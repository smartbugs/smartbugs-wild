/**
 *
 * https://ethergarden.host
 *
 * Welcome to Ether Garden!
 * Here you can earn Ethereum, growing four kinds of vegetables. 
 * You will get random kind of vegetable for growing with the first transaction.
 * One acre of garden field gives one vegetable per day. The more acres you have, the more vegetables they give.
 * Attention! Market value of each vegetable will be different. Less grown vegetables will be more expensive.
 * Also market value depends on contract balance, number of all bought acres and  number of all grown vegetables.
 *
 * Send from 0 to 0.00001 ether for sell your all grown vegetables or getting FREE acres, if you have no one acre.
 * Send 0.00001111 ether for reinvest all grown vegetables to the new acres.
 * Minimum invest amount for fields buying is 0.001 ETH.
 * Use 150000 of Gas limit for your transactions.
 *
 * Marketing commissions: 4% for buying arces
 * Admin commissions: 4% for selling vegetable
 * Referrer: 4%
 *
 */

pragma solidity ^0.4.25; 

contract EtherGarden{

    using SafeMath for uint256;
 
    struct Farmer {
		uint8   vegetableId;
        uint256 startGrowing;
        uint256 fieldSize;
    }

	mapping (uint8 => uint256) public vegetablesTradeBalance;
	mapping (address => Farmer) public farmers;

	uint256 maxVegetableId = 4;
	uint256 minimumInvest = 0.001 ether;
	uint256 growingSpeed = 1 days; 
	
	bool public gameStarted = false;
	bool public initialized = false;
	address public marketing = 0x25e6142178Fc3Afb7533739F5eDDD4a41227576A;
	address public admin;
	
    /**
     * @dev Сonstructor Sets the original roles of the contract 
     */
    constructor() public {
        admin = msg.sender;
    }
	
    /**
     * @dev Modifiers
     */	
    modifier onlyAdmin() {
        require(msg.sender == admin);
        _;
    }
    modifier isInitialized() {
        require(initialized && gameStarted);
        _;
    }	

    /**
     * @dev Market functions
     */		
    function() external payable {
		
		Farmer storage farmer = farmers[msg.sender];

		if (msg.value >= 0 && msg.value <= 0.00001 ether) {
			if (farmer.vegetableId == 0) {
				//Set random vegetale for a new farmer	
				rollFieldId();
				
				getFreeField();
			} else
				sellVegetables();
        } 
		else if (msg.value == 0.00001111 ether){
			reInvest();
        } 
		else {
			if (farmer.vegetableId == 0) {
				//Set random vegetale for a new farmer	
				rollFieldId();		
			}
            buyField();
        }		
    }	 

    function sellVegetables() internal isInitialized {
		Farmer storage farmer = farmers[msg.sender];
		
		uint256 value = vegetablesValue(msg.sender);
		if (value > 0) {
			uint256 sellPrice = vegetablePrice(farmer.vegetableId).mul(value);
			
			if (sellPrice > address(this).balance) {
				sellPrice = address(this).balance;
				//stop game
				gameStarted = false;
			}
			
			uint256 fee = devFee(sellPrice);
			
			farmer.startGrowing = now;
			
			//Update market values
			vegetablesTradeBalance[farmer.vegetableId] = vegetablesTradeBalance[farmer.vegetableId].add(value);
			
			admin.transfer(fee);
			msg.sender.transfer(sellPrice.sub(fee));
		}
    }	 
	
    function buyField() internal isInitialized {
		require(msg.value >= minimumInvest, "Too low ETH value");

		Farmer storage farmer = farmers[msg.sender];	

		//Calculate acres number for buying
		uint256 acres = msg.value.div(fieldPrice(msg.value));
        
		if (farmer.startGrowing > 0)
			sellVegetables();
		
		farmer.startGrowing = now;
		farmer.fieldSize = farmer.fieldSize.add(acres);
		
		////Update market values by 20% from the number of the new acres
		vegetablesTradeBalance[farmer.vegetableId] = vegetablesTradeBalance[farmer.vegetableId].add( acres.div(5) );
		
        uint256 fee = devFee(msg.value);
		marketing.send(fee);
		
        if (msg.data.length == 20) {
            address _referrer = bytesToAddress(bytes(msg.data));
			if (_referrer != msg.sender && _referrer != address(0)) {
				 _referrer.send(fee);
			}
        }		
    }
	 
	function reInvest() internal isInitialized {
		
		Farmer storage farmer = farmers[msg.sender];	
		
		uint256 value = vegetablesValue(msg.sender);
		require(value > 0, "No grown vegetables for reinvest");
		
		//Change one vegetable for one acre
		farmer.fieldSize = farmer.fieldSize.add(value);
		farmer.startGrowing = now;
	}
	
    function getFreeField() internal isInitialized {
		Farmer storage farmer = farmers[msg.sender];
		require(farmer.fieldSize == 0);
		
		farmer.fieldSize = freeFieldSize();
		farmer.startGrowing = now;
		
    }
	
    function initMarket(uint256 _newTradeBalance) public payable onlyAdmin{
        require(!initialized);
        initialized = true;
		gameStarted = true;
		
		//Set the first trade balance
		for (uint8 _vegetableId = 1; _vegetableId <= maxVegetableId; _vegetableId++)
			vegetablesTradeBalance[_vegetableId] = _newTradeBalance;
    }	
	
	function rollFieldId() internal {
		Farmer storage farmer = farmers[msg.sender];
		
	    //Set random vegetables field for a new farmer
		farmer.vegetableId = uint8(uint256(blockhash(block.number - 1)) % maxVegetableId + 1);
	}
	
    /**
     * @dev Referrer functions
     */		

	function bytesToAddress(bytes _source) internal pure returns(address parsedreferrer) {
        assembly {
            parsedreferrer := mload(add(_source,0x14))
        }
        return parsedreferrer;
    }	
	
    /**
     * @dev Views
     */		
	 
    function vegetablePrice(uint8 _VegetableId) public view returns(uint256){
		return address(this).balance.div(maxVegetableId).div(vegetablesTradeBalance[_VegetableId]);
    }

    function vegetablesValue(address _Farmer) public view returns(uint256){
		//ONE acre gives ONE vegetable per day. Many acres give vegetables faster.
		return farmers[_Farmer].fieldSize.mul( now.sub(farmers[_Farmer].startGrowing) ).div(growingSpeed);
    }	
	
    function fieldPrice(uint256 _subValue) public view returns(uint256){
	    uint256 CommonTradeBalance;
		
		for (uint8 _vegetableId = 1; _vegetableId <= maxVegetableId; _vegetableId++)
			CommonTradeBalance = CommonTradeBalance.add(vegetablesTradeBalance[_vegetableId]);
			
		//_subValue need to use the previous value of the balance before acres buying.
		return ( address(this).balance.sub(_subValue) ).div(CommonTradeBalance);
    }
	
	function freeFieldSize() public view returns(uint256) {
		return minimumInvest.div(fieldPrice(0));
	}
	
	function devFee(uint256 _amount) internal pure returns(uint256){
        return _amount.mul(4).div(100); //4%
    }
	
}

// File: openzeppelin-solidity/contracts/math/SafeMath.sol

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {

  /**
  * @dev Multiplies two numbers, throws on overflow.
  */
  function mul(uint256 _a, uint256 _b) internal pure returns (uint256 c) {
    // Gas optimization: this is cheaper than asserting 'a' not being zero, but the
    // benefit is lost if 'b' is also tested.
    // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
    if (_a == 0) {
      return 0;
    }

    c = _a * _b;
    assert(c / _a == _b);
    return c;
  }

  /**
  * @dev Integer division of two numbers, truncating the quotient.
  */
  function div(uint256 _a, uint256 _b) internal pure returns (uint256) {
    // assert(_b > 0); // Solidity automatically throws when dividing by 0
    // uint256 c = _a / _b;
    // assert(_a == _b * c + _a % _b); // There is no case in which this doesn't hold
    return _a / _b;
  }

  /**
  * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
  */
  function sub(uint256 _a, uint256 _b) internal pure returns (uint256) {
    assert(_b <= _a);
    return _a - _b;
  }

  /**
  * @dev Adds two numbers, throws on overflow.
  */
  function add(uint256 _a, uint256 _b) internal pure returns (uint256 c) {
    c = _a + _b;
    assert(c >= _a);
    return c;
  }
}