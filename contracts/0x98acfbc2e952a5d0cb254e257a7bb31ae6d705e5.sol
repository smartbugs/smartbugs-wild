/* Orgon.Sale */
pragma solidity ^0.4.21; //v8 
library SafeMath {
 
  /**
   * Add two uint256 values, throw in case of overflow.
   * @param x first value to add
   * @param y second value to add
   * @return x + y
   */
  function add (uint256 x, uint256 y) internal pure returns (uint256 z) {
    z = x + y;
    require(z >= x);
    return z;
  }

  /**
   * Subtract one uint256 value from another, throw in case of underflow.
   * @param x value to subtract from
   * @param y value to subtract
   * @return x - y
   */
  function sub (uint256 x, uint256 y) internal pure returns (uint256 z) {
    require (x >= y);
    z = x - y;
    return z;
  }

/**
  * @dev Multiplies two numbers, reverts on overflow.
  */
    function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
   
    if (a == 0) return 0;
    c = a * b;
    require(c / a == b);
    return c;
  }
  
   /**
  * @dev Integer division of two numbers truncating the quotient, reverts on division by zero.
  */
  function div(uint256 a, uint256 b) internal pure returns (uint256 c) {
    require(b > 0); // Solidity only automatically asserts when dividing by 0
    c = a / b;
    return c;
  }
}    
    
contract OrgonToken {

  /**
   * Get total number of tokens in circulation.
   *
   * @return total number of tokens in circulation
   */
  function totalSupply () public view returns (uint256 supply);

  /**
   * Get number of tokens currently belonging to given owner.
   *
   * @param _owner address to get number of tokens currently belonging to the
   *        owner of
   * @return number of tokens currently belonging to the owner of given address
   */
  function balanceOf (address _owner) public view returns (uint256 balance);
  
  function theOwner () public view returns (address);

  /**
   * Transfer given number of tokens from message sender to given recipient.
   *
   * @param _to address to transfer tokens to the owner of
   * @param _value number of tokens to transfer to the owner of given address
   * @return true if tokens were transferred successfully, false otherwise
   */

 /**
   * Transfer given number of tokens from message sender to given recipient.
   *
   * @param _to address to transfer tokens to the owner of
   * @param _value number of tokens to transfer to the owner of given address
   * @return true if tokens were transferred successfully, false otherwise
   */
  function transfer (address _to, uint256 _value)
  public returns (bool success);
  
  /**
   * Transfer given number of tokens from given owner to given recipient.
   *
   * @param _from address to transfer tokens from the owner of
   * @param _to address to transfer tokens to the owner of
   * @param _value number of tokens to transfer from given owner to given
   *        recipient
   * @return true if tokens were transferred successfully, false otherwise
   */
  function transferFrom (address _from, address _to, uint256 _value)
  public returns (bool success);

  /**
   * Allow given spender to transfer given number of tokens from message sender.
   *
   * @param _spender address to allow the owner of to transfer tokens from
   *        message sender
   * @param _value number of tokens to allow to transfer
   * @return true if token transfer was successfully approved, false otherwise
   */
  function approve (address _spender, uint256 _value)
  public returns (bool success);

  /**
   * Tell how many tokens given spender is currently allowed to transfer from
   * given owner.
   *
   * @param _owner address to get number of tokens allowed to be transferred
   *        from the owner of
   * @param _spender address to get number of tokens allowed to be transferred
   *        by the owner of
   * @return number of tokens given spender is currently allowed to transfer
   *         from given owner
   */
  function allowance (address _owner, address _spender)
  public view returns (uint256 remaining);

/* Owner of the smart contract */
//address public owner;

  /**
   * Logged when tokens were transferred from one owner to another.
   *
   * @param _from address of the owner, tokens were transferred from
   * @param _to address of the owner, tokens were transferred to
   * @param _value number of tokens transferred
   */
  event Transfer (address indexed _from, address indexed _to, uint256 _value);

  /**
   * Logged when owner approved his tokens to be transferred by some spender.
   *
   * @param _owner owner who approved his tokens to be transferred
   * @param _spender spender who were allowed to transfer the tokens belonging
   *        to the owner
   * @param _value number of tokens belonging to the owner, approved to be
   *        transferred by the spender
   */
  event Approval (
    address indexed _owner, address indexed _spender, uint256 _value);
}


contract OrgonSale {
using SafeMath for uint256;
    /* Start OrgonMarket */
    function OrgonSale (OrgonToken _orgonToken) public {
        orgonToken = _orgonToken;
        owner = msg.sender;
    }
    
    /* Recive ETH */
    function () public payable {
        require (msg.data.length == 0);
        buyTokens ();
    }
    
    function buyTokens () public payable returns (bool success){
        require (msg.value > 0);
        
        uint256 currentMarket;
        currentMarket = orgonToken.balanceOf (this);   
        if (currentMarket == 0) revert (); 
        
        uint256 toBuy;
        if (msg.value < ethBound1) {
            toBuy = msg.value.mul(price);
            require (orgonToken.transfer (msg.sender, toBuy));
            
        }
        else if (msg.value < ethBound2) {
            toBuy = msg.value.mul(price1);
            require (orgonToken.transfer (msg.sender, toBuy));
        }    
        else if (msg.value < ethBound3) {
            toBuy = msg.value.mul(price2);
            require (orgonToken.transfer (msg.sender, toBuy));
        }    
        else {
            toBuy = msg.value.mul(price3);
            require (orgonToken.transfer (msg.sender, toBuy));
        }  
        return true;
    }  
    
    function countTokens (uint256 _value) public view returns (uint256 tokens, uint256 _currentMarket){
        require (_value > 0);
        
        uint256 currentMarket;
        currentMarket = orgonToken.balanceOf (this);   
        if (currentMarket == 0) revert (); 
        
        uint256 toBuy;
        if (_value < ethBound1) {
            toBuy = _value.mul(price);
            return (toBuy,currentMarket);
        }
        else if (_value < ethBound2) {
            toBuy = _value.mul(price1);
            return (toBuy,currentMarket);
        }    
        else if (_value < ethBound3) {
            toBuy = _value.mul(price2);
           return (toBuy,currentMarket);
        }    
        else {
            toBuy = _value.mul(price3);
            return (toBuy,currentMarket);
        }  
        return (0,currentMarket);
    }  
    
    
    function sendTokens (address _to, uint256 _amount) public returns (bool success){
        
        require (msg.sender == owner);
        require (_to != address(this));
        require (_amount > 0);
        require (orgonToken.transfer (_to, _amount));
        return true;
        
    }
    
    function sendETH (address _to, uint256 _amount) public returns (bool success){
        
        require (msg.sender == owner);
        require (_to != address(this));
        require (_amount > 0);
        _to.transfer (_amount);
        return true;
        
    }
     
    function setPrice(uint256 _newPrice) public {
        require (msg.sender == owner);
        require (_newPrice > 0);
        price = _newPrice;
    }
    function setPrice1(uint256 _newPrice, uint256 _bound1) public {
        require (msg.sender == owner);
        require (_newPrice > 0 && _newPrice > price);
        price1 = _newPrice;
        bound1 = _bound1;
        ethBound1 = bound1.div(price);
    }
     function setPrice2(uint256 _newPrice, uint256 _bound2) public {
        require (msg.sender == owner);
        require (_newPrice > 0 && _newPrice > price1 && _bound2 > bound1);
        price2 = _newPrice;
        bound2 = _bound2;
        ethBound2 = bound2.div(price1);
    }
     function setPrice3(uint256 _newPrice, uint256 _bound3) public {
        require (msg.sender == owner);
        require (_newPrice > 0 && _newPrice > price2 && _bound3 > bound2);
        price3 = _newPrice;
        bound3 = _bound3;
        ethBound3 = bound3.div(price2);
    }
    
    /** Set new owner for the smart contract.
 * May only be called by smart contract owner.
 * @param _newOwner address of new owner of the smart contract */
 
/* *********************************************** */
function setOwner (address _newOwner) public {
 
    require (msg.sender == owner);
    require (_newOwner != address(this));
    require (_newOwner != address(0x0));
    
    owner = _newOwner;
    
}
 
 
/* *********************************************** */    
    function getPrice() view public returns (uint256 _price){ return price; }
    function getPrice1() view public returns (uint256 _price1){ return price1; }
    function getPrice2() view public returns (uint256 _price2){ return price2; }
    function getPrice3() view public returns (uint256 _price3){ return price3; }
    
    function getBound1() view public returns (uint256 _bound1){ return bound1; }
    function getBound2() view public returns (uint256 _bound2){ return bound2; }
    function getBound3() view public returns (uint256 _bound3){ return bound3; }
    
    function getEthBound1() view public returns (uint256 _bound1){ return ethBound1; }
    function getEthBound2() view public returns (uint256 _bound2){ return ethBound2; }
    function getEthBound3() view public returns (uint256 _bound3){ return ethBound3; }
    
    function theOwner() view public returns (address _owner){ return owner; }
    
    /** Total number of tokens in circulation */
    uint256 private price;
    uint256 private price1;
    uint256 private price2;
    uint256 private price3;
    
    uint256 private bound1;
    uint256 private bound2;
    uint256 private bound3;
    
    uint256 private ethBound1;
    uint256 private ethBound2;
    uint256 private ethBound3;
    
    /** Owner of the smart contract */
    address private  owner;
    
    /**
    * Orgon Token smart contract.
    */
    OrgonToken internal orgonToken;
}