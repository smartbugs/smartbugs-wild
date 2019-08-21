pragma solidity ^0.4.2;

contract TokenBaseAsset {
    
    address mOwner = msg.sender;
    
    string public mCompany;
	
    mapping(string => string) mTokens;
    
    modifier isOwner() { require(msg.sender == mOwner); _; }

    function TokenBaseAsset(string pCompany) public {
        mCompany = pCompany;
    }
    
	function addToken(string pDocumentHash, string pDocumentToken) public {
	    require(msg.sender == mOwner);
        mTokens[pDocumentHash] = pDocumentToken;
	}
    
	function removeToken(string pDocumentHash) public {
	    require(msg.sender == mOwner);
        mTokens[pDocumentHash] = "";
	}
	
	function getToken(string pDocumentHash) view public returns(string) {
	    return mTokens[pDocumentHash];
	}

}