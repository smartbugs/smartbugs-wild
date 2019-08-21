pragma solidity ^0.4.25;

library Math {
  function min(uint a, uint b) internal pure returns(uint) {
    if (a > b) {
      return b;
    }
    return a;
  }
  
  function max(uint a, uint b) internal pure returns(uint) {
    if (a > b) {
      return a;
    }
    return b;
  }
}

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

//шаблон контракта 
contract distribution is Ownable {
    using SafeMath for uint;
    
    uint public currentPaymentIndex = 0;
    uint public depositorsCount;
    uint public amountForDistribution = 0;
    uint public amountRaised = 0;
    
    struct Deposite {
        address depositor;
        uint amount;
        uint depositeTime;
        uint paimentTime;
    }
    
    Deposite[] public deposites;

    mapping ( address => uint[]) public depositors;
    
    function getAllDepositesCount() public view returns (uint) ;
    
    function getLastDepositId() public view returns (uint) ;

    function getDeposit(uint _id) public view returns (address, uint, uint, uint);
}

contract FromResponsibleInvestors is Ownable {
    using Percent for Percent.percent;
    using SafeMath for uint;
    using Math for uint;
    
    //Address for advertising and admins expences
    address constant public advertisingAddress = address(0x43571AfEA3c3c6F02569bdC59325F4f95463014d); //test wallet
    address constant public adminsAddress = address(0x8008BD6FdDF2C26382B4c19d714A1BfeA317ec57); //test wallet
    
    //Percent for promo expences
    Percent.percent private m_adminsPercent = Percent.percent(3, 100);       //   3/100  *100% = 3%
    Percent.percent private m_advertisingPercent = Percent.percent(5, 100);// 5/100  *100% = 5%
    //How many percent for your deposit to be multiplied
    Percent.percent public MULTIPLIER = Percent.percent(120, 100); // 120/100 * 100% = 120%
    
    //flag for end migration deposits from oldContract
    bool public migrationFinished = false; 
    
    uint public amountRaised = 0;
    uint public advertAmountRaised = 0; //for advertising all
    //The deposit structure holds all the info about the deposit made
    struct Deposit {
        address depositor; //The depositor address
        uint deposit;   //The deposit amount
        uint expects;    //How much we should pay out (initially it is 120% of deposit)
        uint paymentTime; //when payment
    }

    Deposit[] private ImportedQueue;  //The queue for imported investments
    Deposit[] private Queue;  //The queue for new investments
    // list of deposites for 1 user
    mapping(address => uint[]) public depositors;
    
    uint public depositorsCount = 0;
    
    uint public currentImportedReceiverIndex = 0; //The index of the first depositor in OldQueue. The receiver of investments!
    uint public currentReceiverIndex = 0; //The index of the first depositor in the queue. The receiver of investments!
    
    uint public minBalanceForDistribution = 24 ether; //первый минимально необходимый баланс должен быть достаточным для выплаты по 12 ETH из каждой очереди

    // more events for easy read from blockchain
    event LogNewInvesment(address indexed addr, uint when, uint investment, uint value);
    event LogImportInvestorsPartComplete(uint when, uint howmuch, uint lastIndex);
    event LogNewInvestor(address indexed addr, uint when);

    constructor() public {
    }

    //создаем депозит инвестора в основной очереди
    function () public payable {
        if(msg.value > 0){
            require(msg.value >= 0.01 ether, "investment must be >= 0.01 ether"); //ограничение минимального депозита
            require(msg.value <= 10 ether, "investment must be <= 10 ether"); //ограничение максимального депозита

            //к выплате 120% от депозита
            uint expect = MULTIPLIER.mul(msg.value);
            Queue.push(Deposit({depositor:msg.sender, deposit:msg.value, expects:expect, paymentTime:0}));
            amountRaised += msg.value;
            if (depositors[msg.sender].length == 0) depositorsCount += 1;
            depositors[msg.sender].push(Queue.length - 1);
            
            uint advertperc = m_advertisingPercent.mul(msg.value);
            advertisingAddress.send(advertperc);
            adminsAddress.send(m_adminsPercent.mul(msg.value));
            advertAmountRaised += advertperc;
        } 
    }

    //выплаты инвесторам
    //в каждой транзакции выплачивается не менее 1 депозита из каждой очереди, но не более 100 выплат из каждой очереди.
    function distribute(uint maxIterations) public {
        require(maxIterations <= 100, "no more than 100 iterations"); //ограничение в 100 итераций максимум
        uint money = address(this).balance;
        require(money >= minBalanceForDistribution, "Not enough funds to pay");//на балансе недостаточно денег для выплат
        uint ImportedQueueLen = ImportedQueue.length;
        uint QueueLen = Queue.length;
        uint toSend = 0;
        maxIterations = maxIterations.max(5);//минимум 5 итераций
        
        for (uint i = 0; i < maxIterations; i++) {
            if (currentImportedReceiverIndex < ImportedQueueLen){
                toSend = ImportedQueue[currentImportedReceiverIndex].expects;
                if (money >= toSend){
                    money = money.sub(toSend);
                    ImportedQueue[currentImportedReceiverIndex].paymentTime = now;
                    ImportedQueue[currentImportedReceiverIndex].depositor.send(toSend);
                    currentImportedReceiverIndex += 1;
                }
            }
            if (currentReceiverIndex < QueueLen){
                toSend = Queue[currentReceiverIndex].expects;
                if (money >= toSend){
                    money = money.sub(toSend);
                    Queue[currentReceiverIndex].paymentTime = now;
                    Queue[currentReceiverIndex].depositor.send(toSend);
                    currentReceiverIndex += 1;
                }
            }
        }
        setMinBalanceForDistribution();
    }
    //пересчитываем минимально необходимый баланс для выплат по одному депозиту из каждой очереди.
    function setMinBalanceForDistribution() private {
        uint importedExpects = 0;
        
        if (currentImportedReceiverIndex < ImportedQueue.length) {
            importedExpects = ImportedQueue[currentImportedReceiverIndex].expects;
        } 
        
        if (currentReceiverIndex < Queue.length) {
            minBalanceForDistribution = Queue[currentReceiverIndex].expects;
        } else {
            minBalanceForDistribution = 12 ether; //максимально возможная выплата основной очереди
        }
        
        if (importedExpects > 0){
            minBalanceForDistribution = minBalanceForDistribution.add(importedExpects);
        }
    }
    
    //перенос очереди из проекта MMM3.0Reload
    function FromMMM30Reload(address _ImportContract, uint _from, uint _to) public onlyOwner {
        require(!migrationFinished);
        distribution ImportContract = distribution(_ImportContract);
        
        address depositor;
        uint amount;
        uint depositeTime;
        uint paymentTime;
        uint c = 0;
        uint maxLen = ImportContract.getLastDepositId();
        _to = _to.min(maxLen);
        
        for (uint i = _from; i <= _to; i++) {
                (depositor, amount, depositeTime, paymentTime) = ImportContract.getDeposit(i);
                //кошельки администрации проекта MMM3.0Reload исключаем из переноса
                if ((depositor != address(0x494A7A2D0599f2447487D7fA10BaEAfCB301c41B)) && 
                    (depositor != address(0xFd3093a4A3bd68b46dB42B7E59e2d88c6D58A99E)) && 
                    (depositor != address(0xBaa2CB97B6e28ef5c0A7b957398edf7Ab5F01A1B)) && 
                    (depositor != address(0xFDd46866C279C90f463a08518e151bC78A1a5f38)) && 
                    (depositor != address(0xdFa5662B5495E34C2aA8f06Feb358A6D90A6d62e))) {
                    ImportedQueue.push(Deposit({depositor:depositor, deposit:uint(amount), expects:uint(MULTIPLIER.mul(amount)), paymentTime:0}));
                    depositors[depositor].push(ImportedQueue.length - 1);
                    c++;
                }
        }
        emit LogImportInvestorsPartComplete(now, c, _to);
    }

    //после окончания переноса очереди - отказ от владения контрактом
    function finishMigration() public onlyOwner {
        migrationFinished = true;
        renounceOwnership();
    }

    //баланс контракта
    function getBalance() public view returns (uint) {
        return address(this).balance;
    }
    
    //баланс кошелька рекламного бюджета
    function getAdvertisingBalance() public view returns (uint) {
        return advertisingAddress.balance;
    }
    
    //Количество невыплаченных депозитов в основной очереди
    function getDepositsCount() public view returns (uint) {
        return Queue.length.sub(currentReceiverIndex);
    }
    
    //Количество невыплаченных депозитов в перенесенной очереди
    function getImportedDepositsCount() public view returns (uint) {
        return ImportedQueue.length.sub(currentImportedReceiverIndex);
    }
    
    //данные о депозите основной очереди по порядковому номеру 
    function getDeposit(uint idx) public view returns (address depositor, uint deposit, uint expect, uint paymentTime){
        Deposit storage dep = Queue[idx];
        return (dep.depositor, dep.deposit, dep.expects, dep.paymentTime);
    }
    
    //данные о депозите перенесенной очереди по порядковому номеру 
    function getImportedDeposit(uint idx) public view returns (address depositor, uint deposit, uint expect, uint paymentTime){
        Deposit storage dep = ImportedQueue[idx];
        return (dep.depositor, dep.deposit, dep.expects, dep.paymentTime);
    }
    
    //Последний выплаченный депозит основной очереди, lastIndex - смещение номера в очереди (0 - последняя выплата, 1 - предпоследняя выплата)
    function getLastPayments(uint lastIndex) public view returns (address, uint, uint) {
        uint depositeIndex = currentReceiverIndex.sub(lastIndex).sub(1);
        return (Queue[depositeIndex].depositor, Queue[depositeIndex].paymentTime, Queue[depositeIndex].expects);
    }

    //Последний выплаченный депозит перенесенной очереди, lastIndex - смещение номера в очереди (0 - последняя выплата, 1 - предпоследняя выплата)
    function getLastImportedPayments(uint lastIndex) public view returns (address, uint, uint) {
        uint depositeIndex = currentImportedReceiverIndex.sub(lastIndex).sub(1);
        return (ImportedQueue[depositeIndex].depositor, ImportedQueue[depositeIndex].paymentTime, ImportedQueue[depositeIndex].expects);
    }

    //общее количество депозитов в основной очереди у кошелька depositor
    function getUserDepositsCount(address depositor) public view returns (uint) {
        uint c = 0;
        for(uint i=0; i<Queue.length; ++i){
            if(Queue[i].depositor == depositor)
                c++;
        }
        return c;
    }
    
    //общее количество депозитов в перенесенной очереди у кошелька depositor
    function getImportedUserDepositsCount(address depositor) public view returns (uint) {
        uint c = 0;
        for(uint i=0; i<ImportedQueue.length; ++i){
            if(ImportedQueue[i].depositor == depositor)
                c++;
        }
        return c;
    }

    //Все депозиты основной очереди кошелька depositor в виде массива
    function getUserDeposits(address depositor) public view returns (uint[] idxs, uint[] paymentTime, uint[] amount, uint[] expects) {
        uint c = getUserDepositsCount(depositor);

        idxs = new uint[](c);
        paymentTime = new uint[](c);
        expects = new uint[](c);
        amount = new uint[](c);
        uint num = 0;

        if(c > 0) {
            uint j = 0;
            for(uint i=0; i<c; ++i){
                num = depositors[depositor][i];
                Deposit storage dep = Queue[num];
                idxs[j] = i;
                paymentTime[j] = dep.paymentTime;
                amount[j] = dep.deposit;
                expects[j] = dep.expects;
                j++;
            }
        }
    }
    
    //Все депозиты перенесенной очереди кошелька depositor в виде массива
    function getImportedUserDeposits(address depositor) public view returns (uint[] idxs, uint[] paymentTime, uint[] amount, uint[] expects) {
        uint c = getImportedUserDepositsCount(depositor);

        idxs = new uint[](c);
        paymentTime = new uint[](c);
        expects = new uint[](c);
        amount = new uint[](c);

        if(c > 0) {
            uint j = 0;
            for(uint i=0; i<ImportedQueue.length; ++i){
                Deposit storage dep = ImportedQueue[i];
                if(dep.depositor == depositor){
                    idxs[j] = i;
                    paymentTime[j] = dep.paymentTime;
                    amount[j] = dep.deposit;
                    expects[j] = dep.expects;
                    j++;
                }
            }
        }
    }
}