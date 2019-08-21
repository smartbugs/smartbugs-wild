pragma solidity ^0.4.17;

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    assert(c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
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
  function Ownable() public {
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
  function transferOwnership(address newOwner) public onlyOwner {
    require(newOwner != address(0));
    OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }

}



/**
 * @title Pausable
 * @dev Base contract which allows children to implement an emergency stop mechanism.
 */
contract Pausable is Ownable {
  event Pause();
  event Unpause();

  bool public paused = false;


  /**
   * @dev Modifier to make a function callable only when the contract is not paused.
   */
  modifier whenNotPaused() {
    require(!paused);
    _;
  }

  /**
   * @dev Modifier to make a function callable only when the contract is paused.
   */
  modifier whenPaused() {
    require(paused);
    _;
  }

  /**
   * @dev called by the owner to pause, triggers stopped state
   */
  function pause() onlyOwner whenNotPaused public {
    paused = true;
    Pause();
  }

  /**
   * @dev called by the owner to unpause, returns to normal state
   */
  function unpause() onlyOwner whenPaused public {
    paused = false;
    Unpause();
  }
}


/**
 * @title ERC20Basic
 * @dev Simpler version of ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/179
 */
contract ERC20Basic {
    uint256 public totalSupply;
    mapping(address => uint256) balances;
    function balanceOf(address _owner) public constant returns (uint256) { return balances[_owner]; }
    // Transfer is disabled for users, as these are PreSale tokens
    //function transfer(address to, uint256 value) public returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
}

/**
* @title Gimmer PreSale Smart Contract
* @author lucas@gimmer.net, jitendra@chittoda.com
*/
contract GimmerPreSale is ERC20Basic, Pausable {
    using SafeMath for uint256;

    /**
    * @dev Supporter structure, which allows us to track
    * how much the user has bought so far, and if he's flagged as known
    */
    struct Supporter {
        uint256 weiSpent;   // the total amount of Wei this address has sent to this contract
        bool hasKYC;        // if the user has KYC flagged
    }

    mapping(address => Supporter) public supportersMap; // Mapping with all the campaign supporters
    address public fundWallet;      // Address to forward all Ether to
    address public kycManager;      // Address that manages approval of KYC
    uint256 public tokensSold;      // How many tokens sold in PreSale
    uint256 public weiRaised;       // amount of raised money in wei

    uint256 public constant ONE_MILLION = 1000000;
    // Maximum amount that can be sold during the Pre Sale period
    uint256 public constant PRE_SALE_GMRP_TOKEN_CAP = 15 * ONE_MILLION * 1 ether; //15 Million GMRP Tokens

    /* Allowed Contribution in Ether */
    uint256 public constant PRE_SALE_30_ETH     = 30 ether;  // Minimum 30 Ether to get 25% Bonus Tokens
    uint256 public constant PRE_SALE_300_ETH    = 300 ether; // Minimum 300 Ether to get 30% Bonus Tokens
    uint256 public constant PRE_SALE_3000_ETH   = 3000 ether;// Minimum 3000 Ether to get 40% Bonus Tokens

    /* Bonus Tokens based on the ETH Contributed in single transaction */
    uint256 public constant TOKEN_RATE_25_PERCENT_BONUS = 1250; // 25% Bonus Tokens, when >= 30 ETH & < 300 ETH
    uint256 public constant TOKEN_RATE_30_PERCENT_BONUS = 1300; // 30% Bonus Tokens, when >= 300 ETH & < 3000 ETH
    uint256 public constant TOKEN_RATE_40_PERCENT_BONUS = 1400; // 40% Bonus Tokens, when >= 3000 ETH

    /* start and end timestamps where investments are allowed (both inclusive) */
    uint256 public constant START_TIME  = 1511524800;   //GMT: Friday, 24 November 2017 12:00:00
    uint256 public constant END_TIME    = 1514894400;   //GMT: Tuesday, 2 January  2018 12:00:00

    /* Token metadata */
    string public constant name = "GimmerPreSale Token";
    string public constant symbol = "GMRP";
    uint256 public constant decimals = 18;

    /**
    * @dev Modifier to only allow KYCManager
    */
    modifier onlyKycManager() {
        require(msg.sender == kycManager);
        _;
    }

    /**
    * Event for token purchase logging
    * @param purchaser  who bought the tokens
    * @param value      weis paid for purchase
    * @param amount     amount of tokens purchased
    */
    event TokenPurchase(address indexed purchaser, uint256 value, uint256 amount);

    /**
    * Event for minting new tokens
    * @param to         The person that received tokens
    * @param amount     Amount of tokens received
    */
    event Mint(address indexed to, uint256 amount);

    /**
     * Event to log a user is approved or disapproved
     * @param user          User who has been approved/disapproved
     * @param isApproved    true : User is approved, false : User is disapproved
     */
    event KYC(address indexed user, bool isApproved);

    /**
     * Constructor
     * @param _fundWallet           Address to forward all received Ethers to
     * @param _kycManagerWallet     KYC Manager wallet to approve / disapprove user's KYC
     */
    function GimmerPreSale(address _fundWallet, address _kycManagerWallet) public {
        require(_fundWallet != address(0));
        require(_kycManagerWallet != address(0));

        fundWallet = _fundWallet;
        kycManager = _kycManagerWallet;
    }

    /* fallback function can be used to buy tokens */
    function () whenNotPaused public payable {
        buyTokens();
    }

    /* @return true if the transaction can buy tokens, otherwise false */
    function validPurchase() internal constant returns (bool) {
        bool withinPeriod = now >= START_TIME && now <= END_TIME;
        bool higherThanMin30ETH = msg.value >= PRE_SALE_30_ETH;
        return withinPeriod && higherThanMin30ETH;
    }

    /* low level token purchase function */
    function buyTokens() whenNotPaused public payable {
        address sender = msg.sender;

        // make sure the user buying tokens has KYC
        require(userHasKYC(sender));
        require(validPurchase());

        // calculate token amount to be created
        uint256 weiAmountSent = msg.value;
        uint256 rate = getRate(weiAmountSent);
        uint256 newTokens = weiAmountSent.mul(rate);

        // look if we have not yet reached the cap
        uint256 totalTokensSold = tokensSold.add(newTokens);
        require(totalTokensSold <= PRE_SALE_GMRP_TOKEN_CAP);

        // update supporter state
        Supporter storage sup = supportersMap[sender];
        uint256 totalWei = sup.weiSpent.add(weiAmountSent);
        sup.weiSpent = totalWei;

        // update contract state
        weiRaised = weiRaised.add(weiAmountSent);
        tokensSold = totalTokensSold;

        // finally mint the coins
        mint(sender, newTokens);
        TokenPurchase(sender, weiAmountSent, newTokens);

        // and forward the funds to the wallet
        forwardFunds();
    }

    /**
     * returns the rate the user will be paying at,
     * based on the amount of wei sent to the contract
     */
    function getRate(uint256 weiAmount) public pure returns (uint256) {
        if (weiAmount >= PRE_SALE_3000_ETH) {
            return TOKEN_RATE_40_PERCENT_BONUS;
        } else if(weiAmount >= PRE_SALE_300_ETH) {
            return TOKEN_RATE_30_PERCENT_BONUS;
        } else if(weiAmount >= PRE_SALE_30_ETH) {
            return TOKEN_RATE_25_PERCENT_BONUS;
        } else {
            return 0;
        }
    }

    /**
     * send ether to the fund collection wallet
     * override to create custom fund forwarding mechanisms
     */
    function forwardFunds() internal {
        fundWallet.transfer(msg.value);
    }

    // @return true if crowdsale event has ended
    function hasEnded() public constant returns (bool) {
        return now > END_TIME;
    }

    /**
    * @dev Approves an User's KYC
    * @param _user The user to flag as known
    */
    function approveUserKYC(address _user) onlyKycManager public {
        Supporter storage sup = supportersMap[_user];
        sup.hasKYC = true;
        KYC(_user, true);
    }

    /**
     * @dev Disapproves an User's KYC
     * @param _user The user to flag as unknown / suspecious
     */
    function disapproveUserKYC(address _user) onlyKycManager public {
        Supporter storage sup = supportersMap[_user];
        sup.hasKYC = false;
        KYC(_user, false);
    }

    /**
    * @dev Changes the KYC manager to a new address
    * @param _newKYCManager The new address that will be managing KYC approval
    */
    function setKYCManager(address _newKYCManager) onlyOwner public {
        require(_newKYCManager != address(0));
        kycManager = _newKYCManager;
    }

    /**
    * @dev Returns if an users has KYC approval or not
    * @return A boolean representing the user's KYC status
    */
    function userHasKYC(address _user) public constant returns (bool) {
        return supportersMap[_user].hasKYC;
    }

    /**
     * @dev Returns the weiSpent of a user
     */
    function userWeiSpent(address _user) public constant returns (uint256) {
        return supportersMap[_user].weiSpent;
    }

    /**
    * @dev Function to mint tokens
    * @param _to The address that will receive the minted tokens.
    * @param _amount The amount of tokens to mint.
    * @return A boolean that indicates if the operation was successful.
    */
    function mint(address _to, uint256 _amount) internal returns (bool) {
        totalSupply = totalSupply.add(_amount);
        balances[_to] = balances[_to].add(_amount);
        Mint(_to, _amount);
        Transfer(0x0, _to, _amount);
        return true;
    }
}