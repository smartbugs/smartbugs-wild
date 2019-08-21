pragma solidity ^0.4.25;

contract wcgData{
    function getUserWCG(address userAddr)public view returns(uint256);
    function getLevel(uint256 series)external view returns(uint256);
    function getT()external view returns(uint);
    function getTotalWcg()external view returns(uint256);
    function wcgTrunEth(uint wcg)external view returns(uint256);
    function ethTrunWcg(uint256 price)external view returns(uint256);
    function serviceCharge(uint256 eth)external pure returns(uint256,uint256);
    function computingCharge(uint _eth)external pure returns(uint256);
    function currentPrice()public view returns(uint256);
    function getVoteBonusPool()external view returns(uint256);
    function getWcgBonusPool()external view returns(uint256);
    function indexIncrement()external returns(uint256);
    function getAllOrdersLength()external view returns(uint);
    function allOrders(uint256 index)external view returns(uint256);
    function getUserOrders(uint256 _orderId)external view returns(address,uint256,uint256,uint256,uint256,uint256,uint256);
    function getUserVips(address addr,uint index)external view returns(uint256,uint256,uint,uint256);
    function getUserVipsLength(address addr)external view returns(uint256);
    function wcgInfosOf(uint index)external view returns(address,uint256,uint256,uint8);
    function getWcgInfosLength()external view returns(uint);
}
contract voteBonusSystem{
    function drawProposalBouns(address addr)external returns(uint256);
    function vote(address addr,uint index,uint wcg)external returns(bool);
}
contract everydayBonusSystem{
    function bonusSystem(address addr) external returns(address,uint,uint256);
}
contract VIPSystem{
    function paymentVipOfEth(address addr,uint256 series,uint256 value)external returns(address,uint256,uint256,uint256,uint,uint256);
    function paymentVipOfWcg(address addr,uint256 series)external returns(address,uint256,uint256,uint256,uint,uint256);
    function putaway(address addr,uint256 _vipId,uint256 price)external returns(uint256,uint,uint256,uint256);
    function recall(uint256 orderId)external returns(bool);
    function sellVip(address userAddr,uint256 orderId,uint256 value)external returns(uint256,address);
}
contract WCGSystem{
    function buyWCG(address addr,uint256 _price)external returns(address,uint256,uint256,uint256);
    function sellWCG(address addr,uint256 wcg) external returns(uint256,address,uint256,uint256,uint256);
}
contract WcgAsia{
    address public owner;
    wcgData data;
    voteBonusSystem voteBonus;
    everydayBonusSystem everydayBonus;
    VIPSystem vip;
    WCGSystem wcg;
    event buyEvent(address addr,uint eth,uint wcg,uint256 __index);
    event sellEvent(address addr,uint eth,uint wcg,uint256 __index);
    event bonusEvent(address addr,uint bonus,uint256 __index);
    event paymentVipEvent(address addr,uint256 series,uint256 createId,uint256 index,uint price,uint256 __index);
    event orderEvent(address addr,uint256 series,uint price,uint256 orderId,uint256 __index,uint256 charge);
    event recallEvent(uint256 __index);
    event sellVipEvent(uint256 __index);
    constructor(address wcgDataContract)public{
      data = wcgData(wcgDataContract);
      owner = msg.sender;
    }
   function setVoteBonusContract(address voteBonusAddr)public onlyOwner{
       voteBonus = voteBonusSystem(voteBonusAddr);
   }
   function setEverydayBonusContract(address everydayBonusAddr)public onlyOwner{
       everydayBonus = everydayBonusSystem(everydayBonusAddr);
   }
   function setVIPSystemContract(address vipAddr)public onlyOwner{
       vip = VIPSystem(vipAddr);
   }
   function setWCGSystemContract(address wcgSystemAddr)public onlyOwner{
       wcg = WCGSystem(wcgSystemAddr);
   }
   function ethbuyToKen(uint256 _price)public payable{
       require(msg.value == _price);
       (address _addr,uint _eth,uint _wcg,uint256 _index) = wcg.buyWCG(msg.sender,msg.value);
       address(this).transfer(msg.value);
       emit buyEvent(_addr,_eth,_wcg,_index);
   }
   function sell(uint256 _wcg)public{
       (uint256 price,address _addr,uint256 _eth,uint256 __wcg,uint256 _index) = wcg.sellWCG(msg.sender,_wcg);
       require(price != 0);
       msg.sender.transfer(price);
       emit sellEvent(_addr,_eth,__wcg,_index);
   }
   function totalSupply()public view returns(uint256){
       return data.getTotalWcg();
   }
   function sellToken(uint _wcg)public view returns(uint256){
       return data.wcgTrunEth(_wcg);
   }
   function ethTrunWcg(uint256 price)public view returns(uint256){
       return data.ethTrunWcg(price);
   }
   function computingCharge(uint _eth)public view returns(uint256){
       return data.computingCharge(_eth);
   }
   function currentPrice()public view returns(uint256){
       return data.currentPrice();
   }
   function balanceOf(address who)public view returns(uint256){
       return data.getUserWCG(who);
   }
   function wcgTrunEth(uint256 _wcg)public view returns(uint256){
       return data.wcgTrunEth(_wcg);
   }
   function wcgInfosOf(uint index)public view returns(address,uint256,uint256,uint8){
       return data.wcgInfosOf(index);
   }
   function getWcgInfosLength()public view returns(uint){
        return data.getWcgInfosLength();
   }
  function bonusSystem() public{
     (address _addr,uint256 _userBonus,uint256 _index)= everydayBonus.bonusSystem(msg.sender);
     require(_userBonus != 0 );
     msg.sender.transfer(_userBonus);
     emit bonusEvent(_addr,_userBonus,_index);
  }
  function wcgBonusPool()public view returns(uint256){
     return data.getWcgBonusPool();
  }
  function drawProposalBouns()public{
      uint256 userBonus = voteBonus.drawProposalBouns(msg.sender);
      require(userBonus != 0 );
      msg.sender.transfer(userBonus);
  }
  function voteBonusPool()public view returns(uint256){
      return data.getVoteBonusPool();
  }
  function vote(uint256 index,uint256 _wcg)public{
      require(voteBonus.vote(msg.sender,index,_wcg));
  }
  function paymentVipOfEth(uint256 series)public payable{
      if(data.getLevel(series)==0)revert();
      if(msg.value < series*0.02 ether)revert();
      (address addr,uint256 _series,uint256 createId,uint256 index,uint price,uint256 __index) = vip.paymentVipOfEth(msg.sender,series,msg.value);
      address(this).transfer(msg.value);
      emit paymentVipEvent(addr,_series,createId,index,price,__index);
  }    
  function paymentVipOfWcg(uint256 series)public{
      if(data.getLevel(series)==0)revert();
      if(data.getUserWCG(msg.sender) / data.getT() < series * 1)revert();
      (address addr,uint256 _series,uint256 createId,uint256 index,uint price,uint256 __index) = vip.paymentVipOfWcg(msg.sender,series);
      emit paymentVipEvent(addr,_series,createId,index,price,__index);
  }
  function putaway(uint256 _vipId,uint256 price)public{
      (uint256 series,uint pc,uint256 _orderId,uint256 c) = vip.putaway(msg.sender,_vipId,price);
      emit orderEvent(msg.sender,series,pc,_orderId,data.indexIncrement(),c);
  }
  function recall(uint256 orderId)public{
      require(vip.recall(orderId));
      emit recallEvent(data.indexIncrement());
  }
  function sellVip(uint256 orderId)public payable{
      (uint256 price,address addr) = vip.sellVip(msg.sender,orderId,msg.value);
      require(price != 0 && addr != 0x0);
      address(addr).transfer(price);
      emit sellVipEvent(data.indexIncrement());
  }
  function serviceCharge(uint256 eth)public view returns(uint256,uint256){
      (uint256 price1,uint256 price2) = data.serviceCharge(eth);
      return (price1,price2);
  }
  function getAllOrdersLength()public view returns(uint){
      return data.getAllOrdersLength();
  }
  function allOrders(uint256 index)public view returns(uint256){
      return data.allOrders(index);
  }
  
  function userOrders(uint256 _orderId)public view returns(address,uint256,uint256,uint256,uint256,uint256,uint256){
      return data.getUserOrders(_orderId);
  }
  function userVipsOf(address addr,uint index)public view returns(uint256,uint256,uint,uint256){
      return data.getUserVips(addr,index);
  }
  function getUserVipsLength()public view returns(uint256){
      return data.getUserVipsLength(msg.sender);
  }
  function level(uint256 series)public view returns(uint256){
      return data.getLevel(series);
  }
  
  function()public payable{}
  function destroy()public onlyOwner {
      selfdestruct(owner);
  }
  function withdraw()public onlyOwner{
      owner.transfer(address(this).balance);
  }
  function recharge()public payable onlyOwner{
      address(this).transfer(msg.value);
  }
  function getBalance()public view returns(uint){
      return address(this).balance;
  }
   modifier onlyOwner(){
      require(msg.sender == owner);
      _;
   }
}