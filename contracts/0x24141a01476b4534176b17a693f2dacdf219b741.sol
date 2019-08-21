pragma solidity ^0.4.13;

contract IMarketData {

	function getTokenExchangeRatio(address _tokenNum, address _tokenDenom) public returns (uint256 num, uint256 denom);

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

contract ILoanLogic {

	function getTotalPledgeAmount(address token, address account) public constant returns (uint256);

	function hasUnpaidLoan(address account) public constant returns (bool);

	function getTotalBorrowAmount(address _token) public constant returns (uint256);

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

contract Balance is Ownable {

	using SafeMath for uint256;

     

	mapping (address => mapping (address => uint256)) public account2Token2Balance;

	mapping (address => uint256) public token2ProfitShare;

	mapping (address => address) public token2AssuranceAccount;

	mapping (address => uint256) public assuranceAccount2LastDepositTime;



	address public contractBLK;

	address public contractBiLinkLoan;

	address public contractLoanLogic;

	address public contractBiLinkExchange;

	address public contractMarketData;

	

	address public accountCost;

	uint256 public ratioProfit2Cost;//percentage

	uint256 public ratioProfit2BuyBLK;//percentage

	uint256 public ETH_BLK_MULTIPLIER= 1000;

	uint256 public amountEthToBuyBLK;

	uint256 public priceBLK;//eth



	bool public isLegacy;//if true, not allow new trade,new deposit

	bool private depositingTokenFlag;



	event OnShareProfit(address token, uint256 amount, uint256 timestamp );

	event OnSellBLK(address account, uint256 amount, uint256 timestamp );

	

	event OnDeposit(address token, address account, uint256 amount, uint256 balance, uint256 timestamp);

	event OnWithdraw(address token, address account, uint256 amount, uint256 balance, uint256 timestamp);

	event OnFundsMigrated(address account, address newContract, uint256 timestamp);



    constructor (address _owner, address _contractBLK, address _contractBiLinkLoan, address _contractLoanLogic, address _contractBiLinkExchange, address _contractMarketData

		, address _accountCost, uint256 _ratioProfit2Cost, uint256 _ratioProfit2BuyBLK, uint256 _priceBLK) public Ownable(_owner) {

		contractBLK= _contractBLK;

		contractBiLinkExchange= _contractBiLinkExchange;

		contractBiLinkLoan= _contractBiLinkLoan;

		contractLoanLogic= _contractLoanLogic;

		contractMarketData= _contractMarketData;

		accountCost= _accountCost;

		ratioProfit2Cost= _ratioProfit2Cost;

		ratioProfit2BuyBLK= _ratioProfit2BuyBLK;

		priceBLK= _priceBLK;

	}



	function setThisContractAsLegacy() public onlyOwner {

		isLegacy= true;

	}



	function setRatioProfit2Cost(uint256 _ratio) public onlyOwner {

		require(_ratio <= 20);

		ratioProfit2Cost= _ratio;

	}



	function setRatioProfit2BuyBLK(uint256 _ratio) public onlyOwner {

		ratioProfit2BuyBLK= _ratio;

	}



	function setTokenAssuranceAccount(address _token, address _account) public onlyOwner {

		require(token2AssuranceAccount[_token]== address(0));



		token2AssuranceAccount[_token]= _account;

	}



	function getTokenAssuranceAccount(address _token) public constant returns (address) {

		return token2AssuranceAccount[_token];

	}



	function getTokenAssuranceAmount(address _token) public constant returns (uint256) {

		return account2Token2Balance[token2AssuranceAccount[_token]][_token];

	}



	function depositEther() public payable {

		require(isLegacy== false);



		account2Token2Balance[msg.sender][address(0)]= account2Token2Balance[msg.sender][address(0)].add(msg.value);

		emit OnDeposit(0, msg.sender, msg.value, account2Token2Balance[msg.sender][0], now);

	}



	function withdrawEther(uint256 _amount) public {

		require(account2Token2Balance[msg.sender][0] >= _amount);

		account2Token2Balance[msg.sender][0] = account2Token2Balance[msg.sender][0].sub(_amount);



		msg.sender.transfer(_amount);

		emit OnWithdraw(0, msg.sender, _amount, account2Token2Balance[msg.sender][0], now);

	}



	function depositToken(address _token, uint256 _amount) public {

		require(_token != address(0)&& isLegacy== false);

		depositingTokenFlag = true;

		require(IToken(_token).transferFrom(msg.sender, this, _amount));

		depositingTokenFlag = false;



		if(token2AssuranceAccount[_token]== msg.sender)

			assuranceAccount2LastDepositTime[msg.sender]= now;

		 

		account2Token2Balance[msg.sender][_token] = account2Token2Balance[msg.sender][_token].add(_amount);

		emit OnDeposit(_token, msg.sender, _amount, account2Token2Balance[msg.sender][_token], now);

	}



	function withdrawToken(address _token, uint256 _amount) public {

		require(_token != address(0));

		require(account2Token2Balance[msg.sender][_token] >= _amount);



		if(token2AssuranceAccount[_token]== msg.sender) {

			require(_amount<= account2Token2Balance[msg.sender][_token].sub(ILoanLogic(contractLoanLogic).getTotalBorrowAmount(_token)));

			require(now.sub(assuranceAccount2LastDepositTime[msg.sender]) > 30 * 24 * 3600);

		}



		account2Token2Balance[msg.sender][_token] = account2Token2Balance[msg.sender][_token].sub(_amount);

		require(IToken(_token).transfer(msg.sender, _amount));

		emit OnWithdraw(_token, msg.sender, _amount, account2Token2Balance[msg.sender][_token], now);

	}



	function tokenFallback( address _sender, uint256 _amount, bytes _data) public returns (bool ok) {

		if (depositingTokenFlag) {

			// Transfer was initiated from depositToken(). User token balance will be updated there.

			return true;

		} 

		else {

			// Direct ECR223 Token.transfer into this contract not allowed, to keep it consistent

			// with direct transfers of ECR20 and ETH.

			revert();

		}

	}



	function getBalance(address _token, address _account) public constant returns (uint256, uint256) {		

		return (account2Token2Balance[_account][_token] , getAvailableBalance(_token, _account)); 

	}



	function getAvailableBalance(address _token, address _account) public constant returns (uint256) {		

		return account2Token2Balance[_account][_token].sub(ILoanLogic(contractLoanLogic).getTotalPledgeAmount(_token, _account)); 

	}



	function modifyBalance(address _account, address _token, uint256 _amount, bool _addOrSub) public {

		require(msg.sender== contractBiLinkLoan|| msg.sender== contractBiLinkExchange);



		if(_addOrSub)

			account2Token2Balance[_account][_token]= account2Token2Balance[_account][_token].add(_amount);

		else

			account2Token2Balance[_account][_token]= account2Token2Balance[_account][_token].sub(_amount);

	}



	function distributeEthProfit (address _profitMaker, uint256 _amount) public {

		uint256 _amountCost= _amount.mul(ratioProfit2Cost).div(100);

		account2Token2Balance[accountCost][address(0)]= account2Token2Balance[accountCost][address(0)].add(_amountCost);



		uint256 _amountToBuyBLK= _amount.mul(ratioProfit2BuyBLK).div(100);

		amountEthToBuyBLK= amountEthToBuyBLK.add(_amountToBuyBLK);



		token2ProfitShare[address(0)]= token2ProfitShare[address(0)].add(_amount.sub(_amountCost).sub(_amountToBuyBLK));

		

		IBiLinkToken(contractBLK).mint(_profitMaker, _amountToBuyBLK.mul(ETH_BLK_MULTIPLIER));

	}

	

	function distributeTokenProfit (address _profitMaker, address _token, uint256 _amount) public {

		token2ProfitShare[_token]= token2ProfitShare[_token].add(_amount);



		(uint256 _num, uint256 _denom)= IMarketData(contractMarketData).getTokenExchangeRatio(address(0), _token);

		IBiLinkToken(contractBLK).mint(_profitMaker, _amount.mul(_num* 5).div(_denom* 8).mul(ETH_BLK_MULTIPLIER));

	}



	function shareProfit(address _token) public {

		require(token2ProfitShare[_token]> 0);



		uint256 _amountBLKMined= IBiLinkToken(contractBLK).totalSupply();

		uint256 _amountEachBLKShare= token2ProfitShare[_token].div(_amountBLKMined);

		require(_amountEachBLKShare> 0);



		token2ProfitShare[_token]= token2ProfitShare[_token].sub(_amountBLKMined.mul(_amountEachBLKShare));



		address[] memory _accounts= IBiLinkToken(contractBLK).getCanShareProfitAccounts();

		for(uint256 i= 0; i< _accounts.length; i++) {

			uint256 _balance= IBiLinkToken(contractBLK).balanceOf(_accounts[i]);

			if(_balance> 0)

				require(IToken(_token).transfer(_accounts[i], _balance.mul(_amountEachBLKShare)));

		}



		emit OnShareProfit(_token, _amountBLKMined.mul(_amountEachBLKShare), now);

	}



	function migrateFund(address _newContract, address[] _tokens) public {

		require(_newContract != address(0)&& ILoanLogic(contractLoanLogic).hasUnpaidLoan(msg.sender)== false);

    

		Balance _newBalance= Balance(_newContract);



		uint256 _amountEther = account2Token2Balance[msg.sender][0];

		if (_amountEther > 0) {

			account2Token2Balance[msg.sender][0] = 0;

			_newBalance.depositFromUserMigration.value(_amountEther)(msg.sender);

		}



		for (uint16 n = 0; n < _tokens.length; n++) {

			address _token = _tokens[n];

			require(_token != address(0)); // Ether is handled above.

			uint256 _amountToken = account2Token2Balance[msg.sender][_token];

      

			if (_amountToken != 0) {      

				require(IToken(_token).approve(_newBalance, _amountToken));

				account2Token2Balance[msg.sender][_token] = 0;

				_newBalance.depositTokenFromUserMigration(_token, _amountToken, msg.sender);

			}

		}



		emit OnFundsMigrated(msg.sender, _newBalance, now);

	}

	 

	function depositFromUserMigration(address _account) public payable {

		require(_account != address(0));

		require(msg.value > 0);

		account2Token2Balance[_account][0] = account2Token2Balance[_account][0].add(msg.value);

	}

  

	function depositTokenFromUserMigration(address _token, uint _amount, address _account) public {

		require(_token != address(0));

		require(_account != address(0));

		require(_amount > 0);

		depositingTokenFlag = true;

		require(IToken(_token).transferFrom(msg.sender, this, _amount));

		depositingTokenFlag = false;

		account2Token2Balance[_account][_token] = account2Token2Balance[_account][_token].add(_amount);

	}

	

	function getRemainBuyBLKAmount() public constant returns (uint256) {

		return amountEthToBuyBLK;

	}



	function sellBLK(uint256 _amountBLK) public {

		require(_amountBLK> 0);

		account2Token2Balance[msg.sender][contractBLK]= account2Token2Balance[msg.sender][contractBLK].sub(_amountBLK);

		uint256 _amountEth= _amountBLK.mul(priceBLK).div(1 ether);

		amountEthToBuyBLK= amountEthToBuyBLK.sub(_amountEth);

		account2Token2Balance[msg.sender][address(0)]= account2Token2Balance[msg.sender][address(0)].add(_amountEth);



		IBiLinkToken(contractBLK).burn(_amountBLK);



		emit OnSellBLK(msg.sender, _amountBLK, now);

	}

}

contract IBiLinkToken is IToken {

	function getCanShareProfitAccounts() public constant returns (address[]);

	function totalSupply() public view returns (uint256);

	function balanceOf(address _account) public view returns (uint256);

	function mint(address _to, uint256 _amount) public returns (bool);

	function burn(uint256 amount) public;

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