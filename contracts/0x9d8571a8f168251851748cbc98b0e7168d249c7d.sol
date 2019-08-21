pragma solidity ^0.4.18;


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


contract Ownable {
  address public owner;


  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

  function Ownable() public {
    owner = msg.sender;
  }

  function transferOwnership(address newOwner) public onlyOwner {
    require(newOwner != address(0));
    OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }

}


contract ERC20Basic {
  uint256 public totalSupply;
  function balanceOf(address who) public view returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}


contract BasicToken is ERC20Basic {
  using SafeMath for uint256;

  mapping(address => uint256) balances;

  function transfer(address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));
    require(_value <= balances[msg.sender]);
    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);
    Transfer(msg.sender, _to, _value);
    return true;
  }

  function balanceOf(address _owner) public view returns (uint256 balance) {
    return balances[_owner];
  }

}


contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender) public view returns (uint256);
  function transferFrom(address from, address to, uint256 value) public returns (bool);
  function approve(address spender, uint256 value) public returns (bool);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}


contract StandardToken is ERC20, BasicToken {

    mapping (address => mapping (address => uint256)) internal allowed;

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
        require(_to != address(0));
        require(_value <= balances[_from]);
        require(_value <= allowed[_from][msg.sender]);
        balances[_from] = balances[_from].sub(_value);
        balances[_to] = balances[_to].add(_value);
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
        Transfer(_from, _to, _value);
        return true;
    }

    function approve(address _spender, uint256 _value) public returns (bool) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }

    function allowance(address _owner, address _spender) public view returns (uint256) {
        return allowed[_owner][_spender];
    }

    function increaseApproval(address _spender, uint _addedValue) public returns (bool) {
        allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
        Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
        return true;
    }

    function decreaseApproval(address _spender, uint _subtractedValue) public returns (bool) {
        uint oldValue = allowed[msg.sender][_spender];
        if (_subtractedValue > oldValue) {
            allowed[msg.sender][_spender] = 0;
        } else {
            allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
        }
        Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
        return true;
    }
}


contract ReleasableToken is StandardToken, Ownable {

    address public releaseAgent;

    bool public released = false;

    event Released();

    event ReleaseAgentSet(address releaseAgent);

    event TransferAgentSet(address transferAgent, bool status);

    mapping (address => bool) public transferAgents;

    modifier canTransfer(address _sender) {
        require(released || transferAgents[_sender]);
        _;
    }

    modifier inReleaseState(bool releaseState) {
        require(releaseState == released);
        _;
    }

    modifier onlyReleaseAgent() {
        require(msg.sender == releaseAgent);
        _;
    }

    function setReleaseAgent(address addr) public onlyOwner inReleaseState(false) {
        ReleaseAgentSet(addr);
        releaseAgent = addr;
    }

    function setTransferAgent(address addr, bool state) public onlyOwner inReleaseState(false) {
        TransferAgentSet(addr, state);
        transferAgents[addr] = state;
    }
    
    function releaseTokenTransfer() public onlyReleaseAgent {
        Released();
        released = true;
    }

    function transfer(address _to, 
                      uint _value) public canTransfer(msg.sender) returns (bool success) {
        return super.transfer(_to, _value);
    }

    function transferFrom(address _from, 
                          address _to, 
                          uint _value) public canTransfer(_from) returns (bool success) {
        return super.transferFrom(_from, _to, _value);
    }
}


contract TruMintableToken is ReleasableToken {
    
    using SafeMath for uint256;
    using SafeMath for uint;

    bool public mintingFinished = false;

    bool public preSaleComplete = false;

    bool public saleComplete = false;

    event Minted(address indexed _to, uint256 _amount);

    event MintFinished(address indexed _executor);
    
    event PreSaleComplete(address indexed _executor);

    event SaleComplete(address indexed _executor);

    modifier canMint() {
        require(!mintingFinished);
        _;
    }

    function mint(address _to, uint256 _amount) public onlyOwner canMint returns (bool) {
        require(_amount > 0);
        require(_to != address(0));
        totalSupply = totalSupply.add(_amount);
        balances[_to] = balances[_to].add(_amount);
        Minted(_to, _amount);
        Transfer(0x0, _to, _amount);
        return true;
    }

    function finishMinting(bool _presale, bool _sale) public onlyOwner returns (bool) {
        require(_sale != _presale);
        if (_presale == true) {
            preSaleComplete = true;
            PreSaleComplete(msg.sender);
            return true;
        }
        require(preSaleComplete == true);
        saleComplete = true;
        SaleComplete(msg.sender);
        mintingFinished = true;
        MintFinished(msg.sender);
        return true;
    }
}


contract UpgradeAgent {
    
    uint public originalSupply;

    function isUpgradeAgent() public pure returns (bool) {
        return true;
    }

    function upgradeFrom(address _from, uint256 _value) public;
}


contract TruUpgradeableToken is StandardToken {

    using SafeMath for uint256;
    using SafeMath for uint;

    address public upgradeMaster;

    UpgradeAgent public upgradeAgent;

    uint256 public totalUpgraded;

    bool private isUpgradeable = true;

    enum UpgradeState {Unknown, NotAllowed, WaitingForAgent, ReadyToUpgrade, Upgrading}

    event Upgrade(address indexed from, 
        address indexed to, 
        uint256 upgradeValue);

    event UpgradeAgentSet(address indexed agent, 
        address indexed executor);

    event NewUpgradedAmount(uint256 originalBalance, 
        uint256 newBalance, 
        address indexed executor);
    
    modifier onlyUpgradeMaster() {
        require(msg.sender == upgradeMaster);
        _;
    }

    function TruUpgradeableToken(address _upgradeMaster) public {
        require(_upgradeMaster != address(0));
        upgradeMaster = _upgradeMaster;
    }

    function upgrade(uint256 _value) public {
        UpgradeState state = getUpgradeState();
        require((state == UpgradeState.ReadyToUpgrade) || (state == UpgradeState.Upgrading));
        require(_value > 0);
        require(balances[msg.sender] >= _value);
        uint256 upgradedAmount = totalUpgraded.add(_value);
        uint256 senderBalance = balances[msg.sender];
        uint256 newSenderBalance = senderBalance.sub(_value);      
        uint256 newTotalSupply = totalSupply.sub(_value);
        balances[msg.sender] = newSenderBalance;
        totalSupply = newTotalSupply;        
        NewUpgradedAmount(totalUpgraded, newTotalSupply, msg.sender);
        totalUpgraded = upgradedAmount;
        upgradeAgent.upgradeFrom(msg.sender, _value);
        Upgrade(msg.sender, upgradeAgent, _value);
    }

    function setUpgradeAgent(address _agent) public onlyUpgradeMaster {
        require(_agent != address(0));
        require(canUpgrade());
        require(getUpgradeState() != UpgradeState.Upgrading);
        UpgradeAgent newUAgent = UpgradeAgent(_agent);
        require(newUAgent.isUpgradeAgent());
        require(newUAgent.originalSupply() == totalSupply);
        UpgradeAgentSet(upgradeAgent, msg.sender);
        upgradeAgent = newUAgent;
    }

    function getUpgradeState() public constant returns(UpgradeState) {
        if (!canUpgrade())
            return UpgradeState.NotAllowed;
        else if (upgradeAgent == address(0))
            return UpgradeState.WaitingForAgent;
        else if (totalUpgraded == 0)
            return UpgradeState.ReadyToUpgrade;
        else 
            return UpgradeState.Upgrading;
    }

    function setUpgradeMaster(address _master) public onlyUpgradeMaster {
        require(_master != address(0));
        upgradeMaster = _master;
    }

    function canUpgrade() public constant returns(bool) {
        return isUpgradeable;
    }
}


contract TruReputationToken is TruMintableToken, TruUpgradeableToken {

    using SafeMath for uint256;
    using SafeMath for uint;

    uint8 public constant decimals = 18;

    string public constant name = "Tru Reputation Token";

    string public constant symbol = "TRU";

    address public execBoard = 0x0;

    event BoardAddressChanged(address indexed oldAddress, 
        address indexed newAddress, 
        address indexed executor);

    modifier onlyExecBoard() {
        require(msg.sender == execBoard);
        _;
    }

    function TruReputationToken() public TruUpgradeableToken(msg.sender) {
        execBoard = msg.sender;
        BoardAddressChanged(0x0, msg.sender, msg.sender);
    }
    
    function changeBoardAddress(address _newAddress) public onlyExecBoard {
        require(_newAddress != address(0));
        require(_newAddress != execBoard);
        address oldAddress = execBoard;
        execBoard = _newAddress;
        BoardAddressChanged(oldAddress, _newAddress, msg.sender);
    }

    function canUpgrade() public constant returns(bool) {
        return released && super.canUpgrade();
    }

    function setUpgradeMaster(address _master) public onlyOwner {
        super.setUpgradeMaster(_master);
    }
}