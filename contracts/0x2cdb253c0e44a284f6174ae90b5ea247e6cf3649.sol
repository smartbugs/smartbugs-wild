pragma solidity ^0.4.25;

/**

  EN:

  Web: https://bestmultiplier.biz/ru/
  Telegram: https://t.me/bestMultiplierEn

  Multiplier contract: returns 105-130% of each investment!

  Automatic payouts!
  No bugs, no backdoors, NO OWNER - fully automatic!
  Made and checked by professionals!

  1. Send any sum to smart contract address
     - sum from 0.01 ETH
     - min 280000 gas limit
     - you are added to a queue
  2. Wait a little bit
  3. ...
  4. PROFIT! You have got 105-130%

  How is that?
  1. The first investor in the queue (you will become the
     first in some time) receives next investments until
     it become 105-130% of his initial investment.
  2. You will receive payments in several parts or all at once
  3. Once you receive 105-м% of your initial investment you are
     removed from the queue.
  4. You can make only one active deposit
  5. The balance of this contract should normally be 0 because
     all the money are immediately go to payouts


     So the last pays to the first (or to several first ones
     if the deposit big enough) and the investors paid 105-130% are removed from the queue

                new investor --|               brand new investor --|
                 investor5     |                 new investor       |
                 investor4     |     =======>      investor5        |
                 investor3     |                   investor4        |
    (part. paid) investor2    <|                   investor3        |
    (fully paid) investor1   <-|                   investor2   <----|  (pay until 105-130%)

    ==> Limits: <==

    Total invested: up to 100ETH
    Multiplier: 130%
    Maximum deposit: 2.5ETH

    Total invested: from 100 to 250ETH
    Multiplier: 125%
    Maximum deposit: 5ETH

    Total invested: from 250 to 500ETH
    Multiplier: 120%
    Maximum deposit: 10ETH

    Total invested: from 500 to 1000ETH
    Multiplier: 110%
    Maximum deposit: 15ETH

    Total invested: from 1000ETH
    Multiplier: 105%
    Maximum deposit: 20ETH

*/


/**

  RU:

  Web: https://bestmultiplier.biz/ru/
  Telegram: https://t.me/bestMultiplier

  Контракт Умножитель: возвращает 105-130% от вашего депозита!

  Автоматические выплаты!
  Без ошибок, дыр, автоматический - для выплат НЕ НУЖНА администрация!
  Создан и проверен профессионалами!

  1. Пошлите любую ненулевую сумму на адрес контракта
     - сумма от 0.01 ETH
     - gas limit минимум 280000
     - вы встанете в очередь
  2. Немного подождите
  3. ...
  4. PROFIT! Вам пришло 105-130% от вашего депозита.

  Как это возможно?
  1. Первый инвестор в очереди (вы станете первым очень скоро) получает выплаты от
     новых инвесторов до тех пор, пока не получит 105-130% от своего депозита
  2. Выплаты могут приходить несколькими частями или все сразу
  3. Как только вы получаете 105-130% от вашего депозита, вы удаляетесь из очереди
  4. У вас может быть только один активный вклад
  5. Баланс этого контракта должен обычно быть в районе 0, потому что все поступления
     сразу же направляются на выплаты

     Таким образом, последние платят первым, и инвесторы, достигшие выплат 105-130% от депозита,
     удаляются из очереди, уступая место остальным

              новый инвестор --|            совсем новый инвестор --|
                 инвестор5     |                новый инвестор      |
                 инвестор4     |     =======>      инвестор5        |
                 инвестор3     |                   инвестор4        |
 (част. выплата) инвестор2    <|                   инвестор3        |
(полная выплата) инвестор1   <-|                   инвестор2   <----|  (доплата до 105-130%)

    ==> Лимиты: <==

    Всего инвестировано: до 100ETH
    Профит: 130%
    Максимальный вклад: 2.5ETH

    Всего инвестировано: от 100 до 250ETH
    Профит: 125%
    Максимальный вклад: 5ETH

    Всего инвестировано: от 250 до 500ETH
    Профит: 120%
    Максимальный вклад: 10ETH

    Всего инвестировано: от 500 до 1000ETH
    Профит: 110%
    Максимальный вклад: 15ETH

    Всего инвестировано: более 1000ETH
    Профит: 105%
    Максимальный вклад: 20ETH

*/
contract BestMultiplierV2 {

    //The deposit structure holds all the info about the deposit made
    struct Deposit {
        address depositor; // The depositor address
        uint deposit;   // The deposit amount
        uint payout; // Amount already paid
    }

    Deposit[] public queue;  // The queue
    mapping (address => uint) public depositNumber; // investor deposit index
    uint public currentReceiverIndex; // The index of the depositor in the queue
    uint public totalInvested; // Total invested amount

    address public support = msg.sender;
    uint public amountForSupport;

    //This function receives all the deposits
    //stores them and make immediate payouts
    function () public payable {

        if(msg.value > 0){

            require(gasleft() >= 250000); // We need gas to process queue
            require(msg.value >= 0.01 ether && msg.value <= calcMaxDeposit()); // Too small and too big deposits are not accepted
            require(depositNumber[msg.sender] == 0); // Investor should not already be in the queue

            // Add the investor into the queue
            queue.push( Deposit(msg.sender, msg.value, 0) );
            depositNumber[msg.sender] = queue.length;

            totalInvested += msg.value;

            // In total, no more than 5 ETH can be sent to support the project
            if (amountForSupport < 5 ether) {
                amountForSupport += msg.value / 10;
                support.transfer(msg.value / 10);
            }

            // Pay to first investors in line
            pay();

        }
    }

    // Used to pay to current investors
    // Each new transaction processes 1 - 4+ investors in the head of queue
    // depending on balance and gas left
    function pay() internal {

        uint money = address(this).balance;
        uint multiplier = calcMultiplier();

        // We will do cycle on the queue
        for (uint i = 0; i < queue.length; i++){

            uint idx = currentReceiverIndex + i;  //get the index of the currently first investor

            Deposit storage dep = queue[idx]; // get the info of the first investor

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
                depositNumber[dep.depositor] = 0;
                delete queue[idx];

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

        currentReceiverIndex += i; //Update the index of the current first investor
    }

    // Get current queue size
    function getQueueLength() public view returns (uint) {
        return queue.length - currentReceiverIndex;
    }

    // Get max deposit for your investment
    function calcMaxDeposit() public view returns (uint) {

        if (totalInvested <= 100 ether) {
            return 2.5 ether;
        } else if (totalInvested <= 250 ether) {
            return 5 ether;
        } else if (totalInvested <= 500 ether) {
            return 10 ether;
        } else if (totalInvested <= 1000 ether) {
            return 15 ether;
        } else {
            return 20 ether;
        }

    }

    // How many percent for your deposit to be multiplied at now
    function calcMultiplier() public view returns (uint) {

        if (totalInvested <= 100 ether) {
            return 130;
        } else if (totalInvested <= 250 ether) {
            return 125;
        } else if (totalInvested <= 500 ether) {
            return 120;
        } else if (totalInvested <= 1000 ether) {
            return 110;
        } else {
            return 105;
        }

    }

}