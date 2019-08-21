pragma solidity ^0.4.23;

// File: contracts/lib/Ownerable.sol

contract Ownerable {
    /// @notice The address of the owner is the only address that can call
    ///  a function with this modifier
    modifier onlyOwner { require(msg.sender == owner); _; }

    address public owner;

    constructor() public { owner = msg.sender;}

    /// @notice Changes the owner of the contract
    /// @param _newOwner The new owner of the contract
    function setOwner(address _newOwner) public onlyOwner {
        owner = _newOwner;
    }
}

// File: contracts/lib/SafeMath.sol

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
contract SafeMath {
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }

  function max64(uint64 a, uint64 b) internal pure returns (uint64) {
    return a >= b ? a : b;
  }

  function min64(uint64 a, uint64 b) internal pure returns (uint64) {
    return a < b ? a : b;
  }

  function max256(uint256 a, uint256 b) internal pure returns (uint256) {
    return a >= b ? a : b;
  }

  function min256(uint256 a, uint256 b) internal pure returns (uint256) {
    return a < b ? a : b;
  }
}

// File: contracts/token/ERC20Basic.sol

/**
 * @title ERC20Basic
 * @dev Simpler version of ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/179
 */
contract ERC20Basic {
  uint256 public totalSupply;
  function balanceOf(address who) public view returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}

// File: contracts/token/ERC20.sol

/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender) public view returns (uint256);
  function transferFrom(address from, address to, uint256 value) public returns (bool);
  function approve(address spender, uint256 value) public returns (bool);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}

// File: contracts/token/SafeERC20.sol

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure.
 * To use this library you can add a `using SafeERC20 for ERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
  function safeTransfer(ERC20Basic token, address to, uint256 value) internal {
    assert(token.transfer(to, value));
  }

  function safeTransferFrom(ERC20 token, address from, address to, uint256 value) internal {
    assert(token.transferFrom(from, to, value));
  }

  function safeApprove(ERC20 token, address spender, uint256 value) internal {
    assert(token.approve(spender, value));
  }
}

// File: contracts/TokenDistor.sol

contract TokenDistor is Ownerable, SafeMath {
  using SafeERC20 for ERC20Basic;

  ERC20Basic token;

  constructor() public {
  }

  function setToken(address _token) public onlyOwner {
    require(_token != 0x0);
    token = ERC20Basic(_token);
  }

  function airdrop(address[] _tos, uint256[] _amts) public onlyOwner {
    require(_tos.length == _amts.length);

    uint256 totalSendingAmt = 0;

    for(uint i=0; i<_tos.length; i++) {
      /* require(_tos[i] != 0x0);
      require(_amts[i] > 0); */

      totalSendingAmt = add(totalSendingAmt, _amts[i]);
    }

    uint256 tokenBalance = token.balanceOf(address(this));
    require(tokenBalance >= totalSendingAmt);

    for(i=0; i<_tos.length; i++) {
      if(_tos[i] != 0x0 && _amts[i] > 0) {
        token.safeTransfer(_tos[i], _amts[i]);
      }
    }
  }

  function distStaticAmount(address[] _tos, uint256 _amt) public onlyOwner {
    require(_tos.length > 0);
    require(_amt > 0);

    uint256 totalSendingAmt = mul(_amt, _tos.length);
    uint256 tokenBalance = token.balanceOf(address(this));
    require(tokenBalance >= totalSendingAmt);

    for(uint i=0; i<_tos.length; i++) {
      if(_tos[i] != 0x0) {
        token.safeTransfer(_tos[i], _amt);
      }
    }
  }

  function claimTokens(address _to) public onlyOwner {
    require(_to != 0x0);
    
    uint256 tokenBalance = token.balanceOf(address(this));
    require(tokenBalance > 0);

    token.safeTransfer(_to, tokenBalance);
  }
}