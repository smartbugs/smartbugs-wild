/**
 *  @title Base oportunity
 *  @author Clément Lesaege - <clement@lesaege.com>
 *  This code hasn't undertaken bug bounty programs yet.
 */

pragma solidity ^0.5.0;

contract Opportunity {
    
    function () external  payable {
        msg.sender.send(address(this).balance-msg.value);
    }
}