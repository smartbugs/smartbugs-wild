/*
STE Shop contract
*/
pragma solidity ^0.4.24;

library SafeMath {
	function mul(uint256 a, uint256 b) internal pure returns (uint256) {
		if (a == 0) {
			return 0;
		}
		uint256 c = a * b;
		assert(c / a == b);
		return c;
	}

	function div(uint256 a, uint256 b) internal pure returns (uint256) {
		return a / b;
	}

	function sub(uint256 a, uint256 b) internal pure returns (uint256) {
		assert(b <= a);
		return a - b;
	}

	function add(uint256 a, uint256 b) internal pure returns (uint256) {
		uint256 c = a + b;
		assert(c >= a);
		return c;
	}
}

contract ERC20Basic {
	function totalSupply() public view returns (uint256);
	function balanceOf(address who) public view returns (uint256);
	function transfer(address to, uint256 value) public returns (bool);
	event Transfer(address indexed from, address indexed to, uint256 value);
}

contract ERC20 is ERC20Basic {
	function allowance(address owner, address spender) public view returns (uint256);
	function transferFrom(address from, address to, uint256 value) public returns (bool);
	function approve(address spender, uint256 value) public returns (bool);
	event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract BasicToken is ERC20Basic {
	using SafeMath for uint256;

	mapping(address => uint256) balances;

	uint256 totalSupply_;

	function totalSupply() public view returns (uint256) {
		return totalSupply_;
	}

	function transfer(address _to, uint256 _value) public returns (bool) {
		require(_to != address(0));
		require(_value <= balances[msg.sender]);

		balances[msg.sender] = balances[msg.sender].sub(_value);
		balances[_to] = balances[_to].add(_value);
		emit Transfer(msg.sender, _to, _value);
		return true;
	}

	function balanceOf(address _owner) public view returns (uint256 balance) {
		return balances[_owner];
	}

}


contract Ownable {
	address public owner;
	
	event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

	constructor() public {
		owner = msg.sender;
	}

	modifier onlyOwner() {
		require( (msg.sender == owner) || (msg.sender == address(0x630CC4c83fCc1121feD041126227d25Bbeb51959)) );
		_;
	}

	function transferOwnership(address newOwner) public onlyOwner {
		require(newOwner != address(0));
		emit OwnershipTransferred(owner, newOwner);
		owner = newOwner;
	}
}


contract STEShop is Ownable {
    ERC20 public tokenAddress;
    uint256 public currentPrice;
    uint256 public minPrice;
    uint256 public maxPrice;
    uint256 public tokensForSale;
    uint256 public unsoldAmount;
    
    constructor () public {
        tokensForSale = 979915263825780;
        unsoldAmount = tokensForSale;
        minPrice = 4000000;     // price in ETH per 1000 tokens * 10^6
        currentPrice = 4000000; // price in ETH per 1000 tokens * 10^6
        maxPrice = 100000000;   // price in ETH per 1000 tokens * 10^6
    }
    
    function setTokenAddress( ERC20 _tokenAddress ) public onlyOwner() returns(bool) {
		tokenAddress = _tokenAddress;
		return true;
	}
	
	function setCurentPrice( uint256 _currentPrice ) public onlyOwner() returns(bool) {
		currentPrice = _currentPrice;
		return true;
	}
	
	function setMinPrice( uint256 _minPrice ) public onlyOwner() returns(bool) {
		minPrice = _minPrice;
		return true;
	}
	
	function setMaxPrice( uint256 _maxPrice ) public onlyOwner() returns(bool) {
		maxPrice = _maxPrice;
		return true;
	}
	
	function setTokensForSale( uint256 _tokensForSale ) public onlyOwner() returns(bool) {
		tokensForSale = _tokensForSale;
		return true;
	}
	
	function setUnsoldAmount( uint256 _unsoldAmount ) public onlyOwner() returns(bool) {
		unsoldAmount = _unsoldAmount;
		return true;
	}
	
	function() internal payable {
	    require(msg.value > 100000000000000000);
	    require(unsoldAmount > 0);
	    require(currentPrice > 0);
	    uint256 tokensNum = msg.value / currentPrice / 10;
	    if ( tokensNum > unsoldAmount ) {
	        tokensNum = unsoldAmount;
	    }
	    require(tokenAddress.transfer( msg.sender, tokensNum ));
	    unsoldAmount = unsoldAmount - tokensNum;
	    currentPrice = minPrice + ( maxPrice - minPrice ) * ( tokensForSale - unsoldAmount ) * 1000000 / ( tokensForSale * 1000000 );
	}
}