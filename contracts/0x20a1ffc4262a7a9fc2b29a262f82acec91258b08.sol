pragma solidity ^0.4.24;

contract SafeMath {
    function safeMul(uint a, uint b) internal pure returns (uint) {
        uint c = a * b;
        assert(a == 0 || c / a == b);
        return c;
    }

    function safeSub(uint a, uint b) internal pure returns (uint) {
        assert(b <= a);
        return a - b;
    }

    function safeAdd(uint a, uint b) internal pure returns (uint) {
        uint c = a + b;
        assert(c>=a && c>=b);
        return c;
    }

    function is112bit(uint x) internal pure returns (bool) {
        if (x < 1 << 112) {
            return true;
        } else {
            return false;
        }
    }

    function is32bit(uint x) internal pure returns (bool) {
        if (x < 1 << 32) {
            return true;
        } else {
            return false;
        }
    }
}

contract Token {
    function totalSupply() constant returns (uint256 supply) {}
    function balanceOf(address _owner) constant returns (uint256 balance) {}
    function transfer(address _to, uint256 _value) returns (bool success) {}
    function transferFrom(address _from, address _to, uint256 _value) returns (bool success) {}
    function approve(address _spender, uint256 _value) returns (bool success) {}
    function allowance(address _owner, address _spender) constant returns (uint256 remaining) {}

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);

    uint public decimals;
    string public name;
}

// ERC-20 token contract with no return value for transfer(), approve() and transferFrom()
contract NoReturnToken {
    function totalSupply() constant returns (uint256 supply) {}
    function balanceOf(address _owner) constant returns (uint256 balance) {}
    function transfer(address _to, uint256 _value) {}
    function transferFrom(address _from, address _to, uint256 _value) {}
    function approve(address _spender, uint256 _value) {}
    function allowance(address _owner, address _spender) constant returns (uint256 remaining) {}

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);

    uint public decimals;
    string public name;
}

// Allows smoother migration to a new version of the auction smart contract via migrate()
contract NewAuction {
    function depositForUser(address _user) payable {}
    function depositTokenForUser(address _user, address _token, uint _amount) {}
}



contract Auction is SafeMath {
    // ALl the data relevant to the auctions for one specific token
    struct TokenAuction {
        mapping (uint => uint) buyOrders;
        uint buyCount;
        mapping (uint => uint) sellOrders;
        uint sellCount;

        uint maxVolume; // The maximum volume of orders that can be filled in the current auction
        uint maxVolumePrice; // The price at which orders will be filled in the current auction
        uint maxVolumePriceB; // Buy orders below this price cannot be filled as orders are first prioritised by price
        uint maxVolumePriceS; // Sell orders above this price cannot be filled as orders are first prioritised by price
        bool toBeExecuted; // The auction is ready for execution
        bool activeAuction; // There is an ongoing auction for the token
        uint executionIndex; // The index for the next order that needs to be executed in the auction, using storage is necessary to allow batches in separate transactions
        uint executionBuyVolume; // The volume filled so far on the buy side in the current auction
        uint executionSellVolume; // The volume filled so far on the sell side in the current auction
        uint auctionIndex; // The index for the current auction

        mapping (uint => mapping (uint => uint)) checkAuctionIndex; // The auction index when checkVolume() was last called with the given price limits
        mapping (uint => mapping (uint => uint)) checkIndex; // The index for the next order to be processed in checkVolume() for the given price limits
        mapping (uint => mapping (uint => uint)) checkBuyVolume; // The volume of buy orders that can be filled so far in checkVolume() for the given price limits
        mapping (uint => mapping (uint => uint)) checkSellVolume; // The volume of sell orders that can be filled so far in checkVolume() for the given price limits

        uint minimumOrder;

        bool supported;
        bool lastAuction; // Whether token is to be removed after the next auction
        bool everSupported; // Whether the token has ever been supported by this contract

        uint nextAuctionTime;
        uint checkDuration;
        bool startedReveal;
        bool startedCheck;
        bool startedExecute;

        uint onchainBuyCount; // Orders after this index are offchain and have tier 2/3 fees
        uint onchainSellCount; // Orders after this index are offchain and have tier 2/3 fees
        uint publicBuyCount; // Orders after this index are hidden and have tier 3 fees
        uint publicSellCount; // Orders after this index are hidden and have tier 3 fees
        uint revealDuration;

        uint decimals;
        uint unit;

        uint lastPrice;

        bool noReturnTransfer; // Whether the token implementation is missing the return value in transfer()
        bool noReturnApprove; // Whether the token implementation is missing the return value in approve()
        bool noReturnTransferFrom; // Whether the token implementation is missing the return value in transferFrom()
        bool autoWithdrawDisabled;
    }

    mapping (address => TokenAuction) token;

    address[] indexToAddress; // List of user IDs for more efficient storage
    mapping (address => uint32) public addressToIndex;
    address admin;
    address operator;
    mapping (address => mapping (address => uint)) public balances; // Address 0 represents the Ether balance
    bool constant developmentTiming = false; // Timing checks are disabled when true, to make testing easier during development
    uint[] public fees; // Multiplied by (1 ether). Three tiers: On-chain, Off-Chain Public, Off-Chain Hidden
    address feeAccount;
    bool feeAccountFinalised; // If true, the fee account can no longer be changed
    address[] tokenList;
    uint public activeAuctionCount = 0; // The number of auctions that are currently active (either running or in the check/reveal/execute period)
    uint public revealingAuctionCount = 0; // The number of auctions that are currently in their reveal period
    mapping (address => uint) public signedWithdrawalNonce;
    mapping (address => bool) public autoWithdraw;
    mapping (address => bool) public staticAutoWithdraw;
    mapping (address => bool) public verifiedContract;

    uint[] reserve; // An array used as a gas reserve

    event BuyOrderPosted(address indexed tokenAddress, uint indexed auctionIndex, address indexed userAddress, uint orderIndex, uint price, uint amount);
    event BuyOrderRemoved(address indexed tokenAddress, uint indexed auctionIndex, address indexed userAddress, uint orderIndex);
    event SellOrderPosted(address indexed tokenAddress, uint indexed auctionIndex, address indexed userAddress, uint orderIndex, uint price, uint amount);
    event SellOrderRemoved(address indexed tokenAddress, uint indexed auctionIndex, address indexed userAddress, uint orderIndex);
    event Deposit(address indexed tokenAddress, address indexed userAddress, uint amount);
    event Withdrawal(address indexed tokenAddress, address indexed userAddress, uint amount);
    event AuctionHistory(address indexed tokenAddress, uint indexed auctionIndex, uint auctionTime, uint price, uint volume);

    function Auction(address a) {
        admin = a;
        indexToAddress.push(0);
        operator = a;
        feeAccount = a;
        fees.push(0);
        fees.push(0);
        fees.push(0);
    }

    function addToken(address t, uint min) external {
        require(msg.sender == operator);
        require(t > 0);
        if (!token[t].everSupported) {
            tokenList.push(t);
        }
        token[t].supported = true;
        token[t].everSupported = true;
        token[t].lastAuction = false;
        token[t].minimumOrder = min;
        if (token[t].unit == 0) {
            token[t].decimals = Token(t).decimals();
            token[t].unit = 10**token[t].decimals;
        }
    }

    function setNoReturnToken(address t, bool nrt, bool nra, bool nrtf) external {
        require(msg.sender == operator);
        token[t].noReturnTransfer = nrt;
        token[t].noReturnApprove = nra;
        token[t].noReturnTransferFrom = nrtf;
    }

    function removeToken(address t) external {
        require(msg.sender == operator);
        token[t].lastAuction = true;
    }

    function changeAdmin(address a) external {
        require(msg.sender == admin);
        admin = a;
    }

    function changeOperator(address a) external {
        require(msg.sender == admin);
        operator = a;
    }

    function changeFeeAccount(address a) external {
        require(msg.sender == admin);
        // Check if there are any ongoing auctions, otherwise the feeAccountBalance could cause problems
        require(activeAuctionCount == 0);
        require(!feeAccountFinalised);
        feeAccount = a;
    }

    // Finalising the fee account allows giving the fees to a smart contract with no ability to change it
    function finaliseFeeAccount() external {
        require(msg.sender == admin);
        feeAccountFinalised = true;
    }

    function changeMinimumOrder(address t, uint x) external {
        require(msg.sender == operator);
        require(token[t].supported);
        token[t].minimumOrder = x;
    }

    function changeFees(uint[] f) external {
        require(msg.sender == operator);
        // Check if there are any ongoing auctions
        require(activeAuctionCount == 0);
        // Check that all fees are at most 1%
        for (uint i=0; i < f.length; i++) {
            require(f[i] < (10 finney));
        }
        fees = f;
    }

    // There are three tiers of fees: On-Chain, Off-Chain Public and Off-Chain Hidden
    function feeForBuyOrder(address t, uint i) public view returns (uint) {
        if (i < token[t].onchainBuyCount) {
            return fees[0];
        } else {
            if (i < token[t].publicBuyCount) {
                return fees[1];
            } else {
                return fees[2];
            }
        }
    }

    function feeForSellOrder(address t, uint i) public view returns (uint) {
        if (i < token[t].onchainSellCount) {
            return fees[0];
        } else {
            if (i < token[t].publicSellCount) {
                return fees[1];
            } else {
                return fees[2];
            }
        }
    }

    function isAuctionTime(address t) public view returns (bool) {
        if (developmentTiming) { return true; }
        return (block.timestamp < token[t].nextAuctionTime) && (!token[t].startedReveal);
    }

    function isRevealTime(address t) public view returns (bool) {
        if (developmentTiming) { return true; }
        return (block.timestamp >= token[t].nextAuctionTime || token[t].startedReveal) && (block.timestamp < token[t].nextAuctionTime + token[t].revealDuration && !token[t].startedCheck);
    }

    function isCheckingTime(address t) public view returns (bool) {
        if (developmentTiming) { return true; }
        return (block.timestamp >= token[t].nextAuctionTime + token[t].revealDuration || token[t].startedCheck) && (block.timestamp < token[t].nextAuctionTime + token[t].revealDuration + token[t].checkDuration && !token[t].startedExecute);
    }

    function isExecutionTime(address t) public view returns (bool) {
        if (developmentTiming) { return true; }
        return (block.timestamp >= token[t].nextAuctionTime + token[t].revealDuration + token[t].checkDuration || token[t].startedExecute);
    }

    function setDecimals(address t, uint x) public {
        require(msg.sender == operator);
        require(token[t].unit == 0);
        token[t].decimals = x;
        token[t].unit = 10**x;
    }

    function addReserve(uint x) external {
        uint maxUInt = 0;
        maxUInt = maxUInt - 1;
        for (uint i=0; i < x; i++) {
            reserve.push(maxUInt);
        }
    }

    function useReserve(uint x) private {
        require(x <= reserve.length);
        reserve.length = reserve.length - x;
    }



    function startAuction(address t, uint auctionTime, uint revealDuration, uint checkDuration) external {
        require(msg.sender == operator);
        require(token[t].supported);
        // Disabling startAuction() during Reveal periods ensures that there will always be a time when withdrawals are allowed, even with a malicious operator
        require(revealingAuctionCount == 0);
        require(isExecutionTime(t) || token[t].nextAuctionTime == 0);
        require(!token[t].toBeExecuted);
        require(!token[t].activeAuction);
        require(auctionTime > block.timestamp || developmentTiming);
        require(auctionTime <= block.timestamp + 7 * 24 * 3600 || developmentTiming);
        require(revealDuration <= 24 * 3600);
        require(checkDuration <= 24 * 3600);
        require(checkDuration >= 5 * 60);
        token[t].nextAuctionTime = auctionTime;
        token[t].revealDuration = revealDuration;
        token[t].checkDuration = checkDuration;
        token[t].startedReveal = false;
        token[t].startedCheck = false;
        token[t].startedExecute = false;
        uint maxUInt = 0;
        maxUInt = maxUInt - 1;
        token[t].onchainBuyCount = maxUInt;
        token[t].onchainSellCount = maxUInt;
        token[t].publicBuyCount = maxUInt;
        token[t].publicSellCount = maxUInt;
        token[t].activeAuction = true;
        activeAuctionCount++;
    }

    function buy_(address t, address u, uint p, uint a, uint buyCount) private {
        require(is112bit(p));
        require(is112bit(a));
        require(token[t].supported);
        require(t != address(0));
        require(u != feeAccount); // Fee account balance is handled separately in executeAuction()
        // Appropriate timing constraints are in buy() and revealBuy() methods
        uint index = addressToIndex[u];
        require(index != 0);
        uint balance = balances[0][u];
        uint cost = safeMul(p, a) / (token[t].unit);
        require(safeMul(cost, token[t].unit) == safeMul(p, a));
        uint fee = feeForBuyOrder(t, buyCount);
        uint totalCost = safeAdd(cost, safeMul(cost, fee) / (1 ether));
        require(balance >= totalCost);
        require(cost >= token[0].minimumOrder);
        require(a >= token[t].minimumOrder);
        balances[0][u] = safeSub(balance, totalCost);
        token[t].buyOrders[buyCount] = (((index << 112) | p) << 112) | a;
        emit BuyOrderPosted(t, token[t].auctionIndex, u, buyCount, p, a);
    }

    function sell_(address t, address u, uint p, uint a, uint sellCount) private {
        require(is112bit(p));
        require(is112bit(a));
        require(token[t].supported);
        require(t != address(0));
        require(u != feeAccount);
        // Appropriate timing constraints are in sell() and revealSell() methods
        uint index = addressToIndex[u];
        require(index != 0);
        uint balance = balances[t][u];
        require(balance >= a);
        uint cost = safeMul(p, a) / (token[t].unit);
        require(safeMul(cost, token[t].unit) == safeMul(p, a));
        require(cost >= token[0].minimumOrder);
        require(a >= token[t].minimumOrder);
        balances[t][u] = safeSub(balance, a);
        token[t].sellOrders[sellCount] = (((index << 112) | p) << 112) | a;
        emit SellOrderPosted(t, token[t].auctionIndex, u, sellCount, p, a);
    }

    function buy(address t, uint p, uint a) public {
        require(isAuctionTime(t));
        uint buyCount = token[t].buyCount;
        buy_(t, msg.sender, p, a, buyCount);
        token[t].buyCount = buyCount + 1;
    }

    function sell(address t, uint p, uint a) public {
        require(isAuctionTime(t));
        uint sellCount = token[t].sellCount;
        sell_(t, msg.sender, p, a, sellCount);
        token[t].sellCount = sellCount + 1;
    }

    function depositAndBuy(address t, uint p, uint a) external payable {
        deposit();
        buy(t, p, a);
        if (!staticAutoWithdraw[msg.sender] && !autoWithdraw[msg.sender]) {
            autoWithdraw[msg.sender] = true;
        }
    }

    function depositAndSell(address t, uint p, uint a, uint depositAmount) external {
        depositToken(t, depositAmount);
        sell(t, p, a);
        if (!staticAutoWithdraw[msg.sender] && !autoWithdraw[msg.sender]) {
            autoWithdraw[msg.sender] = true;
        }
    }

    function removeBuy(address t, uint i) external {
        require(token[t].supported);
        require(isAuctionTime(t));
        uint index = addressToIndex[msg.sender];
        require(index != 0);
        uint order = token[t].buyOrders[i];
        require(order >> 224 == index);
        uint cost = safeMul(((order << 32) >> 144), ((order << 144) >> 144)) / (token[t].unit);
        uint totalCost = safeAdd(cost, safeMul(cost, feeForBuyOrder(t, i)) / (1 ether));
        balances[0][msg.sender] = safeAdd(balances[0][msg.sender], totalCost);
        token[t].buyOrders[i] &= (((1 << 144) - 1) << 112);
        emit BuyOrderRemoved(t, token[t].auctionIndex, msg.sender, i);
    }

    function removeSell(address t, uint i) external {
        require(token[t].supported);
        require(isAuctionTime(t));
        uint index = addressToIndex[msg.sender];
        require(index != 0);
        uint order = token[t].sellOrders[i];
        require(order >> 224 == index);
        balances[t][msg.sender] = safeAdd(balances[t][msg.sender], (order << 144) >> 144);
        token[t].sellOrders[i] &= (((1 << 144) - 1) << 112);
        emit SellOrderRemoved(t, token[t].auctionIndex, msg.sender, i);
    }

    // The operator needs to finalise the on-chain orders by calling this function so that the optimal price can be calculated and the operator can filter the off-chain orders based on that price (off-chain orders that would not get filled are not submitted to the blockchain to reduce transaction fees)
    function startReveal(address t) external {
        require(msg.sender == operator);
        require(isRevealTime(t));
        require(!token[t].startedReveal);
        revealingAuctionCount++;
        token[t].startedReveal = true;
    }

    // The smart contract needs to know in advance which off-chain orders are visible and which are hidden, since they can have different fees
    // Off-chain orders are sorted so that all visible orders come before the hidden orders and submitting the count for the total number of visible orders is enough to tell which off-chain orders are visible and hidden
    function revealPublicOrdersCount(address t, uint pbc, uint psc) external {
        require(msg.sender == operator);
        require(isRevealTime(t));
        require(token[t].startedReveal);
        require(pbc >= token[t].buyCount);
        require(psc >= token[t].sellCount);
        require(token[t].onchainBuyCount > token[t].buyCount); // This ensures the function can only be called once per auction
        require(token[t].onchainSellCount > token[t].sellCount); // This ensures the function can only be called once per auction
        token[t].onchainBuyCount = token[t].buyCount;
        token[t].onchainSellCount = token[t].sellCount;
        token[t].publicBuyCount = pbc;
        token[t].publicSellCount = psc;
    }

    function recoverHashSignatory(address t, bytes type_, uint price, uint amount, uint id, uint8 v, bytes32 r, bytes32 s) public pure returns (address) {
        bytes32 hash = keccak256(abi.encodePacked(type_, amount, t, price, id));
        address signatory = ecrecover(keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash)), v, r, s);
        require(signatory != address(0));
        return signatory;
    }

    function recoverTypedSignatory(address t, bytes type_, uint price, uint amount, uint id, uint8 v, bytes32 r, bytes32 s) public pure returns (address) {
        bytes32 hash = keccak256(abi.encodePacked(
          keccak256(abi.encodePacked('string Order type', 'address Token address', 'uint256 Price', 'uint256 Amount', 'uint256 Auction index')),
          keccak256(abi.encodePacked(type_, t, price, amount, id))
        ));
        address signatory = ecrecover(hash, v, r, s);
        require(signatory != address(0));
        return signatory;
    }

    // Allows the operator to reveal off-chain orders (which have two benefits: they only need to be submitted if they get filled and cost no gas otherwise, and they can optionally be hidden from other users until filled)
    function revealBuy_(address t, uint order, uint8 v, bytes32 r, bytes32 s, uint buyCount) private {
        require(msg.sender == operator);
        require(isRevealTime(t));
        require(token[t].startedReveal);
        if (buyCount > token[t].onchainBuyCount && buyCount != token[t].publicBuyCount) {
            require(order > token[t].buyOrders[buyCount - 1]); // Enforces the ordering to prevent double submission
        }
        address userAddress = indexToAddress[order >> 224];
        uint price = (order << 32) >> 144;
        uint amount = (order << 144) >> 144;
        uint id = token[t].auctionIndex;
        address signedUserAddress;
        if (buyCount < token[t].publicBuyCount) {
            signedUserAddress = recoverTypedSignatory(t, "Public buy", price, amount, id, v, r, s);
        } else {
            signedUserAddress = recoverTypedSignatory(t, "Hidden buy", price, amount, id, v, r, s);
        }
        if (signedUserAddress != userAddress) {
            if (buyCount < token[t].publicBuyCount) {
                signedUserAddress = recoverHashSignatory(t, "Public buy", price, amount, id, v, r, s);
            } else {
                signedUserAddress = recoverHashSignatory(t, "Hidden buy", price, amount, id, v, r, s);
            }
            require(signedUserAddress == userAddress);
        }
        buy_(t, userAddress, price, amount, buyCount);
    }

    function revealSell_(address t, uint order, uint8 v, bytes32 r, bytes32 s, uint sellCount) private {
        require(msg.sender == operator);
        require(isRevealTime(t));
        require(token[t].startedReveal);
        if (sellCount > token[t].onchainSellCount && sellCount != token[t].publicSellCount) {
            require(order > token[t].sellOrders[sellCount - 1]); // Enforces the ordering to prevent double submission
        }
        address userAddress = indexToAddress[order >> 224];
        uint price = (order << 32) >> 144;
        uint amount = (order << 144) >> 144;
        uint id = token[t].auctionIndex;
        address signedUserAddress;
        if (sellCount < token[t].publicSellCount) {
            signedUserAddress = recoverTypedSignatory(t, "Public sell", price, amount, id, v, r, s);
        } else {
            signedUserAddress = recoverTypedSignatory(t, "Hidden sell", price, amount, id, v, r, s);
        }
        if (signedUserAddress != userAddress) {
            if (sellCount < token[t].publicSellCount) {
                signedUserAddress = recoverHashSignatory(t, "Public sell", price, amount, id, v, r, s);
            } else {
                signedUserAddress = recoverHashSignatory(t, "Hidden sell", price, amount, id, v, r, s);
            }
            require(signedUserAddress == userAddress);
        }
        sell_(t, userAddress, price, amount, sellCount);
    }

    // The operator can submit off-chain orders in batches to reduce gas use
    function revealBuys(address t, uint[] order, uint8[] v, bytes32[] r, bytes32[] s, uint reserveUsage) external {
        uint buyCount = token[t].buyCount;
        for (uint i = 0; i < order.length; i++) {
            revealBuy_(t, order[i], v[i], r[i], s[i], buyCount);
            buyCount++;
        }
        token[t].buyCount = buyCount;
        useReserve(reserveUsage);
    }

    function revealSells(address t, uint[] order, uint8[] v, bytes32[] r, bytes32[] s, uint reserveUsage) external {
        uint sellCount = token[t].sellCount;
        for (uint i = 0; i < order.length; i++) {
            revealSell_(t, order[i], v[i], r[i], s[i], sellCount);
            sellCount++;
        }
        token[t].sellCount = sellCount;
        useReserve(reserveUsage);
    }



    // Note: Excluding the tokenAddress parameter is necessary to prevent stack overflow when executing a successful sell order
    function addEtherBalance_(address userAddress, uint amount) private {
        bool withdrawn = false;
        if (amount > 0) {
            if (autoWithdraw[userAddress] && !token[0].autoWithdrawDisabled) {
                uint size;
                assembly {size := extcodesize(userAddress)}
                if (size == 0) {
                    withdrawn = userAddress.send(amount);
                }
            }
            if (!withdrawn) {
                balances[0][userAddress] = safeAdd(balances[0][userAddress], amount);
            }
        }
    }

    function addTokenBalance_(address tokenAddress, address userAddress, uint amount) private {
        require(tokenAddress != address(0));
        bool withdrawn = false;
        if (amount > 0) {
            if (autoWithdraw[userAddress] && !token[tokenAddress].autoWithdrawDisabled) {
                if (!token[tokenAddress].noReturnTransfer) {
                    withdrawn = Token(tokenAddress).transfer(userAddress, amount);
                }
            }
            if (!withdrawn) {
                balances[tokenAddress][userAddress] = safeAdd(balances[tokenAddress][userAddress], amount);
            }
        }
    }

    // Checks the volume for the given limit prices for buy and sell orders
    function checkVolume(address t, uint pb, uint ps, uint limit, uint reserveUsage) external {
        require(is112bit(pb));
        require(is112bit(ps));
        require(ps <= pb);
        require(token[t].supported);
        require(isCheckingTime(t));
        require(token[t].startedReveal);
        if (!token[t].startedCheck) {
            revealingAuctionCount = safeSub(revealingAuctionCount, 1);
            token[t].startedCheck = true;
        }
        if (token[t].checkAuctionIndex[pb][ps] < token[t].auctionIndex) {
            token[t].checkIndex[pb][ps] = 0;
            token[t].checkBuyVolume[pb][ps] = 0;
            token[t].checkSellVolume[pb][ps] = 0;
            token[t].checkAuctionIndex[pb][ps] = token[t].auctionIndex;
        }
        uint buyVolume = token[t].checkBuyVolume[pb][ps];
        uint order;
        for (uint i = token[t].checkIndex[pb][ps]; (i < safeAdd(token[t].checkIndex[pb][ps], limit)) && (i < token[t].buyCount); i++) {
            order = token[t].buyOrders[i];
            if ((order << 32) >> 144 >= pb) {
                buyVolume += (order << 144) >> 144;
            }
        }
        uint sellVolume = token[t].checkSellVolume[pb][ps];
        for (i = token[t].checkIndex[pb][ps]; (i < safeAdd(token[t].checkIndex[pb][ps], limit)) && (i < token[t].sellCount); i++) {
            order = token[t].sellOrders[i];
            if ((order << 32) >> 144 <= ps) {
                sellVolume += (order << 144) >> 144;
            }
        }
        token[t].checkIndex[pb][ps] = safeAdd(token[t].checkIndex[pb][ps], limit);
        if ((token[t].checkIndex[pb][ps] >= token[t].buyCount) && (token[t].checkIndex[pb][ps] >= token[t].sellCount)) {
            uint volume;
            if (buyVolume < sellVolume) {
                volume = buyVolume;
            } else {
                volume = sellVolume;
            }
            if (volume > token[t].maxVolume || (volume == token[t].maxVolume && pb > token[t].maxVolumePriceB) || (volume == token[t].maxVolume && pb == token[t].maxVolumePriceB && ps < token[t].maxVolumePriceS)) {
                token[t].maxVolume = volume;
                if (buyVolume > sellVolume) {
                    token[t].maxVolumePrice = pb;
                } else {
                    if (sellVolume > buyVolume) {
                        token[t].maxVolumePrice = ps;
                    } else {
                        token[t].maxVolumePrice = ps;
                        token[t].maxVolumePrice += (pb - ps) / 2;
                    }
                }
                token[t].maxVolumePriceB = pb;
                token[t].maxVolumePriceS = ps;
            }
            // Requires a final call from the operator to confirm the auction, in order to prevent potential spam attacks
            // The optimal price from the received submissions will still be chosen, but this ensures that the operator's price suggestion is always considered
            if (msg.sender == operator) {
                token[t].toBeExecuted = true;
            }
        } else {
            token[t].checkBuyVolume[pb][ps] = buyVolume;
            token[t].checkSellVolume[pb][ps] = sellVolume;
        }
        if (msg.sender == operator) {
            useReserve(reserveUsage);
        }
    }

    function executeAuction(address t, uint limit, uint reserveUsage) external {
        require(isExecutionTime(t));
        require(token[t].supported);
        require(token[t].activeAuction);
        // Set flags that allow withdrawal even if no checkVolume() call was made in the Check period
        if (!token[t].startedCheck) {
            // Only decrement revealingAuctionCount if it was incremented by startReveal()
            if (token[t].startedReveal) {
                revealingAuctionCount = safeSub(revealingAuctionCount, 1);
            }
            token[t].startedCheck = true;
        }
        // If the auction could not be confirmed, execution is avoided by setting the volume to zero
        if (!token[t].toBeExecuted) {
            token[t].maxVolume = 0;
        }
        if (!token[t].startedExecute) {
            token[t].startedExecute = true;
        }
        uint amount;
        uint volume = token[t].executionBuyVolume;
        uint[6] memory current; // A memory array is required to avoid stack overflow, index descriptions below:
        // [0] - currentOrder
        // [1] - currentCost
        // [2] - currentTotalCost
        // [3] - currentNewCost
        // [4] - currentNewTotalCost
        // [5] - currentFee
        uint feeAccountBalance = balances[0][feeAccount];
        address currentAddress;
        for (uint i = token[t].executionIndex; (i < safeAdd(token[t].executionIndex, limit)) && (i < token[t].buyCount); i++) {
            current[0] = token[t].buyOrders[i];
            currentAddress = indexToAddress[current[0] >> 224];
            if ((current[0] << 32) >> 144 >= token[t].maxVolumePriceB && volume < token[t].maxVolume) {
                // If the order gets filled
                amount = (current[0] << 144) >> 144;
                volume += amount;
                if (volume > token[t].maxVolume) {
                    // If the volume overflows, return the difference
                    current[1] = safeMul((current[0] << 32) >> 144, amount) / (token[t].unit);
                    current[2] = safeAdd(current[1], safeMul(current[1], feeForBuyOrder(t, i)) / (1 ether));
                    amount = safeSub(amount, safeSub(volume, token[t].maxVolume));
                    current[3] = safeMul((current[0] << 32) >> 144, amount) / (token[t].unit);
                    current[4] = safeAdd(current[3], safeMul(current[3], feeForBuyOrder(t, i)) / (1 ether));
                    addEtherBalance_(currentAddress, safeSub(current[2], current[4]));
                }
                if ((current[0] << 32) >> 144 > token[t].maxVolumePrice) {
                    // If the price is different, return the difference
                    current[1] = safeMul((current[0] << 32) >> 144, amount) / (token[t].unit);
                    current[2] = safeAdd(current[1], safeMul(current[1], feeForBuyOrder(t, i)) / (1 ether));
                    current[3] = safeMul(token[t].maxVolumePrice, amount) / (token[t].unit);
                    current[4] = safeAdd(current[3], safeMul(current[3], feeForBuyOrder(t, i)) / (1 ether));
                    addEtherBalance_(currentAddress, safeSub(current[2], current[4]));
                }
                // Add the correct amount of tokens
                addTokenBalance_(t, currentAddress, amount);
                current[5] = safeMul(safeMul(token[t].maxVolumePrice, amount) / (token[t].unit), feeForBuyOrder(t, i)) / (1 ether);
                feeAccountBalance += current[5];
            } else {
                // If there is no liquidity left to fill the order, return the whole amount
                current[1] = safeMul((current[0] << 32) >> 144, (current[0] << 144) >> 144) / (token[t].unit);
                current[2] = safeAdd(current[1], safeMul(current[1], feeForBuyOrder(t, i)) / (1 ether));
                addEtherBalance_(currentAddress, current[2]);
            }
        }
        token[t].executionBuyVolume = volume;
        volume = token[t].executionSellVolume;
        for (i = token[t].executionIndex; (i < safeAdd(token[t].executionIndex, limit)) && (i < token[t].sellCount); i++) {
            current[0] = token[t].sellOrders[i];
            currentAddress = indexToAddress[current[0] >> 224];
            if ((current[0] << 32) >> 144 <= token[t].maxVolumePriceS && volume < token[t].maxVolume) {
                // If the order gets filled
                amount = (current[0] << 144) >> 144;
                volume += amount;
                if (volume > token[t].maxVolume) {
                    // If the volume overflows, return the difference
                    addTokenBalance_(t, currentAddress, safeSub(volume, token[t].maxVolume));
                    amount = safeSub(amount, safeSub(volume, token[t].maxVolume));
                }
                // Add the correct amount of ether
                current[5] = safeMul(safeMul(token[t].maxVolumePrice, amount) / (token[t].unit), feeForSellOrder(t, i)) / (1 ether);
                addEtherBalance_(currentAddress, safeSub(safeMul(token[t].maxVolumePrice, amount) / (token[t].unit), current[5]));
                feeAccountBalance += current[5];
            } else {
                // If there is no liquidity left to fill the order, return the whole amount
                addTokenBalance_(t, currentAddress, (current[0] << 144) >> 144);
            }
        }
        token[t].executionSellVolume = volume;
        balances[0][feeAccount] = feeAccountBalance;
        token[t].executionIndex = safeAdd(token[t].executionIndex, limit);
        if ((token[t].executionIndex >= token[t].buyCount) && (token[t].executionIndex >= token[t].sellCount)) {
            if (token[t].maxVolume > 0) {
                token[t].lastPrice = token[t].maxVolumePrice;
                emit AuctionHistory(t, token[t].auctionIndex, token[t].nextAuctionTime, token[t].maxVolumePrice, token[t].maxVolume);
            }
            token[t].buyCount = 0;
            token[t].sellCount = 0;
            token[t].maxVolume = 0;
            token[t].executionIndex = 0;
            token[t].executionBuyVolume = 0;
            token[t].executionSellVolume = 0;
            token[t].toBeExecuted = false;
            token[t].activeAuction = false;
            token[t].auctionIndex++;
            activeAuctionCount = safeSub(activeAuctionCount, 1);
            if (token[t].lastAuction) {
                token[t].supported = false;
            }
        }
        useReserve(reserveUsage);
    }



    function register_() private returns (uint32) {
        require(is32bit(indexToAddress.length + 1));
        require(addressToIndex[msg.sender] == 0);
        uint32 index = uint32(indexToAddress.length);
        addressToIndex[msg.sender] = index;
        indexToAddress.push(msg.sender);
        return index;
    }

    function deposit() public payable {
        address index = addressToIndex[msg.sender];
        if (index == 0) {
            index = register_();
        }
        balances[0][msg.sender] = safeAdd(balances[0][msg.sender], msg.value);
        emit Deposit(0, msg.sender, msg.value);
        if (!staticAutoWithdraw[msg.sender] && autoWithdraw[msg.sender]) {
            autoWithdraw[msg.sender] = false;
        }
    }

    function withdraw(uint a) external {
        require(balances[0][msg.sender] >= a);
        // Withdrawals are not allowed while any auction is in the Reveal period
        require(revealingAuctionCount == 0);
        balances[0][msg.sender] = safeSub(balances[0][msg.sender], a);
        emit Withdrawal(0, msg.sender, a);
        require(msg.sender.send(a));
    }

    function depositToken_(address t, uint a, address u) private {
        require(t > 0);
        require(token[t].supported);
        uint32 index = addressToIndex[u];
        if (index == 0) {
            index = register_();
        }
        if (!token[t].noReturnTransferFrom) {
            require(Token(t).transferFrom(u, this, a));
        } else {
            NoReturnToken(t).transferFrom(u, this, a);
        }
        balances[t][u] = safeAdd(balances[t][u], a);
        emit Deposit(t, u, a);
        if (!staticAutoWithdraw[u] && autoWithdraw[u]) {
            autoWithdraw[u] = false;
        }
    }

    // It is necessary to call Token(t).approve(this, a) before depositToken() can complete the transfer
    function depositToken(address t, uint a) public {
        depositToken_(t, a, msg.sender);
    }

    // Automatically runs depositToken() or depositAndSell() on Token(t).approveAndCall(this, a, d)
    // Sell order is placed if the extraData in d is 64 bytes long, with the first half being the price and the second the amount
    function receiveApproval(address u, uint256 a, address t, bytes d) external {
        require(t == msg.sender);
        require(token[t].supported);
        if (d.length < 64) {
            depositToken_(t, a, u);
        } else {
            require(d.length == 64);
            uint price;
            uint amount;
            assembly { price := calldataload(164) } // Skip 4 bytes for the function identifier, 3×32 for the other parameters and 2×32 for the dynamically-sized byte array's length
            assembly { amount := calldataload(196) }
            // depositAndSell() with custom userAddress
            depositToken_(t, a, u);
            // sell() with custom userAddress
            require(isAuctionTime(t));
            uint sellCount = token[t].sellCount;
            sell_(t, u, price, amount, sellCount);
            token[t].sellCount = sellCount + 1;
            if (!staticAutoWithdraw[u] && !autoWithdraw[u]) {
                autoWithdraw[u] = true;
            }
        }
    }

    function withdrawToken(address t, uint a) external {
        require(t > 0);
        require(balances[t][msg.sender] >= a);
        // Withdrawals are not allowed while the specified token's auction is in the Reveal period
        require((!token[t].startedReveal) || (token[t].startedCheck));
        balances[t][msg.sender] = safeSub(balances[t][msg.sender], a);
        emit Withdrawal(t, msg.sender, a);
        if (!token[t].noReturnTransfer) {
            require(Token(t).transfer(msg.sender, a));
        } else {
            NoReturnToken(t).transfer(msg.sender, a);
        }
    }

    // Allows the operator to withdraw on behalf of the user when authorised by signature
    // This is a bonus feature for convenience so that the user can pay the transaction fee for withdrawal from their auction balance if they have no Ether left on their account
    function withdrawForUser(address u, address t, uint a, address feeAddress, uint fee, uint8 v, bytes32 r, bytes32 s) external {
        require(msg.sender == operator);
        require(u != address(0));
        bytes32 hash = keccak256(abi.encodePacked(t, a, feeAddress, fee, signedWithdrawalNonce[u]));
        address signatory = ecrecover(keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n", hash)), v, r, s);
        require(signatory == u);
        signedWithdrawalNonce[u]++;
        balances[feeAddress][u] = safeSub(balances[feeAddress][u], fee);
        balances[feeAddress][feeAccount] = safeAdd(balances[feeAddress][feeAccount], fee);
        require(balances[t][u] >= a);
        if (t == address(0)) {
            balances[t][u] = safeSub(balances[t][u], a);
            emit Withdrawal(t, u, a);
            require(u.call.value(a)());
        } else {
            balances[t][u] = safeSub(balances[t][u], a);
            emit Withdrawal(t, u, a);
            if (!token[t].noReturnTransfer) {
                require(Token(t).transfer(u, a));
            } else {
                NoReturnToken(t).transfer(u, a);
            }
        }
    }

    function setStaticAutoWithdraw(bool b) external {
        staticAutoWithdraw[msg.sender] = b;
    }

    function setAutoWithdrawDisabled(address t, bool b) external {
        require(msg.sender == operator);
        token[t].autoWithdrawDisabled = b;
    }

    function setVerifiedContract(address c, bool b) external {
        require(msg.sender == admin);
        verifiedContract[c] = b;
    }

    // Allows the admin to claim tokens that had never been supported (and therefore could never have been deposited directly by a user, only transferred)
    // This may allow us to distribute tokens to users from large airdrops or tokens with a new smart contract
    function claimNeverSupportedToken(address t, uint a) external {
        require(!token[t].everSupported);
        require(msg.sender == admin);
        require(Token(t).balanceOf(this) >= a);
        balances[t][msg.sender] = safeAdd(balances[t][msg.sender], a);
    }

    // Allows migrating all the user's funds to an upgraded smart contract
    function migrate(address contractAddress, uint low, uint high) external {
        require(verifiedContract[contractAddress]);
        require(tokenList.length > 0);
        // Withdrawals are not allowed while any auction is in the Reveal period
        require(revealingAuctionCount == 0);
        uint amount = 0;
        if (balances[0][msg.sender] > 0) {
            amount = balances[0][msg.sender];
            balances[0][msg.sender] = 0;
            NewAuction(contractAddress).depositForUser.value(amount)(msg.sender);
        }
        uint to;
        if (high >= tokenList.length) {
            to = safeSub(tokenList.length, 1);
        } else {
            to = high;
        }
        for (uint i=low; i <= to; i++) {
            if (balances[tokenList[i]][msg.sender] > 0) {
                amount = balances[tokenList[i]][msg.sender];
                balances[tokenList[i]][msg.sender] = 0;
                if (!token[tokenList[i]].noReturnApprove) {
                    require(Token(tokenList[i]).approve(contractAddress, balances[tokenList[i]][msg.sender]));
                } else {
                    NoReturnToken(tokenList[i]).approve(contractAddress, balances[tokenList[i]][msg.sender]);
                }
                NewAuction(contractAddress).depositTokenForUser(msg.sender, tokenList[i], amount);
            }
        }
    }



    function getBalance(address t, address a) external constant returns (uint) {
        return balances[t][a];
    }

    function getBuyCount(address t) external constant returns (uint) {
        return token[t].buyCount;
    }

    function getBuyAddress(address t, uint i) external constant returns (address) {
        return indexToAddress[token[t].buyOrders[i] >> 224];
    }

    function getBuyPrice(address t, uint i) external constant returns (uint) {
        return (token[t].buyOrders[i] << 32) >> 144;
    }

    function getBuyAmount(address t, uint i) external constant returns (uint) {
        return (token[t].buyOrders[i] << 144) >> 144;
    }

    function getSellCount(address t) external constant returns (uint) {
        return token[t].sellCount;
    }

    function getSellAddress(address t, uint i) external constant returns (address) {
        return indexToAddress[token[t].sellOrders[i] >> 224];
    }

    function getSellPrice(address t, uint i) external constant returns (uint) {
        return (token[t].sellOrders[i] << 32) >> 144;
    }

    function getSellAmount(address t, uint i) external constant returns (uint) {
        return (token[t].sellOrders[i] << 144) >> 144;
    }

    function getMaxVolume(address t) external constant returns (uint) {
        return token[t].maxVolume;
    }

    function getMaxVolumePriceB(address t) external constant returns (uint) {
        return token[t].maxVolumePriceB;
    }

    function getMaxVolumePriceS(address t) external constant returns (uint) {
        return token[t].maxVolumePriceS;
    }

    function getMaxVolumePrice(address t) external constant returns (uint) {
        return token[t].maxVolumePrice;
    }

    function getUserIndex(address u) external constant returns (uint) {
        return addressToIndex[u];
    }

    function getAuctionIndex(address t) external constant returns (uint) {
        return token[t].auctionIndex;
    }

    function getNextAuctionTime(address t) external constant returns (uint) {
        return token[t].nextAuctionTime;
    }

    function getLastPrice(address t) external constant returns (uint) {
        return token[t].lastPrice;
    }
}