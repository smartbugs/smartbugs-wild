pragma solidity ^0.4.17;

contract ExtendData {
    
   struct User {
        bytes32 username;
        bool verified;
    }

    modifier onlyOwners {
        require(owners[msg.sender]);
        _;
    }

    mapping(bytes32 => address) usernameToAddress;
    mapping(bytes32 => address) queryToAddress;
    mapping(address => mapping(bytes32 => uint)) tips;
    mapping(address => mapping(bytes32 => uint)) lastTip;
    mapping(bytes32 => uint) balances;
    mapping(address => User) users;   
    mapping(address => bool) owners;
    
    function ExtendData() public {
        owners[msg.sender] = true;
    }
    
    //getters
    function getAddressForUsername(bytes32 _username) public constant onlyOwners returns (address) {
        return usernameToAddress[_username];
    }

    function getAddressForQuery(bytes32 _queryId) public constant onlyOwners returns (address) {
        return queryToAddress[_queryId];
    }
    
    function getBalanceForUser(bytes32 _username) public constant onlyOwners returns (uint) {
        return balances[_username];
    }
    
    function getUserVerified(address _address) public constant onlyOwners returns (bool) {
        return users[_address].verified;
    }
    
    function getUserUsername(address _address) public constant onlyOwners returns (bytes32) {
        return users[_address].username;
    }

    function getTip(address _from, bytes32 _to) public constant onlyOwners  returns (uint) {
        return tips[_from][_to];
    }
  
    function getLastTipTime(address _from, bytes32 _to) public constant onlyOwners returns (uint) {
        return lastTip[_from][_to];
    }

    //setters
    function setQueryIdForAddress(bytes32 _queryId, address _address) public onlyOwners {
        queryToAddress[_queryId] = _address;
    }
   
    function setBalanceForUser(bytes32 _username, uint _balance) public onlyOwners {
        balances[_username] = _balance;
    }
 
    function setUsernameForAddress(bytes32 _username, address _address) public onlyOwners {
        usernameToAddress[_username] = _address;
    }

    function setVerified(address _address) public onlyOwners {
        users[_address].verified = true;
    }

    function addTip(address _from, bytes32 _to, uint _tip) public onlyOwners {
        tips[_from][_to] += _tip;
        balances[_to] += _tip;
        lastTip[_from][_to] = now;     
    }

    function addUser(address _address, bytes32 _username) public onlyOwners {
        users[_address] = User({
                username: _username,
                verified: false
            });
    }

    function removeTip(address _from, bytes32 _to) public onlyOwners {
        balances[_to] -= tips[_from][_to];
        tips[_from][_to] = 0;
    }
    
    //owner modification
    function addOwner(address _address) public onlyOwners {
        owners[_address] = true;
    }
    
    function removeOwner(address _address) public onlyOwners {
        owners[_address] = false;
    }
}