pragma solidity ^ 0.8.0;

interface IOhmERC20 {
    function burnFrom(address account_, uint256 amount_) external;
    function mint(address account_, uint256 amount_) external;
    function allowance(address owner, address spender) external view returns (uint256);
    function owner() external view returns (address);
     function transferOwnership( address newOwner_ ) external;
}
