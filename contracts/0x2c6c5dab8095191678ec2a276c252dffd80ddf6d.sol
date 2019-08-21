pragma solidity ^0.4.25;

/**
  Gradual.pro - Плавно растущий и долго живущий умножитель БЕЗ КИТОВ!, который возвращает 121% от вашего депозита!

  Маленький лимит на депозит избавляет от проблем с КИТАМИ, которые очень сильно тормозили предыдущую версию контракта и значительно продлевает срок его жизни!

  Автоматические выплаты!
  Полные отчеты о потраченых на рекламу средствах в группе!
  Без ошибок, дыр, автоматический - для выплат НЕ НУЖНА администрация!
  Создан и проверен профессионалами!
  Код полностью документирован на русском языке, каждая строчка понятна!

  Вебсайт: http://gradual.pro/
  Группа в телеграмме: https://t.me/gradualpro

  1. Пошлите любую ненулевую сумму на адрес контракта
     - сумма от 0.01 до 2 ETH
     - gas limit минимум 250000
     - вы встанете в очередь
  2. Немного подождите
  3. ...
  4. PROFIT! Вам пришло 121% от вашего депозита.

  Как это возможно?
  1. Первый инвестор в очереди (вы станете первым очень скоро) получает выплаты от
     новых инвесторов до тех пор, пока не получит 121% от своего депозита
  2. Выплаты могут приходить несколькими частями или все сразу
  3. Как только вы получаете 121% от вашего депозита, вы удаляетесь из очереди
  4. Вы можете делать несколько депозитов сразу
  5. Баланс этого контракта должен обычно быть в районе 0, потому что все поступления
     сразу же направляются на выплаты

     Таким образом, последние платят первым, и инвесторы, достигшие выплат 121% от депозита,
     удаляются из очереди, уступая место остальным

              новый инвестор --|            совсем новый инвестор --|
                 инвестор5     |                новый инвестор      |
                 инвестор4     |     =======>      инвестор5        |
                 инвестор3     |                   инвестор4        |
 (част. выплата) инвестор2    <|                   инвестор3        |
(полная выплата) инвестор1   <-|                   инвестор2   <----|  (доплата до 121%)

*/

contract GradualPro {
    // Адрес кошелька первого проекта для продвижения очереди
    address constant private FIRST_SUPPORT = 0xf8F04b23dACE12841343ecf0E06124354515cc42;

    // Адрес кошелька для оплаты технической поддержки информационных каналов
    address constant private TECH_SUPPORT = 0x988f1a2fb17414c95f45E2DAaaA40509F5C9088c;

    // Процент депозита на первый проект 4%
    uint constant public FIRST_PERCENT = 4;

    // Процент депозита на тех поддержку 1%
    uint constant public TECH_PERCENT = 1;
    
    // Процент выплат всем участникам
    uint constant public MULTIPLIER = 121;

    // Максимальная сумма депозита = 2 эфира, чтобы каждый смог учавстовать и киты не тормозили и не пугали вкладчиков
    uint constant public MAX_LIMIT = 2 ether;

    // Структура Deposit содержит информацию о депозите
    struct Deposit {
        address depositor; // Владелец депозита
        uint128 deposit;   // Сумма депозита
        uint128 expect;    // Сумма выплаты (моментально 121% от депозита)
    }

    // Очередь
    Deposit[] private queue;

    // Номер обрабатываемого депозита, можно следить в разделе Read contract
    uint public currentReceiverIndex = 0;

    // Данная функция получает все депозиты, сохраняет их и производит моментальные выплаты
    function () public payable {
        // Если сумма депозита больше нуля
        if(msg.value > 0){
            // Проверяем минимальный лимит газа 220 000, иначе отменяем депозит и возвращаем деньги вкладчику
            require(gasleft() >= 220000, "We require more gas!");

            // Проверяем максимальную сумму вклада
            require(msg.value <= MAX_LIMIT, "Deposit is too big");

            // Добавляем депозит в очередь, записываем что ему нужно выплатить 121% от суммы депозита
            queue.push(Deposit(msg.sender, uint128(msg.value), uint128(msg.value * MULTIPLIER / 100)));

            // Отправляем процент на продвижение проекта
            uint ads = msg.value * FIRST_PERCENT / 100;
            FIRST_SUPPORT.transfer(ads);

            // Отправляем процент на техническую поддержку проекта
            uint tech = msg.value * TECH_PERCENT / 100;
            TECH_SUPPORT.transfer(tech);

            // Вызываем функцию оплаты первому в очереди депозиту
            pay();
        }
    }

    // Фукнция используется для оплаты первым в очереди депозитам
    // Каждая новая транзация обрабатывает от 1 до 4+ вкладчиков в начале очереди 
    // В зависимости от оставшегося газа
    function pay() private {
        // Попытаемся послать все деньги имеющиеся на контракте первым в очереди вкладчикам
        uint128 money = uint128(address(this).balance);

        // Проходим по всей очереди
        for(uint i = 0; i < queue.length; i++) {

            uint idx = currentReceiverIndex + i;  // Достаем номер первого в очереди депозита

            Deposit storage dep = queue[idx]; // Достаем информацию о первом депозите

            if(money >= dep.expect) {  // Если у нас есть достаточно денег для полной выплаты, то выплачиваем ему все
                dep.depositor.transfer(dep.expect); // Отправляем ему деньги
                money -= dep.expect; // Обновляем количество оставшихся денег

                // депозит был полностью выплачен, удаляем его
                delete queue[idx];
            } else {
                // Попадаем сюда, если у нас не достаточно денег выплатить все, а лишь часть
                dep.depositor.transfer(money); // Отправляем все оставшееся
                dep.expect -= money;       // Обновляем количество оставшихся денег
                break;                     // Выходим из цикла
            }

            if (gasleft() <= 50000)         // Проверяем если еще остался газ, и если его нет, то выходим из цикла
                break;                     //  Следующий вкладчик осуществит выплату следующим в очереди
        }

        currentReceiverIndex += i; // Обновляем номер депозита ставшего первым в очереди
    }

    // Показывает информацию о депозите по его номеру (idx), можно следить в разделе Read contract
    // Вы можете получить номер депозита  (idx) вызвав функцию getDeposits()
    function getDeposit(uint idx) public view returns (address depositor, uint deposit, uint expect){
        Deposit storage dep = queue[idx];
        return (dep.depositor, dep.deposit, dep.expect);
    }

    // Показывает количество вкладов определенного инвестора
    function getDepositsCount(address depositor) public view returns (uint) {
        uint c = 0;
        for(uint i=currentReceiverIndex; i<queue.length; ++i){
            if(queue[i].depositor == depositor)
                c++;
        }
        return c;
    }

    // Показывает все депозиты (index, deposit, expect) определенного инвестора, можно следить в разделе Read contract
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
    
    // Показывает длинну очереди, можно следить в разделе Read contract
    function getQueueLength() public view returns (uint) {
        return queue.length - currentReceiverIndex;
    }

}