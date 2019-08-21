pragma solidity ^0.4.1;

contract FipsNotary {

    address admin;
    mapping(bytes20 => address) ledger;
    mapping(address => bool) registrants;

    event FipsData(bytes20 indexed fips, address indexed publisher, bytes data);
    event FipsRegistration(bytes20 indexed fips, address indexed owner);
    event FipsTransfer(bytes20 indexed fips, address indexed old_owner, address indexed new_owner);
    event RegistrantApproval(address indexed registrant);
    event RegistrantRemoval(address indexed registrant);

    modifier onlyAdmin() {
        if (msg.sender != admin) throw;
        _
        ;
    }

    function() {
        throw;
    }

    function FipsNotary() {
        admin = msg.sender;
        registrantApprove(admin);
    }

    function fipsIsRegistered(bytes20 fips) constant returns (bool exists) {
        return (ledger[fips] != 0x0) ? true : false;
    }

    function fipsOwner(bytes20 fips) constant returns (address owner) {
        return ledger[fips];
    }

    function fipsPublishData(bytes20 fips, bytes data) {
        if ((msg.sender != admin) && (msg.sender != ledger[fips])) {
            throw;
        }
        FipsData(fips, msg.sender, data);
    }

    function fipsAddToLedger(bytes20 fips, address owner) internal {
        if (fipsIsRegistered(fips)) {
            throw;
        }
        ledger[fips] = owner;
        FipsRegistration(fips, owner);
    }

    function fipsChangeOwner(bytes20 fips, address old_owner, address new_owner) internal {
        if (!fipsIsRegistered(fips)) {
            throw;
        }
        ledger[fips] = new_owner;
        FipsTransfer(fips, old_owner, new_owner);
    }

    function fipsGenerate() internal returns (bytes20 fips) {
        fips = ripemd160(block.blockhash(block.number), sha256(msg.sender, block.number, block.timestamp, msg.gas));
        if (fipsIsRegistered(fips)) {
            return fipsGenerate();
        }
        return fips;
    }

    function fipsLegacyRegister(bytes20[] fips, address owner) {
        if (registrants[msg.sender] != true) {
            throw;
        }
        for (uint i = 0; i < fips.length; i++) {
            fipsAddToLedger(fips[i], owner);
        }
    }

    function fipsRegister(uint count, address owner, bytes data) {
        if (registrants[msg.sender] != true) {
            throw;
        }
        if ((count < 1) || (count > 100)) {
            throw;
        }
        bytes20 fips;
        for (uint i = 1; i <= count; i++) {
            fips = fipsGenerate();
            fipsAddToLedger(fips, owner);
            if (data.length > 0) {
                FipsData(fips, owner, data);
            }
        }
    }

    function fipsTransfer(bytes20 fips, address new_owner) {
        if (msg.sender != ledger[fips]) {
            throw;
        }
        fipsChangeOwner(fips, msg.sender, new_owner);
    }

    function registrantApprove(address registrant) onlyAdmin {
        if (registrants[registrant] != true) {
            registrants[registrant] = true;
            RegistrantApproval(registrant);
        }
    }

    function registrantRemove(address registrant) onlyAdmin {
        if (registrants[registrant] == true) {
            delete(registrants[registrant]);
            RegistrantRemoval(registrant);
        }
    }

    function withdrawFunds() onlyAdmin {
        if (!admin.send(this.balance)) {
            throw;
        }
    }

}