//  Copyright (c) 2017, 2018 EtherJack.io. All rights reserved.
//  This code is disclosed only to be used for inspection and audit purposes.
//  Code modification and use for any purpose other than security audit
//  is prohibited. Creation of derived works or unauthorized deployment
//  of the code or any its portion to a blockchain is prohibited.

pragma solidity ^0.4.19;


contract HouseOwned {
    address house;

    modifier onlyHouse {
        require(msg.sender == house);
        _;
    }

    /// @dev Contract constructor
    function HouseOwned() public {
        house = msg.sender;
    }
}


// SafeMath is a part of Zeppelin Solidity library
// licensed under MIT License
// https://github.com/OpenZeppelin/zeppelin-solidity/blob/master/LICENSE

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        assert(c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // assert(b > 0); // Solidity automatically throws when dividing by 0
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }
}

// ----------------------------------------------------------------------------
// ERC Token Standard #20 Interface
// https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20-token-standard.md
// ----------------------------------------------------------------------------
contract ERC20Interface {
    function totalSupply() public constant returns (uint);
    function balanceOf(address _owner) public constant returns (uint balance);
    function allowance(address _owner, address _spender) public constant returns (uint remaining);
    function transfer(address _to, uint _value) public returns (bool success);
    function approve(address _spender, uint _value) public returns (bool success);
    function transferFrom(address _from, address _to, uint _value) public returns (bool success);

    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed tokenOwner, address indexed spender, uint value);
}

contract Token is HouseOwned, ERC20Interface {
    using SafeMath for uint;

    // Public variables of the token
    string public name;
    string public symbol;
    uint8 public constant decimals = 0;
    uint256 public supply;

    // Trusted addresses
    Jackpot public jackpot;
    address public croupier;

    // All users' balances
    mapping (address => uint256) internal balances;
    // Users' deposits with Croupier
    mapping (address => uint256) public depositOf;
    // Total amount of deposits
    uint256 public totalDeposit;
    // Total amount of "Frozen Deposit Pool" -- the tokens for sale at Croupier
    uint256 public frozenPool;
    // Allowance mapping
    mapping (address => mapping (address => uint256)) internal allowed;

    //////
    /// @title Modifiers
    //

    /// @dev Only Croupier
    modifier onlyCroupier {
        require(msg.sender == croupier);
        _;
    }

    /// @dev Only Jackpot
    modifier onlyJackpot {
        require(msg.sender == address(jackpot));
        _;
    }

    /// @dev Protection from short address attack
    modifier onlyPayloadSize(uint size) {
        assert(msg.data.length == size + 4);
        _;
    }

    //////
    /// @title Events
    //

    /// @dev Fired when a token is burned (bet made)
    event Burn(address indexed from, uint256 value);

    /// @dev Fired when a deposit is made or withdrawn
    ///       direction == 0: deposit
    ///       direction == 1: withdrawal
    event Deposit(address indexed from, uint256 value, uint8 direction, uint256 newDeposit);

    /// @dev Fired when a deposit with Croupier is frozen (set for sale)
    event DepositFrozen(address indexed from, uint256 value);

    /// @dev Fired when a deposit with Croupier is unfrozen (removed from sale)
    //       Value is the resulting deposit, NOT the unfrozen amount
    event DepositUnfrozen(address indexed from, uint256 value);

    //////
    /// @title Constructor and Initialization
    //

    /// @dev Initializes contract with initial supply tokens to the creator of the contract
    function Token() HouseOwned() public {
        name = "JACK Token";
        symbol = "JACK";
        supply = 1000000;
    }

    /// @dev Function to set address of Jackpot contract once after creation
    /// @param _jackpot Address of the Jackpot contract
    function setJackpot(address _jackpot) onlyHouse public {
        require(address(jackpot) == 0x0);
        require(_jackpot != address(this)); // Protection from admin's mistake

        jackpot = Jackpot(_jackpot);

        uint256 bountyPortion = supply / 40;           // 2.5% is the bounty portion for marketing expenses
        balances[house] = bountyPortion;               // House receives the bounty tokens
        balances[jackpot] = supply - bountyPortion;    // Jackpot gets the rest

        croupier = jackpot.croupier();
    }

    //////
    /// @title Public Methods
    //


    /// @dev Croupier invokes this method to return deposits to players
    /// @param _to The address of the recipient
    /// @param _extra Additional off-chain credit (AirDrop support), so that croupier can return more than the user has actually deposited
    function returnDeposit(address _to, uint256 _extra) onlyCroupier public {
        require(depositOf[_to] > 0 || _extra > 0);
        uint256 amount = depositOf[_to];
        depositOf[_to] = 0;
        totalDeposit = totalDeposit.sub(amount);

        _transfer(croupier, _to, amount.add(_extra));

        Deposit(_to, amount, 1, 0);
    }

    /// @dev Gets the balance of the specified address.
    /// @param _owner The address
    function balanceOf(address _owner) public view returns (uint256 balance) {
        return balances[_owner];
    }
    
    function totalSupply() public view returns (uint256) {
        return supply;
    }

    /// @dev Send `_value` tokens to `_to`
    /// @param _to The address of the recipient
    /// @param _value the amount to send
    function transfer(address _to, uint256 _value) onlyPayloadSize(2 * 32) public returns (bool) {
        require(address(jackpot) != 0x0);
        require(croupier != 0x0);

        if (_to == address(jackpot)) {
            // It is a token bet. Ignoring _value, only using 1 token
            _burnFromAccount(msg.sender, 1);
            jackpot.betToken(msg.sender);
            return true;
        }

        if (_to == croupier && msg.sender != house) {
            // It's a deposit to Croupier. In addition to transferring the token,
            // mark it in the deposits table

            // House can't make deposits. If House is transferring something to
            // Croupier, it's just a transfer, nothing more

            depositOf[msg.sender] += _value;
            totalDeposit = totalDeposit.add(_value);

            Deposit(msg.sender, _value, 0, depositOf[msg.sender]);
        }

        // In all cases but Jackpot transfer (which is terminated by a return), actually
        // do perform the transfer
        return _transfer(msg.sender, _to, _value);
    }

    /// @dev Transfer tokens from one address to another
    /// @param _from address The address which you want to send tokens from
    /// @param _to address The address which you want to transfer to
    /// @param _value uint256 the amount of tokens to be transferred
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

    /// @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.
    /// @param _spender The address which will spend the funds.
    /// @param _value The amount of tokens to be spent.
    function approve(address _spender, uint256 _value) public returns (bool) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }

    /// @dev Function to check the amount of tokens that an owner allowed to a spender.
    /// @param _owner address The address which owns the funds.
    /// @param _spender address The address which will spend the funds.
    /// @return A uint256 specifying the amount of tokens still available for the spender.
    function allowance(address _owner, address _spender) public view returns (uint256) {
        return allowed[_owner][_spender];
    }

    /// @dev Increase the amount of tokens that an owner allowed to a spender.
    /// @param _spender The address which will spend the funds.
    /// @param _addedValue The amount of tokens to increase the allowance by.
    function increaseApproval(address _spender, uint _addedValue) public returns (bool) {
        allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
        Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
        return true;
    }

    /// @dev Decrease the amount of tokens that an owner allowed to a spender.
    /// @param _spender The address which will spend the funds.
    /// @param _subtractedValue The amount of tokens to decrease the allowance by.
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

    /// @dev Croupier uses this method to set deposited credits of a player for sale
    /// @param _user The address of the user
    /// @param _extra Additional off-chain credit (AirDrop support), so that croupier could have frozen more than the user had invested
    function freezeDeposit(address _user, uint256 _extra) onlyCroupier public {
        require(depositOf[_user] > 0 || _extra > 0);

        uint256 deposit = depositOf[_user];
        depositOf[_user] = depositOf[_user].sub(deposit);
        totalDeposit = totalDeposit.sub(deposit);

        uint256 depositWithExtra = deposit.add(_extra);

        frozenPool = frozenPool.add(depositWithExtra);

        DepositFrozen(_user, depositWithExtra);
    }

    /// @dev Croupier uses this method stop selling user's tokens and return them to normal deposit
    /// @param _user The user whose deposit is being unfrozen
    /// @param _value The value to unfreeze according to Croupier's records (off-chain sale data)
    function unfreezeDeposit(address _user, uint256 _value) onlyCroupier public {
        require(_value > 0);
        require(frozenPool >= _value);

        depositOf[_user] = depositOf[_user].add(_value);
        totalDeposit = totalDeposit.add(_value);

        frozenPool = frozenPool.sub(_value);

        DepositUnfrozen(_user, depositOf[_user]);
    }

    /// @dev The Jackpot contract invokes this method when selling tokens from Croupier
    /// @param _to The recipient of the tokens
    /// @param _value The amount
    function transferFromCroupier(address _to, uint256 _value) onlyJackpot public {
        require(_value > 0);
        require(frozenPool >= _value);

        frozenPool = frozenPool.sub(_value);

        _transfer(croupier, _to, _value);
    }

    //////
    /// @title Internal Methods
    //

    /// @dev Internal transfer function
    /// @param _from From address
    /// @param _to To address
    /// @param _value The value to transfer
    /// @return success
    function _transfer(address _from, address _to, uint256 _value) internal returns (bool) {
        require(_to != address(0));                         // Prevent transfer to 0x0 address
        require(balances[_from] >= _value);                 // Check if the sender has enough
        balances[_from] = balances[_from].sub(_value);      // Subtract from the sender
        balances[_to] = balances[_to].add(_value);          // Add the same to the recipient
        Transfer(_from, _to, _value);
        return true;
    }

    /// @dev Internal function for burning tokens
    /// @param _sender The token sender (whose tokens are being burned)
    /// @param _value The amount of tokens to burn
    function _burnFromAccount(address _sender, uint256 _value) internal {
        require(balances[_sender] >= _value);               // Check if the sender has enough
        balances[_sender] = balances[_sender].sub(_value);  // Subtract from the sender
        supply = supply.sub(_value);                        // Updates totalSupply
        Burn(_sender, _value);
    }

}

contract Jackpot is HouseOwned {
    using SafeMath for uint;

    enum Stages {
        InitialOffer,   // ICO stage: forming the jackpot fund
        GameOn,         // The game is running
        GameOver,       // The jackpot is won, paying out the jackpot
        Aborted         // ICO aborted, refunding investments
    }

    uint256 constant initialIcoTokenPrice = 4 finney;
    uint256 constant initialBetAmount = 10 finney;
    uint constant gameStartJackpotThreshold = 333 ether;
    uint constant icoTerminationTimeout = 48 hours;

    // These variables hold the values needed for minor prize checking:
    //  - when they were last won (once the number reaches the corresponding amount, the
    //    minor prize is won, and it should be reset)
    //  - how much ether was bet since it was last won
    // `etherSince*` variables start with value of 1 and always have +1 in their value
    // so that the variables never go 0, for gas consumption consistency
    uint32 public totalBets = 0;
    uint256 public etherSince20 = 1;
    uint256 public etherSince50 = 1;
    uint256 public etherSince100 = 1;
    uint256 public pendingEtherForCroupier = 0;

    // ICO status
    uint32 public icoSoldTokens;
    uint256 public icoEndTime;

    // Jackpot status
    address public lastBetUser;
    uint256 public terminationTime;
    address public winner;
    uint256 public pendingJackpotForHouse;
    uint256 public pendingJackpotForWinner;

    // General configuration and stage
    address public croupier;
    Token public token;
    Stages public stage = Stages.InitialOffer;

    // Price state
    uint256 public currentIcoTokenPrice = initialIcoTokenPrice;
    uint256 public currentBetAmount = initialBetAmount;

    // Investment tracking for emergency ICO termination
    mapping (address => uint256) public investmentOf;
    uint256 public abortTime;

    //////
    /// @title Modifiers
    //

    /// @dev Only Token
    modifier onlyToken {
        require(msg.sender == address(token));
        _;
    }

    /// @dev Only Croupier
    modifier onlyCroupier {
        require(msg.sender == address(croupier));
        _;
    }

    //////
    /// @title Events
    //

    /// @dev Fired when tokens are sold for Ether in ICO
    event EtherIco(address indexed from, uint256 value, uint256 tokens);

    /// @dev Fired when a bid with Ether is made
    event EtherBet(address indexed from, uint256 value, uint256 dividends);

    /// @dev Fired when a bid with a Token is made
    event TokenBet(address indexed from);

    /// @dev Fired when a bidder wins a minor prize
    ///      Type: 1: 20, 2: 50, 3: 100
    event MinorPrizePayout(address indexed from, uint256 value, uint8 prizeType);

    /// @dev Fired when as a result of ether bid, tokens are sold from the Croupier's pool
    ///      The parameters are who bought them, how many tokens, and for how much Ether they were sold
    event SoldTokensFromCroupier(address indexed from, uint256 value, uint256 tokens);

    /// @dev Fired when the jackpot is won
    event JackpotWon(address indexed from, uint256 value);


    //////
    /// @title Constructor and Initialization
    //

    /// @dev The contract constructor
    /// @param _croupier The address of the trusted Croupier bot's account
    function Jackpot(address _croupier)
        HouseOwned()
        public
    {
        require(_croupier != 0x0);
        croupier = _croupier;

        // There are no bets (it even starts in ICO stage), so initialize
        // lastBetUser, just so that value is not zero and is meaningful
        // The game can't end until at least one bid is made, and once
        // a bid is made, this value is permanently overwritten.
        lastBetUser = _croupier;
    }

    /// @dev Function to set address of Token contract once after creation
    /// @param _token Address of the Token contract (JACK Token)
    function setToken(address _token) onlyHouse public {
        require(address(token) == 0x0);
        require(_token != address(this)); // Protection from admin's mistake

        token = Token(_token);
    }


    //////
    /// @title Default Function
    //

    /// @dev The fallback function for receiving ether (bets)
    ///      Action depends on stages:
    ///       - ICO: just sell the tokens
    ///       - Game: accept bets, award tokens, award minor (20, 50, 100) prizes
    ///       - Game Over: pay out jackpot
    ///       - Aborted: fail
    function() payable public {
        require(croupier != 0x0);
        require(address(token) != 0x0);
        require(stage != Stages.Aborted);

        uint256 tokens;

        if (stage == Stages.InitialOffer) {

            // First, check if the ICO is over. If it is, trigger the events and
            // refund sent ether
            bool started = checkGameStart();
            if (started) {
                // Refund ether without failing the transaction
                // (because side-effect is needed)
                msg.sender.transfer(msg.value);
                return;
            }

            require(msg.value >= currentIcoTokenPrice);
        
            // THE PLAN
            // 1. [CHECK + EFFECT] Calculate how much times price, the investment amount is,
            //    calculate how many tokens the investor is going to get
            // 2. [EFFECT] Log and count
            // 3. [EFFECT] Check game start conditions and maybe start the game
            // 4. [INT] Award the tokens
            // 5. [INT] Transfer 20% to house

            // 1. [CHECK + EFFECT] Checking the amount
            tokens = _icoTokensForEther(msg.value);

            // 2. [EFFECT] Log
            // Log the ICO event and count investment
            EtherIco(msg.sender, msg.value, tokens);

            investmentOf[msg.sender] = investmentOf[msg.sender].add(
                msg.value.sub(msg.value / 5)
            );

            // 3. [EFFECT] Game start
            // Check if we have accumulated the jackpot amount required for game start
            if (icoEndTime == 0 && this.balance >= gameStartJackpotThreshold) {
                icoEndTime = now + icoTerminationTimeout;
            }

            // 4. [INT] Awarding tokens
            // Award the deserved tokens (if any)
            if (tokens > 0) {
                token.transfer(msg.sender, tokens);
            }

            // 5. [INT] House
            // House gets 20% of ICO according to the rules
            house.transfer(msg.value / 5);

        } else if (stage == Stages.GameOn) {

            // First, check if the game is over. If it is, trigger the events and
            // refund sent ether
            bool terminated = checkTermination();
            if (terminated) {
                // Refund ether without failing the transaction
                // (because side-effect is needed)
                msg.sender.transfer(msg.value);
                return;
            }

            // Now processing an Ether bid
            require(msg.value >= currentBetAmount);

            // THE PLAN
            // 1. [CHECK] Calculate how much times min-bet, the bet amount is,
            //    calculate how many tokens the player is going to get
            // 2. [CHECK] Check how much is sold from the Croupier's pool, and how much from Jackpot
            // 3. [EFFECT] Deposit 25% to the Croupier (for dividends and house's benefit)
            // 4. [EFFECT] Log and mark bid
            // 6. [INT] Check and reward (if won) minor (20, 100, 1000) prizes
            // 7. [EFFECT] Update bet amount
            // 8. [INT] Award the tokens


            // 1. [CHECK + EFFECT] Checking the bet amount and token reward
            tokens = _betTokensForEther(msg.value);

            // 2. [CHECK] Check how much is sold from the Croupier's pool, and how much from Jackpot
            //    The priority is (1) Croupier, (2) Jackpot
            uint256 sellingFromJackpot = 0;
            uint256 sellingFromCroupier = 0;
            if (tokens > 0) {
                uint256 croupierPool = token.frozenPool();
                uint256 jackpotPool = token.balanceOf(this);

                if (croupierPool == 0) {
                    // Simple case: only Jackpot is selling
                    sellingFromJackpot = tokens;
                    if (sellingFromJackpot > jackpotPool) {
                        sellingFromJackpot = jackpotPool;
                    }
                } else if (jackpotPool == 0 || tokens <= croupierPool) {
                    // Simple case: only Croupier is selling
                    // either because Jackpot has 0, or because Croupier takes over
                    // by priority and has enough tokens in its pool
                    sellingFromCroupier = tokens;
                    if (sellingFromCroupier > croupierPool) {
                        sellingFromCroupier = croupierPool;
                    }
                } else {
                    // Complex case: both are selling now
                    sellingFromCroupier = croupierPool;  // (tokens > croupierPool) is guaranteed at this point
                    sellingFromJackpot = tokens.sub(sellingFromCroupier);
                    if (sellingFromJackpot > jackpotPool) {
                        sellingFromJackpot = jackpotPool;
                    }
                }
            }

            // 3. [EFFECT] Croupier deposit
            // Transfer a portion to the Croupier for dividend payout and house benefit
            // Dividends are a sum of:
            //   + 25% of bet
            //   + 50% of price of tokens sold from Jackpot (or just anything other than the bet and Croupier payment)
            //   + 0%  of price of tokens sold from Croupier
            //          (that goes in SoldTokensFromCroupier instead)
            uint256 tokenValue = msg.value.sub(currentBetAmount);

            uint256 croupierSaleRevenue = 0;
            if (sellingFromCroupier > 0) {
                croupierSaleRevenue = tokenValue.div(
                    sellingFromJackpot.add(sellingFromCroupier)
                ).mul(sellingFromCroupier);
            }
            uint256 jackpotSaleRevenue = tokenValue.sub(croupierSaleRevenue);

            uint256 dividends = (currentBetAmount.div(4)).add(jackpotSaleRevenue.div(2));

            // 100% of money for selling from Croupier still goes to Croupier
            // so that it's later paid out to the selling user
            pendingEtherForCroupier = pendingEtherForCroupier.add(dividends.add(croupierSaleRevenue));

            // 4. [EFFECT] Log and mark bid
            // Log the bet with actual amount charged (value less change)
            EtherBet(msg.sender, msg.value, dividends);
            lastBetUser = msg.sender;
            terminationTime = now + _terminationDuration();

            // If anything was sold from Croupier, log it appropriately
            if (croupierSaleRevenue > 0) {
                SoldTokensFromCroupier(msg.sender, croupierSaleRevenue, sellingFromCroupier);
            }

            // 5. [INT] Minor prizes
            // Check for winning minor prizes
            _checkMinorPrizes(msg.sender, currentBetAmount);

            // 6. [EFFECT] Update bet amount
            _updateBetAmount();

            // 7. [INT] Awarding tokens
            if (sellingFromJackpot > 0) {
                token.transfer(msg.sender, sellingFromJackpot);
            }
            if (sellingFromCroupier > 0) {
                token.transferFromCroupier(msg.sender, sellingFromCroupier);
            }

        } else if (stage == Stages.GameOver) {

            require(msg.sender == winner || msg.sender == house);

            if (msg.sender == winner) {
                require(pendingJackpotForWinner > 0);

                uint256 winnersPay = pendingJackpotForWinner;
                pendingJackpotForWinner = 0;

                msg.sender.transfer(winnersPay);
            } else if (msg.sender == house) {
                require(pendingJackpotForHouse > 0);

                uint256 housePay = pendingJackpotForHouse;
                pendingJackpotForHouse = 0;

                msg.sender.transfer(housePay);
            }
        }
    }

    // Croupier will call this function when the jackpot is won
    // If Croupier fails to call the function for any reason, house and winner
    // still can claim their jackpot portion by sending ether to Jackpot
    function payOutJackpot() onlyCroupier public {
        require(winner != 0x0);
    
        if (pendingJackpotForHouse > 0) {
            uint256 housePay = pendingJackpotForHouse;
            pendingJackpotForHouse = 0;

            house.transfer(housePay);
        }

        if (pendingJackpotForWinner > 0) {
            uint256 winnersPay = pendingJackpotForWinner;
            pendingJackpotForWinner = 0;

            winner.transfer(winnersPay);
        }

    }

    //////
    /// @title Public Functions
    //

    /// @dev View function to check whether the game should be terminated
    ///      Used as internal function by checkTermination, as well as by the
    ///      Croupier bot, to check whether it should call checkTermination
    /// @return Whether the game should be terminated by timeout
    function shouldBeTerminated() public view returns (bool should) {
        return stage == Stages.GameOn && terminationTime != 0 && now > terminationTime;
    }

    /// @dev Check whether the game should be terminated, and if it should, terminate it
    /// @return Whether the game was terminated as the result
    function checkTermination() public returns (bool terminated) {
        if (shouldBeTerminated()) {
            stage = Stages.GameOver;

            winner = lastBetUser;

            // Flush amount due for Croupier immediately
            _flushEtherToCroupier();

            // The rest should be claimed by the winner (except what house gets)
            JackpotWon(winner, this.balance);


            uint256 jackpot = this.balance;
            pendingJackpotForHouse = jackpot.div(5);
            pendingJackpotForWinner = jackpot.sub(pendingJackpotForHouse);

            return true;
        }

        return false;
    }

    /// @dev View function to check whether the game should be started
    ///      Used as internal function by `checkGameStart`, as well as by the
    ///      Croupier bot, to check whether it should call `checkGameStart`
    /// @return Whether the game should be started
    function shouldBeStarted() public view returns (bool should) {
        return stage == Stages.InitialOffer && icoEndTime != 0 && now > icoEndTime;
    }

    /// @dev Check whether the game should be started, and if it should, start it
    /// @return Whether the game was started as the result
    function checkGameStart() public returns (bool started) {
        if (shouldBeStarted()) {
            stage = Stages.GameOn;

            return true;
        }

        return false;
    }

    /// @dev Bet 1 token in the game
    ///      The token has already been burned having passed all checks, so
    ///      just process the bet of 1 token
    function betToken(address _user) onlyToken public {
        // Token bets can only be accepted in the game stage
        require(stage == Stages.GameOn);

        bool terminated = checkTermination();
        if (terminated) {
            return;
        }

        TokenBet(_user);
        lastBetUser = _user;
        terminationTime = now + _terminationDuration();

        // Check for winning minor prizes
        _checkMinorPrizes(_user, 0);
    }

    /// @dev Allows House to terminate ICO as an emergency measure
    function abort() onlyHouse public {
        require(stage == Stages.InitialOffer);

        stage = Stages.Aborted;
        abortTime = now;
    }

    /// @dev In case the ICO is emergency-terminated by House, allows investors
    ///      to pull back the investments
    function claimRefund() public {
        require(stage == Stages.Aborted);
        require(investmentOf[msg.sender] > 0);

        uint256 payment = investmentOf[msg.sender];
        investmentOf[msg.sender] = 0;

        msg.sender.transfer(payment);
    }

    /// @dev In case the ICO was terminated, allows House to kill the contract in 2 months
    ///      after the termination date
    function killAborted() onlyHouse public {
        require(stage == Stages.Aborted);
        require(now > abortTime + 60 days);

        selfdestruct(house);
    }



    //////
    /// @title Internal Functions
    //

    /// @dev Get current bid timer duration
    /// @return duration The duration
    function _terminationDuration() internal view returns (uint256 duration) {
        return (5 + 19200 / (100 + totalBets)) * 1 minutes;
    }

    /// @dev Updates the current ICO price according to the rules
    function _updateIcoPrice() internal {
        uint256 newIcoTokenPrice = currentIcoTokenPrice;

        if (icoSoldTokens < 10000) {
            newIcoTokenPrice = 4 finney;
        } else if (icoSoldTokens < 20000) {
            newIcoTokenPrice = 5 finney;
        } else if (icoSoldTokens < 30000) {
            newIcoTokenPrice = 5.3 finney;
        } else if (icoSoldTokens < 40000) {
            newIcoTokenPrice = 5.7 finney;
        } else {
            newIcoTokenPrice = 6 finney;
        }

        if (newIcoTokenPrice != currentIcoTokenPrice) {
            currentIcoTokenPrice = newIcoTokenPrice;
        }
    }

    /// @dev Updates the current bid price according to the rules
    function _updateBetAmount() internal {
        uint256 newBetAmount = 10 finney + (totalBets / 100) * 6 finney;

        if (newBetAmount != currentBetAmount) {
            currentBetAmount = newBetAmount;
        }
    }

    /// @dev Calculates how many tokens a user should get with a given Ether bid
    /// @param value The bid amount
    /// @return tokens The number of tokens
    function _betTokensForEther(uint256 value) internal view returns (uint256 tokens) {
        // One bet amount is for the bet itself, for the rest we will sell
        // tokens
        tokens = (value / currentBetAmount) - 1;

        if (tokens >= 1000) {
            tokens = tokens + tokens / 4; // +25%
        } else if (tokens >= 300) {
            tokens = tokens + tokens / 5; // +20%
        } else if (tokens >= 100) {
            tokens = tokens + tokens / 7; // ~ +14.3%
        } else if (tokens >= 50) {
            tokens = tokens + tokens / 10; // +10%
        } else if (tokens >= 20) {
            tokens = tokens + tokens / 20; // +5%
        }
    }

    /// @dev Calculates how many tokens a user should get with a given ICO transfer
    /// @param value The transfer amount
    /// @return tokens The number of tokens
    function _icoTokensForEther(uint256 value) internal returns (uint256 tokens) {
        // How many times the input is greater than current token price
        tokens = value / currentIcoTokenPrice;

        if (tokens >= 10000) {
            tokens = tokens + tokens / 4; // +25%
        } else if (tokens >= 5000) {
            tokens = tokens + tokens / 5; // +20%
        } else if (tokens >= 1000) {
            tokens = tokens + tokens / 7; // ~ +14.3%
        } else if (tokens >= 500) {
            tokens = tokens + tokens / 10; // +10%
        } else if (tokens >= 200) {
            tokens = tokens + tokens / 20; // +5%
        }

        // Checking if Jackpot has the tokens in reserve
        if (tokens > token.balanceOf(this)) {
            tokens = token.balanceOf(this);
        }

        icoSoldTokens += (uint32)(tokens);

        _updateIcoPrice();
    }

    /// @dev Flush the currently pending Ether to Croupier
    function _flushEtherToCroupier() internal {
        if (pendingEtherForCroupier > 0) {
            uint256 willTransfer = pendingEtherForCroupier;
            pendingEtherForCroupier = 0;
            
            croupier.transfer(willTransfer);
        }
    }

    /// @dev Count the bid towards minor prize fund, check if the user
    ///      wins a minor prize, and if they did, transfer the prize to them
    /// @param user The user in question
    /// @param value The bid value
    function _checkMinorPrizes(address user, uint256 value) internal {
        // First and foremost, increment the counters and ether counters
        totalBets ++;
        if (value > 0) {
            etherSince20 = etherSince20.add(value);
            etherSince50 = etherSince50.add(value);
            etherSince100 = etherSince100.add(value);
        }

        // Now actually check if the bets won

        uint256 etherPayout;

        if ((totalBets + 30) % 100 == 0) {
            // Won 100th
            etherPayout = (etherSince100 - 1) / 10;
            etherSince100 = 1;

            MinorPrizePayout(user, etherPayout, 3);

            user.transfer(etherPayout);
            return;
        }

        if ((totalBets + 5) % 50 == 0) {
            // Won 100th
            etherPayout = (etherSince50 - 1) / 10;
            etherSince50 = 1;

            MinorPrizePayout(user, etherPayout, 2);

            user.transfer(etherPayout);
            return;
        }

        if (totalBets % 20 == 0) {
            // Won 20th
            etherPayout = (etherSince20 - 1) / 10;
            etherSince20 = 1;

            _flushEtherToCroupier();

            MinorPrizePayout(user, etherPayout, 1);

            user.transfer(etherPayout);
            return;
        }

        return;
    }

}