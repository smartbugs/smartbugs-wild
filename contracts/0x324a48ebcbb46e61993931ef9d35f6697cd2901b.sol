pragma solidity 0.4.19;

contract Owned {
    address public owner;
    address public pendingOwner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    function Owned() internal {
        owner = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0));
        pendingOwner = newOwner;
    }

    function acceptOwnership() public {
        require(msg.sender == pendingOwner);
        OwnershipTransferred(owner, pendingOwner);
        owner = pendingOwner;
        pendingOwner = address(0);
    }
}

contract Support is Owned {
    mapping (address => bool) public supportList;

    event SupportAdded(address indexed _who);
    event SupportRemoved(address indexed _who);


    modifier supportOrOwner {
        require(msg.sender == owner || supportList[msg.sender]);
        _;
    }

    function addSupport(address _who) public onlyOwner {
        require(_who != address(0));
        require(_who != owner);
        require(!supportList[_who]);
        supportList[_who] = true;
        SupportAdded(_who);
    }

    function removeSupport(address _who) public onlyOwner {
        require(supportList[_who]);
        supportList[_who] = false;
        SupportRemoved(_who);
    }
}

library SafeMath {
    function sub(uint a, uint b) internal pure returns (uint) {
        assert(b <= a);
        return a - b;
    }

    function add(uint a, uint b) internal pure returns (uint) {
        uint c = a + b;
        assert(c >= a);
        return c;
    }
}

contract MigrationAgent {
    function migrateFrom(address _from, uint256 _value) public;
}

// ERC20 interface https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20-token-standard.md
contract ERC20 {
    uint public totalSupply;
    function balanceOf(address who) public constant returns (uint balance);
    function allowance(address owner, address spender) public constant returns (uint remaining);
    function transfer(address to, uint value) public returns (bool success);
    function transferFrom(address from, address to, uint value) public returns (bool success);
    function approve(address spender, uint value) public returns (bool success);

    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);
}

contract Skraps is ERC20, Support {
    using SafeMath for uint;

    string public name = "Skraps";
    string public symbol = "SKRP";
    uint8 public decimals = 18;
    uint public totalSupply;

    uint private endOfFreeze = 1522569600; // Sun, 01 Apr 2018 00:00:00 PST
    uint private MAX_SUPPLY = 110000000 * 1 ether;

    address public migrationAgent;

    mapping (address => uint) private balances;
    mapping (address => mapping (address => uint)) private allowed;

    enum State { Enabled, Migration }
    State public state = State.Enabled;

    event Burn(address indexed from, uint256 value);

    function balanceOf(address _who) public constant returns (uint) {
        return balances[_who];
    }

    function allowance(address _owner, address _spender) public constant returns (uint remaining) {
        return allowed[_owner][_spender];
    }

    function Skraps() public {
        totalSupply = MAX_SUPPLY;
        balances[owner] = totalSupply;
        Transfer(0, owner, totalSupply);
    }

    function transfer(address _to, uint _value) public returns (bool success) {
        require(_to != address(0));
        require(now > endOfFreeze || msg.sender == owner || supportList[msg.sender]);
        require(balances[msg.sender] >= _value);
        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);
        Transfer(msg.sender, _to, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint _value) public returns (bool success) {
        require(_to != address(0));
        require(balances[_from] >= _value && allowed[_from][msg.sender] >= _value);
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
        balances[_from] = balances[_from].sub(_value);
        balances[_to] = balances[_to].add(_value);
        Transfer(_from, _to, _value);
        return true;
    }

    function approve(address _spender, uint _value) public returns (bool success) {
        require(_spender != address(0));
        require(now > endOfFreeze || msg.sender == owner || supportList[msg.sender]);
        require((_value == 0) || (allowed[msg.sender][_spender] == 0));
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }

    function setMigrationAgent(address _agent) public onlyOwner {
        require(state == State.Enabled);
        migrationAgent = _agent;
    }

    function startMigration() public onlyOwner {
        require(migrationAgent != address(0));
        require(state == State.Enabled);
        state = State.Migration;
    }

    function cancelMigration() public onlyOwner {
        require(state == State.Migration);
        require(totalSupply == MAX_SUPPLY);
        migrationAgent = address(0);
        state = State.Enabled;
    }

    function migrate() public {
        require(state == State.Migration);
        require(balances[msg.sender] > 0);
        uint value = balances[msg.sender];
        balances[msg.sender] = balances[msg.sender].sub(value);
        totalSupply = totalSupply.sub(value);
        Burn(msg.sender, value);
        MigrationAgent(migrationAgent).migrateFrom(msg.sender, value);
    }

    function manualMigrate(address _who) public supportOrOwner {
        require(state == State.Migration);
        require(balances[_who] > 0);
        uint value = balances[_who];
        balances[_who] = balances[_who].sub(value);
        totalSupply = totalSupply.sub(value);
        Burn(_who, value);
        MigrationAgent(migrationAgent).migrateFrom(_who, value);
    }

    function withdrawTokens(uint _value) public onlyOwner {
        require(balances[address(this)] > 0 && balances[address(this)] >= _value);
        balances[address(this)] = balances[address(this)].sub(_value);
        balances[msg.sender] = balances[msg.sender].add(_value);
        Transfer(address(this), msg.sender, _value);
    }

    function () payable public {
        require(state == State.Migration);
        require(msg.value == 0);
        migrate();
    }
}