contract TokenInterface {
    uint totalSupply;
    function balanceOf(address owner) constant returns (uint256 balance);
    
    function transfer(address to, uint256 value) returns (bool success);

    function transferFrom(address from, address to, uint256 value) returns (bool success);
    function approve(address spender, uint256 value) returns (bool success);
    function allowance(address owner, address spender) constant returns (uint256 remaining);

    // events notifications
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}
contract StandardToken is TokenInterface {

    mapping (address => uint256) balances;

    mapping (address => mapping (address => uint256)) allowed;
    
    function StandardToken(){
    }
    function transfer(address to, uint256 value) returns (bool success) {
        
        
        if (balances[msg.sender] >= value && value > 0) {

            // do actual tokens transfer       
            balances[msg.sender] -= value;
            balances[to]         += value;
            
            // rise the Transfer event
            Transfer(msg.sender, to, value);
            return true;
        } else {
            
            return false; 
        }
    }
    
    function transferFrom(address from, address to, uint256 value) returns (bool success) {
    
        if ( balances[from] >= value && 
             allowed[from][msg.sender] >= value && 
             value > 0) {
                                          
    
            // do the actual transfer
            balances[from] -= value;    
            balances[to] =+ value;            
            

            // addjust the permision, after part of 
            // permited to spend value was used
            allowed[from][msg.sender] -= value;
            
            // rise the Transfer event
            Transfer(from, to, value);
            return true;
        } else { 
            
            return false; 
        }
    }
    function balanceOf(address owner) constant returns (uint256 balance) {
        return balances[owner];
    }

    function approve(address spender, uint256 value) returns (bool success) {
        
        allowed[msg.sender][spender] = value;
        Approval(msg.sender, spender, value);
        
        return true;
    }

    function allowance(address owner, address spender) constant returns (uint256 remaining) {
      return allowed[owner][spender];
    }

}
contract HackerGold is StandardToken {

    string public name = "HackerGold";

    uint8  public decimals = 3;
    string public symbol = "HKG";
    
    uint BASE_PRICE = 200;
    uint MID_PRICE = 150;
    uint FIN_PRICE = 100;
    uint SAFETY_LIMIT = 4000000 ether;
    uint DECIMAL_ZEROS = 1000;
    
    uint totalValue;
    
    address wallet;

    struct milestones_struct {
      uint p1;
      uint p2; 
      uint p3;
      uint p4;
      uint p5;
      uint p6;
    }
    // Milestones instance
    milestones_struct milestones;
    
    function HackerGold(address multisig) {
        
        wallet = multisig;

        // set time periods for sale
        milestones = milestones_struct(
        
          1476799200,  // P1: GMT: 18-Oct-2016 14:00  => The Sale Starts
          1478181600,  // P2: GMT: 03-Nov-2016 14:00  => 1st Price Ladder 
          1479391200,  // P3: GMT: 17-Nov-2016 14:00  => Price Stable, 
                       //                                Hackathon Starts
          1480600800,  // P4: GMT: 01-Dec-2016 14:00  => 2nd Price Ladder
          1481810400,  // P5: GMT: 15-Dec-2016 14:00  => Price Stable
          1482415200   // P6: GMT: 22-Dec-2016 14:00  => Sale Ends, Hackathon Ends
        );
                
    }
    
    
    /**
     * Fallback function: called on ether sent.
     * 
     * It calls to createHKG function with msg.sender 
     * as a value for holder argument
     */
    function () payable {
        createHKG(msg.sender);
    }
    
    /**
     * Creates HKG tokens.
     * 
     * Runs sanity checks including safety cap
     * Then calculates current price by getPrice() function, creates HKG tokens
     * Finally sends a value of transaction to the wallet
     * 
     * Note: due to lack of floating point types in Solidity,
     * contract assumes that last 3 digits in tokens amount are stood after the point.
     * It means that if stored HKG balance is 100000, then its real value is 100 HKG
     * 
     * @param holder token holder
     */
    function createHKG(address holder) payable {
        
        if (now < milestones.p1) throw;
        if (now >= milestones.p6) throw;
        if (msg.value == 0) throw;
    
        // safety cap
        if (getTotalValue() + msg.value > SAFETY_LIMIT) throw; 
    
        uint tokens = msg.value * getPrice() * DECIMAL_ZEROS / 1 ether;

        totalSupply += tokens;
        balances[holder] += tokens;
        totalValue += msg.value;
        
        if (!wallet.send(msg.value)) throw;
    }
    
    /**
     * Denotes complete price structure during the sale.
     *
     * @return HKG amount per 1 ETH for the current moment in time
     */
    function getPrice() constant returns (uint result) {
        
        if (now < milestones.p1) return 0;
        
        if (now >= milestones.p1 && now < milestones.p2) {
        
            return BASE_PRICE;
        }
        
        if (now >= milestones.p2 && now < milestones.p3) {
            
            uint days_in = 1 + (now - milestones.p2) / 1 days; 
            return BASE_PRICE - days_in * 25 / 7;  // daily decrease 3.5
        }

        if (now >= milestones.p3 && now < milestones.p4) {
        
            return MID_PRICE;
        }
        
        if (now >= milestones.p4 && now < milestones.p5) {
            
            days_in = 1 + (now - milestones.p4) / 1 days; 
            return MID_PRICE - days_in * 25 / 7;  // daily decrease 3.5
        }

        if (now >= milestones.p5 && now < milestones.p6) {
        
            return FIN_PRICE;
        }
        
        if (now >= milestones.p6){

            return 0;
        }

     }
    
    /**
     * Returns total stored HKG amount.
     * 
     * Contract assumes that last 3 digits of this value are behind the decimal place. i.e. 10001 is 10.001
     * Thus, result of this function should be divided by 1000 to get HKG value
     * 
     * @return result stored HKG amount
     */
    function getTotalSupply() constant returns (uint result) {
        return totalSupply;
    } 

    /**
     * It is used for test purposes.
     * 
     * Returns the result of 'now' statement of Solidity language
     * 
     * @return unix timestamp for current moment in time
     */
    function getNow() constant returns (uint result) {
        return now;
    }

    /**
     * Returns total value passed through the contract
     * 
     * @return result total value in wei
     */
    function getTotalValue() constant returns (uint result) {
        return totalValue;  
    }
}