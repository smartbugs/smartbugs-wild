pragma solidity ^0.4.15;

library SafeMath {
  function mul(uint256 a, uint256 b) internal constant returns (uint256) {
    uint256 c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal constant returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  function sub(uint256 a, uint256 b) internal constant returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal constant returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}

contract ApproveAndCallReceiver {
    function receiveApproval(address from, uint256 _amount, address _token, bytes _data) public;
}

contract TokenFactoryInterface {

    function createCloneToken(
        address _parentToken,
        uint _snapshotBlock,
        string _tokenName,
        string _tokenSymbol
      ) public returns (ServusToken newToken);
}

/**
 * @title Controllable
 * @dev The Controllable contract has an controller address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Controllable {
  address public controller;


  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender account.
   */
  function Controllable() public {
    controller = msg.sender;
  }

  /**
   * @dev Throws if called by any account other than the owner.
   */
  modifier onlyController() {
    require(msg.sender == controller);
    _;
  }

  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param newController The address to transfer ownership to.
   */
  function transferControl(address newController) public onlyController {
    if (newController != address(0)) {
      controller = newController;
    }
  }

}

/**
 * @title ServusToken (SRV)
 * Standard Mintable ERC20 Token
 * https://github.com/ethereum/EIPs/issues/20
 * Based on code by FirstBlood:
 * https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol
 */
contract ServusTokenInterface is Controllable {

  event Mint(address indexed to, uint256 amount);
  event MintFinished();
  event ClaimedTokens(address indexed _token, address indexed _owner, uint _amount);
  event NewCloneToken(address indexed _cloneToken, uint _snapshotBlock);
  event Approval(address indexed _owner, address indexed _spender, uint256 _amount);
  event Transfer(address indexed from, address indexed to, uint256 value);

  function totalSupply() public constant returns (uint);
  function totalSupplyAt(uint _blockNumber) public constant returns(uint);
  function balanceOf(address _owner) public constant returns (uint256 balance);
  function balanceOfAt(address _owner, uint _blockNumber) public constant returns (uint);
  function transfer(address _to, uint256 _amount) public returns (bool success);
  function transferFrom(address _from, address _to, uint256 _amount) public returns (bool success);
  function approve(address _spender, uint256 _amount) public returns (bool success);
  function approveAndCall(address _spender, uint256 _amount, bytes _extraData) public returns (bool success);
  function allowance(address _owner, address _spender) public constant returns (uint256 remaining);
  function mint(address _owner, uint _amount) public returns (bool);
  function importPresaleBalances(address[] _addresses, uint256[] _balances, address _presaleAddress) public returns (bool);
  function lockPresaleBalances() public returns (bool);
  function finishMinting() public returns (bool);
  function enableTransfers(bool _value) public;
  function enableMasterTransfers(bool _value) public;
  function createCloneToken(uint _snapshotBlock, string _cloneTokenName, string _cloneTokenSymbol) public returns (address);

}
/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
  address public owner;


  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender account.
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
    if (newOwner != address(0)) {
      owner = newOwner;
    }
  }

}

contract ServusToken is Controllable {

  using SafeMath for uint256;
  ServusTokenInterface public parentToken;
  TokenFactoryInterface public tokenFactory;

  string public name;
  string public symbol;
  string public version;
  uint8 public decimals;

  uint256 public parentSnapShotBlock;
  uint256 public creationBlock;
  bool public transfersEnabled;

  bool public masterTransfersEnabled;
  address public masterWallet = 0x9d23cc4efa366b70f34f1879bc6178e6f3342441;


  struct Checkpoint {
    uint128 fromBlock;
    uint128 value;
  }

  Checkpoint[] totalSupplyHistory;
  mapping(address => Checkpoint[]) balances;
  mapping (address => mapping (address => uint)) allowed;

  bool public mintingFinished = false;
  bool public presaleBalancesLocked = false;

  uint256 public constant TOTAL_PRESALE_TOKENS = 2896000000000000000000;

  event Mint(address indexed to, uint256 amount);
  event MintFinished();
  event ClaimedTokens(address indexed _token, address indexed _owner, uint _amount);
  event NewCloneToken(address indexed cloneToken);
  event Approval(address indexed _owner, address indexed _spender, uint256 _amount);
  event Transfer(address indexed from, address indexed to, uint256 value);




  function ServusToken(
    address _tokenFactory,
    address _parentToken,
    uint256 _parentSnapShotBlock,
    string _tokenName,
    string _tokenSymbol
    ) public {
      tokenFactory = TokenFactoryInterface(_tokenFactory);
      parentToken = ServusTokenInterface(_parentToken);
      parentSnapShotBlock = _parentSnapShotBlock;
      name = _tokenName;
      symbol = _tokenSymbol;
      decimals = 6;
      transfersEnabled = false;
      masterTransfersEnabled = false;
      creationBlock = block.number;
      version = '0.1';
  }

  function() public payable {
    revert();
  }


  /**
  * Returns the total Servus token supply at the current block
  * @return total supply {uint256}
  */
  function totalSupply() public constant returns (uint256) {
    return totalSupplyAt(block.number);
  }

  /**
  * Returns the total Servus token supply at the given block number
  * @param _blockNumber {uint256}
  * @return total supply {uint256}
  */
  function totalSupplyAt(uint256 _blockNumber) public constant returns(uint256) {
    // These next few lines are used when the totalSupply of the token is
    //  requested before a check point was ever created for this token, it
    //  requires that the `parentToken.totalSupplyAt` be queried at the
    //  genesis block for this token as that contains totalSupply of this
    //  token at this block number.
    if ((totalSupplyHistory.length == 0) || (totalSupplyHistory[0].fromBlock > _blockNumber)) {
        if (address(parentToken) != 0) {
            return parentToken.totalSupplyAt(min(_blockNumber, parentSnapShotBlock));
        } else {
            return 0;
        }

    // This will return the expected totalSupply during normal situations
    } else {
        return getValueAt(totalSupplyHistory, _blockNumber);
    }
  }

  /**
  * Returns the token holder balance at the current block
  * @param _owner {address}
  * @return balance {uint256}
   */
  function balanceOf(address _owner) public constant returns (uint256 balance) {
    return balanceOfAt(_owner, block.number);
  }

  /**
  * Returns the token holder balance the the given block number
  * @param _owner {address}
  * @param _blockNumber {uint256}
  * @return balance {uint256}
  */
  function balanceOfAt(address _owner, uint256 _blockNumber) public constant returns (uint256) {
    // These next few lines are used when the balance of the token is
    //  requested before a check point was ever created for this token, it
    //  requires that the `parentToken.balanceOfAt` be queried at the
    //  genesis block for that token as this contains initial balance of
    //  this token
    if ((balances[_owner].length == 0) || (balances[_owner][0].fromBlock > _blockNumber)) {
        if (address(parentToken) != 0) {
            return parentToken.balanceOfAt(_owner, min(_blockNumber, parentSnapShotBlock));
        } else {
            // Has no parent
            return 0;
        }

    // This will return the expected balance during normal situations
    } else {
        return getValueAt(balances[_owner], _blockNumber);
    }
  }

  /**
  * Standard ERC20 transfer tokens function
  * @param _to {address}
  * @param _amount {uint}
  * @return success {bool}
  */
  function transfer(address _to, uint256 _amount) public returns (bool success) {
    return doTransfer(msg.sender, _to, _amount);
  }

  /**
  * Standard ERC20 transferFrom function
  * @param _from {address}
  * @param _to {address}
  * @param _amount {uint256}
  * @return success {bool}
  */
  function transferFrom(address _from, address _to, uint256 _amount) public returns (bool success) {
    require(allowed[_from][msg.sender] >= _amount);
    allowed[_from][msg.sender] -= _amount;
    return doTransfer(_from, _to, _amount);
  }

  /**
  * Standard ERC20 approve function
  * @param _spender {address}
  * @param _amount {uint256}
  * @return success {bool}
  */
  function approve(address _spender, uint256 _amount) public returns (bool success) {
    require(transfersEnabled);

    //https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
    require((_amount == 0) || (allowed[msg.sender][_spender] == 0));

    allowed[msg.sender][_spender] = _amount;
    Approval(msg.sender, _spender, _amount);
    return true;
  }

  /**
  * Standard ERC20 approve function
  * @param _spender {address}
  * @param _amount {uint256}
  * @return success {bool}
  */
  function approveAndCall(address _spender, uint256 _amount, bytes _extraData) public returns (bool success) {
    approve(_spender, _amount);

    ApproveAndCallReceiver(_spender).receiveApproval(
        msg.sender,
        _amount,
        this,
        _extraData
    );

    return true;
  }

  /**
  * Standard ERC20 allowance function
  * @param _owner {address}
  * @param _spender {address}
  * @return remaining {uint256}
   */
  function allowance(address _owner, address _spender) public constant returns (uint256 remaining) {
    return allowed[_owner][_spender];
  }

  /**
  * Internal Transfer function - Updates the checkpoint ledger
  * @param _from {address}
  * @param _to {address}
  * @param _amount {uint256}
  * @return success {bool}
  */
  function doTransfer(address _from, address _to, uint256 _amount) internal returns(bool) {

    if (msg.sender != masterWallet) {
      require(transfersEnabled);
    } else {
      require(masterTransfersEnabled);
    }

    require(_amount > 0);
    require(parentSnapShotBlock < block.number);
    require((_to != 0) && (_to != address(this)));

    // If the amount being transfered is more than the balance of the
    // account the transfer returns false
    uint256 previousBalanceFrom = balanceOfAt(_from, block.number);
    require(previousBalanceFrom >= _amount);

    // First update the balance array with the new value for the address
    //  sending the tokens
    updateValueAtNow(balances[_from], previousBalanceFrom - _amount);

    // Then update the balance array with the new value for the address
    //  receiving the tokens
    uint256 previousBalanceTo = balanceOfAt(_to, block.number);
    require(previousBalanceTo + _amount >= previousBalanceTo); // Check for overflow
    updateValueAtNow(balances[_to], previousBalanceTo + _amount);

    // An event to make the transfer easy to find on the blockchain
    Transfer(_from, _to, _amount);
    return true;
  }


  /**
  * Token creation functions - can only be called by the tokensale controller during the tokensale period
  * @param _owner {address}
  * @param _amount {uint256}
  * @return success {bool}
  */
  function mint(address _owner, uint256 _amount) public onlyController canMint returns (bool) {
    uint256 curTotalSupply = totalSupply();
    uint256 previousBalanceTo = balanceOf(_owner);

    require(curTotalSupply + _amount >= curTotalSupply); // Check for overflow
    require(previousBalanceTo + _amount >= previousBalanceTo); // Check for overflow

    updateValueAtNow(totalSupplyHistory, curTotalSupply + _amount);
    updateValueAtNow(balances[_owner], previousBalanceTo + _amount);
    Transfer(0, _owner, _amount);
    return true;
  }

  modifier canMint() {
    require(!mintingFinished);
    _;
  }


  /**
   * Import presale balances before the start of the token sale. After importing
   * balances, lockPresaleBalances() has to be called to prevent further modification
   * of presale balances.
   * @param _addresses {address[]} Array of presale addresses
   * @param _balances {uint256[]} Array of balances corresponding to presale addresses.
   * @return success {bool}
   */
  function importPresaleBalances(address[] _addresses, uint256[] _balances) public onlyController returns (bool) {
    require(presaleBalancesLocked == false);

    for (uint256 i = 0; i < _addresses.length; i++) {
      updateValueAtNow(balances[_addresses[i]], _balances[i]);
      Transfer(0, _addresses[i], _balances[i]);
    }

    updateValueAtNow(totalSupplyHistory, TOTAL_PRESALE_TOKENS);
    return true;
  }

  /**
   * Lock presale balances after successful presale balance import
   * @return A boolean that indicates if the operation was successful.
   */
  function lockPresaleBalances() public onlyController returns (bool) {
    presaleBalancesLocked = true;
    return true;
  }

  /**
   * Lock the minting of Servus Tokens - to be called after the presale
   * @return {bool} success
  */
  function finishMinting() public onlyController returns (bool) {
    mintingFinished = true;
    MintFinished();
    return true;
  }

  /**
   * Enable or block transfers - to be called in case of emergency
   * @param _value {bool}
  */
  function enableTransfers(bool _value) public onlyController {
    transfersEnabled = _value;
  }

  /**
   * Enable or block transfers - to be called in case of emergency
   * @param _value {bool}
  */
  function enableMasterTransfers(bool _value) public onlyController {
    masterTransfersEnabled = _value;
  }

  /**
   * Internal balance method - gets a certain checkpoint value a a certain _block
   * @param _checkpoints {Checkpoint[]} List of checkpoints - supply history or balance history
   * @return value {uint256} Value of _checkpoints at _block
  */
  function getValueAt(Checkpoint[] storage _checkpoints, uint256 _block) constant internal returns (uint256) {

      if (_checkpoints.length == 0)
        return 0;
      // Shortcut for the actual value
      if (_block >= _checkpoints[_checkpoints.length-1].fromBlock)
        return _checkpoints[_checkpoints.length-1].value;
      if (_block < _checkpoints[0].fromBlock)
        return 0;

      // Binary search of the value in the array
      uint256 min = 0;
      uint256 max = _checkpoints.length-1;
      while (max > min) {
          uint256 mid = (max + min + 1) / 2;
          if (_checkpoints[mid].fromBlock<=_block) {
              min = mid;
          } else {
              max = mid-1;
          }
      }
      return _checkpoints[min].value;
  }


  /**
  * Internal update method - updates the checkpoint ledger at the current block
  * @param _checkpoints {Checkpoint[]}  List of checkpoints - supply history or balance history
  * @return value {uint256} Value to add to the checkpoints ledger
   */
  function updateValueAtNow(Checkpoint[] storage _checkpoints, uint256 _value) internal {
      if ((_checkpoints.length == 0) || (_checkpoints[_checkpoints.length-1].fromBlock < block.number)) {
              Checkpoint storage newCheckPoint = _checkpoints[_checkpoints.length++];
              newCheckPoint.fromBlock = uint128(block.number);
              newCheckPoint.value = uint128(_value);
          } else {
              Checkpoint storage oldCheckPoint = _checkpoints[_checkpoints.length-1];
              oldCheckPoint.value = uint128(_value);
          }
  }


  function min(uint256 a, uint256 b) internal constant returns (uint) {
      return a < b ? a : b;
  }

  /**
  * Clones Servus Token at the given snapshot block
  * @param _snapshotBlock {uint256}
  * @param _name {string} - The cloned token name
  * @param _symbol {string} - The cloned token symbol
  * @return clonedTokenAddress {address}
   */
  function createCloneToken(uint256 _snapshotBlock, string _name, string _symbol) public returns(address) {

      if (_snapshotBlock == 0) {
        _snapshotBlock = block.number;
      }

      if (_snapshotBlock > block.number) {
        _snapshotBlock = block.number;
      }

      ServusToken cloneToken = tokenFactory.createCloneToken(
          this,
          _snapshotBlock,
          _name,
          _symbol
        );


      cloneToken.transferControl(msg.sender);

      // An event to make the token easy to find on the blockchain
      NewCloneToken(address(cloneToken));
      return address(cloneToken);
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

  function Pausable() public {}

  /**
   * @dev modifier to allow actions only when the contract IS paused
   */
  modifier whenNotPaused() {
    require(!paused);
    _;
  }

  /**
   * @dev modifier to allow actions only when the contract IS NOT paused
   */
  modifier whenPaused {
    require(paused);
    _;
  }

  /**
   * @dev called by the owner to pause, triggers stopped state
   */
  function pause() public onlyOwner whenNotPaused returns (bool) {
    paused = true;
    Pause();
    return true;
  }

  /**
   * @dev called by the owner to unpause, returns to normal state
   */
  function unpause() public onlyOwner whenPaused returns (bool) {
    paused = false;
    Unpause();
    return true;
  }
}

/**
 * @title Tokensale
 * Tokensale allows investors to make token purchases and assigns them tokens based

 * on a token per ETH rate. Funds collected are forwarded to a wallet as they arrive.
 */
contract TokenSale is Pausable {

  using SafeMath for uint256;

  ServusTokenInterface public servusToken;
  uint256 public totalWeiRaised;
  uint256 public tokensMinted;
  uint256 public totalSupply;
  uint256 public contributors;
  uint256 public decimalsMultiplier;
  uint256 public startTime;
  uint256 public endTime;
  uint256 public remainingTokens;
  uint256 public allocatedTokens;

  bool public finalized;

  bool public servusTokensAllocated;
  address public servusMultiSig = 0x0cc3e09c8a52fa0313154321be706635cdbdec37;

  uint256 public constant BASE_PRICE_IN_WEI = 1000000000000000;
  uint256 public constant PUBLIC_TOKENS = 100000000 * (10 ** 6);
  uint256 public constant TOTAL_PRESALE_TOKENS = 50000000 * (10 ** 6);
  uint256 public constant TOKENS_ALLOCATED_TO_SERVUS = 100000000 * (10 ** 6);



  uint256 public tokenCap = PUBLIC_TOKENS - TOTAL_PRESALE_TOKENS;
  uint256 public cap = tokenCap;
  uint256 public weiCap = cap * BASE_PRICE_IN_WEI;

  uint256 public firstDiscountPrice = (BASE_PRICE_IN_WEI * 85) / 100;
  uint256 public secondDiscountPrice = (BASE_PRICE_IN_WEI * 90) / 100;
  uint256 public thirdDiscountPrice = (BASE_PRICE_IN_WEI * 95) / 100;

  uint256 public firstDiscountCap = (weiCap * 5) / 100;
  uint256 public secondDiscountCap = (weiCap * 10) / 100;
  uint256 public thirdDiscountCap = (weiCap * 20) / 100;

  bool public started = false;

  event TokenPurchase(address indexed purchaser, address indexed beneficiary, uint256 value, uint256 amount);
  event NewClonedToken(address indexed _cloneToken);
  event OnTransfer(address _from, address _to, uint _amount);
  event OnApprove(address _owner, address _spender, uint _amount);
  event LogInt(string _name, uint256 _value);
  event Finalized();

  function TokenSale(address _tokenAddress, uint256 _startTime, uint256 _endTime) public {
    require(_tokenAddress != 0x0);
    require(_startTime > 0);
    require(_endTime > _startTime);

    startTime = _startTime;
    endTime = _endTime;
    servusToken = ServusTokenInterface(_tokenAddress);

    decimalsMultiplier = (10 ** 6);
  }


  /**
   * High level token purchase function
   */
  function() public payable {
    buyTokens(msg.sender);
  }

  /**
   * Low level token purchase function
   * @param _beneficiary will receive the tokens.
   */
  function buyTokens(address _beneficiary) public payable whenNotPaused whenNotFinalized {
    require(_beneficiary != 0x0);
    require(validPurchase());

    uint256 weiAmount = msg.value;
    uint256 priceInWei = getPriceInWei();
    totalWeiRaised = totalWeiRaised.add(weiAmount);

    uint256 tokens = weiAmount.mul(decimalsMultiplier).div(priceInWei);
    tokensMinted = tokensMinted.add(tokens);
    require(tokensMinted < tokenCap);

    contributors = contributors.add(1);

    servusToken.mint(_beneficiary, tokens);
    TokenPurchase(msg.sender, _beneficiary, weiAmount, tokens);
    forwardFunds();
  }


  /**
   * Get the price in wei for current premium
   * @return price {uint256}
   */
  function getPriceInWei() constant public returns (uint256) {

    uint256 price;

    if (totalWeiRaised < firstDiscountCap) {
      price = firstDiscountPrice;
    } else if (totalWeiRaised < secondDiscountCap) {
      price = secondDiscountPrice;
    } else if (totalWeiRaised < thirdDiscountCap) {
      price = thirdDiscountPrice;
    } else {
      price = BASE_PRICE_IN_WEI;
    }

    return price;
  }

  /**
  * Forwards funds to the tokensale wallet
  */
  function forwardFunds() internal {
    servusMultiSig.transfer(msg.value);
  }


  /**
  * Validates the purchase (period, minimum amount, within cap)
  * @return {bool} valid
  */
  function validPurchase() internal constant returns (bool) {
    uint256 current = now;
    bool presaleStarted = (current >= startTime || started);
    bool presaleNotEnded = current <= endTime;
    bool nonZeroPurchase = msg.value != 0;
    return nonZeroPurchase && presaleStarted && presaleNotEnded;
  }

  /**
  * Returns the total Servus token supply
  * @return totalSupply {uint256} Servus Token Total Supply
  */
  function totalSupply() public constant returns (uint256) {
    return servusToken.totalSupply();
  }

  /**
  * Returns token holder Servus Token balance
  * @param _owner {address} Token holder address
  * @return balance {uint256} Corresponding token holder balance
  */
  function balanceOf(address _owner) public constant returns (uint256) {
    return servusToken.balanceOf(_owner);
  }

  /**
  * Change the Servus Token controller
  * @param _newController {address} New Servus Token controller
  */
  function changeController(address _newController) public {
    require(isContract(_newController));
    servusToken.transferControl(_newController);
  }


  function enableTransfers() public {
    if (now < endTime) {
      require(msg.sender == owner);
    }
    servusToken.enableTransfers(true);
  }

  function lockTransfers() public onlyOwner {
    require(now < endTime);
    servusToken.enableTransfers(false);
  }

  function enableMasterTransfers() public onlyOwner {
    servusToken.enableMasterTransfers(true);
  }

  function lockMasterTransfers() public onlyOwner {
    servusToken.enableMasterTransfers(false);
  }

  function forceStart() public onlyOwner {
    started = true;
  }

  function allocateServusTokens() public onlyOwner whenNotFinalized {
    require(!servusTokensAllocated);
    servusToken.mint(servusMultiSig, TOKENS_ALLOCATED_TO_SERVUS);
    servusTokensAllocated = true;
  }

  function finalize() public onlyOwner {
    require(paused);
    require(servusTokensAllocated);

    servusToken.finishMinting();
    servusToken.enableTransfers(true);
    Finalized();

    finalized = true;
  }


  function isContract(address _addr) constant internal returns(bool) {
    uint size;
    if (_addr == 0)
      return false;
    assembly {
        size := extcodesize(_addr)
    }
    return size>0;
  }

  modifier whenNotFinalized() {
    require(!finalized);
    _;
  }

}