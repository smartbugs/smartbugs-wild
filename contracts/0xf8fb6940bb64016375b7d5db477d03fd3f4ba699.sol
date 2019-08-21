contract ICreditBit {
    function lockBalance(uint _amount, uint _lockForBlocks) {}
    function claimBondReward() {}
    function balanceOf(address _owner) constant returns (uint avaliableBalance) {}
    function lockedBalanceOf(address _owner) constant returns (uint avaliableBalance) {}
    function transfer(address _to, uint256 _value) returns (bool success) {}
}

contract ICreditBond {
    uint public yearlyBlockCount;
}

contract CreditDAOfund {

    ICreditBit creditBitContract;
    ICreditBond creditBondContract;
    address public creditDaoAddress;
    uint public lockedCore;
	address dev;
    
    
    function CreditDAOfund() {
		creditDaoAddress = 0x40219dd5412e3DF40CA3c1C9A7c47786028E626c;
		dev = msg.sender;
	}
	
	function withdrawReward(address _destination) {
	    require(msg.sender == creditDaoAddress);
	    
	    uint withdrawalAmount = creditBitContract.lockedBalanceOf(address(this)) + creditBitContract.balanceOf(address(this)) - lockedCore;
	    require(withdrawalAmount <= creditBitContract.balanceOf(address(this)));
	    require(withdrawalAmount > 0);
	    creditBitContract.transfer(_destination, withdrawalAmount);
	}
	
	function lockTokens(uint _multiplier) {
	    require(msg.sender == creditDaoAddress);
	    
	    uint currentBalance = creditBitContract.balanceOf(address(this)) / 10**8;
	    uint yearlyBlockCount = creditBondContract.yearlyBlockCount();
	    creditBitContract.lockBalance(currentBalance, yearlyBlockCount * _multiplier);
	    lockedCore = creditBitContract.lockedBalanceOf(address(this));
	}

	function claimBondReward() {
		require (msg.sender == creditDaoAddress);
		creditBitContract.claimBondReward();
	}
	
	function setCreditDaoAddress(address _creditDaoAddress) {
	    require(msg.sender == creditDaoAddress);
	    
	    creditDaoAddress = _creditDaoAddress;
	}
	
	function setCreditBitContract(address _creditBitAddress) {
	    require(msg.sender == creditDaoAddress);
	    
	    creditBitContract = ICreditBit(_creditBitAddress);
	}
	
	function setCreditBondContract(address _creditBondAddress) {
	    require(msg.sender == creditDaoAddress);
	    
	    creditBondContract = ICreditBond(_creditBondAddress);
	}

	function setDao(address _newDaoAddress) {
		require(msg.sender == dev);
		creditDaoAddress = _newDaoAddress;
	}

	function getCreditBitAddress() constant returns (address) {
		return address(creditBitContract);
	}

	function getCreditBondAddress() constant returns (address) {
		return address(creditBondContract);
	}

	function getCurrentBalance() constant returns(uint) {
		return creditBitContract.balanceOf(address(this));
	}
}