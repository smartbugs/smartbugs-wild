pragma solidity ^0.4.24;

// Abstract contract for the full ERC 20 Token standard
// https://github.com/ethereum/EIPs/issues/20

contract Token {
    /* This is a slight change to the ERC20 base standard.
    function totalSupply() constant returns (uint256 supply);
    is replaced with:
    uint256 public totalSupply;
    This automatically creates a getter function for the totalSupply.
    This is moved to the base contract since public getter functions are not
    currently recognised as an implementation of the matching abstract
    function by the compiler.
    */
    /// total amount of tokens
    uint256 public totalSupply;

    /// @param _owner The address from which the balance will be retrieved
    /// @return The balance
    function balanceOf(address _owner) constant returns (uint256 balance);

    /// @notice send `_value` token to `_to` from `msg.sender`
    /// @param _to The address of the recipient
    /// @param _value The amount of token to be transferred
    /// @return Whether the transfer was successful or not
    function transfer(address _to, uint256 _value) returns (bool success);

    /// @notice send `_value` token to `_to` from `_from` on the condition it is approved by `_from`
    /// @param _from The address of the sender
    /// @param _to The address of the recipient
    /// @param _value The amount of token to be transferred
    /// @return Whether the transfer was successful or not
    function transferFrom(address _from, address _to, uint256 _value) returns (bool success);

    /// @notice `msg.sender` approves `_spender` to spend `_value` tokens
    /// @param _spender The address of the account able to transfer the tokens
    /// @param _value The amount of tokens to be approved for transfer
    /// @return Whether the approval was successful or not
    function approve(address _spender, uint256 _value) returns (bool success);

    /// @param _owner The address of the account owning tokens
    /// @param _spender The address of the account able to transfer the tokens
    /// @return Amount of remaining tokens allowed to spent
    function allowance(address _owner, address _spender) constant returns (uint256 remaining);

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}

contract Erc2Vite {
    
    mapping (address => string) public records;
    
    address public destoryAddr = 0x1111111111111111111111111111111111111111;

    uint256 public defaultCode = 203226;
    
    address public viteTokenAddress = 0x0;
	address public owner			= 0x0;
	
	uint public bindId = 0;
	event Bind(uint bindId, address indexed _ethAddr, string _viteAddr, uint256 amount, uint256 _invitationCode);
	
	/*
	 * public functions
	 */
	/// @dev Initialize the contract
	/// @param _viteTokenAddress ViteToken ERC20 token address
	/// @param _owner the owner of the contract
	function Erc2Vite(address _viteTokenAddress, address _owner) {
		require(_viteTokenAddress != address(0));
		require(_owner != address(0));

		viteTokenAddress = _viteTokenAddress;
		owner = _owner;
	}
    
    function bind(string _viteAddr, uint256 _invitationCode) public {

        require(bytes(_viteAddr).length == 55);
        
        var viteToken = Token(viteTokenAddress);
        uint256 apprAmount = viteToken.allowance(msg.sender, address(this));
        require(apprAmount > 0);
        
        require(viteToken.transferFrom(msg.sender, destoryAddr, apprAmount));
        
        records[msg.sender] = _viteAddr;

        if(_invitationCode == 0) {
            _invitationCode = defaultCode;
        }
        
        emit Bind(
            bindId++,
            msg.sender,
            _viteAddr,
            apprAmount,
            _invitationCode
        );
    }
    
    function () public payable {
        revert();
    }
    
    function destory() public {
        require(msg.sender == owner);
        selfdestruct(owner);
    }
    
}