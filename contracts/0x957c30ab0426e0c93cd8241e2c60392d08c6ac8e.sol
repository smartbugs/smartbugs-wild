pragma solidity ^0.4.14;

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

//Interface declaration from: https://github.com/ethereum/eips/issues/20
contract ERC20Interface {
    //from: https://github.com/OpenZeppelin/zeppelin-solidity/blob/b395b06b65ce35cac155c13d01ab3fc9d42c5cfb/contracts/token/ERC20Basic.sol
    uint256 public totalSupply; //tokens that can vote, transfer, receive dividend
    function balanceOf(address who) public constant returns (uint256);
    function transfer(address to, uint256 value) public returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    //from: https://github.com/OpenZeppelin/zeppelin-solidity/blob/b395b06b65ce35cac155c13d01ab3fc9d42c5cfb/contracts/token/ERC20.sol
    function allowance(address owner, address spender) public constant returns (uint256);
    function transferFrom(address from, address to, uint256 value) public returns (bool);
    function approve(address spender, uint256 value) public returns (bool);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract ModumToken is ERC20Interface {

    using SafeMath for uint256;

    address public owner;

    mapping(address => mapping (address => uint256)) public allowed;

    enum UpdateMode{Wei, Vote, Both} //update mode for the account
    struct Account {
        uint256 lastProposalStartTime; //For checking at which proposal valueModVote was last updated
        uint256 lastAirdropWei; //For checking after which airDrop bonusWei was last updated
        uint256 lastAirdropClaimTime; //for unclaimed airdrops, re-airdrop
        uint256 bonusWei;      //airDrop/Dividend payout available for withdrawal.
        uint256 valueModVote;  // votes available for voting on active Proposal
        uint256 valueMod;      // the owned tokens
    }
    mapping(address => Account) public accounts;

    //Airdorp
    uint256 public totalDropPerUnlockedToken = 0;     //totally airdropped eth per unlocked token
    uint256 public rounding = 0;                      //airdrops not accounted yet to make system rounding error proof

    //Token locked/unlocked - totalSupply/max
    uint256 public lockedTokens = 9 * 1100 * 1000;   //token that need to be unlocked by voting
    uint256 public constant maxTokens = 30 * 1000 * 1000;      //max distributable tokens

    //minting phase running if false, true otherwise. Many operations can only be called when
    //minting phase is over
    bool public mintDone = false;
    uint256 public constant redistributionTimeout = 548 days; //18 month

    //as suggested in https://theethereum.wiki/w/index.php/ERC20_Token_Standard
    string public constant name = "Modum Token";
    string public constant symbol = "MOD";
    uint8 public constant decimals = 0;

    //Voting
    struct Proposal {
        string addr;        //Uri for more info
        bytes32 hash;       //Hash of the uri content for checking
        uint256 valueMod;      //token to unlock: proposal with 0 amount is invalid
        uint256 startTime;
        uint256 yay;
        uint256 nay;
    }
    Proposal public currentProposal;
    uint256 public constant votingDuration = 2 weeks;
    uint256 public lastNegativeVoting = 0;
    uint256 public constant blockingDuration = 90 days;

    event Voted(address _addr, bool option, uint256 votes); //called when a vote is casted
    event Payout(uint256 weiPerToken); //called when an someone payed ETHs to this contract, that can be distributed

    function ModumToken() public {
        owner = msg.sender;
    }

    /**
     * In case an owner account gets compromised, it should be possible to move control
     * over to another account. This helps in cases like the Parity multisig exploit: As
     * soon as an exploit becomes known, the affected parties might have a small time
     * window before being attacked.
     */
    function transferOwnership(address _newOwner) public {
        require(msg.sender == owner);
        require(_newOwner != address(0));
        owner = _newOwner;
    }

    //*************************** Voting *****************************************
    /*
     * In addition to the the vode with address/URL and its hash, we also set the value
     * of tokens to be transfered from the locked tokens to the modum account.
     */
    function votingProposal(string _addr, bytes32 _hash, uint256 _value) public {
        require(msg.sender == owner); // proposal ony by onwer
        require(!isProposalActive()); // no proposal is active, cannot vote in parallel
        require(_value <= lockedTokens); //proposal cannot be larger than remaining locked tokens
        require(_value > 0); //there needs to be locked tokens to make proposal, at least 1 locked token
        require(_hash != bytes32(0)); //hash need to be set
        require(bytes(_addr).length > 0); //the address need to be set and non-empty
        require(mintDone); //minting phase needs to be over
        //in case of negative vote, wait 90 days. If no lastNegativeVoting have
        //occured, lastNegativeVoting is 0 and now is always larger than 14.1.1970
        //(1.1.1970 plus blockingDuration).
        require(now >= lastNegativeVoting.add(blockingDuration));

        currentProposal = Proposal(_addr, _hash, _value, now, 0, 0);
    }

    function vote(bool _vote) public returns (uint256) {
        require(isVoteOngoing()); // vote needs to be ongoing
        Account storage account = updateAccount(msg.sender, UpdateMode.Vote);
        uint256 votes = account.valueModVote; //available votes
        require(votes > 0); //voter must have a vote left, either by not voting yet, or have modum tokens

        if(_vote) {
            currentProposal.yay = currentProposal.yay.add(votes);
        }
        else {
            currentProposal.nay = currentProposal.nay.add(votes);
        }

        account.valueModVote = 0;
        Voted(msg.sender, _vote, votes);
        return votes;
    }

    function showVotes(address _addr) public constant returns (uint256) {
        Account memory account = accounts[_addr];
        if(account.lastProposalStartTime < currentProposal.startTime || // the user did set his token power yet
            (account.lastProposalStartTime == 0 && currentProposal.startTime == 0)) {
            return account.valueMod;
        }
        return account.valueModVote;
    }

    // The voting can be claimed by the owner of this contract
    function claimVotingProposal() public {
        require(msg.sender == owner); //only owner can claim proposal
        require(isProposalActive()); // proposal active
        require(isVotingPhaseOver()); // voting has already ended

        if(currentProposal.yay > currentProposal.nay && currentProposal.valueMod > 0) {
            //Vote was accepted
            Account storage account = updateAccount(owner, UpdateMode.Both);
            uint256 valueMod = currentProposal.valueMod;
            account.valueMod = account.valueMod.add(valueMod); //add tokens to owner
            totalSupply = totalSupply.add(valueMod);
            lockedTokens = lockedTokens.sub(valueMod);
        } else if(currentProposal.yay <= currentProposal.nay) {
            //in case of a negative vote, set the time of this negative
            //vote to the end of the negative voting period.
            //This will prevent any new voting to be conducted.
            lastNegativeVoting = currentProposal.startTime.add(votingDuration);
        }
        delete currentProposal; //proposal ended
    }

    function isProposalActive() public constant returns (bool)  {
        return currentProposal.hash != bytes32(0);
    }

    function isVoteOngoing() public constant returns (bool)  {
        return isProposalActive()
            && now >= currentProposal.startTime
            && now < currentProposal.startTime.add(votingDuration);
        //its safe to use it for longer periods:
        //https://ethereum.stackexchange.com/questions/6795/is-block-timestamp-safe-for-longer-time-periods
    }

    function isVotingPhaseOver() public constant returns (bool)  {
        //its safe to use it for longer periods:
        //https://ethereum.stackexchange.com/questions/6795/is-block-timestamp-safe-for-longer-time-periods
        return now >= currentProposal.startTime.add(votingDuration);
    }

    //*********************** Minting *****************************************
    function mint(address[] _recipient, uint256[] _value) public {
        require(msg.sender == owner); //only owner can claim proposal
        require(!mintDone); //only during minting
        //require(_recipient.length == _value.length); //input need to be of same size
        //we know what we are doing... remove check to save gas

        //we want to mint a couple of accounts
        for (uint8 i=0; i<_recipient.length; i++) {
            
            //require(lockedTokens.add(totalSupply).add(_value[i]) <= maxTokens);
            //do the check in the mintDone

            //121 gas can be saved by creating temporary variables
            address tmpRecipient = _recipient[i];
            uint tmpValue = _value[i];

            //no need to update account, as we have not set minting to true. This means
            //nobody can start a proposal (isVoteOngoing() is always false) and airdrop
            //cannot be done either totalDropPerUnlockedToken is 0 thus, bonus is always
            //zero.
            Account storage account = accounts[tmpRecipient];
            account.valueMod = account.valueMod.add(tmpValue);
            //if this remains 0, we cannot calculate the time period when the user claimed
            //his airdrop, thus, set it to now
            account.lastAirdropClaimTime = now;
            totalSupply = totalSupply.add(tmpValue); //create the tokens and add to recipient
            Transfer(msg.sender, tmpRecipient, tmpValue);
        }
    }

    function setMintDone() public {
        require(msg.sender == owner);
        require(!mintDone); //only in minting phase
        //here we check that we never exceed the 30mio max tokens. This includes
        //the locked and the unlocked tokens.
        require(lockedTokens.add(totalSupply) <= maxTokens);
        mintDone = true; //end the minting
    }

    //updates an account for voting or airdrop or both. This is required to be able to fix the amount of tokens before
    //a vote or airdrop happend.
    function updateAccount(address _addr, UpdateMode mode) internal returns (Account storage){
        Account storage account = accounts[_addr];
        if(mode == UpdateMode.Vote || mode == UpdateMode.Both) {
            if(isVoteOngoing() && account.lastProposalStartTime < currentProposal.startTime) {// the user did set his token power yet
                account.valueModVote = account.valueMod;
                account.lastProposalStartTime = currentProposal.startTime;
            }
        }

        if(mode == UpdateMode.Wei || mode == UpdateMode.Both) {
            uint256 bonus = totalDropPerUnlockedToken.sub(account.lastAirdropWei);
            if(bonus != 0) {
                account.bonusWei = account.bonusWei.add(bonus.mul(account.valueMod));
                account.lastAirdropWei = totalDropPerUnlockedToken;
            }
        }

        return account;
    }

    //*********************** Airdrop ************************************************
    //default function to pay bonus, anybody that sends eth to this contract will distribute the wei
    //to their token holders
    //Dividend payment / Airdrop
    function() public payable {
        require(mintDone); //minting needs to be over
        require(msg.sender == owner); //ETH payment need to be one-way only, from modum to tokenholders, confirmed by Lykke
        payout(msg.value);
    }
    
    //anybody can pay and add address that will be checked if they
    //can be added to the bonus
    function payBonus(address[] _addr) public payable {
        require(msg.sender == owner);  //ETH payment need to be one-way only, from modum to tokenholders, confirmed by Lykke
        uint256 totalWei = 0;
        for (uint8 i=0; i<_addr.length; i++) {
            Account storage account = updateAccount(_addr[i], UpdateMode.Wei);
            if(now >= account.lastAirdropClaimTime + redistributionTimeout) {
                totalWei += account.bonusWei;
                account.bonusWei = 0;
                account.lastAirdropClaimTime = now;
            } else {
                revert();
            }
        }
        payout(msg.value.add(totalWei));
    }
    
    function payout(uint256 valueWei) internal {
        uint256 value = valueWei.add(rounding); //add old rounding
        rounding = value % totalSupply; //ensure no rounding error
        uint256 weiPerToken = value.sub(rounding).div(totalSupply);
        totalDropPerUnlockedToken = totalDropPerUnlockedToken.add(weiPerToken); //account for locked tokens and add the drop
        Payout(weiPerToken);
    }

    function showBonus(address _addr) public constant returns (uint256) {
        uint256 bonus = totalDropPerUnlockedToken.sub(accounts[_addr].lastAirdropWei);
        if(bonus != 0) {
            return accounts[_addr].bonusWei.add(bonus.mul(accounts[_addr].valueMod));
        }
        return accounts[_addr].bonusWei;
    }

    function claimBonus() public returns (uint256) {
        require(mintDone); //minting needs to be over

        Account storage account = updateAccount(msg.sender, UpdateMode.Wei);
        uint256 sendValue = account.bonusWei; //fetch the values

        if(sendValue != 0) {
            account.bonusWei = 0; //set to zero (before, against reentry)
            account.lastAirdropClaimTime = now; //mark as collected now
            msg.sender.transfer(sendValue); //send the bonus to the correct account
            return sendValue;
        }
        return 0;
    }

    //****************************** ERC20 ************************************

    // Get the account balance of another account with address _owner
    function balanceOf(address _owner) public constant returns (uint256 balance) {
        return accounts[_owner].valueMod;
    }

    // Send _value amount of tokens to address _to
    function transfer(address _to, uint256 _value) public returns (bool success) {
        require(mintDone);
        require(_value > 0);
        Account memory tmpFrom = accounts[msg.sender];
        require(tmpFrom.valueMod >= _value);

        Account storage from = updateAccount(msg.sender, UpdateMode.Both);
        Account storage to = updateAccount(_to, UpdateMode.Both);
        from.valueMod = from.valueMod.sub(_value);
        to.valueMod = to.valueMod.add(_value);
        Transfer(msg.sender, _to, _value);
        return true;
    }

    // Send _value amount of tokens from address _from to address _to
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require(mintDone);
        require(_value > 0);
        Account memory tmpFrom = accounts[_from];
        require(tmpFrom.valueMod >= _value);
        require(allowed[_from][msg.sender] >= _value);

        Account storage from = updateAccount(_from, UpdateMode.Both);
        Account storage to = updateAccount(_to, UpdateMode.Both);
        from.valueMod = from.valueMod.sub(_value);
        to.valueMod = to.valueMod.add(_value);
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
        Transfer(msg.sender, _to, _value);
        return true;
    }

    // ********************** approve, allowance, increaseApproval, and decreaseApproval used from:
    // https://github.com/OpenZeppelin/zeppelin-solidity/blob/master/contracts/token/StandardToken.sol
    //
    // changed from uint to uint256 as this is considered to be best practice.

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

    /*
     * approve should be called when allowed[_spender] == 0. To increment
     * allowed value is better to use this function to avoid 2 calls (and wait until
     * the first transaction is mined)
     * From MonolithDAO Token.sol
     */
    function increaseApproval(address _spender, uint256 _addedValue) public returns (bool success) {
        allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
        Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
        return true;
    }

    function decreaseApproval(address _spender, uint256 _subtractedValue) public returns (bool success) {
        uint256 oldValue = allowed[msg.sender][_spender];
        if(_subtractedValue > oldValue) {
            allowed[msg.sender][_spender] = 0;
        } else {
            allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
        }
        Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
        return true;
    }
}