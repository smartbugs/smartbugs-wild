/**
 *	Made by X-cessive Overlord of Acmeme.biz.
 *	Gamble responsibly.
 */

pragma solidity ^0.4.18;

contract KingOfTheHill {

	uint public timeLimit = 1 hours;
	uint public lastKing;
	address public owner;
	address public currentKing;
	address[] public previousEntries;

	event NewKing(address indexed newKing, uint timestamp);
	event Winner(address indexed winner, uint winnings);
	
	function KingOfTheHill() public {
		owner = msg.sender;
	}

	function seed() external payable {
		require(msg.sender == owner);
		lastKing = block.timestamp;
	}

	function () external payable {
		require(msg.value == 0.1 ether);
		if ((lastKing + timeLimit) < block.timestamp) {
			winner();
		}
		previousEntries.push(currentKing);
		lastKing = block.timestamp;
		currentKing = msg.sender;
		NewKing(currentKing, lastKing);
	}

	function winner() internal {
		uint winnings = this.balance - 0.1 ether;
		currentKing.transfer(winnings);
		Winner(currentKing, winnings);
	}

	function numberOfPreviousEntries() constant external returns (uint) {
		return previousEntries.length;
	}

}