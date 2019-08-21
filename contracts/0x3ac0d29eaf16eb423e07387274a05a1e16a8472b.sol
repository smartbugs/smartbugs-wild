pragma solidity ^0.4.18;

/**
* Send 0.0001 to guess a random number from 1-10. Winner gets 90% of the pot.
* 10% goes to the house. Note: house is supplying the initial pot so cry me a 
* river.
*/

contract LuckyNumber {

    address owner;
    uint winningNumber = uint(keccak256(now, owner)) % 10;

    function LuckyNumber() public { // The constructor. 
        owner = msg.sender;
    }

    //Used for the owner to add money to the pot. 
    function addBalance() public payable {
    }

    //fallback function, returns accidental payments to sender
    function() public payable {
       msg.sender.transfer(msg.value); 
    }
    
    //explicit getter for "owner"
    function getOwner() view public returns (address)  {
        return owner;
    }

    //explicit getter for "balance"
    function getBalance() view public returns (uint) {
        return this.balance;
    }

    //allows the owner to abort the contract and retrieve all funds
    function kill() public { 
        if (msg.sender == owner)  // only allow this action if the account sending the signal is the creator
            selfdestruct(owner);       // kills this contract and sends remaining funds back to creator
    }

    /**
     *Take a guess. Transfer 0.00001 ETH to take a guess. 1/10 chance you are 
     * correct. If you win, the function will transfer you 90% of the balance. 
     * It will then kill the contract and return the remainder to the owner.
     */
    function takeAGuess(uint _myGuess) public payable {
        require(msg.value == 0.0001 ether);
        if (_myGuess == winningNumber) {
            msg.sender.transfer((this.balance*9)/10);
            selfdestruct(owner);
        }
    }


}//end of contract