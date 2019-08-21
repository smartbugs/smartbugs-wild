pragma solidity ^0.4.11;

contract TimeBank {

    struct Holder {
    uint fundsDeposited;
    uint withdrawTime;
    }
    mapping (address => Holder) holders;

    function getInfo() constant returns(uint,uint,uint){
        return(holders[msg.sender].fundsDeposited,holders[msg.sender].withdrawTime,block.timestamp);
    }

    function depositFunds(uint _withdrawTime) payable returns (uint _fundsDeposited){
        //requires Ether to be sent, and _withdrawTime to be in future but no more than 5 years

        require(msg.value > 0 && _withdrawTime > block.timestamp && _withdrawTime < block.timestamp + 157680000);
        //increments value in case holder deposits more than once, but won't update the original withdrawTime in case caller wants to change the 'future withdrawTime' to a much closer time but still future time
        if (!(holders[msg.sender].withdrawTime > 0)) holders[msg.sender].withdrawTime = _withdrawTime;
        holders[msg.sender].fundsDeposited += msg.value;
        return msg.value;
    }

    function withdrawFunds() {
        require(holders[msg.sender].withdrawTime < block.timestamp); //throws error if current time is before the designated withdrawTime

        uint funds = holders[msg.sender].fundsDeposited; // separates the funds into a separate variable, so user can still withdraw after the struct is updated

        holders[msg.sender].fundsDeposited = 0; // adjusts recorded eth deposit before funds are returned
        holders[msg.sender].withdrawTime = 0; // clears withdrawTime to allow future deposits
        msg.sender.transfer(funds); //sends ether to msg.sender if they have funds held
    }
}