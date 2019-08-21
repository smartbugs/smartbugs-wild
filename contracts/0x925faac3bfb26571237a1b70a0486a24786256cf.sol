pragma solidity ^0.4.23;

/**
 * Math operations with safety checks
 */
library SafeMath {
  function mul(uint a, uint b) internal pure returns (uint) {
    uint c = a * b;
    require(a == 0 || c / a == b);
    return c;
  }

  function div(uint a, uint b) internal pure returns (uint) {
    uint c = a / b;
    return c;
  }

  function sub(uint a, uint b) internal pure returns (uint) {
    require(b <= a);
    return a - b;
  }

  function add(uint a, uint b) internal pure returns (uint) {
    uint c = a + b;
    require(c >= a);
    return c;
  }

  function max64(uint64 a, uint64 b) internal pure returns (uint64) {
    return a >= b ? a : b;

  }

  function min64(uint64 a, uint64 b) internal pure returns (uint64) {
    return a < b ? a : b;
  }

  function max256(uint256 a, uint256 b) internal pure returns (uint256) {
    return a >= b ? a : b;
  }

  function min256(uint256 a, uint256 b) internal pure returns (uint256) {
    return a < b ? a : b;
  }

}

contract RockzToken {

    using SafeMath for uint;

    // ERC20 State
    mapping(address => uint256) public balances;
    mapping(address => mapping(address => uint256)) public allowances;
    uint256 public totalSupply;

    // Human State
    string public name;
    uint8 public decimals;
    string public symbol;

    // Minter State
    address public centralMinter;

    // Owner State
    address public owner;

    // Modifiers
    modifier onlyMinter {
        require(msg.sender == centralMinter);
        _;
    }

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    // ERC20 Events
    event Transfer(address indexed _from, address indexed _to, uint256 _value, bytes _data);
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);

    // Rockz Events
    event Mint(address indexed _minter, address indexed _to, uint256 _value, bytes _data);
    event Mint(address indexed _to, uint256 _value);
    event Burn(address indexed _who, uint256 _value, bytes _data);
    event Burn(address indexed _who, uint256 _value);

    // Constructor
    constructor() public {
        totalSupply = 0;
        name = "Rockz Coin";
        decimals = 2;
        symbol = "RKZ";
        owner = msg.sender;
    }

    // ERC20 Methods


    /**
     * @dev Get balance of specified address.
     *
     * @param _address   Tokens owner address.
     */
    function balanceOf(address _address) public view returns (uint256 balance) {
        return balances[_address];
    }

    /**
     * @dev Get amount of tokens allowed to be transferred by 3-rd party.
     *
     * @param _owner    Tokens owner address.
     * @param _spender  Spender address.
     */
    function allowance(address _owner, address _spender) public view returns (uint256 remaining) {
        return allowances[_owner][_spender];
    }

    /**
     * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.
     * Beware that changing an allowance with this method brings the risk that someone may use both the old
     * and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this
     * race condition is to first reduce the spender's allowance to 0 and set the desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     * @param _spender The address which will spend the funds.
     * @param _value The amount of tokens to be spent.
     */
    function approve(address _spender, uint256 _value) public returns (bool success) {
        require(_spender != address(0));
        allowances[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    /**
     * @dev Transfer the specified amount of tokens from one address to another.
     *      This function allows 3-rd party to transfer tokens if there is an allowance
     *      approved by tokens owner.
     *
     * @param _owner    Tokens owner address.
     * @param _to       Tokens receiver address.
     * @param _value    Amount of tokens to transfer.
     */
    function transferFrom(address _owner, address _to, uint256 _value) public returns (bool success) {
        require(_to != address(0));
        require(balances[_owner] >= _value);
        require(allowances[_owner][msg.sender] >= _value);
        balances[_owner] = balances[_owner].sub(_value);
        balances[_to] = balances[_to].add(_value);
        allowances[_owner][msg.sender] = allowances[_owner][msg.sender].sub(_value);
        bytes memory empty;
        emit Transfer(_owner, _to, _value, empty);
        emit Transfer(_owner, _to, _value);
        return true;
    }
    // ERC20 Methods END


    // ERC223 Methods

    /**
     * @dev Transfer the specified amount of tokens to the specified address.
     *      This function works the same with the previous one
     *      but doesn't contain `_data` param.
     *      Added due to backwards compatibility reasons.
     *
     * @param _to    Receiver address.
     * @param _value Amount of tokens that will be transferred.
     */
    function transfer(address _to, uint _value) public {
        bytes memory empty;

        require(_to != address(0));

        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);
        emit Transfer(msg.sender, _to, _value, empty);
        emit Transfer(msg.sender, _to, _value);
    }

    /**
     * @dev Transfer the specified amount of tokens to the specified address.
     *      Invokes the `tokenFallback` function if the recipient is a contract.
     *      The token transfer fails if the recipient is a contract
     *      but does not implement the `tokenFallback` function
     *      or the fallback function to receive funds.
     *
     * @param _to    Receiver address.
     * @param _value Amount of tokens that will be transferred.
     * @param _data  Transaction metadata.
     */
    function transfer(address _to, uint _value, bytes memory _data) public {
        // Standard function transfer similar to ERC20 transfer with no _data .
        // Added due to backwards compatibility reasons .
        require(_to != address(0));

        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);
        emit Transfer(msg.sender, _to, _value, _data);
        emit Transfer(msg.sender, _to, _value);
    }

    // ERC223 Methods END


    // Minter Functions
    /**
     * @dev Mint the specified amount of tokens to the central minter address.
     *
     * @param _amountToMint    Amount of tokens to mint.
     * @param _data Data to be passed to Transfer and Mint events.
     */
    function mint(uint256 _amountToMint, bytes memory _data) public onlyMinter {
        balances[centralMinter] = balances[centralMinter].add(_amountToMint);
        totalSupply = totalSupply.add(_amountToMint);

        emit Mint(centralMinter, centralMinter, _amountToMint, _data);
        emit Mint(centralMinter, _amountToMint);
        emit Transfer(owner, centralMinter, _amountToMint, _data);
        emit Transfer(owner, centralMinter, _amountToMint);
    }

    /**
     * @dev Burn the specified amount of tokens from the central minter address.
     *
     * @param _amountToBurn    Amount of tokens to burn.
     * @param _data Data to be passed to Burn event.
     */
    function burn(uint256 _amountToBurn, bytes memory _data) public onlyMinter returns (bool success) {
        require(balances[centralMinter] >= _amountToBurn);
        balances[centralMinter] = balances[msg.sender].sub(_amountToBurn);
        totalSupply = totalSupply.sub(_amountToBurn);
        emit Burn(centralMinter, _amountToBurn, _data);
        emit Burn(centralMinter, _amountToBurn);
        return true;
    }

    // Minter Functions END

    // Owner functions
    /**
     * @dev Transfer central minter address to specified address.
     *
     * @param _newMinter    New minter address
     */
    function transferMinter(address _newMinter) public onlyOwner {
        require(_newMinter != address(0));
        centralMinter = _newMinter;
    }
    // Owner functions END

}