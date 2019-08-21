pragma solidity ^0.4.25;

/**
 *
 *  EasyInvest7 V2 Contract
 *  - GAIN 7% PER 24 HOURS
 *  - Principal withdrawal anytime
 *  - The balance of the contract can not greater than 200eth
 *
 *
 * How to use:
 *  1. Send amount of ether to make an investment, max 50eth
 *  2a. Get your profit and your principal by sending 0 ether transaction (every day, every week, i don't care unless you're spending too much on GAS)
 *  OR
 *  2b. Send more ether to reinvest AND get your profit at the same time
 *
 * RECOMMENDED GAS LIMIT: 150000
 * RECOMMENDED GAS PRICE: https://ethgasstation.info/
 *
 * www.easyinvest7.biz
 *
 */
contract EasyInvestV2 {
    using SafeMath              for *;

    string constant public name = "EasyInvest7";
    string constant public symbol = "EasyInvest7";
    
    uint256 _maxInvest = 5e19;
    uint256 _maxBalance = 2e20; 

    address public promoAddr_ = address(0x81eCf0979668D3C6a812B404215B53310f14f451);
    
    // records amounts invested
    mapping (address => uint256) public invested;
    // records time at which investments were made
    mapping (address => uint256) public atTime;
    
    uint256 public NowETHINVESTED = 0;
    uint256 public AllINVESTORS = 0;
    uint256 public AllETHINVESTED = 0;

    // this function called every time anyone sends a transaction to this contract
    function () external payable {
        
        uint256 realBalance = getBalance().sub(msg.value);
        
        require(msg.value <= _maxInvest  , "invest amount error, please set the exact amount");
        require(realBalance < _maxBalance  , "max balance, can't invest");
        
        uint256 more_ = 0;
        uint256 amount_ = msg.value;
        if (amount_.add(realBalance) > _maxBalance && amount_ > 0) {
            more_ = amount_.add(realBalance).sub(_maxBalance);
            amount_ = amount_.sub(more_);
            
            msg.sender.transfer(more_);
        }
        
        if (amount_.add(invested[msg.sender]) > _maxInvest && amount_ > 0) {
            more_ = amount_.add(invested[msg.sender]).sub(_maxInvest);
            amount_ = amount_.sub(more_);
            
            msg.sender.transfer(more_);
        }

        // if sender (aka YOU) is invested more than 0 ether
        if (invested[msg.sender] != 0) {
            // calculate profit amount as such:
            // amount = (amount invested) * 7% * (times since last transaction) / 24 hours
            uint256 amount = invested[msg.sender] * 7 / 100 * (now - atTime[msg.sender]) / 24 hours;

            // send calculated amount of ether directly to sender (aka YOU)
            msg.sender.transfer(amount);
        } else {
            if (atTime[msg.sender] == 0) {
                AllINVESTORS += 1;
            }
        }

        // record time and invested amount (msg.value) of this transaction
        if (msg.value == 0 && invested[msg.sender] != 0) {
            msg.sender.transfer(invested[msg.sender]);
            NowETHINVESTED = NowETHINVESTED.sub(invested[msg.sender]);
            
            atTime[msg.sender] = now;
            invested[msg.sender] = 0;
            
        } else {
            atTime[msg.sender] = now;
            invested[msg.sender] += amount_;
            NowETHINVESTED = NowETHINVESTED.add(amount_);
            AllETHINVESTED = AllETHINVESTED.add(amount_);
        }
        
        if (amount_ > 1e14) {
            promoAddr_.transfer(amount_.mul(2).div(100));
        }
    }
    
    function getBalance() public view returns (uint256){
        return address(this).balance;
    }
    

}

/***********************************************************
 * @title SafeMath v0.1.9
 * @dev Math operations with safety checks that throw on error
 * change notes:  original SafeMath library from OpenZeppelin modified by Inventor
 * - added sqrt
 * - added sq
 * - added pwr 
 * - changed asserts to requires with error log outputs
 * - removed div, its useless
 ***********************************************************/
 library SafeMath {
    /**
    * @dev Multiplies two numbers, throws on overflow.
    */
    function mul(uint256 a, uint256 b) 
        internal 
        pure 
        returns (uint256 c) 
    {
        if (a == 0) {
            return 0;
        }
        c = a * b;
        require(c / a == b, "SafeMath mul failed");
        return c;
    }

    /**
    * @dev Integer division of two numbers, truncating the quotient.
    */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // assert(b > 0); // Solidity automatically throws when dividing by 0
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return c;
    }
    
    /**
    * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
    */
    function sub(uint256 a, uint256 b)
        internal
        pure
        returns (uint256) 
    {
        require(b <= a, "SafeMath sub failed");
        return a - b;
    }

    /**
    * @dev Adds two numbers, throws on overflow.
    */
    function add(uint256 a, uint256 b)
        internal
        pure
        returns (uint256 c) 
    {
        c = a + b;
        require(c >= a, "SafeMath add failed");
        return c;
    }
    
    /**
     * @dev gives square root of given x.
     */
    function sqrt(uint256 x)
        internal
        pure
        returns (uint256 y) 
    {
        uint256 z = ((add(x,1)) / 2);
        y = x;
        while (z < y) 
        {
            y = z;
            z = ((add((x / z),z)) / 2);
        }
    }
    
    /**
     * @dev gives square. multiplies x by x
     */
    function sq(uint256 x)
        internal
        pure
        returns (uint256)
    {
        return (mul(x,x));
    }
    
    /**
     * @dev x to the power of y 
     */
    function pwr(uint256 x, uint256 y)
        internal 
        pure 
        returns (uint256)
    {
        if (x==0)
            return (0);
        else if (y==0)
            return (1);
        else 
        {
            uint256 z = x;
            for (uint256 i=1; i < y; i++)
                z = mul(z,x);
            return (z);
        }
    }
}