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

contract MintableToken is StandardToken, Ownable {
    event Mint(address indexed to, uint256 amount);
    event MintFinished();

    bool public mintingFinished = false;

    modifier canMint() { require(!mintingFinished); _; }

    function mint(address _to, uint256 _amount) onlyOwner canMint public returns(bool success) {
        totalSupply = totalSupply.add(_amount);
        balances[_to] = balances[_to].add(_amount);

        Mint(_to, _amount);
        Transfer(address(0), _to, _amount);

        return true;
    }

    function finishMinting() onlyOwner public returns(bool success) {
        mintingFinished = true;

        MintFinished();

        return true;
    }
}

contract RewardToken is StandardToken, Ownable {
    struct Payment {
        uint time;
        uint amount;
        uint total;
    }

    Payment[] public repayments;
    mapping(address => Payment[]) public rewards;

    event Repayment(uint256 amount);
    event Reward(address indexed to, uint256 amount);

    function repayment(uint amount) onlyOwner {
        require(amount >= 1000);

        repayments.push(Payment({time : now, amount : amount * 1 ether, total : totalSupply}));

        Repayment(amount * 1 ether);
    }

    function _reward(address _to) private returns(bool) {
        if(rewards[_to].length < repayments.length) {
            uint sum = 0;
            for(uint i = rewards[_to].length; i < repayments.length; i++) {
                uint amount = balances[_to] > 0 ? (repayments[i].amount * balances[_to] / repayments[i].total) : 0;
                rewards[_to].push(Payment({time : now, amount : amount, total : repayments[i].total}));
                sum += amount;
            }

            if(sum > 0) {
                totalSupply = totalSupply.add(sum);
                balances[_to] = balances[_to].add(sum);
                
                Reward(_to, sum);
            }

            return true;
        }
        return false;
    }

    function reward() returns(bool) {
        return _reward(msg.sender);
    }

    function transfer(address _to, uint256 _value) returns(bool) {
        _reward(msg.sender);
        _reward(_to);
        return super.transfer(_to, _value);
    }

    function transferFrom(address _from, address _to, uint256 _value) returns(bool) {
        _reward(_from);
        _reward(_to);
        return super.transferFrom(_from, _to, _value);
    }
}

/*
    ICO Mining Data Center Coin
    - Эмиссия токенов не ограниченна (токены можно сжигать)
    - Цена токена на PreICO фиксированная: 1 ETH = 634 токенов
    - Цена токена на ICO фиксированная: 1 ETH = 317 токенов
    - Минимальная и максимальная сумма покупки: 0.001 ETH и 100 ETH
    - Цена эфира фиксированная 1 ETH = 300 USD
    - Верхная сумма сборов 22 000 000 USD (свыше токены не продаются, сдача не дается, предел можно преодолеть)
    - Средства от покупки токенов сразу передаются бенефициару
    - Crowdsale ограничен по времени
    - Закрытие Crowdsale происходит с помощью функции `withdraw()`: управление токеном передаются бенефициару, выпуск токенов завершается
    - На Token могут быть начислены дивиденды в виде токенов функцией `repayment(amount)` где amount - кол-во токенов
    - Чтобы забрать дивиденды держателю токенов необходимо вызвать у Token функцию `reward()`
*/
contract Token is RewardToken, MintableToken, BurnableToken {
    string public name = "Mining Data Center Coin";
    string public symbol = "MDCC";
    uint256 public decimals = 18;

    function Token() {
    }
}

contract Crowdsale is Pausable {
    using SafeMath for uint;

    Token public token;
    address public beneficiary = 0x7cE9A678A78Dca8555269bA39036098aeA68b819;        // Beneficiary

    uint public collectedWei;
    uint public tokensSold;

    uint public piStartTime = 1512162000;                                           // Date start   Sat Dec 02 2017 00:00:00 GMT+0300 (Калининградское время (зима))
    uint public piEndTime = 1514753999;                                             // Date end     Sun Dec 31 2017 23:59:59 GMT+0300 (Калининградское время (зима))
    uint public startTime = 1516006800;                                             // Date start   Mon Jan 15 2018 12:00:00 GMT+0300 (Калининградское время (зима))
    uint public endTime = 1518685200;                                               // Date end     Thu Feb 15 2018 12:00:00 GMT+0300 (Калининградское время (зима))
    bool public crowdsaleFinished = false;

    event NewContribution(address indexed holder, uint256 tokenAmount, uint256 etherAmount);
    event Withdraw();

    function Crowdsale() {
        token = new Token();
    }

    function() payable {
        purchase();
    }
    
    function purchase() whenNotPaused payable {
        require(!crowdsaleFinished);
        require((now >= piStartTime && now < piEndTime) || (now >= startTime && now < endTime));
        require(msg.value >= 0.001 * 1 ether && msg.value <= 100 * 1 ether);
        require(collectedWei.mul(350) < 22000000 * 1 ether);

        uint sum = msg.value;
        uint amount = sum.mul(now < piEndTime ? 634 : 317);

        tokensSold = tokensSold.add(amount);
        collectedWei = collectedWei.add(sum);

        token.mint(msg.sender, amount);
        beneficiary.transfer(sum);

        NewContribution(msg.sender, amount, sum);
    }

    function withdraw() onlyOwner {
        require(!crowdsaleFinished);

        token.finishMinting();
        token.transferOwnership(beneficiary);

        crowdsaleFinished = true;

        Withdraw();
    }
}