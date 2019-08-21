pragma solidity ^0.4.4;


/*
 * Ownable
 *
 * Base contract with an owner.
 * Provides onlyOwner modifier, which prevents function from running if it is called by anyone other than the owner.
 */
contract Ownable {
  address public owner;

  function Ownable() {
    owner = msg.sender;
  }

  modifier onlyOwner() {
    if (msg.sender != owner) throw;
    _;
  }

  function transferOwnership(address newOwner) onlyOwner {
    if (newOwner != address(0)) owner = newOwner;
  }

}

contract SafeMath {
  function safeMul(uint a, uint b) internal returns (uint) {
    uint c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function safeSub(uint a, uint b) internal returns (uint) {
    assert(b <= a);
    return a - b;
  }

  function safeAdd(uint a, uint b) internal returns (uint) {
    uint c = a + b;
    assert(c>=a && c>=b);
    return c;
  }

  function assert(bool assertion) internal {
    if (!assertion) throw;
  }
}

contract ERC20 {
  uint public totalSupply;
  function balanceOf(address who) constant returns (uint);
  function allowance(address owner, address spender) constant returns (uint);

  function transfer(address to, uint value) returns (bool ok);
  function transferFrom(address from, address to, uint value) returns (bool ok);
  function approve(address spender, uint value) returns (bool ok);
  event Transfer(address indexed from, address indexed to, uint value);
  event Approval(address indexed owner, address indexed spender, uint value);
}

contract StandardToken is ERC20, SafeMath {

  mapping(address => uint) balances;
  mapping (address => mapping (address => uint)) allowed;

  function transfer(address _to, uint _value) returns (bool success) {
    balances[msg.sender] = safeSub(balances[msg.sender], _value);
    balances[_to] = safeAdd(balances[_to], _value);
    Transfer(msg.sender, _to, _value);
    return true;
  }

  function transferFrom(address _from, address _to, uint _value) returns (bool success) {
    var _allowance = allowed[_from][msg.sender];
    
    balances[_to] = safeAdd(balances[_to], _value);
    balances[_from] = safeSub(balances[_from], _value);
    allowed[_from][msg.sender] = safeSub(_allowance, _value);
    Transfer(_from, _to, _value);
    return true;
  }

  function balanceOf(address _owner) constant returns (uint balance) {
    return balances[_owner];
  }

  function approve(address _spender, uint _value) returns (bool success) {
    allowed[msg.sender][_spender] = _value;
    Approval(msg.sender, _spender, _value);
    return true;
  }

  function allowance(address _owner, address _spender) constant returns (uint remaining) {
    return allowed[_owner][_spender];
  }

}

contract Lockable is Ownable {
    bool donationLock;

    function Lockable() {
        donationLock = false;
    }

    modifier onlyWhenDonationOpen {
        if (donationLock) throw;
        _;
    }

    function stopAcceptingDonation() onlyOwner {
        if (donationLock) throw;
        donationLock = true;
    }

    function startAcceptingDonation() onlyOwner {
        if (!donationLock) throw;
        donationLock = false;
    }
}

contract SmartPoolToken is StandardToken, Lockable {
    string public name = "SmartPool";
    string public symbol = "SPT";
    uint public decimals = 0;

    address public beneficial;
    mapping(address => uint) public donationAmountInWei;
    mapping(uint => address) public donors;
    uint public donorCount;
    uint public totalFundRaised;
    uint _rate;

    uint ETHER = 1 ether;

    event TokenMint(address newTokenHolder, uint tokensAmount);
    event Donated(address indexed from, uint amount, uint tokensAmount, uint blockNumber);

    function SmartPoolToken(uint preminedTokens, address wallet) {
        totalSupply = 0;
        _rate = 100;
        beneficial = wallet;
        totalFundRaised = 0;
        mintTokens(owner, safeMul(preminedTokens, ETHER / _rate));
    }

    function mintTokens(address newTokenHolder, uint weiAmount) internal returns (uint){
        uint tokensAmount = safeMul(_rate, weiAmount) / ETHER;

        if (tokensAmount >= 1) {
            balances[newTokenHolder] = safeAdd(
                balances[newTokenHolder], tokensAmount);
            totalSupply = safeAdd(totalSupply, tokensAmount);

            TokenMint(newTokenHolder, tokensAmount);
            return tokensAmount;
        }
        return 0;
    }

    function () payable onlyWhenDonationOpen {
        uint weiAmount = msg.value;
        if (weiAmount <= 0) throw;

        if (donationAmountInWei[msg.sender] == 0) {
            donors[donorCount] = msg.sender;
            donorCount += 1;
        }

        donationAmountInWei[msg.sender] = safeAdd(
            donationAmountInWei[msg.sender], weiAmount);
        totalFundRaised = safeAdd(
            totalFundRaised, weiAmount);
        uint tokensCreated = mintTokens(msg.sender, weiAmount);
        Donated(msg.sender, weiAmount, tokensCreated, block.number);
    }

    function getDonationAmount() constant returns (uint donation) {
        return donationAmountInWei[msg.sender];
    }

    function getTokenBalance() constant returns (uint tokens) {
        return balances[msg.sender];
    }

    function tokenRate() constant returns (uint tokenRate) {
        return _rate;
    }

    function changeRate(uint newRate) onlyOwner returns (bool success) {
        _rate = newRate;
        return true;
    }

    function withdraw() onlyOwner {
        if (!beneficial.send(this.balance)) {
            throw;
        }
    }
}