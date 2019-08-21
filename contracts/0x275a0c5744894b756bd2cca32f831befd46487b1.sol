pragma solidity ^0.4.24;

    contract DAO {
        function balanceOf(address addr) public returns (uint);
    }
    
    interface RegisterInterface {
        function register(string);
    }
    
// auth
contract Auth {
    address      public  owner;
    constructor () public {
         owner = msg.sender;
    }
    
    modifier auth {
        require(isAuthorized(msg.sender) == true);
        _;
    }
    
    function isAuthorized(address src) internal view returns (bool) {
        if(src == owner){
            return true;
        } else {
            return false;
        }
    }
}

contract TokenTimelock is Auth{
    
    constructor() public {
        benificiary = msg.sender;
    }
    
    uint constant public days_of_month = 30;
    
    uint[] public dateArray;
    uint public release_percent = 0;
    
    mapping (uint => bool) public release_map;
    uint256 public totalFutureRelease = 0;
    
    // cosToken address, 
    address constant public contract_addr = 0x589891a198195061cb8ad1a75357a3b7dbadd7bc;
    address public benificiary;
    uint     public  startTime; 
    bool public lockStart = false;
    
    // set total cos to lock
    function set_total(uint256 total) auth public {
        require(lockStart == false);
        totalFutureRelease = total;
    }
    
    // set month to release
    function set_lock_info(int startMonth,int periods,int percent,int gap) auth public {
        require(lockStart == false);
        require(startMonth > 0);
        require(periods > 0);
        require(percent > 0);
        require(gap > 0);
        require(periods * percent == 100);
        release_percent = uint(percent);
        uint tmp = uint(startMonth);
        delete dateArray;
        for (int i = 0; i < periods; i++) {
             dateArray.push(tmp * days_of_month);
             tmp += uint(gap);
        }
    }

    // when transfer certain balance to this contract address, we can call lock
    function lock(int offsetMinutes) auth public returns(bool) {
        require(lockStart == false);
        require(offsetMinutes >= 0);
        for(uint i = 0; i < dateArray.length; i++) {
            require(dateArray[i] != 0);
        }
        require(release_percent != 0);
        require(totalFutureRelease != 0);
        
        DAO cosTokenApi = DAO(contract_addr);
        uint256 balance = cosTokenApi.balanceOf(address(this));
        require(balance == totalFutureRelease);
        
        startTime = block.timestamp + uint(offsetMinutes) * 1 minutes;
        lockStart = true;
    }
    
    function set_benificiary(address b) auth public {
        benificiary = b;
    }
    
    function release_specific(uint i) private {
        if (release_map[i] == true) {
            emit mapCheck(true,i);
            return;
        }
        emit mapCheck(false,i);
        
        DAO cosTokenApi = DAO(contract_addr);
        uint256 balance = cosTokenApi.balanceOf(address(this));
        uint256 eachRelease = 0;
        eachRelease = (totalFutureRelease / 100) * release_percent;
        
        bool ok = balance >= eachRelease; 
        emit balanceCheck(ok,balance);
        require(balance >= eachRelease);
  
        bool success = contract_addr.call(bytes4(keccak256("transfer(address,uint256)")),benificiary,eachRelease);
        emit tokenTransfer(success);
        require(success);
        release_map[i] = true;
    }
    
    event mapCheck(bool ok,uint window);
    event balanceCheck(bool ok,uint256 balance);
    event tokenTransfer(bool success);

    function release() auth public {
        require(lockStart == true);
        require(release_map[dateArray[dateArray.length-1]] == false);
        uint theDay = dayFor();
        
        for (uint i=0; i<dateArray.length;i++) {
            if(theDay > dateArray[i]) {
                release_specific(dateArray[i]);
            }
        }
    }
    
        // days after lock
    function dayFor() view public returns (uint) {
        uint timestamp = block.timestamp;
        return timestamp < startTime ? 0 : (timestamp - startTime) / 1 days + 1;
    }
    
    function regist(string key) auth public {
        RegisterInterface(contract_addr).register(key);
    }
}