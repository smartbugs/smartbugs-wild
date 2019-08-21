/**
 * @title METTA platform token & preICO crowdsale implementasion
 * @author Maxim Akimov - <devstylesoftware@gmail.com>
 * @author Dmitrii Bykov - <bykoffdn@gmail.com>
 */

pragma solidity ^0.4.15;

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {
    
	function mul(uint256 a, uint256 b) internal constant returns (uint256) {
		uint256 c = a * b;
		assert(a == 0 || c / a == b);
		return c;
	}

	function div(uint256 a, uint256 b) internal constant returns (uint256) {
		// assert(b > 0); // Solidity automatically throws when dividing by 0
		uint256 c = a / b;
		// assert(a == b * c + a % b); // There is no case in which this doesn't hold
		return c;
	}

	function sub(uint256 a, uint256 b) internal constant returns (uint256) {
		assert(b <= a);
		return a - b;
	}

	function add(uint256 a, uint256 b) internal constant returns (uint256) {
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
	uint256 public totalSupply;
	function balanceOf(address who) constant returns (uint256);
	function transfer(address to, uint256 value) returns (bool);
	event Transfer(address indexed from, address indexed to, uint256 value);
}

/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20 is ERC20Basic {
	function allowance(address owner, address spender) constant returns (uint256);
	function transferFrom(address from, address to, uint256 value) returns (bool);
	function approve(address spender, uint256 value) returns (bool);
	event Approval(address indexed owner, address indexed spender, uint256 value);
}

/**
 * @title Basic token
 * @dev Basic version of StandardToken, with no allowances. 
 */
contract BasicToken is ERC20Basic {
    
	using SafeMath for uint256;

	mapping(address => uint256) balances;

	/**
	* @dev transfer token for a specified address
	* @param _to The address to transfer to.
	* @param _value The amount to be transferred.
	*/
	function transfer(address _to, uint256 _value) returns (bool) {
		balances[msg.sender] = balances[msg.sender].sub(_value);
		balances[_to] = balances[_to].add(_value);
		Transfer(msg.sender, _to, _value);
		return true;
	}

	/**
	* @dev Gets the balance of the specified address.
	* @param _owner The address to query the the balance of. 
	* @return An uint256 representing the amount owned by the passed address.
	*/
	function balanceOf(address _owner) constant returns (uint256 balance) {
		return balances[_owner];
	}

}

/**
 * @title Standard ERC20 token
 * @dev Implementation of the basic standard token.
 * @dev https://github.com/ethereum/EIPs/issues/20
 * @dev Based on code by FirstBlood: https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol
 */
contract StandardToken is ERC20, BasicToken {

	mapping (address => mapping (address => uint256)) allowed;

	/**
	* @dev Transfer tokens from one address to another
	* @param _from address The address which you want to send tokens from
	* @param _to address The address which you want to transfer to
	* @param _value uint256 the amout of tokens to be transfered
	*/
	function transferFrom(address _from, address _to, uint256 _value) returns (bool) {
	  
		var _allowance = allowed[_from][msg.sender];

		// Check is not needed because sub(_allowance, _value) will already throw if this condition is not met
		// require (_value <= _allowance);

		balances[_to] = balances[_to].add(_value);
		balances[_from] = balances[_from].sub(_value);
		allowed[_from][msg.sender] = _allowance.sub(_value);
		Transfer(_from, _to, _value);
		return true;
	}

	/**
	* @dev Aprove the passed address to spend the specified amount of tokens on behalf of msg.sender.
	* @param _spender The address which will spend the funds.
	* @param _value The amount of tokens to be spent.
	*/
	function approve(address _spender, uint256 _value) returns (bool) {

		// To change the approve amount you first have to reduce the addresses`
		//  allowance to zero by calling `approve(_spender, 0)` if it is not
		//  already 0 to mitigate the race condition described here:
		//  https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
		require((_value == 0) || (allowed[msg.sender][_spender] == 0));

		allowed[msg.sender][_spender] = _value;
		Approval(msg.sender, _spender, _value);
		return true;
	}

	/**
	* @dev Function to check the amount of tokens that an owner allowed to a spender.
	* @param _owner address The address which owns the funds.
	* @param _spender address The address which will spend the funds.
	* @return A uint256 specifing the amount of tokens still available for the spender.
	*/
	function allowance(address _owner, address _spender) constant returns (uint256 remaining) {
		return allowed[_owner][_spender];
	}

}

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
    
	address public owner;
	address public ownerCandidat;

	/**
	* @dev The Ownable constructor sets the original `owner` of the contract to the sender
	* account.
	*/
	function Ownable() {
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
	function transferOwnership(address newOwner) onlyOwner {
		require(newOwner != address(0));      
		ownerCandidat = newOwner;
	}
	/**
	* @dev Allows safe change current owner to a newOwner.
	*/
	function confirmOwnership() onlyOwner {
		require(msg.sender == ownerCandidat);      
		owner = msg.sender;
	}

}

/**
 * @title Burnable Token
 * @dev Token that can be irreversibly burned (destroyed).
 */
contract BurnableToken is StandardToken, Ownable {
 
	/**
	* @dev Burns a specific amount of tokens.
	* @param _value The amount of token to be burned.
	*/
	function burn(uint256 _value) public onlyOwner {
		require(_value > 0);

		address burner = msg.sender;    
										

		balances[burner] = balances[burner].sub(_value);
		totalSupply = totalSupply.sub(_value);
		Burn(burner, _value);
	}

	event Burn(address indexed burner, uint indexed value);
 
}
 
contract MettaCoin is BurnableToken {
 
	string public constant name = "TOKEN METTACOIN";   
	string public constant symbol = "METTACOIN";   
	uint32 public constant decimals = 18;    
	uint256 public constant initialSupply = 300000000 * 1 ether;

	function MettaCoin() {
		totalSupply = initialSupply;
		balances[msg.sender] = initialSupply;
	}    
  
}


contract Crowdsale is Ownable {
    
    using SafeMath for uint;
	//
    MettaCoin public token = new MettaCoin();
	//
    uint public start;    
    //
	uint public period;
	//
    uint public rate;
	//  
    uint public softcap;
    //
    uint public availableTokensforPreICO;
    //
    uint public countOfSaleTokens;
    //    
    uint public currentPreICObalance;
    //
    uint public refererPercent;
    //
	mapping(address => uint) public balances;
    
    // preICO manager data//////////////
     address public managerETHaddress;
     address public managerETHcandidatAddress;
     uint public managerETHbonus;
    
    /////////////////////////////////
   
    function Crowdsale() {
     
		// 1 METTACOIN = 0.00022 ETH
		rate = 220000000000000; 
		//Mon, 10 Nov 2017 00:00:00 GMT
		start = 1510272000;
		// preICO period is 20 of november - 19 of december
		period = 1; // 29  
		// minimum attracted ETH during preICO - 409
		softcap = 440000000000000;//409 * 1 ether; //0.00044 for test
		// maximum number mettacoins for preICO
		availableTokensforPreICO = 8895539 * 1 ether;
		// current ETH balance of preICO
		currentPreICObalance = 0; 
		// how much mettacoins are sold
		countOfSaleTokens = 0; 
		//percent for referer bonus program
		refererPercent = 15;
		
		//data of manager of company
		managerETHaddress = 0x0;   
		managerETHbonus = 220000000000000; //35 ETH ~ 1,4 BTC // 35 * 1 ether;

    }
    /**
	 * @dev Initially safe sets preICO manager address
	 */
    function setPreIcoManager(address _addr) public onlyOwner {   
        require(managerETHaddress == 0x0) ;//ony once
			managerETHcandidatAddress = _addr;
        
    }
	/**
	 * @dev Allows safe confirm of manager address
	 */
    function confirmManager() public {
        require(msg.sender == managerETHcandidatAddress); 
			managerETHaddress = managerETHcandidatAddress;
    }
    
    	/**
	 * @dev Allows safe changing of manager address
	 */
    function changeManager(address _addr) public {
        require(msg.sender == managerETHaddress); 
			managerETHcandidatAddress = _addr;
    }
	/**
	 * @dev Indicates that preICO starts and not finishes
	 */
    modifier saleIsOn() {
		require(now > start && now < start + period * 1 days);
		_;
    }
	
	/**
	 * @dev Indicates that we have available tokens for sale
	 */
    modifier issetTokensForSale() {
		require(countOfSaleTokens < availableTokensforPreICO); 
		_;
    }
    
    //test
    function getEndDate1() returns (uint){
        return start + period * 1 days;
    }
      function getENow() returns (uint){
        return now;
    }
    ///
    
  
	/**
	 * @dev Tokens ans ownership will be transfered from preICO contract to ICO contract after preICO period.
	 */
    function TransferTokenToIcoContract(address ICOcontract) public onlyOwner {
		require(now > start + period * 1 days);
		token.transfer(ICOcontract, token.balanceOf(this));
		token.transferOwnership(ICOcontract);
    }
	/**
	 * @dev Investments will be refunded if preICO not hits the softcap.
	 */
    function refund() public {
		require(currentPreICObalance < softcap && now > start + period * 1 days);
		msg.sender.transfer(balances[msg.sender]);
		balances[msg.sender] = 0;
    }
	/**
	 * @dev Manager can get his/shes bonus after preICO reaches it's softcap
	 */
    function withdrawManagerBonus() public {    
        if(currentPreICObalance > softcap && managerETHbonus > 0){
            managerETHaddress.transfer(managerETHbonus);
            managerETHbonus = 0;
        }
    }
	/**
	 * @dev If ICO reached owner can withdrow ETH for ICO comping managment
	 */
    function withdrawPreIcoFounds() public onlyOwner {  
		if(currentPreICObalance > softcap) {
			// send all current ETH from contract to owner
			uint availableToTranser = this.balance-managerETHbonus;
			owner.transfer(availableToTranser);
		}
    }
	/**
	 * @dev convert bytes to address
	 */
    function bytesToAddress(bytes source) internal returns(address) {
        uint result;
        uint mul = 1;
        for(uint i = 20; i > 0; i--) {
          result += uint8(source[i-1])*mul;
          mul = mul*256;
        }
        return address(result);
    }
   function buyTokens() issetTokensForSale saleIsOn payable {   
        uint tokens = msg.value.mul(1 ether).div(rate);
        if(tokens > 0)   {
             address referer = 0x0;
            //-------------BONUSES-------------//
             uint bonusTokens = 0;
            if(now < start.add(7* 1 days)) {// 1st week
    			bonusTokens = tokens.mul(45).div(100); //+45%
            } else if(now >= start.add(7 * 1 days) && now < start.add(14 * 1 days)) { // 2nd week
    			bonusTokens = tokens.mul(40).div(100); //+40%
            } else if(now >= start.add(14* 1 days) && now < start.add(21 * 1 days)) { // 3th week
    			bonusTokens = tokens.mul(35).div(100); //+35%
            } else if(now >= start.add(21* 1 days) && now < start.add(28 * 1 days)) { // 4th week
    			bonusTokens = tokens.mul(30).div(100); //+30% 
            } 
            tokens = tokens.add(bonusTokens);
            //---------END-BONUSES-------------//
    		
    		//---------referal program--------- //abailable after 3th week onli
    	//	if(now >= start.add(14* 1 days) && now < start.add(28 * 1 days)) {
                if(msg.data.length == 20) {
                  referer = bytesToAddress(bytes(msg.data));
                  require(referer != msg.sender);
                  uint refererTokens = tokens.mul(refererPercent).div(100);
                }
    	//	}
    		//---------end referal program---------//
    		
    		if(availableTokensforPreICO > countOfSaleTokens.add(tokens)) {  
    			token.transfer(msg.sender, tokens);
    			currentPreICObalance = currentPreICObalance.add(msg.value); 
    			countOfSaleTokens = countOfSaleTokens.add(tokens); 
    			balances[msg.sender] = balances[msg.sender].add(msg.value);
    			if(availableTokensforPreICO > countOfSaleTokens.add(tokens).add(refererTokens)){
    			     // send token to referrer
    			     if(referer !=0x0 && refererTokens >0){
    			        token.transfer(referer, refererTokens);
    			        	countOfSaleTokens = countOfSaleTokens.add(refererTokens); 
    			     }
    			}
    		} else {
    			// there are not sufficient number of tokens - return of ETH
    			msg.sender.transfer(msg.value);
    		}
        }else{
            // retun to buyer if tokens == 0
           msg.sender.transfer(msg.value);
        }
    }

    function() external payable {
		buyTokens();  
    }
}