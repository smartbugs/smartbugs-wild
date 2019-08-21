/// @title SafeMath
/// @dev Math operations with safety checks that throw on error
library SafeMath {
    /// @dev Multiplies a times b
    function mul(uint256 a, uint256 b) 
    internal 
    pure
    returns (uint256) 
    {
        uint256 c = a * b;
        require(a == 0 || c / a == b);
        return c;
    }

    /// @dev Divides a by b
    function div(uint256 a, uint256 b) 
    internal 
    pure
    returns (uint256) 
    {
        // require(b > 0); // Solidity automatically throws when dividing by 0
        uint256 c = a / b;
        // require(a == b * c + a % b); // There is no case in which this doesn't hold
        return c;
    }

    /// @dev Subtracts a from b
    function sub(uint256 a, uint256 b) 
    internal 
    pure
    returns (uint256) 
    {
        require(b <= a);
        return a - b;
    }

    /// @dev Adds a to b
    function add(uint256 a, uint256 b) 
    internal 
    pure
    returns (uint256) 
    {
        uint256 c = a + b;
        require(c >= a);
        return c;
    }
}



/// Implements ERC 20 Token standard: https://github.com/ethereum/EIPs/issues/20
/// @title Abstract token contract - Functions to be implemented by token contracts
contract Token {
    /*
     * Events
     */
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    /*
     * Public functions
     */
    function transfer(address to, uint256 value) public returns (bool);
    function transferFrom(address from, address to, uint256 value) public returns (bool);
    function approve(address spender, uint256 value) public returns (bool);
    function balanceOf(address owner) public constant returns (uint256);
    function allowance(address owner, address spender) public constant returns (uint256);
    uint256 public totalSupply;
}


/// @title Standard token contract - Standard token interface implementation
contract StandardToken is Token {
  using SafeMath for uint256;
    /*
     *  Storage
     */
    mapping (address => uint256) public balances;
    mapping (address => mapping (address => uint256)) public allowances;
    uint256 public totalSupply;

    /*
     *  Public functions
     */
    /// @dev Transfers sender's tokens to a given address. Returns success
    /// @param to Address of token receiver
    /// @param value Number of tokens to transfer
    /// @return Returns success of function call
    function transfer(address to, uint256 value)
        public
        returns (bool)
    {
        require(to != address(0));
        require(value <= balances[msg.sender]);
        balances[msg.sender] = balances[msg.sender].sub(value);
        balances[to] = balances[to].add(value);
        Transfer(msg.sender, to, value);
        return true;
    }

    /// @dev Allows allowances third party to transfer tokens from one address to another. Returns success
    /// @param from Address from where tokens are withdrawn
    /// @param to Address to where tokens are sent
    /// @param value Number of tokens to transfer
    /// @return Returns success of function call
    function transferFrom(address from, address to, uint256 value)
        public
        returns (bool)
    {
        // if (balances[from] < value || allowances[from][msg.sender] < value)
        //     // Balance or allowance too low
        //     revert();
        require(to != address(0));
        require(value <= balances[from]);
        require(value <= allowances[from][msg.sender]);
        balances[to] = balances[to].add(value);
        balances[from] = balances[from].sub(value);
        allowances[from][msg.sender] = allowances[from][msg.sender].sub(value);
        Transfer(from, to, value);
        return true;
    }

    /// @dev Sets approved amount of tokens for spender. Returns success
    /// @param _spender Address of allowances account
    /// @param value Number of approved tokens
    /// @return Returns success of function call
    function approve(address _spender, uint256 value)
        public
        returns (bool success)
    {
        require((value == 0) || (allowances[msg.sender][_spender] == 0));
        allowances[msg.sender][_spender] = value;
        Approval(msg.sender, _spender, value);
        return true;
    }

 /**
   * approve should be called when allowances[_spender] == 0. To increment
   * allowances value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   */
    function increaseApproval(address _spender, uint _addedValue)
        public
        returns (bool)
    {
        allowances[msg.sender][_spender] = allowances[msg.sender][_spender].add(_addedValue);
        Approval(msg.sender, _spender, allowances[msg.sender][_spender]);
        return true;
    }

    function decreaseApproval(address _spender, uint _subtractedValue)
        public
        returns (bool) 
    {
        uint oldValue = allowances[msg.sender][_spender];
        if (_subtractedValue > oldValue) {
            allowances[msg.sender][_spender] = 0;
        } else {
            allowances[msg.sender][_spender] = oldValue.sub(_subtractedValue);
        }
        Approval(msg.sender, _spender, allowances[msg.sender][_spender]);
        return true;
    }

    /// @dev Returns number of allowances tokens for given address
    /// @param _owner Address of token owner
    /// @param _spender Address of token spender
    /// @return Returns remaining allowance for spender
    function allowance(address _owner, address _spender)
        public
        constant
        returns (uint256)
    {
        return allowances[_owner][_spender];
    }

    /// @dev Returns number of tokens owned by given address
    /// @param _owner Address of token owner
    /// @return Returns balance of owner
    function balanceOf(address _owner)
        public
        constant
        returns (uint256)
    {
        return balances[_owner];
    }
}


contract Balehubuck is StandardToken {
    using SafeMath for uint256;
    /*
     *  Constants
     */
    string public constant name = "balehubuck";
    string public constant symbol = "BUX";
    uint8 public constant decimals = 18;
    uint256 public constant TOTAL_SUPPLY = 1000000000 * 10**18;
    // Presale Allocation = 500 * (5000 + 4500 + 4000 + 3500 + 3250 + 3000)
    // Main Sale Allocation = 75000 * 2500
    // Token Sale Allocation = Presale Allocation + Main Sale Allocation
    uint256 public constant TOKEN_SALE_ALLOCATION = 199125000 * 10**18;
    uint256 public constant WALLET_ALLOCATION = 800875000 * 10**18;

    function Balehubuck(address wallet)
        public
    {
        totalSupply = TOTAL_SUPPLY;
        balances[msg.sender] = TOKEN_SALE_ALLOCATION;
        balances[wallet] = WALLET_ALLOCATION;
        // Sanity check to make sure total allocations match total supply
        require(TOKEN_SALE_ALLOCATION + WALLET_ALLOCATION == TOTAL_SUPPLY);
    }
}


contract TokenSale {
    using SafeMath for uint256;
    /*
     *  Events
     */
    event PresaleStart(uint256 indexed presaleStartTime);
    event AllocatePresale(address indexed receiver, uint256 tokenQuantity);
    event PresaleEnd(uint256 indexed presaleEndTime);
    event MainSaleStart(uint256 indexed startMainSaleTime);
    event AllocateMainSale(address indexed receiver, uint256 etherAmount);
    event MainSaleEnd(uint256 indexed endMainSaleTime);
    event TradingStart(uint256 indexed startTradingTime);
    event Refund(address indexed receiver, uint256 etherAmount);

    /*
     *  Constants
     */
    // Presale Allocation = 500 * (5000 + 4500 + 4000 + 3500 + 3250 + 3000) * 10**18
    uint256 public constant PRESALE_TOKEN_ALLOCATION = 11625000 * 10**18;
    uint256 public constant PRESALE_MAX_RAISE = 3000 * 10**18;

    /*
     *  Storage
     */
    mapping (address => uint256) public presaleAllocations;
    mapping (address => uint256) public mainSaleAllocations;
    address public wallet;
    Balehubuck public token;
    uint256 public presaleEndTime;
    uint256 public mainSaleEndTime;
    uint256 public minTradingStartTime;
    uint256 public maxTradingStartTime;
    uint256 public totalReceived;
    uint256 public minimumMainSaleRaise;
    uint256 public maximumMainSaleRaise;
    uint256 public maximumAllocationPerParticipant;
    uint256 public mainSaleExchangeRate;
    Stages public stage;

    enum Stages {
        Deployed,
        PresaleStarted,
        PresaleEnded,
        MainSaleStarted,
        MainSaleEnded,
        Refund,
        Trading
    }

    /*
     *  Modifiers
     */
    modifier onlyWallet() {
        require(wallet == msg.sender);
        _;
    }

    modifier atStage(Stages _stage) {
        require(stage == _stage);
        _;
    }

    /*
     *  Fallback function
     */
    function ()
        external
        payable
    {
        buy(msg.sender);
    }

    /*
     *  Constructor function
     */
    // @dev Constructor function that create the Balehubuck token and sets the initial variables
    // @param _wallet sets the wallet state variable which will be used to start stages throughout the token sale
    function TokenSale(address _wallet)
        public
    {
        require(_wallet != 0x0);
        wallet = _wallet;
        token = new Balehubuck(wallet);
        // Sets the default main sale values
        minimumMainSaleRaise = 23000 * 10**18;
        maximumMainSaleRaise = 78000 * 10**18;
        maximumAllocationPerParticipant = 750 * 10**18;
        mainSaleExchangeRate = 2500;
        stage = Stages.Deployed;
        totalReceived = 0;
    }

    /*
     *  Public functions
     */
    // @ev Allows buyers to buy tokens, throws if neither the presale or main sale is happening
    // @param _receiver The address the will receive the tokens
    function buy(address _receiver)
        public
        payable
    {
        require(msg.value > 0);
        address receiver = _receiver;
        if (receiver == 0x0)
            receiver = msg.sender;
        if (stage == Stages.PresaleStarted) {
            buyPresale(receiver);
        } else if (stage == Stages.MainSaleStarted) {
            buyMainSale(receiver);
        } else {
            revert();
        }
    }

    /*
     *  External functions
     */
    // @dev Starts the presale
    function startPresale()
        external
        onlyWallet
        atStage(Stages.Deployed)
    {
        stage = Stages.PresaleStarted;
        presaleEndTime = now + 8 weeks;
        PresaleStart(now);
    }

    // @dev Sets the maximum and minimum raise amounts prior to the main sale
    // @dev Use this method with extreme caution!
    // @param _minimumMainSaleRaise Sets the minimium main sale raise
    // @param _maximumMainSaleRaise Sets the maximum main sale raise
    // @param _maximumAllocationPerParticipant sets the maximum main sale allocation per participant
    function changeSettings(uint256 _minimumMainSaleRaise,
                            uint256 _maximumMainSaleRaise,
                            uint256 _maximumAllocationPerParticipant,
                            uint256 _mainSaleExchangeRate)
        external
        onlyWallet
        atStage(Stages.PresaleEnded)
    {
        // Checks the inputs for null values
        require(_minimumMainSaleRaise > 0 &&
                _maximumMainSaleRaise > 0 &&
                _maximumAllocationPerParticipant > 0 &&
                _mainSaleExchangeRate > 0);
        // Sanity check that requires the min raise to be less then the max
        require(_minimumMainSaleRaise < _maximumMainSaleRaise);
        // This check verifies that the token_sale contract has enough tokens to match the
        // _maximumMainSaleRaiseAmount * _mainSaleExchangeRate (subtracts presale amounts first)
        require(_maximumMainSaleRaise.sub(PRESALE_MAX_RAISE).mul(_mainSaleExchangeRate) <= token.balanceOf(this).sub(PRESALE_TOKEN_ALLOCATION));
        minimumMainSaleRaise = _minimumMainSaleRaise;
        maximumMainSaleRaise = _maximumMainSaleRaise;
        mainSaleExchangeRate = _mainSaleExchangeRate;
        maximumAllocationPerParticipant = _maximumAllocationPerParticipant;
    }

    // @dev Starts the main sale
    // @dev Make sure the main sale variables are correct before calling
    function startMainSale()
        external
        onlyWallet
        atStage(Stages.PresaleEnded)
    {
        stage = Stages.MainSaleStarted;
        mainSaleEndTime = now + 8 weeks;
        MainSaleStart(now);
    }

    // @dev Starts the trading stage, allowing buyer to claim their tokens
    function startTrading()
        external
        atStage(Stages.MainSaleEnded)
    {
        // Trading starts between two weeks (if called by the wallet) and two months (callable by anyone)
        // after the main sale has ended
        require((msg.sender == wallet && now >= minTradingStartTime) || now >= maxTradingStartTime);
        stage = Stages.Trading;
        TradingStart(now);
    }

    // @dev Allows buyer to be refunded their ETH if the minimum presale raise amount hasn't been met
    function refund() 
        external
        atStage(Stages.Refund)
    {
        uint256 amount = mainSaleAllocations[msg.sender];
        mainSaleAllocations[msg.sender] = 0;
        msg.sender.transfer(amount);
        Refund(msg.sender, amount);
    }

    // @dev Allows buyers to claim the tokens they've purchased
    function claimTokens()
        external
        atStage(Stages.Trading)
    {
        uint256 tokenAllocation = presaleAllocations[msg.sender].add(mainSaleAllocations[msg.sender].mul(mainSaleExchangeRate));
        presaleAllocations[msg.sender] = 0;
        mainSaleAllocations[msg.sender] = 0;
        token.transfer(msg.sender, tokenAllocation);
    }

    /*
     *  Private functions
     */
    // @dev Allocated tokens to the presale buyer at a rate based on the total received
    // @param receiver The address presale balehubucks will be allocated to
    function buyPresale(address receiver)
        private
    {
        if (now >= presaleEndTime) {
            endPresale();
            return;
        }
        uint256 totalTokenAllocation = 0;
        uint256 oldTotalReceived = totalReceived;
        uint256 tokenAllocation = 0;
        uint256 weiUsing = 0;
        uint256 weiAmount = msg.value;
        uint256 maxWeiForPresaleStage = 0;
        uint256 buyerRefund = 0;
        // Cycles through the presale phases conditional giving a different exchange rate for
        // each phase of the presale until tokens have been allocated for all Ether sent or 
        // until the presale cap of 3,000 Ether has been reached
        while (true) {
            // The EVM deals with division by rounding down, causing the below statement to
            // round down to the correct stage
            // stageAmount = totalReceived.add(500 * 10**18).div(500 * 10**18).mul(500 * 10**18);
            // maxWeiForPresaleStage = stageAmount - totalReceived
            maxWeiForPresaleStage = (totalReceived.add(500 * 10**18).div(500 * 10**18).mul(500 * 10**18)).sub(totalReceived);
            if (weiAmount > maxWeiForPresaleStage) {
                weiUsing = maxWeiForPresaleStage;
            } else {
                weiUsing = weiAmount;
            }
            weiAmount = weiAmount.sub(weiUsing);
            if (totalReceived < 500 * 10**18) {
            // Stage 1: up to 500 Ether, exchange rate of 1 ETH for 5000 BUX
                tokenAllocation = calcpresaleAllocations(weiUsing, 5000);
            } else if (totalReceived < 1000 * 10**18) {
            // Stage 2: up to 1000 Ether, exchange rate of 1 ETH for 4500 BUX
                tokenAllocation = calcpresaleAllocations(weiUsing, 4500);
            } else if (totalReceived < 1500 * 10**18) {
            // Stage 3: up to 1500 Ether, exchange rate of 1 ETH for 4000 BUX
                tokenAllocation = calcpresaleAllocations(weiUsing, 4000);
            } else if (totalReceived < 2000 * 10**18) {
            // Stage 4: up to 2000 Ether, exchange rate of 1 ETH for 3500 BUX
                tokenAllocation = calcpresaleAllocations(weiUsing, 3500);
            } else if (totalReceived < 2500 * 10**18) {
            // Stage 5: up to 2500 Ether, exchange rate of 1 ETH for 3250 BUX
                tokenAllocation = calcpresaleAllocations(weiUsing, 3250);
            } else if (totalReceived < 3000 * 10**18) {
            // Stage 6: up to 3000 Ether, exchange rate of 1 ETH for 3000 BUX
                tokenAllocation = calcpresaleAllocations(weiUsing, 3000);
            } 
            totalTokenAllocation = totalTokenAllocation.add(tokenAllocation);
            totalReceived = totalReceived.add(weiUsing);
            if (totalReceived >= PRESALE_MAX_RAISE) {
                    buyerRefund = weiAmount;
                    endPresale();
            }
            // Exits the for loops if the presale cap has been reached (changing the stage)
            // or all of the wei send to the presale has been allocated
            if (weiAmount == 0 || stage != Stages.PresaleStarted)
                break;
        }
        presaleAllocations[receiver] = presaleAllocations[receiver].add(totalTokenAllocation);
        wallet.transfer(totalReceived.sub(oldTotalReceived));
        msg.sender.transfer(buyerRefund);
        AllocatePresale(receiver, totalTokenAllocation);
    }

    // @dev Allocated tokens to the presale buyer at a rate based on the total received
    // @param receiver The address main sale balehubucks will be allocated to
    function buyMainSale(address receiver)
        private
    {
        if (now >= mainSaleEndTime) {
            endMainSale(msg.value);
            msg.sender.transfer(msg.value);
            return;
        }
        uint256 buyerRefund = 0;
        uint256 weiAllocation = mainSaleAllocations[receiver].add(msg.value);
        if (weiAllocation >= maximumAllocationPerParticipant) {
            weiAllocation = maximumAllocationPerParticipant.sub(mainSaleAllocations[receiver]);
            buyerRefund = msg.value.sub(weiAllocation);
        }
        uint256 potentialReceived = totalReceived.add(weiAllocation);
        if (potentialReceived > maximumMainSaleRaise) {
            weiAllocation = maximumMainSaleRaise.sub(totalReceived);
            buyerRefund = buyerRefund.add(potentialReceived.sub(maximumMainSaleRaise));
            endMainSale(buyerRefund);
        }
        totalReceived = totalReceived.add(weiAllocation);
        mainSaleAllocations[receiver] = mainSaleAllocations[receiver].add(weiAllocation);
        msg.sender.transfer(buyerRefund);
        AllocateMainSale(receiver, weiAllocation);
    }

    // @dev Calculates the amount of presale tokens to allocate
    // @param weiUsing The amount of wei being used to for the given token allocation
    // @param rate The eth/token exchange rate, this changes based on how much the presale has received so far
    function calcpresaleAllocations(uint256 weiUsing, uint256 rate)
        private
        pure
        returns (uint256)
    {
        return weiUsing.mul(rate);
    }

    // @dev Ends the presale
    function endPresale()
        private
    {
        stage = Stages.PresaleEnded;
        PresaleEnd(now);
    }

    // @dev Ends the main sale triggering a refund if the minimum sale raise has no been met 
    // @dev or passes funds raised to the wallet and starts the trading count down
    function endMainSale(uint256 buyerRefund)
        private
    {
        if (totalReceived < minimumMainSaleRaise) {
            stage = Stages.Refund;
        } else {
            minTradingStartTime = now + 2 weeks;
            maxTradingStartTime = now + 8 weeks;
            stage = Stages.MainSaleEnded;
            // Transfers all funds raised to the Balehu wallet minus the funds that need to be refunded
            wallet.transfer(this.balance.sub(buyerRefund));
            // All unsold tokens will remain within the token_sale contract
            // and will be treated as burned
        }
        MainSaleEnd(now);
    }
}