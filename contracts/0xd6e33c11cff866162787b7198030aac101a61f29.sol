pragma solidity 0.4.24;
pragma experimental "v0.5.0";

interface RTCoinInterface {
    

    /** Functions - ERC20 */
    function transfer(address _recipient, uint256 _amount) external returns (bool);

    function transferFrom(address _owner, address _recipient, uint256 _amount) external returns (bool);

    function approve(address _spender, uint256 _amount) external returns (bool approved);

    /** Getters - ERC20 */
    function totalSupply() external view returns (uint256);

    function balanceOf(address _holder) external view returns (uint256);

    function allowance(address _owner, address _spender) external view returns (uint256);

    /** Getters - Custom */
    function mint(address _recipient, uint256 _amount) external returns (bool);

    function stakeContractAddress() external view returns (address);

    function mergedMinerValidatorAddress() external view returns (address);
    
    /** Functions - Custom */
    function freezeTransfers() external returns (bool);

    function thawTransfers() external returns (bool);
}

/*
    ERC20 Standard Token interface
*/
interface ERC20Interface {
    function owner() external view returns (address);
    function decimals() external view returns (uint8);
    function transfer(address _to, uint256 _value) external returns (bool);
    function transferFrom(address _from, address _to, uint256 _value) external returns (bool);
    function approve(address _spender, uint256 _amount) external returns (bool);
    function totalSupply() external view returns (uint256);
    function balanceOf(address _owner) external view returns (uint256);
    function allowance(address _owner, address _spender) external view returns (uint256);
}

library SafeMath {

  // We use `pure` bbecause it promises that the value for the function depends ONLY
  // on the function arguments
    function mul(uint256 a, uint256 b) internal pure  returns (uint256) {
        uint256 c = a * b;
        require(a == 0 || c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a / b;
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


/// @title This contract is used to handle staking, and subsequently can increase RTC token supply
/// @author Postables, RTrade Technologies Ltd
/// @dev We able V5 for safety features, see https://solidity.readthedocs.io/en/v0.4.24/security-considerations.html#take-warnings-seriously
contract Stake {

    using SafeMath for uint256;

    // we mark as constant private to reduce gas costs
    // Minimum stake of 1RTC
    uint256 constant private MINSTAKE = 1000000000000000000;
    // NOTE ON MULTIPLIER: this is right now set to 10% this may however change before token is released
    uint256 constant private MULTIPLIER = 100000000000000000;
    // BLOCKHOLDPERIOD is used to determine how many blocks a stake is held for, and how many blocks will mint tokens
    uint256 constant private BLOCKHOLDPERIOD = 2103840;
    // BLOCKSEC uses 15 seconds as an average block time. Ultimately the only thing this "restricts" is the time at which a stake is withdrawn
    // Yes, we use block timestamps which can be influenced to some degree by miners, however since this only determines the time at which an initial stake can be withdrawn at
    // due to the fact that this is also limited by block height, it is an acceptable risk
    uint256 constant private BLOCKSEC = 15;
    string  constant public VERSION = "production";
    // this is the address of the RTC token contract
    address  constant public TOKENADDRESS = 0xecc043b92834c1ebDE65F2181B59597a6588D616;
    // this is the interface used to interact with the RTC Token
    RTCoinInterface   constant public RTI = RTCoinInterface(TOKENADDRESS);

    // keeps track of the number of active stakes
    uint256 public activeStakes;
    // keeps track of the admin address. For security purposes this can't be changed once set
    address public admin;
    // keeps track of whether or not new stakes can be made
    bool public newStakesAllowed;

    // tracks the state of a stake
    enum StakeStateEnum { nil, staking, staked }

    struct StakeStruct {
        // how many tokens were initially staked
        uint256 initialStake;
        // the block that the stake was made
        uint256 blockLocked;
        // the block at which the initial stake can be withdrawn
        uint256 blockUnlocked;
        // the time at which the initial stake can be withdrawn
        uint256 releaseDate;
        // the total number of coins to mint
        uint256 totalCoinsToMint;
        // the current number of coins that have been minted
        uint256 coinsMinted;
        // the amount of coins generated per block
        uint256 rewardPerBlock;
        // the block at which a stake was last withdrawn at 
        uint256 lastBlockWithdrawn;
        // the current state of this stake
        StakeStateEnum    state;
    }

    event StakesDisabled();
    event StakesEnabled();
    event StakeDeposited(address indexed _staker, uint256 indexed _stakeNum, uint256 _coinsToMint, uint256 _releaseDate, uint256 _releaseBlock);
    event StakeRewardWithdrawn(address indexed _staker, uint256 indexed _stakeNum, uint256 _reward);
    event InitialStakeWithdrawn(address indexed _staker, uint256 indexed _stakeNumber, uint256 _amount);
    event ForeignTokenTransfer(address indexed _sender, address indexed _recipient, uint256 _amount);

    // keeps track of the stakes a user has
    mapping (address => mapping (uint256 => StakeStruct)) public stakes;
    // keeps track of the total number of stakes a user has
    mapping (address => uint256) public numberOfStakes;
    // keeps track of the user's current RTC balance
    mapping (address => uint256) public internalRTCBalances;

    modifier validInitialStakeRelease(uint256 _stakeNum) {
        // make sure that the stake is active
        require(stakes[msg.sender][_stakeNum].state == StakeStateEnum.staking, "stake is not active");
        require(
            // please see comment at top of contract about why we consider it safe to use block times
            // linter warnings are left enabled on purpose
            now >= stakes[msg.sender][_stakeNum].releaseDate && block.number >= stakes[msg.sender][_stakeNum].blockUnlocked, 
            "attempting to withdraw initial stake before unlock block and date"
        );
        require(internalRTCBalances[msg.sender] >= stakes[msg.sender][_stakeNum].initialStake, "invalid internal rtc balance");
        _;
    }

    modifier validMint(uint256 _stakeNumber) {
        // allow people to withdraw their rewards even if the staking period is over
        require(
            stakes[msg.sender][_stakeNumber].state == StakeStateEnum.staking || stakes[msg.sender][_stakeNumber].state == StakeStateEnum.staked, 
            "stake must be active or inactive in order to mint tokens"
        );
        // make sure that the current coins minted are less than the total coins minted
        require(
            stakes[msg.sender][_stakeNumber].coinsMinted < stakes[msg.sender][_stakeNumber].totalCoinsToMint, 
            "current coins minted must be less than total"
        );
        uint256 currentBlock = block.number;
        uint256 lastBlockWithdrawn = stakes[msg.sender][_stakeNumber].lastBlockWithdrawn;
        // verify that the current block is one higher than the last block a withdrawal was made
        require(currentBlock > lastBlockWithdrawn, "current block must be one higher than last withdrawal");
        _;
    }

    modifier stakingEnabled(uint256 _numRTC) {
        // make sure this contract can mint coins on the RTC token contract
        require(canMint(), "staking contract is unable to mint tokens");
        // make sure new stakes are allowed
        require(newStakesAllowed, "new stakes are not allowed");
        // make sure they are staking at least one RTC
        require(_numRTC >= MINSTAKE, "specified stake is lower than minimum amount");
        _;
    }

    modifier onlyAdmin() {
        require(msg.sender == admin, "sender is not admin");
        _;
    }

    constructor(address _admin) public {
        require(TOKENADDRESS != address(0), "token address not set");
        admin = _admin;
    }

    /** @notice Used to disable new stakes from being made
        * Only usable by contract admin
     */
    function disableNewStakes() public onlyAdmin returns (bool) {
        newStakesAllowed = false;
        return true;
    }

    /** @notice Used to allow new stakes to be made
        * @dev For this to be enabled, the RTC token contract must be configured properly
     */
    function allowNewStakes() public onlyAdmin returns (bool) {
        newStakesAllowed = true;
        require(RTI.stakeContractAddress() == address(this), "rtc token contract is not set to use this contract as the staking contract");
        return true;
    }

    /** @notice Used by a staker to claim currently staked coins
        * @dev Can only be executed when at least one block has passed from the last execution
        * @param _stakeNumber This is the particular stake to withdraw from
     */
    function mint(uint256 _stakeNumber) public validMint(_stakeNumber) returns (bool) {
        // determine the amount of coins to be minted in this withdrawal
        uint256 mintAmount = calculateMint(_stakeNumber);
        // update current coins minted
        stakes[msg.sender][_stakeNumber].coinsMinted = stakes[msg.sender][_stakeNumber].coinsMinted.add(mintAmount);
        // update the last block a withdrawal was made at
        stakes[msg.sender][_stakeNumber].lastBlockWithdrawn = block.number;
        // emit an event
        emit StakeRewardWithdrawn(msg.sender, _stakeNumber, mintAmount);
        // mint the tokenz
        require(RTI.mint(msg.sender, mintAmount), "token minting failed");
        return true;
    }

    /** @notice Used by a staker to withdraw their initial stake
        * @dev Can only be executed after the specified block number, and unix timestamp has been passed
        * @param _stakeNumber This is the particular stake to withdraw from
     */
    function withdrawInitialStake(uint256 _stakeNumber) public validInitialStakeRelease(_stakeNumber) returns (bool) {
        // get the initial stake amount
        uint256 initialStake = stakes[msg.sender][_stakeNumber].initialStake;
        // de-activate the stake
        stakes[msg.sender][_stakeNumber].state = StakeStateEnum.staked;
        // decrease the total number of stakes
        activeStakes = activeStakes.sub(1);
        // reduce their internal RTC balance
        internalRTCBalances[msg.sender] = internalRTCBalances[msg.sender].sub(initialStake);
        // emit an event
        emit InitialStakeWithdrawn(msg.sender, _stakeNumber, initialStake);
        // transfer the tokenz
        require(RTI.transfer(msg.sender, initialStake), "unable to transfer tokens likely due to incorrect balance");
        return true;
    }

    /** @notice This is used to deposit coins and start staking with at least one RTC
        * @dev Staking must be enabled or this function will not execute
        * @param _numRTC This is the number of RTC tokens to stake
     */
    function depositStake(uint256 _numRTC) public stakingEnabled(_numRTC) returns (bool) {
        uint256 stakeCount = getStakeCount(msg.sender);

        // calculate the various stake parameters
        (uint256 blockLocked, 
        uint256 blockReleased, 
        uint256 releaseDate, 
        uint256 totalCoinsMinted,
        uint256 rewardPerBlock) = calculateStake(_numRTC);

        // initialize this struct in memory
        StakeStruct memory ss = StakeStruct({
            initialStake: _numRTC,
            blockLocked: blockLocked,
            blockUnlocked: blockReleased,
            releaseDate: releaseDate,
            totalCoinsToMint: totalCoinsMinted,
            coinsMinted: 0,
            rewardPerBlock: rewardPerBlock,
            lastBlockWithdrawn: blockLocked,
            state: StakeStateEnum.staking
        });

        // update the users list of stakes
        stakes[msg.sender][stakeCount] = ss;
        // update the users total stakes
        numberOfStakes[msg.sender] = numberOfStakes[msg.sender].add(1);
        // update their internal RTC balance
        internalRTCBalances[msg.sender] = internalRTCBalances[msg.sender].add(_numRTC);
        // increase the number of active stakes
        activeStakes = activeStakes.add(1);
        // emit an event
        emit StakeDeposited(msg.sender, stakeCount, totalCoinsMinted, releaseDate, blockReleased);
        // transfer tokens
        require(RTI.transferFrom(msg.sender, address(this), _numRTC), "transfer from failed, likely needs approval");
        return true;
    }


    // UTILITY FUNCTIONS //

    /** @notice This is a helper function used to calculate the parameters of a stake
        * Will determine the block that the initial stake can be withdraw at
        * Will determine the time that the initial stake can be withdrawn at
        * Will determine the total number of RTC to be minted throughout hte stake
        * Will determine how many RTC the stakee will be awarded per block
        * @param _numRTC This is the number of RTC to be staked
     */
    function calculateStake(uint256 _numRTC) 
        internal
        view
        returns (
            uint256 blockLocked, 
            uint256 blockReleased, 
            uint256 releaseDate, 
            uint256 totalCoinsMinted,
            uint256 rewardPerBlock
        ) 
    {
        // the block that the stake is being made at
        blockLocked = block.number;
        // the block at which the initial stake will be released
        blockReleased = blockLocked.add(BLOCKHOLDPERIOD);
        // the time at which the initial stake will be released
        // please see comment at top of contract about why we consider it safe to use block times
        // linter warnings are left enabled on purpose
        releaseDate = now.add(BLOCKHOLDPERIOD.mul(BLOCKSEC));
        // total coins that will be minted
        totalCoinsMinted = _numRTC.mul(MULTIPLIER);
        // make sure to scale down
        totalCoinsMinted = totalCoinsMinted.div(1 ether);
        // calculate the coins minted per block
        rewardPerBlock = totalCoinsMinted.div(BLOCKHOLDPERIOD);
    }

    /** @notice This is a helper function used to calculate how many coins will be awarded in a given internal
        * @param _stakeNumber This is the particular stake to calculate from
     */
    function calculateMint(uint256 _stakeNumber)
        internal
        view
        returns (uint256 reward)
    {
        // calculate how many blocks they can claim a stake for
        uint256 currentBlock = calculateCurrentBlock(_stakeNumber);
        //get the last block a withdrawal was made at
        uint256 lastBlockWithdrawn = stakes[msg.sender][_stakeNumber].lastBlockWithdrawn;
        // determine the number of blocks to generate a reward for
        uint256 blocksToReward = currentBlock.sub(lastBlockWithdrawn);
        // calculate the reward
        reward = blocksToReward.mul(stakes[msg.sender][_stakeNumber].rewardPerBlock);
        // get total number of coins to be minted
        uint256 totalToMint = stakes[msg.sender][_stakeNumber].totalCoinsToMint;
        // get current number of coins minted
        uint256 currentCoinsMinted = stakes[msg.sender][_stakeNumber].coinsMinted;
        // get the new numberof total coins to be minted
        uint256 newCoinsMinted = currentCoinsMinted.add(reward);
        // if for some reason more would be generated, prevent that from happening
        if (newCoinsMinted > totalToMint) {
            reward = newCoinsMinted.sub(totalToMint);
        }
    }

    /** @notice Allow us to transfer tokens that someone might've accidentally sent to this contract
        @param _tokenAddress this is the address of the token contract
        @param _recipient This is the address of the person receiving the tokens
        @param _amount This is the amount of tokens to send
     */
    function transferForeignToken(
        address _tokenAddress,
        address _recipient,
        uint256 _amount)
        public
        onlyAdmin
        returns (bool)
    {
        require(_recipient != address(0), "recipient address can't be empty");
        // don't allow us to transfer RTC tokens stored in this contract
        require(_tokenAddress != TOKENADDRESS, "token can't be RTC");
        ERC20Interface eI = ERC20Interface(_tokenAddress);
        require(eI.transfer(_recipient, _amount), "token transfer failed");
        emit ForeignTokenTransfer(msg.sender, _recipient, _amount);
        return true;
    }

    /** @notice This is a helper function used to calculate how many blocks to mint coins for
        * @param _stakeNumber This is the stake to be used for calculations
     */
    function calculateCurrentBlock(uint256 _stakeNumber) internal view returns (uint256 currentBlock) {
        currentBlock = block.number;
        // if the current block is greater than the block at which coins can be unlocked at, 
        // prevent them from generating more coins that allowed
        if (currentBlock >= stakes[msg.sender][_stakeNumber].blockUnlocked) {
            currentBlock = stakes[msg.sender][_stakeNumber].blockUnlocked;
        }
    }
    
    /** @notice This is a helper function used to get the total number of stakes a 
        * @param _staker This is the address of the stakee
     */
    function getStakeCount(address _staker) internal view returns (uint256) {
        return numberOfStakes[_staker];
    }

    /** @notice This is a helper function that checks whether or not this contract can mint tokens
        * @dev This should only ever be false under extreme circumstances such as a potential vulnerability
     */
    function canMint() public view returns (bool) {
        require(RTI.stakeContractAddress() == address(this), "rtc token contract is not set to use this contract as the staking contract");
        return true;
    }
}