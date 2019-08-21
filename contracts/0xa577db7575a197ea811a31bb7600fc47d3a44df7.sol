pragma solidity ^0.4.24;

contract SuperBank {
    using SafeMath for *;

    struct Investment {
        uint256 amount;
        uint256 safeAmount;
        uint256 atBlock;
        uint256 withdraw;
        uint256 canWithdraw;
        uint256 maxWithdraw;
    }

    uint256 public startBlockNo;
    uint256 public startTotal;

    uint256 public total;
    uint256 public people;
    uint256 public floatFund;
    uint256 public safeFund;

    uint256 public bonus;
    uint256 public bonusEndTime;
    address public leader;
    uint256 public lastPrice;

    mapping (address => Investment) public invested_m;

    address public owner; 

    constructor()
        public
    {
        owner = msg.sender;
        startBlockNo = block.number + (5900 * 14);
        // 1000 ether
        startTotal = 1000000000000000000000;
    }

    modifier onlyOwner() 
    {
        require(owner == msg.sender, "only owner can do it");
        _;    
    }

    /**
     * @dev invest
     * 
     * radical investment
     */
    function()
        public
        payable
    {
        if (msg.value == 0)
        {
            withdraw();
        } else {
            invest(2, address(0));
        }
    }

    /**
     * @dev invest
     */
    function invest(uint8 _type, address _ref)
        public
        payable
    {
        uint256 _eth = msg.value;
        uint256 _now = now;
        uint256 _safe_p;
        uint256 _other_p;
        uint256 _return_p;
        uint256 _safeAmount;
        uint256 _otherAmount;
        uint256 _returnAmount;
        uint256 _teamAmount;
        uint256 _promoteAmount;

        require(msg.value >= 1000000000, "not enough ether");

        withdraw();

        if (invested_m[msg.sender].amount == 0)
        {
            people = people.add(1);
        }

        if (_type == 1)
        {
            _safe_p = 80;
            _other_p = 5;
            _return_p = 130;
        } else {
            _safe_p = 40;
            _other_p = 25;
            _return_p = 170;
        }

        _safeAmount = (_eth.mul(_safe_p) / 100);
        _returnAmount = (_eth.mul(_return_p) / 100);

        invested_m[msg.sender].amount = _eth.add(invested_m[msg.sender].amount);
        invested_m[msg.sender].safeAmount = _safeAmount.add(invested_m[msg.sender].safeAmount);
        invested_m[msg.sender].maxWithdraw = _returnAmount.add(invested_m[msg.sender].maxWithdraw);

        total = total.add(_eth);
        safeFund = safeFund.add(_safeAmount);
        
        //start ?
        if (block.number < startBlockNo && startTotal <= total) 
        {
            startBlockNo = block.number;
        }

        if (_ref != address(0) && _ref != msg.sender)
        {
            uint256 _refTotal = invested_m[_ref].amount;
            if (_refTotal < 5000000000000000000)
            {
                _promoteAmount = (_eth.mul(3) / 100);
                _teamAmount = (_eth.mul(7) / 100);
            } else if (_refTotal < 20000000000000000000) {
                _promoteAmount = (_eth.mul(5) / 100);
                _teamAmount = (_eth.mul(5) / 100);
            } else {
                _promoteAmount = (_eth.mul(7) / 100);
                _teamAmount = (_eth.mul(3) / 100);
            }

            _ref.transfer(_promoteAmount);
        } else {
            _teamAmount = (_eth.mul(10) / 100);
        }

        owner.transfer(_teamAmount);

        _otherAmount = (_eth.mul(_other_p) / 100);

        floatFund = floatFund.add(_otherAmount);

        // bonus
        if (bonusEndTime != 0 && bonusEndTime < _now)
        {   
            uint256 bonus_t = bonus;
            address leader_t = leader;
            bonus = 0;
            leader = address(0);
            lastPrice = 0;
            bonusEndTime = 0;
            leader_t.transfer(bonus_t);
        }
        bonus = bonus.add(_otherAmount);
    }

    /**
     * @dev withdraws
     */
    function withdraw()
        public
    {
        uint256 _blockNo = block.number;
        uint256 _leaveWithdraw = invested_m[msg.sender].maxWithdraw.sub(invested_m[msg.sender].canWithdraw);
        uint256 _blockSub;

        if (_blockNo < startBlockNo)
        {
            _blockSub = 0;
        } else {
            if (invested_m[msg.sender].atBlock < startBlockNo)
            {
                _blockSub = _blockNo.sub(startBlockNo);
            } else {
                _blockSub = _blockNo.sub(invested_m[msg.sender].atBlock);
            }
        }

        uint256 _canAmount = ((invested_m[msg.sender].amount.mul(5) / 100).mul(_blockSub) / 5900);

        if (_canAmount > _leaveWithdraw)
        {
            _canAmount = _leaveWithdraw;
        }
        invested_m[msg.sender].canWithdraw = _canAmount.add(invested_m[msg.sender].canWithdraw);

        uint256 _realAmount = invested_m[msg.sender].canWithdraw.sub(invested_m[msg.sender].withdraw);
        
        if (_realAmount > 0)
        {
            if (invested_m[msg.sender].safeAmount >= _realAmount)
            {
                safeFund = safeFund.sub(_realAmount);
                invested_m[msg.sender].safeAmount = invested_m[msg.sender].safeAmount.sub(_realAmount);
            } else {
                uint256 _extraAmount = _realAmount.sub(invested_m[msg.sender].safeAmount);
                if (floatFund >= _extraAmount)
                {
                    floatFund = floatFund.sub(_extraAmount);
                } else {
                    _realAmount = floatFund.add(invested_m[msg.sender].safeAmount);
                    floatFund = 0;
                }
                safeFund = safeFund.sub(invested_m[msg.sender].safeAmount);
                invested_m[msg.sender].safeAmount = 0;
            }
        }

        invested_m[msg.sender].withdraw = _realAmount.add(invested_m[msg.sender].withdraw);
        invested_m[msg.sender].atBlock = _blockNo;

        if (_realAmount > 0)
        {
            msg.sender.transfer(_realAmount);
        }
    }

    /**
     * @dev bid
     */
    function bid(address _ref)
        public
        payable
    {
        uint256 _eth = msg.value;
        uint256 _ethUse = msg.value;
        uint256 _now = now;
        uint256 _promoteAmount;
        uint256 _teamAmount;
        uint256 _otherAmount;

        require(block.number >= startBlockNo, "Need start");

        // bonus
        if (bonusEndTime != 0 && bonusEndTime < _now)
        {   
            uint256 bonus_t = bonus;
            address leader_t = leader;
            bonus = 0;
            leader = address(0);
            lastPrice = 0;
            bonusEndTime = 0;
            leader_t.transfer(bonus_t);
        }

        uint256 _maxPrice = (1000000000000000000).add(lastPrice);
        // less than (lastPrice + 0.1Ether) ?
        require(_eth >= (100000000000000000).add(lastPrice), "Need more Ether");
        // more than (lastPrice + 1Ether) ?
        if (_eth > _maxPrice)
        {
            _ethUse = _maxPrice;
            // refund
            msg.sender.transfer(_eth.sub(_ethUse));
        }

        bonusEndTime = _now + 12 hours;
        leader = msg.sender;
        lastPrice = _ethUse;

        if (_ref != address(0) && _ref != msg.sender)
        {
            uint256 _refTotal = invested_m[_ref].amount;
            if (_refTotal < 5000000000000000000)
            {
                _promoteAmount = (_ethUse.mul(3) / 100);
                _teamAmount = (_ethUse.mul(7) / 100);
            } else if (_refTotal < 20000000000000000000) {
                _promoteAmount = (_ethUse.mul(5) / 100);
                _teamAmount = (_ethUse.mul(5) / 100);
            } else {
                _promoteAmount = (_ethUse.mul(7) / 100);
                _teamAmount = (_ethUse.mul(3) / 100);
            }

            _ref.transfer(_promoteAmount);
        } else {
            _teamAmount = (_ethUse.mul(10) / 100);
        }

        owner.transfer(_teamAmount);

        _otherAmount = (_ethUse.mul(45) / 100);

        floatFund = floatFund.add(_otherAmount);
        bonus = bonus.add(_otherAmount);
    }

    /**
     * @dev change owner.
     */
    function changeOwner(address newOwner)
        onlyOwner()
        public
    {
        owner = newOwner;
    }

    /**
     * @dev getInfo
     */
    function getInfo()
        public 
        view 
        returns(uint256, uint256, uint256, uint256, uint256, uint256, uint256, uint256, address, uint256)
    {
        return (
            startBlockNo,
            startTotal,
            total,
            people,
            floatFund,
            safeFund,
            bonus,
            bonusEndTime,
            leader,
            lastPrice
        );
    }
}

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