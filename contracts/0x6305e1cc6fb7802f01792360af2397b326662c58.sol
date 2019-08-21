pragma solidity ^0.5.0;

interface IERC20 
{
    function totalSupply() external view returns (uint256);
    function balanceOf(address who) external view returns (uint256);
    function allowance(address owner, address spender) external view returns (uint256);
    function transfer(address to, uint256 value) external returns (bool);
    function approve(address spender, uint256 value) external returns (bool);
    function transferFrom(address from, address to, uint256 value) external returns (bool);
    
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract ApproveAndCallFallBack {

    function receiveApproval(address from, uint256 tokens, address token, bytes memory data) public;
}

library SafeMath 
{
    function mul(uint256 a, uint256 b) internal pure returns (uint256) 
    {
        if (a == 0) 
        {
            return 0;
        }
        uint256 c = a * b;
        assert(c / a == b);
        return c;
    }
    
    function div(uint256 a, uint256 b) internal pure returns (uint256) 
    {
        uint256 c = a / b;
        return c;
    }
    
    function sub(uint256 a, uint256 b) internal pure returns (uint256) 
    {
        assert(b <= a);
        return a - b;
    }
    
    function add(uint256 a, uint256 b) internal pure returns (uint256) 
    {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }
    
    function ceil(uint256 a, uint256 m) internal pure returns (uint256) 
    {
        uint256 c = add(a,m);
        uint256 d = sub(c,1);
        return mul(div(d,m),m);
    }
}

contract ERC20Detailed is IERC20 
{
    string private _name;
    string private _symbol;
    uint8 private _decimals;
    
    constructor(string memory name, string memory symbol, uint8 decimals) public {
        _name = name;
        _symbol = symbol;
        _decimals = decimals;
    }
    
    function name() public view returns(string memory) {
        return _name;
    }
    
    function symbol() public view returns(string memory) {
        return _symbol;
    }
    
    function decimals() public view returns(uint8) {
        return _decimals;
    }
}


contract BOMB3D is ERC20Detailed 
{
    
    using SafeMath for uint256;
    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowed;
    
    string constant tokenName = "BOMB3D 💣";
    string constant tokenSymbol = "BOMB3D";
    uint8  constant tokenDecimals = 18;
    uint256 _totalSupply = 0;
    
    // ------------------------------------------------------------------------

    address payable admin = address(0);
    
    address unWrappedTokenAddress = address(0x1C95b093d6C236d3EF7c796fE33f9CC6b8606714);
    
    mapping (address => uint256) private _stakedBalances;
    uint256 public totalAmountStaked = 0;
    
    mapping (address => uint256) private _stakingMultipliers;
    mapping (address => uint256) private _stakedBalances_wMultiplier;
    uint256 public totalAmountStaked_wMultipliers = 0;
    
    mapping (address => uint256) private _stakedBalances_bonuses;
    uint256 public totalAmountStaked_bonuses = 0;
    uint256 constant stakingBonuses_max = 50000;
    
    uint256 public staking_totalUnpaidRewards  = 0;
    uint256 _staking_totalRewardsPerUnit = 0;
    mapping (address => uint256) private _staking_totalRewardsPerUnit_positions;
    mapping (address => uint256) private _staking_savedRewards;
    
    uint256 _staking_totalRewardsPerUnit_eth = 0;
    mapping (address => uint256) private _staking_totalRewardsPerUnit_positions_eth;
    mapping (address => uint256) private _staking_savedRewards_eth;
    
    // ------------------------------------------------------------------------
    
    constructor() public payable ERC20Detailed(tokenName, tokenSymbol, tokenDecimals) 
    {
        admin = msg.sender;
    }
    
    // ------------------------------------------------------------------------
    //ERC20 IMPLEMENTATION with approveAndCall
    // ------------------------------------------------------------------------
    
    function totalSupply() public view returns (uint256) 
    {
        return _totalSupply.add(appendDecimals(totalAmountStaked)).add(staking_totalUnpaidRewards);
    }
    
    function balanceOf(address owner) public view returns (uint256) 
    {
        return _balances[owner];
    }
    
    function allowance(address owner, address spender) public view returns (uint256) 
    {
        return _allowed[owner][spender];
    }
    
    function transfer(address to, uint256 value) public returns (bool) 
    {
        require(value <= _balances[msg.sender]);
        require(to != address(0));
        
        _balances[msg.sender] = _balances[msg.sender].sub(value);
        _balances[to] = _balances[to].add(value);
        
        emit Transfer(msg.sender, to, value);
        return true;
    }
    
    function multiTransfer(address[] memory receivers, uint256[] memory values) public
    {
        for (uint256 i = 0; i < receivers.length; i++) 
        {
            transfer(receivers[i], values[i]);
        }
    }
    
    function approve(address spender, uint256 value) public returns (bool) 
    {
        require(spender != address(0));
        _allowed[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }
    
    function approveAndCall(address spender, uint tokens, bytes memory data) public returns (bool success) 
    {
        _allowed[msg.sender][spender] = tokens;
        emit Approval(msg.sender, spender, tokens);
        ApproveAndCallFallBack(spender).receiveApproval(msg.sender, tokens, address(this), data);
        return true;
    }
    
    function transferFrom(address from, address to, uint256 value) public returns (bool) 
    {
        require(value <= _balances[from]);
        require(value <= _allowed[from][msg.sender]);
        require(to != address(0));
        
        _balances[from] = _balances[from].sub(value);
        _balances[to] = _balances[to].add(value);
        
        _allowed[from][msg.sender] = _allowed[from][msg.sender].sub(value);
        
        emit Transfer(from, to, value);
        
        return true;
    }
    
    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) 
    {
        require(spender != address(0));
        _allowed[msg.sender][spender] = (_allowed[msg.sender][spender].add(addedValue));
        emit Approval(msg.sender, spender, _allowed[msg.sender][spender]);
        return true;
    }
    
    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) 
    {
        require(spender != address(0));
        _allowed[msg.sender][spender] = (_allowed[msg.sender][spender].sub(subtractedValue));
        emit Approval(msg.sender, spender, _allowed[msg.sender][spender]);
        return true;
    }
    
    function _mint(address account, uint256 value) internal 
    {
        require(value != 0);
        _balances[account] = _balances[account].add(value);
        _totalSupply = _totalSupply.add(value);
        emit Transfer(address(0), account, value);
    }
    
    function burn(uint256 value) external 
    {
        _burn(msg.sender, value);
    }
    
    function _burn(address account, uint256 value) internal 
    {
        require(value != 0);
        require(value <= _balances[account]);
        _totalSupply = _totalSupply.sub(value);
        _balances[account] = _balances[account].sub(value);
        emit Transfer(account, address(0), value);
    }
    
    function burnFrom(address account, uint256 value) external 
    {
        require(value <= _allowed[account][msg.sender]);
        _allowed[account][msg.sender] = _allowed[account][msg.sender].sub(value);
        _burn(account, value);
    }
    
    
    // ------------------------------------------------------------------------
    //WRAPPING
    // ------------------------------------------------------------------------
    
    
    //Turn BOMBs into BOMB3Ds
    function wrap(uint256 value_unwrapped) public returns (bool) 
    {
        require(IERC20(unWrappedTokenAddress).allowance(msg.sender, address(this)) >= value_unwrapped);
        
        uint256 balance_beforeTransfer = IERC20(unWrappedTokenAddress).balanceOf(address(this));
        require(IERC20(unWrappedTokenAddress).transferFrom(msg.sender, address(this), value_unwrapped));
        uint256 balance_afterTransfer = IERC20(unWrappedTokenAddress).balanceOf(address(this));
        
        require(balance_afterTransfer > balance_beforeTransfer);
        
        //determine what really was received on this end
        uint256 receivedValue = balance_afterTransfer.sub(balance_beforeTransfer);
        
        //create decimals
        uint256 receivedValueWithDecimals = appendDecimals(receivedValue);
        
        uint256 effectiveAmountStaked = totalAmountStaked_effective();
        if(effectiveAmountStaked > 0)
        {
            //calculate staking rewards
            uint256 stakingReward = findOnePercent(receivedValueWithDecimals).mul(getStakingRewardPercentage());
            require(stakingReward < receivedValueWithDecimals);
        
            //split up to rewards per unit in stake
            uint256 RewardsPerUnit = stakingReward.div(effectiveAmountStaked);
            
            //apply rewards
            _staking_totalRewardsPerUnit = _staking_totalRewardsPerUnit.add(RewardsPerUnit);
            
            //prevent leaving any dust in the contract
            uint256 actualRewardsCreated = RewardsPerUnit.mul(effectiveAmountStaked);
            staking_totalUnpaidRewards = staking_totalUnpaidRewards.add(actualRewardsCreated);
            uint256 dust = stakingReward.sub(actualRewardsCreated);
            if(dust > 0)
                _mint(admin, dust);
            
            //give out BOMB3Ds
            _mint(msg.sender, receivedValueWithDecimals.sub(stakingReward));
        }
        else 
            _mint(msg.sender, receivedValueWithDecimals);
        
        return true;
    }
    
    //Turn BOMB3Ds into BOMBs
    function unwrap(uint256 value_unwrapped) public returns (bool)
    {
        return unwrapTo(value_unwrapped, msg.sender);
    }
    
    //Turn BOMB3Ds into BOMBs, also set target address so you can save 1% from being destroyed when you want to transfer to an exchange/other third party
    function unwrapTo(uint256 value_unwrapped, address target) public returns (bool)
    {
        uint256 valueWithDecimals = appendDecimals(value_unwrapped);
        require(balanceOf(msg.sender) >= valueWithDecimals);
        require(IERC20(unWrappedTokenAddress).transfer(target, value_unwrapped));
        _burn(msg.sender, valueWithDecimals);
        return true;
    }
    
    
    
    // ------------------------------------------------------------------------
    //STAKING
    // ------------------------------------------------------------------------
    
    function stakedBalanceOf(address owner) public view returns (uint256) 
    {
        return _stakedBalances[owner];
    }
    
    function stakedBalanceOf_wMultiplier(address owner) public view returns (uint256) 
    {
        return _stakedBalances_wMultiplier[owner];
    }
    
    function stakedBalanceOf_bonuses(address owner) public view returns (uint256) 
    {
        return _stakedBalances_bonuses[owner];
    }
    
    function stakedBalanceOf_effective(address owner) public view returns (uint256) 
    {
        return _stakedBalances_wMultiplier[owner].add(_stakedBalances_bonuses[owner]);
    }
    
    function totalAmountStaked_effective() public view returns (uint256) 
    {
        return totalAmountStaked_wMultipliers.add(totalAmountStaked_bonuses);
    }
    //Moves BOMB3Ds into staking mode. Only full BOMB3Ds can be staked. 
    //Stakers earn rewards whenever BOMBs are converted to BOMB3Ds.
    function stake(uint256 value_unwrapped) public
    {
        require(value_unwrapped > 0);
        uint256 valueWithDecimals = appendDecimals(value_unwrapped);
        require(_balances[msg.sender] >= valueWithDecimals);
        _burn(msg.sender, valueWithDecimals);
        
        updateRewardsFor(msg.sender);
        
        _stakedBalances[msg.sender] = _stakedBalances[msg.sender].add(value_unwrapped);
        totalAmountStaked = totalAmountStaked.add(value_unwrapped);
        
        uint256 value_unwrapped_multiplied = value_unwrapped * getCurrentStakingMultiplier(msg.sender);
        _stakedBalances_wMultiplier[msg.sender] = _stakedBalances_wMultiplier[msg.sender].add(value_unwrapped_multiplied);
        totalAmountStaked_wMultipliers = totalAmountStaked_wMultipliers.add(value_unwrapped_multiplied);
    }
    
    //Removes BOMB3Ds from staking mode.
    function unstake(uint256 value_unwrapped) public
    {
        require(value_unwrapped > 0);
        require(value_unwrapped <= _stakedBalances[msg.sender]);
        updateRewardsFor(msg.sender);
        _stakedBalances[msg.sender] = _stakedBalances[msg.sender].sub(value_unwrapped);
        totalAmountStaked = totalAmountStaked.sub(value_unwrapped);
        
        uint256 value_unwrapped_multiplied = value_unwrapped * getCurrentStakingMultiplier(msg.sender);
        _stakedBalances_wMultiplier[msg.sender] = _stakedBalances_wMultiplier[msg.sender].sub(value_unwrapped_multiplied);
        totalAmountStaked_wMultipliers = totalAmountStaked_wMultipliers.sub(value_unwrapped_multiplied);
        
        uint256 valueWithDecimals = appendDecimals(value_unwrapped);
        _mint(msg.sender, valueWithDecimals);
    }
    
    //Rewards percentage is based on circulating supply.
    function getStakingRewardPercentage() public view returns (uint256)
    {
        uint256 totalSupply_cur = totalSupply();
        if(totalSupply_cur < appendDecimals(1000)) //early stakers bonus
            return 3;
        if(totalSupply_cur < appendDecimals(10000)) //early stakers bonus cooldown
            return 2;
        if(totalSupply_cur <  appendDecimals(50000)) //let normies get in
            return 1;
        if(totalSupply_cur <  appendDecimals(100000)) //getting juicy again
            return 3;
        return 5; //late to the party madness
    }
    
    //Admin can reward users with additional virtual stake from a capped pool.
    function setStakingBonus(address staker, uint256 value) public
    {
        require(msg.sender == admin);
        updateRewardsFor(staker);
        totalAmountStaked_bonuses = totalAmountStaked_bonuses.sub(_stakedBalances_bonuses[staker]);
        _stakedBalances_bonuses[staker] = value;
        totalAmountStaked_bonuses = totalAmountStaked_bonuses.add(value);
        require(totalAmountStaked_bonuses <= stakingBonuses_max);
    }
    
    //catch up with the current total Rewards. 
    //this needs to be done whenever a stake is changed, either by staking more/less or applying a multiplier
    function updateRewardsFor(address staker) private
    {
        _staking_savedRewards[staker] = viewUnpaidRewards(staker);
        _staking_totalRewardsPerUnit_positions[staker] = _staking_totalRewardsPerUnit;
        
        _staking_savedRewards_eth[staker] = viewUnpaidRewards_eth(staker);
        _staking_totalRewardsPerUnit_positions_eth[staker] = _staking_totalRewardsPerUnit_eth;
    }
    
    //get all rewards that have not been claimed yet
    function viewUnpaidRewards(address staker) public view returns (uint256)
    {
        uint256 newRewardsPerUnit = _staking_totalRewardsPerUnit.sub(_staking_totalRewardsPerUnit_positions[staker]);
        uint256 newRewards = newRewardsPerUnit.mul(stakedBalanceOf_effective(staker));
        return _staking_savedRewards[staker].add(newRewards);
    }
    //get all eth rewards that have not been claimed yet
    function viewUnpaidRewards_eth(address staker) public view returns (uint256)
    {
        uint256 newRewardsPerUnit = _staking_totalRewardsPerUnit_eth.sub(_staking_totalRewardsPerUnit_positions_eth[staker]);
        uint256 newRewards = newRewardsPerUnit.mul(stakedBalanceOf_effective(staker));
        return _staking_savedRewards_eth[staker].add(newRewards);
    }
    
    //pay out all unclaimed rewards
    function payoutRewards() public
    {
        updateRewardsFor(msg.sender);
        
        uint256 rewards = _staking_savedRewards[msg.sender];
        _staking_savedRewards[msg.sender] = 0;
        staking_totalUnpaidRewards = staking_totalUnpaidRewards.sub(rewards);
        if(rewards > 0)
            _mint(msg.sender, rewards);
        
        uint256 rewards_eth = _staking_savedRewards_eth[msg.sender];
        _staking_savedRewards_eth[msg.sender] = 0;
        if(rewards_eth > 0)
            msg.sender.transfer(rewards_eth);
    }
    
    //leverage stake by purchasing a multiplier. returns will be used to further develop the BOMB3D ecosystem
    function buyStakingMultiplier () public payable returns (bool)
    {
        uint256 cost = getNextStakingMultiplierCost(msg.sender);
        require(cost > 0 && msg.value == cost);
        
        //calculate staking rewards
        uint256 stakingReward = cost.div(2);
        uint256 effectiveAmountStaked = totalAmountStaked_effective();
        //split up to rewards per unit in stake
        uint256 rewardsPerUnit = stakingReward.div(effectiveAmountStaked);
        //apply rewards
        _staking_totalRewardsPerUnit_eth = _staking_totalRewardsPerUnit_eth.add(rewardsPerUnit);
        
        //again, prevent leaving any dust in the contract
        uint256 actualRewardsCreated = rewardsPerUnit.mul(effectiveAmountStaked);
        uint256 pocketmoney = cost.sub(actualRewardsCreated);
        admin.transfer(pocketmoney);
        
        updateRewardsFor(msg.sender);
        
        totalAmountStaked_wMultipliers = totalAmountStaked_wMultipliers.sub(_stakedBalances_wMultiplier[msg.sender]);
        
        uint256 nextStakingMultiplier = getNextStakingMultiplier(msg.sender);
        _stakingMultipliers[msg.sender] = nextStakingMultiplier;
        
        _stakedBalances_wMultiplier[msg.sender] = _stakedBalances[msg.sender].mul(nextStakingMultiplier) ;
        totalAmountStaked_wMultipliers = totalAmountStaked_wMultipliers.add(_stakedBalances_wMultiplier[msg.sender]);

        return true;
    }
    
    function getCurrentStakingMultiplier(address stakerAddress) public view returns (uint256)
    {
        uint256 currentMultiplier = _stakingMultipliers[stakerAddress];
        if(currentMultiplier == 0)
            return 1;
        return currentMultiplier;
    }
    
    //defines staking multiplier tiers and returns next tier accordingly
    function getNextStakingMultiplier(address stakerAddress) public view returns (uint256)
    {
        uint256 currentMultiplier = getCurrentStakingMultiplier(stakerAddress);
        if(currentMultiplier == 1)
            return 2;
        if(currentMultiplier == 2)
            return 3;
        if(currentMultiplier == 3)
            return 5;
        return 10;
    }
    
    //computes next tier price as: price = multiplier value * 0.1eth
    function getNextStakingMultiplierCost(address stakerAddress) public view returns (uint256)
    {
        if(getCurrentStakingMultiplier(stakerAddress) == getNextStakingMultiplier(stakerAddress))
            return 0;
        return getNextStakingMultiplier(stakerAddress).mul(10 ** 17);
    }
    
    
    // ------------------------------------------------------------------------
    //HELPERS
    // ------------------------------------------------------------------------
    
    function findOnePercent(uint256 value) public pure returns (uint256)  
    {
        uint256 roundValue = value.ceil(100);
        uint256 onePercent = roundValue.mul(100).div(10000);
        return onePercent;
    }
    
    function appendDecimals(uint256 value_unwrapped) public pure returns (uint256)
    {
        return value_unwrapped.mul(10**uint256(tokenDecimals));
    }
    
}