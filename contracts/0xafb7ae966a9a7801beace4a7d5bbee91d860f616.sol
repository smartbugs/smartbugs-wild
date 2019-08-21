pragma solidity ^0.4.0;
contract Ownable {
    address public owner;

    constructor() public {
        owner = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    function transferOwnership(address newOwner) onlyOwner public {
        owner = newOwner;
    }
}
contract LockableToken is Ownable {
    function totalSupply() public view returns (uint256);
    function balanceOf(address who) public view returns (uint256);
    function transfer(address to, uint256 value) public returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    function allowance(address owner, address spender) public view returns (uint256);
    function transferFrom(address from, address to, uint256 value) public returns (bool);
    function approve(address spender, uint256 value) public returns (bool);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    function approveAndCall(address _spender, uint256 _value, bytes _data) public payable returns (bool);
    function transferAndCall(address _to, uint256 _value, bytes _data) public payable returns (bool);
    function transferFromAndCall(address _from, address _to, uint256 _value, bytes _data) public payable returns (bool);
}

contract Token is Ownable{
	LockableToken private token;
	string public Detail;
	uint256 public SellAmount = 0;
	uint256 public WeiRatio = 0;

	event TokenAddressChange(address token);
	event Buy(address sender,uint256 rate,uint256 value,uint256 amount);

    function () payable public {
        buyTokens(msg.sender);
    }
    
	function tokenDetail(string memory _detail) onlyOwner public {
	    Detail = _detail;
	}
	
	function tokenPrice(uint256 _price) onlyOwner public {
	    WeiRatio = _price;
	}

	function tokenAddress(address _token) onlyOwner public {
	    require(_token != address(0), "Token address cannot be null-address");
	    token = LockableToken(_token);
	    emit TokenAddressChange(_token);
	}

	function tokenBalance() public view returns (uint256) {
	    return token.balanceOf(address(this));
	}

    function withdrawEther() onlyOwner public  {
    	require(address(this).balance > 0, "Not have Ether for withdraw");
        owner.transfer(address(this).balance);
    }
    
    function withdrawToken() onlyOwner public  {
    	token.transfer(owner, tokenBalance());
    }

	function buyTokens(address _buyer) private {
		require(_buyer != 0x0);
		require(msg.value > 0);

		uint256 tokens = msg.value * WeiRatio;
		require(tokenBalance() >= tokens, "Not enough tokens for sale");
		token.transfer(_buyer, tokens);
		SellAmount += tokens;

		emit Buy(msg.sender,WeiRatio,msg.value,tokens);
	}
}