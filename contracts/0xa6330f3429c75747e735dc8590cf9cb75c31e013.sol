pragma solidity ^0.4.24;

// File: openzeppelin-solidity/contracts/token/ERC20/ERC20Basic.sol

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

// File: openzeppelin-solidity/contracts/math/SafeMath.sol

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

// File: openzeppelin-solidity/contracts/token/ERC20/BasicToken.sol

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

// File: openzeppelin-solidity/contracts/token/ERC20/ERC20.sol

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

// File: openzeppelin-solidity/contracts/token/ERC20/StandardToken.sol

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

// File: openzeppelin-solidity/contracts/ownership/Ownable.sol

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

// File: openzeppelin-solidity/contracts/token/ERC20/MintableToken.sol

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

// File: openzeppelin-solidity/contracts/lifecycle/Pausable.sol

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

// File: openzeppelin-solidity/contracts/token/ERC20/PausableToken.sol

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

// File: openzeppelin-solidity/contracts/token/ERC20/DetailedERC20.sol

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

// File: openzeppelin-solidity/contracts/token/ERC20/BurnableToken.sol

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

// File: openzeppelin-solidity/contracts/token/ERC20/StandardBurnableToken.sol

/**
 * @title Standard Burnable Token
 * @dev Adds burnFrom method to ERC20 implementations
 */
contract StandardBurnableToken is BurnableToken, StandardToken {

  /**
   * @dev Burns a specific amount of tokens from the target address and decrements allowance
   * @param _from address The address which you want to send tokens from
   * @param _value uint256 The amount of token to be burned
   */
  function burnFrom(address _from, uint256 _value) public {
    require(_value <= allowed[_from][msg.sender]);
    // Should https://github.com/OpenZeppelin/zeppelin-solidity/issues/707 be accepted,
    // this function needs to emit an event with the updated approval.
    allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
    _burn(_from, _value);
  }
}

// File: contracts/RemeCoin.sol

/**
 * @title RemeCoin
 * @author https://bit-sentinel.com
 */
contract RemeCoin is MintableToken, PausableToken, StandardBurnableToken, DetailedERC20 {
    event EnabledFees();
    event DisabledFees();
    event FeeChanged(uint256 fee);
    event FeeThresholdChanged(uint256 feeThreshold);
    event FeeBeneficiaryChanged(address indexed feeBeneficiary);
    event EnabledWhitelist();
    event DisabledWhitelist();
    event ChangedWhitelistManager(address indexed whitelistManager);
    event AddedRecipientToWhitelist(address indexed recipient);
    event AddedSenderToWhitelist(address indexed sender);
    event RemovedRecipientFromWhitelist(address indexed recipient);
    event RemovedSenderFromWhitelist(address indexed sender);

    // If the token whitelist feature is enabled or not.
    bool public whitelist = true;

    // Address of the whitelist manager.
    address public whitelistManager;

    // Addresses that can receive tokens.
    mapping(address => bool) public whitelistedRecipients;

    // Addresses that can send tokens.
    mapping(address => bool) public whitelistedSenders;

    // Fee taken from transfers.
    uint256 public fee;

    // If the fee mechanism is enabled.
    bool public feesEnabled;

    // Address of the fee beneficiary.
    address public feeBeneficiary;

    // Value from which the fee mechanism applies.
    uint256 public feeThreshold;

    /**
     * @dev Initialize the RemeCoin and transfer the initialBalance to the
     *      initialAccount.
     * @param _initialAccount The account that will receive the initial balance.
     * @param _initialBalance The initial balance of tokens.
     * @param _fee uint256 The fee percentage to be applied. Has 4 decimals.
     * @param _feeBeneficiary address The beneficiary of the fees.
     * @param _feeThreshold uint256 The amount of when the transfers fees will be applied.
     */
    constructor(
        address _initialAccount,
        uint256 _initialBalance,
        uint256 _fee,
        address _feeBeneficiary,
        uint256 _feeThreshold
    )
        DetailedERC20("REME Coin", "REME", 18)
        public
    {
        require(_fee != uint256(0) && _fee <= uint256(100 * (10 ** 4)));
        require(_feeBeneficiary != address(0));
        require(_feeThreshold != uint256(0));

        fee = _fee;
        feeBeneficiary = _feeBeneficiary;
        feeThreshold = _feeThreshold;

        totalSupply_ = _initialBalance;
        balances[_initialAccount] = _initialBalance;
        emit Transfer(address(0), _initialAccount, _initialBalance);
    }

    /**
     * @dev Throws if called by any account other than the whitelistManager.
     */
    modifier onlyWhitelistManager() {
        require(msg.sender == whitelistManager);
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract has transfer fees enabled.
     */
    modifier whenFeesEnabled() {
        require(feesEnabled);
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract has transfer fees disabled.
     */
    modifier whenFeesDisabled() {
        require(!feesEnabled);
        _;
    }

    /**
     * @dev Enable the whitelist feature.
     */
    function enableWhitelist() external onlyOwner {
        require(
            !whitelist,
            'Whitelist is already enabled'
        );

        whitelist = true;
        emit EnabledWhitelist();
    }
    
    /**
     * @dev Enable the whitelist feature.
     */
    function disableWhitelist() external onlyOwner {
        require(
            whitelist,
            'Whitelist is already disabled'
        );

        whitelist = false;
        emit DisabledWhitelist();
    }

    /**
     * @dev Change the whitelist manager address.
     * @param _whitelistManager address
     */
    function changeWhitelistManager(address _whitelistManager) external onlyOwner
    {
        require(_whitelistManager != address(0));

        whitelistManager = _whitelistManager;

        emit ChangedWhitelistManager(whitelistManager);
    }

    /**
     * @dev Add recipient to the whitelist.
     * @param _recipient address of the recipient
     */
    function addRecipientToWhitelist(address _recipient) external onlyWhitelistManager
    {
        require(
            !whitelistedRecipients[_recipient],
            'Recipient already whitelisted'
        );

        whitelistedRecipients[_recipient] = true;

        emit AddedRecipientToWhitelist(_recipient);
    }

    /**
     * @dev Add sender to the whitelist.
     * @param _sender address of the sender
     */
    function addSenderToWhitelist(address _sender) external onlyWhitelistManager
    {
        require(
            !whitelistedSenders[_sender],
            'Sender already whitelisted'
        );

        whitelistedSenders[_sender] = true;

        emit AddedSenderToWhitelist(_sender);
    }

    /**
     * @dev Remove recipient from the whitelist.
     * @param _recipient address of the recipient
     */
    function removeRecipientFromWhitelist(address _recipient) external onlyWhitelistManager
    {
        require(
            whitelistedRecipients[_recipient],
            'Recipient not whitelisted'
        );

        whitelistedRecipients[_recipient] = false;

        emit RemovedRecipientFromWhitelist(_recipient);
    }

    /**
     * @dev Remove sender from the whitelist.
     * @param _sender address of the sender
     */
    function removeSenderFromWhitelist(address _sender) external onlyWhitelistManager
    {
        require(
            whitelistedSenders[_sender],
            'Sender not whitelisted'
        );

        whitelistedSenders[_sender] = false;

        emit RemovedSenderFromWhitelist(_sender);
    }

    /**
     * @dev Called by owner to enable fee take
     */
    function enableFees()
        external
        onlyOwner
        whenFeesDisabled
    {
        feesEnabled = true;
        emit EnabledFees();
    }

    /**
     * @dev Called by owner to disable fee take
     */
    function disableFees()
        external
        onlyOwner
        whenFeesEnabled
    {
        feesEnabled = false;
        emit DisabledFees();
    }

    /**
     * @dev Called by owner to set fee percentage.
     * @param _fee uint256 The new fee percentage.
     */
    function setFee(uint256 _fee)
        external
        onlyOwner
    {
        require(_fee != uint256(0) && _fee <= 100 * (10 ** 4));
        fee = _fee;
        emit FeeChanged(fee);
    }

    /**
     * @dev Called by owner to set fee beeneficiary.
     * @param _feeBeneficiary address The new fee beneficiary.
     */
    function setFeeBeneficiary(address _feeBeneficiary)
        external
        onlyOwner
    {
        require(_feeBeneficiary != address(0));
        feeBeneficiary = _feeBeneficiary;
        emit FeeBeneficiaryChanged(feeBeneficiary);
    }

    /**
     * @dev Called by owner to set fee threshold.
     * @param _feeThreshold uint256 The new fee threshold.
     */
    function setFeeThreshold(uint256 _feeThreshold)
        external
        onlyOwner
    {
        require(_feeThreshold != uint256(0));
        feeThreshold = _feeThreshold;
        emit FeeThresholdChanged(feeThreshold);
    }

    /**
     * @dev transfer token for a specified address
     * @param _to The address to transfer to.
     * @param _value The amount to be transferred.
     */
    function transfer(address _to, uint256 _value) public returns (bool)
    {
        if (whitelist) {
            require (
                whitelistedSenders[msg.sender]
                || whitelistedRecipients[_to]
                || msg.sender == owner
                || _to == owner,
                'Sender or recipient not whitelisted'
            );
        }

        uint256 _feeTaken;

        if (msg.sender != owner && msg.sender != feeBeneficiary) {
            (_feeTaken, _value) = applyFees(_value);
        }

        if (_feeTaken > 0) {
            require (super.transfer(feeBeneficiary, _feeTaken) && super.transfer(_to, _value));

            return true;
        }

        return super.transfer(_to, _value);
    }

    /**
     * @dev Transfer tokens from one address to another
     * @param _from address The address which you want to send tokens from
     * @param _to address The address which you want to transfer to
     * @param _value uint256 the amount of tokens to be transferred
     */
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool)
    {
        if (whitelist) {
            require (
                whitelistedSenders[_from]
                || whitelistedRecipients[_to]
                || _from == owner
                || _to == owner,
                'Sender or recipient not whitelisted'
            );
        }

        uint256 _feeTaken;
        (_feeTaken, _value) = applyFees(_value);
        
        if (_feeTaken > 0) {
            require (super.transferFrom(_from, feeBeneficiary, _feeTaken) && super.transferFrom(_from, _to, _value));
            
            return true;
        }

        return super.transferFrom(_from, _to, _value);
    }

    /**
     * @dev Called internally for applying fees to the transfer value.
     * @param _value uint256
     */
    function applyFees(uint256 _value)
        internal
        view
        returns (uint256 _feeTaken, uint256 _revisedValue)
    {
        _revisedValue = _value;

        if (feesEnabled && _revisedValue >= feeThreshold) {
            _feeTaken = _revisedValue.mul(fee).div(uint256(100 * (10 ** 4)));
            _revisedValue = _revisedValue.sub(_feeTaken);
        }
    }
}