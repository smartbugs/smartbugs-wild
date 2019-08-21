pragma solidity 0.4.15;

contract ERC20 {
    function transferFrom(address _from, address _to, uint256 _value) returns (bool success);
}

contract TokensaleBlacklist {
    function isRestricted(address _addr) constant returns(bool);
}

contract TraderStarsSale {
    uint public constant SALES_START = 1510754400; // 15.11.2017 14:00:00 UTC
    uint public constant SALES_DEADLINE = 1513864800; // 21.12.2017 14:00:00 UTC
    address public constant MASTER_WALLET = 0x909B194c56eB3ecf10F1f9FaF5fc8E35B2de1F2d;
    address public constant TOKEN = 0xfCA1a79D59Bcf870fAA685BE0d0cdA394F52Ceb5;
    address public constant TOKENSALE_BLACKLIST = 0x945B2c9569A8ebd883d05Ab20f09AD6c241cB156;
    uint public constant TOKEN_PRICE = 0.00000003 ether;
    uint public constant PRE_ICO_MAX_CAP = 100000000000;
    uint public constant ICO_MAX_CAP = 2100000000000;
    uint public preIcoTotalSupply;
    uint public icoTotalSupply;

    event Contributed(address receiver, uint contribution, uint reward);

    function contribute() payable returns(bool) {
        require(msg.value >= TOKEN_PRICE);
        require(now < SALES_DEADLINE);
        require(now >= SALES_START);
        // Blacklist of exchange pools, and other not private wallets.
        require(!TokensaleBlacklist(TOKENSALE_BLACKLIST).isRestricted(msg.sender));

        uint tokensAmount = _calculateBonusAndUpdateTotal(msg.value / TOKEN_PRICE);
        require(tokensAmount > 0);
        require(preIcoTotalSupply < PRE_ICO_MAX_CAP);
        require(preIcoTotalSupply + icoTotalSupply < ICO_MAX_CAP);

        require(ERC20(TOKEN).transferFrom(MASTER_WALLET, msg.sender, tokensAmount));
        // If there is some division reminder from msg.value % TOKEN_PRICE, we just
        // collect it too.
        MASTER_WALLET.transfer(msg.value);

        Contributed(msg.sender, msg.value, tokensAmount);
        return true;
    }

    function _calculateBonusAndUpdateTotal(uint _value) internal returns(uint) {
        uint currentTime = now;
        uint amountWithBonus;

        // between 5.12.2017 14:00:00 UTC and 21.12.2017 14:00:00 UTC no bonus
        if (currentTime > 1512482400 && currentTime <= SALES_DEADLINE) {
            icoTotalSupply += _value;
            return _value;
        // between 28.11.2017 14:00:00 UTC and 5.12.2017 14:00:00 UTC +2.5%
        } else if (currentTime > 1511877600 && currentTime <= 1512482400) {
            amountWithBonus = _value + _value * 25 / 1000;
            icoTotalSupply += amountWithBonus;
            return amountWithBonus;
        // between 24.11.2017 14:00:00 UTC and 28.11.2017 14:00:00 UTC +5%
        } else if (currentTime > 1511532000 && currentTime <= 1511877600) {
            amountWithBonus = _value + _value * 50 / 1000;
            icoTotalSupply += amountWithBonus;
            return amountWithBonus;
        // between 22.11.2017 14:00:00 UTC and 24.11.2017 14:00:00 UTC +10%
        } else if (currentTime > 1511359200 && currentTime <= 1511532000) {
            amountWithBonus = _value + _value * 100 / 1000;
            icoTotalSupply += amountWithBonus;
            return amountWithBonus;
        // between 21.11.2017 14:00:00 UTC and 22.11.2017 14:00:00 UTC +25%
        } else if (currentTime > 1511272800 && currentTime <= 1511359200) {
            amountWithBonus = _value + _value * 250 / 1000;
            icoTotalSupply += amountWithBonus;
            return amountWithBonus;
        // between 15.11.2017 14:00:00 UTC and 17.11.2017 14:00:00 UTC +30%
        } else if (currentTime >= SALES_START && currentTime <= 1510927200) {
            amountWithBonus = _value + _value * 300 / 1000;
            preIcoTotalSupply += amountWithBonus;
            return amountWithBonus;
        }
        
        return 0;
    }

    function () payable {
        contribute();
    }
}