pragma solidity ^0.4.24;
// produced by the Solididy File Flattener (c) David Appleton 2018
// contact : dave@akomba.com
// released under Apache 2.0 licence
// input  E:\Source\Mozo-NG\smart-contracts\mozo\contracts\MozoXToken.sol
// flattened :  Tuesday, 06-Nov-18 08:44:30 UTC
contract ERC20Basic {
  function totalSupply() public view returns (uint256);
  function balanceOf(address who) public view returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}

library SafeMath {

  /**
  * @dev Multiplies two numbers, throws on overflow.
  */
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    assert(c / a == b);
    return c;
  }

  /**
  * @dev Integer division of two numbers, truncating the quotient.
  */
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  /**
  * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
  */
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  /**
  * @dev Adds two numbers, throws on overflow.
  */
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}

contract Operationable {
    /**
     * @dev Get owner
     */
	function getOwner() public view returns(address);
	
    /**
     * @dev Get ERC20 tokens
     */
	function getERC20() public view returns(OwnerStandardERC20);
	/*
	 * @dev check whether is operation wallet
	*/
	function isOperationWallet(address _wallet) public view returns(bool);
}

contract Owner {
    /**
    * @dev Get smart contract's owner
    * @return The owner of the smart contract
    */
    function owner() public view returns (address);
    
    //check address is a valid owner (owner or coOwner)
    function isValidOwner(address _address) public view returns(bool);

}

contract BasicToken is ERC20Basic {
  using SafeMath for uint256;

  mapping(address => uint256) balances;

  uint256 totalSupply_;

  /**
  * @dev total number of tokens in existence
  */
  function totalSupply() public view returns (uint256) {
    return totalSupply_;
  }

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
    emit Transfer(msg.sender, _to, _value);
    return true;
  }

  /**
  * @dev Gets the balance of the specified address.
  * @param _owner The address to query the the balance of.
  * @return An uint256 representing the amount owned by the passed address.
  */
  function balanceOf(address _owner) public view returns (uint256 balance) {
    return balances[_owner];
  }

}

contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender) public view returns (uint256);
  function transferFrom(address from, address to, uint256 value) public returns (bool);
  function approve(address spender, uint256 value) public returns (bool);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract OwnerERC20 is ERC20Basic, Owner {
}

contract ERC20Exchangable is Operationable{
    //Buy event
    // _from Bought address
    // _to Received address
    // _value Number of tokens
	event Buy(address indexed _from, address indexed _to, uint _value);

    //Sold event
    // _operation Operational Wallet
    // _hash Previous transaction hash of initial blockchain
    // _from Bought address
    // _to Received address
    // _value Number of tokens
    // _fee Fee
	event Sold(address indexed _operation, bytes32 _hash, address indexed _from, address indexed _to, uint _value, uint _fee);
	
    /**
     * @notice This method called by ERC20 smart contract
     * @dev Buy ERC20 tokens in other blockchain
     * @param _from Bought address
     * @param _to The address in other blockchain to transfer tokens to.
     * @param _value Number of tokens
     */
	function autoBuyERC20(address _from, address _to, uint _value) public;
    
    /**
     * @dev called by Bridge or operational wallet (multisig or none) when a bought event occurs,it will transfer ERC20 tokens to receiver address
     * @param _hash Transaction hash in other blockchain
     * @param _from bought address 
     * @param _to The received address 
     * @param _value Number of tokens
     */
    function sold(bytes32 _hash, address _from, address _to, uint _value) public returns(bool);

    /**
     * @dev called by Bridge when a bought event occurs, it will transfer ERC20 tokens to receiver address
     * @param _hash Transaction hash in other blockchain
     * @param _from bought address 
     * @param _to The received address 
     * @param _value Number of tokens
     */
    function soldWithFee(bytes32 _hash, address _from, address _to, uint _value) public returns(bool);
}
contract OwnerStandardERC20 is ERC20, Owner {
}

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
    emit Transfer(_from, _to, _value);
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
    emit Approval(msg.sender, _spender, _value);
    return true;
  }

  /**
   * @dev Function to check the amount of tokens that an owner allowed to a spender.
   * @param _owner address The address which owns the funds.
   * @param _spender address The address which will spend the funds.
   * @return A uint256 specifying the amount of tokens still available for the spender.
   */
  function allowance(address _owner, address _spender) public view returns (uint256) {
    return allowed[_owner][_spender];
  }

  /**
   * @dev Increase the amount of tokens that an owner allowed to a spender.
   *
   * approve should be called when allowed[_spender] == 0. To increment
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   * @param _spender The address which will spend the funds.
   * @param _addedValue The amount of tokens to increase the allowance by.
   */
  function increaseApproval(address _spender, uint _addedValue) public returns (bool) {
    allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

  /**
   * @dev Decrease the amount of tokens that an owner allowed to a spender.
   *
   * approve should be called when allowed[_spender] == 0. To decrement
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   * @param _spender The address which will spend the funds.
   * @param _subtractedValue The amount of tokens to decrease the allowance by.
   */
  function decreaseApproval(address _spender, uint _subtractedValue) public returns (bool) {
    uint oldValue = allowed[msg.sender][_spender];
    if (_subtractedValue > oldValue) {
      allowed[msg.sender][_spender] = 0;
    } else {
      allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
    }
    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

}

contract MozoXToken is StandardToken, OwnerERC20 {
    //token name
    string public constant name = "Mozo Extension Token";

    //token symbol
    string public constant symbol = "MOZOX";

    //token symbol
    uint8 public constant decimals = 2;

    //owner of contract
    address public owner_;
    ERC20Exchangable public treasury;

    modifier onlyOwner() {
        require(msg.sender == owner_);
        _;
    }


    /**
     * @notice Should provide _totalSupply = No. tokens * 100
    */
    constructor() public {
        owner_ = msg.sender;
        // constructor
        totalSupply_ = 50000000000000;
        //assign all tokens to owner
        balances[msg.sender] = totalSupply_;
        emit Transfer(0x0, msg.sender, totalSupply_);
    }
    
    /**
     * @dev Set treasury smart contract
     * @param _treasury Address of smart contract
    */
    function setTreasury(address _treasury) public onlyOwner {
        treasury = ERC20Exchangable(_treasury);
    }

    /**
    * @dev Get smart contract's owner
    */
    function owner() public view returns (address) {
        return owner_;
    }

    function isValidOwner(address _address) public view returns(bool) {
        if (_address == owner_) {
            return true;
        }
        return false;
    }  
    
    /**
    * @dev batch transferring token
    * @notice Sender should check whether he has enough tokens to be transferred
    * @param _recipients List of recipients addresses 
    * @param _values Values to be transferred
    */
    function batchTransfer(address[] _recipients, uint[] _values) public {
        require(_recipients.length == _values.length);
        uint length = _recipients.length;
        for (uint i = 0; i < length; i++) {
            transfer(_recipients[i], _values[i]);
        }
    }
    
    /**
     * @dev transfer token to Treasury smart contract and exchange to Mozo ERC20 tokens
     * @param _to The address to transfer to.
     * @param _value The amount to be transferred.
    */
    function soldMozo(address _to, uint _value) public returns(bool) {
        require(_to != address(0));
        if(transfer(treasury, _value)) {
            treasury.autoBuyERC20(msg.sender, _to, _value);
            return true;
        }
        return false;
    }
}