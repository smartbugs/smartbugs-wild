pragma solidity ^0.4.18;

contract Raffle
{
	struct Player
	{
		address delegate;
		uint amount;
		uint previousTotal;
	}
	
	address owner;
	Player[] players;
	address[] previousWinners;
	mapping(address => uint) playerTotalAmounts;
	uint total = 0;
	uint seed = 0;
	uint lastSeed = 0;
	bool selfdestructQueued = false;
	
	function Raffle() public
	{
		owner = msg.sender;
	}
	
	// if ether is accidentally sent without calling any function, fail
	function() public
	{
		assert(false);
	}
	
	function kill() public
	{
		require(msg.sender == owner);
		if (players.length > 0)
		{
			selfdestructQueued = true;
		}
		else
		{
			selfdestruct(owner);
		}
	}
	
	function enter(uint userSeed) public payable
	{
		require(msg.value > 0);
		require(userSeed != 0);
		players.push(Player(msg.sender, msg.value, total));
		playerTotalAmounts[msg.sender] += msg.value;
		total += msg.value;
		if (lastSeed != userSeed)
		{
			lastSeed = userSeed;
			seed ^= userSeed;
		}
	}
	
	function totalPool() public view returns (uint)
	{
		return total;
	}
	
	function enteredTotalAmount() public view returns (uint)
	{
		return playerTotalAmounts[msg.sender];
	}
	
	function getPreviousWinners() public view returns (address[])
	{
		return previousWinners;
	}
	
	function selectWinner() public
	{
		require(msg.sender == owner);
		address winner = 0x0;
		if (players.length > 0)
		{
			uint value = seed % total;
			uint i = 0;
			uint rangeStart = 0;
			uint rangeEnd = 0;
			// binary search to find winner
			uint min = 0;
			uint max = players.length - 1;
			uint current = min + (max - min) / 2;
			while (true)
			{
				rangeStart = players[current].previousTotal;
				rangeEnd = rangeStart + players[current].amount;
				if (value >= rangeStart && value < rangeEnd)
				{
					winner = players[current].delegate;
					break;
				}
				if (value < rangeStart)
				{
					max = current - 1;
					current = min + (max - min) / 2;
				}
				else if (value >= rangeEnd)
				{
					min = current + 1;
					current = min + (max - min) / 2;
				}
			}
			require(winner != 0x0);
			uint prize = total * 99 / 100; // 1% fee
			uint fee = total - prize;
			for (i = 0; i < players.length; ++i)
			{
				playerTotalAmounts[players[i].delegate] = 0;
			}
			players.length = 0;
			total = 0;
			winner.transfer(prize);
			owner.transfer(fee);
			previousWinners.push(winner);
		}
		if (selfdestructQueued)
		{
			selfdestruct(owner);
		}
	}
	
}