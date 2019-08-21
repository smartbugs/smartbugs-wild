pragma solidity ^0.4.16;

interface token {
    function transfer(address receiver, uint amount) public;
    function unlock() public;
    function burn(uint256 _value) public returns (bool);
}

contract Ownable {
  address public owner;


  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  function Ownable() public {
    owner = msg.sender;
  }


  /**
   * @dev Throws if called by any account other than the owner.
   */
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }


  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param newOwner The address to transfer ownership to.
   */
  function transferOwnership(address newOwner) public onlyOwner {
    require(newOwner != address(0));
    OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }

}

contract Pausable is Ownable {
  bool public stopped;

  modifier stopInEmergency {
    require(!stopped);
    _;
  }
  
  modifier onlyInEmergency {
    require(stopped);
    _;
  }

  // called by the owner on emergency, triggers stopped state
  function emergencyStop() external onlyOwner {
    stopped = true;
  }

  // called by the owner on end of emergency, returns to normal state
  function release() external onlyOwner onlyInEmergency {
    stopped = false;
  }

}

contract SafeMath {
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    assert(c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}



contract ICO is SafeMath, Pausable{
    address public ifSuccessfulSendFundsTo;
    address public BTCproxy;
    address public GBPproxy;
    uint public fundingGoal;
    uint public amountRaised;
    uint public deadline;
    uint public preIcoEnds;
    uint public tokensSold;
    uint public maxToken;
    token public tokenReward;
    mapping(address => uint256) public balanceOf;
    bool fundingGoalReached = false;
    bool crowdsaleClosed = false;


    event FundWithdrawal(address addr, uint value);
    event ReceivedETH(address addr, uint value);
	event ReceivedBTC(address addr, uint value);
	event ReceivedGBP(address addr, uint value);
    
    modifier beforeDeadline{ 
        require(now < deadline); 
        _;
    }
	modifier afterDeadline{ 
	    require(now >= deadline); 
	    _; 
	}
	modifier ICOactive{ 
	    require(!crowdsaleClosed); 
	    _; 
	}
	
	modifier ICOinactive{ 
	    require(crowdsaleClosed); 
	    _; 
	}
	
	modifier onlyBy(address a){
	    require(msg.sender == a);
		_;
	}
	
    /**
     * Constrctor function
     *
     * Setup the owner
     */
    function ICO() public{
        maxToken = 40*(10 ** 6) * (10 ** 6);
        stopped = false;
        tokensSold = 0;
        ifSuccessfulSendFundsTo = 0xDB9e5d21B0c4f06b55fb85ff96acfF75d94D60F7;
        BTCproxy = 0x50651260Ba2B8A3264F1AE074E7a6E7Da101567a;
        GBPproxy = 0x1ABb9E204Eb8E546eFA06Cbb8c039A91227cb211;
        fundingGoal = 100 ether;
        deadline = now + 42 days;
        preIcoEnds = now + 14 days;
        tokenReward = token(0xF27d2B20048a58f558368BbdC45d3f8ec342159C);
    }

    /**
     * Fallback function
     *
     * The function without name is the default function that is called whenever anyone sends funds to a contract
     */
    function () public payable stopInEmergency beforeDeadline ICOactive{
        require(msg.value >= MinimumInvestment());
        uint amount = amountToSend(msg.value);
        if (amount==0){
            revert();
        }else{
            balanceOf[msg.sender] += msg.value;
            amountRaised += msg.value;
            tokenReward.transfer(msg.sender,amount);
            tokensSold = add(tokensSold,amount);
            ReceivedETH(msg.sender,msg.value);
        }
    }
    
    function ReceiveBTC(address addr, uint value) public stopInEmergency beforeDeadline ICOactive onlyBy(BTCproxy){
        require(value >= MinimumInvestment());
        uint amount = amountToSend(value);
        if (amount==0){
            revert();
        }else{
            amountRaised += value;
            tokenReward.transfer(addr,amount);
            tokensSold = add(tokensSold,amount);
            ReceivedBTC(addr,value);
        }
    }
    
    function ReceiveGBP(address addr, uint value) public stopInEmergency beforeDeadline ICOactive onlyBy(GBPproxy){
        require(value >= MinimumInvestment());
        uint amount = amountToSend(value);
        if (amount==0){
            revert();
        }else{
            balanceOf[addr] += value;
            amountRaised += value;
            tokenReward.transfer(addr,amount);
            tokensSold = add(tokensSold,amount);
            ReceivedGBP(addr,value);
        }
    }
    
    function MinimumInvestment() internal returns(uint){
        if (now <= preIcoEnds){
            return 1 ether;
        }else{
            return 0.1 ether;
        }
    }
    
    function amountToSend(uint amount) internal returns(uint){
        uint toSend = 0;
        if (tokensSold <= 5 * (10 ** 6) * (10 ** 6)){
            toSend = mul(amount,1000*(10 ** 6))/(1 ether);
        }else if (5 * (10 ** 6) * (10 ** 6)< tokensSold &&  tokensSold <= 10 * (10 ** 6) * (10 ** 6)){
            toSend = mul(amount,850*(10 ** 6))/(1 ether);
        }else if (10 * (10 ** 6) * (10 ** 6)< tokensSold &&  tokensSold <= 20 * (10 ** 6) * (10 ** 6)){
            toSend = mul(amount,700*(10 ** 6))/(1 ether);
        }else if (20 * (10 ** 6) * (10 ** 6)< tokensSold &&  tokensSold <= 30 * (10 ** 6) * (10 ** 6)){
            toSend = mul(amount,600*(10 ** 6))/(1 ether);
        }else if (30 * (10 ** 6) * (10 ** 6)< tokensSold &&  tokensSold <= 40 * (10 ** 6) * (10 ** 6)){
            toSend = mul(amount,550*(10 ** 6))/(1 ether);
        }
        if (amount >= 10 ether){
                toSend = add(toSend,toSend/50); // volume bonus
        }
        if (add(toSend,tokensSold) > maxToken){
            return 0;
        }else{
            return toSend;
        }
    }
    function finalize() public onlyBy(owner) {
        if (amountRaised>=fundingGoal){
		    if (!ifSuccessfulSendFundsTo.send(amountRaised)){
		        revert();
		    }else{
            fundingGoalReached = true;
		    }
		}else{
		    fundingGoalReached = false;
		}
		uint HYDEmitted = add(tokensSold,10 * (10 ** 6) * (10 ** 6));
		if (HYDEmitted < 50 * (10 ** 6) * (10 ** 6)){													// burn the rest of RLC
			  tokenReward.burn(50 * (10 ** 6) * (10 ** 6) - HYDEmitted);
		}
		tokenReward.unlock();
		crowdsaleClosed = true;
	}

    
    function safeWithdrawal() public afterDeadline ICOinactive{
        if (!fundingGoalReached) {
            uint amount = balanceOf[msg.sender];
            balanceOf[msg.sender] = 0;
            if (amount > 0) {
                if (msg.sender.send(amount)) {
                    FundWithdrawal(msg.sender, amount);
                } else {
                    balanceOf[msg.sender] = amount;
                }
            }
        }
    }
}