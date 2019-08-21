pragma solidity ^0.4.2;

contract Geocache {
  struct VisitorLog {
    address visitor;
    string name;
    string dateTime; // Time in UTC, Format: "1993-10-13T03:24:00"
    string location; // "[lat,lon]"
    string note;
    string imageUrl;
  }

  VisitorLog[] public visitorLogs;

  // because no optional params, interface has to send all fields. if field is empty, send empty string.
  function createLog(string _name, string _dateTime, string _location, string _note, string _imageUrl) public {
    visitorLogs.push(VisitorLog(msg.sender, _name, _dateTime, _location, _note, _imageUrl));
  }

  // because can't return an array, need to return length of array and then up to front end to get entries at each index of visitorLogs array
  function getNumberOfLogEntries() public view returns (uint) {
    return visitorLogs.length;
  }

  // set magic 0th position - the first log entry
  function setFirstLogEntry() public {
    require(msg.sender == 0x8d3e809Fbd258083a5Ba004a527159Da535c8abA);
    visitorLogs.push(VisitorLog(0x0, "Mythical Geocache Creator", "2018-08-31T12:00:00", "[50.0902822,14.426874199999997]", "I was here first", " " ));
  }
}