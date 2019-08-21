pragma solidity >=0.4.22 <0.6.0;

library SafeMath {
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
          return 0;
        }
        uint256 c = a * b;
        assert(c / a == b);
        return c;
    }
    
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a / b;
        return c;
    }
    
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }
    
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }
}

// ERC20 Interface
contract ERC20 {
    function totalSupply() public view returns (uint _totalSupply);
    function balanceOf(address _owner) public view returns (uint balance);
    function transfer(address _to, uint _value) public returns (bool success);
    function transferFrom(address _from, address _to, uint _value) public returns (bool success);
    function approve(address _spender, uint _value) public returns (bool success);
    function allowance(address _owner, address _spender) public view returns (uint remaining);
    event Transfer(address indexed _from, address indexed _to, uint _value);
    event Approval(address indexed _owner, address indexed _spender, uint _value);
}

contract Owned {
    address public owner;
    address public newOwner;
    modifier onlyOwner { require(msg.sender == owner); _; }
    event OwnerUpdate(address _prevOwner, address _newOwner);

    function Owned() public {
        owner = msg.sender;
    }

    function transferOwnership(address _newOwner) public onlyOwner {
        require(owner==msg.sender);
        require(_newOwner != owner);
        newOwner = _newOwner;
    }

    function acceptOwnership() public {
        require(msg.sender == newOwner);
        OwnerUpdate(owner, newOwner);
        owner = newOwner;
        newOwner = 0x0;
    }
}

// ERC20Token
contract ERC20Token is ERC20 {
    using SafeMath for uint256;
    mapping(address => uint256) balances;
    mapping (address => mapping (address => uint256)) allowed;
    mapping (address => mapping (address => uint256)) remainallowed;
    mapping(address => uint256) distBalances;  
    uint256 public totalToken; 
     uint256 public baseStartTime; //
     //debug value 
     uint256 debug_totalallower;
     uint256 debug_mondiff;
     uint256 debug_now;
     
     

    function transfer(address _to, uint256 _value) public returns (bool success) {
        if (balances[msg.sender] >= _value && _value > 0) {
            balances[msg.sender] = balances[msg.sender].sub(_value);
            balances[_to] = balances[_to].add(_value);
            Transfer(msg.sender, _to, _value);
            distBalances[_to] = distBalances[_to].add(_value);
            return true;
        } else {
            return false;
        }
    }
    

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
       
        if (balances[_from] >= _value && allowed[_from][msg.sender] >= _value && _value > 0) {
            balances[_from] = balances[_from].sub(_value);
            balances[_to] = balances[_to].add(_value);
            //allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
  
            
            Transfer(_from, _to, _value);
            return true;
        } else {
            return false;
        }
    }

    function totalSupply() public view returns (uint256) {
        return totalToken;
    }

    function balanceOf(address _owner) public view returns (uint256 balance) {
        return balances[_owner];
    }

    function approve(address _spender, uint256 _value) public returns (bool success) {
        require((_value == 0) || (allowed[msg.sender][_spender] == 0));
        allowed[msg.sender][_spender] = _value;
        remainallowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }
//总的额度
    function allowance(address _owner, address _spender) public view returns (uint256 remaining) {
        return allowed[_owner][_spender];
    }
    // 剩余的额度

  function remainallowance(address _owner, address _spender) public view returns (uint256 remaining) {
        return remainallowed[_owner][_spender];
    }
}





contract FGTToken is ERC20Token, Owned {

    string  public  name = "Food&GoodsChain";
    string  public  symbol = "FGT";
    uint256 public  decimals = 18;
    uint256 public tokenDestroyed;
      //list of distributed balance of each address to calculate restricted amount

    event Burn(address indexed _from, uint256 _tokenDestroyed, uint256 _timestamp);

    function FGTToken(string tokenName, string tokenSymbol,uint256 initialSupply) public {
    name=tokenName;
    symbol=tokenSymbol;
    totalToken = initialSupply * 10 ** uint256(decimals);
    
    balances[msg.sender] = totalToken;
    }
   function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
   //计算本期释放额度
   uint256 calfreeamount=freeAmount(_from,msg.sender);
    if(calfreeamount<_value){
        _value=calfreeamount;
    }
        if (balances[_from] >= _value && allowed[_from][msg.sender] >= _value && _value > 0) {
            balances[_from] = balances[_from].sub(_value);
            balances[_to] = balances[_to].add(_value);
            //allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
            remainallowed[_from][msg.sender] = remainallowed[_from][msg.sender].sub(_value);
            Transfer(_from, _to, _value);
            return true;
        } else {
            return false;
        }
    }

    function transferAnyERC20Token(address _tokenAddress, address _recipient, uint256 _amount) public onlyOwner returns (bool success) {
        return ERC20(_tokenAddress).transfer(_recipient, _amount);
    }

    function burn (uint256 _burntAmount) public returns (bool success) {
        require(balances[msg.sender] >= _burntAmount && _burntAmount > 0);
        balances[msg.sender] = balances[msg.sender].sub(_burntAmount);
        totalToken = totalToken.sub(_burntAmount);
        tokenDestroyed = tokenDestroyed.add(_burntAmount);
        require (tokenDestroyed <= totalToken);
        Transfer(address(this), 0x0, _burntAmount);
        Burn(msg.sender, _burntAmount, block.timestamp);
        return true;
    }
    
   
        
         function setStartTime(uint _startTime) public onlyOwner {
            require (msg.sender==owner);
            baseStartTime = _startTime;
        }
         /* 增发增发代币 */
        function  addToken(address target, uint256 mintedAmount)  public onlyOwner {
        require(target==owner);//仅仅对账户创建者增发
        balances[target] += mintedAmount;
        totalToken += mintedAmount;
        emit Transfer(0, msg.sender, mintedAmount);
        emit Transfer(msg.sender, target, mintedAmount);
    }
    
     function freeAmount(address _from,address user) public returns (uint256 amount) {
        uint256 totalallower= allowed[_from][user] ;
        debug_totalallower=totalallower;
        uint256 releseamount=0;
            //0) no restriction for founder
            if (user == owner) {
                return balances[user];
            }
        debug_now=now;
            //1) no free amount before base start time;
            if (now < baseStartTime) {
                return 0;
            }
 
            //2) calculate number of months passed since base start time;
            uint256 monthDiff =  now.sub(baseStartTime) / (30 days);
         debug_mondiff=monthDiff;
            //3) 大于50个月，所有剩余额度一次释放
            if (monthDiff > 50) {
              releseamount=remainallowed[_from][user];
                return releseamount;
            }
 
            //4) 到本期为止，总共允许释放额度
            uint256 unrestricted =totalallower.div( 50).add( (totalallower.div(50)).mul( monthDiff));
        
            //5) 总释放额度 -已经释放额度  (已经释放额度=（总额度 - 剩余额度）)
            if (unrestricted >remainallowed[_from][user]) {
                releseamount =remainallowed[_from][user];
            } else {
                //本期为止总释放额度 减去 已经释放额度（总额度 - 剩余额度）
                releseamount = unrestricted.sub(totalallower.sub(remainallowed[_from][user]));
            
            }
            if(releseamount>balanceOf(_from)){
                releseamount=balanceOf(_from);
            }
            return releseamount;
        }
       
}