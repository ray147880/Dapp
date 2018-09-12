pragma solidity ^0.4.24;

// v2.2  --  Final Version: Remove all unwanted and debug code

import "./AMZNOraclize.sol";

contract OnChainFactory {
    
    address public owner;
    address public contractAddress;
    address public seller;
    
    AMZNOraclize temp;
    
    event factory(address contractAddr);
    
    constructor() public{
        owner = msg.sender;    
    }
    
    // Create AMZNOraclize.sol
    function setOnChainOraclize(string _contractName, string _underlying, uint _strikePrice, uint _expiration) {
        seller = msg.sender;
        temp = new AMZNOraclize(msg.sender, _contractName, _underlying, _strikePrice, _expiration);
        
        //Get the address of the AMZNOraclize.sol
        emit factory(temp);
        temp.onChainCreator(seller, _contractName, _underlying, _strikePrice, _expiration);
        
    }

}
