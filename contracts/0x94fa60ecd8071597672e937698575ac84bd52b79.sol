/*************************************************************************
 * This contract has been merged with solidify
 * https://github.com/tiesnetwork/solidify
 *************************************************************************/
 
 pragma solidity ^0.4.18;

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
/*************************************************************************
 * import "../token/IERC20Token.sol" : start
 *************************************************************************/

/**@dev ERC20 compliant token interface. 
https://theethereum.wiki/w/index.php/ERC20_Token_Standard 
https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20-token-standard.md */
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
 * import "../token/IERC20Token.sol" : end
 *************************************************************************/

/**@dev This contract holds tokens and unlock at specific dates.
unlockDates - array of UNIX timestamps when unlock happens
unlockAmounts - total amount of tokens that are unlocked on that date, the last element should equal to 0
For example, if 
1st tranche unlocks 10 tokens, 
2nd unlocks 15 tokens more
3rd unlocks 30 tokens more
4th unlocks 40 tokens more - all the rest 
then unlockAmounts should be [10, 25, 55, 95]
 */
contract CustomTrancheWallet is Owned {

    IERC20Token public token;
    address public beneficiary;
    uint256 public initialFunds; //initial funds at the moment of lock 
    bool public locked; //true if funds are locked
    uint256[] public unlockDates;
    uint256[] public unlockAmounts;
    uint256 public alreadyWithdrawn; //amount of tokens already withdrawn

    function CustomTrancheWallet(
        IERC20Token _token, 
        address _beneficiary, 
        uint256[] _unlockDates, 
        uint256[] _unlockAmounts
    ) 
    public 
    {
        token = _token;
        beneficiary = _beneficiary;
        unlockDates = _unlockDates;
        unlockAmounts = _unlockAmounts;

        require(paramsValid());
    }

    /**@dev Returns total number of scheduled unlocks */
    function unlocksCount() public constant returns(uint256) {
        return unlockDates.length;
    }

    /**@dev Returns amount of tokens available for withdraw */
    function getAvailableAmount() public constant returns(uint256) {
        if (!locked) {
            return token.balanceOf(this);
        } else {
            return amountToWithdrawOnDate(now) - alreadyWithdrawn;
        }
    }    

    /**@dev Returns how many token can be withdrawn on specific date */
    function amountToWithdrawOnDate(uint256 currentDate) public constant returns (uint256) {
        for (uint256 i = unlockDates.length; i != 0; --i) {
            if (currentDate > unlockDates[i - 1]) {
                return unlockAmounts[i - 1];
            }
        }
        return 0;
    }

    /**@dev Returns true if params are valid */
    function paramsValid() public constant returns (bool) {        
        if (unlockDates.length == 0 || unlockDates.length != unlockAmounts.length) {
            return false;
        }        

        for (uint256 i = 0; i < unlockAmounts.length - 1; ++i) {
            if (unlockAmounts[i] >= unlockAmounts[i + 1]) {
                return false;
            }
            if (unlockDates[i] >= unlockDates[i + 1]) {
                return false;
            }
        }
        return true;
    }

    /**@dev Sends available amount to stored beneficiary */
    function sendToBeneficiary() public {
        uint256 amount = getAvailableAmount();
        alreadyWithdrawn += amount;
        require(token.transfer(beneficiary, amount));
    }

    /**@dev Locks tokens according to stored schedule */
    function lock() public ownerOnly {
        require(!locked);
        require(token.balanceOf(this) == unlockAmounts[unlockAmounts.length - 1]);

        locked = true;
    }

    /**@dev Changes unlock schedule, can be called only by the owner and if funds are not locked*/
    function setParams(        
        uint256[] _unlockDates, 
        uint256[] _unlockAmounts
    ) 
    public 
    ownerOnly 
    {
        require(!locked);        

        unlockDates = _unlockDates;
        unlockAmounts = _unlockAmounts;

        require(paramsValid());
    }    

    /**@dev Sets new beneficiary, can be called only by the owner */
    function setBeneficiary(address _beneficiary) public ownerOnly {
        beneficiary = _beneficiary;
    }
}