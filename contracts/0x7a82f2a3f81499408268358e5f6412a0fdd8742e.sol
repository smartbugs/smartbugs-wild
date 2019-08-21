pragma solidity ^0.4.24;


/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
  address public owner;


  event OwnershipRenounced(address previousOwner);
  event OwnershipTransferred(
    address previousOwner,
    address newOwner
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

interface IERC20 {
  function totalSupply() external view returns (uint256);

  function balanceOf(address who) external view returns (uint256);

  function allowance(address owner, address spender)
    external view returns (uint256);

  function transfer(address to, uint256 value) external returns (bool);

  function approve(address spender, uint256 value)
    external returns (bool);

  function transferFrom(address from, address to, uint256 value)
    external returns (bool);

  event Transfer(
    address from,
    address to,
    uint256 value
  );

  event Approval(
    address owner,
    address spender,
    uint256 value
  );
}

contract ERC20 is IERC20 {
  using SafeMath for uint256;

  mapping (address => uint256) private _balances;

  mapping (address => mapping (address => uint256)) private _allowed;

  uint256 private _totalSupply;
  bool public isPaused;

  /**
  * @dev Total number of tokens in existence
  */
  function totalSupply() public view returns (uint256) {
    return _totalSupply;
  }

  /**
  * @dev Gets the balance of the specified address.
  * @param owner The address to query the balance of.
  * @return An uint256 representing the amount owned by the passed address.
  */
  function balanceOf(address owner) public view returns (uint256) {
    return _balances[owner];
  }

  /**
   * @dev Function to check the amount of tokens that an owner allowed to a spender.
   * @param owner address The address which owns the funds.
   * @param spender address The address which will spend the funds.
   * @return A uint256 specifying the amount of tokens still available for the spender.
   */
  function allowance(
    address owner,
    address spender
   )
    public
    view
    returns (uint256)
  {
    return _allowed[owner][spender];
  }

  /**
  * @dev Transfer token for a specified address
  * @param to The address to transfer to.
  * @param value The amount to be transferred.
  */
  function transfer(address to, uint256 value) public returns (bool) {
    _transfer(msg.sender, to, value);
    return true;
  }

  /**
   * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.
   * Beware that changing an allowance with this method brings the risk that someone may use both the old
   * and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this
   * race condition is to first reduce the spender's allowance to 0 and set the desired value afterwards:
   * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
   * @param spender The address which will spend the funds.
   * @param value The amount of tokens to be spent.
   */
  function approve(address spender, uint256 value) public returns (bool) {
    require(isPaused == false, "transactions on pause");
    require(spender != address(0));

    _allowed[msg.sender][spender] = value;
    emit Approval(msg.sender, spender, value);
    return true;
  }

  /**
   * @dev Transfer tokens from one address to another
   * @param from address The address which you want to send tokens from
   * @param to address The address which you want to transfer to
   * @param value uint256 the amount of tokens to be transferred
   */
  function transferFrom(
    address from,
    address to,
    uint256 value
  )
    public
    returns (bool)
  {
    require(value <= _allowed[from][msg.sender]);

    _allowed[from][msg.sender] = _allowed[from][msg.sender].sub(value);
    _transfer(from, to, value);
    return true;
  }

  /**
   * @dev Increase the amount of tokens that an owner allowed to a spender.
   * approve should be called when allowed_[_spender] == 0. To increment
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   * @param spender The address which will spend the funds.
   * @param addedValue The amount of tokens to increase the allowance by.
   */
  function increaseAllowance(
    address spender,
    uint256 addedValue
  )
    public
    returns (bool)
  {
    require(spender != address(0));
    require(isPaused == false, "transactions on pause");

    _allowed[msg.sender][spender] = (
      _allowed[msg.sender][spender].add(addedValue));
    emit Approval(msg.sender, spender, _allowed[msg.sender][spender]);
    return true;
  }

  /**
   * @dev Decrease the amount of tokens that an owner allowed to a spender.
   * approve should be called when allowed_[_spender] == 0. To decrement
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   * @param spender The address which will spend the funds.
   * @param subtractedValue The amount of tokens to decrease the allowance by.
   */
  function decreaseAllowance(
    address spender,
    uint256 subtractedValue
  )
    public
    returns (bool)
  {
    require(spender != address(0));
    require(isPaused == false, "transactions on pause");

    _allowed[msg.sender][spender] = (
      _allowed[msg.sender][spender].sub(subtractedValue));
    emit Approval(msg.sender, spender, _allowed[msg.sender][spender]);
    return true;
  }

  /**
  * @dev Transfer token for a specified addresses
  * @param from The address to transfer from.
  * @param to The address to transfer to.
  * @param value The amount to be transferred.
  */
  function _transfer(address from, address to, uint256 value) internal {
    require(value <= _balances[from]);
    require(to != address(0));
    require(isPaused == false, "transactions on pause");

    _balances[from] = _balances[from].sub(value);
    _balances[to] = _balances[to].add(value);
    emit Transfer(from, to, value);
  }

  /**
   * @dev Internal function that mints an amount of the token and assigns it to
   * an account. This encapsulates the modification of balances such that the
   * proper events are emitted.
   * @param account The account that will receive the created tokens.
   * @param value The amount that will be created.
   */
  function _mint(address account, uint256 value) internal {
    require(account != 0);
    require(isPaused == false, "transactions on pause");
    _totalSupply = _totalSupply.add(value);
    _balances[account] = _balances[account].add(value);
    emit Transfer(address(0), account, value);
  }

  /**
   * @dev Internal function that burns an amount of the token of a given
   * account.
   * @param account The account whose tokens will be burnt.
   * @param value The amount that will be burnt.
   */
  function _burn(address account, uint256 value) internal {
    require(account != 0);
    require(value <= _balances[account]);

    _totalSupply = _totalSupply.sub(value);
    _balances[account] = _balances[account].sub(value);
    emit Transfer(account, address(0), value);
  }

  /**
   * @dev Internal function that burns an amount of the token of a given
   * account, deducting from the sender's allowance for said account. Uses the
   * internal burn function.
   * @param account The account whose tokens will be burnt.
   * @param value The amount that will be burnt.
   */
  function _burnFrom(address account, uint256 value) internal {
    require(value <= _allowed[account][msg.sender]);

    // Should https://github.com/OpenZeppelin/zeppelin-solidity/issues/707 be accepted,
    // this function needs to emit an event with the updated approval.
    _allowed[account][msg.sender] = _allowed[account][msg.sender].sub(
      value);
    _burn(account, value);
  }
}

contract FabgCoin is ERC20, Ownable {
    string public name;
    string public symbol;
    uint8 public decimals;

    //tokens per one eth
    uint256 public rate;
    uint256 public minimalPayment;

    bool public isBuyBlocked;
    address saleAgent;
    uint256 public totalEarnings;

    event TokensCreatedWithoutPayment(address Receiver, uint256 Amount);
    event BoughtTokens(address Receiver, uint256 Amount, uint256 sentWei);
    event BuyPaused();
    event BuyUnpaused();
    event UsagePaused();
    event UsageUnpaused();
    event Payment(address payer, uint256 weiAmount);

    modifier onlySaleAgent() {
        require(msg.sender == saleAgent);
        _;
    }

    function changeRate(uint256 _rate) public onlyOwner {
        rate = _rate;
    }

    function pauseCustomBuying() public onlyOwner {
        require(isBuyBlocked == false);
        isBuyBlocked = true;
        emit BuyPaused();
    }

    function resumeCustomBuy() public onlyOwner {
        require(isBuyBlocked == true);
        isBuyBlocked = false;
        emit BuyUnpaused();
    }

    function pauseUsage() public onlyOwner {
        require(isPaused == false);
        isPaused = true;
        emit UsagePaused();
    }

    function resumeUsage() public onlyOwner {
        require(isPaused == true);
        isPaused = false;
        emit UsageUnpaused();
    }

    function setSaleAgent(address _saleAgent) public onlyOwner {
        require(saleAgent == address(0));
        saleAgent = _saleAgent;
    }

    function createTokenWithoutPayment(address _receiver, uint256 _amount) public onlyOwner {
        _mint(_receiver, _amount);

        emit TokensCreatedWithoutPayment(_receiver, _amount);
    }

    function createTokenViaSaleAgent(address _receiver, uint256 _amount) public onlySaleAgent {
        _mint(_receiver, _amount);
    }

    function buyTokens() public payable {
        require(msg.value >= minimalPayment);
        require(isBuyBlocked == false);

        uint256 amount = msg.value.mul(rate); 
        _mint(msg.sender, amount);

        totalEarnings = totalEarnings.add(amount.div(rate));

        emit BoughtTokens(msg.sender, amount, msg.value);
    }
}

contract FabgCoinMarketPack is FabgCoin {
    using SafeMath for uint256;

    bool isPausedForSale;

    /**
     * maping for store amount of tokens to amount of wei per that pack
     */
    mapping(uint256 => uint256) packsToWei;
    uint256[] packs;
    uint256 public totalEarningsForPackSale;
    address adminsWallet;

    event MarketPaused();
    event MarketUnpaused();
    event PackCreated(uint256 TokensAmount, uint256 WeiAmount);
    event PackDeleted(uint256 TokensAmount);
    event PackBought(address Buyer, uint256 TokensAmount, uint256 WeiAmount);
    event Withdrawal(address receiver, uint256 weiAmount);

    constructor() public {  
        name = "FabgCoin";
        symbol = "FABG";
        decimals = 18;
        rate = 100;
        minimalPayment = 1 ether / 100;
        isBuyBlocked = true;
    }

    /**
     * @dev set address for wallet for withdrawal
     * @param _newMultisig new address for withdrawals
     */
    function setAddressForPayment(address _newMultisig) public onlyOwner {
        adminsWallet = _newMultisig;
    }

    /**
     * @dev fallback function which can receive ether with no actions
     */
    function() public payable {
       emit Payment(msg.sender, msg.value);
    }

    /**
     * @dev pause possibility of buying pack of tokens
     */
    function pausePackSelling() public onlyOwner {
        require(isPausedForSale == false);
        isPausedForSale = true;
        emit MarketPaused();
    }

    /**
     * @dev return possibility of buying pack of tokens
     */
    function unpausePackSelling() public onlyOwner {
        require(isPausedForSale == true);
        isPausedForSale = false;
        emit MarketUnpaused();
    }    

    /**
     * @dev add pack to list of possible to buy
     * @param _amountOfTokens amount of tokens in pack
     * @param _amountOfWei amount of wei for buying 1 pack
     */
    function addPack(uint256 _amountOfTokens, uint256 _amountOfWei) public onlyOwner {
        require(packsToWei[_amountOfTokens] == 0);
        require(_amountOfTokens != 0);
        require(_amountOfWei != 0);
        
        packs.push(_amountOfTokens);
        packsToWei[_amountOfTokens] = _amountOfWei;

        emit PackCreated(_amountOfTokens, _amountOfWei);
    }

    /**
     * @dev buying existing pack of tokens
     * @param _amountOfTokens amount of tokens in pack for buying
     */
    function buyPack(uint256 _amountOfTokens) public payable {
        require(packsToWei[_amountOfTokens] > 0);
        require(msg.value >= packsToWei[_amountOfTokens]);
        require(isPausedForSale == false);

        _mint(msg.sender, _amountOfTokens * 1 ether);
        (msg.sender).transfer(msg.value.sub(packsToWei[_amountOfTokens]));

        totalEarnings = totalEarnings.add(packsToWei[_amountOfTokens]);
        totalEarningsForPackSale = totalEarningsForPackSale.add(packsToWei[_amountOfTokens]);

        emit PackBought(msg.sender, _amountOfTokens, packsToWei[_amountOfTokens]);
    }

    /**
     * @dev withdraw all ether from this contract to sender's wallet
     */
    function withdraw() public onlyOwner {
        require(adminsWallet != address(0), "admins wallet couldn't be 0x0");

        uint256 amount = address(this).balance;  
        (adminsWallet).transfer(amount);
        emit Withdrawal(adminsWallet, amount);
    }

    /**
     * @dev delete pack from selling
     * @param _amountOfTokens which pack delete
     */
    function deletePack(uint256 _amountOfTokens) public onlyOwner {
        require(packsToWei[_amountOfTokens] != 0);
        require(_amountOfTokens != 0);

        packsToWei[_amountOfTokens] = 0;

        uint256 index;

        for(uint256 i = 0; i < packs.length; i++) {
            if(packs[i] == _amountOfTokens) {
                index = i;
                break;
            }
        }

        for(i = index; i < packs.length - 1; i++) {
            packs[i] = packs[i + 1];
        }
        packs.length--;

        emit PackDeleted(_amountOfTokens);
    }

    /**
     * @dev get list of all available packs
     * @return uint256 array of packs
     */
    function getAllPacks() public view returns (uint256[]) {
        return packs;
    }

    /**
     * @dev get price of current pack in wei
     * @param _amountOfTokens current pack for price
     * @return uint256 amount of wei for buying
     */
    function getPackPrice(uint256 _amountOfTokens) public view returns (uint256) {
        return packsToWei[_amountOfTokens];
    }
}