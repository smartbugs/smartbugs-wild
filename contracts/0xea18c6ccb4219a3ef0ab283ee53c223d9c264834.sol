pragma solidity ^0.4.18;

/**
* Send 0.00025 to guess a random number from 0-9. Winner gets 80% of the pot.
* 20% goes to the house. Note: house is supplying the initial pot so cry me a 
* river.
*/


contract LuckyNumber {

    address owner;
    bool contractIsAlive = true;
    uint8 winningNumber; 
    uint commitTime = 60;
    uint nonce = 1;
    
    mapping (address => uint8) addressToGuess;
    mapping (address => uint) addressToTimeStamp;
    
    
    //modifier requiring contract to be live. Set bool to false to kill contract
    modifier live() 
    {
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
    function getBalance() view external returns (uint) {
        return this.balance;
    }
    
    //getter for contractIsAlive
    function getStatus() view external returns (bool) {
        return contractIsAlive;
    }

    //allows the owner to abort the contract and retrieve all funds
    function kill() 
    external 
    live 
    { 
        if (msg.sender == owner) {        
            owner.transfer(this.balance);
            contractIsAlive = false;
            }
    }

    /**
     * Pay 0.00025 eth to map your address to a guess. Sets time when guess can be checked
     */
    function takeAGuess(uint8 _myGuess) 
    public 
    payable
    live 
    {
        require(msg.value == 0.00025 ether);
        addressToGuess[msg.sender] = _myGuess;
        addressToTimeStamp[msg.sender] = now+commitTime;
    }
    
    
    /**
     * Call to check your guess and claim reward. Call will fail if guess was set 
     * less than 60 seconds ago. Random number is generated and compared to the 
     * user guess. If the numbers match, user recieves 80% of the pot and the 
     * remainder is returned to the owner. Finally, the users guess is reset to 
     * invalid number
     */
    function checkGuess()
    public
    live
    {
        require(now>addressToTimeStamp[msg.sender]);
        winningNumber = uint8(keccak256(now, owner, block.coinbase, block.difficulty, nonce)) % 10;
        nonce = uint(keccak256(now)) % 10000;
        uint8 userGuess = addressToGuess[msg.sender];
        if (userGuess == winningNumber) {
            msg.sender.transfer((this.balance*8)/10);
            owner.transfer(this.balance);
        }
        
        addressToGuess[msg.sender] = 16;
        addressToTimeStamp[msg.sender] = 1;
       
        
    }


}//end of contract