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

contract EthMessage is Ownable {

    /*
    The cost of posting a message will be currentPrice.

    The currentPrice will increase by basePrice every time a message is bought.
    */

    uint public constant BASEPRICE = 0.01 ether;
    uint public currentPrice = 0.01 ether;
    string public message = "";

    function withdraw() public payable onlyOwner {
        msg.sender.transfer(this.balance);
    }
    
    // This is only for messed up things people put.
    function removeMessage() onlyOwner public {
        message = "";
    }

    modifier requiresPayment () {
        require(msg.value >= currentPrice);
        if (msg.value > currentPrice) {
            msg.sender.transfer(msg.value - currentPrice);
        }
        currentPrice += BASEPRICE;
        _;
    }

    function putMessage(string messageToPut) public requiresPayment payable {
        if (bytes(messageToPut).length > 255) {
            revert();
        }
        message = messageToPut;
    }

    function () {
        revert();
    }
}