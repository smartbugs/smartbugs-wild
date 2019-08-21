pragma solidity ^0.4.25;

/**
 *
 * SmartLotto.in
 *
 * Fair lottery smart contract with random determination of winning tickets
 *
 *
 * 1 ticket is jackpot winning ticket and get 10% of the contract balance
 * 5 tickets are first prize winnings tickets and get 5% of the contract balance
 * 10% of all tickets are second prize winners and get 35% of the contract balance
 * all other tickets receive 50% refund of the ticket price
 *
 *
 * 5% for referral program - use Add Data field and fill it with ETH-address of your upline when you buy tickets
 *
 *
 * 1 ticket price is 0.1 ETH, you can buy 250 tickets per 1 transaction maximum (250 tickets = 25 ETH)
 * You can make more transactions and purhase more tickets to increase your winning chances
 *
 * Use 200000 of gas limit when you buy tickets, check current gas price on https://ethgasstation.info
 *
 * Good luck!
 *
 */


contract SmartLotto {
    using SafeMath for uint256;

    uint256 constant public TICKET_PRICE = 0.1 ether;        // price of 1 ticket is 0.1 ETH
    uint256 constant public MAX_TICKETS_PER_TX = 250;        // max tickets amount per 1 transaction

    uint256 constant public JACKPOT_WINNER = 1;              // jackpot go to 1 ticket winners
    uint256 constant public FIRST_PRIZE_WINNERS = 5;         // first prize go to 5 tickets winners
    uint256 constant public SECOND_PRIZE_WINNERS_PERC = 10;  // percent of the second prize ticket winners

    uint256 constant public JACKPOT_PRIZE = 10;              // jackpot winner take 10% of balance
    uint256 constant public FIRST_PRIZE_POOL = 5;            // first prize winners takes 5% of balance
    uint256 constant public SECOND_PRIZE_POOL = 35;          // second prize winners takes 35% of balance

    uint256 constant public REFERRAL_COMMISSION = 5;         // referral commission 5% from input
    uint256 constant public MARKETING_COMMISSION = 10;       // marketing commission 10% from input
    uint256 constant public WINNINGS_COMMISSION = 20;        // winnings commission 20% from winnings

    uint256 constant public PERCENTS_DIVIDER = 100;          // percents divider, 100%

    uint256 constant public CLOSE_TICKET_SALES = 1546297200; // 23:00:00 31th of December 2018 GMT
    uint256 constant public LOTTERY_DRAW_START = 1546300800; // 00:00:00 1th of January 2019 GMT
    uint256 constant public PAYMENTS_END_TIME = 1554076800;  // 00:00:00 1th of April 2019 GMT

    uint256 public playersCount = 0;                         // participated players counter
    uint256 public ticketsCount = 0;                         // buyed tickets counter

    uint256 public jackpotPrize = 0;                         // jackpot win amount per ticket
    uint256 public firstPrize = 0;                           // first prize win amount per ticket
    uint256 public secondPrize = 0;                          // second prize win amount per ticket
    uint256 public secondPrizeWonTickets = 0;                // second prize win tickets amount
    uint256 public wonTicketsAmount = 0;                     // total amount of won tickets
    uint256 public participantsMoneyPool = 0;                // money pool returned to participants
    uint256 public participantsTicketPrize = 0;              // amount returned per 1 ticket

    uint256 public ticketsCalculated = 0;                    // won tickets calculated counter

    uint256 public salt = 0;                                 // salt for random generator

    bool public calculationsDone;                            // flag true when all calculations finished

    address constant public MARKETING_ADDRESS = 0xFD527958E10C546f8b484135CC51fa9f0d3A8C5f;
    address constant public COMMISSION_ADDRESS = 0x53434676E12A4eE34a4eC7CaBEBE9320e8b836e1;


    struct Player {
        uint256 ticketsCount;
        uint256[] ticketsPacksBuyed;
        uint256 winnings;
        uint256 wonTicketsCount;
        uint256 payed;
    }

    struct TicketsBuy {
        address player;
        uint256 ticketsAmount;
    }

	struct TicketsWon {
		uint256 won;
    }

    mapping (address => Player) public players;
    mapping (uint256 => TicketsBuy) public ticketsBuys;
	mapping (uint256 => TicketsWon) public ticketsWons;


    function() public payable {
        if (msg.value >= TICKET_PRICE) {
            buyTickets();
        } else {
            if (!calculationsDone) {
                makeCalculations(50);
            } else {
                payPlayers();
            }
        }
    }


    function buyTickets() private {
        // require time now less than or equal to 23:00:00 31th of December 2018 GMT
        require(now <= CLOSE_TICKET_SALES);

        // save msg.value
        uint256 msgValue = msg.value;

        // load player msg.sender
        Player storage player = players[msg.sender];

        // if new player add to total players stats
        if (player.ticketsCount == 0) {
            playersCount++;
        }

        // count amount of tickets which can be bought
        uint256 ticketsAmount = msgValue.div(TICKET_PRICE);

        // if tickets more than MAX_TICKETS_PER_TX (250 tickets)
        if (ticketsAmount > MAX_TICKETS_PER_TX) {
            // use MAX_TICKETS_PER_TX (250 tickets)
            ticketsAmount = MAX_TICKETS_PER_TX;
        }

		// count overpayed amount by player
		uint256 overPayed = msgValue.sub(ticketsAmount.mul(TICKET_PRICE));

		// if player overpayed
		if (overPayed > 0) {
			// update msgValue for futher calculations
			msgValue = msgValue.sub(overPayed);

			// send to player overpayed amount
			msg.sender.send(overPayed);
		}

        // add bought tickets pack to array with id of current tickets amount
        player.ticketsPacksBuyed.push(ticketsCount);

        // create new TicketsBuy record
        // creating only one record per MAX_TICKETS_PER_TX (250 tickets)
        // to avoid high gas usage when players buy tickets
        ticketsBuys[ticketsCount] = TicketsBuy({
            player : msg.sender,
            ticketsAmount : ticketsAmount
        });

		// add bought tickets to player stats
        player.ticketsCount = player.ticketsCount.add(ticketsAmount);
        // update bought tickets counter
        ticketsCount = ticketsCount.add(ticketsAmount);

        // try get ref address from tx data
        address referrerAddress = bytesToAddress(msg.data);

        // if ref address not 0 and not msg.sender
        if (referrerAddress != address(0) && referrerAddress != msg.sender) {
            // count ref amount
            uint256 referralAmount = msgValue.mul(REFERRAL_COMMISSION).div(PERCENTS_DIVIDER);
            // send ref amount
            referrerAddress.send(referralAmount);
        }

        // count marketing amount
        uint256 marketingAmount = msgValue.mul(MARKETING_COMMISSION).div(PERCENTS_DIVIDER);
        // send marketing amount
        MARKETING_ADDRESS.send(marketingAmount);
    }

    function makeCalculations(uint256 count) public {
        // require calculations not done
        require(!calculationsDone);
        // require time now more than or equal to 00:00:00 1st of January 2019 GMT
        require(now >= LOTTERY_DRAW_START);

        // if salt not counted
        if (salt == 0) {
            // create random salt which depends on blockhash, count of tickets and count of players
            salt = uint256(keccak256(abi.encodePacked(ticketsCount, uint256(blockhash(block.number-1)), playersCount)));

            // get actual contract balance
            uint256 contractBalance = address(this).balance;

            // count and save jackpot win amount per ticket
            jackpotPrize = contractBalance.mul(JACKPOT_PRIZE).div(PERCENTS_DIVIDER).div(JACKPOT_WINNER);
            // count and save first prize win amount per ticket
            firstPrize = contractBalance.mul(FIRST_PRIZE_POOL).div(PERCENTS_DIVIDER).div(FIRST_PRIZE_WINNERS);

            // count and save second prize win tickets amount
            secondPrizeWonTickets = ticketsCount.mul(SECOND_PRIZE_WINNERS_PERC).div(PERCENTS_DIVIDER);
            // count and save second prize win amount per ticket
            secondPrize = contractBalance.mul(SECOND_PRIZE_POOL).div(PERCENTS_DIVIDER).div(secondPrizeWonTickets);

            // count and save how many tickets won
            wonTicketsAmount = secondPrizeWonTickets.add(JACKPOT_WINNER).add(FIRST_PRIZE_WINNERS);

            // count and save money pool returned to participants
            participantsMoneyPool = contractBalance.mul(PERCENTS_DIVIDER.sub(JACKPOT_PRIZE).sub(FIRST_PRIZE_POOL).sub(SECOND_PRIZE_POOL)).div(PERCENTS_DIVIDER);
            // count and save participants prize per ticket
            participantsTicketPrize = participantsMoneyPool.div(ticketsCount.sub(wonTicketsAmount));

            // proceed jackpot prize ticket winnings
            calculateWonTickets(JACKPOT_WINNER, jackpotPrize);
            // proceed first prize tickets winnings
            calculateWonTickets(FIRST_PRIZE_WINNERS, firstPrize);

            // update calculated tickets counter
            ticketsCalculated = ticketsCalculated.add(JACKPOT_WINNER).add(FIRST_PRIZE_WINNERS);
        // if salt already counted
        } else {
            // if calculations of second prize winners not yet finished
            if (ticketsCalculated < wonTicketsAmount) {
                // how many tickets not yet calculated
                uint256 ticketsForCalculation = wonTicketsAmount.sub(ticketsCalculated);

                // if count zero and tickets for calculations more than 50
                // than calculate 50 tickets to avoid gas cost more than block limit
                if (count == 0 && ticketsForCalculation > 50) {
                    ticketsForCalculation = 50;
                }

                // if count more than zero and count less than amount of not calculated tickets
                // than use count as amount of tickets for calculations
                if (count > 0 && count <= ticketsForCalculation) {
                    ticketsForCalculation = count;
                }

                // proceed second prize ticket winnings
                calculateWonTickets(ticketsForCalculation, secondPrize);

                // update calculated tickets counter
                ticketsCalculated = ticketsCalculated.add(ticketsForCalculation);
            }

            // if calculations of second prize winners finished set calculations done
            if (ticketsCalculated == wonTicketsAmount) {
                calculationsDone = true;
            }
        }
    }

    function calculateWonTickets(uint256 numbers, uint256 prize) private {
        // for all numbers in var make calculations
        for (uint256 n = 0; n < numbers; n++) {
            // get random generated won ticket number
            uint256 wonTicketNumber = random(n);

			// if ticket already won
			if (ticketsWons[wonTicketNumber].won == 1) {
				// than add 1 ticket to numbers
				numbers = numbers.add(1);
			// ticket not won yet
			} else {
				// mark ticket as won
				ticketsWons[wonTicketNumber].won = 1;

				// search player record to add ticket winnings
				for (uint256 i = 0; i < MAX_TICKETS_PER_TX; i++) {
					// search max MAX_TICKETS_PER_TX (250 tickets)
					uint256 wonTicketIdSearch = wonTicketNumber - i;

					// if player record found
					if (ticketsBuys[wonTicketIdSearch].ticketsAmount > 0) {
						// read player from storage
						Player storage player = players[ticketsBuys[wonTicketIdSearch].player];

						// add ticket prize amount to player winnings
						player.winnings = player.winnings.add(prize);
						// update user won tickets counter
						player.wonTicketsCount++;

						// player found so stop searching
						break;
					}
				}
			}
        }

        // update salt and add numbers amount
        salt = salt.add(numbers);
    }

    function payPlayers() private {
        // require calculations are done
        require(calculationsDone);

        // pay players if time now less than 00:00:00 1st of April 2019 GMT
        if (now <= PAYMENTS_END_TIME) {
            // read player record
            Player storage player = players[msg.sender];

            // if player have won tickets and not yet payed
            if (player.winnings > 0 && player.payed == 0) {
                // count winnings commission from player won amount
                uint256 winCommission = player.winnings.mul(WINNINGS_COMMISSION).div(PERCENTS_DIVIDER);

                // count amount of not won tickets
                uint256 notWonTickets = player.ticketsCount.sub(player.wonTicketsCount);
                // count return amount for not won tickets
                uint256 notWonAmount = notWonTickets.mul(participantsTicketPrize);

                // update player payed winnings
                player.payed = player.winnings.add(notWonAmount);

                // send total winnings amount to player
                msg.sender.send(player.winnings.sub(winCommission).add(notWonAmount).add(msg.value));

                // send commission
                COMMISSION_ADDRESS.send(winCommission);
            }

            // if player have not won tickets and not yet payed
            if (player.winnings == 0 && player.payed == 0) {
                // count return amount for not won tickets
                uint256 returnAmount = player.ticketsCount.mul(participantsTicketPrize);

                // update player payed winnings
                player.payed = returnAmount;

                // send total winnings amount to player
                msg.sender.send(returnAmount.add(msg.value));
            }
        // if payment period already ended
        } else {
            // get actual contract balance
            uint256 contractBalance = address(this).balance;

            // actual contract balance more than zero
            if (contractBalance > 0) {
                // send contract balance to commission address
                COMMISSION_ADDRESS.send(contractBalance);
            }
        }
    }

    function random(uint256 nonce) private view returns (uint256) {
        // random number generated from salt plus nonce divided by total amount of tickets
        uint256 number = uint256(keccak256(abi.encodePacked(salt.add(nonce)))).mod(ticketsCount);
        return number;
    }

    function playerBuyedTicketsPacks(address player) public view returns (uint256[]) {
        return players[player].ticketsPacksBuyed;
    }

    function bytesToAddress(bytes data) private pure returns (address addr) {
        assembly {
            addr := mload(add(data, 0x14))
        }
    }
}


/**
 * @title SafeMath
 * @dev Math operations with safety checks that revert on error
 */
library SafeMath {
    /**
    * @dev Multiplies two numbers, reverts on overflow.
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
    * @dev Integer division of two numbers truncating the quotient, reverts on division by zero.
    */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
    * @dev Subtracts two numbers, reverts on overflow (i.e. if subtrahend is greater than minuend).
    */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a);
        uint256 c = a - b;

        return c;
    }

    /**
    * @dev Adds two numbers, reverts on overflow.
    */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a);

        return c;
    }

    /**
    * @dev Divides two numbers and returns the remainder (unsigned integer modulo),
    * reverts when dividing by zero.
    */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0);
        return a % b;
    }
}