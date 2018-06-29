pragma solidity ^0.4.24;

contract Owned{
    address owner;
    
    function Owned() public{
        owner = msg.sender;
    }
    
    modifier onlyOwner{
        require(msg.sender == owner); //require = if
        _;
    }
}

contract OptionCreator is Owned{
    struct Option{
        string contractName;
        string underlying;
        uint strikePrice;
        uint expiration;
    }
    
    mapping (address => Option) options;
    address[] public OptionAccts;
    
    event optionInfo(string contractName, string underlying, uint strikePrice, uint expiration);
        
    
    function setOption(address _address, string _contractName, string _underlying, uint _strikePrice, uint _expiration) onlyOwner public{
        var option = options[_address];
        
        option.contractName = _contractName;
        option.underlying = _underlying;
        option.strikePrice = _strikePrice;
        option.expiration = _expiration;
        
        
        OptionAccts.push(_address);
        emit optionInfo(_contractName,_underlying,_strikePrice, _expiration);
    }
    
    function getOption() view public returns(address[]){
        return OptionAccts;
    }
    
    function getOption(address _address) view public returns (string, string, uint, uint){
        return(options[_address].contractName, options[_address].underlying, options[_address].strikePrice, options[_address].expiration);
    }
    
    function countOptions() view public returns (uint){
        return OptionAccts.length;
    }
}