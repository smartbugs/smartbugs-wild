pragma solidity ^0.4.23;

/*** @title SafeMath
 * @dev https://github.com/OpenZeppelin/openzeppelin-solidity/blob/master/contracts/math/SafeMath.sol */
library SafeMath {

    function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
        if (a == 0) {
            return 0;
        }
        c = a * b;
        assert(c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
        c = a + b;
        assert(c >= a);
        return c;
    }
}

interface ERC20 {
    function transfer (address _beneficiary, uint256 _tokenAmount) external returns (bool);
    function mintFromICO(address _to, uint256 _amount) external  returns(bool);
    function isWhitelisted(address wlCandidate) external returns(bool);
}
/**
 * @title Ownable
 * @dev https://github.com/OpenZeppelin/openzeppelin-solidity/blob/master/contracts/ownership/Ownable.sol
 */
contract Ownable {
    address public owner;

    constructor() public {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }
}

/**
 * @title CrowdSale
 * @dev https://github.com/
 */
contract OneStageMainSale is Ownable {

    ERC20 public token;
    
    ERC20 public authorize;
    
    using SafeMath for uint;

    address public backEndOperator = msg.sender;
    address team = 0x7eDE8260e573d3A3dDfc058f19309DF5a1f7397E; // 33% - team и ранние инвесторы проекта
    address bounty = 0x0cdb839B52404d49417C8Ded6c3E2157A06CdD37; // 2% - для баунти программы
    address reserve = 0xC032D3fCA001b73e8cC3be0B75772329395caA49; // 5%  - для резерва

    mapping(address=>bool) public whitelist;

    mapping(address => uint256) public investedEther;

    uint256 public start1StageSale = 1539561601; // Monday, 15-Oct-18 00:00:01 UTC
    uint256 public end1StageSale = 1542326399; // Thursday, 15-Nov-18 23:59:59 UTC

    uint256 public investors; // общее количество инвесторов
    uint256 public weisRaised; // общее колиество собранных Ether

    uint256 public softCap1Stage = 1000000*1e18; // $2,600,000 = 1,000,000 INM
    uint256 public hardCap1Stage = 1700000*1e18; // 1,700,000 INM = $4,420,000 USD

    uint256 public buyPrice; // 2.6 USD 
    uint256 public dollarPrice; // Ether by USD

    uint256 public soldTokens; // solded tokens - > 1,700,000 INM

    event Authorized(address wlCandidate, uint timestamp);
    event Revoked(address wlCandidate, uint timestamp);
    event UpdateDollar(uint256 time, uint256 _rate);

    modifier backEnd() {
        require(msg.sender == backEndOperator || msg.sender == owner);
        _;
    }

    // конструктор контракта
    constructor(ERC20 _token, ERC20 _authorize, uint256 usdETH) public {
        token = _token;
        authorize = _authorize;
        dollarPrice = usdETH;
        buyPrice = (1e17/dollarPrice)*26; // 2.60 usd
    }

    // изменение даты начала предварительной распродажи
    function setStartOneSale(uint256 newStart1Sale) public onlyOwner {
        start1StageSale = newStart1Sale;
    }

    // изменение даты окончания предварительной распродажи
    function setEndOneSale(uint256 newEnd1Sale) public onlyOwner {
        end1StageSale = newEnd1Sale;
    }

    // Изменение адреса оператора бекэнда
    function setBackEndAddress(address newBackEndOperator) public onlyOwner {
        backEndOperator = newBackEndOperator;
    }

    // Изменение курса доллра к эфиру
    function setBuyPrice(uint256 _dollar) public backEnd {
        dollarPrice = _dollar;
        buyPrice = (1e17/dollarPrice)*26; // 2.60 usd
        emit UpdateDollar(now, dollarPrice);
    }


    /*******************************************************************************
     * Payable's section
     */

    function isOneStageSale() public constant returns(bool) {
        return now >= start1StageSale && now <= end1StageSale;
    }

    // callback функция контракта
    function () public payable {
        require(authorize.isWhitelisted(msg.sender));
        require(isOneStageSale());
        require(msg.value >= 19*buyPrice); // ~ 50 USD
        SaleOneStage(msg.sender, msg.value);
        require(soldTokens<=hardCap1Stage);
        investedEther[msg.sender] = investedEther[msg.sender].add(msg.value);
    }

    // выпуск токенов в период предварительной распродажи
    function SaleOneStage(address _investor, uint256 _value) internal {
        uint256 tokens = _value.mul(1e18).div(buyPrice);
        uint256 tokensByDate = tokens.div(10);
        uint256 bonusSumTokens = tokens.mul(bonusSum(tokens)).div(100);
        tokens = tokens.add(tokensByDate).add(bonusSumTokens); // 60%
        token.mintFromICO(_investor, tokens);
        soldTokens = soldTokens.add(tokens);

        uint256 tokensTeam = tokens.mul(11).div(20); // 33 %
        token.mintFromICO(team, tokensTeam);

        uint256 tokensBoynty = tokens.div(30); // 2 %
        token.mintFromICO(bounty, tokensBoynty);

        uint256 tokensReserve = tokens.div(12);  // 5 %
        token.mintFromICO(reserve, tokensReserve);

        weisRaised = weisRaised.add(_value);
    }

    function bonusSum(uint256 _amount) pure private returns(uint256) {
        if (_amount > 76923*1e18) { // 200k+	10% INMCoin
            return 10;
        } else if (_amount > 19230*1e18) { // 50k - 200k	7% INMCoin
            return 7;
        } else if (_amount > 7692*1e18) { // 20k - 50k	5% INMCoin
            return 5;
        } else if (_amount > 1923*1e18) { // 5k - 20k	3% INMCoin
            return 3;
        } else {
            return 0;
        }
    }

    // Отправка эфира с контракта
    function transferEthFromContract(address _to, uint256 amount) public onlyOwner {
        _to.transfer(amount);
    }

    /*******************************************************************************
     * Refundable
     */
    function refund1ICO() public {
        require(soldTokens < softCap1Stage && now > end1StageSale);
        uint rate = investedEther[msg.sender];
        require(investedEther[msg.sender] >= 0);
        investedEther[msg.sender] = 0;
        msg.sender.transfer(rate);
        weisRaised = weisRaised.sub(rate);
    }
}