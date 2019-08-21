pragma solidity >=0.5.0 <0.7.0;

/*
                                              N     .N      
                                            .ONN.   NN      
                                          ..NNDN  :NNNN     
                                         .8NN  NNNN. NN     
                                        NNN. .NNN....NN     
                                    ..NNN ~NNNO     .N:     
                                 .,NNNDNNNN?.       NN      
                    ..?NNNNNNNNNNNNNNND..          NN       
               ..$NNNNN$.    .=NNN=             ..NN        
             .NNNN,         .NNON               NNN         
           NNN+.           NN~.NN           ..NNN           
         NNN..            NN.  ON          .NNN             
      .:NN.              ,N=    NN.    .,NNNN               
      NNI.              .NN     .NNNNNNNN$.,N?              
    ,NN.                .NI     .NNN,.   .  NN.             
    NN .                ?N.       ?NNNNNN... NN             
    NN.                 NN=       ..NN .NNNN NN             
     NN                 NNN.         NN..NN.  NN            
     IN.                NNN.          :NNN=   :N,           
      NN.               N$NN..         .NN.   .NN           
      .NN.              N7 NN .               .NNI          
        NN.             NO  DNN  .          .ZNNNN.         
        .NN             NN .  NNN:..     ..NNN. .NN         
         .NN.           NN .  . INNNNNNNNNNNN:. .ZN         
           NNI.         NN       . NNNN+   .ONNN8 NN        
             NN.        .N.     .NN, $NN?   . .INNN         
              NN?       .NN    NNO     :NNNNNNNN+           
               ~NN      .NN   NN,                           
                .NNN.     NI..NI.                           
                   NNN    NN.NN                             
                    .NND.. NNNI                             
                       NNN.$NN.                             
                         ONNNN?                             
                            NNN                             

   ,        ,     II   N        NN     OOOOOO       SSSS    
   M        M     II   NN       NN   OOOOOOOOOO    SSSSSSS  
   MM      MM     II   NNN      NN  OOO      OOO  SS     SS   
   MMM    MMM     II   NNNN     NN OO?        OO  SS        
  MM~MM  MMMMM    II   NN NNN   NN OO         OO$  SSSSSS   
  MM MM  MM MM    II   NN  NNN  NN OO         OO=     SSSS  
  MM  MMMM  MM    II   NN   NNN:NN .OOO      OOO        SS  
 MM    MM    MM   II   NN    NNNNN  =OOO    OOO   SS    SS  
 MM    MM    MM   II   NN     NNNN    OOOOOOO      SSSSSS   
*/

/**
 * @title SafeMath
 * @dev Math operations with safety checks that revert on error
 */
library SafeMath {

  /**
  * @dev Multiplies two numbers, reverts on overflow.
  */
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }

    uint256 c = a * b;
    require(c / a == b);

    return c;
  }

  /**
  * @dev Integer division of two numbers truncating the quotient, reverts on division by zero.
  */
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b > 0); // Solidity only automatically asserts when dividing by 0
    uint256 c = a / b;

    return c;
  }

  /**
  * @dev Subtracts two numbers, reverts on overflow (i.e. if subtrahend is greater than minuend).
  */
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b <= a);
    uint256 c = a - b;

    return c;
  }

  /**
  * @dev Adds two numbers, reverts on overflow.
  */
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    require(c >= a);

    return c;
  }

  /**
  * @dev Divides two numbers and returns the remainder (unsigned integer modulo),
  * reverts when dividing by zero.
  */
  function mod(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b != 0);
    return a % b;
  }
}

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
  address private _owner;

  /**
   * Event that notifies clients about the ownership transference
   * @param previousOwner Address registered as the former owner
   * @param newOwner Address that is registered as the new owner
   */
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
    require(isOwner(), "Ownable: Caller is not the owner");
    _;
  }

  /**
   * @return true if `msg.sender` is the owner of the contract.
   */
  function isOwner() public view returns(bool) {
    return msg.sender == _owner;
  }

  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param newOwner The address to transfer ownership to.
   */
  function transferOwnership(address newOwner) public onlyOwner {
    require(newOwner != address(0), "Ownable: New owner is the zero address");
    emit OwnershipTransferred(_owner, newOwner);
    _owner = newOwner;
  }
}

/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20.md
 */
interface IERC20 {

  function balanceOf(address account) external view returns (uint256);
 
  function transfer(address to, uint256 value) external returns (bool);

  function transferFrom(address from, address to, uint256 value)
    external returns (bool);

  function approve(address spender, uint256 value)
    external returns (bool);

  function allowance(address owner, address spender)
    external view returns (uint256);

  /**
   * Event that notifies clients about the amount transferred
   * @param from Address owner of the transferred funds
   * @param to Destination address
   * @param value Amount of tokens transferred
   */
  event Transfer(
    address indexed from,
    address indexed to,
    uint256 value
  );

  /**
   * Event that notifies clients about the amount approved to be spent
   * @param owner Address owner of the approved funds
   * @param spender The address authorized to spend the funds
   * @param value Amount of tokens approved
   */
  event Approval(
    address indexed owner,
    address indexed spender,
    uint256 value
  );
}

/**
 * @title ERC20
 * @dev Implements the functions declared in the IERC20 interface
 */
contract ERC20 is IERC20 {
  using SafeMath for uint256;

  mapping (address => uint256) internal balances;
  mapping (address => mapping (address => uint256)) internal allowed;

  uint256 public totalSupply;
  
  constructor(uint256 initialSupply) internal {
    require(msg.sender != address(0));
    totalSupply = initialSupply;
    balances[msg.sender] = initialSupply;
    emit Transfer(address(0), msg.sender, initialSupply);
  }

  /**
   * @dev Gets the balance of the specified address.
   * @param account The address to query the balance of.
   * @return An uint256 representing the amount owned by the passed address.
   */
  function balanceOf(address account) external view returns (uint256) {
    return balances[account];
  }

  /**
   * @dev Transfer token for a specified address
   * @param to The address to transfer to.
   * @param value The amount to be transferred.
   */
  function transfer(address to, uint256 value) public returns (bool) {
    require(value <= balances[msg.sender]);
    require(to != address(0));

    balances[msg.sender] = balances[msg.sender].sub(value);
    balances[to] = balances[to].add(value);
    emit Transfer(msg.sender, to, value);
    return true;
  }

  /**
   * @dev Transfer tokens from one address to another
   * @param from address The address which you want to send tokens from
   * @param to address The address which you want to transfer to
   * @param value uint256 the amount of tokens to be transferred
   */
  function transferFrom(
    address from,
    address to,
    uint256 value
  )
    public
    returns (bool)
  {
    require(value <= balances[from]);
    require(value <= allowed[from][msg.sender]);
    require(to != address(0));

    balances[from] = balances[from].sub(value);
    balances[to] = balances[to].add(value);
    allowed[from][msg.sender] = allowed[from][msg.sender].sub(value);
    emit Transfer(from, to, value);
    return true;
  }

  /**
   * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.
   * Beware that changing an allowance with this method brings the risk that someone may use both the old
   * and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this
   * race condition is to first reduce the spender's allowance to 0 and set the desired value afterwards:
   * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
   * @param spender The address which will spend the funds.
   * @param value The amount of tokens to be spent.
   */
  function approve(address spender, uint256 value) public returns (bool) {
    require(spender != address(0));

    allowed[msg.sender][spender] = value;
    emit Approval(msg.sender, spender, value);
    return true;
  }

  /**
   * @dev Function to check the amount of tokens that an owner allowed to a spender.
   * @param owner address The address which owns the funds.
   * @param spender address The address which will spend the funds.
   * @return A uint256 specifying the amount of tokens still available for the spender.
   */
  function allowance(
    address owner,
    address spender
   )
    external
    view
    returns (uint256)
  {
    return allowed[owner][spender];
  }

  /**
   * @dev Increase the amount of tokens that an owner allowed to a spender.
   * approve should be called when allowed[spender] == 0. To increment
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   * @param spender The address which will spend the funds.
   * @param addedValue The amount of tokens to increase the allowance by.
   */
  function increaseAllowance(
    address spender,
    uint256 addedValue
  )
    public
    returns (bool)
  {
    require(spender != address(0));

    allowed[msg.sender][spender] = (
      allowed[msg.sender][spender].add(addedValue));
    emit Approval(msg.sender, spender, allowed[msg.sender][spender]);
    return true;
  }

  /**
   * @dev Decrease the amount of tokens that an owner allowed to a spender.
   * approve should be called when allowed[spender] == 0. To decrement
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   * @param spender The address which will spend the funds.
   * @param subtractedValue The amount of tokens to decrease the allowance by.
   */
  function decreaseAllowance(
    address spender,
    uint256 subtractedValue
  )
    public
    returns (bool)
  {
    require(spender != address(0));

    allowed[msg.sender][spender] = (
      allowed[msg.sender][spender].sub(subtractedValue));
    emit Approval(msg.sender, spender, allowed[msg.sender][spender]);
    return true;
  }
}

/**
 * @title Burnable Token
 * @dev Token that can be irreversibly burned (destroyed).
 */
contract Burnable is ERC20 {

  /**
   * Event that notifies clients about the amount burnt
   * @param from Address owner of the burnt funds
   * @param value Amount of tokens burnt
   */
  event Burn(
    address indexed from,
    uint256 value
  );
  
  /**
   * @dev Burns a specific amount of tokens.
   * @param value The amount of token to be burned.
   */
  function burn(uint256 value) public {
    _burn(msg.sender, value);
  }

  /**
   * @dev Burns a specific amount of tokens from the target address and decrements allowance
   * @param from address The address which you want to send tokens from
   * @param value uint256 The amount of token to be burned
   */
  function burnFrom(address from, uint256 value) public {
    require(value <= allowed[from][msg.sender], "Burnable: Amount to be burnt exceeds the account balance");

    // Should https://github.com/OpenZeppelin/zeppelin-solidity/issues/707 be accepted,
    // this function needs to emit an event with the updated approval.
    allowed[from][msg.sender] = allowed[from][msg.sender].sub(value);
    _burn(from, value);
  }

  /**
   * @dev Internal function that burns an amount of the token of a given
   * account.
   * @param account The account whose tokens will be burnt.
   * @param amount The amount that will be burnt.
   */
  function _burn(address account, uint256 amount) internal {
    require(account != address(0), "Burnable: Burn from the zero address");
    require(amount > 0, "Burnable: Can not burn negative amount");
    require(amount <= balances[account], "Burnable: Amount to be burnt exceeds the account balance");

    totalSupply = totalSupply.sub(amount);
    balances[account] = balances[account].sub(amount);
    emit Burn(account, amount);
  }
}

/**
 * @title Freezable Token
 * @dev Token that can be frozen.
 */
contract Freezable is ERC20 {

  mapping (address => uint256) private _freeze;

  /**
   * Event that notifies clients about the amount frozen
   * @param from Address owner of the frozen funds
   * @param value Amount of tokens frozen
   */
  event Freeze(
    address indexed from,
    uint256 value
  );

  /**
   * Event that notifies clients about the amount unfrozen
   * @param from Address owner of the unfrozen funds
   * @param value Amount of tokens unfrozen
   */
  event Unfreeze(
    address indexed from,
    uint256 value
  );

  /**
   * @dev Gets the frozen balance of the specified address.
   * @param account The address to query the frozen balance of.
   * @return An uint256 representing the amount frozen by the passed address.
   */
  function freezeOf(address account) public view returns (uint256) {
    return _freeze[account];
  }

  /**
   * @dev Freezes a specific amount of tokens
   * @param amount uint256 The amount of token to be frozen
   */
  function freeze(uint256 amount) public {
    require(balances[msg.sender] >= amount, "Freezable: Amount to be frozen exceeds the account balance");
    require(amount > 0, "Freezable: Can not freeze negative amount");
    balances[msg.sender] = balances[msg.sender].sub(amount);
    _freeze[msg.sender] = _freeze[msg.sender].add(amount);
    emit Freeze(msg.sender, amount);
  }

  /**
   * @dev Unfreezes a specific amount of tokens
   * @param amount uint256 The amount of token to be unfrozen
   */
  function unfreeze(uint256 amount) public {
    require(_freeze[msg.sender] >= amount, "Freezable: Amount to be unfrozen exceeds the account balance");
    require(amount > 0, "Freezable: Can not unfreeze negative amount");
    _freeze[msg.sender] = _freeze[msg.sender].sub(amount);
    balances[msg.sender] = balances[msg.sender].add(amount);
    emit Unfreeze(msg.sender, amount);
  }
}

/**
 * @title MinosCoin 
 * @dev Contract for MinosCoin token
 **/
contract MinosCoin is ERC20, Burnable, Freezable, Ownable {

  string public constant name = "MinosCoin";
  string public constant symbol = "MNS";
  uint8 public constant decimals = 18;

  // Initial supply is the balance assigned to the owner
  uint256 private constant _initialSupply = 300000000 * (10 ** uint256(decimals));

  /**
   * @dev Constructor
   */
  constructor() 
    public 
    ERC20(_initialSupply)
  {
    require(msg.sender != address(0), "MinosCoin: Create contract from the zero address");
  }
  
  /**
   * @dev Allows to transfer out the ether balance that was sent into this contract
   */
  function withdrawEther() public onlyOwner {
    uint256 totalBalance = address(this).balance;
    require(totalBalance > 0, "MinosCoin: No ether available to be withdrawn");
    msg.sender.transfer(totalBalance);
  }
}