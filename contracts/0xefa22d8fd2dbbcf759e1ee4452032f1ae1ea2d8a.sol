pragma solidity ^0.4.19;

/* This is a simple contract
   to let people write a phrase
   or SHA256 hash to the blockchain.
   Optional signatures can be purchased by 0.001 ETH,
   if someone finds it useful for an application.
*/
contract logPhrase {

    address owner = msg.sender;

   //unique 16 bytes signatures and corresponding addresses
    mapping (bytes16 => address) signatures;

   //cost to by a signature (and get your address into the mapping)
    uint128 constant minimumPayment = 0.001 ether;

    function logPhrase() payable public {
        
    }

    function () payable public {
        //Donations are welcome. They go to the owner.
        address contractAddr = this;
        owner.transfer(contractAddr.balance);
    }

   //The signed logs are indexed
    event Spoke(bytes16 indexed signature, string phrase);

   //unsigned log
    function logUnsigned(bytes32 phrase) public
    {
        log0(phrase);
    }

   //signed log
    function logSigned(string phrase, bytes16 sign) public
    {
        //can only be called by the owner of the signature
        require (signatures[sign]==msg.sender); //check valid address
        Spoke(sign, phrase);
    }

   //buy a 16 bytes signature for 0.001 ETH
    function buySignature(bytes16 sign) payable public
    {
        //signatures are unique
        require(msg.value > minimumPayment && signatures[sign]==0);
        signatures[sign]=msg.sender; //we got a new signer
        address contractAddr = this;
        owner.transfer(contractAddr.balance); //thanks
    }

   //query whois the owner address of the signature    
    function getAddress(bytes16 sign) public returns (address) {
        return signatures[sign];
    }
    

}