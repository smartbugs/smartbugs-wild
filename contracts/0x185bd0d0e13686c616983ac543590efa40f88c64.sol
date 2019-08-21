pragma solidity 0.4.25;

// Констракт.
contract MyMileage {

    // Владелец контракта.
    address private owner;

    // Отображение хеш сумм фотографий и дат.
    mapping(bytes32 => uint) private map;

    // Модификатор доступа "только владелец".
    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    // Конструктор.
    constructor() public {
        owner = msg.sender;
    }

    // Добавление записи.
    function put(bytes32 imageHash) onlyOwner public {

        // Проверка пустого значения по ключу.
        require(free(imageHash));

        // Установка значения.
        map[imageHash] = now;
    }

    // Проверка наличия значения.
    function free(bytes32 imageHash) view public returns (bool) {
        return map[imageHash] == 0;
    }

    // Получение значения.
    function get(bytes32 imageHash) view public returns (uint) {
        return map[imageHash];
    }
    
    // Получение кода подтверждения 
    // в виде хеша блока.
    function getConfirmationCode() view public returns (bytes32) {
        return blockhash(block.number - 6);
    }
}