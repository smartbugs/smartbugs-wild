pragma solidity ^0.4.18;

// Owned contract
// ----------------------------------------------------------------------------
contract Owned {
    address public owner;
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }
    function Owned() public {
        owner = msg.sender;
    }

    function changeOwner(address _newOwner) public onlyOwner{
        owner = _newOwner;
    }
}


// Safe maths, borrowed from OpenZeppelin
// ----------------------------------------------------------------------------
library SafeMath {

  function mul(uint a, uint b) internal pure returns (uint) {
    uint c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function div(uint a, uint b) internal pure returns (uint) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

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

contract tokenRecipient {
  function receiveApproval(address _from, uint256 _value, address _token, bytes _extraData) public;
}

contract ERC20Token {
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
    function balanceOf(address _owner) constant public returns (uint256 balance);

    /// @notice send `_value` token to `_to` from `msg.sender`
    /// @param _to The address of the recipient
    /// @param _value The amount of token to be transferred
    /// @return Whether the transfer was successful or not
    function transfer(address _to, uint256 _value) public returns (bool success);

    /// @notice send `_value` token to `_to` from `_from` on the condition it is approved by `_from`
    /// @param _from The address of the sender
    /// @param _to The address of the recipient
    /// @param _value The amount of token to be transferred
    /// @return Whether the transfer was successful or not
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);

    /// @notice `msg.sender` approves `_spender` to spend `_value` tokens
    /// @param _spender The address of the account able to transfer the tokens
    /// @param _value The amount of tokens to be approved for transfer
    /// @return Whether the approval was successful or not
    function approve(address _spender, uint256 _value) public returns (bool success);

    /// @param _owner The address of the account owning tokens
    /// @param _spender The address of the account able to transfer the tokens
    /// @return Amount of remaining tokens allowed to spent
    function allowance(address _owner, address _spender) constant public returns (uint256 remaining);

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}

contract limitedFactor {
    uint256 public FoundationAddressFreezeTime;
    address public FoundationAddress;
    address public TeamAddress;
    modifier FoundationAccountNeedFreezeOneYear(address _address) {
        if(_address == FoundationAddress) {
            require(now >= FoundationAddressFreezeTime + 1 years);
        }
        _;
    }

}
contract standardToken is ERC20Token, limitedFactor {
    mapping (address => uint256) balances;
    mapping (address => mapping (address => uint256)) allowances;

    function balanceOf(address _owner) constant public returns (uint256) {
        return balances[_owner];
    }

    /* Transfers tokens from your address to other */
    function transfer(address _to, uint256 _value) public FoundationAccountNeedFreezeOneYear(msg.sender) returns (bool success) {
        require (balances[msg.sender] >= _value);           // Throw if sender has insufficient balance
        require (balances[_to] + _value >= balances[_to]);  // Throw if owerflow detected
        balances[msg.sender] -= _value;                     // Deduct senders balance
        balances[_to] += _value;                            // Add recivers blaance
        Transfer(msg.sender, _to, _value);                  // Raise Transfer event
        return true;
    }

    /* Approve other address to spend tokens on your account */
    function approve(address _spender, uint256 _value) public returns (bool success) {
        require(balances[msg.sender] >= _value);
        allowances[msg.sender][_spender] = _value;          // Set allowance
        Approval(msg.sender, _spender, _value);             // Raise Approval event
        return true;
    }

    /* Approve and then communicate the approved contract in a single tx */
    function approveAndCall(address _spender, uint256 _value, bytes _extraData) public returns (bool success) {
        tokenRecipient spender = tokenRecipient(_spender);              // Cast spender to tokenRecipient contract
        approve(_spender, _value);                                      // Set approval to contract for _value
        spender.receiveApproval(msg.sender, _value, this, _extraData);  // Raise method on _spender contract
        return true;
    }

    /* A contract attempts to get the coins */
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require (balances[_from] >= _value);                // Throw if sender does not have enough balance
        require (balances[_to] + _value >= balances[_to]);  // Throw if overflow detected
        require (_value <= allowances[_from][msg.sender]);  // Throw if you do not have allowance
        balances[_from] -= _value;                          // Deduct senders balance
        balances[_to] += _value;                            // Add recipient blaance
        allowances[_from][msg.sender] -= _value;            // Deduct allowance for this address
        Transfer(_from, _to, _value);                       // Raise Transfer event
        return true;
    }

    /* Get the amount of allowed tokens to spend */
    function allowance(address _owner, address _spender) constant public returns (uint256 remaining) {
        return allowances[_owner][_spender];
    }

}

contract NSilkRoadCoinToken is standardToken,Owned {
    using SafeMath for uint;

    string constant public name="NSilkRoadCoinToken";
    string constant public symbol="NSRC";
    uint256 constant public decimals=6;
    
    uint256 public totalSupply = 0;
    uint256 constant public topTotalSupply = 21*10**7*10**decimals;
    uint256 public FoundationSupply = percent(30);
	uint256 public TeamSupply = percent(25);
    uint256 public ownerSupply = topTotalSupply - FoundationSupply - TeamSupply;
    
    /// @dev Fallback to calling deposit when ether is sent directly to contract.
    function() public payable {}
    
    /// @dev initial function
    function NSilkRoadCoinToken() public {
        owner = msg.sender;
        mintTokens(owner, ownerSupply);
    }
    
    /// @dev Issue new tokens
    function mintTokens(address _to, uint256 _amount) internal {
        require (balances[_to] + _amount >= balances[_to]);     // Check for overflows
        balances[_to] = balances[_to].add(_amount);             // Set minted coins to target
        totalSupply = totalSupply.add(_amount);
        require(totalSupply <= topTotalSupply);
        Transfer(0x0, _to, _amount);                            // Create Transfer event from 0x
    }
    
    /// @dev Get time
    function getTime() internal constant returns(uint256) {
        return now;
    }
    
    /// @dev set initial message
    function setInitialVaribles(
        address _FoundationAddress,
        address _TeamAddress
        )
        public
        onlyOwner 
    {
        FoundationAddress = _FoundationAddress;
        TeamAddress = _TeamAddress;
    }
    
    /// @dev withDraw Ether to a Safe Wallet
    function withDraw(address _walletAddress) public payable onlyOwner {
        require (_walletAddress != address(0));
        _walletAddress.transfer(this.balance);
    }
    
    /// @dev allocate Token
    function transferMultiAddress(address[] _recivers, uint256[] _values) public onlyOwner {
        require (_recivers.length == _values.length);
        for(uint256 i = 0; i < _recivers.length ; i++){
            address reciver = _recivers[i];
            uint256 value = _values[i];
            require (balances[msg.sender] >= value);           // Throw if sender has insufficient balance
            require (balances[reciver] + value >= balances[reciver]);  // Throw if owerflow detected
            balances[msg.sender] -= value;                     // Deduct senders balance
            balances[reciver] += value;                            // Add recivers blaance
            Transfer(msg.sender, reciver, value);                  // Raise Transfer event
        }
    }
    
    /// @dev calcute the tokens
    function percent(uint256 percentage) internal pure returns (uint256) {
        return percentage.mul(topTotalSupply).div(100);
    }
    
    /// @dev allocate token for Foundation Address
    function allocateFoundationToken() public onlyOwner {
        require(TeamAddress != address(0));
        require(balances[FoundationAddress] == 0);
        mintTokens(FoundationAddress, FoundationSupply);
        FoundationAddressFreezeTime = now;
    }
    
    /// @dev allocate token for Team Address
    function allocateTeamToken() public onlyOwner {
        require(TeamAddress != address(0));
        require(balances[TeamAddress] == 0);
        mintTokens(TeamAddress, TeamSupply);
    }
}