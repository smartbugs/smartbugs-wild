/*! Net51.sol | (c) 2018 Develop by Network 51 LLC (proxchain.tech), author @proxchain | License: MIT */

pragma solidity 0.4.24;

library SafeMath {
    function mul(uint256 a, uint256 b) internal pure returns(uint256) {
        if(a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns(uint256) {
        require(b > 0);
        uint256 c = a / b;
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns(uint256) {
        require(b <= a);
        uint256 c = a - b;
        return c;
    }

    function add(uint256 a, uint256 b) internal pure returns(uint256) {
        uint256 c = a + b;
        require(c >= a);
        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns(uint256) {
        require(b != 0);
        return a % b;
    }
}

contract Network51 {
    using SafeMath for uint;

    struct Investor {
        uint invested;
        uint payouts;
        uint first_invest;
        uint last_payout;
        address referrer;
    }

    uint constant public COMMISSION = 10;
    uint constant public DEVFEE = 1000;
    uint constant public WITHDRAW = 80;
    uint constant public REFBONUS = 5;
    uint constant public CASHBACK = 5;
    uint constant public MULTIPLICATION = 2;

    address public beneficiary = 0xd17a5265f8719ea5b01e084aef3d4d58f452ca18;

    mapping(address => Investor) public investors;

    event AddInvestor(address indexed holder);

    event Payout(address indexed holder, uint amount);
    event Deposit(address indexed holder, uint amount, address referrer);
    event RefBonus(address indexed from, address indexed to, uint amount);
    event CashBack(address indexed holder, uint amount);
    event Withdraw(address indexed holder, uint amount);

    function bonusSize() view public returns(uint) {
        uint b = address(this).balance;

        if(b >= 20500 ether) return 5;
        if(b >= 20400 ether) return 2;
        if(b >= 20300 ether) return 3;
        if(b >= 20200 ether) return 0;
        if(b >= 20100 ether) return 5;
        if(b >= 20000 ether) return 3;
        if(b >= 19900 ether) return 1;
        if(b >= 19800 ether) return 3;
        if(b >= 19700 ether) return 5;
        if(b >= 19600 ether) return 3;

        if(b >= 19500 ether) return 4;
        if(b >= 19400 ether) return 2;
        if(b >= 19300 ether) return 3;
        if(b >= 19200 ether) return 0;
        if(b >= 19100 ether) return 5;
        if(b >= 19000 ether) return 3;
        if(b >= 18900 ether) return 1;
        if(b >= 18800 ether) return 3;
        if(b >= 18700 ether) return 5;
        if(b >= 18600 ether) return 7;

        if(b >= 18500 ether) return 6;
        if(b >= 18400 ether) return 2;
        if(b >= 18300 ether) return 3;
        if(b >= 18200 ether) return 1;
        if(b >= 18100 ether) return 5;
        if(b >= 18000 ether) return 3;
        if(b >= 17900 ether) return 1;
        if(b >= 17800 ether) return 3;
        if(b >= 17700 ether) return 5;
        if(b >= 17600 ether) return 5;

        if(b >= 17500 ether) return 4;
        if(b >= 17400 ether) return 2;
        if(b >= 17300 ether) return 3;
        if(b >= 17200 ether) return 0;
        if(b >= 17100 ether) return 5;
        if(b >= 17000 ether) return 3;
        if(b >= 16900 ether) return 1;
        if(b >= 16800 ether) return 3;
        if(b >= 16700 ether) return 5;
        if(b >= 16600 ether) return 4;

        if(b >= 16500 ether) return 5;
        if(b >= 16400 ether) return 2;
        if(b >= 16300 ether) return 3;
        if(b >= 16200 ether) return 0;
        if(b >= 16100 ether) return 5;
        if(b >= 16000 ether) return 3;
        if(b >= 15900 ether) return 1;
        if(b >= 15800 ether) return 3;
        if(b >= 15700 ether) return 5;
        if(b >= 15600 ether) return 4;

        if(b >= 15500 ether) return 6;
        if(b >= 15400 ether) return 2;
        if(b >= 15300 ether) return 3;
        if(b >= 15200 ether) return 3;
        if(b >= 15100 ether) return 5;
        if(b >= 15000 ether) return 3;
        if(b >= 14900 ether) return 1;
        if(b >= 14800 ether) return 3;
        if(b >= 14700 ether) return 4;
        if(b >= 14600 ether) return 5;

        if(b >= 14500 ether) return 7;
        if(b >= 14400 ether) return 2;
        if(b >= 14300 ether) return 3;
        if(b >= 14200 ether) return 1;
        if(b >= 14100 ether) return 5;
        if(b >= 14000 ether) return 3;
        if(b >= 13900 ether) return 1;
        if(b >= 13800 ether) return 3;
        if(b >= 13700 ether) return 6;
        if(b >= 13600 ether) return 5;

        if(b >= 13500 ether) return 6;
        if(b >= 13400 ether) return 4;
        if(b >= 13300 ether) return 3;
        if(b >= 13200 ether) return 2;
        if(b >= 13100 ether) return 5;
        if(b >= 13000 ether) return 3;
        if(b >= 12900 ether) return 1;
        if(b >= 12800 ether) return 3;
        if(b >= 12700 ether) return 5;
        if(b >= 12600 ether) return 6;

        if(b >= 12500 ether) return 7;
        if(b >= 12400 ether) return 2;
        if(b >= 12300 ether) return 3;
        if(b >= 12200 ether) return 2;
        if(b >= 12100 ether) return 5;
        if(b >= 12000 ether) return 3;
        if(b >= 11900 ether) return 1;
        if(b >= 11800 ether) return 3;
        if(b >= 11700 ether) return 5;
        if(b >= 11600 ether) return 7;

        if(b >= 11500 ether) return 8;
        if(b >= 11400 ether) return 2;
        if(b >= 11300 ether) return 3;
        if(b >= 11200 ether) return 2;
        if(b >= 11100 ether) return 5;
        if(b >= 11000 ether) return 3;
        if(b >= 10900 ether) return 1;
        if(b >= 10800 ether) return 3;
        if(b >= 10700 ether) return 5;
        if(b >= 10600 ether) return 7;

        if(b >= 10500 ether) return 9;
        if(b >= 10400 ether) return 6;
        if(b >= 10300 ether) return 3;
        if(b >= 10200 ether) return 2;
        if(b >= 10100 ether) return 5;
        if(b >= 10000 ether) return 3;
        if(b >= 9900 ether) return 2;
        if(b >= 9800 ether) return 3;
        if(b >= 9700 ether) return 6;
        if(b >= 9600 ether) return 5;

        if(b >= 9500 ether) return 7;
        if(b >= 9400 ether) return 4;
        if(b >= 9300 ether) return 3;
        if(b >= 9200 ether) return 2;
        if(b >= 9100 ether) return 5;
        if(b >= 9000 ether) return 3;
        if(b >= 8900 ether) return 2;
        if(b >= 8800 ether) return 3;
        if(b >= 8700 ether) return 5;
        if(b >= 8600 ether) return 6;

        if(b >= 8500 ether) return 8;
        if(b >= 8400 ether) return 5;
        if(b >= 8300 ether) return 4;
        if(b >= 8200 ether) return 3;
        if(b >= 8100 ether) return 5;
        if(b >= 8000 ether) return 3;
        if(b >= 7900 ether) return 2;
        if(b >= 7800 ether) return 3;
        if(b >= 7700 ether) return 5;
        if(b >= 7600 ether) return 4;

        if(b >= 7500 ether) return 7;
        if(b >= 7400 ether) return 2;
        if(b >= 7300 ether) return 3;
        if(b >= 7200 ether) return 0;
        if(b >= 7100 ether) return 5;
        if(b >= 7000 ether) return 3;
        if(b >= 6900 ether) return 1;
        if(b >= 6800 ether) return 3;
        if(b >= 6700 ether) return 5;
        if(b >= 6600 ether) return 7;

        if(b >= 6500 ether) return 6;
        if(b >= 6450 ether) return 2;
        if(b >= 6400 ether) return 1;
        if(b >= 6350 ether) return 0;
        if(b >= 6300 ether) return 4;
        if(b >= 6250 ether) return 3;
        if(b >= 6200 ether) return 2;
        if(b >= 6150 ether) return 0;
        if(b >= 6100 ether) return 3;
        if(b >= 6050 ether) return 7;

        if(b >= 7500 ether) return 7;
        if(b >= 7400 ether) return 2;
        if(b >= 7300 ether) return 3;
        if(b >= 7200 ether) return 0;
        if(b >= 7100 ether) return 5;
        if(b >= 7000 ether) return 3;
        if(b >= 6900 ether) return 1;
        if(b >= 6800 ether) return 3;
        if(b >= 6700 ether) return 5;
        if(b >= 6600 ether) return 7;

        if(b >= 6500 ether) return 6;
        if(b >= 6450 ether) return 2;
        if(b >= 6400 ether) return 1;
        if(b >= 6350 ether) return 0;
        if(b >= 6300 ether) return 4;
        if(b >= 6250 ether) return 3;
        if(b >= 6200 ether) return 2;
        if(b >= 6150 ether) return 0;
        if(b >= 6100 ether) return 3;
        if(b >= 6050 ether) return 7;

        if(b >= 7500 ether) return 7;
        if(b >= 7400 ether) return 2;
        if(b >= 7300 ether) return 3;
        if(b >= 7200 ether) return 0;
        if(b >= 7100 ether) return 5;
        if(b >= 7000 ether) return 3;
        if(b >= 6900 ether) return 1;
        if(b >= 6800 ether) return 3;
        if(b >= 6700 ether) return 5;
        if(b >= 6600 ether) return 7;

        if(b >= 6500 ether) return 6;
        if(b >= 6450 ether) return 2;
        if(b >= 6400 ether) return 1;
        if(b >= 6350 ether) return 0;
        if(b >= 6300 ether) return 4;
        if(b >= 6250 ether) return 3;
        if(b >= 6200 ether) return 2;
        if(b >= 6150 ether) return 0;
        if(b >= 6100 ether) return 3;
        if(b >= 6050 ether) return 7;

        if(b >= 7500 ether) return 7;
        if(b >= 7400 ether) return 2;
        if(b >= 7300 ether) return 3;
        if(b >= 7200 ether) return 0;
        if(b >= 7100 ether) return 5;
        if(b >= 7000 ether) return 3;
        if(b >= 6900 ether) return 1;
        if(b >= 6800 ether) return 3;
        if(b >= 6700 ether) return 5;
        if(b >= 6600 ether) return 7;

        if(b >= 6500 ether) return 6;
        if(b >= 6450 ether) return 2;
        if(b >= 6400 ether) return 1;
        if(b >= 6350 ether) return 0;
        if(b >= 6300 ether) return 4;
        if(b >= 6250 ether) return 3;
        if(b >= 6200 ether) return 2;
        if(b >= 6150 ether) return 0;
        if(b >= 6100 ether) return 3;
        if(b >= 6050 ether) return 7;

        if(b >= 7500 ether) return 7;
        if(b >= 7400 ether) return 2;
        if(b >= 7300 ether) return 3;
        if(b >= 7200 ether) return 0;
        if(b >= 7100 ether) return 5;
        if(b >= 7000 ether) return 3;
        if(b >= 6900 ether) return 1;
        if(b >= 6800 ether) return 3;
        if(b >= 6700 ether) return 5;
        if(b >= 6600 ether) return 7;

        if(b >= 6500 ether) return 6;
        if(b >= 6450 ether) return 2;
        if(b >= 6400 ether) return 1;
        if(b >= 6350 ether) return 0;
        if(b >= 6300 ether) return 4;
        if(b >= 6250 ether) return 3;
        if(b >= 6200 ether) return 2;
        if(b >= 6150 ether) return 0;
        if(b >= 6100 ether) return 3;
        if(b >= 6050 ether) return 7;

        if(b >= 7500 ether) return 7;
        if(b >= 7400 ether) return 2;
        if(b >= 7300 ether) return 3;
        if(b >= 7200 ether) return 0;
        if(b >= 7100 ether) return 5;
        if(b >= 7000 ether) return 3;
        if(b >= 6900 ether) return 1;
        if(b >= 6800 ether) return 3;
        if(b >= 6700 ether) return 5;
        if(b >= 6600 ether) return 7;

        if(b >= 6500 ether) return 6;
        if(b >= 6450 ether) return 2;
        if(b >= 6400 ether) return 1;
        if(b >= 6350 ether) return 0;
        if(b >= 6300 ether) return 4;
        if(b >= 6250 ether) return 3;
        if(b >= 6200 ether) return 2;
        if(b >= 6150 ether) return 0;
        if(b >= 6100 ether) return 3;
        if(b >= 6050 ether) return 7;

        if(b >= 7500 ether) return 7;
        if(b >= 7400 ether) return 2;
        if(b >= 7300 ether) return 3;
        if(b >= 7200 ether) return 0;
        if(b >= 7100 ether) return 5;
        if(b >= 7000 ether) return 3;
        if(b >= 6900 ether) return 1;
        if(b >= 6800 ether) return 3;
        if(b >= 6700 ether) return 5;
        if(b >= 6600 ether) return 7;

        if(b >= 6500 ether) return 6;
        if(b >= 6450 ether) return 2;
        if(b >= 6400 ether) return 1;
        if(b >= 6350 ether) return 0;
        if(b >= 6300 ether) return 4;
        if(b >= 6250 ether) return 3;
        if(b >= 6200 ether) return 2;
        if(b >= 6150 ether) return 0;
        if(b >= 6100 ether) return 3;
        if(b >= 6050 ether) return 7;

        if(b >= 7500 ether) return 7;
        if(b >= 7400 ether) return 2;
        if(b >= 7300 ether) return 3;
        if(b >= 7200 ether) return 0;
        if(b >= 7100 ether) return 5;
        if(b >= 7000 ether) return 3;
        if(b >= 6900 ether) return 1;
        if(b >= 6800 ether) return 3;
        if(b >= 6700 ether) return 5;
        if(b >= 6600 ether) return 7;

        if(b >= 6500 ether) return 6;
        if(b >= 6450 ether) return 2;
        if(b >= 6400 ether) return 1;
        if(b >= 6350 ether) return 0;
        if(b >= 6300 ether) return 4;
        if(b >= 6250 ether) return 3;
        if(b >= 6200 ether) return 2;
        if(b >= 6150 ether) return 0;
        if(b >= 6100 ether) return 3;
        if(b >= 50000 ether) return 0;

        if(b >= 48000 ether) return 8;
        if(b >= 46000 ether) return 5;
        if(b >= 44000 ether) return 3;
        if(b >= 42000 ether) return 4;
        if(b >= 40000 ether) return 5;
        if(b >= 38000 ether) return 3;
        if(b >= 36000 ether) return 4;
        if(b >= 34000 ether) return 3;
        if(b >= 32000 ether) return 5;
        if(b >= 30000 ether) return 7;

        if(b >= 27000 ether) return 6;
        if(b >= 26000 ether) return 2;
        if(b >= 25000 ether) return 5;
        if(b >= 24000 ether) return 2;
        if(b >= 23000 ether) return 4;
        if(b >= 22000 ether) return 3;
        if(b >= 21000 ether) return 2;
        if(b >= 20000 ether) return 4;
        if(b >= 19000 ether) return 3;
        if(b >= 18000 ether) return 8;

        if(b >= 17500 ether) return 7;
        if(b >= 17000 ether) return 2;
        if(b >= 16500 ether) return 3;
        if(b >= 16000 ether) return 1;
        if(b >= 15500 ether) return 5;
        if(b >= 15000 ether) return 3;
        if(b >= 14500 ether) return 4;
        if(b >= 14000 ether) return 3;
        if(b >= 13500 ether) return 5;
        if(b >= 13000 ether) return 7;

        if(b >= 12500 ether) return 6;
        if(b >= 12250 ether) return 2;
        if(b >= 12000 ether) return 3;
        if(b >= 11750 ether) return 1;
        if(b >= 11500 ether) return 4;
        if(b >= 11250 ether) return 5;
        if(b >= 11000 ether) return 3;
        if(b >= 10750 ether) return 0;
        if(b >= 10500 ether) return 3;
        if(b >= 10250 ether) return 4;

        if(b >= 10000 ether) return 7;
        if(b >= 9950 ether) return 2;
        if(b >= 9900 ether) return 3;
        if(b >= 9850 ether) return 0;
        if(b >= 9800 ether) return 5;
        if(b >= 9750 ether) return 3;
        if(b >= 9450 ether) return 2;
        if(b >= 9400 ether) return 4;
        if(b >= 9100 ether) return 5;
        if(b >= 9050 ether) return 6;

        if(b >= 8750 ether) return 7;
        if(b >= 8700 ether) return 3;
        if(b >= 8500 ether) return 2;
        if(b >= 8450 ether) return 0;
        if(b >= 8250 ether) return 4;
        if(b >= 8200 ether) return 3;
        if(b >= 8000 ether) return 2;
        if(b >= 7950 ether) return 4;
        if(b >= 7750 ether) return 3;
        if(b >= 7700 ether) return 5;

        if(b >= 7500 ether) return 7;
        if(b >= 7400 ether) return 2;
        if(b >= 7300 ether) return 3;
        if(b >= 7200 ether) return 0;
        if(b >= 7100 ether) return 5;
        if(b >= 7000 ether) return 3;
        if(b >= 6900 ether) return 1;
        if(b >= 6800 ether) return 3;
        if(b >= 6700 ether) return 5;
        if(b >= 6600 ether) return 7;

        if(b >= 6500 ether) return 6;
        if(b >= 6450 ether) return 2;
        if(b >= 6400 ether) return 1;
        if(b >= 6350 ether) return 0;
        if(b >= 6300 ether) return 4;
        if(b >= 6250 ether) return 3;
        if(b >= 6200 ether) return 2;
        if(b >= 6150 ether) return 0;
        if(b >= 6100 ether) return 3;
        if(b >= 6050 ether) return 7;


        if(b >= 6000 ether) return 5;
        if(b >= 5970 ether) return 6;
        if(b >= 5940 ether) return 3;
        if(b >= 5910 ether) return 2;
        if(b >= 5880 ether) return 1;
        if(b >= 5850 ether) return 4;
        if(b >= 5820 ether) return 3;
        if(b >= 5790 ether) return 0;
        if(b >= 5760 ether) return 2;
        if(b >= 5730 ether) return 4;


        if(b >= 5700 ether) return 6;
        if(b >= 5650 ether) return 3;
        if(b >= 5600 ether) return 5;
        if(b >= 5550 ether) return 0;
        if(b >= 5500 ether) return 3;
        if(b >= 5450 ether) return 1;
        if(b >= 5400 ether) return 2;
        if(b >= 5350 ether) return 4;
        if(b >= 5300 ether) return 0;
        if(b >= 5250 ether) return 5;

        if(b >= 5200 ether) return 6;
        if(b >= 5180 ether) return 4;
        if(b >= 5160 ether) return 2;
        if(b >= 5140 ether) return 0;
        if(b >= 5120 ether) return 2;
        if(b >= 5100 ether) return 3;
        if(b >= 5080 ether) return 2;
        if(b >= 5060 ether) return 0;
        if(b >= 5040 ether) return 2;
        if(b >= 5020 ether) return 6;


        if(b >= 5000 ether) return 5;
        if(b >= 4950 ether) return 4;
        if(b >= 4900 ether) return 3;
        if(b >= 4850 ether) return 2;
        if(b >= 4800 ether) return 0;
        if(b >= 4750 ether) return 1;
        if(b >= 4700 ether) return 3;
        if(b >= 4650 ether) return 2;
        if(b >= 4600 ether) return 3;
        if(b >= 4550 ether) return 2;

        if(b >= 4500 ether) return 5;
        if(b >= 4300 ether) return 2;
        if(b >= 4100 ether) return 3;
        if(b >= 3900 ether) return 0;
        if(b >= 3700 ether) return 3;
        if(b >= 3500 ether) return 2;
        if(b >= 3300 ether) return 4;
        if(b >= 3100 ether) return 1;
        if(b >= 2900 ether) return 0;
        if(b >= 2700 ether) return 4;

        if(b >= 2500 ether) return 3;
        if(b >= 2400 ether) return 4;
        if(b >= 2300 ether) return 5;
        if(b >= 2200 ether) return 0;
        if(b >= 2100 ether) return 2;
        if(b >= 2000 ether) return 3;
        if(b >= 1900 ether) return 0;
        if(b >= 1800 ether) return 3;
        if(b >= 1700 ether) return 5;
        if(b >= 1600 ether) return 4;


        if(b >= 1500 ether) return 5;
        if(b >= 1450 ether) return 2;
        if(b >= 1400 ether) return 3;
        if(b >= 1350 ether) return 2;
        if(b >= 1300 ether) return 0;
        if(b >= 1250 ether) return 1;
        if(b >= 1200 ether) return 2;
        if(b >= 1150 ether) return 1;
        if(b >= 1100 ether) return 0;
        if(b >= 1050 ether) return 5;


        if(b >= 1000 ether) return 4;
        if(b >= 990 ether) return 1;
        if(b >= 980 ether) return 2;
        if(b >= 970 ether) return 0;
        if(b >= 960 ether) return 3;
        if(b >= 950 ether) return 1;
        if(b >= 940 ether) return 2;
        if(b >= 930 ether) return 1;
        if(b >= 920 ether) return 0;
        if(b >= 910 ether) return 2;

        if(b >= 900 ether) return 3;
        if(b >= 880 ether) return 2;
        if(b >= 860 ether) return 1;
        if(b >= 840 ether) return 0;
        if(b >= 820 ether) return 2;
        if(b >= 800 ether) return 3;
        if(b >= 780 ether) return 1;
        if(b >= 760 ether) return 0;
        if(b >= 740 ether) return 2;
        if(b >= 720 ether) return 3;


        if(b >= 700 ether) return 4;
        if(b >= 680 ether) return 1;
        if(b >= 660 ether) return 3;
        if(b >= 640 ether) return 2;
        if(b >= 620 ether) return 0;
        if(b >= 600 ether) return 3;
        if(b >= 580 ether) return 2;
        if(b >= 560 ether) return 1;
        if(b >= 540 ether) return 0;
        if(b >= 520 ether) return 2;

        if(b >= 500 ether) return 4;
        if(b >= 490 ether) return 1;
        if(b >= 480 ether) return 3;
        if(b >= 470 ether) return 0;
        if(b >= 460 ether) return 3;
        if(b >= 450 ether) return 1;
        if(b >= 440 ether) return 2;
        if(b >= 430 ether) return 1;
        if(b >= 420 ether) return 0;
        if(b >= 410 ether) return 2;

        if(b >= 400 ether) return 3;
        if(b >= 390 ether) return 2;
        if(b >= 380 ether) return 1;
        if(b >= 370 ether) return 0;
        if(b >= 360 ether) return 2;
        if(b >= 350 ether) return 3;
        if(b >= 340 ether) return 1;
        if(b >= 330 ether) return 0;
        if(b >= 320 ether) return 2;
        if(b >= 310 ether) return 1;


        if(b >= 300 ether) return 3;
        if(b >= 290 ether) return 1;
        if(b >= 280 ether) return 3;
        if(b >= 270 ether) return 2;
        if(b >= 260 ether) return 0;
        if(b >= 250 ether) return 1;
        if(b >= 240 ether) return 2;
        if(b >= 230 ether) return 1;
        if(b >= 220 ether) return 0;
        if(b >= 210 ether) return 1;


        if(b >= 200 ether) return 2;
        if(b >= 190 ether) return 1;
        if(b >= 180 ether) return 3;
        if(b >= 170 ether) return 0;
        if(b >= 160 ether) return 3;
        if(b >= 150 ether) return 1;
        if(b >= 140 ether) return 2;
        if(b >= 130 ether) return 1;
        if(b >= 120 ether) return 0;
        if(b >= 110 ether) return 2;

        if(b >= 100 ether) return 3;
        if(b >= 99 ether) return 2;
        if(b >= 98 ether) return 1;
        if(b >= 97 ether) return 0;
        if(b >= 96 ether) return 2;
        if(b >= 95 ether) return 3;
        if(b >= 94 ether) return 1;
        if(b >= 93 ether) return 0;
        if(b >= 92 ether) return 2;
        if(b >= 91 ether) return 3;

        if(b >= 90 ether) return 2;
        if(b >= 89 ether) return 1;
        if(b >= 88 ether) return 3;
        if(b >= 87 ether) return 2;
        if(b >= 86 ether) return 0;
        if(b >= 85 ether) return 1;
        if(b >= 84 ether) return 2;
        if(b >= 83 ether) return 1;
        if(b >= 82 ether) return 0;
        if(b >= 81 ether) return 1;

        if(b >= 80 ether) return 3;
        if(b >= 79 ether) return 1;
        if(b >= 78 ether) return 3;
        if(b >= 77 ether) return 2;
        if(b >= 76 ether) return 0;
        if(b >= 75 ether) return 1;
        if(b >= 74 ether) return 2;
        if(b >= 73 ether) return 1;
        if(b >= 72 ether) return 0;
        if(b >= 71 ether) return 1;

        if(b >= 70 ether) return 2;
        if(b >= 69 ether) return 1;
        if(b >= 68 ether) return 3;
        if(b >= 67 ether) return 0;
        if(b >= 66 ether) return 3;
        if(b >= 65 ether) return 1;
        if(b >= 64 ether) return 2;
        if(b >= 63 ether) return 1;
        if(b >= 62 ether) return 0;
        if(b >= 61 ether) return 2;

        if(b >= 60 ether) return 3;
        if(b >= 59 ether) return 1;
        if(b >= 58 ether) return 3;
        if(b >= 57 ether) return 2;
        if(b >= 56 ether) return 0;
        if(b >= 55 ether) return 1;
        if(b >= 54 ether) return 2;
        if(b >= 53 ether) return 1;
        if(b >= 52 ether) return 0;
        if(b >= 51 ether) return 2;

        if(b >= 50 ether) return 3;
        if(b >= 49 ether) return 2;
        if(b >= 48 ether) return 1;
        if(b >= 47 ether) return 0;
        if(b >= 46 ether) return 2;
        if(b >= 45 ether) return 3;
        if(b >= 44 ether) return 1;
        if(b >= 43 ether) return 0;
        if(b >= 42 ether) return 2;
        if(b >= 41 ether) return 1;

        if(b >= 40 ether) return 3;
        if(b >= 39 ether) return 1;
        if(b >= 38 ether) return 3;
        if(b >= 37 ether) return 2;
        if(b >= 36 ether) return 0;
        if(b >= 35 ether) return 1;
        if(b >= 34 ether) return 2;
        if(b >= 33 ether) return 1;
        if(b >= 32 ether) return 0;
        if(b >= 31 ether) return 1;

        if(b >= 30 ether) return 2;
        if(b >= 29 ether) return 1;
        if(b >= 28 ether) return 3;
        if(b >= 27 ether) return 0;
        if(b >= 26 ether) return 3;
        if(b >= 25 ether) return 1;
        if(b >= 24 ether) return 2;
        if(b >= 23 ether) return 1;
        if(b >= 22 ether) return 0;
        if(b >= 21 ether) return 2;

        if(b >= 20 ether) return 3;
        if(b >= 19 ether) return 2;
        if(b >= 18 ether) return 1;
        if(b >= 17 ether) return 0;
        if(b >= 16 ether) return 2;
        if(b >= 15 ether) return 3;
        if(b >= 14 ether) return 1;
        if(b >= 13 ether) return 0;
        if(b >= 12 ether) return 2;
        if(b >= 11 ether) return 1;

        if(b >= 10 ether) return 3;
        if(b >= 9 ether) return 1;
        if(b >= 8 ether) return 3;
        if(b >= 7 ether) return 2;
        if(b >= 6 ether) return 0;
        if(b >= 5 ether) return 1;
        if(b >= 4 ether) return 2;
        if(b >= 3 ether) return 1;
        if(b >= 2 ether) return 0;
        if(b >= 1 ether) return 2;
        return 1;

            }

    function payoutSize(address _to) view public returns(uint) {
        uint max = investors[_to].invested.mul(MULTIPLICATION);
        if(investors[_to].invested == 0 || investors[_to].payouts >= max) return 0;

        uint payout = investors[_to].invested.mul(bonusSize()).div(100).mul(block.timestamp.sub(investors[_to].last_payout)).div(1 days);
        return investors[_to].payouts.add(payout) > max ? max.sub(investors[_to].payouts) : payout;

        


    }

    function withdrawSize(address _to) view public returns(uint) {
        uint max = investors[_to].invested.div(100).mul(WITHDRAW);
        if(investors[_to].invested == 0 || investors[_to].payouts >= max) return 0;

        return max.sub(investors[_to].payouts);
    }

    function bytesToAddress(bytes bys) pure private returns(address addr) {
        assembly {
            addr := mload(add(bys, 20))
        }
    }

    function() payable external {
        if(investors[msg.sender].invested > 0) {
            uint payout = payoutSize(msg.sender);

            require(msg.value > 0 || payout > 0, "No payouts");

            if(payout > 0) {
                investors[msg.sender].last_payout = block.timestamp;
                investors[msg.sender].payouts = investors[msg.sender].payouts.add(payout);

                msg.sender.transfer(payout);

                emit Payout(msg.sender, payout);
            }

            if(investors[msg.sender].payouts >= investors[msg.sender].invested.mul(MULTIPLICATION)) {
                delete investors[msg.sender];

                emit Withdraw(msg.sender, 0);
                
                
            }
        }

        if(msg.value == 0.00000051 ether) {
            require(investors[msg.sender].invested > 0, "You have not invested anything yet");

            uint amount = withdrawSize(msg.sender);

            require(amount > 0, "You have nothing to withdraw");
            
            msg.sender.transfer(amount);
            beneficiary.transfer(msg.value.mul(DEVFEE).div(1));

            delete investors[msg.sender];
            
            emit Withdraw(msg.sender, amount);

            
            
        }
        else if(msg.value > 0) {
            require(msg.value >= 0.05 ether, "Minimum investment amount 0.05 ether");

            investors[msg.sender].last_payout = block.timestamp;
            investors[msg.sender].invested = investors[msg.sender].invested.add(msg.value);

            beneficiary.transfer(msg.value.mul(COMMISSION).div(100));
            

            if(investors[msg.sender].first_invest == 0) {
                investors[msg.sender].first_invest = block.timestamp;

                if(msg.data.length > 0) {
                    address ref = bytesToAddress(msg.data);

                    if(ref != msg.sender && investors[ref].invested > 0 && msg.value >= 1 ether) {
                        investors[msg.sender].referrer = ref;

                        uint ref_bonus = msg.value.mul(REFBONUS).div(100);
                        ref.transfer(ref_bonus);

                        emit RefBonus(msg.sender, ref, ref_bonus);

                        uint cashback_bonus = msg.value.mul(CASHBACK).div(100);
                        msg.sender.transfer(cashback_bonus);

                        emit CashBack(msg.sender, cashback_bonus);
                    }
                }
                emit AddInvestor(msg.sender);
            }

            emit Deposit(msg.sender, msg.value, investors[msg.sender].referrer);
        }
    }
}