/*! gbcoin.sol | (c) 2017 Develop by BelovITLab, autor my.life.cookie | License: MIT */

/*
    О нас:

    Наша GB Systems состоит из нескольких банков, расположенных на территории Евросоюза, России, 
    так же будет открыт банк на территории Соединенных Штатов Америки, а так же в скором времени 
    наши ряды пополнит банк из Китая. Наша финансовая система постоянно развивается и стремится 
    для усовершенствования для наших клиентов. Для этого мы воссоединились в одну крупную мировую 
    финансовую сеть, которая может предоставлять для наших клиентов и людей банковские услуги всех 
    направлений, свою валюту GBCoin,  криптовалютную фондовую биржу GBMarkets - где каждый человек, 
    либо профессиональный трейдер, сможет увеличить свой капитал, путем торговли на бирже. 
    
    Для удобство так же мы создаем холодный кошелек GB Wallet со всеми услугами платежной системы. 
    Еще для увеличения капитала для клиентов, мы создаем GB Fund, где по доверительному управлению, 
    клиенту можно зарабатывать неплохие проценты, начисляемые раз в месяц, над этим будут трудиться 
    наши профессиональные трейдеры. Наша финансовая система   постоянно  с каждым месяцем 
    увеличивается, далее в последующем будут открываться  офисы в разных странах, что позволит 
    воспользоваться  нашими услугами гражданину той или иной страны. Наши услуги лояльны ко всем 
    нашим клиентам. Мы предоставляем потребительские кредиты, автокредитование, ипотечное 
    кредитование, под минимальные проценты, открывает депозитные и инвестиционные вклады, вклады 
    на доверительное управление, страхование с большими возможностями, обменник валют, платежная 
    система, так же можно будет  оплачивать нашей криптовалютой GBCoin услуги такси в разных странах, 
    оплачивать за туристические путевки у туроператоров,  По системе лояльности иметь возможность 
    получать скидки и cash back в продуктовых магазинах партнеров и многое другое. 
    
    С нами вы будете иметь все в одной системе и не нужно будет обращаться в сторонние структуры. 
    Удобство и Качество для всех клиентов. 
*/

pragma solidity ^0.4.18;

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
    uint public MAX_SUPPLY;

    modifier canMint() { require(!mintingFinished); _; }

    function mint(address _to, uint256 _amount) onlyOwner canMint public returns(bool success) {
        require(totalSupply.add(_amount) <= MAX_SUPPLY);

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
    ICO GBCoin
    - Эмиссия токенов ограничена (всего 40 000 000 токенов, токены выпускаются во время Crowdsale)
    - Цена токена во время старта: 1 ETH = 20 токенов (1 Eth (~500$) / 20 = ~25$) (цену можно изменить во время ICO)
    - Минимальная и максимальная сумма покупки: 1 ETH и 10 000 ETH
    - Токенов на продажу 20 000 000 (50%)
    - 20 000 000 (50%) токенов передается бенефициару во время создания токена
    - Средства от покупки токенов передаются бенефициару
    - Закрытие Crowdsale происходит с помощью функции `withdraw()`:нераскупленные токены и управление токеном передаётся бенефициару, выпуск токенов закрывается
    - Измение цены токена происходет функцией `setTokenPrice(_value)`, где `_value` - кол-во токенов покумаемое за 1 Ether, смена стоимости токена доступно только во время паузы администратору, после завершения Crowdsale функция становится недоступной
*/
contract Token is BurnableToken, MintableToken {
    string public name = "GBCoin";
    string public symbol = "GBCN";
    uint256 public decimals = 18;

    function Token() {
        MAX_SUPPLY = 40000000 * 1 ether;                                            // Maximum amount tokens
        mint(0xF59125FCB92bBB364e7F3c106E9BAEb8b4bB69B0, 20000000 * 1 ether);       
    }
}

contract Crowdsale is Pausable {
    using SafeMath for uint;

    Token public token;
    address public beneficiary = 0xF59125FCB92bBB364e7F3c106E9BAEb8b4bB69B0;        

    uint public collectedWei;
    uint public tokensSold;

    uint public tokensForSale = 20000000 * 1 ether;                                 // Amount tokens for sale
    uint public priceTokenWei = 1 ether / 20;                                       // 1 Eth (~500$) / 20 = ~25$

    bool public crowdsaleFinished = false;

    event NewContribution(address indexed holder, uint256 tokenAmount, uint256 etherAmount);
    event Withdraw();

    function Crowdsale() {
        token = new Token();
    }

    function() payable {
        purchase();
    }

    function setTokenPrice(uint _value) onlyOwner whenPaused {
        require(!crowdsaleFinished);
        priceTokenWei = 1 ether / _value;
    }
    
    function purchase() whenNotPaused payable {
        require(!crowdsaleFinished);
        require(tokensSold < tokensForSale);
        require(msg.value >= 1 ether && msg.value <= 10000 * 1 ether);

        uint sum = msg.value;
        uint amount = sum.div(priceTokenWei).mul(1 ether);
        uint retSum = 0;
        
        if(tokensSold.add(amount) > tokensForSale) {
            uint retAmount = tokensSold.add(amount).sub(tokensForSale);
            retSum = retAmount.mul(priceTokenWei).div(1 ether);

            amount = amount.sub(retAmount);
            sum = sum.sub(retSum);
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

    function withdraw() onlyOwner {
        require(!crowdsaleFinished);
        
        if(tokensForSale.sub(tokensSold) > 0) {
            token.mint(beneficiary, tokensForSale.sub(tokensSold));
        }

        token.finishMinting();
        token.transferOwnership(beneficiary);

        crowdsaleFinished = true;

        Withdraw();
    }

    function balanceOf(address _owner) constant returns(uint256 balance) {
        return token.balanceOf(_owner);
    }
}