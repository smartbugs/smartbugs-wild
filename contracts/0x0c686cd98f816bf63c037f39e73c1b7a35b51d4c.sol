pragma solidity ^0.4.18;
// -------------------------------------------------
// ethPoker.io EPX token - ERC20 token smart contract
// contact admin@ethpoker.io for queries
// Revision 20b
// Full test suite 20r passed
// -------------------------------------------------
// ERC Token Standard #20 interface:
// https://github.com/ethereum/EIPs/issues/20
// EPX contract sources:
// https://github.com/EthPokerIO/ethpokerIO
// ------------------------------------------------
// 2018 improvements:
// - added transferAnyERC20Token function to capture airdropped tokens
// - added revert() rejection of any Eth sent to the token address itself
// - additional gas optimisation performed (round 3)
// -------------------------------------------------
// Security reviews passed - cycle 20r
// Functional reviews passed - cycle 20r
// Final code revision and regression test cycle passed - cycle 20r
// -------------------------------------------------

contract owned {
  address public owner;

  function owned() internal {
    owner = msg.sender;
  }
  modifier onlyOwner {
    require(msg.sender == owner);
    _;
  }
}

contract safeMath {
  function safeMul(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a * b;
    safeAssert(a == 0 || c / a == b);
    return c;
  }

  function safeDiv(uint256 a, uint256 b) internal pure returns (uint256) {
    safeAssert(b > 0);
    uint256 c = a / b;
    safeAssert(a == b * c + a % b);
    return c;
  }

  function safeSub(uint256 a, uint256 b) internal pure returns (uint256) {
    safeAssert(b <= a);
    return a - b;
  }

  function safeAdd(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    safeAssert(c>=a && c>=b);
    return c;
  }

  function safeAssert(bool assertion) internal pure {
    if (!assertion) revert();
  }
}

contract ERC20Interface is owned, safeMath {
  function balanceOf(address _owner) public constant returns (uint256 balance);
  function transfer(address _to, uint256 _value) public returns (bool success);
  function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);
  function approve(address _spender, uint256 _value) public returns (bool success);
  function increaseApproval (address _spender, uint _addedValue) public returns (bool success);
  function decreaseApproval (address _spender, uint _subtractedValue) public returns (bool success);
  function allowance(address _owner, address _spender) public constant returns (uint256 remaining);
  event Buy(address indexed _sender, uint256 _eth, uint256 _EPX);
  event Transfer(address indexed _from, address indexed _to, uint256 _value);
  event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}

contract EPXToken is ERC20Interface {
  // token setup variables
  string  public constant name                  = "EthPoker.io EPX";
  string  public constant standard              = "EPX";
  string  public constant symbol                = "EPX";
  uint8   public constant decimals              = 4;                               // 4 decimals for practicality
  uint256 private constant totalSupply          = 2800000000000;                   // 280 000 000 (total supply of EPX tokens is 280,000,000) + 4 decimal points (2800000000000)

  // token mappings
  mapping (address => uint256) balances;
  mapping (address => mapping (address => uint256)) allowed;

  // ERC20 standard token possible events, matched to ICO and preSale contracts
  event Buy(address indexed _sender, uint256 _eth, uint256 _EPX);
  event Transfer(address indexed _from, address indexed _to, uint256 _value);
  event Approval(address indexed _owner, address indexed _spender, uint256 _value);

  // ERC20 token balanceOf query function
  function balanceOf(address _owner) public constant returns (uint256 balance) {
    return balances[_owner];
  }

  // token balance normalised for display (4 decimals removed)
  function EPXtokenSupply() public pure returns (uint256 totalEPXtokenCount) {
    return safeDiv(totalSupply,10000); // div by 1,000 for display normalisation (4 decimals)
  }

  // ERC20 token transfer function with additional safety
  function transfer(address _to, uint256 _amount) public returns (bool success) {
    require(!(_to == 0x0));
    if ((balances[msg.sender] >= _amount)
    && (_amount > 0)
    && ((safeAdd(balances[_to],_amount) > balances[_to]))) {
      balances[msg.sender] = safeSub(balances[msg.sender], _amount);
      balances[_to] = safeAdd(balances[_to], _amount);
      Transfer(msg.sender, _to, _amount);
      return true;
    } else {
      return false;
    }
  }

  // ERC20 token transferFrom function with additional safety
  function transferFrom(
    address _from,
    address _to,
    uint256 _amount) public returns (bool success) {
    require(!(_to == 0x0));
    if ((balances[_from] >= _amount)
    && (allowed[_from][msg.sender] >= _amount)
    && (_amount > 0)
    && (safeAdd(balances[_to],_amount) > balances[_to])) {
      balances[_from] = safeSub(balances[_from], _amount);
      allowed[_from][msg.sender] = safeSub((allowed[_from][msg.sender]),_amount);
      balances[_to] = safeAdd(balances[_to], _amount);
      Transfer(_from, _to, _amount);
      return true;
    } else {
      return false;
    }
  }

  // ERC20 allow _spender to withdraw, multiple times, up to the _value amount
  function approve(address _spender, uint256 _amount) public returns (bool success) {
    //Fix for known double-spend https://docs.google.com/document/d/1YLPtQxZu1UAvO9cZ1O2RPXBbT0mooh4DYKjA_jp-RLM/edit#
    //Input must either set allow amount to 0, or have 0 already set, to workaround issue
    require((_amount == 0) || (allowed[msg.sender][_spender] == 0));
    require((_amount == 0) || (allowed[msg.sender][_spender] == 0));
    allowed[msg.sender][_spender] = _amount;
    Approval(msg.sender, _spender, _amount);
    return true;
  }

  // ERC20 return allowance for given owner spender pair
  function allowance(address _owner, address _spender) public constant returns (uint256 remaining) {
    return allowed[_owner][_spender];
  }

  // ERC20 Updated increase approval process (to prevent double-spend attack but remove need to zero allowance before setting)
  function increaseApproval (address _spender, uint _addedValue) public returns (bool success) {
    allowed[msg.sender][_spender] = safeAdd(allowed[msg.sender][_spender],_addedValue);

    // report new approval amount
    Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

  // ERC20 Updated decrease approval process (to prevent double-spend attack but remove need to zero allowance before setting)
  function decreaseApproval (address _spender, uint _subtractedValue) public returns (bool success) {
    uint oldValue = allowed[msg.sender][_spender];

    if (_subtractedValue > oldValue) {
      allowed[msg.sender][_spender] = 0;
    } else {
      allowed[msg.sender][_spender] = safeSub(oldValue,_subtractedValue);
    }

    // report new approval amount
    Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

  // ERC20 Standard default function to assign initial supply variables and send balance to creator for distribution to EPX presale and ICO contract
  function EPXToken() public onlyOwner {
    balances[msg.sender] = totalSupply;
  }

  // Reject sent ETH
  function () public payable {
    revert();
  }

  // Contract owner able to transfer any airdropped or ERC20 tokens that are sent to the token contract address (mistakenly or as part of airdrop campaign)
  function transferAnyERC20Token(address tokenAddress, uint tokens) public onlyOwner returns (bool success) {
    return ERC20Interface(tokenAddress).transfer(owner, tokens);
  }
}