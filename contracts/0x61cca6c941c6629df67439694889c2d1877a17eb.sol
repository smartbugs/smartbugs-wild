pragma solidity ^0.4.11;

contract LockYourLove {

    struct  LoveItem {
        address lovers_address;
        uint block_number;
        uint block_timestamp;
        string love_message;
        string love_url;
    }
  
    address public owner;
    
    mapping (bytes32 => LoveItem) private mapLoveItems;

    uint public price;
    uint public numLoveItems;
    //bytes32 bb;
    event EvLoveItemAdded(bytes32 indexed _loveHash, 
                            address indexed _loversAddress, 
                            uint _blockNumber, 
                            uint _blockTimestamp,
                            string _loveMessage,
                            string _loveUrl);
	event EvNewPrice(uint blocknumber, uint newprice);
	                                
    modifier onlyOwner()
    {
        require(msg.sender == owner);
        _;
    }
    
    // This is the constructor. It's payable so you can initialize the contract with funds during deploy
    function LockYourLove () { // Constructor
        owner = msg.sender;
        price = 10000000000000000; // 0.01 ethers -> https://etherconverter.online
        numLoveItems = 0;
    }

    /*function stringToBytes32(string memory str) returns (bytes32 result) {
        assembly {
            result := mload(add(str, 32))
        }
    }

    function setBB (string str) { 
       bb = stringToBytes32(str);
    }

    function getBB () constant returns (bytes32 result) {
       result = bb;
    }*/
    
    function() payable { 
        msg.sender.transfer(msg.value);
    }

    function donateToLovers(bytes32 loveHash) payable returns (bool) {
        require(msg.value > 0);
        require(mapLoveItems[loveHash].lovers_address > 0);
        mapLoveItems[loveHash].lovers_address.transfer(msg.value);
    }

    function setPrice (uint newprice) onlyOwner { 
        price = newprice;
		EvNewPrice(block.number, price);
    }
    
	function getPrice() constant returns  (uint){
		return price;
	}

	function getNumLoveItems() constant returns  (uint){
		return numLoveItems;
	}

    // datacoord = userId_assurId
    function addLovers(bytes32 love_hash, string lovemsg, string loveurl) payable {
        
        require(bytes(lovemsg).length < 250);
		require(bytes(loveurl).length < 100);
		require(msg.value >= price);
        
        mapLoveItems[love_hash] = LoveItem(msg.sender, block.number, block.timestamp, lovemsg, loveurl);
        numLoveItems++;
            
        owner.transfer(price); 
        
        EvLoveItemAdded(love_hash, msg.sender, block.number, block.timestamp, lovemsg, loveurl);
    }
    
    
    function getLovers(bytes32 love_hash) constant returns  (address, uint, uint, string, string){
        require(mapLoveItems[love_hash].block_number > 0);
        
        return (mapLoveItems[love_hash].lovers_address, mapLoveItems[love_hash].block_number, mapLoveItems[love_hash].block_timestamp,  
                mapLoveItems[love_hash].love_message, mapLoveItems[love_hash].love_url);
    }
    
    
    function destroy() onlyOwner { // so funds not locked in contract forever
        selfdestruct(owner); // send funds to organizer
    }
}