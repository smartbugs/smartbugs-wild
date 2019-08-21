pragma solidity ^0.4.24;


interface DelegatedERC20 {
    function allowance(address _owner, address _spender) external view returns (uint256); 
    function transferFrom(address from, address to, uint256 value, address sender) external returns (bool); 
    function approve(address _spender, uint256 _value, address sender) external returns (bool);
    function totalSupply() external view returns (uint256);
    function balanceOf(address _owner) external view returns (uint256);
    function transfer(address _to, uint256 _value, address sender) external returns (bool);
}



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


/**
 * @title TokenFront is intended to provide a permanent address for a
 * restricted token.  Systems which intend to use the token front should not
 * emit ERC20 events.  Rather this contract should emit them. 
 */
contract TokenFront is ERC20, Ownable {

    string public name = "Test Fox Token";
    string public symbol = "TFT";

    DelegatedERC20 public tokenLogic;
    
    constructor(DelegatedERC20 _tokenLogic, address _owner) public {
        owner = _owner;
        tokenLogic = _tokenLogic; 
    }

    function migrate(DelegatedERC20 newTokenLogic) public onlyOwner {
        tokenLogic = newTokenLogic;
    }

    function allowance(address owner, address spender) 
        public 
        view 
        returns (uint256)
    {
        return tokenLogic.allowance(owner, spender);
    }

    function transferFrom(address from, address to, uint256 value) public returns (bool) {
        if (tokenLogic.transferFrom(from, to, value, msg.sender)) {
            emit Transfer(from, to, value);
            return true;
        } 
        return false;
    }

    function approve(address spender, uint256 value) public returns (bool) {
        if (tokenLogic.approve(spender, value, msg.sender)) {
            emit Approval(msg.sender, spender, value);
            return true;
        }
        return false;
    }

    function totalSupply() public view returns (uint256) {
        return tokenLogic.totalSupply();
    }
    
    function balanceOf(address who) public view returns (uint256) {
        return tokenLogic.balanceOf(who);
    }

    function transfer(address to, uint256 value) public returns (bool) {
        if (tokenLogic.transfer(to, value, msg.sender)) {
            emit Transfer(msg.sender, to, value);
            return true;
        } 
        return false;
    }

}