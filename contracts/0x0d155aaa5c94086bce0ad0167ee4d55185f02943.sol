pragma solidity ^0.4.24;


/**
  * @title SafeMath
  * @dev Math operations with safety checks that throw on error
  */
library SafeMath {
/**
  * @dev Multiplies two numbers, throws on overflow.
  */
    function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
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


/**
* @title Ownable
* @dev The Ownable contract has an owner address, and provides basic authorization control
* functions, this simplifies the implementation of "user permissions".
*/
contract Ownable {
    address public owner;
    event OwnershipRenounced(address indexed previousOwner);
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

    /**
    * @dev Allows the current owner to transfer control of the contract to a newOwner.
    * @param newOwner The address to transfer ownership to.
    */
    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0));
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }

    /**
    * @dev Allows the current owner to relinquish control of the contract.
    */
    function renounceOwnership() public onlyOwner {
        emit OwnershipRenounced(owner);
        owner = address(0);
    }
}


/**
 * @title ERC20Basic
 * @dev Simpler version of ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/179
 */
contract ERC20Basic {
    function totalSupply() public view returns (uint256);
    function balanceOf(address who) public view returns (uint256);
    function transfer(address to, uint256 value) public returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
}


/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20 is ERC20Basic {
    function allowance(address owner, address spender) public view returns (uint256);
    function transferFrom(address from, address to, uint256 value) public returns (bool);
    function approve(address spender, uint256 value) public returns (bool);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}


contract VANMToken is ERC20, Ownable {
    using SafeMath for uint256;

    //Variables
    string public symbol;
    string public name;
    uint8 public decimals;
    uint256 public _totalSupply;

    mapping(address => uint256) balances;
    mapping(address => mapping(address => uint256)) internal allowed;

    uint256 public presaleSupply;
    address public presaleAddress;

    uint256 public crowdsaleSupply;
    address public crowdsaleAddress;

    uint256 public platformSupply;
    address public platformAddress;

    uint256 public incentivisingSupply;
    address public incentivisingAddress;

    uint256 public teamSupply;
    address public teamAddress;

    uint256 public crowdsaleEndsAt;

    uint256 public teamVestingPeriod;

    bool public presaleFinalized = false;

    bool public crowdsaleFinalized = false;

    //Modifiers
    //Only presale contract
    modifier onlyPresale() {
        require(msg.sender == presaleAddress);
        _;
    }

    //Only crowdsale contract
    modifier onlyCrowdsale() {
        require(msg.sender == crowdsaleAddress);
        _;
    }

    //crowdsale has to be over
    modifier notBeforeCrowdsaleEnds(){
        require(block.timestamp >= crowdsaleEndsAt);
        _;
    }

    // Check if vesting period is over
    modifier checkTeamVestingPeriod() {
        require(block.timestamp >= teamVestingPeriod);
        _;
    }

    //Events
    event PresaleFinalized(uint tokensRemaining);

    event CrowdsaleFinalized(uint tokensRemaining);

    //Constructor
    constructor() public {

        //Basic information
        symbol = "VANM";
        name = "VANM";
        decimals = 18;

        //Total VANM supply
        _totalSupply = 240000000 * 10**uint256(decimals);

        // 10% of total supply for presale
        presaleSupply = 24000000 * 10**uint256(decimals);

        // 50% of total supply for crowdsale
        crowdsaleSupply = 120000000 * 10**uint256(decimals);

        // 10% of total supply for platform
        platformSupply = 24000000 * 10**uint256(decimals);

        // 20% of total supply for incentivising
        incentivisingSupply = 48000000 * 10**uint256(decimals);

        // 10% of total supply for team
        teamSupply = 24000000 * 10**uint256(decimals);

        platformAddress = 0x6962371D5a9A229C735D936df5CE6C690e66b718;

        teamAddress = 0xB9e54846da59C27eFFf06C3C08D5d108CF81FEae;

        // 01.05.2019 00:00:00 UTC
        crowdsaleEndsAt = 1556668800;

        // 2 years vesting period
        teamVestingPeriod = crowdsaleEndsAt.add(2 * 365 * 1 days);

        balances[platformAddress] = platformSupply;
        emit Transfer(0x0, platformAddress, platformSupply);

        balances[incentivisingAddress] = incentivisingSupply;
    }

    //External functions
    //Set Presale Address when it's deployed
    function setPresaleAddress(address _presaleAddress) external onlyOwner {
        require(presaleAddress == 0x0);
        presaleAddress = _presaleAddress;
        balances[_presaleAddress] = balances[_presaleAddress].add(presaleSupply);
    }

    // Finalize presale. Leftover tokens will overflow to crowdsale.
    function finalizePresale() external onlyPresale {
        require(presaleFinalized == false);
        uint256 amount = balanceOf(presaleAddress);
        if (amount > 0) {
            balances[presaleAddress] = 0;
            balances[crowdsaleAddress] = balances[crowdsaleAddress].add(amount);
        }
        presaleFinalized = true;
        emit PresaleFinalized(amount);
    }

    //Set Crowdsale Address when it's deployed
    function setCrowdsaleAddress(address _crowdsaleAddress) external onlyOwner {
        require(presaleAddress != 0x0);
        require(crowdsaleAddress == 0x0);
        crowdsaleAddress = _crowdsaleAddress;
        balances[_crowdsaleAddress] = balances[_crowdsaleAddress].add(crowdsaleSupply);
    }

    // Finalize crowdsale. Leftover tokens will overflow to platform.
    function finalizeCrowdsale() external onlyCrowdsale {
        require(presaleFinalized == true && crowdsaleFinalized == false);
        uint256 amount = balanceOf(crowdsaleAddress);
        if (amount > 0) {
            balances[crowdsaleAddress] = 0;
            balances[platformAddress] = balances[platformAddress].add(amount);
            emit Transfer(0x0, platformAddress, amount);
        }
        crowdsaleFinalized = true;
        emit CrowdsaleFinalized(amount);
    }

    //Public functions
    //ERC20 functions
    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    function transfer(address _to, uint256 _value) public
    notBeforeCrowdsaleEnds
    returns (bool) {
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

    function transferFrom(address _from, address _to, uint256 _value) public
    notBeforeCrowdsaleEnds
    returns (bool) {
        require(_to != address(0));
        require(_value <= balances[_from]);
        require(_value <= allowed[_from][msg.sender]);
        balances[_from] = balances[_from].sub(_value);
        balances[_to] = balances[_to].add(_value);
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
        emit Transfer(_from, _to, _value);
        return true;
    }

    function approve(address _spender, uint256 _value) public returns (bool) {
        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function allowance(address _owner, address _spender) public view returns (uint256) {
        return allowed[_owner][_spender];
    }

    //Token functions
    //Incentivising function to transfer tokens
    function transferFromIncentivising(address _to, uint256 _value) public
    onlyOwner
    returns (bool) {
    require(_value <= balances[incentivisingAddress]);
        balances[incentivisingAddress] = balances[incentivisingAddress].sub(_value);
        balances[_to] = balances[_to].add(_value);
        emit Transfer(0x0, _to, _value);
        return true;
    }

    //Presalefunction to transfer tokens
    function transferFromPresale(address _to, uint256 _value) public
    onlyPresale
    returns (bool) {
    require(_value <= balances[presaleAddress]);
        balances[presaleAddress] = balances[presaleAddress].sub(_value);
        balances[_to] = balances[_to].add(_value);
        emit Transfer(0x0, _to, _value);
        return true;
    }

    //Crowdsalefunction to transfer tokens
    function transferFromCrowdsale(address _to, uint256 _value) public
    onlyCrowdsale
    returns (bool) {
    require(_value <= balances[crowdsaleAddress]);
        balances[crowdsaleAddress] = balances[crowdsaleAddress].sub(_value);
        balances[_to] = balances[_to].add(_value);
        emit Transfer(0x0, _to, _value);
        return true;
    }

    // Release team supply after vesting period is finished.
    function releaseTeamTokens() public checkTeamVestingPeriod onlyOwner returns(bool) {
        require(teamSupply > 0);
        balances[teamAddress] = teamSupply;
        emit Transfer(0x0, teamAddress, teamSupply);
        teamSupply = 0;
        return true;
    }

    //Check remaining incentivising tokens
    function checkIncentivisingBalance() public view returns (uint256) {
        return balances[incentivisingAddress];
    }

    //Check remaining presale tokens after presale contract is deployed
    function checkPresaleBalance() public view returns (uint256) {
        return balances[presaleAddress];
    }

    //Check remaining crowdsale tokens after crowdsale contract is deployed
    function checkCrowdsaleBalance() public view returns (uint256) {
        return balances[crowdsaleAddress];
    }

    //Recover ERC20 Tokens
    function transferAnyERC20Token(address tokenAddress, uint tokens) public onlyOwner returns (bool success) {
        return ERC20(tokenAddress).transfer(owner, tokens);
    }

    //Don't accept ETH
    function () public payable {
revert();
    }
}