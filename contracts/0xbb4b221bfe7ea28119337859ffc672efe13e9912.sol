pragma solidity ^0.4.18;

/**
* Send 0.00025 to guess a random number from 0-9. Winner gets 90% of the pot.
* 10% goes to the house. Note: house is supplying the initial pot so cry me a 
* river.
*/

contract LuckyNumber {

    address owner;
    bool contractIsAlive = true;
    
    //modifier requiring contract to be live. Set bool to false to kill contract
    modifier live() {
        require(contractIsAlive);
        _;
    }

    // The constructor. 
    function LuckyNumber() public { 
        owner = msg.sender;
    }

    //Used for the owner to add money to the pot. 
    function addBalance() public payable live {
    }
    

    //explicit getter for "balance"
    function getBalance() view external live returns (uint) {
        return this.balance;
    }

    //allows the owner to abort the contract and retrieve all funds
    function kill() external live { 
        if (msg.sender == owner) {        
            owner.transfer(this.balance);
            contractIsAlive = false;
            }
    }

    /**
     *Take a guess. Transfer 0.00025 ETH to take a guess. 1/10 chance you are 
     * correct. If you win, the function will transfer you 90% of the balance. 
     * It will then kill the contract and return the remainder to the owner.
     */
    function takeAGuess(uint8 _myGuess) public payable live {
        require(msg.value == 0.00025 ether);
         uint8 winningNumber = uint8(keccak256(now, owner)) % 10;
        if (_myGuess == winningNumber) {
            msg.sender.transfer((this.balance*9)/10);
            owner.transfer(this.balance);
            contractIsAlive = false;   
        }
    }


}//end of contract