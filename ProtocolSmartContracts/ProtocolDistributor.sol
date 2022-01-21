pragma solidity ^ 0.8.0;
import "https://github.com/TheTwilightZone/Twilight-ZONE-Contracts/blob/main/ProtocolSmartContracts/FullMath.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/math/SafeMath.sol";


//ERC20 Interface
interface IERC20 {
    function totalSupply() external view returns(uint256);
    function balanceOf(address account) external view returns(uint256);
    function transfer(address recipient, uint256 amount) external returns(bool);
    function allowance(address owner, address spender) external view returns(uint256);
    function approve(address spender, uint256 amount) external returns(bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns(bool);
    function decimals() external view returns (uint8);
}

//Liquidity Token Interface
interface IUniswapV2Pair {
    function getReserves() external view returns(uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function token0() external view returns(address);
    function token1() external view returns(address);
}

//Protocol Token Interface
interface IProtocolERC20 {
    function burnFrom(address account_, uint256 amount_) external;
    function mint(address account_, uint256 amount_) external;
}

//Calculator Interface
interface IProtocolCalculatorOracle {
    function bondValueInProtocolAmount(address _tokenAddress, uint _tokenAmount) external view returns ( uint );
    function bondProfitInProtocolAmount(address _tokenAddress, uint _tokenAmount) external view returns (uint);
    function stakedProtocolToken() external view returns (address);
    function calculateProtocolStakingReward(uint _protocolAmount) external view returns (uint);
}

contract ProtocolDistributor{

    //Using that Safe Math
    using SafeMath for uint;

    //Standard Declarations
    address public manager;
    address public protocolCalculatorOracle; //Calculator Contract
    address public assetDepository; //OnRamp Contract

    //Epoch Stuff
    uint public epochLength;
    uint public nextEpochBlock;
    
    //Staking Reward Info
    StakingReward public stakingReward;
    
    //Bond Stuff
    mapping(string => uint) private bondArchive;
    mapping(address => uint) public whichBond;
    Bond[] private bondList;

    //User Storage
    mapping(address => AccountProfile) private userProfile;

//----STRUCTS----//

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
        mapping(string => bool) isInitialized;
        mapping(string => uint) userBondArchive;
    }

    //Staking Reward Settings
    struct StakingReward{
        uint protocolRewardAmount;
        uint everyBlockAmount;
    }

//----END STRUCTS----//


    //Construct This Baby
    constructor() {
        manager = msg.sender;
    }


    //Add Epoch Info, Used for Staking and Bonds
    function initializeEpoch(uint _epochLength, uint _nextEpochBlock) public isManager returns (bool success){
        epochLength = _epochLength;
        nextEpochBlock = _nextEpochBlock;
        return true;
    }

    //Sets the Depository Contract
    function setDepositoryContract(address _assetDepositoryContract) public isManager returns (bool success){
        assetDepository = _assetDepositoryContract;
        return true;
    }

    //Sets the Calculator Contract
    function setCalculatorContract(address _protocolCalculatorOracleContract) public isManager returns (bool success){
        protocolCalculatorOracle = _protocolCalculatorOracleContract;
        return true;
    }

    //Changes Staking Reward
    function setStakingReward(uint _protocolRewardAmount, uint _everyBlockAmount) public isManager returns (bool success){
        require(_checkResolution(_everyBlockAmount), "This Is Not Set To Propper Resolution");
        stakingReward.protocolRewardAmount = _protocolRewardAmount;
        stakingReward.everyBlockAmount = _everyBlockAmount;
        return true;
    }

    //Add a New Bond
    function addBond(string calldata _name, address _tokenAddress, bool  _isLiquidityToken, bool  _isProtocolLiquidity, address _mainLiquidityPair, uint _multiplier, uint _vestingTermInBlocks, string calldata _imageURL) public isManager returns (bool success){
        
        //Create New Bond
        Bond memory newBond = Bond({
            name: _name, //Bond Name
            tokenAddress: _tokenAddress, //Purchase Token
            isAuthorized: false,
            isLiquidityToken: _isLiquidityToken, //Is this an LP
            isProtocolLiquidity: _isProtocolLiquidity, //Is it paired with Protocol Token
            mainLiquidityPair: _mainLiquidityPair, //LP Pair for the Token, if isLiquidity then Duplicate
            multiplier: _multiplier, //Out of 1000, 500 = %50 increase, 250 = %25 increase
            vestingTermInBlocks: _vestingTermInBlocks, //Bond Finialization Time
            imageURL: _imageURL //For Website Generation
        });

        bondList.push(newBond); //Push Bonds to BondsList
        bondArchive[_name] = (bondList.length).sub(1); //Update Archive
        whichBond[_tokenAddress] = (bondList.length).sub(1); //Update Bond
        return true;
    }

    //Gets Bond Name from Index
    function getBondName(uint _index) public view returns (string memory bondName) {
        require(_index < bondList.length, "Index Is Out Of Bounds");
        return bondList[_index].name;
    }

    //Gets Bond by Name
    function getBondByName(string calldata _bondName) public view returns (Bond memory bond) {
        return bondList[bondArchive[_bondName]];
    }

    //Gets Bond by Index
    function getBondByID(uint _index) public view returns (Bond memory bond) {
        return bondList[_index];
    }

    //Lists out all Bonds
    function listBonds() public view returns (Bond[] memory bonds){
        return bondList;
    }

    //Toggles a Bond on or Off
    function toggleBondAuthorization(string calldata _bondName) public isManager returns (bool success) {
        if( bondList[bondArchive[_bondName]].isAuthorized == true){
            bondList[bondArchive[_bondName]].isAuthorized = false;
        } else if (bondList[bondArchive[_bondName]].isAuthorized == false) {
            bondList[bondArchive[_bondName]].isAuthorized = true;
        }
        return true;
    }
    
    //Checks UserBondTerms for an Address
    function checkUserBond(address _userAddress, string calldata _bondName) public view returns (UserBondTerms memory) {
       uint userBondID = userProfile[_userAddress].userBondArchive[_bondName];
       require(userProfile[_userAddress].isInitialized[_bondName], "Bond Is Not Initialized");
       return userProfile[_userAddress].userBondList[userBondID];
    }

    //Lists All Users Bonds
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

    //Gets Current Block
    function currentBlock() public view returns (uint blocks) {
        return block.number;
    }


    //Stakes Coin By Wrapping
    //function stake(uint _tokenAmount, address _user) public returns (bool success){
        //return true;
    //}

    //Unstakes Coin By Unwrapping
    //function unStake(uint _tokenAmount, address _user) public returns (bool success){

        //return true;
    //}

    //Adds a Userbond to Deposits 
    function deposit(address _bondToken, uint _tokenAmount, address _user) public returns (bool success){

        uint bondID = whichBond[_bondToken]; //Get Bond ID
        Bond memory theBond = getBondByID(bondID); //Pull Bond

        require(theBond.isAuthorized == true, "This Token Is Not Authorized"); //Require Authorization
        
        //Get Bond Value In Protocol Amount
        uint protocolValue = IProtocolCalculatorOracle( protocolCalculatorOracle ).bondValueInProtocolAmount(_bondToken, _tokenAmount);
        uint bondListNumber = userProfile[_user].userBondList.length; //Get BondList Lenght

        //Handles Empty Data
        if(userProfile[_user].isInitialized[theBond.name] == false){
            userProfile[_user].userBondList.push(UserBondTerms({
                name: theBond.name,
                totalProtocolAmount: 0,
                initialBondBlock: 0,
                finalBondBlock: 0,
                claimedAmount: 0,
                totalProtocolProfit: 0
            }));
            userProfile[_user].isInitialized[theBond.name] = true;
            userProfile[_user].userBondArchive[theBond.name] = bondListNumber;
        }

        uint userBondID = userProfile[_user].userBondArchive[theBond.name];

        //Require BondTerms Exsis
        require(_compareStrings(userProfile[_user].userBondList[userBondID].name, theBond.name));

        //Copies External UserBondTerms and creates Local
        UserBondTerms memory newTerms = userProfile[_user].userBondList[userBondID];

        //Calculates Bond Profit
        uint profit = IProtocolCalculatorOracle( protocolCalculatorOracle ).bondProfitInProtocolAmount(_bondToken, _tokenAmount);

        //Adds Profit To Local BondTerms
        newTerms.totalProtocolAmount = newTerms.totalProtocolAmount.add(protocolValue.add(profit));
        
        //Changes Initial Block Only if 0
        if (newTerms.initialBondBlock <= 0){
            newTerms.initialBondBlock = currentBlock();
        }

        //Sets Final Bond Block
        newTerms.finalBondBlock = currentBlock().add(theBond.vestingTermInBlocks);

        //Updates Total Profit Recieved From Bond
        newTerms.totalProtocolProfit = newTerms.totalProtocolProfit.add(profit); 

        //Merges Local With External
        userProfile[_user].userBondList[userBondID] = newTerms;

        return true;
    }

    //Adjusts Information to Claim Bonds
    function claimBond(string calldata _bondName, address _user) public returns (bool success){
        require(claimAmountForBond(_bondName, _user) > 0, "You Have Nothing To Claim");
        require(userProfile[_user].isInitialized[_bondName], "For Some Reason Your Bond Isn't Initialized");
        uint userBondID = userProfile[_user].userBondArchive[_bondName]; //Get Bond ID
        userProfile[_user].userBondList[userBondID].claimedAmount = userProfile[_user].userBondList[userBondID].claimedAmount.add(claimAmountForBond(_bondName, _user));
        if(userProfile[_user].userBondList[userBondID].finalBondBlock <= currentBlock()){
            userProfile[_user].userBondList[userBondID].totalProtocolAmount = 0;
            userProfile[_user].userBondList[userBondID].initialBondBlock = 0;
            userProfile[_user].userBondList[userBondID].finalBondBlock = 0;
            userProfile[_user].userBondList[userBondID].claimedAmount = 0;
            userProfile[_user].userBondList[userBondID].totalProtocolProfit = 0;
        }

        return true;
    }

    //Gets The Amount Needed to CLaim
    function claimAmountForBond(string calldata _bondName, address _user) public view returns (uint){
    
        uint userBondID = userProfile[_user].userBondArchive[_bondName]; //Get Bond ID
        UserBondTerms memory bondTerms = userProfile[_user].userBondList[userBondID];
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


    function _compareStrings(string memory a, string memory b) private pure returns (bool) {
    return (keccak256(bytes(a)) == keccak256(bytes(b)));
    }


    //function _calculateProtocolStakingReward(uint _protocolAmount) private view returns (uint){
        //return FullMath.mulDiv(_protocolAmount, stakingReward.protocolRewardAmount, (10 ** IERC20( protocolToken ).decimals()));
    //}

    //function _calculateProtocolBondingReward() private view returns (){
        
    //}

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

    modifier isDepositor() {
        require(msg.sender == assetDepository);
        _;
    }
    //End Modifiers


    //Events
    event ManagerChange(address indexed _previousManager, address indexed _newManager);
    //End Events

}