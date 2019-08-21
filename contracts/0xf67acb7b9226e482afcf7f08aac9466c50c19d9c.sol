pragma solidity ^0.4.18;

contract GenericCrowdsale {
    address public icoBackend;
    address public icoManager;
    address public emergencyManager;

    // paused state
    bool paused = false;

    /**
     * @dev Confirms that token issuance for an off-chain purchase was processed successfully.
     * @param _beneficiary Token holder.
     * @param _contribution Money received (in USD cents). Copied from issueTokens call arguments.
     * @param _tokensIssued The amount of tokens that was assigned to the holder, not counting bonuses.
     */
    event TokensAllocated(address _beneficiary, uint _contribution, uint _tokensIssued);

    /**
     * @dev Notifies about bonus token issuance. Is raised even if the bonus is 0.
     * @param _beneficiary Token holder.
     * @param _bonusTokensIssued The amount of bonus tokens that was assigned to the holder.
     */
    event BonusIssued(address _beneficiary, uint _bonusTokensIssued);

    /**
     * @dev Issues tokens for founders and partners and closes the current phase.
     * @param foundersWallet Wallet address holding the vested tokens.
     * @param tokensForFounders The amount of tokens vested for founders.
     * @param partnersWallet Wallet address holding the tokens for early contributors.
     * @param tokensForPartners The amount of tokens issued for rewarding early contributors.
     */
    event FoundersAndPartnersTokensIssued(address foundersWallet, uint tokensForFounders,
                                          address partnersWallet, uint tokensForPartners);

    event Paused();
    event Unpaused();

    /**
     * @dev Issues tokens for the off-chain contributors by accepting calls from the trusted address.
     *        Supposed to be run by the backend.
     * @param _beneficiary Token holder.
     * @param _contribution The equivalent (in USD cents) of the contribution received off-chain.
     */
    function issueTokens(address _beneficiary, uint _contribution) onlyBackend onlyUnpaused external;

    /**
     * @dev Issues tokens for the off-chain contributors by accepting calls from the trusted address.
     *      Supposed to be run by the backend.
     * @param _beneficiary Token holder.
     * @param _contribution The equivalent (in USD cents) of the contribution received off-chain.
     * @param _tokens Total Tokens to issue for the contribution, must be > 0
     * @param _bonus How many tokens are bonuses, less or equal to _tokens
     */
    function issueTokensWithCustomBonus(address _beneficiary, uint _contribution, uint _tokens, uint _bonus) onlyBackend onlyUnpaused external;

    /**
     * @dev Pauses the token allocation process.
     */
    function pause() external onlyManager onlyUnpaused {
        paused = true;
        Paused();
    }

    /**
     * @dev Unpauses the token allocation process.
     */
    function unpause() external onlyManager onlyPaused {
        paused = false;
        Unpaused();
    }

    /**
     * @dev Allows the manager to change backends.
     */
    function changeicoBackend(address _icoBackend) external onlyManager {
        icoBackend = _icoBackend;
    }

    /**
     * @dev Modifiers
     */
    modifier onlyManager() {
        require(msg.sender == icoManager);
        _;
    }

    modifier onlyBackend() {
        require(msg.sender == icoBackend);
        _;
    }

    modifier onlyEmergency() {
        require(msg.sender == emergencyManager);
        _;
    }

    modifier onlyPaused() {
        require(paused == true);
        _;
    }

    modifier onlyUnpaused() {
        require(paused == false);
        _;
    }
}

/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20 {
  uint public totalSupply;

  function balanceOf(address _owner) constant public returns (uint balance);
  function transfer(address _to, uint _value) public returns (bool success);
  function transferFrom(address _from, address _to, uint _value) public returns (bool success);
  function approve(address _spender, uint _value) public returns (bool success);
  function allowance(address _owner, address _spender) constant public returns (uint remaining);

  event Transfer(address indexed _from, address indexed _to, uint value);
  event Approval(address indexed _owner, address indexed _spender, uint value);
}

library SafeMath {
   function mul(uint a, uint b) internal pure returns (uint) {
     if (a == 0) {
        return 0;
      }

      uint c = a * b;
      assert(c / a == b);
      return c;
   }

   function sub(uint a, uint b) internal pure returns (uint) {
      assert(b <= a);
      return a - b;
   }

   function add(uint a, uint b) internal pure returns (uint) {
      uint c = a + b;
      assert(c >= a);
      return c;
   }

  function div(uint a, uint b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }
}

contract StandardToken is ERC20 {
    using SafeMath for uint;

    mapping (address => uint) balances;
    mapping (address => mapping (address => uint)) allowed;

    function transfer(address _to, uint _value) onlyPayloadSize(2 * 32) public returns (bool) {
        if (balances[msg.sender] >= _value
            && _value > 0
            && _to != msg.sender
            && _to != address(0)
          ) {
            balances[msg.sender] = balances[msg.sender].sub(_value);
            balances[_to] = balances[_to].add(_value);

            Transfer(msg.sender, _to, _value);
            return true;
        }

        return false;
    }

    function transferFrom(address _from, address _to, uint _value) public returns (bool) {
        if (balances[_from] >= _value
            && allowed[_from][msg.sender] >= _value
            && _value > 0
            && _from != _to
          ) {
            balances[_to]   = balances[_to].add(_value);
            balances[_from] = balances[_from].sub(_value);
            allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
            Transfer(_from, _to, _value);
            return true;
        }

        return false;
    }

    function balanceOf(address _owner) constant public returns (uint) {
        return balances[_owner];
    }

    function allowance(address _owner, address _spender) constant public returns (uint) {
        return allowed[_owner][_spender];
    }

    function approve(address _spender, uint _value) public returns (bool) {
        require(_spender != address(0));
        // needs to be called twice -> first set to 0, then increase to another amount
        // this is to avoid race conditions
        require((_value == 0) || (allowed[msg.sender][_spender] == 0));

        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }

    function increaseApproval(address _spender, uint _addedValue) public returns (bool) {
        // useless operation
        require(_spender != address(0));

        // perform operation
        allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
        Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
        return true;
    }

    function decreaseApproval(address _spender, uint _subtractedValue) public returns (bool) {
        // useless operation
        require(_spender != address(0));

        uint oldValue = allowed[msg.sender][_spender];
        if (_subtractedValue > oldValue) {
            allowed[msg.sender][_spender] = 0;
        } else {
            allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
        }

        Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
        return true;
    }

    modifier onlyPayloadSize(uint _size) {
        require(msg.data.length >= _size + 4);
        _;
    }
}

contract Cappasity is StandardToken {

    // Constants
    // =========
    string public constant name = "Cappasity";
    string public constant symbol = "CAPP";
    uint8 public constant decimals = 2;
    uint public constant TOKEN_LIMIT = 10 * 1e9 * 1e2; // 10 billion tokens, 2 decimals

    // State variables
    // ===============
    address public manager;

    // Block token transfers until ICO is finished.
    bool public tokensAreFrozen = true;

    // Allow/Disallow minting
    bool public mintingIsAllowed = true;

    // events for minting
    event MintingAllowed();
    event MintingDisabled();

    // Freeze/Unfreeze assets
    event TokensFrozen();
    event TokensUnfrozen();

    // Constructor
    // ===========
    function Cappasity(address _manager) public {
        manager = _manager;
    }

    // Fallback function
    // Do not allow to send money directly to this contract
    function() payable public {
        revert();
    }

    // ERC20 functions
    // =========================
    function transfer(address _to, uint _value) public returns (bool) {
        require(!tokensAreFrozen);
        return super.transfer(_to, _value);
    }

    function transferFrom(address _from, address _to, uint _value) public returns (bool) {
        require(!tokensAreFrozen);
        return super.transferFrom(_from, _to, _value);
    }

    function approve(address _spender, uint _value) public returns (bool) {
        require(!tokensAreFrozen);
        return super.approve(_spender, _value);
    }

    function increaseApproval(address _spender, uint _addedValue) public returns (bool) {
        require(!tokensAreFrozen);
        return super.increaseApproval(_spender, _addedValue);
    }

    function decreaseApproval(address _spender, uint _subtractedValue) public returns (bool) {
        require(!tokensAreFrozen);
        return super.decreaseApproval(_spender, _subtractedValue);
    }

    // PRIVILEGED FUNCTIONS
    // ====================
    modifier onlyByManager() {
        require(msg.sender == manager);
        _;
    }

    // Mint some tokens and assign them to an address
    function mint(address _beneficiary, uint _value) external onlyByManager {
        require(_value != 0);
        require(totalSupply.add(_value) <= TOKEN_LIMIT);
        require(mintingIsAllowed == true);

        balances[_beneficiary] = balances[_beneficiary].add(_value);
        totalSupply = totalSupply.add(_value);
    }

    // Disable minting. Can be enabled later, but TokenAllocation.sol only does that once.
    function endMinting() external onlyByManager {
        require(mintingIsAllowed == true);
        mintingIsAllowed = false;
        MintingDisabled();
    }

    // Enable minting. See TokenAllocation.sol
    function startMinting() external onlyByManager {
        require(mintingIsAllowed == false);
        mintingIsAllowed = true;
        MintingAllowed();
    }

    // Disable token transfer
    function freeze() external onlyByManager {
        require(tokensAreFrozen == false);
        tokensAreFrozen = true;
        TokensFrozen();
    }

    // Allow token transfer
    function unfreeze() external onlyByManager {
        require(tokensAreFrozen == true);
        tokensAreFrozen = false;
        TokensUnfrozen();
    }
}

/**
 * @dev For the tokens issued for founders.
 */
contract VestingWallet {
    using SafeMath for uint;

    event TokensReleased(uint _tokensReleased, uint _tokensRemaining, uint _nextPeriod);

    address public foundersWallet;
    address public crowdsaleContract;
    ERC20 public tokenContract;

    // Two-year vesting with 1 month cliff. Roughly.
    bool public vestingStarted = false;
    uint constant cliffPeriod = 30 days;
    uint constant totalPeriods = 24;

    uint public periodsPassed = 0;
    uint public nextPeriod;
    uint public tokensRemaining;
    uint public tokensPerBatch;

    // Constructor
    // ===========
    function VestingWallet(address _foundersWallet, address _tokenContract) public {
        require(_foundersWallet != address(0));
        require(_tokenContract != address(0));

        foundersWallet    = _foundersWallet;
        tokenContract     = ERC20(_tokenContract);
        crowdsaleContract = msg.sender;
    }

    // PRIVILEGED FUNCTIONS
    // ====================
    function releaseBatch() external onlyFounders {
        require(true == vestingStarted);
        require(now > nextPeriod);
        require(periodsPassed < totalPeriods);

        uint tokensToRelease = 0;
        do {
            periodsPassed   = periodsPassed.add(1);
            nextPeriod      = nextPeriod.add(cliffPeriod);
            tokensToRelease = tokensToRelease.add(tokensPerBatch);
        } while (now > nextPeriod);

        // If vesting has finished, just transfer the remaining tokens.
        if (periodsPassed >= totalPeriods) {
            tokensToRelease = tokenContract.balanceOf(this);
            nextPeriod = 0x0;
        }

        tokensRemaining = tokensRemaining.sub(tokensToRelease);
        tokenContract.transfer(foundersWallet, tokensToRelease);

        TokensReleased(tokensToRelease, tokensRemaining, nextPeriod);
    }

    function launchVesting() public onlyCrowdsale {
        require(false == vestingStarted);

        vestingStarted  = true;
        tokensRemaining = tokenContract.balanceOf(this);
        nextPeriod      = now.add(cliffPeriod);
        tokensPerBatch  = tokensRemaining / totalPeriods;
    }

    // INTERNAL FUNCTIONS
    // ==================
    modifier onlyFounders() {
        require(msg.sender == foundersWallet);
        _;
    }

    modifier onlyCrowdsale() {
        require(msg.sender == crowdsaleContract);
        _;
    }
}

/**
* @dev Prepaid token allocation for a capped crowdsale with bonus structure sliding on sales
*      Written with OpenZeppelin sources as a rough reference.
*/
contract TokenAllocation is GenericCrowdsale {
    using SafeMath for uint;

    // Events
    event TokensAllocated(address _beneficiary, uint _contribution, uint _tokensIssued);
    event BonusIssued(address _beneficiary, uint _bonusTokensIssued);
    event FoundersAndPartnersTokensIssued(address _foundersWallet, uint _tokensForFounders,
                                          address _partnersWallet, uint _tokensForPartners);

    // Token information
    uint public tokenRate = 125; // 1 USD = 125 CAPP; so 1 cent = 1.25 CAPP \
                                 // assuming CAPP has 2 decimals (as set in token contract)
    Cappasity public tokenContract;

    address public foundersWallet; // A wallet permitted to request tokens from the time vaults.
    address public partnersWallet; // A wallet that distributes the tokens to early contributors.

    // Crowdsale progress
    uint constant public hardCap     = 5 * 1e7 * 1e2; // 50 000 000 dollars * 100 cents per dollar
    uint constant public phaseOneCap = 3 * 1e7 * 1e2; // 30 000 000 dollars * 100 cents per dollar
    uint public totalCentsGathered = 0;

    // Total sum gathered in phase one, need this to adjust the bonus tiers in phase two.
    // Updated only once, when the phase one is concluded.
    uint public centsInPhaseOne = 0;
    uint public totalTokenSupply = 0;     // Counting the bonuses, not counting the founders' share.

    // Total tokens issued in phase one, including bonuses. Need this to correctly calculate the founders' \
    // share and issue it in parts, once after each round. Updated when issuing tokens.
    uint public tokensDuringPhaseOne = 0;
    VestingWallet public vestingWallet;

    enum CrowdsalePhase { PhaseOne, BetweenPhases, PhaseTwo, Finished }
    enum BonusPhase { TenPercent, FivePercent, None }

    uint public constant bonusTierSize = 1 * 1e7 * 1e2; // 10 000 000 dollars * 100 cents per dollar
    uint public constant bigContributionBound  = 1 * 1e5 * 1e2; // 100 000 dollars * 100 cents per dollar
    uint public constant hugeContributionBound = 3 * 1e5 * 1e2; // 300 000 dollars * 100 cents per dollar
    CrowdsalePhase public crowdsalePhase = CrowdsalePhase.PhaseOne;
    BonusPhase public bonusPhase = BonusPhase.TenPercent;

    /**
     * @dev Constructs the allocator.
     * @param _icoBackend Wallet address that should be owned by the off-chain backend, from which \
     *          \ it mints the tokens for contributions accepted in other currencies.
     * @param _icoManager Allowed to start phase 2.
     * @param _foundersWallet Where the founders' tokens to to after vesting.
     * @param _partnersWallet A wallet that distributes tokens to early contributors.
     */
    function TokenAllocation(address _icoManager,
                             address _icoBackend,
                             address _foundersWallet,
                             address _partnersWallet,
                             address _emergencyManager
                             ) public {
        require(_icoManager != address(0));
        require(_icoBackend != address(0));
        require(_foundersWallet != address(0));
        require(_partnersWallet != address(0));
        require(_emergencyManager != address(0));

        tokenContract = new Cappasity(address(this));

        icoManager       = _icoManager;
        icoBackend       = _icoBackend;
        foundersWallet   = _foundersWallet;
        partnersWallet   = _partnersWallet;
        emergencyManager = _emergencyManager;
    }

    // PRIVILEGED FUNCTIONS
    // ====================
    /**
     * @dev Issues tokens for a particular address as for a contribution of size _contribution, \
     *          \ then issues bonuses in proportion.
     * @param _beneficiary Receiver of the tokens.
     * @param _contribution Size of the contribution (in USD cents).
     */
    function issueTokens(address _beneficiary, uint _contribution) external onlyBackend onlyValidPhase onlyUnpaused {
        // phase 1 cap less than hard cap
        if (crowdsalePhase == CrowdsalePhase.PhaseOne) {
            require(totalCentsGathered.add(_contribution) <= phaseOneCap);
        } else {
            require(totalCentsGathered.add(_contribution) <= hardCap);
        }

        uint remainingContribution = _contribution;

        // Check if the contribution fills the current bonus phase. If so, break it up in parts,
        // mint tokens for each part separately, assign bonuses, trigger events. For transparency.
        do {
            // 1 - calculate contribution part for current bonus stage
            uint centsLeftInPhase = calculateCentsLeftInPhase(remainingContribution);
            uint contributionPart = min(remainingContribution, centsLeftInPhase);

            // 3 - mint tokens
            uint tokensToMint = tokenRate.mul(contributionPart);
            mintAndUpdate(_beneficiary, tokensToMint);
            TokensAllocated(_beneficiary, contributionPart, tokensToMint);

            // 4 - mint bonus
            uint tierBonus = calculateTierBonus(contributionPart);
            if (tierBonus > 0) {
                mintAndUpdate(_beneficiary, tierBonus);
                BonusIssued(_beneficiary, tierBonus);
            }

            // 5 - advance bonus phase
            if ((bonusPhase != BonusPhase.None) && (contributionPart == centsLeftInPhase)) {
                advanceBonusPhase();
            }

            // 6 - log the processed part of the contribution
            totalCentsGathered = totalCentsGathered.add(contributionPart);
            remainingContribution = remainingContribution.sub(contributionPart);

            // 7 - continue?
        } while (remainingContribution > 0);

        // Mint contribution size bonus
        uint sizeBonus = calculateSizeBonus(_contribution);
        if (sizeBonus > 0) {
            mintAndUpdate(_beneficiary, sizeBonus);
            BonusIssued(_beneficiary, sizeBonus);
        }
    }

    /**
     * @dev Issues tokens for the off-chain contributors by accepting calls from the trusted address.
     *        Supposed to be run by the backend. Used for distributing bonuses for affiliate transactions
     *        and special offers
     *
     * @param _beneficiary Token holder.
     * @param _contribution The equivalent (in USD cents) of the contribution received off-chain.
     * @param _tokens Total token allocation size
     * @param _bonus Bonus size
     */
    function issueTokensWithCustomBonus(address _beneficiary, uint _contribution, uint _tokens, uint _bonus)
                                            external onlyBackend onlyValidPhase onlyUnpaused {

        // sanity check, ensure we allocate more than 0
        require(_tokens > 0);
        // all tokens can be bonuses, but they cant be less than bonuses
        require(_tokens >= _bonus);
        // check capps
        if (crowdsalePhase == CrowdsalePhase.PhaseOne) {
            // ensure we are not over phase 1 cap after this contribution
            require(totalCentsGathered.add(_contribution) <= phaseOneCap);
        } else {
            // ensure we are not over hard cap after this contribution
            require(totalCentsGathered.add(_contribution) <= hardCap);
        }

        uint remainingContribution = _contribution;

        // Check if the contribution fills the current bonus phase. If so, break it up in parts,
        // mint tokens for each part separately, assign bonuses, trigger events. For transparency.
        do {
          // 1 - calculate contribution part for current bonus stage
          uint centsLeftInPhase = calculateCentsLeftInPhase(remainingContribution);
          uint contributionPart = min(remainingContribution, centsLeftInPhase);

          // 3 - log the processed part of the contribution
          totalCentsGathered = totalCentsGathered.add(contributionPart);
          remainingContribution = remainingContribution.sub(contributionPart);

          // 4 - advance bonus phase
          if ((remainingContribution == centsLeftInPhase) && (bonusPhase != BonusPhase.None)) {
              advanceBonusPhase();
          }

        } while (remainingContribution > 0);

        // add tokens to the beneficiary
        mintAndUpdate(_beneficiary, _tokens);

        // if tokens arent equal to bonus
        if (_tokens > _bonus) {
          TokensAllocated(_beneficiary, _contribution, _tokens.sub(_bonus));
        }

        // if bonus exists
        if (_bonus > 0) {
          BonusIssued(_beneficiary, _bonus);
        }
    }

    /**
     * @dev Issues the rewards for founders and early contributors. 18% and 12% of the total token supply by the end
     *   of the crowdsale, respectively, including all the token bonuses on early contributions. Can only be
     *   called after the end of the crowdsale phase, ends the current phase.
     */
    function rewardFoundersAndPartners() external onlyManager onlyValidPhase onlyUnpaused {
        uint tokensDuringThisPhase;
        if (crowdsalePhase == CrowdsalePhase.PhaseOne) {
            tokensDuringThisPhase = totalTokenSupply;
        } else {
            tokensDuringThisPhase = totalTokenSupply - tokensDuringPhaseOne;
        }

        // Total tokens sold is 70% of the overall supply, founders' share is 18%, early contributors' is 12%
        // So to obtain those from tokens sold, multiply them by 0.18 / 0.7 and 0.12 / 0.7 respectively.
        uint tokensForFounders = tokensDuringThisPhase.mul(257).div(1000); // 0.257 of 0.7 is 0.18 of 1
        uint tokensForPartners = tokensDuringThisPhase.mul(171).div(1000); // 0.171 of 0.7 is 0.12 of 1

        tokenContract.mint(partnersWallet, tokensForPartners);

        if (crowdsalePhase == CrowdsalePhase.PhaseOne) {
            vestingWallet = new VestingWallet(foundersWallet, address(tokenContract));
            tokenContract.mint(address(vestingWallet), tokensForFounders);
            FoundersAndPartnersTokensIssued(address(vestingWallet), tokensForFounders,
                                            partnersWallet,         tokensForPartners);

            // Store the total sum collected during phase one for calculations in phase two.
            centsInPhaseOne = totalCentsGathered;
            tokensDuringPhaseOne = totalTokenSupply;

            // Enable token transfer.
            tokenContract.unfreeze();
            crowdsalePhase = CrowdsalePhase.BetweenPhases;
        } else {
            tokenContract.mint(address(vestingWallet), tokensForFounders);
            vestingWallet.launchVesting();

            FoundersAndPartnersTokensIssued(address(vestingWallet), tokensForFounders,
                                            partnersWallet,         tokensForPartners);
            crowdsalePhase = CrowdsalePhase.Finished;
        }

        tokenContract.endMinting();
   }

    /**
     * @dev Set the CAPP / USD rate for Phase two, and then start the second phase of token allocation.
     *        Can only be called by the crowdsale manager.
     * _tokenRate How many CAPP per 1 USD cent. As dollars, CAPP has two decimals.
     *            For instance: tokenRate = 125 means "1.25 CAPP per USD cent" <=> "125 CAPP per USD".
     */
    function beginPhaseTwo(uint _tokenRate) external onlyManager onlyUnpaused {
        require(crowdsalePhase == CrowdsalePhase.BetweenPhases);
        require(_tokenRate != 0);

        tokenRate = _tokenRate;
        crowdsalePhase = CrowdsalePhase.PhaseTwo;
        bonusPhase = BonusPhase.TenPercent;
        tokenContract.startMinting();
    }

    /**
     * @dev Allows to freeze all token transfers in the future
     * This is done to allow migrating to new contract in the future
     * If such need ever arises (ie Migration to ERC23, or anything that community decides worth doing)
     */
    function freeze() external onlyUnpaused onlyEmergency {
        require(crowdsalePhase != CrowdsalePhase.PhaseOne);
        tokenContract.freeze();
    }

    function unfreeze() external onlyUnpaused onlyEmergency {
        require(crowdsalePhase != CrowdsalePhase.PhaseOne);
        tokenContract.unfreeze();
    }

    // INTERNAL FUNCTIONS
    // ====================
    function calculateCentsLeftInPhase(uint _remainingContribution) internal view returns(uint) {
        // Ten percent bonuses happen in both Phase One and Phase two, therefore:
        // Take the bonus tier size, subtract the total money gathered in the current phase
        if (bonusPhase == BonusPhase.TenPercent) {
            return bonusTierSize.sub(totalCentsGathered.sub(centsInPhaseOne));
        }

        if (bonusPhase == BonusPhase.FivePercent) {
          // Five percent bonuses only happen in Phase One, so no need to account
          // for the first phase separately.
          return bonusTierSize.mul(2).sub(totalCentsGathered);
        }

        return _remainingContribution;
    }

    function mintAndUpdate(address _beneficiary, uint _tokensToMint) internal {
        tokenContract.mint(_beneficiary, _tokensToMint);
        totalTokenSupply = totalTokenSupply.add(_tokensToMint);
    }

    function calculateTierBonus(uint _contribution) constant internal returns (uint) {
        // All bonuses are additive and not multiplicative
        // Calculate bonus on contribution size, then convert it to bonus tokens.
        uint tierBonus = 0;

        // tierBonus tier tierBonuses. We make sure in issueTokens that the processed contribution \
        // falls entirely into one tier
        if (bonusPhase == BonusPhase.TenPercent) {
            tierBonus = _contribution.div(10); // multiply by 0.1
        } else if (bonusPhase == BonusPhase.FivePercent) {
            tierBonus = _contribution.div(20); // multiply by 0.05
        }

        tierBonus = tierBonus.mul(tokenRate);
        return tierBonus;
    }

    function calculateSizeBonus(uint _contribution) constant internal returns (uint) {
        uint sizeBonus = 0;
        if (crowdsalePhase == CrowdsalePhase.PhaseOne) {
            // 10% for huge contribution
            if (_contribution >= hugeContributionBound) {
                sizeBonus = _contribution.div(10); // multiply by 0.1
            // 5% for big one
            } else if (_contribution >= bigContributionBound) {
                sizeBonus = _contribution.div(20); // multiply by 0.05
            }

            sizeBonus = sizeBonus.mul(tokenRate);
        }
        return sizeBonus;
    }


    /**
     * @dev Advance the bonus phase to next tier when appropriate, do nothing otherwise.
     */
    function advanceBonusPhase() internal onlyValidPhase {
        if (crowdsalePhase == CrowdsalePhase.PhaseOne) {
            if (bonusPhase == BonusPhase.TenPercent) {
                bonusPhase = BonusPhase.FivePercent;
            } else if (bonusPhase == BonusPhase.FivePercent) {
                bonusPhase = BonusPhase.None;
            }
        } else if (bonusPhase == BonusPhase.TenPercent) {
            bonusPhase = BonusPhase.None;
        }
    }

    function min(uint _a, uint _b) internal pure returns (uint result) {
        return _a < _b ? _a : _b;
    }

    /**
     * Modifiers
     */
    modifier onlyValidPhase() {
        require( crowdsalePhase == CrowdsalePhase.PhaseOne
                 || crowdsalePhase == CrowdsalePhase.PhaseTwo );
        _;
    }

    // Do not allow to send money directly to this contract
    function() payable public {
        revert();
    }
}