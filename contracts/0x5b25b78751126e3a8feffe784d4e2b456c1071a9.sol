pragma solidity ^0.4.22;
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




// ERC20 Standard Token valuable interface
contract StandardToken  {
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool);
    function approve(address _spender, uint256 _value) public returns (bool);
    function allowance(address _owner, address _spender) public view returns (uint256);
    function balanceOf(address who) public view returns (uint256);
    function transfer(address to, uint256 value) public returns (bool);
}



// Main contract
contract GESCrowdsale is Ownable {

    /*** STORAGE CONSTANTS ***/

    StandardToken public token;


    /*** CONSTRUCTOR ***/

    /**
      * @param _token Address of the Token
      */
    constructor(StandardToken _token) public {
        require(_token != address(0));
        token = _token;
    }

    /**
     * @dev set token address
     */
    function setTokenAddress(address _addr) public onlyOwner returns (bool) {
        token = StandardToken(_addr);
        return true;

    }

    /**
     * @dev send tokens to recipients, up to 300 recipients per tx
     */
    function sendTokensToRecipients(address[] _recipients, uint256[] _values) onlyOwner public returns (bool) {
        require(_recipients.length == _values.length);
        uint256 i = 0;
        while (i < _recipients.length) {
            if (_values[i] > 0) {
                StandardToken(token).transfer(_recipients[i], _values[i]);
            }
            i += 1;
        }
        return true;
    }
}