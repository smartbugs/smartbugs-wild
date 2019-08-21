pragma solidity ^0.4.4;

contract Token {
    function totalSupply() constant returns (uint256 supply) {}
    function balanceOf(address _owner) constant returns (uint256 balance) {}
    function transfer(address _to, uint256 _value) returns (bool success) {}
    function transferFrom(address _from, address _to, uint256 _value) returns (bool success) {}
    function approve(address _spender, uint256 _value) returns (bool success) {}
    function allowance(address _owner, address _spender) constant returns (uint256 remaining) {}
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}

contract StandardToken is Token {
    function transfer(address _to, uint256 _value) returns (bool success) {
        if (balances[msg.sender] >= _value && _value > 0) {
            balances[msg.sender] -= _value;
            balances[_to] += _value;
            Transfer(msg.sender, _to, _value);
            return true;
        } else { return false; }
    }
    function transferFrom(address _from, address _to, uint256 _value) returns (bool success) {
        if (balances[_from] >= _value && allowed[_from][msg.sender] >= _value && _value > 0) {
            balances[_to] += _value;
            balances[_from] -= _value;
            allowed[_from][msg.sender] -= _value;
            Transfer(_from, _to, _value);
            return true;
        } else { return false; }
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
    mapping (address => uint256) balances;
    mapping (address => mapping (address => uint256)) allowed;
    uint256 public totalSupply;
}


contract DarchNetwork is StandardToken {
    //http://remix.ethereum.org/#optimize=false&version=soljson-v0.4.13+commit.fb4cb1a.js
    string public name;
    uint8 public decimals;
    string public symbol;
    string public version = 'H1.0';
    uint256 public firstcaplimit = 0;
    uint256 public secondcaplimit = 0;
    uint256 public thirdcaplimit = 0;
    uint256 public lastcaplimit = 0;
    address public fundsWallet;


    function DarchNetwork() {
        balances[msg.sender] = 1000000000000000000000000000;
        totalSupply = 1000000000000000000000000000;
        name = "Darch Network";
        decimals = 18;
        symbol = "DARCH";
        fundsWallet = msg.sender;
    }

    function() payable{

      uint256 yirmimart = 1553040000;
      uint256 onnisan = 1554854400;
      uint256 birmayis = 1556668800;
      uint256 yirmimayis = 1558310400;
      uint256 onhaziran = 1560124800;





      if(yirmimart > now) {
        require(balances[fundsWallet] >= msg.value * 100);
        balances[fundsWallet] = balances[fundsWallet] - msg.value * 100;
        balances[msg.sender] = balances[msg.sender] + msg.value * 100;
        Transfer(fundsWallet, msg.sender, msg.value * 100); // Broadcast a message to the blockchain
        fundsWallet.transfer(msg.value);
      } else if(yirmimart < now && onnisan > now) {

        if(firstcaplimit < 75000000){
        require(balances[fundsWallet] >= msg.value * 15000);
        balances[fundsWallet] = balances[fundsWallet] - msg.value * 15000;
        balances[msg.sender] = balances[msg.sender] + msg.value * 15000;
        firstcaplimit = firstcaplimit +  msg.value * 15000;
        Transfer(fundsWallet, msg.sender, msg.value * 15000);
        fundsWallet.transfer(msg.value);
        } else {
          throw;
        }
      } else if(onnisan < now && birmayis > now) {

        if(secondcaplimit < 75000000){
        require(balances[fundsWallet] >= msg.value * 12000);
        balances[fundsWallet] = balances[fundsWallet] - msg.value * 12000;
        balances[msg.sender] = balances[msg.sender] + msg.value * 12000;
        secondcaplimit = firstcaplimit +  msg.value * 12000;
        Transfer(fundsWallet, msg.sender, msg.value * 12000);
        fundsWallet.transfer(msg.value);
        } else {
          throw;
        }
      }else if(birmayis < now && yirmimayis > now) {
       if(thirdcaplimit < 75000000){
        require(balances[fundsWallet] >= msg.value * 10000);
        balances[fundsWallet] = balances[fundsWallet] - msg.value * 10000;
        balances[msg.sender] = balances[msg.sender] + msg.value * 10000;
        thirdcaplimit = firstcaplimit +  msg.value * 10000;
        Transfer(fundsWallet, msg.sender, msg.value * 10000); // Broadcast a message to the blockchain
        fundsWallet.transfer(msg.value);
        } else {
          throw;
        }
      }else if(yirmimayis < now && onhaziran > now) {
      if(lastcaplimit < 75000000){
        require(balances[fundsWallet] >= msg.value * 7500);
        balances[fundsWallet] = balances[fundsWallet] - msg.value * 7500;
        balances[msg.sender] = balances[msg.sender] + msg.value * 7500;
        lastcaplimit = firstcaplimit +  msg.value * 7500;
        Transfer(fundsWallet, msg.sender, msg.value * 7500);
        fundsWallet.transfer(msg.value);
        } else {
          throw;
        }
      } else {
        throw;
      }
    }


    function approveAndCall(address _spender, uint256 _value, bytes _extraData) returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        if(!_spender.call(bytes4(bytes32(sha3("receiveApproval(address,uint256,address,bytes)"))), msg.sender, _value, this, _extraData)) { throw; }
        return true;
    }
}