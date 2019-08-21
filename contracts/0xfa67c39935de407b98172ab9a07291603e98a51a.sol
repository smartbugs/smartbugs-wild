pragma solidity ^0.4.18;

// Math operations with safety checks that throw on error

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

// Simpler version of ERC20 interface

contract ERC20Basic {
    uint256 _totalSupply;
    function balanceOf(address who) public constant returns (uint256);
    function transfer(address to, uint256 value) public returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
}

// Basic version of StandardToken, with no allowances

contract BasicToken is ERC20Basic {

    using SafeMath for uint256;

    mapping(address => uint256) balances;

    function transfer(address _to, uint256 _value) public returns (bool) {
        require(_to != address(0));
        require(_value <= balances[msg.sender]);
        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);
        Transfer(msg.sender, _to, _value);
        return true;
    }

    function balanceOf(address _owner) public constant returns (uint256 balance) {
        return balances[_owner];
    }
}

// ERC20 interface

contract ERC20 is ERC20Basic {
    function allowance(address owner, address spender) public constant returns (uint256);
    function transferFrom(address from, address to, uint256 value) public returns (bool);
    function approve(address spender, uint256 value) public returns (bool);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

// Standard ERC20 token - Implementation of the basic standard token

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
        require((_value == 0) || (allowed[msg.sender][_spender] == 0));
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }

    function allowance(address _owner, address _spender) public constant returns (uint256 remaining) {
        return allowed[_owner][_spender];
    }
}

// Burnable contract

contract Burnable is StandardToken {

    event Burn(address indexed burner, uint256 value);

    function burn(uint256 _value) public {

        require(_value > 0);
        require(_value <= balances[msg.sender]);

        address burner = msg.sender;

        balances[burner] = balances[burner].sub(_value);
        _totalSupply = _totalSupply.sub(_value);

        Burn(burner, _value);
    }
}

// Ownable contract

contract Ownable {

    address public owner;

    function Ownable() public {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0));
        owner = newOwner;
    }
}

// Carblox Token

contract CarbloxToken is StandardToken, Ownable, Burnable {

    string public constant name = "Carblox Token";
    string public constant symbol = "CRX";
    uint256 public constant decimals = 3;
    uint256 public constant initialSupply = 100000000 * 10**3;

    function CarbloxToken() public {
        _totalSupply = initialSupply;
        balances[msg.sender] = initialSupply;
    }
    
    function totalSupply() public constant returns (uint256) {
        return _totalSupply;
    }
}


// Carblox preICO contract

contract CarbloxPreICO is Ownable {

    using SafeMath for uint256;

    CarbloxToken token;

    uint256 public constant RATE = 7500;
    uint256 public constant START = 1510315200; // Fri, 10 Nov 2017 12:00
    uint256 public constant DAYS = 30;

    uint256 public constant initialTokens = 7801500 * 10**3;
    bool public initialized = false;
    uint256 public raisedAmount = 0;
    uint256 public participants = 0;

    event BoughtTokens(address indexed to, uint256 value);

    modifier whenSaleIsActive() {
        assert(isActive());
        _;
    }

    function CarbloxPreICO(address _tokenAddr) public {
        require(_tokenAddr != 0);
        token = CarbloxToken(_tokenAddr);
    }

    function initialize() public onlyOwner {
        require(initialized == false);
        require(tokensAvailable() == initialTokens);
        initialized = true;
    }

    function () public payable {
        require(msg.value >= 100000000000000000);
        buyTokens();
    }

    function buyTokens() public payable whenSaleIsActive {

        uint256 finneyAmount =  msg.value.div(1 finney);
        uint256 tokens = finneyAmount.mul(RATE);
        uint256 bonus = getBonus(tokens);
        
        tokens = tokens.add(bonus);

        BoughtTokens(msg.sender, tokens);
        raisedAmount = raisedAmount.add(msg.value);
        participants = participants.add(1);

        token.transfer(msg.sender, tokens);
        owner.transfer(msg.value);
    }

    function getBonus(uint256 _tokens) public constant returns (uint256) {

        require(_tokens > 0);
        
        if (START <= now && now < START + 5 days) {

            return _tokens.mul(30).div(100); // 30% days 1-5

        } else if (START + 5 days <= now && now < START + 10 days) {

            return _tokens.div(5); // 20% days 6-10

        } else if (START + 10 days <= now && now < START + 15 days) {

            return _tokens.mul(15).div(100); // 15% days 11-15

        } else if (START + 15 days <= now && now < START + 20 days) {

            return _tokens.div(10); // 10% days 16-20

        } else if (START + 20 days <= now && now < START + 25 days) {

            return _tokens.div(20); // 5% days 21-25

        } else {

            return 0;

        }
    }
    
    function isActive() public constant returns (bool) {
        return (
            initialized == true &&
            now >= START &&
            now <= START.add(DAYS * 1 days)
        );
    }

    function tokensAvailable() public constant returns (uint256) {
        return token.balanceOf(this);
    }

    function destroy() public onlyOwner {
        
        // Unsold tokens are burned
        
        uint256 balance = token.balanceOf(this);

        if (balance > 0) {
            token.burn(balance);
        }

        selfdestruct(owner);
    }
}