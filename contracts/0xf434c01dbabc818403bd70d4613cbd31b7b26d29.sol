/*
 * DO NOT EDIT! DO NOT EDIT! DO NOT EDIT!
 *
 * This is an automatically generated file. It will be overwritten.
 *
 * For the original source see
 *    '/Users/testuser/eth-timelock/src/main/solidity/Timelock.sol'
 */

pragma solidity ^0.4.24;

contract Timelock {
  address public owner;
  uint public releaseDate;

  constructor( uint _days, uint _seconds ) public payable {
    require( msg.value > 0, "There's no point in creating an empty Timelock!" );
    owner = msg.sender;
    releaseDate = now + (_days * 1 days) + (_seconds * 1 seconds);
  }

  function withdraw() public {
    require( msg.sender == owner, "Only the owner can withdraw!" );
    require( now > releaseDate, "Cannot withdraw prior to release date!" );
    msg.sender.transfer( address(this).balance );
  }
}