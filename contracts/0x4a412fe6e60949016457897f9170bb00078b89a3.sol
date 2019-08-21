pragma solidity ^0.4.4;

// mainnet: 0x4a412fe6e60949016457897f9170bb00078b89a3

contract SimpleMultisig {

  // wallet
  struct Tx {
    address founder;
    address destAddr;
    uint256 amount;
    bool active;
  }
  
  mapping (address => bool) public founders;
  Tx[] public txs;

  function SimpleMultisig() public {
    founders[0xf8e18E704Fb07282Eec78ADBEC6B584497d0B2e2] = true;
    founders[0x0c621a12884c4F95B7Af1C46760a1bb7fE85ffaa] = true;
    founders[0x6fc10338003273a46D7da62a126099998C981572] = true;
  }

  // contribute function
  function() public payable {}

  // one of founders can propose destination address for ethers
  function proposeTx(address destAddr, uint256 amount) public isFounder {
    txs.push(Tx({
      founder: msg.sender,
      destAddr: destAddr,
      amount: amount,
      active: true
    }));
  }

  // another founder can approve specified tx and send it to destAddr
  function approveTx(uint8 txIdx) public isFounder {
    assert(txs[txIdx].founder != msg.sender);
    assert(txs[txIdx].active);

    txs[txIdx].active = false;
    txs[txIdx].destAddr.transfer(txs[txIdx].amount);
  }

  // founder who created tx can cancel it
  function cancelTx(uint8 txIdx) public {
    assert(txs[txIdx].founder == msg.sender);
    assert(txs[txIdx].active);

    txs[txIdx].active = false;
  }

  // check if msg.sender is founder
  modifier isFounder() {
    assert(founders[msg.sender]);
    _;
  }
}