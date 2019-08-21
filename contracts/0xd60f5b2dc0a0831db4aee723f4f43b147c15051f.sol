pragma solidity ^0.4.11;
 
library SafeMath {
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

 function div(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}

contract Ownable {
  address public owner;


  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  function Ownable() public {
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
 * @title ERC20Basic
 * @dev Simpler version of ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/179
 */
contract ERC20Basic {
  uint256 public totalSupply;
  function balanceOf(address who) constant public returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}

/**
 * @title Basic token
 * @dev Basic version of StandardToken, with no allowances.
 */
contract BasicToken is ERC20Basic {
  using SafeMath for uint256;

  mapping(address => uint256) tokenBalances;

  /**
  * @dev transfer token for a specified address
  * @param _to The address to transfer to.
  * @param _value The amount to be transferred.
  */
  function transfer(address _to, uint256 _value) public returns (bool) {
    require(tokenBalances[msg.sender]>=_value);
    tokenBalances[msg.sender] = tokenBalances[msg.sender].sub(_value);
    tokenBalances[_to] = tokenBalances[_to].add(_value);
    Transfer(msg.sender, _to, _value);
    return true;
  }

  /**
  * @dev Gets the balance of the specified address.
  * @param _owner The address to query the the balance of.
  * @return An uint256 representing the amount owned by the passed address.
  */
  function balanceOf(address _owner) constant public returns (uint256 balance) {
    return tokenBalances[_owner];
  }
}
//TODO: Change the name of the token
contract RevolutionCoin is BasicToken,Ownable {

   using SafeMath for uint256;
   
   string public constant name = "R-evolutioncoin";
   string public constant symbol = "RVL";
   uint256 public constant decimals = 18;
   uint256 public buyPrice = 222222222222222;   // per token the price is 2.2222*10^-4 eth, this price is equivalent in wei
   address public ethStore = 0xDd64EF0c8a41d8a17F09ce2279D79b3397184A10;
   uint256 public constant INITIAL_SUPPLY = 100000000;
   event Debug(string message, address addr, uint256 number);
   
   /**
   * @dev Contructor that gives msg.sender all of existing tokens.
   */
   //TODO: Change the name of the constructor
    function RevolutionCoin() public {
        owner = msg.sender;
        totalSupply = INITIAL_SUPPLY;
        tokenBalances[owner] = INITIAL_SUPPLY * (10 ** uint256(decimals));   //Since we divided the token into 10^18 parts
    }

    function buy() payable public returns (uint amount) {
        amount = msg.value.div(buyPrice);                    // calculates the amount
        amount = amount * (10 ** uint256(decimals));
        require(tokenBalances[owner] >= amount);               // checks if it has enough to sell
        tokenBalances[msg.sender] = tokenBalances[msg.sender].add(amount);                  // adds the amount to buyer's balance
        tokenBalances[owner] = tokenBalances[owner].sub(amount);                        // subtracts amount from seller's balance
        Transfer(owner, msg.sender, amount);               // execute an event reflecting the change
        ethStore.transfer(msg.value);                       //send the eth to the address where eth should be collected
        return amount;                                    // ends function and returns
    }
    function getTokenBalance() public view returns (uint256 balance) {
        balance = tokenBalances[msg.sender].div (10**decimals); // show token balance in full tokens not part
    }
    function changeBuyPrice(uint newPrice) public onlyOwner {
        buyPrice = newPrice;
    }
}