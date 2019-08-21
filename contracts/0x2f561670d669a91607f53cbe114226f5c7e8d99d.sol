pragma solidity ^0.4.22;

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {

  /**
  * @dev Multiplies two numbers, throws on overflow.
  */
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    assert(c / a == b);
    return c;
  }

  /**
  * @dev Integer division of two numbers, truncating the quotient.
  */
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    // uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return a / b;
  }

  /**
  * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
  */
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  /**
  * @dev Adds two numbers, throws on overflow.
  */
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}


contract EstateParticipationUnit  
{
    using SafeMath for uint256;  
    
    enum VoteType
    {
        NONE,
        ALLOW_TRANSFER,
        CHANGE_ADMIN_WALLET,
        CHANGE_BUY_SELL_LIMITS,
        CHANGE_BUY_SELL_PRICE,
        SEND_WEI_FROM_EXCHANGE,
        SEND_WEI_FROM_PAYMENT,
        TRANSFER_EXCHANGE_WEI_TO_PAYMENT,
        START_PAYMENT
    }
    
    struct VoteData
    {
        bool voteYes;
        bool voteCancel;
        address person;
        uint lastVoteId;
    }
    
    struct PaymentData
    {
        uint weiTotal;
        uint weiReceived;
        uint unitsTotal;
        uint unitsReceived;
        uint weiForSingleUnit;
    }
    
    struct BalanceData
    {
        uint balance;
        uint transferAllowed;
        uint balancePaymentSeries;
        VoteData vote;
        mapping (address => uint) allowed;
        bytes32 paymentBalances;
    }
    
    struct ChangeBuySellPriceVoteData
    {
        bool ignoreSecurityLimits;
        uint buyPrice;
        uint buyAddUnits;
        uint sellPrice;
        uint sellAddUnits;
    }
    
    struct AllowTransferVoteData
    {
        address addressTo;
        uint amount;
    }
    
    struct ChangeAdminAddressVoteData
    {
        uint index;
        address adminAddress;
    }
    
    struct ChangeBuySellLimitsVoteData
    {
        uint buyPriceMin;
        uint buyPriceMax;
        uint sellPriceMin;
        uint sellPriceMax;
    }
    
    struct SendWeiFromExchangeVoteData
    {
        address addressTo;
        uint amount;
    }
    
    struct SendWeiFromPaymentVoteData
    {
        address addressTo;
        uint amount;
    }
    
    struct TransferWeiFromExchangeToPaymentVoteData
    {
        bool reverse;
        uint amount;
    }
    
    struct StartPaymentVoteData
    {
        uint weiToShare;
        uint date;
    }
    
    struct PriceSumData
    {
        uint price;
        uint amount;
    }
    
    modifier onlyAdmin()
    {
        require (isAdmin(msg.sender));
        _;
    }
    
    address private mainBalanceAdmin;
    address private buyBalanceAdmin;
    address private sellBalanceAdmin;
    string public constant name = "Estate Participation Unit";
    string public constant symbol = "EPU";
    uint8 public constant decimals = 0;
    uint public amountOfUnitsOutsideAdminWallet = 0;
    uint private constant maxUnits = 200000000;
    uint public paymentNumber = 0;
    uint public paymentSortId = 0;
    uint private paymentSeries = 0;
    bytes32 private paymentHistory;
    uint public weiForPayment = 0;
    uint public totalAmountOfWeiPaidToUsers = 0;
    uint private totalAmountOfWeiPaidToUsersPerSeries = 0;
    uint private totalAmountOfWeiOnPaymentsPerSeries = 0;
    uint public lastPaymentDate;
    
    uint private weiBuyPrice = 50000000000000000;
    uint private securityWeiBuyPriceFrom = 0;
    uint private securityWeiBuyPriceTo = 0;
    
    uint private weiSellPrice = 47000000000000000;
    uint public unitsToSell = 0;
    uint private securityWeiSellPriceFrom = 0;
    uint private securityWeiSellPriceTo = 0;
    uint public weiFromExchange = 0;
    
    PriceSumData private buySum;
    PriceSumData private sellSum;
    
    uint private voteId = 0;
    bool private voteInProgress;
    uint private votesTotalYes;
    uint private votesTotalNo;
    uint private voteCancel;
    
    AllowTransferVoteData private allowTransferVoteData;
    ChangeAdminAddressVoteData private changeAdminAddressVoteData;
    ChangeBuySellLimitsVoteData private changeBuySellLimitsVoteData;
    ChangeBuySellPriceVoteData private changeBuySellPriceVoteData;
    SendWeiFromExchangeVoteData private sendWeiFromExchangeVoteData;
    SendWeiFromPaymentVoteData private sendWeiFromPaymentVoteData;
    TransferWeiFromExchangeToPaymentVoteData private transferWeiFromExchangeToPaymentVoteData;
    StartPaymentVoteData private startPaymentVoteData;
    
    VoteType private voteType = VoteType.NONE;
    
    mapping(address => BalanceData) private balances;
    
    event Transfer(address indexed from, address indexed to, uint units);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
    event OnEmitNewUnitsFromMainWallet(uint units, uint totalOutside);
    event OnAddNewUnitsToMainWallet(uint units, uint totalOutside);
    event NewPayment(uint indexed index, uint totalWei, uint totalUnits, uint date);
    event PaymentReceived(address indexed owner, uint paymentId, uint weiAmount, uint units);
    event UnitsBuy(address indexed buyer, uint amount);
    event UnitsSell(address indexed seller, uint amount);
    event OnExchangeBuyUpdate(uint newValue, uint unitsToBuy);
    event OnExchangeSellUpdate(uint newValue, uint unitsToSell);
    
    modifier startVoting
    {
        require(voteType == VoteType.NONE);
        _;
    }
    
    constructor(
        uint paymentOffset,
        address mainBalanceAdminAddress, 
        address buyBalanceAdminAddress, 
        address sellBalanceAdminAddress
    ) 
    payable
    public
    {
        paymentNumber = paymentOffset;
        mainBalanceAdmin = mainBalanceAdminAddress;
        buyBalanceAdmin = buyBalanceAdminAddress;
        sellBalanceAdmin = sellBalanceAdminAddress;
        BalanceData storage b = balances[mainBalanceAdminAddress];
        b.balance = maxUnits;
        weiForPayment = weiForPayment.add(msg.value);
    }
    
    function  getAdminAccounts()
    external onlyAdmin view
    returns(
        address mainBalanceAdminAddress, 
        address buyBalanceAdminAddress, 
        address sellBalanceAdminAddress
    )
    {
        mainBalanceAdminAddress = mainBalanceAdmin;
        buyBalanceAdminAddress = buyBalanceAdmin;
        sellBalanceAdminAddress = sellBalanceAdmin;
    }
    
    function getBuySellSum()
    external onlyAdmin view
    returns(
        uint buyPrice,
        uint buyAmount,
        uint sellPrice,
        uint sellAmount
    )
    {
        buyPrice = buySum.price;
        buyAmount = buySum.amount;
        sellPrice = sellSum.price;
        sellAmount = sellSum.amount;
    }
    
    function getSecurityLimits() 
    external view 
    returns(
        uint buyPriceFrom, 
        uint buyPriceTo, 
        uint sellPriceFrom, 
        uint sellPriceTo
    )
    {
        buyPriceFrom = securityWeiBuyPriceFrom;
        buyPriceTo = securityWeiBuyPriceTo;
        sellPriceFrom = securityWeiSellPriceFrom;
        sellPriceTo = securityWeiSellPriceTo;
    }
    
    function getThisAddress() 
    external view 
    returns (address)
    {
        return address(this);
    }
    
    function() payable external 
    {
        weiForPayment = weiForPayment.add(msg.value);
    }
    
     function startVotingForAllowTransfer(
         address addressTo, 
         uint amount
    )
        external onlyAdmin startVoting
    {
        voteType = VoteType.ALLOW_TRANSFER;
        allowTransferVoteData.addressTo = addressTo;
        allowTransferVoteData.amount = amount;
        internalStartVoting();
    }
    
    function startVotingForChangeAdminAddress(
        uint index, 
        address adminAddress
    )
        external onlyAdmin startVoting
    {
        require(!isAdmin(adminAddress));
        voteType = VoteType.CHANGE_ADMIN_WALLET;
        changeAdminAddressVoteData.index = index;
        changeAdminAddressVoteData.adminAddress = adminAddress;
        internalStartVoting();
    }
    
    function startVotingForChangeBuySellLimits(
        uint buyPriceMin, 
        uint buyPriceMax, 
        uint sellPriceMin, 
        uint sellPriceMax
    )
        external onlyAdmin startVoting
    {
        if(buyPriceMin > 0 && buyPriceMax > 0)
        {
            require(buyPriceMin < buyPriceMax);
        }
        if(sellPriceMin > 0 && sellPriceMax > 0)
        {
            require(sellPriceMin < sellPriceMax);
        }
        if(buyPriceMin > 0 && sellPriceMax > 0)
        {
            require(buyPriceMin >= sellPriceMax);
        }
        voteType = VoteType.CHANGE_BUY_SELL_LIMITS;
        changeBuySellLimitsVoteData.buyPriceMin = buyPriceMin;
        changeBuySellLimitsVoteData.buyPriceMax = buyPriceMax;
        changeBuySellLimitsVoteData.sellPriceMin = sellPriceMin;
        changeBuySellLimitsVoteData.sellPriceMax = sellPriceMax;
        internalStartVoting();
    }
    
    function startVotingForChangeBuySellPrice(
        uint buyPrice, 
        uint buyAddUnits, 
        uint sellPrice, 
        uint sellAddUnits, 
        bool ignoreSecurityLimits
    )
        external onlyAdmin startVoting
    {
        require(buyPrice >= sellPrice);
        require(sellAddUnits * sellPrice <= weiFromExchange);
        voteType = VoteType.CHANGE_BUY_SELL_PRICE;
        changeBuySellPriceVoteData.buyPrice = buyPrice;
        changeBuySellPriceVoteData.buyAddUnits = buyAddUnits;
        changeBuySellPriceVoteData.sellPrice = sellPrice;
        changeBuySellPriceVoteData.sellAddUnits = sellAddUnits;
        changeBuySellPriceVoteData.ignoreSecurityLimits = ignoreSecurityLimits;
        internalStartVoting();
    }
    
    function startVotingForSendWeiFromExchange(
        address addressTo, 
        uint amount
    )
        external onlyAdmin startVoting
    {
        require(amount <= weiFromExchange);
        voteType = VoteType.SEND_WEI_FROM_EXCHANGE;
        sendWeiFromExchangeVoteData.addressTo = addressTo;
        sendWeiFromExchangeVoteData.amount = amount;
        internalStartVoting();
    }
    
    function startVotingForSendWeiFromPayment(
        address addressTo, 
        uint amount
    )
        external onlyAdmin startVoting
    {
        uint balance = address(this).balance.sub(weiFromExchange);
        require(amount <= balance && amount <= weiForPayment);
        voteType = VoteType.SEND_WEI_FROM_PAYMENT;
        sendWeiFromPaymentVoteData.addressTo = addressTo;
        sendWeiFromPaymentVoteData.amount = amount;
        internalStartVoting();
    }
    
    function startVotingForTransferWeiFromExchangeToPayment(
        bool reverse,
        uint amount
    )
        external onlyAdmin startVoting
    {
        if(reverse)
        {
            require(amount <= weiForPayment);
        }
        else
        {
            require(amount <= weiFromExchange);
        }
        voteType = VoteType.TRANSFER_EXCHANGE_WEI_TO_PAYMENT; 
        transferWeiFromExchangeToPaymentVoteData.reverse = reverse;
        transferWeiFromExchangeToPaymentVoteData.amount = amount;
        internalStartVoting();
    }
    
    function startVotingForStartPayment(
        uint weiToShare,
        uint date
    )
        external onlyAdmin startVoting
    {
        require(weiToShare > 0 && weiToShare <= weiForPayment);
        voteType = VoteType.START_PAYMENT;
        startPaymentVoteData.weiToShare = weiToShare;
        startPaymentVoteData.date = date;
        internalStartVoting();
    }
    
     function voteForCurrent(bool voteYes)
        external onlyAdmin
    {
        require(voteType != VoteType.NONE);
        VoteData storage d = balances[msg.sender].vote;
        // already voted
        if(d.lastVoteId == voteId)
        {
            // ...but changed mind
            if(voteYes != d.voteYes)
            {
                if(voteYes)
                {
                    votesTotalYes = votesTotalYes.add(1);
                    votesTotalNo = votesTotalNo.sub(1);
                }
                else
                {
                    votesTotalYes = votesTotalYes.sub(1);
                    votesTotalNo = votesTotalNo.add(1);
                }
            }
        }
        // a new vote
        // adding 'else' costs more gas
        if(d.lastVoteId < voteId)
        {
            if(voteYes)
            {
                votesTotalYes = votesTotalYes.add(1);
            }
            else
            {
                votesTotalNo = votesTotalNo.add(1);
            }
        }
        // 5 / 10 means something is voted out
        if(votesTotalYes.mul(10).div(3) > 5)
        {
            // adding 'else' for each vote type costs more gas
            if(voteType == VoteType.ALLOW_TRANSFER)
            {
                internalAllowTransfer(
                    allowTransferVoteData.addressTo, 
                    allowTransferVoteData.amount
                );
            }
            if(voteType == VoteType.CHANGE_ADMIN_WALLET)
            {
                internalChangeAdminWallet(
                    changeAdminAddressVoteData.index, 
                    changeAdminAddressVoteData.adminAddress
                );
            }
            if(voteType == VoteType.CHANGE_BUY_SELL_LIMITS)
            {
                internalChangeBuySellLimits(
                    changeBuySellLimitsVoteData.buyPriceMin, 
                    changeBuySellLimitsVoteData.buyPriceMax, 
                    changeBuySellLimitsVoteData.sellPriceMin, 
                    changeBuySellLimitsVoteData.sellPriceMax
                );
            }
            if(voteType == VoteType.CHANGE_BUY_SELL_PRICE)
            {
                internalChangeBuySellPrice(
                    changeBuySellPriceVoteData.buyPrice, 
                    changeBuySellPriceVoteData.buyAddUnits, 
                    changeBuySellPriceVoteData.sellPrice, 
                    changeBuySellPriceVoteData.sellAddUnits,
                    changeBuySellPriceVoteData.ignoreSecurityLimits
                );
            }
            if(voteType == VoteType.SEND_WEI_FROM_EXCHANGE)
            {
                internalSendWeiFromExchange(
                    sendWeiFromExchangeVoteData.addressTo, 
                    sendWeiFromExchangeVoteData.amount
                );
            }
            if(voteType == VoteType.SEND_WEI_FROM_PAYMENT)
            {
                internalSendWeiFromPayment(
                    sendWeiFromPaymentVoteData.addressTo, 
                    sendWeiFromPaymentVoteData.amount
                );
            }
            if(voteType == VoteType.TRANSFER_EXCHANGE_WEI_TO_PAYMENT)
            {
                internalTransferExchangeWeiToPayment(
                    transferWeiFromExchangeToPaymentVoteData.reverse,
                    transferWeiFromExchangeToPaymentVoteData.amount
                );
            }
            if(voteType == VoteType.START_PAYMENT)
            {
                internalStartPayment(
                    startPaymentVoteData.weiToShare,
                    startPaymentVoteData.date
                );
            }
            voteType = VoteType.NONE;
            internalResetVotingData();
        }
        if(votesTotalNo.mul(10).div(3) > 5)
        {
            voteType = VoteType.NONE;
            internalResetVotingData();
        }
        d.voteYes = voteYes;
        d.lastVoteId = voteId;
    }
    
    function voteCancelCurrent() 
        external onlyAdmin
    {
        require(voteType != VoteType.NONE);
        VoteData storage d = balances[msg.sender].vote;
        if(d.lastVoteId <= voteId || !d.voteCancel)
        {
            d.voteCancel = true;
            d.lastVoteId = voteId;
            voteCancel++;
        }
        uint votesCalc = voteCancel.mul(10);
        // 3 admins
        votesCalc = votesCalc.div(3);
        // 5 / 10 means something is voted out
        if(votesCalc > 5)
        {
            voteType = VoteType.NONE;
            internalResetVotingData();
        }
    }
    
    function addEthForSell() 
        external payable onlyAdmin
    {
        require(msg.value > 0);
        weiFromExchange = weiFromExchange.add(msg.value);
    }
    
    function addEthForPayment() 
        external payable
    {
        weiForPayment = weiForPayment.add(msg.value);
    }
    
    function buyEPU() 
    public payable
    {
        // how many units has client bought
        uint amount = msg.value.div(weiBuyPrice);
        uint b = balances[buyBalanceAdmin].balance;
        // can't buy more than main account balance
        if(amount >= b)
        {
            amount = b;
        }
        // the needed price for bought units
        uint price = amount.mul(weiBuyPrice);
        weiFromExchange = weiFromExchange.add(price);
        if(amount > 0)
        {
            buySum.price = buySum.price.add(price);
            buySum.amount = buySum.amount.add(amount);
            internalAllowTransfer(msg.sender, amount);
           // send units to client
            internalTransfer(buyBalanceAdmin, msg.sender, amount);
            // emit event
            emit UnitsBuy(msg.sender, amount);
            //buyBalanceAdmin.transfer(price); 
        }
        // if client sent more than needed
        if(msg.value > price)
        {
            // send him the rest back
            msg.sender.transfer(msg.value.sub(price));
        }
    }
    
    function sellEPU(uint amount) 
        external payable 
        returns(uint revenue)
    {
        require(amount > 0);
        uint fixedAmount = amount;
        BalanceData storage b = balances[msg.sender];
        uint balance = b.balance;
        uint max = balance < unitsToSell ? balance : unitsToSell;
        if(fixedAmount > max)
        {
            fixedAmount = max;
        }
        uint price = fixedAmount.mul(weiSellPrice);
        require(price > 0 && price <= weiFromExchange);
        sellSum.price = sellSum.price.add(price);
        sellSum.amount = sellSum.amount.add(amount);
        internalTransfer(msg.sender, sellBalanceAdmin, fixedAmount);
        weiFromExchange = weiFromExchange.sub(price);
        emit UnitsSell(msg.sender, fixedAmount);
        msg.sender.transfer(price);
        return price;
    }
    
    function checkPayment() 
        external
    {
        internalCheckPayment(msg.sender);
    }
    
    function checkPaymentFor(
        address person
    )
        external
    {
        internalCheckPayment(person);
    }
    
    function accountData() 
        external view 
        returns (
            uint unitsBalance, 
            uint payableUnits, 
            uint totalWeiToReceive, 
            uint weiBuyPriceForUnit, 
            uint buyUnitsLeft, 
            uint weiSellPriceForUnit, 
            uint sellUnitsLeft
        )
    {
        BalanceData storage b = balances[msg.sender];
        unitsBalance = b.balance;
        if(b.balancePaymentSeries < paymentSeries)
        {
            payableUnits = unitsBalance;
            for(uint i = 0; i <= paymentSortId; i++)
            {
                totalWeiToReceive = totalWeiToReceive.add(getPaymentWeiPerUnit(i).mul(payableUnits));
            }
        }
        else
        {
            (totalWeiToReceive, payableUnits) = getAddressWeiFromPayments(b);
        }
        weiBuyPriceForUnit = weiBuyPrice;
        buyUnitsLeft = balances[buyBalanceAdmin].balance;
        weiSellPriceForUnit = weiSellPrice;
        sellUnitsLeft = unitsToSell;
    }
    
    function getBuyUnitsInformations() 
        external view 
        returns(
            uint weiBuyPriceForUnit, 
            uint unitsLeft
        )
    {
        weiBuyPriceForUnit = weiBuyPrice;
        unitsLeft = balances[buyBalanceAdmin].balance;
    }
    
    function getSellUnitsInformations() 
        external view 
        returns(
            uint weiSellPriceForUnit, 
            uint unitsLeft
        )
    {
        weiSellPriceForUnit = weiSellPrice;
        unitsLeft = unitsToSell;
    }
    
    function checkVotingForAllowTransfer() 
        external view onlyAdmin 
        returns(
            address allowTo, 
            uint amount, 
            uint votesYes, 
            uint votesNo, 
            bool stillActive
        )
    {
        require(voteType == VoteType.ALLOW_TRANSFER);
        return (
            allowTransferVoteData.addressTo, 
            allowTransferVoteData.amount, 
            votesTotalYes, 
            votesTotalNo, 
            voteType == VoteType.ALLOW_TRANSFER
        );
    }
    
    function checkVotingForChangeAdminAddress() 
        external view onlyAdmin 
        returns(
            uint adminId, 
            address newAdminAddress, 
            uint votesYes, 
            uint votesNo, 
            bool stillActive
        )
    {
        require(voteType == VoteType.CHANGE_ADMIN_WALLET);
        return (
            changeAdminAddressVoteData.index, 
            changeAdminAddressVoteData.adminAddress, 
            votesTotalYes, 
            votesTotalNo, 
            voteType == VoteType.CHANGE_ADMIN_WALLET
        );
    }
    
    function checkVotingForChangeBuySellLimits() 
        external view onlyAdmin 
        returns(
            uint buyPriceMin, 
            uint buyPriceMax, 
            uint sellPriceMin, 
            uint sellPriceMax, 
            uint votesYes, 
            uint votesNo, 
            bool stillActive
        )
    {
        require(voteType == VoteType.CHANGE_BUY_SELL_LIMITS);
        return (
            changeBuySellLimitsVoteData.buyPriceMin,
            changeBuySellLimitsVoteData.buyPriceMax, 
            changeBuySellLimitsVoteData.sellPriceMin, 
            changeBuySellLimitsVoteData.sellPriceMax, 
            votesTotalYes, 
            votesTotalNo, 
            voteType == VoteType.CHANGE_BUY_SELL_LIMITS
        );
    }
    
    function checkVotingForChangeBuySellPrice() 
        external view onlyAdmin
        returns(
            uint buyPrice, 
            uint buyAddUnits, 
            uint sellPrice, 
            uint sellAddUnits, 
            bool ignoreSecurityLimits, 
            uint votesYes, 
            uint votesNo, 
            bool stillActive
        )
    {
        require(voteType == VoteType.CHANGE_BUY_SELL_PRICE);
        return (
            changeBuySellPriceVoteData.buyPrice, 
            changeBuySellPriceVoteData.buyAddUnits, 
            changeBuySellPriceVoteData.sellPrice, 
            changeBuySellPriceVoteData.sellAddUnits, 
            changeBuySellPriceVoteData.ignoreSecurityLimits, 
            votesTotalYes, 
            votesTotalNo, 
            voteType == VoteType.CHANGE_BUY_SELL_PRICE
        );
    }
    
    function checkVotingForSendWeiFromExchange() 
        external view onlyAdmin 
        returns(
            address addressTo, 
            uint weiAmount, 
            uint votesYes, 
            uint votesNo, 
            bool stillActive
        )
    {
        require(voteType == VoteType.SEND_WEI_FROM_EXCHANGE);
        return (
            sendWeiFromExchangeVoteData.addressTo, 
            sendWeiFromExchangeVoteData.amount, 
            votesTotalYes, 
            votesTotalNo, 
            voteType == VoteType.SEND_WEI_FROM_EXCHANGE
        );
    }
    
    function checkVotingForSendWeiFromPayment() 
        external view onlyAdmin
        returns(
            address addressTo, 
            uint weiAmount, 
            uint votesYes, 
            uint votesNo, 
            bool stillActive
        )
    {
        require(voteType == VoteType.SEND_WEI_FROM_PAYMENT);
        return (
            sendWeiFromPaymentVoteData.addressTo, 
            sendWeiFromPaymentVoteData.amount, 
            votesTotalYes, 
            votesTotalNo, 
            voteType == VoteType.SEND_WEI_FROM_PAYMENT
        );
    }
    
    function checkVotingForTransferWeiFromExchangeToPayment() 
        external view onlyAdmin
        returns (
            bool reverse,
            uint amount, 
            uint votesYes, 
            uint votesNo, 
            bool stillActive
        )
    {
        require(voteType == VoteType.TRANSFER_EXCHANGE_WEI_TO_PAYMENT);
        return (
            transferWeiFromExchangeToPaymentVoteData.reverse,
            transferWeiFromExchangeToPaymentVoteData.amount, 
            votesTotalYes, 
            votesTotalNo, 
            voteType == VoteType.TRANSFER_EXCHANGE_WEI_TO_PAYMENT
        );
    }
    
    function checkVotingForStartPayment() 
        external view onlyAdmin 
        returns(
            uint weiToShare, 
            uint date,
            uint votesYes, 
            uint votesNo, 
            bool stillActive
        )
    {
        require(voteType == VoteType.START_PAYMENT);
        return (
            startPaymentVoteData.weiToShare, 
            startPaymentVoteData.date,
            votesTotalYes, 
            votesTotalNo, 
            voteType == VoteType.START_PAYMENT
        );
    }
    
    
    function totalSupply() 
        public constant 
        returns (uint)
    {
        return maxUnits - balances[mainBalanceAdmin].balance;
    }
    
    
     //  important to display balance in the wallet.
    function balanceOf(address unitOwner) 
        public constant 
        returns (uint balance) 
    {
        balance = balances[unitOwner].balance;
    }
    
    function transferFrom(
        address from, 
        address to, uint units
    ) 
        public 
        returns (bool success) 
    {
        BalanceData storage b = balances[from];
        uint a = b.allowed[msg.sender];
        a = a.sub(units);
        b.allowed[msg.sender] = a;
        success = internalTransfer(from, to, units);
    }
    
    function approve(
        address spender, 
        uint units
    ) 
        public 
        returns (bool success) 
    {
        balances[msg.sender].allowed[spender] = units;
        emit Approval(msg.sender, spender, units);
        success = true;
    }
    
    function allowance(
        address unitOwner, 
        address spender
    ) 
        public constant 
        returns (uint remaining) 
    {
        remaining = balances[unitOwner].allowed[spender];
    }
    
    function transfer(
        address to, 
        uint value
    ) 
        public 
        returns (bool success)
    {
        return internalTransfer(msg.sender, to, value);
    }
    
    function getMaskForPaymentBytes() private pure returns(bytes32)
    {
        return bytes32(uint(2**32 - 1));
    }
    
    function getPaymentBytesIndexSize(uint index) private pure returns (uint)
    {
        return 32 * index;
    }
    
    function getPaymentWeiPerUnit(uint index) private view returns(uint weiPerUnit)
    {
        bytes32 mask = getMaskForPaymentBytes();
        uint offsetIndex = getPaymentBytesIndexSize(index);
        mask = shiftLeft(mask, offsetIndex);
        bytes32 before = paymentHistory & mask;
        weiPerUnit = uint(shiftRight(before, offsetIndex)).mul(1000000000000);
    }
    
    //bytes32 private dataBytes;
    
    function getMask() private pure returns (bytes32)
    {
        return bytes32(uint(2**32 - 1));
    }
    
    function getBitIndex(uint index) private pure returns (uint)
    {
        return 32 * index;
    }
    
    function shiftLeft (bytes32 a, uint n) private pure returns (bytes32) 
    {
        uint shifted = uint(a) * 2 ** uint(n);
        return bytes32(shifted);
    }
    
    function shiftRight (bytes32 a, uint n) private pure returns (bytes32) 
    {
        uint shifted = uint(a) / 2  ** uint(n);
        return bytes32(shifted);
    }
    
    function internalStartVoting() 
        private onlyAdmin
    {
        internalResetVotingData();
        voteId = voteId.add(1);
    }
    
    function internalResetVotingData() 
        private onlyAdmin
    {
        votesTotalYes = 0;
        votesTotalNo = 0;
        voteCancel = 0;
    }
    
    function internalAllowTransfer(
        address from, 
        uint amount
    ) 
        private
    {
        BalanceData storage b = balances[from];
        b.transferAllowed = b.transferAllowed.add(amount);
    }
    
    function internalChangeAdminWallet(
        uint index, 
        address addr
    ) 
        private onlyAdmin
    {
        // adding 'else' for each index costs more gas
        if(index == 0)
        {
            internalTransferAccount(mainBalanceAdmin, addr);
            mainBalanceAdmin = addr;
        }
        if(index == 1)
        {
            internalTransferAccount(buyBalanceAdmin, addr);
            buyBalanceAdmin = addr;
        }
        if(index == 2)
        {
            internalTransferAccount(sellBalanceAdmin, addr);
            sellBalanceAdmin = addr;
        }
    }
    
    function internalAddBuyUnits(
        uint price, 
        uint addUnits, 
        bool ignoreLimits
    ) 
        private onlyAdmin
    {
        if(price > 0)
        {
            weiBuyPrice = price;
            if(!ignoreLimits && securityWeiBuyPriceFrom > 0 && weiBuyPrice < securityWeiBuyPriceFrom)
            {
                weiBuyPrice = securityWeiBuyPriceFrom;
            }
            if(!ignoreLimits && securityWeiBuyPriceTo > 0 && weiBuyPrice > securityWeiBuyPriceTo)
            {
                weiBuyPrice = securityWeiBuyPriceTo;
            }
        }
        if(addUnits > 0)
        {
            uint b = balances[mainBalanceAdmin].balance;
            if(addUnits > b)
            {
                addUnits = b;
            }
            internalAllowTransfer(buyBalanceAdmin, addUnits);
            internalTransfer(mainBalanceAdmin, buyBalanceAdmin, addUnits);
        }
        emit OnExchangeBuyUpdate(weiBuyPrice, balances[buyBalanceAdmin].balance);
    }
    
    function internalAddSellUnits(
        uint price, 
        uint addUnits, 
        bool ignoreLimits
    ) 
        private onlyAdmin
    {
        if(price > 0)
        {
            weiSellPrice = price;
            if(!ignoreLimits)
            {
                if(securityWeiSellPriceFrom > 0 && weiSellPrice < securityWeiSellPriceFrom)
                {
                    weiSellPrice = securityWeiSellPriceFrom;
                }
                if(securityWeiSellPriceTo > 0 && weiSellPrice > securityWeiSellPriceTo)
                {
                    weiSellPrice = securityWeiSellPriceTo;
                }   
            }
        }
        if(addUnits > 0)
        {
            unitsToSell = unitsToSell.add(addUnits);
            //uint requireWei = unitsToSell * weiSellPrice;
            uint maxUnitsAccountCanBuy = sellBalanceAdmin.balance.div(weiSellPrice);
            if(unitsToSell > maxUnitsAccountCanBuy)
            {
                unitsToSell = maxUnitsAccountCanBuy;
            }
            //internalTransfer(mainBalanceAdmin, sellBalanceAdmin, unitsToSell);
            //balances[mainBalanceAdmin] = balances[mainBalanceAdmin].sub(unitsToSell);
        }
        emit OnExchangeSellUpdate(weiSellPrice, unitsToSell);
    }
    
    function internalChangeBuySellLimits(
        uint buyPriceMin, 
        uint buyPriceMax, 
        uint sellPriceMin, 
        uint sellPriceMax
    ) 
        private onlyAdmin
    {
        if(buyPriceMin > 0)
        {
            securityWeiBuyPriceFrom = buyPriceMin;
        }
        if(buyPriceMax > 0)
        {
            securityWeiBuyPriceTo = buyPriceMax;
        }
        if(sellPriceMin > 0)
        {
            securityWeiSellPriceFrom = sellPriceMin;
        }
        if(sellPriceMax > 0)
        {
            securityWeiSellPriceTo = sellPriceMax;
        }
    }
    
    function internalChangeBuySellPrice(
        uint buyPrice, 
        uint buyAddUnits, 
        uint sellPrice, 
        uint sellAddUnits, 
        bool ignoreSecurityLimits
    ) 
        private onlyAdmin
    {
        internalAddBuyUnits(buyPrice, buyAddUnits, ignoreSecurityLimits);
        internalAddSellUnits(sellPrice, sellAddUnits, ignoreSecurityLimits);
    }
    
    // Executed when there is too much wei on the exchange
    function internalSendWeiFromExchange(
        address addressTo, 
        uint amount
    ) 
        private onlyAdmin
    {
        internalRemoveWeiFromExchange(amount);
        addressTo.transfer(amount);
    }
    
    function internalTransferExchangeWeiToPayment(bool reverse, uint amount)
        private onlyAdmin
    {
        if(reverse)
        {
            weiFromExchange = weiFromExchange.add(amount);
            weiForPayment = weiForPayment.sub(amount);
        }
        else
        {
            internalRemoveWeiFromExchange(amount);
            weiForPayment = weiForPayment.add(amount);
        }
    }
    
    function internalRemoveWeiFromExchange(uint amount) 
        private onlyAdmin
    {
        weiFromExchange = weiFromExchange.sub(amount);
        uint units = weiFromExchange.div(weiSellPrice);
        if(units < unitsToSell)
        {
            unitsToSell = units;
        }
    }
    
    function internalSendWeiFromPayment(
        address addressTo,
        uint amount
    ) 
        private onlyAdmin
    {
        weiForPayment = weiForPayment.sub(amount);
        addressTo.transfer(amount);
    }
    
    function getAmountOfUnitsOnPaymentId(
        BalanceData storage b, 
        uint index
    ) 
        private view
        returns(uint)
    {
        bytes32 mask = getMask();
        uint offsetIndex = getBitIndex(index);
        mask = shiftLeft(mask, offsetIndex);
        bytes32 before = b.paymentBalances & mask;
        before = shiftRight(before, offsetIndex);
        uint r = uint(before);
        // special case of error
        if(r > amountOfUnitsOutsideAdminWallet)
        {
            return 0;
        }
        return r;
    }
    
    function setAmountOfUnitsOnPaymentId(
        BalanceData storage b, 
        uint index,
        uint value
    )
    private
    {
        bytes32 mask = getMask();
        uint offsetIndex = getBitIndex(index);
        mask = shiftLeft(mask, offsetIndex);
        b.paymentBalances = (b.paymentBalances ^ mask) & b.paymentBalances;
        bytes32 field = bytes32(value);
        field = shiftLeft(field, offsetIndex);
        b.paymentBalances = b.paymentBalances | field;
    }
    
    function internalTransferAccount(
        address addrA, 
        address addrB
    ) 
        private onlyAdmin
    {
        if(addrA != 0x0 && addrB != 0x0)
        {
            BalanceData storage from = balances[addrA];
            BalanceData storage to = balances[addrB];

            if(from.balancePaymentSeries < paymentSeries)
            {
                from.paymentBalances = bytes32(0);
                setAmountOfUnitsOnPaymentId(from, 0, from.balance);
                from.balancePaymentSeries = paymentSeries;
            }
            
            if(to.balancePaymentSeries < paymentSeries)
            {
                to.paymentBalances = bytes32(0);
                setAmountOfUnitsOnPaymentId(to, 0, to.balance);
                to.balancePaymentSeries = paymentSeries;
            }

            uint nextPaymentFirstUnits = getAmountOfUnitsOnPaymentId(from, 0);
            setAmountOfUnitsOnPaymentId(from, 0, 0);
            setAmountOfUnitsOnPaymentId(to, 1, nextPaymentFirstUnits);
            for(uint i = 0; i <= 5; i++)
            {
                uint existingUnits = getAmountOfUnitsOnPaymentId(from, i);
                existingUnits = existingUnits.add(getAmountOfUnitsOnPaymentId(to, i));
                
                setAmountOfUnitsOnPaymentId(from, i, 0);
                setAmountOfUnitsOnPaymentId(to, i, existingUnits);
            }
            to.balance = to.balance.add(from.balance);
            from.balance = 0;
        }
    }
    
    // metamask error with start payment? Ensure if it's not dividing by 0!
    
    function internalStartPayment(uint weiTotal, uint date) 
        private onlyAdmin
    {
        require(weiTotal >= amountOfUnitsOutsideAdminWallet);
        paymentNumber = paymentNumber.add(1);
        paymentSortId = paymentNumber % 6;
        if(paymentSortId == 0)
        {
            paymentHistory = bytes32(0);
            paymentSeries = paymentSeries.add(1);
            
            uint weiLeft = totalAmountOfWeiOnPaymentsPerSeries.sub(totalAmountOfWeiPaidToUsersPerSeries);
            if(weiLeft > 0)
            {
                weiForPayment = weiForPayment.add(weiLeft);
            }
            totalAmountOfWeiPaidToUsersPerSeries = 0;
            totalAmountOfWeiOnPaymentsPerSeries = 0;
        }
        buySum.price = 0;
        buySum.amount = 0;
        sellSum.price = 0;
        sellSum.amount = 0;
        bytes32 mask = getMaskForPaymentBytes();
        uint offsetIndex = getPaymentBytesIndexSize(paymentSortId);
        mask = shiftLeft(mask, offsetIndex);
        paymentHistory = (paymentHistory ^ mask) & paymentHistory;
        // amount of microether (1 / 1 000 000 eth)  per unit
        bytes32 field = bytes32((weiTotal.div(1000000000000)).div(amountOfUnitsOutsideAdminWallet));
        field = shiftLeft(field, offsetIndex);
        paymentHistory = paymentHistory | field;
        weiForPayment = weiForPayment.sub(weiTotal);
        totalAmountOfWeiOnPaymentsPerSeries = totalAmountOfWeiOnPaymentsPerSeries.add(weiTotal);
        internalCheckPayment(buyBalanceAdmin);
        internalCheckPayment(sellBalanceAdmin);
        lastPaymentDate = date;
        emit NewPayment(paymentNumber, weiTotal, amountOfUnitsOutsideAdminWallet, lastPaymentDate);
    }
    
    function internalCheckPayment(address person) 
        private
    {
        require(person != mainBalanceAdmin);
        BalanceData storage b = balances[person];
        if(b.balancePaymentSeries < paymentSeries)
        {
            b.balancePaymentSeries = paymentSeries;
            b.paymentBalances = bytes32(b.balance);
        }
        (uint weiToSendSum, uint unitsReceived) = getAddressWeiFromPayments(b);
        b.paymentBalances = bytes32(0);
        setAmountOfUnitsOnPaymentId(b, paymentSortId.add(1), b.balance);
        if(weiToSendSum > 0)
        {
            totalAmountOfWeiPaidToUsers = totalAmountOfWeiPaidToUsers.add(weiToSendSum);
            totalAmountOfWeiPaidToUsersPerSeries = totalAmountOfWeiPaidToUsersPerSeries.add(weiToSendSum);
            emit PaymentReceived(person, paymentNumber, weiToSendSum, unitsReceived);
            person.transfer(weiToSendSum);   
        }
    }
    
    function getAddressWeiFromPayments(BalanceData storage b)
        private view
        returns(uint weiSum, uint unitsSum)
    {
        for(uint i = 0; i <= paymentSortId; i++)
        {
            unitsSum = unitsSum.add(getAmountOfUnitsOnPaymentId(b, i));
            weiSum = weiSum.add(getPaymentWeiPerUnit(i).mul(unitsSum));
        }
    }
    
    function proceedTransferFromMainAdmin(BalanceData storage bT, uint value)
        private
    {
        if(bT.balancePaymentSeries < paymentSeries)
        {
            bT.paymentBalances = bytes32(0);
            setAmountOfUnitsOnPaymentId(bT, 0, bT.balance);
            bT.balancePaymentSeries = paymentSeries;
        }
        amountOfUnitsOutsideAdminWallet = amountOfUnitsOutsideAdminWallet.add(value);   
        uint fixedNewPayment = paymentNumber.add(1);
        uint curr = getAmountOfUnitsOnPaymentId(bT, fixedNewPayment).add(value);
        setAmountOfUnitsOnPaymentId(bT, fixedNewPayment, curr);
    }
    
    function proceedTransferToMainAdmin(BalanceData storage bF, uint value)
        private
    {
        amountOfUnitsOutsideAdminWallet = amountOfUnitsOutsideAdminWallet.sub(value);
        if(bF.balancePaymentSeries < paymentSeries)
        {
            bF.paymentBalances = bytes32(0);
            setAmountOfUnitsOnPaymentId(bF, 0, bF.balance);
            bF.balancePaymentSeries = paymentSeries;
        }
        uint maxVal = paymentSortId.add(1);
        for(uint i = 0; i <= maxVal; i++)
        {
            uint v = getAmountOfUnitsOnPaymentId(bF, i);
            if(v >= value)
            {
                setAmountOfUnitsOnPaymentId(bF, i, v.sub(value));
                break;
            }
            value = value.sub(v);
            setAmountOfUnitsOnPaymentId(bF, i, 0);
        }
    }
    
    function proceedTransferFromUserToUser(BalanceData storage bF, BalanceData storage bT, uint value)
        private
    {
        if(bF.balancePaymentSeries < paymentSeries)
        {
            bF.paymentBalances = bytes32(0);
            setAmountOfUnitsOnPaymentId(bF, 0, bF.balance);
            bF.balancePaymentSeries = paymentSeries;
        }
        if(bT.balancePaymentSeries < paymentSeries)
        {
            bT.paymentBalances = bytes32(0);
            setAmountOfUnitsOnPaymentId(bT, 0, bT.balance);
            bT.balancePaymentSeries = paymentSeries;
        }
        uint maxVal = paymentSortId.add(1);
        for(uint i = 0; i <= maxVal; i++)
        {
            uint fromAmount = getAmountOfUnitsOnPaymentId(bF, i);
            uint toAmount = getAmountOfUnitsOnPaymentId(bT, i);
            if(fromAmount >= value)
            {
                setAmountOfUnitsOnPaymentId(bT, i, toAmount.add(value));
                setAmountOfUnitsOnPaymentId(bF, i, fromAmount.sub(value));
                break;
            }
            value = value.sub(fromAmount);
            setAmountOfUnitsOnPaymentId(bT, i, toAmount.add(fromAmount));
            setAmountOfUnitsOnPaymentId(bF, i, 0);
        }
    }
    
    function internalTransfer(
        address from, 
        address to, 
        uint value
    ) 
        private 
        returns (bool success)
    {
        BalanceData storage bF = balances[from];
        BalanceData storage bT = balances[to];
        if(to == 0x0 || bF.balance < value)
        {
            return false;
        }
        bool fromMainAdmin = from == mainBalanceAdmin;
        bool fromAdminToNonAdmin = isAdmin(from) && !isAdmin(to);
        if(fromMainAdmin || fromAdminToNonAdmin)
        {
            assert(bT.transferAllowed > 0);
            if(value > bT.transferAllowed)
            {
                value = bT.transferAllowed;
            }
            bT.transferAllowed = bT.transferAllowed.sub(value);
        }
        if(to == sellBalanceAdmin)
        {
            require(unitsToSell > 0);
            if(value > unitsToSell)
            {
                value = unitsToSell;
            }
            unitsToSell = unitsToSell.sub(value);
        }
        
        if(fromMainAdmin)
        {
            proceedTransferFromMainAdmin(bT, value);
            emit OnEmitNewUnitsFromMainWallet(value, amountOfUnitsOutsideAdminWallet);
        }
        else if(to == mainBalanceAdmin)
        {
            proceedTransferToMainAdmin(bF, value);
            emit OnAddNewUnitsToMainWallet(value, amountOfUnitsOutsideAdminWallet);
        }
        else
        {
            proceedTransferFromUserToUser(bF, bT, value);
        }
        bF.balance = bF.balance.sub(value);
        bT.balance = bT.balance.add(value);
        emit Transfer(from, to, value);
        return true;
    }
    
    function isAdmin(address  person) private view 
    returns(bool)
    {
        return (person == mainBalanceAdmin || person == buyBalanceAdmin || person == sellBalanceAdmin);
    }
}