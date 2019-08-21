/*************************************************************************
 * This contract has been merged with solidify
 * https://github.com/tiesnetwork/solidify
 *************************************************************************/
 
 pragma solidity ^0.4.18;

/*************************************************************************
 * import "./BCSCrowdsale.sol" : start
 *************************************************************************/

/*************************************************************************
 * import "../token/ITokenPool.sol" : start
 *************************************************************************/

/*************************************************************************
 * import "./ERC20StandardToken.sol" : start
 *************************************************************************/

/*************************************************************************
 * import "./IERC20Token.sol" : start
 *************************************************************************/

contract IERC20Token {

    // these functions aren't abstract since the compiler emits automatically generated getter functions as external    
    function name() public constant returns (string _name) { _name; }
    function symbol() public constant returns (string _symbol) { _symbol; }
    function decimals() public constant returns (uint8 _decimals) { _decimals; }
    
    function totalSupply() public constant returns (uint total) {total;}
    function balanceOf(address _owner) public constant returns (uint balance) {_owner; balance;}    
    function allowance(address _owner, address _spender) public constant returns (uint remaining) {_owner; _spender; remaining;}

    function transfer(address _to, uint _value) public returns (bool success);
    function transferFrom(address _from, address _to, uint _value) public returns (bool success);
    function approve(address _spender, uint _value) public returns (bool success);
    

    event Transfer(address indexed _from, address indexed _to, uint _value);
    event Approval(address indexed _owner, address indexed _spender, uint _value);
}
/*************************************************************************
 * import "./IERC20Token.sol" : end
 *************************************************************************/
/*************************************************************************
 * import "../common/SafeMath.sol" : start
 *************************************************************************/

/**dev Utility methods for overflow-proof arithmetic operations 
*/
contract SafeMath {

    /**dev Returns the sum of a and b. Throws an exception if it exceeds uint256 limits*/
    function safeAdd(uint256 a, uint256 b) internal pure returns (uint256) {        
        assert(a+b >= a);
        return a+b;
    }

    /**dev Returns the difference of a and b. Throws an exception if a is less than b*/
    function safeSub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(a >= b);
        return a - b;
    }

    /**dev Returns the product of a and b. Throws an exception if it exceeds uint256 limits*/
    function safeMult(uint256 x, uint256 y) internal pure returns(uint256) {
        uint256 z = x * y;
        assert((x == 0) || (z / x == y));
        return z;
    }

    function safeDiv(uint256 x, uint256 y) internal pure returns (uint256) {
        assert(y != 0);
        return x / y;
    }
}/*************************************************************************
 * import "../common/SafeMath.sol" : end
 *************************************************************************/

/**@dev Standard ERC20 compliant token implementation */
contract ERC20StandardToken is IERC20Token, SafeMath {
    string public name;
    string public symbol;
    uint8 public decimals;

    //tokens already issued
    uint256 tokensIssued;
    //balances for each account
    mapping (address => uint256) balances;
    //one account approves the transfer of an amount to another account
    mapping (address => mapping (address => uint256)) allowed;

    function ERC20StandardToken() public {
     
    }    

    //
    //IERC20Token implementation
    // 

    function totalSupply() public constant returns (uint total) {
        total = tokensIssued;
    }
 
    function balanceOf(address _owner) public constant returns (uint balance) {
        balance = balances[_owner];
    }

    function transfer(address _to, uint256 _value) public returns (bool) {
        require(_to != address(0));

        // safeSub inside doTransfer will throw if there is not enough balance.
        doTransfer(msg.sender, _to, _value);        
        Transfer(msg.sender, _to, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
        require(_to != address(0));
        
        // Check for allowance is not needed because sub(_allowance, _value) will throw if this condition is not met
        allowed[_from][msg.sender] = safeSub(allowed[_from][msg.sender], _value);        
        // safeSub inside doTransfer will throw if there is not enough balance.
        doTransfer(_from, _to, _value);        
        Transfer(_from, _to, _value);
        return true;
    }

    function approve(address _spender, uint256 _value) public returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }

    function allowance(address _owner, address _spender) public constant returns (uint256 remaining) {
        remaining = allowed[_owner][_spender];
    }    

    //
    // Additional functions
    //
    /**@dev Gets real token amount in the smallest token units */
    function getRealTokenAmount(uint256 tokens) public constant returns (uint256) {
        return tokens * (uint256(10) ** decimals);
    }

    //
    // Internal functions
    //    
    
    function doTransfer(address _from, address _to, uint256 _value) internal {
        balances[_from] = safeSub(balances[_from], _value);
        balances[_to] = safeAdd(balances[_to], _value);
    }
}/*************************************************************************
 * import "./ERC20StandardToken.sol" : end
 *************************************************************************/

/**@dev Token pool that manages its tokens by designating trustees */
contract ITokenPool {    

    /**@dev Token to be managed */
    ERC20StandardToken public token;

    /**@dev Changes trustee state */
    function setTrustee(address trustee, bool state) public;

    // these functions aren't abstract since the compiler emits automatically generated getter functions as external
    /**@dev Returns remaining token amount */
    function getTokenAmount() public constant returns (uint256 tokens) {tokens;}
}/*************************************************************************
 * import "../token/ITokenPool.sol" : end
 *************************************************************************/
/*************************************************************************
 * import "../token/ReturnTokenAgent.sol" : start
 *************************************************************************/

/*************************************************************************
 * import "../common/Manageable.sol" : start
 *************************************************************************/

/*************************************************************************
 * import "../common/Owned.sol" : start
 *************************************************************************/

/*************************************************************************
 * import "./IOwned.sol" : start
 *************************************************************************/

/**@dev Simple interface to Owned base class */
contract IOwned {
    function owner() public constant returns (address) {}
    function transferOwnership(address _newOwner) public;
}/*************************************************************************
 * import "./IOwned.sol" : end
 *************************************************************************/

contract Owned is IOwned {
    address public owner;        

    function Owned() public {
        owner = msg.sender;
    }

    // allows execution by the owner only
    modifier ownerOnly {
        require(msg.sender == owner);
        _;
    }

    /**@dev allows transferring the contract ownership. */
    function transferOwnership(address _newOwner) public ownerOnly {
        require(_newOwner != owner);
        owner = _newOwner;
    }
}
/*************************************************************************
 * import "../common/Owned.sol" : end
 *************************************************************************/

///A token that have an owner and a list of managers that can perform some operations
///Owner is always a manager too
contract Manageable is Owned {

    event ManagerSet(address manager, bool state);

    mapping (address => bool) public managers;

    function Manageable() public Owned() {
        managers[owner] = true;
    }

    /**@dev Allows execution by managers only */
    modifier managerOnly {
        require(managers[msg.sender]);
        _;
    }

    function transferOwnership(address _newOwner) public ownerOnly {
        super.transferOwnership(_newOwner);

        managers[_newOwner] = true;
        managers[msg.sender] = false;
    }

    function setManager(address manager, bool state) public ownerOnly {
        managers[manager] = state;
        ManagerSet(manager, state);
    }
}/*************************************************************************
 * import "../common/Manageable.sol" : end
 *************************************************************************/
/*************************************************************************
 * import "../token/ReturnableToken.sol" : start
 *************************************************************************/





///Token that when sent to specified contract (returnAgent) invokes additional actions
contract ReturnableToken is Manageable, ERC20StandardToken {

    /**@dev List of return agents */
    mapping (address => bool) public returnAgents;

    function ReturnableToken() public {}    
    
    /**@dev Sets new return agent */
    function setReturnAgent(ReturnTokenAgent agent) public managerOnly {
        returnAgents[address(agent)] = true;
    }

    /**@dev Removes return agent from list */
    function removeReturnAgent(ReturnTokenAgent agent) public managerOnly {
        returnAgents[address(agent)] = false;
    }

    function doTransfer(address _from, address _to, uint256 _value) internal {
        super.doTransfer(_from, _to, _value);
        if (returnAgents[_to]) {
            ReturnTokenAgent(_to).returnToken(_from, _value);                
        }
    }
}/*************************************************************************
 * import "../token/ReturnableToken.sol" : end
 *************************************************************************/

///Returnable tokens receiver
contract ReturnTokenAgent is Manageable {
    //ReturnableToken public returnableToken;

    /**@dev List of returnable tokens in format token->flag  */
    mapping (address => bool) public returnableTokens;

    /**@dev Allows only token to execute method */
    //modifier returnableTokenOnly {require(msg.sender == address(returnableToken)); _;}
    modifier returnableTokenOnly {require(returnableTokens[msg.sender]); _;}

    /**@dev Executes when tokens are transferred to this */
    function returnToken(address from, uint256 amountReturned)  public;

    /**@dev Sets token that can call returnToken method */
    function setReturnableToken(ReturnableToken token) public managerOnly {
        returnableTokens[address(token)] = true;
    }

    /**@dev Removes token that can call returnToken method */
    function removeReturnableToken(ReturnableToken token) public managerOnly {
        returnableTokens[address(token)] = false;
    }
}/*************************************************************************
 * import "../token/ReturnTokenAgent.sol" : end
 *************************************************************************/


/*************************************************************************
 * import "./IInvestRestrictions.sol" : start
 *************************************************************************/



/** @dev Restrictions on investment */
contract IInvestRestrictions is Manageable {
    /**@dev Returns true if investmet is allowed */
    function canInvest(address investor, uint amount, uint tokensLeft) constant returns (bool result) {
        investor; amount; result; tokensLeft;
    }

    /**@dev Called when investment was made */
    function investHappened(address investor, uint amount) managerOnly {}    
}/*************************************************************************
 * import "./IInvestRestrictions.sol" : end
 *************************************************************************/
/*************************************************************************
 * import "./ICrowdsaleFormula.sol" : start
 *************************************************************************/

/**@dev Abstraction of crowdsale token calculation function */
contract ICrowdsaleFormula {

    /**@dev Returns amount of tokens that can be bought with given weiAmount */
    function howManyTokensForEther(uint256 weiAmount) constant returns(uint256 tokens, uint256 excess) {
        weiAmount; tokens; excess;
    }

    /**@dev Returns how many tokens left for sale */
    function tokensLeft() constant returns(uint256 _left) { _left;}    
}/*************************************************************************
 * import "./ICrowdsaleFormula.sol" : end
 *************************************************************************/

/*************************************************************************
 * import "../token/TokenHolder.sol" : start
 *************************************************************************/



/*************************************************************************
 * import "./ITokenHolder.sol" : start
 *************************************************************************/



/*
    Token Holder interface
*/
contract ITokenHolder {
    function withdrawTokens(IERC20Token _token, address _to, uint256 _amount) public;
}
/*************************************************************************
 * import "./ITokenHolder.sol" : end
 *************************************************************************/

/**@dev A convenient way to manage token's of a contract */
contract TokenHolder is ITokenHolder, Manageable {
    
    function TokenHolder() {
    }

    /** @dev Withdraws tokens held by the contract and sends them to a given address */
    function withdrawTokens(IERC20Token _token, address _to, uint256 _amount)
        public
        managerOnly
    {
        assert(_token.transfer(_to, _amount));
    }
}
/*************************************************************************
 * import "../token/TokenHolder.sol" : end
 *************************************************************************/

/**@dev Crowdsale base contract, used for PRE-TGE and TGE stages
* Token holder should also be the owner of this contract */
contract BCSCrowdsale is ReturnTokenAgent, TokenHolder, ICrowdsaleFormula, SafeMath {

    enum State {Unknown, BeforeStart, Active, FinishedSuccess, FinishedFailure}
    
    ITokenPool public tokenPool;
    IInvestRestrictions public restrictions; //restrictions on investment
    address public beneficiary; //address of contract to collect ether
    uint256 public startTime; //unit timestamp of start time
    uint256 public endTime; //unix timestamp of end date
    uint256 public minimumGoalInWei; //TODO or in tokens
    uint256 public tokensForOneEther; //how many tokens can you buy for 1 ether   
    uint256 realAmountForOneEther; //how many tokens can you buy for 1 ether * 10**decimals   
    uint256 bonusPct;   //additional percent of tokens    
    bool public withdrew; //true if beneficiary already withdrew

    uint256 public weiCollected;
    uint256 public tokensSold;
    uint256 public totalInvestments;

    bool public failure; //true if some error occurred during crowdsale

    mapping (address => uint256) public investedFrom; //how many wei specific address invested
    mapping (address => uint256) public returnedTo; //how many wei returned to specific address if sale fails
    mapping (address => uint256) public tokensSoldTo; //how many tokens sold to specific addreess
    mapping (address => uint256) public overpays;     //overpays for send value excesses

    // A new investment was made
    event Invested(address investor, uint weiAmount, uint tokenAmount);
    // Refund was processed for a contributor
    event Refund(address investor, uint weiAmount);
    // Overpay refund was processed for a contributor
    event OverpayRefund(address investor, uint weiAmount);

    /**@dev Crowdsale constructor, can specify startTime as 0 to start crowdsale immediately 
    _tokensForOneEther - doesn"t depend on token decimals   */ 
    function BCSCrowdsale(        
        ITokenPool _tokenPool,
        IInvestRestrictions _restrictions,
        address _beneficiary, 
        uint256 _startTime, 
        uint256 _durationInHours, 
        uint256 _goalInWei,
        uint256 _tokensForOneEther,
        uint256 _bonusPct) 
    {
        require(_beneficiary != 0x0);
        require(address(_tokenPool) != 0x0);
        require(_tokensForOneEther > 0); 
        
        tokenPool = _tokenPool;
        beneficiary = _beneficiary;
        restrictions = _restrictions;
        
        if (_startTime == 0) {
            startTime = now;
        } else {
            startTime = _startTime;
        }

        endTime = (_durationInHours * 1 hours) + startTime;
        
        tokensForOneEther = _tokensForOneEther;
        minimumGoalInWei = _goalInWei;
        bonusPct = _bonusPct;

        weiCollected = 0;
        tokensSold = 0;
        totalInvestments = 0;
        failure = false;
        withdrew = false;        
        realAmountForOneEther = tokenPool.token().getRealTokenAmount(tokensForOneEther);
    }

    function() payable {
        invest();
    }

    function invest() payable {
        require(canInvest(msg.sender, msg.value));
        
        uint256 excess;
        uint256 weiPaid = msg.value;
        uint256 tokensToBuy;
        (tokensToBuy, excess) = howManyTokensForEther(weiPaid);

        require(tokensToBuy <= tokensLeft() && tokensToBuy > 0);

        if (excess > 0) {
            overpays[msg.sender] = safeAdd(overpays[msg.sender], excess);
            weiPaid = safeSub(weiPaid, excess);
        }
        
        investedFrom[msg.sender] = safeAdd(investedFrom[msg.sender], weiPaid);      
        tokensSoldTo[msg.sender] = safeAdd(tokensSoldTo[msg.sender], tokensToBuy);
        
        tokensSold = safeAdd(tokensSold, tokensToBuy);
        weiCollected = safeAdd(weiCollected, weiPaid);

        if(address(restrictions) != 0x0) {
            restrictions.investHappened(msg.sender, msg.value);
        }
        
        require(tokenPool.token().transferFrom(tokenPool, msg.sender, tokensToBuy));
        ++totalInvestments;
        Invested(msg.sender, weiPaid, tokensToBuy);
    }

    /**@dev ReturnTokenAgent override. Returns ether if crowdsale is failed 
        and amount of returned tokens is exactly the same as bought */
    function returnToken(address from, uint256 amountReturned) public returnableTokenOnly {
        if (msg.sender == address(tokenPool.token()) && getState() == State.FinishedFailure) {
            //require(getState() == State.FinishedFailure);
            require(tokensSoldTo[from] == amountReturned);

            returnedTo[from] = investedFrom[from];
            investedFrom[from] = 0;
            from.transfer(returnedTo[from]);

            Refund(from, returnedTo[from]);
        }
    }

    /**@dev Returns true if it is possible to invest */
    function canInvest(address investor, uint256 amount) constant returns(bool) {
        return getState() == State.Active &&
                    (address(restrictions) == 0x0 || 
                    restrictions.canInvest(investor, amount, tokensLeft()));
    }

    /**@dev ICrowdsaleFormula override */
    function howManyTokensForEther(uint256 weiAmount) constant returns(uint256 tokens, uint256 excess) {        
        uint256 bpct = getCurrentBonusPct(weiAmount);
        uint256 maxTokens = (tokensLeft() * 100) / (100 + bpct);

        tokens = weiAmount * realAmountForOneEther / 1 ether;
        if (tokens > maxTokens) {
            tokens = maxTokens;
        }

        excess = weiAmount - tokens * 1 ether / realAmountForOneEther;

        tokens = (tokens * 100 + tokens * bpct) / 100;
    }

    /**@dev Returns current bonus percent [0-100] */
    function getCurrentBonusPct(uint256 investment) constant returns (uint256) {
        return bonusPct;
    }
    
    /**@dev Returns how many tokens left for sale */
    function tokensLeft() constant returns(uint256) {        
        return tokenPool.getTokenAmount();
    }

    /**@dev Returns funds that should be sent to beneficiary */
    function amountToBeneficiary() constant returns (uint256) {
        return weiCollected;
    } 

    /**@dev Returns crowdsale current state */
    function getState() constant returns (State) {
        if (failure) {
            return State.FinishedFailure;
        }
        
        if (now < startTime) {
            return State.BeforeStart;
        } else if ((endTime == 0 || now < endTime) && tokensLeft() > 0) {
            return State.Active;
        } else if (weiCollected >= minimumGoalInWei || tokensLeft() <= 0) {
            return State.FinishedSuccess;
        } else {
            return State.FinishedFailure;
        }
    }

    /**@dev Allows investor to withdraw overpay */
    function withdrawOverpay() {
        uint amount = overpays[msg.sender];
        overpays[msg.sender] = 0;        

        if (amount > 0) {
            if (msg.sender.send(amount)) {
                OverpayRefund(msg.sender, amount);
            } else {
                overpays[msg.sender] = amount; //restore funds in case of failed send
            }
        }
    }

    /**@dev Transfers all collected funds to beneficiary*/
    function transferToBeneficiary() {
        require(getState() == State.FinishedSuccess && !withdrew);
        
        withdrew = true;
        uint256 amount = amountToBeneficiary();

        beneficiary.transfer(amount);
        Refund(beneficiary, amount);
    }

    /**@dev Makes crowdsale failed/ok, for emergency reasons */
    function makeFailed(bool state) managerOnly {
        failure = state;
    }

    /**@dev Sets new beneficiary */
    function changeBeneficiary(address newBeneficiary) managerOnly {
        beneficiary = newBeneficiary;
    }
} /*************************************************************************
 * import "./BCSCrowdsale.sol" : end
 *************************************************************************/

/**@dev Addition to token-accepting crowdsale contract. 
    Allows to set bonus decreasing with time. 
    For example, if we ant to set bonus taht decreases from +20% to +5% each week -3%,
    and then stays on +%5, then constructor parameters should be:
    _bonusPct = 20
    _maxDecreasePct = 15
    _decreaseStepPct = 3
    _stepDurationDays = 7

    In addition, it allows to set investment steps with different bonus. 
    For example, if there is following scheme:
    Default bonus +20%
    1-5 ETH : +1% bonus, 
    5-10 ETH : +2% bonus,
    10-20 ETH : +3% bonus,
    20+ ETH : +5% bonus, 
    then constructor parameters should be:
    _bonusPct = 20
    _investSteps = [1,5,10,20]
    _bonusPctSteps = [1,2,3,5]
    */ 
contract BCSAddBonusCrowdsale is BCSCrowdsale {
    
    uint256 public decreaseStepPct;
    uint256 public stepDuration;
    uint256 public maxDecreasePct;
    uint256[] public investSteps;
    uint8[] public bonusPctSteps;
    
    function BCSAddBonusCrowdsale(        
        ITokenPool _tokenPool,
        IInvestRestrictions _restrictions,
        address _beneficiary, 
        uint256 _startTime, 
        uint256 _durationInHours, 
        uint256 _goalInWei,
        uint256 _tokensForOneEther,
        uint256 _bonusPct,
        uint256 _maxDecreasePct,        
        uint256 _decreaseStepPct,
        uint256 _stepDurationDays,
        uint256[] _investSteps,
        uint8[] _bonusPctSteps              
        ) 
        BCSCrowdsale(
            _tokenPool,
            _restrictions,
            _beneficiary, 
            _startTime, 
            _durationInHours, 
            _goalInWei,
            _tokensForOneEther,
            _bonusPct
        )
    {
        require (_bonusPct >= maxDecreasePct);

        investSteps = _investSteps;
        bonusPctSteps = _bonusPctSteps;
        maxDecreasePct = _maxDecreasePct;
        decreaseStepPct = _decreaseStepPct;
        stepDuration = _stepDurationDays * 1 days;
    }

    function getCurrentBonusPct(uint256 investment) public constant returns (uint256) {
        
        uint256 decreasePct = decreaseStepPct * (now - startTime) / stepDuration;
        if (decreasePct > maxDecreasePct) {
            decreasePct = maxDecreasePct;
        }

        uint256 first24hAddition = (now - startTime < 1 days ? 1 : 0);

        for (int256 i = int256(investSteps.length) - 1; i >= 0; --i) {
            if (investment >= investSteps[uint256(i)]) {
                return bonusPct - decreasePct + bonusPctSteps[uint256(i)] + first24hAddition;
            }
        }
                
        return bonusPct - decreasePct + first24hAddition;
    }

}