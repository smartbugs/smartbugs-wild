pragma solidity ^0.4.19;

contract TradeIO {
    address owner;
    mapping(bytes8 => string) dateToHash;
    
    modifier onlyOwner () {
        require(owner == msg.sender);
        _;
    }
    
    function TradeIO () public {
        owner = msg.sender;
    }
    
    function changeOwner(address _newOwner) public onlyOwner {
        owner = _newOwner;
    }
    
    function saveHash(bytes8 date, string hash) public onlyOwner {
        require(bytes(dateToHash[date]).length == 0);
        dateToHash[date] = hash;
    }
    
    function getHash(bytes8 date) public constant returns (string) {
        require(bytes(dateToHash[date]).length != 0);
        return dateToHash[date];
    }
}