pragma solidity ^0.4.19;
contract ETHRoyale {
    address devAccount = 0x50334D202f61F80384C065BE6537DD3d609FF9Ab; //Dev address to send dev fee (0.75%) to.
    uint masterBalance; //uint var for total real balance of contract
    uint masterApparentBalance; //var for total apparent balance of contract (real balance + all fake interest collected)
    
    //Array log of current participants
    address[] public participants;
    mapping (address => uint) participantsArrayLocation;
    uint participantsCount;
    
    //Boolean to check if deposits are enabled
    bool isDisabled;
	bool hasStarted;
	
    //Track deposit times
    uint blockHeightStart;
    bool isStart;
    event Deposit(uint _valu);
	
    //Mappings to link account values and dates of last interest claim with an Ethereum address
    mapping (address => uint) accountBalance;
    mapping (address => uint) realAccountBalance;
    mapping (address => uint) depositBlockheight;
    
    //Check individual account balance and return balance associated with that address
    function checkAccBalance() public view returns (uint) {
        address _owner = msg.sender;
        return (accountBalance[_owner]);
    }
    
    //Check actual balance of all wallets
    function checkGlobalBalance() public view returns (uint) {
        return masterBalance;
    }
    
	//Check game status
	function checkGameStatus() public view returns (bool) {
        return (isStart);
    }
    function checkDisabledStatus() public view returns (bool) {
        return (isDisabled);
    }
	
    //Check interest due
    function checkInterest() public view returns (uint) {
        address _owner = msg.sender;
        uint _interest;
        if (isStart) {
            if (blockHeightStart > depositBlockheight[_owner]) {
		        _interest = ((accountBalance[_owner] * (block.number - blockHeightStart) / 2000));
		    } else {
		        _interest = ((accountBalance[_owner] * (block.number - depositBlockheight[_owner]) / 2000));
		    }
		return _interest;
        }else {
			return 0;
        }
    }
	
    //Check interest due + balance
    function checkWithdrawalAmount() public view returns (uint) {
        address _owner = msg.sender;
        uint _interest;
		if (isStart) {
		    if (blockHeightStart > depositBlockheight[_owner]) {
		        _interest = ((accountBalance[_owner] * (block.number - blockHeightStart) / 2000));
		    } else {
		        _interest = ((accountBalance[_owner] * (block.number - depositBlockheight[_owner]) / 2000));
		    }
	    return (accountBalance[_owner] + _interest);
		} else {
			return accountBalance[_owner];
		}
    }
    //check number of participants
    function numberParticipants() public view returns (uint) {
        return participantsCount;
    }
    
    //Take deposit of funds
    function deposit() payable public {
        address _owner = msg.sender;
        uint _amt = msg.value;         
        require (!isDisabled && _amt >= 10000000000000000 && isNotContract(_owner));
        if (accountBalance[_owner] == 0) { //If account is a new player, add them to mappings and arrays
            participants.push(_owner);
            participantsArrayLocation[_owner] = participants.length - 1;
            depositBlockheight[_owner] = block.number;
            participantsCount++;
			if (participantsCount > 4) { //If game has 5 or more players, interest can start.
				isStart = true;
				blockHeightStart = block.number;
				hasStarted = true;
			}
        }
        else {
            isStart = false;
            blockHeightStart = 0;
        }
		Deposit(_amt);
        //add deposit to amounts
        accountBalance[_owner] += _amt;
        realAccountBalance[_owner] += _amt;
        masterBalance += _amt;
        masterApparentBalance += _amt;
    }
    
    //Retrieve interest earned since last interest collection
    function collectInterest(address _owner) internal {
        require (isStart);
        uint blockHeight; 
        //Require 5 or more players for interest to be collected to make trolling difficult
        if (depositBlockheight[_owner] < blockHeightStart) {
            blockHeight = blockHeightStart;
        }
        else {
            blockHeight = depositBlockheight[_owner];
        }
        //Add 0.05% interest for every block (approx 14.2 sec https://etherscan.io/chart/blocktime) since last interest collection/deposit
        uint _tempInterest = accountBalance[_owner] * (block.number - blockHeight) / 2000;
        accountBalance[_owner] += _tempInterest;
        masterApparentBalance += _tempInterest;
		//Set time since interest last collected
		depositBlockheight[_owner] = block.number;
	}

    //Allow withdrawal of funds and if funds left in contract are less than withdrawal requested and greater or = to account balance, contract balance will be cleared
    function withdraw(uint _amount) public  {
        address _owner = msg.sender; 
		uint _amt = _amount;
        uint _devFee;
        require (accountBalance[_owner] > 0 && _amt > 0 && isNotContract(_owner));
        if (isStart) { //Collect interest due if game has started
        collectInterest(msg.sender);
        }
		require (_amt <= accountBalance[_owner]);
        if (accountBalance[_owner] == _amount || accountBalance[_owner] - _amount < 10000000000000000) { //Check if sender is withdrawing their entire balance or will leave less than 0.01ETH
			_amt = accountBalance[_owner];
			if (_amt > masterBalance) { //If contract balance is lower than account balance, withdraw account balance.
				_amt = masterBalance;
			}	
            _devFee = _amt / 133; //Take 0.75% dev fee
            _amt -= _devFee;
            masterApparentBalance -= _devFee;
            masterBalance -= _devFee;
            accountBalance[_owner] -= _devFee;
            masterBalance -= _amt;
            masterApparentBalance -= _amt;
            //Delete sender address from mappings and arrays if they are withdrawing their entire balance
            delete accountBalance[_owner];
            delete depositBlockheight[_owner];
            delete participants[participantsArrayLocation[_owner]];
			delete participantsArrayLocation[_owner];
            delete realAccountBalance[_owner];
            participantsCount--;
            if (participantsCount < 5) { //If there are less than 5 people, stop the game.
                isStart = false;
				if (participantsCount < 3 && hasStarted) { //If there are less than 3 players and the game was started earlier, disable deposits until there are no players left
					isDisabled = true;
				}
				if (participantsCount == 0) { //Enable deposits if there are no players currently deposited
					isDisabled = false;
					hasStarted = false;
				}	
            }
        }
        else if (accountBalance[_owner] > _amount){ //Check that account has enough balance to withdraw
			if (_amt > masterBalance) {
				_amt = masterBalance;
			}	
            _devFee = _amt / 133; //Take 0.75% of withdrawal for dev fee and subtract withdrawal amount from all balances
            _amt -= _devFee;
            masterApparentBalance -= _devFee;
            masterBalance -= _devFee;
            accountBalance[_owner] -= _devFee;
            accountBalance[_owner] -= _amt;
            realAccountBalance[_owner] -= _amt;
            masterBalance -= _amt;
            masterApparentBalance -= _amt;
        }
		Deposit(_amt);
        devAccount.transfer(_devFee);
        _owner.transfer(_amt);
    }
	
	//Check if sender address is a contract for security purposes.
	function isNotContract(address addr) internal view returns (bool) {
		uint size;
		assembly { size := extcodesize(addr) }
		return (!(size > 0));
	}
}