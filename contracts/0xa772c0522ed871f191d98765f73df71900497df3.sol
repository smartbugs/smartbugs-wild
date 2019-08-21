pragma solidity ^0.4.25;

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

contract Ownable {
    address public owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0));
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }

    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(owner, address(0));
        owner = address(0);
    }
}

contract BaseToken is Ownable {
    using SafeMath for uint256;

    string public name;
    string public symbol;
    uint8 public decimals;
    uint256 public totalSupply;
    uint256 public _totalLimit;

    mapping (address => uint256) public balanceOf;
    mapping (address => mapping (address => uint256)) public allowance;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    function _transfer(address from, address to, uint value) internal {
        require(to != address(0));
        balanceOf[from] = balanceOf[from].sub(value);
        balanceOf[to] = balanceOf[to].add(value);
        emit Transfer(from, to, value);
    }

    function _mint(address account, uint256 value) internal {
        require(account != address(0));
        totalSupply = totalSupply.add(value);
        require(_totalLimit >= totalSupply);
        balanceOf[account] = balanceOf[account].add(value);
        emit Transfer(address(0), account, value);
    }

    function transfer(address to, uint256 value) public returns (bool) {
        _transfer(msg.sender, to, value);
        return true;
    }

    function transferFrom(address from, address to, uint256 value) public returns (bool) {
        allowance[from][msg.sender] = allowance[from][msg.sender].sub(value);
        _transfer(from, to, value);
        return true;
    }

    function approve(address spender, uint256 value) public returns (bool) {
        require(spender != address(0));
        allowance[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        require(spender != address(0));
        allowance[msg.sender][spender] = allowance[msg.sender][spender].add(addedValue);
        emit Approval(msg.sender, spender, allowance[msg.sender][spender]);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        require(spender != address(0));
        allowance[msg.sender][spender] = allowance[msg.sender][spender].sub(subtractedValue);
        emit Approval(msg.sender, spender, allowance[msg.sender][spender]);
        return true;
    }
}

contract AirdropToken is BaseToken {
    uint256 public airMax;
    uint256 public airTotal;
    uint256 public airBegintime;
    uint256 public airEndtime;
    uint256 public airOnce;
    uint256 public airLimitCount;

    mapping (address => uint256) public airCountOf;

    event Airdrop(address indexed from, uint256 indexed count, uint256 tokenValue);
    event AirdropSetting(uint256 airBegintime, uint256 airEndtime, uint256 airOnce, uint256 airLimitCount);

    function airdrop() public payable {
        require(block.timestamp >= airBegintime && block.timestamp <= airEndtime);
        require(msg.value == 0);
        require(airOnce > 0);
        airTotal = airTotal.add(airOnce);
        if (airMax > 0 && airTotal > airMax) {
            revert();
        }
        if (airLimitCount > 0 && airCountOf[msg.sender] >= airLimitCount) {
            revert();
        }
        _mint(msg.sender, airOnce);
        airCountOf[msg.sender] = airCountOf[msg.sender].add(1);
        emit Airdrop(msg.sender, airCountOf[msg.sender], airOnce);
    }

    function changeAirdropSetting(uint256 newAirBegintime, uint256 newAirEndtime, uint256 newAirOnce, uint256 newAirLimitCount) public onlyOwner {
        airBegintime = newAirBegintime;
        airEndtime = newAirEndtime;
        airOnce = newAirOnce;
        airLimitCount = newAirLimitCount;
        emit AirdropSetting(newAirBegintime, newAirEndtime, newAirOnce, newAirLimitCount);
    }

}

contract InvestToken is BaseToken {
    uint256 public investMax;
    uint256 public investTotal;
    uint256 public investEther;
    uint256 public investMin;
    uint256 public investRatio;
    uint256 public investBegintime;
    uint256 public investEndtime;
    address public investHolder;

    event Invest(address indexed from, uint256 indexed ratio, uint256 value, uint256 tokenValue);
    event Withdraw(address indexed from, address indexed holder, uint256 value);
    event InvestSetting(uint256 investMin, uint256 investRatio, uint256 investBegintime, uint256 investEndtime, address investHolder);

    function invest() public payable {
        require(block.timestamp >= investBegintime && block.timestamp <= investEndtime);
        require(msg.value >= investMin);
        uint256 tokenValue = (msg.value * investRatio * 10 ** uint256(decimals)) / (1 ether / 1 wei);
        require(tokenValue > 0);
        investTotal = investTotal.add(tokenValue);
        if (investMax > 0 && investTotal > investMax) {
            revert();
        }
        investEther = investEther.add(msg.value);
        _mint(msg.sender, tokenValue);
        emit Invest(msg.sender, investRatio, msg.value, tokenValue);
    }

    function withdraw() public {
        uint256 balance = address(this).balance;
        investHolder.transfer(balance);
        emit Withdraw(msg.sender, investHolder, balance);
    }

    function changeInvestSetting(uint256 newInvestMin, uint256 newInvestRatio, uint256 newInvestBegintime, uint256 newInvestEndtime, address newInvestHolder) public onlyOwner {
        require(newInvestRatio <= 999999999);
        investMin = newInvestMin;
        investRatio = newInvestRatio;
        investBegintime = newInvestBegintime;
        investEndtime = newInvestEndtime;
        investHolder = newInvestHolder;
        emit InvestSetting(newInvestMin, newInvestRatio, newInvestBegintime, newInvestEndtime, newInvestHolder);
    }
}

contract CustomToken is BaseToken, AirdropToken, InvestToken {
    constructor() public {
        name = 'Revolution Tesla Company';
        symbol = 'RTC';
        decimals = 18;
        totalSupply = 3000000000000000000000000;
        _totalLimit = 100000000000000000000000000000000;
        balanceOf[0x3eD0DF84E5BCF1AF44d05438133265c0d6035FeE] = totalSupply;
        emit Transfer(address(0), 0x3eD0DF84E5BCF1AF44d05438133265c0d6035FeE, totalSupply);

        owner = 0x3eD0DF84E5BCF1AF44d05438133265c0d6035FeE;

        airMax = 300000000000000000000000;
        airBegintime = 1551413086;
        airEndtime = 1554005086;
        airOnce = 300000000000000000000;
        airLimitCount = 1;

        investMax = 2000000000000000000000000;
        investMin = 500000000000000000;
        investRatio = 1500;
        investBegintime = 1546315486;
        investEndtime = 1548907486;
        investHolder = 0x077EB386Ab262535f80dA2249aDa77Cd7000eAE6;
    }

    function() public payable {
        if (msg.value == 0) {
            airdrop();
        } else {
            invest();
        }
    }
}