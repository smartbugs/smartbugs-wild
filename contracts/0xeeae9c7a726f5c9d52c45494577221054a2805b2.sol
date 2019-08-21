pragma solidity ^0.4.24;

library SafeMath {

/**
* @dev Multiplies two numbers, throws on overflow.
*/
    function mul(uint256 a, uint256 b)
        internal
        pure
        returns (uint256 c)
    {
        if (a == 0) {
            return 0;
        }
        c = a * b;
        require(c / a == b);
        return c;
    }

    /**
    * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
    */
    function sub(uint256 a, uint256 b)
        internal
        pure
        returns (uint256)
    {
        require(b <= a);
        return a - b;
    }

    /**
    * @dev Adds two numbers, throws on overflow.
    */
    function add(uint256 a, uint256 b)
        internal
        pure
        returns (uint256 c)
    {
        c = a + b;
        require(c >= a);
        return c;
    }

    /**
    * @dev Adds two numbers, throws on overflow.
    */
    function add2(uint8 a, uint8 b)
        internal
        pure
        returns (uint8 c)
    {
        c = a + b;
        require(c >= a);
        return c;
    }


    /**
    * @dev Integer division of two numbers, truncating the quotient.
    */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0);
      // assert(b > 0); // Solidity automatically throws when dividing by 0
      // uint256 c = a / b;
      // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return a / b;
    }

    /**
    * @dev Divides two unsigned integers and returns the remainder (unsigned integer modulo),
    * reverts when dividing by zero.
    */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0);
        return a % b;
    }
    /**
     * @dev gives square root of given x.
     */
    function sqrt(uint256 x)
        internal
        pure
        returns (uint256 y)
    {
        uint256 z = ((add(x,1)) / 2);
        y = x;
        while (z < y)
        {
            y = z;
            z = ((add((x / z),z)) / 2);
        }
    }

    /**
     * @dev gives square. multiplies x by x
     */
    function sq(uint256 x)
        internal
        pure
        returns (uint256)
    {
        return (mul(x,x));
    }

    /**
     * @dev x to the power of y
     */
    function pwr(uint256 x, uint256 y)
        internal
        pure
        returns (uint256)
    {
        if (x==0)
            return (0);
        else if (y==0)
            return (1);
        else
        {
            uint256 z = x;
            for (uint256 i=1; i < y; i++)
                z = mul(z,x);
            return (z);
        }
    }
}

/* solhint-disable var-name-mixedcase */
/* solhint-disable const-name-snakecase */
/* solhint-disable code-complexity */
/* solhint-disable max-line-length */
/* solhint-disable func-name-mixedcase */
/* solhint-disable use-forbidden-name */

/*
    .___           ___.                  .__
  __| _/____   __ _\_ |__   ___________  |__| ____
 / __ |\__  \ |  |  \ __ \_/ __ \_  __ \ |  |/  _ \
/ /_/ | / __ \|  |  / \_\ \  ___/|  | \/ |  (  <_> )
\____ |(____  /____/|___  /\___  >__| /\ |__|\____/
     \/     \/          \/     \/     \/

B-I-N-G-O

for everyone....

[x] Fair
[x] Open Source
[x] Better than grandma's bingo
[x] made with <3.add(hate)

Play it!

Or don't?

Nobody cares.
*/

contract Bingo {
    using SafeMath for uint;

    MegaballInterface constant public megaballContract = MegaballInterface(address(0x3Fe2B3e8FEB33ed523cE8F786c22Cb6556f8A33F));
    DiviesInterface constant private Divies = DiviesInterface(address(0xc7029Ed9EBa97A096e72607f4340c34049C7AF48));
    uint256 constant public AGENT_END_BLOCK = 232;
    uint256 constant public ICO_BLOCK = 200;
    uint256 constant public ICO_TIME = 3600;

    event CardCreated(address indexed ticketOwner, uint indexed playerTicket, uint indexed stage);
    event Payment(address indexed customerAddress, uint indexed stage);
    event NumberCalled(uint indexed number, uint indexed stage, uint indexed total);
    /* user withdraw event */
    event OnWithdraw(address indexed customerAddress, uint256 ethereumWithdrawn);
    event StageCreated(uint indexed stageNumber);

    /* modifiers */
    modifier hasBalance() {
        require(bingoVault[msg.sender] > 0);
        _;
    }

    struct Splits {
        uint256 INCOMING_FIFTYFIVE_PERCENT;
        uint256 INCOMING_EIGHTEEN_PERCENT;
        uint256 INCOMING_TEN_PERCENT;
        uint256 INCOMING_SIX_PERCENT;
        uint256 INCOMING_FIVE_PERCENT;
        uint256 INCOMING_ONE_PERCENT;
        uint256 INCOMING_TWO_PERCENT;
        uint256 INCOMING_DENOMINATION;
    }

    /*
    fund allocation
    */
    uint256 public numberCallerPot = 0;
    uint256 public mainBingoPot = 0;
    uint256 public progressiveBingoPot = 0;
    uint256 public paybackPot = 0;
    uint256 public outboundToMegaball = 0;
    uint256 public buyP3dFunds = 0;
    uint256 public nextRoundSeed = 0;
    uint256 public prevDrawBlock = 0;

/* stages manage drawings, tickets, and peg round denominations */
    struct Stage {
        bool stageCompleted;
        bool allowTicketPurchases;
        uint256 startBlock;
        uint256 endBlock;
        uint256 nextDrawBlock;
        uint256 nextDrawTime;
        Splits stageSplits;
      //  address[] numberCallers;
        mapping(uint8 => CallStatus) calledNumbers;
        mapping(address => Card[]) playerCards;
    }

    struct CallStatus {
        bool isCalled;
        uint8 num;
    }

    struct Card {
        Row B;
        Row I;
        Row N;
        Row G;
        Row O;
        address owner;
    }

    struct Row {
        uint8 N1;
        uint8 N2;
        uint8 N3;
        uint8 N4;
        uint8 N5;
    }

    mapping(uint256 => address[]) public numberCallers;
    mapping(uint256 => Stage) public stages;
    address public owner;
    uint256 public numberOfStages = 0;
    uint8 public numbersCalledThisStage = 0;
    bool public resetDirty = false;
    uint256 public numberOfCardsThisStage = 0;

    mapping(uint256 => address[]) public entrants;

    uint256 public DENOMINATION = 7000000000000000;

    mapping (address => uint256) private bingoVault;

    address[] public paybackQueue;
    uint256 public paybackQueueCount = 0;
    uint256 public nextPayback = 0;

    address public lastCaller;
    uint8 public lastNumber;

    address public lastRef;

    constructor() public
    {
        owner = msg.sender;
        //initFirstStage();
    }

    function seedMain()
    public
    payable
    {
        require(msg.value >= 100000000000000000);
        mainBingoPot = mainBingoPot.add(msg.value);
    }


    function seedProgressive()
    public
    payable
    {
        require(msg.value >= 100000000000000000);
        progressiveBingoPot = progressiveBingoPot.add(msg.value);
    }


    function seedMegball()
    internal
    {
        if (outboundToMegaball > 10000000000000000000) {
            uint256 value = outboundToMegaball;
            outboundToMegaball = 0;
            megaballContract.seedJackpot.value(value)();
        }
    }

    function withdrawFromMB()
    internal
    {
        uint256 amount = megaballContract.getMoneyballBalance();
        if (amount > 10000000000000000) {
            mainBingoPot = mainBingoPot.add(amount);
            megaballContract.withdraw();
        }
    }

    function()
    public
    payable
    {

    }

    function getMBbalance()
    public
    view
    returns (uint)
    {
      return megaballContract.getMoneyballBalance();
    }

    function withdraw()
    external
    hasBalance
    {
        uint256 amount = bingoVault[msg.sender];
        bingoVault[msg.sender] = 0;

        emit OnWithdraw(msg.sender, amount);
        msg.sender.transfer(amount);
    }

    function initFirstStage()
    public
    {
        require(numberOfStages == 0);
        CreateStage();
    }

    function sendDivi()
    private
    {

        uint256 lsend = buyP3dFunds;
        if (lsend > 0) {
            buyP3dFunds = 0;
            Divies.deposit.value(lsend)();
        }
    }

    function getStageDrawTime(uint256 _stage)
    public
    view
    returns (uint256, uint256)
    {
        return (stages[_stage].nextDrawTime, stages[_stage].nextDrawBlock);
    }

    function isCallNumberAvailable(uint256 _stage)
    public
    view
    returns (bool, uint256, uint256)
    {
        if (stages[_stage].nextDrawBlock < block.number && stages[_stage].nextDrawTime < now)
        {
            return (true, 0, 0);
        }
        uint256 blocks = stages[_stage].nextDrawBlock.sub(block.number);
        uint256 time = stages[_stage].nextDrawTime.sub(now);
        return (false, blocks, time);
    }

    function stageMoveDetail(uint256 _stage)
    public
    view
    returns (uint, uint)
    {
        uint256 blocks = 0;
        uint256 time = 0;

        if (stages[_stage].nextDrawBlock > block.number)
        {
            blocks = stages[_stage].nextDrawBlock.sub(block.number);
            blocks.add(1);
        }

        if (stages[_stage].nextDrawTime > now)
        {
            time = stages[_stage].nextDrawTime.sub(now);
            time.add(1);
        }

        return ( blocks, time );
    }

    function getMegaballStatus()
    public
    view
    returns (bool)
    {
        uint256 _stage = megaballContract.numberOfStages();
        _stage = _stage.sub(1);
        (uint256 sm1, uint256 sm2) = megaballContract.stageMoveDetail(_stage);
        if (sm1.add(sm2) == 0) {
            return true;
        }
        return false;
    }

    function updateMegaballStatus()
    private
    {
        uint256 _stage = megaballContract.numberOfStages();
        _stage = _stage.sub(1);
        (bool b1, bool b2, bool b3, bool b4) = megaballContract.getStageStatus(_stage);
        require(b1 == false);
        require(b3 == false);
        if (b4 == true) {
            if (megaballContract.getPlayerRaffleTickets() >= 10 && megaballContract.getRafflePlayerCount(_stage) > 7)
            {
                megaballContract.addPlayerToRaffle(address(this));
            }
            megaballContract.setDrawBlocks(_stage);
        }

        if (b4 == false && b2 == true) {
            if (megaballContract.isFinalizeValid(_stage)) {
                megaballContract.finalizeStage(_stage);
            }
        }
    }

    function callNumbers(uint256 _stage)
    public
    {
        require(stages[_stage].nextDrawBlock < block.number);
        require(stages[_stage].nextDrawTime <= now);
        require(numberOfCardsThisStage >= 2);
        require(stages[_stage].stageCompleted == false);

        if (numbersCalledThisStage == 0) {
            stages[_stage].allowTicketPurchases = false;
            stages[_stage].startBlock = stages[_stage].startBlock.add(block.number);
            stages[_stage].endBlock = block.number.add(AGENT_END_BLOCK);
        }


        if (getMegaballStatus()) {
            updateMegaballStatus();
            paybackQueue.push(msg.sender);
        }


        lastCaller = msg.sender;

        numberCallers[_stage].push(msg.sender);

        uint8 n1 = SafeMath.add2(1, (uint8(blockhash(stages[_stage].nextDrawBlock)) % 74));

        uint8 resetCounter = 0;
        if (isNumberCalled(_stage, n1) == false) {
            callNumber(_stage, n1);
            resetCounter++;
        }

        uint8 n2 = SafeMath.add2(1, (uint8(blockhash(stages[_stage].nextDrawBlock.sub(1))) % 74));
        if (isNumberCalled(_stage, n2) == false && resetCounter == 0) {
            callNumber(_stage, n2);
            resetCounter++;
        }

        uint8 n3 = SafeMath.add2(1, (uint8(blockhash(stages[_stage].nextDrawBlock.sub(2))) % 74));
        if (isNumberCalled(_stage, n3) == false && resetCounter == 0) {
            callNumber(_stage, n3);
            resetCounter++;
        }

        if (resetCounter == 0) {
            resetDrawBlocks(_stage);
            resetDirty = true;
        }
    }


    function roundTimeout(uint256 _stage) public {
        require(stages[_stage].endBlock < block.number);
        require(stages[_stage].nextDrawTime < now);
        require(stages[_stage].stageCompleted == false);
        stages[_stage].stageCompleted = true;
        CreateStage();
    }

    function resetDrawBlocks(uint256 _stage)
    private
    {
        prevDrawBlock = stages[_stage].nextDrawBlock;
        stages[_stage].nextDrawBlock = block.number.add(3);
        stages[_stage].nextDrawTime = now.add(30);
    }

    function callNumber(uint256 _stage, uint8 num)
    internal
    {
        require(num > 0);
        require(num < 76);
        stages[_stage].calledNumbers[num] = CallStatus(true, num);
        numbersCalledThisStage = SafeMath.add2(numbersCalledThisStage, 1);
        lastNumber = num;
        resetDrawBlocks(_stage);
        emit NumberCalled(num, numberOfStages.sub(1), numbersCalledThisStage);
    }

    function getCalledNumbers(uint256 _stage, uint8 _position)
    public
    view
    returns (uint8)
    {
        return (stages[_stage].calledNumbers[_position].num);
    }


    function isNumberCalled(uint256 _stage, uint8 num)
    public
    view
    returns (bool)
    {
        return (stages[_stage].calledNumbers[num].isCalled);
    }

    function CreateStage()
    private
    {

        if (numberOfStages > 20) {
            DENOMINATION = megaballContract.DENOMINATION();
        }

        uint256 ONE_PERCENT = calculateOnePercentTicketCostSplit(DENOMINATION);
        uint256 INCOMING_FIFTYFIVE_PERCENT = calculatePayoutDenomination(ONE_PERCENT, 55);
        uint256 INCOMING_EIGHTEEN_PERCENT = calculatePayoutDenomination(ONE_PERCENT, 18);
        uint256 INCOMING_TEN_PERCENT = calculatePayoutDenomination(ONE_PERCENT, 10);
        uint256 INCOMING_SIX_PERCENT = calculatePayoutDenomination(ONE_PERCENT, 6);
        uint256 INCOMING_FIVE_PERCENT = calculatePayoutDenomination(ONE_PERCENT, 5);
        uint256 INCOMING_TWO_PERCENT = calculatePayoutDenomination(ONE_PERCENT, 2);
        uint256 INCOMING_ONE_PERCENT = calculatePayoutDenomination(ONE_PERCENT, 1);

        Splits memory stageSplits = Splits(
        INCOMING_FIFTYFIVE_PERCENT,
        INCOMING_EIGHTEEN_PERCENT,
        INCOMING_TEN_PERCENT,
        INCOMING_SIX_PERCENT,
        INCOMING_FIVE_PERCENT,
        INCOMING_TWO_PERCENT,
        INCOMING_ONE_PERCENT,
        DENOMINATION);


        stages[numberOfStages] = Stage(
        false,
        true,
        block.number.add(ICO_BLOCK),
        block.number.add(AGENT_END_BLOCK),
        block.number.add(ICO_BLOCK),
        now.add(ICO_TIME),
        stageSplits);

        numbersCalledThisStage = 0;
        numberOfCardsThisStage = 0;
        prevDrawBlock = block.number.add(ICO_BLOCK);

        if (numberOfStages > 0) {
            uint256 value = nextRoundSeed;
            nextRoundSeed = 0;
            mainBingoPot = mainBingoPot.add(value);
            processPaybackQueue(numberOfStages);
       }

        withdrawFromMB();
        seedMegball();
        sendDivi();
        numberOfStages = numberOfStages.add(1);
        resetDirty = false;
        emit StageCreated(numberOfStages);
    }

    /* get stage blocks */
    function getStageBlocks(uint256 _stage)
    public
    view
    returns (uint, uint)
    {
        return (stages[_stage].startBlock, stages[_stage].endBlock);
    }

    /*
     this function is used for other things name it better
    */
    function calculatePayoutDenomination(uint256 _denomination, uint256 _multiple)
    private
    pure
    returns (uint256)
    {
        return SafeMath.mul(_denomination, _multiple);
    }

    /* 1% split of denomination */
    function calculateOnePercentTicketCostSplit(uint256 _denomination)
    private
    pure
    returns (uint256)
    {
        return SafeMath.div(_denomination, 100);
    }

    function sort_array(uint8[5] arr_) internal pure returns (uint8[5] )
    {
        uint8 l = 5;
        uint8[5] memory arr;

        for (uint8 i=0; i<l; i++)
        {
            arr[i] = arr_[i];
        }

        for (i = 0; i < l; i++)
        {
            for (uint8 j=i+1; j < l; j++)
            {
                if (arr[i] < arr[j])
                {
                    uint8 temp = arr[j];
                    arr[j] = arr[i];
                    arr[i] = temp;
                }
          }
        }

        return arr;
    }

    function random(uint8 startNumber, uint8 offset, uint256 _seed, uint8 blockOffset) private view returns (uint8) {
        uint b = block.number.sub(blockOffset);
        b = b.sub(offset);
        uint256 seed = uint256(keccak256(abi.encodePacked(blockhash(b))));
        seed.add(_seed);

        uint8 number = SafeMath.add2(startNumber, (uint8(uint256(keccak256(abi.encodePacked(seed))) % 14)));
        return number;
    }

    function referralSpot(uint256 _stage)
    public
    view
    returns(uint)
    {
        uint b = block.number.sub(1);

        uint256 seed = uint256(keccak256(abi.encodePacked(
            (block.timestamp).add
            (block.difficulty).add
            ((uint256(keccak256(abi.encodePacked(block.coinbase)))) / (now)).add
            (block.gaslimit).add
            ((uint256(keccak256(abi.encodePacked(msg.sender)))) / (now)).add
            (block.number)
        )));

        uint256 number = (uint256(keccak256(abi.encodePacked(blockhash(b), seed))) % entrants[_stage].length);
        return number;

    }


    function randomArr(uint8 n1, uint256 _seed, uint8 blockOffset) private view returns (uint8[5]) {
        uint8[5] memory arr = [0, 0, 0, 0, 0];

        uint8 count = 0;
        arr[0] = random(n1, count, _seed, blockOffset);

        count = SafeMath.add2(count, 1);
        while (arr[1] == 0) {
            if (random(n1, count, _seed, blockOffset) != arr[0]) {
                arr[1] = random(n1, count, _seed, blockOffset);
            }
            count = SafeMath.add2(count, 1);
        }

        while (arr[2] == 0) {
            if (random(n1, count, _seed, blockOffset) != arr[0] && random(n1, count, _seed, blockOffset) != arr[1]) {
                arr[2] = random(n1, count, _seed, blockOffset);
            }
            count = SafeMath.add2(count, 1);
        }

        while (arr[3] == 0) {
            if (random(n1, count, _seed, blockOffset) != arr[0] && random(n1, count, _seed, blockOffset) != arr[1]) {
                if (random(n1, count, _seed, blockOffset) != arr[2]) {
                    arr[3] = random(n1, count, _seed, blockOffset);
                }
            }
            count = SafeMath.add2(count, 1);
        }

        while (arr[4] == 0) {
            if (random(n1, count, _seed, blockOffset) != arr[0] && random(n1, count, _seed, blockOffset) != arr[1]) {
                if (random(n1, count, _seed, blockOffset) != arr[2] && random(n1, count, _seed, blockOffset) != arr[3]) {
                    arr[4] = random(n1, count, _seed, blockOffset);
                }
              }
            count = SafeMath.add2(count, 1);
        }
        require(count < 60);
        /**/
        return arr;
    }


    function makeRow(uint8 n1, uint256 _seed, uint8 blockOffset) private view returns (Row) {
        uint8[5] memory mem = randomArr(n1, _seed, blockOffset);
        uint8[5] memory mem2 = sort_array(mem);

        return Row(mem2[4], mem2[3], mem2[2], mem2[1], mem2[0]);
    }

    function makeCard(uint256 _seed) private view returns (Card) {

        return Card(
        makeRow(1, _seed, 0),
        makeRow(16, _seed, 15),
        makeRow(31, _seed, 30),
        makeRow(46, _seed, 45),
        makeRow(61, _seed, 60),
        msg.sender);
    }


    /* get stage denom */
    function getStageDenomination(uint256 _stage)
    public
    view
    returns (uint)
    {
        return stages[_stage].stageSplits.INCOMING_DENOMINATION;
    }

    function getStageStatus(uint256 _stage)
    public
    view
    returns (bool)
    {
        return (stages[_stage].allowTicketPurchases);
    }

    function getEntrant(uint256 _stage, uint256 _pos)
    public
    view
    returns (address)
    {
        return entrants[_stage][_pos];
    }

    //entrants[_stage][_pos]

    function createCard(uint256 _stage, uint256 _seed, uint8 team)
    external
    payable
    {
        require(stages[_stage].allowTicketPurchases);
        require(msg.value == stages[_stage].stageSplits.INCOMING_DENOMINATION);
        require(_seed > 0);
        require(team > 0);
        require(team < 4);
        numberOfCardsThisStage = numberOfCardsThisStage.add(1);

        /* alpha */
        if (team == 1) {
            mainBingoPot = mainBingoPot.add(stages[_stage].stageSplits.INCOMING_FIFTYFIVE_PERCENT);
            numberCallerPot = numberCallerPot.add(stages[_stage].stageSplits.INCOMING_EIGHTEEN_PERCENT);
            progressiveBingoPot = progressiveBingoPot.add(stages[_stage].stageSplits.INCOMING_TEN_PERCENT);
            nextRoundSeed = nextRoundSeed.add(stages[_stage].stageSplits.INCOMING_SIX_PERCENT);
            paybackPot = paybackPot.add(stages[_stage].stageSplits.INCOMING_FIVE_PERCENT);
            buyP3dFunds = buyP3dFunds.add(stages[_stage].stageSplits.INCOMING_TWO_PERCENT);
            outboundToMegaball = outboundToMegaball.add(stages[_stage].stageSplits.INCOMING_ONE_PERCENT);
        }

        /* beta */
        if (team == 2) {
            mainBingoPot = mainBingoPot.add(stages[_stage].stageSplits.INCOMING_FIFTYFIVE_PERCENT);
            paybackPot = paybackPot.add(stages[_stage].stageSplits.INCOMING_EIGHTEEN_PERCENT);
            numberCallerPot = numberCallerPot.add(stages[_stage].stageSplits.INCOMING_TEN_PERCENT);
            progressiveBingoPot = progressiveBingoPot.add(stages[_stage].stageSplits.INCOMING_SIX_PERCENT);
            buyP3dFunds = buyP3dFunds.add(stages[_stage].stageSplits.INCOMING_FIVE_PERCENT);
            nextRoundSeed = nextRoundSeed.add(stages[_stage].stageSplits.INCOMING_TWO_PERCENT);
            outboundToMegaball = outboundToMegaball.add(stages[_stage].stageSplits.INCOMING_ONE_PERCENT);
        }

        /* omega */
        if (team == 3) {
            mainBingoPot = mainBingoPot.add(stages[_stage].stageSplits.INCOMING_FIFTYFIVE_PERCENT);
            mainBingoPot = mainBingoPot.add(stages[_stage].stageSplits.INCOMING_EIGHTEEN_PERCENT);
            numberCallerPot = numberCallerPot.add(stages[_stage].stageSplits.INCOMING_TEN_PERCENT);
            progressiveBingoPot = progressiveBingoPot.add(stages[_stage].stageSplits.INCOMING_TWO_PERCENT);
            outboundToMegaball = outboundToMegaball.add(stages[_stage].stageSplits.INCOMING_SIX_PERCENT);
            buyP3dFunds = buyP3dFunds.add(stages[_stage].stageSplits.INCOMING_FIVE_PERCENT);
            nextRoundSeed = nextRoundSeed.add(stages[_stage].stageSplits.INCOMING_ONE_PERCENT);
        }


          //THERES A MYSTERY 3% we assume and done store cuz of stack depth problems w/ struct

        if (entrants[_stage].length > 5) {
        //    uint256 aa = 20;
            address az = getEntrant(_stage, referralSpot(_stage));
            lastRef = az;
            payReferral(az, stages[_stage].stageSplits.INCOMING_TWO_PERCENT);
            payReferral(az, stages[_stage].stageSplits.INCOMING_ONE_PERCENT);
        }

        if (entrants[_stage].length <= 5) {
            payReferral(msg.sender, stages[_stage].stageSplits.INCOMING_TWO_PERCENT);
            payReferral(msg.sender, stages[_stage].stageSplits.INCOMING_ONE_PERCENT);
        }


        /* push ticket into users stage def */
        stages[_stage].playerCards[msg.sender].push(makeCard(_seed));
        entrants[_stage].push(msg.sender);
        stages[_stage].nextDrawTime = stages[_stage].nextDrawTime.add(1);
        emit CardCreated(msg.sender, stages[_stage].playerCards[msg.sender].length, numberOfStages);

    }


    function payReferral(address _player, uint256 _amount)
    private
    {
        bingoVault[_player] = bingoVault[_player].add(_amount);
    }

    /* contract balance */
    function getContractBalance() public view returns (uint) {
        return address(this).balance;
    }

    function claimBingo(uint256 _stage, uint256 _position)
    external
    {
        require(stages[_stage].stageCompleted == false, "stage must be incomplete");
        if (checkBingo(_stage, _position) == true) {
            stages[_stage].stageCompleted = true;
            stages[_stage].endBlock = block.number;
            payTicket(_stage, msg.sender);
            payProgressive(_stage, msg.sender);
            payCaller(_stage);
            repayment(_stage, msg.sender);
            processPaybackQueue(_stage);
            CreateStage();
        }
    }

    function processPaybackQueue(uint256 _stage)
    private
    {
        uint256 paybackLength = paybackQueue.length;
        uint256 value = paybackPot;
        if (paybackLength > nextPayback) {
            if (value > DENOMINATION) {
                paybackPot = paybackPot.sub(DENOMINATION);
                address _player = paybackQueue[nextPayback];
                nextPayback = nextPayback.add(1);
                bingoVault[_player] = bingoVault[_player].add(DENOMINATION);
                emit Payment(_player, _stage);
            }
        }
    }


    function payCaller(uint256 _stage)
    private
    {
        if (numberCallerPot > 0) {
            uint256 amount = numberCallerPot;
            numberCallerPot = 0;
            uint256 callerCount = numberCallers[_stage].length;
            uint256 n1 = (uint256(blockhash(prevDrawBlock)) % callerCount);
            address a1 = numberCallers[_stage][n1];
            bingoVault[a1] = bingoVault[a1].add(amount);
            emit Payment(a1, _stage);
        }
    }

    function payProgressive(uint256 _stage, address _player)
    private
    {
        if (numbersCalledThisStage <= 10 && resetDirty == false) {
            uint256 progressiveLocal = progressiveBingoPot;
            uint256 ONE_PERCENT = calculateOnePercentTicketCostSplit(progressiveLocal);
            uint256 amount = calculatePayoutDenomination(ONE_PERCENT, 50);
            if (numbersCalledThisStage == 5) {
                amount = calculatePayoutDenomination(ONE_PERCENT, 100);
            }
            if (numbersCalledThisStage == 6) {
                amount = calculatePayoutDenomination(ONE_PERCENT, 90);
            }
            if (numbersCalledThisStage == 7) {
                amount = calculatePayoutDenomination(ONE_PERCENT, 80);
            }
            if (numbersCalledThisStage == 8) {
                amount = calculatePayoutDenomination(ONE_PERCENT, 70);
            }
            progressiveBingoPot = progressiveBingoPot.sub(amount);
            bingoVault[_player] = bingoVault[_player].add(amount);
            emit Payment(_player, _stage);
        }
    }

    function payTicket(uint256 _stage, address _player)
    private
    {
        if (mainBingoPot > 0) {
            uint256 amount = mainBingoPot;
            mainBingoPot = 0;
            bingoVault[_player] = bingoVault[_player].add(amount);
            emit Payment(_player, _stage);
        }
    }

    function repayment(uint256 _stage, address _player)
    private
    {
        if (numberOfCardsThisStage == 2) {
            addToPaybacks(_stage, _player, 2);
        }

        if (numberOfCardsThisStage == 3) {
            addToPaybacks(_stage, _player, 3);
        }

        if (numberOfCardsThisStage == 4) {
            addToPaybacks(_stage, _player, 4);
        }

        if (numberOfCardsThisStage == 5) {
            addToPaybacks(_stage, _player, 5);
        }

        if (numberOfCardsThisStage > 5) {
            uint256 playerCount = entrants[_stage].length;
            uint256 n1 = (uint256(blockhash(prevDrawBlock)) % playerCount);
            paybackQueue.push(entrants[_stage][n1]);
        }

    }

    function addToPaybacks(uint256 _stage, address _player, uint8 _max)
    private
    {
        for (uint8 x = 0; x < _max; x++) {
            if (entrants[_stage][x] != _player && entrants[_stage][x] != lastCaller) {paybackQueue.push(entrants[_stage][x]);}
        }

    }

    /* get number of players in raffle drawing */

    function getNumberCallersCount(uint256 _stage)
    public
    view
    returns (uint)
    {
        return numberCallers[_stage].length;
    }


    /* get number of players in raffle drawing */
    function getPaybackPlayerCount()
    public
    view
    returns (uint)
    {
        return paybackQueue.length;
    }

    /* get number of players in raffle drawing */
    function getEntrantsPlayerCount(uint256 _stage)
    public
    view
    returns (uint)
    {
        return entrants[_stage].length;
    }

    /*
    *  balance functions
    *  players main game balance
    */
    function getBingoBalance() public view returns (uint) {
        return bingoVault[msg.sender];
    }


    function checkBingo(uint256 _stage, uint256 _position)
    public
    view
    returns (bool)
    {

        if (checkB(_stage, _position) == 5) { return true;}
        if (checkI(_stage, _position) == 5) { return true;}
        if (checkN(_stage, _position) == 5) { return true;}
        if (checkG(_stage, _position) == 5) { return true;}
        if (checkO(_stage, _position) == 5) { return true;}
        if (checkH1(_stage, _position) == 5) { return true;}
        if (checkH2(_stage, _position) == 5) { return true;}
        if (checkH3(_stage, _position) == 5) { return true;}
        if (checkH4(_stage, _position) == 5) { return true;}
        if (checkH5(_stage, _position) == 5) { return true;}
        if (checkD1(_stage, _position) == 5) { return true;}
        if (checkD2(_stage, _position) == 5) { return true;}
        return false;
    }

    function checkD1(uint256 _stage, uint256 _position)
    internal
    view
    returns (uint8) {
        require(_stage <= SafeMath.sub(numberOfStages, 1));
        uint8 count = 0;
        if (isNumberCalled(_stage, stages[_stage].playerCards[msg.sender][_position].B.N1)) {count = SafeMath.add2(count, 1);}
        if (isNumberCalled(_stage, stages[_stage].playerCards[msg.sender][_position].I.N2)) {count = SafeMath.add2(count, 1);}
        if (isNumberCalled(_stage, stages[_stage].playerCards[msg.sender][_position].N.N3)) {count = SafeMath.add2(count, 1);}
        if (isNumberCalled(_stage, stages[_stage].playerCards[msg.sender][_position].G.N4)) {count = SafeMath.add2(count, 1);}
        if (isNumberCalled(_stage, stages[_stage].playerCards[msg.sender][_position].O.N5)) {count = SafeMath.add2(count, 1);}
        return count;
    }

    function checkD2(uint256 _stage, uint256 _position)
    internal
    view
    returns (uint8) {
        require(_stage <= SafeMath.sub(numberOfStages, 1));
        uint8 count = 0;
        if (isNumberCalled(_stage, stages[_stage].playerCards[msg.sender][_position].B.N5)) {count = SafeMath.add2(count, 1);}
        if (isNumberCalled(_stage, stages[_stage].playerCards[msg.sender][_position].I.N4)) {count = SafeMath.add2(count, 1);}
        if (isNumberCalled(_stage, stages[_stage].playerCards[msg.sender][_position].N.N3)) {count = SafeMath.add2(count, 1);}
        if (isNumberCalled(_stage, stages[_stage].playerCards[msg.sender][_position].G.N2)) {count = SafeMath.add2(count, 1);}
        if (isNumberCalled(_stage, stages[_stage].playerCards[msg.sender][_position].O.N1)) {count = SafeMath.add2(count, 1);}
        return count;
    }

    function checkB(uint256 _stage, uint256 _position)
    internal
    view
    returns (uint8) {
        require(_stage <= SafeMath.sub(numberOfStages, 1));
        uint8 count = 0;
        if (isNumberCalled(_stage, stages[_stage].playerCards[msg.sender][_position].B.N1)) {count = SafeMath.add2(count, 1);}
        if (isNumberCalled(_stage, stages[_stage].playerCards[msg.sender][_position].B.N2)) {count = SafeMath.add2(count, 1);}
        if (isNumberCalled(_stage, stages[_stage].playerCards[msg.sender][_position].B.N3)) {count = SafeMath.add2(count, 1);}
        if (isNumberCalled(_stage, stages[_stage].playerCards[msg.sender][_position].B.N4)) {count = SafeMath.add2(count, 1);}
        if (isNumberCalled(_stage, stages[_stage].playerCards[msg.sender][_position].B.N5)) {count = SafeMath.add2(count, 1);}
        return count;
    }

    function checkI(uint256 _stage, uint256 _position)
    internal
    view
    returns (uint8) {
        require(_stage <= SafeMath.sub(numberOfStages, 1));
        uint8 count = 0;
        if (isNumberCalled(_stage, stages[_stage].playerCards[msg.sender][_position].I.N1)) {count = SafeMath.add2(count, 1);}
        if (isNumberCalled(_stage, stages[_stage].playerCards[msg.sender][_position].I.N2)) {count = SafeMath.add2(count, 1);}
        if (isNumberCalled(_stage, stages[_stage].playerCards[msg.sender][_position].I.N3)) {count = SafeMath.add2(count, 1);}
        if (isNumberCalled(_stage, stages[_stage].playerCards[msg.sender][_position].I.N4)) {count = SafeMath.add2(count, 1);}
        if (isNumberCalled(_stage, stages[_stage].playerCards[msg.sender][_position].I.N5)) {count = SafeMath.add2(count, 1);}
        return count;
    }

    function checkN(uint256 _stage, uint256 _position)
    internal
    view
    returns (uint8)  {
        require(_stage <= SafeMath.sub(numberOfStages, 1));
        uint8 count = 0;
        if (isNumberCalled(_stage, stages[_stage].playerCards[msg.sender][_position].N.N1)) {count = SafeMath.add2(count, 1);}
        if (isNumberCalled(_stage, stages[_stage].playerCards[msg.sender][_position].N.N2)) {count = SafeMath.add2(count, 1);}
        if (isNumberCalled(_stage, stages[_stage].playerCards[msg.sender][_position].N.N3)) {count = SafeMath.add2(count, 1);}
        if (isNumberCalled(_stage, stages[_stage].playerCards[msg.sender][_position].N.N4)) {count = SafeMath.add2(count, 1);}
        if (isNumberCalled(_stage, stages[_stage].playerCards[msg.sender][_position].N.N5)) {count = SafeMath.add2(count, 1);}
        return count;
    }

    function checkG(uint256 _stage, uint256 _position) public view returns (uint8)  {
        require(_stage <= SafeMath.sub(numberOfStages, 1));
        uint8 count = 0;
        if (isNumberCalled(_stage, stages[_stage].playerCards[msg.sender][_position].G.N1)) {count = SafeMath.add2(count, 1);}
        if (isNumberCalled(_stage, stages[_stage].playerCards[msg.sender][_position].G.N2)) {count = SafeMath.add2(count, 1);}
        if (isNumberCalled(_stage, stages[_stage].playerCards[msg.sender][_position].G.N3)) {count = SafeMath.add2(count, 1);}
        if (isNumberCalled(_stage, stages[_stage].playerCards[msg.sender][_position].G.N4)) {count = SafeMath.add2(count, 1);}
        if (isNumberCalled(_stage, stages[_stage].playerCards[msg.sender][_position].G.N5)) {count = SafeMath.add2(count, 1);}
        return count;
    }

    function checkO(uint256 _stage, uint256 _position)
    internal
    view
    returns (uint8)  {
        require(_stage <= SafeMath.sub(numberOfStages, 1));
        uint8 count = 0;
        if (isNumberCalled(_stage, stages[_stage].playerCards[msg.sender][_position].O.N1)) {count = SafeMath.add2(count, 1);}
        if (isNumberCalled(_stage, stages[_stage].playerCards[msg.sender][_position].O.N2)) {count = SafeMath.add2(count, 1);}
        if (isNumberCalled(_stage, stages[_stage].playerCards[msg.sender][_position].O.N3)) {count = SafeMath.add2(count, 1);}
        if (isNumberCalled(_stage, stages[_stage].playerCards[msg.sender][_position].O.N4)) {count = SafeMath.add2(count, 1);}
        if (isNumberCalled(_stage, stages[_stage].playerCards[msg.sender][_position].O.N5)) {count = SafeMath.add2(count, 1);}
        return count;
    }

    function checkH1(uint256 _stage, uint256 _position)
    internal
    view
    returns (uint8) {
        require(_stage <= SafeMath.sub(numberOfStages, 1));
        uint8 count = 0;
        if (isNumberCalled(_stage, stages[_stage].playerCards[msg.sender][_position].B.N1)) {count = SafeMath.add2(count, 1);}
        if (isNumberCalled(_stage, stages[_stage].playerCards[msg.sender][_position].I.N1)) {count = SafeMath.add2(count, 1);}
        if (isNumberCalled(_stage, stages[_stage].playerCards[msg.sender][_position].N.N1)) {count = SafeMath.add2(count, 1);}
        if (isNumberCalled(_stage, stages[_stage].playerCards[msg.sender][_position].G.N1)) {count = SafeMath.add2(count, 1);}
        if (isNumberCalled(_stage, stages[_stage].playerCards[msg.sender][_position].O.N1)) {count = SafeMath.add2(count, 1);}
        return count;
    }

    function checkH2(uint256 _stage, uint256 _position)
    internal
    view
    returns (uint8) {
        require(_stage <= SafeMath.sub(numberOfStages, 1));
        uint8 count = 0;
        if (isNumberCalled(_stage, stages[_stage].playerCards[msg.sender][_position].B.N2)) {count = SafeMath.add2(count, 1);}
        if (isNumberCalled(_stage, stages[_stage].playerCards[msg.sender][_position].I.N2)) {count = SafeMath.add2(count, 1);}
        if (isNumberCalled(_stage, stages[_stage].playerCards[msg.sender][_position].N.N2)) {count = SafeMath.add2(count, 1);}
        if (isNumberCalled(_stage, stages[_stage].playerCards[msg.sender][_position].G.N2)) {count = SafeMath.add2(count, 1);}
        if (isNumberCalled(_stage, stages[_stage].playerCards[msg.sender][_position].O.N2)) {count = SafeMath.add2(count, 1);}
        return count;
    }

    function checkH3(uint256 _stage, uint256 _position)
    internal
    view
    returns (uint8) {
        require(_stage <= SafeMath.sub(numberOfStages, 1));
        uint8 count = 0;
        if (isNumberCalled(_stage, stages[_stage].playerCards[msg.sender][_position].B.N3)) {count = SafeMath.add2(count, 1);}
        if (isNumberCalled(_stage, stages[_stage].playerCards[msg.sender][_position].I.N3)) {count = SafeMath.add2(count, 1);}
        if (isNumberCalled(_stage, stages[_stage].playerCards[msg.sender][_position].N.N3)) {count = SafeMath.add2(count, 1);}
        if (isNumberCalled(_stage, stages[_stage].playerCards[msg.sender][_position].G.N3)) {count = SafeMath.add2(count, 1);}
        if (isNumberCalled(_stage, stages[_stage].playerCards[msg.sender][_position].O.N3)) {count = SafeMath.add2(count, 1);}
        return count;
    }


    function checkH4(uint256 _stage, uint256 _position)
    internal
    view
    returns (uint8) {
        require(_stage <= SafeMath.sub(numberOfStages, 1));
        uint8 count = 0;
        if (isNumberCalled(_stage, stages[_stage].playerCards[msg.sender][_position].B.N4)) {count = SafeMath.add2(count, 1);}
        if (isNumberCalled(_stage, stages[_stage].playerCards[msg.sender][_position].I.N4)) {count = SafeMath.add2(count, 1);}
        if (isNumberCalled(_stage, stages[_stage].playerCards[msg.sender][_position].N.N4)) {count = SafeMath.add2(count, 1);}
        if (isNumberCalled(_stage, stages[_stage].playerCards[msg.sender][_position].G.N4)) {count = SafeMath.add2(count, 1);}
        if (isNumberCalled(_stage, stages[_stage].playerCards[msg.sender][_position].O.N4)) {count = SafeMath.add2(count, 1);}
        return count;
    }

    function checkH5(uint256 _stage, uint256 _position)
    internal
    view
    returns (uint8) {
        require(_stage <= SafeMath.sub(numberOfStages, 1));
        uint8 count = 0;
        if (isNumberCalled(_stage, stages[_stage].playerCards[msg.sender][_position].B.N5)) {count = SafeMath.add2(count, 1);}
        if (isNumberCalled(_stage, stages[_stage].playerCards[msg.sender][_position].I.N5)) {count = SafeMath.add2(count, 1);}
        if (isNumberCalled(_stage, stages[_stage].playerCards[msg.sender][_position].N.N5)) {count = SafeMath.add2(count, 1);}
        if (isNumberCalled(_stage, stages[_stage].playerCards[msg.sender][_position].G.N5)) {count = SafeMath.add2(count, 1);}
        if (isNumberCalled(_stage, stages[_stage].playerCards[msg.sender][_position].O.N5)) {count = SafeMath.add2(count, 1);}
        return count;
    }

    function isWithinBounds(uint8 num, uint8 min, uint8 max) internal pure returns (bool) {
        if (num >= min && num <= max) {return true;}
        return false;
    }

    function getPlayerCardsThisStage(uint256 _stage)
    public
    view
    returns (uint)
    {
        return (stages[_stage].playerCards[msg.sender].length);
    }

    function nextPaybacks(uint256 offset)
    public
    view
    returns (address)
    {
        require(offset.add(nextPayback) < paybackQueue.length);
        return (paybackQueue[nextPayback.add(offset)]);
    }

    function getCardRowB(uint256 _stage, uint256 _position)
    public
    view
    returns (uint, uint, uint, uint, uint)
    {
        require(_stage <= SafeMath.sub(numberOfStages, 1));
        address _player = msg.sender;
        return (stages[_stage].playerCards[_player][_position].B.N1,
        stages[_stage].playerCards[_player][_position].B.N2,
        stages[_stage].playerCards[_player][_position].B.N3,
        stages[_stage].playerCards[_player][_position].B.N4,
        stages[_stage].playerCards[_player][_position].B.N5);
    }

    function getCardRowI(uint256 _stage, uint256 _position)
    public
    view
    returns (uint, uint, uint, uint, uint)
    {
        require(_stage <= SafeMath.sub(numberOfStages, 1));
        address _player = msg.sender;
        return (stages[_stage].playerCards[_player][_position].I.N1,
        stages[_stage].playerCards[_player][_position].I.N2,
        stages[_stage].playerCards[_player][_position].I.N3,
        stages[_stage].playerCards[_player][_position].I.N4,
        stages[_stage].playerCards[_player][_position].I.N5);
    }

    function getCardRowN(uint256 _stage, uint256 _position)
    public
    view
    returns (uint, uint, uint, uint, uint)
    {
        require(_stage <= SafeMath.sub(numberOfStages, 1));
        address _player = msg.sender;
        return (stages[_stage].playerCards[_player][_position].N.N1,
        stages[_stage].playerCards[_player][_position].N.N2,
        stages[_stage].playerCards[_player][_position].N.N3,
        stages[_stage].playerCards[_player][_position].N.N4,
        stages[_stage].playerCards[_player][_position].N.N5);
    }

    function getCardRowG(uint256 _stage, uint256 _position)
    public
    view
    returns (uint, uint, uint, uint, uint)
    {
        require(_stage <= SafeMath.sub(numberOfStages, 1));
        address _player = msg.sender;
        return (stages[_stage].playerCards[_player][_position].G.N1,
        stages[_stage].playerCards[_player][_position].G.N2,
        stages[_stage].playerCards[_player][_position].G.N3,
        stages[_stage].playerCards[_player][_position].G.N4,
        stages[_stage].playerCards[_player][_position].G.N5);
    }

    function getCardRowO(uint256 _stage, uint256 _position)
    public
    view
    returns (uint, uint, uint, uint, uint)
    {
        require(_stage <= SafeMath.sub(numberOfStages, 1));
        address _player = msg.sender;
        return (stages[_stage].playerCards[_player][_position].O.N1,
        stages[_stage].playerCards[_player][_position].O.N2,
        stages[_stage].playerCards[_player][_position].O.N3,
        stages[_stage].playerCards[_player][_position].O.N4,
        stages[_stage].playerCards[_player][_position].O.N5);
    }
}

interface MegaballInterface {
    function seedJackpot() external payable;
    function getMoneyballBalance() external view returns (uint);
    function withdraw() external;
    function getRafflePlayerCount(uint256 _stage) external view returns (uint);
    function setDrawBlocks(uint256 _stage) external;
    function isFinalizeValid(uint256 _stage) external view returns (bool);
    function finalizeStage(uint256 _stage) external;
    function numberOfStages() external view returns (uint);
    function stageMoveDetail(uint256 _stage) external view returns (uint, uint);
    function getPlayerRaffleTickets() external view returns (uint);
    function getStageStatus(uint256 _stage) external view returns (bool, bool, bool, bool);
    function addPlayerToRaffle(address _player) external;
    function DENOMINATION() external view returns(uint);
}

interface DiviesInterface {
    function deposit() external payable;
}