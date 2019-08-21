pragma solidity ^0.4.0;

/**
 * Author: Nick Johnson <arachnid at notdot.net>
 * 
 * WARNING: This contract is new and thus-far only lightly tested. I'm fairly
 * confident it operates as described, but you may want to assure yourself of
 * its correctness - or wait for others to do so for you - before you trust your
 * ether to it. No guarantees, express or implied, are provided - use at your
 * own risk.
 * 
 * @dev Ether vault contract. Stores ether with a 'time lock' on withdrawals,
 *      giving a user the chance to reclaim funds if an account is compromised.
 *      A recovery address has the ability to immediately destroy the wallet and
 *      send its funds to a new contract (such as a new vault, if the wallet)
 *      associated with this one is compromised or lost). A cold wallet or
 *      secure brain wallet should typically be used for this purpose.
 * 
 * Setup:
 *   To set up a vault, first create a cold wallet or secure brain wallet to use
 *   as a recovery key, and get its address. Then, deploy this vault contract
 *   with the address of the recovery key, and a time delay (in seconds) to
 *   impose on withdrawals.
 * 
 * Deposits:
 *   Simply deposit funds into this contract by sending them to them. This
 *   contract only uses the minimum gas stipend, so it's safe to use with
 *   sites that "don't support smart contracts".
 * 
 * Withdrawals:
 *   Call unvault() with the amount you wish to withdraw (in wei - one ether is
 *   1e18 wei). After the time delay you specified when you created the wallet,
 *   you can call withdraw() to receive the funds.
 * 
 * Vacations:
 *   If you anticipate not having access to the recovery key for some period,
 *   you can call `lock()` with a period (in seconds) that the funds should be
 *   unavailable for; this will prohibit any withdrawals completing during that
 *   period. If a withdrawal is outstanding, it will be postponed until the
 *   end of this period, too.
 * 
 * Recovery:
 *   If your hotwallet is every compromised, or you detect an unauthorized
 *   `Unvault()` event, use your recovery key to call the `recover()` function
 *   with the address you want funds sent to. The funds will be immediately
 *   sent to this address (with no delay) and the contract will self destruct.
 * 
 *   For safety, you may wish to prepare a new vault (with a new recovery key)
 *   and send your funds directly to that.
 */
contract Vault {
    /**
     * @dev Owner of the vault.
     */
    address public owner;
    
    /**
     * @dev Recovery address for this vault.
     */
    address public recovery;

    /**
     * @dev Minimum interval between making an unvault call and allowing a
     *      withdrawal.
     */
    uint public withdrawDelay;

    /**
     * @dev Earliest time at which a withdrawal can be made.
     *      Valid iff withdrawAmount > 0.
     */
    uint public withdrawTime;
    
    /**
     * @dev Amount requested to be withdrawn.
     */
    uint public withdrawAmount;

    
    modifier only_owner() {
        if(msg.sender != owner) throw;
        _;
    }
    
    modifier only_recovery() {
        if(msg.sender != recovery) throw;
        _;
    }

    /**
     * @dev Withdrawal request made
     */
    event Unvault(uint amount, uint when);
    
    /**
     * @dev Recovery key used to send all funds to `address`.
     */
    event Recover(address target, uint value);
    
    /**
     * @dev Funds deposited.
     */
    event Deposit(address from, uint value);
    
    /**
     * @dev Funds withdrawn.
     */
    event Withdraw(address to, uint value);

    /**
     * @dev Constructor.
     * @param _recovery The address of the recovery account.
     * @param _withdrawDelay The time (in seconds) between an unvault request
     *        and the earliest time a withdrawal can be made.
     */
    function Vault(address _recovery, uint _withdrawDelay) {
        owner = msg.sender;
        recovery = _recovery;
        withdrawDelay = _withdrawDelay;
    }
    
    function max(uint a, uint b) internal returns (uint) {
        if(a > b)
            return a;
        return b;
    }
    
    /**
     * @dev Request withdrawal of funds from the vault. Starts a timer for when
     *      funds can be withdrawn. Increases to the amount will reset the
     *      timer, but decreases can be made without changing it.
     * @param amount The amount requested for withdrawal.
     */
    function unvault(uint amount) only_owner {
        if(amount > this.balance)
            throw;
            
        // Update the withdraw time if we're withdrawing more than previously.
        if(amount > withdrawAmount)
            withdrawTime = max(withdrawTime, block.timestamp + withdrawDelay);
        
        withdrawAmount = amount;
        Unvault(amount, withdrawTime);
    }
    
    /**
     * @dev Withdraw funds. Valid only after `unvault` has been called and the
     *      required interval has elapsed.
     */
    function withdraw() only_owner {
        if(block.timestamp < withdrawTime || withdrawAmount == 0)
            throw;
        
        uint amount = withdrawAmount;
        withdrawAmount = 0;

        if(!owner.send(amount))
            throw;

        Withdraw(owner, amount);
    }
    
    /**
     * @dev Use the recovery address to send all funds to the nominated address
     *      and self-destruct this vault.
     * @param target The target address to send funds to.
     */
    function recover(address target) only_recovery {
        Recover(target, this.balance);
        selfdestruct(target);
    }
    
    /**
     * @dev Permits locking funds for longer than the default duration; useful
     *      if you will not have access to your recovery key for a while.
     */
    function lock(uint duration) only_owner {
        withdrawTime = max(withdrawTime, block.timestamp + duration);
    }
    
    function() payable {
        if(msg.value > 0)
            Deposit(msg.sender, msg.value);
    }
}