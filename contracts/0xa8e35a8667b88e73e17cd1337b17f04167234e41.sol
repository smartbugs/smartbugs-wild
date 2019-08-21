pragma solidity ^0.4.25;

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
contract PreICO is Ownable {

    ERC20 public token;
    
    ERC20 public authorize;
    
    using SafeMath for uint;

    address public backEndOperator = msg.sender;
    address bounty = 0xAddEB4E7780DB11b7C5a0b7E96c133e50f05740E; // 0.4% - для баунти программы

    mapping(address=>bool) public whitelist;

    mapping(address => uint256) public investedEther;

    uint256 public startPreICO = 1543700145; 
    uint256 public endPreICO = 1547510400; 

    uint256 public investors; // total number of investors
    uint256 public weisRaised; // total amount collected by ether

    uint256 public hardCap1Stage = 10000000*1e18; // 10,000,000 SPC = $1,000,000 EURO

    uint256 public buyPrice; // 0.1 EURO
    uint256 public euroPrice; // Ether by USD

    uint256 public soldTokens; // solded tokens - > 10,000,000 SPC

    event Authorized(address wlCandidate, uint timestamp);
    event Revoked(address wlCandidate, uint timestamp);
    event UpdateDollar(uint256 time, uint256 _rate);

    modifier backEnd() {
        require(msg.sender == backEndOperator || msg.sender == owner);
        _;
    }

    // contract constructor
    constructor(ERC20 _token, ERC20 _authorize, uint256 usdETH) public {
        token = _token;
        authorize = _authorize;
        euroPrice = usdETH;
        buyPrice = (1e18/euroPrice).div(10); // 0.1 euro
    }

    // change the date of commencement of pre-sale
    function setStartSale(uint256 newStartSale) public onlyOwner {
        startPreICO = newStartSale;
    }

    // change the date of the end of pre-sale
    function setEndSale(uint256 newEndSale) public onlyOwner {
        endPreICO = newEndSale;
    }

    // Change of operator’s backend address
    function setBackEndAddress(address newBackEndOperator) public onlyOwner {
        backEndOperator = newBackEndOperator;
    }

    // Change in the rate of dollars to broadcast
    function setBuyPrice(uint256 _dollar) public backEnd {
        euroPrice = _dollar;
        buyPrice = (1e18/euroPrice).div(10); // 0.1 euro
        emit UpdateDollar(now, euroPrice);
    }


    /*******************************************************************************
     * Payable's section
     */

    function isPreICO() public constant returns(bool) {
        return now >= startPreICO && now <= endPreICO;
    }

    // callback contract function
    function () public payable {
        require(authorize.isWhitelisted(msg.sender));
        require(isPreICO());
        require(msg.value >= buyPrice.mul(100)); // ~ 10 EURO
        SalePreICO(msg.sender, msg.value);
        require(soldTokens<=hardCap1Stage);
        investedEther[msg.sender] = investedEther[msg.sender].add(msg.value);
    }

    // release of tokens during the pre-sale period
    function SalePreICO(address _investor, uint256 _value) internal {
        uint256 tokens = _value.mul(1e18).div(buyPrice);
        token.mintFromICO(_investor, tokens);
        soldTokens = soldTokens.add(tokens);
        uint256 tokensBoynty = tokens.div(250); // 2 %
        token.mintFromICO(bounty, tokensBoynty);
        weisRaised = weisRaised.add(_value);
    }
    
    function manualMint(address _investor, uint256 _tokens)  public onlyOwner {
        token.mintFromICO(_investor, _tokens);
    }
    
    // Sending air from the contract
    function transferEthFromContract(address _to, uint256 amount) public onlyOwner {
        _to.transfer(amount);
    }

   
}