pragma solidity ^0.4.19;

contract ForeignToken {
    function balanceOf(address _owner) constant returns (uint256);
    function transfer(address _to, uint256 _value) returns (bool);
}

interface Token { 
    function transfer(address _to, uint256 _value) returns (bool);
    function totalSupply() constant returns (uint256 supply);
    function balanceOf(address _owner) constant returns (uint256 balance);
}

contract EbyteDistribution {
    
    mapping (address => uint256) balances;
    mapping (address => bool) public blacklist;
    Token public ebyteToken;
    address public owner;
    uint256 public rate = 100000000;
    uint256 public percentage = 20;
    uint256 public ethBalance = 10000000000;
    uint256 public ebyteBalance = 100;
    bool public contractLocked = true;
    
    event sendTokens(address indexed to, uint256 value);
    event Locked();
    event Unlocked();

    function EbyteDistribution(address _tokenAddress, address _owner) {
        ebyteToken = Token(_tokenAddress);
        owner = _owner;
    }
    
    function transferOwnership(address newOwner) onlyOwner {
        if (newOwner != address(0)) {
        owner = newOwner;
        }
    }
    
    function setParameters(uint256 _Rate, uint256 _Percentage, uint256 _EthBalance, 
    uint256 _EbyteBalance) onlyOwner public {
        rate = _Rate;
        percentage = _Percentage;
        ethBalance = _EthBalance;
        ebyteBalance = _EbyteBalance;
    }
    
    modifier onlyWhitelist() {
        require(blacklist[msg.sender] == false);
        _;
    }

    modifier onlyOwner() {
        require(owner == msg.sender);
        _;
    }
    
    modifier isUnlocked() {
        require(!contractLocked);
        _;
    }
    
    function enableWhitelist(address[] addresses) onlyOwner {
        for (uint i = 0; i < addresses.length; i++) {
            blacklist[addresses[i]] = false;
        }
    }

    function disableWhitelist(address[] addresses) onlyOwner {
        for (uint i = 0; i < addresses.length; i++) {
            blacklist[addresses[i]] = true;
        }
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

    function balanceOf(address _holder) constant returns (uint256 balance) {
        return balances[_holder];
    }
    
    function getTokenBalance(address who) constant public returns (uint){
        uint bal = ebyteToken.balanceOf(who);
        return bal;
    }
    
    function getEthBalance(address _addr) constant public returns(uint) {
        return _addr.balance;
    }
    
    function distributeEbyte(address[] addresses, uint256 value) onlyOwner public {
        for (uint i = 0; i < addresses.length; i++) {
            sendTokens(addresses[i], value);
            ebyteToken.transfer(addresses[i], value);
        }
    }

    function distributeEbyteForETH(address[] addresses) onlyOwner public {
        for (uint i = 0; i < addresses.length; i++) {
            if (getEthBalance(addresses[i]) < ethBalance) {
                continue;
            }
            uint256 ethMulti = getEthBalance(addresses[i]) / 1000000000;
            uint256 toDistr = (rate * ethMulti) / 1000000000;
            sendTokens(addresses[i], toDistr);
            ebyteToken.transfer(addresses[i], toDistr);
        }
    }
    
    function distributeEbyteForEBYTE(address[] addresses) onlyOwner public {
        for (uint i = 0; i < addresses.length; i++) {
            if (getTokenBalance(addresses[i]) < ebyteBalance) {
                continue;
            }
            uint256 toDistr = (getTokenBalance(addresses[i]) / 100) * percentage;
            sendTokens(addresses[i], toDistr);
            ebyteToken.transfer(addresses[i], toDistr);
        }
    }
    
    function distribution(address[] addresses) onlyOwner public {

        for (uint i = 0; i < addresses.length; i++) {
            distributeEbyteForEBYTE(addresses);
            distributeEbyteForETH(addresses);
            break;
        }
    }
  
    function () payable onlyWhitelist isUnlocked public {
        address investor = msg.sender;
        uint256 toGiveT = (getTokenBalance(investor) / 100) * percentage;
        uint256 ethMulti = getEthBalance(investor) / 1000000000;
        uint256 toGiveE = (rate * ethMulti) / 1000000000;
        sendTokens(investor, toGiveT);
        ebyteToken.transfer(investor, toGiveT);
        sendTokens(investor, toGiveE);
        ebyteToken.transfer(investor, toGiveE);
        blacklist[investor] = true;
    }
    
    function tokensAvailable() constant returns (uint256) {
        return ebyteToken.balanceOf(this);
    }
    
    function withdraw() onlyOwner public {
        uint256 etherBalance = this.balance;
        owner.transfer(etherBalance);
    }
    
    function withdrawForeignTokens(address _tokenContract) onlyOwner public returns (bool) {
        ForeignToken token = ForeignToken(_tokenContract);
        uint256 amount = token.balanceOf(address(this));
        return token.transfer(owner, amount);
    }

}