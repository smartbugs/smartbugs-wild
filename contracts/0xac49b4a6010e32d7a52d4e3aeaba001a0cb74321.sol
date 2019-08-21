pragma solidity ^0.4.19;

library SafeMath {
  function sub(uint a, uint b) internal pure returns (uint) {
    assert(b <= a);
    return a - b;
  }

  function add(uint a, uint b) internal pure returns (uint) {
    uint c = a + b;
    assert(c >= a);
    return c;
  }
}

/**
* @title Contract that will work with ERC223 tokens.
*/
contract ContractReceiver {
  /**
   * @dev Standard ERC223 function that will handle incoming token transfers.
   *
   * @param _from  Token sender address.
   * @param _value Amount of tokens.
   * @param _data  Transaction metadata.
   */
   
  function tokenFallback(address _from, uint _value, bytes _data) public;
}

/**
 * @title ERC223 standard token implementation.
 */
contract GodviewChain {
	using SafeMath for uint256;
	
	uint256 public totalSupply;
    string  public name;
    string  public symbol;
    uint8   public constant decimals = 4;

    address public owner;
	
    mapping(address => uint256) balances; // List of user balances.

    function GodviewChain(uint256 initialSupply, string tokenName, string tokenSymbol) public {
        owner           =   msg.sender;
		totalSupply     =   initialSupply * 10 ** uint256(decimals);
		name            =   tokenName;
		symbol          =   tokenSymbol;
        balances[owner] =   totalSupply;
    }

	event Transfer(address indexed from, address indexed to, uint256 value);  // ERC20
    event Transfer(address indexed from, address indexed to, uint256 value, bytes data); // ERC233
	event Burn(address indexed from, uint256 amount, uint256 currentSupply, bytes data);


	/**
     * @dev Transfer the specified amount of tokens to the specified address.
     *      This function works the same with the previous one
     *      but doesn't contain `_data` param.
     *      Added due to backwards compatibility reasons.
     *
     * @param _to    Receiver address.
     * @param _value Amount of tokens that will be transferred.
     */
    function transfer(address _to, uint _value) public returns (bool) {
        bytes memory empty;
		transfer(_to, _value, empty);
    }

	/**
     * @dev Transfer the specified amount of tokens to the specified address.
     *      Invokes the `tokenFallback` function if the recipient is a contract.
     *      The token transfer fails if the recipient is a contract
     *      but does not implement the `tokenFallback` function
     *      or the fallback function to receive funds.
     *
     * @param _to    Receiver address.
     * @param _value Amount of tokens that will be transferred.
     * @param _data  Transaction metadata.
     */
    function transfer(address _to, uint _value, bytes _data) public returns (bool) {
        uint codeLength;

        assembly {
            codeLength := extcodesize(_to)
        }

        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);
        if(codeLength>0) {
            ContractReceiver receiver = ContractReceiver(_to);
            receiver.tokenFallback(msg.sender, _value, _data);
        }
		
		Transfer(msg.sender, _to, _value);
        Transfer(msg.sender, _to, _value, _data);
    }
	
	/**
     * Destroy tokens
     *
     * Remove `_value` tokens from the system irreversibly
     *
     * @param _value the amount of money to burn
	 * @param _data  Transaction metadata.
     */
    function burn(uint256 _value, bytes _data) public returns (bool success) {
		balances[msg.sender] = balances[msg.sender].sub(_value);
        totalSupply = totalSupply.sub(_value);
        Burn(msg.sender, _value, totalSupply, _data);
        return true;
    }
	
	/**
     * @dev Returns balance of the `_address`.
     *
     * @param _address   The address whose balance will be returned.
     * @return balance Balance of the `_address`.
     */
    function balanceOf(address _address) public constant returns (uint256 balance) {
        return balances[_address];
    }
}