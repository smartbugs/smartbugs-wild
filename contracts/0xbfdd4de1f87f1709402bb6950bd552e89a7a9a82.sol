pragma solidity ^0.5.3;

contract Ownable 
{
    address private owner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() public 
    {
        owner = msg.sender;
    }

    modifier onlyOwner() 
    {
        require(msg.sender == owner, "Only owner can call this function.");
        _;
    }

    function isOwner() public view returns(bool) 
    {
        return msg.sender == owner;
    }

    function transferOwnership(address newOwner) public onlyOwner 
    {
        require(newOwner != address(0));
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }
}

contract IERC20
{
    uint256 public tokenTotalSupply;
    string private tokenName;
    string private tokenSymbol;
    
    function balanceOf(address who) external view returns (uint256);
    function allowance(address owner, address spender) external view returns (uint256);
    function transfer(address to, uint256 value) external returns (bool);
    function approve(address spender, uint256 value) external returns (bool);
    function transferFrom(address from, address to, uint256 value) external returns (bool);

    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function totalSupply() external view returns (uint256);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    function burnOwnTokens(uint256 amountToBurn) external;
    function setCrowdsale(address crowdsaleAddress, uint256 crowdsaleAmount) external;
}

contract IERC223 is IERC20
{
    function transfer(address to, uint value, bytes memory data) public returns (bool);
    function transferFrom(address from, address to, uint value, bytes memory data) public returns (bool);
    event Transfer(address indexed from, address indexed to, uint value, bytes data);
}

contract IERC223Receiver 
{ 
    function tokenFallback(address from, address sender, uint value, bytes memory data) public returns (bool);
}

contract IMigrationAgent
{
    function finalizeMigration() external;
    function migrateTokens(address owner, uint256 tokens) public;
}

contract IMigrationSource
{
    address private migrationAgentAddress;
    IMigrationAgent private migrationAgentContract;
    bool private isMigrated;

    event MigratedFrom(address indexed owner, uint256 tokens);

    function setMigrationAgent(address agent) external;
    function migrate() external;
    function finalizeMigration() external;
}

library SafeMath 
{
    function mul(uint256 a, uint256 b) internal pure returns (uint256) 
    {
        if (a == 0) 
        {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "Multiplying error.");
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) 
    {
        require(b > 0, "Division error.");
        uint256 c = a / b;
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) 
    {
        require(b <= a, "Subtraction error.");
        uint256 c = a - b;
        return c;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) 
    {
        uint256 c = a + b;
        require(c >= a, "Adding error.");
        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) 
    {
        require(b != 0, "Mod error.");
        return a % b;
    }
}

contract EggToken is IERC223, Ownable, IMigrationSource
{
    using SafeMath for uint256;

    uint256 private tokenTotalSupply;
    string private tokenName;
    string private tokenSymbol;
    uint8 private tokenDecimals;

    mapping (address => uint256) private balances;
    mapping (address => mapping (address => uint256)) private allowances;

    address private migrationAgentAddress;
    IMigrationAgent private migrationAgentContract;
    bool private isMigrated;
    bool private isCrowdsaleSet;
    
    address private owner;
    
    constructor(string memory name, 
                string memory symbol, 
                uint256 totalSupply, 
                address developmentTeamAddress, 
                uint256 developmentTeamBalance, 
                address marketingTeamAddress, 
                uint256 marketingTeamBalance, 
                address productTeamAddress, 
                uint256 productTeamBalance, 
                address airdropAddress,
                uint256 airdropBalance) public 
    {
        tokenName = name;
        tokenSymbol = symbol;
        tokenDecimals = 18;

        tokenTotalSupply = totalSupply;
        
        balances[developmentTeamAddress] = developmentTeamBalance;
        balances[marketingTeamAddress] = marketingTeamBalance;
        balances[productTeamAddress] = productTeamBalance;
        balances[airdropAddress] = airdropBalance;
    }

    function setCrowdsale(address crowdsaleAddress, uint256 crowdsaleBalance) onlyOwner validAddress(crowdsaleAddress) external
    {
        require(!isCrowdsaleSet, "Crowdsale address was already set.");
        isCrowdsaleSet = true;
        tokenTotalSupply = tokenTotalSupply.add(crowdsaleBalance);
        balances[crowdsaleAddress] = crowdsaleBalance;
    }
    
    function approve(address spender, uint256 value) validAddress(spender) external returns (bool) 
    {
        allowances[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }
    
    function transfer(address to, uint256 value) external returns (bool) 
    {
        return transfer(to, value, new bytes(0));
    }
    
    function transferFrom(address from, address to, uint256 value) external returns (bool)
    {
        return transferFrom(from, to, value, new bytes(0));
    }
    
    function transferBatch(address[] calldata to, uint256 value) external returns (bool) 
    {
        return transferBatch(to, value, new bytes(0));
    }

    function transfer(address to, uint256 value, bytes memory data) validAddress(to) enoughBalance(msg.sender, value) public returns (bool)
    {
        balances[msg.sender] = balances[msg.sender].sub(value);
        balances[to] = balances[to].add(value);
        if (isContract(to))
        {
            contractFallback(msg.sender, to, value, data);
        }
        emit Transfer(msg.sender, to, value, data);
        return true;
    }

    function transferFrom(address from, address to, uint256 value, bytes memory data) validAddress(to) enoughBalance(from, value) public returns (bool)
    {
        require(value <= allowances[from][msg.sender], "Transfer value exceeds the allowance.");

        balances[from] = balances[from].sub(value);
        balances[to] = balances[to].add(value);
        allowances[from][msg.sender] = allowances[from][msg.sender].sub(value);
        if (isContract(to))
        {
            contractFallback(from, to, value, data);
        }
        emit Transfer(from, to, value, data);
        return true;
    }

    function transferBatch(address[] memory to, uint256 value, bytes memory data) public returns (bool)
    {
        uint256 totalValue = value.mul(to.length);
        checkBalance(msg.sender, totalValue);
        balances[msg.sender] = balances[msg.sender].sub(totalValue);

        uint256 i = 0;
        while (i < to.length) 
        {
            checkAddressValidity(to[i]);
            balances[to[i]] = balances[to[i]].add(value);
            if (isContract(to[i]))
            {
                contractFallback(msg.sender, to[i], value, data);
            }
            emit Transfer(msg.sender, to[i], value, data);
            i++;
        }

        return true;
    }

    function contractFallback(address sender, address to, uint256 value, bytes memory data) private returns (bool) 
    {
        IERC223Receiver reciever = IERC223Receiver(to);
        return reciever.tokenFallback(msg.sender, sender, value, data);
    }

    function isContract(address to) internal view returns (bool) 
    {
        uint length;
        assembly { length := extcodesize(to) }
        return length > 0;
    }
    
    function increaseAllowance(address spender, uint256 addedValue) validAddress(spender) external returns (bool)
    {
        allowances[msg.sender][spender] = allowances[msg.sender][spender].add(addedValue);
        emit Approval(msg.sender, spender, allowances[msg.sender][spender]);
        return true;
    }
    
    function decreaseAllowance(address spender, uint256 subtractedValue) validAddress(spender) external returns (bool)
    {
        allowances[msg.sender][spender] = allowances[msg.sender][spender].sub(subtractedValue);
        emit Approval(msg.sender, spender, allowances[msg.sender][spender]);
        return true;
    }

    function burnOwnTokens(uint256 amountToBurn) enoughBalance(msg.sender, amountToBurn) external 
    {
        require(balances[msg.sender] >= amountToBurn, "Can't burn more tokens than you own.");
        tokenTotalSupply = tokenTotalSupply.sub(amountToBurn);
        balances[msg.sender] = balances[msg.sender].sub(amountToBurn);
        emit Transfer(msg.sender, address(0), amountToBurn, new bytes(0));
    }

    function transferAnyERC20Token(address tokenAddress, uint256 tokens) public onlyOwner returns (bool success) 
    {
        return IERC20(tokenAddress).transfer(owner, tokens);
    }

    function balanceOf(address balanceOwner) external view returns (uint256) 
    {
        return balances[balanceOwner];
    }
    
    function allowance(address balanceOwner, address spender) external view returns (uint256)
    {
        return allowances[balanceOwner][spender];
    }

    function name() external view returns(string memory) {
        return tokenName;
    }

    function symbol() external view returns(string memory) {
        return tokenSymbol;
    }

    function decimals() external view returns(uint8) {
        return tokenDecimals;
    }

    function totalSupply() external view returns (uint256) 
    {
        return tokenTotalSupply;
    }

    modifier validAddress(address _address) 
    {
        checkAddressValidity(_address);
        _;
    }

    modifier enoughBalance(address from, uint256 value) 
    {
        checkBalance(from, value);
        _;
    }

    function checkAddressValidity(address _address) internal view
    {
        require(_address != address(0), "The address can't be blank.");
        require(_address != address(this), "The address can't point to Egg smart contract.");
    }

    function checkBalance(address from, uint256 value) internal view
    {
        require(value <= balances[from], "Specified address has less tokens than required for this operation.");
    }
    
    function setMigrationAgent(address agent) onlyOwner validAddress(agent) external
    {
        require(migrationAgentAddress == address(0), "Migration Agent was specified already.");
        require(!isMigrated, 'Contract was already migrated.');
        migrationAgentAddress = agent;
        migrationAgentContract = IMigrationAgent(agent);
    }

    function migrate() external
    {
        require(migrationAgentAddress != address(0), "Migration is closed or haven't started.");

        uint256 migratedAmount = balances[msg.sender];
        require(migratedAmount > 0, "No tokens to migrate.");

        balances[msg.sender] = 0;
        emit MigratedFrom(msg.sender, migratedAmount);
        migrationAgentContract.migrateTokens(msg.sender, migratedAmount);
    }

    function finalizeMigration() external
    {
        require(msg.sender == migrationAgentAddress, "Only Migration Agent can finalize the migration.");
        migrationAgentAddress = address(0);
        isMigrated = true;
    }
}