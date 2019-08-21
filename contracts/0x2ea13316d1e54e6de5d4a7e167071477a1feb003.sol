pragma solidity ^0.4.18;

contract Ownable {
  address public owner;

  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

  function Ownable() public {
    owner = msg.sender;
  }

  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

  function transferOwnership(address newOwner) public onlyOwner {
    require(newOwner != address(0));
    OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }
}

contract ERC20Basic {
  uint public totalSupply;
  function balanceOf(address who) public constant returns (uint);
  function transfer(address to, uint value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint value);
}

library SafeMath {
  function mul(uint a, uint b) internal pure returns (uint) {
    if (a == 0) return 0;
    uint c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function div(uint a, uint b) internal pure returns (uint) {
    uint c = a / b;
    return c;
  }

  function sub(uint a, uint b) internal pure returns (uint) {
    assert(b <= a);
    return a - b;
  }

  function add(uint a, uint b) internal pure returns (uint) {
    uint c = a + b;
    assert(c >= a);
    return c;
  }
}


contract BasicToken is ERC20Basic {
  using SafeMath for uint;

  mapping(address => uint) balances;

  function transfer(address _to, uint _value) public returns (bool) {
    require(_to != address(0));
    require(_value > 0 && _value <= balances[msg.sender]);

    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);
    Transfer(msg.sender, _to, _value);
    return true;
  }

  function balanceOf(address _owner) public constant returns (uint balance) {
    return balances[_owner];
  }
}

contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender) public constant returns (uint);
  function transferFrom(address from, address to, uint value) public returns (bool);
  function approve(address spender, uint value) public returns (bool);
  event Approval(address indexed owner, address indexed spender, uint value);
}


contract StandardToken is ERC20, BasicToken {
  mapping (address => mapping (address => uint)) internal allowed;

  function transferFrom(address _from, address _to, uint _value) public returns (bool) {
    require(_to != address(0));
    require(_value <= balances[_from]);
    require(_value <= allowed[_from][msg.sender]);

    balances[_from] = balances[_from].sub(_value);
    balances[_to] = balances[_to].add(_value);
    allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
    Transfer(_from, _to, _value);
    return true;
  }

  function approve(address _spender, uint _value) public returns (bool) {
    allowed[msg.sender][_spender] = _value;
    Approval(msg.sender, _spender, _value);
    return true;
  }

  function allowance(address _owner, address _spender) public constant returns (uint remaining) {
    return allowed[_owner][_spender];
  }

  function increaseApproval (address _spender, uint _addedValue) public returns (bool success) {
    allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
    Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

  function decreaseApproval (address _spender, uint _subtractedValue) public returns (bool success) {
    uint oldValue = allowed[msg.sender][_spender];
    if (_subtractedValue > oldValue) {
      allowed[msg.sender][_spender] = 0;
    } else {
      allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
    }
    Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }
}

contract TokenTimelock is StandardToken, Ownable {
  struct Ice {
    uint value;
    uint time;
  }
  mapping (address => Ice[]) beneficiary;

  event Freezing(address indexed to, uint value, uint time);
  event UnFreeze(address indexed to, uint time, uint value);
  event Crack(address indexed addr, uint time, uint value);

  function freeze(address _to, uint _releaseTime, uint _value) public onlyOwner {
    require(_to != address(0));
    require(_value > 0 && _value <= balances[owner]);

    // Check exist
    uint i;
    bool f;
    while (i < beneficiary[_to].length) {
      if (beneficiary[_to][i].time == _releaseTime) {
        f = true;
        break;
      }
      i++;
    }

    // Add data
    if (f) {
      beneficiary[_to][i].value = beneficiary[_to][i].value.add(_value);
    } else {
      Ice memory temp = Ice({
          value: _value,
          time: _releaseTime
      });
      beneficiary[_to].push(temp);
    }
    balances[owner] = balances[owner].sub(_value);
    Freezing(_to, _value, _releaseTime);
  }

  function unfreeze(address _to) public onlyOwner {
    Ice memory record;
    for (uint i = 0; i < beneficiary[_to].length; i++) {
      record = beneficiary[_to][i];
      if (record.value > 0 && record.time < now) {
        beneficiary[_to][i].value = 0;
        balances[_to] = balances[_to].add(record.value);
        UnFreeze(_to, record.time, record.value);
      }
    }
  }

  function clear(address _to, uint _time, uint _amount) public onlyOwner {
    for (uint i = 0; i < beneficiary[_to].length; i++) {
      if (beneficiary[_to][i].time == _time) {
        beneficiary[_to][i].value = beneficiary[_to][i].value.sub(_amount);
        balances[owner] = balances[owner].add(_amount);
        Crack(_to, _time, _amount);
        break;
      }
    }
  }

  function getBeneficiaryByTime(address _to, uint _time) public view returns(uint) {
    for (uint i = 0; i < beneficiary[_to].length; i++) {
      if (beneficiary[_to][i].time == _time) {
        return beneficiary[_to][i].value;
      }
    }
  }

  function getBeneficiaryById(address _to, uint _id) public view returns(uint, uint) {
    return (beneficiary[_to][_id].value, beneficiary[_to][_id].time);
  }

  function getNumRecords(address _to) public view returns(uint) {
    return beneficiary[_to].length;
  }
}


contract GozToken is TokenTimelock {
  string public constant name = 'GOZ';
  string public constant symbol = 'GOZ';
  uint32 public constant decimals = 18;
  uint public constant initialSupply = 80E25;

  function GozToken() public {
    totalSupply = initialSupply;
    balances[msg.sender] = initialSupply;
  }
}