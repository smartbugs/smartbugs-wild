// compiler: 0.4.19+commit.c4cbbb05.Emscripten.clang
pragma solidity ^0.4.19;

contract owned {
  address public owner;

  function owned() public {
    owner = msg.sender;
  }

  function changeOwner( address newowner ) public onlyOwner {
    owner = newowner;
  }

  function closedown() public onlyOwner { selfdestruct(owner); }

  modifier onlyOwner {
    if (msg.sender != owner) { revert(); }
    _;
  }
}

//
// mutable record of holdings
//
contract PREICO is owned {

  event Holder( address indexed holder, uint amount );

  uint public totalSupply_;

  address[] holders_;

  mapping( address => uint ) public balances_;

  function PREICO() public {}

  function count() public constant returns (uint) { return holders_.length; }

  function holderAt( uint ix ) public constant returns (address) {
    return holders_[ix];
  }

  function balanceOf( address hldr ) public constant returns (uint) {
    return balances_[hldr];
  }

  function add( address holder, uint amount ) onlyOwner public
  {
    require( holder != address(0) );
    require( balances_[holder] + amount > balances_[holder] ); // overflow

    balances_[holder] += amount;
    totalSupply_ += amount;

    if (!isHolder(holder))
    {
      holders_.push( holder );
      Holder( holder, amount );
    }
  }

  function sub( address holder, uint amount ) onlyOwner public
  {
    require( holder != address(0) && balances_[holder] >= amount );

    balances_[holder] -= amount;
    totalSupply_ -= amount;
  }

  function isHolder( address who ) internal constant returns (bool)
  {
    for( uint ii = 0; ii < holders_.length; ii++ )
      if (holders_[ii] == who) return true;

    return false;
  }

}