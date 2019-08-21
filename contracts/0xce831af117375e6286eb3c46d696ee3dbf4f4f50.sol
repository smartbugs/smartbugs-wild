pragma solidity ^0.4.18;

library SafeMath {
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    assert(c / a == b);
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

contract FullERC20 {
  event Transfer(address indexed from, address indexed to, uint256 value);
  event Approval(address indexed owner, address indexed spender, uint256 value);
  
  uint256 public totalSupply;
  uint8 public decimals;

  function balanceOf(address who) public view returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  function allowance(address owner, address spender) public view returns (uint256);
  function transferFrom(address from, address to, uint256 value) public returns (bool);
  function approve(address spender, uint256 value) public returns (bool);
}

contract BalanceHistoryToken is FullERC20 {
  function balanceOfAtBlock(address who, uint256 blockNumber) public view returns (uint256);
}

contract ProfitSharingToken is BalanceHistoryToken {
  using SafeMath for uint256;

  string public name = "Fairgrounds";
  string public symbol = "FGD";
  uint8 public decimals = 2;
  uint256 public constant INITIAL_SUPPLY = 10000000000; // 100M

  struct Snapshot {
    uint192 block; // Still millions of years
    uint64 balance; // > total supply
  }

  mapping(address => Snapshot[]) public snapshots;
  mapping (address => mapping (address => uint256)) internal allowed;

  event Burn(address indexed burner, uint256 value);


  function ProfitSharingToken() public {
      totalSupply = INITIAL_SUPPLY;
      updateBalance(msg.sender, INITIAL_SUPPLY);
  }

  /**
   * @dev Transfer tokens from one address to another
   * @param _from address The address which you want to send tokens from
   * @param _to address The address which you want to transfer to
   * @param _value uint256 the amount of tokens to be transferred
   */
  function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));
    require(_value <= balanceOf(_from));
    require(_value <= allowed[_from][msg.sender]);

    updateBalance(_from, balanceOf(_from).sub(_value));
    updateBalance(_to, balanceOf(_to).add(_value));
    allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
    Transfer(_from, _to, _value);

    return true;
  }

  /**
  * @dev transfer token for a specified address
  * @param _to The address to transfer to.
  * @param _value The amount to be transferred.
  */
  function transfer(address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));
    require(_value <= balanceOf(msg.sender));

    // SafeMath.sub will throw if there is not enough balance.
    updateBalance(msg.sender, balanceOf(msg.sender).sub(_value));
    updateBalance(_to, balanceOf(_to).add(_value));
    Transfer(msg.sender, _to, _value);

    return true;
  }

  function balanceOfAtBlock(address who, uint256 blockNumber) public view returns (uint256) {
    Snapshot[] storage snapshotHistory = snapshots[who];
    if (snapshotHistory.length == 0 || blockNumber < snapshotHistory[0].block) {
      return 0;
    }

    // Check the last transfer value first
    if (blockNumber >= snapshotHistory[snapshotHistory.length-1].block) {
        return snapshotHistory[snapshotHistory.length-1].balance;
    }

    // Search the snapshots until the value is found.
    uint min = 0;
    uint max = snapshotHistory.length-1;
    while (max > min) {
        uint mid = (max + min + 1) / 2;
        if (snapshotHistory[mid].block <= blockNumber) {
            min = mid;
        } else {
            max = mid-1;
        }
    }

    return snapshotHistory[min].balance;
  }

  /// @dev Updates the balance to the provided value
  function updateBalance(address who, uint value) internal {
    snapshots[who].push(Snapshot(uint192(block.number), uint56(value)));
  }

  /**
  * @dev Gets the balance of the specified address.
  * @param _owner The address to query the the balance of.
  * @return An uint256 representing the amount owned by the passed address.
  */
  function balanceOf(address _owner) public view returns (uint256 balance) {
    uint length = snapshots[_owner].length;
    if (length == 0) {
      return 0;
    }

    return snapshots[_owner][length - 1].balance;
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
   * approve should be called when allowed[_spender] == 0. To increment
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   */
  function increaseApproval(address _spender, uint _addedValue) public returns (bool) {
    allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
    Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

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

  /**
  * @dev Burns a specific amount of tokens.
  * @param _value The amount of token to be burned.
  */
  function burn(uint256 _value) public {
    require(_value > 0);
    require(_value <= balanceOf(msg.sender));
    // no need to require value <= totalSupply, since that would imply the
    // sender's balance is greater than the totalSupply, which *should* be an assertion failure

    address burner = msg.sender;
    updateBalance(burner, balanceOf(burner).sub(_value));
    totalSupply = totalSupply.sub(_value);
    Burn(burner, _value);
  }
}