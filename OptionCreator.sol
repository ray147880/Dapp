pragma solidity ^0.4.24;
/*
   Option Creation. i.e. Sell side
*/


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
            testAMZN_TOKEN_ADDRESS = 0xE8B5425f8DF49aC39b4c1f771c24b25B1176D117;
            testAMZN_TOKEN = testAMZNToken(testAMZN_TOKEN_ADDRESS);
        }
    
    //mapping (address => Option) public options;
    address[] public OptionAccts;
    
    event optionInfo(string contractName, string underlying, uint strikePrice, uint expiration);
    event logAmazonTicker(uint AMZNprice);
    event settlement(uint strikePrice, uint AMZNprice, string descritionS);
    event notsettlement(uint strikePrice, uint AMZNprice, string descritionNS);
    event balanceEvent(uint balance);
    event noBalance(address sender, uint bal, string description);
        
    
    function setOption(address _address, string _contractName, string _underlying, uint _strikePrice, uint _expiration) public{
        //var option = options[_address];
        
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
    
    function checkSettlement() internal{
        if (AMZNprice > strikePrice){

            uint balance = testAMZN_TOKEN.balanceOf(0x4a937e8388ee86953b13e0770e7be4fc6fad1775);
            uint sendAmount = 10;
            if(balance > (sendAmount*(10**18))){
                sendTokens(0x4a937e8388ee86953b13e0770e7be4fc6fad1775, creatorAddr, sendAmount);
                emit settlement(strikePrice, AMZNprice, "Settled: Tokens sent");
            }
            else{
                emit noBalance(0x4a937e8388ee86953b13e0770e7be4fc6fad1775, balance, "Not enough tokens balance to settle");
            }
        }
        else{
            emit notsettlement(strikePrice, AMZNprice, "Not Settled: LastPrice < StrikePrice");
        }
    }
    
    function sendTokens(address fm, address to, uint amount) public{
        testAMZN_TOKEN.transferFrom(fm,to,amount*(10**18));
    }
        
}
