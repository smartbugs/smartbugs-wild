pragma solidity ^0.4.24;

contract Whitelist {

    address public owner;
    mapping(address => bool) public whitelistAdmins;
    mapping(address => bool) public whitelist;

    constructor () public {
        owner = msg.sender;
        whitelistAdmins[owner] = true;
    }

    modifier onlyOwner () {
        require(msg.sender == owner, "Only owner");
        _;
    }

    modifier onlyWhitelistAdmin () {
        require(whitelistAdmins[msg.sender], "Only whitelist admin");
        _;
    }

    function isWhitelisted(address _addr) public view returns (bool) {
        return whitelist[_addr];
    }

    function addWhitelistAdmin(address _admin) public onlyOwner {
        whitelistAdmins[_admin] = true;
    }

    function removeWhitelistAdmin(address _admin) public onlyOwner {
        require(_admin != owner, "Cannot remove contract owner");
        whitelistAdmins[_admin] = false;
    }

    function whitelistAddress(address _user) public onlyWhitelistAdmin  {
        whitelist[_user] = true;
    }

    function whitelistAddresses(address[] _users) public onlyWhitelistAdmin {
        for (uint256 i = 0; i < _users.length; i++) {
            whitelist[_users[i]] = true;
        }
    }

    function unWhitelistAddress(address _user) public onlyWhitelistAdmin  {
        whitelist[_user] = false;
    }

    function unWhitelistAddresses(address[] _users) public onlyWhitelistAdmin {
        for (uint256 i = 0; i < _users.length; i++) {
            whitelist[_users[i]] = false;
        }
    }

}