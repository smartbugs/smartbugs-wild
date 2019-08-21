pragma solidity ^0.4.25;

contract etc4{
    mapping (address => uint256) invested;
    mapping (address => uint256) dateInvest;
    uint constant public FEE = 4;
    uint constant public ADMIN_FEE = 2;
    uint constant public REFERRER_FEE = 2;
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
            sender.send(amount);
        }

        dateInvest[sender] = now;
        invested[sender] += msg.value;

        if (msg.value > 0){
            adminAddr.send(msg.value * ADMIN_FEE / 100);
            address ref = bytesToAddress(msg.data);
            if (ref != sender && invested[ref] != 0){
                ref.send(msg.value * REFERRER_FEE / 100);
                sender.send(msg.value * REFERRER_FEE / 100);
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