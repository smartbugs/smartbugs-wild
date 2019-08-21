pragma solidity 0.4.18;

// File: contracts/ERC20Interface.sol

// https://github.com/ethereum/EIPs/issues/20
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

// File: contracts/KyberReserveInterface.sol

/// @title Kyber Reserve contract
interface KyberReserveInterface {

    function trade(
        ERC20 srcToken,
        uint srcAmount,
        ERC20 destToken,
        address destAddress,
        uint conversionRate,
        bool validate
    )
        public
        payable
        returns(bool);

    function getConversionRate(ERC20 src, ERC20 dest, uint srcQty, uint blockNumber) public view returns(uint);
}

// File: contracts/Utils.sol

/// @title Kyber constants contract
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

// File: contracts/Utils2.sol

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

// File: contracts/PermissionGroups.sol

contract PermissionGroups {

    address public admin;
    address public pendingAdmin;
    mapping(address=>bool) internal operators;
    mapping(address=>bool) internal alerters;
    address[] internal operatorsGroup;
    address[] internal alertersGroup;
    uint constant internal MAX_GROUP_SIZE = 50;

    function PermissionGroups() public {
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

    modifier onlyAlerter() {
        require(alerters[msg.sender]);
        _;
    }

    function getOperators () external view returns(address[]) {
        return operatorsGroup;
    }

    function getAlerters () external view returns(address[]) {
        return alertersGroup;
    }

    event TransferAdminPending(address pendingAdmin);

    /**
     * @dev Allows the current admin to set the pendingAdmin address.
     * @param newAdmin The address to transfer ownership to.
     */
    function transferAdmin(address newAdmin) public onlyAdmin {
        require(newAdmin != address(0));
        TransferAdminPending(pendingAdmin);
        pendingAdmin = newAdmin;
    }

    /**
     * @dev Allows the current admin to set the admin in one tx. Useful initial deployment.
     * @param newAdmin The address to transfer ownership to.
     */
    function transferAdminQuickly(address newAdmin) public onlyAdmin {
        require(newAdmin != address(0));
        TransferAdminPending(newAdmin);
        AdminClaimed(newAdmin, admin);
        admin = newAdmin;
    }

    event AdminClaimed( address newAdmin, address previousAdmin);

    /**
     * @dev Allows the pendingAdmin address to finalize the change admin process.
     */
    function claimAdmin() public {
        require(pendingAdmin == msg.sender);
        AdminClaimed(pendingAdmin, admin);
        admin = pendingAdmin;
        pendingAdmin = address(0);
    }

    event AlerterAdded (address newAlerter, bool isAdd);

    function addAlerter(address newAlerter) public onlyAdmin {
        require(!alerters[newAlerter]); // prevent duplicates.
        require(alertersGroup.length < MAX_GROUP_SIZE);

        AlerterAdded(newAlerter, true);
        alerters[newAlerter] = true;
        alertersGroup.push(newAlerter);
    }

    function removeAlerter (address alerter) public onlyAdmin {
        require(alerters[alerter]);
        alerters[alerter] = false;

        for (uint i = 0; i < alertersGroup.length; ++i) {
            if (alertersGroup[i] == alerter) {
                alertersGroup[i] = alertersGroup[alertersGroup.length - 1];
                alertersGroup.length--;
                AlerterAdded(alerter, false);
                break;
            }
        }
    }

    event OperatorAdded(address newOperator, bool isAdd);

    function addOperator(address newOperator) public onlyAdmin {
        require(!operators[newOperator]); // prevent duplicates.
        require(operatorsGroup.length < MAX_GROUP_SIZE);

        OperatorAdded(newOperator, true);
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
                OperatorAdded(operator, false);
                break;
            }
        }
    }
}

// File: contracts/Withdrawable.sol

/**
 * @title Contracts that should be able to recover tokens or ethers
 * @author Ilan Doron
 * @dev This allows to recover any tokens or Ethers received in a contract.
 * This will prevent any accidental loss of tokens.
 */
contract Withdrawable is PermissionGroups {

    event TokenWithdraw(ERC20 token, uint amount, address sendTo);

    /**
     * @dev Withdraw all ERC20 compatible tokens
     * @param token ERC20 The address of the token contract
     */
    function withdrawToken(ERC20 token, uint amount, address sendTo) external onlyAdmin {
        require(token.transfer(sendTo, amount));
        TokenWithdraw(token, amount, sendTo);
    }

    event EtherWithdraw(uint amount, address sendTo);

    /**
     * @dev Withdraw Ethers
     */
    function withdrawEther(uint amount, address sendTo) external onlyAdmin {
        sendTo.transfer(amount);
        EtherWithdraw(amount, sendTo);
    }
}

// File: contracts/dutchX/KyberDutchXReserve.sol

interface WETH9 {
    function approve(address spender, uint amount) public returns(bool);
    function withdraw(uint amount) public;
    function deposit() public payable;
}


interface DutchXExchange {
    // Two functions below are in fact: mapping (address => mapping (address => uint)) public sellVolumesCurrent;
    // Token => Token => amount
    function buyVolumes(address sellToken, address buyToken) public view returns (uint);
    function sellVolumesCurrent(address sellToken, address buyToken) public view returns (uint);
    function deposit(address tokenAddress,uint amount) public returns(uint);
    function postBuyOrder(address sellToken,address buyToken,uint auctionIndex,uint amount) public returns (uint);

    function claimBuyerFunds(address sellToken, address buyToken, address user, uint auctionIndex) public
        returns(uint returned, uint frtsIssued);

    function withdraw(address tokenAddress,uint amount) public returns (uint);
    function getAuctionIndex(address sellToken, address buyToken) public view returns(uint index);
    function getFeeRatio(address user) public view returns (uint num, uint den); // feeRatio < 10^4

    function getCurrentAuctionPrice(address sellToken, address buyToken, uint auctionIndex) public view
        returns (uint num, uint den);
}


contract KyberDutchXReserve is KyberReserveInterface, Withdrawable, Utils2 {

    uint public constant BPS = 10000;
    uint public constant DEFAULT_KYBER_FEE_BPS = 25;

    uint public feeBps = DEFAULT_KYBER_FEE_BPS;
    uint public dutchXFeeNum;
    uint public dutchXFeeDen;

    DutchXExchange public dutchX;
    address public kyberNetwork;
    WETH9 public weth;

    mapping(address => bool) public listedTokens;

    bool public tradeEnabled;

    /**
        Constructor
    */
    function KyberDutchXReserve(
        DutchXExchange _dutchX,
        address _admin,
        address _kyberNetwork,
        WETH9 _weth
    )
        public
    {
        require(address(_dutchX) != address(0));
        require(_admin != address(0));
        require(_kyberNetwork != address(0));
        require(_weth != WETH9(0));

        dutchX = _dutchX;
        admin = _admin;
        kyberNetwork = _kyberNetwork;
        weth = _weth;

        setDutchXFee();
        require(weth.approve(dutchX, 2 ** 255));
        setDecimals(ETH_TOKEN_ADDRESS);
    }

    function() public payable {
        // anyone can deposit ether
    }

    struct AuctionData {
        uint index;
        ERC20 srcToken;
        ERC20 dstToken;
        uint priceNum; // numerator
        uint priceDen; // denominator
    }

    /**
        Returns rate = dest quantity / source quantity.
    */
    function getConversionRate(
        ERC20 src,
        ERC20 dest,
        uint srcQty,
        uint blockNumber
    )
        public
        view
        returns(uint)
    {
        blockNumber;
        if (!tradeEnabled) return 0;

        if (src == ETH_TOKEN_ADDRESS) {
            if (!listedTokens[dest]) return 0;
        } else if (dest == ETH_TOKEN_ADDRESS) {
            if (!listedTokens[src]) return 0;
        } else {
            return 0;
        }

        AuctionData memory auctionData = getAuctionData(src, dest);
        if (auctionData.index == 0) return 0;

        (auctionData.priceNum, auctionData.priceDen) = dutchX.getCurrentAuctionPrice(
                auctionData.dstToken,
                auctionData.srcToken,
                auctionData.index
            );

        if (!sufficientLiquidity(auctionData.srcToken, srcQty, auctionData.dstToken,
            auctionData.priceNum, auctionData.priceDen)) {
            return 0;
        }

        // if source is Eth, reduce kyber fee from source.
        uint actualSrcQty = (src == ETH_TOKEN_ADDRESS) ? srcQty * (BPS - feeBps) / BPS : srcQty;
        require(actualSrcQty * auctionData.priceDen > actualSrcQty);
        uint convertedQty = (actualSrcQty * auctionData.priceDen) / auctionData.priceNum;
        // reduce dutchX fees
        convertedQty = convertedQty * (dutchXFeeDen - dutchXFeeNum) / dutchXFeeDen;

        // if destination is Eth, reduce kyber fee from destination.
        convertedQty = (dest == ETH_TOKEN_ADDRESS) ? convertedQty * (BPS - feeBps) / BPS : convertedQty;

        // here use original srcQty, which will give the real rate (as seen by internal kyberNetwork)
        return calcRateFromQty(
            srcQty, /* srcAmount */
            convertedQty, /* destAmount */
            getDecimals(src), /* srcDecimals */
            getDecimals(dest) /* dstDecimals */
        );
    }

    event TradeExecute(
        address indexed sender,
        address src,
        uint srcAmount,
        address destToken,
        uint destAmount,
        address destAddress,
        uint auctionIndex
    );

    function trade(
        ERC20 srcToken,
        uint srcAmount,
        ERC20 destToken,
        address destAddress,
        uint conversionRate,
        bool validate
    )
        public
        payable
        returns(bool)
    {
        validate;

        require(tradeEnabled);
        require(msg.sender == kyberNetwork);

        AuctionData memory auctionData = getAuctionData(srcToken, destToken);
        require(auctionData.index != 0);

        uint actualSrcQty;

        if (srcToken == ETH_TOKEN_ADDRESS){
            require(srcAmount == msg.value);
            actualSrcQty = srcAmount * (BPS - feeBps) / BPS;
            weth.deposit.value(actualSrcQty)();
        } else {
            require(msg.value == 0);
            require(srcToken.transferFrom(msg.sender, address(this), srcAmount));
            actualSrcQty = srcAmount;
        }

        dutchX.deposit(auctionData.srcToken, actualSrcQty);
        dutchX.postBuyOrder(auctionData.dstToken, auctionData.srcToken, auctionData.index, actualSrcQty);

        uint destAmount;
        uint frtsIssued;
        (destAmount, frtsIssued) = dutchX.claimBuyerFunds(
            auctionData.dstToken,
            auctionData.srcToken,
            this,
            auctionData.index
        );

        dutchX.withdraw(auctionData.dstToken, destAmount);

        if (destToken == ETH_TOKEN_ADDRESS) {
            weth.withdraw(destAmount);
            destAmount = destAmount * (BPS - feeBps) / BPS;
            destAddress.transfer(destAmount);
        } else {
            require(auctionData.dstToken.transfer(destAddress, destAmount));
        }

        require(conversionRate <= calcRateFromQty(
            srcAmount, /* srcAmount */
            destAmount, /* destAmount */
            getDecimals(srcToken), /* srcDecimals */
            getDecimals(destToken) /* dstDecimals */
        ));
        
        TradeExecute(
            msg.sender, /* sender */
            srcToken, /* src */
            srcAmount, /* srcAmount */
            destToken, /* destToken */
            destAmount, /* destAmount */
            destAddress, /* destAddress */
            auctionData.index
        );

        return true;
    }

    event FeeUpdated(
        uint bps
    );

    function setFee(uint bps) public onlyAdmin {
        require(bps <= BPS);
        feeBps = bps;
        FeeUpdated(bps);
    }

    event TokenListed(
        ERC20 token
    );

    function listToken(ERC20 token)
        public
        onlyAdmin
    {
        require(address(token) != address(0));

        listedTokens[token] = true;
        setDecimals(token);
        require(token.approve(dutchX, 2**255));
        TokenListed(token);
    }

    event TokenDelisted(ERC20 token);

    function delistToken(ERC20 token)
        public
        onlyAdmin
    {
        require(listedTokens[token]);
        listedTokens[token] = false;

        TokenDelisted(token);
    }

    event TradeEnabled(
        bool enable
    );

    function setDutchXFee() public {
        (dutchXFeeNum, dutchXFeeDen) = dutchX.getFeeRatio(this);

        // can't use denominator 0 (EVM bad instruction)
        if (dutchXFeeDen == 0) {
            tradeEnabled = false;
        }

        TradeEnabled(tradeEnabled);
    }

    function disableTrade()
        public
        onlyAlerter
        returns(bool)
    {
        tradeEnabled = false;
        TradeEnabled(tradeEnabled);
        return true;
    }

    function enableTrade()
        public
        onlyAdmin
        returns(bool)
    {
        tradeEnabled = true;
        TradeEnabled(tradeEnabled);
        return true;
    }

    event KyberNetworkSet(
        address kyberNetwork
    );

    function setKyberNetwork(
        address _kyberNetwork
    )
        public
        onlyAdmin
    {
        require(_kyberNetwork != address(0));
        kyberNetwork = _kyberNetwork;
        KyberNetworkSet(kyberNetwork);
    }

    event Execution(bool success, address caller, address destination, uint value, bytes data);

    function executeTransaction(address destination, uint value, bytes data)
        public
        onlyOperator
    {
        if (destination.call.value(value)(data)) {
            Execution(true, msg.sender, destination, value, data);
        } else {
            revert();
        }
    }

    function sufficientLiquidity(ERC20 src, uint srcQty, ERC20 dest, uint priceNum, uint priceDen)
        internal view returns(bool)
    {
        uint buyVolume = dutchX.buyVolumes(dest, src);
        uint sellVolume = dutchX.sellVolumesCurrent(dest, src);

        // 10^30 * 10^37 = 10^67
        require(sellVolume * priceNum > sellVolume);
        uint outstandingVolume = (sellVolume * priceNum) / priceDen - buyVolume;

        if (outstandingVolume >= srcQty) return true;

        return false;
    }

    function getAuctionData(ERC20 src, ERC20 dst) internal view returns (AuctionData data) {
        data.srcToken = src == ETH_TOKEN_ADDRESS ? ERC20(weth) : src;
        data.dstToken = dst == ETH_TOKEN_ADDRESS ? ERC20(weth) : dst;
        data.index = dutchX.getAuctionIndex(data.dstToken, data.srcToken);
    }
}