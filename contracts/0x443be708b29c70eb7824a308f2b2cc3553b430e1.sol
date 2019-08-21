pragma solidity ^0.4.18;
/*
  ASTRCoin ICO - Airdrop code
 */

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal pure returns (uint256) {  //was constant
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}



contract Ownable {
  address public owner;

  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

  function Ownable() public {
    owner = msg.sender;
  }


  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

  function transferOwnership(address newOwner) onlyOwner public {
    require(newOwner != address(0));
    OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }

}

contract ERC20 { 
    function transfer(address receiver, uint amount) public ;
    function transferFrom(address sender, address receiver, uint amount) public returns(bool success); // do token.approve on the ICO contract
    function balanceOf(address _owner) constant public returns (uint256 balance);
}

/**
 * Airdrop for ASTRCoin
 */
contract ASTRDrop is Ownable {
  ERC20 public token;  // using the ASTRCoin token - will set an address
  address public ownerAddress;  // deploy owner
  uint8 internal decimals             = 4; // 4 decimal places should be enough in general
  uint256 internal decimalsConversion = 10 ** uint256(decimals);
  uint public   AIRDROP_AMOUNT        = 10 * decimalsConversion;

  function multisend(address[] dests) onlyOwner public returns (uint256) {

    ownerAddress    = ERC20(0x3EFAe2e152F62F5cc12cc0794b816d22d416a721); // 
    token           = ERC20(0x80E7a4d750aDe616Da896C49049B7EdE9e04C191); //  

      uint256 i = 0;
      while (i < dests.length) { // probably want to keep this to only 20 or 30 addresses at a time
        token.transferFrom(ownerAddress, dests[i], AIRDROP_AMOUNT);
         i += 1;
      }
      return(i);
    }

  // Change the airdrop rate
  function setAirdropAmount(uint256 _astrAirdrop) onlyOwner public {
    if( _astrAirdrop > 0 ) {
        AIRDROP_AMOUNT = _astrAirdrop * decimalsConversion;
    }
  }


  // reset the rate to the default
  function resetAirdropAmount() onlyOwner public {
     AIRDROP_AMOUNT = 10 * decimalsConversion;
  }
}