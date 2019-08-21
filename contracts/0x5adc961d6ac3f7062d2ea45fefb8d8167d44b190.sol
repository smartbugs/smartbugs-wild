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

contract ERC20Basic {
  function totalSupply() public view returns (uint256);
  function balanceOf(address who) public view returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}

contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender) public view returns (uint256);
  function transferFrom(address from, address to, uint256 value) public returns (bool);
  function approve(address spender, uint256 value) public returns (bool);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}



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
  function allowance(address _owner, address _spender) public view returns (uint256) {
    return allowed[_owner][_spender];
  }

  /**
   * @dev Increase the amount of tokens that an owner allowed to a spender.
   *
   * approve should be called when allowed[_spender] == 0. To increment
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   * @param _spender The address which will spend the funds.
   * @param _addedValue The amount of tokens to increase the allowance by.
   */
  function increaseApproval(address _spender, uint _addedValue) public returns (bool) {
    allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
    Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

  /**
   * @dev Decrease the amount of tokens that an owner allowed to a spender.
   *
   * approve should be called when allowed[_spender] == 0. To decrement
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   * @param _spender The address which will spend the funds.
   * @param _subtractedValue The amount of tokens to decrease the allowance by.
   */
  function decreaseApproval(address _spender, uint _subtractedValue) public returns (bool) {
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

contract MintableToken is StandardToken, Ownable {
  event Mint(address indexed to, uint256 amount);
  event MintFinished();

  bool public mintingFinished = false;


  modifier canMint() {
    require(!mintingFinished);
    _;
  }

  /**
   * @dev Function to mint tokens
   * @param _to The address that will receive the minted tokens.
   * @param _amount The amount of tokens to mint.
   * @return A boolean that indicates if the operation was successful.
   */
  function mint(address _to, uint256 _amount) onlyOwner canMint public returns (bool) {
    totalSupply_ = totalSupply_.add(_amount);
    balances[_to] = balances[_to].add(_amount);
    Mint(_to, _amount);
    Transfer(address(0), _to, _amount);
    return true;
  }

  /**
   * @dev Function to stop minting new tokens.
   * @return True if the operation was successful.
   */
  function finishMinting() onlyOwner canMint public returns (bool) {
    mintingFinished = true;
    MintFinished();
    return true;
  }
}

contract Whitelistable is Ownable {
    
    event LogUserRegistered(address indexed sender, address indexed userAddress);
    event LogUserUnregistered(address indexed sender, address indexed userAddress);
    
    mapping(address => bool) public whitelisted;

    function registerUser(address userAddress) 
        public 
        onlyOwner 
    {
        require(userAddress != 0);
        whitelisted[userAddress] = true;
        LogUserRegistered(msg.sender, userAddress);
    }

    function unregisterUser(address userAddress) 
        public 
        onlyOwner 
    {
        require(whitelisted[userAddress] == true);
        whitelisted[userAddress] = false;
        LogUserUnregistered(msg.sender, userAddress);
    }
}

contract DisbursementHandler is Ownable {

    struct Disbursement {
        uint256 timestamp;
        uint256 tokens;
    }

    event LogSetup(address indexed vestor, uint256 tokens, uint256 timestamp);
    event LogChangeTimestamp(address indexed vestor, uint256 index, uint256 timestamp);
    event LogWithdraw(address indexed to, uint256 value);

    ERC20 public token;
    mapping(address => Disbursement[]) public disbursements;
    mapping(address => uint256) public withdrawnTokens;

    function DisbursementHandler(address _token) public {
        token = ERC20(_token);
    }

    /// @dev Called by the sale contract to create a disbursement.
    /// @param vestor The address of the beneficiary.
    /// @param tokens Amount of tokens to be locked.
    /// @param timestamp Funds will be locked until this timestamp.
    function setupDisbursement(
        address vestor,
        uint256 tokens,
        uint256 timestamp
    )
        public
        onlyOwner
    {
        require(block.timestamp < timestamp);
        disbursements[vestor].push(Disbursement(timestamp, tokens));
        LogSetup(vestor, timestamp, tokens);
    }

    /// @dev Change an existing disbursement.
    /// @param vestor The address of the beneficiary.
    /// @param timestamp Funds will be locked until this timestamp.
    /// @param index Index of the DisbursementVesting in the vesting array.
    function changeTimestamp(
        address vestor,
        uint256 index,
        uint256 timestamp
    )
        public
        onlyOwner
    {
        require(block.timestamp < timestamp);
        require(index < disbursements[vestor].length);
        disbursements[vestor][index].timestamp = timestamp;
        LogChangeTimestamp(vestor, index, timestamp);
    }

    /// @dev Transfers tokens to a given address
    /// @param to Address of token receiver
    /// @param value Number of tokens to transfer
    function withdraw(address to, uint256 value)
        public
    {
        uint256 maxTokens = calcMaxWithdraw();
        uint256 withdrawAmount = value < maxTokens ? value : maxTokens;
        withdrawnTokens[msg.sender] = SafeMath.add(withdrawnTokens[msg.sender], withdrawAmount);
        token.transfer(to, withdrawAmount);
        LogWithdraw(to, value);
    }

    /// @dev Calculates the maximum amount of vested tokens
    /// @return Number of vested tokens to withdraw
    function calcMaxWithdraw()
        public
        constant
        returns (uint256)
    {
        uint256 maxTokens = 0;
        Disbursement[] storage temp = disbursements[msg.sender];
        for (uint256 i = 0; i < temp.length; i++) {
            if (block.timestamp > temp[i].timestamp) {
                maxTokens = SafeMath.add(maxTokens, temp[i].tokens);
            }
        }
        maxTokens = SafeMath.sub(maxTokens, withdrawnTokens[msg.sender]);
        return maxTokens;
    }
}

library StateMachineLib {

    struct Stage {
        // The id of the next stage
        bytes32 nextId;

        // The identifiers for the available functions in each stage
        mapping(bytes4 => bool) allowedFunctions;
    }

    struct State {
        // The current stage id
        bytes32 currentStageId;

        // A callback that is called when entering this stage
        function(bytes32) internal onTransition;

        // Checks if a stage id is valid
        mapping(bytes32 => bool) validStage;

        // Maps stage ids to their Stage structs
        mapping(bytes32 => Stage) stages;
    }

    /// @dev Creates and sets the initial stage. It has to be called before creating any transitions.
    /// @param stageId The id of the (new) stage to set as initial stage.
    function setInitialStage(State storage self, bytes32 stageId) internal {
        self.validStage[stageId] = true;
        self.currentStageId = stageId;
    }

    /// @dev Creates a transition from 'fromId' to 'toId'. If fromId already had a nextId, it deletes the now unreachable stage.
    /// @param fromId The id of the stage from which the transition begins.
    /// @param toId The id of the stage that will be reachable from "fromId".
    function createTransition(State storage self, bytes32 fromId, bytes32 toId) internal {
        require(self.validStage[fromId]);

        Stage storage from = self.stages[fromId];

        // Invalidate the stage that won't be reachable any more
        if (from.nextId != 0) {
            self.validStage[from.nextId] = false;
            delete self.stages[from.nextId];
        }

        from.nextId = toId;
        self.validStage[toId] = true;
    }

    /// @dev Goes to the next stage if posible (if the next stage is valid)
    function goToNextStage(State storage self) internal {
        Stage storage current = self.stages[self.currentStageId];

        require(self.validStage[current.nextId]);

        self.currentStageId = current.nextId;

        self.onTransition(current.nextId);
    }

    /// @dev Checks if the a function is allowed in the current stage.
    /// @param selector A function selector (bytes4[keccak256(functionSignature)])
    /// @return true If the function is allowed in the current stage
    function checkAllowedFunction(State storage self, bytes4 selector) internal constant returns(bool) {
        return self.stages[self.currentStageId].allowedFunctions[selector];
    }

    /// @dev Allow a function in the given stage.
    /// @param stageId The id of the stage
    /// @param selector A function selector (bytes4[keccak256(functionSignature)])
    function allowFunction(State storage self, bytes32 stageId, bytes4 selector) internal {
        require(self.validStage[stageId]);
        self.stages[stageId].allowedFunctions[selector] = true;
    }


}

contract StateMachine {
    using StateMachineLib for StateMachineLib.State;

    event LogTransition(bytes32 indexed stageId, uint256 blockNumber);

    StateMachineLib.State internal state;

    /* This modifier performs the conditional transitions and checks that the function 
     * to be executed is allowed in the current stage
     */
    modifier checkAllowed {
        conditionalTransitions();
        require(state.checkAllowedFunction(msg.sig));
        _;
    }

    function StateMachine() public {
        // Register the startConditions function and the onTransition callback
        state.onTransition = onTransition;
    }

    /// @dev Gets the current stage id.
    /// @return The current stage id.
    function getCurrentStageId() public view returns(bytes32) {
        return state.currentStageId;
    }

    /// @dev Performs conditional transitions. Can be called by anyone.
    function conditionalTransitions() public {

        bytes32 nextId = state.stages[state.currentStageId].nextId;

        while (state.validStage[nextId]) {
            StateMachineLib.Stage storage next = state.stages[nextId];
            // If the next stage's condition is true, go to next stage and continue
            if (startConditions(nextId)) {
                state.goToNextStage();
                nextId = next.nextId;
            } else {
                break;
            }
        }
    }

    /// @dev Determines whether the conditions for transitioning to the given stage are met.
    /// @return true if the conditions are met for the given stageId. False by default (must override in child contracts).
    function startConditions(bytes32) internal constant returns(bool) {
        return false;
    }

    /// @dev Callback called when there is a stage transition. It should be overridden for additional functionality.
    function onTransition(bytes32 stageId) internal {
        LogTransition(stageId, block.number);
    }


}

contract TimedStateMachine is StateMachine {

    event LogSetStageStartTime(bytes32 indexed stageId, uint256 startTime);

    // Stores the start timestamp for each stage (the value is 0 if the stage doesn't have a start timestamp).
    mapping(bytes32 => uint256) internal startTime;

    /// @dev This function overrides the startConditions function in the parent contract in order to enable automatic transitions that depend on the timestamp.
    function startConditions(bytes32 stageId) internal constant returns(bool) {
        // Get the startTime for stage
        uint256 start = startTime[stageId];
        // If the startTime is set and has already passed, return true.
        return start != 0 && block.timestamp > start;
    }

    /// @dev Sets the starting timestamp for a stage.
    /// @param stageId The id of the stage for which we want to set the start timestamp.
    /// @param timestamp The start timestamp for the given stage. It should be bigger than the current one.
    function setStageStartTime(bytes32 stageId, uint256 timestamp) internal {
        require(state.validStage[stageId]);
        require(timestamp > block.timestamp);

        startTime[stageId] = timestamp;
        LogSetStageStartTime(stageId, timestamp);
    }

    /// @dev Returns the timestamp for the given stage id.
    /// @param stageId The id of the stage for which we want to set the start timestamp.
    function getStageStartTime(bytes32 stageId) public view returns(uint256) {
        return startTime[stageId];
    }
}

contract Sale is Ownable, TimedStateMachine {
    using SafeMath for uint256;

    event LogContribution(address indexed contributor, uint256 amountSent, uint256 excessRefunded);
    event LogTokenAllocation(address indexed contributor, uint256 contribution, uint256 tokens);
    event LogDisbursement(address indexed beneficiary, uint256 tokens);

    // Stages for the state machine
    bytes32 public constant SETUP = "setup";
    bytes32 public constant SETUP_DONE = "setupDone";
    bytes32 public constant SALE_IN_PROGRESS = "saleInProgress";
    bytes32 public constant SALE_ENDED = "saleEnded";

    mapping(address => uint256) public contributions;

    uint256 public weiContributed = 0;
    uint256 public contributionCap;

    // Wallet where funds will be sent
    address public wallet;

    MintableToken public token;

    DisbursementHandler public disbursementHandler;

    function Sale(
        address _wallet, 
        uint256 _contributionCap
    ) 
        public 
    {
        require(_wallet != 0);
        require(_contributionCap != 0);

        wallet = _wallet;

        token = createTokenContract();
        disbursementHandler = new DisbursementHandler(token);

        contributionCap = _contributionCap;

        setupStages();
    }

    function() external payable {
        contribute();
    }

    /// @dev Sets the start timestamp for the SALE_IN_PROGRESS stage.
    /// @param timestamp The start timestamp.
    function setSaleStartTime(uint256 timestamp) 
        external 
        onlyOwner 
        checkAllowed
    {
        // require(_startTime < getStageStartTime(SALE_ENDED));
        setStageStartTime(SALE_IN_PROGRESS, timestamp);
    }

    /// @dev Sets the start timestamp for the SALE_ENDED stage.
    /// @param timestamp The start timestamp.
    function setSaleEndTime(uint256 timestamp) 
        external 
        onlyOwner 
        checkAllowed
    {
        require(getStageStartTime(SALE_IN_PROGRESS) < timestamp);
        setStageStartTime(SALE_ENDED, timestamp);
    }

    /// @dev Called in the SETUP stage, check configurations and to go to the SETUP_DONE stage.
    function setupDone() 
        public 
        onlyOwner 
        checkAllowed
    {
        uint256 _startTime = getStageStartTime(SALE_IN_PROGRESS);
        uint256 _endTime = getStageStartTime(SALE_ENDED);
        require(block.timestamp < _startTime);
        require(_startTime < _endTime);

        state.goToNextStage();
    }

    /// @dev Called by users to contribute ETH to the sale.
    function contribute() 
        public 
        payable
        checkAllowed 
    {
        require(msg.value > 0);   

        uint256 contributionLimit = getContributionLimit(msg.sender);
        require(contributionLimit > 0);

        // Check that the user is allowed to contribute
        uint256 totalContribution = contributions[msg.sender].add(msg.value);
        uint256 excess = 0;

        // Check if it goes over the eth cap for the sale.
        if (weiContributed.add(msg.value) > contributionCap) {
            // Subtract the excess
            excess = weiContributed.add(msg.value).sub(contributionCap);
            totalContribution = totalContribution.sub(excess);
        }

        // Check if it goes over the contribution limit of the user. 
        if (totalContribution > contributionLimit) {
            excess = excess.add(totalContribution).sub(contributionLimit);
            contributions[msg.sender] = contributionLimit;
        } else {
            contributions[msg.sender] = totalContribution;
        }

        // We are only able to refund up to msg.value because the contract will not contain ether
        // excess = excess < msg.value ? excess : msg.value;
        require(excess <= msg.value);

        weiContributed = weiContributed.add(msg.value).sub(excess);

        if (excess > 0) {
            msg.sender.transfer(excess);
        }

        wallet.transfer(this.balance);

        assert(contributions[msg.sender] <= contributionLimit);
        LogContribution(msg.sender, msg.value, excess);
    }

    /// @dev Create a disbursement of tokens.
    /// @param beneficiary The beneficiary of the disbursement.
    /// @param tokenAmount Amount of tokens to be locked.
    /// @param timestamp Tokens will be locked until this timestamp.
    function distributeTimelockedTokens(
        address beneficiary,
        uint256 tokenAmount,
        uint256 timestamp
    ) 
        public
        onlyOwner
        checkAllowed
    { 
        disbursementHandler.setupDisbursement(
            beneficiary,
            tokenAmount,
            timestamp
        );
        token.mint(disbursementHandler, tokenAmount);
        LogDisbursement(beneficiary, tokenAmount);
    }
    
    function setupStages() internal {
        // Set the stages
        state.setInitialStage(SETUP);
        state.createTransition(SETUP, SETUP_DONE);
        state.createTransition(SETUP_DONE, SALE_IN_PROGRESS);
        state.createTransition(SALE_IN_PROGRESS, SALE_ENDED);

        state.allowFunction(SETUP, this.distributeTimelockedTokens.selector);
        state.allowFunction(SETUP, this.setSaleStartTime.selector);
        state.allowFunction(SETUP, this.setSaleEndTime.selector);
        state.allowFunction(SETUP, this.setupDone.selector);
        state.allowFunction(SALE_IN_PROGRESS, this.contribute.selector);
        state.allowFunction(SALE_IN_PROGRESS, 0); // fallback
    }

    // Override in the child sales
    function createTokenContract() internal returns (MintableToken);
    function getContributionLimit(address userAddress) public view returns (uint256);

    /// @dev Stage start conditions.
    function startConditions(bytes32 stageId) internal constant returns (bool) {
        // If the cap has been reached, end the sale.
        if (stageId == SALE_ENDED && contributionCap <= weiContributed) {
            return true;
        }
        return super.startConditions(stageId);
    }

    /// @dev State transitions callbacks.
    function onTransition(bytes32 stageId) internal {
        if (stageId == SALE_ENDED) { 
            onSaleEnded(); 
        }
        super.onTransition(stageId);
    }

    /// @dev Callback that gets called when entering the SALE_ENDED stage.
    function onSaleEnded() internal {}
}

contract ERC223ReceivingContract {

    /// @dev Standard ERC223 function that will handle incoming token transfers.
    /// @param _from  Token sender address.
    /// @param _value Amount of tokens.
    /// @param _data  Transaction metadata.
    function tokenFallback(address _from, uint _value, bytes _data) public;

}

contract ERC223Basic is ERC20Basic {

    /**
      * @dev Transfer the specified amount of tokens to the specified address.
      *      Now with a new parameter _data.
      *
      * @param _to    Receiver address.
      * @param _value Amount of tokens that will be transferred.
      * @param _data  Transaction metadata.
      */
    function transfer(address _to, uint _value, bytes _data) public returns (bool);

    /**
      * @dev triggered when transfer is successfully called.
      *
      * @param _from  Sender address.
      * @param _to    Receiver address.
      * @param _value Amount of tokens that will be transferred.
      * @param _data  Transaction metadata.
      */
    event Transfer(address indexed _from, address indexed _to, uint256 indexed _value, bytes _data);
}


contract ERC223BasicToken is ERC223Basic, BasicToken {

    /**
      * @dev Transfer the specified amount of tokens to the specified address.
      *      Invokes the `tokenFallback` function if the recipient is a contract.
      *      The token transfer fails if the recipient is a contract
      *      but does not implement the `tokenFallback` function
      *      or the fallback function to receive funds.
      *
      * @param _to    Receiver address.
      * @param _value Amount of tokens that will be transferred.
      * @param _data  Transaction metadata.
      */
    function transfer(address _to, uint _value, bytes _data) public returns (bool) {
        // Standard function transfer similar to ERC20 transfer with no _data .
        // Added due to backwards compatibility reasons .
        uint codeLength;

        assembly {
            // Retrieve the size of the code on target address, this needs assembly .
            codeLength := extcodesize(_to)
        }

        require(super.transfer(_to, _value));

        if(codeLength>0) {
            ERC223ReceivingContract receiver = ERC223ReceivingContract(_to);
            receiver.tokenFallback(msg.sender, _value, _data);
        }
        Transfer(msg.sender, _to, _value, _data);
        return true;
    }

      /**
      * @dev Transfer the specified amount of tokens to the specified address.
      *      Invokes the `tokenFallback` function if the recipient is a contract.
      *      The token transfer fails if the recipient is a contract
      *      but does not implement the `tokenFallback` function
      *      or the fallback function to receive funds.
      *
      * @param _to    Receiver address.
      * @param _value Amount of tokens that will be transferred.
      */
    function transfer(address _to, uint256 _value) public returns (bool) {
        bytes memory empty;
        require(transfer(_to, _value, empty));
        return true;
    }

}

contract DetailedERC20 is ERC20 {
  string public name;
  string public symbol;
  uint8 public decimals;

  function DetailedERC20(string _name, string _symbol, uint8 _decimals) public {
    name = _name;
    symbol = _symbol;
    decimals = _decimals;
  }
}

contract DetherToken is DetailedERC20, MintableToken, ERC223BasicToken {
    string constant NAME = "Dether";
    string constant SYMBOL = "DTH";
    uint8 constant DECIMALS = 18;

    /**
      *@dev Constructor that set Detailed of the ERC20 token.
      */
    function DetherToken()
        DetailedERC20(NAME, SYMBOL, DECIMALS)
        public
    {}
}


contract DetherSale is Sale, Whitelistable {

    uint256 public constant PRESALE_WEI = 3956 ether * 1.15 + 490 ether; // Amount raised in the presale including bonus

    uint256 public constant DECIMALS_MULTIPLIER = 1000000000000000000;
    uint256 public constant MAX_DTH = 100000000 * DECIMALS_MULTIPLIER;

    // MAX_WEI - PRESALE_WEI
    // TODO: change to actual amount
    uint256 public constant WEI_CAP = 10554 ether;

    // Duration of the whitelisting phase
    uint256 public constant WHITELISTING_DURATION = 2 days;

    // Contribution limit for the whitelisting phase
    uint256 public constant WHITELISTING_MAX_CONTRIBUTION = 5 ether;

    // Contribution limit for the public sale
    uint256 public constant PUBLIC_MAX_CONTRIBUTION = 2**256 - 1;

    // Minimum contribution allowed
    uint256 public constant MIN_CONTRIBUTION = 0.1 ether;

    // wei per DTH
    uint256 public weiPerDTH;
    // true if the locked tokens have been distributed
    bool private lockedTokensDistributed;
    // true if the presale tokens have been allocated
    bool private presaleAllocated;

    // Address for the presale buyers (Dether team will distribute manually)
    address public presaleAddress;

    uint256 private weiAllocated;

    // Contribution limits specified for the presale
    mapping(address => uint256) public presaleMaxContribution;

    function DetherSale(address _wallet, address _presaleAddress) Sale(_wallet, WEI_CAP) public {
      presaleAddress = _presaleAddress;
    }

    /// @dev Distributes timed locked tokens
    function performInitialAllocations() external onlyOwner checkAllowed {
        require(lockedTokensDistributed == false);
        lockedTokensDistributed = true;

        // Advisors
        distributeTimelockedTokens(0x4dc976cEd66d1B87C099B338E1F1388AE657377d, MAX_DTH.mul(3).div(100), now + 6 * 4 weeks);

        // Bounty
        distributeTimelockedTokens(0xfEF675cC3068Ee798f2312e82B12c841157A0A0E, MAX_DTH.mul(3).div(100), now + 1 weeks);

        // Early Contributors
        distributeTimelockedTokens(0x8F38C4ddFE09Bd22545262FE160cf441D43d2489, MAX_DTH.mul(25).div(1000), now + 6 * 4 weeks);

        distributeTimelockedTokens(0x87a4eb1c9fdef835DC9197FAff3E09b8007ADe5b, MAX_DTH.mul(25).div(1000), now + 6 * 4 weeks);

        // Strategic Partnerships
        distributeTimelockedTokens(0x6f63D5DF2D8644851cBb5F8607C845704C008284, MAX_DTH.mul(11).div(100), now + 1 weeks);

        // Team (locked 3 years, 6 months release)
        distributeTimelockedTokens(0x24c14796f401D77fc401F9c2FA1dF42A136EbF83, MAX_DTH.mul(3).div(100), now + 6 * 4 weeks);
        distributeTimelockedTokens(0x24c14796f401D77fc401F9c2FA1dF42A136EbF83, MAX_DTH.mul(3).div(100), now + 2 * 6 * 4 weeks);
        distributeTimelockedTokens(0x24c14796f401D77fc401F9c2FA1dF42A136EbF83, MAX_DTH.mul(3).div(100), now + 3 * 6 * 4 weeks);
        distributeTimelockedTokens(0x24c14796f401D77fc401F9c2FA1dF42A136EbF83, MAX_DTH.mul(3).div(100), now + 4 * 6 * 4 weeks);
        distributeTimelockedTokens(0x24c14796f401D77fc401F9c2FA1dF42A136EbF83, MAX_DTH.mul(3).div(100), now + 5 * 6 * 4 weeks);
        distributeTimelockedTokens(0x24c14796f401D77fc401F9c2FA1dF42A136EbF83, MAX_DTH.mul(3).div(100), now + 6 * 6 * 4 weeks);
    }

    /// @dev Registers a user and sets the maximum contribution amount for the whitelisting period
    function registerPresaleContributor(address userAddress, uint256 maxContribution)
        external
        onlyOwner
    {
        // Specified contribution has to be lower than the max
        require(maxContribution <= WHITELISTING_MAX_CONTRIBUTION);

        // Register user (Whitelistable contract)
        registerUser(userAddress);

        // Set contribution
        presaleMaxContribution[userAddress] = maxContribution;
    }

    /// @dev Called to allocate the tokens depending on eth contributed.
    /// @param contributor The address of the contributor.
    function allocateTokens(address contributor)
        external
        checkAllowed
    {
        require(presaleAllocated);
        require(contributions[contributor] != 0);

        // We keep a record of how much wei contributed has already been used for allocations
        weiAllocated = weiAllocated.add(contributions[contributor]);

        // Mint the respective tokens to the contributor
        token.mint(contributor, contributions[contributor].mul(DECIMALS_MULTIPLIER).div(weiPerDTH));

        // Set contributions to 0
        contributions[contributor] = 0;

        // If all tokens were allocated, stop minting functionality
        // and send the remaining (rounding errors) tokens to the owner
        if (weiAllocated == weiContributed) {
          uint256 remaining = MAX_DTH.sub(token.totalSupply());
          token.mint(owner, remaining);
          token.finishMinting();
        }
    }

    /// @dev Called to allocate the tokens for presale address.
    function presaleAllocateTokens()
        external
        checkAllowed
    {
        require(!presaleAllocated);
        presaleAllocated = true;

        // Mint the respective tokens to the contributor
        token.mint(presaleAddress, PRESALE_WEI.mul(DECIMALS_MULTIPLIER).div(weiPerDTH));
    }

    function contribute()
        public
        payable
        checkAllowed
    {
        require(msg.value >= MIN_CONTRIBUTION);

        super.contribute();
    }

    /// @dev The limit will be different for every address during the whitelist period, and after that phase there is no limit for contributions.
    function getContributionLimit(address userAddress) public view returns (uint256) {
        uint256 saleStartTime = getStageStartTime(SALE_IN_PROGRESS);

        // If not whitelisted or sale has not started, return 0
        if (!whitelisted[userAddress] || block.timestamp < saleStartTime) {
            return 0;
        }

        // Are we in the first two days?
        bool whitelistingPeriod = block.timestamp - saleStartTime <= WHITELISTING_DURATION;

        // If we are in the whitelisting period, return the contribution limit for the user
        // If not, return the public max contribution
        return whitelistingPeriod ? presaleMaxContribution[userAddress] : PUBLIC_MAX_CONTRIBUTION;
    }

    function createTokenContract() internal returns(MintableToken) {
        return new DetherToken();
    }

    function setupStages() internal {
        super.setupStages();
        state.allowFunction(SETUP, this.performInitialAllocations.selector);
        state.allowFunction(SALE_ENDED, this.allocateTokens.selector);
        state.allowFunction(SALE_ENDED, this.presaleAllocateTokens.selector);
    }

    /// @dev The price will be the total wei contributed divided by the amount of tokens to be allocated to contributors.
    function calculatePrice() public view returns(uint256) {
        return weiContributed.add(PRESALE_WEI).div(60000000).add(1);
    }

    function onSaleEnded() internal {
        // Calculate DTH per Wei
        weiPerDTH = calculatePrice();
    }
}