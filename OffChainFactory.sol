pragma solidity ^0.4.24;

import "./AMZNOraclize.sol";

contract OffChainFactory {
    
    address public owner;
    address public contractAddress;
    address public seller;
    AMZNOraclize temp;
    
    event debug(address contractAddr);
    
    constructor() public{
        owner = msg.sender;    
        
    }
    
    function setOffChainOraclize(string _contractName, string _underlying, uint _strikePrice, uint _expiration, address _buyer, address _seller) external {
        temp = new AMZNOraclize(msg.sender, _contractName, _underlying, _strikePrice, _expiration);
        emit debug(temp);
        temp.offChainCreator(_contractName, _underlying, _strikePrice, _expiration, _buyer, _seller);
        
    }

}
