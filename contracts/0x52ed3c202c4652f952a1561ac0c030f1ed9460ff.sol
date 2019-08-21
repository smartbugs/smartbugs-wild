/*
AvatarNetwork Copyright

Подпись документов v1.2


https://avatarnetwork.io

*/

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
contract Documents is Owned {

    /* Структура представляющая документ */
    struct Document {
        string hash;
        string link;
        string data;
        address creator;
        uint date;
        uint signsCount;
        mapping (uint => Sign) signs;
    }

    /* Структура представляющая подпись */
    struct Sign {
        address member;
        uint date;
    }

    /* Маппинг ID документа -> документ */
    mapping (uint => Document) public documentsIds;

    /* Кол-во документов */
    uint documentsCount = 0;

    /* Событие при подписи документа участником, параметры - адрес участника, ID документа */
    event DocumentSigned(uint id, address member);

    /* Событие при регистрации документа, параметры - ID документа */
    event DocumentRegistered(uint id, string hash);

     /* Конструктор контракта, вызывается при первом запуске */
    function Documents() {
    }

    /* функция добавления документа, параметры - хэш, ссылка, дополнительные данные, создатель.
    Если не передаётся адрес создателя, то будет указан адрес отправителя, в конце вызовется событие DocumentRegistered
    с параметрами id - документа (позиция в массиве documents) и hash - хэш сумма */
    function registerDocument(string hash,
                       string link,
                       string data) {
        address creator = msg.sender;

        uint id = documentsCount + 1;
        documentsIds[id] = Document({
           hash: hash,
           link: link,
           data: data,
           creator: creator,
           date: now,
           signsCount: 0
        });
        documentsCount = id;
        DocumentRegistered(id, hash);
    }

    /* функция добавления подписи в документ, параметры - ID Документа, адрес подписчика.
    Если не передаётся адрес подписчика, то будет указан адрес отправителя,
    в конце вызовется событие DocumentSigned */
    function addSignature(uint id) {
        address member = msg.sender;
        if (documentsCount < id) throw;

        Document d = documentsIds[id];
        uint count = d.signsCount;
        bool signed = false;
        if (count != 0) {
            for (uint i = 0; i < count; i++) {
                if (d.signs[i].member == member) {
                    signed = true;
                    break;
                }
            }
        }

        if (!signed) {
            d.signs[count] = Sign({
                    member: member,
                    date: now
                });
            documentsIds[id].signsCount = count + 1;
            DocumentSigned(id, member);
        }
    }

    /* Функция получения количества документов */
    function getDocumentsCount() constant returns (uint) {
        return documentsCount;
    }

    /* Функция получения документа по ID */
    function getDocument(uint id) constant returns (string hash,
                       string link,
                       string data,
                       address creator,
                       uint date) {
        Document d = documentsIds[id];
        hash = d.hash;
        link = d.link;
        data = d.data;
        creator = d.creator;
        date = d.date;
    }

    /* Функция получения количества подписей по ID документа */
    function getDocumentSignsCount(uint id) constant returns (uint) {
        Document d = documentsIds[id];
        return d.signsCount;
    }

    /* Функция получения подписи документов, параметры - ID документа, позиция подписи в массиве */
    function getDocumentSign(uint id, uint index) constant returns (
                        address member,
                        uint date) {
        Document d = documentsIds[id];
        Sign s = d.signs[index];
        member = s.member;
        date = s.date;
	}
}