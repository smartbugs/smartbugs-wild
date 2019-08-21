pragma solidity ^0.4.25;


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
 * @title Pausable
 * @dev Base contract which allows children to implement an emergency stop mechanism.
 */
contract Pausable is Ownable {
  event Pause();
  event Unpause();

  bool public paused = false;


  /**
   * @dev Modifier to make a function callable only when the contract is not paused.
   */
  modifier whenNotPaused() {
    require(!paused);
    _;
  }

  /**
   * @dev Modifier to make a function callable only when the contract is paused.
   */
  modifier whenPaused() {
    require(paused);
    _;
  }

  /**
   * @dev called by the owner to pause, triggers stopped state
   */
  function pause() public onlyOwner whenNotPaused {
    paused = true;
    emit Pause();
  }

  /**
   * @dev called by the owner to unpause, returns to normal state
   */
  function unpause() public onlyOwner whenPaused {
    paused = false;
    emit Unpause();
  }
}





/**
 * @title Elliptic curve signature operations
 * @dev Based on https://gist.github.com/axic/5b33912c6f61ae6fd96d6c4a47afde6d
 * TODO Remove this library once solidity supports passing a signature to ecrecover.
 * See https://github.com/ethereum/solidity/issues/864
 */

library ECRecovery {

  /**
   * @dev Recover signer address from a message by using their signature
   * @param _hash bytes32 message, the hash is the signed message. What is recovered is the signer address.
   * @param _sig bytes signature, the signature is generated using web3.eth.sign()
   */
  function recover(bytes32 _hash, bytes _sig)
    internal
    pure
    returns (address)
  {
    bytes32 r;
    bytes32 s;
    uint8 v;

    // Check the signature length
    if (_sig.length != 65) {
      return (address(0));
    }

    // Divide the signature in r, s and v variables
    // ecrecover takes the signature parameters, and the only way to get them
    // currently is to use assembly.
    // solium-disable-next-line security/no-inline-assembly
    assembly {
      r := mload(add(_sig, 32))
      s := mload(add(_sig, 64))
      v := byte(0, mload(add(_sig, 96)))
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
      return ecrecover(_hash, v, r, s);
    }
  }

  /**
   * toEthSignedMessageHash
   * @dev prefix a bytes32 value with "\x19Ethereum Signed Message:"
   * and hash the result
   */
  function toEthSignedMessageHash(bytes32 _hash)
    internal
    pure
    returns (bytes32)
  {
    // 32 is the length in bytes of hash,
    // enforced by the type signature above
    return keccak256(
      abi.encodePacked("\x19Ethereum Signed Message:\n32", _hash)
    );
  }
}



contract ETHDenverStaking is Ownable, Pausable {

    using ECRecovery for bytes32;

    event UserStake(address userUportAddress, address userMetamaskAddress, uint amountStaked);
    event UserRecoupStake(address userUportAddress, address userMetamaskAddress, uint amountStaked);

    // Debug events
    event debugBytes32(bytes32 _msg);
    event debugBytes(bytes _msg);
    event debugString(string _msg);
    event debugAddress(address _address);

    // ETHDenver will need to authorize staking and recouping.
    address public grantSigner;

    // End of the event, when staking can be sweeped
    uint public finishDate;

    // uPortAddress => walletAddress
    mapping (address => address) public userStakedAddress;

    // ETH amount staked by a given uPort address
    mapping (address => uint256) public stakedAmount;


    constructor(address _grantSigner, uint _finishDate) public {
        grantSigner = _grantSigner;
        finishDate = _finishDate;
    }

    // Public functions

    // function allow the staking for a participant
    function stake(address _userUportAddress, uint _expiryDate, bytes _signature) public payable whenNotPaused {
        bytes32 hashMessage = keccak256(abi.encodePacked(_userUportAddress, msg.value, _expiryDate));
        address signer = hashMessage.toEthSignedMessageHash().recover(_signature);

        require(signer == grantSigner, "Signature is not valid");
        require(block.timestamp < _expiryDate, "Grant is expired");
        require(userStakedAddress[_userUportAddress] == 0, "User has already staked!");

        userStakedAddress[_userUportAddress] = msg.sender;
        stakedAmount[_userUportAddress] = msg.value;

        emit UserStake(_userUportAddress, msg.sender, msg.value);
    }

    // function allow the staking for a participant
    function recoupStake(address _userUportAddress, uint _expiryDate, bytes _signature) public whenNotPaused {
        bytes32 hashMessage = keccak256(abi.encodePacked(_userUportAddress, _expiryDate));
        address signer = hashMessage.toEthSignedMessageHash().recover(_signature);

        require(signer == grantSigner, "Signature is not valid");
        require(block.timestamp < _expiryDate, "Grant is expired");
        require(userStakedAddress[_userUportAddress] != 0, "User has not staked!");

        address stakedBy = userStakedAddress[_userUportAddress];
        uint256 amount = stakedAmount[_userUportAddress];
        userStakedAddress[_userUportAddress] = address(0x0);
        stakedAmount[_userUportAddress] = 0;

        stakedBy.transfer(amount);

        emit UserRecoupStake(_userUportAddress, stakedBy, amount);
    }

    // Owner functions

    function setGrantSigner(address _signer) public onlyOwner {
        require(_signer != address(0x0), "address is null");
        grantSigner = _signer;
    }

    function sweepStakes() public onlyOwner {
        require(block.timestamp > finishDate, "EthDenver is not over yet!");
        owner.transfer(address(this).balance);
    }

}