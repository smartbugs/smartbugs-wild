pragma solidity ^0.4.24;

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

  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}

/**
 * @title Ownable
    * @dev The Ownable contract has an owner address, and provides basic authorization control
       * functions, this simplifies the implementation of "user permissions".
          */
contract Ownable {
  address public owner;


  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
        * account.
             */
  constructor() public {
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
  function transferOwnership(address newOwner) public onlyOwner {
    if (newOwner != address(0)) {
      owner = newOwner;
    }
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

  mapping(address => uint256) balances;

  /**
  * @dev transfer token for a specified address
      * @param _to The address to transfer to.
          * @param _value The amount to be transferred.
              */
  function transfer(address _to, uint256 _value) public returns (bool) {
    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);
    emit Transfer(msg.sender, _to, _value);
    return true;
  }

  /**
  * @dev Gets the balance of the specified address.
      * @param _owner The address to query the the balance of.
          * @return An uint256 representing the amount owned by the passed address.
              */
  function balanceOf(address _owner) constant public returns (uint256 balance) {
    return balances[_owner];
  }

}


/**
 * @title ERC20 interface
    * @dev see https://github.com/ethereum/EIPs/issues/20
       */
contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender) constant public returns (uint256);
  function transferFrom(address from, address to, uint256 value) public returns (bool);
  function approve(address spender, uint256 value) public returns (bool);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract StandardToken is ERC20, BasicToken {

  mapping (address => mapping (address => uint256)) allowed;

  function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
    uint256 _allowance = allowed[_from][msg.sender];

    // Check is not needed because sub(_allowance, _value) will already throw if this condition is not met
    // require (_value <= _allowance);

    balances[_to] = balances[_to].add(_value);
    balances[_from] = balances[_from].sub(_value);
    allowed[_from][msg.sender] = _allowance.sub(_value);
    emit Transfer(_from, _to, _value);
    return true;
  }

  function approve(address _spender, uint256 _value) public returns (bool) {

    require((_value == 0) || (allowed[msg.sender][_spender] == 0));

    allowed[msg.sender][_spender] = _value;
    emit Approval(msg.sender, _spender, _value);
    return true;
  }

  /**
   * @dev Function to check the amount of tokens that an owner allowed to a spender.
        * @param _owner address The address which owns the funds.
             * @param _spender address The address which will spend the funds.
                  * @return A uint256 specifing the amount of tokens still avaible for the spender.
                       */
  function allowance(address _owner, address _spender) constant public returns (uint256 remaining) {
    return allowed[_owner][_spender];
  }

}


contract TreeCoin is StandardToken, Ownable {
    using SafeMath for uint256;

    // Token Info.
    string  public constant name = "Tree Coin";
    string  public constant symbol = "TREE";
    uint8   public constant decimals = 18;

    // Address where funds are collected.
    address public wallet;

    // Event
    event TokenPushed(address indexed buyer, uint256 amount);

    // Modifiers
    modifier uninitialized() {
        require(wallet == 0x0);
        _;
    }

    constructor() public {
    }

    function initialize(address _wallet, uint256 _totalSupply) public onlyOwner uninitialized {
        require(_wallet != 0x0);
        require(_totalSupply > 0);

        wallet = _wallet;
        totalSupply = _totalSupply;

        balances[wallet] = totalSupply;
    }

    function push(address buyer, uint256 amount) public onlyOwner {
        require(balances[wallet] >= amount);

        // Transfer
        balances[wallet] = balances[wallet].sub(amount);
        balances[buyer] = balances[buyer].add(amount);
        emit TokenPushed(buyer, amount);
    }
}