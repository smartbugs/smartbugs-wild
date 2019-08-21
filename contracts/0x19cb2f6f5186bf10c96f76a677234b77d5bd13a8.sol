pragma solidity ^0.4.24;


contract Game{
  using ShareCalc for uint256;
  using SafeMath for *;
  uint256 constant private weight0 = 1;
  uint256 constant private weight1 = 1;  
  uint256 constant private refcodeFee = 1e16;
  uint256 constant private phasePerStage = 4;
  uint256 constant private maxStage = 10;
  Entrepreneur.Company public gameState;  
  mapping (bytes32 => address) public refcode2Addr;

  mapping (address => Entrepreneur.Player) public players;    
  address foundationAddr = 0x52E9e51e2519e9D8e5D68D992958e7D1bD4e5899;
  uint256 constant private phaseLen  = 11 hours;
  uint256 constant private growthTarget    = 110; 
  uint256 constant private lockup = 2 ;
  uint256 constant private sweepDelay = 30 days;
  Entrepreneur.Allocation rate = Entrepreneur.Allocation(50,9,3,2,6,30);
  mapping (uint256 => Entrepreneur.Phase) public phases;
  mapping (uint256 => mapping (address => uint256)) public phase_player_origShare; 
  mapping (uint256 =>mapping (uint256 => mapping (address => uint256))) public stage_prod_player_origShare;
  mapping (uint256 =>mapping (uint256 => mapping (address => uint256))) public stage_prod_player_cdps;
  mapping (uint256 =>mapping (uint256 => mapping (address => uint256))) public stage_prod_player_cbps;
  mapping (uint256 =>mapping (uint256 =>  uint256)) public phase_prod_Share;
  mapping (uint256 =>mapping (uint256 =>  uint256)) public stage_prod_currShare;
  mapping (uint256 =>mapping (uint256 =>  uint256)) public stage_prod_origShare;
  mapping (uint256 =>mapping (uint256 =>  uint256)) public stage_prod_cdps;
  mapping (uint256 =>mapping (uint256 =>  uint256)) public stage_prod_cbps;
  mapping (address =>mapping (uint256=>  bytes32)) public player_id_refCode;
  modifier isHuman() { 
    require(msg.sender == tx.origin, "Humans only");
    _;
  }
  modifier ethLimit(uint256 _eth) { 
    require(_eth >= 1e16, "0.01ETH min");
    require(_eth <= 1e20, "100ETH max");
    _;    
  }
  constructor () public {
    gameState.stage=1;
    gameState.phase=1;
    phases[gameState.phase].ethGoal=10*1e18;
    phases[gameState.phase].shareGoal=(gameState.eth).sharesRec(phases[gameState.phase].ethGoal);            
    phases[gameState.phase].stage=1;    
  }
  string public gameName = "Entrepreneur";
  function checkRefcode(address playerAddr,uint256 id)
    public 
    view
    returns(bytes32)
  {
    return player_id_refCode[playerAddr][id];
  }
  function accruedDiv (address playerAddr)
    public 
    view 
    returns (uint256)
  {
    uint256 div=0;
    for(uint i=1;i<=gameState.stage;i++){
      for(uint j=0;j<2;j++){
        div=(stage_prod_cdps[i][j].sub(stage_prod_player_cdps[i][j][playerAddr]).mul(stage_prod_player_origShare[i][j][playerAddr])/1e18).add(div);        
      }
    }
    return div;
  }
  function accruedBuyout (address playerAddr)
    public
    view 
    returns (uint256)
  {
    if(gameState.stage<=lockup)
      return 0;
    uint256 buyoutEth=0;
      for(uint i=1;i<=gameState.stage.sub(lockup);i++){
        buyoutEth=buyoutEth.add((stage_prod_cbps[i][0].sub(stage_prod_player_cbps[i][0][playerAddr])).mul(stage_prod_player_origShare[i][0][playerAddr])/1e18);        
      }
    return buyoutEth;
  }
  function potShare(address playerAddr)
    private
    view
    returns (uint256)
  {
    uint256 weightedShare=phase_player_origShare[gameState.phase][playerAddr].mul(weight0);
    if(gameState.phase>1){
      weightedShare=weightedShare.add(phase_player_origShare[gameState.phase-1][playerAddr].mul(weight1));                  
    }
    return weightedShare;        
  }
  function accruedLiq(address playerAddr) 
    private 
    view 
    returns (uint256)
  {
    if(gameState.ended>0 && !players[playerAddr].redeemed )
    {                                          
      return (gameState.lps).mul(potShare(playerAddr))/1e18;      
    }      
    return 0;
  }
  function currShares(address playerAddr)
    private
    view
    returns(uint256)
  {
    uint256 _shares;
    for(uint i=1;i<=gameState.stage;i++){
      for(uint j=0;j<2;j++){
        if(stage_prod_origShare[i][j]>0)
          _shares=_shares.add(stage_prod_player_origShare[i][j][playerAddr].mul(stage_prod_currShare[i][j])/stage_prod_origShare[i][j]);        
      }
    }
    return _shares;
  }
  function getState() 
    public 
    view 
    returns (
      uint256,
      uint256,
      uint256,
      uint256,
      uint256,
      uint256,
      uint256,
      uint256,
      uint256,
      uint256
    )
  {
    uint256 phase=gameState.phase;
    uint256 end;
    uint256 ethGoal;
    uint256 eth;  
    uint256 stage=gameState.stage;
    if(phases[phase].end!=0 && now > phases[phase].end && phases[phase].shares>=phases[phase].shareGoal && gameState.ended==0){
      end=phases[phase].end.add(phaseLen);      
      ethGoal=phases[phase].eth.mul(growthTarget)/100;
      phase++;
      stage=(phase-1)/phasePerStage+1;                  
    }else{
      end=phases[phase].end;
      ethGoal=phases[phase].ethGoal;
      eth=phases[phase].eth;
    }
    return (
      gameState.pot, 
      gameState.origShares,
      gameState.plyrCount,
      phase,
      end,
      ethGoal,
      eth,
      stage,
      gameState.eth,
      gameState.currShares
      );    
  }
  // function getState2() 
  //   public 
  //   view 
  //   returns (
  //     uint256 pot,
  //     uint256 origShares,
  //     uint256 plyrCount,
  //     uint256 phase,
  //     uint256 end,
  //     uint256 phaseEthGoal,
  //     uint256 phaseEth,
  //     uint256 stage,
  //     uint256 totalEth,
  //     uint256 totalCurrShares
  //   )
  // {
  //   phase=gameState.phase;            
  //   stage=gameState.stage;
  //   if(phases[phase].end!=0 && now > phases[phase].end && phases[phase].shares>=phases[phase].shareGoal && gameState.ended==0){
  //     end=phases[phase].end.add(phaseLen);      
  //     phaseEthGoal=phases[phase].eth.mul(growthTarget)/100;
  //     phase++;
  //     stage=(phase-1)/phasePerStage+1;                  
  //   }else{
  //     end=phases[phase].end;
  //     phaseEthGoal=phases[phase].ethGoal;
  //     phaseEth=phases[phase].eth;
  //   }
  //   pot=gameState.pot;
  //   origShares=gameState.origShares;
  //   plyrCount=gameState.plyrCount;
  //   totalEth=gameState.eth;
  //   totalCurrShares=gameState.currShares;
  //   return (
  //     pot, 
  //     origShares,
  //     plyrCount,
  //     phase,
  //     end,
  //     phaseEthGoal,
  //     phaseEth,
  //     stage,
  //     totalEth,
  //     totalCurrShares
  //     );    
  // }
  function phaseAddtlInfo(uint256 phase)
    public 
    view
    returns(      
      uint256,
      uint256,
      uint256,
      uint256
    )
  { 
    uint256 growth;
    if(phase==1)
      growth=0;
    else
      growth=phases[phase].eth.mul(10000)/phases[phase.sub(1)].eth;
    uint256 stage;    
    uint256 ethGoal;          
    if(phase == gameState.phase + 1 && phases[gameState.phase].end!=0 && phases[gameState.phase].shares>=phases[gameState.phase].shareGoal && now > phases[gameState.phase].end){
      stage=(phase-1)/phasePerStage+1;            
      ethGoal=phases[gameState.phase].eth.mul(growthTarget)/100;
    }else{
      stage=phases[phase].stage;      
      ethGoal=phases[phase].ethGoal;
    }
    return(
      stage,      
      phases[phase].eth,
      ethGoal,      
      growth
    );
  }
  function getPlayerIncome(address playerAddr) 
    public 
    view 
    returns (      
      uint256,
      uint256,
      uint256,
      uint256
      )
  {     
    return (     
      players[playerAddr].redeemedDiv.add(accruedDiv(playerAddr)),      
      players[playerAddr].redeemedRef,
      players[playerAddr].redeemedBuyout.add(accruedBuyout(playerAddr)),
      players[playerAddr].redeemedLiq.add(accruedLiq(playerAddr)));
  }
  
  function getPlayerVault(address playerAddr) 
    public 
    view 
    returns (            
      uint256,
      uint256,
      uint256,
      uint256
      )
  { 
    uint256 shares=currShares(playerAddr);
    return (            
      totalBal(playerAddr),
      shares,
      potShare(playerAddr),
      (gameState.origShares).ethRec(shares));
  }
  function totalBal(address playerAddr)
    public 
    view 
    returns(uint256)
  {
    uint256 div = accruedDiv(playerAddr);  
    uint256 liq = accruedLiq(playerAddr);
    uint256 buyout=accruedBuyout(playerAddr);
    return players[playerAddr].bal.add(div).add(liq).add(buyout);
  }

  function _register(address playerAddr,address ref) 
    private
  {
    if(players[playerAddr].id>0)
      return;
    if(players[ref].id==0 || ref==playerAddr)
      ref=address(0);
    players[playerAddr].id=++gameState.plyrCount;
    players[playerAddr].ref=ref;
    players[ref].apprentice1++;
    address ref2=players[ref].ref;
    if(ref2 != address(0)){
      players[ref2].apprentice2++;
      address ref3=players[ref2].ref;
      if(ref3 != address(0)){
        players[ref3].apprentice3++;
      }
    }    
  }
  function _register2(address playerAddr,bytes32 refcode)
    private
  {
    _register(playerAddr,refcode2Addr[refcode]);
  }

  function endGame() 
    private 
    returns (uint256)
  {
    if(gameState.ended>0){
      return gameState.ended;
    }      
    if(now > phases[gameState.phase].end){
      if(phases[gameState.phase].shares>=phases[gameState.phase].shareGoal)
      {
        uint256 nextPhase=gameState.phase+1;
        if(gameState.phase % phasePerStage == 0){          
          if(gameState.stage+1>maxStage){
            gameState.ended=2;            
          }else{
            gameState.stage++;            
          }
        }     
        if(gameState.ended==0){
          phases[nextPhase].stage=gameState.stage;
          phases[nextPhase].end=phases[gameState.phase].end.add(phaseLen);      
          phases[nextPhase].ethGoal=phases[gameState.phase].eth.mul(growthTarget)/100;
          phases[nextPhase].shareGoal=(gameState.eth).sharesRec(phases[nextPhase].ethGoal);
          gameState.phase=nextPhase;        
          if(now > phases[gameState.phase].end){
            gameState.ended=1;
          }                
        }        
      }else{
        gameState.ended=1;                
      }      
    }
    if(gameState.ended>0){
      uint256 weightedShare=phases[gameState.phase].shares.mul(weight0);
      if(gameState.phase>1){
        weightedShare=weightedShare.add(phases[gameState.phase-1].shares.mul(weight1));                        
      }        
      gameState.lps=(gameState.pot).mul(1e18)/weightedShare;
      gameState.pot=0;
    }
    return gameState.ended;      
  }
  function calcBuyout(uint256 shares) 
    public
    view
    returns(uint256)
  { 
    if(gameState.stage<=lockup)
      return 0;
    uint256 buyoutShares;

    if(phases[gameState.phase].shares.add(shares)>phases[gameState.phase].shareGoal){
      buyoutShares=phases[gameState.phase].shares.add(shares).sub(phases[gameState.phase].shareGoal);
    }
    if(buyoutShares>shares){
      buyoutShares=shares;
    }
    if(buyoutShares > stage_prod_currShare[gameState.stage.sub(lockup)][0]){
      buyoutShares= stage_prod_currShare[gameState.stage.sub(lockup)][0];
    }
    return buyoutShares;
  }
  function minRedeem(address playerAddr,uint256 stage,uint256 prodId)
    public
  {     
    uint256 div= (stage_prod_cdps[stage][prodId].sub(stage_prod_player_cdps[stage][prodId][playerAddr])).mul(stage_prod_player_origShare[stage][prodId][playerAddr])/1e18;      
    stage_prod_player_cdps[stage][prodId][playerAddr]=stage_prod_cdps[stage][prodId];
    players[playerAddr].bal=div.add(players[playerAddr].bal);
    players[playerAddr].redeemedDiv=div.add(players[playerAddr].redeemedDiv);    
  }
  function redeem(address playerAddr) 
    public
  {
    uint256 liq=0;
    if(gameState.ended>0 && !players[playerAddr].redeemed){
      liq=accruedLiq(playerAddr);      
      players[playerAddr].redeemed=true;
    }

    uint256 div=0;
    for(uint i=1;i<=gameState.stage;i++){
      for(uint j=0;j<2;j++){
        div=div.add((stage_prod_cdps[i][j].sub(stage_prod_player_cdps[i][j][playerAddr])).mul(stage_prod_player_origShare[i][j][playerAddr])/1e18);
        stage_prod_player_cdps[i][j][playerAddr]=stage_prod_cdps[i][j];
      }
    }      
    
    uint256 buyoutEth=0;
    if(gameState.stage>lockup){
      for(i=1;i<=gameState.stage.sub(lockup);i++){
        buyoutEth=buyoutEth.add((stage_prod_cbps[i][0].sub(stage_prod_player_cbps[i][0][playerAddr])).mul(stage_prod_player_origShare[i][0][playerAddr])/1e18);
        stage_prod_player_cbps[i][0][playerAddr]=stage_prod_cbps[i][0];
      }
    }    
    players[playerAddr].bal=liq.add(div).add(buyoutEth).add(players[playerAddr].bal);
    players[playerAddr].redeemedLiq=players[playerAddr].redeemedLiq.add(liq);
    players[playerAddr].redeemedDiv=players[playerAddr].redeemedDiv.add(div);
    players[playerAddr].redeemedBuyout=players[playerAddr].redeemedBuyout.add(buyoutEth);
  }    
  
  function payRef(address playerAddr,uint256 eth) 
    private
  {
    uint256 foundationAmt=eth.mul(rate.foundation)/100;
    uint256 ref1Amt=eth.mul(rate.ref1)/100;
    uint256 ref2Amt=eth.mul(rate.ref2)/100;
    uint256 ref3Amt=eth.mul(rate.ref3)/100;
    address ref1= players[playerAddr].ref;
    if(ref1 != address(0)){
      players[ref1].bal=ref1Amt.add(players[ref1].bal);
      players[ref1].redeemedRef=ref1Amt.add(players[ref1].redeemedRef);
      address ref2=players[ref1].ref;
      if(ref2 != address(0)){
        players[ref2].bal=ref2Amt.add(players[ref2].bal);
        players[ref2].redeemedRef=ref2Amt.add(players[ref2].redeemedRef);
        address ref3=players[ref2].ref;
        if(ref3 != address(0)){
          players[ref3].bal=ref3Amt.add(players[ref3].bal);
          players[ref3].redeemedRef=ref3Amt.add(players[ref3].redeemedRef);
        }else{
          foundationAmt=foundationAmt.add(ref3Amt);    
        }        
      }else{
        foundationAmt=foundationAmt.add(ref3Amt).add(ref2Amt);    
      }        
    }else{
      foundationAmt=foundationAmt.add(ref3Amt).add(ref2Amt).add(ref1Amt);    
    }            
    foundationAddr.transfer(foundationAmt);  
  }
  function updateDps(uint256 div) 
    private
  {
    uint256 dps=div.mul(1e18)/gameState.currShares;  
    for(uint i = 1; i <= gameState.stage; i++){
      for(uint j=0;j<=1;j++){
        if(stage_prod_origShare[i][j]>0){
          stage_prod_cdps[i][j]=(dps.mul(stage_prod_currShare[i][j])/stage_prod_origShare[i][j]).add(stage_prod_cdps[i][j]);     
        }        
      }
    }    
  }  
  function _buy(address playerAddr, uint256 eth, uint256 prodId) 
    ethLimit(eth)
    private      
  {
    if(prodId>1)
      prodId=1;
    if(players[playerAddr].id==0)
      _register(playerAddr,address(0));      
    minRedeem(playerAddr,gameState.stage,prodId);
    require(players[playerAddr].bal >= eth,"insufficient fund");        
    if(eth>0 && phases[gameState.phase].end==0)
      phases[gameState.phase].end=now.add(phaseLen);
    if(endGame()>0)
      return;
    uint256 stage=gameState.stage;
    uint256 phase=gameState.phase;
    players[playerAddr].bal=(players[playerAddr].bal).sub(eth);    
    uint256 shares=(gameState.eth).sharesRec(eth);
    uint256 buyout = calcBuyout(shares);            
    uint256 newShare=shares.sub(buyout);    
    uint256 newShareEth=(gameState.origShares).ethRec(newShare);
    uint256 buyoutEth=eth.sub(newShareEth);    
    if(buyout>0){
      uint256 buyoutStage=stage.sub(lockup);
      stage_prod_currShare[buyoutStage][0]=stage_prod_currShare[buyoutStage][0].sub(buyout);                  
      stage_prod_cbps[buyoutStage][0]=(stage_prod_cbps[buyoutStage][0]).add(buyoutEth.mul(rate.pot).mul(1e18)/100/stage_prod_origShare[buyoutStage][0]);
    }    
        
    gameState.origShares = shares.add(gameState.origShares);
    gameState.currShares=newShare.add(gameState.currShares);
    gameState.eth = eth.add(gameState.eth);
    phases[phase].shares=shares.add(phases[phase].shares);    
    phases[phase].eth=eth.add(phases[phase].eth);    
    stage_prod_origShare[stage][prodId]=shares.add(stage_prod_origShare[stage][prodId]);
    stage_prod_currShare[stage][prodId]=stage_prod_origShare[stage][prodId];
    
    players[playerAddr].origShares=shares.add(players[playerAddr].origShares);
    stage_prod_player_origShare[stage][prodId][playerAddr]=shares.add(stage_prod_player_origShare[stage][prodId][playerAddr]);
    phase_player_origShare[phase][playerAddr]=shares.add(phase_player_origShare[phase][playerAddr]);
    
    updateDps(eth.mul(rate.div)/100);            
    payRef(playerAddr,eth);    
    gameState.pot=gameState.pot.add(newShareEth.mul(rate.pot)/100);        
  }
  function sweep()
    public
  {
    if(gameState.ended>0 && now > sweepDelay + phases[gameState.phase].end)
      foundationAddr.transfer(address(this).balance);
  }

  function register(address ref)
    isHuman()
    public
  {
    _register(msg.sender,ref);
  }

  function recharge()    
    public 
    payable
  {
    players[msg.sender].bal=(players[msg.sender].bal).add(msg.value);
  }

  function withdraw() 
    isHuman()
    public 
  {
    redeem(msg.sender);
    uint256 _bal = players[msg.sender].bal;            
    players[msg.sender].bal=0;    
    msg.sender.transfer(_bal);
  }
  function buyFromWallet(uint256 prodId,bytes32 refCode) 
    isHuman()    
    public 
    payable
  {
    _register2(msg.sender, refCode);
    players[msg.sender].bal=(players[msg.sender].bal).add(msg.value);        
    _buy(msg.sender,msg.value,prodId);
  }

  function regRefcode(bytes32 refcode)
    public 
    payable
    returns (bool)
  {
    _register2(msg.sender, "");
    if(msg.value<refcodeFee || refcode2Addr[refcode]!=address(0)){
      msg.sender.transfer(msg.value);
      return false;
    }
    refcode2Addr[refcode]=msg.sender;
    
    players[msg.sender].numRefcodes=players[msg.sender].numRefcodes.add(1);
    player_id_refCode[msg.sender][players[msg.sender].numRefcodes]=refcode;
    return true;  
  }

  function buyFromBal(uint256 eth,uint256 prodId,bytes32 refCode)    
    isHuman()
    public
  {
    _register2(msg.sender, refCode);
    redeem(msg.sender);
    _buy(msg.sender,eth,prodId);
  }

  function getEthNeeded(uint256 keysCount) public view returns(uint256) {
    uint256 ethCount=(gameState.origShares).ethRec(keysCount);

    return ethCount;
  }
}

library Entrepreneur {
  struct Player {    
    uint256 origShares;       
    uint256 bal;    
    bool redeemed;
    uint256 id;
    address ref;
    uint256 redeemedDiv;    
    uint256 redeemedRef;
    uint256 redeemedBuyout;
    uint256 redeemedLiq;
    uint256 apprentice1;
    uint256 apprentice2;
    uint256 apprentice3;
    uint256 numRefcodes;
  }
    
  struct Company {    
    uint256 eth;    
    uint256 pot;    
    uint256 origShares;
    uint256 currShares;
    uint256 lps;
    uint256 ended;
    uint256 plyrCount;
    uint256 phase;
    uint256 stage;  
  }  

  struct Phase{ 
    uint256 stage;
    uint256 end; 
    uint256 shareGoal; 
    uint256 shares; 
    uint256 eth;
    uint256 ethGoal;    
  }

  struct Allocation {
    uint256 div;  
    uint256 ref1;
    uint256 ref2;
    uint256 ref3;
    uint256 foundation;   
    uint256 pot;    
  }  
}

library ShareCalc {
  using SafeMath for *;
  /**
    * @dev calculates number of share received given X eth 
    * @param _curEth current amount of eth in contract 
    * @param _newEth eth being spent
    * @return amount of Share purchased
    */
  function sharesRec(uint256 _curEth, uint256 _newEth)
      internal
      pure
      returns (uint256)
  {
    return(shares((_curEth).add(_newEth)).sub(shares(_curEth)));
  }
  
  /**
    * @dev calculates amount of eth received if you sold X share 
    * @param _curShares current amount of shares that exist 
    * @param _sellShares amount of shares you wish to sell
    * @return amount of eth received
    */
  function ethRec(uint256 _curShares, uint256 _sellShares)
      internal
      pure
      returns (uint256)
  {
    return(eth(_curShares.add(_sellShares)).sub(eth(_curShares)));
  }

  /**
    * @dev calculates how many shares would exist with given an amount of eth
    * @param _eth eth "in contract"
    * @return number of shares that would exist
    */
  function shares(uint256 _eth) 
      internal
      pure
      returns(uint256)
  {
    // old
    // return ((((((_eth).mul(1000000000000000000)).mul(46675600000000000000000000)).add(49018761795600000000000000000000000000000000000000000000000000)).sqrt()).sub(7001340000000000000000000000000)) / (23337800);
    // new
    return ((((((_eth).mul(1000000000000000000)).mul(466756000000000000000000)).add(49018761795600000000000000000000000000000000000000000000000000)).sqrt()).sub(7001340000000000000000000000000)) / (233378);
  }
  
  /**
    * @dev calculates how much eth would be in contract given a number of shares
    * @param _shares number of shares "in contract" 
    * @return eth that would exists
    */
  function eth(uint256 _shares) 
      internal
      pure
      returns(uint256)  
  {
    // old
    // return ((11668900).mul(_shares.sq()).add(((14002680000000).mul(_shares.mul(1000000000000000000))) / (2))) / ((1000000000000000000).sq());
    // new
    return ((116689).mul(_shares.sq()).add(((14002680000000).mul(_shares.mul(1000000000000000000))) / (2))) / ((1000000000000000000).sq());
  }
}

library SafeMath {
    
  /**
  * @dev Multiplies two numbers, throws on overflow.
  */
  function mul(uint256 a, uint256 b) 
      internal 
      pure 
      returns (uint256 c) 
  {
    if (a == 0) {
      return 0;
    }
    c = a * b;
    require(c / a == b, "SafeMath mul failed");
    return c;
  }

  /**
  * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
  */
  function sub(uint256 a, uint256 b)
      internal
      pure
      returns (uint256) 
  {
    require(b <= a, "SafeMath sub failed");
    return a - b;
  }

  /**
  * @dev Adds two numbers, throws on overflow.
  */
  function add(uint256 a, uint256 b)
      internal
      pure
      returns (uint256 c) 
  {
    c = a + b;
    require(c >= a, "SafeMath add failed");
    return c;
  }
  
  /**
    * @dev gives square root of given x.
    */
  function sqrt(uint256 x)
      internal
      pure
      returns (uint256 y) 
  {
    uint256 z = ((add(x,1)) / 2);
    y = x;
    while (z < y) 
    {
      y = z;
      z = ((add((x / z),z)) / 2);
    }
  }
  
  /**
    * @dev gives square. multiplies x by x
    */
  function sq(uint256 x)
      internal
      pure
      returns (uint256)
  {
    return (mul(x,x));
  }
  
  /**
    * @dev x to the power of y 
    */
  function pwr(uint256 x, uint256 y)
      internal 
      pure 
      returns (uint256)
  {
    if (x==0)
        return (0);
    else if (y==0)
        return (1);
    else 
    {
      uint256 z = x;
      for (uint256 i = 1; i < y; i++)
        z = mul(z,x);
      return (z);
    }
  }
}