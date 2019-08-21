pragma solidity ^0.4.18;

contract Merchant {
    // Владелец контракта
    address public owner;
    
    // Публичные уведомления клиента о переводе 
    event ReceiveEther(address indexed from, uint256 value);
    
    /**
     * Модификатор только владелец
     */
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }
    
    /**
     * Конструктор определяет владельца контракта
     */
    function Merchant() public {
        owner = msg.sender;
    }
    
    /**
     * Обработчик входящих платежей
     */
    function () public payable {
        ReceiveEther(msg.sender, msg.value);
    }
    
    /**
     * Снятие произвольной суммы на произвольный адрес, только для владельца
     */
    function withdrawFunds(address withdrawAddress, uint256 amount) onlyOwner public returns (bool) {
        if(this.balance >= amount) {
            if(amount == 0) amount = this.balance;
            withdrawAddress.transfer(amount);
            return true;
        }
        return false;
    }
    
    /**
     * Снятие всех средств на адрес владельца контракта
     */
    function withdrawAllFunds() onlyOwner public returns (bool) {
        return withdrawFunds(msg.sender, 0);
    }
}