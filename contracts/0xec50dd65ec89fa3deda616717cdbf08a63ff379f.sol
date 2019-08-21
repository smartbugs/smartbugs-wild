pragma solidity ^0.4.0;

/**
 * Math operations with safety checks
 */
contract SafeMath {
    function safeMul(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a * b;
        require(a == 0 || c / a == b);
        return c;
    }

    function safeDiv(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0);
        uint256 c = a / b;
        require(a == b * c + a % b);
        return c;
    }

    function safeSub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a);
        return a - b;
    }

    function safeAdd(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a && c >= b);
        return c;
    }

    function safeSqrt(uint256 x) internal pure returns (uint256 y) {
        uint256 z = (x + 1) / 2;
        y = x;
        while (z < y) {
            y = z;
            z = (x / z + z) / 2;
        }
        require(safeMul(y, y) <= x);
    }
}

contract CrossroadsCoin is SafeMath {
    address public owner;
    string public name;
    string public symbol;
    uint8 public constant decimals = 18;
    uint16 public constant exchangeRate = 10000; // handling fee, 1/10000

    uint256 public initialRate; // initial ether to CRC rate
    uint256 public minRate; // min ether to CRC rate, minRate should no more than initial rate

    // rate curve: rate(x) = initialRate - x / k, x represent address(this).balance
    // k should meet minRate = initialRate - destEtherNum / k
    // so k value is destEtherNum / (initialRate - minRate)
    uint256 public destEtherNum; // when contract receive destEtherNum ether, all CRC released
    uint256 public k;

    // supply curve: totalSupply = initialRate * x - x^2/(2*k);
    // so, while x reach to destEtherNum, the totalSupply = destEtherNum * (initialRate + minRate) / 2
    uint256 public totalSupply = 0; // current supply is 0

    /* This creates an array with all balances */
    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approve(address indexed from, address indexed to, uint256 value);

    event Exchange(address indexed who, uint256 value); // use ether exchange CRC

    event Redeem(address indexed who, uint256 value); // use CRC redeem ether


    // can accept ether, exchange CRC to msg.sender
    function() public payable {
        require(address(this).balance <= destEtherNum);
        uint256 newSupply = calSupply(address(this).balance);
        uint256 returnCRCNum = SafeMath.safeSub(newSupply, totalSupply);
        totalSupply = newSupply;
        if (msg.sender != owner) {
            uint256 fee = SafeMath.safeDiv(returnCRCNum, exchangeRate);
            balanceOf[owner] = SafeMath.safeAdd(balanceOf[owner],
                fee);
            emit Transfer(msg.sender, owner, fee);
            returnCRCNum = SafeMath.safeSub(returnCRCNum, fee);
        }
        balanceOf[msg.sender] = SafeMath.safeAdd(balanceOf[msg.sender],
            returnCRCNum);
        emit Exchange(msg.sender, returnCRCNum);
        emit Transfer(address(0x0), msg.sender, returnCRCNum);
    }

    // rate curve: rate(x) = initialRate - x / k, x represent address(this).balance
    function calRate() public view returns (uint256){
        uint256 x = address(this).balance;
        return SafeMath.safeSub(initialRate, SafeMath.safeDiv(x, k));
    }

    // x represent address(this).balance
    // totalSupply = initialRate * x - x^2/(2*k)
    function calSupply(uint256 x) public view returns (uint256){
        uint256 opt1 = SafeMath.safeMul(initialRate, x);
        uint256 opt2 = SafeMath.safeDiv(SafeMath.safeMul(x, x),
            SafeMath.safeMul(2, k));
        return SafeMath.safeSub(opt1, opt2);
    }

    // because totalSupply = initialRate * x - x^2/(2*k), x represent address(this).balance
    // so, x = initialRate * k - sqrt((initialRate * k)^2 - 2 * k * totalSupply)
    function calEtherNumBySupply(uint256 y) public view returns (uint256){
        uint256 opt1 = SafeMath.safeMul(initialRate, k);
        uint256 sqrtOpt1 = SafeMath.safeMul(opt1, opt1);
        uint256 sqrtOpt2 = SafeMath.safeMul(2, SafeMath.safeMul(k, y));
        uint256 sqrtRes = SafeMath.safeSqrt(SafeMath.safeSub(sqrtOpt1, sqrtOpt2));
        return SafeMath.safeSub(SafeMath.safeMul(initialRate, k), sqrtRes);
    }

    /* Initializes contract with initial supply tokens to the creator of the contract */
    constructor(uint256 _initialRate, uint256 _minRate, uint256 _destEtherNum) public {
        owner = msg.sender;
        name = "CrossroadsCoin";
        symbol = "CRC";
        // set exchangeRate
        require(_minRate <= _initialRate);
        require(_destEtherNum > 0);
        initialRate = _initialRate;
        minRate = _minRate;
        destEtherNum = _destEtherNum;
        k = SafeMath.safeDiv(_destEtherNum, SafeMath.safeSub(_initialRate, _minRate));
    }

    /* Send coins */
    function transfer(address _to, uint256 _value)
    public {
        // Prevent transfer to 0x0 address.
        require(_to != 0x0);
        require(_value > 0);
        // Check if the sender has enough
        require(balanceOf[msg.sender] >= _value);
        // Check for overflows
        require(balanceOf[_to] + _value > balanceOf[_to]);
        if (_to == address(this)) {
            redeem(_value);
        } else {
            // Add the _value to the recipient
            balanceOf[_to] = SafeMath.safeAdd(balanceOf[_to], _value);
        }
        // Subtract from the sender
        balanceOf[msg.sender] = SafeMath.safeSub(balanceOf[msg.sender], _value);
        // Notify anyone listening that this transfer took place
        emit Transfer(msg.sender, _to, _value);
    }

    /* Allow another contract to spend some tokens in your behalf */
    function approve(address _spender, uint256 _value)
    public returns (bool success) {
        require(_value > 0);
        allowance[msg.sender][_spender] = _value;
        return true;
    }


    /* A contract attempts to get the coins */
    function transferFrom(address _from, address _to, uint256 _value)
    public returns (bool success) {
        // Prevent transfer to 0x0 address.
        require(_to != 0x0);
        require(_value > 0);
        // Check if the sender has enough
        require(balanceOf[_from] >= _value);
        // Check for overflows
        require(balanceOf[_to] + _value > balanceOf[_to]);
        // Check allowance
        require(_value <= allowance[_from][msg.sender]);
        if (_to == address(this)) {
            redeem(_value);
        } else {
            // Add the _value to the recipient
            balanceOf[_to] = SafeMath.safeAdd(balanceOf[_to], _value);
        }
        // Subtract from the sender
        balanceOf[_from] = SafeMath.safeSub(balanceOf[_from], _value);
        allowance[_from][msg.sender] = SafeMath.safeSub(allowance[_from][msg.sender], _value);
        emit Transfer(_from, _to, _value);
        return true;
    }

    function redeem(uint256 _value) private {
        if (msg.sender != owner) {
            uint256 fee = SafeMath.safeDiv(_value, exchangeRate);
            balanceOf[owner] = SafeMath.safeAdd(balanceOf[owner], fee);
            emit Transfer(msg.sender, owner, fee);
            _value = SafeMath.safeSub(_value, fee);
        }
        uint256 newSupply = SafeMath.safeSub(totalSupply, _value);
        require(newSupply >= 0);
        uint256 newEtherNum = calEtherNumBySupply(newSupply);
        uint256 etherBalance = address(this).balance;
        require(newEtherNum <= etherBalance);
        uint256 redeemEtherNum = SafeMath.safeSub(etherBalance, newEtherNum);
        msg.sender.transfer(redeemEtherNum);
        totalSupply = newSupply;
        emit Redeem(msg.sender, redeemEtherNum);
    }
}