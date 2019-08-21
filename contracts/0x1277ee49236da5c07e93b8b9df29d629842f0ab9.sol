/*
    CryptoMines game via Ethereum Smart Contract

	In the game you can buy, sell and upgrade mines from 1 to 14 levels. Upgrade 13 level mine to the last 14 level also give you BONUS - 12 new mines differrent levels.
	You can mining the resources needed to upgrade mines. Resources can also be traded to other gamers for their mines upgrade.
	The cost of production of new mines takes place on a strict mathematical formula and depends on the real USD currency value.
	
	Website: https://cryptomines.pro
	
	@author Valeriy Antonov
*/	
	
	
pragma solidity ^0.4.19;
contract Ownable {

  address public owner;

  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

  function Ownable() public {
    owner = msg.sender;
  }

  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

  function transferOwnership(address newOwner) public onlyOwner {
    require(newOwner != address(0));
    OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }

}

contract Payments is Ownable {
  mapping(address => uint256) public payments; 
  
  function getBalance() public constant onlyOwner returns(uint256) {
	 return payments[msg.sender];
  }    
  

  function withdrawPayments() public onlyOwner {
	address payee = msg.sender;
	uint256 payment = payments[payee];

	require(payment != 0);
	require(this.balance >= payment);

	payments[payee] = 0;

	assert(payee.send(payment));
  }  
    
}

contract Resources {
    //ResoursId->ResourceOwner->amount
	mapping(uint8 => mapping(address => uint256) ) public ResourcesOwner; 
}

contract Mines is Resources {
	mapping(uint256 => address) public MineOwner; 
	mapping(uint256 => uint8) public MineLevel; 
	mapping(uint256 => uint256) public MineCooldown; 
	uint256 public nextMineId = 15;
	uint256 public nextMineEvent = 1;
	
	event MineAffected(uint256 indexed AffectId, uint256 MineId);

	function createNewMine(uint8 _MineLVL) internal {
        MineOwner[nextMineId] = msg.sender;
        MineLevel[nextMineId] = _MineLVL;
        MineCooldown[nextMineId] = now;
		
		nextMineId++;
	}
	
	function StartMiningByIdArray(uint256[] _MineIds) public {
	    uint256 MinesCount = _MineIds.length;
		
		require(MinesCount>0);
		
		for (uint256 key=0; key < MinesCount; key++) {
			if (MineOwner[_MineIds[key]]==msg.sender)
				StartMiningById(_MineIds[key]); 
		}
	}
	
	function StartMiningById(uint256 _MineId) internal {
	    
		uint8 MineLVL=MineLevel[_MineId];
		
		assert (MineLVL>0 && MineOwner[_MineId]==msg.sender);	
		
	    uint256 MiningDays = (now - MineCooldown[_MineId])/86400;
		
		assert (MiningDays>0);

		uint256 newCooldown = MineCooldown[_MineId] + MiningDays*86400;
		
		if (MineLVL==14) {
			//14 (high) level mining x2 resources then 13 level
			MineLVL = 13;
			MiningDays = MiningDays*2;
		}
		//start mining			
		for (uint8 lvl=1; lvl<=MineLVL; lvl++) {
			ResourcesOwner[lvl][msg.sender] +=  (MineLVL-lvl+1)*MiningDays;
		}
	
		MineCooldown[_MineId] = newCooldown;
	}	
	
	function UpMineLVL(uint256 _MineId) public {	
		uint8 MineLVL=MineLevel[_MineId];
		
		require (MineLVL>0 && MineLVL<=13 && MineOwner[_MineId]==msg.sender);	
		
		for (uint8 lvl=1; lvl<=MineLVL; lvl++) {
		    require (ResourcesOwner[lvl][msg.sender] >= (MineLVL-lvl+2)*15);
		}

		for (lvl=1; lvl<=MineLVL; lvl++) {
		    ResourcesOwner[lvl][msg.sender] -= (MineLVL-lvl+2)*15;
			//super bonus for the creation high level mine
			if (MineLVL==13 && lvl<=12) 
			    createNewMine(lvl);
		}
		
		MineLevel[_MineId]++;
		
		MineAffected(nextMineEvent,_MineId);
		nextMineEvent++;		
	}
}

contract Trading is Mines, Payments {

    struct tradeStruct {
        address Seller;
        uint8 ResourceId;
        uint256 ResourceAmount;
        uint256 MineId;
        uint128 Price;
    }
    //tradeId->tradeOwner->cost
    mapping(uint256 => tradeStruct) public TradeList; 
	uint128[13] public minesPrice;
	uint256 public TradeId = 1;
	uint256 public nextTradeEvent = 1;
	
	event TradeAffected(uint256 indexed AffectId, uint256 TradeId);
	
  	function buyMine(uint8 _MineLVL) public payable {
	    
		require(_MineLVL>0 && _MineLVL<=13 && msg.value==minesPrice[_MineLVL-1]);
	    
        createNewMine(_MineLVL);
		payments[owner]+=msg.value;
		
	} 
	
    function startSelling(uint8 _sellResourceId, uint256 _ResourcesAmount, uint256 _sellMineId, uint128 _sellPrice) public {
		require ( (_sellResourceId==0 || _sellMineId==0) && (_sellResourceId>0 || _sellMineId>0) && _sellPrice>0 );
		_sellPrice = _sellPrice - _sellPrice%1000; //fix price, some time it was added a few wei.
		if (_sellResourceId>0) {
			require (_ResourcesAmount>0 && ResourcesOwner[_sellResourceId][msg.sender]>=_ResourcesAmount);
			ResourcesOwner[_sellResourceId][msg.sender] -= _ResourcesAmount;
			TradeList[TradeId]=tradeStruct({Seller: msg.sender, ResourceId: _sellResourceId, ResourceAmount: _ResourcesAmount, MineId: _sellMineId, Price: _sellPrice});
		}
		
		if (_sellMineId>0) {		
		    require (MineOwner[_sellMineId]==msg.sender);
			TradeList[TradeId]=tradeStruct({Seller: msg.sender, ResourceId: _sellResourceId, ResourceAmount: _ResourcesAmount, MineId: _sellMineId, Price: _sellPrice});
		}
        
		TradeId++;
	}
	
    function stopSelling(uint256 _TradeId) public {	
		require (_TradeId>0);
		tradeStruct TradeLot = TradeList[_TradeId];	
        require (TradeLot.Seller==msg.sender && TradeLot.Price>0);
		if (TradeLot.ResourceId>0) {
			ResourcesOwner[TradeLot.ResourceId][TradeLot.Seller] += TradeLot.ResourceAmount;
		}
		//stop trade
		TradeLot.Price=0;
		TradeAffected(nextTradeEvent,_TradeId);		
		nextTradeEvent++;
	}
	
    function changeSellingPrice(uint256 _TradeId, uint128 _newPrice) public {	
		require (_TradeId>0 && _newPrice>0);
		tradeStruct TradeLot = TradeList[_TradeId];	
        require (TradeLot.Seller==msg.sender && TradeLot.Price>0);
		TradeLot.Price=_newPrice;
		
		TradeAffected(nextTradeEvent,_TradeId);		
		nextTradeEvent++;
	}
	
    
	function startBuying(uint256 _TradeId) public payable {
		tradeStruct TradeLot = TradeList[_TradeId];
		require (TradeLot.Price==msg.value && msg.value>0);
		 
		if (TradeLot.ResourceId>0) {
			ResourcesOwner[TradeLot.ResourceId][msg.sender] += TradeLot.ResourceAmount;
		}
		 
		if (TradeLot.MineId>0) {
			MineOwner[TradeLot.MineId]=msg.sender;
			MineAffected(nextMineEvent,TradeLot.MineId);
			nextMineEvent++;					
		}
		 
		address payee = TradeLot.Seller;
		payee.transfer(msg.value);

		//stop trade
		TradeLot.Price=0;
		
		TradeAffected(nextTradeEvent,_TradeId);		
		nextTradeEvent++;
		
	}
	
}

contract FiatContract {
  function ETH(uint _id) constant returns (uint256);
  function USD(uint _id) constant returns (uint256);
  function EUR(uint _id) constant returns (uint256);
  function GBP(uint _id) constant returns (uint256);
  function updatedAt(uint _id) constant returns (uint);
}


contract MinesFactory is Trading {


    function MinesFactory() { //constructon
		setMinesPrice ();
	}

	function setMinesPrice () public {
		// mine level 1 price = getUSD()*10 = 10 USD;
	    var lvl1MinePrice = getUSD()*10; 
		
	    for (uint8 lvl=0; lvl<13; lvl++) {
			if (lvl<=2)
				minesPrice[lvl] = (lvl+1)*lvl1MinePrice;
			else
			    minesPrice[lvl] = minesPrice[lvl-1]+minesPrice[lvl-2];
		}
	}
	
	function getMinesInfo(uint256[] _MineIds) public constant returns(address[32], uint8[32], uint256[32]) {
	    address[32] memory MinesOwners_;
	    uint8[32] memory MinesLevels_;
	    uint256[32] memory MinesCooldowns_;

		uint256 MinesCount=_MineIds.length;
		require (MinesCount>0 && MinesCount<=32);
		
		for (uint256 key=0; key < MinesCount; key++) {
			MinesOwners_[key]=MineOwner[_MineIds[key]];
			MinesLevels_[key]=MineLevel[_MineIds[key]];
			MinesCooldowns_[key]=MineCooldown[_MineIds[key]];
		}
		return (MinesOwners_, MinesLevels_, MinesCooldowns_);
	}

	function getResourcesInfo(address _resourcesOwner) public constant returns(uint256[13]) {
	    uint256[13] memory ResourcesAmount_;
		for (uint8 key=0; key <= 12; key++) {
			ResourcesAmount_[key]=ResourcesOwner[key+1][_resourcesOwner];
		}
		return ResourcesAmount_;
	}	
	
	function getMineCooldown(uint256 _MineId) public constant returns(uint256) {
	    return now - MineCooldown[_MineId];
	}
	
    function getUSD() constant returns (uint128) {
		//Fiat Currency value from https://fiatcontract.com/
		//Get Fiat Currency value within an Ethereum Contract
		//$0.01 USD/EURO/GBP in ETH to fit your conversion
		
		FiatContract price;
		
		price = FiatContract(0x8055d0504666e2B6942BeB8D6014c964658Ca591); //mainnet
		require (price.USD(0) > 10000000000);
		var USDtoWEIrounded = uint128((price.USD(0) - price.USD(0) % 10000000000) * 100);
		
		//return 1 USD currency value in WEI ;
		return USDtoWEIrounded;
    }	
	
}