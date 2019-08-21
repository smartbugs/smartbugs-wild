pragma solidity ^0.4.23;


/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {

    /**
    * @dev Multiplies two numbers, throws on overflow.
    */
    function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
        // Gas optimization: this is cheaper than asserting 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
        if (a == 0) {
            return 0;
        }

        c = a * b;
        assert(c / a == b);
        return c;
    }

    /**
    * @dev Integer division of two numbers, truncating the quotient.
    */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // assert(b > 0); // Solidity automatically throws when dividing by 0
        // uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return a / b;
    }

    /**
    * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
    */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    /**
    * @dev Adds two numbers, throws on overflow.
    */
    function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
        c = a + b;
        assert(c >= a);
        return c;
    }
}

contract ERC20Basic {
    function totalSupply() public view returns (uint256);
    function balanceOf(address who) public view returns (uint256);
    function transfer(address to, uint256 value) public returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
}

contract ERC20 is ERC20Basic {
    function allowance(address owner, address spender)
        public view returns (uint256);

    function transferFrom(address from, address to, uint256 value)
        public returns (bool);

    function approve(address spender, uint256 value) public returns (bool);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract BasicToken is ERC20Basic {
    using SafeMath for uint256;

    mapping(address => uint256) balances;

    uint256 totalSupply_;

    function totalSupply() public view returns (uint256) {
        return totalSupply_;
    }

    function transfer(address _to, uint256 _value) public returns (bool) {
        require(_to != address(0));
        require(_value <= balances[msg.sender]);

        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);
        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    function balanceOf(address _owner) public view returns (uint256) {
        return balances[_owner];
    }
}

contract Ownable {
    address public owner;

    event OwnershipRenounced(address indexed previousOwner);
    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );


    constructor() public {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    function renounceOwnership() public onlyOwner {
        emit OwnershipRenounced(owner);
        owner = address(0);
    }

    function transferOwnership(address _newOwner) public onlyOwner {
        _transferOwnership(_newOwner);
    }

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


    modifier whenNotPaused() {
        require(!paused);
        _;
    }


    modifier whenPaused() {
        require(paused);
        _;
    }


    function pause() onlyOwner whenNotPaused public {
        paused = true;
        emit Pause();
    }


    function unpause() onlyOwner whenPaused public {
        paused = false;
        emit Unpause();
    }
}

contract Lockable is Pausable {
    mapping(address => bool) public lockedAccounts;
    mapping(address => uint) public lockedTokenToBlockList;

    event LockTokenToBlockSuccess(address indexed target, uint toBlockNumber);

    function lockTokenToBlock(uint _blockNumber) public returns (bool success) {
        require(lockedTokenToBlockList[msg.sender] < _blockNumber);

        return _lockTokenToBlock(msg.sender, _blockNumber);
    }

    function lockTokenToBlock(address _target, uint _blockNumber) public onlyOwner returns (bool success) {
        return _lockTokenToBlock(_target, _blockNumber);
    }

    function _lockTokenToBlock(address _target, uint _blockNumber) private returns (bool success) {
        require(_target != address(0) && _blockNumber > block.number);

        lockedTokenToBlockList[_target] = _blockNumber;

        emit LockTokenToBlockSuccess(_target, _blockNumber);

        return true;
    }


    function lockAddress(address _target) public onlyOwner returns (bool success) {
        require(_target != address(0));

        lockedAccounts[_target] = true;

        return true;
    }

    function unlockAddress(address _target) public onlyOwner returns (bool success) {
        delete lockedAccounts[_target];

        return true;
    }


    modifier transferAllowed(address _target) {
        require(_target != address(0)
            && lockedAccounts[_target] == false
            && lockedTokenToBlockList[_target] < block.number);

        _;
    }
}

/**
 * @title Standard ERC20 token
 *
 * @dev Implementation of the basic standard token.
 * https://github.com/ethereum/EIPs/issues/20
 * Based on code by FirstBlood: https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol
 */
contract StandardToken is ERC20, BasicToken {

    mapping (address => mapping (address => uint256)) internal allowed;


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
        returns (bool)
    {
        require(_to != address(0));
        require(_value <= balances[_from]);
        require(_value <= allowed[_from][msg.sender]);

        balances[_from] = balances[_from].sub(_value);
        balances[_to] = balances[_to].add(_value);
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
        emit Transfer(_from, _to, _value);
        return true;
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
    function approve(address _spender, uint256 _value) public returns (bool) {
        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
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
        returns (uint256)
    {
        return allowed[_owner][_spender];
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
        returns (bool)
    {
        allowed[msg.sender][_spender] = (
        allowed[msg.sender][_spender].add(_addedValue));
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
        returns (bool)
    {
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

contract LockableToken is StandardToken, Lockable {
    function transfer(
        address _to,
        uint256 _value
    )
        public
        whenNotPaused
        transferAllowed(msg.sender) 
        returns (bool)
    {
        return super.transfer(_to, _value);
    }


    function transferFrom(
        address _from,
        address _to,
        uint256 _value
    )
        public
        whenNotPaused
        transferAllowed(_from) 
        returns (bool)
    {
        return super.transferFrom(_from, _to, _value);
    }

    function approve(
        address _spender,
        uint256 _value
    )
        public
        whenNotPaused
        returns (bool)
    {
        return super.approve(_spender, _value);
    }


    function increaseApproval(
        address _spender,
        uint _addedValue
    )
        public
        whenNotPaused
        returns (bool success)
    {
        return super.increaseApproval(_spender, _addedValue);
    }
    

    function decreaseApproval(
        address _spender,
        uint _subtractedValue
    )
        public
        whenNotPaused
        returns (bool success)
    {
        return super.decreaseApproval(_spender, _subtractedValue);
    }
}

contract MQT is LockableToken {
    function () external {
        revert();
    }

    string public name = "Miao Quark Token"; 
    uint8 public decimals = 18;              
    string public symbol = "MQT";          

    uint public TOKEN_UNIT_RATIO = 10 ** 18;

    uint public totalTokens = 21000000000 * TOKEN_UNIT_RATIO;

    /*分配给基石投资的总数*/
    uint public assignedAmountToCornerstoneInvestment = totalTokens * 5 / 100;

    /*分配给团队的总数*/
    uint public assignedAmountToDevelopmentTeam = totalTokens * 20 / 100;

    /*分配给私募的总数*/
    uint public assignedAmountToPrivateEquityFund = totalTokens * 15 / 100;

    /*分配给基金会的总数*/
    uint public assignedAmountToTheFoundation = totalTokens * 10 / 100;

    /*分配给市场开拓的总数*/
    uint public assignedAmountToMarketExpand = totalTokens * 15 / 100;

    /*生态奖励奖池总数*/
    uint public assignedAmountToEcoReward = totalTokens * 35 / 100;

    enum PoolTypeChoices {Other, CornerstoneInvestment, DevelopmentTeam, PrivateEquityFund, Foundation, MarketExpand, EcoReward }

    mapping (uint32 => uint) assignedInfo;

    uint public defaultLockBlocksForPool = 182 days / 15 seconds;

    constructor() public {
        totalSupply_ = totalTokens;
    }

    function allocateTokens(PoolTypeChoices _choice, address _target, uint _amount) public onlyOwner whenNotPaused returns(bool) {
        uint _lockedBlocks = 0;
        if (_choice != PoolTypeChoices.EcoReward) {
            _lockedBlocks = defaultLockBlocksForPool;
        }
        return allocateTokens(_choice, _target, _amount, _lockedBlocks);
    }

    function allocateTokens(
        PoolTypeChoices _choice, 
        address _target,
        uint _amount,
        uint _lockedBlocks
    ) 
        public 
        onlyOwner 
        whenNotPaused 
        returns(bool) 
    {
        require(_target != address(0) && _amount > 0);

        uint totalAssigned = _amount.add(assignedInfo[uint32(_choice)]);

        uint totalPool = totalTokenForPool(_choice);

        require(totalAssigned <= totalPool);

        assignedInfo[uint32(_choice)] = totalAssigned;
        balances[_target] = _amount.add(balances[_target]);

        if (_lockedBlocks > 0) {
            lockTokenToBlock(_target, block.number + _lockedBlocks);
        }

        emit Transfer(address(0), _target, _amount);
        return true;
    }

    function remainingTokenForPool(PoolTypeChoices _choice) public view returns(uint) {
        uint totalPool = totalTokenForPool(_choice);

        if (totalPool > 0) {
            return totalPool.sub(assignedInfo[uint32(_choice)]);
        }

        return 0;
    }

    function totalTokenForPool(PoolTypeChoices _choice) public view returns(uint) {
        uint totalPool = 0;

        if (_choice == PoolTypeChoices.CornerstoneInvestment) {
            totalPool = assignedAmountToCornerstoneInvestment;
        } 
        else if (_choice == PoolTypeChoices.DevelopmentTeam) {
            totalPool = assignedAmountToDevelopmentTeam;
        }
        else if (_choice == PoolTypeChoices.PrivateEquityFund) {
            totalPool = assignedAmountToPrivateEquityFund;
        }
        else if (_choice == PoolTypeChoices.Foundation) {
            totalPool = assignedAmountToTheFoundation;
        }
        else if (_choice == PoolTypeChoices.MarketExpand) {
            totalPool = assignedAmountToMarketExpand;
        }
        else if (_choice == PoolTypeChoices.EcoReward) {
            totalPool = assignedAmountToEcoReward;
        }

        return totalPool;
    }
}