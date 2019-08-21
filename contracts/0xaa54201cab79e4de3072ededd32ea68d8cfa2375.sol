pragma solidity ^0.4.10;

contract EtherGame 
{
    uint[] a;
    function Test1(uint a) public constant returns(address)
    {
        return msg.sender;
    }
    function Test2(uint a) constant returns(address)
    {
        return msg.sender;
    }
    function Test3(uint b) public constant returns(uint)
    {
        return a.length;
    }
    function Test4(uint b) constant returns(uint)
    {
        return a.length;
    }
    function Test5(uint b) external constant returns(uint)
    {
        return a.length;
    }
    function Test6() constant returns(uint)
    {
        return a.length;
    }
    function Kill(uint a)
    {
        selfdestruct(msg.sender);
    }
}