pragma solidity ^0.4.24; 

contract ETHStatement {

    /* --- EVENTS --- */

    event InvestorStatement(address indexed investor, uint amount, string email);

    /* --- FIELDS --- */

    struct Investor {
        uint amount;
        string email;
    }

    mapping (address => Investor) public investors;
    uint public totalAmount;


    /* --- PUBLIC / EXTERNAL METHODS --- */

    function declare(uint amount, string email) public { 
        require(msg.sender.balance >= amount, "You don't have enough ETH.");
        totalAmount += amount - investors[msg.sender].amount;
        investors[msg.sender].amount = amount; 
        investors[msg.sender].email = email;

        emit InvestorStatement(msg.sender, amount, email);
    }

    function declare(uint amount) public { 
        return declare(amount, "");
    }

    function getInvestorStatement(address investor) view public returns(uint, string) {
        return (investors[investor].amount, investors[investor].email);
    }

}