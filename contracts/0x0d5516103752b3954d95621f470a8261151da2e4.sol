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

/*
    ICO Bloomzed Token
    - Эмиссия токенов ограничена (всего 100 000 000 токенов, токены выпускаются во время ICO и PreICO)
    - Цена токена фиксированная: 1 ETH = 500 токенов
    - Токенов на продажу 50 000 000 (50%)
    - 50 000 000 (50%) токенов передается команде во время создания токена
    - Бонусы на PreICO: +50% токенов
    - Бонусы на ICO: +25% первый день, +20% с 2 по 3 день, +15% с 4 по 5 день, +10% с 6 по 7 день, +7% с 8 по 9 день, +5% с 10 по 11 день
    - Бонусы на ICO: +3% при покупке >= 3 000 токенов, +5% при покупке > 5 000 токенов, +7% при покупке > 10 000 токенов, +10% при покупке > 15 000 токенов
    - Бонусы расчитываются на начальную сумму, бонусы сумируются
    - Минимальная и максимальная сумма покупки: 0.5 ETH и 10000 ETH
    - Средства от покупки токенов передаются бенефициару
    - Crowdsale ограничен по времени
    - Закрытие Crowdsale происходит с помощью функции "withdraw()", минтинг закрывается, управление токеном передаются бенефициару
*/
contract Token is BurnableToken, MintableToken {
    string public name = "Bloomzed Token";
    string public symbol = "BZT";
    uint256 public decimals = 18;

    function Token() {
        mint(0x3c64B86cEE4E60EDdA517521b46Ac74134442058, 50000000 * 1 ether);       // Command mint
    }
}

contract Crowdsale is Pausable {
    using SafeMath for uint;

    Token public token;
    address public beneficiary = 0x86fABfdBB9B5BFDbec3975aECdDee54b28bDeA45;        // Beneficiary
    address public manager = 0xD9e4a8fCb4357Dfd14861Bc9E4170e43C14062A4;            // Manager

    uint public collectedWei;
    uint public tokensSold;

    uint public priceTokenWei = 1 ether / 500;

    uint public piTokensForSale = 5000000 * 1 ether;                                // Amount tokens for sale on PreICO
    uint public tokensForSale = 50000000 * 1 ether;                                 // Amount tokens for sale

    uint public piStartTime = 1513674000;                                           // Date start   19.12.2017 12:00 +03
    uint public piEndTime = 1514278800;                                             // Date end     26.12.2017 12:00 +03
    uint public startTime = 1516179600;                                             // Date start   17.01.2018 12:00 +03
    uint public endTime = 1518858000;                                               // Date end     17.02.2018 12:00 +03
    bool public crowdsaleFinished = false;

    event NewContribution(address indexed holder, uint256 tokenAmount, uint256 etherAmount);
    event Withdraw();

    modifier onlyManager() { require(msg.sender == manager); _; }

    function Crowdsale() {
        token = new Token();
    }

    function() payable {
        purchase();
    }
    
    function purchase() whenNotPaused payable {
        require(!crowdsaleFinished);
        require((now >= piStartTime && now < piEndTime && tokensSold < piTokensForSale) || (now >= startTime && now < endTime));
        require(tokensSold < tokensForSale);
        require(msg.value >= 0.5 * 1 ether && msg.value <= 10000 * 1 ether);

        uint sum = msg.value;
        uint amount = sum.div(priceTokenWei).mul(1 ether);
        uint retSum = 0;

        // ICO
        if(now > piEndTime) {
            uint bonus = 0;

            // Day bonus
            if(tokensSold.add(amount) < piTokensForSale) {
                bonus.add(
                    now < startTime + 1 days ? 25
                        : (now < startTime + 3 days ? 20
                            : (now < startTime + 5 days ? 15
                                : (now < startTime + 7 days ? 10
                                    : (now < startTime + 9 days ? 7
                                        : (now < startTime + 11 days ? 5 : 0
                ))))));

                // Amount bonus
                if(amount >= 3000 * 1 ether) {
                    bonus.add(
                        amount > 15000 * 1 ether ? 10 : 
                            (amount > 10000 * 1 ether ? 7 : 
                                (amount > 5000 * 1 ether ? 5 : 3
                    )));
                }
            }

            if(bonus > 0) {
                amount = amount.add(amount.div(100).mul(bonus));
            }

            if(tokensSold.add(amount) > piTokensForSale) {
                uint retAmount = tokensSold.add(amount).sub(piTokensForSale);
                retSum = retAmount.mul(price).div(1 ether);

                amount = amount.sub(retAmount);
                sum = sum.sub(retSum);
            }
        }
        // PreICO
        else {
            uint price = priceTokenWei.mul(100).div(150);
            amount = sum.div(price).mul(1 ether);
            
            if(tokensSold.add(amount) > piTokensForSale) {
                retAmount = tokensSold.add(amount).sub(piTokensForSale);
                retSum = retAmount.mul(price).div(1 ether);

                amount = amount.sub(retAmount);
                sum = sum.sub(retSum);
            }
        }

        tokensSold = tokensSold.add(amount);
        collectedWei = collectedWei.add(sum);

        beneficiary.transfer(sum);
        token.mint(msg.sender, amount);

        if(retSum > 0) {
            msg.sender.transfer(retSum);
        }

        NewContribution(msg.sender, amount, sum);
    }

    function externalPurchase(address _to, uint _value) whenNotPaused onlyManager {
        require(!crowdsaleFinished);
        require(tokensSold < tokensForSale);

        uint amount = _value.mul(1 ether);

        tokensSold = tokensSold.add(amount);

        token.mint(_to, amount);

        NewContribution(_to, amount, 0);
    }

    function withdraw() onlyOwner {
        require(!crowdsaleFinished);
        
        token.finishMinting();
        token.transferOwnership(beneficiary);

        crowdsaleFinished = true;

        Withdraw();
    }
}