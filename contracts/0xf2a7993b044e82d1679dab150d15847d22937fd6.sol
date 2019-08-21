pragma solidity ^0.4.23;

library SafeMath {
    
    function multiplication(uint256 a, uint256 b) internal pure returns (uint256 c) {
        if (a == 0) {
            return 0;
        }
        c = a * b;
        assert(c / a == b);
        return c;
    }

  // integer division of two numbers, truncating the quotient
  function division(uint256 a, uint256 b) internal pure returns (uint256) {
    return a / b;
  }

  // subtracts two numbers , throws an overflow
  function subtraction(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function addition(uint256 a, uint256 b) internal pure returns (uint256 c) {
    c = a + b;
    assert(c >= a);
    return c;
  }
}

/**
ownable contract has an owner address & provides basic authorization control
functions, this simplifies the implementation of the user permission
**/

contract Ownable {
  address public owner;
  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

  // constructor sets the original owner of the contract to the sender account
  constructor() public {
    owner = msg.sender;
  }

  // throws if called by any account other than the owner
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

  /**
  allows the current owner to transfer control of the contract to a new owner
  newOwner: the address to transfer ownership to
  **/
  function transferOwnership(address newOwner) public onlyOwner {
    require(newOwner != address(0));
    emit OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }
}

// ERC20 basic interface
contract ERC20Basic {
  function totalSupply() public view returns (uint256);
  function balanceOf(address who) public view returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}

contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender) public view returns (uint256);
  function transferFrom(address from, address to, uint256 value) public returns (bool);
  function approve(address spender, uint256 value) public returns (bool);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}

// basic version of standard token with no allowances
contract BasicToken is ERC20Basic {
  using SafeMath for uint256;
  mapping(address => uint256) balances;
  uint256 totalSupply_;

  // total numbers of tokens in existence
  function totalSupply() public view returns (uint256) {
    return totalSupply_;
  }

  /**
  _to: address to transfer to
  _value: amoutn to be transferred
  **/
  function transfer(address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));
    require(_value <= balances[msg.sender]);

    balances[msg.sender] = balances[msg.sender].subtraction(_value);
    balances[_to] = balances[_to].addition(_value);
    emit Transfer(msg.sender, _to, _value);
    return true;
  }

  /**
  gets the balance of the specified address
  _owner: address to query the balance of
  return: uint256 representing the amount owned by the passed address
  **/
  function balanceOf(address _owner) public view returns (uint256) {
    return balances[_owner];
  }
}

contract StandardToken is ERC20, BasicToken {
  mapping(address => mapping (address => uint256)) internal allowed;

  /**
  transfers tokens from one address to another
  _from address: address which you want to send tokens from
  _to address: address which you want to transfer to
  _value uint256: amount of tokens to be transferred
  **/
  function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));
    require(_value <= balances[_from]);
    require(_value <= allowed[_from][msg.sender]);

    balances[_from] = balances[_from].subtraction(_value);
    balances[_to] = balances[_to].addition(_value);
    allowed[_from][msg.sender] = allowed[_from][msg.sender].subtraction(_value);

    emit Transfer(_from, _to, _value);
    return true;
  }

  /**
  approve the passed address to spend the specific amount of tokens on behalf of msg.sender
  _spender: address which will spend the funds
  _value: amount of tokens to be spent
  **/
  function approve(address _spender, uint256 _value) public returns (bool) {
    allowed[msg.sender][_spender] = _value;
    emit Approval(msg.sender, _spender, _value);
    return true;
  }

  /**
  to check the amount of tokens that an owner allowed to a _spender
  _owner address: address which owns the funds
  _spender address: address which will spend the funds
  return: specifying the amount of tokens still available for the spender
  **/
  function allowance(address _owner, address _spender) public view returns (uint256) {
    return allowed[_owner][_spender];
  }

  /**
  increase amount of tokens that an owner allowed to a _spender
  _spender: address which will spend the funds
  _addedValue:  amount of tokens to increase the allowance by
  **/
  function increaseApproval(address _spender, uint _addedValue) public returns (bool) {
    allowed[msg.sender][_spender] = allowed[msg.sender][_spender].addition(_addedValue);
    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

  function decreaseApproval(address _spender, uint _subtractedValue) public returns (bool) {
    uint oldValue = allowed[msg.sender][_spender];

    if (_subtractedValue > oldValue) {
      allowed[msg.sender][_spender] = 0;
    } else {
      allowed[msg.sender][_spender] = oldValue.subtraction(_subtractedValue);
    }
    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }
}

contract Configurable {
  uint256 public constant cap = 1000000*10**18;
  uint256 public constant basePrice = 100*10**18; // tokens per 1 ETH
  uint256 public tokensSold = 0;

  uint256 public constant tokenReserve = 1000000*10**18;
  uint256 public remainingTokens = 0;
}

contract CrowdSaleToken is StandardToken, Configurable, Ownable {
  // enum of current crowdSale state
  enum Stages {
    none,
    icoStart,
    icoEnd
  }

  Stages currentStage;

  // constructor of CrowdSaleToken
  constructor() public {
    currentStage = Stages.none;
    balances[owner] = balances[owner].addition(tokenReserve);
    totalSupply_ = totalSupply_.addition(tokenReserve);
    remainingTokens = cap;
    emit Transfer(address(this), owner, tokenReserve);
  }

  // fallback function to send ether too for CrowdSale
  function() public payable {
    require(currentStage == Stages.icoStart);
    require(msg.value > 0);
    require(remainingTokens > 0);

    uint256 weiAmount = msg.value; // calculate tokens to sell
    uint256 tokens = weiAmount.multiplication(basePrice).division(1 ether);
    uint256 returnWei = 0;

    if(tokensSold.addition(tokens) > cap) {
      uint256 newTokens = cap.subtraction(tokensSold);
      uint256 newWei = newTokens.division(basePrice).multiplication(1 ether);
      returnWei = weiAmount.subtraction(newWei);
      weiAmount = newWei;
      tokens = newTokens;
    }

    tokensSold = tokensSold.addition(tokens); // increment raised amount
    remainingTokens = cap.subtraction(tokensSold);

    if(returnWei > 0) {
      msg.sender.transfer(returnWei);
      emit Transfer(address(this), msg.sender, returnWei);
    }

    balances[msg.sender] = balances[msg.sender].addition(tokens);
    emit Transfer(address(this), msg.sender, tokens);
    totalSupply_ = totalSupply_.addition(tokens);
    owner.transfer(weiAmount); // send money to owner
    }

    // starts the ICO
    function startIco() public onlyOwner {
      require(currentStage != Stages.icoEnd);
      currentStage = Stages.icoStart;
    }

    // ends the ICO
    function endIco() internal {
      currentStage = Stages.icoEnd;
      // transfer any remaining tokens
      if(remainingTokens > 0) {
        balances[owner] = balances[owner].addition(remainingTokens);
      }
      // transfer any remaining ETH to the owner
      owner.transfer(address(this).balance);
    }

    // finishes the ICO
    function finalizeIco() public onlyOwner {
      require(currentStage != Stages.icoEnd);
      endIco();
    }
}
// Contract to create the token
contract MementoToken is CrowdSaleToken {
  string public constant name = "Memento";
  string public constant symbol = "MTX";
  uint32 public constant decimals = 18;
}