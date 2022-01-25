pragma solidity ^ 0.8.0;

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
