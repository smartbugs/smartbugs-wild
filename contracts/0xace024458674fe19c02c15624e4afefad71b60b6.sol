pragma solidity ^0.4.24;
// pragma experimental ABIEncoderV2;
/**
 * @title SafeMath
 * @dev Math operations with safety checks that revert on error
 */
library SafeMath {
    int256 constant private INT256_MIN = -2**255;

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
    * @dev Multiplies two signed integers, reverts on overflow.
    */
    function mul(int256 a, int256 b) internal pure returns (int256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
        if (a == 0) {
            return 0;
        }

        require(!(a == -1 && b == INT256_MIN)); // This is the only case of overflow not detected by the check below

        int256 c = a * b;
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
    * @dev Integer division of two signed integers truncating the quotient, reverts on division by zero.
    */
    function div(int256 a, int256 b) internal pure returns (int256) {
        require(b != 0); // Solidity only automatically asserts when dividing by 0
        require(!(b == -1 && a == INT256_MIN)); // This is the only case of overflow

        int256 c = a / b;

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
    * @dev Subtracts two signed integers, reverts on overflow.
    */
    function sub(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a - b;
        require((b >= 0 && c <= a) || (b < 0 && c > a));

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
    * @dev Adds two signed integers, reverts on overflow.
    */
    function add(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a + b;
        require((b >= 0 && c >= a) || (b < 0 && c < a));

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


library Helper {
    using SafeMath for uint256;
    
        
    function bytes32ToUint(bytes32 n) 
        public
        pure
        returns (uint256) 
    {
        return uint256(n);
    }
    
    function stringToBytes32(string memory source) 
        public
        pure
        returns (bytes32 result) 
    {
        bytes memory tempEmptyStringTest = bytes(source);
        if (tempEmptyStringTest.length == 0) {
            return 0x0;
        }

        assembly {
            result := mload(add(source, 32))
        }
    }
    
    function stringToUint(string memory source) 
        public
        pure
        returns (uint256)
    {
        return bytes32ToUint(stringToBytes32(source));
    }
    
    function validUsername(string _username)
        public
        pure
        returns(bool)
    {
        bytes memory b = bytes(_username);
        // Im Raum [4, 18]
        if ((b.length < 4) || (b.length > 18)) return false;
        // Letzte Char != ' '
        
        for(uint i; i<b.length; i++){
            bytes1 char = b[i];
            if(
                !(char >= 0x30 && char <= 0x39) &&
                !(char >= 0x41 && char <= 0x5A) //A-Z
            )
                return false;
        }
        
        if (b[0] >= 0x30 && b[0] <= 0x39) return false;
        
        return true;
    }   
}

interface DAAInterface {
    function citizenMintToken(address _buyer, uint256 _buyPrice, int8 _is_win) external returns(uint256);
    function transfer(address _to, uint256 _value) external returns(bool);
    function transferFrom(address _from, address _to, uint256 _tokenAmount) external returns(bool);
    function balanceOf(address _from) external returns(uint256);
    function currentRoundDividend() external;
    function getDividendView(address _sender) external returns(uint256);
    function getDividendPull(address _sender, uint256 _value) external returns(uint256);
    function payOut(address _winner, uint256 _unit, uint256 _value, uint256 _valuebet) external;
    function getCitizenBalanceEth(address _sender) external returns(uint256);
    function totalSupplyByAddress(address _sender) external returns(uint256);
}

interface TicketInterface{
    function getEarlyIncomePull(address _sender) external returns(uint256);
    function getEarlyIncomeView(address _sender, bool _current) external returns(uint256); 
    function getEarlyIncomeByRound(address _buyer, uint256 _round) external returns(uint256);
    function currentRound() external returns(uint256);
    function ticketSumByAddress(address _sender) external returns(uint256);
}

contract CitizenStorage{
    using SafeMath for uint256;
    
    address controller; 
    modifier onlyCoreContract() {
        require(msg.sender == controller, "admin required");
        _;
    }
    
    mapping (address => uint256) public citizenWinIncome;
    mapping (address => uint256) public citizenGameWinIncome;
    mapping (address => uint256) public citizenWithdrawed;
    
    function addWinIncome(address _citizen, uint256 _value) public onlyCoreContract() {
         citizenWinIncome[_citizen] = _value.add(citizenWinIncome[_citizen]);
         citizenWithdrawed[_citizen] = citizenWithdrawed[_citizen].add(_value);
    }
    function addGameWinIncome(address _citizen, uint256 _value, bool _enough) public onlyCoreContract() {
        citizenGameWinIncome[_citizen] = _value.add(citizenGameWinIncome[_citizen]);
        if (_enough){
            citizenWithdrawed[_citizen] = citizenWithdrawed[_citizen].add(_value);
        }
    }
    function pushCitizenWithdrawed(address _sender, uint256 _value) public onlyCoreContract(){
        citizenWithdrawed[_sender] = citizenWithdrawed[_sender].add(_value);
    }
    constructor (address _contract)
        public
    {
        require(controller== 0x0, "require setup");
        controller = _contract;
    }
}

contract Citizen{
    using SafeMath for uint256;
    
    // event Register(uint256 id, uint256 username, address indexed citizen, address indexed ref,
    //                 uint256 ticket, uint256 ticketSpend, uint256 totalGameSpend, uint256 totalMined,
    //                 uint256 dateJoin, uint256 totalWithdraw);
                    
    event Register(uint256 id, uint256 username, address indexed citizen, address indexed ref, uint256 ticketSpend, uint256 totalGameSpend, uint256 dateJoin);
    modifier onlyAdmin() {
        require(msg.sender == devTeam1, "admin required");
        _;
    }
    
    modifier onlyCoreContract() {
        require(isCoreContract[msg.sender], "admin required");
        _;
    }

    modifier notRegistered(){
        require(!isCitizen[msg.sender], "already exist");
        _;
    }

    modifier registered(){
        require(isCitizen[msg.sender], "must be a citizen");
        _;
    }
    
    uint8[10] public TICKET_LEVEL_REF = [uint8(60),40,20,10,10,10,5,5,5,5];// 3 demical
    uint8[10] public GAME_LEVEL_REF = [uint8(5),2,1,1,1,1,1,1,1,1];// 3 demical
    
    
    struct Profile{
        uint256 id;
        uint256 username;
        address ref;
        mapping(uint => address[]) refTo;
        mapping(address => uint256) payOut;
        uint256 totalChild;
        uint256 treeLevel;
        
        uint256 citizenBalanceEth;
        uint256 citizenBalanceEthBackup;
        
        uint256 citizenTicketSpend;
        uint256 citizenGameEthSpend;
        uint256 citizenGameTokenSpend;
        
        
        uint256 citizenEarlyIncomeRevenue;
        uint256 citizenTicketRevenue;
        uint256 citizenGameEthRevenue;
        uint256 citizenGameTokenRevenue;
    }


    
    mapping (address => uint256) public citizenEthDividend;

    address[21] public mostTotalSpender;
    mapping (address => uint256) public mostTotalSpenderId;
    mapping (address => mapping(uint256 => uint256)) public payOutByLevel;
    
    mapping (address => Profile) public citizen;
    mapping (address => bool) public isCitizen;
    mapping (uint256 => address) public idAddress;
    mapping (uint256 => address) public usernameAddress;
    mapping (uint256 => address[]) public levelCitizen;


    address devTeam1; 
    address devTeam2; 
    address devTeam3; 
    address devTeam4;
    
    uint256 public citizenNr;
    uint256 lastLevel;
    
    uint256 earlyIncomeBalanceEth;
    
    DAAInterface public DAAContract;
    TicketInterface public TicketContract;
    CitizenStorage public CitizenStorageContract;
    mapping (address => bool) public isCoreContract;
    uint256 public coreContractSum;
    address[] public coreContracts;
    

    constructor (address[4] _devTeam)
        public
    {
        devTeam1 = _devTeam[0];
        devTeam2 = _devTeam[1];
        devTeam3 = _devTeam[2];
        devTeam4 = _devTeam[3];

        // first citizen is the development team
        citizenNr = 1;
        idAddress[1] = devTeam3;
        isCitizen[devTeam3] = true;
        //root => self ref
        citizen[devTeam3].ref = devTeam3;
        // username rules bypass
        uint256 _username = Helper.stringToUint("GLOBAL");
        citizen[devTeam3].username = _username;
        usernameAddress[_username] = devTeam3; 
        citizen[devTeam3].id = 1;
        citizen[devTeam3].treeLevel = 1;
        levelCitizen[1].push(devTeam3);
        lastLevel = 1;
    }
    
    // DAAContract, TicketContract, CitizenContract, CitizenStorage 
    function joinNetwork(address[4] _contract)
        public
    {
        require(address(DAAContract) == 0x0,"already setup");
        DAAContract = DAAInterface(_contract[0]);
        TicketContract = TicketInterface(_contract[1]);
        CitizenStorageContract = CitizenStorage(_contract[3]);
        for(uint256 i =0; i<3; i++){
            isCoreContract[_contract[i]]=true;
            coreContracts.push(_contract[i]);
        }
        coreContractSum = 3;
    }

    function updateTotalChild(address _address)
        private
    {
        address _member = _address;
        while(_member != devTeam3) {
            _member = getRef(_member);
            citizen[_member].totalChild ++;
        }
    }
    
    function addCoreContract(address _address) public  // [dev1]
        onlyAdmin()
    {
        require(_address!=0x0,"Invalid address");
        isCoreContract[_address] = true;
        coreContracts.push(_address);
        coreContractSum+=1;
    }
    
    function updateRefTo(address _address) private {
        address _member = _address;
        uint256 level =1;
        while (_member != devTeam3 && level<11){
            _member = getRef(_member);
            citizen[_member].refTo[level].push(_address);
            level = level+1;
        }
    }

    function register(string _sUsername, address _ref)
        public
        notRegistered()
    {
        require(Helper.validUsername(_sUsername), "invalid username");
        address sender = msg.sender;
        uint256 _username = Helper.stringToUint(_sUsername);
        require(usernameAddress[_username] == 0x0, "username already exist");
        usernameAddress[_username] = sender;
        //ref must be a citizen, else ref = devTeam
        address validRef = isCitizen[_ref] ? _ref : devTeam3;

        //Welcome new Citizen
        isCitizen[sender] = true;
        citizen[sender].username = _username;
        citizen[sender].ref = validRef;
        citizenNr++;

        idAddress[citizenNr] = sender;
        citizen[sender].id = citizenNr;
        
        uint256 refLevel = citizen[validRef].treeLevel;
        if (refLevel == lastLevel) lastLevel++;
        citizen[sender].treeLevel = refLevel + 1;
        levelCitizen[refLevel + 1].push(sender);
        //add child
        updateRefTo(sender);
        updateTotalChild(sender);
        emit Register(citizenNr,_username, sender, validRef, citizen[sender].citizenTicketSpend, citizen[sender].citizenGameEthSpend, now);
    }
    
    // function updateUsername(string _sNewUsername)
    //     public
    //     registered()
    // {
    //     require(Helper.validUsername(_sNewUsername), "invalid username");
    //     address sender = msg.sender;
    //     uint256 _newUsername = Helper.stringToUint(_sNewUsername);
    //     require(usernameAddress[_newUsername] == 0x0, "username already exist");
    //     uint256 _oldUsername = citizen[sender].username;
    //     citizen[sender].username = _newUsername;
    //     usernameAddress[_oldUsername] = 0x0;
    //     usernameAddress[_newUsername] = sender;
    // }

    function getRef(address _address)
        public
        view
        returns (address)
    {
        return citizen[_address].ref == 0x0 ? devTeam3 : citizen[_address].ref;
    }
    
    function getUsername(address _address)
        public
        view
        returns (uint256)
    {
        return citizen[_address].username;
    }
    
    function isDev() public view returns(bool){
        if (msg.sender == devTeam1) return true;
        return false;
    }
    
    function getAddressById(uint256 _id)
        public
        view
        returns (address)
    {
        return idAddress[_id];
    }

    function getAddressByUserName(string _username)
        public
        view
        returns (address)
    {
        return usernameAddress[Helper.stringToUint(_username)];
    }
    
    function pushTicketRefIncome(address _sender)
        public
        payable
        onlyCoreContract() 
    {
        uint256 _amount = msg.value; // 17%
        _amount = _amount.div(170);
        address sender = _sender;
        address ref = getRef(sender);
        uint256 money;
        uint8 level;
        
        for (level=0; level<10; level++){
            money = _amount.mul(TICKET_LEVEL_REF[level]);
            citizen[ref].citizenBalanceEth = money.add(citizen[ref].citizenBalanceEth);
            citizen[ref].citizenTicketRevenue = money.add(citizen[ref].citizenTicketRevenue);
            citizen[ref].payOut[_sender] = money.add(citizen[ref].payOut[_sender]);
            payOutByLevel[ref][level+1] = money.add(payOutByLevel[ref][level+1]);
            sender = ref;
            ref = getRef(sender);
        }
    }    
    
    function pushGametRefIncome(address _sender)
        public
        payable
        onlyCoreContract() 
    {
        uint256 _amount =  msg.value; // 1.5%
        _amount = _amount.div(15);
        address sender = _sender;
        address ref = getRef(sender);
        uint256 level;
        uint256 money;
        uint256 forDaa;
        for (level=0; level<10; level++){
            forDaa=0;
            money = _amount.mul(GAME_LEVEL_REF[level]);
            if (citizen[ref].citizenGameEthRevenue<citizen[ref].citizenGameEthSpend.div(10)){
                if (citizen[ref].citizenGameEthRevenue+money>citizen[ref].citizenGameEthSpend.div(10)){
                    forDaa = citizen[ref].citizenGameEthRevenue+money-citizen[ref].citizenGameEthSpend.div(10);
                    money = money.sub(forDaa);
                }
            } else {
                forDaa = money;
                money = 0;
            }
            
            citizen[ref].citizenBalanceEth = money.add(citizen[ref].citizenBalanceEth);
            citizen[ref].citizenGameEthRevenue = money.add(citizen[ref].citizenGameEthRevenue);
            citizen[ref].payOut[_sender] = money.add(citizen[ref].payOut[_sender]);
            payOutByLevel[ref][level+1] = money.add(payOutByLevel[ref][level+1]);
            
            citizen[devTeam3].citizenBalanceEth = forDaa.add(citizen[devTeam3].citizenBalanceEth);
            citizen[devTeam3].citizenGameEthRevenue = forDaa.add(citizen[devTeam3].citizenGameEthRevenue);
            
            sender = ref;
            ref = getRef(sender);
        }
    }    
    function pushGametRefIncomeToken(address _sender, uint256 _amount)
        public
        payable
        onlyCoreContract() 
    {
        _amount = _amount.div(15);
        address sender = _sender;
        address ref = getRef(sender);
        uint256 level;
        uint256 money;
        uint256 forDaa;
        
        for (level=0; level<10; level++){
            forDaa=0;
            money = _amount.mul(GAME_LEVEL_REF[level]);
            if (citizen[ref].citizenGameTokenRevenue<citizen[ref].citizenGameTokenSpend.div(10)){
                if (citizen[ref].citizenGameTokenRevenue+money>citizen[ref].citizenGameTokenSpend.div(10)){
                    forDaa = citizen[ref].citizenGameTokenRevenue+money-citizen[ref].citizenGameTokenSpend.div(10);
                    money = money.sub(forDaa);
                }
            } else {
                forDaa = money;
                money = 0;
            }
            
            DAAContract.payOut(ref,1,money,0);
            citizen[ref].citizenGameTokenRevenue=money.add(citizen[ref].citizenGameTokenRevenue);
            
            DAAContract.payOut(devTeam3,1,forDaa,0);
            citizen[devTeam3].citizenGameTokenRevenue = forDaa.add(citizen[devTeam3].citizenGameTokenRevenue);
            
            sender = ref;
            ref = getRef(sender);
        }
    }
    
    function pushEarlyIncome() public payable{
        uint256 _value = msg.value;
        earlyIncomeBalanceEth = earlyIncomeBalanceEth.add(_value);
    }
    
    function sortMostSpend(address _citizen) private {
        uint256 citizen_spender = getTotalSpend(_citizen);
        uint256 i=1;
        while (i<21) {
            if (mostTotalSpender[i]==0x0||(mostTotalSpender[i]!=0x0&&getTotalSpend(mostTotalSpender[i])<citizen_spender)){
                if (mostTotalSpenderId[_citizen]!=0&&mostTotalSpenderId[_citizen]<i){
                    break;
                }
                if (mostTotalSpenderId[_citizen]!=0){
                    mostTotalSpender[mostTotalSpenderId[_citizen]]=0x0;
                }
                address temp1 = mostTotalSpender[i];
                address temp2;
                uint256 j=i+1;
                while (j<21&&temp1!=0x0){
                    temp2 = mostTotalSpender[j];
                    mostTotalSpender[j]=temp1;
                    mostTotalSpenderId[temp1]=j;
                    temp1 = temp2;
                    j++;
                }
                mostTotalSpender[i]=_citizen;
                mostTotalSpenderId[_citizen]=i;
                break;
            }
            i++;
        }
    }
    
    function addTicketEthSpend(address _citizen, uint256 _value) onlyCoreContract() public {
        citizen[_citizen].citizenTicketSpend = citizen[_citizen].citizenTicketSpend.add(_value);
        DAAContract.citizenMintToken(_citizen,_value,0);// buy ticket 0, win 1, lose -1;
        sortMostSpend(_citizen);
    }   
    
    // Game spend 
    function addGameEthSpendWin(address _citizen, uint256 _value, uint256 _valuewin, bool _enough) onlyCoreContract() public {
        citizen[_citizen].citizenGameEthSpend = citizen[_citizen].citizenGameEthSpend.add(_value);
        // DAAContract.citizenMintToken(_citizen,_value,1);// buy ticket 0, win 1, lose -1;
        CitizenStorageContract.addGameWinIncome(_citizen, _valuewin, _enough);
        sortMostSpend(_citizen);
    }     
    function addGameEthSpendLose(address _citizen, uint256 _value) onlyCoreContract() public {
        citizen[_citizen].citizenGameEthSpend = citizen[_citizen].citizenGameEthSpend.add(_value);
        DAAContract.citizenMintToken(_citizen,_value,-1);// buy ticket 0, win 1, lose -1;
        sortMostSpend(_citizen);
    }    
    function addGameTokenSpend(address _citizen, uint256 _value) onlyCoreContract() public {
        citizen[_citizen].citizenGameTokenSpend = citizen[_citizen].citizenGameTokenSpend.add(_value);
    }
    
    function withdrawEth() public registered() {
        address _sender = msg.sender;
        uint256 _earlyIncome = TicketContract.getEarlyIncomePull(_sender);
        uint256 _devidend = DAAContract.getDividendView(msg.sender);
        uint256 _citizenBalanceEth = citizen[_sender].citizenBalanceEth;
        uint256 _total = _earlyIncome.add(_devidend).add(_citizenBalanceEth).add(DAAContract.getCitizenBalanceEth(_sender));
        require(_total>0,"Balance none");
        CitizenStorageContract.pushCitizenWithdrawed(_sender,_total);
        DAAContract.getDividendPull(_sender,_citizenBalanceEth+_earlyIncome);
        _sender.transfer(_citizenBalanceEth+_earlyIncome);
        citizen[_sender].citizenBalanceEthBackup = citizen[_sender].citizenBalanceEthBackup.add(_citizenBalanceEth).add(_earlyIncome).add(_devidend);
        citizen[_sender].citizenEarlyIncomeRevenue = citizen[_sender].citizenEarlyIncomeRevenue.add(_earlyIncome);
        citizenEthDividend[_sender] = citizenEthDividend[_sender].add(_devidend);
        earlyIncomeBalanceEth= earlyIncomeBalanceEth.sub(_earlyIncome);
        citizen[_sender].citizenBalanceEth = 0;
    }
    
    function addWinIncome(address _citizen, uint256 _value)  onlyCoreContract()  public {
        CitizenStorageContract.addWinIncome(_citizen, _value); 
    }
    // function addGameWinIncome(address _citizen, uint256 _value, bool _enough) public {
    //     CitizenStorageContract.addGameWinIncome(_citizen, _value, _enough);
    // }
    
    // function getInWallet() public view returns (uint256){
    //     uint256 _sum;
    //     address _sender = msg.sender;
    //     _sum = _sum.add(citizen[_sender].citizenBalanceEth);
    //     _sum = _sum.add(TicketContract.getEarlyIncomeView(_sender));
    //     _sum = _sum.add(DAAContract.getDividendView(_sender));
    //     _sum = _sum.add(DAAContract.getCitizenBalanceEth(_sender));
    //     return _sum;
    // }  
    
    function getTotalEth() public registered() view returns(uint256){
        uint256 _sum;
        address _sender = msg.sender;
        _sum = _sum.add(citizen[_sender].citizenBalanceEth);
        _sum = _sum.add(citizen[_sender].citizenBalanceEthBackup);
        _sum = _sum.add(CitizenStorageContract.citizenWinIncome(_sender));
        _sum = _sum.add(TicketContract.getEarlyIncomeView(_sender, false));
        _sum = _sum.add(DAAContract.getDividendView(_sender));
        return _sum;
    }
    
    function getTotalDividend(address _sender) public registered() view returns(uint256){
        return citizenEthDividend[_sender].add(DAAContract.getDividendView(_sender));
    }
    
    function getTotalEarlyIncome(address _sender) public registered() view returns(uint256){
        uint256 _sum;
        _sum = citizen[_sender].citizenEarlyIncomeRevenue;
        _sum = _sum.add(TicketContract.getEarlyIncomeView(_sender, true));
        return _sum;
    }
    
    function getTotalSpend(address _sender) public view returns(uint256){
        return citizen[_sender].citizenGameEthSpend+citizen[_sender].citizenTicketSpend;
    }
    
    function getMemberByLevelToTal(uint256 _level) public view returns(uint256, uint256){
        address _sender = msg.sender;
        return(citizen[_sender].refTo[_level].length,payOutByLevel[_sender][_level]);
    }
    
    function getMemberByLevel(uint256 _level, address _sender, uint256 _id) public view returns(address){
        return citizen[_sender].refTo[_level][_id];
    }
    
    function citizenPayForRef(address _citizen, address _ref) public view returns(uint256){
        return citizen[_ref].payOut[_citizen];
    }
}