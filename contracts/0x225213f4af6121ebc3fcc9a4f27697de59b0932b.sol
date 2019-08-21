pragma solidity ^0.4.25;

contract BlockTO_9 {
    address[] addresses;
    mapping (address => bool) addressValidated;
    
    function becomeValidator() public {
        require(!isValidator(msg.sender));
        require(addresses.length < 10);
        addresses.push(msg.sender);
        addressValidated[msg.sender] = true;
    }

    function isValidator(address _who) public view returns (bool) {
        return addressValidated[_who];
    }

    function getValidators() public view returns(address[]) {
        return addresses;
    }
}