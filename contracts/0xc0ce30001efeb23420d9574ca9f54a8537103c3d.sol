pragma solidity ^0.4.18;

contract agame {
   
    address internal owner;
    uint256 internal startCount;
    
    uint internal roundCount; 
    uint internal startTime;
    uint internal currentRoundSupport;
    uint internal currentRoundLeft;
    uint internal timeout;
    mapping(uint => uint) roundSupportMapping;
   
    uint constant internal decimals = 18;
    uint constant internal min_wei = 1e9;
    uint constant internal dividendFee = 10;
    uint constant internal dynamicDividendFee = 6;
    uint constant internal platformDividendFee = 4;
   
    constructor(uint _startCount,uint timeout_) public{
        require(_startCount>0);
        owner = msg.sender;
        startCount = _startCount * 1e14;
        currentRoundLeft = startCount;
        currentRoundSupport = startCount;
        roundCount = 1;
        startTime = now;
        timeout = timeout_;
        roundSupportMapping[roundCount] = currentRoundLeft;
    }
    
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }
    
    modifier running() {
        require((now - startTime) < timeout,'time is out');
        _;
    }
    
    modifier correctValue(uint256 _eth) {
        require(_eth >= min_wei, "can not lessthan 1 gwei ");
        require(_eth <= 100000000000000000000000, "no vitalik, no");
        _;
    }
    
   string contractName = "OGAME";
   
   mapping(address => Buyer) buyerList;
   mapping(address => Buyer) buyerList_next;
   address[] addressList;
   address[] addressList_next;
   
   event ChangeName(string name_);
   event BuySuccess(address who,uint256 value,uint againCount);
   event SendDivedend(address who,uint256 value);
   event Transfer(
        address indexed from,
        address indexed to,
        uint256 tokens
    );
    event ReturnValue(
        address indexed from,
        address indexed to,
        uint256 tokens
    );
    
    function getContractName() public view returns(string name_){    
        return contractName;
    }
   
    function setContractName(string newName) public onlyOwner{
       contractName = newName;
       emit ChangeName(newName);
    }
    
    function getCurrentRoundLeft() public view returns(uint left,uint _all){
        return (currentRoundLeft,currentRoundSupport);
    }
    
    function transfer(address to_,uint256 amount) public onlyOwner returns(bool success_){
        to_.transfer(amount);
        emit Transfer(address(this), to_, amount);
        return true;
    }
   
    function dealDivedendOfBuyers() internal onlyOwner returns(bool success_){
        for (uint128 i = 0; i < addressList.length; i++) {
            uint256 _amount = buyerList[addressList[i]].amount*(100+dividendFee)/100;
            address _to = addressList[i];
            _to.transfer(_amount);
            emit SendDivedend(_to, _amount);
        }
        return true;
    }
   
    function gettAddressList() public view returns(address[] addressList_){
        return addressList;
    }
    
    function gameInfo() public view returns(string _gameName,uint _roundCount,uint _remaining,uint _all,uint _leftTime){
        return (contractName,roundCount,currentRoundLeft,currentRoundSupport,timeout-(now - startTime));
    }
   
    struct Buyer{
        address who;
        uint256 amount;
        uint time;
        uint againCount;
        bool isValue;
    }
  
    function buy(uint againCount_) payable correctValue(msg.value) running public{

        uint256 value = msg.value;
        address sender = msg.sender;
        uint returnValue = 0;
        if(currentRoundLeft <= value){
           returnValue = value - currentRoundLeft;
           value = currentRoundLeft;
        }

        currentRoundLeft -= value;

        if(currentRoundLeft == 0){
            _initNextRound();
        }

        if(returnValue > 0){
            sender.transfer(returnValue);
            emit ReturnValue(address(this), sender, returnValue);
        }

        Buyer memory buyer;
        if(buyerList[sender].isValue){
            buyer = buyerList[sender];
            buyer.amount = buyer.amount + value;
            buyerList[sender] = (buyer);
        }else{
            addressList.push(sender);
            buyer = Buyer(sender,value,now,againCount_,true);
            buyerList[sender] = (buyer);
        }
        emit BuySuccess(sender,value,againCount_);
       
    }
    
    // 内部方法
    function _initNextRound() internal{ 
        currentRoundSupport = currentRoundSupport * (100 + dividendFee + dynamicDividendFee + platformDividendFee)/100;
        currentRoundLeft = currentRoundSupport;
        roundCount++;
        roundSupportMapping[roundCount] = currentRoundSupport;
        startTime = now;
    }
    
    // view
    function mybalance() public view onlyOwner returns(uint256 balance){
        return address(this).balance;
    }
    
    function userAmount(address user) public view returns(uint256 _amount,uint256 _devidend){
        return (buyerList[user].amount,(buyerList[user].amount * (100+dividendFee) / 100));
    }
    
    function userDevidend(address user) public view returns(uint256 _amount){
        return (buyerList[user].amount * (100+dividendFee) / 100);
    }
  
}