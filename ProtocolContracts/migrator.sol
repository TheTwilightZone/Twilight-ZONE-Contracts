pragma solidity ^ 0.8.0;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/math/SafeMath.sol";

interface IProtocolDistributor {
    function claimAmountForBond(string calldata _bondName, address _user) external view returns (uint);
}

contract migrator{

    using SafeMath for uint;

    address public contractToMigrate;
    mapping(address => User) private userAccount;

    struct User{
        mapping(string => uint) claimedAmount;
    }

    constructor(address _distributor) {
        contractToMigrate = _distributor;
    }


    function getMigratedAmount(string calldata _bondName, address _user) public view returns (uint){

        uint pendingBalance = IProtocolDistributor( contractToMigrate ).claimAmountForBond(_bondName, _user);

        if(userAccount[_user].claimedAmount[_bondName] == pendingBalance){
            return 0;
        }else{
            return pendingBalance.sub(userAccount[_user].claimedAmount[_bondName]);
        }

    }

    function claimMigratedAmount(string calldata _bondName, address _user) public returns (bool){
        userAccount[_user].claimedAmount[_bondName] = IProtocolDistributor( contractToMigrate ).claimAmountForBond(_bondName, _user);
        return true;
    }

}
