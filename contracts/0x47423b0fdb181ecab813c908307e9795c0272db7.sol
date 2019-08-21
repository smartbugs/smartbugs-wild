pragma solidity ^0.4.18;

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

/**
 * @title ERC20Basic
 * @dev Simpler version of ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/179
 */
contract ERC20Basic {
  uint256 public totalSupply;
  function balanceOf(address who) public constant returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}


/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender) public constant returns (uint256);
  function transferFrom(address from, address to, uint256 value) public returns (bool);
  function approve(address spender, uint256 value) public returns (bool);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}


/**
 * @title Basic token
 * @dev Basic version of StandardToken, with no allowances.
 */
contract BasicToken is ERC20Basic {
  using SafeMath for uint256;

  mapping(address => uint256) balances;

  /**
  * @dev transfer token for a specified address
  * @param _to The address to transfer to.
  * @param _value The amount to be transferred.
  */
  function transfer(address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));
    require(_value <= balances[msg.sender]);

    // SafeMath.sub will throw if there is not enough balance.
    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);
    Transfer(msg.sender, _to, _value);
    return true;
  }

  /**
  * @dev Gets the balance of the specified address.
  * @param _owner The address to query the the balance of.
  * @return An uint256 representing the amount owned by the passed address.
  */
  function balanceOf(address _owner) public constant returns (uint256) {
    return balances[_owner];
  }

}


/**
 * @title Standard ERC20 token
 *
 * @dev Implementation of the basic standard token.
 * @dev https://github.com/ethereum/EIPs/issues/20
 * @dev Based on code by FirstBlood: https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol
 */
contract StandardToken is ERC20, BasicToken {
    
  mapping (address => mapping (address => uint256)) internal allowed;

  /**
   * @dev Transfer tokens from one address to another
   * @param _from address The address which you want to send tokens from
   * @param _to address The address which you want to transfer to
   * @param _value uint256 the amount of tokens to be transferred
   */
  function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));
    require(_value <= balances[_from]);
    require(_value <= allowed[_from][msg.sender]);

    balances[_from] = balances[_from].sub(_value);
    balances[_to] = balances[_to].add(_value);
    allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
    Transfer(_from, _to, _value);
    return true;
  }

  /**
   * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.
   *
   * Beware that changing an allowance with this method brings the risk that someone may use both the old
   * and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this
   * race condition is to first reduce the spender's allowance to 0 and set the desired value afterwards:
   * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
   * @param _spender The address which will spend the funds.
   * @param _value The amount of tokens to be spent.
   */
  function approve(address _spender, uint256 _value) public returns (bool) {
    allowed[msg.sender][_spender] = _value;
    Approval(msg.sender, _spender, _value);
    return true;
  }

  /**
   * @dev Function to check the amount of tokens that an owner allowed to a spender.
   * @param _owner address The address which owns the funds.
   * @param _spender address The address which will spend the funds.
   * @return A uint256 specifying the amount of tokens still available for the spender.
   */
  function allowance(address _owner, address _spender) public constant returns (uint256 remaining) {
    return allowed[_owner][_spender];
  }

  /**
   * approve should be called when allowed[_spender] == 0. To increment
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   */
  function increaseApproval (address _spender, uint _addedValue) public returns (bool success) {
    allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
    Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

  function decreaseApproval (address _spender, uint _subtractedValue) public returns (bool success) {
    uint oldValue = allowed[msg.sender][_spender];
    if (_subtractedValue > oldValue) {
      allowed[msg.sender][_spender] = 0;
    } else {
      allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
    }
    Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

}


/*
 * Ownable
 * Base contract with an owner.
 * Provides onlyOwner modifier, which prevents function from running if it is called by anyone other than the owner.
 */
contract Ownable {
    address public owner;

    function Ownable() public {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        if (msg.sender != owner) {
            revert();
        }
        _;
    }

    function transferOwnership(address newOwner) internal onlyOwner {
        if (newOwner != address(0)) {
            owner = newOwner;
        }
    }
}


/*
  Copyright 2017 ZeroEx Intl.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/
/**
 * @title Unlimited Allowance Token
 * @dev Unlimited allowance for exchange transfers. Modfied the base zeroEX code with latest compile features
 * @author Dinesh
 */
contract UnlimitedAllowanceToken is StandardToken {
    
    //  MAX_UINT represents an unlimited allowance
    uint256 constant MAX_UINT = 2**256 - 1;
    
    /**
     * @dev ERC20 transferFrom, modified such that an allowance of MAX_UINT represents an unlimited allowance.
     * @param _from Address to transfer from
     * @param _to Address to transfer to
     * @param _value Amount to transfer
     * @return Success of transfer
     */ 
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
        uint allowance = allowed[_from][msg.sender];
        require(balances[_from] >= _value);
        require(allowance >= _value);
        require(balances[_to].add(_value) >= balances[_to]);
        
        balances[_to] = balances[_to].add(_value);
        balances[_from] = balances[_from].sub(_value);
        if (allowance < MAX_UINT) {
            allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
        }  
        Transfer(_from, _to, _value);
        
        return true;
    }
}

/**
 * @title Tokenized Ether
 * @dev ERC20 tokenization for Ether to allow exchange transfer and smoother handling of ether.
 *      Modified the base zerox contract to use latest language features and made it more secure
 *      and fault tolerant
 * @author Dinesh
 */
contract EtherToken is UnlimitedAllowanceToken, Ownable{
    using SafeMath for uint256; 
    
    string constant public name = "Ether Token";
    string constant public symbol = "WXETH";
    uint256 constant public decimals = 18; 
    
    // triggered when the total supply is increased
    event Issuance(uint256 _amount);
    
    // triggered when the total supply is decreased
    event Destruction(uint256 _amount);
    
    // in case of emergency, block all transactions
    bool public enabled;
    
    // In case emergencies, all the funds will be moved to a safety Wallet. Normally Owner of the contract
    address public safetyWallet; 
    
    /** 
     * @dev constructor
     */
    function EtherToken() public {
        enabled = true;
        safetyWallet = msg.sender;
    }
    
    /**
     * @dev function to enable/disable contract operations
     * @param _disableTx tell whethere the tx needs to be blocked or allowed
     */
    function blockTx(bool _disableTx) public onlyOwner { 
        enabled = !_disableTx;
    }
    
    /**
     * @dev fucntion only executes if there is an emergency and only contract owner can do it 
     *      CAUTION: This moves all the funds in the contract to owner's Wallet and to be called
     *      most extreme cases only
     */
    function moveToSafetyWallet() public onlyOwner {
        require(!enabled); 
        require(totalSupply > 0);
        require(safetyWallet != 0x0);
        
        //Empty Total Supply
        uint256 _amount = totalSupply;
        totalSupply = totalSupply.sub(totalSupply); 
        
        //Fire the events
        Transfer(safetyWallet, this, totalSupply);
        Destruction(totalSupply);
        
        // send the amount to the target account
        safetyWallet.transfer(_amount);  
    }
    
    /** 
     * @dev fallback function can be used to get ether tokens foe ether
     */
    function () public payable {
        require(enabled);
        deposit(msg.sender);
    }
    
    /**
     * @dev function Buys tokens with Ether, exchanging them 1:1. Simliar to a Deposit function
     * @param beneficiary is the senders account
     */
    function deposit(address beneficiary) public payable {
        require(enabled);
        require(beneficiary != 0x0);  
        require(msg.value != 0);  
        
        balances[beneficiary] = balances[beneficiary].add(msg.value);
        totalSupply = totalSupply.add( msg.value);
        
        //Fire th events
        Issuance(msg.value);
        Transfer(this, beneficiary, msg.value);
    }
    
    /**
     * @dev withdraw ether from the account
     * @param _amount  amount of ether to withdraw
     */
    function withdraw(uint256 _amount) public {
        require(enabled);
        withdrawTo(msg.sender, _amount);
    }
    
    /**
     * @dev withdraw ether from the account to a target account
     * @param _to account to receive the ether
     * @param _amount of ether to withdraw
     */
    function withdrawTo(address _to, uint _amount) public { 
        require(enabled);
        require(_to != 0x0);
        require(_amount != 0);  
        require(_amount <= balances[_to]); 
        require(this != _to);
        
        balances[_to] = balances[_to].sub(_amount);
        totalSupply = totalSupply.sub(_amount); 
        
        //Fire the events
        Transfer(msg.sender, this, _amount);
        Destruction(_amount);
        
         // send the amount to the target account
        _to.transfer(_amount);  
    }
}