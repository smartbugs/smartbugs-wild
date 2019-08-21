pragma solidity ^0.4.25;

// ----------------------------------------------------------------------------
// Safe maths
// ----------------------------------------------------------------------------
library SafeMath {
    function add(uint a, uint b) internal pure returns (uint c) {
        c = a + b;
        require(c >= a);
    }
    function sub(uint a, uint b) internal pure returns (uint c) {
        require(b <= a);
        c = a - b;
    }
    function mul(uint a, uint b) internal pure returns (uint c) {
        c = a * b;
        require(a == 0 || c / a == b);
    }
    function div(uint a, uint b) internal pure returns (uint c) {
        require(b > 0);
        c = a / b;
    }
}

// ProfitLineInc contract
contract ProfitLineInc  {
    using SafeMath for uint;
    // set CEO and board of directors ownables
    mapping(uint256 => address)public management;// 0 CEO 1-5 Directors
    mapping(uint256 => uint256)public manVault;// Eth balance
    //mapping(uint256 => uint256)public spendableShares; // unused allocation
    mapping(uint256 => uint256)public price; // takeover price
    uint256 public totalSupplyShares; // in use totalsupply shares
    uint256 public ethPendingManagement;
    
    // Player setup
    mapping(address => uint256)public  bondsOutstanding; // redeemablebonds
    uint256 public totalSupplyBonds; //totalsupply of bonds outstanding
    mapping(address => uint256)public  playerVault; // in contract eth balance
    mapping(address => uint256)public  pendingFills; //eth to fill bonds
    mapping(address => uint256)public  playerId; 
    mapping(uint256 => address)public  IdToAdress; 
    uint256 public nextPlayerID;
    
    // autoReinvest
    mapping(address => bool) public allowAutoInvest;
    mapping(address => uint256) public percentageToReinvest;
    
    // Game vars
    uint256 ethPendingDistribution; // eth pending distribution
    
    // proffit line vars
    uint256 ethPendingLines; // eth ending distributionacross lines
    
        // line 1 -  proof of cheating the line
        mapping(uint256 => address) public cheatLine;
        mapping(address => bool) public isInLine;
        mapping(address => uint256) public lineNumber;
        uint256 public cheatLinePot;
        uint256 public nextInLine;
        uint256 public lastInLine;
        // line 2 -  proof of cheating the line Whale
        mapping(uint256 => address) public cheatLineWhale;
        mapping(address => bool) public isInLineWhale;
        mapping(address => uint256) public lineNumberWhale;
        uint256 public cheatLinePotWhale;
        uint256 public nextInLineWhale;
        uint256 public lastInLineWhale;
        // line 3 -  proof of arbitrage opportunity
        uint256 public arbitragePot;
        // line 4 - proof of risky arbitrage opportunity
        uint256 public arbitragePotRisky;
        // line 5 - proof of increasing odds
        mapping(address => uint256) public odds;
        uint256 public poioPot; 
        // line 6 - proof of increasing odds Whale
        mapping(address => uint256) public oddsWhale;
        uint256 public poioPotWhale;
        // line 7 - proof of increasing odds everybody
        uint256 public oddsAll;
        uint256 public poioPotAll;
        // line 8 - proof of decreasing odds everybody
        uint256 public decreasingOddsAll;
        uint256 public podoPotAll;
        // line 9 -  proof of distributing by random
        uint256 public randomPot;
        mapping(uint256 => address) public randomDistr;
        uint256 public randomNext;
        uint256 public lastdraw;
        // line 10 - proof of distributing by random whale
        uint256 public randomPotWhale;
        mapping(uint256 => address) public randomDistrWhale;
        uint256 public randomNextWhale;
        uint256 public lastdrawWhale;
        // line 11 - proof of distributing by everlasting random
        uint256 public randomPotAlways;
        mapping(uint256 => address) public randomDistrAlways;
        uint256 public randomNextAlways;
        uint256 public lastdrawAlways;
        // line 12 - Proof of eth rolls
        uint256 public dicerollpot;
        // line 13 - Proof of ridiculously bad odds
        uint256 public amountPlayed;
        uint256 public badOddsPot;
        
        // line 14 - Proof of playing Snip3d
        uint256 public Snip3dPot;

        // line 16 - Proof of playing Slaughter3d
        uint256 public Slaughter3dPot;
        
        // line 17 - Proof of eth rolls feeding bank
        uint256 public ethRollBank;
        // line 18 - Proof of eth stuck on PLinc
        uint256 public ethStuckOnPLinc;
        address public currentHelper;
        bool public canGetPaidForHelping;
        mapping(address => bool) public hassEthstuck;
        // line 19 - Proof of giving of eth
        uint256 public PLincGiverOfEth;
        // 
        
        // vaults
        uint256 public vaultSmall;
        uint256 public timeSmall;
        uint256 public vaultMedium;
        uint256 public timeMedium;
        uint256 public vaultLarge;
        uint256 public timeLarge;
        uint256 public vaultDrip; // delayed bonds maturing
        uint256 public timeDrip;
    
    // interfaces
    HourglassInterface constant P3Dcontract_ = HourglassInterface(0xB3775fB83F7D12A36E0475aBdD1FCA35c091efBe);//0xB3775fB83F7D12A36E0475aBdD1FCA35c091efBe);
    SPASMInterface constant SPASM_ = SPASMInterface(0xfaAe60F2CE6491886C9f7C9356bd92F688cA66a1);//0xfaAe60F2CE6491886C9f7C9356bd92F688cA66a1);
    Snip3DBridgeInterface constant snip3dBridge = Snip3DBridgeInterface(0x99352D1edfa7f124eC618dfb51014f6D54bAc4aE);//snip3d bridge
    Slaughter3DBridgeInterface constant slaughter3dbridge = Slaughter3DBridgeInterface(0x3E752fFD5eff7b7f2715eF43D8339ecABd0e65b9);//slaughter3dbridge
    
    // bonds div setup
    uint256 public pointMultiplier = 10e18;
    struct Account {
        uint256 balance;
        uint256 lastDividendPoints;
        }
    mapping(address=>Account) accounts;
    
   
    uint256 public totalDividendPoints;
    uint256 public unclaimedDividends;

    function dividendsOwing(address account) public view returns(uint256) {
        uint256 newDividendPoints = totalDividendPoints.sub(accounts[account].lastDividendPoints);
        return (bondsOutstanding[account] * newDividendPoints) / pointMultiplier;
    }
    function fetchdivs(address toupdate) public updateAccount(toupdate){}
    
    modifier updateAccount(address account) {
        uint256 owing = dividendsOwing(account);
        if(owing > 0) {
            
            unclaimedDividends = unclaimedDividends.sub(owing);
            pendingFills[account] = pendingFills[account].add(owing);
        }
        accounts[account].lastDividendPoints = totalDividendPoints;
        _;
        }
    function () external payable{} // needs for divs
    function vaultToWallet(address toPay) public {
        require(playerVault[toPay] > 0);
        uint256 value = playerVault[toPay];
        playerVault[toPay] = 0;
        toPay.transfer(value);
        emit cashout(msg.sender,value);
    }
    // view functions
    function harvestabledivs()
        view
        public
        returns(uint256)
    {
        return ( P3Dcontract_.myDividends(true))  ;
    }
    
    function fetchDataMain()
        public
        view
        returns(uint256 _ethPendingDistribution, uint256 _ethPendingManagement, uint256 _ethPendingLines)
    {
        _ethPendingDistribution = ethPendingDistribution;
        _ethPendingManagement = ethPendingManagement;
        _ethPendingLines = ethPendingLines;
    }
    function fetchCheatLine()
        public
        view
        returns(address _1stInLine, address _2ndInLine, address _3rdInLine, uint256 _sizeOfPot)
    {
        _1stInLine = cheatLine[nextInLine-1];
        _2ndInLine = cheatLine[nextInLine-2];
        _3rdInLine = cheatLine[nextInLine-3];
        _sizeOfPot = cheatLinePot;
    }
    function fetchCheatLineWhale()
        public
        view
        returns(address _1stInLine2, address _2ndInLine2, address _3rdInLine2, uint256 _sizeOfPot2)
    {
        _1stInLine2 = cheatLineWhale[nextInLineWhale-1];
        _2ndInLine2 = cheatLineWhale[nextInLineWhale-2];
        _3rdInLine2 = cheatLineWhale[nextInLineWhale-3];
        _sizeOfPot2 = cheatLinePotWhale;
    }

    // management hot potato functions
    function buyCEO() public payable{
        uint256 value = msg.value;
        require(value >= price[0]);// 
        playerVault[management[0]] += (manVault[0] .add(value.div(2)));
        manVault[0] = 0;
        emit CEOsold(management[0],msg.sender,value);
        management[0] = msg.sender;
        ethPendingDistribution = ethPendingDistribution.add(value.div(2));
        price[0] = price[0].mul(21).div(10);
    }
    function buyDirector(uint256 spot) public payable{
        uint256 value = msg.value;
        require(spot >0 && spot < 6);
        require(value >= price[spot]);
        playerVault[management[spot]] += (manVault[spot].add(value.div(2)));
        manVault[spot] = 0;
        emit Directorsold(management[spot],msg.sender,value, spot);
        management[spot] = msg.sender;
        ethPendingDistribution = ethPendingDistribution.add(value.div(4));
        playerVault[management[0]] = playerVault[management[0]].add(value.div(4));
        price[spot] = price[spot].mul(21).div(10);
    }
    function managementWithdraw(uint256 who) public{
        uint256 cash = manVault[who];
        require(who <6);
        require(cash>0);
        manVault[who] = 0; 
        management[who].transfer(cash);
        emit cashout(management[who],cash);
    }
    // eth distribution cogs main
    function ethPropagate() public{
        require(ethPendingDistribution>0 );
        uint256 base = ethPendingDistribution.div(50);
        ethPendingDistribution = 0;
        //2% to SPASM
        SPASM_.disburse.value(base)();
        //2% to management
        ethPendingManagement = ethPendingManagement.add(base);
        //10% to bonds maturity
        uint256 amount = base.mul(5);
        totalDividendPoints = totalDividendPoints.add(amount.mul(pointMultiplier).div(totalSupplyBonds));
        unclaimedDividends = unclaimedDividends.add(amount);
        emit bondsMatured(amount);
        //rest split across lines
        ethPendingLines = ethPendingLines.add(base.mul(43));
    }
    //buybonds function
    function buyBonds(address masternode, address referral)updateAccount(msg.sender) updateAccount(referral) payable public {
        // update bonds first
        uint256 value = msg.value;
        address sender = msg.sender;
        require(msg.value > 0 && referral != 0);
        uint256 base = value.div(100);
        // buy P3D 5%
        P3Dcontract_.buy.value(base.mul(5))(masternode);
        // add bonds to sender
        uint256 amount =  value.mul(11).div(10);
        bondsOutstanding[sender] = bondsOutstanding[sender].add(amount);
        emit bondsBought(msg.sender,amount);
        // reward referal in bonds
        bondsOutstanding[referral] = bondsOutstanding[referral].add(value.mul(2).div(100));
        // edit totalsupply
        totalSupplyBonds = totalSupplyBonds.add(amount.add(value.mul(2).div(100)));
        // set rest to eth pending
        ethPendingDistribution = ethPendingDistribution.add(base.mul(95));
        // update playerbook
        if(playerId[sender] == 0){
           playerId[sender] = nextPlayerID;
           IdToAdress[nextPlayerID] = sender;
           nextPlayerID++;
        }
    }
    // management distribution eth function
    function ethManagementPropagate() public {
        require(ethPendingManagement > 0);
        uint256 base = ethPendingManagement.div(20);
        ethPendingManagement = 0;
        manVault[0] += base.mul(5);//CEO
        manVault[1] += base.mul(5);//first Director
        manVault[2] += base.mul(4);
        manVault[3] += base.mul(3);
        manVault[4] += base.mul(2);
        manVault[5] += base.mul(1);// fifth
    }
    // cash mature bonds to playervault
    function fillBonds (address bondsOwner)updateAccount(msg.sender) updateAccount(bondsOwner) public {
        uint256 pendingz = pendingFills[bondsOwner];
        require(bondsOutstanding[bondsOwner] > 1000 && pendingz > 1000);
        require(msg.sender == tx.origin);
        require(pendingz <= bondsOutstanding[bondsOwner]);
        // empty the pendings
        pendingFills[bondsOwner] = 0;
        // decrease bonds outstanding
        bondsOutstanding[bondsOwner] = bondsOutstanding[bondsOwner].sub(pendingz);
        // reward freelancer
        bondsOutstanding[msg.sender]= bondsOutstanding[msg.sender].add(pendingz.div(1000));
        // adjust totalSupplyBonds
        totalSupplyBonds = totalSupplyBonds.sub(pendingz).add(pendingz.div(1000));
        // add cash to playerVault
        playerVault[bondsOwner] = playerVault[bondsOwner].add(pendingz);
        emit bondsFilled(bondsOwner,pendingz);
    }
    //force bonds because overstock pendingFills
    function forceBonds (address bondsOwner,  address masternode)updateAccount(msg.sender) updateAccount(bondsOwner) public {
        require(bondsOutstanding[bondsOwner] > 1000 && pendingFills[bondsOwner] > 1000);
        require(pendingFills[bondsOwner] > bondsOutstanding[bondsOwner]);
        // update bonds first
        uint256 value = pendingFills[bondsOwner].sub(bondsOutstanding[bondsOwner]);
        
        pendingFills[bondsOwner] = pendingFills[bondsOwner].sub(bondsOutstanding[bondsOwner]);
        uint256 base = value.div(100);
        // buy P3D 5%
        P3Dcontract_.buy.value(base.mul(5))(masternode);
        // add bonds to sender
        uint256 amount =  value.mul(11).div(10);
        bondsOutstanding[bondsOwner] += amount;
        // reward referal in bonds
        bondsOutstanding[msg.sender] += value.mul(2).div(100);
        // edit totalsupply
        totalSupplyBonds += amount.add(value.mul(2).div(100));
        // set rest to eth pending
        ethPendingDistribution += base.mul(95);
        emit bondsBought(bondsOwner, amount);
    }
    //autoReinvest functions
    function setAuto (uint256 percentage) public {
        allowAutoInvest[msg.sender] = true;
        require(percentage <=100 && percentage > 0);
        percentageToReinvest[msg.sender] = percentage;
    }
    function disableAuto () public {
        allowAutoInvest[msg.sender] = false;
    }
    function freelanceReinvest(address stackOwner, address masternode)updateAccount(msg.sender) updateAccount(stackOwner) public{
        address sender = msg.sender;
        require(allowAutoInvest[stackOwner] == true && playerVault[stackOwner] > 100000);
        require(sender == tx.origin);
        // update vault first
        uint256 value = playerVault[stackOwner];
        //emit autoReinvested(stackOwner, value, percentageToReinvest[stackOwner]);
        playerVault[stackOwner]=0;
        uint256 base = value.div(100000).mul(percentageToReinvest[stackOwner]);
        // buy P3D 5%
        P3Dcontract_.buy.value(base.mul(50))(masternode);
        // update bonds first
        // add bonds to sender
        uint256 precalc = base.mul(950);//.mul(percentageToReinvest[stackOwner]); 
        uint256 amount =  precalc.mul(109).div(100);
        bondsOutstanding[stackOwner] = bondsOutstanding[stackOwner].add(amount);
        // reward referal in bonds
        bondsOutstanding[sender] = bondsOutstanding[sender].add(base);
        // edit totalsupply
        totalSupplyBonds = totalSupplyBonds.add(amount.add(base));
        // set to eth pending
        ethPendingDistribution = ethPendingDistribution.add(precalc);
        if(percentageToReinvest[stackOwner] < 100)
        {
            precalc = value.sub(precalc.add(base.mul(50)));//base.mul(100-percentageToReinvest[stackOwner]);
            stackOwner.transfer(precalc);
            
        }
        emit bondsBought(stackOwner, amount);
        
    }
    function PendinglinesToLines () public {
        require(ethPendingLines > 1000);
        
        uint256 base = ethPendingLines.div(25);
        ethPendingLines = 0;
        // line 1
        cheatLinePot = cheatLinePot.add(base);
        // line 2
        cheatLinePotWhale = cheatLinePotWhale.add(base);
        // line 3
        arbitragePot = arbitragePot.add(base);
        // line 4
        arbitragePotRisky = arbitragePotRisky.add(base);
        // line 5
        poioPot = poioPot.add(base);
        // line 6
        poioPotWhale = poioPotWhale.add(base);
        // line 7
        poioPotAll = poioPotAll.add(base);
        // line 8
        podoPotAll = podoPotAll.add(base);
        // line 9
        randomPot = randomPot.add(base);
        // line 10
        randomPotWhale = randomPotWhale.add(base);
        // line 11
        randomPotAlways = randomPotAlways.add(base);
        // line 12
        dicerollpot = dicerollpot.add(base);
        // line 13
        badOddsPot = badOddsPot.add(base);
        
        // line 14
        Snip3dPot = Snip3dPot.add(base);

        // line 16
        Slaughter3dPot = Slaughter3dPot.add(base);
        
        // line 17
        ethRollBank = ethRollBank.add(base);
        // line 18
        ethStuckOnPLinc = ethStuckOnPLinc.add(base);
        // line 19
        PLincGiverOfEth = PLincGiverOfEth.add(base);
        
        //vaultSmall
        vaultSmall = vaultSmall.add(base);
        //vaultMedium
        vaultMedium = vaultMedium.add(base);
        //vaultLarge 
        vaultLarge = vaultLarge.add(base);
        //vaultdrip 
        vaultDrip = vaultDrip.add(base.mul(4));
        
    }
    function fetchP3Ddivs() public{
        //allocate p3d dividends to contract 
            uint256 dividends =  harvestabledivs();
            require(dividends > 0);
            P3Dcontract_.withdraw();
            ethPendingDistribution = ethPendingDistribution.add(dividends);
    }
    
    //Profit lines
    function cheatTheLine () public payable updateAccount(msg.sender){
        address sender = msg.sender;
        uint256 value = msg.value;
        require(value >= 0.01 ether);
        require(msg.sender == tx.origin);
        if(isInLine[sender] == true)
        {
            // overwrite previous spot
            cheatLine[lineNumber[sender]] = cheatLine[lastInLine];
            // get first in line
            cheatLine[nextInLine] = sender;
            // adjust pointers
            nextInLine++;
            lastInLine++;
        }
        if(isInLine[sender] == false)
        {
            // get first in line
            cheatLine[nextInLine] = sender;
            // set where in line
            lineNumber[sender] = nextInLine;
            // adjust pointer
            nextInLine++;
            // adjust isinline
            isInLine[sender] = true;
        }

        //give bonds for eth payment    
        bondsOutstanding[sender] = bondsOutstanding[sender].add(value);
        // edit totalsupply
        totalSupplyBonds = totalSupplyBonds.add(value);
        // set paid eth to eth pending
        ethPendingDistribution = ethPendingDistribution.add(value);
        emit bondsBought(sender, value);
        
    }
    function payoutCheatLine () public {
        // needs someone in line and pot have honey
        require(cheatLinePot >= 0.1 ether && nextInLine > 0);
        require(msg.sender == tx.origin);
        // set winner
        uint256 winner = nextInLine.sub(1);
        // change index
        nextInLine--;
        // deduct from pot
        cheatLinePot = cheatLinePot.sub(0.1 ether);
        // add to winers pendingFills
        pendingFills[cheatLine[winner]] = pendingFills[cheatLine[winner]].add(0.1 ether);
        // kicked from line because of win
        isInLine[cheatLine[winner]] = false;
        // 
        //emit newMaturedBonds(cheatLine[winner], 0.1 ether);
        emit won(cheatLine[winner], true, 0.1 ether, 1);
    }
    function cheatTheLineWhale () public payable updateAccount(msg.sender){
        address sender = msg.sender;
        uint256 value = msg.value;
        require(value >= 1 ether);
        require(sender == tx.origin);
        if(isInLineWhale[sender] == true)
        {
            // overwrite previous spot
            cheatLineWhale[lineNumberWhale[sender]] = cheatLineWhale[lastInLineWhale];
            // get first in line
            cheatLineWhale[nextInLineWhale] = sender;
            // adjust pointers
            nextInLineWhale++;
            lastInLineWhale++;
        }
        if(isInLineWhale[sender] == false)
        {
            // get first in line
            cheatLineWhale[nextInLineWhale] = sender;
            // set where in line
            lineNumberWhale[sender] = nextInLineWhale;
            // adjust pointer
            nextInLineWhale++;
            // adjust isinline
            isInLineWhale[sender] = true;
        }
        
        bondsOutstanding[sender] = bondsOutstanding[sender].add(value);
        // edit totalsupply
        totalSupplyBonds = totalSupplyBonds.add(value);
        // set paid eth to eth pending
        ethPendingDistribution = ethPendingDistribution.add(value);
        //emit bondsBought(sender, value);
    }
    function payoutCheatLineWhale () public {
        // needs someone in line and pot have honey
        require(cheatLinePotWhale >= 10 ether && nextInLineWhale > 0);
        require(msg.sender == tx.origin);
        // set winner
        uint256 winner = nextInLineWhale.sub(1);
        // change index
        nextInLineWhale--;
        // deduct from pot
        cheatLinePotWhale = cheatLinePotWhale.sub(10 ether);
        // add to winers pendingFills
        pendingFills[cheatLineWhale[winner]] = pendingFills[cheatLineWhale[winner]].add(10 ether);
        // kicked from line because of win
        isInLineWhale[cheatLineWhale[winner]] = false;
        // 
        //emit newMaturedBonds(cheatLineWhale[winner], 10 ether);
        emit won(cheatLineWhale[winner], true, 10 ether,2);
    }
    function takeArbitrageOpportunity () public payable updateAccount(msg.sender){
        uint256 opportunityCost = arbitragePot.div(100);
        require(msg.value > opportunityCost && opportunityCost > 1000);
        
        uint256 payout = opportunityCost.mul(101).div(100);
        arbitragePot = arbitragePot.sub(payout);
        //
        uint256 value = msg.value;
        address sender = msg.sender;
        require(sender == tx.origin);
        // add to winers pendingFills
        pendingFills[sender] = pendingFills[sender].add(payout);
        // add bonds to sender
        
        bondsOutstanding[sender] = bondsOutstanding[sender].add(value);
        // edit totalsupply
        totalSupplyBonds = totalSupplyBonds.add(value);
        // set paid eth to eth pending
        ethPendingDistribution = ethPendingDistribution.add(value);
        
        emit won(sender, true, payout,3);
    }
    function takeArbitrageOpportunityRisky () public payable updateAccount(msg.sender){
        uint256 opportunityCost = arbitragePotRisky.div(5);
        require(msg.value > opportunityCost && opportunityCost > 1000);
        
        uint256 payout = opportunityCost.mul(101).div(100);
        arbitragePotRisky = arbitragePotRisky.sub(payout);
        //
        uint256 value = msg.value;
        address sender = msg.sender;
        require(sender == tx.origin);
        // add to winers pendingFills
        pendingFills[sender] = pendingFills[sender].add(payout);
        // add bonds to sender
        
        bondsOutstanding[sender] = bondsOutstanding[sender].add(value);
        // edit totalsupply
        totalSupplyBonds = totalSupplyBonds.add(value);
        // set paid eth to eth pending
        ethPendingDistribution = ethPendingDistribution.add(value);
        //emit bondsBought(sender, value);
        //emit newMaturedBonds(sender, payout);
        emit won(sender, true, payout,4);
    }
    function playProofOfIncreasingOdds (uint256 plays) public payable updateAccount(msg.sender){
        //possible mm gas problem upon win?
        
        address sender  = msg.sender;
        uint256 value = msg.value;
        uint256 oddz = odds[sender];
        uint256 oddzactual;
        require(sender == tx.origin);
        require(value >= plays.mul(0.1 ether));
        require(plays > 0);
        bool hasWon;
        // fix this
        for(uint i=0; i< plays; i++)
        {
            
            if(1000- oddz - i > 2){oddzactual = 1000- oddz - i;}
            if(1000- oddz - i <= 2){oddzactual =  2;}
            uint256 outcome = uint256(blockhash(block.number-1)) % (oddzactual);
            emit RNGgenerated(outcome);
            if(outcome == 1){
                // only 1 win per tx
                i = plays;
                // change pot
                poioPot = poioPot.div(2);
                // add to winers pendingFills
                pendingFills[sender] = pendingFills[sender].add(poioPot);
                // reset odds
                odds[sender] = 0;
                //emit newMaturedBonds(sender, poioPot);
                hasWon = true;
                uint256 amount = poioPot;
            }
        }
        odds[sender] += i;
        // add bonds to sender
        bondsOutstanding[sender] = bondsOutstanding[sender].add(value);
        // edit totalsupply
        totalSupplyBonds = totalSupplyBonds.add(value);
        // set paid eth to eth pending
        ethPendingDistribution = ethPendingDistribution.add(value);
        //
        //emit bondsBought(sender, value);
        emit won(sender, hasWon, amount,5);
        
    }
    function playProofOfIncreasingOddsWhale (uint256 plays) public payable updateAccount(msg.sender){
        //possible mm gas problem upon win?

        address sender  = msg.sender;
        uint256 value = msg.value;
        uint256 oddz = oddsWhale[sender];
        uint256 oddzactual;
        require(sender == tx.origin);
        require(value >= plays.mul(10 ether));
        require(plays > 0);
        bool hasWon;
        // fix this
        for(uint i=0; i< plays; i++)
        {
            
            if(1000- oddz - i > 2){oddzactual = 1000- oddz - i;}
            if(1000- oddz - i <= 2){oddzactual =  2;}
            uint256 outcome = uint256(blockhash(block.number-1)) % (oddzactual);
            emit RNGgenerated(outcome);
            if(outcome == 1){
                // only 1 win per tx
                i = plays;
                // change pot
                poioPotWhale = poioPotWhale.div(2);
                // add to winers pendingFills
                pendingFills[sender] = pendingFills[sender].add(poioPotWhale);
                // reset odds
                oddsWhale[sender] = 0;
                //emit newMaturedBonds(sender, poioPotWhale);
                hasWon = true;
                uint256 amount = poioPotWhale;
            }
        }
        oddsWhale[sender] += i;
        // add bonds to sender
        bondsOutstanding[sender] = bondsOutstanding[sender].add(value);
        // edit totalsupply
        totalSupplyBonds = totalSupplyBonds.add(value);
        // set paid eth to eth pending
        ethPendingDistribution = ethPendingDistribution.add(value);
        //
        //emit bondsBought(sender, value);
        emit won(sender, hasWon, amount,6);
    }
    function playProofOfIncreasingOddsALL (uint256 plays) public payable updateAccount(msg.sender){
        //possible mm gas problem upon win?

        address sender  = msg.sender;
        uint256 value = msg.value;
        uint256 oddz = oddsAll;
        uint256 oddzactual;
        require(sender == tx.origin);
        require(value >= plays.mul(0.1 ether));
        require(plays > 0);
        bool hasWon;
        // fix this
        for(uint i=0; i< plays; i++)
        {
            
            if(1000- oddz - i > 2){oddzactual = 1000- oddz - i;}
            if(1000- oddz - i <= 2){oddzactual =  2;}
            uint256 outcome = uint256(blockhash(block.number-1)) % (oddzactual);
            emit RNGgenerated(outcome);
            if(outcome == 1){
                // only 1 win per tx
                i = plays;
                // change pot
                poioPotAll = poioPotAll.div(2);
                // add to winers pendingFills
                pendingFills[sender] = pendingFills[sender].add(poioPotAll);
                // reset odds
                odds[sender] = 0;
                //emit newMaturedBonds(sender, poioPotAll);
                hasWon = true;
                uint256 amount = poioPotAll;
            }
        }
        oddsAll += i;
        // add bonds to sender
        bondsOutstanding[sender] = bondsOutstanding[sender].add(value);
        // edit totalsupply
        totalSupplyBonds = totalSupplyBonds.add(value);
        // set paid eth to eth pending
        ethPendingDistribution = ethPendingDistribution.add(value);
        //emit bondsBought(sender, value);
        emit won(sender, hasWon, amount,7);
    }
    function playProofOfDecreasingOddsALL (uint256 plays) public payable updateAccount(msg.sender){
        //possible mm gas problem upon win?

        address sender  = msg.sender;
        uint256 value = msg.value;
        uint256 oddz = decreasingOddsAll;
        uint256 oddzactual;
        require(sender == tx.origin);
        require(value >= plays.mul(0.1 ether));
        require(plays > 0);
        bool hasWon;
        // fix this
        for(uint i=0; i< plays; i++)
        {
            
            oddzactual = oddz + i;
            uint256 outcome = uint256(blockhash(block.number-1)).add(now) % (oddzactual);
            emit RNGgenerated(outcome);
            if(outcome == 1){
                // only 1 win per tx
                i = plays;
                // change pot
                podoPotAll = podoPotAll.div(2);
                // add to winers pendingFills
                pendingFills[sender] = pendingFills[sender].add(podoPotAll);
                // reset odds
                decreasingOddsAll = 10;
                //emit newMaturedBonds(sender, podoPotAll);
                hasWon = true;
                uint256 amount = podoPotAll;
            }
        }
        decreasingOddsAll += i;
        // add bonds to sender
        bondsOutstanding[sender] = bondsOutstanding[sender].add(value);
        // edit totalsupply
        totalSupplyBonds = totalSupplyBonds.add(value);
        // set paid eth to eth pending
        ethPendingDistribution = ethPendingDistribution.add(value);
        //emit bondsBought(sender, value);
        emit won(sender, hasWon, amount,8);
    }
    function playRandomDistribution (uint256 plays) public payable updateAccount(msg.sender){
        address sender = msg.sender;
        uint256 value = msg.value;
        require(value >= plays.mul(0.01 ether));
        require(plays > 0);
        uint256 spot;
         for(uint i=0; i< plays; i++)
        {
            // get first in line
            spot = randomNext + i;
            randomDistr[spot] = sender;
        }
        // adjust pointer
        randomNext = randomNext + i;
        
        
        //give bonds for eth payment    
        bondsOutstanding[sender] = bondsOutstanding[sender].add(value);
        // edit totalsupply
        totalSupplyBonds = totalSupplyBonds.add(value);
        // set paid eth to eth pending
        ethPendingDistribution = ethPendingDistribution.add(value);
        //emit bondsBought(sender, value);
       
    }
    function payoutRandomDistr () public {
        // needs someone in line and pot have honey
        address sender = msg.sender;
        require(randomPot >= 0.1 ether && randomNext > 0 && lastdraw != block.number);
        require(sender == tx.origin);
        // set winner
        uint256 outcome = uint256(blockhash(block.number-1)).add(now) % (randomNext);
        emit RNGgenerated(outcome);
        // deduct from pot
        randomPot = randomPot.sub(0.1 ether);
        // add to winers pendingFills
        pendingFills[randomDistr[outcome]] = pendingFills[randomDistr[outcome]].add(0.1 ether);
        //emit newMaturedBonds(randomDistr[outcome], 0.1 ether);
        // kicked from line because of win
        randomDistr[outcome] = randomDistr[randomNext-1];
        // reduce one the line
        randomNext--;
        // adjust lastdraw
        lastdraw = block.number;
        // 
        emit won(randomDistr[outcome], true, 0.1 ether,9);
    }
    function playRandomDistributionWhale (uint256 plays) public payable updateAccount(msg.sender){
        address sender = msg.sender;
        uint256 value = msg.value;
        require(value >= plays.mul(1 ether));
        require(plays > 0);
        uint256 spot;
         for(uint i=0; i< plays; i++)
        {
            // get first in line
            spot = randomNextWhale + i;
            randomDistrWhale[spot] = sender;
        }
        // adjust pointer
        randomNextWhale = randomNextWhale + i;
        
        
        //give bonds for eth payment    
        bondsOutstanding[sender] = bondsOutstanding[sender].add(value);
        // edit totalsupply
        totalSupplyBonds = totalSupplyBonds.add(value);
        // set paid eth to eth pending
        ethPendingDistribution = ethPendingDistribution.add(value);
        //emit bondsBought(sender, value);
        
    }
    function payoutRandomDistrWhale () public {
        // needs someone in line and pot have honey
        require(randomPotWhale >= 10 ether && randomNextWhale > 0 && lastdrawWhale != block.number);
        require(msg.sender == tx.origin);
        // set winner
        uint256 outcome = uint256(blockhash(block.number-1)).add(now) % (randomNextWhale);
        emit RNGgenerated(outcome);
        // deduct from pot
        randomPotWhale = randomPotWhale.sub(10 ether);
        //emit newMaturedBonds(randomDistrWhale[outcome], 10 ether);
        // add to winers pendingFills
        pendingFills[randomDistrWhale[outcome]] = pendingFills[randomDistrWhale[outcome]].add(10 ether);
        // kicked from line because of win
        randomDistrWhale[outcome] = randomDistrWhale[randomNext-1];
        // reduce one the line
        randomNextWhale--;
        // adjust lastdraw
        lastdrawWhale = block.number;
        // 
        emit won(randomDistrWhale[outcome], true, 10 ether,10);
    }
    function playRandomDistributionAlways (uint256 plays) public payable updateAccount(msg.sender){
        address sender = msg.sender;
        uint256 value = msg.value;
        require(value >= plays.mul(0.1 ether));
        require(plays > 0);
        uint256 spot;
         for(uint i=0; i< plays; i++)
        {
            // get first in line
            spot = randomNextAlways + i;
            randomDistrAlways[spot] = sender;
        }
        // adjust pointer
        randomNextAlways = randomNextAlways + i;
        
        
        //give bonds for eth payment    
        bondsOutstanding[sender] = bondsOutstanding[sender].add(value);
        // edit totalsupply
        totalSupplyBonds = totalSupplyBonds.add(value);
        // set paid eth to eth pending
        ethPendingDistribution = ethPendingDistribution.add(value);
        //emit bondsBought(sender, value);
    }
    function payoutRandomDistrAlways () public {
        // needs someone in line and pot have honey
        require(msg.sender == tx.origin);
        require(randomPotAlways >= 1 ether && randomNextAlways > 0 && lastdrawAlways != block.number);
        // set winner
        uint256 outcome = uint256(blockhash(block.number-1)).add(now) % (randomNextAlways);
        emit RNGgenerated(outcome);
        // deduct from pot
        randomPotAlways = randomPotAlways.sub(1 ether);
        //emit newMaturedBonds(randomDistrAlways[outcome], 1 ether);
        // add to winers pendingFills
        pendingFills[randomDistrAlways[outcome]] = pendingFills[randomDistrAlways[outcome]].add(1 ether);
        // adjust lastdraw
        lastdraw = block.number;
        // 
        emit won(randomDistrAlways[outcome], true, 1 ether,11);
    }
    function playProofOfRediculousBadOdds (uint256 plays) public payable updateAccount(msg.sender){
        //possible mm gas problem upon win?

        address sender  = msg.sender;
        uint256 value = msg.value;
        uint256 oddz = amountPlayed;
        uint256 oddzactual;
        require(sender == tx.origin);
        require(value >= plays.mul(0.0001 ether));
        require(plays > 0);
        bool hasWon;
        // fix this
        for(uint i=0; i< plays; i++)
        {
            oddzactual =  oddz.add(1000000).add(i);
            uint256 outcome = uint256(blockhash(block.number-1)).add(now) % (oddzactual);
            emit RNGgenerated(outcome);
            if(outcome == 1){
                // only 1 win per tx
                i = plays;
                // change pot
                badOddsPot = badOddsPot.div(2);
                // add to winers pendingFills
                pendingFills[sender] = pendingFills[sender].add(badOddsPot);
                //emit newMaturedBonds(randomDistrAlways[outcome], badOddsPot);
                 hasWon = true;
                uint256 amount = badOddsPot;
            }
        }
        amountPlayed += i;
        // add bonds to sender
        bondsOutstanding[sender] = bondsOutstanding[sender].add(value);
        // edit totalsupply
        totalSupplyBonds = totalSupplyBonds.add(value);
        // set paid eth to eth pending
        ethPendingDistribution = ethPendingDistribution.add(value);
        //emit bondsBought(sender, value);
        emit won(sender, hasWon, amount,12);
    }
    function playProofOfDiceRolls (uint256 oddsTaken) public payable updateAccount(msg.sender){
        //possible mm gas problem upon win?

        address sender  = msg.sender;
        uint256 value = msg.value;
        uint256 oddz = amountPlayed;
        uint256 possiblewin = value.mul(100).div(oddsTaken);
        require(sender == tx.origin);
        require(dicerollpot >= possiblewin);
        require(oddsTaken > 0 && oddsTaken < 100);
        bool hasWon;
        // fix this
       
            uint256 outcome = uint256(blockhash(block.number-1)).add(now).add(oddz) % (100);
            emit RNGgenerated(outcome);
            if(outcome < oddsTaken){
                // win
                dicerollpot = dicerollpot.sub(possiblewin);
               pendingFills[sender] = pendingFills[sender].add(possiblewin);
                //emit newMaturedBonds(sender, possiblewin);
                hasWon = true;
                uint256 amount = possiblewin;
            }
        
        amountPlayed ++;
        // add bonds to sender
        bondsOutstanding[sender] = bondsOutstanding[sender].add(value);
        // edit totalsupply
        totalSupplyBonds = totalSupplyBonds.add(value);
        // set paid eth to eth pending
        ethPendingDistribution = ethPendingDistribution.add(value);
        //emit bondsBought(sender, value);
        emit won(sender, hasWon, amount,13);
    }
    function playProofOfEthRolls (uint256 oddsTaken) public payable updateAccount(msg.sender){
        //possible mm gas problem upon win?

        address sender  = msg.sender;
        uint256 value = msg.value;
        uint256 oddz = amountPlayed;
        uint256 possiblewin = value.mul(100).div(oddsTaken);
        require(sender == tx.origin);
        require(ethRollBank >= possiblewin);
        require(oddsTaken > 0 && oddsTaken < 100);
        bool hasWon;
        // fix this
       
            uint256 outcome = uint256(blockhash(block.number-1)).add(now).add(oddz) % (100);
            emit RNGgenerated(outcome);
            if(outcome < oddsTaken){
                // win
                ethRollBank = ethRollBank.sub(possiblewin);
               pendingFills[sender] = pendingFills[sender].add(possiblewin);
               //emit newMaturedBonds(sender, possiblewin);
                hasWon = true;
                uint256 amount = possiblewin;
            }
        
        amountPlayed ++;
        // add bonds to sender
        bondsOutstanding[sender] = bondsOutstanding[sender].add(value);
        // edit totalsupply
        totalSupplyBonds = totalSupplyBonds.add(value);
        // set paid eth to eth pending
        ethPendingDistribution = ethPendingDistribution.add(value.div(100));
        // most eth to bank instead
        ethRollBank = ethRollBank.add(value.div(100).mul(99));
        
        emit won(sender, hasWon, amount,14);
    }
    function helpUnstuckEth()public payable updateAccount(msg.sender){
        uint256 value = msg.value;
        address sender  = msg.sender;
        require(sender == tx.origin);
        require(value >= 2 finney);
        hassEthstuck[currentHelper] = true;
        canGetPaidForHelping = true;
        currentHelper = msg.sender;
        hassEthstuck[currentHelper] = false;
        // add bonds to sender
        bondsOutstanding[sender] = bondsOutstanding[sender].add(value);
        // edit totalsupply
        totalSupplyBonds = totalSupplyBonds.add(value);
        // set paid eth to eth pending
        ethPendingDistribution = ethPendingDistribution.add(value);
        
    }
    function transferEthToHelper()public{
        
        address sender  = msg.sender;
        require(sender == tx.origin);
        require(hassEthstuck[sender] == true && canGetPaidForHelping == true);
        require(ethStuckOnPLinc > 4 finney);
        hassEthstuck[sender] = false;
        canGetPaidForHelping = false;
        ethStuckOnPLinc = ethStuckOnPLinc.sub(4 finney);
        pendingFills[currentHelper] = pendingFills[currentHelper].add(4 finney) ;
        //emit newMaturedBonds(currentHelper, 4 finney);
        emit won(currentHelper, true, 4 finney,15);
    }
    function begForFreeEth () public payable updateAccount(msg.sender){
         address sender  = msg.sender;
         uint256 value = msg.value;
        require(sender == tx.origin);
        
        require(value >= 0.1 ether );
        bool hasWon;
        if(PLincGiverOfEth >= 0.101 ether)
        {
            PLincGiverOfEth = PLincGiverOfEth.sub(0.1 ether);
            pendingFills[sender] = pendingFills[sender].add( 0.101 ether) ;
            //emit newMaturedBonds(sender, 0.101 ether);
            hasWon = true;
        }
        // add bonds to sender
        bondsOutstanding[sender] = bondsOutstanding[sender].add(value);
        // edit totalsupply
        totalSupplyBonds = totalSupplyBonds.add(value);
        // set paid eth to eth pending
        ethPendingDistribution = ethPendingDistribution.add(value);
        //emit bondsBought(sender, value);
        emit won(sender, hasWon, 0.101 ether,16);
    }
    function releaseVaultSmall () public {
        // needs time or amount reached
        uint256 vaultSize = vaultSmall;
        require(timeSmall + 24 hours < now || vaultSize > 10 ether);
        // reset time
        timeSmall = now;
        // empty vault
        vaultSmall = 0;
        // add to ethPendingDistribution
        ethPendingDistribution = ethPendingDistribution.add(vaultSize);
    }
    function releaseVaultMedium () public {
        // needs time or amount reached
        uint256 vaultSize = vaultMedium;
        require(timeMedium + 168 hours < now || vaultSize > 100 ether);
        // reset time
        timeMedium = now;
        // empty vault
        vaultMedium = 0;
        // add to ethPendingDistribution
        ethPendingDistribution = ethPendingDistribution.add(vaultSize);
    }
    function releaseVaultLarge () public {
        // needs time or amount reached
        uint256 vaultSize = vaultLarge;
        require(timeLarge + 720 hours < now || vaultSize > 1000 ether);
        // reset time
        timeLarge = now;
        // empty vault
        vaultLarge = 0;
        // add to ethPendingDistribution
        ethPendingDistribution = ethPendingDistribution.add(vaultSize);
    }
    function releaseDrip () public {
        // needs time or amount reached
        uint256 vaultSize = vaultDrip;
        require(timeDrip + 24 hours < now);
        // reset time
        timeDrip = now;
        uint256 value = vaultSize.div(100);
        // empty vault
        vaultDrip = vaultDrip.sub(value);
        // update divs params
        totalDividendPoints = totalDividendPoints.add(value);
        unclaimedDividends = unclaimedDividends.add(value);
        emit bondsMatured(value);
    }

    constructor()
        public
    {
        management[0] = 0x0B0eFad4aE088a88fFDC50BCe5Fb63c6936b9220;
        management[1] = 0x58E90F6e19563CE82C4A0010CEcE699B3e1a6723;
        management[2] = 0xf1A7b8b3d6A69C30883b2a3fB023593d9bB4C81E;
        management[3] = 0x2615A4447515D97640E43ccbbF47E003F55eB18C;
        management[4] = 0xD74B96994Ef8a35Fc2dA61c5687C217ab527e8bE;
        management[5] = 0x2F145AA0a439Fa15e02415e035aaF9fDbDeCaBD5;
        price[0] = 100 ether;
        price[1] = 25 ether;
        price[2] = 20 ether;
        price[3] = 15 ether;
        price[4] = 10 ether;
        price[5] = 5 ether;
        
        bondsOutstanding[0x0B0eFad4aE088a88fFDC50BCe5Fb63c6936b9220]= 100 finney;
        totalSupplyBonds = 100 finney;
        decreasingOddsAll = 10;
        
        timeSmall = now;
        timeMedium = now;
        timeLarge = now;
        timeDrip = now;
    }
    
    // snip3d handlers
    function soldierBuy () public {
        require(Snip3dPot > 0.1 ether);
        uint256 temp = Snip3dPot;
        Snip3dPot = 0;
        snip3dBridge.sacUp.value(temp)();
    }
    function snip3dVaultToPLinc() public {// from bridge to PLinc
        uint256 incoming = snip3dBridge.harvestableBalance();
        snip3dBridge.fetchBalance();
        ethPendingDistribution = ethPendingDistribution.add(incoming);
    }
    // slaughter3d handlers
    
    function sendButcher() public{
        require(Slaughter3dPot > 0.1 ether);
        uint256 temp = Slaughter3dPot;
        Slaughter3dPot = 0;
        slaughter3dbridge.sacUp.value(temp)();
    }
    function slaughter3dbridgeToPLinc() public {
        uint256 incoming = slaughter3dbridge.harvestableBalance();
        slaughter3dbridge.fetchBalance();
        ethPendingDistribution = ethPendingDistribution.add(incoming);
    }
 
// events
    event bondsBought(address indexed player, uint256 indexed bonds);
    event bondsFilled(address indexed player, uint256 indexed bonds);
    event CEOsold(address indexed previousOwner, address indexed newOwner, uint256 indexed price);
    event Directorsold(address indexed previousOwner, address indexed newOwner, uint256 indexed price, uint256 spot);
    event cashout(address indexed player , uint256 indexed ethAmount);
    event bondsMatured(uint256 indexed amount);
    event RNGgenerated(uint256 indexed number);
    event won(address player, bool haswon, uint256 amount ,uint256 line);

}
interface HourglassInterface  {
    function () payable external;
    function buy(address _playerAddress) payable external returns(uint256);
    function withdraw() external;
    function myDividends(bool _includeReferralBonus) external view returns(uint256);

}
interface SPASMInterface  {
    function() payable external;
    function disburse() external  payable;
}

interface Snip3DBridgeInterface  {
    function harvestableBalance()
        view
        external
        returns(uint256)
    ;
    function sacUp () external payable ;
    function fetchBalance ()  external ;
    
}
interface Slaughter3DBridgeInterface{
    function harvestableBalance()
        view
        external
        returns(uint256)
    ;
    function sacUp () external payable ;
    function fetchBalance ()  external ;
}