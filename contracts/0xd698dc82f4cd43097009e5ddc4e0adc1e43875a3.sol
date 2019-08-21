pragma solidity 0.4.24;

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

// File: contracts/Vault12LockedTokens.sol

contract Vault12LockedTokens {
    using SafeMath for uint256;
    uint256 constant internal SECONDS_PER_YEAR = 31561600;

    modifier onlyV12MultiSig {
        require(msg.sender == v12MultiSig, "not owner");
        _;
    }

    modifier onlyValidAddress(address _recipient) {
        require(_recipient != address(0) && _recipient != address(this) && _recipient != address(token), "not valid _recipient");
        _;
    }

    struct Grant {
        uint256 startTime;
        uint256 amount;
        uint256 vestingDuration;
        uint256 yearsClaimed;
        uint256 totalClaimed;
    }

    event GrantAdded(address recipient, uint256 amount);
    event GrantTokensClaimed(address recipient, uint256 amountClaimed);
    event ChangedMultisig(address multisig);

    ERC20 public token;
    
    mapping (address => Grant) public tokenGrants;
    address public v12MultiSig;

    constructor(ERC20 _token) public {
        require(address(_token) != address(0));
        v12MultiSig = msg.sender;
        token = _token;
    }
    
    function addTokenGrant(
        address _recipient,
        uint256 _startTime,
        uint256 _amount,
        uint256 _vestingDurationInYears
    )
        onlyV12MultiSig
        onlyValidAddress(_recipient)
        external
    {
        require(!grantExist(_recipient), "grant already exist");
        require(_vestingDurationInYears <= 25, "more than 25 years");
        uint256 amountVestedPerYear = _amount.div(_vestingDurationInYears);
        require(amountVestedPerYear > 0, "amountVestedPerYear > 0");

        // Transfer the grant tokens under the control of the vesting contract
        require(token.transferFrom(msg.sender, address(this), _amount), "transfer failed");

        Grant memory grant = Grant({
            startTime: _startTime == 0 ? currentTime() : _startTime,
            amount: _amount,
            vestingDuration: _vestingDurationInYears,
            yearsClaimed: 0,
            totalClaimed: 0
        });
        tokenGrants[_recipient] = grant;
        emit GrantAdded(_recipient, _amount);
    }

    /// @notice Calculate the vested and unclaimed months and tokens available for `_grantId` to claim
    /// Due to rounding errors once grant duration is reached, returns the entire left grant amount
    /// Returns (0, 0) if cliff has not been reached
    function calculateGrantClaim(address _recipient) public view returns (uint256, uint256) {
        Grant storage tokenGrant = tokenGrants[_recipient];

        // For grants created with a future start date, that hasn't been reached, return 0, 0
        if (currentTime() < tokenGrant.startTime) {
            return (0, 0);
        }

        uint256 elapsedTime = currentTime().sub(tokenGrant.startTime);
        uint256 elapsedYears = elapsedTime.div(SECONDS_PER_YEAR);
        
        // If over vesting duration, all tokens vested
        if (elapsedYears >= tokenGrant.vestingDuration) {
            uint256 remainingGrant = tokenGrant.amount.sub(tokenGrant.totalClaimed);
            uint256 remainingYears = tokenGrant.vestingDuration.sub(tokenGrant.yearsClaimed);
            return (remainingYears, remainingGrant);
        } else {
            uint256 i = 0;
            uint256 tokenGrantAmount = tokenGrant.amount;
            uint256 totalVested = 0;
            for(i; i < elapsedYears; i++){
                totalVested = (tokenGrantAmount.mul(10)).div(100).add(totalVested); 
                tokenGrantAmount = tokenGrant.amount.sub(totalVested);
            }
            uint256 amountVested = totalVested.sub(tokenGrant.totalClaimed);
            return (elapsedYears, amountVested);
        }
    }

    /// @notice Allows a grant recipient to claim their vested tokens. Errors if no tokens have vested
    /// It is advised recipients check they are entitled to claim via `calculateGrantClaim` before calling this
    function claimVestedTokens(address _recipient) external {
        uint256 yearsVested;
        uint256 amountVested;
        (yearsVested, amountVested) = calculateGrantClaim(_recipient);
        require(amountVested > 0, "amountVested is 0");

        Grant storage tokenGrant = tokenGrants[_recipient];
        tokenGrant.yearsClaimed = yearsVested;
        tokenGrant.totalClaimed = tokenGrant.totalClaimed.add(amountVested);
        
        require(token.transfer(_recipient, amountVested), "no tokens");
        emit GrantTokensClaimed(_recipient, amountVested);
    }

    function currentTime() public view returns(uint256) {
        return block.timestamp;
    }

    function changeMultiSig(address _newMultisig) 
        external 
        onlyV12MultiSig
        onlyValidAddress(_newMultisig)
    {
        v12MultiSig = _newMultisig;
        emit ChangedMultisig(_newMultisig);
    }

    function grantExist(address _recipient) public view returns(bool) {
        return tokenGrants[_recipient].amount > 0;
    }

}