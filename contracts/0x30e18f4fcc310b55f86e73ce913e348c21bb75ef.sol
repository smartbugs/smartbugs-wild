pragma solidity ^0.4.0;

/**
 * @title Contains the history of all relevant historic events in the vehicle lifecycle.
 */
contract History  {

    // The creator of this contract. This address can authorize Mechanics, Insurers, Car-Dealers etc
    // to log events.
    address owner;

    // Currently 3 types suported. More to come soon.
    enum EventType { NewOwner, Maintenance, DamageRepair }

    // List of addresses controlled by Mechanics, Insurers, Car-Dealers etc. that are 
    // Authorized to log events this Vehicle-History-Log.
    mapping(address => bool) public authorizedLoggers;

    // This event is broadcasted when a new maintenance event is logged.
    event EventLogged(string vin, EventType eventType, uint256 mileage, address verifier);

    // The event is broadcasted when a new logger is authorized to log events.
    event LoggerAuthorized(address loggerAddress);

    struct LedgerEvent {
        
        uint256 creationTime;
        uint256 mileage; 
        uint256 repairOrderNumber;
        address verifier; 
        EventType eventType;
        string description;   
    }

    mapping (bytes32 => LedgerEvent[]) events;

    /**
     * Set the owner.
     */
    function History() {
        
        owner = msg.sender; 
    }

    /**
     * Only allows addresses can call this function.
     */
    modifier onlyAuthorized {

        if (!authorizedLoggers[msg.sender])
            throw;
        _;
    }

    /**
     * Only owner can call this function.
     */
     modifier onlyOwner {

        if (msg.sender != owner)
            throw;
        _;
    }


    /**
     * Authorize the specified address to add evemnts to the historic log.
     */
    function authorize(address newLogger) onlyOwner {

        authorizedLoggers[newLogger] = true;
        LoggerAuthorized(newLogger);
    }

    /**
     * Checks if the specified address is authorized to log events.
     */
    function isAuthorized(address logger) returns (bool) {

         return authorizedLoggers[logger];
    }

    /**
     * Add a historically significant event (i.e. maintenance, damage 
     * repair or new owner).
     */
    function addEvent(uint256 _mileage, 
                     uint256 _repairOrderNumber,
                     EventType _eventType, 
                     string _description, 
                     string _vin) onlyAuthorized {

        events[sha3(_vin)].push(LedgerEvent({
            creationTime: now,
            mileage: _mileage,
            repairOrderNumber: _repairOrderNumber,
            verifier: msg.sender,
            eventType: _eventType,
            description: _description
        }));
        
        EventLogged(_vin, _eventType, _mileage, msg.sender);
    }
    
    /**
     * Returns the number of events for a vin. (helper function for getEvent function)
     */
    function getEventsCount(string _vin) constant returns(uint256) {

        return events[sha3(_vin)].length;
    }
    
    /**
     * Returns the details of a specific event. To be used together with the function
     * getEventsCount().
     */
    function getEvent(string _vin, uint256 _index) constant
                returns (uint256 mileage, address verifier, 
                        EventType eventType, string description) {

        LedgerEvent memory e = events[sha3(_vin)][_index];
        mileage = e.mileage;
        verifier = e.verifier;
        eventType = e.eventType;
        description = e.description;
    }

    /**
     * Lifecycle management (Solidity best-practice).
     */
    function kill() onlyOwner { 

        selfdestruct(owner); 
    }

    /**
     * Fallback function (Solidity best-practice).
     */
    function() payable {}
}