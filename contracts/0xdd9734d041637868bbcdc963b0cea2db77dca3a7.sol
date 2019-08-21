pragma solidity ^0.4.10;

contract FunGame 
{
    address owner;
    modifier OnlyOwner() 
    {
        if (msg.sender == owner) 
        _;
    }
    function FunGame()
    {
        owner = msg.sender;
    }
    function TakeMoney() OnlyOwner
    {
        owner.transfer(this.balance);
    }
    function ChangeOwner(address NewOwner) OnlyOwner 
    {
        owner = NewOwner;
    }
}