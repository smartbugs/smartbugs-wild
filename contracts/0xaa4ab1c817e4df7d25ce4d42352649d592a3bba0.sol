library SafeMath
{
  function mul(uint256 a, uint256 b) internal pure returns (uint256) 
  {
    uint256 c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) 
  {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) 
  {
    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal pure returns (uint256) 
  {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}

contract Ownable 
{
    address public owner;
    
    //  @dev The Ownable constructor sets the original `owner` of the contract to the sender
    //  account.
    function Ownable() public 
    {
        owner = msg.sender;
    }

    //  @dev Throws if called by any account other than the owner. 
    modifier onlyOwner() 
    {
        require(msg.sender == owner);
        _;
    }
    
    //  @dev Allows the current owner to transfer control of the contract to a newOwner.
    //  @param newOwner The address to transfer ownership to. 
    function transferOwnership(address newOwner) public onlyOwner
    {
        if (newOwner != address(0)) 
        {
            owner = newOwner;
        }
    }
}

contract BasicToken
{
    using SafeMath for uint256;
    
     //  Total number of Tokens
    uint totalCoinSupply;
    
    //  allowance map
    //  ( owner => (spender => amount ) ) 
    mapping (address => mapping (address => uint256)) public AllowanceLedger;
    
    //  ownership map
    //  ( owner => value )
    mapping (address => uint256) public balanceOf;

    //  @dev transfer token for a specified address
    //  @param _to The address to transfer to.
    //  @param _value The amount to be transferred.
    function transfer( address _recipient, uint256 _value ) public 
        returns( bool success )
    {
        balanceOf[msg.sender] = balanceOf[msg.sender].sub(_value);
        balanceOf[_recipient] = balanceOf[_recipient].add(_value);
        Transfer(msg.sender, _recipient, _value);
        return true;
    }
    
    function transferFrom( address _owner, address _recipient, uint256 _value ) 
        public returns( bool success )
    {
        var _allowance = AllowanceLedger[_owner][msg.sender];
        // Check is not needed because sub(_allowance, _value) will already 
        //  throw if this condition is not met
        // require (_value <= _allowance);

        balanceOf[_recipient] = balanceOf[_recipient].add(_value);
        balanceOf[_owner] = balanceOf[_owner].sub(_value);
        AllowanceLedger[_owner][msg.sender] = _allowance.sub(_value);
        Transfer(_owner, _recipient, _value);
        return true;
    }
    
    function approve( address _spender, uint256 _value ) 
        public returns( bool success )
    {
        //  _owner is the address of the owner who is giving approval to
        //  _spender, who can then transact coins on the behalf of _owner
        address _owner = msg.sender;
        AllowanceLedger[_owner][_spender] = _value;
        
        //  Fire off Approval event
        Approval( _owner, _spender, _value);
        return true;
    }
    
    function allowance( address _owner, address _spender ) public constant 
        returns ( uint256 remaining )
    {
        //  returns the amount _spender can transact on behalf of _owner
        return AllowanceLedger[_owner][_spender];
    }
    
    function totalSupply() public constant returns( uint256 total )
    {  
        return totalCoinSupply;
    }

    //  @dev Gets the balance of the specified address.
    //  @param _owner The address to query the the balance of. 
    //  @return An uint256 representing the amount owned by the passed address.
    function balanceOf(address _owner) public constant returns (uint256 balance)
    {
        return balanceOf[_owner];
    }
    
    event Transfer( address indexed _owner, address indexed _recipient, uint256 _value );
    event Approval( address _owner, address _spender, uint256 _value );

}

contract AnkorusToken is BasicToken, Ownable
{
    using SafeMath for uint256;
    
    // Token Cap for each rounds
    uint256 public saleCap;

    // Address where funds are collected.
    address public wallet;
    
    // Sale period.
    uint256 public startDate;
    uint256 public endDate;

    // Amount of raised money in wei.
    uint256 public weiRaised;
    
    //  Tokens rate formule
    uint256 public tokensSold = 0;
    uint256 public tokensPerTrunche = 2000000;
    
    //  Whitelist approval mapping
    mapping (address => bool) public whitelist;
    bool public finalized = false;
    
   //  This is the 'Ticker' symbol and name for our Token.
    string public constant symbol = "ANK";
    string public constant name = "AnkorusToken";
    
    //  This is for how your token can be fracionalized. 
    uint8 public decimals = 18; 
    
    // Events
    event TokenPurchase(address indexed purchaser, uint256 value, 
        uint256 tokenAmount);
    event CompanyTokenPushed(address indexed beneficiary, uint256 amount);
    event Burn( address burnAddress, uint256 amount);
    
    function AnkorusToken() public 
    {
    }
    
    //  @dev gets the sale pool balance
    //  @return tokens in the pool
    function supply() internal constant returns (uint256) 
    {
        return balanceOf[0xb1];
    }

    modifier uninitialized() 
    {
        require(wallet == 0x0);
        _;
    }

    //  @dev gets the current time
    //  @return current time
    function getCurrentTimestamp() public constant returns (uint256) 
    {
        return now;
    }
    
    //  @dev gets the current rate of tokens per ether contributed
    //  @return number of tokens per ether
    function getRateAt() public constant returns (uint256)
    {
        uint256 traunch = tokensSold.div(tokensPerTrunche);
        
        //  Price curve based on function at:
        //  https://github.com/AnkorusTokenIco/Smart-Contract/blob/master/Price_curve.png
        if     ( traunch == 0 )  {return 600;}
        else if( traunch == 1 )  {return 598;}
        else if( traunch == 2 )  {return 596;}
        else if( traunch == 3 )  {return 593;}
        else if( traunch == 4 )  {return 588;}
        else if( traunch == 5 )  {return 583;}
        else if( traunch == 6 )  {return 578;}
        else if( traunch == 7 )  {return 571;}
        else if( traunch == 8 )  {return 564;}
        else if( traunch == 9 )  {return 556;}
        else if( traunch == 10 ) {return 547;}
        else if( traunch == 11 ) {return 538;}
        else if( traunch == 12 ) {return 529;}
        else if( traunch == 13 ) {return 519;}
        else if( traunch == 14 ) {return 508;}
        else if( traunch == 15 ) {return 498;}
        else if( traunch == 16 ) {return 487;}
        else if( traunch == 17 ) {return 476;}
        else if( traunch == 18 ) {return 465;}
        else if( traunch == 19 ) {return 454;}
        else if( traunch == 20 ) {return 443;}
        else if( traunch == 21 ) {return 432;}
        else if( traunch == 22 ) {return 421;}
        else if( traunch == 23 ) {return 410;}
        else if( traunch == 24 ) {return 400;}
        else return 400;
    }
    
    //  @dev Initialize wallet parms, can only be called once
    //  @param _wallet - address of multisig wallet which receives contributions
    //  @param _start - start date of sale
    //  @param _end - end date of sale
    //  @param _saleCap - amount of coins for sale
    //  @param _totalSupply - total supply of coins
    function initialize(address _wallet, uint256 _start, uint256 _end,
                        uint256 _saleCap, uint256 _totalSupply)
                        public onlyOwner uninitialized
    {
        require(_start >= getCurrentTimestamp());
        require(_start < _end);
        require(_wallet != 0x0);
        require(_totalSupply > _saleCap);

        finalized = false;
        startDate = _start;
        endDate = _end;
        saleCap = _saleCap;
        wallet = _wallet;
        totalCoinSupply = _totalSupply;

        //  Set balance of company stock
        balanceOf[wallet] = _totalSupply.sub(saleCap);
        
        //  Log transfer of tokens to company wallet
        Transfer(0x0, wallet, balanceOf[wallet]);
        
        //  Set balance of sale pool
        balanceOf[0xb1] = saleCap;
        
        //  Log transfer of tokens to ICO sale pool
        Transfer(0x0, 0xb1, saleCap);
    }
    
    //  Fallback function is entry point to buy tokens
    function () public payable
    {
        buyTokens(msg.sender, msg.value);
    }

    //  @dev Internal token purchase function
    //  @param beneficiary - The address of the purchaser 
    //  @param value - Value of contribution, in ether
    function buyTokens(address beneficiary, uint256 value) internal
    {
        require(beneficiary != 0x0);
        require(value >= 0.1 ether);
        
        // Calculate token amount to be purchased
        uint256 weiAmount = value;
        uint256 actualRate = getRateAt();
        uint256 tokenAmount = weiAmount.mul(actualRate);

        //  Check our supply
        //  Potentially redundant as balanceOf[0xb1].sub(tokenAmount) will
        //  throw with insufficient supply
        require(supply() >= tokenAmount);

        //  Check conditions for sale
        require(saleActive());
        
        // Transfer
        balanceOf[0xb1] = balanceOf[0xb1].sub(tokenAmount);
        balanceOf[beneficiary] = balanceOf[beneficiary].add(tokenAmount);
        TokenPurchase(msg.sender, weiAmount, tokenAmount);
        
        //  Log the transfer of tokens
        Transfer(0xb1, beneficiary, tokenAmount);
        
        // Update state.
        uint256 updatedWeiRaised = weiRaised.add(weiAmount);
        
        //  Get the base value of tokens
        uint256 base = tokenAmount.div(1 ether);
        uint256 updatedTokensSold = tokensSold.add(base);
        weiRaised = updatedWeiRaised;
        tokensSold = updatedTokensSold;

        // Forward the funds to fund collection wallet.
        wallet.transfer(msg.value);
    }
    
    //  @dev whitelist a batch of addresses. Note:Expensive
    //  @param [] beneficiarys - Array set to whitelist
    function batchApproveWhitelist(address[] beneficiarys) 
        public onlyOwner
    {
        for (uint i=0; i<beneficiarys.length; i++) 
        {
            whitelist[beneficiarys[i]] = true;
        }
    }
    
    //  @dev Set whitelist for specified address
    //  @param beneficiary - The address to whitelist
    //  @param value - value to set (can set address to true or false)
    function setWhitelist(address beneficiary, bool inList) public onlyOwner
    {
        whitelist[beneficiary] = inList;
    }
    
    //  @dev Time remaining until official sale begins
    //  @returns time remaining, in seconds
    function getTimeUntilStart() public constant returns (uint256)
    {
        if(getCurrentTimestamp() >= startDate)
            return 0;
            
        return startDate.sub(getCurrentTimestamp());
    }
    
    
    //  @dev transfer tokens from one address to another
    //  @param _recipient - The address to receive tokens
    //  @param _value - number of coins to send
    //  @return true if no requires thrown
    function transfer( address _recipient, uint256 _value ) public returns(bool)
    {
        //  Check to see if the sale has ended
        require(finalized);
        
        //  transfer
        super.transfer(_recipient, _value);
        
        return true;
    }
    
    //  @dev push tokens from treasury stock to specified address
    //  @param beneficiary - The address to receive tokens
    //  @param amount - number of coins to push
    //  @param lockout - lockout time 
    function push(address beneficiary, uint256 amount) public 
        onlyOwner 
    {
        require(balanceOf[wallet] >= amount);

        // Transfer
        balanceOf[wallet] = balanceOf[wallet].sub(amount);
        balanceOf[beneficiary] = balanceOf[beneficiary].add(amount);
        
        //  Log transfer of tokens
        CompanyTokenPushed(beneficiary, amount);
        Transfer(wallet, beneficiary, amount);
    }
    
    //  @dev Burns tokens from sale pool remaining after the sale
    function finalize() public onlyOwner 
    {
        //  Can only finalize after after sale is completed
        require(getCurrentTimestamp() > endDate);

        //  Set finalized
        finalized = true;

        // Burn tokens remaining
        Burn(0xb1, balanceOf[0xb1]);
        totalCoinSupply = totalCoinSupply.sub(balanceOf[0xb1]);
        
        //  Log transfer to burn address
        Transfer(0xb1, 0x0, balanceOf[0xb1]);
        
        balanceOf[0xb1] = 0;
    }

    //  @dev check to see if the sale period is active
    //  @return true if sale active, false otherwise
    function saleActive() public constant returns (bool) 
    {
        //  Ability to purchase has begun for this purchaser with either 2 
        //  conditions: Sale has started 
        //  Or purchaser has been whitelisted to purchase tokens before The start date
        //  and the whitelistDate is active
        bool checkSaleBegun = (whitelist[msg.sender] && 
            getCurrentTimestamp() >= (startDate.sub(2 days))) || 
                getCurrentTimestamp() >= startDate;
        
        //  Sale of tokens can not happen after the ico date or with no
        //  supply in any case
        bool canPurchase = checkSaleBegun && 
            getCurrentTimestamp() < endDate &&
            supply() > 0;
            
        return(canPurchase);
    }
}