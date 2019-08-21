pragma solidity ^0.4.17;

/// @title Manages special access privileges of BankCore.
/*** LoveBankAccessControl Contract adapted from CryptoKitty ***/
contract LoveBankAccessControl {

    // This facet controls access control for LoveBank. There are four roles managed here:
    //
    //     - The CEO: The CEO can reassign other roles and change the addresses of our dependent smart
    //         contracts. It is also the only role that can unpause the smart contract. It is initially
    //         set to the address that created the smart contract in the BankCore constructor.
    //
    //     - The CFO: The CFO can withdraw funds from BankCore contract.
    //
    //     - The COO: The COO can set Free-Fee-Time.
    //
    // It should be noted that these roles are distinct without overlap in their access abilities, the
    // abilities listed for each role above are exhaustive. In particular, while the CEO can assign any
    // address to any role, the CEO address itself doesn't have the ability to act in those roles. This
    // restriction is intentional so that we aren't tempted to use the CEO address frequently out of
    // convenience. The less we use an address, the less likely it is that we somehow compromise the
    // account.

    /// @dev Emited when contract is upgraded
    event ContractUpgrade(address newVerseContract);

    // The addresses of the accounts (or contracts) that can execute actions within each roles.
    address public ceoAddress;
    address public cfoAddress;
    address public cooAddress;

    // @dev Keeps track whether the contract is paused. When that is true, most actions are blocked
    bool public paused=false;

    /// @dev Access modifier for CEO-only functionality
    modifier onlyCEO() {
        require(msg.sender == ceoAddress);
        _;
    }

    /// @dev Access modifier for CFO-only functionality
    modifier onlyCFO() {
        require(msg.sender == cfoAddress);
        _;
    }

    /// @dev Access modifier for COO-only functionality
    modifier onlyCOO() {
        require(msg.sender == cooAddress);
        _;
    }

    modifier onlyCLevel() {
        require(
            msg.sender == cooAddress ||
            msg.sender == ceoAddress ||
            msg.sender == cfoAddress
        );
        _;
    }
    
    /// @dev Assigns a new address to act as the CEO. Only available to the current CEO.
    /// @param _newCEO is the address of the new CEO
    function setCEO(address _newCEO) external onlyCEO {
        require(_newCEO != address(0));
        ceoAddress = _newCEO;
    }

    /// @dev Assigns a new address to act as the CFO. Only available to the current CEO.
    /// @param _newCFO is the address of the new CFO
    function setCFO(address _newCFO) external onlyCEO {
        require(_newCFO != address(0));
        cfoAddress = _newCFO;
    }

    /// @dev Assigns a new address to act as the COO. Only available to the current CEO.
    /// @param _newCOO is the address of the new COO
    function setCOO(address _newCOO) external onlyCEO {
        require(_newCOO != address(0));
        cooAddress = _newCOO;
    }
    
    /*** Pausable functionality adapted from OpenZeppelin ***/

    /// @dev Modifier to allow actions only when the contract IS NOT paused
    modifier whenNotPaused() {
        require(!paused);
        _;
    }

    /// @dev Modifier to allow actions only when the contract IS paused
    modifier whenPaused() {
        require(paused);
        _;
    }

    /// @dev Called by any "C-level" role to pause the contract. Used only when
    ///  a bug or exploit is detected and we need to limit damage.
    function pause() external onlyCLevel whenNotPaused {
        paused = true;
    }

    /// @dev Unpauses the smart contract. Can only be called by the CEO, since
    ///  one reason we may pause the contract is when CFO or COO accounts are
    ///  compromised.
    /// @notice This is public rather than external so it can be called by
    ///  derived contracts.
    function unpause() public onlyCEO whenPaused {
        // can't unpause if contract was upgraded
        paused = false;
    }
}

/// @title Love Account Base Contract for LoveBank. Holds all common structs, events and base 
///  variables for love accounts.
/// @author Diana Kudrow <https://github.com/lovebankcrypto>
/// @dev Create new account by couple ,deposit or bless by all, withdraw with both sides' confirmation

contract LoveAccountBase{

    // An individual new contrat is build whenever a new couple create a new love account through the 
    // BankCore Contract. The love account contract plays seceral roles:
    //
    //     - Information Storage: owners names, wallet addresses, love-ID, their milestones in 
    //        relationship, diary……
    //
    //     - Balance Storage: each account keep their deposit in seperate contrat for safety and 
    //        privilege concern
    //
    //     - Access Control: only receive message from one of owners, triggered by bank for safety 
    //        reason
    //     
    //     - Deposit/Bless(fallback), Withdraw, BreakUp, MileStone, Diary: 5 main function of our 
    //        love bank

    /*** EVENTS ***/
    
    /// @dev The Deposit event is fired whenever a value>0 ether is transfered into loveaccount
    event Deposit(address _from, uint _value);
    
    /*** DATA TYPES ***/
    /// @dev choices of all account status and milestones
    enum Status{BreakUp, Active, RequestPending, FirstMet,  //0-3
        FirstKiss, FirstConfess, InRelationship,FirstDate, //4-7
        Proposal, Engage, WeddingDay, Anniversary, Trip,  //8-12
        NewFamilyMember, FirstSex, Birthday,             //13-15
        special1, special2, special3                  // 16-18
    }

    struct StonePage {
    	uint64 logtime;
    	Status contant;
    }

    struct DiaryPage {
    	uint64 logtime;
    	bytes contant;
    }

    /*** STORAGE ***/
    
    /// @dev Nicename of the FOUNDER of this love account
    bytes32 public name1;

    /// @dev Nicename of the FOUNDER's lover
    bytes32 public name2;

    /// @dev Address of the FOUNDER of this love account
    address public owner1;

    /// @dev Address of the FOUNDER's lover
    address public owner2;

    /// @dev contract address of Love Bank, for access control
    address BANKACCOUNT;

    /// @dev Keep track of who is withdrawing money during double-sig pending time
    address withdrawer;

    /// @dev Keep track of how much is withdrawing money during double-sig pending time
    uint256 request_amount;

    /// @dev Keep track of service charge during double-sig pending time
    uint256 request_fee;

    /// @dev One and unique LoveID of this account, smaller if sign up early
    uint64 public loveID;

    /// @dev Time stamp of found moment
    uint64 public foundTime=uint64(now);

    /// @dev diary index log, public
    uint64 public next_diary_id=0;

    /// @dev milestone index log, public
    uint64 public next_stone_id=0;

    /// @dev Status of the account: BreakUp, Active(defult), RequestPending
    Status public status=Status.Active;
    
    /// @dev A mapping from timestamp to Status. Keep track of all Memory Moment for lovers
    mapping (uint64=>StonePage) public milestone;

    /// @dev A mapping from timestamp to bytes. Lovers can keep whatever words on ethereum eternally
    mapping (uint64=>DiaryPage) public diary;

    /// @dev Initiate love account when first found
    function LoveAccountBase (
        bytes32 _name1,
        bytes32 _name2,
        address _address1,
        address _address2,
        uint64 _loveID) public {
            name1 = _name1;
            name2 = _name2;
            owner1 = _address1;
            owner2 = _address2;
            loveID = _loveID;
            BANKACCOUNT = msg.sender;
    }
    /// @dev Modifier to allow actions only when the account is not Breakup
    modifier notBreakup() {require(uint(status)!=0);_;}

    /// @dev Modifier to allow actions only when the call was sent by one of owners
    modifier oneOfOwners(address _address) {
        require (_address==owner1 || _address==owner2);_;
    }

    /// @dev Modifier to allow actions only when message sender is Bank
    modifier callByBank() {require(msg.sender == BANKACCOUNT);_;}
    
    /// @dev Rarely used! Only happen when extreme circumstances
    function changeBankAccount(address newBank) external callByBank{
        require(newBank!=address(0));
        BANKACCOUNT = newBank;
    }

    /// @dev THINK TWICE! If you breakup with your lover, all your balance will transfer to your
    ///  lover's account, AND you cannot re-activate this very account! Think about your sweet
    ///  moments before you hurt someone's heart!!
    function breakup(
        address _breaker, uint256 _fee) external payable 
        notBreakup oneOfOwners(_breaker) callByBank{
        if(_fee!=0){BankCore(BANKACCOUNT).receiveFee.value(_fee)();}
        if(_breaker==owner1) {owner2.transfer(this.balance);}
        if(_breaker==owner2) {owner1.transfer(this.balance);}
        status=Status.BreakUp;
    }
    
    /// @dev Log withdraw info when first receice request 
    function withdraw(uint256 amount, 
        address _to, uint256 _fee) external notBreakup oneOfOwners(_to) callByBank{
        require(this.balance>=amount);
        // change status to pending
        status =Status.RequestPending;
        request_amount = amount;
        withdrawer = _to;
        request_fee = _fee;
    }

    /// @dev Confirm request and send money; erase info logs
    function withdrawConfirm(
        uint256 _amount, 
        address _confirmer) external payable notBreakup oneOfOwners(_confirmer) callByBank{
        // check for matching withdraw request
        require(uint(status)==2);
        require(_amount==request_amount);
        require(_confirmer!=withdrawer);
        require(this.balance>=request_amount);
        
        // send service fee to bank
        if(request_fee!=0){BankCore(BANKACCOUNT).receiveFee.value(request_fee)();}
        withdrawer.transfer(request_amount-request_fee);

        // clean pending log informations
        status=Status.Active;
        withdrawer=address(0);
        request_amount=0;
        request_fee=0;
    }
    
    /// @dev Log big events(pre-set-choice) in relationship, time stamp is required
    function mileStone(address _sender, uint64 _time, uint8 _choice) external notBreakup oneOfOwners(_sender) callByBank {
        milestone[next_stone_id]=StonePage({
        	logtime: _time,
        	contant: Status(_choice)
        });
        next_stone_id++;
    }

    /// @dev Log diary, time stamp is now
    function Diary(address _sender, bytes _diary) external notBreakup oneOfOwners(_sender) callByBank {
        diary[next_diary_id]=DiaryPage({
        	logtime: uint64(now),
        	contant: _diary
        });
        next_diary_id++;  
    }
    
    // @dev Fallback function for deposit and blessing income
    function() external payable notBreakup {
        require(msg.value>0);
        Deposit(msg.sender, msg.value);
    }
}


/// @title Basic contract of LoveBank that defines the Creating, Saving, and Using of love 
/// accounts under the protect of one Bank contract.
/// @author Diana Kudrow <https://github.com/lovebankcrypto>
contract Bank is LoveBankAccessControl{

    /*** EVENTS ***/

    /// @dev Create event is fired whenever a new love account is created, and a new contract
    ///  address is created 
    event Create(bytes32 _name1, bytes32 _name2, address _conadd, 
                address _address1, address _address2, uint64 _loveID);
    /// @dev Breakup event is fired when someone breakup with another
    event Breakup(uint _time);
    /// @dev StoneLog event returns when love account log a milestone
    event StoneLog(uint _time, uint _choice);
    /// @dev DiaryLog event returns when love account log a diary
    event DiaryLog(uint _time, bytes _contant);
    /// @dev Withdraw event returns when a user trigger a withdrow demand
    event Withdraw(uint _amount, uint _endTime);
    /// @dev WithdrawConfirm event returns when a withdraw demand is confirmed and accomplished
    event WithdrawConfirm(uint _amount, uint _confirmTime);

    /*** DATA TYPES ***/
    
    struct pending {
        bool pending;
        address withdrawer;
        uint256 amount;
        uint256 fee;
        uint64 endTime;
    }

    /*** CONSTANTS ***/

    /// @dev constant variables
    uint256 STONE_FEE=4000000000000000;
    uint256 OPEN_FEE=20000000000000000;
    uint64 FREE_START=0;
    uint64 FREE_END=0;
    uint64 WD_FEE_VERSE=100;  // 1% service fee
    uint64 BU_FEE_VERSE=50;   // 2% service fee
    uint32 public CONFIRM_LIMIT = 900; //15mins

    /*** STORAGE ***/

    /// @dev The ID of the next signing couple, also the number of current signed accounts
    uint64 public next_id=0; 
    /// @dev A mapping from owers addresses' sha256 to love account address
    mapping (bytes16 => address)  public sig_to_add;
    /// @dev A mapping from love account address to withdraw demand detail
    mapping (address => pending) public pendingList;
    
    /// @dev Create a new love account and log in Bank
    /// @param name1 is nicename of the FOUNDER of this love account
    /// @param name2 is nicename of the FOUNDER's lover
    /// @param address1 is address of the FOUNDER of this love account, need to be msg.sender
    /// @param address2 is address of the FOUNDER's lover
    function createAccount(
        bytes32 name1,
        bytes32 name2,
        address address1,
        address address2) external payable whenNotPaused {
        uint fee;
        // calculate open account service fee
        if (_ifFree()){fee=0;} else{fee=OPEN_FEE;}
        require(msg.sender==address1   &&
                address1!=address2     && 
                address1!=address(0)   &&
                address2!=address(0)   &&
                msg.value>=fee);
        require(_ifFree() || msg.value >= OPEN_FEE);
        // Same couple can only created love account once. Addresses' keccak256 is logged
        bytes16 sig = bytes16(keccak256(address1))^bytes16(keccak256(address2));
        require(sig_to_add[sig]==0);
        // New contract created
        address newContract = (new LoveAccountBase)(name1, name2, address1, address2, next_id);
        sig_to_add[sig]=newContract;
        Create(name1, name2, newContract, address1, address2, next_id);
        // First deposit
        if(msg.value>fee){
            newContract.transfer(msg.value-fee);
        }
        next_id++;
    }
    
    /// @dev Calculate service fee; to avoid ufixed data type, dev=(1/charge rate)
    /// @param _dev is inverse of charging rate. If service fee is 1%, _dev=100
    function _calculate(uint256 _amount, uint _dev) internal pure returns(uint256 _int){
        _int = _amount/uint256(_dev);
    }

    /// @dev If now is during service-free promotion, return true; else return false
    function _ifFree() view internal returns(bool) {
        if(uint64(now)<FREE_START || uint64(now)>FREE_END
            ) {return false;
        } else {return true;}
    }

    /// @dev THINK TWICE! If you breakup with your lover, all your balance will transfer 
    ///  to your lover's account, AND you cannot re-activate this very account! Think about 
    ///  your sweet moments before you hurt someone's heart!!
    /// @param _conadd is contract address of love account
    function sendBreakup(address _conadd) external whenNotPaused {
        if (_ifFree()){
            // Call function in love account contract
            LoveAccountBase(_conadd).breakup(msg.sender,0);}
        else{
            uint _balance = _conadd.balance;
            uint _fee = _calculate(_balance, BU_FEE_VERSE);
            // Call function in love account contract
            LoveAccountBase(_conadd).breakup(msg.sender,_fee);}
        Breakup(now);
     }

    /// @dev Log big events(pre-set-choice) in relationship, time stamp is required
    /// @param _conadd is contract address of love account
    /// @param _time is time stamp of the time of event
    /// @param _choice is uint of enum. See Love Account Base to understand how milestone work
    function sendMileStone(
        address _conadd, uint _time, 
        uint _choice) external payable whenNotPaused {
        require(msg.value >= STONE_FEE);
        uint8 _choice8 = uint8(_choice);
        require(_choice8>2 && _choice8<=18);
        // Call function in love account contract
        LoveAccountBase(_conadd).mileStone(msg.sender, uint64(_time), _choice8);
        StoneLog(_time, _choice8);
    }
    
    /// @dev Log diary, time stamp is now
    /// @param _conadd is contract address of love account
    function sendDiary(address _conadd, bytes _diary) external whenNotPaused{
        LoveAccountBase(_conadd).Diary(msg.sender, _diary);
        DiaryLog(now, _diary);
    }
    
    /// @dev Log withdraw info when first receice request
    /// @param _conadd is contract address of love account
    /// @param _amount is the amount of money to withdraw in unit wei
    function bankWithdraw(address _conadd, uint _amount) external whenNotPaused{
        // Make sure no valid withdraw is pending
        require(!pendingList[_conadd].pending || now>pendingList[_conadd].endTime);
        uint256 _fee;
        uint256 _amount256 = uint256(_amount); 
        require(_amount256==_amount);

        // Fee calculation
        if (_ifFree()){_fee=0;}else{_fee=_calculate(_amount, WD_FEE_VERSE);}

        // Call function in love account contract
        LoveAccountBase _conA = LoveAccountBase(_conadd);
        _conA.withdraw(_amount, msg.sender, _fee);

        // Log detail info for latter check
        uint64 _end = uint64(now)+CONFIRM_LIMIT;
        pendingList[_conadd] = pending({
                    pending:true,
                    withdrawer:msg.sender,
                    amount: _amount256,
                    fee:_fee,
                    endTime: _end});
        Withdraw(_amount256, _end);
    }

    /// @dev Confirm request and send money; erase info logs
    /// @param _conadd is contract address of love account 
    /// @param _amount is the amount of money to withdraw in unit wei
    function bankConfirm(address _conadd, uint _amount) external whenNotPaused{
        // Confirm matching request
        uint256 _amount256 = uint256(_amount); 
        require(_amount256==_amount);
        require(pendingList[_conadd].pending && now<pendingList[_conadd].endTime);
        require(pendingList[_conadd].withdrawer != msg.sender);
        require(pendingList[_conadd].amount == _amount);

        // Call function in love account contract
        LoveAccountBase(_conadd).withdrawConfirm(_amount, msg.sender);

        // Clean pending information
        delete pendingList[_conadd];
        WithdrawConfirm(_amount, now);
    }
}

/// @title Promotion contract of LoveBank. 
/// @author Diana Kudrow <https://github.com/lovebankcrypto>
/// @dev All CLevel OPs, for promotion. CFO can define free-of-charge time, and CEO can lower the 
///  service fee. (Yeah, we won't raise charge for sure, it's in the contrat!) 
contract LovePromo is Bank{

    /// @dev Withdraw your money for FREEEEEE! Or too if you wanna break up
    /// @param _start is time stamp of free start time
    /// @param _end is time stamp of free end time
    function setFreeTime(uint _start, uint _end) external onlyCOO {
        require(_end>=_start && _start>uint64(now));
        FREE_START = uint64(_start);
        FREE_END = uint64(_end);
    }


    /// @dev Set new charging rate
    /// @param _withdrawFee is inverse of charging rate to avoid ufixed data type. 
    ///  _withdrawFee=(1/x). If withdraw fee is 1%, _withdrawFee=100
    /// @param _breakupFee is inverse of charging rate to avoid ufixed data type. 
    ///  _breakupFee=(1/x). If breakup fee is 2%, _breakupFee=50
    /// @param _stone is Milestone logging fee, wei (diary is free of charge, cost only gas)
    /// @param _open is Open account fee, wei

    function setFee(
        uint _withdrawFee, 
        uint _breakupFee, 
        uint _stone, 
        uint _open) external onlyCEO {

        /// Service fee of withdraw NO HIGHER THAN 1%
        require(_withdrawFee>=100);
        /// Service fee of breakup NO HIGHER THAN 2%
        require(_breakupFee>=50);

        WD_FEE_VERSE = uint64(_withdrawFee);
        BU_FEE_VERSE = uint64(_breakupFee);
        STONE_FEE = _stone;
        OPEN_FEE = _open;
    }

    /// @dev CEO might extend the confirm time limit when Etherum Network is blocked
    /// @param _newlimit uses second as a unit
    function setConfirm(uint _newlimit) external onlyCEO {
        CONFIRM_LIMIT = uint32(_newlimit);
    }

    /// @dev Just for checking
    function getFreeTime() external view onlyCLevel returns(uint64 _start, uint64 _end){
        _start = uint64(FREE_START);
        _end = uint64(FREE_END);
    }
    
    /// @dev Just for checking
    function getFee() external view onlyCLevel returns(
        uint64 _withdrawFee, 
        uint64 _breakupFee, 
        uint _stone, 
        uint _open){

        _withdrawFee = WD_FEE_VERSE;
        _breakupFee = BU_FEE_VERSE;
        _stone = STONE_FEE;
        _open = OPEN_FEE;
    }
}

/// @title Love Bank, a safe place for lovers to save money money for future and get bless from
///  strangers and keep eternally on Etherum blockchain
/// @author Diana Kudrow <https://github.com/lovebankcrypto>
/// @dev The main LoveBank contract, keep track of all love accounts and their contracts, double
///  security check before any operations
contract BankCore is LovePromo {

    // This is the main LoveBank contract. The function of our DApp is quite straight forward:
    //  to create a account for couple, which is displayed on our website. Owers can put money in 
    //  as well as strangers. Withdraw request can only be done with both owners permission.
    //  In honor of eternal love, the party who puts forward a breakup will transfer all the remain
    //  balance to the other party by default.
    // 
    //  To make the contract more logical, we simple seperate our contract in following parts:
    //
    //      - LoveBankAccessControl: This contract manages the various addresses and constraints for 
    //             operations that can be executed only by specific roles. Namely CEO, CFO and COO.
    //
    //      - Bank is LoveBankAccessControl: In this contract we define the main stucture of our 
    //              Love Bank and the methord to create accounts. Also, all the operations of users are
    //              defined here, like money withdraw, breakup, diary, milestones. Lots of modifiers
    //              are used to protect user's safety.
    //
    //      - LovePromo is Bank: Here are some simple operations for COO to set free-charge time and for CEO
    //              to lower the charge rate.
    //
    //      - BankCore is LovePromo: inherit all previous contract. Contains all the big moves, like: 
    //              creating a bank, set defult C-Level users, unpause, update (only when hugh bug happens),
    //              withdraw money, etc.
    //
    //      - LoveAccountBase: This contract is the contract of a love account. Holds all common structs,
    //              events and base variables for love accounts.


    // Set in case the core contract is broken and an upgrade is required
    address public newContractAddress;

    /// @dev DepositBank is fired when ether is received from CLevel to BankCore Contract
    event DepositBank(address _sender, uint _value);

    function BankCore() public {
        // Starts paused.
        paused = true;
        // the creator of the contract is the initial CEO
        ceoAddress = msg.sender;
        // the creator of the contract is also the initial COO
        cooAddress = msg.sender;
        // the creator of the contract is also the initial COO
        cfoAddress = msg.sender;
    }

    /// @dev Used to mark the smart contract as upgraded, in case there is a serious
    ///  breaking bug. This method does nothing but keep track of the new contract and
    ///  emit a message indicating that the new address is set. It's up to clients of this
    ///  contract to update to the new contract address in that case. (This contract will
    ///  be paused indefinitely if such an upgrade takes place.)
    /// @param _v2Address new address
    /*** setNewAddress adapted from CryptoKitty ***/
    function setNewAddress(address _v2Address) external onlyCEO whenPaused {
        newContractAddress = _v2Address;
        ContractUpgrade(_v2Address);
    }

    /// @dev Override unpause so it requires all external contract addresses
    ///  to be set before contract can be unpaused. Also, we can't have
    ///  newContractAddress set either, because then the contract was upgraded.
    function unpause() public onlyCEO whenPaused {
        require(newContractAddress == address(0));
        // Actually unpause the contract.
        super.unpause();
    }
    
    /// @dev Rarely used! Only happen when extreme circumstances
    /// @param _conadd is contract address of love account
    /// @param newBank is newBank contract addess if updated
    function changeBank(address _conadd, address newBank) external whenPaused onlyCEO{
        require(newBank != address(0));
        LoveAccountBase(_conadd).changeBankAccount(newBank);
    }

    /// @dev Allows the CFO to capture the balance of Bank contract
    function withdrawBalance() external onlyCFO {
        // Subtract all the currently pregnant kittens we have, plus 1 of margin.
        if (this.balance > 0) {
            cfoAddress.transfer(this.balance);
        }
    }
    
    /// @dev Get Love account contrat address through Bank contract index
    function getContract(address _add1, address _add2) external view returns(address){
        bytes16 _sig = bytes16(keccak256(_add1))^bytes16(keccak256(_add2));
        return sig_to_add[_sig];
    }
    
    /// @dev Receive service fee from sub contracts
    function receiveFee() external payable{}
    
    /// @dev Reject all deposit from outside CLevel accounts
    function() external payable onlyCLevel {
        require(msg.value>0);
        DepositBank(msg.sender, msg.value);
    }
}