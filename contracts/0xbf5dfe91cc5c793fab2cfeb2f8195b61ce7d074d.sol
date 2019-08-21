/**
 * Source Code first verified at https://etherscan.io on Thursday, May 2, 2019
 (UTC) */

pragma solidity ^0.4.25;

// ----------------------------------------------------------------------------
// Safe maths
// ----------------------------------------------------------------------------
library SafeMath {
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
     * @dev Subtracts two unsigned integers, reverts on overflow (i.e. if subtrahend is greater than minuend).
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a);
        uint256 c = a - b;

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
     * @dev Divides two unsigned integers and returns the remainder (unsigned integer modulo),
     * reverts when dividing by zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0);
        return a % b;
    }
}

// ProfitLineInc contract
contract Snowball  {
    using SafeMath for uint;
    uint256 public RID; //roundid
    mapping (uint256 => mapping(address => info)) public round;
    
    mapping(address => uint256)public  playerId; 
    mapping(address => address)public  referalSticky;
    mapping(uint256 => address)public  IdToAdress; 
    mapping(address => address)public  hustler;
    uint256 public hustlerprice;
    address public currentHustler;
    uint256 public curatorPrice;
    address public currentCurator;
    uint256 public nextPlayerID;
    
    PlincInterface constant hub_ = PlincInterface(0xd5D10172e8D8B84AC83031c16fE093cba4c84FC6);
    
    struct info {
        uint256 stake;
        uint256 lastDividendPoints;
        }
    address self;
    mapping(address => uint256)public  playerVault;
    mapping(address => uint256)public  curatorVault;
    mapping(address => uint256)public  hustlerVault;
    // div setup for round
uint256 public pointMultiplier = 10e18;
    
    mapping(uint256 => uint256) public price;
    mapping(address => mapping(uint256 => uint256)) public lastActiveRound;
    mapping(uint256 => address) public owner;
    mapping(uint256 => uint256) public time;
    uint256 public pot;
    uint256 public curatorReward;
    mapping(uint256 => uint256) public totalDividendPoints;
    mapping(uint256 => uint256) public unclaimedDividends;
    mapping(uint256 => uint256) public totalsupply;
    
    
    function dividendsOwing(address target,uint256 roundid) public view returns(uint256) {
        uint256 newDividendPoints = totalDividendPoints[roundid].sub(round[roundid][target].lastDividendPoints);
        return (round[roundid][target].stake * newDividendPoints) / pointMultiplier;
    }
    function fetchdivs(address toUpdate, uint256 roundid) public updateAccount(toUpdate , roundid){}
    
    modifier updateAccount(address toUpdate , uint256 roundid) {
        uint256 owing = dividendsOwing(toUpdate, roundid);
        if(owing > 0) {
            
            unclaimedDividends[roundid] = unclaimedDividends[roundid].sub(owing);
            playerVault[toUpdate] = playerVault[toUpdate].add(owing);
        }
       round[roundid][toUpdate].lastDividendPoints = totalDividendPoints[roundid];
        _;
        }
    function () external payable{} // needs for divs
    // events
    event ballRolled(uint256 indexed round, address indexed player, uint256 indexed size);
    event buddySold(uint256 indexed round, address indexed previousOwner, address indexed newOwner, uint256 price);
    event collectorSold(uint256 indexed round, address indexed previousOwner, address indexed newOwner, uint256 price);
    event cashout(uint256 indexed round, address indexed player , uint256 indexed ethAmount);
    event endOfRound(uint256 indexed round, address player, uint256 size ,uint256 pot);
    event ETHfail(address indexed player, uint256 indexed round,  uint256 sizeNeeded ,uint256 sizeSent);
    // gameplay
    function buyBall( address referral)updateAccount(msg.sender, RID)  payable public {
        // update bonds first
        uint256 values = msg.value;
        address sender = msg.sender;
        require(values > 0);
        uint256 thisround = RID;
        
        if(referalSticky[sender] != 0x0){referral = referalSticky[sender];}
        if(referalSticky[sender] == 0x0){referalSticky[sender] = referral;}
        if(hustler[sender] == 0x0){hustler[sender] = currentHustler;}
        // timer not expired.
        uint256 base;
        if(time[thisround] + 24 hours >= now){
            // require enough $$ sent
            if(values < price[thisround])
            {
                playerVault[sender] = playerVault[sender].add(values);
                emit ETHfail(sender, thisround,price[thisround], values);
            }
            if(values >= price[thisround]){
        // set base for calcs
        base = price[thisround].div(100);
        // buy plinchub bonds
        hub_.buyBonds.value(price[thisround])(0xdc827558062AA1cc0e2AB28146DA9eeAC38A06D1) ;
        // excess to playerbalance
        if(values > price[thisround])
        {
            playerVault[msg.sender] = playerVault[msg.sender].add(values.sub(price[thisround]));
        }
        // pay to previous owner + 3% flip
        playerVault[owner[thisround]] = playerVault[owner[thisround]].add(base.mul(103));
        // adjust pot
        pot = pot.add(base);
        // set new owner
        owner[thisround] = sender;
        // update to new price
        price[thisround] = base.mul(110);
        // pay to previous owners
        totalDividendPoints[thisround] = totalDividendPoints[thisround].add(base.mul(pointMultiplier).div(totalsupply[thisround]));
        unclaimedDividends[thisround] = unclaimedDividends[thisround].add(base);
        // pay to referral
        playerVault[referalSticky[sender]] = playerVault[referalSticky[sender]].add(base);
        // hustler reward
        hustlerVault[hustler[sender]] = hustlerVault[hustler[sender]].add(base);
        // update playerbook
        if(playerId[sender] == 0){
           playerId[sender] = nextPlayerID;
           IdToAdress[nextPlayerID] = sender;
           nextPlayerID++;
            }
        // add  to previous owners
        round[thisround][sender].stake = round[thisround][sender].stake.add(1);
        // update previous owners totalsupply
        totalsupply[thisround] = totalsupply[thisround].add(1);
        // update round timer
        time[thisround] = now;
        //update lastActiveRound
        lastActiveRound[sender][thisround] = base.mul(100);
       
        emit ballRolled(thisround, sender,  values);
            }
    }
    // timer expired
        if(time[thisround] + 24 hours < now)
            {
                require(values >= 10 finney);
                uint256 payout = pot.div(2);
               emit endOfRound(thisround, owner[thisround], price[thisround] ,payout);
            RID = thisround.add(1);
            price[RID] = 10 finney;
            owner[RID] = sender;
            
            base = price[thisround].div(100);
        // buy plinc bonds
        hub_.buyBonds.value(values)(0xdc827558062AA1cc0e2AB28146DA9eeAC38A06D1) ;
        // pay to previous owner
        playerVault[owner[thisround]] = playerVault[owner[thisround]].add(base.mul(100)).add(pot.div(2));
        // adjust pot
        pot = pot.div(2);
        // update playerbook
        if(playerId[sender] == 0){
           playerId[sender] = nextPlayerID;
           IdToAdress[nextPlayerID] = sender;
           nextPlayerID++;
           
        }
        
        totalsupply[RID] = totalsupply[RID].add(1);
        // update round timer
        time[RID] = now;
        emit ballRolled(RID, sender,  values);
        }
        
    }
    function walletToVault() payable public {
        require(msg.value >0);
        playerVault[msg.sender] = playerVault[msg.sender].add(msg.value);
    }
    // plinc functions
    function fetchHubVault() public{
        
        uint256 value = hub_.playerVault(address(this));
        require(value >0);
        hub_.vaultToWallet();
        
        uint256 base = value.div(100);
        playerVault[currentCurator] = playerVault[currentCurator].add(base);
        // adjust pot
        pot = pot.add(base).add(base);
    }
    function fetchHubPiggy() public{
        
        uint256 value = hub_.piggyBank(address(this));
        require(value >0);
        hub_.piggyToWallet();
        uint256 base = value.div(100);
        playerVault[currentCurator] = playerVault[currentCurator].add(base);
        // adjust pot
        pot = pot.add(base).add(base);
        
    }
    
    function buyHustler() payable public {
        uint256 value = msg.value;
        if(value < hustlerprice)
        {
            playerVault[msg.sender] = playerVault[msg.sender].add(value);
            emit ETHfail(msg.sender, RID, hustlerprice, value);
        }
        if(value >= hustlerprice)
        {
        hub_.buyBonds.value(hustlerprice)(0xdc827558062AA1cc0e2AB28146DA9eeAC38A06D1) ;
        playerVault[currentHustler] =  playerVault[currentHustler].add(hustlerprice);
        emit buddySold(RID,currentHustler, msg.sender, hustlerprice);
        if(value > hustlerprice)
        {
            playerVault[msg.sender] = playerVault[msg.sender].add(value.sub(hustlerprice));
        }
        hustlerprice = hustlerprice.add(1 finney);
        currentHustler = msg.sender;
        }
        
    }
    function buyCurator() payable public {
        uint256 value = msg.value;
        if(value < curatorPrice)
        {
            playerVault[msg.sender] = playerVault[msg.sender].add(value);
            emit ETHfail(msg.sender, RID, curatorPrice, value);
        }
        if(value >= curatorPrice)
        {
        hub_.buyBonds.value(curatorPrice)(0xdc827558062AA1cc0e2AB28146DA9eeAC38A06D1) ;
        curatorVault[currentCurator] =  curatorVault[currentCurator].add(curatorPrice);
        emit collectorSold(RID, currentCurator, msg.sender, curatorPrice);
        if(value > curatorPrice)
        {
            playerVault[msg.sender] = playerVault[msg.sender].add(value.sub(curatorPrice));
        }
        curatorPrice = curatorPrice.add(1 finney);
        currentCurator = msg.sender;
        }
        
    }
    function vaultToWallet() public {
        
        address sender = msg.sender;
        require(playerVault[sender].sub(lastActiveRound[sender][RID]) > 0);
        uint256 value = playerVault[sender].sub(lastActiveRound[sender][RID]);
        playerVault[sender] = lastActiveRound[sender][RID];
        emit cashout(RID,sender ,  value);
        sender.transfer(value);
        
    }
    function vaultCuratorToWallet() public {
        
        address sender = msg.sender;
        require(curatorVault[sender] > 0);
        uint256 value = curatorVault[sender];
        curatorVault[sender] = 0;
        emit cashout(RID,sender ,  value);
        sender.transfer(value);
        
    }
    function vaultHustlerToWallet() public {
        
        address sender = msg.sender;
        require(hustlerVault[sender] > 0);
        uint256 value = hustlerVault[sender];
        hustlerVault[sender] = 0;
        emit cashout(RID,sender ,  value);
        sender.transfer(value);
        
    }
    function donateToPot()  payable public {
        pot = pot.add(msg.value);
    }
    
    constructor()
        public
    {
        hub_.setAuto(10);
        hustlerprice = 1 finney;
        curatorPrice = 1 finney;
    }
    // UI function
    function fetchDataMain()
        public
        view
        returns(uint256 _hubPiggy)
    {
        _hubPiggy = hub_.piggyBank(address(this));
    }
    
    function getPlayerInfo() public view returns(address[] memory _Owner, uint256[] memory locationData,address[] memory infoRef ){
          uint i;
          address[] memory _locationOwner = new address[](nextPlayerID);
          uint[] memory _locationData = new uint[](nextPlayerID*4); //curator + buddy + vault + frozen
          address[] memory _info = new address[](nextPlayerID*2);
          //bool[] memory _locationData2 = new bool[](nextPlayerID); //isAlive
          uint y;
          uint z;
          for(uint x = 0; x < nextPlayerID; x+=1){
            
             
                _locationOwner[i] = IdToAdress[i];
                _locationData[y] = curatorVault[IdToAdress[i]];
                _locationData[y+1] = hustlerVault[IdToAdress[i]];
                _locationData[y+2] = playerVault[IdToAdress[i]];
                _locationData[y+3] = lastActiveRound[IdToAdress[i]][RID];
                _info[z] = referalSticky[IdToAdress[i]];
                _info[z+1] = hustler[IdToAdress[i]];
                
                //_locationData2[i] = allowAutoInvest[IdToAdress[i]];
              y += 4;
              z += 2;
              i+=1;
            }
          
          return (_locationOwner,_locationData, _info);
        }
        function getRoundInfo(address player) public view returns(address[] memory _Owner, uint256[] memory locationData){
          uint i;
          address[] memory _locationOwner = new address[](RID);
          uint[] memory _locationData = new uint[](RID * 2); //
          
          uint y;
          for(uint x = 0; x < RID; x+=1){
            
             
                _locationOwner[i] = owner[i];
                _locationData[y] = price[i];
                _locationData[y+1] = dividendsOwing(player,i);
              y += 2;
              i+=1;
            }
          
          return (_locationOwner,_locationData);
        }
}
interface PlincInterface {
    
    function IdToAdress(uint256 index) external view returns(address);
    function nextPlayerID() external view returns(uint256);
    function bondsOutstanding(address player) external view returns(uint256);
    function playerVault(address player) external view returns(uint256);
    function piggyBank(address player) external view returns(uint256);
    function vaultToWallet() external ;
    function piggyToWallet() external ;
    function setAuto (uint256 percentage)external ;
    function buyBonds( address referral)external payable ;
}