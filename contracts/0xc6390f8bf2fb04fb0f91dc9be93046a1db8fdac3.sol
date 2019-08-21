pragma solidity ^0.4.15;

contract TokenFactoryInterface {

    function createCloneToken(
        address _parentToken,
        uint _snapshotBlock,
        string _tokenName,
        string _tokenSymbol
      ) public returns (ProofToken newToken);
}

contract ControllerInterface {

    function proxyPayment(address _owner) public payable returns(bool);
    function onTransfer(address _from, address _to, uint _amount) public returns(bool);
    function onApprove(address _owner, address _spender, uint _amount) public returns(bool);
}

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

contract ProofTokenInterface is Controllable {

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
  function enableTransfers(bool _transfersEnabled) public;
  function createCloneToken(uint _snapshotBlock, string _cloneTokenName, string _cloneTokenSymbol) public returns (address);

}

contract ProofToken is Controllable {

  using SafeMath for uint256;
  ProofTokenInterface public parentToken;
  TokenFactoryInterface public tokenFactory;

  string public name;
  string public symbol;
  string public version;
  uint8 public decimals;

  struct Checkpoint {
    uint128 fromBlock;
    uint128 value;
  }

  uint256 public parentSnapShotBlock;
  uint256 public creationBlock;
  bool public transfersEnabled;

  mapping(address => Checkpoint[]) balances;
  mapping (address => mapping (address => uint)) allowed;

  Checkpoint[] totalSupplyHistory;

  bool public mintingFinished = false;
  bool public presaleBalancesLocked = false;

  uint256 public constant TOKENS_ALLOCATED_TO_PROOF = 1181031 * (10 ** 18);
  uint256 public constant TOTAL_PRESALE_TOKENS = 112386712924725508802400;

  event Mint(address indexed to, uint256 amount);
  event MintFinished();
  event ClaimedTokens(address indexed _token, address indexed _owner, uint _amount);
  event NewCloneToken(address indexed cloneToken);
  event Approval(address indexed _owner, address indexed _spender, uint256 _amount);
  event Transfer(address indexed from, address indexed to, uint256 value);




  function ProofToken(
    address _tokenFactory,
    address _parentToken,
    uint256 _parentSnapShotBlock,
    string _tokenName,
    string _tokenSymbol
    ) public {
      tokenFactory = TokenFactoryInterface(_tokenFactory);
      parentToken = ProofTokenInterface(_parentToken);
      parentSnapShotBlock = _parentSnapShotBlock;
      name = _tokenName;
      symbol = _tokenSymbol;
      decimals = 18;
      transfersEnabled = false;
      creationBlock = block.number;
      version = '0.1';
  }

  function() public payable {
    revert();
  }


  /**
  * Returns the total Proof token supply at the current block
  * @return total supply {uint}
  */
  function totalSupply() public constant returns (uint) {
    return totalSupplyAt(block.number);
  }

  /**
  * Returns the total Proof token supply at the given block number
  * @param _blockNumber {uint}
  * @return total supply {uint}
  */
  function totalSupplyAt(uint _blockNumber) public constant returns(uint) {
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
  * @return balance {uint}
   */
  function balanceOf(address _owner) public constant returns (uint256 balance) {
    return balanceOfAt(_owner, block.number);
  }

  /**
  * Returns the token holder balance the the given block number
  * @param _owner {address}
  * @param _blockNumber {uint}
  * @return balance {uint}
  */
  function balanceOfAt(address _owner, uint _blockNumber) public constant returns (uint) {
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
  * Standard ERC20 transfer tokens
  * @param _to {address}
  * @param _amount {uint}
  * @return success {bool}
  */
  function transfer(address _to, uint256 _amount) public returns (bool success) {
    return doTransfer(msg.sender, _to, _amount);
  }

  /**
  * Standard ERC20 transferFrom interface
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
  * Standard ERC20 approve interface
  * @param _spender {address}
  * @param _amount {uint256}
  * @return success {bool}
  */
  function approve(address _spender, uint256 _amount) public returns (bool success) {
    require(transfersEnabled);

    // To change the approve amount you first have to reduce the addresses`
    //  allowance to zero by calling `approve(_spender,0)` if it is not
    //  already 0 to mitigate the race condition described here:
    //  https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
    require((_amount == 0) || (allowed[msg.sender][_spender] == 0));

    // Alerts the token controller of the approve function call
    if (isContract(controller)) {
        require(ControllerInterface(controller).onApprove(msg.sender, _spender, _amount));
    }

    allowed[msg.sender][_spender] = _amount;
    Approval(msg.sender, _spender, _amount);
    return true;
  }

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

  function allowance(address _owner, address _spender) public constant returns (uint256 remaining) {
    return allowed[_owner][_spender];
  }


  function doTransfer(address _from, address _to, uint _amount) internal returns(bool) {
    require(transfersEnabled);
    require(_amount > 0);
    require(parentSnapShotBlock < block.number);
    require((_to != 0) && (_to != address(this)));

    // If the amount being transfered is more than the balance of the
    //  account the transfer returns false
    var previousBalanceFrom = balanceOfAt(_from, block.number);
    require(previousBalanceFrom >= _amount);

    // Alerts the token controller of the transfer
    if (isContract(controller)) {
      require(ControllerInterface(controller).onTransfer(_from, _to, _amount));
    }

    // First update the balance array with the new value for the address
    //  sending the tokens
    updateValueAtNow(balances[_from], previousBalanceFrom - _amount);

    // Then update the balance array with the new value for the address
    //  receiving the tokens
    var previousBalanceTo = balanceOfAt(_to, block.number);
    require(previousBalanceTo + _amount >= previousBalanceTo); // Check for overflow
    updateValueAtNow(balances[_to], previousBalanceTo + _amount);

    // An event to make the transfer easy to find on the blockchain
    Transfer(_from, _to, _amount);
    return true;
  }


  function mint(address _owner, uint _amount) public onlyController canMint returns (bool) {
    uint curTotalSupply = totalSupply();
    uint previousBalanceTo = balanceOf(_owner);

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
   * Lock the minting of Proof Tokens - to be called after the presale
   * @return {bool} success
  */
  function finishMinting() public onlyController returns (bool) {
    mintingFinished = true;
    MintFinished();
    return true;
  }

  /**
   * Enable or block transfers - to be called in case of emergency
  */
  function enableTransfers(bool _transfersEnabled) public onlyController {
      transfersEnabled = _transfersEnabled;
  }


  function getValueAt(Checkpoint[] storage checkpoints, uint _block) constant internal returns (uint) {

      if (checkpoints.length == 0)
        return 0;
      // Shortcut for the actual value
      if (_block >= checkpoints[checkpoints.length-1].fromBlock)
        return checkpoints[checkpoints.length-1].value;
      if (_block < checkpoints[0].fromBlock)
        return 0;

      // Binary search of the value in the array
      uint min = 0;
      uint max = checkpoints.length-1;
      while (max > min) {
          uint mid = (max + min + 1) / 2;
          if (checkpoints[mid].fromBlock<=_block) {
              min = mid;
          } else {
              max = mid-1;
          }
      }
      return checkpoints[min].value;
  }

  function updateValueAtNow(Checkpoint[] storage checkpoints, uint _value
  ) internal
  {
      if ((checkpoints.length == 0) || (checkpoints[checkpoints.length-1].fromBlock < block.number)) {
              Checkpoint storage newCheckPoint = checkpoints[checkpoints.length++];
              newCheckPoint.fromBlock = uint128(block.number);
              newCheckPoint.value = uint128(_value);
          } else {
              Checkpoint storage oldCheckPoint = checkpoints[checkpoints.length-1];
              oldCheckPoint.value = uint128(_value);
          }
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

  /// @dev Helper function to return a min betwen the two uints
  function min(uint a, uint b) internal constant returns (uint) {
      return a < b ? a : b;
  }

  /**
  * Clones Proof Token at the given snapshot block
  * @param _snapshotBlock {uint}
  * @param _cloneTokenName {string}
  * @param _cloneTokenSymbol {string}
   */
  function createCloneToken(
        uint _snapshotBlock,
        string _cloneTokenName,
        string _cloneTokenSymbol
    ) public returns(address) {

      if (_snapshotBlock == 0) {
        _snapshotBlock = block.number;
      }

      if (_snapshotBlock > block.number) {
        _snapshotBlock = block.number;
      }

      ProofToken cloneToken = tokenFactory.createCloneToken(
          this,
          _snapshotBlock,
          _cloneTokenName,
          _cloneTokenSymbol
        );


      cloneToken.transferControl(msg.sender);

      // An event to make the token easy to find on the blockchain
      NewCloneToken(address(cloneToken));
      return address(cloneToken);
    }

}