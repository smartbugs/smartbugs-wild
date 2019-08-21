pragma solidity ^0.5.1;
// Saltyness token
// Known bug: Doesn't solve the oracle problem. Tweet @ARitzCracker with proof of salt. Saltyness will be sent to the provided address.

interface ERC223Handler { 
    function tokenFallback(address _from, uint _value, bytes calldata _data) external;
}

contract SaltynessToken{
    using SafeMath for uint256;
    using SafeMath for uint;
    
	modifier onlyOwner {
		require(msg.sender == owner);
		_;
	}
    
    constructor() public{
        owner = msg.sender;
    }
	address owner;
	address newOwner;
    
    mapping(address => uint256) public balanceOf;
    mapping(address => mapping (address => uint256)) allowances;
    
    string constant public name = "Saltyness";
    string constant public symbol = "SALT";
    uint8 constant public decimals = 18;
    uint256 public totalSupply;
    
    // --Events
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
    event Transfer(address indexed from, address indexed to, uint value);
    event Transfer(address indexed from, address indexed to, uint value, bytes indexed data);
    // --Events--
    
    // --Owner only functions
    function setNewOwner(address o) public onlyOwner {
		newOwner = o;
	}

	function acceptNewOwner() public {
		require(msg.sender == newOwner);
		owner = msg.sender;
	}
	
    // Known bug: Token supply is theoretically infinite as @peter_szilagyi produces a never-ending stream of salt in extremly high amounts.
	function giveSalt(address _saltee, uint256 _salt) public onlyOwner {
	    totalSupply = totalSupply.add(_salt);
	    balanceOf[_saltee] = balanceOf[_saltee].add(_salt);
        emit Transfer(address(this), _saltee, _salt, "");
        emit Transfer(address(this), _saltee, _salt);
	}
	// --Owner only functions--
    
    // --Public write functions
    function transfer(address _to, uint _value, bytes memory _data, string memory _function) public returns(bool ok){
        actualTransfer(msg.sender, _to, _value, _data, _function, true);
        return true;
    }
    
    function transfer(address _to, uint _value, bytes memory _data) public returns(bool ok){
        actualTransfer(msg.sender, _to, _value, _data, "", true);
        return true;
    }
    function transfer(address _to, uint _value) public returns(bool ok){
        actualTransfer(msg.sender, _to, _value, "", "", true);
        return true;
    }
    
    function approve(address _spender, uint _value) public returns (bool success) {
        allowances[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }
    function transferFrom(address _from, address _to, uint _value) public returns (bool success) {
        uint256 _allowance = allowances[_from][msg.sender];
        require(_allowance > 0, "Not approved");
        require(_allowance >= _value, "Over spending limit");
        allowances[_from][msg.sender] = _allowance.sub(_value);
        actualTransfer(_from, _to, _value, "", "", false);
        return true;
    }
    
    // --Public write functions--
     
    // --Public read-only functions
    
    function allowance(address _sugardaddy, address _spender) public view returns (uint remaining) {
        return allowances[_sugardaddy][_spender];
    }
    
    // --Public read-only functions--
    
    
    
    // Internal functions
    
    function actualTransfer(address _from, address _to, uint _value, bytes memory _data, string memory _function, bool _careAboutHumanity) private{
        require(balanceOf[_from] >= _value, "Insufficient balance"); // You see, I want to be helpful.
        require(_to != address(this), "You can't sell back your tokens");
        
        // Throwing an exception undos all changes. Otherwise changing the balance now would be a shitshow
        balanceOf[_from] = balanceOf[_from].sub(_value);
        balanceOf[_to] = balanceOf[_to].add(_value);
        
        if(_careAboutHumanity && isContract(_to)) {
            if (bytes(_function).length == 0){
                ERC223Handler receiver = ERC223Handler(_to);
                receiver.tokenFallback(_from, _value, _data);
            }else{
                bool success;
                bytes memory returnData;
                (success, returnData) = _to.call.value(0)(abi.encodeWithSignature(_function, _from, _value, _data));
                assert(success);
            }
        }
        emit Transfer(_from, _to, _value, _data);
        emit Transfer(_from, _to, _value);
    }
    
    function isContract(address _addr) private view returns (bool is_contract) {
        uint length;
        assembly {
            // Peter hates this opcode because it forces him to realize that it's the only blockchain-related function in the EVM which effects aren't applied until _after_ confirmation.
            // But no, it's totally a feature as he intended because he is always right.
            length := extcodesize(_addr)
        }
        return (length>0);
    }
}

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {
    
    /**
    * @dev Multiplies two numbers, throws on overflow.
    */
    function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
        if (a == 0 || b == 0) {
           return 0;
        }
        c = a * b;
        assert(c / a == b);
        return c;
    }
    
    /**
    * @dev Integer division of two numbers, truncating the quotient.
    */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // assert(b > 0); // Solidity automatically throws when dividing by 0
        // uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return a / b;
    }
    
    /**
    * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
    */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }
    
    /**
    * @dev Adds two numbers, throws on overflow.
    */
    function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
        c = a + b;
        assert(c >= a);
        return c;
    }
}