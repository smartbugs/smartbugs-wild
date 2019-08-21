// File: openzeppelin-solidity/contracts/ownership/Ownable.sol

pragma solidity ^0.4.24;


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

// File: openzeppelin-solidity/contracts/token/ERC20/ERC20Basic.sol

pragma solidity ^0.4.24;


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

pragma solidity ^0.4.24;



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

// File: contracts/promocode/PromoCode.sol

pragma solidity ^0.4.24;



contract PromoCode is Ownable {
  ERC20 public token;
  mapping(bytes32 => bool) public used;
  uint256 public amount;

  event Redeem(address user, uint256 amount, string code);

  function PromoCode(ERC20 _token, uint256 _amount) {
    amount = _amount;
    token = _token;
  }

  function setAmount(uint256 _amount) onlyOwner {
    amount = _amount;
  }

  function redeem(string promoCode, bytes signature) {
    bytes32 hash = keccak256(abi.encodePacked(promoCode));
    bytes32 r;
    bytes32 s;
    uint8 v;
    assembly {
      r := mload(add(signature, 32))
      s := mload(add(signature, 64))
      v := and(mload(add(signature, 65)), 255)
    }
    if (v < 27) v += 27;

    require(!used[hash]);
    used[hash] = true;
    require(verifyString(promoCode, v, r, s) == owner);
    address user = msg.sender;
    require(token.transferFrom(owner, user, amount));
    emit Redeem(user, amount, promoCode);
  }

  // https://blog.ricmoo.com/verifying-messages-in-solidity-50a94f82b2ca
  // Returns the address that signed a given string message
  function verifyString(string message, uint8 v, bytes32 r, bytes32 s) public pure returns (address signer) {
    // The message header; we will fill in the length next
    string memory header = "\x19Ethereum Signed Message:\n000000";
    uint256 lengthOffset;
    uint256 length;
    assembly {
    // The first word of a string is its length
      length := mload(message)
    // The beginning of the base-10 message length in the prefix
      lengthOffset := add(header, 57)
    }
    // Maximum length we support
    require(length <= 999999);
    // The length of the message's length in base-10
    uint256 lengthLength = 0;
    // The divisor to get the next left-most message length digit
    uint256 divisor = 100000;
    // Move one digit of the message length to the right at a time
    while (divisor != 0) {
      // The place value at the divisor
      uint256 digit = length / divisor;
      if (digit == 0) {
        // Skip leading zeros
        if (lengthLength == 0) {
          divisor /= 10;
          continue;
        }
      }
      // Found a non-zero digit or non-leading zero digit
      lengthLength++;
      // Remove this digit from the message length's current value
      length -= digit * divisor;
      // Shift our base-10 divisor over
      divisor /= 10;

      // Convert the digit to its ASCII representation (man ascii)
      digit += 0x30;
      // Move to the next character and write the digit
      lengthOffset++;
      assembly {
        mstore8(lengthOffset, digit)
      }
    }
    // The null string requires exactly 1 zero (unskip 1 leading 0)
    if (lengthLength == 0) {
      lengthLength = 1 + 0x19 + 1;
    } else {
      lengthLength += 1 + 0x19;
    }
    // Truncate the tailing zeros from the header
    assembly {
      mstore(header, lengthLength)
    }
    // Perform the elliptic curve recover operation
    bytes32 check = keccak256(header, message);
    return ecrecover(check, v, r, s);
  }
}