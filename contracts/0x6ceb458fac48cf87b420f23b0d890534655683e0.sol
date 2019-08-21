pragma solidity ^0.4.18;

contract ERC20 {
    function totalSupply() constant returns (uint256 supply) {}
    function balanceOf(address _owner) constant returns (uint256 balance) {}
    function transfer(address _to, uint256 _value) returns (bool success) {}
    function transferFrom(address _from, address _to, uint256 _value) returns (bool success) {}
    function approve(address _spender, uint256 _value) returns (bool success) {}
    function allowance(address _owner, address _spender) constant returns (uint256 remaining) {}
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}

contract FBT is ERC20 {
    mapping (address => uint256) balances;
    mapping (address => mapping (address => uint256)) allowed;
    mapping (address => bytes1) addresslevels;
    mapping (address => uint256) feebank;
 
    uint256 public totalSupply;
    uint256 public pieceprice;
    uint256 public datestart;
    uint256 public totalaccumulated;
  
    address dev1 = 0xFAB873F0f71dCa84CA33d959C8f017f886E10C63;
    address dev2 = 0xD7E9aB6a7a5f303D3Cd17DcaEFF254D87757a1F8;

    function transfer(address _to, uint256 _value) returns (bool success) {
        if (balances[msg.sender] >= _value && _value > 0) {
            balances[msg.sender] -= _value;
            balances[_to] += _value;
            Transfer(msg.sender, _to, _value);
          
            refundFees();
            return true;
        } else revert();
    }

    function transferFrom(address _from, address _to, uint256 _value) returns (bool success) {
        if (balances[_from] >= _value && allowed[_from][msg.sender] >= _value && _value > 0) {
            balances[_to] += _value;
            balances[_from] -= _value;
            allowed[_from][msg.sender] -= _value;
            Transfer(_from, _to, _value);
          
            refundFees();
            return true;
        } else revert();
    }
  
    function balanceOf(address _owner) constant returns (uint256 balance) {
        return balances[_owner];
    }

    function approve(address _spender, uint256 _value) returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }

    function allowance(address _owner, address _spender) constant returns (uint256 remaining) {
        return allowed[_owner][_spender];
    }
   
    function refundFees() {
        uint256 refund = 200000*tx.gasprice;
        if (feebank[msg.sender]>=refund) {
            msg.sender.transfer(refund);
            feebank[msg.sender]-=refund;
        }       
    }
}


contract FrostByte is FBT {
    event tokenBought(uint256 totalTokensBought, uint256 Price);
    event etherSent(uint256 total);
   
    string public name;
    uint8 public decimals;
    string public symbol;
    string public version = '0.4';
  
    function FrostByte() {
        name = "FrostByte";
        decimals = 4;
        symbol = "FBT";
        pieceprice = 1 ether / 256;
        datestart = now;
    }

    function () payable {
        bytes1 addrLevel = getAddressLevel();
        uint256 generateprice = getPrice(addrLevel);
        if (msg.value<generateprice) revert();

        uint256 seventy = msg.value / 100 * 30;
        uint256 dev = seventy / 2;
        dev1.transfer(dev);
        dev2.transfer(dev);
        totalaccumulated += seventy;

        uint256 generateamount = msg.value * 10000 / generateprice;
        totalSupply += generateamount;
        balances[msg.sender]=generateamount;
        feebank[msg.sender]+=msg.value-seventy;
       
        refundFees();
        tokenBought(generateamount, msg.value);
    }
   
    function sendEther(address x) payable {
        x.transfer(msg.value);
        refundFees();

        etherSent(msg.value);
    }
   
    function feeBank(address x) constant returns (uint256) {
        return feebank[x];
    }
   
    function getPrice(bytes1 addrLevel) constant returns (uint256) {
        return pieceprice * uint256(addrLevel);
    }
   
    function getAddressLevel() returns (bytes1 res) {
        if (addresslevels[msg.sender]>0) return addresslevels[msg.sender];
      
        bytes1 highest = 0;
        for (uint256 i=0;i<20;i++) {
            bytes1 c = bytes1(uint8(uint(msg.sender) / (2**(8*(19 - i)))));
            if (bytes1(c)>highest) highest=c;
           
        }
      
        addresslevels[msg.sender]=highest;
        return highest;
    }
 
    function approveAndCall(address _spender, uint256 _value, bytes _extraData) returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);

        if(!_spender.call(bytes4(bytes32(keccak256("receiveApproval(address,uint256,address,bytes)"))), msg.sender, _value, this, _extraData)) { revert(); }
        return true;
    }
}