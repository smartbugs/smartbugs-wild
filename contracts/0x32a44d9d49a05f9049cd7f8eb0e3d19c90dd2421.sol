pragma solidity ^ 0.4.11;


contract Dragon {
    function transfer( address _to, uint256 _amount )returns(bool ok);
}


contract DragonDistributions {
    

    address public dragon;
    uint256 public clock;
    address public prime;
    address public film;
    address public northadvisor;
    address public southadvisor;
    
    uint public filmamount;
    bool public filmpaid;
    
    mapping ( address => uint256 ) public  balanceOf;
    mapping ( address => bool ) public  distributionOne;
    mapping ( address => bool ) public  distributionTwo;
    mapping ( address => bool ) public  distributionThree;
    mapping ( address => bool ) public  advisors;
   
    uint256 public awardAmount       =  45000000000000;
    uint256 public awardAmountPrime  = 100000000000000;
    
    
    
    
    
    function DragonDistributions () {
        
        dragon = 0x814F67fA286f7572B041D041b1D99b432c9155Ee; // Hard code Dragon address
        prime =  0x243098c1e16973c7e3e969c289c5b87808e359c1; // prime Advisor Address
        film =   0xdFCf69C8FeD25F5150Db719BAd4EfAb64F628d31;// filmmaker address
        
        northadvisor = 0x74Fc8fA4F99b6c19C250E4Fc6952051a95F6060D;
        southadvisor = 0xCC3c6A89B5b8a054f21bCEff58B6429447cd8e5E;
        
        clock = now;
        
        filmamount = 2500000000000;
        
        balanceOf[ film ] = awardAmount + filmamount; // award amount plus film maker
        balanceOf[ northadvisor ] = awardAmount;
        balanceOf[ southadvisor ] = awardAmount;
        
        balanceOf[ prime ] = awardAmountPrime;
        
        advisors [ film ] = true;
        advisors [ northadvisor ] = true;
        advisors [ southadvisor ] = true;
        
        filmpaid = false;
        
        
        
        
    }
    
     modifier onlyPrime() {
        if (msg.sender != prime) {
            throw;
        }
        _;
    }

    modifier onlyFilm() {
        if ( msg.sender != film ) {
            throw;
        }
        _;
    }


    function withdrawDragons()
    {
        uint256 total = 0;
        
        require ( advisors[msg.sender] == true );
        
        Dragon drg = Dragon ( dragon );
        
        if ( distributionOne[ msg.sender ] == false ){
            distributionOne[ msg.sender ] = true;
            total += 15000000000000;
            balanceOf[ msg.sender ] -= 15000000000000; 
            
        }
        
        if ( distributionTwo[ msg.sender ] == false && now > clock + 22 days  ){
            
            
            distributionTwo[ msg.sender ] = true;
            total += 15000000000000;
            balanceOf[ msg.sender ] -= 15000000000000; 
            
        }
        
        if ( distributionThree[ msg.sender ] == false && now > clock + 387 days ){
            distributionThree[ msg.sender ] = true;
            total += 15000000000000;
            balanceOf[ msg.sender ] -= 15000000000000; 
            
        }
        
        
        drg.transfer ( msg.sender, total);
        
        
    } 
    
    
    function withdrawDragonsPrime() onlyPrime {
        
         uint _amount = balanceOf[ prime ];
         balanceOf[ prime ] = 0; 
         Dragon drg = Dragon ( dragon );
         drg.transfer ( prime , _amount );
 
    }
    
    function withdrawDragonsFilm() onlyFilm {
        
        if ( filmpaid == true ) throw;
         filmpaid = true;
         uint _amount = filmamount;
         balanceOf[ film ] -= filmamount; 
         Dragon drg = Dragon ( dragon );
         drg.transfer ( film , _amount );
 
    }
    
}