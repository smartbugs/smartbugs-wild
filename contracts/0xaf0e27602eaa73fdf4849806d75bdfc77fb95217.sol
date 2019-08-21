pragma solidity ^0.4.19;

/**
 * CoinCrowd Exchange Rates. More info www.coincrowd.it 
 */


/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
  address public owner;
  
  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  function Ownable() internal {
    owner = msg.sender;
  }

  /**
   * @dev Throws if called by any account other than the owner.
   */
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param newOwner The address to transfer ownership to.
   */
  function transferOwnership(address newOwner) onlyOwner public {
    require(newOwner != address(0));
    OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }
}

/**
 * @title Authorizable
 * @dev The Authorizable contract has authorized addresses, and provides basic authorization control
 * functions, this simplifies the implementation of "multiple user permissions".
 */
contract Authorizable is Ownable {
  mapping(address => bool) public authorized;
  
  event AuthorizationSet(address indexed addressAuthorized, bool indexed authorization);

  /**
   * @dev The Authorizable constructor sets the first `authorized` of the contract to the sender
   * account.
   */ 
  function Authorizable() public {
	authorized[msg.sender] = true;
  }

  /**
   * @dev Throws if called by any account other than the authorized.
   */
  modifier onlyAuthorized() {
    require(authorized[msg.sender]);
    _;
  }

 /**
   * @dev Allows the current owner to set an authorization.
   * @param addressAuthorized The address to change authorization.
   */
  function setAuthorized(address addressAuthorized, bool authorization) onlyOwner public {
    AuthorizationSet(addressAuthorized, authorization);
    authorized[addressAuthorized] = authorization;
  }
  
}

contract CoinCrowdExchangeRates is Ownable, Authorizable {
    uint256 public constant decimals = 18;
    mapping (string  => uint256) rate;
    
    function readRate(string _currency) public view returns (uint256 oneEtherValue) {
        return rate[_currency];
    }
    
    function writeRate(string _currency, uint256 oneEtherValue) onlyAuthorized public returns (bool result) {
        rate[_currency] = oneEtherValue;
        return true;
    }
}