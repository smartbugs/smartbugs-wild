pragma solidity ^0.4.25;

interface ERC20TokenInterface {
    function balanceOf(address _who) external view returns (uint256);
    function transfer(address _to, uint256 _value) external returns (bool);
}

contract WorldByEth {

    using SafeMath for *;
    string constant public name = "ETH world top";
    string constant public symbol = "cqwt";
    uint public gap = 2 minutes;
    uint public ctnum = 217;
    uint public deadline;
    bool public active = false;
    uint public max = 1 hours;
    uint constant min_purchase = 0.05 ether;
    address public owner;
    address private nextOwner;
    address public lastplayer = 0x8F92200Dd83E8f25cB1daFBA59D5532507998307;
    address public comaddr = 0x8F92200Dd83E8f25cB1daFBA59D5532507998307;
    address public lastwinner;
    uint[] public validplayers;
    uint256 public rID_;
    mapping(uint256 => uint256) public pot_;
    mapping(uint256 => mapping(uint256 => Ctry)) public ctry_;
    mapping(uint256 => uint256) public totalinvest_;

    uint public _rate = 1000;

    struct Ctry {
        uint256 id;
        uint256 price;
        bytes32 name;
        bytes32 mem;
        address owner;
    }

    event LOG_Winner(address addr, uint amount);
    constructor()
    public {
        rID_++;
        validplayers.length = 0;
        deadline = now + max;
        owner = msg.sender;
    }
    modifier isActive {
        if (!active) revert();
        _;
    }

    modifier isHuman() {
        address _addr = msg.sender;
        require(_addr == tx.origin);

        uint256 _codeLength;

        assembly {
            _codeLength: = extcodesize(_addr)
        }
        require(_codeLength == 0, "sorry humans only");
        _;
    }

    modifier onlyDevs() {
        require(
            msg.sender == 0x4E10a18A23d1BD1DF6331C48CFD75d31F125cA30 ||
            msg.sender == 0x8F92200Dd83E8f25cB1daFBA59D5532507998307,
            "only team just can activate"
        );
        _;
    }

    function getvalid() constant
    public
    returns(uint[]) {
        return validplayers;
    }

    function changeRemark(uint id, bytes32 mem) isActive
    isHuman
    public
    payable {
        require(msg.sender == ctry_[rID_][id].owner, "msgSender should be countryOwner.");
        if (mem != "") {
            ctry_[rID_][id].mem = mem;
        }
    }

    function pot() isActive
    public
    payable {
        pot_[rID_] += msg.value;
    }

    function setActive(uint idnum)
    onlyDevs
    public {
        if (active) {
            return;
        }
        active = true;
        ctnum = idnum;
    }

    function withcom()
    onlyDevs
    public {
        if (address(this).balance > pot_[rID_]) {
            comaddr.transfer(address(this).balance - pot_[rID_]);
        }
    }

    function settimmer(uint _gap)
    private {
        deadline += _gap;
        if (deadline > now + max) {
            deadline = now + max;
        }
    }

    function turnover()
    private
    returns(bool) {
        if (validplayers.length < ctnum) {
            settimmer(max);
            return true;
        }

        if (now > deadline) {
            uint win = pot_[rID_].mul(6).div(10);
            lastplayer.transfer(win);
            lastwinner = lastplayer;
            emit LOG_Winner(lastwinner, win);
            pot_[rID_ + 1] += pot_[rID_] - win;
            pot_[rID_] = 0;
            deadline = now + max;
            return false;
        }

        settimmer(gap);
        return true;
    }

    function ()
    public
    payable {}

    function buyOne(uint id, bytes32 memo) isHuman external payable {
        require(msg.value >= min_purchase, "Amount should be within range.");
        require(msg.value >= ctry_[rID_][id].price, "Price should be within range.");
        require(id>0 && id <= ctnum, "CountryNum should be within ctnum.");
        buy(id, memo, msg.value);
    }
    
    function buyManyCountries(uint[] countryIds) isHuman
    external
    payable {
        uint restValue = msg.value;
        require(restValue >= countryIds.length.mul(min_purchase), "Amount should be within range.");

        for (uint i = 0; i < countryIds.length; i++) {
            uint countryid = countryIds[i];
            if (countryid == 0 || countryid > ctnum) {
                continue;
            }

            uint buyprice = min_purchase;
            if (ctry_[rID_][countryid].price > 0) {
                buyprice = ctry_[rID_][countryid].price;
            }

            if (restValue < buyprice) {
                continue;
            }

            buy(countryid, "", buyprice);
            restValue = restValue.sub(buyprice);
        }

        if (restValue > 0 ){
            (msg.sender).transfer(restValue);
        }
    }

    function devi(uint id,uint _price)
    private
    {
        if( rID_ <= 1){
            return;
        }

        if (rID_ > 2){
            if (ctry_[rID_ - 1][id].owner != address(0x0)) {
                ctry_[rID_ - 1][id].owner.transfer((_price).mul(15).div(1000));
            }
        }

        if (ctry_[1][id].owner != address(0x0)) {
            ctry_[1][id].owner.transfer((_price).mul(15).div(1000));
        }
    }

    function buy(uint id, bytes32 memo, uint _price) isActive private {
        if (memo != "") {
            ctry_[rID_][id].mem = memo;
        }

        if (turnover() == true) {
            uint gamepot = (_price).mul(7).div(100);
            pot_[rID_] += gamepot;

            devi(id,_price);
            
            if (ctry_[rID_][id].owner != address(0x0)) {
                ctry_[rID_][id].owner.transfer((_price).mul(88).div(100)); 
            } else {
                validplayers.push(id);
            }

            ctry_[rID_][id].owner = msg.sender;
            ctry_[rID_][id].price = (_price).mul(14).div(10);
            
        } else {
            rID_++;
            validplayers.length = 0;
            ctry_[rID_][id].owner = msg.sender;
            ctry_[rID_][id].price = 0.07 ether;
            validplayers.push(id);
            (msg.sender).transfer(_price - min_purchase);
            _price = min_purchase;
        }
        lastplayer = msg.sender;
        totalinvest_[rID_] += _price;
        ctry_[rID_][id].id = id;
    }
}

library SafeMath {
    function mul(uint256 a, uint256 b)
    internal
    pure
    returns(uint256 c) {
        if (a == 0) {
            return 0;
        }
        c = a * b;
        require(c / a == b, "SafeMath mul failed");
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns(uint256) {
        uint256 c = a / b;
        return c;
    }

    function sub(uint256 a, uint256 b)
    internal
    pure
    returns(uint256) {
        require(b <= a, "SafeMath sub failed");
        return a - b;
    }

    function add(uint256 a, uint256 b)
    internal
    pure
    returns(uint256 c) {
        c = a + b;
        require(c >= a, "SafeMath add failed");
        return c;
    }

    function sqrt(uint256 x)
    internal
    pure
    returns(uint256 y) {
        uint256 z = ((add(x, 1)) / 2);
        y = x;
        while (z < y) {
            y = z;
            z = ((add((x / z), z)) / 2);
        }
    }


    function sq(uint256 x)
    internal
    pure
    returns(uint256) {
        return (mul(x, x));
    }


    function pwr(uint256 x, uint256 y)
    internal
    pure
    returns(uint256) {
        if (x == 0)
            return (0);
        else if (y == 0)
            return (1);
        else {
            uint256 z = x;
            for (uint256 i = 1; i < y; i++)
                z = mul(z, x);
            return (z);
        }
    }
}