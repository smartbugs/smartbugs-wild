pragma solidity ^0.5.9;

contract ImmDomains {

  address public owner;
  address public registrar;

  mapping(bytes => address) public addresses;

  event OwnerUpdate(address _owner);
  event RegistrarUpdate(address _registrar);
  event Registration(bytes _domain, address _address);

  constructor() public {
    owner = msg.sender;
    registrar = msg.sender;
  }

  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

  function setOwner(address _owner) onlyOwner() external {
    owner = _owner;
    emit OwnerUpdate(_owner);
  }

  function setRegistrar(address _registrar) onlyOwner() external {
    registrar = _registrar;
    emit RegistrarUpdate(_registrar);
  }

  function isValidCharacter(uint8 _character) public pure returns (bool) {
    if (_character >= 97 && _character <= 122) {
      // ASCII "a - z"
      return true;
    }
    if (_character >= 48 && _character <= 57) {
      // ASCII "0 - 9"
      return true;
    }
    return false;
  }

  function isValidDomain(bytes memory _domain) public pure returns (bool) {
    if(_domain.length == 0) {
      return false;
    }

    for (uint i; i < _domain.length; i++) {
      if(isValidCharacter(uint8(_domain[i])) == false) {
        return false;
      }
    }

    return true;
  }

  function register(bytes calldata _domain, address _address) external {

    require(msg.sender == registrar);
    require(_address != address(0));
    require(isValidDomain(_domain));
    require(addresses[_domain] == address(0));

    addresses[_domain] = _address;
    emit Registration(_domain, _address);

  }

}