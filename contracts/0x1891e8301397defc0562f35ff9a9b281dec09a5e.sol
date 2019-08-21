/* Copernic Space Cryptocurrency Token  */
/*     Released on 11.11.2018 v.1.1     */
/*   To celebrate 100 years of Polish   */
/*             INDEPENDENCE             */
/* ==================================== */
/* National Independence Day is a       */
/* national day in Poland celebrated on */
/* 11 November to commemorate the       */
/* anniversary of the restoration of    */
/* Poland's sovereignty as the          */
/* Second Polish Republic in 1918 from  */
/* German, Austrian and Russian Empires */
/* Following the partitions in the late */
/* 18th century, Poland ceased to exist */
/* for 123 years until the end of       */
/* World War I, when the destruction of */
/* the neighbouring powers allowed the  */
/* country to reemerge.                 */

pragma solidity 0.5.0;

library SafeMath {
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b);
        return c;
    }
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0);
        uint256 c = a / b;
        return c;
    }
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a);
        uint256 c = a - b;
        return c;
    }
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a);
        return c;
    }
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0);
        return a % b;
    }
}

contract ERC223Interface {
    function balanceOf(address who) public view returns (uint);
    function transfer(address _to, uint _value) public returns (bool);
    function transfer(address _to, uint _value, bytes memory _data) public returns (bool);
    event Transfer(address indexed from, address indexed to, uint value, bytes data);
}

contract ERC223ReceivingContract {
    function tokenFallback(address _from, uint _value, bytes memory _data) public;
}

contract Ownable {
    address private _owner;
    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );
    constructor() internal {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
    }
    function owner() public view returns (address) {
        return _owner;
    }
    modifier onlyOwner() {
        require(isOwner());
        _;
    }
    function isOwner() public view returns (bool) {
        return msg.sender == _owner;
    }
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }
    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0));
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

contract Pausable is Ownable {
    event Paused(address account);
    event Unpaused(address account);
    bool private _paused;
    constructor() internal {
        _paused = false;
    }
    function paused() public view returns (bool) {
        return _paused;
    }
    modifier whenNotPaused() {
        require(!_paused);
        _;
    }
    modifier whenPaused() {
        require(_paused);
        _;
    }
    function pause() public onlyOwner whenNotPaused {
        _paused = true;
        emit Paused(msg.sender);
    }
    function unpause() public onlyOwner whenPaused {
        _paused = false;
        emit Unpaused(msg.sender);
    }
}


interface IERC20 {
    function totalSupply() external pure returns (uint256);
    function balanceOf(address who) external view returns (uint256);
    function allowance(address owner, address spender)
    external view returns (uint256);
    function transfer(address to, uint256 value) external returns (bool);
    function approve(address spender, uint256 value)
    external returns (bool);
    function transferFrom(address from, address to, uint256 value)
    external returns (bool);
    event Transfer(
        address indexed from,
        address indexed to,
        uint256 value
    );
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

contract CPRToken is IERC20, ERC223Interface, Ownable, Pausable {
    using SafeMath for uint;
    mapping(address => uint) balances;
    mapping(address => mapping(address => uint256)) private _allowed;
    string  private constant        _name = "Copernic";
    string  private constant      _symbol = "CPR";
    uint8   private constant    _decimals = 6;
    uint256 private constant _totalSupply = 40000000 * (10 ** 6);
    constructor() public {
        balances[msg.sender] = balances[msg.sender].add(_totalSupply);
        emit Transfer(address(0), msg.sender, _totalSupply);
    }
    function totalSupply() public pure returns (uint256) {
        return _totalSupply;
    }
    function name() public pure returns (string memory) {
        return _name;
    }
    function symbol() public pure returns (string memory) {
        return _symbol;
    }
    function decimals() public pure returns (uint8) {
        return _decimals;
    }
    function balanceOf(address _owner) public view returns (uint balance) {
        return balances[_owner];
    }
    function allowance(address owner, address spender) public view returns (uint256)
    {
        return _allowed[owner][spender];
    }
    function increaseAllowance(address spender, uint256 addedValue) public whenNotPaused returns (bool)
    {
        require(spender != address(0));
        _allowed[msg.sender][spender] = (
        _allowed[msg.sender][spender].add(addedValue));
        emit Approval(msg.sender, spender, _allowed[msg.sender][spender]);
        return true;
    }
    function decreaseAllowance(address spender, uint256 subtractedValue) public whenNotPaused returns (bool)
    {
        require(spender != address(0));
        _allowed[msg.sender][spender] = (
        _allowed[msg.sender][spender].sub(subtractedValue));
        emit Approval(msg.sender, spender, _allowed[msg.sender][spender]);
        return true;
    }    function approve(address spender, uint256 value) public whenNotPaused returns (bool) {
        require(spender != address(0));
        _allowed[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }
    function transferFrom(address _from, address _to, uint256 _value) public whenNotPaused returns (bool success) {
        require(_value <= balances[_from]);
        require(_value <= _allowed[_from][msg.sender]);
        require(_to != address(0));
        require(balances[_to] + _value > balances[_to]);
        balances[_from] = balances[_from].sub(_value);
        _allowed[_from][msg.sender] = _allowed[_from][msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);
        uint codeLength;
        bytes memory empty;
        assembly {
            codeLength := extcodesize(_to)
        }
        if (codeLength > 0) {
            ERC223ReceivingContract receiver = ERC223ReceivingContract(_to);
            receiver.tokenFallback(_from, _value, empty);
        }
        emit Transfer(_from, _to, _value);
        emit Transfer(_from, _to, _value, empty);
        return true;
    }
    function transfer(address _to, uint _value, bytes memory _data) public whenNotPaused returns (bool) {
        if (isContract(_to)) {
            return transferToContract(_to, _value, _data);
        } else {
            return transferToAddress(_to, _value, _data);
        }
    }
    function transferToAddress(address _to, uint _value, bytes memory _data) internal returns (bool success) {
        require(_value <= balances[msg.sender]);
        require(_to != address(0));
        require(balances[_to] + _value > balances[_to]);
        balances[msg.sender] -= _value;
        balances[_to] += _value;
        emit Transfer(msg.sender, _to, _value);
        emit Transfer(msg.sender, _to, _value, _data);
        return true;
    }
    function transferToContract(address _to, uint _value, bytes memory _data) internal returns (bool success) {
        require(_value <= balances[msg.sender]);
        require(_to != address(0));
        require(balances[_to] + _value > balances[_to]);
        balances[msg.sender] -= _value;
        balances[_to] += _value;
        ERC223ReceivingContract receiver = ERC223ReceivingContract(_to);
        receiver.tokenFallback(msg.sender, _value, _data);
        emit Transfer(msg.sender, _to, _value);
        emit Transfer(msg.sender, _to, _value, _data);
        return true;
    }
    function isContract(address _address) internal view returns (bool is_contract) {
        uint length;
        if (_address == address(0)) return false;
        assembly {
            length := extcodesize(_address)
        }
        if (length > 0) {
            return true;
        } else {
            return false;
        }
    }
    function transfer(address _to, uint256 _value) whenNotPaused public returns (bool) {
        bytes memory empty;
        if (isContract(_to)) {
            return transferToContract(_to, _value, empty);
        } else {
            return transferToAddress(_to, _value, empty);
        }
        return true;
    }
    struct TKN {
        address sender;
        uint value;
        bytes data;
        bytes4 sig;
    }
    function tokenFallback(address _from, uint _value, bytes memory _data) pure public {
        TKN memory tkn;
        tkn.sender = _from;
        tkn.value = _value;
        tkn.data = _data;
        uint32 u = uint32(uint8(_data[3])) + (uint32(uint8(_data[2])) << 8) + (uint32(uint8(_data[1])) << 16) + (uint32(uint8(_data[0])) << 24);
        tkn.sig = bytes4(u);
    }
}