pragma solidity ^0.4.18;


contract ExternalCurrencyPrice {
    struct CurrencyValue {
        uint64 value;
        uint8 decimals;
    }

    struct Transaction {
        string currency;
        uint64 value;
        string transactionId;
        uint64 price;
        uint8  decimals;
    }

    struct RefundTransaction {
        uint sourceTransaction;
        uint88 refundAmount;
    }

    mapping(string => CurrencyValue) prices;

    Transaction[] public transactions;
    RefundTransaction[] public refundTransactions;

    address owner;

    event NewTransaction(string currency, uint64 value, string transactionId,
                                                            uint64 price, uint8 decimals);
    event NewRefundTransaction(uint sourceTransaction, uint88 refundAmount);
    event PriceSet(string currency, uint64 value, uint8 decimals);

    modifier onlyAdministrator() {
        require(tx.origin == owner);
        _;
    }

    function ExternalCurrencyPrice()
        public
    {
        owner = tx.origin;
    }

    //Example: 0.00007115 BTC will be setPrice("BTC", 7115, 8)
    function setPrice(string currency, uint64 value, uint8 decimals)
        public
        onlyAdministrator
    {
        prices[currency].value = value;
        prices[currency].decimals = decimals;
        PriceSet(currency, value, decimals);
    }

    function getPrice(string currency)
        public
        view
        returns(uint64 value, uint8 decimals)
    {
        value = prices[currency].value;
        decimals = prices[currency].decimals;
    }

    //Value is returned with accuracy of 18 decimals (same as token)
    //Example: to calculate value of 1 BTC call
    // should look like calculateAmount("BTC", 100000000)
    // See setPrice example (8 decimals)
    function calculateAmount(string currency, uint64 value)
        public
        view
        returns (uint88 amount)
    {
        require(prices[currency].value > 0);
        require(value >= prices[currency].value);

        amount = uint88( ( uint(value) * ( 10**18 ) ) / prices[currency].value );
    }

    function calculatePrice(string currency, uint88 amount)
        public
        view
        returns (uint64 price)
    {
        require(prices[currency].value > 0);

        price = uint64( amount * prices[currency].value );
    }

    function addTransaction(string currency, uint64 value, string transactionId)
        public
        onlyAdministrator
        returns (uint newTransactionId)
    {
        require(prices[currency].value > 0);

        newTransactionId = transactions.length;

        Transaction memory transaction;

        transaction.currency = currency;
        transaction.value = value;
        transaction.decimals = prices[currency].decimals;
        transaction.price = prices[currency].value;
        transaction.transactionId = transactionId;

        transactions.push(transaction);

        NewTransaction(transaction.currency, transaction.value, transaction.transactionId,
            transaction.price, transaction.decimals);
    }

    function getNumTransactions()
        public
        constant
        returns(uint length)
    {
        length = transactions.length;
    }

    function addRefundTransaction(uint sourceTransaction, uint88 refundAmount)
        public
        onlyAdministrator
        returns (uint newTransactionId)
    {
        require(sourceTransaction < transactions.length);

        newTransactionId = refundTransactions.length;

        RefundTransaction memory transaction;

        transaction.sourceTransaction = sourceTransaction;
        transaction.refundAmount = refundAmount;

        refundTransactions.push(transaction);

        NewRefundTransaction(transaction.sourceTransaction, transaction.refundAmount);
    }

    function getNumRefundTransactions()
        public
        constant
        returns(uint length)
    {
        length = refundTransactions.length;
    }
}