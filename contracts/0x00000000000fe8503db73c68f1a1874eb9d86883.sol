// File: contracts/Ownable.sol

pragma solidity 0.5.0;

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {

    address private _owner;
    address private _pendingOwner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    
    /**
     * @dev The constructor sets the original owner of the contract to the sender account.
     */
    constructor() public {
        setOwner(msg.sender);
    }

    /**
     * @dev Modifier throws if called by any account other than the pendingOwner.
     */
    modifier onlyPendingOwner() {
        require(msg.sender == _pendingOwner, "msg.sender should be onlyPendingOwner");
        _;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(msg.sender == _owner, "msg.sender should be owner");
        _;
    }

    /**
     * @dev Tells the address of the pendingOwner
     * @return The address of the pendingOwner
     */
    function pendingOwner() public view returns (address) {
        return _pendingOwner;
    }
    
    /**
     * @dev Tells the address of the owner
     * @return the address of the owner
     */
    function owner() public view returns (address ) {
        return _owner;
    }
    
    /**
    * @dev Sets a new owner address
    * @param _newOwner The newOwner to set
    */
    function setOwner(address _newOwner) internal {
        _owner = _newOwner;
    }

    /**
     * @dev Allows the current owner to set the pendingOwner address.
     * @param _newOwner The address to transfer ownership to.
     */
    function transferOwnership(address _newOwner) public onlyOwner {
        _pendingOwner = _newOwner;
    }

    /**
     * @dev Allows the pendingOwner address to finalize the transfer.
     */
    function claimOwnership() public onlyPendingOwner {
        emit OwnershipTransferred(_owner, _pendingOwner);
        _owner = _pendingOwner;
        _pendingOwner = address(0); 
    }
    
}

// File: contracts/Operable.sol

pragma solidity 0.5.0;


contract Operable is Ownable {

    address private _operator; 

    event OperatorChanged(address indexed previousOperator, address indexed newOperator);

    /**
     * @dev Tells the address of the operator
     * @return the address of the operator
     */
    function operator() external view returns (address) {
        return _operator;
    }
    
    /**
     * @dev Only the operator can operate store
     */
    modifier onlyOperator() {
        require(msg.sender == _operator, "msg.sender should be operator");
        _;
    }

    /**
     * @dev update the storgeOperator
     * @param _newOperator The newOperator to update  
     */
    function updateOperator(address _newOperator) public onlyOwner {
        require(_newOperator != address(0), "Cannot change the newOperator to the zero address");
        emit OperatorChanged(_operator, _newOperator);
        _operator = _newOperator;
    }

}

// File: contracts/utils/SafeMath.sol

pragma solidity 0.5.0;

/**
 * @title SafeMath
 * @dev Unsigned math operations with safety checks that revert on error
 */
library SafeMath {
    /**
     * @dev Multiplies two unsigned integers, reverts on overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b);

        return c;
    }

    /**
     * @dev Integer division of two unsigned integers truncating the quotient, reverts on division by zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Subtracts two unsigned integers, reverts on overflow (i.e. if subtrahend is greater than minuend).
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a);
        uint256 c = a - b;

        return c;
    }

    /**
     * @dev Adds two unsigned integers, reverts on overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a);

        return c;
    }

    /**
     * @dev Divides two unsigned integers and returns the remainder (unsigned integer modulo),
     * reverts when dividing by zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0);
        return a % b;
    }
}

// File: contracts/TokenStore.sol

pragma solidity 0.5.0;



contract TokenStore is Operable {

    using SafeMath for uint256;

    uint256 public totalSupply;
    
    string  public name = "PingAnToken";
    string  public symbol = "PAT";
    uint8 public decimals = 18;

    mapping (address => uint256) public balances;
    mapping (address => mapping (address => uint256)) public allowed;

    function changeTokenName(string memory _name, string memory _symbol) public onlyOperator {
        name = _name;
        symbol = _symbol;
    }

    function addBalance(address _holder, uint256 _value) public onlyOperator {
        balances[_holder] = balances[_holder].add(_value);
    }

    function subBalance(address _holder, uint256 _value) public onlyOperator {
        balances[_holder] = balances[_holder].sub(_value);
    }

    function setBalance(address _holder, uint256 _value) public onlyOperator {
        balances[_holder] = _value;
    }

    function addAllowance(address _holder, address _spender, uint256 _value) public onlyOperator {
        allowed[_holder][_spender] = allowed[_holder][_spender].add(_value);
    }

    function subAllowance(address _holder, address _spender, uint256 _value) public onlyOperator {
        allowed[_holder][_spender] = allowed[_holder][_spender].sub(_value);
    }

    function setAllowance(address _holder, address _spender, uint256 _value) public onlyOperator {
        allowed[_holder][_spender] = _value;
    }

    function addTotalSupply(uint256 _value) public onlyOperator {
        totalSupply = totalSupply.add(_value);
    }

    function subTotalSupply(uint256 _value) public onlyOperator {
        totalSupply = totalSupply.sub(_value);
    }

    function setTotalSupply(uint256 _value) public onlyOperator {
        totalSupply = _value;
    }

}

// File: contracts/ERC20Interface.sol

pragma solidity 0.5.0;


interface ERC20Interface {  

    function totalSupply() external view returns (uint256);

    function balanceOf(address holder) external view returns (uint256);

    function allowance(address holder, address spender) external view returns (uint256);

    function transfer(address to, uint256 value) external returns (bool);

    function approve(address spender, uint256 value) external returns (bool);

    function transferFrom(address from, address to, uint256 value) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed holder, address indexed spender, uint256 value);

}

// File: contracts/ERC20StandardToken.sol

pragma solidity 0.5.0;




contract ERC20StandardToken is ERC20Interface, Ownable {


    TokenStore public tokenStore;
    
    event TokenStoreSet(address indexed previousTokenStore, address indexed newTokenStore);
    event ChangeTokenName(string newName, string newSymbol);

    /**
     * @dev ownership of the TokenStore contract
     * @param _newTokenStore The address to of the TokenStore to set.
     */
    function setTokenStore(address _newTokenStore) public onlyOwner returns (bool) {
        emit TokenStoreSet(address(tokenStore), _newTokenStore);
        tokenStore = TokenStore(_newTokenStore);
        return true;
    }
    
    function changeTokenName(string memory _name, string memory _symbol) public onlyOwner {
        tokenStore.changeTokenName(_name, _symbol);
        emit ChangeTokenName(_name, _symbol);
    }

    function totalSupply() public view returns (uint256) {
        return tokenStore.totalSupply();
    }

    function balanceOf(address _holder) public view returns (uint256) {
        return tokenStore.balances(_holder);
    }

    function allowance(address _holder, address _spender) public view returns (uint256) {
        return tokenStore.allowed(_holder, _spender);
    }
    
    function name() public view returns (string memory) {
        return tokenStore.name();
    }
    
    function symbol() public view returns (string memory) {
        return tokenStore.symbol();
    }
    
    function decimals() public view returns (uint8) {
        return tokenStore.decimals();
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
    function approve(
        address _spender,
        uint256 _value
    ) public returns (bool success) {
        require (_spender != address(0), "Cannot approve to the zero address");       
        tokenStore.setAllowance(msg.sender, _spender, _value);
        emit Approval(msg.sender, _spender, _value);
        return true;
    }
    
    /**
     * @dev Increase the amount of tokens that an holder allowed to a spender.
     *
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
    ) public returns (bool success) {
        require (_spender != address(0), "Cannot increaseApproval to the zero address");      
        tokenStore.addAllowance(msg.sender, _spender, _addedValue);
        emit Approval(msg.sender, _spender, tokenStore.allowed(msg.sender, _spender));
        return true;
    }
    
    /**
     * @dev Decrease the amount of tokens that an holder allowed to a spender.
     *
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
    ) public returns (bool success) {
        require (_spender != address(0), "Cannot decreaseApproval to the zero address");       
        tokenStore.subAllowance(msg.sender, _spender, _subtractedValue);
        emit Approval(msg.sender, _spender, tokenStore.allowed(msg.sender, _spender));
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
    ) public returns (bool success) {
        require(_to != address(0), "Cannot transfer to zero address"); 
        tokenStore.subAllowance(_from, msg.sender, _value);          
        tokenStore.subBalance(_from, _value);
        tokenStore.addBalance(_to, _value);
        emit Transfer(_from, _to, _value);
        return true;
    } 

    /**
     * @dev Transfer token for a specified address
     * @param _to The address to transfer to.
     * @param _value The amount to be transferred.
     */
    function transfer(
        address _to, 
        uint256 _value
    ) public returns (bool success) {
        require (_to != address(0), "Cannot transfer to zero address");    
        tokenStore.subBalance(msg.sender, _value);
        tokenStore.addBalance(_to, _value);
        emit Transfer(msg.sender, _to, _value);
        return true;
    }

}

// File: contracts/PausableToken.sol

pragma solidity 0.5.0;



contract PausableToken is ERC20StandardToken {

    address private _pauser;
    bool public paused = false;

    event Pause();
    event Unpause();
    event PauserChanged(address indexed previousPauser, address indexed newPauser);
    
    /**
     * @dev Tells the address of the pauser
     * @return The address of the pauser
     */
    function pauser() public view returns (address) {
        return _pauser;
    }
    
    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     */
    modifier whenNotPaused() {
        require(!paused, "state shouldn't be paused");
        _;
    }

    /**
     * @dev throws if called by any account other than the pauser
     */
    modifier onlyPauser() {
        require(msg.sender == _pauser, "msg.sender should be pauser");
        _;
    }

    /**
     * @dev called by the owner to pause, triggers stopped state
     */
    function pause() public onlyPauser {
        paused = true;
        emit Pause();
    }

    /**
     * @dev called by the owner to unpause, returns to normal state
     */
    function unpause() public onlyPauser {
        paused = false;
        emit Unpause();
    }

    /**
     * @dev update the pauser role
     * @param _newPauser The newPauser to update
     */
    function updatePauser(address _newPauser) public onlyOwner {
        require(_newPauser != address(0), "Cannot update the newPauser to the zero address");
        emit PauserChanged(_pauser, _newPauser);
        _pauser = _newPauser;
    }

    function approve(
        address _spender,
        uint256 _value
    ) public whenNotPaused returns (bool success) {
        return super.approve(_spender, _value);
    }

    function increaseApproval(
        address _spender,
        uint256 _addedValue
    ) public whenNotPaused returns (bool success) {
        return super.increaseApproval(_spender, _addedValue);
    } 

    function decreaseApproval(
        address _spender,
        uint256 _subtractedValue 
    ) public whenNotPaused returns (bool success) {
        return super.decreaseApproval(_spender, _subtractedValue);
    }

    function transferFrom(
        address _from, 
        address _to, 
        uint256 _value
    ) public whenNotPaused returns (bool success) {
        return super.transferFrom(_from, _to, _value);
    } 

    function transfer(
        address _to, 
        uint256 _value
    ) public whenNotPaused returns (bool success) {
        return super.transfer(_to, _value);
    }

}

// File: contracts/BlacklistStore.sol

pragma solidity 0.5.0;


contract BlacklistStore is Operable {

    mapping (address => uint256) public blacklisted;

    /**
     * @dev Checks if account is blacklisted
     * @param _account The address to check
     * @param _status The address status    
     */
    function setBlacklist(address _account, uint256 _status) public onlyOperator {
        blacklisted[_account] = _status;
    }

}

// File: contracts/BlacklistableToken.sol

pragma solidity 0.5.0;



/**
 * @title BlacklistableToken
 * @dev Allows accounts to be blacklisted by a "blacklister" role
 */
contract BlacklistableToken is PausableToken {

    BlacklistStore public blacklistStore;

    address private _blacklister;

    event BlacklisterChanged(address indexed previousBlacklister, address indexed newBlacklister);
    event BlacklistStoreSet(address indexed previousBlacklistStore, address indexed newblacklistStore);
    event Blacklist(address indexed account, uint256 _status);


    /**
     * @dev Throws if argument account is blacklisted
     * @param _account The address to check
     */
    modifier notBlacklisted(address _account) {
        require(blacklistStore.blacklisted(_account) == 0, "Account in the blacklist");
        _;
    }

    /**
     * @dev Throws if called by any account other than the blacklister
     */
    modifier onlyBlacklister() {
        require(msg.sender == _blacklister, "msg.sener should be blacklister");
        _;
    }

    /**
     * @dev Tells the address of the blacklister
     * @return The address of the blacklister
     */
    function blacklister() public view returns (address) {
        return _blacklister;
    }
    
    /**
     * @dev Set the blacklistStore
     * @param _newblacklistStore The blacklistStore address to set
     */
    function setBlacklistStore(address _newblacklistStore) public onlyOwner returns (bool) {
        emit BlacklistStoreSet(address(blacklistStore), _newblacklistStore);
        blacklistStore = BlacklistStore(_newblacklistStore);
        return true;
    }
    
    /**
     * @dev Update the blacklister 
     * @param _newBlacklister The newBlacklister to update
     */
    function updateBlacklister(address _newBlacklister) public onlyOwner {
        require(_newBlacklister != address(0), "Cannot update the blacklister to the zero address");
        emit BlacklisterChanged(_blacklister, _newBlacklister);
        _blacklister = _newBlacklister;
    }

    /**
     * @dev Checks if account is blacklisted
     * @param _account The address status to query
     * @return the address status 
     */
    function queryBlacklist(address _account) public view returns (uint256) {
        return blacklistStore.blacklisted(_account);
    }

    /**
     * @dev Adds account to blacklist
     * @param _account The address to blacklist
     * @param _status The address status to change
     */
    function changeBlacklist(address _account, uint256 _status) public onlyBlacklister {
        blacklistStore.setBlacklist(_account, _status);
        emit Blacklist(_account, _status);
    }

    function approve(
        address _spender,
        uint256 _value
    ) public notBlacklisted(msg.sender) notBlacklisted(_spender) returns (bool success) {
        return super.approve(_spender, _value);
    }
    
    function increaseApproval(
        address _spender,
        uint256 _addedValue
    ) public notBlacklisted(msg.sender) notBlacklisted(_spender) returns (bool success) {
        return super.increaseApproval(_spender, _addedValue);
    } 

    function decreaseApproval(
        address _spender,
        uint256 _subtractedValue 
    ) public notBlacklisted(msg.sender) notBlacklisted(_spender) returns (bool success) {
        return super.decreaseApproval(_spender, _subtractedValue);
    }

    function transferFrom(
        address _from, 
        address _to, 
        uint256 _value
    ) public notBlacklisted(_from) notBlacklisted(_to) notBlacklisted(msg.sender) returns (bool success) {
        return super.transferFrom(_from, _to, _value);
    } 

    function transfer(
        address _to, 
        uint256 _value
    ) public notBlacklisted(msg.sender) notBlacklisted(_to) returns (bool success) {
        return super.transfer(_to, _value);
    }

}

// File: contracts/BurnableToken.sol

pragma solidity 0.5.0;


contract BurnableToken is BlacklistableToken {

    event Burn(address indexed burner, uint256 value);
    
    /**
     * @dev holder can burn some of its own tokens
     * amount is less than or equal to the minter's account balance
     * @param _value uint256 the amount of tokens to be burned
    */
    function burn(
        uint256 _value
    ) public whenNotPaused notBlacklisted(msg.sender) returns (bool success) {   
        tokenStore.subBalance(msg.sender, _value);
        tokenStore.subTotalSupply(_value);
        emit Burn(msg.sender, _value);
        emit Transfer(msg.sender, address(0), _value);
        return true;
    }

}

// File: contracts/MintableToken.sol

pragma solidity 0.5.0;



contract MintableToken is BlacklistableToken {

    event MinterChanged(address indexed previousMinter, address indexed newMinter);
    event Mint(address indexed minter, address indexed to, uint256 value);

    address private _minter;

    modifier onlyMinter() {
        require(msg.sender == _minter, "msg.sender should be minter");
        _;
    }

    /**
     * @dev Tells the address of the blacklister
     * @return The address of the blacklister
     */
    function minter() public view returns (address) {
        return _minter;
    }
 
    /**
     * @dev update the minter
     * @param _newMinter The newMinter to update
     */
    function updateMinter(address _newMinter) public onlyOwner {
        require(_newMinter != address(0), "Cannot update the newPauser to the zero address");
        emit MinterChanged(_minter, _newMinter);
        _minter = _newMinter;
    }

    /**
     * @dev Function to mint tokens
     * @param _to The address that will receive the minted tokens.
     * @param _value The amount of tokens to mint. Must be less than or equal to the minterAllowance of the caller.
     * @return A boolean that indicates if the operation was successful.
     */
    function mint(
        address _to, 
        uint256 _value
    ) public onlyMinter whenNotPaused notBlacklisted(msg.sender) notBlacklisted(_to) returns (bool) {
        require(_to != address(0), "Cannot mint to zero address");
        tokenStore.addTotalSupply(_value);
        tokenStore.addBalance(_to, _value);  
        emit Mint(msg.sender, _to, _value);
        emit Transfer(address(0), _to, _value);
        return true;
    }

}

// File: contracts/PingAnToken.sol

pragma solidity 0.5.0;




contract PingAnToken is BurnableToken, MintableToken {


    /**
     * contract only can initialized once 
     */
    bool private initialized = true;

    /**
     * @dev sets 0 initials tokens, the owner.
     * this serves as the constructor for the proxy but compiles to the
     * memory model of the Implementation contract.
     * @param _owner The owner to initials
     */
    function initialize(address _owner) public {
        require(!initialized, "already initialized");
        require(_owner != address(0), "Cannot initialize the owner to zero address");
        setOwner(_owner);
        initialized = true;
    }

}