pragma solidity ^0.4.17;

library SafeMath {

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a * b;
        assert(a == 0 || c / a == b);
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

contract Owned {
    address public owner;
    address public proposedOwner;
    event OwnershipTransferInitiated(address indexed _proposedOwner);
    event OwnershipTransferCompleted(address indexed _newOwner);


    function Owned() public {
        owner = msg.sender;
    }
    modifier onlyOwner() {
        require(isOwner(msg.sender));
        _;
    }

    function isOwner(address _address) internal view returns (bool) {
        return (_address == owner);
    }

    function initiateOwnershipTransfer(address _proposedOwner) public onlyOwner returns (bool) {
        proposedOwner = _proposedOwner;
        OwnershipTransferInitiated(_proposedOwner);
        return true;
    }

    function completeOwnershipTransfer() public returns (bool) {
        require(msg.sender == proposedOwner);
        owner = proposedOwner;
        proposedOwner = address(0);
        OwnershipTransferCompleted(owner);
        return true;
    }
}

contract SkipdayConfig {
    string  public constant TOKEN_SYMBOL   = "SKIPDAY";
    string  public constant TOKEN_NAME     = "Skipday";
    uint8   public constant TOKEN_DECIMALS = 18;
    uint256 public constant DECIMALSFACTOR = 10**uint256(TOKEN_DECIMALS);
    uint256 public constant TOKENS_MAX     = 314159265 * DECIMALSFACTOR;
}

contract ERC20Interface {
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
    function name() public view returns (string);
    function symbol() public view returns (string);
    function decimals() public view returns (uint8);
    function totalSupply() public view returns (uint256);
    function balanceOf(address _owner) public view returns (uint256 balance);
    function allowance(address _owner, address _spender) public view returns (uint256 remaining);
    function transfer(address _to, uint256 _value) public returns (bool success);
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);
    function approve(address _spender, uint256 _value) public returns (bool success);
}

contract ERC20Token is ERC20Interface, Owned {
    using SafeMath for uint256;
    string  private tokenName;
    string  private tokenSymbol;
    uint8   private tokenDecimals;
    uint256 internal tokenTotalSupply;
    mapping(address => uint256) balances;
    mapping(address => mapping (address => uint256)) allowed;


    function ERC20Token(string _symbol, string _name, uint8 _decimals, uint256 _totalSupply) public Owned(){
        tokenSymbol      = _symbol;
        tokenName        = _name;
        tokenDecimals    = _decimals;
        tokenTotalSupply = _totalSupply;
        balances[owner]  = _totalSupply;
        Transfer(0x0, owner, _totalSupply);
    }


    function name() public view returns (string) {
        return tokenName;
    }


    function symbol() public view returns (string) {
        return tokenSymbol;
    }


    function decimals() public view returns (uint8) {
        return tokenDecimals;
    }


    function totalSupply() public view returns (uint256) {
        return tokenTotalSupply;
    }


    function balanceOf(address _owner) public view returns (uint256) {
        return balances[_owner];
    }


    function allowance(address _owner, address _spender) public view returns (uint256 remaining) {
        return allowed[_owner][_spender];
    }


    function transfer(address _to, uint256 _value) public returns (bool success) {
        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);
        Transfer(msg.sender, _to, _value);
        return true;
    }


    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        balances[_from] = balances[_from].sub(_value);
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);
        Transfer(_from, _to, _value);
        return true;
    }


    function approve(address _spender, uint256 _value) public returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }

}

contract OpsManaged is Owned {
    address public opsAddress;
    address public adminAddress;
    event AdminAddressChanged(address indexed _newAddress);
    event OpsAddressChanged(address indexed _newAddress);


    function OpsManaged() public Owned(){
    }

    modifier onlyAdmin() {
        require(isAdmin(msg.sender));
        _;
    }

    modifier onlyAdminOrOps() {
        require(isAdmin(msg.sender) || isOps(msg.sender));
        _;
    }

    modifier onlyOwnerOrAdmin() {
        require(isOwner(msg.sender) || isAdmin(msg.sender));
        _;
    }

    modifier onlyOps() {
        require(isOps(msg.sender));
        _;
    }

    function isAdmin(address _address) internal view returns (bool) {
        return (adminAddress != address(0) && _address == adminAddress);
    }

    function isOps(address _address) internal view returns (bool) {
        return (opsAddress != address(0) && _address == opsAddress);
    }

    function isOwnerOrOps(address _address) internal view returns (bool) {
        return (isOwner(_address) || isOps(_address));
    }

    function setAdminAddress(address _adminAddress) external onlyOwnerOrAdmin returns (bool) {
        require(_adminAddress != owner);
        require(_adminAddress != address(this));
        require(!isOps(_adminAddress));
        adminAddress = _adminAddress;
        AdminAddressChanged(_adminAddress);
        return true;
    }

    function setOpsAddress(address _opsAddress) external onlyOwnerOrAdmin returns (bool) {
        require(_opsAddress != owner);
        require(_opsAddress != address(this));
        require(!isAdmin(_opsAddress));
        opsAddress = _opsAddress;
        OpsAddressChanged(_opsAddress);
        return true;
    }
}



contract Skipday is ERC20Token, OpsManaged, SkipdayConfig {
    bool public finalized;
    event Burnt(address indexed _from, uint256 _amount);
    event Finalized();

    function Skipday() public ERC20Token(TOKEN_SYMBOL, TOKEN_NAME, TOKEN_DECIMALS, TOKENS_MAX) OpsManaged(){
        finalized = false;
    }

    function transfer(address _to, uint256 _value) public returns (bool success) {
        checkTransferAllowed(msg.sender, _to);
        return super.transfer(_to, _value);
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        checkTransferAllowed(msg.sender, _to);
        return super.transferFrom(_from, _to, _value);
    }

    function checkTransferAllowed(address _sender, address _to) private view {
        if (finalized) {
            return;
        }
        require(isOwnerOrOps(_sender) || _to == owner);
    }

    function burn(uint256 _value) public returns (bool success) {
        require(_value <= balances[msg.sender]);
        balances[msg.sender] = balances[msg.sender].sub(_value);
        tokenTotalSupply = tokenTotalSupply.sub(_value);
        Burnt(msg.sender, _value);
        return true;
    }

    function finalize() external onlyAdmin returns (bool success) {
        require(!finalized);
        finalized = true;
        Finalized();
        return true;
    }
}