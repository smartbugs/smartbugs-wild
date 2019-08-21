pragma solidity ^0.4.2;

/* Родительский контракт */
contract Owned {

    /* Адрес владельца контракта*/
    address owner;

    /* Конструктор контракта, вызывается при первом запуске */
    function Owned() {
        owner = msg.sender;
    }

    /* Изменить владельца контракта, newOwner - адрес нового владельца */
    function changeOwner(address newOwner) onlyowner {
        owner = newOwner;
    }

    /* Модификатор для ограничения доступа к функциям только для владельца */
    modifier onlyowner() {
        if (msg.sender==owner) _;
    }

    /* Удалить контракт */
    function kill() onlyowner {
        if (msg.sender == owner) suicide(owner);
    }
}

/* Основной контракт, наследует контракт Owned */
contract Gods is Owned {

    /* Структура представляющая участника */
    struct Member {
        address member;
        string name;
        string surname;
        string patronymic;
        uint birthDate;
        string birthPlace;
        string avatarHash;
        uint avatarID;
        bool approved;
        uint memberSince;
    }

    /* Массив участников */
    Member[] public members;

    /* Маппинг адрес участника -> id участника */
    mapping (address => uint) public memberId;

    /* Маппинг id участника -> приватный ключ кошелька */
    mapping (uint => string) public pks;

    /* Маппинг id участника -> дополнительные данные на участника в формате JSON */
    mapping (uint => string) public memberData;

    /* Событие при добавлении участника, параметры - адрес, ID */
    event MemberAdded(address member, uint id);

    /* Событие при изменении участника, параметры - адрес, ID */
    event MemberChanged(address member, uint id);

    /* Конструктор контракта, вызывается при первом запуске */
    function Gods() {
        /* Добавляем пустого участника для инициализации */
        addMember('', '', '', 0, '', '', 0, '');
    }

    /* функция добавления и обновления участника, параметры - адрес, имя, фамилия,
     отчество, дата рождения (linux time), место рождения, хэш аватара, ID аватара
     если пользователь с таким адресом не найден, то будет создан новый, в конце вызовется событие
     MemberAdded, если пользователь найден, то будет произведено обновление полей и проставлен флаг
     подтверждения approved */
    function addMember(string name,
        string surname,
        string patronymic,
        uint birthDate,
        string birthPlace,
        string avatarHash,
        uint avatarID,
        string data) onlyowner {
        uint id;
        address member = msg.sender;
        if (memberId[member] == 0) {
            memberId[member] = members.length;
            id = members.length++;
            members[id] = Member({
                member: member,
                name: name,
                surname: surname,
                patronymic: patronymic,
                birthDate: birthDate,
                birthPlace: birthPlace,
                avatarHash: avatarHash,
                avatarID: avatarID,
                approved: (owner == member),
                memberSince: now
            });
            memberData[id] = data;
            if (member != 0) {
                MemberAdded(member, id);
            }
        } else {
            id = memberId[member];
            Member m = members[id];
            m.approved = true;
            m.name = name;
            m.surname = surname;
            m.patronymic = patronymic;
            m.birthDate = birthDate;
            m.birthPlace = birthPlace;
            m.avatarHash = avatarHash;
            m.avatarID = avatarID;
            memberData[id] = data;
            MemberChanged(member, id);
        }
    }

    /* Функция получения приватного ключа по ID юзера */
    function getPK(uint id) onlyowner constant returns (string) {
        return pks[id];
    }

    /* Функция получения количества юзеров */
    function getMemberCount() constant returns (uint) {
        return members.length - 1;
    }

    /* Функция получения юзера по id
     возвращает массив из полей [имя, фамилия, отчество, дата_рождения, хэш аватара, id аватара] */
    function getMember(uint id) constant returns (
        string name,
        string surname,
        string patronymic,
        uint birthDate,
        string birthPlace,
        string avatarHash,
        uint avatarID,
        string data) {
        Member m = members[id];
        name = m.name;
        surname = m.surname;
        patronymic = m.patronymic;
        birthDate = m.birthDate;
        birthPlace = m.birthPlace;
        avatarHash = m.avatarHash;
        avatarID = m.avatarID;
        data = memberData[id];
    }
}