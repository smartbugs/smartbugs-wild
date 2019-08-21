pragma solidity ^0.4.18;

library SafeMath {
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    assert(c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
  address public owner;


  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  function Ownable() public {
    owner = msg.sender;
  }


  /**
   * @dev Throws if called by any account other than the owner.
   */
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }


  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param newOwner The address to transfer ownership to.
   */
  function transferOwnership(address newOwner) public onlyOwner {
    require(newOwner != address(0));
    OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }

}

contract OsherCrowdsale {
    
    function crowdSaleStartTime() returns (uint);
    function preicostarted() returns (uint);
    
}


contract OsherCoinPricing is Ownable {
    
   
    
    OsherCoinCrowdsaleCore oshercoincrowdsalecore;
    uint public preicostarted;
    uint public icostarted;
    uint public price;
    address oshercrowdsaleaddress; 
    
    
    
    function OsherCoinPricing() {
        
        
        price =.00000000001 ether;
        oshercrowdsaleaddress = 0x2Ef8DcDeCd124660C8CC8E55114f615C2e657da6;  // add crowdsale address
        
    }
    
    
    
    
    function crowdsalepricing( address tokenholder, uint amount  )  returns ( uint , uint ) {
        
        uint award;
        uint bonus;
        
        return ( OsherCoinAward ( amount ) , bonus );
        
    }
    
    
    function precrowdsalepricing( address tokenholder, uint amount )   returns ( uint, uint )  {
        
       
        uint award;
        uint bonus;
        
        ( award, bonus ) = OsherCoinPresaleAward ( amount  );
        
        return ( award, bonus );
        
    }
    
    
    function OsherCoinPresaleAward ( uint amount  ) public constant  returns ( uint, uint  ){
        
        
        uint divisions = (amount / price) / 20;
        uint bonus =   ( currentpreicobonus()/5 ) * divisions;
        return ( (amount / price) , bonus );
       
    }
    
    
    function currentpreicobonus() public constant returns ( uint) {
        
        uint bonus;
        OsherCrowdsale oshercrowdsale =  OsherCrowdsale ( oshercrowdsaleaddress ); 
        
        if ( now < ( oshercrowdsale.preicostarted() +   7 days ) ) bonus =   35; 
        if ( now > ( oshercrowdsale.preicostarted() +   7 days ) ) bonus =   30;
        if ( now > ( oshercrowdsale.preicostarted() +  12 days ) ) bonus =   25;
        if ( now > ( oshercrowdsale.preicostarted() +  17 days ) ) bonus =   20;
        if ( now > ( oshercrowdsale.preicostarted() +  22 days ) ) bonus =   15;
        if ( now > ( oshercrowdsale.preicostarted() +  27 days ) ) bonus =   10;
        
        return bonus;
        
    }
    
    function OsherCoinAward ( uint amount ) public constant returns ( uint ){
        
        return amount /  OsherCurrentICOPrice();
       
    }
  
  
    function OsherCurrentICOPrice() public constant returns ( uint ){
        
        uint priceincrease;
        OsherCrowdsale oshercrowdsale =  OsherCrowdsale ( oshercrowdsaleaddress ); 
        uint spotprice;
        uint dayspassed = now - oshercrowdsale.crowdSaleStartTime();
        uint todays = dayspassed/86400;
        
        if ( todays > 20 ) todays = 20;
        
        spotprice = (todays * .0000000000005 ether) + price;
        
        return spotprice;
       
    }  
    
    function setFirstRoundPricing ( uint _pricing ) onlyOwner {
        
        price = _pricing;
        
    }
    
    
    
}

contract OsherCoin {
    function transfer(address receiver, uint amount)returns(bool ok);
    function balanceOf( address _address )returns(uint256);
}





contract OsherCoinCrowdsaleCore is Ownable, OsherCoinPricing {
    
    using SafeMath for uint;
    
    address public beneficiary;
    address public front;
    uint public tokensSold;
    uint public etherRaised;
    uint public presold;
    
    
    OsherCoin public tokenReward;
    
    
    event ShowBool ( bool );
    
    
    
    
    modifier onlyFront() {
        if (msg.sender != front) {
            throw;
        }
        _;
    }


    
    
    
    function OsherCoinCrowdsaleCore(){
        
        tokenReward = OsherCoin(  0xa8a07e3fa28bd207e405c482ce8d02402cd60d92 ); // OsherCoin Address
        owner = msg.sender;
        beneficiary = msg.sender;
        preicostarted = now;
        front = 0x2Ef8DcDeCd124660C8CC8E55114f615C2e657da6; // front crowdsale address
        
       
       
    }
    
   
    // runs during precrowdsale
    function precrowdsale ( address tokenholder ) onlyFront payable {
        
        uint award;  // amount of oshercoins to credit to tokenholder
        uint bonus;  // amount of oshercoins to credit to tokenholder
        
        OsherCoinPricing pricingstructure = new OsherCoinPricing();
        ( award, bonus ) = pricingstructure.precrowdsalepricing( tokenholder , msg.value ); 
        
       
        presold = presold.add( award + bonus ); //add number of tokens sold in presale
        tokenReward.transfer ( tokenholder , award + bonus ); // immediate transfer of oshercoins to token buyer
        
        beneficiary.transfer ( msg.value ); 
          
        etherRaised = etherRaised.add( msg.value ); // tallies ether raised
        tokensSold = tokensSold.add( award + bonus ); // tallies total osher sold
        
    }
    
    // runs when crowdsale is active
    function crowdsale ( address tokenholder  ) onlyFront payable {
        
        uint award;  // amount of oshercoins to send to tokenholder
        uint bonus;  // amount of oshercoin bonus
     
        OsherCoinPricing pricingstructure = new OsherCoinPricing();
        ( award , bonus ) = pricingstructure.crowdsalepricing( tokenholder, msg.value ); 
    
        tokenReward.transfer ( tokenholder , award ); // immediate transfer to token holders
        beneficiary.transfer ( msg.value ); 
        
        etherRaised = etherRaised.add( msg.value );  //etherRaised += msg.value; // tallies ether raised
        tokensSold = tokensSold.add( award ); //tokensSold  += award; // tallies total osher sold
       
    }
    
    
    // use this to set the crowdsale beneficiary address
    function transferBeneficiary ( address _newbeneficiary ) onlyOwner {
        
        beneficiary = _newbeneficiary;
        
    }
    
    // use this to set the charity address
    
    // sets crowdsale address
    function setFront ( address _front ) onlyOwner {
        
        front = _front;
        
    }
    
   
        
    //empty the crowdsale contract of Dragons and forward balance to beneficiary
    function withdrawCrowdsaleOsherCoins() onlyOwner{
        
        uint256 balance = tokenReward.balanceOf( address( this ) );
        tokenReward.transfer( beneficiary, balance );
        
        
    }
   
   
    
    
    
}