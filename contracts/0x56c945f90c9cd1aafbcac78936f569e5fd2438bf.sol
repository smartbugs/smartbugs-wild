pragma solidity ^0.4.24;

// File: node_modules/openzeppelin-solidity/contracts/ownership/Ownable.sol

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
  address private _owner;

  event OwnershipTransferred(
    address indexed previousOwner,
    address indexed newOwner
  );

  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  constructor() internal {
    _owner = msg.sender;
    emit OwnershipTransferred(address(0), _owner);
  }

  /**
   * @return the address of the owner.
   */
  function owner() public view returns(address) {
    return _owner;
  }

  /**
   * @dev Throws if called by any account other than the owner.
   */
  modifier onlyOwner() {
    require(isOwner());
    _;
  }

  /**
   * @return true if `msg.sender` is the owner of the contract.
   */
  function isOwner() public view returns(bool) {
    return msg.sender == _owner;
  }

  /**
   * @dev Allows the current owner to relinquish control of the contract.
   * @notice Renouncing to ownership will leave the contract without an owner.
   * It will not be possible to call the functions with the `onlyOwner`
   * modifier anymore.
   */
  function renounceOwnership() public onlyOwner {
    emit OwnershipTransferred(_owner, address(0));
    _owner = address(0);
  }

  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param newOwner The address to transfer ownership to.
   */
  function transferOwnership(address newOwner) public onlyOwner {
    _transferOwnership(newOwner);
  }

  /**
   * @dev Transfers control of the contract to a newOwner.
   * @param newOwner The address to transfer ownership to.
   */
  function _transferOwnership(address newOwner) internal {
    require(newOwner != address(0));
    emit OwnershipTransferred(_owner, newOwner);
    _owner = newOwner;
  }
}

// File: node_modules/openzeppelin-solidity/contracts/token/ERC20/IERC20.sol

/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
interface IERC20 {
  function totalSupply() external view returns (uint256);

  function balanceOf(address who) external view returns (uint256);

  function allowance(address owner, address spender)
    external view returns (uint256);

  function transfer(address to, uint256 value) external returns (bool);

  function approve(address spender, uint256 value)
    external returns (bool);

  function transferFrom(address from, address to, uint256 value)
    external returns (bool);

  event Transfer(
    address indexed from,
    address indexed to,
    uint256 value
  );

  event Approval(
    address indexed owner,
    address indexed spender,
    uint256 value
  );
}

// File: lib/CanReclaimToken.sol

/**
 * @title Contracts that should be able to recover tokens
 * @author SylTi
 * @dev This allow a contract to recover any ERC20 token received in a contract by transferring the balance to the contract owner.
 * This will prevent any accidental loss of tokens.
 */
contract CanReclaimToken is Ownable {

  /**
   * @dev Reclaim all ERC20 compatible tokens
   * @param token ERC20 The address of the token contract
   */
  function reclaimToken(IERC20 token) external onlyOwner {
    if (address(token) == address(0)) {
      owner().transfer(address(this).balance);
      return;
    }
    uint256 balance = token.balanceOf(this);
    token.transfer(owner(), balance);
  }

}

// File: contracts/HeroUp.sol

interface HEROES_NEW {
  function mint(address to, uint256 genes, uint256 level) external returns (uint);
  function mint(uint256 tokenId, address to, uint256 genes, uint256 level) external returns (uint);
}


interface HEROES_OLD {
  function getLock(uint256 _tokenId) external view returns (uint256 lockedTo, uint16 lockId);
  function unlock(uint256 _tokenId, uint16 _lockId) external returns (bool);
  function lock(uint256 _tokenId, uint256 _lockedTo, uint16 _lockId) external returns (bool);
  function transferFrom(address _from, address _to, uint256 _tokenId) external;
  function getCharacter(uint256 _tokenId) external view returns (uint256 genes, uint256 mintedAt, uint256 godfather, uint256 mentor, uint32 wins, uint32 losses, uint32 level, uint256 lockedTo, uint16 lockId);
  function ownerOf(uint256 _tokenId) external view returns (address);
}

contract HeroUp is Ownable, CanReclaimToken {
  event HeroUpgraded(uint tokenId, address owner);

  HEROES_OLD public heroesOld;
  HEROES_NEW public heroesNew;
  constructor (HEROES_OLD _heroesOld, HEROES_NEW _heroesNew) public {
    require(address(_heroesOld) != address(0));
    require(address(_heroesNew) != address(0));
    heroesOld = _heroesOld;
    heroesNew = _heroesNew;
  }

  function() public {}

  function setOld(HEROES_OLD _heroesOld) public onlyOwner {
    require(address(_heroesOld) != address(0));
    heroesOld = _heroesOld;
  }

  function setNew(HEROES_NEW _heroesNew) public onlyOwner {
    require(address(_heroesNew) != address(0));
    heroesNew = _heroesNew;
  }

  function upgrade(uint _tokenId) public {
    require(msg.sender == heroesOld.ownerOf(_tokenId));
    uint256 genes;
    uint32 level;
    uint256 lockedTo;
    uint16 lockId;

    //transfer old hero
    (genes,,,,,,level,lockedTo,lockId) = heroesOld.getCharacter(_tokenId);
    heroesOld.unlock(_tokenId, lockId);
    heroesOld.lock(_tokenId, 0, 999);
    heroesOld.transferFrom(msg.sender, address(this), _tokenId);
//    heroesOld.unlock(_tokenId, 999);

    //mint new hero
    heroesNew.mint(_tokenId, msg.sender, genes, level);

    emit HeroUpgraded(_tokenId, msg.sender);
  }
}