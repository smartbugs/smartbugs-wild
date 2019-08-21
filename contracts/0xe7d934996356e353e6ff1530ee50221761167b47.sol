pragma solidity ^0.4.24;

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

pragma solidity ^0.4.0;//please import oraclizeAPI_pre0.4.sol when solidity < 0.4.0

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

interface PlayerBookInterface {
    function getPlayerID(address _addr, uint256 _affCode) external returns (uint256);
    function getPlayerName(uint256 _pID) external view returns (bytes32);
    function getPlayerLAff(uint256 _pID) external view returns (uint256);
    function getPlayerAddr(uint256 _pID) external view returns (address);
    function getPlayerBetID(uint256 _pID, uint256 betIndex) external view returns (uint256);
    function getPlayerInfo(uint256 _pID) external view returns(uint256,uint256,uint256,uint256,uint256,uint256);
    function getNameFee() external view returns (uint256);
    function betXaddr(address _addr, uint256 betAmount, bool isWin, uint256 betID, uint256 winAmount) external;
    function rewardXID(uint256 _pID, uint256 rewardAmount, uint256 betID, uint256 level) external;
    function registerNameFromDapp(address _addr, bytes32 _name) external payable returns(bool);
}
// </ORACLIZE_API>

contract Bet100 is usingOraclize {

    using NameFilter for string;

    uint constant edge = 100; 
    uint constant maxWin = 1000; 
    uint constant maxWinCheck = maxWin * 2;  
    uint constant minBet = 10 finney;
    uint constant emergencyWithdrawalRatio = 10; 

    uint safeGas = 400000;
    uint constant ORACLIZE_GAS_LIMIT = 175000;
    uint constant INVALID_BET_MARKER = 99999;
    uint constant INVALID_BET_MARKER_1 = 99998;
    uint constant EMERGENCY_TIMEOUT = 30 seconds;

    string public randomOrgAPIKey = "e1de2fda-77b3-4fa5-bdec-cd09c82bcff7";

    PlayerBookInterface constant private PlayerBook = PlayerBookInterface(0x8c7f8865acdf45ce86adac2939a72658d12272e3);


    struct Bet {
        address playerAddress;      
        uint betNumber;             
        uint amountBet;             
        uint numberRolled;          
        uint laff;                  
        uint betTime;               
        uint winAmount;             
        bytes32 myid;                  
    }

    struct WithdrawalProposal {
        address toAddress;
        uint atTime;
    }

    uint public _bankRoll = 0;

    address public owner;
    address public houseAddress;
    bool public isStopped;


    mapping (bytes32 => Bet) public bets;
    bytes32[] public betsKeys;
    uint256 betsCount;
    mapping(uint => Bet) public betsInfo;


    uint public investorsProfit = 0;

    uint public investorsLosses = 0;


    uint constant dealerMinReward = 100 szabo; 
    uint constant dealer_level_1_reward = 20; 
    uint constant dealer_level_2_reward = 10; 
    uint constant dealer_level_3_reward = 5; 
    uint public dealer_reward_total = 0; 

    uint public draw_amount = 0;
    uint public invest_amount = 0;

    event LOG_NewBet(address playerAddress, uint amount, bytes32 myid);
    event LOG_BetWon(address playerAddress, uint numberRolled, uint amountWon, uint betId);
    event LOG_BetLost(address playerAddress, uint numberRolled, uint betId);
    event LOG_EmergencyWithdrawalProposed();
    event LOG_EmergencyWithdrawalFailed(address withdrawalAddress);
    event LOG_EmergencyWithdrawalSucceeded(address withdrawalAddress, uint amountWithdrawn);
    event LOG_FailedSend(address receiver, uint amount);
    event LOG_ZeroSend();
    event LOG_InvestorEntrance(address investor, uint amount);
    event LOG_InvestorCapitalUpdate(address investor, int amount);
    event LOG_InvestorExit(address investor, uint amount);
    event LOG_ContractStopped();
    event LOG_ContractResumed();
    event LOG_OwnerAddressChanged(address oldAddr, address newOwnerAddress);
    event LOG_HouseAddressChanged(address oldAddr, address newHouseAddress);
    event LOG_RandomOrgAPIKeyChanged(string oldKey, string newKey);
    event LOG_GasLimitChanged(uint oldGasLimit, uint newGasLimit);
    event LOG_EmergencyAutoStop();
    event LOG_EmergencyWithdrawalVote(address investor, bool vote);
    event LOG_ValueIsTooBig();
    event LOG_SuccessfulSend(address addr, uint amount);

    constructor() public {
        oraclize_setProof(proofType_TLSNotary | proofStorage_IPFS);
        owner = msg.sender;
        houseAddress = msg.sender;
        betsCount = 0;
    }

    //SECTION I: MODIFIERS AND HELPER FUNCTIONS

    //MODIFIERS

    modifier onlyIfNotStopped {
        require(isStopped == false, "Game is stop!!!");
        //if (isStopped) throw;
        _;
    }

    modifier onlyIfStopped {
        require(isStopped == true, "Game is not stop!!!");
        // if (!isStopped) throw;
        _;
    }

    modifier onlyOwner {
        require(owner == msg.sender, "Only owner can operator !!!");
        // if (owner != msg.sender) throw;
        _;
    }

    modifier onlyOraclize {
        require(msg.sender == oraclize_cbAddress(), "Only Oraclize address can operator !!!");
        //if (msg.sender != oraclize_cbAddress()) throw;
        _;
    }

    modifier onlyMoreThanZero {
        require(msg.value != 0, "onlyMoreThanZero !!!");
        //if (msg.value == 0) throw;
        _;
    }

    modifier onlyIfBetExist(bytes32 myid) {
        require(bets[myid].playerAddress != address(0x0), "onlyIfBetExist !!!");
        //if(bets[myid].playerAddress == address(0x0)) throw;
        _;
    }

    modifier onlyIfBetSizeIsStillCorrect(bytes32 myid) {
        if ((((bets[myid].amountBet * ((10000 - edge) - bets[myid].betNumber)) / bets[myid].betNumber ) <= (maxWinCheck * getBankroll()) / 10000)  && (bets[myid].amountBet >= minBet)) {
             _;
        }
        else {
            bets[myid].numberRolled = INVALID_BET_MARKER_1;
            safeSend(bets[myid].playerAddress, bets[myid].amountBet);
            return;
        }
    }

    modifier onlyIfValidRoll(bytes32 myid, string result) {
        uint numberRolled = parseInt(result);
        if ((numberRolled < 1 || numberRolled > 10000) && bets[myid].numberRolled == 0) {
            bets[myid].numberRolled = INVALID_BET_MARKER;
            safeSend(bets[myid].playerAddress, bets[myid].amountBet);
            return;
        }
        _;
    }

    modifier onlyWinningBets(uint numberRolled, uint betNumber) {
        if (numberRolled - 1 < betNumber) {
            _;
        }
    }

    modifier onlyLosingBets(uint numberRolled, uint betNumber) {
        if (numberRolled - 1 >= betNumber) {
            _;
        }
    }

    modifier onlyIfValidGas(uint newGasLimit) {
        require(ORACLIZE_GAS_LIMIT + newGasLimit >= ORACLIZE_GAS_LIMIT, "gas is low");
        // if (ORACLIZE_GAS_LIMIT + newGasLimit < ORACLIZE_GAS_LIMIT) throw;
        require(newGasLimit >= 25000, "gas is low");
        // if (newGasLimit < 25000) throw;
        _;
    }

    modifier onlyIfNotProcessed(bytes32 myid) {
        require(bets[myid].numberRolled <= 0, "onlyIfNotProcessed");
        // if (bets[myid].numberRolled > 0) throw;
        _;
    }
    //检测下注点数是否合法
    modifier onlyRollNumberValid(uint rollNumber) {
        require(rollNumber < 100, "roll number invalid");
        require(rollNumber > 0, "roll number invalid");
        _;
    }

    //CONSTANT HELPER FUNCTIONS

    function getBankroll()
        view
        public
        returns(uint) {

        if (_bankRoll + investorsProfit <= investorsLosses) {
            return 0;
        }
        else {
            return _bankRoll + investorsProfit - investorsLosses;
        }
        //return _bankRoll;
    }

    function getStatus()
        view
        external
        returns(uint, uint, uint, uint, uint, uint) {

        uint bankroll = getBankroll();
        //uint minInvestment = getMinInvestment();
        return (bankroll, edge, maxWin, minBet, (investorsProfit - investorsLosses), betsCount);
    }

    function getBet(uint id)
        public
        view
        returns(address, uint, uint, uint, uint, uint) {

        if (id < betsCount) {
            return (betsInfo[id].playerAddress, betsInfo[id].amountBet, betsInfo[id].betNumber,  betsInfo[id].numberRolled, betsInfo[id].winAmount,  betsInfo[id].betTime);
        }
    }

    function getBetKey(uint id)
        public
        view
        returns(bytes32) {

        if (id < betsCount) {
            return (betsInfo[id].myid);
        }
    }

    function numBets()
        view
        public
        returns(uint) {

        return betsCount;
    }

    function getBetReward(uint betNumber, uint betAmount) 
        view
        public
        returns(uint, uint, uint) 
    {
        uint oraclizeFee = OraclizeI(OAR.getAddress()).getPrice("URL", ORACLIZE_GAS_LIMIT + safeGas);
        uint realBet = betAmount;
        uint winAmount = ((realBet * (10000 - edge)) / (betNumber * 100)) - oraclizeFee ;
        return (winAmount, realBet, oraclizeFee);
    }

    function OraclizeIFee() 
        view
        public
        returns(uint) 
    {
        return OraclizeI(OAR.getAddress()).getPrice("URL", ORACLIZE_GAS_LIMIT + safeGas);
    }

    function getMinBetAmount()
        view
        public
        returns(uint) {

        uint oraclizeFee = OraclizeI(OAR.getAddress()).getPrice("URL", ORACLIZE_GAS_LIMIT + safeGas);
        return oraclizeFee + minBet;
    }

    function getMaxBetAmount(uint256 withNumber)
        view
        public
        returns(uint) {
        uint betNumber = withNumber * 100;
        uint oraclizeFee = OraclizeI(OAR.getAddress()).getPrice("URL", ORACLIZE_GAS_LIMIT + safeGas);
        uint betValue =  (maxWin * getBankroll()) * betNumber / (10000 * (10000 - edge - betNumber));
        return betValue + oraclizeFee;
    }


    function changeOraclizeProofType(byte _proofType)
        onlyOwner 
        public {

        require(_proofType != 0x00, "_proofType is 0x00");
        //if (_proofType == 0x00) throw;
        oraclize_setProof( _proofType |  proofStorage_IPFS );
    }

    function changeOraclizeConfig(bytes32 _config)
        onlyOwner 
        public {

        oraclize_setConfig(_config);
    }

    // PRIVATE HELPERS FUNCTION

    function safeSend(address addr, uint value)
        private {

        if (value == 0) {
            emit LOG_ZeroSend();
            return;
        }

        if (this.balance < value) {
            emit LOG_ValueIsTooBig();
            return;
        }
        //发送资金
        if (!(addr.call.gas(safeGas).value(value)())) {
            emit LOG_FailedSend(addr, value);
            if (addr != houseAddress) {
                
                if (!(houseAddress.call.gas(safeGas).value(value)())) LOG_FailedSend(houseAddress, value);
            }
        }

        emit LOG_SuccessfulSend(addr,value);
    }

    // SECTION II: BET & BET PROCESSING

    function()
        payable 
        public {

        bet(5, 0);
    }

    function bet(uint256 betNumber, uint affCode)
        payable
        onlyIfNotStopped 
        onlyRollNumberValid(betNumber) {

        uint256 betNumberHigh = betNumber * 100;
        uint oraclizeFee = OraclizeI(OAR.getAddress()).getPrice("URL", ORACLIZE_GAS_LIMIT + safeGas);
        require(oraclizeFee < msg.value, "msg.value can not pay for oraclizeFee");
        //if (oraclizeFee >= msg.value) throw;
        uint betValue = msg.value;

        uint pID = PlayerBook.getPlayerID(msg.sender, affCode);
        if ((((betValue * ((10000 - edge) - betNumberHigh)) / betNumberHigh ) <= (maxWin * getBankroll()) / 10000) && (betValue >= minBet)) {

            string memory str1 = "[URL] ['json(https://api.random.org/json-rpc/1/invoke).result.random.data.0', '\\n{\"jsonrpc\":\"2.0\",\"method\":\"generateSignedIntegers\",\"params\":{\"apiKey\":\"";
            string memory str2 = randomOrgAPIKey;
            string memory str3 = "\",\"n\":1,\"min\":1,\"max\":10000${[identity] \"}\"},\"id\":1${[identity] \"}\"}']";
            string memory query = strConcat(str1, str2, str3);

            bytes32 myid =
                oraclize_query(
                    "nested",
                    query,
                    ORACLIZE_GAS_LIMIT + safeGas
                );
            uint laff = PlayerBook.getPlayerLAff(pID);
            bets[myid] = Bet(msg.sender, betNumberHigh, betValue, 0, laff, now, 0, myid);
            betsKeys.push(myid);
            emit LOG_NewBet(msg.sender, betValue, myid);
        }
        else {
            revert("out of bank roll");
        }
    }

    function __callback(bytes32 myid, string result, bytes proof)
        onlyOraclize
        onlyIfBetExist(myid)
        onlyIfNotProcessed(myid)
        onlyIfValidRoll(myid, result)
        onlyIfBetSizeIsStillCorrect(myid) {

        uint numberRolled = parseInt(result);
        bets[myid].numberRolled = numberRolled;
        isWinningBet(bets[myid], numberRolled, bets[myid].betNumber);
        isLosingBet(bets[myid], numberRolled, bets[myid].betNumber);
    }

    function isWinningBet(Bet thisBet, uint numberRolled, uint betNumber)
        private
        onlyWinningBets(numberRolled, betNumber) {

        uint winAmount = (thisBet.amountBet * (10000 - edge)) / betNumber;

        uint oraclizeFee = OraclizeI(OAR.getAddress()).getPrice("URL", ORACLIZE_GAS_LIMIT + safeGas);
        winAmount = winAmount - oraclizeFee;

        emit LOG_BetWon(thisBet.playerAddress, numberRolled, winAmount, betsCount);

        safeSend(thisBet.playerAddress, winAmount);
        
        //统计
        thisBet.winAmount = winAmount;
        betsInfo[betsCount] = thisBet;
        PlayerBook.betXaddr(thisBet.playerAddress, thisBet.amountBet, true, betsCount, winAmount);

        //计算返现
        affReward(thisBet, betsCount);

        betsCount++;
        
        //Check for overflow and underflow
        if ((investorsLosses + winAmount < investorsLosses) ||
            (investorsLosses + winAmount < thisBet.amountBet)) {
                revert("error");
            }

        uint256 rLosses = winAmount - thisBet.amountBet;
        if(winAmount < thisBet.amountBet)
            rLosses = 0;

        investorsLosses += rLosses;
    }

    function isLosingBet(Bet thisBet, uint numberRolled, uint betNumber)
        private
        onlyLosingBets(numberRolled, betNumber) {

        emit LOG_BetLost(thisBet.playerAddress, numberRolled, betsCount);
        safeSend(thisBet.playerAddress, 1);


        betsInfo[betsCount] = thisBet;
        PlayerBook.betXaddr(thisBet.playerAddress, thisBet.amountBet, false, betsCount, 0);
        

        affReward(thisBet, betsCount);

        betsCount++;

        //Check for overflow and underflow
        if ((investorsProfit + thisBet.amountBet < investorsProfit) ||
            (investorsProfit + thisBet.amountBet < thisBet.amountBet) ||
            (thisBet.amountBet == 1)) {
                revert("error");
            }
        
        investorsProfit += thisBet.amountBet - 1;
    }

    function affReward(Bet thisBet, uint256 betID)
        private {
        
        if(thisBet.laff > 0)
        {
            uint laff_1_reward_max = thisBet.amountBet * edge / 10000;
            uint laff_1_reward = thisBet.amountBet * edge * dealer_level_1_reward / (10000 * 100);
            if(laff_1_reward >= dealerMinReward && laff_1_reward < laff_1_reward_max)
            {

                address laff_1_address = PlayerBook.getPlayerAddr(thisBet.laff);
                dealer_reward_total += laff_1_reward;
                safeSend(laff_1_address, laff_1_reward);
                PlayerBook.rewardXID(thisBet.laff, laff_1_reward, betID, 1);


                uint laff_2_pid = PlayerBook.getPlayerLAff(thisBet.laff);
                uint laff_2_reward = thisBet.amountBet * edge * dealer_level_2_reward / (10000 * 100);
                if(laff_2_pid>0 && laff_2_reward >= dealerMinReward && laff_2_reward < laff_1_reward_max)
                {

                    address laff_2_address = PlayerBook.getPlayerAddr(laff_2_pid);
                    dealer_reward_total += laff_2_reward;
                    safeSend(laff_2_address, laff_2_reward);
                    PlayerBook.rewardXID(laff_2_pid, laff_2_reward, betID, 2);
                }
                
            }
            
        }
    }

    //SECTION III: INVEST & DIVEST

    function increaseInvestment()
        external
        payable
        onlyIfNotStopped
        onlyMoreThanZero
        onlyOwner  {

        _bankRoll += msg.value;
        invest_amount += msg.value;
    }



    function divest(uint amount)
        external
        onlyOwner {

        //divest(msg.sender);
        require(address(this).balance >= amount, "Don't have enough balance");
        //require(_bankRoll > amount, "Don't have enough _bankRoll");

        _bankRoll = address(this).balance - amount;
        draw_amount += amount;
        safeSend(owner, amount);

        investorsProfit = 0;
        investorsLosses = 0;
        
    }

    //SECTION IV: CONTRACT MANAGEMENT

    function stopContract()
        external
        onlyOwner {

        isStopped = true;
        emit LOG_ContractStopped();
    }

    function resumeContract()
        external
        onlyOwner {

        isStopped = false;
        emit LOG_ContractResumed();
    }

    function changeHouseAddress(address newHouse)
        external
        onlyOwner {

        require(newHouse != address(0x0), "new Houst is 0x0");
        //if (newHouse == address(0x0)) throw; //changed based on audit feedback
        houseAddress = newHouse;
        emit LOG_HouseAddressChanged(houseAddress, newHouse);
    }

    function changeOwnerAddress(address newOwner)
        external
        onlyOwner {

        require(newOwner != address(0x0), "new owner is 0x0");
        // if (newOwner == address(0x0)) throw;
        owner = newOwner;
        emit LOG_OwnerAddressChanged(owner, newOwner);
    }

    /**
     * @dev prevents contracts from interacting with fomo3d 
     */
    modifier isHuman() {
        address _addr = msg.sender;
        uint256 _codeLength;
        
        assembly {_codeLength := extcodesize(_addr)}
        require(_codeLength == 0, "sorry humans only");
        _;
    }
    
    function regName(string name) 
        isHuman()
        public
        payable
    {
        bytes32 _name = name.nameFilter();
        address _addr = msg.sender;
        uint256 _paid = msg.value;
        PlayerBook.registerNameFromDapp.value(_paid)(_addr, _name);
    }

    function changeRandomOrgAPIKey(string newKey) 
        onlyOwner {

        string oldKey = randomOrgAPIKey;
        randomOrgAPIKey = newKey;
        LOG_RandomOrgAPIKeyChanged(oldKey, newKey);
    }

    function changeGasLimitOfSafeSend(uint newGasLimit)
        external
        onlyOwner
        onlyIfValidGas(newGasLimit) {

        safeGas = newGasLimit;
        emit LOG_GasLimitChanged(safeGas, newGasLimit);
    }

    //SECTION V: EMERGENCY WITHDRAWAL
    function receivePlayerInfo(uint256 _pID, address _addr, bytes32 _name, uint256 _laff) 
        external
    {
        require (msg.sender == address(PlayerBook), "your not playerNames contract... hmmm..");
    }
}


library NameFilter {
    /**
     * @dev filters name strings
     * -converts uppercase to lower case.  
     * -makes sure it does not start/end with a space
     * -makes sure it does not contain multiple spaces in a row
     * -cannot be only numbers
     * -cannot start with 0x 
     * -restricts characters to A-Z, a-z, 0-9, and space.
     * @return reprocessed string in bytes32 format
     */
    function nameFilter(string _input)
        internal
        pure
        returns(bytes32)
    {
        bytes memory _temp = bytes(_input);
        uint256 _length = _temp.length;
        
        //sorry limited to 32 characters
        require (_length <= 32 && _length > 0, "string must be between 1 and 32 characters");
        // make sure it doesnt start with or end with space
        require(_temp[0] != 0x20 && _temp[_length-1] != 0x20, "string cannot start or end with space");
        // make sure first two characters are not 0x
        if (_temp[0] == 0x30)
        {
            require(_temp[1] != 0x78, "string cannot start with 0x");
            require(_temp[1] != 0x58, "string cannot start with 0X");
        }
        
        // create a bool to track if we have a non number character
        bool _hasNonNumber;
        
        // convert & check
        for (uint256 i = 0; i < _length; i++)
        {
            // if its uppercase A-Z
            if (_temp[i] > 0x40 && _temp[i] < 0x5b)
            {
                // convert to lower case a-z
                _temp[i] = byte(uint(_temp[i]) + 32);
                
                // we have a non number
                if (_hasNonNumber == false)
                    _hasNonNumber = true;
            } else {
                require
                (
                    // require character is a space
                    _temp[i] == 0x20 || 
                    // OR lowercase a-z
                    (_temp[i] > 0x60 && _temp[i] < 0x7b) ||
                    // or 0-9
                    (_temp[i] > 0x2f && _temp[i] < 0x3a),
                    "string contains invalid characters"
                );
                // make sure theres not 2x spaces in a row
                if (_temp[i] == 0x20)
                    require( _temp[i+1] != 0x20, "string cannot contain consecutive spaces");
                
                // see if we have a character other than a number
                if (_hasNonNumber == false && (_temp[i] < 0x30 || _temp[i] > 0x39))
                    _hasNonNumber = true;    
            }
        }
        
        require(_hasNonNumber == true, "string cannot be only numbers");
        
        bytes32 _ret;
        assembly {
            _ret := mload(add(_temp, 32))
        }
        return (_ret);
    }
}