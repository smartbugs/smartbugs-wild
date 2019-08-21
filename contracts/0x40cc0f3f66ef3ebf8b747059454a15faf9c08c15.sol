pragma solidity ^0.4.24;

library SafeMath {

  /**
  * @dev Multiplies two numbers, throws on overflow.
  */
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    assert(c / a == b);
    return c;
  }

  /**
  * @dev Integer division of two numbers, truncating the quotient.
  */
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  /**
  * @dev Substracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
  */
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  /**
  * @dev Adds two numbers, throws on overflow.
  */
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}


contract Presale {
    using SafeMath for uint256;
    address owner;
    mapping (address => uint) public userV1ItemNumber;  // p1
    mapping (address => uint) public userV2ItemNumber;  // p2
    mapping (address => uint) public userV3ItemNumber;  // p3
    uint v1Price = 1 ether;
    uint v2Price = 500 finney;
    uint v3Price = 100 finney;
    uint v1Number = 10;
    uint v2Number = 50;
    uint v3Number = 100;
    uint currentV1Number = 0;
    uint currentV2Number = 0;
    uint currentV3Number = 0;
    /* Modifiers */
    modifier onlyOwner() {
        require(owner == msg.sender);
        _;
    }
    
    /* Owner */
    function setOwner (address _owner) onlyOwner() public {
        owner = _owner;
    }

    function Presale() public {
        owner = msg.sender;
    }

    function buyItem1() public payable{
        require(msg.value >= v1Price);
        require(currentV1Number < v1Number);
        uint excess = msg.value.sub(v1Price);
        if (excess > 0) {
            msg.sender.transfer(excess);
        }
        currentV1Number += 1;
        userV1ItemNumber[msg.sender] += 1;
    }
    
    function buyItem2() public payable{
        require(msg.value >= v2Price);
        require(currentV2Number < v2Number);
        uint excess = msg.value.sub(v2Price);
        if (excess > 0) {
            msg.sender.transfer(excess);
        }
        currentV2Number += 1;
        userV2ItemNumber[msg.sender] += 1;
    }
    
    function buyItem3() public payable{
        require(msg.value >= v3Price);
        require(currentV3Number < v3Number);
        uint excess = msg.value.sub(v3Price);
        if (excess > 0) {
            msg.sender.transfer(excess);
        }
        currentV3Number += 1;
        userV3ItemNumber[msg.sender] += 1;
    }
    
    function getGameStats() public view returns(uint, uint, uint) {
        return (currentV1Number, currentV2Number, currentV3Number);    
    }
    
    function withdrawAll () onlyOwner() public {
        msg.sender.transfer(address(this).balance);
    }

    function withdrawAmount (uint256 _amount) onlyOwner() public {
        msg.sender.transfer(_amount);
    }
}