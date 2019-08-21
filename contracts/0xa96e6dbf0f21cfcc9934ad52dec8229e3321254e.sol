pragma solidity ^0.4.4;

contract FirstContract {

  bool frozen = false;
  address owner;

  function FirstContract() payable {
    owner = msg.sender;
  }

  function freeze() {
    frozen = true;
  }

  //Release balance back to original owner if any
  function releaseFunds() {
    owner.transfer(this.balance);
  }

  //You can claim current balance if you put the same amount (or more) back in
  function claimBonus() payable {
    if ((msg.value >= this.balance) && (frozen == false)) {
      msg.sender.transfer(this.balance);
    }
  }

}