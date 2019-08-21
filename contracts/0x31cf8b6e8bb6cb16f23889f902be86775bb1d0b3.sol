pragma solidity ^0.4.25;
// Original gameplay and contract by Spielley
// Spielley is not liable for any bugs or exploits the contract may contain
// This game is purely intended for fun purposes

// Gameplay:
// Send in 0.1 eth to get a soldier in the field and 1 bullet
// Wait till you reach the waiting time needed to shoot
// Each time someone is killed divs are given to the survivors
// 2 ways to shoot: 
// semi random, available first (after 200 blocks)
// Chose target                 (after 800 blocks)

// there is only a 1 time self kill prevention when semi is used
// if you send in multiple soldiers friendly kills are possible
// => use target instead

// Social gameplay: Chat with people and Coordinate your shots 
// if you want to risk not getting shot by semi bullets first

// you keep your bullets when you send in new soldiers

// if your soldier dies your address is added to the back of the refund line
// to get back your initial eth

// payout structure per 0.1 eth:
// 0.005 eth buy P3D
// 0.005 eth goes to the refund line
// 0.001 eth goes dev cut shared across SPASM(Spielleys profit share aloocation module)
// 0.001 eth goes to referal
// 0.088 eth is given to survivors upon kill

// P3D divs: 
// 1% to SPASM
// 99% to refund line

// SPASM: get a part of the dev fee payouts and funds Spielley to go fulltime dev
// https://etherscan.io/address/0xfaae60f2ce6491886c9f7c9356bd92f688ca66a1#writeContract
// => buyshares function , send in eth to get shares

// P3D MN payouts for UI devs
// payout per 0.1 eth sent in the sendInSoldier function

// **to prevent exploit spot 0 can be targeted by chosing nextFormation number**

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

// ----------------------------------------------------------------------------
// Owned contract
// ----------------------------------------------------------------------------
contract Owned {
    address public owner;
    address public newOwner;

    event OwnershipTransferred(address indexed _from, address indexed _to);

    constructor() public {
        owner = 0x0B0eFad4aE088a88fFDC50BCe5Fb63c6936b9220;
       
    }

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    function transferOwnership(address _newOwner) public onlyOwner {
        newOwner = _newOwner;
    }
    function acceptOwnership() public {
        require(msg.sender == newOwner);
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
        newOwner = address(0);
    }
}
// Snip3d contract
contract Snip3D is  Owned {
    using SafeMath for uint;
    uint public _totalSupply;

    mapping(address => uint256)public  balances;// soldiers on field
    mapping(address => uint256)public  bullets;// amount of bullets Owned
    mapping(address => uint256)public  playerVault;// amount of bullets Owned
    mapping(uint256 => address)public  formation;// the playing field
    uint256 public nextFormation;// next spot in formation
    mapping(address => uint256)public lastMove;//blocknumber lastMove
    mapping(uint256 => address) public RefundWaitingLine;
    uint256 public  NextInLine;//next person to be refunded
    uint256 public  NextAtLineEnd;//next spot to add loser
    uint256 public Refundpot;
    uint256 public blocksBeforeSemiRandomShoot = 200;
    uint256 public blocksBeforeTargetShoot = 800;
    uint256 public NextInLineOld;
    uint256 public lastToPayOld;
    
    // events
    event death(address indexed player , uint256 indexed formation);
    event semiShot(address indexed player);
    event targetShot(address indexed player);
    event newSoldiers(address indexed player , uint256 indexed amount, uint256 indexed formation);
    //constructor
    constructor()
        public
    {
        NextInLineOld = old.NextInLine();
        lastToPayOld = 2784;
        
    }
    //mods
    modifier isAlive()
    {
        require(balances[msg.sender] > 0);
        _;
    }
    // divfunctions
    // interface setup
HourglassInterface constant P3Dcontract_ = HourglassInterface(0xB3775fB83F7D12A36E0475aBdD1FCA35c091efBe);
SPASMInterface constant SPASM_ = SPASMInterface(0xfaAe60F2CE6491886C9f7C9356bd92F688cA66a1);
Snip3dInterface public old = Snip3dInterface(0x6D534b48835701312ebc904d4b37e54D4f7D039f);
// view functions
function harvestabledivs()
        view
        public
        returns(uint256)
    {
        return (P3Dcontract_.myDividends(true))  ;
    }
    function nextonetogetpaid()
        public
        view
        returns(address)
    {
        
        return (RefundWaitingLine[NextInLine]);
    }
    function playervanity(address theplayer)
        public
        view
        returns( string )
    {
        return (Vanity[theplayer]);
    }
    function blocksTillSemiShoot(address theplayer)
        public
        view
        returns( uint256 )
    {
        uint256 number;
        if(block.number - lastMove[theplayer] < blocksBeforeSemiRandomShoot)
        {number = blocksBeforeSemiRandomShoot -(block.number - lastMove[theplayer]);}
        return (number);
    }
    function blocksTillTargetShoot(address theplayer)
        public
        view
        returns( uint256 )
    {
        uint256 number;
        if(block.number - lastMove[theplayer] < blocksBeforeTargetShoot)
        {number = blocksBeforeTargetShoot -(block.number - lastMove[theplayer]);}
        return (number);
    }
function amountofp3d() external view returns(uint256){
    return ( P3Dcontract_.balanceOf(address(this)))  ;
}
    //divsection
uint256 public pointMultiplier = 10e18;
struct Account {
  uint balance;
  uint lastDividendPoints;
}
mapping(address=>Account) accounts;
mapping(address => string) public Vanity;
uint public ethtotalSupply;
uint public totalDividendPoints;
uint public unclaimedDividends;

function dividendsOwing(address account) public view returns(uint256) {
  uint256 newDividendPoints = totalDividendPoints.sub(accounts[account].lastDividendPoints);
  return (balances[account] * newDividendPoints) / pointMultiplier;
}
modifier updateAccount(address account) {
  uint256 owing = dividendsOwing(account);
  if(owing > 0) {
    unclaimedDividends = unclaimedDividends.sub(owing);
    
    playerVault[account] = playerVault[account].add(owing);
  }
  accounts[account].lastDividendPoints = totalDividendPoints;
  _;
}
function () external payable{}
function fetchdivs(address toupdate) public updateAccount(toupdate){}
// Gamefunctions
function sendInSoldier(address masternode, uint256 amount) public updateAccount(msg.sender)  payable{
    uint256 value = msg.value;
    require(value >=  amount.mul(100 finney));// sending in sol costs 0.1 eth
    address sender = msg.sender;
    // add life
    balances[sender]=  balances[sender].add(amount);
    // update totalSupply
    _totalSupply= _totalSupply.add(amount);
    // add 2 bullet per soldier
    bullets[sender] = bullets[sender].add(amount).add(amount);
    // add to playing field
    for(uint i=0; i< amount; i++)
        {
            uint256 spot = nextFormation.add(i);
            formation[spot] = sender;
        }
    nextFormation += i;
    // reset lastMove to prevent people from adding bullets and start shooting
    lastMove[sender] = block.number;
    // buy P3D
    uint256 buyamount = amount.mul( 5 finney);
    P3Dcontract_.buy.value(buyamount)(masternode);
    // check excess of payed 
     if(value > amount.mul(100 finney)){Refundpot += value.sub(amount.mul(100 finney)) ;}
    // progress refundline
    Refundpot += amount.mul(5 finney);
    // send SPASM cut
    uint256 spasmamount = amount.mul(2 finney);
    SPASM_.disburse.value(spasmamount)();
    emit newSoldiers(sender, amount, nextFormation);

}
function sendInSoldierReferal(address masternode, address referal, uint256 amount) public updateAccount(msg.sender)  payable{
    uint256 value = msg.value;
    require(value >=  amount.mul(100 finney));// sending in sol costs 0.1 eth
    address sender = msg.sender;
   // add life
    balances[sender]=  balances[sender].add(amount);
    // update totalSupply
    _totalSupply= _totalSupply.add(amount);
    // add 2 bullet per soldier
    bullets[sender] = bullets[sender].add(amount).add(amount);
    // add to playing field
    for(uint i=0; i< amount; i++)
        {
            uint256 spot = nextFormation.add(i);
            formation[spot] = sender;
        }
    nextFormation += i;
    // reset lastMove to prevent people from adding bullets and start shooting
    lastMove[sender] = block.number;
    // buy P3D
    uint256 buyamount = amount.mul( 5 finney);
    P3Dcontract_.buy.value(buyamount)(masternode);
    // check excess of payed 
     if(value > amount.mul(100 finney)){Refundpot += value.sub(amount.mul(100 finney)) ;}
    // progress refundline
    Refundpot += amount.mul(5 finney);
    // send SPASM cut
    uint256 spasmamount = amount.mul(1 finney);
    SPASM_.disburse.value(spasmamount)();
    // send referal cut
    playerVault[referal] = playerVault[referal].add(amount.mul(1 finney));
    emit newSoldiers(sender, amount, nextFormation);

}
function shootSemiRandom() public isAlive() {
    address sender = msg.sender;
    require(block.number > lastMove[sender] + blocksBeforeSemiRandomShoot);
    require(bullets[sender] > 0);
    uint256 semiRNG = (block.number.sub(lastMove[sender])) % 200;
    
    uint256 shot = uint256 (blockhash(block.number.sub(semiRNG))) % nextFormation;
    address killed = formation[shot];
    // solo soldiers self kill prevention - shoots next in line instead
    if(sender == killed)
    {
        shot = uint256 (blockhash(block.number.sub(semiRNG).add(1))) % nextFormation;
        killed = formation[shot];
    }
    // update divs loser
    fetchdivs(killed);
    // remove life
    balances[killed]--;
    // update totalSupply
    _totalSupply--;
    // remove bullet 
    bullets[sender]--;
    // remove from playing field
    uint256 lastEntry = nextFormation.sub(1);
    formation[shot] = formation[lastEntry];
    nextFormation--;
    // reset lastMove to prevent people from adding bullets and start shooting
    lastMove[sender] = block.number;
    
    
    // add loser to refundline
    fetchdivsRefund(killed);
    balancesRefund[killed] += 0.1 ether;
   
    // disburse eth to survivors
    uint256 amount = 88 finney;
    totalDividendPoints = totalDividendPoints.add(amount.mul(pointMultiplier).div(_totalSupply));
    unclaimedDividends = unclaimedDividends.add(amount);
    emit semiShot(sender);
    emit death(killed, shot);

}
function shootTarget(uint256 target) public isAlive() {
    address sender = msg.sender;
    require(target <= nextFormation && target > 0);
    require(block.number > lastMove[sender] + blocksBeforeTargetShoot);
    require(bullets[sender] > 0);
    if(target == nextFormation){target = 0;}
    address killed = formation[target];
    
    // update divs loser
    fetchdivs(killed);
    
    // remove life
    balances[killed]--;
    // update totalSupply
    _totalSupply--;
    // remove bullet 
    bullets[sender]--;
    // remove from playing field
    uint256 lastEntry = nextFormation.sub(1);
    formation[target] = formation[lastEntry];
    nextFormation--;
    // reset lastMove to prevent people from adding bullets and start shooting
    lastMove[sender] = block.number;
    
    // add loser to refundline
    fetchdivsRefund(killed);
    balancesRefund[killed] += 0.1 ether;
    // fetch contracts divs
    
    // disburse eth to survivors
    uint256 amount = 88 finney;
    
    totalDividendPoints = totalDividendPoints.add(amount.mul(pointMultiplier).div(_totalSupply));
    unclaimedDividends = unclaimedDividends.add(amount);
    emit targetShot(sender);
    emit death(killed, target);
}
function Payoutnextrefund ()public
    {
         
        require(Refundpot > 0.00001 ether);
        uint256 amount = Refundpot;
    Refundpot = 0;
    totalDividendPointsRefund = totalDividendPointsRefund.add(amount.mul(pointMultiplier).div(_totalSupplyRefund));
    unclaimedDividendsRefund = unclaimedDividendsRefund.add(amount);
    }

function disburse() public  payable {
    uint256 amount = msg.value;
    uint256 base = amount.div(100);
    uint256 amt2 = amount.sub(base);
  totalDividendPoints = totalDividendPoints.add(amt2.mul(pointMultiplier).div(_totalSupply));
 unclaimedDividends = unclaimedDividends.add(amt2);
 
}
function vaultToWallet(address toPay) public {
        require(playerVault[toPay] > 0);
        uint256 value = playerVault[toPay];
        playerVault[toPay] = 0;
        toPay.transfer(value);
    }
function changevanity(string van) public payable{
    require(msg.value >= 1  finney);
    Vanity[msg.sender] = van;
    Refundpot += msg.value;
}
function P3DDivstocontract() public{
    uint256 divs = harvestabledivs();
    require(divs > 0);
 
P3Dcontract_.withdraw();
    //1% to owner
    uint256 base = divs.div(100);
    uint256 amt2 = divs.sub(base);
    SPASM_.disburse.value(base)();// to dev fee sharing contract
   Refundpot = Refundpot.add(amt2);// add divs to refund line
   
}
// 2nd div setup for refunds

// legacystarting refunds from old contract
    function legacyStart(uint256 amountProgress) onlyOwner public{
        uint256 nextUp = NextInLineOld;
        for(uint i=0; i< amountProgress; i++)
        {
        address torefund = old.RefundWaitingLine(nextUp + i);
        i++;
        balancesRefund[torefund] = balancesRefund[torefund].add(0.1 ether);
        }
        NextInLineOld += i;
        _totalSupplyRefund = _totalSupplyRefund.add(i.mul(0.1 ether));
    }

mapping(address => uint256) public balancesRefund;
uint256 public _totalSupplyRefund;
mapping(address=>Account) public accountsRefund;
uint public ethtotalSupplyRefund;
uint public totalDividendPointsRefund;
uint public unclaimedDividendsRefund;

function dividendsOwingRefund(address account) public view returns(uint256) {
  uint256 newDividendPointsRefund = totalDividendPointsRefund.sub(accountsRefund[account].lastDividendPoints);
  return (balancesRefund[account] * newDividendPointsRefund) / pointMultiplier;
}
modifier updateAccountRefund(address account) {
  uint256 owing = dividendsOwingRefund(account);
  if(owing > balancesRefund[account]){balancesRefund[account] = owing;}
  if(owing > 0 ) {
    unclaimedDividendsRefund = unclaimedDividendsRefund.sub(owing);
    
    playerVault[account] = playerVault[account].add(owing);
    balancesRefund[account] = balancesRefund[account].sub(owing);
    _totalSupplyRefund = _totalSupplyRefund.sub(owing);
  }
  accountsRefund[account].lastDividendPoints = totalDividendPointsRefund;
  _;
}
//function () external payable{}
function fetchdivsRefund(address toUpdate) public updateAccountRefund(toUpdate){}

function disburseRefund() public  payable {
    uint256 amount = msg.value;
    
  totalDividendPointsRefund = totalDividendPointsRefund.add(amount.mul(pointMultiplier).div(_totalSupplyRefund));
  //ethtotalSupply = ethtotalSupply.add(amount);
 unclaimedDividendsRefund = unclaimedDividendsRefund.add(amount);
}

    //fetch P3D divs
    function DivsToRefundpot ()public
    {
        //allocate p3d dividends to contract 
            uint256 dividends = P3Dcontract_.myDividends(true);
            require(dividends > 0);
            uint256 base = dividends.div(100);
            P3Dcontract_.withdraw();
            SPASM_.disburse.value(base.mul(5))();// to dev fee sharing contract SPASM
            Refundpot = Refundpot.add(base.mul(95));
    }
    
}
interface HourglassInterface  {
    function() payable external;
    function buy(address _playerAddress) payable external returns(uint256);
    function sell(uint256 _amountOfTokens) external;
    function reinvest() external;
    function withdraw() external;
    function exit() external;
    function myDividends(bool _includeReferralBonus) external view returns(uint256);
    function dividendsOf(address _playerAddress) external view returns(uint256);
    function balanceOf(address _playerAddress) external view returns(uint256);
    function transfer(address _toAddress, uint256 _amountOfTokens) external returns(bool);
    function stakingRequirement() external view returns(uint256);
}

interface Snip3dInterface {
    function RefundWaitingLine(uint256 index) external view returns(address);
    function NextInLine() external view returns(uint256);
    function NextAtLineEnd() external view returns(uint256);
}
interface SPASMInterface  {
    function() payable external;
    function disburse() external  payable;
}