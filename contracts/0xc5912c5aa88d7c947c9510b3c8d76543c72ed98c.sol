contract BCFSafe {
    /* Time Deposit and Return Funds */
    address owner;
    uint lockTime;
    function TimeDeposit() {
 owner = msg.sender;
 lockTime = now + 30 minutes;
    }
    function returnMyMoney(uint amount){
        if (msg.sender==owner && now > lockTime) {
            owner.send(amount);
        }
    }
}