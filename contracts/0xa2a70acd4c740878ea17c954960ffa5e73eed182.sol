pragma solidity ^0.4.24;

/*
*                                Stargate V1.0
*
* 
 _______ _________ _______  _______  _______  _______ _________ _______ 
(  ____ \\__   __/(  ___  )(  ____ )(  ____ \(  ___  )\__   __/(  ____ \
| (    \/   ) (   | (   ) || (    )|| (    \/| (   ) |   ) (   | (    \/
| (_____    | |   | (___) || (____)|| |      | (___) |   | |   | (__    
(_____  )   | |   |  ___  ||     __)| | ____ |  ___  |   | |   |  __)   
      ) |   | |   | (   ) || (\ (   | | \_  )| (   ) |   | |   | (      
/\____) |   | |   | )   ( || ) \ \__| (___) || )   ( |   | |   | (____/\
\_______)   )_(   |/     \||/   \__/(_______)|/     \|   )_(   (_______/
                                                                      
*
*
*                       Website:  https://playstargate.com
*
*                       Discord:  https://discord.gg/PnbFSa2
*
*                       Support:  ethergamedev@gmail.com
*
*
*
*   Stargate is a unique game of chance where you can win 10X or more of you
*   original wager.  Stargate features a progressive jackpot which grows with each bet.
*
*
*
*
*
*/


// <ORACLIZE_API>
/*
Copyright (c) 2015-2016 Oraclize SRL
Copyright (c) 2016 Oraclize LTD



Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:



The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.



THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
*/

pragma solidity ^0.4.0; //please import oraclizeAPI_pre0.4.sol when solidity < 0.4.0

contract OraclizeI {
    address public cbAddress;
    function query(uint _timestamp, string _datasource, string _arg) payable returns (bytes32 _id);
    function query_withGasLimit(uint _timestamp, string _datasource, string _arg, uint _gaslimit) payable returns (bytes32 _id);
    function query2(uint _timestamp, string _datasource, string _arg1, string _arg2) payable returns (bytes32 _id);
    function query2_withGasLimit(uint _timestamp, string _datasource, string _arg1, string _arg2, uint _gaslimit) payable returns (bytes32 _id);
    function getPrice(string _datasource) returns (uint _dsprice);
    function getPrice(string _datasource, uint gaslimit) returns (uint _dsprice);
    function useCoupon(string _coupon);
    function setProofType(byte _proofType);
    function setConfig(bytes32 _config);
    function setCustomGasPrice(uint _gasPrice);
}
contract OraclizeAddrResolverI {
    function getAddress() returns (address _addr);
}
contract usingOraclize {
    uint constant day = 60*60*24;
    uint constant week = 60*60*24*7;
    uint constant month = 60*60*24*30;
    byte constant proofType_NONE = 0x00;
    byte constant proofType_TLSNotary = 0x10;
    byte constant proofStorage_IPFS = 0x01;
    uint8 constant networkID_auto = 0;
    uint8 constant networkID_mainnet = 1;
    uint8 constant networkID_testnet = 2;
    uint8 constant networkID_morden = 2;
    uint8 constant networkID_consensys = 161;

    OraclizeAddrResolverI OAR;
    
    OraclizeI oraclize;
    modifier oraclizeAPI {
        if(address(OAR)==0) oraclize_setNetwork(networkID_auto);
        oraclize = OraclizeI(OAR.getAddress());
        _;
    }
    modifier coupon(string code){
        oraclize = OraclizeI(OAR.getAddress());
        oraclize.useCoupon(code);
        _;
    }

    function oraclize_setNetwork(uint8 networkID) internal returns(bool){
        if (getCodeSize(0x1d3b2638a7cc9f2cb3d298a3da7a90b67e5506ed)>0){ //mainnet
            OAR = OraclizeAddrResolverI(0x1d3b2638a7cc9f2cb3d298a3da7a90b67e5506ed);
            return true;
        }
        if (getCodeSize(0xc03a2615d5efaf5f49f60b7bb6583eaec212fdf1)>0){ //ropsten testnet
            OAR = OraclizeAddrResolverI(0xc03a2615d5efaf5f49f60b7bb6583eaec212fdf1);
            return true;
        }
        if (getCodeSize(0x51efaf4c8b3c9afbd5ab9f4bbc82784ab6ef8faa)>0){ //browser-solidity
            OAR = OraclizeAddrResolverI(0x51efaf4c8b3c9afbd5ab9f4bbc82784ab6ef8faa);
            return true;
        }
        return false;
    }
    
    function __callback(bytes32 myid, string result) {
        __callback(myid, result, new bytes(0));
    }
    function __callback(bytes32 myid, string result, bytes proof) {
    }
    
    function oraclize_getPrice(string datasource) oraclizeAPI internal returns (uint){
        return oraclize.getPrice(datasource);
    }
    function oraclize_getPrice(string datasource, uint gaslimit) oraclizeAPI internal returns (uint){
        return oraclize.getPrice(datasource, gaslimit);
    }
    
    function oraclize_query(string datasource, string arg) oraclizeAPI internal returns (bytes32 id){
        uint price = oraclize.getPrice(datasource);
        if (price > 1 ether + tx.gasprice*200000) return 0; // unexpectedly high price
        return oraclize.query.value(price)(0, datasource, arg);
    }
    function oraclize_query(uint timestamp, string datasource, string arg) oraclizeAPI internal returns (bytes32 id){
        uint price = oraclize.getPrice(datasource);
        if (price > 1 ether + tx.gasprice*200000) return 0; // unexpectedly high price
        return oraclize.query.value(price)(timestamp, datasource, arg);
    }
    function oraclize_query(uint timestamp, string datasource, string arg, uint gaslimit) oraclizeAPI internal returns (bytes32 id){
        uint price = oraclize.getPrice(datasource, gaslimit);
        if (price > 1 ether + tx.gasprice*gaslimit) return 0; // unexpectedly high price
        return oraclize.query_withGasLimit.value(price)(timestamp, datasource, arg, gaslimit);
    }
    function oraclize_query(string datasource, string arg, uint gaslimit) oraclizeAPI internal returns (bytes32 id){
        uint price = oraclize.getPrice(datasource, gaslimit);
        if (price > 1 ether + tx.gasprice*gaslimit) return 0; // unexpectedly high price
        return oraclize.query_withGasLimit.value(price)(0, datasource, arg, gaslimit);
    }
    function oraclize_query(string datasource, string arg1, string arg2) oraclizeAPI internal returns (bytes32 id){
        uint price = oraclize.getPrice(datasource);
        if (price > 1 ether + tx.gasprice*200000) return 0; // unexpectedly high price
        return oraclize.query2.value(price)(0, datasource, arg1, arg2);
    }
    function oraclize_query(uint timestamp, string datasource, string arg1, string arg2) oraclizeAPI internal returns (bytes32 id){
        uint price = oraclize.getPrice(datasource);
        if (price > 1 ether + tx.gasprice*200000) return 0; // unexpectedly high price
        return oraclize.query2.value(price)(timestamp, datasource, arg1, arg2);
    }
    function oraclize_query(uint timestamp, string datasource, string arg1, string arg2, uint gaslimit) oraclizeAPI internal returns (bytes32 id){
        uint price = oraclize.getPrice(datasource, gaslimit);
        if (price > 1 ether + tx.gasprice*gaslimit) return 0; // unexpectedly high price
        return oraclize.query2_withGasLimit.value(price)(timestamp, datasource, arg1, arg2, gaslimit);
    }
    function oraclize_query(string datasource, string arg1, string arg2, uint gaslimit) oraclizeAPI internal returns (bytes32 id){
        uint price = oraclize.getPrice(datasource, gaslimit);
        if (price > 1 ether + tx.gasprice*gaslimit) return 0; // unexpectedly high price
        return oraclize.query2_withGasLimit.value(price)(0, datasource, arg1, arg2, gaslimit);
    }
    function oraclize_cbAddress() oraclizeAPI internal returns (address){
        return oraclize.cbAddress();
    }
    function oraclize_setProof(byte proofP) oraclizeAPI internal {
        return oraclize.setProofType(proofP);
    }
    function oraclize_setCustomGasPrice(uint gasPrice) oraclizeAPI internal {
        return oraclize.setCustomGasPrice(gasPrice);
    }    
    function oraclize_setConfig(bytes32 config) oraclizeAPI internal {
        return oraclize.setConfig(config);
    }

    function getCodeSize(address _addr) constant internal returns(uint _size) {
        assembly {
            _size := extcodesize(_addr)
        }
    }


    function parseAddr(string _a) internal returns (address){
        bytes memory tmp = bytes(_a);
        uint160 iaddr = 0;
        uint160 b1;
        uint160 b2;
        for (uint i=2; i<2+2*20; i+=2){
            iaddr *= 256;
            b1 = uint160(tmp[i]);
            b2 = uint160(tmp[i+1]);
            if ((b1 >= 97)&&(b1 <= 102)) b1 -= 87;
            else if ((b1 >= 48)&&(b1 <= 57)) b1 -= 48;
            if ((b2 >= 97)&&(b2 <= 102)) b2 -= 87;
            else if ((b2 >= 48)&&(b2 <= 57)) b2 -= 48;
            iaddr += (b1*16+b2);
        }
        return address(iaddr);
    }


    function strCompare(string _a, string _b) internal returns (int) {
        bytes memory a = bytes(_a);
        bytes memory b = bytes(_b);
        uint minLength = a.length;
        if (b.length < minLength) minLength = b.length;
        for (uint i = 0; i < minLength; i ++)
            if (a[i] < b[i])
                return -1;
            else if (a[i] > b[i])
                return 1;
        if (a.length < b.length)
            return -1;
        else if (a.length > b.length)
            return 1;
        else
            return 0;
   } 

    function indexOf(string _haystack, string _needle) internal returns (int)
    {
        bytes memory h = bytes(_haystack);
        bytes memory n = bytes(_needle);
        if(h.length < 1 || n.length < 1 || (n.length > h.length)) 
            return -1;
        else if(h.length > (2**128 -1))
            return -1;                                  
        else
        {
            uint subindex = 0;
            for (uint i = 0; i < h.length; i ++)
            {
                if (h[i] == n[0])
                {
                    subindex = 1;
                    while(subindex < n.length && (i + subindex) < h.length && h[i + subindex] == n[subindex])
                    {
                        subindex++;
                    }   
                    if(subindex == n.length)
                        return int(i);
                }
            }
            return -1;
        }   
    }

    function strConcat(string _a, string _b, string _c, string _d, string _e) internal returns (string){
        bytes memory _ba = bytes(_a);
        bytes memory _bb = bytes(_b);
        bytes memory _bc = bytes(_c);
        bytes memory _bd = bytes(_d);
        bytes memory _be = bytes(_e);
        string memory abcde = new string(_ba.length + _bb.length + _bc.length + _bd.length + _be.length);
        bytes memory babcde = bytes(abcde);
        uint k = 0;
        for (uint i = 0; i < _ba.length; i++) babcde[k++] = _ba[i];
        for (i = 0; i < _bb.length; i++) babcde[k++] = _bb[i];
        for (i = 0; i < _bc.length; i++) babcde[k++] = _bc[i];
        for (i = 0; i < _bd.length; i++) babcde[k++] = _bd[i];
        for (i = 0; i < _be.length; i++) babcde[k++] = _be[i];
        return string(babcde);
    }
    
    function strConcat(string _a, string _b, string _c, string _d) internal returns (string) {
        return strConcat(_a, _b, _c, _d, "");
    }

    function strConcat(string _a, string _b, string _c) internal returns (string) {
        return strConcat(_a, _b, _c, "", "");
    }

    function strConcat(string _a, string _b) internal returns (string) {
        return strConcat(_a, _b, "", "", "");
    }

    // parseInt
    function parseInt(string _a) internal returns (uint) {
        return parseInt(_a, 0);
    }

    // parseInt(parseFloat*10^_b)
    function parseInt(string _a, uint _b) internal returns (uint) {
        bytes memory bresult = bytes(_a);
        uint mint = 0;
        bool decimals = false;
        for (uint i=0; i<bresult.length; i++){
            if ((bresult[i] >= 48)&&(bresult[i] <= 57)){
                if (decimals){
                   if (_b == 0) break;
                    else _b--;
                }
                mint *= 10;
                mint += uint(bresult[i]) - 48;
            } else if (bresult[i] == 46) decimals = true;
        }
        if (_b > 0) mint *= 10**_b;
        return mint;
    }
    
    function uint2str(uint i) internal returns (string){
        if (i == 0) return "0";
        uint j = i;
        uint len;
        while (j != 0){
            len++;
            j /= 10;
        }
        bytes memory bstr = new bytes(len);
        uint k = len - 1;
        while (i != 0){
            bstr[k--] = byte(48 + i % 10);
            i /= 10;
        }
        return string(bstr);
    }
    
    

}
// </ORACLIZE_API>



// Stargate game data setup
contract Stargate is usingOraclize {
    using SafeMath for uint;

    // ---------------------- Events

    event LogResult(
        address _wagerer,
        uint _result,
        uint _profit,
        uint _wagered,
        uint _category,
        bool _win,
        uint _originalBet
    );

    event onWithdraw(
        address customerAddress,
        uint256 ethereumWithdrawn
    );

    event betError(
        address indexed _wagerer,
        uint _result
    );

    event modError(
        address indexed _wagerer,
        uint _result
    );

     // Result announcement events
    event LOG_NewBet(address _wagerer, uint amount);
    event Deposit(address indexed sender, uint value);
    event Loss(address _wagerer, uint _block);                  // Category 0
    event Cat1(address _wagerer, uint _block);                  // Category 1
    event Cat2(address _wagerer, uint _block);                  // Category 2
    event Cat3(address _wagerer, uint _block);                  // Category 3
    event Cat4(address _wagerer, uint _block);                  // Category 4
    event Cat5(address _wagerer, uint _block);                  // Category 5
    event Cat6(address _wagerer, uint _block);                  // Category 6
    event Cat7(address _wagerer, uint _block);                  // Category 7
    event Cat8(address _wagerer, uint _block);                  // Category 8
    event Cat9(address _wagerer, uint _block);                  // Category 9
    event Cat10(address _wagerer, uint _block);                 // Category 10
    event Cat11(address _wagerer, uint _block);                 // Category 11
    event Cat12(address _wagerer, uint _block);                 // Category 12
    event Cat13(address _wagerer, uint _block);                 // Category 13
    event Cat14(address _wagerer, uint _block);                 // Category 14
    event Cat15(address _wagerer, uint _block);                 // Category 15
    event Cat16(address _wagerer, uint _block);                 // Category 16
    event Cat17(address _wagerer, uint _block);                 // Category 17
    event Cat18(address _wagerer, uint _block);                 // Category 18
    event Cat19(address _wagerer, uint _block);                 // Category 19    
    event BetConcluded(address _wagerer, uint _block);          // Debug event

    event LogConstructorInitiated(string nextStep);
    event LogPriceUpdated(string price);
    event LogNewOraclizeQuery(string description);

   
    // ---------------------- Modifiers

    // Makes sure bet is within Min and Max Range
    modifier betIsValid(uint _betSize) {
        require(_betSize <= maxBet);
        require(_betSize >= minBet);
      _;
    }

      // only people with winnings
    modifier onlyPlayers(address _player) {
        require(playerAccount[_player] > 0);
        _;
    }

    // Requires the game to be currently active
    modifier gameIsActive {
      require(gamePaused == false);
      _;
    }

    // Require msg.sender to be owner
    modifier onlyOwner {
      require(msg.sender == owner); 
      _;
    }

    modifier onlyOraclize {
        if (msg.sender != oraclize_cbAddress()) throw; 
        _;
    }

    modifier onlyIfBetExist(bytes32 myid) {
        if(bets[myid].playerAddress == address(0x0)) throw;
        _;
    }

    modifier onlyIfValidGas(uint newGasLimit) {
        if (ORACLIZE_GAS_LIMIT + newGasLimit < ORACLIZE_GAS_LIMIT) throw;
        if (newGasLimit < 25000) throw;
        _;
    }

    modifier onlyIfNotProcessed(bytes32 myid) {
        if (bets[myid].numberRolled > 0) throw;
        _;
    }

    struct Bet {
        address playerAddress;
        uint amountBet;
        uint numberRolled;
        uint originalBet;
        bool instaPay;
    }

    // ---------------------- Variables

    // Configurables
    uint maxProfit;

    mapping (address => uint256) public playerAccount;
    uint public maxProfitAsPercentOfHouse;
    uint public minBet = 5e16;  //0.05ETH
    uint public maxBet = 2e17;  //0.20ETH  This will increase with contract value

    mapping (address => uint256) public playerETHWagered;
    mapping (address => uint256) public playerETHWon;
 
    address private owner;
    address private bankroll;
    bool gamePaused;
    bool boolJackpotFee;
    uint jackpotDivisor;

    //Random Number Functions
    uint public randN = 3;          //numberof random bytes to be returned
    uint public randDelay = 0;      //number of seconds to delay result
    uint public maxRange = 1000000; //Max Random Number

    // Trackers
    //uint  public totalSpins;
    uint  public totalBets;
     uint  public totalCalls;
    uint  public totalETHWagered;
    //mapping (uint => uint) public contractBalance;
    
    // Is betting allowed? (Administrative function, in the event of unforeseen bugs)
    bool public gameActive;


    uint256 public jackpot;
    uint256 private houseAccount;
    uint256 public bankAccount;
    uint256 public contractBalance;
    uint private maxPayoutMultiple;
    uint256 public totalPlayerBalance;
    uint public lastResult;
    uint256 private lastBlock;
    uint48 private lastSpinBlock; 
    uint lastCategory;
    uint public lastProfit;
    uint public numBets;

    mapping(uint => uint256) winThreshold;
    mapping(uint => uint) winPercentage;

    

    mapping (bytes32 => Bet) public bets;
    bytes32[] public betsKeys;

    uint[] public arrResult;

    uint ORACLIZE_GAS_LIMIT = 400000;   //250000;
    uint safeGas = 2300;
    uint public customGasPrice = 7000000000;  //7GWEI

    uint public oracleFee = 0;

    

    
    uint256 public lastOraclePrice;
    //uint256 public contractBalance;
    uint public lastOracleFee;

    bool public allowReferrals;
    uint public referralPercent;
    uint public minReferAmount = 100000000000000000;    //0.1 ETH min wagered to qualify for a masternode

    // ---------------------- Functions 

    constructor() public  {

        owner = msg.sender;

        //oraclize_setProof(proofType_Ledger);

        // Set starting variables
        gameActive  = true;

        allowReferrals = false;
        referralPercent = 1;

        jackpot = 0;
        totalPlayerBalance = 0;
        houseAccount = 0;
        bankAccount = 0;
        maxPayoutMultiple = 15;

        boolJackpotFee = false;
        jackpotDivisor = 100;

        winThreshold[0] = 900000;
        winThreshold[1] = 2;
        winThreshold[2] = 299;
        winThreshold[3] = 3128;
        winThreshold[4] = 16961;
        winThreshold[5] = 30794;
        winThreshold[6] = 44627;
        winThreshold[7] = 46627;
        winThreshold[8] = 49627;
        winThreshold[9] = 51627;
        winThreshold[10] = 53127;
        winThreshold[11] = 82530;
        winThreshold[12] = 150423;
        winThreshold[13] = 203888;
        winThreshold[14] = 257353;
        winThreshold[15] = 310818;
        winThreshold[16] = 364283;
        winThreshold[17] = 417748;
        winThreshold[18] = 471213;

        winPercentage[2] = 1000;        
        winPercentage[3] = 500;        
        winPercentage[4] = 200;         
        winPercentage[5] = 200;         
        winPercentage[6] = 200;         
        winPercentage[7] = 500;        
        winPercentage[8] = 750;         
        winPercentage[9] = 400;         
        winPercentage[10] = 400;       
        winPercentage[11] = 250;        
        winPercentage[12] = 150;        
        winPercentage[13] = 75;         
        winPercentage[14] = 75;         
        winPercentage[15] = 75;         
        winPercentage[16] = 100;        
        winPercentage[17] = 75;        
        winPercentage[18] = 75;        
        winPercentage[19] = 33;        

    }

     function deposit()
        public
        payable
    {
        addContractBalance(msg.value);
        bankAccount = SafeMath.add(bankAccount, msg.value);
    }


    function withdrawWinnings()
        onlyPlayers(msg.sender)
        public
    {
        // setup data
        uint256 _winnings = playerAccount[msg.sender]; 
        require( _winnings < address(this).balance - jackpot);
        playerAccount[msg.sender] = 0;
        totalPlayerBalance = SafeMath.sub(totalPlayerBalance, _winnings);
        msg.sender.transfer(_winnings);
        subContractBalance(_winnings);
            
        // fire event
        emit onWithdraw(msg.sender, _winnings);

    }

     function()
        payable {

        bet(true, 0x0000000000000000000000000000000000000000);
    }

  // Execute bet.
    function bet(bool _instaPay, address _referrer) 
      public
      payable
      betIsValid(msg.value)   
    {
        require(msg.value > 0);
        require(gameActive);


        totalETHWagered += msg.value;
        playerETHWagered[msg.sender] = SafeMath.add(playerETHWagered[msg.sender], msg.value);

        addContractBalance(msg.value);

        uint betValue = msg.value - oracleFee;

        if (allowReferrals && _referrer != 0x0000000000000000000000000000000000000000 && (_referrer != msg.sender) && (playerETHWagered[_referrer] >= minReferAmount)){
            
            uint refererAmount = SafeMath.div(SafeMath.mul(betValue,referralPercent),100);
            betValue = SafeMath.sub(betValue,refererAmount);
            playerAccount[_referrer] = SafeMath.add(playerAccount[_referrer], refererAmount);
            totalPlayerBalance = SafeMath.add(totalPlayerBalance, refererAmount);
        }

        
       
        LOG_NewBet(msg.sender, msg.value);

        // Increment total number of bets
        totalBets += 1;

        oraclize_setCustomGasPrice(customGasPrice);

        //bytes32 myid = oraclize_newRandomDSQuery(randDelay, randN, ORACLIZE_GAS_LIMIT + safeGas);

        bytes32 myid = oraclize_query("WolframAlpha", "random number between 1 and 1000000", ORACLIZE_GAS_LIMIT + safeGas);

        bets[myid] = Bet(msg.sender, betValue, 0, msg.value, _instaPay);
        betsKeys.push(myid);

  
    }

     function __callback(bytes32 myid, string strResult)
        onlyOraclize 
        onlyIfBetExist(myid)
        onlyIfNotProcessed(myid)
      {
         
        totalCalls = totalCalls + 1;
        uint result = parseInt(strResult);
        bets[myid].numberRolled = result;
        arrResult.push(result);

        //uint result = parseInt(strResult);

        bets[myid].numberRolled = result;
        arrResult.push(result);


        uint256 betAmount = bets[myid].amountBet;
       
        jackpot = SafeMath.add(jackpot,SafeMath.div(betAmount,jackpotDivisor));
        
        if (boolJackpotFee){
            betAmount = SafeMath.sub(betAmount,SafeMath.div(betAmount,jackpotDivisor));
        }

        uint profit = 0;
        uint category = 0;

        lastResult = result;

        checkResult(bets[myid].playerAddress, betAmount, category, result, myid);
       
        emit BetConcluded(bets[myid].playerAddress, result);
    
        }
    


function checkResult(address target, uint256 betAmount, uint category, uint _result, bytes32 myid) internal {
  
  uint _originalBet = bets[myid].amountBet;
  bool _instaPay = bets[myid].instaPay;

  uint profit = 0; 

   if (_result > winThreshold[0]) {   
            // Player has lost. 

            category = 0;
            emit Loss(target, _result);
           
        
        } else if (_result < winThreshold[1]) {  //2
            // Player has won the jackpot!
      
            // Get profit amount via jackpot
            profit = jackpot;    
            category = 1;
            jackpot = 0;
            // Emit events
            emit Cat1(target, _result);
          

           if (_instaPay){
                if(profit > 0){
                    if (profit <= (address(this).balance - jackpot - totalPlayerBalance)){
                        target.transfer(profit);
                        subContractBalance(profit);
                        playerETHWon[target] = SafeMath.add(playerETHWon[target], profit);
                    }else
                        {
                        playerAccount[target] = SafeMath.add(playerAccount[target],profit);
                        totalPlayerBalance = SafeMath.add(totalPlayerBalance, profit);
                        playerETHWon[target] = SafeMath.add(playerETHWon[target], profit);
                        }

                    }
                }else{
                    playerAccount[target] = SafeMath.add(playerAccount[target], profit);
                    totalPlayerBalance = SafeMath.add(totalPlayerBalance, profit);
                    playerETHWon[target] = SafeMath.add(playerETHWon[target], profit);
                }


            } else {
                if (_result < winThreshold[2]) {  //299
                    category = 2;
                    emit Cat2(target, _result);
                } else if (_result < winThreshold[3]) {  //3128
                    category = 3;
                    emit Cat3(target, _result);
                } else if (_result < winThreshold[4]) {  //16961
                    category = 4;
                    emit Cat4(target, _result);
                } else if (_result < winThreshold[5]) {  //30794
                    category = 5;
                    emit Cat5(target, _result);
                } else if (_result < winThreshold[6]) {  //44627
                    category = 6;
                    emit Cat6(target, _result);
                } else if (_result < winThreshold[7]) {  //46627
                    category = 7;
                    emit Cat7(target, _result);
                } else if (_result < winThreshold[8]) {  //49127
                    category = 8;
                    emit Cat8(target, _result);
                } else if (_result < winThreshold[9]) {  //51627
                    category = 9;
                    emit Cat9(target, _result);
                } else if (_result < winThreshold[10]) {  //53127
                    category = 10;
                    emit Cat10(target, _result);
                } else if (_result < winThreshold[11]) {  //82530
                    category = 11;
                    emit Cat11(target, _result);
                } else if (_result < winThreshold[12]) {  //150423
                    category = 12;
                    emit Cat12(target, _result);
                } else if (_result < winThreshold[13]) {  //203888
                    category = 13;
                    emit Cat13(target, _result);
                } else if (_result < winThreshold[14]) {  //257353
                    category = 14;
                    emit Cat14(target, _result);
                } else if (_result < winThreshold[15]) {  //310818
                    category = 15;
                    emit Cat15(target, _result);
                } else if (_result < winThreshold[16]) {  //364283
                    category = 16;
                    emit Cat16(target, _result);
                } else if (_result < winThreshold[17]) {  //417748
                    category = 17;
                    emit Cat17(target, _result);
                } else if (_result < winThreshold[18]) {  //471213
                    category = 18;
                    emit Cat18(target, _result);
                } else {
                    category = 19;
                    emit Cat19(target, _result);
                }
                lastCategory = category;
            }

            distributePrize(target, betAmount, category, _result, _originalBet, _instaPay);

        }

    

    //Distribute Prize
    function distributePrize(address target, uint256 betAmount, uint category, uint _result, uint _originalBet, bool _instaPay) internal {
        
        uint256 profit = 0;
     
        if (category >= 2 && category <= 19){
            profit = SafeMath.div(SafeMath.mul(betAmount,winPercentage[category]),100);
        }

        if (_instaPay){
            if(profit>0){

                uint256 _maxWithdraw = address(this).balance;
                if (profit <= _maxWithdraw){
                    target.transfer(profit);
                    subContractBalance(profit);
                } else {
                    playerAccount[target] = SafeMath.add(playerAccount[target],profit);
                    totalPlayerBalance = SafeMath.add(totalPlayerBalance, profit);
                    playerETHWon[target] = SafeMath.add(playerETHWon[target], profit);
                }


            }
        }else{
            playerAccount[target] = SafeMath.add(playerAccount[target], profit);
            totalPlayerBalance = SafeMath.add(totalPlayerBalance, profit);
        }

        lastProfit = profit;
        playerETHWon[target] = SafeMath.add(playerETHWon[target], profit);


        emit LogResult(target, _result, profit, betAmount, category, true, _originalBet);
   
        
    }


     function setWinPercentage(uint _category, uint _percentage) public onlyOwner {
        winPercentage[_category] = _percentage;
    }

     function setWinThreshold(uint _category, uint _threshold) public onlyOwner {
        winThreshold[_category] = _threshold;
    }

     function getWinPercentage(uint _category) public view returns(uint){
        return(winPercentage[_category]);
    }

    function getWinThreshold(uint _category) public view returns(uint){
        return(winThreshold[_category]);
    }

    // Subtracts from the contract balance tracking var
    function subContractBalance(uint256 sub) internal {
      contractBalance = contractBalance.sub(sub);

    }

    // Adds to the contract balance tracking var
    function addContractBalance(uint add) internal {
      contractBalance = contractBalance.add(add);
    }

    // Only owner can set minBet   
    function ownerSetMinBet(uint newMinimumBet) public
    onlyOwner
    {
      minBet = newMinimumBet;
    }

    // Only owner can set maxBet   
    function ownerSetMaxBet(uint newMaximumBet) public
    onlyOwner
    {
      maxBet = newMaximumBet;
    }

    function setGasLimit(uint _gas) public onlyOwner   {
        ORACLIZE_GAS_LIMIT = _gas;
    }

    function getGasLimit() public view returns(uint){
        return(ORACLIZE_GAS_LIMIT);
    }


    // If, for any reason, betting needs to be paused (very unlikely), this will freeze all bets.
    function pauseGame() public onlyOwner {
        gameActive = false;
    }

    // The converse of the above, resuming betting if a freeze had been put in place.
    function resumeGame() public onlyOwner {
        gameActive = true;
    }

    // Administrative function to change the owner of the contract.
    function changeOwner(address _newOwner) public onlyOwner {
        owner = _newOwner;
    }

    function setOracleFee(uint256 _newFee) public onlyOwner {
        oracleFee = _newFee;
    }

    function setAllowReferral(bool _allow) public onlyOwner {
        allowReferrals = _allow;
    }

    function setReferralPercent(uint _percent) public onlyOwner {
        referralPercent = _percent;
    }

    function setMaxRange(uint _newRange) public onlyOwner {
        maxRange = _newRange;
    }

    function setRandN(uint _newN) public onlyOwner {
        randN = _newN;
    }

    function setRandDelay(uint _newDelay) public onlyOwner {
        randDelay = _newDelay;
    }

    function setMinReferer(uint _newAmount) public onlyOwner {
        minReferAmount = _newAmount;
    }

    function setStargateCustomGasPrice(uint _newPrice) public onlyOwner {
        customGasPrice = _newPrice;
    }
    
    function getContractBalance() public view returns(uint256) {
        return(address(this).balance);
    }

    function getMyBalance() public view returns(uint256) {
        return(playerAccount[msg.sender]);
    }

    function getJackpot() public view returns(uint256){
        return(jackpot);
    }

    function getBankAccount() public view returns(uint256){
        return(bankAccount);
    }

    function getLastBlock() public view returns(uint256){
        return(lastBlock);
    }

    function getLastResult() public view returns(uint){
        return(lastResult);
    }

    function getLastCategory() public view returns(uint){
        return(lastCategory);
    }
    function getLastProfit() public view returns(uint){
        return(lastProfit);
    }

    function refund(address _to, uint256 _Amount) public onlyOwner 
    
    {
        uint256 _maxRefund = address(this).balance - jackpot - totalPlayerBalance;

       require(_Amount <= _maxRefund);
        _to.transfer(_Amount);
        subContractBalance(_Amount);

        
    }

}


/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {

    /**
    * @dev Multiplies two numbers, throws on overflow.
    */
    function mul(uint a, uint b) internal pure returns (uint) {
        if (a == 0) {
            return 0;
        }
        uint c = a * b;
        assert(c / a == b);
        return c;
    }

    /**
    * @dev Integer division of two numbers, truncating the quotient.
    */
    function div(uint a, uint b) internal pure returns (uint) {
        // assert(b > 0); // Solidity automatically throws when dividing by 0
        uint c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return c;
    }

    /**
    * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
    */
    function sub(uint a, uint b) internal pure returns (uint) {
        assert(b <= a);
        return a - b;
    }

    /**
    * @dev Adds two numbers, throws on overflow.
    */
    function add(uint a, uint b) internal pure returns (uint) {
        uint c = a + b;
        assert(c >= a);
        return c;
    }
}