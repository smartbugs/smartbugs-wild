pragma solidity 0.4.19;

contract carnitaAsada{
    address addressManager; // Oscar Angel Cardenas
    address  bitsoAddress; //address to pay carnitaAsada
    carnita [] carnitas; //array of carnitas
    uint256 lastCarnita; //index of last carnita
    bool public halted = false; // flag for emergency stop or start
    uint256 currentPeople; // current max number of people who can participate
    uint256 priceCarnita; // current price of carnita
    uint toPaycarnita; // amount will pay to the carnita 
    
    struct carnita{
        uint256 maxPeople; //max quantity of participants
        bool active; // flag to see if is still active
        uint256 raised; //amount of eth raised
        uint256 min; //minimun eth to participate
        address[] participants; //list of participants
        
    }
    
    function carnitaAsada(address _manager, address _bitso) public{
        addressManager= _manager;
        bitsoAddress= _bitso;
        lastCarnita=0;
        priceCarnita= 0.015 ether;
        currentPeople= 8;
        toPaycarnita=0.012 ether;
        
        //first carnitaAsada
        carnita memory temp;
        temp.maxPeople=currentPeople;
        temp.active=true;
        temp.raised=0;
        temp.min=priceCarnita;
        carnitas.push(temp);
       
    }
    
    // only manager can do this action
    modifier onlyManager() {
        require(msg.sender ==  addressManager);
        _;
    }
    // Checks if Contract is running and has not been stopped
    modifier onContractRunning() {
        require( halted == false);
        _;
    }
    // Checks if Contract was stopped or deadline is reached
    modifier onContractStopped() {
      require( halted == true);
        _;
    }

   
    //generate a random number
    function rand() internal constant returns (uint32 res){
        return uint32(block.number^now)%uint32(carnitas[lastCarnita].participants.length);
    }
    
    //recover funds in case of error
    function recoverAllEth() onlyManager public {
        addressManager.transfer(this.balance);
    }
    
    /*
    *   Emergency Stop or Contract.
    *
    */

    function  halt() onlyManager  onContractRunning public{
         halted = true;
    }

    function  unhalt() onlyManager onContractStopped public {
        halted = false;
    }
    
    //change manager
    function newManager(address _newManager) onlyManager public{
        addressManager= _newManager;
    }
    //see the current manager
    function getManager() public constant returns (address _manager){
        return addressManager;
    }
    //change bitsoAddress
    function newBitsoAddress(address _newAddress) onlyManager public{
        addressManager= _newAddress;
    }
    //see the current manager
    function getBitsoAddress() public constant returns (address _bitsoAddress){
        return bitsoAddress;
    }
    // see the current price of carnita
    function getPrice() public constant returns(uint256 _price){
        return priceCarnita;
    }
    
   // Change current price of carnita
    function setPrice(uint256 _newPriceCarnita) onlyManager public{
        priceCarnita=_newPriceCarnita;
        carnitas[lastCarnita].min=priceCarnita;
    }
    
    // see the current price to Paycarnita
    function getPaycarnita() public constant returns(uint256 _Paycarnita){
        return toPaycarnita;
    }
    
   // Change current price of Paycarnita
    function setPaycarnita(uint256 _newPaycarnita) onlyManager public{
        toPaycarnita=_newPaycarnita;
    }
    
    // see the current max participants
    function getMaxParticipants() public constant returns(uint256 _max){
        return currentPeople;
    }
    // Change current minimun of max participants
    function setMaxParticipants(uint256 _newMax) onlyManager public{
        currentPeople=_newMax;
        carnitas[lastCarnita].maxPeople=currentPeople;
    }
    
   
    //check the number of current participants
    function seeCurrentParticipants()public constant returns(uint256 _participants){
        return carnitas[lastCarnita].participants.length;
    }
    // add new participant
    function addParticipant(address _buyer, uint256 _value) internal {
        require(_value == priceCarnita || _buyer== addressManager);
        /*if (carnitas[lastCarnita].maxPeople == carnitas[lastCarnita].participants.length){
            newCarnita();
        }*///this no works because is created when the payCarnita function is called
        carnitas[lastCarnita].participants.push(_buyer);
        carnitas[lastCarnita].raised+=_value;
        if(carnitas[lastCarnita].maxPeople == carnitas[lastCarnita].participants.length){
            halted = true;
        }
        
    }
    //generate new carnitaAsada
    function newCarnita() internal{
        carnitas[lastCarnita].active=false;
        carnita memory temp;
        temp.maxPeople=currentPeople;
        temp.active=true;
        temp.raised=0;
        temp.min=priceCarnita;
        carnitas.push(temp);
        lastCarnita+=1;
    }
    
    //pay the carnitaAsada
    
    function payCarnita(uint256 _gasUsed, uint256 _bill) onlyManager public{
        uint256 winner = uint256(rand());// define a random winner
        addressManager.transfer(_gasUsed); //pay the gas to the Manager
        
        //to pay the bill could be toPaycarnita variable or set by manager
        if(_bill>0){
            bitsoAddress.transfer(carnitas[lastCarnita].participants.length*_bill);
        }else{
        bitsoAddress.transfer(carnitas[lastCarnita].participants.length*toPaycarnita);
        }
        
        carnitas[lastCarnita].participants[winner].transfer(this.balance);//send money to the winner
        halted=false;//activate the Contract again
        newCarnita(); //create new carnita
        
    }
    
    /*
     *  default fall back function      
     */
    function () onContractRunning payable  public {
                 addParticipant(msg.sender, msg.value);           
            }
    
    
    
    
    
    
}