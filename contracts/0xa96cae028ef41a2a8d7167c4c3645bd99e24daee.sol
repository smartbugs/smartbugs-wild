pragma solidity ^0.4.18;
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
/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
  address public owner;
  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  function Ownable() {
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
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param newOwner The address to transfer ownership to.
   */
  function transferOwnership(address newOwner) onlyOwner {
    require(newOwner != address(0));
    owner = newOwner;
  }
}
/**
 * @title KYC
 * @dev KYC contract handles the white list for ASTCrowdsale contract
 * Only accounts registered in KYC contract can buy AST token.
 * Admins can register account, and the reason why
 */
contract KYC is Ownable {
  // check the address is registered for token sale
  mapping (address => bool) public registeredAddress;
  // check the address is admin of kyc contract
  mapping (address => bool) public admin;
  event Registered(address indexed _addr);
  event Unregistered(address indexed _addr);
  event NewAdmin(address indexed _addr);
  event ClaimedTokens(address _token, address owner, uint256 balance);
  /**
   * @dev check whether the address is registered for token sale or not.
   * @param _addr address
   */
  modifier onlyRegistered(address _addr) {
    require(registeredAddress[_addr]);
    _;
  }
  /**
   * @dev check whether the msg.sender is admin or not
   */
  modifier onlyAdmin() {
    require(admin[msg.sender]);
    _;
  }
  function KYC() {
    admin[msg.sender] = true;
  }
  /**
   * @dev set new admin as admin of KYC contract
   * @param _addr address The address to set as admin of KYC contract
   */
  function setAdmin(address _addr)
    public
    onlyOwner
  {
    require(_addr != address(0) && admin[_addr] == false);
    admin[_addr] = true;
    NewAdmin(_addr);
  }
  /**
   * @dev register the address for token sale
   * @param _addr address The address to register for token sale
   */
  function register(address _addr)
    public
    onlyAdmin
  {
    require(_addr != address(0) && registeredAddress[_addr] == false);
    registeredAddress[_addr] = true;
    Registered(_addr);
  }
  /**
   * @dev register the addresses for token sale
   * @param _addrs address[] The addresses to register for token sale
   */
  function registerByList(address[] _addrs)
    public
    onlyAdmin
  {
    for(uint256 i = 0; i < _addrs.length; i++) {
      require(_addrs[i] != address(0) && registeredAddress[_addrs[i]] == false);
      registeredAddress[_addrs[i]] = true;
      Registered(_addrs[i]);
    }
  }
  /**
   * @dev unregister the registered address
   * @param _addr address The address to unregister for token sale
   */
  function unregister(address _addr)
    public
    onlyAdmin
    onlyRegistered(_addr)
  {
    registeredAddress[_addr] = false;
    Unregistered(_addr);
  }
  /**
   * @dev unregister the registered addresses
   * @param _addrs address[] The addresses to unregister for token sale
   */
  function unregisterByList(address[] _addrs)
    public
    onlyAdmin
  {
    for(uint256 i = 0; i < _addrs.length; i++) {
      require(registeredAddress[_addrs[i]]);
      registeredAddress[_addrs[i]] = false;
      Unregistered(_addrs[i]);
    }
  }
  function claimTokens(address _token) public onlyOwner {
    if (_token == 0x0) {
        owner.transfer(this.balance);
        return;
    }
    ERC20Basic token = ERC20Basic(_token);
    uint256 balance = token.balanceOf(this);
    token.transfer(owner, balance);
    ClaimedTokens(_token, owner, balance);
  }
}