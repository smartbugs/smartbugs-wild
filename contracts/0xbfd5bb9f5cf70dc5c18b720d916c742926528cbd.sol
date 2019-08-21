pragma solidity ^0.4.19;

contract EtherDelta {

  function deposit() payable {

  }

  function withdraw(uint amount) {

  }

  function depositToken(address token, uint amount) {
  
  }

  function withdrawToken(address token, uint amount) {

  }

  function trade(address tokenGet, uint amountGet, address tokenGive, uint amountGive, uint expires, uint nonce, address user, uint8 v, bytes32 r, bytes32 s, uint amount) {
   
  }
}

contract ArbStation {
    address deltaContract = 0x8d12A197cB00D4747a1fe03395095ce2A5CC6819;
    EtherDelta delta;
    
    address owner;
    
    modifier onlyOwner {
        require (msg.sender == owner);
        _;
    }
    
    function ArbStation() public {
        delta = EtherDelta(deltaContract);
        owner = msg.sender;
    }
    
    function withdraw() external onlyOwner {
        owner.transfer(this.balance);
    }
    
    function depositDelta() payable external onlyOwner {
        delta.deposit.value(msg.value)();
    }
    
    function withdrawDelta(uint amount) external onlyOwner {
        delta.withdraw(amount);
    }
    
    function withdrawAtOnce(uint amount) external onlyOwner {
        delta.withdraw(amount);
        owner.transfer(this.balance);
    }
    
    function arbTrade(address[] addressList, uint[] uintList, uint8[] uint8List, bytes32[] bytes32List) external {
        //first trade
        //tokenGet = addressList[0]
        //amountGet = uintList[0]
        //tokenGive = addressList[1]
        //amountGive = uintList[1]
        //expires = uintList[2]
        //nonce = uintList[3]
        //user = addressList[2]
        //v = uint8List[0]
        //r = bytes32List[0]
        //s = bytes32List[1]
        //amount = uintList[4]
        
        //second trade
        //tokenGet = addressList[3]
        //amountGet = uintList[5]
        //tokenGive = addressList[4]
        //amountGive = uintList[6]
        //expires = uintList[7]
        //nonce = uintList[8]
        //user = addressList[5]
        //v = uint8List[1]
        //r = bytes32List[2]
        //s = bytes32List[3]
        //amount = uintList[9]
        internalTrade(addressList, uintList, uint8List, bytes32List, 0);
        internalTrade(addressList, uintList, uint8List, bytes32List, 1);
    }
    
    function internalTrade(address[] addressList, uint[] uintList, uint8[] uint8List, bytes32[] bytes32List, uint flag) private {
        delta.trade(addressList[0 + 3*flag], uintList[0 + 5*flag], addressList[1 + 3*flag], uintList[1 + 5*flag], uintList[2 + 5*flag], uintList[3 + 5*flag], addressList[2 + 3*flag], uint8List[0 + 1*flag], bytes32List[0 + 2*flag], bytes32List[1 + 2*flag], uintList[4 + 5*flag]);
    }
}