/**
 * DELFI is an on-chain price oracle you can reason about
 * it provides a liquidity-weighted index of ETH/DAI prices from decentralized exchanges
 * the price is backed up by the ETH amount required to move the rate more than 5%
 * this provides a quantifiable threshold of economic activity the price can safely support

                                   ___---___
                             ___---___---___---___
                       ___---___---         ---___---___
                 ___---___---                    ---___---___
           ___---___---            D E L F I          ---___---___
     ___---___---                   eth/dai                  ---___---___
__---___---_________________________________________________________---___---__
===============================================================================
 ||||                                                                     ||||
 |---------------------------------------------------------------------------|
 |___-----___-----___-----___-----___-----___-----___-----___-----___-----___|
 / _ \===/ _ \   / _ \===/ _ \   / _ \===/ _ \   / _ \===/ _ \   / _ \===/ _ \
( (.\ oOo /.) ) ( (.\ oOo /.) ) ( (.\ oOo /.) ) ( (.\ oOo /.) ) ( (.\ oOo /.) )
 \__/=====\__/   \__/=====\__/   \__/=====\__/   \__/=====\__/   \__/=====\__/
    |||||||         |||||||         |||||||         |||||||         |||||||
    |||||||         |||||||         |||||||         |||||||         |||||||
    |||||||         |||||||         |||||||         |||||||         |||||||
    |||||||         |||||||         |||||||         |||||||         |||||||
    |||||||         |||||||         |||||||         |||||||         |||||||
    |||||||         |||||||         |||||||         |||||||         |||||||
    |||||||         |||||||         |||||||         |||||||         |||||||
    |||||||         |||||||         |||||||         |||||||         |||||||
    (oOoOo)         (oOoOo)         (oOoOo)         (oOoOo)         (oOoOo)
    J%%%%%L         J%%%%%L         J%%%%%L         J%%%%%L         J%%%%%L
   ZZZZZZZZZ       ZZZZZZZZZ       ZZZZZZZZZ       ZZZZZZZZZ       ZZZZZZZZZ
  ===========================================================================
__|_________________________________________________________________________|__
_|___________________________________________________________________________|_
|_____________________________________________________________________________|
_______________________________________________________________________________

 */

pragma solidity ^0.5.4;

//////////////
//INTERFACES//
//////////////

contract ERC20 {
	function balanceOf(address) external view returns(uint256) {}
}

contract Uniswap {
	function getEthToTokenInputPrice(uint256) external view returns(uint256) {}
	function getTokenToEthOutputPrice(uint256) external view returns(uint256) {}
}

contract Eth2Dai {
	function getBuyAmount(address, address, uint256) external view returns(uint256) {}
	function getPayAmount(address, address, uint256) external view returns(uint256) {}
}

contract Bancor {
	function getReturn(address, address, uint256) external view returns(uint256, uint256) {}
}

contract BancorDai {
	function getReturn(address, address, uint256) external view returns(uint256) {}
}

contract Kyber {
	function searchBestRate(address, address, uint256, bool) external view returns(address, uint256) {}
}

/////////////////
//MAIN CONTRACT//
/////////////////

contract Delfi {

	///////////////////
	//STATE VARIABLES//
	///////////////////

	/** latest ETH/DAI price */
	uint256 public latestRate;
	/** block number of latest state update */
	uint256 public latestBlock;
	/** latest cost to move the price 5% */
	uint256 public latestCostToMovePrice;

	uint256 constant public ONE_ETH = 10**18;
	uint256 constant public FIVE_PERCENT = 5;
	
	address constant public DAI = 0x89d24A6b4CcB1B6fAA2625fE562bDD9a23260359;
	address constant public WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
	address constant public BNT = 0x1F573D6Fb3F13d689FF844B4cE37794d79a7FF1C;
	address constant public UNISWAP = 0x09cabEC1eAd1c0Ba254B09efb3EE13841712bE14;
	address constant public ETH2DAI = 0x39755357759cE0d7f32dC8dC45414CCa409AE24e;
	address constant public BANCOR = 0xCBc6a023eb975a1e2630223a7959988948E664f3;
	address constant public BANCORDAI = 0x587044b74004E3D5eF2D453b7F8d198d9e4cB558;
	address constant public BANCORETH = 0xc0829421C1d260BD3cB3E0F06cfE2D52db2cE315;
	address constant public KYBER = 0x9ae49C0d7F8F9EF4B864e004FE86Ac8294E20950;
	address constant public KYBERETH = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;
	address constant public KYBER_OASIS_RESERVE = 0x04A487aFd662c4F9DEAcC07A7B10cFb686B682A4;
	address constant public KYBER_UNISWAP_RESERVE = 0x13032DeB2d37556cf49301f713E9d7e1d1A8b169;


	///////////////////////////
	//CONTRACT INSTANTIATIONS//
	///////////////////////////
	
	ERC20 constant dai = ERC20(DAI);
	Uniswap constant uniswap = Uniswap(UNISWAP);
	Eth2Dai constant eth2dai = Eth2Dai(ETH2DAI);
	Bancor constant bancor = Bancor(BANCOR);
	BancorDai constant bancordai = BancorDai(BANCORDAI);
	Kyber constant kyber = Kyber(KYBER);

	///////////////
	//CONSTRUCTOR//
	///////////////
	
	constructor() public {
		/** set intial values */
		updateCurrentRate(); 
	}

	///////////
	//METHODS//
	///////////
	
	/**
	 * get the DAI balance of an address
	 * @param _owner address of token holder
	 * @return _tokenAmount token balance of holder in smallest unit
	 */
	function getDaiBalance(
		address _owner
	) 
	public 
	view 
	returns(
		uint256 _tokenAmount
	) {
		return dai.balanceOf(_owner);
	}

	/**
	 * get the non-token ETH balance of an address
	 * @param _owner address to check
	 * @return _ethAmount amount in wei
	 */
	function getEthBalance(
	    address _owner
	) 
	public 
	view 
	returns(
	    uint256 _ethAmount
	) {
	    return _owner.balance;
	}

	/**
	 * get the buy price of DAI on uniswap
	 * @param _ethAmount amount of ETH being spent in wei
	 * @return _rate returned as a rate in wei
	 */
	function getUniswapBuyPrice(
		uint256 _ethAmount
	)
	public 
	view 
	returns(
		uint256 _rate
	) {
		uint256 tokenAmount = uniswap.getEthToTokenInputPrice(_ethAmount);
		return (tokenAmount * ONE_ETH) / _ethAmount;
	}

	/**
	 * get the sell price of DAI on uniswap
	 * @param _ethAmount amount of ETH being purchased in wei
	 * @return _rate returned as a rate in wei
	 */
	function getUniswapSellPrice(
		uint256 _ethAmount
	)
	public 
	view 
	returns(
		uint256 _rate
	) {
		uint256 ethAmount = uniswap.getTokenToEthOutputPrice(_ethAmount);
		return (ethAmount * ONE_ETH) / _ethAmount;
	}

	/**
	 * get the buy price of DAI on Eth2Dai
	 * @param _ethAmount amount of ETH being spent in wei
	 * @return _rate returned as a rate in wei
	 */
	function getEth2DaiBuyPrice(
		uint256 _ethAmount
	)
	public 
	view 
	returns(
		uint256 _rate
	) {
		uint256 tokenAmount = eth2dai.getBuyAmount(DAI, WETH, _ethAmount);
		return (tokenAmount * ONE_ETH) / _ethAmount;
	}

	/**
	 * get the sell price of DAI on Eth2Dai
	 * @param _ethAmount amount of ETH being purchased in wei
	 * @return _rate returned as a rate in wei
	 */
	function getEth2DaiSellPrice(
		uint256 _ethAmount
	)
	public 
	view 
	returns(
		uint256 _rate
	) {
		uint256 ethAmount = eth2dai.getPayAmount(DAI, WETH, _ethAmount);
		return (ethAmount * ONE_ETH) / _ethAmount;
	}

	/**
	 * get the buy price of DAI on Bancor
	 * @param _ethAmount amount of ETH being spent in wei
	 * @return _rate returned as a rate in wei
	 */
	function getBancorBuyPrice(
		uint256 _ethAmount
	)
	public 
	view 
	returns(
		uint256 _rate
	) {
		/** convert from eth to bnt */
		/** parse tuple return value */
		uint256 bntAmount;
		(bntAmount,) = bancor.getReturn(BANCORETH, BNT, _ethAmount);
		/** convert from bnt to eth */
		uint256 tokenAmount = bancordai.getReturn(BNT, DAI, bntAmount);
		return (tokenAmount * ONE_ETH) / _ethAmount;
	}

	/**
	 * get the sell price of DAI on Bancor
	 * @param _ethAmount amount of ETH being purchased in wei
	 * @return _rate returned as a rate in wei
	 */
	function getBancorSellPrice(
		uint256 _ethAmount
	)
	public 
	view 
	returns(
		uint256 _rate
	) {
		uint256 roughTokenAmount = (latestRate * _ethAmount) / ONE_ETH;
		/** convert from dai to bnt*/
		uint256 bntAmount = bancordai.getReturn(DAI, BNT, roughTokenAmount);
		/** convert from bnt to eth */
		/** parse tuple return value */
		uint256 ethAmount;
		(ethAmount,) = bancor.getReturn(BNT, BANCORETH, bntAmount);
		return (ONE_ETH * roughTokenAmount) / ethAmount;
	}

	/**
	 * get the buy price of DAI on Kyber
	 * @param _ethAmount amount of ETH being spent in wei
	 * @return _reserveAddress reserve address with best rate
	 * @return _rate returned as a rate in wei
	 */
	function getKyberBuyPrice(
		uint256 _ethAmount
	)
	public 
	view
	returns(	
	  address _reserveAddress,
		uint256 _rate
	) {
		return kyber.searchBestRate(KYBERETH, DAI, _ethAmount, true);
	}

	/**
	 * get the sell price of DAI on Kyber
	 * @param _ethAmount amount of ETH being purchased in wei
	 * @return _reserveAddress reserve address with best rate
	 * @return _rate returned as a rate in wei
	 */
	function getKyberSellPrice(
		uint256 _ethAmount
	)
	public 
	view
	returns(
		address _reserveAddress,
		uint256 _rate
	) {
		/** get an approximate token amount to calculate ETH returned */
		/** if there is no recent price, calc current kyber buy price */
		uint256 recentRate;
		if (block.number > latestRate + 100) {
			(,recentRate) = getKyberBuyPrice(_ethAmount);
		} else {
			recentRate = latestRate;	
		}
		uint256 ethAmount;
		address reserveAddress;
		(reserveAddress, ethAmount) = kyber.searchBestRate(DAI, KYBERETH, _ethAmount, true);
	    uint256 tokenAmount = (_ethAmount * ONE_ETH) / ethAmount;
	    return (reserveAddress, (tokenAmount * ONE_ETH) / _ethAmount);
	}

	/**
	 * get the most recent saved rate
	 * cheap to call but information may be outdated
	 * @return _rate most recent saved ETH/DAI rate in wei
	 * @return _block block.number the most recent state was saved
	 * @return _costToMoveFivePercent cost to move the price 5% in wei
	 */
	function getLatestSavedRate() 
	view
	public
	returns(
		uint256 _rate,
		uint256 _block,
		uint256 _costToMoveFivePercent
	) {
		return (latestRate, latestBlock, latestCostToMovePrice);
	}

	/**
	 * updates the price information to the current block and returns this information
	 * comparatively expensive to call but always up to date
	 * @return _rate most recent saved ETH/DAI rate in wei
	 * @return _block block.number the most recent state was saved
	 * @return _costToMoveFivePercent cost to move the price 5% in wei
	 */
	function getLatestRate()
	external
	returns(
		uint256 _rate,
		uint256 _block,
		uint256 _costToMoveFivePercent
	) {
		updateCurrentRate();
		return (latestRate, latestBlock, latestCostToMovePrice);
	}

	//////////////////////
	//INTERNAL FUNCTIONS//
	//////////////////////

	/**
	 * updates the current rate in state
	 * @return _rate most recent saved ETH/DAI rate in wei
	 * @return _costToMoveFivePercent cost to move the price 5% in wei 
	 */
	function updateCurrentRate()  
	internal 
	returns(
	  uint256 _rate,
		uint256 _costToMoveFivePercent
	) {

		/** find midpoints of each spread */
		uint256[3] memory midPointArray = [
		    findMidPoint(getUniswapBuyPrice(ONE_ETH), getUniswapSellPrice(ONE_ETH)),
		    findMidPoint(getBancorBuyPrice(ONE_ETH), getBancorBuyPrice(ONE_ETH)),
		    findMidPoint(getEth2DaiBuyPrice(ONE_ETH), getEth2DaiSellPrice(ONE_ETH))
		];

		/** find liquidity of pooled exchanges */
		uint256 uniswapLiquidity = getEthBalance(UNISWAP);
		uint256 bancorLiquidity = getDaiBalance(BANCORDAI) * ONE_ETH / midPointArray[1]; 
		uint256 eth2daiRoughLiquidity = getDaiBalance(ETH2DAI) * ONE_ETH / midPointArray[2]; 
        
		/** cost of percent move for pooled exchanges */
		/** 2.5% of liquidity is approximately a 5% price move */
		uint256 costToMovePriceUniswap = (uniswapLiquidity * FIVE_PERCENT) / 50; 
		uint256 costToMovePriceBancor = (bancorLiquidity * FIVE_PERCENT) / 50;
		
		/** divide by price difference */
		uint256 largeBuy = eth2daiRoughLiquidity / 2;
		uint256 priceMove = getEth2DaiBuyPrice(largeBuy);
		uint256 priceMovePercent = ((midPointArray[2] * 10000) / priceMove) - 10000;
		
		/** ensure largeBuy causes a price move more than _percent */
		/** increase large buy amount if necessary */
		if (priceMovePercent < FIVE_PERCENT * 100) {
			largeBuy += eth2daiRoughLiquidity - 1;
			priceMove = getEth2DaiBuyPrice(largeBuy);
			priceMovePercent = ((midPointArray[2] * 10000) / priceMove) - 10000;
		}

		uint256 ratioOfPriceMove = FIVE_PERCENT * 10000 / priceMovePercent;
 		uint256 costToMovePriceEth2Dai = largeBuy * ratioOfPriceMove / 100;
		
		/** information stored in memory arrays to avoid stack depth issues */
		uint256[3] memory costOfPercentMoveArray = [costToMovePriceUniswap, costToMovePriceBancor, costToMovePriceEth2Dai];
        
    return calcRatio(midPointArray, costOfPercentMoveArray);
	}
	
	/**
	 * extension of previous method used to update state
	 * @return _rate most recent saved ETH/DAI rate in wei
	 * @return _costToMoveFivePercent cost to move the price 5% in wei 
	 */
	function calcRatio(
		uint256[3] memory _midPointArray,
		uint256[3] memory _costOfPercentMoveArray
	) 
	internal
	returns(
		uint256 _rate,
		uint256 _costToMoveFivePercent
	)
	{
		uint256 totalCostOfPercentMove = _costOfPercentMoveArray[0] + _costOfPercentMoveArray[1] + _costOfPercentMoveArray[2];
		
		/** calculate proportion of each exchange in the formula */
		/** precise to two decimals */
		uint256 precision = 10000; 
		uint256[3] memory propotionArray;
		propotionArray[0] = (_costOfPercentMoveArray[0] * precision) / totalCostOfPercentMove;
		propotionArray[1] = (_costOfPercentMoveArray[1] * precision) / totalCostOfPercentMove;
		propotionArray[2] = (_costOfPercentMoveArray[2] * precision) / totalCostOfPercentMove;

		/** balance prices */
		uint256 balancedRate = 
			(
				(_midPointArray[0] * propotionArray[0]) + 
				(_midPointArray[1] * propotionArray[1]) + 
				(_midPointArray[2] * propotionArray[2])
			) 
			/ precision;

		latestRate = balancedRate;
		latestBlock = block.number;
		latestCostToMovePrice = totalCostOfPercentMove;

		return (balancedRate, totalCostOfPercentMove);
	}

	/**
	 * utility function to find mean of an array of values
	 * no safe math, yolo
	 * @param _a first value
	 * @param _b second value
	 * @return _midpoint average value
	 */
	function findMidPoint(
		uint256 _a, 
		uint256 _b
	) 
	internal 
	pure 
	returns(
		uint256 _midpoint
		) {
		return (_a + _b) / 2;
	}


	////////////
	//FALLBACK//
	////////////

	/**
	 * non-payable fallback function
	 * this is redundant but more explicit than not including a fallback
	 */
	function() external {}

}