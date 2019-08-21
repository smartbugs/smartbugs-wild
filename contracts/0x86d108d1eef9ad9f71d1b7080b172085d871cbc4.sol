pragma solidity ^0.4.18;

contract Token {
    function transfer(address _to, uint _value) public returns(bool);
    function burn(uint _value) public;
    function balanceOf(address _owner) view public returns(uint);
    function decimals() view public returns(uint8);
    function transferOwnership(address _newOwner) public;
}

library SafeMath {
    function add(uint _a, uint _b) internal pure returns(uint) {
        uint c = _a + _b;
        assert(c >= _a);
        return c;
    }

    function mul(uint _a, uint _b) internal pure returns(uint) {
        if (_a == 0) {
          return 0;
        }
        uint c = _a * _b;
        assert(c / _a == _b);
        return c;
    }

    function div(uint _a, uint _b) internal pure returns(uint) {
        return _a / _b;
    }

    function sub(uint _a, uint _b) internal pure returns (uint) {
        assert(_b <= _a);
        return _a - _b;
    }
}

contract Owned {
    address public contractOwner;
    address public pendingContractOwner;

    event LogContractOwnershipChangeInitiated(address to);
    event LogContractOwnershipChangeCompleted(address to);

    function Owned() public {
        contractOwner = msg.sender;
    }

    modifier onlyContractOwner() {
        require(contractOwner == msg.sender);
        _;
    }

    function changeContractOwnership(address _to) onlyContractOwner() public returns(bool) {
        pendingContractOwner = _to;
        LogContractOwnershipChangeInitiated(_to);
        return true;
    }

    function claimContractOwnership() public returns(bool) {
        if (pendingContractOwner != msg.sender) {
            return false;
        }
        contractOwner = pendingContractOwner;
        delete pendingContractOwner;
        LogContractOwnershipChangeCompleted(contractOwner);
        return true;
    }

    function forceChangeContractOwnership(address _to) onlyContractOwner() public returns(bool) {
        contractOwner = _to;
        LogContractOwnershipChangeCompleted(contractOwner);
        return true;
    }
}

contract NeuroSale is Owned {
    using SafeMath for uint;

    mapping(address => uint) public totalSpentEth;
    mapping(address => uint) public totalTokensWithoutBonuses;
    mapping(address => uint) public volumeBonusesTokens;

    uint public constant TOKEN_PRICE = 0.001 ether;
    uint public constant MULTIPLIER = uint(10) ** uint(18);
    uint public salesStart;
    uint public salesDeadline;
    Token public token;
    address public wallet;
    bool public salePaused;

    event LogBought(address indexed receiver, uint contribution, uint reward, uint128 customerId);
    event LogPaused(bool isPaused);
    event LogWalletUpdated(address to);

    modifier notPaused() {
        require(!salePaused);
        _;
    }

    // Can be iniitialized only once.
    function init(Token _token, address _wallet, uint _start, uint _deadline) onlyContractOwner() public returns(bool) {
        require(address(token) == 0);
        require(_wallet != 0);
        token = _token;
        wallet = _wallet;
        salesStart = _start;
        salesDeadline = _deadline;
        return true;
    }

    function setSalePause(bool _value) onlyContractOwner() public returns(bool) {
        salePaused = _value;
        LogPaused(_value);
        return true;
    }

    function setWallet(address _wallet) onlyContractOwner() public returns(bool) {
        require(_wallet != 0);
        wallet = _wallet;
        LogWalletUpdated(_wallet);
        return true;
    }

    function transferOwnership() onlyContractOwner() public returns(bool) {
        token.transferOwnership(contractOwner);
        return true;
    }

    function burnUnsold() onlyContractOwner() public returns(bool) {
        uint tokensToBurn = token.balanceOf(address(this));
        token.burn(tokensToBurn);
        return true;
    }

    function buy() payable notPaused() public returns(bool) {
        require(now >= salesStart);
        require(now < salesDeadline);

        // Overflow is impossible because amounts are calculated based on actual ETH being sent.
        // There is no division remainder.
        uint tokensToBuy = msg.value * MULTIPLIER / TOKEN_PRICE;
        require(tokensToBuy > 0);
        uint timeBonus = _calculateTimeBonus(tokensToBuy, now);
        uint volumeBonus = _calculateVolumeBonus(tokensToBuy, msg.sender, msg.value);
        // Overflow is impossible because amounts are calculated based on actual ETH being sent.
        uint totalTokensToTransfer = tokensToBuy + timeBonus + volumeBonus;
        require(token.transfer(msg.sender, totalTokensToTransfer));
        LogBought(msg.sender, msg.value, totalTokensToTransfer, 0);
        // Call is performed as the last action, no threats.
        require(wallet.call.value(msg.value)());
        return true;
    }

    function buyWithCustomerId(address _beneficiary, uint _value, uint _amount, uint128 _customerId, uint _date, bool _autobonus) onlyContractOwner() public returns(bool) {
        uint totalTokensToTransfer;
        uint volumeBonus;

        if (_autobonus) {
            uint tokensToBuy = _value.mul(MULTIPLIER).div(TOKEN_PRICE);
            require(tokensToBuy > 0);
            uint timeBonus = _calculateTimeBonus(tokensToBuy, _date);
            volumeBonus = _calculateVolumeBonus(tokensToBuy, _beneficiary, _value);
            // Overflow is possible because value is specified in the input.
            totalTokensToTransfer = tokensToBuy.add(timeBonus).add(volumeBonus);
        } else {
            totalTokensToTransfer = _amount;
        }

        require(token.transfer(_beneficiary, totalTokensToTransfer));
        LogBought(_beneficiary, _value, totalTokensToTransfer, _customerId);
        return true;
    }

    function _calculateTimeBonus(uint _value, uint _date) view internal returns(uint) {
        // Overflows are possible because value is specified in the input.
        if (_date < salesStart) {
            return 0;
        }
        // between 07.01.2018 00:00:00 UTC and 14.01.2018 00:00:00 UTC +15%
        if (_date < salesStart + 1 weeks) {
            return _value.mul(150).div(1000);
        }
        // between 14.01.2018 00:00:00 UTC and 21.01.2018 00:00:00 UTC +10%
        if (_date < salesStart + 2 weeks) {
            return _value.mul(100).div(1000);
        }
        // between 21.01.2018 00:00:00 UTC and 28.01.2018 00:00:00 UTC +7%
        if (_date < salesStart + 3 weeks) {
            return _value.mul(70).div(1000);
        }
        // between 28.01.2018 00:00:00 UTC and 04.02.2018 00:00:00 UTC +4%
        if (_date < salesStart + 4 weeks) {
            return _value.mul(40).div(1000);
        }
        // between 04.02.2018 00:00:00 UTC and 11.02.2018 00:00:00 UTC +2%
        if (_date < salesStart + 5 weeks) {
            return _value.mul(20).div(1000);
        }
        // between 11.02.2018 00:00:00 UTC and 15.02.2018 23:59:59 UTC +1%
        if (_date < salesDeadline) {
            return _value.mul(10).div(1000);
        }

        return 0;
    }

    function _calculateVolumeBonus(uint _amount, address _receiver, uint _value) internal returns(uint) {
        // Overflows are possible because amount and value are specified in the input.
        uint totalCollected = totalTokensWithoutBonuses[_receiver].add(_amount);
        uint totalEth = totalSpentEth[_receiver].add(_value);
        uint totalBonus;

        if (totalEth < 30 ether) {
            totalBonus = 0;
        } else if (totalEth < 50 ether) {
            totalBonus = totalCollected.mul(10).div(1000);
        } else if (totalEth < 100 ether) {
            totalBonus = totalCollected.mul(25).div(1000);
        } else if (totalEth < 300 ether) {
            totalBonus = totalCollected.mul(50).div(1000);
        } else if (totalEth < 500 ether) {
            totalBonus = totalCollected.mul(80).div(1000);
        } else if (totalEth < 1000 ether) {
            totalBonus = totalCollected.mul(150).div(1000);
        } else if (totalEth < 2000 ether) {
            totalBonus = totalCollected.mul(200).div(1000);
        } else if (totalEth < 3000 ether) {
            totalBonus = totalCollected.mul(300).div(1000);
        } else if (totalEth >= 3000 ether) {
            totalBonus = totalCollected.mul(400).div(1000);
        }

        // Overflow is impossible because totalBonus is always >= volumeBonusesTokens[_receiver];
        uint bonusToPay = totalBonus - volumeBonusesTokens[_receiver];
        volumeBonusesTokens[_receiver] = totalBonus;

        totalSpentEth[_receiver] = totalEth;
        totalTokensWithoutBonuses[_receiver] = totalCollected;
        return bonusToPay;
    }

    function () payable public {
        buy();
    }

    // In case somebody sends tokens here.
    function recoverTokens(Token _token, uint _amount) onlyContractOwner() public returns(bool) {
        return _token.transfer(contractOwner, _amount);
    }
}