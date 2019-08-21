pragma solidity ^0.4.24;

/// @title Smart contract for forwarding ETH to a pre-defined recipient in the passive mode i.e. someone has to trigger the transfer.
/// It also allows recipient to call any smart contracts. For example: Calling Trustcoin smart contract to transfer TRST.
/// @author WeTrustPlatform
contract PassiveForwarder {
  /// @dev recipient must be a normal account or a smart contract with the standard payable fallback method.
  /// Otherwise, fund will be stuck!
  address public recipient;

  event Received(address indexed sender, uint256 value);

  constructor(address _recipient) public {
    recipient = _recipient;
  }

  function () public payable {
    require(msg.value > 0);
    emit Received(msg.sender, msg.value);
  }

  function sweep() public {
    recipient.transfer(address(this).balance);
  }

  /// @dev Courtesy of https://github.com/gnosis/MultiSigWallet/blob/master/contracts/MultiSigWallet.sol
  /// This method allows the pre-defined recipient to call other smart contracts.
  function externalCall(address destination, uint256 value, bytes data) public returns (bool) {
    require(msg.sender == recipient, "Sender must be the recipient.");
    uint256 dataLength = data.length;
    bool result;
    assembly {
      let x := mload(0x40)   // "Allocate" memory for output (0x40 is where "free memory" pointer is stored by convention)
      let d := add(data, 32) // First 32 bytes are the padded length of data, so exclude that
      result := call(
        sub(gas, 34710),     // 34710 is the value that solidity is currently emitting
                             // It includes callGas (700) + callVeryLow (3, to pay for SUB) + callValueTransferGas (9000) +
                             // callNewAccountGas (25000, in case the destination address does not exist and needs creating)
        destination,
        value,
        d,
        dataLength,          // Size of the input (in bytes) - this is what fixes the padding problem
        x,
        0                    // Output is ignored, therefore the output size is zero
      )
    }
    return result;
  }
}


/// @dev This contract is used for creating the Forwarder.
/// It also keeps track of all the Forwarders and their recipients
contract PassiveForwarderFactory {

  address public owner;

  /// @dev This will generate a public getter with two parameters
  /// recipient address and contract index
  mapping(address => address[]) public recipients;

  event Created(address indexed recipient, address indexed newContract);

  constructor(address _owner) public {
    owner = _owner;
  }

  function create(address recipient) public returns (address){
    require(msg.sender == owner, "Sender must be the owner.");

    PassiveForwarder pf = new PassiveForwarder(recipient);
    recipients[recipient].push(pf);
    emit Created(recipient, pf);
    return pf;
  }

  /// @dev This method helps iterate through the recipients mapping
  function getNumberOfContracts(address recipient) public view returns (uint256) {
    return recipients[recipient].length;
  }
}