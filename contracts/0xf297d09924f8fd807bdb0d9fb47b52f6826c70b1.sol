pragma solidity ^0.5.7;

/**
 * Math operations with safety checks
 */
contract SafeMath {
  function safeMul(uint256 a, uint256 b)pure internal returns (uint256) {
    uint256 c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function safeDiv(uint256 a, uint256 b)pure internal returns (uint256) {
    assert(b > 0);
    uint256 c = a / b;
    assert(a == b * c + a % b);
    return c;
  }

  function safeSub(uint256 a, uint256 b)pure internal returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function safeAdd(uint256 a, uint256 b)pure internal returns (uint256) {
    uint256 c = a + b;
    assert(c>=a && c>=b);
    return c;
  }

}
contract PAPP is SafeMath{
    string  public  constant name = "PolyAlpha";
    string  public  constant symbol = "PAPP";
    uint8   public  constant decimals = 18;
    uint256 public totalSupply = 10**9;
    uint256 public unsetCoin;
	address public owner = 0xcb194c3127A9728907EeF53c7078A7052f6F23CA;
    
    /* This creates an array with all balances */
    mapping (address => uint256) public balanceOf;
	mapping (address => uint256) public freezeOf;
    mapping (address => mapping (address => uint256)) public allowance;

    /* This generates a public event on the blockchain that will notify clients */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /* This notifies clients about the amount burnt */
    event Burn(address indexed from, uint256 value);
	
	/* This notifies clients about the amount frozen */
    event Freeze(address indexed from, uint256 value);
	
	/* This notifies clients about the amount unfrozen */
    event Unfreeze(address indexed from, uint256 value);

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }
    event FounderUnlock(address _sender, uint256 _amount);
    struct founderLock {
        uint256 amount;
        uint256 startTime;
        uint remainRound;
        uint totalRound;
        uint256 period;
    }
    mapping (address => founderLock) public founderLockance;
    address address1 = 0xDD35f75513E6265b57EcE5CC587A09768969525d;
    address address2 = 0x51909b2623d90fF2B04aC503F40C51F12Fc7aB49;
    address address3 = 0x1893A8f045e2eC40498f254D6978A349c53dF2D3;
    address address4 = 0x7BEE83C5103B1734e315Cc0C247E7D98492c193f;
    address address5 = 0xEB759Dd32Fc9454BF5d0C3AFD9C739840987A84f;
    
    /* Initializes contract with initial supply tokens to the creator of the contract */
    constructor(
        ) public {
        setFounderLock(address1, totalSupply/10, 4, 180 days);
        setFounderLock(address2, totalSupply/10, 4, 180 days);
        setFounderLock(address3, totalSupply/20, 4, 180 days);
        setFounderLock(address4, totalSupply/20, 4, 180 days);
        balanceOf[address5] = totalSupply*6/10;
        unsetCoin = totalSupply/10;
    }

    /* Send coins */
    function transfer(address _to, uint256 _value) public{
        if (_to == address(0x0)) revert();                               // Prevent transfer to 0x0 address. Use burn() instead
		if (_value <= 0) revert(); 
        if (balanceOf[msg.sender] < _value) revert();           // Check if the sender has enough
        if (balanceOf[_to] + _value < balanceOf[_to]) revert(); // Check for overflows
        balanceOf[msg.sender] = SafeMath.safeSub(balanceOf[msg.sender], _value);                     // Subtract from the sender
        balanceOf[_to] = SafeMath.safeAdd(balanceOf[_to], _value);                            // Add the same to the recipient
        emit Transfer(msg.sender, _to, _value);                   // Notify anyone listening that this transfer took place
    }

    /* Allow another contract to spend some tokens in your behalf */
    function approve(address _spender, uint256 _value) public
        returns (bool success) {
		if (_value <= 0) revert(); 
        allowance[msg.sender][_spender] = _value;
        return true;
    }
       

    /* A contract attempts to get the coins */
    function transferFrom(address _from, address _to, uint256 _value)public returns (bool success) {
        if (_to == address(0x0)) revert();                                // Prevent transfer to 0x0 address. Use burn() instead
		if (_value <= 0) revert(); 
        if (balanceOf[_from] < _value) revert();                 // Check if the sender has enough
        if (balanceOf[_to] + _value < balanceOf[_to]) revert();  // Check for overflows
        if (_value > allowance[_from][msg.sender]) revert();     // Check allowance
        balanceOf[_from] = SafeMath.safeSub(balanceOf[_from], _value);                           // Subtract from the sender
        balanceOf[_to] = SafeMath.safeAdd(balanceOf[_to], _value);                             // Add the same to the recipient
        allowance[_from][msg.sender] = SafeMath.safeSub(allowance[_from][msg.sender], _value);
        emit Transfer(_from, _to, _value);
        return true;
    }

    function burn(uint256 _value)public returns (bool success) {
        if (balanceOf[msg.sender] < _value) revert();            // Check if the sender has enough
		if (_value <= 0) revert(); 
        balanceOf[msg.sender] = SafeMath.safeSub(balanceOf[msg.sender], _value);                      // Subtract from the sender
        totalSupply = SafeMath.safeSub(totalSupply,_value);                                // Updates totalSupply
        emit Burn(msg.sender, _value);
        return true;
    }
	
	function freeze(uint256 _value)public returns (bool success) {
        if (balanceOf[msg.sender] < _value) revert();            // Check if the sender has enough
		if (_value <= 0) revert(); 
        balanceOf[msg.sender] = SafeMath.safeSub(balanceOf[msg.sender], _value);                      // Subtract from the sender
        freezeOf[msg.sender] = SafeMath.safeAdd(freezeOf[msg.sender], _value);                                // Updates totalSupply
        emit Freeze(msg.sender, _value);
        return true;
    }
	
	function unfreeze(uint256 _value)public returns (bool success) {
        if (freezeOf[msg.sender] < _value) revert();            // Check if the sender has enough
		if (_value <= 0) revert(); 
        freezeOf[msg.sender] = SafeMath.safeSub(freezeOf[msg.sender], _value);                      // Subtract from the sender
		balanceOf[msg.sender] = SafeMath.safeAdd(balanceOf[msg.sender], _value);
        emit Unfreeze(msg.sender, _value);
        return true;
    }
	
	function setFounderLock(address _address, uint256 _value, uint _round, uint256 _period)  internal{
        founderLockance[_address].amount = _value;
        founderLockance[_address].startTime = now;
        founderLockance[_address].remainRound = _round;
        founderLockance[_address].totalRound = _round;
        founderLockance[_address].period = _period;
    }
    function ownerSetFounderLock(address _address, uint256 _value, uint _round, uint256 _period) public onlyOwner{
        require(_value <= unsetCoin);
        setFounderLock( _address,  _value,  _round,  _period);
        unsetCoin = SafeMath.safeSub(unsetCoin, _value);
    }
    function unlockFounder () public{
        require(now >= founderLockance[msg.sender].startTime + (founderLockance[msg.sender].totalRound - founderLockance[msg.sender].remainRound + 1) * founderLockance[msg.sender].period);
        require(founderLockance[msg.sender].remainRound > 0);
        uint256 changeAmount = SafeMath.safeDiv(founderLockance[msg.sender].amount,founderLockance[msg.sender].remainRound);
        balanceOf[msg.sender] = SafeMath.safeAdd(balanceOf[msg.sender],changeAmount);
        founderLockance[msg.sender].amount = SafeMath.safeSub(founderLockance[msg.sender].amount,changeAmount);
        founderLockance[msg.sender].remainRound --;
        emit FounderUnlock(msg.sender, changeAmount);
    }
}