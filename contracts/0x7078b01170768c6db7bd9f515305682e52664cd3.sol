pragma solidity ^0.4.19;

/** GitHub repository: https://github.com/dggventures/syndicate/tree/master/tari */

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

contract TariInvestment is Ownable {

  // These are addresses that shouldn't consume too much gas in their fallback functions if they are contracts.
  // Address of the target contract
  address public investmentAddress = 0x33eFC5120D99a63bdF990013ECaBbd6c900803CE;
  // Major partner address
  address public majorPartnerAddress = 0x8f0592bDCeE38774d93bC1fd2c97ee6540385356;
  // Minor partner address
  address public minorPartnerAddress = 0xC787C3f6F75D7195361b64318CE019f90507f806;
  // Record balances to allow refunding
  mapping(address => uint) public balances;
  // Total received. Used for refunding.
  uint totalInvestment;
  // Available refunds. Used for refunding.
  uint availableRefunds;
  // Deadline when refunding starts.
  uint refundingDeadline;
  // States: Open for investments - allows ether investments; transitions to Closed as soon as
  //                                a transfer to the target investment address is made,
  //         Closed for investments - only transfers to target investment address are allowed,
  //         Refunding investments - any state can transition to refunding state
  enum State{Open, Closed, Refunding}


  State public state = State.Open;

  function TariInvestment() public {
    refundingDeadline = now + 10 days;
  }

  // Payments to this contract require a bit of gas. 100k should be enough.
  function() payable public {
    // Reject any value transfers once we have finished sending the balance to the target contract.
    require(state == State.Open);
    balances[msg.sender] += msg.value;
    totalInvestment += msg.value;
  }

  // Transfer some funds to the target investment address.
  // It is expected of all addresses to allow low gas transferrals of ether.
  function execute_transfer(uint transfer_amount) public onlyOwner {
    // Close down investments. Transferral of funds shouldn't be possible during refunding.
    State current_state = state;
    if (current_state == State.Open)
      state = State.Closed;
    require(state == State.Closed);

    // Major fee is 1,50% = 15 / 1000
    uint major_fee = transfer_amount * 15 / 1000;
    // Minor fee is 1% = 10 / 1000
    uint minor_fee = transfer_amount * 10 / 1000;
    majorPartnerAddress.transfer(major_fee);
    minorPartnerAddress.transfer(minor_fee);

    // Send the rest 
    investmentAddress.transfer(transfer_amount - major_fee - minor_fee);
  }

  // Convenience function to transfer all available balance.
  function execute_transfer() public onlyOwner {
    execute_transfer(this.balance);
  }

  // Refund an investor when he sends a withdrawal transaction.
  // Only available once refunds are enabled.
  function withdraw() public {
    if (state != State.Refunding) {
      require(refundingDeadline <= now);
      state = State.Refunding;
      availableRefunds = this.balance;
    }

    uint withdrawal = availableRefunds * balances[msg.sender] / totalInvestment;
    balances[msg.sender] = 0;
    msg.sender.transfer(withdrawal);
  }

}