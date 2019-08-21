contract Ownable {
  address public owner;
  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

  function Ownable() public {
    owner = msg.sender;
  }

  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

  function transferOwnership(address newOwner) public onlyOwner {
    require(newOwner != address(0));
    OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }
}

contract SAMPreSaleToken is Ownable {
    event Payment(address indexed investor, uint256 value);

    function () external payable {
        owner.transfer(msg.value);
        Payment(msg.sender, msg.value);
    }
}