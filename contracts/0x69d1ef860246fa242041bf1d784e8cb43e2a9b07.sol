pragma solidity >=0.4.22 <0.6.0;
contract FiveForty {
    
// "FiveForty" investment contract
// 5% daily up to 200% of invest
// 10% marketing fee
// 5% reward to referrer and refferal (need to have invest)
//
// Send ETH to make an invest
// Send 0 ETH to payout
// Recomended GAS LIMIT - 150 000
//
// ***WARNING*** 
// It's a "Ponzi scheme", you can lose your etherium
// You need to send payout request EVERY 24 HOURS
// Contract supports >0 transactions to payout, you can send up to 999 WEI to send payout request

using ToAddress for *;
mapping (address => uint256) invested; // records amounts invested
mapping (address => uint256) lastPaymentBlock; // records blocks at which last payment were made
mapping (address => uint256) dailyPayment; // records estimated daily payment
mapping (address => uint256) totalPaid; // records total paid
address payable constant fundAddress = 0x27FE767C1da8a69731c64F15d6Ee98eE8af62E72; // marketing fund address

function () external payable {
    if (msg.value >= 1000) { // receiving function
        
        fundAddress.transfer(msg.value / 10); // sending marketing fee
        if (invested[msg.sender] == 0) {lastPaymentBlock[msg.sender] = block.number;} // starting timer of payments (once for address)
        invested[msg.sender] += msg.value; // calculating all invests from address
        
        address refAddress = msg.data.toAddr();
        if (invested[refAddress] != 0 && refAddress != msg.sender) { invested[refAddress] += msg.value/20; } // Referral bonus adds only to investors
        invested[msg.sender] += msg.value/20; // Referral reward
        
        dailyPayment[msg.sender] = (invested[msg.sender] * 2 - totalPaid[msg.sender]) / 40; // calculating amount of daily payment (5% of invest)
        
    } else { // Payment function
        
        if (invested[msg.sender] * 2 > totalPaid[msg.sender] && // max profit = invest*2
            block.number - lastPaymentBlock[msg.sender] > 5900) { // 24 hours from last payout
                totalPaid[msg.sender] += dailyPayment[msg.sender]; // calculating all payouts
                address payable sender = msg.sender; sender.transfer(dailyPayment[msg.sender]); // sending daily profit
            }
    }
}

function investorInfo(address addr) public view returns(uint totalInvested, uint pendingProfit,
uint dailyProfit, uint minutesBeforeNextPayment, uint totalPayouts) { // helps to track investment
  totalInvested = invested[addr];
  pendingProfit = invested[addr] * 2 - totalPaid[addr];
  dailyProfit = dailyPayment[addr];
  uint time = 1440 - (block.number - lastPaymentBlock[addr]) / 4;
  if (time >= 0) { minutesBeforeNextPayment = time; } else { minutesBeforeNextPayment = 0; }
  totalPayouts = totalPaid[addr];
}

}

library ToAddress {
  function toAddr(bytes memory source) internal pure returns(address payable addr) {
    assembly { addr := mload(add(source,0x14)) }
    return addr;
  }
}