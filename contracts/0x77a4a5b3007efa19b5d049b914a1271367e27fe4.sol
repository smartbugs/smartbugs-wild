pragma solidity ^0.4.19;

contract ERC20 {


    event Transfer(address indexed _from, address indexed _to, uint256 _value);

    event Approval(address indexed _owner, address indexed _spender, uint256 _value);

    function totalSupply() external constant returns (uint);

    function balanceOf(address _owner) external constant returns (uint256);

    function transfer(address _to, uint256 _value) external returns (bool);

    function transferFrom(address _from, address _to, uint256 _value) external returns (bool);

    function approve(address _spender, uint256 _value) external returns (bool);

    function allowance(address _owner, address _spender) external constant returns (uint256);

}

library SafeMath {

    /*
        @return sum of a and b
    */
    function ADD (uint256 a, uint256 b) pure internal returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }

    /*
        @return difference of a and b
    */
    function SUB (uint256 a, uint256 b) pure internal returns (uint256) {
        assert(a >= b);
        return a - b;
    }
    
}

contract Ownable {


    address owner;

    event OwnershipTransferred(address indexed _previousOwner, address indexed _newOwner);

    function Ownable() public {
        owner = msg.sender;
        OwnershipTransferred (address(0), owner);
    }

    function transferOwnership(address _newOwner)
        public
        onlyOwner
        notZeroAddress(_newOwner)
    {
        owner = _newOwner;
        OwnershipTransferred(msg.sender, _newOwner);
    }

    //Only owner can call function
    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    modifier notZeroAddress(address _address) {
        require(_address != address(0));
        _;
    }

}

/*
	Trustable saves trusted addresses
*/
contract Trustable is Ownable {


    //Only trusted addresses are able to transfer tokens during the Crowdsale
    mapping (address => bool) trusted;

    event AddTrusted (address indexed _trustable);
    event RemoveTrusted (address indexed _trustable);

    function Trustable() public {
        trusted[msg.sender] = true;
        AddTrusted(msg.sender);
    }

    //Add new trusted address
    function addTrusted(address _address)
        external
        onlyOwner
        notZeroAddress(_address)
    {
        trusted[_address] = true;
        AddTrusted(_address);
    }

    //Remove address from a trusted list
    function removeTrusted(address _address)
        external
        onlyOwner
        notZeroAddress(_address)
    {
        trusted[_address] = false;
        RemoveTrusted(_address);
    }

}

contract Pausable is Trustable {


    //To check if Token is paused
    bool public paused;
    //Block number on pause
    uint256 public pauseBlockNumber;
    //Block number on resume
    uint256 public resumeBlockNumber;

    event Pause(uint256 _blockNumber);
    event Unpause(uint256 _blockNumber);

    function pause()
        public
        onlyOwner
        whenNotPaused
    {
        paused = true;
        pauseBlockNumber = block.number;
        resumeBlockNumber = 0;
        Pause(pauseBlockNumber);
    }

    function unpause()
        public
        onlyOwner
        whenPaused
    {
        paused = false;
        resumeBlockNumber = block.number;
        pauseBlockNumber = 0;
        Unpause(resumeBlockNumber);
    }

    modifier whenNotPaused {
        require(!paused);
        _;
    }

    modifier whenPaused {
        require(paused);
        _;
    }

}

/*
	Contract determines token
*/
contract Token is ERC20, Pausable{


    using SafeMath for uint256;

    //Total amount of Outing
    uint256 _totalSupply = 56000000000000000; 

    //Balances for each account
    mapping (address => uint256)  balances;
    //Owner of the account approves the transfer of an amount to another account
    mapping (address => mapping (address => uint256)) allowed;

    //Notifies users about the amount burnt
    event Burn(address indexed _from, uint256 _value);
    //Notifies users about end block change
    event CrowdsaleEndChanged (uint256 _crowdsaleEnd, uint256 _newCrowdsaleEnd);

    //return _totalSupply of the Token
    function totalSupply() external constant returns (uint256 totalTokenSupply) {
        totalTokenSupply = _totalSupply;
    }

    //What is the balance of a particular account?
    function balanceOf(address _owner)
        external
        constant
        returns (uint256 balance)
    {
        return balances[_owner];
    }

    //Transfer the balance from owner's account to another account
    function transfer(address _to, uint256 _amount)
        external
        notZeroAddress(_to)
        whenNotPaused
        returns (bool success)
    {
        balances[msg.sender] = balances[msg.sender].SUB(_amount);
        balances[_to] = balances[_to].ADD(_amount);
        Transfer(msg.sender, _to, _amount);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _amount)
        external
        notZeroAddress(_to)
        whenNotPaused
        returns (bool success)
    {
        //Require allowance to be not too big
        require(allowed[_from][msg.sender] >= _amount);
        balances[_from] = balances[_from].SUB(_amount);
        balances[_to] = balances[_to].ADD(_amount);
        allowed[_from][msg.sender] = allowed[_from][msg.sender].SUB(_amount);
        Transfer(_from, _to, _amount);
        return true;
    }

    // Allow _spender to withdraw from your account, multiple times, up to the _value amount.
    // If this function is called again it overwrites the current allowance with _value.
    function approve(address _spender, uint256 _amount)
        external
        whenNotPaused
        notZeroAddress(_spender)
        returns (bool success)
    {
        allowed[msg.sender][_spender] = _amount;
        Approval(msg.sender, _spender, _amount);
        return true;
    }

    //Return how many tokens left that you can spend from
    function allowance(address _owner, address _spender)
        external
        constant
        returns (uint256 remaining)
    {
        return allowed[_owner][_spender];
    }

    function increaseApproval(address _spender, uint256 _addedValue)
        external
        whenNotPaused
        returns (bool success)
    {
        uint256 increased = allowed[msg.sender][_spender].ADD(_addedValue);
        require(increased <= balances[msg.sender]);
        //Cannot approve more coins then you have
        allowed[msg.sender][_spender] = increased;
        Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
        return true;
    }

    function decreaseApproval(address _spender, uint256 _subtractedValue)
        external
        whenNotPaused
        returns (bool success)
    {
        uint256 oldValue = allowed[msg.sender][_spender];
        if (_subtractedValue > oldValue) {
            allowed[msg.sender][_spender] = 0;
        } else {
            allowed[msg.sender][_spender] = oldValue.SUB(_subtractedValue);
        }
        Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
        return true;
    }

    function burn(uint256 _value) external returns (bool success) {
        require(trusted[msg.sender]);
        //Subtract from the sender
        balances[msg.sender] = balances[msg.sender].SUB(_value);
        //Update _totalSupply
        _totalSupply = _totalSupply.SUB(_value);
        Burn(msg.sender, _value);
        return true;
    }

}

/*
	Contract defines specific token
*/
contract OutingToken is Token{

    //Name of the token
    string public constant name = "Outing";
    //Symbol of the token
    string public constant symbol = "OTG";
    //Number of decimals of Outing
    uint8 public constant decimals = 8;

    //Tokens allocation
    //Outing Reserve wallet that will be unlocked after 0.5 year after ICO
    address public constant OUTINGRESERVE = 0xB8E6C4Eab5BC0eAF1f3D8A9a59a8A26112a56fE2;
    //Team wallet that will be unlocked after 1 year after ICO

    address public constant TEAM = 0x0702dd2f7DC2FF1dCc6beC2De9D1e6e0d467AfaC;
    //0.5 year after ICO
    uint256 public UNLOCK_OUTINGRESERVE = now + 262800 minutes;
    //1 year after ICO
    uint256 public UNLOCK_TEAM = now + 525600 minutes;
    //outing reserve wallet balance
    uint256 public outingreserveBalance;
    //team wallet balance
    uint256 public teamBalance;

    //56%
    uint256 private constant OUTINGRESERVE_THOUSANDTH = 560;
    //7%
    uint256 private constant TEAM_THOUSANDTH = 70;
    //37%
    uint256 private constant ICO_THOUSANDTH = 370;
    //100%
    uint256 private constant DENOMINATOR = 1000;

    function OutingToken() public {
        //36% of _totalSupply
        balances[msg.sender] = _totalSupply * ICO_THOUSANDTH / DENOMINATOR;
        //56% of _totalSupply
        outingreserveBalance = _totalSupply * OUTINGRESERVE_THOUSANDTH / DENOMINATOR;
        //8% of _totalSupply
        teamBalance = _totalSupply * TEAM_THOUSANDTH / DENOMINATOR;

        Transfer (this, msg.sender, balances[msg.sender]);
    }

    //Check if team wallet is unlocked
    function unlockTokens(address _address) external {
        if (_address == OUTINGRESERVE) {
            require(UNLOCK_OUTINGRESERVE <= now);
            require (outingreserveBalance > 0);
            balances[OUTINGRESERVE] = outingreserveBalance;
            outingreserveBalance = 0;
            Transfer (this, OUTINGRESERVE, balances[OUTINGRESERVE]);
        } else if (_address == TEAM) {
            require(UNLOCK_TEAM <= now);
            require (teamBalance > 0);
            balances[TEAM] = teamBalance;
            teamBalance = 0;
            Transfer (this, TEAM, balances[TEAM]);
        }
    }
}