pragma solidity ^0.4.25;

 /*
  * @title: SafeMath
  * @dev: Helper contract functions to arithmatic operations safely.
  */
contract SafeMath {
  function Sub(uint128 a, uint128 b) pure public returns (uint128) {
    assert(b <= a);
    return a - b;
  }

  function Add(uint128 a, uint128 b) pure public returns (uint128) {
    uint128 c = a + b;
    assert(c>=a && c>=b);
    return c;
  }
}

 /*
  * @title: Token
  * @dev: Interface contract for ERC20 tokens
  */
contract Token {
  function totalSupply() public view returns (uint256 supply);
  function balanceOf(address _owner) public view returns (uint256 balance);
  function transfer(address _to, uint256 _value) public returns (bool success);
  function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);
  function approve(address _spender, uint256 _value) public returns (bool success);
  function allowance(address _owner, address _spender) public view returns (uint256 remaining);
  event Transfer(address indexed _from, address indexed _to, uint256 _value);
  event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}

 /*
  * @title: Dex
  * @author Dexhigh Services Pvt. Ltd (https://www.dexhigh.com)
  * @dev The Dex Contract implement all the required functionalities viz order sharing, local exchange etc.
  */
contract DEX is SafeMath
{
    uint32 public lastTransferId = 1;

    // Events
    event NewDeposit(uint32 indexed exId, uint32  prCode, uint32 indexed accountId, uint128 amount, uint64 timestamp, uint32 lastTransferId);
    event NewWithdraw(uint32 indexed exId, uint32  prCode, uint32 indexed accountId, uint128 amount, uint64 timestamp, uint32 lastTransferId);
    uint32 public lastNewOrderId = 1;
    event NewOrder(uint32 indexed prTrade, uint32 indexed prBase, uint32 indexed accountId, uint32 id, bool isSell, uint80 price, uint104 qty, uint32 lastNewOrderId);
    event NewCancel(uint32 indexed prTrade, uint32 indexed prBase, uint32 indexed accountId, uint32 id, bool isSell, uint80 price, uint104 qt, uint32 lastNewOrderId);
    event NewBestBidAsk(uint32 indexed prTrade, uint32 indexed prBase, bool isBid, uint80 price);
    uint32 public lastTradeId = 1;
    event NewTrade(uint32 indexed prTrade, uint32 prBase, uint32 indexed bidId, uint32 indexed askId, uint32 accountIdBid, uint32 accountIdAsk, bool isSell, uint80 price, uint104 qty, uint32 lastTradeId, uint64 timestamp);

    // basePrice, All the prices will be "based" by basePrice
    uint256 public constant basePrice = 10000000000;
    uint80 public constant maxPrice = 10000000000000000000001;
    uint104 public constant maxQty = 1000000000000000000000000000001;
    uint128 public constant maxBalance = 1000000000000000000000000000000000001;
    bool public isContractUse = true;

    //No Args constructor will add msg.sender as owner/operator
    // Add ETH product
    constructor() public
    {
        owner = msg.sender;
        operator = owner;
        AddOwner(msg.sender);
        AddProduct(18, 0x0);
        //lastProductId = 1; // productId == 1 -> ETH 0x0
    }

    address public owner;
    // Functions with this modifier can only be executed by the owner
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    address public operator;
    // Functions with this modifier can only be executed by the operator
    modifier onlyOperator() {
        require(msg.sender == operator);
        _;
    }
    function transferOperator(address _operator) onlyOwner public {
        operator = _operator;
    }

    // Functions with this modifier can only be executed by the owner of each exchange
    modifier onlyExOwner()  {
        require(owner_id[msg.sender] != 0);
        _;
    }

    // Functions with this modifier can only be executed when this contract is not abandoned
    modifier onlyContractUse {
        require(isContractUse == true);
        _;
    }

    uint32 public lastOwnerId;
    mapping (uint32 => address) id_owner;
    mapping (address => uint32) owner_id;
    mapping (uint32 => uint8) ownerId_takerFeeRateLocal;
    mapping (uint32 => uint32) ownerId_accountId;

    //Delete the owner of exchange
    function DeleteOwner(uint32 exId) onlyOperator public
    {
        require(lastOwnerId >= exId && exId > 0);
        owner_id[id_owner[exId]] = 0;
    }

    //Add Owner of exchange
    function AddOwner(address newOwner) onlyOperator public
    {
        require(owner_id[newOwner] == 0);

        owner_id[newOwner] = ++lastOwnerId;
        id_owner[lastOwnerId] = newOwner;

        ownerId_accountId[lastOwnerId] = FindOrAddAccount();
    }
    //Get exchange owner list and id
    function GetOwnerList() view public returns (address[] owners, uint32[] ownerIds)
    {
        owners = new address[](lastOwnerId);
        ownerIds = new uint32[](lastOwnerId);

        for (uint32 i = 1; i <= lastOwnerId; i++)
        {
            owners[i - 1] = id_owner[i];
            ownerIds[i - 1] = i;
        }
    }
    //Set local exchange fee
    function setTakerFeeRateLocal(uint8 _takerFeeRate) public
    {
        require (_takerFeeRate <= 100);// takerFeeRate cannot be more than 1%
        uint32 ownerId = owner_id[msg.sender];
        require(ownerId != 0);
        ownerId_takerFeeRateLocal[ownerId] = _takerFeeRate;//bp
    }
    // Get fee Rate for an exchange with owner id == ownerId
    function getTakerFeeRateLocal(uint32 ownerId) public view returns (uint8)
    {
        return ownerId_takerFeeRateLocal[ownerId];//bp
    }

    //Air Drop events
    function airDrop(uint32 exId, uint32 prCode, uint32[] accountIds, uint104[] qtys) onlyExOwner public
    {
        uint32 accountId = FindOrRevertAccount();
        require(accountId_freeze[accountId] == false);
        uint256 n = accountIds.length;
        require(n == qtys.length);

        uint128 sum = 0;
        for (uint32 i = 0; i < n; i++)
        {
            sum += qtys[i];
        }

        exId_prCode_AccountId_Balance[exId][prCode][accountId].available = Sub(exId_prCode_AccountId_Balance[exId][prCode][accountId].available, sum);

        for (i = 0; i < n; i++)
        {
            exId_prCode_AccountId_Balance[exId][prCode][accountIds[i]].available += qtys[i];
            // exId_prCode_AccountId_Balance[exId][prCode][accountIds[i]].available >> qtys[i]
            // 2^128 >> 2^104 -> minimum 2^24 times of airdrop need for overflow (hard to imagine)
            // because prCode_AccountId_Balance[prCode][accountIds[i]].available restircted by maxBalance in deposit function
        }
    }

    //information of product
    struct ProductInfo
    {
        uint256 divider;
        bool isTradeBid;
        bool isTradeAsk;
        bool isDeposit;
        bool isWithdraw;
        uint32 ownerId;
        uint104 minQty;
    }

    uint32 public lastProductId;
    uint256 public newProductFee;
    mapping (uint32 => address) prCode_product;
    mapping (address => uint32) product_prCode;
    mapping (uint32 => ProductInfo) prCode_productInfo;

    // Add product by exchange owner
    function AddProduct(uint256 decimals, address product) payable onlyExOwner public
    {
        require(msg.value >= newProductFee || msg.sender == operator);
        require(product_prCode[product] == 0);
        require(decimals <= 18);

        product_prCode[product] = ++lastProductId;
        prCode_product[lastProductId] = product;

        ProductInfo memory productInfo;
        productInfo.divider = 10 ** decimals; // max = 10 ^ 18 because of require(decimals <= 18);
        productInfo.ownerId = owner_id[msg.sender];
        prCode_productInfo[lastProductId] = productInfo;

        exId_prCode_AccountId_Balance[1][1][ownerId_accountId[1]].available += uint128(msg.value); //eth transfer < 2^128
    }
    // Set Product Information
    function SetProductInfo(uint32 prCode, bool isTradeBid, bool isTradeAsk, bool isDeposit, bool isWithdraw, uint104 _minQty, uint32 exId) public
    {
        ProductInfo storage prInfo = prCode_productInfo[prCode];

        require(msg.sender == operator || owner_id[msg.sender] == prInfo.ownerId );

        prInfo.isTradeBid = isTradeBid;
        prInfo.isTradeAsk = isTradeAsk;
        prInfo.isDeposit = isDeposit;
        prInfo.isWithdraw = isWithdraw;
        prInfo.minQty = _minQty;
        prInfo.ownerId = exId;
    }
    // Set product listing fee
    function SetProductFee(uint256 productFee) onlyOperator public
    {
        newProductFee = productFee;
    }
    // Get product address and id
    function GetProductList() view public returns (address[] products, uint32[] productIds)
    {
        products = new address[](lastProductId);
        productIds = new uint32[](lastProductId);

        for (uint32 i = 1; i <= lastProductId; i++)
        {
            products[i - 1] = prCode_product[i];
            productIds[i - 1] = i;
        }
    }
    // Get infromation of product
    function GetProductInfo(address product) view public returns (uint32 prCode, uint256 divider, bool isTradeBid, bool isTradeAsk, bool isDeposit, bool isWithdraw, uint32 ownerId, uint104 minQty)
    {
        prCode = product_prCode[product];

        divider = prCode_productInfo[prCode].divider;
        isTradeBid = prCode_productInfo[prCode].isTradeBid;
        isTradeAsk = prCode_productInfo[prCode].isTradeAsk;
        isDeposit = prCode_productInfo[prCode].isDeposit;
        isWithdraw = prCode_productInfo[prCode].isWithdraw;
        ownerId = prCode_productInfo[prCode].ownerId;
        minQty = prCode_productInfo[prCode].minQty;
    }

    uint32 public lastAcccountId;
    mapping (uint32 => uint8) id_announceLV;
    //Each announceLV open information as
    //0: None, 1: Trade, 2:Balance, 3:DepositWithdrawal, 4:OpenOrder
    mapping (uint32 => address) id_account;
    mapping (uint32 => bool) accountId_freeze;
    mapping (address => uint32) account_id;
    // Find or add account
    function FindOrAddAccount() private returns (uint32)
    {
        if (account_id[msg.sender] == 0)
        {
            account_id[msg.sender] = ++lastAcccountId;
            id_account[lastAcccountId] = msg.sender;
        }
        return account_id[msg.sender];
    }
    // Find or revert account
    function FindOrRevertAccount() private view returns (uint32)
    {
        uint32 accountId = account_id[msg.sender];
        require(accountId != 0);
        return accountId;
    }
    // Get account id of msg sender
    function GetMyAccountId() view public returns (uint32)
    {
        return account_id[msg.sender];
    }
    // Get account id of any users
    function GetAccountId(address account) view public returns (uint32)
    {
        return account_id[account];
    }
    // Get account announcement level
    function GetMyAnnounceLV() view public returns (uint32)
    {
        return id_announceLV[account_id[msg.sender]];
    }
    // Set account announce level
    function ChangeAnnounceLV(uint8 announceLV) public
    {
        id_announceLV[FindOrRevertAccount()] = announceLV;
    }
    // Freeze or unfreez of account
    function SetFreezeByAddress(bool isFreeze, address account) onlyOperator public
    {
        uint32 accountId = account_id[account];

        if (accountId != 0)
        {
            accountId_freeze[accountId] = isFreeze;
        }
    }

    // reserved: Balance held up in orderBook
    // available: Balance available for trade
    struct Balance
    {
        uint128 reserved;
        uint128 available;
    }

    struct ListItem
    {
        uint32 prev;
        uint32 next;
    }

    struct OrderLink
    {
        uint32 firstId;
        uint32 lastId;
        uint80 nextPrice;
        uint80 prevPrice;
        mapping (uint32 => ListItem) id_orderList;
    }

    struct Order
    {
        uint32 exId;
        uint32 accountId;
        uint32 prTrade;
        uint32 prBase;
        uint104 qty;
        uint80 price;
        bool isSell;
    }

    uint32 public lastOrderId;
    mapping (uint32 => Order) id_Order;

    //orderbook information
    struct OrderBook
    {
        uint8 tickSize;

        uint80 bestBidPrice;
        uint80 bestAskPrice;

        mapping (uint80 => OrderLink) bidPrice_Order;
        mapping (uint80 => OrderLink) askPrice_Order;
    }
    mapping (uint32 => mapping (uint32 => OrderBook)) basePID_tradePID_orderBook;
    function SetOrderBookTickSize(uint32 prTrade, uint32 prBase, uint8 _tickSize) onlyOperator public
    {
        basePID_tradePID_orderBook[prBase][prTrade].tickSize = _tickSize;
    }

    mapping (uint32 => mapping (uint32 => mapping (uint32 => Balance))) exId_prCode_AccountId_Balance;

    // open order list
    struct OpenOrder
    {
        uint32 startId;
        mapping(uint32 => ListItem) id_orderList;
    }
    mapping(uint32 => OpenOrder) accountId_OpenOrder;
    function AddOpenOrder(uint32 accountId, uint32 orderId) private
    {
        OpenOrder memory openOrder = accountId_OpenOrder[accountId];

        if (openOrder.startId != 0)
        {
            accountId_OpenOrder[accountId].id_orderList[openOrder.startId].prev = orderId;
            accountId_OpenOrder[accountId].id_orderList[orderId].next = openOrder.startId;
        }
        accountId_OpenOrder[accountId].startId = orderId;
    }
    function RemoveOpenOrder(uint32 accountId, uint32 orderId) private
    {
        OpenOrder memory openOrder = accountId_OpenOrder[accountId];

        uint32 nextId = accountId_OpenOrder[accountId].id_orderList[orderId].next;
        uint32 prevId = accountId_OpenOrder[accountId].id_orderList[orderId].prev;

        if (nextId != 0)
        {
            accountId_OpenOrder[accountId].id_orderList[nextId].prev = prevId;
        }

        if (prevId != 0)
        {
            accountId_OpenOrder[accountId].id_orderList[prevId].next = nextId;
        }

        if (openOrder.startId == orderId)
        {
            accountId_OpenOrder[accountId].startId = nextId;
        }
    }

    //withdrawal and deposit record (DW records)
    struct DWrecord
    {
        uint32 prCode;
        bool isDeposit;
        uint128 qty;
        uint64 timestamp;
    }

    struct DWrecords
    {
        uint32 N;
        mapping (uint32 => DWrecord) N_DWrecord;
    }
    mapping (uint32 => mapping (uint32 => DWrecords)) exId_AccountId_DWrecords;

    //record deposit and withdrawal
    function RecordDW(uint32 exId, uint32 accountId, uint32 prCode, bool isDeposit, uint128 qty) private
    {
        DWrecord memory dW;
        dW.isDeposit = isDeposit;
        dW.prCode = prCode;
        dW.qty = qty;
        dW.timestamp = uint64(now);

        exId_AccountId_DWrecords[exId][accountId].N_DWrecord[++exId_AccountId_DWrecords[exId][accountId].N] = dW;

        if (isDeposit == true)
            emit NewDeposit(exId, prCode, accountId, qty, dW.timestamp, lastTransferId++);
        else
            emit NewWithdraw(exId, prCode, accountId, qty, dW.timestamp, lastTransferId++);
    }
    // returns 'N', DW  records with account id, accountId, for exchange id, exId
    function GetDWrecords(uint32 N, uint32 exId, uint32 accountId) view public returns (uint32[] prCode, bool[] isDeposit, uint128[] qty, uint64[] timestamp)
    {
        checkAnnounceLV(accountId, 3);

        DWrecords storage dWrecords = exId_AccountId_DWrecords[exId][accountId];
        uint32 n = dWrecords.N;

        if (n > N)
            n = N;

        prCode = new uint32[](n);
        isDeposit = new bool[](n);
        qty = new uint128[](n);
        timestamp = new uint64[](n);

        for (uint32 i = dWrecords.N; i > dWrecords.N - n; i--)
        {
            N = dWrecords.N - i;
            prCode[N] = dWrecords.N_DWrecord[i].prCode;
            isDeposit[N] = dWrecords.N_DWrecord[i].isDeposit;
            qty[N] = dWrecords.N_DWrecord[i].qty;
            timestamp[N] = dWrecords.N_DWrecord[i].timestamp;
        }
    }

    //Deposit ETH to exchange
    function depositETH(uint32 exId) payable onlyContractUse public
    {
        require(exId <= lastOwnerId);
        uint32 accountId = FindOrAddAccount();
        exId_prCode_AccountId_Balance[exId][1][accountId].available = Add(exId_prCode_AccountId_Balance[exId][1][accountId].available, uint128(msg.value));
        RecordDW(exId, accountId, 1, true, uint104(msg.value));
    }
    // Withdraw ETH from exchange
    function withdrawETH(uint32 exId, uint104 amount) public
    {
        uint32 accountId = FindOrRevertAccount();
        require(accountId_freeze[accountId] == false);
        exId_prCode_AccountId_Balance[exId][1][accountId].available = Sub(exId_prCode_AccountId_Balance[exId][1][accountId].available, amount);
        require(msg.sender.send(amount));
        RecordDW(exId, accountId, 1, false,  amount);
    }
    // Deposit/Withdraw, ERC20's to exchange
    function depositWithdrawToken(uint32 exId, uint128 amount, bool isDeposit, address prAddress) public
    {
        uint32 prCode = product_prCode[prAddress];
        require(amount < maxBalance && prCode != 0);
        uint32 accountId = FindOrAddAccount();
        require(accountId_freeze[accountId] == false);

        if (isDeposit == true)
        {
            require(prCode_productInfo[prCode].isDeposit == true && isContractUse == true && exId <= lastOwnerId);
            require(Token(prAddress).transferFrom(msg.sender, this, amount));
            exId_prCode_AccountId_Balance[exId][prCode][accountId].available = Add(exId_prCode_AccountId_Balance[exId][prCode][accountId].available, amount);
            require (exId_prCode_AccountId_Balance[exId][prCode][accountId].available < maxBalance);
        }
        else
        {
            require(prCode_productInfo[prCode].isWithdraw == true);
            exId_prCode_AccountId_Balance[exId][prCode][accountId].available = Sub(exId_prCode_AccountId_Balance[exId][prCode][accountId].available, amount);
            require(Token(prAddress).transfer(msg.sender, amount));
        }
        RecordDW(exId, accountId, prCode, isDeposit, amount);
    }

    // This function will be never used in normal situations.
    // This function is only prepared for emergency case such as smart contract hacking Vulnerability or smart contract abolishment
    // Withdrawn fund by this function cannot belong to any exchange operators or owners.
    // Withdrawn fund should be distributed to individual accounts having original ownership of withdrawn fund.
    // After using this function, this contract cannot get any deposit or trade.
    // After using this function, this contract will be abolished.
    function emergencyWithdrawal(uint32 prCode, uint256 amount) onlyOwner public
    {
        isContractUse = false;//This cannot be return. After activating this, this contract cannot support any deposit or trade function.
        if (prCode == 1)
            require(msg.sender.send(amount));
        else
            Token(prCode_product[prCode]).transfer(msg.sender, amount);
    }

    // Find tick size of each price
    function GetNextTick(bool isAsk, uint80 price, uint8 n) public pure returns (uint80)
    {
        if (price > 0)
        {
            uint80 tick = GetTick(price, n);

            if (isAsk == true)
                return (((price - 1) / tick) + 1) * tick;
            else
                return (price / tick) * tick;
        }
        else
        {
            return price;
        }
    }

    function GetTick(uint80 price, uint8 n)  public pure returns  (uint80)
    {
        if (n < 1)
            n = 1;

        uint80 x = 1;

        for (uint8 i=1; i <= n / 2; i++)
        {
            x *= 10;
        }

        if (price < 10 * x)
            return 1;
        else
        {
            uint80 tick = 10000;

            uint80 priceTenPercent = price / 10 / x;

            while (priceTenPercent > tick)
            {
                tick *= 10;
            }

            while (priceTenPercent < tick)
            {
                tick /= 10;
            }

            if (n % 2 == 1)
            {
                if (price >= 50 * tick * x)
                {
                    tick *= 5;
                }
            }
            else
            {
                if (price < 50 * tick * x)
                {
                    tick *= 5;
                }
                else
                {
                    tick *= 10;
                }

            }

            return tick;
        }
    }
    // New limit order
    function LimitOrder(uint32 exId, uint32 prTrade, uint32 prBase, bool isSell, uint80 price, uint104 qty) public onlyContractUse  returns  (uint32)
    {
        uint32 accountId = FindOrRevertAccount();
        require(accountId_freeze[accountId] == false);
        uint80 lastBestPrice;
        OrderBook storage orderBook = basePID_tradePID_orderBook[prBase][prTrade];
        require(price != 0 && price <= maxPrice && qty <= maxQty &&
            ((isSell == false && prCode_productInfo[prTrade].isTradeBid == true && prCode_productInfo[prBase].isTradeAsk == true)
            || (isSell == true && prCode_productInfo[prTrade].isTradeAsk == true && prCode_productInfo[prBase].isTradeBid == true))
            && prCode_productInfo[prTrade].minQty <= qty);

        if (isSell == true)
        {
            price = GetNextTick(true, price, orderBook.tickSize);
            lastBestPrice = orderBook.bestAskPrice;
        }
        else
        {
            price = GetNextTick(false, price, orderBook.tickSize);
            lastBestPrice = orderBook.bestBidPrice;
        }

        Order memory order;
        order.exId = exId;
        order.isSell = isSell;
        order.prTrade = prTrade;
        order.prBase = prBase;
        order.accountId = accountId;
        order.price = price;
        order.qty = qty;

        require (IsPossibleLimit(exId, order));

        emit NewOrder(order.prTrade, order.prBase, order.accountId, ++lastOrderId, order.isSell, order.price, order.qty, lastNewOrderId++);

        BalanceUpdateByLimitAfterTrade(order, qty, matchOrder(orderBook, order, lastOrderId));

        if (order.qty != 0)
        {
            uint80 priceNext;
            uint80 price0;

            if (isSell == true)
            {
                price0 = orderBook.bestAskPrice;
                if (price0 == 0)
                {
                    orderBook.askPrice_Order[price].prevPrice = 0;
                    orderBook.askPrice_Order[price].nextPrice = 0;
                    orderBook.bestAskPrice = price;
                }
                else if(price < price0)
                {
                    orderBook.askPrice_Order[price0].prevPrice = price;
                    orderBook.askPrice_Order[price].prevPrice = 0;
                    orderBook.askPrice_Order[price].nextPrice = price0;
                    orderBook.bestAskPrice = price;
                }
                else if (orderBook.askPrice_Order[price].firstId == 0)
                {
                    priceNext = price0;

                    while (priceNext != 0 && priceNext < price)
                    {
                        price0 = priceNext;
                        priceNext = orderBook.askPrice_Order[price0].nextPrice;
                    }

                    orderBook.askPrice_Order[price0].nextPrice = price;
                    orderBook.askPrice_Order[price].prevPrice = price0;
                    orderBook.askPrice_Order[price].nextPrice = priceNext;
                    if (priceNext != 0)
                    {
                        orderBook.askPrice_Order[priceNext].prevPrice = price;
                    }
                }

                OrderLink storage orderLink = orderBook.askPrice_Order[price];
            }
            else
            {
                price0 = orderBook.bestBidPrice;
                if (price0 == 0)
                {
                    orderBook.bidPrice_Order[price].prevPrice = 0;
                    orderBook.bidPrice_Order[price].nextPrice = 0;
                    orderBook.bestBidPrice = price;
                }
                else if (price > price0)
                {
                    orderBook.bidPrice_Order[price0].prevPrice = price;
                    orderBook.bidPrice_Order[price].prevPrice = 0;
                    orderBook.bidPrice_Order[price].nextPrice = price0;
                    orderBook.bestBidPrice = price;
                }
                else if (orderBook.bidPrice_Order[price].firstId == 0)
                {
                    priceNext = price0;

                    while (priceNext != 0 && priceNext > price)
                    {
                        price0 = priceNext;
                        priceNext = orderBook.bidPrice_Order[price0].nextPrice;
                    }

                    orderBook.bidPrice_Order[price0].nextPrice = price;
                    orderBook.bidPrice_Order[price].prevPrice = price0;
                    orderBook.bidPrice_Order[price].nextPrice = priceNext;
                    if (priceNext != 0)
                    {
                        orderBook.bidPrice_Order[priceNext].prevPrice = price;
                    }
                }

                orderLink = orderBook.bidPrice_Order[price];
            }

            if (lastOrderId != 0)
            {
                orderLink.id_orderList[lastOrderId].prev = orderLink.lastId;
                if (orderLink.firstId != 0)
                {
                    orderLink.id_orderList[orderLink.lastId].next = lastOrderId;
                }
                else
                {
                    orderLink.id_orderList[lastOrderId].next = 0;
                    orderLink.firstId = lastOrderId;
                }
                orderLink.lastId = lastOrderId;
            }

            AddOpenOrder(accountId, lastOrderId);
            id_Order[lastOrderId] = order;
        }

        if (isSell == true && lastBestPrice != orderBook.bestAskPrice)
        {
            emit NewBestBidAsk(prTrade, prBase, isSell, orderBook.bestAskPrice);
        }
        if (isSell == false && lastBestPrice != orderBook.bestBidPrice)
        {
            emit NewBestBidAsk(prTrade, prBase, isSell, orderBook.bestBidPrice);
        }

        return lastOrderId;
    }

    function BalanceUpdateByLimitAfterTrade(Order order, uint104 qty, uint104 tradedQty) private
    {
        uint32 exId = order.exId;
        uint32 accountId = order.accountId;
        uint32 prTrade = order.prTrade;
        uint32 prBase = order.prBase;
        uint80 price = order.price;
        uint104 orderQty = order.qty;

        if (order.isSell)
        {
            Balance storage balance = exId_prCode_AccountId_Balance[exId][prTrade][accountId];
            balance.available = Sub(balance.available, qty);

            if (orderQty != 0)
                balance.reserved = Add(balance.reserved, orderQty);
        }
        else
        {
            balance = exId_prCode_AccountId_Balance[exId][prBase][accountId];
            if (orderQty != 0)
            {
                // prCode_productInfo[prBase].divider * qty * price < 2^60 * 2^80 * 2^104 < 2^256
                uint256 temp = prCode_productInfo[prBase].divider * orderQty * price / basePrice / prCode_productInfo[prTrade].divider;
                require (temp < maxQty); // temp < maxQty < 2^104
                balance.available = Sub(balance.available, tradedQty + uint104(temp));
                balance.reserved = Add(balance.reserved, uint104(temp));
            }
            else
            {
                balance.available = Sub(balance.available, tradedQty);
            }
            tradedQty = qty - orderQty;

            prBase = prTrade;
        }
        if (tradedQty != 0)
        {
            uint104 takeFeeLocal = tradedQty * ownerId_takerFeeRateLocal[exId] / 10000;
            exId_prCode_AccountId_Balance[exId][prBase][accountId].available += tradedQty - takeFeeLocal;
            exId_prCode_AccountId_Balance[exId][prBase][ownerId_accountId[exId]].available += takeFeeLocal;
        }
    }

    function IsPossibleLimit(uint32 exId, Order memory order) private view returns (bool)
    {
        if (order.isSell)
        {
            if (exId_prCode_AccountId_Balance[exId][order.prTrade][order.accountId].available >= order.qty)
                return true;
            else
                return false;
        }
        else
        {
            if (exId_prCode_AccountId_Balance[exId][order.prBase][order.accountId].available >= prCode_productInfo[order.prBase].divider * order.qty * order.price / basePrice / prCode_productInfo[order.prTrade].divider)
                return true;
            else
                return false;
        }
    }
    // Heart of DexHI's onchain order matching algorithm
    function matchOrder(OrderBook storage ob, Order memory order, uint32 id) private returns (uint104)
    {
        uint32 prTrade = order.prTrade;
        uint32 prBase = order.prBase;
        uint80 tradePrice;

        if (order.isSell == true)
            tradePrice = ob.bestBidPrice;
        else
            tradePrice = ob.bestAskPrice;

        bool isBestPriceUpdate = false;

        uint104 qtyBase = 0;
        uint104 tradeAmount;

        while (tradePrice != 0 && order.qty > 0 && ((order.isSell && order.price <= tradePrice) || (!order.isSell && order.price >= tradePrice)))
        {
            if (order.isSell == true)
                OrderLink storage orderLink = ob.bidPrice_Order[tradePrice];
            else
                orderLink = ob.askPrice_Order[tradePrice];

            uint32 orderId = orderLink.firstId;

            while (orderLink.firstId != 0 && orderId != 0 && order.qty != 0)
            {
                Order storage matchingOrder = id_Order[orderId];
                if (matchingOrder.qty >= order.qty)
                {
                    tradeAmount = order.qty;
                    matchingOrder.qty -= order.qty; //matchingOrder.qty cannot be negative by (matchingOrder.qty >= order.qty
                    order.qty = 0;
                }
                else
                {
                    tradeAmount = matchingOrder.qty;
                    order.qty -= matchingOrder.qty;
                    matchingOrder.qty = 0;
                }

                qtyBase += BalanceUpdateByTradeCp(order, matchingOrder, tradeAmount);
                //return value of BalanceUpdateByTradeCp < maxqty < 2^100 so qtyBase < 2 * maxqty < 2 * 101 by below require(qtyBase < maxQty) -> qtyBase cannot be overflow
                require(qtyBase < maxQty);

                uint32 orderAccountID = order.accountId;

                if (order.isSell == true)
                    emit NewTrade(prTrade, prBase, orderId, id, matchingOrder.accountId, orderAccountID, true, tradePrice,  tradeAmount, lastTradeId++, uint64(now));
                else
                    emit NewTrade(prTrade, prBase, id, orderId, orderAccountID, matchingOrder.accountId, false, tradePrice,  tradeAmount, lastTradeId++, uint64(now));

                if (matchingOrder.qty != 0)
                {
                    break;
                }
                else
                {
                    if (RemoveOrder(prTrade, prBase, matchingOrder.isSell, tradePrice, orderId) == true)
                    {
                        RemoveOpenOrder(matchingOrder.accountId, orderId);
                    }
                    orderId = orderLink.firstId;
                }
            }

            if (orderLink.firstId == 0)
            {
                tradePrice = orderLink.nextPrice;
                isBestPriceUpdate = true;
            }
        }

        if (isBestPriceUpdate == true)
        {
            if (order.isSell)
            {
                ob.bestBidPrice = tradePrice;
            }
            else
            {
                ob.bestAskPrice = tradePrice;
            }

            emit NewBestBidAsk(prTrade, prBase, !order.isSell, tradePrice);
        }

        return qtyBase;
    }

    function BalanceUpdateByTradeCp(Order order, Order matchingOrder, uint104 tradeAmount) private returns (uint104)
    {
        uint32 accountId = matchingOrder.accountId;
        uint32 prTrade = order.prTrade;
        uint32 prBase = order.prBase;
        require (tradeAmount < maxQty);
        // qtyBase < 10 ^ 18 < 2^ 60 & tradedAmount < 2^104 & matching orderprice < 2^80 ->  prCode_productInfo[prBase].divider * tradeAmount * matchingOrder.price < 2^256
        // so, below qtyBase cannot be overflow
        uint256 qtyBase = prCode_productInfo[prBase].divider * tradeAmount * matchingOrder.price / basePrice / prCode_productInfo[prTrade].divider;
        require (qtyBase < maxQty);

        Balance storage balanceTrade = exId_prCode_AccountId_Balance[matchingOrder.exId][prTrade][accountId];
        Balance storage balanceBase = exId_prCode_AccountId_Balance[matchingOrder.exId][prBase][accountId];

        if (order.isSell == true)
        {
            balanceTrade.available = SafeMath.Add(balanceTrade.available, tradeAmount);
            balanceBase.reserved = SafeMath.Sub(balanceBase.reserved, uint104(qtyBase));
        }
        else
        {
            balanceTrade.reserved = SafeMath.Sub(balanceTrade.reserved, tradeAmount);
            balanceBase.available = SafeMath.Add(balanceBase.available, uint104(qtyBase));
        }

        return uint104(qtyBase); // return value < maxQty = 1000000000000000000000000000001 < 2^100 by require (qtyBase < maxQty);
    }
    // Internal functions to remove order
    function RemoveOrder(uint32 prTrade, uint32 prBase, bool isSell, uint80 price, uint32 id) private returns (bool)
    {
        OrderBook storage ob = basePID_tradePID_orderBook[prBase][prTrade];

        if (isSell == false)
        {
            OrderLink storage orderLink = ob.bidPrice_Order[price];
        }
        else
        {
            orderLink = ob.askPrice_Order[price];
        }

        if (id != 0)
        {
            ListItem memory removeItem = orderLink.id_orderList[id];
            if (removeItem.next != 0)
            {
                orderLink.id_orderList[removeItem.next].prev = removeItem.prev;
            }

            if (removeItem.prev != 0)
            {
                orderLink.id_orderList[removeItem.prev].next = removeItem.next;
            }

            if (id == orderLink.lastId)
            {
                orderLink.lastId = removeItem.prev;
            }

            if (id == orderLink.firstId)
            {
                orderLink.firstId = removeItem.next;
            }

            delete orderLink.id_orderList[id];

            if (orderLink.firstId == 0)
            {
                if (orderLink.nextPrice != 0)
                {
                    if (isSell == true)
                        OrderLink storage replaceLink = ob.askPrice_Order[orderLink.nextPrice];
                    else
                        replaceLink = ob.bidPrice_Order[orderLink.nextPrice];

                    replaceLink.prevPrice = orderLink.prevPrice;
                }
                if (orderLink.prevPrice != 0)
                {
                    if (isSell == true)
                        replaceLink = ob.askPrice_Order[orderLink.prevPrice];
                    else
                        replaceLink = ob.bidPrice_Order[orderLink.prevPrice];

                    replaceLink.nextPrice = orderLink.nextPrice;
                }

                if (price == ob.bestAskPrice)
                {
                    ob.bestAskPrice = orderLink.nextPrice;
                }
                if (price == ob.bestBidPrice)
                {
                    ob.bestBidPrice = orderLink.nextPrice;
                }
            }
            return true;
        }
        else
        {
            return false;
        }
    }
    // Cancel orders, keep eye on max block gas Fee
    function cancelOrders(uint32 exId, uint32[] id) public
    {
        for (uint32 i = 0; i < id.length; i++)
        {
            cancelOrder(exId, id[i]);
        }
    }
    //  Cancel order
    function cancelOrder(uint32 exId, uint32 id) public returns (bool)
    {
        Order memory order = id_Order[id];
        uint32 accountId = account_id[msg.sender];
        require(order.accountId == accountId);

        uint32 prTrade = order.prTrade;
        uint32 prBase = order.prBase;
        bool isSell = order.isSell;
        uint80 price = order.price;
        uint104 qty = order.qty;

        if (RemoveOrder(prTrade, prBase, isSell, price, id) == false)
            return false;
        else
        {
            RemoveOpenOrder(accountId, id);
        }

        if (isSell)
        {
            Balance storage balance = exId_prCode_AccountId_Balance[exId][prTrade][accountId];
            balance.available = SafeMath.Add(balance.available, qty);
            balance.reserved = SafeMath.Sub(balance.reserved, qty);
        }
        else
        {
            balance = exId_prCode_AccountId_Balance[exId][prBase][accountId];
            // prCode_productInfo[prBase].divider * qty * price < 2^60 * 2^80 * 2^104 < 2^256
            uint256 temp = prCode_productInfo[prBase].divider * qty * price / basePrice / prCode_productInfo[prTrade].divider;
            require (temp < maxQty); // temp < maxQty < 2^104 -> temp cannot be overflow
            balance.available = SafeMath.Add(balance.available, uint104(temp));
            balance.reserved = SafeMath.Sub(balance.reserved, uint104(temp));
        }

        emit NewCancel(prTrade, prBase, accountId, id, isSell, price, qty, lastNewOrderId++);
        return true;
    }
    function checkAnnounceLV(uint32 accountId, uint8 LV) private view returns (bool)
    {
        require(accountId == account_id[msg.sender] || id_announceLV[accountId] >= LV || msg.sender == operator || owner_id[msg.sender] != 0);
    }
    // Get balance by acount id
    function getBalance(uint32 exId, uint32[] prCode, uint32 accountId) view public returns (uint128[] available, uint128[] reserved)
    {
        if (accountId == 0)
            accountId = account_id[msg.sender];
        checkAnnounceLV(accountId, 2);

        uint256 n = prCode.length;
        available = new uint128[](n);
        reserved = new uint128[](n);

        for (uint32 i = 0; i < n; i++)
        {
            available[i] = exId_prCode_AccountId_Balance[exId][prCode[i]][accountId].available;
            reserved[i] = exId_prCode_AccountId_Balance[exId][prCode[i]][accountId].reserved;
        }
    }
    // Get balance by product
    function getBalanceByProduct(uint32 exId, uint32 prCode, uint128 minQty) view public returns (uint32[] accountId, uint128[] balanceSum)
    {
        require (owner_id[msg.sender] != 0 || msg.sender == operator);
        uint32 n = 0;
        for (uint32 i = 1; i <= lastAcccountId; i++)
        {
            if (exId_prCode_AccountId_Balance[exId][prCode][i].available + exId_prCode_AccountId_Balance[exId][prCode][i].reserved > minQty)
                n++;
        }
        accountId = new uint32[](n);
        balanceSum = new uint128[](n);

        n = 0;
        uint128 temp;
        for (i = 1; i <= lastAcccountId; i++)
        {
            temp = exId_prCode_AccountId_Balance[exId][prCode][i].available + exId_prCode_AccountId_Balance[exId][prCode][i].reserved;
            if (temp >= minQty)
            {
                accountId[n] = i;
                balanceSum[n++] = temp;
            }
        }
    }

    // Get bestBidPrice and bestAskPrice of each orderbook
    function getOrderBookInfo(uint32[] prTrade, uint32 prBase) view public returns (uint80[] bestBidPrice, uint80[] bestAskPrice)
    {
        uint256 n = prTrade.length;
        bestBidPrice = new uint80[](n);
        bestAskPrice = new uint80[](n);

        for (uint256 i = 0; i < n; i++)
        {
            OrderBook memory orderBook = basePID_tradePID_orderBook[prBase][prTrade[i]];
            bestBidPrice[i] = orderBook.bestBidPrice;
            bestAskPrice[i] = orderBook.bestAskPrice;
        }
    }

    // Get order information by order id
    function getOrder(uint32 id) view public returns (uint32 prTrade, uint32 prBase, bool sell, uint80 price, uint104 qty, uint32 accountId)
    {
        Order memory order = id_Order[id];

        accountId = order.accountId;
        checkAnnounceLV(accountId, 4);

        prTrade = order.prTrade;
        prBase = order.prBase;
        price = order.price;
        sell = order.isSell;
        qty = order.qty;
    }

    // Get message sender's open orders
    function GetMyOrders(uint32 exId, uint32 accountId, uint16 orderN) view public returns (uint32[] orderId, uint32[] prTrade, uint32[] prBase, bool[] sells, uint80[] prices, uint104[] qtys)
    {
        if (accountId == 0)
            accountId = account_id[msg.sender];

        checkAnnounceLV(accountId, 4);

        OpenOrder storage openOrder = accountId_OpenOrder[accountId];

        orderId = new uint32[](orderN);
        prTrade = new uint32[](orderN);
        prBase = new uint32[](orderN);
        qtys = new uint104[](orderN);
        prices = new uint80[](orderN);
        sells = new bool[](orderN);

        uint32 id = openOrder.startId;
        if (id != 0)
        {
            Order memory order;
            uint32 i = 0;
            while (id != 0 && i < orderN)
            {
                order = id_Order[id];

                if (exId == order.exId)
                {
                    orderId[i] = id;
                    prTrade[i] = order.prTrade;
                    prBase[i] = order.prBase;
                    qtys[i] = order.qty;
                    prices[i] = order.price;
                    sells[i++] = order.isSell;
                }

                id = openOrder.id_orderList[id].next;
            }
        }
    }

    // Get all order id in each price
    function GetHogaDetail(uint32 prTrade, uint32 prBase, uint80 price, bool isSell, uint16 orderN) view public returns (uint32[] orderIds)
    {
        if (isSell == false)
        {
            OrderLink storage orderLink = basePID_tradePID_orderBook[prBase][prTrade].bidPrice_Order[price];
        }
        else if (isSell == true)
        {
            orderLink = basePID_tradePID_orderBook[prBase][prTrade].askPrice_Order[price];
        }
        else
        {
            return;
        }

        orderIds = new uint32[](orderN);
        uint16 n = 0;
        uint32 id0 = orderLink.firstId;
        while (id0 != 0 && orderN > n)
        {
            orderIds[n++] = id0;
            id0 = orderLink.id_orderList[id0].next;
        }
    }

    // Get orderbook screen
    function GetHoga(uint32 prTrade, uint32 prBase, uint32 hogaN) public view returns (uint80[] priceB, uint104[] volumeB, uint80[] priceA, uint104[] volumeA)
    {
        OrderBook storage ob = basePID_tradePID_orderBook[prBase][prTrade];

        (priceB, volumeB) = GetHoga(ob, hogaN, false);
        (priceA, volumeA) = GetHoga(ob, hogaN, true);
    }

    // Get orderbook screen
    function GetHoga(OrderBook storage ob, uint32 hogaN, bool isSell) private view returns (uint80[] prices, uint104[] volumes)
    {
        prices = new uint80[](hogaN);
        volumes = new uint104[](hogaN);

        uint32 n;
        uint32 id0;
        uint80 price;
        uint104 sum;

        if (isSell == false)
            price = ob.bestBidPrice;
        else
            price = ob.bestAskPrice;

        if (price != 0)
        {
            n = 0;
            while (price != 0 && n < hogaN)
            {
                if (isSell == false)
                    OrderLink storage orderLink = ob.bidPrice_Order[price];
                else
                    orderLink = ob.askPrice_Order[price];

                id0 = orderLink.firstId;
                sum = 0;
                while (id0 != 0)
                {
                    sum += id_Order[id0].qty;
                    id0 = orderLink.id_orderList[id0].next;
                }
                prices[n] = price;
                volumes[n] = sum;
                price = orderLink.nextPrice;
                n++;
            }

            if (n > 0)
            {
                while (n < hogaN)
                {
                    if (isSell == true)
                        prices[n] = GetNextTick(true, prices[n - 1] + 1, ob.tickSize);
                    else
                        prices[n] = GetNextTick(false, prices[n - 1] - 1, ob.tickSize);
                    n++;
                }
            }
        }
    }
}