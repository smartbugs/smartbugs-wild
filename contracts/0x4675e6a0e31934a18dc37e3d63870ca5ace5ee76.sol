pragma solidity >=0.4.22 <0.6.0;

contract Ownable {
    address payable public owner;
    address payable public developer;


    event OwnershipRenounced(address indexed previousOwner);
    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );


    /**
    * @dev The Ownable constructor sets the original `owner` of the contract to the sender
    * account.
    */
    constructor() public {
        // owner = msg.sender;
        owner = msg.sender;
        developer = 0x67264cB47c717838Ae684F22E686d6f35dA90981;
    }

    /**
    * @dev Throws if called by any account other than the owner.
    */
    modifier onlyOwner() {
        require(msg.sender == owner, "Only Owner Can Do This");
        _;
    }

    modifier onlyDeveloper() {
        require(msg.sender == developer, "Only Developer Can Do This");
        _;
    }

    /**
    * @dev Allows the current owner to relinquish control of the contract.
    * @notice Renouncing to ownership will leave the contract without an owner.
    * It will not be possible to call the functions with the `onlyOwner`
    * modifier anymore.
    */
    function renounceOwnership() public onlyOwner {
        emit OwnershipRenounced(owner);
        owner = address(0);
    }

    function renounceDevelopership() public onlyDeveloper {
        // emit OwnershipRenounced(owner);
        developer = address(0);
    }

    /**
    * @dev Allows the current owner to transfer control of the contract to a newOwner.
    * @param _newOwner The address to transfer ownership to.
    */
    function transferOwnership(address payable _newOwner) public onlyOwner {
        _transferOwnership(_newOwner);
    }

    function transferDevelopership(address payable _newDeveloper) public onlyDeveloper {
        require(_newDeveloper != address(0), "New Developer's Address is Required");
        // emit OwnershipTransferred(owner, _newOwner);
        developer = _newDeveloper;
    }

    /**
    * @dev Transfers control of the contract to a newOwner.
    * @param _newOwner The address to transfer ownership to.
    */
    function _transferOwnership(address payable _newOwner) internal {
        require(_newOwner != address(0), "New Owner's Address is Required");
        emit OwnershipTransferred(owner, _newOwner);
        owner = _newOwner;
    }
}

contract Pausable is Ownable {
    event Pause();
    event Unpause();

    bool public paused = false;


    /**
    * @dev Modifier to make a function callable only when the contract is not paused.
    */
    modifier whenNotPaused() {
        require(!paused);
        _;
    }

    /**
    * @dev Modifier to make a function callable only when the contract is paused.
    */
    modifier whenPaused() {
        require(paused);
        _;
    }

    /**
    * @dev called by the owner to pause, triggers stopped state
    */
    function pause() public onlyOwner whenNotPaused {
        paused = true;
        emit Pause();
    }

    /**
    * @dev called by the owner to unpause, returns to normal state
    */
    function unpause() public onlyOwner whenPaused {
        paused = false;
        emit Unpause();
    }
}

library SafeMath {
    int256 constant private INT256_MIN = -2**255;

    /**
    * @dev Multiplies two unsigned integers, reverts on overflow.
    */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b);

        return c;
    }

    /**
    * @dev Multiplies two signed integers, reverts on overflow.
    */
    function mul(int256 a, int256 b) internal pure returns (int256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
        if (a == 0) {
            return 0;
        }

        require(!(a == -1 && b == INT256_MIN)); // This is the only case of overflow not detected by the check below

        int256 c = a * b;
        require(c / a == b);

        return c;
    }

    /**
    * @dev Integer division of two unsigned integers truncating the quotient, reverts on division by zero.
    */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
    * @dev Integer division of two signed integers truncating the quotient, reverts on division by zero.
    */
    function div(int256 a, int256 b) internal pure returns (int256) {
        require(b != 0); // Solidity only automatically asserts when dividing by 0
        require(!(b == -1 && a == INT256_MIN)); // This is the only case of overflow

        int256 c = a / b;

        return c;
    }

    /**
    * @dev Subtracts two unsigned integers, reverts on overflow (i.e. if subtrahend is greater than minuend).
    */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a);
        uint256 c = a - b;

        return c;
    }

    /**
    * @dev Subtracts two signed integers, reverts on overflow.
    */
    function sub(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a - b;
        require((b >= 0 && c <= a) || (b < 0 && c > a));

        return c;
    }

    /**
    * @dev Adds two unsigned integers, reverts on overflow.
    */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a);

        return c;
    }

    /**
    * @dev Adds two signed integers, reverts on overflow.
    */
    function add(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a + b;
        require((b >= 0 && c >= a) || (b < 0 && c < a));

        return c;
    }

    /**
    * @dev Divides two unsigned integers and returns the remainder (unsigned integer modulo),
    * reverts when dividing by zero.
    */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0);
        return a % b;
    }
}

contract Fishbowl is Ownable ,Pausable{

    using SafeMath for uint;

    uint[9] fishBowlSize = [0,2000,3000,4000,7000,9000,10000,14000,17000]; //等級、尺寸轉換表
    uint[9] fishBowlLevelByAmount = [0,1,5,10,30,50,100,150,200]; //魚數、魚缸等級對照表
    address private playerBookAddress;

    event setPlayerBookAddrEvent(address _newPlayerBookAddr, uint _time);

    constructor(address _playerBookAddress) public{
        playerBookAddress = _playerBookAddress;
    }

    /* @dev only transaction system can call */
    modifier onlyForPlayerBook(){
        // require(msg.sender == playerBookAddress, "Only for palyerBook contract!");
        _;
    }

    /* @dev
        (魚缸升級(lv8前)、新魚缸)
        將購魚數量與魚價傳入，回傳玩家專屬魚缸資訊(新購入及升級) -> 呼叫player函數設定值 -> return 給player使用
        uint level; //等級
        uint fodderFee; //需支付的飼料費用(魚價*購魚數)
        uint fishbowlSize; //魚缸倍數
        uint admissionPrice; //基礎入場價格(魚價*購魚數*2)
        uint amountToSale; //可銷售總額(基礎入場價格*魚缸倍數)
    */
    function fishBowl(uint _totalFishPrice, uint _fishAmount)
    public view onlyForPlayerBook returns(uint fishbowlLevel, uint fishbowlSize, uint admissionPrice, uint amountToSale)
    {
        uint _fishbowlLevel = getFishBowlLevel(_fishAmount);
        uint _fishbowlSize = getFishbowlSize(_fishbowlLevel);
        uint _admissionPrice = getAdmissionPrice(_totalFishPrice);
        uint _amountToSale = getAmountToSale(_fishbowlLevel, _admissionPrice);

        return (_fishbowlLevel, _fishbowlSize, _admissionPrice, _amountToSale);
    }

    /* @dev
        (多重購魚(lv8後))將原先的基礎入場價格及可購買總額、這次多重購魚購買魚數及魚價傳入，回傳多重購魚後基礎入場價格及可銷售總額
        @notice 魚價單位轉換
    */
    function multipleBuy(uint _totalFishPrice, uint _oldAdmissionPrice, uint _oldAmountToSale)
    public view onlyForPlayerBook returns(uint newAdmissionPrice, uint newAmountToSale)
    {
        uint _admissionPrice = getAdmissionPrice(_totalFishPrice);
        uint _newAdmissionPrice = _admissionPrice.add(_oldAdmissionPrice);
        uint _newAmountToSale = getAmountToSale(8, _admissionPrice).add(_oldAmountToSale);

        return (_newAdmissionPrice, _newAmountToSale);
    }

    /*@dev 將購魚數量傳入，回傳魚缸等級 */
    function getFishBowlLevel(uint _fishAmount) public view onlyForPlayerBook returns(uint fishbowlLevel){
        for(uint i = 0; i < 9; i++){
            if( _fishAmount == fishBowlLevelByAmount[i]){
                return i;
            }
        }
    }

    /*@dev 將購魚數量與魚價傳入，回傳飼料費(魚價*購魚數) */
    function getFodderFee(uint _fishPrice, uint _fishAmount) public pure onlyForPlayerBook returns(uint fodderFee){
        return _fishPrice.mul(_fishAmount);
    }

    /*@dev 將魚缸等級傳入，回傳魚缸尺寸 */
    function getFishbowlSize(uint _fishbowlLevel) public view onlyForPlayerBook returns(uint fishbowlSize){
        return fishBowlSize[_fishbowlLevel];
    }

    /*@dev 將購魚總價傳入，回傳基礎入場價格(購魚總價*2)*/
    function getAdmissionPrice(uint _totalFishPrice) public pure onlyForPlayerBook returns(uint admissionPrice){
        return _totalFishPrice.mul(2);
    }

    /*@dev 將魚缸等級、基礎入場價格傳入，回傳可銷售總額(基礎入場價格*魚缸倍數) */
    function getAmountToSale(uint _fishbowlLevel, uint _admissionPrice)
    public view onlyForPlayerBook returns(uint amountToSale)
    {
        return _admissionPrice.mul(getFishbowlSize(_fishbowlLevel));
    }

    /*@dev set playerbookAddr */
    function setPlayerBookAddr(address _newPlayerBookAddr) public onlyOwner{
        playerBookAddress = _newPlayerBookAddr;

        emit setPlayerBookAddrEvent(_newPlayerBookAddr, now);
    }

    /*@dev get playerbookAddr */
    function getPlayerBookAddr() public view returns(address _playerBookAddress){
        return playerBookAddress;
    }

}

contract TransactionSystem is Ownable{
	using SafeMath for uint;
	using SafeMath for int;

	struct GlobalData {
		uint fishAmount; // -> still alive fishAmount
		uint fishPrice;
		uint systemTotalFishAmount; //掛新單子用 
		uint selledAmount; //累積銷售魚數
		uint[7] priceInterval;
	}

	struct PlayerSellOrderData {
		address payable owner;
		uint fishAmount;
		uint fishPrice;
		uint round;
	}

	struct Queue{
		uint[] idList;
		uint front;
	}

	/* Config public variables */
	uint constant public INIT_FISHAMOUNT = 10000;
	uint constant public INIT_FISHPRICE = 50 finney; // 50 * (10 ** 15) = 0.05ETH
	// uint constant public INIT_FISHPRICE = 91 finney; // 50 * (10 ** 15) = 0.05ETH
	
	/* Global data for the entire game */
	GlobalData globalData;

	/* Player book inplement*/
	PlayerBook playerBook = PlayerBook(0x0);
	address payable public playerBookAddress;

	/* order data */
	mapping(uint => uint) private priceTotalFishAmount; //每個價位玩家總共幾條魚(只有賣單)
	mapping(uint => Queue) public sellOrderSequence; // [價格] 單子[] (賣單)

	/* address query */
	mapping(address => uint) private personSellOrders; //每個人還在的賣單紀錄

	// Order Stored
	PlayerSellOrderData[] private sellOrders; //全部的賣單

	/* 系統坊賣單 */
	mapping(uint => uint) systemFishAmount; //價格 對應的魚數
	uint systemFishPriceCumulativeCount;

	// 長肉模式用
	bool public isFleshUp; //是否為長肉的 flag，true 代表是
	uint public fleshUpCount; //長肉模式總共會賣出的魚數
	bool public haveFish; //區間還有多少魚

	// 紀錄繁殖區塊
	uint[] private reproductionBlockNumbers;

	event changePriceEvent(address indexed _contract, uint indexed _price, uint _timestamp);
	event orderEvent(address indexed _from, uint _amount, uint _timestamp);
	event fleshUpEvent(uint _price, uint fleshUpCount, uint _timestamp);

	/* contructor */
	constructor() public {
		globalData = GlobalData({
			fishAmount: INIT_FISHAMOUNT,
			fishPrice: INIT_FISHPRICE,
			systemTotalFishAmount: 0,
			selledAmount: 0,
			priceInterval: [uint256(50 finney), uint256(51 finney), uint256(52 finney), uint256(53 finney), uint256(54 finney), uint256(55 finney), uint256(56 finney)]
			// priceInterval: [uint256(93 finney), uint256(94 finney), uint256(95 finney), uint256(96 finney), uint256(97 finney), uint256(98 finney), uint256(99 finney)]
		});
		isFleshUp = false;
		/* Initial order setup */
		/* @dev
			1.初始系統庫存魚數:10000 
			2.交易系統中已顯示的 7 個價位,第一優先掛賣庫存魚數的 2% 取整數計算(無條件捨去)。 
			3.交易系統中出現新價位(高價格)時, 第一優先掛賣庫存魚數的 2%, 取整數計算(無條件捨去)。 
		*/
		globalData.systemTotalFishAmount = INIT_FISHAMOUNT;
		// globalData.systemTotalFishAmount = 6000;
		for (uint orderPrice = INIT_FISHPRICE; orderPrice < INIT_FISHPRICE.add(7 finney); orderPrice = orderPrice.add(1 finney)) {
			systemFishAmount[orderPrice] = 200;
		}/*
		systemFishAmount[97 finney] = 200;
		systemFishAmount[98 finney] = 39;
		systemFishAmount[99 finney] = 123;
		fleshUpCount = 700;
		isFleshUp = true;*/
		reproductionBlockNumbers.push(0);
		systemFishPriceCumulativeCount = 56 finney; //初始累進最高價位為 56
		// systemFishPriceCumulativeCount = 99 finney; //初始累進最高價位為 56
	}

	//only call from playerbook is allowed
	modifier onlyPlayerBook() {
		require(msg.sender == playerBookAddress);
		_;
	}

	//if u want to make a donation... <3
	function() payable external{
		playerBookAddress.transfer(msg.value);
	}

	
	/* @dev
		0. need setup playerBookAddress first
		1. all call should from playerBook (this contract should not get any ETH)
		2. price should been preprocess from playerBook
	*/
	//買魚並記錄金額。
	function addNewBuyOrder(address payable _buyer, uint _fishAmount, uint _balance, bool _isRebuy)
		public
		onlyPlayerBook()
	{
		//require(_fishAmount <= 200); //max value //或是 playerbook 檢查
		/* @dev
			魚價範圍 0.05~0.1ETH ，以 0.001 為一個檔位做跳動. -> 50~100
			每個檔位最高可掛賣數量為總可交易魚數的 5%, 
		*/

		//addFishAmount -> 處理買家飼料費
		//sellerProcessProfit -> 處理賣家獲利
		//交易總共投入金額
		uint totalCost = 0; //處理跨價購買的問題
		uint _addFishAmount = 0; //總共要增加的魚數
		uint _tempRound = playerBook.reproductionRound();

		Queue storage Q = sellOrderSequence[globalData.fishPrice];
		while(_fishAmount > 0){ 
			//系統還有魚 -> 進入系統單
			if(systemFishAmount[globalData.fishPrice] > 0){ 
				//系統能賣夠
				if(_fishAmount <= systemFishAmount[globalData.fishPrice]){
					//最終要新增的魚數量
					_addFishAmount = _addFishAmount.add(_fishAmount);
					//扣掉花費
					_balance = _balance.sub(_fishAmount.mul(globalData.fishPrice));
					totalCost = totalCost.add(_fishAmount.mul(globalData.fishPrice));
						
					//更新 player 狀態 //totalCost , isBuy
					playerBook.addFishAmount(_buyer, _addFishAmount, totalCost, true);
					//更新全域賣出魚數
					globalData.selledAmount = globalData.selledAmount.add(_fishAmount);
					//更新賣家
					playerBook.sellerProcessProfit(playerBookAddress, _fishAmount.mul(globalData.fishPrice));
					//更新系統該價位魚的資訊
					systemFishAmount[globalData.fishPrice] = systemFishAmount[globalData.fishPrice].sub(_fishAmount);
					globalData.systemTotalFishAmount = globalData.systemTotalFishAmount.sub(_fishAmount);
					//減少要購買的數量
					_fishAmount = 0;

					//找零
					if(_balance > 0 && _isRebuy == false){ 
						uint temp = _balance;
						_balance = 0;
						playerBook.buyOrderRefund(_buyer, temp);
					}

					if( priceTotalFishAmount[globalData.fishPrice] == 0 && systemFishAmount[globalData.fishPrice] == 0 ){
						changePriceInterval();
						Q = sellOrderSequence[globalData.fishPrice]; //To-Notice: 不知道這樣會不會 work
					}
					break;
				}else{
					//要新增的魚數量
					_addFishAmount = _addFishAmount.add(systemFishAmount[globalData.fishPrice]);
					//減少要購買的數量
					_fishAmount = _fishAmount.sub(systemFishAmount[globalData.fishPrice]);
					//扣掉花費
					_balance = _balance.sub(systemFishAmount[globalData.fishPrice].mul(globalData.fishPrice));
					totalCost = totalCost.add(systemFishAmount[globalData.fishPrice].mul(globalData.fishPrice));
					//不能更新 player 狀態，因為沒買完
					//更新全域賣出魚數
					globalData.selledAmount = globalData.selledAmount.add(systemFishAmount[globalData.fishPrice]);
					//更新賣家
					playerBook.sellerProcessProfit(playerBookAddress, systemFishAmount[globalData.fishPrice].mul(globalData.fishPrice));
					//更新系統該價位魚的資訊
					globalData.systemTotalFishAmount = globalData.systemTotalFishAmount.sub(systemFishAmount[globalData.fishPrice]);
					systemFishAmount[globalData.fishPrice] = 0;
				}
			}

			//系統處理完還有魚(不會 break) -> 進入玩家賣單
			
			//當玩家沒有賣單 -> 跳價格
			if( priceTotalFishAmount[globalData.fishPrice] == 0 ){
				changePriceInterval();
				Q = sellOrderSequence[globalData.fishPrice]; //To-Notice: 不知道這樣會不會 work
				if ( playerBook.reproductionRound() > _tempRound ) {
					_addFishAmount = _addFishAmount.mul(2);
					_tempRound = playerBook.reproductionRound();
				}
				continue; //或可以把整個 if 放到迴圈末端
			}

			//檢查單子是否存在
			if(sellOrders[ Q.idList[Q.front] ].fishAmount <= 0){
				Q.front++;
				continue;
			}

			//處理繁殖次數 (amount = amount * 2**(globalRound - localRound))
			uint realAmount = sellOrders[ Q.idList[Q.front] ].fishAmount.mul( 2 **(playerBook.reproductionRound().sub(sellOrders[ Q.idList[Q.front] ].round)) );
			//魚的數量 overflow 可能另外檢查(?) (To-Notice)

			if(_fishAmount >= realAmount){
				//買的完，不用改賣單

				//要新增的魚數量
				_addFishAmount = _addFishAmount.add(realAmount);
				//減少要購買的數量
				_fishAmount = _fishAmount.sub(realAmount);
				//扣掉花費
				_balance = _balance.sub(realAmount.mul(globalData.fishPrice));
				totalCost = totalCost.add(realAmount.mul(globalData.fishPrice));

				//不能更新 player 狀態，因為沒買完
				//更新全域賣出魚數
				globalData.selledAmount = globalData.selledAmount.add(realAmount);
				//更新賣家
				playerBook.sellerProcessProfit(sellOrders[ Q.idList[Q.front] ].owner, realAmount.mul(globalData.fishPrice));
				delete sellOrders[ Q.idList[Q.front] ]; //刪除該筆賣單
				delete Q.idList[Q.front]; //刪除該筆排序
				//更新該價位魚的總量
				priceTotalFishAmount[globalData.fishPrice] = priceTotalFishAmount[globalData.fishPrice].sub(realAmount);
				//下一筆賣單
				Q.front++;
			}else{ 
				//剩下要購買的魚數量 < 賣單的
				//買完了，但買不完賣單，修改賣單魚數
				//注意 realFishAmount (To-Notice)

				//要新增的魚數量 
				_addFishAmount = _addFishAmount.add(_fishAmount);
					
				//扣掉花費
				_balance = _balance.sub(_fishAmount.mul(globalData.fishPrice));
				totalCost = totalCost.add(_fishAmount.mul(globalData.fishPrice));
					
				//更新 player 狀態 //isBuy
				playerBook.addFishAmount(_buyer, _addFishAmount, totalCost, true);
				//更新全域賣出魚數
				globalData.selledAmount = globalData.selledAmount.add(_fishAmount);
				//更新賣家
				playerBook.sellerProcessProfit(sellOrders[ Q.idList[Q.front] ].owner, _fishAmount.mul(globalData.fishPrice));
				//更新賣單的狀態
				sellOrders[ Q.idList[Q.front] ].fishAmount = realAmount.sub(_fishAmount);
				sellOrders[ Q.idList[Q.front] ].round = playerBook.reproductionRound();

				//更新該價位魚的總量
				priceTotalFishAmount[globalData.fishPrice] = priceTotalFishAmount[globalData.fishPrice].sub(_fishAmount);
					
				//減少要購買的數量
				_fishAmount = 0;

				//找零
				if(_balance > 0 && _isRebuy == false){ 
					uint temp = _balance;
					_balance = 0;
					playerBook.buyOrderRefund(_buyer, temp);
				}
				break;
			}
		}
		
		emit orderEvent(_buyer, _addFishAmount, now);
	}

	function getEstimateFishPrice(uint _fishAmount) external view returns(uint){
		uint tempBalance = 0;
		uint tempFishPrice = globalData.fishPrice;
		uint tempFishAmount = _fishAmount;
		bool tempJumpPrice = isFleshUp;
		uint tempfleshUpCount = fleshUpCount;
		while(tempFishAmount > 0){
			//To-Notice 跳價格後的價格區間
			//價格往下跳不管
			if(systemFishAmount[tempFishPrice] >= tempFishAmount || tempFishPrice > globalData.priceInterval[6]){//99->100 100
				// > priceInterval[6] 代表跑到最新的系統單去了
				tempBalance = tempBalance.add(tempFishAmount.mul(tempFishPrice));
				tempFishAmount = 0;
				break;		
			}else{
				tempFishAmount = tempFishAmount.sub(systemFishAmount[tempFishPrice]);//減掉該價位所有魚
				tempBalance = tempBalance.add(systemFishAmount[tempFishPrice].mul(tempFishPrice));//花費增加
				if(priceTotalFishAmount[tempFishPrice] > tempFishAmount){
					tempBalance = tempBalance.add(tempFishAmount.mul(tempFishPrice));
					tempFishAmount = 0;
					break;	
				}else{
					tempFishAmount = tempFishAmount.sub(priceTotalFishAmount[tempFishPrice]);
					tempBalance = tempBalance.add(priceTotalFishAmount[tempFishPrice].mul(tempFishPrice));
				}	
			}

			//價格變動方向
			if(tempJumpPrice == false){//不是長肉就正常跳價
				//跑完所有顯示過的價位後沒變動的話，目前價位 + 1
				tempFishPrice = tempFishPrice.add(1 finney);
				for(uint i = tempFishPrice; i < 100 finney; i = i.add(1 finney)){
					if(priceTotalFishAmount[i] > 0 || systemFishAmount[i] > 0){
						tempFishPrice = i; 
						break;
					}
				}

			}else if(tempFishPrice == globalData.priceInterval[6]){ //長肉結束，跳到新的價位 -> 不一定超過 globalData.priceInterval[6]
				//會進到 else 代表 isFleshUp == true
				tempJumpPrice = false;
				//清空累計銷售
				//globalData.selledAmount = 0;
				// 678 * 100 / 10000 = 6.78
				if(tempFishPrice == 99 finney){//如果為準繁殖 -> 下一輪
					tempFishPrice = 100 finney;
				}else{
					tempFishPrice = tempFishPrice.add( tempfleshUpCount.mul(100).div(globalData.fishAmount).mul(1 finney) ); //要加的價位
					if(tempfleshUpCount.mul(100) % globalData.fishAmount > 0){ //無條件進位
						tempFishPrice = tempFishPrice.add(1 finney);
					}
					if(tempFishPrice > 99 finney){ //估價的部分可以多估
						tempFishPrice = 101 finney;
					}
				}
			}else if(tempJumpPrice == true || globalData.selledAmount.add(_fishAmount - tempFishAmount).mul(50) >= globalData.fishAmount){ //這邊處理到新價位後，達到長肉 2% 的狀況
				if(tempJumpPrice == false){
					tempfleshUpCount = 0; //第一次進入，把凍結區間的總魚數歸零
				}

				for(uint i = globalData.priceInterval[0]; i <= globalData.priceInterval[6] && tempJumpPrice == false; i += 1 finney){
					//第一次進入，紀錄凍結後的總魚數
					tempfleshUpCount += priceTotalFishAmount[i];
					tempfleshUpCount += systemFishAmount[i];
				}
				tempJumpPrice = true; //鎖住掛賣
				tempFishPrice = tempFishPrice.add(1 finney);
				//7檔位不動
			}
		} 
		tempBalance = tempBalance.mul(110);
		tempBalance = tempBalance.div(100);
		return tempBalance;
	}

	/* Add new order to the contract */
	function addNewSellOrder(address payable _seller, uint _fishAmount, uint _fishPrice) 
		public 
		onlyPlayerBook()
	{
		/*
			每個檔位最高可掛賣數量為總可交易魚數的 2%
			玩家只能掛 10% -> PB 檢查
		*/
		//長肉不可掛單
		require(isFleshUp == false, "isFleshUp");

		//check is legal price interval
		if(_fishPrice == globalData.fishPrice
			|| _fishPrice < globalData.priceInterval[0] 
			|| (_fishPrice > globalData.priceInterval[6] && _fishPrice != 100 finney)
		){
			revert("out of range");
		}

		/*
			當魚的時價來到 0.099 時進入準繁殖狀態, 所有<0.99價位不可掛賣
			系統只會出現 0.099 跟 0.1  這 2 個價位   
			0.1 價位為預掛單 <- ,總掛賣量上限為總可交易魚數的 3% 
		*/
		// only price=99 then allow price=100 orders
		if(globalData.fishPrice < 99 finney && _fishPrice > 99 finney){
			revert("out of range");
		}
		// if global price>=99 only 0.1 ETH orders is allowed
		if(globalData.fishPrice >= 99 finney && _fishPrice != 100 finney){
			revert("0.099 only allowed 0.1 eth");
		}

		//not current price legal amount (2% allowed)
		if( priceTotalFishAmount[_fishPrice].add(systemFishAmount[_fishPrice]).add(_fishAmount).mul(50) > globalData.fishAmount ){
			revert("no more than 2% total fishAmount");
		}
		if(globalData.fishPrice == 99 finney && priceTotalFishAmount[50 finney].add(systemFishAmount[50 finney]).add(_fishAmount).mul(25) > globalData.fishAmount ){
			revert("no more than 2% total fishAmount");
		}

		require(_fishAmount > 0, "no zero fish"); //不能掛 0 條

		require(_fishPrice % (1 finney) == 0, "illegal price");

		//檢查是否已有掛單
		require(sellOrders.length == 0 || sellOrders[ personSellOrders[_seller] ].owner != _seller, "already exist");

		//reduce _seller fishAmount
		playerBook.minusFishAmount(_seller, _fishAmount);
		
		//add Order
		uint sellOrdersCount = sellOrders.length;
		if(_fishPrice == 100 finney){ //100 的玩家單其實為下一輪 50 的玩家掛單
			_fishAmount = _fishAmount.mul(2);
			_fishPrice = 50 finney;
			sellOrders.push( PlayerSellOrderData({
				owner: _seller,
				fishAmount: _fishAmount,
				fishPrice: _fishPrice,
				//要記錄繁殖階段
				round: playerBook.reproductionRound().add(1)
			}) );
		}else{
			sellOrders.push( PlayerSellOrderData({
				owner: _seller,
				fishAmount: _fishAmount,
				fishPrice: _fishPrice,
				//要記錄繁殖階段
				round: playerBook.reproductionRound()
			}) );
		}

		//更新該價位整體魚數
		priceTotalFishAmount[_fishPrice] = priceTotalFishAmount[_fishPrice].add(_fishAmount);
		// Can improve by double-linked-list (or Not?)
		personSellOrders[_seller] = sellOrdersCount; //owner
		sellOrderSequence[_fishPrice].idList.push(sellOrdersCount); //system

		emit orderEvent(_seller, _fishAmount, now);
	}


	// Cancel sell order 
	function cancelSellOrder(address payable _caller, uint _orderId)
		public
		onlyPlayerBook()
	{
		if(sellOrders.length <= _orderId){
			revert("id error");
		}

		if(sellOrders[_orderId].owner != _caller){ //less gas cost, since cancel probably fail
			revert("only owner");
		}

		if(globalData.fishPrice == 99 finney && sellOrders[_orderId].fishPrice == 50 finney){ //避免被在價位 99 用來洗 50 的魚數
			revert("0.099 not allowed cancel 0.1 eth order");
		}

		require(isFleshUp == false, "isFleshUp");

		//處理魚繁殖問題
		uint tempFishAmount = sellOrders[_orderId].fishAmount.mul(2 **(playerBook.reproductionRound().sub(sellOrders[_orderId].round)) );
        uint _fishPrice = sellOrders[_orderId].fishPrice;
		delete sellOrders[_orderId];

		//return fish Amount to _caller
		playerBook.addFishAmount(_caller, tempFishAmount, 0, false);

		//更新該價位整體魚數
		priceTotalFishAmount[_fishPrice] = priceTotalFishAmount[_fishPrice].sub(tempFishAmount);

		personSellOrders[_caller] = 0; //清空 owner 掛單

		emit orderEvent(_caller, tempFishAmount, now);
	}


	/* reproduce */
	function reproductionStage()
		private
	{
		//魚變兩倍 & 更新價位 & 累進計數器
		globalData.fishAmount = globalData.fishAmount.mul(2);
		globalData.systemTotalFishAmount = globalData.systemTotalFishAmount.mul(2);
		globalData.fishPrice = 50 finney;
		globalData.selledAmount = 0;
		systemFishPriceCumulativeCount = 56 finney;
		isFleshUp = false;

		//更新個別價位 總魚數
		uint _addSystemFishAmount = globalData.systemTotalFishAmount.div(50);
		uint j=1;
		globalData.priceInterval[0] = 50 finney; //50 其他在跳價格處理
		for(uint i = 51 finney; i <= 98 finney; i += 1 finney){ //只更新到 98 (99賣完 -> 回到 50)
			priceTotalFishAmount[i] = priceTotalFishAmount[i].mul(2); //殘存玩家單
			systemFishAmount[i] = systemFishAmount[i].mul(2); //殘存系統單
			//systemFishAmount 直接加新的的
			if(i <= 56 finney){
				globalData.priceInterval[j] = i;
				j++;
				systemFishAmount[i] = systemFishAmount[i].add(_addSystemFishAmount);
			}
		}

		//告知 playerBook 更新 round 資訊
		playerBook.addReproductionRound();
		reproductionBlockNumbers.push(block.number);
	}


	function changePriceInterval() 
		private
	{
		/*
			檢查是否長肉:
				每個檔位銷售完後, 每當累計銷售量大於等於到總可交易魚數的 2%
		*/
		
		
		if( isFleshUp == true || globalData.selledAmount.mul(50) >= globalData.fishAmount ){//長肉模式
			if(isFleshUp == false){
				fleshUpCount = 0; //第一次進入，把凍結區間的總魚數歸零
			}

			haveFish = false;// 長肉的正常跳價
			for(uint i = globalData.priceInterval[0]; i <= globalData.priceInterval[6]; i += 1 finney){
				if(haveFish == false &&(priceTotalFishAmount[i] > 0 || systemFishAmount[i] > 0)){
					globalData.fishPrice = i;
					haveFish = true;
				}
				if(isFleshUp == false){ //第一次進入，紀錄凍結後的總魚數
					fleshUpCount += priceTotalFishAmount[i];
					fleshUpCount += systemFishAmount[i];
				}
			}
			isFleshUp = true; //鎖住掛賣
			//7檔位不動
			//清空累計銷售
			globalData.selledAmount = 0;

			if(fleshUpCount == 0){ //避免進入長肉，結果區間沒有魚
				//變回正常跳價
				//檢查價位往哪 (下3 or 上最多變成 0.099 eth 價位)
				for(uint i = globalData.priceInterval[0]; i < 100 finney; i = i.add(1 finney)){
					if(priceTotalFishAmount[i] > 0 || systemFishAmount[i] > 0){
						globalData.fishPrice = i; //99 一定有魚，沒魚就長肉了
						break;
					} //          98 -> 95 -> 92 -> *89 -> 94* -> 99
				}
				isFleshUp = false;
			}else if(haveFish == false){//長肉結束，跳到新的價位
				//會進到 else 代表 isFleshUp == true
				isFleshUp = false;
				//清空累計銷售
				globalData.selledAmount = 0;
				// 678 * 100 / 10000 = 6.78
				if(globalData.fishPrice == 99 finney){//如果為準繁殖 -> 下一輪
					globalData.fishPrice = 100 finney;
				}else{
					globalData.fishPrice = globalData.fishPrice.add( fleshUpCount.mul(100).div(globalData.fishAmount).mul(1 finney) ); //要加的價位
					if(fleshUpCount.mul(100) % globalData.fishAmount > 0){ //無條件進位
						globalData.fishPrice = globalData.fishPrice.add(1 finney);
					}
					if(globalData.fishPrice > 99 finney){
						globalData.fishPrice = 99 finney;
					}
				}
				//跳完價格後，跳到無魚的地方由 line 629 開始處裡
			}

			emit fleshUpEvent(globalData.fishPrice, fleshUpCount, now);
		}else{
			//不是長肉就正常跳價
			if(globalData.fishPrice == 99 finney){//如果為準繁殖 -> 下一輪
				globalData.fishPrice = 100 finney;
			}else{
				//檢查價位往哪 (下3 or 上最多變成 0.099 eth 價位)
				for(uint i = globalData.priceInterval[0]; i < 100 finney; i = i.add(1 finney)){
					if(priceTotalFishAmount[i] > 0 || systemFishAmount[i] > 0){
						globalData.fishPrice = i; //99 一定有魚，沒魚就長肉了
						break;
					} //          98 -> 95 -> 92 -> *89 -> 94* -> 99
				}
			}
		}

		//如果繁殖 -> 由繁殖修改資訊
		if(globalData.fishPrice > 99 finney){
			reproductionStage();
			return;
		}
		
		// 94 [95] 96 97 |98| 99
		// 97 -> 98 cumulativecount = 99
		// 93-> 99 確實會進入這邊，但因為只會更新到 99 價位，所以不會動到 100
		if(globalData.fishPrice.add(3 finney) > systemFishPriceCumulativeCount && systemFishPriceCumulativeCount < 99 finney && isFleshUp == false){//讓 99 , 而且不是長肉
			// 交易系統中出現新價位(高價格)時, 第一優先掛賣庫存魚數的 2%, 取整數計算(無條件捨去)。 
			uint _addSystemFishAmount = globalData.systemTotalFishAmount.div(50);
			uint newPrice = globalData.fishPrice.add(3 finney); 
			if(newPrice > 99 finney){
				newPrice = 99 finney;
			}
			//更新 systemFishAmount
			for(uint i = globalData.fishPrice; i <= newPrice; i = i.add(1 finney)){ //從當前價位更新魚數，而不用管前面的價位(就算是新的)
				if(systemFishAmount[i] == 0){ //沒有掛過魚 (舊的價位不該進到這個判斷，systemFishPriceCumulativeCount 不會讓舊的價位部署上去)
					systemFishAmount[i] = systemFishAmount[i].add(_addSystemFishAmount);
				}
			}
			systemFishPriceCumulativeCount = newPrice;
			//由價位更新 priceInterval
			// for(uint i = 6; i >= 0; i--){
			// 	globalData.priceInterval[i] = newPrice.sub( (6-i).mul(1 finney));
			// }
			globalData.priceInterval[0] = newPrice.sub(6 finney);
			globalData.priceInterval[1] = newPrice.sub(5 finney);
			globalData.priceInterval[2] = newPrice.sub(4 finney);
			globalData.priceInterval[3] = newPrice.sub(3 finney);
			globalData.priceInterval[4] = newPrice.sub(2 finney);
			globalData.priceInterval[5] = newPrice.sub(1 finney);
			globalData.priceInterval[6] = newPrice;
		}else if(globalData.fishPrice < 96 finney && globalData.fishPrice.sub(3 finney) >= 50 finney && isFleshUp == false){ //加上不是長肉
			//|96| 97 98 99  
			//50 51 52 |53|<-54
			globalData.priceInterval[0] = globalData.fishPrice.sub(3 finney);
			globalData.priceInterval[1] = globalData.fishPrice.sub(2 finney);
			globalData.priceInterval[2] = globalData.fishPrice.sub(1 finney);
			globalData.priceInterval[3] = globalData.fishPrice;
			globalData.priceInterval[4] = globalData.fishPrice.add(1 finney);
			globalData.priceInterval[5] = globalData.fishPrice.add(2 finney);
			globalData.priceInterval[6] = globalData.fishPrice.add(3 finney);
		}

		if(priceTotalFishAmount[globalData.fishPrice] == 0 && systemFishAmount[globalData.fishPrice] == 0){//避免跳到一個沒魚的舊價位
			for(uint i = globalData.priceInterval[0]; i < 100 finney; i = i.add(1 finney)){
				if(priceTotalFishAmount[i] > 0 || systemFishAmount[i] > 0){
					globalData.fishPrice = i; //99 一定有魚，沒魚就長肉了
					break;
				} //          98 -> 95 -> 92 -> *89 -> 94* -> 99
			}
		}

		if(globalData.fishPrice == 99 finney){ //新的價位為 99 的話，繁殖的問題系統單
			priceTotalFishAmount[50 finney] = priceTotalFishAmount[50 finney].mul(2); //先繁殖下一輪的 50 價位
			uint _addSystemFishAmount = globalData.systemTotalFishAmount.div(50); //2%
			systemFishAmount[50 finney] = systemFishAmount[50 finney].add(_addSystemFishAmount).mul(2);

			//如果還是要讓 100 顯示 100，而不是下一輪的 50
			uint newPrice = 100 finney;
			globalData.priceInterval[0] = newPrice.sub(6 finney);
			globalData.priceInterval[1] = newPrice.sub(5 finney);
			globalData.priceInterval[2] = newPrice.sub(4 finney);
			globalData.priceInterval[3] = newPrice.sub(3 finney);
			globalData.priceInterval[4] = newPrice.sub(2 finney);
			globalData.priceInterval[5] = newPrice.sub(1 finney);
			globalData.priceInterval[6] = newPrice;
		}

		emit changePriceEvent(address(this), globalData.fishPrice, now);
	}

	//@dev 減少可交易魚數
	function deadFish(uint _fishAmount) 
		external
		onlyPlayerBook
	{
		globalData.fishAmount = globalData.fishAmount.sub(_fishAmount);
	}


	function setPlayerBookAddress(address payable _PBaddress) 
		external
		onlyOwner
	{
		playerBookAddress = _PBaddress;
		playerBook = PlayerBook(_PBaddress);
	}



	function getPersonSellOrders()
		external
		view
		returns(uint)
	{
		return(personSellOrders[msg.sender]);
	}


	function getSellOrderData(uint _orderId)
		external
		view
		returns(address, uint, uint)
	{
		return(sellOrders[_orderId].owner, sellOrders[_orderId].fishAmount, sellOrders[_orderId].fishPrice);
	}


	function showGlobalData() 
		public
		view
		returns( uint _fishAmount, uint _fishPrice, uint _selledAmount )
	{
		return( 
			globalData.fishAmount,
			globalData.fishPrice,
			globalData.selledAmount
		);
	}


	function showAvaliablePriceInterval() 
		public 
		view
		returns (uint256 [7] memory) 
	{
		return globalData.priceInterval;
	}


	function showPriceIntervalFishAmount()
		public 
		view
		returns (uint256 [7] memory) 
	{
		uint[7] memory temp;
		for(uint i = 0; i < 7; i++){
			uint tempPrice = globalData.priceInterval[i];
			if(tempPrice == 100 finney){
				temp[i] += priceTotalFishAmount[50 finney];
				temp[i] += systemFishAmount[50 finney];
				temp[i] /= 2;
			}else{
				temp[i] += priceTotalFishAmount[tempPrice];
				temp[i] += systemFishAmount[tempPrice];
			}
		}
		return temp;
	}

	function showFish()
		public 
		view
		returns (uint256) 
	{
		return globalData.systemTotalFishAmount;
	}

	function getRepoBlockNumbers() 
		external
		view
		returns(uint[] memory)
	{
		return reproductionBlockNumbers;
	}
}

contract Commission is Ownable ,Pausable{
    using SafeMath for uint;

    /* @dev 魚缸等級 => 影響推薦獎金趴數、魚缸尺寸倍增多寡
        @notice 小數點位數處理(3位)
    */
    uint[9] levelToCommission = [100,400,400,500,500,600,600,700,700]; //千分比
    // uint[9] levelToCommission = [100,400,400,500,500,600,600,700,700]; //千分比
    uint[9] fishbowlGrow = [0,0,0,0,0,0,0,0,1000]; //千分比
    address private playerBookAddress;


    /* @dev Generation model */
    struct Generation{
        /*false => 普通玩家, true=> 第一代玩家*/ //用ancestorList.length 判斷？
        //bool firstGeneration;

        /*向上，分發獎金用 => 10代 建立時檢查*/
        address[] ancestorList; //往上延伸，需要分發獎金的人 => push

        /*向下，擴增魚缸尺寸用*/
        address[] inviteesList; //邀請者列表
    }
    mapping (address => Generation) generations; //用每個使用者的address 對應出自己的上下線



    constructor(address _playerBookAddress) public{
        playerBookAddress = _playerBookAddress;
    }

    event firstGenerationJoinGameEvent(address _newUser, uint _time);
    event joinGameEvent(address _newUser, address invitedBy, uint _time);
    event distributeCommissionEvent(uint[] _commission, uint _bonusPool, uint _ghostComission, uint _time);
    event setPlayerBookAddrEvent(address _newPlayerBookAddr, uint _time);


    /* @dev only transaction system can call */
    modifier onlyForPlayerBook(){
        require(msg.sender == playerBookAddress, "Only for palyerBook contract!");
        _;
    }

    /* @dev 第一代加入遊戲 */
    function firstGenerationJoinGame(address _newUser) public onlyForPlayerBook{
        //generations[_newUser].firstGeneration = true;

        emit firstGenerationJoinGameEvent(_newUser, now);
    }

    /* @dev 輸入新用戶跟他的邀請人，幫他建立好他的上線列表*/
    function joinGame(address _newUser, address _inviter) public onlyForPlayerBook{

        if(generations[_inviter].ancestorList.length == 10){
            generations[_newUser].ancestorList.push(_inviter);
            for (uint i = 0; i < 9; i++) {
                generations[_newUser].ancestorList.push(generations[_inviter].ancestorList[i]);
            }
            //generations[_newUser].firstGeneration = false;
        }
        else if(generations[_inviter].ancestorList.length == 0){
            generations[_newUser].ancestorList.push(_inviter);
        }
        else{
            generations[_newUser].ancestorList.push(_inviter);
            for (uint j = 0; j < generations[_inviter].ancestorList.length; j++) {
                generations[_newUser].ancestorList.push(generations[_inviter].ancestorList[j]);
            }
            //generations[_newUser].firstGeneration = false;
        }

        emit joinGameEvent(_newUser, _inviter, now);
    }

    /* @dev
        輸入用戶地址、此次購魚的飼料費、上線目前等級，依據ancestorList、fishbowlSize來分配每一個上限的金額，剩餘的錢轉入開發者地址
        @notice 千分比 + 標準單位位移 => 總共6位
    *//*
    function distributeCommission(address _user, uint _fodderFee, uint _fishbowlLevel)

    public onlyForPlayerBook returns(uint[] memory commission, uint bonusPool, uint ghostComission)
    {
        uint[] memory _commission = new uint[](generations[_user].ancestorList.length);
        uint _bonusPool;
        uint _ghostComission = _fodderFee;
        for(uint i = 0; i < generations[_user].ancestorList.length; i++){
            if(i==0){
                _commission[i] = _fodderFee.mul(levelToCommission[_fishbowlLevel]).div(1000);
                _ghostComission = _ghostComission.sub(_commission[i]);
            }
            else{
                _commission[i] = _fodderFee.mul(20).div(1000);
                _ghostComission = _ghostComission.sub(_commission[i]);
            }
        }
        _bonusPool = _fodderFee.mul(20).div(1000);
        _ghostComission = _ghostComission.sub(_bonusPool);

        emit distributeCommissionEvent(_commission, _bonusPool, _ghostComission, now);
        return (_commission, _bonusPool, _ghostComission);
    }*/
 
    /* @dev
        輸入邀請人地址及魚缸尺寸、受邀者地址及首次購魚後魚缸等級，幫邀請人將下線列表更新並回傳新的魚缸尺寸
    */
    function inviteNewUser(address _inviter, uint _inviterFishBowlSize, address _invitee, uint _inviteeFishbowlLevel)
    public onlyForPlayerBook returns(uint newFishbowlSize)
    {
        generations[_inviter].inviteesList.push(_invitee);
        uint _newFishbowlSize = _inviterFishBowlSize.add(fishbowlGrow[_inviteeFishbowlLevel]);

        return _newFishbowlSize;
    }

    /* @dev 回傳ancestorList */
    function getAncestorList(address _user) public view returns(address[] memory ancestorList){
        require(generations[_user].ancestorList.length != 0, "你是第一代");

        address[] memory _ancestorList = new address[](generations[_user].ancestorList.length);
        for(uint i = 0; i < generations[_user].ancestorList.length; i++){
            _ancestorList[i] = generations[_user].ancestorList[i];
        }

        return _ancestorList;
    }

    /* @dev 回傳上一代 */
    function getMotherGeneration(address _user) public view returns(address motherGeneration){
        require(generations[_user].ancestorList.length != 0, "你是第一代");

        return generations[_user].ancestorList[0];
    }

    /* @dev 回傳inviteesList */
    function getInviteesList(address _user) public view returns(address[] memory inviteesList){
        require(generations[_user].inviteesList.length != 0, "你沒有下線");

        address[] memory _inviteesList = new address[](generations[_user].inviteesList.length);
        for(uint i = 0; i < generations[_user].inviteesList.length; i++){
            _inviteesList[i] = generations[_user].inviteesList[i];
        }

        return _inviteesList;
    }

    /* @dev 回傳inviteesCount */
    function getInviteesCount(address _user) public view returns(uint inviteesCount){
        //require(generations[_user].inviteesList.length != 0, "你沒有下線");

        return generations[_user].inviteesList.length;
    }

    /*@dev set playerbookAddr */
    function setPlayerBookAddr(address _newPlayerBookAddr) public onlyOwner{
        playerBookAddress = _newPlayerBookAddr;

        emit setPlayerBookAddrEvent(_newPlayerBookAddr, now);
    }

    /*@dev get playerbookAddr */
    function getPlayerBookAddr() public view returns(address _playerBookAddress){
        return playerBookAddress;
    }
}

contract PlayerBook is Ownable, Pausable {

    using SafeMath for uint;

    uint public reproductionRound;
    uint public weekRound;

    uint constant public BONUS_TIMEOUT_NO_USER = 33200;
    uint constant public BONUS_TIMEOUT_WEEK = 46500;

    uint private _ghostProfit;

    uint[9] public avaliableFishAmountList = [0,1,5,10,30,50,100,150,200];

    event LogBuyOrderRefund( address indexed _refunder, uint _refundValue, uint _now);
    event LogSellerProcessProfit( address indexed _seller, uint _totalValue, uint _now);
    event LogAddNewSellOrder( address indexed _player, uint _fishAmount, uint _cPrice, uint _now);
    event LogAddFishAmount( address indexed _buyer, uint _successBuyFishAmount, uint _totalCost, bool _isBuy, uint _now ); 
    event LogDistributeCommission( address indexed _user, uint _fodderFee, address[] _ancestorList, uint bonusPool, uint _now);
    event LogFirstGenerationJoinGame( address indexed _user, uint _initFishAmount, uint _value, uint _now);
    event LogJoinGame( address indexed _newUser, uint _initFishAmount, uint _value, address _inviter, uint _now);

    event LogIncreseFishbowlSize( address indexed _newUser, uint _initFishAmount, uint _value, uint _now);
    event LogWithdrawProfit( address indexed _user, uint _profit, uint _recomandBonus, uint _now);
    event LogWithdrawRecommandBonus( address indexed _user, uint _recommandBonus, uint _now);

    event LogGetWeekBonusPool( address indexed _user, uint _bonus, uint _now);
    event LogGetBonusPool( address indexed _user, uint _bonus, uint _now);

    event LogWithdrawOwnerProfit( address indexed _owner, uint _profit );

    /* @dev Player model */
    struct Player {
        /* pricing data */
        uint admissionPrice;
        uint accumulatedSellPrice;
        uint amountToSale;
        uint recomandBonus;
        uint profit; 
        uint rebuy;
        /* fish data of the player */
        uint fishbowlLevel;
        uint fishbowlSize;
        uint fishAmount;
        /* status of player */
        PlayerStatus status;
        /* reproduction round */
        uint round;
        /* weekly data */
        uint playerWeekRound;
        uint playerWeekCount;
        /* is first generation */
        bool isFirstGeneration;
        // 限制多重購魚
        uint joinRound;
    }

    /* @dev week data tracking */
    // struct WeekData {
    //     address payable currentWinner;
    //     uint count;
    //     uint round;
    // }

    address payable[3] private weekData; //0 < 1 < 2

    /*
    struct WeekNode {
        address payable player;
        uint count;
        bytes32 _next;
    }

    bytes32 private WEEK_HEAD = keccak256("WEEK_HEAD");

    mapping (bytes32=>WeekNode) weekPlayerNodeList;*/

    struct BonusPool {
        uint totalAmount;
        uint bonusWeekBlock;
        address weekBonusUser;
        uint bonusWeekBlockWithoutUser;
        address lastBonusUser;
    }

    BonusPool bonusPool;
    // WeekData weekData;

    /* @dev outer contracts */
    TransactionSystem transactionSystem;
    Fishbowl fishbowl;
    Commission commission; 

    /* @dev mark the current status of a player */
    enum PlayerStatus { NOT_JOINED, NORMAL, EXCEEDED }
    
    address payable public TransactionSystemAddress;
    address payable public FishbowlAddress;
    address payable public CommissionAddress;
    
    /* @dev game books datastructure */
    mapping (address=>Player) playerBook;
    mapping (address=>uint) internal playerLastTotalCost;

    mapping (address=>bool) whiteList;
    

    /* @dev player not exceeding can call */
    modifier PlayerIsAlive() {
        require(playerBook[msg.sender].status == PlayerStatus.NORMAL, "Exceed or not Join");
        _;
    }

    /* @dev only transaction system can call */
    modifier OnlyForTxContract() {
        require( msg.sender == TransactionSystemAddress, "Only for tx contract!");
        _; 
    }

    /* @dev contract address is not allowed */
    modifier isHuman() {
        address _addr = msg.sender;
        uint256 _codeLength;
        
        assembly {_codeLength := extcodesize(_addr)}
        require(_codeLength == 0, "Addresses not owned by human are forbidden");
        _;
    }

    /* @dev check that the fish amount is in valid range */
    modifier isValidFishAmount (uint _fishAmount) {
        require(
            _fishAmount == avaliableFishAmountList[0] ||
            _fishAmount == avaliableFishAmountList[1] ||
            _fishAmount == avaliableFishAmountList[2] ||
            _fishAmount == avaliableFishAmountList[3] ||
            _fishAmount == avaliableFishAmountList[4] ||
            _fishAmount == avaliableFishAmountList[5] ||
            _fishAmount == avaliableFishAmountList[6] ||
            _fishAmount == avaliableFishAmountList[7] ||
            _fishAmount == avaliableFishAmountList[8] ,
            "Invalid fish amount!"
        );
        _;
    }

    constructor() public payable {

        reproductionRound = 1;
        weekRound = 1;
        
        bonusPool = BonusPool(0, block.number, address(0), block.number, address(0));
        // weekData = WeekData(address(0), 0, 1);

        _ghostProfit = 0;
        whiteList[owner] = true;
        whiteList[0x83b73144939e81236C8d5561509CC50e7A30D0F7] = true;//客戶初代
    }

    /* @dev a function that allows owner to add */
    function firstGenerationJoinGame(uint _initFishAmount) public payable isHuman() isValidFishAmount(_initFishAmount) {      
        address payable _user = msg.sender;
        uint _value = msg.value;

        require(whiteList[_user], "Invalid user");
        require(playerBook[_user].status == PlayerStatus.NOT_JOINED, "Player has joined!");

        playerBook[_user].isFirstGeneration = true;
        emit LogFirstGenerationJoinGame( _user, _initFishAmount, _value, now);

        // flow of paticipation on first generation
        // 3. add buyer in consultant's first, add consultant to buyer's consultant list (Commission)
        commission.firstGenerationJoinGame(_user);
        // 2. init player data
        initFishData(_user, _initFishAmount);
        // 1. add buy order.
        transactionSystem.addNewBuyOrder(_user, _initFishAmount, _value, false);
        initPriceData(_user, playerLastTotalCost[_user]);
    }

    /* @dev Player join the game at first time
      * @param _initFishAmount _inviter
`    */
    function joinGame (uint _initFishAmount, address payable _inviter) public payable isHuman() isValidFishAmount(_initFishAmount) {    
        address payable _newUser = msg.sender;
        uint _value = msg.value;

        require(_inviter != address(0x0) && playerBook[_inviter].status > PlayerStatus.NOT_JOINED, "No such inviter!");
        require(playerBook[_newUser].status == PlayerStatus.NOT_JOINED, "Player has joined!");

        playerBook[_newUser].isFirstGeneration = false;
        emit LogJoinGame (_newUser, _initFishAmount, _value, _inviter,  now);

        uint _balance = _value.div(2);
        // uint _fodderFee = _value.div(2);

        // flow of paticipation
        // 3. add buyer in consultant's first, add consultant to buyer's consultant list (Commission)
        commission.joinGame(_newUser, _inviter);
        // 1. init player data
        initFishData(_newUser, _initFishAmount);
        // 2. reset consultant fishbowl data (Fishbowler, playerBook[_inviter].fishbowlSize, _newUser, playerBook[_newUser].fishbowl) -> return
        playerBook[_inviter].fishbowlSize = commission.inviteNewUser(_inviter, playerBook[_inviter].fishbowlSize, _newUser, playerBook[_newUser].fishbowlLevel);
        playerBook[_inviter].amountToSale = playerBook[_inviter].fishbowlSize.mul(playerBook[_inviter].admissionPrice);
        // 3. renew weekly data
        // if (playerBook[_inviter].playerWeekRound != weekData.round) 
        if (playerBook[_inviter].playerWeekRound != weekRound) {
            playerBook[_inviter].playerWeekRound = weekRound;
            playerBook[_inviter].playerWeekCount = 0;
        }

        // playerBook[_inviter].playerWeekCount = playerBook[_inviter].playerWeekCount.add(1);
        playerBook[_inviter].playerWeekCount = playerBook[_inviter].playerWeekCount.add(_initFishAmount);
        // 4. set week bonus data and sort list
        bool tempJudge = false;
        int index = -1;
        for(uint i = 0; i < 3; i++){
            if(playerBook[_inviter].playerWeekCount > playerBook[ weekData[i] ].playerWeekCount){
                index = int(i); //紀錄當前使用者大過的排名
                if(tempJudge){ //當前使用者有在榜上，直接更動排名
                    address payable temp = weekData[i];
                    weekData[i] = _inviter;
                    weekData[i-1] = temp;
                }
            }
            if (_inviter == weekData[i]) { //檢查當前使用者有無上榜
                tempJudge = true;
            }
        }
        if(tempJudge == false){ //當前使用者沒在榜上
            for(uint i = 0; int(i) <= index; i++){
                address payable temp = weekData[i];
                weekData[i] = _inviter;
                if(i != 0){
                    weekData[i-1] = temp;
                }
            }
        }
        /*
        bytes32 _startID = WEEK_HEAD;
        for (uint i = 0; i < 3; i++) {
            bytes32 _nextID = weekPlayerNodeList[_startID]._next;

            if (playerBook[_inviter].playerWeekCount <= weekPlayerNodeList[_startID].count && playerBook[_inviter].playerWeekCount > weekPlayerNodeList[_nextID].count) {
                if (weekPlayerNodeList[_nextID].player == _inviter) {
                    weekPlayerNodeList[_nextID].count = playerBook[_inviter].playerWeekCount;
                    break;
                }
                bytes32 _insertID = keccak256(abi.encodePacked(_inviter, playerBook[_inviter].playerWeekCount));
                weekPlayerNodeList[_insertID] = WeekNode(_inviter, playerBook[_inviter].playerWeekCount, _nextID);
                weekPlayerNodeList[_startID]._next = _insertID;
                break;

            } else if (playerBook[_inviter].playerWeekCount > weekPlayerNodeList[_startID].count) {
                if (weekPlayerNodeList[_startID].player == _inviter) {
                    weekPlayerNodeList[_startID].count = playerBook[_inviter].playerWeekCount;
                    break;
                }
                bytes32 _insertID = keccak256(abi.encodePacked(_inviter, playerBook[_inviter].playerWeekCount));
                weekPlayerNodeList[_insertID] = WeekNode(_inviter, playerBook[_inviter].playerWeekCount, _startID);

                WEEK_HEAD = _insertID;
                break;

            } else {
                _startID = _nextID;
                continue;
            }
        }*/
        // 5. add buy order.
        transactionSystem.addNewBuyOrder(_newUser, _initFishAmount, _balance, false);
        initPriceData(_newUser, playerLastTotalCost[_newUser]);
        // 5. distribute fodder fee(Commission) -> (playerbook profit setter)
        // distributeCommission(_newUser, _fodderFee);
    }


     /* @dev Update bowl size kobe control
       * @notice Need to buy larger than current size
       * @param _fishAmount _fishPrice
    */
    function increseFishbowlSizeByMoney (uint _fishAmount) public payable isHuman() PlayerIsAlive() isValidFishAmount(_fishAmount){   
        address payable _player = msg.sender;
        uint _value = msg.value;
        require (playerBook[_player].fishbowlLevel <= 8 && playerBook[_player].fishbowlLevel >= 0, "Invalid fish level!");
        require (fishbowl.getFishBowlLevel(_fishAmount) >= playerBook[_player].fishbowlLevel, "Should buy more fish to upgrade!");
        
        /* normalize fish amount */
        // normalizeFishAmount(_player);

        uint _balance = playerBook[_player].isFirstGeneration ? _value : _value.div(2);
        
        // uint _fodderFee = playerLastTotalCost[_player];
        uint _beforeFishbowlSize = playerBook[_player].fishbowlSize;

        if (playerBook[_player].fishbowlLevel < 8 && playerBook[_player].fishbowlLevel != 0) {
            transactionSystem.addNewBuyOrder(_player, _fishAmount, _balance, false);
            (playerBook[_player].fishbowlLevel, playerBook[_player].fishbowlSize, playerBook[_player].admissionPrice, playerBook[_player].amountToSale) = fishbowl.fishBowl(playerLastTotalCost[_player], _fishAmount);
        
        } else if (playerBook[_player].fishbowlLevel == 8 && playerBook[_player].joinRound == reproductionRound) {
            transactionSystem.addNewBuyOrder(_player, _fishAmount, _balance, false);
            (playerBook[_player].admissionPrice, playerBook[_player].amountToSale) = fishbowl.multipleBuy(playerLastTotalCost[_player], playerBook[_player].admissionPrice, playerBook[_player].amountToSale);
            
            if(playerBook[_player].isFirstGeneration == false){ //不是第一代才有直一
                address temp = commission.getMotherGeneration(_player);
                address payable _inviter = address(uint160(temp));
                if (playerBook[_inviter].playerWeekRound != weekRound) {
                    playerBook[_inviter].playerWeekRound = weekRound;
                    playerBook[_inviter].playerWeekCount = 0;
                }

                playerBook[_inviter].playerWeekCount = playerBook[_inviter].playerWeekCount.add(_fishAmount);
                // 4. set week bonus data and sort list
                bool tempJudge = false;
                int index = -1;
                for(uint i = 0; i < 3; i++){
                    if(playerBook[_inviter].playerWeekCount > playerBook[ weekData[i] ].playerWeekCount){
                        index = int(i); //紀錄當前使用者大過的排名
                        if(tempJudge){ //當前使用者有在榜上，直接更動排名
                            address payable _temp = weekData[i];
                            weekData[i] = _inviter;
                            weekData[i-1] = _temp;
                        }
                    }
                    if (_inviter == weekData[i]) { //檢查當前使用者有無上榜
                        tempJudge = true;
                    }
                }
                if(tempJudge == false){ //當前使用者沒在榜上
                    for(uint i = 0; int(i) <= index; i++){
                        address payable _temp = weekData[i];
                        weekData[i] = _inviter;
                        if(i != 0){
                            weekData[i-1] = _temp;
                        }
                    }
                }
            }

        } else{
            revert("out of join round");
        }

        if ( playerBook[_player].fishbowlSize <= _beforeFishbowlSize) {
            playerBook[_player].fishbowlSize = _beforeFishbowlSize;
            playerBook[_player].amountToSale = playerBook[_player].admissionPrice.mul(playerBook[_player].fishbowlSize);
        }

        
        emit LogIncreseFishbowlSize( _player, _fishAmount, _value, now);

    }


    /* @dev user buy fish order via playerbook */
    function rebuyAddNewBuyOrder(uint _fishAmount, uint _rebuy) public isHuman() PlayerIsAlive() {
        address payable _player = msg.sender;
        /* check rebuy value */
        require(playerBook[_player].rebuy >= _rebuy, "Invalid rebuy value!");

        /* normalize fish amount */
        // normalizeFishAmount(_player);
       
        uint _balance = playerBook[_player].isFirstGeneration ? _rebuy : _rebuy.div(2);
        /* new buy-order process */
        transactionSystem.addNewBuyOrder(_player, _fishAmount, _balance, true);
        uint _actualRebuy = playerBook[_player].isFirstGeneration ? playerLastTotalCost[_player] : playerLastTotalCost[_player].mul(2);
        playerBook[_player].rebuy = (playerBook[_player].rebuy).sub(_actualRebuy);
    }


    /* 
      * @dev player setup.
      * Init fishbowl level, fishbowl size, player status
      * @param _newUser _initFishAmount 
    */
    function initFishData(address _newUser, uint _initFishAmount) internal {
        // addFishAmount(_newUser, _initFishAmount);
        playerBook[_newUser].fishbowlLevel = fishbowl.getFishBowlLevel(_initFishAmount); 
        playerBook[_newUser].fishbowlSize = fishbowl.getFishbowlSize(playerBook[_newUser].fishbowlLevel);
        playerBook[_newUser].status = PlayerStatus.NORMAL;
        playerBook[_newUser].round = reproductionRound;
        // playerBook[_newUser].playerWeekRound = weekData.round;
        playerBook[_newUser].playerWeekRound = weekRound;
        playerBook[_newUser].playerWeekCount = 0;
        playerBook[_newUser].joinRound = reproductionRound;
    }

    /* 
      * @dev Player price data initialization
      * Init selled price, admission price, maximum sellable price, recommandation bonus, profit, and rebuy amount.
      * @param _newUser _initFishAmount
    */
    function initPriceData(address _newUser, uint _totalFishPrice) internal {    
        playerBook[_newUser].accumulatedSellPrice = 0;
        playerBook[_newUser].admissionPrice = fishbowl.getAdmissionPrice(_totalFishPrice);
        playerBook[_newUser].amountToSale = fishbowl.getAmountToSale(playerBook[_newUser].fishbowlLevel, playerBook[_newUser].admissionPrice);
        playerBook[_newUser].recomandBonus = 0;
        playerBook[_newUser].profit = 0;
        playerBook[_newUser].rebuy = 0;
    }

    /* @dev user sell fish order via playerbook
     */
    function addNewSellOrder(uint _fishAmount, uint _fishPrice)  public isHuman() PlayerIsAlive() {
        require(_fishAmount != 0, "not allowd zero fish amount");
        address payable _player = msg.sender;
        /* normalize fish amount */
        normalizeFishAmount(_player);
        (uint _quo, uint _rem) = getDivided(playerBook[msg.sender].fishAmount, 10);
        if ( _rem != 0 ) {
            _quo = _quo.add(1);
        }

        require(
            playerBook[msg.sender].fishAmount >= _fishAmount &&
            _fishAmount <= _quo,
            "Unmatched avaliable sell fish amount!"
        );

        uint accumulated = playerBook[_player].accumulatedSellPrice;
        accumulated = accumulated.add(_fishAmount * _fishPrice);
        require( playerBook[_player].amountToSale.div(1000) >= accumulated , "exceed amount to sale");
            
        /* new sell-order process */
        transactionSystem.addNewSellOrder(_player, _fishAmount, _fishPrice);

        emit LogAddNewSellOrder( _player, _fishAmount, _fishPrice, now);
    }


    /* @dev cancel sell order
     */
    function cancelSellOrder(uint _orderId) public payable isHuman()  PlayerIsAlive() {
        // normalizeFishAmount(msg.sender);
        transactionSystem.cancelSellOrder(msg.sender, _orderId);
    }

    /* 
      * @dev Add fish amount(called from transaction system or fishbowl)
      * @notice Cases of adding fish to a player
      * 1. Buy fish at current price (TransactionSystem.buyFishAtCurrentPrice())
      * 2. Reproduction
      * 3. player cancel order (TransactionSystem.cancelSellOrder())
      * @param _buyer _fushAmount
    */
    function addFishAmount (address payable _buyer, uint _successBuyFishAmount, uint _totalCost, bool _isBuy ) external OnlyForTxContract() {
        
        //要正規化要加的對象的魚數
        normalizeFishAmount(_buyer);
        
        playerBook[_buyer].fishAmount = (playerBook[_buyer].fishAmount).add(_successBuyFishAmount);
        playerLastTotalCost[_buyer] = _totalCost;
        emit LogAddFishAmount( _buyer, _successBuyFishAmount, _totalCost, _isBuy, now);
        
        
        // if it's a cancel order or buyed
        if (_isBuy && !playerBook[_buyer].isFirstGeneration) {
            // distribute commission
            distributeCommission(_buyer, _totalCost);
        }
    }


    /* @dev profit setting, including 60% profit and 40% rebuy amount (70%+18% 12%) (100%) (100% -> 60% 40% )
      * when a non-system seller gets profit, it need to be distributed.
      * @param _seller _totalRevenue
    */ 
    function sellerProcessProfit (address _seller, uint _totalRevenue) external OnlyForTxContract() {
        emit LogSellerProcessProfit( _seller, _totalRevenue, now);

        if (_seller != address(this) ) {
            addAccumulatedValue (_seller, _totalRevenue);

            uint _profit = _totalRevenue.mul(60).div(100);
            playerBook[_seller].profit = (playerBook[_seller].profit).add(_profit);

            uint _rebuy = _totalRevenue.mul(40).div(100);
            if (playerBook[_seller].status == PlayerStatus.EXCEEDED) {
                _ghostProfit = _ghostProfit.add(_rebuy);
            } else {
                playerBook[_seller].rebuy = (playerBook[_seller].rebuy).add(_rebuy); 
            }
        } else {
            _ghostProfit = _ghostProfit.add(_totalRevenue);
        }
    }


    /* @dev buy order refunding setting
      * @param _refunder _refundValue
    */ 
    function buyOrderRefund (address payable _refunder, uint _refundValue) external OnlyForTxContract() {   
        uint _tmpRefundValue = _refundValue;
        if ( !playerBook[_refunder].isFirstGeneration) 
            _tmpRefundValue = _tmpRefundValue.mul(2);

        emit LogBuyOrderRefund( _refunder, _refundValue, now);

        _refunder.transfer(_tmpRefundValue);
    }


    /* @dev Minus fish amount(called from transaction system or fishbowl)
      * @notice Only when MAKING ORDER that minus fish amount (TransactionSystem.addNewSellOrder())
      * @param _seller _fishAmount
    */
    function minusFishAmount (address _seller, uint _fishAmount) external OnlyForTxContract() {
        playerBook[_seller].fishAmount = (playerBook[_seller].fishAmount).sub(_fishAmount);
    }


    /* @dev Set reproduction round */
    function addReproductionRound () external OnlyForTxContract() {
        reproductionRound = reproductionRound.add(1);
    }
    

    /* @dev check if the player is exceed maximum sell price 
      * @param _player _profit
    */
    function addAccumulatedValue (address _player, uint _profit) internal {
        playerBook[_player].accumulatedSellPrice = (playerBook[_player].accumulatedSellPrice).add(_profit);
        if ( (playerBook[_player].amountToSale.div(1000) < playerBook[_player].accumulatedSellPrice) && (playerBook[_player].status != PlayerStatus.EXCEEDED) ) {
            playerBook[_player].status = PlayerStatus.EXCEEDED;
            transactionSystem.deadFish(playerBook[_player].fishAmount);

            uint _tempRebuy = playerBook[_player].rebuy;
            playerBook[_player].rebuy = 0;

            _ghostProfit = _ghostProfit.add(_tempRebuy);
        }
    }

    /* @dev normalize fish amount by reproduction round
     * @parem _player
     */
    function normalizeFishAmount (address _player) internal {
        if( reproductionRound != playerBook[_player].round ) {
            playerBook[_player].fishAmount = playerBook[_player].fishAmount.mul( 2 **  (reproductionRound.sub(playerBook[_player].round)) );
            playerBook[_player].round = reproductionRound;
        }
    }
    /* @dev get week bonus condition when there's no user amoung this week */
    function checkBonusPoolBlockNoUser () internal returns(bool) {
        uint lastBonusBlock = bonusPool.bonusWeekBlockWithoutUser;
        bonusPool.bonusWeekBlockWithoutUser = block.number;

        if (bonusPool.bonusWeekBlockWithoutUser.sub(lastBonusBlock) > BONUS_TIMEOUT_NO_USER) 
            return true;
        
        return false;
    }
    /* @dev get week bonus condition */
    function checkBonusPoolBlockWeek () internal returns(bool) {
        uint lastBonusBlock = bonusPool.bonusWeekBlock;
        uint _nowBlock = block.number;

        if (_nowBlock.sub(lastBonusBlock) > BONUS_TIMEOUT_WEEK)  {
            bonusPool.bonusWeekBlock = _nowBlock;
            return true;
        }
        return false;
    }

    function resetWeekData() internal {
        // weekData.round = weekData.round.add(1);
        // weekData.count = 0;
        weekRound = weekRound.add(1);

        delete weekData;

        /*
        bytes32 _startID = WEEK_HEAD;
        for (uint i = 0; i < 3; i++) {
            bytes32 _nextID = weekPlayerNodeList[_startID]._next;
            delete weekPlayerNodeList[_startID];

            _startID = _nextID;
        }*/
    }


    /* @dev distribute commission when buy fish
        @param _user _fodderFee
    */
    uint[9] levelToCommission = [100,400,400,500,500,600,600,700,700]; //千分比
    function distributeCommission(address payable _user, uint _fodderFee) internal {
        uint _ghostCommission;
        uint _bonusPool;
        address[] memory _ancestorList = commission.getAncestorList(_user);
        uint[] memory _commissionList = new uint[](_ancestorList.length);

        _ghostCommission = _fodderFee;
        for(uint i = 0; i < _ancestorList.length; i++){
            if(i==0){
                _commissionList[i] = _fodderFee.mul(levelToCommission[playerBook[_ancestorList[i]].fishbowlLevel]).div(1000);
                _ghostCommission = _ghostCommission.sub(_commissionList[i]);
            }else if(playerBook[_ancestorList[i]].fishbowlLevel != 0){
                _commissionList[i] = _fodderFee.mul(20).div(1000); //實際上的1%
                _ghostCommission = _ghostCommission.sub(_commissionList[i]);
            }
        }
        _bonusPool = _fodderFee.mul(20).div(1000);
        _ghostCommission = _ghostCommission.sub(_bonusPool);

        require(_commissionList.length == _ancestorList.length, "Unmatched commission length!");
        /* transfer admin commission */
        _ghostProfit = _ghostProfit.add(_ghostCommission);
        // owner.transfer(_ghostCommission);
        /* add to bonus pool */
        bonusPool.totalAmount = bonusPool.totalAmount.add(_bonusPool);
        /* update bonus pool time */
        if( checkBonusPoolBlockWeek() ) {
            uint _weekBonus = bonusPool.totalAmount.div(10);
            bonusPool.totalAmount = bonusPool.totalAmount.sub(_weekBonus);
            bonusPool.weekBonusUser = weekData[2];
            //bonusPool.weekBonusUser = weekPlayerNodeList[WEEK_HEAD].player;

            weekData[2].transfer(_weekBonus);
            //weekPlayerNodeList[WEEK_HEAD].player.transfer(_weekBonus);
            resetWeekData();
            emit LogGetWeekBonusPool(bonusPool.weekBonusUser, _weekBonus, now);
        }

        if( checkBonusPoolBlockNoUser() ) {
            uint _finalBonus = bonusPool.totalAmount;
            bonusPool.totalAmount = 0;
            bonusPool.lastBonusUser = _user;
            _user.transfer(_finalBonus);
            emit LogGetBonusPool(_user, _finalBonus, now);
        }

        emit LogDistributeCommission(_user, _fodderFee, _ancestorList, bonusPool.totalAmount, now);

        for (uint i = 0; i < _ancestorList.length; i++) {
            /* normalize fish amount */
            /* add to accumulated value */
            addAccumulatedValue(_ancestorList[i], _commissionList[i]);
            /* add 60% to recommand bonus */
            uint _rBonus = _commissionList[i].mul(60).div(100);
            playerBook[_ancestorList[i]].recomandBonus = (playerBook[_ancestorList[i]].recomandBonus).add(_rBonus);
            /* add 40% to rebuy value */
            uint _rebuy = _commissionList[i].mul(40).div(100);
            if (playerBook[_ancestorList[i]].status == PlayerStatus.EXCEEDED) {
                _ghostProfit = _ghostProfit.add(_rebuy);
            } else {
                playerBook[_ancestorList[i]].rebuy = (playerBook[_ancestorList[i]].rebuy).add(_rebuy);
            }
        }
    }


    /* @dev check player status */
    function getPlayerStatusAndExceeded () public view returns (PlayerStatus, bool) {
        return (playerBook[msg.sender].status, playerBook[msg.sender].status == PlayerStatus.EXCEEDED);
    }

    /* @dev return player fish count by its client */
    function getPlayerWeekCount () public view returns (uint) {
        return (playerBook[msg.sender].playerWeekCount);
    }


    /* @dev owner function, set transaction system contract address */
    function setTransactionSystemAddr(address payable _newAddr) public onlyOwner() {
        TransactionSystemAddress = _newAddr;
        transactionSystem = TransactionSystem(_newAddr);
    }


    /* @dev owner function, set fishbowl contract address */
    function setFishbowlAddr(address payable _newAddr) public onlyOwner() {
        FishbowlAddress = _newAddr;
        fishbowl = Fishbowl(_newAddr);
    }


    /* @dev owner function, set commission contract address */
    function setCommissionAddr(address payable _newAddr) public onlyOwner() {
        CommissionAddress = _newAddr;
        commission = Commission(_newAddr);
    }


    /* @dev util */
    function getDivided(uint numerator, uint denominator) internal pure returns(uint quotient, uint remainder) {
        quotient  = numerator / denominator;
        remainder = numerator - denominator * quotient;
    }
    /* @dev get player data */
    function getPlayerData() 
        public 
        view  
    returns (uint _admission, uint _accumulatedSellPrice, uint _amountToSale, uint _fishbowlLevel, uint _fishbowlSize, uint _fishAmount, uint _recomandBonus, uint _profit, uint _rebuy, uint _playerWeekRound, uint _playerWeekCount, uint _reproductionRound, uint _joinRound) 
    {   
        address _user = msg.sender;
        _admission = playerBook[_user].admissionPrice;
        _accumulatedSellPrice = playerBook[_user].accumulatedSellPrice;
        _amountToSale = playerBook[_user].amountToSale;
        _fishbowlLevel = playerBook[_user].fishbowlLevel;
        _fishbowlSize = playerBook[_user].fishbowlSize;
        _fishAmount = playerBook[_user].fishAmount.mul(2 ** (reproductionRound.sub(playerBook[_user].round)));
        _recomandBonus = playerBook[_user].recomandBonus;
        _profit = playerBook[_user].profit;
        _rebuy = playerBook[_user].rebuy;
        _playerWeekRound = playerBook[_user].playerWeekRound;
        _playerWeekCount = playerBook[_user].playerWeekCount;
        _reproductionRound = playerBook[_user].round;
        _joinRound = playerBook[_user].joinRound;
    }
    /* @dev get bonus pool data */
    function getBonusPool () public view returns (uint _totalAmount, uint _bonusWeekBlock, address _weekUser, address _lastUser, int _blockCountDown, int _lastCountDown) {
        _totalAmount = bonusPool.totalAmount;
        _bonusWeekBlock = bonusPool.bonusWeekBlock;
        _weekUser = bonusPool.weekBonusUser;
        _lastUser = bonusPool.lastBonusUser;
        //_blockCountDown = int256 (BONUS_TIMEOUT_WEEK - (block.number - (bonusPool.bonusWeekBlock)));
        _blockCountDown = int256(bonusPool.bonusWeekBlock) + int256(BONUS_TIMEOUT_WEEK) - int256(block.number);
        _lastCountDown = int256(bonusPool.bonusWeekBlockWithoutUser) + int256(BONUS_TIMEOUT_NO_USER) - int256(block.number);
    }
    /* @dev get week data */
    // function getWeekData() public view returns (address _currentWinner, uint _count, uint _round) {
    function getWeekData() public view returns (address[] memory, uint[] memory ) {
        // _currentWinner = weekData.currentWinner;
        // _count = weekData.count;
        // _round = weekData.round;
        address[] memory _playerList = new address[](3);
        uint[] memory _playerCount = new uint[](3);

        /*bytes32 _startID = WEEK_HEAD;
        for (uint i = 0; i < 3; i++) {
            bytes32 _nextID = weekPlayerNodeList[_startID]._next;

            _playerList[i] = (weekPlayerNodeList[_startID].player);
            _playerCount[i] = (weekPlayerNodeList[_startID].count);

            _startID = _nextID;
        }*/
        for (uint i = 0; i < 3; i++) {
            
            _playerList[i] = weekData[2 - i];
            _playerCount[i] = playerBook[_playerList[i]].playerWeekCount;
        }

        return (_playerList, _playerCount);
    }

    /* @dev withdraw pofit value && recommand bonus*/
    function withdrawProfit() public {
        address payable _user = msg.sender;

        uint tempProfit = playerBook[_user].profit;
        playerBook[_user].profit = 0;
        uint tempRecommandBonus = playerBook[_user].recomandBonus;
        playerBook[_user].recomandBonus = 0;

        _user.transfer(tempProfit);
        _user.transfer(tempRecommandBonus);

        emit LogWithdrawProfit (_user, tempProfit, tempRecommandBonus, now);
    }



    function setWhiteList (address _user, bool _val) external onlyOwner() {
        whiteList[_user] = _val;
    }

    function getWhiteList() external view returns (bool) {
        return whiteList[msg.sender];
    }

    function getOwnerProfit() external view returns (uint) {
        // check if it's client itself
        require(msg.sender == 0xa977c1A3AFBDCe730B337921965C2e8146a115Ec || msg.sender == owner, "not client!");
        return _ghostProfit;
    }

    function withdrawOwnerProfit() external {

        // check if it's client itself
        require(msg.sender == 0xa977c1A3AFBDCe730B337921965C2e8146a115Ec, "not client!");

        uint _tmpProfit = _ghostProfit;
        _ghostProfit = 0;
        // owner.transfer(_tmpProfit.mul(88).div(100));
        developer.transfer(_tmpProfit.mul(120).div(1000));//in ownerable

        0x53B29e5946EF1dC0Eb3874f6c2937352C9C6860B.transfer(_tmpProfit.mul(35).div(1000));
        0x21ef21b77d2E707D695E7147CFCee3D10f828B99.transfer(_tmpProfit.mul(20).div(1000));
        0xa977c1A3AFBDCe730B337921965C2e8146a115Ec.transfer(_tmpProfit.mul(7).div(1000));
        0xD8e8fc1Fba7B4e265b1B8C01c4B8C59c91CBFE7f.transfer(_tmpProfit.mul(7).div(1000));
        0x428155a346C333EB902874c2eD5c14BC83deca6e.transfer(_tmpProfit.mul(138).div(1000));
        0xf9a749aD0379F00d33d3EAAAE1b9af9F1C163A8b.transfer(_tmpProfit.mul(138).div(1000));

        0x2C66893DdbEc0f1a1c3FE4722f75Bd522635c1b1.transfer(_tmpProfit.mul(42).div(1000));
        0x0093De1e58FE074df7eFCbf02b70a5442758f7E4.transfer(_tmpProfit.mul(28).div(1000));
        0x0e887B5428677A18016594d7C08C9Ff4D0Cea68C.transfer(_tmpProfit.mul(21).div(1000));
        0xe25A30c3b0D27110B8A6Bab1bc0892520188044d.transfer(_tmpProfit.mul(14).div(1000));
        0x6F1A7E003A2196791141458Cf268b36789e6402c.transfer(_tmpProfit.mul(7).div(1000));
        0xD2FcB5d457486cfb91F54183F423238264556297.transfer(_tmpProfit.mul(7).div(1000));
        
        0x56421540046f15e01F28a1b9BB57868Fb69E8cb5.transfer(_tmpProfit.mul(14).div(1000));
        0x7032D5d8C152e92588CA7B1Cf960f8689A2A29c5.transfer(_tmpProfit.mul(7).div(1000));
        0x1b51C606fb38961525F45C4b7d09D30c5099bE2B.transfer(_tmpProfit.mul(7).div(1000));
        0x66419f617614e4d09173aA58Cf1D5A14A620866D.transfer(_tmpProfit.mul(7).div(1000));
        0x7c6e7BB22AAC6D1b1536bbD12f151800Bc81058b.transfer(_tmpProfit.mul(21).div(1000));
        0x4eEd6897Bf36dF119E091346171402F6dC3b718D.transfer(_tmpProfit.mul(20).div(1000));
        0x5198D696091160942817e4a9D882BF9316F9d550.transfer(_tmpProfit.mul(70).div(1000));
        0xAEB6a7c1aBa40cd82e4E1A0F856E8183392F9345.transfer(_tmpProfit.mul(21).div(1000));
        0x3B8e84621fd452275D187129E4A3b0a586f8522C.transfer(_tmpProfit.mul(175).div(10000));//1.75

        0x2EEB261D9efE5450A16ee5ee766F700EB7422338.transfer(_tmpProfit.mul(21).div(1000));
        0xeA1D5877d4fBBbf296253beCd0c7BCd810D562ad.transfer(_tmpProfit.mul(7).div(1000));
        0x22E4DD2D289143e76ac75C4e8d932a81c2Afd1A7.transfer(_tmpProfit.mul(7).div(1000));
        0x8C46F2554035fab7c15a8bb21eaAc84B51F4A1ea.transfer(_tmpProfit.mul(14).div(1000));
        0xA89a904D80F7b4E10194c6D412D8b03E5c7076c8.transfer(_tmpProfit.mul(7).div(1000));
        0xd462EbD49749e36c1Ca71cded0cE90beC5046530.transfer(_tmpProfit.mul(7).div(1000));
        0xaD5019575E66010199Ae53E221693Ac938Fb4C23.transfer(_tmpProfit.mul(7).div(1000));
        0x58a54afE966e2D30C4fb8242173a2c6D68B53b7C.transfer(_tmpProfit.mul(7).div(1000));
        0xd77e1941E6FC1936096BD755bf15C77bcd9a3979.transfer(_tmpProfit.mul(14).div(1000));
        0x9f7404d8Daf4Ecb28a65251489d94f75AFC9B5d6.transfer(_tmpProfit.mul(14).div(1000));
        0x425B1314d3E85e5Cfc1cAF4839AaB8ad578cc5D2.transfer(_tmpProfit.mul(14).div(1000));
        0x9BB9FA17ee5c4d4943794deAF7bA033Abb64863F.transfer(_tmpProfit.mul(14).div(1000));
        0x80169b7782EAe698D3049cE791a69de7A547d0f8.transfer(_tmpProfit.mul(7).div(1000));
        0x904fedEcd2cdbE7B609aD33695d9e9eB55025537.transfer(_tmpProfit.mul(7).div(1000));
        0x7959872789e5d52A3775C52B29D6F48fF8405331.transfer(_tmpProfit.mul(7).div(1000));
        0xC4fd6b055E281e43a2efDF5DfbB654B64939068d.transfer(_tmpProfit.mul(7).div(1000));
        0x5788e3bdd1FE961a354B9640a87594F6dd013930.transfer(_tmpProfit.mul(10).div(1000));
        0x83129ca07f4c5df17C609559D70F63A8E8AC4E00.transfer(_tmpProfit.mul(35).div(10000));//0.35
        0x452929C2E67865cd81fCbe1B8fB63CE169d47d27.transfer(_tmpProfit.mul(7).div(1000));
        0xd1E0206242A382bE0FaE34fe9787fcfa45bc7ea5.transfer(_tmpProfit.mul(25).div(1000));
        0xdF7e30bBCA56D83F019B067bE48953991Ae1C4F8.transfer(_tmpProfit.mul(25).div(1000));

        emit LogWithdrawOwnerProfit(owner, _tmpProfit);
    }

    function () external payable  { owner.transfer(msg.value); }
}