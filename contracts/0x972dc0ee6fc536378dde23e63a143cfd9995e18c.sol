pragma solidity ^0.4.24;

/*
https://donutchain.io/

  WARNING

  All users are forbidden to interact with this contract 
  if this contract is inconflict with user’s local regulations and laws.  

  DonutChain - is a game designed to explore human behavior 
  via  token redistribution through open source smart contract code and pre-defined rules.
  
  This system is for internal use only 
  and all could be lost  by sending anything to this contract address.
  
  No one can change anything once the contract has been deployed.
*/

/**
 * @title Standard ERC20 token
 *
 * @dev Implementation of the basic standard token.
 * https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20.md
 * Originally based on code by FirstBlood: https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol
 */
contract ERC20 {

  using SafeMath for uint256;

  event Transfer(
    address indexed from,
    address indexed to,
    uint256 value
  );

  event Approval(
    address indexed owner,
    address indexed spender,
    uint256 value
  );
  
  mapping (address => uint256) private balances_;

  mapping (address => mapping (address => uint256)) private allowed_;

  uint256 private totalSupply_;

  /**
  * @dev Total number of tokens in existence
  */
  function totalSupply() public view returns (uint256) {
    return totalSupply_;
  }

  /**
  * @dev Gets the balance of the specified address.
  * @param _owner The address to query the the balance of.
  * @return An uint256 representing the amount owned by the passed address.
  */
  function balanceOf(address _owner) public view returns (uint256) {
    return balances_[_owner];
  }

  /**
   * @dev Function to check the amount of tokens that an owner allowed to a spender.
   * @param _owner address The address which owns the funds.
   * @param _spender address The address which will spend the funds.
   * @return A uint256 specifying the amount of tokens still available for the spender.
   */
  function allowance(
    address _owner,
    address _spender
   )
    external
    view
    returns (uint256)
  {
    return allowed_[_owner][_spender];
  }

  /**
  * @dev Transfer token for a specified address
  * @param _to The address to transfer to.
  * @param _value The amount to be transferred.
  */
  function transfer(address _to, uint256 _value) external returns (bool) {
    require(_value <= balances_[msg.sender]);
    require(_to != address(0));

    balances_[msg.sender] = balances_[msg.sender].sub(_value);
    balances_[_to] = balances_[_to].add(_value);
    emit Transfer(msg.sender, _to, _value);
    return true;
  }

  /**
   * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.
   * Beware that changing an allowance with this method brings the risk that someone may use both the old
   * and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this
   * race condition is to first reduce the spender's allowance to 0 and set the desired value afterwards:
   * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
   * @param _spender The address which will spend the funds.
   * @param _value The amount of tokens to be spent.
   */
  function approve(address _spender, uint256 _value) external returns (bool) {
    allowed_[msg.sender][_spender] = _value;
    emit Approval(msg.sender, _spender, _value);
    return true;
  }

  /**
   * @dev Transfer tokens from one address to another
   * @param _from address The address which you want to send tokens from
   * @param _to address The address which you want to transfer to
   * @param _value uint256 the amount of tokens to be transferred
   */
  function transferFrom(
    address _from,
    address _to,
    uint256 _value
  )
    external
    returns (bool)
  {
    require(_value <= balances_[_from]);
    require(_value <= allowed_[_from][msg.sender]);
    require(_to != address(0));

    balances_[_from] = balances_[_from].sub(_value);
    balances_[_to] = balances_[_to].add(_value);
    allowed_[_from][msg.sender] = allowed_[_from][msg.sender].sub(_value);
    emit Transfer(_from, _to, _value);
    return true;
  }

  /**
   * @dev Increase the amount of tokens that an owner allowed to a spender.
   * approve should be called when allowed_[_spender] == 0. To increment
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   * @param _spender The address which will spend the funds.
   * @param _addedValue The amount of tokens to increase the allowance by.
   */
  function increaseApproval(
    address _spender,
    uint256 _addedValue
  )
    external
    returns (bool)
  {
    allowed_[msg.sender][_spender] = (
      allowed_[msg.sender][_spender].add(_addedValue));
    emit Approval(msg.sender, _spender, allowed_[msg.sender][_spender]);
    return true;
  }

  /**
   * @dev Decrease the amount of tokens that an owner allowed to a spender.
   * approve should be called when allowed_[_spender] == 0. To decrement
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   * @param _spender The address which will spend the funds.
   * @param _subtractedValue The amount of tokens to decrease the allowance by.
   */
  function decreaseApproval(
    address _spender,
    uint256 _subtractedValue
  )
    external
    returns (bool)
  {
    uint256 oldValue = allowed_[msg.sender][_spender];
    if (_subtractedValue >= oldValue) {
      allowed_[msg.sender][_spender] = 0;
    } else {
      allowed_[msg.sender][_spender] = oldValue.sub(_subtractedValue);
    }
    emit Approval(msg.sender, _spender, allowed_[msg.sender][_spender]);
    return true;
  }

  /**
   * @dev Internal function that mints an amount of the token and assigns it to
   * an account. This encapsulates the modification of balances such that the
   * proper events are emitted.
   * @param _account The account that will receive the created tokens.
   * @param _amount The amount that will be created.
   */
  function _mint(address _account, uint256 _amount) internal {
    require(_account != 0);
    totalSupply_ = totalSupply_.add(_amount);
    balances_[_account] = balances_[_account].add(_amount);
    emit Transfer(address(0), _account, _amount);
  }

  /**
   * @dev Internal function that burns an amount of the token of a given
   * account.
   * @param _account The account whose tokens will be burnt.
   * @param _amount The amount that will be burnt.
   */
  function _burn(address _account, uint256 _amount) internal {
    require(_account != 0);
    require(_amount <= balances_[_account]);

    totalSupply_ = totalSupply_.sub(_amount);
    balances_[_account] = balances_[_account].sub(_amount);
    emit Transfer(_account, address(0), _amount);
  }

}

contract DonutChain is ERC20 {
    
  event TokensBurned(address indexed burner, uint256 value);
  event Mint(address indexed to, uint256 amount);
  event MintFinished();
  uint8  public constant decimals = 0;
  string public constant name = "donutchain.io token #1";
  string public constant symbol = "DNT1";
  bool public flag = true;
  uint256 public endBlock;
  uint256 public mainGift;
  uint256 public amount = 0.001 ether;
  uint256 public increment = 0.000001 ether;
  address public donee;

  constructor() public {
    endBlock = block.number + 24 * 60 * 4;
  }
  function() external payable {
    require(flag);
    flag = false;
    if (endBlock > block.number) {
      require(msg.value >= amount);
      uint256 tokenAmount =  msg.value / amount;
      uint256 change = msg.value - tokenAmount * amount;
        if (change > 0 )
          msg.sender.transfer(change);
        if (msg.data.length == 20) {
          address refAddress = bToAddress(bytes(msg.data));
          refAddress.transfer(msg.value / 10); // 10%
        } 
          mainGift += msg.value / 5; // 20%
          donee = msg.sender;
          endBlock = block.number + 24 * 60 * 4; // ~24h
          amount += increment * tokenAmount;
          _mint(msg.sender, tokenAmount);
          emit Mint(msg.sender, tokenAmount);
          flag = true;
        } else {
          msg.sender.transfer(msg.value);
          emit MintFinished();
          selfdestruct(donee);
        }
  }
  /**  
   * @dev Function to check the amount of ether per a token.
   * @return A uint256 specifying the amount of ether per a token available for gift.
   */

  function etherPerToken() public view returns (uint256) {
    uint256 sideETH = address(this).balance - mainGift;
    if (totalSupply() == 0)
        return 0;
    return sideETH / totalSupply();
  }

  /**  
   * @dev Function to calculate size of a gift for token owner.
   * @param _who address The address of a token owner.
   * @return A uint256 specifying the amount of gift in ether.
   */
  function giftAmount(address _who) external view returns (uint256) {
    return etherPerToken() * balanceOf(_who);
  }
  
  /**
  * @dev Transfer gift from contract to tokens owner.
  * @param _amount The amount of gift.
  */
  function transferGift(uint256 _amount) external {
    require(balanceOf(msg.sender) >= _amount);
    uint256 ept = etherPerToken();
    _burn(msg.sender, _amount);
    emit TokensBurned(msg.sender, _amount);
    msg.sender.transfer(_amount * ept);
  }

  function bToAddress(
    bytes _bytesData
  )
    internal
    pure
    returns(address _refAddress) 
  {
    assembly {
      _refAddress := mload(add(_bytesData,0x14))
    }
    return _refAddress;
  }

}

/**
 * @title SafeMath
 * @dev Math operations with safety checks that revert on error
 */
library SafeMath {

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
}