/*
   Getting Amazon price from IEX trading website by Oraclize.it

   This contract sends a Amazon price request to iextrading.com
*/

// v1.0  --  Create Oraclize, Create Option, Buy Option, Oraclize Settlement, Tokens transfer, Tokens locking, OffChain
// v2.1  --  Add new function: Transfer
// v2.2  --  Final Version: Remove all unwanted and debug code

pragma solidity ^0.4.24;
import "./oraclizeAPI_0.5.sol";
import "./OptionCreator.sol";

// Inherit usingOraclize.sol and OptionCreator.sol
contract AMZNOraclize is OptionCreator, usingOraclize{

    mapping(bytes32=>bool) validIds; // verify query id
    
    event logOraclizeQuery(string description);
    event logExercise(string description2);
    event buyOptionfuncDebug(address buyer);
    
    address public owner;
    address public contractAddr;
    address public buyer;
    address public seller;
    
    // Option Contract Creation
    constructor(address creatorAddr, string contractName, string underlying, uint strikePrice, uint expiration)
    OptionCreator(creatorAddr, contractName, underlying, strikePrice, expiration) public{
        owner = msg.sender;
        contractAddr = this;
    }
    
    // On-chain trading approach
    function onChainCreator(address _creatorAddr, string _contractName, string _underlying, uint _strikePrice, uint _expiration) public{
        setOption(_creatorAddr, _contractName, _underlying, _strikePrice, _expiration);
        seller = _creatorAddr;
        sendTokensFrom(seller, contractAddr, 10);   //v2.1
    }
    
    // Off-chain trading approach
    function offChainCreator(string _contractName, string _underlying, uint _strikePrice, uint _expiration, address _buyer, address _seller) public{
        setOption(msg.sender, _contractName, _underlying, _strikePrice, _expiration);
        buyer = _buyer;
        seller = _seller;
        sendTokensFrom(seller, contractAddr, 10);   //v2.1
        update();
    }

    // Buyer buy and match contract
    function buyOption() public{
        buyer = msg.sender;
        emit buyOptionfuncDebug(buyer);
        update();   
    }
    
    // Price return
    function __callback(bytes32 myid, string result) {
        if (!validIds[myid]) revert();
        if (msg.sender != oraclize_cbAddress()) revert();
        
        AMZNprice = parseInt(result,2);
        emit logAmazonTicker(AMZNprice);
        checkSettlement(contractAddr, buyer, seller);
        
        delete validIds[myid];
        
    }
    
    // Query sending
    function update() payable {
        bytes32 queryId;
        if (expiration == 0){
            queryId = oraclize_query("URL", "https://api.iextrading.com/1.0/stock/amzn/price"); // Instant call back
            logOraclizeQuery("Oraclize query was sent, standing by for the answer..");
            validIds[queryId] = true; // verify query id
        }
        else{
            queryId = oraclize_query(expiration*3600, "URL", "https://api.iextrading.com/1.0/stock/amzn/price"); // Callback function will be triggered after "expiration" hour
            logOraclizeQuery("Oraclize query was sent, standing by for the answer..");
            validIds[queryId] = true; // verify query id
        }
    }
} 
                                           
