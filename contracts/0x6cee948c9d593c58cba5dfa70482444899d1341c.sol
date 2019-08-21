pragma solidity ^0.4.15;

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
  function balanceOf(address who) public constant returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
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
 * @title Math
 * @dev Assorted math operations
 */

library Math {
  function max64(uint64 a, uint64 b) internal constant returns (uint64) {
    return a >= b ? a : b;
  }

  function min64(uint64 a, uint64 b) internal constant returns (uint64) {
    return a < b ? a : b;
  }

  function max256(uint256 a, uint256 b) internal constant returns (uint256) {
    return a >= b ? a : b;
  }

  function min256(uint256 a, uint256 b) internal constant returns (uint256) {
    return a < b ? a : b;
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

 /*
 * Contract that is working with ERC223 tokens
 * This is an implementation of ContractReceiver provided here:
 * https://github.com/Dexaran/ERC223-token-standard/blob/Recommended/Receiver_Interface.sol
 */

 contract ContractReceiver {

    function tokenFallback(address _from, uint _value, bytes _data);

}
/*
    Copyright 2016, Jordi Baylina

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

/// @title MiniMeToken Contract
/// @author Jordi Baylina
/// @dev This token contract's goal is to make it easy for anyone to clone this
///  token using the token distribution at a given block, this will allow DAO's
///  and DApps to upgrade their features in a decentralized manner without
///  affecting the original token
/// @dev It is ERC20 compliant, but still needs to under go further testing.


/// @dev The token controller contract must implement these functions
contract TokenController {
    /// @notice Called when `_owner` sends ether to the MiniMe Token contract
    /// @param _owner The address that sent the ether to create tokens
    /// @return True if the ether is accepted, false if it throws
    function proxyPayment(address _owner) payable returns(bool);

    /// @notice Notifies the controller about a token transfer allowing the
    ///  controller to react if desired
    /// @param _from The origin of the transfer
    /// @param _to The destination of the transfer
    /// @param _amount The amount of the transfer
    /// @return False if the controller does not authorize the transfer
    function onTransfer(address _from, address _to, uint _amount) returns(bool);

    /// @notice Notifies the controller about an approval allowing the
    ///  controller to react if desired
    /// @param _owner The address that calls `approve()`
    /// @param _spender The spender in the `approve()` call
    /// @param _amount The amount in the `approve()` call
    /// @return False if the controller does not authorize the approval
    function onApprove(address _owner, address _spender, uint _amount)
        returns(bool);
}

contract Controlled {
    /// @notice The address of the controller is the only address that can call
    ///  a function with this modifier
    modifier onlyController { require(msg.sender == controller); _; }

    address public controller;

    function Controlled() { controller = msg.sender;}

    /// @notice Changes the controller of the contract
    /// @param _newController The new controller of the contract
    function changeController(address _newController) onlyController {
        controller = _newController;
    }
}

/// @title SpecToken - Crowdfunding code for the Spectre.ai Token Sale
/// @author Parthasarathy Ramanujam
contract SpectreSubscriberToken is StandardToken, Pausable, TokenController {
  using SafeMath for uint;

  string public constant name = "SPECTRE SUBSCRIBER TOKEN";
  string public constant symbol = "SXS";
  uint256 public constant decimals = 18;

  uint256 constant public TOKENS_AVAILABLE             = 240000000 * 10**decimals;
  uint256 constant public BONUS_SLAB                   = 100000000 * 10**decimals;
  uint256 constant public MIN_CAP                      = 5000000 * 10**decimals;
  uint256 constant public MIN_FUND_AMOUNT              = 1 ether;
  uint256 constant public TOKEN_PRICE                  = 0.0005 ether;
  uint256 constant public WHITELIST_PERIOD             = 3 days;

  address public specWallet;
  address public specDWallet;
  address public specUWallet;

  bool public refundable = false;
  bool public configured = false;
  bool public tokenAddressesSet = false;
  //presale start and end blocks
  uint256 public presaleStart;
  uint256 public presaleEnd;
  //main sale start and end blocks
  uint256 public saleStart;
  uint256 public saleEnd;
  //discount end block for main sale
  uint256 public discountSaleEnd;

  //whitelisting
  mapping(address => uint256) public whitelist;
  uint256 constant D160 = 0x0010000000000000000000000000000000000000000;

  //bonus earned
  mapping(address => uint256) public bonus;

  event Refund(address indexed _to, uint256 _value);
  event ContractFunded(address indexed _from, uint256 _value, uint256 _total);
  event Refundable();
  event WhiteListSet(address indexed _subscriber, uint256 _value);
  event OwnerTransfer(address indexed _from, address indexed _to, uint256 _value);

  modifier isRefundable() {
    require(refundable);
    _;
  }

  modifier isNotRefundable() {
    require(!refundable);
    _;
  }

  modifier isTransferable() {
    require(tokenAddressesSet);
    require(getNow() > saleEnd);
    require(totalSupply >= MIN_CAP);
    _;
  }

  modifier onlyWalletOrOwner() {
    require(msg.sender == owner || msg.sender == specWallet);
    _;
  }

  //@notice function to initilaize the token contract
  //@notice _specWallet - The wallet that receives the proceeds from the token sale
  //@notice _specDWallet - Wallet that would receive tokens chosen for dividend
  //@notice _specUWallet - Wallet that would receive tokens chosen for utility
  function SpectreSubscriberToken(address _specWallet) {
    require(_specWallet != address(0));
    specWallet = _specWallet;
    pause();
  }

  //@notice Fallback function that accepts the ether and allocates tokens to
  //the msg.sender corresponding to msg.value
  function() payable whenNotPaused public {
    require(msg.value >= MIN_FUND_AMOUNT);
    if(getNow() >= presaleStart && getNow() <= presaleEnd) {
      purchasePresale();
    } else if (getNow() >= saleStart && getNow() <= saleEnd) {
      purchase();
    } else {
      revert();
    }
  }

  //@notice function to be used for presale purchase
  function purchasePresale() internal {
    //Only check whitelist for the first 3 days of presale
    if (getNow() < (presaleStart + WHITELIST_PERIOD)) {
      require(whitelist[msg.sender] > 0);
      //Accept if the subsciber 95% to 120% of whitelisted amount
      uint256 minAllowed = whitelist[msg.sender].mul(95).div(100);
      uint256 maxAllowed = whitelist[msg.sender].mul(120).div(100);
      require(msg.value >= minAllowed && msg.value <= maxAllowed);
      //remove the address from whitelist
      whitelist[msg.sender] = 0;
    }

    uint256 numTokens = msg.value.mul(10**decimals).div(TOKEN_PRICE);
    uint256 bonusTokens = 0;

    if(totalSupply < BONUS_SLAB) {
      //Any portion of tokens less than BONUS_SLAB are eligable for 33% bonus, otherwise 22% bonus
      uint256 remainingBonusSlabTokens = SafeMath.sub(BONUS_SLAB, totalSupply);
      uint256 bonusSlabTokens = Math.min256(remainingBonusSlabTokens, numTokens);
      uint256 nonBonusSlabTokens = SafeMath.sub(numTokens, bonusSlabTokens);
      bonusTokens = bonusSlabTokens.mul(33).div(100);
      bonusTokens = bonusTokens.add(nonBonusSlabTokens.mul(22).div(100));
    } else {
      //calculate 22% bonus for tokens purchased on presale
      bonusTokens = numTokens.mul(22).div(100);
    }
    //
    numTokens = numTokens.add(bonusTokens);
    bonus[msg.sender] = bonus[msg.sender].add(bonusTokens);

    //transfer money to Spectre MultisigWallet (could be msg.value)
    specWallet.transfer(msg.value);

    totalSupply = totalSupply.add(numTokens);
    require(totalSupply <= TOKENS_AVAILABLE);

    balances[msg.sender] = balances[msg.sender].add(numTokens);
    //fire the event notifying the transfer of tokens
    Transfer(0, msg.sender, numTokens);

  }

  //@notice function to be used for mainsale purchase
  function purchase() internal {

    uint256 numTokens = msg.value.mul(10**decimals).div(TOKEN_PRICE);
    uint256 bonusTokens = 0;

    if(getNow() <= discountSaleEnd) {
      //calculate 11% bonus for tokens purchased on discount period
      bonusTokens = numTokens.mul(11).div(100);
    }

    numTokens = numTokens.add(bonusTokens);
    bonus[msg.sender] = bonus[msg.sender].add(bonusTokens);

    //transfer money to Spectre MultisigWallet
    specWallet.transfer(msg.value);

    totalSupply = totalSupply.add(numTokens);

    require(totalSupply <= TOKENS_AVAILABLE);
    balances[msg.sender] = balances[msg.sender].add(numTokens);
    //fire the event notifying the transfer of tokens
    Transfer(0, msg.sender, numTokens);
  }

  //@notice Function reports the number of tokens available for sale
  function numberOfTokensLeft() constant returns (uint256) {
    return TOKENS_AVAILABLE.sub(totalSupply);
  }

  //Override unpause function to only allow once configured
  function unpause() onlyOwner whenPaused public {
    require(configured);
    paused = false;
    Unpause();
  }

  //@notice Function to configure contract addresses
  //@param `_specUWallet` - address of Utility contract
  //@param `_specDWallet` - address of Dividend contract
  function setTokenAddresses(address _specUWallet, address _specDWallet) onlyOwner public {
    require(!tokenAddressesSet);
    require(_specDWallet != address(0));
    require(_specUWallet != address(0));
    require(isContract(_specDWallet));
    require(isContract(_specUWallet));
    specUWallet = _specUWallet;
    specDWallet = _specDWallet;
    tokenAddressesSet = true;
    if (configured) {
      unpause();
    }
  }

  //@notice Function to configure contract parameters
  //@param `_startPresaleBlock` - block from when presale begins.
  //@param `_endPresaleBlock` - block from when presale ends.
  //@param `_saleStart` - block from when main sale begins.
  //@param `_saleEnd` - block from when main sale ends.
  //@param `_discountEnd` - block from when the discounts would end.
  //@notice Can be called only when funding is not active and only by the owner
  function configure(uint256 _presaleStart, uint256 _presaleEnd, uint256 _saleStart, uint256 _saleEnd, uint256 _discountSaleEnd) onlyOwner public {
    require(!configured);
    require(_presaleStart > getNow());
    require(_presaleEnd > _presaleStart);
    require(_saleStart > _presaleEnd);
    require(_saleEnd > _saleStart);
    require(_discountSaleEnd > _saleStart && _discountSaleEnd <= _saleEnd);
    presaleStart = _presaleStart;
    presaleEnd = _presaleEnd;
    saleStart = _saleStart;
    saleEnd = _saleEnd;
    discountSaleEnd = _discountSaleEnd;
    configured = true;
    if (tokenAddressesSet) {
      unpause();
    }
  }

  //@notice Function that can be called by purchasers to refund
  //@notice Used only in case the ICO isn't successful.
  function refund() isRefundable public {
    require(balances[msg.sender] > 0);

    uint256 tokenValue = balances[msg.sender].sub(bonus[msg.sender]);
    balances[msg.sender] = 0;
    tokenValue = tokenValue.mul(TOKEN_PRICE).div(10**decimals);

    //transfer to the requesters wallet
    msg.sender.transfer(tokenValue);
    Refund(msg.sender, tokenValue);
  }

  function withdrawEther() public isNotRefundable onlyOwner {
    //In case ether is sent, even though not refundable
    msg.sender.transfer(this.balance);
  }

  //@notice Function used for funding in case of refund.
  //@notice Can be called only by the Owner or Wallet
  function fundContract() public payable onlyWalletOrOwner {
    //does nothing just accepts and stores the ether
    ContractFunded(msg.sender, msg.value, this.balance);
  }

  function setRefundable() onlyOwner {
    require(this.balance > 0);
    require(getNow() > saleEnd);
    require(totalSupply < MIN_CAP);
    Refundable();
    refundable = true;
  }

  //@notice Standard function transfer similar to ERC20 transfer with no _data .
  //@notice Added due to backwards compatibility reasons .
  function transfer(address _to, uint256 _value) isTransferable returns (bool success) {
    //standard function transfer similar to ERC20 transfer with no _data
    //added due to backwards compatibility reasons
    require(_to == specDWallet || _to == specUWallet);
    require(isContract(_to));
    bytes memory empty;
    return transferToContract(msg.sender, _to, _value, empty);
  }

  //@notice assemble the given address bytecode. If bytecode exists then the _addr is a contract.
  function isContract(address _addr) private returns (bool is_contract) {
    uint256 length;
    assembly {
      //retrieve the size of the code on target address, this needs assembly
      length := extcodesize(_addr)
    }
    return (length>0);
  }

  //@notice function that is called when transaction target is a contract
  function transferToContract(address _from, address _to, uint256 _value, bytes _data) internal returns (bool success) {
    require(balanceOf(_from) >= _value);
    balances[_from] = balanceOf(_from).sub(_value);
    balances[_to] = balanceOf(_to).add(_value);
    ContractReceiver receiver = ContractReceiver(_to);
    receiver.tokenFallback(_from, _value, _data);
    Transfer(_from, _to, _value);
    return true;
  }

  /**
   * @dev Transfer tokens from one address to another - needed for owner transfers
   * @param _from address The address which you want to send tokens from
   * @param _to address The address which you want to transfer to
   * @param _value uint256 the amount of tokens to be transferred
   */
  function transferFrom(address _from, address _to, uint256 _value) public isTransferable returns (bool) {
    require(_to == specDWallet || _to == specUWallet);
    require(isContract(_to));
    //owner can transfer tokens on behalf of users after 28 days
    if (msg.sender == owner && getNow() > saleEnd + 28 days) {
      OwnerTransfer(_from, _to, _value);
    } else {
      uint256 _allowance = allowed[_from][msg.sender];
      allowed[_from][msg.sender] = _allowance.sub(_value);
    }

    //Now make the transfer
    bytes memory empty;
    return transferToContract(_from, _to, _value, empty);

  }

  //@notice function that is used for whitelisting an address
  function setWhiteList(address _subscriber, uint256 _amount) public onlyOwner {
    require(_subscriber != address(0));
    require(_amount != 0);
    whitelist[_subscriber] = _amount;
    WhiteListSet(_subscriber, _amount);
  }

  // data is an array of uint256s. Each uint256 represents a address and amount.
  // The 160 LSB is the address that wants to be added
  // The 96 MSB is the amount of to be set for the whitelist for that address
  function multiSetWhiteList(uint256[] data) public onlyOwner {
    for (uint256 i = 0; i < data.length; i++) {
      address addr = address(data[i] & (D160 - 1));
      uint256 amount = data[i] / D160;
      setWhiteList(addr, amount);
    }
  }

  /////////////////
  // TokenController interface
  /////////////////

  /// @notice `proxyPayment()` returns false, meaning ether is not accepted at
  ///  the token address, only the address of FiinuCrowdSale
  /// @param _owner The address that will hold the newly created tokens

  function proxyPayment(address _owner) payable returns(bool) {
      return false;
  }

  /// @notice Notifies the controller about a transfer, for this Campaign all
  ///  transfers are allowed by default and no extra notifications are needed
  /// @param _from The origin of the transfer
  /// @param _to The destination of the transfer
  /// @param _amount The amount of the transfer
  /// @return False if the controller does not authorize the transfer
  function onTransfer(address _from, address _to, uint _amount) returns(bool) {
      return true;
  }

  /// @notice Notifies the controller about an approval, for this Campaign all
  ///  approvals are allowed by default and no extra notifications are needed
  /// @param _owner The address that calls `approve()`
  /// @param _spender The spender in the `approve()` call
  /// @param _amount The amount in the `approve()` call
  /// @return False if the controller does not authorize the approval
  function onApprove(address _owner, address _spender, uint _amount)
      returns(bool)
  {
      return true;
  }

  function getNow() constant internal returns (uint256) {
    return now;
  }

}