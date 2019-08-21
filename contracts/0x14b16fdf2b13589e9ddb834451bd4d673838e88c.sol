pragma solidity ^0.4.2;

contract MyInterface{
	function zGetGameBalance() public view returns (uint);
	function zReceiveFunds() payable public;
	function zSynchGameID(uint nIndex, uint nExpiration) public;
}

contract FantasySports {
	address gadrOwner;
	uint gnGameID = 0;
	address gadrOtherContract;
	MyInterface gobjOtherContract;
	uint constant gcnWinMultipler = 195;
	uint constant gcnTransferFee = .0001 ether;

	mapping(uint => address[]) gmapGame_addresses;
	mapping(uint => uint[]) gmapGame_wagers;
	mapping(uint => uint[]) gmapGame_runningbalances;
	mapping(uint => uint) gmapGame_balance;
	mapping(uint => uint) gmapGame_expiration;

	modifier onlyOwner() {
		require(gadrOwner == msg.sender);
		_;

	}

	modifier onlyOtherContract() {
		require(gadrOtherContract == msg.sender);
		_;
	}

	function FantasySports () public {
		gadrOwner = msg.sender;
	}

	function zReceiveFunds() payable public {
	}

	function() payable public {
		require(msg.value >= .001 ether && block.timestamp < gmapGame_expiration[gnGameID]);
		gmapGame_addresses[gnGameID].push(msg.sender);
		gmapGame_wagers[gnGameID].push(msg.value);
		gmapGame_balance[gnGameID] +=msg.value;
		gmapGame_runningbalances[gnGameID].push(gmapGame_balance[gnGameID]);
	}

	function zSynchGameID(uint nIndex, uint nExpiration) onlyOtherContract() public {
		gnGameID = nIndex;
		gmapGame_expiration[gnGameID] = nExpiration;
	}

	function zSetGameID(uint nIndex, uint nExpiration) onlyOwner() public {
		gnGameID = nIndex;
		gmapGame_expiration[gnGameID] = nExpiration;
		gobjOtherContract.zSynchGameID(gnGameID, nExpiration);
	}

	function zIncrementGameID(uint nExpiration) onlyOwner() public {
		gnGameID++;
		gmapGame_expiration[gnGameID] = nExpiration;
		gobjOtherContract.zSynchGameID(gnGameID, nExpiration);
	}

	function zGetGameID() onlyOwner() public view returns (uint) {
		return gnGameID;
	}

	function setOwner (address _owner) onlyOwner() public {
		gadrOwner = _owner;
	}

	function setOtherContract (address _othercontract) onlyOwner() public {
		gadrOtherContract = _othercontract;
		gobjOtherContract = MyInterface(gadrOtherContract);
	}

	function zgetOwner() onlyOwner() public view returns (address) {
		return gadrOwner;
	}

	function zgetOtherContract() onlyOwner() public view returns (address) {
		return gadrOtherContract;
	}

	function zgetPlayers(uint nIDOfGame) onlyOwner() public view returns (uint, uint, address[],uint[], uint[]) {
		return (gmapGame_balance[nIDOfGame], gmapGame_expiration[nIDOfGame], gmapGame_addresses[nIDOfGame], gmapGame_wagers[nIDOfGame],gmapGame_runningbalances[nIDOfGame]);
	}

	function zGetGameBalance() onlyOtherContract() public view returns (uint) {
		return (gmapGame_balance[gnGameID]);
	}

	function zRefundAllPlayers() onlyOwner() public {
		for (uint i = 0; i < gmapGame_addresses[gnGameID].length; i++) {
			gmapGame_addresses[gnGameID][i].transfer(gmapGame_wagers[gnGameID][i] - gcnTransferFee);
		}
	}

	function zGetBothContractBalances() public view onlyOwner() returns (uint, uint) {
		uint nOtherBalance = gobjOtherContract.zGetGameBalance();
		return (gmapGame_balance[gnGameID], nOtherBalance);
	}

	function zTransferFundsToOtherContract(uint nAmount) onlyOwner() public {
		gobjOtherContract.zReceiveFunds.value(nAmount)();
	}

	function zTransferFundsToOwner(uint nAmount) onlyOwner() public {
		gadrOwner.transfer(nAmount);
	}

	function zTransferLosingBets() onlyOwner() public {
		if (gmapGame_balance[gnGameID] != 0) {
			uint nOtherBalance = gobjOtherContract.zGetGameBalance();
			if (gmapGame_balance[gnGameID] <= nOtherBalance) {
				gobjOtherContract.zReceiveFunds.value(gmapGame_balance[gnGameID])();
			} else {
				if (nOtherBalance != 0) {
					gobjOtherContract.zReceiveFunds.value(nOtherBalance)();
				}
				for (uint i = 0; i < gmapGame_addresses[gnGameID].length; i++) {
					if (gmapGame_runningbalances[gnGameID][i] > nOtherBalance) {
						if (gmapGame_runningbalances[gnGameID][i] - nOtherBalance < gmapGame_wagers[gnGameID][i]) {
							gmapGame_addresses[gnGameID][i].transfer( (gmapGame_runningbalances[gnGameID][i] - nOtherBalance) - gcnTransferFee);
						} else {
							gmapGame_addresses[gnGameID][i].transfer(gmapGame_wagers[gnGameID][i] - gcnTransferFee);
						}
					}
				}
			}
		}
	}

	function zTransferWinningBets() onlyOwner() public {
		if (gmapGame_balance[gnGameID] != 0) {
			uint nPreviousRunningBalance = 0;
			uint nOtherBalance = gobjOtherContract.zGetGameBalance();
			for (uint i = 0; i < gmapGame_addresses[gnGameID].length; i++) {
				if (gmapGame_runningbalances[gnGameID][i] <= nOtherBalance) {
					gmapGame_addresses[gnGameID][i].transfer((gmapGame_wagers[gnGameID][i] * gcnWinMultipler / 100) - gcnTransferFee);
				} else {
					if (nPreviousRunningBalance < nOtherBalance) {
						gmapGame_addresses[gnGameID][i].transfer(((nOtherBalance - nPreviousRunningBalance) * gcnWinMultipler / 100) + (gmapGame_wagers[gnGameID][i] - (nOtherBalance - nPreviousRunningBalance)) - gcnTransferFee);
					} else {
						gmapGame_addresses[gnGameID][i].transfer(gmapGame_wagers[gnGameID][i] - gcnTransferFee);
					}
				}
				nPreviousRunningBalance = gmapGame_runningbalances[gnGameID][i];
			}
		}
	}
	
	function zKill() onlyOwner() public {
		selfdestruct(gadrOwner);
	}
}