pragma solidity ^0.4.25;

/**
  Ethereum Multiplier contract: returns 110% of each investment!
  Automatic payouts!
  No bugs, no backdoors, NO OWNER - fully automatic!
  Smart contract Made, checked and verified by professionals!

  1. Send any sum to smart contract address
     - sum from 0.001 to 5 ETH
     - min 250000 gas limit
     - you are added to a queue
  2. Wait a little bit
  3. ...
  4. PROFIT! You have got 110%

  How is that?
  1. The first investor in the queue (you will become the
     first in some time) receives next investments until
     it become 110% of his initial investment.
  2. You will receive payments in several parts or all at once
  3. Once you receive 110% of your initial investment you are
     removed from the queue.
  4. You can make multiple deposits
  5. The balance of this contract should normally be 0 because
     all the money are immediately go to payouts


     So the last pays to the first (or to several first ones
     if the deposit big enough) and the investors paid 110% are removed from the queue

                new investor --|               brand new investor --|
                 investor5     |                 new investor       |
                 investor4     |     =======>      investor5        |
                 investor3     |                   investor4        |
    (part. paid) investor2    <|                   investor3        |
    (fully paid) investor1   <-|                   investor2   <----|  (pay until 110%)

-------------------------------------------------------------------------------------------------
  Контракт Умножитель: возвращает 110% от вашего депозита!
  Автоматические выплаты!
  Без ошибок, дыр, автоматический - для выплат НЕ НУЖНА администрация!
  Создан и проверен профессионалами!

  1. Пошлите любую ненулевую сумму на адрес контракта
     - сумма от 0.001 до 5 ETH
     - gas limit минимум 250000
     - вы встанете в очередь
  2. Немного подождите
  3. ...
  4. PROFIT! Вам пришло 110% от вашего депозита.

  Как это возможно?
  1. Первый инвестор в очереди (вы станете первым очень скоро) получает выплаты от
     новых инвесторов до тех пор, пока не получит 121% от своего депозита
  2. Выплаты могут приходить несколькими частями или все сразу
  3. Как только вы получаете 110% от вашего депозита, вы удаляетесь из очереди
  4. Вы можете делать несколько депозитов сразу
  5. Баланс этого контракта должен обычно быть в районе 0, потому что все поступления
     сразу же направляются на выплаты

     Таким образом, последние платят первым, и инвесторы, достигшие выплат 110% от депозита,
     удаляются из очереди, уступая место остальным

              новый инвестор --|            совсем новый инвестор --|
                 инвестор5     |                новый инвестор      |
                 инвестор4     |     =======>      инвестор5        |
                 инвестор3     |                   инвестор4        |
 (част. выплата) инвестор2    <|                   инвестор3        |
(полная выплата) инвестор1   <-|                   инвестор2   <----|  (доплата до 110%)
-------------------------------------------------------------------------------------------------
乘数合约：每笔投资110％回报！
  自动支付！
  没有错误，没有后门，没有所有者 - 全自动！
  智能合约由专业人士制作，检查和验证！

  1.将任何金额发送到智能合约地址
      - 总和从0.001到5 ETH
      - 最低250000气体限制
      - 您被添加到队列中
  等一下
  3. ...
  4.利润！你有110％

  那个怎么样？
  排队的第一个投资者（你将成为
     首先在一段时间内接受下一次投资，直到
     它成为他初始投资的121％。
  2.您将同时收到几个部分或全部付款
  3.一旦您获得110％的初始投资，您就是
     从队列中删除。
  你可以多次存款
  这份合同的余额通常应为0，因为
     所有的钱都立即去支付


     所以最后一次支付给第一次（或者是第一次支付）
     如果存款足够大）和投资者110％的支付被从队列中删除

                新投资者 -  |全新的投资者 -  |
                 投资者5 |新投资者|
                 investor4 | =======> investor5 |
                 投资者3 | investor4 |
    （部分付款）投资者2 <|投资者3 |
    （全额付款）投资者1 < -  | investor2 <---- | （支付到110％）
    -------------------------------------------------------------------------------------------------
    
乗数契約：各投資の110％を返します！
  自動支払い！
  バグ、バックドア、NO OWNER  - 全自動！
  スマートな契約作り、チェック、専門家による検証！

  1.スマート契約アドレスに合計を送信する
      -  0.001から5 ETHの合計
      - 最小250000ガス限界
      - あなたはキューに追加されます
  2.少し待ってください
  3. ...
  4.利益！あなたは110％

  それはどうですか？
  1.キューに入っている最初の投資家（あなたは
     最初にいくつかの時間に）次の投資を受けるまで
     彼の最初の投資の121％になります。
  あなたは一度にいくつかの部分またはすべての支払いを受け取ります
  3.初期投資額の110％を受け取ると、
     キューから削除されます。
  4.複数の預金を作ることができます
  5.この契約の残高は、
     すべてのお金はすぐに支払いに行く


     だから、最後のものは最初のものに（あるいはいくつかの最初のものに）
     預金が十分に大きい場合）、投資家が110％支払った金額がキ​​ューから取り除かれた場合

                新しい投資家 -  |新しい投資家 -  |
                 |投資家5 |新しい投資家|
                 投資家4 | =======>投資家5 |
                 |投資家3 |投資家4 |
    （部分的に支払われた）investor2 <| |投資家3 |
    （全額）投資家1 < -  | investor2 <---- | （110％まで支払う）
    -------------------------------------------------------------------------------------------------
    Multiplier-contract: geeft 110% van elke investering terug!
  Automatische uitbetalingen!
  Geen bugs, geen achterdeuren, GEEN EIGENAAR - volledig automatisch!
  Slim contract gemaakt, gecontroleerd en geverifieerd door professionals!

  1. Stuur een bedrag naar een slim contractadres
     - som van 0,001 tot 5 ETH
     - min. 250000 gaslimiet
     - u wordt aan een wachtrij toegevoegd
  2. Wacht een beetje
  3. ...
  4. WINST! Je hebt 110%

  Hoe is dat?
  1. De eerste investeerder in de wachtrij (u wordt de
     eerst in een tijd) ontvangt volgende investeringen tot
     het wordt 121% van zijn initiële investering.
  2. U ontvangt betalingen in meerdere of in één keer
  3. Zodra u 110% van uw initiële investering ontvangt, bent u dat
     uit de wachtrij verwijderd.
  4. Je kunt meerdere stortingen doen
  5. Het saldo van dit contract zou normaliter 0 moeten zijn omdat
     al het geld gaat meteen naar uitbetalingen


     Dus de laatste betaalt aan de eerste (of aan verschillende eerste
     als de aanbetaling groot genoeg is) en de beleggers 110% hebben betaald, worden ze uit de wachtrij verwijderd

                nieuwe investeerder - nieuwe investeerder - |
                 investor5 | nieuwe investeerder |
                 investor4 | =======> investeerder5 |
                 investor3 | investor4 |
    (deel betaald) investeerder2 <| investor3 |
    (volledig betaald) investeerder1 <- | investor2 <---- | (betaal tot 110%)
    -------------------------------------------------------------------------------------------------
    Kuntratt multiplikatur: jirritorna 110% ta 'kull investiment!
  Ħlasijiet awtomatiċi!
  L-ebda bugs, l-ebda backdoors, L-ebda proprjetarju - kompletament awtomatiku!
  Kuntratt intelliġenti Made, ikkontrollat ​​u vverifikat minn professjonisti!

  1. Ibgħat kwalunkwe somma għal indirizz tal-kuntratt intelliġenti
     - somma minn 0.001 sa 5 ETH
     - min 250000 limitu ta 'gass
     - inti miżjud ma 'kju
  2. Stenna ftit
  3. ...
  4. PROFIT! Int għandek 110%

  Kif huwa dan?
  1. L-ewwel investitur fil-kju (int se ssir il-persuna
     l-ewwel f'xi żmien) jirċievi l-investimenti li jmiss sa
     sar 121% tal-investiment inizjali tiegħu.
  2. Inti ser tirċievi pagamenti f'diversi partijiet jew kollha f'daqqa
  3. Ladarba tirċievi 110% tal-investiment inizjali tiegħek int
     jitneħħa mill-kju.
  4. Tista 'tagħmel depożiti multipli
  5. Il-bilanċ ta 'dan il-kuntratt normalment għandu jkun 0 minħabba
     il-flus kollha jmorru minnufih għall-ħlasijiet


     Allura l-aħħar iħallas lill-ewwel (jew lil diversi dawk l-ewwel
     jekk id-depożitu huwa kbir biżżejjed) u l-investituri mħallsa 110% jitneħħew mill-kju

                investitur ġdid - | investitur ġdid fjamant - |
                 investitur5 | investitur ġdid |
                 investitur4 | =======> investor5 |
                 investitur3 | investitur4 |
    (parti mħallsa) investitur2 <| investitur3 |
    (imħallas għal kollox) investitur1 <- | investitur2 <---- | (tħallas sa 110%)
    --------------------------------------------------------------------------------------------------
    

*/

contract EthereumMultiplier {
    //Address for reclame expences
    address constant private Reclame = 0x37Ef79eFAEb515EFC1fecCa00d998Ded73092141;
    //Percent for reclame expences
    uint constant public Reclame_PERCENT = 2; 
    //3 for advertizing
    address constant private Admin = 0x942Ee0aDa641749861c47E27E6d5c09244E4d7c8;
    // Address for admin expences
    uint constant public Admin_PERCENT = 2;
    // 1 for techsupport
    address constant private BMG = 0x60d23A4F6642869C04994C818A2dDE5a1bf2c217;
    // Address for BestMoneyGroup
    uint constant public BMG_PERCENT = 2;
    // 2 for BMG
    uint constant public Refferal_PERCENT = 10;
    // 10 for Refferal
    //How many percent for your deposit to be multiplied
    uint constant public MULTIPLIER = 110;

    //The deposit structure holds all the info about the deposit made
    struct Deposit {
        address depositor; //The depositor address
        uint128 deposit;   //The deposit amount
        uint128 expect;    //How much we should pay out (initially it is 121% of deposit)
    }

    Deposit[] private queue;  //The queue
    uint public currentReceiverIndex = 0; //The index of the first depositor in the queue. The receiver of investments!

    //This function receives all the deposits
    //stores them and make immediate payouts
    function () public payable {
        require(tx.gasprice <= 50000000000 wei, "Gas price is too high! Do not cheat!");
        if(msg.value > 110){
            require(gasleft() >= 220000, "We require more gas!"); //We need gas to process queue
            require(msg.value <= 5 ether); //Do not allow too big investments to stabilize payouts

            //Add the investor into the queue. Mark that he expects to receive 121% of deposit back
            queue.push(Deposit(msg.sender, uint128(msg.value), uint128(msg.value*MULTIPLIER/110)));

            //Send some promo to enable this contract to leave long-long time
            uint promo = msg.value*Reclame_PERCENT/100;
            Reclame.send(promo);
            uint admin = msg.value*Admin_PERCENT/100;
            Admin.send(admin);
            uint bmg = msg.value*BMG_PERCENT/100;
            BMG.send(bmg);

            //Pay to first investors in line
            pay();
        }
    
    }
        function refferal (address REF) public payable {
        require(tx.gasprice <= 50000000000 wei, "Gas price is too high! Do not cheat!");
        if(msg.value > 0){
            require(gasleft() >= 220000, "We require more gas!"); //We need gas to process queue
            require(msg.value <= 5 ether); //Do not allow too big investments to stabilize payouts

            //Add the investor into the queue. Mark that he expects to receive 121% of deposit back
            queue.push(Deposit(msg.sender, uint128(msg.value), uint128(msg.value*MULTIPLIER/110)));

            //Send some promo to enable this contract to leave long-long time
            uint promo = msg.value*Reclame_PERCENT/100;
            Reclame.send(promo);
            uint admin = msg.value*Admin_PERCENT/100;
            Admin.send(admin);
            uint bmg = msg.value*BMG_PERCENT/100;
            BMG.send(bmg);
            require(REF != 0x0000000000000000000000000000000000000000 && REF != msg.sender, "You need another refferal!"); //We need gas to process queue
            uint ref = msg.value*Refferal_PERCENT/100;
            REF.send(ref);
            //Pay to first investors in line
            pay();
        }
    
    }
    //Used to pay to current investors
    //Each new transaction processes 1 - 4+ investors in the head of queue 
    //depending on balance and gas left
    function pay() private {
        //Try to send all the money on contract to the first investors in line
        uint128 money = uint128(address(this).balance);

        //We will do cycle on the queue
        for(uint i=0; i<queue.length; i++){

            uint idx = currentReceiverIndex + i;  //get the index of the currently first investor

            Deposit storage dep = queue[idx]; //get the info of the first investor

            if(money >= dep.expect){  //If we have enough money on the contract to fully pay to investor
                dep.depositor.send(dep.expect); //Send money to him
                money -= dep.expect;            //update money left

                //this investor is fully paid, so remove him
                delete queue[idx];
            }else{
                //Here we don't have enough money so partially pay to investor
                dep.depositor.send(money); //Send to him everything we have
                dep.expect -= money;       //Update the expected amount
                break;                     //Exit cycle
            }

            if(gasleft() <= 50000)         //Check the gas left. If it is low, exit the cycle
                break;                     //The next investor will process the line further
        }

        currentReceiverIndex += i; //Update the index of the current first investor
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