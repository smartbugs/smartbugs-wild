/*
 * DO NOT EDIT! DO NOT EDIT! DO NOT EDIT!
 *
 * This is an automatically generated file. It will be overwritten.
 *
 * For the original source see
 *    '/Users/swaldman/Dropbox/BaseFolders/development-why/gitproj/eth-ping-pong/src/main/solidity/PingPong.sol'
 */

pragma solidity ^0.4.18;





contract PingPong {
  string private last;
  uint private pong_count;

  function PingPong() public {
    last = "";
    pong_count = 0;
  }

  event Pinged( string payload );
  event Ponged( uint indexed count, string payload );

  function ping( string payload ) public {
    last = payload;

    Pinged( payload );
  }

  function pong() public {
    pong_count += 1;

    Ponged( pong_count, last );
  }

  function count() public view returns (uint n) {
    n = pong_count;
  }
}