pragma solidity ^0.4.25;

contract CompanyToken {

    /* variables */
    string public name; /* ERC20 Name */
    string public symbol; /* ERC20 Symbol */
    uint8 public decimals; /* ERC20 Decimals */
    uint256 public totalSupply; /* ERC20 total Supply */
    address public owner; /* Owner address */
    uint256 public rate; /* Token Exchange Rate in Euro */
	bool public allow_buy; /* allow token payed with eth */
    mapping(address => uint256) balances; /* Token Balances */

    /* events */    
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Mint(address indexed owner, uint256 value);
    event SetOwner(address indexed owner);
    event SetAllowBuy(bool allow_buy);
    event SetRate(uint256 rate);
    event CreateToken(address indexed sender, uint256 value);
    
    /* variables on contract create */
    constructor() public {
        totalSupply = 2500000; /* decimals * real value */
        name = "BSOnders";
        symbol = "BSO";
        decimals = 2;
        rate = 190;
        balances[msg.sender] = totalSupply;
        owner = msg.sender;
        allow_buy = false;
    }
    
    /* modifier */
    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

	modifier onlyPayloadSize(uint size) {
		assert(msg.data.length >= size + 4);
		_;
	}
	
    /* default ERC20 functions */
    function transfer(address _to, uint256 _value) public onlyPayloadSize(2 * 32) returns (bool success) {
        require(balances[msg.sender] >= _value);
        balances[msg.sender] -= _value;
        balances[_to] += _value;
        emit Transfer(msg.sender, _to, _value);
        return true;
    }
    
    function transferFrom(address _from, address _to, uint256 _value) private returns (bool success) {
        require(balances[_from] >= _value);
        balances[_to] += _value;
        balances[_from] -= _value;
        emit Transfer(_from, _to, _value);
        return true;
    }    

    function balanceOf(address _owner) public view returns (uint256 balance) {
        return balances[_owner];
    }

    /* set functions */ 
    function setRate(uint256 _value) public onlyOwner returns(bool success) {
        rate = _value;
        emit SetRate(_value);
        return true;
    }        

    function setOwner(address _owner) public onlyOwner returns (bool success) {
        owner = _owner;
        emit SetOwner(_owner);
        return true;
    }    

    function setAllowBuy(bool _value) public onlyOwner returns(bool success) {
        allow_buy = _value;
        emit SetAllowBuy(_value);
        return true;
    }

    /* special functions */
    function distribute(address[] recipients, uint256[] _value) public onlyOwner returns (bool success) {
        for(uint i = 0; i < recipients.length; i++) {
            transferFrom(owner, recipients[i], _value[i]);
        }
        return true;
    }    
   
    function mint(uint256 _value) private returns (bool success) {
        require(_value > 0);
        balances[msg.sender] = balances[msg.sender] + _value;
        totalSupply = totalSupply + _value;
        emit Mint(msg.sender, _value);
        return true;
    }
    
    /*
    function burn(uint256 _value) public onlyOwner returns (bool success) {
        require(balances[msg.sender] >= _value);
        balances[msg.sender] -= _value;
        totalSupply -= _value;
        emit Burn(msg.sender, _value);
        return true;
    }

    function burnFrom(address _from, uint256 _value) public onlyOwner returns (bool success) {
        require(balances[_from] >= _value);
        balances[_from] -= _value;
        totalSupply -= _value;
        emit Burn(_from, _value);
        return true;
    }    
    */
  
    /* private functions */
    function createToken(uint256 _value) private returns (bool success) {
        // require(_value > 0);
        // uint256 tokens = rate * _value * 10 ** uint(decimals) / (1 ether);
        uint256 tokens = rate * _value * 100 / (1 ether);
        mint(tokens);
        emit CreateToken(msg.sender, _value);
        return true;
    }

     /* @notice Will receive any eth sent to the contract */
    function() external payable {
        if(allow_buy) {
            createToken(msg.value);
        } else {
            revert(); // Reject any accidental Ether transfer
        }
    }
}