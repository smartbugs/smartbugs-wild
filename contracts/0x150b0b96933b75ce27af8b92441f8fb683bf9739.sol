pragma solidity 0.4.25;

library SafeMath256 {

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        assert(c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
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

    function pow(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) return 0;
        if (b == 0) return 1;

        uint256 c = a ** b;
        assert(c / (a ** (b - 1)) == a);
        return c;
    }
}

contract Ownable {
    address public owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    function _validateAddress(address _addr) internal pure {
        require(_addr != address(0), "invalid address");
    }

    constructor() public {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "not a contract owner");
        _;
    }

    function transferOwnership(address newOwner) public onlyOwner {
        _validateAddress(newOwner);
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }

}

contract Controllable is Ownable {
    mapping(address => bool) controllers;

    modifier onlyController {
        require(_isController(msg.sender), "no controller rights");
        _;
    }

    function _isController(address _controller) internal view returns (bool) {
        return controllers[_controller];
    }

    function _setControllers(address[] _controllers) internal {
        for (uint256 i = 0; i < _controllers.length; i++) {
            _validateAddress(_controllers[i]);
            controllers[_controllers[i]] = true;
        }
    }
}

contract Upgradable is Controllable {
    address[] internalDependencies;
    address[] externalDependencies;

    function getInternalDependencies() public view returns(address[]) {
        return internalDependencies;
    }

    function getExternalDependencies() public view returns(address[]) {
        return externalDependencies;
    }

    function setInternalDependencies(address[] _newDependencies) public onlyOwner {
        for (uint256 i = 0; i < _newDependencies.length; i++) {
            _validateAddress(_newDependencies[i]);
        }
        internalDependencies = _newDependencies;
    }

    function setExternalDependencies(address[] _newDependencies) public onlyOwner {
        externalDependencies = _newDependencies;
        _setControllers(_newDependencies);
    }
}

interface IERC20 {
  function totalSupply() external view returns (uint256);

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

contract ERC20 is IERC20 {
    using SafeMath256 for uint256;

    mapping (address => uint256) _balances;

    mapping (address => mapping (address => uint256)) _allowed;

    uint256 _totalSupply;

    string public name;
    string public symbol;
    uint8 public decimals;

    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address owner) public view returns (uint256) {
        return _balances[owner];
    }

    function allowance(
        address owner,
        address spender
    )
      public
      view
      returns (uint256)
    {
        return _allowed[owner][spender];
    }

    function transfer(address to, uint256 value) public returns (bool) {
        _transfer(msg.sender, to, value);
        return true;
    }

    function _validateAddress(address _addr) internal pure {
        require(_addr != address(0), "invalid address");
    }

    function approve(address spender, uint256 value) public returns (bool) {
        _validateAddress(spender);

        _allowed[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 value
    )
      public
      returns (bool)
    {
        require(value <= _allowed[from][msg.sender], "not enough allowed tokens");

        _allowed[from][msg.sender] = _allowed[from][msg.sender].sub(value);
        _transfer(from, to, value);
        return true;
    }

    function increaseAllowance(
        address spender,
        uint256 addedValue
    )
      public
      returns (bool)
    {
        _validateAddress(spender);

        _allowed[msg.sender][spender] = _allowed[msg.sender][spender].add(addedValue);
        emit Approval(msg.sender, spender, _allowed[msg.sender][spender]);
        return true;
    }

    function decreaseAllowance(
        address spender,
        uint256 subtractedValue
    )
      public
      returns (bool)
    {
        _validateAddress(spender);

        _allowed[msg.sender][spender] = _allowed[msg.sender][spender].sub(subtractedValue);
        emit Approval(msg.sender, spender, _allowed[msg.sender][spender]);
        return true;
    }

    function _transfer(address from, address to, uint256 value) internal {
        require(value <= _balances[from], "not enough tokens");
        _validateAddress(to);

        _balances[from] = _balances[from].sub(value);
        _balances[to] = _balances[to].add(value);
        emit Transfer(from, to, value);
    }

    function _mint(address account, uint256 value) internal {
        _validateAddress(account);
        _totalSupply = _totalSupply.add(value);
        _balances[account] = _balances[account].add(value);
        emit Transfer(address(0), account, value);
    }

    function _burn(address account, uint256 value) internal {
        _validateAddress(account);
        require(value <= _balances[account], "not enough tokens to burn");

        _totalSupply = _totalSupply.sub(value);
        _balances[account] = _balances[account].sub(value);
        emit Transfer(account, address(0), value);
    }

    function _burnFrom(address account, uint256 value) internal {
        require(value <= _allowed[account][msg.sender], "not enough allowed tokens to burn");

        _allowed[account][msg.sender] = _allowed[account][msg.sender].sub(value);
        _burn(account, value);
    }
}

contract Gold is ERC20, Upgradable {
    address[5] founders = [
        0x23b3763f31F4da6B42F47927BCF66A221E8705Cd,
        0x5CFF40372b96e133967d980F72812653163121fa,
        0xE246C5Aa2D57878DA70779A75B12dCDFFd77aDBA,
        0x950eEAf8ddbA1409dbD25aD16d50A867EEA75c3E,
        0x87252E8F04F6c6bC4d2c690893addb7108aa8a5f
    ];

    address foundation = 0x5Ff8957EF7e964E8072815211c9Fc3E7F820F1D4;
    address NonsenseGames = 0x10208FB4Ef202BdC49803995b0A8CA185383bba4;

    string constant WP_IPFS_HASH = "QmfR75tK12q2LpkU5dzYqykUUpYswSiewpCbDuwYhRb6M5";


    constructor(address treasury) public {
        name = "Dragonereum Gold";
        symbol = "GOLD";
        decimals = 18;

        uint256 _foundersGold = 6000000 * 10**18; // 10%
        uint256 _foundationGold = 6000000 * 10**18; // 10%
        uint256 _NonsenseGamesGold = 3000000 * 10**18; // 5%
        uint256 _gameAccountGold = 45000000 * 10**18; // 75%

        uint256 _founderStake = _foundersGold.div(founders.length);
        for (uint256 i = 0; i < founders.length; i++) {
            _mint(founders[i], _founderStake);
        }

        _mint(foundation, _foundationGold);
        _mint(NonsenseGames, _NonsenseGamesGold);
        _mint(treasury, _gameAccountGold);

        require(_totalSupply == 60000000 * 10**18, "wrong total supply");
    }

    function remoteTransfer(address _to, uint256 _value) external onlyController {
        _transfer(tx.origin, _to, _value);
    }

    function burn(uint256 _value) external onlyController {
        _burn(msg.sender, _value);
    }
}