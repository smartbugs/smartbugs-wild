pragma solidity ^0.4.18;


contract SafeMath {
    function safeAdd(uint256 a, uint256 b) public pure returns (uint256 c) {
        c = a + b;
        require(c >= a);
    }

    function safeSub(uint256 a, uint256 b) public pure returns (uint256 c) {
        require(b <= a);
        c = a - b;
    }
}


contract ERC20Interface {
    function totalSupply() public view returns (uint256);
    function balanceOf(address tokenOwner) public view returns (uint256);
    function allowance(address tokenOwner, address spender) public view returns (uint256);
    function transfer(address to, uint256 tokens) public returns (bool);
    function approve(address spender, uint256 tokens) public returns (bool);
    function transferFrom(address from, address to, uint256 tokens) public returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint256 tokens);
}


// ----------------------------------------------------------------------------
// Owned contract
// ----------------------------------------------------------------------------
contract Owned {
    address public owner;

    event OwnershipTransferred(address indexed _from, address indexed _to);

    function Owned() public {
        owner = msg.sender;
    }

    function transferOwnership(address _newOwner) public {
        require(msg.sender == owner);
        owner = _newOwner;
    }
}


contract MigrationAgent {
    function migrateFrom(address _from, uint256 _value) public;
}


contract CHFToken is ERC20Interface, Owned, SafeMath {

    string constant public symbol = "CHFT";
    string constant public name = "CHF-Token";
    uint8 constant public decimals = 18;

    //SNB M3: 2018-01, 1036.941 Mrd. CHF
    uint256 public totalSupply = 1036941000000 * 10**uint256(decimals);
    address public migrationAgent = address(0);
    uint256 public totalMigrated = 0;

    mapping(address => uint256) public balances;
    mapping(address => mapping(address => uint256)) public allowed;

    event Migrate(address indexed _from, address indexed _to, uint256 _value);

    function CHFToken() public {
        balances[msg.sender] = totalSupply;
        Transfer(address(0), msg.sender, totalSupply);
    }

    function () public payable {
        revert();
    }

    function totalSupply() public view returns (uint256) {
        return totalSupply;
    }

    function balanceOf(address _tokenOwner) public view returns (uint256) {
        return balances[_tokenOwner];
    }

    function transfer(address _to, uint256 _tokens) public returns (bool) {
        balances[msg.sender] = safeSub(balances[msg.sender], _tokens);
        balances[_to] = safeAdd(balances[_to], _tokens);
        Transfer(msg.sender, _to, _tokens);
        return true;
    }

    function bulkTransfer(address[] _tos, uint256[] _tokens) public returns (bool) {

        for (uint i = 0; i < _tos.length; i++) {
            require(transfer(_tos[i], _tokens[i]));
        }

        return true;
    }

    function approve(address _spender, uint256 _tokens) public returns (bool) {
        allowed[msg.sender][_spender] = _tokens;
        Approval(msg.sender, _spender, _tokens);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _tokens) public returns (bool) {
        balances[_from] = safeSub(balances[_from], _tokens);
        allowed[_from][msg.sender] = safeSub(allowed[_from][msg.sender], _tokens);
        balances[_to] = safeAdd(balances[_to], _tokens);
        Transfer(_from, _to, _tokens);
        return true;
    }

    function allowance(address _tokenOwner, address _spender) public view returns (uint256) {
        return allowed[_tokenOwner][_spender];
    }

    /**
    * @dev migrate functionality
    */
    function migrate(uint256 _value) public {

        require(migrationAgent != address(0));
        require(_value > 0);
        require(_value <= balances[msg.sender]);

        balances[msg.sender] = safeSub(balances[msg.sender], _value);
        totalSupply = safeSub(totalSupply, _value);
        totalMigrated = safeAdd(totalMigrated, _value);

        MigrationAgent(migrationAgent).migrateFrom(msg.sender, _value);
        Migrate(msg.sender, migrationAgent, _value);
    }

    /**
    * @dev migrate functionality
    */
    function setMigrationAgent(address _agent) public {
        require(msg.sender == owner);        
        require(migrationAgent == address(0));

        migrationAgent = _agent;
    }
}