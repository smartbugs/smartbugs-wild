pragma solidity ^0.4.24;


/**
 * @title SafeMath v0.1.9
 * @dev Math operations with safety checks that throw on error
 * change notes:  original SafeMath library from OpenZeppelin modified by Inventor
 * - added sqrt
 * - added sq
 * - added pwr
 * - changed asserts to requires with error log outputs
 * - removed div, its useless
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



//==============================================================================
//   __|_ _    __|_ _  .
//  _\ | | |_|(_ | _\  .
//==============================================================================
library F3Ddatasets {
    struct Referee {
        uint256 pID;
        uint256 offer;
    }
    
    struct EventReturns {
        address winnerBigPotAddr;         // winner address
        uint256 amountWonBigPot;          // amount won

        address winnerSmallPotAddr;         // winner address
        uint256 amountWonSmallPot;          // amount won

        uint256 newPot;             // amount in new pot
        uint256 P3DAmount;          // amount distributed to p3d
        uint256 genAmount;          // amount distributed to key money sharer
        uint256 potAmount;          // amount added to pot
    }

    struct PlayerVault {
        address addr;   // player address
        uint256 winBigPot;    // winnings vault
        uint256 winSmallPot;    // winnings vault
        uint256 gen;    // general vault
        uint256 aff;    // affiliate vault
        uint256 lrnd;
    }

    struct PlayerRound {
        uint256 eth;    // eth player has added to round (used for eth limiter)
        uint256 auc;    // auction phase investment
        uint256 keys;   // keys
        uint256 mask;   // player mask
        uint256 refID;  // referal right ID -- 推荐权利 ID
    }

    struct SmallPot {
        uint256 plyr;   // pID of player in lead for Small pot
        uint256 end;    // time ends/ended
        uint256 strt;   // time round started
        uint256 pot;     // eth to pot (during round) / final amount paid to winner (after round ends)
        uint256 keys;   // keys
        uint256 eth;   // total eth
        bool on;     // has round end function been ran
    }

    struct BigPot {
        uint256 plyr;   // pID of player in lead for Big pot
        uint256 end;    // time ends/ended
        uint256 strt;   // time round started
        uint256 keys;   // keys
        uint256 eth;    // total eth in
        uint256 gen;
        uint256 mask;
        uint256 pot;    // eth to pot (during round) / final amount paid to winner (after round ends)
        bool ended;     // has round end function been ran
    }


    struct Auction {
        // auction phase
        bool isAuction; // true: auction; false: bigPot
        uint256 end;    // time ends/ended
        uint256 strt;   // time round started
        uint256 eth;    // total eth sent in during AUC phase
        uint256 gen; // total eth for gen during AUC phase
        uint256 keys;   // keys
        // uint256 eth;    // total eth in
        // uint256 mask;   // global mask
    }
}

//==============================================================================
//  |  _      _ _ | _  .
//  |<(/_\/  (_(_||(_  .
//=======/======================================================================
library F3DKeysCalcShort {
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

//==============================================================================
//  . _ _|_ _  _ |` _  _ _  _  .
//  || | | (/_| ~|~(_|(_(/__\  .
//==============================================================================


interface PlayerBookInterface {
    function getPlayerID(address _addr) external returns (uint256);
    function getPlayerAddr(uint256 _pID) external view returns (address);
}



contract F3Devents {
    event eventAuction(
        string funName,
        uint256 round,
        uint256 plyr,
        uint256 money,
        uint256 keyPrice,
        uint256 plyrEth,
        uint256 plyrAuc,
        uint256 plyrKeys,
        uint256 aucEth,
        uint256 aucKeys
    );

    event onPot(
        uint256 plyrBP, // pID of player in lead for Big pot
        uint256 ethBP,
        uint256 plyrSP, // pID of player in lead for Small pot
        uint256 ethSP   // eth to pot (during round) / final amount paid to winner (after round ends)
    );

}


contract FoMo3DFast is F3Devents {
    using SafeMath for *;
    //    using F3DKeysCalcShort for uint256;
    //
    PlayerBookInterface constant private PlayerBook = PlayerBookInterface(0x2C0C48F27350b50ede309BFC7E2349BbEb0aCC72);

    address private admin = msg.sender;
    uint256 private prepareTime = 30 minutes;
    uint256 private aucDur = 120 minutes;     // length of the very first auc
    uint256 constant private rndInc_ = 360 minutes;              // every full key purchased adds 6hrs to timer
    uint256 constant private smallTime_ = 5 minutes;              // small time, small pot time
    uint256 constant private rndMax_ = 10080 minutes;                // max length a round timer can be, 1 week
    uint256 public rID_;    // round id number / total rounds that have happened
    uint256 constant public keyPriceAuc_ = 5000000000000000;
    uint256 constant public keyPricePot_ = 10000000000000000;
    //****************
    // PLAYER DATA
    //****************
    mapping(address => uint256) public pIDxAddr_;          // (addr => pID) returns player id by address
    mapping(uint256 => F3Ddatasets.PlayerVault) public plyr_;   // (pID => data) player data
    // (pID => rID => data) player round data by player id & round id
    mapping(uint256 => mapping(uint256 => F3Ddatasets.PlayerRound)) public plyrRnds_;
    //****************
    // ROUND DATA
    //****************
    mapping(uint256 => F3Ddatasets.Auction) public auction_;   // (rID => data) round data
    mapping(uint256 => F3Ddatasets.BigPot) public bigPot_;   // (rID => data) round data
    F3Ddatasets.SmallPot public smallPot_;   // (rID => data) round data
    mapping(uint256 => uint256) public rndTmEth_;      // (rID => tID => data) eth in per team, by round id and team id


    // referee  (rID => referee[] data)
    mapping(uint256 => F3Ddatasets.Referee[]) public referees_;
    uint256 minOfferValue_;
    uint256 constant referalSlot_ = 2;

    constructor()
    public
    {

    }
    //==============================================================================
    //     _ _  _  _|. |`. _  _ _  .
    //    | | |(_)(_||~|~|(/_| _\  .  (these are safety checks)
    //==============================================================================
    /**
    * @dev used to make sure no one can interact with contract until it has
    * been activated.
    */
    modifier isActivated() {
        require(activated_ == true, "its not ready yet.  check ?eta in discord");
        _;
    }

    /**
    * @dev prevents contracts from interacting with fomo3d
    */
    modifier isHuman() {
        address _addr = msg.sender;
        uint256 _codeLength;

        assembly {_codeLength := extcodesize(_addr)}
        require(_codeLength == 0, "sorry humans only");
        _;
    }

    /**
    * @dev sets boundaries for incoming tx
    */
    modifier isWithinLimits(uint256 _eth) {
        require(_eth >= 1000000000, "pocket lint: not a valid currency");
        _;
    }

    //==============================================================================
    //     _    |_ |. _   |`    _  __|_. _  _  _  .
    //    |_)|_||_)||(_  ~|~|_|| |(_ | |(_)| |_\  .  (use these to interact with contract)
    //====|=========================================================================
    /**
    * @dev emergency buy uses last stored affiliate ID and team snek
    */
    function()
    isActivated()
    isHuman()
    isWithinLimits(msg.value)
    public
    payable
    {
        // get/set pID for current player
        determinePID();

        // fetch player id
        uint256 _pID = pIDxAddr_[msg.sender];
        uint256 _now = now;
        uint256 _rID = rID_;

        if (_now > auction_[_rID].strt && _now < auction_[_rID].end)
        {
            // Auction phase
            buyAuction(_pID);
        } else if (_now > bigPot_[_rID].strt && _now < bigPot_[_rID].end) {
            // Round(big pot) phase
            buy(_pID, 9999);
        } else {
            // check to see if end round needs to be ran
            if (_now > bigPot_[_rID].end && bigPot_[_rID].ended == false)
            {
                // end the round (distributes pot) & start new round
                bigPot_[_rID].ended = true;
                endRound();
            }

            // put eth in players vault
            plyr_[_pID].gen = msg.value.add(plyr_[_pID].gen);
        }
    }

    function buyXQR(address senderAddr, uint256 _affID)
    isActivated()
    isWithinLimits(msg.value)
    public
    payable
    {
        // get/set pID for current player
        determinePID();

        // fetch player id
        uint256 _pID = pIDxAddr_[senderAddr];
        uint256 _now = now;
        uint256 _rID = rID_;

        if (_now > auction_[_rID].strt && _now < auction_[_rID].end)
        {
            // Auction phase
            buyAuction(_pID);
        } else if (_now > bigPot_[_rID].strt && _now < bigPot_[_rID].end) {
            // Round(big pot) phase
            buy(_pID, _affID);
        } else {
            // check to see if end round needs to be ran
            if (_now > bigPot_[_rID].end && bigPot_[_rID].ended == false)
            {
                // end the round (distributes pot) & start new round
                bigPot_[_rID].ended = true;
                endRound();
            }

            // put eth in players vault
            plyr_[_pID].gen = plyr_[_pID].gen.add(msg.value);
        }
    }

    function endRound()
    private
    {
        // setup local rID
        uint256 _rID = rID_;

        // grab our winning player and team id's
        uint256 _winPID = bigPot_[_rID].plyr;

        // grab our pot amount
        uint256 _win = bigPot_[_rID].pot;
        // 10000000000000000000 10个ether

        // pay our winner bigPot
        plyr_[_winPID].winBigPot = _win.add(plyr_[_winPID].winBigPot);

        // pay smallPot
        uint256 _currentPot = smallPot_.eth;
        if (smallPot_.on == true) {
            uint256 _winSmallPot = smallPot_.pot;
            uint256 _surplus = _currentPot.sub(_winSmallPot);
            smallPot_.on = false;
            smallPot_.keys = 0;
            smallPot_.eth = 0;
            smallPot_.pot = 0;
            smallPot_.plyr = 0;
            plyr_[_winPID].winSmallPot = _winSmallPot.add(plyr_[_winPID].winSmallPot);
            if (_surplus > 0) {
                plyr_[1].winSmallPot = _surplus.add(plyr_[1].winSmallPot);
            }
        } else {
            if (_currentPot > 0) {
                plyr_[1].winSmallPot = _currentPot.add(plyr_[1].winSmallPot);
            }
        }


        // start next round
        rID_++;
        _rID++;
        uint256 _now = now;
        auction_[_rID].strt = _now;
        auction_[_rID].end = _now + aucDur;

        bigPot_[_rID].strt = _now + aucDur;
        bigPot_[_rID].end = _now + aucDur + rndMax_;
    }

    function withdrawXQR(address _realSender)
    payable
    isActivated()
    public
    {
        // setup local rID
        uint256 _rID = rID_;

        // grab time
        uint256 _now = now;

        // fetch player ID
        uint256 _pID = pIDxAddr_[_realSender];

        // setup temp var for player eth
        uint256 _eth;

        // check to see if round has ended and no one has run round end yet
        if (_now > bigPot_[_rID].end && bigPot_[_rID].ended == false && bigPot_[_rID].plyr != 0)
        {
            // end the round (distributes pot)
            bigPot_[_rID].ended = true;
            endRound();

            // get their earnings
            _eth = withdrawEarnings(_pID);

            // gib moni
            if (_eth > 0)
                plyr_[_pID].addr.transfer(_eth);

            // in any other situation
        } else {
            // get their earnings
            _eth = withdrawEarnings(_pID);

            // gib moni
            if (_eth > 0)
                plyr_[_pID].addr.transfer(_eth);

        }
    }

    function withdrawEarnings(uint256 _pID)
    private
    returns (uint256)
    {
        updateGenVault(_pID, plyr_[_pID].lrnd);
        // from vaults
        uint256 _earnings = (plyr_[_pID].winBigPot).add(plyr_[_pID].winSmallPot).add(plyr_[_pID].gen).add(plyr_[_pID].aff);
        if (_earnings > 0)
        {
            plyr_[_pID].winBigPot = 0;
            plyr_[_pID].winSmallPot = 0;
            plyr_[_pID].gen = 0;
            plyr_[_pID].aff = 0;
        }
        return (_earnings);
    }

    function updateGenVault(uint256 _pID, uint256 _rIDlast)
        private 
    {
        uint256 _earnings = calcUnMaskedEarnings(_pID, _rIDlast);
        if (_earnings > 0)
        {
            // put in gen vault
            plyr_[_pID].gen = _earnings.add(plyr_[_pID].gen);
            // zero out their earnings by updating mask
            plyrRnds_[_pID][_rIDlast].mask = _earnings.add(plyrRnds_[_pID][_rIDlast].mask);
        }
    }

    function calcUnMaskedEarnings(uint256 _pID, uint256 _rIDlast)
        private
        view
        returns(uint256)
    {
        return( (((bigPot_[_rIDlast].mask).mul(plyrRnds_[_pID][_rIDlast].keys)) / (1000000000000000000)).sub(plyrRnds_[_pID][_rIDlast].mask) );
    }

    function managePlayer(uint256 _pID)
        private
    {
        // if player has played a previous round, move their unmasked earnings
        // from that round to gen vault.
        if (plyr_[_pID].lrnd != 0)
            updateGenVault(_pID, plyr_[_pID].lrnd);
            
        // update player's last round played
        plyr_[_pID].lrnd = rID_;
    }


    function buyAuction(uint256 _pID)
    private
    {
        // setup local variables
        uint256 _rID = rID_;
        uint256 _keyPrice = keyPriceAuc_;

        // 加入未统计的分钥匙的钱
        if (plyrRnds_[_pID][_rID].keys == 0)
            managePlayer(_pID);
        
        // update bigPot leader
        bigPot_[_rID].plyr = _pID;

        uint256 _eth = msg.value;
        // calculate keys purchased
        uint256 _keys = _eth / _keyPrice;

        // plry {eth, auc, keys}
        plyrRnds_[_pID][_rID].eth = _eth.add(plyrRnds_[_pID][_rID].eth);
        plyrRnds_[_pID][_rID].auc = _eth.add(plyrRnds_[_pID][_rID].auc);
        plyrRnds_[_pID][_rID].keys = _keys.add(plyrRnds_[_pID][_rID].keys);

        uint256 plyrEth = plyrRnds_[_pID][_rID].eth;
        uint256 plyrAuc = plyrRnds_[_pID][_rID].auc;
        uint256 plyrKeys = plyrRnds_[_pID][_rID].keys;

        // auction {eth, keys}
        auction_[_rID].eth = auction_[_rID].eth.add(_eth);
        auction_[_rID].keys = auction_[_rID].keys.add(_keys);
        uint256 aucEth = auction_[_rID].eth;
        uint256 aucKeys = auction_[_rID].keys;

        emit eventAuction
        (
            "buyFunction",
            _rID,
            _pID,
            _eth,
            _keyPrice,
            plyrEth,
            plyrAuc,
            plyrKeys,
            aucEth,
            aucKeys
        );

        // update round
        refereeCore(_pID, plyrRnds_[_pID][_rID].auc);

        // 分钱
        distributeAuction(_rID, _eth);
    }

    function distributeAuction(uint256 _rID, uint256 _eth)
    private
    {
        // pay 50% out to team
        uint256 _team = _eth / 2;
        uint256 _pot = _eth.sub(_team);
        // 50% to big Pot
        uint256 _bigPot = _pot / 2;
        // 50% to small Pot
        uint256 _smallPot = _pot / 2;

        // pay out p3d
        admin.transfer(_team);

        // move money to Pot
        bigPot_[_rID].pot = bigPot_[_rID].pot.add(_bigPot);
        smallPot_.pot = smallPot_.pot.add(_smallPot);
        emit onPot(bigPot_[_rID].plyr, bigPot_[_rID].pot, smallPot_.plyr, smallPot_.pot);
    }

    function buy(uint256 _pID, uint256 _affID)
    private
    {
        // setup local rID
        uint256 _rID = rID_;
        uint256 _keyPrice = keyPricePot_;

        if (plyrRnds_[_pID][_rID].keys == 0)
            managePlayer(_pID);

        uint256 _eth = msg.value;

        uint256 _keys = _eth / _keyPrice;

        if (_eth > 1000000000)
        {
            // if they bought at least 1 whole key
            if (_eth >= 1000000000000000000)
            {
                updateTimer(_eth, _rID);
                // set new leaders
                if (bigPot_[_rID].plyr != _pID)
                    bigPot_[_rID].plyr = _pID;
            }


            // update round
            bigPot_[_rID].keys = _keys.add(bigPot_[_rID].keys);
            bigPot_[_rID].eth = _eth.add(bigPot_[_rID].eth);

            // update player
            plyrRnds_[_pID][_rID].keys = _keys.add(plyrRnds_[_pID][_rID].keys);
            plyrRnds_[_pID][_rID].eth = _eth.add(plyrRnds_[_pID][_rID].eth);

            // key sharing earnings
            uint256 _gen = _eth.mul(6) / 10;
            updateMasks(_rID, _pID, _gen, _keys);
            // if (_dust > 0)
            //     _gen = _gen.sub(_dust);

            distributeBuy(_rID, _eth, _affID);
            smallPot();
        }
    }

    function updateMasks(uint256 _rID, uint256 _pID, uint256 _gen, uint256 _keys)
        private
        returns(uint256)
    {
        // calc profit per key & round mask based on this buy:  (dust goes to pot)
        uint256 _ppt = (_gen.mul(1000000000000000000)) / (bigPot_[_rID].keys);
        bigPot_[_rID].mask = _ppt.add(bigPot_[_rID].mask); 
            
        // calculate player earning from their own buy (only based on the keys
        // they just bought).  & update player earnings mask
        uint256 _pearn = (_ppt.mul(_keys)) / (1000000000000000000);
        plyrRnds_[_pID][_rID].mask = (((bigPot_[_rID].mask.mul(_keys)) / (1000000000000000000)).sub(_pearn)).add(plyrRnds_[_pID][_rID].mask);
        
        // calculate & return dust
        return(_gen.sub((_ppt.mul(bigPot_[_rID].keys)) / (1000000000000000000)));
    }

    function distributeBuy(uint256 _rID, uint256 _eth, uint256 _affID)
    private
    {
        // pay 10% out to team
        uint256 _team = _eth / 10;
        // 10% to aff
        uint256 _aff = _eth / 10;
        if (_affID == 9999) {
            _team = _team.add(_aff);
            _aff = 0;
        }

        // 10% to big Pot
        uint256 _bigPot = _eth / 10;
        // 10% to small Pot
        uint256 _smallPot = _eth / 10;

        // pay out team
        admin.transfer(_team);

        if (_aff != 0) {
            // 通过 affID 得到 推荐玩家pID， 并将_aff驾到 pID玩家的 aff中
            uint256 affPID = referees_[_rID][_affID].pID;
            plyr_[affPID].aff = _aff.add(plyr_[affPID].aff);
        }

        // move money to Pot
        bigPot_[_rID].pot = bigPot_[_rID].pot.add(_bigPot);
        smallPot_.pot = smallPot_.pot.add(_smallPot);

        emit onPot(bigPot_[_rID].plyr, bigPot_[_rID].pot, smallPot_.plyr, smallPot_.pot);
    }

    function smallPot()
    private
    {
        uint256 _now = now;

        if (smallPot_.on == false && smallPot_.keys >= (1000)) {
            smallPot_.on = true;
            smallPot_.pot = smallPot_.eth;
            smallPot_.strt = _now;
            smallPot_.end = _now + smallTime_;
        } else if (smallPot_.on == true && _now > smallPot_.end) {
            uint256 _winSmallPot = smallPot_.pot;
            uint256 _currentPot = smallPot_.eth;
            uint256 _surplus = _currentPot.sub(_winSmallPot);
            uint256 _winPID = smallPot_.plyr;
            smallPot_.on = false;
            smallPot_.keys = 0;
            smallPot_.eth = 0;
            smallPot_.pot = 0;
            smallPot_.plyr = 0;
            plyr_[_winPID].winSmallPot = _winSmallPot.add(plyr_[_winPID].winSmallPot);
            if (_surplus > 0) {
                plyr_[1].winSmallPot = _surplus.add(plyr_[1].winSmallPot);
            }
        }
    }

    event onBigPot(
        string eventname,
        uint256 rID,
        uint256 plyr, // pID of player in lead for Big pot
    // big pot phase
        uint256 end, // time ends/ended
        uint256 strt, // time round started
        uint256 eth, // eth to pot (during round) / final amount paid to winner (after round ends)
        uint256 keys, // eth to pot (during round) / final amount paid to winner (after round ends)
        bool ended     // has round end function been ran
    );

    function updateTimer(uint256 _keys, uint256 _rID)
    private
    {
        emit onBigPot
        (
            "updateTimer_start:",
            _rID,
            bigPot_[_rID].plyr,
            bigPot_[_rID].end,
            bigPot_[_rID].strt,
            bigPot_[_rID].eth,
            bigPot_[_rID].keys,
            bigPot_[_rID].ended
        );
        // grab time
        uint256 _now = now;

        // calculate time based on number of keys bought
        uint256 _newTime;
        if (_now > bigPot_[_rID].end && bigPot_[_rID].plyr == 0)
            _newTime = (((_keys) / (1000000000000000000)).mul(rndInc_)).add(_now);
        else
            _newTime = (((_keys) / (1000000000000000000)).mul(rndInc_)).add(bigPot_[_rID].end);

        // compare to max and set new end time
        if (_newTime < (rndMax_).add(_now))
            bigPot_[_rID].end = _newTime;
        else
            bigPot_[_rID].end = rndMax_.add(_now);

        emit onBigPot
        (
            "updateTimer_end:",
            _rID,
            bigPot_[_rID].plyr,
            bigPot_[_rID].end,
            bigPot_[_rID].strt,
            bigPot_[_rID].eth,
            bigPot_[_rID].keys,
            bigPot_[_rID].ended
        );

    }

    event pidUpdate(address sender, uint256 pidOri, uint256 pidNew);

    function determinePID()
    private
    {

        uint256 _pID = pIDxAddr_[msg.sender];
        uint256 _pIDOri = _pID;
        // if player is new to this version of fomo3d
        if (_pID == 0)
        {
            // grab their player ID, name and last aff ID, from player names contract
            _pID = PlayerBook.getPlayerID(msg.sender);

            // set up player account
            pIDxAddr_[msg.sender] = _pID;
            plyr_[_pID].addr = msg.sender;

        }
        emit pidUpdate(msg.sender, _pIDOri, _pID);
    }


    function getPlayerIdxAddr(address _addr) public view returns (uint256){
        if (pIDxAddr_[_addr] == 0) {
            return pIDxAddr_[_addr];
        } else {
            return 0;
        }
    }


    function receivePlayerInfo(uint256 _pID, address _addr)
    external
    {
        require(msg.sender == address(PlayerBook), "your not playerNames contract... hmmm..");
        if (pIDxAddr_[_addr] != _pID)
            pIDxAddr_[_addr] = _pID;
        if (plyr_[_pID].addr != _addr)
            plyr_[_pID].addr = _addr;
    }

    event consolerefereeCore(
        uint256 _pID, uint256 _value, uint256 minOfferIndex, uint256 minOfferpID, uint256 minOfferValue
    );

    function refereeCore(uint256 _pID, uint256 _value) private {
        uint256 _rID = rID_;
        uint256 length_ = referees_[_rID].length;
        emit consolerefereeCore(_pID, _value, _rID, length_, minOfferValue_);
        if (_value > minOfferValue_) {

            uint256 minXvalue = _value;
            uint256 minXindex = 9999;
            uint256 flag = 1;

            // 找到当前玩家，不改变数组，更新玩家出价
            for (uint256 i = 0; i < referees_[_rID].length; i++) {
                if (_pID == referees_[_rID][i].pID) {
                    referees_[_rID][i].offer = _value;
                    flag = 0;
                    break;
                }
            }

            // 未找到当前玩家，则改变数组，更新玩家出价
            if (flag == 1) {
                emit consolerefereeCore(1111, minXindex, _rID, referees_[_rID].length, minXvalue);
                // 找到当前数组中最低出价及最低出价的index
                for (uint256 j = 0; j < referees_[_rID].length; j++) {
                    if (referees_[_rID][j].offer < minXvalue) {
                        minXvalue = referees_[_rID][j].offer;
                        emit consolerefereeCore(2222, minXindex, _rID, referees_[_rID].length, minXvalue);
                        minXindex = j;
                    }
                }
                emit consolerefereeCore(3333, minXindex, _rID, referees_[_rID].length, minXvalue);
                // 若数组未满， 则直接加入
                if (referees_[_rID].length < referalSlot_) {
                    referees_[_rID].push(F3Ddatasets.Referee(_pID, _value));
                } else {
                    // 替换最低出价
                    if (minXindex != 9999) {
                        referees_[_rID][minXindex].offer = _value;
                        referees_[_rID][minXindex].pID = _pID;
                        minOfferValue_ = _value;
                    }
                }
            }
        }
    }
    //==============================================================================
    //     _  _ _|__|_ _  _ _  .
    //    (_|(/_ |  | (/_| _\  . (for UI & viewing things on etherscan)
    //=====_|=======================================================================
    /**
    * @dev return the price buyer will pay for next 1 individual key.
    * -functionhash- 0x018a25e8
    * @return price for next key bought (in wei format)
    */
    // function getBuyPrice()
    // public
    // view
    // returns (uint256)
    // {
    //     if (now < round_[rID_].start) {
    //         // 当前轮游戏开始前
    //         return 5;
    //     } else if (now > round_[rID_].start && now < rndTmEth_[rID_]) {
    //         // 当前轮游戏进行中
    //         return 10;
    //     } else if (now > rndTmEth_[rID_]) {
    //         // 当前轮游戏已结束
    //         return 5;
    //     }
    // }

    function getTimeLeft() public
    view returns (uint256){
        return rndTmEth_[rID_] - now;
    }

    function getrID() public
    view returns (uint256){
        return rID_;
    }

    function getAdmin() public
    view returns (address){
        return admin;
    }

    //==============================================================================
    //    (~ _  _    _._|_    .
    //    _)(/_(_|_|| | | \/  .
    //====================/=========================================================
    /** upon contract deploy, it will be deactivated.  this is a one time
     * use function that will activate the contract.  we do this so devs
     * have time to set things up on the web end                            **/
    bool public activated_ = false;
    uint256  public end_ = 0;

    function activate()
    public
    {
        // only team just can activate
        require(msg.sender == admin, "only admin can activate");
        // can only be ran once
        require(activated_ == false, "FOMO Short already activated");

        // activate the contract
        activated_ = true;

        // lets start first round
        rID_ = 1;
        uint256 _now = now;

        auction_[1].strt = _now;
        auction_[1].end = _now + aucDur;

        bigPot_[1].strt = _now + aucDur;
        bigPot_[1].end = _now + aucDur + rndMax_;
    }

    function getAuctionTimer()
    public
    view
    returns (uint256, uint256, uint256, uint256, bool, uint256, uint256)
    {
        // setup local rID
        uint256 _rID = rID_;
        uint256 _now = now;
        return
        (
        _rID, //1
        auction_[_rID].strt,
        auction_[_rID].end,
        _now,
        _now > auction_[_rID].end,
        bigPot_[_rID].strt,
        bigPot_[_rID].end            //2
        );
    }


    // ================== 页面数据方法 start ======================

    // 获取当前轮auc数据
    function getCurrentRoundAucInfo()
    public
    view
    returns (uint256, bool, uint256, uint256, uint256, uint256, uint256, uint256)
    {
        // setup local rID
        uint256 _rID = rID_;
        uint256 _now = now;

        return
        (
        _rID, // round index
        // auc data
        auction_[_rID].isAuction, // true: auction; false: bigPot
        auction_[_rID].strt,
        auction_[_rID].end,
        auction_[_rID].end - _now,
        auction_[_rID].eth,
        auction_[_rID].gen,
        auction_[_rID].keys
        );
    }

    // 获取当前轮BigPot数据
    function getCurrentRoundBigPotInfo()
    public
    view
    returns (uint256, uint256, bool, uint256, uint256, uint256, uint256, uint256, uint256, uint256, address, uint256)
    {
        // setup local rID
        uint256 _rID = rID_;
        uint256 _now = now;
        uint256 _currentpID = bigPot_[_rID].plyr;
        uint256 _eth = bigPot_[_rID].eth;
        return
        (
        _rID, // round index
        // bitPot data
        _currentpID, // pID of player in lead for Big pot
        bigPot_[_rID].ended, // has round end function been ran
        bigPot_[_rID].strt, // time round started
        bigPot_[_rID].end, // time ends/ended
        bigPot_[_rID].end - _now,
        bigPot_[_rID].keys, // keys
        _eth, // total eth in
        _eth.mul(60) / 100,
        bigPot_[_rID].pot, // eth to pot (during round) / final amount paid to winner (after round ends)
        plyr_[_currentpID].addr, // current lead address
        keyPricePot_
        );
    }

    // 获取当前轮SmallPot数据
    function getSmallPotInfo()
    public
    view
    returns (uint256, uint256, bool, uint256, uint256, uint256, uint256, uint256, uint256, address)
    {
        // setup local rID
        uint256 _rID = rID_;
        uint256 _now = now;
        uint256 _currentpID = smallPot_.plyr;
        return
        (
        _rID, // round index
        // smallPot data
        _currentpID,
        smallPot_.on,
        smallPot_.strt,
        smallPot_.end,
        smallPot_.end - _now,
        smallPot_.keys,
        smallPot_.eth,
        smallPot_.pot,
        plyr_[_currentpID].addr // current lead address
        );
    }

    // 获取当前轮数据
    function getPlayerInfoxAddr()
    public
    view
    returns (uint256, uint256, uint256, uint256, uint256, uint256, uint256)
    {
        // setup local rID
        uint256 _rID = rID_;
        uint256 _pID = pIDxAddr_[msg.sender];
        return
        (_rID, //1
        _pID, //1
        plyrRnds_[_pID][_rID].eth,
        plyrRnds_[_pID][_rID].auc,
        plyrRnds_[_pID][_rID].keys,
        plyrRnds_[_pID][_rID].mask, //2
        plyrRnds_[_pID][_rID].refID //2
        );
    }

    // 获取用户钱包信息
    function getPlayerVaultxAddr()
    public
    view
    returns (uint256, address, uint256, uint256, uint256, uint256)
    {
        // setup local rID
        address addr = msg.sender;
        uint256 _pID = pIDxAddr_[addr];
        return
        (
        _pID, //1
        plyr_[_pID].addr,
        plyr_[_pID].winBigPot,
        plyr_[_pID].winSmallPot,
        plyr_[_pID].gen,
        plyr_[_pID].aff
        );
    }
    // ================== 页面数据方法 end ======================

    event consoleRef(uint256 index, uint256 pID, uint256 value);

    function getReferees()
    public
    payable
    {
        // setup local rID
        uint256 _rID = rID_;
        for (uint256 i = 0; i < referees_[_rID].length; i++) {
            emit consoleRef(i, referees_[_rID][i].pID, referees_[_rID][i].offer);
        }
    }

    function getPlayerInfoByAddress(address addr)
    public
    view
    returns (uint256, address, uint256, uint256, uint256, uint256, uint256, uint256, uint256, uint256, uint256, uint256)
    {
        // setup local rID
        uint256 _rID = rID_;
        address _addr = addr;

        if (_addr == address(0))
        {
            _addr == msg.sender;
        }
        uint256 _pID = pIDxAddr_[_addr];
        return
        (
        _pID, //0
        _addr, //1
        _rID, //2
        plyr_[_pID].winBigPot, //3
        plyr_[_pID].winSmallPot, //4
        plyr_[_pID].gen, //5
        plyr_[_pID].aff, //6
        plyrRnds_[_pID][_rID].keys, //7
        plyrRnds_[_pID][_rID].eth, //
        plyrRnds_[_pID][_rID].auc, //
        plyrRnds_[_pID][_rID].mask, //
        plyrRnds_[_pID][_rID].refID //
        );
    }

    function getPlayerInfoById(uint256 pID)
    public
    view
    returns (uint256, address, uint256, uint256, uint256, uint256, uint256, uint256, uint256, uint256, uint256, uint256)
    {
        // setup local rID
        uint256 _rID = rID_;
        uint256 _pID = pID;
        address _addr = msg.sender;
        return
        (
        _pID, //0
        _addr, //1
        _rID, //2
        plyr_[_pID].winBigPot, //3
        plyr_[_pID].winSmallPot, //4
        plyr_[_pID].gen, //5
        plyr_[_pID].aff, //6
        plyrRnds_[_pID][_rID].keys, //7
        plyrRnds_[_pID][_rID].eth, //
        plyrRnds_[_pID][_rID].auc, //
        plyrRnds_[_pID][_rID].mask, //
        plyrRnds_[_pID][_rID].refID //
        );
    }

}