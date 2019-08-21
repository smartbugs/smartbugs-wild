pragma solidity ^0.4.8;


/**
 * Math operations with safety checks
 * By OpenZeppelin: https://github.com/OpenZeppelin/zeppelin-solidity/contracts/SafeMath.sol
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

contract ContractReceiver {
    function tokenFallback(address _from, uint256 _value, bytes  _data) external;
}

contract Ownable {
    address public owner;
    address public ownerCandidate;
    event OwnerTransfer(address originalOwner, address currentOwner);

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    function proposeNewOwner(address newOwner) public onlyOwner {
        require(newOwner != address(0) && newOwner != owner);
        ownerCandidate = newOwner;
    }

    function acceptOwnerTransfer() public {
        require(msg.sender == ownerCandidate);
        OwnerTransfer(owner, ownerCandidate);
        owner = ownerCandidate;
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
    require(_value <= balances[_from]);
    require(_value <= allowed[_from][msg.sender]);

    balances[_from] = balances[_from].sub(_value);
    balances[_to] = balances[_to].add(_value);
    allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
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


// Based in part on code by Open-Zeppelin: https://github.com/OpenZeppelin/zeppelin-solidity.git
// Based in part on code by FirstBlood: https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol
// Smart contract for the RepuX token & the first crowdsale
contract RepuX is StandardToken, Ownable {
    string public constant name = "RepuX";
    string public constant symbol = "REPUX";
    uint8 public constant decimals = 18;
    address public multisig; //multisig wallet, to which all contributions will be sent

    uint256 public phase1StartBlock; //Crowdsale start block
    uint256 public phase1EndBlock; // Day 7 (estimate)
    uint256 public phase2EndBlock; // Day 13 (estimate)
    uint256 public phase3EndBlock; // Day 19 (estimate)
    uint256 public phase4EndBlock; // Day 25 (estimate)
    uint256 public phase5EndBlock; // Day 31 (estimate)
    uint256 public endBlock; //whole crowdsale end block

    uint256 public basePrice = 1818 * (10**11); // ICO token base price: ~$0.20 (estimate assuming $1100 per Eth)

    uint256 public totalSupply = 500000000 * (10**uint256(decimals)); //Token total supply: 500000000 RPX
    uint256 public presaleTokenSupply = totalSupply.mul(20).div(100); //Amount of tokens available during presale (10%)
    uint256 public crowdsaleTokenSupply = totalSupply.mul(30).div(100); //Amount of tokens available during crowdsale (50%)
    uint256 public rewardsTokenSupply = totalSupply.mul(15).div(100); //Rewards pool (VIP etc, 10%), ambassador share(3%) & ICO bounties(2%)
    uint256 public teamTokenSupply = totalSupply.mul(12).div(100); //Tokens distributed to team (12% in total, 4% vested for 12, 24 & 36 months)
    uint256 public platformTokenSupply = totalSupply.mul(23).div(100); //Token reserve for sale on platform
    uint256 public presaleTokenSold = 0; //Records the amount of tokens sold during presale
    uint256 public crowdsaleTokenSold = 0; //Records the amount of tokens sold during the crowdsale

    uint256 public phase1Cap = crowdsaleTokenSupply.mul(50).div(100);
    uint256 public phase2Cap = crowdsaleTokenSupply.mul(60).div(100);
    uint256 public phase3Cap = crowdsaleTokenSupply.mul(70).div(100);
    uint256 public phase4Cap = crowdsaleTokenSupply.mul(80).div(100);

    uint256 public transferLockup = 5760; //Lock up token transfer until ~2 days after crowdsale concludes
    uint256 public teamLockUp; 
    uint256 private teamWithdrawlCount = 0;
    uint256 public averageBlockTime = 18; //Average block time in seconds

    bool public presaleStarted = false;
    bool public presaleConcluded = false;
    bool public crowdsaleStarted = false;
    bool public crowdsaleConcluded = false;
    bool public ICOReserveWithdrawn = false;
    bool public halted = false; //Halt crowdsale in emergency

    uint256 contributionCount = 0;
    bytes32[] public contributionHashes;
    mapping (bytes32 => Contribution) private contributions;

    address public teamWithdrawalRecipient = address(0);
    bool public teamWithdrawalProposed = false;
    bool teamWithdrawn = false;

    event Halt(); //Halt event
    event Unhalt(); //Unhalt event
    event Burn(address burner, uint256 amount);
    event StartPresale();
    event ConcludePresale();
    event StartCrowdsale();
    event ConcludeCrowdsale();
    event SetMultisig(address newMultisig);

    struct Contribution {
        address contributor;
        address recipient;
        uint256 ethWei;
        uint256 tokens;
        bool resolved;
        bool success;
        uint8 stage;
    }

    event ContributionReceived(bytes32 contributionHash, address contributor, address recipient,
        uint256 ethWei, uint256 pendingTokens);

    event ContributionResolved(bytes32 contributionHash, bool pass, address contributor, 
        address recipient, uint256 ethWei, uint256 tokens);


    // lockup during and after 48h of end of crowdsale
    modifier crowdsaleTransferLock() {
        require(crowdsaleConcluded && block.number >= endBlock.add(transferLockup));
        _;
    }

    modifier whenNotHalted() {
        require(!halted);
        _;
    }

    //Constructor: set owner (team) address & crowdsale recipient multisig wallet address
    //Allocate reward tokens to the team wallet
  	function RepuX(address _multisig) {
        owner = msg.sender;
        multisig = _multisig;
  	}

    //Fallback function when receiving Ether. Contributors can directly send Ether to the token address during crowdsale.
    function() payable {
        buy();
    }


    //Halt ICO in case of emergency.
    function halt() public onlyOwner {
        halted = true;
        Halt();
    }

    function unhalt() public onlyOwner {
        halted = false;
        Unhalt();
    }

    function startPresale() public onlyOwner {
        require(!presaleStarted);
        presaleStarted = true;
        StartPresale();
    }

    function concludePresale() public onlyOwner {
        require(presaleStarted && !presaleConcluded);
        presaleConcluded = true;
        //Unsold tokens in the presale are made available in the crowdsale.
        crowdsaleTokenSupply = crowdsaleTokenSupply.add(presaleTokenSupply.sub(presaleTokenSold)); 
        ConcludePresale();
    }

    //Can only be called after presale is concluded.
    function startCrowdsale() public onlyOwner {
        require(presaleConcluded && !crowdsaleStarted);
        crowdsaleStarted = true;
        phase1StartBlock = block.number;
        phase1EndBlock = phase1StartBlock.add(dayToBlockNumber(7));
        phase2EndBlock = phase1EndBlock.add(dayToBlockNumber(6));
        phase3EndBlock = phase2EndBlock.add(dayToBlockNumber(6));
        phase4EndBlock = phase3EndBlock.add(dayToBlockNumber(6));
        phase5EndBlock = phase4EndBlock.add(dayToBlockNumber(6));
        endBlock = phase5EndBlock;
        StartCrowdsale();
    }

    //Can only be called either after crowdsale time period ends, or after tokens have sold out
    function concludeCrowdsale() public onlyOwner {
        require(crowdsaleStarted && !crowdsaleOn() && !crowdsaleConcluded);
        crowdsaleConcluded = true;
        endBlock = block.number;
        uint256 unsold = crowdsaleTokenSupply.sub(crowdsaleTokenSold);
        if (unsold > 0) {
            //Burn unsold tokens
            totalSupply = totalSupply.sub(unsold);
            Burn(this, unsold);
            Transfer(this, address(0), unsold);
        }
        teamLockUp = dayToBlockNumber(365); //12-month lock-up period
        ConcludeCrowdsale();
    }

    function proposeTeamWithdrawal(address recipient) public onlyOwner {
        require(!teamWithdrawn);
        teamWithdrawalRecipient = recipient;
        teamWithdrawalProposed = true;
    }

    function cancelTeamWithdrawal() public onlyOwner {
        require(!teamWithdrawn);
        require(teamWithdrawalProposed);
        teamWithdrawalProposed = false;
        teamWithdrawalRecipient = address(0); 
    }

    function confirmTeamWithdrawal() public {
        require(!teamWithdrawn);
        require(teamWithdrawalProposed);
        require(msg.sender == teamWithdrawalRecipient);
        teamWithdrawn = true;
        uint256 tokens = rewardsTokenSupply.add(teamTokenSupply).add(platformTokenSupply);
        balances[msg.sender] = balances[msg.sender].add(tokens);
        Transfer(this, msg.sender, tokens);
    }


    function buy() payable {
        buyRecipient(msg.sender);
    }


    //Allow addresses to buy token for another account
    function buyRecipient(address recipient) public payable whenNotHalted {
        require(msg.value > 0);
        require(presaleOn()||crowdsaleOn()); //Contribution only allowed during presale/crowdsale
        uint256 tokens = msg.value.mul(10**uint256(decimals)).div(tokenPrice()); 
        uint8 stage = 0;

        if(presaleOn()) {
            require(presaleTokenSold.add(tokens) <= presaleTokenSupply);
            presaleTokenSold = presaleTokenSold.add(tokens);
        } else {
            require(crowdsaleTokenSold.add(tokens) <= crowdsaleTokenSupply);
            crowdsaleTokenSold = crowdsaleTokenSold.add(tokens);
            stage = 1;
        }
        contributionCount = contributionCount.add(1);
        bytes32 transactionHash = keccak256(contributionCount, msg.sender, msg.value, msg.data,
            msg.gas, block.number, tx.gasprice);
        contributions[transactionHash] = Contribution(msg.sender, recipient, msg.value, 
            tokens, false, false, stage);
        contributionHashes.push(transactionHash);
        ContributionReceived(transactionHash, msg.sender, recipient, msg.value, tokens);
    }

    //Accept a contribution if KYC passed.
    function acceptContribution(bytes32 transactionHash) public onlyOwner {
        Contribution storage c = contributions[transactionHash];
        require(!c.resolved);
        c.resolved = true;
        c.success = true;
        balances[c.recipient] = balances[c.recipient].add(c.tokens);
        assert(multisig.send(c.ethWei));
        Transfer(this, c.recipient, c.tokens);
        ContributionResolved(transactionHash, true, c.contributor, c.recipient, c.ethWei, 
            c.tokens);
    }

    //Reject a contribution if KYC failed.
    function rejectContribution(bytes32 transactionHash) public onlyOwner {
        Contribution storage c = contributions[transactionHash];
        require(!c.resolved);
        c.resolved = true;
        c.success = false;
        if (c.stage == 0) {
            presaleTokenSold = presaleTokenSold.sub(c.tokens);
        } else {
            crowdsaleTokenSold = crowdsaleTokenSold.sub(c.tokens);
        }
        assert(c.contributor.send(c.ethWei));
        ContributionResolved(transactionHash, false, c.contributor, c.recipient, c.ethWei, 
            c.tokens);
    }

    // Team manually mints tokens in case of BTC/wire-transfer contributions
    function mint(address recipient, uint256 value) public onlyOwner {
    	require(value > 0);
    	require(presaleOn()||crowdsaleOn()); //Minting only allowed during presale/crowdsale
    	if(presaleOn()) {
            require(presaleTokenSold.add(value) <= presaleTokenSupply);
            presaleTokenSold = presaleTokenSold.add(value);
        } else {
            require(crowdsaleTokenSold.add(value) <= crowdsaleTokenSupply);
            crowdsaleTokenSold = crowdsaleTokenSold.add(value);
        }
        balances[recipient] = balances[recipient].add(value);
        Transfer(this, recipient, value);
    }


    //Burns the specified amount of tokens from the team wallet address
    function burn(uint256 _value) public onlyOwner returns (bool) {
        balances[msg.sender] = balances[msg.sender].sub(_value);
        totalSupply = totalSupply.sub(_value);
        Transfer(msg.sender, address(0), _value);
        Burn(msg.sender, _value);
        return true;
    }

    //Allow team to change the recipient multisig address
    function setMultisig(address addr) public onlyOwner {
      	require(addr != address(0));
      	multisig = addr;
        SetMultisig(addr);
    }

    //Allows Team to adjust average blocktime according to network status, 
    //in order to provide more precise timing for ICO phases & lock-up periods
    function setAverageBlockTime(uint256 newBlockTime) public onlyOwner {
        require(newBlockTime > 0);
        averageBlockTime = newBlockTime;
    }

    //Allows Team to adjust basePrice so price of the token has correct correlation to dollar
    function setBasePrice(uint256 newBasePrice) public onlyOwner {
        require(newBasePrice > 0);
        basePrice = newBasePrice;
    }

    function transfer(address _to, uint256 _value) public crowdsaleTransferLock 
    returns(bool) {
        return super.transfer(_to, _value);
    }

    function transferFrom(address _from, address _to, uint256 _value) public 
    crowdsaleTransferLock returns(bool) {
        return super.transferFrom(_from, _to, _value);
    }

    //Price of token in terms of ether.
    function tokenPrice() public constant returns(uint256) {
        uint8 p = phase();
        if (p == 0) return basePrice.mul(50).div(100); //Presale: 50% discount
        if (p == 1) return basePrice.mul(70).div(100); //ICO phase 1: 30% discount
        if (p == 2) return basePrice.mul(75).div(100); //Phase 2 :25% discount
        if (p == 3) return basePrice.mul(80).div(100); //Phase 3: 20% discount
        if (p == 4) return basePrice.mul(85).div(100); //Phase 4: 15% discount
        if (p == 5) return basePrice.mul(90).div(100); //Phase 5: 10% discount
        return basePrice;
    }

    function phase() public constant returns (uint8) {
        if (presaleOn()) return 0;
        if (crowdsaleTokenSold <= phase1Cap && block.number <= phase1EndBlock) return 1;
        if (crowdsaleTokenSold <= phase2Cap && block.number <= phase2EndBlock) return 2;
        if (crowdsaleTokenSold <= phase3Cap && block.number <= phase3EndBlock) return 3;
        if (crowdsaleTokenSold <= phase4Cap && block.number <= phase4EndBlock) return 4;
        if (crowdsaleTokenSold <= crowdsaleTokenSupply && block.number <= phase5EndBlock) return 5;
        return 6;
    }

    function presaleOn() public constant returns (bool) {
        return (presaleStarted && !presaleConcluded && presaleTokenSold < presaleTokenSupply);
    }

    function crowdsaleOn() public constant returns (bool) {
        return (crowdsaleStarted && block.number <= endBlock && crowdsaleTokenSold < crowdsaleTokenSupply);
    }

    function dayToBlockNumber(uint256 dayNum) public constant returns(uint256) {
        return dayNum.mul(86400).div(averageBlockTime); //86400 = 24*60*60 = number of seconds in a day
    }

    function getContributionFromHash(bytes32 contributionHash) public constant returns (
            address contributor,
            address recipient,
            uint256 ethWei,
            uint256 tokens,
            bool resolved,
            bool success
        ) {
        Contribution c = contributions[contributionHash];
        contributor = c.contributor;
        recipient = c.recipient;
        ethWei = c.ethWei;
        tokens = c.tokens;
        resolved = c.resolved;
        success = c.success;
    }

    function getContributionHashes() public constant returns (bytes32[]) {
        return contributionHashes;
    }

}