/* Orgon.Sale2 */
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


contract OrgonSale2 {
using SafeMath for uint256;
    /* Start OrgonMarket */
    function OrgonSale2 (OrgonToken _orgonToken) public {
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
        currentMarket = orgonToken.balanceOf (address(this));   
        if (currentMarket == 0) revert (); 
        require (orgonToken.transfer (msg.sender, countTokens(msg.value)));
        return true;
    }  
    
    function countTokens (uint256 _value) public view returns (uint256 _tokens){
       
        uint256 toBuy;
        if (_value < weiBound1) {
            toBuy = _value.mul(tokensPerWei);
            _tokens = toBuy;
        }
        else if (_value < weiBound2) {
            toBuy = _value.mul(tokensPerWei);
            _tokens = toBuy.mul(orgonBonus1);
            _tokens = _tokens.div(100);
        }    
        else if (_value < weiBound3) {
            toBuy = _value.mul(tokensPerWei);
            _tokens = toBuy.mul(orgonBonus2);
            _tokens = _tokens.div(100);
        }
        else if (_value < weiBound4) {
            toBuy = _value.mul(tokensPerWei);
            _tokens = toBuy.mul(orgonBonus3);
            _tokens = _tokens.div(100);
        }
        else if (_value < weiBound5) {
            toBuy = _value.mul(tokensPerWei);
            _tokens = toBuy.mul(orgonBonus4);
            _tokens = _tokens.div(100);
        }
        else if (_value < weiBound6) {
            toBuy = _value.mul(tokensPerWei);
            _tokens = toBuy.mul(orgonBonus5);
            _tokens = _tokens.div(100);
        }
        else {
            toBuy = _value.mul(tokensPerWei);
            _tokens = toBuy.mul(orgonBonus6);
            _tokens = _tokens.div(100);
        }
        return (_tokens);
    }  
    
    function countTokensE18 (uint256 _value) public view returns (uint256 _tokens){
        return countTokens(_value.mul(10**18))/(10**18);
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
     
    function setPriceAndBonus(uint256 _newTokensPerWei, uint256 _newWeiBound1, uint256 _newOrgonBonus1, uint256 _newWeiBound2, uint256 _newOrgonBonus2, uint256 _newWeiBound3, uint256 _newOrgonBonus3, uint256 _newWeiBound4, uint256 _newOrgonBonus4, uint256 _newWeiBound5, uint256 _newOrgonBonus5, uint256 _newWeiBound6, uint256 _newOrgonBonus6  ) public {
        require (msg.sender == owner);
        require (_newTokensPerWei > 0);
        require (_newWeiBound1 < _newWeiBound2 && _newWeiBound2 < _newWeiBound3 &&_newWeiBound3 < _newWeiBound4 &&_newWeiBound4 < _newWeiBound5 &&_newWeiBound5 < _newWeiBound6);
        tokensPerWei = _newTokensPerWei;
        weiBound1 = _newWeiBound1;
        weiBound2 = _newWeiBound2;
        weiBound3 = _newWeiBound3;
        weiBound4 = _newWeiBound4;
        weiBound5 = _newWeiBound5;
        weiBound6 = _newWeiBound6;
        orgonBonus1 = _newOrgonBonus1;
        orgonBonus2 = _newOrgonBonus2;
        orgonBonus3 = _newOrgonBonus3;
        orgonBonus4 = _newOrgonBonus4;
        orgonBonus5 = _newOrgonBonus5;
        orgonBonus6 = _newOrgonBonus6;
    }
    
    function setPriceAndBonusETH(uint256 _tokensPerWei, uint256 _newEthBound1, uint256 _newOrgonBonus1, uint256 _newEthBound2, uint256 _newOrgonBonus2, uint256 _newEthBound3, uint256 _newOrgonBonus3, uint256 _newEthBound4, uint256 _newOrgonBonus4, uint256 _newEthBound5, uint256 _newOrgonBonus5, uint256 _newEthBound6, uint256 _newOrgonBonus6  ) public {
        require (msg.sender == owner);
        require (_tokensPerWei > 0);
        require (_newEthBound1 < _newEthBound2 && _newEthBound2 < _newEthBound3 &&_newEthBound3 < _newEthBound4 &&_newEthBound4 < _newEthBound5 &&_newEthBound5 < _newEthBound6);
        tokensPerWei = _tokensPerWei;
        weiBound1 = _newEthBound1.mul(1000000000000000000);
        weiBound2 = _newEthBound2.mul(1000000000000000000);
        weiBound3 = _newEthBound3.mul(1000000000000000000);
        weiBound4 = _newEthBound4.mul(1000000000000000000);
        weiBound5 = _newEthBound5.mul(1000000000000000000);
        weiBound6 = _newEthBound6.mul(1000000000000000000);
        orgonBonus1 = _newOrgonBonus1;
        orgonBonus2 = _newOrgonBonus2;
        orgonBonus3 = _newOrgonBonus3;
        orgonBonus4 = _newOrgonBonus4;
        orgonBonus5 = _newOrgonBonus5;
        orgonBonus6 = _newOrgonBonus6;
    }    
    
    function setPriceAndBonusFinney(uint256 _newTokensPerWei, uint256 _newFinneyBound1, uint256 _newOrgonBonus1, uint256 _newFinneyBound2, uint256 _newOrgonBonus2, uint256 _newFinneyBound3, uint256 _newOrgonBonus3, uint256 _newFinneyBound4, uint256 _newOrgonBonus4, uint256 _newFinneyBound5, uint256 _newOrgonBonus5, uint256 _newFinneyBound6, uint256 _newOrgonBonus6  ) public {
        require (msg.sender == owner);
        require (_newTokensPerWei > 0);
        require (_newFinneyBound1 < _newFinneyBound2 && _newFinneyBound2 < _newFinneyBound3 &&_newFinneyBound3 < _newFinneyBound4 &&_newFinneyBound4 < _newFinneyBound5 &&_newFinneyBound5 < _newFinneyBound6);
        tokensPerWei = _newTokensPerWei;
        weiBound1 = _newFinneyBound1.mul(1000000000000000);
        weiBound2 = _newFinneyBound2.mul(1000000000000000);
        weiBound3 = _newFinneyBound3.mul(1000000000000000);
        weiBound4 = _newFinneyBound4.mul(1000000000000000);
        weiBound5 = _newFinneyBound5.mul(1000000000000000);
        weiBound6 = _newFinneyBound6.mul(1000000000000000);
        orgonBonus1 = _newOrgonBonus1;
        orgonBonus2 = _newOrgonBonus2;
        orgonBonus3 = _newOrgonBonus3;
        orgonBonus4 = _newOrgonBonus4;
        orgonBonus5 = _newOrgonBonus5;
        orgonBonus6 = _newOrgonBonus6;
    } 
    
 /** Set new owner for the smart contract.
 * May only be called by smart contract owner.
 * @param _newOwner address of new owner of the smart contract 
 **/
    function setOwner (address _newOwner) public {
        require (msg.sender == owner);
        require (_newOwner != address(this));
        require (_newOwner != address(0x0));
        
        owner = _newOwner;
}
 
/* *********************************************** */    
    function getCurrentMarket() view public returns (uint256){ return orgonToken.balanceOf(address(this)); } 
    
    function getCurrentMarketE18() view public returns (uint256, uint256){
        uint256 bal;
        bal = orgonToken.balanceOf(address(this));
        return (bal/1000000000000000000, bal%1000000000000000000);
    } 
    
    function getTotalSupply() view public returns (uint256){ return orgonToken.totalSupply(); }
    
    function getTotalSupplyE18() view public returns (uint256){
        return orgonToken.totalSupply()/1000000000000000000;
    }
    
    function getETHbalance() view public returns (uint256, uint256) {
        uint256 bal;
        bal = address(this).balance;
        return (bal/1000000000000000000,bal%1000000000000000000);
    }
    
    function getTokensPerETH() view public returns (uint256){ return tokensPerWei; }
    
    function theOwner() view public returns (address _owner){ return owner; }
   
    function getEthBonus() view public returns (uint256 eth_1Bound, uint256 Bonus1,
                                                uint256 eth_2Bound, uint256 Bonus2,
                                                uint256 eth_3Bound, uint256 Bonus3,
                                                uint256 eth_4Bound, uint256 Bonus4,
                                                uint256 eth_5Bound, uint256 Bonus5,
                                                uint256 eth_6Bound, uint256 Bonus6) {
        eth_1Bound = weiBound1.div(1000000000000000000);
        eth_2Bound = weiBound2.div(1000000000000000000);
        eth_3Bound = weiBound3.div(1000000000000000000);
        eth_4Bound = weiBound4.div(1000000000000000000);
        eth_5Bound = weiBound5.div(1000000000000000000);
        eth_6Bound = weiBound6.div(1000000000000000000);
        return (eth_1Bound, orgonBonus1, eth_2Bound, orgonBonus2, eth_3Bound, orgonBonus3,
                eth_4Bound, orgonBonus4, eth_5Bound, orgonBonus5, eth_6Bound, orgonBonus6);
    }
    
    function getFinneyBonus() view public returns (uint256 finney_1Bound, uint256 Bonus1,
                                                uint256 finney_2Bound, uint256 Bonus2,
                                                uint256 finney_3Bound, uint256 Bonus3,
                                                uint256 finney_4Bound, uint256 Bonus4,
                                                uint256 finney_5Bound, uint256 Bonus5,
                                                uint256 finney_6Bound, uint256 Bonus6) {
        finney_1Bound = weiBound1.div(1000000000000000);
        finney_2Bound = weiBound2.div(1000000000000000);
        finney_3Bound = weiBound3.div(1000000000000000);
        finney_4Bound = weiBound4.div(1000000000000000);
        finney_5Bound = weiBound5.div(1000000000000000);
        finney_6Bound = weiBound6.div(1000000000000000);
        return (finney_1Bound, orgonBonus1, finney_2Bound, orgonBonus2, finney_3Bound, orgonBonus3,
                finney_4Bound, orgonBonus4, finney_5Bound, orgonBonus5, finney_6Bound, orgonBonus6);
    }
   
   function getWeiBonus() view public returns (uint256 wei_1Bound, uint256 Bonus1,
                                                uint256 wei_2Bound, uint256 Bonus2,
                                                uint256 wei_3Bound, uint256 Bonus3,
                                                uint256 wei_4Bound, uint256 Bonus4,
                                                uint256 wei_5Bound, uint256 Bonus5,
                                                uint256 wei_6Bound, uint256 Bonus6) {
        return (weiBound1, orgonBonus1, weiBound2, orgonBonus2, weiBound3, orgonBonus3,
                weiBound4, orgonBonus4, weiBound5, orgonBonus5, weiBound6, orgonBonus6);
    }
   
    
    uint256 private tokensPerWei;
    uint256 private orgonBonus1;
    uint256 private orgonBonus2;
    uint256 private orgonBonus3;
    uint256 private orgonBonus4;
    uint256 private orgonBonus5;
    uint256 private orgonBonus6;
    
    uint256 private weiBound1;
    uint256 private weiBound2;
    uint256 private weiBound3;
    uint256 private weiBound4;
    uint256 private weiBound5;
    uint256 private weiBound6;
    
    /** Owner of the smart contract */
    address private  owner;
    
    /**
    * Orgon Token smart contract.
    */
    OrgonToken private orgonToken;
}