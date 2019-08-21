/*************************************************************************
 * This contract has been merged with solidify
 * https://github.com/tiesnetwork/solidify
 *************************************************************************/
 
 pragma solidity ^0.4.10;

/*************************************************************************
 * import "../common/Manageable.sol" : start
 *************************************************************************/

/*************************************************************************
 * import "../common/Owned.sol" : start
 *************************************************************************/


contract Owned {
    address public owner;        

    function Owned() {
        owner = msg.sender;
    }

    // allows execution by the owner only
    modifier ownerOnly {
        assert(msg.sender == owner);
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

    function Manageable() Owned() {
        managers[owner] = true;
    }

    /**@dev Allows execution by managers only */
    modifier managerOnly {
        assert(managers[msg.sender]);
        _;
    }

    function transferOwnership(address _newOwner) public ownerOnly {
        super.transferOwnership(_newOwner);

        managers[_newOwner] = true;
        managers[msg.sender] = false;
    }

    function setManager(address manager, bool state) ownerOnly {
        managers[manager] = state;
        ManagerSet(manager, state);
    }
}/*************************************************************************
 * import "../common/Manageable.sol" : end
 *************************************************************************/
/*************************************************************************
 * import "./ValueToken.sol" : start
 *************************************************************************/

/*************************************************************************
 * import "./ERC20StandardToken.sol" : start
 *************************************************************************/

/*************************************************************************
 * import "./IERC20Token.sol" : start
 *************************************************************************/

/**@dev ERC20 compliant token interface. 
https://theethereum.wiki/w/index.php/ERC20_Token_Standard 
https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20-token-standard.md */
contract IERC20Token {

    // these functions aren't abstract since the compiler emits automatically generated getter functions as external    
    function name() public constant returns (string _name) { _name; }
    function symbol() public constant returns (string _symbol) { _symbol; }
    function decimals() public constant returns (uint8 _decimals) { _decimals; }
    
    function totalSupply() constant returns (uint total) {total;}
    function balanceOf(address _owner) constant returns (uint balance) {_owner; balance;}    
    function allowance(address _owner, address _spender) constant returns (uint remaining) {_owner; _spender; remaining;}

    function transfer(address _to, uint _value) returns (bool success);
    function transferFrom(address _from, address _to, uint _value) returns (bool success);
    function approve(address _spender, uint _value) returns (bool success);
    

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
    function safeAdd(uint256 a, uint256 b) internal returns (uint256) {        
        uint256 c = a + b;
        assert(c >= a);

        return c;
    }

    /**dev Returns the difference of a and b. Throws an exception if a is less than b*/
    function safeSub(uint256 a, uint256 b) internal returns (uint256) {
        assert(a >= b);
        return a - b;
    }

    /**dev Returns the product of a and b. Throws an exception if it exceeds uint256 limits*/
    function safeMult(uint256 x, uint256 y) internal returns(uint256) {
        uint256 z = x * y;
        assert((x == 0) || (z / x == y));
        return z;
    }

    function safeDiv(uint256 x, uint256 y) internal returns (uint256) {
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

    function ERC20StandardToken() {
     
    }    

    //
    //IERC20Token implementation
    // 

    function totalSupply() constant returns (uint total) {
        total = tokensIssued;
    }
 
    function balanceOf(address _owner) constant returns (uint balance) {
        balance = balances[_owner];
    }

    function transfer(address _to, uint256 _value) returns (bool) {
        require(_to != address(0));

        // safeSub inside doTransfer will throw if there is not enough balance.
        doTransfer(msg.sender, _to, _value);        
        Transfer(msg.sender, _to, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) returns (bool) {
        require(_to != address(0));
        
        // Check for allowance is not needed because sub(_allowance, _value) will throw if this condition is not met
        allowed[_from][msg.sender] = safeSub(allowed[_from][msg.sender], _value);        
        // safeSub inside doTransfer will throw if there is not enough balance.
        doTransfer(_from, _to, _value);        
        Transfer(_from, _to, _value);
        return true;
    }

    function approve(address _spender, uint256 _value) returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }

    function allowance(address _owner, address _spender) constant returns (uint256 remaining) {
        remaining = allowed[_owner][_spender];
    }    

    //
    // Additional functions
    //
    /**@dev Gets real token amount in the smallest token units */
    function getRealTokenAmount(uint256 tokens) constant returns (uint256) {
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
/*************************************************************************
 * import "../token/ValueTokenAgent.sol" : start
 *************************************************************************/




/**@dev Watches transfer operation of tokens to validate value-distribution state */
contract ValueTokenAgent {

    /**@dev Token whose transfers that contract watches */
    ValueToken public valueToken;

    /**@dev Allows only token to execute method */
    modifier valueTokenOnly {require(msg.sender == address(valueToken)); _;}

    function ValueTokenAgent(ValueToken token) {
        valueToken = token;
    }

    /**@dev Called just before the token balance update*/   
    function tokenIsBeingTransferred(address from, address to, uint256 amount);

    /**@dev Called when non-transfer token state change occurs: burn, issue, change of valuable tokens.
    holder - address of token holder that committed the change
    amount - amount of new or deleted tokens  */
    function tokenChanged(address holder, uint256 amount);
}/*************************************************************************
 * import "../token/ValueTokenAgent.sol" : end
 *************************************************************************/


/**@dev Can be relied on to distribute values according to its balances 
 Can set some reserve addreses whose tokens don't take part in dividend distribution */
contract ValueToken is Manageable, ERC20StandardToken {
    
    /**@dev Watches transfer operation of this token */
    ValueTokenAgent valueAgent;

    /**@dev Holders of reserved tokens */
    mapping (address => bool) public reserved;

    /**@dev Reserved token amount */
    uint256 public reservedAmount;

    function ValueToken() {}

    /**@dev Sets new value agent */
    function setValueAgent(ValueTokenAgent newAgent) managerOnly {
        valueAgent = newAgent;
    }

    function doTransfer(address _from, address _to, uint256 _value) internal {

        if (address(valueAgent) != 0x0) {
            //first execute agent method
            valueAgent.tokenIsBeingTransferred(_from, _to, _value);
        }

        //first check if addresses are reserved and adjust reserved amount accordingly
        if (reserved[_from]) {
            reservedAmount = safeSub(reservedAmount, _value);
            //reservedAmount -= _value;
        } 
        if (reserved[_to]) {
            reservedAmount = safeAdd(reservedAmount, _value);
            //reservedAmount += _value;
        }

        //then do actual transfer
        super.doTransfer(_from, _to, _value);
    }

    /**@dev Returns a token amount that is accounted in the process of dividend calculation */
    function getValuableTokenAmount() constant returns (uint256) {
        return totalSupply() - reservedAmount;
    }

    /**@dev Sets specific address to be reserved */
    function setReserved(address holder, bool state) managerOnly {        

        uint256 holderBalance = balanceOf(holder);
        if (address(valueAgent) != 0x0) {            
            valueAgent.tokenChanged(holder, holderBalance);
        }

        //change reserved token amount according to holder's state
        if (state) {
            //reservedAmount += holderBalance;
            reservedAmount = safeAdd(reservedAmount, holderBalance);
        } else {
            //reservedAmount -= holderBalance;
            reservedAmount = safeSub(reservedAmount, holderBalance);
        }

        reserved[holder] = state;
    }
}/*************************************************************************
 * import "./ValueToken.sol" : end
 *************************************************************************/
/*************************************************************************
 * import "./ReturnableToken.sol" : start
 *************************************************************************/



/*************************************************************************
 * import "./ReturnTokenAgent.sol" : start
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
    function returnToken(address from, uint256 amountReturned);

    /**@dev Sets token that can call returnToken method */
    function setReturnableToken(ReturnableToken token) managerOnly {
        returnableTokens[address(token)] = true;
    }

    /**@dev Removes token that can call returnToken method */
    function removeReturnableToken(ReturnableToken token) managerOnly {
        returnableTokens[address(token)] = false;
    }
}/*************************************************************************
 * import "./ReturnTokenAgent.sol" : end
 *************************************************************************/

///Token that when sent to specified contract (returnAgent) invokes additional actions
contract ReturnableToken is Manageable, ERC20StandardToken {

    /**@dev List of return agents */
    mapping (address => bool) public returnAgents;

    function ReturnableToken() {}    
    
    /**@dev Sets new return agent */
    function setReturnAgent(ReturnTokenAgent agent) managerOnly {
        returnAgents[address(agent)] = true;
    }

    /**@dev Removes return agent from list */
    function removeReturnAgent(ReturnTokenAgent agent) managerOnly {
        returnAgents[address(agent)] = false;
    }

    function doTransfer(address _from, address _to, uint256 _value) internal {
        super.doTransfer(_from, _to, _value);
        if (returnAgents[_to]) {
            ReturnTokenAgent(_to).returnToken(_from, _value);                
        }
    }
}/*************************************************************************
 * import "./ReturnableToken.sol" : end
 *************************************************************************/
/*************************************************************************
 * import "./IBurnableToken.sol" : start
 *************************************************************************/

/**@dev A token that can be burnt */
contract IBurnableToken {
    function burn(uint256 _value);
}/*************************************************************************
 * import "./IBurnableToken.sol" : end
 *************************************************************************/

/**@dev bcshop.io crowdsale token */
contract BCSToken is ValueToken, ReturnableToken, IBurnableToken {

    /**@dev Specifies allowed address that always can transfer tokens in case of global transfer lock */
    mapping (address => bool) public transferAllowed;
    /**@dev Specifies timestamp when specific token holder can transfer funds */    
    mapping (address => uint256) public transferLockUntil; 
    /**@dev True if transfer is locked for all holders, false otherwise */
    bool public transferLocked;

    event Burn(address sender, uint256 value);

    /**@dev Creates a token with given initial supply  */
    function BCSToken(uint256 _initialSupply, uint8 _decimals) {
        name = "BCShop.io Token";
        symbol = "BCS";
        decimals = _decimals;        

        tokensIssued = _initialSupply * (uint256(10) ** decimals);
        //store all tokens at the owner's address;
        balances[msg.sender] = tokensIssued;

        transferLocked = true;
        transferAllowed[msg.sender] = true;        
    }

    /**@dev ERC20StandatdToken override */
    function doTransfer(address _from, address _to, uint256 _value) internal {
        require(canTransfer(_from));
        super.doTransfer(_from, _to, _value);
    }    

    /**@dev Returns true if given address can transfer tokens */
    function canTransfer(address holder) constant returns (bool) {
        if(transferLocked) {
            return transferAllowed[holder];
        } else {
            return now > transferLockUntil[holder];
        }
        //return !transferLocked && now > transferLockUntil[holder];
    }    

    /**@dev Lock transfer for a given holder for a given amount of days */
    function lockTransferFor(address holder, uint256 daysFromNow) managerOnly {
        transferLockUntil[holder] = daysFromNow * 1 days + now;
    }

    /**@dev Sets transfer allowance for specific holder */
    function allowTransferFor(address holder, bool state) managerOnly {
        transferAllowed[holder] = state;
    }

    /**@dev Locks or allows transfer for all holders, for emergency reasons*/
    function setLockedState(bool state) managerOnly {
        transferLocked = state;
    }
    
    function burn(uint256 _value) managerOnly {        
        require (balances[msg.sender] >= _value);            // Check if the sender has enough

        if (address(valueAgent) != 0x0) {            
            valueAgent.tokenChanged(msg.sender, _value);
        }

        balances[msg.sender] -= _value;                      // Subtract from the sender
        tokensIssued -= _value;                              // Updates totalSupply        

        Burn(msg.sender, _value);        
    }
}