pragma solidity ^0.4.25;

/*
* https://12hourfasttrain.github.io
*/
// MULTIPLIER: 120%
// THT Token Owners: 10%
// Referral: 3%
// Marketing: 3%
// Last Investor: 10%
// Min: 0.05 ETH
// Max: 1 ETH

interface TwelveHourTokenInterface {
     function fallback() external payable; 
     function buy(address _referredBy) external payable returns (uint256);
     function exit() external;
}

contract TwelveHourFastTrain {
	address public owner;
	address public twelveHourTokenAddress;
    TwelveHourTokenInterface public TwelveHourToken; 
	uint256 constant private THT_TOKEN_OWNERS     = 10;
    address constant private PROMO = 0x31778364A4000F785c59D42Bb80e7E6E60b8457b;
    uint constant public PROMO_PERCENT = 1;
    uint constant public MULTIPLIER = 120;
    uint constant public MAX_DEPOSIT = 1 ether;
    uint constant public MIN_DEPOSIT = 0.05 ether;
	uint256 constant public VERIFY_REFERRAL_PRICE = 0.01 ether;
	uint256 constant public REFERRAL             = 3;

    uint constant public LAST_DEPOSIT_PERCENT = 10;
    
    LastDeposit public last;

	mapping(address => bool) public referrals;

    struct Deposit {
        address depositor; 
        uint128 deposit;   
        uint128 expect;    
    }

    struct LastDeposit {
        address depositor;
        uint expect;
        uint depositTime;
    }

    Deposit[] public queue;
    uint public currentReceiverIndex = 0; 

	modifier onlyOwner() 
    {
      require(msg.sender == owner);
      _;
    }
    modifier disableContract()
    {
      require(tx.origin == msg.sender);
      _;
    }

	/**
    * @dev set TwelveHourToken contract
    * @param _addr TwelveHourToken address
    */
    function setTwelveHourToken(address _addr) public onlyOwner
    {
      twelveHourTokenAddress = _addr;
      TwelveHourToken = TwelveHourTokenInterface(twelveHourTokenAddress);  
    }

	constructor() public 
    {
      owner = msg.sender;
    }

    function () public payable {
        if (msg.sender != twelveHourTokenAddress) invest(0x0);
    }

    function invest(address _referral) public payable disableContract
    {
		if(msg.value == 0 && msg.sender == last.depositor) {
            require(gasleft() >= 220000, "We require more gas!");
            require(last.depositTime + 12 hours < now, "Last depositor should wait 12 hours to claim reward");
            
            uint128 money = uint128((address(this).balance));
            if(money >= last.expect){
                last.depositor.transfer(last.expect);
            } else {
                last.depositor.transfer(money);
            }
            
            delete last;
        }
        else if(msg.value > 0){
            require(gasleft() >= 220000, "We require more gas!");
            require(msg.value >= MIN_DEPOSIT, "Deposit must be >= 0.01 ETH and <= 1 ETH"); 
            uint256 valueDeposit = msg.value;
            if(valueDeposit > MAX_DEPOSIT) {
                msg.sender.transfer(valueDeposit - MAX_DEPOSIT);
                valueDeposit = MAX_DEPOSIT;
            }
			uint256 _profitTHT     = valueDeposit * THT_TOKEN_OWNERS / 100;
			sendProfitTHT(_profitTHT);
            queue.push(Deposit(msg.sender, uint128(valueDeposit), uint128(valueDeposit*MULTIPLIER/100)));

            last.depositor = msg.sender;
            last.expect += valueDeposit*LAST_DEPOSIT_PERCENT/100;
            last.depositTime = now;

            uint promo = valueDeposit*PROMO_PERCENT/100;
            PROMO.transfer(promo);
			uint devFee = valueDeposit*2/100;
            owner.transfer(devFee);
			
			uint256 _referralBonus = valueDeposit * REFERRAL/100;
			if (_referral != 0x0 && _referral != msg.sender && referrals[_referral] == true) address(_referral).transfer(_referralBonus);
			else owner.transfer(_referralBonus);

            pay();
        }
    }

	function pay() private {
        uint128 money = uint128((address(this).balance)-last.expect);
        for(uint i=0; i<queue.length; i++){
            uint idx = currentReceiverIndex + i;  
            Deposit storage dep = queue[idx]; 
            if(money >= dep.expect){  
                dep.depositor.transfer(dep.expect); 
                money -= dep.expect;            
                delete queue[idx];
            }else{
                dep.depositor.transfer(money); 
                dep.expect -= money;       
                break;
            }
            if(gasleft() <= 50000)        
                break;
        }
        currentReceiverIndex += i; 
    }

	function sendProfitTHT(uint256 profitTHT) private
    {
        buyTHT(calEthSendToTHT(profitTHT));
        exitTHT();
    }
	
	function exitTHT() private
    {
      TwelveHourToken.exit();
    }
	
	/**
    * @dev calculate dividend eth for THT owner
    * @param _eth value want share
    * value = _eth * 100 / 64
    */
    function calEthSendToTHT(uint256 _eth) private pure returns(uint256 _value)
    {
      _value = _eth * 100 / 64;
    }

	function buyTHT(uint256 _value) private
    {
      TwelveHourToken.fallback.value(_value)();
    }

	function totalEthereumBalance() public view returns (uint256) {
        return address(this).balance;
    }

    function getDeposit(uint idx) public view returns (address depositor, uint deposit, uint expect){
        Deposit storage dep = queue[idx];
        return (dep.depositor, dep.deposit, dep.expect);
    }


	function verifyReferrals() public payable disableContract
    {
      require(msg.value >= VERIFY_REFERRAL_PRICE);
      referrals[msg.sender] = true;
      owner.transfer(msg.value);
    }
    
    function getDepositByAddress(address depositor) public view returns (uint256 index, uint256 deposit, uint256 expect) {
        for(uint i=currentReceiverIndex; i<queue.length; ++i){
            Deposit storage dep = queue[i];
            if(dep.depositor == depositor){
                index = i;
                deposit = dep.deposit;
                expect = dep.expect;
                break;
            }
        }
    }
    
    function getData()public view returns(uint256 _lastDepositBonus, uint256 _endTime, uint256 _currentlyServing, uint256 _queueLength, address _lastAddress) {
        _lastDepositBonus = address(this).balance;
        _endTime = last.depositTime + 12 hours;
        _currentlyServing = currentReceiverIndex;
        _queueLength = queue.length;
        _lastAddress = last.depositor;
    }

}