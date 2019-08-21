contract BasicSign {

    event Created(
        address indexed from,
        uint256 id
    );
    event Signed(
        address indexed from,
        uint256 docId,
        uint8 singId,
        bytes16 signType,
        bytes sign
    );

    address owner;
    mapping (uint256 => Document) public documents;

    struct Document {
        address organizer;
        Sign[] signs;
    }

    struct Sign {
        address signer;
        bytes16 signType;
        bytes   sign;
    }

    function SimpleSign() {
        owner = msg.sender;
    }

    function createDocument(uint256 nonce) returns (uint256 docId) {
        docId = generateId(nonce);
        if (documents[docId].organizer != 0) throw;
        documents[docId].organizer = msg.sender;
        Created(msg.sender, docId);
    }

    function removeDocument(uint256 docId) {
        Document doc = documents[docId];
        if (doc.organizer != msg.sender) throw;
        delete documents[docId];
    }

    function addSignature(uint256 docId, bytes16 _type, bytes _sign) {
        Document doc = documents[docId];
        if (doc.organizer != msg.sender) throw;
        if (doc.signs.length >= 0xFF) throw;
        uint idx = doc.signs.push(Sign(msg.sender, _type, _sign));
        Signed(msg.sender, docId, uint8(idx), _type, _sign);
    }

    function getDocumentDetails(uint256 docId) returns (address organizer, uint count) {
        Document doc = documents[docId];
        organizer = doc.organizer;
        count = doc.signs.length;
    }

    function getSignsCount(uint256 docId) returns (uint) {
        return documents[docId].signs.length;
    }

    function getSignDetails(uint256 docId, uint8 signId) returns (address, bytes16) {
        Document doc = documents[docId];
        Sign s = doc.signs[signId];
        return (s.signer, s.signType);
    }

    function getSignData(uint256 docId, uint8 signId) returns (bytes) {
        Document doc = documents[docId];
        Sign s = doc.signs[signId];
        return s.sign;
    }

    function generateId(uint256 nonce) returns (uint256) {
        return uint256(sha3(msg.sender, nonce));
    }

    function () {
        throw;
    }

}