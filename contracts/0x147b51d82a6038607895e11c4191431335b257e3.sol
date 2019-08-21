pragma solidity ^0.4.18;

/*
    2018 Proxycard
*/

// Abstract contract for the full ERC 20 Token standard
// https://github.com/ethereum/EIPs/issues/20

interface ERC20Token {
	/// @param _owner The address from which the balance will be retrieved
	/// @return The balance
	function balanceOf(address _owner) public view returns (uint256);

	/// @notice send `_value` token to `_to` from `msg.sender`
	/// @param _to The address of the recipient
	/// @param _value The amount of token to be transferred
	/// @return Whether the transfer was successful or not
	function transfer(address _to, uint256 _value) public returns (bool);

	/// @notice send `_value` token to `_to` from `_from` on the condition it is approved by `_from`
	/// @param _from The address of the sender
	/// @param _to The address of the recipient
	/// @param _value The amount of token to be transferred
	/// @return Whether the transfer was successful or not
	function transferFrom(address _from, address _to, uint256 _value) public returns (bool);

	/// @notice `msg.sender` approves `_spender` to spend `_value` tokens
	/// @param _spender The address of the account able to transfer the tokens
	/// @param _value The amount of tokens to be approved for transfer
	/// @return Whether the approval was successful or not
	function approve(address _spender, uint256 _value) public returns (bool);

	/// @param _owner The address of the account owning tokens
	/// @param _spender The address of the account able to transfer the tokens
	/// @return Amount of remaining tokens allowed to spent
	function allowance(address _owner, address _spender) public view returns (uint256);

	event Transfer(address indexed _from, address indexed _to, uint256 _value);
	event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}

contract Owned {
    /// @notice The address of the owner is the only address that can call
    ///  a function with this modifier
    modifier onlyOwner { require(msg.sender == owner); _; }

    address public owner;

    function Owned() public { owner = msg.sender;}

    /// @notice Changes the owner of the contract
    /// @param _newOwner The new owner of the contract
    function changeOwner(address _newOwner) onlyOwner public {
        owner = _newOwner;
    }
}

library SafeMathMod {// Partial SafeMath Library

    function sub(uint256 a, uint256 b) internal pure returns (uint256 c) {
        require((c = a - b) < a);
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
        require((c = a + b) > a);
    }
}

contract EPRX is Owned, ERC20Token  {
    using SafeMathMod for uint256;

    /**
    * @constant name The name of the token
    * @constant symbol  The symbol used to display the currency
    * @constant decimals  The number of decimals used to display a balance
    * @constant totalSupply The total number of tokens times 10^ of the number of decimals
    * @constant MAX_UINT256 Magic number for unlimited allowance
    * @storage balanceOf Holds the balances of all token holders
    * @storage allowed Holds the allowable balance to be transferable by another address.
    */

    string constant public name = "eProxy";

    string constant public symbol = "ePRX";

    uint8 constant public decimals = 8;

    uint256 constant public totalSupply = 50000000e8;
	
	address public issuingTokenOwner;

    mapping (address => uint256) public balanceOf;

    // `allowed` tracks any extra transfer rights as in all ERC20 tokens
    mapping (address => mapping (address => uint256)) public allowed;

    // Flag that determines if the token is transferable or not.
    bool public transfersEnabled;

	////////////////
	// Events
	////////////////
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event TransferFrom(address indexed _spender, address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);	
    event ClaimedTokens(address indexed _token, address indexed _Owner, uint256 _amount);
    event SwappedTokens(address indexed _owner, uint256 _amountOffered, uint256 _amountReceived);
 
 	////////////////
	// Constructor
	////////////////   
    function EPRX() public { 
		issuingTokenOwner = msg.sender;
        balanceOf[issuingTokenOwner] = totalSupply; 
        transfersEnabled = true;
    }

	///////////////////
	// ERC20 Methods
	///////////////////

    /// @notice Send `_amount` tokens to `_to` from `msg.sender`
    /// @param _to The address of the recipient
    /// @param _amount The amount of tokens to be transferred
    /// @return Whether the transfer was successful or not
    function transfer(address _to, uint256 _amount) public returns (bool success) {
        if (msg.sender != owner) {
            require(transfersEnabled);
        }
        return doTransfer(msg.sender, _to, _amount);
    }

    /// @notice Send `_amount` tokens to `_to` from `_from` on the condition it
    ///  is approved by `_from`
    /// @param _from The address holding the tokens being transferred
    /// @param _to The address of the recipient
    /// @param _amount The amount of tokens to be transferred
    /// @return True if the transfer was successful
    function transferFrom(address _from, address _to, uint256 _amount
    ) public returns (bool success) {

        // The owner of this contract can move tokens around at will,
        //  this is important to recognize! Confirm that you trust the
        //  owner of this contract
        if (msg.sender != owner) {
            require(transfersEnabled);

            // The standard ERC20 transferFrom functionality
            // require(allowed[_from][msg.sender] >= _amount);
			allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_amount);
        }

        return doTransfer(_from, _to, _amount);
    }

    /// @dev This is the actual transfer function in the token contract, it can
    ///  only be called by other functions in this contract.
    /// @param _from The address holding the tokens being transferred
    /// @param _to The address of the recipient
    /// @param _amount The amount of tokens to be transferred
    /// @return True if the transfer was successful
    function doTransfer(address _from, address _to, uint _amount
    ) internal returns(bool) {
	
		if(_amount == 0) {
			return true;
		}

		// Do not allow transfer to 0x0 or the token contract itself
		require((_to != 0) && (_to != address(this)));

		/* SafeMathMOd.sub will throw if there is not enough balance
		   and if the transfer value is 0. */
		balanceOf[_from] = balanceOf[_from].sub(_amount);
		balanceOf[_to] = balanceOf[_to].add(_amount);

		// An event to make the transfer easy to find on the blockchain
		Transfer(_from, _to, _amount);

        return true;
    }

    /// @param _owner The address that's balance is being requested
    /// @return The balance of `_owner` at the current block
    function balanceOf(address _owner) public view returns (uint256) {
        return balanceOf[_owner];
    }

    /// @notice `msg.sender` approves `_spender` to spend `_amount` tokens on
    ///  its behalf. This is a modified version of the ERC20 approve function
    ///  to be a little bit safer
    /// @param _spender The address of the account able to transfer the tokens
    /// @param _amount The amount of tokens to be approved for transfer
    /// @return True if the approval was successful
    function approve(address _spender, uint256 _amount) public returns (bool) {
        require(transfersEnabled);

        /* Ensures address "0x0" is not assigned allowance. */
        require(_spender != address(0));

        // To change the approve amount you first have to reduce the addresses`
        //  allowance to zero by calling `approve(_spender,0)` if it is not
        //  already 0 to mitigate the race condition described here:
        //  https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
        require((_amount == 0) || (allowed[msg.sender][_spender] == 0));

        allowed[msg.sender][_spender] = _amount;
        Approval(msg.sender, _spender, _amount);
		
        return true;
    }

    /// @dev This function makes it easy to read the `allowed[]` map
    /// @param _owner The address of the account that owns the token
    /// @param _spender The address of the account able to transfer the tokens
    /// @return Amount of remaining tokens of _owner that _spender is allowed
    ///  to spend
    function allowance(address _owner, address _spender
    ) public view returns (uint256 remaining) {
        return allowed[_owner][_spender];
    }

	////////////////
	// Enable tokens transfers
	////////////////

    /// @notice Enables token holders to transfer their tokens freely if true
    /// @param _transfersEnabled True if transfers are allowed in the clone
    function enableTransfers(bool _transfersEnabled) onlyOwner public {
        transfersEnabled = _transfersEnabled;
    }

	//////////
	// Safety Methods
	//////////

    /// @notice This method can be used by the owner to extract mistakenly
    ///  sent tokens to this contract.
    /// @param _token The address of the token contract that you want to recover
    ///  set to 0 in case you want to extract ether.
    function claimTokens(address _token) onlyOwner public {
        // Transfer ether
        if (_token == 0x0) {
            owner.transfer(this.balance);
            return;
        }

        ERC20Token token = ERC20Token(_token);
        uint balance = token.balanceOf(this);
        token.transfer(owner, balance);
        ClaimedTokens(_token, owner, balance);
    }

    /// @notice This method can be used by users holding old proxy tokens
    ///  to swap for new tokens at the ratio of 1 : 2.
    function swapProxyTokens() public {
        ERC20Token oldToken = ERC20Token(0x81BE91c7E74Ad0957B4156F782263e7B0B88cF7b);
        uint256 oldTokenBalance = oldToken.balanceOf(msg.sender);

        require(oldTokenBalance > 0);

        // User must first approve address(this) as a spender by calling the below
        // approve(<address of this contract>, oldTokenBalance);
		
        // Convert old proxy token to new token for any user authorizing the transfer
        if(oldToken.transferFrom(msg.sender, issuingTokenOwner, oldTokenBalance)) {
            require(oldToken.balanceOf(msg.sender) == 0);
			
            // Transfer new token to user
			uint256 newTokenAmount = 200 * oldTokenBalance;
            doTransfer(issuingTokenOwner, msg.sender, newTokenAmount);

            SwappedTokens(msg.sender, oldTokenBalance, newTokenAmount);
        }
        
    }

}