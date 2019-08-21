pragma solidity ^0.4.15;

// Anyone can own this contract as long as they pay less
// than the previous owner.
contract EtherImp {
    address public creator;
    address public currentOwner;
    address public previousOwner;
    uint public lastPricePaid;

    event LogTransfer(
        address _from,
        address _to,
        uint _value
    );

    function EtherImp() payable public {
        require(msg.value > 0);

        creator = msg.sender;
        currentOwner = creator;
        previousOwner = creator;
        lastPricePaid = msg.value;
    }
    
    function buyBottle() payable public {
        // Conditions
        require(msg.sender != currentOwner);
        require(msg.value > 0);
        require(msg.value < lastPricePaid);
        
        // Effects
        previousOwner = currentOwner;
        currentOwner = msg.sender;
        lastPricePaid = msg.value;
        LogTransfer(previousOwner, currentOwner, lastPricePaid);
        
        // Interactions
        previousOwner.transfer(msg.value);
    }

    function close() onlyCreator {
        selfdestruct(creator);
    }

    modifier onlyCreator {
        require(msg.sender == creator);
        _;
    }

    modifier onlyOwner {
        require(msg.sender == currentOwner);
        _;
    }
}