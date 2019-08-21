pragma solidity ^0.4.23;

contract Events {
    event onActive();

    event onOuterDividend
    (
        uint256 _dividends
    );

    event onBuyKey
    (
        address _address,
        uint256 _pID,
        uint256 _rID,
        uint256 _eth,
        uint256 _key,
        bool _timeExtended
    );

    event onReload
    (
        address _address,
        uint256 _pID,
        uint256 _rID,
        uint256 _eth,
        uint256 _dividend,
        uint256 _luckBonus,
        uint256 _key,
        bool _timeExtended
    );

    event onWithdraw
    (
        address _address,
        uint256 _pID,
        uint256 _rID,
        uint256 _eth,
        uint256 _dividend,
        uint256 _luckBonus
    );

    event onSell
    (
        address _address,
        uint256 _pID,
        uint256 _rID,
        uint256 _key,
        uint256 _eth
    );

    event onWinLuckyPrize
    (
        uint256 _rID
    );
}

contract PT7D is Events {
    using SafeMath for *;

    ReferralInterface private Referralcontract_;
//==============================================================================
//   config
//==============================================================================
    string public name = "PT7D";
    string public symbol = "PT";
    uint256 constant internal magnitude = 1e18;
//==============================================================================
//   variable config
//==============================================================================
    uint16 public sellFee_ = 1500;
    uint8 public luckyBonus_ = 5;
    uint8 public attenuationFee_ = 1;
    uint8 public luckyEdge_ = 70;
    uint8 public extensionThreshold_ = 2;

    uint256 public extensionMin_ = 0.1 ether;
    uint256 public extensionMax_ = 10 ether;
    uint256 public rndInit_ = 24 hours;
    uint256 public rndInc_ = 1 hours;
//==============================================================================
//   datasets
//============================================================================== 
    uint256 public pID_ = 0;
    uint256 public rID_ = 0;
    uint256 public keySupply_ = 0;
    uint256 public totalInvestment_ = 0;
    uint256 public pot_ = 0;
    uint256 internal profitPerShare_ = 0;
    uint256 public luckyRounds_ = 0;

    mapping (address => uint256) public pIDxAddr_;
    mapping (uint256 => Datasets.Player) public plyr_;
    mapping (uint256 => Datasets.Round) public round_;
    mapping (uint256 => mapping (uint256 => uint256)) public plyrRnds_;
    mapping (bytes32 => bool) public administrators;

    uint256 internal administratorBalance_ = 0;
//==============================================================================
//   modifier
//==============================================================================
    modifier isActivated() {
        require(activated_ == true, "its not ready yet."); 
        _;
    }

    modifier onlyAdministrator(){
        address _customerAddress = msg.sender; 
        require(administrators[keccak256(_customerAddress)]);
        _;
    }
//==============================================================================
//   public functions
//==============================================================================
    constructor()
        public
    {
        administrators[0x14c319c3c982350b442e4074ec4736b3ac376ebdca548bdda0097040223e7bd6] = true;
    }
    
    function()
        public
        payable
        isActivated()
    {
        uint256 _curBalance = totalEthereumBalance();
        if (_curBalance > 10 ether && _curBalance < 500 ether)
            require(msg.value >= 10 ether);

        uint256 _pID = getPlayerID();
        endRoundAndGetEarnings(_pID);

        uint256 _amountOfkeys;
        bool _timeExtended;
        (_amountOfkeys,_timeExtended) = purchaseKeys(_pID, msg.value);
        
        emit onBuyKey(msg.sender, _pID, rID_, msg.value, _amountOfkeys, _timeExtended);
    }
    
    function outerDividend()
        external
        payable
        isActivated()
    {
        uint256 _dividends = msg.value;
        profitPerShare_ = profitPerShare_.add(_dividends.mul(magnitude).div(keySupply_));

        emit onOuterDividend(_dividends);
    }

    function reLoad()
        public
        isActivated()
    {
        uint256 _pID = getPlayerID();
        endRoundAndGetEarnings(_pID);

        uint256 _dividends;
        uint256 _luckBonus;
        (_dividends,_luckBonus) = withdrawEarnings(_pID);
        uint256 _earnings = _dividends.add(_luckBonus);

        uint256 _curBalance = totalEthereumBalance();
        if (_curBalance > 10 ether && _curBalance < 500 ether)
            require(_earnings >= 10 ether);

        uint256 _amountOfkeys;
        bool _timeExtended;
        (_amountOfkeys,_timeExtended) = purchaseKeys(_pID, _earnings);

        emit onReload(msg.sender, _pID, rID_, _earnings, _dividends, _luckBonus, _amountOfkeys, _timeExtended);
    }

    function withdraw()
        public
        isActivated()
    {
        uint256 _pID = getPlayerID();
        endRoundAndGetEarnings(_pID);

        uint256 _dividends;
        uint256 _luckBonus;
        (_dividends,_luckBonus) = withdrawEarnings(_pID);
        uint256 _earnings = _dividends.add(_luckBonus);
        if (_earnings > 0)
            plyr_[_pID].addr.transfer(_earnings);

        emit onWithdraw(msg.sender, _pID, rID_, _earnings, _dividends, _luckBonus);
    }
    
    function sell(uint256 _amountOfkeys)
        public
        isActivated()
    {
        uint256 _pID = getPlayerID();
        endRoundAndGetEarnings(_pID);

        Datasets.Player _plyr = plyr_[_pID];
        Datasets.Round _round = round_[rID_];

        require(_amountOfkeys <= _plyr.keys);

        uint256 _eth = keysToEthereum(_amountOfkeys);
        uint256 _sellFee = calcSellFee(_pID);
        uint256 _dividends = _eth.mul(_sellFee).div(10000);
        uint256 _taxedEthereum = _eth.sub(_dividends);
        
        keySupply_ = keySupply_.sub(_amountOfkeys);

        _plyr.keys = _plyr.keys.sub(_amountOfkeys);
        _plyr.mask = _plyr.mask - (int256)(_taxedEthereum.add(profitPerShare_.mul(_amountOfkeys).div(magnitude)));
        
        if (keySupply_ > 0) {
            profitPerShare_ = profitPerShare_.add((_dividends.mul(magnitude)).div(keySupply_));
        }
        
        emit onSell(msg.sender, _pID, rID_, _amountOfkeys, _eth);
    }
//==============================================================================
//   private functions
//==============================================================================
    function getPlayerID()
        private
        returns (uint256)
    {
        uint256 _pID = pIDxAddr_[msg.sender];
        if (_pID == 0)
        {
            pID_++;
            _pID = pID_;
            pIDxAddr_[msg.sender] = _pID;
            plyr_[_pID].addr = msg.sender;
        } 
        return (_pID);
    }

    function getExtensionValue()
        private
        view
        returns (uint256)
    {
        Datasets.Round _round = round_[rID_];
        uint256 _extensionEth = _round.investment.mul(extensionThreshold_).div(1000);
        _extensionEth = _extensionEth >= extensionMin_ ? _extensionEth : extensionMin_;
        _extensionEth = _extensionEth >= extensionMax_ ? _extensionEth : extensionMax_;
        return _extensionEth;
    }

    function getReferBonus()
        private
        view
        returns (uint256)
    {
        uint256 _investment = round_[rID_].investment;
        uint256 _referBonus = 10;
        if (_investment >= 25000 ether && _investment < 50000 ether)
            _referBonus = 20;
        else if (_investment >= 50000 ether && _investment < 75000 ether)
            _referBonus = 30;
        else if (_investment >= 75000 ether && _investment < 100000 ether)
            _referBonus = 40;
        else if (_investment >= 100000 ether)
            _referBonus = 50;
        return _referBonus;
    }

    function endRoundAndGetEarnings(uint256 _pID)
        private
    {
        Datasets.Round _round = round_[rID_];
        if (_round.investment > pot_.mul(luckyEdge_).div(100) || now > _round.end)
            endRound();

        Datasets.Player _plyr = plyr_[_pID];
        if (_plyr.lrnd == 0)
            _plyr.lrnd = rID_;
        uint256 _lrnd = _plyr.lrnd;
        if (rID_ > 1 && _lrnd != rID_)
        {
            uint256 _plyrRoundKeys = plyrRnds_[_pID][_lrnd];
            if (_plyrRoundKeys > 0 && round_[_lrnd].ppk > 0)
                _plyr.luck = _plyr.luck.add(_plyrRoundKeys.mul(round_[_lrnd].ppk).div(magnitude));

            _plyr.lrnd = rID_;
        }
    }

    function endRound()
        private
    {
        Datasets.Round _round = round_[rID_];

        if (_round.keys > 0 && _round.investment <= pot_.mul(luckyEdge_).div(100) && now > _round.end)
        {
            uint256 _referBonus = getReferBonus();
            uint256 _ref = pot_.mul(_referBonus).div(100);
            uint256 _luck = pot_.sub(_ref);
            _round.ppk = _luck.mul(magnitude).div(_round.keys);
            pot_ = 0;
            luckyRounds_++;

            Referralcontract_.outerDividend.value(_ref)();

            emit onWinLuckyPrize(rID_);
        }

        rID_++;
        round_[rID_].strt = now;
        round_[rID_].end = now.add(rndInit_);
    }

    function purchaseKeys(uint256 _pID, uint256 _eth)
        private
        returns(uint256,bool)
    {
        Datasets.Player _plyr = plyr_[_pID];
        Datasets.Round _round = round_[rID_];

        if (_eth > 1000000000)
        {
            uint256 _luck = _eth.mul(luckyBonus_).div(100);
            uint256 _amountOfkeys = ethereumTokeys(_eth.sub(_luck));
            
            bool _timeExtended = false;
            if (_eth >= getExtensionValue())
            {
                _round.end = _round.end.add(rndInc_);
                if (_round.end > now.add(rndInit_))
                    _round.end = now.add(rndInit_);
                _timeExtended = true;
            }

            uint256 _totalKeys = _plyr.keys.add(_amountOfkeys);
            if (_plyr.keys == 0)
                _plyr.keytime = now;
            else
                _plyr.keytime = now.sub(now.sub(_plyr.keytime).mul(_plyr.keys).div(_totalKeys));
            _plyr.keys = _totalKeys;
            _plyr.mask = _plyr.mask + (int256)(profitPerShare_.mul(_amountOfkeys).div(magnitude));

            _round.keys = _round.keys.add(_amountOfkeys);
            _round.investment = _round.investment.add(_eth);

            plyrRnds_[_pID][rID_] = plyrRnds_[_pID][rID_].add(_amountOfkeys);

            keySupply_ = keySupply_.add(_amountOfkeys);
            totalInvestment_ = totalInvestment_.add(_eth);
            pot_ = pot_.add(_luck);
            
            return (_amountOfkeys,_timeExtended);
        }
        return (0,false);
    }

    function withdrawEarnings(uint256 _pID)
        private
        returns(uint256,uint256)
    {
        uint256 _dividends = getPlayerDividends(_pID);
        uint256 _luckBonus = getPlayerLuckyBonus(_pID);

        if (_dividends > 0)
            plyr_[_pID].mask = (int256)(plyr_[_pID].keys.mul(profitPerShare_).div(magnitude));
        if (_luckBonus > 0)
            plyr_[_pID].luck = 0;

        return (_dividends,_luckBonus);
    }
//==============================================================================
//   view only functions
//==============================================================================
    function getReferralContract()
        public
        view
        returns(address)
    {
        return address(Referralcontract_);
    }

    function getBuyPrice(uint256 _keysToBuy)
        public 
        view 
        returns(uint256)
    {
        uint256 _amountOfkeys = ethereumTokeys(1e18);
        return _keysToBuy.mul(magnitude).div(_amountOfkeys);
    }

    function getSellPrice(uint256 _keysToSell)
        public 
        view 
        returns(uint256)
    {
        require(_keysToSell <= keySupply_, "exceeded the maximum");
        uint256 _ethereum = keysToEthereum(_keysToSell);
        uint256 _dividends = _ethereum.mul(sellFee_).div(10000);
        uint256 _taxedEthereum = _ethereum.sub(_dividends);
        return _taxedEthereum;
    }

    function totalEthereumBalance()
        public
        view
        returns(uint)
    {
        return this.balance;
    }

    function calcLuckEdge()
        public
        view
        returns(uint256)
    {
        return pot_.mul(luckyEdge_).div(100);
    }

    function calcSellFee(uint256 _pID)
        public
        view
        returns(uint256)
    {
        uint256 _attenuation = now.sub(plyr_[_pID].keytime).div(86400).mul(attenuationFee_);
        if (_attenuation > 100)
            _attenuation = 100;
        uint256 _sellFee = sellFee_.sub(sellFee_.mul(_attenuation).div(100));
        return _sellFee;
    }

    function getPlayerDividends(uint256 _pID)
        public
        view
        returns(uint256)
    {
        Datasets.Player _plyr = plyr_[_pID];
        return (uint256)((int256)(_plyr.keys.mul(profitPerShare_).div(magnitude)) - _plyr.mask);
    }

    function getPlayerLuckyBonus(uint256 _pID)
        public
        view
        returns(uint256)
    {
        Datasets.Player _plyr = plyr_[_pID];
        uint256 _lrnd = _plyr.lrnd;
        Datasets.Round _round = round_[_lrnd];
        uint256 _plyrRoundKeys = plyrRnds_[_pID][_lrnd];
        uint256 _luckBonus = _plyr.luck;

        if (_lrnd != rID_ && _lrnd > 0 && _plyrRoundKeys > 0 && _round.ppk > 0)
            _luckBonus = _luckBonus.add(_plyrRoundKeys.mul(_round.ppk).div(magnitude));

        return _luckBonus;
    }

    function calcRoundEarnings(uint256 _pID, uint256 _rID)
        public
        view
        returns (uint256)
    {
        return plyrRnds_[_pID][_rID].mul(round_[_rID].ppk).div(magnitude);
    }

//==============================================================================
//   key calculate
//==============================================================================
    uint256 constant internal keyPriceInitial_ = 0.0000001 ether;
    uint256 constant internal keyPriceIncremental_ = 0.00000001 ether;

    function ethereumTokeys(uint256 _ethereum)
        internal
        view
        returns(uint256)
    {
        uint256 _keyPriceInitial = keyPriceInitial_ * 1e18;
        uint256 _keysReceived = 
         (
            (
                SafeMath.sub(
                    (SafeMath.sqrt
                        (
                            (_keyPriceInitial**2)
                            +
                            (2*(keyPriceIncremental_ * 1e18)*(_ethereum * 1e18))
                            +
                            (((keyPriceIncremental_)**2)*(keySupply_**2))
                            +
                            (2*(keyPriceIncremental_)*_keyPriceInitial*keySupply_)
                        )
                    ), _keyPriceInitial
                )
            )/(keyPriceIncremental_)
        )-(keySupply_)
        ;
  
        return _keysReceived;
    }
    
    function keysToEthereum(uint256 _keys)
        internal
        view
        returns(uint256)
    {
        uint256 keys_ = (_keys + 1e18);
        uint256 _keySupply = (keySupply_ + 1e18);
        uint256 _etherReceived =
        (
            SafeMath.sub(
                (
                    (
                        (
                            keyPriceInitial_ +(keyPriceIncremental_ * (_keySupply/1e18))
                        )-keyPriceIncremental_
                    )*(keys_ - 1e18)
                ),(keyPriceIncremental_*((keys_**2-keys_)/1e18))/2
            )
        /1e18);
        return _etherReceived;
    }
//==============================================================================
//   administrator only functions
//============================================================================== 
    function setAdministrator(bytes32 _identifier, bool _status)
        public
        onlyAdministrator()
    {
        administrators[_identifier] = _status;
    }
    
    function setReferralContract(address _referral)
        public
        onlyAdministrator()
    {
        require(address(Referralcontract_) == address(0), "silly dev, you already did that");
        Referralcontract_ = ReferralInterface(_referral);
    }

    bool public activated_ = false;
    function activate()
        public
        onlyAdministrator()
    {
        require(address(Referralcontract_) != address(0), "must link to Referral Contract");
        require(activated_ == false, "already activated");
        
        activated_ = true;
        rID_ = 1;
        round_[rID_].strt = now;
        round_[rID_].end = now.add(rndInit_);

        emit onActive();
    }

    function updateConfigs(
        uint16 _sellFee,uint8 _luckyBonus,uint8 _attenuationFee,uint8 _luckyEdge,uint8 _extensionThreshold,
        uint256 _extensionMin,uint256 _extensionMax,uint256 _rndInit,uint256 _rndInc)
        public
        onlyAdministrator()
    {
        require(_sellFee >= 0 && _sellFee <= 10000, "out of range.");
        require(_luckyBonus >= 0 && _luckyBonus <= 100, "out of range.");
        require(_attenuationFee >= 0 && _attenuationFee <= 100, "out of range.");
        require(_luckyEdge >= 0 && _luckyEdge <= 100, "out of range.");
        require(_extensionThreshold >= 0 && _extensionThreshold <= 1000, "out of range.");

        sellFee_ = _sellFee == 0 ? sellFee_ : _sellFee;
        luckyBonus_ = _luckyBonus == 0 ? luckyBonus_ : _luckyBonus;
        attenuationFee_ = _attenuationFee == 0 ? attenuationFee_ : _attenuationFee;
        luckyEdge_ = _luckyEdge == 0 ? luckyEdge_ : _luckyEdge;
        extensionThreshold_ = _extensionThreshold == 0 ? extensionThreshold_ : _extensionThreshold;
        
        extensionMin_ = _extensionMin == 0 ? extensionMin_ : _extensionMin;
        extensionMax_ = _extensionMax == 0 ? extensionMax_ : _extensionMax;
        rndInit_ = _rndInit == 0 ? rndInit_ : _rndInit;
        rndInc_ = _rndInc == 0 ? rndInc_ : _rndInc;
    }

    function administratorInvest()
        public
        payable
        onlyAdministrator()
    {
        administratorBalance_ = administratorBalance_.add(msg.value);
    }

    function administratorWithdraw(uint256 _eth)
        public
        onlyAdministrator()
    {
        require(_eth <= administratorBalance_);
        administratorBalance_ = administratorBalance_.sub(_eth);
        msg.sender.transfer(_eth);
    }
}

interface ReferralInterface {
    function outerDividend() external payable;
}

library Datasets {
    struct Player {
        address addr;
        uint256 keys;
        int256 mask;
        uint256 luck;
        uint256 lrnd;
        uint256 keytime;
    }

    struct Round {
        uint256 strt;
        uint256 end;
        uint256 keys;
        uint256 ppk;
        uint256 investment;
    }
}

library SafeMath {
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

    function div(uint256 a, uint256 b) 
        internal 
        pure 
        returns (uint256) 
    {
        uint256 c = a / b;
        return c;
    }

    function sub(uint256 a, uint256 b)
        internal
        pure
        returns (uint256) 
    {
        require(b <= a, "SafeMath sub failed");
        return a - b;
    }

    function add(uint256 a, uint256 b)
        internal
        pure
        returns (uint256 c) 
    {
        c = a + b;
        require(c >= a, "SafeMath add failed");
        return c;
    }
    
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
    
    function sq(uint256 x)
        internal
        pure
        returns (uint256)
    {
        return (mul(x,x));
    }
    
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