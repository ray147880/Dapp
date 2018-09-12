pragma solidity ^0.4.24;
/*
   Option Creation. i.e. Sell side
*/

// v2.1  --  Add new function: sendTokens and approveTokens, Modify sendTokens -> sendTokensFrom, 
//           Use transfer instead of TransferFrom in settlement
// v2.2  --  Final Version: Remove all unwanted and debug code

import "./testAMZN.sol";

contract OptionCreator{
    address public creatorAddr;
    string public contractName;
    string public underlying;
    uint public strikePrice;
    uint public expiration;
    
    uint public AMZNprice;
    address public testAMZN_TOKEN_ADDRESS;
    testAMZNToken testAMZN_TOKEN;
    
    // Variable Initialization
    constructor(
        address _creatorAddr,
        string _contractName,
        string _underlying,
        uint _strikePrice,
        uint _expiration
        )public{
            creatorAddr = _creatorAddr;
            contractName = _contractName;
            underlying = _underlying;
            strikePrice = _strikePrice;
            expiration = _expiration;
            testAMZN_TOKEN_ADDRESS = 0x1d3907b4674f1aeb51c079a5ce42cabda160077a;
            testAMZN_TOKEN = testAMZNToken(testAMZN_TOKEN_ADDRESS);
        }
    
    address[] public OptionAccts;
    
    // Event Subscriptions
    event optionInfo(string contractName, string underlying, uint strikePrice, uint expiration);
    event logAmazonTicker(uint AMZNprice);
    event exercise(uint strikePrice, uint AMZNprice, string descritionS);
    event notExercise(uint strikePrice, uint AMZNprice, string descritionNS);
    event balanceEvent(uint balance);
    event noBalance(address sender, uint bal, string description);
        
    // Set option with option information
    function setOption(address _address, string _contractName, string _underlying, uint _strikePrice, uint _expiration) public{
        creatorAddr = _address;
        contractName = _contractName;
        underlying = _underlying;
        strikePrice = _strikePrice;
        expiration = _expiration;
    
        OptionAccts.push(_address);
        emit optionInfo(_contractName,_underlying,_strikePrice, _expiration);
    }
    
    function getOption() view public returns(address[]){
        return OptionAccts;
    }
    
    function getOption(address _address) view public returns (string, string, uint, uint){
        return(contractName, underlying, strikePrice, expiration);
    }
    
    function countOptions() view public returns (uint){
        return OptionAccts.length;
    }
    
    // Settlement process Initiation
    function checkSettlement(address contractAddr, address buyer, address seller) internal{
        uint sendAmount = 10;
        uint balance = testAMZN_TOKEN.balanceOf(contractAddr);

        if (AMZNprice >= strikePrice){
            if(balance >= (sendAmount*(10**18))){
                sendTokens(buyer, sendAmount);  // v2.1
                emit exercise(strikePrice, AMZNprice, "Settled: Tokens sent");
            }
            else{
                emit noBalance(contractAddr, balance, "Not enough tokens balance to settle");
            }
        }
        else{
            if(balance >= (sendAmount*(10**18))){
                sendTokens(seller, sendAmount); // v2.1
                emit notExercise(strikePrice, AMZNprice, "Not Settled.Refunded Tokens. : LastPrice < StrikePrice");
            }
            
            else{
                emit noBalance(contractAddr, balance, "Not enough tokens balance to refund");
            }
        }
    }
    
    // v2.1 Tokens transferring mechanism
    function sendTokensFrom(address fm, address to, uint amount) public{
        testAMZN_TOKEN.transferFrom(fm, to,amount*(10**18));
    }
    
    function sendTokens(address to, uint amount) public{
        testAMZN_TOKEN.transfer(to,amount*(10**18));
    }
    
    function approveTokens(address spender, uint amount) public{
        testAMZN_TOKEN.approve(spender,amount*(10**18));
    }
        
}