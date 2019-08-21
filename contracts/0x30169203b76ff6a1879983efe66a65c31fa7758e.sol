pragma solidity ^0.4.25;

/**
  WITH AUTORESTART EVERY 256 BLOCKS!!! / С АВТОРЕСТАРТОМ КАЖДЫЕ 256 БЛОКОВ!!!

  EN:
  Multiplier contract: returns 110-130% of each investment!

  Automatic payouts!
  No bugs, no backdoors, NO OWNER - fully automatic!
  Made and checked by professionals!

  1. Send any sum to smart contract address
     - sum from 0.1 ETH
     - min 280000 gas limit
     - you are added to a queue
  2. Wait a little bit
  3. ...
  4. PROFIT! You have got 110-130%

  How is that?
  1. The first investor in the queue (you will become the
     first in some time) receives next investments until
     it become 110-130% of his initial investment.
  2. You will receive payments in several parts or all at once
  3. Once you receive 110-130% of your initial investment you are
     removed from the queue.
  4. You can make only one active deposit
  5. The balance of this contract should normally be 0 because
     all the money are immediately go to payouts


     So the last pays to the first (or to several first ones
     if the deposit big enough) and the investors paid 110-130% are removed from the queue

                new investor --|               brand new investor --|
                 investor5     |                 new investor       |
                 investor4     |     =======>      investor5        |
                 investor3     |                   investor4        |
    (part. paid) investor2    <|                   investor3        |
    (fully paid) investor1   <-|                   investor2   <----|  (pay until 110-130%)

    ==> Limits: <==

    Total invested: up to 20ETH
    Multiplier: 130%
    Maximum deposit: 0.5ETH

    Total invested: from 20 to 50ETH
    Multiplier: 120%
    Maximum deposit: 0.7ETH

    Total invested: from 50 to 100ETH
    Multiplier: 115%
    Maximum deposit: 1ETH

    Total invested: from 100 to 200ETH
    Multiplier: 112%
    Maximum deposit: 1.5ETH

    Total invested: from 200ETH
    Multiplier: 110%
    Maximum deposit: 2ETH

    Do not invest at the end of the round
*/


/**

  RU:
  Контракт Умножитель: возвращает 110-130% от вашего депозита!

  Автоматические выплаты!
  Без ошибок, дыр, автоматический - для выплат НЕ НУЖНА администрация!
  Создан и проверен профессионалами!

  1. Пошлите любую ненулевую сумму на адрес контракта
     - сумма от 0.1 ETH
     - gas limit минимум 280000
     - вы встанете в очередь
  2. Немного подождите
  3. ...
  4. PROFIT! Вам пришло 110-130% от вашего депозита.

  Как это возможно?
  1. Первый инвестор в очереди (вы станете первым очень скоро) получает выплаты от
     новых инвесторов до тех пор, пока не получит 110-130% от своего депозита
  2. Выплаты могут приходить несколькими частями или все сразу
  3. Как только вы получаете 110-130% от вашего депозита, вы удаляетесь из очереди
  4. У вас может быть только один активный вклад
  5. Баланс этого контракта должен обычно быть в районе 0, потому что все поступления
     сразу же направляются на выплаты

     Таким образом, последние платят первым, и инвесторы, достигшие выплат 110-130% от депозита,
     удаляются из очереди, уступая место остальным

              новый инвестор --|            совсем новый инвестор --|
                 инвестор5     |                новый инвестор      |
                 инвестор4     |     =======>      инвестор5        |
                 инвестор3     |                   инвестор4        |
 (част. выплата) инвестор2    <|                   инвестор3        |
(полная выплата) инвестор1   <-|                   инвестор2   <----|  (доплата до 110-130%)

    ==> Лимиты: <==

    Всего инвестировано: до 20ETH
    Профит: 130%
    Максимальный вклад: 0.5ETH

    Всего инвестировано: от 20 до 50ETH
    Профит: 120%
    Максимальный вклад: 0.7ETH

    Всего инвестировано: от 50 до 100ETH
    Профит: 115%
    Максимальный вклад: 1ETH

    Всего инвестировано: от 100 до 200ETH
    Профит: 112%
    Максимальный вклад: 1.5ETH

    Всего инвестировано: более 200ETH
    Профит: 110%
    Максимальный вклад: 2ETH

    Не инвестируйте в конце раунда

*/
contract EternalMultiplier {

    //The deposit structure holds all the info about the deposit made
    struct Deposit {
        address depositor; // The depositor address
        uint deposit;   // The deposit amount
        uint payout; // Amount already paid
    }

    uint public roundDuration = 256;
    
    mapping (uint => Deposit[]) public queue;  // The queue
    mapping (uint => mapping (address => uint)) public depositNumber; // investor deposit index
    mapping (uint => uint) public currentReceiverIndex; // The index of the depositor in the queue
    mapping (uint => uint) public totalInvested; // Total invested amount

    address public support = msg.sender;
    mapping (uint => uint) public amountForSupport;

    //This function receives all the deposits
    //stores them and make immediate payouts
    function () public payable {
        require(block.number >= 6617925);
        require(block.number % roundDuration < roundDuration - 20);
        uint stage = block.number / roundDuration;

        if(msg.value > 0){

            require(gasleft() >= 250000); // We need gas to process queue
            require(msg.value >= 0.1 ether && msg.value <= calcMaxDeposit(stage)); // Too small and too big deposits are not accepted
            require(depositNumber[stage][msg.sender] == 0); // Investor should not already be in the queue

            // Add the investor into the queue
            queue[stage].push( Deposit(msg.sender, msg.value, 0) );
            depositNumber[stage][msg.sender] = queue[stage].length;

            totalInvested[stage] += msg.value;

            // No more than 5 ETH per stage can be sent to support the project
            if (amountForSupport[stage] < 5 ether) {
                uint fee = msg.value / 5;
                amountForSupport[stage] += fee;
                support.transfer(fee);
            }

            // Pay to first investors in line
            pay(stage);

        }
    }

    // Used to pay to current investors
    // Each new transaction processes 1 - 4+ investors in the head of queue
    // depending on balance and gas left
    function pay(uint stage) internal {

        uint money = address(this).balance;
        uint multiplier = calcMultiplier(stage);

        // We will do cycle on the queue
        for (uint i = 0; i < queue[stage].length; i++){

            uint idx = currentReceiverIndex[stage] + i;  //get the index of the currently first investor

            Deposit storage dep = queue[stage][idx]; // get the info of the first investor

            uint totalPayout = dep.deposit * multiplier / 100;
            uint leftPayout;

            if (totalPayout > dep.payout) {
                leftPayout = totalPayout - dep.payout;
            }

            if (money >= leftPayout) { //If we have enough money on the contract to fully pay to investor

                if (leftPayout > 0) {
                    dep.depositor.send(leftPayout); // Send money to him
                    money -= leftPayout;
                }

                // this investor is fully paid, so remove him
                depositNumber[stage][dep.depositor] = 0;
                delete queue[stage][idx];

            } else{

                // Here we don't have enough money so partially pay to investor
                dep.depositor.send(money); // Send to him everything we have
                dep.payout += money;       // Update the payout amount
                break;                     // Exit cycle

            }

            if (gasleft() <= 55000) {         // Check the gas left. If it is low, exit the cycle
                break;                       // The next investor will process the line further
            }
        }

        currentReceiverIndex[stage] += i; //Update the index of the current first investor
    }

    // Get current queue size
    function getQueueLength() public view returns (uint) {
        uint stage = block.number / roundDuration;
        return queue[stage].length - currentReceiverIndex[stage];
    }

    // Get max deposit for your investment
    function calcMaxDeposit(uint stage) public view returns (uint) {

        if (totalInvested[stage] <= 20 ether) {
            return 0.5 ether;
        } else if (totalInvested[stage] <= 50 ether) {
            return 0.7 ether;
        } else if (totalInvested[stage] <= 100 ether) {
            return 1 ether;
        } else if (totalInvested[stage] <= 200 ether) {
            return 1.5 ether;
        } else {
            return 2 ether;
        }

    }

    // How many percent for your deposit to be multiplied at now
    function calcMultiplier(uint stage) public view returns (uint) {

        if (totalInvested[stage] <= 20 ether) {
            return 130;
        } else if (totalInvested[stage] <= 50 ether) {
            return 120;
        } else if (totalInvested[stage] <= 100 ether) {
            return 115;
        } else if (totalInvested[stage] <= 200 ether) {
            return 112;
        } else {
            return 110;
        }

    }

}