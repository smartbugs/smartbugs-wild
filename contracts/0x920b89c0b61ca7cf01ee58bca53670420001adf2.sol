pragma solidity ^0.4.24;

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
  address public owner;


  event OwnershipRenounced(address indexed previousOwner);
  event OwnershipTransferred(
    address indexed previousOwner,
    address indexed newOwner
  );


  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  constructor() public {
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
   * @dev Allows the current owner to relinquish control of the contract.
   * @notice Renouncing to ownership will leave the contract without an owner.
   * It will not be possible to call the functions with the `onlyOwner`
   * modifier anymore.
   */
  function renounceOwnership() public onlyOwner {
    emit OwnershipRenounced(owner);
    owner = address(0);
  }

  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param _newOwner The address to transfer ownership to.
   */
  function transferOwnership(address _newOwner) public onlyOwner {
    _transferOwnership(_newOwner);
  }

  /**
   * @dev Transfers control of the contract to a newOwner.
   * @param _newOwner The address to transfer ownership to.
   */
  function _transferOwnership(address _newOwner) internal {
    require(_newOwner != address(0));
    emit OwnershipTransferred(owner, _newOwner);
    owner = _newOwner;
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
 * Контракт лута
 */

contract ImpLoot is Haltable {

    struct TemplateState {
        uint weiAmount;
        mapping (address => address) owners;
    }

    address private destinationWallet;

    // Мапа id шаблона лута => стейт лута
    mapping (uint => TemplateState) private templatesState;

    // Событие покупки
    event Bought(address _receiver, uint _lootTemplateId, uint _weiAmount);

    constructor(address _destinationWallet) public {
        require(_destinationWallet != address(0));
        destinationWallet = _destinationWallet;
    }

    function buy(uint _lootTemplateId) payable stopInEmergency{
        uint weiAmount = msg.value;
        address receiver = msg.sender;

        require(destinationWallet != address(0));
        require(weiAmount != 0);
        require(templatesState[_lootTemplateId].owners[receiver] != receiver);
        require(templatesState[_lootTemplateId].weiAmount == weiAmount);

        templatesState[_lootTemplateId].owners[receiver] = receiver;

        destinationWallet.transfer(weiAmount);

        emit Bought(receiver, _lootTemplateId, weiAmount);
    }

    function getPrice(uint _lootTemplateId) constant returns (uint weiAmount) {
        return templatesState[_lootTemplateId].weiAmount;
    }

    function setPrice(uint _lootTemplateId, uint _weiAmount) external onlyOwner {
        templatesState[_lootTemplateId].weiAmount = _weiAmount;
    }

    function isOwner(uint _lootTemplateId, address _owner) constant returns (bool isOwner){
        return templatesState[_lootTemplateId].owners[_owner] == _owner;
    }

    function setDestinationWallet(address _walletAddress) external onlyOwner {
        require(_walletAddress != address(0));

        destinationWallet = _walletAddress;
    }

    function getDestinationWallet() constant returns (address wallet) {
        return destinationWallet;
    }
}