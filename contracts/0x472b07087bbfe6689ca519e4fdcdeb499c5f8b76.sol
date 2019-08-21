pragma solidity ^0.4.16;

contract Ownable {
    
    address public owner;
    
    function Ownable() public { 
        owner = msg.sender;
    }
 
    modifier onlyOwner() { 
        require(msg.sender == owner);
        _;
    }
 
    function transferOwnership(address _owner) public onlyOwner { 
        owner = _owner;
    }
    
}

contract RobotCoin is Ownable{
    
  modifier onlySaleAgent() { 
    require(msg.sender == saleAgent);
    _;
  }
    
  modifier onlyMasters() { 
    require(msg.sender == saleAgent || msg.sender == owner);
    _;
  }

  string public name; 
  string public symbol; 
  uint8 public decimals; 
     
  uint256 private tokenTotalSupply;
  address private tokenHolder;
  bool public usersCanTransfer;
  
  address public saleAgent; 
  
  mapping (address => uint256) private  balances;
  mapping (address => mapping (address => uint256)) private allowed; 
  
  event Transfer(address indexed _from, address indexed _to, uint256 _value);  
  event Approval(address indexed _owner, address indexed _spender, uint256 _value); 

  function RobotCoin () public {
    name = "RobotCoin"; 
    symbol = "RBC"; 
    decimals = 3; 
    
    tokenHolder = owner;
        
    tokenTotalSupply = 500000000000; 
    balances[this] = 250000000000;
    balances[tokenHolder] = 250000000000;
    
    usersCanTransfer = true;
  }

  function totalSupply() public constant returns (uint256 _totalSupply){ 
    return tokenTotalSupply;
    }
   
  function setTransferAbility(bool _usersCanTransfer) public onlyMasters{
    usersCanTransfer = _usersCanTransfer;
  }
  
  function setSaleAgent(address newSaleAgnet) public onlyMasters{ 
    saleAgent = newSaleAgnet;
  }
  
  function balanceOf(address _owner) public constant returns (uint balance) { 
    return balances[_owner];
  }

  function allowance(address _owner, address _spender) public constant returns (uint256 remaining){ 
    return allowed[_owner][_spender];
  }
  
  function approve(address _spender, uint256 _value) public returns (bool success){  
    allowed[msg.sender][_spender] += _value;
    Approval(msg.sender, _spender, _value);
    return true;
  }
  
  function _transfer(address _from, address _to, uint256 _value) internal returns (bool){ 
    require (_to != 0x0); 
    require(balances[_from] >= _value); 
    require(balances[_to] + _value >= balances[_to]); 

    balances[_from] -= _value; 
    balances[_to] += _value;

    Transfer(_from, _to, _value);
    return true;
  }

  function transfer(address _to, uint256 _value) public returns (bool success) { 
    require(usersCanTransfer || (msg.sender == owner));
    return _transfer(msg.sender, _to, _value);
  }

  function serviceTransfer(address _to, uint256 _value) public onlySaleAgent returns (bool success) { 
    return _transfer(this, _to, _value);
  }

  function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {   
    require(usersCanTransfer);
    require(_value <= allowed[_from][_to]);
    allowed[_from][_to] -= _value;  
    return _transfer(_from, _to, _value); 
  }
  
  function transferEther(uint256 etherAmmount) public onlyOwner{ 
    require(this.balance >= etherAmmount); 
    owner.transfer(etherAmmount); 
  }
}