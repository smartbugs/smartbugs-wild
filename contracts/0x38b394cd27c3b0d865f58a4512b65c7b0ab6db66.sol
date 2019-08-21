//A BurnableOpenPayment is instantiated with a specified payer and a serviceDeposit.
//The worker is not set when the contract is instantiated.

//The constructor is payable, so the contract can be instantiated with initial funds.
//In addition, anyone can add more funds to the Payment by calling addFunds.

//All behavior of the contract is directed by the payer, but
//the payer can never directly recover the payment,
//unless he calls the recover() function before anyone else commit()s.

//If the BOP is in the Open state,
//anyone can become the worker by contributing the serviceDeposit with commit().
//This changes the state from Open to Committed. The BOP will never return to the Open state.
//The worker will never be changed once it's been set via commit().

//In the committed state,
//the payer can at any time choose to burn or release to the worker any amount of funds.

pragma solidity ^ 0.4.10;
contract BurnableOpenPaymentFactory {
	event NewBOP(address indexed newBOPAddress, address payer, uint serviceDeposit, uint autoreleaseTime, string title, string initialStatement);

	//contract address array
	address[]public BOPs;

	function getBOPCount()
	public
	constant
	returns(uint) {
		return BOPs.length;
	}

	function newBurnableOpenPayment(address payer, uint serviceDeposit, uint autoreleaseInterval, string title, string initialStatement)
	public
	payable
	returns(address) {
		//pass along any ether to the constructor
		address newBOPAddr = (new BurnableOpenPayment).value(msg.value)(payer, serviceDeposit, autoreleaseInterval, title, initialStatement);
		NewBOP(newBOPAddr, payer, serviceDeposit, autoreleaseInterval, title, initialStatement);

		//save created BOPs in contract array
		BOPs.push(newBOPAddr);

		return newBOPAddr;
	}
}

contract BurnableOpenPayment {
    //title will never change
    string public title;
    
	//BOP will start with a payer but no worker (worker==0x0)
	address public payer;
	address public worker;
	address constant burnAddress = 0x0;
	
	//Set to true if fundsRecovered is called
	bool recovered = false;

	//Note that these will track, but not influence the BOP logic.
	uint public amountDeposited;
	uint public amountBurned;
	uint public amountReleased;

	//Amount of ether a prospective worker must pay to permanently become the worker. See commit().
	uint public serviceDeposit;

	//How long should we wait before allowing the default release to be called?
	uint public autoreleaseInterval;

	//Calculated from autoreleaseInterval in commit(),
	//and recaluclated whenever the payer (or possibly the worker) calls delayhasDefaultRelease()
	//After this time, auto-release can be called by the Worker.
	uint public autoreleaseTime;

	//Most action happens in the Committed state.
	enum State {
		Open,
		Committed,
		Closed
	}
	State public state;
	//Note that a BOP cannot go from Committed back to Open, but it can go from Closed back to Committed
	//(this would retain the committed worker). Search for Closed and Unclosed events to see how this works.

	modifier inState(State s) {
		require(s == state);
		_;
	}
	modifier onlyPayer() {
		require(msg.sender == payer);
		_;
	}
	modifier onlyWorker() {
		require(msg.sender == worker);
		_;
	}
	modifier onlyPayerOrWorker() {
		require((msg.sender == payer) || (msg.sender == worker));
		_;
	}

	event Created(address indexed contractAddress, address payer, uint serviceDeposit, uint autoreleaseInterval, string title);
	event FundsAdded(address from, uint amount); //The payer has added funds to the BOP.
	event PayerStatement(string statement);
	event WorkerStatement(string statement);
	event FundsRecovered();
	event Committed(address worker);
	event FundsBurned(uint amount);
	event FundsReleased(uint amount);
	event Closed();
	event Unclosed();
	event AutoreleaseDelayed();
	event AutoreleaseTriggered();

	function BurnableOpenPayment(address _payer, uint _serviceDeposit, uint _autoreleaseInterval, string _title, string initialStatement)
	public
	payable {
		Created(this, _payer, _serviceDeposit, _autoreleaseInterval, _title);

		if (msg.value > 0) {
		    //Here we use tx.origin instead of msg.sender (msg.sender is just the factory contract)
			FundsAdded(tx.origin, msg.value);
			amountDeposited += msg.value;
		}
		
		title = _title;

		state = State.Open;
		payer = _payer;

		serviceDeposit = _serviceDeposit;

		autoreleaseInterval = _autoreleaseInterval;

		if (bytes(initialStatement).length > 0)
		    PayerStatement(initialStatement);
	}

	function getFullState()
	public
	constant
	returns(address, string, State, address, uint, uint, uint, uint, uint, uint, uint) {
		return (payer, title, state, worker, this.balance, serviceDeposit, amountDeposited, amountBurned, amountReleased, autoreleaseInterval, autoreleaseTime);
	}

	function addFunds()
	public
	payable {
		require(msg.value > 0);

		FundsAdded(msg.sender, msg.value);
		amountDeposited += msg.value;
		if (state == State.Closed) {
			state = State.Committed;
			Unclosed();
		}
	}

	function recoverFunds()
	public
	onlyPayer()
	inState(State.Open) {
	    recovered = true;
		FundsRecovered();
		selfdestruct(payer);
	}

	function commit()
	public
	inState(State.Open)
	payable{
		require(msg.value == serviceDeposit);

		if (msg.value > 0) {
			FundsAdded(msg.sender, msg.value);
			amountDeposited += msg.value;
		}

		worker = msg.sender;
		state = State.Committed;
		Committed(worker);

		autoreleaseTime = now + autoreleaseInterval;
	}

	function internalBurn(uint amount)
	private
	inState(State.Committed) {
		burnAddress.transfer(amount);

		amountBurned += amount;
		FundsBurned(amount);

		if (this.balance == 0) {
			state = State.Closed;
			Closed();
		}
	}

	function burn(uint amount)
	public
	inState(State.Committed)
	onlyPayer() {
		internalBurn(amount);
	}

	function internalRelease(uint amount)
	private
	inState(State.Committed) {
		worker.transfer(amount);

		amountReleased += amount;
		FundsReleased(amount);

		if (this.balance == 0) {
			state = State.Closed;
			Closed();
		}
	}

	function release(uint amount)
	public
	inState(State.Committed)
	onlyPayer() {
		internalRelease(amount);
	}

	function logPayerStatement(string statement)
	public
	onlyPayer() {
	    PayerStatement(statement);
	}

	function logWorkerStatement(string statement)
	public
	onlyWorker() {
		WorkerStatement(statement);
	}

	function delayAutorelease()
	public
	onlyPayer()
	inState(State.Committed) {
		autoreleaseTime = now + autoreleaseInterval;
		AutoreleaseDelayed();
	}

	function triggerAutorelease()
	public
	onlyWorker()
	inState(State.Committed) {
		require(now >= autoreleaseTime);

        AutoreleaseTriggered();
		internalRelease(this.balance);
	}
}