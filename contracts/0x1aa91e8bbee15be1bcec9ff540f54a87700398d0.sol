pragma solidity ^0.4.24;

contract Alias {
    mapping(string => address) aliasNameMapping;
    mapping(string => bool) aliasNameUsedMapping;
    mapping(address => string) aliasAddressMapping;
    mapping(address => bool) aliasAddressUsedMapping;

    constructor() public {
        setAlias("owner");
    }

    function setAlias(string _name) public {
        require(!aliasNameUsedMapping[_name]);
        require(!aliasAddressUsedMapping[msg.sender]);

        aliasNameUsedMapping[_name] = true;
        aliasAddressUsedMapping[msg.sender] = true;
        aliasNameMapping[_name] = msg.sender;
        aliasAddressMapping[msg.sender] = _name;
    }

    function getAddress(string _name) public view returns(address) {
        require(aliasNameUsedMapping[_name]);

        return aliasNameMapping[_name];
    }

    function getAlias(address _address) public view returns(string) {
        require(aliasAddressUsedMapping[_address]);

        return aliasAddressMapping[_address];
    }

    function resetAlias() public {
        require(aliasAddressUsedMapping[msg.sender]);

        string memory name = aliasAddressMapping[msg.sender];
        aliasNameUsedMapping[name] = false;
        aliasAddressUsedMapping[msg.sender] = false;
    }

    function send(string _name) public payable {
        require(aliasNameUsedMapping[_name]);
        require(msg.value > 0);

        aliasNameMapping[_name].transfer(msg.value);
    }
}