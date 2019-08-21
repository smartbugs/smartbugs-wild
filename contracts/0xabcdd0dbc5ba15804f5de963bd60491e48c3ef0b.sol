pragma solidity ^0.4.7;
contract Investment{
    /** the owner of the contract, C4C */
    address owner;
    /** List of all investors. */
    address[] public investors;
    /** The investors's balances. */
    mapping(address => uint) public balances;
    /** The total amount raised. */
    uint public amountRaised;
    /** The index of the investor currentlz being paid out. */
    uint public investorIndex;
    /** The return rates (factors) per interval (in raised Ether). */
    uint[] public rates;
    uint[] public limits;
    /** indicates if ne investments are accepted */
    bool public closed;
    /** Notifies listeners that a new investment was undertaken */
    event NewInvestment(address investor, uint amount);
    /** Notifies listeners that ether was returned to the investors */
    event Returned(uint amount);

    
    function Investment(){
        owner = msg.sender;
        limits= [0, 1000000000000000000000, 4000000000000000000000, 10000000000000000000000];
        rates= [15, 14, 13,12];//1 decimal
    }
    
    /**
     * Adds new investors to the list and calculates the balance according to the current rate.
     * Minimum value: 1 ETH.
     * */
     function invest() payable{
        if (closed) throw;
        if (msg.value < 1 ether) throw;
        if (balances[msg.sender]==0){//new investor
            investors.push(msg.sender);
        }
        balances[msg.sender] += calcReturnValue(msg.value, amountRaised); 
        amountRaised += msg.value;
        NewInvestment(msg.sender, msg.value);
     }
     
     /**
      * call invest() whenever ether is sent to the contract
      * */
     function() payable{
         invest();
     }
     
     /**
      * calcultes the return value depending on the amount raised, limits and rates
      * @param value : the investment value
      * @param amRa : the amount raised
      * */
     function calcReturnValue(uint value, uint amRa) internal returns (uint){
         if(amRa >= limits[limits.length-1]) return value/10*rates[limits.length-1];
         for(uint i = limits.length-2; i >= 0; i--){
             if(amRa>=limits[i]){
                uint newAmountRaised = amRa+value;
                if(newAmountRaised>limits[i+1]){
                    uint remainingVal=newAmountRaised-limits[i+1];
                    return (value-remainingVal)/10 * rates[i] + calcReturnValue(remainingVal, limits[i+1]);
                }  
                else
                    return value/10*rates[i];
             }
         }
     }
     
     /**
      * Enables the owner to withdraw the funds
      * */
     function withdraw(){
         if(msg.sender==owner){
             msg.sender.send(this.balance);
         }
     }
     
     /**
      * called to pay the investor
      * */
     function returnInvestment() payable{
        returnInvestmentRecursive(msg.value);
        Returned(msg.value);
     }
     
     /**
      * sends the given value to the next investor(s) in the list
      * */
     function returnInvestmentRecursive(uint value) internal{
        if (investorIndex>=investors.length || value==0) return;
        else if(value<=balances[investors[investorIndex]]){
            balances[investors[investorIndex]]-=value;
            if(!investors[investorIndex].send(value)) throw; 
        } 
        else if(balances[investors[investorIndex]]>0){
            uint val = balances[investors[investorIndex]];
            balances[investors[investorIndex]]=0;
            if(!investors[investorIndex].send(val)) throw;
            investorIndex++;
            returnInvestmentRecursive(value-val);
        } 
        else{
            investorIndex++;
            returnInvestmentRecursive(value);
        }
     }
     
     function getNumInvestors() constant returns(uint){
         return investors.length;
     }
     
     /** do not accept any more investments */
     function close(){
         if(msg.sender==owner)
            closed=true;
     }
     
     /** allow investments */
     function open(){
         if(msg.sender==owner)
            closed=false;
     }
}