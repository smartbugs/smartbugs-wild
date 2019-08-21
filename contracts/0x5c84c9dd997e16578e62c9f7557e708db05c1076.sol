pragma solidity ^0.4.4;

contract Token {
    function transfer(address _to, uint _value) returns (bool);
    function balanceOf(address owner) returns(uint);
}

contract Owned {
    address public owner;

    function Owned() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        if (msg.sender != owner) throw;
        _;
    }

    address newOwner;

    function changeOwner(address _newOwner) onlyOwner {
        newOwner = _newOwner;
    }

    function acceptOwnership() {
        if (msg.sender == newOwner) {
            owner = newOwner;
        }
    }
}

contract TokenReceivable is Owned {
    event logTokenTransfer(address token, address to, uint amount);

    function claimTokens(address _token, address _to) onlyOwner returns (bool) {
        Token token = Token(_token);
        uint balance = token.balanceOf(this);
        if (token.transfer(_to, balance)) {
            logTokenTransfer(_token, _to, balance);
            return true;
        }
        return false;
    }
}

contract FunFairSale is Owned, TokenReceivable {
    uint public deadline;
    uint public startTime = 123123; //set actual time here
    uint public saleTime = 14 days;
    uint public capAmount;

    function FunFairSale() {
        deadline = startTime + saleTime;
    }

    function setSoftCapDeadline(uint t) onlyOwner {
        if (t > deadline) throw;
        deadline = t;
    }

    function launch(uint _cap) onlyOwner {
        // cap is immutable once the sale starts
        if (this.balance > 0) throw;
        capAmount = _cap;
    }

    function () payable {
        if (block.timestamp < startTime || block.timestamp >= deadline) throw;
        if (this.balance >= capAmount) throw;
        if (this.balance + msg.value >= capAmount) {
            deadline = block.timestamp;
        }
    }

    function withdraw() onlyOwner {
        if (block.timestamp < deadline) throw;
        if (!owner.call.value(this.balance)()) throw;
    }

    // for testing
    function setStartTime(uint _startTime, uint _deadline) onlyOwner {
    	if (_deadline < _startTime) throw;
        startTime = _startTime;
        deadline = _deadline;
    }

}