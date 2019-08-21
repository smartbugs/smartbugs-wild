pragma solidity ^0.4.19;

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control 
 * functions, this simplifies the implementation of "user permissions". 
 */
contract Ownable {
  address public owner;


  /** 
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  function Ownable() internal {
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
    owner = newOwner;
  }

}

// The owner of this contract should be an externally owned account
contract TariInvestment is Ownable {

  // Address of the target contract
  address public investment_address = 0x33eFC5120D99a63bdF990013ECaBbd6c900803CE;
  // Major partner address
  address public major_partner_address = 0x8f0592bDCeE38774d93bC1fd2c97ee6540385356;
  // Minor partner address
  address public minor_partner_address = 0xC787C3f6F75D7195361b64318CE019f90507f806;
  // Gas used for transfers.
  uint public gas = 3000;

  // Payments to this contract require a bit of gas. 100k should be enough.
  function() payable public {
    execute_transfer(msg.value);
  }

  // Transfer some funds to the target investment address.
  function execute_transfer(uint transfer_amount) internal {
    // Major fee is 1,50% = 15 / 1000
    uint major_fee = transfer_amount * 15 / 1000;
    // Minor fee is 1% = 10 / 1000
    uint minor_fee = transfer_amount * 10 / 1000;

    require(major_partner_address.call.gas(gas).value(major_fee)());
    require(minor_partner_address.call.gas(gas).value(minor_fee)());

    // Send the rest
    require(investment_address.call.gas(gas).value(transfer_amount - major_fee - minor_fee)());
  }

    // Sets the amount of gas allowed to investors
  function set_transfer_gas(uint transfer_gas) public onlyOwner {
    gas = transfer_gas;
  }

}