pragma solidity 0.4.24;

// File: @tokenfoundry/sale-contracts/contracts/interfaces/DisbursementHandlerI.sol

interface DisbursementHandlerI {
    function withdraw(address _beneficiary, uint256 _index) external;
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
  function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
    // Gas optimization: this is cheaper than asserting 'a' not being zero, but the
    // benefit is lost if 'b' is also tested.
    // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
    if (a == 0) {
      return 0;
    }

    c = a * b;
    assert(c / a == b);
    return c;
  }

  /**
  * @dev Integer division of two numbers, truncating the quotient.
  */
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    // uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return a / b;
  }

  /**
  * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
  */
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  /**
  * @dev Adds two numbers, throws on overflow.
  */
  function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
    c = a + b;
    assert(c >= a);
    return c;
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

// File: openzeppelin-solidity/contracts/token/ERC20/ERC20Basic.sol

/**
 * @title ERC20Basic
 * @dev Simpler version of ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/179
 */
contract ERC20Basic {
  function totalSupply() public view returns (uint256);
  function balanceOf(address who) public view returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}

// File: openzeppelin-solidity/contracts/token/ERC20/ERC20.sol

/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender)
    public view returns (uint256);

  function transferFrom(address from, address to, uint256 value)
    public returns (bool);

  function approve(address spender, uint256 value) public returns (bool);
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
  function safeTransfer(ERC20Basic token, address to, uint256 value) internal {
    require(token.transfer(to, value));
  }

  function safeTransferFrom(
    ERC20 token,
    address from,
    address to,
    uint256 value
  )
    internal
  {
    require(token.transferFrom(from, to, value));
  }

  function safeApprove(ERC20 token, address spender, uint256 value) internal {
    require(token.approve(spender, value));
  }
}

// File: @tokenfoundry/sale-contracts/contracts/DisbursementHandler.sol

/// @title Disbursement handler - Manages time locked disbursements of ERC20 tokens
contract DisbursementHandler is DisbursementHandlerI, Ownable {
    using SafeMath for uint256;
    using SafeERC20 for ERC20;

    struct Disbursement {
        // Tokens cannot be withdrawn before this timestamp
        uint256 timestamp;

        // Amount of tokens to be disbursed
        uint256 value;
    }

    event Setup(address indexed _beneficiary, uint256 _timestamp, uint256 _value);
    event TokensWithdrawn(address indexed _to, uint256 _value);

    ERC20 public token;
    uint256 public totalAmount;
    mapping(address => Disbursement[]) public disbursements;

    bool public closed;

    modifier isOpen {
        require(!closed, "Disbursement Handler is closed");
        _;
    }

    modifier isClosed {
        require(closed, "Disbursement Handler is open");
        _;
    }


    constructor(ERC20 _token) public {
        require(_token != address(0), "Token cannot have address 0");
        token = _token;
    }

    /// @dev Called to create disbursements.
    /// @param _beneficiaries The addresses of the beneficiaries.
    /// @param _values The number of tokens to be locked for each disbursement.
    /// @param _timestamps Funds will be locked until this timestamp for each disbursement.
    function setupDisbursements(
        address[] _beneficiaries,
        uint256[] _values,
        uint256[] _timestamps
    )
        external
        onlyOwner
        isOpen
    {
        require((_beneficiaries.length == _values.length) && (_beneficiaries.length == _timestamps.length), "Arrays not of equal length");
        require(_beneficiaries.length > 0, "Arrays must have length > 0");

        for (uint256 i = 0; i < _beneficiaries.length; i++) {
            setupDisbursement(_beneficiaries[i], _values[i], _timestamps[i]);
        }
    }

    function close() external onlyOwner isOpen {
        closed = true;
    }

    /// @dev Called by the sale contract to create a disbursement.
    /// @param _beneficiary The address of the beneficiary.
    /// @param _value Amount of tokens to be locked.
    /// @param _timestamp Funds will be locked until this timestamp.
    function setupDisbursement(
        address _beneficiary,
        uint256 _value,
        uint256 _timestamp
    )
        internal
    {
        require(block.timestamp < _timestamp, "Disbursement timestamp in the past");
        disbursements[_beneficiary].push(Disbursement(_timestamp, _value));
        totalAmount = totalAmount.add(_value);
        emit Setup(_beneficiary, _timestamp, _value);
    }

    /// @dev Transfers tokens to a beneficiary
    /// @param _beneficiary The address to transfer tokens to
    /// @param _index The index of the disbursement
    function withdraw(address _beneficiary, uint256 _index)
        external
        isClosed
    {
        Disbursement[] storage beneficiaryDisbursements = disbursements[_beneficiary];
        require(_index < beneficiaryDisbursements.length, "Supplied index out of disbursement range");

        Disbursement memory disbursement = beneficiaryDisbursements[_index];
        require(disbursement.timestamp < now && disbursement.value > 0, "Disbursement timestamp not reached, or disbursement value of 0");

        // Remove the withdrawn disbursement
        delete beneficiaryDisbursements[_index];

        token.safeTransfer(_beneficiary, disbursement.value);
        emit TokensWithdrawn(_beneficiary, disbursement.value);
    }
}