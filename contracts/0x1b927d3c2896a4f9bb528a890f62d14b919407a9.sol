pragma solidity ^0.4.11;

contract TronToken {

    // string public name = "Tronix";      //  token name
   //  string public symbol = "TRX";           //  token symbol
  //  uint256 public decimals = 6;            //  token digit

    mapping (address => uint256) public balanceOf;
   

    uint256 public totalSupply = 0;
    bool public stopped = false;

    uint256 constant valueFounder = 100000000000000000;
    address owner = 0x0;

  

    modifier isRunning {
        assert (!stopped);
        _;
    }

    modifier validAddress {
        assert(0x0 != msg.sender);
        _;
    }

    function TronToken(address _addressFounder) public {
        owner = msg.sender;
        totalSupply = valueFounder;
        balanceOf[_addressFounder] = valueFounder;
        Transfer(0x0, _addressFounder, valueFounder);
    }
   
    

    function transfer(address _to, uint256 _value) isRunning validAddress  payable returns (bool success) {
        require(balanceOf[msg.sender] >= _value);
        require(balanceOf[_to] + _value >= balanceOf[_to]);
        balanceOf[msg.sender] -= _value;
        balanceOf[_to] += _value;
        Transfer(msg.sender, _to, _value);
        return true;
    }

    

   
   

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
   
}