pragma solidity ^0.4.18;

/**
 * ICrowdsale
 *
 * Base crowdsale interface to manage the sale of 
 * an ERC20 token
 *
 * #created 09/09/2017
 * #author Frank Bonnet
 */
interface ICrowdsale {

    /**
     * Returns true if the contract is currently in the presale phase
     *
     * @return True if in presale phase
     */
    function isInPresalePhase() public view returns (bool);


    /**
     * Returns true if the contract is currently in the ended stage
     *
     * @return True if ended
     */
    function isEnded() public view returns (bool);


    /**
     * Returns true if `_beneficiary` has a balance allocated
     *
     * @param _beneficiary The account that the balance is allocated for
     * @param _releaseDate The date after which the balance can be withdrawn
     * @return True if there is a balance that belongs to `_beneficiary`
     */
    function hasBalance(address _beneficiary, uint _releaseDate) public view returns (bool);


    /** 
     * Get the allocated token balance of `_owner`
     * 
     * @param _owner The address from which the allocated token balance will be retrieved
     * @return The allocated token balance
     */
    function balanceOf(address _owner) public view returns (uint);


    /** 
     * Get the allocated eth balance of `_owner`
     * 
     * @param _owner The address from which the allocated eth balance will be retrieved
     * @return The allocated eth balance
     */
    function ethBalanceOf(address _owner) public view returns (uint);


    /** 
     * Get invested and refundable balance of `_owner` (only contributions during the ICO phase are registered)
     * 
     * @param _owner The address from which the refundable balance will be retrieved
     * @return The invested refundable balance
     */
    function refundableEthBalanceOf(address _owner) public view returns (uint);


    /**
     * Returns the rate and bonus release date
     *
     * @param _phase The phase to use while determining the rate
     * @param _volume The amount wei used to determine what volume multiplier to use
     * @return The rate used in `_phase` multiplied by the corresponding volume multiplier
     */
    function getRate(uint _phase, uint _volume) public view returns (uint);


    /**
     * Convert `_wei` to an amount in tokens using 
     * the `_rate`
     *
     * @param _wei amount of wei to convert
     * @param _rate rate to use for the conversion
     * @return Amount in tokens
     */
    function toTokens(uint _wei, uint _rate) public view returns (uint);


    /**
     * Receive ether and issue tokens to the sender
     * 
     * This function requires that msg.sender is not a contract. This is required because it's 
     * not possible for a contract to specify a gas amount when calling the (internal) send() 
     * function. Solidity imposes a maximum amount of gas (2300 gas at the time of writing)
     * 
     * Contracts can call the contribute() function instead
     */
    function () public payable;


    /**
     * Receive ether and issue tokens to the sender
     *
     * @return The accepted ether amount
     */
    function contribute() public payable returns (uint);


    /**
     * Receive ether and issue tokens to `_beneficiary`
     *
     * @param _beneficiary The account that receives the tokens
     * @return The accepted ether amount
     */
    function contributeFor(address _beneficiary) public payable returns (uint);


    /**
     * Withdraw allocated tokens
     */
    function withdrawTokens() public;


    /**
     * Withdraw allocated ether
     */
    function withdrawEther() public;


    /**
     * Refund in the case of an unsuccessful crowdsale. The 
     * crowdsale is considered unsuccessful if minAmount was 
     * not raised before end of the crowdsale
     */
    function refund() public;
}


/**
 * ICrowdsaleProxy
 *
 * #created 23/11/2017
 * #author Frank Bonnet
 */
interface ICrowdsaleProxy {

    /**
     * Receive ether and issue tokens to the sender
     * 
     * This function requires that msg.sender is not a contract. This is required because it's 
     * not possible for a contract to specify a gas amount when calling the (internal) send() 
     * function. Solidity imposes a maximum amount of gas (2300 gas at the time of writing)
     * 
     * Contracts can call the contribute() function instead
     */
    function () public payable;


    /**
     * Receive ether and issue tokens to the sender
     *
     * @return The accepted ether amount
     */
    function contribute() public payable returns (uint);


    /**
     * Receive ether and issue tokens to `_beneficiary`
     *
     * @param _beneficiary The account that receives the tokens
     * @return The accepted ether amount
     */
    function contributeFor(address _beneficiary) public payable returns (uint);
}


/**
 * CrowdsaleProxy
 *
 * #created 22/11/2017
 * #author Frank Bonnet
 */
contract CrowdsaleProxy is ICrowdsaleProxy {

    address public owner;
    ICrowdsale public target;
    

    /**
     * Deploy proxy
     *
     * @param _owner Owner of the proxy
     * @param _target Target crowdsale
     */
    function CrowdsaleProxy(address _owner, address _target) public {
        target = ICrowdsale(_target);
        owner = _owner;
    }


    /**
     * Receive contribution and forward to the crowdsale
     * 
     * This function requires that msg.sender is not a contract. This is required because it's 
     * not possible for a contract to specify a gas amount when calling the (internal) send() 
     * function. Solidity imposes a maximum amount of gas (2300 gas at the time of writing)
     */
    function () public payable {
        target.contributeFor.value(msg.value)(msg.sender);
    }


    /**
     * Receive ether and issue tokens to the sender
     *
     * @return The accepted ether amount
     */
    function contribute() public payable returns (uint) {
        target.contributeFor.value(msg.value)(msg.sender);
    }


    /**
     * Receive ether and issue tokens to `_beneficiary`
     *
     * @param _beneficiary The account that receives the tokens
     * @return The accepted ether amount
     */
    function contributeFor(address _beneficiary) public payable returns (uint) {
        target.contributeFor.value(msg.value)(_beneficiary);
    }
}