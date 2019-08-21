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
    ICO Блэк-рок
    - Эмиссия токенов ограничена (всего 10 000 000 токенов, токены не сгорают)
    - Цена токена фиксированная: 1 ETH = 3000 токенов
    - Минимальная и максимальная сумма покупки: 0.001 ETH и 100 ETH
    - Токенов на продажу на PreICO 2 000 000
    - Средства от покупки токенов лежат на контракте
    - Crowdsale ограничен по времени
    - Закрытие Crowdsale происходит с помощью функции `withdraw()`
    - `withdraw(false)` успешное завершение компании: управление токеном, не раскупленные токены и средства на контракте передаются бенефициару
    - `withdraw(true)` компания завершилась неудачей: управление токеном и не раскупленные токены передаются бенефициару, открывается возможность забрать вложенные средства `refund()`
    - Вкладчик может забрать свои средства вызовом функции `refund()` после неудачного завершение компании `withdraw(true)`
*/
contract Token is BurnableToken, Ownable {
    string public name = "RealStart Token";
    string public symbol = "RST";
    uint256 public decimals = 18;
    
    uint256 public INITIAL_SUPPLY = 10000000 * 1 ether;                             // Amount tokens

    function Token() {
        totalSupply = INITIAL_SUPPLY;
        balances[msg.sender] = INITIAL_SUPPLY;
    }
}

contract Crowdsale is Pausable {
    using SafeMath for uint;

    Token public token;
    address public beneficiary = 0xe97be260bB25d84860592524E5086C07c3cb3C0c;        // Beneficiary

    uint public collectedWei;
    uint public refundedWei;
    uint public tokensSold;

    uint public tokensForSale = 2000000 * 1 ether;                                 // Amount tokens for sale
    uint public priceTokenWei = 1 ether / 2000;
    uint public priceTokenWeiPreICO = 333333333333333; // 1 ether / 3000;

    uint public startTime = 1513299600;                                             
    uint public endTime = 1517360399;                                               
    bool public crowdsaleFinished = false;
    bool public refundOpen = false;

    mapping(address => uint256) saleBalances; 

    event NewContribution(address indexed holder, uint256 tokenAmount, uint256 etherAmount);
    event Refunded(address indexed holder, uint256 etherAmount);
    event Withdraw();

    function Crowdsale() {
        token = new Token();
    }

    function() payable {
        purchase();
    }
    
    /// @dev Test purchase: new Crowdsale(); $0.purchase()(10); new $0.token.Token(); $2.balanceOf(@0) == 2e+22
    /// @dev Test min purchase: new Crowdsale(); !$0.purchase()(0.0009); $0.purchase()(0.001)
    /// @dev Test max purchase: new Crowdsale(); !$0.purchase()(10001); $0.purchase()(10000)
    function purchase() whenNotPaused payable {
        require(!crowdsaleFinished);
        require(now >= startTime && now < endTime);
        require(tokensSold < tokensForSale);
        require(msg.value >= 0.001 * 1 ether && msg.value <= 100 * 1 ether);

        uint sum = msg.value;
        uint amount = sum.div(priceTokenWeiPreICO).mul(1 ether);
        uint retSum = 0;
        
        if(tokensSold.add(amount) > tokensForSale) {
            uint retAmount = tokensSold.add(amount).sub(tokensForSale);
            retSum = retAmount.mul(priceTokenWeiPreICO).div(1 ether);

            amount = amount.sub(retAmount);
            sum = sum.sub(retSum);
        }

        tokensSold = tokensSold.add(amount);
        collectedWei = collectedWei.add(sum);
        saleBalances[msg.sender] = saleBalances[msg.sender].add(sum);

        token.transfer(msg.sender, amount);

        if(retSum > 0) {
            msg.sender.transfer(retSum);
        }

        NewContribution(msg.sender, amount, sum);
    }

    /// @dev Test withdraw: new Crowdsale(); $0.purchase()(1000); $0.purchase()(1000)[1]; $0.withdraw(false); new $0.token.Token(); $4.owner() == @5
    function withdraw(bool refund) onlyOwner {
        require(!crowdsaleFinished);

        if(token.balanceOf(this) > 0) {
            token.transfer(beneficiary, token.balanceOf(this));
        }

        if(refund && tokensSold < tokensForSale) {
            refundOpen = true;
        }
        else {
            beneficiary.transfer(this.balance);
        }
        
        token.transferOwnership(beneficiary);
        crowdsaleFinished = true;

        Withdraw();
    }
    
    function refund() {
        require(crowdsaleFinished);
        require(refundOpen);
        require(saleBalances[msg.sender] > 0);

        uint sum = saleBalances[msg.sender];

        saleBalances[msg.sender] = 0;
        refundedWei = refundedWei.add(sum);

        msg.sender.transfer(sum);
        
        Refunded(msg.sender, sum);
    }
}