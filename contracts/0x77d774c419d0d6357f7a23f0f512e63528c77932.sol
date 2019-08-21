pragma solidity ^0.5.7;

/**
 * Copy right (c) Donex UG (haftungsbeschraenkt)
 * All rights reserved
 * Version 0.2.1 (BETA)
 */

contract Master {

    address payable ownerAddress;
    address constant oracleAddress = 0xE8013bD526100Ebf67ace0E0F21a296D8974f0A4;

    mapping (uint => bool) public validDueDate;


    event NewContract (
        address contractAddress
    );


    modifier onlyByOwner () {
        require(msg.sender ==  ownerAddress);
        _;
    }


    constructor () public {
        ownerAddress = msg.sender;
    }


    /**
     * @notice Create a contract representing a conditional payment.
     * @dev The creator address can be used to connect another smart contract to this master.
     * @param creator Provide the address of the creator of this contract.
     * @param long Decide if you want to be in the long or short position of your contract.
     * @param dueDate Set the due date of your contract. Note that the due date needs to match a valid due date.
     * @param strikePrice Choose a strike price which will be used on the due date for calculation of the payout. Make sure that the format is correct.
     */
    function createConditionalPayment
    (
        address payable creator,
        bool long,
        uint256 dueDate,
        uint256 strikePrice
    )
        payable
        public
        returns(address newDerivativeAddress)
    {
        require(validDueDate[dueDate]);
        ConditionalPayment conditionalPayment = (new ConditionalPayment).value(msg.value)
        (
            creator,
            long,
            dueDate,
            strikePrice
        );

        emit NewContract(address(conditionalPayment));

        return address(conditionalPayment);
    }

    /// @notice This function will be called by every conditional payment contract at settlement and requests the price from the oracle.
    function settle
    (
        uint256 dueDate
    )
        public
        payable
        returns (uint256)
    {
        Oracle o = Oracle(oracleAddress);
        return o.sendPrice(dueDate);
    }


    /**
     * Owner functions
     */

    function setValidDueDate
    (
        uint dueDate,
        bool valid
    )
        public
        onlyByOwner
    {
        validDueDate[dueDate] = valid;
    }

    function withdrawFees ()
        public
        onlyByOwner
    {
        msg.sender.transfer(address(this).balance);
    }

    function balanceOfFactory ()
        public
        view
        returns (uint256)
    {
        return (address(this).balance);
    }

}



/**
 * @title This contract serves as a conditional payment based on the spot price of an asset on the due date compared to a strike price.
 * @notice Use the Master to create this contract.
 */
contract ConditionalPayment {

    address payable public masterAddress;

    address constant public withdrawFunctionsAddress = 0x0b564F0aD4dcb35Cd43eff2f26Bf96B670eaBF5e;

    address payable public creator;

    uint256 public dueDate;
    uint256 public strikePrice;
    bool public creatorLong;

    uint8 public countCounterparties;

    bool public isSettled;
    uint256 public settlementPrice;

    uint256 public totalStakeCounterparties;

    mapping(address => uint256) public stakes;


    event ContractAltered ();

    event UpdatedParticipant
    (
        address indexed participant,
        uint256 stake
    );


    modifier onlyByCreator()
    {
        require(msg.sender ==  creator);
        _;
    }

    modifier onlyIncremental(uint amount)
    {
        require(amount % (0.1 ether) == 0);
        _;
    }

    modifier nonZeroMsgValue()
    {
        require(msg.value > 0);
        _;
    }

    modifier dueDateInFuture()
    {
        _;
        require(now < dueDate);
    }

    modifier nonZeroStrikePrice(uint256 newStrikePrice)
    {
        require(newStrikePrice > 0);
        _;
    }

    modifier emitsContractAlteredEvent()
    {
        _;
        emit ContractAltered();
    }

    modifier emitsUpdatedParticipantEvent(address participant)
    {
        _;
        emit UpdatedParticipant(participant,stakes[participant]);
    }


    constructor
    (
        address payable _creator,
        bool _long,
        uint256 _dueDate,
        uint256 _strikePrice
    )
        payable
        public
        onlyIncremental(msg.value)
        nonZeroStrikePrice(_strikePrice)
        nonZeroMsgValue
        dueDateInFuture
        emitsUpdatedParticipantEvent(_creator)
    {
        masterAddress = msg.sender;

        creator = _creator;
        creatorLong = _long;
        stakes[creator] = msg.value;

        strikePrice = _strikePrice;
        dueDate = _dueDate;
    }


    /// @notice The strike price can be changed as long as no counterpary has been found. Use this in order to make the conditional payment more attractive to be entered.
    function changeStrikePrice (uint256 newStrikePrice)
        public
        nonZeroStrikePrice(newStrikePrice)
        onlyByCreator
        emitsContractAlteredEvent
    {
        require(countCounterparties == 0);

        strikePrice = newStrikePrice;
    }


    /// @notice As a creator you can reduce your stake to the total stake of the counterparties at minimum.
    function reduceStake (uint256 amount)
        public
        onlyByCreator
        onlyIncremental(amount)
        emitsContractAlteredEvent
        emitsUpdatedParticipantEvent(creator)
    {
        uint256 maxWithdrawAmount = stakes[msg.sender] - totalStakeCounterparties;
        if(amount < maxWithdrawAmount)
        {
            stakes[msg.sender] -= amount;
            msg.sender.transfer(amount);
        }
        else
        {
            stakes[msg.sender] -= maxWithdrawAmount;
            msg.sender.transfer(maxWithdrawAmount);
        }
    }


    /// @notice As a creator you can add stake which allows more counterparties.
    function addStake ()
        public
        payable
        onlyByCreator
        onlyIncremental(msg.value)
        emitsContractAlteredEvent
        emitsUpdatedParticipantEvent(creator)
    {
        stakes[msg.sender] += msg.value;
    }


    /**
     * @notice Sign the contract. Note you will be subjected to fees at the time of settlement.
     * @param requestedStrikePrice Since the strike price could have potentially been changed by the creator during your transaction, make sure to enter the strike price you saw before making this transaction.
     */
    function signContract (uint256 requestedStrikePrice)
        payable
        public
        onlyIncremental(msg.value)
        nonZeroMsgValue
        dueDateInFuture
        emitsContractAlteredEvent
        emitsUpdatedParticipantEvent(msg.sender)
    {
        require(msg.sender != creator);
        require(requestedStrikePrice == strikePrice);
        totalStakeCounterparties += msg.value;
        require(totalStakeCounterparties <= stakes[creator]);

        if (stakes[msg.sender] == 0)
        {
            countCounterparties += 1;
        }
        stakes[msg.sender] += msg.value;
    }


    /// @notice Withdraw your stake as soon as the due date is reached and the price is available from the oracle.
    function withdraw ()
        public
        emitsContractAlteredEvent
    {
        require(now > dueDate);
        require(countCounterparties > 0);

        if (isSettled == false)
        {
            Master m = Master(masterAddress);
            settlementPrice = m.settle.value(totalStakeCounterparties/200)(dueDate);
            isSettled = true;
        }

        uint256 stakeMemory = stakes[msg.sender];
        Withdraw w = Withdraw(withdrawFunctionsAddress);
        if (msg.sender == creator)
        {
            stakes[msg.sender] = 0;
            msg.sender.transfer(w.amountCreator(
                creatorLong,
                stakeMemory,
                settlementPrice,
                strikePrice,
                totalStakeCounterparties));
        }
        if (stakes[msg.sender] != 0)
        {
            stakes[msg.sender] = 0;
            msg.sender.transfer(w.amountCounterparty(
                creatorLong,
                stakeMemory,
                settlementPrice,
                strikePrice));
        }
    }


    /// @notice In case anything went wrong, you are able to withdraw your stake 90 days after the due date.
    function unsettledWithdraw ()
        public
        emitsContractAlteredEvent
    {
        require (now > dueDate + 90 days);
        require (isSettled == false);

        uint256 stakeMemory = stakes[msg.sender];
        stakes[msg.sender] = 0;
        msg.sender.transfer(stakeMemory);
    }

}




interface Oracle {

    function sendPrice (uint256 dueDate)
        external
        view
        returns (uint256);

}


interface Withdraw {

    function amountCreator
    (
        bool makerLong,
        uint256 stakeMemory,
        uint256 settlementPrice,
        uint256 strikePrice,
        uint256 totalStakeAllTakers
    )
        external
        pure
        returns (uint256);


    function amountCounterparty
    (
        bool makerLong,
        uint256 stakeMemory,
        uint256 settlementPrice,
        uint256 strikePrice
    )
        external
        pure
        returns (uint256);

}