pragma solidity ^0.5.0;

/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */

interface IERC20 {

    function transfer(address to, uint256 value) external returns (bool);

    function approve(address spender, uint256 value) external returns (bool);

    function transferFrom(address from, address to, uint256 value) external returns (bool);

    function totalSupply() external view returns (uint256);

    function balanceOf(address who) external view returns (uint256);

    function allowance(address owner, address spender) external view returns (uint256);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);

}

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

/**
 * @title Standard ERC20 token
 *
 * @dev Implementation of the basic standard token.
 * https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20.md
 * Originally based on code by FirstBlood:
 * https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol
 *
 * This implementation emits additional Approval events, allowing applications to reconstruct the allowance status for
 * all accounts just by listening to said events. Note that this isn't required by the specification, and other
 * compliant implementations may not do it.
 */

contract ERC20 is IERC20 {

    using SafeMath for uint256;

    mapping (address => uint256) internal _balances;

    mapping (address => mapping (address => uint256)) internal _allowed;

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
     * @dev Transfer tokens from one address to another.
     * Note that while this function emits an Approval event, this is not required as per the specification,
     * and other compliant implementations may not emit the event.
     * @param from address The address which you want to send tokens from
     * @param to address The address which you want to transfer to
     * @param value uint256 the amount of tokens to be transferred
     */
    function transferFrom(address from, address to, uint256 value) public returns (bool) {
        _allowed[from][msg.sender] = _allowed[from][msg.sender].sub(value);
        _transfer(from, to, value);
        emit Approval(from, msg.sender, _allowed[from][msg.sender]);
        return true;
    }

    /**
     * @dev Increase the amount of tokens that an owner allowed to a spender.
     * approve should be called when allowed_[_spender] == 0. To increment
     * allowed value is better to use this function to avoid 2 calls (and wait until
     * the first transaction is mined)
     * From MonolithDAO Token.sol
     * Emits an Approval event.
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
     * Emits an Approval event.
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

    /**
     * @dev Internal function that mints an amount of the token and assigns it to
     * an account. This encapsulates the modification of balances such that the
     * proper events are emitted.
     * @param account The account that will receive the created tokens.
     * @param value The amount that will be created.
     */
    function _mint(address account, uint256 value) internal {
        require(account != address(0));

        _totalSupply = _totalSupply.add(value);
        _balances[account] = _balances[account].add(value);
        emit Transfer(address(0), account, value);
    }

    /**
     * @dev Internal function that burns an amount of the token of a given
     * account.
     * @param account The account whose tokens will be burnt.
     * @param value The amount that will be burnt.
     */
    function _burn(address account, uint256 value) internal {
        require(account != address(0));

        _totalSupply = _totalSupply.sub(value);
        _balances[account] = _balances[account].sub(value);
        emit Transfer(account, address(0), value);
    }

    /**
     * @dev Internal function that burns an amount of the token of a given
     * account, deducting from the sender's allowance for said account. Uses the
     * internal burn function.
     * Emits an Approval event (reflecting the reduced allowance).
     * @param account The account whose tokens will be burnt.
     * @param value The amount that will be burnt.
     */
    function _burnFrom(address account, uint256 value) internal {
        _allowed[account][msg.sender] = _allowed[account][msg.sender].sub(value);
        _burn(account, value);
        emit Approval(account, msg.sender, _allowed[account][msg.sender]);
    }
}

/**
 * @title ERC20Detailed token
 * @dev The decimals are only for visualization purposes.
 * All the operations are done using the smallest and indivisible token unit,
 * just as on Ethereum all the operations are done in wei.
 */
 
contract ERC20Detailed is  ERC20 {
    string private _name;
    string private _symbol;
    uint8 internal _decimals;

    constructor (string memory name, string memory symbol, uint8 decimals) public {
        _name = name;
        _symbol = symbol;
        _decimals = decimals;
    }

    /**
     * @return the name of the token.
     */
    function name() public view returns (string memory) {
        return _name;
    }

    /**
     * @return the symbol of the token.
     */
    function symbol() public view returns (string memory) {
        return _symbol;
    }

    /**
     * @return the number of decimals of the token.
     */
    function decimals() public view returns (uint8) {
        return _decimals;
    }
}

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
 
contract Ownable {
    
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev The Ownable constructor sets the original `owner` of the contract to the sender
     * account.
     */
    constructor () internal {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
    }

    /**
     * @return the address of the owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(isOwner());
        _;
    }

    /**
     * @return true if `msg.sender` is the owner of the contract.
     */
    function isOwner() public view returns (bool) {
        return msg.sender == _owner;
    }

    /**
     * @dev Allows the current owner to relinquish control of the contract.
     * @notice Renouncing to ownership will leave the contract without an owner.
     * It will not be possible to call the functions with the `onlyOwner`
     * modifier anymore.
     */
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Allows the current owner to transfer control of the contract to a newOwner.
     * @param newOwner The address to transfer ownership to.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers control of the contract to a newOwner.
     * @param newOwner The address to transfer ownership to.
     */
    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0));
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}


contract Remote is Ownable, IERC20 {
    
    IERC20 internal _remoteToken;
    address internal _remoteContractAddress;

    /**
    @dev approveSpenderOnVault
    This is only needed if you put the funds in the Vault contract address, and then need to withdraw them
    Avoid this, by not putting funds in there that you need to get back.
    @param spender The address that will be used to withdraw from the Vault.
    @param value The amount of tokens to approve.
    @return success
     */
    function approveSpenderOnVault (address spender, uint256 value) 
        external onlyOwner returns (bool success) {
            // NOTE Approve the spender on the Vault address
            _remoteToken.approve(spender, value);     
            success = true;
        }

   /** 
    @dev remoteTransferFrom This allows the admin to withdraw tokens from the contract, using an 
    allowance that has been previously set. 
    @param from address to take the tokens from (allowance)
    @param to the recipient to give the tokens to
    @param value the amount in tokens to send
    @return bool
    */
    function remoteTransferFrom (address from, address to, uint256 value) external onlyOwner returns (bool) {
        return _remoteTransferFrom(from, to, value);
    }

    /**
    @dev setRemoteContractAddress
    @param remoteContractAddress The remote contract's address
    @return success
     */
    function setRemoteContractAddress (address remoteContractAddress)
        external onlyOwner returns (bool success) {
            _remoteContractAddress = remoteContractAddress;        
            _remoteToken = IERC20(_remoteContractAddress);
            success = true;
        }

    function remoteBalanceOf(address owner) external view returns (uint256) {
        return _remoteToken.balanceOf(owner);
    }

    function remoteTotalSupply() external view returns (uint256) {
        return _remoteToken.totalSupply();
    }

    /** */
    function remoteAllowance (address owner, address spender) external view returns (uint256) {
        return _remoteToken.allowance(owner, spender);
    }

    /**
    @dev remoteBalanceOfVault Return tokens from the balance of the Vault contract.
    This should be zero. Tokens should come from allowance, not balanceOf.
    @return balance
     */
    function remoteBalanceOfVault () external view onlyOwner 
        returns(uint256 balance) {
            balance = _remoteToken.balanceOf(address(this));
        }

    /**
    @dev remoteAllowanceOnMyAddress Check contracts allowance on the users address.
    @return allowance
     */
    function remoteAllowanceOnMyAddress () public view
        returns(uint256 allowance) {
            allowance = _remoteToken.allowance(msg.sender, address(this));
        } 

    /** 
    @dev _remoteTransferFrom This allows contract to withdraw tokens from an address, using an 
    allowance that has been previously set. 
    @param from address to take the tokens from (allowance)
    @param to the recipient to give the tokens to
    @param value the amount in tokens to send
    @return bool
    */
    function _remoteTransferFrom (address from, address to, uint256 value) internal returns (bool) {
        return _remoteToken.transferFrom(from, to, value);
    }

}


contract ProofOfTrident is ERC20Detailed, Remote {
    
    event SentToStake(address from, address to, uint256 value);  

    // max total supply set.
    uint256 private _maxTotalSupply = 100000000000 * 10**uint(18);
    
    // minimum number of tokens that can be staked
    uint256 internal _stakeMinimum = 100000000 * 10**uint(18); 
    // maximum number of tokens that can be staked
    uint256 internal _stakeMaximum = 500000000 * 10**uint(18); 
    
    uint internal _oneDay = 60 * 60 * 24;    
    uint internal _sixMonths = _oneDay * 182;   
    uint internal _oneYear = _oneDay * 365; 
    uint internal _stakeMinimumTimestamp = 1000; // minimum age for coin age: 1000 seconds

    // Stop the maximum stake at this to encourage users to collect regularly. 
    uint internal _stakeMaximumTimestamp = _oneYear + _sixMonths;
    uint256 internal _percentageLower = 2;
    uint256 internal _percentageMiddle = 7;
    uint256 internal _percentageUpper = 13;
    //uint256 internal _percentageOfTokensReturned = 10;
    // These funds will go into a variable, but will be stored at the original owner address
    uint256 private _treasuryPercentageOfReward = 50;    
  
    address internal _treasury;

    /**
     @dev cancelTrident
     @return success
     */
    function cancelTrident() external returns (bool) {
        // Don't check the real balance as the user is allowed to add the whole amount to stake.
        uint256 _amountInVault = _transferIns[msg.sender].amountInVault;
        // Check that there is at least an amount set to stake.
        require(_amountInVault > 0, "You have not staked any tokens.");
        
        // reset values before moving on
        _transferIns[msg.sender].amountInVault = 0;
        _transferIns[msg.sender].tokenTimestamp = block.timestamp;

        // NOTE  Convert to transferFrom Vault
        // DONE The contract needs a allowance on itself for every token
        _remoteTransferFrom(address(this), msg.sender, _amountInVault);

        return true;
    }

    /**
     @dev collectRewards
     @return success
     */
    function collectRewards() external returns (bool) {
        // Don't check the real balance as the user is allowed to add the whole amount to stake.
        uint256 _amountInVault = _transferIns[msg.sender].amountInVault;
        // Check that there is at least an amount set to stake.
        require(_amountInVault > 0, "You have not staked any tokens.");
        
        // If the stake age is less than minimum, reject the attempt.
        require(_holdAgeTimestamp(msg.sender) >= _transferIns[msg.sender].stakeMinimumTimestamp,
        "You need to stake for the minimum time of 1000 seconds.");

        uint256 rewardForUser = tridentReward(msg.sender);
        require(rewardForUser > 0, "Your reward is currently zero. Nothing to collect.");

        // reset values before moving on
        _transferIns[msg.sender].amountInVault = 0;
        _transferIns[msg.sender].tokenTimestamp = block.timestamp;
        _transferIns[msg.sender].percentageLower = 0;
        _transferIns[msg.sender].percentageMiddle = 0;
        _transferIns[msg.sender].percentageUpper = 0;
        _transferIns[msg.sender].stakeMinimumTimestamp = _oneDay;
        _transferIns[msg.sender].stakeMaximumTimestamp = _oneYear + _sixMonths;
        // return their stake
        // DONE the contract needs and allowance inself for all the inputs, make this on 
        // first set up
        _remoteTransferFrom(address(this), msg.sender, _amountInVault);

        // calculate the amount for the treasury
        uint256 _amountForTreasury = rewardForUser.mul(_treasuryPercentageOfReward).div(100);

        // apply the rewards to the owner address to save on gas later
        _mint(_treasury, _amountForTreasury);

        // calculate the amount for the user
        _mint(msg.sender, rewardForUser);
        return true;
    }

    function setTreasuryAddress (address treasury) external onlyOwner {
        _treasury = treasury;
    }

    struct TransferInStake {
        uint256 amountInVault;
        uint256 tokenTimestamp;
        uint256 percentageLower;
        uint256 percentageMiddle;
        uint256 percentageUpper;
        uint stakeMinimumTimestamp;
        uint stakeMaximumTimestamp;
    }

    mapping(address => TransferInStake) internal _transferIns;

    modifier canPoSMint() {
        // This will allow the supply to go slightly over the max total supply (once the last rewards are applied).
        // Users can collect rewards (and stake) after the closure period. 
        // In theory somone could hold for a long time and then receive a very large reward.
        require(_totalSupply < _maxTotalSupply,
        "This operation would take the total supply over the maximum supply.");
        _;
    }

    /**
    @dev setTridentDetails

    @param stakeMinimumTimestamp The timestamp as the minimum amount of staking 
    @param stakeMaximumTimestamp The timestamp as the maximum amount of staking 
    @param stakeMinimumInTokens The minimum amount of tokens to stake
    @param stakeMaximumInTokens The the maximum amount of tokens to stake 
    @param percentageTreasury The percentage of the reward that the treasury take 
    @param percentageLower The lower annual interest rate to pay out to users 
    @param percentageMiddle The middel annual interest rate to pay out to users 
    @param percentageUpper The upper annual interest rate to pay out to users 
    @param maxTotalSupply The maximum supply that can be minted 
    @return success
    */
    function setTridentDetails(
        uint256 stakeMinimumTimestamp,
        uint256 stakeMaximumTimestamp,
        uint256 stakeMinimumInTokens,
        uint256 stakeMaximumInTokens,
        uint256 percentageTreasury,
        uint256 percentageLower,
        uint256 percentageMiddle,
        uint256 percentageUpper,
        uint256 maxTotalSupply) 
        external onlyOwner returns (bool success) {
            _stakeMinimum = stakeMinimumInTokens * 10**uint(18);
            _stakeMaximum = stakeMaximumInTokens * 10**uint(18);
            _stakeMinimumTimestamp = stakeMinimumTimestamp;
            _stakeMaximumTimestamp = stakeMaximumTimestamp;
            _percentageLower = percentageLower;  
            _percentageMiddle = percentageMiddle;  
            _percentageUpper = percentageUpper; 
            _treasuryPercentageOfReward = percentageTreasury;
            _maxTotalSupply = maxTotalSupply * 10**uint(18);
            success = true;
        }

    function canAddToVault() external view canPoSMint returns(bool) {
        return true;
    }

    function treasuryAddress () external view onlyOwner returns (address treasury) {
        treasury = _treasury;
    }

    /**
    @dev tridentDetails
    @return stakeMinimum The token count minimum
    @return stakeMaximum The token count minimum
    @return interest The average interest earned per year
    @return treasuryPercentage The percentage (extra) given to treasury per reward
    @return maxTotalSupply The maximum supply cap
    */
    function tridentDetails ()
    external view returns
    (
    uint stakeMinimumTimestamp,
    uint stakeMaximumTimestamp,
    uint256 percentageLower,
    uint256 percentageMiddle,
    uint256 percentageUpper,
    uint256 treasuryPercentage,
    uint256 stakeMinimum,
    uint256 stakeMaximum,
    uint256 maxTotalSupply) {
        stakeMinimumTimestamp = _stakeMinimumTimestamp;
        stakeMaximumTimestamp = _stakeMaximumTimestamp;
        percentageLower = _percentageLower;
        percentageMiddle = _percentageMiddle;
        percentageUpper = _percentageUpper;
        treasuryPercentage = _treasuryPercentageOfReward; 
        stakeMinimum = _stakeMinimum;
        stakeMaximum = _stakeMaximum;     
        maxTotalSupply = _maxTotalSupply;
    }
    
    function percentageLower () external view returns (uint256) {
        return _percentageLower;
    }

    function percentageMiddle () external view returns (uint256) {
        return _percentageMiddle;
    }

    function percentageUpper () external view returns (uint256) {
        return _percentageUpper;
    }

    function stakeMinimum () external view returns (uint256) {
        return _stakeMinimum;
    }

    function stakeMaximum () external view returns (uint256) {
        return _stakeMaximum;
    }

    function myHoldAgeTimestamp() external view returns (uint256) {
        return _holdAgeTimestamp(msg.sender);
    }

    function myAmountInVault() external view returns (uint256) {
        return _transferIns[msg.sender].amountInVault;
    }

    function myPercentageLower() external view returns (uint256) {
        return _transferIns[msg.sender].percentageLower;
    }

    function myPercentageMiddle() external view returns (uint256) {
        return _transferIns[msg.sender].percentageMiddle;
    }

    function myPercentageUpper() external view returns (uint256) {
        return _transferIns[msg.sender].percentageUpper;
    }

    function myStakeMinimumTimestamp() external view returns (uint) {
        return _transferIns[msg.sender].stakeMinimumTimestamp;
    }

    function myStakeMaximumTimestamp() external view returns (uint) {
        return _transferIns[msg.sender].stakeMaximumTimestamp;
    }

    /**
     @dev tridentReward: Returns value of the reward. Does not allocate reward.
    @param owner The owner address
     @return totalReward
     */
    function tridentReward(address owner) public view returns (uint256 totalReward) {
        require(_transferIns[owner].amountInVault > 0, "You have not sent any tokens into stake.");
        
        uint256 _amountInStake =  _transferIns[owner].amountInVault;//Take from struct
  
        uint _lengthOfHoldInSeconds = _holdAgeTimestamp(owner);//Take from method

        if (_lengthOfHoldInSeconds > (_transferIns[owner].stakeMaximumTimestamp)) {
            _lengthOfHoldInSeconds = _transferIns[owner].stakeMaximumTimestamp;
        }

        uint percentage = _transferIns[owner].percentageLower;

        // NOTE  if user holds for long time
        if (_lengthOfHoldInSeconds >= (_sixMonths)) {
            percentage = _transferIns[owner].percentageMiddle;
        }
        if (_lengthOfHoldInSeconds >= (_oneYear)) {
            percentage = _transferIns[owner].percentageUpper;
        }

        uint256 reward = 
        _amountInStake.
        mul(percentage)
        .mul(_lengthOfHoldInSeconds)
        .div(_stakeMaximumTimestamp)
        .div(100);

        totalReward = reward;

    }

    /**
     @dev _holdAgeTimestamp
     @param owner The owner address
     @return holdAgeTimestamp The stake age in seconds
     */
    function _holdAgeTimestamp(address owner) internal view returns (uint256 holdAgeTimestamp) {
        
        require(_transferIns[owner].amountInVault > 0,
        "You haven't sent any tokens to stake, so there is no stake age to return.");
        
        uint256 _lengthOfHoldTimestamp = (block.timestamp - _transferIns[owner].tokenTimestamp);
        
        holdAgeTimestamp = _lengthOfHoldTimestamp;
    }   
}

/**
 * @title Burnable Token
 * @dev Token that can be irreversibly burned (destroyed).
 */
 
contract ERC20Burnable is ERC20 {
    
    /**
     * @dev Burns a specific amount of tokens.
     * @param value The amount of token to be burned.
     */
    function burn(uint256 value) public {
        _burn(msg.sender, value);
    }

    /**
     * @dev Burns a specific amount of tokens from the target address and decrements allowance
     * @param from address The address which you want to send tokens from
     * @param value uint256 The amount of token to be burned
     */
    function burnFrom(address from, uint256 value) public {
        _burnFrom(from, value);
    }
}

/**
 * @title Vault
 * @dev Very simple ERC20 Token example, where all tokens are pre-assigned to the creator.
 * Note they can later distribute these tokens as they wish using `transfer` and other
 * `ERC20` functions.
 */

contract Vault is ProofOfTrident, ERC20Burnable {

    uint8 private constant DECIMALS = 18;
    uint256 private constant INITIAL_SUPPLY = 0;
    address private _vaultAddress = address(this);
    
    /**
     * @dev Constructor that gives msg.sender all of existing tokens, 0.
     */
    constructor (string memory name, string memory symbol, address remoteContractAddress, address treasury)
        public ERC20Detailed(name, symbol, DECIMALS) {

            _remoteContractAddress = remoteContractAddress;
            _remoteToken = IERC20(_remoteContractAddress);
            _decimals = DECIMALS;
            _treasury = treasury;
            //_percentageOfTokensReturned = percentageOfTokensReturned;
            
            _mint(msg.sender, INITIAL_SUPPLY);
        }

    function() external payable {
        // If Ether is sent to this address, send it back.
        // The contracts must be used, not the fallback
        revert();
    }
 
    /**
     * @dev adminDoDestructContract
     */ 
    function adminDoDestructContract() external onlyOwner { 
        if (msg.sender == owner()) selfdestruct(msg.sender);
    }

    /** 
    @dev vaultRequestFromUser This allows the contract to transferFrom the user to 
    themselves using allowance that has been previously set. 
    @return string Message
    */
    function vaultRequestFromUser () external canPoSMint returns (string memory message) {
     
        // calculate remote allowance given to the contract on the senders address
        // completed via the wallet
        uint256 amountAllowed = _remoteToken.allowance(msg.sender, _vaultAddress);
        require(amountAllowed > 0, "No allowance has been set.");        
        require(amountAllowed <= _stakeMaximum, "The allowance has been set too high.");
        uint256 amountBalance = _remoteToken.balanceOf(msg.sender);
        require(amountBalance >= amountAllowed);
        
        require(_transferIns[msg.sender].amountInVault == 0,
        "You are already staking. Cancel your stake (sacrificing reward), or collect your reward and send again.");
        
        require(amountBalance >= amountAllowed,
        "The sending account balance is lower than the requested value.");
        require(amountAllowed >= _stakeMinimum,
        "There is a minimum stake amount set.");
        uint256 vaultBalance = _remoteToken.balanceOf(_vaultAddress);
        _remoteTransferFrom(msg.sender, _vaultAddress, amountAllowed);

        _transferIns[msg.sender].amountInVault = amountAllowed;
        _transferIns[msg.sender].tokenTimestamp = block.timestamp;
        _transferIns[msg.sender].percentageLower = _percentageLower;
        _transferIns[msg.sender].percentageMiddle = _percentageMiddle;
        _transferIns[msg.sender].percentageUpper = _percentageUpper;

        _transferIns[msg.sender].stakeMinimumTimestamp = _stakeMinimumTimestamp;
        _transferIns[msg.sender].stakeMaximumTimestamp = _stakeMaximumTimestamp;

        _remoteToken.approve(_vaultAddress, vaultBalance.add(amountAllowed));  
 
        return "Vault deposit complete, thank you.";
    }

    /**
    * @dev vaultDetails
    * @return address vaultAddress, 
    * @return address remoteContractAddress,
    * @return uint decimals
     */ 
    function vaultDetails() external view returns (
        address vaultAddress,  
        address remoteContractAddress, 
        uint decimals) {
        vaultAddress = _vaultAddress;
        remoteContractAddress = _remoteContractAddress;      
        decimals = _decimals;
    }

    /**
    @dev myBalance Return tokens from a balance
    @return balance
     */
    function myBalance () external view returns(uint256 balance) {
        balance = _balances[msg.sender];
    }

    /**
    @dev myAddress Return address from a sender. 
    Useful for setting allowances
    @return myAddress
     */
    function myAddress () external view returns(address myadddress) {
        myadddress = msg.sender;
    }

    /**
    @dev vaultBalance Return number of tokens helds by the contract.
    @return balance
     */
    function vaultBalance () external view onlyOwner returns(uint balance) {
        balance = _balances[address(this)];
    }

}