pragma solidity ^0.4.18;

 /// @title Ownable contract - base contract with an owner
contract Ownable {
  address public owner;

  function Ownable() public {
    owner = msg.sender;
  }

  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

  function transferOwnership(address newOwner) public onlyOwner {
    if (newOwner != address(0)) {
      owner = newOwner;
    }
  }
}

 /// @title Killable contract - base contract that can be killed by owner. All funds in contract will be sent to the owner.
contract Killable is Ownable {
  function kill() public onlyOwner {
    selfdestruct(owner);
  }
}


 /// @title ERC20 interface see https://github.com/ethereum/EIPs/issues/20
contract ERC20 {
  uint public totalSupply;
  function balanceOf(address who) public constant returns (uint);
  function allowance(address owner, address spender) public constant returns (uint);  
  function transfer(address to, uint value) public returns (bool ok);
  function transferFrom(address from, address to, uint value) public returns (bool ok);
  function approve(address spender, uint value) public returns (bool ok);
  function decimals() public constant returns (uint value);
  event Transfer(address indexed from, address indexed to, uint value);
  event Approval(address indexed owner, address indexed spender, uint value);
}

 /// @title SafeMath contract - math operations with safety checks
contract SafeMath {
  function safeMul(uint a, uint b) internal pure  returns (uint) {
    uint c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function safeDiv(uint a, uint b) internal pure returns (uint) {
    assert(b > 0);
    uint c = a / b;
    assert(a == b * c + a % b);
    return c;
  }

  function safeSub(uint a, uint b) internal pure returns (uint) {
    assert(b <= a);
    return a - b;
  }

  function safeAdd(uint a, uint b) internal pure returns (uint) {
    uint c = a + b;
    assert(c>=a && c>=b);
    return c;
  }

  function max64(uint64 a, uint64 b) internal pure returns (uint64) {
    return a >= b ? a : b;
  }

  function min64(uint64 a, uint64 b) internal pure returns (uint64) {
    return a < b ? a : b;
  }

  function max256(uint256 a, uint256 b) internal pure returns (uint256) {
    return a >= b ? a : b;
  }

  function min256(uint256 a, uint256 b) internal pure returns (uint256) {
    return a < b ? a : b;
  }
}


 /// @title TokenAdrToken contract - standard ERC20 token with Short Hand Attack and approve() race condition mitigation.
contract TokenAdrToken is SafeMath, ERC20, Killable {
  string constant public name = "TokenAdr Token";
  string constant public symbol = "TADR";
 
  /// Holder list
  address[] public holders;
  /// Balance data
  struct Balance {
    /// Tokens amount
    uint value;
    /// Object exist
    bool exist;
  }
  /// Holder balances
  mapping(address => Balance) public balances;
  /// Contract that is allowed to create new tokens and allows unlift the transfer limits on this token
  address public crowdsaleAgent;
  /// A crowdsale contract can release us to the wild if ICO success. If false we are are in transfer lock up period.
  bool public released = false;
  /// approve() allowances
  mapping (address => mapping (address => uint)) allowed;

  /// @dev Limit token transfer until the crowdsale is over.
  modifier canTransfer() {
    if(!released)
      require(msg.sender == crowdsaleAgent);
    _;
  }

  /// @dev The function can be called only before or after the tokens have been releasesd
  /// @param _released token transfer and mint state
  modifier inReleaseState(bool _released) {
    require(_released == released);
    _;
  }

  /// @dev If holder does not exist add to array
  /// @param holder Token holder
  modifier addIfNotExist(address holder) {
    if(!balances[holder].exist)
      holders.push(holder);
    _;
  }

  /// @dev The function can be called only by release agent.
  modifier onlyCrowdsaleAgent() {
    require(msg.sender == crowdsaleAgent);
    _;
  }

  /// @dev Fix for the ERC20 short address attack http://vessenes.com/the-erc20-short-address-attack-explained/
  /// @param size payload size
  modifier onlyPayloadSize(uint size) {
    require(msg.data.length >= size + 4);
    _;
  }

  /// @dev Make sure we are not done yet.
  modifier canMint() {
    require(!released);
    _;
  }

  /// @dev Constructor
  function TokenAdrToken() public {
  }

  /// Fallback method
  function() payable public {
	  revert();
  }

  function decimals() public constant returns (uint value) {
    return 12;
  }
  /// @dev Create new tokens and allocate them to an address. Only callably by a crowdsale contract
  /// @param receiver Address of receiver
  /// @param amount  Number of tokens to issue.
  function mint(address receiver, uint amount) onlyCrowdsaleAgent canMint addIfNotExist(receiver) public {
      totalSupply = safeAdd(totalSupply, amount);
      balances[receiver].value = safeAdd(balances[receiver].value, amount);
      balances[receiver].exist = true;
      Transfer(0, receiver, amount);
  }

  /// @dev Set the contract that can call release and make the token transferable.
  /// @param _crowdsaleAgent crowdsale contract address
  function setCrowdsaleAgent(address _crowdsaleAgent) onlyOwner inReleaseState(false) public {
    crowdsaleAgent = _crowdsaleAgent;
  }
  /// @dev One way function to release the tokens to the wild. Can be called only from the release agent that is the final ICO contract. It is only called if the crowdsale has been success (first milestone reached).
  function releaseTokenTransfer() public onlyCrowdsaleAgent {
    released = true;
  }
  /// @dev Tranfer tokens to address
  /// @param _to dest address
  /// @param _value tokens amount
  /// @return transfer result
  function transfer(address _to, uint _value) onlyPayloadSize(2 * 32) canTransfer addIfNotExist(_to) public returns (bool success) {
    balances[msg.sender].value = safeSub(balances[msg.sender].value, _value);
    balances[_to].value = safeAdd(balances[_to].value, _value);
    balances[_to].exist = true;
    Transfer(msg.sender, _to, _value);
    return true;
  }

  /// @dev Tranfer tokens from one address to other
  /// @param _from source address
  /// @param _to dest address
  /// @param _value tokens amount
  /// @return transfer result
  function transferFrom(address _from, address _to, uint _value) onlyPayloadSize(2 * 32) canTransfer addIfNotExist(_to) public returns (bool success) {
    var _allowance = allowed[_from][msg.sender];

    balances[_to].value = safeAdd(balances[_to].value, _value);
    balances[_from].value = safeSub(balances[_from].value, _value);
    balances[_to].exist = true;

    allowed[_from][msg.sender] = safeSub(_allowance, _value);
    Transfer(_from, _to, _value);
    return true;
  }
  /// @dev Tokens balance
  /// @param _owner holder address
  /// @return balance amount
  function balanceOf(address _owner) constant public returns (uint balance) {
    return balances[_owner].value;
  }

  /// @dev Approve transfer
  /// @param _spender holder address
  /// @param _value tokens amount
  /// @return result
  function approve(address _spender, uint _value) public returns (bool success) {
    // To change the approve amount you first have to reduce the addresses`
    //  allowance to zero by calling `approve(_spender, 0)` if it is not
    //  already 0 to mitigate the race condition described here:
    //  https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
    require ((_value == 0) || (allowed[msg.sender][_spender] == 0));

    allowed[msg.sender][_spender] = _value;
    Approval(msg.sender, _spender, _value);
    return true;
  }

  /// @dev Token allowance
  /// @param _owner holder address
  /// @param _spender spender address
  /// @return remain amount
  function allowance(address _owner, address _spender) constant public returns (uint remaining) {
    return allowed[_owner][_spender];
  }
}