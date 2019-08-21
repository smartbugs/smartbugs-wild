pragma solidity ^0.5.0;

contract freedomStatement {
    
    string public statement = "https://ipfs.globalupload.io/QmeeFwpnMk9CaXHZYv4Hn1FFD2MT7kxZ7TNnT9JfZqTzUM";
    mapping (address => bool) public checkconsent;
    event wearehere(string statement);
    uint public signAmounts;
    
    constructor () public {
        emit wearehere(statement);
    }
        
    function isHuman(address addr) internal view returns (bool) {
        uint size;
        assembly { size := extcodesize(addr) }
        return size == 0;
    }

    function () external payable {
        require(isHuman(msg.sender),"no robot");//Don't want to use tx.origin because that will cause an interoperability problem
        require(msg.value< 0.0000001 ether);//don't give me money, for metamask no error
        require(checkconsent[msg.sender] == false,"You have already signed up");
        checkconsent[msg.sender] = true;
        signAmounts++;
    }

}