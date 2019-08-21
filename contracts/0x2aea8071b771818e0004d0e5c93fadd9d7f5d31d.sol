pragma solidity ^0.4.19;

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
    uint256 c = a / b;
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

  function transfer(address _to, uint256 _value) returns (bool) {
    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);
    Transfer(msg.sender, _to, _value);
    return true;
  }

  function balanceOf(address _owner) constant returns (uint256 balance) {
    return balances[_owner];
  }

}

contract StandardToken is ERC20, BasicToken {

  mapping (address => mapping (address => uint256)) allowed;

  function transferFrom(address _from, address _to, uint256 _value) returns (bool) {
    var _allowance = allowed[_from][msg.sender];

    balances[_to] = balances[_to].add(_value);
    balances[_from] = balances[_from].sub(_value);
    allowed[_from][msg.sender] = _allowance.sub(_value);
    Transfer(_from, _to, _value);
    return true;
  }


  function approve(address _spender, uint256 _value) returns (bool) {

    require((_value == 0) || (allowed[msg.sender][_spender] == 0));

    allowed[msg.sender][_spender] = _value;
    Approval(msg.sender, _spender, _value);
    return true;
  }


  function allowance(address _owner, address _spender) constant returns (uint256 remaining) {
    return allowed[_owner][_spender];
  }

}

contract Ownable {
    
  address public owner;

  function Ownable() {
    owner = msg.sender;
  }


  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

  function transferOwnership(address newOwner) onlyOwner {
    require(newOwner != address(0));      
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

  function mint(address _to, uint256 _amount) onlyOwner canMint returns (bool) {
    totalSupply = totalSupply.add(_amount);
    balances[_to] = balances[_to].add(_amount);
    Mint(_to, _amount);
    return true;
  }

  function finishMinting() onlyOwner returns (bool) {
    mintingFinished = true;
    MintFinished();
    return true;
  }
  
}

/* @dev Specific contract details name , decimals */

contract CIDToken is MintableToken {
    
    string public constant name = "CID";
    
    string public constant symbol = "CID";
    
    uint32 public constant decimals = 18;
    
}



contract CIDCrowdsale is Ownable {
    
    using SafeMath for uint;
    
    address public multisig;

    CIDToken public token = new CIDToken();

    uint start;
    
    uint endtime;

    uint hardcap;

    uint rate;
    
    uint softcap;
    
    address wal1;
    address wal2;
    address wal3;

    mapping(address => uint) public balances;
    /* Specific contract details: Start time, End time, Min.Cap, Max.Cap,
    Rate of Token to ETH, Final owner wallet, Team's bonuses wallet*/
    function CIDCrowdsale() {
        /** Final owner wallet */
        multisig = 0x2338801bA8aEe40d679364bcA4e69d8C1B7a101C;
        rate = 1000000000000000000000; 
        start = 1517468400; /** 01.02.2018 in unix */
        endtime = 1519776000;/** 28.02.2018in unix */
        hardcap = 7000000 * (10 ** 18); /** 7 000 000 * 1e18 CID*/
        softcap = 300000 * (10 ** 18); /** 300 000 1e18 */
        
        /*Team's bonuses wallet*/
        wal1 = 0x35E0e717316E38052f6b74f144F2a7CE8318294b;
        wal2 = 0xa9251f22203e34049aa5D4DbfE4638009A1586F5;
        wal3 = 0xE9267a312B9Bc125557cff5146C8379cCEE3a33D;
    }

    modifier saleIsOn() {
    require(now > start && now < endtime);
        _;
    }
    
    modifier isUnderHardCap() {
        require(this.balance <= hardcap);
        _;
    }
    /* refund option for investors*/
    function refund() public {
        require(this.balance < softcap && now > start && balances[msg.sender] > 0);
        uint value = balances[msg.sender];
        balances[msg.sender] = 0;
        msg.sender.transfer(value);
    }
    
    /* when softcap reached , finish of token minting could be implemented */
   function finishMinting() public onlyOwner {
      uint finCheckBalance = softcap.div(rate);
      if(this.balance > finCheckBalance) {
        multisig.transfer(this.balance);
        token.finishMinting();
      }
    }
    
    
   function createTokens() isUnderHardCap saleIsOn payable {
       
        
        uint tokens = rate.mul(msg.value).div(1 ether);
        uint CTS = token.totalSupply(); /** check total Supply */
        uint bonusTokens = 0;
        
        /* bonus tokens calculation for ICO stages */
        if(CTS <= (300000 * (10 ** 18))) {
          bonusTokens = (tokens.mul(30)).div(100);    /* 30% bonus */
        } else if(CTS > (300000 * (10 ** 18)) && CTS <= (400000 * (10 ** 18)))  {
          bonusTokens = (tokens.mul(25)).div(100);       /* 25% bonus */
        } else if(CTS > (400000 * (10 ** 18)) && CTS <= (500000 * (10 ** 18))) {
          bonusTokens = (tokens.mul(20)).div(100);         /* 20% bonus */
        } else if(CTS > (500000 * (10 ** 18)) && CTS <= (700000 * (10 ** 18))) {
          bonusTokens = (tokens.mul(15)).div(100);       /* 15% bonus */
        } else if(CTS > (700000 * (10 ** 18)) && CTS <= (1000000 * (10 ** 18))) {
          bonusTokens = (tokens.mul(10)).div(100);          /* 10% bonus */
        } else if(CTS > (1000000 * (10 ** 18))) {
          bonusTokens = 0;      /* 0% */
        }
        
        tokens += bonusTokens;
        token.mint(msg.sender, tokens);
        
        
        balances[msg.sender] = balances[msg.sender].add(msg.value);
        /** Team's bonus tokens calculation*/
        uint wal1Tokens = (tokens.mul(25)).div(100);
        token.mint(wal1, wal1Tokens);
        
        
        uint wal2Tokens = (tokens.mul(10)).div(100);
        token.mint(wal2, wal2Tokens);
        
        uint wal3Tokens = (tokens.mul(5)).div(100);
        token.mint(wal3, wal3Tokens);
        
        
       
    }

   
    function() external payable {
        createTokens();
    }
    
}