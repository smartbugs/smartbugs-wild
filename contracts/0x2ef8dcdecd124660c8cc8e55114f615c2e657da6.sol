pragma solidity ^0.4.18;



contract OsherCrowdsaleCore {
    
    function crowdsale( address _address )payable;
    function precrowdsale( address _address )payable;
}

contract OsherCrowdsale {
    
    address public owner;
    
    
   
    bool public crowdSaleStarted;
    bool public crowdSaleClosed;
    bool public  crowdSalePause;
    
    uint public crowdSaleStartTime;
    uint public preicostarted;
    
    uint public deadline;
    
    address public CoreAddress;
    OsherCrowdsaleCore  core;
    
    
    
    
    modifier onlyOwner() {
        if (msg.sender != owner) {
            throw;
        }
        _;
    }

    
    
    
    function OsherCrowdsale(){
        
        crowdSaleStarted = false;
        crowdSaleClosed = false;
        crowdSalePause = false;
        preicostarted = now;
        owner = msg.sender;
        
    }
    
    // fallback function to receive all incoming ether funds and then forwarded to the DragonCrowdsaleCore contract 
    function () payable {
        
        require ( crowdSaleClosed == false && crowdSalePause == false  );
        
        if ( crowdSaleStarted ) { 
            require ( now < deadline );
            core.crowdsale.value( msg.value )( msg.sender); 
            
        } 
        else
        { core.precrowdsale.value( msg.value )( msg.sender); }
       
    }
    
    
   
    // Start this to initiate crowdsale - will run for 60 days
    function startCrowdsale() onlyOwner  {
        
        crowdSaleStarted = true;
        crowdSaleStartTime = now;
        deadline = now + 60 days;
       
                
    }

    //terminates the crowdsale
    function endCrowdsale() onlyOwner  {
        
        
        crowdSaleClosed = true;
    }

    //pauses the crowdsale
    function pauseCrowdsale() onlyOwner {
        
        crowdSalePause = true;
        
        
    }

    //unpauses the crowdsale
    function unpauseCrowdsale() onlyOwner {
        
        crowdSalePause = false;
        
        
    }
    
    // set the dragon crowdsalecore contract
    function setCore( address _core ) onlyOwner {
        
        require ( _core != 0x00 );
        CoreAddress = _core;
        core = OsherCrowdsaleCore( _core );
        
    }
    
    function transferOwnership( address _address ) onlyOwner {
        
        require ( _address!= 0x00 );
        owner =  _address ;
        
    }
    
    
    
    
    
    
    
}