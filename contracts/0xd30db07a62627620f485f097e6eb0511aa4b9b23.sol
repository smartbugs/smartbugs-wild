pragma solidity ^0.4.13;

library SafeMath {
    function mul(uint256 a, uint256 b) internal constant returns (uint256) {
        uint256 c = a * b;
        assert(a == 0 || c / a == b);
        return c;
    }
    function div(uint256 a, uint256 b) internal constant returns (uint256) {
        uint256 c = a / b;
        return c;
    }
    function sub(uint256 a, uint256 b) internal constant returns (uint256) {
        assert(b <= a);
        return a - b;
    }
    function add(uint256 a, uint256 b) internal constant returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }
}

contract ExtFueldToken {
    using SafeMath for uint256;
// ownable
    address public owner;
    address public mainContract;

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    function transferOwnership(address newOwner) onlyOwner public {
        require(newOwner != address(0));
        OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }

// self transfer
    mapping(address => uint256) balances;
    event Transfer(address indexed from, address indexed to, uint256 value);
    function transfer(address _to, uint256 _value) public returns (bool) {
        require(_to != address(0));
        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);
        Transfer(msg.sender, _to, _value);
        return true;
    }
    function balanceOf(address _owner) public constant returns (uint256 balance) {
        return balances[_owner];
    }

// allowed transfer
    mapping (address => mapping (address => uint256)) allowed;
    event Approval(address indexed owner_, address indexed spender, uint256 value);
    function approve(address _spender, uint256 _value) public returns (bool) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }
    function allowance(address _owner, address _spender) public constant returns (uint256 remaining) {
        return allowed[_owner][_spender];
    }
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
        require(_to != address(0));
        uint256 _allowance = allowed[_from][msg.sender];
        balances[_from] = balances[_from].sub(_value);
        balances[_to] = balances[_to].add(_value);
        allowed[_from][msg.sender] = _allowance.sub(_value);
        Transfer(_from, _to, _value);
        return true;
    }
    function increaseApproval (address _spender, uint _addedValue) public returns (bool success) {
        allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
        Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
        return true;
    }
    function decreaseApproval (address _spender, uint _subtractedValue) public returns (bool success) {
        uint oldValue = allowed[msg.sender][_spender];
        if (_subtractedValue > oldValue) { allowed[msg.sender][_spender] = 0; } 
        else {allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue); }
        Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
        return true;
    }

// mintable
    uint256 public totalSupply = 13500000; // minting in constructor
// sale
    mapping (address => uint256) public privatePreICOdepositors;
    mapping (address => uint256) public preICOdepositors;
    mapping (address => uint256) public ICOdepositors;
    mapping (address => uint256) public ICObalances;
    mapping (address => uint256) public depositorCurrency;
    
    uint256 constant public maxPreICOSupply = 13500000; // including free bonus tokens
    uint256 constant public maxPreICOandICOSupply = 13500000;
    uint256 public startTimePrivatePreICO = 0;
    uint256 public startTimePreICO = 0;
    uint256 public startTimeICO = 0;
    uint256 public soldTokenCount = 0;
    uint256 public cap = 0;
    uint256 public capPreICO = 0;
    uint256 public capPreICOTrasferred = 0;
    uint256 public capETH = 0;

    // sale
    event SaleStatus(string indexed status, uint256 indexed _date);

    function startPrivatePreICO() onlyOwner public {
        require(startTimeICO == 0 && startTimePreICO == 0);
        startTimePreICO = now;
        startTimePrivatePreICO = startTimePreICO;
        SaleStatus('Private Pre ICO started', startTimePreICO);
    }
    
    function startPreICO() onlyOwner public {
        require(startTimeICO == 0 && startTimePreICO == 0);
        startTimePreICO = now;
        SaleStatus('Public Pre ICO started', startTimePreICO);
    }

    function startICO() onlyOwner public {
        require(startTimeICO == 0 && startTimePreICO == 0);
        startTimeICO = now;
        SaleStatus('start ICO', startTimePreICO);
    }

    function stopSale() onlyOwner public {
        require(startTimeICO > 0 || startTimePreICO > 0);
        if (startTimeICO > 0){
            SaleStatus('ICO stopped', now);
        }
        else{
            capPreICO = 0;
            SaleStatus('Pre ICO stopped', now);
        }
        startTimeICO = 0;
        startTimePreICO = 0;
        startTimePrivatePreICO = 0;
    }

    event ExtTokenPurchase(address indexed purchaser, address indexed beneficiary, uint256 value, uint256 currencyCode, uint256 amount);
    function buyTokens(address beneficiary_, uint256 fiatAmount_, uint256 currencyCode_, uint256 amountETH_, uint256 tokensAmount_) onlyOwner public { 
        require(startTimeICO > 0 || startTimePreICO > 0);
        require(msg.sender != address(0));
        
        address depositor = beneficiary_;
        uint256 deposit = fiatAmount_;
        uint256 currencyCode = currencyCode_;
        uint256 amountETH = amountETH_;
        uint256 tokens = tokensAmount_;

        balances[owner] = balances[owner].sub(tokens);
        balances[depositor] = balances[depositor].add(tokens);
        depositorCurrency[depositor] = currencyCode;
        soldTokenCount = soldTokenCount.add(tokens);
        capETH = capETH.add(amountETH);
        if (startTimeICO > 0){
            ICObalances[depositor] = ICObalances[depositor].add(tokens);
        }

        if (startTimeICO > 0){
            ICOdepositors[depositor] = ICOdepositors[depositor].add(deposit);
        }
        else{
            if(startTimePrivatePreICO > 0) {
                privatePreICOdepositors[depositor] = privatePreICOdepositors[depositor].add(deposit);
            }
            else {
                preICOdepositors[depositor] = preICOdepositors[depositor].add(deposit);
            }
        }
        cap = cap.add(deposit);
        if(startTimePreICO > 0) {
            capPreICO = capPreICO.add(deposit);
        }

        FueldToken FueldTokenExt = FueldToken(mainContract);
        FueldTokenExt.extBuyTokens(depositor, tokens, amountETH); 
        ExtTokenPurchase(owner, depositor, deposit, currencyCode, tokens);
    }

    event FixSale(uint256 fixTime);
    bool public fixSaleCompleted = false;
    function fixSale() onlyOwner public {
        require(startTimeICO == 0 && startTimePreICO == 0);
        uint256 currentTime = now;
        soldTokenCount = 0;
        fixSaleCompleted = true;
        FixSale(currentTime);
    }

// burnable
    event Burn(address indexed burner, uint indexed value);
    function burn(uint _value) onlyOwner public {
        require(fixSaleCompleted == true);
        require(_value > 0);
        address burner = msg.sender;
        balances[burner] = balances[burner].sub(_value);
        totalSupply = totalSupply.sub(_value);
        fixSaleCompleted = false;
        Burn(burner, _value);
    }

// constructor
    string constant public name = "EXTFUELD";
    string constant public symbol = "EFL";
    uint32 constant public decimals = 18;

    function setMainContractAddress(address mainContract_) onlyOwner public {
        mainContract = mainContract_;
    }

    function ExtFueldToken() public {
        owner = msg.sender;
        balances[owner] = totalSupply;
    }
}

contract FueldToken{
    function extBuyTokens(address beneficiary_, uint256 tokensAmount_, uint256 amountETH_) public { 
        require(beneficiary_ != address(0));
        require(tokensAmount_ != 0);
        require(amountETH_ != 0);
    }
}