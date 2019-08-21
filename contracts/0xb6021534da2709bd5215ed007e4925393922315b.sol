pragma solidity 0.4.15;

library SafeMath {

    function mul(uint256 a, uint256 b) internal returns (uint256) {
        if (a == 0) {
          return 0;
        }
        uint256 c = a * b;
        assert(c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) internal returns (uint256) {
        // assert(b > 0); // Solidity automatically throws when dividing by 0
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return c;
    }

    function sub(uint256 a, uint256 b) internal returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    function add(uint256 a, uint256 b) internal returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }

}

contract Owned {
    address public contractOwner;
    address public pendingContractOwner;

    function Owned() {
        contractOwner = msg.sender;
    }

    modifier onlyContractOwner() {
        if (contractOwner == msg.sender) {
            _;
        }
    }

    function changeContractOwnership(address _to) onlyContractOwner() returns(bool) {
        pendingContractOwner = _to;
        return true;
    }

    function claimContractOwnership() returns(bool) {
        if (pendingContractOwner != msg.sender) {
            return false;
        }
        contractOwner = pendingContractOwner;
        delete pendingContractOwner;
        return true;
    }
}

contract ERC20Interface {
    function balanceOf(address _address) returns(uint);
    function transfer(address _receiver, uint _amount) returns(bool);
    function transferFrom(address _from, address _to, uint _amount) returns(bool);
}

contract Vesting is Owned {
    struct Vestings {
        address receiver;
        ERC20Interface ERC20;
        uint amount;
        uint parts;
        uint paymentInterval;
        uint schedule;
        uint sendings;
    }

    mapping (address => uint) public vestingBalance;
    mapping (address => mapping (address => uint)) public receiverVestings;

    Vestings[] public vestings;

    event VestingCreated(address sender, address receiver, address ERC20, uint amount, uint id, uint parts, uint paymentInterval, uint schedule);
    event VestingSent(address receiver, address ERC20, uint amount, uint id, uint sendings);
    event ReceiverChanged(uint id, address from, address to);

    function createVesting(address _receiver, ERC20Interface _ERC20, uint _amount, uint _parts, uint _paymentInterval, uint _schedule) returns(bool) {
        require(_receiver != 0x0);
        require(_parts > 0 && _amount > 0 && _parts <= 10000);
        require(SafeMath.add(_schedule, SafeMath.mul(_paymentInterval, _parts)) <= ((365 * 5 days) + now));

        vestings.push(Vestings(_receiver, _ERC20, _amount, _parts, _paymentInterval, _schedule, 0));
        require(_ERC20.transferFrom(msg.sender, address(this), SafeMath.mul(_amount, _parts)));
        vestingBalance[_ERC20] = SafeMath.add(vestingBalance[_ERC20], (_amount * _parts));
        receiverVestings[_receiver][_ERC20] = SafeMath.add(receiverVestings[_receiver][_ERC20], (_amount * _parts));
        VestingCreated(msg.sender, _receiver, _ERC20, _amount, (vestings.length - 1), _parts, _paymentInterval, _schedule);
        return true;
    }

    function sendVesting(uint _id) returns(bool) {
        require(now >= (vestings[_id].schedule + vestings[_id].paymentInterval * (vestings[_id].sendings + 1)));

        require(vestings[_id].ERC20.transfer(vestings[_id].receiver, vestings[_id].amount));
        VestingSent(vestings[_id].receiver, vestings[_id].ERC20, vestings[_id].amount, _id, vestings[_id].sendings);
        vestings[_id].sendings++;
        vestingBalance[vestings[_id].ERC20] -= vestings[_id].amount;
        receiverVestings[vestings[_id].receiver][vestings[_id].ERC20] -= vestings[_id].amount;
        if (vestings[_id].sendings == vestings[_id].parts) {
            delete vestings[_id];
        }
        return true;
    }

    function changeReceiver(uint _id, address _newReceiver) returns(bool) {
        require(_newReceiver != 0x0);
        require(msg.sender == vestings[_id].receiver);

        vestings[_id].receiver = _newReceiver;
        ReceiverChanged(_id, msg.sender, _newReceiver);
        return true;
    }

    function withdrawExtraTokens(ERC20Interface _ERC20) onlyContractOwner() returns(bool) {
        require(_ERC20.transfer(contractOwner, getExtraTokens(_ERC20)));
        return true;
    }

    function getVesting(uint _id) constant returns(address, address, uint, uint, uint, uint, uint) {
        return (vestings[_id].receiver, vestings[_id].ERC20, vestings[_id].amount, vestings[_id].parts, vestings[_id].paymentInterval, vestings[_id].schedule, vestings[_id].sendings);
    }

    function getExtraTokens(ERC20Interface _ERC20) constant returns(uint) {
        return (_ERC20.balanceOf(this) - vestingBalance[_ERC20]);
    }

    function getReceiverVesting(address _receiver, address _ERC20) constant returns(uint) {
        return receiverVestings[_receiver][_ERC20];
    }
}