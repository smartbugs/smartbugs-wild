pragma solidity 0.5.7;

contract CuratorsInterface {
  function checkRole(address _operator, string memory _permission) public view;
}

contract pDNA {
  CuratorsInterface public curators = CuratorsInterface(0x2D1711aDA9DD2Bf8792AD29DD4E307D6527f2Ad5);

  string public name;
  string public symbol;

  mapping(string => string) private files;

  event FilePut(address indexed curator, string hash, string name);

  constructor(string memory _eGrid, string memory _grundstuck) public {
    curators.checkRole(msg.sender, "authorized");
    name = _eGrid;
    symbol = _grundstuck;
  }

  function getFile(string memory _name) public view returns (string memory) {
    return files[_name];
  }

  function putFile(string memory _hash, string memory _name) public {
    curators.checkRole(msg.sender, "authorized");
    files[_name] = _hash;
    emit FilePut(msg.sender, _hash, _name);
  }
}