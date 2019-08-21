pragma solidity ^0.4.11;
contract MinerShare {
	// 合約的創建者
	address public owner = 0x0;
	// 已經被提領的總量
	uint public totalWithdrew = 0;
	// 目前有多少位股東
	uint public userNumber = 0;
	// 監聽新增股東的事件
	event LogAddUser(address newUser);
	// 監聽移除股東的事件
	event LogRmUser(address rmUser);
	// 監聽股東提領的事件
	event LogWithdrew(address sender, uint amount);
	// 儲存股東們的 ETH Address
	mapping(address => uint) public usersAddress;
	// 紀錄每個股東已經提領的數量
	mapping(address => uint) public usersWithdrew;

	modifier onlyOwner() {
		require(owner == msg.sender);
		_;
	}

	modifier onlyMember() {
		require(usersAddress[msg.sender] != 0);
		_;
	}

	// 創建實體，註冊創建者
	function MinerShare() {
		owner = msg.sender;
	}

	// 新增股東
	function AddUser(address newUser) onlyOwner{
		if (usersAddress[newUser] == 0) {
			usersAddress[newUser] = 1;
			userNumber += 1;
			LogAddUser(newUser);
		}
	}

	// 移除股東
	function RemoveUser(address rmUser) onlyOwner {
		if (usersAddress[rmUser] == 1) {
			usersAddress[rmUser] = 0;
			userNumber -= 1;
			LogRmUser(rmUser);
		}
	}

	// 股東提領
	function Withdrew() onlyMember {
		// 實際總額為此 contract 的 balance 與已經提領數量的總和
		uint totalMined = this.balance + totalWithdrew;
		// 可以提領的數量為 實際總額除以股東總數 減去 該股東已經提領的數量
		uint avaliableWithdrew = totalMined/userNumber - usersWithdrew[msg.sender];
		// 改變提領數量
		usersWithdrew[msg.sender] += avaliableWithdrew;
		// 改變總提領數量
		totalWithdrew += avaliableWithdrew;
		// 檢查是否為合法的提領
		if (avaliableWithdrew > 0) {
			// 轉移 ETH 至股東的 address
			msg.sender.transfer(avaliableWithdrew);
			LogWithdrew(msg.sender, avaliableWithdrew);
		} else
			throw;
	}

	// 讓此 contract 可以收錢
	function () payable {}
}