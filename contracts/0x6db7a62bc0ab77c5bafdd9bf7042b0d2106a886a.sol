pragma solidity 0.4.16;

contract Escrow{
    
    function Escrow() {
        owner = msg.sender;
    }

    mapping (address => mapping (bytes32 => uint128)) public balances;
    mapping (bytes16 => Lock) public lockedMoney;
    address public owner;
    
    struct Lock {
        uint128 amount;
        bytes32 currencyAndBank;
        address from;
        address executingBond;
    }
    
    event TxExecuted(uint32 indexed event_id);
    
    modifier onlyOwner() {
        if(msg.sender == owner)
        _;
    }
    
    function checkBalance(address acc, string currencyAndBank) constant returns (uint128 balance) {
        bytes32 cab = sha3(currencyAndBank);
        return balances[acc][cab];
    }
    
    function getLocked(bytes16 lockID) returns (uint) {
        return lockedMoney[lockID].amount;
    }
    
    function deposit(address to, uint128 amount, string currencyAndBank, uint32 event_id) 
        onlyOwner returns(bool success) {
            bytes32 cab = sha3(currencyAndBank);
            balances[to][cab] += amount;
            TxExecuted(event_id);
            return true;
    } 
    
    function withdraw(uint128 amount, string currencyAndBank, uint32 event_id) 
        returns(bool success) {
            bytes32 cab = sha3(currencyAndBank);
            require(balances[msg.sender][cab] >= amount);
            balances[msg.sender][cab] -= amount;
            TxExecuted(event_id);
            return true;
    }
    
    function lock(uint128 amount, string currencyAndBank, address executingBond, bytes16 lockID, uint32 event_id) 
        returns(bool success) {   
            bytes32 cab = sha3(currencyAndBank);
            require(balances[msg.sender][cab] >= amount);
            balances[msg.sender][cab] -= amount;
            lockedMoney[lockID].currencyAndBank = cab;
            lockedMoney[lockID].amount += amount;
            lockedMoney[lockID].from = msg.sender;
            lockedMoney[lockID].executingBond = executingBond;
            TxExecuted(event_id);
            return true; 
    }
    
    function executeLock(bytes16 lockID, address issuer) returns(bool success) {
        if(msg.sender == lockedMoney[lockID].executingBond){
	        balances[issuer][lockedMoney[lockID].currencyAndBank] += lockedMoney[lockID].amount;            
	        delete lockedMoney[lockID];
	        return true;
		}else
		    return false;
    }
    
    function unlock(bytes16 lockID, uint32 event_id) onlyOwner returns (bool success) {
        balances[lockedMoney[lockID].from][lockedMoney[lockID].currencyAndBank] +=
            lockedMoney[lockID].amount;
        delete lockedMoney[lockID];
        TxExecuted(event_id);
        return true;
    }
    
    function pay(address to, uint128 amount, string currencyAndBank, uint32 event_id) 
        returns (bool success){
            bytes32 cab = sha3(currencyAndBank);
            require(balances[msg.sender][cab] >= amount);
            balances[msg.sender][cab] -= amount;
            balances[to][cab] += amount;
            TxExecuted(event_id);
            return true;
    }
}