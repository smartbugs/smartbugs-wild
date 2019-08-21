pragma solidity ^0.4.0;

contract Hellevator {

    event GiveUpTheDough(address indexed beneficiary);
    event JoinTheFray(address indexed rube);

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    uint public buyin = 0.01 ether;
    uint public newRubesUntilPayout = 3;
    uint public payout = 0.02 ether;
    uint public queueFront;
    uint public queueSize;

    address owner;
    mapping (address => uint) pendingWithdrawals;
    mapping (uint => address) rubes;

    function Hellevator() public {
        owner = msg.sender;
    }

    function() public payable {
        joinTheFray();
    }

    function withdraw() public {
        uint amount = pendingWithdrawals[msg.sender];
        pendingWithdrawals[msg.sender] = 0;
        msg.sender.transfer(amount);
    }

    // Internal

    function addRube() internal {
        rubes[queueSize] = msg.sender;
        queueSize += 1;
    }

    function giveUpTheDough() internal {
        address undeservingBeneficiary = rubes[queueFront];
        pendingWithdrawals[undeservingBeneficiary] += payout;
        queueFront += 1;
        GiveUpTheDough(undeservingBeneficiary);
    }

    function isPayoutTime() internal view returns (bool) {
        return queueSize % newRubesUntilPayout == 0;
    }

    function joinTheFray() internal {
        bool isCheapskate = msg.value < buyin;

        if (isCheapskate) {
            return;
        }

        addRube();
        JoinTheFray(msg.sender);

        if (isPayoutTime()) {
            giveUpTheDough();
        }
    }

    // Administration

    function changeBuyin(uint _buyin) public onlyOwner {
        buyin = _buyin;
    }

    function changeNewRubesUntilPayout(uint _newRubesUntilPayout) public onlyOwner {
        newRubesUntilPayout = _newRubesUntilPayout;
    }

    function changeOwner(address _owner) public onlyOwner {
        owner = _owner;
    }

    function changePayout(uint _payout) public onlyOwner {
        payout = _payout;
    }

    function payTheMan(uint amount) public onlyOwner {
        owner.transfer(amount);
    }
}