pragma solidity ^0.4.6;
contract FileStorage {	
	address owner;
	mapping (bytes32=>File[]) public files;
	
	struct File {
		string title;		
		string category;	
		string extension;	
		string created;		
		string updated;	
		uint version;	
		bytes data;			
	}

    function FileStorage() {
        owner = msg.sender;
    }
    
    function Kill() {
        if (msg.sender == owner)
        selfdestruct(owner);
    }

	function StoreFile(bytes32 key, string title, string category, string extension, string created, string updated, uint version, bytes data)
	payable returns (bool success) {
	    var before = files[key].length;	
		var file = File(title, category, extension, created, updated, version, data);	
		files[key].push(file);	
			
		if (files[key].length > before) {	
			owner.send(this.balance);
			return true;
		} else {
			msg.sender.send(this.balance);
			return false;
		}

	}
	
	
	function GetFileLocation(bytes32 key) constant returns (uint Loc) {
		return files[key].length -1;	
	}
	
	function() {
	    throw;
	}
}