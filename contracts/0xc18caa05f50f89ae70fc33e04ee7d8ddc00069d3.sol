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



contract COMPANI is StandardToken {

    function () {
       
        throw;
    }

    string public name;                   
    uint8 public decimals;               
    string public symbol;                 
    string public version = 'H1.0';       
 /* สมาร์ทคอนแทร็ก โดยบริษัท คัมปานี จำกัด, กรุงเทพฯ, ประเทศไทย เพื่อใช้ผลิตเหรียญสินค้าสกุลดิจิตอลชื่อ
 ทีเอชบีซี โดยใช้เพื่อกิจการทางธุรกิจและเศรษฐสังคมทั่วไปทั้งในและต่างประเทศ อนึ่งไม่ใช่เพื่อการแลกเปลี่ยนเงิน
 ตราหรือกิจกรรมอื่นใดที่อาจขัดแย้งกับพรบ.การเงิน และขอสงวนสิทธิ์ในการรับผิดจากการที่บุคคลนำไปใช้โดยผิดวัตถุประสงค์
 ทุกกรณี */
    function COMPANI(
        ) {
        balances[msg.sender] = 161803398875;               
        totalSupply = 161803398875;                        
        name = "Compani Ltd., (http://compani.org) - Common Token";                                   
        decimals = 2;                            
        symbol = "THBC";                               
    }

    function approveAndCall(address _spender, uint256 _value, bytes _extraData) returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);

        if(!_spender.call(bytes4(bytes32(sha3("receiveApproval(address,uint256,address,bytes)"))), msg.sender, _value, this, _extraData)) { throw; }
        return true;
    }
}