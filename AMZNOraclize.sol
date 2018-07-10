/*
   Getting Amazon price from IEX trading website by Oraclize.it

   This contract sends a Amazon price request to iextrading.com
*/

pragma solidity ^0.4.24;
import "./oraclizeAPI_0.5.sol";
import "./OptionCreator.sol";


contract AMZNOraclize is OptionCreator, usingOraclize{

    
    mapping(bytes32=>bool) validIds; // verify query id
    
    event logOraclizeQuery(string description);
    event logExercise(string description2);
    
    address public owner = msg.sender;
    

    constructor(address creatorAddr, string contractName, string underlying, uint strikePrice, uint expiration)
    OptionCreator(msg.sender, "AMZN2000G8", "AMZN", 150000, (now + 21600)) public{
        update();
    }
    
    function __callback(bytes32 myid, string result) {
        if (!validIds[myid]) revert();
        if (msg.sender != oraclize_cbAddress()) revert();
        
        AMZNprice = parseInt(result,2);
        emit logAmazonTicker(AMZNprice);
        checkSettlement();
        
        delete validIds[myid];
        
    }
    
    function update() payable {
        //bytes32 queryId = oraclize_query(expiration, "URL", "https://api.iextrading.com/1.0/stock/amzn/price");
        bytes32 queryId = oraclize_query("URL", "https://api.iextrading.com/1.0/stock/amzn/price");
        logOraclizeQuery("Oraclize query was sent, standing by for the answer..");
        validIds[queryId] = true; // verify query id
    }
    
} 
                                           
