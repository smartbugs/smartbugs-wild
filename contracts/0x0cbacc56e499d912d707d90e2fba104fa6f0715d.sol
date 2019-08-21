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






contract IToken is ERC20 {
    // note: we use external visibility for all non-standard functions 
    // (which are not used internally) 

    function reclaimToken(ERC20Basic _token, address _to) external;

    function setMaxTransferGasPrice(uint newGasPrice) external;

    // TAP whitelisting functions
    function whitelist(address TAP) external;
    function deWhitelist(address TAP) external;

    function setTransferFeeNumerator(uint newTransferFeeNumerator) external;

    // transfer blacklist functions
    function blacklist(address a) external;
    function deBlacklist(address a) external;

    // seizing function
    function seize(address a) external;

    // rebalance functions
    function rebalance(bool deducts, uint tokensAmount) external;

    // transfer fee functions
    function disableFee(address a) external;
    function enableFee(address a) external;
    function computeFee(uint amount) public view returns(uint);

    // to disable
    function renounceOwnership() public;

    // mintable
    event Mint(address indexed to, uint amount);
    function mint(address _to, uint _amount) public returns(bool);
    // to disable
    function finishMinting() public returns (bool);

    // burnable
    event Burn(address indexed burner, uint value);
    // burn is only available through the transfer function
    function burn(uint _value) public;

    // pausable
    function pause() public;
    function unpause() public;

    // ownable
    function transferOwnership(address newOwner) public;
    function transferSuperownership(address newOwner) external; // external for consistency reasons

    function increaseApproval(address _spender, uint256 _addedValue) public returns (bool);
    function decreaseApproval(address _spender, uint256 _subtractedValue) public returns (bool);
}







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



contract Token is IToken, PausableToken, BurnableToken, MintableToken, DetailedERC20 {
    using SafeMath for uint;
    using SafeERC20 for ERC20Basic;

    // scaling factor
    uint public scaleFactor = 10 ** 18;
    mapping(address => uint) internal lastScalingFactor;

    // maximum percent of scaling of balances
    uint constant internal MAX_REBALANCE_PERCENT = 5;

    // gas price
    // deactivate the limit at deployment: set it to the maximum integer
    uint public maxTransferGasPrice = uint(-1);
    event TransferGasPrice(uint oldGasPrice, uint newGasPrice);

    // transfer fee is computed as:
    // regular transfer amount * transferFeeNumerator / TRANSFER_FEE_DENOMINATOR
    uint public transferFeeNumerator = 0;
    uint constant internal MAX_NUM_DISABLED_FEES = 100;
    uint constant internal MAX_FEE_PERCENT = 5;
    uint constant internal TRANSFER_FEE_DENOMINATOR = 10 ** 18;
    mapping(address => bool) public avoidsFees;
    address[] public avoidsFeesArray;
    event TransferFeeNumerator(uint oldNumerator, uint newNumerator);
    event TransferFeeDisabled(address indexed account);
    event TransferFeeEnabled(address indexed account);
    event TransferFee(
        address indexed to,
        AccountClassification
        fromAccountClassification,
        uint amount
    );

    // whitelisted TAPs
    mapping(address => bool) public TAPwhiteListed;
    event TAPWhiteListed(address indexed TAP);
    event TAPDeWhiteListed(address indexed TAP);

    // blacklisted Accounts
    mapping(address => bool) public transferBlacklisted;
    event TransferBlacklisted(address indexed account);
    event TransferDeBlacklisted(address indexed account);

    // seized funds
    event FundsSeized(
        address indexed account,
        AccountClassification fromAccountClassification,
        uint amount
    );

    // extended transfer event
    enum AccountClassification {Zero, Owner, Superowner, TAP, Other} // Enum
    // block accounts with classification Other
    bool public blockOtherAccounts;
    event TransferExtd(
        address indexed from,
        AccountClassification fromAccountClassification,
        address indexed to,
        AccountClassification toAccountClassification,
        uint amount
    );
    event BlockOtherAccounts(bool isEnabled);

    // rebalancing event
    event Rebalance(
        bool deducts,
        uint amount,
        uint oldScaleFactor,
        uint newScaleFactor,
        uint oldTotalSupply,
        uint newTotalSupply
    );

    // additional owner
    address public superowner;
    event SuperownershipTransferred(address indexed previousOwner,
      address indexed newOwner);
    mapping(address => bool) public usedOwners;

    constructor(
      string name,
      string symbol,
      uint8 decimals,
      address _superowner
    )
    public DetailedERC20(name, symbol, decimals)
    {
        require(_superowner != address(0), "superowner is not the zero address");
        superowner = _superowner;
        usedOwners[owner] = true;
        usedOwners[superowner] = true;
    }

    modifier onlyOwner() {
        require(isOwner(msg.sender),  "sender is owner or superowner");
        _;
    }

    modifier hasMintPermission() {
        require(isOwner(msg.sender),  "sender is owner or superowner");
        _;
    }

    modifier nonZeroAddress(address account) {
        require(account != address(0), "account is not the zero address");
        _;
    }

    modifier limitGasPrice() {
        require(tx.gasprice <= maxTransferGasPrice, "gasprice is less than its upper bound");
        _;
    }

    /**
     * @dev Reclaim all ERC20Basic compatible tokens that have been sent by mistake to this
     * contract
     * @param _token ERC20Basic The address of the token contract
     * @param _to The address of the recipient of the tokens
     */
    function reclaimToken(ERC20Basic _token, address _to) external onlyOwner {
        uint256 balance = _token.balanceOf(address(this));
        _token.safeTransfer(_to, balance);
    }

    /**
     * @notice Setter of max transfer gas price
     * @param newGasPrice the new gas price
     */
    function setMaxTransferGasPrice(uint newGasPrice) external onlyOwner {
        require(newGasPrice != 0, "gas price limit cannot be null");
        emit TransferGasPrice(maxTransferGasPrice, newGasPrice);
        maxTransferGasPrice = newGasPrice;
    }

    /**
     * @notice Whitelist an address as a TAP to which tokens can be minted
     * @param TAP The address to whitelist
     */
    function whitelist(address TAP) external nonZeroAddress(TAP) onlyOwner {
        require(!isOwner(TAP), "TAP is not owner or superowner");
        require(!TAPwhiteListed[TAP], "TAP cannot be whitlisted");
        emit TAPWhiteListed(TAP);
        TAPwhiteListed[TAP] = true;
    }

    /**
     * @notice Dewhitelist an address as a TAP
     * @param TAP The address to dewhitelist
     */
    function deWhitelist(address TAP) external nonZeroAddress(TAP) onlyOwner {
        require(TAPwhiteListed[TAP], "TAP is whitlisted");
        emit TAPDeWhiteListed(TAP);
        TAPwhiteListed[TAP] = false;
    }

    /**
     * @notice Change the transfer fee numerator
     * @param newTransferFeeNumerator The new transfer fee numerator
     */
    function setTransferFeeNumerator(uint newTransferFeeNumerator) external onlyOwner {
        require(newTransferFeeNumerator <= TRANSFER_FEE_DENOMINATOR.mul(MAX_FEE_PERCENT).div(100),
            "transfer fee numerator is less than its upper bound");
        emit TransferFeeNumerator(transferFeeNumerator, newTransferFeeNumerator);
        transferFeeNumerator = newTransferFeeNumerator;
    }

    /**
     * @notice Blacklist an account to prevent their transfers
     * @dev this function can be called while the contract is paused, to prevent blacklisting and
     * front-running (by first pausing, then blacklisting)
     * @param account The address to blacklist
     */
    function blacklist(address account) external nonZeroAddress(account) onlyOwner {
        require(!transferBlacklisted[account], "account is not blacklisted");
        emit TransferBlacklisted(account);
        transferBlacklisted[account] = true;
    }

    /**
     * @notice Deblacklist an account to allow their transfers once again
     * @param account The address to deblacklist
     */
    function deBlacklist(address account) external nonZeroAddress(account) onlyOwner {
        require(transferBlacklisted[account], "account is blacklisted");
        emit TransferDeBlacklisted(account);
        transferBlacklisted[account] = false;
    }

    /**
     * @notice Seize all funds from a blacklisted account
     * @param account The address to be seized
     */
    function seize(address account) external nonZeroAddress(account) onlyOwner {
        require(transferBlacklisted[account], "account has been blacklisted");
        updateBalanceAndScaling(account);
        uint balance = balanceOf(account);
        emit FundsSeized(account, getAccountClassification(account), balance);
        super._burn(account, balance);
    }

    /**
     * @notice disable future transfer fees for an account
     * @dev The fees owed before this function are paid here, via updateBalanceAndScaling.
     * @param account The address which will avoid future transfer fees
     */
    function disableFee(address account) external nonZeroAddress(account) onlyOwner {
        require(!avoidsFees[account], "account has fees");
        require(avoidsFeesArray.length < MAX_NUM_DISABLED_FEES, "array is not full");
        emit TransferFeeDisabled(account);
        avoidsFees[account] = true;
        avoidsFeesArray.push(account);
    }

    /**
     * @notice enable future transfer fees for an account
     * @param account The address which will pay future transfer fees
     */
    function enableFee(address account) external nonZeroAddress(account) onlyOwner {
        require(avoidsFees[account], "account avoids fees");
        emit TransferFeeEnabled(account);
        avoidsFees[account] = false;
        uint len = avoidsFeesArray.length;
        assert(len != 0);
        for (uint i = 0; i < len; i++) {
            if (avoidsFeesArray[i] == account) {
                avoidsFeesArray[i] = avoidsFeesArray[len.sub(1)];
                avoidsFeesArray.length--;
                return;
            }
        }
        assert(false);
    }

    /**
     * @notice rebalance changes the total supply by the given amount (either deducts or adds)
     * by scaling all balance amounts proportionally (also those exempt from fees)
     * @dev this uses the current total supply (which is the sum of all token balances excluding
     * the inventory, i.e., the balances of owner and superowner) to compute the new scale factor
     * @param deducts indication if we deduct or add token from total supply
     * @param tokensAmount the number of tokens to add/deduct
     */
    function rebalance(bool deducts, uint tokensAmount) external onlyOwner {
        uint oldTotalSupply = totalSupply();
        uint oldScaleFactor = scaleFactor;

        require(
            tokensAmount <= oldTotalSupply.mul(MAX_REBALANCE_PERCENT).div(100),
            "tokensAmount is within limits"
        );

        // new scale factor and total supply
        uint newScaleFactor;
        if (deducts) {
            newScaleFactor = oldScaleFactor.mul(
                oldTotalSupply.sub(tokensAmount)).div(oldTotalSupply
            );
        } else {
            newScaleFactor = oldScaleFactor.mul(
                oldTotalSupply.add(tokensAmount)).div(oldTotalSupply
            );
        }
        // update scaleFactor
        scaleFactor = newScaleFactor;

        // update total supply
        uint newTotalSupply = oldTotalSupply.mul(scaleFactor).div(oldScaleFactor);
        totalSupply_ = newTotalSupply;

        emit Rebalance(
            deducts,
            tokensAmount,
            oldScaleFactor,
            newScaleFactor,
            oldTotalSupply,
            newTotalSupply
        );

        if (deducts) {
            require(newTotalSupply < oldTotalSupply, "totalSupply shrinks");
            // avoid overly large rounding errors
            assert(oldTotalSupply.sub(tokensAmount.mul(9).div(10)) >= newTotalSupply);
            assert(oldTotalSupply.sub(tokensAmount.mul(11).div(10)) <= newTotalSupply);
        } else {
           require(newTotalSupply > oldTotalSupply, "totalSupply grows");
           // avoid overly large rounding errors
           assert(oldTotalSupply.add(tokensAmount.mul(9).div(10)) <= newTotalSupply);
           assert(oldTotalSupply.add(tokensAmount.mul(11).div(10)) >= newTotalSupply);
        }
    }

    /**
     * @notice enable change of superowner
     * @param _newSuperowner the address of the new owner
     */
    function transferSuperownership(
        address _newSuperowner
    )
    external nonZeroAddress(_newSuperowner)
    {
        require(msg.sender == superowner, "only superowner");
        require(!usedOwners[_newSuperowner], "owner was not used before");
        usedOwners[_newSuperowner] = true;
        uint value = balanceOf(superowner);
        if (value > 0) {
            super._burn(superowner, value);
            emit TransferExtd(
                superowner,
                AccountClassification.Superowner,
                address(0),
                AccountClassification.Zero,
                value
            );
        }
        emit SuperownershipTransferred(superowner, _newSuperowner);
        superowner = _newSuperowner;
    }

    /**
     * @notice Compute the regular amount of tokens of an account.
     * @dev Gets the balance of the specified address.
     * @param account The address to query the the balance of.
     * @return An uint256 representing the amount owned by the passed address.
     */
    function balanceOf(address account) public view returns (uint) {
        uint amount = balances[account];
        uint oldScaleFactor = lastScalingFactor[account];
        if (oldScaleFactor == 0) {
            return 0;
        } else if (oldScaleFactor == scaleFactor) {
            return amount;
        } else {
            return amount.mul(scaleFactor).div(oldScaleFactor);
        }
    }

    /**
     * @notice Compute the fee corresponding to a transfer not exempt from fees.
     * @param amount The amount of the transfer
     * @return the number of tokens to be paid as a fee
     */
    function computeFee(uint amount) public view returns (uint) {
        return amount.mul(transferFeeNumerator).div(TRANSFER_FEE_DENOMINATOR);
    }

    /**
     * @notice Compute the total outstanding of tokens (excluding those held by owner
     * and superowner, i.e., the inventory accounts).
     * @dev function to get the total supply excluding inventory
     * @return The uint total supply excluding inventory
     */
    function totalSupply() public view returns(uint) {
        uint inventory = balanceOf(owner);
        if (owner != superowner) {
            inventory = inventory.add(balanceOf(superowner));
        }
        return (super.totalSupply().sub(inventory));
    }

    /**
     * @notice enable change of owner
     * @param _newOwner the address of the new owner
     */
    function transferOwnership(address _newOwner) public onlyOwner {
        require(!usedOwners[_newOwner], "owner was not used before");
        usedOwners[_newOwner] = true;
        uint value = balanceOf(owner);
        if (value > 0) {
            super._burn(owner, value);
            emit TransferExtd(
                owner,
                AccountClassification.Owner,
                address(0),
                AccountClassification.Zero,
                value
            );
        }
        super.transferOwnership(_newOwner);
    }

    /**
     * @notice Wrapper around OZ's increaseApproval
     * @dev Update the corresponding balance and scaling before increasing approval
     * @param _spender The address which will spend the funds.
     * @param _addedValue The amount of tokens to increase the allowance by.
     * @return true in case of success
     */
    function increaseApproval(
        address _spender,
        uint256 _addedValue
    )
    public whenNotPaused returns (bool)
    {
        updateBalanceAndScaling(msg.sender);
        updateBalanceAndScaling(_spender);
        return super.increaseApproval(_spender, _addedValue);
    }

    /**
     * @notice Wrapper around OZ's decreaseApproval
     * @dev Update the corresponding balance and scaling before decreasing approval
     * @param _spender The address which will spend the funds.
     * @param _subtractedValue The amount of tokens to decrease the allowance by.
     * @return true in case of success
     */
    function decreaseApproval(
        address _spender,
        uint256 _subtractedValue
    )
    public whenNotPaused returns (bool)
    {
        updateBalanceAndScaling(msg.sender);
        updateBalanceAndScaling(_spender);
        return super.decreaseApproval(_spender, _subtractedValue);
    }

    /**
     * @dev Transfer token for a specified address
     * @param _to The address to transfer to.
     * @param _value The amount to be transferred, from which the transfer fee will be deducted
     * @return true in case of success
     */
    function transfer(
        address _to,
        uint _value
    )
    public whenNotPaused limitGasPrice returns (bool)
    {
        require(!transferBlacklisted[msg.sender], "sender is not blacklisted");
        require(!transferBlacklisted[_to], "to address is not blacklisted");
        require(!blockOtherAccounts ||
            (getAccountClassification(msg.sender) != AccountClassification.Other &&
            getAccountClassification(_to) != AccountClassification.Other),
            "addresses are not blocked");

        emit TransferExtd(
            msg.sender,
            getAccountClassification(msg.sender),
            _to,
            getAccountClassification(_to),
            _value
        );

        updateBalanceAndScaling(msg.sender);

        if (_to == address(0)) {
            // burn tokens
            super.burn(_value);
            return true;
        }

        updateBalanceAndScaling(_to);

        require(super.transfer(_to, _value), "transfer succeeds");

        if (!avoidsFees[msg.sender] && !avoidsFees[_to]) {
            computeAndBurnFee(_to, _value);
        }

        return true;
    }

    /**
     * @dev Transfer tokens from one address to another
     * @param _from address The address which you want to send tokens from
     * @param _to address The address which you want to transfer to
     * @param _value uint256 the amount of tokens to be transferred, from which the transfer fee
     * will be deducted
     * @return true in case of success
     */
    function transferFrom(
        address _from,
        address _to,
        uint _value
    )
    public whenNotPaused limitGasPrice returns (bool)
    {
        require(!transferBlacklisted[msg.sender], "sender is not blacklisted");
        require(!transferBlacklisted[_from], "from address is not blacklisted");
        require(!transferBlacklisted[_to], "to address is not blacklisted");
        require(!blockOtherAccounts ||
            (getAccountClassification(_from) != AccountClassification.Other &&
            getAccountClassification(_to) != AccountClassification.Other),
            "addresses are not blocked");

        emit TransferExtd(
            _from,
            getAccountClassification(_from),
            _to,
            getAccountClassification(_to),
            _value
        );

        updateBalanceAndScaling(_from);

        if (_to == address(0)) {
            // burn tokens
            super.transferFrom(_from, msg.sender, _value);
            super.burn(_value);
            return true;
        }

        updateBalanceAndScaling(_to);

        require(super.transferFrom(_from, _to, _value), "transfer succeeds");

        if (!avoidsFees[msg.sender] && !avoidsFees[_from] && !avoidsFees[_to]) {
            computeAndBurnFee(_to, _value);
        }

        return true;
    }

    /**
     * @dev Approve the passed address to spend the specified amount of tokens on behalf of
     * msg.sender. Beware that changing an allowance with this method brings the risk that someone
     * may use both the old and the new allowance by unfortunate transaction ordering. One
     * possible solution to mitigate this race condition is to first reduce the spender's
     * allowance to 0 and set the desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     * @param _spender The address which will spend the funds.
     * @param _value Amount of tokens to be spent, from which the transfer fee will be deducted.
     * @return true in case of success
     */
    function approve(address _spender, uint _value) public whenNotPaused returns (bool) {
        updateBalanceAndScaling(_spender);
        return super.approve(_spender, _value);
    }

    /**
     * @dev Function for TAPs to mint tokens
     * @param _to The address that will receive the minted tokens.
     * @param _amount The amount of tokens to mint.
     * @return true in case of success
     */
    function mint(address _to, uint _amount) public returns(bool) {
        require(!transferBlacklisted[_to], "to address is not blacklisted");
        require(!blockOtherAccounts || getAccountClassification(_to) != AccountClassification.Other,
            "to address is not blocked");
        updateBalanceAndScaling(_to);
        emit TransferExtd(
            address(0),
            AccountClassification.Zero,
            _to,
            getAccountClassification(_to),
            _amount
        );
        return super.mint(_to, _amount);
    }

    /**
     * @notice toggle allowOthterAccounts variable
     */
    function toggleBlockOtherAccounts() public onlyOwner {
        blockOtherAccounts = !blockOtherAccounts;
        emit BlockOtherAccounts(blockOtherAccounts);
    }

    // get AccountClassification of an account
    function getAccountClassification(
        address account
    )
    internal view returns(AccountClassification)
    {
        if (account == address(0)) {
            return AccountClassification.Zero;
        } else if (account == owner) {
            return AccountClassification.Owner;
        } else if (account == superowner) {
            return AccountClassification.Superowner;
        } else if (TAPwhiteListed[account]) {
            return AccountClassification.TAP;
        } else {
            return AccountClassification.Other;
        }
    }

    // check if account is an owner
    function isOwner(address account) internal view returns (bool) {
        return account == owner || account == superowner;
    }

    // update balance and scaleFactor
    function updateBalanceAndScaling(address account) internal {
        uint oldBalance = balances[account];
        uint newBalance = balanceOf(account);
        if (lastScalingFactor[account] != scaleFactor) {
            lastScalingFactor[account] = scaleFactor;
        }
        if (oldBalance != newBalance) {
            balances[account] = newBalance;
        }
    }

    // compute and burn a transfer fee
    function computeAndBurnFee(address _to, uint _value) internal {
        uint fee = computeFee(_value);
        if (fee > 0) {
            _burn(_to, fee);
            emit TransferFee(_to, getAccountClassification(_to), fee);
        }
    }

    // disabled
    function finishMinting() public returns (bool) {
        require(false, "is disabled");
        return false;
    }

    // disabled
    function burn(uint /* _value */) public {
        // burn is only available through the transfer function
        require(false, "is disabled");
    }

    // disabled
    function renounceOwnership() public {
        require(false, "is disabled");
    }
}