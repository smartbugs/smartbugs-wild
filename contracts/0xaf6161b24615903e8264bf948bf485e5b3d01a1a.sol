pragma solidity ^0.4.24;

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

/**
 * @title ERC20Detailed token
 * @dev The decimals are only for visualization purposes.
 * All the operations are done using the smallest and indivisible token unit,
 * just as on Ethereum all the operations are done in wei.
 */
contract ERC20Detailed is IERC20 {
  string private _name;
  string private _symbol;
  uint8 private _decimals;

  constructor(string name, string symbol, uint8 decimals) public {
    _name = name;
    _symbol = symbol;
    _decimals = decimals;
  }

  /**
   * @return the name of the token.
   */
  function name() public view returns(string) {
    return _name;
  }

  /**
   * @return the symbol of the token.
   */
  function symbol() public view returns(string) {
    return _symbol;
  }

  /**
   * @return the number of decimals of the token.
   */
  function decimals() public view returns(uint8) {
    return _decimals;
  }
}

contract SupportEscrow is Ownable {
    ERC20Detailed public constant bznToken = ERC20Detailed(0x1BD223e638aEb3A943b8F617335E04f3e6B6fFfa);
    ERC20Detailed public constant gusdToken = ERC20Detailed(0x056Fd409E1d7A124BD7017459dFEa2F387b6d5Cd);
    
    //BZN has 18 decimals, so we must append 18 decimals to this number
    uint256 public constant bznRequirement = 13213 * (10 ** uint256(18));
    
    //gusd has two decimals, so the last two digits are for decimals
    //i.e 8888801 = $88,888.01
    //Therefore, 330330 = $3,303.30
    uint256 public constant gusdRequirement = 330330;

    //The minimum amount the contract must hold ($303.33)
    uint256 public constant gusdMinimum = 33033;
    
    //The date when assets unlock
    uint256 public constant unlockDate = 1551330000;
    
    bool public redeemed = false;
    bool public executed = false;
    bool public redeemable = false;
    address public thirdParty;
    
    modifier onlyThridParty {
        require(msg.sender == thirdParty);
        _;
    }
    
    constructor(address tp) public {
        thirdParty = tp;
    }
    
    function validate() public view returns (bool) {
        address self = address(this);
        
        uint256 bzn = bznToken.balanceOf(self);
        uint256 gusd = gusdToken.balanceOf(self);
        
        return bzn >= bznRequirement && gusd >= gusdRequirement;
    }
    
    function execute() public onlyOwner returns (bool) {
        //Ensure we haven't executed yet
        require(executed == false);
        
        address self = address(this);
        uint256 bzn = bznToken.balanceOf(self);
        
        //Ensure everything is in place before we execute
        require(bzn >= bznRequirement);
        
        //Transfer the BZN to the owner
        bznToken.transfer(owner(), bznRequirement);
        
        //We are done executing
        executed = true;
    }
    
    function destroy() public onlyOwner {
        address self = address(this);
        
        uint256 bzn = bznToken.balanceOf(self);
        uint256 gusd = gusdToken.balanceOf(self);
        
        //First return all funds
        if (executed == false) {
            //If it hasn't been executed yet, give funds back to third party
            
            bznToken.transfer(thirdParty, bzn);
            bznToken.transfer(thirdParty, gusd);
        } else if (redeemable && redeemed == false) {
            //If it hasn't been redeemed but was marked redeemable, give back to third party
            
            bznToken.transfer(thirdParty, bzn);
            bznToken.transfer(thirdParty, gusd);
        }
        
        selfdestruct(owner());
    }
    
    function allowRedeem() public onlyThridParty returns (uint256) {
        //Ensure this has been executed
        require(executed);
        //Ensure this hasn't been marked as redeemable yet
        require(redeemed == false);
        //Ensure this hasn't been redeemed yet
        require(redeemable == false);
        //Ensure the time is past the unlock date
        require(block.timestamp >= unlockDate);
        //Ensure everything is in place before marking it as redeemable
        require(validate());
        
        redeemable = true;
    }
    
    function redeem() public onlyOwner returns (uint256) {
        //Ensure this has been executed
        require(executed);
        //Ensure this is redeemable
        require(redeemable);
        //Ensure it hasn't been redeemed
        require(redeemed == false);
        //Ensure the time is past the unlock date
        require(block.timestamp >= unlockDate);
        //Ensure it's in the correct state
        require(validate());
        
        //Give back the BZN to the thrid party
        bznToken.transfer(thirdParty, bznRequirement);
        
        //Transfer gusd to the owner
        gusdToken.transfer(owner(), gusdRequirement);
        
        //Mark as redeemed
        redeemed = true;
    }
    
    function withdrawBZN(uint256 amount) public onlyThridParty {
        //You can only do this before execute() is called
        //This is a safety net to ensure you don't send more than you meant to
        //Or to reverse this contract before execute() is called
        require(executed == false);
        
        //Send back BZN to the third party
        bznToken.transfer(thirdParty, amount);
    }
}