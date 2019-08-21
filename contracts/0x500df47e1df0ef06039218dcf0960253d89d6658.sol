pragma solidity ^0.4.16;

interface tokenRecipient { function receiveApproval(address _from, uint256 _value, address _token, bytes _extraData) external; }

contract DateTime {
		function toTimestamp(uint16 year, uint8 month, uint8 day) public constant returns (uint timestamp);
        function getYear(uint timestamp) public constant returns (uint16);
        function getMonth(uint timestamp) public constant returns (uint8);
        function getDay(uint timestamp) public constant returns (uint8);
}

contract TokenERC20 {
    // Public variables of the token
    string public name = "Authpaper Coin";
    string public symbol = "AUPC";
    uint8 public decimals = 18;
    // 18 decimals is the strongly suggested default, avoid changing it
    uint256 public totalSupply = 400000000 * 10 ** uint256(decimals);
	address public owner;

    // This creates an array with all balances
    mapping (address => uint256) public balanceOf;
    mapping (address => mapping (address => uint256)) public allowance;
	mapping (address => uint256) public icoAmount;

    // This generates a public event on the blockchain that will notify clients
    event Transfer(address indexed from, address indexed to, uint256 value);
    
    // This generates a public event on the blockchain that will notify clients
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);

    // This notifies clients about the amount burnt
    event Burn(address indexed from, uint256 value);
	
	//Date related code
	address public dateTimeAddr = 0x1a6184CD4C5Bea62B0116de7962EE7315B7bcBce;
	DateTime dateTime = DateTime(dateTimeAddr);
	uint[] lockupTime = [dateTime.toTimestamp(2018,9,15),dateTime.toTimestamp(2018,10,15),dateTime.toTimestamp(2018,11,15),
	dateTime.toTimestamp(2018,12,15),dateTime.toTimestamp(2019,1,15),dateTime.toTimestamp(2019,2,15),
	dateTime.toTimestamp(2019,3,15),dateTime.toTimestamp(2019,4,15),dateTime.toTimestamp(2019,5,15),
	dateTime.toTimestamp(2019,6,15),dateTime.toTimestamp(2019,7,15),dateTime.toTimestamp(2019,8,15),
	dateTime.toTimestamp(2019,9,15)];
	uint lockupRatio = 8;
	uint fullTradeTime = dateTime.toTimestamp(2019,10,1);

    /**
     * Constructor function
     *
     * Initializes contract with initial supply tokens to the creator of the contract
     */
    constructor() public {
        balanceOf[msg.sender] = totalSupply;                // Give the creator all initial tokens
		owner = msg.sender;
    }

    /**
     * Internal transfer, only can be called by this contract
     */
    function _transfer(address _from, address _to, uint _value) internal {
        // Prevent transfer to 0x0 address. Use burn() instead
        require(_to != 0x0);
        // Check if the sender has enough
        require(balanceOf[_from] >= _value);
        // Check for overflows
		require( balanceOf[_to] + _value >= balanceOf[_to] );
		require( 100*(balanceOf[_from] - _value) >= (balanceOf[_from] - _value) );
		require( 100*icoAmount[_from] >= icoAmount[_from] );
		require( icoAmount[_to] + _value >= icoAmount[_to] );
		
		if(now < fullTradeTime && _from != owner && _to !=owner && icoAmount[_from] >0) {
			//Check for lockup period and lockup percentage
			uint256 i=0;
			for (uint256 l = lockupTime.length; i < l; i++) {
				if(now < lockupTime[i]) break;
			}
			uint256 minAmountLeft = (i<1)? 0 : ( (lockupRatio*i>100)? 100 : lockupRatio*i );
			minAmountLeft = 100 - minAmountLeft;
			require( ((balanceOf[_from] - _value)*100) >= (minAmountLeft*icoAmount[_from]) );			
		}	
        // Save this for an assertion in the future
        uint previousBalances = balanceOf[_from] + balanceOf[_to];
        // Subtract from the sender
        balanceOf[_from] -= _value;
        // Add the same to the recipient
        balanceOf[_to] += _value;
		if(_from == owner && now < fullTradeTime) icoAmount[_to] += _value;
		if(_to == owner){
			if(icoAmount[_from] >= _value) icoAmount[_from] -= _value;
			else icoAmount[_from]=0;
		}
        emit Transfer(_from, _to, _value);
        // Asserts are used to use static analysis to find bugs in your code. They should never fail
        assert(balanceOf[_from] + balanceOf[_to] == previousBalances);
    }

    /**
     * Transfer tokens
     *
     * Send `_value` tokens to `_to` from your account
     *
     * @param _to The address of the recipient
     * @param _value the amount to send
     */
    function transfer(address _to, uint256 _value) public returns (bool success) {
        _transfer(msg.sender, _to, _value);
        return true;
    }

    /**
     * Transfer tokens from other address
     *
     * Send `_value` tokens to `_to` on behalf of `_from`
     *
     * @param _from The address of the sender
     * @param _to The address of the recipient
     * @param _value the amount to send
     */
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require(_value <= allowance[_from][msg.sender]);     // Check allowance
        allowance[_from][msg.sender] -= _value;
        _transfer(_from, _to, _value);
        return true;
    }
	function addApprove(address _spender, uint256 _value) public returns (bool success){
		require( allowance[msg.sender][_spender] + _value >= allowance[msg.sender][_spender] );
		allowance[msg.sender][_spender] += _value;
        emit Approval(msg.sender, _spender, allowance[msg.sender][_spender]);
		return true;
	}
	function claimICOToken() public returns (bool success){
		require(allowance[owner][msg.sender] > 0);     // Check allowance
		transferFrom(owner,msg.sender,allowance[owner][msg.sender]);
		return true;
	}
	

    /**
     * Set allowance for other address
     *
     * Allows `_spender` to spend no more than `_value` tokens on your behalf
     *
     * @param _spender The address authorized to spend
     * @param _value the max amount they can spend
     */
    function approve(address _spender, uint256 _value) public
        returns (bool success) {
        allowance[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    /**
     * Set allowance for other address and notify
     *
     * Allows `_spender` to spend no more than `_value` tokens on your behalf, and then ping the contract about it
     *
     * @param _spender The address authorized to spend
     * @param _value the max amount they can spend
     * @param _extraData some extra information to send to the approved contract
     */
    function approveAndCall(address _spender, uint256 _value, bytes _extraData)
        public
        returns (bool success) {
        tokenRecipient spender = tokenRecipient(_spender);
        if (approve(_spender, _value)) {
            spender.receiveApproval(msg.sender, _value, this, _extraData);
            return true;
        }
    }

    /**
     * Destroy tokens
     *
     * Remove `_value` tokens from the system irreversibly
     *
     * @param _value the amount of money to burn
     */
    function burn(uint256 _value) public returns (bool success) {
        require(balanceOf[msg.sender] >= _value);   // Check if the sender has enough
        balanceOf[msg.sender] -= _value;            // Subtract from the sender
        totalSupply -= _value;                      // Updates totalSupply
        emit Burn(msg.sender, _value);
        return true;
    }

    /**
     * Destroy tokens from other account
     *
     * Remove `_value` tokens from the system irreversibly on behalf of `_from`.
     *
     * @param _from the address of the sender
     * @param _value the amount of money to burn
     */
    function burnFrom(address _from, uint256 _value) public returns (bool success) {
        require(balanceOf[_from] >= _value);                // Check if the targeted balance is enough
        require(_value <= allowance[_from][msg.sender]);    // Check allowance
        balanceOf[_from] -= _value;                         // Subtract from the targeted balance
        allowance[_from][msg.sender] -= _value;             // Subtract from the sender's allowance
        totalSupply -= _value;                              // Update totalSupply
        emit Burn(_from, _value);
        return true;
    }
}