pragma solidity ^0.4.13;

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

contract ERC20Basic {
  function totalSupply() public view returns (uint256);
  function balanceOf(address _who) public view returns (uint256);
  function transfer(address _to, uint256 _value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}

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

contract TokenContinuousDistribution is Ownable {
    using SafeMath for uint256;
    using SafeERC20 for ERC20Basic;

    event Released(ERC20Basic token, uint256 amount);

    // beneficiary of tokens after they are released
    address public beneficiary;

    uint256 public cliff;
    uint256 public start;
    uint256 public endTime;
    // 1 day = 86400 seconds
    uint256 public secondsIn1Unit = 86400;
    // 365 days * 5 = 1825 time units
    uint256 public numberOfUnits = 1825;
    // 86400 * 1825
    uint256 public duration = 157680000;

    //1st interval gets 5/15*total balance allowed, 2nd gets 4/15*TBA, 3rd gets 3*TBA, 4th gets 2*TBA, 5th gets 1*TBA
    uint256 numberOfPhases = 5;
    // 15=5+4+3+2+1
    uint256 slice = 15;

    mapping(address => uint256) public released;

    /**
     * @dev Creates a continuous distribution contract that distributes its balance of any ERC20 token to the
     * _beneficiary, gradually in a linear fashion until _start + _duration,
     * where _duration is the result of secondsIn1Unit*numberOfUnits
     * By then all of the balance will have distributed.
     * @param _beneficiary address of the beneficiary to whom distributed tokens are transferred
     * @param _start the time (as Unix time) at which point continuous distribution starts
     * @param _cliff duration in seconds of the cliff in which tokens will begin to continuous-distribute
     */
    constructor(
        address _beneficiary,
        uint256 _start,
        uint256 _cliff
    )
    public
    {
        require(_beneficiary != address(0), "Beneficiary address should NOT be null.");
        require(_cliff <= duration, "Cliff should be less than or equal to duration (i.e. secondsIn1Unit.mul(numberOfUnits)).");
        require((numberOfUnits % 5) == 0, "numberOfUnits should be a multiple of 5");


        beneficiary = _beneficiary;
        cliff = _start.add(_cliff);
        start = _start;
        endTime = _start.add(duration);
    }

    /**
     * @notice Transfers distributed tokens to beneficiary.
     * @param token ERC20 token which is being distributed
     */
    function release(ERC20Basic token) public {
        uint256 unreleased = releasableAmount(token);

        require(unreleased > 0, "Unreleased amount should be larger than 0.");

        released[token] = released[token].add(unreleased);

        token.safeTransfer(beneficiary, unreleased);

        emit Released(token, unreleased);
    }

    /**
     * @dev Calculates the amount that has already distributed but hasn't been released yet.
     * @param token ERC20 token which is being distributed
     */
    function releasableAmount(ERC20Basic token) public view returns (uint256) {
        return distributedAmount(token).sub(released[token]);
    }

    /**
     * @dev Calculates the amount that has already distributed.
     * @param token ERC20 token which is being distributed
     */
    function distributedAmount(ERC20Basic token) public view returns (uint256) {
        uint256 blockTimestamp = block.timestamp;
        return distributedAmountWithBlockTimestamp(token, blockTimestamp);
    }


    function distributedAmountWithBlockTimestamp(ERC20Basic token, uint256 blockTimestamp) public view returns (uint256) {
        uint256 currentBalance = token.balanceOf(this);
        uint256 totalBalance = currentBalance.add(released[token]);

        if (blockTimestamp < cliff) {
            return 0;
        } else if (blockTimestamp >= endTime) {
            return totalBalance;
        } else {
            uint256 unitsPassed = blockTimestamp.sub(start).div(secondsIn1Unit); // number of time unit passed, remember unit is usually 'day'
            uint256 unitsIn1Phase = numberOfUnits.div(numberOfPhases); // remember unit is usually 'day'
            uint256 unitsInThisPhase;
            uint256 weight;

            if (unitsPassed < unitsIn1Phase) {
                weight = 5;
                unitsInThisPhase = unitsPassed;
                // delay division to last step to keep precision
                return unitsInThisPhase.mul(totalBalance).mul(weight).div(slice).div(unitsIn1Phase);
            } else if (unitsPassed < unitsIn1Phase.mul(2)) {
                weight = 4;
                unitsInThisPhase = unitsPassed.sub(unitsIn1Phase);
                // "5" because we have everything in the previous phase 
                // and note div(slice) is moved to the end, (x+y).div(slice) => x.div(slice).add(y.div(slice))
                return totalBalance.mul(5).add(unitsInThisPhase.mul(totalBalance).mul(weight).div(unitsIn1Phase)).div(slice);
            } else if (unitsPassed < unitsIn1Phase.mul(3)) {
                weight = 3;
                unitsInThisPhase = unitsPassed.sub(unitsIn1Phase.mul(2));
                // "9" because we have everything in the previous phase = 5+4
                // and note div(slice) is moved to the end, (x+y).div(slice) => x.div(slice).add(y.div(slice))
                return totalBalance.mul(9).add(unitsInThisPhase.mul(totalBalance).mul(weight).div(unitsIn1Phase)).div(slice);
            } else if (unitsPassed < unitsIn1Phase.mul(4)) {
                weight = 2;
                unitsInThisPhase = unitsPassed.sub(unitsIn1Phase.mul(3));
                // "12" because we have everything in the previous phase = 5+4+3
                // and note div(slice) is moved to the end, (x+y).div(slice) => x.div(slice).add(y.div(slice))
                return totalBalance.mul(12).add(unitsInThisPhase.mul(totalBalance).mul(weight).div(unitsIn1Phase)).div(slice);
            } else if (unitsPassed < unitsIn1Phase.mul(5)) {
                weight = 1;
                unitsInThisPhase = unitsPassed.sub(unitsIn1Phase.mul(4));
                // "14" because we have everything in the previous phase = 5+4+3+2
                // and note div(slice) is moved to the end, (x+y).div(slice) => x.div(slice).add(y.div(slice))
                return totalBalance.mul(14).add(unitsInThisPhase.mul(totalBalance).mul(weight).div(unitsIn1Phase)).div(slice);
            }
            require(blockTimestamp < endTime, "Block timestamp is expected to have not reached distribution endTime if the code even falls in here.");
        }
    }
}