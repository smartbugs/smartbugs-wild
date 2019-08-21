pragma solidity ^0.4.11;

library SafeMath {
    function mul(uint256 a, uint256 b) internal constant returns(uint256) {
        uint256 c = a * b;
        assert(a == 0 || c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) internal constant returns(uint256) {
        uint256 c = a / b;
        return c;
    }

    function sub(uint256 a, uint256 b) internal constant returns(uint256) {
        assert(b <= a);
        return a - b;
    }

    function add(uint256 a, uint256 b) internal constant returns(uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }
}

contract Ownable {
    address public owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    modifier onlyOwner() { require(msg.sender == owner); _; }

    function Ownable() {
        owner = msg.sender;
    }

    function transferOwnership(address newOwner) onlyOwner {
        require(newOwner != address(0));
        OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }
}

contract Pausable is Ownable {
    bool public paused = false;

    event Pause();
    event Unpause();

    modifier whenNotPaused() { require(!paused); _; }
    modifier whenPaused() { require(paused); _; }

    function pause() onlyOwner whenNotPaused {
        paused = true;
        Pause();
    }
    
    function unpause() onlyOwner whenPaused {
        paused = false;
        Unpause();
    }
}

contract ERC20 {
    uint256 public totalSupply;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    function balanceOf(address who) constant returns (uint256);
    function transfer(address to, uint256 value) returns (bool);
    function transferFrom(address from, address to, uint256 value) returns (bool);
    function allowance(address owner, address spender) constant returns (uint256);
    function approve(address spender, uint256 value) returns (bool);
}

contract StandardToken is ERC20 {
    using SafeMath for uint256;

    mapping(address => uint256) balances;
    mapping(address => mapping(address => uint256)) allowed;

    function balanceOf(address _owner) constant returns(uint256 balance) {
        return balances[_owner];
    }

    function transfer(address _to, uint256 _value) returns(bool success) {
        require(_to != address(0));

        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);

        Transfer(msg.sender, _to, _value);

        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) returns(bool success) {
        require(_to != address(0));

        var _allowance = allowed[_from][msg.sender];

        balances[_from] = balances[_from].sub(_value);
        balances[_to] = balances[_to].add(_value);
        allowed[_from][msg.sender] = _allowance.sub(_value);

        Transfer(_from, _to, _value);

        return true;
    }

    function allowance(address _owner, address _spender) constant returns(uint256 remaining) {
        return allowed[_owner][_spender];
    }

    function approve(address _spender, uint256 _value) returns(bool success) {
        require((_value == 0) || (allowed[msg.sender][_spender] == 0));

        allowed[msg.sender][_spender] = _value;

        Approval(msg.sender, _spender, _value);

        return true;
    }

    function increaseApproval(address _spender, uint _addedValue) returns(bool success) {
        allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);

        Approval(msg.sender, _spender, allowed[msg.sender][_spender]);

        return true;
    }

    function decreaseApproval(address _spender, uint _subtractedValue) returns(bool success) {
        uint oldValue = allowed[msg.sender][_spender];

        if(_subtractedValue > oldValue) {
            allowed[msg.sender][_spender] = 0;
        } else {
            allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
        }

        Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
        
        return true;
    }
}

contract BurnableToken is StandardToken {
    event Burn(address indexed burner, uint256 value);

    function burn(uint256 _value) public {
        require(_value > 0);

        address burner = msg.sender;
        balances[burner] = balances[burner].sub(_value);
        totalSupply = totalSupply.sub(_value);
        Burn(burner, _value);
    }
}

/*
    ICO Алтын
    - Эмиссия токенов ограничена (всего 100 000 000 токенов)
    - На Crowdsale продаются 22 000 000 токенов в 4 этапа, каждый этап ограничен по кол-ву токенов, цена токена на каждом этапе своя
    - Нижная граница сборов 300 000 USD (граница никак не ограничивают контракт)
    - Верхная граница сборов 5 500 000 USD (если граница достигнута токены больше не продаются, контракт дает сдачу если сумма больше)
    - ICO ограничено по времени дата начала 17.10.2017 продолжительность 45 дней.
    - Цена эфира 1 ETH = 300 USD, минимальная сумма инвестиций 0.03 USD
    - Закрытие ICO происходит с помощью функции "withdraw()", управление токеном передаются бенефициару, не раскупленные токены сгорают, токены не участвующие в продаже отправляются бенефициару
*/

contract ALTToken is BurnableToken, Ownable {
    string public name = "Altyn Token";
    string public symbol = "ALT";
    uint256 public decimals = 18;
    
    uint256 public INITIAL_SUPPLY = 100000000 * 1 ether;                                        // Amount tokens

    function ALTToken() {
        totalSupply = INITIAL_SUPPLY;
        balances[msg.sender] = INITIAL_SUPPLY;
    }
}

contract ALTCrowdsale is Pausable {
    using SafeMath for uint;

    struct Step {
        uint priceUSD;
        uint amountTokens;
    }

    ALTToken public token;
    address public beneficiary = 0x9df0be686E12ccdbE46D4177442878bf8636E89f;                    // Beneficiary

    uint public collected;
    uint public collectedUSD;
    uint public tokensSold;
    uint public maxTokensSold = 22000000 * 1 ether;                                             // Tokens for sale

    uint public priceETH = 300;                                                                 // Ether price USD
    uint public softCapUSD = 300000;                                                            // Soft cap USD
    uint public softCap = softCapUSD / priceETH * 1 ether;
    uint public hardCapUSD = 5500000;                                                           // Hard cap USD
    uint public hardCap = hardCapUSD / priceETH * 1 ether;

    Step[] steps;

    uint public startTime = 1508225824;                                                         // Date start 01.10.2017 00:00 +0
    uint public endTime = startTime + 45 days;                                                  // Date end +45 days
    bool public crowdsaleFinished = false;

    event SoftCapReached(uint256 etherAmount);
    event HardCapReached(uint256 etherAmount);
    event NewContribution(address indexed holder, uint256 tokenAmount, uint256 etherAmount);
    event Withdraw();

    modifier onlyAfter(uint time) { require(now > time); _; }
    modifier onlyBefore(uint time) {  require(now < time);  _; }

    function ALTCrowdsale() {
        token = new ALTToken();

        steps.push(Step(15, 2000000));                                                          // Step 1: 0.15$; 2 000 000 ALT tokens
        steps.push(Step(20, 5000000));                                                          // Step 2: 0.20$; +3 000 000 ALT tokens
        steps.push(Step(25, 15000000));                                                         // Step 3: 0.25$; +10 000 000 ALT tokens
        steps.push(Step(30, 22000000));                                                         // Step 4: 0.30$; +7 000 000 ALT tokens
    }

    function() payable {
        purchase();
    }
    
    function purchase() onlyAfter(startTime) onlyBefore(endTime) whenNotPaused payable {
        require(!crowdsaleFinished);
        require(msg.value >= 0.001 * 1 ether && msg.value <= 10000 * 1 ether);
        require(tokensSold < maxTokensSold);

        uint amount = 0;
        uint sum = 0;
        for(uint i = 0; i < steps.length; i++) {
            if(tokensSold.add(amount) < steps[i].amountTokens * 1 ether) {
                uint avail = (steps[i].amountTokens * 1 ether) - tokensSold.add(amount);
                uint nece = (msg.value - sum) * priceETH / steps[i].priceUSD * 100;
                uint buy = nece;

                if(buy > avail) buy = avail;
                
                amount += buy;
                sum += buy / (priceETH / steps[i].priceUSD * 100);

                if(buy == nece) break;
            }
        }
        
        require(tokensSold.add(amount) <= maxTokensSold);

        if(collected < softCap && collected.add(sum) >= softCap) {
            SoftCapReached(collected.add(sum));
        }

        collected = collected.add(sum);
        collectedUSD = collected * priceETH / 1 ether;
        tokensSold = tokensSold.add(amount);
        
        require(token.transfer(msg.sender, amount));
        if(sum < msg.value) require(msg.sender.send(msg.value - sum));

        NewContribution(msg.sender, amount, sum);

        if(collected >= hardCap) {
            HardCapReached(collected);
        }
    }

    function withdraw() onlyOwner {
        require(!crowdsaleFinished);

        beneficiary.transfer(collected);

        if(tokensSold < maxTokensSold) token.burn(maxTokensSold - tokensSold);
        token.transfer(beneficiary, token.balanceOf(this));
        
        token.transferOwnership(beneficiary);

        crowdsaleFinished = true;

        Withdraw();
    }
}