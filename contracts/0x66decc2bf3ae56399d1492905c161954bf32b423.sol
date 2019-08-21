pragma solidity 0.4.24;

/**
 * SafeMath
 * */
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

/**
 *ERC20Basic
 */
contract ERC20Basic {
    function totalSupply() public view returns (uint256);
    function balanceOf(address who) public view returns (uint256);
    function transfer(address to, uint256 value) public returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
}


/**
 ERC20 interface
 */
contract ERC20 is ERC20Basic {
    function allowance(address owner, address spender) public view returns (uint256);
    function transferFrom(address from, address to, uint256 value) public returns (bool);
    function approve(address spender, uint256 value) public returns (bool);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}


/**
 * Basic token
 *
 */
contract BasicToken is ERC20Basic {
    using SafeMath for uint256;

    mapping(address => uint256) balances;

    uint256 public totalSupply_;

  
    function totalSupply() public view returns (uint256) {
        return totalSupply_;
    }

  
    function transfer(address _to, uint256 _value) public returns (bool) {
        require(msg.data.length>=(2*32)+4);
        require(_to != address(0));
        require(_value <= balances[msg.sender]);

        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);
        emit Transfer (msg.sender, _to, _value);
        return true;
    }

   
    function balanceOf(address _owner) public view returns (uint256 balance) {
        return balances[_owner];
    }
}

/**
 Standard ERC20 token
 */
contract StandardToken is ERC20, BasicToken {

    mapping (address => mapping (address => uint256)) internal allowed;

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
        require(_to != address(0));
        require(_value <= balances[_from]);
        require(_value <= allowed[_from][msg.sender]);

        balances[_from] = balances[_from].sub(_value);
        balances[_to] = balances[_to].add(_value);
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
        emit Transfer(_from, _to, _value);
        return true;
    }

   
    function approve(address _spender, uint256 _value) public returns (bool) {
        require(_value==0||allowed[msg.sender][_spender]==0);
        require(msg.data.length>=(2*32)+4);
        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    
    function allowance(address _owner, address _spender) public view returns (uint256) {
        return allowed[_owner][_spender];
    }

  
    function increaseApproval(address _spender, uint _addedValue) public returns (bool) {
        allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
        emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
        return true;
    }

   
    function decreaseApproval(address _spender, uint _subtractedValue) public returns (bool) {
        uint oldValue = allowed[msg.sender][_spender];
        if (_subtractedValue > oldValue) {
            allowed[msg.sender][_spender] = 0;
        } else {
            allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
        }
        emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
        return true;
    }
}

contract OpenDAOToken is StandardToken {
    string public name;
    string public symbol;
    uint8 public decimals;
    uint256 public precentDecimal=2;
    
    // miner and developer percent
    uint256 public minerAndDeveloperPercent=70;
    
    //open dao fund percent
    uint256 public openDaoFundPercent=10;
    
    //codecoin core team percent
    uint256 public codeCoinCoreTeamPercent=10;
    
    //cloudmine precent
    uint256 public mineralcloudFundPercent=10;
     
    
    // miner and developer Account
    address public minerAndDeveloperFundAccount;
    
    //open dao fund Account
    address public openDaoFundAccount;
    
    //codecoin core team Account
    address public codeCoinCoreTeamAccount;
    
    //cloudmine Account
    address public mineralcloudFundAccount;
    
    
    // miner and developer fund Balnace
    uint256 public minerAndDeveloperFundBalnace;
    
    //open dao fund Balnace
    uint256 public openDaoFundBalnace;
    
    //codecoin core team Balnace
    uint256 public codeCoinCoreTeamBalnace;
    
    //cloudmine Balnace
    uint256 public mineralcloudFundBalnace;


    //OpenDAOToken constructor
    constructor(string _name,string _symbol, uint8 _decimals, uint256 _initialSupply,
        address _minerAndDeveloperFundAccount,address _openDaoFundAccount,address _codeCoinCoreTeamAccount,address _mineralcloudFundAccount) public {
        //init name,symbol,decimal,totalSupply
        name = _name;
        symbol = _symbol;
        decimals = _decimals;
        totalSupply_ = _initialSupply*10**uint256(_decimals);
        
        //init account
        minerAndDeveloperFundAccount=_minerAndDeveloperFundAccount;
        openDaoFundAccount=_openDaoFundAccount;
        codeCoinCoreTeamAccount=_codeCoinCoreTeamAccount;
        mineralcloudFundAccount=_mineralcloudFundAccount;
        

        //compute balance
        minerAndDeveloperFundBalnace=totalSupply_.mul(minerAndDeveloperPercent).div(10 ** precentDecimal);
        openDaoFundBalnace=totalSupply_.mul(openDaoFundPercent).div(10 ** precentDecimal);
        codeCoinCoreTeamBalnace=totalSupply_.mul(codeCoinCoreTeamPercent).div(10 ** precentDecimal);
        mineralcloudFundBalnace=totalSupply_.mul(mineralcloudFundPercent).div(10 ** precentDecimal);
    
    
        //evaluate balanace for account
        balances[_minerAndDeveloperFundAccount]=minerAndDeveloperFundBalnace;
        balances[_openDaoFundAccount]=openDaoFundBalnace;
        balances[_codeCoinCoreTeamAccount]=codeCoinCoreTeamBalnace;
        balances[_mineralcloudFundAccount]=mineralcloudFundBalnace;
        
    }
    
    
    function transfer(address _to, uint256 _value) public returns (bool) {
       return super.transfer(_to, _value);
    } 
    
   
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
        return super.transferFrom(_from, _to, _value);
    }
     
     function() public payable{
         revert();
     }
}