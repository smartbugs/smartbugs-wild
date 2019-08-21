pragma solidity 0.4.20;

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

// Support accounts using for change Ether price, manual migration and sending tokens during ICO, see endOfFreeze field
contract Support is Owned {
    mapping (address => bool) public supportAccounts;

    event SupportAdded(address indexed _who);
    event SupportRemoved(address indexed _who);

    modifier supportOrOwner {
        require(msg.sender == owner || supportAccounts[msg.sender]);
        _;
    }

    function addSupport(address _who) public onlyOwner {
        require(_who != address(0));
        require(_who != owner);
        require(!supportAccounts[_who]);
        supportAccounts[_who] = true;
        SupportAdded(_who);
    }

    function removeSupport(address _who) public onlyOwner {
        require(supportAccounts[_who]);
        supportAccounts[_who] = false;
        SupportRemoved(_who);
    }
}

// Math operations with safety checks that throw on error
library SafeMath {
    // Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
    function sub(uint a, uint b) internal pure returns (uint) {
        assert(b <= a);
        return a - b;
    }

    // Adds two numbers, throws on overflow.
    function add(uint a, uint b) internal pure returns (uint) {
        uint c = a + b;
        assert(c >= a);
        return c;
    }
}

// ERC20 interface https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20.md
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

// Interface for migration to a new contract address
contract MigrationAgent {
    function migrateFrom(address _from, uint256 _value) public;
}

contract AdvancedToken is ERC20, Support {
    using SafeMath for uint;

    uint internal MAX_SUPPLY = 110000000 * 1 ether;
    address public migrationAgent;

    mapping (address => uint) internal balances;

    enum State { Waiting, ICO, Running, Migration }
    State public state = State.Waiting;

    event NewState(State state);
    event Burn(address indexed from, uint256 value);

    /**
     * The migration process to transfer tokens to the new token contract, when in the contract, a sufficiently large
     * number of investors that the company can't cover a miner fees to transfer all tokens, this will
     * be used in the following cases:
     * 1. If a critical error is found in the contract
     * 2. When will be released and approved a new standard for digital identification ERC-725 or similar
     * @param _agent The new token contract
     */
    function setMigrationAgent(address _agent) public onlyOwner {
        require(state == State.Running);
        migrationAgent = _agent;
    }

    // Called after setMigrationAgent function to make sure that a new contract address is valid
    function startMigration() public onlyOwner {
        require(migrationAgent != address(0));
        require(state == State.Running);
        state = State.Migration;
        NewState(state);
    }

    // Migration can be canceled if tokens have not yet been sent to the new contract
    function cancelMigration() public onlyOwner {
        require(state == State.Migration);
        require(totalSupply == MAX_SUPPLY);
        migrationAgent = address(0);
        state = State.Running;
        NewState(state);
    }

    // Manual migration if someone has problems moving
    function manualMigrate(address _who) public supportOrOwner {
        require(state == State.Migration);
        require(_who != address(this));
        require(balances[_who] > 0);
        uint value = balances[_who];
        balances[_who] = balances[_who].sub(value);
        totalSupply = totalSupply.sub(value);
        Burn(_who, value);
        MigrationAgent(migrationAgent).migrateFrom(_who, value);
    }

    // Migrate the holder's tokens to a new contract and burn the holder's tokens on the current contract
    function migrate() public {
        require(state == State.Migration);
        require(balances[msg.sender] > 0);
        uint value = balances[msg.sender];
        balances[msg.sender] = balances[msg.sender].sub(value);
        totalSupply = totalSupply.sub(value);
        Burn(msg.sender, value);
        MigrationAgent(migrationAgent).migrateFrom(msg.sender, value);
    }

    // The withdraw of Tokens from the contract after the end of ICO
    function withdrawTokens(uint _value) public onlyOwner {
        require(state == State.Running || state == State.Migration);
        require(balances[address(this)] > 0 && balances[address(this)] >= _value);
        balances[address(this)] = balances[address(this)].sub(_value);
        balances[msg.sender] = balances[msg.sender].add(_value);
        Transfer(address(this), msg.sender, _value);
    }

    // The withdraw of Ether from the contract
    function withdrawEther(uint256 _value) public onlyOwner {
        require(this.balance >= _value);
        owner.transfer(_value);
    }
}

contract Crowdsale is AdvancedToken {
    uint internal endOfFreeze = 1522569600; // Sun, 01 Apr 2018 00:00:00 PST
    uint private tokensForSalePhase2;
    uint public tokensPerEther;

    address internal reserve = 0x4B046B05C29E535E152A3D9c8FB7540a8e15c7A6;

    function Crowdsale() internal {
        assert(reserve != address(0));
        tokensPerEther = 2000 * 1 ether; // Tokens ^ 18
        totalSupply = MAX_SUPPLY;
        uint MARKET_SHARE = 66000000 * 1 ether;
        uint tokensSoldPhase1 = 11110257 * 1 ether;
        tokensForSalePhase2 = MARKET_SHARE - tokensSoldPhase1;

        // Tokens for the Phase 2 are on the contract and not available to withdraw by owner during the ICO
        balances[address(this)] = tokensForSalePhase2;
        // Tokens for the Phase 1 are on the owner to distribution by manually processes
        balances[owner] = totalSupply - tokensForSalePhase2;

        assert(balances[address(this)] + balances[owner] == MAX_SUPPLY);
        Transfer(0, address(this), balances[address(this)]);
        Transfer(0, owner, balances[owner]);
    }

    // Setting the number of tokens to buy for 1 Ether, changes automatically by owner or support account
    function setTokensPerEther(uint _tokens) public supportOrOwner {
        require(state == State.ICO || state == State.Waiting);
        require(_tokens > 100 ether); // Min 100 tokens ^ 18
        tokensPerEther = _tokens;
    }

    // The payable function to buy Skraps tokens
    function () internal payable {
        require(msg.sender != address(0));
        require(state == State.ICO || state == State.Migration);
        if (state == State.ICO) {
            // The minimum ether to participate
            require(msg.value >= 0.01 ether);
            // Counting and sending tokens to the investor
            uint _tokens = msg.value * tokensPerEther / 1 ether;
            require(balances[address(this)] >= _tokens);
            balances[address(this)] = balances[address(this)].sub(_tokens);
            balances[msg.sender] = balances[msg.sender].add(_tokens);
            Transfer(address(this), msg.sender, _tokens);

            // send 25% of ether received to reserve address
            uint to_reserve = msg.value * 25 / 100;
            reserve.transfer(to_reserve);
        } else {
            require(msg.value == 0);
            migrate();
        }
    }

    // Start ISO manually because the block timestamp is not mean the current time
    function startICO() public supportOrOwner {
        require(state == State.Waiting);
        state = State.ICO;
        NewState(state);
    }

    // Since a contracts can not call itself, we must manually close the ICO
    function closeICO() public onlyOwner {
        require(state == State.ICO);
        state = State.Running;
        NewState(state);
    }

    // Anti-scam function, if the tokens are obtained by dishonest means, can be used only during ICO
    function refundTokens(address _from, uint _value) public onlyOwner {
        require(state == State.ICO);
        require(balances[_from] >= _value);
        balances[_from] = balances[_from].sub(_value);
        balances[address(this)] = balances[address(this)].add(_value);
        Transfer(_from, address(this), _value);
    }
}

/**
 * Standard ERC20 implementation, see the interface above,
 * with a small modification to block the transfer of tokens until a specific date, see endOfFreeze field
 */
contract Skraps is Crowdsale {
    using SafeMath for uint;

    string public name = "Skraps";
    string public symbol = "SKRP";
    uint8 public decimals = 18;

    mapping (address => mapping (address => uint)) private allowed;

    function balanceOf(address _who) public constant returns (uint) {
        return balances[_who];
    }

    function allowance(address _owner, address _spender) public constant returns (uint remaining) {
        return allowed[_owner][_spender];
    }

    function transfer(address _to, uint _value) public returns (bool success) {
        require(_to != address(0));
        require(balances[msg.sender] >= _value);
        require(now > endOfFreeze || msg.sender == owner || supportAccounts[msg.sender]);

        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);
        Transfer(msg.sender, _to, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint _value) public returns (bool success) {
        require(_to != address(0));
        require(balances[_from] >= _value);
        require(allowed[_from][msg.sender] >= _value);

        balances[_from] = balances[_from].sub(_value);
        balances[_to] = balances[_to].add(_value);
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
        Transfer(_from, _to, _value);
        return true;
    }

    function approve(address _spender, uint _value) public returns (bool success) {
        require(balances[msg.sender] >= _value);
        require(_spender != address(0));
        require(now > endOfFreeze || msg.sender == owner || supportAccounts[msg.sender]);
        require((_value == 0) || (allowed[msg.sender][_spender] == 0));

        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }
}