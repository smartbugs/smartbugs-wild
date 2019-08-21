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

contract PullPaymentCapable {
    uint256 private totalBalance;
    mapping(address => uint256) private payments;

    event LogPaymentReceived(address indexed dest, uint256 amount);

    function PullPaymentCapable() {
        if (0 < this.balance) {
            asyncSend(msg.sender, this.balance);
        }
    }

    // store sent amount as credit to be pulled, called by payer
    function asyncSend(address dest, uint256 amount) internal {
        if (amount > 0) {
            totalBalance += amount;
            payments[dest] += amount;
            LogPaymentReceived(dest, amount);
        }
    }

    function getTotalBalance()
        constant
        returns (uint256) {
        return totalBalance;
    }

    function getPaymentOf(address beneficiary) 
        constant
        returns (uint256) {
        return payments[beneficiary];
    }

    // withdraw accumulated balance, called by payee
    function withdrawPayments()
        external 
        returns (bool success) {
        uint256 payment = payments[msg.sender];
        payments[msg.sender] = 0;
        totalBalance -= payment;
        if (!msg.sender.call.value(payment)()) {
            throw;
        }
        success = true;
    }

    function fixBalance()
        returns (bool success);

    function fixBalanceInternal(address dest)
        internal
        returns (bool success) {
        if (totalBalance < this.balance) {
            uint256 amount = this.balance - totalBalance;
            payments[dest] += amount;
            LogPaymentReceived(dest, amount);
        }
        return true;
    }
}

contract WithBeneficiary is Owned {
    /**
     * @notice Address that is forwarded all value.
     * @dev Made private to protect against child contract setting it to 0 by mistake.
     */
    address private beneficiary;
    
    event LogBeneficiarySet(address indexed previousBeneficiary, address indexed newBeneficiary);

    function WithBeneficiary(address _beneficiary) payable {
        if (_beneficiary == 0) {
            throw;
        }
        beneficiary = _beneficiary;
        if (msg.value > 0) {
            asyncSend(beneficiary, msg.value);
        }
    }

    function asyncSend(address dest, uint amount) internal;

    function getBeneficiary()
        constant
        returns (address) {
        return beneficiary;
    }

    function setBeneficiary(address newBeneficiary)
        fromOwner 
        returns (bool success) {
        if (newBeneficiary == 0) {
            throw;
        }
        if (beneficiary != newBeneficiary) {
            LogBeneficiarySet(beneficiary, newBeneficiary);
            beneficiary = newBeneficiary;
        }
        success = true;
    }

    function () payable {
        asyncSend(beneficiary, msg.value);
    }
}

contract CertificationCentreI {
    event LogCertificationDbRegistered(address indexed db);

    event LogCertificationDbUnRegistered(address indexed db);

    function getCertificationDbCount()
        constant
        returns (uint);

    function getCertificationDbStatus(address db)
        constant
        returns (bool valid, uint256 index);

    function getCertificationDbAtIndex(uint256 index)
        constant
        returns (address db);

    function registerCertificationDb(address db)
        returns (bool success);

    function unRegisterCertificationDb(address db)
        returns (bool success);
}

contract CertificationCentre is CertificationCentreI, WithBeneficiary, PullPaymentCapable {
    struct CertificationDbStruct {
        bool valid;
        uint256 index;
    }

    mapping (address => CertificationDbStruct) private certificationDbStatuses;
    address[] private certificationDbs;

    function CertificationCentre(address beneficiary)
        WithBeneficiary(beneficiary) {
        if (msg.value > 0) {
            throw;
        }
    }

    function getCertificationDbCount()
        constant
        returns (uint256) {
        return certificationDbs.length;
    }

    function getCertificationDbStatus(address db)
        constant
        returns (bool valid, uint256 index) {
        CertificationDbStruct status = certificationDbStatuses[db];
        return (status.valid, status.index);
    }

    function getCertificationDbAtIndex(uint256 index)
        constant
        returns (address db) {
        return certificationDbs[index];
    }

    function registerCertificationDb(address db) 
        fromOwner
        returns (bool success) {
        if (db == 0) {
            throw;
        }
        if (!certificationDbStatuses[db].valid) {
            certificationDbStatuses[db].valid = true;
            certificationDbStatuses[db].index = certificationDbs.length;
            certificationDbs.push(db);
        }
        LogCertificationDbRegistered(db);
        success = true;
    }

    function unRegisterCertificationDb(address db)
        fromOwner
        returns (bool success) {
        if (certificationDbStatuses[db].valid) {
            uint256 index = certificationDbStatuses[db].index;
            certificationDbs[index] = certificationDbs[certificationDbs.length - 1];
            certificationDbStatuses[certificationDbs[index]].index = index;
            delete certificationDbStatuses[db];
            certificationDbs.length--;
        }
        LogCertificationDbUnRegistered(db);
        success = true;
    }

    function fixBalance()
        returns (bool success) {
        return fixBalanceInternal(getBeneficiary());
    }
}