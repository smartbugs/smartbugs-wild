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
        if ((msg.sender == admin) || (msg.sender == ledger[fips])) {
            FipsData(fips, msg.sender, data);
        }
    }

    function fipsPublishDataMulti(bytes20[] fips, bytes data) {
        for (uint i = 0; i < fips.length; i++) {
            fipsPublishData(fips[i], data);
        }
    }

    function fipsAddToLedger(bytes20 fips, address owner, bytes data) internal {
        if (!fipsIsRegistered(fips)) {
            ledger[fips] = owner;
            FipsRegistration(fips, owner);
            if (data.length > 0) {
                FipsData(fips, owner, data);
            }
        }
    }

    function fipsGenerate() internal returns (bytes20 fips) {
        fips = ripemd160(block.blockhash(block.number), sha256(msg.sender, block.number, block.timestamp, msg.gas));
        if (fipsIsRegistered(fips)) {
            return fipsGenerate();
        }
        return fips;
    }

    function fipsLegacyRegister(bytes20 fips, address owner, bytes data) {
        if (registrants[msg.sender] == true) {
            fipsAddToLedger(fips, owner, data);
        }
    }

    function fipsLegacyRegisterMulti(bytes20[] fips, address owner, bytes data) {
        if (registrants[msg.sender] == true) {
            for (uint i = 0; i < fips.length; i++) {
                fipsAddToLedger(fips[i], owner, data);
            }
        }
    }

    function fipsRegister(address owner, bytes data) {
        if (registrants[msg.sender] == true) {
            fipsAddToLedger(fipsGenerate(), owner, data);
        }
    }

    function fipsRegisterMulti(uint count, address owner, bytes data) {
        if (registrants[msg.sender] == true) {
            if ((count > 0) && (count <= 100)) {
                for (uint i = 0; i < count; i++) {
                    fipsAddToLedger(fipsGenerate(), owner, data);
                }
            }
        }
    }

    function fipsTransfer(bytes20 fips, address new_owner) {
        if (fipsOwner(fips) == msg.sender) {
            ledger[fips] = new_owner;
            FipsTransfer(fips, msg.sender, new_owner);
        }
    }

    function fipsTransferMulti(bytes20[] fips, address new_owner) {
        for (uint i = 0; i < fips.length; i++) {
            fipsTransfer(fips[i], new_owner);
        }
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