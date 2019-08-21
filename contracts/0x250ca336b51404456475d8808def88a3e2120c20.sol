pragma solidity 0.4.24;


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
 * @title Vesting trustee contract for CoyToken.
 */
contract CoyVesting is Ownable {

    using SafeMath for uint256;

    using SafeERC20 for ERC20;

    ERC20 public token;

    // Vesting grant for a specific holder.
    struct Grant {
        uint256 value;
        uint256 start;
        uint256 cliff;
        uint256 end;
        uint256 installmentLength; // In seconds.
        uint256 transferred;
        bool revocable;
    }

    // Holder to grant information mapping.
    mapping (address => Grant) public grants;

    // Total tokens available for vesting.
    uint256 public totalVesting;

    event NewGrant(address indexed _from, address indexed _to, uint256 _value);

    event TokensUnlocked(address indexed _to, uint256 _value);

    event GrantRevoked(address indexed _holder, uint256 _refund);

    /**
     * @dev Constructor that initializes the address of the CoyToken contract.
     * @param _token CoyToken The address of the previously deployed CoyToken contract.
     */
    constructor(ERC20 _token) public {
        require(_token != address(0), "Token must exist and cannot be 0 address.");
        
        token = _token;
    }
    
    /**
     * @dev Unlock vested tokens and transfer them to their holder.
     */
    function unlockVestedTokens() external {
        Grant storage grant_ = grants[msg.sender];

        // Require that the grant is not empty.
        require(grant_.value != 0);
        
        // Get the total amount of vested tokens, according to grant.
        uint256 vested = calculateVestedTokens(grant_, block.timestamp);
        
        if (vested == 0) {
            return;
        }
        
        // Make sure the holder doesn't transfer more than what he already has.
        
        uint256 transferable = vested.sub(grant_.transferred);
        
        if (transferable == 0) {
            return;
        }
        
        // Update transferred and total vesting amount, then transfer remaining vested funds to holder.
        grant_.transferred = grant_.transferred.add(transferable);
        totalVesting = totalVesting.sub(transferable);
        
        token.safeTransfer(msg.sender, transferable);

        emit TokensUnlocked(msg.sender, transferable);
    }

    /**
     * @dev Grant tokens to a specified address. Please note, that the trustee must have enough ungranted tokens
     * to accomodate the new grant. Otherwise, the call with fail.
     * @param _to address The holder address.
     * @param _value uint256 The amount of tokens to be granted.
     * @param _start uint256 The beginning of the vesting period.
     * @param _cliff uint256 Point in time of the end of the cliff period (when the first installment is made).
     * @param _end uint256 The end of the vesting period.
     * @param _installmentLength uint256 The length of each vesting installment (in seconds).
     * @param _revocable bool Whether the grant is revocable or not.
     */
    function granting(address _to, uint256 _value, uint256 _start, uint256 _cliff, uint256 _end,
    uint256 _installmentLength, bool _revocable)
    external onlyOwner 
    {    
        require(_to != address(0));
        
        // Don't allow holder to be this contract.
        require(_to != address(this));
        
        require(_value > 0);
        
        // Require that every holder can be granted tokens only once.
        require(grants[_to].value == 0);
        
        // Require for time ranges to be consistent and valid.
        require(_start <= _cliff && _cliff <= _end);
        
        // Require installment length to be valid and no longer than (end - start).
        require(_installmentLength > 0 && _installmentLength <= _end.sub(_start));
        
        // Grant must not exceed the total amount of tokens currently available for vesting.
        require(totalVesting.add(_value) <= token.balanceOf(address(this)));
        
        // Assign a new grant.
        grants[_to] = Grant({
            value: _value,
            start: _start,
            cliff: _cliff,
            end: _end,
            installmentLength: _installmentLength,
            transferred: 0,
            revocable: _revocable
        });
        
        // Since tokens have been granted, increase the total amount available for vesting.
        totalVesting = totalVesting.add(_value);
        
        emit NewGrant(msg.sender, _to, _value);
    }
    
    /**
     * @dev Calculate the total amount of vested tokens of a holder at a given time.
     * @param _holder address The address of the holder.
     * @param _time uint256 The specific time to calculate against.
     * @return a uint256 Representing a holder's total amount of vested tokens.
     */
    function vestedTokens(address _holder, uint256 _time) external view returns (uint256) {
        Grant memory grant_ = grants[_holder];
        if (grant_.value == 0) {
            return 0;
        }
        return calculateVestedTokens(grant_, _time);
    }

    /** 
     * @dev Revoke the grant of tokens of a specifed address.
     * @param _holder The address which will have its tokens revoked.
     */
    function revoke(address _holder) public onlyOwner {
        Grant memory grant_ = grants[_holder];

        // Grant must be revocable.
        require(grant_.revocable);

        // Calculate amount of remaining tokens that are still available (i.e. not yet vested) to be returned to owner.
        uint256 vested = calculateVestedTokens(grant_, block.timestamp);
        
        uint256 notTransferredInstallment = vested.sub(grant_.transferred);
        
        uint256 refund = grant_.value.sub(vested);
        
        //Update of transferred not necessary due to deletion of the grant in the following step.
        
        // Remove grant information.
        delete grants[_holder];
        
        // Update total vesting amount and transfer previously calculated tokens to owner.
        totalVesting = totalVesting.sub(refund).sub(notTransferredInstallment);
        
        // Transfer vested amount that was not yet transferred to _holder.
        token.safeTransfer(_holder, notTransferredInstallment);
        
        emit TokensUnlocked(_holder, notTransferredInstallment);
        
        token.safeTransfer(msg.sender, refund);
        
        emit TokensUnlocked(msg.sender, refund);
        
        emit GrantRevoked(_holder, refund);
    }

    /**
     * @dev Calculate amount of vested tokens at a specifc time.
     * @param _grant Grant The vesting grant.
     * @param _time uint256 The time to be checked
     * @return a uint256 Representing the amount of vested tokens of a specific grant.
     */
    function calculateVestedTokens(Grant _grant, uint256 _time) private pure returns (uint256) {
        // If we're before the cliff, then nothing is vested.
        if (_time < _grant.cliff) {
            return 0;
        }
       
        // If we're after the end of the vesting period - everything is vested;
        if (_time >= _grant.end) {
            return _grant.value;
        }
       
        // Calculate amount of installments past until now.
        // NOTE result gets floored because of integer division.
        uint256 installmentsPast = _time.sub(_grant.start).div(_grant.installmentLength);
       
        // Calculate amount of days in entire vesting period.
        uint256 vestingDays = _grant.end.sub(_grant.start);
       
        // Calculate and return installments that have passed according to vesting days that have passed.
        return _grant.value.mul(installmentsPast.mul(_grant.installmentLength)).div(vestingDays);
    }
}