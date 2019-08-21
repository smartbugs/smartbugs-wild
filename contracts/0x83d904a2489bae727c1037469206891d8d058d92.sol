contract Destination {
    function recover(address _from, address _to) returns(bool);
}

contract RecoveryWithTenant {
    event Recovery(uint indexed nonce, address indexed from, address indexed to);
    event Setup(uint indexed nonce, address indexed user);
    
    //1: user not existing
    //2: conflict, user exists already
    //3: signature not by tenant
    //4: nonce/signature used before
    //5: contract call failed
    //6: oracle access denied
    //8: requested user not found
    event Error(uint indexed nonce, uint code);
    
    struct User {
        address addr;
    }
    
    mapping (address => uint) userIndex;
    User[] public users;

    address public oracle;
    address public tenant;
    mapping(uint => bool) nonceUsed;
    address public callDestination;


    modifier onlyOracle() {
        if (msg.sender == oracle) {
            _
        }
        Error(0, 6);
    }
    
    modifier noEther() {
        if (msg.value > 0) throw;
        _
    }

    function RecoveryWithTenant() {
        oracle = msg.sender;
        tenant = msg.sender;
        users.length++;
    }
    
    //############# INTERNAL FUNCTIONS
    
    function _checkSigned(bytes32 _hash, uint _nonce, uint8 _v, bytes32 _r, bytes32 _s) internal returns (bool) {
        address recovered = ecrecover(_hash, _v, _r, _s);

        if (tenant != recovered) {
            Error(_nonce, 3);
            return false;
        }
        if (nonceUsed[_nonce]) {
            Error(_nonce, 4);
            return false;
        }
        nonceUsed[_nonce] = true; 
        return true;
    }
    
    
    //############# PUBLIC FUNCTIONS
    
    function setOracle(address _newOracle) noEther onlyOracle {
        oracle = _newOracle;
    }
    
    function configure(address _tenant, address _callDestination, uint _nonce, uint8 _v, bytes32 _r, bytes32 _s) noEther onlyOracle returns (bool) {
        if(tenant != oracle && !_checkSigned(sha3(_tenant, _callDestination, _nonce), _nonce, _v, _r, _s))
            return false;
        tenant = _tenant;
        callDestination = _callDestination;
        return true;
    }
    
    
    function addUser(address _userAddr, uint _nonce, uint8 _v, bytes32 _r, bytes32 _s) noEther onlyOracle returns (bool) {
        if(userIndex[_userAddr] > 0) {
            Error(_nonce, 2);
            return false;
        }
        if(!_checkSigned(sha3(_userAddr, _nonce), _nonce, _v, _r, _s))
            return false;
        uint posUser = users.length++;
        userIndex[_userAddr] = posUser;
        users[posUser] = User(_userAddr);
        Setup(_nonce, _userAddr);
        return true;
    }
    
    function recoverUser(address _oldAddr, address _newAddr, uint _nonce, uint8 _v, bytes32 _r, bytes32 _s) noEther onlyOracle returns (bool) {
        uint userPos = userIndex[_oldAddr];
        if (userPos == 0) {
            Error(_nonce, 1); //user doesn't exsit
            return false;
        }
        
        if (!_checkSigned(sha3(_oldAddr, _newAddr, _nonce), _nonce, _v, _r, _s))
            return false;
        bool result = Destination(callDestination).recover(_oldAddr, _newAddr);
        if (result) {
            users[userPos].addr = _newAddr;
            delete userIndex[_oldAddr];
            userIndex[_newAddr] = userPos;
            Recovery(_nonce, _oldAddr, _newAddr);
            return true;
        }
        Error(_nonce, 5);
        return false;
    }

    function () noEther {
        throw;
    }
    
    //############# STATIC FUNCTIONS
    
    function isUser(address _userAddr) constant returns (bool) {
        return (userIndex[_userAddr] > 0);
    }

}