pragma solidity >=0.4.22 <0.6.0;

interface token  
{
    function transfer(address receiver, uint amount) external;
}

contract Levblockchain_LVE_Private_Sale_Limited_Offer
{
    address public Levblockchain;
    uint public ether_raised;
    uint public cost_LVE;
    token public Levblockchain_token;

    mapping(address => uint256) public balanceOf;
    
    bool ether_raised_success = false;
     bool private_sale_off = false;
    

    event value_Transfer(address investor, uint amount, bool isContribution);
    event FundTransfer(address Levblockchain, uint ether_raised,bool success);
    event tokenTransfer(address Levblockchain,uint amount,bool success);
    
    constructor(
    ) 
   
    public
    { 
    Levblockchain = 0x555716FECaa29Ba9ef58880a963E44f6a257747C;
    cost_LVE = 1112 ;
    Levblockchain_token = token(0xA93F28cca763E766f96D008f815adaAb16A8E38b);
    }
    
 function () payable external 
 {
        require(!private_sale_off);
        uint amount = msg.value;
        balanceOf[msg.sender] += amount;
        ether_raised += amount;
        Levblockchain_token.transfer(msg.sender, amount * cost_LVE);
        
       emit value_Transfer(msg.sender, amount, true);
    }
    
     modifier ifsuccessful ()
     
        
        { require (msg.sender == Levblockchain); _;
             ether_raised_success = true;
            private_sale_off = true;
        }
      

     function draw() public  ifsuccessful {
           if (ether_raised_success && Levblockchain == msg.sender) {
             if (msg.sender.send(ether_raised)) {
               
               emit FundTransfer(Levblockchain, ether_raised, true);}}}
              
               function draw(uint amount ) public ifsuccessful {
                     if (ether_raised_success && Levblockchain == msg.sender){
                        Levblockchain_token.transfer(msg.sender,amount);
                    
                       emit tokenTransfer(Levblockchain, amount, true);
                         
                     }
                   
               }
}