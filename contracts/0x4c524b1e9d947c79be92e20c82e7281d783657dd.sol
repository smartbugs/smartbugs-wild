pragma solidity ^0.4.11;

contract Johnsonville {

    address owner;
    address patronOne;
    address patronTwo;
    address patronThree;

    bool patronOneWd;
    bool patronTwoWd;
    bool patronThreeWd;

    modifier onlyOwner {
      if(msg.sender != owner) throw;
      _;
    }

    function Johnsonville() {
      owner = msg.sender;
      patronOneWd = false;
      patronTwoWd = false;
      patronThreeWd = false;
    }

    function Donate() payable {
      if(msg.value > patronOne.balance || patronOne == 0x0){
        patronOne = msg.sender;
        return;
      }
      if(msg.value > patronTwo.balance || patronTwo == 0x0){
        patronTwo = msg.sender;
        return;
      }
      if(msg.value > patronThree.balance || patronThree == 0x0){
        patronThree = msg.sender;
        return;
      }
    }

    function PatronOneWithdrawal(){
      if(msg.sender == patronOne){ patronOneWd = !patronOneWd; }
    }

    function PatronTwoWithdrawal(){
      if(msg.sender == patronTwo){ patronTwoWd = !patronTwoWd; }
    }

    function PatronThreeWithdrawal(){
      if(msg.sender == patronThree){ patronThreeWd = !patronThreeWd; }
    }

    function Withdrawal(address withdrawalAddress) onlyOwner {
      if(patronOneWd && patronTwoWd && patronThreeWd){
        selfdestruct(withdrawalAddress);
      }
    }

    function KillContract() onlyOwner {
      selfdestruct(0x0);
    }
}