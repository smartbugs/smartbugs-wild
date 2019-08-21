/*************************************************************************
 * This contract has been merged with solidify
 * https://github.com/tiesnetwork/solidify
 *************************************************************************/
 
 pragma solidity ^0.4.10;

/*************************************************************************
 * import "./TrancheWallet.sol" : start
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

/**@dev Distributes some amount of currency in small portions available to withdraw once in a period */
contract TrancheWallet is Owned {
    address public beneficiary;         //funds are to withdraw to this account
    uint256 public tranchePeriodInDays; //one tranche 'cooldown' time
    uint256 public trancheAmountPct;    //one tranche amount 
        
    uint256 public lockStart;           //when funds were locked
    uint256 public completeUnlockTime;  //when funds are unlocked completely
    uint256 public initialFunds;        //funds to divide into tranches
    uint256 public tranchesSent;        //tranches already sent to beneficiary

    event Withdraw(uint256 amount, uint256 tranches);

    function TrancheWallet(
        address _beneficiary, 
        uint256 _tranchePeriodInDays,
        uint256 _trancheAmountPct        
        ) 
    {
        beneficiary = _beneficiary;
        tranchePeriodInDays = _tranchePeriodInDays;
        trancheAmountPct = _trancheAmountPct;
        tranchesSent = 0;
        completeUnlockTime = 0;
    }

    /**@dev Sets new beneficiary to receive funds */
    function setBeneficiary(address newBeneficiary) public ownerOnly {
        beneficiary = newBeneficiary;
    }

    //Locks all funds on account so that it's possible to withdraw only specific tranche amount.
    //Funds will be unlocked completely in a given amount of days 
    //Can be made only one time
    function lock(uint256 lockPeriodInDays) public ownerOnly {
        require(lockStart == 0);

        initialFunds = currentBalance();//this.balance;
        lockStart = now;
        completeUnlockTime = lockPeriodInDays * 1 days + lockStart;
    }

    /**@dev Sends available tranches to beneficiary account*/
    function sendToBeneficiary() {
        uint256 amountToWithdraw;
        uint256 tranchesToSend;
        (amountToWithdraw, tranchesToSend) = amountAvailableToWithdraw();

        require(amountToWithdraw > 0);

        tranchesSent += tranchesToSend;
        doTransfer(amountToWithdraw);

        Withdraw(amountToWithdraw, tranchesSent);
    }

    /**@dev Calculates available amount to withdraw */
    function amountAvailableToWithdraw() constant returns (uint256 amount, uint256 tranches) {        
        if (currentBalance() > 0) {
            if(now > completeUnlockTime) {
                //withdraw everything
                amount = currentBalance();
                tranches = 0;
            } else {
                //withdraw tranche                
                uint256 periodsSinceLock = (now - lockStart) / (tranchePeriodInDays * 1 days);
                tranches = periodsSinceLock - tranchesSent + 1;                
                amount = tranches * oneTrancheAmount();

                //check if exceeding current limit
                if(amount > currentBalance()) {
                    amount = currentBalance();
                    tranches = amount / oneTrancheAmount();
                }
            }
        } else {
            amount = 0;
            tranches = 0;
        }
    }

    /**@dev Returns the size of one tranche */
    function oneTrancheAmount() constant returns(uint256) {
        return trancheAmountPct * initialFunds / 100; 
    }

    /**@dev Returns current balance to be distributed to portions*/
    function currentBalance() internal constant returns(uint256);

    /**@dev Transfers given amount of currency to the beneficiary */
    function doTransfer(uint256 amount) internal;
}
/*************************************************************************
 * import "./TrancheWallet.sol" : end
 *************************************************************************/
/*************************************************************************
 * import "../token/IERC20Token.sol" : start
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
 * import "../token/IERC20Token.sol" : end
 *************************************************************************/

/**@dev Wallet that contains some amount of tokens and allows to withdraw it in small portions */
contract TokenTrancheWallet is TrancheWallet {

    /**@dev Token to be stored */
    IERC20Token public token;

    function TokenTrancheWallet(
        IERC20Token _token,
        address _beneficiary, 
        uint256 _tranchePeriodInDays,
        uint256 _trancheAmountPct
        ) TrancheWallet(_beneficiary, _tranchePeriodInDays, _trancheAmountPct) 
    {
        token = _token;
    }

    /**@dev Returns current balance to be distributed to portions*/
    function currentBalance() internal constant returns(uint256) {
        return token.balanceOf(this);
    }

    /**@dev Transfers given amount of currency to the beneficiary */
    function doTransfer(uint256 amount) internal {
        require(token.transfer(beneficiary, amount));
    }
}