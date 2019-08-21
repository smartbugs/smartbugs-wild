pragma solidity ^0.4.18;

/**
 * @dev Math operations with safety checks that throw on error
 */
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
    mapping (address => Snapshot[]) balances;
    mapping (address => uint256) userWithdrawalBlocks;
	
    /**
     * @dev 'Snapshot' is the structure that attaches a block number to a
     * given value, the block number attached is the one that last changed the value
     * 'fromBlock' - is the block number that the value was generated from
     * 'value' - is the amount of tokens at a specific block number
     */
    struct Snapshot {
      uint128 fromBlock;
      uint128 value;
    }
	
	/**
	 * @dev tracks history of totalSupply
	 */
    Snapshot[] totalSupplyHistory;
    
    /**
     * @dev track history of 'ETH balance' for dividends
     */
    Snapshot[] balanceForDividendsHistory;
	
	/**
	* @dev transfer token for a specified address
	* @param to - the address to transfer to.
	* @param value - the amount to be transferred.
	*/
	function transfer(address to, uint256 value) public returns (bool) {
        return doTransfer(msg.sender, to, value);
	}
	
	/**
	 * @dev internal function for transfers handling
	 */
	function doTransfer(address _from, address _to, uint _amount) internal returns(bool) {
	   if (_amount == 0) {
		   return true;
	   }
     
	   // Do not allow transfer to 0x0 or the token contract itself
	   require((_to != 0) && (_to != address(this)));

	   // If the amount being transfered is more than the balance of the
	   //  account the transfer returns false
	   var previousBalanceFrom = balanceOfAt(_from, block.number);
	   if (previousBalanceFrom < _amount) {
		   return false;
	   }

	   // First update the balance array with the new value for the address
	   //  sending the tokens
	   updateValueAtNow(balances[_from], previousBalanceFrom - _amount);

	   // Then update the balance array with the new value for the address
	   //  receiving the tokens
	   var previousBalanceTo = balanceOfAt(_to, block.number);
	   require(previousBalanceTo + _amount >= previousBalanceTo); // Check for overflow
	   updateValueAtNow(balances[_to], previousBalanceTo + _amount);

	   // An event to make the transfer easy to find on the blockchain
	   Transfer(_from, _to, _amount);

	   return true;
    }
    
	/**
	* @dev Gets the balance of the specified address.
	* @param _owner The address to query the the balance of. 
	* @return An uint256 representing the amount owned by the passed address.
	*/
	function balanceOf(address _owner) public constant returns (uint256 balance) {
		return balanceOfAt(_owner, block.number);
	}

    /**
     * @dev Queries the balance of `_owner` at a specific `_blockNumber`
     * @param _owner The address from which the balance will be retrieved
     * @param _blockNumber The block number when the balance is queried
     * @return The balance at `_blockNumber`
     */
    function balanceOfAt(address _owner, uint _blockNumber) public constant returns (uint) {
        //  These next few lines are used when the balance of the token is
        //  requested before a check point was ever created for this token
        if ((balances[_owner].length == 0)|| (balances[_owner][0].fromBlock > _blockNumber)) {
			return 0; 
        } else {
            return getValueAt(balances[_owner], _blockNumber);
        }
    }

    /**
     * @dev Total amount of tokens at a specific `_blockNumber`.
     * @param _blockNumber The block number when the totalSupply is queried
     * @return The total amount of tokens at `_blockNumber`
     */
    function totalSupplyAt(uint _blockNumber) public constant returns(uint) {
        // These next few lines are used when the totalSupply of the token is
        // requested before a check point was ever created for this token
        if ((totalSupplyHistory.length == 0) || (totalSupplyHistory[0].fromBlock > _blockNumber)) {
			return 0;
        } else {
            return getValueAt(totalSupplyHistory, _blockNumber);
        }
    }

    /**
     * @dev `getValueAt` retrieves the number of tokens at a given block number
     * @param checkpoints The history of values being queried
     * @param _block The block number to retrieve the value at
     * @return The number of tokens being queried
     */
    function getValueAt(Snapshot[] storage checkpoints, uint _block) constant internal returns (uint) {
        if (checkpoints.length == 0) return 0;

        // Shortcut for the actual value
        if (_block >= checkpoints[checkpoints.length-1].fromBlock)
            return checkpoints[checkpoints.length-1].value;
        if (_block < checkpoints[0].fromBlock) return 0;

        // Binary search of the value in the array
        uint min = 0;
        uint max = checkpoints.length-1;
        while (max > min) {
            uint mid = (max + min + 1)/ 2;
            if (checkpoints[mid].fromBlock<=_block) {
                min = mid;
            } else {
                max = mid-1;
            }
        }
        return checkpoints[min].value;
    }

    /**
     * @dev `updateValueAtNow` used to update the `balances` map and the `totalSupplyHistory`
     * @param checkpoints The history of data being updated
     * @param _value The new number of tokens
     */ 
    function updateValueAtNow(Snapshot[] storage checkpoints, uint _value) internal  {
        if ((checkpoints.length == 0) || (checkpoints[checkpoints.length -1].fromBlock < block.number)) {
           Snapshot storage newCheckPoint = checkpoints[ checkpoints.length++ ];
           newCheckPoint.fromBlock =  uint128(block.number);
           newCheckPoint.value = uint128(_value);
        } else {
           Snapshot storage oldCheckPoint = checkpoints[checkpoints.length-1];
           oldCheckPoint.value = uint128(_value);
        }
    }
	
    /**
     * @dev This function makes it easy to get the total number of tokens
     * @return The total number of tokens
     */
    function redeemedSupply() public constant returns (uint) {
        return totalSupplyAt(block.number);
    }
}

contract Ownable {
  address public owner;

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
    owner = newOwner;
  }
}

contract StandardToken is ERC20, BasicToken {

  mapping (address => mapping (address => uint256)) allowed;

  /**
   * @dev Transfer tokens from one address to another
   * @param _from address The address which you want to send tokens from
   * @param _to address The address which you want to transfer to
   * @param _value uint256 the amount of tokens to be transferred
   */
  function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
	  return doTransfer(_from, _to, _value);
  }

  /**
   * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.
   * @param _spender The address which will spend the funds.
   * @param _value The amount of tokens to be spent.
   */
  function approve(address _spender, uint256 _value) public returns (bool) {
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
   * @return A uint256 specifying the amount of tokens still available for the spender.
   */
  function allowance(address _owner, address _spender) public constant returns (uint256 remaining) {
    return allowed[_owner][_spender];
  }

}

contract MintableToken is StandardToken {
  event Mint(address indexed to, uint256 amount);
  event MintFinished();
  
  bool public mintingFinished = false;

  string public name = "Honey Mining Token";		
  string public symbol = "HMT";		
  uint8 public decimals = 8;		

  modifier canMint() {
    require(!mintingFinished);
    _;
  }

  /**
   * @dev Function to mint tokens
   * @param _to The address that will receive the minted tokens.
   * @param _amount The amount of tokens to mint.
   * @return A boolean that indicates if the operation was successful.
   */
  function mint(address _to, uint256 _amount) public canMint returns (bool) {
    totalSupply = totalSupply.add(_amount);
	uint curTotalSupply = redeemedSupply();
	require(curTotalSupply + _amount >= curTotalSupply); // Check for overflow
	uint previousBalanceTo = balanceOf(_to);
	require(previousBalanceTo + _amount >= previousBalanceTo); // Check for overflow
	updateValueAtNow(totalSupplyHistory, curTotalSupply + _amount);
    updateValueAtNow(balances[_to], previousBalanceTo + _amount);
    Mint(_to, _amount);
    Transfer(0x0, _to, _amount);
    return true;
  }
  
  /**
   * @dev Function to record snapshot block and amount
   */
  function recordDeposit(uint256 _amount) public {
	 updateValueAtNow(balanceForDividendsHistory, _amount);
  }
  
  /**
   * @dev Function to stop minting new tokens.
   * @return True if the operation was successful.
   */
  function finishMinting() public returns (bool) {
    mintingFinished = true;
    MintFinished();
    return true;
  }
  
  /**
   * @dev Function to calculate dividends
   * @return awailable for withdrawal ethere (wei value)
   */
  function awailableDividends(address userAddress) public view returns (uint256) {
      uint256 userLastWithdrawalBlock = userWithdrawalBlocks[userAddress];
      uint256 amountForWithdraw = 0;
      for(uint i = 0; i<=balanceForDividendsHistory.length-1; i++){
          Snapshot storage snapshot = balanceForDividendsHistory[i];
          if(userLastWithdrawalBlock < snapshot.fromBlock)
            amountForWithdraw = amountForWithdraw.add(balanceOfAt(userAddress, snapshot.fromBlock).mul(snapshot.value).div(totalSupplyAt(snapshot.fromBlock)));
      }
      return amountForWithdraw;
  }
  
  /**
   * @dev Function to record user withdrawal 
   */
  function recordWithdraw(address userAddress) public {
    userWithdrawalBlocks[userAddress] = balanceForDividendsHistory[balanceForDividendsHistory.length-1].fromBlock;
  }
}

contract HoneyMiningToken is Ownable {
    
  using SafeMath for uint256;

  MintableToken public token;
  /**
   * @dev Info of max supply
   */
  uint256 public maxSupply = 300000000000000;
  
  /**
   * event for token purchase logging
   * @param purchaser who paid for the tokens, basically - 0x0, but could be user address on refferal case
   * @param beneficiary who got the tokens
   * @param value weis paid for purchase
   * @param amount - of tokens purchased
   */
  event TokenPurchase(address indexed purchaser, address indexed beneficiary, uint256 value, uint256 amount);
  
  /**
   * event for referral comission logging
   * @param purchaser who paid for the tokens
   * @param beneficiary who got the bonus tokens
   * @param amount - of tokens as ref reward
   */
  event ReferralBonus(address indexed purchaser, address indexed beneficiary, uint amount);
  
   /**
   * event for token dividends deposit logging
   * @param amount - amount of ETH deposited
   */
  event DepositForDividends(uint256 indexed amount);
  
  /**
   * event for dividends withdrawal logging 
   * @param holder - who has the tokens
   * @param amount - amount of ETH which was withdraw
  */
  event WithdrawDividends(address indexed holder, uint256 amount);

  /**
   * event for dev rewards logging
   * @param purchaser - who paid for the tokens
   * @param amount  - representation of dev reward
   */
  event DevReward(address purchaser, uint amount);

  function HoneyMiningToken() public {
    token = new MintableToken();
  }

  /**
   * @dev fallback function can be used to buy tokens
   */
  function () public payable {buyTokens(0x0);}

  /**
   * @dev low level token purchase function
   * @param referrer - optional parameter for ref bonus
   */
  function buyTokens(address referrer) public payable {
    require(msg.sender != 0x0);
    require(msg.sender != referrer);
    require(validPurchase());
    
    //we dont need 18 decimals - and will use only 8
    uint256 amount = msg.value.div(10000000000);
    
    // calculate token amount to be created
    uint256 tokens = amount.mul(rate());
    require(tokens >= 100000000);
    uint256 devTokens = tokens.mul(30).div(100);
    if(referrer != 0x0){
       require(token.balanceOf(referrer) >= 100000000);
       // 2.5% for referral and referrer
       uint256 refTokens = tokens.mul(25).div(1000);
       //tokens = tokens+refTokens;
       require(maxSupply.sub(redeemedSupply()) >= tokens.add(refTokens.mul(2)).add(devTokens));
       
       //generate tokens for purchser
       token.mint(msg.sender, tokens.add(refTokens));
       TokenPurchase(msg.sender, msg.sender, amount, tokens.add(refTokens));
       token.mint(referrer, refTokens);
       ReferralBonus(msg.sender, referrer, refTokens);
       
    } else{
        require(maxSupply.sub(redeemedSupply())>=tokens.add(devTokens));
        //updatedReddemedSupply = redeemedSupply().add(tokens.add(devTokens));
        
        //generate tokens for purchser
        token.mint(msg.sender, tokens);
    
        // log purchase
        TokenPurchase(msg.sender, msg.sender, amount, tokens);
    }
    token.mint(owner, devTokens);
    DevReward(msg.sender, devTokens);
    forwardFunds();
  }

  /**
   * @return true if the transaction can buy tokens
   */
  function validPurchase() internal constant returns (bool) {
    return !hasEnded() && msg.value != 0;
  }

  /**
   * @return true if sale is over
   */
  function hasEnded() public constant returns (bool) {
    return maxSupply <= redeemedSupply();
  }
  
  /**
   * @dev get current user balance
   * @param userAddress - address of user
   * @return current balance of tokens
   */
  function checkBalance(address userAddress) public constant returns (uint){
      return token.balanceOf(userAddress);
  }
  
  /**
   * @dev get user balance of tokens on specific block
   * @param userAddress - address of user
   * @param targetBlock - block number
   * @return address balance on block
   */
  function checkBalanceAt(address userAddress, uint256 targetBlock) public constant returns (uint){
      return token.balanceOfAt(userAddress, targetBlock);
  }
  
  /**
   * @dev get awailable dividends for withdrawal
   * @param userAddress - target 
   * @return amount of ether (wei value) for current user
   */
  function awailableDividends(address userAddress) public constant returns (uint){
    return token.awailableDividends(userAddress);
  }
  
  /**
   * @return total purchased tokens value
   */
  function redeemedSupply() public view returns (uint){
    return token.totalSupply();
  }
  
  /**
   * @dev user-related method for withdrawal dividends
   */
  function withdrawDividends() public {
    uint _amount = awailableDividends(msg.sender);
    require(_amount > 0);
    msg.sender.transfer(_amount);
    token.recordWithdraw(msg.sender);
    WithdrawDividends(msg.sender, _amount);
  }
  
  /**
   * @dev function for deposit ether to token address as/for dividends
   */
  function depositForDividends() public payable onlyOwner {
      require(msg.value > 0);
      token.recordDeposit(msg.value);
      DepositForDividends(msg.value);
  }
  
  function stopSales() public onlyOwner{
   maxSupply = token.totalSupply();
  }
   
  function forwardFunds() internal {
    owner.transfer(msg.value);
  }
  
  function rate() internal constant returns (uint) {
    if(redeemedSupply() < 1000000000000)
        return 675;
    else if (redeemedSupply() < 5000000000000)
        return 563;
    else
        return 450;
  }
}