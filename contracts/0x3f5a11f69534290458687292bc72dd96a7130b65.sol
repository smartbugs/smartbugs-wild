pragma solidity ^0.4.17;

contract meOw {
    uint256 public totalUsers;
    
    mapping ( address => mapping ( bytes32 => bool ) ) public counters;
    mapping ( bytes32 => UserMeta ) public profiles;
    
    struct UserMeta {
        address admin;
        string username;
        string name;
        string bio;
        string about;
        uint positive_counter;
        uint negative_counter;
        uint time;
        uint update_time;
        bool status;
    }
    
    
    
    function meOw() public {
        
    }
    
    function stringToBytes32(string memory source) internal pure returns (bytes32 result) {
        bytes memory tempEmptyStringTest = bytes(source);
        if (tempEmptyStringTest.length == 0) {
            return 0x0;
        }
    
        assembly {
            result := mload(add(source, 32))
        }
    }
    
    function _validateUserName(string _username) internal pure returns (bool){
        bytes memory b = bytes(_username);
        if(b.length > 32) return false;
        
        uint counter = 0;
        for(uint i; i<b.length; i++){
            bytes1 char = b[i];
            
            if(
                !(char >= 0x30 && char <= 0x39)   //9-0
                && !(char >= 0x61 && char <= 0x7A)  //a-z
                && !(char == 0x2D) // - 
                && !(char == 0x2E && counter == 0) // . 
            ){
                return false;
            }
            
            if(char == 0x2E) counter++; 
        }
    
        return true;
    }
    
    function register(
        string _username, 
        string _name, 
        string _bio, 
        string _about
    ) public returns (bool _status) {
        require( _validateUserName(_username) );
        
        bytes32 _unBytes = stringToBytes32(_username);
        UserMeta storage u = profiles[_unBytes];
        
        require( !u.status );
        
        totalUsers++;
        
        u.admin = msg.sender;
        u.username = _username;
        u.name = _name;
        u.bio = _bio;
        u.about = _about;
        u.time = now;
        u.update_time = now;
        u.status = true;
        
        _status = true;
    }
    
    function update(
        string _username, 
        address _admin, 
        string _name, 
        string _bio, 
        string _about
    ) public returns (bool _status) {
        bytes32 _unBytes = stringToBytes32(_username);
        UserMeta storage u = profiles[_unBytes];
        
        require(
            u.status 
            && u.admin == msg.sender
        );
        
        u.admin = _admin;
        u.name = _name;
        u.bio = _bio;
        u.about = _about;
        u.update_time = now;
        
        _status = true;
    }
    
    function review(
        string _username, 
        bool _positive
    ) public returns (bool _status) {
        bytes32 _unBytes = stringToBytes32(_username);
        UserMeta storage u = profiles[_unBytes];
        
        require( 
            u.status 
            && !counters[msg.sender][_unBytes]
        );
        
        counters[msg.sender][_unBytes] = true;
        
        if(_positive){
            u.positive_counter++;
        } else {
            u.negative_counter++;
        }
        
        _status = true;
    }
    
}