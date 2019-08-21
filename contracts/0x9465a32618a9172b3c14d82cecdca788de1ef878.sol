pragma solidity ^0.4.21;

// File: contracts/ReinvestProxy.sol

/*
 * Visit: https://p4rty.io
 * Discord: https://discord.gg/7y3DHYF
 * Copyright Mako Labs LLC 2018 All Rights Reseerved
*/
interface ReinvestProxy {

    /// @dev Converts all incoming ethereum to tokens for the caller,
    function reinvestFor(address customer) external payable;

}

// File: openzeppelin-solidity/contracts/math/Math.sol

/**
 * @title Math
 * @dev Assorted math operations
 */
library Math {
  function max64(uint64 a, uint64 b) internal pure returns (uint64) {
    return a >= b ? a : b;
  }

  function min64(uint64 a, uint64 b) internal pure returns (uint64) {
    return a < b ? a : b;
  }

  function max256(uint256 a, uint256 b) internal pure returns (uint256) {
    return a >= b ? a : b;
  }

  function min256(uint256 a, uint256 b) internal pure returns (uint256) {
    return a < b ? a : b;
  }
}

// File: openzeppelin-solidity/contracts/math/SafeMath.sol

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {

  /**
  * @dev Multiplies two numbers, throws on overflow.
  */
  function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
    if (a == 0) {
      return 0;
    }
    c = a * b;
    assert(c / a == b);
    return c;
  }

  /**
  * @dev Integer division of two numbers, truncating the quotient.
  */
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    // uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return a / b;
  }

  /**
  * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
  */
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  /**
  * @dev Adds two numbers, throws on overflow.
  */
  function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
    c = a + b;
    assert(c >= a);
    return c;
  }
}

// File: openzeppelin-solidity/contracts/ownership/Ownable.sol

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
  constructor() public {
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
    emit OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }

}

// File: openzeppelin-solidity/contracts/ownership/Whitelist.sol

/**
 * @title Whitelist
 * @dev The Whitelist contract has a whitelist of addresses, and provides basic authorization control functions.
 * @dev This simplifies the implementation of "user permissions".
 */
contract Whitelist is Ownable {
  mapping(address => bool) public whitelist;

  event WhitelistedAddressAdded(address addr);
  event WhitelistedAddressRemoved(address addr);

  /**
   * @dev Throws if called by any account that's not whitelisted.
   */
  modifier onlyWhitelisted() {
    require(whitelist[msg.sender]);
    _;
  }

  /**
   * @dev add an address to the whitelist
   * @param addr address
   * @return true if the address was added to the whitelist, false if the address was already in the whitelist
   */
  function addAddressToWhitelist(address addr) onlyOwner public returns(bool success) {
    if (!whitelist[addr]) {
      whitelist[addr] = true;
      emit WhitelistedAddressAdded(addr);
      success = true;
    }
  }

  /**
   * @dev add addresses to the whitelist
   * @param addrs addresses
   * @return true if at least one address was added to the whitelist,
   * false if all addresses were already in the whitelist
   */
  function addAddressesToWhitelist(address[] addrs) onlyOwner public returns(bool success) {
    for (uint256 i = 0; i < addrs.length; i++) {
      if (addAddressToWhitelist(addrs[i])) {
        success = true;
      }
    }
  }

  /**
   * @dev remove an address from the whitelist
   * @param addr address
   * @return true if the address was removed from the whitelist,
   * false if the address wasn't in the whitelist in the first place
   */
  function removeAddressFromWhitelist(address addr) onlyOwner public returns(bool success) {
    if (whitelist[addr]) {
      whitelist[addr] = false;
      emit WhitelistedAddressRemoved(addr);
      success = true;
    }
  }

  /**
   * @dev remove addresses from the whitelist
   * @param addrs addresses
   * @return true if at least one address was removed from the whitelist,
   * false if all addresses weren't in the whitelist in the first place
   */
  function removeAddressesFromWhitelist(address[] addrs) onlyOwner public returns(bool success) {
    for (uint256 i = 0; i < addrs.length; i++) {
      if (removeAddressFromWhitelist(addrs[i])) {
        success = true;
      }
    }
  }

}

// File: openzeppelin-solidity/contracts/token/ERC20/ERC20Basic.sol

/**
 * @title ERC20Basic
 * @dev Simpler version of ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/179
 */
contract ERC20Basic {
  function totalSupply() public view returns (uint256);
  function balanceOf(address who) public view returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}

// File: openzeppelin-solidity/contracts/token/ERC20/ERC20.sol

/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender) public view returns (uint256);
  function transferFrom(address from, address to, uint256 value) public returns (bool);
  function approve(address spender, uint256 value) public returns (bool);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}

// File: contracts/P4RTYDaoVault.sol

/*
 * Visit: https://p4rty.io
 * Discord: https://discord.gg/7y3DHYF
*/

contract P4RTYDaoVault is Whitelist {


    /*=================================
    =            MODIFIERS            =
    =================================*/

    /// @dev Only people with profits
    modifier onlyDivis {
        require(myDividends() > 0);
        _;
    }


    /*==============================
    =            EVENTS            =
    ==============================*/

    event onStake(
        address indexed customerAddress,
        uint256 stakedTokens,
        uint256 timestamp
    );

    event onDeposit(
        address indexed fundingSource,
        uint256 ethDeposited,
        uint    timestamp
    );

    event onWithdraw(
        address indexed customerAddress,
        uint256 ethereumWithdrawn,
        uint timestamp
    );

    event onReinvestmentProxy(
        address indexed customerAddress,
        address indexed destinationAddress,
        uint256 ethereumReinvested
    );




    /*=====================================
    =            CONFIGURABLES            =
    =====================================*/


    uint256 constant internal magnitude = 2 ** 64;


    /*=================================
     =            DATASETS            =
     ================================*/

    // amount of shares for each address (scaled number)
    mapping(address => uint256) internal tokenBalanceLedger_;
    mapping(address => int256) internal payoutsTo_;

    //Initial deposits backed by one virtual share that cannot be unstaked
    uint256 internal tokenSupply_ = 1;
    uint256 internal profitPerShare_;

    ERC20 public p4rty;


    /*=======================================
    =            PUBLIC FUNCTIONS           =
    =======================================*/

    constructor(address _p4rtyAddress) Ownable() public {

        p4rty = ERC20(_p4rtyAddress);

    }

    /**
     * @dev Fallback function to handle ethereum that was send straight to the contract
     */
    function() payable public {
        deposit();
    }

    /// @dev Internal function to actually purchase the tokens.
    function deposit() payable public  {

        uint256 _incomingEthereum = msg.value;
        address _fundingSource = msg.sender;

        // take the amount of dividends gained through this transaction, and allocates them evenly to each shareholder
        profitPerShare_ += (_incomingEthereum * magnitude / tokenSupply_);


        // fire event
        emit onDeposit(_fundingSource, _incomingEthereum, now);

    }

    function stake(uint _amountOfTokens) public {


        //Approval has to happen separately directly with p4rty
        //p4rty.approve(<DAO>, _amountOfTokens);

        address _customerAddress = msg.sender;

        //Customer needs to have P4RTY
        require(p4rty.balanceOf(_customerAddress) > 0);



        uint256 _balance = p4rty.balanceOf(_customerAddress);
        uint256 _stakeAmount = Math.min256(_balance,_amountOfTokens);

        require(_stakeAmount > 0);
        p4rty.transferFrom(_customerAddress, address(this), _stakeAmount);

        //Add to the tokenSupply_
        tokenSupply_ = SafeMath.add(tokenSupply_, _stakeAmount);

        // update circulating supply & the ledger address for the customer
        tokenBalanceLedger_[_customerAddress] = SafeMath.add(tokenBalanceLedger_[_customerAddress], _stakeAmount);

        // Tells the contract that the buyer doesn't deserve dividends for the tokens before they owned them;
        // really i know you think you do but you don't
        int256 _updatedPayouts = (int256) (profitPerShare_ * _stakeAmount);
        payoutsTo_[_customerAddress] += _updatedPayouts;

        emit onStake(_customerAddress, _amountOfTokens, now);
    }

    /// @dev Withdraws all of the callers earnings.
    function withdraw() onlyDivis public {

        address _customerAddress = msg.sender;
        // setup data
        uint256 _dividends = dividendsOf(_customerAddress);

        // update dividend tracker
        payoutsTo_[_customerAddress] += (int256) (_dividends * magnitude);


        // lambo delivery service
        _customerAddress.transfer(_dividends);

        // fire event
        emit onWithdraw(_customerAddress, _dividends, now);
    }

    function reinvestByProxy(address _customerAddress) onlyWhitelisted public {
        // setup data
        uint256 _dividends = dividendsOf(_customerAddress);

        // update dividend tracker
        payoutsTo_[_customerAddress] += (int256) (_dividends * magnitude);


        // dispatch a buy order with the virtualized "withdrawn dividends"
        ReinvestProxy reinvestProxy =  ReinvestProxy(msg.sender);
        reinvestProxy.reinvestFor.value(_dividends)(_customerAddress);

        emit onReinvestmentProxy(_customerAddress,msg.sender,_dividends);

    }


    /*=====================================
    =      HELPERS AND CALCULATORS        =
    =====================================*/

    /**
     * @dev Method to view the current Ethereum stored in the contract
     *  Example: totalEthereumBalance()
     */
    function totalEthereumBalance() public view returns (uint256) {
        return address(this).balance;
    }

    /// @dev Retrieve the total token supply.
    function totalSupply() public view returns (uint256) {
        return tokenSupply_;
    }

    /// @dev Retrieve the tokens owned by the caller.
    function myTokens() public view returns (uint256) {
        address _customerAddress = msg.sender;
        return balanceOf(_customerAddress);
    }

    /// @dev The percentage of the
    function votingPower(address _customerAddress) public view returns (uint256) {
        return SafeMath.div(balanceOf(_customerAddress), totalSupply());
    }

    /**
     * @dev Retrieve the dividends owned by the caller.
     *  If `_includeReferralBonus` is to to 1/true, the referral bonus will be included in the calculations.
     *  The reason for this, is that in the frontend, we will want to get the total divs (global + ref)
     *  But in the internal calculations, we want them separate.
     */
    function myDividends() public view returns (uint256) {
        return dividendsOf(msg.sender);

    }

    /// @dev Retrieve the token balance of any single address.
    function balanceOf(address _customerAddress) public view returns (uint256) {
        return tokenBalanceLedger_[_customerAddress];
    }

    /// @dev Retrieve the dividend balance of any single address.
    function dividendsOf(address _customerAddress) public view returns (uint256) {
        return (uint256) ((int256) (profitPerShare_ * tokenBalanceLedger_[_customerAddress]) - payoutsTo_[_customerAddress]) / magnitude;
    }

}