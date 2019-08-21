pragma solidity ^0.4.24;

/*******************************************************************************
 *
 * Copyright (c) 2018 Decentralization Authority MDAO.
 * Released under the MIT License.
 *
 * ZeroGold POW Mining
 * 
 * An ERC20 token wallet which dispenses tokens via Proof of Work mining.
 * Based on recommendation from /u/diego_91
 * 
 * Version 18.8.19
 *
 * Web    : https://d14na.org
 * Email  : support@d14na.org
 */


/*******************************************************************************
 *
 * SafeMath
 */
library SafeMath {
    function add(uint a, uint b) internal pure returns (uint c) {
        c = a + b;
        require(c >= a);
    }
    function sub(uint a, uint b) internal pure returns (uint c) {
        require(b <= a);
        c = a - b;
    }
    function mul(uint a, uint b) internal pure returns (uint c) {
        c = a * b;
        require(a == 0 || c / a == b);
    }
    function div(uint a, uint b) internal pure returns (uint c) {
        require(b > 0);
        c = a / b;
    }
}


/*******************************************************************************
 *
 * Owned contract
 */
contract Owned {
    address public owner;
    address public newOwner;

    event OwnershipTransferred(address indexed _from, address indexed _to);

    constructor() public {
        owner = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    function transferOwnership(address _newOwner) public onlyOwner {
        newOwner = _newOwner;
    }

    function acceptOwnership() public {
        require(msg.sender == newOwner);

        emit OwnershipTransferred(owner, newOwner);

        owner = newOwner;

        newOwner = address(0);
    }
}


/*******************************************************************************
 *
 * ERC Token Standard #20 Interface
 * https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20-token-standard.md
 */
contract ERC20Interface {
    function totalSupply() public constant returns (uint);
    function balanceOf(address tokenOwner) public constant returns (uint balance);
    function allowance(address tokenOwner, address spender) public constant returns (uint remaining);
    function transfer(address to, uint tokens) public returns (bool success);
    function approve(address spender, uint tokens) public returns (bool success);
    function transferFrom(address from, address to, uint tokens) public returns (bool success);

    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
}


/*******************************************************************************
 *
 * ERC 918 Mineable Token Interface
 * https://github.com/ethereum/EIPs/blob/master/EIPS/eip-918.md
 */
contract ERC918Interface {
    function getChallengeNumber() public constant returns (bytes32);
    function getMiningDifficulty() public constant returns (uint);
    function getMiningTarget() public constant returns (uint);
    function getMiningReward() public constant returns (uint);

    function mint(uint256 nonce, bytes32 challenge_digest) public returns (bool success);
    event Mint(address indexed from, uint reward_amount, uint epochCount, bytes32 newChallengeNumber);

    address public lastRewardTo;
    uint public lastRewardEthBlockNumber;
}

/*******************************************************************************
 *
 * @notice ZeroGoldDust - Merged Mining Contract
 *
 * @dev This is a standard ERC20 mineable token contract.
 */
contract ZeroGoldPOWMining is Owned {
    using SafeMath for uint;

    /* Initialize the ZeroGold contract. */
    ERC20Interface zeroGold;
    
    /* Initialize the Mining Leader contract. */
    ERC918Interface public miningLeader;
    
    /* Reward divisor. */
    // NOTE A value of 20 means the reward is 1/20 (5%) 
    //      of current tokens held in the quarry. 
    uint rewardDivisor = 20;

    /* Number of times this has been mined. */
    uint epochCount = 0;
    
    /* Amount of pending rewards (merged but not yet transferred). */
    uint unclaimedRewards = 0;
    
    /* MintHelper approved rewards (to be claimed in transfer). */
    mapping(address => uint) mintHelperRewards;

    /* Solved solutions (to prevent duplicate rewards). */
    mapping(bytes32 => bytes32) solutionForChallenge;

    event Mint(address indexed from, uint reward_amount, uint epochCount, bytes32 newChallengeNumber);

    constructor(address _miningLeader) public  {
        /* Initialize the mining leader (eg 0xBitcoin). */
        miningLeader = ERC918Interface(_miningLeader);

        /* Initialize the ZeroGold contract. */
        // NOTE We hard-code the address here, since it should never change.
        zeroGold = ERC20Interface(0x6ef5bca539A4A01157af842B4823F54F9f7E9968);
    }

    /**
     * Merge
     * (called from ANY MintHelper)
     * 
     * Ensure that mergeMint() can only be called once per MintHelper.
     * Do this by ensuring that the "new" challenge number from 
     * MiningLeader::challenge post mint can be called once and that this block time 
     * is the same as this mint, and the caller is msg.sender.
     */
    function merge() external returns (bool success) {
        /* Verify MiningLeader::lastRewardTo == msg.sender. */
        if (miningLeader.lastRewardTo() != msg.sender) {
            // NOTE A different address called mint last 
            //      so return false (don't revert).
            return false;
        }
            
        /* Verify MiningLeader::lastRewardEthBlockNumber == block.number. */
        if (miningLeader.lastRewardEthBlockNumber() != block.number) {
            // NOTE MiningLeader::mint() was called in a different block number 
            //      so return false (don't revert).
            return false;
        }

        // We now update the solutionForChallenge hashmap with the value of 
        // MiningLeader::challengeNumber when a solution is merge minted. Only allow 
        // one reward for each challenge based on MiningLeader::challengeNumber.
        bytes32 challengeNumber = miningLeader.getChallengeNumber();
        bytes32 solution = solutionForChallenge[challengeNumber];
        if (solution != 0x0) return false; // prevent the same answer from awarding twice
        
        bytes32 digest = 'merge';
        solutionForChallenge[challengeNumber] = digest;

        // We may safely run the relevant logic to give an award to the sender, 
        // and update the contract.
        
        /* Retrieve the reward amount. */
        uint reward = getRewardAmount();
        
        /* Increase the value of unclaimed rewards. */
        unclaimedRewards = unclaimedRewards.add(reward);

        /* Increase the MintHelper's reward amount. */
        mintHelperRewards[msg.sender] = mintHelperRewards[msg.sender].add(reward);

        /* Retrieve our ZeroGold balance. */
        uint balance = zeroGold.balanceOf(address(this));

        /* Verify that we will NOT try to transfer more than we HODL. */
        assert(mintHelperRewards[msg.sender] <= balance);

        /* Increment the epoch count. */
        epochCount = epochCount.add(1);

        // NOTE: Use 0 to indicate a merge mine.
        emit Mint(msg.sender, mintHelperRewards[msg.sender], epochCount, 0);

        return true;
    }

    /**
     * Transfer
     * (called from ANY MintHelper)
     * 
     * Transfers the "approved" ZeroGold rewards to the MintHelpers's 
     * payout wallets. 
     * 
     * NOTE: This function will be called twice by MintHelper.merge(), 
     *       once for `minterWallet` and once for `payoutsWallet`.
     */
    function transfer(
        address _wallet, 
        uint _reward
    ) external returns (bool) {
        /* Require a positive transfer value. */
        if (_reward <= 0) {
            return false;
        }

        /* Verify our MintHelper isn't trying to over reward itself. */
        if (_reward > mintHelperRewards[msg.sender]) {
            return false;
        }

        /* Reduce the MintHelper's reward amount. */
        mintHelperRewards[msg.sender] = mintHelperRewards[msg.sender].sub(_reward);
        
        /* Reduce the unclaimed rewards amount. */
        unclaimedRewards = unclaimedRewards.sub(_reward);

        /* Safely transfer ZeroGold reward to MintHelper's specified wallet. */
        // FIXME MintHelper can transfer rewards to ANY wallet, and NOT
        //       necessarily the wallet that pool miners will benefit from.
        //       How "should we" restrict/verify the specified wallet??
        zeroGold.transfer(_wallet, _reward);
    }

    /* Calculate the current reward value. */
    function getRewardAmount() public view returns (uint) {
        /* Retrieve the ZeroGold balance available in this mineable contract. */
        uint totalBalance = zeroGold.balanceOf(address(this));
        
        /* Calculate the available balance (minus unclaimed rewards). */
        uint availableBalance = totalBalance.sub(unclaimedRewards);

        /* Calculate the reward amount. */
        uint rewardAmount = availableBalance.div(rewardDivisor);

        return rewardAmount;
    }
    
    /* Retrieves the "TOTAL" reward amount available to this MintHelper. */
    // NOTE `lastRewardAmount()` is called from MintHelper during the `merge` 
    //      to assign the `merge_totalReward` value.
    function lastRewardAmount() external view returns (uint) {
        return mintHelperRewards[msg.sender];
    }
    
    /* Set the mining leader. */
    function setMiningLeader(address _miningLeader) external onlyOwner {
        miningLeader = ERC918Interface(_miningLeader);
    }

    /* Set the reward divisor. */
    function setRewardDivisor(uint _rewardDivisor) external onlyOwner {
        rewardDivisor = _rewardDivisor;
    }

    /**
     * THIS CONTRACT DOES NOT ACCEPT DIRECT ETHER
     */
    function () public payable {
        /* Cancel this transaction. */
        revert('Oops! Direct payments are NOT permitted here.');
    }

    /**
     * Transfer Any ERC20 Token
     *
     * @notice Owner can transfer out any accidentally sent ERC20 tokens.
     *
     * @dev Provides an ERC20 interface, which allows for the recover
     *      of any accidentally sent ERC20 tokens.
     */
    function transferAnyERC20Token(
        address tokenAddress, uint tokens
    ) public onlyOwner returns (bool success) {
        return ERC20Interface(tokenAddress).transfer(owner, tokens);
    }
}