pragma solidity ^0.4.25;

/**
   QuickQueue contract: returns 103% of each investment!
  Automatic payouts!
  No bugs, no backdoors, NO OWNER - fully automatic!
  Made and checked by professionals!

  1. Send any sum to smart contract address
     - sum from 0.01 to 1 ETH
     - min 250000 gas limit
     - you are added to a queue
  2. Wait a little bit
  3. ...
  4. PROFIT! You have got 103%

  How is that?
  1. The first investor in the queue (you will become the
     first in some time) receives next investments until
     it become 103% of his initial investment.
  2. You will receive payments in several parts or all at once
  3. Once you receive 103% of your initial investment you are
     removed from the queue.
  4. You can make multiple deposits
  5. The balance of this contract should normally be 0 because
     all the money are immediately go to payouts


     So the last pays to the first (or to several first ones
     if the deposit big enough) and the investors paid 103% are removed from the queue

                new investor --|               brand new investor --|
                 investor5     |                           new investor       |
                 investor4     |     =======>         investor5        |
                 investor3     |                               investor4        |
    (part. paid) investor2    <|                      investor3        |
    (fully paid) investor1   <-|                    investor2   <----|  (pay until 103%)
    
    
  QuickQueue - Надежный умножитель, который возвращает 103% от вашего депозита!

  Маленький лимит на депозит избавляет от проблем с крупными вкладами и дает возможность заработать каждому!

  Автоматические выплаты!
  Полные отчеты о потраченных на рекламу средствах в группе!
  Без ошибок, дыр, автоматический - для выплат НЕ НУЖНА администрация!
  Создан и проверен профессионалами!

  1. Пошлите любую ненулевую сумму на адрес контракта
     - сумма от 0.01 до 1 ETH
     - gas limit минимум 250000
     - вы встанете в очередь
  2. Немного подождите
  3. ...
  4. PROFIT! Вам пришло 103% от вашего депозита.

  Как это возможно?
  1. Первый инвестор в очереди (вы станете первым очень скоро) получает выплаты от
     новых инвесторов до тех пор, пока не получит 103% от своего депозита
  2. Выплаты могут приходить несколькими частями или все сразу
  3. Как только вы получаете 103% от вашего депозита, вы удаляетесь из очереди
  4. Вы можете делать несколько депозитов сразу
  5. Баланс этого контракта должен обычно быть в районе 0, потому что все поступления
     сразу же направляются на выплаты

     Таким образом, последние платят первым, и инвесторы, достигшие выплат 103% от депозита,
     удаляются из очереди, уступая место остальным

              новый инвестор --|            совсем новый инвестор --|
                 инвестор5     |                              новый инвестор      |
                 инвестор4     |     =======>                инвестор5        |
                 инвестор3     |                                      инвестор4        |
 (част. выплата) инвестор2    <|                       инвестор3        |
(полная выплата) инвестор1   <-|                   инвестор2   <----|  (доплата до 103%)

*/

contract QuickQueue {
   
    address constant private SUPPORT = 0x1f78Ae3ab029456a3ac5b6f4F90EaB5B675c47D5;  // Address for promo expences
    uint constant public SUPPORT_PERCENT = 5; //Percent for promo expences 5% (3% for advertizing, 2% for techsupport)
    uint constant public QUICKQUEUE = 103; // Percent for your deposit to be QuickQueue
    uint constant public MAX_LIMIT = 1 ether; // Max deposit = 1 Eth

    //The deposit structure holds all the info about the deposit made
    struct Deposit {
        address depositor; // The depositor address
        uint128 deposit;   // The deposit amount
        uint128 expect;    // How much we should pay out (initially it is 103% of deposit)
    }

    //The queue
    Deposit[] private queue;

    uint public currentReceiverIndex = 0;

    //This function receives all the deposits
    //stores them and make immediate payouts
    function () public payable {
        if(msg.value > 0){
            require(gasleft() >= 220000, "We require more gas!");
            require(msg.value <= MAX_LIMIT, "Deposit is too big");

            queue.push(Deposit(msg.sender, uint128(msg.value), uint128(msg.value * QUICKQUEUE / 100)));

            uint ads = msg.value * SUPPORT_PERCENT / 100;
            SUPPORT.transfer(ads);

            pay();
        }
    }

    //Used to pay to current investors
    //Each new transaction processes 1 - 4+ investors in the head of queue 
    //depending on balance and gas left
    function pay() private {
        uint128 money = uint128(address(this).balance);

        for(uint i = 0; i < queue.length; i++) {

            uint idx = currentReceiverIndex + i;

            Deposit storage dep = queue[idx];

            if(money >= dep.expect) {  
                dep.depositor.transfer(dep.expect);
                money -= dep.expect;

                delete queue[idx];
            } else {
                dep.depositor.transfer(money);
                dep.expect -= money;       
                break;                     
            }

            if (gasleft() <= 50000)     
                break;                     
        }

        currentReceiverIndex += i; 
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
        for(uint i=currentReceiverIndex; i<queue.length; ++i){
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
            for(uint i=currentReceiverIndex; i<queue.length; ++i){
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
        return queue.length - currentReceiverIndex;
    }

}