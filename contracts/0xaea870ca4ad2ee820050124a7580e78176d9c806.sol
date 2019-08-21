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

contract LoanLogic is Ownable {

	using SafeMath for uint256;

	struct LoanInfo {

	    uint256 id; 

		address tokenPledge;

		address tokenBorrow;

		address borrower;

		address lender;

		uint256 amount;

		uint256 amountPledge;

		uint256 amountInterest;

		uint256 periodDays;

		uint256 timeLoan;

		CoinExchangeRatio cerForceClose;

	}



	struct CoinExchangeRatio {

		uint256 num;

		uint256 denom;

	}

	

	address public contractMarketData;

	address public contractBiLinkLoan;

	uint256 public incrementalId;

	mapping (address => uint256[]) public borrower2LoanInfoId;

	mapping (address => uint256[]) public lender2LoanInfoId;

	mapping (uint256 => LoanInfo) public id2LoanInfo;

	uint256[] allLoanId;



	event OnAddMargin(uint256 id, uint256 amount, address borrower, uint256 timestamp);

	

	constructor (address _owner, address _contractMarketData) public 

		Ownable(_owner) {

		incrementalId= 0;

		contractMarketData= _contractMarketData;

	}

	

	function setBiLinkLoanContract(address _contractBiLinkLoan) public onlyOwner {

		contractBiLinkLoan= _contractBiLinkLoan;

	}



	function getLoanDataPart(uint256 _id) public constant returns (address, address, address, address) {

		LoanInfo memory _li= id2LoanInfo[_id];

		return(_li.tokenPledge, _li.tokenBorrow, _li.borrower, _li.lender);

	}



	function getLoanDataFull(uint256 _id) public constant returns (address, address, address, address,uint256,uint256,uint256,uint256,uint256,uint256,uint256) {

		LoanInfo memory _li= id2LoanInfo[_id];

		return(_li.tokenPledge, _li.tokenBorrow, _li.borrower, _li.lender, _li.amount, _li.amountPledge, _li.amountInterest, _li.periodDays, _li.timeLoan, _li.cerForceClose.num,_li.cerForceClose.denom);

	}



	function getTotalPledgeAmount(address _token, address _account) public constant returns (uint256) {

		uint256 _amountPledge= 0; 

		for(uint256 i= 0; i<borrower2LoanInfoId[_account].length;i++) {

			LoanInfo memory _li= id2LoanInfo[borrower2LoanInfoId[_account][i]];

			if(_li.borrower== _account&& _token== _li.tokenPledge) {

				_amountPledge= _amountPledge.add(_li.amountPledge);

				_amountPledge= _amountPledge.add(_li.amountInterest);

			}

		}

		

		return _amountPledge; 

	}



	function getTotalBorrowAmount(address _token) public constant returns (uint256) {

		uint256 _amountBorrow= 0; 

		for(uint256 i= 0; i< allLoanId.length; i++) {

			LoanInfo memory _li= id2LoanInfo[allLoanId[i]];

			if(_token== _li.tokenBorrow) {

				_amountBorrow= _amountBorrow.add(_li.amount);

			}

		}

		

		return _amountBorrow; 

	}



	function hasUnpaidLoan(address _account) public constant returns (bool) {

		return (borrower2LoanInfoId[_account].length!= 0|| lender2LoanInfoId[_account].length!= 0 );

	}



	function getUnpaiedLoanInfo(address _tokenPledge, address _tokenBorrow, address _account, bool _borrowOrLend) public constant returns (uint256[]) {

	    uint256[] memory _arrId= new uint256[]((_borrowOrLend? borrower2LoanInfoId[_account].length: lender2LoanInfoId[_account].length));

		uint256 _count= 0;



		if(_borrowOrLend) {

		    for(uint256 i= 0; i<borrower2LoanInfoId[_account].length;i++) {

			    if(id2LoanInfo[borrower2LoanInfoId[_account][i]].tokenBorrow== _tokenBorrow&& id2LoanInfo[borrower2LoanInfoId[_account][i]].tokenPledge== _tokenPledge)

					_arrId[_count++]= borrower2LoanInfoId[_account][i];

			}

		}

		else {

		    for(i= 0; i<lender2LoanInfoId[_account].length;i++) {

			    if(id2LoanInfo[lender2LoanInfoId[_account][i]].tokenBorrow== _tokenBorrow&& id2LoanInfo[lender2LoanInfoId[_account][i]].tokenPledge== _tokenPledge)

					_arrId[_count++]= lender2LoanInfoId[_account][i];

			}

		}



		return _arrId;

	}

	 

	function getPledgeAmount(address _tokenPledge, address _tokenBorrow, uint256 _amount,uint16 _ratioPledge) public constant returns (uint256) {

		(uint256 _num, uint256 _denom)= IMarketData(contractMarketData).getTokenExchangeRatio(_tokenPledge, _tokenBorrow);

		if(_num!= 0)

			return _num.mul(_amount).mul(_ratioPledge).div(_denom).div(100);

		else

			return 0;

	}



	function updateDataAfterTrade(address _tokenPledge, address _tokenBorrow, address _borrower, address _lender,

		uint256 _amount, uint256 _amountPledge, uint256 _amountInterest, uint256 _periodDays) public returns (bool) {

		require(msg.sender== contractBiLinkLoan);



		CoinExchangeRatio memory _cerForceCloseLine= getForceCloseLine(_tokenPledge, _tokenBorrow, _amountPledge, _amount);



		incrementalId= incrementalId.add(1);

		LoanInfo memory _li= LoanInfo({id:incrementalId, tokenPledge: _tokenPledge, tokenBorrow: _tokenBorrow, borrower: _borrower, lender: _lender

		    , amount: _amount, amountPledge: _amountPledge, amountInterest: _amountInterest, periodDays: _periodDays, timeLoan: now, cerForceClose:_cerForceCloseLine});

		borrower2LoanInfoId[_borrower].push(incrementalId);

		lender2LoanInfoId[_lender].push(incrementalId);



		id2LoanInfo[incrementalId]= _li;

		allLoanId.push(incrementalId);



		return true;

	}



	function getForceCloseLine(address _tokenPledge, address _tokenBorrow, uint256 _amountPledge, uint256 _amount) private returns (CoinExchangeRatio _cerForceCloseLine) {

		(uint256 _num, uint256 _denom)= IMarketData(contractMarketData).getTokenExchangeRatio(_tokenPledge, _tokenBorrow);

		uint256 _ratioPledge= _amountPledge.mul(100).mul(_denom).div(_amount).div(_num);

		return CoinExchangeRatio({num:_num* _ratioPledge, denom:_denom* ((_ratioPledge- 100)/ 4+ 100)});

	}



	function updateDataAfterRepay(uint256 _id, uint256 _availableAmountOfBorrower) public returns (uint256, uint256, uint256, uint256, uint256) {

		require(msg.sender== contractBiLinkLoan);

		LoanInfo memory _li= id2LoanInfo[_id];

		

		deleteLoan(_li);



		if(_availableAmountOfBorrower>= _li.amount) {

			return(_li.amount, _li.amountInterest, getActualInterest(_li), 0, _li.amountPledge);

		}

		else {

			return(_li.amount, _li.amountInterest, getActualInterest(_li), (_li.amount- _availableAmountOfBorrower), _li.amountPledge);

		}

	}



	function deleteLoan (LoanInfo _li) private {

		uint256 _indexOne;

		for(_indexOne= 0; _indexOne< borrower2LoanInfoId[_li.borrower].length; _indexOne++) {

		    if(borrower2LoanInfoId[_li.borrower][_indexOne]== _li.id) {

				break;

		    }

		}

		 

		uint256 _indexTwo;

		for(_indexTwo= 0; _indexTwo< lender2LoanInfoId[_li.lender].length; _indexTwo++) {

		    if(lender2LoanInfoId[_li.lender][_indexTwo]== _li.id) {

				break;

		    }

		}



		for(uint256 i= 0; i< allLoanId.length; i++) {

			if(allLoanId[i]== _li.id) {

				if(i< allLoanId.length- 1&& allLoanId.length> 1)

					allLoanId[i]= allLoanId[allLoanId.length- 1];

				delete allLoanId[allLoanId.length- 1];

				allLoanId.length--;

				break;

			}

		}



		delete(id2LoanInfo[_li.id]);

		

		if(_indexOne< borrower2LoanInfoId[_li.borrower].length- 1&& borrower2LoanInfoId[_li.borrower].length> 1)

			borrower2LoanInfoId[_li.borrower][_indexOne]= borrower2LoanInfoId[_li.borrower][borrower2LoanInfoId[_li.borrower].length- 1];

		delete borrower2LoanInfoId[_li.borrower][borrower2LoanInfoId[_li.borrower].length- 1];

		borrower2LoanInfoId[_li.borrower].length--;

		 

		if(_indexTwo< lender2LoanInfoId[_li.lender].length- 1&& lender2LoanInfoId[_li.lender].length> 1)

			lender2LoanInfoId[_li.lender][_indexTwo]= lender2LoanInfoId[_li.lender][lender2LoanInfoId[_li.lender].length- 1];

		delete lender2LoanInfoId[_li.lender][lender2LoanInfoId[_li.lender].length- 1];

		lender2LoanInfoId[_li.lender].length--;

	}



	function getActualInterest(LoanInfo _li) private returns (uint256) {

		uint256 _elapsedDays= (now.sub(_li.timeLoan))/ (24* 3600)+ 1;

		if(_elapsedDays> _li.periodDays)

			_elapsedDays= _li.periodDays;



		return _li.amountInterest.mul(_elapsedDays).div(_li.periodDays);

	}



	function checkForceClose() public constant returns(uint256[]) {

		uint256[] memory _arrId= new uint256[](allLoanId.length);

		uint256 _count= 0;

		for(uint256 i= 0; i< allLoanId.length; i++) {

			if(needForceClose(allLoanId[i]))

				_arrId[_count++]= allLoanId[i];

		}



		return _arrId;

	}



	function needForceClose(uint256 _id) public constant returns (bool) {

		LoanInfo memory _li= id2LoanInfo[_id];

		uint256 _totalDays= (now.sub(_li.timeLoan))/ (24* 3600);

		if(_totalDays>= _li.periodDays) {

			return true;

		}

		else {

			(uint256 _num, uint256 _denom)= IMarketData(contractMarketData).getTokenExchangeRatio(_li.tokenPledge, _li.tokenBorrow);

			if(_num* _li.cerForceClose.denom> _denom* _li.cerForceClose.num) {

				return true;

			}

		}



		return false;

	}



	function addMargin(uint256 _id, uint256 _amount) public {

		LoanInfo memory _li= id2LoanInfo[_id];

		require(_amount> 0&& _li.borrower!= address(0)&& _li.borrower==msg.sender);



		id2LoanInfo[_id].amountPledge= id2LoanInfo[_id].amountPledge.add(_amount);

		emit OnAddMargin(_id, _amount, _li.borrower, now);

	}

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

contract IMarketData {

	function getTokenExchangeRatio(address _tokenNum, address _tokenDenom) public returns (uint256 num, uint256 denom);

}