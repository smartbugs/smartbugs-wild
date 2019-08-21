pragma solidity ^0.4.18;

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a * b;
        assert(a == 0 || c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // assert(b > 0); // Solidity automatically throws when dividing by 0
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
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

contract SuperOwners {

    address public owner1;
    address public pendingOwner1;
    
    address public owner2;
    address public pendingOwner2;

    function SuperOwners(address _owner1, address _owner2) internal {
        require(_owner1 != address(0));
        owner1 = _owner1;
        
        require(_owner2 != address(0));
        owner2 = _owner2;
    }

    modifier onlySuperOwner1() {
        require(msg.sender == owner1);
        _;
    }
    
    modifier onlySuperOwner2() {
        require(msg.sender == owner2);
        _;
    }
    
    /** Any of the owners can execute this. */
    modifier onlySuperOwner() {
        require(isSuperOwner(msg.sender));
        _;
    }
    
    /** Is msg.sender any of the owners. */
    function isSuperOwner(address _addr) public view returns (bool) {
        return _addr == owner1 || _addr == owner2;
    }

    /** 
     * Safe transfer of ownership in 2 steps. Once called, a newOwner needs 
     * to call claimOwnership() to prove ownership.
     */
    function transferOwnership1(address _newOwner1) onlySuperOwner1 public {
        pendingOwner1 = _newOwner1;
    }
    
    function transferOwnership2(address _newOwner2) onlySuperOwner2 public {
        pendingOwner2 = _newOwner2;
    }

    function claimOwnership1() public {
        require(msg.sender == pendingOwner1);
        owner1 = pendingOwner1;
        pendingOwner1 = address(0);
    }
    
    function claimOwnership2() public {
        require(msg.sender == pendingOwner2);
        owner2 = pendingOwner2;
        pendingOwner2 = address(0);
    }
}

contract MultiOwnable is SuperOwners {

    mapping (address => bool) public ownerMap;
    address[] public ownerHistory;

    event OwnerAddedEvent(address indexed _newOwner);
    event OwnerRemovedEvent(address indexed _oldOwner);

    function MultiOwnable(address _owner1, address _owner2) 
        SuperOwners(_owner1, _owner2) internal {}

    modifier onlyOwner() {
        require(isOwner(msg.sender));
        _;
    }

    function isOwner(address owner) public view returns (bool) {
        return isSuperOwner(owner) || ownerMap[owner];
    }
    
    function ownerHistoryCount() public view returns (uint) {
        return ownerHistory.length;
    }

    // Add extra owner
    function addOwner(address owner) onlySuperOwner public {
        require(owner != address(0));
        require(!ownerMap[owner]);
        ownerMap[owner] = true;
        ownerHistory.push(owner);
        OwnerAddedEvent(owner);
    }

    // Remove extra owner
    function removeOwner(address owner) onlySuperOwner public {
        require(ownerMap[owner]);
        ownerMap[owner] = false;
        OwnerRemovedEvent(owner);
    }
}

contract ERC20 {

    uint256 public totalSupply;

    function balanceOf(address _owner) public view returns (uint256 balance);

    function transfer(address _to, uint256 _value) public returns (bool success);

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);

    function approve(address _spender, uint256 _value) public returns (bool success);

    function allowance(address _owner, address _spender) public view returns (uint256 remaining);

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}

contract StandardToken is ERC20 {
    
    using SafeMath for uint;

    mapping(address => uint256) balances;
    
    mapping(address => mapping(address => uint256)) allowed;

    function balanceOf(address _owner) public view returns (uint256 balance) {
        return balances[_owner];
    }

    function transfer(address _to, uint256 _value) public returns (bool) {
        require(_to != address(0));
        require(_value > 0);
        require(_value <= balances[msg.sender]);
        
        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);
        Transfer(msg.sender, _to, _value);
        return true;
    }

    /// @dev Allows allowed third party to transfer tokens from one address to another. Returns success.
    /// @param _from Address from where tokens are withdrawn.
    /// @param _to Address to where tokens are sent.
    /// @param _value Number of tokens to transfer.
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
        require(_to != address(0));
        require(_value > 0);
        require(_value <= balances[_from]);
        require(_value <= allowed[_from][msg.sender]);
        
        balances[_to] = balances[_to].add(_value);
        balances[_from] = balances[_from].sub(_value);
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
        Transfer(_from, _to, _value);
        return true;
    }

    /// @dev Sets approved amount of tokens for spender. Returns success.
    /// @param _spender Address of allowed account.
    /// @param _value Number of approved tokens.
    function approve(address _spender, uint256 _value) public returns (bool) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }

    /// @dev Returns number of allowed tokens for given address.
    /// @param _owner Address of token owner.
    /// @param _spender Address of token spender.
    function allowance(address _owner, address _spender) public view returns (uint256 remaining) {
        return allowed[_owner][_spender];
    }
}

contract CommonToken is StandardToken, MultiOwnable {

    string public name;
    string public symbol;
    uint256 public totalSupply;
    uint8 public decimals = 18;
    string public version = 'v0.1';

    address public seller;     // The main account that holds all tokens at the beginning and during tokensale.

    uint256 public saleLimit;  // (e18) How many tokens can be sold in total through all tiers or tokensales.
    uint256 public tokensSold; // (e18) Number of tokens sold through all tiers or tokensales.
    uint256 public totalSales; // Total number of sales (including external sales) made through all tiers or tokensales.

    // Lock the transfer functions during tokensales to prevent price speculations.
    bool public locked = true;
    
    event SellEvent(address indexed _seller, address indexed _buyer, uint256 _value);
    event ChangeSellerEvent(address indexed _oldSeller, address indexed _newSeller);
    event Burn(address indexed _burner, uint256 _value);
    event Unlock();

    function CommonToken(
        address _owner1,
        address _owner2,
        address _seller,
        string _name,
        string _symbol,
        uint256 _totalSupplyNoDecimals,
        uint256 _saleLimitNoDecimals
    ) MultiOwnable(_owner1, _owner2) public {

        require(_seller != address(0));
        require(_totalSupplyNoDecimals > 0);
        require(_saleLimitNoDecimals > 0);

        seller = _seller;
        name = _name;
        symbol = _symbol;
        totalSupply = _totalSupplyNoDecimals * 1e18;
        saleLimit = _saleLimitNoDecimals * 1e18;
        balances[seller] = totalSupply;

        Transfer(0x0, seller, totalSupply);
    }
    
    modifier ifUnlocked(address _from, address _to) {
        require(!locked || isOwner(_from) || isOwner(_to));
        _;
    }
    
    /** Can be called once by super owner. */
    function unlock() onlySuperOwner public {
        require(locked);
        locked = false;
        Unlock();
    }

    function changeSeller(address newSeller) onlySuperOwner public returns (bool) {
        require(newSeller != address(0));
        require(seller != newSeller);

        address oldSeller = seller;
        uint256 unsoldTokens = balances[oldSeller];
        balances[oldSeller] = 0;
        balances[newSeller] = balances[newSeller].add(unsoldTokens);
        Transfer(oldSeller, newSeller, unsoldTokens);

        seller = newSeller;
        ChangeSellerEvent(oldSeller, newSeller);
        
        return true;
    }

    function sellNoDecimals(address _to, uint256 _value) public returns (bool) {
        return sell(_to, _value * 1e18);
    }

    function sell(address _to, uint256 _value) onlyOwner public returns (bool) {

        // Check that we are not out of limit and still can sell tokens:
        require(tokensSold.add(_value) <= saleLimit);

        require(_to != address(0));
        require(_value > 0);
        require(_value <= balances[seller]);

        balances[seller] = balances[seller].sub(_value);
        balances[_to] = balances[_to].add(_value);
        Transfer(seller, _to, _value);

        totalSales++;
        tokensSold = tokensSold.add(_value);
        SellEvent(seller, _to, _value);

        return true;
    }
    
    /**
     * Until all tokens are sold, tokens can be transfered to/from owner's accounts.
     */
    function transfer(address _to, uint256 _value) ifUnlocked(msg.sender, _to) public returns (bool) {
        return super.transfer(_to, _value);
    }

    /**
     * Until all tokens are sold, tokens can be transfered to/from owner's accounts.
     */
    function transferFrom(address _from, address _to, uint256 _value) ifUnlocked(_from, _to) public returns (bool) {
        return super.transferFrom(_from, _to, _value);
    }

    function burn(uint256 _value) public returns (bool) {
        require(_value > 0);
        require(_value <= balances[msg.sender]);

        balances[msg.sender] = balances[msg.sender].sub(_value) ;
        totalSupply = totalSupply.sub(_value);
        Transfer(msg.sender, 0x0, _value);
        Burn(msg.sender, _value);

        return true;
    }
}

contract RaceToken is CommonToken {
    
    function RaceToken() CommonToken(
        0x229B9Ef80D25A7e7648b17e2c598805d042f9e56, // __OWNER1__
        0xcd7cF1D613D5974876AfBfd612ED6AFd94093ce7, // __OWNER2__
        0x2821e1486D604566842FF27F626aF133FddD5f89, // __SELLER__
        'Coin Race',
        'RACE',
        100 * 1e6, // 100m tokens in total.
        70 * 1e6   // 70m tokens for sale.
    ) public {}
}