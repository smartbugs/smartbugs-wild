pragma solidity ^0.4.25;


/**
* @title ThorMutual
* @author Leo
* @dev Thor Mutual for TRX, WAVES, ADA, ERC20 and so on
*/


contract Utils {

    uint constant DAILY_PERIOD = 1;
    uint constant WEEKLY_PERIOD = 7;

    int constant PRICE_DECIMALS = 10 ** 8;

    int constant INT_MAX = 2 ** 255 - 1;

    uint constant UINT_MAX = 2 ** 256 - 1;

}

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev The Ownable constructor sets the original `owner` of the contract to the sender
     * account.
     */
    constructor () internal {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
    }

    /**
     * @return the address of the owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(isOwner());
        _;
    }

    /**
     * @return true if `msg.sender` is the owner of the contract.
     */
    function isOwner() public view returns (bool) {
        return msg.sender == _owner;
    }

    // /**
    //  * @dev Allows the current owner to relinquish control of the contract.
    //  * @notice Renouncing to ownership will leave the contract without an owner.
    //  * It will not be possible to call the functions with the `onlyOwner`
    //  * modifier anymore.
    //  */
    // function renounceOwnership() public onlyOwner {
    //     emit OwnershipTransferred(_owner, address(0));
    //     _owner = address(0);
    // }

    /**
     * @dev Allows the current owner to transfer control of the contract to a newOwner.
     * @param newOwner The address to transfer ownership to.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers control of the contract to a newOwner.
     * @param newOwner The address to transfer ownership to.
     */
    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0));
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}


interface ThorMutualInterface {
    function getCurrentPeriod() external view returns(uint);
    function settle() external;
}


/**
 * @title ThorMutualToken
 * @dev Every ThorMutualToken contract is related with a specific token such as BTC/ETH/EOS/ERC20
 * functions, participants send ETH to this contract to take part in the Thor Mutual activity.
 */
contract ThorMutualToken is Ownable, Utils {
    string public thorMutualToken;

    // total deposit for a specific period
    mapping(uint => uint) amountOfDailyPeriod;

    // total deposit for a specific period
    mapping(uint => uint) amountOfWeeklyPeriod;

    // participant's total deposit fund
    mapping(address => uint) participantAmount;

    // participants
    address[] participants;

    // deposit info
    struct DepositInfo {
        uint blockTimeStamp;
        uint period;
        string token;
        uint amount;
    }

    // participant's total deposit history
    //mapping(address => DepositInfo[]) participantsHistory;
    mapping(address => uint[]) participantsHistoryTime;
    mapping(address => uint[]) participantsHistoryPeriod;
    mapping(address => uint[]) participantsHistoryAmount;

    // participant's total deposit fund for a specific period
    mapping(uint => mapping(address => uint)) participantAmountOfDailyPeriod;

    // participant's total deposit fund for a weekly period
    mapping(uint => mapping(address => uint)) participantAmountOfWeeklyPeriod;

    // participants for the daily period
    mapping(uint => address[]) participantsDaily;

    // participants for the weekly period
    mapping(uint => address[]) participantsWeekly;

    ThorMutualInterface public thorMutualContract;

    constructor(string _thorMutualToken, ThorMutualInterface _thorMutual) public {
        thorMutualToken = _thorMutualToken;
        thorMutualContract = _thorMutual;
    }

    event ThorDepositToken(address sender, uint256 amount);
    function() external payable {
        require(msg.value >= 0.001 ether);
        
        require(address(thorMutualContract) != address(0));
        address(thorMutualContract).transfer(msg.value);

        //uint currentPeriod;
        uint actualPeriod = 0;
        uint actualPeriodWeek = 0;

        actualPeriod = thorMutualContract.getCurrentPeriod();

        actualPeriodWeek = actualPeriod / WEEKLY_PERIOD;

        if (participantAmount[msg.sender] == 0) {
            participants.push(msg.sender);
        }

        if (participantAmountOfDailyPeriod[actualPeriod][msg.sender] == 0) {
            participantsDaily[actualPeriod].push(msg.sender);
        }

        if (participantAmountOfWeeklyPeriod[actualPeriodWeek][msg.sender] == 0) {
            participantsWeekly[actualPeriodWeek].push(msg.sender);
        }

        participantAmountOfDailyPeriod[actualPeriod][msg.sender] += msg.value;

        participantAmount[msg.sender] += msg.value;
        
        participantAmountOfWeeklyPeriod[actualPeriodWeek][msg.sender] += msg.value;

        amountOfDailyPeriod[actualPeriod] += msg.value;

        amountOfWeeklyPeriod[actualPeriodWeek] += msg.value;

        // DepositInfo memory depositInfo = DepositInfo(block.timestamp, actualPeriod, thorMutualToken, msg.value);

        // participantsHistory[msg.sender].push(depositInfo);

        participantsHistoryTime[msg.sender].push(block.timestamp);
        participantsHistoryPeriod[msg.sender].push(actualPeriod);
        participantsHistoryAmount[msg.sender].push(msg.value);

        emit ThorDepositToken(msg.sender, msg.value);
    }

    function setThorMutualContract(ThorMutualInterface _thorMutualContract) public onlyOwner{
        require(address(_thorMutualContract) != address(0));
        thorMutualContract = _thorMutualContract;
    }

    function getThorMutualContract() public view returns(address) {
        return thorMutualContract;
    }

    function setThorMutualToken(string _thorMutualToken) public onlyOwner {
        thorMutualToken = _thorMutualToken;
    }

    function getDepositDailyAmountofPeriod(uint period) external view returns(uint) {
        require(period >= 0);

        return amountOfDailyPeriod[period];
    }

    function getDepositWeeklyAmountofPeriod(uint period) external view returns(uint) {
        require(period >= 0);
        uint periodWeekly = period / WEEKLY_PERIOD;
        return amountOfWeeklyPeriod[periodWeekly];
    }

    function getParticipantsDaily(uint period) external view returns(address[], uint) {
        require(period >= 0);

        return (participantsDaily[period], participantsDaily[period].length);
    }

    function getParticipantsWeekly(uint period) external view returns(address[], uint) {
        require(period >= 0);

        uint periodWeekly = period / WEEKLY_PERIOD;
        return (participantsWeekly[periodWeekly], participantsWeekly[period].length);
    }

    function getParticipantAmountDailyPeriod(uint period, address participant) external view returns(uint) {
        require(period >= 0);

        return participantAmountOfDailyPeriod[period][participant];
    }

    function getParticipantAmountWeeklyPeriod(uint period, address participant) external view returns(uint) {
        require(period >= 0);

        uint periodWeekly = period / WEEKLY_PERIOD;
        return participantAmountOfWeeklyPeriod[periodWeekly][participant];
    }

    //function getParticipantHistory(address participant) public view returns(DepositInfo[]) {
    function getParticipantHistory(address participant) public view returns(uint[], uint[], uint[]) {

        return (participantsHistoryTime[participant], participantsHistoryPeriod[participant], participantsHistoryAmount[participant]);
        //return participantsHistory[participant];
    }

    function getSelfBalance() public view returns(uint) {
        return address(this).balance;
    }

    function withdraw(address receiver, uint amount) public onlyOwner {
        require(receiver != address(0));

        receiver.transfer(amount);
    }

}