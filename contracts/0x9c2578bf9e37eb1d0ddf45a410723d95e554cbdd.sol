pragma solidity ^0.4.23;


/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
    address public owner;


    event OwnershipRenounced(address indexed previousOwner);
    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );


    /**
    * @dev The Ownable constructor sets the original `owner` of the contract to the sender
    * account.
    */
    constructor() public {
        owner = msg.sender;
    }

    /**
    * @dev Throws if called by any account other than the owner.
    */
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner is allowed for this operation.");
        _;
    }

    /**
    * @dev Allows the current owner to relinquish control of the contract.
    * @notice Renouncing to ownership will leave the contract without an owner.
    * It will not be possible to call the functions with the `onlyOwner`
    * modifier anymore.
    */
    function renounceOwnership() public onlyOwner {
        emit OwnershipRenounced(owner);
        owner = address(0);
    }

    /**
    * @dev Allows the current owner to transfer control of the contract to a newOwner.
    * @param _newOwner The address to transfer ownership to.
    */
    function transferOwnership(address _newOwner) public onlyOwner {
        _transferOwnership(_newOwner);
    }

    /**
    * @dev Transfers control of the contract to a newOwner.
    * @param _newOwner The address to transfer ownership to.
    */
    function _transferOwnership(address _newOwner) internal {
        require(_newOwner != address(0), "Cannot transfer ownership to an empty user.");
        emit OwnershipTransferred(owner, _newOwner);
        owner = _newOwner;
    }
}

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {

    /**
    * @dev Multiplies two numbers, throws on overflow.
    */
    function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
        // Gas optimization: this is cheaper than asserting 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
        if (a == 0) {
            return 0;
        }

        c = a * b;
        assert(c / a == b);
        return c;
    }

    /**
    * @dev Integer division of two numbers, truncating the quotient.
    */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // assert(b > 0); // Solidity automatically throws when dividing by 0
        // uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return a / b;
    }

    /**
    * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
    */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    /**
    * @dev Adds two numbers, throws on overflow.
    */
    function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
        c = a + b;
        assert(c >= a);
        return c;
    }
}

/**
 * @title ERC20Basic
 * @dev Simpler version of ERC20 interface
 * See https://github.com/ethereum/EIPs/issues/179
 */
contract ERC20Basic {
    function totalSupply() public view returns (uint256);
    function balanceOf(address who) public view returns (uint256);
    function transfer(address to, uint256 value) public returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
}

contract ANKRTokenVault is Ownable {
    using SafeMath for uint256;

    // token contract Address

    //Wallet Addresses for allocation immediately
    address public opentokenAddress           = 0x7B1f5F0FCa6434D7b01161552D335A774706b650;
    address public tokenmanAddress            = 0xBB46219183f1F17364914e353A44F982de77eeC8;

    // Wallet Address for unlocked token
    address public marketingAddress           = 0xc2e96F45232134dD32B6DF4D51AC82248CA942cc;

    // Wallet Address for locked token
    address public teamReserveWallet          = 0x0AA7Aa665276A96acD25329354FeEa8F955CAf2b;
    address public communityReserveWallet     = 0xeFA1f626670445271359940e1aC346Ac374019E7;

    //Token Allocations
    uint256 public opentokenAllocation            = 0.5 * (10 ** 9) * (10 ** 18);
    uint256 public tokenmanAllocation             = 0.2 * (10 ** 9) * (10 ** 18);
    uint256 public marketingAllocation            = 0.5 * (10 ** 9) * (10 ** 18);
    uint256 public teamReserveAllocation          = 2.0 * (10 ** 9) * (10 ** 18);
    uint256 public communityReserveAllocation     = 4.0 * (10 ** 9) * (10 ** 18);

    //Total Token Allocations
    uint256 public totalAllocation = 10 * (10 ** 9) * (10 ** 18);

    uint256 public investorTimeLock = 183 days; // six months
    uint256 public othersTimeLock = 3 * 365 days;
    // uint256 public investorVestingStages = 1;
    uint256 public othersVestingStages = 3 * 12;

    // uint256 public investorTimeLock = 5 seconds; // six months
    // uint256 public othersTimeLock = 3 * 12 * 5 seconds;

    /** Reserve allocations */
    mapping(address => uint256) public allocations;

    /** When timeLocks are over (UNIX Timestamp)  */
    mapping(address => uint256) public timeLocks;

    /** How many tokens each reserve wallet has claimed */
    mapping(address => uint256) public claimed;

    /** How many tokens each reserve wallet has claimed */
    mapping(address => uint256) public lockedInvestors;
    address[] public lockedInvestorsIndices;

    /** How many tokens each reserve wallet has claimed */
    mapping(address => uint256) public unLockedInvestors;
    address[] public unLockedInvestorsIndices;

    /** When this vault was locked (UNIX Timestamp)*/
    uint256 public lockedAt = 0;

    ERC20Basic public token;

    /** Allocated reserve tokens */
    event Allocated(address wallet, uint256 value);

    /** Distributed reserved tokens */
    event Distributed(address wallet, uint256 value);

    /** Tokens have been locked */
    event Locked(uint256 lockTime);

    //Any of the reserve wallets
    modifier onlyReserveWallets {
        require(allocations[msg.sender] > 0, "There should be non-zero allocation.");
        _;
    }

    // //Only Ankr team reserve wallet
    // modifier onlyNonInvestorReserve {
    //     require(
    //         msg.sender == teamReserveWallet || msg.sender == communityReserveWallet, 
    //         "Only team and community is allowed for this operation.");
    //     require(allocations[msg.sender] > 0, "There should be non-zero allocation for team.");
    //     _;
    // }

    //Has not been locked yet
    modifier notLocked {
        require(lockedAt == 0, "lockedAt should be zero.");
        _;
    }

    modifier locked {
        require(lockedAt > 0, "lockedAt should be larger than zero.");
        _;
    }

    //Token allocations have not been set
    modifier notAllocated {
        require(allocations[opentokenAddress] == 0, "Allocation should be zero.");
        require(allocations[tokenmanAddress] == 0, "Allocation should be zero.");
        require(allocations[marketingAddress] == 0, "Allocation should be zero.");
        require(allocations[teamReserveWallet] == 0, "Allocation should be zero.");
        require(allocations[communityReserveWallet] == 0, "Allocation should be zero.");
        _;
    }

    constructor(ERC20Basic _token) public {
        token = ERC20Basic(_token);
    }

    function addUnlockedInvestor(address investor, uint256 amt) public onlyOwner notLocked notAllocated returns (bool) {
        require(investor != address(0), "Unlocked investor must not be zero.");
        require(amt > 0, "Unlocked investor's amount should be larger than zero.");
        require(unLockedInvestors[investor] == 0, "Unlocked investor shouldn't be added before.");
        unLockedInvestorsIndices.push(investor);
        unLockedInvestors[investor] = amt * (10 ** 18);
        return true;
    }

    function addLockedInvestor(address investor, uint256 amt) public onlyOwner notLocked notAllocated returns (bool) {
        require(investor != address(0), "Locked investor must not be zero.");
        require(amt > 0, "Locked investor's amount should be larger than zero.");
        require(lockedInvestors[investor] == 0, "Locked investor shouldn't be added before.");
        lockedInvestorsIndices.push(investor);
        lockedInvestors[investor] = amt * (10 ** 18);
        return true;
    }

    function allocate() public notLocked notAllocated onlyOwner {

        //Makes sure Token Contract has the exact number of tokens
        require(token.balanceOf(address(this)) == totalAllocation, "Token should not be allocated yet.");

        allocations[opentokenAddress] = opentokenAllocation;
        allocations[tokenmanAddress] = tokenmanAllocation;
        allocations[marketingAddress] = marketingAllocation;
        allocations[teamReserveWallet] = teamReserveAllocation;
        allocations[communityReserveWallet] = communityReserveAllocation;

        emit Allocated(opentokenAddress, opentokenAllocation);
        emit Allocated(tokenmanAddress, tokenmanAllocation);
        emit Allocated(marketingAddress, marketingAllocation);
        emit Allocated(teamReserveWallet, teamReserveAllocation);
        emit Allocated(communityReserveWallet, communityReserveAllocation);

        address cur;
        uint arrayLength;
        uint i;
        arrayLength = unLockedInvestorsIndices.length;
        for (i = 0; i < arrayLength; i++) {
            cur = unLockedInvestorsIndices[i];
            allocations[cur] = unLockedInvestors[cur];
            emit Allocated(cur, unLockedInvestors[cur]);
        }
        arrayLength = lockedInvestorsIndices.length;
        for (i = 0; i < arrayLength; i++) {
            cur = lockedInvestorsIndices[i];
            allocations[cur] = lockedInvestors[cur];
            emit Allocated(cur, lockedInvestors[cur]);
        }

        // lock();
        preDistribute();
    }

    function distribute() public notLocked onlyOwner {
        lock();
    }

    //Lock the vault for the rest wallets
    function lock() internal {

        lockedAt = block.timestamp;

        timeLocks[teamReserveWallet] = lockedAt.add(othersTimeLock).add(investorTimeLock);
        timeLocks[communityReserveWallet] = lockedAt.add(othersTimeLock).add(investorTimeLock);

        emit Locked(lockedAt);
    }

    //In the case locking failed, then allow the owner to reclaim the tokens on the contract.
    //Recover Tokens in case incorrect amount was sent to contract.
    function recoverFailedLock() external notLocked onlyOwner {

        // Transfer all tokens on this contract back to the owner
        require(token.transfer(owner, token.balanceOf(address(this))), "recoverFailedLock: token transfer failed!");
    }

    // Total number of tokens currently in the vault
    function getTotalBalance() public view returns (uint256 tokensCurrentlyInVault) {

        return token.balanceOf(address(this));

    }

    // Number of tokens that are still locked
    function getLockedBalance() public view onlyReserveWallets returns (uint256 tokensLocked) {
        return allocations[msg.sender].sub(claimed[msg.sender]);
    }

    //Distribute tokens for non-vesting reserve wallets
    function preDistribute() internal {
        claimTokenReserve(opentokenAddress);
        claimTokenReserve(tokenmanAddress);
        claimTokenReserve(marketingAddress);
    }

    //Claim tokens for non-vesting reserve wallets
    function claimTokenReserve(address reserveWallet) internal {
        // Must Only claim once
        require(allocations[reserveWallet] > 0, "There should be non-zero allocation.");
        require(claimed[reserveWallet] == 0, "This address should be never claimed before.");

        uint256 amount = allocations[reserveWallet];

        claimed[reserveWallet] = amount;

        require(token.transfer(reserveWallet, amount), "Token transfer failed");

        emit Distributed(reserveWallet, amount);
    }


    // Let the unLocked Investors to claim the token just in case 
    // that function distributeUnlockedInvestorsReserve failed to distribute the token
    function claimUnlockedInvestorTokenReserve() public {
        require(unLockedInvestors[msg.sender] > 0, "This is not an Unlocked investor.");
        claimTokenReserve(msg.sender);
    }

    // Let the Locked Investors to claim the token just in case 
    // that function distributeLockedInvestorsReserve failed to distribute the token
    function claimLockedInvestorTokenReserve() public locked {
        require(block.timestamp.sub(lockedAt) > investorTimeLock, "Still in locking period.");
        require(lockedInvestors[msg.sender] > 0, "This is not a Locked investor.");
        claimTokenReserve(msg.sender);
    }

    //Claim tokens for unLocked Investor's reserve wallet
    function distributeUnlockedInvestorsReserve() public onlyOwner {
        uint arrayLength;
        uint i;

        arrayLength = unLockedInvestorsIndices.length;
        for (i = 0; i < arrayLength; i++) {
            claimTokenReserve(unLockedInvestorsIndices[i]);
        }
    }

    //Claim tokens for Locked Investor's reserve wallet
    function distributeLockedInvestorsReserve() public onlyOwner locked {
        require(block.timestamp.sub(lockedAt) > investorTimeLock, "Still in locking period.");

        uint arrayLength;
        uint i;
        
        arrayLength = lockedInvestorsIndices.length;
        for (i = 0; i < arrayLength; i++) {
            claimTokenReserve(lockedInvestorsIndices[i]);
        }
    }

    //Claim tokens for Team and Community reserve wallet
    // function claimNonInvestorReserve() public onlyNonInvestorReserve locked {
    function claimNonInvestorReserve() public onlyOwner locked {
        uint256 vestingStage = nonInvestorVestingStage();

        //Amount of tokens the team should have at this vesting stage
        uint256 totalUnlockedTeam = vestingStage.mul(allocations[teamReserveWallet]).div(othersVestingStages);
        uint256 totalUnlockedComm = vestingStage.mul(allocations[communityReserveWallet]).div(othersVestingStages);

        //Previously claimed tokens must be less than what is unlocked
        require(claimed[teamReserveWallet] < totalUnlockedTeam, "Team's claimed tokens must be less than what is unlocked");
        require(claimed[communityReserveWallet] < totalUnlockedComm, "Community's claimed tokens must be less than what is unlocked");

        uint256 paymentTeam = totalUnlockedTeam.sub(claimed[teamReserveWallet]);
        uint256 paymentComm = totalUnlockedComm.sub(claimed[communityReserveWallet]);

        claimed[teamReserveWallet] = totalUnlockedTeam;
        claimed[communityReserveWallet] = totalUnlockedComm;

        require(token.transfer(teamReserveWallet, paymentTeam), "Team token transfer failed.");
        require(token.transfer(communityReserveWallet, paymentComm), "Community token transfer failed.");

        emit Distributed(teamReserveWallet, paymentTeam);
        emit Distributed(communityReserveWallet, paymentComm);
    }

    //Current Vesting stage for Ankr's Team and Community
    function nonInvestorVestingStage() public view returns(uint256){

        // Every month
        uint256 vestingMonths = othersTimeLock.div(othersVestingStages);

        uint256 stage = (block.timestamp.sub(lockedAt).sub(investorTimeLock)).div(vestingMonths);

        //Ensures Team and Community vesting stage doesn't go past othersVestingStages
        if(stage > othersVestingStages){
            stage = othersVestingStages;
        }

        return stage;

    }
}