pragma solidity ^ 0.8.0;



interface IProtocolDistributor {
    function whichBond(address) external view returns (uint);
    function stakingReward() external view returns (StakingReward memory);
    function getBondName(uint _index) external view returns (string memory bondName);
    function getBondByName(string calldata _bondName) external view returns (Bond memory bond);
    function getBondByID(uint _index) external view returns (Bond memory bond);
    function listBonds() external view returns (Bond[] memory bonds);
    function currentBlock() external view returns (uint blocks);
}


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
