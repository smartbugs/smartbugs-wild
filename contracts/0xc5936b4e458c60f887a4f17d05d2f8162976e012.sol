pragma solidity ^0.4.17;

/**
 * V 1.0. 
 * (C) profit-chain.net Licensed under MIT terms
 *
 * ProfitChain is a game allowing participants to win some Ether. Based on Ethereum intrinsic randomness and difficulty, you must be either lucky or one
 * hell of a hacker to win... Read the code, and if you find a problem, write owner AT profit-chain.net !
 *
 * Investors participate in rounds of fixed size and investment. Once a round is full, a new one opens automatically.
 * A single winner is picked per round, raking all the round's investments (minus invitor fees).
 *
 * Each investor must provide an invitor address when making the first investment in the group.
 * The game includes a time and depth limited invitation pyramid - you must invest first, then you can invite others. As invitor you'll enjoy a part of invitees investment
 * and wins, as well as their sub-invitees, for a limited time, and up to certain number of generations.
 *
 * There are multiple groups, each with its specific characteristics- to cater to all players.
 * 
 * We deter hacking of the winner by making it non-economical:
 * There is a "security factor" K, which is larger than the group round size N.
 * For example, for N=10 we may choose K=50.
 * A few blocks following the round's last investment, the winner is picked if the block's hash mod K is a number of 1...N.
 * If a hacker miner made a single invetment in the round, the miner would have to match 1 out of 50 "guesses", ie. 50 times greater effort than usual...
 * If a hacker miner made all invetments but one in the round, the miner would have to match 9 of of 50 "guesses", or about 5 times greater than usual...
 * And then there's the participation fees, that render even that last scenario non-economical.
 *
 * It would take a little over K blocks on average to declare the winner.
 * At 15 seconds per block, if K=50, it would take on average 13 minutes after the last investment, before a winner is found.
 * BUT! 
 * Winner declaration is temporary - checking is done on last 255 blocks. So even if a winner exists now, the winner must be actively named using a transaction while relevant.
 * A "checkAndDeclareWinner" transaction is required to write the winner (at the time of the transaction!) into the blockchain.
 * 
 * All Ether withdrawals, after wins or invitor fees payouts, require execution of a "withdraw" transaction, for safety. 
 */


contract ProfitChain {

    using SafeMath256 for uint256;
    using SafeMath32 for uint32;
    
    // types
    
    struct Investment {
        address investor;               // who made the investment
        uint256 sum;                    // actual investment, after fees deduction
        uint256 time;                   // investment time
    }
    
    struct Round {
        mapping(uint32 => Investment) investments;      // all investments made in round
        mapping (address => uint32) investorMapping;    // quickly find an investor by address
        uint32 totalInvestors;          // the number of investors in round so far
        uint256 totalInvestment;        // the sum of all investments in round, so far
        address winner;                 // winner of the round (0 if not yet known)
        uint256 lastBlock;              // block number of latest investment
    }
    
    struct GroupMember {
        uint256 joinTime;               // when the pariticipant joined the group
        address invitor;                // who invited the participant
    }

    struct Group {
        string name;                    // group name
        uint32 roundSize;               // round size (number of investors)
        uint256 investment;             // investment size in wei
        uint32 blocksBeforeWinCheck;    // how many blocks to wait after round's final investment, prior to determining the winner
        uint32 securityFactor;          // security factor, larger than the group size, to make hacking difficult
        uint32 invitationFee;           // promiles of invitation fee out of investment and winning
        uint32 ownerFee;                // promiles of owner fee out of investment
        uint32 invitationFeePeriod;     // number of days an invitation incurs fees
        uint8 invitationFeeDepth;       // how many invitors can be paid up the invitation chain
        bool active;                    // is the group open for new rounds?
        mapping (address => GroupMember) members;   // all the group members
        mapping(uint32 => Round) rounds;            // rounds of this group
        uint32 currentRound;            // the current round
        uint32 firstUnwonRound;         // the oldest round we need to check for win
    }
    
    
    // variables
    string public contractName = "ProfitChain 1.0";
    uint256 public contractBlock;               // block of contract
    address public owner;                       // owner of the contract
    mapping (address => uint256) balances;      // balance of each investor
    Group[] groups;                             // all groups
    mapping (string => bool) groupNames;        // for exclusivity of group names

    // modifiers
    modifier onlyOwner() {require(msg.sender == owner); _;}
    
    // events
    event GroupCreated(uint32 indexed group, uint256 timestamp);
    event GroupClosed(uint32 indexed group, uint256 timestamp);
    event NewInvestor(address indexed investor, uint32 indexed group, uint256 timestamp);
    event Invest(address indexed investor, uint32 indexed group, uint32 indexed round, uint256 timestamp);
    event Winner(address indexed payee, uint32 indexed group, uint32 indexed round, uint256 timestamp);
    event Deposit(address indexed payee, uint256 sum, uint256 timestamp);
    event Withdraw(address indexed payee, uint256 sum, uint256 timestamp);

    // functions
    
    /**
     * Constructor:
     * - owner account
     */
    function ProfitChain () public {
        owner = msg.sender;
        contractBlock = block.number;
    }

    /**
     * if someones sends Ether directly to the contract - fail it!
     */
    function /* fallback */ () public payable {
        revert();
    } 

    /**
     * Create new group (only owner)
     */
    function newGroup (
        string _groupName, 
        uint32 _roundSize,
        uint256 _investment,
        uint32 _blocksBeforeWinCheck,
        uint32 _securityFactor,
        uint32 _invitationFee,
        uint32 _ownerFee,
        uint32 _invitationFeePeriod,
        uint8 _invitationFeeDepth
    ) public onlyOwner 
    {
        // some basic tests
        require(_roundSize > 0);
        require(_investment > 0);
        require(_invitationFee.add(_ownerFee) < 1000);
        require(_securityFactor > _roundSize);
        // check if group name exists
        require(!groupNameExists(_groupName));
        
        // create the group
        Group memory group;
        group.name = _groupName;
        group.roundSize = _roundSize;
        group.investment = _investment;
        group.blocksBeforeWinCheck = _blocksBeforeWinCheck;
        group.securityFactor = _securityFactor;
        group.invitationFee = _invitationFee;
        group.ownerFee = _ownerFee;
        group.invitationFeePeriod = _invitationFeePeriod;
        group.invitationFeeDepth = _invitationFeeDepth;
        group.active = true;
        // group.currentRound = 0; // initialized with 0 anyway
        // group.firstUnwonRound = 0; // initialized with 0 anyway
        
        groups.push(group);
        groupNames[_groupName] = true;

        // notify world
        GroupCreated(uint32(groups.length).sub(1), block.timestamp);
    }

    /**
     * Close group (only owner)
     * Once closed, it will not initiate new rounds.
     */
    function closeGroup(uint32 _group) onlyOwner public {
        // verify group exists and not closed
        require(groupExists(_group));
        require(groups[_group].active);
        
        groups[_group].active = false;

        // notify the world
        GroupClosed(_group, block.timestamp);
    } 
    
    
    /**
     * Join group and make first investment
     * Invitor must already belong to group (or be owner), investor must not.
     */
     
    function joinGroupAndInvest(uint32 _group, address _invitor) payable public {
        address investor = msg.sender;
        // owner is not allowed to invest
        require(msg.sender != owner);
        // check group exists, investor does not yet belong to group, and invitor exists (or owner)
        Group storage thisGroup = groups[_group];
        require(thisGroup.roundSize > 0);
        require(thisGroup.members[_invitor].joinTime > 0 || _invitor == owner);
        require(thisGroup.members[investor].joinTime == 0);
        // check payment is as required
        require(msg.value == thisGroup.investment);
        
        // add investor to group
        thisGroup.members[investor].joinTime = block.timestamp;
        thisGroup.members[investor].invitor = _invitor;
        
        // notify the world
        NewInvestor(investor, _group, block.timestamp);
        
        // make the first investment
        invest(_group);
    }

    /**
     * Invest in a group
     * Can invest once per round.
     * Must be a member of the group.
     */
    function invest(uint32 _group) payable public {
        address investor = msg.sender;
        Group storage thisGroup = groups[_group];
        uint32 round = thisGroup.currentRound;
        Round storage thisRound = thisGroup.rounds[round];
        
        // check the group is still open for business - only if we're about to be the first investors
        require(thisGroup.active || thisRound.totalInvestors > 0);
        
        // check payment is as required
        require(msg.value == thisGroup.investment);
        // verify we're members
        require(thisGroup.members[investor].joinTime > 0);
        // verify we're not already investors in this round
        require(! isInvestorInRound(thisRound, investor));
        
        // notify the world
        Invest(investor, _group, round, block.timestamp);

        // calculate fees. there are owner fee and invitor fee
        uint256 ownerFee = msg.value.mul(thisGroup.ownerFee).div(1000);
        balances[owner] = balances[owner].add(ownerFee);
        Deposit(owner, ownerFee, block.timestamp);
                
        uint256 investedSumLessOwnerFee = msg.value.sub(ownerFee);

        uint256 invitationFee = payAllInvitors(thisGroup, investor, block.timestamp, investedSumLessOwnerFee, 0);

        uint256 investedNetSum = investedSumLessOwnerFee.sub(invitationFee);
        
        // join the round
        thisRound.investorMapping[investor] = thisRound.totalInvestors;
        thisRound.investments[thisRound.totalInvestors] = Investment({
            investor: investor,
            sum: investedNetSum,
            time: block.timestamp});
        
        thisRound.totalInvestors = thisRound.totalInvestors.add(1);
        thisRound.totalInvestment = thisRound.totalInvestment.add(investedNetSum);
        
        // check if this round has been completely populated. If so, close this round and prepare the next round
        if (thisRound.totalInvestors == thisGroup.roundSize) {
            thisGroup.currentRound = thisGroup.currentRound.add(1);
            thisRound.lastBlock = block.number;
        }

        // every investor also helps by checking for a previous winner.
        address winner;
        string memory reason;
        (winner, reason) = checkWinnerInternal(thisGroup);
        if (winner != 0)
            declareWinner(_group, winner);
    }

    
    /**
     * withdraw collects due funds in a safe manner
     */
    function withdraw(uint256 sum) public {
        address withdrawer = msg.sender;
        // do we have enough funds for withdrawal?
        require(balances[withdrawer] >= sum);

        // notify the world
        Withdraw(withdrawer, sum, block.timestamp);
        
        // update (safely)
        balances[withdrawer] = balances[withdrawer].sub(sum);
        withdrawer.transfer(sum);
    }
    
    /**
     * checkWinner checks if at the time of the call a winner exists for the currently earliest unwon round of the given group.
     * No declaration is made - so another winner could be selected later!
     */
    function checkWinner(uint32 _group) public constant returns (bool foundWinner, string reason) {
        Group storage thisGroup = groups[_group];
        require(thisGroup.roundSize > 0);
        address winner;
        (winner, reason) = checkWinnerInternal(thisGroup);
        foundWinner = winner != 0;
    }
    
    /**
     * checkAndDeclareWinner checks if at the time of the call a winner exists for the currently earliest unwon round of the given group,
     * and then declares the winner.
     * Reverts if no winner found, to prevent unnecessary gas expenses.
     */

    function checkAndDeclareWinner(uint32 _group) public {
        Group storage thisGroup = groups[_group];
        require(thisGroup.roundSize > 0);
        address winner;
        string memory reason;
        (winner, reason) = checkWinnerInternal(thisGroup);
        // revert if no winner found
        require(winner != 0);
        // let's declare the winner!
        declareWinner(_group, winner);
    }

    /**
     * declareWinner etches the winner into the blockchain.
     */

    function declareWinner(uint32 _group, address _winner) internal {
        // let's declare the winner!
        Group storage thisGroup = groups[_group];
        Round storage unwonRound = thisGroup.rounds[thisGroup.firstUnwonRound];
    
        unwonRound.winner = _winner;
        
        // notify the world
        Winner(_winner, _group, thisGroup.firstUnwonRound, block.timestamp);
        uint256 wonSum = unwonRound.totalInvestment;
        
        wonSum = wonSum.sub(payAllInvitors(thisGroup, _winner, block.timestamp, wonSum, 0));
        
        balances[_winner] = balances[_winner].add(wonSum);
        
        Deposit(_winner, wonSum, block.timestamp);
            
        // update the unwon round
        thisGroup.firstUnwonRound = thisGroup.firstUnwonRound.add(1);
    }

    /**
     * checkWinnerInernal tries finding a winner for the oldest non-decided round.
     * Returns winner != 0 iff a new winner was found, as well as reason
     */
    function checkWinnerInternal(Group storage thisGroup) internal constant returns (address winner, string reason) {
        winner = 0; // assume have not found a new winner
        // some tests
        // the first round has no previous rounds to check
        if (thisGroup.currentRound == 0) {
            reason = 'Still in first round';
            return;
        }
        // we don't check current round - by definition it is not full
        if (thisGroup.currentRound == thisGroup.firstUnwonRound) {
            reason = 'No unwon finished rounds';
            return;
        }
     
        Round storage unwonRound = thisGroup.rounds[thisGroup.firstUnwonRound];
        
        // we will scan a range of blocks, from unwonRound.lastBlock + thisGroup.blocksBeforeWinCheck;
        uint256 firstBlock = unwonRound.lastBlock.add(thisGroup.blocksBeforeWinCheck);
        // but we can't scan more than 255 blocks into the past
        // the first test is for testing environments that may have less than 256 blocks :)
        if (block.number > 255 && firstBlock < block.number.sub(255))
            firstBlock = block.number.sub(255);
        // the scan ends at the last committed block
        uint256 lastBlock = block.number.sub(1);

        for (uint256 thisBlock = firstBlock; thisBlock <= lastBlock; thisBlock = thisBlock.add(1)) {
            uint256 latestHash = uint256(block.blockhash(thisBlock));
            // we're "drawing" a winner out of the security-factor-sized group - perhaps no winner at all  
            uint32 drawn = uint32(latestHash % thisGroup.securityFactor);
            if (drawn < thisGroup.roundSize) {
                // we have a winner!
                winner = unwonRound.investments[drawn].investor;
                return;
            }
        }
        reason = 'No winner picked';
    } 
    
    /**
     * Given a group, investor and amount of wei, pay all the eligible invitors.
     * NOTE: does not draw from the _payer balance - we're assuming the returned value will be deducted when necessary.
     * NOTE 2: a recursive call, yet the depth is limited by 8-bits so no real stack concren.
     * Return the amount of wei to be deducted from the payer
     */
    function payAllInvitors(Group storage thisGroup, address _payer, uint256 _relevantTime, uint256 _amount, uint32 _depth) internal returns (uint256 invitationFee) {

        address invitor = thisGroup.members[_payer].invitor;
        // conditions for payment:
        if (
        // the payer's invitor is not the owner...
            invitor == owner ||
        // must have something to share...
            _amount == 0 ||
        // no more than specified depth
            _depth >= thisGroup.invitationFeeDepth ||
        // the invitor's invitation time has not expired
            _relevantTime > thisGroup.members[_payer].joinTime.add(thisGroup.invitationFeePeriod.mul(1 days))
        ) {
            return;
        }

        // compute how much to pay
        invitationFee = _amount.mul(thisGroup.invitationFee).div(1000);
        
        // we may have reached rock bottom - don't continue
        if (invitationFee == 0) return;

        // calculate recursively even higher-hierarcy fees
        uint256 invitorFee = payAllInvitors(thisGroup, invitor, _relevantTime,  invitationFee, _depth.add(1));
        
        // out net invitation fees are...
        uint256 paid = invitationFee.sub(invitorFee);
        
        // pay
        balances[invitor] = balances[invitor].add(paid);
        
        // notify the world
        Deposit(invitor, paid, block.timestamp);
    }


    
    /**
     * Is a specific investor in a specific round?
     */
    function isInvestorInRound(Round storage _round, address _investor) internal constant returns (bool investorInRound) {
        return (_round.investments[_round.investorMapping[_investor]].investor == _investor);
    }
    
    
    /**
     * Get info about specific account
     */
    function balanceOf(address investor) public constant returns (uint256 balance) {
        balance = balances[investor];
    }
    
     
    /**
     * Get info about groups
     */
    function groupsCount() public constant returns (uint256 count) {
        count = groups.length;
    }
     
    /**
     * Get info about specific group
     */ 
    function groupInfo(uint32 _group) public constant returns (
        string name,
        uint32 roundSize,
        uint256 investment,
        uint32 blocksBeforeWinCheck,
        uint32 securityFactor,
        uint32 invitationFee,
        uint32 ownerFee,
        uint32 invitationFeePeriod,
        uint8 invitationFeeDepth,
        bool active,
        uint32 currentRound,
        uint32 firstUnwonRound
    ) {
        require(groupExists(_group));
        Group storage thisGroup = groups[_group];
        name = thisGroup.name;
        roundSize = thisGroup.roundSize;
        investment = thisGroup.investment;
        blocksBeforeWinCheck = thisGroup.blocksBeforeWinCheck;
        securityFactor = thisGroup.securityFactor;
        invitationFee = thisGroup.invitationFee;
        ownerFee = thisGroup.ownerFee;
        invitationFeePeriod = thisGroup.invitationFeePeriod;
        invitationFeeDepth = thisGroup.invitationFeeDepth;
        active = thisGroup.active;
        currentRound = thisGroup.currentRound;
        firstUnwonRound = thisGroup.firstUnwonRound;
    }
    
     
    /**
     * Get info about specific group member
     */
    function groupMemberInfo (uint32 _group, address investor) public constant returns (
        uint256 joinTime,
        address invitor
    ) {
        require(groupExists(_group));
        GroupMember storage groupMember = groups[_group].members[investor];
        joinTime = groupMember.joinTime;
        invitor = groupMember.invitor;
    }
    
    /**
     * Get info about specific group's round
     */
    function roundInfo (uint32 _group, uint32 _round) public constant returns (
        uint32 totalInvestors,
        uint256 totalInvestment,
        address winner,
        uint256 lastBlock
    ) {
        require(groupExists(_group));
        Round storage round = groups[_group].rounds[_round];
        totalInvestors = round.totalInvestors;
        totalInvestment = round.totalInvestment;
        winner = round.winner;
        lastBlock = round.lastBlock;
    } 
    
    /**
     * Get info about specific round's investment, by investor
     */
    function roundInvestorInfoByAddress (uint32 _group, uint32 _round, address investor) public constant returns (
        bool inRound,
        uint32 index
    ) {
        require(groupExists(_group));
        index = groups[_group].rounds[_round].investorMapping[investor];
        inRound = isInvestorInRound(groups[_group].rounds[_round], investor);
    }
    
    /**
     * Get info about specific round's investment - by index
     */
    function roundInvestorInfoByIndex (uint32 _group, uint32 _round, uint32 _index) public constant returns (
        address investor,
        uint256 sum,
        uint256 time
    ) {
        require(groupExists(_group));
        require(groups[_group].rounds[_round].totalInvestors > _index);
        Investment storage investment = groups[_group].rounds[_round].investments[_index];
        investor = investment.investor;
        sum = investment.sum;
        time = investment.time;
    }

    /**
     * Does group name exist?
     */
    function groupNameExists(string _groupName) internal constant returns (bool exists) {
        return groupNames[_groupName];
    }

    function groupExists(uint32 _group) internal constant returns (bool exists) {
        return _group < groups.length;
    }

}





library SafeMath256 {
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a * b;
    require(a == 0 || c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // require(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // require(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    require(c >= a);
    return c;
  }
}

library SafeMath32 {
  function mul(uint32 a, uint32 b) internal pure returns (uint32) {
    uint32 c = a * b;
    require(a == 0 || c / a == b);
    return c;
  }

  function div(uint32 a, uint32 b) internal pure returns (uint32) {
    // require(b > 0); // Solidity automatically throws when dividing by 0
    uint32 c = a / b;
    // require(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  function sub(uint32 a, uint32 b) internal pure returns (uint32) {
    require(b <= a);
    return a - b;
  }

  function add(uint32 a, uint32 b) internal pure returns (uint32) {
    uint32 c = a + b;
    require(c >= a);
    return c;
  }
}