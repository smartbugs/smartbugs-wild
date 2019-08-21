pragma solidity ^0.4.18;

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
  function Ownable() public {
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
  function transferOwnership(address newOwner) public onlyOwner {
    require(newOwner != address(0));
    OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }

}

interface itoken {
    function transferMultiAddressFrom(address _from, address[] _toMulti, uint256[] _values) public returns (bool);
}

contract AirsendGifts is Ownable {
    // uint256 private m_rate = 1e18;

    // function initialize(address _tokenAddr, address _tokenOwner, uint256 _amount) onlyOwner public {
    //     require(_tokenAddr != address(0));
    //     require(_tokenOwner != address(0));
    //     require(_amount > 0);
    //     m_token = DRCTestToken(_tokenAddr);
    //     m_token.approve(this, _amount.mul(m_rate));
    //     m_tokenOwner = _tokenOwner;
    // }
    
    function multiSend(address _tokenAddr, address _tokenOwner, address[] _destAddrs, uint256[] _values) onlyOwner public returns (bool) {
        assert(_destAddrs.length == _values.length);

        return itoken(_tokenAddr).transferMultiAddressFrom(_tokenOwner, _destAddrs, _values);
    }
}