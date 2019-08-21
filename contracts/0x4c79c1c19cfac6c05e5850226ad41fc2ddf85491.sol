pragma solidity ^0.4.19;

contract StandardToken {
    function balanceOf(address _owner) constant public returns (uint256);
    function transfer(address _to, uint256 _value) public returns (bool);
}

library SafeMath {
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a / b;
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

interface Token { 
    function transfer(address _to, uint256 _value) public returns (bool);
    function totalSupply() constant public returns (uint256 supply);
    function balanceOf(address _owner) constant public returns (uint256 balance);
}

contract CslTokenDistribution {
    
    using SafeMath for uint256;
    mapping (address => uint256) balances;
    Token public cslToken;
    address public owner;
    uint256 public decimals = 10e17;      //token decimals
    uint256 public value = 50000;         //50000 tokens for 1 ETH
    uint256 public bonus = 5000;          //5000 tokens for 1 ETH
    uint256 public drop;                  //tokens for airdrop
    bool public contractLocked = true;    //crowdsale locked
    bool public bonusTime = true;         //bonus true for early investors
    
    event sendTokens(address indexed to, uint256 value);
    event Locked();
    event Unlocked();
    event Bonustimer();
    event NoBonustimer();

    function CslTokenDistribution(address _tokenAddress, address _owner) public {
        cslToken = Token(_tokenAddress);
        owner = _owner;
    }
    
    function transferOwnership(address newOwner) onlyOwner public {
        if (newOwner != address(0)) {
        owner = newOwner;
        }
    }
    
    function setAirdrop(uint256 _Drop) onlyOwner public {
        drop = _Drop;
    }
    
    function setCrowdsale(uint256 _value, uint256 _bonus) onlyOwner public {
        value = _value;
        bonus = _bonus;
    }
    
    modifier onlyOwner() {
        require(owner == msg.sender);
        _;
    }
    
    modifier isUnlocked() {
        require(!contractLocked);
        _;
    }
    
    function lockContract() onlyOwner public returns (bool) {
        contractLocked = true;
        Locked();
        return true;
    }
    
    function unlockContract() onlyOwner public returns (bool) {
        contractLocked = false;
        Unlocked();
        return false;
    }
    
    function bonusOn() onlyOwner public returns (bool) {
        bonusTime = true;
        Bonustimer();
        return true;
    }
    
    function bonusOff() onlyOwner public returns (bool) {
        bonusTime = false;
        NoBonustimer();
        return false;
    }

    function balanceOf(address _holder) constant public returns (uint256 balance) {
        return balances[_holder];
    }
    
    function getTokenBalance(address who) constant public returns (uint){
        uint bal = cslToken.balanceOf(who);
        return bal;
    }
    
    function getEthBalance(address _addr) constant public returns(uint) {
        return _addr.balance;
    }
    
    function airdrop(address[] addresses) onlyOwner public {
        
        require(addresses.length <= 255);
        
        for (uint i = 0; i < addresses.length; i++) {
            sendTokens(addresses[i], drop);
            cslToken.transfer(addresses[i], drop);
        }
	
    }
    
    function distribution(address[] addresses, uint256 amount) onlyOwner public {
        
        require(addresses.length <= 255);

        for (uint i = 0; i < addresses.length; i++) {
            sendTokens(addresses[i], amount);
            cslToken.transfer(addresses[i], amount);
        }

    }
    
    function distributeAmounts(address[] addresses, uint256[] amounts) onlyOwner public {

        require(addresses.length <= 255);
        require(addresses.length == amounts.length);
        
        for (uint8 i = 0; i < addresses.length; i++) {
            sendTokens(addresses[i], amounts[i]);
            cslToken.transfer(addresses[i], amounts[i]);
        }
        
    }
    
    function () external payable {
            getTokens();
    }
    
    function getTokens() payable isUnlocked public {
        address investor = msg.sender;
        uint256 weiAmount = msg.value;
        uint256 tokens = weiAmount.mul(value);
        
        if (msg.value == 0) { return; }
        if (bonusTime == true) {
            uint256 bonusTokens = weiAmount.mul(bonus);
            tokens = tokens.add(bonusTokens);
        }
        
        sendTokens(investor, tokens);
        cslToken.transfer(investor, tokens);
    
    }
    
    function tokensAvailable() constant public returns (uint256) {
        return cslToken.balanceOf(this);
    }
    
    function withdraw() onlyOwner public {
        uint256 etherBalance = this.balance;
        owner.transfer(etherBalance);
    }
    
    function withdrawStandardTokens(address _tokenContract) onlyOwner public returns (bool) {
        StandardToken token = StandardToken(_tokenContract);
        uint256 amount = token.balanceOf(address(this));
        return token.transfer(owner, amount);
    }

}