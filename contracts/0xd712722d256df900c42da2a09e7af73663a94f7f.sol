pragma solidity ^0.4.16;

contract SafeMath {

    function safeAdd(uint256 x, uint256 y) view internal returns (uint256) {
        uint256 z = x + y;
        assert((z >= x) && (z >= y));
        return z;
    }

    function safeSubtract(uint256 x, uint256 y) view internal returns (uint256) {
        assert(x >= y);
        uint256 z = x - y;
        return z;
    }

    function safeMult(uint256 x, uint256 y) view internal returns (uint256) {
        uint256 z = x * y;
        assert((x == 0) || (z / x == y));
        return z;
    }

    function safeDiv(uint256 a, uint256 b) view internal returns (uint256) {
        assert(b > 0);
        uint c = a / b;
        assert(a == b * c + a % b);
        return c;
    }
}

contract Owner {
	
	// Адреса владельцев
	mapping ( address => bool ) public ownerAddressMap;
	// Соответсвие адреса владельца и его номера
	mapping ( address => uint256 ) public ownerAddressNumberMap;
	// список менеджеров
	mapping ( uint256 => address ) public ownerListMap;
	// сколько всего менеджеров
	uint256 public ownerCountInt = 0;
	
	// событие "изменение в контракте"
	event ContractManagementUpdate( string _type, address _initiator, address _to, bool _newvalue );

	// модификатор - если смотрит владелец
	modifier isOwner {
        require( ownerAddressMap[msg.sender]==true );
        _;
    }
	
	// создание/включение владельца
	function ownerOn( address _onOwnerAddress ) external isOwner returns (bool retrnVal) {
		// Check if it's a non-zero address
		require( _onOwnerAddress != address(0) );
		// если такой владелец есть (стартового владельца удалить нельзя)
		if ( ownerAddressNumberMap[ _onOwnerAddress ]>0 )
		{
			// если такой владелец отключен, влючим его обратно
			if ( !ownerAddressMap[ _onOwnerAddress ] )
			{
				ownerAddressMap[ _onOwnerAddress ] = true;
				ContractManagementUpdate( "Owner", msg.sender, _onOwnerAddress, true );
				retrnVal = true;
			}
			else
			{
				retrnVal = false;
			}
		}
		// если такого владеьца нет
		else
		{
			ownerAddressMap[ _onOwnerAddress ] = true;
			ownerAddressNumberMap[ _onOwnerAddress ] = ownerCountInt;
			ownerListMap[ ownerCountInt ] = _onOwnerAddress;
			ownerCountInt++;
			ContractManagementUpdate( "Owner", msg.sender, _onOwnerAddress, true );
			retrnVal = true;
		}
	}
	
	// отключение менеджера
	function ownerOff( address _offOwnerAddress ) external isOwner returns (bool retrnVal) {
		// если такой менеджер есть и он не 0-вой, а также активен
		// 0-вой менеджер не может быть отключен
		if ( ownerAddressNumberMap[ _offOwnerAddress ]>0 && ownerAddressMap[ _offOwnerAddress ] )
		{
			ownerAddressMap[ _offOwnerAddress ] = false;
			ContractManagementUpdate( "Owner", msg.sender, _offOwnerAddress, false );
			retrnVal = true;
		}
		else
		{
			retrnVal = false;
		}
	}

	// конструктор, при создании контракта добалвяет создателя в "неудаляемые" создатели
	function Owner() public {
		// создаем владельца
		ownerAddressMap[ msg.sender ] = true;
		ownerAddressNumberMap[ msg.sender ] = ownerCountInt;
		ownerListMap[ ownerCountInt ] = msg.sender;
		ownerCountInt++;
	}
}

contract SpecialManager is Owner {

	// адреса специальных менеджеров
	mapping ( address => bool ) public specialManagerAddressMap;
	// Соответсвие адреса специального менеджера и его номера
	mapping ( address => uint256 ) public specialManagerAddressNumberMap;
	// список специальноых менеджеров
	mapping ( uint256 => address ) public specialManagerListMap;
	// сколько всего специальных менеджеров
	uint256 public specialManagerCountInt = 0;
	
	// модификатор - если смотрит владелец или специальный менеджер
	modifier isSpecialManagerOrOwner {
        require( specialManagerAddressMap[msg.sender]==true || ownerAddressMap[msg.sender]==true );
        _;
    }
	
	// создание/включение специального менеджера
	function specialManagerOn( address _onSpecialManagerAddress ) external isOwner returns (bool retrnVal) {
		// Check if it's a non-zero address
		require( _onSpecialManagerAddress != address(0) );
		// если такой менеджер есть
		if ( specialManagerAddressNumberMap[ _onSpecialManagerAddress ]>0 )
		{
			// если такой менеджер отключен, влючим его обратно
			if ( !specialManagerAddressMap[ _onSpecialManagerAddress ] )
			{
				specialManagerAddressMap[ _onSpecialManagerAddress ] = true;
				ContractManagementUpdate( "Special Manager", msg.sender, _onSpecialManagerAddress, true );
				retrnVal = true;
			}
			else
			{
				retrnVal = false;
			}
		}
		// если такого менеджера нет
		else
		{
			specialManagerAddressMap[ _onSpecialManagerAddress ] = true;
			specialManagerAddressNumberMap[ _onSpecialManagerAddress ] = specialManagerCountInt;
			specialManagerListMap[ specialManagerCountInt ] = _onSpecialManagerAddress;
			specialManagerCountInt++;
			ContractManagementUpdate( "Special Manager", msg.sender, _onSpecialManagerAddress, true );
			retrnVal = true;
		}
	}
	
	// отключение менеджера
	function specialManagerOff( address _offSpecialManagerAddress ) external isOwner returns (bool retrnVal) {
		// если такой менеджер есть и он не 0-вой, а также активен
		// 0-вой менеджер не может быть отключен
		if ( specialManagerAddressNumberMap[ _offSpecialManagerAddress ]>0 && specialManagerAddressMap[ _offSpecialManagerAddress ] )
		{
			specialManagerAddressMap[ _offSpecialManagerAddress ] = false;
			ContractManagementUpdate( "Special Manager", msg.sender, _offSpecialManagerAddress, false );
			retrnVal = true;
		}
		else
		{
			retrnVal = false;
		}
	}


	// конструктор, добавляет создателя в суперменеджеры
	function SpecialManager() public {
		// создаем менеджера
		specialManagerAddressMap[ msg.sender ] = true;
		specialManagerAddressNumberMap[ msg.sender ] = specialManagerCountInt;
		specialManagerListMap[ specialManagerCountInt ] = msg.sender;
		specialManagerCountInt++;
	}
}

contract Manager is SpecialManager {
	
	// адрес менеджеров
	mapping ( address => bool ) public managerAddressMap;
	// Соответсвие адреса менеджеров и его номера
	mapping ( address => uint256 ) public managerAddressNumberMap;
	// список менеджеров
	mapping ( uint256 => address ) public managerListMap;
	// сколько всего менеджеров
	uint256 public managerCountInt = 0;
	
	// модификатор - если смотрит владелец или менеджер
	modifier isManagerOrOwner {
        require( managerAddressMap[msg.sender]==true || ownerAddressMap[msg.sender]==true );
        _;
    }
	
	// создание/включение менеджера
	function managerOn( address _onManagerAddress ) external isOwner returns (bool retrnVal) {
		// Check if it's a non-zero address
		require( _onManagerAddress != address(0) );
		// если такой менеджер есть
		if ( managerAddressNumberMap[ _onManagerAddress ]>0 )
		{
			// если такой менеджер отключен, влючим его обратно
			if ( !managerAddressMap[ _onManagerAddress ] )
			{
				managerAddressMap[ _onManagerAddress ] = true;
				ContractManagementUpdate( "Manager", msg.sender, _onManagerAddress, true );
				retrnVal = true;
			}
			else
			{
				retrnVal = false;
			}
		}
		// если такого менеджера нет
		else
		{
			managerAddressMap[ _onManagerAddress ] = true;
			managerAddressNumberMap[ _onManagerAddress ] = managerCountInt;
			managerListMap[ managerCountInt ] = _onManagerAddress;
			managerCountInt++;
			ContractManagementUpdate( "Manager", msg.sender, _onManagerAddress, true );
			retrnVal = true;
		}
	}
	
	// отключение менеджера
	function managerOff( address _offManagerAddress ) external isOwner returns (bool retrnVal) {
		// если такой менеджер есть и он не 0-вой, а также активен
		// 0-вой менеджер не может быть отключен
		if ( managerAddressNumberMap[ _offManagerAddress ]>0 && managerAddressMap[ _offManagerAddress ] )
		{
			managerAddressMap[ _offManagerAddress ] = false;
			ContractManagementUpdate( "Manager", msg.sender, _offManagerAddress, false );
			retrnVal = true;
		}
		else
		{
			retrnVal = false;
		}
	}


	// конструктор, добавляет создателя в менеджеры
	function Manager() public {
		// создаем менеджера
		managerAddressMap[ msg.sender ] = true;
		managerAddressNumberMap[ msg.sender ] = managerCountInt;
		managerListMap[ managerCountInt ] = msg.sender;
		managerCountInt++;
	}
}

contract Management is Manager {
	
	// текстовое описание контракта
	string public description = "";
	
	// текущий статус разрешения транзакций
	// TRUE - транзакции возможны
	// FALSE - транзакции не возможны
	bool public transactionsOn = false;
	
	// текущий статус эмиссии
	// TRUE - эмиссия возможна, менеджеры могут добавлять в контракт токены
	// FALSE - эмиссия невозможна, менеджеры не могут добавлять в контракт токены
	bool public emissionOn = true;

	// потолок эмиссии
	uint256 public tokenCreationCap = 0;
	
	// модификатор - транзакции возможны
	modifier isTransactionsOn{
        require( transactionsOn );
        _;
    }
	
	// модификатор - эмиссия возможна
	modifier isEmissionOn{
        require( emissionOn );
        _;
    }
	
	// функция изменения статуса транзакций
	function transactionsStatusUpdate( bool _on ) external isOwner
	{
		transactionsOn = _on;
	}
	
	// функция изменения статуса эмиссии
	function emissionStatusUpdate( bool _on ) external isOwner
	{
		emissionOn = _on;
	}
	
	// установка потолка эмиссии
	function tokenCreationCapUpdate( uint256 _newVal ) external isOwner
	{
		tokenCreationCap = _newVal;
	}
	
	// событие, "смена описания"
	event DescriptionPublished( string _description, address _initiator);
	
	// изменение текста
	function descriptionUpdate( string _newVal ) external isOwner
	{
		description = _newVal;
		DescriptionPublished( _newVal, msg.sender );
	}
}

// Токен-контракт FoodCoin Ecosystem
contract FoodcoinEcosystem is SafeMath, Management {
	
	// название токена
	string public constant name = "FoodCoin EcoSystem";
	// короткое название токена
	string public constant symbol = "FOOD";
	// точность токена (знаков после запятой для вывода в кошельках)
	uint256 public constant decimals = 8;
	// общее кол-во выпущенных токенов
	uint256 public totalSupply = 0;
	
	// состояние счета
	mapping ( address => uint256 ) balances;
	// список всех счетов
	mapping ( uint256 => address ) public balancesListAddressMap;
	// соответсвие счета и его номера
	mapping ( address => uint256 ) public balancesListNumberMap;
	// текстовое описание счета
	mapping ( address => string ) public balancesAddressDescription;
	// общее кол-во всех счетов
	uint256 balancesCountInt = 1;
	
	// делегирование на управление счетом на определенную сумму
	mapping ( address => mapping ( address => uint256 ) ) allowed;
	
	
	// событие - транзакция
	event Transfer(address _from, address _to, uint256 _value, address _initiator);
	
	// событие делегирование управления счетом
	event Approval(address indexed _owner, address indexed _spender, uint256 _value);
	
	// событие - эмиссия
	event TokenEmissionEvent( address initiatorAddress, uint256 amount, bool emissionOk );
	
	// событие - списание средств
	event WithdrawEvent( address initiatorAddress, address toAddress, bool withdrawOk, uint256 withdrawValue, uint256 newBalancesValue );
	
	
	// проссмотра баланса счета
	function balanceOf( address _owner ) external view returns ( uint256 )
	{
		return balances[ _owner ];
	}
	// Check if a given user has been delegated rights to perform transfers on behalf of the account owner
	function allowance( address _owner, address _initiator ) external view returns ( uint256 remaining )
	{
		return allowed[ _owner ][ _initiator ];
	}
	// общее кол-во счетов
	function balancesQuantity() external view returns ( uint256 )
	{
		return balancesCountInt - 1;
	}
	
	// функция непосредственного перевода токенов. Если это первое получение средств для какого-то счета, то также создается детальная информация по этому счету
	function _addClientAddress( address _balancesAddress, uint256 _amount ) internal
	{
		// check if this address is not on the list yet
		if ( balancesListNumberMap[ _balancesAddress ] == 0 )
		{
			// add it to the list
			balancesListAddressMap[ balancesCountInt ] = _balancesAddress;
			balancesListNumberMap[ _balancesAddress ] = balancesCountInt;
			// increment account counter
			balancesCountInt++;
		}
		// add tokens to the account 
		balances[ _balancesAddress ] = safeAdd( balances[ _balancesAddress ], _amount );
	}
	// Internal function that performs the actual transfer (cannot be called externally)
	function _transfer( address _from, address _to, uint256 _value ) internal isTransactionsOn returns ( bool success )
	{
		// If the amount to transfer is greater than 0, and sender has funds available
		if ( _value > 0 && balances[ _from ] >= _value )
		{
			// Subtract from sender account
			balances[ _from ] -= _value;
			// Add to receiver's account
			_addClientAddress( _to, _value );
			// Perform the transfer
			Transfer( _from, _to, _value, msg.sender );
			// Successfully completed transfer
			return true;
		}
		// Return false if there are problems
		else
		{
			return false;
		}
	}
	// функция перевода токенов
	function transfer(address _to, uint256 _value) external isTransactionsOn returns ( bool success )
	{
		return _transfer( msg.sender, _to, _value );
	}
	// функция перевода токенов с делегированного счета
	function transferFrom(address _from, address _to, uint256 _value) external isTransactionsOn returns ( bool success )
	{
		// Check if the transfer initiator has permissions to move funds from the sender's account
		if ( allowed[_from][msg.sender] >= _value )
		{
			// If yes - perform transfer 
			if ( _transfer( _from, _to, _value ) )
			{
				// Decrease the total amount that initiator has permissions to access
				allowed[_from][msg.sender] = safeSubtract(allowed[_from][msg.sender], _value);
				return true;
			}
			else
			{
				return false;
			}
		}
		else
		{
			return false;
		}
	}
	// функция делегирования управления счетом на определенную сумму
	function approve( address _initiator, uint256 _value ) external isTransactionsOn returns ( bool success )
	{
		// Grant the rights for a certain amount of tokens only
		allowed[ msg.sender ][ _initiator ] = _value;
		// Initiate the Approval event
		Approval( msg.sender, _initiator, _value );
		return true;
	}
	
	// функция эмиссии (менеджер или владелец контракта создает токены и отправляет их на определенный счет)
	function tokenEmission(address _reciever, uint256 _amount) external isManagerOrOwner isEmissionOn returns ( bool returnVal )
	{
		// Check if it's a non-zero address
		require( _reciever != address(0) );
		// Calculate number of tokens after generation
		uint256 checkedSupply = safeAdd( totalSupply, _amount );
		// сумма к эмиссии
		uint256 amountTmp = _amount;
		// Если потолок эмиссии установлен, то нельзя выпускать больше этого потолка
		if ( tokenCreationCap > 0 && tokenCreationCap < checkedSupply )
		{
			amountTmp = 0;
		}
		// если попытка добавить больше 0-ля токенов
		if ( amountTmp > 0 )
		{
			// If no error, add generated tokens to a given address
			_addClientAddress( _reciever, amountTmp );
			// increase total supply of tokens
			totalSupply = checkedSupply;
			TokenEmissionEvent( msg.sender, _amount, true);
		}
		else
		{
			returnVal = false;
			TokenEmissionEvent( msg.sender, _amount, false);
		}
	}
	
	// функция списания токенов
	function withdraw( address _to, uint256 _amount ) external isSpecialManagerOrOwner returns ( bool returnVal, uint256 withdrawValue, uint256 newBalancesValue )
	{
		// check if this is a valid account
		if ( balances[ _to ] > 0 )
		{
			// сумма к списанию
			uint256 amountTmp = _amount;
			// нельзя списать больше, чем есть на счету
			if ( balances[ _to ] < _amount )
			{
				amountTmp = balances[ _to ];
			}
			// проводим списывание
			balances[ _to ] = safeSubtract( balances[ _to ], amountTmp );
			// меняем текущее общее кол-во токенов
			totalSupply = safeSubtract( totalSupply, amountTmp );
			// возвращаем ответ
			returnVal = true;
			withdrawValue = amountTmp;
			newBalancesValue = balances[ _to ];
			WithdrawEvent( msg.sender, _to, true, amountTmp, balances[ _to ] );
		}
		else
		{
			returnVal = false;
			withdrawValue = 0;
			newBalancesValue = 0;
			WithdrawEvent( msg.sender, _to, false, _amount, balances[ _to ] );
		}
	}
	
	// добавление описания к счету
	function balancesAddressDescriptionUpdate( string _newDescription ) external returns ( bool returnVal )
	{
		// если такой аккаунт есть или владелец контракта
		if ( balancesListNumberMap[ msg.sender ] > 0 || ownerAddressMap[msg.sender]==true )
		{
			balancesAddressDescription[ msg.sender ] = _newDescription;
			returnVal = true;
		}
		else
		{
			returnVal = false;
		}
	}
}