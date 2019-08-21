pragma solidity ^0.4.4;
/**
 * @title Contract for object that have an owner
 */
contract Owned {
    /**
     * Contract owner address
     */
    address public owner;

    /**
     * @dev Store owner on creation
     */
    function Owned() { owner = msg.sender; }

    /**
     * @dev Delegate contract to another person
     * @param _owner is another person address
     */
    function delegate(address _owner) onlyOwner
    { owner = _owner; }

    /**
     * @dev Owner check modifier
     */
    modifier onlyOwner { if (msg.sender != owner) throw; _; }
}


/**
 * @title Contract for objects that can be morder
 */
contract Mortal is Owned {
    /**
     * @dev Destroy contract and scrub a data
     * @notice Only owner can kill me
     */
    function kill() onlyOwner
    { suicide(owner); }
}


contract Comission is Mortal {
    address public ledger;
    bytes32 public taxman;
    uint    public taxPerc;

    /**
     * @dev Comission contract constructor
     * @param _ledger Processing ledger contract
     * @param _taxman Tax receiver account
     * @param _taxPerc Processing tax in percent
     */
    function Comission(address _ledger, bytes32 _taxman, uint _taxPerc) {
        ledger  = _ledger;
        taxman  = _taxman;
        taxPerc = _taxPerc;
    }

    /**
     * @dev Refill ledger with comission
     * @param _destination Destination account
     */
    function process(bytes32 _destination) payable returns (bool) {
        // Handle value below 100 isn't possible
        if (msg.value < 100) throw;

        var tax = msg.value * taxPerc / 100; 
        var refill = bytes4(sha3("refill(bytes32)")); 
        if ( !ledger.call.value(tax)(refill, taxman)
          || !ledger.call.value(msg.value - tax)(refill, _destination)
           ) throw;
        return true;
    }
}


contract Invoice is Mortal {
    address   public signer;
    uint      public closeBlock;

    Comission public comission;
    string    public description;
    bytes32   public beneficiary;
    uint      public value;

    /**
     * @dev Offer type contract
     * @param _comission Comission handler address
     * @param _description Deal description
     * @param _beneficiary Beneficiary account
     * @param _value Deal value
     */
    function Invoice(address _comission,
                     string  _description,
                     bytes32 _beneficiary,
                     uint    _value) {
        comission   = Comission(_comission);
        description = _description;
        beneficiary = _beneficiary;
        value       = _value;
    }

    /**
     * @dev Call me to withdraw money
     */
    function withdraw() onlyOwner {
        if (closeBlock != 0) {
            if (!comission.process.value(value)(beneficiary)) throw;
        }
    }

    /**
     * @dev Payment fallback function
     */
    function () payable {
        // Condition check
        if (msg.value != value
           || closeBlock != 0) throw;

        // Store block when closed
        closeBlock = block.number;
        signer = msg.sender;
        PaymentReceived();
    }
    
    /**
     * @dev Payment notification
     */
    event PaymentReceived();
}


library CreatorInvoice {
    function create(address _comission, string _description, bytes32 _beneficiary, uint256 _value) returns (Invoice)
    { return new Invoice(_comission, _description, _beneficiary, _value); }

    function version() constant returns (string)
    { return "v0.5.0 (a9ea4c6c)"; }

    function abi() constant returns (string)
    { return '[{"constant":true,"inputs":[],"name":"signer","outputs":[{"name":"","type":"address"}],"payable":false,"type":"function"},{"constant":true,"inputs":[],"name":"beneficiary","outputs":[{"name":"","type":"bytes32"}],"payable":false,"type":"function"},{"constant":true,"inputs":[],"name":"comission","outputs":[{"name":"","type":"address"}],"payable":false,"type":"function"},{"constant":false,"inputs":[],"name":"withdraw","outputs":[],"payable":false,"type":"function"},{"constant":true,"inputs":[],"name":"value","outputs":[{"name":"","type":"uint256"}],"payable":false,"type":"function"},{"constant":false,"inputs":[],"name":"kill","outputs":[],"payable":false,"type":"function"},{"constant":false,"inputs":[{"name":"_owner","type":"address"}],"name":"delegate","outputs":[],"payable":false,"type":"function"},{"constant":true,"inputs":[],"name":"description","outputs":[{"name":"","type":"string"}],"payable":false,"type":"function"},{"constant":true,"inputs":[],"name":"closeBlock","outputs":[{"name":"","type":"uint256"}],"payable":false,"type":"function"},{"constant":true,"inputs":[],"name":"owner","outputs":[{"name":"","type":"address"}],"payable":false,"type":"function"},{"inputs":[{"name":"_comission","type":"address"},{"name":"_description","type":"string"},{"name":"_beneficiary","type":"bytes32"},{"name":"_value","type":"uint256"}],"type":"constructor"},{"payable":true,"type":"fallback"},{"anonymous":false,"inputs":[],"name":"PaymentReceived","type":"event"}]'; }
}


/**
 * @title Builder based contract
 */
contract Builder is Mortal {
    /**
     * @dev this event emitted for every builded contract
     */
    event Builded(address indexed client, address indexed instance);
 
    /* Addresses builded contracts at sender */
    mapping(address => address[]) public getContractsOf;
 
    /**
     * @dev Get last address
     * @return last address contract
     */
    function getLastContract() constant returns (address) {
        var sender_contracts = getContractsOf[msg.sender];
        return sender_contracts[sender_contracts.length - 1];
    }

    /* Building beneficiary */
    address public beneficiary;

    /**
     * @dev Set beneficiary
     * @param _beneficiary is address of beneficiary
     */
    function setBeneficiary(address _beneficiary) onlyOwner
    { beneficiary = _beneficiary; }

    /* Building cost  */
    uint public buildingCostWei;

    /**
     * @dev Set building cost
     * @param _buildingCostWei is cost
     */
    function setCost(uint _buildingCostWei) onlyOwner
    { buildingCostWei = _buildingCostWei; }

    /* Security check report */
    string public securityCheckURI;

    /**
     * @dev Set security check report URI
     * @param _uri is an URI to report
     */
    function setSecurityCheck(string _uri) onlyOwner
    { securityCheckURI = _uri; }
}

//
// AIRA Builder for Invoice contract
//
/**
 * @title BuilderInvoice contract
 */
contract BuilderInvoice is Builder {
    /**
     * @dev Run script creation contract
     * @return address new contract
     */
    function create(address _comission, string _description,
                    bytes32 _beneficiary, uint _value,
                    address _client) payable returns (address) {
        if (buildingCostWei > 0 && beneficiary != 0) {
            // Too low value
            if (msg.value < buildingCostWei) throw;
            // Beneficiary send
            if (!beneficiary.send(buildingCostWei)) throw;
            // Refund
            if (msg.value > buildingCostWei) {
                if (!msg.sender.send(msg.value - buildingCostWei)) throw;
            }
        } else {
            // Refund all
            if (msg.value > 0) {
                if (!msg.sender.send(msg.value)) throw;
            }
        }

        if (_client == 0)
            _client = msg.sender;
 
        var inst = CreatorInvoice.create(_comission, _description, _beneficiary, _value);
        inst.delegate(_client);
        Builded(_client, inst);
        getContractsOf[_client].push(inst);
        return inst;
    }
}