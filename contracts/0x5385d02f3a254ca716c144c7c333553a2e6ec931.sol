pragma solidity ^0.4.2;

/**
 * @notice Declares a contract that can have an owner.
 */
contract OwnedI {
    event LogOwnerChanged(address indexed previousOwner, address indexed newOwner);

    function getOwner()
        constant
        returns (address);

    function setOwner(address newOwner)
        returns (bool success); 
}

/**
 * @notice Defines a contract that can have an owner.
 */
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

// @notice Interface for a certifier database
contract CertifierDbI {
    event LogCertifierAdded(address indexed certifier);

    event LogCertifierRemoved(address indexed certifier);

    function addCertifier(address certifier)
        returns (bool success);

    function removeCertifier(address certifier)
        returns (bool success);

    function getCertifiersCount()
        constant
        returns (uint count);

    function getCertifierStatus(address certifierAddr)
        constant 
        returns (bool authorised, uint256 index);

    function getCertifierAtIndex(uint256 index)
        constant
        returns (address);

    function isCertifier(address certifier)
        constant
        returns (bool isIndeed);
}

contract CertifierDb is Owned, CertifierDbI, BalanceFixable {
    struct Certifier {
        bool authorised;
        /**
         * @notice The index in the table at which this certifier can be found.
         */
        uint256 index;
    }

    /**
     * @notice Addresses of the account or contract that are entitled to certify students.
     */
    mapping(address => Certifier) private certifierStatuses;
    
    /**
     * @notice The potentially long list of all certifiers.
     */
    address[] private certifiers;

    modifier fromCertifier {
        if (!certifierStatuses[msg.sender].authorised) {
            throw;
        }
        _;
    }

    function CertifierDb() {
        if (msg.value > 0) {
            throw;
        }
    }

    function addCertifier(address certifier)
        fromOwner
        returns (bool success) {
        if (certifier == 0) {
            throw;
        }
        if (!certifierStatuses[certifier].authorised) {
            certifierStatuses[certifier].authorised = true;
            certifierStatuses[certifier].index = certifiers.length;
            certifiers.push(certifier);
            LogCertifierAdded(certifier);
        }
        success = true;
    }

    function removeCertifier(address certifier)
        fromOwner
        returns (bool success) {
        if (!certifierStatuses[certifier].authorised) {
            throw;
        }
        // Let's move the last array item into the one we remove.
        uint256 index = certifierStatuses[certifier].index;
        certifiers[index] = certifiers[certifiers.length - 1];
        certifierStatuses[certifiers[index]].index = index;
        certifiers.length--;
        delete certifierStatuses[certifier];
        LogCertifierRemoved(certifier);
        success = true;
    }

    function getCertifiersCount()
        constant
        returns (uint256 count) {
        count = certifiers.length;
    }

    function getCertifierStatus(address certifierAddr)
        constant 
        returns (bool authorised, uint256 index) {
        Certifier certifier = certifierStatuses[certifierAddr];
        return (certifier.authorised,
            certifier.index);
    }

    function getCertifierAtIndex(uint256 index)
        constant
        returns (address) {
        return certifiers[index];
    }

    function isCertifier(address certifier)
        constant
        returns (bool isIndeed) {
        isIndeed = certifierStatuses[certifier].authorised;
    }
}