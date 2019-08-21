pragma solidity ^0.4.21;

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
  address public owner;


  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  function Ownable() public {
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
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param newOwner The address to transfer ownership to.
   */
  function transferOwnership(address newOwner) public onlyOwner {
    require(newOwner != address(0));
    emit OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }

}

/**
 * @title ERC20Basic
 * @dev Simpler version of ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/179
 */
contract ERC20Basic {
  function totalSupply() public view returns (uint256);
  function balanceOf(address who) public view returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}


/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender) public view returns (uint256);
  function transferFrom(address from, address to, uint256 value) public returns (bool);
  function approve(address spender, uint256 value) public returns (bool);
  function setCrowdsale(address tokenWallet, uint256 amount) public returns (bool);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract cDeployer {
	function deployCrowdsale(address _tWallet, address _token, address _eWallet, uint _maxETH, address reqBy) public returns (address);
}

contract tDeployer {
	function deployToken(string _tName, string _tSymbol, uint _mint, address _owner) public returns (address);
}

contract customTkn {
    function multiTransfer(address[] _to, uint256[] _values) public;
    function transferFrom(address from, address to, uint256 value) public returns (bool);
}

contract contractDeployer is Ownable {
	
	event ContractCreated(address newAddress);
	
    address public tokenAddr;
	uint public tokenFee;
	uint public crowdsaleFee;
	uint public multisendFee;

	ERC20 token;
	cDeployer cdep;
	tDeployer tdep;

	function setUp(address _token, address _cdep, address _tdep) public onlyOwner {
		tokenAddr = _token;
		token = ERC20(tokenAddr);
		cdep = cDeployer(_cdep);
		tdep = tDeployer(_tdep);
	}
	function changeTokenFee(uint _amount) public onlyOwner {
		tokenFee = _amount;
	}
	function changeCrowdsaleFee(uint _amount) public onlyOwner {
		crowdsaleFee = _amount;
	}
	function changeMultisendFee(uint _amount) public onlyOwner {
		multisendFee = _amount;
	}

	function deployToken(string _tName, string _tSymbol, uint _mint, address _owner) public returns (address) {
		require(token.transferFrom(msg.sender, owner, tokenFee));
		emit ContractCreated(tdep.deployToken(_tName, _tSymbol, _mint, _owner));
	}
	
	function deployCrowdsale(address _tWallet, address _token, address _eWallet, uint _maxETH) public returns (address) {
		require(token.transferFrom(msg.sender, owner, crowdsaleFee));
		emit ContractCreated(cdep.deployCrowdsale(_eWallet, _token, _tWallet, _maxETH, msg.sender));
	}


	function multiSender(address _token, uint _total, address[] _to, uint[] _amount) public {
		require(token.transferFrom(msg.sender, owner, multisendFee));
		customTkn er2 = customTkn(_token);
		require(er2.transferFrom(msg.sender, this, _total));
		er2.multiTransfer(_to, _amount);
	}

}