pragma solidity ^0.4.18;

contract Profile {
  mapping (address => string) private usernameOfOwner;
  mapping (address => string) private agendaOfOwner;
  mapping (string => address) private ownerOfUsername;

  event Set (string indexed _username, string indexed _agenda, address indexed _owner);
  event SetUsername (string indexed _username, address indexed _owner);
  event SetAgenda (string indexed _agenda, address indexed _owner);
  event Unset (string indexed _username, string indexed _agenda, address indexed _owner);
  event UnsetUsername(string indexed _username, address indexed _owner);
  event UnsetAgenda(string indexed _agenda, address indexed _owner);


  function Profile () public {
  }

  function usernameOf (address _owner) public view returns (string _username) {
    return usernameOfOwner[_owner];
  }

  function agendaOf (address _owner) public view returns (string _agenda) {
    return agendaOfOwner[_owner];
  }

  function getUserValues(address _owner) public view returns (string _username, string _agenda){
    return (usernameOfOwner[_owner], agendaOfOwner[_owner]);
  }

  function ownerOf (string _username) public view returns (address _owner) {
    return ownerOfUsername[_username];
  }

  function set (string _username, string _agenda) public {
    require(bytes(_username).length > 2);
    require(bytes(_agenda).length > 2);
    require(ownerOf(_username) == address(0) || ownerOf(_username) == msg.sender);
    address owner = msg.sender;
    string storage oldUsername = usernameOfOwner[owner];
    string storage oldAgenda = agendaOfOwner[owner];
    if (bytes(oldUsername).length > 0 && bytes(oldAgenda).length > 0) {
      Unset(oldUsername, oldAgenda, owner);
      delete ownerOfUsername[oldUsername];
    }
    usernameOfOwner[owner] = _username;
    agendaOfOwner[owner] = _agenda;
    ownerOfUsername[_username] = owner;
    Set(_username, _agenda, owner);
  }

  function setUsername (string _username) public {
    require(bytes(_username).length > 2);
    require(ownerOf(_username) == address(0) || ownerOf(_username) == msg.sender);
    address owner = msg.sender;
    string storage oldUsername = usernameOfOwner[owner];
    if(bytes(oldUsername).length > 0) {
      UnsetUsername(oldUsername, owner);
      delete ownerOfUsername[oldUsername];
    }
    usernameOfOwner[owner] = _username;
    ownerOfUsername[_username] = owner;
    SetUsername(_username, owner);
  }

  function setAgenda (string _agenda) public {
    require(bytes(_agenda).length > 2);
    address owner = msg.sender;
    string storage oldAgenda = agendaOfOwner[owner];
    if(bytes(oldAgenda).length > 0) {
      UnsetAgenda(oldAgenda, owner);
    }
    agendaOfOwner[owner] = _agenda;
    SetUsername(_agenda, owner);
  }

  function unset () public {
    require(bytes(usernameOfOwner[msg.sender]).length > 0 && bytes(agendaOfOwner[msg.sender]).length > 0);
    address owner = msg.sender;
    string storage oldUsername = usernameOfOwner[owner];
    string storage oldAgenda = agendaOfOwner[owner];
    Unset(oldUsername, oldAgenda, owner);
    delete ownerOfUsername[oldUsername];
    delete usernameOfOwner[owner];
    delete agendaOfOwner[owner];
  }
}