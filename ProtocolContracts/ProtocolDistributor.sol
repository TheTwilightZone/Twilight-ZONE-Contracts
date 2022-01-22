pragma solidity ^ 0.8.0;
import "https://github.com/TheTwilightZone/Twilight-ZONE-Contracts/blob/main/DependencyContracts/FullMath.sol";
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
    function mint(address to, uint256 _amount) external returns(bool);
    function burn(address account_, uint256 amount_) external returns(bool);
    function protocolToReserve(uint256 _amount) external view returns(uint);
    function reserveToProtocol(uint256 _amount) external view returns(uint);
    function addToReservoir(uint _amount) external returns(bool);
    function protocolReservoir() external view returns(uint);
    function owner() external view returns (address);
    function transferOwnership(address newOwner) external;
}

//Bleh - Disgusting
interface IOhmERC20 {
    function burnFrom(address account_, uint256 amount_) external;
    function mint(address account_, uint256 amount_) external;
    function allowance(address owner, address spender) external view returns (uint256);
    function owner() external view returns (address);
     function transferOwnership( address newOwner_ ) external;
}

//Calculator Interface
interface IProtocolCalculatorOracle {
    function bondValueInProtocolAmount(address _tokenAddress, uint _tokenAmount) external view returns ( uint );
    function bondProfitInProtocolAmount(address _tokenAddress, uint _tokenAmount) external view returns (uint);
    function stakedProtocolToken() external view returns (address);
    function protocolToken() external view returns (address);
    function calculateProtocolStakingReward(uint _protocolAmount) external view returns (uint);

}


contract ProtocolDistributor{

    //Construct This Baby
    constructor() {
        manager = msg.sender;
    }


//----INITIALIZERS----//
    
    using SafeMath for uint;                                 //Using That Safe Math
    address public manager;                                  //Owner Of Contract [MultiSig]
    address public protocolCalculatorOracle;                 //Calculator Contract
    address public assetDepository;                          //Staking & Depositing OnRamp Contract
    EpochInfo public epochInfo;                              //Chain Epoch Information
    StakingReward public stakingReward;                      //Staking Reward Info
    mapping(string => uint) private bondArchive;             //Bond String To Bond Index
    mapping(address => uint) public whichBond;               //Token Address To Bond Index
    Bond[] private bondList;                                 //Array Of All Bonds
    mapping(address => AccountProfile) private userProfile;  //User Storage

//----END INITIALIZERS----//


//====================//
//DO YOU LIKE MY CODE?//
//====================//


//----STRUCTS----//

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

    //Bond Stats For A Specific Bond (For User Profiles)
    struct UserBondTerms{
        string name;                 //Bond Name
        uint totalProtocolAmount;    //Total Amount Of Protocol Tokens Owed
        uint initialBondBlock;       //Intitially Bonded On What Block?
        uint finalBondBlock;         //Final Complete Vesting Block
        uint claimedAmount;          //How Much Protocol Tokens Have Been Claimed So Far
        uint totalProtocolProfit;    //Total Actual Protocol Token Profits
    }

    //User Profile for Staking and Bonds
    struct AccountProfile{
        UserBondTerms[] userBondList;             //Users Bond List Of Vesting Bonds
        mapping(string => bool) isInitialized;    //Checks If Bond Has Been Used Before
        mapping(string => uint) userBondArchive;  //Bond String To User Bond Index
    }

    //Staking Reward Settings
    struct StakingReward{            
        uint protocolRewardAmount;   //Protocol Token Reward Amount Per [One Token = (10 ** Decimals())]
        uint everyBlockAmount;       //Distribute Rewards After This Many Blocks
        uint nextRewardBlock;        //Next Rewarded Is Distributed On This Block
    }

    //Epoch Info
    struct EpochInfo{
        uint epochLength;         //Epoch Size (Specific Per Chain)
        uint nextEpochBlock;      //Epoch Block Index
    }

//----END STRUCTS----//


//====================//
//DO YOU LIKE MY CODE?//
//====================//


//----MANAGEMENT FUCNTIONS----//

    //Change Owner
    function changeManager(address _newManager) public isManager returns (bool success) {
        emit ManagerChange(manager, _newManager);  
        manager = _newManager;                    
        return true;
    }

    //Initialize Important Settings
    function initialize(uint _epochLength, uint _nextEpochBlock, uint _firstRewardBlock, address _protocolCalculatorOracleContract, address _assetDepositoryContract) public isManager returns (bool success){
        epochInfo.epochLength = _epochLength;
        epochInfo.nextEpochBlock = _nextEpochBlock;
        stakingReward.nextRewardBlock = _firstRewardBlock;
        protocolCalculatorOracle = _protocolCalculatorOracleContract;
        assetDepository = _assetDepositoryContract;
        return true;
    }

    //Sets the Depository Contract [0 = protocolCalculatorOracle, 1 = assetDepository]
    function setContract(uint _ID, address _contractAddress) public isManager returns (bool success){
        if(_ID == 0){
            protocolCalculatorOracle = _contractAddress;
            return true;
        }else if (_ID == 1){
            assetDepository = _contractAddress;
            return true;
        }
        return false;
    }

    //Changes Token Ownership To New Address
    function newTokenOwner(address _updatedContract) public isManager returns (bool success){
        address protocolToken = IProtocolCalculatorOracle( protocolCalculatorOracle ).protocolToken();
        address stakedToken = IProtocolCalculatorOracle( protocolCalculatorOracle ).stakedProtocolToken();
        require(IProtocolERC20( stakedToken ).owner() == address(this), "This Contract Doesn't Own This Token");
        require(IOhmERC20( protocolToken ).owner() == address(this), "This Contract Doesn't Own This Token");
        IProtocolERC20( stakedToken ).transferOwnership(_updatedContract);
        IOhmERC20( protocolToken ).transferOwnership(_updatedContract);
        return true;
    }

    //Changes Staking Reward
    function setStakingReward(uint _protocolRewardAmount, uint _everyBlockAmount) public isManager returns (bool success){
        require(_checkResolution(_everyBlockAmount), "This Is Not Set To Propper Resolution");  //HardCoded Set Intervals
        stakingReward.protocolRewardAmount = _protocolRewardAmount;
        stakingReward.everyBlockAmount = _everyBlockAmount;
        return true;
    }

    //Add a New Bond
    function addBond(string calldata _name, address _tokenAddress, bool  _isLiquidityToken, bool  _isProtocolLiquidity, address _mainLiquidityPair, uint _multiplier, uint _vestingTermInBlocks, string calldata _imageURL) public isManager returns (bool success){
        
        //Checks Duplicates
        if(bondList.length > 0){
            require(bondList[bondArchive[_name]].isAuthorized != true, "You Have To DeAuthorize If You Want To Replace A Bond");
        }

        //Create New Bond
        Bond memory newBond = Bond({
            name: _name,                                //Bond Name
            tokenAddress: _tokenAddress,                //Purchase Token
            isAuthorized: false,                        //Toggle It Later Baby
            isLiquidityToken: _isLiquidityToken,        //Is this an LP
            isProtocolLiquidity: _isProtocolLiquidity,  //Is it paired with Protocol Token
            mainLiquidityPair: _mainLiquidityPair,      //LP Pair for the Token, if isLiquidity then Duplicate
            multiplier: _multiplier,                    //Out of 1000, 500 = %50 increase, 250 = %25 increase
            vestingTermInBlocks: _vestingTermInBlocks,  //Bond Finialization Time
            imageURL: _imageURL                         //For Website Generation
        });

        bondList.push(newBond);                               //Push Bonds to BondsList
        bondArchive[_name] = (bondList.length).sub(1);        //Update Archive
        whichBond[_tokenAddress] = (bondList.length).sub(1);  //Update Bond
        return true;                                          //Ship It
    }

    //Edits Bond Settings [0 = multiplier, 1 = vestingTerm]
    function setBondValue(string calldata _bondName, uint _ID, uint _value) public isManager returns (bool success){
        if(_ID == 0){
            bondList[bondArchive[_bondName]].multiplier = _value;
            return true;
        }else if (_ID == 1){
            bondList[bondArchive[_bondName]].vestingTermInBlocks = _value;
            return true;
        }
        return false;
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

//----END MANAGEMENT FUCNTIONS----//


//====================//
//DO YOU LIKE MY CODE?//
//====================//


//----PLEB FUCNTIONS----//

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

    //Gets The Amount Needed to CLaim
    function claimAmountForBond(string calldata _bondName, address _user) public view returns (uint){
    
        uint userBondID = userProfile[_user].userBondArchive[_bondName]; //Get Bond ID
        UserBondTerms memory bondTerms = userProfile[_user].userBondList[userBondID];
        require(bondTerms.finalBondBlock >= currentBlock());

        uint protocolDelta = bondTerms.finalBondBlock.sub(bondTerms.initialBondBlock);
        uint currentDelta = currentBlock().sub(bondTerms.initialBondBlock);

        return (FullMath.mulDiv(currentDelta, bondTerms.totalProtocolAmount, protocolDelta).sub(bondTerms.claimedAmount));
    }

//----END PLEB FUCNTIONS----//


//====================//
//DO YOU LIKE MY CODE?//
//====================//


//----REWARD MANAGEMENT FUCNTIONS----//

    //Stakes Coin By Burn MintWrapping
    function stake(uint _tokenAmount, address _user) public isDepositor returns (bool success){
        address stakedToken = IProtocolCalculatorOracle( protocolCalculatorOracle ).stakedProtocolToken();          //Gets Staked Token
        address protocolToken = IProtocolCalculatorOracle( protocolCalculatorOracle ).protocolToken();
        require(address(this) == IOhmERC20( protocolToken ).owner(), "Contract Is Not Protocol Token Owner");
        require(address(this) == IProtocolERC20( stakedToken ).owner(), "Contract Is Not Staked Token Owner");
        uint mintAmount = IProtocolERC20( stakedToken ).protocolToReserve(_tokenAmount);                            //Determines Mint Amount
        require(IOhmERC20( protocolToken ).allowance(assetDepository, address(this)) >= _tokenAmount, "Asset Depository Contract Needs To Approve");
        IOhmERC20( protocolToken ).burnFrom(assetDepository, _tokenAmount);                                           //Burn The Fake Money
        require(IProtocolERC20( stakedToken ).mint(_user, mintAmount), "Staked Token Not Minted For Some Reason");  //Require Mint Tokens
        emit ProtocolStaked(_user, _tokenAmount);                                                                   //Log That Shit
        blockUpdate();                                                                                              //Routine
        return true;                                                                                                //Ship It
    }

    //Unstakes Coin By Burn MintWrapping
    function unStake(uint _tokenAmount, address _user) public isDepositor returns (bool success){
        address stakedToken = IProtocolCalculatorOracle( protocolCalculatorOracle ).stakedProtocolToken();          //Gets Staked Token
        address protocolToken = IProtocolCalculatorOracle( protocolCalculatorOracle ).protocolToken();
        require(address(this) == IOhmERC20( protocolToken ).owner(), "Contract Is Not Protocol Token Owner");
        require(address(this) == IProtocolERC20( stakedToken ).owner(), "Contract Is Not Staked Token Owner");
        uint mintAmount = IProtocolERC20( stakedToken ).reserveToProtocol(_tokenAmount);                            //Determines Mint Amount
        require(IProtocolERC20( stakedToken ).burn(assetDepository, mintAmount), "Staked Token Not Burned For Some Reason");
        IOhmERC20( protocolToken ).mint(_user, mintAmount); 
        emit ProtocolUnStaked(_user, mintAmount);
        blockUpdate();
        return true;
    }

    //Adds a Userbond to Deposits 
    function deposit(address _bondToken, uint _tokenAmount, address _user) public isDepositor returns (bool success){
        uint bondID = whichBond[_bondToken];                                    //Get Bond ID
        Bond memory theBond = getBondByID(bondID);                              //Pull Bond
        require(_bondToken == theBond.tokenAddress, "Bond Doesn't Match");
        require(theBond.isAuthorized == true, "This Token Is Not Authorized");  //Require Token Authorization
        
        //Get Bond Value In Protocol Amount
        uint protocolValue = IProtocolCalculatorOracle( protocolCalculatorOracle ).bondValueInProtocolAmount(_bondToken, _tokenAmount);
        uint bondListNumber = userProfile[_user].userBondList.length;

        //Handles Empty User Data
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

        uint userBondID = userProfile[_user].userBondArchive[theBond.name];                        //Gets ID Of User Bond Data
        require(_compareStrings(userProfile[_user].userBondList[userBondID].name, theBond.name));  //Require That The BondTerm Is Initialized

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

        newTerms.finalBondBlock = currentBlock().add(theBond.vestingTermInBlocks);  //Sets Final Bond Block
        newTerms.totalProtocolProfit = newTerms.totalProtocolProfit.add(profit);    //Updates Total Profit Recieved From Bond
        userProfile[_user].userBondList[userBondID] = newTerms;                     //Merges Local With External
        emit BondDeposited(_user, bondID, currentBlock(), _tokenAmount);            //Log That Shit
        blockUpdate();                                                              //Routine
        return true;                                                                //Ship It
    }

    //Adjusts Information to Claim Bonds
    function claimBond(string calldata _bondName, address _user) public isDepositor returns (bool success){
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
        emit BondAmountClaimed(_user, claimAmountForBond(_bondName, _user), currentBlock());
        //blockUpdate();
        return true;
    }

//----END REWARD MANAGEMENT FUCNTIONS----//


//====================//
//DO YOU LIKE MY CODE?//
//====================//


//----CORE FUCNTIONS----//

    //Keep The Block Up To Date
    function blockUpdate() public returns (bool success){
        if ( epochInfo.nextEpochBlock <= currentBlock() ) {
            epochInfo.nextEpochBlock = epochInfo.nextEpochBlock.add( epochInfo.epochLength );
        }
        distribute();
        return true;
    }

    //Distribute Staking Rewards
    function distribute() public returns (bool success){
        if ( stakingReward.nextRewardBlock <= currentBlock()) {
            address stakedToken = IProtocolCalculatorOracle( protocolCalculatorOracle ).stakedProtocolToken();
            uint reservoirAmount = IProtocolERC20( stakedToken ).protocolReservoir();
            uint mintAmount = IProtocolCalculatorOracle( protocolCalculatorOracle ).calculateProtocolStakingReward(reservoirAmount);
            require(IProtocolERC20( stakedToken ).addToReservoir(mintAmount), "Failed To Add To Staking Reservoir");
            emit RewardDistributed(mintAmount, stakingReward.nextRewardBlock);
            stakingReward.nextRewardBlock = stakingReward.nextRewardBlock.add(stakingReward.everyBlockAmount);
            return true;
        }
        return false;
    }

    //Gets Current Block
    function currentBlock() public view returns (uint blocks) {
        return block.number;
    }

//----END CORE FUCNTIONS----//


//====================//
//DO YOU LIKE MY CODE?//
//====================//


//----INTERNAL FUNCTIONS----//
    
    //Compares Strings Cause Solidity Sucks
    function _compareStrings(string memory a, string memory b) private pure returns (bool) {
        return (keccak256(bytes(a)) == keccak256(bytes(b)));
    }

    //Makes Things Managable For Rewards (No Wonk)
    function _checkResolution(uint _blockAmount) private view returns (bool) {

        if(_blockAmount == epochInfo.epochLength){return true;}
        if(_blockAmount == epochInfo.epochLength.div(2)){return true;}
        if(_blockAmount == epochInfo.epochLength.div(3)){return true;}
        if(_blockAmount == epochInfo.epochLength.div(4)){return true;}
        if(_blockAmount == epochInfo.epochLength.div(6)){return true;}
        if(_blockAmount == epochInfo.epochLength.div(8)){return true;}
        
        return false;
    }


//----END INTERNAL FUNCTIONS----//


//====================//
//DO YOU LIKE MY CODE?//
//====================//


//----MODIFIERS----//
    modifier isManager() {
        require(msg.sender == manager);
        _;
    }

    modifier isDepositor() {
        require(msg.sender == assetDepository);
        _;
    }
//----END MODIFIERS----//


//====================//
//DO YOU LIKE MY CODE?//
//====================//


//----EVENTS----//
    event ManagerChange(address indexed _previousManager, address indexed _newManager);
    event ProtocolStaked(address indexed _user, uint _protocolAmount);
    event ProtocolUnStaked(address indexed _user, uint _protocolAmount);
    event BondAmountClaimed(address indexed _user, uint _protocolAmount, uint _blockNumber);
    event BondDeposited(address indexed _user, uint indexed _bondID, uint _blockNumber, uint _tokenAmount);
    event RewardDistributed(uint _protocolAmount, uint _blockNumber);
//----END EVENTS----//

}
