pragma solidity ^0.4.25;

library Percent {
  // Solidity automatically throws when dividing by 0
  struct percent {
    uint num;
    uint den;
  }
  
  // storage
  function mul(percent storage p, uint a) internal view returns (uint) {
    if (a == 0) {
      return 0;
    }
    return a*p.num/p.den;
  }

    function toMemory(percent storage p) internal view returns (Percent.percent memory) {
    return Percent.percent(p.num, p.den);
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
  function mul(uint256 _a, uint256 _b) internal pure returns (uint256) {
    // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
    // benefit is lost if 'b' is also tested.
    // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
    if (_a == 0) {
      return 0;
    }

    uint256 c = _a * _b;
    require(c / _a == _b);

    return c;
  }

  /**
  * @dev Adds two numbers, reverts on overflow.
  */
  function add(uint256 _a, uint256 _b) internal pure returns (uint256) {
    uint256 c = _a + _b;
    require(c >= _a);

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

}

contract Ownable {
  address public owner;

  event OwnershipTransferred(
    address indexed previousOwner,
    address indexed newOwner
  );

  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  constructor() internal {
    owner = msg.sender;
    emit OwnershipTransferred(address(0), owner);
  }

  /**
   * @return the address of the owner.
   */
  function owner() public view returns(address) {
    return owner;
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
  function isOwner() public view returns(bool) {
    return msg.sender == owner;
  }

  /**
   * @dev Allows the current owner to relinquish control of the contract.
   * @notice Renouncing to ownership will leave the contract without an owner.
   * It will not be possible to call the functions with the `onlyOwner`
   * modifier anymore.
   */
  function renounceOwnership() public onlyOwner {
    emit OwnershipTransferred(owner, address(0));
    owner = address(0);
  }
}

contract FastLap is Ownable {
    using Percent for Percent.percent;
    using SafeMath for uint;
    
    //Address for advertising and admins expences
    address constant public advertisingAddress = address(0xf86117De6539c6f48764b638412C99F3ADB19892); //рекламный
    address constant public adminsAddress = address(0x33a6c786Cf6D69CC62c475B5d69947af08bB6210); //тех поддержка и автоматизация выплат
    
    //Percent for promo expences
    Percent.percent private m_adminsPercent = Percent.percent(3, 100);       //   3/100  *100% = 3%
    Percent.percent private m_advertisingPercent = Percent.percent(5, 100);// 5/100  *100% = 5%
    //How many percent for your deposit to be multiplied
    Percent.percent public MULTIPLIER = Percent.percent(120, 100); // 120/100 * 100% = 120%
    
    uint public amountRaised = 0;
    //The deposit structure holds all the info about the deposit made
    struct Deposit {
        address depositor; //The depositor address
        uint deposit;   //The deposit amount
        uint expects;    //How much we should pay out (initially it is 120% of deposit)
        uint paymentTime; //when payment
    }

    Deposit[] private Queue;  //The queue for new investments
    // list of deposites for 1 user
    mapping(address => uint[]) private depositors;
    
    uint public depositorsCount = 0;
    
    uint private currentReceiverIndex = 0; //The index of the first depositor in the queue. The receiver of investments!
    
    uint public minBalanceForDistribution = 3 ether; //минимально необходимый баланс

    //создаем депозит инвестора в основной очереди
    function () public payable {
        if(msg.value > 0){ //регистрация депозита
            require(msg.value >= 0.1 ether, "investment must be between 0.1 and 0.5 ether"); //ограничение минимального депозита
            require(msg.value <= 0.5 ether, "investment must be between 0.1 and 0.5 ether"); //ограничение максимального депозита

            //к выплате 120% от депозита
            uint expect = MULTIPLIER.mul(msg.value);
            Queue.push(Deposit({depositor:msg.sender, deposit:msg.value, expects:expect, paymentTime:0}));
            amountRaised += msg.value;
            if (depositors[msg.sender].length == 0) depositorsCount += 1;
            depositors[msg.sender].push(Queue.length - 1);
            
            advertisingAddress.send(m_advertisingPercent.mul(msg.value));
            adminsAddress.send(m_adminsPercent.mul(msg.value));
        } else { //выплаты инвесторам
            uint money = address(this).balance;
            require(money >= minBalanceForDistribution, "Not enough funds to pay");//на балансе недостаточно денег для выплат
            uint QueueLen = Queue.length;
            uint toSend = Queue[currentReceiverIndex].expects;
            uint maxIterations = 25;//максимум 25 итераций
            uint num = 0;
            uint i = 0;
            
            while ((currentReceiverIndex < QueueLen) && (i < maxIterations) && (money >= toSend)) {
                money = money.sub(toSend);
                Queue[currentReceiverIndex].paymentTime = now;
                num = currentReceiverIndex;
                currentReceiverIndex += 1;
                i +=1;
                Queue[num].depositor.send(toSend);
                toSend = Queue[currentReceiverIndex].expects;
            }
        }
    }

    //баланс контракта
    function getNeedBalance() public view returns (uint) {
        uint money = address(this).balance;
        if (money >= minBalanceForDistribution){
          return 0;  
        } else {
            return minBalanceForDistribution - money;
        }
    }
    
    //данные о депозите по порядковому номеру 
    function getDeposit(uint idx) public view returns (address depositor, uint deposit, uint expect, uint paymentTime){
        Deposit storage dep = Queue[idx];
        return (dep.depositor, dep.deposit, dep.expects, dep.paymentTime);
    }

    //общее количество депозитов у кошелька depositor
    function getUserDepositsCount(address depositor) public view returns (uint) {
        return depositors[depositor].length;
    }

    //Все депозиты основной очереди кошелька depositor в виде массива
    function getUserInfo(address depositor) public view returns (uint depCount, uint allDeps, uint payDepCount, uint allPay, uint lastPaymentTime) {
        depCount = depositors[depositor].length;
        allPay = 0;
        allDeps = 0;
        lastPaymentTime = 0;
        payDepCount = 0;
        uint num = 0;
        
        for(uint i=0; i<depCount; ++i){
            num = depositors[depositor][i];
            allDeps += Queue[num].deposit;
            if (Queue[num].paymentTime > 0){
                allPay += Queue[num].expects;
                payDepCount += 1;
                lastPaymentTime = Queue[num].paymentTime;
            }
        }
        return (depCount, allDeps, payDepCount, allPay, lastPaymentTime);
    }
}