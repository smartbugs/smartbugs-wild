pragma solidity 0.4.24;

// _____________________________________________________________
//                  .''
//        ._.-.___.' (`\
//       //(        ( `'
//      '/ )\ ).__. )
//      ' <' `\ ._/'\
// ________`___\_____\__________________________________________
//                                            .''
//     ___ _____ _ __ ___  ___      ._.-.___.' (`\
//    / _//_  _//// // _/ / o |    //(        ( `'
//   / _/  / / / ` // _/ /  ,'    '/ )\ ).__. )
//  /___/ /_/ /_n_//___//_/`_\    ' <' `\ ._/'\
// __________________________________`___\_____\________________
//                                                    .''
//     __   ___  ___   ___  _  __           ._.-.___.' (`\
//    /  \ / _/ / o | / o.)| |/,'          //(        ( `'
//   / o |/ _/ /  ,' / o \ | ,'           '/ )\ ).__. )
//  /__,'/___//_/`_\/___,'/_/             ' <' `\ ._/'\
// __________________________________________`___\_____\________
//                            .''
//                  ._.-.___.' (`\
//                 //(        ( `'
//                '/ )\ ).__. )
//                ' <' `\ ._/'\
// __________________`___\_____\________________________________
//
// This product is protected under license.  Any unauthorized copy, modification, or use without 
// express written consent from the creators is prohibited.
//
contract EtherDerby {
    using SafeMath for *;
    using CalcCarrots for uint256;

    // settings
    string constant public name = "EtherDerby";
    uint256 constant private ROUNDMAX = 4 hours;
    uint256 constant private MULTIPLIER = 2**64;
    uint256 constant private DECIMALS = 18;
    uint256 constant public REGISTERFEE = 20 finney;

    address constant private DEVADDR = 0xC17A40cB38598520bd7C0D5BFF97D441A810a008;

    // horse Identifiers
    uint8 constant private H1 = 1;
    uint8 constant private H2 = 2;
    uint8 constant private H3 = 3;
    uint8 constant private H4 = 4;

    //  ___  _ _  ___   __   _  ___  _
    // |_ _|| U || __| |  \ / \|_ _|/ \
    //  | | |   || _|  | o ) o || || o |
    //  |_| |_n_||___| |__/|_n_||_||_n_|
    //

    struct Round {
        uint8 winner; // horse in the lead
        mapping (uint8 => uint256) eth; // total eth per horse
        mapping (uint8 => uint256) carrots; // total eth per horse
    }

    struct Player {
        address addr; // player address
        bytes32 name; // player name
        uint256 totalWinnings; // player winnings
        uint256 totalReferrals; // player referral bonuses
        int256  dividendPayouts; // running count of payouts player has received (important that it can be negative)

        mapping (uint256 => mapping (uint8 => uint256)) eth; // round -> horse -> eTH invested
        mapping (uint256 => mapping (uint8 => uint256)) carrots; // round -> horse -> carrots purchased
        mapping (uint256 => mapping (uint8 => uint256)) referrals; // round -> horse -> referrals (eth)

        mapping (uint8 => uint256) totalEth; // total carrots invested in each horse by the player
        mapping (uint8 => uint256) totalCarrots; // total carrots invested in each horse by the player

        uint256 totalWithdrawn; // running total of ETH withdrawn by the player
        uint256 totalReinvested; // running total of ETH reinvested by the player

        uint256 roundLastManaged; // round players winnings were last recorded
        uint256 roundLastReferred; // round player was last referred and therefore had its referrals managed
        address lastRef; // address of player who last referred this player
    }

    struct Horse {
        bytes32 name;
        uint256 totalEth;
        uint256 totalCarrots;
        uint256 mostCarrotsOwned;
        address owner;
    }

    uint256 rID_ = 0; // current round number
    mapping (uint256 => Round) public rounds_; // data for each round
    uint256 roundEnds_; // time current round is over
    mapping (address => Player) public players_; // data for each player
    mapping (uint8 => Horse) horses_; // data for each horse
    uint256 private earningsPerCarrot_; // used to keep track of dividends rewarded to carrot holders

    mapping (bytes32 => address) registeredNames_;

    //  ___  _ _  ___  _  _  ___ __
    // | __|| | || __|| \| ||_ _/ _|
    // | _| | V || _| | \\ | | |\_ \
    // |___| \_/ |___||_|\_| |_||__/
    //

    /**
     * @dev fired for every set of carrots purchased or reinvested in
     * @param playerAddress player making the purchase
     * @param playerName players name if they have registered
     * @param roundId round for which carrots were purchased
     * @param horse array of two horses (stack limit hit so we use array)
     *   0 - horse which horse carrots were purchased for
     *   1 - horse now in the lead
     * @param horseName horse name at the time of purchase
     * @param roundEnds round end time
     * @param timestamp block timestamp when purchase occurred
     * @param data contains the following (stack limit hit so we use array)
     *   0 - amount of eth
     *   1 - amount of carrots
     *   2 - horses total eth for the round
     *   3 - horses total carrots for the round
     *   4 - players total eth for the round
     *   5 - players total carrots for the round
     */
    event OnCarrotsPurchased
    (
        address indexed playerAddress,
        bytes32 playerName,
        uint256 roundId,
        uint8[2] horse,
        bytes32 indexed horseName,
        uint256[6] data,
        uint256 roundEnds,
        uint256 timestamp
    );

    /**
     * @dev fired each time a player withdraws ETH
     * @param playerAddress players address
     * @param eth amount withdrawn
     */
    event OnEthWithdrawn
    (
        address indexed playerAddress,
        uint256 eth
    );

    /**
     * @dev fired whenever a horse is given a new name
     * @param playerAddress which player named the horse
     * @param horse number of horse being named
     * @param horseName new name of horse
     * @param mostCarrotsOwned number of carrots by owned to name the horse
     * @param timestamp block timestamp when horse is named
     */
    event OnHorseNamed
    (
      address playerAddress,
      bytes32 playerName,
      uint8 horse,
      bytes32 horseName,
      uint256 mostCarrotsOwned,
      uint256 timestamp
    );

    /**
     * @dev fired whenever a player registers a name
     * @param playerAddress which player registered a name
     * @param playerName name being registered
     * @param ethDonated amount of eth donated with registration
     * @param timestamp block timestamp when name registered
     */
    event OnNameRegistered
    (
        address playerAddress,
        bytes32 playerName,
        uint256 ethDonated,
        uint256 timestamp
    );

    /**
     * @dev fired when a transaction is rejected
     * mainly used to make it easier to write front end code
     * @param playerAddress player making the purchase
     * @param reason why the transaction failed
     */
    event OnTransactionFail
    (
        address indexed playerAddress,
        bytes32 reason
    );

    constructor()
      public
    {
        // start with Round 0 ending before now so that first purchase begins Round 1
        // subtract an hour to make sure the first purchase doesn't go to round 0 (ex. same block)
        roundEnds_ = block.timestamp - 1 hours;

        // default horse names
        horses_[H1].name = "horse1";
        horses_[H2].name = "horse2";
        horses_[H3].name = "horse3";
        horses_[H4].name = "horse4";
    }

    //  _   _  _  __  _  ___  _  ___  ___  __
    // | \_/ |/ \|  \| || __|| || __|| o \/ _|
    // | \_/ ( o ) o ) || _| | || _| |   /\_ \
    // |_| |_|\_/|__/|_||_|  |_||___||_|\\|__/
    //

    /**
     * @dev verifies that a valid horse is provided
     */
    modifier isValidHorse(uint8 _horse) {
        require(_horse == H1 || _horse == H2 || _horse == H3 || _horse == H4, "unknown horse selected");
        _;
    }

    /**
     * @dev prevents smart contracts from interacting with EtherDerby
     */
    modifier isHuman() {
        address addr = msg.sender;
        uint256 codeLength;

        assembly {codeLength := extcodesize(addr)}
        require(codeLength == 0, "Humans only ;)");
        require(msg.sender == tx.origin, "Humans only ;)");
        _;
    }

    /**
     * @dev verifies that all purchases sent include a reasonable amount of ETH
     */
    modifier isWithinLimits(uint256 _eth) {
        require(_eth >= 1000000000, "Not enough eth!");
        require(_eth <= 100000000000000000000000, "Go away whale!");
        _;
    }


    //  ___ _ _  ___ _    _  __   ___  _ _  _  _  __  ___  _  _  _  _  __
    // | o \ | || o ) |  | |/ _| | __|| | || \| |/ _||_ _|| |/ \| \| |/ _|
    // |  _/ U || o \ |_ | ( (_  | _| | U || \\ ( (_  | | | ( o ) \\ |\_ \
    // |_| |___||___/___||_|\__| |_|  |___||_|\_|\__| |_| |_|\_/|_|\_||__/
    //

    /**
     * @dev register a name with Ether Derby to generate a referral link
     * @param _nameStr the name being registered (see NameValidator library below
     * for name requirements)
     */
    function registerName(string _nameStr)
        public
        payable
        isHuman()
    {
        require(msg.value >= REGISTERFEE, "You must pay the partner fee of 20 finney");

        bytes32 nameToRegister = NameValidator.validate(_nameStr);

        require(registeredNames_[nameToRegister] == 0, "Name already in use");

        registeredNames_[nameToRegister] = msg.sender;
        players_[msg.sender].name = nameToRegister;

        // partner fee goes to devs
        players_[DEVADDR].totalReferrals = msg.value.add(players_[DEVADDR].totalReferrals);

        emit OnNameRegistered(msg.sender, nameToRegister, msg.value, block.timestamp);
    }

    /**
     * @dev buy carrots with ETH
     * @param _horse the horse carrots are being purchased for
     * @param _round the round these carrots should be purchased for (send 0 to
     * buy for whatever the current round is)
     * @param _referrerName the player for which to reward referral bonuses to
     */
    function buyCarrots(uint8 _horse, uint256 _round, bytes32 _referrerName)
        public
        payable
        isHuman()
        isWithinLimits(msg.value)
        isValidHorse(_horse)
    {
        if (isInvalidRound(_round)) {
            emit OnTransactionFail(msg.sender, "Invalid round");
            msg.sender.transfer(msg.value);
            return;
        }
        buyCarrotsInternal(_horse, msg.value, _referrerName);
    }

    /**
     * @dev buy carrots with current earnings left in smart contract
     * @param _horse the horse carrots are being purchased for
     * @param _round the round these carrots should be purchased for (send 0 to
     * buy for whatever the current round is)
     * @param _referrerName the player for which to reward referral bonuses to
     */
    function reinvestInCarrots(uint8 _horse, uint256 _round, uint256 _value, bytes32 _referrerName)
        public
        isHuman()
        isWithinLimits(_value)
        isValidHorse(_horse)
    {
        if (isInvalidRound(_round)) {
            emit OnTransactionFail(msg.sender, "Invalid round");
            return;
        }
        if (calcPlayerEarnings() < _value) {
            // Not enough earnings in player vault
            emit OnTransactionFail(msg.sender, "Insufficient funds");
            return;
        }
        players_[msg.sender].totalReinvested = _value.add(players_[msg.sender].totalReinvested);

        buyCarrotsInternal(_horse, _value, _referrerName);
    }

    /**
     * @dev name horse by purchasing enough carrots to become majority holder
     * @param _horse the horse being named
     * @param _nameStr the desired horse name (See NameValidator for requirements)
     * @param _referrerName the player for which to reward referral bonuses to
     */
    function nameHorse(uint8 _horse, string _nameStr, bytes32 _referrerName)
      public
      payable
      isHuman()
      isValidHorse(_horse)
    {
        if ((rounds_[getCurrentRound()].eth[_horse])
            .carrotsReceived(msg.value)
            .add(players_[msg.sender].totalCarrots[_horse]) < 
                horses_[_horse].mostCarrotsOwned) {
            emit OnTransactionFail(msg.sender, "Insufficient funds");
            if (msg.value > 0) {
                msg.sender.transfer(msg.value);
            }
            return;
        }
        if (msg.value > 0) {
            buyCarrotsInternal(_horse, msg.value, _referrerName);    
        }
        horses_[_horse].name = NameValidator.validate(_nameStr);
        if (horses_[_horse].owner != msg.sender) {
            horses_[_horse].owner = msg.sender;
        }
        emit OnHorseNamed(
            msg.sender,
            players_[msg.sender].name,
            _horse,
            horses_[_horse].name,
            horses_[_horse].mostCarrotsOwned,
            block.timestamp
        );
    }

    /**
     * @dev withdraw all earnings made so far. includes winnings, dividends, and referrals
     */
    function withdrawEarnings()
        public
        isHuman()
    {
        managePlayer();
        manageReferrer(msg.sender);

        uint256 earnings = calcPlayerEarnings();
        if (earnings > 0) {
            players_[msg.sender].totalWithdrawn = earnings.add(players_[msg.sender].totalWithdrawn);
            msg.sender.transfer(earnings);
        }
        emit OnEthWithdrawn(msg.sender, earnings);
    }

    /**
     * @dev fallback function puts incoming eth into devs referrals
     */
    function()
        public
        payable
    {
        players_[DEVADDR].totalReferrals = msg.value.add(players_[DEVADDR].totalReferrals);
    }

    //  ___ ___ _  _ _   _  ___  ___   _ _  ___  _    ___ ___  ___  __
    // | o \ o \ || | | / \|_ _|| __| | U || __|| |  | o \ __|| o \/ _|
    // |  _/   / || V || o || | | _|  |   || _| | |_ |  _/ _| |   /\_ \
    // |_| |_|\\_| \_/ |_n_||_| |___| |_n_||___||___||_| |___||_|\\|__/
    //

    /**
     * @dev core helper method for purchasing carrots
     * @param _horse the horse carrots are being purchased for
     * @param _value amount of eth to spend on carrots
     * @param _referrerName the player for which to reward referral bonuses to
     */
    function buyCarrotsInternal(uint8 _horse, uint256 _value, bytes32 _referrerName)
        private
    {
        // check if new round needs started and update horses pending data if necessary
        manageRound();

        // update players winnings and reset pending data if necessary
        managePlayer();

        address referrer = getReferrer(_referrerName);
        // update referrers total referrals and reset pending referrals if necessary
        manageReferrer(referrer);
        if (referrer != DEVADDR) {
            // also manage dev account unless referrer is dev
            manageReferrer(DEVADDR);
        }

        uint256 carrots = (rounds_[rID_].eth[_horse]).carrotsReceived(_value);

        /*******************/
        /*  Update Player  */
        /*******************/

        players_[msg.sender].eth[rID_][_horse] = 
            _value.add(players_[msg.sender].eth[rID_][_horse]);
        players_[msg.sender].carrots[rID_][_horse] = 
            carrots.add(players_[msg.sender].carrots[rID_][_horse]);
        players_[msg.sender].totalEth[_horse] =
            _value.add(players_[msg.sender].totalEth[_horse]);
        players_[msg.sender].totalCarrots[_horse] =
            carrots.add(players_[msg.sender].totalCarrots[_horse]);

        // players don't recieve dividends before buying the carrots
        players_[msg.sender].dividendPayouts += SafeConversions.SafeSigned(earningsPerCarrot_.mul(carrots));

        /*******************/
        /* Update Referrer */
        /*******************/

        players_[referrer].referrals[rID_][_horse] = 
            ninePercent(_value).add(players_[referrer].referrals[rID_][_horse]);
        // one percent to devs
        // reuse referrals since functionality is the same
        players_[DEVADDR].referrals[rID_][_horse] =
            _value.div(100).add(players_[DEVADDR].referrals[rID_][_horse]);

        // check if players new amount of total carrots for this horse is greater than mostCarrotsOwned and update
        if (players_[msg.sender].totalCarrots[_horse] > horses_[_horse].mostCarrotsOwned) {
          horses_[_horse].mostCarrotsOwned = players_[msg.sender].totalCarrots[_horse];
        }

        /*******************/
        /*  Update  Round  */
        /*******************/

        rounds_[rID_].eth[_horse] = _value.add(rounds_[rID_].eth[_horse]);
        rounds_[rID_].carrots[_horse] = carrots.add(rounds_[rID_].carrots[_horse]);

        // if this horses carrots now exceeds current winner, update current winner
        if (rounds_[rID_].winner != _horse &&
            rounds_[rID_].carrots[_horse] > rounds_[rID_].carrots[rounds_[rID_].winner]) {
            rounds_[rID_].winner = _horse;
        }

        /*******************/
        /*  Update  Horse  */
        /*******************/

        horses_[_horse].totalCarrots = carrots.add(horses_[_horse].totalCarrots);
        horses_[_horse].totalEth = _value.add(horses_[_horse].totalEth);

        emit OnCarrotsPurchased(
            msg.sender,
            players_[msg.sender].name,
            rID_,
            [
                _horse,
                rounds_[rID_].winner
            ],
            horses_[_horse].name,
            [
                _value,
                carrots,
                rounds_[rID_].eth[_horse],
                rounds_[rID_].carrots[_horse],
                players_[msg.sender].eth[rID_][_horse],
                players_[msg.sender].carrots[rID_][_horse]
            ],
            roundEnds_,
            block.timestamp
        );
    }

    /**
     * @dev check if now is past current rounds ends time. if so, compute round
     * details and update all storage to start the next round
     */
    function manageRound()
      private
    {
        if (!isRoundOver()) {
            return;
        }
        // round over, update dividends and start next round
        uint256 earningsPerCarrotThisRound = fromEthToDivies(calcRoundLosingHorsesEth(rID_));

        if (earningsPerCarrotThisRound > 0) {
            earningsPerCarrot_ = earningsPerCarrot_.add(earningsPerCarrotThisRound);  
        }

        rID_++;
        roundEnds_ = block.timestamp + ROUNDMAX;
    }

    /**
     * @dev check if a player has winnings from a previous round that have yet to
     * be recorded. this needs to be called before any player interacts with Ether
     * Derby to make sure there data is kept up to date
     */
    function managePlayer()
        private
    {
        uint256 unrecordedWinnings = calcUnrecordedWinnings();
        if (unrecordedWinnings > 0) {
            players_[msg.sender].totalWinnings = unrecordedWinnings.add(players_[msg.sender].totalWinnings);
        }
        // if managePlayer is being called while round is over, calcUnrecordedWinnings will include
        // winnings from the current round. it's important that we store rID_+1 here to make sure
        // users can't double withdraw winnings from current round
        if (players_[msg.sender].roundLastManaged == rID_ && isRoundOver()) {
            players_[msg.sender].roundLastManaged = rID_.add(1);
        }
        else if (players_[msg.sender].roundLastManaged < rID_) {
            players_[msg.sender].roundLastManaged = rID_;
        }
    }

    /**
     * @dev check if a player has referral bonuses from a previous round that have yet 
     * to be recorded
     */
    function manageReferrer(address _referrer)
        private
    {
        uint256 unrecordedRefferals = calcUnrecordedRefferals(_referrer);
        if (unrecordedRefferals > 0) {
            players_[_referrer].totalReferrals =
                unrecordedRefferals.add(players_[_referrer].totalReferrals);
        }

        if (players_[_referrer].roundLastReferred == rID_ && isRoundOver()) {
            players_[_referrer].roundLastReferred = rID_.add(1);
        }
        else if (players_[_referrer].roundLastReferred < rID_) {
            players_[_referrer].roundLastReferred = rID_;
        }
    }

    /**
     * @dev calculate total amount of carrots that have been purchased
     */
    function calcTotalCarrots()
        private
        view
        returns (uint256)
    {
        return horses_[H1].totalCarrots
            .add(horses_[H2].totalCarrots)
            .add(horses_[H3].totalCarrots)
            .add(horses_[H4].totalCarrots);
    }

    /**
     * @dev calculate players total amount of carrots including the unrecorded
     */
    function calcPlayerTotalCarrots()
        private
        view
        returns (uint256)
    {
        return players_[msg.sender].totalCarrots[H1]
            .add(players_[msg.sender].totalCarrots[H2])
            .add(players_[msg.sender].totalCarrots[H3])
            .add(players_[msg.sender].totalCarrots[H4]);
    }

    /**
     * @dev calculate players total amount of eth spent including unrecorded
     */
    function calcPlayerTotalEth()
        private
        view
        returns (uint256)
    {
        return players_[msg.sender].totalEth[H1]
            .add(players_[msg.sender].totalEth[H2])
            .add(players_[msg.sender].totalEth[H3])
            .add(players_[msg.sender].totalEth[H4]);
    }

    /**
     * @dev calculate players total earnings (able to be withdrawn)
     */
    function calcPlayerEarnings()
        private
        view
        returns (uint256)
    {
        return calcPlayerWinnings()
            .add(calcPlayerDividends())
            .add(calcPlayerReferrals())
            .sub(players_[msg.sender].totalWithdrawn)
            .sub(players_[msg.sender].totalReinvested);
    }

    /**
     * @dev calculate players total winning including the unrecorded
     */
    function calcPlayerWinnings()
        private
        view
        returns (uint256)
    {
        return players_[msg.sender].totalWinnings.add(calcUnrecordedWinnings());
    }

    /**
     * @dev calculate players total dividends including the unrecorded
     */
    function calcPlayerDividends()
      private
      view
      returns (uint256)
    {
        uint256 unrecordedDividends = calcUnrecordedDividends();
        uint256 carrotBalance = calcPlayerTotalCarrots();
        int256 totalDividends = SafeConversions.SafeSigned(carrotBalance.mul(earningsPerCarrot_).add(unrecordedDividends));
        return SafeConversions.SafeUnsigned(totalDividends - players_[msg.sender].dividendPayouts).div(MULTIPLIER);
    }

    /**
     * @dev calculate players total referral bonus including the unrecorded
     */
    function calcPlayerReferrals()
        private
        view
        returns (uint256)
    {
        return players_[msg.sender].totalReferrals.add(calcUnrecordedRefferals(msg.sender));
    }

    /**
     * @dev calculate players unrecorded winnings (those not yet in Player.totalWinnings)
     */
    function calcUnrecordedWinnings()
        private
        view
        returns (uint256)
    {
        uint256 round = players_[msg.sender].roundLastManaged;
        if ((round == 0) || (round > rID_) || (round == rID_ && !isRoundOver())) {
            // all winnings have been recorded
            return 0;
        }
        // round is <= rID_, not 0, and if equal then round is over
        // (players eth spent on the winning horse during their last round) +
        // ((players carrots for winning horse during their last round) * 
        // (80% of losing horses eth)) / total carrots purchased for winning horse
        return players_[msg.sender].eth[round][rounds_[round].winner]
            .add((players_[msg.sender].carrots[round][rounds_[round].winner]
            .mul(eightyPercent(calcRoundLosingHorsesEth(round))))
            .div(rounds_[round].carrots[rounds_[round].winner]));
    }

    /**
     * @dev calculate players unrecorded dividends (those not yet reflected in earningsPerCarrot_)
     */
    function calcUnrecordedDividends()
        private
        view
        returns (uint256)
    {
        if (!isRoundOver()) {
            // round is not over
            return 0;
        }
        // round has ended but next round has not yet been started, so
        // dividends from the current round are reflected in earningsPerCarrot_
        return fromEthToDivies(calcRoundLosingHorsesEth(rID_)).mul(calcPlayerTotalCarrots());
    }

    /**
     * @dev calculate players unrecorded referral bonus (those not yet in Player.referrals)
     */
    function calcUnrecordedRefferals(address _player)
        private
        view
        returns (uint256 ret)
    {
        uint256 round = players_[_player].roundLastReferred;
        if (!((round == 0) || (round > rID_) || (round == rID_ && !isRoundOver()))) {
            for (uint8 i = H1; i <= H4; i++) {
                if (rounds_[round].winner != i) {
                    ret = ret.add(players_[_player].referrals[round][i]);
                }
            }
        }
    }

    /**
     * @dev calculate total eth from all horses except the winner
     */
    function calcRoundLosingHorsesEth(uint256 _round)
        private
        view
        returns (uint256 ret)
    {
        for (uint8 i = H1; i <= H4; i++) {
            if (rounds_[_round].winner != i) {
                ret = ret.add(rounds_[_round].eth[i]);
            }
        }
    }

    /**
     * @dev calculate the change in earningsPerCarrot_ based on new eth coming in
     * @param _value amount of ETH being sent out as dividends to all carrot holders
     */
    function fromEthToDivies(uint256 _value)
        private
        view
        returns (uint256)
    {
        // edge case where dividing by 0 would happen
        uint256 totalCarrots = calcTotalCarrots();
        if (totalCarrots == 0) {
            return 0;
        }
        // multiply by MULTIPLIER to prevent integer division from returning 0
        // when totalCarrots > losingHorsesEth
        // divide by 10 because only 10% of losing horses ETH goes to dividends
        return _value.mul(MULTIPLIER).div(10).div(totalCarrots);
    }

    /**
     * @dev convert registered name to an address
     * @param _referrerName name of player that referred current player
     * @return address of referrer if valid, or last person to refer the current player,
     * or the devs as a backup referrer
     */
    function getReferrer(bytes32 _referrerName)
        private
        returns (address)
    {
        address referrer;
        // referrer is not empty, unregistered, or same as buyer
        if (_referrerName != "" && registeredNames_[_referrerName] != 0 && _referrerName != players_[msg.sender].name) {
            referrer = registeredNames_[_referrerName];
        } else if (players_[msg.sender].lastRef != 0) {
            referrer = players_[msg.sender].lastRef;
        } else {
            // fallback to Devs if no referrer provided
            referrer = DEVADDR;
        }
        if (players_[msg.sender].lastRef != referrer) {
            // store last referred to allow partner to continue receiving
            // future purchases from this player
            players_[msg.sender].lastRef = referrer;
        }
        return referrer;
    }

    /**
     * @dev calculate price of buying carrots
     * @param _horse which horse to calculate price for
     * @param _carrots how many carrots desired
     * @return ETH required to purchase X many carrots (in large format)
     */
    function calculateCurrentPrice(uint8 _horse, uint256 _carrots)
        private
        view
        returns(uint256)
    {
        uint256 currTotal = 0;
        if (!isRoundOver()) {
            // Round is ongoing
            currTotal = rounds_[rID_].carrots[_horse];
        }
        return currTotal.add(_carrots).ethReceived(_carrots);
    }

    /**
     * @dev check if a round number is valid to make a purchase for
     * @param _round round to check
     * @return true if _round is current (or next if current is over)
     */
    function isInvalidRound(uint256 _round)
        private
        view
        returns(bool)
    {
        // passing _round as 0 means buy for current round
        return _round != 0 && _round != getCurrentRound();
    }

    /**
     * @dev get current round
     */
    function getCurrentRound()
        private
        view
        returns(uint256)
    {
        if (isRoundOver()) {
            return (rID_ + 1);
        }
        return rID_;
    }

    /**
     * @dev check if current round has ended based on current block timestamp
     * @return true if round is over, false otherwise
     */
    function isRoundOver()
        private
        view
        returns (bool)
    {
        return block.timestamp >= roundEnds_;
    }

    /**
     * @dev compute eighty percent as whats left after subtracting 10%, 1% and 9%
     * @param num_ number to compute 80% of
     */
    function eightyPercent(uint256 num_)
        private
        pure
        returns (uint256)
    {
        // 100% - 9% - 1% - 10% = 80%
        return num_.sub(ninePercent(num_)).sub(num_.div(100)).sub(num_.div(10));
    }

    /**
     * @dev compute eighty percent as whats left after subtracting 10% twice
     * @param num_ number to compute 80% of
     */
    function ninePercent(uint256 num_)
        private
        pure
        returns (uint256)
    {
        return num_.mul(9).div(100);
    }

    //  _____ _____  ___  ___ _  _   _   _     _ _  _   _   _  ___  ___  _ _  _  __  __
    // | __\ V /_ _|| __|| o \ \| | / \ | |   | | || | | \_/ || __||_ _|| U |/ \|  \/ _|
    // | _| ) ( | | | _| |   / \\ || o || |_  | U || | | \_/ || _|  | | |   ( o ) o )_ \
    // |___/_n_\|_| |___||_|\\_|\_||_n_||___| |___||_| |_| |_||___| |_| |_n_|\_/|__/|__/
    //

    /**
     * @dev get stats from current round (or the last round if new has not yet started)
     * @return round id
     * @return round end time
     * @return horse in the lead
     * @return eth for each horse
     * @return carrots for each horse
     * @return eth invested for each horse
     * @return carrots invested for each horse
     * @return horse names
     */
    function getRoundStats()
        public
        view
        returns(uint256, uint256, uint8, uint256[4], uint256[4], uint256[4], uint256[4], bytes32[4])
    {
        return
        (
            rID_,
            roundEnds_,
            rounds_[rID_].winner,
            [
                rounds_[rID_].eth[H1],
                rounds_[rID_].eth[H2],
                rounds_[rID_].eth[H3],
                rounds_[rID_].eth[H4]
            ],
            [
                rounds_[rID_].carrots[H1],
                rounds_[rID_].carrots[H2],
                rounds_[rID_].carrots[H3],
                rounds_[rID_].carrots[H4]
            ],
            [
                players_[msg.sender].eth[rID_][H1],
                players_[msg.sender].eth[rID_][H2],
                players_[msg.sender].eth[rID_][H3],
                players_[msg.sender].eth[rID_][H4]
            ],
            [
                players_[msg.sender].carrots[rID_][H1],
                players_[msg.sender].carrots[rID_][H2],
                players_[msg.sender].carrots[rID_][H3],
                players_[msg.sender].carrots[rID_][H4]
            ],
            [
                horses_[H1].name,
                horses_[H2].name,
                horses_[H3].name,
                horses_[H4].name
            ]
        );
    }

    /**
     * @dev get minimal details about a specific round (returns all 0s if round not over)
     * @param _round which round to query
     * @return horse that won
     * @return eth for each horse
     * @return carrots for each horse
     * @return eth invested for each horse
     * @return carrots invested for each horse
     */
    function getPastRoundStats(uint256 _round) 
        public
        view
        returns(uint8, uint256[4], uint256[4], uint256[4], uint256[4])
    {
        if ((_round == 0) || (_round > rID_) || (_round == rID_ && !isRoundOver())) {
            return;
        }
        return
        (
            rounds_[rID_].winner,
            [
                rounds_[_round].eth[H1],
                rounds_[_round].eth[H2],
                rounds_[_round].eth[H3],
                rounds_[_round].eth[H4]
            ],
            [
                rounds_[_round].carrots[H1],
                rounds_[_round].carrots[H2],
                rounds_[_round].carrots[H3],
                rounds_[_round].carrots[H4]
            ],
            [
                players_[msg.sender].eth[_round][H1],
                players_[msg.sender].eth[_round][H2],
                players_[msg.sender].eth[_round][H3],
                players_[msg.sender].eth[_round][H4]
            ],
            [
                players_[msg.sender].carrots[_round][H1],
                players_[msg.sender].carrots[_round][H2],
                players_[msg.sender].carrots[_round][H3],
                players_[msg.sender].carrots[_round][H4]
            ]
        );
    }

    /**
     * @dev get stats for player
     * @return total winnings
     * @return total dividends
     * @return total referral bonus
     * @return total reinvested
     * @return total withdrawn
     */
    function getPlayerStats()
        public 
        view
        returns(uint256, uint256, uint256, uint256, uint256)
    {
        return
        (
            calcPlayerWinnings(),
            calcPlayerDividends(),
            calcPlayerReferrals(),
            players_[msg.sender].totalReinvested,
            players_[msg.sender].totalWithdrawn
        );
    }

    /**
     * @dev get name of player
     * @return players registered name if there is one
     */
    function getPlayerName()
      public
      view
      returns(bytes32)
    {
        return players_[msg.sender].name;
    }

    /**
     * @dev check if name is available
     * @param _name name to check
     * @return bool whether or not it is available
     */
    function isNameAvailable(bytes32 _name)
      public
      view
      returns(bool)
    {
        return registeredNames_[_name] == 0;
    }

    /**
     * @dev get overall stats for EtherDerby
     * @return total eth for each horse
     * @return total carrots for each horse
     * @return player total eth for each horse
     * @return player total carrots for each horse
     * @return horse names
     */
    function getStats()
        public
        view
        returns(uint256[4], uint256[4], uint256[4], uint256[4], bytes32[4])
    {
        return
        (
            [
                horses_[H1].totalEth,
                horses_[H2].totalEth,
                horses_[H3].totalEth,
                horses_[H4].totalEth
            ],
            [
                horses_[H1].totalCarrots,
                horses_[H2].totalCarrots,
                horses_[H3].totalCarrots,
                horses_[H4].totalCarrots
            ],
            [
                players_[msg.sender].totalEth[H1],
                players_[msg.sender].totalEth[H2],
                players_[msg.sender].totalEth[H3],
                players_[msg.sender].totalEth[H4]
            ],
            [
                players_[msg.sender].totalCarrots[H1],
                players_[msg.sender].totalCarrots[H2],
                players_[msg.sender].totalCarrots[H3],
                players_[msg.sender].totalCarrots[H4]
            ],
            [
                horses_[H1].name,
                horses_[H2].name,
                horses_[H3].name,
                horses_[H4].name
            ]
        );
    }

    /**
     * @dev returns data for past 50 rounds
     * @param roundStart which round to start returning data at (0 means current)
     * @return round number this index in the arrays corresponds to
     * @return winning horses for past 50 finished rounds
     * @return horse1 carrot amounts for past 50 rounds
     * @return horse2 carrot amounts for past 50 rounds
     * @return horse3 carrot amounts for past 50 rounds
     * @return horse4 carrot amounts for past 50 rounds
     * @return horse1 players carrots for past 50 rounds
     * @return horse2 players carrots for past 50 rounds
     * @return horse3 players carrots for past 50 rounds
     * @return horse4 players carrots for past 50 rounds
     * @return horseEth total eth amounts for past 50 rounds
     * @return playerEth total player eth amounts for past 50 rounds
     */
    function getPastRounds(uint256 roundStart)
        public
        view
        returns(
            uint256[50] roundNums,
            uint8[50] winners,
            uint256[50] horse1Carrots,
            uint256[50] horse2Carrots,
            uint256[50] horse3Carrots,
            uint256[50] horse4Carrots,
            uint256[50] horse1PlayerCarrots,
            uint256[50] horse2PlayerCarrots,
            uint256[50] horse3PlayerCarrots,
            uint256[50] horse4PlayerCarrots,
            uint256[50] horseEth,
            uint256[50] playerEth
        )
    {
        uint256 index = 0;
        uint256 round = rID_;
        if (roundStart != 0 && roundStart <= rID_) {
            round = roundStart;
        }
        while (index < 50 && round > 0) {
            if (round == rID_ && !isRoundOver()) {
                round--;
                continue;
            }
            roundNums[index] = round;
            winners[index] = rounds_[round].winner;
            horse1Carrots[index] = rounds_[round].carrots[H1];
            horse2Carrots[index] = rounds_[round].carrots[H2];
            horse3Carrots[index] = rounds_[round].carrots[H3];
            horse4Carrots[index] = rounds_[round].carrots[H4];
            horse1PlayerCarrots[index] = players_[msg.sender].carrots[round][H1];
            horse2PlayerCarrots[index] = players_[msg.sender].carrots[round][H2];
            horse3PlayerCarrots[index] = players_[msg.sender].carrots[round][H3];
            horse4PlayerCarrots[index] = players_[msg.sender].carrots[round][H4];
            horseEth[index] = rounds_[round].eth[H1]
                .add(rounds_[round].eth[H2])
                .add(rounds_[round].eth[H3])
                .add(rounds_[round].eth[H4]);
            playerEth[index] = players_[msg.sender].eth[round][H1]
                .add(players_[msg.sender].eth[round][H2])
                .add(players_[msg.sender].eth[round][H3])
                .add(players_[msg.sender].eth[round][H4]);
            index++;
            round--;
        }
    }

    /**
     * @dev calculate price of buying carrots for a specific horse
     * @param _horse which horse to calculate price for
     * @param _carrots how many carrots desired
     * @return ETH required to purchase X many carrots
     */
    function getPriceOfXCarrots(uint8 _horse, uint256 _carrots)
        public
        view
        isValidHorse(_horse)
        returns(uint256)
    {
        return calculateCurrentPrice(_horse, _carrots.mul(1000000000000000000));
    }

    /**
     * @dev calculate price to become majority carrot holder for a specific horse
     * @param _horse which horse to calculate price for
     * @return carrotsRequired
     * @return ethRequired
     * @return currentMax
     * @return owner
     * @return ownerName
     */
    function getPriceToName(uint8 _horse)
        public
        view
        isValidHorse(_horse)
        returns(
            uint256 carrotsRequired,
            uint256 ethRequired,
            uint256 currentMax,
            address owner,
            bytes32 ownerName
        )
    {
        if (players_[msg.sender].totalCarrots[_horse] < horses_[_horse].mostCarrotsOwned) {
            // player is not already majority holder
            // Have user buy one carrot more than current max
            carrotsRequired = horses_[_horse].mostCarrotsOwned.sub(players_[msg.sender].totalCarrots[_horse]).add(10**DECIMALS);
            ethRequired = calculateCurrentPrice(_horse, carrotsRequired);
        }
        currentMax = horses_[_horse].mostCarrotsOwned;
        owner = horses_[_horse].owner;
        ownerName = players_[horses_[_horse].owner].name;
    }
}


//   __   _   ___ ___  _ ___    __   _   _   __  _ _  _     _  ___ _  ___
//  / _| / \ | o \ o \/ \_ _|  / _| / \ | | / _|| | || |   / \|_ _/ \| o \
// ( (_ | o ||   /   ( o ) |  ( (_ | o || |( (_ | U || |_ | o || ( o )   /
//  \__||_n_||_|\\_|\\\_/|_|   \__||_n_||___\__||___||___||_n_||_|\_/|_|\\
//
library CalcCarrots {
    using SafeMath for *;

    /**
     * @dev calculates number of carrots recieved given X eth
     */
    function carrotsReceived(uint256 _currEth, uint256 _newEth)
        internal
        pure
        returns (uint256)
    {
        return carrots((_currEth).add(_newEth)).sub(carrots(_currEth));
    }

    /**
     * @dev calculates amount of eth received if you sold X carrots
     */
    function ethReceived(uint256 _currCarrots, uint256 _sellCarrots)
        internal
        pure
        returns (uint256)
    {
        return eth(_currCarrots).sub(eth(_currCarrots.sub(_sellCarrots)));
    }

    /**
     * @dev calculates how many carrots for a single horse given an amount
     * of eth spent on that horse
     */
    function carrots(uint256 _eth)
        internal
        pure
        returns (uint256)
    {
        return ((((_eth).mul(62831853072000000000000000000000000000000000000)
            .add(9996858654086510028837239824000000000000000000000000000000000000)).sqrt())
            .sub(99984292036732000000000000000000)) / (31415926536);
    }

    /**
     * @dev calculates how much eth would be in the contract for a single
     * horse given an amount of carrots bought for that horse
     */
    function eth(uint256 _carrots)
        internal
        pure
        returns (uint256)
    {
        return ((15707963268).mul(_carrots.mul(_carrots)).add(((199968584073464)
            .mul(_carrots.mul(1000000000000000000))) / (2))) / (1000000000000000000000000000000000000);
    }
}


//  __  _   ___  ___   _   _   _  ___  _ _
// / _|/ \ | __|| __| | \_/ | / \|_ _|| U |
// \_ \ o || _| | _|  | \_/ || o || | |   |
// |__/_n_||_|  |___| |_| |_||_n_||_| |_n_|
//

/**
 * @title SafeMath library from OpenZeppelin
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

    /**
     * @dev Gives square root of given x.
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
}

library SafeConversions {
    function SafeSigned(uint256 a) internal pure returns (int256) {
        int256 b = int256(a);
        // If a is too large, the signed version will be negative.
        assert(b >= 0);
        return b;
    }

    function SafeUnsigned(int256 a) internal pure returns (uint256) {
        // Only negative numbers are unsafe to make unsigned.
        assert(a >= 0);
        return uint256(a);
    }
}

library NameValidator {
    /**
     * @dev throws on invalid name
     * -converts uppercase to lower case
     * -cannot contain space
     * -cannot be only numbers
     * -cannot be an address (start with 0x)
     * -restricts characters to A-Z, a-z, 0-9
     * @return validated string in bytes32 format
     */
    function validate(string _input)
        internal
        pure
        returns(bytes32)
    {
        bytes memory temp = bytes(_input);
        uint256 length = temp.length;
        
        // limited to 15 characters
        require (length <= 15 && length > 0, "name must be between 1 and 15 characters");
        // cannot be an address
        if (temp[0] == 0x30) {
            require(temp[1] != 0x78, "name cannot start with 0x");
            require(temp[1] != 0x58, "name cannot start with 0X");
        }
        bool _hasNonNumber;
        for (uint256 i = 0; i < length; i++) {
            // if its uppercase A-Z
            if (temp[i] > 0x40 && temp[i] < 0x5b) {
                // convert to lower case
                temp[i] = byte(uint(temp[i]) + 32);
                // character is non number
                if (_hasNonNumber == false) {
                    _hasNonNumber = true;
                }
            } else {
                // character should be only lowercase a-z or 0-9
                require ((temp[i] > 0x60 && temp[i] < 0x7b) || (temp[i] > 0x2f && temp[i] < 0x3a), "name contains invalid characters");

                // check if character is non number 
                if (_hasNonNumber == false && (temp[i] < 0x30 || temp[i] > 0x39)) {
                    _hasNonNumber = true;    
                }
            }
        }
        require(_hasNonNumber == true, "name cannot be only numbers");
        bytes32 _ret;
        assembly {
            _ret := mload(add(temp, 32))
        }
        return (_ret);
    }
}