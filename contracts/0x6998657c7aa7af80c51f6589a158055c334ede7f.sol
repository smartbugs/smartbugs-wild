pragma solidity 0.4.19;

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {
  function mul(uint256 a, uint256 b) internal returns (uint256) {
    uint256 c = a * b;
    require(a == 0 || c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal returns (uint256) {
    //   require(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    //   require(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  function sub(uint256 a, uint256 b) internal returns (uint256) {
    require(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal returns (uint256) {
    uint256 c = a + b;
    require(c >= a);
    return c;
  }
}

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
  address public owner;


  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


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
  function transferOwnership(address newOwner) onlyOwner public {
    require(newOwner != address(0));
    OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }

}

contract Governable {

  // list of admins
  address[] public admins;

  function Governable() {
    admins.length = 1;
    admins[0] = msg.sender;
  }

  modifier onlyAdmins() {
    bool isAdmin = false;
    for (uint256 i = 0; i < admins.length; i++) {
      if (msg.sender == admins[i]) {
        isAdmin = true;
      }
    }
    require(isAdmin == true);
    _;
  }

  function addAdmin(address _admin) public onlyAdmins {
    for (uint256 i = 0; i < admins.length; i++) {
      require(_admin != admins[i]);
    }
    require(admins.length < 10);
    admins[admins.length++] = _admin;
  }

  function removeAdmin(address _admin) public onlyAdmins {
    uint256 pos = admins.length;
    for (uint256 i = 0; i < admins.length; i++) {
      if (_admin == admins[i]) {
        pos = i;
      }
    }
    require(pos < admins.length);
    // if not last element, switch with last
    if (pos < admins.length - 1) {
      admins[pos] = admins[admins.length - 1];
    }
    // then cut off the tail
    admins.length--;
  }

}

/**
 * @title Pausable
 * @dev Base contract which allows children to implement an emergency stop mechanism.
 */
contract Pausable is Governable {
  event Pause();
  event Unpause();

  bool public paused = true;


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
  function pause() onlyAdmins whenNotPaused public {
    paused = true;
    Pause();
  }

  /**
   * @dev called by the owner to unpause, returns to normal state
   */
  function unpause() onlyAdmins whenPaused public {
    paused = false;
    Unpause();
  }
}

contract DataCentre is Ownable {
    struct Container {
        mapping(bytes32 => uint256) values;
        mapping(bytes32 => address) addresses;
        mapping(bytes32 => bool) switches;
        mapping(address => uint256) balances;
        mapping(address => mapping (address => uint)) constraints;
    }

    mapping(bytes32 => Container) containers;

    // Owner Functions
    function setValue(bytes32 _container, bytes32 _key, uint256 _value) onlyOwner {
        containers[_container].values[_key] = _value;
    }

    function setAddress(bytes32 _container, bytes32 _key, address _value) onlyOwner {
        containers[_container].addresses[_key] = _value;
    }

    function setBool(bytes32 _container, bytes32 _key, bool _value) onlyOwner {
        containers[_container].switches[_key] = _value;
    }

    function setBalanace(bytes32 _container, address _key, uint256 _value) onlyOwner {
        containers[_container].balances[_key] = _value;
    }


    function setConstraint(bytes32 _container, address _source, address _key, uint256 _value) onlyOwner {
        containers[_container].constraints[_source][_key] = _value;
    }

    // Constant Functions
    function getValue(bytes32 _container, bytes32 _key) constant returns(uint256) {
        return containers[_container].values[_key];
    }

    function getAddress(bytes32 _container, bytes32 _key) constant returns(address) {
        return containers[_container].addresses[_key];
    }

    function getBool(bytes32 _container, bytes32 _key) constant returns(bool) {
        return containers[_container].switches[_key];
    }

    function getBalanace(bytes32 _container, address _key) constant returns(uint256) {
        return containers[_container].balances[_key];
    }

    function getConstraint(bytes32 _container, address _source, address _key) constant returns(uint256) {
        return containers[_container].constraints[_source][_key];
    }
}

contract ERC223ReceivingContract {
    function tokenFallback(address _from, uint _value, bytes _data);
}


/*
 * ERC20Basic
 * Simpler version of ERC20 interface
 * see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20Basic {
  function totalSupply() constant returns (uint256);
  function balanceOf(address _owner) constant returns (uint256);
  function transfer(address _to, uint256 _value) returns (bool);
  event Transfer(address indexed from, address indexed to, uint value);
}

contract ERC223Basic is ERC20Basic {
    function transfer(address to, uint value, bytes data) returns (bool);
}

/*
 * ERC20 interface
 * see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20 is ERC223Basic {
  // active supply of tokens
  function allowance(address _owner, address _spender) constant returns (uint256);
  function transferFrom(address _from, address _to, uint _value) returns (bool);
  function approve(address _spender, uint256 _value) returns (bool);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract ControllerInterface {

  function totalSupply() constant returns (uint256);
  function balanceOf(address _owner) constant returns (uint256);
  function allowance(address _owner, address _spender) constant returns (uint256);

  function approve(address owner, address spender, uint256 value) public returns (bool);
  function transfer(address owner, address to, uint value, bytes data) public returns (bool);
  function transferFrom(address owner, address from, address to, uint256 amount, bytes data) public returns (bool);
  function mint(address _to, uint256 _amount)  public returns (bool);
}

contract Token is Ownable, ERC20 {

  event Mint(address indexed to, uint256 amount);
  event MintToggle(bool status);

  // Constant Functions
  function balanceOf(address _owner) constant returns (uint256) {
    return ControllerInterface(owner).balanceOf(_owner);
  }

  function totalSupply() constant returns (uint256) {
    return ControllerInterface(owner).totalSupply();
  }

  function allowance(address _owner, address _spender) constant returns (uint256) {
    return ControllerInterface(owner).allowance(_owner, _spender);
  }

  function mint(address _to, uint256 _amount) onlyOwner public returns (bool) {
    Mint(_to, _amount);
    Transfer(address(0), _to, _amount);
    return true;
  }

  function mintToggle(bool status) onlyOwner public returns (bool) {
    MintToggle(status);
    return true;
  }

  // public functions
  function approve(address _spender, uint256 _value) public returns (bool) {
    ControllerInterface(owner).approve(msg.sender, _spender, _value);
    Approval(msg.sender, _spender, _value);
    return true;
  }

  function transfer(address _to, uint256 _value) public returns (bool) {
    bytes memory empty;
    return transfer(_to, _value, empty);
  }

  function transfer(address to, uint value, bytes data) public returns (bool) {
    ControllerInterface(owner).transfer(msg.sender, to, value, data);
    Transfer(msg.sender, to, value);
    _checkDestination(msg.sender, to, value, data);
    return true;
  }

  function transferFrom(address _from, address _to, uint _value) public returns (bool) {
    bytes memory empty;
    return transferFrom(_from, _to, _value, empty);
  }


  function transferFrom(address _from, address _to, uint256 _amount, bytes _data) public returns (bool) {
    ControllerInterface(owner).transferFrom(msg.sender, _from, _to, _amount, _data);
    Transfer(_from, _to, _amount);
    _checkDestination(_from, _to, _amount, _data);
    return true;
  }

  // Internal Functions
  function _checkDestination(address _from, address _to, uint256 _value, bytes _data) internal {

    uint256 codeLength;
    assembly {
      codeLength := extcodesize(_to)
    }
    if(codeLength>0) {
      ERC223ReceivingContract untrustedReceiver = ERC223ReceivingContract(_to);
      // untrusted contract call
      untrustedReceiver.tokenFallback(_from, _value, _data);
    }
  }
}

/**
 Simple Token based on OpenZeppelin token contract
 */
contract SGPay is Token {

  string public constant name = "SGPay Token";
  string public constant symbol = "SGP";
  uint8 public constant decimals = 18;

}

contract CrowdsaleInterface {
  function changeRate(uint256 _newValue) public;
}

contract DataManager is Pausable {

  // dataCentre contract addresses
  address public dataCentreAddr;

  function DataManager(address _dataCentreAddr) {
    dataCentreAddr = _dataCentreAddr;
  }

  // Constant Functions
  function balanceOf(address _owner) constant returns (uint256) {
    return DataCentre(dataCentreAddr).getBalanace('STK', _owner);
  }

  function totalSupply() constant returns (uint256) {
    return DataCentre(dataCentreAddr).getValue('STK', 'totalSupply');
  }

  function allowance(address _owner, address _spender) constant returns (uint256) {
    return DataCentre(dataCentreAddr).getConstraint('STK', _owner, _spender);
  }

  function _setTotalSupply(uint256 _newTotalSupply) internal {
    DataCentre(dataCentreAddr).setValue('STK', 'totalSupply', _newTotalSupply);
  }

  function _setBalanceOf(address _owner, uint256 _newValue) internal {
    DataCentre(dataCentreAddr).setBalanace('STK', _owner, _newValue);
  }

  function _setAllowance(address _owner, address _spender, uint256 _newValue) internal {
    require(balanceOf(_owner) >= _newValue);
    DataCentre(dataCentreAddr).setConstraint('STK', _owner, _spender, _newValue);
  }

}

contract SimpleControl is DataManager {
  using SafeMath for uint;

  // token satellite address
  address public satellite;

  modifier onlyToken {
    require(msg.sender == satellite);
    _;
  }


  function SimpleControl(address _satellite, address _dataCentreAddr)
    DataManager(_dataCentreAddr)
  {
    satellite = _satellite;
  }

  // public functions
  function approve(address _owner, address _spender, uint256 _value) public onlyToken whenNotPaused {
    require(_owner != _spender);
    _setAllowance(_owner, _spender, _value);
  }


  function _transfer(address _from, address _to, uint256 _amount, bytes _data) internal {
    require(_to != address(this));
    require(_to != address(0));
    require(_amount > 0);
    require(_from != _to);
    _setBalanceOf(_from, balanceOf(_from).sub(_amount));
    _setBalanceOf(_to, balanceOf(_to).add(_amount));
  }

  function transfer(address _from, address _to, uint256 _amount, bytes _data) public onlyToken whenNotPaused {
    _transfer(_from, _to, _amount, _data);
  }

  function transferFrom(address _sender, address _from, address _to, uint256 _amount, bytes _data) public onlyToken whenNotPaused {
    _setAllowance(_from, _to, allowance(_from, _to).sub(_amount));
    _transfer(_from, _to, _amount, _data);
  }
}

contract CrowdsaleControl is SimpleControl {
  using SafeMath for uint;

  // not necessary to store in data centre
  bool public mintingFinished = false;

  modifier canMint(bool status) {
    require(!mintingFinished == status);
    _;
  }

  function CrowdsaleControl(address _satellite, address _dataCentreAddr)
    SimpleControl(_satellite, _dataCentreAddr)
  {

  }

  function mint(address _to, uint256 _amount) whenNotPaused canMint(true) onlyAdmins public returns (bool) {
    bytes memory empty;
    _setTotalSupply(totalSupply().add(_amount));
    _setBalanceOf(_to, balanceOf(_to).add(_amount));
    Token(satellite).mint(_to, _amount);
    return true;
  }

  function startMinting() onlyAdmins public returns (bool) {
    mintingFinished = false;
    Token(satellite).mintToggle(mintingFinished);
    return true;
  }

  function finishMinting() onlyAdmins public returns (bool) {
    mintingFinished = true;
    Token(satellite).mintToggle(mintingFinished);
    return true;
  }

  function changeRate(uint256 _newValue) onlyAdmins public returns (bool) {
    CrowdsaleInterface(admins[1]).changeRate(_newValue);
  }
}

/**
 Controller to interface between DataCentre and Token satellite
 */
contract Controller is CrowdsaleControl {

  function Controller(address _satellite, address _dataCentreAddr)
    CrowdsaleControl(_satellite, _dataCentreAddr)
  {

  }

  // Owner Functions
  function setContracts(address _satellite, address _dataCentreAddr) public onlyAdmins whenPaused {
    dataCentreAddr = _dataCentreAddr;
    satellite = _satellite;
  }

  function kill(address _newController) public onlyAdmins whenPaused {
    if (dataCentreAddr != address(0)) { Ownable(dataCentreAddr).transferOwnership(msg.sender); }
    if (satellite != address(0)) { Ownable(satellite).transferOwnership(msg.sender); }
    selfdestruct(_newController);
  }

}