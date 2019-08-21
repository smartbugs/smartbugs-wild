pragma solidity 0.5.0;


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


/**
 * @title ControlCentreInterface
 * @dev ControlCentreInterface is an interface for providing commonly used function
 * signatures to the ControlCentre
 */
interface IController {

    function totalSupply() external view returns (uint256);
    function balanceOf(address _owner) external view returns (uint256);
    function allowance(address _owner, address _spender) external view returns (uint256);

    function approve(address owner, address spender, uint256 value) external returns (bool);
    function transfer(address owner, address to, uint value) external returns (bool);
    function transferFrom(address owner, address from, address to, uint256 amount) external returns (uint256);
    function mint(address _to, uint256 _amount)  external returns (bool);

    function increaseAllowance(address owner, address spender, uint256 addedValue) external returns (uint256);
    function decreaseAllowance(address owner, address spender, uint256 subtractedValue) external returns (uint256);

    function burn(address owner, uint value) external returns (bool);
    function burnFrom(address spender, address from, uint value) external returns (uint256);
}


contract ERC20 is Ownable, IERC20 {

    event Mint(address indexed to, uint256 amount);
    event Log(address to);
    event MintToggle(bool status);
    
    // Constant Functions
    function balanceOf(address _owner) public view returns (uint256) {
        return IController(owner()).balanceOf(_owner);
    }

    function totalSupply() public view returns (uint256) {
        return IController(owner()).totalSupply();
    }

    function allowance(address _owner, address _spender) public view returns (uint256) {
        return IController(owner()).allowance(_owner, _spender);
    }

    function mint(address _to, uint256 _amount) public onlyOwner returns (bool) {
        emit Mint(_to, _amount);
        emit Transfer(address(0), _to, _amount);
        return true;
    }

    function mintToggle(bool status) public onlyOwner returns (bool) {
        emit MintToggle(status);
        return true;
    }

    // public functions
    function approve(address _spender, uint256 _value) public returns (bool) {
        IController(owner()).approve(msg.sender, _spender, _value);
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        uint256 allowed = IController(owner()).increaseAllowance(msg.sender, spender, addedValue);
        emit Approval(msg.sender, spender, allowed);
        return true;
    }
    
    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        uint256 allowed = IController(owner()).decreaseAllowance(msg.sender, spender, subtractedValue);
        emit Approval(msg.sender, spender, allowed);
        return true;
    }

    function transfer(address to, uint value) public returns (bool) {
        IController(owner()).transfer(msg.sender, to, value);
        emit Transfer(msg.sender, to, value);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _amount) public returns (bool) {
        uint256 allowed = IController(owner()).transferFrom(msg.sender, _from, _to, _amount);
        emit Approval(_from, msg.sender, allowed);
        emit Transfer(_from, _to, _amount);
        return true;
    }

    function burn(uint256 value) public returns (bool) {
        IController(owner()).burn(msg.sender, value);
        emit Transfer(msg.sender, address(0), value);
        return true;
    }

    function burnFrom(address from, uint256 value) public returns (bool) {
        uint256 allowed = IController(owner()).burnFrom(msg.sender, from, value);
        emit Approval(from, msg.sender, allowed);
        emit Transfer(from, address(0), value);
        return true;
    }
}


contract VodiX is ERC20 {

    string internal _name = "Vodi X";
    string internal _symbol = "VDX";
    uint8 internal _decimals = 18;

    /**
     * @return the name of the token.
     */
    function name() public view returns (string memory) {
        return _name;
    }

    /**
     * @return the symbol of the token.
     */
    function symbol() public view returns (string memory) {
        return _symbol;
    }

    /**
     * @return the number of decimals of the token.
     */
    function decimals() public view returns (uint8) {
        return _decimals;
    }
}