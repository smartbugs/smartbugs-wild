// Copyright (c) 2016 Chronicled, Inc. All rights reserved.
// http://explorer.chronicled.org
// http://demo.chronicled.org
// http://chronicled.org

contract Registrar {
    address public registrar;

    /**

    * Created event, gets triggered when a new registrant gets created
    * event
    * @param registrant - The registrant address.
    * @param registrar - The registrar address.
    * @param data - The data of the registrant.
    */
    event Created(address indexed registrant, address registrar, bytes data);

    /**
    * Updated event, gets triggered when a new registrant id Updated
    * event
    * @param registrant - The registrant address.
    * @param registrar - The registrar address.
    * @param data - The data of the registrant.
    */
    event Updated(address indexed registrant, address registrar, bytes data, bool active);

    /**
    * Error event.
    * event
    * @param code - The error code.
    * 1: Permission denied.
    * 2: Duplicate Registrant address.
    * 3: No such Registrant.
    */
    event Error(uint code);

    struct Registrant {
        address addr;
        bytes data;
        bool active;
    }

    mapping(address => uint) public registrantIndex;
    Registrant[] public registrants;

    /**
    * Function can't have ether.
    * modifier
    */
    modifier noEther() {
        if (msg.value > 0) throw;
        _
    }

    modifier isRegistrar() {
      if (msg.sender != registrar) {
        Error(1);
        return;
      }
      else {
        _
      }
    }

    /**
    * Construct registry with and starting registrants lenght of one, and registrar as msg.sender
    * constructor
    */
    function Registrar() {
        registrar = msg.sender;
        registrants.length++;
    }

    /**
    * Add a registrant, only registrar allowed
    * public_function
    * @param _registrant - The registrant address.
    * @param _data - The registrant data string.
    */
    function add(address _registrant, bytes _data) isRegistrar noEther returns (bool) {
        if (registrantIndex[_registrant] > 0) {
            Error(2); // Duplicate registrant
            return false;
        }
        uint pos = registrants.length++;
        registrants[pos] = Registrant(_registrant, _data, true);
        registrantIndex[_registrant] = pos;
        Created(_registrant, msg.sender, _data);
        return true;
    }

    /**
    * Edit a registrant, only registrar allowed
    * public_function
    * @param _registrant - The registrant address.
    * @param _data - The registrant data string.
    */
    function edit(address _registrant, bytes _data, bool _active) isRegistrar noEther returns (bool) {
        if (registrantIndex[_registrant] == 0) {
            Error(3); // No such registrant
            return false;
        }
        Registrant registrant = registrants[registrantIndex[_registrant]];
        registrant.data = _data;
        registrant.active = _active;
        Updated(_registrant, msg.sender, _data, _active);
        return true;
    }

    /**
    * Set new registrar address, only registrar allowed
    * public_function
    * @param _registrar - The new registrar address.
    */
    function setNextRegistrar(address _registrar) isRegistrar noEther returns (bool) {
        registrar = _registrar;
        return true;
    }

    /**
    * Get if a regsitrant is active or not.
    * constant_function
    * @param _registrant - The registrant address.
    */
    function isActiveRegistrant(address _registrant) constant returns (bool) {
        uint pos = registrantIndex[_registrant];
        return (pos > 0 && registrants[pos].active);
    }

    /**
    * Get all the registrants.
    * constant_function
    */
    function getRegistrants() constant returns (address[]) {
        address[] memory result = new address[](registrants.length-1);
        for (uint j = 1; j < registrants.length; j++) {
            result[j-1] = registrants[j].addr;
        }
        return result;
    }

    /**
    * Function to reject value sends to the contract.
    * fallback_function
    */
    function () noEther {}

    /**
    * Desctruct the smart contract. Since this is first, alpha release of Open Registry for IoT, updated versions will follow.
    * Registry's discontinue must be executed first.
    */
    function discontinue() isRegistrar noEther {
      selfdestruct(msg.sender);
    }
}