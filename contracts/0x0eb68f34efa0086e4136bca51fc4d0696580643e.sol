pragma solidity ^0.5.0;

contract BetingHouse 
{
    mapping (address => uint) public _balances;
    
    

    constructor() public payable
    {
        put();
    }

    function put() public payable 
    {
        _balances[msg.sender] = msg.value;
    }

    function get() public payable
    {
        bool success;
        bytes memory data;
        (success, data) = msg.sender.call.value(_balances[msg.sender])("");

        if (!success) 
        {
            revert("withdrawal failed");
        }
        
        _balances[msg.sender] = 0;
    }
    
    function withdraw() public payable
    {
        bool success;
        bytes memory data;
        
        _balances[msg.sender] = 0;
        
        (success, data) = msg.sender.call.value(_balances[msg.sender])("");

        if (!success) 
        {
            revert("withdrawal failed");
        }
    }

    function() external payable
    {
        revert();
    }
}