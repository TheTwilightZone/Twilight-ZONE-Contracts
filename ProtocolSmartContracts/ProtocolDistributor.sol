pragma solidity ^ 0.8.0;
import "https://github.com/Uniswap/v3-core/blob/main/contracts/libraries/FullMath.sol";
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

interface IOHMERC20 {
    function burnFrom(address account_, uint256 amount_) external;
    function mint(address account_, uint256 amount_) external;
}

interface IProtocolCalculatorOracle {
    function bondValueInProtocolAmount(address _tokenAddress, uint _tokenAmount) external view returns ( uint );
    function bondProfitInProtocolAmount(address _tokenAddress, uint _tokenAmount) external view returns (uint);
    function stakedProtocolToken() external view returns (address);
    function calculateProtocolStakingReward(uint _protocolAmount) external view returns (uint);
}

contract ProtocolDistributor{

    using SafeMath for uint;

    address public manager;
    address public protocolCalculatorOracle;
    address public assetDepository;

    uint public epochLength;
    uint public nextEpochBlock;
    
    StakingReward public stakingReward;
    
    mapping(string => uint) private bondArchive;
    mapping(address => uint) public whichBond;

    mapping(address => AccountProfile) private userProfile;
    
    Bond[] private bondList;

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

    //Bond Stats For A Specific Bond For A Profile
    struct UserBondTerms{
        string name;
        uint totalProtocolAmount;
        uint initialBondBlock;
        uint finalBondBlock;
        uint claimedAmount;
        uint totalProtocolProfit;   
    }

    //User Profile for Staking and Bonds
    struct AccountProfile{
        UserBondTerms[] userBondList;
        mapping(string => uint) userBondArchive;
    }

    struct StakingReward{
        uint protocolRewardAmount;
        uint everyBlockAmount;
    }

    constructor() {
        manager = msg.sender;
    }

    function initialize(uint _epochLength, uint _nextEpochBlock) public isManager returns (bool success){
        epochLength = _epochLength;
        nextEpochBlock = _nextEpochBlock;
        return true;
    }

    function setDepositoryContract(address _assetDepositoryContract) public isManager returns (bool success){
        assetDepository = _assetDepositoryContract;
        return true;
    }

    function setCalculatorContract(address _protocolCalculatorOracleContract) public isManager returns (bool success){
        protocolCalculatorOracle = _protocolCalculatorOracleContract;
        return true;
    }

    function setStakingReward(uint _protocolRewardAmount, uint _everyBlockAmount) public isManager returns (bool success){
        require(_checkResolution(_everyBlockAmount), "This Is Not Set To Propper Resolution");
        stakingReward.protocolRewardAmount = _protocolRewardAmount;
        stakingReward.everyBlockAmount = _everyBlockAmount;
        return true;
    }

    function addBond(string calldata _name, address _tokenAddress, bool  _isLiquidityToken, bool  _isProtocolLiquidity, address _mainLiquidityPair, uint _multiplier, uint _vestingTermInBlocks, string calldata _imageURL) public isManager returns (bool success){
        
        Bond memory newBond = Bond({
            name: _name,
            tokenAddress: _tokenAddress,
            isAuthorized: false,
            isLiquidityToken: _isLiquidityToken,
            isProtocolLiquidity: _isProtocolLiquidity,
            mainLiquidityPair: _mainLiquidityPair,
            multiplier: _multiplier,
            vestingTermInBlocks: _vestingTermInBlocks,
            imageURL: _imageURL
        });

        bondList.push(newBond);
        bondArchive[_name] = (bondList.length).sub(1);
        whichBond[_tokenAddress] = (bondList.length).sub(1);
        return true;
    }

    function getBondName(uint _index) public view returns (string memory bondName) {
        require(_index < bondList.length, "Index Is Out Of Bounds");
        return bondList[_index].name;
    }

    function getBondByName(string calldata _bondName) public view returns (Bond memory bond) {
        return bondList[bondArchive[_bondName]];
    }

    function getBondByID(uint _index) public view returns (Bond memory bond) {
        return bondList[_index];
    }

    function listBonds() public view returns (Bond[] memory bonds){
        return bondList;
    }

    function toggleBondAuthorization(string calldata _bondName) public isManager returns (bool success) {
        if( bondList[bondArchive[_bondName]].isAuthorized = true){
            bondList[bondArchive[_bondName]].isAuthorized = false;
        } else if (bondList[bondArchive[_bondName]].isAuthorized = false) {
            bondList[bondArchive[_bondName]].isAuthorized = true;
        }
        return true;
    }
    
    function checkUserBond(address _userAddress, string calldata _bondName) public view returns (UserBondTerms memory) {
       return userProfile[_userAddress].userBondList[userProfile[_userAddress].userBondArchive[_bondName]];
    }

    function listUserBonds(address _userAddress) public view returns (UserBondTerms[] memory) {
       return userProfile[_userAddress].userBondList;
    }


    function blockUpdate() public returns (bool success){
        
        
        if ( nextEpochBlock <= block.number ) {
            nextEpochBlock = nextEpochBlock.add( epochLength );
        }

        //if ( nextRewardBlock() <= block.number) {

        //}

        return true;
    }


    function currentBlock() public view returns (uint blocks) {
        return block.number;
    }


    function stake(uint _tokenAmount, address _user) public returns (bool success){



        return true;
    }

    //function unStake() public returns (bool success){

    //    return true;
    //}

    function deposit(address _bondToken, uint _tokenAmount, address _user) public returns (bool success){

        uint bondID = whichBond[_bondToken];
        Bond memory theBond = getBondByID(bondID);
        require(theBond.isAuthorized == true, "This Token Is Not Authorized");
        uint protocolValue = IProtocolCalculatorOracle( protocolCalculatorOracle ).bondValueInProtocolAmount(_bondToken, _tokenAmount);
        
        
        uint userBondArchive = userProfile[_user].userBondArchive[theBond.name];
        UserBondTerms memory newTerms = userProfile[_user].userBondList[userBondArchive];
        
        uint profit = IProtocolCalculatorOracle( protocolCalculatorOracle ).bondProfitInProtocolAmount(_bondToken, _tokenAmount);

        newTerms.totalProtocolAmount = newTerms.totalProtocolAmount.add(protocolValue.add(profit));
        
        if (newTerms.initialBondBlock <= 0){
            newTerms.initialBondBlock = currentBlock();
        }
        newTerms.finalBondBlock = currentBlock().add(theBond.vestingTermInBlocks);
        newTerms.totalProtocolProfit = newTerms.totalProtocolProfit.add(profit); 

        userProfile[_user].userBondList[userBondArchive] = newTerms;

        return true;
    }

    function claimBond(string calldata _bondName, address _user) public returns (bool success){
        require(claimAmountForBond(_bondName, _user) > 0);
        uint userBondArchive = userProfile[_user].userBondArchive[_bondName];
        userProfile[_user].userBondList[userBondArchive].claimedAmount += claimAmountForBond(_bondName, _user);
        if(userProfile[_user].userBondList[userBondArchive].finalBondBlock >= currentBlock()){
            userProfile[_user].userBondList[userBondArchive].totalProtocolAmount = 0;
            userProfile[_user].userBondList[userBondArchive].initialBondBlock = 0;
            userProfile[_user].userBondList[userBondArchive].claimedAmount = 0;
            userProfile[_user].userBondList[userBondArchive].totalProtocolProfit = 0;
        }

        return true;
    }

    
    function claimAmountForBond(string calldata _bondName, address _user) public view returns (uint){
    
        uint userBondArchive = userProfile[_user].userBondArchive[_bondName];
        UserBondTerms memory bondTerms = userProfile[_user].userBondList[userBondArchive];
        require(bondTerms.finalBondBlock >= currentBlock());

        uint protocolDelta = bondTerms.finalBondBlock.sub(bondTerms.initialBondBlock);
        uint currentDelta = currentBlock().sub(bondTerms.initialBondBlock);

        return (FullMath.mulDiv(currentDelta, bondTerms.totalProtocolAmount, protocolDelta).sub(bondTerms.claimedAmount));
    }




    function _checkResolution(uint _blockAmount) private view returns (bool) {

        if(_blockAmount == epochLength){return true;}
        if(_blockAmount == epochLength.div(2)){return true;}
        if(_blockAmount == epochLength.div(3)){return true;}
        if(_blockAmount == epochLength.div(4)){return true;}
        if(_blockAmount == epochLength.div(6)){return true;}
        if(_blockAmount == epochLength.div(8)){return true;}
        
        return false;
    }




    //function _calculateProtocolStakingReward(uint _protocolAmount) private view returns (uint){
        //return FullMath.mulDiv(_protocolAmount, stakingReward.protocolRewardAmount, (10 ** IERC20( protocolToken ).decimals()));
    //}

    //function _calculateProtocolBondingReward() private view returns (){
        
    //}


    //Modifiers
    modifier isManager() {
        require(msg.sender == manager);
        _;
    }

    modifier isDepositor() {
        require(msg.sender == assetDepository);
        _;
    }
    //End Modifiers


    //Events
    event ManagerChange(address indexed _previousManager, address indexed _newManager);
    //End Events

}
