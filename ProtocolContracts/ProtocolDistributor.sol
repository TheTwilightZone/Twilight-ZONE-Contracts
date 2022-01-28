pragma solidity ^ 0.8.0;
import "https://github.com/TheTwilightZone/Twilight-ZONE-Contracts/blob/main/DependencyContracts/FullMath.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/math/SafeMath.sol";

import "https://github.com/TheTwilightZone/Twilight-ZONE-Contracts/blob/main/interfaces/IERC20.sol";
import "https://github.com/TheTwilightZone/Twilight-ZONE-Contracts/blob/main/interfaces/IUniswapV2Pair.sol";
import "https://github.com/TheTwilightZone/Twilight-ZONE-Contracts/blob/main/interfaces/IProtocolERC20.sol";
import "https://github.com/TheTwilightZone/Twilight-ZONE-Contracts/blob/main/interfaces/IOhmERC20.sol";
import "https://github.com/TheTwilightZone/Twilight-ZONE-Contracts/blob/main/interfaces/IProtocolCalculatorOracle.sol";


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
    address public protocolLender;                           //Allows Minting Based For Loans
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
        bool isStakedLiquidity;      //Is One Half Of The mainLiquidityPair The Staked Protocol Token?
        address mainLiquidityPair;   //Has To Be Paired with Protocol Token or Price Token, [Duplicate Address if LP Token]
        uint multiplier;             //Out of 1000, 500 = 50%, 250 = 25%
        uint vestingTermInBlocks;    //How Many Blocks Untill Fully Vested
        uint maxDepositCap;          //How Much Protocol Can Be Deposited
        uint totalDeposited;         //How Much Protocol Value Was Deposited
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
        }else if(_ID == 2){
            protocolLender = _contractAddress;
        }
        return false;
    }

    //Changes Token Ownership To New Address
    function newTokenOwner(address _updatedContract) public isManager returns (bool success){
        address protocolToken = IProtocolCalculatorOracle( protocolCalculatorOracle ).protocolToken();
        address stakedToken = IProtocolCalculatorOracle( protocolCalculatorOracle ).stakedProtocolToken();
        require(IProtocolERC20( stakedToken ).owner() == address(this), "A");
        require(IOhmERC20( protocolToken ).owner() == address(this), "A");
        IProtocolERC20( stakedToken ).transferOwnership(_updatedContract);
        IOhmERC20( protocolToken ).transferOwnership(_updatedContract);
        return true;
    }

    //Changes Staking Reward
    function setStakingReward(uint _protocolRewardAmount, uint _everyBlockAmount) public isManager returns (bool success){
        stakingReward.protocolRewardAmount = _protocolRewardAmount;
        stakingReward.everyBlockAmount = _everyBlockAmount;
        return true;
    }

    //Add a New Bond
    function addBond(string calldata _name, address _tokenAddress, bool  _isLiquidityToken, bool  _isProtocolLiquidity, bool _isStakedLiquidity, address _mainLiquidityPair, uint _multiplier, uint _vestingTermInBlocks, uint _maxDepositCap, string calldata _imageURL) public isManager returns (bool success){
        
        //Checks Duplicates
        if(bondList.length > 0){
            require(bondList[bondArchive[_name]].isAuthorized != true, "B");
        }

        //Create New Bond
        Bond memory newBond = Bond({
            name: _name,                                //Bond Name
            tokenAddress: _tokenAddress,                //Purchase Token
            isAuthorized: false,                        //Toggle It Later Baby
            isLiquidityToken: _isLiquidityToken,        //Is this an LP
            isProtocolLiquidity: _isProtocolLiquidity,  //Is it paired with Protocol Token
            isStakedLiquidity: _isStakedLiquidity,
            mainLiquidityPair: _mainLiquidityPair,      //LP Pair for the Token, if isLiquidity then Duplicate
            multiplier: _multiplier,                    //Out of 1000, 500 = %50 increase, 250 = %25 increase
            vestingTermInBlocks: _vestingTermInBlocks,  //Bond Finialization Time
            maxDepositCap: _maxDepositCap,              //How Much Protocol Can Be Deposited
            totalDeposited: 0,                          //Metric For Protocol Deposited
            imageURL: _imageURL                         //For Website Generation
        });

        bondList.push(newBond);                               //Push Bonds to BondsList
        bondArchive[_name] = (bondList.length).sub(1);        //Update Archive
        whichBond[_tokenAddress] = (bondList.length).sub(1);  //Update Bond
        return true;                                          //Ship It
    }

    //Edits Bond Settings [0 = multiplier, 1 = vestingTerm]
    function setBondValue(string calldata _bondName, uint _ID, uint _value) public isManager returns (bool success){
        require(_setBondValue(_bondName, _ID, _value));
        return true;
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
        require(_index < bondList.length, "C");
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
       require(userProfile[_userAddress].isInitialized[_bondName], "D");
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

        uint protocolDelta = bondTerms.finalBondBlock.sub(bondTerms.initialBondBlock);
        uint currentDelta = currentBlock().sub(bondTerms.initialBondBlock);
        
        if(bondTerms.finalBondBlock <= currentBlock()){
            return (bondTerms.totalProtocolAmount.sub(bondTerms.claimedAmount));
        }else{
            return (FullMath.mulDiv(currentDelta, bondTerms.totalProtocolAmount, protocolDelta).sub(bondTerms.claimedAmount));
        }
    }

//----END PLEB FUCNTIONS----//


//====================//
//DO YOU LIKE MY CODE?//
//====================//


//----REWARD MANAGEMENT FUCNTIONS----//

    function lenderMint(uint _tokenAmount, address _user) public isLender returns (bool success){
        require(_mintProtocol(_tokenAmount, _user));
        blockUpdate();
        return true;
    }
    function lenderBurn(uint _tokenAmount) public isLender returns (bool success){
        require(_burnProtocol(_tokenAmount, protocolLender));
        blockUpdate(); 
        return true;
    }

    //Stakes Coin By Burn MintWrapping
    function stake(uint _tokenAmount, address _user) public isDepositor returns (bool success){
        address stakedToken = IProtocolCalculatorOracle( protocolCalculatorOracle ).stakedProtocolToken();          //Gets Staked Token
        uint mintAmount = IProtocolERC20( stakedToken ).protocolToReserve(_tokenAmount);                            //Determines Mint Amount
        require(_burnProtocol(_tokenAmount, assetDepository));                                                      //Burn The Fake Money
        require(_mintStaked(mintAmount, _user));                                                                    //Require Mint Tokens
        emit ProtocolStaked(_user, _tokenAmount);                                                                   //Log That Shit
        blockUpdate();                                                                                              //Routine
        return true;                                                                                                //Ship It
    }

    //Unstakes Coin By Burn MintWrapping
    function unStake(uint _tokenAmount, address _user) public isDepositor returns (bool success){
        address stakedToken = IProtocolCalculatorOracle( protocolCalculatorOracle ).stakedProtocolToken();          //Gets Staked Token
        uint mintAmount = IProtocolERC20( stakedToken ).reserveToProtocol(_tokenAmount);                            //Determines Mint Amount
        require(_burnStaked(_tokenAmount, assetDepository));
        require(_mintProtocol(mintAmount, _user)); 
        emit ProtocolUnStaked(_user, mintAmount);
        blockUpdate();
        return true;
    }

    //Adds a Userbond to Deposits 
    function deposit(address _bondToken, uint _tokenAmount, address _user) public isDepositor returns (bool success){
        uint bondID = whichBond[_bondToken];                                    //Get Bond ID
        string memory bondName = getBondName(bondID);
        Bond memory theBond = getBondByID(bondID);                              //Pull Bond
        require(_bondToken == theBond.tokenAddress, "I");
        require(theBond.isAuthorized == true, "J");  //Require Token Authorization

        //Get Bond Value In Protocol Amount
        uint protocolValue = IProtocolCalculatorOracle( protocolCalculatorOracle ).bondValueInProtocolAmount(_bondToken, _tokenAmount);
        require(theBond.maxDepositCap >= (theBond.maxDepositCap.add(protocolValue)));
        
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

        require(_setBondValue(bondName, 2, (theBond.maxDepositCap.add(protocolValue))));

        emit BondDeposited(_user, bondID, currentBlock(), _tokenAmount);            //Log That Shit
        blockUpdate();                                                              //Routine
        return true;                                                                //Ship It
    }

    //Adjusts Information to Claim Bonds
    function claimBond(string calldata _bondName, address _user) public isDepositor returns (bool success){
        require(claimAmountForBond(_bondName, _user) > 0, "K");
        require(userProfile[_user].isInitialized[_bondName], "L");
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
        blockUpdate();
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
            require(IProtocolERC20( stakedToken ).addToReservoir(mintAmount), "M");
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

    function _mintProtocol(uint _tokenAmount, address _user) private returns (bool success){
        address protocolToken = IProtocolCalculatorOracle( protocolCalculatorOracle ).protocolToken();
        require(address(this) == IOhmERC20( protocolToken ).owner(), "E");
        IOhmERC20( protocolToken ).mint(_user, _tokenAmount); 
        return true;
    }
    function _burnProtocol(uint _tokenAmount, address _from) private returns (bool success){
        address protocolToken = IProtocolCalculatorOracle( protocolCalculatorOracle ).protocolToken();
        require(address(this) == IOhmERC20( protocolToken ).owner(), "E");
        require(IOhmERC20( protocolToken ).allowance(_from, address(this)) >= _tokenAmount, "G");
        IOhmERC20( protocolToken ).burnFrom(_from, _tokenAmount); 
        return true;
    }

    function _mintStaked(uint _tokenAmount, address _user) private returns (bool success){
        address stakedToken = IProtocolCalculatorOracle( protocolCalculatorOracle ).stakedProtocolToken();
        require(address(this) == IProtocolERC20( stakedToken ).owner(), "E");
        require(IProtocolERC20( stakedToken ).mint(_user, _tokenAmount)); 
        return true;
    }
    function _burnStaked(uint _tokenAmount, address _from) private returns (bool success){
        address stakedToken = IProtocolCalculatorOracle( protocolCalculatorOracle ).stakedProtocolToken();
        require(address(this) == IProtocolERC20( stakedToken ).owner(), "E");
        require(IProtocolERC20( stakedToken ).burn(_from, _tokenAmount)); 
        return true;
    }

    function _setBondValue(string memory _bondName, uint _ID, uint _value) private returns (bool success){
        if(_ID == 0){
            bondList[bondArchive[_bondName]].multiplier = _value;
            return true;
        }else if (_ID == 1){
            bondList[bondArchive[_bondName]].vestingTermInBlocks = _value;
            return true;
        }else if (_ID == 2){
            bondList[bondArchive[_bondName]].maxDepositCap = _value;
            return true;
        }
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

    modifier isLender() {
        require(msg.sender == protocolLender);
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
