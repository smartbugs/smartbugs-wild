pragma solidity >=0.4.4;

contract Sale {
    uint public startTime;
    uint public stopTime;
    uint public target;
    uint public raised;
    uint public collected;
    uint public numContributors;
    mapping(address => uint) public balances;

    function buyTokens(address _a, uint _eth, uint _time) returns (uint); 
    function getTokens(address holder) constant returns (uint); 
    function getRefund(address holder) constant returns (uint); 
    function getSoldTokens() constant returns (uint); 
    function getOwnerEth() constant returns (uint); 
    function tokensPerEth() constant returns (uint);
    function isActive(uint time) constant returns (bool); 
    function isComplete(uint time) constant returns (bool); 
}

contract Constants {
    uint DECIMALS = 8;
}

contract EventDefinitions {
    event logSaleStart(uint startTime, uint stopTime);
    event logPurchase(address indexed purchaser, uint eth);
    event logClaim(address indexed purchaser, uint refund, uint tokens);

    //Token standard events
    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);
} 

contract Testable {
    uint fakeTime;
    bool public testing;
    modifier onlyTesting() {
        if (!testing) throw;
        _;
    }
    function setFakeTime(uint t) onlyTesting {
        fakeTime = t;
    }
    function addMinutes(uint m) onlyTesting {
        fakeTime = fakeTime + (m * 1 minutes);
    }
    function addDays(uint d) onlyTesting {
        fakeTime = fakeTime + (d * 1 days);
    }
    function currTime() constant returns (uint) {
        if (testing) {
            return fakeTime;
        } else {
            return block.timestamp;
        }
    }
    function weiPerEth() constant returns (uint) {
        if (testing) {
            return 200;
        } else {
            return 10**18;
        }
    }
}

contract Owned {
    address public owner;
    
    modifier onlyOwner() {
        if (msg.sender != owner) throw;
        _;
    }

    address newOwner;

    function changeOwner(address _newOwner) onlyOwner {
        newOwner = _newOwner;
    }

    function acceptOwnership() {
        if (msg.sender == newOwner) {
            owner = newOwner;
        }
    }    
}

//from Zeppelin
contract SafeMath {
    function safeMul(uint a, uint b) internal returns (uint) {
        uint c = a * b;
        assert(a == 0 || c / a == b);
        return c;
    }

    function safeSub(uint a, uint b) internal returns (uint) {
        assert(b <= a);
        return a - b;
    }

    function safeAdd(uint a, uint b) internal returns (uint) {
        uint c = a + b;
        assert(c>=a && c>=b);
        return c;
    }

    function assert(bool assertion) internal {
        if (!assertion) throw;
    }
}

contract Token is SafeMath, Owned, Constants {
    uint public totalSupply;

    address ico;
    address controller;

    string public name;
    uint8 public decimals; 
    string public symbol;     

    modifier onlyControllers() {
        if (msg.sender != ico &&
            msg.sender != controller) throw;
        _;
    }

    modifier onlyPayloadSize(uint numwords) {
        assert(msg.data.length == numwords * 32 + 4);
        _;
    } 

    function Token() { 
        owner = msg.sender;
        name = "Monolith TKN";
        decimals = uint8(DECIMALS);
        symbol = "TKN";
    }

    function setICO(address _ico) onlyOwner {
        if (ico != 0) throw;
        ico = _ico;
    }
    function setController(address _controller) onlyOwner {
        if (controller != 0) throw;
        controller = _controller;
    }
    
    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);
    event Mint(address owner, uint amount);

    //only called from contracts so don't need msg.data.length check
    function mint(address addr, uint amount) onlyControllers {
        if (maxSupply > 0 && safeAdd(totalSupply, amount) > maxSupply) throw;
        balanceOf[addr] = safeAdd(balanceOf[addr], amount);
        totalSupply = safeAdd(totalSupply, amount);
        Mint(addr, amount);
    }

    mapping(address => uint) public balanceOf;
    mapping (address => mapping (address => uint)) public allowance;

    function transfer(address _to, uint _value) 
    onlyPayloadSize(2)
    returns (bool success) {
        if (balanceOf[msg.sender] < _value) return false;

        balanceOf[msg.sender] = balanceOf[msg.sender] - _value;
        balanceOf[_to] = safeAdd(balanceOf[_to], _value);
        Transfer(msg.sender, _to, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint _value) 
    onlyPayloadSize(3)
    returns (bool success) {
        if (balanceOf[_from] < _value) return false; 

        var allowed = allowance[_from][msg.sender];
        if (allowed < _value) return false;

        balanceOf[_to] = safeAdd(balanceOf[_to], _value);
        balanceOf[_from] = safeSub(balanceOf[_from], _value);
        allowance[_from][msg.sender] = safeSub(allowed, _value);
        Transfer(_from, _to, _value);
        return true;
    }

    function approve(address _spender, uint _value) 
    onlyPayloadSize(2)
    returns (bool success) {
        //require user to set to zero before resetting to nonzero
        if ((_value != 0) && (allowance[msg.sender][_spender] != 0)) {
            return false;
        }
    
        allowance[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }

    function increaseApproval (address _spender, uint _addedValue) 
    onlyPayloadSize(2)
    returns (bool success) {
        uint oldValue = allowance[msg.sender][_spender];
        allowance[msg.sender][_spender] = safeAdd(oldValue, _addedValue);
        return true;
    }

    function decreaseApproval (address _spender, uint _subtractedValue) 
    onlyPayloadSize(2)
    returns (bool success) {
        uint oldValue = allowance[msg.sender][_spender];
        if (_subtractedValue > oldValue) {
            allowance[msg.sender][_spender] = 0;
        } else {
            allowance[msg.sender][_spender] = safeSub(oldValue, _subtractedValue);
        }
        return true;
    }

    //Holds accumulated dividend tokens other than TKN
    TokenHolder tokenholder;

    //once locked, can no longer upgrade tokenholder
    bool lockedTokenHolder;

    function lockTokenHolder() onlyOwner {
        lockedTokenHolder = true;
    }

    //while unlocked, 
    //this gives owner lots of power over held dividend tokens
    //effectively can deny access to all accumulated tokens
    //thus crashing TKN value
    function setTokenHolder(address _th) onlyOwner {
        if (lockedTokenHolder) throw;
        tokenholder = TokenHolder(_th);
    }

    event Burn(address burner, uint amount);

    function burn(uint _amount) returns (bool result) {
        if (_amount > balanceOf[msg.sender]) return false;
        balanceOf[msg.sender] = safeSub(balanceOf[msg.sender], _amount);
        totalSupply = safeSub(totalSupply, _amount);
        result = tokenholder.burn(msg.sender, _amount);
        if (!result) throw;
        Burn(msg.sender, _amount);
    }

    uint public maxSupply;

    function setMaxSupply(uint _maxSupply) {
        if (msg.sender != controller) throw;
        if (maxSupply > 0) throw;
        maxSupply = _maxSupply;
    }
}

contract TokenHolder {
    function burn(address _burner, uint _amount)
    returns (bool result) { 
        return false;
    }
}


contract ICO is EventDefinitions, Testable, SafeMath, Owned {
    Token public token;
    address public controller;
    address public payee;

    Sale[] public sales;
    
    //salenum => minimum wei
    mapping (uint => uint) saleMinimumPurchases;

    //next sale number user can claim from
    mapping (address => uint) public nextClaim;

    //net contributed ETH by each user (in case of stop/refund)
    mapping (address => uint) refundInStop;

    modifier tokenIsSet() {
        if (address(token) == 0) throw;
        _;
    }

    modifier onlyController() {
        if (msg.sender != address(controller)) throw;
        _;
    }

    function ICO() { 
        owner = msg.sender;
        payee = msg.sender;
        allStopper = msg.sender;
    }

    //payee can only be changed once
    //intent is to lock payee to a contract that holds or distributes funds
    //in deployment, be sure to do this before changing owner!
    //we initialize to owner to keep things simple if there's no payee contract
    function changePayee(address newPayee) 
    onlyOwner notAllStopped {
        payee = newPayee;
    }

    function setToken(address _token) onlyOwner {
        if (address(token) != 0x0) throw;
        token = Token(_token);
    }

    //before adding sales, we can set this to be a test ico
    //this lets us manipulate time and drastically lowers weiPerEth
    function setAsTest() onlyOwner {
        if (sales.length == 0) {
            testing = true;
        }
    }

    function setController(address _controller) 
    onlyOwner notAllStopped {
        if (address(controller) != 0x0) throw;
        controller = _controller; //ICOController(_controller);
    }

    //********************************************************
    //Sales
    //********************************************************

    function addSale(address sale, uint minimumPurchase) 
    onlyController notAllStopped {
        uint salenum = sales.length;
        sales.push(Sale(sale));
        saleMinimumPurchases[salenum] = minimumPurchase;
        logSaleStart(Sale(sale).startTime(), Sale(sale).stopTime());
    }

    function addSale(address sale) onlyController {
        addSale(sale, 0);
    }

    function getCurrSale() constant returns (uint) {
        if (sales.length == 0) throw; //no reason to call before startFirstSale
        return sales.length - 1;
    }

    function currSaleActive() constant returns (bool) {
        return sales[getCurrSale()].isActive(currTime());
    }

    function currSaleComplete() constant returns (bool) {
        return sales[getCurrSale()].isComplete(currTime());
    }

    function numSales() constant returns (uint) {
        return sales.length;
    }

    function numContributors(uint salenum) constant returns (uint) {
        return sales[salenum].numContributors();
    }

    //********************************************************
    //ETH Purchases
    //********************************************************

    event logPurchase(address indexed purchaser, uint value);

    function () payable {
        deposit();
    }

    function deposit() payable notAllStopped {
        doDeposit(msg.sender, msg.value);

        //not in doDeposit because only for Eth:
        uint contrib = refundInStop[msg.sender];
        refundInStop[msg.sender] = contrib + msg.value;

        logPurchase(msg.sender, msg.value);
    }

    //is also called by token contributions
    function doDeposit(address _for, uint _value) private {
        uint currSale = getCurrSale();
        if (!currSaleActive()) throw;
        if (_value < saleMinimumPurchases[currSale]) throw;

        uint tokensToMintNow = sales[currSale].buyTokens(_for, _value, currTime());

        if (tokensToMintNow > 0) {
            token.mint(_for, tokensToMintNow);
        }
    }

    //********************************************************
    //Token Purchases
    //********************************************************

    //Support for purchase via other tokens
    //We don't attempt to deal with those tokens directly
    //We just give admin ability to tell us what deposit to credit
    //We only allow for first sale 
    //because first sale normally has no refunds
    //As written, the refund would be in ETH

    event logPurchaseViaToken(
                        address indexed purchaser, address indexed token, 
                        uint depositedTokens, uint ethValue, 
                        bytes32 _reference);

    event logPurchaseViaFiat(
                        address indexed purchaser, uint ethValue, 
                        bytes32 _reference);

    mapping (bytes32 => bool) public mintRefs;
    mapping (address => uint) public raisedFromToken;
    uint public raisedFromFiat;

    function depositFiat(address _for, uint _ethValue, bytes32 _reference) 
    notAllStopped onlyOwner {
        if (getCurrSale() > 0) throw; //only first sale allows this
        if (mintRefs[_reference]) throw; //already minted for this reference
        mintRefs[_reference] = true;
        raisedFromFiat = safeAdd(raisedFromFiat, _ethValue);

        doDeposit(_for, _ethValue);
        logPurchaseViaFiat(_for, _ethValue, _reference);
    }

    function depositTokens(address _for, address _token, 
                           uint _ethValue, uint _depositedTokens, 
                           bytes32 _reference) 
    notAllStopped onlyOwner {
        if (getCurrSale() > 0) throw; //only first sale allows this
        if (mintRefs[_reference]) throw; //already minted for this reference
        mintRefs[_reference] = true;
        raisedFromToken[_token] = safeAdd(raisedFromToken[_token], _ethValue);

        //tokens do not count toward price changes and limits
        //we have to look up pricing, and do our own mint()
        uint tokensPerEth = sales[0].tokensPerEth();
        uint tkn = safeMul(_ethValue, tokensPerEth) / weiPerEth();
        token.mint(_for, tkn);
        
        logPurchaseViaToken(_for, _token, _depositedTokens, _ethValue, _reference);
    }

    //********************************************************
    //Roundoff Protection
    //********************************************************
    //protect against roundoff in payouts
    //this prevents last person getting refund from not being able to collect
    function safebalance(uint bal) private returns (uint) {
        if (bal > this.balance) {
            return this.balance;
        } else {
            return bal;
        }
    }

    //It'd be nicer if last person got full amount
    //instead of getting shorted by safebalance()
    //topUp() allows admin to deposit excess ether to cover it
    //and later get back any left over 

    uint public topUpAmount;

    function topUp() payable onlyOwner notAllStopped {
        topUpAmount = safeAdd(topUpAmount, msg.value);
    }

    function withdrawTopUp() onlyOwner notAllStopped {
        uint amount = topUpAmount;
        topUpAmount = 0;
        if (!msg.sender.call.value(safebalance(amount))()) throw;
    }

    //********************************************************
    //Claims
    //********************************************************

    //Claim whatever you're owed, 
    //from whatever completed sales you haven't already claimed
    //this covers refunds, and any tokens not minted immediately
    //(i.e. auction tokens, not firstsale tokens)
    function claim() notAllStopped {
        var (tokens, refund, nc) = claimable(msg.sender, true);
        nextClaim[msg.sender] = nc;
        logClaim(msg.sender, refund, tokens);
        if (tokens > 0) {
            token.mint(msg.sender, tokens);
        }
        if (refund > 0) {
            refundInStop[msg.sender] = safeSub(refundInStop[msg.sender], refund);
            if (!msg.sender.send(safebalance(refund))) throw;
        }
    }

    //Allow admin to claim on behalf of user and send to any address.
    //Scenarios:
    //  user lost key
    //  user sent from an exchange
    //  user has expensive fallback function
    //  user is unknown, funds presumed abandoned
    //We only allow this after one year has passed.
    function claimFor(address _from, address _to) 
    onlyOwner notAllStopped {
        var (tokens, refund, nc) = claimable(_from, false);
        nextClaim[_from] = nc;

        logClaim(_from, refund, tokens);

        if (tokens > 0) {
            token.mint(_to, tokens);
        }
        if (refund > 0) {
            refundInStop[_from] = safeSub(refundInStop[_from], refund);
            if (!_to.send(safebalance(refund))) throw;
        }
    }

    function claimable(address _a, bool _includeRecent) 
    constant private tokenIsSet 
    returns (uint tokens, uint refund, uint nc) {
        nc = nextClaim[_a];

        while (nc < sales.length &&
               sales[nc].isComplete(currTime()) &&
               ( _includeRecent || 
                 sales[nc].stopTime() + 1 years < currTime() )) 
        {
            refund = safeAdd(refund, sales[nc].getRefund(_a));
            tokens = safeAdd(tokens, sales[nc].getTokens(_a));
            nc += 1;
        }
    }

    function claimableTokens(address a) constant returns (uint) {
        var (tokens, refund, nc) = claimable(a, true);
        return tokens;
    }

    function claimableRefund(address a) constant returns (uint) {
        var (tokens, refund, nc) = claimable(a, true);
        return refund;
    }

    function claimableTokens() constant returns (uint) {
        return claimableTokens(msg.sender);
    }

    function claimableRefund() constant returns (uint) {
        return claimableRefund(msg.sender);
    }

    //********************************************************
    //Withdraw ETH
    //********************************************************

    mapping (uint => bool) ownerClaimed;

    function claimableOwnerEth(uint salenum) constant returns (uint) {
        uint time = currTime();
        if (!sales[salenum].isComplete(time)) return 0;
        return sales[salenum].getOwnerEth();
    }

    function claimOwnerEth(uint salenum) onlyOwner notAllStopped {
        if (ownerClaimed[salenum]) throw;

        uint ownereth = claimableOwnerEth(salenum);
        if (ownereth > 0) {
            ownerClaimed[salenum] = true;
            if ( !payee.call.value(safebalance(ownereth))() ) throw;
        }
    }

    //********************************************************
    //Sweep tokens sent here
    //********************************************************

    //Support transfer of erc20 tokens out of this contract's address
    //Even if we don't intend for people to send them here, somebody will

    event logTokenTransfer(address token, address to, uint amount);

    function transferTokens(address _token, address _to) onlyOwner {
        Token token = Token(_token);
        uint balance = token.balanceOf(this);
        token.transfer(_to, balance);
        logTokenTransfer(_token, _to, balance);
    }

    //********************************************************
    //Emergency Stop
    //********************************************************

    bool allstopped;
    bool permastopped;

    //allow allStopper to be more secure address than owner
    //in which case it doesn't make sense to let owner change it again
    address allStopper;
    function setAllStopper(address _a) onlyOwner {
        if (allStopper != owner) return;
        allStopper = _a;
    }
    modifier onlyAllStopper() {
        if (msg.sender != allStopper) throw;
        _;
    }

    event logAllStop();
    event logAllStart();

    modifier allStopped() {
        if (!allstopped) throw;
        _;
    }

    modifier notAllStopped() {
        if (allstopped) throw;
        _;
    }

    function allStop() onlyAllStopper {
        allstopped = true;    
        logAllStop();
    }

    function allStart() onlyAllStopper {
        if (!permastopped) {
            allstopped = false;
            logAllStart();
        }
    }

    function emergencyRefund(address _a, uint _amt) 
    allStopped 
    onlyAllStopper {
        //if you start actually calling this refund, the disaster is real.
        //Don't allow restart, so this can't be abused 
        permastopped = true;

        uint amt = _amt;

        uint ethbal = refundInStop[_a];

        //convenient default so owner doesn't have to look up balances
        //this is fine as long as no funds have been stolen
        if (amt == 0) amt = ethbal; 

        //nobody can be refunded more than they contributed
        if (amt > ethbal) amt = ethbal;

        //since everything is halted, safer to call.value
        //so we don't have to worry about expensive fallbacks
        if ( !_a.call.value(safebalance(amt))() ) throw;
    }

    function raised() constant returns (uint) {
        return sales[getCurrSale()].raised();
    }

    function tokensPerEth() constant returns (uint) {
        return sales[getCurrSale()].tokensPerEth();
    }
}