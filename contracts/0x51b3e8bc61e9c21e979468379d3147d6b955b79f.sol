pragma solidity ^0.4.19;

/**
 * @title ERC20Basic
 * @dev Simpler version of ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/179
 */
contract ERC20Basic {
  function totalSupply() public view returns (uint256);
  function balanceOf(address who) public view returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {

  /**
  * @dev Multiplies two numbers, throws on overflow.
  */
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    assert(c / a == b);
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
  * @dev Substracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
  */
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  /**
  * @dev Adds two numbers, throws on overflow.
  */
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}


/**
 * @title Basic token
 * @dev Basic version of StandardToken, with no allowances.
 */
contract BasicToken is ERC20Basic {
  using SafeMath for uint256;

  mapping(address => uint256) balances;

  uint256 totalSupply_;

  /**
  * @dev total number of tokens in existence
  */
  function totalSupply() public view returns (uint256) {
    return totalSupply_;
  }

  /**
  * @dev transfer token for a specified address
  * @param _to The address to transfer to.
  * @param _value The amount to be transferred.
  */
  function transfer(address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));
    require(_value <= balances[msg.sender]);

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
  function balanceOf(address _owner) public view returns (uint256 balance) {
    return balances[_owner];
  }

}


/**
 * @title Burnable Token
 * @dev Token that can be irreversibly burned (destroyed).
 */
contract BurnableToken is BasicToken {

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
    balances[burner] = balances[burner].sub(_value);
    totalSupply_ = totalSupply_.sub(_value);
    Burn(burner, _value);
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

contract UBOCOIN is BurnableToken, Ownable
{
    // ERC20 token parameters
    string public constant name = "UBOCOIN";
    string public constant symbol = "UBO";
    uint8 public constant decimals = 18;
    
    
    // Crowdsale base price (before bonuses): 0.001 ETH per UBO
    uint256 private UBO_per_ETH = 1000 * (uint256(10) ** decimals);
    
    // 14 days with 43% bonus for purchases of at least 1000 UBO (19 february - 5 march)
    uint256 private constant pre_ICO_duration = 15 days;
    uint256 private constant pre_ICO_bonus_percentage = 43;
    uint256 private constant pre_ICO_bonus_minimum_purchased_UBO = 1000 * (uint256(10) ** decimals);
    
    // 21 days with 15% bonus (6 march - 26 march)
    uint256 private constant first_bonus_sale_duration = 21 days;
    uint256 private constant first_bonus_sale_bonus = 15;
    
    // 15 days with 10% bonus (27 march - 10 april)
    uint256 private constant second_bonus_sale_duration = 15 days;
    uint256 private constant second_bonus_sale_bonus = 10;
    
    // 8 days with 6% bonus (11 april - 18 april)
    uint256 private constant third_bonus_sale_duration = 8 days;
    uint256 private constant third_bonus_sale_bonus = 6;
    
    // 7 days with 3% bonus (19 april - 25 april)
    uint256 private constant fourth_bonus_sale_duration = 7 days;
    uint256 private constant fourth_bonus_sale_bonus = 3;
    
    // 5 days with no bonus (26 april - 30 april)
    uint256 private constant final_sale_duration = 5 days;
    
    
    // The target of the crowdsale is 3500000 UBICOINS.
    // If the crowdsale has finished, and the target has not been reached,
    // all crowdsale participants will be able to call refund() and get their
    // ETH back. The refundMany() function can be used to refund multiple
    // participants in one transaction.
    uint256 public constant crowdsaleTargetUBO = 3500000 * (uint256(10) ** decimals);
    
    
    // Variables that remember the start times of the various crowdsale periods
    uint256 private pre_ICO_start_timestamp;
    uint256 private first_bonus_sale_start_timestamp;
    uint256 private second_bonus_sale_start_timestamp;
    uint256 private third_bonus_sale_start_timestamp;
    uint256 private fourth_bonus_sale_start_timestamp;
    uint256 private final_sale_start_timestamp;
    uint256 private crowdsale_end_timestamp;
    
    
    // Publicly accessible trackers that indicate how much UBO is left
    // in each category
    uint256 public crowdsaleAmountLeft;
    uint256 public foundersAmountLeft;
    uint256 public earlyBackersAmountLeft;
    uint256 public teamAmountLeft;
    uint256 public bountyAmountLeft;
    uint256 public reservedFundLeft;
    
    // Keep track of all participants, how much they bought and how much they spent.
    address[] public allParticipants;
    mapping(address => uint256) public participantToEtherSpent;
    mapping(address => uint256) public participantToUBObought;
    
    
    function crowdsaleTargetReached() public view returns (bool)
    {
        return amountOfUBOsold() >= crowdsaleTargetUBO;
    }
    
    function crowdsaleStarted() public view returns (bool)
    {
        return pre_ICO_start_timestamp > 0 && now >= pre_ICO_start_timestamp;
    }
    
    function crowdsaleFinished() public view returns (bool)
    {
        return pre_ICO_start_timestamp > 0 && now >= crowdsale_end_timestamp;
    }
    
    function amountOfParticipants() external view returns (uint256)
    {
        return allParticipants.length;
    }
    
    function amountOfUBOsold() public view returns (uint256)
    {
        return totalSupply_ * 70 / 100 - crowdsaleAmountLeft;
    }
    
    // If the crowdsale target has not been reached, or the crowdsale has not finished,
    // don't allow the transfer of tokens purchased in the crowdsale.
    function transfer(address _to, uint256 _amount) public returns (bool)
    {
        if (!crowdsaleTargetReached() || !crowdsaleFinished())
        {
            require(balances[msg.sender] - participantToUBObought[msg.sender] >= _amount);
        }
        
        return super.transfer(_to, _amount);
    }
    
    
    // Constructor function
    function UBOCOIN() public
    {
        totalSupply_ = 300000000 * (uint256(10) ** decimals);
        balances[this] = totalSupply_;
        Transfer(0x0, this, totalSupply_);
        
        crowdsaleAmountLeft = totalSupply_ * 70 / 100;   // 70%
        foundersAmountLeft = totalSupply_ * 10 / 100;    // 10%
        earlyBackersAmountLeft = totalSupply_ * 5 / 100; // 5%
        teamAmountLeft = totalSupply_ * 5 / 100;         // 5%
        bountyAmountLeft = totalSupply_ * 5 / 100;       // 5%
        reservedFundLeft = totalSupply_ * 5 / 100;       // 5%
        
        setPreICOStartTime(1518998400); // This timstamp indicates 2018-02-19 00:00 UTC
    }
    
    function setPreICOStartTime(uint256 _timestamp) public onlyOwner
    {
        // If the crowdsale has already started, don't allow re-scheduling it.
        require(!crowdsaleStarted());
        
        pre_ICO_start_timestamp = _timestamp;
        first_bonus_sale_start_timestamp = pre_ICO_start_timestamp + pre_ICO_duration;
        second_bonus_sale_start_timestamp = first_bonus_sale_start_timestamp + first_bonus_sale_duration;
        third_bonus_sale_start_timestamp = second_bonus_sale_start_timestamp + second_bonus_sale_duration;
        fourth_bonus_sale_start_timestamp = third_bonus_sale_start_timestamp + third_bonus_sale_duration;
        final_sale_start_timestamp = fourth_bonus_sale_start_timestamp + fourth_bonus_sale_duration;
        crowdsale_end_timestamp = final_sale_start_timestamp + final_sale_duration;
    }
    
    function startPreICOnow() external onlyOwner
    {
        setPreICOStartTime(now);
    }
    
    function destroyUnsoldTokens() external
    {
        require(crowdsaleStarted() && crowdsaleFinished());
        
        uint256 amountToBurn = crowdsaleAmountLeft;
        crowdsaleAmountLeft = 0;
        this.burn(amountToBurn);
    }
    
    // If someone sends ETH to the contract address,
    // assume that they are trying to buy tokens.
    function () payable external
    {
        buyTokens();
    }
    
    function buyTokens() payable public
    {
        uint256 amountOfUBOpurchased = msg.value * UBO_per_ETH / (1 ether);
        
        // Only allow buying tokens if the ICO has started, and has not finished
        require(crowdsaleStarted());
        require(!crowdsaleFinished());
        
        // If the pre-ICO hasn't started yet, cancel the transaction
        if (now < pre_ICO_start_timestamp)
        {
            revert();
        }
        
        // If we are in the pre-ICO...
        else if (now >= pre_ICO_start_timestamp && now < first_bonus_sale_start_timestamp)
        {
            // If they purchased enough to be eligible for the pre-ICO bonus,
            // then give them the bonus
            if (amountOfUBOpurchased >= pre_ICO_bonus_minimum_purchased_UBO)
            {
                amountOfUBOpurchased = amountOfUBOpurchased * (100 + pre_ICO_bonus_percentage) / 100;
            }
        }
        
        // If we are in the first bonus sale...
        else if (now >= first_bonus_sale_start_timestamp && now < second_bonus_sale_start_timestamp)
        {
            amountOfUBOpurchased = amountOfUBOpurchased * (100 + first_bonus_sale_bonus) / 100;
        }
        
        // If we are in the second bonus sale...
        else if (now >= second_bonus_sale_start_timestamp && now < third_bonus_sale_start_timestamp)
        {
            amountOfUBOpurchased = amountOfUBOpurchased * (100 + second_bonus_sale_bonus) / 100;
        }
        
        // If we are in the third bonus sale...
        else if (now >= third_bonus_sale_start_timestamp && now < fourth_bonus_sale_start_timestamp)
        {
            amountOfUBOpurchased = amountOfUBOpurchased * (100 + third_bonus_sale_bonus) / 100;
        }
        
        // If we are in the fourth bonus sale...
        else if (now >= fourth_bonus_sale_start_timestamp && now < final_sale_start_timestamp)
        {
            amountOfUBOpurchased = amountOfUBOpurchased * (100 + fourth_bonus_sale_bonus) / 100;
        }
        
        // If we are in the final sale...
        else if (now >= final_sale_start_timestamp && now < crowdsale_end_timestamp)
        {
            // No bonus
        }
        
        // If we are passed the final sale, cancel the transaction.
        else
        {
            revert();
        }
        
        // Make sure the crowdsale has enough UBO left
        require(amountOfUBOpurchased <= crowdsaleAmountLeft);
        
        // Remove the tokens from this contract and the crowdsale tokens,
        // add them to the buyer
        crowdsaleAmountLeft -= amountOfUBOpurchased;
        balances[this] -= amountOfUBOpurchased;
        balances[msg.sender] += amountOfUBOpurchased;
        Transfer(this, msg.sender, amountOfUBOpurchased);
        
        // Track statistics
        if (participantToEtherSpent[msg.sender] == 0)
        {
            allParticipants.push(msg.sender);
        }
        participantToUBObought[msg.sender] += amountOfUBOpurchased;
        participantToEtherSpent[msg.sender] += msg.value;
    }
    
    function refund() external
    {
        // If the crowdsale has not started yet, don't allow refund
        require(crowdsaleStarted());
        
        // If the crowdsale has not finished yet, don't allow refund
        require(crowdsaleFinished());
        
        // If the target was reached, don't allow refund
        require(!crowdsaleTargetReached());
        
        _refundParticipant(msg.sender);
    }
    
    function refundMany(uint256 _startIndex, uint256 _endIndex) external
    {
        // If the crowdsale has not started yet, don't allow refund
        require(crowdsaleStarted());
        
        // If the crowdsale has not finished yet, don't allow refund
        require(crowdsaleFinished());
        
        // If the target was reached, don't allow refund
        require(!crowdsaleTargetReached());
        
        for (uint256 i=_startIndex; i<=_endIndex && i<allParticipants.length; i++)
        {
            _refundParticipant(allParticipants[i]);
        }
    }
    
    function _refundParticipant(address _participant) internal
    {
        if (participantToEtherSpent[_participant] > 0)
        {
            // Return the UBO they bought into the crowdsale funds
            uint256 refundUBO = participantToUBObought[_participant];
            participantToUBObought[_participant] = 0;
            balances[_participant] -= refundUBO;
            balances[this] += refundUBO;
            crowdsaleAmountLeft += refundUBO;
            Transfer(_participant, this, refundUBO);
            
            // Return the ETH they spent to buy them
            uint256 refundETH = participantToEtherSpent[_participant];
            participantToEtherSpent[_participant] = 0;
            _participant.transfer(refundETH);
        }
    }
    
    function distributeFounderTokens(address _founderAddress, uint256 _amount) external onlyOwner
    {
        require(_amount <= foundersAmountLeft);
        foundersAmountLeft -= _amount;
        this.transfer(_founderAddress, _amount);
    }
    
    function distributeEarlyBackerTokens(address _earlyBackerAddress, uint256 _amount) external onlyOwner
    {
        require(_amount <= earlyBackersAmountLeft);
        earlyBackersAmountLeft -= _amount;
        this.transfer(_earlyBackerAddress, _amount);
    }
    
    function distributeTeamTokens(address _teamMemberAddress, uint256 _amount) external onlyOwner
    {
        require(_amount <= teamAmountLeft);
        teamAmountLeft -= _amount;
        this.transfer(_teamMemberAddress, _amount);
    }
    
    function distributeBountyTokens(address _bountyReceiverAddress, uint256 _amount) external onlyOwner
    {
        require(_amount <= bountyAmountLeft);
        bountyAmountLeft -= _amount;
        this.transfer(_bountyReceiverAddress, _amount);
    }
    
    function distributeReservedTokens(address _to, uint256 _amount) external onlyOwner
    {
        require(_amount <= reservedFundLeft);
        reservedFundLeft -= _amount;
        this.transfer(_to, _amount);
    }
    
    function distributeCrowdsaleTokens(address _to, uint256 _amount) external onlyOwner
    {
        require(_amount <= crowdsaleAmountLeft);
        crowdsaleAmountLeft -= _amount;
        this.transfer(_to, _amount);
    }
    
    function ownerWithdrawETH() external onlyOwner
    {
        // Only allow the owner to withdraw if the crowdsale target has been reached
        require(crowdsaleTargetReached());
        
        owner.transfer(this.balance);
    }
}