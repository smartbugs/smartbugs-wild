pragma solidity ^0.4.11;




/**
 * @title Math
 * @dev Assorted math operations y
 */
library Math {
  function max64(uint64 a, uint64 b) internal pure returns (uint64) {
    return a >= b ? a : b;
  }

  function min64(uint64 a, uint64 b) internal pure returns (uint64) {
    return a < b ? a : b;
  }

  function max256(uint256 a, uint256 b) internal pure returns (uint256) {
    return a >= b ? a : b;
  }

  function min256(uint256 a, uint256 b) internal pure returns (uint256) {
    return a < b ? a : b;
  }
}




/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}




/**
 * @title ERC20Basic
 * @dev Simpler version of ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/179
 */
contract ERC20Basic {
  uint256 public totalSupply;

  function balanceOf(address who) constant public returns (uint256);

  function transfer(address to, uint256 value) public returns (bool);

  event Transfer(address indexed from, address indexed to, uint256 value);
}





/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender) constant public returns (uint256);

  function transferFrom(address from, address to, uint256 value) public returns (bool);

  function approve(address spender, uint256 value) public returns (bool);

  event Approval(address indexed owner, address indexed spender, uint256 value);
}





contract ERC223 {
  uint public totalSupply;
  function balanceOf(address who) constant public returns (uint);

  function name() constant public returns (string _name);
  function symbol() constant public returns (string _symbol);
  function decimals() constant public returns (uint8 _decimals);
  function totalSupply() constant public returns (uint256 _supply);

  function transfer(address to, uint value) public returns (bool ok);
  function transfer(address to, uint value, bytes data) public returns (bool ok);
  event Transfer(address indexed from, address indexed to, uint value, bytes indexed data);
}





/*
* Contract that is working with ERC223 tokens
*/

contract ContractReceiver {

  string public functionName;
  address public sender;
  uint public value;
  bytes public data;

  function tokenFallback(address _from, uint _value, bytes _data) public {

    sender = _from;
    value = _value;
    data = _data;
    functionName = "tokenFallback";
    //uint32 u = uint32(_data[3]) + (uint32(_data[2]) << 8) + (uint32(_data[1]) << 16) + (uint32(_data[0]) << 24);
    //tkn.sig = bytes4(u);

    /* tkn variable is analogue of msg variable of Ether transaction
    *  tkn.sender is person who initiated this token transaction   (analogue of msg.sender)
    *  tkn.value the number of tokens that were sent   (analogue of msg.value)
    *  tkn.data is data of token transaction   (analogue of msg.data)
    *  tkn.sig is 4 bytes signature of function
    *  if data of token transaction is a function execution
    */
  }

  function customFallback(address _from, uint _value, bytes _data) public {
    tokenFallback(_from, _value, _data);
    functionName = "customFallback";
  }
}







contract RobomedIco is ERC223, ERC20 {

    using SafeMath for uint256;

    string public name = "RobomedToken";

    string public symbol = "RBM";

    uint8 public decimals = 18;

    //addresses

    /*
     * ADDR_OWNER - владелец контракта - распределяет вип токены, начисляет баунти и team, осуществляет переход по стадиям
     */
    address public constant ADDR_OWNER = 0x21F6C4D926B705aD244Ec33271559dA8c562400F;

    /*
    * ADDR_WITHDRAWAL1, ADDR_WITHDRAWAL2 - участники контракта, которые совместно выводят eth после наступления PostIco
    */
    address public constant ADDR_WITHDRAWAL1 = 0x0dD97e6259a7de196461B36B028456a97e3268bE;

    /*
    * ADDR_WITHDRAWAL1, ADDR_WITHDRAWAL2 - участники контракта, которые совместно выводят eth после наступления PostIco
    */
    address public constant ADDR_WITHDRAWAL2 = 0x8c5B02144F7664D37FDfd4a2f90148d08A04838D;

    /**
    * Адрес на который кладуться токены для раздачи по Baunty
    */
    address public constant ADDR_BOUNTY_TOKENS_ACCOUNT = 0x6542393623Db0D7F27fDEd83e6feDBD767BfF9b4;

    /**
    * Адрес на который кладуться токены для раздачи Team
    */
    address public constant ADDR_TEAM_TOKENS_ACCOUNT = 0x28c6bCAB2204CEd29677fEE6607E872E3c40d783;



    //VipPlacement constants


    /**
     * Количество токенов для стадии VipPlacement
    */
    uint256 public constant INITIAL_COINS_FOR_VIPPLACEMENT =507937500 * 10 ** 18;

    /**
     * Длительность стадии VipPlacement
    */
    uint256 public constant DURATION_VIPPLACEMENT = 1 seconds;// 1 minutes;//  1 days;

    //end VipPlacement constants

    //PreSale constants

    /**
     * Количество токенов для стадии PreSale
    */
    uint256 public constant EMISSION_FOR_PRESALE = 76212500 * 10 ** 18;

    /**
     * Длительность стадии PreSale
    */
    uint256 public constant DURATION_PRESALE = 1 days;//2 minutes;//1 days;

    /**
     * Курс стадии PreSale
    */
    uint256 public constant RATE_PRESALE = 2702;

    //end PreSale constants

    //SaleStage1 constants

    /**
     * Общая длительность стадий Sale с SaleStage1 по SaleStage7 включительно
    */
    uint256 public constant DURATION_SALESTAGES = 10 days; //2 minutes;//30 days;

    /**
     * Курс стадии SaleStage1
    */
    uint256 public constant RATE_SALESTAGE1 = 2536;

    /**
     * Эмиссия токенов для стадии SaleStage1
    */
    uint256 public constant EMISSION_FOR_SALESTAGE1 = 40835000 * 10 ** 18;

    //end SaleStage1 constants

    //SaleStage2 constants

    /**
     * Курс стадии SaleStage2
    */
    uint256 public constant RATE_SALESTAGE2 = 2473;

    /**
    * Эмиссия токенов для стадии SaleStage2
    */
    uint256 public constant EMISSION_FOR_SALESTAGE2 = 40835000 * 10 ** 18;

    //end SaleStage2 constants

    //SaleStage3 constants

    /**
     * Курс стадии SaleStage3
    */
    uint256 public constant RATE_SALESTAGE3 = 2390;

    /**
    * Эмиссия токенов для стадии SaleStage3
    */
    uint256 public constant EMISSION_FOR_SALESTAGE3 = 40835000 * 10 ** 18;
    //end SaleStage3 constants

    //SaleStage4 constants

    /**
     * Курс стадии SaleStage4
    */
    uint256 public constant RATE_SALESTAGE4 = 2349;

    /**
    * Эмиссия токенов для стадии SaleStage4
    */
    uint256 public constant EMISSION_FOR_SALESTAGE4 = 40835000 * 10 ** 18;

    //end SaleStage4 constants


    //SaleStage5 constants

    /**
     * Курс стадии SaleStage5
    */
    uint256 public constant RATE_SALESTAGE5 = 2286;

    /**
    * Эмиссия токенов для стадии SaleStage5
    */
    uint256 public constant EMISSION_FOR_SALESTAGE5 = 40835000 * 10 ** 18;

    //end SaleStage5 constants



    //SaleStage6 constants

    /**
     * Курс стадии SaleStage6
    */
    uint256 public constant RATE_SALESTAGE6 = 2224;

    /**
    * Эмиссия токенов для стадии SaleStage6
    */
    uint256 public constant EMISSION_FOR_SALESTAGE6 = 40835000 * 10 ** 18;

    //end SaleStage6 constants


    //SaleStage7 constants

    /**
     * Курс стадии SaleStage7
    */
    uint256 public constant RATE_SALESTAGE7 = 2182;

    /**
    * Эмиссия токенов для стадии SaleStage7
    */
    uint256 public constant EMISSION_FOR_SALESTAGE7 = 40835000 * 10 ** 18;

    //end SaleStage7 constants


    //SaleStageLast constants

    /**
     * Длительность стадии SaleStageLast
    */
    uint256 public constant DURATION_SALESTAGELAST = 1 days;// 20 minutes;//10 days;

    /**
     * Курс стадии SaleStageLast
    */
    uint256 public constant RATE_SALESTAGELAST = 2078;

    /**
    * Эмиссия токенов для стадии SaleStageLast
    */
    uint256 public constant EMISSION_FOR_SALESTAGELAST = 302505000 * 10 ** 18;
    //end SaleStageLast constants

    //PostIco constants

    /**
     * Длительность периода на который нельзя использовать team токены, полученные при распределении
    */
    uint256 public constant DURATION_NONUSETEAM = 180 days;//10 days;

    /**
     * Длительность периода на который нельзя восстановить нераспроданные unsoldTokens токены,
     * отсчитывается после наступления PostIco
    */
    uint256 public constant DURATION_BEFORE_RESTORE_UNSOLD = 270 days;

    //end PostIco constants

    /**
    * Эмиссия токенов для BOUNTY
    */
    uint256 public constant EMISSION_FOR_BOUNTY = 83750000 * 10 ** 18;

    /**
    * Эмиссия токенов для TEAM
    */
    uint256 public constant EMISSION_FOR_TEAM = 418750000 * 10 ** 18;

    /**
    * Кол-во токенов, которое будет начислено каждому участнику команды
    */
    uint256 public constant TEAM_MEMBER_VAL = 2000000 * 10 ** 18;

    /**
      * Перечисление состояний контракта
      */
    enum IcoStates {

    /**
     * Состояние для которого выполняется заданная эмиссия на кошелёк владельца,
     * далее все выпущенные токены распределяются владельцем из своего кошелька на произвольные кошельки, распределение может происходить всегда.
     * Владелец не может распределить из своего кошелька, количество превышающее INITIAL_COINS_FOR_VIPPLACEMENT до прекращения ICO
     * Состояние завершается по наступлению времени endDateOfVipPlacement
     */
    VipPlacement,

    /**
       * Состояние для которого выполняется заданная эмиссия в свободный пул freeMoney.
       * далее все выпущенные свободные токены покупаются всеми желающими вплоть до endDateOfPreSale,
       * не выкупленные токены будут уничтожены
       * Состояние завершается по наступлению времени endDateOfPreSale.
       * С момента наступления PreSale покупка токенов становиться разрешена
       */
    PreSale,

    /**
     * Состояние представляющее из себя подстадию продаж,
     * при наступлении данного состояния выпускается заданное количество токенов,
     * количество свободных токенов приравнивается к этой эмиссии
     * Состояние завершается при выкупе всех свободных токенов или по наступлению времени startDateOfSaleStageLast.
     * Если выкупаются все свободные токены - переход осуществляется на следующую стадию -
     * например [с SaleStage1 на SaleStage2] или [с SaleStage2 на SaleStage3]
     * Если наступает время startDateOfSaleStageLast, то независимо от выкупленных токенов переходим на стостояние SaleStageLast
    */
    SaleStage1,

    /**
     * Аналогично SaleStage1
     */
    SaleStage2,

    /**
     * Аналогично SaleStage1
     */
    SaleStage3,

    /**
     * Аналогично SaleStage1
     */
    SaleStage4,

    /**
     * Аналогично SaleStage1
     */
    SaleStage5,

    /**
     * Аналогично SaleStage1
     */
    SaleStage6,

    /**
     * Аналогично SaleStage1
     */
    SaleStage7,

    /**
     * Состояние представляющее из себя последнюю подстадию продаж,
     * при наступлении данного состояния выпускается заданное количество токенов,
     * количество свободных токенов приравнивается к этой эмиссии,
     * плюс остатки нераспроданных токенов со стадий SaleStage1,SaleStage2,SaleStage3,SaleStage4,SaleStage5,SaleStage6,SaleStage7
     * Состояние завершается по наступлению времени endDateOfSaleStageLast.
    */
    SaleStageLast,

    /**
     * Состояние наступающее после завершения Ico,
     * при наступлении данного состояния свободные токены сохраняются в unsoldTokens,
     * также происходит бонусное распределение дополнительных токенов Bounty и Team,
     * С момента наступления PostIco покупка токенов невозможна
    */
    PostIco

    }


    /**
    * Здесь храним балансы токенов
    */
    mapping (address => uint256)  balances;

    mapping (address => mapping (address => uint256))  allowed;

    /**
    * Здесь храним начисленные премиальные токены, могут быть выведены на кошелёк начиная с даты startDateOfUseTeamTokens
    */
    mapping (address => uint256) teamBalances;

    /**
    * Владелец контракта - распределяет вип токены, начисляет баунти и team, осуществляет переход по стадиям,
    */
    address public owner;


    /**
    * Участник контракта -  выводит eth после наступления PostIco, совместно с withdrawal2
    */
    address public withdrawal1;

    /**
    * Участник контракта - только при его участии может быть выведены eth после наступления PostIco, совместно с withdrawal1
    */
    address public withdrawal2;




    /**
    * Адрес на счёте которого находятся нераспределённые bounty токены
    */
    address public bountyTokensAccount;

    /**
    * Адрес на счёте которого находятся нераспределённые team токены
    */
    address public teamTokensAccount;

    /**
    *Адрес на который инициирован вывод eth (владельцем)
    */
    address public withdrawalTo;

    /**
    * Количество eth который предполагается выводить на адрес withdrawalTo
    */
    uint256 public withdrawalValue;

    /**
     * Количество нераспределённых токенов bounty
     * */
    uint256 public bountyTokensNotDistributed;

    /**
     * Количество нераспределённых токенов team
     * */
    uint256 public teamTokensNotDistributed;

    /**
      * Текущее состояние
      */
    IcoStates public currentState;

    /**
    * Количество собранного эфира
    */
    uint256 public totalBalance;

    /**
    * Количество свободных токенов (никто ими не владеет)
    */
    uint256 public freeMoney = 0;

    /**
     * Общее количество выпущенных токенов
     * */
    uint256 public totalSupply = 0;

    /**
     * Общее количество купленных токенов
     * */
    uint256 public totalBought = 0;



    /**
     * Количество не распределённых токенов от стадии VipPlacement
     */
    uint256 public vipPlacementNotDistributed;

    /**
     * Дата окончания стадии VipPlacement
    */
    uint256 public endDateOfVipPlacement;

    /**
     * Дата окончания стадии PreSale
    */
    uint256 public endDateOfPreSale = 0;

    /**
     * Дата начала стадии SaleStageLast
    */
    uint256 public startDateOfSaleStageLast;

    /**
     * Дата окончания стадии SaleStageLast
    */
    uint256 public endDateOfSaleStageLast = 0;


    /**
     * Остаток нераспроданных токенов для состояний с SaleStage1 по SaleStage7, которые переходят в свободные на момент наступления SaleStageLast
     */
    uint256 public remForSalesBeforeStageLast = 0;

    /**
    * Дата, начиная с которой можно получить team токены непосредственно на кошелёк
    */
    uint256 public startDateOfUseTeamTokens = 0;

    /**
    * Дата, начиная с которой можно восстановить-перевести нераспроданные токены unsoldTokens
    */
    uint256 public startDateOfRestoreUnsoldTokens = 0;

    /**
    * Количество нераспроданных токенов на момент наступления PostIco
    */
    uint256 public unsoldTokens = 0;

    /**
     * How many token units a buyer gets per wei
     */
    uint256 public rate = 0;


    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    /**
     * @dev Throws if called by any account other than the withdrawal1.
     */
    modifier onlyWithdrawal1() {
        require(msg.sender == withdrawal1);
        _;
    }

    /**
     * @dev Throws if called by any account other than the withdrawal2.
     */
    modifier onlyWithdrawal2() {
        require(msg.sender == withdrawal2);
        _;
    }

    /**
     * Модификатор позволяющий выполнять вызов,
     * только если состояние PostIco или выше
     */
    modifier afterIco() {
        require(uint(currentState) >= uint(IcoStates.PostIco));
        _;
    }


    /**
    * Модификатор проверяющий допустимость операций transfer
    */
    modifier checkForTransfer(address _from, address _to, uint256 _value)  {

        //проверяем размер перевода
        require(_value > 0);

        //проверяем кошелёк назначения
        require(_to != 0x0 && _to != _from);

        //на стадиях перед ico переводить может только владелец
        require(currentState == IcoStates.PostIco || _from == owner);

        //операции на bounty и team не допустимы до окончания ico
        require(currentState == IcoStates.PostIco || (_to != bountyTokensAccount && _to != teamTokensAccount));

        _;
    }



    /**
     * Событие изменения состояния контракта
     */
    event StateChanged(IcoStates state);


    /**
     * Событие покупки токенов
     */
    event Buy(address beneficiary, uint256 boughtTokens, uint256 ethValue);

    /**
    * @dev Конструктор
    */
    function RobomedIco() public {

        //проверяем, что все указанные адреса не равны 0, также они отличаются от создающего контракт
        //по сути контракт создаёт некое 3-ее лицо не имеющее в дальнейшем ни каких особенных прав
        //так же действует условие что все перичисленные адреса разные (нельзя быть одновременно владельцем и кошельком для токенов - например)
        require(ADDR_OWNER != 0x0 && ADDR_OWNER != msg.sender);
        require(ADDR_WITHDRAWAL1 != 0x0 && ADDR_WITHDRAWAL1 != msg.sender);
        require(ADDR_WITHDRAWAL2 != 0x0 && ADDR_WITHDRAWAL2 != msg.sender);
        require(ADDR_BOUNTY_TOKENS_ACCOUNT != 0x0 && ADDR_BOUNTY_TOKENS_ACCOUNT != msg.sender);
        require(ADDR_TEAM_TOKENS_ACCOUNT != 0x0 && ADDR_TEAM_TOKENS_ACCOUNT != msg.sender);

        require(ADDR_BOUNTY_TOKENS_ACCOUNT != ADDR_TEAM_TOKENS_ACCOUNT);
        require(ADDR_OWNER != ADDR_TEAM_TOKENS_ACCOUNT);
        require(ADDR_OWNER != ADDR_BOUNTY_TOKENS_ACCOUNT);
        require(ADDR_WITHDRAWAL1 != ADDR_OWNER);
        require(ADDR_WITHDRAWAL1 != ADDR_BOUNTY_TOKENS_ACCOUNT);
        require(ADDR_WITHDRAWAL1 != ADDR_TEAM_TOKENS_ACCOUNT);
        require(ADDR_WITHDRAWAL2 != ADDR_OWNER);
        require(ADDR_WITHDRAWAL2 != ADDR_BOUNTY_TOKENS_ACCOUNT);
        require(ADDR_WITHDRAWAL2 != ADDR_TEAM_TOKENS_ACCOUNT);
        require(ADDR_WITHDRAWAL2 != ADDR_WITHDRAWAL1);

        //выставляем адреса
        //test
        owner = ADDR_OWNER;
        withdrawal1 = ADDR_WITHDRAWAL1;
        withdrawal2 = ADDR_WITHDRAWAL2;
        bountyTokensAccount = ADDR_BOUNTY_TOKENS_ACCOUNT;
        teamTokensAccount = ADDR_TEAM_TOKENS_ACCOUNT;

        //устанавливаем начальное значение на предопределённых аккаунтах
        balances[owner] = INITIAL_COINS_FOR_VIPPLACEMENT;
        balances[bountyTokensAccount] = EMISSION_FOR_BOUNTY;
        balances[teamTokensAccount] = EMISSION_FOR_TEAM;

        //нераспределённые токены
        bountyTokensNotDistributed = EMISSION_FOR_BOUNTY;
        teamTokensNotDistributed = EMISSION_FOR_TEAM;
        vipPlacementNotDistributed = INITIAL_COINS_FOR_VIPPLACEMENT;

        currentState = IcoStates.VipPlacement;
        totalSupply = INITIAL_COINS_FOR_VIPPLACEMENT + EMISSION_FOR_BOUNTY + EMISSION_FOR_TEAM;

        endDateOfVipPlacement = now.add(DURATION_VIPPLACEMENT);
        remForSalesBeforeStageLast = 0;


        //set team for members
        owner = msg.sender;
        //ildar
        transferTeam(0xa19DC4c158169bC45b17594d3F15e4dCb36CC3A3, TEAM_MEMBER_VAL);
        //vova
        transferTeam(0xdf66490Fe9F2ada51967F71d6B5e26A9D77065ED, TEAM_MEMBER_VAL);
        //kirill
        transferTeam(0xf0215C6A553AD8E155Da69B2657BeaBC51d187c5, TEAM_MEMBER_VAL);
        //evg
        transferTeam(0x6c1666d388302385AE5c62993824967a097F14bC, TEAM_MEMBER_VAL);
        //igor
        transferTeam(0x82D550dC74f8B70B202aB5b63DAbe75E6F00fb36, TEAM_MEMBER_VAL);
        owner = ADDR_OWNER;
    }

    /**
    * Function to access name of token .
    */
    function name() public constant returns (string) {
        return name;
    }

    /**
    * Function to access symbol of token .
    */
    function symbol() public constant returns (string) {
        return symbol;
    }

    /**
    * Function to access decimals of token .
    */
    function decimals() public constant returns (uint8) {
        return decimals;
    }


    /**
    * Function to access total supply of tokens .
    */
    function totalSupply() public constant returns (uint256) {
        return totalSupply;
    }

    /**
    * Метод получающий количество начисленных премиальных токенов
    */
    function teamBalanceOf(address _owner) public constant returns (uint256){
        return teamBalances[_owner];
    }

    /**
    * Метод зачисляющий предварительно распределённые team токены на кошелёк
    */
    function accrueTeamTokens() public afterIco {
        //зачисление возможно только после определённой даты
        require(startDateOfUseTeamTokens <= now);

        //добавляем в общее количество выпущенных
        totalSupply = totalSupply.add(teamBalances[msg.sender]);

        //зачисляем на кошелёк и обнуляем не начисленные
        balances[msg.sender] = balances[msg.sender].add(teamBalances[msg.sender]);
        teamBalances[msg.sender] = 0;
    }

    /**
    * Метод проверяющий возможность восстановления нераспроданных токенов
    */
    function canRestoreUnsoldTokens() public constant returns (bool) {
        //восстановление возможно только после ico
        if (currentState != IcoStates.PostIco) return false;

        //восстановление возможно только после определённой даты
        if (startDateOfRestoreUnsoldTokens > now) return false;

        //восстановление возможно только если есть что восстанавливать
        if (unsoldTokens == 0) return false;

        return true;
    }

    /**
    * Метод выполняющий восстановление нераспроданных токенов
    */
    function restoreUnsoldTokens(address _to) public onlyOwner {
        require(_to != 0x0);
        require(canRestoreUnsoldTokens());

        balances[_to] = balances[_to].add(unsoldTokens);
        totalSupply = totalSupply.add(unsoldTokens);
        unsoldTokens = 0;
    }

    /**
     * Метод переводящий контракт в следующее доступное состояние,
     * Для выяснения возможности перехода можно использовать метод canGotoState
    */
    function gotoNextState() public onlyOwner returns (bool)  {

        if (gotoPreSale() || gotoSaleStage1() || gotoSaleStageLast() || gotoPostIco()) {
            return true;
        }
        return false;
    }


    /**
    * Инициация снятия эфира на указанный кошелёк
    */
    function initWithdrawal(address _to, uint256 _value) public afterIco onlyWithdrawal1 {
        withdrawalTo = _to;
        withdrawalValue = _value;
    }

    /**
    * Подтверждение снятия эфира на указанный кошелёк
    */
    function approveWithdrawal(address _to, uint256 _value) public afterIco onlyWithdrawal2 {
        require(_to != 0x0 && _value > 0);
        require(_to == withdrawalTo);
        require(_value == withdrawalValue);

        totalBalance = totalBalance.sub(_value);
        withdrawalTo.transfer(_value);

        withdrawalTo = 0x0;
        withdrawalValue = 0;
    }



    /**
     * Метод проверяющий возможность перехода в указанное состояние
     */
    function canGotoState(IcoStates toState) public constant returns (bool){
        if (toState == IcoStates.PreSale) {
            return (currentState == IcoStates.VipPlacement && endDateOfVipPlacement <= now);
        }
        else if (toState == IcoStates.SaleStage1) {
            return (currentState == IcoStates.PreSale && endDateOfPreSale <= now);
        }
        else if (toState == IcoStates.SaleStage2) {
            return (currentState == IcoStates.SaleStage1 && freeMoney == 0 && startDateOfSaleStageLast > now);
        }
        else if (toState == IcoStates.SaleStage3) {
            return (currentState == IcoStates.SaleStage2 && freeMoney == 0 && startDateOfSaleStageLast > now);
        }
        else if (toState == IcoStates.SaleStage4) {
            return (currentState == IcoStates.SaleStage3 && freeMoney == 0 && startDateOfSaleStageLast > now);
        }
        else if (toState == IcoStates.SaleStage5) {
            return (currentState == IcoStates.SaleStage4 && freeMoney == 0 && startDateOfSaleStageLast > now);
        }
        else if (toState == IcoStates.SaleStage6) {
            return (currentState == IcoStates.SaleStage5 && freeMoney == 0 && startDateOfSaleStageLast > now);
        }
        else if (toState == IcoStates.SaleStage7) {
            return (currentState == IcoStates.SaleStage6 && freeMoney == 0 && startDateOfSaleStageLast > now);
        }
        else if (toState == IcoStates.SaleStageLast) {
            //переход на состояние SaleStageLast возможен только из состояний SaleStages
            if (
            currentState != IcoStates.SaleStage1
            &&
            currentState != IcoStates.SaleStage2
            &&
            currentState != IcoStates.SaleStage3
            &&
            currentState != IcoStates.SaleStage4
            &&
            currentState != IcoStates.SaleStage5
            &&
            currentState != IcoStates.SaleStage6
            &&
            currentState != IcoStates.SaleStage7) return false;

            //переход осуществляется если на состоянии SaleStage7 не осталось свободных токенов
            //или на одном из состояний SaleStages наступило время startDateOfSaleStageLast
            if (!(currentState == IcoStates.SaleStage7 && freeMoney == 0) && startDateOfSaleStageLast > now) {
                return false;
            }

            return true;
        }
        else if (toState == IcoStates.PostIco) {
            return (currentState == IcoStates.SaleStageLast && endDateOfSaleStageLast <= now);
        }
    }

    /**
    * Fallback функция - из неё по сути просто происходит вызов покупки токенов для отправителя
    */
    function() public payable {
        buyTokens(msg.sender);
    }

    /**
     * Метод покупки токенов
     */
    function buyTokens(address beneficiary) public payable {
        require(beneficiary != 0x0);
        require(msg.value != 0);

        //нельзя покупать на токены bounty и team
        require(beneficiary != bountyTokensAccount && beneficiary != teamTokensAccount);

        //выставляем остаток средств
        //в процессе покупки будем его уменьшать на каждой итерации - итерация - покупка токенов на определённой стадии
        //суть - если покупающий переводит количество эфира,
        //большее чем возможное количество свободных токенов на определённой стадии,
        //то выполняется переход на следующую стадию (курс тоже меняется)
        //и на остаток идёт покупка на новой стадии и т.д.
        //если же в процессе покупке все свободные токены израсходуются (со всех допустимых стадий)
        //будет выкинуто исключение
        uint256 remVal = msg.value;

        //увеличиваем количество эфира пришедшего к нам
        totalBalance = totalBalance.add(msg.value);

        //общее количество токенов которые купили за этот вызов
        uint256 boughtTokens = 0;

        while (remVal > 0) {
            //покупать токены можно только на указанных стадиях
            require(
            currentState != IcoStates.VipPlacement
            &&
            currentState != IcoStates.PostIco);

            //выполняем покупку для вызывающего
            //смотрим, есть ли у нас такое количество свободных токенов на текущей стадии
            uint256 tokens = remVal.mul(rate);
            if (tokens > freeMoney) {
                remVal = remVal.sub(freeMoney.div(rate));
                tokens = freeMoney;
            }
            else
            {
                remVal = 0;
                //если остаток свободных токенов меньше чем курс - отдаём их покупателю
                uint256 remFreeTokens = freeMoney.sub(tokens);
                if (0 < remFreeTokens && remFreeTokens < rate) {
                    tokens = freeMoney;
                }
            }
            assert(tokens > 0);

            freeMoney = freeMoney.sub(tokens);
            totalBought = totalBought.add(tokens);
            balances[beneficiary] = balances[beneficiary].add(tokens);
            boughtTokens = boughtTokens.add(tokens);

            //если покупка была выполнена на любой из стадий Sale кроме последней
            if (
            uint(currentState) >= uint(IcoStates.SaleStage1)
            &&
            uint(currentState) <= uint(IcoStates.SaleStage7)) {

                //уменьшаем количество остатка по токенам которые необходимо продать на этих стадиях
                remForSalesBeforeStageLast = remForSalesBeforeStageLast.sub(tokens);

                //пробуем перейти между SaleStages
                transitionBetweenSaleStages();
            }

        }

        Buy(beneficiary, boughtTokens, msg.value);

    }

    /**
    * Метод выполняющий выдачу баунти-токенов на указанный адрес
    */
    function transferBounty(address _to, uint256 _value) public onlyOwner {
        //проверяем кошелёк назначения
        require(_to != 0x0 && _to != msg.sender);

        //уменьшаем количество нераспределённых
        bountyTokensNotDistributed = bountyTokensNotDistributed.sub(_value);

        //переводим с акаунта баунти на акаунт назначения
        balances[_to] = balances[_to].add(_value);
        balances[bountyTokensAccount] = balances[bountyTokensAccount].sub(_value);

        Transfer(bountyTokensAccount, _to, _value);
    }

    /**
    * Метод выполняющий выдачу баунти-токенов на указанный адрес
    */
    function transferTeam(address _to, uint256 _value) public onlyOwner {
        //проверяем кошелёк назначения
        require(_to != 0x0 && _to != msg.sender);

        //уменьшаем количество нераспределённых
        teamTokensNotDistributed = teamTokensNotDistributed.sub(_value);

        //переводим с акаунта team на team акаунт назначения
        teamBalances[_to] = teamBalances[_to].add(_value);
        balances[teamTokensAccount] = balances[teamTokensAccount].sub(_value);

        //убираем токены из общего количества выпущенных
        totalSupply = totalSupply.sub(_value);
    }

    /**
    * Function that is called when a user or another contract wants to transfer funds .
    */
    function transfer(address _to, uint _value, bytes _data) checkForTransfer(msg.sender, _to, _value) public returns (bool) {

        if (isContract(_to)) {
            return transferToContract(_to, _value, _data);
        }
        else {
            return transferToAddress(_to, _value, _data);
        }
    }


    /**
    * @dev transfer token for a specified address
    * Standard function transfer similar to ERC20 transfer with no _data .
    * Added due to backwards compatibility reasons .
    * @param _to The address to transfer to.
    * @param _value The amount to be transferred.
    */
    function transfer(address _to, uint _value) checkForTransfer(msg.sender, _to, _value) public returns (bool) {

        //standard function transfer similar to ERC20 transfer with no _data
        //added due to backwards compatibility reasons
        bytes memory empty;
        if (isContract(_to)) {
            return transferToContract(_to, _value, empty);
        }
        else {
            return transferToAddress(_to, _value, empty);
        }
    }

    /**
    * assemble the given address bytecode. If bytecode exists then the _addr is a contract.
    */
    function isContract(address _addr) private view returns (bool) {
        uint length;
        assembly {
        //retrieve the size of the code on target address, this needs assembly
        length := extcodesize(_addr)
        }
        return (length > 0);
    }

    /**
    * function that is called when transaction target is an address
    */
    function transferToAddress(address _to, uint _value, bytes _data) private returns (bool) {
        _transfer(msg.sender, _to, _value);
        Transfer(msg.sender, _to, _value, _data);
        return true;
    }

    /**
    * function that is called when transaction target is a contract
    */
    function transferToContract(address _to, uint _value, bytes _data) private returns (bool success) {
        _transfer(msg.sender, _to, _value);
        ContractReceiver receiver = ContractReceiver(_to);
        receiver.tokenFallback(msg.sender, _value, _data);
        Transfer(msg.sender, _to, _value, _data);
        return true;
    }

    function _transfer(address _from, address _to, uint _value) private {
        require(balances[_from] >= _value);
        balances[_from] = balances[_from].sub(_value);
        balances[_to] = balances[_to].add(_value);
        if (currentState != IcoStates.PostIco) {
            //общая сумма переводов от владельца (до завершения) ico не может превышать InitialCoinsFor_VipPlacement
            vipPlacementNotDistributed = vipPlacementNotDistributed.sub(_value);
        }
    }




    /**
    * @dev Gets the balance of the specified address.
    * @param _owner The address to query the the balance of.
    * @return An uint256 representing the amount owned by the passed address.
    */
    function balanceOf(address _owner) public constant returns (uint256 balance) {
        return balances[_owner];
    }

    /**
     * @dev Transfer tokens from one address to another
     * @param _from address The address which you want to send tokens from
     * @param _to address The address which you want to transfer to
     * @param _value uint256 the amout of tokens to be transfered
     */
    function transferFrom(address _from, address _to, uint256 _value) public afterIco returns (bool) {

        var _allowance = allowed[_from][msg.sender];

        // Check is not needed because sub(_allowance, _value) will already throw if this condition is not met
        // require (_value <= _allowance);

        balances[_to] = balances[_to].add(_value);
        balances[_from] = balances[_from].sub(_value);
        allowed[_from][msg.sender] = _allowance.sub(_value);
        Transfer(_from, _to, _value);
        return true;
    }

    /**
     * @dev Aprove the passed address to spend the specified amount of tokens on behalf of msg.sender.
     * @param _spender The address which will spend the funds.
     * @param _value The amount of tokens to be spent.
     */
    function approve(address _spender, uint256 _value) public afterIco returns (bool) {
        // To change the approve amount you first have to reduce the addresses`
        //  allowance to zero by calling `approve(_spender, 0)` if it is not
        //  already 0 to mitigate the race condition described here:
        //  https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
        require((_value == 0) || (allowed[msg.sender][_spender] == 0));

        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }

    /**
     * @dev Function to check the amount of tokens that an owner allowed to a spender.
     * @param _owner address The address which owns the funds.
     * @param _spender address The address which will spend the funds.
     * @return A uint256 specifing the amount of tokens still available for the spender.
     */
    function allowance(address _owner, address _spender) public constant returns (uint256 remaining) {
        return allowed[_owner][_spender];
    }

    /**
    * Вспомогательный метод выставляющий количество свободных токенов, рейт и добавляющий количество эмитированных
    */
    function setMoney(uint256 _freeMoney, uint256 _emission, uint256 _rate) private {
        freeMoney = _freeMoney;
        totalSupply = totalSupply.add(_emission);
        rate = _rate;
    }

    /**
     * Метод переводящий контракт в состояние PreSale
     */
    function gotoPreSale() private returns (bool) {

        //проверяем возможность перехода
        if (!canGotoState(IcoStates.PreSale)) return false;

        //да нужно переходить

        //переходим в PreSale
        currentState = IcoStates.PreSale;


        //выставляем состояние токенов
        setMoney(EMISSION_FOR_PRESALE, EMISSION_FOR_PRESALE, RATE_PRESALE);

        //устанавливаем дату окончания PreSale
        endDateOfPreSale = now.add(DURATION_PRESALE);

        //разим событие изменения состояния
        StateChanged(IcoStates.PreSale);
        return true;
    }

    /**
    * Метод переводящий контракт в состояние SaleStage1
    */
    function gotoSaleStage1() private returns (bool) {
        //проверяем возможность перехода
        if (!canGotoState(IcoStates.SaleStage1)) return false;

        //да нужно переходить

        //переходим в SaleStage1
        currentState = IcoStates.SaleStage1;

        //непроданные токены сгорают
        totalSupply = totalSupply.sub(freeMoney);

        //выставляем состояние токенов
        setMoney(EMISSION_FOR_SALESTAGE1, EMISSION_FOR_SALESTAGE1, RATE_SALESTAGE1);

        //определяем количество токенов которое можно продать на всех стадиях Sale кроме последней
        remForSalesBeforeStageLast =
        EMISSION_FOR_SALESTAGE1 +
        EMISSION_FOR_SALESTAGE2 +
        EMISSION_FOR_SALESTAGE3 +
        EMISSION_FOR_SALESTAGE4 +
        EMISSION_FOR_SALESTAGE5 +
        EMISSION_FOR_SALESTAGE6 +
        EMISSION_FOR_SALESTAGE7;


        //устанавливаем дату начала последней стадии продаж
        startDateOfSaleStageLast = now.add(DURATION_SALESTAGES);

        //разим событие изменения состояния
        StateChanged(IcoStates.SaleStage1);
        return true;
    }

    /**
     * Метод выполняющий переход между состояниями Sale
     */
    function transitionBetweenSaleStages() private {
        //переход между состояниями SaleStages возможен только если находимся в одном из них, кроме последнего
        if (
        currentState != IcoStates.SaleStage1
        &&
        currentState != IcoStates.SaleStage2
        &&
        currentState != IcoStates.SaleStage3
        &&
        currentState != IcoStates.SaleStage4
        &&
        currentState != IcoStates.SaleStage5
        &&
        currentState != IcoStates.SaleStage6
        &&
        currentState != IcoStates.SaleStage7) return;

        //если есть возможность сразу переходим в состояние StageLast
        if (gotoSaleStageLast()) {
            return;
        }

        //смотрим в какое состояние можем перейти и выполняем переход
        if (canGotoState(IcoStates.SaleStage2)) {
            currentState = IcoStates.SaleStage2;
            setMoney(EMISSION_FOR_SALESTAGE2, EMISSION_FOR_SALESTAGE2, RATE_SALESTAGE2);
            StateChanged(IcoStates.SaleStage2);
        }
        else if (canGotoState(IcoStates.SaleStage3)) {
            currentState = IcoStates.SaleStage3;
            setMoney(EMISSION_FOR_SALESTAGE3, EMISSION_FOR_SALESTAGE3, RATE_SALESTAGE3);
            StateChanged(IcoStates.SaleStage3);
        }
        else if (canGotoState(IcoStates.SaleStage4)) {
            currentState = IcoStates.SaleStage4;
            setMoney(EMISSION_FOR_SALESTAGE4, EMISSION_FOR_SALESTAGE4, RATE_SALESTAGE4);
            StateChanged(IcoStates.SaleStage4);
        }
        else if (canGotoState(IcoStates.SaleStage5)) {
            currentState = IcoStates.SaleStage5;
            setMoney(EMISSION_FOR_SALESTAGE5, EMISSION_FOR_SALESTAGE5, RATE_SALESTAGE5);
            StateChanged(IcoStates.SaleStage5);
        }
        else if (canGotoState(IcoStates.SaleStage6)) {
            currentState = IcoStates.SaleStage6;
            setMoney(EMISSION_FOR_SALESTAGE6, EMISSION_FOR_SALESTAGE6, RATE_SALESTAGE6);
            StateChanged(IcoStates.SaleStage6);
        }
        else if (canGotoState(IcoStates.SaleStage7)) {
            currentState = IcoStates.SaleStage7;
            setMoney(EMISSION_FOR_SALESTAGE7, EMISSION_FOR_SALESTAGE7, RATE_SALESTAGE7);
            StateChanged(IcoStates.SaleStage7);
        }
    }

    /**
      * Метод переводящий контракт в состояние SaleStageLast
      */
    function gotoSaleStageLast() private returns (bool) {
        if (!canGotoState(IcoStates.SaleStageLast)) return false;

        //ок переходим на состояние SaleStageLast
        currentState = IcoStates.SaleStageLast;

        //выставляем состояние токенов, с учётом всех остатков
        setMoney(remForSalesBeforeStageLast + EMISSION_FOR_SALESTAGELAST, EMISSION_FOR_SALESTAGELAST, RATE_SALESTAGELAST);


        //устанавливаем дату окончания SaleStageLast
        endDateOfSaleStageLast = now.add(DURATION_SALESTAGELAST);

        StateChanged(IcoStates.SaleStageLast);
        return true;
    }



    /**
      * Метод переводящий контракт в состояние PostIco
      */
    function gotoPostIco() private returns (bool) {
        if (!canGotoState(IcoStates.PostIco)) return false;

        //ок переходим на состояние PostIco
        currentState = IcoStates.PostIco;

        //выставляем дату после которой можно использовать премиальные токены
        startDateOfUseTeamTokens = now + DURATION_NONUSETEAM;

        //выставляем дату после которой можно зачислять оставшиеся (не распроданные) токены, на произвольный кошелёк
        startDateOfRestoreUnsoldTokens = now + DURATION_BEFORE_RESTORE_UNSOLD;

        //запоминаем количество нераспроданных токенов
        unsoldTokens = freeMoney;

        //уничтожаем свободные токены
        totalSupply = totalSupply.sub(freeMoney);
        setMoney(0, 0, 0);

        StateChanged(IcoStates.PostIco);
        return true;
    }


}