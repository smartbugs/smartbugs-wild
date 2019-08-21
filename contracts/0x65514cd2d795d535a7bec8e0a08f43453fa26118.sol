pragma solidity ^0.4.13;

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

	function distributeEthProfit(address profitMaker, uint256 amount) public ;

	function distributeTokenProfit (address profitMaker, address token, uint256 amount) public ;

	function modifyBalance(address _account, address _token, uint256 _amount, bool _addOrSub) public;

	function getAvailableBalance(address _token, address _account) public constant returns (uint256);

	function getTokenAssuranceAccount(address _token) public constant returns (address);

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

contract IMarketData {

	function getTokenExchangeRatio(address _tokenNum, address _tokenDenom) public returns (uint256 num, uint256 denom);

}

contract ILoanLogic {  

	function setTokenExchangeRatio(address[] tokenPledge, address[] tokenBorrow, uint256[] amountDenom, uint256[] amountNum) public returns (bool);

	function getPledgeAmount(address tokenPledge, address tokenBorrow, uint256 amount,uint16 ratioPledge) public constant returns (uint256);

	function updateDataAfterTrade(address tokenPledge, address tokenBorrow, address borrower, address lender,

		uint256 amountPledge, uint256 amount, uint256 amountInterest, uint256 periodDays) public returns(bool);

	function updateDataAfterRepay(uint256 id, uint256 uBorrowerAvailableAmount) public returns (uint256, uint256, uint256, uint256, uint256);

	function getLoanDataPart(uint256 id) public constant returns (address, address, address, address);

	function needForceClose(uint256 id) public constant returns (bool);

}

contract BiLinkLoan is Ownable {

	using SafeMath for uint256;



	address public contractLoanLogic;

	address public contractBalance;

	address public contractMarketData;

	address public accountCost;

	uint256 public commissionRatio;//percentage

	

	mapping (address => mapping ( bytes32 => uint256)) public account2Order2TradeAmount;

	

	mapping (address => uint16) public token2PledgeRatio;//percentage

	bool public isLegacy;//if true, not allow new trade,new deposit



	event OnTrade(address tokenPledge, address tokenBorrow, address borrower, address lender, uint256 amountPledge, uint256 amountInterest, uint256 amountBorrow, uint256 timestamp);

	event OnUserRepay(address tokenPledge, address tokenBorrow, address borrower, address lender, uint256 amountPledge, uint256 amountOriginInterest, uint256 amountActualInterest

		, uint256 amountRepaied, uint256 amountRepaiedPledgeToken, uint256 timestamp);

	event OnForceRepay(address tokenPledge, address tokenBorrow, address borrower, address lender, uint256 amountPledge, uint256 amountOriginInterest, uint256 amountActualInterest

		, uint256 amountRepaied, uint256 amountRepaiedPledgeToken, uint256 timestamp);

	event OnLossCompensated(address tokenPledge, address tokenBorrow, address borrower, address lender, uint256 amountLoss, uint256 amountCompensated, uint256 timestamp);

	event OnLossCompensatedByAssurance(address tokenPledge, address tokenBorrow, address borrower, address lender, uint256 amountLoss, uint256 amountCompensated, uint256 timestamp);

		

	constructor(address _owner, address _accountCost, address _contractLoanLogic, address _contractMarketData, uint256 _commissionRatio) public Ownable(_owner) {

		contractLoanLogic= _contractLoanLogic;

		contractMarketData= _contractMarketData;

		isLegacy= false;

		commissionRatio= _commissionRatio;

		accountCost= _accountCost;

	}

	

	function setTokenPledgeRatio(address _token, uint16 _ratioPledge) public onlyOwner {

		require(_ratioPledge> 0);

		token2PledgeRatio[_token]= _ratioPledge;

	}



	function setThisContractAsLegacy() public onlyOwner {

		isLegacy= true;

	}



	function setBalanceContract(address _contractBalance) public onlyOwner {

		contractBalance= _contractBalance;

	}



	//_arr1:tokenPledge,tokenBorrow,borrower,lender

	//_arr2:amountOrigin,amountInterest,periodDays,expireTime,amountTake

	//_arr3:rMaker,sMaker,rTaker,sTaker

	function trade(address[] _arr1, uint256[] _arr2, bool _borrowOrLend, uint8 _vMaker,uint8 _vTaker, bytes32[] _arr3) public {

		require(isLegacy== false&& _arr2[4]<= _arr2[0]&& verifyInput( _arr1, _arr2, _borrowOrLend, _vMaker, _vTaker, _arr3)&& token2PledgeRatio[_arr1[1]]> 0);



		uint256 amountPledge= ILoanLogic(contractLoanLogic).getPledgeAmount(_arr1[0], _arr1[1], _arr2[4], token2PledgeRatio[_arr1[1]]);

		require(amountPledge!= 0);



		uint256 amountInterest = amountPledge.mul(_arr2[1]).mul(_arr2[2]).mul(100).div(token2PledgeRatio[_arr1[1]]).div(100000);

		require(amountPledge.add(amountInterest)<= IBalance(contractBalance).getAvailableBalance(_arr1[0], _arr1[2])&&_arr2[4]<= IBalance(contractBalance).getAvailableBalance(_arr1[1], _arr1[3]));



		IBalance(contractBalance).modifyBalance(_arr1[3], _arr1[1], _arr2[4], false); 

		IBalance(contractBalance).modifyBalance(_arr1[2], _arr1[1], _arr2[4], true); 



		require(ILoanLogic(contractLoanLogic).updateDataAfterTrade(_arr1[0], _arr1[1], _arr1[2], _arr1[3], _arr2[4], amountPledge, amountInterest, _arr2[2]));

		

		emit OnTrade(_arr1[0], _arr1[1], _arr1[2], _arr1[3], amountPledge, amountInterest, _arr2[4], now);

	}



	function verifyInput( address[] _arr1, uint256[] _arr2, bool _borrowOrLend, uint8 _vMaker, uint8 _vTaker, bytes32[] _arr3) private returns (bool) {

		require(now <= _arr2[3]);

		address _accountPledgeAssurance= IBalance(contractBalance).getTokenAssuranceAccount(_arr1[0]);

		address _accountBorrowAssurance= IBalance(contractBalance).getTokenAssuranceAccount(_arr1[1]);

		require(_accountPledgeAssurance!= _arr1[2]&& _accountPledgeAssurance!= _arr1[3]&& _accountBorrowAssurance!= _arr1[2]&& _accountBorrowAssurance!= _arr1[3]);



		bytes32 _hash= keccak256(abi.encodePacked(this, _arr1[0], _arr1[1], _arr2[1], _arr2[2], _arr2[3]));

		require(ecrecover(_hash, _vMaker, _arr3[0], _arr3[1]) == (_borrowOrLend? _arr1[3] : _arr1[2]));

		require(ecrecover(getTakerHash(_arr1, _arr2, _borrowOrLend), _vTaker, _arr3[2], _arr3[3]) == (_borrowOrLend? _arr1[2]: _arr1[3]));

		

		if(_borrowOrLend) {

			require(account2Order2TradeAmount[_arr1[3]][_hash].add(_arr2[4])<= _arr2[0]);

			account2Order2TradeAmount[_arr1[3]][_hash]= account2Order2TradeAmount[_arr1[3]][_hash].add(_arr2[4]);

		}

		else {

			require(account2Order2TradeAmount[_arr1[2]][_hash].add(_arr2[4])<= _arr2[0]);

			account2Order2TradeAmount[_arr1[2]][_hash]= account2Order2TradeAmount[_arr1[2]][_hash].add(_arr2[4]);

		}

		return true;

	}



	function getTakerHash(address[] _arr1, uint256[] _arr2, bool _borrowOrLend) private returns (bytes32) {

		return keccak256(abi.encodePacked(this, _arr1[0], _arr1[1], _arr2[0], _arr2[4], _arr2[1], _arr2[2], _arr2[3], (_borrowOrLend? _arr1[3] : _arr1[2])));

	}



	function getNeedRepayPledgeTokenAmount(uint256 _amountUnRepaiedPledgeTokenAmount, address _token) private returns (uint256) {

		return _amountUnRepaiedPledgeTokenAmount.mul((token2PledgeRatio[_token] - 100)/4 + 100).div(100);

	}



	function doRepay(uint256 _id, bool _userOrForce) private {

		var (_tokenPledge,_tokenBorrow,_borrower,_lender)= ILoanLogic(contractLoanLogic).getLoanDataPart(_id);

		require(_borrower!= address(0));

		 

		uint256 _available= IBalance(contractBalance).getAvailableBalance(_tokenBorrow, _borrower);

		var (_amount, _amountOriginInterest, _amountActualInterest,_amountUnRepaiedAmount, _amountPledge)= ILoanLogic(contractLoanLogic).updateDataAfterRepay(_id, _available);

		require(_amount!= 0);



		uint256 _amountUnRepaiedPledgeToken= tryCompensateLossByAssurance(_tokenPledge, _tokenBorrow, _borrower, _lender, _amountPledge, _amountUnRepaiedAmount);



		_available= IBalance(contractBalance).getAvailableBalance(_tokenBorrow, _borrower);

		uint256 _amountRepaiedPledgeToken= getNeedRepayPledgeTokenAmount(_amountUnRepaiedPledgeToken, _tokenBorrow);

		adjustBalancesAfterRepay(_tokenPledge, _tokenBorrow, _borrower, _lender, _amountActualInterest, (_amountRepaiedPledgeToken< _amountPledge? _amountRepaiedPledgeToken: _amountPledge), (_available> _amount? _amount: _available)

			, (_amountUnRepaiedPledgeToken > _amountPledge? _amountUnRepaiedPledgeToken - _amountPledge: 0));



		if(_userOrForce)

			emit OnUserRepay(_tokenPledge, _tokenBorrow, _borrower, _lender, _amountPledge, _amountOriginInterest, _amountActualInterest, _amount, _amountRepaiedPledgeToken, now);

		else

			emit OnForceRepay(_tokenPledge, _tokenBorrow, _borrower, _lender, _amountPledge, _amountOriginInterest, _amountActualInterest, _amount, _amountRepaiedPledgeToken, now);

	}



	function tryCompensateLossByAssurance(address _tokenPledge, address _tokenBorrow, address _borrower, address _lender, uint256 _amountPledge, uint256 _amountUnRepaiedAmount) private returns (uint256) {

		uint256 _amountUnRepaiedPledgeToken= 0;

		address _accountAssurance= IBalance(contractBalance).getTokenAssuranceAccount(_tokenBorrow);

		uint256 _available= IBalance(contractBalance).getAvailableBalance(_tokenBorrow, _accountAssurance);

		(uint256 _num, uint256 _denom)= IMarketData(contractMarketData).getTokenExchangeRatio(_tokenPledge, _tokenBorrow);

		uint256 _equalAmount= _amountPledge.mul(_denom).div(_num);



		if(_amountUnRepaiedAmount > _equalAmount&& _available> 0) {

			uint256 _actualCompensatedAmountByAssurance= _amountUnRepaiedAmount.sub(_equalAmount);

			if(_available< _amountUnRepaiedAmount)

				_actualCompensatedAmountByAssurance= _available;

			IBalance(contractBalance).modifyBalance(_accountAssurance, _tokenBorrow, _actualCompensatedAmountByAssurance, false); 

			IBalance(contractBalance).modifyBalance(_borrower, _tokenBorrow, _actualCompensatedAmountByAssurance, true); 

			

			emit OnLossCompensatedByAssurance(_tokenPledge, _tokenBorrow, _borrower, _lender, _amountUnRepaiedAmount, _actualCompensatedAmountByAssurance, now);

			_amountUnRepaiedAmount= _amountUnRepaiedAmount.sub(_actualCompensatedAmountByAssurance);

		}



		_amountUnRepaiedPledgeToken= _amountUnRepaiedAmount.mul(_num).div(_denom);



		return _amountUnRepaiedPledgeToken;

	}



	function userRepay(uint256 _id, uint8 _v, bytes32 _r, bytes32 _s) public {

		var (_tokenPledge, _tokenBorrow, _borrower, _lender)= ILoanLogic(contractLoanLogic).getLoanDataPart(_id);

		require(ecrecover(keccak256(abi.encodePacked(this, _id)), _v, _r, _s) == _borrower);

		 

		doRepay(_id, true);

	}



	function forceRepay(uint256[] _arr) public onlyOwner {

		for(uint256 i= 0; i< _arr.length; i++) {

			if(ILoanLogic(contractLoanLogic).needForceClose(_arr[i])) {

				doRepay(_arr[i], false);

			}

		}

	}



	function adjustBalancesAfterRepay(address _tokenPledge, address _tokenBorrow, address _borrower, address _lender, uint256 _amountActualInterest, uint256 _amountRepaiedPeldgeToken, uint256 _amountRepaiedBorrowToken, uint256 _amountLoss) private {

		uint256 _amountProfit= (_amountActualInterest.mul(commissionRatio))/ 100;

		IBalance(contractBalance).modifyBalance(_borrower, _tokenPledge, _amountRepaiedPeldgeToken.add(_amountActualInterest), false); 

		IBalance(contractBalance).modifyBalance(_lender, _tokenPledge, _amountActualInterest.sub(_amountProfit), true);

		 		 

		if(_amountRepaiedBorrowToken> 0) {

			IBalance(contractBalance).modifyBalance(_borrower, _tokenBorrow, _amountRepaiedBorrowToken, false);

			IBalance(contractBalance).modifyBalance(_lender, _tokenBorrow, _amountRepaiedBorrowToken, true);

		}



		if(_amountLoss> 0) {

			if(IBalance(contractBalance).getAvailableBalance(_tokenPledge, accountCost)/ 10> _amountLoss) {

				IBalance(contractBalance).modifyBalance(accountCost, _tokenPledge, _amountLoss, false); 

				IBalance(contractBalance).modifyBalance(_lender, _tokenPledge, _amountLoss, true); 

				emit OnLossCompensated(_tokenPledge, _tokenBorrow, _borrower, _lender, _amountLoss, _amountLoss, now);

			}

			else {

				uint256 uActualPaiedLoss= IBalance(contractBalance).getAvailableBalance(_tokenPledge, accountCost)/ 10;

				IBalance(contractBalance).modifyBalance(accountCost, _tokenPledge, uActualPaiedLoss, false); 

				IBalance(contractBalance).modifyBalance(_lender, _tokenPledge, uActualPaiedLoss, true); 

				emit OnLossCompensated(_tokenPledge, _tokenBorrow, _borrower, _lender, _amountLoss, uActualPaiedLoss, now);

			}

		}



		IBalance(contractBalance).modifyBalance(_lender, _tokenPledge, _amountRepaiedPeldgeToken, true);



		if(_tokenPledge== address(0)) {

			IBalance(contractBalance).distributeEthProfit(_lender, _amountProfit);

		}

		else {

			IBalance(contractBalance).distributeTokenProfit(_lender, _tokenPledge, _amountProfit);

		}

	}

}