pragma solidity ^0.4.24;


/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
  address public owner;


  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


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
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param newOwner The address to transfer ownership to.
   */
  function transferOwnership(address newOwner) public onlyOwner {
    require(newOwner != address(0));
    emit OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }

}

interface SimpleDatabaseInterface {
  function set(string variable, address value) external returns (bool);
  function get(string variable) external view returns (address);
}

library QueryDB {
  function getAddress(address _db, string _name) internal view returns (address) {
    return SimpleDatabaseInterface(_db).get(_name);
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
  function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
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

/**
 * @title Elliptic curve signature operations
 * @dev Based on https://gist.github.com/axic/5b33912c6f61ae6fd96d6c4a47afde6d
 * TODO Remove this library once solidity supports passing a signature to ecrecover.
 * See https://github.com/ethereum/solidity/issues/864
 */

library ECDSA {
    /**
     * @dev Recover signer address from a message by using their signature
     * @param hash bytes32 message, the hash is the signed message. What is recovered is the signer address.
     * @param signature bytes signature, the signature is generated using web3.eth.sign()
     */
    function recover(bytes32 hash, bytes signature) internal pure returns (address) {
        bytes32 r;
        bytes32 s;
        uint8 v;

        // Check the signature length
        if (signature.length != 65) {
            return (address(0));
        }

        // Divide the signature in r, s and v variables
        // ecrecover takes the signature parameters, and the only way to get them
        // currently is to use assembly.
        // solium-disable-next-line security/no-inline-assembly
        assembly {
            r := mload(add(signature, 0x20))
            s := mload(add(signature, 0x40))
            v := byte(0, mload(add(signature, 0x60)))
        }

        // Version of signature should be 27 or 28, but 0 and 1 are also possible versions
        if (v < 27) {
            v += 27;
        }

        // If the version is correct return the signer address
        if (v != 27 && v != 28) {
            return (address(0));
        } else {
            // solium-disable-next-line arg-overflow
            return ecrecover(hash, v, r, s);
        }
    }

    /**
     * toEthSignedMessageHash
     * @dev prefix a bytes32 value with "\x19Ethereum Signed Message:"
     * and hash the result
     */
    function toEthSignedMessageHash(bytes32 hash) internal pure returns (bytes32) {
        // 32 is the length in bytes of hash,
        // enforced by the type signature above
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
    }
}

interface TokenInterface {
  function balanceOf(address who) external view returns (uint256);
  function transfer(address to, uint256 value) external returns (bool);
  function allowance(address owner, address spender) external view returns (uint256);
  function transferFrom(address from, address to, uint256 value) external returns (bool);
  function approve(address spender, uint256 value) external returns (bool);
}

contract Redeemer is Ownable {
  using SafeMath for uint256;
  using QueryDB for address;

  // Need this struct because of stack too deep error
  struct Code {
    address user;
    uint256 value;
    uint256 unlockTimestamp;
    uint256 entropy;
    bytes signature;
    bool deactivated;
    uint256 velocity;
  }

  address public DB;
  address[] public SIGNERS;

  mapping(bytes32 => Code) public codes;

  event AddSigner(address indexed owner, address signer);
  event RemoveSigner(address indexed owner, address signer);
  event RevokeAllToken(address indexed owner, address recipient, uint256 value);
  event SupportUser(address indexed owner, address indexed user, uint256 value, uint256 unlockTimestamp, uint256 entropy, bytes signature, uint256 velocity);
  event DeactivateCode(address indexed owner, address indexed user, uint256 value, uint256 unlockTimestamp, uint256 entropy, bytes signature);
  event Redeem(address indexed user, uint256 value, uint256 unlockTimestamp, uint256 entropy, bytes signature, uint256 velocity);

  /**
   * Constructor
   */
  constructor (address _db) public {
    DB = _db;
    SIGNERS = [msg.sender];
  }


  /**
   * Modifiers
   */
  modifier isValidCode(Code _code) {
    bytes32 _hash = hash(_code);
    require(!codes[_hash].deactivated, "Deactivated code.");
    require(now >= _code.unlockTimestamp, "Lock time is not over.");
    require(validateSignature(_hash, _code.signature), "Invalid signer.");
    _;
  }

  modifier isValidCodeOwner(address _codeOwner) {
    require(_codeOwner != address(0), "Invalid sender.");
    require(msg.sender == _codeOwner, "Invalid sender.");
    _;
  }

  modifier isValidBalance(uint256 _value) {
    require(_value <= myBalance(), "Not enough balance.");
    _;
  }

  modifier isValidAddress(address _who) {
    require(_who != address(0), "Invalid address.");
    _;
  }


  /**
   * Private functions
   */
  
  // Hash function
  function hash(Code _code) private pure returns (bytes32) {
    return keccak256(abi.encode(_code.user, _code.value, _code.unlockTimestamp, _code.entropy));
  }

  // Check signature
  function validateSignature(bytes32 _hash, bytes _signature) private view returns (bool) {
    address _signer = ECDSA.recover(_hash, _signature);
    return signerExists(_signer);
  }

  // Transfer KAT
  function transferKAT(address _to, uint256 _value) private returns (bool) {
    bool ok = TokenInterface(DB.getAddress("TOKEN")).transfer(_to, _value);
    if(!ok) return false;
    return true;    
  }


  /**
   * Management functions
   */

  // Balance of KAT
  function myBalance() public view returns (uint256) {
     return TokenInterface(DB.getAddress("TOKEN")).balanceOf(address(this));
  }
  
  // Check address whether is in signer list
  function signerExists(address _signer) public view returns (bool) {
    if(_signer == address(0)) return false;
    for(uint256 i = 0; i < SIGNERS.length; i++) {
      if(_signer == SIGNERS[i]) return true;
    }
    return false;
  }

  // Add a signer
  function addSigner(address _signer) public onlyOwner isValidAddress(_signer) returns (bool) {
    if(signerExists(_signer)) return true;
    SIGNERS.push(_signer);
    emit AddSigner(msg.sender, _signer);
    return true;
  }

  // Remove a signer
  function removeSigner(address _signer) public onlyOwner isValidAddress(_signer) returns (bool) {
    for(uint256 i = 0; i < SIGNERS.length; i++) {
      if(_signer == SIGNERS[i]) {
        SIGNERS[i] = SIGNERS[SIGNERS.length - 1];
        delete SIGNERS[SIGNERS.length - 1];
        emit RemoveSigner(msg.sender, _signer);
        return true;
      }
    }
    return true;
  }

  // Revoke all KAT in case
  function revokeAllToken(address _recipient) public onlyOwner returns (bool) {
    uint256 _value = myBalance();
    emit RevokeAllToken(msg.sender, _recipient, _value);
    return transferKAT(_recipient, _value);
  }

  // Kambria manually supports user in case they don't controll
  function supportUser(
    address _user,
    uint256 _value,
    uint256 _unlockTimestamp,
    uint256 _entropy,
    bytes _signature
  )
    public
    onlyOwner
    isValidCode(Code(_user, _value, _unlockTimestamp, _entropy, _signature, false, 0))
    returns (bool)
  {
    uint256 _velocity = now - _unlockTimestamp;
    Code memory _code = Code(_user, _value, _unlockTimestamp, _entropy, _signature, true, _velocity);
    bytes32 _hash = hash(_code);
    codes[_hash] = _code;
    emit SupportUser(msg.sender, _code.user, _code.value, _code.unlockTimestamp, _code.entropy, _code.signature, _code.velocity);
    return transferKAT(_code.user, _code.value);
  }

  // Kambria manually deactivate code
  function deactivateCode(
    address _user,
    uint256 _value,
    uint256 _unlockTimestamp,
    uint256 _entropy,
    bytes _signature
  ) 
    public
    onlyOwner
    returns (bool)
  {
    Code memory _code = Code(_user, _value, _unlockTimestamp, _entropy, _signature, true, 0);
    bytes32 _hash = hash(_code);
    codes[_hash] = _code;
    emit DeactivateCode(msg.sender, _code.user, _code.value, _code.unlockTimestamp, _code.entropy, _code.signature);
    return true;
  }

  /**
   * User functions
   */
  
  // Redeem
  function redeem(
    address _user,
    uint256 _value,
    uint256 _unlockTimestamp,
    uint256 _entropy,
    bytes _signature
  )
    public
    isValidBalance(_value)
    isValidCodeOwner(_user)
    isValidCode(Code(_user, _value, _unlockTimestamp, _entropy, _signature, false, 0))
    returns (bool)
  {
    uint256 _velocity = now - _unlockTimestamp;
    Code memory _code = Code(_user, _value, _unlockTimestamp, _entropy, _signature, true, _velocity);
    bytes32 _hash = hash(_code);
    codes[_hash] = _code;
    emit Redeem(_code.user, _code.value, _code.unlockTimestamp, _code.entropy, _code.signature, _code.velocity);
    return transferKAT(_code.user, _code.value);
  }
}