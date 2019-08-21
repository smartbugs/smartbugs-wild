pragma solidity ^0.4.8;

contract ERC20 {
  uint public totalSupply;
  function balanceOf(address who) constant returns (uint);
  function allowance(address owner, address spender) constant returns (uint);

  function transfer(address to, uint value) returns (bool ok);
  function transferFrom(address from, address to, uint value) returns (bool ok);
  function approve(address spender, uint value) returns (bool ok);
  event Transfer(address indexed from, address indexed to, uint value);
  event Approval(address indexed owner, address indexed spender, uint value);
}


contract Ownable {
  address public owner;

  function Ownable() {
    owner = msg.sender;
  }

  modifier onlyOwner() {
    if (msg.sender == owner)
      _;
  }

  function transferOwnership(address newOwner) onlyOwner {
    if (newOwner != address(0)) owner = newOwner;
  }

}

contract TokenSpender {
    function receiveApproval(address _from, uint256 _value, address _token, bytes _extraData);
}

contract SafeMath {
  function safeMul(uint a, uint b) internal returns (uint) {
    uint c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function safeDiv(uint a, uint b) internal returns (uint) {
    assert(b > 0);
    uint c = a / b;
    assert(a == b * c + a % b);
    return c;
  }

  function safeSub(uint a, uint b) internal returns (uint) {
    assert(b <= a);
    return a - b;
  }

  function safeAdd(uint a, uint b) internal returns (uint) {
    uint c = a + b;
    assert(c>=a && c>=b);
    return c;
  }

  function max64(uint64 a, uint64 b) internal constant returns (uint64) {
    return a >= b ? a : b;
  }

  function min64(uint64 a, uint64 b) internal constant returns (uint64) {
    return a < b ? a : b;
  }

  function max256(uint256 a, uint256 b) internal constant returns (uint256) {
    return a >= b ? a : b;
  }

  function min256(uint256 a, uint256 b) internal constant returns (uint256) {
    return a < b ? a : b;
  }

  function assert(bool assertion) internal {
    if (!assertion) {
      throw;
    }
  }
}

contract PullPayment {
  mapping(address => uint) public payments;
  event RefundETH(address to, uint value);
  // store sent amount as credit to be pulled, called by payer
  function asyncSend(address dest, uint amount) internal {
    payments[dest] += amount;
  }

  // withdraw accumulated balance, called by payee
  function withdrawPayments() {
    address payee = msg.sender;
    uint payment = payments[payee];
    
    if (payment == 0) {
      throw;
    }

    if (this.balance < payment) {
      throw;
    }

    payments[payee] = 0;

    if (!payee.send(payment)) {
      throw;
    }
    RefundETH(payee,payment);
  }
}

contract Pausable is Ownable {
  bool public stopped;

  modifier stopInEmergency {
    if (stopped) {
      throw;
    }
    _;
  }
  
  modifier onlyInEmergency {
    if (!stopped) {
      throw;
    }
    _;
  }

  // called by the owner on emergency, triggers stopped state
  function emergencyStop() external onlyOwner {
    stopped = true;
  }

  // called by the owner on end of emergency, returns to normal state
  function release() external onlyOwner onlyInEmergency {
    stopped = false;
  }

}


contract RLC is ERC20, SafeMath, Ownable {

    /* Public variables of the token */
  string public name;       //fancy name
  string public symbol;
  uint8 public decimals;    //How many decimals to show.
  string public version = 'v0.1'; 
  uint public initialSupply;
  uint public totalSupply;
  bool public locked;
  //uint public unlockBlock;

  mapping(address => uint) balances;
  mapping (address => mapping (address => uint)) allowed;

  // lock transfer during the ICO
  modifier onlyUnlocked() {
    if (msg.sender != owner && locked) throw;
    _;
  }

  /*
   *  The RLC Token created with the time at which the crowdsale end
   */

  function RLC() {
    // lock the transfer function during the crowdsale
    locked = true;
    //unlockBlock=  now + 45 days; // (testnet) - for mainnet put the block number

    initialSupply = 87000000000000000;
    totalSupply = initialSupply;
    balances[msg.sender] = initialSupply;// Give the creator all initial tokens                    
    name = 'iEx.ec Network Token';        // Set the name for display purposes     
    symbol = 'RLC';                       // Set the symbol for display purposes  
    decimals = 9;                        // Amount of decimals for display purposes
  }

  function unlock() onlyOwner {
    locked = false;
  }

  function burn(uint256 _value) returns (bool){
    balances[msg.sender] = safeSub(balances[msg.sender], _value) ;
    totalSupply = safeSub(totalSupply, _value);
    Transfer(msg.sender, 0x0, _value);
    return true;
  }

  function transfer(address _to, uint _value) onlyUnlocked returns (bool) {
    balances[msg.sender] = safeSub(balances[msg.sender], _value);
    balances[_to] = safeAdd(balances[_to], _value);
    Transfer(msg.sender, _to, _value);
    return true;
  }

  function transferFrom(address _from, address _to, uint _value) onlyUnlocked returns (bool) {
    var _allowance = allowed[_from][msg.sender];
    
    balances[_to] = safeAdd(balances[_to], _value);
    balances[_from] = safeSub(balances[_from], _value);
    allowed[_from][msg.sender] = safeSub(_allowance, _value);
    Transfer(_from, _to, _value);
    return true;
  }

  function balanceOf(address _owner) constant returns (uint balance) {
    return balances[_owner];
  }

  function approve(address _spender, uint _value) returns (bool) {
    allowed[msg.sender][_spender] = _value;
    Approval(msg.sender, _spender, _value);
    return true;
  }

    /* Approve and then comunicate the approved contract in a single tx */
  function approveAndCall(address _spender, uint256 _value, bytes _extraData){    
      TokenSpender spender = TokenSpender(_spender);
      if (approve(_spender, _value)) {
          spender.receiveApproval(msg.sender, _value, this, _extraData);
      }
  }

  function allowance(address _owner, address _spender) constant returns (uint remaining) {
    return allowed[_owner][_spender];
  }
  
}




contract Crowdsale is SafeMath, PullPayment, Pausable {

  	struct Backer {
		uint weiReceived;	// Amount of ETH given
		string btc_address;  //store the btc address for full traceability
		uint satoshiReceived;	// Amount of BTC given
		uint rlcSent;
	}

	RLC 	public rlc;         // RLC contract reference
	address public owner;       // Contract owner (iEx.ec team)
	address public multisigETH; // Multisig contract that will receive the ETH
	address public BTCproxy;	// address of the BTC Proxy

	uint public RLCPerETH;      // Number of RLC per ETH
	uint public RLCPerSATOSHI;  // Number of RLC per SATOSHI
	uint public ETHReceived;    // Number of ETH received
	uint public BTCReceived;    // Number of BTC received
	uint public RLCSentToETH;   // Number of RLC sent to ETH contributors
	uint public RLCSentToBTC;   // Number of RLC sent to BTC contributors
	uint public startBlock;     // Crowdsale start block
	uint public endBlock;       // Crowdsale end block
	uint public minCap;         // Minimum number of RLC to sell
	uint public maxCap;         // Maximum number of RLC to sell
	bool public maxCapReached;  // Max cap has been reached
	uint public minInvestETH;   // Minimum amount to invest
	uint public minInvestBTC;   // Minimum amount to invest
	bool public crowdsaleClosed;// Is crowdsale still on going

	address public bounty;		// address at which the bounty RLC will be sent
	address public reserve; 	// address at which the contingency reserve will be sent
	address public team;		// address at which the team RLC will be sent

	uint public rlc_bounty;		// amount of bounties RLC
	uint public rlc_reserve;	// amount of the contingency reserve
	uint public rlc_team;		// amount of the team RLC 
	mapping(address => Backer) public backers; //backersETH indexed by their ETH address

	modifier onlyBy(address a){
		if (msg.sender != a) throw;  
		_;
	}

	modifier minCapNotReached() {
		if ((now<endBlock) || RLCSentToETH + RLCSentToBTC >= minCap ) throw;
		_;
	}

	modifier respectTimeFrame() {
		if ((now < startBlock) || (now > endBlock )) throw;
		_;
	}

	/*
	* Event
	*/
	event ReceivedETH(address addr, uint value);
	event ReceivedBTC(address addr, string from, uint value, string txid);
	event RefundBTC(string to, uint value);
	event Logs(address indexed from, uint amount, string value);

	/*
	*	Constructor
	*/
	//function Crowdsale() {
	function Crowdsale() {
		owner = msg.sender;
		BTCproxy = 0x75c6cceb1a33f177369053f8a0e840de96b4ed0e;
		rlc = RLC(0x607F4C5BB672230e8672085532f7e901544a7375);
		multisigETH = 0xAe307e3871E5A321c0559FBf0233A38c937B826A;
		team = 0xd65380D773208a6Aa49472Bf55186b855B393298;
		reserve = 0x24F6b37770C6067D05ACc2aD2C42d1Bafde95d48;
		bounty = 0x8226a24dA0870Fb8A128E4Fc15228a9c4a5baC29;
		RLCSentToETH = 0;
		RLCSentToBTC = 0;
		minInvestETH = 1 ether;
		minInvestBTC = 5000000;			// approx 50 USD or 0.05000000 BTC
		startBlock = 0 ;            	// should wait for the call of the function start
		endBlock =  0;  				// should wait for the call of the function start
		RLCPerETH = 200000000000;		// will be update every 10min based on the kraken ETHBTC
		RLCPerSATOSHI = 50000;			// 5000 RLC par BTC == 50,000 RLC per satoshi
		minCap=12000000000000000;
		maxCap=60000000000000000;
		rlc_bounty=1700000000000000;	// max 6000000 RLC
		rlc_reserve=1700000000000000;	// max 6000000 RLC
		rlc_team=12000000000000000;
	}

	/* 
	 * The fallback function corresponds to a donation in ETH
	 */
	function() payable {
		if (now > endBlock) throw;
		receiveETH(msg.sender);
	}

	/* 
	 * To call to start the crowdsale
	 */
	function start() onlyBy(owner) {
		startBlock = now ;            
		endBlock =  now + 30 days;    
	}

	/*
	*	Receives a donation in ETH
	*/
	function receiveETH(address beneficiary) internal stopInEmergency  respectTimeFrame  {
		if (msg.value < minInvestETH) throw;								//don't accept funding under a predefined threshold
		uint rlcToSend = bonus(safeMul(msg.value,RLCPerETH)/(1 ether));		//compute the number of RLC to send
		if (safeAdd(rlcToSend, safeAdd(RLCSentToETH, RLCSentToBTC)) > maxCap) throw;	

		Backer backer = backers[beneficiary];
		if (!rlc.transfer(beneficiary, rlcToSend)) throw;     				// Do the RLC transfer right now 
		backer.rlcSent = safeAdd(backer.rlcSent, rlcToSend);
		backer.weiReceived = safeAdd(backer.weiReceived, msg.value);		// Update the total wei collected during the crowdfunding for this backer    
		ETHReceived = safeAdd(ETHReceived, msg.value);						// Update the total wei collected during the crowdfunding
		RLCSentToETH = safeAdd(RLCSentToETH, rlcToSend);

		emitRLC(rlcToSend);													// compute the variable part 
		ReceivedETH(beneficiary,ETHReceived);								// send the corresponding contribution event
	}
	
	/*
	* receives a donation in BTC
	*/
	function receiveBTC(address beneficiary, string btc_address, uint value, string txid) stopInEmergency respectTimeFrame onlyBy(BTCproxy) returns (bool res){
		if (value < minInvestBTC) throw;											// this verif is also made on the btcproxy

		uint rlcToSend = bonus(safeMul(value,RLCPerSATOSHI));						//compute the number of RLC to send
		if (safeAdd(rlcToSend, safeAdd(RLCSentToETH, RLCSentToBTC)) > maxCap) {		// check if we are not reaching the maxCap by accepting this donation
			RefundBTC(btc_address , value);
			return false;
		}

		Backer backer = backers[beneficiary];
		if (!rlc.transfer(beneficiary, rlcToSend)) throw;							// Do the transfer right now 
		backer.rlcSent = safeAdd(backer.rlcSent , rlcToSend);
		backer.btc_address = btc_address;
		backer.satoshiReceived = safeAdd(backer.satoshiReceived, value);
		BTCReceived =  safeAdd(BTCReceived, value);									// Update the total satoshi collected during the crowdfunding for this backer
		RLCSentToBTC = safeAdd(RLCSentToBTC, rlcToSend);							// Update the total satoshi collected during the crowdfunding
		emitRLC(rlcToSend);
		ReceivedBTC(beneficiary, btc_address, BTCReceived, txid);
		return true;
	}

	/*
	 *Compute the variable part
	 */
	function emitRLC(uint amount) internal {
		rlc_bounty = safeAdd(rlc_bounty, amount/10);
		rlc_team = safeAdd(rlc_team, amount/20);
		rlc_reserve = safeAdd(rlc_reserve, amount/10);
		Logs(msg.sender ,amount, "emitRLC");
	}

	/*
	 *Compute the RLC bonus according to the investment period
	 */
	function bonus(uint amount) internal constant returns (uint) {
		if (now < safeAdd(startBlock, 10 days)) return (safeAdd(amount, amount/5));   // bonus 20%
		if (now < safeAdd(startBlock, 20 days)) return (safeAdd(amount, amount/10));  // bonus 10%
		return amount;
	}

	/* 
	 * When mincap is not reach backer can call the approveAndCall function of the RLC token contract
	 * with this crowdsale contract on parameter with all the RLC they get in order to be refund
	 */
	function receiveApproval(address _from, uint256 _value, address _token, bytes _extraData) minCapNotReached public {
		if (msg.sender != address(rlc)) throw; 
		if (_extraData.length != 0) throw;								// no extradata needed
		if (_value != backers[_from].rlcSent) throw;					// compare value from backer balance
		if (!rlc.transferFrom(_from, address(this), _value)) throw ;	// get the token back to the crowdsale contract
		if (!rlc.burn(_value)) throw ;									// token sent for refund are burnt
		uint ETHToSend = backers[_from].weiReceived;
		backers[_from].weiReceived=0;
		uint BTCToSend = backers[_from].satoshiReceived;
		backers[_from].satoshiReceived = 0;
		if (ETHToSend > 0) {
			asyncSend(_from,ETHToSend);									// pull payment to get refund in ETH
		}
		if (BTCToSend > 0)
			RefundBTC(backers[_from].btc_address ,BTCToSend);			// event message to manually refund BTC
	}

	/*
	* Update the rate RLC per ETH, computed externally by using the ETHBTC index on kraken every 10min
	*/
	function setRLCPerETH(uint rate) onlyBy(BTCproxy) {
		RLCPerETH=rate;
	}
	
	/*	
	* Finalize the crowdsale, should be called after the refund period
	*/
	function finalize() onlyBy(owner) {
		// check
		if (RLCSentToETH + RLCSentToBTC < maxCap - 5000000000000 && now < endBlock) throw;	// cannot finalise before 30 day until maxcap is reached minus 1BTC
		if (RLCSentToETH + RLCSentToBTC < minCap && now < endBlock + 15 days) throw ;		// if mincap is not reached donors have 15days to get refund before we can finalise
		if (!multisigETH.send(this.balance)) throw;											// moves the remaining ETH to the multisig address
		if (rlc_reserve > 6000000000000000){												// moves RLC to the team, reserve and bounty address
			if(!rlc.transfer(reserve,6000000000000000)) throw;								// max cap 6000000RLC
			rlc_reserve = 6000000000000000;
		} else {
			if(!rlc.transfer(reserve,rlc_reserve)) throw;  
		}
		if (rlc_bounty > 6000000000000000){
			if(!rlc.transfer(bounty,6000000000000000)) throw;								// max cap 6000000RLC
			rlc_bounty = 6000000000000000;
		} else {
			if(!rlc.transfer(bounty,rlc_bounty)) throw;
		}
		if (!rlc.transfer(team,rlc_team)) throw;
		uint RLCEmitted = rlc_reserve + rlc_bounty + rlc_team + RLCSentToBTC + RLCSentToETH;
		if (RLCEmitted < rlc.totalSupply())													// burn the rest of RLC
			  rlc.burn(rlc.totalSupply() - RLCEmitted);
		rlc.unlock();
		crowdsaleClosed = true;
	}

	/*	
	* Failsafe drain
	*/
	function drain() onlyBy(owner) {
		if (!owner.send(this.balance)) throw;
	}
}