pragma solidity ^0.4.19;

interface ERC20 {
    function totalSupply() public view returns (uint256);
    function balanceOf(address who) public view returns (uint256);
    function transfer(address to, uint256 value) public returns (bool);

    function allowance(address owner, address spender) public view returns (uint256);
    function transferFrom(address from, address to, uint256 value) public returns (bool);
    function approve(address spender, uint256 value) public returns (bool);

    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Transfer(address indexed from, address indexed to, uint256 value);
}

/**
 * Aethia CHI Token
 *
 * Chi is the in-game currency used throughout Aethia. This contract governs
 * the ownership and transfer of all Chi within the game.
 */
contract ChiToken is ERC20 {

    /**
     * The currency is named Chi.
     * 
     * The currency's symbol is 'CHI'. The different uses for the two are as 
     * follows:
     *  - "That Jelly Pill will cost you 5 CHI."
     *  - "Did you know Aethia uses Chi as currency?"
     */
    string public name = 'Chi';
    string public symbol = 'CHI';
    
    /**
     * There is ten-billion Chi in circulation.
     */
    uint256 _totalSupply = 10000000000;
    
    /**
     * Chi is an atomic currency.
     * 
     * It is not possible to have a fraction of a Chi. You are only able to have
     * integer values of Chi tokens.
     */
    uint256 public decimals = 0;

    /**
     * The amount of CHI owned per address.
     */
    mapping (address => uint256) balances;
    
    /**
     * The amount of CHI an owner has allowed a certain spender.
     */
    mapping (address => mapping (address => uint256)) allowances;

    /**
     * Chi token transfer event.
     * 
     * For audit and logging purposes, as well as to adhere to the ERC-20
     * standard, all chi token transfers are logged by benefactor and 
     * beneficiary.
     */
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    
    /**
     * Chi token allowance approval event.
     * 
     * For audit and logging purposes, as well as to adhere to the ERC-20
     * standard, all chi token allowance approvals are logged by owner and 
     * approved spender.
     */
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);

    /**
     * Contract constructor.
     * 
     * This creates all ten-billion Chi tokens and sets them to the creating
     * address. From this address, the tokens will be distributed to the proper
     * locations.
     */
    function ChiToken() public {
        balances[msg.sender] = _totalSupply;
    }
    
    /**
     * The total supply of Chi tokens. 
     * 
     * Returns
     * -------
     * uint256
     *     The total number of Chi tokens in circulation.
     */
    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    /**
     * Get Chi balance of an address.
     * 
     * Parameters 
     * ----------
     * address : _owner
     *     The address to return the Chi balance of.
     * 
     * Returns
     * -------
     * uint256
     *     The amount of Chi owned by given address.
     */
    function balanceOf(address _owner) public view returns (uint256) {
        return balances[_owner];
    }

    /**
     * Transfer an amount of Chi to an address.
     * 
     * Parameters
     * ----------
     * address : _to
     *     The beneficiary address to transfer the Chi tokens to.
     * uint256 : _value
     *     The number of Chi tokens to transfer.
     * 
     * Returns
     * -------
     * bool
     *     True if the transfer succeeds.
     */
    function transfer(address _to, uint256 _value) public returns (bool) {
        require(balances[msg.sender] >= _value);

        balances[msg.sender] -= _value;
        balances[_to] += _value;

        Transfer(msg.sender, _to, _value);

        return true;
    }

    /**
     * Transfer Chi tokens from one address to another.
     * 
     * This requires an allowance to be set for the requester.
     * 
     * Parameters
     * ----------
     * address : _from
     *     The benefactor address from which the Chi tokens are to be sent.
     * address : _to
     *     The beneficiary address to transfer the Chi tokens to.
     * uint256 : _value
     *      The number of Chi tokens to transfer.
     * 
     * Returns
     * -------
     * bool
     *     True if the transfer succeeds.
     */
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
        require(balances[_from] >= _value);
        require(allowances[_from][msg.sender] >= _value);

        balances[_to] += _value;
        balances[_from] -= _value;

        allowances[_from][msg.sender] -= _value;

        Transfer(_from, _to, _value);

        return true;
    }

    /**
     * Approve given address to spend a number of Chi tokens.
     * 
     * This gives an approval to `_spender` to spend `_value` tokens on behalf
     * of `msg.sender`.
     * 
     * Parameters
     * ----------
     * address : _spender
     *     The address that is to be allowed to spend the given number of Chi
     *     tokens.
     * uint256 : _value
     *     The number of Chi tokens that `_spender` is allowed to spend.
     * 
     * Returns
     * -------
     * bool
     *     True if the approval succeeds.
     */
    function approve(address _spender, uint256 _value) public returns (bool) {
        allowances[msg.sender][_spender] = _value;

        Approval(msg.sender, _spender, _value);

        return true;
    }
    
    /**
     * Get the number of tokens `_spender` is allowed to spend by `_owner`.
     * 
     * Parameters
     * ----------
     * address : _owner
     *     The address that gave out the allowance.
     * address : _spender
     *     The address that is given the allowance to spend.
     * 
     * Returns
     * -------
     * uint256
     *     The number of tokens `_spender` is allowed to spend by `_owner`.
     */
    function allowance(address _owner, address _spender) public view returns (uint256) {
        return allowances[_owner][_spender];
    }
}