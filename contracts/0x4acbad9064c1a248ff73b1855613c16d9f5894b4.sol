pragma solidity ^0.4.13;

contract Ownable 

{

  address public owner;

 

  constructor(address _owner) public 

  {

    owner = _owner;

  }

 

  modifier onlyOwner() 

  {

    require(msg.sender == owner);

    _;

  }

 

  function transferOwnership(address newOwner) onlyOwner 

  {

    require(newOwner != address(0));      

    owner = newOwner;

  }

}

contract IBalance {

	function distributeEthProfit(address profitMaker, uint256 amount) public  ;

	function distributeTokenProfit (address profitMaker, address token, uint256 amount) public  ;

	function modifyBalance(address _account, address _token, uint256 _amount, bool _addOrSub) public;

	function getAvailableBalance(address _token, address _account) public constant returns (uint256);

}

contract IToken {



  /// @notice send `_value` token to `_to` from `msg.sender`

  /// @param _to The address of the recipient

  /// @param _value The amount of token to be transferred

  /// @return Whether the transfer was successful or not

  function transfer(address _to, uint256 _value) public returns (bool success);



  /// @notice send `_value` token to `_to` from `_from` on the condition it is approved by `_from`

  /// @param _from The address of the sender

  /// @param _to The address of the recipient

  /// @param _value The amount of token to be transferred

  /// @return Whether the transfer was successful or not

  function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);



  function approve(address _spender, uint256 _value) public returns (bool success);



}

library SafeMath {



  /**

  * @dev Multiplies two numbers, throws on overflow.

  */

  function mul(uint256 a, uint256 b) internal pure returns (uint256) {

    if (a == 0) {

      return 0;

    }

    uint256 c = a * b;

    require(c / a == b);

    return c;

  }



  /**

  * @dev Integer division of two numbers, truncating the quotient.

  */

  function div(uint256 a, uint256 b) internal pure returns (uint256) {

    require(b > 0); // Solidity automatically throws when dividing by 0

    uint256 c = a / b;

    return c;

  }



  /**

  * @dev Substracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).

  */

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {

    require(b <= a);

    return a - b;

  }



  /**

  * @dev Adds two numbers, throws on overflow.

  */

  function add(uint256 a, uint256 b) internal pure returns (uint256) {

    uint256 c = a + b;

    require(c >= a);

    return c;

  }

}

contract BiLinkExchange is Ownable {

	using SafeMath for uint256;



	address public contractBalance;

	uint256 public commissionRatio;//percentage



	mapping (address => mapping ( bytes32 => uint256)) public account2Order2TradeAmount;



	bool public isLegacy;//if true, not allow new trade,new deposit



	event OnTrade(bytes32 guid, address tokenGive, address tokenGet, address maker, address taker, uint256 amountGive, uint256 amountGet, uint256 amountGetTrade, uint256 timestamp);

	



	constructor(address _owner, uint256 _commissionRatio) public Ownable(_owner) {

		isLegacy= false;

		commissionRatio= _commissionRatio;

	}



	function setThisContractAsLegacy() public onlyOwner {

		isLegacy= true;

	}



	function setBalanceContract(address _contractBalance) public onlyOwner {

		contractBalance= _contractBalance;

	}



	//_arr1:tokenGive,tokenGet,maker

	//_arr2:amountGive,amountGet,amountGetTrade,expireTime

	//_arr3:rMaker,sMaker

	//parameters are from taker's perspective

	function trade(address[] _arr1, uint256[] _arr2, bytes32 _guid, uint8 _vMaker, bytes32[] _arr3) public {

		require(isLegacy== false&& now <= _arr2[3]);



		uint256 _amountTokenGiveTrade= _arr2[0].mul(_arr2[2]).div(_arr2[1]);

		require(_arr2[2]<= IBalance(contractBalance).getAvailableBalance(_arr1[1], _arr1[2])&&_amountTokenGiveTrade<= IBalance(contractBalance).getAvailableBalance(_arr1[0], msg.sender));



		bytes32 _hash = keccak256(abi.encodePacked(this, _arr1[1], _arr1[0], _arr2[1], _arr2[0], _arr2[3]));

		require(ecrecover(_hash, _vMaker, _arr3[0], _arr3[1]) ==  _arr1[2]&& account2Order2TradeAmount[_arr1[2]][_hash].add(_arr2[2])<= _arr2[1]);



		uint256 _commission= _arr2[2].mul(commissionRatio).div(10000);

		

		IBalance(contractBalance).modifyBalance(msg.sender, _arr1[1], _arr2[2].sub(_commission), true);

		IBalance(contractBalance).modifyBalance(_arr1[2], _arr1[1], _arr2[2], false); 

		

		IBalance(contractBalance).modifyBalance(msg.sender, _arr1[0], _amountTokenGiveTrade, false);

		IBalance(contractBalance).modifyBalance(_arr1[2], _arr1[0], _amountTokenGiveTrade, true);

		account2Order2TradeAmount[_arr1[2]][_hash]= account2Order2TradeAmount[_arr1[2]][_hash].add(_arr2[2]);

						

		if(_arr1[1]== address(0)) {

			IBalance(contractBalance).distributeEthProfit(msg.sender, _commission);

		}

		else {

			IBalance(contractBalance).distributeTokenProfit(msg.sender, _arr1[1], _commission);

		}



		emit OnTrade(_guid, _arr1[0], _arr1[1], _arr1[2], msg.sender, _arr2[0], _arr2[1], _arr2[2], now);

	}

}