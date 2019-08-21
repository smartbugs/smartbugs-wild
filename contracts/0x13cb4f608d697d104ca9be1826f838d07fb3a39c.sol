pragma solidity ^0.4.11;

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a * b;
    assert(a == 0 || c / a == b);
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
  function transferOwnership(address newOwner) onlyOwner public {
    require(newOwner != address(0));
    OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }

}

/**
 * @title ERC20Basic
 * @dev Simpler version of ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/179
 */
contract ERC20Basic {
  uint256 public totalSupply;
  function balanceOf(address who) constant public returns (uint256);
  function transfer(address to, uint256 value) internal returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}

/**
 * @title Basic token
 * @dev Basic version of StandardToken, with no allowances.
 */
contract BasicToken is ERC20Basic {
  using SafeMath for uint256;

  mapping(address => uint256) tokenBalances;

  /**
  * @dev transfer token for a specified address
  * @param _to The address to transfer to.
  * @param _value The amount to be transferred.
  */
  function transfer(address _to, uint256 _value) internal returns (bool) {
    //TRANSFER Functionality has been disabled as we wanted to make the token non-tradable
    //and we are nice people so we don't want anyone to not get their payout :)
    return false;
  }

  /**
  * @dev Gets the balance of the specified address.
  * @param _owner The address to query the the balance of.
  * @return An uint256 representing the amount owned by the passed address.
  */
  function balanceOf(address _owner) constant public returns (uint256 balance) {
    return tokenBalances[_owner];
  }

}
contract HareemMinePoolToken is BasicToken, Ownable {

   using SafeMath for uint256;
   string public constant name = "HareemMinePool";
   string public constant symbol = "HMP";
   uint256 public constant decimals = 18;

   uint256 constant INITIAL_SUPPLY = 1000 * (10 ** uint256(decimals));
   uint256 public sellPrice = 2;  
   uint256 public buyPrice = 1; 
  
   string public constant COLLATERAL_HELD = "1000 ETH";
   uint payout_worth = 0;
   
   event Debug(string message, uint256 num);
   
   mapping(address => uint256) amountLeftToBePaid;
   mapping(address => uint256) partialAmtToBePaid;
   
   address[] listAddr;
   
   //Client addresses
   address ethStore = 0x66Ef84EE378B07012FE44Df83b64Ea2Ae35fD09b;   
   address exchange = 0x093af86909F7E2135aD764e9cB384Ed7311799d3;
   
   uint perTokenPayout = 0;
   uint tokenToTakeBack = 0;
   
   event addr(string message, address sender);
   event logString(string message);
   
   // fallback function can be used to buy tokens
    function () public payable {
    buy(msg.sender);
    }
  
    /**
    * @dev Contructor that gives msg.sender all of existing tokens.
    */
    function HareemMinePoolToken() public {
    owner = ethStore;
    totalSupply = INITIAL_SUPPLY;
    tokenBalances[owner] = INITIAL_SUPPLY;
    }
    
    function transferOwnership(address newOwner) public onlyOwner {
        transferOwnership(newOwner);
    }

    function setPrices(uint256 newSellPrice, uint256 newBuyPrice) public onlyOwner {
        sellPrice = newSellPrice;
        buyPrice = newBuyPrice;
    }
  
    function payoutWorth(address beneficiary) constant public returns (uint amount) {
        amount = tokenBalances[beneficiary].mul(sellPrice);
    }
    
    function tokensLeft() public view returns (uint amount) {
        amount = tokenBalances[owner];
    }
    
    function payoutLeft() internal constant returns (uint amount) {
        for (uint i=0;i<listAddr.length;i++)
        {
            amount = amount + amountLeftToBePaid[listAddr[i]];
        }
        return amount;
    }
    function doPayout() payable public onlyOwner{
      uint payLeft = payoutLeft();
      uint cashBack = msg.value;
      require (payLeft>0 && cashBack <=payLeft);
      uint soldTokens = totalSupply.sub(tokenBalances[owner]);
      cashBack = cashBack.mul(10**18);
      perTokenPayout =cashBack.div(soldTokens);
      tokenToTakeBack = perTokenPayout.div(sellPrice);
      makePayments();
    }
    
    function makePayments() internal {
        uint exchangeAmount;
        uint customerAmt;
        for (uint i=0;i<listAddr.length;i++)
        {
            uint payAmt = amountLeftToBePaid[listAddr[i]];
            if (payAmt >0)
            {
                uint tokensHeld = payAmt.div(sellPrice);
                if (tokensHeld >0)
                {
                    uint sendMoney = tokensHeld.mul(perTokenPayout);
                    sendMoney = sendMoney.div(10**decimals);
                    uint takeBackTokens = tokenToTakeBack.mul(tokensHeld);
                    takeBackTokens = takeBackTokens.div(10**decimals);
                    (exchangeAmount,customerAmt) = getExchangeAndEthStoreAmount(sendMoney); 
                    exchange.transfer(exchangeAmount);
                    listAddr[i].transfer(customerAmt);
                    amountLeftToBePaid[listAddr[i]] = amountLeftToBePaid[listAddr[i]].sub(sendMoney);
                    tokenBalances[listAddr[i]] = tokenBalances[listAddr[i]].sub(takeBackTokens);
                    tokenBalances[owner] = tokenBalances[owner].add(takeBackTokens);
                    Transfer(listAddr[i],owner, takeBackTokens); 
                    takeBackTokens = takeBackTokens.div(10**decimals);
                }
            }
        }
    }
    
    function buy(address beneficiary) payable public returns (uint amount) {
        require (msg.value >= 10 ** decimals);   //  see this
        uint exchangeAmount;
        uint ethStoreAmt;
        (exchangeAmount,ethStoreAmt) = getExchangeAndEthStoreAmount(msg.value); 
        ethStore.transfer(ethStoreAmt);    
        exchange.transfer(exchangeAmount);
        uint tempBuyPrice = buyPrice.mul(10**decimals);
        amount = msg.value.div(tempBuyPrice);                    // calculates the amount
        amount = amount.mul(10**decimals);
        require(tokenBalances[owner] >= amount);               // checks if it has enough to sell
        tokenBalances[beneficiary] = tokenBalances[beneficiary].add(amount);                  // adds the amount to buyer's balance
        tokenBalances[owner] = tokenBalances[owner].sub(amount);                        // subtracts amount from seller's balance
        amountLeftToBePaid[beneficiary] = amount.mul(sellPrice);   //input how much has to be paid out to the customer later on
        Transfer(owner, beneficiary, amount);
        listAddr.push(beneficiary);
        return amount;                                    // ends function and returns
    }
   
   function getExchangeAndEthStoreAmount(uint value) internal pure returns (uint exchangeAmt, uint ethStoreAmt) {
       exchangeAmt = value.div(100);    //since 1% means divide by 100
       ethStoreAmt = value - exchangeAmt;   //the rest would be eth store amount
   }
}