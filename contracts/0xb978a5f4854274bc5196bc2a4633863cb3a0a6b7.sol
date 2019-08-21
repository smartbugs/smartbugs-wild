pragma solidity ^0.4.0;

contract Pyramid {
    address master;

    address[] memberQueue;
    uint queueFront;

    event Joined(address indexed _member, uint _entries, uint _paybackStartNum);

    modifier onlymaster { if (msg.sender == master) _; }

    function Pyramid() {
        master = msg.sender;
        memberQueue.push(master);
        queueFront = 0;
    }

    // fallback function, wont work to call join here bc we will run out of gas (2300 gas for send())
    function(){}

    // users are allowed to join with .1 - 5 ethereum
    function join() payable {
        require(msg.value >= 100 finney);

        uint entries = msg.value / 100 finney;
        entries = entries > 50 ? 50 : entries; // cap at 5 ethereum

        for (uint i = 0; i < entries; i++) {
            memberQueue.push(msg.sender);

            if (memberQueue.length % 2 == 1) {
                queueFront += 1;
                memberQueue[queueFront-1].transfer(194 finney);
            }
        }

        Joined(msg.sender, entries, memberQueue.length * 2);

        // send back any unused ethereum
        uint remainder = msg.value - (entries * 100 finney);
        if (remainder > 1 finney) {
            msg.sender.transfer(remainder);
        }
        //msg.sender.send(msg.value - entries * 100 finney);
    }

    function collectFee() onlymaster {
        master.transfer(this.balance - 200 finney);
    }

    function setMaster(address _master) onlymaster {
        master = _master;
    }

}