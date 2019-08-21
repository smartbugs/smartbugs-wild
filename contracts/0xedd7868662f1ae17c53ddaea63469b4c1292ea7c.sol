pragma solidity ^0.4.24;

contract Token {
    bytes32 public standard;
    bytes32 public name;
    bytes32 public symbol;
    uint256 public totalSupply;
    uint8 public decimals;
    bool public allowTransactions;
    mapping (address => uint256) public balanceOf;
    mapping (address => mapping (address => uint256)) public allowance;
    function transfer(address _to, uint256 _value) public returns (bool success);
    function approveAndCall(address _spender, uint256 _value, bytes _extraData) public returns (bool success);
    function approve(address _spender, uint256 _value) public returns (bool success);
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);
}

contract NescrowExchangeService {

    address owner = msg.sender;

    uint256 public feeRateMin = 200;//100/200 = max 0.5%
    uint256 public takerFeeRate = 0;
    uint256 public makerFeeRate = 0;
    address public feeAddress;

    mapping (address => bool) public admins;
    mapping (bytes32 => bool) public traded;
    mapping (bytes32 => uint256) public orderFills;
    mapping (bytes32 => bool) public withdrawn;
    mapping (bytes32 => bool) public transfers;
    mapping (address => mapping (address => uint256)) public balances;
    mapping (address => uint256) public tradesLocked;
    mapping (address => uint256) public disableFees;
    mapping (address => uint256) public tokenDecimals;
    mapping (address => bool) public tokenRegistered;

    event Deposit(address token, address user, uint256 amount, uint256 balance);
    event Withdraw(address token, address user, uint256 amount, uint256 balance);
    event TradesLock(address user);
    event TradesUnlock(address user);

    modifier onlyOwner {
        assert(msg.sender == owner);
        _;
    }

    modifier onlyAdmin {
        require(msg.sender == owner || admins[msg.sender]);
        _;
    }

    function setOwner(address newOwner) public onlyOwner {
        owner = newOwner;
    }

    function getOwner() public view returns (address out) {
        return owner;
    }

    function setAdmin(address admin, bool isAdmin) public onlyOwner {
        admins[admin] = isAdmin;
    }

    function deposit() public payable {
        uint amount = safeDiv(msg.value, 10**10);//wei to 8 decimals
        require(msg.value > 0);
        increaseBalance(msg.sender, address(0), amount);
        emit Deposit(address(0), msg.sender, amount, balances[address(0)][msg.sender]);
    }

    function depositToken(address token, uint256 amount) public {
        require(amount > 0);
        require(Token(token).transferFrom(msg.sender, this, toTokenAmount(token, amount)));
        increaseBalance(msg.sender, token, amount);
        emit Deposit(token, msg.sender, amount, balances[token][msg.sender]);
    }

    function sendTips() public payable {
        uint amount = safeDiv(msg.value, 10**10);//wei to 8 decimals
        require(msg.value > 0);
        increaseBalance(feeAddress, address(0), amount);
    }

    function sendTipsToken(address token, uint256 amount) public {
        require(amount > 0);
        require(Token(token).transferFrom(msg.sender, this, toTokenAmount(token, amount)));
        increaseBalance(feeAddress, token, amount);
    }

    function transferTips(address token, uint256 amount, address fromUser, uint nonce, uint8 v, bytes32 r, bytes32 s)
        public onlyAdmin {

        require(amount > 0);

        bytes32 hash = keccak256(abi.encodePacked(this, token, amount, fromUser, nonce));
        require(!transfers[hash]);
        transfers[hash] = true;

        address signer = ecrecover(keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash)), v, r, s);
        require(fromUser == signer);

        require(reduceBalance(fromUser, token, amount));
        increaseBalance(feeAddress, token, amount);
    }

    function transfer(address token, uint256 amount, address fromUser, address toUser, uint nonce, uint8 v, bytes32 r, bytes32 s)
        public onlyAdmin {

        require(amount > 0);

        bytes32 hash = keccak256(abi.encodePacked(this, token, amount, fromUser, toUser, nonce));
        require(!transfers[hash]);
        transfers[hash] = true;

        address signer = ecrecover(keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash)), v, r, s);
        require(fromUser == signer);

        require(reduceBalance(fromUser, token, amount));
        increaseBalance(toUser, token, amount);
    }

    function withdrawAdmin(address token, uint256 amount, address user, uint nonce, uint8 v, bytes32 r, bytes32 s)
        public onlyAdmin {

        require(amount > 0);

        bytes32 hash = keccak256(abi.encodePacked(this, token, amount, user, nonce));
        require(!withdrawn[hash]);
        withdrawn[hash] = true;

        address signer = ecrecover(keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash)), v, r, s);
        require(user == signer);

        require(reduceBalance(user, token, amount));
        if (token == address(0)) {
            require(user.send(toTokenAmount(address(0), amount)));
        } else {
            require(Token(token).transfer(user, toTokenAmount(token, amount)));
        }
        emit Withdraw(token, user, amount, balances[token][user]);
    }

    function withdraw(address token, uint256 amount) public {

        require(amount > 0);
        require(tradesLocked[msg.sender] > block.number);
        require(reduceBalance(msg.sender, token, amount));

        if (token == address(0)) {
            require(msg.sender.send(toTokenAmount(address(0), amount)));
        } else {
            require(Token(token).transfer(msg.sender, toTokenAmount(token, amount)));
        }
        emit Withdraw(token, msg.sender, amount, balances[token][msg.sender]);
    }

    function reduceBalance(address user, address token, uint256 amount) private returns(bool) {
        if (balances[token][user] < amount) return false;
        balances[token][user] = safeSub(balances[token][user], amount);
        return true;
    }

    function increaseBalance(address user, address token, uint256 amount) private returns(bool) {
        balances[token][user] = safeAdd(balances[token][user], amount);
        return true;
    }

    function toTokenAmount(address token, uint256 amount) private view returns (uint256) {

        require(tokenRegistered[token]);
        uint256 decimals = token == address(0)
            ? 18
            : tokenDecimals[token];

        if (decimals == 8) {
            return amount;
        }

        if (decimals > 8) {
            return safeMul(amount, 10**(decimals - 8));
        } else {
            return safeDiv(amount, 10**(8 - decimals));
        }
    }

    function setTakerFeeRate(uint256 feeRate) public onlyAdmin {
        require(feeRate == 0 || feeRate >= feeRateMin);
        takerFeeRate = feeRate;
    }

    function setMakerFeeRate(uint256 feeRate) public onlyAdmin {
        require(feeRate == 0 || feeRate >= feeRateMin);
        makerFeeRate = feeRate;
    }

    function setFeeAddress(address _feeAddress) public onlyAdmin {
        require(_feeAddress != address(0));
        feeAddress = _feeAddress;
    }

    function setDisableFees(address user, uint256 timestamp) public onlyAdmin {
        require(timestamp > block.timestamp);
        disableFees[user] = timestamp;
    }

    function invalidateOrder(address user, uint256 timestamp) public onlyAdmin {
        require(timestamp > block.timestamp);
        disableFees[user] = timestamp;
    }

    function setTokenDecimals(address token, uint256 decimals) public onlyAdmin {
        require(!tokenRegistered[token]);
        tokenRegistered[token] = true;
        tokenDecimals[token] = decimals;
    }

    function tradesLock(address user) public {
        require(user == msg.sender);
        tradesLocked[user] = block.number + 20000;
        emit TradesLock(user);
    }

    function tradesUnlock(address user) public {
        require(user == msg.sender);
        tradesLocked[user] = 0;
        emit TradesUnlock(user);
    }

    function isUserMakerFeeEnabled(address user) private view returns(bool) {
        return makerFeeRate > 0 && disableFees[user] < block.timestamp;
    }

    function isUserTakerFeeEnabled(address user) private view returns(bool) {
        return takerFeeRate > 0 && disableFees[user] < block.timestamp;
    }

    function trade(
        uint256[6] amounts,
        address[4] addresses,
        uint8[2] v,
        bytes32[4] rs
    ) public onlyAdmin {
        /**
            amounts: offerAmount, wantAmount, offerAmountToFill, blockExpires, nonce, nonceTrade
            addresses: maker, taker, offerToken, wantToken
        */
        require(tradesLocked[addresses[0]] < block.number);
        require(block.timestamp <= amounts[3]);
        bytes32 orderHash = keccak256(abi.encodePacked(this, addresses[2], addresses[3], addresses[0], amounts[0], amounts[1], amounts[3], amounts[4]));

        require(ecrecover(keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", orderHash)), v[0], rs[0], rs[1]) == addresses[0]);

        bytes32 tradeHash = keccak256(abi.encodePacked(orderHash, amounts[2], addresses[1], amounts[5]));
        require(ecrecover(keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", tradeHash)), v[1], rs[2], rs[3]) == addresses[1]);

        require(!traded[tradeHash]);
        traded[tradeHash] = true;

        require(safeSub(amounts[0], orderFills[orderHash]) >= amounts[2]);

        uint256 wantAmountToTake = safeDiv(safeMul(amounts[2], amounts[1]), amounts[0]);
        require(wantAmountToTake > 0);

        require(reduceBalance(addresses[0], addresses[2], amounts[2]));
        require(reduceBalance(addresses[1], addresses[3], safeDiv(safeMul(amounts[2], amounts[1]), amounts[0])));

        if (isUserMakerFeeEnabled(addresses[0])) {
            increaseBalance(addresses[0], addresses[3], safeSub(wantAmountToTake, safeDiv(wantAmountToTake, makerFeeRate)));
            increaseBalance(feeAddress, addresses[3], safeDiv(wantAmountToTake, makerFeeRate));
        } else {
            increaseBalance(addresses[0], addresses[3], wantAmountToTake);
        }

        if (isUserTakerFeeEnabled(addresses[1])) {
            increaseBalance(addresses[1], addresses[2], safeSub(amounts[2], safeDiv(amounts[2], takerFeeRate)));
            increaseBalance(feeAddress, addresses[2], safeDiv(amounts[2], takerFeeRate));
        } else {
            increaseBalance(addresses[1], addresses[2], amounts[2]);
        }

        orderFills[orderHash] = safeAdd(orderFills[orderHash], amounts[2]);
    }

    function tradeWithTips(
        uint256[9] amounts,
        address[4] addresses,
        uint8[2] v,
        bytes32[4] rs
    ) public onlyAdmin {
        /**
            amounts: offerAmount, wantAmount, offerAmountToFill, blockExpires, nonce, nonceTrade, makerTips, takerTips, p2p
            addresses: maker, taker, offerToken, wantToken
        */
        require(tradesLocked[addresses[0]] < block.number);
        require(block.timestamp <= amounts[3]);

        bytes32 orderHash;
        if (amounts[8] == 0) {
            orderHash = amounts[6] > 0
                ? keccak256(abi.encodePacked(this, addresses[2], addresses[3], addresses[0], amounts[0], amounts[1], amounts[3], amounts[4], amounts[6]))
                : keccak256(abi.encodePacked(this, addresses[2], addresses[3], addresses[0], amounts[0], amounts[1], amounts[3], amounts[4]));
        } else {
            orderHash = amounts[6] > 0
                ? keccak256(abi.encodePacked(this, addresses[2], addresses[3], addresses[0], addresses[1], amounts[0], amounts[1], amounts[3], amounts[4], amounts[6]))
                : keccak256(abi.encodePacked(this, addresses[2], addresses[3], addresses[0], addresses[1], amounts[0], amounts[1], amounts[3], amounts[4]));
        }

        require(ecrecover(keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", orderHash)), v[0], rs[0], rs[1]) == addresses[0]);

        bytes32 tradeHash = amounts[7] > 0
            ? keccak256(abi.encodePacked(orderHash, amounts[2], addresses[1], amounts[5], amounts[7]))
            : keccak256(abi.encodePacked(orderHash, amounts[2], addresses[1], amounts[5]));
        require(ecrecover(keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", tradeHash)), v[1], rs[2], rs[3]) == addresses[1]);

        require(!traded[tradeHash]);
        traded[tradeHash] = true;

        require(safeSub(amounts[0], orderFills[orderHash]) >= amounts[2]);

        uint256 wantAmountToTake = safeDiv(safeMul(amounts[2], amounts[1]), amounts[0]);
        require(wantAmountToTake > 0);

        require(reduceBalance(addresses[0], addresses[2], amounts[2]));
        require(reduceBalance(addresses[1], addresses[3], safeDiv(safeMul(amounts[2], amounts[1]), amounts[0])));

        if (amounts[6] > 0 && !isUserMakerFeeEnabled(addresses[0])) {
            increaseBalance(addresses[0], addresses[3], safeSub(wantAmountToTake, safeDiv(wantAmountToTake, amounts[6])));
            increaseBalance(feeAddress, addresses[3], safeDiv(wantAmountToTake, amounts[6]));
        } else if (amounts[6] == 0 && isUserMakerFeeEnabled(addresses[0])) {
            increaseBalance(addresses[0], addresses[3], safeSub(wantAmountToTake, safeDiv(wantAmountToTake, makerFeeRate)));
            increaseBalance(feeAddress, addresses[3], safeDiv(wantAmountToTake, makerFeeRate));
        } else if (amounts[6] > 0 && isUserMakerFeeEnabled(addresses[0])) {
            increaseBalance(addresses[0], addresses[3], safeSub(wantAmountToTake, safeAdd(safeDiv(wantAmountToTake, amounts[6]), safeDiv(wantAmountToTake, makerFeeRate))));
            increaseBalance(feeAddress, addresses[3], safeAdd(safeDiv(wantAmountToTake, amounts[6]), safeDiv(wantAmountToTake, makerFeeRate)));
        } else {
            increaseBalance(addresses[0], addresses[3], wantAmountToTake);
        }

        if (amounts[7] > 0 && !isUserTakerFeeEnabled(addresses[1])) {
            increaseBalance(addresses[1], addresses[2], safeSub(amounts[2], safeDiv(amounts[2], amounts[7])));
            increaseBalance(feeAddress, addresses[2], safeDiv(amounts[2], amounts[7]));
        } else if (amounts[7] == 0 && isUserTakerFeeEnabled(addresses[1])) {
            increaseBalance(addresses[1], addresses[2], safeSub(amounts[2], safeDiv(amounts[2], takerFeeRate)));
            increaseBalance(feeAddress, addresses[2], safeDiv(amounts[2], takerFeeRate));
        } else if (amounts[7] > 0 && isUserTakerFeeEnabled(addresses[1])) {
            increaseBalance(addresses[1], addresses[2], safeSub(amounts[2], safeAdd(safeDiv(amounts[2], amounts[7]), safeDiv(amounts[2], takerFeeRate))));
            increaseBalance(feeAddress, addresses[2], safeAdd(safeDiv(amounts[2], amounts[7]), safeDiv(amounts[2], takerFeeRate)));
        } else {
            increaseBalance(addresses[1], addresses[2], amounts[2]);
        }

        orderFills[orderHash] = safeAdd(orderFills[orderHash], amounts[2]);
    }

    function() external payable {
        revert();
    }

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

    function safeDiv(uint a, uint b) internal pure returns (uint) {
        assert(b > 0);
        uint c = a / b;
        assert(a == b * c + a % b);
        return c;
    }

}