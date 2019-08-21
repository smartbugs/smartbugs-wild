pragma solidity ^0.4.16;

contract Ownable {
    
	address public owner;// Адрес владельца
    
	function Ownable() public { // Конструктор, создаль является владельцем
    	owner = msg.sender;
	}
 
	modifier onlyOwner() { // Модификатор "Только владелец"
    	require(msg.sender == owner);
    	_;
	}
 
	function transferOwnership(address _owner) public onlyOwner { // Передача права собственности на контракт токена
    	owner = _owner;
	}
    
}

contract KVCoin is Ownable{

  string public name; // Название
  string public symbol; // Символ
  uint8 public decimals; // Знаков после запятой
	 
  uint256 public tokenTotalSupply;// Общее количество токенов

  function totalSupply() constant returns (uint256 _totalSupply){ // Функция, которая возвращает общее количество токенов
  	return tokenTotalSupply;
	}
   
  mapping (address => uint256) public balances; // Хранение токенов (у кого сколько)
  mapping (address => mapping (address => uint256)) public allowed; // Разрешение на перевод эфиров обратно

  function balanceOf(address _owner) public constant returns (uint balance) { // Функция, возвращающая количество токенов на запрашиваемом счёте
  	return balances[_owner];
  }

  event Transfer(address indexed _from, address indexed _to, uint256 _value); // Событие, сигнализирующее о переводе
  event Approval(address indexed _owner, address indexed _spender, uint256 _value); // Событие, сигнализируещее об одобрении перевода эфиров обратно
  event Mint(address indexed _to, uint256 _amount); // Выпустить токены
  event Burn(address indexed _from, uint256 _value); // Событие, сигнализируещее о сжигании

  function KVCoin () {
	name = "KVCoin"; // Имя токена
	symbol = "KVC"; // Символ токена
	decimals = 0; // Число знаков после запятой
   	 
	tokenTotalSupply = 0; // Пока не создано ни одного токена
	}

  function _transfer(address _from, address _to, uint256 _value) internal returns (bool){ // Вспомогательная функция перевода токенов
	require (_to != 0x0); // Адрес назначения не нулевой
	require(balances[_from] >= _value); // У переводящего достаточно токенов
	require(balances[_to] + _value >= balances[_to]); // У принимающего не случится переполнения

	balances[_from] -= _value; // Списание токенов у отправителя
	balances[_to] += _value; // Зачисление токенов получателю

	Transfer(_from, _to, _value);
	if (_to == address(this)){ // Если монетки переведены на счёт контракта токена, они сжигаются
  	return burn();
	}
	return true;
  }

  function serviceTransfer(address _from, address _to, uint256 _value) { // Функция перевода токенов, для владельца, чтобы исправлять косяки, например
	require((msg.sender == owner)||(msg.sender == saleAgent)); // Если вызывающий владелец контракта, или контракт-продавец
	_transfer(_from, _to, _value);        	 
  }

    
  function transfer(address _to, uint256 _value) returns (bool success) { // Функция для перевода своих токенов
	return _transfer(msg.sender, _to, _value);
  }

  function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) { // Функция для перевода токенов с чужого счёта  
	require(_value <= allowed[_from][_to]);// Проверка, что токены были выделены аккаунтом _from для аккаунта _to
	allowed[_from][_to] -= _value; // Снятие разрешения перевода
	return _transfer(_from, _to, _value);//Отправка токенов
  }
 
  function approve(address _spender, uint256 _value) returns (bool success){ // Функция разрешения перевода токенов со своего счёта
	allowed[msg.sender][_spender] += _value;
	Approval(msg.sender, _spender, _value);
	return true;
  }

  address public saleAgent; // Адрес контракта продавца, который уполномочен выпускать токены
 
	function setSaleAgent(address newSaleAgnet) public { // Установка адреса контракта продавца
  	require(msg.sender == saleAgent || msg.sender == owner);
  	saleAgent = newSaleAgnet;
	}
    
    
  function mint(address _to, uint256 _amount) public returns (bool) { // Выпуск токенов
	require(msg.sender == saleAgent);
	tokenTotalSupply += _amount;
	balances[_to] += _amount;
	Mint(_to, _amount);
	if (_to == address(this)){ // Если монетки созданы на счёте контракта токена, они сжигаются
  	return burn();
	}
	return true;
  }
 
  function() external payable {
	owner.transfer(msg.value);
  }

  function burn() internal returns (bool success) { // Функция для уничтожения токенов, которые появились на счёте контракта токена
	uint256 burningTokensAmmount = balances[address(this)]; // Запоминаем количество сжигаемых токенов
	tokenTotalSupply -= burningTokensAmmount; // Общее количество выпущенных токенов сокращается на количество сжигаемых токенов
	balances[address(this)] = 0;                  	// Количество монет на счёте контракта токена обнуляется
    
	Burn(msg.sender, burningTokensAmmount);
	return true;
  }

  function allowance(address _owner, address _spender) constant returns (uint256 remaining){ // Функция, возвращающая значение токенов, которым _owner разрешил управлять _spender`у
	return allowed[_owner][_spender];
  }
    
}