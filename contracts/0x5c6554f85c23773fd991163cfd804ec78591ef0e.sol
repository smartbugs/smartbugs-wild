pragma solidity 0.4.19;

/**
 * Owned Contract
 * 
 * This is a contract trait to inherit from. Contracts that inherit from Owned 
 * are able to modify functions to be only callable by the owner of the
 * contract.
 * 
 * By default it is impossible to change the owner of the contract.
 */
contract Owned {
    /**
     * Contract owner.
     * 
     * This value is set at contract creation time.
     */
    address owner;

    /**
     * Contract constructor.
     * 
     * This sets the owner of the Owned contract at the time of contract
     * creation.
     */
    function Owned() public {
        owner = msg.sender;
    }

    /**
     * Modify method to only allow the owner to call it.
     */
    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }
}

/**
 * Aethia Omega Egg Sale Contract.
 * 
 * Every day, for a period of five (5) days, starting February 12th 12:00:00 
 * UTC, this contract is allowed to sell a maximum of one-hundred-and-twenty
 * (120) omega Ethergotchi eggs, for a total of six-hundred (600) eggs.
 *
 * These one-hundred-and-twenty eggs are divided over the twelve (12) time slots
 * of two (2) hours that make up each day. Every two hours, ten (10) omega
 * Ethergotchi eggs are available for 0.09 ether (excluding the gas cost of a 
 * transaction).
 *
 * Any omega eggs that remain at the end of a time slot are not transferred to
 * the next time slot.
 */
contract OmegaEggSale is Owned {

    /**
     * The start date of the omega egg sale in seconds since the UNIX epoch.
     * 
     * This value is equivalent to February 12th, 12:00:00 UTC, on a 24 hour
     * clock.
     */
    uint256 constant START_DATE = 1518436800;

    /**
     * The end date of the omega egg sale in seconds since the UNIX epoch.
     * 
     * This value is equivalent to February 17th, 12:00:00 UTC, on a 24 hour
     * clock.
     */
    uint256 constant END_DATE = 1518868800;

    /**
     * The amount of seconds within a single time slot.
     *
     * This is set to a total of two hours:
     *      2 x 60 x 60 = 7200 seconds
     */
    uint16 constant SLOT_DURATION_IN_SECONDS = 7200;

    /**
     * The number of remaining eggs in each time slot.
     * 
     * This is initially set to ten for each time slot.
     */
    mapping (uint8 => uint8) remainingEggs;
    
    /**
     * Omega egg owners.
     *
     * This is a mapping containing all owners of omega eggs. While this does
     * not prevent people from using multiple addresses to buy multiple omega
     * eggs, it does increase the difficulty slightly.
     */
    mapping (address => bool) eggOwners;

    /**
     * Omega egg sale event.
     * 
     * For audit and logging purposes, all omega egg sales are logged by 
     * acquirer and acquisition date.
     */
    event LogOmegaEggSale(address indexed _acquirer, uint256 indexed _date);

    /**
     * Contract constructor
     * 
     * This generates all omega egg time slots and the amount of available
     * omega eggs within each time slot. The generation is done by calculating
     * the total amount of seconds within the sale period together with the 
     * amount of seconds within each time slot, and dividing the former by the
     * latter for the number of time slots.
     * 
     * Each time slot is then assigned ten omega eggs.
     */
    function OmegaEggSale() Owned() public {
        uint256 secondsInSalePeriod = END_DATE - START_DATE;
        uint8 timeSlotCount = uint8(
            secondsInSalePeriod / SLOT_DURATION_IN_SECONDS
        );

        for (uint8 i = 0; i < timeSlotCount; i++) {
            remainingEggs[i] = 10;
        }
    }

    /**
     * Buy omega egg from the OmegaEggSale contract.
     * 
     * The cost of an omega egg is 0.09 ether. This contract accepts any amount
     * equal or above 0.09 ether to buy an omega egg. In the case of higher
     * amounts being sent, the contract will refund the difference.
     * 
     * To successully buy an omega egg, five conditions have to be met:
     *  1. The `buyOmegaEgg` method must be called.
     *  2. A value of 0.09 or more ether must accompany the transaction.
     *  3. The transaction occurs in between February 12th 12:00:00 UTC and
     *     February 17th 12:00:00 UTC.
     *  4. The time slot in which the transaction occurs has omega eggs
     *     available.
     *  5. The sender must not already have bought an omega egg.
     */
    function buyOmegaEgg() payable external {
        require(msg.value >= 0.09 ether);
        require(START_DATE <= now && now < END_DATE);
        require(eggOwners[msg.sender] == false);

        uint8 currentTimeSlot = getTimeSlot(now);

        require(remainingEggs[currentTimeSlot] > 0);

        remainingEggs[currentTimeSlot] -= 1;
        eggOwners[msg.sender] = true;

        LogOmegaEggSale(msg.sender, now);
        
        // Send back any remaining value
        if (msg.value > 0.09 ether) {
            msg.sender.transfer(msg.value - 0.09 ether);
        }
    }

    /**
     * Fallback payable method.
     *
     * This is in the case someone calls the contract without specifying the
     * correct method to call. This method will ensure the failure of a
     * transaction that was wrongfully executed.
     */
    function () payable external {
        revert();
    }
    
    /**
     * Return number of eggs remaining in given time slot.
     * 
     * If the time slot is not valid (e.g. the time slot does not exist
     * according to the this contract), the number of remaining eggs will
     * default to zero (0).
     * 
     * This method is intended for external viewing purposes.
     * 
     * Parameters
     * ----------
     * _timeSlot : uint8
     *     The time slot to return the number of remaining eggs for.
     * 
     * Returns
     * -------
     * uint8
     *     The number of eggs still available within the contract for given
     *     time slot.
     */
    function eggsInTimeSlot(uint8 _timeSlot) view external returns (uint8) {
        return remainingEggs[_timeSlot];
    }
    
    /**
     * Return true if `_buyer` has bought an omega egg, otherwise false.
     * 
     * This method is intended for external viewing purposes.
     * 
     * Parameters
     * ----------
     * _buyer : address
     *     The Ethereum wallet address of the buyer.
     * 
     * Returns
     * -------
     * bool
     *     True if `_buyer` has bought an egg, otherwise false.
     */
    function hasBoughtEgg(address _buyer) view external returns (bool) {
        return eggOwners[_buyer] == true;
    }
    
    /**
     * Withdraw all funds from contract.
     * 
     * This method can only be called after the OmegaEggSale contract has run
     * its course.
     */
    function withdraw() onlyOwner external {
        require(now >= END_DATE);

        owner.transfer(this.balance);
    }

    /**
     * Calculate the time slot corresponding to the given UNIX timestamp.
     *
     * The time slot is calculated by subtracting the current date and time in
     * seconds from the contract's starting date and time in seconds. The result
     * is then divided by the number of seconds within a time slot, and rounded
     * down to get the correct time slot.
     *
     * Parameters
     * ----------
     * _timestamp : uint256
     *     The timestamp to calculate a timeslot for. This is the amount of
     *     seconds elapsed since the UNIX epoch.
     *
     * Returns
     * -------
     * uint8
     *     The OmegaEggSale time slot corresponding to the given timestamp.
     *     This can be a non-existent time slot, if the timestamp is further
     *     in the future than `END_DATE`.
     */
    function getTimeSlot(uint256 _timestamp) private pure returns (uint8) {
        uint256 secondsSinceSaleStart = _timestamp - START_DATE;
        
        return uint8(secondsSinceSaleStart / SLOT_DURATION_IN_SECONDS);
    }
}