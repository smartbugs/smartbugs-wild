/**
 * Ludum - mean "For gaming" in Latin. Play, earn, live full of life. In Game.
 * LDM will show you new generation of Gaming.
 * LDM is in-game cyrrency of Privateers.Life game.
 * https://privateers.life
 */


pragma solidity ^0.4.18;


contract Ownable {

	address public owner;

	event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

	function Ownable() public {
		owner = msg.sender;
	}

	modifier onlyOwner() {
		require(msg.sender == owner);
		_;
	}

	function transferOwnership(address newOwner) public onlyOwner {
		require(newOwner != address(0));
		OwnershipTransferred(owner, newOwner);
		owner = newOwner;
	}

}


interface Token {

	function transfer(address _to, uint256 _value) public returns (bool);
	function balanceOf(address _owner) public constant returns (uint256 balance);

}


contract LudumAirdrop is Ownable {

	Token token;

	event TransferredToken(address indexed to, uint256 value);
	event FailedTransfer(address indexed to, uint256 value);

	modifier whenDropIsActive() {
		assert(isActive());
		_;
	}

	function LudumAirdrop () public {
	    address _tokenAddr = 0x28a40acF39b1D3C932f42dD8068ad00A5Ad6448F;
	    token = Token(_tokenAddr);
	}

	function isActive() public constant returns (bool) {
		return (
			tokensAvailable() > 0 // Tokens must be available to send
		);
	}

	//below function can be used when you want to send every recipeint with different number of tokens
	function sendLudumToMany(address[] dests, uint256[] values) whenDropIsActive onlyOwner external {
		uint256 i = 0;
		while (i < dests.length) {
			//uint256 toSend = values[i] * 10**18;
			uint256 toSend = values[i];
			sendInternally(dests[i] , toSend, values[i]);
			i++;
		}
	}

	// this function can be used when you want to send same number of tokens to all the recipients
	function sendLudumToSingle(address[] dests, uint256 value) whenDropIsActive onlyOwner external {
		uint256 i = 0;
		//uint256 toSend = value * 10**18;
		uint256 toSend = value;
		while (i < dests.length) {
			sendInternally(dests[i] , toSend, value);
			i++;
		}
	}  

	function sendInternally(address recipient, uint256 tokensToSend, uint256 valueToPresent) internal {
		if(recipient == address(0)) return;

		if(tokensAvailable() >= tokensToSend) {
			token.transfer(recipient, tokensToSend);
			TransferredToken(recipient, valueToPresent);
		} else {
			FailedTransfer(recipient, valueToPresent); 
		}
	}   


	function tokensAvailable() public constant returns (uint256) {
		return token.balanceOf(this);
	}

	function sendRemainsToOwner() public onlyOwner {
		uint256 balance = tokensAvailable();
		require (balance > 0);
		token.transfer(owner, balance);
		//selfdestruct(owner);
	}

}