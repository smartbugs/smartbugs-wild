/*
this smartcontract used to store documents text on the Ethereum blockchain
*/

contract ProofOfExistence{

    /* ---- Public variables: */
    string public created;
    address public manager; // account that adds info to this smartcontract
    uint256 public index;   // record's numbers and number of records
    mapping (uint256 => Doc) public docs; // index => Doc
    // to get Doc obj call ProofOfExistence.docs(index);

    /* ---- Stored document structure: */

    struct Doc {
        string publisher; // publisher's email
        uint256 publishedOnUnixTime; // block timestamp (block.timestamp)
        uint256 publishedInBlockNumber; // block.number
        string text; // text of the document
    }

    /* ---- Constructor: */

    function ProofOfExistence(){
        manager = msg.sender;
        created = "cryptonomica.net";
        index = 0; //
    }

    /* ---- Event:  */
    // This generates a public event on the blockchain that will notify clients. In 'Mist' SmartContract page enable 'Watch contract events'
    event DocumentAdded(uint256 indexed index,
                        string indexed publisher,
                        uint256 publishedOnUnixTime,
                        string indexed text);

    /* ----- Main method: */

    function addDoc(string _publisher, string _text) returns (uint256) {
        // authorization
        if (msg.sender != manager) throw;
        // document number
        index += 1;
        // add document data:
        docs[index] = Doc(_publisher, now, block.number, _text);
        // add event
        DocumentAdded(index,
                      docs[index].publisher,
                      docs[index].publishedOnUnixTime,
                      docs[index].text);
        // return number of the stored document
        return index;
    }

    /* ---- Utilities: */

    function () {
        // This function gets executed if a
        // transaction with invalid data is sent to
        // the contract or just ether without data.
        // We revert the send so that no-one
        // accidentally loses money when using the
        // contract.
        throw;
    }

}