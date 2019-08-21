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

contract MarketData is Ownable {	 

	struct CoinExchangeRatio {

		uint256 num;

		uint256 denom;

	}

	

	mapping (address => mapping (address => CoinExchangeRatio)) public tokenExchangeRatio;	



	constructor (address _owner) public Ownable(_owner) {

	}



	function setTokenExchangeRatio(address[] _tokenNum, address[] _tokenDenom, uint256[] _num, uint256[] _denom) public onlyOwner returns (bool ok) {

		for(uint256 i= 0; i< _tokenNum.length; i++) {

			if(_num[i]!= 0&& _denom[i]!= 0) {

				tokenExchangeRatio[_tokenNum[i]][_tokenDenom[i]].num= _num[i];

				tokenExchangeRatio[_tokenNum[i]][_tokenDenom[i]].denom= _denom[i];

			}

			else

				return false;

		}



		return true;

	}



	function getTokenExchangeRatio(address _tokenNum, address _tokenDenom) public returns (uint256 num, uint256 denom) {

		require(tokenExchangeRatio[_tokenNum][_tokenDenom].num > 0);

		return (tokenExchangeRatio[_tokenNum][_tokenDenom].num, tokenExchangeRatio[_tokenNum][_tokenDenom].denom);

	}

}