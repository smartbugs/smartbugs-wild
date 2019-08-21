pragma solidity ^0.5.0;

/**
 * @title McFLY.aero Flight smart contract ver 0.0.3
 * @author Copyright (c) 2018 McFly.aero
 * @author Dmitriy Khizhinskiy
 * @author "MIT"
 */

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
  address public owner;


  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  constructor() public {
    owner = msg.sender;
  }

  /**
   * @dev Throws if called by any account other than the owner.
   */
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param newOwner The address to transfer ownership to.
   */
  function transferOwnership(address newOwner) public onlyOwner {
    require(newOwner != address(0));
    emit OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }

}

contract McFlyToken  {
    function transferFrom(address from, address to, uint256 value) public returns (bool);
    function transfer(address to, uint256 value) public returns (bool);
    function balanceOf(address who) public view returns (uint256);
}

contract McFlight is Ownable {

    address public McFLYtokenAddress = 0x17e2c574cF092950eF89FB4939C97DB2086e796f;
    McFlyToken token_McFLY = McFlyToken(McFLYtokenAddress);

    address GridMaster_Contract_ID;

    event FlightStart(uint256 F_ID, uint256 _st, uint256 tokens);
    event FlightEnd(uint256 F_ID, uint256 _end, uint256 uHash, uint256 _mins);

    struct Flight {
        uint256 Flight_start_time;
        uint256 Flight_end_time;
        uint256 McFLY_tokens_reserved;
        uint256 Universa_Hash;
        address Car_ID;
        address Pad_Owner_Departure_ID;
        address Pad_Owner_Arrival_ID;
        address Charging_Owner_ID;
        address Pilot_ID;
        address ATM_ID;
        address City_Management_ID;
        address Insurance_ID;
        address Catering_ID;
        address App_ID;
    }
    mapping(uint256 => Flight) public flights;

    struct FlightFee {
        uint type_of_pay;
        uint256 value;
    }
    mapping(address => FlightFee) public flightFees;

    constructor () public {
        GridMaster_Contract_ID = address(this);
    }
    
    function Start_Flight(
        uint256 _Flight_ID,
        uint256 _Flight_start_time,
        uint256 _McFLY_tokens_reserved,
        address _Car_ID,
        address _Pad_Owner_Departure_ID,
        address _Pad_Owner_Arrival_ID,
        address _Charging_Owner_ID,
        address _Pilot_ID,
        address _ATM_ID,
        address _City_Management_ID,
        address _Insurance_ID,
        address _Catering_ID,
        address _App_ID
        ) public onlyOwner 
        {
            require(_Flight_ID != 0);

            require(_McFLY_tokens_reserved != 0);
            require(_Car_ID != address(0));
            require(_Pad_Owner_Departure_ID != address(0));
            require(_Pad_Owner_Arrival_ID != address(0));
            require(_Charging_Owner_ID != address(0));
            require(_Pilot_ID != address(0));
            require(_ATM_ID != address(0));
            require(_City_Management_ID != address(0));
            require(_Insurance_ID != address(0));
            require(_Catering_ID != address(0));
            require(_App_ID != address(0));

            flights[_Flight_ID].Flight_start_time = _Flight_start_time;
            flights[_Flight_ID].McFLY_tokens_reserved = _McFLY_tokens_reserved;
            flights[_Flight_ID].Car_ID = _Car_ID;
            flights[_Flight_ID].Pad_Owner_Departure_ID = _Pad_Owner_Departure_ID;
            flights[_Flight_ID].Pad_Owner_Arrival_ID = _Pad_Owner_Arrival_ID;
            flights[_Flight_ID].Charging_Owner_ID = _Charging_Owner_ID;
            flights[_Flight_ID].Pilot_ID = _Pilot_ID;
            flights[_Flight_ID].ATM_ID = _ATM_ID;
            flights[_Flight_ID].City_Management_ID = _City_Management_ID;
            flights[_Flight_ID].Insurance_ID = _Insurance_ID;
            flights[_Flight_ID].Catering_ID = _Catering_ID;
            flights[_Flight_ID].App_ID = _App_ID;
            
            emit FlightStart(_Flight_ID, _Flight_start_time, _McFLY_tokens_reserved);
    }


    function Set_Flight_Fees(
        uint256 _Flight_ID,
        uint256 _Car_Fee,
        uint256 _Pad_Owner_Departure_Fee,
        uint256 _Pad_Owner_Arrival_Fee,
        uint256 _Charging_Owner_Fee,
        uint256 _Pilot_Fee,
        uint256 _ATM_Fee,
        uint256 _City_Management_Fee,
        uint256 _Insurance_Fee,
        uint256 _Catering_Fee,
        uint256 _App_Fee
        ) public onlyOwner 
        {
            flightFees[flights[_Flight_ID].Car_ID].value = _Car_Fee;
            flightFees[flights[_Flight_ID].Pad_Owner_Departure_ID].value = _Pad_Owner_Departure_Fee;
            flightFees[flights[_Flight_ID].Pad_Owner_Arrival_ID].value = _Pad_Owner_Arrival_Fee;
            flightFees[flights[_Flight_ID].Charging_Owner_ID].value = _Charging_Owner_Fee;
            flightFees[flights[_Flight_ID].Pilot_ID].value = _Pilot_Fee;
            flightFees[flights[_Flight_ID].ATM_ID].value = _ATM_Fee;
            flightFees[flights[_Flight_ID].City_Management_ID].value = _City_Management_Fee;
            flightFees[flights[_Flight_ID].Insurance_ID].value = _Insurance_Fee;
            flightFees[flights[_Flight_ID].Catering_ID].value = _Catering_Fee;
            flightFees[flights[_Flight_ID].App_ID].value = _App_Fee;
    }


    function Finish_Flight(uint256 _Flight_ID, uint256 _Flight_end_time, uint256 _Universa_Hash, uint256 _totalMins) public onlyOwner {
        require(_Flight_ID != 0);

        flights[_Flight_ID].Flight_end_time = _Flight_end_time;
        flights[_Flight_ID].Universa_Hash = _Universa_Hash;

        token_McFLY.transfer(flights[_Flight_ID].Car_ID, flightFees[flights[_Flight_ID].Car_ID].value * _totalMins);
        token_McFLY.transfer(flights[_Flight_ID].Pad_Owner_Departure_ID, flightFees[flights[_Flight_ID].Pad_Owner_Departure_ID].value);
        token_McFLY.transfer(flights[_Flight_ID].Pad_Owner_Arrival_ID, flightFees[flights[_Flight_ID].Pad_Owner_Arrival_ID].value);
        token_McFLY.transfer(flights[_Flight_ID].Charging_Owner_ID, flightFees[flights[_Flight_ID].Charging_Owner_ID].value);
        token_McFLY.transfer(flights[_Flight_ID].Pilot_ID, flightFees[flights[_Flight_ID].Pilot_ID].value * _totalMins);
        token_McFLY.transfer(flights[_Flight_ID].ATM_ID, flightFees[flights[_Flight_ID].ATM_ID].value);
        token_McFLY.transfer(flights[_Flight_ID].City_Management_ID, flightFees[flights[_Flight_ID].City_Management_ID].value);
        token_McFLY.transfer(flights[_Flight_ID].Insurance_ID, flightFees[flights[_Flight_ID].Insurance_ID].value);
        token_McFLY.transfer(flights[_Flight_ID].Catering_ID, flightFees[flights[_Flight_ID].Catering_ID].value);
        token_McFLY.transfer(flights[_Flight_ID].App_ID, flightFees[flights[_Flight_ID].App_ID].value);

        emit FlightEnd(_Flight_ID, _Flight_end_time, _Universa_Hash, _totalMins);
    }


    function DeleteMe() public onlyOwner {
        selfdestruct(msg.sender);
    }
}