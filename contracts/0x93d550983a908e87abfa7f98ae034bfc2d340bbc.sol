// ERC Token Standard #20 Interface
interface ERC20 {
    // Get the total token supply
    function totalSupply() public constant returns (uint _totalSupply);
    // Get the account balance of another account with address _owner
    function balanceOf(address _owner) public constant returns (uint balance);
    // Send _value amount of tokens to address _to
    function transfer(address _to, uint _value) public returns (bool success);
    // Send _value amount of tokens from address _from to address _to
    function transferFrom(address _from, address _to, uint _value) public returns (bool success);
    // Allow _spender to withdraw from your account, multiple times, up to the _value amount.
    // If this function is called again it overwrites the current allowance with _value.
    // this function is required for some DEX functionality
    function approve(address _spender, uint _value) public returns (bool success);
    // Returns the amount which _spender is still allowed to withdraw from _owner
    function allowance(address _owner, address _spender) public constant returns (uint remaining);
    // Triggered when tokens are transferred.
    event Transfer(address indexed _from, address indexed _to, uint _value);
    // Triggered whenever approve(address _spender, uint256 _value) is called.
    event Approval(address indexed _owner, address indexed _spender, uint _value);
}

library SafeMath {
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a * b;
        assert(a == 0 || c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b > 0); // Solidity automatically throws when dividing by 0
        uint256 c = a / b;
        assert(a == b * c + a % b); // There is no case in which this doesn't hold
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

contract OnePay is ERC20 {

    // Ability to call SafeMath functions on uints.
    using SafeMath for uint256;

    // Token basic information
    string public constant name = "OnePay";
    string public constant symbol = "1PAY";
    uint256 public constant decimals = 18;

    // Director address
    address public director;

    // Balances for each account
    mapping(address => uint256) balances;

    // Owner of account approves the transfer of an amount to another account
    mapping(address => mapping(address => uint256)) allowed;

    // Public sale control
    bool public saleClosed;
    uint256 public currentSalePhase;
    uint256 public SALE = 9090;  // Pre-Sale tokens per eth
    uint256 public PRE_SALE = 16667; // Sale tokens per eth

    // Total supply of tokens
    uint256 public totalSupply;

    // Total funds received
    uint256 public totalReceived;

    // Total amount of coins minted
    uint256 public mintedCoins;

    // Hard Cap for the sale
    uint256 public hardCapSale;

    // Token Cap
    uint256 public tokenCap;

    /**
      * Functions with this modifier can only be executed by the owner
      */
    modifier onlyDirector()
    {
        assert(msg.sender == director);
        _;
    }

    /**
      * Constructor
      */
    function OnePay() public
    {
        // Create the initial director
        director = msg.sender;

        // setting the hardCap for sale
        hardCapSale = 100000000 * 10 ** uint256(decimals);

        // token Cap
        tokenCap = 500000000 * 10 ** uint256(decimals);

        // Set the total supply
        totalSupply = 0;

        // Initial sale phase is presale
        currentSalePhase = PRE_SALE;

        // total coins minted so far
        mintedCoins = 0;

        // total funds raised
        totalReceived = 0;

        saleClosed = true;
    }

    /**
      * Fallback function to be invoked when a value is sent without a function call.
      */
    function() public payable
    {
        // Make sure the sale is active
        require(!saleClosed);

        // Minimum amount is 0.02 eth
        require(msg.value >= 0.02 ether);

        // If 1400 eth is received switch the sale price
        if (totalReceived >= 1500 ether) {
            currentSalePhase = SALE;
        }

        // Calculate tokens to mint based on the "current sale phase"
        uint256 amount = msg.value.mul(currentSalePhase);

        // Make sure that mintedCoins don't exceed the hardcap sale
        require(mintedCoins + amount <= hardCapSale);

        // Check for totalSupply max amount
        balances[msg.sender] = balances[msg.sender].add(amount);

        // Increase the number of minted coins
        mintedCoins += amount;

        //Increase totalSupply by amount
        totalSupply += amount;

        // Track of total value received
        totalReceived += msg.value;

        Transfer(this, msg.sender, amount);
    }

    /**
      * Get Tokens for the company
      */
    function getCompanyToken(uint256 amount) public onlyDirector returns (bool success)
    {
        amount = amount * 10 ** uint256(decimals);

        require((totalSupply + amount) <= tokenCap);

        balances[director] = amount;

        totalSupply += amount;

        return true;
    }

    /**
	  * Lock the crowdsale
	  */
    function closeSale() public onlyDirector returns (bool success)
    {
        saleClosed = true;
        return true;
    }

    /**
      * Unlock the crowd sale.
      */
    function openSale() public onlyDirector returns (bool success)
    {
        saleClosed = false;
        return true;
    }

    /**
      * Set the price to pre-sale
      */
    function setPriceToPreSale() public onlyDirector returns (bool success)
    {
        currentSalePhase = PRE_SALE;
        return true;
    }

    /**
      * Set the price to reg sale.
      */
    function setPriceToRegSale() public onlyDirector returns (bool success)
    {
        currentSalePhase = SALE;
        return true;
    }

    /**
      * Withdraw funds from the contract
      */
    function withdrawFunds() public onlyDirector
    {
        director.transfer(this.balance);
    }

    /**
      * Transfers the director to a new address
      */
    function transferDirector(address newDirector) public onlyDirector
    {
        director = newDirector;
    }

    /**
      * Returns total
      */
    function totalSupply() public view returns (uint256)
    {
        return totalSupply;
    }

    /**
      * Balance of a particular account
      */
    function balanceOf(address _owner) public constant returns (uint256)
    {
        return balances[_owner];
    }

    /**
      * Transfer balance from sender's account to receiver's account
      */
    function transfer(address _to, uint256 _value) public returns (bool success)
    {
        // Make sure the sender has enough value in their account
        assert(balances[msg.sender] >= _value && _value > 0);
        // Subtract value from sender's account
        balances[msg.sender] = balances[msg.sender].sub(_value);
        // Add value to receiver's account
        balances[_to] = balances[_to].add(_value);

        // Log
        Transfer(msg.sender, _to, _value);
        return true;
    }

    /**
      * Allow spender to spend the value amount on your behalf.
      * If this function is called again it overwrites the current allowance with _value.
      */
    function approve(address _spender, uint256 _value) public returns (bool)
    {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }

    /**
      * Spend value from a different account granted you have allowance to use the value amount.
      * If this function is called again it overwrites the current allowance with _value.
      */
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success)
    {
        assert(allowed[_from][msg.sender] >= _value && balances[_from] >= _value && _value > 0);
        balances[_from] = balances[_from].sub(_value);
        balances[_to] = balances[_to].add(_value);
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
        Transfer(_from, _to, _value);
        return true;
    }

    /**
      * Returns the amount which _spender is still allowed to withdraw from _owner
      */
    function allowance(address _owner, address _spender) public constant returns (uint256)
    {
        return allowed[_owner][_spender];
    }

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}