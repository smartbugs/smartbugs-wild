/**
 * RatesProvider.sol
 * Provides rates, conversion methods and tools for ETH and CHF currencies.

 * The unflattened code is available through this github tag:
 * https://github.com/MtPelerin/MtPelerin-protocol/tree/etherscan-verify-batch-1

 * @notice Copyright © 2016 - 2018 Mt Pelerin Group SA - All Rights Reserved

 * @notice All matters regarding the intellectual property of this code 
 * @notice or software are subject to Swiss Law without reference to its 
 * @notice conflicts of law rules.

 * @notice License for each contract is available in the respective file
 * @notice or in the LICENSE.md file.
 * @notice https://github.com/MtPelerin/

 * @notice Code by OpenZeppelin is copyrighted and licensed on their repository:
 * @notice https://github.com/OpenZeppelin/openzeppelin-solidity
 */


pragma solidity ^0.4.24;

// File: contracts/zeppelin/math/SafeMath.sol

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {

  /**
  * @dev Multiplies two numbers, throws on overflow.
  */
  function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
    // Gas optimization: this is cheaper than asserting 'a' not being zero, but the
    // benefit is lost if 'b' is also tested.
    // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
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

// File: contracts/interface/IRatesProvider.sol

/**
 * @title IRatesProvider
 * @dev IRatesProvider interface
 *
 * @author Cyril Lapinte - <cyril.lapinte@mtpelerin.com>
 *
 * @notice Copyright © 2016 - 2018 Mt Pelerin Group SA - All Rights Reserved
 * @notice Please refer to the top of this file for the license.
 */
contract IRatesProvider {
  function rateWEIPerCHFCent() public view returns (uint256);
  function convertWEIToCHFCent(uint256 _amountWEI)
    public view returns (uint256);

  function convertCHFCentToWEI(uint256 _amountCHFCent)
    public view returns (uint256);
}

// File: contracts/zeppelin/ownership/Ownable.sol

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
  address public owner;


  event OwnershipRenounced(address indexed previousOwner);
  event OwnershipTransferred(
    address indexed previousOwner,
    address indexed newOwner
  );


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
   * @dev Allows the current owner to relinquish control of the contract.
   */
  function renounceOwnership() public onlyOwner {
    emit OwnershipRenounced(owner);
    owner = address(0);
  }

  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param _newOwner The address to transfer ownership to.
   */
  function transferOwnership(address _newOwner) public onlyOwner {
    _transferOwnership(_newOwner);
  }

  /**
   * @dev Transfers control of the contract to a newOwner.
   * @param _newOwner The address to transfer ownership to.
   */
  function _transferOwnership(address _newOwner) internal {
    require(_newOwner != address(0));
    emit OwnershipTransferred(owner, _newOwner);
    owner = _newOwner;
  }
}

// File: contracts/Authority.sol

/**
 * @title Authority
 * @dev The Authority contract has an authority address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 * Authority means to represent a legal entity that is entitled to specific rights
 *
 * @author Cyril Lapinte - <cyril.lapinte@mtpelerin.com>
 *
 * @notice Copyright © 2016 - 2018 Mt Pelerin Group SA - All Rights Reserved
 * @notice Please refer to the top of this file for the license.
 *
 * Error messages
 * AU01: Message sender must be an authority
 */
contract Authority is Ownable {

  address authority;

  /**
   * @dev Throws if called by any account other than the authority.
   */
  modifier onlyAuthority {
    require(msg.sender == authority, "AU01");
    _;
  }

  /**
   * @dev return the address associated to the authority
   */
  function authorityAddress() public view returns (address) {
    return authority;
  }

  /**
   * @dev rdefines an authority
   * @param _name the authority name
   * @param _address the authority address.
   */
  function defineAuthority(string _name, address _address) public onlyOwner {
    emit AuthorityDefined(_name, _address);
    authority = _address;
  }

  event AuthorityDefined(
    string name,
    address _address
  );
}

// File: contracts/RatesProvider.sol

/**
 * @title RatesProvider
 * @dev RatesProvider interface
 *
 * @author Cyril Lapinte - <cyril.lapinte@mtpelerin.com>
 *
 * @notice Copyright © 2016 - 2018 Mt Pelerin Group SA - All Rights Reserved
 * @notice Please refer to the top of this file for the license.
 *
 * Error messages
 */
contract RatesProvider is IRatesProvider, Authority {
  using SafeMath for uint256;

  // WEICHF rate is in ETH_wei/CHF_cents with no fractional parts
  uint256 public rateWEIPerCHFCent;

  /**
   * @dev constructor
   */
  constructor() public {
  }

  /**
   * @dev convert rate from ETHCHF to WEICents
   */
  function convertRateFromETHCHF(
    uint256 _rateETHCHF,
    uint256 _rateETHCHFDecimal)
    public pure returns (uint256)
  {
    if (_rateETHCHF == 0) {
      return 0;
    }

    return uint256(
      10**(_rateETHCHFDecimal.add(18 - 2))
    ).div(_rateETHCHF);
  }

  /**
   * @dev convert rate from WEICents to ETHCHF
   */
  function convertRateToETHCHF(
    uint256 _rateWEIPerCHFCent,
    uint256 _rateETHCHFDecimal)
    public pure returns (uint256)
  {
    if (_rateWEIPerCHFCent == 0) {
      return 0;
    }

    return uint256(
      10**(_rateETHCHFDecimal.add(18 - 2))
    ).div(_rateWEIPerCHFCent);
  }

  /**
   * @dev convert CHF to ETH
   */
  function convertCHFCentToWEI(uint256 _amountCHFCent)
    public view returns (uint256)
  {
    return _amountCHFCent.mul(rateWEIPerCHFCent);
  }

  /**
   * @dev convert ETH to CHF
   */
  function convertWEIToCHFCent(uint256 _amountETH)
    public view returns (uint256)
  {
    if (rateWEIPerCHFCent == 0) {
      return 0;
    }

    return _amountETH.div(rateWEIPerCHFCent);
  }

  /* Current ETHCHF rates */
  function rateWEIPerCHFCent() public view returns (uint256) {
    return rateWEIPerCHFCent;
  }
  
  /**
   * @dev rate ETHCHF
   */
  function rateETHCHF(uint256 _rateETHCHFDecimal)
    public view returns (uint256)
  {
    return convertRateToETHCHF(rateWEIPerCHFCent, _rateETHCHFDecimal);
  }

  /**
   * @dev define rate
   */
  function defineRate(uint256 _rateWEIPerCHFCent)
    public onlyAuthority
  {
    rateWEIPerCHFCent = _rateWEIPerCHFCent;
    emit Rate(currentTime(), _rateWEIPerCHFCent);
  }

  /**
   * @dev define rate with decimals
   */
  function defineETHCHFRate(uint256 _rateETHCHF, uint256 _rateETHCHFDecimal)
    public onlyAuthority
  {
    // The rate is inverted to maximize the decimals stored
    defineRate(convertRateFromETHCHF(_rateETHCHF, _rateETHCHFDecimal));
  }

  /**
   * @dev current time
   */
  function currentTime() private view returns (uint256) {
    // solium-disable-next-line security/no-block-members
    return now;
  }

  event Rate(uint256 at, uint256 rateWEIPerCHFCent);
}