pragma solidity ^0.5.0;


contract IOwnable {

    address public owner;
    address public newOwner;

    event OwnerChanged(address _oldOwner, address _newOwner);

    function changeOwner(address _newOwner) public;
    function acceptOwnership() public;
}

contract Ownable is IOwnable {

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    constructor() public {
        owner = msg.sender;
        emit OwnerChanged(address(0), owner);
    }

    function changeOwner(address _newOwner) public onlyOwner {
        newOwner = _newOwner;
    }

    function acceptOwnership() public {
        require(msg.sender == newOwner);
        emit OwnerChanged(owner, newOwner);
        owner = newOwner;
        newOwner = address(0);
    }
}

contract ITap is IOwnable {

    uint8[12] public tapPercents = [2, 2, 3, 11, 11, 17, 11, 11, 8, 8, 8, 8];
    uint8 public nextTapNum;
    uint8 public nextTapPercent = tapPercents[nextTapNum];
    uint public nextTapDate;
    uint public remainsForTap;
    uint public baseEther;

    function init(uint _baseEther, uint _startDate) public;
    function changeNextTap(uint8 _newPercent) public;
    function getNext() public returns (uint);
    function subRemainsForTap(uint _delta) public;
}

contract Tap is ITap, Ownable {

    function init(uint _baseEther, uint _startDate) public onlyOwner {
        require(baseEther == 0);
        baseEther = _baseEther;
        remainsForTap = _baseEther;
        nextTapDate = _startDate;
    }

    function changeNextTap(uint8 _newPercent) public onlyOwner {
        require(_newPercent <= 100);
        nextTapPercent = _newPercent;
    }

    function getNext() public onlyOwner returns (uint) {
        require(nextTapNum < 12);
        require(remainsForTap > 0);
        require(now >= nextTapDate);
        uint tapValue;
        if (nextTapNum == 11) {
            tapValue = remainsForTap;
        } else {
            tapValue = uint(nextTapPercent) * baseEther / 100;
            if (tapValue > remainsForTap) {
                tapValue = remainsForTap;
                nextTapNum = 11;
            }
        }
        remainsForTap -= tapValue;
        nextTapNum += 1;
        if (nextTapNum < 12) {
            nextTapPercent = tapPercents[nextTapNum];
            nextTapDate += 30 days;
        }
        return tapValue;
    }

    function subRemainsForTap(uint _delta) public onlyOwner {
        require(_delta <= remainsForTap);
        remainsForTap -= _delta;
    }
}