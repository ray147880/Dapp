pragma solidity ^0.4.24;

import "./AMZNOraclize.sol";

contract OnChainFactory {
    
    address public owner;
    address public contractAddress;
    address public seller;
    AMZNOraclize temp;
    
    event debug(address contractAddr);
    
    constructor() public{
        owner = msg.sender;    
        
    }
    
    function setOnChainOraclize(string _contractName, string _underlying, uint _strikePrice, uint _expiration) {
        seller = msg.sender;
        temp = new AMZNOraclize(msg.sender, _contractName, _underlying, _strikePrice, _expiration);
        
        emit debug(temp);
        temp.onChainCreator(seller, _contractName, _underlying, _strikePrice, _expiration);
        
    }

}
