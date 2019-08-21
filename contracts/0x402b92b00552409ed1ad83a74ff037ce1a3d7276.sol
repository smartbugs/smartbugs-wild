pragma solidity ^0.4.18;

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
  function transferOwnership(address newOwner) onlyOwner public {
    require(newOwner != address(0));
    OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }

}



/**
 * @title ERC20Basic
 * @dev Simpler version of ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/179
 */
contract ERC20Basic {
  uint256 public totalSupply;
  function balanceOf(address who) public constant returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}


/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender) public constant returns (uint256);
  function transferFrom(address from, address to, uint256 value) public returns (bool);
  function approve(address spender, uint256 value) public returns (bool);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}


/**
 * @title Basic token
 * @dev Basic version of StandardToken, with no allowances.
 */
contract BasicToken is ERC20Basic, Ownable {
  using SafeMath for uint256;

  mapping(address => uint256) balances;
  mapping(address => bool) locks;

  /**
  * @dev transfer token for a specified address
  * @param _to The address to transfer to.
  * @param _value The amount to be transferred.
  */
  function transfer(address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));
    
    require(!locks[msg.sender] && !locks[_to]);

    // SafeMath.sub will throw if there is not enough balance.
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
  function balanceOf(address _owner) public constant returns (uint256 balance) {
    return balances[_owner];
  }
  
  /**
  * @dev Sets the lock state of the specified address.
  * @param _toLock The address to set the the lock state for.
  * @param _setTo A bool representing the lock state.
  */
  function setLock(address _toLock, bool _setTo) onlyOwner {
      locks[_toLock] = _setTo;
  }

  /**
  * @dev Gets the lock state of the specified address.
  * @param _owner The address to query the the lock state of.
  * @return A bool representing the lock state.
  */
  function lockOf(address _owner) public constant returns (bool lock) {
    return locks[_owner];
  }

}


/**
 * @title Standard ERC20 token
 *
 * @dev Implementation of the basic standard token.
 * @dev https://github.com/ethereum/EIPs/issues/20
 * @dev Based on code by FirstBlood: https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol
 */
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
    
    require(!locks[_from] && !locks[_to]);

    uint256 _allowance = allowed[_from][msg.sender];

    // Check is not needed because sub(_allowance, _value) will already throw if this condition is not met
    // require (_value <= _allowance);

    balances[_from] = balances[_from].sub(_value);
    balances[_to] = balances[_to].add(_value);
    allowed[_from][msg.sender] = _allowance.sub(_value);
    Transfer(_from, _to, _value);
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

  /**
   * approve should be called when allowed[_spender] == 0. To increment
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   */
  function increaseApproval (address _spender, uint _addedValue) public returns (bool success) {
    allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
    Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

  function decreaseApproval (address _spender, uint _subtractedValue) public returns (bool success) {
    uint oldValue = allowed[msg.sender][_spender];
    if (_subtractedValue > oldValue) {
      allowed[msg.sender][_spender] = 0;
    } else {
      allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
    }
    Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

}


/**
 * @title Mintable token
 * @dev ERC20 Token, with mintable token creation
 * @dev Issue: * https://github.com/OpenZeppelin/zeppelin-solidity/issues/120
 * Based on code by TokenMarketNet: https://github.com/TokenMarketNet/ico/blob/master/contracts/MintableToken.sol
 */

contract MintableToken is StandardToken {
  string public constant name = "CryptoTask";
  string public constant symbol = "CTF";
  uint8 public constant decimals = 18; 
    
  event Mint(address indexed to, uint256 amount);
  event MintFinished();

  bool public mintingFinished = false;


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
  function mint(address _to, uint256 _amount) onlyOwner canMint public returns (bool) {
    require(!locks[_to]);
    totalSupply = totalSupply.add(_amount);
    balances[_to] = balances[_to].add(_amount);
    Mint(_to, _amount);
    Transfer(0x0, _to, _amount);
    return true;
  }

  /**
   * @dev Function to stop minting new tokens.
   * @return True if the operation was successful.
   */
  function finishMinting() onlyOwner public returns (bool) {
    mintingFinished = true;
    MintFinished();
    return true;
  }
  
}


contract Crowdsale is Ownable {
    using SafeMath for uint;
    
    uint public fundingGoal = 1000 * 1 ether;
    uint public hardCap;
    uint public amountRaisedPreSale = 0;
    uint public amountRaisedICO = 0;
    uint public contractDeployedTime;
    //period after which anyone can close the presale
    uint presaleDuration = 30 * 1 days;
    //period between pre-sale and ICO
    uint countdownDuration = 45 * 1 days;
    //ICO duration
    uint icoDuration = 20 * 1 days;
    uint public presaleEndTime;
    uint public deadline;
    uint public price = 1000;
    MintableToken public token;
    mapping(address => uint) public balanceOf;
    bool public icoSuccess = false;
    bool public crowdsaleClosed = false;
    //2 vaults that the raised funds are forwarded to
    address vault1;
    address vault2 = 0xC0776D495f9Ed916C87c8C48f34f08E2B9506342;
    //stage 0 - presale, 1 - ICO, 2 - ICO success, 3 - after 1st vote on continuation of the project, 4 - after 2nd vote. ICO funds released in 3 stages
    uint public stage = 0;
    //total token stake against the project continuation
    uint public against = 0;
    uint public lastVoteTime;
    uint minVoteTime = 180 * 1 days;

    event GoalReached(uint amountRaised);
    event FundTransfer(address backer, uint amount, bool isContribution);

    /**
     * Constrctor function
     *
     * Setup the owner
     */
    function Crowdsale() {
        contractDeployedTime = now;
        vault1 = msg.sender;
        token = new MintableToken();
    }

    /**
     * Fallback function
     *
     * Called whenever anyone sends funds to the contract
     */
    function () payable {
        require(!token.lockOf(msg.sender) && !crowdsaleClosed && stage<2 && msg.value >= 1 * (1 ether)/10);
        if(stage==1 && (now < presaleEndTime.add(countdownDuration) || amountRaisedPreSale+amountRaisedICO+msg.value > hardCap)) {
            throw;
        }
        uint amount = msg.value;
        balanceOf[msg.sender] += amount;
        if(stage==0) {  //presale
            amountRaisedPreSale += amount;
            token.mint(msg.sender, amount.mul(2) * price);
        } else {
            amountRaisedICO += amount;
            token.mint(msg.sender, amount * price);
        }
        FundTransfer(msg.sender, amount, true);
    }
    
    /**
     * Forwards the amount from the contract to the vaults, 67% of the amount to vault1 and 33% to vault2
     */
    function forward(uint amount) internal {
        vault1.transfer(amount.mul(67)/100);
        vault2.transfer(amount.sub(amount.mul(67)/100));
    }

    modifier afterDeadline() { if (stage > 0 && now >= deadline) {_;} }

    /**
     * Check after deadline if the goal was reached and ends the campaign
     */
    function checkGoalReached() afterDeadline {
        require(stage==1 && !crowdsaleClosed);
        if (amountRaisedPreSale+amountRaisedICO >= fundingGoal) {
            uint amount = amountRaisedICO/3;
            if(!icoSuccess) {
                amount += amountRaisedPreSale/3;    //if funding goal hasn't been already reached in pre-sale
            }
            uint amountToken1 = token.totalSupply().mul(67)/(100*4);
            uint amountToken2 = token.totalSupply().mul(33)/(100*4);
            forward(amount);
            icoSuccess = true;
            token.mint(vault1, amountToken1);    //67% of the 25% of the total
            token.mint(vault2, amountToken2);    //33% of the 25% of the total
            stage=2;
            lastVoteTime = now;
            GoalReached(amountRaisedPreSale+amountRaisedICO);
        }
        crowdsaleClosed = true;
        token.finishMinting();
    }

    /**
     * Closes presale
     */
    function closePresale() {
        require((msg.sender == owner || now.sub(contractDeployedTime) > presaleDuration) && stage==0);
        stage = 1;
        presaleEndTime = now;
        deadline = now.add(icoDuration.add(countdownDuration));
        if(amountRaisedPreSale.mul(5) > 10000 * 1 ether) {
            hardCap = amountRaisedPreSale.mul(5);
        } else {
            hardCap = 10000 * 1 ether;
        }
        if(amountRaisedPreSale >= fundingGoal) {
            uint amount = amountRaisedPreSale/3;
            forward(amount);
            icoSuccess = true;
            GoalReached(amountRaisedPreSale);
        }
    }

    /**
     * Withdraw the funds
     *
     * If goal was not reached, each contributor can withdraw the amount they contributed, or less in case project is stopped through voting in later stages.
     */
    function safeWithdrawal() {
        require(crowdsaleClosed && !icoSuccess);
        
        uint amount;
        if(stage==1) {
            amount = balanceOf[msg.sender];
        } else if(stage==2) {
            amount = balanceOf[msg.sender].mul(2)/3;    //2 thirds of the initial deposit can be withdrawn
        } else if(stage==3) {
            amount = balanceOf[msg.sender]/3;    //one third of the initial deposit can be withdrawn
        }
        balanceOf[msg.sender] = 0;
        if (amount > 0) {
            msg.sender.transfer(amount);
            FundTransfer(msg.sender, amount, false);
        }
    }
    
    /**
     * Token stakeholder can vote against the project continuation. Tokens are locked until voteRelease() is called
     */
    function voteAgainst()
    {
        require((stage==2 || stage==3) && !token.lockOf(msg.sender));   // If has already voted, cancel
        token.setLock(msg.sender, true);
        uint voteWeight = token.balanceOf(msg.sender);
        against = against.add(voteWeight);
    }
    
    /**
     * Token stakeholder can release the against-vote, and unlock the tokens
     */
    function voteRelease()
    {
        require((stage==2 || stage==3 || stage==4) && token.lockOf(msg.sender));
        token.setLock(msg.sender, false);
        uint voteWeight = token.balanceOf(msg.sender);
        against = against.sub(voteWeight);
    }
    
    /**
     * After each voting period, vote stakes can be counted, and in case that more than 50% of token stake is against the continuation,
     * the remaining eth balances can be withdrawn proportionally
     */
    function countVotes()
    {
        require(icoSuccess && (stage==2 || stage==3) && now.sub(lastVoteTime) > minVoteTime);
        lastVoteTime = now;
        
        if(against > token.totalSupply()/2) {
            icoSuccess = false;
        } else {
            uint amount = amountRaisedICO/3 + amountRaisedPreSale/3;
            forward(amount);
            stage++;
        }
    }
    
}