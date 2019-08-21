pragma solidity ^0.4.24;

/**
 * @title -LuckyStar v0.0.1
 *
 * WARNING:  THIS PRODUCT IS HIGHLY ADDICTIVE.  IF YOU HAVE AN ADDICTIVE NATURE.  DO NOT PLAY.
 */

contract PlayerBook {
    using NameFilter for string;
    using SafeMath for *;
    address private admin = msg.sender;
    //address community=address(0x465b31ae487c4e6cede5f98a72472f1a6a81c826);
    uint256 public registrationFee_ = 10 finney;
    uint256 pIdx_=1;
    uint256 public pID_;        // total number of players
    mapping (address => uint256) public pIDxAddr_;          // (addr => pID) returns player id by address
    mapping (bytes32 => uint256) public pIDxName_;          // (name => pID) returns player id by name
    mapping (uint256 => LSDatasets.Player) public plyr_;   // (pID => data) player data
    mapping (uint256 => mapping (bytes32 => bool)) public plyrNames_; // (pID => name => bool) list of names a player owns.  (used so you can change your display name amongst any name you own)
    //mapping (uint256 => mapping (uint256 => bytes32)) public plyrNameList_; // (pID => nameNum => name) list of names a player owns
    modifier onlyOwner() {
        require(msg.sender == admin);
        _;
    }
    modifier isHuman() {
        address _addr = msg.sender;
        uint256 _codeLength;

        assembly {_codeLength := extcodesize(_addr)}
        require(_codeLength == 0, "sorry humans only");
        _;
    }
    function getPlayerID(address _addr)
    public
        returns (uint256)
    {
        determinePID(_addr);
        return (pIDxAddr_[_addr]);
    }
    function getPlayerName(uint256 _pID)
    public
        view
        returns (bytes32)
    {
        return (plyr_[_pID].name);
    }
    function getPlayerLAff(uint256 _pID)
    public
        view
        returns (uint256)
    {
        return (plyr_[_pID].laff);
    }
    function getPlayerAddr(uint256 _pID)
    public
        view
        returns (address)
    {
        return (plyr_[_pID].addr);
    }
    function getNameFee()
    public
        view
        returns (uint256)
    {
        return(registrationFee_);
    }
    function determinePID(address _addr)
        private
        returns (bool)
    {
        if (pIDxAddr_[_addr] == 0)
        {
            pID_++;
            pIDxAddr_[_addr] = pID_;
            plyr_[pID_].addr = _addr;

            // set the new player bool to true
            return (true);
        } else {
            return (false);
        }
    }
    function register(address _addr,uint256 _affID,bool _isSuper)  onlyOwner() public{
        bool _isNewPlayer = determinePID(_addr);
        bytes32 _name="LuckyStar";
        uint256 _pID = pIDxAddr_[_addr];
        plyr_[_pID].laff = _affID;
        registerNameCore(_pID, _addr, _affID, _name, _isNewPlayer);
    }
    function registerNameXname(string _nameString, bytes32 _affCode, bool _all)
        isHuman()
        public
        payable
    {
        require (msg.value >= registrationFee_, "umm.....  you have to pay the name fee");
        bytes32 _name = _nameString.nameFilter();
        address _addr = msg.sender;


        // set up our tx event data and determine if player is new or not
        bool _isNewPlayer = determinePID(_addr);

        // fetch player id
        uint256 _pID = pIDxAddr_[_addr];

        // manage affiliate residuals
        // if no affiliate code was given or player tried to use their own, lolz
        uint256 _affID;
        if (_affCode != "" && _affCode != _name)
        {
            // get affiliate ID from aff Code
            _affID = pIDxName_[_affCode];

            // if affID is not the same as previously stored
            if (_affID != plyr_[_pID].laff)
            {
                // update last affiliate
                plyr_[_pID].laff = _affID;
            }
        }

        // register name
        registerNameCore(_pID, _addr, _affID, _name, _isNewPlayer);
    }

    function registerNameCore(uint256 _pID, address _addr, uint256 _affID, bytes32 _name, bool _isNewPlayer)
        private
    {
        // if names already has been used, require that current msg sender owns the name
        if (pIDxName_[_name] != 0)
            require(plyrNames_[_pID][_name] == true, "sorry that names already taken");

        // add name to player profile, registry, and name book
        plyr_[_pID].name = _name;
        pIDxName_[_name] = _pID;
        if (plyrNames_[_pID][_name] == false)
        {
            plyrNames_[_pID][_name] = true;
        }

        // registration fee goes directly to community rewards
        //admin.transfer(address(this).balance);
        uint256 _paid=msg.value;
        //plyr_[pIdx_].aff=_paid.add(plyr_[pIdx_].aff);
        admin.transfer(_paid);

    }
    function setSuper(address _addr,bool isSuper) 
     onlyOwner()
     public{
        uint256 _pID=pIDxAddr_[_addr];
        if(_pID!=0){
            plyr_[_pID].super=isSuper;
        }else{
            revert();
        }
    }
    
    function setRegistrationFee(uint256 _fee)
      onlyOwner()
        public{
         registrationFee_ = _fee;
    }
}

contract LuckyStar is PlayerBook {
    using SafeMath for *;
    using NameFilter for string;
    using LSKeysCalcShort for uint256;

    

//==============================================================================
//     _ _  _  |`. _     _ _ |_ | _  _  .
//    (_(_)| |~|~|(_||_|| (_||_)|(/__\  .  (game settings)
//=================_|===========================================================
    address private admin = msg.sender;

    string constant public name = "LuckyStar";
    string constant public symbol = "LuckyStar";
    uint256 constant gen_=55;
    uint256 constant bigPrize_ =30;
    uint256 public minBuyForPrize_=100 finney;
    uint256 constant private rndInit_ = 3 hours;            // round timer starts at this  1H17m17s
    uint256 constant private rndInc_ = 1 minutes;              // every full key purchased adds this much to the timer
    uint256 constant private rndMax_ = 6 hours;             // max length a round timer can be  ；3Hours
    uint256 constant private prizeTimeInc_= 1 days;
    uint256 constant private stopTime_=1 hours;
//==============================================================================
//     _| _ _|_ _    _ _ _|_    _   .
//    (_|(_| | (_|  _\(/_ | |_||_)  .  (data used to store game info that changes)
//=============================|================================================
    uint256 public airDropPot_;             // person who gets the airdrop wins part of this pot
    uint256 public airDropTracker_ = 0;     // incremented each time a "qualified" tx occurs.  used to determine winning air drop
    uint256 public rID_;    // round id number / total rounds that have happened
//****************
// PLAYER DATA
//****************
    mapping (uint256 => uint256) public plyrOrders_; // plyCounter => pID
    mapping (uint256 => uint256) public plyrForPrizeOrders_; // playCounter => pID
    mapping (uint256 => mapping (uint256 => LSDatasets.PlayerRounds)) public plyrRnds_;    // (pID => rID => data) player round data by player id & round id

//****************
// ROUND DATA
//****************
    mapping (uint256 => LSDatasets.Round) public round_;   // (rID => data) round data
    mapping (uint256 => mapping(uint256 => uint256)) public rndTmEth_;      // (rID => tID => data) eth in per team, by round id and team id
//****************

//==============================================================================
//     _ _  _  __|_ _    __|_ _  _  .
//    (_(_)| |_\ | | |_|(_ | (_)|   .  (initial data setup upon contract deploy)
//==============================================================================
    constructor()
        public
    {
		pIDxAddr_[address(0xc7FcAD2Ad400299a7690d5aa6d7295F9dDB7Fc33)] = 1;
        plyr_[1].addr = address(0xc7FcAD2Ad400299a7690d5aa6d7295F9dDB7Fc33);
        plyr_[1].name = "sumpunk";
        plyr_[1].super=true;
        pIDxName_["sumpunk"] = 1;
        plyrNames_[1]["sumpunk"] = true;
        
        pIDxAddr_[address(0x2f52362c266c1Df356A2313F79E4bE4E7de281cc)] = 2;
        plyr_[2].addr = address(0x2f52362c266c1Df356A2313F79E4bE4E7de281cc);
        plyr_[2].name = "xiaokan";
        plyr_[2].super=true;
        pIDxName_["xiaokan"] = 2;
        plyrNames_[2]["xiaokan"] = true;
        
        pIDxAddr_[address(0xA97F850B019871B7a356956f8b43255988d1578a)] = 3;
        plyr_[3].addr = address(0xA97F850B019871B7a356956f8b43255988d1578a);
        plyr_[3].name = "Mr Shen";
        plyr_[3].super=true;
        pIDxName_["Mr Shen"] = 3;
        plyrNames_[3]["Mr Shen"] = true;
        
        pIDxAddr_[address(0x84408183fC70A65d378f720f4E95e4f9bD9EbeBE)] = 4;
        plyr_[4].addr = address(0x84408183fC70A65d378f720f4E95e4f9bD9EbeBE);
        plyr_[4].name = "4";
        plyr_[4].super=false;
        pIDxName_["4"] = 4;
        plyrNames_[4]["4"] = true;
        
        pIDxAddr_[address(0xa21E15d5933502DAD475daB3ed235fffFa537f85)] = 5;
        plyr_[5].addr = address(0xa21E15d5933502DAD475daB3ed235fffFa537f85);
        plyr_[5].name = "5";
        plyr_[5].super=true;
        pIDxName_["5"] = 5;
        plyrNames_[5]["5"] = true;
        
        pIDxAddr_[address(0xEb892446E9096a7e6e28B89EE416564E50504A68)] = 6;
        plyr_[6].addr = address(0xEb892446E9096a7e6e28B89EE416564E50504A68);
        plyr_[6].name = "6";
        plyr_[6].super=true;
        pIDxName_["6"] = 6;
        plyrNames_[6]["6"] = true;
        
        pIDxAddr_[address(0x75DF1440094346d4156cf4563a85dC5C564D2100)] = 7;
        plyr_[7].addr = address(0x75DF1440094346d4156cf4563a85dC5C564D2100);
        plyr_[7].name = "7";
        plyr_[7].super=true;
        pIDxName_["7"] = 7;
        plyrNames_[7]["7"] = true;
        
        pIDxAddr_[address(0xb00B860546F13268DC9Fa922B63342BC9C5a28a6)] = 8;
        plyr_[8].addr = address(0xb00B860546F13268DC9Fa922B63342BC9C5a28a6);
        plyr_[8].name = "8";
        plyr_[8].super=false;
        pIDxName_["8"] = 8;
        plyrNames_[8]["8"] = true;
        
        pIDxAddr_[address(0x9DC1bB8FDD15C9781d7D590B59E5DAFC0e37Cf3e)] = 9;
        plyr_[9].addr = address(0x9DC1bB8FDD15C9781d7D590B59E5DAFC0e37Cf3e);
        plyr_[9].name = "9";
        plyr_[9].super=false;
        pIDxName_["9"] = 9;
        plyrNames_[9]["9"] = true;
        
        pIDxAddr_[address(0x142Ba743cf9317eB54ba10c157870Af3cBb66bD3)] = 10;
        plyr_[10].addr = address(0x142Ba743cf9317eB54ba10c157870Af3cBb66bD3);
        plyr_[10].name = "10";
        plyr_[10].super=false;
        pIDxName_["10"] =10;
        plyrNames_[10]["10"] = true;
        
        pIDxAddr_[address(0x8B8F389Eb845eB0735D6eA084A3215d86Ed70344)] = 11;
        plyr_[11].addr = address(0x8B8F389Eb845eB0735D6eA084A3215d86Ed70344);
        plyr_[11].name = "11";
        plyr_[11].super=false;
        pIDxName_["11"] =11;
        plyrNames_[11]["11"] = true;
        
        pIDxAddr_[address(0x73974391d9B8Eae6F883503EffBc21E7dbAcf62c)] = 12;
        plyr_[12].addr = address(0x73974391d9B8Eae6F883503EffBc21E7dbAcf62c);
        plyr_[12].name = "12";
        plyr_[12].super=false;
        pIDxName_["12"] =12;
        plyrNames_[12]["12"] = true;
        
        pIDxAddr_[address(0xf1b9167F73847874AdD274FDFf4E1546CC184d03)] = 13;
        plyr_[13].addr = address(0xf1b9167F73847874AdD274FDFf4E1546CC184d03);
        plyr_[13].name = "13";
        plyr_[13].super=false;
        pIDxName_["13"] =13;
        plyrNames_[13]["13"] = true;
        
        pIDxAddr_[address(0x56948841d665A2903218018728979C0a8a47648A)] = 14;
        plyr_[14].addr = address(0x56948841d665A2903218018728979C0a8a47648A);
        plyr_[14].name = "14";
        plyr_[14].super=false;
        pIDxName_["14"] =14;
        plyrNames_[14]["14"] = true;
        
        pIDxAddr_[address(0x94bC531328e2b39C53B7D2EBb8461E794d7999A1)] = 15;
        plyr_[15].addr = address(0x94bC531328e2b39C53B7D2EBb8461E794d7999A1);
        plyr_[15].name = "15";
        plyr_[15].super=true;
        pIDxName_["15"] =15;
        plyrNames_[15]["15"] = true;
        
        pID_ = 15;
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
        require(_eth <= 100000000000000000000000, "no vitalik, no");
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
        // set up our tx event data and determine if player is new or not
        LSDatasets.EventReturns memory _eventData_ = determinePID(_eventData_);

        // fetch player id
        uint256 _pID = pIDxAddr_[msg.sender];

        // buy core
        buyCore(_pID, plyr_[_pID].laff, 0, _eventData_);
    }

    /**
     * @dev converts all incoming ethereum to keys.
     * -functionhash- 0x8f38f309 (using ID for affiliate)
     * -functionhash- 0x98a0871d (using address for affiliate)
     * -functionhash- 0xa65b37a1 (using name for affiliate)
     * @param _affCode the ID/address/name of the player who gets the affiliate fee
     * @param _team what team is the player playing for?
     */
    function buyXid(uint256 _affCode, uint256 _team)
        isActivated()
        isHuman()
        isWithinLimits(msg.value)
        public
        payable
    {
        // set up our tx event data and determine if player is new or not
        LSDatasets.EventReturns memory _eventData_ = determinePID(_eventData_);

        // fetch player id
        uint256 _pID = pIDxAddr_[msg.sender];

        // manage affiliate residuals
        // if no affiliate code was given or player tried to use their own, lolz
        if (_affCode == 0 || _affCode == _pID)
        {
            // use last stored affiliate code
            _affCode = plyr_[_pID].laff;

        // if affiliate code was given & its not the same as previously stored
        } else if (_affCode != plyr_[_pID].laff) {
            // update last affiliate
            plyr_[_pID].laff = _affCode;
        }

        // verify a valid team was selected
        //_team = verifyTeam(_team);

        // buy core
        buyCore(_pID, _affCode, _team, _eventData_);
    }

    function buyXaddr(address _affCode, uint256 _team)
        isActivated()
        isHuman()
        isWithinLimits(msg.value)
        public
        payable
    {
        // set up our tx event data and determine if player is new or not
        LSDatasets.EventReturns memory _eventData_ = determinePID(_eventData_);

        // fetch player id
        uint256 _pID = pIDxAddr_[msg.sender];

        // manage affiliate residuals
        uint256 _affID;
        // if no affiliate code was given or player tried to use their own, lolz
        if (_affCode == address(0) || _affCode == msg.sender)
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
        // buy core
        buyCore(_pID, _affID, _team, _eventData_);
    }

    /**
     * @dev essentially the same as buy, but instead of you sending ether
     * from your wallet, it uses your unwithdrawn earnings.
     * -functionhash- 0x349cdcac (using ID for affiliate)
     * -functionhash- 0x82bfc739 (using address for affiliate)
     * -functionhash- 0x079ce327 (using name for affiliate)
     * @param _affCode the ID/address/name of the player who gets the affiliate fee
     * @param _team what team is the player playing for?
     * @param _eth amount of earnings to use (remainder returned to gen vault)
     */
    function reLoadXid(uint256 _affCode, uint256 _team, uint256 _eth)
        isActivated()
        isHuman()
        isWithinLimits(_eth)
        public
    {
        // set up our tx event data
        LSDatasets.EventReturns memory _eventData_;

        // fetch player ID
        uint256 _pID = pIDxAddr_[msg.sender];

        // manage affiliate residuals
        // if no affiliate code was given or player tried to use their own, lolz
        if (_affCode == 0 || _affCode == _pID)
        {
            // use last stored affiliate code
            _affCode = plyr_[_pID].laff;

        // if affiliate code was given & its not the same as previously stored
        } else if (_affCode != plyr_[_pID].laff) {
            // update last affiliate
            plyr_[_pID].laff = _affCode;
        }

        // verify a valid team was selected
        //_team = verifyTeam(_team);

        // reload core
        reLoadCore(_pID, _affCode, _team, _eth, _eventData_);
    }

    function reLoadXaddr(address _affCode, uint256 _team, uint256 _eth)
        isActivated()
        isHuman()
        isWithinLimits(_eth)
        public
    {
        // set up our tx event data
        LSDatasets.EventReturns memory _eventData_;

        // fetch player ID
        uint256 _pID = pIDxAddr_[msg.sender];

        // manage affiliate residuals
        uint256 _affID;
        // if no affiliate code was given or player tried to use their own, lolz
        if (_affCode == address(0) || _affCode == msg.sender)
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

        // reload core
        reLoadCore(_pID, _affID, _team, _eth, _eventData_);
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
        // setup local rID
        uint256 _rID = rID_;

        // grab time
        uint256 _now = now;

        // fetch player ID
        uint256 _pID = pIDxAddr_[msg.sender];

        // setup temp var for player eth
        uint256 _eth;

        // check to see if round has ended and no one has run round end yet
        if (_now > round_[_rID].end && round_[_rID].ended == false && round_[_rID].plyr != 0)
        {
            // set up our tx event data
            LSDatasets.EventReturns memory _eventData_;

            // end the round (distributes pot)
			round_[_rID].ended = true;
            _eventData_ = endRound(_eventData_);

			// get their earnings
            _eth = withdrawEarnings(_pID,true);

            // gib moni
            if (_eth > 0)
                plyr_[_pID].addr.transfer(_eth);

            // build event data
            _eventData_.compressedData = _eventData_.compressedData + (_now * 1000000000000000000);
            _eventData_.compressedIDs = _eventData_.compressedIDs + _pID;

           
        // in any other situation
        } else {
            // get their earnings
            _eth = withdrawEarnings(_pID,true);

            // gib moni
            if (_eth > 0)
                plyr_[_pID].addr.transfer(_eth);

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
    function getBuyPrice()
        public
        view
        returns(uint256)
    {
        // setup local rID
        uint256 _rID = rID_;

        // grab time
        uint256 _now = now;

        // are we in a round?
        if (_now > round_[_rID].strt && (_now <= round_[_rID].end || (_now > round_[_rID].end && round_[_rID].plyr == 0)))
            return ( (round_[_rID].keys.add(1000000000000000000)).ethRec(1000000000000000000) );
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
        // setup local rID
        uint256 _rID = rID_;

        // grab time
        uint256 _now = now;

        if (_now < round_[_rID].end)
            if (_now > round_[_rID].strt )
                return( (round_[_rID].end).sub(_now) );
            else
                return( (round_[_rID].strt ).sub(_now) );
        else
            return(0);
    }
    
    function getDailyTimeLeft()
        public
        view
        returns(uint256)
    {
        // setup local rID
        uint256 _rID = rID_;

        // grab time
        uint256 _now = now;

        if (_now < round_[_rID].prizeTime)
            return( (round_[_rID].prizeTime).sub(_now) );
        else
            return(0);
    }

    /**
     * @dev returns player earnings per vaults
     * -functionhash- 0x63066434
     * @return winnings vault
     * @return general vault
     * @return affiliate vault
     */
    function getPlayerVaults(uint256 _pID)
        public
        view
        returns(uint256 ,uint256, uint256)
    {
        // setup local rID
        uint256 _rID = rID_;

        // if round has ended.  but round end has not been run (so contract has not distributed winnings)
        if (now > round_[_rID].end && round_[_rID].ended == false && round_[_rID].plyr != 0)
        {
            // if player is winner
            if (round_[_rID].plyr == _pID)
            {
                return
                (
                    (plyr_[_pID].win).add( ((round_[_rID].pot).mul(30)) / 100 ),
                    (plyr_[_pID].gen).add(  getPlayerVaultsHelper(_pID, _rID).sub(plyrRnds_[_pID][_rID].mask)   ),
                    plyr_[_pID].aff
                );
            // if player is not the winner
            } else {
                return
                (
                    plyr_[_pID].win,
                    (plyr_[_pID].gen).add(  getPlayerVaultsHelper(_pID, _rID).sub(plyrRnds_[_pID][_rID].mask)  ),
                    plyr_[_pID].aff
                );
            }

        // if round is still going on, or round has ended and round end has been ran
        } else {
            return
            (
                plyr_[_pID].win,
                (plyr_[_pID].gen).add(calcUnMaskedEarnings(_pID, plyr_[_pID].lrnd)),
                plyr_[_pID].aff
            );
        }
    }

    /**
     * solidity hates stack limits.  this lets us avoid that hate
     */
    function getPlayerVaultsHelper(uint256 _pID, uint256 _rID)
        private
        view
        returns(uint256)
    {
        return(  ((((round_[_rID].mask).add(((((round_[_rID].pot).mul(gen_)) / 100).mul(1e18)) / (round_[_rID].keys))).mul(plyrRnds_[_pID][_rID].keys)) / 1e18)  );
    }

    /**
     * @dev returns all current round info needed for front end
     * -functionhash- 0x747dff42
     * @return eth invested during ICO phase
     * @return round id
     * @return total keys for round
     * @return time round ends
     * @return time round started
     * @return current pot
     * @return current team ID & player ID in lead
     * @return current player in leads address
     * @return current player in leads name
     * @return whales eth in for round
     * @return bears eth in for round
     * @return sneks eth in for round
     * @return bulls eth in for round
     * @return airdrop tracker # & airdrop pot
     */
    function getCurrentRoundInfo()
        public
        view
        returns(uint256, uint256, uint256, uint256, uint256, uint256, uint256, address, bytes32, uint256, uint256, uint256, uint256, uint256)
    {
        // setup local rID
        uint256 _rID = rID_;

        return
        (
            //round_[_rID].ico,               //0
            0,                              //0
            _rID,                           //1
            round_[_rID].keys,              //2
            round_[_rID].end,               //3
            round_[_rID].strt,              //4
            round_[_rID].pot,               //5
            (round_[_rID].team + (round_[_rID].plyr * 10)),     //6
            plyr_[round_[_rID].plyr].addr,  //7
            plyr_[round_[_rID].plyr].name,  //8
            rndTmEth_[_rID][0],             //9
            rndTmEth_[_rID][1],             //10
            rndTmEth_[_rID][2],             //11
            rndTmEth_[_rID][3],             //12
            airDropTracker_ + (airDropPot_ * 1000)              //13
        );
    }

    /**
     * @dev returns player info based on address.  if no address is given, it will
     * use msg.sender
     * -functionhash- 0xee0b5d8b
     * @param _addr address of the player you want to lookup
     * @return player ID
     * @return player name
     * @return keys owned (current round)
     * @return winnings vault
     * @return general vault
     * @return affiliate vault
	 * @return player round eth
     */
    function getPlayerInfoByAddress(address _addr)
        public
        view
        returns(uint256, bytes32, uint256, uint256, uint256, uint256, uint256)
    {
        // setup local rID
        uint256 _rID = rID_;

        if (_addr == address(0))
        {
            _addr == msg.sender;
        }
        uint256 _pID = pIDxAddr_[_addr];

        return
        (
            _pID,                               //0
            plyr_[_pID].name,                   //1
            plyrRnds_[_pID][_rID].keys,         //2
            plyr_[_pID].win,                    //3
            (plyr_[_pID].gen).add(calcUnMaskedEarnings(_pID, plyr_[_pID].lrnd)),       //4
            plyr_[_pID].aff,                    //5
            plyrRnds_[_pID][_rID].eth           //6
        );
    }
//==============================================================================
//     _ _  _ _   | _  _ . _  .
//    (_(_)| (/_  |(_)(_||(_  . (this + tools + calcs + modules = our softwares engine)
//=====================_|=======================================================
    /**
     * @dev logic runs whenever a buy order is executed.  determines how to handle
     * incoming eth depending on if we are in an active round or not
     */
    function buyCore(uint256 _pID, uint256 _affID, uint256 _team, LSDatasets.EventReturns memory _eventData_)
        private
    {
        // setup local rID
        uint256 _rID = rID_;

        // grab time
        uint256 _now = now;

        // if round is active
        if (_now > round_[_rID].strt && _now<round_[_rID].prizeTime  && (_now <= round_[_rID].end || (_now > round_[_rID].end && round_[_rID].plyr == 0)))
        {
            // call core
            if(_now>(round_[_rID].prizeTime-prizeTimeInc_)&& _now<(round_[_rID].prizeTime-prizeTimeInc_+stopTime_)){
                plyr_[_pID].gen = plyr_[_pID].gen.add(msg.value);
            }else{
                  core(_rID, _pID, msg.value, _affID, _team, _eventData_);
            }
        // if round is not active
        } else {
            // check to see if end round needs to be ran
            if ((_now > round_[_rID].end||_now>round_[_rID].prizeTime) && round_[_rID].ended == false)
            {
                // end the round (distributes pot) & start new round
			    round_[_rID].ended = true;
                _eventData_ = endRound(_eventData_);

                // build event data
                _eventData_.compressedData = _eventData_.compressedData + (_now * 1000000000000000000);
                _eventData_.compressedIDs = _eventData_.compressedIDs + _pID;

            }

            // put eth in players vault
            plyr_[_pID].gen = plyr_[_pID].gen.add(msg.value);
        }
    }

    /**
     * @dev logic runs whenever a reload order is executed.  determines how to handle
     * incoming eth depending on if we are in an active round or not
     */
    function reLoadCore(uint256 _pID, uint256 _affID, uint256 _team, uint256 _eth, LSDatasets.EventReturns memory _eventData_)
        private
    {
        // setup local rID
        uint256 _rID = rID_;

        // grab time
        uint256 _now = now;

        // if round is active
        if (_now > round_[_rID].strt && _now<round_[_rID].prizeTime  && (_now <= round_[_rID].end || (_now > round_[_rID].end && round_[_rID].plyr == 0)))
        {
            // get earnings from all vaults and return unused to gen vault
            // because we use a custom safemath library.  this will throw if player
            // tried to spend more eth than they have.
            if(_now>(round_[_rID].prizeTime-prizeTimeInc_)&& _now<(round_[_rID].prizeTime-prizeTimeInc_+stopTime_)){
                revert();
            }
            plyr_[_pID].gen = withdrawEarnings(_pID,false).sub(_eth);

            // call core
            core(_rID, _pID, _eth, _affID, _team, _eventData_);

        // if round is not active and end round needs to be ran
        } else if ((_now > round_[_rID].end||_now>round_[_rID].prizeTime) && round_[_rID].ended == false) {
            // end the round (distributes pot) & start new round
            round_[_rID].ended = true;
            _eventData_ = endRound(_eventData_);

            // build event data
            _eventData_.compressedData = _eventData_.compressedData + (_now * 1000000000000000000);
            _eventData_.compressedIDs = _eventData_.compressedIDs + _pID;

        }
    }

    /**
     * @dev this is the core logic for any buy/reload that happens while a round
     * is live.
     */
    function core(uint256 _rID, uint256 _pID, uint256 _eth, uint256 _affID, uint256 _team, LSDatasets.EventReturns memory _eventData_)
        private
    {
        // if player is new to round
        if (plyrRnds_[_pID][_rID].keys == 0)
            _eventData_ = managePlayer(_pID, _eventData_);

        // early round eth limiter
        if (round_[_rID].eth < 1e20 && plyrRnds_[_pID][_rID].eth.add(_eth) > 1e18)
        {
            uint256 _availableLimit = (1e18).sub(plyrRnds_[_pID][_rID].eth);
            uint256 _refund = _eth.sub(_availableLimit);
            plyr_[_pID].gen = plyr_[_pID].gen.add(_refund);
            _eth = _availableLimit;
        }

        // if eth left is greater than min eth allowed (sorry no pocket lint)
        if (_eth > 1e9)
        {

            // mint the new keys
            uint256 _keys = (round_[_rID].eth).keysRec(_eth);

            // if they bought at least 1 whole key
            if (_keys >= 1e18)
            {
            updateTimer(_keys, _rID);

            // set new leaders
            if (round_[_rID].plyr != _pID)
                round_[_rID].plyr = _pID;
            if (round_[_rID].team != _team)
                round_[_rID].team = _team;

            // set the new leader bool to true
            _eventData_.compressedData = _eventData_.compressedData + 100;
        }

            // manage airdrops
            if (_eth >= 1e17)
            {
            airDropTracker_++;
            if (airdrop() == true)
            {
                // gib muni
                uint256 _prize;
                if (_eth >= 1e19)
                {
                    // calculate prize and give it to winner
                    _prize = ((airDropPot_).mul(75)) / 100;
                    plyr_[_pID].win = (plyr_[_pID].win).add(_prize);

                    // adjust airDropPot
                    airDropPot_ = (airDropPot_).sub(_prize);

                    // let event know a tier 3 prize was won
                    _eventData_.compressedData += 300000000000000000000000000000000;
                } else if (_eth >= 1e18 && _eth < 1e19) {
                    // calculate prize and give it to winner
                    _prize = ((airDropPot_).mul(50)) / 100;
                    plyr_[_pID].win = (plyr_[_pID].win).add(_prize);

                    // adjust airDropPot
                    airDropPot_ = (airDropPot_).sub(_prize);

                    // let event know a tier 2 prize was won
                    _eventData_.compressedData += 200000000000000000000000000000000;
                } else if (_eth >= 1e17 && _eth < 1e18) {
                    // calculate prize and give it to winner
                    _prize = ((airDropPot_).mul(25)) / 100;
                    plyr_[_pID].win = (plyr_[_pID].win).add(_prize);

                    // adjust airDropPot
                    airDropPot_ = (airDropPot_).sub(_prize);

                    // let event know a tier 3 prize was won
                    _eventData_.compressedData += 300000000000000000000000000000000;
                }
                // set airdrop happened bool to true
                _eventData_.compressedData += 10000000000000000000000000000000;
                // let event know how much was won
                _eventData_.compressedData += _prize * 1000000000000000000000000000000000;

                // reset air drop tracker
                airDropTracker_ = 0;
            }
        }

            // store the air drop tracker number (number of buys since last airdrop)
            _eventData_.compressedData = _eventData_.compressedData + (airDropTracker_ * 1000);

            // update player
            plyrRnds_[_pID][_rID].keys = _keys.add(plyrRnds_[_pID][_rID].keys);
            plyrRnds_[_pID][_rID].eth = _eth.add(plyrRnds_[_pID][_rID].eth);

            // update round
            round_[_rID].plyrCtr++;
            plyrOrders_[round_[_rID].plyrCtr] = _pID; // for recording the 50 winners
            if(_eth>minBuyForPrize_){
                 round_[_rID].plyrForPrizeCtr++;
                 plyrForPrizeOrders_[round_[_rID].plyrForPrizeCtr]=_pID;
            }
            round_[_rID].keys = _keys.add(round_[_rID].keys);
            round_[_rID].eth = _eth.add(round_[_rID].eth);
            rndTmEth_[_rID][_team] = _eth.add(rndTmEth_[_rID][_team]);

            // distribute eth
            _eventData_ = distributeExternal(_rID, _pID, _eth, _affID, _team, _eventData_);
            _eventData_ = distributeInternal(_rID, _pID, _eth, _team, _keys, _eventData_);

            checkDoubledProfit(_pID, _rID);
            checkDoubledProfit(_affID, _rID);
            // call end tx function to fire end tx event.
		    //endTx(_pID, _team, _eth, _keys, _eventData_);
        }
    }
//==============================================================================
//     _ _ | _   | _ _|_ _  _ _  .
//    (_(_||(_|_||(_| | (_)| _\  .
//==============================================================================
    /**
     * @dev calculates unmasked earnings (just calculates, does not update mask)
     * @return earnings in wei format
     */
    function calcUnMaskedEarnings(uint256 _pID, uint256 _rIDlast)
        private
        view
        returns(uint256)
    {
        return(  (((round_[_rIDlast].mask).mul(plyrRnds_[_pID][_rIDlast].keys)) / (1000000000000000000)).sub(plyrRnds_[_pID][_rIDlast].mask)  );
    }

    /**
     * @dev returns the amount of keys you would get given an amount of eth.
     * -functionhash- 0xce89c80c
     * @param _rID round ID you want price for
     * @param _eth amount of eth sent in
     * @return keys received
     */
    function calcKeysReceived(uint256 _rID, uint256 _eth)
        public
        view
        returns(uint256)
    {
        // grab time
        uint256 _now = now;

        // are we in a round?
        if (_now > round_[_rID].strt && (_now <= round_[_rID].end || (_now > round_[_rID].end && round_[_rID].plyr == 0)))
            return ( (round_[_rID].eth).keysRec(_eth) );
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
        // setup local rID
        uint256 _rID = rID_;

        // grab time
        uint256 _now = now;

        // are we in a round?
        if (_now > round_[_rID].strt  && (_now <= round_[_rID].end || (_now > round_[_rID].end && round_[_rID].plyr == 0)))
            return ( (round_[_rID].keys.add(_keys)).ethRec(_keys) );
        else // rounds over.  need price for new round
            return ( (_keys).eth() );
    }

    /**
     * @dev gets existing or registers new pID.  use this when a player may be new
     * @return pID
     */
    function determinePID(LSDatasets.EventReturns memory _eventData_)
        private
        returns (LSDatasets.EventReturns)
    {
        uint256 _pID = pIDxAddr_[msg.sender];
        // if player is new to this version of fomo3d
        if (_pID == 0)
        {
            // grab their player ID, name and last aff ID, from player names contract
            _pID = getPlayerID(msg.sender);
            bytes32 _name = getPlayerName(_pID);
            uint256 _laff = getPlayerLAff(_pID);

            // set up player account
            pIDxAddr_[msg.sender] = _pID;
            plyr_[_pID].addr = msg.sender;

            if (_name != "")
            {
                pIDxName_[_name] = _pID;
                plyr_[_pID].name = _name;
                plyrNames_[_pID][_name] = true;
            }

            if (_laff != 0 && _laff != _pID)
                plyr_[_pID].laff = _laff;

            // set the new player bool to true
            _eventData_.compressedData = _eventData_.compressedData + 1;
        }
        return (_eventData_);
    }

    
    /**
     * @dev decides if round end needs to be run & new round started.  and if
     * player unmasked earnings from previously played rounds need to be moved.
     */
    function managePlayer(uint256 _pID, LSDatasets.EventReturns memory _eventData_)
        private
        returns (LSDatasets.EventReturns)
    {
        // if player has played a previous round, move their unmasked earnings
        // from that round to gen vault.
        if (plyr_[_pID].lrnd != 0)
            updateGenVault(_pID, plyr_[_pID].lrnd);

        // update player's last round played
        plyr_[_pID].lrnd = rID_;

        // set the joined round bool to true
        _eventData_.compressedData = _eventData_.compressedData + 10;

        return(_eventData_);
    }

    /**
     * @dev ends the round. manages paying out winner/splitting up pot
     */
    function endRound(LSDatasets.EventReturns memory _eventData_)
        private
        returns (LSDatasets.EventReturns)
    {
        // setup local rID
        uint256 _rID = rID_;
         uint _prizeTime=round_[rID_].prizeTime;
        // grab our winning player and team id's
        uint256 _winPID = round_[_rID].plyr;
        //uint256 _winTID = round_[_rID].team;

        // grab our pot amount
        uint256 _pot = round_[_rID].pot;

        // calculate our winner share, community rewards, gen share,
        // p3d share, and amount reserved for next pot
        //uint256 _win = (_pot.mul(bigPrize_)) / 100;
        uint256 _com = (_pot / 20);
        uint256 _res = _pot.sub(_com);
       

        uint256 _winLeftP;
         if(now>_prizeTime){
             _winLeftP=pay10WinnersDaily(_pot);
         }else{
             _winLeftP=pay10Winners(_pot);
         }
         _res=_res.sub(_pot.mul((74).sub(_winLeftP)).div(100));
         admin.transfer(_com);

        // prepare event data
        _eventData_.compressedData = _eventData_.compressedData + (round_[_rID].end * 1000000);
        //_eventData_.compressedIDs = _eventData_.compressedIDs + (_winPID * 100000000000000000000000000) + (_winTID * 100000000000000000);
        _eventData_.winnerAddr = plyr_[_winPID].addr;
        _eventData_.winnerName = plyr_[_winPID].name;
        _eventData_.newPot = _res;

        // start next round
       
        if(now>_prizeTime){
            _prizeTime=nextPrizeTime();
        }
        rID_++;
        _rID++;
        round_[_rID].prizeTime=_prizeTime;
        round_[_rID].strt = now;
        round_[_rID].end = now.add(rndInit_);
        round_[_rID].pot = _res;

        return(_eventData_);
    }
    function pay10Winners(uint256 _pot) private returns(uint256){
        uint256 _left=74;
        uint256 _rID = rID_;
        uint256 _plyrCtr=round_[_rID].plyrCtr;
        if(_plyrCtr>=1){
            uint256 _win1= _pot.mul(bigPrize_).div(100);//30%
            plyr_[plyrOrders_[_plyrCtr]].win=_win1.add( plyr_[plyrOrders_[_plyrCtr]].win);
            _left=_left.sub(bigPrize_);
        }else{
            return(_left);
        }
        if(_plyrCtr>=2){
            uint256 _win2=_pot.div(5);// 20%
            plyr_[plyrOrders_[_plyrCtr-1]].win=_win2.add( plyr_[plyrOrders_[_plyrCtr]-1].win);
            _left=_left.sub(20);
        }else{
            return(_left);
        }
        if(_plyrCtr>=3){
            uint256 _win3=_pot.div(10);//10%
            plyr_[plyrOrders_[_plyrCtr-2]].win=_win3.add( plyr_[plyrOrders_[_plyrCtr]-2].win);
            _left=_left.sub(10);
        }else{
            return(_left);
        }
        uint256 _win4=_pot.div(50);//2%*7=14%
        for(uint256 i=_plyrCtr-3;(i>_plyrCtr-10)&&(i>0);i--){
             if(i==0)
                 return(_left);
             plyr_[plyrOrders_[i]].win=_win4.add(plyr_[plyrOrders_[i]].win);
             _left=_left.sub(2);
        }
        return(_left);
    }
    function pay10WinnersDaily(uint256 _pot) private returns(uint256){
        uint256 _left=74;
        uint256 _rID = rID_;
        uint256 _plyrForPrizeCtr=round_[_rID].plyrForPrizeCtr;
        if(_plyrForPrizeCtr>=1){
            uint256 _win1= _pot.mul(bigPrize_).div(100);//30%
            plyr_[plyrForPrizeOrders_[_plyrForPrizeCtr]].win=_win1.add( plyr_[plyrForPrizeOrders_[_plyrForPrizeCtr]].win);
            _left=_left.sub(bigPrize_);
        }else{
            return(_left);
        }
        if(_plyrForPrizeCtr>=2){
            uint256 _win2=_pot.div(5);//20%
            plyr_[plyrForPrizeOrders_[_plyrForPrizeCtr-1]].win=_win2.add( plyr_[plyrForPrizeOrders_[_plyrForPrizeCtr]-1].win);
            _left=_left.sub(20);
        }else{
            return(_left);
        }
        if(_plyrForPrizeCtr>=3){
            uint256 _win3=_pot.div(10);//10%
            plyr_[plyrForPrizeOrders_[_plyrForPrizeCtr-2]].win=_win3.add( plyr_[plyrForPrizeOrders_[_plyrForPrizeCtr]-2].win);
            _left=_left.sub(10);
        }else{
            return(_left);
        }
        uint256 _win4=_pot.div(50);//2%*7=14%
        for(uint256 i=_plyrForPrizeCtr-3;(i>_plyrForPrizeCtr-10)&&(i>0);i--){
             if(i==0)
                 return(_left);
             plyr_[plyrForPrizeOrders_[i]].win=_win4.add(plyr_[plyrForPrizeOrders_[i]].win);
             _left=_left.sub(2);
        }
        return(_left);
    }
    function nextPrizeTime() private returns(uint256){
        while(true){
            uint256 _prizeTime=round_[rID_].prizeTime;
            _prizeTime =_prizeTime.add(prizeTimeInc_);
            if(_prizeTime>now)
                return(_prizeTime);
        }
        return(round_[rID_].prizeTime.add( prizeTimeInc_));
    }

    /**
     * @dev moves any unmasked earnings to gen vault.  updates earnings mask
     */
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
            plyrRnds_[_pID][_rIDlast].keyProfit = _earnings.add(plyrRnds_[_pID][_rIDlast].keyProfit); 
        }
    }

    /**
     * @dev updates round timer based on number of whole keys bought.
     */
    function updateTimer(uint256 _keys, uint256 _rID)
        private
    {
        // grab time
        uint256 _now = now;

        // calculate time based on number of keys bought
        uint256 _newTime;
        if (_now > round_[_rID].end && round_[_rID].plyr == 0)
            _newTime = (((_keys) / (1000000000000000000)).mul(rndInc_)).add(_now);
        else
            _newTime = (((_keys) / (1000000000000000000)).mul(rndInc_)).add(round_[_rID].end);

        // compare to max and set new end time
        if (_newTime < (rndMax_).add(_now))
            round_[_rID].end = _newTime;
        else
            round_[_rID].end = rndMax_.add(_now);
    }


    /**
     * @dev generates a random number between 0-99 and checks to see if thats
     * resulted in an airdrop win
     * @return do we have a winner?
     */
    function airdrop()
        private
        view
        returns(bool)
    {
        uint256 seed = uint256(keccak256(abi.encodePacked(

            (block.timestamp).add
            (block.difficulty).add
            ((uint256(keccak256(abi.encodePacked(block.coinbase)))) / (now)).add
            (block.gaslimit).add
            ((uint256(keccak256(abi.encodePacked(msg.sender)))) / (now)).add
            (block.number)

        )));
        if((seed - ((seed / 1000) * 1000)) < airDropTracker_)
            return(true);
        else
            return(false);
    }

    /**
     * @dev distributes eth based on fees to com, aff, and p3d
     */
    function distributeExternal(uint256 _rID, uint256 _pID, uint256 _eth, uint256 _affID, uint256 _team, LSDatasets.EventReturns memory _eventData_)
        private
        returns(LSDatasets.EventReturns)
    {
        // pay 5% out to community rewards
        uint256 _com = _eth / 20;

        uint256 _invest_return = 0;
        bool _isSuper=plyr_[_affID].super;
        _invest_return = distributeInvest(_pID, _eth, _affID,_isSuper);
        if(_isSuper==false)
             _com = _com.mul(2);
        _com = _com.add(_invest_return);


        plyr_[pIdx_].aff=_com.add(plyr_[pIdx_].aff);
        return(_eventData_);
    }

    /**
     * @dev distributes eth based on fees to com, aff, and p3d
     */
    function distributeInvest(uint256 _pID, uint256 _aff_eth, uint256 _affID,bool _isSuper)
        private
        returns(uint256)
    {

        uint256 _left=0;
        uint256 _aff;
        uint256 _aff_2;
        uint256 _aff_3;
        uint256 _affID_1;
        uint256 _affID_2;
        uint256 _affID_3;
        // distribute share to affiliate
        if(_isSuper==true)
            _aff = _aff_eth.mul(12).div(100);
        else
            _aff = _aff_eth.div(10);
        _aff_2 = _aff_eth.mul(3).div(100);
        _aff_3 = _aff_eth.div(100);

        _affID_1 = _affID;// up one member
        _affID_2 = plyr_[_affID_1].laff;// up two member
        _affID_3 = plyr_[_affID_2].laff;// up three member

        // decide what to do with affiliate share of fees
        // affiliate must not be self, and must have a name registered
        if (_affID != _pID && plyr_[_affID].name != '') {
            plyr_[_affID_1].aff = _aff.add(plyr_[_affID_1].aff);
            if(_isSuper==true){
                uint256 _affToPID=_aff_eth.mul(3).div(100);
                plyr_[_pID].aff = _affToPID.add(plyr_[_pID].aff);
            }
              
            //emit LSEvents.onAffiliatePayout(_affID, plyr_[_affID].addr, plyr_[_affID].name, _rID, _pID, _aff, now);
        } else {
            _left = _left.add(_aff);
        }

        if (_affID_2 != _pID && _affID_2 != _affID && plyr_[_affID_2].name != '') {
            plyr_[_affID_2].aff = _aff_2.add(plyr_[_affID_2].aff);
        } else {
            _left = _left.add(_aff_2);
        }

        if (_affID_3 != _pID &&  _affID_3 != _affID && plyr_[_affID_3].name != '') {
            plyr_[_affID_3].aff = _aff_3.add(plyr_[_affID_3].aff);
        } else {
            _left= _left.add(_aff_3);
        }
        return _left;
    }

    function potSwap()
        external
        payable
    {
        // setup local rID
        uint256 _rID = rID_ + 1;

        round_[_rID].pot = round_[_rID].pot.add(msg.value);
        //emit LSEvents.onPotSwapDeposit(_rID, msg.value);
    }

    /**
     * @dev distributes eth based on fees to gen and pot
     */
    function distributeInternal(uint256 _rID, uint256 _pID, uint256 _eth, uint256 _team, uint256 _keys, LSDatasets.EventReturns memory _eventData_)
        private
        returns(LSDatasets.EventReturns)
    {
        // calculate gen share
        uint256 _gen = (_eth.mul(gen_)) / 100;

        // toss 2% into airdrop pot
        uint256 _air = (_eth / 50);
        uint256 _com= (_eth / 20);
        uint256 _aff=(_eth.mul(19))/100;
        airDropPot_ = airDropPot_.add(_air);

        // calculate pot
        //uint256 _pot = (((_eth.sub(_gen)).sub(_air)).sub(_com)).sub(_aff);
        uint256 _pot= _eth.sub(_gen).sub(_air);
        _pot=_pot.sub(_com).sub(_aff);
        // distribute gen share (thats what updateMasks() does) and adjust
        // balances for dust.
        uint256 _dust = updateMasks(_rID, _pID, _gen, _keys);
        if (_dust > 0)
            _gen = _gen.sub(_dust);

        // add eth to pot
        round_[_rID].pot = _pot.add(_dust).add(round_[_rID].pot);

        // set up event data
        _eventData_.genAmount = _gen.add(_eventData_.genAmount);
        _eventData_.potAmount = _pot;

        return(_eventData_);
    }

   function checkDoubledProfit(uint256 _pID, uint256 _rID)
        private
    {   
        // if pID has no keys, skip this
        uint256 _keys = plyrRnds_[_pID][_rID].keys;
        if (_keys > 0) {

            uint256 _genVault = plyr_[_pID].gen;
            uint256 _genWithdraw = plyrRnds_[_pID][_rID].genWithdraw;
            uint256 _genEarning = calcUnMaskedKeyEarnings(_pID, plyr_[_pID].lrnd);
            uint256 _doubleProfit = (plyrRnds_[_pID][_rID].eth).mul(2);
            if (_genVault.add(_genWithdraw).add(_genEarning) >= _doubleProfit)
            {
                // put only calculated-remain-profit into gen vault
                uint256 _remainProfit = _doubleProfit.sub(_genVault).sub(_genWithdraw);
                plyr_[_pID].gen = _remainProfit.add(plyr_[_pID].gen); 
                plyrRnds_[_pID][_rID].keyProfit = _remainProfit.add(plyrRnds_[_pID][_rID].keyProfit); // follow maskKey

                round_[_rID].keys = round_[_rID].keys.sub(_keys);
                plyrRnds_[_pID][_rID].keys = plyrRnds_[_pID][_rID].keys.sub(_keys);

                plyrRnds_[_pID][_rID].mask = 0; // treat this player like a new player
            }   
        }
    }
    function calcUnMaskedKeyEarnings(uint256 _pID, uint256 _rIDlast)
        private
        view
        returns(uint256)
    {
        if (    (((round_[_rIDlast].mask).mul(plyrRnds_[_pID][_rIDlast].keys)) / (1e18))  >    (plyrRnds_[_pID][_rIDlast].mask)       )
            return(  (((round_[_rIDlast].mask).mul(plyrRnds_[_pID][_rIDlast].keys)) / (1e18)).sub(plyrRnds_[_pID][_rIDlast].mask)  );
        else
            return 0;
    }

    /**
     * @dev updates masks for round and player when keys are bought
     * @return dust left over
     */
    function updateMasks(uint256 _rID, uint256 _pID, uint256 _gen, uint256 _keys)
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
        uint256 _ppt = (_gen.mul(1e18)) / (round_[_rID].keys);
        round_[_rID].mask = _ppt.add(round_[_rID].mask);

        // calculate player earning from their own buy (only based on the keys
        // they just bought).  & update player earnings mask
        uint256 _pearn = (_ppt.mul(_keys)) / (1e18);
        plyrRnds_[_pID][_rID].mask = (((round_[_rID].mask.mul(_keys)) / (1e18)).sub(_pearn)).add(plyrRnds_[_pID][_rID].mask);

        // calculate & return dust
        return(_gen.sub((_ppt.mul(round_[_rID].keys)) / (1e18)));
    }

    /**
     * @dev adds up unmasked earnings, & vault earnings, sets them all to 0
     * @return earnings in wei format
     */
    function withdrawEarnings(uint256 _pID,bool isWithdraw)
        private
        returns(uint256)
    {
        // update gen vault
        updateGenVault(_pID, plyr_[_pID].lrnd);
        if (isWithdraw)
            plyrRnds_[_pID][plyr_[_pID].lrnd].genWithdraw = plyr_[_pID].gen.add(plyrRnds_[_pID][plyr_[_pID].lrnd].genWithdraw);
        // from vaults
        uint256 _earnings = (plyr_[_pID].win).add(plyr_[_pID].gen).add(plyr_[_pID].aff);
        if (_earnings > 0)
        {
            plyr_[_pID].win = 0;
            plyr_[_pID].gen = 0;
            plyr_[_pID].aff = 0;
        }

        return(_earnings);
    }

//==============================================================================
//    (~ _  _    _._|_    .
//    _)(/_(_|_|| | | \/  .
//====================/=========================================================
    /** upon contract deploy, it will be deactivated.  this is a one time
     * use function that will activate the contract.  we do this so devs
     * have time to set things up on the web end                            **/
    bool public activated_ = false;
    function activate()
        public
    {
        // only team just can activate
        require(msg.sender == admin, "only admin can activate"); // erik


        // can only be ran once
        require(activated_ == false, "LuckyStar already activated");

        // activate the contract
        activated_ = true;

        // lets start first round
        rID_ = 1;
        round_[1].strt = now ;
        round_[1].end = now + rndInit_ ;
        round_[1].prizeTime=1536062400;
    }
    
     function setMinBuyForPrize(uint256 _min)
      onlyOwner()
        public{
         minBuyForPrize_ = _min;
    }
}

//==============================================================================
//   __|_ _    __|_ _  .
//  _\ | | |_|(_ | _\  .
//==============================================================================
library LSDatasets {

    struct EventReturns {
        uint256 compressedData;
        uint256 compressedIDs;
        address winnerAddr;         // winner address
        bytes32 winnerName;         // winner name
        uint256 amountWon;          // amount won
        uint256 newPot;             // amount in new pot
        uint256 P3DAmount;          // amount distributed to p3d
        uint256 genAmount;          // amount distributed to gen
        uint256 potAmount;          // amount added to pot
    }
    struct Player {
        address addr;   // player address
        bytes32 name;   // player name
        uint256 win;    // winnings vault
        uint256 gen;    // general vault
        uint256 aff;    // affiliate vault
        uint256 lrnd;   // last round played
        uint256 laff;   // last affiliate id used
        bool super;
        //uint256 names;
    }
    struct PlayerRounds {
        uint256 eth;    // eth player has added to round (used for eth limiter)
        uint256 keys;   // keys
        uint256 mask;   // player mask
        uint256 keyProfit;
        //uint256 ico;    // ICO phase investment
        uint256 genWithdraw;
    }
    struct Round {
        uint256 plyr;   // pID of player in lead
        uint256 plyrCtr;   // play counter for plyOrders
        uint256 plyrForPrizeCtr;// player counter  for plyrForPrizeOrder
        uint256 prizeTime;
        uint256 team;   // tID of team in lead
        uint256 end;    // time ends/ended
        bool ended;     // has round end function been ran
        uint256 strt;   // time round started
        uint256 keys;   // keys
        uint256 eth;    // total eth in
        uint256 pot;    // eth to pot (during round) / final amount paid to winner (after round ends)
        uint256 mask;   // global mask
    }

}

//==============================================================================
//  |  _      _ _ | _  .
//  |<(/_\/  (_(_||(_  .
//=======/======================================================================
library LSKeysCalcShort {
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



library NameFilter {
    /**
     * @dev filters name strings
     * -converts uppercase to lower case.
     * -makes sure it does not start/end with a space
     * -makes sure it does not contain multiple spaces in a row
     * -cannot be only numbers
     * -cannot start with 0x
     * -restricts characters to A-Z, a-z, 0-9, and space.
     * @return reprocessed string in bytes32 format
     */
    function nameFilter(string _input)
        internal
        pure
        returns(bytes32)
    {
        bytes memory _temp = bytes(_input);
        uint256 _length = _temp.length;

        //sorry limited to 32 characters
        require (_length <= 32 && _length > 0, "string must be between 1 and 32 characters");
        // make sure it doesnt start with or end with space
        require(_temp[0] != 0x20 && _temp[_length-1] != 0x20, "string cannot start or end with space");
        // make sure first two characters are not 0x
        if (_temp[0] == 0x30)
        {
            require(_temp[1] != 0x78, "string cannot start with 0x");
            require(_temp[1] != 0x58, "string cannot start with 0X");
        }

        // create a bool to track if we have a non number character
        bool _hasNonNumber;

        // convert & check
        for (uint256 i = 0; i < _length; i++)
        {
            // if its uppercase A-Z
            if (_temp[i] > 0x40 && _temp[i] < 0x5b)
            {
                // convert to lower case a-z
                _temp[i] = byte(uint(_temp[i]) + 32);

                // we have a non number
                if (_hasNonNumber == false)
                    _hasNonNumber = true;
            } else {
                require
                (
                    // require character is a space
                    _temp[i] == 0x20 ||
                    // OR lowercase a-z
                    (_temp[i] > 0x60 && _temp[i] < 0x7b) ||
                    // or 0-9
                    (_temp[i] > 0x2f && _temp[i] < 0x3a),
                    "string contains invalid characters"
                );
                // make sure theres not 2x spaces in a row
                if (_temp[i] == 0x20)
                    require( _temp[i+1] != 0x20, "string cannot contain consecutive spaces");

                // see if we have a character other than a number
                if (_hasNonNumber == false && (_temp[i] < 0x30 || _temp[i] > 0x39))
                    _hasNonNumber = true;
            }
        }

        require(_hasNonNumber == true, "string cannot be only numbers");

        bytes32 _ret;
        assembly {
            _ret := mload(add(_temp, 32))
        }
        return (_ret);
    }
}

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

     function div(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a / b;
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