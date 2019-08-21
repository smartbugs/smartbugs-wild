pragma solidity ^0.4.25;

/** KPI is 100k USD (~ETH rate fix at start of contract) target selling period is 45 days*/

/** If NCryptBit reached 100k before 45 days -> payoff immediately 10% commission through `claim` function */

/** 
Pay 4k USD (in ETH) first installment of comission fee immediately after startTime (confirm purchased) `ONE day` (through claimFirstInstallment())

Remaining installment fee will be paid dependTime on KPI below:
    
    - Trunk payment period when reach partial KPI
        * 0 -> 15 date reach >=25k -> 1/3 Remaining Installment Fee (~2k USD)
        * 15 -> 30 date reach >=25k -> 1/3 Remaining Installment Fee (~2k USD)
        * 45  reach >=25k -> 1/3 Remaining Installment Fee (~2k USD)
        
    NOTE: Remaining ETH will refund to Triip through `refund` function at endTime of this campaign
*/

contract TriipInvestorsServices {

    event ConfirmPurchase(address _sender, uint _startTime, uint _amount);

    event Payoff(address _seller, uint _amount, uint _kpi);
    
    event Refund(address _buyer, uint _amount);

    event Claim(address _sender, uint _counting, uint _buyerWalletBalance);

    enum PaidStage {
        NONE,
        FIRST_PAYMENT,
        SECOND_PAYMENT,
        FINAL_PAYMENT
    }

    uint public KPI_0k = 0;
    uint public KPI_25k = 25;
    uint public KPI_50k = 50;
    uint public KPI_100k = 100;    
    
    address public seller; // NCriptBit
    address public buyer;  // Triip Protocol wallet use for refunding
    address public buyerWallet; // Triip Protocol's raising ETH wallet
    
    uint public startTime = 0;
    uint public endTime = 0;
    bool public isEnd = false;    

    uint decimals = 18;
    uint unit = 10 ** decimals;
    
    uint public paymentAmount = 69 * unit;                // 69 ETH equals to 10k USD upfront, fixed at deploy of contract manually
    uint public targetSellingAmount = 10 * paymentAmount; // 690 ETH equals to 100k USD upfront
    
    uint claimCounting = 0;

    PaidStage public paidStage = PaidStage.NONE;

    uint public balance;

    // Begin: only for testing

    // function setPaymentAmount(uint _paymentAmount) public returns (bool) {
    //     paymentAmount = _paymentAmount;
    //     return true;
    // }

    // function setStartTime(uint _startTime) public returns (bool) {
    //     startTime = _startTime;
    //     return true;
    // }

    // function setEndTime(uint _endTime) public returns (bool) {
    //     endTime = _endTime;
    //     return true;
    // }

    // function getNow() public view returns (uint) {
    //     return now;
    // }

    // End: only for testing

    constructor(address _buyer, address _seller, address _buyerWallet) public {

        seller = _seller;
        buyer = _buyer;
        buyerWallet = _buyerWallet;

    }

    modifier whenNotEnd() {
        require(!isEnd, "This contract should not be endTime") ;
        _;
    }

    function confirmPurchase() public payable { // Trigger by Triip with the ETH amount agreed for installment

        require(startTime == 0);

        require(msg.value == paymentAmount, "Not equal installment fee");

        startTime = now;

        endTime = startTime + ( 45 * 1 days );

        balance += msg.value;

        emit ConfirmPurchase(msg.sender, startTime, balance);
    }

    function contractEthBalance() public view returns (uint) {

        return balance;
    }

    function buyerWalletBalance() public view returns (uint) {
        
        return address(buyerWallet).balance;
    }

    function claimFirstInstallment() public whenNotEnd returns (bool) {

        require(paidStage == PaidStage.NONE, "First installment has already been claimed");

        require(now >= startTime + 1 days, "Require first installment fee to be claimed after startTime + 1 day");

        uint payoffAmount = balance * 40 / 100; // 40% of agreed commission

        // update balance
        balance = balance - payoffAmount; // ~5k gas as of writing

        seller.transfer(payoffAmount); // ~21k gas as of writing

        emit Payoff(seller, payoffAmount, KPI_0k );
        emit Claim(msg.sender, claimCounting, buyerWalletBalance());

        return true;
    }
    
    function claim() public whenNotEnd returns (uint) {

        claimCounting = claimCounting + 1;

        uint payoffAmount = 0;

        uint sellingAmount  = targetSellingAmount;
        uint buyerBalance = buyerWalletBalance();

        emit Claim(msg.sender, claimCounting, buyerWalletBalance());
        
        if ( buyerBalance >= sellingAmount ) {

            payoffAmount = balance;

            seller.transfer(payoffAmount);
            paidStage = PaidStage.FINAL_PAYMENT;

            balance = 0;
            endContract();

            emit Payoff(seller, payoffAmount, KPI_100k);

        }
        else {
            payoffAmount = claimByKPI();

        }

        return payoffAmount;
    }

    function claimByKPI() private returns (uint) {

        uint payoffAmount = 0;
        uint sellingAmount = targetSellingAmount;
        uint buyerBalance = buyerWalletBalance();

        if ( buyerBalance >= ( sellingAmount * KPI_50k / 100) 
            && now >= (startTime + ( 30 * 1 days) )
            ) {

            uint paidPercent = 66;

            if ( paidStage == PaidStage.NONE) {
                paidPercent = 66; // 66% of 6k installment equals 4k
            }else if( paidStage == PaidStage.FIRST_PAYMENT) {
                // 33 % of total balance
                // 50% of remaining balance
                paidPercent = 50;
            }

            payoffAmount = balance * paidPercent / 100;

            // update balance
            balance = balance - payoffAmount;

            seller.transfer(payoffAmount);

            emit Payoff(seller, payoffAmount, KPI_50k);

            paidStage = PaidStage.SECOND_PAYMENT;
        }

        if( buyerBalance >= ( sellingAmount * KPI_25k / 100) 
            && now >= (startTime + (15 * 1 days) )
            && paidStage == PaidStage.NONE ) {

            payoffAmount = balance * 33 / 100;

            // update balance
            balance = balance - payoffAmount;

            seller.transfer(payoffAmount);

            emit Payoff(seller, payoffAmount, KPI_25k );

            paidStage = PaidStage.FIRST_PAYMENT;

        }

        if(now >= (startTime + (45 * 1 days) )) {

            endContract();
        }

        return payoffAmount;
    }

    function endContract() private {
        isEnd = true;
    }
    
    function refund() public returns (uint) {

        require(now >= endTime);

        // refund remaining balance
        uint refundAmount = address(this).balance;

        buyer.transfer(refundAmount);

        emit Refund(buyer, refundAmount);

        return refundAmount;
    }
}