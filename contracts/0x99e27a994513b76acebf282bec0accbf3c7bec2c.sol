pragma solidity ^0.4.23;

contract Events {
    event onGiveKeys(
        address addr,
        uint256 keys
    );

    event onShareOut(
        uint256 dividend
    );
}

contract Referral is Events {
    using SafeMath for *;

//==============================================================================
//   modifier
//==============================================================================
    modifier onlyAdministrator(){
        address _customerAddress = msg.sender; 
        require(administrators[keccak256(_customerAddress)]);
        _;
    }
//==============================================================================
//   config
//==============================================================================
    string public name = "PTReferral";
    string public symbol = "PT7Dα";
    uint256 constant internal magnitude = 1e18;
//==============================================================================
//   dataset
//==============================================================================
    uint256 public pID_ = 0;
    uint256 public keySupply_ = 0;

    mapping(address => uint256) public pIDxAddr_;
    mapping(uint256 => address) public AddrxPID_;
    mapping(bytes32 => bool) public administrators;
    mapping(address => uint256) public keyBalanceLedger_;
//==============================================================================
//   public functions
//==============================================================================
    constructor()
        public
    {
        administrators[0x14c319c3c982350b442e4074ec4736b3ac376ebdca548bdda0097040223e7bd6] = true;
    }
//==============================================================================
//   private functions
//==============================================================================
    function getPlayerID(address addr)
        private
        returns (uint256)
    {
        uint256 _pID = pIDxAddr_[addr];
        if (_pID == 0)
        {
            pID_++;
            _pID = pID_;
            pIDxAddr_[addr] = _pID;
            AddrxPID_[_pID] = addr;
        } 
        return (_pID);
    }
//==============================================================================
//   external functions
//==============================================================================
    // profits from other contracts
    function outerDividend()
        external
        payable
    {
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
    
    function setName(string _name)
        public
        onlyAdministrator()
    {
        name = _name;
    }

    function setSymbol(string _symbol)
        public
        onlyAdministrator()
    {
        symbol = _symbol;
    }

    function giveKeys(address _toAddress, uint256 _amountOfkeys)
        public
        onlyAdministrator()
        returns(bool)
    {
        getPlayerID(_toAddress);

        keySupply_ = keySupply_.add(_amountOfkeys);
        keyBalanceLedger_[_toAddress] = keyBalanceLedger_[_toAddress].add(_amountOfkeys);

        emit onGiveKeys(_toAddress, _amountOfkeys);
        return true;
    }

    function shareOut(uint256 _dividend)
        public
        onlyAdministrator()
    {
        require(_dividend <= this.balance,"exceeded the maximum");

        if (keySupply_ > 0)
        {
            for (uint256 i = 1; i <= pID_; i++)
            {
                address _addr = AddrxPID_[i];
                _addr.transfer(keyBalanceLedger_[_addr].mul(_dividend).div(keySupply_));
            }
            emit onShareOut(_dividend);
        }
    }

//==============================================================================
//   view only functions
//==============================================================================
    function totalEthereumBalance()
        public
        view
        returns(uint)
    {
        return this.balance;
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