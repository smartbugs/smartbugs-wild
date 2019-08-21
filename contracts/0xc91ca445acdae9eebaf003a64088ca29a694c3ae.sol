pragma solidity ^0.4.24;

library SafeMath {
    function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
        if (a == 0) {
            return 0;
        }
        c = a * b;
        require(c / a == b, "SafeMath mul failed");
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256 c) {
        return a / b;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath sub failed");
        return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
        c = a + b;
        require(c >= a, "SafeMath add failed");
        return c;
    }
}

contract Ownable {
    address public owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() public {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "You are not owner.");
        _;
    }

    function transferOwnership(address _newOwner) public onlyOwner {
        require(_newOwner != address(0), "Invalid address.");

        owner = _newOwner;

        emit OwnershipTransferred(owner, _newOwner);
    }
}

contract Foundation is Ownable {
    using SafeMath for uint256;

    mapping(address => uint256) public depositOf;

    struct Share {
        address member;
        uint256 amount;
    }
    Share[] private shares;

    event Deposited(address indexed member, uint256 amount);
    event Withdrawn(address indexed member, uint256 amount);

    constructor() public {
        shares.push(Share(address(0), 0));

        shares.push(Share(0x05dEbE8428CAe653eBA92a8A887CCC73C7147bB8, 60));
        shares.push(Share(0xF53e5f0Af634490D33faf1133DE452cd9fF987e1, 20));
        shares.push(Share(0x34D26e1325352d7B3F91DF22ae97894B0C5343b7, 20));
    }

    function() public payable {
        deposit();
    }

    function deposit() public payable {
        uint256 amount = msg.value;
        require(amount > 0, "Deposit failed - zero deposits not allowed");

        for (uint256 i = 1; i < shares.length; i++) {
            if (shares[i].amount > 0) {
                depositOf[shares[i].member] = depositOf[shares[i].member].add(amount.mul(shares[i].amount).div(100));
            }
        }

        emit Deposited(msg.sender, amount);
    }

    function withdraw(address _who) public {
        uint256 amount = depositOf[_who];
        require(amount > 0 && amount <= address(this).balance, "Insufficient amount.");

        depositOf[_who] = depositOf[_who].sub(amount);

        _who.transfer(amount);

        emit Withdrawn(_who, amount);
    }

    function getShares(address _who) public view returns(uint256 amount) {
        for (uint256 i = 1; i < shares.length; i++) {
            if (shares[i].member == _who) {
                amount = shares[i].amount;
                break;
            }
        }
        return amount;
    }

    function setShares(address _who, uint256 _amount) public onlyOwner {
        uint256 index = 0;
        uint256 total = 100;
        for (uint256 i = 1; i < shares.length; i++) {
            if (shares[i].member == _who) {
                index = i;
            } else if (shares[i].amount > 0) {
                total = total.sub(shares[i].amount);
            }
        }
        require(_amount <= total, "Insufficient shares.");

        if (index > 0) {
            shares[index].amount = _amount;
        } else {
            shares.push(Share(_who, _amount));
        }
    }
}