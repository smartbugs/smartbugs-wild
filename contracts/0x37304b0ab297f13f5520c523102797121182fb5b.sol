pragma solidity ^0.4.18;

contract SportCrypt {
    address private owner;
    mapping(address => bool) private admins;

    function SportCrypt() public {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    function changeOwner(address newOwner) external onlyOwner {
        owner = newOwner;
    }

    function addAdmin(address addr) external onlyOwner {
        admins[addr] = true;
    }

    function removeAdmin(address addr) external onlyOwner {
        admins[addr] = false;
    }


    // Events

    event LogBalanceChange(address indexed account, uint oldAmount, uint newAmount);
    event LogDeposit(address indexed account);
    event LogWithdraw(address indexed account);
    event LogTrade(address indexed takerAccount, address indexed makerAccount, uint indexed matchId, uint orderHash, uint8 orderDirection, uint8 price, uint longAmount, int newLongPosition, uint shortAmount, int newShortPosition);
    event LogTradeError(address indexed takerAccount, address indexed makerAccount, uint indexed matchId, uint orderHash, uint16 status);
    event LogOrderCancel(address indexed account, uint indexed matchId, uint orderHash);
    event LogFinalizeMatch(uint indexed matchId, uint8 finalPrice);
    event LogClaim(address indexed account, uint indexed matchId, uint amount);


    // Storage

    struct Match {
        mapping(address => int) positions;
        uint64 firstTradeTimestamp;
        bool finalized;
        uint8 finalPrice;
    }

    mapping(address => uint) private balances;
    mapping(uint => Match) private matches;
    mapping(uint => uint) private filledAmounts;


    // Memory

    uint constant MAX_SANE_AMOUNT = 2**128;

    enum Status {
        OK,
        MATCH_FINALIZED,
        ORDER_EXPIRED,
        ORDER_MALFORMED,
        ORDER_BAD_SIG,
        AMOUNT_MALFORMED,
        SELF_TRADE,
        ZERO_VALUE_TRADE
    }

    struct Order {
        uint orderHash;
        uint matchId;
        uint amount;
        uint expiry;
        address addr;
        uint8 price;
        uint8 direction;
    }

    // [0]: match hash
    // [1]: amount
    // [2]: 5-byte expiry, 5-byte nonce, 1-byte price, 1-byte direction, 20-byte address

    function parseOrder(uint[3] memory rawOrder) private constant returns(Order memory o) {
        o.orderHash = uint(keccak256(this, rawOrder));

        o.matchId = rawOrder[0];
        o.amount = rawOrder[1];

        uint packed = rawOrder[2];
        o.expiry = packed >> (8*27);
        o.addr = address(packed & 0x00ffffffffffffffffffffffffffffffffffffffff);
        o.price = uint8((packed >> (8*21)) & 0xff);
        o.direction = uint8((packed >> (8*20)) & 0xff);
    }

    function validateOrderParams(Order memory o) private pure returns(bool) {
        if (o.amount > MAX_SANE_AMOUNT) return false;
        if (o.price == 0 || o.price > 99) return false;
        if (o.direction > 1) return false;
        return true;
    }

    function validateOrderSig(Order memory o, bytes32 r, bytes32 s, uint8 v) private pure returns(bool) {
        if (ecrecover(keccak256("\x19Ethereum Signed Message:\n32", o.orderHash), v, r, s) != o.addr) return false;
        return true;
    }

    struct Trade {
        Status status;
        address longAddr;
        address shortAddr;
        int newLongPosition;
        int newShortPosition;
        int longBalanceDelta;
        int shortBalanceDelta;
        uint shortAmount;
        uint longAmount;
    }


    // User methods

    function() external payable {
        revert();
    }

    function deposit() external payable {
        if (msg.value > 0) {
            uint origAmount = balances[msg.sender];
            uint newAmount = safeAdd(origAmount, msg.value);
            balances[msg.sender] = newAmount;

            LogDeposit(msg.sender);
            LogBalanceChange(msg.sender, origAmount, newAmount);
        }
    }

    function withdraw(uint amount) external {
        uint origAmount = balances[msg.sender];
        uint amountToWithdraw = minu256(origAmount, amount);

        if (amountToWithdraw > 0) {
            uint newAmount = origAmount - amountToWithdraw;
            balances[msg.sender] = newAmount;

            LogWithdraw(msg.sender);
            LogBalanceChange(msg.sender, origAmount, newAmount);

            msg.sender.transfer(amountToWithdraw);
        }
    }

    function cancelOrder(uint[3] order, bytes32 r, bytes32 s, uint8 v) external {
        Order memory o = parseOrder(order);

        // Don't bother validating order params.
        require(validateOrderSig(o, r, s, v));
        require(o.addr == msg.sender);

        if (block.timestamp < o.expiry) {
            filledAmounts[o.orderHash] = o.amount;
            LogOrderCancel(msg.sender, o.matchId, o.orderHash);
        }
    }

    function trade(uint amount, uint[3] order, bytes32 r, bytes32 s, uint8 v) external {
        Order memory o = parseOrder(order);

        if (!validateOrderParams(o)) {
            LogTradeError(msg.sender, o.addr, o.matchId, o.orderHash, uint16(Status.ORDER_MALFORMED));
            return;
        }

        if (!validateOrderSig(o, r, s, v)) {
            LogTradeError(msg.sender, o.addr, o.matchId, o.orderHash, uint16(Status.ORDER_BAD_SIG));
            return;
        }

        Trade memory t = tradeCore(amount, o);

        if (t.status != Status.OK) {
            LogTradeError(msg.sender, o.addr, o.matchId, o.orderHash, uint16(t.status));
            return;
        }

        // Modify storage to reflect trade:

        var m = matches[o.matchId];

        if (m.firstTradeTimestamp == 0) {
            assert(block.timestamp > 0);
            m.firstTradeTimestamp = uint64(block.timestamp);
        }

        m.positions[t.longAddr] = t.newLongPosition;
        m.positions[t.shortAddr] = t.newShortPosition;

        adjustBalance(t.longAddr, t.longBalanceDelta);
        adjustBalance(t.shortAddr, t.shortBalanceDelta);

        filledAmounts[o.orderHash] += (o.direction == 0 ? t.shortAmount : t.longAmount);

        LogTrade(msg.sender, o.addr, o.matchId, o.orderHash, o.direction, o.price, t.longAmount, t.newLongPosition, t.shortAmount, t.newShortPosition);
    }

    function claim(uint matchId, uint8 finalPrice, bytes32 r, bytes32 s, uint8 v) external {
        var m = matches[matchId];

        if (m.finalized) {
            require(m.finalPrice == finalPrice);
        } else {
            uint messageHash = uint(keccak256(this, matchId, finalPrice));
            address signer = ecrecover(keccak256("\x19Ethereum Signed Message:\n32", messageHash), v, r, s);
            require(admins[signer]);
            require(finalPrice <= 100);

            m.finalized = true;
            m.finalPrice = finalPrice;
            LogFinalizeMatch(matchId, finalPrice);
        }

        // NOTE: final prices other than 0 and 100 may leave very small amounts of unrecoverable dust in the contract due to rounding.

        int delta = 0;
        int senderPosition = m.positions[msg.sender];

        if (senderPosition > 0) {
            delta = priceDivide(senderPosition, finalPrice);
        } else if (senderPosition < 0) {
            delta = priceDivide(-senderPosition, 100 - finalPrice);
        } else {
            return;
        }

        assert(delta >= 0);

        m.positions[msg.sender] = 0;
        adjustBalance(msg.sender, delta);

        LogClaim(msg.sender, matchId, uint(delta));
    }

    function recoverFunds(uint matchId) external {
        var m = matches[matchId];

        if (m.finalized || m.firstTradeTimestamp == 0) {
            return;
        }

        uint recoveryTimestamp = uint(m.firstTradeTimestamp) + ((matchId & 0xFF) * 7 * 86400);

        if (uint(block.timestamp) > recoveryTimestamp) {
            uint8 finalPrice = uint8((matchId & 0xFF00) >> 8);
            require(finalPrice <= 100);

            m.finalized = true;
            m.finalPrice = finalPrice;
            LogFinalizeMatch(matchId, finalPrice);
        }
    }


    // Private utilities

    function adjustBalance(address addr, int delta) private {
        uint origAmount = balances[addr];
        uint newAmount = delta >= 0 ? safeAdd(origAmount, uint(delta)) : safeSub(origAmount, uint(-delta));
        balances[addr] = newAmount;

        LogBalanceChange(addr, origAmount, newAmount);
    }

    function priceDivide(int amount, uint8 price) private pure returns(int) {
        assert(amount >= 0);
        return int(safeMul(uint(amount), price) / 100);
    }

    function computeEffectiveBalance(uint balance, int position, uint8 price, bool isLong) private pure returns(uint) {
        uint effectiveBalance = balance;

        if (isLong) {
            if (position < 0) effectiveBalance += uint(priceDivide(-position, price));
        } else {
            if (position > 0) effectiveBalance += uint(priceDivide(position, 100 - price));
        }

        return effectiveBalance;
    }

    function computePriceWeightedAmounts(uint longAmount, uint shortAmount, uint price) private pure returns(uint, uint) {
        uint totalLongAmount;
        uint totalShortAmount;

        totalLongAmount = longAmount + (safeMul(longAmount, 100 - price) / price);
        totalShortAmount = shortAmount + (safeMul(shortAmount, price) / (100 - price));

        if (totalLongAmount > totalShortAmount) {
            return (totalShortAmount - shortAmount, shortAmount);
        } else {
            return (longAmount, totalLongAmount - longAmount);
        }
    }

    function computeExposureDelta(int longBalanceDelta, int shortBalanceDelta, int oldLongPosition, int newLongPosition, int oldShortPosition, int newShortPosition) private pure returns(int) {
        int positionDelta = 0;
        if (newLongPosition > 0) positionDelta += newLongPosition - max256(0, oldLongPosition);
        if (oldShortPosition > 0) positionDelta -= oldShortPosition - max256(0, newShortPosition);

        return positionDelta + longBalanceDelta + shortBalanceDelta;
    }

    function tradeCore(uint amount, Order memory o) private constant returns(Trade t) {
        var m = matches[o.matchId];

        if (block.timestamp >= o.expiry) {
            t.status = Status.ORDER_EXPIRED;
            return;
        }

        if (m.finalized) {
            t.status = Status.MATCH_FINALIZED;
            return;
        }

        if (msg.sender == o.addr) {
            t.status = Status.SELF_TRADE;
            return;
        }

        if (amount > MAX_SANE_AMOUNT) {
            t.status = Status.AMOUNT_MALFORMED;
            return;
        }

        t.status = Status.OK;


        uint longAmount;
        uint shortAmount;

        if (o.direction == 0) {
            // maker short, taker long
            t.longAddr = msg.sender;
            longAmount = amount;

            t.shortAddr = o.addr;
            shortAmount = safeSub(o.amount, filledAmounts[o.orderHash]);
        } else {
            // maker long, taker short 
            t.longAddr = o.addr;
            longAmount = safeSub(o.amount, filledAmounts[o.orderHash]);

            t.shortAddr = msg.sender;
            shortAmount = amount;
        }

        int oldLongPosition = m.positions[t.longAddr];
        int oldShortPosition = m.positions[t.shortAddr];

        longAmount = minu256(longAmount, computeEffectiveBalance(balances[t.longAddr], oldLongPosition, o.price, true));
        shortAmount = minu256(shortAmount, computeEffectiveBalance(balances[t.shortAddr], oldShortPosition, o.price, false));

        (longAmount, shortAmount) = computePriceWeightedAmounts(longAmount, shortAmount, o.price);

        if (longAmount == 0 || shortAmount == 0) {
            t.status = Status.ZERO_VALUE_TRADE;
            return;
        }


        int newLongPosition = oldLongPosition + (int(longAmount) + int(shortAmount));
        int newShortPosition = oldShortPosition - (int(longAmount) + int(shortAmount));


        t.longBalanceDelta = 0;
        t.shortBalanceDelta = 0;

        if (oldLongPosition < 0) t.longBalanceDelta += priceDivide(-oldLongPosition + min256(0, newLongPosition), 100 - o.price);
        if (newLongPosition > 0) t.longBalanceDelta -= priceDivide(newLongPosition - max256(0, oldLongPosition), o.price);

        if (oldShortPosition > 0) t.shortBalanceDelta += priceDivide(oldShortPosition - max256(0, newShortPosition), o.price);
        if (newShortPosition < 0) t.shortBalanceDelta -= priceDivide(-newShortPosition + min256(0, oldShortPosition), 100 - o.price);

        int exposureDelta = computeExposureDelta(t.longBalanceDelta, t.shortBalanceDelta, oldLongPosition, newLongPosition, oldShortPosition, newShortPosition);

        if (exposureDelta != 0) {
            if (exposureDelta == 1) {
                newLongPosition--;
                newShortPosition++;
            } else if (exposureDelta == -1) {
                t.longBalanceDelta++; // one left-over wei: arbitrarily give it to long
            } else {
                assert(false);
            }

            exposureDelta = computeExposureDelta(t.longBalanceDelta, t.shortBalanceDelta, oldLongPosition, newLongPosition, oldShortPosition, newShortPosition);
            assert(exposureDelta == 0);
        }


        t.newLongPosition = newLongPosition;
        t.newShortPosition = newShortPosition;
        t.shortAmount = shortAmount;
        t.longAmount = longAmount;
    }


    // External views

    function getOwner() external view returns(address) {
        return owner;
    }

    function isAdmin(address addr) external view returns(bool) {
        return admins[addr];
    }

    function getBalance(address addr) external view returns(uint) {
        return balances[addr];
    }

    function getMatchInfo(uint matchId) external view returns(uint64, bool, uint8) {
        var m = matches[matchId];
        return (m.firstTradeTimestamp, m.finalized, m.finalPrice);
    }

    function getPosition(uint matchId, address addr) external view returns(int) {
        return matches[matchId].positions[addr];
    }

    function getFilledAmount(uint orderHash) external view returns(uint) {
        return filledAmounts[orderHash];
    }

    function checkMatchBatch(address myAddr, uint[16] matchIds) external view returns(int[16] myPosition, bool[16] finalized, uint8[16] finalPrice) {
        for (uint i = 0; i < 16; i++) {
            if (matchIds[i] == 0) break;

            var m = matches[matchIds[i]];

            myPosition[i] = m.positions[myAddr];
            finalized[i] = m.finalized;
            finalPrice[i] = m.finalPrice;
        }
    }

    function checkOrderBatch(uint[48] input) external view returns(uint16[16] status, uint[16] amount) {
        for (uint i = 0; i < 16; i++) {
            uint[3] memory rawOrder;
            rawOrder[0] = input[(i*3)];
            rawOrder[1] = input[(i*3) + 1];
            rawOrder[2] = input[(i*3) + 2];

            if (rawOrder[0] == 0) break;

            Order memory o = parseOrder(rawOrder);

            if (!validateOrderParams(o)) {
                status[i] = uint16(Status.ORDER_MALFORMED);
                amount[i] = 0;
                continue;
            }

            // Not validating order signatures or timestamps: should be done by clients

            var m = matches[o.matchId];

            if (m.finalized) {
                status[i] = uint16(Status.MATCH_FINALIZED);
                amount[i] = 0;
                continue;
            }

            uint longAmount;
            uint shortAmount;

            if (o.direction == 0) {
                shortAmount = safeSub(o.amount, filledAmounts[o.orderHash]);
                longAmount = safeMul(shortAmount, 100);
                shortAmount = minu256(shortAmount, computeEffectiveBalance(balances[o.addr], m.positions[o.addr], o.price, false));
                (longAmount, shortAmount) = computePriceWeightedAmounts(longAmount, shortAmount, o.price);
                status[i] = uint16(Status.OK);
                amount[i] = shortAmount;
            } else {
                longAmount = safeSub(o.amount, filledAmounts[o.orderHash]);
                shortAmount = safeMul(longAmount, 100);
                longAmount = minu256(longAmount, computeEffectiveBalance(balances[o.addr], m.positions[o.addr], o.price, true));
                (longAmount, shortAmount) = computePriceWeightedAmounts(longAmount, shortAmount, o.price);
                status[i] = uint16(Status.OK);
                amount[i] = longAmount;
            }
        }
    }


    // Math utilities

    function safeMul(uint a, uint b) private pure returns(uint) {
        uint c = a * b;
        assert(a == 0 || c / a == b);
        return c;
    }

    function safeSub(uint a, uint b) private pure returns(uint) {
        assert(b <= a);
        return a - b;
    }

    function safeAdd(uint a, uint b) private pure returns(uint) {
        uint c = a + b;
        assert(c >= a && c >= b);
        return c;
    }

    function minu256(uint a, uint b) private pure returns(uint) {
        return a < b ? a : b;
    }

    function max256(int a, int b) private pure returns(int) {
        return a >= b ? a : b;
    }

    function min256(int a, int b) private pure returns(int) {
        return a < b ? a : b;
    }
}