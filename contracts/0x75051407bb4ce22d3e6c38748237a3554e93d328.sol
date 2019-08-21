pragma solidity ^0.4.12;

// Reward Channel contract

contract Name{
    address public owner = msg.sender;
    string public name;

    modifier onlyBy(address _account) { require(msg.sender == _account); _; }


    function Name(string myName) public {
      name = myName;
    }

    function() payable public {}

    function withdraw() onlyBy(owner) public {
      owner.transfer(this.balance);
    }

    function destroy() onlyBy(owner) public{
      selfdestruct(this);
    }
}