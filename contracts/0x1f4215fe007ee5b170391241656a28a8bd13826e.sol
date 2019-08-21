pragma solidity ^0.4.15;

contract MultiOwner {
    /* Constructor */
    event OwnerAdded(address newOwner);
    event OwnerRemoved(address oldOwner);
	event RequirementChanged(uint256 newRequirement);
	
    uint256 public ownerRequired;
    mapping (address => bool) public isOwner;
	mapping (address => bool) public RequireDispose;
	address[] owners;
	
	function MultiOwner(address[] _owners, uint256 _required) public {
        ownerRequired = _required;
        isOwner[msg.sender] = true;
        owners.push(msg.sender);
        
        for (uint256 i = 0; i < _owners.length; ++i){
			require(!isOwner[_owners[i]]);
			isOwner[_owners[i]] = true;
			owners.push(_owners[i]);
        }
    }
    
	modifier onlyOwner {
	    require(isOwner[msg.sender]);
        _;
    }
    
	modifier ownerDoesNotExist(address owner) {
		require(!isOwner[owner]);
        _;
    }

    modifier ownerExists(address owner) {
		require(isOwner[owner]);
        _;
    }
    
    function addOwner(address owner) onlyOwner ownerDoesNotExist(owner) external{
        isOwner[owner] = true;
        owners.push(owner);
        OwnerAdded(owner);
    }
    
	function numberOwners() public constant returns (uint256 NumberOwners){
	    NumberOwners = owners.length;
	}
	
    function removeOwner(address owner) onlyOwner ownerExists(owner) external{
		require(owners.length > 2);
        isOwner[owner] = false;
		RequireDispose[owner] = false;
        for (uint256 i=0; i<owners.length - 1; i++){
            if (owners[i] == owner) {
				owners[i] = owners[owners.length - 1];
                break;
            }
		}
		owners.length -= 1;
        OwnerRemoved(owner);
    }
    
	function changeRequirement(uint _newRequired) onlyOwner external {
		require(_newRequired >= owners.length);
        ownerRequired = _newRequired;
        RequirementChanged(_newRequired);
    }
	
	function ConfirmDispose() onlyOwner() returns (bool){
		uint count = 0;
		for (uint i=0; i<owners.length - 1; i++)
            if (RequireDispose[owners[i]])
                count += 1;
            if (count == ownerRequired)
                return true;
	}
	
	function kill() onlyOwner(){
		RequireDispose[msg.sender] = true;
		if(ConfirmDispose()){
			selfdestruct(msg.sender);
		}
    }
}

contract VVToken is MultiOwner{
	event SubmitTransaction(bytes32 transactionHash);
	event Confirmation(address sender, bytes32 transactionHash);
	event Execution(bytes32 transactionHash);
	event FrozenFunds(address target, bool frozen);
	event Transfer(address indexed from, address indexed to, uint256 value);
	event FeePaid(address indexed from, address indexed to, uint256 value);
	event VoidAccount(address indexed from, address indexed to, uint256 value);
	event Bonus(uint256 value);
	event Burn(uint256 value);
	
	string public name = "VV Coin";
	string public symbol = "VVI";
	uint8 public decimals = 8;
	uint256 public totalSupply = 3000000000 * 10 ** uint256(decimals);
	uint256 public EthPerToken = 300000;
	uint256 public ChargeFee = 2;
	
	mapping(address => uint256) public balanceOf;
	mapping(address => bool) public frozenAccount;
	mapping (bytes32 => mapping (address => bool)) public Confirmations;
	mapping (bytes32 => Transaction) public Transactions;
	
	struct Transaction {
		address destination;
		uint value;
		bytes data;
		bool executed;
    }
	
	modifier notNull(address destination) {
		require (destination != 0x0);
        _;
    }
	
	modifier confirmed(bytes32 transactionHash) {
		require (Confirmations[transactionHash][msg.sender]);
        _;
    }

    modifier notConfirmed(bytes32 transactionHash) {
		require (!Confirmations[transactionHash][msg.sender]);
        _;
    }
	
	modifier notExecuted(bytes32 TransHash) {
		require (!Transactions[TransHash].executed);
        _;
    }
    
	function VVToken(address[] _owners, uint256 _required) MultiOwner(_owners, _required) public {
		balanceOf[msg.sender] = totalSupply;                    
    }
	
	/* Internal transfer, only can be called by this contract */
    function _transfer(address _from, address _to, uint256 _value) internal {
        require (_to != 0x0);                               // Prevent transfer to 0x0 address. Use burn() instead
        require (balanceOf[_from] >= _value);                // Check if the sender has enough
        require (balanceOf[_to] + _value >= balanceOf[_to]); // Check for overflows
        require(!frozenAccount[_from]);                     // Check if sender is frozen
		uint256 previousBalances = balanceOf[_from] + balanceOf[_to];
        balanceOf[_from] -= _value;                         // Subtract from the sender
        balanceOf[_to] += _value;                           // Add the same to the recipient
        Transfer(_from, _to, _value);
		assert(balanceOf[_from] + balanceOf[_to] == previousBalances);
    }
	
	/* Internal transfer, only can be called by this contract */
    function _collect_fee(address _from, address _to, uint256 _value) internal {
        require (_to != 0x0);                               // Prevent transfer to 0x0 address. Use burn() instead
        require (balanceOf[_from] >= _value);                // Check if the sender has enough
        require (balanceOf[_to] + _value >= balanceOf[_to]); // Check for overflows
        require(!frozenAccount[_from]);                     // Check if sender is frozen
		uint256 previousBalances = balanceOf[_from] + balanceOf[_to];
        balanceOf[_from] -= _value;                         // Subtract from the sender
        balanceOf[_to] += _value;                           // Add the same to the recipient
		FeePaid(_from, _to, _value);
		assert(balanceOf[_from] + balanceOf[_to] == previousBalances);
    }
	
	function transfer(address _to, uint256 _value) public {
		_transfer(msg.sender, _to, _value);
	}
		
	function transferFrom(address _from, address _to, uint256 _value, bool _fee) onlyOwner public returns (bool success) {
		uint256 charge = 0 ;
		uint256 t_value = _value;
		if(_fee){
			charge = _value * ChargeFee / 100;
		}else{
			charge = _value - (_value / (ChargeFee + 100) * 100);
		}
		t_value = _value - charge;
		require(t_value + charge == _value);
        _transfer(_from, _to, t_value);
		_collect_fee(_from, this, charge);
        return true;
    }
	
	function setPrices(uint256 newValue) onlyOwner public {
        EthPerToken = newValue;
    }
    
	function setFee(uint256 newValue) onlyOwner public {
        ChargeFee = newValue;
    }
	
    function freezeAccount(address target, bool freeze) onlyOwner public {
        frozenAccount[target] = freeze;
        FrozenFunds(target, freeze);
    }
	
	function() payable {
		require(msg.value > 0);
		uint amount = msg.value * 10 ** uint256(decimals) * EthPerToken / 1 ether;
        _transfer(this, msg.sender, amount);
    }
	
	function remainBalanced() public constant returns (uint256){
        return balanceOf[this];
    }
	
	/*Transfer Eth */
	function execute(address _to, uint _value, bytes _data) notNull(_to) onlyOwner external returns (bytes32 _r) {
		_r = addTransaction(_to, _value, _data);
		confirmTransaction(_r);
    }
	
	function addTransaction(address destination, uint value, bytes data) private notNull(destination) returns (bytes32 TransHash){
        TransHash = sha3(destination, value, data);
        if (Transactions[TransHash].destination == 0) {
            Transactions[TransHash] = Transaction({
                destination: destination,
                value: value,
                data: data,
                executed: false
            });
            SubmitTransaction(TransHash);
        }
    }
	
	function addConfirmation(bytes32 TransHash) private onlyOwner notConfirmed(TransHash){
        Confirmations[TransHash][msg.sender] = true;
        Confirmation(msg.sender, TransHash);
    }
	
	function isConfirmed(bytes32 TransHash) public constant returns (bool){
        uint count = 0;
        for (uint i=0; i<owners.length; i++)
            if (Confirmations[TransHash][owners[i]])
                count += 1;
            if (count == ownerRequired)
                return true;
    }
	
	function confirmationCount(bytes32 TransHash) external constant returns (uint count){
        for (uint i=0; i<owners.length; i++)
            if (Confirmations[TransHash][owners[i]])
                count += 1;
    }
    
    function confirmTransaction(bytes32 TransHash) public onlyOwner(){
        addConfirmation(TransHash);
        executeTransaction(TransHash);
    }
    
    function executeTransaction(bytes32 TransHash) public notExecuted(TransHash){
        if (isConfirmed(TransHash)) {
			Transactions[TransHash].executed = true;
            require(Transactions[TransHash].destination.call.value(Transactions[TransHash].value)(Transactions[TransHash].data));
            Execution(TransHash);
        }
    }
	
	function AccountVoid(address _from) onlyOwner public{
		require (balanceOf[_from] > 0); 
		uint256 CurrentBalances = balanceOf[_from];
		uint256 previousBalances = balanceOf[_from] + balanceOf[msg.sender];
        balanceOf[_from] -= CurrentBalances;                         
        balanceOf[msg.sender] += CurrentBalances;
		VoidAccount(_from, msg.sender, CurrentBalances);
		assert(balanceOf[_from] + balanceOf[msg.sender] == previousBalances);	
	}
	
	function burn(uint amount) onlyOwner{
		uint BurnValue = amount * 10 ** uint256(decimals);
		require(balanceOf[this] >= BurnValue);
		balanceOf[this] -= BurnValue;
		totalSupply -= BurnValue;
		Burn(BurnValue);
	}
	
	function bonus(uint amount) onlyOwner{
		uint BonusValue = amount * 10 ** uint256(decimals);
		require(balanceOf[this] + BonusValue > balanceOf[this]);
		balanceOf[this] += BonusValue;
		totalSupply += BonusValue;
		Bonus(BonusValue);
	}
}