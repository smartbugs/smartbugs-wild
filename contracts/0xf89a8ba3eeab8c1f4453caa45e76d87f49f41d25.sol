pragma solidity ^0.4.18;

/**
 * Followine Token (WINE). More info www.followine.io
 */

 contract Ownable {
   address public owner;
 
   event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
 
   /**
    * @dev The Ownable constructor sets the original `owner` of the contract to the sender
    * account.
    */
   constructor() internal {
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
   function transferOwnership(address newOwner) onlyOwner public {
     require(newOwner != address(0));
     emit OwnershipTransferred(owner, newOwner);
     owner = newOwner;
   }
 }

 contract Authorizable is Ownable {
   mapping(address => bool) public authorized;
   mapping(address => bool) public blocked;

   event AuthorizationSet(address indexed addressAuthorized, bool indexed authorization);

   /**
    * @dev The Authorizable constructor sets the first `authorized` of the contract to the sender
    * account.
    */
   constructor() public {
 	authorized[msg.sender] = true;
   }

   /**
    * @dev Throws if called by any account other than the authorized.
    */
   modifier onlyAuthorized() {
     require(authorized[msg.sender]);
     _;
   }

  /**
    * @dev Allows the current owner to set an authorization.
    * @param addressAuthorized The address to change authorization.
    */
   function setAuthorized(address addressAuthorized, bool authorization) onlyOwner public {
     emit AuthorizationSet(addressAuthorized, authorization);
     authorized[addressAuthorized] = authorization;
   }

   function setBlocked(address addressAuthorized, bool authorization) onlyOwner public {
     blocked[addressAuthorized] = authorization;
   }

 }

contract Startable is Ownable, Authorizable {
  event Start();
  event StopV();

  bool public started = false;

  /**
   * @dev Modifier to make a function callable only when the contract is started.
   */
  modifier whenStarted() {
	require( (started || authorized[msg.sender]) && !blocked[msg.sender] );
    _;
  }

  /**
   * @dev called by the owner to start, go to normal state
   */
  function start() onlyOwner public {
    started = true;
    emit Start();
  }

  function stop() onlyOwner public {
    started = false;
    emit StopV();
  }

}
contract ERC20Basic {
  uint256 public totalSupply;
  function balanceOf(address who) public constant returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}

contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender) public constant returns (uint256);
  function transferFrom(address from, address to, uint256 value) public returns (bool);
  function approve(address spender, uint256 value) public returns (bool);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}
contract BasicToken is ERC20Basic {
  using SafeMath for uint256;

  mapping(address => uint256) balances;

  /**
  * @dev transfer token from an address to another specified address
  * @param _sender The address to transfer from.
  * @param _to The address to transfer to.
  * @param _value The amount to be transferred.
  */
  function transferFunction(address _sender, address _to, uint256 _value) internal returns (bool) {
    require(_to != address(0));
    require(_to != address(this));
    require(_value <= balances[_sender]);

    // SafeMath.sub will throw if there is not enough balance.
    balances[_sender] = balances[_sender].sub(_value);
    balances[_to] = balances[_to].add(_value);
    emit Transfer(_sender, _to, _value);
    return true;
  }

  /**
  * @dev transfer token for a specified address (BasicToken transfer method)
  */
  function transfer(address _to, uint256 _value) public returns (bool) {
	return transferFunction(msg.sender, _to, _value);
  }

  /**
  * @dev Gets the balance of the specified address.
  * @param _owner The address to query the the balance of.
  * @return An uint256 representing the amount owned by the passed address.
  */
  function balanceOf(address _owner) public constant returns (uint256 balance) {
    return balances[_owner];
  }
}
contract StandardToken is ERC20, BasicToken {

  mapping (address => mapping (address => uint256)) internal allowed;


  /**
   * @dev Transfer tokens from one address to another
   * @param _from address The address which you want to send tokens from
   * @param _to address The address which you want to transfer to
   * @param _value uint256 the amount of tokens to be transferred
   */
  function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));
    require(_to != address(this));
    require(_value <= balances[_from]);
    require(_value <= allowed[_from][msg.sender]);

    balances[_from] = balances[_from].sub(_value);
    balances[_to] = balances[_to].add(_value);
    allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
    emit Transfer(_from, _to, _value);
    return true;
  }

  /**
   * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.
   *
   * Beware that changing an allowance with this method brings the risk that someone may use both the old
   * and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this
   * race condition is to first reduce the spender's allowance to 0 and set the desired value afterwards:
   * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
   * @param _spender The address which will spend the funds.
   * @param _value The amount of tokens to be spent.
   */
  function approve(address _spender, uint256 _value) public returns (bool) {
    allowed[msg.sender][_spender] = _value;
    emit Approval(msg.sender, _spender, _value);
    return true;
  }

  /**
   * @dev Function to check the amount of tokens that an owner allowed to a spender.
   * @param _owner address The address which owns the funds.
   * @param _spender address The address which will spend the funds.
   * @return A uint256 specifying the amount of tokens still available for the spender.
   */
  function allowance(address _owner, address _spender) public constant returns (uint256 remaining) {
    return allowed[_owner][_spender];
  }

  /**
   * approve should be called when allowed[_spender] == 0. To increment
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   */
  function increaseApproval (address _spender, uint _addedValue) public returns (bool success) {
    allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

  function decreaseApproval (address _spender, uint _subtractedValue) public returns (bool success) {
    uint oldValue = allowed[msg.sender][_spender];
    if (_subtractedValue > oldValue) {
      allowed[msg.sender][_spender] = 0;
    } else {
      allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
    }
    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

}

contract StartToken is Startable, StandardToken {
    struct Pay{
        uint256 date;
        uint256 value;
        uint256 category;
    }

    mapping( address => Pay[] ) log;

    mapping( address => uint256) transferredCoin;


  function addLog(address id, uint256 _x, uint256 _y, uint256 _z) internal {
        log[id].push(Pay(_x,_y,_z));
  }

  function addTransferredCoin(address id, uint256 _x) private {
        transferredCoin[id] = transferredCoin[id] + _x;
  }

  function getFreeCoin(address field) private view returns (uint256){
        uint arrayLength = log[field].length;
        uint256 totalValue = 0;
        for (uint i=0; i<arrayLength; i++) {
            uint256 date = log[field][i].date;
            uint256 value = log[field][i].value;
            uint256 category = log[field][i].category;
            // category = 1 acquisto private sale
            // category = 2 acquisto pre-ico
            // category = 3 acquisto ico
            // category = 4 acquisto bounty
            // category = 5 acquisto airdrop
            // category = 6 acquisto team
            // category = 7 acquisto advisor
            // category = 8 fondi bloccati per le aziende
            if( category == 1 || category == 2 ){
                if( (date + 750 days) <= now ){
                    totalValue += value;
                }else if( (date + 510 days) <= now ){
                    totalValue += value.mul(60).div(100);
                }else if( (date + 390 days) <= now ){
                    totalValue += value.mul(30).div(100);
                }
            }
            if( category == 3 ){
                if( (date + 690 days) <= now ){
                    totalValue += value;
                }else if( (date + 480 days) <= now ){
                    totalValue += value.mul(60).div(100);
                }else if( (date + 300 days) <= now ){
                    totalValue += value.mul(30).div(100);
                }
            }
            if( category == 4 || category == 5 ){
                if( (date + 720 days) <= now ){
                    totalValue += value;
                }else if( (date + 540 days) <= now ){
                    totalValue += value.mul(75).div(100);
                }else if( (date + 360 days) <= now ){
                    totalValue += value.mul(50).div(100);
                }
            }
            if( category == 6 ){
                if( (date + 1020 days) <= now ){
                    totalValue += value;
                }else if( (date + 810 days) <= now ){
                    totalValue += value.mul(70).div(100);
                }else if( (date + 630 days) <= now ){
                    totalValue += value.mul(40).div(100);
                }else if( (date + 450 days) <= now ){
                    totalValue += value.mul(20).div(100);
                }
            }
            if( category == 7 ){
                if( (date + 810 days) <= now ){
                    totalValue += value;
                }else if( (date + 600 days) <= now ){
                    totalValue += value.mul(80).div(100);
                }else if( (date + 420 days) <= now ){
                    totalValue += value.mul(40).div(100);
                }
            }
            if( category == 8 ){
                uint256 numOfMonths = now.sub(date).div(60).div(60).div(24).div(30).div(6);
                if( numOfMonths > 20 ){
                    numOfMonths = 20;
                }
                uint256 perc = 5;
                totalValue += value.mul((perc.mul(numOfMonths))).div(100);
            }
            if( category == 0 ){
                totalValue += value;
            }
        }
        totalValue = totalValue - transferredCoin[field];
        return totalValue;
  }

  function deleteCoin(address field,uint256 val) internal {
        uint arrayLength = log[field].length;
        for (uint i=0; i<arrayLength; i++) {
            uint256 value = log[field][i].value;
            if( value >= val ){
                log[field][i].value = value - val;
                break;
            }else{
                val = val - value;
                log[field][i].value = 0;
            }
        }
  }

  function getMyFreeCoin(address _addr) public constant returns(uint256) {
      return getFreeCoin(_addr);
  }

  function transfer(address _to, uint256 _value) public whenStarted returns (bool) {
        if( getFreeCoin(msg.sender) >= _value ){
            if( super.transfer(_to, _value) ){
                addLog(_to,now,_value,0);
                addTransferredCoin(msg.sender,_value);
                return true;
            }else{
                return false;
            }
        }
  }


  function transferCustom(address _to, uint256 _value, uint256 _cat) onlyOwner whenStarted public returns(bool success) {
	    addLog(_to,now,_value,_cat);
	    return super.transfer(_to, _value);
  }

  function transferFrom(address _from, address _to, uint256 _value) public whenStarted returns (bool) {
        if( getFreeCoin(_from) >= _value ){
            if( super.transferFrom(_from, _to, _value) ){
                addLog(_to,now,_value,0);
                addTransferredCoin(_from,_value);
                return true;
            }else{
                return false;
            }
        }
  }

  function approve(address _spender, uint256 _value) public whenStarted returns (bool) {
      if( getFreeCoin(msg.sender) >= _value ){
          return super.approve(_spender, _value);
      }else{
          revert();
      }
  }

  function increaseApproval(address _spender, uint _addedValue) public whenStarted returns (bool success) {
      if( getFreeCoin(msg.sender) >= allowed[msg.sender][_spender].add(_addedValue) ){
          return super.increaseApproval(_spender, _addedValue);
      }
  }

  function decreaseApproval(address _spender, uint _subtractedValue) public whenStarted returns (bool success) {
    return super.decreaseApproval(_spender, _subtractedValue);
  }

}

contract HumanStandardToken is StandardToken, StartToken {
    /* Approves and then calls the receiving contract */
    function approveAndCall(address _spender, uint256 _value, bytes _extraData) public returns (bool success) {
        approve(_spender, _value);
        require(_spender.call(bytes4(keccak256("receiveApproval(address,uint256,bytes)")), msg.sender, _value, _extraData));
        return true;
    }
}

contract BurnToken is StandardToken, StartToken {

    event Burn(address indexed burner, uint256 value);

    /**
     * @dev Function to burn tokens.
     * @param _burner The address of token holder.
     * @param _value The amount of token to be burned.
     */
    function burnFunction(address _burner, uint256 _value) internal returns (bool) {
        require(_value > 0);
		require(_value <= balances[_burner]);
        // no need to require value <= totalSupply, since that would imply the
        // sender's balance is greater than the totalSupply, which *should* be an assertion failure

        balances[_burner] = balances[_burner].sub(_value);
        totalSupply = totalSupply.sub(_value);
        emit Burn(_burner, _value);
        if( _burner != tx.origin ){
            deleteCoin(_burner,_value);
        }
		return true;
    }

    /**
     * @dev Burns a specific amount of tokens.
     * @param _value The amount of token to be burned.
     */
	function burn(uint256 _value) public returns(bool) {
        return burnFunction(msg.sender, _value);
    }

	/**
	* @dev Burns tokens from one address
	* @param _from address The address which you want to burn tokens from
	* @param _value uint256 the amount of tokens to be burned
	*/
	function burnFrom(address _from, uint256 _value) public returns (bool) {
		require(_value <= allowed[_from][msg.sender]); // check if it has the budget allowed
		burnFunction(_from, _value);
		allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
		return true;
	}
}

contract OriginToken is Authorizable, BasicToken, BurnToken {

    /**
     * @dev transfer token from tx.orgin to a specified address (onlyAuthorized contract)
     */
    function originTransfer(address _to, uint256 _value) onlyAuthorized public returns (bool) {
	    return transferFunction(tx.origin, _to, _value);
    }

    /**
     * @dev Burns a specific amount of tokens from tx.orgin. (onlyAuthorized contract)
     * @param _value The amount of token to be burned.
     */
	function originBurn(uint256 _value) onlyAuthorized public returns(bool) {
        return burnFunction(tx.origin, _value);
    }
}

contract InterfaceProposal {
	uint256 public proposalNumber;
  	string public proposal;
  	bool public ongoingProposal;
  	bool public investorWithdraw;
  	mapping (uint256 => proposals) registry;

  	event TapRaise(address,uint256,uint256,string);
	event CustomVote(address,uint256,uint256,string);
  	event Destruct(address,uint256,uint256,string);

  	struct proposals {
		address proposalSetter;
   		uint256 votingStart;
   		uint256 votingEnd;
   		string proposalName;
		bool proposalResult;
		uint256 proposalType;
	}

	function _setRaiseProposal() internal;
	function _setCustomVote(string _custom, uint256 _tt) internal;
  	function _setDestructProposal() internal;
   	function _startProposal(string _proposal, uint256 _proposalType) internal;
}

library SafeMath {
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a * b;
    assert(a == 0 || c / a == b);
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

contract VoterInterface {
  	uint256 public TotalAgreeVotes;
  	uint256 public TotalDisagreeVotes;
  	mapping (uint256 => mapping(address => bool)) VoteCast;

  	function _Vote(bool _vote) internal;
  	function _tallyVotes() internal returns (bool);
}

contract proposal is InterfaceProposal, BasicToken {
	using SafeMath for uint256;

	modifier noCurrentProposal {
    	require(!ongoingProposal);
      	require(balanceOf(msg.sender) >= 1000000); //1000 token
      	_;
  	}
  	modifier currentProposal {
      	require(ongoingProposal);
      	require(registry[proposalNumber].votingEnd > block.timestamp);
	    _;
  	}
	// Proposal to raise Tap
  	function _setRaiseProposal() internal noCurrentProposal {
		_startProposal("Raise",2);
      	emit TapRaise(msg.sender, registry[proposalNumber].votingStart, registry[proposalNumber].votingEnd,"Vote To Raise Tap");
  	}

	function _setCustomVote(string _custom, uint256 _tt) internal noCurrentProposal {
		_startProposal(_custom,_tt);
      	emit CustomVote(msg.sender, registry[proposalNumber].votingStart, registry[proposalNumber].votingEnd,_custom);
  	}

	// Proposal to destroy the DAICO
  	function _setDestructProposal() internal noCurrentProposal {
		_startProposal("Destruct",1);
      	emit Destruct(msg.sender, registry[proposalNumber].votingStart, registry[proposalNumber].votingEnd,"Vote To destruct DAICO and return funds");
  	}

   	function _startProposal(string _proposal, uint256 _proposalType) internal {
    	ongoingProposal = true;
      	proposalNumber = proposalNumber.add(1);
      	registry[proposalNumber].votingStart = block.timestamp;
		registry[proposalNumber].proposalSetter = msg.sender;
		registry[proposalNumber].proposalName = _proposal;
      	registry[proposalNumber].votingEnd = block.timestamp.add(1296000);
		registry[proposalNumber].proposalType = _proposalType;
      	proposal = _proposal;
  	}

}

contract Voter is VoterInterface , proposal {

	modifier alreadyVoted {
        require(!VoteCast[proposalNumber][msg.sender]);
        _;
    }

    function _Vote(bool _vote) internal alreadyVoted {
		VoteCast[proposalNumber][msg.sender] = true;

		if (_vote) {
        	TotalAgreeVotes += 1;
       	}else{
        	TotalDisagreeVotes += 1;
       	}
	}
   	function _tallyVotes() internal returns(bool) {
       	if( TotalAgreeVotes > TotalDisagreeVotes ) {
           return true;
       	}else{
           return false;
       	}
	}
}

contract FiatContract {
    function ETH(uint _id) public constant returns (uint256);
  	function EUR(uint _id) public constant returns (uint256);
  	function updatedAt(uint _id) public constant returns (uint);
}

contract WINE is StandardToken, StartToken, HumanStandardToken, BurnToken, OriginToken, Voter {

	using SafeMath for uint256;

	event Withdraw(uint256 amountWei, uint256 timestamp);

	struct refund {
		uint256 date;
		uint256 etherReceived;
		uint256 token;
		uint256 refunded;
        uint256 euro;
	}

    struct burnoutStruct {
        address add;
		uint256 date;
		string email;
		uint256 token;
	}

    uint8 public decimals = 3;

    string public name = "WineCoin";

    string public symbol = "WINE";

    uint256 public initialSupply;

	mapping (address => uint256) icoLog;
	mapping (address => refund[]) refundLog;
    burnoutStruct[] internal burnoutLog;

	uint256 internal firstSale = 5000000 * 10 ** uint(decimals);
	uint256 internal preICO = 10000000 * 10 ** uint(decimals);
	uint256 internal ICO = 120000000 * 10 ** uint(decimals);
	uint256 internal ICOFinal = 0;
	uint256 internal maxICOToken = 5000000 * 10 ** uint(decimals);

	uint256 internal firstSaleStart = 1543662000;
	uint256 internal firstSaleEnd = 1546300799;

	uint256 internal preICOStart = 1546300800;
	uint256 internal preICOEnd = 1548979199;

	uint256 internal ICOStep1 = 1548979200;
    uint256 internal ICOStep1E = 1549583999;
	uint256 internal ICOStep2 = 1549584000;
    uint256 internal ICOStep2E = 1550188799;
	uint256 internal ICOStep3 = 1550188800;
    uint256 internal ICOStep3E = 1550793599;
	uint256 internal ICOStep4 = 1550793600;
    uint256 internal ICOStep4E = 1551311999;
	uint256 internal ICOStepEnd = 1551312000;
	uint256 internal ICOEnd = 1553817599;

	uint256 internal tap = 192901234567901; // 500 ether al mese (wei/sec)
	uint256 internal tempTap = 0;
	uint256 internal constant secondWithdrawTime = 1567296000;
	uint256 internal lastWithdrawTime = secondWithdrawTime;
	uint256 internal firstWithdrawA = 0;
	address internal teamWallet = 0xb14F4c380BFF211222c18F026F3b1395F8e36F2F;
	uint256 internal softCap = 1000000; // un milione di euro
    uint256 internal hardCap = 12000000; // dodici milioni di euro
    uint256 internal withdrawPrice = 0;
    uint256 internal investorToken = 0;
    bool internal burnoutActive = false;
    mapping (address => uint256) investorLogToken;
    uint256 public totalEarned = 0; // totale ricevuto in euro
    uint256 public totalBitcoinReceived = 0;

    FiatContract internal price;

    modifier isValidTokenHolder {
    	require(balanceOf(msg.sender) > 1000 * 10 ** uint(decimals)); //1000 token
      	require(VoteCast[proposalNumber][msg.sender] == false);
      	_;
  	}

    constructor() public {
        totalSupply = 250000000 * 10 ** uint(decimals);

        initialSupply = totalSupply;

        balances[msg.sender] = totalSupply;

        price = FiatContract(0x8055d0504666e2B6942BeB8D6014c964658Ca591);
    }

    function TokenToSend(uint256 received, uint256 cost) internal returns (uint256) {
        uint256 ethCent = price.EUR(0);
        uint256 tokenToSendT = (received * 10 ** uint(decimals)).div(ethCent.mul(cost));
        uint256 tokenToSendTC = received.div(ethCent.mul(cost));
        require( tokenToSendTC.mul(cost).div(100) >= 90 );
        require( totalEarned.add(tokenToSendTC.mul(cost).div(100)) <= hardCap );
        totalEarned = totalEarned.add(tokenToSendTC.mul(cost).div(100));
        return tokenToSendT;
    }

	function addLogRefund(address id, uint256 _x, uint256 _y, uint256 _z, uint256 _p) internal {
        refundLog[id].push(refund(_x,_y,_z,0,_p));
    }

    function addLogBurnout(address id, uint256 _x, string _y, uint256 _z) internal {
        burnoutLog.push(burnoutStruct(id,_x,_y,_z));
    }

    function() public payable {
		uint256 am = msg.value;
		if( now >= firstSaleStart && now <= firstSaleEnd ){
	        uint256 token = TokenToSend(am,3);
			if( token <= firstSale ){
		        addLog(msg.sender,now,token,1);
		        transferFunction(owner,msg.sender, token);
				firstSale = firstSale.sub(token);
                investorToken = investorToken.add(token);
                investorLogToken[msg.sender] = investorLogToken[msg.sender].add(token);
                uint256 tm = token / 10 ** uint256(decimals);
				addLogRefund(msg.sender, now, am, token, tm.mul(3).div(100) );
			}else{
				revert();
			}
		}else if( now >= preICOStart && now <= preICOEnd ){
	        uint256 token1 = TokenToSend(am,4);
			if( token1 <= preICO ){
		        addLog(msg.sender,now,token1,2);
		        transferFunction(owner,msg.sender, token1);
                investorToken = investorToken.add(token1);
                investorLogToken[msg.sender] = investorLogToken[msg.sender].add(token1);
				preICO = preICO.sub(token1);
				addLogRefund(msg.sender, now, am, token1, (token1 / 10 ** uint(decimals)).mul(4).div(100));
			}else{
				revert();
			}
		}else if( now >= ICOStep1 && now <= ICOStep1E ){
	        uint256 token2 = TokenToSend(am,5);
			if( ( icoLog[msg.sender].add(token2) ) <= maxICOToken && token2 <= ICO ){
				icoLog[msg.sender] = icoLog[msg.sender].add(token2);
		        addLog(msg.sender,now,token2,3);
		        transferFunction(owner,msg.sender, token2);
                investorToken = investorToken.add(token2);
                investorLogToken[msg.sender] = investorLogToken[msg.sender].add(token2);
				ICO = ICO.sub(token2);
				addLogRefund(msg.sender, now, am, token2, (token2 / 10 ** uint(decimals)).mul(5).div(100));
			}else{
				revert();
			}
		}else if( now >= ICOStep2 && now <= ICOStep2E ){
	        uint256 token3 = TokenToSend(am,6);
			if( ( icoLog[msg.sender].add(token3) ) <= maxICOToken && token3 <= ICO ){
				icoLog[msg.sender] = icoLog[msg.sender].add(token3);
		        addLog(msg.sender,now,token3,3);
		        transferFunction(owner,msg.sender, token3);
                investorToken = investorToken.add(token3);
                investorLogToken[msg.sender] = investorLogToken[msg.sender].add(token3);
				ICO = ICO.sub(token3);
				addLogRefund(msg.sender, now, am, token3, (token3 / 10 ** uint(decimals)).mul(6).div(100));
			}else{
				revert();
			}
		}else if( now >= ICOStep3 && now <= ICOStep3E ){
	        uint256 token4 = TokenToSend(am,7);
			if( ( icoLog[msg.sender].add(token4) ) <= maxICOToken && token4 <= ICO ){
				icoLog[msg.sender] = icoLog[msg.sender].add(token4);
		        addLog(msg.sender,now,token4,3);
		        transferFunction(owner,msg.sender, token4);
                investorToken = investorToken.add(token4);
                investorLogToken[msg.sender] = investorLogToken[msg.sender].add(token4);
				ICO = ICO.sub(token4);
				addLogRefund(msg.sender, now, am, token4, (token4 / 10 ** uint(decimals)).mul(7).div(100));
			}else{
				revert();
			}
		}else if( now >= ICOStep4 && now <= ICOStep4E ){
	        uint256 token5 = TokenToSend(am,8);
			if( ( icoLog[msg.sender].add(token5) ) <= maxICOToken && token5 <= ICO ){
				icoLog[msg.sender] = icoLog[msg.sender].add(token5);
		        addLog(msg.sender,now,token5,3);
		        transferFunction(owner,msg.sender, token5);
                investorToken = investorToken.add(token5);
                investorLogToken[msg.sender] = investorLogToken[msg.sender].add(token5);
				ICO = ICO.sub(token5);
				addLogRefund(msg.sender, now, am, token5, (token5 / 10 ** uint(decimals)).mul(8).div(100));
			}else{
				revert();
			}
		}else if( now >= ICOStepEnd && now <= ICOEnd ){
	        uint256 token6 = TokenToSend(am,10);
            if( ICOFinal <= 0 ){
                ICOFinal = firstSale.add(preICO).add(ICO);
                firstSale = 0;
                preICO = 0;
                ICO = 0;
            }
			if( ( icoLog[msg.sender].add(token6) ) <= maxICOToken && token6 <= ICOFinal ){
				icoLog[msg.sender] = icoLog[msg.sender].add(token6);
		        addLog(msg.sender,now,token6,3);
		        transferFunction(owner,msg.sender, token6);
				ICOFinal = ICOFinal.sub(token6);
                investorToken = investorToken.add(token6);
                investorLogToken[msg.sender] = investorLogToken[msg.sender].add(token6);
				addLogRefund(msg.sender, now, am, token6, (token6 / 10 ** uint(decimals)).mul(10).div(100));
			}else{
				revert();
			}
		}else{
			revert();
		}
    }

	function firstWithdraw() public onlyOwner {
        require(!investorWithdraw);
        require(firstWithdrawA == 0);
		require(now >= ICOEnd);
        require(totalEarned >= softCap);
        uint256 softCapInEther = ((price.EUR(0)).mul(100)).mul(softCap);
        uint256 amount = softCapInEther.div(2);
        if( amount > address(this).balance ){
            amount = address(this).balance;
        }
        firstWithdrawA = 1;
        teamWallet.transfer(amount);
        uint256 amBlocked = 62500000 * 10 ** uint(decimals);
        amBlocked = amBlocked.add(ICOFinal);
        ICOFinal = 0;
        addLog(teamWallet,now,amBlocked,8);
        transferFunction(owner,teamWallet,amBlocked);
        emit Withdraw(amount, now);
    }

	function calcTapAmount() internal view returns(uint256) {
        uint256 amount = now.sub(lastWithdrawTime).mul(tap);
        if(address(this).balance < amount) {
            amount = address(this).balance;
        }
        return amount;
    }

	function withdraw() public onlyOwner {
        require(!investorWithdraw);
        require(firstWithdrawA == 1);
		require(now >= secondWithdrawTime);
        uint256 amount = calcTapAmount();
        lastWithdrawTime = now;
        teamWallet.transfer(amount);
        emit Withdraw(amount, now);
    }

	function _modTapProposal(uint256 _tap) public {
        require(now >= ICOEnd);
        TotalAgreeVotes = 0;
	  	TotalDisagreeVotes = 0;
    	_setRaiseProposal();
    	tempTap = _tap;
	}
	function Armageddon() public {
        require(now >= ICOEnd);
        TotalAgreeVotes = 0;
	  	TotalDisagreeVotes = 0;
    	_setDestructProposal();
	}
	function _customProposal(string _proposal,uint256 _typeProposal) public onlyOwner { // impostare il _typeProposal a 3 per la funzione burnout, impostare a zero per le altre proposte
        require(now >= ICOEnd);
        TotalAgreeVotes = 0;
	  	TotalDisagreeVotes = 0;
    	_setCustomVote(_proposal,_typeProposal);
	}

	function _ProposalVote(bool _vote) public currentProposal isValidTokenHolder {
    	_Vote(_vote);
	}

	function _tallyingVotes() public {
    	require(now > registry[proposalNumber].votingEnd);
    	bool result = _tallyVotes();
        registry[proposalNumber].proposalResult = result;
    	_afterVoteAction(result);
	}

	function _afterVoteAction(bool result) internal {
    	if(result && registry[proposalNumber].proposalType == 2 ) {
        	tap = tempTap;
            tempTap = 0;
          	ongoingProposal = false;
    	}else if (result && registry[proposalNumber].proposalType == 1 ) {
        	investorWithdraw = true;
            withdrawPrice = address(this).balance / investorToken;
        	ongoingProposal = false;
    	}else if (result && registry[proposalNumber].proposalType == 3 ) {
			burnoutActive = true;
        	ongoingProposal = false;
    	}else{
        	ongoingProposal = false;
    	}
	}

    function burnout(string email) public {
        require(burnoutActive);
        uint256 val = balanceOf(msg.sender);
        burn(val);
        addLogBurnout(msg.sender, now, email, val);
    }

    function getBurnout(uint256 id) public onlyOwner constant returns (string __email, uint256 __val, address __add, uint256 __date) {
        return (burnoutLog[id].email, burnoutLog[id].token, burnoutLog[id].add, burnoutLog[id].date);
    }

    function refundEther(uint _amountP) public {
        require(balanceOf(msg.sender) >= _amountP);
        if( investorWithdraw == true ){
            if( investorLogToken[msg.sender] >= _amountP ){
                investorLogToken[msg.sender] = investorLogToken[msg.sender].sub(_amountP);
                burn(_amountP);
                uint256 revenue = _amountP * withdrawPrice;
                msg.sender.transfer(revenue);
            }else{
                revert();
            }
        }else{
            uint256 refundable = 0;
            uint256 arrayLength = refundLog[msg.sender].length;
            for (uint256 e=0; e<arrayLength; e++){
                if( now <= (refundLog[msg.sender][e].date).add(1296000) ){
                    if( refundLog[msg.sender][e].refunded == 0 ){
                        refundable = refundable.add(refundLog[msg.sender][e].token);
                    }
                }
            }
            if( refundable >= _amountP ){
                balances[owner] += _amountP;
                balances[msg.sender] -= _amountP;
                uint256 amountPrev = _amountP;
                for (uint256 i=0; i<arrayLength; i++){
                    if( now <= (refundLog[msg.sender][i].date).add(1296000) ){
                        if( refundLog[msg.sender][i].refunded == 0 ){
                            if( refundLog[msg.sender][i].token > amountPrev ){
                                uint256 ethTT = refundLog[msg.sender][i].token / 10 ** uint(decimals);
                                uint256 ethT = (refundLog[msg.sender][i].etherReceived).div(ethTT * 10 ** uint(decimals));
                                msg.sender.transfer(ethT.mul(amountPrev).sub(1 wei));
                                refundLog[msg.sender][i].etherReceived = (refundLog[msg.sender][i].etherReceived).sub(ethT.mul(amountPrev).sub(1 wei));
                                refundLog[msg.sender][i].token = (refundLog[msg.sender][i].token).sub(amountPrev);
                                investorLogToken[msg.sender] = investorLogToken[msg.sender].sub(amountPrev);
                                amountPrev = 0;
                                break;
                            }else{
                                msg.sender.transfer(refundLog[msg.sender][i].etherReceived);
                                refundLog[msg.sender][i].refunded = 1;
                                amountPrev = amountPrev.sub(refundLog[msg.sender][i].token);
                                totalEarned = totalEarned.sub(refundLog[msg.sender][i].euro);
                                investorLogToken[msg.sender] = investorLogToken[msg.sender].sub(amountPrev);
                            }
                        }
                    }
                }
                emit Transfer(msg.sender, this, _amountP);
            }else{
                revert();
            }
        }
    }

    function addBitcoin(uint256 btc, uint256 eur) public onlyOwner {
        totalBitcoinReceived = totalBitcoinReceived.add(btc);
        totalEarned = totalEarned.add(eur);
    }

    function removeBitcoin(uint256 btc, uint256 eur) public onlyOwner {
        totalBitcoinReceived = totalBitcoinReceived.sub(btc);
        totalEarned = totalEarned.sub(eur);
    }

    function historyOfProposal(uint256 _id) public constant returns (string _name, bool _result) {
        return (registry[_id].proposalName, registry[_id].proposalResult);
    }

}