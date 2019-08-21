contract Docsign
{
    //Fire when document hash is added to contract
    event Added(address indexed _from);

    //Fire when contract is deployed on the blockchain
    event Created(address indexed _from);


    struct Document {
        uint version;
        string name;
        address creator;
        string hash;
        uint date;
    }
    Document[] public a_document;
    uint length;

    // Constructor. Can be used to track contract deployment
    function Docsign() {
        Created(msg.sender);
    }

    function Add(uint _version, string _name, string _hash) {
        a_document.push(Document(_version,_name,msg.sender, _hash, now));
        Added(msg.sender);
    }
    // Get number of element in Array a_document (does not used GAS)
    function getCount() public constant returns(uint) {
        return a_document.length;
    }
    
    // fallback function (send back ether if contrat is used as wallet contract)
    function() { throw; }

}