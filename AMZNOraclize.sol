/*
   Getting Amazon price from IEX trading website by Oraclize.it

   This contract sends a Amazon price request to iextrading.com
*/

// v1.0  --  Create Oraclize, Create Option, Buy Option, Oraclize Settlement, Tokens transfer, Tokens locking, OffChain
// v2.1  --  Add new function: Transfer

pragma solidity ^0.4.24;
import "./oraclizeAPI_0.5.sol";
import "./OptionCreator.sol";


contract AMZNOraclize is OptionCreator, usingOraclize{

    
    mapping(bytes32=>bool) validIds; // verify query id
    
    event logOraclizeQuery(string description);
    event logExercise(string description2);
    event buyOptionfuncDebug(address buyer);
    
    address public owner;
    address public contractAddr;
    address public buyer;
    address public seller;
    
    constructor(address creatorAddr, string contractName, string underlying, uint strikePrice, uint expiration)
    OptionCreator(creatorAddr, contractName, underlying, strikePrice, expiration) public{
        owner = msg.sender;
        contractAddr = this;
    }
    
    
    function setOptionCreator(string _contractName, string _underlying, uint _strikePrice, uint _expiration) public{
        setOption(msg.sender, _contractName, _underlying, _strikePrice, _expiration);
        seller = msg.sender;
        sendTokensFrom(seller, contractAddr, 10);   //v2.1
    }
    
    function onChainCreator(address _creatorAddr, string _contractName, string _underlying, uint _strikePrice, uint _expiration) public{
        setOption(_creatorAddr, _contractName, _underlying, _strikePrice, _expiration);
        seller = _creatorAddr;
        sendTokensFrom(seller, contractAddr, 10);   //v2.1
    }
    
    function offChainCreator(string _contractName, string _underlying, uint _strikePrice, uint _expiration, address _buyer, address _seller) public{
        setOption(msg.sender, _contractName, _underlying, _strikePrice, _expiration);
        buyer = _buyer;
        seller = _seller;
        sendTokensFrom(seller, contractAddr, 10);   //v2.1
        update();
    }

    
    function buyOption() public{
        buyer = msg.sender;
        emit buyOptionfuncDebug(buyer);
        update();   
    }
    
    function __callback(bytes32 myid, string result) {
        if (!validIds[myid]) revert();
        if (msg.sender != oraclize_cbAddress()) revert();
        
        AMZNprice = parseInt(result,2);
        emit logAmazonTicker(AMZNprice);
        checkSettlement(contractAddr, buyer, seller);
        
        delete validIds[myid];
        
    }
    
    function update() payable {
        //bytes32 queryId = oraclize_query(expiration, "URL", "https://api.iextrading.com/1.0/stock/amzn/price"); // Callback function will be triggered after "expiration" seconds
        bytes32 queryId = oraclize_query("URL", "https://api.iextrading.com/1.0/stock/amzn/price"); // Instant call back
        logOraclizeQuery("Oraclize query was sent, standing by for the answer..");
        validIds[queryId] = true; // verify query id
    }
    
} 
                                           
