pragma solidity ^0.4.17;


/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
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

/**
 * @title Pausable
 * @dev Base contract which allows children to implement an emergency stop mechanism.
 */
contract Pausable is Ownable {
  event Pause();
  event Unpause();

  bool public paused = false;


  /**
   * @dev Modifier to make a function callable only when the contract is not paused.
   */
  modifier whenNotPaused() {
    require(!paused);
    _;
  }

  /**
   * @dev Modifier to make a function callable only when the contract is paused.
   */
  modifier whenPaused() {
    require(paused);
    _;
  }

  /**
   * @dev called by the owner to pause, triggers stopped state
   */
  function pause() onlyOwner whenNotPaused public {
    paused = true;
    Pause();
  }

  /**
   * @dev called by the owner to unpause, returns to normal state
   */
  function unpause() onlyOwner whenPaused public {
    paused = false;
    Unpause();
  }
}

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {
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


/**
 * @title ERC20Basic
 * @dev Simpler version of ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/179
 */
contract ERC20Basic {
  //uint256 public totalSupply;
  function balanceOf(address who) public view returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}



/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20 
 */
contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender) public view returns (uint256);
  function transferFrom(address from, address to, uint256 value) public returns (bool);
  function approve(address spender, uint256 value) public returns (bool);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract GoldFees is Ownable {
    using SafeMath for uint256;
    
    // e.g. if rate = 0.0054
    //uint rateN = 9999452055;
    uint rateN = 9999452054794520548;
    uint rateD = 19;
    uint public maxDays;
    uint public maxRate;

    
    function GoldFees() public {
        calcMax();
    }

    function calcMax() internal {
        maxDays = 1;
        maxRate = rateN;
        
        
        uint pow = 2;
        do {
            uint newN = rateN ** pow;
            if (newN / maxRate != maxRate) {
                maxDays = pow / 2;
                break;
            }
            maxRate = newN;
            pow *= 2;
        } while (pow < 2000);
        
    }

    function updateRate(uint256 _n, uint256 _d) public onlyOwner {
        rateN = _n;
        rateD = _d;
        calcMax();
    }
    
    function rateForDays(uint256 numDays) public view returns (uint256 rate) {
        if (numDays <= maxDays) {
            uint r = rateN ** numDays;
            uint d = rateD * numDays;
            if (d > 18) {
                uint div = 10 ** (d-18);
                rate = r / div;
            } else {
                div = 10 ** (18 - d);
                rate = r * div;
            }
        } else {
            uint256 md1 = numDays / 2;
            uint256 md2 = numDays - md1;
             uint256 r2;

            uint256 r1 = rateForDays(md1);
            if (md1 == md2) {
                r2 = r1;
            } else {
                r2 = rateForDays(md2);
            }
           

            //uint256 r1 = rateForDays(maxDays);
            //uint256 r2 = rateForDays(numDays-maxDays);
            rate = r1.mul(r2)/(10**18);
        }
        return; 
        
    }

    uint256 constant public UTC2MYT = 1483200000;

    function wotDay(uint256 time) public pure returns (uint256) {
        return (time - UTC2MYT) / (1 days);
    }

    // minimum fee is 1 unless same day
    function calcFees(uint256 start, uint256 end, uint256 startAmount) public view returns (uint256 amount, uint256 fee) {
        if (startAmount == 0) 
            return;
        uint256 numberOfDays = wotDay(end) - wotDay(start);
        if (numberOfDays == 0) {
            amount = startAmount;
            return;
        }
        amount = (rateForDays(numberOfDays) * startAmount) / (1 ether);
        if ((fee == 0) && (amount != 0)) 
            amount--;
        fee = startAmount.sub(amount);
    }
}


contract Reclaimable is Ownable {
	ERC20Basic constant internal RECLAIM_ETHER = ERC20Basic(0x0);

	function reclaim(ERC20Basic token)
        public
        onlyOwner
    {
        address reclaimer = msg.sender;
        if (token == RECLAIM_ETHER) {
            reclaimer.transfer(this.balance);
        } else {
            uint256 balance = token.balanceOf(this);
            require(token.transfer(reclaimer, balance));
        }
    }
}


// This is primarity used for the migration. Use in the GBT contract is for convenience
contract GBTBasic {

    struct Balance {
        uint256 amount;                 // amount through update or transfer
        uint256 lastUpdated;            // DATE last updated
        uint256 nextAllocationIndex;    // which allocationsOverTime record contains next update
        uint256 allocationShare;        // the share of allocationPool that this holder gets (means they hold HGT)
	}

	/*Creates an array with all balances*/
	mapping (address => Balance) public balances;
	
    struct Allocation { 
        uint256     amount;
        uint256     date;
    }
	
	Allocation[]   public allocationsOverTime;
	Allocation[]   public currentAllocations;

	function currentAllocationLength() view public returns (uint256) {
		return currentAllocations.length;
	}

	function aotLength() view public returns (uint256) {
		return allocationsOverTime.length;
	}
}


contract GoldBackedToken is Ownable, ERC20, Pausable, GBTBasic, Reclaimable {
	using SafeMath for uint;

	function GoldBackedToken(GoldFees feeCalc, GBTBasic _oldToken) public {
		uint delta = 3799997201200178500814753;
		feeCalculator = feeCalc;
        oldToken = _oldToken;
		// now migrate the non balance stuff
		uint x;
		for (x = 0; x < oldToken.aotLength(); x++) {
			Allocation memory al;
			(al.amount, al.date) = oldToken.allocationsOverTime(x);
			allocationsOverTime.push(al);
		}
		allocationsOverTime[3].amount = allocationsOverTime[3].amount.sub(delta);
		for (x = 0; x < oldToken.currentAllocationLength(); x++) {
			(al.amount, al.date) = oldToken.currentAllocations(x);
			al.amount = al.amount.sub(delta);
			currentAllocations.push(al);
		}

		// 1st Minting : TxHash 0x8ba9175d77ed5d3bbf0ddb3666df496d3789da5aa41e46228df91357d9eae8bd
		// amount = 528359800000000000000;
		// date = 1512646845;
		
		// 2nd Minting : TxHash 0xb3ec483dc8cf7dbbe29f4b86bd371702dd0fdaccd91d1b2d57d5e9a18b23d022
		// date = 1513855345;
		// amount = 1003203581831868623088;

		// Get values of first minting at second minting date
		// feeCalc(1512646845,1513855345,528359800000000000000) => (527954627221032516031,405172778967483969)

		mintedGBT.date = 1515700247;
		mintedGBT.amount = 1529313490861692541644;
	}

  function totalSupply() view public returns (uint256) {
	  uint256 minted;
	  uint256 mFees;
	  uint256 uminted;
	  uint256 umFees;
	  uint256 allocated;
	  uint256 aFees;
	  (minted,mFees) = calcFees(mintedGBT.date,now,mintedGBT.amount);
	  (uminted,umFees) = calcFees(unmintedGBT.date,now,unmintedGBT.amount);
	  (allocated,aFees) = calcFees(currentAllocations[0].date,now,currentAllocations[0].amount);
	  if (minted+allocated>uminted) {
	  	return minted.add(allocated).sub(uminted);
	  } else {
		return 0;
	  }
  }

  event Transfer(address indexed from, address indexed to, uint value);
  event Approval(address indexed owner, address indexed spender, uint value);
  event DeductFees(address indexed owner,uint256 amount);

  event TokenMinted(address destination, uint256 amount);
  event TokenBurned(address source, uint256 amount);
  
	string public name = "GOLDX";
	string public symbol = "GOLDX";
	uint256 constant public  decimals = 18;  // same as ETH
	uint256 constant public  hgtDecimals = 8;
		
	uint256 constant public allocationPool = 1 * 10**9 * 10**hgtDecimals;      // total HGT holdings
	uint256	         public	maxAllocation  = 38 * 10**5 * 10**decimals;			// max GBT that can ever ever be given out
	uint256	         public	totAllocation;			// amount of GBT so far
	
	GoldFees		 public feeCalculator;
	address		     public HGT;					// HGT contract address

	function updateMaxAllocation(uint256 newMax) public onlyOwner {
		require(newMax > 38 * 10**5 * 10**decimals);
		maxAllocation = newMax;
	}

	function setFeeCalculator(GoldFees newFC) public onlyOwner {
		feeCalculator = newFC;
	}

	
	// GoldFees needs to take care of Domain Offset - do not do here

	function calcFees(uint256 from, uint256 to, uint256 amount) view public returns (uint256 val, uint256 fee) {
		return feeCalculator.calcFees(from,to,amount);
	}

	
	mapping (address => mapping (address => uint)) public allowance;
    mapping (address => bool) updated;

    GBTBasic oldToken;

	function migrateBalance(address where) public {
		if (!updated[where]) {
            uint256 am;
            uint256 lu;
            uint256 ne;
            uint256 al;
            (am,lu,ne,al) = oldToken.balances(where);
            balances[where] = Balance(am,lu,ne,al);
            updated[where] = true;
        }

	}
	
	function update(address where) internal {
        uint256 pos;
		uint256 fees;
		uint256 val;
		migrateBalance(where);
        (val,fees,pos) = updatedBalance(where);
	    balances[where].nextAllocationIndex = pos;
	    balances[where].amount = val;
        balances[where].lastUpdated = now;
	}
	
	function updatedBalance(address where) view public returns (uint val, uint fees, uint pos) {
		uint256 cVal;
		uint256 cFees;
		uint256 cAmount;

        uint256 am;
        uint256 lu;
        uint256 ne;
        uint256 al;
		Balance memory bb;

		// calculate update of balance in account
        if (updated[where]) {
            bb = balances[where];
            am = bb.amount;
            lu = bb.lastUpdated;
            ne = bb.nextAllocationIndex;
            al = bb.allocationShare;
        } else {
            (am,lu,ne,al) = oldToken.balances(where);
        }
		(val,fees) = calcFees(lu,now,am);
		// calculate update based on accrued disbursals
	    pos = ne;
		if ((pos < currentAllocations.length) && (al != 0)) {
			cAmount = currentAllocations[ne].amount.mul(al).div( allocationPool);
			(cVal,cFees) = calcFees(currentAllocations[ne].date,now,cAmount);
		} 
	    val = val.add(cVal);
		fees = fees.add(cFees);
		pos = currentAllocations.length;
	}

    function balanceOf(address where) view public returns (uint256 val) {
        uint256 fees;
		uint256 pos;
        (val,fees,pos) = updatedBalance(where);
        return ;
    }

	event GoldAllocation(uint256 amount, uint256 date);
	event FeeOnAllocation(uint256 fees, uint256 date);

	event PartComplete();
	event StillToGo(uint numLeft);
	uint256 public partPos;
	uint256 public partFees;
	uint256 partL;
	Allocation[]   public partAllocations;

	function partAllocationLength() view public returns (uint) {
		return partAllocations.length;
	}

	function addAllocationPartOne(uint newAllocation,uint numSteps) 
		public 
		onlyMinter 
	{
		require(partPos == 0);
		uint256 thisAllocation = newAllocation;

		require(totAllocation < maxAllocation);		// cannot allocate more than this;

		if (currentAllocations.length > partAllocations.length) {
			partAllocations = currentAllocations;
		}

		if (totAllocation + thisAllocation > maxAllocation) {
			thisAllocation = maxAllocation.sub(totAllocation);
			log0("max alloc reached");
		}
		totAllocation = totAllocation.add(thisAllocation);

		GoldAllocation(thisAllocation,now);

        Allocation memory newDiv;
        newDiv.amount = thisAllocation;
        newDiv.date = now;
		// store into history
	    allocationsOverTime.push(newDiv);
		// add this record to the end of currentAllocations
		partL = partAllocations.push(newDiv);
		// update all other records with calcs from last record
		if (partAllocations.length < 2) { // no fees to consider
			PartComplete();
			currentAllocations = partAllocations;
			FeeOnAllocation(0,now);
			return;
		}
		//
		// The only fees that need to be collected are the fees on location zero.
		// Since they are the last calculated = they come out with the break
		//
		for (partPos = partAllocations.length - 2; partPos >= 0; partPos-- ) {
			(partAllocations[partPos].amount,partFees) = calcFees(partAllocations[partPos].date,now,partAllocations[partPos].amount);

			partAllocations[partPos].amount = partAllocations[partPos].amount.add(partAllocations[partL - 1].amount);
			partAllocations[partPos].date = now;
			if ((partPos == 0) || (partPos == partAllocations.length-numSteps)) {
				break; 
			}
		}
		if (partPos != 0) {
			StillToGo(partPos);
			return; // not done yet
		}
		PartComplete();
		FeeOnAllocation(partFees,now);
		currentAllocations = partAllocations;
	}

	function addAllocationPartTwo(uint numSteps) 
		public 
		onlyMinter 
	{
		require(numSteps > 0);
		require(partPos > 0);
		for (uint i = 0; i < numSteps; i++ ) {
			partPos--;
			(partAllocations[partPos].amount,partFees) = calcFees(partAllocations[partPos].date,now,partAllocations[partPos].amount);
			partAllocations[partPos].amount = partAllocations[partPos].amount.add(partAllocations[partL - 1].amount);
			partAllocations[partPos].date = now;
			if (partPos == 0) {
				break; 
			}
		}
		if (partPos != 0) {
			StillToGo(partPos);
			return; // not done yet
		}
		PartComplete();
		FeeOnAllocation(partFees,now);
		currentAllocations = partAllocations;
	}

	function setHGT(address _hgt) public onlyOwner {
		HGT = _hgt;
	}

	function parentFees(address where) public whenNotPaused {
		require(msg.sender == HGT);
	    update(where);		
	}
	
	function parentChange(address where, uint newValue) public whenNotPaused { // called when HGT balance changes
		require(msg.sender == HGT);
	    balances[where].allocationShare = newValue;
	}
	
	/* send GBT */
	function transfer(address _to, uint256 _value) public whenNotPaused returns (bool ok) {
		require(_to != address(0));
	    update(msg.sender);              // Do this to ensure sender has enough funds.
		update(_to); 

        balances[msg.sender].amount = balances[msg.sender].amount.sub(_value);
        balances[_to].amount = balances[_to].amount.add(_value);
		Transfer(msg.sender, _to, _value); //Notify anyone listening that this transfer took place
        return true;
	}

	function transferFrom(address _from, address _to, uint _value) public whenNotPaused returns (bool success) {
		require(_to != address(0));
		var _allowance = allowance[_from][msg.sender];

	    update(_from);              // Do this to ensure sender has enough funds.
		update(_to); 

		balances[_to].amount = balances[_to].amount.add(_value);
		balances[_from].amount = balances[_from].amount.sub(_value);
		allowance[_from][msg.sender] = _allowance.sub(_value);
		Transfer(_from, _to, _value);
		return true;
	}

  	function approve(address _spender, uint _value) public whenNotPaused returns (bool success) {
		require((_value == 0) || (allowance[msg.sender][_spender] == 0));
    	allowance[msg.sender][_spender] = _value;
    	Approval(msg.sender, _spender, _value);
    	return true;
  	}

  /**
   * approve should be called when allowed[_spender] == 0. To increment
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   */
  function increaseApproval(address _spender, uint _addedValue) public returns (bool) {
    allowance[msg.sender][_spender] = allowance[msg.sender][_spender].add(_addedValue);
    Approval(msg.sender, _spender, allowance[msg.sender][_spender]);
    return true;
  }

  function decreaseApproval(address _spender, uint _subtractedValue) public returns (bool) {
    uint oldValue = allowance[msg.sender][_spender];
    if (_subtractedValue > oldValue) {
      allowance[msg.sender][_spender] = 0;
    } else {
      allowance[msg.sender][_spender] = oldValue.sub(_subtractedValue);
    }
    Approval(msg.sender, _spender, allowance[msg.sender][_spender]);
    return true;
  }

  	function allowance(address _owner, address _spender) public view returns (uint remaining) {
    	return allowance[_owner][_spender];
  	}

	// Minting Functions 
	address public authorisedMinter;

	function setMinter(address minter) public onlyOwner {
		authorisedMinter = minter;
	}

	modifier onlyMinter() {
		require(msg.sender == authorisedMinter);
		_;
	}

	Allocation public mintedGBT;		// minting adds to this one
	Allocation public unmintedGBT;		// allocating adds here, burning takes from here if minted is empty
	
	function mintTokens(address destination, uint256 amount) 
		onlyMinter
		public 
	{
		require(msg.sender == authorisedMinter);
		update(destination);
		balances[destination].amount = balances[destination].amount.add(amount);
		TokenMinted(destination,amount);
		Transfer(0x0,destination,amount); // ERC20 compliance
		//
		// TotalAllocation stuff
		//
		uint256 fees;
		(mintedGBT.amount,fees) = calcFees(mintedGBT.date,now,mintedGBT.amount);
		mintedGBT.amount = mintedGBT.amount.add(amount);
		mintedGBT.date = now;
	}

	function burnTokens(address source, uint256 amount) 
		onlyMinter
		public 
	{
		update(source);
		balances[source].amount = balances[source].amount.sub(amount);
		TokenBurned(source,amount);
		Transfer(source,0x0,amount); // ERC20 compliance
		//
		// TotalAllocation stuff
		//
		uint256 fees;
		(unmintedGBT.amount,fees) = calcFees(unmintedGBT.date,now,unmintedGBT.amount);
		unmintedGBT.date = now;
		unmintedGBT.amount = unmintedGBT.amount.add(amount);
	}

}