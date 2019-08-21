pragma solidity ^0.4.10;

contract Fortune {
  string[] private fortunes;

  function Fortune( string initialFortune ) {
    addFortune( initialFortune );
  }

  function addFortune( string fortune ) {
    fortunes.push( fortune );
  }

  function drawFortune() constant returns ( string fortune ) {
    fortune = fortunes[ shittyRandom() % fortunes.length ];
  }

  function shittyRandom() private constant returns ( uint number ) {
    number = uint( block.blockhash( block.number - 1 ) );  	   
  }
}