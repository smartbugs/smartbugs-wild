pragma solidity ^ 0.4.11;


contract Dragon {
    function transfer( address _to, uint256 _amount );
}


contract DragonDistributions {
    

    address public dragon;
    uint256 public clock;
    mapping ( address => uint256 ) public  balanceOf;
    mapping ( address => bool ) public  distributionOne;
    mapping ( address => bool ) public  distributionTwo;
    mapping ( address => bool ) public  distributionThree;
    mapping ( address => bool ) public  advisors;
   
    
    
    
    modifier onlyDragon() {
        if (msg.sender != dragon) {
            throw;
        }
        _;
    }
    
    function DragonDistributions () {
        
        dragon = 0x1d1CF6cD3fE91fe4d1533BA3E0b7758DFb59aa1f;
        clock = now;
        
        balanceOf[ 0xdFCf69C8FeD25F5150Db719BAd4EfAb64F628d31 ] = 45000000000000;
        balanceOf[ 0x74Fc8fA4F99b6c19C250E4Fc6952051a95F6060D ] = 45000000000000;
        balanceOf[ 0xCC3c6A89B5b8a054f21bCEff58B6429447cd8e5E ] = 45000000000000;
        
        advisors [ 0xdFCf69C8FeD25F5150Db719BAd4EfAb64F628d31 ] = true;
        advisors [ 0x74Fc8fA4F99b6c19C250E4Fc6952051a95F6060D ] = true;
        advisors [ 0xCC3c6A89B5b8a054f21bCEff58B6429447cd8e5E ] = true;
        
        
        
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
        
        if ( distributionTwo[ msg.sender ] == false && now > clock + 80 days ){
            
            
            distributionTwo[ msg.sender ] = true;
            total += 15000000000000;
            balanceOf[ msg.sender ] -= 15000000000000; 
            
        }
        
        if ( distributionThree[ msg.sender ] == false && now > clock + 445 days ){
            distributionThree[ msg.sender ] = true;
            total += 15000000000000;
            balanceOf[ msg.sender ] -= 15000000000000; 
            
        }
        
        
        
        
        drg.transfer ( msg.sender, total);
    } 
 
    
    
}