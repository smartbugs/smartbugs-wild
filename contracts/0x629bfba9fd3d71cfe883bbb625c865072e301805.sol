pragma solidity ^0.4.4;

// mainnet: 0x629bfba9fd3d71cfe883bbb625c865072e301805

contract ERC223Token {
  function transfer(address _from, uint _value, bytes _data) public;
}

contract Operations {

  mapping (address => uint) public balances;
  mapping (address => bytes32) public activeCall;

  // remember who was call recipient based on callHash
  mapping (bytes32 => address) public recipientsMap;

  mapping (address => uint) public endCallRequestDate;

  uint endCallRequestDelay = 1 hours;

  ERC223Token public exy;

  function Operations() public {
    exy = ERC223Token(0xFA74F89A6d4a918167C51132614BbBE193Ee8c22);
  }

  // falback for EXY deposits
  function tokenFallback(address _from, uint _value, bytes _data) public {
    balances[_from] += _value;
  }

  function withdraw(uint value) public {
    // dont allow to withdraw any balance if user have active call
    require(activeCall[msg.sender] == 0x0);

    uint balance = balances[msg.sender];

    // requested value cant be greater than balance
    require(value <= balance);

    balances[msg.sender] -= value;
    bytes memory empty;
    exy.transfer(msg.sender, value, empty);
  }

  function startCall(uint timestamp, uint8 _v, bytes32 _r, bytes32 _s) public {
    // address caller == ecrecover(...)
    address recipient = msg.sender;
    bytes32 callHash = keccak256('Experty.io startCall:', recipient, timestamp);
    address caller = ecrecover(callHash, _v, _r, _s);

    // caller cant start more than 1 call
    require(activeCall[caller] == 0x0);

    // save callHash for this caller
    activeCall[caller] = callHash;
    recipientsMap[callHash] = recipient;

    // clean endCallRequestDate for this address
    // if it was set before
    endCallRequestDate[caller] = 0;
  }

  function endCall(bytes32 callHash, uint amount, uint8 _v, bytes32 _r, bytes32 _s) public {
    // get recipient from map using callHash
    address recipient = recipientsMap[callHash];

    // only recipient can push this transaction
    require(recipient == msg.sender);

    bytes32 endHash = keccak256('Experty.io endCall:', recipient, callHash, amount);
    address caller = ecrecover(endHash, _v, _r, _s);

    // check if call hash was created by caller
    require(activeCall[caller] == callHash);

    uint maxAmount = amount;
    if (maxAmount > balances[caller]) {
      maxAmount = balances[caller];
    }

    // remove recipient address from map
    recipientsMap[callHash] = 0x0;
    // clean callHash from caller map
    activeCall[caller] = 0x0;

    settlePayment(caller, msg.sender, maxAmount);
  }

  // end call can be requested by caller
  // if recipient did not published it
  function requestEndCall() public {
    // only caller can request end his call
    require(activeCall[msg.sender] != 0x0);

    // save current timestamp
    endCallRequestDate[msg.sender] = block.timestamp;
  }

  // endCall can be called by caller only if he requested
  // endCall more than endCallRequestDelay ago
  function forceEndCall() public {
    // only caller can request end his call
    require(activeCall[msg.sender] != 0x0);
    // endCallRequestDate needs to be set
    require(endCallRequestDate[msg.sender] != 0);
    require(endCallRequestDate[msg.sender] + endCallRequestDelay < block.timestamp);

    endCallRequestDate[msg.sender] = 0;

    // remove recipient address from map
    recipientsMap[activeCall[msg.sender]] = 0x0;
    // clean callHash from caller map
    activeCall[msg.sender] = 0x0;
  }

  function settlePayment(address sender, address recipient, uint value) private {
    balances[sender] -= value;
    balances[recipient] += value;
  }

}