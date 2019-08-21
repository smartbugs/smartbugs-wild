pragma solidity ^0.4.16;

/// @title SafeMath
/// @dev Math operations with safety checks that throw on error
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

/// @title ERC20 Standard Token interface
contract IERC20Token {
    function name() public constant returns (string) { name; }
    function symbol() public constant returns (string) { symbol; }
    function decimals() public constant returns (uint8) { decimals; }
    function totalSupply() public constant returns (uint256) { totalSupply; }
    function balanceOf(address _owner) public constant returns (uint256 balance) { _owner; balance; }
    function allowance(address _owner, address _spender) public constant returns (uint256 remaining) { _owner; _spender; remaining; }

    function transfer(address _to, uint256 _value) public returns (bool);
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool);
    function approve(address _spender, uint256 _value) public returns (bool);
}

/// @title ERC20 Standard Token implementation
contract ERC20Token is IERC20Token {
    using SafeMath for uint256;

    string public standard = 'Token 0.1';
    string public name = '';
    string public symbol = '';
    uint8 public decimals = 0;
    uint256 public totalSupply = 0;
    mapping (address => uint256) public balanceOf;
    mapping (address => mapping (address => uint256)) public allowance;

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);

    function ERC20Token(string _name, string _symbol, uint8 _decimals) {
        require(bytes(_name).length > 0 && bytes(_symbol).length > 0);
        name = _name;
        symbol = _symbol;
        decimals = _decimals;
    }

    modifier validAddress(address _address) {
        require(_address != 0x0);
        _;
    }

    function transfer(address _to, uint256 _value) public validAddress(_to) returns (bool) {
        balanceOf[msg.sender] = balanceOf[msg.sender].sub(_value);
        balanceOf[_to] = balanceOf[_to].add(_value);
        Transfer(msg.sender, _to, _value);
        
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public validAddress(_to) returns (bool) {
        allowance[_from][msg.sender] = allowance[_from][msg.sender].sub(_value);
        balanceOf[_from] = balanceOf[_from].sub(_value);
        balanceOf[_to] = balanceOf[_to].add(_value);
        Transfer(_from, _to, _value);
        return true;
    }

    function approve(address _spender, uint256 _value) public validAddress(_spender) returns (bool) {
        require(_value == 0 || allowance[msg.sender][_spender] == 0);
        allowance[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }
}

contract IOwned {
    function owner() public constant returns (address) { owner; }
    function transferOwnership(address _newOwner) public;
}

contract Owned is IOwned {
    address public owner;
    function Owned() {
        owner = msg.sender;
    }
    modifier validAddress(address _address) {
        require(_address != 0x0);
        _;
    }
    modifier onlyOwner {
        assert(msg.sender == owner);
        _;
    }
    function transferOwnership(address _newOwner) validAddress(_newOwner) onlyOwner {
        require(_newOwner != owner);
        
        owner = _newOwner;
    }
}

/// @title B2BX contract interface
contract ISmartToken {
    function initialSupply() public constant returns (uint256) { initialSupply; }

    function totalSoldTokens() public constant returns (uint256) { totalSoldTokens; }
    function totalProjectToken() public constant returns (uint256) { totalProjectToken; }

    function fundingEnabled() public constant returns (bool) { fundingEnabled; }
    function transfersEnabled() public constant returns (bool) { transfersEnabled; }
}

/// @title B2BX contract - crowdfunding code for B2BX Project
contract SmartToken is ISmartToken, ERC20Token, Owned {
    using SafeMath for uint256;
 
    // The current initial token supply.
    uint256 public initialSupply = 50000000 ether;

    // Cold wallet for distribution of tokens.
    address public fundingWallet;

    // The flag indicates if the B2BX contract is in Funding state.
    bool public fundingEnabled = true;

    // The maximum tokens available for sale.
    uint256 public maxSaleToken;

    // Total number of tokens sold.
    uint256 public totalSoldTokens;
    // Total number of tokens for B2BX Project.
    uint256 public totalProjectToken;
    uint256 private totalLockToken;

    // The flag indicates if the B2BX contract is in eneble / disable transfers.
    bool public transfersEnabled = true; 

    // Wallets, which allowed the transaction during the crowdfunding.
    mapping (address => bool) private fundingWallets;
    // Wallets B2BX Project, which will be locked the tokens
    mapping (address => allocationLock) public allocations;

    struct allocationLock {
        uint256 value;
        uint256 end;
        bool locked;
    }

    event Finalize(address indexed _from, uint256 _value);
    event Lock(address indexed _from, address indexed _to, uint256 _value, uint256 _end);
    event Unlock(address indexed _from, address indexed _to, uint256 _value);
    event DisableTransfers(address indexed _from);

    /// @notice B2BX Project - Initializing crowdfunding.
    /// @dev Constructor.
    function SmartToken() ERC20Token("B2BX", "B2BX", 18) {
        // The main, cold wallet for the distribution of tokens.
        fundingWallet = msg.sender; 

        // Initializing 80% of tokens for sale.
        // maxSaleToken = initialSupply * 80 / 100 (80% this is maxSaleToken & 100% this is initialSupply)
        // totalProjectToken will be calculated in function finalize()
        // 
        // |------------maxSaleToken------totalProjectToken|
        // |================80%================|====20%====|
        // |-----------------initialSupply-----------------|
        maxSaleToken = initialSupply.mul(80).div(100);

        balanceOf[fundingWallet] = maxSaleToken;
        totalSupply = initialSupply;

        fundingWallets[fundingWallet] = true;
        fundingWallets[0xEF02E1a87c91435349437f035F85F5a85f6b39ae] = true;
        fundingWallets[0xb0e5E17B43dAEcE47ABe3e81938063432A8D683d] = true;
        fundingWallets[0x67805701A5045092882cB4c7b066FF78Bb365938] = true;
        fundingWallets[0x80CD4388E7C54758aB2B3f1c810630aa653Ac932] = true;
        fundingWallets[0xfE51555Aea91768F0aA2fCb55705bd1C330Fb973] = true;
    }

    // Validates an address - currently only checks that it isn't null.
    modifier validAddress(address _address) {
        require(_address != 0x0);
        _;
    }

    modifier transfersAllowed(address _address) {
        if (fundingEnabled) {
            require(fundingWallets[_address]);
        }

        require(transfersEnabled);
        _;
    }

    /// @notice This function is disabled during the crowdfunding.
    /// @dev Send tokens.
    /// @param _to address      The address of the tokens recipient.
    /// @param _value _value    The amount of token to be transferred.
    function transfer(address _to, uint256 _value) public validAddress(_to) transfersAllowed(msg.sender) returns (bool) {
        return super.transfer(_to, _value);
    }

    /// @notice This function is disabled during the crowdfunding.
    /// @dev Send from tokens.
    /// @param _from address    The address of the sender of the token
    /// @param _to address      The address of the tokens recipient.
    /// @param _value _value    The amount of token to be transferred.
    function transferFrom(address _from, address _to, uint256 _value) public validAddress(_to) transfersAllowed(_from) returns (bool) {
        return super.transferFrom(_from, _to, _value);
    }

    /// @notice This function can accept for blocking no more than "totalProjectToken".
    /// @dev Lock tokens to a specified address.
    /// @param _to address      The address to lock tokens to.
    /// @param _value uint256   The amount of tokens to be locked.
    /// @param _end uint256     The end of the lock period.
    function lock(address _to, uint256 _value, uint256 _end) internal validAddress(_to) onlyOwner returns (bool) {
        require(_value > 0);

        assert(totalProjectToken > 0);

        // Check that this lock doesn't exceed the total amount of tokens currently available for totalProjectToken.
        totalLockToken = totalLockToken.add(_value);
        assert(totalProjectToken >= totalLockToken);

        // Make sure that a single address can be locked tokens only once.
        require(allocations[_to].value == 0);

        // Assign a new lock.
        allocations[_to] = allocationLock({
            value: _value,
            end: _end,
            locked: true
        });

        Lock(this, _to, _value, _end);

        return true;
    }

    /// @notice Only the owner of a locked wallet can unlock the tokens.
    /// @dev Unlock tokens at the address to the caller function.
    function unlock() external {
        require(allocations[msg.sender].locked);
        require(now >= allocations[msg.sender].end);
        
        balanceOf[msg.sender] = balanceOf[msg.sender].add(allocations[msg.sender].value);

        allocations[msg.sender].locked = false;

        Transfer(this, msg.sender, allocations[msg.sender].value);
        Unlock(this, msg.sender, allocations[msg.sender].value);
    }

    /// @notice B2BX Allocation - finalize crowdfunding & time-locked vault of tokens allocated
    /// to B2BX company, developers and bounty program.
    function finalize() external onlyOwner {
        require(fundingEnabled);

        // Get total sold tokens on the fundingWallet.
        // totalSoldTokens is 80% of the total number of tokens.
        totalSoldTokens = maxSaleToken.sub(balanceOf[fundingWallet]);

        // totalProjectToken = totalSoldTokens * 20 / 80 (20% this is B2BX Project & 80% this is totalSoldTokens)
        //
        // |----------totalSoldTokens-----totalProjectToken|
        // |================80%================|====20%====|
        // |totalSupply=(totalSoldTokens+totalProjectToken)|
        totalProjectToken = totalSoldTokens.mul(20).div(80);

        totalSupply = totalSoldTokens.add(totalProjectToken);

        // B2BX Prodject allocations tokens.
        // 40% of the totalProjectToken tokens (== 10% totalSupply) go to B2BX Company.
        lock(0x324044e0fB93A2D0274345Eba0E604B6F35826d2, totalProjectToken.mul(50).div(100), now);
        // 40% of the totalProjectToken tokens (== 8% totalSupply) go to developers.
        lock(0x6653f5e04ED6Ec6f004D345868f47f4CebAA095e, totalProjectToken.mul(40).div(100), (now + 6 * 30 days));
        // 10% of the totalProjectToken tokens (== 2% totalSupply) go to bounty program.
        lock(0x591e7CF52D6b3ccC452Cd435E3eA88c1032b0DE3, totalProjectToken.mul(10).div(100), now);
        
        // Zeroing a cold wallet.
        balanceOf[fundingWallet] = 0;

        // End of crowdfunding.
        fundingEnabled = false;

        // End of crowdfunding.
        Transfer(this, fundingWallet, 0);
        Finalize(msg.sender, totalSupply);
    }

    /// @notice Disable all transfers in case of a vulnerability found in the contract or other systems.
    /// @dev Disable transfers in B2BX contract.
    function disableTransfers() external onlyOwner {
        require(transfersEnabled);

        transfersEnabled = false;

        DisableTransfers(msg.sender);
    }

    /// @dev Disable the hot wallets for transfers.
    /// @param _address address Address in fundingWallets[]
    function disableFundingWallets(address _address) external onlyOwner {
        require(fundingEnabled);
        require(fundingWallet != _address);
        require(fundingWallets[_address]);

        fundingWallets[_address] = false;
    }
}