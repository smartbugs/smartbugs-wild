pragma solidity 0.4.25;

contract AlarmClock {

    event _newAlarmClock(address _contract, uint startBlock, uint blockWindow, uint reward, uint gas, bytes _callData);
    
    address public owner;
    //uint public initBlock;
    uint public totalTimers;
    uint public waitingTimers;
    
    struct ClockStruct {
        address _contract;
        uint startBlock;
        uint blockWindow;
        uint reward;
        uint gas;
        bytes callData;
    }
    
    //sha3("setA(uint256)")[0:8].hex()
    //'ee919d50'
    //0xee919d500000000000000000000000000000000000000000000000000000000000000001 - call setA(1), method selector 4 bytes
    
    //0x6a3d9d350000000000000000000000000000000000000000000000000000000000000005 - call alarmtest.testFunc(5)
    
    ClockStruct[] public clockList;
  
    constructor () public payable {
        owner = msg.sender;
        //initBlock = block.number;
        totalTimers = 0;
        waitingTimers = 0;
    }  
  
    modifier ownerOnly() {
        require(msg.sender == owner);
        _;
    }  
  
    // 1. transfer  //
    function setNewOwner(address _newOwner) public ownerOnly {
        owner = _newOwner;
    }   
  
    /*function refreshBlock() public ownerOnly {
        initBlock = block.number;
    }*/ 
  
    // gas required for registration ~200000
    function registerAlarmClock(address _contract, uint startBlock, uint blockWindow, uint gas, bytes  _callData) external payable {
        
        require(gas >= 200000);
        require(msg.value > gas);
        require(block.number < startBlock);
        
        clockList.push(ClockStruct(_contract, startBlock, blockWindow, msg.value - gas, gas, _callData));
        //uint id = clockList.push(ClockStruct(_contract, startBlock, blockWindow, msg.value - gas, gas, callData)) - 1;
        //clockToOwner[id] = msg.sender;
        //clockToValue[id] = msg.value;
        //ownerClockCount[msg.sender]++;
        
        totalTimers++;
        waitingTimers++;
        
        emit _newAlarmClock(_contract, startBlock, blockWindow, msg.value - gas, gas, _callData);
    }  
  
	// ~30000   +200000gas if called contract request new registration 
    function trigerAlarmClock(uint id) external payable {
        
        require(clockList[id].reward > 0);
        require(block.number >= clockList[id].startBlock);
        require(block.number < (clockList[id].startBlock + clockList[id].blockWindow));
        
        msg.sender.transfer(clockList[id].reward);
        require(clockList[id]._contract.call.value(0).gas(clockList[id].gas)(clockList[id].callData));
        
        clockList[id].reward = 0;
        waitingTimers--;
    }  
  
    // fallback function tigered, when contract gets ETH
    function() external payable {
        //?
    }   
    
    function _destroyContract() external ownerOnly {
        selfdestruct(msg.sender);
    }    
  
}