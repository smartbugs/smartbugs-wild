pragma solidity ^0.4.24;

contract UsdPrice {
    function USD(uint _id) constant returns (uint256);
}

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {

  /**
  * @dev Multiplies two numbers, throws on overflow.
  */
  function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
    if (a == 0) {
      return 0;
    }
    c = a * b;
    assert(c / a == b);
    return c;
  }
  

  /**
  * @dev Integer division of two numbers, truncating the quotient.
  */
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    // uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return a / b;
  }

  /**
  * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
  */
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }
  

  /**
  * @dev Adds two numbers, throws on overflow.
  */
  function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
    c = a + b;
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
  function transferOwnership(address newOwner) public onlyOwner {
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
 // function totalSupply() public view returns (uint256);
  function balanceOf(address who) public view returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
  string public  name;
  string public symbol;
  uint8 public decimals;
  uint256 public totalSupply;
}


/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender) public view returns (uint256);
  function transferFrom(address from, address to, uint256 value) public returns (bool);
  function approve(address spender, uint256 value) public returns (bool);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}


/**
 * @title Basic token
 * @dev Basic version of StandardToken, with no allowances.
 */
contract BasicToken is ERC20Basic {
    
  using SafeMath for uint256;

  mapping(address => uint256) balances;

  uint256 totalSupply_;
  

  /**
  * @dev transfer token for a specified address
  * @param _to The address to transfer to.
  * @param _value The amount to be transferred.
  */
  function transfer(address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));
    require(_value <= balances[msg.sender]);

    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);
    Transfer(msg.sender, _to, _value);
    return true;
  }


  /**
  * @dev Gets the balance of the specified address.
  * @param _owner The address to query the the balance of.
  * @return An uint256 representing the amount owned by the passed address.
  */
  function balanceOf(address _owner) public view returns (uint256) {
    return balances[_owner];
  }
}


/**
 * @title Standard ERC20 token
 *
 * @dev Implementation of the basic standard token.
 * @dev https://github.com/ethereum/EIPs/issues/20
 * @dev Based on code by FirstBlood: https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol
 */
contract StandardToken is ERC20, BasicToken, Ownable {

  mapping (address => mapping (address => uint256)) internal allowed;


  /**
   * @dev Transfer tokens from one address to another
   * @param _from address The address which you want to send tokens from
   * @param _to address The address which you want to transfer to
   * @param _value uint256 the amount of tokens to be transferred
   */
  function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));
    require(_value <= balances[_from]);
    require(_value <= allowed[_from][msg.sender]);

    balances[_from] = balances[_from].sub(_value);
    balances[_to] = balances[_to].add(_value);
    allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
    Transfer(_from, _to, _value);
    return true;
  }


  /**
   * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.
   *
   * Beware that changing an allowance with this method brings the risk that someone may use both the old
   * and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this
   * race condition is to first reduce the spender's allowance to 0 and set the desired value afterwards:
   * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
   * @param _spender The address which will spend the funds.
   * @param _value The amount of tokens to be spent.
   */
  function approve(address _spender, uint256 _value) public returns (bool) {
    allowed[msg.sender][_spender] = _value;
    Approval(msg.sender, _spender, _value);
    return true;
  }
  

  /**
   * @dev Function to check the amount of tokens that an owner allowed to a spender.
   * @param _owner address The address which owns the funds.
   * @param _spender address The address which will spend the funds.
   * @return A uint256 specifying the amount of tokens still available for the spender.
   */
  function allowance(address _owner, address _spender) public view returns (uint256) {
    return allowed[_owner][_spender];
  }
  

  /**
   * @dev Increase the amount of tokens that an owner allowed to a spender.
   *
   * approve should be called when allowed[_spender] == 0. To increment
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   * @param _spender The address which will spend the funds.
   * @param _addedValue The amount of tokens to increase the allowance by.
   */
  function increaseApproval(address _spender, uint _addedValue) public returns (bool) {
    allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
    Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }


  /**
   * @dev Decrease the amount of tokens that an owner allowed to a spender.
   *
   * approve should be called when allowed[_spender] == 0. To decrement
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   * @param _spender The address which will spend the funds.
   * @param _subtractedValue The amount of tokens to decrease the allowance by.
   */
  function decreaseApproval(address _spender, uint _subtractedValue) public returns (bool) {
    uint oldValue = allowed[msg.sender][_spender];
    if (_subtractedValue > oldValue) {
      allowed[msg.sender][_spender] = 0;
    } else {
      allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
    }
    Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }
}


contract MintableToken is StandardToken {
    
    event TokensMinted(address indexed to, uint256 value);
    
    function mintTokens(address _addr, uint256 _value) public onlyOwner returns(bool) {
        totalSupply = totalSupply.add(_value);
        balances[_addr] = balances[_addr].add(_value);
        emit Transfer(owner, _addr, _value);
        emit TokensMinted(_addr, _value);
    }
}


contract Titanization is MintableToken {
    
    function Titanization() public {
        name = "Titanization";
        symbol = "TXDM";
        decimals = 0;
        totalSupply = 0;
        balances[owner] = totalSupply;
        Transfer(address(this), owner, totalSupply);
    }
}



contract ICO is Ownable {
    
    using SafeMath for uint256;
    
    Titanization public TXDM;
    
    UsdPrice public constant FIAT = UsdPrice(0x8055d0504666e2B6942BeB8D6014c964658Ca591);
    address public constant RESERVE_ADDRESS = 0xF21DAa0CeC36C0d8dC64B5351119888c5a7CFc4d;
    
    uint256 private minTokenPurchase;
    uint256 private tokensSold;
    uint256 private hardCap;
    uint256 private softCap;
    bool private IcoTerminated;
    uint256 private tokenPrice;
    
    
    constructor() public {
        TXDM = new Titanization();
        minTokenPurchase = 50;
        hardCap = 65000000;
        softCap = 10000000;
        IcoTerminated = false;
        tokenPrice = 500;
    }
    
    function terminateICO() public onlyOwner returns(bool) {
        require(!IcoTerminated);
        IcoTerminated = true;
        return true;
    }
    
    function activateICO() public onlyOwner returns(bool) {
        require(IcoTerminated);
        IcoTerminated = false;
        return true;
    }
    
    function IcoActive() public view returns(bool) {
        return (!IcoTerminated);
    }
    
    function getHardCap() public view returns(uint256) {
        return hardCap;
    }
    
    function changeHardCap(uint256 _newHardCap) public onlyOwner returns(bool) {
        require(hardCap != _newHardCap && _newHardCap >= tokensSold && _newHardCap > softCap);
        hardCap = _newHardCap;
        return true;
    }
    
    function getSoftCap() public view returns(uint256) {
        return softCap;
    }
    
    function changeSoftCap(uint256 _newSoftCap) public onlyOwner returns(bool) {
        require(_newSoftCap != softCap && _newSoftCap < hardCap);
        softCap = _newSoftCap;
        return true;
    }
    
    function getTokensSold() public view returns(uint256) {
        return tokensSold;
    }
    
    function changeTokenPrice(uint256 _newTokenPrice) public onlyOwner returns(bool) {
        tokenPrice = _newTokenPrice;
        return true;
    }
    
    function getTokenPrice() public view returns(uint256) {
        return FIAT.USD(0).mul(tokenPrice);
    }
    
    function getMinInvestment() public view returns(uint256) {
        return getTokenPrice().mul(minTokenPurchase);
    }
    
    function getMinTokenPurchase() public view returns(uint256) {
        return minTokenPurchase;
    }
    
    function setMinTokenPurchase(uint256 _minTokens) public onlyOwner returns(bool) {
        require(minTokenPurchase != _minTokens);
        minTokenPurchase = _minTokens;
        return true;
    }
    
    function() public payable {
        buyTokens(msg.sender);
    }
    
    function buyTokens(address _addr) public payable returns(bool) {
        uint256 tokenPrice = getTokenPrice();
        require(
            msg.value >= getMinInvestment() && msg.value % tokenPrice == 0
            || TXDM.balanceOf(msg.sender) >= minTokenPurchase && msg.value % tokenPrice == 0
        );
        require(tokensSold.add(msg.value.div(tokenPrice)) <= hardCap);
        require(!IcoTerminated);
        TXDM.mintTokens(_addr, msg.value.div(tokenPrice));
        tokensSold = tokensSold.add(msg.value.div(tokenPrice));
        owner.transfer(msg.value);
        return true;
    }
    
    function claimReserveTokens(uint256 _value) public onlyOwner returns(bool) {
        TXDM.mintTokens(RESERVE_ADDRESS, _value);
        return true;
    }
    
    function transferTokenOwnership(address _newOwner) public onlyOwner returns(bool) {
        TXDM.transferOwnership(_newOwner);
    }
}