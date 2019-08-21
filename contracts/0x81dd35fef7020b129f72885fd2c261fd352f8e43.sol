pragma solidity ^0.4.15;

/**
 * @dev SEEDS token smart contract. For project and ICO details, please check: http://seedsico.info
 */

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

contract Token {
    uint256 public totalSupply;
    function balanceOf(address _owner) constant returns (uint256 balance);
    function transfer(address _to, uint256 _value) returns (bool success);
    function transferFrom(address _from, address _to, uint256 _value) returns (bool success);
    function approve(address _spender, uint256 _value) returns (bool success);
    function allowance(address _owner, address _spender) constant returns (uint256 remaining);
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}

    /**
     * @title Ownable
     * @dev The Ownable contract has an owner address, and provides basic authorization control
     * functions, this simplifies the implementation of "user permissions".
     */
contract Ownable {
  address public owner;


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
    owner = newOwner;
  }

}


/**
 * @title Pausable
 * @dev Base contract which allows children to implement an emergency stop mechanism.
 * pause is initially set to true; team will unpause before PRE-ICO start.
 */
contract Pausable is Ownable {
  event Pause();
  event Unpause();

  bool public paused = true;


  /**
   * @dev modifier to allow actions only when the contract IS paused
   */
  modifier whenNotPaused() {
    require(!paused);
    _;
  }

  /**
   * @dev modifier to allow actions only when the contract IS NOT paused
   */
  modifier whenPaused() {
    require(paused);
    _;
  }

  /**
   * @dev called by the owner to pause, triggers stopped state
   */
  function pause() onlyOwner whenNotPaused {
    paused = true;
    Pause();
  }

  /**
   * @dev called by the owner to unpause, returns to normal state
   */
  function unpause() onlyOwner whenPaused {
    paused = false;
    Unpause();
  }
}
/**
 * @title LockFunds
 * @dev Base contract which allows children to lock funds.
 * Funds are locked in contributors' wallets since ICO end. On 6th March 2018 funds will be transferable
 */
contract LockFunds is Ownable {
  event Lock();
  event UnLock();

  bool public locked = true;


  /**
   * @dev modifier to allow actions only when the funds ARE locked
   */
  modifier whenNotLocked() {
    require(!locked);
    _;
  }

  /**
   * @dev modifier to allow actions only when the funds ARE NOT locked
   */
  modifier whenLocked() {
    require(locked);
    _;
  }

  /**
   * @dev called by the owner to lock, triggers locked state
   */
  function lock() onlyOwner whenNotLocked {
    locked = true;
    Lock();
  }

  /**
   * @dev called by the owner to unlock, returns to normal state
   */
  function unlock() onlyOwner whenLocked {
    locked = false;
    UnLock();
  }
}
/**
 * StandardToken contract that implements LockFunds contract.
 * Transfers are locked until 6th March 2018.
*/
contract StandardToken is Token, SafeMath, LockFunds {

    function transfer(address _to, uint256 _value) whenNotLocked returns (bool success) {
      if (balances[msg.sender] >= _value && _value > 0) {
        balances[msg.sender] = sub(balances[msg.sender], _value);
        balances[_to] = add(balances[_to], _value);
        Transfer(msg.sender, _to, _value);
        return true;
      } else {
        return false;
      }
    }

    function transferFrom(address _from, address _to, uint256 _value) whenNotLocked returns (bool success) {
      if (balances[_from] >= _value && allowed[_from][msg.sender] >= _value && _value > 0) {
        balances[_to] = add(balances[_to], _value);
        balances[_from] -= sub(balances[_from], _value);
        allowed[_from][msg.sender] = sub(allowed[_from][msg.sender], _value);
        Transfer(_from, _to, _value);
        return true;
      } else {
        return false;
      }
    }

    function balanceOf(address _owner) constant returns (uint256 balance) {
        return balances[_owner];
    }

    function approve(address _spender, uint256 _value) returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }

    function allowance(address _owner, address _spender) constant returns (uint256 remaining) {
      return allowed[_owner][_spender];
    }

    mapping (address => uint256) balances;
    mapping (address => mapping (address => uint256)) allowed;
}

/** Burn contract allows team to burn their OWN SEEDS supply, 
 * Total supply is updated and lowered.
*/

contract BurnableToken is SafeMath, StandardToken {

    event Burn(address indexed burner, uint256 value);

    /**
     * @dev Burns a specific amount of tokens.
     * @param _value The amount of token to be burned.
     */
    function burn(uint256 _value) public {
        require(_value <= balances[msg.sender]);
        // no need to require value <= totalSupply, since that would imply the
        // sender's balance is greater than the totalSupply, which *should* be an assertion failure

        address burner = msg.sender;
        balances[burner] = sub(balances[burner],_value);
        totalSupply = sub(totalSupply,_value);
        Burn(burner, _value);
    }
}

/**SEEDSToken contract allows contributor to participate in PRE-ICO and ICO;
 * PRE-ICO starts on January 5th 2018 14:00 GMT and ends on January 8th 2018, 13:59 GMT. 50% discount during this phase.
 * ICO start on  January 8th 2018, 14:00 GMT and ends on March 5th 2018, 23:59 GMT.
 * Discounts are the following:
 * - 30% discount during phase 1, starting on 8th January and ending on 15th January;
 * - 15% discount during phase 2, starting on 15th January and ending on 29th January;
 * - 5% discount during phase 3, starting on 29th January and ending on 12th February;
 * - No discount during phase 4, starting on 12th February and ending on 5th March.
 * On ICO end, SEEDS tokens will be unlocked and transfers will be available.
 */

contract SEEDSToken is SafeMath, StandardToken, BurnableToken, Pausable {

    string public constant name = "Seeds";                                      //token name
    string public constant symbol = "SEEDS";                                    //token symbol
    uint256 public constant decimals = 18;                                      //token decimals
    uint256 public constant maxFixedSupply = 500000000*10**decimals;            //Max SEEDS supply
	uint256 public constant tokenCreationCap = 375000000*10**decimals;          //Max cap for ICO and PRE-ICO
	uint256 public constant initialSupply = add(add(freeTotal, teamTotal), add(advisorTotal,lockedTeam));   //sets initial supply
    uint256 public freeTotal = 5000000*10**decimals;                            //sets bounties and airdrop supply
    uint256 public teamTotal = 50000000*10**decimals;                           //sets team supply
    uint256 public advisorTotal = 50000000*10**decimals;                        //sets advisors and partners supply
    uint256 public lockedTeam = 20000000*10**decimals;                          //sets team funds locked for 24 months 
    uint256 public stillAvailable = tokenCreationCap;                           //calculates how many tokens are still available for crowdsale
    
	
	uint256 public toBeDistributedFree = freeTotal; 
    uint256 public totalEthReceivedinWei;
    uint256 public totalDistributedinWei;
    uint256 public totalBountyinWei;

    Phase public currentPhase = Phase.END;

    enum Phase {
        PreICO,
        ICO1,
        ICO2,
        ICO3,
        ICO4,
        END
    }

    event CreateSEEDS(address indexed _to, uint256 _value);
    event PriceChanged(string _text, uint _newPrice);
    event StageChanged(string _text);
    event Withdraw(address to, uint amount);

    function SEEDSToken() {                                                     //sets totalSupply and owner supply
        owner=msg.sender;                                                       //owner supply = 125 M SEEDS to be distributed
        balances[owner] = sub(maxFixedSupply, tokenCreationCap);                //through bounties, airdrop, team and advisors
        totalSupply = initialSupply;
    
    }

    function () payable {
        createTokens();
    }


    function createTokens() whenNotPaused internal  {                           //function that calculates Seeds to be received according 
        uint multiplier = 10 ** 10;                                             // to ETH sent.
        uint256 oneTokenInWei;
        uint256 tokens; 
        uint256 checkedSupply;

        if (currentPhase == Phase.PreICO){
            {
                oneTokenInWei = 25000000000000;
                tokens = div(msg.value*100000000, oneTokenInWei) * multiplier;
                checkedSupply = add(totalSupply, tokens);
                if (checkedSupply <= tokenCreationCap)
                    {
                        addTokens(tokens);
                        stillAvailable = sub(stillAvailable, tokens);           //
                    }
                else
                    revert ();
            }
        } 
        else if (currentPhase == Phase.ICO1){
            {
                oneTokenInWei = 35000000000000;
                tokens = div(msg.value*100000000, oneTokenInWei) * multiplier;
                checkedSupply = add(totalSupply, tokens);
                if (checkedSupply <= tokenCreationCap)
                    {
                        addTokens(tokens);
                        stillAvailable = sub(stillAvailable, tokens);
                    }
                else
                    revert ();
            }
        }
        else if (currentPhase == Phase.ICO2){
            {
                oneTokenInWei = 42000000000000;
                tokens = div(msg.value*100000000, oneTokenInWei) * multiplier;
                checkedSupply = add(totalSupply, tokens);
                if (checkedSupply <= tokenCreationCap)
                    {
                        addTokens(tokens);
                        stillAvailable = sub(stillAvailable, tokens);           //
                    }
                else
                    revert ();
            }
        }
        else if (currentPhase == Phase.ICO3){
            {
                oneTokenInWei = 47500000000000;
                tokens = div(msg.value*100000000, oneTokenInWei) * multiplier;
                checkedSupply = add(totalSupply, tokens);
                if (checkedSupply <= tokenCreationCap)
                    {
                        addTokens(tokens);
                        stillAvailable = sub(stillAvailable, tokens);           //
                    }
                else
                    revert ();
            }
        }
        else if (currentPhase == Phase.ICO4){
            {
                oneTokenInWei = 50000000000000;
                tokens = div(msg.value*100000000, oneTokenInWei) * multiplier;
                checkedSupply = add(totalSupply, tokens);
                if (checkedSupply <= tokenCreationCap)
                    {
                        addTokens(tokens);
                        stillAvailable = sub(stillAvailable, tokens);           //
                    }
                else
                    revert ();
            }
        }
        else if (currentPhase == Phase.END){
            revert();
        }
    }

    function addTokens(uint256 tokens) internal {                               //updates received ETH and total supply, sends Seeds to contributor
        require (msg.value >= 0 && msg.sender != address(0));
        balances[msg.sender] = add(balances[msg.sender], tokens);
        totalSupply = add(totalSupply, tokens);
        totalEthReceivedinWei = add(totalEthReceivedinWei, msg.value);
        CreateSEEDS(msg.sender, tokens);
    }

    function withdrawInWei(address _toAddress, uint256 amount) external onlyOwner {     //allow Seeds team to Withdraw collected Ether
        require(_toAddress != address(0));
        _toAddress.transfer(amount);
        Withdraw(_toAddress, amount);
    }

    function setPreICOPhase() external onlyOwner {                              //set current Phase. Initial phase is set to "END".
        currentPhase = Phase.PreICO;
        StageChanged("Current stage: PreICO");
    }
    
    function setICO1Phase() external onlyOwner {
        currentPhase = Phase.ICO1;
        StageChanged("Current stage: ICO1");
    }
    
    function setICO2Phase() external onlyOwner {
        currentPhase = Phase.ICO2;
        StageChanged("Current stage: ICO2");
    }
    
    function setICO3Phase() external onlyOwner {
        currentPhase = Phase.ICO3;
        StageChanged("Current stage: ICO3");
    }
    
    function setICO4Phase() external onlyOwner {
        currentPhase = Phase.ICO4;
        StageChanged("Current stage: ICO4");
    }

    function setENDPhase () external onlyOwner {
        currentPhase = Phase.END;
        StageChanged ("Current stage: END");
    }

    function generateTokens(address _receiver, uint256 _amount) external onlyOwner {    //token generation
        require(_receiver != address(0));
        balances[_receiver] = add(balances[_receiver], _amount);
        totalSupply = add(totalSupply, _amount);
        CreateSEEDS(_receiver, _amount);
    }

	function airdropSEEDSinWei(address[] addresses, uint256 _value) onlyOwner { //distribute airdrop, value inserted with decimals
         uint256 airdrop = _value;
         uint256 airdropMax = 100000*10**decimals;
         uint256 total = mul(airdrop, addresses.length);
         if (toBeDistributedFree >= 0 && total<=airdropMax){
             for (uint i = 0; i < addresses.length; i++) {
	            balances[owner] = sub(balances[owner], airdrop);
                balances[addresses[i]] = add(balances[addresses[i]],airdrop);
                Transfer(owner, addresses[i], airdrop);
            }
			totalDistributedinWei = add(totalDistributedinWei,total);
			toBeDistributedFree = sub(toBeDistributedFree, totalDistributedinWei);
         }
         else
            revert();
       }
    function bountySEEDSinWei(address[] addresses, uint256 _value) onlyOwner {  //distribute bounty, value inserted with decimals
         uint256 bounty = _value;
         uint256 total = mul(bounty, addresses.length);
         if (toBeDistributedFree >= 0){
             for (uint i = 0; i < addresses.length; i++) {
	            balances[owner] = sub(balances[owner], bounty);
                balances[addresses[i]] = add(balances[addresses[i]],bounty);
                Transfer(owner, addresses[i], bounty);
            }
			totalBountyinWei = add(totalBountyinWei,total);
			toBeDistributedFree = sub(toBeDistributedFree, totalBountyinWei);
         }
         else
            revert();
       }
       
}