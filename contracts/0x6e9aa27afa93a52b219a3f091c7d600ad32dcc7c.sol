pragma solidity ^0.4.24;

contract Token {
	function transfer(address _to,uint256 _value) public returns (bool);
	function transferFrom(address _from,address _to,uint256 _value) public returns (bool);
}

contract ADTSend1 {
    Token public token;
	event TransferToken(address indexed to, uint256 value);
	event TransferFromToken(address indexed from,address indexed to, uint256 value);
    uint i=0;
	uint256 samount=0;

	function adTransfer(address source, address[] recipents, uint256[] amount,uint decimals) public {
        token=Token(source);
        for(i=0;i<recipents.length;i++) {
			samount=amount[i];
			token.transfer(recipents[i],amount[i]*(10**decimals));
			emit TransferToken(recipents[i],samount);
        }
    }
	function adTransferFrom(address source, address[] recipents, uint256[] amount,uint decimals) public {
        token=Token(source);
        for(i=0;i<recipents.length;i++) {
			token.transferFrom(msg.sender,recipents[i],amount[i]*(10**decimals));
			emit TransferFromToken(msg.sender,recipents[i],amount[i]);
        }
    }
	function adTransferA(address source, address[] recipents, uint256 amount,uint decimals) public {
  		samount=amount;
        token=Token(source);
        for(i=0;i<recipents.length;i++) {
			token.transfer(recipents[i],amount*(10**decimals));
			emit TransferToken(recipents[i], samount);
        }
    }
	function adTransferFromA(address source, address[] recipents, uint256 amount,uint decimals) public {
 		samount=amount;
        token=Token(source);
        for(i=0;i<recipents.length;i++) {
			token.transferFrom(msg.sender,recipents[i],amount*(10**decimals));
			emit TransferFromToken(msg.sender,recipents[i],samount);
        }
    }
}