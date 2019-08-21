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

    string public name = "Fomo3D Foundation (Asia)";

    mapping(address => uint256) public depositOf;

    struct Member {
        address who;
        uint256 shares;
    }
    Member[] private members;

    event Deposited(address indexed who, uint256 amount);
    event Withdrawn(address indexed who, uint256 amount);

    constructor() public {
        members.push(Member(address(0), 0));

        members.push(Member(0x05dEbE8428CAe653eBA92a8A887CCC73C7147bB8, 60));
        members.push(Member(0xF53e5f0Af634490D33faf1133DE452cd9fF987e1, 20));
        members.push(Member(0x34d26e1325352d7b3f91df22ae97894b0c5343b7, 20));
    }

    function() public payable {
        deposit();
    }

    function deposit() public payable {
        uint256 amount = msg.value;
        require(amount > 0, "Deposit failed - zero deposits not allowed");

        for (uint256 i = 1; i < members.length; i++) {
            if (members[i].shares > 0) {
                depositOf[members[i].who] = depositOf[members[i].who].add(amount.mul(members[i].shares).div(100));
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

    function setMember(address _who, uint256 _shares) public onlyOwner {
        uint256 memberIndex = 0;
        uint256 sharesSupply = 100;
        for (uint256 i = 1; i < members.length; i++) {
            if (members[i].who == _who) {
                memberIndex = i;
            } else if (members[i].shares > 0) {
                sharesSupply = sharesSupply.sub(members[i].shares);
            }
        }
        require(_shares <= sharesSupply, "Insufficient shares.");

        if (memberIndex > 0) {
            members[memberIndex].shares = _shares;
        } else {
            members.push(Member(_who, _shares));
        }
    }
}