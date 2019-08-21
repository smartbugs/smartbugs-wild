pragma solidity 0.4.25;

// File: openzeppelin-solidity/contracts/cryptography/ECDSA.sol

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
  function recover(bytes32 hash, bytes signature)
    internal
    pure
    returns (address)
  {
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
  function toEthSignedMessageHash(bytes32 hash)
    internal
    pure
    returns (bytes32)
  {
    // 32 is the length in bytes of hash,
    // enforced by the type signature above
    return keccak256(
      abi.encodePacked("\x19Ethereum Signed Message:\n32", hash)
    );
  }
}

// File: contracts/Web3Provider.sol

contract Web3Provider {
    
    using ECDSA for bytes32;
    
    uint256 constant public REQUEST_PRICE = 100 wei;
    
    uint256 public clientDeposit;
    uint256 public chargedService;
    address public clientAddress;
    address public web3provider;
    uint256 public timelock;
    bool public charged;
    
    
    constructor() public {
        web3provider = msg.sender;
    }
    
    function() external {}
    
    function subscribeForProvider()
        external
        payable
    {
        require(clientAddress == address(0));
        require(msg.value % REQUEST_PRICE == 0);
        
        clientDeposit = msg.value;
        clientAddress = msg.sender;
        timelock = now + 1 days;
    }
    
    function chargeService(uint256 _amountRequests, bytes _sig) 
        external
    {
        require(charged == false);
        require(now <= timelock);
        require(msg.sender == web3provider);
        
        bytes32 hash = keccak256(abi.encodePacked(_amountRequests));
        require(hash.recover(_sig) == clientAddress);
        chargedService = _amountRequests*REQUEST_PRICE;
        require(chargedService <= clientDeposit);
        charged = true;
        web3provider.transfer(chargedService);
    }
    
    function withdrawDeposit()
        external
    {
        require(msg.sender == clientAddress);
        require(now > timelock);
        clientAddress.transfer(address(this).balance);
    }
}