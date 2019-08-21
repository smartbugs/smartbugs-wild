pragma solidity ^0.4.18;

/**
 * @title SafeMath for performing valid mathematics.
 */
library SafeMath {
  function Mul (uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    assert(c / a == b);
    return c;
  }

  function Div (uint256 a, uint256 b) internal pure returns (uint256) {
    //assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  function Sub (uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function Add (uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}

/**
 * Contract "Ownable"
 * Purpose: Defines Owner for contract
 * Status : Complete
 * 
 */
contract Ownable {

	//owner variable to store contract owner account
  address public owner;

  //Constructor for the contract to store owner's account on deployement
  function Ownable() public {
    owner = msg.sender;
  }

  //modifier to check transaction initiator is only owner
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

}

// ERC20 Interface
contract ERC20 {
  uint256 public totalSupply;
  function balanceOf(address who) public view returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  function allowance(address owner, address spender) public view returns (uint256);
  function transferFrom(address from, address to, uint256 value) public returns (bool);
  function approve(address spender, uint256 value) public returns (bool);
  event Approval(address indexed owner, address indexed spender, uint256 value);
  event Transfer(address indexed from, address indexed to, uint256 value);
}

/**
 * @title GIZA to implement token
 */
contract GIZAToken is ERC20, Ownable {

    using SafeMath for uint256;
    //The name of the  token
    bytes32 public name;
    //The token symbol
    bytes32 public symbol;
    //The precision used in the calculations in contract
    uint8 public decimals;   
    //To denote the locking on transfer of tokens among token holders
    bool public locked;
	// Founder address. Need to froze for 8 moths
	address public founder;
	// Team address. Need to froze for 8 moths
	address public team;
	// Start of Pre-ICO date
	uint256 public start;
	
    //Mapping to relate number of  token to the account
    mapping(address => uint256 ) balances;
    //Mapping to relate owner and spender to the tokens allowed to transfer from owner
    mapping(address => mapping(address => uint256)) allowed;

    event Burn(address indexed burner, uint indexed value);  

    /**
    * @dev Constructor of GIZA
    */
    function GIZAToken(address _founder, address _team) public {
		require( _founder != address(0) && _team != address(0) );
        /* Public variables of the token */
        //The name of the  token
        name = "GIZA Token";
        //The token symbol
        symbol = "GIZA";
        //Number of zeroes to be treated as decimals
        decimals = 18;       
        //initial token supply 0
        totalSupply = 368e23; // 36 800 000 tokens total
        //Transfer of tokens is locked (not allowed) when contract is deployed
        locked = true;
		// Save founder and team address
		founder = _founder;
		team = _team;
		balances[msg.sender] = totalSupply;
		start = 0;
    }
      
	function startNow() external onlyOwner {
		start = now;
	}
	  
    //To handle ERC20 short address attack
    modifier onlyPayloadSize(uint256 size) {
       require(msg.data.length >= size + 4);
       _;
    }

    modifier onlyUnlocked() { 
      require (!locked); 
      _; 
    }
	
    modifier ifNotFroze() { 
		if ( 
		  (msg.sender == founder || msg.sender == team) && 
		  (start == 0 || now < (start + 80 days) ) ) revert();
		_;
    }
    
    //To enable transfer of tokens
    function unlockTransfer() external onlyOwner{
      locked = false;
    }

    /**
    * @dev Check balance of given account address
    *
    * @param _owner The address account whose balance you want to know
    * @return balance of the account
    */
    function balanceOf(address _owner) public view returns (uint256 _value){
        return balances[_owner];
    }

    /**
    * @dev Transfer tokens to an address given by sender
    *
    * @param _to The address which you want to transfer to
    * @param _value the amount of tokens to be transferred
    * @return A bool if the transfer was a success or not
    */
    function transfer(address _to, uint256 _value) onlyPayloadSize(2 * 32) onlyUnlocked ifNotFroze public returns(bool _success) {
        require( _to != address(0) );
        if((balances[msg.sender] > _value) && _value > 0){
			balances[msg.sender] = balances[msg.sender].Sub(_value);
			balances[_to] = balances[_to].Add(_value);
			Transfer(msg.sender, _to, _value);
			return true;
        }
        else{
            return false;
        }
    }

    /**
    * @dev Transfer tokens from one address to another, for ERC20.
    *
    * @param _from The address which you want to send tokens from
    * @param _to The address which you want to transfer to
    * @param _value the amount of tokens to be transferred
    * @return A bool if the transfer was a success or not
    */
    function transferFrom(address _from, address _to, uint256 _value) onlyPayloadSize(3 * 32) onlyUnlocked ifNotFroze public returns (bool success){
        require( _to != address(0) && (_from != address(0)));
        if((_value > 0)
           && (allowed[_from][msg.sender] > _value )){
            balances[_from] = balances[_from].Sub(_value);
            balances[_to] = balances[_to].Add(_value);
            allowed[_from][msg.sender] = allowed[_from][msg.sender].Sub(_value);
            Transfer(_from, _to, _value);
            return true;
        }
        else{
            return false;
        }
    }

    /**
    * @dev Function to check the amount of tokens that an owner has allowed a spender to recieve from owner.
    *
    * @param _owner address The address which owns the funds.
    * @param _spender address The address which will spend the funds.
    * @return A uint256 specifying the amount of tokens still available for the spender to spend.
    */
    function allowance(address _owner, address _spender) public view returns (uint256){
        return allowed[_owner][_spender];
    }

    /**
    * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.
    *
    * @param _spender The address which will spend the funds.
    * @param _value The amount of tokens to be spent.
    */
    function approve(address _spender, uint256 _value) public returns (bool){
        if( (_value > 0) && (_spender != address(0)) && (balances[msg.sender] >= _value)){
            allowed[msg.sender][_spender] = _value;
            Approval(msg.sender, _spender, _value);
            return true;
        }
        else{
            return false;
        }
    }
    
    // Only owner can burn own tokens
    function burn(uint _value) public onlyOwner {
        require(_value > 0);
        address burner = msg.sender;
        balances[burner] = balances[burner].Sub(_value);
        totalSupply = totalSupply.Sub(_value);
        Burn(burner, _value);
    }

}

contract Crowdsale is Ownable {
    
    using SafeMath for uint256;
    GIZAToken token;
    address public token_address;
    address public owner;
    address founder;
    address team;
    address multisig;
    bool started = false;
    //price of token against 1 ether
    uint256 public dollarsForEther;
    //No of days for which pre ico will be open
    uint256 constant DURATION_PRE_ICO = 30;
    uint256 startBlock = 0; // Start timestamp
    uint256 tokensBought = 0; // Amount of bought tokens
    uint256 totalRaisedEth = 0; // Total raised ETH

    uint256 constant MAX_TOKENS_FIRST_7_DAYS_PRE_ICO  = 11000000 * 1 ether; // 10 000 000 + 10%
	uint256 constant MAX_TOKENS_PRE_ICO    				    = 14850000 * 1 ether; // max 14 850 000 tokens
    uint256 constant MAX_TOKENS_FIRST_5_DAYS_ICO        = 3850000 * 1 ether;   // 3 500 000 + 10%
    uint256 constant MAX_TOKENS_FIRST_10_DAYS_ICO      	= 10725000 * 1 ether; // 9 750 000 + 10%
    uint256 constant MAX_BOUNTY      	                			= 1390000 * 1 ether;
    uint256 bountySent = 0;
    enum CrowdsaleType { PreICO, ICO }
    CrowdsaleType etype = CrowdsaleType.PreICO;
    
    
    function Crowdsale(address _founder, address _team, address _multisig) public {
        require(_founder != address(0) && _team != address(0) && _multisig != address(0));
        owner = msg.sender;
        team = _team;
        multisig = _multisig;
        founder = _founder;
        token = new GIZAToken(_founder, _team);
        token_address = address(token);
    }
    
    modifier isStarted() {
        require (started == true);
        _;
    }
    
    // Set current price of one Ether in dollars
    function setDollarForOneEtherRate(uint256 _dollars) public onlyOwner {
        dollarsForEther = _dollars;
    }
    
    function sendBounty(address _to, uint256 _amount) public onlyOwner returns(bool){
        require(_amount != 0 && _to != address(0));
        token.unlockTransfer();
        uint256 totalToSend = _amount.Mul(1 ether);
        require(bountySent.Add(totalToSend) < MAX_BOUNTY);
        if ( transferTokens(_to, totalToSend) ){
                bountySent = bountySent.Add(totalToSend);
                return true;
        }else
            return false;        
    }
    
    function sendTokens(address _to, uint256 _amount) public onlyOwner returns(bool){
        require(_amount != 0 && _to != address(0));
        token.unlockTransfer();
        return transferTokens(_to, _amount.Mul(1 ether));
    } 
  
    //To start Pre ICO
    function startPreICO(uint256 _dollarForOneEtherRate) public onlyOwner {
        require(startBlock == 0 && _dollarForOneEtherRate > 0);
        //Set block number to current block number
        startBlock = now;
        //to show pre Ico is running
        etype = CrowdsaleType.PreICO;
        started = true;
        dollarsForEther = _dollarForOneEtherRate;
        token.startNow();
        token.unlockTransfer();
    }
	
	// Finish pre ICO.
	function endPreICO() public onlyOwner {
		started = false;
	}
  
    //to start ICO
    function startICO(uint256 _dollarForOneEtherRate) public onlyOwner{
        //ico can be started only after the end of pre ico
        require( startBlock != 0 && now > startBlock.Add(DURATION_PRE_ICO) );
        startBlock = now;
        //to show iCO IS running
        etype = CrowdsaleType.ICO;
        started = true;
        dollarsForEther = _dollarForOneEtherRate;
    }
    
    // Get current price of token on current time interval
    function getCurrentTokenPriceInCents() public view returns(uint256){
        require(startBlock != 0);
        uint256 _day = (now - startBlock).Div(1 days);
        // Pre-ICO
        if (etype == CrowdsaleType.PreICO){
            require(_day <= DURATION_PRE_ICO && tokensBought < MAX_TOKENS_PRE_ICO);
            if (_day >= 0 && _day <= 7 && tokensBought < MAX_TOKENS_FIRST_7_DAYS_PRE_ICO)
                return 20; // $0.2
			else
                return 30; // $0.3
        // ICO
        } else {
            if (_day >= 0 && _day <= 5 && tokensBought < MAX_TOKENS_FIRST_5_DAYS_ICO)
                return 60; // $0.6 
            else if (_day > 5 && _day <= 10 && tokensBought < MAX_TOKENS_FIRST_10_DAYS_ICO)
                return 80; // $0.8 
            else
                return 100; // $1 
        }        
    }
    
    // Calculate tokens to send
    function calcTokensToSend(uint256 _value) internal view returns (uint256){
        require (_value > 0);
        
        // Current token price in cents
        uint256 currentTokenPrice = getCurrentTokenPriceInCents();
        
        // Calculate value in dollars*100
        // _value in dollars * 100 
        // Example: for $54.38 valueInDollars = 5438        
        uint256 valueInDollars = _value.Mul(dollarsForEther).Div(10**16);
        uint256 tokensToSend = valueInDollars.Div(currentTokenPrice);
        
        // Calculate bonus by purshase
        uint8 bonusPercent = 0;
        _value = _value.Div(1 ether).Mul(dollarsForEther);
        if ( _value >= 35000 ){
            bonusPercent = 10;
        }else if ( _value >= 20000 ){
            bonusPercent = 7;
        }else if ( _value >= 10000 ){
            bonusPercent = 5;
        }
        // Add bonus tokens
        if (bonusPercent > 0) tokensToSend = tokensToSend.Add(tokensToSend.Div(100).Mul(bonusPercent));
        
        return tokensToSend;
    }    

    // Transfer funds to owner
    function forwardFunds(uint256 _value) internal {
        multisig.transfer(_value);
    }

    // transfer tokens
    function transferTokens(address _to, uint256 _tokensToSend) internal returns(bool){
        uint256 tot = _tokensToSend.Mul(1222).Div(8778); // 5.43 + 6.79 = 12.22, 10000 - 1222 = 8778 
        uint256 tokensForTeam = tot.Mul(4443).Div(1e4);// 5.43% for Team (44,43% of (5.43 + 6.79) )
        uint256 tokensForFounder = tot.Sub(tokensForTeam);// 6.79% for Founders
        uint256 totalToSend = _tokensToSend.Add(tokensForFounder).Add(tokensForTeam);
        if (token.balanceOf(this) >= totalToSend && 
            token.transfer(_to, _tokensToSend) == true){
                token.transfer(founder, tokensForFounder);
                token.transfer(team, tokensForTeam);
                tokensBought = tokensBought.Add(totalToSend);
                return true;
        }else
            return false;
    }

    function buyTokens(address _beneficiary) public isStarted payable {
        require(_beneficiary != address(0) &&  msg.value != 0 );
        uint256 tokensToSend = calcTokensToSend(msg.value);
        tokensToSend = tokensToSend.Mul(1 ether);
        
        // Pre-ICO
        if (etype == CrowdsaleType.PreICO){
            require(tokensBought.Add(tokensToSend) < MAX_TOKENS_PRE_ICO);
        }      
        
        if (!transferTokens(_beneficiary, tokensToSend)) revert();
        totalRaisedEth = totalRaisedEth.Add( (msg.value).Div(1 ether) );
        forwardFunds(msg.value);
    }

    // Fallback function
    function () public payable {
        buyTokens(msg.sender);
    }
    
    // Burn unsold tokens
    function burnTokens() public onlyOwner {
        token.burn( token.balanceOf(this) );
        started = false;
    }
    
    // destroy this contract
    function kill() public onlyOwner{
        selfdestruct(multisig);   
    }
}