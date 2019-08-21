pragma solidity ^0.4.24;

contract BasicAccessControl {
    address public owner;
    // address[] public moderators;
    uint16 public totalModerators = 0;
    mapping (address => bool) public moderators;
    bool public isMaintaining = false;

    constructor() public {
        owner = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    modifier onlyModerators() {
        require(msg.sender == owner || moderators[msg.sender] == true);
        _;
    }

    modifier isActive {
        require(!isMaintaining);
        _;
    }

    function ChangeOwner(address _newOwner) public onlyOwner {
        if (_newOwner != address(0)) {
            owner = _newOwner;
        }
    }


    function AddModerator(address _newModerator) public onlyOwner {
        if (moderators[_newModerator] == false) {
            moderators[_newModerator] = true;
            totalModerators += 1;
        }
    }

    function RemoveModerator(address _oldModerator) public onlyOwner {
        if (moderators[_oldModerator] == true) {
            moderators[_oldModerator] = false;
            totalModerators -= 1;
        }
    }

    function UpdateMaintaining(bool _isMaintaining) public onlyOwner {
        isMaintaining = _isMaintaining;
    }
}

interface ERC20 {
    function totalSupply() public view returns (uint supply);
    function balanceOf(address _owner) public view returns (uint balance);
    function transfer(address _to, uint _value) public returns (bool success);
    function transferFrom(address _from, address _to, uint _value) public returns (bool success);
    function approve(address _spender, uint _value) public returns (bool success);
    function allowance(address _owner, address _spender) public view returns (uint remaining);
    function decimals() public view returns(uint digits);
    event Approval(address indexed _owner, address indexed _spender, uint _value);
}

contract EtheremonDataBase {
    uint64 public totalMonster;
    uint32 public totalClass;

    // write
    function addElementToArrayType(EtheremonEnum.ArrayType _type, uint64 _id, uint8 _value) external returns(uint);
    function addMonsterObj(uint32 _classId, address _trainer, string _name) external returns(uint64);
    function removeMonsterIdMapping(address _trainer, uint64 _monsterId) external;

    // read
    function getElementInArrayType(EtheremonEnum.ArrayType _type, uint64 _id, uint _index) external constant returns(uint8);
    function getMonsterClass(uint32 _classId) external constant returns(uint32 classId, uint256 price, uint256 returnPrice, uint32 total, bool catchable);
    function getMonsterObj(uint64 _objId) external constant returns(uint64 objId, uint32 classId, address trainer, uint32 exp, uint32 createIndex, uint32 lastClaimIndex, uint createTime);
}

contract EtheremonEnum {
    enum ResultCode {
        SUCCESS,
        ERROR_CLASS_NOT_FOUND,
        ERROR_LOW_BALANCE,
        ERROR_SEND_FAIL,
        ERROR_NOT_TRAINER,
        ERROR_NOT_ENOUGH_MONEY,
        ERROR_INVALID_AMOUNT
    }

    enum ArrayType {
        CLASS_TYPE,
        STAT_STEP,
        STAT_START,
        STAT_BASE,
        OBJ_SKILL
    }

    enum PropertyType {
        ANCESTOR,
        XFACTOR
    }
}

interface EtheremonMonsterNFTInterface {
   function triggerTransferEvent(address _from, address _to, uint _tokenId) external;
   function getMonsterCP(uint64 _monsterId) constant external returns(uint cp);
}

contract EtheremonWorldNFT is BasicAccessControl {
    uint8 constant public STAT_COUNT = 6;
    uint8 constant public STAT_MAX = 32;

    struct MonsterClassAcc {
        uint32 classId;
        uint256 price;
        uint256 returnPrice;
        uint32 total;
        bool catchable;
    }

    struct MonsterObjAcc {
        uint64 monsterId;
        uint32 classId;
        address trainer;
        string name;
        uint32 exp;
        uint32 createIndex;
        uint32 lastClaimIndex;
        uint createTime;
    }

    address public dataContract;
    address public monsterNFT;

    mapping(uint32 => bool) public classWhitelist;
    mapping(address => bool) public addressWhitelist;

    uint public gapFactor = 5;
    uint public priceIncreasingRatio = 1000;

    function setContract(address _dataContract, address _monsterNFT) external onlyModerators {
        dataContract = _dataContract;
        monsterNFT = _monsterNFT;
    }

    function setConfig(uint _gapFactor, uint _priceIncreasingRatio) external onlyModerators {
        gapFactor = _gapFactor;
        priceIncreasingRatio = _priceIncreasingRatio;
    }

    function setClassWhitelist(uint32 _classId, bool _status) external onlyModerators {
        classWhitelist[_classId] = _status;
    }

    function setAddressWhitelist(address _smartcontract, bool _status) external onlyModerators {
        addressWhitelist[_smartcontract] = _status;
    }

    function mintMonster(uint32 _classId, address _trainer, string _name) external onlyModerators returns(uint) {
        EtheremonDataBase data = EtheremonDataBase(dataContract);
        // add monster
        uint64 objId = data.addMonsterObj(_classId, _trainer, _name);
        uint8 value;
        uint seed = getRandom(_trainer, block.number-1, objId);
        // generate base stat for the previous one
        for (uint i=0; i < STAT_COUNT; i += 1) {
            seed /= 100;
            value = uint8(seed % STAT_MAX) + data.getElementInArrayType(EtheremonEnum.ArrayType.STAT_START, uint64(_classId), i);
            data.addElementToArrayType(EtheremonEnum.ArrayType.STAT_BASE, objId, value);
        }

        EtheremonMonsterNFTInterface(monsterNFT).triggerTransferEvent(address(0), _trainer, objId);
        return objId;
    }

    function burnMonster(uint64 _tokenId) external onlyModerators {
        // need to check condition before calling this function
        EtheremonDataBase data = EtheremonDataBase(dataContract);
        MonsterObjAcc memory obj;
        (obj.monsterId, obj.classId, obj.trainer, obj.exp, obj.createIndex, obj.lastClaimIndex, obj.createTime) = data.getMonsterObj(_tokenId);
        require(obj.trainer != address(0));
        data.removeMonsterIdMapping(obj.trainer, _tokenId);
        EtheremonMonsterNFTInterface(monsterNFT).triggerTransferEvent(obj.trainer, address(0), _tokenId);
    }

    function catchMonsterNFT(uint32 _classId, string _name) external isActive payable {
        EtheremonDataBase data = EtheremonDataBase(dataContract);
        MonsterClassAcc memory class;
        (class.classId, class.price, class.returnPrice, class.total, class.catchable) = data.getMonsterClass(_classId);
        if (class.classId == 0 || class.catchable == false) {
            revert();
        }

        uint price = class.price;
        if (class.total > 0)
            price += class.price*(class.total-1)/priceIncreasingRatio;
        if (msg.value < price) {
            revert();
        }

        // add new monster
        uint64 objId = data.addMonsterObj(_classId, msg.sender, _name);
        uint8 value;
        uint seed = getRandom(msg.sender, block.number-1, objId);
        // generate base stat for the previous one
        for (uint i=0; i < STAT_COUNT; i += 1) {
            seed /= 100;
            value = uint8(seed % STAT_MAX) + data.getElementInArrayType(EtheremonEnum.ArrayType.STAT_START, uint64(_classId), i);
            data.addElementToArrayType(EtheremonEnum.ArrayType.STAT_BASE, objId, value);
        }

        EtheremonMonsterNFTInterface(monsterNFT).triggerTransferEvent(address(0), msg.sender, objId);
        // refund extra
        if (msg.value > price) {
            msg.sender.transfer((msg.value - price));
        }
    }

    // for whitelist contracts, no refund extra
    function catchMonster(address _player, uint32 _classId, string _name) external isActive payable returns(uint tokenId) {
        if (addressWhitelist[msg.sender] == false) {
            revert();
        }

        EtheremonDataBase data = EtheremonDataBase(dataContract);
        MonsterClassAcc memory class;
        (class.classId, class.price, class.returnPrice, class.total, class.catchable) = data.getMonsterClass(_classId);
        if (class.classId == 0) {
            revert();
        }

        if (class.catchable == false && classWhitelist[_classId] == false) {
            revert();
        }

        uint price = class.price;
        if (class.total > gapFactor) {
            price += class.price*(class.total - gapFactor)/priceIncreasingRatio;
        }
        if (msg.value < price) {
            revert();
        }

        // add new monster
        uint64 objId = data.addMonsterObj(_classId, _player, _name);
        uint8 value;
        uint seed = getRandom(_player, block.number-1, objId);
        // generate base stat for the previous one
        for (uint i=0; i < STAT_COUNT; i += 1) {
            seed /= 100;
            value = uint8(seed % STAT_MAX) + data.getElementInArrayType(EtheremonEnum.ArrayType.STAT_START, uint64(_classId), i);
            data.addElementToArrayType(EtheremonEnum.ArrayType.STAT_BASE, objId, value);
        }

        EtheremonMonsterNFTInterface(monsterNFT).triggerTransferEvent(address(0), _player, objId);
        return objId;
    }

    function getMonsterClassBasic(uint32 _classId) external constant returns(uint256, uint256, uint256, bool) {
        EtheremonDataBase data = EtheremonDataBase(dataContract);
        MonsterClassAcc memory class;
        (class.classId, class.price, class.returnPrice, class.total, class.catchable) = data.getMonsterClass(_classId);
        return (class.price, class.returnPrice, class.total, class.catchable);
    }

    function getPrice(uint32 _classId) external constant returns(bool catchable, uint price) {
        EtheremonDataBase data = EtheremonDataBase(dataContract);
        MonsterClassAcc memory class;
        (class.classId, class.price, class.returnPrice, class.total, class.catchable) = data.getMonsterClass(_classId);

        price = class.price;
        if (class.total > 0)
            price += class.price*(class.total-1)/priceIncreasingRatio;

        if (class.catchable == false) {
            return (classWhitelist[_classId], price);
        } else {
            return (true, price);
        }
    }

    // public api
    function getRandom(address _player, uint _block, uint _count) public view returns(uint) {
        return uint(keccak256(abi.encodePacked(blockhash(_block), _player, _count)));
    }

    function withdrawEther(address _sendTo, uint _amount) public onlyOwner {
        if (_amount > address(this).balance) {
            revert();
        }
        _sendTo.transfer(_amount);
    }
}

interface KyberNetworkProxyInterface {
    function maxGasPrice() public view returns(uint);
    function getUserCapInWei(address user) public view returns(uint);
    function getUserCapInTokenWei(address user, ERC20 token) public view returns(uint);
    function enabled() public view returns(bool);
    function info(bytes32 id) public view returns(uint);

    function getExpectedRate(ERC20 src, ERC20 dest, uint srcQty) public view
        returns (uint expectedRate, uint slippageRate);

    function tradeWithHint(ERC20 src, uint srcAmount, ERC20 dest, address destAddress, uint maxDestAmount,
        uint minConversionRate, address walletId, bytes hint) public payable returns(uint);
}

contract Utils {

    ERC20 constant internal ETH_TOKEN_ADDRESS = ERC20(0x00eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee);
    uint  constant internal PRECISION = (10**18);
    uint  constant internal MAX_QTY   = (10**28); // 10B tokens
    uint  constant internal MAX_RATE  = (PRECISION * 10**6); // up to 1M tokens per ETH
    uint  constant internal MAX_DECIMALS = 18;
    uint  constant internal ETH_DECIMALS = 18;
    mapping(address=>uint) internal decimals;

    function setDecimals(ERC20 token) internal {
        if (token == ETH_TOKEN_ADDRESS) decimals[token] = ETH_DECIMALS;
        else decimals[token] = token.decimals();
    }

    function getDecimals(ERC20 token) internal view returns(uint) {
        if (token == ETH_TOKEN_ADDRESS) return ETH_DECIMALS; // save storage access
        uint tokenDecimals = decimals[token];
        // technically, there might be token with decimals 0
        // moreover, very possible that old tokens have decimals 0
        // these tokens will just have higher gas fees.
        if(tokenDecimals == 0) return token.decimals();

        return tokenDecimals;
    }

    function calcDstQty(uint srcQty, uint srcDecimals, uint dstDecimals, uint rate) internal pure returns(uint) {
        require(srcQty <= MAX_QTY);
        require(rate <= MAX_RATE);

        if (dstDecimals >= srcDecimals) {
            require((dstDecimals - srcDecimals) <= MAX_DECIMALS);
            return (srcQty * rate * (10**(dstDecimals - srcDecimals))) / PRECISION;
        } else {
            require((srcDecimals - dstDecimals) <= MAX_DECIMALS);
            return (srcQty * rate) / (PRECISION * (10**(srcDecimals - dstDecimals)));
        }
    }

    function calcSrcQty(uint dstQty, uint srcDecimals, uint dstDecimals, uint rate) internal pure returns(uint) {
        require(dstQty <= MAX_QTY);
        require(rate <= MAX_RATE);
        
        //source quantity is rounded up. to avoid dest quantity being too low.
        uint numerator;
        uint denominator;
        if (srcDecimals >= dstDecimals) {
            require((srcDecimals - dstDecimals) <= MAX_DECIMALS);
            numerator = (PRECISION * dstQty * (10**(srcDecimals - dstDecimals)));
            denominator = rate;
        } else {
            require((dstDecimals - srcDecimals) <= MAX_DECIMALS);
            numerator = (PRECISION * dstQty);
            denominator = (rate * (10**(dstDecimals - srcDecimals)));
        }
        return (numerator + denominator - 1) / denominator; //avoid rounding down errors
    }
}

contract Utils2 is Utils {

    /// @dev get the balance of a user.
    /// @param token The token type
    /// @return The balance
    function getBalance(ERC20 token, address user) public view returns(uint) {
        if (token == ETH_TOKEN_ADDRESS)
            return user.balance;
        else
            return token.balanceOf(user);
    }

    function getDecimalsSafe(ERC20 token) internal returns(uint) {

        if (decimals[token] == 0) {
            setDecimals(token);
        }

        return decimals[token];
    }

    function calcDestAmount(ERC20 src, ERC20 dest, uint srcAmount, uint rate) internal view returns(uint) {
        return calcDstQty(srcAmount, getDecimals(src), getDecimals(dest), rate);
    }

    function calcSrcAmount(ERC20 src, ERC20 dest, uint destAmount, uint rate) internal view returns(uint) {
        return calcSrcQty(destAmount, getDecimals(src), getDecimals(dest), rate);
    }

    function calcRateFromQty(uint srcAmount, uint destAmount, uint srcDecimals, uint dstDecimals)
        internal pure returns(uint)
    {
        require(srcAmount <= MAX_QTY);
        require(destAmount <= MAX_QTY);

        if (dstDecimals >= srcDecimals) {
            require((dstDecimals - srcDecimals) <= MAX_DECIMALS);
            return (destAmount * PRECISION / ((10 ** (dstDecimals - srcDecimals)) * srcAmount));
        } else {
            require((srcDecimals - dstDecimals) <= MAX_DECIMALS);
            return (destAmount * PRECISION * (10 ** (srcDecimals - dstDecimals)) / srcAmount);
        }
    }
}

interface WrapEtheremonInterface {
    /// @notice Can only be called by operators
    /// @dev Sets the KyberNetwork address
    /// @param _KyberNetwork KyberNetwork contract address
    function setKyberNetwork(address _KyberNetwork) public;

    /// @dev Get the ETH price of the Etheremon monster and if it is catchable
    /// @param _etheremon EtheremonWorldNFT address
    /// @param _classId Class ID of monster
    /// @param _payPrice Price of monster passed from Etheremon server
    /// @return catchable, monsterInETH
    function getMonsterPriceInETH(
        EtheremonWorldNFT _etheremon,
        uint32 _classId,
        uint _payPrice
    )
        public
        view
        returns (
            bool catchable,
            uint monsterInETH
        );

    /// @dev Get the rates of the Etheremon monster
    /// @param _kyberProxy KyberNetworkProxyInterface address
    /// @param token ERC20 token address
    /// @param monsterInETH Price of the monster in ETH
    /// @return expectedRate, slippageRate
    function getMonsterRates(
        KyberNetworkProxyInterface _kyberProxy,
        ERC20 token,
        uint monsterInETH
    )
        public
        view
        returns (
            uint expectedRate,
            uint slippageRate
        );

    /// @dev Get the token price and rates of the Etheremon monster
    /// @param token ERC20 token address
    /// @param expectedRate Expected rate of ETH to token
    /// @param monsterInETH Price of the monster in ETH
    /// @return monsterInTokens
    function getMonsterPriceInTokens(
        ERC20 token,
        uint expectedRate,
        uint monsterInETH
    )
        public
        view
        returns (uint monsterInTokens);

    /// @dev Acquires the monster from Etheremon using tokens
    /// @param _kyberProxy KyberNetworkProxyInterface address
    /// @param _etheremon EtheremonWorldNFT address
    /// @param _classId Class ID of monster
    /// @param _name Name of the monster
    /// @param token ERC20 token address
    /// @param tokenQty Amount of tokens to be transferred by user
    /// @param maxDestQty Actual amount of ETH needed to purchase the monster
    /// @param minRate The minimum rate or slippage rate.
    /// @param walletId Wallet ID where Kyber referral fees will be sent to
    /// @return monsterId
    function catchMonster(
        KyberNetworkProxyInterface _kyberProxy,
        EtheremonWorldNFT _etheremon,
        uint32 _classId,
        string _name,
        ERC20 token,
        uint tokenQty,
        uint maxDestQty,
        uint minRate,
        address walletId
    )
        public
        returns (uint monsterId);
}

contract WrapEtheremonPermissions {
    event TransferAdmin(address newAdmin);
    event OperatorAdded(address newOperator, bool isAdd);

    address public admin;
    address[] public operatorsGroup;
    mapping(address=>bool) internal operators;
    uint constant internal MAX_GROUP_SIZE = 50;

    constructor () public {
        admin = msg.sender;
    }

    modifier onlyAdmin() {
        require(msg.sender == admin);
        _;
    }

    modifier onlyOperator() {
        require(operators[msg.sender]);
        _;
    }

    function transferAdmin(address newAdmin) public onlyAdmin {
        require(newAdmin != address(0));
        emit TransferAdmin(newAdmin);
        admin = newAdmin;
    }

    function addOperator(address newOperator) public onlyAdmin {
        require(!operators[newOperator]);
        require(operatorsGroup.length < MAX_GROUP_SIZE);

        emit OperatorAdded(newOperator, true);
        operators[newOperator] = true;
        operatorsGroup.push(newOperator);
    }

    function removeOperator (address operator) public onlyAdmin {
        require(operators[operator]);
        operators[operator] = false;

        for (uint i = 0; i < operatorsGroup.length; ++i) {
            if (operatorsGroup[i] == operator) {
                operatorsGroup[i] = operatorsGroup[operatorsGroup.length - 1];
                operatorsGroup.length -= 1;
                emit OperatorAdded(operator, false);
                break;
            }
        }
    }
}

contract WrapEtheremon is WrapEtheremonInterface, WrapEtheremonPermissions, Utils2 {
    event SwapTokenChange(uint startTokenBalance, uint change);
    event CaughtWithToken(address indexed sender, uint monsterId, ERC20 token, uint amount);
    event ETHReceived(address indexed sender, uint amount);

    address public KyberNetwork;
    ERC20 constant internal ETH_TOKEN_ADDRESS = ERC20(0x00eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee);

    /// @dev Contract contstructor
    /// @param _KyberNetwork KyberNetwork main contract address
    constructor (address _KyberNetwork) public {
        KyberNetwork = _KyberNetwork;
    }

    /// @dev Return the ETH to user that was taken back by the network
    function() public payable {
        // Only receive ETH from KyberNetwork main contract
        require(msg.sender == KyberNetwork);
        emit ETHReceived(msg.sender, msg.value);
    }

    /// @notice Can only be called by operators
    /// @dev Sets the KyberNetwork address
    /// @param _KyberNetwork KyberNetwork contract address
    function setKyberNetwork(address _KyberNetwork) public onlyOperator {
      KyberNetwork = _KyberNetwork;
    }

    /// @dev Get the ETH price of the Etheremon monster and if it is catchable
    /// @param _etheremon EtheremonWorldNFT address
    /// @param _classId Class ID of monster
    /// @param _payPrice Price of monster passed from Etheremon server
    /// @return catchable, monsterInETH
    function getMonsterPriceInETH(
        EtheremonWorldNFT _etheremon,
        uint32 _classId,
        uint _payPrice
    )
        public
        view
        returns (
            bool catchable,
            uint monsterInETH
        )
    {
        // Get monster details from Etheremon contract
        (catchable, monsterInETH) = _etheremon.getPrice(_classId);

        // Get the highest price from contract pricing or offchain pricing
        monsterInETH = max(monsterInETH, _payPrice);

        return (catchable, monsterInETH);
    }

    /// @dev Get the rates of the Etheremon monster
    /// @param _kyberProxy KyberNetworkProxyInterface address
    /// @param token ERC20 token address
    /// @param monsterInETH Price of the monster in ETH
    /// @return expectedRate, slippageRate
    function getMonsterRates(
        KyberNetworkProxyInterface _kyberProxy,
        ERC20 token,
        uint monsterInETH
    )
        public
        view
        returns (
            uint expectedRate,
            uint slippageRate
        )
    {
        // Get the expected and slippage rates of the token to ETH
        (expectedRate, slippageRate) = _kyberProxy.getExpectedRate(token, ETH_TOKEN_ADDRESS, monsterInETH);

        return (expectedRate, slippageRate);
    }

    /// @dev Get the token price and rates of the Etheremon monster
    /// @param token ERC20 token address
    /// @param expectedRate Expected rate of ETH to token
    /// @param monsterInETH Price of the monster in ETH
    /// @return monsterInTokens
    function getMonsterPriceInTokens(
        ERC20 token,
        uint expectedRate,
        uint monsterInETH
    )
        public
        view
        returns (uint monsterInTokens)
    {
        // If expectedRate is 0, return 0 for monster price in tokens
        if (expectedRate == 0) {
            return 0;
        }

        // Calculate monster price in tokens
        monsterInTokens = calcSrcAmount(ETH_TOKEN_ADDRESS, token, monsterInETH, expectedRate);

        return monsterInTokens;
    }

    /// @dev Acquires the monster from Etheremon using tokens
    /// @param _kyberProxy KyberNetworkProxyInterface address
    /// @param _etheremon EtheremonWorldNFT address
    /// @param _classId Class ID of monster
    /// @param _name Name of the monster
    /// @param token ERC20 token address
    /// @param tokenQty Amount of tokens to be transferred by user
    /// @param maxDestQty Actual amount of ETH needed to purchase the monster
    /// @param minRate The minimum rate or slippage rate.
    /// @param walletId Wallet ID where Kyber referral fees will be sent to
    /// @return monsterId
    function catchMonster(
        KyberNetworkProxyInterface _kyberProxy,
        EtheremonWorldNFT _etheremon,
        uint32 _classId,
        string _name,
        ERC20 token,
        uint tokenQty,
        uint maxDestQty,
        uint minRate,
        address walletId
    )
        public
        returns (uint monsterId)
    {
        // Check that the player has transferred the token to this contract
        require(token.transferFrom(msg.sender, this, tokenQty));

        // Get the starting token balance of the player's wallet
        uint startTokenBalance = token.balanceOf(this);

        // Mitigate ERC20 Approve front-running attack, by initially setting
        // allowance to 0
        require(token.approve(_kyberProxy, 0));

        // Verify that the token balance has not decreased from front-running
        require(token.balanceOf(this) == startTokenBalance);

        // Once verified, set the token allowance to tokenQty
        require(token.approve(_kyberProxy, tokenQty));

        // Swap player's token to ETH to send to Etheremon payments contract
        uint userETH = _kyberProxy.tradeWithHint(
            token,
            tokenQty,
            ETH_TOKEN_ADDRESS,
            address(this),
            maxDestQty,
            minRate,
            walletId,
            ""
        );

        // Acquire the monster and send to player
        monsterId = _etheremon.catchMonster.value(userETH)(msg.sender, _classId, _name);

        // Log event that monster was caught using tokens
        emit CaughtWithToken(msg.sender, monsterId, token, tokenQty);

        // Return change to player if any
        calcPlayerChange(token, startTokenBalance);

        return monsterId;
    }

    /// @dev Calculates token change and returns to player
    /// @param token ERC20 token address
    /// @param startTokenBalance Starting token balance of the player's wallet
    function calcPlayerChange(ERC20 token, uint startTokenBalance) private {
        // Calculate change of player
        uint change = token.balanceOf(this);

        // Send back change if change is > 0
        if (change > 0) {
            // Log the exchange event
            emit SwapTokenChange(startTokenBalance, change);

            // Transfer change back to player
            token.transfer(msg.sender, change);
        }
    }

    /// @dev Gets the max between two uint params
    /// @param a Param A
    /// @param b Param B
    /// @return result
    function max(uint a, uint b) private pure returns (uint result) {
        return a > b ? a : b;
    }
}