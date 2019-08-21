pragma solidity ^0.4.23;

/**
 *   _____  ___    ___   _____      _              
 *   \_   \/ __\  / __\ /__   \___ | | _____ _ __  
 *    / /\/__\// / /      / /\/ _ \| |/ / _ \ '_ \ 
 * /\/ /_/ \/  \/ /___   / / | (_) |   <  __/ | | |
 * \____/\_____/\____/   \/   \___/|_|\_\___|_| |_|
 * 
 * Token Address: 0xDEcF3A00E37BAdA548EC438dcef99B43D7F9F67d
 */
contract Token {
    string public symbol = "";
    string public name = "";
    uint8 public constant decimals = 18;
    uint256 _totalSupply = 0;
    address owner = 0;
    bool setupDone = false;
   
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
 
    mapping(address => uint256) balances;
 
    mapping(address => mapping (address => uint256)) allowed;
    function SetupToken(string tokenName, string tokenSymbol, uint256 tokenSupply);
    function totalSupply() constant returns (uint256 totalSupply);
    function balanceOf(address _owner) constant returns (uint256 balance);
    function transfer(address _to, uint256 _amount) returns (bool success);
    function transferFrom(address _from, address _to, uint256 _amount) returns (bool success);
    function approve(address _spender, uint256 _amount) returns (bool success);
    function allowance(address _owner, address _spender) constant returns (uint256 remaining);
}

/**
 *   _____  ___    ___     __       _   _                  
 *   \_   \/ __\  / __\   / /  ___ | |_| |_ ___ _ __ _   _ 
 *    / /\/__\// / /     / /  / _ \| __| __/ _ \ '__| | | |
 * /\/ /_/ \/  \/ /___  / /__| (_) | |_| ||  __/ |  | |_| |
 * \____/\_____/\____/  \____/\___/ \__|\__\___|_|   \__, |
 *                                                   |___/ 
 */

contract IBCLottery
{
    uint256 private ticketPrice_;
    
    // (user => Tikcet)
    mapping(address => Ticket) internal ticketRecord_;
    
    Token public ibcToken_;
    
    address public officialWallet_;
    address public devATeamWallet_;
    address public devBTeamWallet_;
    
    // round => tokenRaised
    uint256 public tokenRaised_;
    uint256 public actualTokenRaised_;
    mapping(address => uint256) public userPaidIn_;
    
    // On mainnet:
    // ibc coin: 0xdecf3a00e37bada548ec438dcef99b43d7f9f67d
    // official wallet: 0xe49c794d9eb5cE8E72C52Ab4dc7ccB233AA7Eb7C
    // devA team wallet: 0xB034209C57134625CD95f8843e504bD0fA8664E5
    // devB team wallet: 0x2ECBD107C3D3AdC43EeF22EE07b0401DF11E9472
    constructor(
        address _ibcoin,
        address _officialWallet,
        address _devATeamWallet,
        address _devBTeamWallet
    )
        public
    {
        ibcToken_ = Token(_ibcoin);
        officialWallet_ = _officialWallet;
        devATeamWallet_ = _devATeamWallet;
        devBTeamWallet_ = _devBTeamWallet;
    }
    
    /**
     *    __                 _       
     *   /__\_   _____ _ __ | |_ ___ 
     *  /_\ \ \ / / _ \ '_ \| __/ __|
     * //__  \ V /  __/ | | | |_\__ \
     * \__/   \_/ \___|_| |_|\__|___/                       
     */
     
    event BuyTicket(
        address indexed buyer,
        uint256 price
    );
     
     /**
     *                   _ _  __ _           
     *   /\/\   ___   __| (_)/ _(_) ___ _ __ 
     *  /    \ / _ \ / _` | | |_| |/ _ \ '__|
     * / /\/\ \ (_) | (_| | |  _| |  __/ |   
     * \/    \/\___/ \__,_|_|_| |_|\___|_|                                  
     */
     
    modifier onlyBoughtTicket(
        address _user,
        uint256 _timeLeft
    )
    {
        require(hasValidTicketCore(_user, _timeLeft), "You don't have ticket yet!");
        _;
    }
    
    /**
     *    ___       _     _ _          ___                 _   _                 
     *   / _ \_   _| |__ | (_) ___    / __\   _ _ __   ___| |_(_) ___  _ __  ___ 
     *  / /_)/ | | | '_ \| | |/ __|  / _\| | | | '_ \ / __| __| |/ _ \| '_ \/ __|
     * / ___/| |_| | |_) | | | (__  / /  | |_| | | | | (__| |_| | (_) | | | \__ \
     * \/     \__,_|_.__/|_|_|\___| \/    \__,_|_| |_|\___|\__|_|\___/|_| |_|___/
     */
    
    function buyTicketCore(
        uint256 _pot,
        uint256 _timeLeft,
        address _user
    )
        internal
        returns
        (bool)
    {
        if(!hasValidTicketCore(_user, _timeLeft)) {
            if (_timeLeft == 0) return false;
            // local allowance variable
            uint256 _allowance = ibcToken_.allowance(_user, this);
            
            // check if allowance to this contract.
            require(_allowance > 0, "Please approve token to this contract.");
            
            // how much IBC user should pay for ticket.
            uint256 _ticketPrice = calculateTicketPrice(_pot, _timeLeft);
            
            // check if the allowance enough to pay the ticket.
            require(_allowance >= _ticketPrice, "Insufficient allowance for this contract.");
            
            // transfer from token from user wallet to this contract.
            require(ibcToken_.transferFrom(_user, this, _ticketPrice));
            
            // increase tocket raise for each round.
            tokenRaised_ = tokenRaised_ + _ticketPrice;
            
            // assign ticket to user.
            ticketRecord_[_user].hasTicket = true;
            ticketRecord_[_user].expirationTime = now + 30 minutes;
            ticketRecord_[_user].ticketPrice = _ticketPrice;
            
            emit BuyTicket(_user, _ticketPrice);
        }
        return true;
    }
    
    function hasValidTicketCore(
        address _user,
        uint256 _timeLeft
    )
        view
        internal
        returns
        (bool)
    {
        if (_timeLeft == 0) return false;
        bool _hasTicket = ticketRecord_[_user].hasTicket;
        uint256 _expirationTime = ticketRecord_[_user].expirationTime;
        
        return (_hasTicket && now <= _expirationTime);
    }
    
    function calculateTicketPrice(
        uint256 _pot,
        uint256 _timeLeft
    ) 
        pure
        internal
        returns
        (uint256)
    {
        uint256 _potFixed = _pot / 1000000000000000000;
        
        // calculate Left time
        uint256 _leftHour = _timeLeft / 3600;
        
        // left hours over and equal 24 hours
        // pot equal to 0
        // this means initial status of the game,
        // no need to calculate, return 1 IBC (10**18 wei)
        if (_leftHour >= 24) return 1000000000000000000;
        
        // what the fuck is this condition XDDD
        // when 10**8 ETH in pot, return 10**7 IBC
        // it is impossible,
        // total ETH supply only about 10**8 ETH,
        if (_pot >= 100000000000000000000000000) 
            return 10000000000000000000000000;
        
        /** 
         * 1        -> 99       ETH in pot => 1        IBC (< 100)
         * 100      -> 999      ETH in pot => 10      IBC (< 1000)
         * 1000     -> 9999     ETH in pot => 100     IBC (< 10000)
         * 10000    -> 99999    ETH in pot => 1000    IBC (< 100000)
         * 100000   -> 999999   ETH in pot => 10000   IBC (< 1000000)
         * 1000000  -> 9999999  ETH in pot => 100000  IBC (< 10000000)
         * 10000000 -> 99999999 ETH in pot => 1000000 IBC (< 100000000)
         * Why? 
         * Total supply will be reached 120 million,
         * the pot only 20% will be in pot.
         * 
         * Time left:
         * 0  -> 2  hours left, ticket price * 8.
         * 3  -> 5  hours left, ticket price * 7.
         * 6  -> 8  hours left, ticket price * 6.
         * 9  -> 11 hours left, ticket price * 5.
         * 12 -> 14 hours left, ticket price * 4.
         * 15 -> 17 hours left, ticket price * 3.
         * 18 -> 20 hours left, ticket price * 2.
         * 21 -> 23 hours left, ticket price * 1.
         * */
    
        uint256 _gap = 100;
        for(uint8 _step = 0; _step < 7; _gap = _gap * 10) {
            if (_potFixed < _gap) {
                return (_gap / 100) * (8 - (_leftHour / 3)) * 1000000000000000000;
            }    
        }
    }
    
    function getTokenRaised()
        view
        public
        returns
        (uint256, uint256)
    {
        // team funding:
        // (tokenRaised_[_round] - (actualTokenRaised_ / 4))
        // 25% token refund to user.
        return (
            tokenRaised_, 
            actualTokenRaised_
        );
    }
    
    function getUserPaidIn(
        address _address
    )
        view
        public
        returns
        (uint256)
    {
        return userPaidIn_[_address];
    }
    
    struct Ticket {
        bool hasTicket;
        uint256 expirationTime;
        uint256 ticketPrice;
    }
}

/**
 *     ___ _____   ___  __                 _       
 *    / __\___ /  /   \/__\_   _____ _ __ | |_ ___ 
 *   / _\   |_ \ / /\ /_\ \ \ / / _ \ '_ \| __/ __|
 *  / /    ___) / /_///__  \ V /  __/ | | | |_\__ \
 *  \/    |____/___,'\__/   \_/ \___|_| |_|\__|___/
 * */
contract IBCLotteryEvents {
    
    // fired at end of buy or reload
    event onEndTx
    (
        address playerAddress,
        uint256 ethIn,
        uint256 keysBought,
        address winnerAddr,
        uint256 amountWon,
        uint256 newPot,
        uint256 genAmount,
        uint256 potAmount
    );
    
	// fired whenever theres a withdraw
    event onWithdraw
    (
        uint256 indexed playerID,
        address playerAddress,
        uint256 ethOut,
        uint256 timeStamp
    );
    
    // fired whenever a withdraw forces end round to be ran
    event onWithdrawAndDistribute
    (
        address playerAddress,
        uint256 ethOut,
        address winnerAddr,
        uint256 amountWon,
        uint256 newPot,
        uint256 genAmount
    );
    
    // hit zero, and causes end round to be ran.
    event onBuyAndDistribute
    (
        address playerAddress,
        uint256 ethIn,
        address winnerAddr,
        uint256 amountWon,
        uint256 newPot,
        uint256 genAmount
    );
    
    event onBuyTicketAndDistribute
    (
        address playerAddress,
        address winnerAddr,
        uint256 amountWon,
        uint256 newPot,
        uint256 genAmount
    );
    
    // hit zero, and causes end round to be ran.
    event onReLoadAndDistribute
    (
        address playerAddress,
        address winnerAddr,
        uint256 amountWon,
        uint256 newPot,
        uint256 genAmount
    );
    
    // fired whenever an affiliate is paid
    event onAffiliatePayout
    (
        uint256 indexed affiliateID,
        address affiliateAddress,
        uint256 indexed buyerID,
        uint256 amount,
        uint256 timeStamp
    );
    
    event onRefundTicket
    (
        uint256 indexed playerID,
        uint256 refundAmount
    );
}

/**
 *      ___            _                  _       
 *     / __\___  _ __ | |_ _ __ __ _  ___| |_ ___ 
 *    / /  / _ \| '_ \| __| '__/ _` |/ __| __/ __|
 *   / /__| (_) | | | | |_| | | (_| | (__| |_\__ \
 *   \____/\___/|_| |_|\__|_|  \__,_|\___|\__|___/
 * */

contract IBCLotteryGame is IBCLotteryEvents, IBCLottery {
    using SafeMath for *;
    using IBCLotteryKeysCalcLong for uint256;
	
    /**
     *    ___                       __      _   _   _                 
     *   / _ \__ _ _ __ ___   ___  / _\ ___| |_| |_(_)_ __   __ _ ___ 
     *  / /_\/ _` | '_ ` _ \ / _ \ \ \ / _ \ __| __| | '_ \ / _` / __|
     * / /_\\ (_| | | | | | |  __/ _\ \  __/ |_| |_| | | | | (_| \__ \
     * \____/\__,_|_| |_| |_|\___| \__/\___|\__|\__|_|_| |_|\__, |___/
     *                                                      |___/     
     * */
    
	// round timer starts at this
    // start at 24 hours
    // this value used at: 
    //   - endRound() function
    //   - activate() function
    uint256 private rndInit_ = 24 hours;
    // The timer will be added after the whole key purchased.
    // this value used at: 
    //   - updateTimer() function
    uint256 private rndInc_ = 1 minutes;
    // Max length a round timer can be
    // this value used at:
    //   - updateTimer() function
    uint256 private rndMax_ = 24 hours;
    
    // Auto Increment ID
    // Inspired by MYSAL AUTO INCREMENT PRIMARY KEY.
    uint256 private maxUserId_ = 0;
    
    address private owner_;

    /**
     *    ___                          ___      _        
     *   / _ \__ _ _ __ ___   ___     /   \__ _| |_ __ _ 
     *  / /_\/ _` | '_ ` _ \ / _ \   / /\ / _` | __/ _` |
     * / /_\\ (_| | | | | | |  __/  / /_// (_| | || (_| |
     * \____/\__,_|_| |_| |_|\___| /___,' \__,_|\__\__,_|
     * */
	uint256 public rID_;    // round id number / total rounds that have happened

    /**
     *    ___ _                            ___      _        
     *   / _ \ | __ _ _   _  ___ _ __     /   \__ _| |_ __ _ 
     *  / /_)/ |/ _` | | | |/ _ \ '__|   / /\ / _` | __/ _` |
     * / ___/| | (_| | |_| |  __/ |     / /_// (_| | || (_| |
     * \/    |_|\__,_|\__, |\___|_|    /___,' \__,_|\__\__,_|
     *                |___/                                  
     * */
    mapping (address => uint256) public pIDxAddr_;          // (addr => pID) returns player id by address
    mapping (uint256 => IBCLotteryDatasets.Player) public plyr_;   // (pID => data) player data
    mapping (uint256 => IBCLotteryDatasets.PlayerRounds) public plyrRnds_;    // (pID => rID => data) player round data by player id & round id

    /**
     *    __                       _      ___      _        
     *   /__\ ___  _   _ _ __   __| |    /   \__ _| |_ __ _ 
     *  / \/// _ \| | | | '_ \ / _` |   / /\ / _` | __/ _` |
     * / _  \ (_) | |_| | | | | (_| |  / /_// (_| | || (_| |
     * \/ \_/\___/ \__,_|_| |_|\__,_| /___,' \__,_|\__\__,_|
     * */
    IBCLotteryDatasets.Round round_;   // (rID => data) round data

    /**
     *     ___                _                   _             
     *    / __\___  _ __  ___| |_ _ __ _   _  ___| |_ ___  _ __ 
     *   / /  / _ \| '_ \/ __| __| '__| | | |/ __| __/ _ \| '__|
     *  / /__| (_) | | | \__ \ |_| |  | |_| | (__| || (_) | |   
     *  \____/\___/|_| |_|___/\__|_|   \__,_|\___|\__\___/|_|   
     * */
    constructor(
        address _ibcoin,
        address _officialWallet,
        address _devATeamWallet,
        address _devBTeamWallet
    )
        IBCLottery(_ibcoin, _officialWallet, _devATeamWallet, _devBTeamWallet)
        public
    {
        owner_ = msg.sender;
	}
    /**
                         _ _  __ _               
     *   /\/\   ___   __| (_)/ _(_) ___ _ __ ___ 
     *  /    \ / _ \ / _` | | |_| |/ _ \ '__/ __|
     * / /\/\ \ (_) | (_| | |  _| |  __/ |  \__ \
     * \/    \/\___/ \__,_|_|_| |_|\___|_|  |___/
     */
    /**
     * @dev used to make sure no one can interact with contract until it has 
     * been activated. 
     */
    modifier isActivated() {
        require(activated_ == true, "Be patient!!!"); 
        _;
    }
    /**
     * @dev prevents contracts from interacting this contract
     */
    modifier isHuman() {
        address _addr = msg.sender;
        uint256 _codeLength;
        
        assembly {_codeLength := extcodesize(_addr)}
        require(_codeLength == 0, "sorry humans only");
        _;
    }
    
    modifier onlyInRound() {
        require(!round_.ended, "The game has ended");
        _;
    }

    /**
     * @dev sets boundaries for incoming tx 
     */
    modifier isWithinLimits(uint256 _eth) {
        require(_eth >= 1000000000, "pocket lint: not a valid currency");
        require(_eth <= 100000000000000000000000, "no vitalik, no");
        _;    
    }
    
    modifier onlyOwner(
        address _address
    ) {
        require(_address == owner_, "You are not owner!!!!");
        _;
    }
    
    /**
     *    ___       _     _ _          ___                 _   _                 
     *   / _ \_   _| |__ | (_) ___    / __\   _ _ __   ___| |_(_) ___  _ __  ___ 
     *  / /_)/ | | | '_ \| | |/ __|  / _\| | | | '_ \ / __| __| |/ _ \| '_ \/ __|
     * / ___/| |_| | |_) | | | (__  / /  | |_| | | | | (__| |_| | (_) | | | \__ \
     * \/     \__,_|_.__/|_|_|\___| \/    \__,_|_| |_|\___|\__|_|\___/|_| |_|___/
     * */
    /**
     * @dev emergency buy uses last stored affiliate ID and team snek
     */
    function()
        isActivated()
        onlyInRound()
        isHuman()
        isWithinLimits(msg.value)
        onlyBoughtTicket(msg.sender, getTimeLeft())
        public
        payable
    {
        // set up our tx event data and determine if player is new or not
        IBCLotteryDatasets.EventReturns memory _eventData_ = determinePID(_eventData_);
        
        // fetch player id
        uint256 _pID = pIDxAddr_[msg.sender];
        
        uint256 _affID = plyr_[_pID].laff;
        
        core(_pID, msg.value, _affID, _eventData_);
    }
    
    /**
     * @dev converts all incoming ethereum to keys.
     * -functionhash- 0x8f38f309 (using ID for affiliate)
     * -functionhash- 0x98a0871d (using address for affiliate)
     * @param _affCode the ID/address/name of the player who gets the affiliate fee
     */
    
    function buyXaddr(address _affCode)
        isActivated()
        onlyInRound()
        isHuman()
        isWithinLimits(msg.value)
        onlyBoughtTicket(msg.sender, getTimeLeft())
        public
        payable
    {
        // set up our tx event data and determine if player is new or not
        IBCLotteryDatasets.EventReturns memory _eventData_ = determinePID(_eventData_);
        
        // fetch player id
        uint256 _pID = pIDxAddr_[msg.sender];

        // manage affiliate residuals
        uint256 _affID = pIDxAddr_[_affCode];
        // if no affiliate code was given or player tried to use their own, lolz
        if (_affCode == address(0) 
            || _affCode == msg.sender 
            || plyrRnds_[_affID].keys < 1000000000000000000)
        {
            // use last stored affiliate code
            _affID = plyr_[_pID].laff;
        
        // if affiliate code was given    
        } else {
            // get affiliate ID from aff Code 
            _affID = pIDxAddr_[_affCode];
            
            // if affID is not the same as previously stored 
            if (_affID != plyr_[_pID].laff)
            {
                // update last affiliate
                plyr_[_pID].laff = _affID;
            }
        }
        
        core(_pID, msg.value, _affID, _eventData_);
    }
    
    function buyTicket()
        onlyInRound()
        public
        returns
        (bool)
    {
        uint256 _now = now;
        if (_now > round_.end && round_.ended == false && round_.plyr != 0) 
        {
            IBCLotteryDatasets.EventReturns memory _eventData_;
            
            // end the round (distributes pot) & start new round
		    round_.ended = true;
            _eventData_ = endRound(_eventData_);
            
            // fire buy and distribute event 
            emit IBCLotteryEvents.onBuyTicketAndDistribute
            (
                msg.sender, 
                _eventData_.winnerAddr, 
                _eventData_.amountWon, 
                _eventData_.newPot, 
                _eventData_.genAmount
            );
        } else {
            uint256 _pot = round_.pot;
            uint256 _timeLeft = getTimeLeft();
            return buyTicketCore(_pot, _timeLeft, msg.sender);
        }
    }

    /**
     * @dev withdraws all of your earnings.
     * -functionhash- 0x3ccfd60b
     */
    function withdraw()
        isActivated()
        isHuman()
        public
    {
        // grab time
        uint256 _now = now;
        
        // fetch player ID
        uint256 _pID = pIDxAddr_[msg.sender];
        
        // setup temp var for player eth
        uint256 _eth;
        
        // check to see if round has ended and no one has run round end yet
        if (_now > round_.end && round_.ended == false && round_.plyr != 0)
        {
            // set up our tx event data
            IBCLotteryDatasets.EventReturns memory _eventData_;
            
            // end the round (distributes pot)
			round_.ended = true;
            _eventData_ = endRound(_eventData_);
            
			// get their earnings
            _eth = withdrawEarnings(_pID);
            
            // gib moni
            if (_eth > 0)
                plyr_[_pID].addr.transfer(_eth);    
            
            // fire withdraw and distribute event
            emit IBCLotteryEvents.onWithdrawAndDistribute
            (
                msg.sender, 
                _eth, 
                _eventData_.winnerAddr, 
                _eventData_.amountWon, 
                _eventData_.newPot, 
                _eventData_.genAmount
            );
            
        // in any other situation
        } else {
            // get their earnings
            _eth = withdrawEarnings(_pID);
            
            // gib moni
            if (_eth > 0)
                plyr_[_pID].addr.transfer(_eth);
            
            // fire withdraw event
            emit IBCLotteryEvents.onWithdraw(_pID, msg.sender, _eth, _now);
        }
        
        if (now > round_.end && round_.plyr != 0) {
            refundTicket(_pID);
        }
    }

    /**
     *    ___     _   _                
     *   / _ \___| |_| |_ ___ _ __ ___ 
     *  / /_\/ _ \ __| __/ _ \ '__/ __|
     * / /_\\  __/ |_| ||  __/ |  \__ \
     * \____/\___|\__|\__\___|_|  |___/
     * */
    /**
     * @dev return the price buyer will pay for next 1 individual key.
     * -functionhash- 0x018a25e8
     * @return price for next key bought (in wei format)
     */
    function getBuyPrice()
        public 
        view 
        returns(uint256)
    {  
        // grab time
        uint256 _now = now;
        
        // are we in a round?
        if (_now > round_.strt && (_now <= round_.end || (_now > round_.end && round_.plyr == 0)))
            return ( (round_.keys.add(1000000000000000000)).ethRec(1000000000000000000) );
        else // rounds over.  need price for new round
            return ( 75000000000000 ); // init
    }
    
    /**
     * @dev returns time left.  dont spam this, you'll ddos yourself from your node 
     * provider
     * -functionhash- 0xc7e284b8
     * @return time left in seconds
     */
    function getTimeLeft()
        public
        view
        returns(uint256)
    {
        // grab time
        uint256 _now = now;
        
        if (_now < round_.end)
            if (_now > round_.strt)
                return( (round_.end).sub(_now) );
            else
                return( (round_.strt).sub(_now) );
        else
            return(0);
    }
    
    /**
     * @dev returns player earnings per vaults 
     * -functionhash- 0x63066434
     * @return winnings vault
     * @return general vault
     * @return affiliate vault
     * @return token share vault
     */
    function getPlayerVaults(uint256 _pID)
        public
        view
        returns(uint256 ,uint256, uint256, uint256)
    {
        uint256 _gen;
        uint256 _limiter;
        uint256 _genShow;
        // if round has ended.  but round end has not been run (so contract has not distributed winnings)
        if (now > round_.end && round_.ended == false && round_.plyr != 0)
        {
            // if player is winner 
            if (round_.plyr == _pID)
            {
                _gen = (plyr_[_pID].gen).add(getPlayerVaultsHelper(_pID).sub(plyrRnds_[_pID].mask));
                _limiter = (plyrRnds_[_pID].eth.mul(22) / 10);
                _genShow = 0;
                
                if (plyrRnds_[_pID].genWithdraw.add(_gen) > _limiter) {
                    _genShow = _limiter - plyrRnds_[_pID].genWithdraw;
                } else {
                    _genShow = _gen;
                }
                
                return
                (
                    (plyr_[_pID].win).add( ((round_.pot).mul(2)) / 5 ).add(getFinalDistribute(_pID)),
                    _genShow,
                    plyr_[_pID].aff,
                    plyr_[_pID].tokenShare.add(getTokenShare(_pID))
                );
            // if player is not the winner
            } else {
                
                _gen = (plyr_[_pID].gen).add(getPlayerVaultsHelper(_pID).sub(plyrRnds_[_pID].mask));
                _limiter = (plyrRnds_[_pID].eth.mul(22) / 10);
                _genShow = 0;
                
                if (plyrRnds_[_pID].genWithdraw.add(_gen) > _limiter) {
                    _genShow = _limiter - plyrRnds_[_pID].genWithdraw;
                } else {
                    _genShow = _gen;
                }    
                
                return
                (
                    (plyr_[_pID]).win.add(getFinalDistribute(_pID)),
                    _genShow,
                    plyr_[_pID].aff,
                    plyr_[_pID].tokenShare.add(getTokenShare(_pID))
                );
            }
            
        // if round is still going on, or round has ended and round end has been ran
        } else {
            _gen = (plyr_[_pID].gen).add(calcUnMaskedEarnings(_pID)) ;
            _limiter = (plyrRnds_[_pID].eth.mul(22) / 10);
            _genShow = 0;
            
            if (plyrRnds_[_pID].genWithdraw.add(_gen) > _limiter) {
                _genShow = _limiter - plyrRnds_[_pID].genWithdraw;
            } else {
                _genShow = _gen;
            }  
            
            return
            (
                plyr_[_pID].win.add(getFinalDistribute(_pID)),
                _genShow,
                plyr_[_pID].aff,
                plyr_[_pID].tokenShare.add(getTokenShare(_pID))
            );
        }
    }
    
    /**
     * solidity hates stack limits.  this lets us avoid that hate 
     */
    function getPlayerVaultsHelper(uint256 _pID)
        private
        view
        returns(uint256)
    {
        return(  (((round_.mask).mul(plyrRnds_[_pID].keys)) / 1000000000000000000)  );
    }
    
    function getFinalDistribute(uint256 _pID)
        private
        view
        returns(uint256)
    {
        uint256 _now = now;
        
        if (_now > round_.strt && (_now <= round_.end || (_now > round_.end && round_.plyr == 0)))
        {
            return 0;
        }
        
        uint256 _boughtTime = plyrRnds_[_pID].boughtTime;
        
        if(_boughtTime == 0) return 0;
        
        uint256 _firstKeyShare = round_.firstKeyShare;
        
        uint256 _eachKeyCanShare = round_.eachKeyCanShare;
        uint256 _totalKeyCanShare = 0;
        for (uint256 _bought = _boughtTime; _bought > 0; _bought --) {
            uint256 _lastKey = plyrRnds_[_pID].boughtRecord[_bought].lastKey;
            if (_lastKey < _firstKeyShare) break;
            uint256 _amount = plyrRnds_[_pID].boughtRecord[_bought].amount;
            uint256 _firstKey = _lastKey - _amount;
            if (_firstKey > _firstKeyShare) {
                _totalKeyCanShare = _totalKeyCanShare.add(_amount);
            } else {
                _totalKeyCanShare = _totalKeyCanShare.add(_lastKey - _firstKeyShare);
            }
        }
        return (_totalKeyCanShare.mul(_eachKeyCanShare) / 1000000000000000000);
    }
    
    function getTokenShare(uint256 _pID) 
        private
        view
        returns(uint256)
    {
        uint256 _now = now;
        
        if(plyrRnds_[_pID].tokenShareCalc) {
            return 0;
        }
        
        if (_now > round_.strt && (_now <= round_.end || (_now > round_.end && round_.plyr == 0)))
        {
            return 0;   
        }
        
        address _address = plyr_[_pID].addr;
        uint256 _userPaidIn = userPaidIn_[_address];
        
        return ((round_.tokenShare.mul(_userPaidIn)) / 1000000000000000000);
    }
    
    
    /**
     * @dev returns all current round info needed for front end
     * -functionhash- 0x747dff42
     * @return round id 
     * @return total keys for round 
     * @return time round ends
     * @return time round started
     * @return current pot 
     * @return player ID in lead 
     * @return current player in leads address 
     * @return token raised for buying ticket
     * @return token actual raised for using ticket.
     */
    function getCurrentRoundInfo()
        public
        view
        returns(uint256, uint256, uint256, uint256, uint256, address, uint256, uint256)
    {
        (uint256 _tokenRaised, uint256 _tokenActualRaised) = getTokenRaised();
        
        return
        (
            round_.keys,              //0
            round_.end,               //1
            round_.strt,              //2
            round_.pot,               //3
            round_.plyr,     //4
            plyr_[round_.plyr].addr,  //5
            _tokenRaised, // 6
            _tokenActualRaised //7 
        );
    }

    /**
     * @dev returns player info based on address.  if no address is given, it will 
     * use msg.sender 
     * -functionhash- 0xee0b5d8b
     * @param _addr address of the player you want to lookup 
     * @return player ID 
     * @return keys owned (current round)
     * @return winnings vault
     * @return general vault 
     * @return affiliate vault 
	 * @return player round eth
     */
    function getPlayerInfoByAddress(address _addr)
        public 
        view 
        returns(uint256, uint256, uint256, uint256, uint256, uint256, uint256)
    {
        if (_addr == address(0))
        {
            _addr == msg.sender;
        }
        uint256 _pID = pIDxAddr_[_addr];
        
        uint256 _gen = (plyr_[_pID].gen).add(calcUnMaskedEarnings(_pID));
        uint256 _limiter = (plyrRnds_[_pID].eth.mul(22) / 10);
        uint256 _genShow = 0;
        
        if (plyrRnds_[_pID].genWithdraw.add(_gen) > _limiter) {
            _genShow = _limiter - plyrRnds_[_pID].genWithdraw;
        } else {
            _genShow = _gen;
        } 
        
        return
        (
            _pID,                               //0
            plyrRnds_[_pID].keys,         //1
            plyr_[_pID].win,                    //2
            _genShow,       //3
            plyr_[_pID].aff,                    //4
            plyr_[_pID].tokenShare,             // 5
            plyrRnds_[_pID].eth           //6
        );
    }

    /**
     *    ___                   __             _      
     *   / __\___  _ __ ___    / /  ___   __ _(_) ___ 
     *  / /  / _ \| '__/ _ \  / /  / _ \ / _` | |/ __|
     * / /__| (_) | | |  __/ / /__| (_) | (_| | | (__ 
     * \____/\___/|_|  \___| \____/\___/ \__, |_|\___|
     *                                   |___/        
     * */
    
    /**
     * @dev this is the core logic for any buy/reload that happens while a round 
     * is live.
     */
    function core(uint256 _pID, uint256 _eth, uint256 _affID, IBCLotteryDatasets.EventReturns memory _eventData_)
        private
    {
        // if player is new to round
        if (plyrRnds_[_pID].keys == 0)
            _eventData_ = managePlayer(_pID, _eventData_);
        
        // if eth left is greater than min eth allowed (sorry no pocket lint)
        
        // mint the new keys
        uint256 _keys = (round_.eth).keysRec(_eth);
        uint256 _keyBonus = getKeyBonus();
        
        _keys = (_keys.mul(_keyBonus) / 10);
        
        // if they bought at least 1 whole key
        if (_keys >= 1000000000000000000 && _keyBonus == 10)
        {
            updateTimer(_keys);

            // set new leaders
            if (round_.plyr != _pID)
                round_.plyr = _pID;  
        }
        
        // new key cannot share over earning dividend.
        if (round_.overEarningMask > 0) {
            plyrRnds_[_pID].mask = plyrRnds_[_pID].mask.add(
                (round_.overEarningMask.mul(_keys) / 1000000000000000000)
            );
        }
        
        // update player 
        plyrRnds_[_pID].keys = _keys.add(plyrRnds_[_pID].keys);
        plyrRnds_[_pID].eth = _eth.add(plyrRnds_[_pID].eth);
        
        // update round
        round_.keys = _keys.add(round_.keys);
        round_.eth = _eth.add(round_.eth);
        
        uint256 _boughtTime = plyrRnds_[_pID].boughtTime + 1;
        plyrRnds_[_pID].boughtTime = _boughtTime;
        
        plyrRnds_[_pID].boughtRecord[_boughtTime].lastKey = round_.keys;
        plyrRnds_[_pID].boughtRecord[_boughtTime].amount = _keys;

        // distribute eth
        _eventData_ = distributeExternal(_pID, _eth, _affID, _eventData_);
        _eventData_ = distributeInternal(_pID, _eth, _keys, _eventData_);
        
        // call end tx function to fire end tx event.
        endTx(_eth, _keys, _eventData_);
    }
    /**
     *    ___      _            _       _   _                 
     *   / __\__ _| | ___ _   _| | __ _| |_(_) ___  _ __  ___ 
     *  / /  / _` | |/ __| | | | |/ _` | __| |/ _ \| '_ \/ __|
     * / /__| (_| | | (__| |_| | | (_| | |_| | (_) | | | \__ \
     * \____/\__,_|_|\___|\__,_|_|\__,_|\__|_|\___/|_| |_|___/
     * */
    /**
     * @dev calculates unmasked earnings (just calculates, does not update mask)
     * @return earnings in wei format
     */
    function calcUnMaskedEarnings(uint256 _pID)
        private
        view
        returns(uint256)
    {
        return(  (((round_.mask.add(round_.overEarningMask)).mul(plyrRnds_[_pID].keys)) / (1000000000000000000)).sub(plyrRnds_[_pID].mask)  );
    }
    
    /** 
     * @dev returns the amount of keys you would get given an amount of eth. 
     * -functionhash- 0xce89c80c
     * @param _eth amount of eth sent in 
     * @return keys received 
     */
    function calcKeysReceived(uint256 _eth)
        public
        view
        returns(uint256)
    {
        // grab time
        uint256 _now = now;
        
        // are we in a round?
        if (_now > round_.strt && (_now <= round_.end || (_now > round_.end && round_.plyr == 0)))
            return ( (round_.eth).keysRec(_eth) );
        else // rounds over.  need keys for new round
            return ( (_eth).keys() );
    }
    
    /** 
     * @dev returns current eth price for X keys.  
     * -functionhash- 0xcf808000
     * @param _keys number of keys desired (in 18 decimal format)
     * @return amount of eth needed to send
     */
    function iWantXKeys(uint256 _keys)
        public
        view
        returns(uint256)
    {
        // grab time
        uint256 _now = now;
        
        // are we in a round?
        if (_now > round_.strt && (_now <= round_.end || (_now > round_.end && round_.plyr == 0)))
            return ( (round_.keys.add(_keys)).ethRec(_keys) );
        else // rounds over.  need price for new round
            return ( (_keys).eth() );
    }

    function getTicketPrice()
        public
        view
        returns(uint256)
    {
        uint256 _now = now;
        // in round
        if (_now > round_.strt && (_now <= round_.end || (_now > round_.end && round_.plyr == 0)))
        {
            uint256 _timeLeft = round_.end - now;
            return calculateTicketPrice(round_.pot, _timeLeft);
        }
        // not in round
        else {
            return 1000000000000000000;
        }
    }

    /**
     *   _____            _     
     *  /__   \___   ___ | |___ 
     *   / /\/ _ \ / _ \| / __|
     *  / / | (_) | (_) | \__ \
     *  \/   \___/ \___/|_|___/
     * */
        
    /**
     * @dev gets existing or registers new pID.  use this when a player may be new
     * @return pID 
     */
    function determinePID(IBCLotteryDatasets.EventReturns memory _eventData_)
        private
        returns (IBCLotteryDatasets.EventReturns)
    {
        uint256 _pID = pIDxAddr_[msg.sender];
        if (_pID == 0)
        {
            maxUserId_ = maxUserId_ + 1;
            _pID = maxUserId_;
            
            // set up player account 
            pIDxAddr_[msg.sender] = _pID;
            plyr_[_pID].addr = msg.sender;
        } 
        return (_eventData_);
    }
    
    function getKeyBonus()
        view
        internal
        returns
        (uint256)
    {
        uint256 _timeLeft = getTimeLeft();
        
        if(_timeLeft == 86400) return 10;
        
        uint256 _hoursLeft = _timeLeft / 3600;
        uint256 _minutesLeft = (_timeLeft % 3600) / 60;
        
        if(_minutesLeft <= 59 && _minutesLeft >= 5) return 10;
        
        uint256 _flag = 0;
        if (_hoursLeft <= 24 && _hoursLeft >= 12) {
            _flag = 3;
        } else {
            _flag = 6;
        }
        
        uint256 _randomNumber = getRandomNumber() % _flag;
        
        return ((5*_randomNumber) + 15);
    }
    
    /**
     * @dev decides if round end needs to be run & new round started.  and if 
     * player unmasked earnings from previously played rounds need to be moved.
     */
    function managePlayer(uint256 _pID, IBCLotteryDatasets.EventReturns memory _eventData_)
        private
        returns (IBCLotteryDatasets.EventReturns)
    {
        // if player has played a previous round, move their unmasked earnings
        // from that round to gen vault.
        if (plyr_[_pID].lrnd != 0)
            updateGenVault(_pID);
            
        // update player's last round played
        plyr_[_pID].lrnd = rID_;
        
        return(_eventData_);
    }
    
    /**
     * @dev ends the round. manages paying out winner/splitting up pot
     */
    function endRound(IBCLotteryDatasets.EventReturns memory _eventData_)
        private
        returns (IBCLotteryDatasets.EventReturns)
    {
        
        // grab our winning player and team id's
        uint256 _winPID = round_.plyr;
        
        // grab our pot amount
        uint256 _pot = round_.pot;
        
        // calculate our winner share, community rewards, gen share, 
        // all eth in 20% to pot,
        // winner share 40% of pot.
        // last 1% user share another 50% of pot.
        uint256 _win = ((_pot.mul(2)) / 5);
        
        // refund those ticket unused to ibcToken wallet.
        uint256 tokenBackToTeam = tokenRaised_ - actualTokenRaised_;
        if (tokenBackToTeam > 0) {
            ibcToken_.transfer(officialWallet_, tokenBackToTeam / 2);
            ibcToken_.transfer(devATeamWallet_, tokenBackToTeam / 2);
        }
        
        // pay our winner
        plyr_[_winPID].win = _win.add(plyr_[_winPID].win);
        
            
        // prepare event data
        _eventData_.winnerAddr = plyr_[_winPID].addr;
        _eventData_.amountWon = _win;
        
        return(_eventData_);
    }
    
    /**
     * @dev moves any unmasked earnings to gen vault.  updates earnings mask
     */
    function updateGenVault(uint256 _pID)
        private 
    {
        uint256 _earnings = calcUnMaskedEarnings(_pID);
        if (_earnings > 0)
        {
            // put in gen vault
            plyr_[_pID].gen = _earnings.add(plyr_[_pID].gen);
            // zero out their earnings by updating mask
            plyrRnds_[_pID].mask = _earnings.add(plyrRnds_[_pID].mask);
        }
    }
    
    function updateFinalDistribute(uint256 _pID)
        private
    {
        uint256 _now = now;
        if (!(_now > round_.strt && (_now <= round_.end || (_now > round_.end && round_.plyr == 0))))
        {
            plyr_[_pID].win = plyr_[_pID].win + getFinalDistribute(_pID);
            plyrRnds_[_pID].boughtTime = 0;
        }
    }
    
    function updateTokenShare(uint256 _pID)
        internal
    {
        uint256 _now = now;
        if (!(_now > round_.strt && (_now <= round_.end || (_now > round_.end && round_.plyr == 0))))
        {
            if (!plyrRnds_[_pID].tokenShareCalc) {
                plyr_[_pID].tokenShare = plyr_[_pID].tokenShare + getTokenShare(_pID);
                plyrRnds_[_pID].tokenShareCalc = true;
            }
        }
    }
    
    /**
     * @dev updates round timer based on number of whole keys bought.
     */
    function updateTimer(uint256 _keys)
        private
    {
        // grab time
        uint256 _now = now;
        
        // calculate time based on number of keys bought
        uint256 _newTime;
        if (_now > round_.end && round_.plyr == 0)
            _newTime = (((_keys) / (1000000000000000000)).mul(rndInc_)).add(_now);
        else
            _newTime = (((_keys) / (1000000000000000000)).mul(rndInc_)).add(round_.end);
        
        // compare to max and set new end time
        if (_newTime < (rndMax_).add(_now))
            round_.end = _newTime;
        else
            round_.end = rndMax_.add(_now);
    }

    /**
     * @dev distributes eth based on fees to com, aff, and p3d
     */
    function distributeExternal(uint256 _pID, uint256 _eth, uint256 _affID, IBCLotteryDatasets.EventReturns memory _eventData_)
        private 
        returns(IBCLotteryDatasets.EventReturns)
    {
        
        // distribute share to affiliate
        // 20% for affiliate
        // origin ((_eth / 5).mul(88) / 100)
        uint256 _aff = ((_eth).mul(88) / 500);
        
        // decide what to do with affiliate share of fees
        // affiliate must not be self, and must have a name registered
        // what is this?
        // all of player of this game has player ID.
        // bu to be an legal affiliate must register, register can give user a name.
        // those users who have name is an valid affiliate.
        if (_affID != _pID && _affID != 0) {
            plyr_[_affID].aff = _aff.add(plyr_[_affID].aff);
            emit IBCLotteryEvents.onAffiliatePayout(_affID, plyr_[_affID].addr, _pID, _aff, now);
        } else if (!round_.firstPlayerIn){
            // first user send to dev A wallet.
            devATeamWallet_.transfer(_aff);
            round_.firstPlayerIn = true;
            emit IBCLotteryEvents.onAffiliatePayout(0, devATeamWallet_, _pID, _aff, now);
        } else {
            // no affiliate
            // send to offical wallet.
            devBTeamWallet_.transfer(_aff);
            emit IBCLotteryEvents.onAffiliatePayout(0, devBTeamWallet_, _pID, _aff, now);
        }
        
        return(_eventData_);
    }
    
    /**
     * @dev distributes eth based on fees to gen and pot
     */
    function distributeInternal(uint256 _pID, uint256 _eth, uint256 _keys, IBCLotteryDatasets.EventReturns memory _eventData_)
        private
        returns(IBCLotteryDatasets.EventReturns)
    {
        // calculate gen share 50%
        // origin = (_eth.mul(45).mul(88) / 100 / 100)
        uint256 _gen = (_eth.mul(3960) / 10000);
        
        // aff share 15%
        // _gen 50%
        // IBC share 10%
        // pot 25%
        
        // calculate pot 
        // origin: ((_eth / 4).mul(88) / 100)
        uint256 _pot = _pot.add((_eth.mul(88)) / 400);
        
        // distribute gen share (thats what updateMasks() does) and adjust
        // balances for dust.
        uint256 _dust = updateMasks(_pID, _gen, _keys);
        if (_dust > 0)
            _gen = _gen.sub(_dust);
        
        // add eth to pot
        round_.pot = _pot.add(_dust).add(round_.pot);
        
        // set up event data
        _eventData_.genAmount = _gen.add(_eventData_.genAmount);
        _eventData_.potAmount = _pot;
        
        return(_eventData_);
    }
    
    function refundTicket(uint256 _pID)
        public
    {
        address _playerAddress = plyr_[_pID].addr;
        uint256 _userPaidIn = userPaidIn_[_playerAddress];
        
        if (!plyr_[_pID].ibcRefund && _userPaidIn != 0) {
            // do not do refund at round 1.
            uint256 _refund = userPaidIn_[_playerAddress] / 4;
            plyr_[_pID].ibcRefund = true;
            ibcToken_.transfer(_playerAddress, _refund);
            emit onRefundTicket(
                _pID,
                _refund
            );
        }
    }

    /**
     * @dev updates masks for round and player when keys are bought
     * @return dust left over 
     */
    function updateMasks(uint256 _pID, uint256 _gen, uint256 _keys)
        private
        returns(uint256)
    {
        /* MASKING NOTES
            earnings masks are a tricky thing for people to wrap their minds around.
            the basic thing to understand here.  is were going to have a global
            tracker based on profit per share for each round, that increases in
            relevant proportion to the increase in share supply.
            
            the player will have an additional mask that basically says "based
            on the rounds mask, my shares, and how much i've already withdrawn,
            how much is still owed to me?"
        */
        
        // calc profit per key & round mask based on this buy:  (dust goes to pot)
        uint256 _ppt = (_gen.mul(1000000000000000000)) / (round_.keys);
        round_.mask = _ppt.add(round_.mask);
            
        // calculate player earning from their own buy (only based on the keys
        // they just bought).  & update player earnings mask
        uint256 _pearn = (_ppt.mul(_keys)) / (1000000000000000000);
        plyrRnds_[_pID].mask = (((round_.mask.mul(_keys)) / (1000000000000000000)).sub(_pearn)).add(plyrRnds_[_pID].mask);
        
        // calculate & return dust
        return(_gen.sub((_ppt.mul(round_.keys)) / (1000000000000000000)));
    }
    
    /**
     * @dev adds up unmasked earnings, & vault earnings, sets them all to 0
     * @return earnings in wei format
     */
    function withdrawEarnings(uint256 _pID)
        private
        returns(uint256)
    {
        // update gen vault
        updateGenVault(_pID);
        updateTokenShare(_pID);
        updateFinalDistribute(_pID);
        
        uint256 _playerGenWithdraw = plyrRnds_[_pID].genWithdraw;
        
        uint256 _limiter = (plyrRnds_[_pID].eth.mul(22) / 10);
        
        uint256 _withdrawGen = 0;
        
        if(_playerGenWithdraw.add(plyr_[_pID].gen) > _limiter) {
            _withdrawGen = _limiter - _playerGenWithdraw;
            
            uint256 _overEarning = _playerGenWithdraw.add(plyr_[_pID].gen) - _limiter;
            round_.overEarningMask = round_.overEarningMask.add(_overEarning.mul(1000000000000000000) / round_.keys);
            for (int i = 0; i < 5; i ++) {
                round_.overEarningMask = round_.overEarningMask.add(_overEarning.mul(1000000000000000000) / round_.keys);
                _overEarning = (round_.overEarningMask.mul(plyrRnds_[_pID].keys) / 1000000000000000000);
            }
            
            plyrRnds_[_pID].genWithdraw = _limiter;
        } else {
            _withdrawGen = plyr_[_pID].gen;
            
            plyrRnds_[_pID].genWithdraw = _playerGenWithdraw.add(plyr_[_pID].gen);
        }
        
        // from vaults 
        uint256 _earnings = (plyr_[_pID].win)
                            .add(_withdrawGen)
                            .add(plyr_[_pID].aff)
                            .add(plyr_[_pID].tokenShare);
        if (_earnings > 0)
        {
            plyr_[_pID].win = 0;
            plyr_[_pID].gen = 0;
            plyr_[_pID].aff = 0;
            plyr_[_pID].tokenShare = 0;
        }

        return(_earnings);
    }
    
    /**
     * @dev prepares compression data and fires event for buy or reload tx's
     */
    function endTx(uint256 _eth, uint256 _keys, IBCLotteryDatasets.EventReturns memory _eventData_)
        private
    {
        uint256 _pot = round_.pot;
        
        round_.firstKeyShare = ((round_.keys.mul(95)) / 100);
        uint256 _finalShareAmount = (round_.keys).sub(round_.firstKeyShare);
        round_.eachKeyCanShare = ((((_pot * 3) / 5).mul(1000000000000000000)) / _finalShareAmount);
        
        uint256 _ticketPrice = ticketRecord_[msg.sender].ticketPrice;
        
        userPaidIn_[msg.sender] = userPaidIn_[msg.sender] + _ticketPrice;
        actualTokenRaised_ = actualTokenRaised_ + _ticketPrice;
        
        ibcToken_.transfer(officialWallet_, (_ticketPrice / 2));
        ibcToken_.transfer(devATeamWallet_, (_ticketPrice / 4));
        
        // calculate share per token
        // origin: ((((round_.eth) / 10).mul(88)) / 100)
        uint256 totalTokenShare = (((round_.eth).mul(88)) / 1000);
        round_.tokenShare = ((totalTokenShare.mul(1000000000000000000)) / (actualTokenRaised_));
        
        devATeamWallet_.transfer(((_eth.mul(12)) / 100));
        
        ticketRecord_[msg.sender].hasTicket = false;
        
        emit IBCLotteryEvents.onEndTx
        (
            msg.sender,
            _eth,
            _keys,
            _eventData_.winnerAddr,
            _eventData_.amountWon,
            _eventData_.newPot,
            _eventData_.genAmount,
            _eventData_.potAmount
        );
    }
    
    function getRandomNumber() 
        view
        internal
        returns
        (uint8)
    {
        uint256 _timeLeft = getTimeLeft();
        return uint8(uint256(keccak256(
            abi.encodePacked(
            block.timestamp, 
            block.difficulty, 
            block.coinbase,
            _timeLeft,
            msg.sender
            )))%256);
    }
    
    function hasValidTicket()
        view
        public
        returns
        (bool)
    {
        address _buyer = msg.sender;
        uint256 _timeLeft = getTimeLeft();
        
        return hasValidTicketCore(_buyer, _timeLeft);
    }
    
    /**
     *    ___                                            _       
     *   /___\__      ___ __   ___ _ __       ___  _ __ | |_   _ 
     *  //  //\ \ /\ / / '_ \ / _ \ '__|____ / _ \| '_ \| | | | |
     * / \_//  \ V  V /| | | |  __/ | |_____| (_) | | | | | |_| |
     * \___/    \_/\_/ |_| |_|\___|_|        \___/|_| |_|_|\__, |
     *                                                     |___/ 
     * */
    /** upon contract deploy, it will be deactivated.  this is a one time
     * use function that will activate the contract.  we do this so devs 
     * have time to set things up on the web end                            **/
    bool public activated_ = false;
    function activate()
        onlyOwner(msg.sender)
        public
    {
        // can only be ran once
        require(activated_ == false, "IBCLottery already activated");
        
        // activate the contract 
        activated_ = true;
        
        // lets start first round
		rID_ = 1;
        round_.strt = now;
        round_.end = now + rndInit_;
    }
}

/**
 *   __ _                   _                  
 *  / _\ |_ _ __ _   _  ___| |_ _   _ _ __ ___ 
 *  \ \| __| '__| | | |/ __| __| | | | '__/ _ \
 *  _\ \ |_| |  | |_| | (__| |_| |_| | | |  __/
 *  \__/\__|_|   \__,_|\___|\__|\__,_|_|  \___|
 * */

library IBCLotteryDatasets {
    struct EventReturns {
        address winnerAddr;         // winner address
        uint256 amountWon;          // amount won
        uint256 newPot;             // amount in new pot
        uint256 genAmount;          // amount distributed to gen
        uint256 potAmount;          // amount added to pot
    }
    struct Player {
        address addr;   // player address
        uint256 win;    // winnings vault
        uint256 gen;    // general vault
        uint256 aff;    // affiliate vault
        uint256 tokenShare; // earning from token share
        uint256 lrnd;   // last round played
        uint256 laff;   // last affiliate id used
        bool ibcRefund;
    }
    struct PlayerRounds {
        uint256 eth;    // eth player has added to round (used for eth limiter)
        uint256 keys;   // keys
        uint256 mask;   // player mask
        bool tokenShareCalc; // if tokenShare value has been migrate.
        mapping(uint256 => BoughtRecord) boughtRecord;
        uint256 boughtTime;
        uint256 genWithdraw;
    }
    struct Round {
        uint256 plyr;   // pID of player in lead
        bool firstPlayerIn;
        uint256 end;    // time ends/ended
        bool ended;     // has round end function been ran
        uint256 strt;   // time round started
        uint256 keys;   // keys
        uint256 eth;    // total eth in
        uint256 pot;    // eth to pot (during round) / final amount paid to winner (after round ends)
        uint256 mask;   // global mask
        uint256 tokenShare; // how many eth user share per token send in.
        uint256 firstKeyShare;
        uint256 eachKeyCanShare;
        uint256 overEarningMask;
    }
    struct TeamFee {
        uint256 gen;    // % of buy in thats paid to key holders of current round
    }
    struct BoughtRecord {
        uint256 lastKey;
        uint256 amount;
    }
}

/**
 *                       ___      _            _       _   _             
 *    /\ /\___ _   _    / __\__ _| | ___ _   _| | __ _| |_(_) ___  _ __  
 *   / //_/ _ \ | | |  / /  / _` | |/ __| | | | |/ _` | __| |/ _ \| '_ \ 
 *  / __ \  __/ |_| | / /__| (_| | | (__| |_| | | (_| | |_| | (_) | | | |
 *  \/  \/\___|\__, | \____/\__,_|_|\___|\__,_|_|\__,_|\__|_|\___/|_| |_|
 *             |___/                                                     
 * */
library IBCLotteryKeysCalcLong {
    using SafeMath for *;
    /**
     * @dev calculates number of keys received given X eth 
     * @param _curEth current amount of eth in contract 
     * @param _newEth eth being spent
     * @return amount of ticket purchased
     */
    function keysRec(uint256 _curEth, uint256 _newEth)
        internal
        pure
        returns (uint256)
    {
        return(keys((_curEth).add(_newEth)).sub(keys(_curEth)));
    }
    
    /**
     * @dev calculates amount of eth received if you sold X keys 
     * @param _curKeys current amount of keys that exist 
     * @param _sellKeys amount of keys you wish to sell
     * @return amount of eth received
     */
    function ethRec(uint256 _curKeys, uint256 _sellKeys)
        internal
        pure
        returns (uint256)
    {
        return((eth(_curKeys)).sub(eth(_curKeys.sub(_sellKeys))));
    }

    /**
     * @dev calculates how many keys would exist with given an amount of eth
     * @param _eth eth "in contract"
     * @return number of keys that would exist
     */
    function keys(uint256 _eth) 
        internal
        pure
        returns(uint256)
    {
        return ((((((_eth).mul(1000000000000000000)).mul(312500000000000000000000000)).add(5624988281256103515625000000000000000000000000000000000000000000)).sqrt()).sub(74999921875000000000000000000000)) / (156250000);
    }
    
    /**
     * @dev calculates how much eth would be in contract given a number of keys
     * @param _keys number of keys "in contract" 
     * @return eth that would exists
     */
    function eth(uint256 _keys) 
        internal
        pure
        returns(uint256)  
    {
        return ((78125000).mul(_keys.sq()).add(((149999843750000).mul(_keys.mul(1000000000000000000))) / (2))) / ((1000000000000000000).sq());
    }
}

/**
 *  __        __                   _   _     
 * / _\ __ _ / _| ___  /\/\   __ _| |_| |__  
 * \ \ / _` | |_ / _ \/    \ / _` | __| '_ \ 
 * _\ \ (_| |  _|  __/ /\/\ \ (_| | |_| | | |
 * \__/\__,_|_|  \___\/    \/\__,_|\__|_| |_|
 */
library SafeMath {
    
    /**
    * @dev Multiplies two numbers, throws on overflow.
    */
    function mul(uint256 a, uint256 b) 
        internal 
        pure 
        returns (uint256 c) 
    {
        if (a == 0) {
            return 0;
        }
        c = a * b;
        require(c / a == b, "SafeMath mul failed");
        return c;
    }

    /**
    * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
    */
    function sub(uint256 a, uint256 b)
        internal
        pure
        returns (uint256) 
    {
        require(b <= a, "SafeMath sub failed");
        return a - b;
    }

    /**
    * @dev Adds two numbers, throws on overflow.
    */
    function add(uint256 a, uint256 b)
        internal
        pure
        returns (uint256 c) 
    {
        c = a + b;
        require(c >= a, "SafeMath add failed");
        return c;
    }
    
    /**
     * @dev gives square root of given x.
     */
    function sqrt(uint256 x)
        internal
        pure
        returns (uint256 y) 
    {
        uint256 z = ((add(x,1)) / 2);
        y = x;
        while (z < y) 
        {
            y = z;
            z = ((add((x / z),z)) / 2);
        }
    }
    
    /**
     * @dev gives square. multiplies x by x
     */
    function sq(uint256 x)
        internal
        pure
        returns (uint256)
    {
        return (mul(x,x));
    }
    
    /**
     * @dev x to the power of y 
     */
    function pwr(uint256 x, uint256 y)
        internal 
        pure 
        returns (uint256)
    {
        if (x==0)
            return (0);
        else if (y==0)
            return (1);
        else 
        {
            uint256 z = x;
            for (uint256 i=1; i < y; i++)
                z = mul(z,x);
            return (z);
        }
    }
}