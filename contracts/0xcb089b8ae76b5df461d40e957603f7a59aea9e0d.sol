pragma solidity 0.5.0;

/**
 * @title SafeMath
 * @dev Math operations with safety checks that revert on error
 */
library SafeMath {
    /**
    * @dev Multiplies two numbers, reverts on overflow.
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
    * @dev Integer division of two numbers truncating the quotient, reverts on division by zero.
    */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
    * @dev Subtracts two numbers, reverts on overflow (i.e. if subtrahend is greater than minuend).
    */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a);
        uint256 c = a - b;

        return c;
    }

    /**
    * @dev Adds two numbers, reverts on overflow.
    */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a);

        return c;
    }

    /**
    * @dev Divides two numbers and returns the remainder (unsigned integer modulo),
    * reverts when dividing by zero.
    */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0);
        return a % b;
    }
}

/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address who) external view returns (uint256);

    function allowance(address owner, address spender) external view returns (uint256);

    function transfer(address to, uint256 value) external returns (bool);

    function approve(address spender, uint256 value) external returns (bool);

    function transferFrom(address from, address to, uint256 value) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}

/**
 * @title Standard ERC20 token
 *
 * @dev Implementation of the basic standard token.
 * https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20.md
 * Originally based on code by FirstBlood: https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol
 */
contract ERC20 is IERC20 {
    using SafeMath for uint256;

    mapping (address => uint256) internal _balances;

    mapping (address => mapping (address => uint256)) private _allowed;

    uint256 internal _totalSupply;

    /**
    * @dev Total number of tokens in existence
    */
    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    /**
    * @dev Gets the balance of the specified address.
    * @param owner The address to query the balance of.
    * @return An uint256 representing the amount owned by the passed address.
    */
    function balanceOf(address owner) public view returns (uint256) {
        return _balances[owner];
    }

    /**
     * @dev Function to check the amount of tokens that an owner allowed to a spender.
     * @param owner address The address which owns the funds.
     * @param spender address The address which will spend the funds.
     * @return A uint256 specifying the amount of tokens still available for the spender.
     */
    function allowance(address owner, address spender) public view returns (uint256) {
        return _allowed[owner][spender];
    }

    /**
    * @dev Transfer token for a specified address
    * @param to The address to transfer to.
    * @param value The amount to be transferred.
    */
    function transfer(address to, uint256 value) public returns (bool) {
        _transfer(msg.sender, to, value);
        return true;
    }

    /**
     * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.
     * Beware that changing an allowance with this method brings the risk that someone may use both the old
     * and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this
     * race condition is to first reduce the spender's allowance to 0 and set the desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     * @param spender The address which will spend the funds.
     * @param value The amount of tokens to be spent.
     */
    function approve(address spender, uint256 value) public returns (bool) {
        require(spender != address(0));

        _allowed[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }

    /**
     * @dev Transfer tokens from one address to another
     * @param from address The address which you want to send tokens from
     * @param to address The address which you want to transfer to
     * @param value uint256 the amount of tokens to be transferred
     */
    function transferFrom(address from, address to, uint256 value) public returns (bool) {
        _allowed[from][msg.sender] = _allowed[from][msg.sender].sub(value);
        _transfer(from, to, value);
        return true;
    }

    /**
     * @dev Increase the amount of tokens that an owner allowed to a spender.
     * approve should be called when allowed_[_spender] == 0. To increment
     * allowed value is better to use this function to avoid 2 calls (and wait until
     * the first transaction is mined)
     * From MonolithDAO Token.sol
     * @param spender The address which will spend the funds.
     * @param addedValue The amount of tokens to increase the allowance by.
     */
    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        require(spender != address(0));

        _allowed[msg.sender][spender] = _allowed[msg.sender][spender].add(addedValue);
        emit Approval(msg.sender, spender, _allowed[msg.sender][spender]);
        return true;
    }

    /**
     * @dev Decrease the amount of tokens that an owner allowed to a spender.
     * approve should be called when allowed_[_spender] == 0. To decrement
     * allowed value is better to use this function to avoid 2 calls (and wait until
     * the first transaction is mined)
     * From MonolithDAO Token.sol
     * @param spender The address which will spend the funds.
     * @param subtractedValue The amount of tokens to decrease the allowance by.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        require(spender != address(0));

        _allowed[msg.sender][spender] = _allowed[msg.sender][spender].sub(subtractedValue);
        emit Approval(msg.sender, spender, _allowed[msg.sender][spender]);
        return true;
    }

    /**
    * @dev Transfer token for a specified addresses
    * @param from The address to transfer from.
    * @param to The address to transfer to.
    * @param value The amount to be transferred.
    */
    function _transfer(address from, address to, uint256 value) internal {
        require(to != address(0));

        _balances[from] = _balances[from].sub(value);
        _balances[to] = _balances[to].add(value);
        emit Transfer(from, to, value);
    }

}


/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
    address public owner;


    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


    /**
    * @dev The Ownable constructor sets the original `owner` of the contract to the sender
    * account.
    */
    constructor() public {
        owner = msg.sender;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(msg.sender == owner);
    _;
    }

}

contract Claimable is Ownable {
    address public pendingOwner;

    /**
     * @dev Modifier throws if called by any account other than the pendingOwner.
     */
    modifier onlyPendingOwner() {
        require(msg.sender == pendingOwner);
        _;
    }

    /**
     * @dev Allows the current owner to set the pendingOwner address.
     * @param newOwner The address to transfer ownership to.
     */
    function transferOwnership(address newOwner) onlyOwner public {
        pendingOwner = newOwner;
    }

    /**
     * @dev Allows the pendingOwner address to finalize the transfer.
     */
    function claimOwnership() onlyPendingOwner public {
        emit OwnershipTransferred(owner, pendingOwner);
        owner = pendingOwner;
        pendingOwner = address(0);
    }
}

/**
 * @title Arroundtoken
 * @dev The Arroundtoken contract is ERC20-compatible token processing contract
 * with additional  features like multiTransfer and reclaimTokens
 *
 */
contract Arroundtoken is ERC20, Claimable {
    using SafeMath for uint256;

    uint64 public constant TDE_FINISH = 1542326400;//!!!!Check before deploy
    // 1542326400  GMT: 16 November 2018 г., 00:00:00
    // 1542326399  GMT: 15 November 2018 г., 23:59:59


    //////////////////////
    // State var       ///
    //////////////////////
    string  public name;
    string  public symbol;
    uint8   public decimals;
    address public accTDE;
    address public accFoundCDF;
    address public accFoundNDF1;
    address public accFoundNDF2;
    address public accFoundNDF3;
    address public accTeam;
    address public accBounty;
  
    // Implementation of frozen funds
    mapping(address => uint64) public frozenAccounts;

    //////////////
    // EVENTS    //
    ///////////////
    event NewFreeze(address _acc, uint64 _timestamp);
    event BatchDistrib(uint8 cnt, uint256 batchAmount);
    
    /**
     * @param _accTDE - main address for token distribution
     * @param _accFoundCDF  - address for CDF Found tokens (WP)
     * @param _accFoundNDF1 - address for NDF Found tokens (WP)
     * @param _accFoundNDF2 - address for NDF Found tokens (WP)
     * @param _accFoundNDF3 - address for NDF Found tokens (WP)
     * @param _accTeam - address for team tokens, will frozzen by one year
     * @param _accBounty - address for bounty tokens 
     * @param _initialSupply - subj
     */  
    constructor (
        address _accTDE, 
        address _accFoundCDF,
        address _accFoundNDF1,
        address _accFoundNDF2,
        address _accFoundNDF3,
        address _accTeam,
        address _accBounty, 
        uint256 _initialSupply
    )
    public 
    {
        require(_accTDE       != address(0));
        require(_accFoundCDF  != address(0));
        require(_accFoundNDF1 != address(0));
        require(_accFoundNDF2 != address(0));
        require(_accFoundNDF3 != address(0));
        require(_accTeam      != address(0));
        require(_accBounty    != address(0));
        require(_initialSupply > 0);
        name           = "Arround";
        symbol         = "ARR";
        decimals       = 18;
        accTDE         = _accTDE;
        accFoundCDF    = _accFoundCDF;
        accFoundNDF1   = _accFoundNDF1;
        accFoundNDF2   = _accFoundNDF2;
        accFoundNDF3   = _accFoundNDF3;
        
        accTeam        = _accTeam;
        accBounty      = _accBounty;
        _totalSupply   = _initialSupply * (10 ** uint256(decimals));// All ARR tokens in the world
        
       //Initial token distribution
        _balances[_accTDE]       = 1104000000 * (10 ** uint256(decimals)); // TDE,      36.8%=28.6+8.2 
        _balances[_accFoundCDF]  = 1251000000 * (10 ** uint256(decimals)); // CDF,      41.7%
        _balances[_accFoundNDF1] =  150000000 * (10 ** uint256(decimals)); // 0.50*NDF, 10.0%
        _balances[_accFoundNDF2] =  105000000 * (10 ** uint256(decimals)); // 0.35*NDF, 10.0%
        _balances[_accFoundNDF3] =   45000000 * (10 ** uint256(decimals)); // 0.15*NDF, 10.0%
        _balances[_accTeam]      =  300000000 * (10 ** uint256(decimals)); // team,     10.0%
        _balances[_accBounty]    =   45000000 * (10 ** uint256(decimals)); // Bounty,    1.5%
        require(  _totalSupply ==  3000000000 * (10 ** uint256(decimals)), "Total Supply exceeded!!!");
        emit Transfer(address(0), _accTDE,       1104000000 * (10 ** uint256(decimals)));
        emit Transfer(address(0), _accFoundCDF,  1251000000 * (10 ** uint256(decimals)));
        emit Transfer(address(0), _accFoundNDF1,  150000000 * (10 ** uint256(decimals)));
        emit Transfer(address(0), _accFoundNDF2,  105000000 * (10 ** uint256(decimals)));
        emit Transfer(address(0), _accFoundNDF3,   45000000 * (10 ** uint256(decimals)));
        emit Transfer(address(0), _accTeam,       300000000 * (10 ** uint256(decimals)));
        emit Transfer(address(0), _accBounty,      45000000 * (10 ** uint256(decimals)));
        //initisl freeze
        frozenAccounts[_accTeam]      = TDE_FINISH + 31536000; //+3600*24*365 sec
        frozenAccounts[_accFoundNDF2] = TDE_FINISH + 31536000; //+3600*24*365 sec
        frozenAccounts[_accFoundNDF3] = TDE_FINISH + 63158400; //+(3600*24*365)*2 +3600*24(leap year 2020)
        emit NewFreeze(_accTeam,        TDE_FINISH + 31536000);
        emit NewFreeze(_accFoundNDF2,   TDE_FINISH + 31536000);
        emit NewFreeze(_accFoundNDF3,   TDE_FINISH + 63158400);

    }
    
    modifier onlyTokenKeeper() {
        require(
            msg.sender == accTDE || 
            msg.sender == accFoundCDF ||
            msg.sender == accFoundNDF1 ||
            msg.sender == accBounty
        );
        _;
    }

    function() external { } 

    /**
     * @dev Returns standart ERC20 result with frozen accounts check
     */
    function transfer(address _to, uint256 _value) public  returns (bool) {
        require(frozenAccounts[msg.sender] < now);
        return super.transfer(_to, _value);
    }

    /**
     * @dev Returns standart ERC20 result with frozen accounts check
     */
    function transferFrom(address _from, address _to, uint256 _value) public  returns (bool) {
        require(frozenAccounts[_from] < now);
        return super.transferFrom(_from, _to, _value);
    }

    /**
     * @dev Returns standart ERC20 result with frozen accounts check
     */
    function approve(address _spender, uint256 _value) public  returns (bool) {
        require(frozenAccounts[msg.sender] < now);
        return super.approve(_spender, _value);
    }

    /**
     * @dev Returns standart ERC20 result with frozen accounts check
     */
    function increaseAllowance(address _spender, uint _addedValue) public  returns (bool success) {
        require(frozenAccounts[msg.sender] < now);
        return super.increaseAllowance(_spender, _addedValue);
    }
    
    /**
     * @dev Returns standart ERC20 result with frozen accounts check
     */
    function decreaseAllowance(address _spender, uint _subtractedValue) public  returns (bool success) {
        require(frozenAccounts[msg.sender] < now);
        return super.decreaseAllowance(_spender, _subtractedValue);
    }

    
    /**
     * @dev Batch transfer function. Allow to save up 50% of gas
     */
    function multiTransfer(address[] calldata  _investors, uint256[] calldata   _value )  
        external 
        onlyTokenKeeper 
        returns (uint256 _batchAmount)
    {
        require(_investors.length <= 255); //audit recommendation
        require(_value.length == _investors.length);
        uint8      cnt = uint8(_investors.length);
        uint256 amount = 0;
        for (uint i=0; i<cnt; i++){
            amount = amount.add(_value[i]);
            require(_investors[i] != address(0));
            _balances[_investors[i]] = _balances[_investors[i]].add(_value[i]);
            emit Transfer(msg.sender, _investors[i], _value[i]);
        }
        require(amount <= _balances[msg.sender]);
        _balances[msg.sender] = _balances[msg.sender].sub(amount);
        emit BatchDistrib(cnt, amount);
        return amount;
    }
  
    /**
     * @dev Owner can claim any tokens that transfered to this contract address
     */
    function reclaimToken(ERC20 token) external onlyOwner {
        require(address(token) != address(0));
        uint256 balance = token.balanceOf(address(this));
        token.transfer(owner, balance);
    }
}
  //***************************************************************
  // Based on best practice of https://github.com/Open Zeppelin/zeppelin-solidity
  // Adapted and amended by IBERGroup; 
  // Code released under the MIT License(see git root).
  ////**************************************************************