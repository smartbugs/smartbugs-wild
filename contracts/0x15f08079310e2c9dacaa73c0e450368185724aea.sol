/**
 * The edgeless casino contract holds the players's funds and provides state channel functionality.
 * The casino has at no time control over the players's funds.
 * State channels can be updated and closed from both parties: the player and the casino.
 * author: Julia Altenried
 **/

pragma solidity ^0.4.17;

contract SafeMath {

	function safeSub(uint a, uint b) pure internal returns(uint) {
		assert(b <= a);
		return a - b;
	}
	
	function safeSub(int a, int b) pure internal returns(int) {
		if(b < 0) assert(a - b > a);
		else assert(a - b <= a);
		return a - b;
	}

	function safeAdd(uint a, uint b) pure internal returns(uint) {
		uint c = a + b;
		assert(c >= a && c >= b);
		return c;
	}

	function safeMul(uint a, uint b) pure internal returns (uint) {
    uint c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }
}

contract owned {
  address public owner;
  modifier onlyOwner {
    require(msg.sender == owner);
    _;
  }

  function owned() public{
    owner = msg.sender;
  }

  function changeOwner(address newOwner) onlyOwner public{
    owner = newOwner;
  }
}

/** owner should be able to close the contract is nobody has been using it for at least 30 days */
contract mortal is owned {
	/** contract can be closed by the owner anytime after this timestamp if non-zero */
	uint public closeAt;
	/**
	* lets the owner close the contract if there are no player funds on it or if nobody has been using it for at least 30 days
	*/
  function closeContract(uint playerBalance) internal{
		if(playerBalance == 0) selfdestruct(owner);
		if(closeAt == 0) closeAt = now + 30 days;
		else if(closeAt < now) selfdestruct(owner);
  }

	/**
	* in case close has been called accidentally.
	**/
	function open() onlyOwner public{
		closeAt = 0;
	}

	/**
	* make sure the contract is not in process of being closed.
	**/
	modifier isAlive {
		require(closeAt == 0);
		_;
	}

	/**
	* delays the time of closing.
	**/
	modifier keepAlive {
		if(closeAt > 0) closeAt = now + 30 days;
		_;
	}
}


contract chargingGas is mortal, SafeMath{
  /** the price per kgas and GWei in tokens (5 decimals) */
	uint public gasPrice;
	/** the amount of gas used per transaction in kGas */
	mapping(bytes4 => uint) public gasPerTx;
	
	/**
	 * sets the amount of gas consumed by methods with the given sigantures.
	 * only called from the edgeless casino constructor.
	 * @param signatures an array of method-signatures
	 *        gasNeeded  the amount of gas consumed by these methods
	 * */
	function setGasUsage(bytes4[3] signatures, uint[3] gasNeeded) internal{
	  require(signatures.length == gasNeeded.length);
	  for(uint8 i = 0; i < signatures.length; i++)
	    gasPerTx[signatures[i]] = gasNeeded[i];
	}
	
	/**
	 * adds the gas cost of the tx to the given value.
	 * @param value the value to add the gas cost to
	 * */
	function addGas(uint value) internal constant returns(uint){
  	return safeAdd(value,getGasCost());
	}
	
	/**
	 * subtracts the gas cost of the tx from the given value.
	 * @param value the value to subtract the gas cost from
	 * */
	function subtractGas(uint value) internal constant returns(uint){
  	return safeSub(value,getGasCost());
	}
	
	
	/**
	* updates the price per 1000 gas in EDG.
	* @param price the new gas price (4 decimals, max 0.0256 EDG)
	**/
	function setGasPrice(uint8 price) public onlyOwner{
		gasPrice = price;
	}
	
	/**
	 * returns the gas cost of the called function.
	 * */
	function getGasCost() internal constant returns(uint){
	  return safeMul(safeMul(gasPerTx[msg.sig], gasPrice), tx.gasprice)/1000000000;
	}

}

contract Token {
	function transferFrom(address sender, address receiver, uint amount) public returns(bool success) {}

	function transfer(address receiver, uint amount) public returns(bool success) {}

	function balanceOf(address holder) public constant returns(uint) {}
}

contract CasinoBank is chargingGas{
	/** the total balance of all players with 5 virtual decimals **/
	uint public playerBalance;
	/** the balance per player in edgeless tokens with 5 virtual decimals */
	mapping(address=>uint) public balanceOf;
	/** in case the user wants/needs to call the withdraw function from his own wallet, he first needs to request a withdrawal */
	mapping(address=>uint) public withdrawAfter;
	/** the edgeless token contract */
	Token edg;
	/** the maximum amount of tokens the user is allowed to deposit (5 decimals) */
	uint public maxDeposit;
	/** waiting time for withdrawal if not requested via the server **/
	uint public waitingTime;
	
	/** informs listeners how many tokens were deposited for a player */
	event Deposit(address _player, uint _numTokens, bool _chargeGas);
	/** informs listeners how many tokens were withdrawn from the player to the receiver address */
	event Withdrawal(address _player, address _receiver, uint _numTokens);

	function CasinoBank(address tokenContract, uint depositLimit) public{
		edg = Token(tokenContract);
		maxDeposit = depositLimit;
		waitingTime = 90 minutes;
	}

	/**
	* accepts deposits for an arbitrary address.
	* retrieves tokens from the message sender and adds them to the balance of the specified address.
	* edgeless tokens do not have any decimals, but are represented on this contract with 5 decimals.
	* @param receiver  address of the receiver
	*        numTokens number of tokens to deposit (0 decimals)
	*				 chargeGas indicates if the gas cost is subtracted from the user's edgeless token balance
	**/
	function deposit(address receiver, uint numTokens, bool chargeGas) public isAlive{
		require(numTokens > 0);
		uint value = safeMul(numTokens,100000);
		if(chargeGas) value = subtractGas(value);
		uint newBalance = safeAdd(balanceOf[receiver], value);
		require(newBalance <= maxDeposit);
		assert(edg.transferFrom(msg.sender, address(this), numTokens));
		balanceOf[receiver] = newBalance;
		playerBalance = safeAdd(playerBalance, value);
		Deposit(receiver, numTokens, chargeGas);
  }

	/**
	* If the user wants/needs to withdraw his funds himself, he needs to request the withdrawal first.
	* This method sets the earliest possible withdrawal date to 'waitingTime from now (default 90m, but up to 24h).
	* Reason: The user should not be able to withdraw his funds, while the the last game methods have not yet been mined.
	**/
	function requestWithdrawal() public{
		withdrawAfter[msg.sender] = now + waitingTime;
	}

	/**
	* In case the user requested a withdrawal and changes his mind.
	* Necessary to be able to continue playing.
	**/
	function cancelWithdrawalRequest() public{
		withdrawAfter[msg.sender] = 0;
	}

	/**
	* withdraws an amount from the user balance if the waiting time passed since the request.
	* @param amount the amount of tokens to withdraw
	**/
	function withdraw(uint amount) public keepAlive{
		require(withdrawAfter[msg.sender]>0 && now>withdrawAfter[msg.sender]);
		withdrawAfter[msg.sender] = 0;
		uint value = safeMul(amount,100000);
		balanceOf[msg.sender]=safeSub(balanceOf[msg.sender],value);
		playerBalance = safeSub(playerBalance, value);
		assert(edg.transfer(msg.sender, amount));
		Withdrawal(msg.sender, msg.sender, amount);
	}

	/**
	* lets the owner withdraw from the bankroll
	* @param numTokens the number of tokens to withdraw (0 decimals)
	**/
	function withdrawBankroll(uint numTokens) public onlyOwner {
		require(numTokens <= bankroll());
		assert(edg.transfer(owner, numTokens));
	}

	/**
	* returns the current bankroll in tokens with 0 decimals
	**/
	function bankroll() constant public returns(uint){
		return safeSub(edg.balanceOf(address(this)), playerBalance/100000);
	}
	
	
	/**
	* updates the maximum deposit.
	* @param newMax the new maximum deposit (5 decimals)
	**/
	function setMaxDeposit(uint newMax) public onlyOwner{
		maxDeposit = newMax;
	}
	
	/**
	 * sets the time the player has to wait for his funds to be unlocked before withdrawal (if not withdrawing with help of the casino server).
	 * the time may not be longer than 24 hours.
	 * @param newWaitingTime the new waiting time in seconds
	 * */
	function setWaitingTime(uint newWaitingTime) public onlyOwner{
		require(newWaitingTime <= 24 hours);
		waitingTime = newWaitingTime;
	}

	/**
	 * lets the owner close the contract if there are no player funds on it or if nobody has been using it for at least 30 days
	 * */
	function close() public onlyOwner{
		closeContract(playerBalance);
	}
}

contract EdgelessCasino is CasinoBank{
	/** indicates if an address is authorized to act in the casino's name  */
    mapping(address => bool) public authorized;
	/** a number to count withdrawal signatures to ensure each signature is different even if withdrawing the same amount to the same address */
	mapping(address => uint) public withdrawCount;
	/** the most recent known state of a state channel */
	mapping(address => State) public lastState;
    /** fired when the state is updated */
    event StateUpdate(uint128 count, int128 winBalance, int difference, uint gasCost, address player, uint128 lcount);
    /** fired if one of the parties chooses to log the seeds and results */
    event GameData(address player, bytes32[] serverSeeds, bytes32[] clientSeeds, int[] results);
  
	struct State{
		uint128 count;
		int128 winBalance;
	}

    modifier onlyAuthorized {
        require(authorized[msg.sender]);
        _;
    }


  /**
  * creates a new edgeless casino contract.
  * @param authorizedAddress the address which may send transactions to the Edgeless Casino
  *				 tokenContract     the address of the Edgeless token contract
  * 			 depositLimit      the maximum deposit allowed
  * 			 kGasPrice				 the price per kGas in WEI
  **/
  function EdgelessCasino(address authorizedAddress, address tokenContract, uint depositLimit, uint8 kGasPrice) CasinoBank(tokenContract, depositLimit) public{
    authorized[authorizedAddress] = true;
    //deposit, withdrawFor, updateChannel
    bytes4[3] memory signatures = [bytes4(0x3edd1128),0x9607610a, 0x713d30c6];
    //amount of gas consumed by the above methods in GWei
    uint[3] memory gasUsage = [uint(141),95,60];
    setGasUsage(signatures, gasUsage);
    setGasPrice(kGasPrice);
  }


  /**
  * transfers an amount from the contract balance to the owner's wallet.
  * @param receiver the receiver address
	*				 amount   the amount of tokens to withdraw (0 decimals)
	*				 v,r,s 		the signature of the player
  **/
  function withdrawFor(address receiver, uint amount, uint8 v, bytes32 r, bytes32 s) public onlyAuthorized keepAlive{
	var player = ecrecover(keccak256(receiver, amount, withdrawCount[receiver]), v, r, s);
	withdrawCount[receiver]++;
	uint value = addGas(safeMul(amount,100000));
    balanceOf[player] = safeSub(balanceOf[player], value);
	playerBalance = safeSub(playerBalance, value);
    assert(edg.transfer(receiver, amount));
	Withdrawal(player, receiver, amount);
  }

  /**
  * authorize a address to call game functions.
  * @param addr the address to be authorized
  **/
  function authorize(address addr) public onlyOwner{
    authorized[addr] = true;
  }

  /**
  * deauthorize a address to call game functions.
  * @param addr the address to be deauthorized
  **/
  function deauthorize(address addr) public onlyOwner{
    authorized[addr] = false;
  }

  /**
   * closes a state channel. can also be used for intermediate state updates. can be called by both parties.
   * 1. verifies the signature.
   * 2. verifies if the signed game-count is higher than the last known game-count of this channel.
   * 3. updates the balances accordingly. This means: It checks the already performed updates for this channel and computes
   *    the new balance difference to add or subtract from the player‘s balance.
   * @param winBalance the current win or loss
   *				gameCount  the number of signed game moves
   *				v,r,s      the signature of either the casino or the player
   * */
  function updateState(int128 winBalance,  uint128 gameCount, uint8 v, bytes32 r, bytes32 s) public{
  	address player = determinePlayer(winBalance, gameCount, v, r, s);
  	uint gasCost = 0;
  	if(player == msg.sender)//if the player closes the state channel himself, make sure the signer is a casino wallet
  		require(authorized[ecrecover(keccak256(player, winBalance, gameCount), v, r, s)]);
  	else//if the casino wallet is the sender, subtract the gas costs from the player balance
  		gasCost = getGasCost();
  	State storage last = lastState[player];
  	require(gameCount > last.count);
  	int difference = updatePlayerBalance(player, winBalance, last.winBalance, gasCost);
  	lastState[player] = State(gameCount, winBalance);
  	StateUpdate(gameCount, winBalance, difference, gasCost, player, last.count);
  }

  /**
   * determines if the msg.sender or the signer of the passed signature is the player. returns the player's address
   * @param winBalance the current winBalance, used to calculate the msg hash
   *				gameCount  the current gameCount, used to calculate the msg.hash
   *				v, r, s    the signature of the non-sending party
   * */
  function determinePlayer(int128 winBalance, uint128 gameCount, uint8 v, bytes32 r, bytes32 s) constant internal returns(address){
  	if (authorized[msg.sender])//casino is the sender -> player is the signer
  		return ecrecover(keccak256(winBalance, gameCount), v, r, s);
  	else
  		return msg.sender;
  }

	/**
	 * computes the difference of the win balance relative to the last known state and adds it to the player's balance.
	 * in case the casino is the sender, the gas cost in EDG gets subtracted from the player's balance.
	 * @param player the address of the player
	 *				winBalance the current win-balance
	 *				lastWinBalance the win-balance of the last known state
	 *				gasCost the gas cost of the tx
	 * */
  function updatePlayerBalance(address player, int128 winBalance, int128 lastWinBalance, uint gasCost) internal returns(int difference){
  	difference = safeSub(winBalance, lastWinBalance);
  	int outstanding = safeSub(difference, int(gasCost));
  	uint outs;
  	if(outstanding < 0){
  		outs = uint256(outstanding * (-1));
  		playerBalance = safeSub(playerBalance, outs);
  		balanceOf[player] = safeSub(balanceOf[player], outs);
  	}
  	else{
  		outs = uint256(outstanding);
  	  playerBalance = safeAdd(playerBalance, outs);
  	  balanceOf[player] = safeAdd(balanceOf[player], outs);
  	}
  }
  
  /**
   * logs some seeds and game results for players wishing to have their game history logged by the contract
   * @param serverSeeds array containing the server seeds
   *        clientSeeds array containing the client seeds
   *        results     array containing the results
   *        v, r, s     the signature of the non-sending party (to make sure the corrcet results are logged)
   * */
  function logGameData(bytes32[] serverSeeds, bytes32[] clientSeeds, int[] results, uint8 v, bytes32 r, bytes32 s) public{
    address player = determinePlayer(serverSeeds, clientSeeds, results, v, r, s);
    GameData(player, serverSeeds, clientSeeds, results);
    //charge gas in case the server is logging the results for the player
    if(player != msg.sender){
      uint gasCost = (57 + 768 * serverSeeds.length / 1000)*gasPrice;
      balanceOf[player] = safeSub(balanceOf[player], gasCost);
      playerBalance = safeSub(playerBalance, gasCost);
    }
  }
  
  /**
   * determines if the msg.sender or the signer of the passed signature is the player. returns the player's address
   * @param serverSeeds array containing the server seeds
   *        clientSeeds array containing the client seeds
   *        results     array containing the results
   *				v, r, s    the signature of the non-sending party
   * */
  function determinePlayer(bytes32[] serverSeeds, bytes32[] clientSeeds, int[] results, uint8 v, bytes32 r, bytes32 s) constant internal returns(address){
  	if (authorized[msg.sender])//casino is the sender -> player is the signer
  		return ecrecover(keccak256(serverSeeds, clientSeeds, results), v, r, s);
  	else
  		return msg.sender;
  }

}