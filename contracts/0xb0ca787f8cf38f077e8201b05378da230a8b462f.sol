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

    string constant public name = 'BHTX';
    string constant public symbol = 'BHTX';
    uint8 constant public decimals = 18;
    uint256 public totalSupply = 1e27;
    uint256 constant public _totalLimit = 1e32;

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

contract LockToken is BaseToken {

    struct LockItem {
        uint256 endtime;
        uint256 remain;
    }

    struct LockMeta {
        uint8 lockType;
        LockItem[] lockItems;
    }

    mapping (address => LockMeta) public lockData;

    event Lock(address indexed lockAddress, uint8 indexed lockType, uint256[] endtimeList, uint256[] remainList);

    function _transfer(address from, address to, uint value) internal {
        uint8 lockType = lockData[from].lockType;
        if (lockType != 0) {
            uint256 remain = balanceOf[from].sub(value);
            uint256 length = lockData[from].lockItems.length;
            for (uint256 i = 0; i < length; i++) {
                LockItem storage item = lockData[from].lockItems[i];
                if (block.timestamp < item.endtime && remain < item.remain) {
                    revert();
                }
            }
        }
        super._transfer(from, to, value);
    }

    function lock(address lockAddress, uint8 lockType, uint256[] endtimeList, uint256[] remainList) public onlyOwner returns (bool) {
        require(lockAddress != address(0));
        require(lockType == 0 || lockType == 1 || lockType == 2);
        require(lockData[lockAddress].lockType != 1);

        lockData[lockAddress].lockItems.length = 0;

        lockData[lockAddress].lockType = lockType;
        if (lockType == 0) {
            emit Lock(lockAddress, lockType, endtimeList, remainList);
            return true;
        }

        require(endtimeList.length == remainList.length);
        uint256 length = endtimeList.length;
        require(length > 0 && length <= 12);
        uint256 thisEndtime = endtimeList[0];
        uint256 thisRemain = remainList[0];
        lockData[lockAddress].lockItems.push(LockItem({endtime: thisEndtime, remain: thisRemain}));
        for (uint256 i = 1; i < length; i++) {
            require(endtimeList[i] > thisEndtime && remainList[i] < thisRemain);
            lockData[lockAddress].lockItems.push(LockItem({endtime: endtimeList[i], remain: remainList[i]}));
            thisEndtime = endtimeList[i];
            thisRemain = remainList[i];
        }

        emit Lock(lockAddress, lockType, endtimeList, remainList);
        return true;
    }
}

contract CustomToken is BaseToken, LockToken {
    constructor() public {
        balanceOf[0x69AD4582F25a5bAE004d4ceC3E5311bd8602AEB1] = totalSupply;
        emit Transfer(address(0), 0x69AD4582F25a5bAE004d4ceC3E5311bd8602AEB1, totalSupply);

        owner = 0x69AD4582F25a5bAE004d4ceC3E5311bd8602AEB1;
    }
}