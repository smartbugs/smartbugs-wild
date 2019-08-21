pragma solidity ^0.4.23;

// File: contracts/Owned.sol

// ----------------------------------------------------------------------------
// Ownership functionality for authorization controls and user permissions
// ----------------------------------------------------------------------------
contract Owned {
    address public owner;
    address public newOwner;

    event OwnershipTransferred(address indexed _from, address indexed _to);

    constructor() public {
        owner = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    function transferOwnership(address _newOwner) public onlyOwner {
        newOwner = _newOwner;
    }
    function acceptOwnership() public {
        require(msg.sender == newOwner);
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
        newOwner = address(0);
    }
}

// File: contracts/Pausable.sol

// ----------------------------------------------------------------------------
// Pause functionality
// ----------------------------------------------------------------------------
contract Pausable is Owned {
  event Pause();
  event Unpause();

  bool public paused = false;


  // Modifier to make a function callable only when the contract is not paused.
  modifier whenNotPaused() {
    require(!paused);
    _;
  }

  // Modifier to make a function callable only when the contract is paused.
  modifier whenPaused() {
    require(paused);
    _;
  }

  // Called by the owner to pause, triggers stopped state
  function pause() onlyOwner whenNotPaused public {
    paused = true;
    emit Pause();
  }

  // Called by the owner to unpause, returns to normal state
  function unpause() onlyOwner whenPaused public {
    paused = false;
    emit Unpause();
  }
}

// File: contracts/SafeMath.sol

// ----------------------------------------------------------------------------
// Safe maths
// ----------------------------------------------------------------------------
contract SafeMath {
    function safeAdd(uint a, uint b) public pure returns (uint c) {
        c = a + b;
        require(c >= a);
    }
    function safeSub(uint a, uint b) public pure returns (uint c) {
        require(b <= a);
        c = a - b;
    }
    function safeMul(uint a, uint b) public pure returns (uint c) {
        c = a * b;
        require(a == 0 || c / a == b);
    }
    function safeDiv(uint a, uint b) public pure returns (uint c) {
        require(b > 0);
        c = a / b;
    }
}

// File: contracts/ERC20.sol

// ----------------------------------------------------------------------------
// ERC20 Standard Interface
// ----------------------------------------------------------------------------
contract ERC20 {
    function totalSupply() public constant returns (uint);
    function balanceOf(address tokenOwner) public constant returns (uint balance);
    function allowance(address tokenOwner, address spender) public constant returns (uint remaining);
    function transfer(address to, uint tokens) public returns (bool success);
    function approve(address spender, uint tokens) public returns (bool success);
    function transferFrom(address from, address to, uint tokens) public returns (bool success);

    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
}

// File: contracts/UncToken.sol

// ----------------------------------------------------------------------------
// 'UNC' 'Uncloak' token contract
// Symbol      : UNC
// Name        : Uncloak
// Total supply: 4,200,000,000
// Decimals    : 18
// ----------------------------------------------------------------------------


// ----------------------------------------------------------------------------
// ERC20 Token, with the addition of symbol, name and decimals
// Receives ETH and generates tokens
// ----------------------------------------------------------------------------
contract UncToken is SafeMath, Owned, ERC20 {
    string public symbol;
    string public  name;
    uint8 public decimals;
    uint public _totalSupply;

    // Track whether the coin can be transfered
    bool private transferEnabled = false;

    // track addresses that can transfer regardless of whether transfers are enables
    mapping(address => bool) public transferAdmins;

    mapping(address => uint) public balances;
    mapping(address => mapping(address => uint)) internal allowed;

    event Burned(address indexed burner, uint256 value);

    // Check if transfer is valid
    modifier canTransfer(address _sender) {
        require(transferEnabled || transferAdmins[_sender]);
        _;
    }

    // ------------------------------------------------------------------------
    // Constructor
    // ------------------------------------------------------------------------
    constructor() public {
        symbol = "UNC";
        name = "Uncloak";
        decimals = 18;
        _totalSupply = 4200000000 * 10**uint(decimals);
        transferAdmins[owner] = true; // Enable transfers for owner
        balances[owner] = _totalSupply;
        emit Transfer(address(0), owner, _totalSupply);
    }

    // ------------------------------------------------------------------------
    // Total supply
    // ------------------------------------------------------------------------
    function totalSupply() public constant returns (uint) {
        return _totalSupply;
    }

    // ------------------------------------------------------------------------
    // Get the token balance for account `tokenOwner`
    // ------------------------------------------------------------------------
    function balanceOf(address tokenOwner) public constant returns (uint balance) {
        return balances[tokenOwner];
    }

    // ------------------------------------------------------------------------
    // Transfer the balance from token owner's account to `to` account
    // - Owner's account must have sufficient balance to transfer
    // - 0 value transfers are allowed
    // ------------------------------------------------------------------------
    function transfer(address to, uint tokens) canTransfer (msg.sender) public returns (bool success) {
        require(to != address(this)); //make sure we're not transfering to this contract

        //check edge cases
        if (balances[msg.sender] >= tokens
            && tokens > 0) {

                //update balances
                balances[msg.sender] = safeSub(balances[msg.sender], tokens);
                balances[to] = safeAdd(balances[to], tokens);

                //log event
                emit Transfer(msg.sender, to, tokens);
                return true;
        }
        else {
            return false;
        }
    }

    // ------------------------------------------------------------------------
    // Token owner can approve for `spender` to transferFrom(...) `tokens`
    // from the token owner's account
    // ------------------------------------------------------------------------
    function approve(address spender, uint tokens) public returns (bool success) {
        // Ownly allow changes to or from 0. Mitigates vulnerabiilty of race description
        // described here: https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
        require((tokens == 0) || (allowed[msg.sender][spender] == 0));

        allowed[msg.sender][spender] = tokens;
        emit Approval(msg.sender, spender, tokens);
        return true;
    }

    // ------------------------------------------------------------------------
    // Transfer `tokens` from the `from` account to the `to` account
    //
    // The calling account must already have sufficient tokens approve(...)-d
    // for spending from the `from` account and
    // - From account must have sufficient balance to transfer
    // - Spender must have sufficient allowance to transfer
    // - 0 value transfers are allowed
    // ------------------------------------------------------------------------
    function transferFrom(address from, address to, uint tokens) canTransfer(from) public returns (bool success) {
        require(to != address(this));

        //check edge cases
        if (allowed[from][msg.sender] >= tokens
            && balances[from] >= tokens
            && tokens > 0) {

            //update balances and allowances
            balances[from] = safeSub(balances[from], tokens);
            allowed[from][msg.sender] = safeSub(allowed[from][msg.sender], tokens);
            balances[to] = safeAdd(balances[to], tokens);

            //log event
            emit Transfer(from, to, tokens);
            return true;
        }
        else {
            return false;
        }
    }

    // ------------------------------------------------------------------------
    // Returns the amount of tokens approved by the owner that can be
    // transferred to the spender's account
    // ------------------------------------------------------------------------
    function allowance(address tokenOwner, address spender) public constant returns (uint remaining) {
        return allowed[tokenOwner][spender];
    }


    // Owner can allow transfers for a particular address. Use for crowdsale contract.
    function setTransferAdmin(address _addr, bool _canTransfer) onlyOwner public {
        transferAdmins[_addr] = _canTransfer;
    }

    // Enable transfers for token holders
    function enablesTransfers() public onlyOwner {
        transferEnabled = true;
    }

    // ------------------------------------------------------------------------
    // Burns a specific number of tokens
    // ------------------------------------------------------------------------
    function burn(uint256 _value) public onlyOwner {
        require(_value > 0);

        address burner = msg.sender;
        balances[burner] = safeSub(balances[burner], _value);
        _totalSupply = safeSub(_totalSupply, _value);
        emit Burned(burner, _value);
    }

    // ------------------------------------------------------------------------
    // Doesn't Accept Eth
    // ------------------------------------------------------------------------
    function () public payable {
        revert();
    }
}

// File: contracts/TimeLock.sol

// ----------------------------------------------------------------------------
// The timeLock contract is used for locking up the tokens of early backers.
// It distributes 40% at launch, 40% 3 months later, 20% 6 months later.
// ----------------------------------------------------------------------------
contract TimeLock is SafeMath, Owned {

  // Token we are using
  UncToken public token;

  // beneficiary of tokens after they are released
  address public beneficiary;

  // timestamp when token release is enabled
  uint256 public releaseTime1;
  uint256 public releaseTime2;
  uint256 public releaseTime3;

  // track initial balance of time lock
  uint256 public initialBalance;

  // Keep track of step of distribution
  uint public step = 0;

  // constructor
  constructor(UncToken _token, address _beneficiary, uint256 _releaseTime) public {
    require(_releaseTime > now);
    token = _token;
    beneficiary = _beneficiary;
    releaseTime1 = _releaseTime;
    releaseTime2 = safeAdd(releaseTime1, 7776000);  // Add 3 months
    releaseTime3 = safeAdd(releaseTime1, 15552000);  // Add 6 months
  }


  // Sets the initial balance, used because timelock distribution based on % of initial balance
  function setInitialBalance() public onlyOwner {
  	initialBalance = token.balanceOf(address(this));
  }

  // Function to move release time frame earlier if needed
  function updateReleaseTime(uint256 _releaseTime) public onlyOwner {
  	// Check that release schedule has not started
  	require(now < releaseTime1);
  	require(_releaseTime < releaseTime1);

  	// Update times
  	releaseTime1 = _releaseTime;
    releaseTime2 = safeAdd(releaseTime1, 7776000);  // Add 3 months
    releaseTime3 = safeAdd(releaseTime1, 15552000);  // Add 6 months
  }

  // Transfers tokens held by timelock to beneficiary.
  function release() public {
    require(now >= releaseTime1);

    uint256 unlockAmount = 0;

    // Initial balance of tokens in this contract
    uint256 amount = initialBalance;
    require(amount > 0);

    // Determine release amount
    if (step == 0 && now > releaseTime1) {
    	unlockAmount = safeDiv(safeMul(amount, 4), 10); //40%
    }
    else if (step == 1 && now > releaseTime2) {
    	unlockAmount = safeDiv(safeMul(amount, 4), 10); //40%
    }
    else if (step == 2 && now > releaseTime3) {
    	unlockAmount = token.balanceOf(address(this));
    }
    // Make sure there is new tokens to release, otherwise don't advance step
    require(unlockAmount != 0);

    // Increase step for next time
    require(token.transfer(beneficiary, unlockAmount));
    step++;

  }
}

// File: contracts/UncTokenSale.sol

// ----------------------------------------------------------------------------
// The UncTokenSale smart contract is used for selling UncToken (UNC).
// It calculates UNC allocation based on the ETH contributed and the sale stage.
// ----------------------------------------------------------------------------
contract UncTokenSale is SafeMath, Pausable {

	// The beneficiary is the address that receives the ETH raised if sale is successful
	address public beneficiary;

	// Token to be sold
	UncToken  public token;

	// Crowdsale variables set in constructor
	uint public hardCap;
    uint public highBonusRate = 115;
    uint public lowBonusRate = 110;
	uint public constant highBonus = 160000000000000000000; // 160 Eth
	uint public constant minContribution = 4000000000000000000; // 4 Eth
	uint public constant preMaxContribution = 200000000000000000000; // 200 Eth
	uint public constant mainMaxContribution = 200000000000000000000; // 200 Eth

	// List of addresses that can add KYC verified addresses
	mapping(address => bool) public isVerifier;
	// List of addresses that are kycVerified
	mapping(address => bool) public kycVerified;

	// Time periods of sale stages
	uint public preSaleTime;
	uint public mainSaleTime;
	uint public endSaleTime;

	// Keeps track of amount raised
	uint public amountRaised;

	// Booleans to track sale state
	bool public beforeSale = true;
	bool public preSale = false;
	bool public mainSale = false;
	bool public saleEnded = false;
	bool public hardCapReached = false;

	// Mapping of token timelocks
	mapping(address => address) public timeLocks;

	// Ratio of Wei to UNC. LOW HIGH NEED TO BE UPDATED
	uint public rate = 45000; // $0.01 per UNC
	uint public constant lowRate = 10000;
	uint public constant highRate = 1000000;

	// Mapping to track contributions
	mapping(address => uint256) public contributionAmtOf;

	// The tokens allocated to an address
	mapping(address => uint256) public tokenBalanceOf;

    // A mapping that tracks the tokens allocated to team and advisors
	mapping(address => uint256) public teamTokenBalanceOf;

    event HardReached(address _beneficiary, uint _amountRaised);
    event BalanceTransfer(address _to, uint _amount);
    event AddedOffChain(address indexed _beneficiary, uint256 tokensAllocated);
    event RateChanged(uint newRate);
    event VerifiedKYC(address indexed person);
    //other potential events: transfer of tokens to investors,

    modifier beforeEnd() { require (now < endSaleTime); _; }
    modifier afterEnd() { require (now >= endSaleTime); _; }
    modifier afterStart() { require (now >= preSaleTime); _; }

    modifier saleActive() { require (!(beforeSale || saleEnded)); _; }

    modifier verifierOnly() { require(isVerifier[msg.sender]); _; }

    // Constructor, lay out the structure of the sale
    constructor (
    UncToken  _token,
    address _beneficiary,
    uint _preSaleTime,
    uint _mainSaleTime,
    uint _endSaleTime,
    uint _hardCap
    ) public
    {
    //require(_beneficiary != address(0) && _beneficiary != address(this));
    //require(_endSaleTime > _mainSaleTime && _mainSaleTime > _preSaleTime);

    // This sets the contract owner as a verifier, then they can add other verifiers
    isVerifier[msg.sender] = true;

    	token = _token;
    	beneficiary = _beneficiary;
    	preSaleTime = _preSaleTime;
    	mainSaleTime = _mainSaleTime;
    	endSaleTime = _endSaleTime;
    	hardCap = _hardCap;

    	//may want to deal with vesting and lockup here

    }


    /* Fallback function is called when Ether is sent to the contract. It can
    *  Only be executed when the crowdsale is not closed, paused, or before the
    *  deadline is reached. The function will update state variables and make
    *  a function call to calculate number of tokens to be allocated to investor
    */
    function () public payable whenNotPaused {
    	// Contribution amount in wei
    	uint amount = msg.value;

    	uint newTotalContribution = safeAdd(contributionAmtOf[msg.sender], msg.value);

    	// amount must be greater than or equal to the minimum contribution amount
    	require(amount >= minContribution);

    	if (preSale) {
    		require(newTotalContribution <= preMaxContribution);
    	}

    	if (mainSale) {
    		require(newTotalContribution <= mainMaxContribution);
    	}

    	// Convert wei to UNC and allocate token amount
    	allocateTokens(msg.sender, amount);
    }


    // Caluclates the number of tokens to allocate to investor and updates balance
    function allocateTokens(address investor, uint _amount) internal {
    	// Make sure investor has been verified
    	require(kycVerified[investor]);

    	// Calculate baseline number of tokens
    	uint numTokens = safeMul(_amount, rate);

    	//logic for adjusting the number of tokens they get based on stage and amount
    	if (preSale) {
    		// greater than 160 Eth
    		if (_amount >= highBonus) {
    			numTokens = safeDiv(safeMul(numTokens, highBonusRate), 100);
    		}

            else {
                numTokens = safeDiv(safeMul(numTokens, lowBonusRate), 100);
            }
    	}
    	else {
    			numTokens = safeDiv(safeMul(numTokens, lowBonusRate), 100);
    		}

    	// Check that there are enough tokens left for sale to execute purchase and update balances
    	require(token.balanceOf(address(this)) >= numTokens);
    	tokenBalanceOf[investor] = safeAdd(tokenBalanceOf[investor], numTokens);

    	// Crowdsale contract sends investor their tokens
    	token.transfer(investor, numTokens);

    	// Update the amount this investor has contributed
    	contributionAmtOf[investor] = safeAdd(contributionAmtOf[investor], _amount);
    	amountRaised = safeAdd(amountRaised, _amount);

    	
    }

    // Function to transfer tokens from this contract to an address
    function tokenTransfer(address recipient, uint numToks) public onlyOwner {
        token.transfer(recipient, numToks);
    }

    /*
    * Owner can call this function to withdraw funds sent to this contract.
    * The funds will be sent to the beneficiary specified when the
    * crowdsale was created.
    */
    function beneficiaryWithdrawal() external onlyOwner {
    	uint contractBalance = address(this).balance;
    	// Send eth in contract to the beneficiary
    	beneficiary.transfer(contractBalance);
    	emit BalanceTransfer(beneficiary, contractBalance);
    }

    	// The owner can end crowdsale at any time.
    	function terminate() external onlyOwner {
        saleEnded = true;
    }

    // Allows owner to update the rate (UNC to ETH)
    function setRate(uint _rate) public onlyOwner {
    	require(_rate >= lowRate && _rate <= highRate);
    	rate = _rate;

    	emit RateChanged(rate);
    }


    // Checks if there are any tokens left to sell. Updates
    // state variables and triggers event hardReached
    function checkHardReached() internal {
    	if(!hardCapReached) {
    		if (token.balanceOf(address(this)) == 0) {
    			hardCapReached = true;
    			saleEnded = true;
    			emit HardReached(beneficiary, amountRaised);
    		}
    	}
    }

    // Starts the preSale stage.
    function startPreSale() public onlyOwner {
    	beforeSale = false;
    	preSale = true;
    }

    // Starts the mainSale stage
    function startMainSale() public afterStart onlyOwner {
    	preSale = false;
    	mainSale = true;
    }

    // Ends the preSale and mainSale stage.
    function endSale() public afterStart onlyOwner {
    	preSale = false;
    	mainSale = false;
    	saleEnded = true;
    }

    /*
    * Function to update the start time of the pre-sale. Checks that the sale
    * has not started and that the new time is valid
    */
    function updatePreSaleTime(uint newTime) public onlyOwner {
    	require(beforeSale == true);
    	require(now < preSaleTime);
    	require(now < newTime);

    	preSaleTime = newTime;
    }

    /*
    * Function to update the start time of the main-sale. Checks that the main
    * sale has not started and that the new time is valid
    */
    function updateMainSaleTime(uint newTime) public onlyOwner {
    	require(mainSale != true);
    	require(now < mainSaleTime);
    	require(now < newTime);

    	mainSaleTime = newTime;
    }

    /*
    * Function to update the end of the sale. Checks that the main
    * sale has not ended and that the new time is valid
    */
    function updateEndSaleTime(uint newTime) public onlyOwner {
    	require(saleEnded != true);
    	require(now < endSaleTime);
    	require(now < newTime);

    	endSaleTime = newTime;
    }

    // Function to burn all unsold tokens after sale has ended
    function burnUnsoldTokens() public afterEnd onlyOwner {
    	// All unsold tokens that are held by this contract get burned
    	uint256 tokensToBurn = token.balanceOf(address(this));
    	token.burn(tokensToBurn);
    }

    // Adds an address to the list of verifiers
    function addVerifier (address _address) public onlyOwner {
        isVerifier[_address] = true;
    }

    // Removes an address from the list of verifiers
    function removeVerifier (address _address) public onlyOwner {
        isVerifier[_address] = false;
    }

    // Function to update an addresses KYC verification status
    function verifyKYC(address[] participants) public verifierOnly {
    	require(participants.length > 0);

    	// KYC verify all addresses in array participants
    	for (uint256 i = 0; i < participants.length; i++) {
    		kycVerified[participants[i]] = true;
    		emit VerifiedKYC(participants[i]);
    	}
    }

    // Function to update the start time of a particular timeLock
    function moveReleaseTime(address person, uint256 newTime) public onlyOwner {
    	require(timeLocks[person] != 0x0);
    	require(now < newTime);

    	// Get the timeLock instance for this person
    	TimeLock lock = TimeLock(timeLocks[person]);

    	lock.updateReleaseTime(newTime);
    }

    // Release unlocked tokens
    function releaseLock(address person) public {
    	require(timeLocks[person] != 0x0);

    	// Get the timeLock instance for this person
    	TimeLock lock = TimeLock(timeLocks[person]);

    	// Release the vested tokens for this person
    	lock.release();
    }

    // Adds an address for commitments made off-chain
    function offChainTrans(address participant, uint256 tokensAllocated, uint256 contributionAmt, bool isFounder) public onlyOwner {
    	uint256 startTime;

        // Store tokensAllocated in a variable
    	uint256 tokens = tokensAllocated;
    	// Check that there are enough tokens to allocate to participant
    	require(token.balanceOf(address(this)) >= tokens);

    	// Update how much this participant has contributed
    	contributionAmtOf[participant] = safeAdd(contributionAmtOf[participant], contributionAmt);

    	// increase tokenBalanceOf by tokensAllocated for this person
    	tokenBalanceOf[participant] = safeAdd(tokenBalanceOf[participant], tokens);

    	// Set the start date for their vesting. Founders: June 1, 2019. Everyone else: Aug 3, 2018
    	if (isFounder) {
            // June 1, 2019
            startTime = 1559347200;
        }
        else {
            // October 30th, 2018
            startTime = 1540886400;
        }

    	// declare an object of type timeLock
    	TimeLock lock;

    	// Create or update timelock for this participant
    	if (timeLocks[participant] == 0x0) {
    		lock = new TimeLock(token, participant, startTime);
    		timeLocks[participant] = address(lock);
    	} else {
    		lock = TimeLock(timeLocks[participant]);
    	}

    	// Transfer tokens to the time lock and set its initial balance
    	token.transfer(lock, tokens);
    	lock.setInitialBalance();

    	//Make event for private investor and invoke it here
    	emit AddedOffChain(participant, tokensAllocated);
    }

}