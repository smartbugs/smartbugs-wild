// File: openzeppelin-solidity\contracts\ownership\Ownable.sol

pragma solidity ^0.5.0;

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev The Ownable constructor sets the original `owner` of the contract to the sender
     * account.
     */
    constructor () internal {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
    }

    /**
     * @return the address of the owner.
     */
    function owner() public view returns (address) {
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
    function isOwner() public view returns (bool) {
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

// File: openzeppelin-solidity\contracts\token\ERC20\IERC20.sol

pragma solidity ^0.5.0;

/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
interface IERC20 {
    function transfer(address to, uint256 value) external returns (bool);

    function approve(address spender, uint256 value) external returns (bool);

    function transferFrom(address from, address to, uint256 value) external returns (bool);

    function totalSupply() external view returns (uint256);

    function balanceOf(address who) external view returns (uint256);

    function allowance(address owner, address spender) external view returns (uint256);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}

// File: openzeppelin-solidity\contracts\math\SafeMath.sol

pragma solidity ^0.5.0;

/**
 * @title SafeMath
 * @dev Unsigned math operations with safety checks that revert on error
 */
library SafeMath {
    /**
    * @dev Multiplies two unsigned integers, reverts on overflow.
    */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b);

        return c;
    }

    /**
    * @dev Integer division of two unsigned integers truncating the quotient, reverts on division by zero.
    */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
    * @dev Subtracts two unsigned integers, reverts on overflow (i.e. if subtrahend is greater than minuend).
    */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a);
        uint256 c = a - b;

        return c;
    }

    /**
    * @dev Adds two unsigned integers, reverts on overflow.
    */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a);

        return c;
    }

    /**
    * @dev Divides two unsigned integers and returns the remainder (unsigned integer modulo),
    * reverts when dividing by zero.
    */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0);
        return a % b;
    }
}

// File: contracts\Furance.sol

pragma solidity >=0.5.2;

/**
This is hackathon edition of our Furance contract. Will be replaced with production version later.
 */





interface IPyroToken {
  function mint(address, uint) external returns(bool);
}


contract Furance is Ownable {
  event Burn(address indexed sender, address indexed token, uint value, uint pyroValue);
  using SafeMath for uint;
  
  bool public extinguished;
  uint public ashes;
  IPyroToken public pyro;

  uint constant alpha = 999892503784850936; // decay per block corresponds 0.5 decay per day
  uint constant DECIMAL_MULTIPLIER=1e18;
  uint constant DECIMAL_HALFMULTIPLIER=1e9;


  function _sqrt(uint x) internal pure returns (uint y) {
    uint z = (x + 1) >> 1;
    if ( x+1 == 0) z = 1<<255;
    y = x;
    while (z < y) {
      y = z;
      z = (x / z + z) >> 1;
    }
    y = y * DECIMAL_HALFMULTIPLIER;
  }

  /* solium-disable-next-line */
  function _pown(uint x, uint z) internal pure returns(uint) {
    uint res = DECIMAL_MULTIPLIER;
    uint t = z;
    uint bit;
    while (true) {
      t = z >> 1;
      bit = z - (t << 1);
      if (bit == 1)
        res = res.mul(x).div(DECIMAL_MULTIPLIER);
      if (t==0) break;
      z = t; 
      x = x.mul(x).div(DECIMAL_MULTIPLIER);
    }
    return res;
  }


  struct token {
    bool enabled;
    uint a; //mintable performance parameter, depending for market capitalization
    uint b; //tokens burned
    uint c; //tokens minted
    uint r; //burnrate
    uint kappa_0; //initial kappa
    uint w; //weight of initial kappa
    uint blockNumber;
  }

  mapping(address=>token) tokens;

  modifier notExitgushed {
    require(!extinguished);
    _;
  }

  function exitgush() public onlyOwner notExitgushed returns(bool) {
    extinguished=true;
    return true;
  }


  function bind() public returns(bool) {
    require(address(0) == address(pyro));
    pyro = IPyroToken(msg.sender);
    return true;
  }

  function _kappa(token storage t) internal view returns(uint) {
    return (t.c + t.kappa_0 * t.w / DECIMAL_MULTIPLIER) * DECIMAL_MULTIPLIER / (t.b + t.w);
  }


  function estimateMintAmount(address token_, uint value) public view returns(uint) {
    token storage t = tokens[token_];
    uint b_i = value;
    uint r_is = t.r * _pown(alpha, block.number - t.blockNumber) / DECIMAL_MULTIPLIER;
    uint r_i = r_is + value;
    uint c_i = t.a*(_sqrt(r_i) - _sqrt(r_is))/ DECIMAL_MULTIPLIER;
    uint kappa = _kappa(t);
    if (c_i > b_i*kappa/DECIMAL_MULTIPLIER) c_i = b_i*kappa/DECIMAL_MULTIPLIER;
    return c_i;
  }

  function getTokenState(address token_) public view returns(uint, uint, uint, uint, uint, uint) {
    token storage t = tokens[token_];
    return (t.a, t.b, t.c, t.r, _kappa(t), t.blockNumber);
  }

  function burn(address token_, uint value, uint minimalPyroValue) public notExitgushed returns (bool) {
    require(value > 0);
    require(IERC20(token_).transferFrom(msg.sender, address(this), value));
    token storage t = tokens[token_];
    require(t.enabled);
    uint b_i = value;
    uint r_is = t.r * _pown(alpha, block.number - t.blockNumber) / DECIMAL_MULTIPLIER;
    uint r_i = r_is + b_i;
    uint c_i = t.a*(_sqrt(r_i) - _sqrt(r_is)) / DECIMAL_MULTIPLIER;
    uint kappa = _kappa(t);
    if (c_i > b_i*kappa/DECIMAL_MULTIPLIER) c_i = b_i*kappa/DECIMAL_MULTIPLIER;
    require(c_i >= minimalPyroValue);
    t.b += b_i;
    t.c += c_i;
    t.r = r_i;
    t.blockNumber = block.number;
    if (IERC20(token_).balanceOf(msg.sender)==0) ashes+=1;
    pyro.mint(msg.sender, c_i);
    emit Burn(msg.sender, token_, b_i, c_i);
    return true;
  } 

  function addFuel(address token_, uint a, uint kappa0, uint w) public onlyOwner notExitgushed returns (bool) {
    tokens[token_] = token(true, a, 0, 0, 0, kappa0, w, block.number);
  }

}