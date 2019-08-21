pragma solidity 0.5.1; 


library SafeMath {

    uint256 constant internal MAX_UINT = 2 ** 256 - 1; // max uint256

    /**
     * @dev Multiplies two numbers, reverts on overflow.
     */
    function mul(uint256 _a, uint256 _b) internal pure returns(uint256) {
        if (_a == 0) {
            return 0;
        }
        require(MAX_UINT / _a >= _b);
        return _a * _b;
    }

    /**
     * @dev Integer division of two numbers truncating the quotient, reverts on division by zero.
     */
    function div(uint256 _a, uint256 _b) internal pure returns(uint256) {
        require(_b != 0);
        return _a / _b;
    }

    /**
     * @dev Subtracts two numbers, reverts on overflow (i.e. if subtrahend is greater than minuend).
     */
    function sub(uint256 _a, uint256 _b) internal pure returns(uint256) {
        require(_b <= _a);
        return _a - _b;
    }

    /**
     * @dev Adds two numbers, reverts on overflow.
     */
    function add(uint256 _a, uint256 _b) internal pure returns(uint256) {
        require(MAX_UINT - _a >= _b);
        return _a + _b;
    }

}


contract Ownable {
    address public owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    /**
     * @dev Allows the current owner to transfer control of the contract to a newOwner.
     * @param _newOwner The address to transfer ownership to.
     */
    function transferOwnership(address _newOwner) public onlyOwner {
        _transferOwnership(_newOwner);
    }

    /**
     * @dev Transfers control of the contract to a newOwner.
     * @param _newOwner The address to transfer ownership to.
     */
    function _transferOwnership(address _newOwner) internal {
        require(_newOwner != address(0));
        emit OwnershipTransferred(owner, _newOwner);
        owner = _newOwner;
    }
}


contract Pausable is Ownable {
    event Pause();
    event Unpause();

    bool public paused = false;

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     */
    modifier whenNotPaused() {
        require(!paused);
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     */
    modifier whenPaused() {
        require(paused);
        _;
    }

    /**
     * @dev called by the owner to pause, triggers stopped state
     */
    function pause() public onlyOwner whenNotPaused {
        paused = true;
        emit Pause();
    }

    /**
     * @dev called by the owner to unpause, returns to normal state
     */
    function unpause() public onlyOwner whenPaused {
        paused = false;
        emit Unpause();
    }
}


contract StandardToken {
    using SafeMath for uint256;

    mapping(address => uint256) internal balances;

    mapping(address => mapping(address => uint256)) internal allowed;

    mapping (address => bool) public frozenAccount;

    uint256 internal totalSupply_;

    event Transfer(
        address indexed from,
        address indexed to,
        uint256 value
    );

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 vaule
    );

    event FrozenFunds(
        address indexed _account, 
        bool _frozen
    );

    /**
     * @dev Total number of tokens in existence
     */
    function totalSupply() public view returns(uint256) {
        return totalSupply_;
    }

    /**
     * @dev Gets the balance of the specified address.
     * @param _owner The address to query the the balance of.
     * @return An uint256 representing the amount owned by the passed address.
     */
    function balanceOf(address _owner) public view returns(uint256) {
        return balances[_owner];
    }

    /**
     * @dev Function to check the amount of tokens that an owner allowed to a spender.
     * @param _owner address The address which owns the funds.
     * @param _spender address The address which will spend the funds.
     * @return A uint256 specifying the amount of tokens still available for the spender.
     */
    function allowance(
        address _owner,
        address _spender
    )
    public
    view
    returns(uint256) {
        return allowed[_owner][_spender];
    }

    /**
     * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.
     * Beware that changing an allowance with this method brings the risk that someone may use both the old
     * and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this
     * race condition is to first reduce the spender's allowance to 0 and set the desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     * @param _spender The address which will spend the funds.
     * @param _value The amount of tokens to be spent.
     */
    function approve(address _spender, uint256 _value) public returns(bool) {
        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    /**
     * @dev Increase the amount of tokens that an owner allowed to a spender.
     * approve should be called when allowed[_spender] == 0. To increment
     * allowed value is better to use this function to avoid 2 calls (and wait until
     * the first transaction is mined)
     * From MonolithDAO Token.sol
     * @param _spender The address which will spend the funds.
     * @param _addedValue The amount of tokens to increase the allowance by.
     */
    function increaseApproval(
        address _spender,
        uint256 _addedValue
    )
    public
    returns(bool) {
        allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
        emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
        return true;
    }

    /**
     * @dev Decrease the amount of tokens that an owner allowed to a spender.
     * approve should be called when allowed[_spender] == 0. To decrement
     * allowed value is better to use this function to avoid 2 calls (and wait until
     * the first transaction is mined)
     * From MonolithDAO Token.sol
     * @param _spender The address which will spend the funds.
     * @param _subtractedValue The amount of tokens to decrease the allowance by.
     */
    function decreaseApproval(
        address _spender,
        uint256 _subtractedValue
    )
    public
    returns(bool) {
        uint256 oldValue = allowed[msg.sender][_spender];
        if (_subtractedValue >= oldValue) {
            allowed[msg.sender][_spender] = 0;
        } else {
            allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
        }
        emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
        return true;
    }
}


contract BurnableToken is StandardToken, Ownable {

    event Burn(address indexed account, uint256 value);

    /**
     * @dev Internal function that burns an amount of the token of a given
     * account. Uses the internal burn function.
     * @param account The account whose tokens will be burnt.
     * @param value The amount that will be burnt.
     */
    function _burn(address account, uint256 value) internal {
        require(account != address(0)); 
        totalSupply_ = totalSupply_.sub(value);
        balances[account] = balances[account].sub(value);
        emit Burn(account, value);
        emit Transfer(account, address(0), value);
    }

    /**
     * @dev Burns a specific amount of tokens.
     * @param value The amount of token to be burned.
     */
    function burn(uint256 value) public onlyOwner {
        _burn(msg.sender, value);
    }
}


contract PausableToken is StandardToken, Pausable {
    function approve(
        address _spender,
        uint256 _value
    )
    public
    whenNotPaused
    returns(bool) {
        return super.approve(_spender, _value);
    }

    function increaseApproval(
        address _spender,
        uint _addedValue
    )
    public
    whenNotPaused
    returns(bool success) {
        return super.increaseApproval(_spender, _addedValue);
    }

    function decreaseApproval(
        address _spender,
        uint _subtractedValue
    )
    public
    whenNotPaused
    returns(bool success) {
        return super.decreaseApproval(_spender, _subtractedValue);
    }
}


/**
 * @title AQQToken token
 * @dev Initialize the basic information of AQQToken.
 */
contract AQQToken is PausableToken, BurnableToken {
    using SafeMath for uint256;

    string public constant name = "AQQ"; // name of Token
    string public constant symbol = "AQQ"; // symbol of Token
    uint8 public constant decimals = 18; // decimals of Token

    uint256 internal vestingToken; 
    uint256 public initialCirculatingToken; 
    address constant wallet = 0xC151c00E83988ce3774Cde684f0209AD46C12aFC; 

    uint256 constant _INIT_TOTALSUPPLY = 100000000; 
    uint256 constant _INIT_VESTING_TOKEN = 60000000; 
    uint256 constant _INIT_CIRCULATE_TOKEN = 10000000;

  /**
   * @dev constructor Initialize the basic information.
   */
    constructor() public {
        totalSupply_ = _INIT_TOTALSUPPLY * 10 ** uint256(decimals); // amount of totalsupply
        vestingToken = _INIT_VESTING_TOKEN * 10 ** uint256(decimals); // total amount of token circulation plan after deploy
        initialCirculatingToken = _INIT_CIRCULATE_TOKEN * 10 ** uint256(decimals); // amount of circulating tokens
        owner = wallet; // Specify owner as wallet address
        balances[wallet] = totalSupply_;
    }

  /**
   * @dev getVestingToken function that returns a value of the remaining outstanding tokens in the current circulation plan.
   */
    function getVestingToken() public view returns(uint256 amount){
        if(now < 1546272000) { //2019.01.01 00:00:00
            return vestingToken;
        }else if(now < 1577808000) { //2020.01.01 00:00:00
            return vestingToken.sub(20000000 * 10 ** uint256(decimals));
        }else if(now < 1609430400) { //2021.01.01 00:00:00
            return vestingToken.sub(40000000 * 10 ** uint256(decimals));
        }else {
            return 0;
        }
    }

  /**
   * @dev _validate internal function that validate the balance of _addr is more than _value.
   */
    function _validate(address _addr, uint256 _value) internal view {
        uint256 vesting = getVestingToken();
        require(balances[_addr] >= vesting.add(_value));
    }

    /**
     * @dev Transfer token for a specified address
     * @param _to The address to transfer to.
     * @param _value The amount to be transferred.
     */
    function transfer(
        address _to, 
        uint256 _value
    ) 
    public 
    whenNotPaused 
    returns(bool) {
        require(_to != address(0));
        require(!frozenAccount[msg.sender]);
        require(!frozenAccount[_to]);
        require(_value <= balances[msg.sender]);
        if(msg.sender == wallet) {
            _validate(msg.sender, _value);
        }
        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);
        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    /**
     * @dev Transfer tokens from one address to another
     * @param _from address The address which you want to send tokens from
     * @param _to address The address which you want to transfer to
     * @param _value uint256 the amount of tokens to be transferred
     */
    function transferFrom(
        address _from,
        address _to,
        uint256 _value
    )
    public
    whenNotPaused
    returns(bool) {
        require(_to != address(0));
        require(!frozenAccount[_from]);
        require(!frozenAccount[_to]);
        require(_value <= balances[_from]);
        require(_value <= allowed[_from][msg.sender]);
        if(_from == wallet) {
            _validate(_from, _value);
        }
        balances[_from] = balances[_from].sub(_value);
        balances[_to] = balances[_to].add(_value);
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
        emit Transfer(_from, _to, _value);
        return true;
    }

  /**
   * @dev freezeAccount function that freeze the funds of target address.
   * @param _account target address
   * @param _freeze position of funds，true or false
   */
    function freezeAccount(address _account, bool _freeze) public onlyOwner returns(bool) {
        frozenAccount[_account] = _freeze;
        emit FrozenFunds(_account, _freeze);    
        return true;    
    }

  /**
   * @dev _batchTransfer internal function for airdropping candy to target address.
   * @param _to target address
   * @param _amount amount of token
   */
    function _batchTransfer(address[] memory _to, uint256[] memory _amount) internal whenNotPaused {
        require(_to.length == _amount.length);
        uint256 sum = 0; 
        for(uint256 i = 0;i < _to.length;i += 1){
            require(_to[i] != address(0)); 
            require(!frozenAccount[_to[i]]); 
            sum = sum.add(_amount[i]);
            require(sum <= balances[msg.sender]);  
            balances[_to[i]] = balances[_to[i]].add(_amount[i]); 
            emit Transfer(msg.sender, _to[i], _amount[i]);
        } 
        _validate(msg.sender, sum);
        balances[msg.sender] = balances[msg.sender].sub(sum); 
    }

  /**
   * @dev airdrop function for airdropping candy to target address.
   * @param _to target address
   * @param _amount amount of token
   */
    function airdrop(address[] memory _to, uint256[] memory _amount) public onlyOwner returns(bool){
        _batchTransfer(_to, _amount);
        return true;
    }

  /**
   * @dev overwrite the burn function and call the _validate internal function to validate the value.
   * @param value amount of burn tokens
   */
    function burn(uint256 value) public onlyOwner {
        _validate(msg.sender, value);
        super.burn(value); 
    }
}