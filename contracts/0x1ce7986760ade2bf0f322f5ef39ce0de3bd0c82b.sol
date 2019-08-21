pragma solidity ^0.4.0;

/// @title PonzICO
/// @author acityinohio
contract PonzICO {
    address public owner;
    uint public total;
    mapping (address => uint) public invested;
    mapping (address => uint) public balances;
    address[] investors;

    //log event of successful investment/withdraw and address
    event LogInvestment(address investor, uint amount);
    event LogWithdrawal(address investor, uint amount);

    //modifiers for various things
    modifier checkZeroBalance() { if (balances[msg.sender] == 0) { throw; } _;}
    modifier accreditedInvestor() { if (msg.value < 100 finney) { throw; } _;}

	//constructor for initializing PonzICO.
    //the owner is the genius who made this revolutionary smart contract
	function PonzICO() {
		owner = msg.sender;
	}

    //the logic for a small fee for the creator of this contract
    //miniscule in the grand scheme of things
    function ownerFee(uint amount) private returns (uint fee) {
        if (total < 200000 ether) {
            fee = amount/2;
            balances[owner] += fee;
        }
        return;
    }

    //This is where the magic is withdrawn.
    //For users with balances. Can only be used to withdraw full balance.
    function withdraw()
    checkZeroBalance()
    {
        uint amount = balances[msg.sender];
        balances[msg.sender] = 0;
        if (!msg.sender.send(amount)) {
            balances[msg.sender] = amount;
        } else {
            LogWithdrawal(msg.sender, amount);
        }
    }

    //What's better than withdrawing? Re-investing profits!
    function reinvest()
    checkZeroBalance()
    {
        uint dividend = balances[msg.sender];
        balances[msg.sender] = 0;
        uint fee = ownerFee(dividend);
        dividend -= fee;
        for (uint i = 0; i < investors.length; i++) {
            balances[investors[i]] += dividend * invested[investors[i]] / total;
        }
        invested[msg.sender] += (dividend + fee);
        total += (dividend + fee);
        LogInvestment(msg.sender, dividend+fee);
    }

	//This is the where the magic is invested.
    //Note the accreditedInvestor() modifier, to ensure only sophisticated
    //investors with 0.1 ETH or more can invest. #SelfRegulation
	function invest() payable
    accreditedInvestor()
    {
        //first send the owner's modest 50% fee but only if the total invested is less than 200000 ETH
        uint dividend = msg.value;
        uint fee = ownerFee(dividend);
        dividend -= fee;
        //then accrue balances from the generous remainder to everyone else previously invested
        for (uint i = 0; i < investors.length; i++) {
            balances[investors[i]] += dividend * invested[investors[i]] / total;
        }

        //finally, add this enterprising new investor to the public balances
        if (invested[msg.sender] == 0) {
            investors.push(msg.sender);
            invested[msg.sender] = msg.value;
        } else {
            invested[msg.sender] += msg.value;
        }
        total += msg.value;
        LogInvestment(msg.sender, msg.value);
	}

    //finally, fallback function. no one should send money to this contract
    //without first being added as an investment.
    function () { throw; }
}