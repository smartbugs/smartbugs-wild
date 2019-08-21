pragma solidity ^0.4.4;
  //ENG::This code is a part of game on www.fgames.io
  //ENG::If you found any bug or have an idea, contact us on code@fgames.io
  //RUS::Этот код является частью игры на сайте www.fgames.io
  //RUS::Если вы нашли баги или есть идеи, пишите нам code@fgames.io
contract playFive {
  //ENG::Declare variable we use
  //RUS::Декларируем переменные
  address private creator;
  string private message;
  string private message_details;
  string private referal;
  uint private totalBalance; 
  uint public totalwin;
  
  //ENG::Сonstructor
  //Конструктор
  /*
  constructor() public {

    creator = tx.origin;   
    message = 'initiated';
  }
  */


  


  //ENG::Function that show Creator adress
  //RUS::Функция которая отобразит адресс создателя контракта
  function getCreator() public constant returns(address) {
    return creator;
  }

  //ENG::Function that show SmarrtContract Balance
  //Функция которая отобразит Баланс СмартКонтракта
  function getTotalBalance() public constant returns(uint) {
    return address(this).balance;
  }  
  

//ENG::One of the best way to compare two strings converted to bytes
//ENG::Function will check length and if bytes length is same then calculate hash of strings and compare it, (a1)
//ENG::if strings the same, return true, otherwise return false (a2)
//RUS::Один из лучших вариантов сравнения стринг переменных сконвертированные а байты
//RUS::Сначала функция сравнивает длинну байткода и послк их хэш (a1)
//RUS::Если хэш одинаковый, то возвращает true, иначе - false (a2)

function hashCompareWithLengthCheck(string a, string b) internal pure returns (bool) {
    if(bytes(a).length != bytes(b).length) { //(a1)
        return false;
    } else {
        return keccak256(abi.encodePacked(a)) == keccak256(abi.encodePacked(b)); //(a2)
    }
}

//ENG::Function that calculate Wining points
//ENG::After we get our *play ticket* adress, we take last 5 chars of it and game is on
//ENG::sendTXTpsTX - main game function, send to this function *play ticket* code and player entered symbols 
//ENG::function starting setted initiated results to nothing (b1)
//ENG::Then converting strings to bytes, so we can run throung each symbol (b2)
//ENG::Also we set initial winpoint to 0 (b3)
//ENG::Then we run throught each symbol in *play ticket* and compare it with player entered symbols
//ENG::player entered symbols maximum length also is five
//ENG::if function found a match using *hashCompareWithLengthCheck* function, then
//ENG::function add to event message details, that shows whats symbols are found whith player entered symbols (b4)
//ENG::replace used symbols in *player ticket* and entered symbols on X and Y so they no more used in game process (b5)
//ENG::and increase winpoit by 1 (b6)
//ENG::after function complete, it return winpoint from 0 - 5 (b7)
//RUS::Функция которая высчитывает количество очков
//RUS::После получения адреса *билета*, мы берем его последнии 5 символов и игра началась
//RUS::sendTXTpsTX - главная функция игры, шлёт этой функции символы билета и символы введеные игроком
//RUS::Функция сначало обнуляет детали переменной результата (b1)
//RUS::После конвертирует *билет* и символы игрока в байты, чтобы можно было пройти по символам (b2)
//RUS::Также ставим начальное количество очков на 0 (b3)
//RUS::Далее мы проверяем совпадают ли символы *билета* с символами которые ввел игрок
//RUS::Максимальная длинна символов которые вводит игрок, тоже 5.
//RUS::Если функция находит совпадение с помощью функции *hashCompareWithLengthCheck*, то
//RUS::Функция добавляет к эвэнту детальное сообщение о том, какие символы были найдены (b4)
//RUS::Заменяет найденные символы в *билете* и *ключе* на X и Y и они более не участвуют в игре (b5)
//RUS::Увеличивает количество баллов winpoint на 1 (b6)
//RUS::По звыершению, возвращает значение winpoint от 0 до 5 (b7)
function check_result(string ticket, string check) public  returns (uint) {
  message_details = ""; //(b1)
    bytes memory ticketBytes = bytes(ticket); //(b2)
    bytes memory checkBytes = bytes(check);   //(b2) 
    uint winpoint = 0; //(b3)


    for (uint i=0; i < 5; i++){

      for (uint j=0; j < 5; j++){

        if(hashCompareWithLengthCheck(string(abi.encodePacked(ticketBytes[j])),string(abi.encodePacked(checkBytes[i]))))
        {
          message_details = string(abi.encodePacked(message_details,'*',ticketBytes[j],'**',checkBytes[i])); //(b4)
          ticketBytes[j] ="X"; //(b5)
          checkBytes[i] = "Y"; //(b5)

          winpoint = winpoint+1; //(b6)         
        }
       
      }

    }    
    return uint(winpoint); //(b7)
  }

//ENG::Function destroy this smartContract
//ENG::Thats needed in case if we create new game, to take founds from it and add to new game 
//ENG::Or also it need if we see that current game not so actual, and we need to transfer founds to a new game, that more popular
//ENG::Or in case if we found any critical bug, to take founds in safe place, while fixing bugs.
//RUS::Функция для уничтожения смарт контракта
//RUS::Это необходимо, чтобы при создании новых игр, можно было разделить Баланс текущей игры с новой игрой
//RUS::Или если при создании новых игр, эта потеряет свою актуальность
//RUS::Либо при обнаружении критических багое, перевести средства в безопастное место на время исправления ошибок
  function resetGame () public {
    if (msg.sender == creator) { 
      selfdestruct(0xdC3df52BB1D116471F18B4931895d91eEefdC2B3); 
      return;
    }
  }

//ENG::Function to substring provided string from provided start position until end position
//ENG::It's need to tak last 5 characters from *ticket* adress
//RUS::Функция для обрезания заданной строки с заданной позиции до заданной конечной позиции
//RUS::Это надо, чтобы получить последние 5 символов с адресса *билета*
function substring(string str, uint startIndex, uint endIndex) public pure returns (string) {
    bytes memory strBytes = bytes(str);
    bytes memory result = new bytes(endIndex-startIndex);
    for(uint i = startIndex; i < endIndex; i++) {
        result[i-startIndex] = strBytes[i];
    }
    return string(result);
  }

//ENG::Also very useful function, to make all symbols in string to lowercase
//ENG::That need in case to lowercase *TICKET* adress and Player provided symbols
//ENG::Because adress can be 0xasdf...FFDDEE123 and player can provide ACfE4. but we all convert to one format. lowercase
//RUS::Тоже очень полезная функция, чтобы перевести все символы в нижний регистр
//RUS::Это надо, чтобы привести в единый формат все такие переменные как *Билет* и *Ключ*
//RUS::Так как адресс билета может быть 0xasdf...FFDDEE123, а также игрок может ввести ACfE4.
	function _toLower(string str) internal pure returns (string) {
		bytes memory bStr = bytes(str);
		bytes memory bLower = new bytes(bStr.length);
		for (uint i = 0; i < bStr.length; i++) {
			// Uppercase character...
			if ((bStr[i] >= 65) && (bStr[i] <= 90)) {
				// So we add 32 to make it lowercase
				bLower[i] = bytes1(int(bStr[i]) + 32);
			} else {
				bLower[i] = bStr[i];
			}
		}
		return string(bLower);
	}

  //ENG::Standart Function to receive founds
  //RUS::Стандартная функция для приёма средств
  function () payable public {
    //RECEIVED    
  }

  //ENG::Converts adress type into string
  //ENG::Used to convert *TICKET* adress into string
  //RUS::Конвертирует переменную типа adress в строку string
  //RUS::Используется для конвертации адреса *билета* в строку string
  
function addressToString(address _addr) public pure returns(string) {
    bytes32 value = bytes32(uint256(_addr));
    bytes memory alphabet = "0123456789abcdef";

    bytes memory str = new bytes(42);
    str[0] = '0';
    str[1] = 'x';
    for (uint i = 0; i < 20; i++) {
        str[2+i*2] = alphabet[uint(value[i + 12] >> 4)];
        str[3+i*2] = alphabet[uint(value[i + 12] & 0x0f)];
    }
    return string(str);
}


  //ENG::Get last blockhash symbols and converts into string
  //ENG::Used to convert *TICKET* hash into string
  //RUS::Получаемонвертирует переменную типа adress в строку string
  //RUS::Используется для конвертации адреса *билета* в строку string

function blockhashToString(bytes32 _blockhash_to_decode) public pure returns(string) {
    bytes32 value = _blockhash_to_decode;
    bytes memory alphabet = "0123456789abcdef";

    bytes memory str = new bytes(42);
    str[0] = '0';
    str[1] = 'x';
    for (uint i = 0; i < 20; i++) {
        str[2+i*2] = alphabet[uint(value[i + 12] >> 4)];
        str[3+i*2] = alphabet[uint(value[i + 12] & 0x0f)];
    }
    return string(str);
}

  //ENG::Converts uint type into STRING to show data in human readable format
  //RUS::Конвертирует переменную uint в строку string чтобы отобразить данные в понятном для человека формате
function uint2str(uint i) internal pure returns (string){
    if (i == 0) return "0";
    uint j = i;
    uint length;
    while (j != 0){
        length++;
        j /= 10;
    }
    bytes memory bstr = new bytes(length);
    uint k = length - 1;
    while (i != 0){
        bstr[k--] = byte(48 + i % 10);
        i /= 10;
    }
    return string(bstr);
}


//ENG::This simple function, clone existing contract into new contract, to gain TOTALLY UNICALLY random string of *TICKET*
//RUS::Эта простая функция клонирует текущий контракт в новый контракт, чтобы получить 100% уникальную переменную *БИЛЕТА*

function isContract(address _addr) private view returns (bool OKisContract){
  uint32 size;
  assembly {
    size := extcodesize(_addr)
  }
  return (size > 0);
}



  //ENG::Event which will be visible in transaction logs in etherscan, and will have result data, whats will be parsed and showed on website
  //RUS::Эвент который будет виден а логах транзакции, и отобразит строку с полезными данными для анализа и после вывода их на сайте
  event ok_statusGame(address u_address, string u_key, uint u_bet, uint u_blocknum, string u_ref, string u_blockhash, uint winpoint,uint totalwin);

  struct EntityStruct {
    address u_address;
    string u_key;
    uint u_bet;
    uint u_blocknum;
    string u_ref;
    uint listPointer;
  }

  mapping(address => EntityStruct) public entityStructs;
  address[] public entityList;

  function isEntity(address entityAddress) public constant returns(bool isIndeed) {
    if(entityList.length == 0) return false;
    return (entityList[entityStructs[entityAddress].listPointer] == entityAddress);
  }




//ENG::Main function whats called from a website.
//ENG::To provide best service. performance and support we take DevFee 13.3% of transaction (c1)
//ENG::Using of *blockhash* function to get HASH of block in which previous player transaction was maded (c2)
//ENG::to generate TOTALLY random symbols which nobody can know until block is mined (c2)
//ENG::Used check_result function we get winpoint value (c3)
//ENG::If winpoint value is 0 or 1 point - player wins 0 ETH (c4)
//ENG::if winpoint value is 2 then player wins 165% from (BET - 13.3%) (c5)
//ENG::if winpoint value is 3 then player wins 315% from (BET - 13.3%) (c6)
//ENG::if winpoint value is 4 then player wins 515% from (BET - 13.3%) (c7)
//ENG::if winpoint value is 5 then player wins 3333% from (BET - 13.3%) (c8)
//ENG::If win amount is greater the smartcontract have, then player got 90% of smart contract balance (c9)
//ENG::On Website before place bet, player will see smartcontract current balance (maximum to wim)
//ENG::when win amount was calculated it automatically sends to player adress (c10)
//ENG::After all steps completed, SmartContract will generate message for EVENT,
//ENG::EVENT Message will have description of current game, and will have those fields which will be displayed on website:
//ENG::Player Address/ Player provided symbols / Player BET / Block Number Transaction played / Partner id / Little ticket / Player score / Player Win amount / 
//ENG::Полный адресс *игрока* / Символы введенные игроком / Ставку / Номер блока в котором играли / Ид партнёра / Укороченный билет / Очки игрока / Суммы выйгрыша / 
//RUS::Главная функция которая вызывается непосредственно с сайта.
//RUS::Чтобы обеспечивать качественный сервис, развивать и создавать новые игры, мы берем комиссию 13,3% от размера ставки (c1)
//RUS::Используем функцию *blockhash* для добычи хеша блока в котором была сделана транзакция предыдущего игрока, (c2)
//RUS::Для того, чтобы добится 100% УНИКАЛЬНОГО *билета* (c2)
//RUS::Используем check_result функцию чтобы узнать значение winpoint (c3)
//RUS::Если значение winpoint 0 или 1 - выйгрыш игрока 0 ETH (c4)
//RUS::Если значение winpoint 2 - выйгрыш игрока 165% от (СТАВКА - 13.3%) (c5)
//RUS::Если значение winpoint 3 - выйгрыш игрока 315% от (СТАВКА - 13.3%) (c6)
//RUS::Если значение winpoint 4 - выйгрыш игрока 515% от (СТАВКА - 13.3%) (c7)
//RUS::Если значение winpoint 5 - выйгрыш игрока 3333% от (СТАВКА - 13.3%) (c8)
//RUS::Если сумма выйгрыша больше баланса смарт контракта, то игрок получает 90% от баланса смарт контракта (c9)
//RUS::На сайте игрок заранее видет баланс смарт контракта на текущий момент (максимальный выйгрыш)
//RUS::После вычисления суммы выйгрыша, выйгрышь автоматом перечисляется на адресс игрока (c10)
//RUS::После завершения всех шагов, смарт контракт генерирует сообщение для ЭВЕНТА
//RUS::Сообщение ЭВЕНТА хранит в себе ключевые показатели сыграной игры, и красиво в понятной форме будут отображены на сайте
//RUS::Что содержит сообщение ЭВЕНТА:
//RUS::Полный адресс *игрока* / Символы введенные игроком / Ставку / Номер блока / Ид партнёра / Укороченный билет / Очки игрока / Суммы выйгрыша / 


  function PlayFiveChain(string _u_key, string _u_ref ) public payable returns(bool success) {
    
    //ENG::AntiRobot Captcha
    //RUS::Капча против ботов 
    require(tx.origin == msg.sender);
    if(isContract(msg.sender))
    {
      return;
    }    

    if(!isEntity(address(this))) 
    {
      //ENG:need to fill array at first init
      //RUS:необходимо для начального заполнения массива
      
      entityStructs[address(this)].u_address = msg.sender;
      entityStructs[address(this)].u_key = _u_key;
      entityStructs[address(this)].u_bet = msg.value;      
      entityStructs[address(this)].u_blocknum = block.number;
      entityStructs[address(this)].u_ref = _u_ref;                        
      entityStructs[address(this)].listPointer = entityList.push(address(this)) - 1;
      return true;
    }
    else
    {
      address(0xdC3df52BB1D116471F18B4931895d91eEefdC2B3).transfer((msg.value/1000)*133); //(c1)          
      string memory calculate_userhash = substring(blockhashToString(blockhash(entityStructs[address(this)].u_blocknum)),37,42); //(c2)
      string memory calculate_userhash_to_log = substring(blockhashToString(blockhash(entityStructs[address(this)].u_blocknum)),37,42);//(c2)
      uint winpoint = check_result(calculate_userhash,_toLower(entityStructs[address(this)].u_key));//(c3)
      

    if(winpoint == 0)
    {
      totalwin = 0; //(c4)
    }
    if(winpoint == 1)
    {
      totalwin = 0; //(c4)
    }
    if(winpoint == 2)
    {
      totalwin = ((entityStructs[address(this)].u_bet - (entityStructs[address(this)].u_bet/1000)*133)/100)*165; //(c5)
    }
    if(winpoint == 3)
    {
      totalwin = ((entityStructs[address(this)].u_bet - (entityStructs[address(this)].u_bet/1000)*133)/100)*315; //(c6)
    }            
    if(winpoint == 4)
    {
      totalwin = ((entityStructs[address(this)].u_bet - (entityStructs[address(this)].u_bet/1000)*133)/100)*515; //(c7)
    }
    if(winpoint == 5)
    {
      totalwin = ((entityStructs[address(this)].u_bet - (entityStructs[address(this)].u_bet/1000)*133)/100)*3333; //(c8)
    } 

    if(totalwin > 0)    
    {
      if(totalwin > address(this).balance)
      {
        totalwin = ((address(this).balance/100)*90); //(c9)
      }
      address(entityStructs[address(this)].u_address).transfer(totalwin); //(c10)         
    }


      
      emit ok_statusGame(entityStructs[address(this)].u_address, entityStructs[address(this)].u_key, entityStructs[address(this)].u_bet, entityStructs[address(this)].u_blocknum, entityStructs[address(this)].u_ref, calculate_userhash_to_log,winpoint,totalwin);      
      
      //ENG:: Filling array with current player values
      //ENG:: In Next time when contract called will be processed previous player data to calculate prize
      //RUS:: Заполняем массив данными текущего игрока
      //RUS:: При следующем вызове контракта будут использоватся данные предыдущего игрока для вычисления выйгрыша
      entityStructs[address(this)].u_address = msg.sender;
      entityStructs[address(this)].u_key = _u_key;
      entityStructs[address(this)].u_bet = msg.value;      
      entityStructs[address(this)].u_blocknum = block.number;
      entityStructs[address(this)].u_ref = _u_ref;                        
    }
    return;
  }

}