pragma solidity ^0.4.18;


 /*
 * Contract that is working with ERC223 tokens
 */

contract ERC223ReceivingContract {
    function tokenFallback(address _from, uint _value, bytes _data) public;
}


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
    * @dev Throws if called by any account other than the owner.
    */
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    /**
    * @dev The Ownable constructor sets the original `owner` of the contract to the sender
    * account.
    */
    function Ownable() public {
        owner = msg.sender;
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

/**
 * @title ControlCentreInterface
 * @dev ControlCentreInterface is an interface for providing commonly used function
 * signatures to the ControlCentre
 */
contract ControllerInterface {

    function totalSupply() public constant returns (uint256);
    function balanceOf(address _owner) public constant returns (uint256);
    function allowance(address _owner, address _spender) public constant returns (uint256);
    function approve(address owner, address spender, uint256 value) public returns (bool);
    function transfer(address owner, address to, uint value, bytes data) public returns (bool);
    function transferFrom(address owner, address from, address to, uint256 amount, bytes data) public returns (bool);
    function mint(address _to, uint256 _amount) public returns (bool);
}


/*
 * ERC20Basic
 * Simpler version of ERC20 interface
 * see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20Basic {
    function totalSupply() public constant returns (uint256);
    function balanceOf(address _owner) public constant returns (uint256);
    function transfer(address _to, uint256 _value) public returns (bool);
    event Transfer(address indexed from, address indexed to, uint value);
}


contract ERC223Basic is ERC20Basic {
    function transfer(address to, uint value, bytes data) public returns (bool);
}

contract ERC20 is ERC223Basic {
    // active supply of tokens
    function allowance(address _owner, address _spender) public constant returns (uint256);
    function transferFrom(address _from, address _to, uint _value) public returns (bool);
    function approve(address _spender, uint256 _value) public returns (bool);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract Token is Ownable, ERC20 {

    event Mint(address indexed to, uint256 amount);
    event MintToggle(bool status);

    // Constant Functions
    function balanceOf(address _owner) public constant returns (uint256) {
        return ControllerInterface(owner).balanceOf(_owner);
    }

    function totalSupply() public constant returns (uint256) {
        return ControllerInterface(owner).totalSupply();
    }

    function allowance(address _owner, address _spender) public constant returns (uint256) {
        return ControllerInterface(owner).allowance(_owner, _spender);
    }

    function mint(address _to, uint256 _amount) onlyOwner public returns (bool) {
        bytes memory empty;
        _checkDestination(address(this), _to, _amount, empty);
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
    function setValue(bytes32 _container, bytes32 _key, uint256 _value) public onlyOwner {
        containers[_container].values[_key] = _value;
    }

    function setAddress(bytes32 _container, bytes32 _key, address _value) public onlyOwner {
        containers[_container].addresses[_key] = _value;
    }

    function setBool(bytes32 _container, bytes32 _key, bool _value) public onlyOwner {
        containers[_container].switches[_key] = _value;
    }

    function setBalanace(bytes32 _container, address _key, uint256 _value) public onlyOwner {
        containers[_container].balances[_key] = _value;
    }


    function setConstraint(bytes32 _container, address _source, address _key, uint256 _value) public onlyOwner {
        containers[_container].constraints[_source][_key] = _value;
    }

    // Constant Functions
    function getValue(bytes32 _container, bytes32 _key) public constant returns(uint256) {
        return containers[_container].values[_key];
    }

    function getAddress(bytes32 _container, bytes32 _key) public constant returns(address) {
        return containers[_container].addresses[_key];
    }

    function getBool(bytes32 _container, bytes32 _key) public constant returns(bool) {
        return containers[_container].switches[_key];
    }

    function getBalanace(bytes32 _container, address _key) public constant returns(uint256) {
        return containers[_container].balances[_key];
    }

    function getConstraint(bytes32 _container, address _source, address _key) public constant returns(uint256) {
        return containers[_container].constraints[_source][_key];
    }
}

contract Governable {

    // list of admins, council at first spot
    address[] public admins;

    modifier onlyAdmins() {
        var(adminStatus, ) = isAdmin(msg.sender);
        require(adminStatus == true);
        _;
    }

    function Governable() public {
        admins.length = 1;
        admins[0] = msg.sender;
    }

    function addAdmin(address _admin) public onlyAdmins {
        var(adminStatus, ) = isAdmin(_admin);
        require(!adminStatus);
        require(admins.length < 10);
        admins[admins.length++] = _admin;
    }

    function removeAdmin(address _admin) public onlyAdmins {
        var(adminStatus, pos) = isAdmin(_admin);
        require(adminStatus);
        require(pos < admins.length);
        // if not last element, switch with last
        if (pos < admins.length - 1) {
            admins[pos] = admins[admins.length - 1];
        }
        // then cut off the tail
        admins.length--;
    }

    function isAdmin(address _addr) internal returns (bool isAdmin, uint256 pos) {
        isAdmin = false;
        for (uint256 i = 0; i < admins.length; i++) {
            if (_addr == admins[i]) {
            isAdmin = true;
            pos = i;
            }
        }
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
    modifier whenNotPaused(address _to) {
        var(adminStatus, ) = isAdmin(_to);
        require(!paused || adminStatus);
        _;
    }

    /**
    * @dev Modifier to make a function callable only when the contract is paused.
    */
    modifier whenPaused(address _to) {
        var(adminStatus, ) = isAdmin(_to);
        require(paused || adminStatus);
        _;
    }

    /**
    * @dev called by the owner to pause, triggers stopped state
    */
    function pause() onlyAdmins whenNotPaused(msg.sender) public {
        paused = true;
        Pause();
    }

    /**
    * @dev called by the owner to unpause, returns to normal state
    */
    function unpause() onlyAdmins whenPaused(msg.sender) public {
        paused = false;
        Unpause();
    }
}

contract DataManager is Pausable {

    // satelite contract addresses
    address public dataCentreAddr;

    function DataManager(address _dataCentreAddr) {
        dataCentreAddr = _dataCentreAddr;
    }

    // Constant Functions
    function balanceOf(address _owner) public constant returns (uint256) {
        return DataCentre(dataCentreAddr).getBalanace("FORCE", _owner);
    }

    function totalSupply() public constant returns (uint256) {
        return DataCentre(dataCentreAddr).getValue("FORCE", "totalSupply");
    }

    function allowance(address _owner, address _spender) public constant returns (uint256) {
        return DataCentre(dataCentreAddr).getConstraint("FORCE", _owner, _spender);
    }

    function _setTotalSupply(uint256 _newTotalSupply) internal {
        DataCentre(dataCentreAddr).setValue("FORCE", "totalSupply", _newTotalSupply);
    }

    function _setBalanceOf(address _owner, uint256 _newValue) internal {
        DataCentre(dataCentreAddr).setBalanace("FORCE", _owner, _newValue);
    }

    function _setAllowance(address _owner, address _spender, uint256 _newValue) internal {
        require(balanceOf(_owner) >= _newValue);
        DataCentre(dataCentreAddr).setConstraint("FORCE", _owner, _spender, _newValue);
    }

}

contract SimpleControl is DataManager {
    using SafeMath for uint;

    // not necessary to store in data centre  address public satellite;

    address public satellite;

    modifier onlyToken {
        require(msg.sender == satellite);
        _;
    }

    function SimpleControl(address _satellite, address _dataCentreAddr) public
        DataManager(_dataCentreAddr)
    {
        satellite = _satellite;
    }

    // public functions
    function approve(address _owner, address _spender, uint256 _value) public onlyToken whenNotPaused(_owner) {
        require(_owner != _spender);
        _setAllowance(_owner, _spender, _value);
    }

    function transfer(address _from, address _to, uint256 _amount, bytes _data) public onlyToken whenNotPaused(_from) {
        _transfer(_from, _to, _amount, _data);
    }

    function transferFrom(address _sender, address _from, address _to, uint256 _amount, bytes _data) public onlyToken whenNotPaused(_sender) {
        _setAllowance(_from, _to, allowance(_from, _to).sub(_amount));
        _transfer(_from, _to, _amount, _data);
    }

    function _transfer(address _from, address _to, uint256 _amount, bytes _data) internal {
        require(_to != address(this));
        require(_to != address(0));
        require(_amount > 0);
        require(_from != _to);
        _setBalanceOf(_from, balanceOf(_from).sub(_amount));
        _setBalanceOf(_to, balanceOf(_to).add(_amount));
    }
}


contract CrowdsaleControl is SimpleControl {
    using SafeMath for uint;

    // not necessary to store in data centre
    bool public mintingFinished;

    modifier canMint(bool status, address _to) {
        var(adminStatus, ) = isAdmin(_to);
        require(!mintingFinished == status || adminStatus);
        _;
    }

    function CrowdsaleControl(address _satellite, address _dataCentreAddr) public
        SimpleControl(_satellite, _dataCentreAddr)
    {

    }

    function mint(address _to, uint256 _amount) whenNotPaused(_to) canMint(true, msg.sender) onlyAdmins public returns (bool) {
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
}


/**
 Simple Token based on OpenZeppelin token contract
 */
contract Controller is CrowdsaleControl {

    /**
    * @dev Constructor that gives msg.sender all of existing tokens.
    */
    function Controller(address _satellite, address _dataCentreAddr) public
        CrowdsaleControl(_satellite, _dataCentreAddr)
    {

    }

    // Owner Functions
    function setContracts(address _satellite, address _dataCentreAddr) public onlyAdmins whenPaused(msg.sender) {
        dataCentreAddr = _dataCentreAddr;
        satellite = _satellite;
    }

    function kill(address _newController) public onlyAdmins whenPaused(msg.sender) {
        if (dataCentreAddr != address(0)) { 
            Ownable(dataCentreAddr).transferOwnership(msg.sender);
        }
        if (satellite != address(0)) {
            Ownable(satellite).transferOwnership(msg.sender);
        }
        selfdestruct(_newController);
    }
}