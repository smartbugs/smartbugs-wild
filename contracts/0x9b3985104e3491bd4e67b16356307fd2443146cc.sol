pragma solidity ^0.4.24;

/**
 * @title ERC20Basic
 * @dev Simpler version of ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/179
 */
contract ERC20Basic {
  function totalSupply() public view returns (uint256);
  function balanceOf(address who) public view returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}

/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender)
    public view returns (uint256);

  function transferFrom(address from, address to, uint256 value)
    public returns (bool);

  function approve(address spender, uint256 value) public returns (bool);
  event Approval(
    address indexed owner,
    address indexed spender,
    uint256 value
  );
}


/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure.
 * To use this library you can add a `using SafeERC20 for ERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
  function safeTransfer(ERC20Basic token, address to, uint256 value) internal {
    require(token.transfer(to, value));
  }

  function safeTransferFrom(
    ERC20 token,
    address from,
    address to,
    uint256 value
  )
    internal
  {
    require(token.transferFrom(from, to, value));
  }

  function safeApprove(ERC20 token, address spender, uint256 value) internal {
    require(token.approve(spender, value));
  }
}


/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {

  /**
  * @dev Multiplies two numbers, throws on overflow.
  */
  function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
    // Gas optimization: this is cheaper than asserting 'a' not being zero, but the
    // benefit is lost if 'b' is also tested.
    // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
    if (a == 0) {
      return 0;
    }

    c = a * b;
    assert(c / a == b);
    return c;
  }

  /**
  * @dev Integer division of two numbers, truncating the quotient.
  */
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    // uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return a / b;
  }

  /**
  * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
  */
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  /**
  * @dev Adds two numbers, throws on overflow.
  */
  function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
    c = a + b;
    assert(c >= a);
    return c;
  }
}

contract OpetEscrow {

	using SafeMath for uint256;
	using SafeERC20 for ERC20;

	ERC20 public opetToken;
	address public opetWallet;

	ERC20 public pecunioToken;
	address public pecunioWallet;

	uint256 public depositCount;

	modifier onlyParticipants() {
	    require(msg.sender == opetWallet || msg.sender == pecunioWallet);
	    _;
	}

	constructor(ERC20 _opetToken, address _opetWallet, ERC20 _pecunioToken, address _pecunioWallet) public {
		require(_opetToken != address(0));
		require(_opetWallet != address(0));
		require(_pecunioToken != address(0));
		require(_pecunioWallet != address(0));

	    opetToken = _opetToken;
	    opetWallet = _opetWallet;
	    pecunioToken = _pecunioToken;
	    pecunioWallet = _pecunioWallet;
	    depositCount = 0;
	}

	function() public payable {
		revert();
	}

	function opetTokenBalance() view public returns (uint256) {
	    return opetToken.balanceOf(this);
	}

	function pecunioTokenBalance() view public returns (uint256) {
	    return pecunioToken.balanceOf(this);
	}

	function initiateDeposit() onlyParticipants public {
		require(depositCount < 2);

		uint256 opetInitital = uint256(2000000).mul(uint256(10)**uint256(18));
		uint256 pecunioInitital = uint256(1333333).mul(uint256(10)**uint256(8));

		require(opetToken.allowance(opetWallet, this) == opetInitital);
		require(pecunioToken.allowance(pecunioWallet, this) == pecunioInitital);

		opetToken.safeTransferFrom(opetWallet, this, opetInitital);
		pecunioToken.safeTransferFrom(pecunioWallet, this, pecunioInitital);

		depositCount = depositCount.add(1);
	}

	function refundTokens() onlyParticipants public {
		require(opetToken.balanceOf(this) > 0);
		require(pecunioToken.balanceOf(this) > 0);

		opetToken.safeTransfer(opetWallet, opetToken.balanceOf(this));
		pecunioToken.safeTransfer(pecunioWallet, pecunioToken.balanceOf(this));

	}

	function releaseTokens() onlyParticipants public {
		// 30-06-2019 00:00:00 UTC
		require(block.timestamp > 1561852800);
		require(opetToken.balanceOf(this) > 0);
		require(pecunioToken.balanceOf(this) > 0);

		opetToken.safeTransfer(pecunioWallet, opetToken.balanceOf(this));
		pecunioToken.safeTransfer(opetWallet, pecunioToken.balanceOf(this));
	}

}