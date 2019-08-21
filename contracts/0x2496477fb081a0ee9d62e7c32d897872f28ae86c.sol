pragma solidity ^0.4.15;

// ERC Token Standard #20 Interface
// https://github.com/ethereum/EIPs/issues/20
contract ERC20Interface
{
    function totalSupply() public constant returns (uint256);
    function balanceOf(address owner) public constant returns (uint256);
    function transfer(address to, uint256 value) public returns (bool);
    function transferFrom(address from, address to, uint256 value) public returns (bool);
    function approve(address spender, uint256 value) public returns (bool);
    function allowance(address owner, address spender) public constant returns (uint256);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

// Additional desired wallet functionality
contract ERC20Burnable is ERC20Interface
{
    function burn(uint256 value) returns (bool);

    event Burn(address indexed owner, uint256 value);
}

// Wallet implementation
contract VRTtoken is ERC20Burnable
{
    // Public data
    string public constant name = "VRT token";
    string public constant symbol = "VRT";
    uint256 public constant decimals = 9; 
    address public owner;  

    // Internal data
    uint256 private constant initialSupply = 100000000; // 100,000,000
    uint256 private currentSupply;
    mapping(address => uint256) private balances;
    mapping(address => mapping (address => uint256)) private allowed;

    function VRTtoken()
    {
        // Increase initial supply by appropriate factor to allow
        // for the desired number of decimals
        currentSupply = initialSupply * (10 ** uint(decimals));

        owner = msg.sender;
        balances[owner] = currentSupply - 478433206500000;
        balances[0xa878177D38B932D9E5C5DD5D6DF27759b07dC9E0] = 6000000000000;
        balances[0x5af0ddFa8DFb5F29b5D41bFf41A8ef109c3F7072] = 236250000000;
        balances[0x3082F7AFB5eC42a3E3e8a0524e443A561ff479A4] = 6817500000;
        balances[0x41f464D2341E8Aa1EDF74E9aedD9B551E340dEC9] = 307500000000;
        balances[0xc5DE97dE45cf59eaA97d89c68FaC549167B85D28] = 37500000000;
        balances[0x687Eab8387faFca0E894c7890571cb8885d06252] = 75000000000;
        balances[0xDB82638bA86A925BC56f0150Fa426642C3b69574] = 2250000000000;
        balances[0xB24673108d0e63238ad9b7cb16C26B65Ab0901ad] = 150000000000;
        balances[0xC50653E116b10f487b588eBCd5c1E4FfA49DD50e] = 3750000000000;
        balances[0xC0b6eBF6485fF134453e537139cAB5a340125287] = 3750000000000;
        balances[0xb8c180DD09E611ac253AB321650B8b5393D6A00C] = 1500000000000;
        balances[0x5EE6ffb12ba911D7e1299e8F7e31924B3e52564b] = 3000000000000;
        balances[0xFb8d70B3347f8BdAe3b9e7EAf7d623F721A91fCe] = 155921947000000;
        balances[0xd2993BdE19Aa51FbEb8AfBE336D1E21b1b1FA074] = 178257000000000;
        balances[0x4C84ED7adA883539F54c768932e9BBa8a9F1e784] = 117324947000000;
        balances[0xFb8d70B3347f8BdAe3b9e7EAf7d623F721A91fCe] = 5866245000000;
        Transfer(owner, 0xa878177D38B932D9E5C5DD5D6DF27759b07dC9E0, 6000000000000);
        Transfer(owner, 0x5af0ddFa8DFb5F29b5D41bFf41A8ef109c3F7072, 236250000000);
        Transfer(owner, 0x3082F7AFB5eC42a3E3e8a0524e443A561ff479A4, 6817500000);
        Transfer(owner, 0x41f464D2341E8Aa1EDF74E9aedD9B551E340dEC9, 307500000000);
        Transfer(owner, 0xc5DE97dE45cf59eaA97d89c68FaC549167B85D28, 37500000000);
        Transfer(owner, 0x687Eab8387faFca0E894c7890571cb8885d06252, 75000000000);
        Transfer(owner, 0xDB82638bA86A925BC56f0150Fa426642C3b69574, 2250000000000);
        Transfer(owner, 0xB24673108d0e63238ad9b7cb16C26B65Ab0901ad, 150000000000);
        Transfer(owner, 0xC50653E116b10f487b588eBCd5c1E4FfA49DD50e, 3750000000000);
        Transfer(owner, 0xC0b6eBF6485fF134453e537139cAB5a340125287, 3750000000000);
        Transfer(owner, 0xb8c180DD09E611ac253AB321650B8b5393D6A00C, 1500000000000);
        Transfer(owner, 0x5EE6ffb12ba911D7e1299e8F7e31924B3e52564b, 3000000000000);
        Transfer(owner, 0xFb8d70B3347f8BdAe3b9e7EAf7d623F721A91fCe, 155921947000000);
        Transfer(owner, 0xd2993BdE19Aa51FbEb8AfBE336D1E21b1b1FA074, 178257000000000);
        Transfer(owner, 0x4C84ED7adA883539F54c768932e9BBa8a9F1e784, 117324947000000);
        Transfer(owner, 0xFb8d70B3347f8BdAe3b9e7EAf7d623F721A91fCe, 5866245000000);
    }

    function totalSupply() public constant 
        returns (uint256)
    {
        return currentSupply;
    }

    function balanceOf(address tokenOwner) public constant 
        returns (uint256)
    {
        return balances[tokenOwner];
    }
  
    function transfer(address to, uint256 amount) public 
        returns (bool)
    {
        if (balances[msg.sender] >= amount && // Sender has enough?
            balances[to] + amount > balances[to]) // Transfer won't cause overflow?
        {
            balances[msg.sender] -= amount;
            balances[to] += amount;
            Transfer(msg.sender, to, amount);
            return true;
        } 
        else // Invalid transfer
        {
            return false;
        }
    }
  
    function transferFrom(address from, address to, uint256 amount) public 
        returns (bool)
    {
        if (balances[from] >= amount && // Account has enough?
            allowed[from][msg.sender] >= amount && // Sender can act for account for this amount?
            balances[to] + amount > balances[to]) // Transfer won't cause overflow?
        {
            balances[from] -= amount;
            allowed[from][msg.sender] -= amount;
            balances[to] += amount;
            Transfer(from, to, amount);
            return true;
        }
        else // Invalid transfer
        {
            return false;
        }
    }

    function approve(address spender, uint256 amount) public 
        returns (bool)
    {
        allowed[msg.sender][spender] = amount;
        Approval(msg.sender, spender, amount);
        return true;
    }

    function allowance(address tokenOwner, address spender) public constant 
        returns (uint256)
    {
        return allowed[tokenOwner][spender];
    }

    function burn(uint256 amount) public 
        returns (bool)
    {
        require(msg.sender == owner); // Only the owner can burn

        if (balances[msg.sender] >= amount) // Account has enough?
        {
            balances[msg.sender] -= amount;
            currentSupply -= amount;
            Burn(msg.sender, amount);
            return true;
        }
        else // Not enough to burn
        {
            return false;
        }
    }
}