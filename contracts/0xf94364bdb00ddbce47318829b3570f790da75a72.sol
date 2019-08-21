pragma solidity 0.4.25;

contract StandardToken {

    /* Data structures */
    mapping (address => uint256) balances;
    mapping (address => mapping (address => uint256)) allowed;
    uint256 public totalSupply;

    /* Events */
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    /* Read and write storage functions */

    // Transfers sender's tokens to a given address. Returns success.
    function transfer(address _to, uint256 _value) public returns (bool success) {
        if (balances[msg.sender] >= _value && _value > 0) {
            balances[msg.sender] -= _value;
            balances[_to] += _value;
            emit Transfer(msg.sender, _to, _value);
            return true;
        }
        else {
            return false;
        }
    }

    // Allows allowed third party to transfer tokens from one address to another. Returns success. _value Number of tokens to transfer.
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        if (balances[_from] >= _value && allowed[_from][msg.sender] >= _value && _value > 0) {
            balances[_to] += _value;
            balances[_from] -= _value;
            allowed[_from][msg.sender] -= _value;
            emit Transfer(_from, _to, _value);
            return true;
        }
        else {
            return false;
        }
    }

    // Returns number of tokens owned by given address.
    function balanceOf(address _owner) public view returns (uint256 balance) {
        return balances[_owner];
    }

    // Sets approved amount of tokens for spender. Returns success. _value Number of approved tokens.
    function approve(address _spender, uint256 _value) public returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    /* Read storage functions */

    //Returns number of allowed tokens for given address. _owner Address of token owner. _spender Address of token spender.
    function allowance(address _owner, address _spender) public view returns (uint256 remaining) {
      return allowed[_owner][_spender];
    }

}


contract AltTokenFund is StandardToken {

    /* External contracts */

    address public emissionContractAddress = 0x0;

    //Token meta data
    string constant public name = "Alt Token Fund";
    string constant public symbol = "ATF";
    uint8 constant public decimals = 8;

    /* Storage */
    address public owner = 0x0;
    bool public emissionEnabled = true;
    bool transfersEnabled = true;

    /* Modifiers */

    modifier isCrowdfundingContract() {
        // Only emission address to do this action
        if (msg.sender != emissionContractAddress) {
            revert();
        }
        _;
    }

    modifier onlyOwner() {
        // Only owner is allowed to do this action.
        if (msg.sender != owner) {
            revert();
        }
        _;
    }

    /* Contract functions */

    // TokenFund emission function. _for is Address of receiver, tokenCount is Number of tokens to issue.
    function issueTokens(address _for, uint tokenCount)
        external
        isCrowdfundingContract
        returns (bool)
    {
        if (emissionEnabled == false) {
            revert();
        }

        balances[_for] += tokenCount;
        totalSupply += tokenCount;
        return true;
    }

    // Withdraws tokens for msg.sender.
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

    // Function to change address that is allowed to do emission.
    function changeEmissionContractAddress(address newAddress)
        external
        onlyOwner
    {
        emissionContractAddress = newAddress;
    }

    // Function that enables/disables transfers of token, value is true/false
    function enableTransfers(bool value)
        external
        onlyOwner
    {
        transfersEnabled = value;
    }

    // Function that enables/disables token emission.
    function enableEmission(bool value)
        external
        onlyOwner
    {
        emissionEnabled = value;
    }

    /* Overriding ERC20 standard token functions to support transfer lock */
    function transfer(address _to, uint256 _value) public returns (bool success) {
        if (transfersEnabled == true) {
            return super.transfer(_to, _value);
        }
        return false;
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        if (transfersEnabled == true) {
            return super.transferFrom(_from, _to, _value);
        }
        return false;
    }


    // Contract constructor function sets initial token balances. _owner Address of the owner of AltTokenFund.
    constructor (address _owner) public
    {
        totalSupply = 0;
        owner = _owner;
    }

    function transferOwnership(address newOwner) public onlyOwner {
        owner = newOwner;
    }
}

contract Fund {

  address public owner;
  address public SetPriceAccount;
  address public SetReferralAccount;

  modifier onlyOwner {
      if (msg.sender != owner) revert();
      _;
  }
  
  modifier onlySetPriceAccount {
      if (msg.sender != SetPriceAccount) revert();
      _;
  }
  
  modifier onlySetReferralAccount {
      if (msg.sender != SetReferralAccount) revert();
      _;
  }
  
    /* External contracts */
    AltTokenFund public tokenFund;

    /* Events */
    event Deposit(address indexed from, uint256 value);
    event Withdrawal(address indexed from, uint256 value);
    event AddInvestment(address indexed to, uint256 value);

    /* Storage */
    address public ethAddress;
    address public fundManagers;
    address public supportAddress;
    uint public tokenPrice = 1 finney; // 0.001 ETH
    uint public managersFee = 1;
    uint public referralFee = 3;
    uint public supportFee = 1;

    mapping (address => address) public referrals;

/* Contract functions */

    // Issue tokens _for address and send comissions

    function issueTokens(address _for, uint tokenCount)
    	private
    	returns (bool)
    {
    	if (tokenCount == 0) {
        return false;
      }

      uint percent = tokenCount / 100;

    // managersFee to the fund managers
      if (!tokenFund.issueTokens(fundManagers, percent * managersFee)) {
        // Tokens could not be issued.
        revert();
      }

    // supportFee to the support team
      if (!tokenFund.issueTokens(supportAddress, percent * supportFee)) {
        // Tokens could not be issued.
        revert();
      }

      if (referrals[_for] != 0) {
      	// referralFee to the referral
      	if (!tokenFund.issueTokens(referrals[_for], referralFee * percent)) {
          // Tokens could not be issued.
          revert();
        }
      } else {
      	// if there is no referral, referralFee goes to the fund managers
      	if (!tokenFund.issueTokens(fundManagers, referralFee * percent)) {
          // Tokens could not be issued.
          revert();
        }
      }

      if (!tokenFund.issueTokens(_for, tokenCount - (referralFee+supportFee+managersFee) * percent)) {
        // Tokens could not be issued.
        revert();
	    }

	    return true;
    }

    // Issues tokens for users who made investment.
    // @param beneficiary Address the tokens will be issued to.
    // @param valueInWei investment in wei
    function addInvestment(address beneficiary, uint valueInWei)
        external
        onlyOwner
        returns (bool)
    {
        uint tokenCount = calculateTokens(valueInWei);
    	return issueTokens(beneficiary, tokenCount);
    }

    // Issues tokens for users who made direct ETH payment.
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
          revert();
        }
        // Send money to the fund ethereum address
        if (!ethAddress.send(roundedInvestment)) {
          revert();
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
        return valueInWei * (100000000-1000000*(referralFee+supportFee+managersFee)) / tokenPrice;
    }

    function setReferral(address client, address referral)
        public
        onlySetReferralAccount
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
        onlySetPriceAccount
    {
        tokenPrice = valueInWei;
    }


    function changeComissions(uint newManagersFee, uint newSupportFee, uint newReferralFee) public
        onlyOwner
    {
        managersFee = newManagersFee;
        supportFee = newSupportFee;
        referralFee = newReferralFee;
    }

    function changefundManagers(address newfundManagers) public
        onlyOwner
    {
        fundManagers = newfundManagers;
    }

    function changeEthAddress(address newEthAddress) public
        onlyOwner
    {
        ethAddress = newEthAddress;
    }

    function changeSupportAddress(address newSupportAddress) public
        onlyOwner
    {
        supportAddress = newSupportAddress;
    }
    
    function changeSetPriceAccount(address newSetPriceAccount) public
        onlyOwner
    {
        SetPriceAccount = newSetPriceAccount;
    }
    
     function changeSetReferralAccount (address newSetReferralAccount) public
        onlyOwner
    {
        SetReferralAccount = newSetReferralAccount;
    }

    function transferOwnership(address newOwner) public
      onlyOwner
    {
        owner = newOwner;
    }

    // Contract constructor function

    constructor (address _owner, address _SetPriceAccount, address _SetReferralAccount, address _ethAddress, address _fundManagers, address _supportAddress, address _tokenAddress)
    public
    {
        owner = _owner;
        SetPriceAccount = _SetPriceAccount;
        SetReferralAccount = _SetReferralAccount;
        ethAddress = _ethAddress;
        fundManagers = _fundManagers;
        supportAddress = _supportAddress;
        tokenFund = AltTokenFund(_tokenAddress);
    }

    // Fallback function. Calls fund() function to create tokens once contract receives payment.
    function () public payable {
        fund();
    }
}