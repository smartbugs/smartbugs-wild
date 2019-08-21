pragma solidity >=0.4.22 <0.6.0;
contract FiveForty {
    
// "FiveForty" investment contract
// 5% daily up to 200% of invest
// 10% marketing fee
// 5% reward to referrer and refferal (payout to investment account)
// You need to have investment to receive refferal reward
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
        if (invested[refAddress] != 0 && refAddress != msg.sender) { // referral bonus adds only to investors
            invested[refAddress] += msg.value / 20; // referrer reward
            dailyPayment[refAddress] += msg.value / 400; // calculating ref's daily payment
            invested[msg.sender] += msg.value / 20; // referral reward
        }
        
        dailyPayment[msg.sender] = (invested[msg.sender] * 2 - totalPaid[msg.sender]) / 40; // calculating amount of daily payment (5% of invest)
        
    } else { // payment function
        
        if (invested[msg.sender] * 2 > totalPaid[msg.sender] && // max profit = invest*2
            block.number - lastPaymentBlock[msg.sender] > 5900) { // 24 hours from last payout
            
                uint thisPayment; // calculating current payment
                if (invested[msg.sender] * 2 - totalPaid[msg.sender] < dailyPayment[msg.sender]) { // total payout must be 200% of investment
                    thisPayment = invested[msg.sender] * 2 - totalPaid[msg.sender]; // last payment can be lower 5% of investment
                } else { thisPayment = dailyPayment[msg.sender]; } // regular 5% payment
                
                totalPaid[msg.sender] += thisPayment; // calculating all payouts
                lastPaymentBlock[msg.sender] = block.number; // recording time of last payment
                address payable sender = msg.sender; sender.transfer(thisPayment); // sending daily profit
            }
    }
}

function investorInfo(address Your_Address) public view returns(string memory Info, uint Total_Invested_PWEI, uint Pending_Profit_PWEI,
uint Daily_Profit_PWEI, uint Minutes_Before_Next_Payment, uint Total_Payouts_PWEI) { // helps to track investment
    Info = "PETA WEI (PWEI) = 1 ETH / 1000";
    Total_Invested_PWEI = invested[Your_Address] / (10**15);
    Pending_Profit_PWEI = (invested[Your_Address] * 2 - totalPaid[Your_Address]) / (10**15);
    Daily_Profit_PWEI = dailyPayment[Your_Address] / (10**15);
    uint time = 1440 - (block.number - lastPaymentBlock[Your_Address]) / 4;
    if (time <= 1440) { Minutes_Before_Next_Payment = time; } else { Minutes_Before_Next_Payment = 0; }
    Total_Payouts_PWEI = totalPaid[Your_Address] / (10**15);
}

}


library ToAddress {
  function toAddr(bytes memory source) internal pure returns(address payable addr) {
    assembly { addr := mload(add(source,0x14)) }
    return addr;
  }
}