pragma solidity ^0.4.25;

/**
Правила игр eSmart

* Процентная ставка 120%
* Фиксированный размер депозита; 0.05 eth, 0.1eth, 1eth
* Ежедневные старты, 5 раундов для каждой категории депозитов
* Распределение баланса
- 90% на выплаты участникам
- 7% делится поровну и распределяется между последними депозитами которые не прошли круг
(возврат 20% от депозита)
- 1% Джекпот
- 2% маркетинг и техническая поддержка

* Джекпот выигрывает участник который сделает больше всех транзакций с оборота за 5 раундов, в каждой категории отдельно.

* Раунд заканчивается через 10 минут от последней входящей транзакции на смарт контракт.

* eSmart предлагает самые эффективные умножители с высокой вероятностью прохождения круга!
* В играх eSmart нет проигравших, так как в каждом раунде все транзакции получают выплаты
- 77% первых транзакций 120% от депозита
- 23% последних транзакций в очереди 20% от депозита

* Играй в честные игры с eSmart

*/

contract ESmart {
    uint constant public INVESTMENT = 0.05 ether;
    uint constant private START_TIME = 1541435400; // 2018-11-05 19:30 MSK (GMT+3)

    //Address for tech expences
    address constant private TECH = 0x9A5B6966379a61388068bb765c518E5bC4D9B509;
    //Address for promo expences
    address constant private PROMO = 0xD6104cEca65db37925541A800870aEe09C8Fd78D;
    //Address for promo expences
    address constant private LAST_FUND = 0x357b9046f99eEC7E705980F328F00BAab4b3b6Be;
    //Percent for first multiplier donation
    uint constant public JACKPOT_PERCENT = 1;
    uint constant public TECH_PERCENT = 7; //0.7%
    uint constant public PROMO_PERCENT = 13; //1.3%
    uint constant public LAST_FUND_PERCENT = 10;
    uint constant public MAX_IDLE_TIME = 10 minutes; //Maximum time the deposit should remain the last to receive prize
    uint constant public NEXT_ROUND_TIME = 30 minutes; //Time to next round since the last deposit

    //How many percent for your deposit to be multiplied
    uint constant public MULTIPLIER = 120;

    //The deposit structure holds all the info about the deposit made
    struct Deposit {
        address depositor; //The depositor address
        uint128 deposit;   //The deposit amount
        uint128 expect;    //How much we should pay out (initially it is 120% of deposit)
    }

    struct LastDepositInfo {
        uint128 index;
        uint128 time;
    }

    struct MaxDepositInfo {
        address depositor;
        uint count;
    }

    Deposit[] private queue;  //The queue
    uint public currentReceiverIndex = 0; //The index of the first depositor in the queue. The receiver of investments!
    uint public currentQueueSize = 0; //The current size of queue (may be less than queue.length)
    LastDepositInfo public lastDepositInfo; //The time last deposit made at
    MaxDepositInfo public maxDepositInfo; //The pretender for jackpot
    uint private startTime = START_TIME;
    mapping(address => uint) public depCount; //Number of deposits made

    uint public jackpotAmount = 0; //Prize amount accumulated for the last depositor
    int public stage = 0; //Number of contract runs

    //This function receives all the deposits
    //stores them and make immediate payouts
    function () public payable {
        //If money are from first multiplier, just add them to the balance
        //All these money will be distributed to current investors
        if(msg.value > 0){
            require(gasleft() >= 220000, "We require more gas!"); //We need gas to process queue
            require(msg.value >= INVESTMENT, "The investment is too small!");
            require(stage < 5); //Only 5 rounds!!!

            checkAndUpdateStage();

            //Check that we can accept deposits
            require(getStartTime() <= now, "Deposits are not accepted before time");

            addDeposit(msg.sender, msg.value);

            //Pay to first investors in line
            pay();
        }else if(msg.value == 0){
            withdrawPrize();
        }
    }

    //Used to pay to current investors
    //Each new transaction processes 1 - 4+ investors in the head of queue
    //depending on balance and gas left
    function pay() private {
        //Try to send all the money on contract to the first investors in line
        uint balance = address(this).balance;
        uint128 money = 0;
        if(balance > (jackpotAmount)) //The opposite is impossible, however the check will not do any harm
            money = uint128(balance - jackpotAmount);

        //We will do cycle on the queue
        for(uint i=currentReceiverIndex; i<currentQueueSize; i++){

            Deposit storage dep = queue[i]; //get the info of the first investor

            if(money >= dep.expect){  //If we have enough money on the contract to fully pay to investor
                dep.depositor.send(dep.expect); //Send money to him
                money -= dep.expect;            //update money left

                //this investor is fully paid, so remove him
                delete queue[i];
            }else{
                //Here we don't have enough money so partially pay to investor
                dep.depositor.send(money); //Send to him everything we have
                dep.expect -= money;       //Update the expected amount
                break;                     //Exit cycle
            }

            if(gasleft() <= 50000)         //Check the gas left. If it is low, exit the cycle
                break;                     //The next investor will process the line further
        }

        currentReceiverIndex = i; //Update the index of the current first investor
    }

    function addDeposit(address depositor, uint value) private {
        require(stage < 5); //Only 5 rounds!!!
        //If you are applying for the prize you should invest more than minimal amount
        //Otherwize it doesn't count
        if(value > INVESTMENT){ //Fixed deposit
            depositor.transfer(value - INVESTMENT);
            value = INVESTMENT;
        }

        lastDepositInfo.index = uint128(currentQueueSize);
        lastDepositInfo.time = uint128(now);

        //Add the investor into the queue. Mark that he expects to receive 120% of deposit back
        push(depositor, value, value*MULTIPLIER/100);

        depCount[depositor]++;

        //Check if candidate for jackpot changed
        uint count = depCount[depositor];
        if(maxDepositInfo.count < count){
            maxDepositInfo.count = count;
            maxDepositInfo.depositor = depositor;
        }

        //Save money for prize and father multiplier
        jackpotAmount += value*(JACKPOT_PERCENT)/100;

        uint lastFund = value*LAST_FUND_PERCENT/100;
        LAST_FUND.send(lastFund);
        //Send small part to tech support
        uint support = value*TECH_PERCENT/1000;
        TECH.send(support);
        uint adv = value*PROMO_PERCENT/1000;
        PROMO.send(adv);

    }

    function checkAndUpdateStage() private{
        int _stage = getCurrentStageByTime();

        require(_stage >= stage, "We should only go forward in time");

        if(_stage != stage){
            proceedToNewStage(_stage);
        }
    }

    function proceedToNewStage(int _stage) private {
        //Clean queue info
        //The prize amount on the balance is left the same if not withdrawn
        startTime = getStageStartTime(_stage);
        assert(startTime > 0);
        stage = _stage;
        currentQueueSize = 0; //Instead of deleting queue just reset its length (gas economy)
        currentReceiverIndex = 0;
        delete lastDepositInfo;
    }

    function withdrawPrize() private {
        require(getCurrentStageByTime() >= 5); //Only after 5 rounds!
        require(maxDepositInfo.count > 0, "The max depositor is not confirmed yet");

        uint balance = address(this).balance;
        if(jackpotAmount > balance) //Impossible but better check it
            jackpotAmount = balance;

        maxDepositInfo.depositor.send(jackpotAmount);

        selfdestruct(TECH); //5 rounds are over, so we can clean the contract
    }

    //Pushes investor to the queue
    function push(address depositor, uint deposit, uint expect) private {
        //Add the investor into the queue
        Deposit memory dep = Deposit(depositor, uint128(deposit), uint128(expect));
        assert(currentQueueSize <= queue.length); //Assert queue size is not corrupted
        if(queue.length == currentQueueSize)
            queue.push(dep);
        else
            queue[currentQueueSize] = dep;

        currentQueueSize++;
    }

    //Get the deposit info by its index
    //You can get deposit index from
    function getDeposit(uint idx) public view returns (address depositor, uint deposit, uint expect){
        Deposit storage dep = queue[idx];
        return (dep.depositor, dep.deposit, dep.expect);
    }

    //Get the count of deposits of specific investor
    function getDepositsCount(address depositor) public view returns (uint) {
        uint c = 0;
        for(uint i=currentReceiverIndex; i<currentQueueSize; ++i){
            if(queue[i].depositor == depositor)
                c++;
        }
        return c;
    }

    //Get all deposits (index, deposit, expect) of a specific investor
    function getDeposits(address depositor) public view returns (uint[] idxs, uint128[] deposits, uint128[] expects) {
        uint c = getDepositsCount(depositor);

        idxs = new uint[](c);
        deposits = new uint128[](c);
        expects = new uint128[](c);

        if(c > 0) {
            uint j = 0;
            for(uint i=currentReceiverIndex; i<currentQueueSize; ++i){
                Deposit storage dep = queue[i];
                if(dep.depositor == depositor){
                    idxs[j] = i;
                    deposits[j] = dep.deposit;
                    expects[j] = dep.expect;
                    j++;
                }
            }
        }
    }

    //Get current queue size
    function getQueueLength() public view returns (uint) {
        return currentQueueSize - currentReceiverIndex;
    }

    function getCurrentStageByTime() public view returns (int) {
        if(lastDepositInfo.time > 0 && lastDepositInfo.time + MAX_IDLE_TIME <= now){
            return stage + 1; //Move to next stage if last deposit is too old
        }
        return stage;
    }

    function getStageStartTime(int _stage) public view returns (uint) {
        if(_stage >= 5)
            return 0;
        if(_stage == stage)
            return startTime;
        if(lastDepositInfo.time == 0)
            return 0;
        if(_stage == stage + 1)
            return lastDepositInfo.time + NEXT_ROUND_TIME;
        return 0;
    }

    function getStartTime() public view returns (uint) {
        return getStageStartTime(getCurrentStageByTime());
    }

}