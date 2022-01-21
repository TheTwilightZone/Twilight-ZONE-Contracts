pragma solidity ^ 0.8.0;
import "https://github.com/TheTwilightZone/Twilight-ZONE-Contracts/blob/main/DependencyContracts/FullMath.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/math/SafeMath.sol";


interface IERC20 {
    function totalSupply() external view returns(uint256);
    function balanceOf(address account) external view returns(uint256);
    function transfer(address recipient, uint256 amount) external returns(bool);
    function allowance(address owner, address spender) external view returns(uint256);
    function approve(address spender, uint256 amount) external returns(bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns(bool);
    function decimals() external view returns (uint8);
}

interface IUniswapV2Pair {
    function getReserves() external view returns(uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function token0() external view returns(address);
    function token1() external view returns(address);
}

interface IProtocolDistributor {
    function whichBond(address) external view returns (uint);
    function stakingReward() external view returns (StakingReward memory);
    function getBondName(uint _index) external view returns (string memory bondName);
    function getBondByName(string calldata _bondName) external view returns (Bond memory bond);
    function getBondByID(uint _index) external view returns (Bond memory bond);
    function listBonds() external view returns (Bond[] memory bonds);
    function currentBlock() external view returns (uint blocks);
}

//Individual Bonds
struct Bond{
    string name;
    address tokenAddress;
    bool isAuthorized;
    bool isLiquidityToken;
    bool isProtocolLiquidity;
    address mainLiquidityPair; //Paired with Protocol Token, or Price Token [Duplicate if LP Token]

    uint multiplier; //Out 1000
    uint vestingTermInBlocks;
    string imageURL;
}

struct StakingReward{
    uint protocolRewardAmount;
    uint everyBlockAmount;
}


contract ProtocolCalculatorOracle{

    using SafeMath for uint;


    address public manager;
    address public ProtocolDistributor;

    address public protocolToken;
    address public stakedProtocolToken;
    address public protocolLiqudityToken;
    address public priceToken;


    constructor() {
        manager = msg.sender;
    }

    function initialize(address _protocolToken, address _liqudityToken, address _priceToken) public isManager returns (bool success){
        require(_protocolToken != address(0), "Stop Playin");
        require(_liqudityToken != address(0), "Stop Playin");
        protocolToken = _protocolToken;
        protocolLiqudityToken = _liqudityToken;
        priceToken = _priceToken;
        return true;
    }

    function setdistributorContract(address _protocolDistributorContract) public isManager returns (bool success){
        ProtocolDistributor = _protocolDistributorContract;
        return true;
    }
    
    function setStakingContract(address _stakedProtocolToken) public isManager returns (bool success){
        stakedProtocolToken = _stakedProtocolToken;
        return true;
    }

   function protocolTokenPrice() public view returns ( uint ) {
        return (_pairPrice(protocolLiqudityToken, protocolToken));
    }

    function protocolInPriceAmount(uint _tokenAmount) public view returns ( uint ) {
        uint decimals = 10 ** IERC20( protocolToken ).decimals();
        return FullMath.mulDiv(_tokenAmount, protocolTokenPrice(), decimals);
    }

    function protocolMintAmount(uint _tokenAmount) public view returns ( uint ) {
        uint decimals = 10 ** IERC20( protocolToken ).decimals();
        return FullMath.mulDiv(_tokenAmount, decimals, protocolTokenPrice());
    }

    function calculateProtocolStakingReward(uint _protocolAmount) public view returns (uint){
        return FullMath.mulDiv(_protocolAmount, IProtocolDistributor( ProtocolDistributor ).stakingReward().protocolRewardAmount, (10 ** IERC20( protocolToken ).decimals()));
    }

    function bondProfitInProtocolAmount(address _tokenAddress, uint _tokenAmount) public view returns (uint){
        uint bondID = IProtocolDistributor( ProtocolDistributor ).whichBond(_tokenAddress);
        uint bondMultiplier = IProtocolDistributor( ProtocolDistributor ).getBondByID(bondID).multiplier;
        uint bondValue = bondValueInProtocolAmount(_tokenAddress, _tokenAmount);

        return (FullMath.mulDiv(bondValue, bondMultiplier, 1000));

    }

    function bondValueInProtocolAmount(address _tokenAddress, uint _tokenAmount) public view returns ( uint ) {
        require(_tokenAddress != address(0), "Stop Playin");
       
       uint bondID = IProtocolDistributor( ProtocolDistributor ).whichBond(_tokenAddress);
       bool isLP = IProtocolDistributor( ProtocolDistributor ).getBondByID(bondID).isLiquidityToken;
       
        if( isLP == true){
            
            bool isProtocolLP = IProtocolDistributor( ProtocolDistributor ).getBondByID(bondID).isProtocolLiquidity;

            if(isProtocolLP == true){
                uint inLiquidity = IERC20( protocolToken ).balanceOf(_tokenAddress);
                uint totalLiqudity = IERC20(_tokenAddress).totalSupply();
                uint totalProtocolAmount = FullMath.mulDiv(_tokenAmount, inLiquidity, totalLiqudity);
                return totalProtocolAmount.mul(2);
            } else {
                uint inLiquidity = IERC20( priceToken ).balanceOf(_tokenAddress);
                uint totalLiqudity = IERC20(_tokenAddress).totalSupply();
                uint totalPriceAmount = FullMath.mulDiv(_tokenAmount, inLiquidity, totalLiqudity);
                uint totalProtocolAmount = protocolMintAmount(totalPriceAmount);
                return totalProtocolAmount.mul(2);
             }


        } else if (IProtocolDistributor( ProtocolDistributor ).getBondByID(bondID).isLiquidityToken == false){

             bool isProtocolLP = IProtocolDistributor( ProtocolDistributor ).getBondByID(bondID).isProtocolLiquidity;

            if(isProtocolLP == true){
                uint singleToken = (10 ** IERC20( _tokenAddress ).decimals());
                uint singleTokenValue = _pairPrice(IProtocolDistributor( ProtocolDistributor ).getBondByID(bondID).mainLiquidityPair, _tokenAddress);
                return FullMath.mulDiv(_tokenAmount, singleTokenValue, singleToken);
            } else {
                uint singleToken = (10 ** IERC20( _tokenAddress ).decimals());
                uint singleTokenPrice = _pairPrice(IProtocolDistributor( ProtocolDistributor ).getBondByID(bondID).mainLiquidityPair, _tokenAddress);
                uint singleTokenValue = protocolMintAmount(singleTokenPrice);
                return FullMath.mulDiv(_tokenAmount, singleTokenValue, singleToken);
            }
        }

        return 0;
    }

    function _pairPrice(address _liquidityPair, address _unpricedToken) private view returns ( uint ) {
        ( uint reserve0, uint reserve1, ) = IUniswapV2Pair( _liquidityPair ).getReserves();

        uint unpricedAmount;
        uint pricedAmount;
        uint decimals;

        if ( IUniswapV2Pair( _liquidityPair ).token0() == _unpricedToken ) {
            decimals = (10 ** IERC20( IUniswapV2Pair( _liquidityPair ).token0() ).decimals());
            pricedAmount = reserve1;
            unpricedAmount = reserve0;
        } else {
            decimals = (10 ** IERC20( IUniswapV2Pair( _liquidityPair ).token1() ).decimals());
            pricedAmount = reserve0;
            unpricedAmount = reserve1;
        }

        return FullMath.mulDiv(pricedAmount, decimals, unpricedAmount);
    }


  
    //Managment Function
    function changeManager(address _newManager) public isManager returns (bool success) {
        emit ManagerChange(manager, _newManager);
        manager = _newManager;
        return true;
    }


    //Modifiers
    modifier isManager() {
        require(msg.sender == manager);
        _;
    }
    //End Modifiers


    //Events
    event ManagerChange(address indexed _previousManager, address indexed _newManager);
    //End Events

}