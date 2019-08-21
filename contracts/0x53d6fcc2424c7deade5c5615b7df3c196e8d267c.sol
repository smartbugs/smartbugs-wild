pragma solidity ^0.4.16;


/// @title etherfund.me ERC20 tokens issued crowdfunding contract
contract EtherFundMeIssueTokensCrowdfunding {

    ///////////////////////////////////////////////////////////////////////////////
    /// ERC20 Token fields
    ///////////////////////////////////////////////////////////////////////////////
    /// Returns the name of the token - e.g. "MyToken".
    string public name;

    /// Returns the symbol of the token. E.g. "HIX".
    string public symbol;

    /// Returns the number of decimals the token uses - e.g. 8, means to divide the token amount by 100000000 to get its user representation
    uint public decimals;

    /// Returns the total token supply
    uint public totalSupply;

    /// approve() allowances
    mapping (address => mapping (address => uint)) allowed;

    /// holder balances
    mapping(address => uint) balances;

    ///////////////////////////////////////////////////////////////////////////////
    /// Crowdfunding fields
    ///////////////////////////////////////////////////////////////////////////////
    /// The crowdfunding project name
    string public projectName;

    /// The crowdfunding project description
    string public projectDescription;

    /// The crowdfunding team contact
    string public teamEmail;

    /// The start time of crowdfunding
    uint public startsAt;

    /// The end time of crowdfunding
    uint public endsAt;

    /// Crowdfunding team wallet
    address public teamWallet;

    /// etherfund.me fee wallet
    address public feeReceiverWallet;

    /// etherfund.me deploy agent
    address public deployAgentWallet;

    /// How much tokens will team will receive
    uint teamTokensAmount;

    /// How much tokens remain for sale
    uint tokensForSale = totalSupply - teamTokensAmount;

    /// How much token cost in wei 
    uint public tokenPrice;

    /// if the funding goal is not reached, investors may withdraw their funds
    uint public fundingGoal;

    ///  How many distinct addresses have invested
    uint public investorCount = 0;

    ///  Has this crowdfunding been finalized
    bool public finalized;

    ///  Has this crowdfunding been paused
    bool public halted;

    ///  How much ETH each address has invested to this crowdfunding
    mapping (address => uint256) public investedAmountOf;

    ///  How much tokens each address has invested to this crowdfunding
    mapping (address => uint256) public tokenAmountOf;

    /// etherfund.me final fee in %
    uint public constant ETHERFUNDME_FEE = 3;

    /// etherfund.me each transaction fee in %
    uint public constant ETHERFUNDME_ONLINE_FEE = 1;

    /// if a project reach 60% of their funding goal it becomes successful
    uint public constant GOAL_REACHED_CRITERION = 80;

    /// Define pricing schedule using milestones.
    struct Milestone {
        // UNIX timestamp when this milestone kicks in
        uint start;
        // UNIX timestamp when this milestone kicks out
        uint end;
        // How many % tokens will add
        uint bonus;
    }

    /// Define a structure for one investment event occurrence
    struct Investment {
        /// Who invested
        address source;

        /// Tokens count
        uint tokensAmount;
    }
 
    /// Milestones list
    Milestone[] public milestones;

    /// Array element counter for investments
    uint public investmentsCount;

    /// How much tokens each address has invested to this contract
    Investment[] public investments;

    /// State machine
    /// Preparing: All contract initialization calls and variables have not been set yet
    /// Funding: Active crowdsale
    /// Success: Minimum funding goal reached
    /// Failure: Minimum funding goal not reached before ending time
    /// Finalized: The finalized has been called and succesfully executed
    /// Refunding: Refunds are loaded on the contract for reclaim
    enum State { Unknown, Preparing, Funding, Success, Failure, Finalized, Refunding }

    ///////////////////////////////////////////////////////////////////////////////
    /// Crowdfunding events
    ///////////////////////////////////////////////////////////////////////////////
    /// A new investment was made
    event Invested(address investor, uint weiAmount);
    /// Withdraw was processed for a contributor
    event Withdraw(address receiver, uint weiAmount);
    /// Returning funds for a contributor
    event Refund(address receiver, uint weiAmount);

    ///////////////////////////////////////////////////////////////////////////////
    /// ERC20 Token events
    ///////////////////////////////////////////////////////////////////////////////
    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);

    ///////////////////////////////////////////////////////////////////////////////
    /// ERC20 Token modifiers
    ///////////////////////////////////////////////////////////////////////////////
    /// @dev Modified allowing execution only if the crowdfunding is currently running
    modifier inState(State state) {
        require(getState() == state);
        _;
    }

    /// @dev Limit token transfer until the sale is over.
    modifier canTransfer() {
        require(finalized);
        _;
    }

    ///////////////////////////////////////////////////////////////////////////////
    /// Crowdfunding modifiers
    ///////////////////////////////////////////////////////////////////////////////
    /// @dev Modified allowing execution only if deploy agent call
    modifier onlyDeployAgent() {
        require(msg.sender == deployAgentWallet);
        _;
    }

    /// @dev Modified allowing execution only if not stopped
    modifier stopInEmergency {
        require(!halted);
        _;
    }

    /// @dev Modified allowing execution only if stopped
    modifier onlyInEmergency {
        require(halted);
        _;
    }

    /// @dev Fix for the ERC20 short address attack http://vessenes.com/the-erc20-short-address-attack-explained/
    /// @param size payload size
    modifier onlyPayloadSize(uint size) {
       require(msg.data.length >= size + 4);
       _;
    }

    /// @dev Constructor
    /// @param _projectName crowdfunding project name
    /// @param _projectDescription crowdfunding project short description
    /// @param _teamEmail crowdfunding team contact
    /// @param _startsAt crowdfunding start time
    /// @param _endsAt crowdfunding end time
    /// @param _fundingGoal funding goal in wei
    /// @param _teamWallet  team address
    /// @param _feeReceiverWallet  fee receiver address
    /// @param _name ERC20 token name
    /// @param _symbol ERC20 token symbol
    /// @param _decimals  ERC20 token decimal
    /// @param _totalSupply  ERC20 token amount
    /// @param _tokenPrice token price in wei
    /// @param _teamTokensAmount token amount for team
    function EtherFundMeIssueTokensCrowdfunding(
      string _projectName,
      string _projectDescription,
      string _teamEmail,
      uint _startsAt,
      uint _endsAt,
      uint _fundingGoal,
      address _teamWallet,
      address _feeReceiverWallet,
      string _name,
      string _symbol,
      uint _decimals,
      uint _totalSupply,
      uint _tokenPrice,
      uint _teamTokensAmount) {
        require(_startsAt != 0);
        require(_endsAt != 0);
        require(_fundingGoal != 0);
        require(_teamWallet != 0);
        require(_feeReceiverWallet != 0);
        require(_decimals >= 2);
        require(_totalSupply > 0);
        require(_tokenPrice > 0);

        deployAgentWallet = msg.sender;
        projectName = _projectName;
        projectDescription = _projectDescription;
        teamEmail = _teamEmail;
        startsAt = _startsAt;
        endsAt = _endsAt;
        fundingGoal = _fundingGoal;
        teamWallet = _teamWallet;
        feeReceiverWallet = _feeReceiverWallet;
        name = _name;
        symbol = _symbol;
        decimals = _decimals;
        totalSupply = _totalSupply;
        tokenPrice = _tokenPrice;
        teamTokensAmount = _teamTokensAmount;
    }

    ///////////////////////////////////////////////////////////////////////////////
    /// Crowdfunding methods
    ///////////////////////////////////////////////////////////////////////////////
    /// @dev Crowdfund state machine management.
    /// @return State current state
    function getState() public constant returns (State) {
        if (finalized)
            return State.Finalized;
        if (startsAt > now)
            return State.Preparing;
        if (now >= startsAt && now < endsAt)
            return State.Funding;
        if (isGoalReached())
            return State.Success;
        if (!isGoalReached() && this.balance > 0)
            return State.Refunding;
        return State.Failure;
    }

    /// @dev Goal was reached
    /// @return true if the crowdsale has raised enough money to be a succes
    function isGoalReached() public constant returns (bool reached) {
        return this.balance >= (fundingGoal * GOAL_REACHED_CRITERION) / 100;
    }

    /// @dev Fallback method
    function() payable {
        invest();
    }

    /// @dev Allow contributions to this crowdfunding.
    function invest() public payable stopInEmergency  {
        require(getState() == State.Funding);
        require(msg.value > 0);

        uint weiAmount = msg.value;
        address investor = msg.sender;

        if(investedAmountOf[investor] == 0) {
            // A new investor
            investorCount++;
        } 

        uint multiplier = 10 ** decimals;
        uint tokensAmount = (weiAmount * multiplier) / tokenPrice;
        assert(tokensAmount > 0);
        
        if(getCurrentMilestone().bonus > 0) {
            tokensAmount += (tokensAmount * getCurrentMilestone().bonus) / 100;
        }

        assert(tokensForSale - tokensAmount >= 0);
        tokensForSale -= tokensAmount;
        investments.push(Investment(investor, tokensAmount));
        investmentsCount++;
        tokenAmountOf[investor] += tokensAmount;

        // calculate online fee
        uint onlineFeeAmount = (weiAmount * ETHERFUNDME_ONLINE_FEE) / 100;
        Withdraw(feeReceiverWallet, onlineFeeAmount);
        // send online fee
        feeReceiverWallet.transfer(onlineFeeAmount);

        uint investedAmount = weiAmount - onlineFeeAmount;
        // Update investor
        investedAmountOf[investor] += investedAmount;
        // Tell us invest was success
        Invested(investor, investedAmount);
    }

    /// @dev Finalize a succcesful crowdfunding. The team can triggre a call the contract that provides post-crowdfunding actions, like releasing the funds.
    function finalize() public inState(State.Success) stopInEmergency  {
        require(msg.sender == deployAgentWallet || msg.sender == teamWallet);
        require(!finalized);

        finalized = true;

        uint feeAmount = (this.balance * ETHERFUNDME_FEE) / 100;
        uint teamAmount = this.balance - feeAmount;

        Withdraw(teamWallet, teamAmount);
        teamWallet.transfer(teamAmount);

        Withdraw(feeReceiverWallet, feeAmount);
        feeReceiverWallet.transfer(feeAmount);

        // assign team tokens 
        balances[teamWallet] += (teamTokensAmount + tokensForSale);
        
        // Distribute tokens to investors
        for (uint i = 0; i < investments.length; i++) {
            balances[investments[i].source] += investments[i].tokensAmount;
            Transfer(0, investments[i].source, investments[i].tokensAmount);
        }
    }

    /// @dev Investors can claim refund.
    function refund() public inState(State.Refunding) {
        uint weiValue = investedAmountOf[msg.sender];
        if (weiValue == 0) revert();
        investedAmountOf[msg.sender] = 0;
        Refund(msg.sender, weiValue);
        msg.sender.transfer(weiValue);
    }
    
    
    /// @dev Called by the deploy agent on emergency, triggers stopped state
    function halt() public onlyDeployAgent {
        halted = true;
    }

    /// @dev Called by the deploy agent on end of emergency, returns to normal state
    function unhalt() public onlyDeployAgent onlyInEmergency {
        halted = false;
    }

    /// @dev Add a milestone
    /// @param _start start bonus time 
    /// @param _end end bonus  time
    /// @param _bonus bonus percent
    function addMilestone(uint _start, uint _end, uint _bonus) public onlyDeployAgent {
        require(_bonus > 0 && _end > _start);
        milestones.push(Milestone(_start, _end, _bonus));
    }

    /// @dev Get the current milestone or bail out if we are not in the milestone periods.
    /// @return Milestone current bonus milestone
    function getCurrentMilestone() private constant returns (Milestone) {
        for (uint i = 0; i < milestones.length; i++) {
            if (milestones[i].start <= now && milestones[i].end > now) {
                return milestones[i];
            }
        }
    }
    ///////////////////////////////////////////////////////////////////////////////
    /// ERC20 Token methods
    ///////////////////////////////////////////////////////////////////////////////
    /// @dev Returns the account balance of another account with address _owner
    /// @param _owner holder address
    /// @return balance amount
    function balanceOf(address _owner) constant returns (uint balance) {
        return balances[_owner];
    }

    /// @dev Transfers _value amount of tokens to address _to, and MUST fire the Transfer event. The function SHOULD throw if the _from account balance does not have enough tokens to spend.
    /// @param _to dest address
    /// @param _value tokens amount
    /// @return transfer result
    function transfer(address _to, uint _value) onlyPayloadSize(2 * 32) canTransfer returns (bool success) {
        require((_to != 0) && (_to != address(this)));
        require(balances[msg.sender] >= _value);

        balances[msg.sender] -= _value;
        balances[_to] += _value;

        Transfer(msg.sender, _to, _value);
        return true;
    }

    /// @dev Transfers _value amount of tokens from address _from to address _to, and MUST fire the Transfer event.
    /// @param _from source address
    /// @param _to dest address
    /// @param _value tokens amount
    /// @return transfer result
    function transferFrom(address _from, address _to, uint _value) onlyPayloadSize(2 * 32) canTransfer returns (bool success) {
        require(balances[_from] >= _value && allowed[_from][msg.sender] >= _value);

        balances[_to] += _value;
        balances[_from] -= _value;

        allowed[_from][msg.sender] -= _value;
        Transfer(_from, _to, _value);
        return true;
    }

    /// @dev Allows _spender to withdraw from your account multiple times, up to the _value amount. If this function is called again it overwrites the current allowance with _value.
    /// @param _spender holder address
    /// @param _value tokens amount
    /// @return result
    function approve(address _spender, uint _value) returns (bool success) {
        // To change the approve amount you first have to reduce the addresses`
        //  allowance to zero by calling `approve(_spender, 0)` if it is not
        //  already 0 to mitigate the race condition described here:
        //  https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
        require ((_value == 0) || (allowed[msg.sender][_spender] == 0));

        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }

    /// @dev Returns the amount which _spender is still allowed to withdraw from _owner.
    /// @param _owner holder address
    /// @param _spender spender address
    /// @return remain amount
    function allowance(address _owner, address _spender) constant returns (uint remaining) {
        return allowed[_owner][_spender];
    }
}