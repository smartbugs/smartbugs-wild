pragma solidity 0.4.25;

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    assert(c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a / b;
    return c;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}

contract ERC20 {
    
  function totalSupply()public view returns (uint256 total_Supply);
  function balanceOf(address who)public view returns (uint256);
  function allowance(address owner, address spender)public view returns (uint256);
  function transferFrom(address from, address to, uint256 value)public returns (bool ok);
  function approve(address spender, uint256 value)public returns (bool ok);
  function transfer(address to, uint256 value)public returns (bool ok);
  event Transfer(address indexed from, address indexed to, uint256 value);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}

//--- Upgraded tokens must extend UpgradeAgent ----//
contract UpgradeAgent {
  address public oldAddress;
  function isUpgradeAgent() public pure returns (bool) {
    return true;
  }
  function upgradeFrom(address _from, uint256 _value) public;
}

contract CVEN is ERC20 { 
    using SafeMath for uint256;
    //--- Token configurations ----// 
    string public constant name = "Concordia Ventures Stablecoin";
    string public constant symbol = "CVEN";
    uint8 public constant decimals = 18;
    
    //--- Token allocations -------//
    uint256 public _totalsupply;
    uint256 public mintedTokens;
    uint256 public totalUpgraded;

    //--- Address -----------------//
    address public owner;
    address public ethFundMain;
    UpgradeAgent public upgradeAgent;
    
    //--- Variables ---------------//
    bool public lockstatus = false;
    bool public stopped = false;
    
    mapping(address => uint256) public balances;
    mapping(address => mapping(address => uint256)) public allowed;
    mapping(address => bool) public locked;
    event Mint(address indexed from, address indexed to, uint256 amount);
    event Burn(address indexed from, uint256 amount);
    event Upgrade(address indexed _from, address indexed _to, uint256 _value);
    event UpgradeAgentSet(address agent);

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner is allowed");
        _;
    }

    constructor() public
    {
        owner = msg.sender;
        ethFundMain = 0x657Eb3CE439CA61e58FF6Cb106df2e962C5e7890;
    }

    function totalSupply() public view returns (uint256 total_Supply) {
        total_Supply = _totalsupply;
    }
    
    function balanceOf(address _owner)public view returns (uint256 balance) {
        return balances[_owner];
    }

    function transfer(address _to, uint256 _amount)public returns (bool success) {
        require(!lockstatus, "Token is locked now");
        require( _to != 0x0, "Receiver can not be 0x0");
        require(balances[msg.sender] >= _amount, "Balance does not have enough tokens");
        require(!locked[msg.sender], "Sender address is locked");
        balances[msg.sender] = (balances[msg.sender]).sub(_amount);
        balances[_to] = (balances[_to]).add(_amount);
        emit Transfer(msg.sender, _to, _amount);
        return true;
    }

    function transferFrom( address _from, address _to, uint256 _amount ) public returns (bool success)  {
        require( _to != 0x0, "Receiver can not be 0x0");
        require(!lockstatus, "Token is locked now");
        require(balances[_from] >= _amount, "Source balance is not enough");
        require(allowed[_from][msg.sender] >= _amount, "Allowance is not enough");
        require(!locked[_from], "From address is locked");
        balances[_from] = (balances[_from]).sub(_amount);
        allowed[_from][msg.sender] = (allowed[_from][msg.sender]).sub(_amount);
        balances[_to] = (balances[_to]).add(_amount);
        emit Transfer(_from, _to, _amount);
        return true;
    }
    
    function approve(address _spender, uint256 _amount)public returns (bool success)  {
        require(!lockstatus, "Token is locked now");
        require( _spender != 0x0, "Address can not be 0x0");
        require(balances[msg.sender] >= _amount, "Balance does not have enough tokens");
        require(!locked[msg.sender], "Sender address is locked");
        allowed[msg.sender][_spender] = _amount;
        emit Approval(msg.sender, _spender, _amount);
        return true;
    }
  
    function allowance(address _owner, address _spender)public view returns (uint256 remaining) {
        return allowed[_owner][_spender];
    }

    function burn(uint256 _value) public returns (bool success) {
        require(balances[msg.sender] >= _value, "Balance does not have enough tokens");
        require(!locked[msg.sender], "Sender address is locked");   
        balances[msg.sender] = (balances[msg.sender]).sub(_value);            
        _totalsupply = _totalsupply.sub(_value);                     
        emit Burn(msg.sender, _value);
        return true;
    }

    function burnFrom(address from, uint256 _value) public returns (bool success) {
        require(balances[from] >= _value, "Source balance does not have enough tokens");
        require(allowed[from][msg.sender] >= _value, "Source balance does not have enough tokens");
        require(!locked[from], "Source address is locked");   
        balances[from] = (balances[from]).sub(_value);
        allowed[from][msg.sender] = (allowed[from][msg.sender]).sub(_value);            
        _totalsupply = _totalsupply.sub(_value);                     
        emit Burn(from, _value);
        return true;
    }

    function stopTransferToken() external onlyOwner {
        require(!lockstatus, "Token is locked");
        lockstatus = true;
    }

    function startTransferToken() external onlyOwner {
        require(lockstatus, "Token is transferable");
        lockstatus = false;
    }

    function () public payable {
        require(!stopped, "CrowdSale is stopping");
        mint(this, msg.sender, msg.value);
    }

    function manualMint(address receiver, uint256 _value) public onlyOwner{
        require(!stopped, "CrowdSale is stopping");
        mint(owner, receiver, _value);
    }

    function mint(address from, address receiver, uint256 value) internal {
        require(receiver != 0x0, "Address can not be 0x0");
        require(value > 0, "Value should larger than 0");
        balances[receiver] = balances[receiver].add(value);
        _totalsupply = _totalsupply.add(value);
        mintedTokens = mintedTokens.add(value);
        emit Mint(from, receiver, value);
        emit Transfer(0, receiver, value);
    }
    
    function haltMintToken() external onlyOwner {
        require(!stopped, "Minting is stopping");
        stopped = true;
    }

    function resumeMintToken() external onlyOwner {
        require(stopped, "Minting is running");
        stopped = false;
    }

    function changeReceiveWallet(address newAddress) external onlyOwner {
        require(newAddress != 0x0, "Address can not be 0x0");
        ethFundMain = newAddress;
    }

	function assignOwnership(address newOwner) external onlyOwner {
	    require(newOwner != 0x0, "Address can not be 0x0");
	    balances[newOwner] = (balances[newOwner]).add(balances[owner]);
	    balances[owner] = 0;
	    owner = newOwner;
	    emit Transfer(msg.sender, newOwner, balances[newOwner]);
	}

    function forwardFunds() external onlyOwner { 
        address myAddress = this;
        ethFundMain.transfer(myAddress.balance);
    }

    function withdrawTokens() external onlyOwner {
        uint256 value = balances[this];
        balances[owner] = (balances[owner]).add(value);
        balances[this] = 0;
        emit Transfer(this, owner, value);
    }

    function haltTokenTransferFromAddress(address investor) external onlyOwner {
        locked[investor] = true;
    }

    function resumeTokenTransferFromAddress(address investor) external onlyOwner {
        locked[investor] = false;
    }

    function setUpgradeAgent(address agent) external onlyOwner{
        require(agent != 0x0, "Upgrade agent can not be zero");
        require(totalUpgraded == 0, "Token are upgrading");
        upgradeAgent = UpgradeAgent(agent);
        require(upgradeAgent.isUpgradeAgent(), "The address is not upgrade agent");
        require(upgradeAgent.oldAddress() == address(this), "This is not right agent");
        emit UpgradeAgentSet(upgradeAgent);
    }

    function upgrade(uint256 value) public {
        require (value != 0, "Value can not be zero");
        require(balances[msg.sender] >= value, "Balance is not enough");
        require(address(upgradeAgent) != 0x0, "Upgrade agent is not set");
        balances[msg.sender] = (balances[msg.sender]).sub(value);
        _totalsupply = _totalsupply.sub(value);
        totalUpgraded = totalUpgraded.add(value);
        upgradeAgent.upgradeFrom(msg.sender, value);
        emit Upgrade(msg.sender, upgradeAgent, value);
        emit Transfer(msg.sender, 0, value);
    }
}