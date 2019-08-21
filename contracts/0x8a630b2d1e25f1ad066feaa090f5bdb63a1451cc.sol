pragma solidity ^0.4.10;

contract EtherGame 
{
    uint[] a;
    function Test1() public returns(address)
    {
        return msg.sender;
    }
    function Test2() returns(address)
    {
        return msg.sender;
    }
    function Test3() public returns(uint)
    {
        return a.length;
    }
    function Test4() returns(uint)
    {
        return a.length;
    }
    function Kill()
    {
        selfdestruct(msg.sender);
    }
}