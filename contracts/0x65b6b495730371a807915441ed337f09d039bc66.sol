pragma solidity 0.4.19;


contract InterfaceDeusETH {
    bool public gameOver;
    bool public gameOverByUser;
    function totalSupply() public view returns (uint256);
    function livingSupply() public view returns (uint256);
    function getState(uint256 _id) public returns (uint256);
    function getHolder(uint256 _id) public returns (address);
}


contract FundsKeeper {
    using SafeMath for uint256;
    InterfaceDeusETH private lottery = InterfaceDeusETH(0x0);
    bool public started = false;

    // address of tokens
    address public deusETH;

    uint256 public weiReceived;

    // address of team
    address public owner;
    bool public salarySent = false;

    uint256 public totalPayments = 0;

    mapping(uint256 => bool) public payments;

    event Bank(uint256 indexed _sum, uint256 indexed _add);

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    function FundsKeeper(address _owner) public {
        require(_owner != address(0));
        owner = _owner;
    }

    function () external payable {
        weiReceive();
    }

    function getGain(uint256 _id) public {
        require((lottery.gameOver() && salarySent) || lottery.gameOverByUser());
        require(lottery.getHolder(_id) == msg.sender);
        require(lottery.getState(_id) == 1); //living token only
        require(payments[_id] == false);

        address winner = msg.sender;

        uint256 gain = calcGain();

        require(gain != 0);
        require(this.balance >= gain);

        totalPayments = totalPayments.add(gain);
        payments[_id] = true;

        winner.transfer(gain);
    }

    function setLottery(address _lottery) public onlyOwner {
        require(!started);
        lottery = InterfaceDeusETH(_lottery);
        deusETH = _lottery;
        started = true;
    }

    function getTeamSalary() public onlyOwner {
        require(!salarySent);
        require(lottery.gameOver());
        require(!lottery.gameOverByUser());
        salarySent = true;
        weiReceived = this.balance;
        uint256 salary = weiReceived/10;
        weiReceived = weiReceived.sub(salary);
        owner.transfer(salary);
    }

    function weiReceive() internal {
        Bank(this.balance, msg.value);
    }

    function calcGain() internal returns (uint256) {
        if (lottery.gameOverByUser() && (weiReceived == 0)) {
            weiReceived = this.balance;
        }
        return weiReceived/lottery.livingSupply();
    }
}


library SafeMath {
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a * b;
        assert(a == 0 || c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a / b;
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }
}