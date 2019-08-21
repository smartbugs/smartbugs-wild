pragma solidity ^0.5.1;

interface ELFToken {
  function burnTokens(uint256 _amount) external returns (bool);
  function balanceOf(address who) external view returns (uint256);
}

contract ELFBurner {
    address public token = 0xbf2179859fc6D5BEE9Bf9158632Dc51678a4100e;
    
    function burn() public returns (bool) {
        uint256 balance = ELFToken(token).balanceOf(address(this));
        return ELFToken(token).burnTokens(balance);
    }
}