pragma solidity ^0.4.19;

contract SafeMath {

    /* function assert(bool assertion) internal { */
    /*   if (!assertion) { */
    /*     throw; */
    /*   } */
    /* }      // assert no longer needed once solidity is on 0.4.10 */

    function safeAdd(uint256 x, uint256 y) internal returns(uint256) {
      uint256 z = x + y;
      assert((z >= x) && (z >= y));
      return z;
    }

    function safeSub(uint256 x, uint256 y) internal returns(uint256) {
      assert(x >= y);
      uint256 z = x - y;
      return z;
    }

    function safeMult(uint256 x, uint256 y) internal returns(uint256) {
      uint256 z = x * y;
      assert((x == 0)||(z/x == y));
      return z;
    }

}

contract Ownable {
	address public owner;
	function Ownable() {owner = msg.sender;}
	modifier onlyOwner() {
		if (msg.sender != owner) throw;
		_;
	}

}

contract Token {
    uint256 public totalSupply;
    function balanceOf(address _owner) constant returns (uint256 balance);
    function transfer(address _to, uint256 _value) returns (bool success);
    function transferFrom(address _from, address _to, uint256 _value) returns (bool success);
    function approve(address _spender, uint256 _value) returns (bool success);
    function allowance(address _owner, address _spender) constant returns (uint256 remaining);
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}

/*  ERC 20 token */
contract StandardToken is Token {

    function transfer(address _to, uint256 _value) returns (bool success) {
      if (balances[msg.sender] >= _value && _value > 0) {
        balances[msg.sender] -= _value;
        balances[_to] += _value;
        Transfer(msg.sender, _to, _value);
        return true;
      } else {
        return false;
      }
    }

    function transferFrom(address _from, address _to, uint256 _value) returns (bool success) {
      if (balances[_from] >= _value && allowed[_from][msg.sender] >= _value && _value > 0) {
        balances[_to] += _value;
        balances[_from] -= _value;
        allowed[_from][msg.sender] -= _value;
        Transfer(_from, _to, _value);
        return true;
      } else {
        return false;
      }
    }

    function balanceOf(address _owner) constant returns (uint256 balance) {
        return balances[_owner];
    }

    function approve(address _spender, uint256 _value) returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }

    function allowance(address _owner, address _spender) constant returns (uint256 remaining) {
      return allowed[_owner][_spender];
    }

    mapping (address => uint256) balances;
    mapping (address => mapping (address => uint256)) allowed;
}

contract XCToken is StandardToken,SafeMath,Ownable {

    // metadata
    string public constant name = "XC.COM(XC Program)";
    string public constant symbol = "XC";
    uint256 public constant decimals = 8;
    string public version = "1.0";
    
    // total cap
    uint256 public constant tokenCreationCap = 2000 * (10**6) * 10**decimals;
    // init amount
    uint256 public constant tokenCreationInit = 1000 * (10**6) * 10**decimals;
    // The amount of XCTokens that can be mint
    uint256 public constant tokenMintCap = 1000 * (10**6) * 10**decimals;
    // The amount of XCTokens that have been minted
    uint256 public tokenMintedSupply;
    
    address public initDepositAccount;
    address public mintDepositAccount;
    
	bool public mintFinished;
	
	event Mint(uint256 amount);
	event MintFinished();

    function XCToken(
        address _initFundDepositAccount,
        address _mintFundDepositAccount
        ) {
        initDepositAccount = _initFundDepositAccount;
        mintDepositAccount = _mintFundDepositAccount;
        balances[initDepositAccount] = tokenCreationInit;
        totalSupply = tokenCreationInit;
        tokenMintedSupply = 0;
        mintFinished = false;
    }
    
    modifier canMint() {
		if(mintFinished) throw;
		_;
	}
	
    // The remaining amount of tokens that can be minted.
	function remainMintTokenAmount() constant returns (uint256 remainMintTokenAmount) {
	    return safeSub(tokenMintCap, tokenMintedSupply);
	}

	// mint token
	function mint(uint256 _tokenAmount) onlyOwner canMint returns (bool) {
		if(_tokenAmount <= 0) throw;
		uint256 checkedSupply = safeAdd(tokenMintedSupply, _tokenAmount);
		if(checkedSupply > tokenMintCap) throw;
		if(checkedSupply == tokenMintCap){ // mint finish
		    mintFinished = true;
		    MintFinished();
		}
		tokenMintedSupply = checkedSupply;
		totalSupply = safeAdd(totalSupply, _tokenAmount);
		balances[mintDepositAccount] = safeAdd(balances[mintDepositAccount], _tokenAmount);
		Mint(_tokenAmount);
		return true;
	}
	
	// Do not allow direct deposits.
    function () external {
        throw;
    }
	
}