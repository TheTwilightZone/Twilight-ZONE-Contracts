
// File: https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/math/SafeMath.sol


// OpenZeppelin Contracts v4.4.1 (utils/math/SafeMath.sol)

pragma solidity ^0.8.0;

// CAUTION
// This version of SafeMath should only be used with Solidity 0.8 or later,
// because it relies on the compiler's built in overflow checks.

/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SafeMath` is generally not needed starting with Solidity 0.8, since the compiler
 * now has built in overflow checking.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the substraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator.
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {trySub}.
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting with custom message when dividing by zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryMod}.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}

// File: https://github.com/Uniswap/v3-core/blob/main/contracts/libraries/FullMath.sol


pragma solidity >=0.4.0;

/// @title Contains 512-bit math functions
/// @notice Facilitates multiplication and division that can have overflow of an intermediate value without any loss of precision
/// @dev Handles "phantom overflow" i.e., allows multiplication and division where an intermediate value overflows 256 bits
library FullMath {
    /// @notice Calculates floor(a×b÷denominator) with full precision. Throws if result overflows a uint256 or denominator == 0
    /// @param a The multiplicand
    /// @param b The multiplier
    /// @param denominator The divisor
    /// @return result The 256-bit result
    /// @dev Credit to Remco Bloemen under MIT license https://xn--2-umb.com/21/muldiv
    function mulDiv(
        uint256 a,
        uint256 b,
        uint256 denominator
    ) internal pure returns (uint256 result) {
        // 512-bit multiply [prod1 prod0] = a * b
        // Compute the product mod 2**256 and mod 2**256 - 1
        // then use the Chinese Remainder Theorem to reconstruct
        // the 512 bit result. The result is stored in two 256
        // variables such that product = prod1 * 2**256 + prod0
        uint256 prod0; // Least significant 256 bits of the product
        uint256 prod1; // Most significant 256 bits of the product
        assembly {
            let mm := mulmod(a, b, not(0))
            prod0 := mul(a, b)
            prod1 := sub(sub(mm, prod0), lt(mm, prod0))
        }

        // Handle non-overflow cases, 256 by 256 division
        if (prod1 == 0) {
            require(denominator > 0);
            assembly {
                result := div(prod0, denominator)
            }
            return result;
        }

        // Make sure the result is less than 2**256.
        // Also prevents denominator == 0
        require(denominator > prod1);

        ///////////////////////////////////////////////
        // 512 by 256 division.
        ///////////////////////////////////////////////

        // Make division exact by subtracting the remainder from [prod1 prod0]
        // Compute remainder using mulmod
        uint256 remainder;
        assembly {
            remainder := mulmod(a, b, denominator)
        }
        // Subtract 256 bit number from 512 bit number
        assembly {
            prod1 := sub(prod1, gt(remainder, prod0))
            prod0 := sub(prod0, remainder)
        }

        // Factor powers of two out of denominator
        // Compute largest power of two divisor of denominator.
        // Always >= 1.
        uint256 twos = denominator & (~denominator + 1);
        // Divide denominator by power of two
        assembly {
            denominator := div(denominator, twos)
        }

        // Divide [prod1 prod0] by the factors of two
        assembly {
            prod0 := div(prod0, twos)
        }
        // Shift in bits from prod1 into prod0. For this we need
        // to flip `twos` such that it is 2**256 / twos.
        // If twos is zero, then it becomes one
        assembly {
            twos := add(div(sub(0, twos), twos), 1)
        }
        prod0 |= prod1 * twos;

        // Invert denominator mod 2**256
        // Now that denominator is an odd number, it has an inverse
        // modulo 2**256 such that denominator * inv = 1 mod 2**256.
        // Compute the inverse by starting with a seed that is correct
        // correct for four bits. That is, denominator * inv = 1 mod 2**4
        uint256 inv = (3 * denominator) ^ 2;
        // Now use Newton-Raphson iteration to improve the precision.
        // Thanks to Hensel's lifting lemma, this also works in modular
        // arithmetic, doubling the correct bits in each step.
        inv *= 2 - denominator * inv; // inverse mod 2**8
        inv *= 2 - denominator * inv; // inverse mod 2**16
        inv *= 2 - denominator * inv; // inverse mod 2**32
        inv *= 2 - denominator * inv; // inverse mod 2**64
        inv *= 2 - denominator * inv; // inverse mod 2**128
        inv *= 2 - denominator * inv; // inverse mod 2**256

        // Because the division is now exact we can divide by multiplying
        // with the modular inverse of denominator. This will give us the
        // correct result modulo 2**256. Since the precoditions guarantee
        // that the outcome is less than 2**256, this is the final result.
        // We don't need to compute the high bits of the result and prod1
        // is no longer required.
        result = prod0 * inv;
        return result;
    }

    /// @notice Calculates ceil(a×b÷denominator) with full precision. Throws if result overflows a uint256 or denominator == 0
    /// @param a The multiplicand
    /// @param b The multiplier
    /// @param denominator The divisor
    /// @return result The 256-bit result
    function mulDivRoundingUp(
        uint256 a,
        uint256 b,
        uint256 denominator
    ) internal pure returns (uint256 result) {
        result = mulDiv(a, b, denominator);
        if (mulmod(a, b, denominator) > 0) {
            require(result < type(uint256).max);
            result++;
        }
    }
}

// File: github/TheTwilightZone/Twilight-ZONE-Contracts/ProtocolSmartContracts/ProtocolDistributor.sol

pragma solidity ^ 0.8.0;



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
