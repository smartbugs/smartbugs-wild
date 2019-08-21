pragma solidity ^0.4.20;

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
    modifier onlyOwner { require(msg.sender == owner); _; }
    function Owned() public {
        owner = msg.sender;
    }
}

// ERC20Token
contract ERC20Token is ERC20 {
    using SafeMath for uint256;
    mapping(address => uint256) balances;
    mapping (address => mapping (address => uint256)) allowed;
    uint256 public totalToken; 


     /* Send coins */
    function transfer(address _to, uint256 _value) public returns (bool success) {
        if (balances[msg.sender] >= _value && _value > 0) 
        {
            balances[msg.sender] = balances[msg.sender].sub(_value);
            balances[_to] = balances[_to].add(_value);
            Transfer(msg.sender, _to, _value);
            return true;
        } 
        else 
        {
            return false;
        }
    }

    /* A contract attempts to get the coins */
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        if (balances[_from] >= _value && allowed[_from][msg.sender] >= _value && _value > 0) {
            balances[_from] = balances[_from].sub(_value);
            balances[_to] = balances[_to].add(_value);
            allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
            Transfer(_from, _to, _value);
            return true;
        } 
        else 
        {
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
        Approval(msg.sender, _spender, _value);
        return true;
    }

    function allowance(address _owner, address _spender) public view returns (uint256 remaining) {
        return allowed[_owner][_spender];
    }

}

contract DouDou is ERC20Token, Owned {

    string  public constant name = "DouDou Token";
    string  public constant symbol = "DouDou";
    uint256 public constant decimals = 18;
    uint256 public tokenDestroyed;
    address public yearteam;
    address public halfyearteam;
    uint public normal_trade_date = 1519837167; //new Date("yyyy-mm-ddT00:00:00").getTime()/1000
    uint public halfyearteam_trade_date = normal_trade_date + (24*60*60)/2;//(365*24*60*60)/2;
    uint public yearteam_trade_date     = normal_trade_date + (24*60*60);//(365*24*60*60);  

    event Burn(address indexed _from, uint256 _tokenDestroyed);

    function DouDou() public 
    {
        totalToken   = 200000000000000000000000000;
        yearteam     = 0x2cFD5263896aA51085FFaBF0183dA67F26e5789c;
        halfyearteam = 0x86BEa0b293dE7975aA9Dd49b8a52c0e10BD243dC;
        balances[msg.sender]    =  (totalToken*60) / 100; //owner 60%
        balances[halfyearteam]  =  (totalToken*20) / 100; //team1 20%
        balances[yearteam]      =  (totalToken*20) / 100; //team2 20%
    }
    
    /* Send coins */
    function transfer(address _to, uint256 _value) public returns (bool success) 
    {
        //time check
        if (msg.sender == yearteam && now < yearteam_trade_date) 
            revert();
        if (msg.sender == halfyearteam && now < halfyearteam_trade_date)
            revert();
        if (balances[msg.sender] >= _value && _value > 0) 
        {
            balances[msg.sender] = balances[msg.sender].sub(_value);
            balances[_to] = balances[_to].add(_value);
            Transfer(msg.sender, _to, _value);
            return true;
        } 
        else 
        {
            return false;
        }
    }

    function transferAnyERC20Token(address _tokenAddress, address _recipient, uint256 _amount) public onlyOwner returns (bool success) {
        return ERC20(_tokenAddress).transfer(_recipient, _amount);
    }

    function burn (uint256 _burntValue) public returns (bool success) 
    {
        require(balances[msg.sender] >= _burntValue && _burntValue > 0);
        balances[msg.sender] = balances[msg.sender].sub(_burntValue);
        totalToken = totalToken.sub(_burntValue);
        tokenDestroyed = tokenDestroyed.add(_burntValue);
        require (tokenDestroyed <= 100000000000000000000000000);
        Transfer(address(this), 0x0, _burntValue);
        Burn(msg.sender, _burntValue);
        return true;
    }

}