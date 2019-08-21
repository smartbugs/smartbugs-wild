pragma solidity 0.4.24;

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

// File: openzeppelin-solidity/contracts/token/ERC20/SafeERC20.sol

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

// File: contracts/governance/DelegateReference.sol

/**
* @title Delegate reference to be used in other contracts
*/
interface DelegateReference {
    /**
    * @notice Stake specified amount of tokens to the delegate to participate in coin distribution
    */
    function stake(uint256 _amount) external;

    /**
    * @notice Unstake specified amount of tokens from the delegate
    */
    function unstake(uint256 _amount) external;

    /**
    * @notice Return number of tokens staked by the specified staker
    */
    function stakeOf(address _staker) external view returns (uint256);

    /**
    * @notice Sets Aerum address for delegate & calling staker
    */
    function setAerumAddress(address _aerum) external;
}

// File: contracts/vesting/MultiVestingWallet.sol

/**
 * @title TokenVesting
 * @notice A token holder contract that can release its token balance gradually like a
 * typical vesting scheme, with a cliff and vesting period. Optionally revocable by the
 * owner.
 */
contract MultiVestingWallet is Ownable {
    using SafeMath for uint256;
    using SafeERC20 for ERC20;

    event Released(address indexed account, uint256 amount);
    event Revoked(address indexed account);
    event UnRevoked(address indexed account);
    event ReturnTokens(uint256 amount);
    event Promise(address indexed account, uint256 amount);
    event Stake(address indexed delegate, uint256 amount);
    event Unstake(address indexed delegate, uint256 amount);

    ERC20 public token;

    uint256 public cliff;
    uint256 public start;
    uint256 public duration;
    uint256 public staked;

    bool public revocable;

    address[] public accounts;
    mapping(address => bool) public known;
    mapping(address => uint256) public promised;
    mapping(address => uint256) public released;
    mapping(address => bool) public revoked;

    /**
     * @notice Creates a vesting contract that vests its balance of any ERC20 token to the
     * of the balance will have vested.
     * @param _token token being vested
     * @param _cliff duration in seconds of the cliff in which tokens will begin to vest
     * @param _start the time (as Unix time) at which point vesting starts
     * @param _duration duration in seconds of the period in which the tokens will vest
     * @param _revocable whether the vesting is revocable or not
     */
    constructor(
        address _token,
        uint256 _start,
        uint256 _cliff,
        uint256 _duration,
        bool _revocable
    )
    public
    {
        require(_token != address(0));
        require(_cliff <= _duration);

        token = ERC20(_token);
        revocable = _revocable;
        duration = _duration;
        cliff = _start.add(_cliff);
        start = _start;
    }

    /**
     * @notice Transfers vested tokens to beneficiary.
     */
    function release() external {
        _release(msg.sender);
    }

    /**
     * @notice Transfers vested tokens to list of beneficiary.
     * @param _addresses List of beneficiaries
     */
    function releaseBatch(address[] _addresses) external {
        for (uint256 index = 0; index < _addresses.length; index++) {
            _release(_addresses[index]);
        }
    }

    /**
     * @notice Transfers vested tokens to batch of beneficiaries (starting 0)
     * @param _start Index of first beneficiary to release tokens
     * @param _count Number of beneficiaries to release tokens
     */
    function releaseBatchPaged(uint256 _start, uint256 _count) external {
        uint256 last = _start.add(_count);
        if (last > accounts.length) {
            last = accounts.length;
        }

        for (uint256 index = _start; index < last; index++) {
            _release(accounts[index]);
        }
    }

    /**
     * @notice Transfers vested tokens to all beneficiaries.
     */
    function releaseAll() external {
        for (uint256 index = 0; index < accounts.length; index++) {
            _release(accounts[index]);
        }
    }

    /**
     * @notice Internal transfer of vested tokens to beneficiary.
     */
    function _release(address _beneficiary) internal {
        uint256 amount = releasableAmount(_beneficiary);
        if (amount > 0) {
            released[_beneficiary] = released[_beneficiary].add(amount);
            token.safeTransfer(_beneficiary, amount);

            emit Released(_beneficiary, amount);
        }
    }

    /**
     * @notice Allows the owner to revoke the vesting. Tokens already vested
     * remain in the contract, the rest are returned to the owner.
     * @param _beneficiary Account which will be revoked
     */
    function revoke(address _beneficiary) public onlyOwner {
        require(revocable);
        require(!revoked[_beneficiary]);

        promised[_beneficiary] = vestedAmount(_beneficiary);
        revoked[_beneficiary] = true;

        emit Revoked(_beneficiary);
    }

    /**
     * @notice Allows the owner to revoke the vesting for few addresses.
     * @param _addresses Accounts which will be unrevoked
     */
    function revokeBatch(address[] _addresses) external onlyOwner {
        for (uint256 index = 0; index < _addresses.length; index++) {
            revoke(_addresses[index]);
        }
    }

    /**
     * @notice Allows the owner to unrevoke the vesting.
     * @param _beneficiary Account which will be unrevoked
     */
    function unRevoke(address _beneficiary) public onlyOwner {
        require(revocable);
        require(revoked[_beneficiary]);

        revoked[_beneficiary] = false;

        emit UnRevoked(_beneficiary);
    }

    /**
     * @notice Allows the owner to unrevoke the vesting for few addresses.
     * @param _addresses Accounts which will be unrevoked
     */
    function unrevokeBatch(address[] _addresses) external onlyOwner {
        for (uint256 index = 0; index < _addresses.length; index++) {
            unRevoke(_addresses[index]);
        }
    }

    /**
     * @notice Calculates the amount that has already vested but hasn't been released yet.
     * @param _beneficiary Account which gets vested tokens
     */
    function releasableAmount(address _beneficiary) public view returns (uint256) {
        return vestedAmount(_beneficiary).sub(released[_beneficiary]);
    }

    /**
     * @notice Calculates the amount that has already vested.
     * @param _beneficiary Account which gets vested tokens
     */
    function vestedAmount(address _beneficiary) public view returns (uint256) {
        uint256 totalPromised = promised[_beneficiary];

        if (block.timestamp < cliff) {
            return 0;
        } else if (block.timestamp >= start.add(duration) || revoked[_beneficiary]) {
            return totalPromised;
        } else {
            return totalPromised.mul(block.timestamp.sub(start)).div(duration);
        }
    }

    /**
     * @notice Calculates the amount of free tokens in contract
     */
    function remainingBalance() public view returns (uint256) {
        uint256 tokenBalance = token.balanceOf(address(this));
        uint256 totalPromised = 0;
        uint256 totalReleased = 0;

        for (uint256 index = 0; index < accounts.length; index++) {
            address account = accounts[index];
            totalPromised = totalPromised.add(promised[account]);
            totalReleased = totalReleased.add(released[account]);
        }

        uint256 promisedNotReleased = totalPromised.sub(totalReleased);
        if (promisedNotReleased > tokenBalance) {
            return 0;
        }
        return tokenBalance.sub(promisedNotReleased);
    }

    /**
    * @notice Calculates amount of tokens promised
    */
    function totalPromised() public view returns (uint256) {
        uint256 total = 0;

        for (uint256 index = 0; index < accounts.length; index++) {
            address account = accounts[index];
            total = total.add(promised[account]);
        }

        return total;
    }

    /**
    * @notice Calculates amount of tokens released
    */
    function totalReleased() public view returns (uint256) {
        uint256 total = 0;

        for (uint256 index = 0; index < accounts.length; index++) {
            address account = accounts[index];
            total = total.add(released[account]);
        }

        return total;
    }

    /**
     * @notice Returns free tokens to owner
     */
    function returnRemaining() external onlyOwner {
        uint256 remaining = remainingBalance();
        require(remaining > 0);

        token.safeTransfer(owner, remaining);

        emit ReturnTokens(remaining);
    }

    /**
     * @notice Returns all tokens to owner
     */
    function returnAll() external onlyOwner {
        uint256 remaining = token.balanceOf(address(this));
        token.safeTransfer(owner, remaining);

        emit ReturnTokens(remaining);
    }

    /**
     * @notice Sets promise to account
     * @param _beneficiary Account which gets vested tokens
     * @param _amount Amount of tokens vested
     */
    function promise(address _beneficiary, uint256 _amount) public onlyOwner {
        if (!known[_beneficiary]) {
            known[_beneficiary] = true;
            accounts.push(_beneficiary);
        }

        promised[_beneficiary] = _amount;

        emit Promise(_beneficiary, _amount);
    }

    /**
     * @notice Sets promise to list of account
     * @param _addresses Accounts which will get promises
     * @param _amounts Promise amounts
     */
    function promiseBatch(address[] _addresses, uint256[] _amounts) external onlyOwner {
        require(_addresses.length == _amounts.length);

        for (uint256 index = 0; index < _addresses.length; index++) {
            promise(_addresses[index], _amounts[index]);
        }
    }

    /**
     * @notice Returns full list if beneficiaries
     */
    function getBeneficiaries() external view returns (address[]) {
        return accounts;
    }

    /**
     * @notice Returns number of beneficiaries
     */
    function getBeneficiariesCount() external view returns (uint256) {
        return accounts.length;
    }

    /**
     * @notice Stake specified amount of vested tokens to the delegate by the beneficiary
     */
    function stake(address _delegate, uint256 _amount) external onlyOwner {
        staked = staked.add(_amount);
        token.approve(_delegate, _amount);
        DelegateReference(_delegate).stake(_amount);

        emit Stake(_delegate, _amount);
    }

    /**
     * @notice Unstake the given number of vested tokens by the beneficiary
     */
    function unstake(address _delegate, uint256 _amount) external onlyOwner {
        staked = staked.sub(_amount);
        DelegateReference(_delegate).unstake(_amount);

        emit Unstake(_delegate, _amount);
    }
}

// File: contracts\registry\ContractRegistry.sol

/**
 * @title Contract registry
 */
contract ContractRegistry is Ownable {

    struct ContractRecord {
        address addr;
        bytes32 name;
        bool enabled;
    }

    address private token;

    /**
     * @dev contracts Mapping of contracts
     */
    mapping(bytes32 => ContractRecord) private contracts;
    /**
     * @dev contracts Mapping of contract names
     */
    bytes32[] private contractsName;

    event ContractAdded(bytes32 indexed _name);
    event ContractRemoved(bytes32 indexed _name);

    constructor(address _token) public {
        require(_token != address(0), "Token is required");
        token = _token;
    }

    /**
     * @dev Returns contract by name
     * @param _name Contract's name
     */
    function getContractByName(bytes32 _name) external view returns (address, bytes32, bool) {
        ContractRecord memory record = contracts[_name];
        if(record.addr == address(0) || !record.enabled) {
            return;
        }
        return (record.addr, record.name, record.enabled);
    }

    /**
     * @dev Returns contract's names
     */
    function getContractNames() external view returns (bytes32[]) {
        uint count = 0;
        for(uint i = 0; i < contractsName.length; i++) {
            if(contracts[contractsName[i]].enabled) {
                count++;
            }
        }
        bytes32[] memory result = new bytes32[](count);
        uint j = 0;
        for(i = 0; i < contractsName.length; i++) {
            if(contracts[contractsName[i]].enabled) {
                result[j] = contractsName[i];
                j++;
            }
        }
        return result;
    }

    /**
     * @notice Creates a vesting contract that vests its balance of any ERC20 token to the
     * of the balance will have vested.
     * @param _name contract's name
     * @param _cliff duration in seconds of the cliff in which tokens will begin to vest
     * @param _start the time (as Unix time) at which point vesting starts
     * @param _duration duration in seconds of the period in which the tokens will vest
     * @param _revocable whether the vesting is revocable or not
     */
    function addContract(
        bytes32 _name,
        uint256 _start,
        uint256 _cliff,
        uint256 _duration,
        bool _revocable) external onlyOwner {
        require(contracts[_name].addr == address(0), "Contract's name should be unique");
        require(_cliff <= _duration, "Cliff shall be bigger than duration");

        MultiVestingWallet wallet = new MultiVestingWallet(token, _start, _cliff, _duration, _revocable);
        wallet.transferOwnership(msg.sender);
        address walletAddr = address(wallet);
        
        ContractRecord memory record = ContractRecord({
            addr: walletAddr,
            name: _name,
            enabled: true
        });
        contracts[_name] = record;
        contractsName.push(_name);

        emit ContractAdded(_name);
    }

    /**
     * @dev Enables/disables contract by address
     * @param _name Name of the contract
     */
    function setEnabled(bytes32 _name, bool enabled) external onlyOwner {
        ContractRecord memory record = contracts[_name];
        require(record.addr != address(0), "Contract with specified address does not exist");

        contracts[_name].enabled = enabled;
    }

     /**
     * @dev Set's new name
     * @param _oldName Old name of the contract
     * @param _newName New name of the contract
     */
    function setNewName(bytes32 _oldName, bytes32 _newName) external onlyOwner {
        require(contracts[_newName].addr == address(0), "Contract's name should be unique");

        ContractRecord memory record = contracts[_oldName];
        require(record.addr != address(0), "Contract's old name should be defined");

        record.name = _newName;
        contracts[_newName] = record;
        contractsName.push(_newName);

        delete contracts[_oldName];
        contractsName = removeByValue(contractsName, _oldName);
    }

    function removeByValue(bytes32[] memory _array, bytes32 _name) private pure returns(bytes32[]) {
        uint i = 0;
        uint j = 0;
        bytes32[] memory outArray = new bytes32[](_array.length - 1);
        while (i < _array.length) {
            if(_array[i] != _name) {
                outArray[j] = _array[i];
                j++;
            }
            i++;
        }
        return outArray;
    }
}