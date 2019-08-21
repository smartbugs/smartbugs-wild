pragma solidity 0.4.19;

/*
 * Aethia egg giveaway.
 *
 * Every day, for a period of seven days, starting February 2nd 12:00:00 UTC,
 * this contract is allowed to distribute a maximum of one-hundred-and-twenty
 * (120) common Ethergotchi eggs, for a total of 820 eggs.
 *
 * These 120 eggs are divided over the four (4) slots of six (6) hours that
 * make up each day. Every six hours, thirty (30) common Ethergotchi eggs are
 * available for free (excluding the gas cost of a transaction).
 *
 * Eggs that remain at the end of a time slot are not transferred to the next
 * time slot.
 */
contract EggGiveaway {

    /*
     * The start and end dates respectively convert to the following
     * timestamps:
     *  START_DATE  => February 2nd, 12:00:00 UTC
     *  END_DATE    => February 9th, 11:59:59 UTC
     */
    uint256 constant START_DATE = 1517572800;
    uint256 constant END_DATE = 1518177600;

    /*
     * The amount of seconds within a single time slot.
     *
     * This is set to a total of six hours:
     *      6 x 60 x 60 = 21600
     */
    uint16 constant SLOT_DURATION_IN_SECONDS = 21600;

    /*
     * Remaining free eggs per time slot.
     *
     * The structure is as follows:
     * {
     *  0   => 30,  February 2nd, 12:00:00 UTC until February 2nd, 17:59:59 UTC
     *  1   => 30,  February 2nd, 18:00:00 UTC until February 2nd, 23:59:59 UTC
     *  2   => 30,  February 3rd, 00:00:00 UTC until February 3rd, 05:59:59 UTC
     *  3   => 30,  February 3rd, 06:00:00 UTC until February 3rd, 11:59:59 UTC
     *  4   => 30,  February 3rd, 12:00:00 UTC until February 3rd, 17:59:59 UTC
     *  5   => 30,  February 3rd, 18:00:00 UTC until February 3rd, 23:59:59 UTC
     *  6   => 30,  February 4th, 00:00:00 UTC until February 4th, 05:59:59 UTC
     *  7   => 30,  February 4th, 06:00:00 UTC until February 4th, 11:59:59 UTC
     *  8   => 30,  February 4th, 12:00:00 UTC until February 4th, 17:59:59 UTC
     *  9   => 30,  February 4th, 18:00:00 UTC until February 4th, 23:59:59 UTC
     *  10  => 30,  February 5th, 00:00:00 UTC until February 5th, 05:59:59 UTC
     *  11  => 30,  February 5th, 06:00:00 UTC until February 5th, 11:59:59 UTC
     *  12  => 30,  February 5th, 12:00:00 UTC until February 5th, 17:59:59 UTC
     *  13  => 30,  February 5th, 18:00:00 UTC until February 5th, 23:59:59 UTC
     *  14  => 30,  February 6th, 00:00:00 UTC until February 6th, 05:59:59 UTC
     *  15  => 30,  February 6th, 06:00:00 UTC until February 6th, 11:59:59 UTC
     *  16  => 30,  February 6th, 12:00:00 UTC until February 6th, 17:59:59 UTC
     *  17  => 30,  February 6th, 18:00:00 UTC until February 6th, 23:59:59 UTC
     *  18  => 30,  February 7th, 00:00:00 UTC until February 7th, 05:59:59 UTC
     *  19  => 30,  February 7th, 06:00:00 UTC until February 7th, 11:59:59 UTC
     *  20  => 30,  February 7th, 12:00:00 UTC until February 7th, 17:59:59 UTC
     *  21  => 30,  February 7th, 18:00:00 UTC until February 7th, 23:59:59 UTC
     *  22  => 30,  February 8th, 00:00:00 UTC until February 8th, 05:59:59 UTC
     *  23  => 30,  February 8th, 06:00:00 UTC until February 8th, 11:59:59 UTC
     *  24  => 30,  February 8th, 12:00:00 UTC until February 8th, 17:59:59 UTC
     *  25  => 30,  February 8th, 18:00:00 UTC until February 8th, 23:59:59 UTC
     *  26  => 30,  February 9th, 00:00:00 UTC until February 8th, 05:59:59 UTC
     *  27  => 30,  February 9th, 06:00:00 UTC until February 8th, 11:59:59 UTC
     * }
     */
    mapping (uint8 => uint8) remainingFreeEggs;

    /*
     * Egg owners
     *
     * This is a mapping containing all owners of free eggs. While this does
     * not prevent people from using multiple addresses to acquire multiple
     * eggs, it does increase the difficulty slightly.
     */
    mapping (address => bool) eggOwners;

    /*
     * Store egg retrieval event on the blockchain.
     *
     * For audit and logging purposes, all acquisitions of Ethergotchi eggs are
     * logged by acquirer and acquisition date.
     */
    event LogEggAcquisition(address indexed _acquirer, uint256 indexed _date);

    /*
     * The contract constructor.
     * 
     * This generates all available free eggs per time slot by calculating the
     * total amount of seconds within the entire giveaway period, and the number
     * of time slots within this period.
     *
     * Each time slot is then assigned thirty (30) eggs.
     */
    function EggGiveaway() public {
        uint256 secondsInGiveawayPeriod = END_DATE - START_DATE;
        uint8 timeSlotCount = uint8(
            secondsInGiveawayPeriod / SLOT_DURATION_IN_SECONDS
        );

        for (uint8 i = 0; i < timeSlotCount; i++) {
            remainingFreeEggs[i] = 30;
        }
    }

    /*
     * Acquire free egg from the egg giveaway contract.
     *
     * To acquire an egg, a few conditions have to be met:
     *  1. The sender is not allowed to send Ether. The game is free to play.
     *  2. The transaction must occur within the giveaway period, as specified
     *     at the top of this file.
     *  3. The sender must not already have acquired a free egg.
     *  4. There must be an availability of at least one (1) for the time slot
     *     the transaction occurs in.
     */
    function acquireFreeEgg() payable external {
        require(msg.value == 0);
        require(START_DATE <= now && now < END_DATE);
        require(eggOwners[msg.sender] == false);

        uint8 currentTimeSlot = getTimeSlot(now);

        require(remainingFreeEggs[currentTimeSlot] > 0);

        remainingFreeEggs[currentTimeSlot] -= 1;
        eggOwners[msg.sender] = true;

        LogEggAcquisition(msg.sender, now);
    }

    /*
     * Fallback payable method.
     *
     * This is in the case someone calls the contract without specifying the
     * correct method to call. This method will ensure the failure of a
     * transaction that was wrongfully executed.
     */
    function () payable external {
        revert();
    }

    /*
     * Calculates the time slot corresponding to the given UNIX timestamp.
     *
     * The time slot is calculated by subtracting the current date and time in
     * seconds from the contract starting date and time in seconds. This is then
     * divided by the number of seconds within a time slot, and floored, to get
     * the correct time slot.
     */
    function getTimeSlot(uint256 _timestamp) private pure returns (uint8) {
        uint256 secondsSinceGiveawayStart = _timestamp - START_DATE;
        
        return uint8(secondsSinceGiveawayStart / SLOT_DURATION_IN_SECONDS);
    }
}