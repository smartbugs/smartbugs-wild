pragma solidity ^0.4.11;

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {
  function mul(uint256 a, uint256 b) internal constant returns (uint256) {
    uint256 c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal constant returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  function sub(uint256 a, uint256 b) internal constant returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal constant returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}

pragma solidity ^0.4.11;


/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
  address public owner;


  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  function Ownable() {
    owner = msg.sender;
  }


  /**
   * @dev Throws if called by any account other than the owner.
   */
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }


  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param newOwner The address to transfer ownership to.
   */
  function transferOwnership(address newOwner) onlyOwner public {
    require(newOwner != address(0));
    OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }

}

pragma solidity ^0.4.11;


/**
 * @title ERC20Basic
 * @dev Simpler version of ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/179
 */
contract ERC20Basic {
  uint256 public totalSupply;
  function balanceOf(address who) public constant returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}


pragma solidity ^0.4.11;


/**
 * @title Basic token
 * @dev Basic version of StandardToken, with no allowances.
 */
contract BasicToken is ERC20Basic {
  using SafeMath for uint256;

  mapping(address => uint256) balances;

  /**
  * @dev transfer token for a specified address
  * @param _to The address to transfer to.
  * @param _value The amount to be transferred.
  */
  function transfer(address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));

    // SafeMath.sub will throw if there is not enough balance.
    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);
    Transfer(msg.sender, _to, _value);
    return true;
  }

  /**
  * @dev Gets the balance of the specified address.
  * @param _owner The address to query the the balance of.
  * @return An uint256 representing the amount owned by the passed address.
  */
  function balanceOf(address _owner) public constant returns (uint256 balance) {
    return balances[_owner];
  }

}

pragma solidity ^0.4.11;


/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender) public constant returns (uint256);
  function transferFrom(address from, address to, uint256 value) public returns (bool);
  function approve(address spender, uint256 value) public returns (bool);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}

pragma solidity ^0.4.11;


/**
 * @title Standard ERC20 token
 *
 * @dev Implementation of the basic standard token.
 * @dev https://github.com/ethereum/EIPs/issues/20
 * @dev Based on code by FirstBlood: https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol
 */
contract StandardToken is ERC20, BasicToken {

  mapping (address => mapping (address => uint256)) allowed;


  /**
   * @dev Transfer tokens from one address to another
   * @param _from address The address which you want to send tokens from
   * @param _to address The address which you want to transfer to
   * @param _value uint256 the amount of tokens to be transferred
   */
  function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));

    uint256 _allowance = allowed[_from][msg.sender];

    // Check is not needed because sub(_allowance, _value) will already throw if this condition is not met
    // require (_value <= _allowance);

    balances[_from] = balances[_from].sub(_value);
    balances[_to] = balances[_to].add(_value);
    allowed[_from][msg.sender] = _allowance.sub(_value);
    Transfer(_from, _to, _value);
    return true;
  }

  /**
   * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.
   *
   * Beware that changing an allowance with this method brings the risk that someone may use both the old
   * and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this
   * race condition is to first reduce the spender's allowance to 0 and set the desired value afterwards:
   * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
   * @param _spender The address which will spend the funds.
   * @param _value The amount of tokens to be spent.
   */
  function approve(address _spender, uint256 _value) public returns (bool) {
    allowed[msg.sender][_spender] = _value;
    Approval(msg.sender, _spender, _value);
    return true;
  }

  /**
   * @dev Function to check the amount of tokens that an owner allowed to a spender.
   * @param _owner address The address which owns the funds.
   * @param _spender address The address which will spend the funds.
   * @return A uint256 specifying the amount of tokens still available for the spender.
   */
  function allowance(address _owner, address _spender) public constant returns (uint256 remaining) {
    return allowed[_owner][_spender];
  }

  /**
   * approve should be called when allowed[_spender] == 0. To increment
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   */
  function increaseApproval (address _spender, uint _addedValue)
    returns (bool success) {
    allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
    Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

  function decreaseApproval (address _spender, uint _subtractedValue)
    returns (bool success) {
    uint oldValue = allowed[msg.sender][_spender];
    if (_subtractedValue > oldValue) {
      allowed[msg.sender][_spender] = 0;
    } else {
      allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
    }
    Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

}

pragma solidity ^0.4.11;


/*****
* @title The ICO Contract
*/
contract DadiToken is StandardToken, Ownable {
    using SafeMath for uint256;

    /* Public variables of the token */
    string public name = "DADI";
    string public symbol = "DADI";
    uint8 public decimals = 18;
    string public version = "H1.0";

    address public owner;

    uint256 public hundredPercent = 1000;
    uint256 public foundersPercentOfTotal = 200;
    uint256 public referralPercentOfTotal = 50;
    uint256 public ecosystemPercentOfTotal = 25;
    uint256 public operationsPercentOfTotal = 25;

    uint256 public investorCount = 0;
    uint256 public totalRaised; // total ether raised (in wei)
    uint256 public preSaleRaised = 0; // ether raised (in wei)
    uint256 public publicSaleRaised = 0; // ether raised (in wei)

    // PartnerSale variables
    uint256 public partnerSaleTokensAvailable;
    uint256 public partnerSaleTokensPurchased = 0;
    mapping(address => uint256) public purchasedTokens;
    mapping(address => uint256) public partnerSaleWei;

    // PreSale variables
    uint256 public preSaleTokensAvailable;
    uint256 public preSaleTokensPurchased = 0;

    // PublicSale variables
    uint256 public publicSaleTokensAvailable;
    uint256 public publicSaleTokensPurchased = 0;

    // Price data
    uint256 public partnerSaleTokenPrice = 125;     // USD$0.125
    uint256 public partnerSaleTokenValue;
    uint256 public preSaleTokenPrice = 250;         // USD$0.25
    uint256 public publicSaleTokenPrice = 500;       // USD$0.50

    // ETH to USD Rate, set by owner: 1 ETH = ethRate USD
    uint256 public ethRate;

    // Address which will receive raised funds and owns the total supply of tokens
    address public fundsWallet;
    address public ecosystemWallet;
    address public operationsWallet;
    address public referralProgrammeWallet;
    address[] public foundingTeamWallets;
    
    address[] public partnerSaleWallets;
    address[] public preSaleWallets;
    address[] public publicSaleWallets;
   
    /*****
    * State machine
    *  0 - Preparing:            All contract initialization calls
    *  1 - PartnerSale:          Contract is in the invite-only PartnerSale Period
    *  6 - PartnerSaleFinalized: PartnerSale has completed
    *  2 - PreSale:              Contract is in the PreSale Period
    *  7 - PreSaleFinalized:     PreSale has completed
    *  3 - PublicSale:           The public sale of tokens, follows PreSale
    *  8 - PublicSaleFinalized:  The PublicSale has completed
    *  4 - Success:              ICO Successful
    *  5 - Failure:              Minimum funding goal not reached
    *  9 - Refunding:            Owner can transfer refunds
    * 10 - Closed:               ICO has finished, all tokens must have been claimed
    */
    enum SaleState { Preparing, PartnerSale, PreSale, PublicSale, Success, Failure, PartnerSaleFinalized, PreSaleFinalized, PublicSaleFinalized, Refunding, Closed }
    SaleState public state = SaleState.Preparing;

    /**
    * event for token purchase logging
    * @param purchaser who paid for the tokens
    * @param beneficiary who got the tokens
    * @param value weis paid for purchase
    * @param tokens amount of tokens purchased
    */
    event LogTokenPurchase(address indexed purchaser, address indexed beneficiary, uint256 value, uint256 tokens);
    event LogRedistributeTokens(address recipient, SaleState state, uint256 tokens);
    event LogRefundProcessed(address recipient, uint256 value);
    event LogRefundFailed(address recipient, uint256 value);
    event LogClaimTokens(address recipient, uint256 tokens);
    event LogFundTransfer(address wallet, uint256 value);

    /*****
    * @dev Modifier to check that amount transferred is not 0
    */
    modifier nonZero() {
        require(msg.value != 0);
        _;
    }

    /*****
    * @dev The constructor function to initialize the token related properties
    * @param _wallet                        address     Specifies the address of the funding wallet
    * @param _operationalWallets            address[]   Specifies an array of addresses for [0] ecosystem, [1] operations, [2] referral programme
    * @param _foundingTeamWallets           address[]   Specifies an array of addresses of the founding team wallets
    * @param _initialSupply                 uint256     Specifies the total number of tokens available
    * @param _tokensAvailable               uint256[]   Specifies an array of tokens available for each phase, [0] PartnerSale, [1] PreSale, [2] PublicSale
    */
    function DadiToken (
        address _wallet,
        address[] _operationalWallets,
        address[] _foundingTeamWallets,
        uint256 _initialSupply,
        uint256[] _tokensAvailable
    ) public {
        require(_wallet != address(0));

        owner = msg.sender;
 
        // Token distribution per sale phase
        partnerSaleTokensAvailable = _tokensAvailable[0];
        preSaleTokensAvailable = _tokensAvailable[1];
        publicSaleTokensAvailable = _tokensAvailable[2];

        // Determine the actual supply using token amount * decimals
        totalSupply = _initialSupply * (uint256(10) ** decimals);

        // Give all the initial tokens to the contract owner
        balances[owner] = totalSupply;
        Transfer(0x0, owner, totalSupply);

        // Distribute tokens to the supporting operational wallets
        ecosystemWallet = _operationalWallets[0];
        operationsWallet = _operationalWallets[1];
        referralProgrammeWallet = _operationalWallets[2];
        foundingTeamWallets = _foundingTeamWallets;
        fundsWallet = _wallet;
        
        // Set a base ETHUSD rate
        updateEthRate(300000);
    }

    /*****
    * @dev Fallback Function to buy the tokens
    */
    function () payable {
        require(
            state == SaleState.PartnerSale || 
            state == SaleState.PreSale || 
            state == SaleState.PublicSale
        );

        buyTokens(msg.sender, msg.value);
    }

    /*****
    * @dev Allows transfer of tokens to a recipient who has purchased offline, during the PartnerSale
    * @param _recipient     address     The address of the recipient of the tokens
    * @param _tokens        uint256     The number of tokens purchased by the recipient
    * @return success       bool        Returns true if executed successfully
    */
    function offlineTransaction (address _recipient, uint256 _tokens) public onlyOwner returns (bool) {
        require(state == SaleState.PartnerSale);
        require(_tokens > 0);

        // Convert to a token with decimals 
        uint256 tokens = _tokens * (uint256(10) ** decimals);

        purchasedTokens[_recipient] = purchasedTokens[_recipient].add(tokens);

        // Use original _token argument to increase the count of tokens purchased in the PartnerSale
        partnerSaleTokensPurchased = partnerSaleTokensPurchased.add(_tokens);

        // Finalize the PartnerSale if necessary
        if (partnerSaleTokensPurchased >= partnerSaleTokensAvailable) {
            state = SaleState.PartnerSaleFinalized;
        }

        LogTokenPurchase(msg.sender, _recipient, 0, tokens);

        return true;
    }

    /*****
    * @dev Allow updating the ETH USD exchange rate
    * @param rate   uint256  the current ETH USD rate, multiplied by 1000
    * @return bool  Return true if the contract is in PartnerSale Period
    */
    function updateEthRate (uint256 rate) public onlyOwner returns (bool) {
        require(rate >= 100000);
        
        ethRate = rate;
        return true;
    }

    /*****
    * @dev Allows the contract owner to add a new PartnerSale wallet, used to hold funds safely
    *      Can only be performed in the Preparing state
    * @param _wallet        address     The address of the wallet
    * @return success       bool        Returns true if executed successfully
    */
    function addPartnerSaleWallet (address _wallet) public onlyOwner returns (bool) {
        require(state < SaleState.PartnerSaleFinalized);
        require(_wallet != address(0));
        partnerSaleWallets.push(_wallet);
        return true;
    }

    /*****
    * @dev Allows the contract owner to add a new PreSale wallet, used to hold funds safely
    *      Can not be performed in the PreSale state
    * @param _wallet        address     The address of the wallet
    * @return success       bool        Returns true if executed successfully
    */
    function addPreSaleWallet (address _wallet) public onlyOwner returns (bool) {
        require(state != SaleState.PreSale);
        require(_wallet != address(0));
        preSaleWallets.push(_wallet);
        return true;
    }

    /*****
    * @dev Allows the contract owner to add a new PublicSale wallet, used to hold funds safely
    *      Can not be performed in the PublicSale state
    * @param _wallet        address     The address of the wallet
    * @return success       bool        Returns true if executed successfully
    */
    function addPublicSaleWallet (address _wallet) public onlyOwner returns (bool) {
        require(state != SaleState.PublicSale);
        require(_wallet != address(0));
        publicSaleWallets.push(_wallet);
        return true;
    }

    /*****
    * @dev Calculates the number of tokens that can be bought for the amount of Wei transferred
    * @param _amount    uint256     The amount of money invested by the investor
    * @return tokens    uint256     The number of tokens purchased for the amount invested
    */
    function calculateTokens (uint256 _amount) public returns (uint256 tokens) {
        if (isStatePartnerSale()) {
            tokens = _amount * ethRate / partnerSaleTokenPrice;
        } else if (isStatePreSale()) {
            tokens = _amount * ethRate / preSaleTokenPrice;
        } else if (isStatePublicSale()) {
            tokens = _amount * ethRate / publicSaleTokenPrice;
        } else {
            tokens = 0;
        }

        return tokens;
    }

    /*****
    * @dev Called by the owner of the contract to open the Partner/Pre/Crowd Sale periods
    */
    function setPhase (uint256 phase) public onlyOwner {
        state = SaleState(uint(phase));
    }

    /*****
    * @dev Called by the owner of the contract to start the Partner Sale
    * @param rate   uint256  the current ETH USD rate, multiplied by 1000
    */
    function startPartnerSale (uint256 rate) public onlyOwner {
        state = SaleState.PartnerSale;
        updateEthRate(rate);
    }

    /*****
    * @dev Called by the owner of the contract to start the Pre Sale
    * @param rate   uint256  the current ETH USD rate, multiplied by 1000
    */
    function startPreSale (uint256 rate) public onlyOwner {
        state = SaleState.PreSale;
        updateEthRate(rate);
    }

    /*****
    * @dev Called by the owner of the contract to start the Public Sale
    * @param rate   uint256  the current ETH USD rate, multiplied by 1000
    */
    function startPublicSale (uint256 rate) public onlyOwner {
        state = SaleState.PublicSale;
        updateEthRate(rate);
    }

    /*****
    * @dev Called by the owner of the contract to close the Partner Sale
    */
    function finalizePartnerSale () public onlyOwner {
        require(state == SaleState.PartnerSale);
        
        state = SaleState.PartnerSaleFinalized;
    }

    /*****
    * @dev Called by the owner of the contract to close the Pre Sale
    */
    function finalizePreSale () public onlyOwner {
        require(state == SaleState.PreSale);
        
        state = SaleState.PreSaleFinalized;
    }

    /*****
    * @dev Called by the owner of the contract to close the Public Sale
    */
    function finalizePublicSale () public onlyOwner {
        require(state == SaleState.PublicSale);
        
        state = SaleState.PublicSaleFinalized;
    }

    /*****
    * @dev Called by the owner of the contract to finalize the ICO
    *      and redistribute funds and unsold tokens
    */
    function finalizeIco () public onlyOwner {
        require(state == SaleState.PublicSaleFinalized);

        state = SaleState.Success;

        // 2.5% of total goes to DADI ecosystem
        distribute(ecosystemWallet, ecosystemPercentOfTotal);

        // 2.5% of total goes to DADI+ operations
        distribute(operationsWallet, operationsPercentOfTotal);

        // 5% of total goes to referral programme
        distribute(referralProgrammeWallet, referralPercentOfTotal);
        
        // 20% of total goes to the founding team wallets
        distributeFoundingTeamTokens(foundingTeamWallets);

        // redistribute unsold tokens to DADI ecosystem
        uint256 remainingPreSaleTokens = getPreSaleTokensAvailable();
        preSaleTokensAvailable = 0;
        
        uint256 remainingPublicSaleTokens = getPublicSaleTokensAvailable();
        publicSaleTokensAvailable = 0;

        // we need to represent the tokens with included decimals
        // `2640 ** (10 ^ 18)` not `2640`
        if (remainingPreSaleTokens > 0) {
            remainingPreSaleTokens = remainingPreSaleTokens * (uint256(10) ** decimals);
            balances[owner] = balances[owner].sub(remainingPreSaleTokens);
            balances[ecosystemWallet] = balances[ecosystemWallet].add(remainingPreSaleTokens);
            Transfer(0, ecosystemWallet, remainingPreSaleTokens);
        }

        if (remainingPublicSaleTokens > 0) {
            remainingPublicSaleTokens = remainingPublicSaleTokens * (uint256(10) ** decimals);
            balances[owner] = balances[owner].sub(remainingPublicSaleTokens);
            balances[ecosystemWallet] = balances[ecosystemWallet].add(remainingPublicSaleTokens);
            Transfer(0, ecosystemWallet, remainingPublicSaleTokens);
        }

        // Transfer ETH to the funding wallet.
        if (!fundsWallet.send(this.balance)) {
            revert();
        }
    }

    /*****
    * @dev Called by the owner of the contract to close the ICO
    *      and unsold tokens to the ecosystem wallet. No more tokens 
    *      may be claimed
    */
    function closeIco () public onlyOwner {
        state = SaleState.Closed;
    }
    

    /*****
    * @dev Allow investors to claim their tokens after the ICO is finalized & successful
    * @return   bool  Return true, if executed successfully
    */
    function claimTokens () public returns (bool) {
        require(state == SaleState.Success);
        
        // get the tokens available for the sender
        uint256 tokens = purchasedTokens[msg.sender];
        require(tokens > 0);

        purchasedTokens[msg.sender] = 0;

        balances[owner] = balances[owner].sub(tokens);
        balances[msg.sender] = balances[msg.sender].add(tokens);
      
        LogClaimTokens(msg.sender, tokens);
        Transfer(owner, msg.sender, tokens);
        return true;
    }

    /*****
    * @dev Allow investors to take their money back after a failure in the ICO
    * @param _recipient     address     The caller of the function who is looking for refund
    * @return               bool        Return true, if executed successfully
    */
    function refund (address _recipient) public onlyOwner returns (bool) {
        require(state == SaleState.Refunding);

        uint256 value = partnerSaleWei[_recipient];
        
        require(value > 0);

        partnerSaleWei[_recipient] = 0;

        if(!_recipient.send(value)) {
            partnerSaleWei[_recipient] = value;
            LogRefundFailed(_recipient, value);
        }

        LogRefundProcessed(_recipient, value);
        return true;
    }

    /*****
    * @dev Allows owner to withdraw funds from the contract balance for marketing purposes
    * @param _address       address     The recipient address for the ether
    * @return               bool        Return true, if executed successfully
    */
    function withdrawFunds (address _address, uint256 _amount) public onlyOwner {
        _address.transfer(_amount);
    }

    /*****
    * @dev Generates a random number from 1 to max based on the last block hash
    * @param max     uint  the maximum value 
    * @return a random number
    */
    function getRandom(uint max) public constant returns (uint randomNumber) {
        return (uint(sha3(block.blockhash(block.number - 1))) % max) + 1;
    }

    /*****
    * @dev Called by the owner of the contract to set the state to Refunding
    */
    function setRefunding () public onlyOwner {
        require(state == SaleState.PartnerSaleFinalized);
        
        state = SaleState.Refunding;
    }

    /*****
    * @dev Get the overall success state of the ICO
    * @return bool whether the state is successful, or not
    */
    function isSuccessful () public constant returns (bool) {
        return state == SaleState.Success;
    }

    /*****
    * @dev Get the amount of PreSale tokens left for purchase
    * @return uint256 the count of tokens available
    */
    function getPreSaleTokensAvailable () public constant returns (uint256) {
        if (preSaleTokensAvailable == 0) {
            return 0;
        }

        return preSaleTokensAvailable - preSaleTokensPurchased;
    }

    /*****
    * @dev Get the amount of PublicSale tokens left for purchase
    * @return uint256 the count of tokens available
    */
    function getPublicSaleTokensAvailable () public constant returns (uint256) {
        if (publicSaleTokensAvailable == 0) {
            return 0;
        }

        return publicSaleTokensAvailable - publicSaleTokensPurchased;
    }

    /*****
    * @dev Get the total count of tokens purchased in all the Sale periods
    * @return uint256 the count of tokens purchased
    */
    function getTokensPurchased () public constant returns (uint256) {
        return partnerSaleTokensPurchased + preSaleTokensPurchased + publicSaleTokensPurchased;
    }

    /*****
    * @dev Get the total amount raised in the PreSale and PublicSale periods
    * @return uint256 the amount raised, in Wei
    */
    function getTotalRaised () public constant returns (uint256) {
        return preSaleRaised + publicSaleRaised;
    }

    /*****
    * @dev Get the balance sent to the contract
    * @return uint256 the amount sent to this contract, in Wei
    */
    function getBalance () public constant returns (uint256) {
        return this.balance;
    }

    /*****
    * @dev Get the balance of the funds wallet used to transfer the final balance
    * @return uint256 the amount sent to the funds wallet at the end of the ICO, in Wei
    */
    function getFundsWalletBalance () public constant onlyOwner returns (uint256) {
        return fundsWallet.balance;
    }

    /*****
    * @dev Get the count of unique investors
    * @return uint256 the total number of unique investors
    */
    function getInvestorCount () public constant returns (uint256) {
        return investorCount;
    }

    /*****
    * @dev Send ether to the fund collection wallets
    */
    function forwardFunds (uint256 _value) internal {
        // if (isStatePartnerSale()) {
        //     // move funds to a partnerSaleWallet
        //     if (partnerSaleWallets.length > 0) {
        //         // Transfer ETH to a random wallet
        //         uint accountNumber = getRandom(partnerSaleWallets.length) - 1;
        //         address account = partnerSaleWallets[accountNumber];
        //         account.transfer(_value);
        //         LogFundTransfer(account, _value);
        //     }
        // }

        uint accountNumber;
        address account;

        if (isStatePreSale()) {
            // move funds to a preSaleWallet
            if (preSaleWallets.length > 0) {
                // Transfer ETH to a random wallet
                accountNumber = getRandom(preSaleWallets.length) - 1;
                account = preSaleWallets[accountNumber];
                account.transfer(_value);
                LogFundTransfer(account, _value);
            }
        } else if (isStatePublicSale()) {
            // move funds to a publicSaleWallet
            if (publicSaleWallets.length > 0) {
                // Transfer ETH to a random wallet
                accountNumber = getRandom(publicSaleWallets.length) - 1;
                account = publicSaleWallets[accountNumber];
                account.transfer(_value);
                LogFundTransfer(account, _value);
            }
        }
    }

    /*****
    * @dev Internal function to execute the token transfer to the recipient
    *      In the PartnerSale period, token balances are stored in a separate mapping, to
    *      await the PartnerSaleFinalized state, when investors may call claimTokens
    * @param _recipient     address     The address of the recipient of the tokens
    * @param _value         uint256     The amount invested by the recipient
    * @return success       bool        Returns true if executed successfully
    */
    function buyTokens (address _recipient, uint256 _value) internal returns (bool) {
        uint256 boughtTokens = calculateTokens(_value);
        require(boughtTokens != 0);

        if (isStatePartnerSale()) {
            // assign tokens to separate mapping
            purchasedTokens[_recipient] = purchasedTokens[_recipient].add(boughtTokens);
            partnerSaleWei[_recipient] = partnerSaleWei[_recipient].add(_value);
        } else {
            // increment the unique investor count
            if (purchasedTokens[_recipient] == 0) {
                investorCount++;
            }

            // assign tokens to separate mapping, that is not "balances"
            purchasedTokens[_recipient] = purchasedTokens[_recipient].add(boughtTokens);
        }

       
        LogTokenPurchase(msg.sender, _recipient, _value, boughtTokens);

        forwardFunds(_value);

        updateSaleParameters(_value, boughtTokens);

        return true;
    }

    /*****
    * @dev Internal function to modify parameters based on tokens bought
    * @param _value         uint256     The amount invested in exchange for the tokens
    * @param _tokens        uint256     The number of tokens purchased
    * @return success       bool        Returns true if executed successfully
    */
    function updateSaleParameters (uint256 _value, uint256 _tokens) internal returns (bool) {
        // we need to represent the integer value of tokens here
        // tokensPurchased = `2640`, not `2640 ** (10 ^ 18)`
        uint256 tokens = _tokens / (uint256(10) ** decimals);

        if (isStatePartnerSale()) {
            partnerSaleTokensPurchased = partnerSaleTokensPurchased.add(tokens);

            // No PartnerSale tokens remaining
            if (partnerSaleTokensPurchased >= partnerSaleTokensAvailable) {
                state = SaleState.PartnerSaleFinalized;
            }
        } else if (isStatePreSale()) {
            preSaleTokensPurchased = preSaleTokensPurchased.add(tokens);

            preSaleRaised = preSaleRaised.add(_value);

            // No PreSale tokens remaining
            if (preSaleTokensPurchased >= preSaleTokensAvailable) {
                state = SaleState.PreSaleFinalized;
            }
        } else if (isStatePublicSale()) {
            publicSaleTokensPurchased = publicSaleTokensPurchased.add(tokens);

            publicSaleRaised = publicSaleRaised.add(_value);

            // No PublicSale tokens remaining
            if (publicSaleTokensPurchased >= publicSaleTokensAvailable) {
                state = SaleState.PublicSaleFinalized;
            }
        }
    }

    /*****
    * @dev Internal calculation for the amount of Wei the specified tokens are worth
    * @param _tokens    uint256     The number of tokens purchased by the investor
    * @return amount    uint256     The amount the tokens are worth
    */
    function calculateValueFromTokens (uint256 _tokens) internal returns (uint256) {
        uint256 amount = _tokens.div(ethRate.div(partnerSaleTokenPrice));
        return amount;
    }

    /*****
    * @dev Private function to distribute tokens evenly amongst the founding team wallet addresses
    * @param _recipients    address[]   An array of founding team wallet addresses
    * @return success       bool        Returns true if executed successfully
    */
    function distributeFoundingTeamTokens (address[] _recipients) private returns (bool) {
        // determine the split between wallets
        // to arrive at a valid percentage we start the percentage the founding team has
        // available, which is 20% of the total supply. The percentage to distribute then is the
        // total percentage divided by the number of founding team wallets (likely 4).
        uint percentage = foundersPercentOfTotal / _recipients.length;

        for (uint i = 0; i < _recipients.length; i++) {
            distribute(_recipients[i], percentage);
        }
    }

    /*****
    * @dev Private function to move tokens to the specified wallet address
    * @param _recipient     address     The address of the wallet to move tokens to
    * @param percentage     uint        The percentage of the total supply of tokens to move
    * @return success       bool        Returns true if executed successfully
    */
    function distribute (address _recipient, uint percentage) private returns (bool) {
        uint256 tokens = totalSupply / (hundredPercent / percentage);

        balances[owner] = balances[owner].sub(tokens);
        balances[_recipient] = balances[_recipient].add(tokens);
        Transfer(0, _recipient, tokens);
    }

    /*****
    * @dev Check the PartnerSale state of the contract
    * @return bool  Return true if the contract is in the PartnerSale state
    */
    function isStatePartnerSale () private constant returns (bool) {
        return state == SaleState.PartnerSale;
    }

    /*****
    * @dev Check the PreSale state of the contract
    * @return bool  Return true if the contract is in the PreSale state
    */
    function isStatePreSale () private constant returns (bool) {
        return state == SaleState.PreSale;
    }

    /*****
    * @dev Check the PublicSale state of the contract
    * @return bool  Return true if the contract is in the PublicSale state
    */
    function isStatePublicSale () private constant returns (bool) {
        return state == SaleState.PublicSale;
    }
}