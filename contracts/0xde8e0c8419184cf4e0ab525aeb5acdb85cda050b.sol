/*
* The "Become a Billionaire" decentralized Raffle v1.0, Main-Net Release.
* ~by Gluedog 
* -----------
* 
* Compiler version: 0.4.19+commit.c4cbbb05.Emscripten.clang
* 
* The weekly Become a Billionaire decentralized raffle is the basis of the deflationary mechanism for Billionaire Token
* ---------------------------------------------------------------------------------------------------------------------
* Every week, users can register 10 XBL to an Ethereum Smart Contract address – this is the equivalent of buying one ticket,
*     more tickets mean a better chance to win. Users can buy an unlimited number of tickets to increase their chances.
*     At the end of the week, the Smart Contract will choose three winners at random. First place will get 40% of
*     the tokens  that were raised during that week, second place gets 20% and third place gets 10%.
*     From the remaining 30% of the tokens: 10% are burned – as an offering to the market gods. The other 20% are sent
*     to another Smart Contract Address that works like a twisted faucet – rewarding people for burning their own coins.
* 
* The Become a Billionaire raffle Smart Contract will run forever, and will have an internal timer that will reset
*     itself every seven days or after there have been 256 tickets registered to the Raffle. The players are registered
*     by creating an internal mapping, inside the Smart Contract, a mapping of every address that registers tokens to 
*     it and their associated number of tickets. This mapping is reset every time the internal timer resets (every seven days).
*/

pragma solidity ^0.4.8;
contract XBL_ERC20Wrapper
{
    function transferFrom(address from, address to, uint value) returns (bool success);
    function transfer(address _to, uint _value) returns (bool success);
    function allowance(address _owner, address _spender) constant returns (uint256 remaining);
    function burn(uint256 _value) returns (bool success);
    function balanceOf(address _owner) constant returns (uint256 balance);
    function totalSupply() constant returns (uint256 total_supply);
}

contract BillionaireTokenRaffle
{
    address private winner1;
    address private winner2;
    address private winner3;

    address public XBLContract_addr;
    address public burner_addr;
    address public raffle_addr;
    address private owner_addr;

    address[] private raffle_bowl; /* Holds ticket entries */
    address[] private participants;
    uint256[] private seeds;

    uint64 public unique_players; /* Unique number of addresses registered in a week */
    uint256 public total_burned_by_raffle;
    uint256 public next_week_timestamp;
    uint256 private minutes_in_a_week = 10080;
    uint256 public raffle_balance;
    uint256 public ticket_price;
    uint256 public current_week;
    uint256 public total_supply;
    /* Initiate the XBL token wrapper */
    XBL_ERC20Wrapper private ERC20_CALLS;

    mapping(address => uint256) public address_to_tickets; /* Will be made private after open beta is finished. */
    mapping(address => uint256) public address_to_tokens_prev_week0; /* Variables which will be made public  */
    mapping(address => uint256) public address_to_tokens_prev_week1; /*  after each week's raffle has ended */

    uint8 public prev_week_ID; /* Keeps track of which variable is the correct indicator of prev week mapping
                                    Can only be [0] or [1]. */
    address public lastweek_winner1;
    address public lastweek_winner2;
    address public lastweek_winner3;

    /* Init */
    function BillionaireTokenRaffle()
    {
        /* Billionaire Token contract address */
        XBLContract_addr = 0x49AeC0752E68D0282Db544C677f6BA407BA17ED7;
        ERC20_CALLS = XBL_ERC20Wrapper(XBLContract_addr);
        total_supply = ERC20_CALLS.totalSupply();
        ticket_price = 10000000000000000000; /* 10 XBL  */
        raffle_addr = address(this); /* Own address                              */
        owner_addr = msg.sender; /* Set the owner address as the initial sender */
        next_week_timestamp = now + minutes_in_a_week * 1 minutes; /* Will get set every time resetRaffle() is called */
    }

    /* A modifier that can be applied to functions to only allow the owner to execute them.       */
    /* This is very useful in cases where one would like to upgrade the deflationary algorithm.   */
    /* We can simply use setter functions on the "Burner address",                                */
    /* so that if we update the Burner, we can just point the Raffle to the new version of it.    */
    modifier onlyOwner()
    {
        require (msg.sender == owner_addr);
        _;
    }

    modifier onlyBurner()
    {
        require(msg.sender == burner_addr);
        _;
    }

    /* <<<--- Burner accesible functions --->>> */
    /* <<<--- Burner accesible functions --->>> */
    /* <<<--- Burner accesible functions --->>> */

    function getLastWeekStake(address user_addr) public onlyBurner returns (uint256 last_week_stake)
    {   /* The burner accesses this function to retrieve each player's stake from the previous week. */
        if (prev_week_ID == 0)
            return address_to_tokens_prev_week1[user_addr];
        if (prev_week_ID == 1)
            return address_to_tokens_prev_week0[user_addr];
    }

    function reduceLastWeekStake(address user_addr, uint256 amount) public onlyBurner
    {   /* After a succesful burn, the burner will call this function and reduce the player's last_week_stake. */
        if (prev_week_ID == 0)
            address_to_tokens_prev_week1[user_addr] -= amount;
        if (prev_week_ID == 1)
            address_to_tokens_prev_week0[user_addr] -= amount;
    }

    /* <<<--- Public utility functions --->>> */
    /* <<<--- Public utility functions --->>> */
    /* <<<--- Public utility functions --->>> */

    function registerTickets(uint256 number_of_tickets) public returns (int8 registerTickets_STATUS)
    {
        /*  registerTickets RETURN CODES:

            [-6] - Raffle still has tickets after fillBurner() called 
            [-5] - fillBurner() null burner addr, raised error
            [-4] - fillWeeklyArrays() prev_week_ID invalid value, raised error.
            [-3] - getWinners() fail, raised error.
            [-2] - ACTUAL ALLOWANCE CHECK MISMATCH.
            [-1] - INVALID INPUT (zero or too many tickets).
            [0 ] - REGISTERED OK.                                   */

        /* Check the ticket amount limit (256 max) */
        if (raffle_bowl.length > 256)
        {
            next_week_timestamp = now;
        }

        /* Check the time limit, one week is max. */
        if (now >= next_week_timestamp)
        {
            int8 RAFFLE_STATUS = resetRaffle();
            /* Error checks */
            if (RAFFLE_STATUS == -2)
                return -3; /* getWinners() errored, raise it! */

            if (RAFFLE_STATUS == -3)
                return -5; /* fillBurner() errored, raise it! */

            if (RAFFLE_STATUS == -4)
                return -6; /* Raffle still has tickets after fillBurner() called */
        }
        /* Before users will call registerTickets function,they will first have to call approve()    */
        /* on the XBL contract address and approve the Raffle to spend tokens on their behalf.      */
        /* After they have called approve, they will have to call this registerTickets() function  */

        if ( (number_of_tickets == 0) || (number_of_tickets > 5) || (address_to_tickets[msg.sender] >= 5) )
            return -1; /* Invalid Input */

        if (ERC20_CALLS.allowance(msg.sender, raffle_addr) < ticket_price * number_of_tickets)
            return -2; /* Allowance check mismatch */

        if (ERC20_CALLS.balanceOf(msg.sender) < ticket_price * number_of_tickets) 
            return - 2; /* Allowance check mismatch */

        /*  Reaching this point means the ticket registrant is legit  */
        /*  Every ticket will add an entry to the raffle_bowl         */
        if (fillWeeklyArrays(number_of_tickets, msg.sender) == -1)
            return -4; /* prev_week_ID invalid value */

        else
        {   /* Everything checks out, transfer the coins from the user to the Raffle */
            ERC20_CALLS.transferFrom(msg.sender, raffle_addr, number_of_tickets * ticket_price);
            return 0; 
        }
    }

    /* <<<--- Owner functions --->>> */
    /* <<<--- Owner functions --->>> */
    /* <<<--- Owner functions --->>> */

    function setBurnerAddress(address _burner_addr) public onlyOwner
    {
        burner_addr = _burner_addr;
    }

    function setTicketPrice(uint256 _ticket_price) public onlyOwner
    {
        ticket_price = _ticket_price;
    }

    function setOwnerAddr(address _owner_addr) public onlyOwner
    {
        owner_addr = _owner_addr;
    }

    /* <<<--- Internal functions --->>> */
    /* <<<--- Internal functions --->>> */
    /* <<<--- Internal functions --->>> */

    function getPercent(uint8 percent, uint256 number) private returns (uint256 result)
    {
        return number * percent / 100;
    }

    function getRand(uint256 upper_limit) private returns (uint256 random_number)
    {
        return uint(sha256(uint256(block.blockhash(block.number-1)) * uint256(sha256(msg.sender)))) % upper_limit;
    }
    
    function getRandWithSeed(uint256 upper_limit, uint seed) private returns (uint256 random_number)
    {
        return seed % upper_limit;
    }

    function resetWeeklyVars() private returns (bool success)
    {   /*  After the weekly vars have been been reset, the player that last
            registered (if this gets called from registerTickets()) will have
            to have his tickets added to next week's Raffle Bowl.               */

        total_supply = ERC20_CALLS.totalSupply();

        /* Clear everything. */
        for (uint i = 0; i < participants.length; i++)
        {
            address_to_tickets[participants[i]] = 0;

            /* Clear the opposite of whatever prev_week_ID is */
            if (prev_week_ID == 0)
                address_to_tokens_prev_week1[participants[i]] = 0;
            if (prev_week_ID == 1)
                address_to_tokens_prev_week0[participants[i]] = 0;
        }

        seeds.length = 0;
        raffle_bowl.length = 0;
        participants.length = 0;
        unique_players = 0;
        
        lastweek_winner1 = winner1;
        lastweek_winner2 = winner2;
        lastweek_winner3 = winner3;
        winner1 = 0x0;
        winner2 = 0x0;
        winner3 = 0x0;
        
        prev_week_ID++;
        if (prev_week_ID == 2)
            prev_week_ID = 0;

        return success;
    }

    function resetRaffle() private returns (int8 resetRaffle_STATUS)
    {
        /*  resetRaffle STATUS CODES:

            [-5] - burnTenPercent() error            
            [-4] - Raffle still has tokens after fillBurner().
            [-3] - fillBurner() error.
            [-2] - getWinners() error.
            [-1] - We have no participants.
            [0 ] - ALL OK.
            [1 ] - Only one player, was refunded.
            [2 ] - Two players, were refunded.
            [3 ] - Three players, refunded.            */

        while (now >= next_week_timestamp)
        {
            next_week_timestamp += minutes_in_a_week * 1 minutes;
            current_week++;
        }

        if (raffle_bowl.length == 0)
        {   /*   We have no registrants.  */
            /* Reset the stats and return */
            resetWeeklyVars(); 
            return -1;
        }

        if (unique_players < 4)
        {   /* We have between 1 and three players in the raffle */
            for (uint i = 0; i < raffle_bowl.length; i++)
            { /* Refund their tokens */ 
                if (address_to_tickets[raffle_bowl[i]] != 0)
                {
                    ERC20_CALLS.transfer(raffle_bowl[i], address_to_tickets[raffle_bowl[i]] * ticket_price);
                    address_to_tickets[raffle_bowl[i]] = 0;
                }
            }
            /* Reset variables. */
            resetWeeklyVars();
            /* Return 1, 2 or 3 depending on how many raffle players were refunded */
            return int8(unique_players);
        }
        /* At this point we assume that we have more than three unique players */
        getWinners(); /* Choose three winners */

        /* Do we have winners? */
        if ( (winner1 == 0x0) || (winner2 == 0x0) || (winner3 == 0x0) )
            return -2;

        /* We have three winners! Proceed with rewards */
        raffle_balance = ERC20_CALLS.balanceOf(raffle_addr);

        /* Transfer 40%, 20% and 10% of the tokens to their respective winners */ 
        ERC20_CALLS.transfer(winner1, getPercent(40, raffle_balance));
        ERC20_CALLS.transfer(winner2, getPercent(20, raffle_balance));
        ERC20_CALLS.transfer(winner3, getPercent(10, raffle_balance));
        /* Burn 10% */
        if (burnTenPercent(raffle_balance) != true)
            return -5;

        /* Fill the burner with the rest of the tokens. */
        if (fillBurner() == -1)
            return -3; /* Burner addr NULL | error */ 

        /* Reset variables. */
        resetWeeklyVars();

        if (ERC20_CALLS.balanceOf(raffle_addr) > 0)
            return -4; /* We still have a positive balance | error */

        return 0; /* Everything OK */
    }

    function getWinners() private returns (int8 getWinners_STATUS)
    {
        /* Acquire the first random number using previous blockhash as an initial seed. */
        uint initial_rand = getRand(seeds.length);

        /* Use this first random number to choose one of the seeds from the array. */
        uint firstwinner_rand = getRandWithSeed(seeds.length, seeds[initial_rand]);

        /* This new random number is used to grab the first winner's index from raffle_bowl. */
        winner1 = raffle_bowl[firstwinner_rand];

        /* Find the position of winner1 in participants[] */
        for (uint16 i = 0; i < participants.length; i++)
        {
            if (participants[i] == winner1)
            {
                uint16 winner1_index = i;
                break;
            }
        }

        /* Then choose two more winners, based on the initial position of winner1, looping over participants[] now. */
        if (winner1_index+1 >= participants.length)
        {
            winner2 = participants[0];
            winner3 = participants[1];

            return 0;
        }

        if (winner1_index+2 >= participants.length)
        {
            winner2 = participants[winner1_index+1];
            winner3 = participants[0];

            return 0;
        }

        winner2 = participants[winner1_index+1];
        winner3 = participants[winner1_index+2];

        return 0;
    }

    function fillBurner() private returns (int8 fillBurner_STATUS)
    {
        /* [-1]: Burner Address NULL
        *  [ 0]: OK
        */
        if (burner_addr == 0x0)
            return -1;

        ERC20_CALLS.transfer(burner_addr, ERC20_CALLS.balanceOf(raffle_addr));
        return 0;
    }

    function fillWeeklyArrays(uint256 number_of_tickets, address user_addr) private returns (int8 fillWeeklyArrays_STATUS)
    {
        /*  [-1] Error with prev_week_ID
        *   [0]  OK                        */

        if ((prev_week_ID != 0) && (prev_week_ID != 1))
            return -1;

        /* Record unique players. */
        if (address_to_tickets[user_addr] == 0)
        {
            unique_players++;
            participants.push(user_addr);
        }

        address_to_tickets[user_addr] += number_of_tickets;
        
        if (prev_week_ID == 0)
            address_to_tokens_prev_week0[user_addr] += number_of_tickets * ticket_price;
        if (prev_week_ID == 1)
            address_to_tokens_prev_week1[user_addr] += number_of_tickets * ticket_price;

        uint256 _ticket_number = number_of_tickets;
        while (_ticket_number > 0)
        {
            raffle_bowl.push(user_addr);
            _ticket_number--;
        }
        /* Capture a seed from the user. */
        seeds.push(uint(sha256(user_addr)) * uint(sha256(now)));

        return 0;
    }

    function burnTenPercent(uint256 raffle_balance) private returns (bool success_state)
    {
        uint256 amount_to_burn = getPercent(10, raffle_balance);
        total_burned_by_raffle += amount_to_burn;
        /* Burn the coins, return success state */
        if (ERC20_CALLS.burn(amount_to_burn) == true)
            return true;
        else
            return false;
    }

    /* <<<--- Debug ONLY functions --->>> */
    /* <<<--- Debug ONLY functions --->>> */
    /* <<<--- Debug ONLY functions --->>> */

    function dSET_XBL_ADDRESS(address _XBLContract_addr) public onlyOwner
    {   /* These will be hardcoded in the production version. */
        XBLContract_addr = _XBLContract_addr;
        ERC20_CALLS = XBL_ERC20Wrapper(XBLContract_addr);
        total_supply = ERC20_CALLS.totalSupply();
    }

    function dTRIGGER_NEXTWEEK_TIMESTAMP() public onlyOwner
    {   /* Trigger end week quicker. */
        next_week_timestamp = now;
    }

    function dKERNEL_PANIC() public onlyOwner
    {   /* Out of Gas panic function. */
        for (uint i = 0; i < raffle_bowl.length; i++)
        { /* Refund everyone's tokens */ 
            if (address_to_tickets[raffle_bowl[i]] != 0)
            {
                ERC20_CALLS.transfer(raffle_bowl[i], address_to_tickets[raffle_bowl[i]] * ticket_price);
                address_to_tickets[raffle_bowl[i]] = 0;
            }
        }
    }
}