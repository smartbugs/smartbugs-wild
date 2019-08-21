pragma solidity ^0.4.24;

/**
 * Note Of Exchange On The BlockChain
 * Website: http://1-2.io
 * Twitter: https://twitter.com/NoteOfExchange
 */
library SafeMath {

    /**
    * Multiplies two numbers, throws on overflow.
    */
    function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
        if (a == 0) {
            return 0;
        }
        c = a * b;
        assert(c / a == b);
        return c;
    }

    /**
    * Integer division of two numbers, truncating the quotient.
    */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // assert(b > 0); // Solidity automatically throws when dividing by 0
        // uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return a / b;
    }

    /**
    * Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
    */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    /**
    * Adds two numbers, throws on overflow.
    */
    function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
        c = a + b;
        assert(c >= a);
        return c;
    }
}

contract OtherToken {
    function balanceOf(address _owner) constant public returns (uint256);
    function transfer(address _to, uint256 _value) public returns (bool);
}

contract ERC20Basic {
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

contract NoteOfExchange is ERC20 {
    
    using SafeMath for uint256;
    address owner = msg.sender;

    mapping (address => uint256) public balances;
    mapping (address => mapping (address => uint256)) public allowed;    
    mapping (address => bool) public joinOnce;
    mapping (address => uint256) public frozenAccount;

    string  internal  name_ = "NoteOfExchange";
    string  internal  symbol_ = "NOE";
    uint8 internal  decimals_ = 8;    
    uint256 internal  totalSupply_ = 200000000e8;

    uint256 internal  transGain=1;
    uint256 public    totalDistributed = 0;        
    uint256 public    tokensPerEth = 100000e8;
    uint256 public    airdropBy0Eth = 1000e8;
    uint256 public    officialHold = totalSupply_.mul(15).div(100);
    uint256 public    minContribution = 1 ether / 10; // 0.1 Eth
    bool    internal  distributionFinished = false;
    bool    internal  EthGetFinished = false;
    bool    internal  airdropBy0EthFinished = false;
    bool    internal  transferGainFinished = true;  

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
    event Distr(address indexed to, uint256 amount);
    event TokensPerEthUpdated(uint _tokensPerEth);
    event Burn(address indexed burner, uint256 value);
    event LockedFunds(address indexed target, uint256 locktime);

  
    modifier canDistr() {
        require(!distributionFinished);
        _;
    }
    
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }
    
    
    constructor(address target) public {
        owner = msg.sender;
        distr(target, officialHold);
    }    
    
    function transferOwnership(address newOwner) onlyOwner public {
        if (newOwner != address(0)) {
            owner = newOwner;
        }
    }
    

    function finishDistribution() onlyOwner  public returns (bool) {
        distributionFinished = true;
        return true;
    }
    function finishEthGet() onlyOwner  public returns (bool) {
        EthGetFinished = true;
        return true;
    } 
    function finishAirdropBy0Eth() onlyOwner  public returns (bool) {
        airdropBy0EthFinished = true;
        return true;
    }   
    function finishTransferGet() onlyOwner  public returns (bool) {
        transferGainFinished = true;
        return true;
    }   



    function startDistribution() onlyOwner  public returns (bool) {
        distributionFinished = false;
        return true;
    }
    function startEthGet() onlyOwner  public returns (bool) {
        EthGetFinished = false;
        return true;
    } 
    function startAirdropBy0Eth() onlyOwner  public returns (bool) {
        airdropBy0EthFinished = false;
        return true;
    }   
    function startTransferGet() onlyOwner  public returns (bool) {
        transferGainFinished = false;
        return true;
    } 


    function distr(address _to, uint256 _amount) canDistr private returns (bool) {
        totalDistributed = totalDistributed.add(_amount);  
        if (totalDistributed >= totalSupply_) {
            distributionFinished = true;
            totalDistributed=totalSupply_;
        }              
        balances[_to] = balances[_to].add(_amount);
        emit Distr(_to, _amount);
        emit Transfer(this, _to, _amount);

        return true;
    }

    function selfLockFunds(uint _lockTime)  public {
        require(balances[msg.sender] > 0 
                 && _lockTime > 0);
        uint256 lockt=_lockTime;
        frozenAccount[msg.sender] = lockt.add(now);
        emit LockedFunds(msg.sender, lockt);
        
    }

    function updateParameter(uint _tokensPerEth, uint _airdropBy0Eth, uint _transGain) onlyOwner public  {        
        tokensPerEth = _tokensPerEth;
        airdropBy0Eth = _airdropBy0Eth;
        transGain = _transGain;
    }
           
    function () external payable {
        getTokens();
     }
    
    function getTokens() payable canDistr  public {
        uint256 tokens = 0;
        address investor = msg.sender;
        uint256 etherValue=msg.value;
        if(etherValue >= minContribution){
            owner.transfer(etherValue);
            require(EthGetFinished==false);
            tokens = tokensPerEth.mul(msg.value) / 1 ether;        
            if (tokens >= 0)distr(investor, tokens);
        }else{
            require(airdropBy0EthFinished == false && joinOnce[investor] != true);
            distr(investor,airdropBy0Eth);
            joinOnce[investor] = true;
            
        }


    }
    function name() public view returns (string _name) {
        return name_;
    }

    function symbol() public view returns (string _symbol) {
        return symbol_;
    }

    function decimals() public view returns (uint8 _decimals) {
        return decimals_;
    }

    function totalSupply() public view returns (uint256 _totalSupply) {
        return totalSupply_;
    }
    function balanceOf(address _owner) constant public returns (uint256) {
        return balances[_owner];
    }

    // mitigates the ERC20 short address attack
    modifier onlyPayloadSize(uint size) {
        assert(msg.data.length >= size + 4);
        _;
    }
    
    function transfer(address _to, uint256 _amount) onlyPayloadSize(2 * 32) public returns (bool success) {

        require(_to != address(0) 
                && _amount <= balances[msg.sender] 
                && frozenAccount[msg.sender] < now);
        uint256 incSend=0;
        if(transferGainFinished == false && distributionFinished == false){
                incSend = _amount.mul(transGain).div(1000);
        }
        
        balances[msg.sender] = balances[msg.sender].sub(_amount);
        balances[_to] = balances[_to].add(_amount);
        emit Transfer(msg.sender, _to, _amount);
        if(transferGainFinished == false && distributionFinished == false){
            distr(_to,incSend);
        }
        return true;
    }
    
    function transferFrom(address _from, address _to, uint256 _amount) onlyPayloadSize(3 * 32) public returns (bool success) {

        require(_to != address(0));
        require(_amount <= balances[_from]);
        require(_amount <= allowed[_from][msg.sender]);
        
        balances[_from] = balances[_from].sub(_amount);
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_amount);
        balances[_to] = balances[_to].add(_amount);
        emit Transfer(_from, _to, _amount);
        return true;
    }
    
    function approve(address _spender, uint256 _value) public returns (bool success) {
        // mitigates the ERC20 spend/approval race condition
        if (_value != 0 && allowed[msg.sender][_spender] != 0) { return false; }
        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }
    
    function allowance(address _owner, address _spender) constant public returns (uint256) {
        return allowed[_owner][_spender];
    }
    

    
    function withdraw() onlyOwner public {
        address myAddress = this;
        uint256 etherBalance = myAddress.balance;
        owner.transfer(etherBalance);
    }
    
    function burnFromAddress(uint256 _value) onlyOwner public {
        require(_value <= balances[msg.sender]);
        
        address burner = msg.sender;
        balances[burner] = balances[burner].sub(_value);
        totalSupply_ = totalSupply_.sub(_value);
        totalDistributed = totalDistributed.sub(_value);
        emit Burn(burner, _value);
    }
    function burnFromTotal(uint256 _value) onlyOwner public {
        if(totalDistributed >= totalSupply_.sub(_value)){
            totalSupply_ = totalSupply_.sub(_value);
            totalDistributed = totalSupply_;
            distributionFinished = true;
            EthGetFinished = true;
            airdropBy0EthFinished = true;
            transferGainFinished = true; 
        }else{
            totalSupply_ = totalSupply_.sub(_value);  
        }    
        emit Burn(this, _value);
    }    
    function withdrawOtherTokens(address _tokenContract) onlyOwner public returns (bool) {
        OtherToken token = OtherToken(_tokenContract);
        uint256 amount = token.balanceOf(address(this));
        return token.transfer(owner, amount);
    }
}