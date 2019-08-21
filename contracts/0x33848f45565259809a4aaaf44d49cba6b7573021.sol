pragma solidity ^0.4.24;

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
  address private _owner;

  event OwnershipTransferred(
    address indexed previousOwner,
    address indexed newOwner
  );

  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  constructor(address custom_owner) public {
    if (custom_owner != address (0))
      _owner = custom_owner;
    else
      _owner = msg.sender;
    emit OwnershipTransferred(address(0), _owner);
  }

  /**
   * @return the address of the owner.
   */
  function owner() public view returns(address) {
    return _owner;
  }

  /**
   * @dev Throws if called by any account other than the owner.
   */
  modifier onlyOwner() {
    require(isOwner());
    _;
  }

  /**
   * @return true if `msg.sender` is the owner of the contract.
   */
  function isOwner() public view returns(bool) {
    return msg.sender == _owner;
  }

  /**
   * @dev Allows the current owner to relinquish control of the contract.
   * @notice Renouncing to ownership will leave the contract without an owner.
   * It will not be possible to call the functions with the `onlyOwner`
   * modifier anymore.
   */
  function renounceOwnership() public onlyOwner {
    emit OwnershipTransferred(_owner, address(0));
    _owner = address(0);
  }

  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param newOwner The address to transfer ownership to.
   */
  function transferOwnership(address newOwner) public onlyOwner {
    _transferOwnership(newOwner);
  }

  /**
   * @dev Transfers control of the contract to a newOwner.
   * @param newOwner The address to transfer ownership to.
   */
  function _transferOwnership(address newOwner) internal {
    require(newOwner != address(0));
    emit OwnershipTransferred(_owner, newOwner);
    _owner = newOwner;
  }
}


contract Authorizable is Ownable {
    mapping (address => bool) addressesAllowed;

    constructor () Ownable(address(0)) public {
        addressesAllowed[owner()] = true;
    }

    function addAuthorization (address authAddress) public onlyOwner {
        addressesAllowed[authAddress] = true;
    }

    function removeAuthorization (address authAddress) public onlyOwner {
        delete(addressesAllowed[authAddress]);
    }

    function isAuthorized () public view returns(bool) {
        return addressesAllowed[msg.sender];
    }

    modifier authorized() {
        require(isAuthorized());
        _;
    }
}

contract NotesharesCatalog is Authorizable {
    address[] public tokens;
    mapping (address => bool) public banned; // 1 - banned, 0 - allowed

    event tokenAdded (address tokenAddress);
    event permissionChanged (address tokenAddress, bool permission);

    function getTokens () public view returns(address[]) {
        return tokens;
    }

    function getTokensCount () public view returns(uint256) {
        return tokens.length;
    }

    function isBanned (address tokenAddress) public view returns(bool) {
        return banned[tokenAddress];
    }

    function setPermission (address tokenAddress, bool permission) public onlyOwner {
        if (permission)
            banned[tokenAddress] = permission;
        else
            delete(banned[tokenAddress]);

        emit permissionChanged(tokenAddress, permission);
    }

    function addExistingToken (address token) public authorized {
        require(token != address (0));
        tokens.push(token);
        emit tokenAdded (token);
    }

    function destruct () public onlyOwner {
        selfdestruct(owner());
    }
}

/*
    Based on https://etherscan.io/address/0x6dee36e9f915cab558437f97746998048dcaa700#code
    by https://blog.pennyether.com/posts/realtime-dividend-token.html
*/

/**
 * @title SafeMath
 * @dev Math operations with safety checks that revert on error
 */
library SafeMath {

  /**
  * @dev Multiplies two numbers, reverts on overflow.
  */
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
    // benefit is lost if 'b' is also tested.
    // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
    if (a == 0) {
      return 0;
    }

    uint256 c = a * b;
    require(c / a == b);

    return c;
  }

  /**
  * @dev Integer division of two numbers truncating the quotient, reverts on division by zero.
  */
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b > 0); // Solidity only automatically asserts when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold

    return c;
  }

  /**
  * @dev Subtracts two numbers, reverts on overflow (i.e. if subtrahend is greater than minuend).
  */
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b <= a);
    uint256 c = a - b;

    return c;
  }

  /**
  * @dev Adds two numbers, reverts on overflow.
  */
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    require(c >= a);

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


contract ERC20 {
    using SafeMath for uint256;

    string public name;
    string public symbol;
    uint8 public decimals = 18;
    uint public totalSupply;
    mapping (address => uint) public balanceOf;
    mapping (address => mapping (address => uint)) public allowance;

    event Created(uint time);
    event Transfer(address indexed from, address indexed to, uint amount);
    event Approval(address indexed owner, address indexed spender, uint amount);
    event AllowanceUsed(address indexed owner, address indexed spender, uint amount);

    constructor(string _name, string _symbol)
    public
    {
        name = _name;
        symbol = _symbol;
        emit Created(now);
    }

    function transfer(address _to, uint _value)
    public
    returns (bool success)
    {
        return _transfer(msg.sender, _to, _value);
    }

    function approve(address _spender, uint _value)
    public
    returns (bool success)
    {
        allowance[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    // Attempts to transfer `_value` from `_from` to `_to`
    //  if `_from` has sufficient allowance for `msg.sender`.
    function transferFrom(address _from, address _to, uint256 _value)
    public
    returns (bool success)
    {
        address _spender = msg.sender;
        require(allowance[_from][_spender] >= _value);
        allowance[_from][_spender] = allowance[_from][_spender].sub(_value);
        emit AllowanceUsed(_from, _spender, _value);
        return _transfer(_from, _to, _value);
    }

    // Transfers balance from `_from` to `_to` if `_to` has sufficient balance.
    // Called from transfer() and transferFrom().
    function _transfer(address _from, address _to, uint _value)
    private
    returns (bool success)
    {
        require(balanceOf[_from] >= _value);
        require(balanceOf[_to].add(_value) > balanceOf[_to]);
        balanceOf[_from] = balanceOf[_from].sub(_value);
        balanceOf[_to] = balanceOf[_to].add(_value);
        emit Transfer(_from, _to, _value);
        return true;
    }
}

interface HasTokenFallback {
    function tokenFallback(address _from, uint256 _amount, bytes _data)
    external
    returns (bool success);
}

contract ERC667 is ERC20 {
    constructor(string _name, string _symbol)
    public
    ERC20(_name, _symbol)
    {}

    function transferAndCall(address _to, uint _value, bytes _data)
    public
    returns (bool success)
    {
        require(super.transfer(_to, _value));
        require(HasTokenFallback(_to).tokenFallback(msg.sender, _value, _data));
        return true;
    }
}

/*********************************************************
******************* DIVIDEND TOKEN ***********************
**********************************************************

UI: https://www.pennyether.com/status/tokens

An ERC20 token that can accept Ether and distribute it
perfectly to all Token Holders relative to each account's
balance at the time the dividend is received.

The Token is owned by the creator, and can be frozen,
minted, and burned by the owner.

Notes:
    - Accounts can view or receive dividends owed at any time
    - Dividends received are immediately credited to all
      current Token Holders and can be redeemed at any time.
    - Per above, upon transfers, dividends are not
      transferred. They are kept by the original sender, and
      not credited to the receiver.
    - Uses "pull" instead of "push". Token holders must pull
      their own dividends.

*/
contract DividendTokenERC667 is ERC667, Ownable
{
    using SafeMath for uint256;

    // How dividends work:
    //
    // - A "point" is a fraction of a Wei (1e-32), it's used to reduce rounding errors.
    //
    // - totalPointsPerToken represents how many points each token is entitled to
    //   from all the dividends ever received. Each time a new deposit is made, it
    //   is incremented by the points oweable per token at the time of deposit:
    //     (depositAmtInWei * POINTS_PER_WEI) / totalSupply
    //
    // - Each account has a `creditedPoints` and `lastPointsPerToken`
    //   - lastPointsPerToken:
    //       The value of totalPointsPerToken the last time `creditedPoints` was changed.
    //   - creditedPoints:
    //       How many points have been credited to the user. This is incremented by:
    //         (`totalPointsPerToken` - `lastPointsPerToken` * balance) via
    //         `.updateCreditedPoints(account)`. This occurs anytime the balance changes
    //         (transfer, mint, burn).
    //
    // - .collectOwedDividends() calls .updateCreditedPoints(account), converts points
    //   to wei and pays account, then resets creditedPoints[account] to 0.
    //
    // - "Credit" goes to Nick Johnson for the concept.
    //
    uint constant POINTS_PER_WEI = 1e32;
    uint public dividendsTotal;
    uint public dividendsCollected;
    uint public totalPointsPerToken;
    mapping (address => uint) public creditedPoints;
    mapping (address => uint) public lastPointsPerToken;

    // Events
    event CollectedDividends(uint time, address indexed account, uint amount);
    event DividendReceived(uint time, address indexed sender, uint amount);

    constructor(uint256 _totalSupply, address _custom_owner)
    public
    ERC667("Noteshares Token", "NST")
    Ownable(_custom_owner)
    {
        totalSupply = _totalSupply;
    }

    // Upon receiving payment, increment lastPointsPerToken.
    function receivePayment()
    internal
    {
        if (msg.value == 0) return;
        // POINTS_PER_WEI is 1e32.
        // So, no multiplication overflow unless msg.value > 1e45 wei (1e27 ETH)
        totalPointsPerToken = totalPointsPerToken.add((msg.value.mul(POINTS_PER_WEI)).div(totalSupply));
        dividendsTotal = dividendsTotal.add(msg.value);
        emit DividendReceived(now, msg.sender, msg.value);
    }
    /*************************************************************/
    /********** PUBLIC FUNCTIONS *********************************/
    /*************************************************************/

    // Normal ERC20 transfer, except before transferring
    //  it credits points for both the sender and receiver.
    function transfer(address _to, uint _value)
    public
    returns (bool success)
    {
        // ensure tokens are not frozen.
        _updateCreditedPoints(msg.sender);
        _updateCreditedPoints(_to);
        return ERC20.transfer(_to, _value);
    }

    // Normal ERC20 transferFrom, except before transferring
    //  it credits points for both the sender and receiver.
    function transferFrom(address _from, address _to, uint256 _value)
    public
    returns (bool success)
    {
        _updateCreditedPoints(_from);
        _updateCreditedPoints(_to);
        return ERC20.transferFrom(_from, _to, _value);
    }

    // Normal ERC667 transferAndCall, except before transferring
    //  it credits points for both the sender and receiver.
    function transferAndCall(address _to, uint _value, bytes _data)
    public
    returns (bool success)
    {
        _updateCreditedPoints(msg.sender);
        _updateCreditedPoints(_to);
        return ERC667.transferAndCall(_to, _value, _data);
    }

    // Updates creditedPoints, sends all wei to the owner
    function collectOwedDividends()
    internal
    returns (uint _amount)
    {
        // update creditedPoints, store amount, and zero it.
        _updateCreditedPoints(msg.sender);
        _amount = creditedPoints[msg.sender].div(POINTS_PER_WEI);
        creditedPoints[msg.sender] = 0;
        dividendsCollected = dividendsCollected.add(_amount);
        emit CollectedDividends(now, msg.sender, _amount);
        require(msg.sender.call.value(_amount)());
    }


    /*************************************************************/
    /********** PRIVATE METHODS / VIEWS **************************/
    /*************************************************************/
    // Credits _account with whatever dividend points they haven't yet been credited.
    //  This needs to be called before any user's balance changes to ensure their
    //  "lastPointsPerToken" credits their current balance, and not an altered one.
    function _updateCreditedPoints(address _account)
    private
    {
        creditedPoints[_account] = creditedPoints[_account].add(_getUncreditedPoints(_account));
        lastPointsPerToken[_account] = totalPointsPerToken;
    }

    // For a given account, returns how many Wei they haven't yet been credited.
    function _getUncreditedPoints(address _account)
    private
    view
    returns (uint _amount)
    {
        uint _pointsPerToken = totalPointsPerToken.sub(lastPointsPerToken[_account]);
        // The upper bound on this number is:
        //   ((1e32 * TOTAL_DIVIDEND_AMT) / totalSupply) * balances[_account]
        // Since totalSupply >= balances[_account], this will overflow only if
        //   TOTAL_DIVIDEND_AMT is around 1e45 wei. Not ever going to happen.
        return _pointsPerToken.mul(balanceOf[_account]);
    }


    /*************************************************************/
    /********* CONSTANTS *****************************************/
    /*************************************************************/
    // Returns how many wei a call to .collectOwedDividends() would transfer.
    function getOwedDividends(address _account)
    public
    constant
    returns (uint _amount)
    {
        return (_getUncreditedPoints(_account).add(creditedPoints[_account])).div(POINTS_PER_WEI);
    }
}

contract NSERC667 is DividendTokenERC667 {
    using SafeMath for uint256;

    uint256 private TOTAL_SUPPLY =  100 * (10 ** uint256(decimals)); //always a 100 tokens representing 100% of ownership

    constructor (address ecosystemFeeAccount, uint256 ecosystemShare, address _custom_owner)
    public
    DividendTokenERC667(TOTAL_SUPPLY, _custom_owner)
    {
        uint256 ownerSupply = totalSupply.sub(ecosystemShare);
        balanceOf[owner()] = ownerSupply;
        balanceOf[ecosystemFeeAccount] = ecosystemShare;
    }
}

contract NotesharesToken is NSERC667 {
    using SafeMath for uint256;

    uint8 public state; //0 - canceled, 1 - active, 2 - failed, 3 - complete

    string private contentLink;
    string private folderLink;
    bool public hidden = false;

    constructor (string _contentLink, string _folderLink, address _ecosystemFeeAccount, uint256 ecosystemShare, address _custom_owner)
    public
    NSERC667(_ecosystemFeeAccount, ecosystemShare, _custom_owner) {
        state = 3;
        contentLink = _contentLink;
        folderLink = _folderLink;
    }

    //payables
    /**
     * Main donation function
     */
    function () public payable {
        require(state == 3); //donations only acceptable if contract is complete
        receivePayment();
    }

    function getContentLink () public view returns (string) {
        require(hidden == false);
        return contentLink;
    }

    function getFolderLink() public view returns (string) {
        require(hidden == false);
        return folderLink;
    }
    //Contract control
    /**
     * Transfers dividend in ETH if contract is complete or remaining funds to investors if contract is failed
     */

    function setCancelled () public onlyOwner {
        state = 0;
    }

    function setHidden (bool _hidden) public onlyOwner {
        hidden = _hidden;
    }

    function claimDividend () public {
        require(state > 1);
        collectOwedDividends();
    }

    //destruction is possible if there is only one owner
    function destruct () public onlyOwner {
        require(state == 2 || state == 3);
        require(balanceOf[owner()] == totalSupply);
        selfdestruct(owner());
    }

    //to claim ownership you should have 100% of tokens
    function claimOwnership () public {
        //require(state == 2);
        require(balanceOf[msg.sender] == totalSupply);
        _transferOwnership(msg.sender);
    }
}

contract NotesharesTokenFactory is Ownable (address(0)) {
    address public catalogAddress;
    address public ecosystemFeeAccount;

    event tokenCreated (address tokenAddress);

    constructor (address _catalogAddress, address _ecosystemFeeAccount) public {
        catalogAddress = _catalogAddress;
        ecosystemFeeAccount = _ecosystemFeeAccount;
    }

    function setEcosystemFeeAccount (address _ecosystemFeeAccount) public onlyOwner {
        ecosystemFeeAccount = _ecosystemFeeAccount;
    }

    function setCatalogAddress (address _catalogAddress) public onlyOwner {
        catalogAddress = _catalogAddress;
    }

    function addTokenToCatalog (address token) internal {
        NotesharesCatalog NSC = NotesharesCatalog(catalogAddress);
        NSC.addExistingToken(address(token));
    }

    function createToken (string _contentLink, string _folderLink, uint256 ecosystemShare) public returns (address){
        NotesharesToken NST = new NotesharesToken(_contentLink, _folderLink, ecosystemFeeAccount, ecosystemShare, msg.sender);
        emit tokenCreated(address(NST));
        addTokenToCatalog(address(NST));
    }

    function destruct () public onlyOwner {
        selfdestruct(owner());
    }
}