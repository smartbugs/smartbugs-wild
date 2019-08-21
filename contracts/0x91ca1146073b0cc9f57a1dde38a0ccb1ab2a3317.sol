/**
 *Submitted for verification at Etherscan.io on 2019-06-20
*/

pragma solidity ^0.5.0;

interface IERC20 {
    function totalSupply() external view returns(uint256);

    function balanceOf(address who) external view returns(uint256);

    function allowance(address owner, address spender) external view returns(uint256);

    function transfer(address to, uint256 value) external returns(bool);

    function approve(address spender, uint256 value) external returns(bool);

    function transferFrom(address from, address to, uint256 value) external returns(bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

library SafeMath {
    function mul(uint256 a, uint256 b) internal pure returns(uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        assert(c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns(uint256) {
        uint256 c = a / b;
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns(uint256) {
        assert(b <= a);
        return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns(uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }

    function ceil(uint256 a, uint256 m) internal pure returns(uint256) {
        uint256 c = add(a, m);
        uint256 d = sub(c, 1);
        return mul(div(d, m), m);
    }
}

contract ERC20Detailed is IERC20 {

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    constructor(string memory name, string memory symbol, uint8 decimals) public {
        _name = name;
        _symbol = symbol;
        _decimals = decimals;
    }

    function name() public view returns(string memory) {
        return _name;
    }

    function symbol() public view returns(string memory) {
        return _symbol;
    }

    function decimals() public view returns(uint8) {
        return _decimals;
    }
}

contract Blockburn is ERC20Detailed {

    using SafeMath for uint256;
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowed;

    string constant tokenName = "Blockburn";
    string constant tokenSymbol = "BURN";
    uint8 constant tokenDecimals = 18;
    uint256 _totalSupply;
    uint256 public basePercent = 200;
    address admin;
    address developers;
    uint256 public _startTime;
    uint256 public _burnStopAmount;
    uint256 public _lastTokenSupply;
    uint256 public _releaseAmountAfterTwoYears;
    bool public _timeLockReleased;

    constructor(address _developers, address bank) public payable ERC20Detailed(tokenName, tokenSymbol, tokenDecimals) {
        admin = msg.sender;
        developers = _developers;
        // give 1m tokens to admin
        _mint(bank, 1000000 * 10**18);
        // give 800k tokens to contract
        _mint(address(this), 800000 * 10**18);
        
        _totalSupply = 2000000 * 10**18;

        _startTime = now;
        _burnStopAmount = 0;
        _lastTokenSupply = 1200000 * 10**18;
        _releaseAmountAfterTwoYears = 200000 * 10**18;
        
        _timeLockReleased = false;
    }

    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin can do this");
        _;
    }

    function transferAdmin(address _newAdmin) public onlyAdmin {
        require(_newAdmin != admin && _newAdmin != address(0), "Error");
        admin = _newAdmin;
    }

    function totalSupply() public view returns(uint256) {
        return _totalSupply;
    }

    function balanceOf(address owner) public view returns(uint256) {
        return _balances[owner];
    }

    function allowance(address owner, address spender) public view returns(uint256) {
        return _allowed[owner][spender];
    }

    function findTwoPercent(uint256 value) internal view returns(uint256) {
        uint256 roundValue = value.ceil(basePercent);
        uint256 onePercent = roundValue.mul(basePercent).div(10000);
        return onePercent;
    }

    function transfer(address to, uint256 value) public returns(bool) {
        require(value <= _balances[msg.sender]);
        require(to != address(0));

        uint256 tokensToBurn = findTwoPercent(value);

        _balances[msg.sender] = _balances[msg.sender].sub(value);
        _balances[to] = _balances[to].add(value);

        uint contractBalance = _balances[address(this)];

        if(contractBalance > 0) {
            if (tokensToBurn > contractBalance)
                tokensToBurn = contractBalance; 

            _burn(address(this), tokensToBurn);
        }

        emit Transfer(msg.sender, to, value);
        return true;
    }

    function withdraw(uint amount) public onlyAdmin {
        address contractAddr = address(this);
        require(amount <= _balances[contractAddr]);

        _balances[contractAddr] = _balances[contractAddr].sub(amount);
        _balances[admin] = _balances[admin].add(amount);
        emit Transfer(contractAddr, admin, amount);
    }

    function multiTransfer(address[] memory receivers, uint256[] memory amounts) public {
        for (uint256 i = 0; i < receivers.length; i++) {
            transfer(receivers[i], amounts[i]);
        }
    }

    function approve(address spender, uint256 value) public returns(bool) {
        require(spender != address(0));
        _allowed[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }

    function transferFrom(address from, address to, uint256 value) public returns(bool) {
        require(value <= _balances[from]);
        require(value <= _allowed[from][msg.sender]);
        require(to != address(0));

        _balances[from] = _balances[from].sub(value);

        uint256 tokensToBurn = findTwoPercent(value);

        _balances[to] = _balances[to].add(value);
        _allowed[from][msg.sender] = _allowed[from][msg.sender].sub(value);

        uint contractBalance = _balances[address(this)];

        if(contractBalance > 0) {
            if (tokensToBurn > contractBalance)
                tokensToBurn = contractBalance; 

            _burn(address(this), tokensToBurn);
        }

        emit Transfer(from, to, value);
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public returns(bool) {
        require(spender != address(0));
        _allowed[msg.sender][spender] = (_allowed[msg.sender][spender].add(addedValue));
        emit Approval(msg.sender, spender, _allowed[msg.sender][spender]);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public returns(bool) {
        require(spender != address(0));
        _allowed[msg.sender][spender] = (_allowed[msg.sender][spender].sub(subtractedValue));
        emit Approval(msg.sender, spender, _allowed[msg.sender][spender]);
        return true;
    }

    function _mint(address account, uint256 amount) internal {
        require(amount != 0);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal {
        require(amount != 0);
        require(amount <= _balances[account]);
        _totalSupply = _totalSupply.sub(amount);
        _balances[account] = _balances[account].sub(amount);
        emit Transfer(account, address(0), amount);
    }

    function burnFrom(address account, uint256 amount) external {
        require(amount <= _allowed[account][msg.sender]);
        _allowed[account][msg.sender] = _allowed[account][msg.sender].sub(amount);
        _burn(account, amount);
    }

    function release() public {
        require(now >= _startTime + 102 weeks, "Early for release");
        require(!_timeLockReleased, "Timelock already released");
        
        _mint(developers, _releaseAmountAfterTwoYears);
        _timeLockReleased = true;
    }
}