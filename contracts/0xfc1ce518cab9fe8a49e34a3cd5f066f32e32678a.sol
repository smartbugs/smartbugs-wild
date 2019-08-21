pragma solidity ^0.4.16;

contract SafeMath {
    function safeMul(uint a, uint b) pure internal returns (uint) {
        uint c = a * b;
        assert(a == 0 || c / a == b);
        return c;
    }

    function safeSub(uint a, uint b) pure internal returns (uint) {
        assert(b <= a);
        return a - b;
    }

    function safeAdd(uint a, uint b) pure internal returns (uint) {
        uint c = a + b;
        assert(c >= a && c >= b);
        return c;
    }
}

// ERC20代币
contract Token {
    function totalSupply() public constant returns (uint256 supply);

    function balanceOf(address _owner) public constant returns (uint256 balance);

    function transfer(address _to, uint256 _value) public returns (bool success);

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);

    function approve(address _spender, uint256 _value) public returns (bool success);

    function allowance(address _owner, address _spender) public constant returns (uint256 remaining);

    event Transfer(address indexed _from, address indexed _to, uint256 _value);

    event Approval(address indexed _owner, address indexed _spender, uint256 _value);

    uint public decimals;
    string public symbol;
    string public name;
}

contract EKTSale is SafeMath {
    Token public token;
    address public owner;
    bool public stopped;

    // 阶段
    uint private constant BEFORE_SALE = 0;
    uint private constant IN_SALE = 1;
    uint private constant FINISHED = 2;

    // ICO总代币数量
    uint public totalQuantity =  1.5 * 10000 * 10000 * 100000000;

    // 已卖出代币数量
    uint public saleQuantity = 0;

    // 收入的ETH数量
    uint public ethQuantity = 0;

    // 提现的代币数量
    uint public withdrawQuantity = 0;

    // ICO最小以太值
    uint public minEth = 0.1 ether;

    // ICO最大以太值
    uint public maxEth = 1000 ether;

    // 开始时间 2017-12-24 19:00:00
    uint public openTime = 1514113200;
    // 结束时间 2018-01-05 19:00:00
    uint public closeTime = 1515150000;
    // 价格
    uint public price = 5696;

    modifier isOwner {
        assert(owner == msg.sender);
        _;
    }

    modifier validAddress(address _address) {
        assert(0x0 != _address);
        _;
    }

    modifier validPeriod {
        assert(now >= openTime && now < closeTime);
        _;
    }

    modifier validQuantity {
        assert(totalQuantity >= saleQuantity);
        _;
    }

    modifier validEth {
        assert(msg.value >= minEth && msg.value <= maxEth);
        _;
    }

    event Buy(address indexed sender, uint eth, uint token);
    event SaleStop();

    function EKTSale(address _token)
        public
        validAddress(_token)
    {
        owner = msg.sender;
        token = Token(_token);
    }


    function setPrice(uint _price)
        public
        isOwner
        returns(bool)
    {
        assert(_price > 0);
        price = _price;
        return true;
    }

    function ()
        public
        payable
    {
        buy();
    }

    function buy()
        public
        payable
        validAddress(token)      // 代币是否已设置
        validEth        // 以太是否足够
        validPeriod     // 是否在ICO期间
        validQuantity   // 代币是否已卖完
    {
        uint eth = msg.value;

        // 计算代币数量
        uint quantity = eth * price / 10 ** 10;

        // 是否超出剩余代币
        uint leftQuantity = safeSub(totalQuantity, saleQuantity);
        if (quantity > leftQuantity) {
            quantity = leftQuantity;
        }

        saleQuantity = safeAdd(saleQuantity, quantity);
        ethQuantity = safeAdd(ethQuantity, eth);

        // 发送代币
        require(token.transfer(msg.sender, quantity));

        // 生成日志
        Buy(msg.sender, eth, quantity);
    }

    function withdraw(uint amount)
        public
        isOwner
    {
        uint period = getPeriod();
        require(period == FINISHED);

        require(this.balance >= amount);
        msg.sender.transfer(amount);
    }

    function withdrawToken(uint amount)
        public
        isOwner
    {
        uint period = getPeriod();
        require(period == FINISHED);

        withdrawQuantity += safeAdd(withdrawQuantity, amount);
        require(token.transfer(msg.sender, amount));
    }

    function getPeriod()
        public
        constant
        returns (uint)
    {
        if (stopped) {
            return FINISHED;
        }

        if (now < openTime) {
            return BEFORE_SALE;
        }

        if (totalQuantity == saleQuantity) {
            return FINISHED;
        }

        if (now >= openTime && now < closeTime) {
            return IN_SALE;
        }

        return FINISHED;
    }

    function stopSale()
        public
        isOwner
        returns (bool)
    {
        stopped = true;
        SaleStop();
        return true;
    }


}