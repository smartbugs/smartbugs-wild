pragma solidity ^0.4.24;

/**
 * luck100.win - Fair Ethereum game platform
 * 
 * OutLuck100
 * More exciting game than Fomo3D
 * 
 * 1. One out of every three new coupons will be awarded 180% of the proceeds;
 * 
 * 2. Inviting others to buy lottery tickets can permanently earn 10% of the proceeds;
 * 
 * 3. 1% income per day sign-in
 */
 
contract Ownable {
  address public owner;
  address public admin;
  uint256 public lockedIn;
  uint256 public OWNER_AMOUNT;
  uint256 public OWNER_PERCENT = 2;
  uint256 public OWNER_MIN = 0.0001 ether;

  event OwnershipRenounced(address indexed previousOwner);
  event OwnershipTransferred(
    address indexed previousOwner,
    address indexed newOwner
  );


  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  constructor(address addr, uint256 percent, uint256 min) public {
    require(addr != address(0), 'invalid addr');
    owner = msg.sender;
    admin = addr;
    OWNER_PERCENT = percent;
    OWNER_MIN = min;
  }

  /**
   * @dev Throws if called by any account other than the owner.
   */
  modifier onlyOwner() {
    require(msg.sender==owner || msg.sender==admin);
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

  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param _newOwner The address to transfer ownership to.
   */
  function transferOwnership(address _newOwner) public onlyOwner {
    _transferOwnership(_newOwner);
  }

  /**
   * @dev Transfers control of the contract to a newOwner.
   * @param _newOwner The address to transfer ownership to.
   */
  function _transferOwnership(address _newOwner) internal {
    require(_newOwner != address(0));
    emit OwnershipTransferred(owner, _newOwner);
    owner = _newOwner;
  }

  function _cash() public view returns(uint256){
      return address(this).balance;
  }

  /*function kill() onlyOwner public{
    require(lockedIn == 0, "invalid lockedIn");
    selfdestruct(owner);
  }*/

  function setAdmin(address addr) onlyOwner public{
      require(addr != address(0), 'invalid addr');
      admin = addr;
  }

  function setOwnerPercent(uint256 percent) onlyOwner public{
      OWNER_PERCENT = percent;
  }

  function setOwnerMin(uint256 min) onlyOwner public{
      OWNER_MIN = min;
  }

  function _fee() internal returns(uint256){
      uint256 fe = msg.value*OWNER_PERCENT/100;
      if(fe < OWNER_MIN){
          fe = OWNER_MIN;
      }
      OWNER_AMOUNT += fe;
      return fe;
  }

  function cashOut() onlyOwner public{
    require(OWNER_AMOUNT > 0, 'invalid OWNER_AMOUNT');
    owner.send(OWNER_AMOUNT);
  }

  modifier isHuman() {
      address _addr = msg.sender;
      uint256 _codeLength;
      assembly {_codeLength := extcodesize(_addr)}
      require(_codeLength == 0, "sorry humans only");
      _;
  }

  modifier isContract() {
      address _addr = msg.sender;
      uint256 _codeLength;
      assembly {_codeLength := extcodesize(_addr)}
      require(_codeLength > 0, "sorry contract only");
      _;
  }
}

contract OutLuck100 is Ownable{
  event recEvent(address indexed addr, uint256 amount, uint8 tn, uint256 ts);

  struct CardType{
      uint256 price;
      uint256 signCount;
      uint8 signRate;
      uint8 outRate;
  }
  struct Card{
      address holder;
      uint256 blockNumber;
      uint256 signCount;
      uint256 sn;
      uint8 typeId;
      bool isOut;
  }
  struct User{
      address parentAddr;
      uint256 balance;
      uint256[] cids;
      address[] subs;
  }

  User _u;
  CardType[4] public cts;
  Card[] public cardList;
  uint256[] cardIds1;
  uint256[] cardIds2;
  uint256[] cardIds3;
  mapping(address=>User) public userList;
  mapping(address=>bool) public userExists;
  mapping(bytes6=>address) public codeList;
  uint256 pool_sign = 0;
  uint256 constant public PAY_LIMIT = 0.1 ether;
  uint256 constant public DAY_STEP = 5900;
  uint8 constant public MOD = 3;
  uint8 constant public inviteRate = 10;
  uint8 constant public signRate = 38;

  constructor(address addr, uint256 percent, uint256 min) Ownable(addr, percent, min) public{
      cts[0] = CardType({price:0, signCount:0, signRate:0, outRate:0});
      cts[1] = CardType({price:0.5 ether, signCount:100, signRate:1, outRate:120});
      cts[2] = CardType({price:1 ether, signCount:130, signRate:1, outRate:150});
      cts[3] = CardType({price:2 ether, signCount:150, signRate:1, outRate:180});
  }

  function() public payable{

  }

  function buyCode(bytes6 mcode) onlyOwner public payable{
      require(codeList[mcode]==address(0), 'code is Exists');
      codeList[mcode] = msg.sender;
  }

  function buyCard(bytes6 pcode, bytes6 mcode) public payable{
      require(pcode!=mcode, 'code is invalid');
      uint256 amount = msg.value;
      uint8 typeId = 0;
      for(uint8 i=1;i<cts.length;i++){
          if(amount==cts[i].price){
              typeId = i;
              break;
          }
      }
      require(typeId>0, 'pay amount is valid');

      _fee();
      pool_sign += amount*signRate/100;
      emit recEvent(msg.sender, amount, 1, now);

      if(!userExists[msg.sender]){//创建用户
          userExists[msg.sender] = true;
          userList[msg.sender] = _u;
          address parentAddr = codeList[pcode];
          if(parentAddr!=address(0)){
              if(!userExists[parentAddr]){
                  userExists[parentAddr] = true;
                  userList[parentAddr] = _u;
              }
              userList[msg.sender].parentAddr = parentAddr;
              userList[parentAddr].subs.push(msg.sender);
          }
      }

      User storage me = userList[msg.sender];
      uint256 cid = cardList.length;
      me.cids.push(cid);
      if(me.parentAddr!=address(0)){
          uint256 e = amount*inviteRate/100;
          userList[me.parentAddr].balance += e;
          emit recEvent(me.parentAddr, e, 2, now);
          payment(me.parentAddr);
      }

      cardList.push(Card({
          holder:msg.sender,
          blockNumber:block.number,
          signCount:0,
          sn:0,
          typeId:typeId,
          isOut:false
      }));

      if(typeId==1){
          cardIds1.push(cid);
          out(cardIds1);
      }else if(typeId==2){
          cardIds2.push(cid);
          out(cardIds2);
      }else if(typeId==3){
          cardIds3.push(cid);
          out(cardIds3);
      }

      if(codeList[mcode]==address(0) && typeId>1){
         codeList[mcode] = msg.sender;
         emit recEvent(msg.sender, 0, 6, now);
      }
  }

  function sign() public payable{
      User storage me = userList[msg.sender];
      CardType memory ct = cts[0];
      uint256[] memory cids = me.cids;
      uint256 e = 0;
      uint256 s = 0;
      uint256 n = 0;
      for(uint256 i=0;i<cids.length;i++){
          Card storage c = cardList[cids[i]];
          ct = cts[c.typeId];
          if(c.signCount>=ct.signCount || c.blockNumber+DAY_STEP>block.number) continue;
          n = (block.number-c.blockNumber)/DAY_STEP;
          if(c.signCount+n>=ct.signCount){
              c.signCount = ct.signCount;
          }else{
              c.signCount += n;
          }
          c.sn++;
          c.blockNumber = block.number;
          e = ct.price*ct.signRate/100;
          s += e;
      }
      if(s==0) return ;
      emit recEvent(msg.sender, s, 4, now);
      if(pool_sign<s) return ;
      me.balance += s;
      pool_sign -= s;
      payment(msg.sender);
  }

  function out(uint256[] cids) private{
      uint256 len = cids.length;
      if(len<MOD) return ;
      uint256 outIdx = len-1;
      if(outIdx%MOD!=0) return ;
      outIdx = cids[outIdx/MOD-1];
      Card storage outCard = cardList[outIdx];
      if(outCard.isOut) return ;
      outCard.isOut = true;
      CardType memory ct = cts[outCard.typeId];
      uint256 e = ct.price*ct.outRate/100;
      userList[outCard.holder].balance += e;
      emit recEvent(outCard.holder, e, 3, now);
      payment(outCard.holder);
  }

  function payment(address addr) private{
      User storage me = userList[addr];
      uint256 ba = me.balance;
      if(ba >= PAY_LIMIT){
          me.balance = 0;
          addr.send(ba);
          emit recEvent(addr, ba, 5, now);
      }
  }
  
  function getUserInfo(address addr, bytes6 mcode) public view returns(
    address parentAddr,
    address codeAddr,
    uint256 balance,
    address[] subs,
    uint256[] cids
    ){
      User memory me = userList[addr];
      parentAddr = me.parentAddr;
      codeAddr = codeList[mcode];
      balance = me.balance;
      subs = me.subs;
      cids = me.cids;
    }

  function getUser(address addr) public view returns(
    uint256 balance,
    address[] subs,
    uint256[] cids,
    uint256[] bns,
    uint256[] scs,
    uint256[] sns,
    uint8[] ts,
    bool[] os
  ){
      User memory me = userList[addr];
      balance = me.balance;
      subs = me.subs;
      cids = me.cids;
      uint256 len = cids.length;
      if(len==0) return ;
      bns = new uint256[](len);
      scs = new uint256[](len);
      sns = new uint256[](len);
      ts = new uint8[](len);
      os = new bool[](len);
      for(uint256 i=0;i<len;i++){
          Card memory c = cardList[cids[i]];
          bns[i] = c.blockNumber;
          scs[i] = c.signCount;
          sns[i] = c.sn;
          ts[i] = c.typeId;
          os[i] = c.isOut;
      }
  }
}