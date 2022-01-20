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

// File: github/TheTwilightZone/Twilight-ZONE-Contracts/ProtocolSmartContracts/ProtocolCalculatorOracle%20(Not%20Flat).sol

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
