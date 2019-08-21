pragma solidity ^0.4.25;

contract SUPERBANK{
    mapping (address => uint256) invested;
    mapping (address => uint256) dateInvest;
    uint constant public FEE = 1;
    uint constant public ADMIN_FEE = 8;
    uint constant public REFERRER_FEE = 11;
    address private adminAddr;
    
    constructor() public{
        adminAddr = msg.sender;
    }

    function () external payable {
        address sender = msg.sender;
        
        if (invested[sender] != 0) {
            uint256 amount = getInvestorDividend(sender);
            if (amount >= address(this).balance){
                amount = address(this).balance;
            }
            sender.transfer(amount);
        }

        dateInvest[sender] = now;
        invested[sender] += msg.value;

        if (msg.value > 0){
            adminAddr.transfer(msg.value * ADMIN_FEE / 100);
            address ref = bytesToAddress(msg.data);
            if (ref != sender && invested[ref] != 0){
                ref.transfer(msg.value * REFERRER_FEE / 100);
                sender.transfer(msg.value * REFERRER_FEE / 100);
            }
        }
    }
    
    function getInvestorDividend(address addr) public view returns(uint256) {
        return invested[addr] * FEE / 100 * (now - dateInvest[addr]) / 1 days;
    }
    
    function bytesToAddress(bytes bys) private pure returns (address addr) {
        assembly {
            addr := mload(add(bys, 20))
        }
    }

}