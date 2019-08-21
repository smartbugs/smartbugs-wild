pragma solidity ^0.5.7;


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
      * It will not be possible to call the functions with the `onlyOwner`
      * modifier anymore.
      * @notice Renouncing ownership will leave the contract without an owner,
      * thereby removing any functionality that is only available to the owner.
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



 contract Pausable is Ownable {
   event Pause();
   event Unpause();

   bool public paused = false;


   /**
    * @dev Modifier to make a function callable only when the contract is not paused.
    */
   modifier whenNotPaused() {
     require(!paused);
     _;
   }

   /**
    * @dev Modifier to make a function callable only when the contract is paused.
    */
   modifier whenPaused() {
     require(paused);
     _;
   }

   /**
    * @dev called by the owner to pause, triggers stopped state
    */
   function pause() onlyOwner whenNotPaused public {
     paused = true;
     emit Pause();
   }

   /**
    * @dev called by the owner to unpause, returns to normal state
    */
   function unpause() onlyOwner whenPaused public {
     paused = false;
     emit Unpause();
   }
 }


contract IERC20 {
    function transfer(address to, uint256 value) external returns (bool);

    function approve(address spender, uint256 value) external returns (bool);

    function transferFrom(address from, address to, uint256 value) external returns (bool);

    function totalSupply() external view returns (uint256);

    function balanceOf(address who) external view returns (uint256);

    function allowance(address owner, address spender) external view returns (uint256);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract ERC20 is IERC20 {
    using SafeMath for uint256;

    mapping (address => uint256) public _balances;

    mapping (address => mapping (address => uint256)) private _allowed;

    uint256 public totalSupply;


    /**
     * @dev Gets the balance of the specified address.
     * @param owner The address to query the balance of.
     * @return A uint256 representing the amount owned by the passed address.
     */
    function balanceOf(address owner) public view returns (uint256) {
        return _balances[owner];
    }

    /**
     * @dev Function to check the amount of tokens that an owner allowed to a spender.
     * @param owner address The address which owns the funds.
     * @param spender address The address which will spend the funds.
     * @return A uint256 specifying the amount of tokens still available for the spender.
     */
    function allowance(address owner, address spender) public view returns (uint256) {
        return _allowed[owner][spender];
    }

    /**
     * @dev Transfer token to a specified address
     * @param to The address to transfer to.
     * @param value The amount to be transferred.
     */
    function transfer(address to, uint256 value) public returns (bool) {
        _transfer(msg.sender, to, value);
        return true;
    }


    function approve(address spender, uint256 value) public returns (bool) {
        _approve(msg.sender, spender, value);
        return true;
    }

  
    function transferFrom(address from, address to, uint256 value) public returns (bool) {
        _transfer(from, to, value);
        _approve(from, msg.sender, _allowed[from][msg.sender].sub(value));
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        _approve(msg.sender, spender, _allowed[msg.sender][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        _approve(msg.sender, spender, _allowed[msg.sender][spender].sub(subtractedValue));
        return true;
    }

    function _transfer(address from, address to, uint256 value) internal {
        require(to != address(0));

        _balances[from] = _balances[from].sub(value);
        _balances[to] = _balances[to].add(value);
        emit Transfer(from, to, value);
    }


    function _approve(address owner, address spender, uint256 value) internal {
        require(spender != address(0));
        require(owner != address(0));

        _allowed[owner][spender] = value;
        emit Approval(owner, spender, value);
    }


}




contract ERC20Pausable is ERC20, Pausable {
    function transfer(address to, uint256 value) public whenNotPaused returns (bool) {
        return super.transfer(to, value);
    }

    function transferFrom(address from, address to, uint256 value) public whenNotPaused returns (bool) {
        return super.transferFrom(from, to, value);
    }

    function approve(address spender, uint256 value) public whenNotPaused returns (bool) {
        return super.approve(spender, value);
    }

    function increaseAllowance(address spender, uint addedValue) public whenNotPaused returns (bool success) {
        return super.increaseAllowance(spender, addedValue);
    }

    function decreaseAllowance(address spender, uint subtractedValue) public whenNotPaused returns (bool success) {
        return super.decreaseAllowance(spender, subtractedValue);
    }
}






contract MVITc is Ownable {


  MVITtoken public token;
  uint256 constant public tokenDecimals = 18;
  uint256 public totalSupply = 90000000 * (10 ** uint256(tokenDecimals));

  constructor () public {

    token = createTokenContract();
    token.unpause();
  }



  //
  // Token related operations
  //

  // creates the token to be sold.
  // override this method to have crowdsale of a specific mintable token.
  function createTokenContract() internal returns (MVITtoken) {
    return new MVITtoken();
  }

  // enable token transferability
  function enableTokenTransferability() external onlyOwner {
    token.unpause();
  }

  // disable token transferability
  function disableTokenTransferability() external onlyOwner {
    token.pause();
  }

  // transfer token to designated address
  function transfer(address to, uint256 value) external onlyOwner returns (bool ok)  {
    uint256 converterdValue = value * (10 ** uint256(tokenDecimals));
    return token.transfer(to, converterdValue);
   }



}





contract MVITtoken is ERC20Pausable {
  string constant public name = "MVit Token";
  string constant public symbol = "MVT";
  uint8 constant public decimals = 18;
  uint256 constant TOKEN_UNIT = 10 ** uint256(decimals);
  uint256 constant INITIAL_SUPPLY = 90000000 * TOKEN_UNIT;


  constructor () public {
    // Set untransferable by default to the token
    paused = true;
    // asign all tokens to the contract creator
    totalSupply = INITIAL_SUPPLY;

    _balances[msg.sender] = INITIAL_SUPPLY;
  }



}



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