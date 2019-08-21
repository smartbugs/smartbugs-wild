pragma solidity ^0.4.23;

contract Token { // ERC20 standard

    function balanceOf(address _owner) public view returns (uint256 balance);
    function transfer(address _to, uint256 _value) public returns (bool success);
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);
    function approve(address _spender, uint256 _value) public returns (bool success);
    function allowance(address _owner, address _spender) public view returns (uint256 remaining);
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);

}


/**
 * Overflow aware uint math functions.
 *
 * Inspired by https://github.com/MakerDAO/maker-otc/blob/master/contracts/simple_market.sol
 */

contract SafeMath {

    function safeMul(uint a, uint b) internal pure returns (uint) {
        uint c = a * b;
        assert(a == 0 || c / a == b);
        return c;
    }

    function safeSub(uint a, uint b) internal pure returns (uint) {
        assert(b <= a);
        return a - b;
    }

    function safeAdd(uint a, uint b) internal pure returns (uint) {
        uint c = a + b;
        assert(c>=a && c>=b);
        return c;
    }
	
	function safeDiv(uint a, uint b) internal pure returns (uint) {
		// assert(b > 0); // Solidity automatically throws when dividing by 0
		uint c = a / b;
		// assert(a == b * c + a % b); // There is no case in which this doesn't hold
		return c;
	}

    // mitigate short address attack
    // thanks to https://github.com/numerai/contract/blob/c182465f82e50ced8dacb3977ec374a892f5fa8c/contracts/Safe.sol#L30-L34.
    // TODO: doublecheck implication of >= compared to ==
    modifier onlyPayloadSize(uint numWords) {
        assert(msg.data.length >= numWords * 32 + 4);
        _;
    }

}

contract StandardToken is Token, SafeMath {

    uint256 public totalSupply;

    // TODO: update tests to expect throw
    function transfer(address _to, uint256 _value) public onlyPayloadSize(2) returns (bool success) {
        require(_to != address(0));
        require(balances[msg.sender] >= _value && _value > 0);
        balances[msg.sender] = safeSub(balances[msg.sender], _value);
        balances[_to] = safeAdd(balances[_to], _value);
        emit Transfer(msg.sender, _to, _value);

        return true;
    }

    // TODO: update tests to expect throw
    function transferFrom(address _from, address _to, uint256 _value) public onlyPayloadSize(3) returns (bool success) {
        require(_to != address(0));
        require(balances[_from] >= _value && allowed[_from][msg.sender] >= _value && _value > 0);
        balances[_from] = safeSub(balances[_from], _value);
        balances[_to] = safeAdd(balances[_to], _value);
        allowed[_from][msg.sender] = safeSub(allowed[_from][msg.sender], _value);
        emit Transfer(_from, _to, _value);

        return true;
    }

    function balanceOf(address _owner) public view returns (uint256 balance) {
        return balances[_owner];
    }

    // To change the approve amount you first have to reduce the addresses'
    //  allowance to zero by calling 'approve(_spender, 0)' if it is not
    //  already 0 to mitigate the race condition described here:
    //  https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
    function approve(address _spender, uint256 _value) public onlyPayloadSize(2) returns (bool success) {
        require((_value == 0) || (allowed[msg.sender][_spender] == 0));
        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);

        return true;
    }

    function changeApproval(address _spender, uint256 _oldValue, uint256 _newValue) public onlyPayloadSize(3) returns (bool success) {
        require(allowed[msg.sender][_spender] == _oldValue);
        allowed[msg.sender][_spender] = _newValue;
        emit Approval(msg.sender, _spender, _newValue);

        return true;
    }

    function allowance(address _owner, address _spender) public view returns (uint256 remaining) {
        return allowed[_owner][_spender];
    }

    mapping (address => uint256) balances;
    mapping (address => mapping (address => uint256)) allowed;

}

contract Lucre is StandardToken {

    // FIELDS

    string public name = "LUCRE";
    string public symbol = "LCR";
    uint256 public decimals = 18;
    string public version = "1.0";

    uint256 public tokenCap = 12500000 * 10**18;  // 10/80 							  

    // crowdsale parameters
    uint256 public startTime;
    uint256 public endTime;

    // root control
    address public fundWallet;
    // control of liquidity and limited control of updatePrice
    address public controlWallet;
    // company reserve, advisor fee & marketing
    address public companyWallet;

    // fundWallet controlled state variables
    // halted: halt buying due to emergency, tradeable: signal that assets have been acquired
    bool public halted = false;
    bool public tradeable = false;

    // -- totalSupply defined in StandardToken
    // -- mapping to token balances done in StandardToken


    uint256 public rate;
    uint256 public minAmount = 0.10 ether;

    // maps addresses
    mapping (address => bool) public whitelist;


    // EVENTS

    event Buy(address indexed participant, address indexed beneficiary, uint256 ethValue, uint256 amountTokens);
    event AllocatePresale(address indexed participant, uint256 amountTokens);
    event Whitelist(address indexed participant);
    event RateUpdate(uint256 rate);


    // MODIFIERS

    modifier isTradeable { // exempt companyWallet and fundWallet to allow company allocations
        require(tradeable || msg.sender == fundWallet || msg.sender == companyWallet);
        _;
    }

    modifier onlyWhitelist {
        require(whitelist[msg.sender]);
        _;
    }

    modifier onlyFundWallet {
        require(msg.sender == fundWallet);
        _;
    }

    modifier onlyManagingWallets {
        require(msg.sender == controlWallet || msg.sender == fundWallet || msg.sender == companyWallet);
        _;
    }

    modifier only_if_controlWallet {
        if (msg.sender == controlWallet) _;
    }


    // CONSTRUCTOR

    constructor (address controlWalletInput, address companyWalletInput, uint preSaleDays, uint mainSaleDays, uint256 rateInput) public {
        require(controlWalletInput != address(0));
        require(rateInput > 0);
        startTime = now + preSaleDays * 1 days; // 30 days of presales (default)
        fundWallet = msg.sender;
        controlWallet = controlWalletInput;
        companyWallet = companyWalletInput;
        whitelist[fundWallet] = true;
        whitelist[controlWallet] = true;
        whitelist[companyWallet] = true;
        endTime = now + (preSaleDays + mainSaleDays) * 1 days; // mainSaleDays = 28 days (default)
		rate = rateInput;

    }

    // METHODS

    // allows controlWallet to update the price within a time constraint, allows fundWallet complete control
    function updateRate(uint256 newRate) external onlyManagingWallets {
        require(newRate > 0);
        // either controlWallet command is compliant or transaction came from fundWallet
        rate = newRate;
        emit RateUpdate(rate);
    }


    function allocateTokens(address participant, uint256 amountTokens) private {
        // 20% of total allocated for PR, Marketing, Team, Advisers
        uint256 companyAllocation = safeMul(amountTokens, 25000000000000000) / 100000000000000000; //20/80
        // check that token cap is not exceeded
        uint256 newTokens = safeAdd(amountTokens, companyAllocation);
        require(safeAdd(totalSupply, newTokens) <= tokenCap);
        // increase token supply, assign tokens to participant
        totalSupply = safeAdd(totalSupply, newTokens);
        balances[participant] = safeAdd(balances[participant], amountTokens);
        balances[companyWallet] = safeAdd(balances[companyWallet], companyAllocation);
    }

    function allocatePresaleTokens(address participant, uint amountTokens) external onlyFundWallet {
        require(now < endTime);
        require(participant != address(0));
        whitelist[participant] = true; // automatically whitelist accepted presale
        allocateTokens(participant, amountTokens);
        emit Whitelist(participant);
        emit AllocatePresale(participant, amountTokens);
    }

    function verifyParticipant(address participant) external onlyManagingWallets {
        whitelist[participant] = true;
        emit Whitelist(participant);
    }

    function buy() external payable {
        buyTo(msg.sender);
    }

    function buyTo(address participant) public payable onlyWhitelist {
        require(!halted);
        require(participant != address(0));
        require(msg.value >= minAmount);
        require(now >= startTime && now < endTime);
		uint256 money = safeMul(msg.value, rate);
		uint256 bonusMoney = safeMul(money, getBonus()) / 100;
		uint256 tokensToBuy = safeAdd(money, bonusMoney);  
        allocateTokens(participant, tokensToBuy);
        // send ether to fundWallet
        fundWallet.transfer(msg.value);
        emit Buy(msg.sender, participant, msg.value, tokensToBuy);
    }


    function getBonus() internal view returns (uint256) {
        uint256 icoDuration = safeSub(now, startTime);
        uint256 discount;
        if (icoDuration < 7 days) { 
            discount = 0;
        } else if (icoDuration < 14 days) { 
            discount = 10; // 10% bonus
        } else if (icoDuration < 21 days) { 
            discount = 15; // 15% bonus
        } else {
            discount = 20; // 20% bonus
        } 
		return discount;
    }


    function changeFundWallet(address newFundWallet) external onlyFundWallet {
        require(newFundWallet != address(0));
        fundWallet = newFundWallet;
    }

    function changeControlWallet(address newControlWallet) external onlyFundWallet {
        require(newControlWallet != address(0));
        controlWallet = newControlWallet;
    }

    function updateFundingStartTime(uint256 newStartTime) external onlyFundWallet {
        require(now < startTime);
        require(now < newStartTime);
        startTime = newStartTime;
    }

    function updateFundingEndTime(uint256 newEndTime) external onlyFundWallet {
        require(now < endTime);
        require(now < newEndTime);
        endTime = newEndTime;
    }

    function halt() external onlyFundWallet {
        halted = true;
    }
    function unhalt() external onlyFundWallet {
        halted = false;
    }

    function enableTrading() external onlyFundWallet {
        require(now > endTime);
        tradeable = true;
    }

    // fallback function
    function() external payable {
        buyTo(msg.sender);
    }

    function claimTokens(address _token) external onlyFundWallet {
        require(_token != address(0));
        Token token = Token(_token);
        uint256 balance = token.balanceOf(this);
        token.transfer(fundWallet, balance);
    }

    // prevent transfers until trading allowed
    function transfer(address _to, uint256 _value) public isTradeable returns (bool success) {
        return super.transfer(_to, _value);
    }
    function transferFrom(address _from, address _to, uint256 _value) public isTradeable returns (bool success) {
        return super.transferFrom(_from, _to, _value);
    }

}