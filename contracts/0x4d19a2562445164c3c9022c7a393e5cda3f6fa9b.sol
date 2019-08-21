//File: node_modules\openzeppelin-solidity\contracts\ownership\Ownable.sol
pragma solidity ^0.4.24;


/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
  address public owner;


  event OwnershipRenounced(address indexed previousOwner);
  event OwnershipTransferred(
    address indexed previousOwner,
    address indexed newOwner
  );


  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  constructor() public {
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
   * @dev Allows the current owner to relinquish control of the contract.
   * @notice Renouncing to ownership will leave the contract without an owner.
   * It will not be possible to call the functions with the `onlyOwner`
   * modifier anymore.
   */
  function renounceOwnership() public onlyOwner {
    emit OwnershipRenounced(owner);
    owner = address(0);
  }

  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param _newOwner The address to transfer ownership to.
   */
  function transferOwnership(address _newOwner) public onlyOwner {
    _transferOwnership(_newOwner);
  }

  /**
   * @dev Transfers control of the contract to a newOwner.
   * @param _newOwner The address to transfer ownership to.
   */
  function _transferOwnership(address _newOwner) internal {
    require(_newOwner != address(0));
    emit OwnershipTransferred(owner, _newOwner);
    owner = _newOwner;
  }
}

//File: node_modules\openzeppelin-solidity\contracts\token\ERC20\ERC20Basic.sol
pragma solidity ^0.4.24;


/**
 * @title ERC20Basic
 * @dev Simpler version of ERC20 interface
 * See https://github.com/ethereum/EIPs/issues/179
 */
contract ERC20Basic {
  function totalSupply() public view returns (uint256);
  function balanceOf(address _who) public view returns (uint256);
  function transfer(address _to, uint256 _value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}

//File: node_modules\openzeppelin-solidity\contracts\token\ERC20\ERC20.sol
pragma solidity ^0.4.24;




/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20 is ERC20Basic {
  function allowance(address _owner, address _spender)
    public view returns (uint256);

  function transferFrom(address _from, address _to, uint256 _value)
    public returns (bool);

  function approve(address _spender, uint256 _value) public returns (bool);
  event Approval(
    address indexed owner,
    address indexed spender,
    uint256 value
  );
}

//File: node_modules\openzeppelin-solidity\contracts\token\ERC20\SafeERC20.sol
pragma solidity ^0.4.24;





/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure.
 * To use this library you can add a `using SafeERC20 for ERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
  function safeTransfer(
    ERC20Basic _token,
    address _to,
    uint256 _value
  )
    internal
  {
    require(_token.transfer(_to, _value));
  }

  function safeTransferFrom(
    ERC20 _token,
    address _from,
    address _to,
    uint256 _value
  )
    internal
  {
    require(_token.transferFrom(_from, _to, _value));
  }

  function safeApprove(
    ERC20 _token,
    address _spender,
    uint256 _value
  )
    internal
  {
    require(_token.approve(_spender, _value));
  }
}

//File: node_modules\openzeppelin-solidity\contracts\math\SafeMath.sol
pragma solidity ^0.4.24;


/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {

  /**
  * @dev Multiplies two numbers, throws on overflow.
  */
  function mul(uint256 _a, uint256 _b) internal pure returns (uint256 c) {
    // Gas optimization: this is cheaper than asserting 'a' not being zero, but the
    // benefit is lost if 'b' is also tested.
    // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
    if (_a == 0) {
      return 0;
    }

    c = _a * _b;
    assert(c / _a == _b);
    return c;
  }

  /**
  * @dev Integer division of two numbers, truncating the quotient.
  */
  function div(uint256 _a, uint256 _b) internal pure returns (uint256) {
    // assert(_b > 0); // Solidity automatically throws when dividing by 0
    // uint256 c = _a / _b;
    // assert(_a == _b * c + _a % _b); // There is no case in which this doesn't hold
    return _a / _b;
  }

  /**
  * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
  */
  function sub(uint256 _a, uint256 _b) internal pure returns (uint256) {
    assert(_b <= _a);
    return _a - _b;
  }

  /**
  * @dev Adds two numbers, throws on overflow.
  */
  function add(uint256 _a, uint256 _b) internal pure returns (uint256 c) {
    c = _a + _b;
    assert(c >= _a);
    return c;
  }
}

//File: contracts\ico\BountyDistribution.sol
/**
 * @title TILE Token Distribution - LOOMIA
 * @author Pactum IO <dev@pactum.io>
 */
pragma solidity ^0.4.24;





contract TileDistribution is Ownable {
    using SafeMath for uint256;

    /*** VARIABLES ***/
    ERC20Basic public token; // The token being distributed

    /*** EVENTS ***/
    event AirDrop(address indexed _beneficiaryAddress, uint256 _amount);

    /*** MODIFIERS ***/
    modifier validAddressAmount(address _beneficiaryWallet, uint256 _amount) {
        require(_beneficiaryWallet != address(0));
        require(_amount != 0);
        _;
    }

    constructor(address _token) public {
        require(_token != address(0));

        token = ERC20Basic(_token);
    }

    /*** PUBLIC || EXTERNAL ***/

    /**
     * @dev This function is the batch send function for Token distribution. It accepts an array of addresses and amounts
     * @param _beneficiaryWallets the address where tokens will be deposited into
     * @param _amounts the token amount in wei to send to the associated beneficiary
     */
    function batchDistributeTokens(address[] _beneficiaryWallets, uint256[] _amounts) external onlyOwner {
        require(_beneficiaryWallets.length == _amounts.length);
        for (uint i = 0; i < _beneficiaryWallets.length; i++) {
            distributeTokens(_beneficiaryWallets[i], _amounts[i]);
        }
    }

    /**
     * @dev Single token airdrop function. It is for a single transfer of tokens to beneficiary
     * @param _beneficiaryWallet the address where tokens will be deposited into
     * @param _amount the token amount in wei to send to the associated beneficiary
     */
    function distributeTokens(address _beneficiaryWallet, uint256 _amount) public onlyOwner validAddressAmount(_beneficiaryWallet, _amount) {
        token.transfer(_beneficiaryWallet, _amount);
        emit AirDrop(_beneficiaryWallet, _amount);
    }
}