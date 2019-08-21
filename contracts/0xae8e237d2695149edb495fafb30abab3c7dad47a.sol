/* file: openzeppelin-solidity/contracts/ownership/Ownable.sol */
pragma solidity ^0.4.24;


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

/* eof (openzeppelin-solidity/contracts/ownership/Ownable.sol) */
/* file: openzeppelin-solidity/contracts/token/ERC20/ERC20Basic.sol */
pragma solidity ^0.4.24;


/**
 * @title ERC20Basic
 * @dev Simpler version of ERC20 interface
 * See https://github.com/ethereum/EIPs/issues/179
 */
contract ERC20Basic {
  function totalSupply() public view returns (uint256);
  function balanceOf(address _who) public view returns (uint256);
  function transfer(address _to, uint256 _value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}

/* eof (openzeppelin-solidity/contracts/token/ERC20/ERC20Basic.sol) */
/* file: openzeppelin-solidity/contracts/token/ERC20/ERC20.sol */
pragma solidity ^0.4.24;



/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20 is ERC20Basic {
  function allowance(address _owner, address _spender)
    public view returns (uint256);

  function transferFrom(address _from, address _to, uint256 _value)
    public returns (bool);

  function approve(address _spender, uint256 _value) public returns (bool);
  event Approval(
    address indexed owner,
    address indexed spender,
    uint256 value
  );
}

/* eof (openzeppelin-solidity/contracts/token/ERC20/ERC20.sol) */
/* file: openzeppelin-solidity/contracts/token/ERC20/SafeERC20.sol */
pragma solidity ^0.4.24;



/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure.
 * To use this library you can add a `using SafeERC20 for ERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
  function safeTransfer(
    ERC20Basic _token,
    address _to,
    uint256 _value
  )
    internal
  {
    require(_token.transfer(_to, _value));
  }

  function safeTransferFrom(
    ERC20 _token,
    address _from,
    address _to,
    uint256 _value
  )
    internal
  {
    require(_token.transferFrom(_from, _to, _value));
  }

  function safeApprove(
    ERC20 _token,
    address _spender,
    uint256 _value
  )
    internal
  {
    require(_token.approve(_spender, _value));
  }
}

/* eof (openzeppelin-solidity/contracts/token/ERC20/SafeERC20.sol) */
/* file: openzeppelin-solidity/contracts/ownership/CanReclaimToken.sol */
pragma solidity ^0.4.24;



/**
 * @title Contracts that should be able to recover tokens
 * @author SylTi
 * @dev This allow a contract to recover any ERC20 token received in a contract by transferring the balance to the contract owner.
 * This will prevent any accidental loss of tokens.
 */
contract CanReclaimToken is Ownable {
  using SafeERC20 for ERC20Basic;

  /**
   * @dev Reclaim all ERC20Basic compatible tokens
   * @param _token ERC20Basic The address of the token contract
   */
  function reclaimToken(ERC20Basic _token) external onlyOwner {
    uint256 balance = _token.balanceOf(this);
    _token.safeTransfer(owner, balance);
  }

}

/* eof (openzeppelin-solidity/contracts/ownership/CanReclaimToken.sol) */
/* file: openzeppelin-solidity/contracts/math/SafeMath.sol */
pragma solidity ^0.4.24;


/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {

  /**
  * @dev Multiplies two numbers, throws on overflow.
  */
  function mul(uint256 _a, uint256 _b) internal pure returns (uint256 c) {
    // Gas optimization: this is cheaper than asserting 'a' not being zero, but the
    // benefit is lost if 'b' is also tested.
    // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
    if (_a == 0) {
      return 0;
    }

    c = _a * _b;
    assert(c / _a == _b);
    return c;
  }

  /**
  * @dev Integer division of two numbers, truncating the quotient.
  */
  function div(uint256 _a, uint256 _b) internal pure returns (uint256) {
    // assert(_b > 0); // Solidity automatically throws when dividing by 0
    // uint256 c = _a / _b;
    // assert(_a == _b * c + _a % _b); // There is no case in which this doesn't hold
    return _a / _b;
  }

  /**
  * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
  */
  function sub(uint256 _a, uint256 _b) internal pure returns (uint256) {
    assert(_b <= _a);
    return _a - _b;
  }

  /**
  * @dev Adds two numbers, throws on overflow.
  */
  function add(uint256 _a, uint256 _b) internal pure returns (uint256 c) {
    c = _a + _b;
    assert(c >= _a);
    return c;
  }
}

/* eof (openzeppelin-solidity/contracts/math/SafeMath.sol) */
/* file: openzeppelin-solidity/contracts/token/ERC20/BasicToken.sol */
pragma solidity ^0.4.24;




/**
 * @title Basic token
 * @dev Basic version of StandardToken, with no allowances.
 */
contract BasicToken is ERC20Basic {
  using SafeMath for uint256;

  mapping(address => uint256) internal balances;

  uint256 internal totalSupply_;

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
    require(_value <= balances[msg.sender]);
    require(_to != address(0));

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

/* eof (openzeppelin-solidity/contracts/token/ERC20/BasicToken.sol) */
/* file: openzeppelin-solidity/contracts/token/ERC20/BurnableToken.sol */
pragma solidity ^0.4.24;



/**
 * @title Burnable Token
 * @dev Token that can be irreversibly burned (destroyed).
 */
contract BurnableToken is BasicToken {

  event Burn(address indexed burner, uint256 value);

  /**
   * @dev Burns a specific amount of tokens.
   * @param _value The amount of token to be burned.
   */
  function burn(uint256 _value) public {
    _burn(msg.sender, _value);
  }

  function _burn(address _who, uint256 _value) internal {
    require(_value <= balances[_who]);
    // no need to require value <= totalSupply, since that would imply the
    // sender's balance is greater than the totalSupply, which *should* be an assertion failure

    balances[_who] = balances[_who].sub(_value);
    totalSupply_ = totalSupply_.sub(_value);
    emit Burn(_who, _value);
    emit Transfer(_who, address(0), _value);
  }
}

/* eof (openzeppelin-solidity/contracts/token/ERC20/BurnableToken.sol) */
/* file: openzeppelin-solidity/contracts/token/ERC20/StandardToken.sol */
pragma solidity ^0.4.24;



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
    require(_value <= balances[_from]);
    require(_value <= allowed[_from][msg.sender]);
    require(_to != address(0));

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
    if (_subtractedValue >= oldValue) {
      allowed[msg.sender][_spender] = 0;
    } else {
      allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
    }
    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

}

/* eof (openzeppelin-solidity/contracts/token/ERC20/StandardToken.sol) */
/* file: openzeppelin-solidity/contracts/token/ERC20/MintableToken.sol */
pragma solidity ^0.4.24;



/**
 * @title Mintable token
 * @dev Simple ERC20 Token example, with mintable token creation
 * Based on code by TokenMarketNet: https://github.com/TokenMarketNet/ico/blob/master/contracts/MintableToken.sol
 */
contract MintableToken is StandardToken, Ownable {
  event Mint(address indexed to, uint256 amount);
  event MintFinished();

  bool public mintingFinished = false;


  modifier canMint() {
    require(!mintingFinished);
    _;
  }

  modifier hasMintPermission() {
    require(msg.sender == owner);
    _;
  }

  /**
   * @dev Function to mint tokens
   * @param _to The address that will receive the minted tokens.
   * @param _amount The amount of tokens to mint.
   * @return A boolean that indicates if the operation was successful.
   */
  function mint(
    address _to,
    uint256 _amount
  )
    public
    hasMintPermission
    canMint
    returns (bool)
  {
    totalSupply_ = totalSupply_.add(_amount);
    balances[_to] = balances[_to].add(_amount);
    emit Mint(_to, _amount);
    emit Transfer(address(0), _to, _amount);
    return true;
  }

  /**
   * @dev Function to stop minting new tokens.
   * @return True if the operation was successful.
   */
  function finishMinting() public onlyOwner canMint returns (bool) {
    mintingFinished = true;
    emit MintFinished();
    return true;
  }
}

/* eof (openzeppelin-solidity/contracts/token/ERC20/MintableToken.sol) */
/* file: openzeppelin-solidity/contracts/lifecycle/Pausable.sol */
pragma solidity ^0.4.24;




/**
 * @title Pausable
 * @dev Base contract which allows children to implement an emergency stop mechanism.
 */
contract Pausable is Ownable {
  event Pause();
  event Unpause();

  bool public paused = false;


  /**
   * @dev Modifier to make a function callable only when the contract is not paused.
   */
  modifier whenNotPaused() {
    require(!paused);
    _;
  }

  /**
   * @dev Modifier to make a function callable only when the contract is paused.
   */
  modifier whenPaused() {
    require(paused);
    _;
  }

  /**
   * @dev called by the owner to pause, triggers stopped state
   */
  function pause() public onlyOwner whenNotPaused {
    paused = true;
    emit Pause();
  }

  /**
   * @dev called by the owner to unpause, returns to normal state
   */
  function unpause() public onlyOwner whenPaused {
    paused = false;
    emit Unpause();
  }
}

/* eof (openzeppelin-solidity/contracts/lifecycle/Pausable.sol) */
/* file: openzeppelin-solidity/contracts/token/ERC20/PausableToken.sol */
pragma solidity ^0.4.24;



/**
 * @title Pausable token
 * @dev StandardToken modified with pausable transfers.
 **/
contract PausableToken is StandardToken, Pausable {

  function transfer(
    address _to,
    uint256 _value
  )
    public
    whenNotPaused
    returns (bool)
  {
    return super.transfer(_to, _value);
  }

  function transferFrom(
    address _from,
    address _to,
    uint256 _value
  )
    public
    whenNotPaused
    returns (bool)
  {
    return super.transferFrom(_from, _to, _value);
  }

  function approve(
    address _spender,
    uint256 _value
  )
    public
    whenNotPaused
    returns (bool)
  {
    return super.approve(_spender, _value);
  }

  function increaseApproval(
    address _spender,
    uint _addedValue
  )
    public
    whenNotPaused
    returns (bool success)
  {
    return super.increaseApproval(_spender, _addedValue);
  }

  function decreaseApproval(
    address _spender,
    uint _subtractedValue
  )
    public
    whenNotPaused
    returns (bool success)
  {
    return super.decreaseApproval(_spender, _subtractedValue);
  }
}

/* eof (openzeppelin-solidity/contracts/token/ERC20/PausableToken.sol) */
/* file: ./contracts/ico/SnapshotToken.sol */
/**
 * @title SnapshotToken
 * ERC-20 Compatible Token inspired by the MiniMeToken contract for an auditable history of previous balances
 * @author Validity Labs AG <info@validitylabs.org>
 */
pragma solidity 0.4.24;



contract SnapshotToken is BurnableToken, MintableToken, PausableToken {
    using SafeMath for uint256;

    /** 
    * @dev `Checkpoint` is the structure that attaches a block number to a
    * given value, the block number attached is the one that last changed the value
    */
    struct Checkpoint {
        // `fromBlock` is the block number that the value was generated super.mint(_to, _amount); from
        uint128 fromBlock;
        // `value` is the amount of tokens at a specific block number
        uint128 value;
    }
 
    // Tracks the history of the `totalSupply` of the token
    Checkpoint[] public totalSupplyHistory;

    // `balances` is the map that tracks the balance of each address, in this
    //  contract when the balance changes the block number that the change
    //  occurred is also included in the map
    mapping (address => Checkpoint[]) public balances;

    /**
    * @notice Send `_amount` tokens to `_to` from `msg.sender`
    * @param _to The address of the recipient
    * @param _amount The amount of tokens to be transferred
    * @return Whether the transfer was successful or not
    */
    function transfer(address _to, uint256 _amount) public whenNotPaused returns (bool success) {
        doTransfer(msg.sender, _to, _amount);
        return true;
    }

    /**
    * @notice Send `_amount` tokens to `_to` from `_from` on the condition it
    *  is approved by `_from`
    * @param _from The address holding the tokens being transferred
    * @param _to The address of the recipient
    * @param _amount The amount of tokens to be transferred
    * @return True if the transfer was successful
    */
    function transferFrom(address _from, address _to, uint256 _amount) public whenNotPaused returns (bool success) {
        // The standard ERC 20 transferFrom functionality
        require(allowed[_from][msg.sender] >= _amount, "amount > allowance");
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_amount);

        doTransfer(_from, _to, _amount);
        return true;
    }

    /**
    * @param _owner The address that's balance is being requested
    * @return The balance of `_owner` at the current block
    */
    function balanceOf(address _owner) public view returns (uint256 balance) {
        return balanceOfAt(_owner, block.number);
    }

    /**
    * @notice `msg.sender` approves `_spender` to spend `_amount` tokens on
    *  its behalf. This is a modified version of the ERC20 approve function
    *  to be a little bit safer
    * @param _spender The address of the account able to transfer the tokens
    * @param _amount The amount of tokens to be approved for transfer
    * @return True if the approval was successful
    */
    function approve(address _spender, uint256 _amount) public whenNotPaused returns (bool success) {
        // To change the approve amount you first have to reduce the addresses`
        //  allowance to zero by calling `approve(_spender,0)` if it is not
        //  already 0 to mitigate the race condition described here:
        //  https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
        require((_amount == 0) || (allowed[msg.sender][_spender] == 0), "reset allowance required");

        allowed[msg.sender][_spender] = _amount;
        emit Approval(msg.sender, _spender, _amount);
        return true;
    }

    /**
    * @dev This function makes it easy to get the total number of tokens
    * @return The total number of tokens
    */
    function totalSupply() public view returns (uint256) {
        return totalSupplyAt(block.number);
    }

    /**
    * @dev Queries the balance of `_owner` at a specific `_blockNumber`
    * @param _owner The address from which the balance will be retrieved
    * @param _blockNumber The block number when the balance is queried
    * @return The balance at `_blockNumber`
    */
    function balanceOfAt(address _owner, uint256 _blockNumber) public view returns (uint256) {
        return balanceAt(_owner, _blockNumber, false);
    }

    /**
    * @notice Total amount of tokens at a specific `_blockNumber`.
    * @param _blockNumber The block number when the totalSupply is queried
    * @return The total amount of tokens at `_blockNumber`
    */
    function totalSupplyAt(uint256 _blockNumber) public view returns(uint256) {
        return balanceAt(address(0), _blockNumber, true);
    }

    /**
    * @dev Generates `_amount` tokens that are assigned to `_to`
    * @param _to The address that will be assigned the new tokens
    * @param _amount The quantity of tokens generated
    * @return True if the tokens are generated correctly
    */
    function mint(address _to, uint256 _amount) public hasMintPermission canMint returns (bool) {
        uint256 curTotalSupply = totalSupply();

        uint256 previousBalanceTo = balanceOf(_to);

        updateValueAtNow(totalSupplyHistory, curTotalSupply.add(_amount));
        updateValueAtNow(balances[_to], previousBalanceTo.add(_amount));

        emit Mint(_to, _amount);
        emit Transfer(0, _to, _amount);
        return true;
    }

    /**
    * @notice Burns `_amount` tokens from `msg.sender`
    * @param _amount The quantity of tokens to burn
    * @return True if the tokens are burned correctly
    */
    function burn(uint256 _amount) public {
        uint256 curTotalSupply = totalSupply();
        uint256 previousBalanceFrom = balanceOf(msg.sender);

        updateValueAtNow(totalSupplyHistory, curTotalSupply.sub(_amount));
        updateValueAtNow(balances[msg.sender], previousBalanceFrom.sub(_amount));

        emit Burn(msg.sender, _amount);
        emit Transfer(msg.sender, 0, _amount);
    }

    /*** INTERNAL/PRIVATE ***/
    /**
    * @dev This is the actual transfer function in the token contract, it can
    *      only be called by other functions in this contract.
    * @param _from The address holding the tokens being transferred
    * @param _to The address of the recipient
    * @param _amount The amount of tokens to be transferred
    * @return True if the transfer was successful
    */
    function doTransfer(address _from, address _to, uint256 _amount) internal {
        if (_amount == 0) {
            emit Transfer(_from, _to, _amount);    // Follow the spec to louch the event when transfer 0
            return;
        }

        // Do not allow transfer to 0x0 or the token contract itself
        require((_to != address(0)) && (_to != address(this)), "cannot transfer to 0x0 or self");

        // If the amount being transfered is more than the balance of the
        //  account the transfer throws
        uint256 previousBalanceFrom = balanceOfAt(_from, block.number);
        require(previousBalanceFrom >= _amount, "amount > balance");

        // First update the balance array with the new value for the address
        //  sending the tokens
        updateValueAtNow(balances[_from], previousBalanceFrom.sub(_amount));

        // Then update the balance array with the new value for the address
        //  receiving the tokens
        uint256 previousBalanceTo = balanceOfAt(_to, block.number);
        updateValueAtNow(balances[_to], previousBalanceTo.add(_amount));

        // An event to make the transfer easy to find on the blockchain
        emit Transfer(_from, _to, _amount);
    }

    /**
    * @notice this internal function retrieives the historyical balance of either totalSupply or from an address
    * @param _owner address of a wallet/contract to check
    * @param _blockNumber uint256 block number to retrieve balance at
    * @param _isTotalSupply bool marks if totalSupply or wallet/contract balance lookup
    */
    function balanceAt(address _owner, uint256 _blockNumber, bool _isTotalSupply) internal view returns (uint256) {
        Checkpoint[] memory balanceArray;

        if (_isTotalSupply) {
            balanceArray = totalSupplyHistory;
        } else {
            balanceArray = balances[_owner];
        }

        if ((balanceArray.length == 0) || (balanceArray[0].fromBlock > _blockNumber)) {
            return 0;
        // This will return the expected totalSupply during normal situations
        } else {
            return getValueAt(balanceArray, _blockNumber);
        }
    }

    /**
    * @dev `getValueAt` retrieves the number of tokens at a given block number
    * @param checkpoints The history of values being queried
    * @param _block The block number to retrieve the value at
    * @return The number of tokens being queried
    */
    function getValueAt(Checkpoint[] memory checkpoints, uint256 _block) internal pure returns (uint256) {
        // Shortcut for the actual value
        if (_block >= checkpoints[checkpoints.length.sub(1)].fromBlock) {
            return checkpoints[checkpoints.length.sub(1)].value;
        }

        // Binary search of the value in the array
        uint256 min = 0;
        uint256 max = checkpoints.length.sub(1);
        while (max > min) {
            uint256 mid = (max.add(min).add(1)).div(2);
            if (checkpoints[mid].fromBlock <= _block) {
                min = mid;
            } else {
                max = mid.sub(1);
            }
        }
        return checkpoints[min].value;
    }

    /**
    *@dev `updateValueAtNow` used to update the `balances` map and the
    *  `totalSupplyHistory`
    * @param checkpoints The history of data being updated
    * @param _value The new number of tokens
    */
    function updateValueAtNow(Checkpoint[] storage checkpoints, uint256 _value) internal {
        if ((checkpoints.length == 0) || (checkpoints[checkpoints.length.sub(1)].fromBlock < block.number)) {
            checkpoints.push(Checkpoint(uint128(block.number), uint128(_value)));
        } else {
            checkpoints[checkpoints.length.sub(1)].value = uint128(_value);
        }
    }
}

/* eof (./contracts/ico/SnapshotToken.sol) */
/* file: ./contracts/ico/HbeToken.sol */
/**
 * @title HBE token
 * @author Validity Labs AG <info@validitylabs.org>
 */
pragma solidity 0.4.24;



contract HbeToken is CanReclaimToken, SnapshotToken {
    /* solhint-disable */
    string public constant name = "healthbank Token";
    string public constant symbol = "HBE";
    uint8 public constant decimals = 0;
    /* solhint-enable */

    address public hbeMembership;
    address public hbeMemberVault;

    bool private _lockContracts;

    /** MODIFIERS **/
    modifier onlyHbeMembership() {
        require(msg.sender == hbeMembership, "not a member");
        _;
    }

    /**
     * @dev Constructor of HbeToken that instantiates a new Mintable Pauseable Burnable Token
     */
    constructor() public {
        // token should not be transferrable until after all tokens have been issued
        paused = true;
    }

    /** 
    * @dev allows onlyHbeMembership to release the tokens of an existing member, effective cancelling their membership
    * @param _address address of the ex HBE member
    * @param _currentlyLocked amount of HBE tokens locked owned by member
    */
    function releaseMembershipFee(address _address, uint256 _currentlyLocked) external onlyHbeMembership {
        doTransfer(hbeMemberVault, _address, _currentlyLocked);
    }

    /**
    * @dev updates the member's locked HBE balance to reflect the current HBE Membership price
    * @param _address address of the HBE member
    * @param _currentlyLocked amount of HBE tokens locked owned by member
    * @param _currentMemberFee current membership fee pricing
    * @return bool, bool, uint256 
    */
    function updateMemberBalance(address _address, uint256 _currentlyLocked, uint256 _currentMemberFee) 
        external 
        onlyHbeMembership 
        returns (bool, bool, uint256) {
            uint256 currentBalance = balanceOf(_address);
            uint256 difference;

            // balance due from _address
            if (_currentlyLocked < _currentMemberFee) {
                difference = _currentMemberFee.sub(_currentlyLocked);

                if (difference <= currentBalance) {
                    doTransfer(_address, hbeMemberVault, difference);
                    // mark successful, no refund, N balance chance
                    return(true, false, difference);
                } else {
                    revert("insufficent HBE funds");
                }
            }

            // refund due to _address
            if (_currentlyLocked > _currentMemberFee) {
                difference = _currentlyLocked.sub(_currentMemberFee);
        
                doTransfer(hbeMemberVault, _address, difference);

                // mark successful, yes refund, N balance change
                return(true, true, difference);
            }
            // mark successful, no refund, 0 balance change Eg. already an active member
            return (true, false, 0);
        }

    /**
    * @notice allows onlyOwner to set the address of the HBE membership contracts
    * @dev onlyOwner to set the contracts once. Afterwards, the contracts' addresses are locked and cannot be updated
    * @param _membershipContract address of membership management
    * @param _membershipVault address of the membe HBE token vault
    */
    function setMembershipContracts(address _membershipContract, address _membershipVault) external onlyOwner {
        require(!_lockContracts);
        require(_membershipContract != address(0), "invalid membership address");
        require(_membershipVault != address(0), "invalid vault address");

        _lockContracts = true;

        hbeMembership = _membershipContract;
        hbeMemberVault = _membershipVault;
    }
}

/* eof (./contracts/ico/HbeToken.sol) */