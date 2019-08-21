pragma solidity ^0.4.19;

/**
   @title HODL

   A smart contract for real HOLDERS, all ETH received here can be withdraw a year 
   after it was deposited.
 */
contract HODL {

    // 1 Year to relase the funds
    uint256 public RELEASE_TIME = 1 years;

    // Balances on hold
    mapping(address => Deposit) deposits;
    
    struct Deposit {
        uint256 value;
        uint256 releaseTime;
    }
    
    /**
     @dev Fallback function

     Everytime the contract receives ETH it will check if there is a deposit
     made by the `msg.sender` if there is one the value of the tx wil be added
     to the current deposit and the release time will be reseted adding a year
     If there is not deposit created by the `msg.sender` it will be created.
   */
    function () public payable {
        require(msg.value > 0);
        
        if (deposits[msg.sender].releaseTime == 0) {
            uint256 releaseTime = now + RELEASE_TIME;
            deposits[msg.sender] = Deposit(msg.value, releaseTime);
        } else {
            deposits[msg.sender].value += msg.value;
            deposits[msg.sender].releaseTime += RELEASE_TIME;
        }
    }
    
    /**
     @dev withdraw function

     This function can be called by a holder after a year of his last deposit
     and it will transfer all the ETH deposited back to him.
   */
    function withdraw() public {
        require(deposits[msg.sender].value > 0);
        require(deposits[msg.sender].releaseTime < now);
        
        msg.sender.transfer(deposits[msg.sender].value);
        
        deposits[msg.sender].value = 0;
        deposits[msg.sender].releaseTime = 0;
    }
    
    /**
     @dev getDeposit function
     It returns the deposited value and release time from a holder.

     @param holder address The holder address

     @return uint256 value Amount of ETH deposited in wei
     @return uint256 releaseTime Timestamp of when the the deposit can returned
   */
    function getDeposit(address holder) public view returns
        (uint256 value, uint256 releaseTime)
    {
        return(deposits[holder].value, deposits[holder].releaseTime);
    }
}