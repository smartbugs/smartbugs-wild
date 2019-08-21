pragma solidity ^0.4.18;

/* taking ideas from Zeppelin solidity module */
contract SafeMath {

    // it is recommended to define functions which can neither read the state of blockchain nor write in it as pure instead of constant

    function safeAdd(uint256 x, uint256 y) internal pure returns(uint256) {
        uint256 z = x + y;
        assert((z >= x));
        return z;
    }

    function safeSubtract(uint256 x, uint256 y) internal pure returns(uint256) {
        assert(x >= y);
        return x - y;
    }

    function safeMult(uint256 x, uint256 y) internal pure returns(uint256) {
        uint256 z = x * y;
        assert((x == 0)||(z/x == y));
        return z;
    }

    function safeDiv(uint256 x, uint256 y) internal pure returns (uint256) {
        uint256 z = x / y;
        return z;
    }

    // mitigate short address attack
    // thanks to https://github.com/numerai/contract/blob/c182465f82e50ced8dacb3977ec374a892f5fa8c/contracts/Safe.sol#L30-L34.
    // TODO: doublecheck implication of >= compared to ==
    modifier onlyPayloadSize(uint numWords) {
        assert(msg.data.length >= numWords * 32 + 4);
        _;
    }

}

/// Implements ERC 20 Token standard: https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20-token-standard.md
contract ERC20 {
    uint256 public totalSupply;

    /*
     *  Public functions
     */
    function balanceOf(address _owner) constant public returns (uint256 balance);
    function transfer(address _to, uint256 _value) public returns (bool success);
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);
    function approve(address _spender, uint256 _value) public returns (bool success);
    function allowance(address _owner, address _spender) public constant returns (uint256 remaining);

    /*
     *  Events
     */
    // this generates a public event on blockchain that will notify clients
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
    // This notifies clients about the amount burnt
    event Burn(address indexed from, uint256 value);


}


/*  ERC 20 token */
contract StandardToken is ERC20,SafeMath {

    /*
     *  Storage
    */

    mapping (address => uint256) balances;
    mapping (address => mapping (address => uint256)) allowed;


    /*
     *  Public functions
     */
    /// @dev Transfers sender's tokens to a given address. Returns success
    /// @param _to Address of token receiver
    /// @param _value Number of tokens to transfer
    /// @return Was transfer successful?

    function transfer(address _to, uint256 _value) onlyPayloadSize(2) public returns (bool success) {
      if (balances[msg.sender] >= _value && _value > 0 && balances[_to] + _value > balances[_to]) {
        balances[msg.sender] -= _value;
        balances[_to] += _value;
        Transfer(msg.sender, _to, _value);
        return true;
      } else {
        return false;
      }
    }


    /// @dev Allows allowed third party to transfer tokens from one address to another. Returns success
    /// @param _from Address from where tokens are withdrawn
    /// @param _to Address to where tokens are sent
    /// @param _value Number of tokens to transfer
    /// @return Was transfer successful?

    function transferFrom(address _from, address _to, uint256 _value) onlyPayloadSize(3) public returns (bool success) {
      if (balances[_from] >= _value && allowed[_from][msg.sender] >= _value && _value > 0) {
        balances[_to] += _value;
        balances[_from] -= _value;
        allowed[_from][msg.sender] -= _value;
        Transfer(_from, _to, _value);
        return true;
      } else {
        return false;
      }
    }


    /// @dev Returns number of tokens owned by given address
    /// @param _owner Address of token owner
    /// @return Balance of owner

    // it is recommended to define functions which can read the state of blockchain but cannot write in it as view instead of constant

    function balanceOf(address _owner) view public returns (uint256 balance) {
        return balances[_owner];
    }

    /// @dev Sets approved amount of tokens for spender. Returns success
    /// @param _spender Address of allowed account
    /// @param _value Number of approved tokens
    /// @return Was approval successful?

    function approve(address _spender, uint256 _value) onlyPayloadSize(2) public returns (bool success) {
        // To change the approve amount you first have to reduce the addresses`
        //  allowance to zero by calling `approve(_spender, 0)` if it is not
        //  already 0 to mitigate the race condition described here:
        //  https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729

        require(_value == 0 && (allowed[msg.sender][_spender] == 0));
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }


    function changeApproval(address _spender, uint256 _oldValue, uint256 _newValue) onlyPayloadSize(3) public returns (bool success) {
        require(allowed[msg.sender][_spender] == _oldValue);
        allowed[msg.sender][_spender] = _newValue;
        Approval(msg.sender, _spender, _newValue);

        return true;
    }


    /// @dev Returns number of allowed tokens for given address
    /// @param _owner Address of token owner
    /// @param _spender Address of token spender
    /// @return Remaining allowance for spender
    function allowance(address _owner, address _spender) public  view returns (uint256 remaining) {
      return allowed[_owner][_spender];
    }

    /**
    * @dev Burns a specific amount of tokens.
    * @param _value The amount of token to be burned.
    */

    function burn(uint256 _value) public returns (bool burnSuccess) {
        require(_value > 0);
        require(_value <= balances[msg.sender]);
        // no need to require value <= totalSupply, since that would imply the
        // sender's balance is greater than the totalSupply, which *should* be an assertion failure

        address burner = msg.sender;
        balances[burner] =  safeSubtract(balances[burner],_value);
        totalSupply = safeSubtract(totalSupply,_value);
        Burn(burner, _value);
        return true;
    }


}


contract TrakToken is StandardToken {
    // FIELDS
    string constant public  name = "TrakInvest Token" ;
    string constant public  symbol = "TRAK";
    uint256 constant public  decimals = 18;

    // The flag indicates if the crowdsale contract is in Funding state.
    bool public fundraising = true;

    // who created smart contract
    address public creator;
    // owns the total supply of tokens - it would be DAO
    address public tokensOwner;
    mapping (address => bool) public frozenAccounts;

  /// events
    event FrozenFund(address target ,bool frozen);

  /// modifiers

    modifier isCreator() { 
      require(msg.sender == creator);  
      _; 
    }

    modifier onlyPayloadSize(uint size) {
        assert(msg.data.length >= size + 4);
        _;
    }


    modifier onlyOwner() {
        require(msg.sender == tokensOwner);
        _;
    }

    modifier manageTransfer() {
        if (msg.sender == tokensOwner) {
            _;
        }
        else {
            require(fundraising == false);
            _;
        }
    }

  /// constructor
    function TrakToken(
      address _fundsWallet,
      uint256 initialSupply
      ) public {
      creator = msg.sender;

      if (_fundsWallet !=0) {
        tokensOwner = _fundsWallet;
      }
      else {
        tokensOwner = msg.sender;
      }

      totalSupply = initialSupply * (uint256(10) ** decimals);
      balances[tokensOwner] = totalSupply;
      Transfer(0x0, tokensOwner, totalSupply);
    }


  /// overriden methods

    function transfer(address _to, uint256 _value)  public manageTransfer onlyPayloadSize(2 * 32) returns (bool success) {
      require(!frozenAccounts[msg.sender]);
      require(_to != address(0));
      return super.transfer(_to, _value);
    }

    function transferFrom(address _from, address _to, uint256 _value)  public manageTransfer onlyPayloadSize(3 * 32) returns (bool success) {
      require(!frozenAccounts[msg.sender]);
      require(_to != address(0));
      require(_from != address(0));
      return super.transferFrom(_from, _to, _value);
    }


    function freezeAccount (address target ,bool freeze) public onlyOwner {
      frozenAccounts[target] = freeze;
      FrozenFund(target,freeze);  
    }

    function burn(uint256 _value) public onlyOwner returns (bool burnSuccess) {
        require(fundraising == false);
        return super.burn(_value);
    }

    /// @param newAddress Address of new owner.
    function changeTokensWallet(address newAddress) public onlyOwner returns (bool)
    {
        require(newAddress != address(0));
        tokensOwner = newAddress;
    }

    function finalize() public  onlyOwner {
        require(fundraising != false);
        // Switch to Operational state. This is the only place this can happen.
        fundraising = false;
    }


    function() public {
        revert();
    }

}