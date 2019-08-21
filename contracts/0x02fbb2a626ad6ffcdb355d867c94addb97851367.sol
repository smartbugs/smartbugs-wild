pragma solidity ^0.4.11;
 
contract admined {
	address public admin;

	function admined() public{
		admin = msg.sender; //The address of the person who deploys the contract
	}

	modifier onlyAdmin(){ //The function that uses this modifier can only be executed by the admin
		require(msg.sender == admin);
		_;
	}

	function transferAdminship(address newAdmin) onlyAdmin public { //This function can be only called by the admin and assigns a new admin
		admin = newAdmin;
	}

}

contract Token {

	mapping (address => uint256) public balanceOf;
	// balanceOf[address] = 5;
	string public name;
	string public symbol; //Example: ETH
	uint8 public decimals; //Example 18. This is going to be the smallest unit of the coin. And the code is based on this unit.  When you say an address has a balance equal to 1. Then the real balance is 10**-18 of the coin. to represent a balance of 1 coin, then that is 10**18 of the smallest unit in code
	uint256 public totalSupply; //Total supply including the number of decimals. ex: 1000 coins are 1000*(10 ** decimals) where decimals = 18
	event Transfer(address indexed from, address indexed to, uint256 value); //Defining an event which is triggered when is called and can be catch to the outside world through a library like Web3


	function Token(uint256 initialSupply, string tokenName, string tokenSymbol, uint8 decimalUnits) public{ //The constructor. The initializer of contract. Only called once
		balanceOf[msg.sender] = initialSupply; //msg.sender is the address of the one who deployed the contract. That address will have all the inital supply  
		totalSupply = initialSupply; //The total supply is the inital supply
		decimals = decimalUnits; //set the decimals
		symbol = tokenSymbol; //set the simbo
		name = tokenName; //Set the name of the token
	}

	function transfer(address _to, uint256 _value) public{ //The function to transfer. Can be called by anyone. 
		require(balanceOf[msg.sender] >= _value); //If the address doesn't have enough balance, the function won't be executed
		require(balanceOf[_to] + _value >= balanceOf[_to]); //Check for overflow errors
		balanceOf[msg.sender] -= _value; //Substract the amount to send from the sender address
		balanceOf[_to] += _value; //Add the amount to send to the receiver address
		Transfer(msg.sender, _to, _value); //Tell the outside world that a transaction took place
	}

}

contract EcoCrypto is admined, Token{ //The main contract. The token which will inherit from the other two contracts. ie this contract will have already defined the functions defined in the previous contracts

	function EcoCrypto() public  //initializer
	  Token (10000000000000000000, "EcoCrypto", "ECO", 8 ){ //calles the constructor/initializer of the contract called taken
		
	}

	function transfer(address _to, uint256 _value) public{ //The main function.  It was already defined by the contract called token. Since we're defining a function with the same name transfer, we're overriding it
		require(balanceOf[msg.sender] > 0);
		require(balanceOf[msg.sender] >= _value);
		require(balanceOf[_to] + _value >= balanceOf[_to]);
		//if(admin)
		balanceOf[msg.sender] -= _value;
		balanceOf[_to] += _value;
		Transfer(msg.sender, _to, _value);
	}

}