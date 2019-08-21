//pragma solidity ^0.4.24;
/*

$$$$$$$$\                                  $$$$$$$\                                                     $$\           $$$$$$$\            $$\ $$\           
$$  _____|                                 $$  __$$\                                                    $$ |          $$  __$$\           \__|$$ |          
$$ |    $$$$$$\  $$\   $$\  $$$$$$\        $$ |  $$ | $$$$$$\   $$$$$$\   $$$$$$$\  $$$$$$\  $$$$$$$\ $$$$$$\         $$ |  $$ | $$$$$$\  $$\ $$ |$$\   $$\ 
$$$$$\ $$  __$$\ $$ |  $$ |$$  __$$\       $$$$$$$  |$$  __$$\ $$  __$$\ $$  _____|$$  __$$\ $$  __$$\\_$$  _|        $$ |  $$ | \____$$\ $$ |$$ |$$ |  $$ |
$$  __|$$ /  $$ |$$ |  $$ |$$ |  \__|      $$  ____/ $$$$$$$$ |$$ |  \__|$$ /      $$$$$$$$ |$$ |  $$ | $$ |          $$ |  $$ | $$$$$$$ |$$ |$$ |$$ |  $$ |
$$ |   $$ |  $$ |$$ |  $$ |$$ |            $$ |      $$   ____|$$ |      $$ |      $$   ____|$$ |  $$ | $$ |$$\       $$ |  $$ |$$  __$$ |$$ |$$ |$$ |  $$ |
$$ |   \$$$$$$  |\$$$$$$  |$$ |            $$ |      \$$$$$$$\ $$ |      \$$$$$$$\ \$$$$$$$\ $$ |  $$ | \$$$$  |      $$$$$$$  |\$$$$$$$ |$$ |$$ |\$$$$$$$ |
\__|    \______/  \______/ \__|            \__|       \_______|\__|       \_______| \_______|\__|  \__|  \____/       \_______/  \_______|\__|\__| \____$$ |
                                                                                                                                                  $$\   $$ |
                                                                                                                                                  \$$$$$$  |
                                                                                                                                                   \______/ 

*     
*   https://fourpercentdaily.tk
*
*   Deposit ETH and automatically receive 4% of your deposit amount Daily!
*
*   Each Day at 2200 UTC our smart contract will distribute 4% of initial deposit amount to all investors 
*
*   How to invest:   Just send ether to our contract address.   Four Percent Daily will catalogue
*   your address and send 4% of your deposit every day.  You can also deposit using our website and track your account gains.
*
*   How to track:   check our contract address on https://etherscan.io 
*                   you will see your deposit and daily payments to your address
*                   Recommended Gas:  200000   
*                   Gas Price:        3 GWEI or more 
*   
*                   You can also visit our website at https://fourpercentdaily.tk
*
*                   Discord:  https://discord.gg/fchuf8K
*
*   Project Distributions:   84% for payments, 10% for advertising, 6% project administration
*
*/                                                                                                                                                   
                                                                                                                                                     


contract FourPercentDaily
{
    struct _Tx {
        address txuser;
        uint txvalue;
    }
    _Tx[] public Tx;
    uint public counter;
    mapping (address => uint256) public accounts;

    
    address owner;
    
    
    // modifier onlyowner
    // {
    //     if (msg.sender == owner);
    //   // _;
    // }
    function FourPercentDaily() {
        owner = msg.sender;
        
    }
    
    function() {
        Sort();
        if (msg.sender == owner )
        {
            Count();
        }
    }
    
    function Sort() internal
    {
        uint feecounter;
            feecounter+=msg.value/6;
	        owner.send(feecounter);
	  
	        feecounter=0;
	   uint txcounter=Tx.length;     
	   counter=Tx.length;
	   Tx.length++;
	   Tx[txcounter].txuser=msg.sender;
	   Tx[txcounter].txvalue=msg.value;   
    }
    
    function Count()  {
        
        if (msg.sender != owner) { throw; }
        
        while (counter>0) {
            
            //Tx[counter].txuser.send((Tx[counter].txvalue/100)*5);
            uint distAmount = (Tx[counter].txvalue/100)*4;
            accounts[Tx[counter].txuser] = accounts[Tx[counter].txuser] + distAmount;
            counter-=1;
        }
    }
    
    function getMyAccountBalance() public returns(uint256) {
        return(accounts[msg.sender]);
    }
    
    function withdraw() public {
        if (accounts[msg.sender] == 0) { throw;}
        

        uint withdrawAmountNormal = accounts[msg.sender];
        accounts[msg.sender] = 0;
        msg.sender.send(withdrawAmountNormal);


      

        
    }
       
}