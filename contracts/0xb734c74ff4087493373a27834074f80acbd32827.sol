pragma solidity ^0.4.6;

contract StandardToken {

    /*
     *  Data structures
     */
    mapping (address => uint256) balances;
    mapping (address => mapping (address => uint256)) allowed;
    uint256 public totalSupply;

    /*
     *  Events
     */
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    /*
     *  Read and write storage functions
     */
    /// @dev Transfers sender's tokens to a given address. Returns success.
    /// @param _to Address of token receiver.
    /// @param _value Number of tokens to transfer.
    function transfer(address _to, uint256 _value) returns (bool success) {
        if (balances[msg.sender] >= _value && _value > 0) {
            balances[msg.sender] -= _value;
            balances[_to] += _value;
            Transfer(msg.sender, _to, _value);
            return true;
        }
        else {
            return false;
        }
    }

    /// @dev Allows allowed third party to transfer tokens from one address to another. Returns success.
    /// @param _from Address from where tokens are withdrawn.
    /// @param _to Address to where tokens are sent.
    /// @param _value Number of tokens to transfer.
    function transferFrom(address _from, address _to, uint256 _value) returns (bool success) {
        if (balances[_from] >= _value && allowed[_from][msg.sender] >= _value && _value > 0) {
            balances[_to] += _value;
            balances[_from] -= _value;
            allowed[_from][msg.sender] -= _value;
            Transfer(_from, _to, _value);
            return true;
        }
        else {
            return false;
        }
    }

    /// @dev Returns number of tokens owned by given address.
    /// @param _owner Address of token owner.
    function balanceOf(address _owner) constant returns (uint256 balance) {
        return balances[_owner];
    }

    /// @dev Sets approved amount of tokens for spender. Returns success.
    /// @param _spender Address of allowed account.
    /// @param _value Number of approved tokens.
    function approve(address _spender, uint256 _value) returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }

    /*
     * Read storage functions
     */
    /// @dev Returns number of allowed tokens for given address.
    /// @param _owner Address of token owner.
    /// @param _spender Address of token spender.
    function allowance(address _owner, address _spender) constant returns (uint256 remaining) {
      return allowed[_owner][_spender];
    }

}


/// @title Token contract - Implements Standard Token Interface for TokenFund.
/// @author Evgeny Yurtaev - <evgeny@etherionlab.com>
contract TokenFund is StandardToken {

    /*
     * External contracts
     */
    address public emissionContractAddress = 0x0;

    /*
     * Token meta data
     */
    string constant public name = "TheToken Fund";
    string constant public symbol = "TKN";
    uint8 constant public decimals = 8;

    /*
     * Storage
     */
    address public owner = 0x0;
    bool public emissionEnabled = true;
    bool transfersEnabled = true;

    /*
     * Modifiers
     */

    modifier isCrowdfundingContract() {
        // Only emission address is allowed to proceed.
        if (msg.sender != emissionContractAddress) {
            throw;
        }
        _;
    }

    modifier onlyOwner() {
        // Only owner is allowed to do this action.
        if (msg.sender != owner) {
            throw;
        }
        _;
    }

    /*
     * Contract functions
     */

     /// @dev TokenFund emission function.
    /// @param _for Address of receiver.
    /// @param tokenCount Number of tokens to issue.
    function issueTokens(address _for, uint tokenCount)
        external
        isCrowdfundingContract
        returns (bool)
    {
        if (emissionEnabled == false) {
            throw;
        }

        balances[_for] += tokenCount;
        totalSupply += tokenCount;
        return true;
    }

    /// @dev Withdraws tokens for msg.sender.
    /// @param tokenCount Number of tokens to withdraw.
    function withdrawTokens(uint tokenCount)
        public
        returns (bool)
    {
        uint balance = balances[msg.sender];
        if (balance < tokenCount) {
            return false;
        }
        balances[msg.sender] -= tokenCount;
        totalSupply -= tokenCount;
        return true;
    }

    /// @dev Function to change address that is allowed to do emission.
    /// @param newAddress Address of new emission contract.
    function changeEmissionContractAddress(address newAddress)
        external
        onlyOwner
        returns (bool)
    {
        emissionContractAddress = newAddress;
    }

    /// @dev Function that enables/disables transfers of token.
    /// @param value True/False
    function enableTransfers(bool value)
        external
        onlyOwner
    {
        transfersEnabled = value;
    }

    /// @dev Function that enables/disables token emission.
    /// @param value True/False
    function enableEmission(bool value)
        external
        onlyOwner
    {
        emissionEnabled = value;
    }

    /*
     * Overriding ERC20 standard token functions to support transfer lock
     */
    function transfer(address _to, uint256 _value)
        returns (bool success)
    {
        if (transfersEnabled == true) {
            return super.transfer(_to, _value);
        }
        return false;
    }

    function transferFrom(address _from, address _to, uint256 _value)
        returns (bool success)
    {
        if (transfersEnabled == true) {
            return super.transferFrom(_from, _to, _value);
        }
        return false;
    }


    /// @dev Contract constructor function sets initial token balances.
    /// @param _owner Address of the owner of TokenFund.
    function TokenFund(address _owner)
    {
        totalSupply = 0;
        owner = _owner;
    }

    function transferOwnership(address newOwner) onlyOwner {
        owner = newOwner;
    }
}

contract owned {
    address public owner;

    function owned() {
        owner = msg.sender;
    }

    modifier onlyOwner {
        if (msg.sender != owner) throw;
        _;
    }

    function transferOwnership(address newOwner) onlyOwner {
        owner = newOwner;
    }
}


contract Fund is owned {

	/*
     * External contracts
     */
    TokenFund public tokenFund;

	/*
     * Storage
     */
    address public ethAddress;
    address public multisig;
    address public supportAddress;
    uint public tokenPrice = 1 finney; // 0.001 ETH

    mapping (address => address) public referrals;

    /*
     * Contract functions
     */

	/// @dev Withdraws tokens for msg.sender.
    /// @param tokenCount Number of tokens to withdraw.
    function withdrawTokens(uint tokenCount)
        public
        returns (bool)
    {
        return tokenFund.withdrawTokens(tokenCount);
    }

    function issueTokens(address _for, uint tokenCount)
    	private
    	returns (bool)
    {
    	if (tokenCount == 0) {
        return false;
      }

      var percent = tokenCount / 100;

      // 1% goes to the fund managers
      if (!tokenFund.issueTokens(multisig, percent)) {
        // Tokens could not be issued.
        throw;
      }

		  // 1% goes to the support team
      if (!tokenFund.issueTokens(supportAddress, percent)) {
        // Tokens could not be issued.
        throw;
      }

      if (referrals[_for] != 0) {
      	// 3% goes to the referral
      	if (!tokenFund.issueTokens(referrals[_for], 3 * percent)) {
          // Tokens could not be issued.
          throw;
        }
      } else {
      	// if there is no referral, 3% goes to the fund managers
      	if (!tokenFund.issueTokens(multisig, 3 * percent)) {
          // Tokens could not be issued.
          throw;
        }
      }

      if (!tokenFund.issueTokens(_for, tokenCount - 5 * percent)) {
        // Tokens could not be issued.
        throw;
	    }

	    return true;
    }

    /// @dev Issues tokens for users who made investment.
    /// @param beneficiary Address the tokens will be issued to.
    /// @param valueInWei investment in wei
    function addInvestment(address beneficiary, uint valueInWei)
        external
        onlyOwner
        returns (bool)
    {
        uint tokenCount = calculateTokens(valueInWei);
    	return issueTokens(beneficiary, tokenCount);
    }

    /// @dev Issues tokens for users who made direct ETH payment.
    function fund()
        public
        payable
        returns (bool)
    {
        // Token count is rounded down. Sent ETH should be multiples of baseTokenPrice.
        address beneficiary = msg.sender;
        uint tokenCount = calculateTokens(msg.value);
        uint roundedInvestment = tokenCount * tokenPrice / 100000000;

        // Send change back to user.
        if (msg.value > roundedInvestment && !beneficiary.send(msg.value - roundedInvestment)) {
          throw;
        }
        // Send money to the fund ethereum address
        if (!ethAddress.send(roundedInvestment)) {
          throw;
        }
        return issueTokens(beneficiary, tokenCount);
    }

    function calculateTokens(uint valueInWei)
        public
        constant
        returns (uint)
    {
        return valueInWei * 100000000 / tokenPrice;
    }

    function estimateTokens(uint valueInWei)
        public
        constant
        returns (uint)
    {
        return valueInWei * 95000000 / tokenPrice;
    }

    function setReferral(address client, address referral)
        public
        onlyOwner
    {
        referrals[client] = referral;
    }

    function getReferral(address client)
        public
        constant
        returns (address)
    {
        return referrals[client];
    }

    /// @dev Sets token price (TKN/ETH) in Wei.
    /// @param valueInWei New value.
    function setTokenPrice(uint valueInWei)
        public
        onlyOwner
    {
        tokenPrice = valueInWei;
    }

    function getTokenPrice()
        public
        constant
        returns (uint)
    {
        return tokenPrice;
    }

    function changeMultisig(address newMultisig)
        onlyOwner
    {
        multisig = newMultisig;
    }

    function changeEthAddress(address newEthAddress)
        onlyOwner
    {
        ethAddress = newEthAddress;
    }

    /// @dev Contract constructor function
    /// @param _ethAddress Ethereum address of the TokenFund.
    /// @param _multisig Address of the owner of TokenFund.
    /// @param _supportAddress Address of the developers team.
    /// @param _tokenAddress Address of the token contract.
    function Fund(address _owner, address _ethAddress, address _multisig, address _supportAddress, address _tokenAddress)
    {
        owner = _owner;
        ethAddress = _ethAddress;
        multisig = _multisig;
        supportAddress = _supportAddress;
        tokenFund = TokenFund(_tokenAddress);
    }

    /// @dev Fallback function. Calls fund() function to create tokens.
    function () payable {
        fund();
    }
}