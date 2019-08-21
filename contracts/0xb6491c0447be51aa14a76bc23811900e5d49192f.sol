/*************************************************
*                                                *
*   AirDrop Dapp                                 *
*   Developed by Phenom.Team "www.phenom.team"   *
*                                                *
*************************************************/

pragma solidity ^0.4.24;

/**
 * @title SafeMath
 * @dev Math operations with safety checks that revert on error
 */
library SafeMath {

  /**
  * @dev Multiplies two numbers, reverts on overflow.
  */
  function mul(uint256 _a, uint256 _b) internal pure returns (uint256) {
    // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
    // benefit is lost if 'b' is also tested.
    // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
    if (_a == 0) {
      return 0;
    }

    uint256 c = _a * _b;
    require(c / _a == _b);

    return c;
  }

  /**
  * @dev Integer division of two numbers truncating the quotient, reverts on division by zero.
  */
  function div(uint256 _a, uint256 _b) internal pure returns (uint256) {
    require(_b > 0); // Solidity only automatically asserts when dividing by 0
    uint256 c = _a / _b;
    // assert(_a == _b * c + _a % _b); // There is no case in which this doesn't hold

    return c;
  }

  /**
  * @dev Subtracts two numbers, reverts on overflow (i.e. if subtrahend is greater than minuend).
  */
  function sub(uint256 _a, uint256 _b) internal pure returns (uint256) {
    require(_b <= _a);
    uint256 c = _a - _b;

    return c;
  }

  /**
  * @dev Adds two numbers, reverts on overflow.
  */
  function add(uint256 _a, uint256 _b) internal pure returns (uint256) {
    uint256 c = _a + _b;
    require(c >= _a);

    return c;
  }

  /**
  * @dev Divides two numbers and returns the remainder (unsigned integer modulo),
  * reverts when dividing by zero.
  */
  function mod(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b != 0);
    
    return a % b;
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
    owner = tx.origin;
  }

  /**
   * @dev Throws if called by any account other than the owner.
   */
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }
}

/**
 * @title ERC20
 * @dev Standard of ERC20.
 */
contract ERC20 is Ownable {
  using SafeMath for uint256;

  uint public totalSupply;
  string public name;
  string public symbol;
  uint8 public decimals;
  bool public transferable;

  mapping(address => uint) balances;
  mapping(address => mapping (address => uint)) allowed;

  /**
  *   @dev Get balance of tokens holder
  *   @param _holder        holder's address
  *   @return               balance of investor
  */
  function balanceOf(address _holder) public view returns (uint) {
       return balances[_holder];
  }

 /**
  *   @dev Send coins
  *   throws on any error rather then return a false flag to minimize
  *   user errors
  *   @param _to           target address
  *   @param _amount       transfer amount
  *
  *   @return true if the transfer was successful 
  */
  function transfer(address _to, uint _amount) public returns (bool) {
      require(_to != address(0) && _to != address(this));
      if (!transferable) {
        require(msg.sender == owner);
      }
      balances[msg.sender] = balances[msg.sender].sub(_amount);  
      balances[_to] = balances[_to].add(_amount);
      emit Transfer(msg.sender, _to, _amount);
      return true;
  }

 /**
  *   @dev An account/contract attempts to get the coins
  *   throws on any error rather then return a false flag to minimize user errors
  *
  *   @param _from         source address
  *   @param _to           target address
  *   @param _amount       transfer amount
  *
  *   @return true if the transfer was successful
  */
  function transferFrom(address _from, address _to, uint _amount) public returns (bool) {
      require(_to != address(0) && _to != address(this));
      balances[_from] = balances[_from].sub(_amount);
      allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_amount);
      balances[_to] = balances[_to].add(_amount);
      emit Transfer(_from, _to, _amount);
      return true;
   }

 /**
  *   @dev Allows another account/contract to spend some tokens on its behalf
  *   throws on any error rather then return a false flag to minimize user errors
  *
  *   also, to minimize the risk of the approve/transferFrom attack vector
  *   approve has to be called twice in 2 separate transactions - once to
  *   change the allowance to 0 and secondly to change it to the new allowance
  *   value
  *
  *   @param _spender      approved address
  *   @param _amount       allowance amount
  *
  *   @return true if the approval was successful
  */
  function approve(address _spender, uint _amount) public returns (bool) {
      require((_amount == 0) || (allowed[msg.sender][_spender] == 0));
      allowed[msg.sender][_spender] = _amount;
      emit Approval(msg.sender, _spender, _amount);
      return true;
  }

 /**
  *   @dev Function to check the amount of tokens that an owner allowed to a spender.
  *
  *   @param _owner        the address which owns the funds
  *   @param _spender      the address which will spend the funds
  *
  *   @return              the amount of tokens still avaible for the spender
  */
  function allowance(address _owner, address _spender) public view returns (uint) {
      return allowed[_owner][_spender];
  }

  /**
  *   @dev Function make token transferable.
  *
  *   @return the status of issue
  */
  function unfreeze() public onlyOwner {
      transferable = true;
      emit Unfreezed(now);
  }

  event Transfer(address indexed _from, address indexed _to, uint _value);
  event Approval(address indexed _owner, address indexed _spender, uint _value);
  event Unfreezed(uint indexed _timestamp);
}

/**
 * @title StandardToken
 * @dev Token without the ability to release new ones.
 */
contract StandardToken is ERC20 {
  using SafeMath for uint256;

  /**
  * @dev The Standard token constructor determines the total supply of tokens.
  */
  constructor(string _name, string _symbol, uint8 _decimals, uint _totalSupply, bool _transferable) public {   
      name = _name;
      symbol = _symbol;
      decimals = _decimals;
      totalSupply = _totalSupply;
      balances[tx.origin] = _totalSupply;
      transferable = _transferable;
      emit Transfer(address(0), tx.origin, _totalSupply);
  }

  /**
  * @dev Sends the tokens to a list of addresses.
  */
  function airdrop(address[] _addresses, uint256[] _values) public onlyOwner returns (bool) {
      require(_addresses.length == _values.length);
      for (uint256 i = 0; i < _addresses.length; i++) {
          require(transfer(_addresses[i], _values[i]));
      }        
      return true;
  }
}

/**
 * @title MintableToken
 * @dev Token with the ability to release new ones.
 */
contract MintableToken is Ownable, ERC20 {
  using SafeMath for uint256;

  bool public mintingFinished = false;

 /**
  * @dev The Standard token constructor determines the total supply of tokens.
  */
  constructor(string _name, string _symbol, uint8 _decimals, bool _transferable) public {
    name = _name;
    symbol = _symbol;
    decimals = _decimals;
    transferable = _transferable;
  }

  modifier canMint() {
    require(!mintingFinished);
    _;
  }

 /**
  *   @dev Function to mint tokens
  *   @param _holder       beneficiary address the tokens will be issued to
  *   @param _value        number of tokens to issue
  */
  function mintTokens(address _holder, uint _value) public canMint onlyOwner returns (bool) {
     require(_value > 0);
     require(_holder != address(0));
     balances[_holder] = balances[_holder].add(_value);
     totalSupply = totalSupply.add(_value);
     emit Transfer(address(0), _holder, _value);
     return true;
  }

  /**
  * @dev Sends the tokens to a list of addresses.
  */
  function airdrop(address[] _addresses, uint256[] _values) public onlyOwner returns (bool) {
      require(_addresses.length == _values.length);
      for (uint256 i = 0; i < _addresses.length; i++) {
          require(mintTokens(_addresses[i], _values[i]));
      }
      return true;
  }
 
  /**
  *   @dev Function finishes minting tokens.
  *
  *   @return the status of issue
  */
  function finishMinting() public onlyOwner {
      mintingFinished = true;
      emit MintFinished(now);
  }

  event MintFinished(uint indexed _timestamp);
}

/**
 * @title TokenCreator
 * @dev Create new token ERC20.
 */
contract TokenCreator {
  using SafeMath for uint256;

  mapping(address => address[]) public mintableTokens;
  mapping(address => address[]) public standardTokens;
  mapping(address => uint256) public amountMintTokens;
  mapping(address => uint256) public amountStandTokens;
  
  /**
  *   @dev Function create standard token.
  *
  *   @return the address of new token.
  */
  function createStandardToken(string _name, string _symbol, uint8 _decimals, uint _totalSupply, bool _transferable) public returns (address) {
    address token = new StandardToken(_name, _symbol, _decimals, _totalSupply, _transferable);
    standardTokens[msg.sender].push(token);
    amountStandTokens[msg.sender]++;
    emit TokenCreated(msg.sender, token);
    return token;
  }

  /**
  *   @dev Function create mintable token.
  *
  *   @return the address of new token.
  */
  function createMintableToken(string _name, string _symbol, uint8 _decimals, bool _transferable) public returns (address) {
    address token = new MintableToken(_name, _symbol, _decimals, _transferable);
    mintableTokens[msg.sender].push(token);
    amountMintTokens[msg.sender]++;
    emit TokenCreated(msg.sender, token);
    return token;
  }

  event TokenCreated(address indexed _creator, address indexed _token);
}