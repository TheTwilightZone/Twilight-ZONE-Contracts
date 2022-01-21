// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "https://github.com/TheTwilightZone/Twilight-ZONE-Contracts/blob/main/ProtocolSmartContracts/FullMath.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/math/SafeMath.sol";

contract Twilight is ERC20, Ownable {
    
    constructor() ERC20("Twilight", "TWLT") {}

    using SafeMath for uint;

    uint public protocolReservoir;

    function mint(address to, uint256 _amount) public onlyOwner returns(bool) {
        protocolReservoir = protocolReservoir.add(twilightToProtocol(_amount));
        _mint(to, _amount);
        return true;
    }

    function burn(address to, uint256 _amount) public onlyOwner returns(bool) {
        protocolReservoir = protocolReservoir.sub(twilightToProtocol(_amount));
        _burn(to, _amount);
        return true;
    }

    function addToReservoir(uint _amount) public onlyOwner returns(bool) {
        if(totalSupply() > 0){
            protocolReservoir = protocolReservoir.add(_amount);
            return true;
        }
        return false;
    }

    function protocolToTwilight(uint256 _amount) public view returns(uint){
        uint returnValue;
        if(protocolReservoir == 0){
           returnValue = _amount; 
        }else{
            returnValue = FullMath.mulDiv(_amount, totalSupply(), protocolReservoir);
        }
        return returnValue;
    }

    function twilightToProtocol(uint256 _amount) public view returns(uint){
        uint returnValue;
        if(protocolReservoir == 0){
           returnValue = _amount; 
        }else{
            returnValue = FullMath.mulDiv(_amount, protocolReservoir, totalSupply());
        }
        return returnValue;
    }

}