pragma solidity ^0.4.24;


/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {

  /**
  * @dev Multiplies two numbers, throws on overflow.
  */
  function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
    // Gas optimization: this is cheaper than asserting 'a' not being zero, but the
    // benefit is lost if 'b' is also tested.
    // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
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
 * @title ERC20Basic
 * @dev Simpler version of ERC20 interface
 * See https://github.com/ethereum/EIPs/issues/179
 */
contract ERC20Basic {
  function totalSupply() public view returns (uint256);
  function balanceOf(address who) public view returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}



contract Time {
    /**
    * @dev Current time getter
    * @return Current time in seconds
    */
    function _currentTime() internal view returns (uint256) {
        return block.timestamp;
    }
}


/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
  address public owner;


  event OwnershipRenounced(address indexed previousOwner);
  event OwnershipTransferred(
    address indexed previousOwner,
    address indexed newOwner
  );


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
   * @dev Allows the current owner to relinquish control of the contract.
   * @notice Renouncing to ownership will leave the contract without an owner.
   * It will not be possible to call the functions with the `onlyOwner`
   * modifier anymore.
   */
  function renounceOwnership() public onlyOwner {
    emit OwnershipRenounced(owner);
    owner = address(0);
  }

  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param _newOwner The address to transfer ownership to.
   */
  function transferOwnership(address _newOwner) public onlyOwner {
    _transferOwnership(_newOwner);
  }

  /**
   * @dev Transfers control of the contract to a newOwner.
   * @param _newOwner The address to transfer ownership to.
   */
  function _transferOwnership(address _newOwner) internal {
    require(_newOwner != address(0));
    emit OwnershipTransferred(owner, _newOwner);
    owner = _newOwner;
  }
}










/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender)
    public view returns (uint256);

  function transferFrom(address from, address to, uint256 value)
    public returns (bool);

  function approve(address spender, uint256 value) public returns (bool);
  event Approval(
    address indexed owner,
    address indexed spender,
    uint256 value
  );
}



/**
 * @title DetailedERC20 token
 * @dev The decimals are only for visualization purposes.
 * All the operations are done using the smallest and indivisible token unit,
 * just as on Ethereum all the operations are done in wei.
 */
contract DetailedERC20 is ERC20 {
  string public name;
  string public symbol;
  uint8 public decimals;

  constructor(string _name, string _symbol, uint8 _decimals) public {
    name = _name;
    symbol = _symbol;
    decimals = _decimals;
  }
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
  * @dev Total number of tokens in existence
  */
  function totalSupply() public view returns (uint256) {
    return totalSupply_;
  }

  /**
  * @dev Transfer token for a specified address
  * @param _to The address to transfer to.
  * @param _value The amount to be transferred.
  */
  function transfer(address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));
    require(_value <= balances[msg.sender]);

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
  function balanceOf(address _owner) public view returns (uint256) {
    return balances[_owner];
  }

}




/**
 * @title Standard ERC20 token
 *
 * @dev Implementation of the basic standard token.
 * https://github.com/ethereum/EIPs/issues/20
 * Based on code by FirstBlood: https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol
 */
contract StandardToken is ERC20, BasicToken {

  mapping (address => mapping (address => uint256)) internal allowed;


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
    public
    returns (bool)
  {
    require(_to != address(0));
    require(_value <= balances[_from]);
    require(_value <= allowed[_from][msg.sender]);

    balances[_from] = balances[_from].sub(_value);
    balances[_to] = balances[_to].add(_value);
    allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
    emit Transfer(_from, _to, _value);
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
  function approve(address _spender, uint256 _value) public returns (bool) {
    allowed[msg.sender][_spender] = _value;
    emit Approval(msg.sender, _spender, _value);
    return true;
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
    public
    view
    returns (uint256)
  {
    return allowed[_owner][_spender];
  }

  /**
   * @dev Increase the amount of tokens that an owner allowed to a spender.
   * approve should be called when allowed[_spender] == 0. To increment
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
    public
    returns (bool)
  {
    allowed[msg.sender][_spender] = (
      allowed[msg.sender][_spender].add(_addedValue));
    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

  /**
   * @dev Decrease the amount of tokens that an owner allowed to a spender.
   * approve should be called when allowed[_spender] == 0. To decrement
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
    public
    returns (bool)
  {
    uint256 oldValue = allowed[msg.sender][_spender];
    if (_subtractedValue > oldValue) {
      allowed[msg.sender][_spender] = 0;
    } else {
      allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
    }
    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

}






contract CosquareToken is Time, StandardToken, DetailedERC20, Ownable {
    using SafeMath for uint256;

    /**
    * Describes locked balance
    * @param expires Time when tokens will be unlocked
    * @param value Amount of the tokens is locked
    */
    struct LockedBalance {
        uint256 expires;
        uint256 value;
    }

    // locked balances specified be the address
    mapping(address => LockedBalance[]) public lockedBalances;

    // sale wallet (65%)
    address public saleWallet;
    // reserve wallet (15%)
    address public reserveWallet;
    // team wallet (15%)
    address public teamWallet;
    // strategic wallet (5%)
    address public strategicWallet;

    // end point, after which all tokens will be unlocked
    uint256 public lockEndpoint;

    /**
    * Event for lock logging
    * @param who The address on which part of the tokens is locked
    * @param value Amount of the tokens is locked
    * @param expires Time when tokens will be unlocked
    */
    event LockLog(address indexed who, uint256 value, uint256 expires);

    /**
    * @param _saleWallet Sale wallet
    * @param _reserveWallet Reserve wallet
    * @param _teamWallet Team wallet
    * @param _strategicWallet Strategic wallet
    * @param _lockEndpoint End point, after which all tokens will be unlocked
    */
    constructor(address _saleWallet, address _reserveWallet, address _teamWallet, address _strategicWallet, uint256 _lockEndpoint) 
      DetailedERC20("cosquare", "CSQ", 18) public {
        require(_lockEndpoint > 0, "Invalid global lock end date.");
        lockEndpoint = _lockEndpoint;

        _configureWallet(_saleWallet, 65000000000000000000000000000); // 6.5e+28
        saleWallet = _saleWallet;
        _configureWallet(_reserveWallet, 15000000000000000000000000000); // 1.5e+28
        reserveWallet = _reserveWallet;
        _configureWallet(_teamWallet, 15000000000000000000000000000); // 1.5e+28
        teamWallet = _teamWallet;
        _configureWallet(_strategicWallet, 5000000000000000000000000000); // 0.5e+28
        strategicWallet = _strategicWallet;
    }

    /**
    * @dev Setting the initial value of the tokens to the wallet
    * @param _wallet Address to be set up
    * @param _amount The number of tokens to be assigned to this address
    */
    function _configureWallet(address _wallet, uint256 _amount) private {
        require(_wallet != address(0), "Invalid wallet address.");

        totalSupply_ = totalSupply_.add(_amount);
        balances[_wallet] = _amount;
        emit Transfer(address(0), _wallet, _amount);
    }

    /**
    * @dev Throws if the address does not have enough not locked balance
    * @param _who The address to transfer from
    * @param _value The amount to be transferred
    */
    modifier notLocked(address _who, uint256 _value) {
        uint256 time = _currentTime();

        if (lockEndpoint > time) {
            uint256 index = 0;
            uint256 locked = 0;
            while (index < lockedBalances[_who].length) {
                if (lockedBalances[_who][index].expires > time) {
                    locked = locked.add(lockedBalances[_who][index].value);
                }

                index++;
            }

            require(_value <= balances[_who].sub(locked), "Not enough unlocked tokens");
        }        
        _;
    }

    /**
    * @dev Overridden to check whether enough not locked balance
    * @param _from The address which you want to send tokens from
    * @param _to The address which you want to transfer to
    * @param _value The amount of tokens to be transferred
    */
    function transferFrom(address _from, address _to, uint256 _value) public notLocked(_from, _value) returns (bool) {
        return super.transferFrom(_from, _to, _value);
    }

    /**
    * @dev Overridden to check whether enough not locked balance
    * @param _to The address to transfer to
    * @param _value The amount to be transferred
    */
    function transfer(address _to, uint256 _value) public notLocked(msg.sender, _value) returns (bool) {
        return super.transfer(_to, _value);
    }

    /**
    * @dev Gets the locked balance of the specified address
    * @param _owner The address to query the locked balance of
    * @param _expires Time of expiration of the lock (If equals to 0 - returns all locked tokens at this moment)
    * @return An uint256 representing the amount of locked balance by the passed address
    */
    function lockedBalanceOf(address _owner, uint256 _expires) external view returns (uint256) {
        uint256 time = _currentTime();
        uint256 index = 0;
        uint256 locked = 0;

        if (lockEndpoint > time) {       
            while (index < lockedBalances[_owner].length) {
                if (_expires > 0) {
                    if (lockedBalances[_owner][index].expires == _expires) {
                        locked = locked.add(lockedBalances[_owner][index].value);
                    }
                } else {
                    if (lockedBalances[_owner][index].expires >= time) {
                        locked = locked.add(lockedBalances[_owner][index].value);
                    }
                }

                index++;
            }
        }

        return locked;
    }

    /**
    * @dev Locks part of the balance for the specified address and for a certain period (3 periods expected)
    * @param _who The address of which will be locked part of the balance
    * @param _value The amount of tokens to be locked
    * @param _expires Time of expiration of the lock
    */
    function lock(address _who, uint256 _value, uint256 _expires) public onlyOwner {
        uint256 time = _currentTime();
        require(_who != address(0) && _value <= balances[_who] && _expires > time, "Invalid lock configuration.");

        uint256 index = 0;
        bool exist = false;
        while (index < lockedBalances[_who].length) {
            if (lockedBalances[_who][index].expires == _expires) {
                exist = true;
                break;
            }

            index++;
        }

        if (exist) {
            lockedBalances[_who][index].value = lockedBalances[_who][index].value.add(_value);
        } else {
            lockedBalances[_who].push(LockedBalance({
                expires: _expires,
                value: _value
            }));
        }

        emit LockLog(_who, _value, _expires);
    }
}