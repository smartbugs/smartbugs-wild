pragma solidity ^0.4.24;

/*
  Реализация смарт контракта по типу 6 друзей
*/

contract SixFriends {

    using SafeMath for uint;

    address public ownerAddress; //Адресс владельца
    uint private percentMarketing = 8; //Проценты на маркетинг
    uint private percentAdministrator = 2; //Проценты администрации

    uint public c_total_hexagons; //Количество гексагонов всего
    mapping(address =>  uint256) public Bills; //Баланс для вывода

    uint256 public BillsTotal; //суммарная проведенная сумма

    struct Node {
        uint256 usd;
        bool cfw;
        uint256 min; //Стоимость входа
        uint c_hexagons; //Количество гексагонов
        mapping(address => bytes32[]) Addresses; //Адресс => уникальные ссылки
        mapping(address => uint256[6]) Statistics; //Адресс => статистика по рефералам
        mapping(bytes32 => address[6]) Hexagons; //Уникальная ссылка (keccak256) => 6 кошельков
    }

    mapping (uint256 => Node) public Nodes; //все типы

    //Проверяет что сумма перевода достаточна
    modifier enoughMoney(uint256 tp) {
        require (msg.value >= Nodes[0].min, "Insufficient funds");
        _;
    }

    //Проверяет что тот кто перевел владелец кошелька
    modifier onlyOwner {
        require (msg.sender == ownerAddress, "Only owner");
        _;
    }

    //Ранее создан
    modifier allReadyCreate(uint256 tp) {
        require (Nodes[tp].cfw == false);
        _;
    }

    //Проверяю что человек запросивший являетя владельцем баланса
    modifier recipientOwner(address recipient) {
        require (Bills[recipient] > 0);
        require (msg.sender == recipient);
        _;
    }

    //Функция для оплаты
    function pay(bytes32 ref, uint256 tp) public payable enoughMoney(tp) {

        if (Nodes[tp].Hexagons[ref][0] == 0) ref = Nodes[tp].Addresses[ownerAddress][0]; //Если ref не найдена то берется первое значение

        createHexagons(ref, tp); //Передаю текущую ref, добавляю новые 6 друзей

        uint256 marketing_pay = ((msg.value / 100) * (percentMarketing + percentAdministrator));
        uint256 friend_pay = msg.value - marketing_pay;

        //Перевожу деньги на счета клиентов
        for(uint256 i = 0; i < 6; i++)
            Bills[Nodes[tp].Hexagons[ref][i]] += friend_pay.div(6);

        //Перевожу коммисию на маркетинг
        Bills[ownerAddress] += marketing_pay;

        //Суммирую всего выплат
        BillsTotal += msg.value;
    }

    function getHexagons(bytes32 ref, uint256 tp) public view returns (address, address, address, address, address, address)
    {
        return (Nodes[tp].Hexagons[ref][0], Nodes[tp].Hexagons[ref][1], Nodes[tp].Hexagons[ref][2], Nodes[tp].Hexagons[ref][3], Nodes[tp].Hexagons[ref][4], Nodes[tp].Hexagons[ref][0]);
    }

    //Запросить деньги и обнулить счет
    function getMoney(address recipient) public recipientOwner(recipient) {
        recipient.transfer(Bills[recipient]);
        Bills[recipient] = 0;
    }

    //Передаю переданную рефку и добавляю новый гексагон
    function createHexagons(bytes32 ref, uint256 tp) internal {

        Nodes[tp].c_hexagons++; //Увеличиваю счетчик гексагонов и транзакций
        c_total_hexagons++; //Увеличиваю счетчик гексагонов и транзакций

        bytes32 new_ref = createRef(Nodes[tp].c_hexagons);

        //Прохожу по переданной рефке и создаю кошельки
        for(uint8 i = 0; i < 5; i++)
        {
            Nodes[tp].Hexagons[new_ref][i] = Nodes[tp].Hexagons[ref][i + 1]; //Добавляю новый гексагон
            Nodes[tp].Statistics[Nodes[tp].Hexagons[ref][i]][5 - i]++; //Добавляю статистку
        }

        Nodes[tp].Statistics[Nodes[tp].Hexagons[ref][i]][0]++; //Добавляю статистку

        Nodes[tp].Hexagons[new_ref][5] = msg.sender;
        Nodes[tp].Addresses[msg.sender].push(new_ref); //Добавляю рефку
    }

    //Создаю новый гексагон с указанием его стоимости и порядкового номера
    function createFirstWallets(uint256 usd, uint256 tp) public onlyOwner allReadyCreate(tp) {

        bytes32 new_ref = createRef(1);

        Nodes[tp].Hexagons[new_ref] = [ownerAddress, ownerAddress, ownerAddress, ownerAddress, ownerAddress, ownerAddress];
        Nodes[tp].Addresses[ownerAddress].push(new_ref);

        Nodes[tp].c_hexagons = 1; //Количество гексагонов
        Nodes[tp].usd = usd; //Сколько стоит членский взнос в эту ноду в долларах
        Nodes[tp].cfw = true; //Нода помечается как созданная

        c_total_hexagons++;
    }

    //Создаю реферальную ссылку на основе номера блока и типа контракта
    function createRef(uint hx) internal pure returns (bytes32) {
        uint256 _unixTimestamp;
        uint256 _timeExpired;
        return keccak256(abi.encodePacked(hx, _unixTimestamp, _timeExpired));
    }

    //Получаю количество ссылок для адреса
    function countAddressRef(address adr, uint256 tp) public view returns (uint count) {
        count = Nodes[tp].Addresses[adr].length;
    }

    //Получаю ссылку
    function getAddress(address adr, uint256 i, uint256 tp) public view returns(bytes32) {
        return Nodes[tp].Addresses[adr][i];
    }

    //Возвращение статистики
    function getStatistics(address adr, uint256 tp) public view returns(uint256, uint256, uint256, uint256, uint256, uint256)
    {
        return (Nodes[tp].Statistics[adr][0], Nodes[tp].Statistics[adr][1], Nodes[tp].Statistics[adr][2], Nodes[tp].Statistics[adr][3], Nodes[tp].Statistics[adr][4], Nodes[tp].Statistics[adr][5]);
    }

    //Устанавливаю стоимость входа
    function setMin(uint value, uint256 tp) public onlyOwner {
        Nodes[tp].min = value;
    }

    //Получение минимальной стоимости
    function getMin(uint256 tp) public view returns (uint256) {
        return Nodes[tp].min;
    }

    //Получаю тотал денег
    function getBillsTotal() public view returns (uint256) {
        return BillsTotal;
    }

    constructor() public {
        ownerAddress = msg.sender;
    }
}

library SafeMath {
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        assert(c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a / b;
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }
}