/**
 * MPSSaleConfig.sol
 * Configuration for the MPS token sale private phase.

 * More info about MPS : https://github.com/MtPelerin/MtPelerin-share-MPS

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

// File: contracts/interface/ISaleConfig.sol

/**
 * @title ISaleConfig interface
 *
 * @author Cyril Lapinte - <cyril.lapinte@mtpelerin.com>
 *
 * @notice Copyright © 2016 - 2018 Mt Pelerin Group SA - All Rights Reserved
 * @notice Please refer to the top of this file for the license.
 */
contract ISaleConfig {

  struct Tokensale {
    uint256 lotId;
    uint256 tokenPriceCHFCent;
  }

  function tokenSupply() public pure returns (uint256);
  function tokensaleLotSupplies() public view returns (uint256[]);

  function tokenizedSharePercent() public pure returns (uint256); 
  function tokenPriceCHF() public pure returns (uint256);

  function minimalCHFInvestment() public pure returns (uint256);
  function maximalCHFInvestment() public pure returns (uint256);

  function tokensalesCount() public view returns (uint256);
  function lotId(uint256 _tokensaleId) public view returns (uint256);
  function tokenPriceCHFCent(uint256 _tokensaleId)
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

// File: contracts/mps/MPSSaleConfig.sol

/**
 * @title MPSSaleConfig
 * @dev MPSSaleConfig contract
 * The contract configure the sale for the MPS token
 *
 * @author Cyril Lapinte - <cyril.lapinte@mtpelerin.com>
 *
 * @notice Copyright © 2016 - 2018 Mt Pelerin Group SA - All Rights Reserved
 * @notice Please refer to the top of this file for the license.
 */
contract MPSSaleConfig is ISaleConfig, Ownable {

  // Token supply cap: 10M
  uint256 constant public TOKEN_SUPPLY = 10 ** 7;
 
  // 100% of Mt Pelerin's shares are tokenized
  uint256 constant public TOKENSALE_LOT1_SHARE_PERCENT = 5;
  uint256 constant public TOKENSALE_LOT2_SHARE_PERCENT = 95;
  uint256 constant public TOKENIZED_SHARE_PERCENT
  = TOKENSALE_LOT1_SHARE_PERCENT + TOKENSALE_LOT2_SHARE_PERCENT;

  uint256 constant public TOKENSALE_LOT1_SUPPLY
  = TOKEN_SUPPLY * TOKENSALE_LOT1_SHARE_PERCENT / 100;
  uint256 constant public TOKENSALE_LOT2_SUPPLY
  = TOKEN_SUPPLY * TOKENSALE_LOT2_SHARE_PERCENT / 100;

  uint256[] private tokensaleLotSuppliesArray
  = [ TOKENSALE_LOT1_SUPPLY, TOKENSALE_LOT2_SUPPLY ];

  // Tokens amount per CHF Cents
  uint256 constant public TOKEN_PRICE_CHF_CENT = 500;

  // Minimal CHF Cents investment
  uint256 constant public MINIMAL_CHF_CENT_INVESTMENT = 10 ** 4;

  // Maximal CHF Cents investment
  uint256 constant public MAXIMAL_CHF_CENT_INVESTMENT = 10 ** 10;

  Tokensale[] public tokensales;

  /**
   * @dev constructor
   */
  constructor() public {
    tokensales.push(Tokensale(
      0,
      TOKEN_PRICE_CHF_CENT * 80 / 100
    ));

    tokensales.push(Tokensale(
      0,
      TOKEN_PRICE_CHF_CENT
    ));
  }

  /**
   * @dev getter need to be declared to comply with ISaleConfig interface
   */
  function tokenSupply() public pure returns (uint256) {
    return TOKEN_SUPPLY;
  }

  /**
   * @dev getter need to be declared to comply with ISaleConfig interface
   */
  function tokensaleLotSupplies() public view returns (uint256[]) {
    return tokensaleLotSuppliesArray;
  }

  /**
   * @dev getter need to be declared to comply with ISaleConfig interface
   */
  function tokenizedSharePercent() public pure returns (uint256) {
    return TOKENIZED_SHARE_PERCENT;
  }

  /**
   * @dev getter need to be declared to comply with ISaleConfig interface
   */
  function tokenPriceCHF() public pure returns (uint256) {
    return TOKEN_PRICE_CHF_CENT;
  }

  /**
   * @dev getter need to be declared to comply with ISaleConfig interface
   */
  function minimalCHFInvestment() public pure returns (uint256) {
    return MINIMAL_CHF_CENT_INVESTMENT;
  }

  /**
   * @dev getter need to be declared to comply with ISaleConfig interface
   */
  function maximalCHFInvestment() public pure returns (uint256) {
    return MAXIMAL_CHF_CENT_INVESTMENT;
  }

  /**
   * @dev tokensale count
   */
  function tokensalesCount() public view returns (uint256) {
    return tokensales.length;
  }

  /**
   * @dev getter need to be declared to comply with ISaleConfig interface
   */
  function lotId(uint256 _tokensaleId) public view returns (uint256) {
    return tokensales[_tokensaleId].lotId;
  }

  /**
   * @dev getter need to be declared to comply with ISaleConfig interface
   */
  function tokenPriceCHFCent(uint256 _tokensaleId)
    public view returns (uint256)
  {
    return tokensales[_tokensaleId].tokenPriceCHFCent;
  }
}