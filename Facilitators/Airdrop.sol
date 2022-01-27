pragma solidity ^ 0.8.0;

import "https://github.com/TheTwilightZone/Twilight-ZONE-Contracts/blob/main/interfaces/IERC20.sol";



contract Airdrop{

    address public manager;
    address[] public airdropAddressList;
    uint[] public airdropAmount;


    //Construct This Baby
    constructor() {
        manager = msg.sender;
    }

    function setList(address[] memory _airdropAddressList, uint[] memory _airdropAmount) public isManager returns (bool){
        airdropAddressList = _airdropAddressList;
        airdropAmount = _airdropAmount;
        return true;
    }

    function distribute(address _tokenAddress, uint _amount) public isManager returns(bool) {

        require(IERC20(  _tokenAddress  ).balanceOf(address(this)) >= _amount, "Not Enough Balance");
        require(airdropAddressList.length == airdropAmount.length);

        for (uint i = 0; i < airdropAddressList.length; i++) {
            require(IERC20(  _tokenAddress  ).balanceOf(address(this)) >= airdropAmount[i], "Not Enough Balance While Distributing");
            IERC20( _tokenAddress ).transfer(airdropAddressList[i], airdropAmount[i]);
        }        

        return true;
    }
    
    function withdraw(address _tokenAddress, uint _amount) public isManager returns(bool) {
        require(IERC20(  _tokenAddress  ).balanceOf(address(this)) >= _amount, "Not Enough Balance");
        IERC20( _tokenAddress ).transfer(msg.sender, _amount);
        return true;

    }


    //Managment Function
    function changeManager(address _newManager) public isManager returns (bool success) {
        manager = _newManager;
        return true;
    }


    //Modifiers
    modifier isManager() {
        require(msg.sender == manager);
        _;
    }
    //End Modifiers


}
