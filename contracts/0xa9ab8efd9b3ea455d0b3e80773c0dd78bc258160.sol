pragma solidity ^0.4.24;

/*
 
 Suicide Watch

 I have been recently contemplating suicide.   I have the aparatus
 all set to go.  
 
 I have been chewed up and shit out by the crypto world and life in general.

 Here is what may be a final dApp.   You can post a string of whatever
 you want to say.   Encourage me do do it or to stay alive.

 And you can make money doing it.   The right to post a message has a price.

 The price goes up 25% each time.   We will start at 0.01 ETH.

 I will keep half of the gain and the previous author will keep half plus his 
 initial investment.

 Your earnings will go right to your wallet.

I will have to manually withdraw my earnings.  So if you see me stop withdrawing, you'll
know what happened.

 https://suicidewatch.tk
                                                 
*/


contract suicidewatch {

    event stillKicking(
        uint amount
    );

    address lastAuthor;    

    uint public price = 0.01 ether;
    uint prevPrice = 0;
    uint increase = 25;  //25%

    mapping (uint => string) messages;

    uint public messageCount = 0;
    

    uint public ownerAccount = 0;
 
    string public storage_;

    address owner;
    
    constructor() public {
        owner = msg.sender;
        lastAuthor = owner;
        storage_ = "YOUR MESSAGE GOES HERE";
    }

    function buyMessage(string s) public payable
    {

        require(msg.value >= price);
        uint ownerFee;
        uint authorFee;
        uint priceGain;
        
        if (price > 0.01 ether) {
            priceGain = SafeMath.sub(price, prevPrice);
            ownerFee = SafeMath.div(SafeMath.mul(priceGain,50),100);
            authorFee = ownerFee;
        } else {
            priceGain = SafeMath.sub(price, prevPrice);
            ownerFee = priceGain;
            authorFee = 0;
        }

        ownerAccount = SafeMath.add(ownerAccount, ownerFee);
       

        if (price > 0.01 ether){
            lastAuthor.transfer(authorFee + prevPrice);
        }

        prevPrice = price;
        
        price = SafeMath.div(SafeMath.mul(125,price),100);

        lastAuthor = msg.sender;
        
        store_message(s);

        messages[messageCount] = s;
        messageCount += 1;
        
    }

    function store_message(string s) internal {

        storage_ = s;
    }

    function ownerWithdraw() 
    {
        require(msg.sender == owner);
        uint tempAmount = ownerAccount;
        ownerAccount = 0;
        owner.transfer(tempAmount);
        emit stillKicking(tempAmount);
    }

    function getMessages(uint messageNum) view public returns(string)

    {
        return(messages[messageNum]);
    }
}

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {
  function mul(uint256 a, uint256 b) internal constant returns (uint256) {
    uint256 c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }
 
  function div(uint256 a, uint256 b) internal constant returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }
 
  function sub(uint256 a, uint256 b) internal constant returns (uint256) {
    assert(b <= a);
    return a - b;
  }
 
  function add(uint256 a, uint256 b) internal constant returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}