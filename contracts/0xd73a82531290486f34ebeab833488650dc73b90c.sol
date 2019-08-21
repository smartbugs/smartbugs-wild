contract ERC20Basic {
  uint256 public totalSupply;
  function balanceOf(address who) public constant returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}

contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender) public constant returns (uint256);
  function transferFrom(address from, address to, uint256 value) public returns (bool);
  function approve(address spender, uint256 value) public returns (bool);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}

library SafeMath {
  function mul(uint256 a, uint256 b) internal constant returns (uint256) {
    uint256 c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal constant returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  function sub(uint256 a, uint256 b) internal constant returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal constant returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}

contract BasicToken is ERC20Basic {
  using SafeMath for uint256;

  mapping(address => uint256) balances;

  function transfer(address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));
    require(_value <= balances[msg.sender]);

    // SafeMath.sub will throw if there is not enough balance.
    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);
    Transfer(msg.sender, _to, _value);
    return true;
  }

  function balanceOf(address _owner) public constant returns (uint256 balance) {
    return balances[_owner];
  }

}
contract StandardToken is ERC20, BasicToken {

  mapping (address => mapping (address => uint256)) internal allowed;


  function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));
    require(_value <= balances[_from]);
    require(_value <= allowed[_from][msg.sender]);

    balances[_from] = balances[_from].sub(_value);
    balances[_to] = balances[_to].add(_value);
    allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
    Transfer(_from, _to, _value);
    return true;
  }

  function approve(address _spender, uint256 _value) public returns (bool) {
    allowed[msg.sender][_spender] = _value;
    Approval(msg.sender, _spender, _value);
    return true;
  }

  function allowance(address _owner, address _spender) public constant returns (uint256 remaining) {
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
contract Ownable {
  address public owner;
  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
  function Ownable() public{
    owner = msg.sender;
  }
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }
  function transferOwnership(address newOwner) onlyOwner public {
    require(newOwner != address(0));
    OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }

}
contract MintableToken is StandardToken, Ownable {
  event Mint(address indexed to, uint256 amount);
  event MintFinished();

  bool public mintingFinished = false;


  modifier canMint() {
    require(!mintingFinished);
    _;
  }

  function mint(address _to, uint256 _amount) onlyOwner canMint public returns (bool) {
    totalSupply = totalSupply.add(_amount);
    balances[_to] = balances[_to].add(_amount);
    Mint(_to, _amount);
    Transfer(address(0), _to, _amount);
    return true;
  }
  function finishMinting() onlyOwner public returns (bool) {
    mintingFinished = true;
    MintFinished();
    return true;
  }
}
contract BurnableToken is StandardToken {

  function burn(uint _value) public {
    require(_value > 0);
    address burner = msg.sender;
    balances[burner] = balances[burner].sub(_value);
    totalSupply = totalSupply.sub(_value);
    Burn(burner, _value);
  }

  event Burn(address indexed burner, uint indexed value);

}


contract EWA is MintableToken, BurnableToken {
    
    string public constant name = "EWAcoin";
    
    string public constant symbol = "EWA";
    
    uint32 public constant decimals = 0;
    
    struct Trnsaction {
        address addr;
        uint time;
        uint value;
    }
    
    mapping (uint => Trnsaction) TrnsactionLog;
    
    mapping (address => uint256) securities;
     
    mapping (address => uint256) production;
    
    uint public startsecurities;
    
    uint public startproduction;
    
    uint public starteth;
    
    address public moneybackaddr;
    
    uint public i;
    
    function EWA() public{
		owner = msg.sender;
		startsecurities = 1546214400;
		startproduction = 1546214400;
		starteth = 1514764800;
		moneybackaddr = 0x0F99f33cD5a6B1b77eD905C229FC1962D05fE74F;
    }
    
    function destroyforsecurities (uint _value) public {
        require (_value > 99999);
        require (now > startsecurities);
        if(balances[msg.sender] >= _value && securities[msg.sender] + _value >= securities[msg.sender]) {
            burn (_value);
            securities[msg.sender] += _value;
        }
    }
    
    function securitiesOf(address _owner) public constant returns (uint balance) {
        return securities[_owner];
    }
    
    function destroyforproduction (uint _value) public {
        require (_value > 0);
        require (now > startproduction);
        if(balances[msg.sender] >= _value && production[msg.sender] + _value >= production[msg.sender]) {
            burn (_value);
            production[msg.sender] += _value;
        }
    }
    
    function productionOf(address _owner) public constant returns (uint balance) {
        return production[_owner];
    }
    
    function destroyforeth (uint _value) public {
        require (_value > 0);
        require (now > starteth);
        require (this.balance > _value.mul(120000000000000));
        if(balances[msg.sender] >= _value) {
            burn (_value);
            TrnsactionLog[i].addr = msg.sender;
            TrnsactionLog[i].time = now;
            TrnsactionLog[i].value = _value;
            i++;
            msg.sender.transfer(_value.mul(120000000000000));
        }
    }
    
    function showTrnsactionLog (uint _number) public constant returns (address addr, uint time, uint value) {
        return (TrnsactionLog[_number].addr, TrnsactionLog[_number].time, TrnsactionLog[_number].value);   
    }
    
    function moneyback () public {
        require  (msg.sender == moneybackaddr);
        uint256 bal = balance1();
        if (bal > 10 ) {
            moneybackaddr.transfer(bal);
        }
    }
    
    function balance1 () public constant returns (uint256){
        return this.balance;
    }
    
    function() external payable {
    }
    
}

contract Crowdsale is Ownable {
    
    using SafeMath for uint;
    address owner ;
    EWA public token = new EWA();
    uint start1;
    uint start2;
    uint start3;
    uint start4;
    uint end1;
    uint end2;
    uint end3;
    uint end4;
    uint hardcap1;
    uint hardcap2;
    uint price11;
    uint price12;
    uint price13;
    uint price2;
    uint price3;
    uint price4;
	address ethgetter;

    function Crowdsale() public{
        owner = msg.sender;
		start1 = 1511568000;
		start2 = 1512777600;  
		start3 = 1512864000;
		start4 = 1512950400;
		end1 = 1512777599; 
		end2 = 1512863999;
		end3 = 1512950399;
		end4 = 1514764799;
		hardcap1 = 70000000;
		hardcap2 = 200000000;
		price11 = 60000000000000;
		price12 = price11.mul(35).div(100);
		price13 = price11.div(2);
		price2 = price11.mul(15).div(100);
		price3 = price11.mul(7).div(100);
		price4 = price11;
		ethgetter = 0xC84f88d5cc6cAbc10fD031E1A5908fA70b3fcECa;
    }
    
    function() external payable {
        require((now > start1 && now < end1)||(now > start2 && now < end2)||(now > start3 && now < end3)||(now > start4 && now < end4));
        uint tokadd;
        if (now > start1 && now <end1) {
            if (msg.value < 2000000000000000000) {
                tokadd = msg.value.div(price11);
                require (token.totalSupply() + tokadd < hardcap1);
                ethgetter.transfer(msg.value);
                token.mint(msg.sender, tokadd);
                
            }
            if (msg.value >= 2000000000000000000 && msg.value < 50000000000000000000) {
                tokadd = msg.value.div(price12);
                require (token.totalSupply() + tokadd < hardcap1);
                ethgetter.transfer(msg.value);
                token.mint(msg.sender, tokadd);
            }
            if (msg.value >= 50000000000000000000) {
                tokadd = msg.value.div(price13);
                require (token.totalSupply() + tokadd < hardcap1);
                ethgetter.transfer(msg.value);
                token.mint(msg.sender, tokadd);
            }
        }
        if (now > start2 && now <end2) {
            tokadd = msg.value.div(price2);
            require (token.totalSupply() + tokadd < hardcap2);
            ethgetter.transfer(msg.value);
            token.mint(msg.sender, tokadd);
        }
        if (now > start3 && now <end3) {
            tokadd = msg.value.div(price3);
            require (token.totalSupply() + tokadd < hardcap2);
            ethgetter.transfer(msg.value);
            token.mint(msg.sender, tokadd);
        }
        if (now > start4 && now <end4) {
            tokadd = msg.value.div(price4);
            require (token.totalSupply() + tokadd < hardcap2);
            ethgetter.transfer(msg.value);
            token.mint(msg.sender, tokadd);
        }
        
    }
    
    function finishMinting() public onlyOwner {
        token.finishMinting();
    }
    
    function mint(address _to, uint _value) public onlyOwner {
        require(_value > 0);
        require(_value + token.totalSupply() < hardcap2 + 3000000);
        token.mint(_to, _value);
    }
    
}