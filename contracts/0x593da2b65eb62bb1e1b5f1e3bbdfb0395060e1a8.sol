pragma solidity ^ 0.4.18;

contract ERC20 {
  uint256 public totalsupply;
  function totalSupply() public constant returns(uint256 _totalSupply);
  function balanceOf(address who) public constant returns (uint256);
  function allowance(address owner, address spender) public constant returns (uint256);
  function transferFrom(address from, address to, uint256 value) public returns (bool ok);
  function approve(address spender, uint256 value) public returns (bool ok);
  function transfer(address to, uint256 value) public returns (bool ok);
  event Transfer(address indexed from, address indexed to, uint256 value);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {
    function mul(uint256 a, uint256 b) pure internal returns(uint256) {
        uint256 c = a * b;
        assert(a == 0 || c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) pure internal returns(uint256) {
        // assert(b > 0); // Solidity automatically throws when dividing by 0
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return c;
    }

    function sub(uint256 a, uint256 b) pure internal returns(uint256) {
        assert(b <= a);
        return a - b;
    }

    function add(uint256 a, uint256 b) pure internal returns(uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }
}

contract ShipBloc is ERC20 {
    
    using SafeMath
    for uint256;
    
    
    string public constant name = "ShipBloc Token";

    string public constant symbol = "SBLOC";

    uint8 public constant decimals = 18;

    uint256 public constant totalsupply = 82500000 * (10 ** 18);
    uint256 public constant teamAllocated = 14025000 * (10 ** 18);
    uint256 public constant maxPreSale1Token = 15000000 * (10 ** 18);
    uint256 public constant maxPreSale2Token = 30000000 * (10 ** 18);
    uint256 public totalUsedTokens = 0;
      
    mapping(address => uint256) balances;

    mapping(address => mapping(address => uint256)) allowed;
    
    address owner = 0x1067c593a9981eFF4a56056dD775627CBe9D9107;
    
    event supply(uint256 bnumber);

    event events(string _name);
    
    uint256 public no_of_tokens;
    
    uint preICO1Start;
    uint preICO1End;
    uint preICO2Start;
    uint preICO2End;
    uint ICOStart;
    uint ICOEnd;
    
    enum Stages {
        NOTSTARTED,
        PREICO1,
        PREICO2,
        ICO,
        ENDED
    }
    
    mapping(uint => Stages) stage;

    modifier onlyOwner() {
        if (msg.sender != owner) {
            revert();
        }
        _;
    }
   
    function ShipBloc(uint _preICO1Start,uint _preICO1End,uint _preICO2Start,uint _preICO2End,uint _ICOStart,uint _ICOEnd) public {
        balances[owner] = teamAllocated;      
        balances[address(this)] = SafeMath.sub(totalsupply,teamAllocated);
        stage[0]=Stages.NOTSTARTED;
        stage[1667]=Stages.PREICO1;
        stage[1000]=Stages.PREICO2;
        stage[715]=Stages.ICO;
        stage[1]=Stages.ENDED;
        preICO1Start=_preICO1Start;
        preICO1End=_preICO1End;
        preICO2Start=_preICO2Start;
        preICO2End=_preICO2End;
        ICOStart=_ICOStart;
        ICOEnd=_ICOEnd;
    }
    
    function () public payable {
        require(msg.value != 0);
        
        uint256 _price_tokn = checkStage();
        require(stage[_price_tokn] != Stages.NOTSTARTED && stage[_price_tokn] != Stages.ENDED);
        
        no_of_tokens = SafeMath.mul(msg.value , _price_tokn); 
        
        require(balances[address(this)] >= no_of_tokens);
        
        totalUsedTokens = SafeMath.add(totalUsedTokens,no_of_tokens);
        balances[address(this)] =SafeMath.sub(balances[address(this)],no_of_tokens);
        balances[msg.sender] = SafeMath.add(balances[msg.sender],no_of_tokens);
        Transfer(address(this), msg.sender, no_of_tokens);
        owner.transfer(this.balance);
   }
    
    function totalSupply() public constant returns(uint256) {
       return totalsupply;
    }
    
     function balanceOf(address sender) public constant returns(uint256 balance) {
        return balances[sender];
    }

    
    function transfer(address _to, uint256 _amount) public returns(bool success) {
        require(_to != address(0));
        require(stage[checkStage()] == Stages.ENDED);
        if (balances[msg.sender] >= _amount &&
            _amount > 0) {
         
            balances[msg.sender] = SafeMath.sub(balances[msg.sender],_amount);
            balances[_to] = SafeMath.add(balances[_to],_amount);
            Transfer(msg.sender, _to, _amount);

            return true;
        } else {
            return false;
        }
    }
    
    function checkStage() internal view returns(uint) {
        uint currentBlock = block.number;
        if (currentBlock < preICO1Start){
            return 0;    
        } else if (currentBlock < preICO1End) {
            require(maxPreSale1Token>totalUsedTokens);
            return 1667;    
        } else if (currentBlock < preICO2Start) {
            return 0;    
        } else if (currentBlock < preICO2End) {
            require(maxPreSale2Token>totalUsedTokens);
            return 1000;    
        } else if (currentBlock < ICOStart) {
            return 0;
        } else if (currentBlock < ICOEnd) {
            return 715;    
        }
        return 1;
    }
    
    function getStageandPrice() public view returns(uint,uint){
        return (checkStage(),uint(stage[checkStage()]));
    }
   
    function transferFrom(
        address _from,
        address _to,
        uint256 _amount
    ) public returns(bool success) {
            require(_from != address(0) && _to != address(0));
            require(stage[checkStage()] == Stages.ENDED);
            require(balances[_from] >= _amount && allowed[_from][msg.sender] >= _amount);    
                
            balances[_from] = SafeMath.sub(balances[_from],_amount);
            allowed[_from][msg.sender] = SafeMath.sub(allowed[_from][msg.sender], _amount);
            balances[_to] = SafeMath.add(balances[_to], _amount);
            Transfer(_from, _to, _amount);
            
            return true;
       
    }

    function approve(address _spender, uint256 _value) public returns (bool) {
        require((_value == 0) || (allowed[msg.sender][_spender] == 0));
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }

    function allowance(address _owner, address _spender) public constant returns(uint256 remaining) {
        return allowed[_owner][_spender];
    }

    function drain() external onlyOwner {
        owner.transfer(this.balance);
    }

    function drainToken() external onlyOwner {
        require(stage[checkStage()] == Stages.ENDED);
        balances[owner] = SafeMath.add(balances[owner],balances[address(this)]);
        Transfer(address(this), owner, balances[address(this)]);
        balances[address(this)] = 0;
    }

}