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
contract FueldToken{
    using SafeMath for uint256;
// ownable
    address public multisig;
    address public multisigPreICO;
    address public owner;
    address public extOwner;

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

    event MultisigsChanged(address _multisig, address _multisigPreICO);
    function changeMultisigs(address _multisig, address _multisigPreICO) onlyOwner public {
        require(_multisig != address(0));
        require(_multisigPreICO != address(0));
        multisig = _multisig;
        multisigPreICO = _multisigPreICO;
        MultisigsChanged(multisig, multisigPreICO);
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
    uint256 public totalSupply = 200000000; // minting in constructor
// sale
    mapping (address => uint256) public privatePreICOdepositors;
    mapping (address => uint256) public preICOdepositors;
    mapping (address => uint256) public ICOdepositors;
    mapping (address => uint256) public ICObalances;
    
    uint256 constant public softCap = 6700 ether;
    uint256 constant public hardCap = 67000 ether;
    uint256 constant public price = 456000000000000 wei; // 0.000000456 ETH * 10**18
    
    uint256 constant public maxPreICOSupply = 13500000; // including free bonus tokens
    uint256 constant public maxPreICOandICOSupply = 150000000;

    uint256 constant public privatePreICOFreeBonusPercent = 35;
    uint256 constant public preICOFreeBonusPercent = 30;
    
    uint256 constant public privatePreICOBonusPercent = 0;
    uint256 constant public preICOBonusPercent = 0;
    uint256 constant public ICOBonusPercent1week = 15;
    uint256 constant public ICOBonusPercent2week = 10;
    uint256 constant public ICOBonusPercent3week = 5;
    uint256 constant public restrictedPercent = 25;

    uint256 public startTimePrivatePreICO = 0;
    uint256 public startTimePreICO = 0;
    uint256 public startTimeICO = 0;
    uint256 public soldTokenCount = 0;
    uint256 public cap = 0;
    uint256 public capPreICO = 0;
    uint256 public capPreICOTrasferred = 0;
    uint256 public capFiat = 0;
    uint256 public capFiatAndETH = 0;
    bool public capReached = false;

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
            multisigPreICO.transfer(capPreICO);
            capPreICOTrasferred = capPreICOTrasferred.add(capPreICO);
            capPreICO = 0;
            SaleStatus('Pre ICO stopped', now);
        }
        startTimeICO = 0;
        startTimePreICO = 0;
        startTimePrivatePreICO = 0;
    }

    function currentBonusPercent() public constant returns(uint256 bonus_percent) {
        require(startTimeICO > 0 || startTimePreICO > 0);
        uint256 current_date = now;
        uint256 bonusPercent = 0;
        if (startTimeICO > 0){
            if (current_date > startTimeICO && current_date <= (startTimeICO.add(1 weeks))){ bonusPercent = ICOBonusPercent1week; }
            else{
                if (current_date > startTimeICO && current_date <= (startTimeICO.add(2 weeks))){ bonusPercent = ICOBonusPercent2week; }
                else{
                    if (current_date > startTimeICO && current_date <= (startTimeICO.add(3 weeks))){ bonusPercent = ICOBonusPercent3week; }
                }
            }
        }
        else{
            if(startTimePrivatePreICO > 0) {
                bonusPercent = privatePreICOBonusPercent;
            }
            else {
                bonusPercent = preICOBonusPercent;
            }
        }
        return bonusPercent;
    }

    event TokenPurchase(address indexed purchaser, address indexed beneficiary, uint256 value, uint256 amount);
    function() payable public { 
        require(startTimeICO > 0 || startTimePreICO > 0);
        require(msg.sender != address(0));
        require(msg.value > 0);
        require(cap < hardCap);
        uint256 bonusPercent = currentBonusPercent();
        uint256 currentPrice = price.mul(100 - bonusPercent).div(100);
        address depositor = msg.sender;
        uint256 deposit = msg.value;
        uint256 tokens = deposit/currentPrice;
        if (startTimeICO > 0){
            require(soldTokenCount.add(tokens) <= maxPreICOandICOSupply);
        }
        else{
            if(startTimePrivatePreICO > 0) {
                tokens = (tokens * (100 + privatePreICOFreeBonusPercent)) / 100;
            }
            else {
                tokens = (tokens * (100 + preICOFreeBonusPercent)) / 100;
            }
            require(soldTokenCount.add(tokens) <= maxPreICOSupply);
        }

        balances[owner] = balances[owner].sub(tokens);
        balances[depositor] = balances[depositor].add(tokens);
        soldTokenCount = soldTokenCount.add(tokens);
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

        capFiatAndETH = capFiat.add(cap);
        if(capFiatAndETH >= softCap) {
            capReached = true;
        }
        TokenPurchase(owner, depositor, deposit, tokens);
    }

    event ExtTokenPurchase(address indexed purchaser, address indexed beneficiary, uint256 amount);
    function extBuyTokens(address beneficiary_, uint256 tokensAmount_, uint256 amountETH_) public { 
        require(startTimeICO > 0 || startTimePreICO > 0);
        require(msg.sender != address(0));
        require(msg.sender == extOwner);
        address depositor = beneficiary_;
        uint256 tokens = tokensAmount_;
        uint256 amountETH = amountETH_;

        balances[owner] = balances[owner].sub(tokens);
        balances[depositor] = balances[depositor].add(tokens);
        soldTokenCount = soldTokenCount.add(tokens);

        capFiat = capFiat.add(amountETH);
        capFiatAndETH = capFiat.add(cap);
        if(capFiatAndETH >= softCap) {
            capReached = true;
        }

        ExtTokenPurchase(owner, depositor, tokens);
    }

    function transferExtOwnership(address newOwner_) onlyOwner public {
        extOwner = newOwner_;
    }

// refund
    bool public refundCompleted = false;
    uint256 public startTimeRefund = 0;

    function startRefund() onlyOwner public {
        require(startTimeICO == 0 && startTimePreICO == 0);
        startTimeRefund = now;
        SaleStatus('Refund started', startTimeRefund);
    }

    function stopRefund() onlyOwner public {
        require(startTimeRefund > 0);
        startTimeRefund = 0;
        refundCompleted = true;
        SaleStatus('Refund stopped', now);
    }

    event Refunded(address indexed depositor, uint256 indexed deposit, uint256 indexed tokens);
    function refund() public {
        require(capFiatAndETH < softCap);
        require(startTimeRefund > 0);
        address depositor = msg.sender;
        uint256 deposit = ICOdepositors[depositor];
        uint256 tokens = ICObalances[depositor];    
        ICOdepositors[depositor] = 0;
        ICObalances[depositor] = 0;
        balances[depositor] = balances[depositor].sub(tokens);
        depositor.transfer(deposit);
        balances[owner] = balances[owner].add(tokens);
        cap = cap.sub(deposit);
        capFiatAndETH = capFiatAndETH.sub(deposit);
        soldTokenCount = soldTokenCount.sub(tokens);
        Refunded(depositor, deposit, tokens);
    }

    bool public fixSaleCompleted = false;
    function fixSale() onlyOwner public {
        require(refundCompleted == true);
        require(startTimeICO == 0 && startTimePreICO == 0 && startTimeRefund == 0);
        require(multisig != address(0));
        uint256 restrictedTokens = soldTokenCount * (totalSupply - maxPreICOandICOSupply) / maxPreICOandICOSupply;
        transfer(multisig, restrictedTokens);
        multisig.transfer(cap.sub(capPreICOTrasferred));
        soldTokenCount = 0;
        fixSaleCompleted = true;
    }

// burnable
    event Burn(address indexed burner, uint indexed value);
    function burn(uint _value) onlyOwner public {
        require(fixSaleCompleted == true);
        require(_value > 0);
        address burner = msg.sender;
        balances[burner] = balances[burner].sub(_value);
        totalSupply = totalSupply.sub(_value);
        refundCompleted = false;
        fixSaleCompleted = false;
        Burn(burner, _value);
    }

// constructor
    string constant public name = "FUELD";
    string constant public symbol = "FLD";
    uint32 constant public decimals = 18;

    function FueldToken() public {
        owner = msg.sender;
        balances[owner] = totalSupply;
    }
}