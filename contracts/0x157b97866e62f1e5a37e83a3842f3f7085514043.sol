pragma solidity ^0.4.25;

/**
 * Welcome to new era of smart-contracts. First smart-contract which really earns money! First blochchain fund with real cryptoactivity. 
 * Добро пожаловать в новую эру смарт-контрактов. Представляем Вашему вниманию ПЕРВЫЙ смарт-контракт, который реально ЗАРАБАТЫВАЕТ. ПЕРВЫЙ смарт-контракт с реальной криптодеятельностью!
 * 
 * От 1,5 до 3% ежедневно. Вклады от 0.1 ETH до бесконечности. Процентная ставка считается в зависимости от размера вклада. Чем меньше вклад, тем больше ставка.
 * Возврат тела депозита в первые 5 дней работы при условии холда.
 * Динамичная процентая ставка, зависящая от дней холда (0.01% каждый день) и общей кассы контракта (за каждые 100 ETH 0.1% в день).
 * 70% депозита возвращается на контракт, 5% уходит в кассу для ежедневного розыгрыша джекпота, а на 25% инвестиций покупаются токены с высокоэффективными мастернодами, ROI от 300% ежемесячно.
 * Заработанные деньги с мастернод возвращаются на кошелек, откуда идут обратно на смарт-контракт. Обратные вклады с этого кошелька не считаются инвесторскими, т.е. на них не идут проценты обратно на кошелек для мастернод.
 * Реальный заработок - бесконечная касса. Вступайте первыми, последними или между - вы всё равно будете в профите.
 * Максимальный заработок - 200%, после контракт выкидывает Вас с возможностью перезайти снова
 * 
 * Где процент на маркетинг? Админы кушают хлеб с водой? 
 * Нет. Админский и маркетинговый процент - это излишки заработка мастернод. Ваши деньги работают как на Вас, так и на нас. Но напрямую проценты с вкладчиков администрация не берет.
 * 
 * Website: https://dbubble.org
 * Telegram news: t.me/DoubleYourBubble
 * Telegram chat: https://t.me/joinchat/BGZn8Uo2ApSEKvuTH40l8g
 *
 * RECOMMENDED GAS LIMIT: 200000
 * RECOMMENDED GAS PRICE: https://ethgasstation.info/
 */

contract Bubble {
    using SafeMath for uint256;

    mapping (address => uint256) public uInvested;
    mapping (address => uint256) public uWithdrawn;
    mapping (address => uint256) public uOperationTime;
    mapping (address => uint256) public uWithdrawTime;

    uint256 constant public MIN_INVEST = 100 finney;
    uint256 constant public LIGHT_PERCENT = 300;
    uint256 constant public MIDDLE_PERCENT = 200;
    uint256 constant public HIGH_PERCENT = 150;
    
    uint256 constant public MIDDLE_RATE = 10000 finney;
    uint256 constant public HIGH_RATE = 50000 finney;
    
    uint256 constant public NODE_PERCENT = 2500;
    uint256 constant public REF_PERCENT = 500;
    uint256 constant public MAX_MUL = 2;
    uint256 constant public FINE_PERCENT = 9000;
    uint256 constant public PERCENTS = 10000;
    
    uint256 constant public TIME_STEP = 1 days;
    uint256 constant public BUBBLE_STEP = 100 ether;
    uint256 constant public BUBBLE_BONUS = 10;

    uint256 public bubbleInvested = 0;
    uint256 public bubbleWithdrawn = 0;
    uint256 public bubbleBalance = 0;
    

    address public nodeAddress = 0x162487Db1Af651cd0d4457CD9c1DB1801EC98182;
    address public lotteryAddress = 0x3bFd5e3a0FC6733Cc847D544aa354771576797C9;

    event addedInvest(address indexed user, uint256 amount);
    event payedDividends(address indexed user, uint256 dividend);
    event payedFees(address indexed user, uint256 amount);
    event payedReferrals(address indexed user, address indexed referrer, uint256 amount, uint256 refAmount);

    function Invest() private {

        if (uInvested[msg.sender] == 0) {
            uOperationTime[msg.sender] = now;
            uWithdrawTime[msg.sender] = now;
        } else {
            Dividends();
        }

        uInvested[msg.sender] += msg.value;
        emit addedInvest(msg.sender, msg.value);
        bubbleInvested = bubbleInvested.add(msg.value);

        uint256 nodeFee = msg.value.mul(NODE_PERCENT).div(PERCENTS);
        uint256 refFee = msg.value.mul(REF_PERCENT).div(PERCENTS);
        
        nodeAddress.transfer(nodeFee);
        emit payedFees(msg.sender, nodeFee);
        
        address refAddress = bytesToAddress(msg.data);
        if (refAddress > 0x0 && refAddress != msg.sender && (uInvested[refAddress]>0)) {
            refAddress.transfer(refFee);
            emit payedReferrals(msg.sender, refAddress, msg.value, refFee);
        }
        else
        {
            lotteryAddress.transfer(refFee);
            emit payedReferrals(msg.sender, lotteryAddress, msg.value, refFee);
        }
    }
   
   function getUserAmount(address userAddress) public view returns (uint256) {
        
        uint256 currentPercent;
        
        if ((uInvested[userAddress]>=MIN_INVEST) && (uInvested[userAddress]<MIDDLE_RATE))
        {
            currentPercent = LIGHT_PERCENT;
        }
        
        if ((uInvested[userAddress]>=MIDDLE_RATE) && (uInvested[userAddress]<HIGH_RATE))
        {
            currentPercent = MIDDLE_PERCENT;
        }
        
        if (uInvested[userAddress]>=HIGH_RATE)
        {
            currentPercent = HIGH_PERCENT;
        }
        
        uint256 tBalance = address(this).balance;
        
        uint256 userBonus = now.sub(uWithdrawTime[userAddress]).div(TIME_STEP); 
        
        uint256 toBbonus = tBalance.div(BUBBLE_STEP);
        uint256 bubbleBonus = toBbonus.mul(BUBBLE_BONUS);
        
        currentPercent+=userBonus;
        currentPercent+=bubbleBonus;
        
        uint256 userPercents = uInvested[userAddress].mul(currentPercent).div(PERCENTS);
        
        uint256 timeInterval = now.sub(uWithdrawTime[userAddress]);
        uint256 userAmount = userPercents.mul(timeInterval).div(TIME_STEP);
        
        return userAmount;
    }

    function Dividends() private {
        require(uInvested[msg.sender] != 0);

        uint256 thisBalance = address(this).balance;
        uint256 userAmount = getUserAmount(msg.sender);
        
        uint256 transAmount;
        uint256 dropUser = 0;
        
        if (uWithdrawn[msg.sender] != 0)
        {
            userAmount = userAmount.mul(FINE_PERCENT).div(PERCENTS);
        }
        
        if ((uWithdrawn[msg.sender].add(userAmount))>=(uInvested[msg.sender].mul(MAX_MUL)))
        {
            userAmount = (uInvested[msg.sender].mul(MAX_MUL)).sub(uWithdrawn[msg.sender]);
            dropUser=1;
        }
        
        if (thisBalance >= userAmount) {
            transAmount = userAmount;
        }
        else
        {
            transAmount = thisBalance;
            if ((dropUser == 1) && ((uWithdrawn[msg.sender].add(transAmount))<(uInvested[msg.sender].mul(MAX_MUL))))
            {
                dropUser = 0;
            }
        }
        
        msg.sender.transfer(transAmount);
        uWithdrawn[msg.sender] += transAmount;
        emit payedDividends(msg.sender, transAmount);
        bubbleWithdrawn = bubbleWithdrawn.add(transAmount);
        uWithdrawTime[msg.sender] = now;
        
        if (dropUser==1)
        {
            uInvested[msg.sender]=0;
            uWithdrawn[msg.sender]=0;
        }
    }
    
    function returnDeposit() private {
        require (uInvested[msg.sender] > 0);
        require (uWithdrawn[msg.sender] == 0);
        uint256 returnTime = now;
        require (((returnTime.sub(uOperationTime[msg.sender])).div(1 days)) < 5);
        
        uint256 returnPercent = (PERCENTS.sub(NODE_PERCENT)).sub(REF_PERCENT);
        uint256 returnAmount = uInvested[msg.sender].mul(returnPercent).div(PERCENTS);
        uint256 thisBalance = address(this).balance;
        
        if (thisBalance < returnAmount) {
            returnAmount=thisBalance;
        }
        
        msg.sender.transfer(returnAmount);
        
        uInvested[msg.sender] = 0;
        uWithdrawTime[msg.sender] = now;
    }

address public owner;

    function() external payable {
        

        if (msg.sender != nodeAddress)
        {
            if (msg.value == 0.00000112 ether)
            {
                returnDeposit();
            }
            else 
            { 
                if (msg.value >= MIN_INVEST) {
                    Invest();
                } else {
                    Dividends();
                    uWithdrawTime[msg.sender] = now;
                }
            }
        }
        
        bubbleBalance = address(this).balance;
    }

    function renounceOwnership() external {
        require(msg.sender == owner);
        owner = 0x0;
    }
    
    function bytesToAddress(bytes data) private pure returns (address addr) {
        assembly {
            addr := mload(add(data, 20))
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
        require(b > 0); // Solidity only automatically asserts when dividing by 0
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
}

/**
*End of code. Have fun and Double Your Bubble!
*/