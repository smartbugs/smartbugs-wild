pragma solidity ^0.4.13;

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
  address public owner;


  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  function Ownable() {
    owner = msg.sender;
  }


  /**
   * @dev Throws if called by any account other than the owner.
   */
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }


  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param newOwner The address to transfer ownership to.
   */
  function transferOwnership(address newOwner) onlyOwner {
    require(newOwner != address(0));      
    OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }

}

/*
 * Базовый контракт, который поддерживает остановку продаж
 */

contract Haltable is Ownable {
    bool public halted;

    modifier stopInEmergency {
        require(!halted);
        _;
    }

    /* Модификатор, который вызывается в потомках */
    modifier onlyInEmergency {
        require(halted);
        _;
    }

    /* Вызов функции прервет продажи, вызывать может только владелец */
    function halt() external onlyOwner {
        halted = true;
    }

    /* Вызов возвращает режим продаж */
    function unhalt() external onlyOwner onlyInEmergency {
        halted = false;
    }

}

/**
 * @title ERC20Basic
 * @dev Simpler version of ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/179
 */
contract ERC20Basic {
uint256 public totalSupply;
function balanceOf(address who) constant returns (uint256);
function transfer(address to, uint256 value) returns (bool);
event Transfer(address indexed from, address indexed to, uint256 value);
}

/**
 * Интерфейс контракта токена
 */

contract ImpToken is ERC20Basic {
    function decimals() public returns (uint) {}
}

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {
  function mul(uint256 a, uint256 b) internal constant returns (uint256) {
    uint256 c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal constant returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  function sub(uint256 a, uint256 b) internal constant returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal constant returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}

/* Контракт продаж */

contract Sale is Haltable {
    using SafeMath for uint;

    /* Токен, который продаем */
    ImpToken public impToken;

    /* Собранные средства будут переводиться сюда */
    address public destinationWallet;

    /*  Сколько сейчас стоит 1 IMP в wei */
    uint public oneImpInWei;

    /*  Минимальное кол-во токенов, которое можно продать */
    uint public minBuyTokenAmount;

    /*  Максимальное кол-во токенов, которое можно купить за 1 раз */
    uint public maxBuyTokenAmount;

    /* Событие покупки токена */
    event Invested(address receiver, uint weiAmount, uint tokenAmount);

    /* Конструктор */
    function Sale(address _impTokenAddress, address _destinationWallet) {
        require(_impTokenAddress != 0);
        require(_destinationWallet != 0);

        impToken = ImpToken(_impTokenAddress);

        destinationWallet = _destinationWallet;
    }

    /**
     * Fallback функция вызывающаяся при переводе эфира
     */
    function() payable stopInEmergency {
        uint weiAmount = msg.value;
        address receiver = msg.sender;

        uint tokenMultiplier = 10 ** impToken.decimals();
        uint tokenAmount = weiAmount.mul(tokenMultiplier).div(oneImpInWei);

        require(tokenAmount > 0);

        require(tokenAmount >= minBuyTokenAmount && tokenAmount <= maxBuyTokenAmount);

        // Сколько осталось токенов на контракте продаж
        uint tokensLeft = getTokensLeft();

        require(tokensLeft > 0);

        require(tokenAmount <= tokensLeft);

        // Переводим токены инвестору
        assignTokens(receiver, tokenAmount);

        // Шлем на кошелёк эфир
        destinationWallet.transfer(weiAmount);

        // Вызываем событие
        Invested(receiver, weiAmount, tokenAmount);
    }

    /**
     * Адрес кошелька для сбора средств
     */
    function setDestinationWallet(address destinationAddress) external onlyOwner {
        destinationWallet = destinationAddress;
    }

    /**
     *  Минимальное кол-во токенов, которое можно продать
     */
    function setMinBuyTokenAmount(uint value) external onlyOwner {
        minBuyTokenAmount = value;
    }

    /**
     *  Максимальное кол-во токенов, которое можно продать
     */
    function setMaxBuyTokenAmount(uint value) external onlyOwner {
        maxBuyTokenAmount = value;
    }

    /**
     * Функция, которая задает текущий курс ETH в центах
     */
    function setOneImpInWei(uint value) external onlyOwner {
        require(value > 0);

        oneImpInWei = value;
    }

    /**
     * Перевод токенов покупателю
     */
    function assignTokens(address receiver, uint tokenAmount) private {
        impToken.transfer(receiver, tokenAmount);
    }

    /**
     * Возвращает кол-во нераспроданных токенов
     */
    function getTokensLeft() public constant returns (uint) {
        return impToken.balanceOf(address(this));
    }
}