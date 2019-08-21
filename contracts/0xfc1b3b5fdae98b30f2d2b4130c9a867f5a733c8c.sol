pragma solidity ^0.4.24;

contract WorldByEth {
    using SafeMath for *;

    string constant public name = "ETH world cq";
    string constant public symbol = "ecq";
    uint256 public rID_;
    address public comaddr = 0x9ca974f2c49d68bd5958978e81151e6831290f57;
    mapping(uint256 => uint256) public pot_;
    mapping(uint256 => mapping(uint256 => Ctry)) public ctry_;
    uint public gap = 1 hours;
    address public lastplayer = 0x9ca974f2c49d68bd5958978e81151e6831290f57;
    address public lastwinner;
    uint[] public validplayers;
    uint public ctnum = 180;
    uint public timeleft;
    bool public active = true;
    bool public autobegin = true;
    uint public max = 24 hours;
    //mapping(uint256 => address) public lastrdowner;

    struct Ctry {
        uint256 id;
        uint256 price;
        bytes32 name;
        bytes32 mem;
        address owner;
    }

    mapping(uint256 => uint256) public totalinvest_;

    modifier isHuman() {
        address _addr = msg.sender;
        require(_addr == tx.origin);
        
        uint256 _codeLength;
        
        assembly {_codeLength := extcodesize(_addr)}
        require(_codeLength == 0, "sorry humans only");
        _;
    }
    
    constructor()
    public
    {
        rID_++;
        validplayers.length = 0;
        timeleft = now + max;
    }

    function getvalid()
    public
    returns(uint[]){
        return validplayers;
    }
    
    function changemem(uint id, bytes32 mem)
    isHuman
    public
    payable
    {
        require(msg.sender == ctry_[rID_][id].owner);
        if (mem != ""){
            ctry_[rID_][id].mem = mem;
        }
    }

    function buy(uint id, bytes32 mem)
    isHuman
    public
    payable
    {
        require(active == true);
        require(msg.value >= 0.02 ether);
        require(msg.value >= ctry_[rID_][id].price);
        require(id <= ctnum);

        if (validplayers.length <= 50) {
            timeleft = now + max;
        }
        
        if (mem != ""){
            ctry_[rID_][id].mem = mem;
        }

        if (update() == true) {
            uint pot = (msg.value).div(10);
            pot_[rID_] += pot;

            if (rID_> 1){
                if (ctry_[rID_-1][id].owner != address(0x0)) {
                    ctry_[rID_-1][id].owner.send((msg.value).div(50));
                }
            }
        
            if (ctry_[rID_][id].owner != address(0x0)){
                ctry_[rID_][id].owner.transfer((msg.value).mul(86).div(100));
            }else{
                validplayers.push(id);
            }
            ctry_[rID_][id].owner = msg.sender;
            ctry_[rID_][id].price = (msg.value).mul(14).div(10);
        }else{
            rID_++;
            validplayers.length = 0;
            ctry_[rID_][id].owner = msg.sender;
            ctry_[rID_][id].price = 0.028 ether;
            validplayers.push(id);
            (msg.sender).send(msg.value - 0.02 ether);
        }

        lastplayer = msg.sender;
        totalinvest_[rID_] += msg.value;
        ctry_[rID_][id].id = id;
    }

    function update()
    private
    returns(bool)
    {
        if (now > timeleft) {
            uint win = pot_[rID_].mul(6).div(10);
            lastplayer.transfer(win);
            lastwinner = lastplayer;
            pot_[rID_+1] += pot_[rID_].div(5);
            pot_[rID_] = 0;
            timeleft = now + max;
            if (autobegin == false){
                active = false;  // waiting for set open again
            }
            return false;
        }

        if (validplayers.length < ctnum) {
            timeleft += gap;
        }
        
        if (timeleft > now + max) {
            timeleft = now + max;
        }
        return true;
    }

    function()
    public
    payable
    {
        
    }
    
    // add to pot
    function pot()
    public
    payable
    {
        pot_[rID_] += msg.value;
    }

    modifier onlyDevs() {
        require(
            msg.sender == 0x9ca974f2c49d68bd5958978e81151e6831290f57,
            "only team just can activate"
        );
        _;
    }

    // add more countries
    function setctnum(uint id)
    onlyDevs
    public
    {
        require(id > 180);
        ctnum = id;
    }
    
    // withdraw unreachable eth
    function withcom()
    onlyDevs
    public
    {
        if (address(this).balance > pot_[rID_]){
            uint left = address(this).balance - pot_[rID_];
            comaddr.transfer(left);
        }
    }
    
    function setActive(bool _auto)
    onlyDevs
    public
    {
        active = true;
        autobegin = _auto;
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

    /**
    * @dev Integer division of two numbers, truncating the quotient.
    */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // assert(b > 0); // Solidity automatically throws when dividing by 0
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
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