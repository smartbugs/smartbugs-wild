pragma solidity ^0.4.17;

contract J8TTokenConfig {
    // The J8T decimals
    uint8 public constant TOKEN_DECIMALS = 8;

    // The J8T decimal factor to obtain luckys
    uint256 public constant J8T_DECIMALS_FACTOR = 10**uint256(TOKEN_DECIMALS);
}

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

/**
 * @title Burnable Token
 * @dev Token that can be irreversibly burned (destroyed).
 */
contract BurnableToken is StandardToken {

    event Burn(address indexed burner, uint256 value);

    /**
     * @dev Burns a specific amount of tokens.
     * @param _value The amount of token to be burned.
     */
    function burn(uint256 _value) public {
        require(_value > 0);

        address burner = msg.sender;
        balances[burner] = balances[burner].sub(_value);
        totalSupply = totalSupply.sub(_value);
        Burn(burner, _value);
    }
}

//////////////////////////////////////////////////////////////////////
// @title J8T Token                                                 //
// @dev ERC20 J8T Token                                             //
//                                                                  //
// J8T Tokens are divisible by 1e8 (100,000,000) base               //
//                                                                  //
// J8T are displayed using 8 decimal places of precision.           //
//                                                                  //
// 1 J8T is equivalent to 100000000 luckys:                         //
//   100000000 == 1 * 10**8 == 1e8 == One Hundred Million luckys    //
//                                                                  //
// 1,5 Billion J8T (total supply) is equivalent to:                 //
//   150000000000000000 == 1500000000 * 10**8 == 1,5e17 luckys      //
//                                                                  //
//////////////////////////////////////////////////////////////////////

contract J8TToken is J8TTokenConfig, BurnableToken, Ownable {
    string public constant name            = "J8T Token";
    string public constant symbol          = "J8T";
    uint256 public constant decimals       = TOKEN_DECIMALS;
    uint256 public constant INITIAL_SUPPLY = 1500000000 * (10 ** uint256(decimals));

    event Transfer(address indexed _from, address indexed _to, uint256 _value);

    function J8TToken() {
        totalSupply = INITIAL_SUPPLY;
        balances[msg.sender] = INITIAL_SUPPLY;

        //https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20.md#transfer-1
        //EIP 20: A token contract which creates new tokens SHOULD trigger a
        //Transfer event with the _from address set to 0x0
        //when tokens are created.
        Transfer(0x0, msg.sender, INITIAL_SUPPLY);
     }
}


contract ACLManaged is Ownable {
    
    ///////////////////////////
    // ACLManaged PROPERTIES //
    ///////////////////////////

    // The operational acl address
    address public opsAddress;

    // The admin acl address
    address public adminAddress;

    ////////////////////////////////////////
    // ACLManaged FUNCTIONS and MODIFIERS //
    ////////////////////////////////////////

    function ACLManaged() public Ownable() {}

    // Updates the opsAddress propety with the new _opsAddress value
    function setOpsAddress(address _opsAddress) external onlyOwner returns (bool) {
        require(_opsAddress != address(0));
        require(_opsAddress != address(this));

        opsAddress = _opsAddress;
        return true;
    }

    // Updates the adminAddress propety with the new _adminAddress value
    function setAdminAddress(address _adminAddress) external onlyOwner returns (bool) {
        require(_adminAddress != address(0));
        require(_adminAddress != address(this));

        adminAddress = _adminAddress;
        return true;
    }

    //Checks if an address is owner
    function isOwner(address _address) public view returns (bool) {
        bool result = (_address == owner);
        return result;
    }

    //Checks if an address is operator
    function isOps(address _address) public view returns (bool) {
        bool result = (_address == opsAddress);
        return result;
    }

    //Checks if an address is ops or admin
    function isOpsOrAdmin(address _address) public view returns (bool) {
        bool result = (_address == opsAddress || _address == adminAddress);
        return result;
    }

    //Checks if an address is ops,owner or admin
    function isOwnerOrOpsOrAdmin(address _address) public view returns (bool) {
        bool result = (_address == opsAddress || _address == adminAddress || _address == owner);
        return result;
    }

    //Checks whether the msg.sender address is equal to the adminAddress property or not
    modifier onlyAdmin() {
        //Needs to be set. Default constructor will set 0x0;
        address _address = msg.sender;
        require(_address != address(0));
        require(_address == adminAddress);
        _;
    }

    // Checks whether the msg.sender address is equal to the opsAddress property or not
    modifier onlyOps() {
        //Needs to be set. Default constructor will set 0x0;
        address _address = msg.sender;
        require(_address != address(0));
        require(_address == opsAddress);
        _;
    }

    // Checks whether the msg.sender address is equal to the opsAddress or adminAddress property
    modifier onlyAdminAndOps() {
        //Needs to be set. Default constructor will set 0x0;
        address _address = msg.sender;
        require(_address != address(0));
        require(_address == opsAddress || _address == adminAddress);
        _;
    }
}

contract CrowdsaleConfig is J8TTokenConfig {
    using SafeMath for uint256;

    // Default start token sale date is 28th February 15:00 SGP 2018
    uint256 public constant START_TIMESTAMP = 1519801200;

    // Default end token sale date is 14th March 15:00 SGP 2018
    uint256 public constant END_TIMESTAMP   = 1521010800;

    // The ETH decimal factor to obtain weis
    uint256 public constant ETH_DECIMALS_FACTOR = 10**uint256(18);

    // The token sale supply 
    uint256 public constant TOKEN_SALE_SUPPLY = 450000000 * J8T_DECIMALS_FACTOR;

    // The minimum contribution amount in weis
    uint256 public constant MIN_CONTRIBUTION_WEIS = 0.1 ether;

    // The maximum contribution amount in weis
    uint256 public constant MAX_CONTRIBUTION_WEIS = 10 ether;

    //@WARNING: WORKING WITH KILO-MULTIPLES TO AVOID IMPOSSIBLE DIVISIONS OF FLOATING POINTS.
    uint256 constant dollar_per_kilo_token = 100; //0.1 dollar per token
    uint256 public constant dollars_per_kilo_ether = 900000; //900$ per ether
    //TOKENS_PER_ETHER = dollars_per_ether / dollar_per_token
    uint256 public constant INITIAL_TOKENS_PER_ETHER = dollars_per_kilo_ether.div(dollar_per_kilo_token);
}

contract Ledger is ACLManaged {
    
    using SafeMath for uint256;

    ///////////////////////
    // Ledger PROPERTIES //
    ///////////////////////

    // The Allocation struct represents a token sale purchase
    // amountGranted is the amount of tokens purchased
    // hasClaimedBonusTokens whether the allocation has been alredy claimed
    struct Allocation {
        uint256 amountGranted;
        uint256 amountBonusGranted;
        bool hasClaimedBonusTokens;
    }

    // ContributionPhase enum cases are
    // PreSaleContribution, the contribution has been made in the presale phase
    // PartnerContribution, the contribution has been made in the private phase
    enum ContributionPhase {
        PreSaleContribution, PartnerContribution
    }

    // Map of adresses that purchased tokens on the presale phase
    mapping(address => Allocation) public presaleAllocations;

    // Map of adresses that purchased tokens on the private phase
    mapping(address => Allocation) public partnerAllocations;

    // Reference to the J8TToken contract
    J8TToken public tokenContract;

    // Reference to the Crowdsale contract
    Crowdsale public crowdsaleContract;

    // Total private allocation, counting the amount of tokens from the
    // partner and the presale phase
    uint256 public totalPrivateAllocation;

    // Whether the token allocations can be claimed on the partner sale phase
    bool public canClaimPartnerTokens;

    // Whether the token allocations can be claimed on the presale sale phase
    bool public canClaimPresaleTokens;

    // Whether the bonus token allocations can be claimed
    bool public canClaimPresaleBonusTokensPhase1;
    bool public canClaimPresaleBonusTokensPhase2;

    // Whether the bonus token allocations can be claimed
    bool public canClaimPartnerBonusTokensPhase1;
    bool public canClaimPartnerBonusTokensPhase2;

    ///////////////////
    // Ledger EVENTS //
    ///////////////////

    // Triggered when an allocation has been granted
    event AllocationGranted(address _contributor, uint256 _amount, uint8 _phase);

    // Triggered when an allocation has been revoked
    event AllocationRevoked(address _contributor, uint256 _amount, uint8 _phase);

    // Triggered when an allocation has been claimed
    event AllocationClaimed(address _contributor, uint256 _amount);

    // Triggered when a bonus allocation has been claimed
    event AllocationBonusClaimed(address _contributor, uint256 _amount);

    // Triggered when crowdsale contract updated
    event CrowdsaleContractUpdated(address _who, address _old_address, address _new_address);

    //Triggered when any can claim token boolean is updated. _type param indicates which is updated.
    event CanClaimTokensUpdated(address _who, string _type, bool _oldCanClaim, bool _newCanClaim);

    //////////////////////
    // Ledger FUNCTIONS //
    //////////////////////

    // Ledger constructor
    // Sets default values for canClaimPresaleTokens and canClaimPartnerTokens properties
    function Ledger(J8TToken _tokenContract) public {
        require(address(_tokenContract) != address(0));
        tokenContract = _tokenContract;
        canClaimPresaleTokens = false;
        canClaimPartnerTokens = false;
        canClaimPresaleBonusTokensPhase1 = false;
        canClaimPresaleBonusTokensPhase2 = false;
        canClaimPartnerBonusTokensPhase1 = false;
        canClaimPartnerBonusTokensPhase2 = false;
    }

    function () external payable {
        claimTokens();
    }

    // Revokes an allocation from the contributor with address _contributor
    // Deletes the allocation from the corresponding mapping property and transfers
    // the total amount of tokens of the allocation back to the Crowdsale contract
    function revokeAllocation(address _contributor, uint8 _phase) public onlyAdminAndOps payable returns (uint256) {
        require(_contributor != address(0));
        require(_contributor != address(this));

        // Can't revoke  an allocation if the contribution phase is not in the ContributionPhase enum
        ContributionPhase _contributionPhase = ContributionPhase(_phase);
        require(_contributionPhase == ContributionPhase.PreSaleContribution ||
                _contributionPhase == ContributionPhase.PartnerContribution);

        uint256 grantedAllocation = 0;

        // Deletes the allocation from the respective mapping
        if (_contributionPhase == ContributionPhase.PreSaleContribution) {
            grantedAllocation = presaleAllocations[_contributor].amountGranted.add(presaleAllocations[_contributor].amountBonusGranted);
            delete presaleAllocations[_contributor];
        } else if (_contributionPhase == ContributionPhase.PartnerContribution) {
            grantedAllocation = partnerAllocations[_contributor].amountGranted.add(partnerAllocations[_contributor].amountBonusGranted);
            delete partnerAllocations[_contributor];
        }

        // The granted amount allocation must be less that the current token supply on the contract
        uint256 currentSupply = tokenContract.balanceOf(address(this));
        require(grantedAllocation <= currentSupply);

        // Updates the total private allocation substracting the amount of tokens that has been revoked
        require(grantedAllocation <= totalPrivateAllocation);
        totalPrivateAllocation = totalPrivateAllocation.sub(grantedAllocation);
        
        // We sent back the amount of tokens that has been revoked to the corwdsale contract
        require(tokenContract.transfer(address(crowdsaleContract), grantedAllocation));

        AllocationRevoked(_contributor, grantedAllocation, _phase);

        return grantedAllocation;

    }

    // Adds a new allocation for the contributor with address _contributor
    function addAllocation(address _contributor, uint256 _amount, uint256 _bonus, uint8 _phase) public onlyAdminAndOps returns (bool) {
        require(_contributor != address(0));
        require(_contributor != address(this));

        // Can't create or update an allocation if the amount of tokens to be allocated is not greater than zero
        require(_amount > 0);

        // Can't create an allocation if the contribution phase is not in the ContributionPhase enum
        ContributionPhase _contributionPhase = ContributionPhase(_phase);
        require(_contributionPhase == ContributionPhase.PreSaleContribution ||
                _contributionPhase == ContributionPhase.PartnerContribution);


        uint256 totalAmount = _amount.add(_bonus);
        uint256 totalGrantedAllocation = 0;
        uint256 totalGrantedBonusAllocation = 0;

        // Fetch the allocation from the respective mapping and updates the granted amount of tokens
        if (_contributionPhase == ContributionPhase.PreSaleContribution) {
            totalGrantedAllocation = presaleAllocations[_contributor].amountGranted.add(_amount);
            totalGrantedBonusAllocation = presaleAllocations[_contributor].amountBonusGranted.add(_bonus);
            presaleAllocations[_contributor] = Allocation(totalGrantedAllocation, totalGrantedBonusAllocation, false);
        } else if (_contributionPhase == ContributionPhase.PartnerContribution) {
            totalGrantedAllocation = partnerAllocations[_contributor].amountGranted.add(_amount);
            totalGrantedBonusAllocation = partnerAllocations[_contributor].amountBonusGranted.add(_bonus);
            partnerAllocations[_contributor] = Allocation(totalGrantedAllocation, totalGrantedBonusAllocation, false);
        }

        // Updates the contract data
        totalPrivateAllocation = totalPrivateAllocation.add(totalAmount);

        AllocationGranted(_contributor, totalAmount, _phase);

        return true;
    }

    // The claimTokens() function handles the contribution token claim.
    // Tokens can only be claimed after we open this phase.
    // The lockouts periods are defined by the foundation.
    // There are 2 different lockouts:
    //      Presale lockout
    //      Partner lockout
    //
    // A contributor that has contributed in all the phases can claim
    // all its tokens, but only the ones that are accesible to claim
    // be transfered.
    // 
    // A contributor can claim its tokens after each phase has been opened
    function claimTokens() public payable returns (bool) {
        require(msg.sender != address(0));
        require(msg.sender != address(this));

        uint256 amountToTransfer = 0;

        // We need to check if the contributor has made a contribution on each
        // phase, presale and partner
        Allocation storage presaleA = presaleAllocations[msg.sender];
        if (presaleA.amountGranted > 0 && canClaimPresaleTokens) {
            amountToTransfer = amountToTransfer.add(presaleA.amountGranted);
            presaleA.amountGranted = 0;
        }

        Allocation storage partnerA = partnerAllocations[msg.sender];
        if (partnerA.amountGranted > 0 && canClaimPartnerTokens) {
            amountToTransfer = amountToTransfer.add(partnerA.amountGranted);
            partnerA.amountGranted = 0;
        }

        // The amount to transfer must greater than zero
        require(amountToTransfer > 0);

        // The amount to transfer must be less or equal to the current supply
        uint256 currentSupply = tokenContract.balanceOf(address(this));
        require(amountToTransfer <= currentSupply);
        
        // Transfer the token allocation to contributor
        require(tokenContract.transfer(msg.sender, amountToTransfer));
        AllocationClaimed(msg.sender, amountToTransfer);
    
        return true;
    }

    function claimBonus() external payable returns (bool) {
        require(msg.sender != address(0));
        require(msg.sender != address(this));

        uint256 amountToTransfer = 0;

        // BONUS PHASE 1
        Allocation storage presale = presaleAllocations[msg.sender];
        if (presale.amountBonusGranted > 0 && !presale.hasClaimedBonusTokens && canClaimPresaleBonusTokensPhase1) {
            uint256 amountPresale = presale.amountBonusGranted.div(2);
            amountToTransfer = amountPresale;
            presale.amountBonusGranted = amountPresale;
            presale.hasClaimedBonusTokens = true;
        }

        Allocation storage partner = partnerAllocations[msg.sender];
        if (partner.amountBonusGranted > 0 && !partner.hasClaimedBonusTokens && canClaimPartnerBonusTokensPhase1) {
            uint256 amountPartner = partner.amountBonusGranted.div(2);
            amountToTransfer = amountToTransfer.add(amountPartner);
            partner.amountBonusGranted = amountPartner;
            partner.hasClaimedBonusTokens = true;
        }

        // BONUS PHASE 2
        if (presale.amountBonusGranted > 0 && canClaimPresaleBonusTokensPhase2) {
            amountToTransfer = amountToTransfer.add(presale.amountBonusGranted);
            presale.amountBonusGranted = 0;
        }

        if (partner.amountBonusGranted > 0 && canClaimPartnerBonusTokensPhase2) {
            amountToTransfer = amountToTransfer.add(partner.amountBonusGranted);
            partner.amountBonusGranted = 0;
        }

        // The amount to transfer must greater than zero
        require(amountToTransfer > 0);

        // The amount to transfer must be less or equal to the current supply
        uint256 currentSupply = tokenContract.balanceOf(address(this));
        require(amountToTransfer <= currentSupply);
        
        // Transfer the token allocation to contributor
        require(tokenContract.transfer(msg.sender, amountToTransfer));
        AllocationBonusClaimed(msg.sender, amountToTransfer);

        return true;
    }

    // Updates the canClaimPresaleTokens propety with the new _canClaimTokens value
    function setCanClaimPresaleTokens(bool _canClaimTokens) external onlyAdmin returns (bool) {
        bool _oldCanClaim = canClaimPresaleTokens;
        canClaimPresaleTokens = _canClaimTokens;
        CanClaimTokensUpdated(msg.sender, 'canClaimPresaleTokens', _oldCanClaim, _canClaimTokens);
        return true;
    }

    // Updates the canClaimPartnerTokens property with the new _canClaimTokens value
    function setCanClaimPartnerTokens(bool _canClaimTokens) external onlyAdmin returns (bool) {
        bool _oldCanClaim = canClaimPartnerTokens;
        canClaimPartnerTokens = _canClaimTokens;
        CanClaimTokensUpdated(msg.sender, 'canClaimPartnerTokens', _oldCanClaim, _canClaimTokens);
        return true;
    }

    // Updates the canClaimBonusTokens property with the new _canClaimTokens value
    function setCanClaimPresaleBonusTokensPhase1(bool _canClaimTokens) external onlyAdmin returns (bool) {
        bool _oldCanClaim = canClaimPresaleBonusTokensPhase1;
        canClaimPresaleBonusTokensPhase1 = _canClaimTokens;
        CanClaimTokensUpdated(msg.sender, 'canClaimPresaleBonusTokensPhase1', _oldCanClaim, _canClaimTokens);
        return true;
    }

    // Updates the canClaimBonusTokens property with the new _canClaimTokens value
    function setCanClaimPresaleBonusTokensPhase2(bool _canClaimTokens) external onlyAdmin returns (bool) {
        bool _oldCanClaim = canClaimPresaleBonusTokensPhase2;
        canClaimPresaleBonusTokensPhase2 = _canClaimTokens;
        CanClaimTokensUpdated(msg.sender, 'canClaimPresaleBonusTokensPhase2', _oldCanClaim, _canClaimTokens);
        return true;
    }

    // Updates the canClaimBonusTokens property with the new _canClaimTokens value
    function setCanClaimPartnerBonusTokensPhase1(bool _canClaimTokens) external onlyAdmin returns (bool) {
        bool _oldCanClaim = canClaimPartnerBonusTokensPhase1;
        canClaimPartnerBonusTokensPhase1 = _canClaimTokens;
        CanClaimTokensUpdated(msg.sender, 'canClaimPartnerBonusTokensPhase1', _oldCanClaim, _canClaimTokens);
        return true;
    }

    // Updates the canClaimBonusTokens property with the new _canClaimTokens value
    function setCanClaimPartnerBonusTokensPhase2(bool _canClaimTokens) external onlyAdmin returns (bool) {
        bool _oldCanClaim = canClaimPartnerBonusTokensPhase2;
        canClaimPartnerBonusTokensPhase2 = _canClaimTokens;
        CanClaimTokensUpdated(msg.sender, 'canClaimPartnerBonusTokensPhase2', _oldCanClaim, _canClaimTokens);
        return true;
    }

    // Updates the crowdsale contract property with the new _crowdsaleContract value
    function setCrowdsaleContract(Crowdsale _crowdsaleContract) public onlyOwner returns (bool) {
        address old_crowdsale_address = crowdsaleContract;

        crowdsaleContract = _crowdsaleContract;

        CrowdsaleContractUpdated(msg.sender, old_crowdsale_address, crowdsaleContract);

        return true;
    }
}

contract Crowdsale is ACLManaged, CrowdsaleConfig {

    using SafeMath for uint256;

    //////////////////////////
    // Crowdsale PROPERTIES //
    //////////////////////////

    // The J8TToken smart contract reference
    J8TToken public tokenContract;

    // The Ledger smart contract reference
    Ledger public ledgerContract;

    // The start token sale date represented as a timestamp
    uint256 public startTimestamp;

    // The end token sale date represented as a timestamp
    uint256 public endTimestamp;

    // Ratio of J8T tokens to per ether
    uint256 public tokensPerEther;

    // The total amount of wei raised in the token sale
    // Including presales (in eth) and public sale
    uint256 public weiRaised;

    // The current total amount of tokens sold in the token sale
    uint256 public totalTokensSold;

    // The minimum and maximum eth contribution accepted in the token sale
    uint256 public minContribution;
    uint256 public maxContribution;

    // The wallet address where the token sale sends all eth contributions
    address public wallet;

    // Controls whether the token sale has finished or not
    bool public isFinalized = false;

    // Map of adresses that requested to purchase tokens
    // Contributors of the token sale are segmented as:
    //  CannotContribute: Cannot contribute in any phase (uint8  - 0)
    //  PreSaleContributor: Can contribute on both pre-sale and pubic sale phases (uint8  - 1)
    //  PublicSaleContributor: Can contribute on he public sale phase (uint8  - 2)
    mapping(address => WhitelistPermission) public whitelist;

    // Map of addresses that has already contributed on the token sale
    mapping(address => bool) public hasContributed;

    enum WhitelistPermission {
        CannotContribute, PreSaleContributor, PublicSaleContributor 
    }

    //////////////////////
    // Crowdsale EVENTS //
    //////////////////////

    // Triggered when a contribution in the public sale has been processed correctly
    event TokensPurchased(address _contributor, uint256 _amount);

    // Triggered when the whitelist has been updated
    event WhiteListUpdated(address _who, address _account, WhitelistPermission _phase);

    // Triggered when the Crowdsale has been created
    event ContractCreated();

    // Triggered when a presale has been added
    // The phase parameter can be a strategic partner contribution or a presale contribution
    event PresaleAdded(address _contributor, uint256 _amount, uint8 _phase);

    // Triggered when the tokensPerEther property has been updated
    event TokensPerEtherUpdated(address _who, uint256 _oldValue, uint256 _newValue);

    // Triggered when the startTimestamp property has been updated
    event StartTimestampUpdated(address _who, uint256 _oldValue, uint256 _newValue);

    // Triggered when the endTimestamp property has been updated
    event EndTimestampUpdated(address _who, uint256 _oldValue, uint256 _newValue);

    // Triggered when the wallet property has been updated
    event WalletUpdated(address _who, address _oldWallet, address _newWallet);

    // Triggered when the minContribution property has been updated
    event MinContributionUpdated(address _who, uint256 _oldValue, uint256 _newValue);

    // Triggered when the maxContribution property has been updated
    event MaxContributionUpdated(address _who, uint256 _oldValue, uint256 _newValue);

    // Triggered when the token sale has finalized
    event Finalized(address _who, uint256 _timestamp);

    // Triggered when the token sale has finalized and there where still token to sale
    // When the token are not sold, we burn them
    event Burned(address _who, uint256 _amount, uint256 _timestamp);

    /////////////////////////
    // Crowdsale FUNCTIONS //
    /////////////////////////
    

    // Crowdsale constructor
    // Takes default values from the CrowdsaleConfig smart contract
    function Crowdsale(
        J8TToken _tokenContract,
        Ledger _ledgerContract,
        address _wallet
    ) public
    {
        uint256 _start            = START_TIMESTAMP;
        uint256 _end              = END_TIMESTAMP;
        uint256 _supply           = TOKEN_SALE_SUPPLY;
        uint256 _min_contribution = MIN_CONTRIBUTION_WEIS;
        uint256 _max_contribution = MAX_CONTRIBUTION_WEIS;
        uint256 _tokensPerEther   = INITIAL_TOKENS_PER_ETHER;

        require(_start > currentTime());
        require(_end > _start);
        require(_tokensPerEther > 0);
        require(address(_tokenContract) != address(0));
        require(address(_ledgerContract) != address(0));
        require(_wallet != address(0));

        ledgerContract   = _ledgerContract;
        tokenContract    = _tokenContract;
        startTimestamp   = _start;
        endTimestamp     = _end;
        tokensPerEther   = _tokensPerEther;
        minContribution = _min_contribution;
        maxContribution = _max_contribution;
        wallet           = _wallet;
        totalTokensSold  = 0;
        weiRaised        = 0;
        isFinalized      = false;  

        ContractCreated();
    }

    // Updates the tokenPerEther propety with the new _tokensPerEther value
    function setTokensPerEther(uint256 _tokensPerEther) external onlyAdmin onlyBeforeSale returns (bool) {
        require(_tokensPerEther > 0);

        uint256 _oldValue = tokensPerEther;
        tokensPerEther = _tokensPerEther;

        TokensPerEtherUpdated(msg.sender, _oldValue, tokensPerEther);
        return true;
    }

    // Updates the startTimestamp propety with the new _start value
    function setStartTimestamp(uint256 _start) external onlyAdmin returns (bool) {
        require(_start < endTimestamp);
        require(_start > currentTime());

        uint256 _oldValue = startTimestamp;
        startTimestamp = _start;

        StartTimestampUpdated(msg.sender, _oldValue, startTimestamp);

        return true;
    }

    // Updates the endTimestamp propety with the new _end value
    function setEndTimestamp(uint256 _end) external onlyAdmin returns (bool) {
        require(_end > startTimestamp);

        uint256 _oldValue = endTimestamp;
        endTimestamp = _end;

        EndTimestampUpdated(msg.sender, _oldValue, endTimestamp);
        
        return true;
    }

    // Updates the wallet propety with the new _newWallet value
    function updateWallet(address _newWallet) external onlyAdmin returns (bool) {
        require(_newWallet != address(0));
        
        address _oldValue = wallet;
        wallet = _newWallet;
        
        WalletUpdated(msg.sender, _oldValue, wallet);
        
        return true;
    }

    // Updates the minContribution propety with the new _newMinControbution value
    function setMinContribution(uint256 _newMinContribution) external onlyAdmin returns (bool) {
        require(_newMinContribution <= maxContribution);

        uint256 _oldValue = minContribution;
        minContribution = _newMinContribution;
        
        MinContributionUpdated(msg.sender, _oldValue, minContribution);
        
        return true;
    }

    // Updates the maxContribution propety with the new _newMaxContribution value
    function setMaxContribution(uint256 _newMaxContribution) external onlyAdmin returns (bool) {
        require(_newMaxContribution > minContribution);

        uint256 _oldValue = maxContribution;
        maxContribution = _newMaxContribution;
        
        MaxContributionUpdated(msg.sender, _oldValue, maxContribution);
        
        return true;
    }

    // Main public function.
    function () external payable {
        purchaseTokens();
    }

    // Revokes a presale allocation from the contributor with address _contributor
    // Updates the totalTokensSold property substracting the amount of tokens that where previously allocated
    function revokePresale(address _contributor, uint8 _contributorPhase) external onlyAdmin returns (bool) {
        require(_contributor != address(0));

        // We can only revoke allocations from pre sale or strategic partners
        // ContributionPhase.PreSaleContribution == 0,  ContributionPhase.PartnerContribution == 1
        require(_contributorPhase == 0 || _contributorPhase == 1);

        uint256 luckys = ledgerContract.revokeAllocation(_contributor, _contributorPhase);
        
        require(luckys > 0);
        require(luckys <= totalTokensSold);
        
        totalTokensSold = totalTokensSold.sub(luckys);
        
        return true;
    }

    // Adds a new presale allocation for the contributor with address _contributor
    // We can only allocate presale before the token sale has been initialized
    function addPresale(address _contributor, uint256 _tokens, uint256 _bonus, uint8 _contributorPhase) external onlyAdminAndOps onlyBeforeSale returns (bool) {
        require(_tokens > 0);
        require(_bonus > 0);

        // Converts the amount of tokens to our smallest J8T value, lucky
        uint256 luckys = _tokens.mul(J8T_DECIMALS_FACTOR);
        uint256 bonusLuckys = _bonus.mul(J8T_DECIMALS_FACTOR);
        uint256 totalTokens = luckys.add(bonusLuckys);

        uint256 availableTokensToPurchase = tokenContract.balanceOf(address(this));
        
        require(totalTokens <= availableTokensToPurchase);

        // Insert the new allocation to the Ledger
        require(ledgerContract.addAllocation(_contributor, luckys, bonusLuckys, _contributorPhase));
        // Transfers the tokens form the Crowdsale contract to the Ledger contract
        require(tokenContract.transfer(address(ledgerContract), totalTokens));

        // Updates totalTokensSold property
        totalTokensSold = totalTokensSold.add(totalTokens);

        // If we reach the total amount of tokens to sell we finilize the token sale
        availableTokensToPurchase = tokenContract.balanceOf(address(this));
        if (availableTokensToPurchase == 0) {
            finalization();
        }

        // Trigger PresaleAdded event
        PresaleAdded(_contributor, totalTokens, _contributorPhase);
    }

    // The purchaseTokens function handles the token purchase flow
    function purchaseTokens() public payable onlyDuringSale returns (bool) {
        address contributor = msg.sender;
        uint256 weiAmount = msg.value;

        // A contributor can only contribute once on the public sale
        require(hasContributed[contributor] == false);
        // The contributor address must be whitelisted in order to be able to purchase tokens
        require(contributorCanContribute(contributor));
        // The weiAmount must be greater or equal than minContribution
        require(weiAmount >= minContribution);
        // The weiAmount cannot be greater than maxContribution
        require(weiAmount <= maxContribution);
        // The availableTokensToPurchase must be greater than 0
        require(totalTokensSold < TOKEN_SALE_SUPPLY);
        uint256 availableTokensToPurchase = TOKEN_SALE_SUPPLY.sub(totalTokensSold);

        // We need to convert the tokensPerEther to luckys (10**8)
        uint256 luckyPerEther = tokensPerEther.mul(J8T_DECIMALS_FACTOR);

        // In order to calculate the tokens amount to be allocated to the contrbutor
        // we need to multiply the amount of wei sent by luckyPerEther and divide the
        // result for the ether decimal factor (10**18)
        uint256 tokensAmount = weiAmount.mul(luckyPerEther).div(ETH_DECIMALS_FACTOR);
        

        uint256 refund = 0;
        uint256 tokensToPurchase = tokensAmount;
        
        // If the token purchase amount is bigger than the remaining token allocation
        // we can only sell the remainging tokens and refund the unused amount of eth
        if (availableTokensToPurchase < tokensAmount) {
            tokensToPurchase = availableTokensToPurchase;
            weiAmount = tokensToPurchase.mul(ETH_DECIMALS_FACTOR).div(luckyPerEther);
            refund = msg.value.sub(weiAmount);
        }

        // We update the token sale contract data
        totalTokensSold = totalTokensSold.add(tokensToPurchase);
        uint256 weiToPurchase = tokensToPurchase.div(tokensPerEther);
        weiRaised = weiRaised.add(weiToPurchase);

        // Transfers the tokens form the Crowdsale contract to contriutors wallet
        require(tokenContract.transfer(contributor, tokensToPurchase));

        // Issue a refund for any unused ether 
        if (refund > 0) {
            contributor.transfer(refund);
        }

        // Transfer ether contribution to the wallet
        wallet.transfer(weiAmount);

        // Update hasContributed mapping
        hasContributed[contributor] = true;

        TokensPurchased(contributor, tokensToPurchase);

        // If we reach the total amount of tokens to sell we finilize the token sale
        if (totalTokensSold == TOKEN_SALE_SUPPLY) {
            finalization();
        }

        return true;
    }

    // Updates the whitelist
    function updateWhitelist(address _account, WhitelistPermission _permission) external onlyAdminAndOps returns (bool) {
        require(_account != address(0));
        require(_permission == WhitelistPermission.PreSaleContributor || _permission == WhitelistPermission.PublicSaleContributor || _permission == WhitelistPermission.CannotContribute);
        require(!saleHasFinished());

        whitelist[_account] = _permission;

        address _who = msg.sender;
        WhiteListUpdated(_who, _account, _permission);

        return true;
    }

    function updateWhitelist_batch(address[] _accounts, WhitelistPermission _permission) external onlyAdminAndOps returns (bool) {
        require(_permission == WhitelistPermission.PreSaleContributor || _permission == WhitelistPermission.PublicSaleContributor || _permission == WhitelistPermission.CannotContribute);
        require(!saleHasFinished());

        for(uint i = 0; i < _accounts.length; ++i) {
            require(_accounts[i] != address(0));
            whitelist[_accounts[i]] = _permission;
            WhiteListUpdated(msg.sender, _accounts[i], _permission);
        }

        return true;
    }

    // Checks that the status of an address account
    // Contributors of the token sale are segmented as:
    //  PreSaleContributor: Can contribute on both pre-sale and pubic sale phases
    //  PublicSaleContributor: Can contribute on he public sale phase
    //  CannotContribute: Cannot contribute in any phase
    function contributorCanContribute(address _contributorAddress) private view returns (bool) {
        WhitelistPermission _contributorPhase = whitelist[_contributorAddress];

        if (_contributorPhase == WhitelistPermission.CannotContribute) {
            return false;
        }

        if (_contributorPhase == WhitelistPermission.PreSaleContributor || 
            _contributorPhase == WhitelistPermission.PublicSaleContributor) {
            return true;
        }

        return false;
    }

    // Returns the current time
    function currentTime() public view returns (uint256) {
        return now;
    }

    // Checks if the sale has finished
    function saleHasFinished() public view returns (bool) {
        if (isFinalized) {
            return true;
        }

        if (endTimestamp < currentTime()) {
            return true;
        }

        if (totalTokensSold == TOKEN_SALE_SUPPLY) {
            return true;
        }

        return false;
    }

    modifier onlyBeforeSale() {
        require(currentTime() < startTimestamp);
        _;
    }

    modifier onlyDuringSale() {
        uint256 _currentTime = currentTime();
        require(startTimestamp < _currentTime);
        require(_currentTime < endTimestamp);
        _;
    }

    modifier onlyPostSale() {
        require(endTimestamp < currentTime());
        _;
    }

    ///////////////////////
    // PRIVATE FUNCTIONS //
    ///////////////////////

    // This method is for to be called only for the owner. This way we protect for anyone who wanna finalize the ICO.
    function finalize() external onlyAdmin returns (bool) {
        return finalization();
    }

    // Only used by finalize and setFinalized.
    // Overloaded logic for two uses.
    // NOTE: In case finalize is called by an user and not from addPresale()/purchaseToken()
    // will diff total supply with sold supply to burn token.
    function finalization() private returns (bool) {
        require(!isFinalized);

        isFinalized = true;

        
        if (totalTokensSold < TOKEN_SALE_SUPPLY) {
            uint256 toBurn = TOKEN_SALE_SUPPLY.sub(totalTokensSold);
            tokenContract.burn(toBurn);
            Burned(msg.sender, toBurn, currentTime());
        }

        Finalized(msg.sender, currentTime());

        return true;
    }

    function saleSupply() public view returns (uint256) {
        return tokenContract.balanceOf(address(this));
    }
}