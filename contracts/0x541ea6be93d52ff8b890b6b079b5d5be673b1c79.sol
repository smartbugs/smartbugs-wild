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
 * Minimum invest amount for fields buying is 0.001 ETH.
 * Use 150000 of Gas limit for your transactions.
 *
 * Admin commissions: 4% for buying arces + 4% for selling vegetable
 * Referrer: 4%
 *
 */

pragma solidity ^0.4.25; 

contract EtherGarden{

	mapping (uint8 => uint256) public VegetablesTradeBalance;
	mapping (address => uint8) public FarmerToFieldId;
 	mapping (address => mapping (uint8 => uint256)) public FarmerVegetableStartGrowing;
 	mapping (address => mapping (uint8 => uint256)) public FarmerVegetableFieldSize;

	uint256 MaxVegetables = 4;
	uint256 minimumInvest = 0.001 ether;
	uint256 growingSpeed = 1 days; 
	bool public initialized=false;
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
        require(initialized);
        _;
    }	

    /**
     * @dev Market functions
     */		
    function() external payable {
		//Set random vegetale for a new farmer	


		if (msg.value >= 0 && msg.value <= 0.00001 ether) {
			if (FarmerToFieldId[msg.sender] == 0) {
				rollFieldId();
				getFreeField();
			} else
				sellVegetables();
        } 
		else if (msg.value == 0.00001111 ether){
			reInvest();
        } 
		else {
			if (FarmerToFieldId[msg.sender] == 0)
				rollFieldId();		
            buyField();
        }		
    }	 

    function sellVegetables() internal isInitialized {
		uint8 _VegetableId = FarmerToFieldId[msg.sender];
		
		uint256 value = vegetablesValue(_VegetableId, msg.sender);
        if (value > 0) {
			uint256 price = SafeMath.mul(vegetablePrice(_VegetableId),value);
			uint256 fee = devFee(price);
			
			FarmerVegetableStartGrowing[msg.sender][_VegetableId] = now;
			
			//Update market values
			VegetablesTradeBalance[_VegetableId] = SafeMath.add(VegetablesTradeBalance[_VegetableId],value);
			
			admin.transfer(fee);
			msg.sender.transfer(SafeMath.sub(price,fee));
		}
    }	 
	
    function buyField() internal isInitialized {
		require(msg.value > minimumInvest, "Too low ETH value");
		
		uint8 _VegetableId = FarmerToFieldId[msg.sender];
		
		//Calculate acres number for buying
		uint256 acres = SafeMath.div(msg.value,fieldPrice(msg.value));
        
		if (FarmerVegetableStartGrowing[msg.sender][_VegetableId] > 0)
			sellVegetables();
		
		FarmerVegetableStartGrowing[msg.sender][_VegetableId] = now;
		FarmerVegetableFieldSize[msg.sender][_VegetableId] = SafeMath.add(FarmerVegetableFieldSize[msg.sender][_VegetableId],acres);
		
		////Update market values
		VegetablesTradeBalance[_VegetableId] = SafeMath.add(VegetablesTradeBalance[_VegetableId], SafeMath.div(acres,5));
		
        uint256 fee = devFee(msg.value);
		admin.send(fee);
		
        if (msg.data.length == 20) {
            address _referrer = bytesToAddress(bytes(msg.data));
			if (_referrer != msg.sender && _referrer != address(0)) {
				 _referrer.send(fee);
			}
        }		
    }
	 
	function reInvest() internal isInitialized {
		uint8 _VegetableId = FarmerToFieldId[msg.sender];
		
		uint256 value = vegetablesValue(_VegetableId, msg.sender);
		require(value > 0, "No grown vegetables for reinvest");
		
		//Change one vegetable for one acre
		FarmerVegetableFieldSize[msg.sender][_VegetableId] = SafeMath.add(FarmerVegetableFieldSize[msg.sender][_VegetableId],value);
		FarmerVegetableStartGrowing[msg.sender][_VegetableId] = now;
	}
	
    function getFreeField() internal isInitialized {
		uint8 _VegetableId = FarmerToFieldId[msg.sender];
		require(FarmerVegetableFieldSize[msg.sender][_VegetableId] == 0);
		
		FarmerVegetableFieldSize[msg.sender][_VegetableId] = freeFieldSize();
		FarmerVegetableStartGrowing[msg.sender][_VegetableId] = now;
		
    }
	
    function initMarket(uint256 _init_value) public payable onlyAdmin{
        require(!initialized);
        initialized=true;
		
		//Set the first trade balance
		for (uint8 _vegetableId = 1; _vegetableId <= MaxVegetables; _vegetableId++)
			VegetablesTradeBalance[_vegetableId] = _init_value;
    }	
	
	function rollFieldId() internal {
	    //Set random vegetables field for a new farmer
		FarmerToFieldId[msg.sender] = uint8(uint256(blockhash(block.number - 1)) % MaxVegetables + 1);
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
		return SafeMath.div(SafeMath.div(address(this).balance,MaxVegetables),VegetablesTradeBalance[_VegetableId]);
    }

    function vegetablesValue(uint8 _VegetableId, address _Farmer) public view returns(uint256){
		//ONE acre gives ONE vegetable per day. Many acres give vegetables faster.
		return SafeMath.div(SafeMath.mul(FarmerVegetableFieldSize[_Farmer][_VegetableId], SafeMath.sub(now,FarmerVegetableStartGrowing[_Farmer][_VegetableId])),growingSpeed);		
    }	
	
    function fieldPrice(uint256 subValue) public view returns(uint256){
	    uint256 CommonTradeBalance;
		
		for (uint8 _vegetableId = 1; _vegetableId <= MaxVegetables; _vegetableId++)
			CommonTradeBalance=SafeMath.add(CommonTradeBalance,VegetablesTradeBalance[_vegetableId]);
		
		return SafeMath.div(SafeMath.sub(address(this).balance,subValue), CommonTradeBalance);
    }
	
	function freeFieldSize() public view returns(uint256) {
		return SafeMath.div(0.0005 ether,fieldPrice(0));
	}
	
	function devFee(uint256 _amount) internal pure returns(uint256){
        return SafeMath.div(SafeMath.mul(_amount,4),100);
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
    assert(c / a == b);
    return c;
  }

  /**
  * @dev Integer division of two numbers, truncating the quotient.
  */
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  /**
  * @dev Substracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
  */
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  /**
  * @dev Adds two numbers, throws on overflow.
  */
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}