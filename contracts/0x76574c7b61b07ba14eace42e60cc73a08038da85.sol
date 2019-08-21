/*! all.me.sol | (c) 2017 Develop by BelovITLab, autor my.life.cookie | License: MIT */

pragma solidity 0.4.18;

library SafeMath {
    function mul(uint256 a, uint256 b) internal pure returns(uint256) {
        if(a == 0) {
            return 0;
        }
        uint256 c = a * b;
        assert(c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns(uint256) {
        uint256 c = a / b;
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns(uint256) {
        assert(b <= a);
        return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns(uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }
}

contract Ownable {
    address public owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    modifier onlyOwner() { require(msg.sender == owner); _; }

    function Ownable() public {
        owner = msg.sender;
    }

    function transferOwnership(address newOwner) public onlyOwner {
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

    function pause() onlyOwner whenNotPaused public {
        paused = true;
        Pause();
    }

    function unpause() onlyOwner whenPaused public {
        paused = false;
        Unpause();
    }
}

contract ERC20 {
    uint256 public totalSupply;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    function balanceOf(address who) public view returns(uint256);
    function transfer(address to, uint256 value) public returns(bool);
    function transferFrom(address from, address to, uint256 value) public returns(bool);
    function allowance(address owner, address spender) public view returns(uint256);
    function approve(address spender, uint256 value) public returns(bool);
}

contract StandardToken is ERC20 {
    using SafeMath for uint256;

    mapping(address => uint256) balances;
    mapping (address => mapping (address => uint256)) internal allowed;

    function balanceOf(address _owner) public view returns(uint256 balance) {
        return balances[_owner];
    }

    function transfer(address _to, uint256 _value) public returns(bool) {
        require(_to != address(0));
        require(_value <= balances[msg.sender]);

        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);

        Transfer(msg.sender, _to, _value);

        return true;
    }
    
    function multiTransfer(address[] _to, uint256[] _value) public returns(bool) {
        require(_to.length == _value.length);

        for(uint i = 0; i < _to.length; i++) {
            transfer(_to[i], _value[i]);
        }

        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns(bool) {
        require(_to != address(0));
        require(_value <= balances[_from]);
        require(_value <= allowed[_from][msg.sender]);

        balances[_from] = balances[_from].sub(_value);
        balances[_to] = balances[_to].add(_value);
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);

        Transfer(_from, _to, _value);

        return true;
    }

    function allowance(address _owner, address _spender) public view returns(uint256) {
        return allowed[_owner][_spender];
    }

    function approve(address _spender, uint256 _value) public returns(bool) {
        allowed[msg.sender][_spender] = _value;

        Approval(msg.sender, _spender, _value);

        return true;
    }

    function increaseApproval(address _spender, uint _addedValue) public returns(bool) {
        allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);

        Approval(msg.sender, _spender, allowed[msg.sender][_spender]);

        return true;
    }

    function decreaseApproval(address _spender, uint _subtractedValue) public returns(bool) {
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

contract MintableToken is StandardToken, Ownable {
    event Mint(address indexed to, uint256 amount);
    event MintFinished();

    bool public mintingFinished = false;

    modifier canMint() { require(!mintingFinished); _; }

    function mint(address _to, uint256 _amount) onlyOwner canMint public returns(bool) {
        totalSupply = totalSupply.add(_amount);
        balances[_to] = balances[_to].add(_amount);

        Mint(_to, _amount);
        Transfer(address(0), _to, _amount);

        return true;
    }

    function finishMinting() onlyOwner canMint public returns(bool) {
        mintingFinished = true;

        MintFinished();

        return true;
    }
}

contract CappedToken is MintableToken {
    uint256 public cap;

    function CappedToken(uint256 _cap) public {
        require(_cap > 0);
        cap = _cap;
    }

    function mint(address _to, uint256 _amount) onlyOwner canMint public returns(bool) {
        require(totalSupply.add(_amount) <= cap);

        return super.mint(_to, _amount);
    }
}

contract Manageable is Ownable {
    mapping(address => bool) public managers;

    event ManagerAdded(address indexed manager);
    event ManagerRemoved(address indexed manager);

    modifier onlyManager() { require(managers[msg.sender]); _; }

    function addManager(address _manager) onlyOwner public {
        require(_manager != address(0));

        managers[_manager] = true;

        ManagerAdded(_manager);
    }

    function removeManager(address _manager) onlyOwner public {
        require(_manager != address(0));

        managers[_manager] = false;

        ManagerRemoved(_manager);
    }
}

/*
    ICO All.me
    - Эмиссия токенов ограничена (всего 10 000 000 000 токенов, токены выпускаются во время Crowdsale)
    - Цена токена во время старта: 1 ETH = 200 токенов (цену можно изменить во время ICO)
    - Минимальная сумма покупки: 0.001 ETH
    - Токенов на продажу 7 000 000 000
    - Отправляем бенефициару 3 000 000 000 токенов во время создания токена
    - Средства от покупки токенов передаются бенефициару
    - Закрытие Crowdsale происходит с помощью функции `withdraw()`: управление токеном передаётся бенефициару
    - Измение цены токена происходет функцией `setTokenPrice(_value)`, где `_value` - кол-во токенов покумаемое за 1 Ether, смена стоимости токена доступно только во время паузы администратору, после завершения Crowdsale функция становится недоступной
*/
contract Token is CappedToken {
    string public name = "ALL.ME";
    string public symbol = "ME";
    uint256 public decimals = 18;

    function Token() CappedToken(10000000000 * 1 ether) public {                    // Maximum amount tokens
    
    }
}

contract Crowdsale is Pausable, Manageable {
    using SafeMath for uint;

    Token public token;
    address public beneficiary = 0x170cAb2d8987643fB689d9047e21bd1A70716e92;        // Beneficiary

    uint public collectedWei;
    uint public tokensSold;

    uint public tokensForSale = 7000000000 * 1 ether;                               // Amount tokens for sale
    uint public priceTokenWei = 1 ether / 200;                                      // Start token price

    bool public crowdsaleFinished = false;

    event NewContribution(address indexed holder, uint256 tokenAmount, uint256 etherAmount);
    event CrowdsaleClose();

    function Crowdsale() public {
        token = new Token();

        token.mint(0xD7e85ce02C4446Aa87E2d155189C28E07C6C06a0, 3000000000 * 1 ether);

        addManager(0x7Eada7e60bd714d1a38d9ab329b85D0c75334814);                     // Manager
    }

    function() payable public {
        purchase();
    }

    function setTokenPrice(uint _value) onlyOwner whenPaused public {
        require(!crowdsaleFinished);
        priceTokenWei = 1 ether / _value;
    }
    
    function purchase() whenNotPaused payable public {
        require(!crowdsaleFinished);
        require(tokensSold < tokensForSale);
        require(msg.value >= 0.001 ether);

        uint sum = msg.value;
        uint amount = sum.mul(1 ether).div(priceTokenWei);
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

    function externalPurchase(address _to, uint _value) whenNotPaused onlyManager public {
        require(!crowdsaleFinished);
        require(tokensSold.add(_value) <= tokensForSale);

        tokensSold = tokensSold.add(_value);

        token.mint(_to, _value);

        NewContribution(_to, _value, 0);
    }

    function closeCrowdsale() onlyOwner public {
        require(!crowdsaleFinished);
        
        token.transferOwnership(beneficiary);

        crowdsaleFinished = true;

        CrowdsaleClose();
    }

    function balanceOf(address _owner) public view returns(uint256 balance) {
        return token.balanceOf(_owner);
    }
}