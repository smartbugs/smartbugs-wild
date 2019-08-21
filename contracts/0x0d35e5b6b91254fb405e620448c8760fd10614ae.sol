pragma solidity ^0.4.25;

/**
 * Web - https://ethmoon.cc/
 * RU  Telegram_chat: https://t.me/ethmoonccv2
 *
 *
 * Multiplier ETHMOON_V3: returns 115%-120% of each investment!
 * Fully transparent smartcontract with automatic payments proven professionals.
 * 1. Send any sum to smart contract address
 *    - sum from 0.21 to 10 ETH
 *    - min 250000 gas limit
 *    - you are added to a queue
 * 2. Wait a little bit
 * 3. ...
 * 4. PROFIT! You have got 115%-120%
 *
 * How is that?
 * 1. The first investor in the queue (you will become the
 *    first in some time) receives next investments until
 *    it become 115%-120% of his initial investment.
 * 2. You will receive payments in several parts or all at once
 * 3. Once you receive 115%-120% of your initial investment you are
 *    removed from the queue.
 * 4. You can make more than one deposits at once
 * 5. The balance of this contract should normally be 0 because
 *    all the money are immediately go to payouts
 *
 *
 * So the last pays to the first (or to several first ones if the deposit big enough) 
 * and the investors paid 115%-120% are removed from the queue
 *
 *               new investor --|               brand new investor --|
 *                investor5     |                 new investor       |
 *                investor4     |     =======>      investor5        |
 *                investor3     |                   investor4        |
 *   (part. paid) investor2    <|                   investor3        |
 *   (fully paid) investor1   <-|                   investor2   <----|  (pay until 115%-120%)
 *
 *
 *
 * Контракт ETHMOON_V3: возвращает 115%-120% от вашего депозита!
 * Полностью прозрачный смартконтракт с автоматическими выплатами, проверенный профессионалами.
 * 1. Пошлите любую ненулевую сумму на адрес контракта
 *    - сумма от 0.21 до 10 ETH
 *    - gas limit минимум 250000
 *    - вы встанете в очередь
 * 2. Немного подождите
 * 3. ...
 * 4. PROFIT! Вам пришло 115%-120% от вашего депозита.
 * 
 * Как это возможно?
 * 1. Первый инвестор в очереди (вы станете первым очень скоро) получает выплаты от
 *    новых инвесторов до тех пор, пока не получит 115%-120% от своего депозита
 * 2. Выплаты могут приходить несколькими частями или все сразу
 * 3. Как только вы получаете 115%-120% от вашего депозита, вы удаляетесь из очереди
 * 4. Вы можете делать несколько депозитов сразу
 * 5. Баланс этого контракта должен обычно быть в районе 0, потому что все поступления
 *    сразу же направляются на выплаты
 *
 * Таким образом, последние платят первым, и инвесторы, достигшие выплат 115%-120% от 
 * депозита, удаляются из очереди, уступая место остальным
 *
 *             новый инвестор --|            совсем новый инвестор --|
 *                инвестор5     |                новый инвестор      |
 *                инвестор4     |     =======>      инвестор5        |
 *                инвестор3     |                   инвестор4        |
 * (част. выпл.)  инвестор2    <|                   инвестор3        |
 * (полная выпл.) инвестор1   <-|                   инвестор2   <----|  (доплата до 115%-120%)
 *
*/


contract EthmoonV3 {
    // address for promo expences
    address constant private PROMO = 0xa4Db4f62314Db6539B60F0e1CBE2377b918953Bd;
    address constant private SMARTCONTRACT = 0x03f69791513022D8b67fACF221B98243346DF7Cb;
    address constant private STARTER = 0x5dfE1AfD8B7Ae0c8067dB962166a4e2D318AA241;
    // percent for promo/tech expences
    uint constant public PROMO_PERCENT = 5;
    uint constant public SMARTCONTRACT_PERCENT = 5;
    // how many percent for your deposit to be multiplied
    uint constant public START_MULTIPLIER = 115;
    // deposit limits
    uint constant public MIN_DEPOSIT = 0.21 ether;
    uint constant public MAX_DEPOSIT = 10 ether;
    bool public started = false;
    // count participation
    mapping(address => uint) public participation;

    // the deposit structure holds all the info about the deposit made
    struct Deposit {
        address depositor; // the depositor address
        uint128 deposit;   // the deposit amount
        uint128 expect;    // how much we should pay out (initially it is 115%-120% of deposit)
    }

    Deposit[] private queue;  // the queue
    uint public currentReceiverIndex = 0; // the index of the first depositor in the queue. The receiver of investments!

    // this function receives all the deposits
    // stores them and make immediate payouts
    function () public payable {
        require(gasleft() >= 220000, "We require more gas!"); // we need gas to process queue
        require((msg.sender == STARTER) || (started));
        
        if (msg.sender != STARTER) {
            require((msg.value >= MIN_DEPOSIT) && (msg.value <= MAX_DEPOSIT)); // do not allow too big investments to stabilize payouts
            uint multiplier = percentRate(msg.sender);
            // add the investor into the queue. Mark that he expects to receive 115%-120% of deposit back
            queue.push(Deposit(msg.sender, uint128(msg.value), uint128(msg.value * multiplier/100)));
            participation[msg.sender] = participation[msg.sender] + 1;
            // send some promo to enable this contract to leave long-long time
            uint promo = msg.value * PROMO_PERCENT/100;
            PROMO.transfer(promo);
            uint smartcontract = msg.value * SMARTCONTRACT_PERCENT/100;
            SMARTCONTRACT.transfer(smartcontract);
    
            // pay to first investors in line
            pay();
        } else {
            started = true;
        }
    }

    // used to pay to current investors
    // each new transaction processes 1 - 4+ investors in the head of queue 
    // depending on balance and gas left
    function pay() private {
        // try to send all the money on contract to the first investors in line
        uint128 money = uint128(address(this).balance);

        // we will do cycle on the queue
        for (uint i=0; i<queue.length; i++) {
            uint idx = currentReceiverIndex + i;  // get the index of the currently first investor

            Deposit storage dep = queue[idx]; // get the info of the first investor

            if (money >= dep.expect) {  // if we have enough money on the contract to fully pay to investor
                dep.depositor.transfer(dep.expect); // send money to him
                money -= dep.expect;            // update money left

                // this investor is fully paid, so remove him
                delete queue[idx];
            } else {
                // here we don't have enough money so partially pay to investor
                dep.depositor.transfer(money); // send to him everything we have
                dep.expect -= money;       // update the expected amount
                break;                     // exit cycle
            }

            if (gasleft() <= 50000)         // check the gas left. If it is low, exit the cycle
                break;                     // the next investor will process the line further
        }

        currentReceiverIndex += i; // update the index of the current first investor
    }

    // get the deposit info by its index
    // you can get deposit index from
    function getDeposit(uint idx) public view returns (address depositor, uint deposit, uint expect){
        Deposit storage dep = queue[idx];
        return (dep.depositor, dep.deposit, dep.expect);
    }

    // get the count of deposits of specific investor
    function getDepositsCount(address depositor) public view returns (uint) {
        uint c = 0;
        for (uint i=currentReceiverIndex; i<queue.length; ++i) {
            if(queue[i].depositor == depositor)
                c++;
        }
        return c;
    }

    // get all deposits (index, deposit, expect) of a specific investor
    function getDeposits(address depositor) public view returns (uint[] idxs, uint128[] deposits, uint128[] expects) {
        uint c = getDepositsCount(depositor);

        idxs = new uint[](c);
        deposits = new uint128[](c);
        expects = new uint128[](c);

        if (c > 0) {
            uint j = 0;
            for (uint i=currentReceiverIndex; i<queue.length; ++i) {
                Deposit storage dep = queue[i];
                if (dep.depositor == depositor) {
                    idxs[j] = i;
                    deposits[j] = dep.deposit;
                    expects[j] = dep.expect;
                    j++;
                }
            }
        }
    }
    
    // get current queue size
    function getQueueLength() public view returns (uint) {
        return queue.length - currentReceiverIndex;
    }
    
    // get persent rate
    function percentRate(address depositor) public view returns(uint) {
        uint persent = START_MULTIPLIER;
        if (participation[depositor] > 0) {
            persent = persent + participation[depositor] * 5;
        }
        if (persent > 120) {
            persent = 120;
        } 
        return persent;
    }
}