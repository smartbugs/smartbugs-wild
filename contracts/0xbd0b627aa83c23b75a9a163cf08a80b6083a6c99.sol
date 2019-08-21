pragma solidity ^0.4.21;

contract owned {
    address public godOwner;
    mapping (address => bool) public owners;
    
    constructor() public{
        godOwner = msg.sender;
        owners[msg.sender] = true;
    }
    
    modifier onlyGodOwner {
        require(msg.sender == godOwner);
        _;
    }

    modifier onlyOwner {
        require(owners[msg.sender] == true);
        _;
    }

    function addOwner(address _newOwner) onlyGodOwner public{
        owners[_newOwner] = true;
    }
    
    function removeOwner(address _oldOwner) onlyGodOwner public{
        owners[_oldOwner] = false;
    }
    
    function transferOwnership(address newGodOwner) public onlyGodOwner {
        godOwner = newGodOwner;
        owners[newGodOwner] = true;
        owners[godOwner] = false;
    }
}


contract ContractConn{
    function transfer(address _to, uint _value) public;
    function lock(address _to, uint256 _value) public;
}

contract Airdrop is owned{
    
  constructor()  public payable{
         
  }
    
  function deposit() payable public{
  }
  
  function doTransfers(address _tokenAddr, address[] _dests, uint256[] _values) onlyOwner public {
    require(_dests.length >= 1 && _dests.length == _values.length,"doTransfers 1");
    ContractConn conn = ContractConn(_tokenAddr);
    uint256 i = 0;
    while (i < _dests.length) {
        conn.transfer(_dests[i], _values[i]);
        i += 1;
    }
  }
  
  function doLocks(address _tokenAddr, address[] _dests, uint256[] _values) onlyOwner public{
    require(_dests.length >= 1 && _dests.length == _values.length);
    ContractConn conn = ContractConn(_tokenAddr);
    uint256 i = 0;
    while (i < _dests.length) {
        conn.lock(_dests[i], _values[i]);
        i += 1;
    }
  }
  
  function doWork(address _tokenAddr, string _method, address[] _dests, uint256[] _values) onlyOwner public{
      require(_dests.length >= 1 && _dests.length == _values.length);
      bytes4 methodID =  bytes4(keccak256(abi.encodePacked(_method)));
      uint256 i = 0;
      while(i < _dests.length){
          if(!_tokenAddr.call(methodID, _dests[i], _values[i])){
              revert();
          }
          i += 1;
      }
  }
  
  function extract(address _tokenAddr,address _to,uint256 _value) onlyOwner  public{
      ContractConn conn = ContractConn(_tokenAddr);
      conn.transfer(_to,_value);
  }
  
  function extractEth(uint256 _value) onlyOwner  public{
      msg.sender.transfer(_value);
  }
  
}