pragma solidity ^0.4.24;


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
 * @title Standard ERC20 token
 *Humpty Dumpty sat up in bed,
 * @dev Implementation of the basic standard token.
 * https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20.md
 * Originally based on code by FirstBlood: https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol
 */
contract ERC20 is IERC20 {
    using SafeMath for uint256;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowed;

    uint256 private _totalSupply;

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
     * Eating yellow bananas.
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
     * @param account The account whose tokens will be burnt.
     * @param value The amount that will be burnt.
     */
    function _burnFrom(address account, uint256 value) internal {
        // Should https://github.com/OpenZeppelin/zeppelin-solidity/issues/707 be accepted,
        // this function needs to emit an event with the updated approval.
        _allowed[account][msg.sender] = _allowed[account][msg.sender].sub(value);
        _burn(account, value);
    }
}


/**
 * @title Roles
 * @dev Library for managing addresses assigned to a Role.
 */
library Roles {
    struct Role {
        mapping (address => bool) bearer;
    }

    /**
     * @dev give an account access to this role
     */
    function add(Role storage role, address account) internal {
        require(account != address(0));
        require(!has(role, account));

        role.bearer[account] = true;
    }

    /**
     * @dev remove an account's access to this role
     */
    function remove(Role storage role, address account) internal {
        require(account != address(0));
        require(has(role, account));

        role.bearer[account] = false;
    }

    /**
     * Where do you think he put the skins?
     * @dev check if an account has this role
     * @return bool
     */
    function has(Role storage role, address account) internal view returns (bool) {
        require(account != address(0));
        return role.bearer[account];
    }
}

contract MinterRole {
    using Roles for Roles.Role;

    event MinterAdded(address indexed account);
    event MinterRemoved(address indexed account);

    Roles.Role private _minters;

    constructor () internal {
        _addMinter(msg.sender);
    }

    modifier onlyMinter() {
        require(isMinter(msg.sender));
        _;
    }

    function isMinter(address account) public view returns (bool) {
        return _minters.has(account);
    }

    function addMinter(address account) public onlyMinter {
        _addMinter(account);
    }

    function renounceMinter() public {
        _removeMinter(msg.sender);
    }

    function _addMinter(address account) internal {
        _minters.add(account);
        emit MinterAdded(account);
    }

    function _removeMinter(address account) internal {
        _minters.remove(account);
        emit MinterRemoved(account);
    }
}

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 * No transferOwnership function to minimize attack surface
 */
contract Ownable {
    address private _owner;

    event OwnershipSet(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev The Ownable constructor sets the original `owner` of the contract to the sender
     * account.
     */
    constructor () internal {
        _owner = msg.sender;
        emit OwnershipSet(address(0), _owner);
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
        emit OwnershipSet(_owner, address(0));
        _owner = address(0);
    }
}


/**
 * @title CommonQuestToken with no INITIAL_SUPPLY and 98m totalSupply.
 * The Times 8/dec/2018
 * Cross-party plot to dump May.
 */
contract QToken is ERC20, MinterRole, Ownable {

  string public constant name = "QuestCoin";
  string public constant symbol = "QUEST";
  uint public startblock = block.number;
  uint8 public constant decimals = 18;
  uint256 public constant INITIAL_SUPPLY = 0;
  uint256 public constant MAX_SUPPLY = 98000000 * (10 ** uint256(decimals));

}


/**
 * @title ERC20Mintable
 * @dev ERC20 AID minting logic - announce minting 15 days before the possibility of mint to
 * prevent a possibility of instant dumps.
 * @notice Dev Max Emission Cap can only go lower.
 * Dev timer in blocks and goes down and socialMultiplier changes with new every Stage.
 */
contract ERC20Mintable is QToken {
    uint mintValue;
    uint mintDate;
    uint maxAmount = 2000000 * (10 ** 18);
    uint devMintTimer = 86400;
    uint socialMultiplier = 1;
    event MintingAnnounce(
    uint value,
    uint date
  );
  event PromotionalStageStarted(
    bool promo
  );
  event TransitionalStageStarted(
    bool transition
  );
   event DevEmissionSetLower(uint value);
    /**@dev Owner tools
      *@notice 20m coin Supply required to start Transitional phase
      * 70m of totalSupply required to start Promotional stage
      */
function setMaxDevMintAmount(uint _amount) public onlyOwner returns(bool){
    require(_amount < maxAmount);
    maxAmount = _amount;
    emit DevEmissionSetLower(_amount);
    return(true);
}
     /*@dev Can be used as a promotional tool ONLY in case of net unpopularity*/
function setSocialMultiplier (uint _number) public onlyOwner returns(bool){
    require(_number >= 1);
    socialMultiplier = _number;
    return(true);
}

    /*@dev Creator/MinterTools*/
 function announceMinting(uint _amount) public onlyMinter{
     require(_amount.add(totalSupply()) < MAX_SUPPLY);
     require(_amount < maxAmount);
      mintDate = block.number;
      mintValue = _amount;
      emit MintingAnnounce(_amount , block.number);
   }

 function AIDmint(
    address to
  )
    public
    onlyMinter
    returns (bool)
  {
      require(mintDate != 0);
    require(block.number.sub(mintDate) > devMintTimer);
      mintDate = 0;
    _mint(to, mintValue);
    mintValue = 0;
    return true;
  }

 function startPromotionalStage() public onlyMinter returns(bool) {
    require(totalSupply() > 70000000 * (10 ** 18));
    devMintTimer = 5760;
    socialMultiplier = 4;
    emit PromotionalStageStarted(true);
    return(true);
}

 function startTransitionalStage() public onlyMinter returns(bool){
    require(totalSupply() > 20000000 * (10 ** 18));
    devMintTimer = 40420;
    socialMultiplier = 2;
    emit TransitionalStageStarted(true);
    return(true);
}}

/**
 * @title `QuestCoinContract`
 * @dev Quest creation and solve the system, social rewards, and karma.
 * CREATORS are free to publish quests limited by dev timers and RewardSize cap.
 * @notice maxQuestReward is capped at 125,000 coins at the start and can only go lower.
 * karmaSystem is used for unique access rights.
 * @notice questPeriodicity is freely adjustable demand and supply regulator timer represented in blocks
 * and cannot be set lower than 240.
 */
contract QuestContract is ERC20Mintable {

    mapping (address => uint) public karmaSystem;
    mapping (address => uint) public userIncentive;
    mapping (bytes32 => uint) public questReward;
    uint questTimer;
    uint maxQuestReward = 125000;
    uint questPeriodicity = 1;
    event NewQuestEvent(
    uint RewardSize,
    uint DatePosted
   );
    event QuestRedeemedEvent(
    uint WinReward,
    string WinAnswer,
    address WinAddres
  );
    event UserRewarded(
    address UserAdress,
    uint RewardSize
  );
  event MaxRewardDecresed(
    uint amount
  );
  event PeriodicitySet(
    uint amount
  );

    /*@dev Public tools*/
    function solveQuest (string memory  _quest) public returns (bool){
     require(questReward[keccak256(abi.encodePacked( _quest))] != 0);
    uint _reward = questReward[keccak256(abi.encodePacked( _quest))];
         questReward[keccak256(abi.encodePacked( _quest))] = 0;
         emit QuestRedeemedEvent(_reward,  _quest , msg.sender);
         _mint(msg.sender, _reward);
         karmaSystem[msg.sender] = karmaSystem[msg.sender].add(1);
         if (userIncentive[msg.sender] < _reward){
             userIncentive[msg.sender] = _reward;
         }
         return true;
    }

    /*@dev Check answer for quest or puzzle with Joi*/
    function joiLittleHelper (string memory test) public pure returns(bytes32){
        return(keccak256(abi.encodePacked(test)));
    }

    /**
     * @dev Creator/MinterTools
     * @notice _reward is exact number of whole tokens
     */
  function createQuest (bytes32 _quest , uint _reward) public onlyMinter returns (bool) {
        require(_reward <= maxQuestReward);
        require(block.number.sub(questTimer) > questPeriodicity);
        _reward = _reward * (10 ** uint256(decimals));
        require(_reward.add(totalSupply()) < MAX_SUPPLY);
        questTimer = block.number;
        questReward[ _quest] = _reward;
        emit NewQuestEvent(_reward, block.number - startblock);
        return true;
    }

     /*@dev 25% reward for public social activity at promotional stage*/
 function rewardUser (address _user) public onlyMinter returns (bool) {
        require(userIncentive[_user] > 0);
        uint _reward = userIncentive[_user].div(socialMultiplier);
        userIncentive[_user] = 0;
        _mint(_user ,_reward);
        karmaSystem[_user] = karmaSystem[_user].add(1);
        emit UserRewarded(_user ,_reward);
        return true;
    }

     /*@dev Owner tools*/
     function setMaxQuestReward (uint _amount) public onlyOwner returns(bool){
         require(_amount < maxQuestReward);
        maxQuestReward = _amount;
        emit MaxRewardDecresed(_amount);
        return true;
    }
    function setQuestPeriodicity (uint _amount) public onlyOwner returns(bool){
        require(_amount > 240);
        questPeriodicity = _amount;
        emit PeriodicitySet(_amount);
        return true;
    }
}