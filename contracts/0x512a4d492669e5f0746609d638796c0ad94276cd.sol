/* ==================================================================== */
/* Copyright (c) 2018 The CryptoRacing Project.  All rights reserved.
/* 
/*   The first idle car race game of blockchain                 
/* ==================================================================== */
pragma solidity ^0.4.20;

interface ERC20 {
    function totalSupply() public view returns (uint);
    function balanceOf(address tokenOwner) public view returns (uint balance);
    function allowance(address tokenOwner, address spender) public view returns (uint remaining);
    function transfer(address to, uint tokens) public returns (bool success);
    function approve(address spender, uint tokens) public returns (bool success);
    function transferFrom(address from, address to, uint tokens) public returns (bool success);

    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
}

// RaceCoin - Crypto Idle Raceing Game
// https://cryptoracing.online


contract AccessAdmin {
    bool public isPaused = false;
    address public addrAdmin;  

    event AdminTransferred(address indexed preAdmin, address indexed newAdmin);

    function AccessAdmin() public {
        addrAdmin = msg.sender;
    }  


    modifier onlyAdmin() {
        require(msg.sender == addrAdmin);
        _;
    }

    modifier whenNotPaused() {
        require(!isPaused);
        _;
    }

    modifier whenPaused {
        require(isPaused);
        _;
    }

    function setAdmin(address _newAdmin) external onlyAdmin {
        require(_newAdmin != address(0));
        emit AdminTransferred(addrAdmin, _newAdmin);
        addrAdmin = _newAdmin;
    }

    function doPause() external onlyAdmin whenNotPaused {
        isPaused = true;
    }

    function doUnpause() external onlyAdmin whenPaused {
        isPaused = false;
    }
}


interface IRaceCoin {
    function addTotalEtherPool(uint256 amount) external;
    function addPlayerToList(address player) external;
    function increasePlayersAttribute(address player, uint16[13] param) external;
    function reducePlayersAttribute(address player, uint16[13] param) external;
}

contract RaceCoin is ERC20, AccessAdmin, IRaceCoin {

    using SafeMath for uint256;

    string public constant name  = "Race Coin";
    string public constant symbol = "Coin";
    uint8 public constant decimals = 0;
    uint256 private roughSupply;
    uint256 public totalRaceCoinProduction;
   
    //Daily match fun dividend ratio
    uint256 public bonusMatchFunPercent = 10;

    //Daily off-line dividend ratio
    uint256 public bonusOffLinePercent = 10;

    //Recommendation ratio
    uint256 constant refererPercent = 5;

    

    address[] public playerList;
    //Verifying whether duplication is repeated
   // mapping(address => uint256) public isProduction;


    uint256 public totalEtherPool; // Eth dividends to be split between players' race coin production
    uint256[] private totalRaceCoinProductionSnapshots; // The total race coin production for each prior day past
    uint256[] private allocatedProductionSnapshots; // The amount of EHT that can be allocated daily
    uint256[] private allocatedRaceCoinSnapshots; // The amount of EHT that can be allocated daily
    uint256[] private totalRaceCoinSnapshots; // The total race coin for each prior day past
    uint256 public nextSnapshotTime;



    // Balances for each player
    mapping(address => uint256) private ethBalance;
    mapping(address => uint256) private raceCoinBalance;
    mapping(address => uint256) private refererDivsBalance;

    mapping(address => uint256) private productionBaseValue; //Player production base value
    mapping(address => uint256) private productionMultiplier; //Player production multiplier

    mapping(address => uint256) private attackBaseValue; //Player attack base value
    mapping(address => uint256) private attackMultiplier; //Player attack multiplier
    mapping(address => uint256) private attackPower; //Player attack Power

    mapping(address => uint256) private defendBaseValue; //Player defend base value
    mapping(address => uint256) private defendMultiplier; //Player defend multiplier
    mapping(address => uint256) private defendPower; //Player defend Power

    mapping(address => uint256) private plunderBaseValue; //Player plunder base value
    mapping(address => uint256) private plunderMultiplier; //Player plunder multiplier
    mapping(address => uint256) private plunderPower; //Player plunder Power




    mapping(address => mapping(uint256 => uint256)) private raceCoinProductionSnapshots; // Store player's race coin production for given day (snapshot)
    mapping(address => mapping(uint256 => bool)) private raceCoinProductionZeroedSnapshots; // This isn't great but we need know difference between 0 production and an unused/inactive day.
    mapping(address => mapping(uint256 => uint256)) private raceCoinSnapshots;// Store player's race coin for given day (snapshot)



    mapping(address => uint256) private lastRaceCoinSaveTime; // Seconds (last time player claimed their produced race coin)
    mapping(address => uint256) public lastRaceCoinProductionUpdate; // Days (last snapshot player updated their production)
    mapping(address => uint256) private lastProductionFundClaim; // Days (snapshot number)
    mapping(address => uint256) private lastRaceCoinFundClaim; // Days (snapshot number)
    mapping(address => uint256) private battleCooldown; // If user attacks they cannot attack again for short time


    // Computational correlation


    // Mapping of approved ERC20 transfers (by player)
    mapping(address => mapping(address => uint256)) private allowed;


    event ReferalGain(address referal, address player, uint256 amount);
    event PlayerAttacked(address attacker, address target, bool success, uint256 raceCoinPlunder);


     /// @dev Trust contract
    mapping (address => bool) actionContracts;

    function setActionContract(address _actionAddr, bool _useful) external onlyAdmin {
        actionContracts[_actionAddr] = _useful;
    }

    function getActionContract(address _actionAddr) external view onlyAdmin returns(bool) {
        return actionContracts[_actionAddr];
    }
    
   


    function RaceCoin() public {
        addrAdmin = msg.sender;
        totalRaceCoinSnapshots.push(0);
    }
    

    function() external payable {

    }


    function beginGame(uint256 firstDivsTime) external onlyAdmin {
        nextSnapshotTime = firstDivsTime;  
    }


     // We will adjust to achieve a balance.
    function adjustDailyMatchFunDividends(uint256 newBonusPercent) external onlyAdmin whenNotPaused {

        require(newBonusPercent > 0 && newBonusPercent <= 80);
       
        bonusMatchFunPercent = newBonusPercent;

    }

     // We will adjust to achieve a balance.
    function adjustDailyOffLineDividends(uint256 newBonusPercent) external onlyAdmin whenNotPaused {

        require(newBonusPercent > 0 && newBonusPercent <= 80);
       
        bonusOffLinePercent = newBonusPercent;

    }

    // Stored race coin (rough supply as it ignores earned/unclaimed RaceCoin)
    function totalSupply() public view returns(uint256) {
        return roughSupply; 
    }


    function balanceOf(address player) public view returns(uint256) {
        return raceCoinBalance[player] + balanceOfUnclaimedRaceCoin(player);
    }

    function raceCionBalance(address player) public view returns(uint256) {
        return raceCoinBalance[player];
    }


    function balanceOfUnclaimedRaceCoin(address player) internal view returns (uint256) {
        uint256 lastSave = lastRaceCoinSaveTime[player];
        if (lastSave > 0 && lastSave < block.timestamp) {
            return (getRaceCoinProduction(player) * (block.timestamp - lastSave)) / 100;
        }
        return 0;
    }


    function getRaceCoinProduction(address player) public view returns (uint256){
        return raceCoinProductionSnapshots[player][lastRaceCoinProductionUpdate[player]];
    }


    function etherBalanceOf(address player) public view returns(uint256) {
        return ethBalance[player];
    }


    function transfer(address recipient, uint256 amount) public returns (bool) {
        updatePlayersRaceCoin(msg.sender);
        require(amount <= raceCoinBalance[msg.sender]);
        
        raceCoinBalance[msg.sender] -= amount;
        raceCoinBalance[recipient] += amount;
        
        emit Transfer(msg.sender, recipient, amount);
        return true;
    }

    function transferFrom(address player, address recipient, uint256 amount) public returns (bool) {
        updatePlayersRaceCoin(player);
        require(amount <= allowed[player][msg.sender] && amount <= raceCoinBalance[player]);
        
        raceCoinBalance[player] -= amount;
        raceCoinBalance[recipient] += amount;
        allowed[player][msg.sender] -= amount;
        
        emit Transfer(player, recipient, amount);
        return true;
    }


    function approve(address approvee, uint256 amount) public returns (bool){
        allowed[msg.sender][approvee] = amount;
        emit Approval(msg.sender, approvee, amount);
        return true;
    }

    function allowance(address player, address approvee) public view returns(uint256){
        return allowed[player][approvee];
    }


    function addPlayerToList(address player) external{
        
        require(actionContracts[msg.sender]);
        require(player != address(0));

        bool b = false;

        //Judge whether or not to repeat
        for (uint256 i = 0; i < playerList.length; i++) {
            if(playerList[i] == player){
               b = true;
               break;
            }
        } 

        if(!b){
            playerList.push(player);
        }   
    }


    function getPlayerList() external view returns ( address[] ){
        return playerList;
    }





    function updatePlayersRaceCoin(address player) internal {
        uint256 raceCoinGain = balanceOfUnclaimedRaceCoin(player);
        lastRaceCoinSaveTime[player] = block.timestamp;
        roughSupply += raceCoinGain;
        raceCoinBalance[player] += raceCoinGain;
    }

    //Increase attribute
    function increasePlayersAttribute(address player, uint16[13] param) external{


        require(actionContracts[msg.sender]);
        require(player != address(0));


        //Production
        updatePlayersRaceCoin(player);
        uint256 increase;
        uint256 newProduction;
        uint256 previousProduction;

        previousProduction = getRaceCoinProduction(player);

        productionBaseValue[player] = productionBaseValue[player].add(param[3]);
        productionMultiplier[player] = productionMultiplier[player].add(param[7]);

        newProduction = productionBaseValue[player].mul(100 + productionMultiplier[player]).div(100);

        increase = newProduction.sub(previousProduction);

        raceCoinProductionSnapshots[player][allocatedProductionSnapshots.length] = newProduction;
        lastRaceCoinProductionUpdate[player] = allocatedProductionSnapshots.length;
        totalRaceCoinProduction += increase;




        //Attack
        attackBaseValue[player] = attackBaseValue[player].add(param[4]);
        attackMultiplier[player] = attackMultiplier[player].add(param[8]);
        attackPower[player] = attackBaseValue[player].mul(100 + attackMultiplier[player]).div(100);


        //Defend
        defendBaseValue[player] = defendBaseValue[player].add(param[5]);
        defendMultiplier[player] = defendMultiplier[player].add(param[9]);
        defendPower[player] = defendBaseValue[player].mul(100 + defendMultiplier[player]).div(100);


        //Plunder
        plunderBaseValue[player] = plunderBaseValue[player].add(param[6]);
        plunderMultiplier[player] = plunderMultiplier[player].add(param[10]);

        plunderPower[player] = plunderBaseValue[player].mul(100 + plunderMultiplier[player]).div(100);


    }


    //Reduce attribute
    function reducePlayersAttribute(address player, uint16[13] param) external{

        require(actionContracts[msg.sender]);
        require(player != address(0));


        //Production
        updatePlayersRaceCoin(player);


        uint256 decrease;
        uint256 newProduction;
        uint256 previousProduction;


        previousProduction = getRaceCoinProduction(player);

        productionBaseValue[player] = productionBaseValue[player].sub(param[3]);
        productionMultiplier[player] = productionMultiplier[player].sub(param[7]);

        newProduction = productionBaseValue[player].mul(100 + productionMultiplier[player]).div(100);

        decrease = previousProduction.sub(newProduction);
        
        if (newProduction == 0) { // Special case which tangles with "inactive day" snapshots (claiming divs)
            raceCoinProductionZeroedSnapshots[player][allocatedProductionSnapshots.length] = true;
            delete raceCoinProductionSnapshots[player][allocatedProductionSnapshots.length]; // 0
        } else {
            raceCoinProductionSnapshots[player][allocatedProductionSnapshots.length] = newProduction;
        }
        
        lastRaceCoinProductionUpdate[player] = allocatedProductionSnapshots.length;
        totalRaceCoinProduction -= decrease;




        //Attack
        attackBaseValue[player] = attackBaseValue[player].sub(param[4]);
        attackMultiplier[player] = attackMultiplier[player].sub(param[8]);
        attackPower[player] = attackBaseValue[player].mul(100 + attackMultiplier[player]).div(100);


        //Defend
        defendBaseValue[player] = defendBaseValue[player].sub(param[5]);
        defendMultiplier[player] = defendMultiplier[player].sub(param[9]);
        defendPower[player] = defendBaseValue[player].mul(100 + defendMultiplier[player]).div(100);


        //Plunder
        plunderBaseValue[player] = plunderBaseValue[player].sub(param[6]);
        plunderMultiplier[player] = plunderMultiplier[player].sub(param[10]);
        plunderPower[player] = plunderBaseValue[player].mul(100 + plunderMultiplier[player]).div(100);


    }


    function attackPlayer(address player,address target) external {
        require(battleCooldown[player] < block.timestamp);
        require(target != player);
        require(balanceOf(target) > 0);
        
        uint256 attackerAttackPower = attackPower[player];
        uint256 attackerplunderPower = plunderPower[player];
        uint256 defenderDefendPower = defendPower[target];
        

        if (battleCooldown[target] > block.timestamp) { // When on battle cooldown, the defense is reduced by 50%
            defenderDefendPower = defenderDefendPower.div(2);
        }
        
        if (attackerAttackPower > defenderDefendPower) {
            battleCooldown[player] = block.timestamp + 30 minutes;
            if (balanceOf(target) > attackerplunderPower) {
               
                uint256 unclaimedRaceCoin = balanceOfUnclaimedRaceCoin(target);
                if (attackerplunderPower > unclaimedRaceCoin) {
                    uint256 raceCoinDecrease = attackerplunderPower - unclaimedRaceCoin;
                    raceCoinBalance[target] -= raceCoinDecrease;
                    roughSupply -= raceCoinDecrease;
                } else {
                    uint256 raceCoinGain = unclaimedRaceCoin - attackerplunderPower;
                    raceCoinBalance[target] += raceCoinGain;
                    roughSupply += raceCoinGain;
                }
                raceCoinBalance[player] += attackerplunderPower;
                emit PlayerAttacked(player, target, true, attackerplunderPower);
            } else {
                emit PlayerAttacked(player, target, true, balanceOf(target));
                raceCoinBalance[player] += balanceOf(target);
                raceCoinBalance[target] = 0;
            }
            
            lastRaceCoinSaveTime[target] = block.timestamp;
        
           
        } else {
            battleCooldown[player] = block.timestamp + 10 minutes;
            emit PlayerAttacked(player, target, false, 0);
        }
    }



    function getPlayersBattleStats(address player) external view returns (uint256, uint256, uint256, uint256){

        return (attackPower[player], defendPower[player], plunderPower[player], battleCooldown[player]);
    }


    function getPlayersBaseAttributesInt(address player) external view returns (uint256, uint256, uint256, uint256){
        return (productionBaseValue[player], attackBaseValue[player], defendBaseValue[player], plunderBaseValue[player]); 
    }
    
    function getPlayersAttributesInt(address player) external view returns (uint256, uint256, uint256, uint256){
        return (getRaceCoinProduction(player), attackPower[player], defendPower[player], plunderPower[player]); 
    }


    function getPlayersAttributesMult(address player) external view returns (uint256, uint256, uint256, uint256){
        return (productionMultiplier[player], attackMultiplier[player], defendMultiplier[player], plunderMultiplier[player]);
    }
    

    function withdrawEther(uint256 amount) external {
        require(amount <= ethBalance[msg.sender]);
        ethBalance[msg.sender] -= amount;
        msg.sender.transfer(amount);
    }


    function getBalance() external view returns(uint256) {
        return totalEtherPool;
    }


    function addTotalEtherPool(uint256 amount) external{
        require(actionContracts[msg.sender]);
        require(amount > 0);
        totalEtherPool += amount;
    }

    function correctPool(uint256 _count) external onlyAdmin {
        require( _count > 0);
        totalEtherPool += _count;
    }


    // To display 
    function getGameInfo(address player) external view returns (uint256, uint256, uint256, uint256, uint256, uint256, uint256){
           
        return ( totalEtherPool, totalRaceCoinProduction,nextSnapshotTime, balanceOf(player), ethBalance[player], 
                    getRaceCoinProduction(player),raceCoinBalance[player]);
    }

    function getMatchFunInfo(address player) external view returns (uint256, uint256){
        return (raceCoinSnapshots[player][totalRaceCoinSnapshots.length - 1], 
        totalRaceCoinSnapshots[totalRaceCoinSnapshots.length - 1]);
    }


    function getGameCurrTime(address player) external view returns (uint256){
        return block.timestamp;
    }


    function claimOffLineDividends(address referer, uint256 startSnapshot, uint256 endSnapShot) external {
        require(startSnapshot <= endSnapShot);
        require(startSnapshot >= lastProductionFundClaim[msg.sender]);
        require(endSnapShot < allocatedProductionSnapshots.length);

        uint256 offLineShare;
        uint256 previousProduction = raceCoinProductionSnapshots[msg.sender][lastProductionFundClaim[msg.sender] - 1]; 
        for (uint256 i = startSnapshot; i <= endSnapShot; i++) {
            
            uint256 productionDuringSnapshot = raceCoinProductionSnapshots[msg.sender][i];
            bool soldAllProduction = raceCoinProductionZeroedSnapshots[msg.sender][i];
            if (productionDuringSnapshot == 0 && !soldAllProduction) {
                productionDuringSnapshot = previousProduction;
            } else {
               previousProduction = productionDuringSnapshot;
            }
            
            offLineShare += (allocatedProductionSnapshots[i] * productionDuringSnapshot) / totalRaceCoinProductionSnapshots[i];
        }
        
        
        if (raceCoinProductionSnapshots[msg.sender][endSnapShot] == 0 && !raceCoinProductionZeroedSnapshots[msg.sender][endSnapShot] && previousProduction > 0) {
            raceCoinProductionSnapshots[msg.sender][endSnapShot] = previousProduction; // Checkpoint for next claim
        }
        
        lastProductionFundClaim[msg.sender] = endSnapShot + 1;
        
       
        uint256 referalDivs;
        if (referer != address(0) && referer != msg.sender) {
            referalDivs = offLineShare.mul(refererPercent).div(100); // 5%
            ethBalance[referer] += referalDivs;
            refererDivsBalance[referer] += referalDivs;
            emit ReferalGain(referer, msg.sender, referalDivs);
        }


        
        ethBalance[msg.sender] += offLineShare - referalDivs;
    }


    // To display on website
    function viewOffLineDividends(address player) external view returns (uint256, uint256, uint256) {
        uint256 startSnapshot = lastProductionFundClaim[player];
        uint256 latestSnapshot = allocatedProductionSnapshots.length - 1; 
        
        uint256 offLineShare;
        uint256 previousProduction = raceCoinProductionSnapshots[player][lastProductionFundClaim[player] - 1];
        for (uint256 i = startSnapshot; i <= latestSnapshot; i++) {
            
            uint256 productionDuringSnapshot = raceCoinProductionSnapshots[player][i];
            bool soldAllProduction = raceCoinProductionZeroedSnapshots[player][i];
            if (productionDuringSnapshot == 0 && !soldAllProduction) {
                productionDuringSnapshot = previousProduction;
            } else {
               previousProduction = productionDuringSnapshot;
            }
            
            offLineShare += (allocatedProductionSnapshots[i] * productionDuringSnapshot) / totalRaceCoinProductionSnapshots[i];
        }
        return (offLineShare, startSnapshot, latestSnapshot);
    }

   



    function claimRaceCoinDividends(address referer, uint256 startSnapshot, uint256 endSnapShot) external {
        require(startSnapshot <= endSnapShot);
        require(startSnapshot >= lastRaceCoinFundClaim[msg.sender]);
        require(endSnapShot < allocatedRaceCoinSnapshots.length);
        
        uint256 dividendsShare;


        for (uint256 i = startSnapshot; i <= endSnapShot; i++) {

            dividendsShare += (allocatedRaceCoinSnapshots[i] * raceCoinSnapshots[msg.sender][i]) / (totalRaceCoinSnapshots[i] + 1);
        }

        
        lastRaceCoinFundClaim[msg.sender] = endSnapShot + 1;
        
        uint256 referalDivs;
        if (referer != address(0) && referer != msg.sender) {
            referalDivs = dividendsShare.mul(refererPercent).div(100); // 5%
            ethBalance[referer] += referalDivs;
            refererDivsBalance[referer] += referalDivs;
            emit ReferalGain(referer, msg.sender, referalDivs);
        }
        
        ethBalance[msg.sender] += dividendsShare - referalDivs;
    }

    // To display 
    function viewUnclaimedRaceCoinDividends(address player) external view returns (uint256, uint256, uint256) {
        uint256 startSnapshot = lastRaceCoinFundClaim[player];
        uint256 latestSnapshot = allocatedRaceCoinSnapshots.length - 1; // No snapshots to begin with
        
        uint256 dividendsShare;
        
        for (uint256 i = startSnapshot; i <= latestSnapshot; i++) {

            dividendsShare += (allocatedRaceCoinSnapshots[i] * raceCoinSnapshots[player][i]) / (totalRaceCoinSnapshots[i] + 1);
        }

        return (dividendsShare, startSnapshot, latestSnapshot);
    }


    function getRefererDivsBalance(address player)  external view returns (uint256){
        return refererDivsBalance[player];
    }


    function updatePlayersRaceCoinFromPurchase(address player, uint256 purchaseCost) internal {
        uint256 unclaimedRaceCoin = balanceOfUnclaimedRaceCoin(player);
        
        if (purchaseCost > unclaimedRaceCoin) {
            uint256 raceCoinDecrease = purchaseCost - unclaimedRaceCoin;
            require(raceCoinBalance[player] >= raceCoinDecrease);
            roughSupply -= raceCoinDecrease;
            raceCoinBalance[player] -= raceCoinDecrease;
        } else {
            uint256 raceCoinGain = unclaimedRaceCoin - purchaseCost;
            roughSupply += raceCoinGain;
            raceCoinBalance[player] += raceCoinGain;
        }
        
        lastRaceCoinSaveTime[player] = block.timestamp;
    }


    function fundRaceCoinDeposit(uint256 amount) external {
        updatePlayersRaceCoinFromPurchase(msg.sender, amount);
        raceCoinSnapshots[msg.sender][totalRaceCoinSnapshots.length - 1] += amount;
        totalRaceCoinSnapshots[totalRaceCoinSnapshots.length - 1] += amount;
    }



    // Allocate  divs for the day (00:00 cron job)
    function snapshotDailyRaceCoinFunding() external onlyAdmin whenNotPaused {
       
        uint256 todaysRaceCoinFund = (totalEtherPool * bonusMatchFunPercent) / 100; // 10% of pool daily
        uint256 todaysOffLineFund = (totalEtherPool * bonusOffLinePercent) / 100; // 10% of pool daily

        if(totalRaceCoinSnapshots[totalRaceCoinSnapshots.length - 1] > 0){
            totalEtherPool -= todaysRaceCoinFund;
        }

        totalEtherPool -= todaysOffLineFund;


        totalRaceCoinSnapshots.push(0);
        allocatedRaceCoinSnapshots.push(todaysRaceCoinFund);
        
        totalRaceCoinProductionSnapshots.push(totalRaceCoinProduction);
        allocatedProductionSnapshots.push(todaysOffLineFund);
        
        nextSnapshotTime = block.timestamp + 24 hours;
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