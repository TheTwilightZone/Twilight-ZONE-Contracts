pragma solidity ^ 0.8.0;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/utils/SafeERC20.sol";

//ERC20 Interface
interface IProtocolDistributor {
    function stake(uint _tokenAmount, address _user) external returns (bool success);
    function unStake(uint _tokenAmount, address _user) external returns (bool success);
    function deposit(address _bondToken, uint _tokenAmount, address _user) external returns (bool success);
    function claimBond(string calldata _bondName, address _user) external returns (bool success);
    function whichBond(address) external returns (uint);
    function getBondByID(uint _index) external view returns (Bond memory bond);
}

interface IProtocolCalculatorOracle {
    function bondValueInProtocolAmount(address _tokenAddress, uint _tokenAmount) external view returns ( uint );
    function bondProfitInProtocolAmount(address _tokenAddress, uint _tokenAmount) external view returns (uint);
    function stakedProtocolToken() external view returns (address);
    function protocolToken() external view returns (address);
    function calculateProtocolStakingReward(uint _protocolAmount) external view returns (uint);
    function ProtocolDistributor() external view returns (address);

}

//Individual Bonds
    struct Bond{
        string name;                 //Bond Name
        address tokenAddress;        //Accepted Token To Deposit For Bond
        bool isAuthorized;           //Toggles Activation
        bool isLiquidityToken;       //Single Asset, or LP?
        bool isProtocolLiquidity;    //Is One Half Of The mainLiquidityPair The Protocol Token? 
        address mainLiquidityPair;   //Has To Be Paired with Protocol Token or Price Token, [Duplicate Address if LP Token]
        uint multiplier;             //Out of 1000, 500 = 50%, 250 = 25%
        uint vestingTermInBlocks;    //How Many Blocks Untill Fully Vested
        string imageURL;             //Used For WebSite Generation [Bond Image]
    }

contract ProtocolAssetDepository{

    address public manager;                                  //Owner Of Contract [MultiSig]
    address public protocolCalculatorOracle;                 //Calculator Contract

    //Construct This Baby
    constructor() {
        manager = msg.sender;
    }

    function setProtocolCalculatorOracle(address _calculatorContract) public isManager returns(bool){
        protocolCalculatorOracle = _calculatorContract;
        return true;
    }

    function stakeProtocol(uint _tokenAmount) public returns (bool) {
        address protocolToken = IProtocolCalculatorOracle( protocolCalculatorOracle ).protocolToken();
        address protocolDistributor = IProtocolCalculatorOracle( protocolCalculatorOracle ).ProtocolDistributor();
        require(IERC20( protocolToken ).balanceOf(msg.sender) >= _tokenAmount, "User Does Not Have Enough Protocol Balance");
        require(IERC20( protocolToken ).allowance(msg.sender, address(this)) >= _tokenAmount, "Asset Depository Contract Needs To Approve");
        SafeERC20.safeTransferFrom(IERC20(protocolToken), msg.sender, address(this), _tokenAmount);
        require(IProtocolDistributor( protocolDistributor ).stake(_tokenAmount, msg.sender), "Failed To Distribute");
        return true;
    }

    function unstakeProtocol(uint _tokenAmount) public returns (bool){
        address stakedToken = IProtocolCalculatorOracle( protocolCalculatorOracle ).stakedProtocolToken();  
        address protocolDistributor = IProtocolCalculatorOracle( protocolCalculatorOracle ).ProtocolDistributor();
        require(IERC20( stakedToken ).balanceOf(msg.sender) >= _tokenAmount, "User Does Not Have Enough Protocol Balance");
        require(IERC20( stakedToken ).allowance(msg.sender, address(this)) >= _tokenAmount, "Asset Depository Contract Needs To Approve"); 
        SafeERC20.safeTransferFrom(IERC20(stakedToken), msg.sender, address(this), _tokenAmount);
        require(IProtocolDistributor( protocolDistributor ).unStake(_tokenAmount, msg.sender), "Failed To Distribute");
        return true;
    }

    function depositForBond(address _tokenAddress, uint _tokenAmount) public returns (bool){
        address protocolDistributor = IProtocolCalculatorOracle( protocolCalculatorOracle ).ProtocolDistributor();
        require(IERC20(  _tokenAddress ).balanceOf(msg.sender) >= _tokenAmount, "User Does Not Have Enough Protocol Balance");
        require(IERC20( _tokenAddress ).allowance(msg.sender, address(this)) >= _tokenAmount, "Asset Depository Contract Needs To Approve"); 
        require(IProtocolDistributor( protocolDistributor ).deposit(_tokenAddress, _tokenAmount, msg.sender), "Failed To Deposit");
        SafeERC20.safeTransferFrom(IERC20(_tokenAddress), msg.sender, manager, _tokenAmount);
        return true;
    }

    function claimBond(string calldata _bondName) public returns (bool){
        address protocolDistributor = IProtocolCalculatorOracle( protocolCalculatorOracle ).ProtocolDistributor();
        require(IProtocolDistributor( protocolDistributor ).claimBond(_bondName, msg.sender), "Failed To Distribute");
        return true;
    }

    function changeManager(address _newManager) public isManager returns (bool success) {
        emit ManagerChange(manager, _newManager);  
        manager = _newManager;                    
        return true;
    }


    modifier isManager() {
        require(msg.sender == manager);
        _;
    }

    event ManagerChange(address indexed _previousManager, address indexed _newManager);

}