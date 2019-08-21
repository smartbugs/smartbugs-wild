pragma solidity ^0.4.2;

contract OwnedI {
    event LogOwnerChanged(address indexed previousOwner, address indexed newOwner);

    function getOwner()
        constant
        returns (address);

    function setOwner(address newOwner)
        returns (bool success); 
}

contract Owned is OwnedI {
    /**
     * @dev Made private to protect against child contract setting it to 0 by mistake.
     */
    address private owner;

    function Owned() {
        owner = msg.sender;
    }

    modifier fromOwner {
        if (msg.sender != owner) {
            throw;
        }
        _;
    }

    function getOwner()
        constant
        returns (address) {
        return owner;
    }

    function setOwner(address newOwner)
        fromOwner 
        returns (bool success) {
        if (newOwner == 0) {
            throw;
        }
        if (owner != newOwner) {
            LogOwnerChanged(owner, newOwner);
            owner = newOwner;
        }
        success = true;
    }
}

contract BalanceFixable is OwnedI {
    function fixBalance() 
        returns (bool success) {
        if (!getOwner().send(this.balance)) {
            throw;
        }
        return true;
    }
}

contract Migrations is Owned, BalanceFixable {
    uint public last_completed_migration;
    address public allowedAccount;

    function Migrations() {
        if(msg.value > 0) throw;
    }

    function setCompleted(uint completed) {
        if (msg.sender != getOwner()
            && msg.sender != allowedAccount) {
            throw;
        }
        last_completed_migration = completed;
    }

    function setAllowedAccount(address _allowedAccount) fromOwner {
        allowedAccount = _allowedAccount;
    }

    function upgrade(address new_address) fromOwner {
        Migrations upgraded = Migrations(new_address);
        upgraded.setCompleted(last_completed_migration);
    }
}