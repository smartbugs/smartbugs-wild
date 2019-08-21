pragma solidity ^0.4.24;

/**
* @title SafeMath
* @dev Math operations with safety checks that throw on error
*/
library SafeMath {

    /**
    * @dev Multiplies two numbers, throws on overflow.
    */
    function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
        if (a == 0 || b == 0) {
            return 0;
        }
        c = a * b;
        require(c / a == b, "Mul overflow!");
        return c;
    }

    /**
    * @dev Integer division of two numbers, truncating the quotient.
    */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // Solidity automatically throws when dividing by 0
        uint256 c = a / b;
        return c;
    }

    /**
    * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
    */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "Sub overflow!");
        return a - b;
    }

    /**
    * @dev Adds two numbers, throws on overflow.
    */
    function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
        c = a + b;
        require(c >= a, "Add overflow!");
        return c;
    }
}

// ----------------------------------------------------------------------------
// ERC Token Standard #20 Interface
// https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20.md
// ----------------------------------------------------------------------------
contract ERC20Interface {

    string public name;
    string public symbol;
    uint8 public decimals;
    uint256 public totalSupply;
    function balanceOf(address _owner) external view returns (uint256);
    function transfer(address _to, uint256 _value) external returns(bool);

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
}

// ----------------------------------------------------------------------------
// Owned contract
// ----------------------------------------------------------------------------
contract Owned {

    address public owner;
    address public newOwner;

    event OwnershipTransferred(address indexed _from, address indexed _to);

    modifier onlyOwner {
        require(msg.sender == owner, "Only Owner can do that!");
        _;
    }

    function transferOwnership(address _newOwner)
    external onlyOwner {
        newOwner = _newOwner;
    }

    function acceptOwnership()
    external {
        require(msg.sender == newOwner, "You are not new Owner!");
        owner = newOwner;
        newOwner = address(0);
        emit OwnershipTransferred(owner, newOwner);
    }
}

contract Permissioned {

    function approve(address _spender, uint256 _value) public returns(bool);
    function transferFrom(address _from, address _to, uint256 _value) external returns(bool);
    function allowance(address _owner, address _spender) external view returns (uint256);

    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}

contract Burnable {

    function burn(uint256 _value) external returns(bool);
    function burnFrom(address _from, uint256 _value) external returns(bool);

    // This notifies clients about the amount burnt
    event Burn(address indexed _from, uint256 _value);
}

interface tokenRecipient { function receiveApproval(address _from, uint256 _value, address _token, bytes _extraData) external; }

contract Aligato is ERC20Interface, Owned, Permissioned, Burnable {

    using SafeMath for uint256; //Be aware of overflows

    // This creates an array with all balances
    mapping(address => uint256) internal _balanceOf;

    // This creates an array with all allowance
    mapping(address => mapping(address => uint256)) internal _allowance;

    bool public isLocked = true; //only contract Owner can transfer tokens

    uint256 icoSupply = 0;

    //set ICO balance and emit
    function setICO(address user, uint256 amt) internal{
        uint256 amt2 = amt * (10 ** uint256(decimals));
        _balanceOf[user] = amt2;
        emit Transfer(0x0, user, amt2);
        icoSupply += amt2;
    }

    // As ICO been done on platform, we need set proper amouts for ppl that participate
   

    /**
    * Constructor function
    *
    * Initializes contract with initial supply tokens to the creator of the contract
    */
    constructor(string _symbol, string _name, uint256 _supply, uint8 _decimals)
    public {
        require(_supply != 0, "Supply required!"); //avoid accidental deplyment with zero balance
        owner = msg.sender;
        symbol = _symbol;
        name = _name;
        decimals = _decimals;
        
        totalSupply = _supply.mul(10 ** uint256(decimals)); //supply in constuctor is w/o decimal zeros
        _balanceOf[msg.sender] = totalSupply - icoSupply;
        emit Transfer(address(0), msg.sender, totalSupply - icoSupply);
    }

    // unlock transfers for everyone
    function unlock() external onlyOwner returns (bool success)
    {
        require (isLocked == true, "It is unlocked already!"); //you can unlock only once
        isLocked = false;
        return true;
    }

    /**
    * Get the token balance for account
    *
    * Get token balance of `_owner` account
    *
    * @param _owner The address of the owner
    */
    function balanceOf(address _owner)
    external view
    returns(uint256 balance) {
        return _balanceOf[_owner];
    }

    /**
    * Internal transfer, only can be called by this contract
    */
    function _transfer(address _from, address _to, uint256 _value)
    internal {
        // check that contract is unlocked
        require (isLocked == false || _from == owner, "Contract is locked!");
        // Prevent transfer to 0x0 address. Use burn() instead
        require(_to != address(0), "Can`t send to 0x0, use burn()");
        // Check if the sender has enough
        require(_balanceOf[_from] >= _value, "Not enough balance!");
        // Subtract from the sender
        _balanceOf[_from] = _balanceOf[_from].sub(_value);
        // Add the same to the recipient
        _balanceOf[_to] = _balanceOf[_to].add(_value);
        emit Transfer(_from, _to, _value);
    }

    /**
    * Transfer tokens
    *
    * Send `_value` tokens to `_to` from your account
    *
    * @param _to The address of the recipient
    * @param _value the amount to send
    */
    function transfer(address _to, uint256 _value)
    external
    returns(bool success) {
        _transfer(msg.sender, _to, _value);
        return true;
    }

    /**
    * Transfer tokens from other address
    *
    * Send `_value` tokens to `_to` on behalf of `_from`
    *
    * @param _from The address of the sender
    * @param _to The address of the recipient
    * @param _value the amount to send
    */
    function transferFrom(address _from, address _to, uint256 _value)
    external
    returns(bool success) {
        // Check allowance
        require(_value <= _allowance[_from][msg.sender], "Not enough allowance!");
        // Check balance
        require(_value <= _balanceOf[_from], "Not enough balance!");
        _allowance[_from][msg.sender] = _allowance[_from][msg.sender].sub(_value);
        _transfer(_from, _to, _value);
        emit Approval(_from, _to, _allowance[_from][_to]);
        return true;
    }

    /**
    * Set allowance for other address
    *
    * Allows `_spender` to spend no more than `_value` tokens on your behalf
    *
    * @param _spender The address authorized to spend
    * @param _value the max amount they can spend
    */
    function approve(address _spender, uint256 _value)
    public
    returns(bool success) {
        _allowance[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    /**
    * Set allowance for other address and notify
    *
    * Allows `_spender` to spend no more than `_value` tokens on your behalf, and then ping the contract about it
    *
    * @param _spender The address authorized to spend
    * @param _value the max amount they can spend
    * @param _extraData some extra information to send to the approved contract
    */
    function approveAndCall(address _spender, uint256 _value, bytes _extraData)
    external
    returns(bool success) {
        tokenRecipient spender = tokenRecipient(_spender);
        if (approve(_spender, _value)) {
            spender.receiveApproval(msg.sender, _value, this, _extraData);
            return true;
        }
    }

    /**
    * @dev Function to check the amount of tokens that an owner allowed to a spender.
    * @param _owner address The address which owns the funds.
    * @param _spender address The address which will spend the funds.
    * @return A uint256 specifying the amount of tokens still available for the spender.
    */
    function allowance(address _owner, address _spender)
    external view
    returns(uint256 value) {
        return _allowance[_owner][_spender];
    }

    /**
    * Destroy tokens
    *
    * Remove `_value` tokens from the system irreversibly
    *
    * @param _value the amount of money to burn
    */
    function burn(uint256 _value)
    external
    returns(bool success) {
        _burn(msg.sender, _value);
        return true;
    }

    /**
    * Destroy tokens from other account
    *
    * Remove `_value` tokens from the system irreversibly on behalf of `_from`.
    *
    * @param _from the address of the sender
    * @param _value the amount of money to burn
    */
    function burnFrom(address _from, uint256 _value)
    external
    returns(bool success) {
         // Check allowance
        require(_value <= _allowance[_from][msg.sender], "Not enough allowance!");
        // Is tehere enough coins on account
        require(_value <= _balanceOf[_from], "Insuffient balance!");
        // Subtract from the sender's allowance
        _allowance[_from][msg.sender] = _allowance[_from][msg.sender].sub(_value);
        _burn(_from, _value);
        emit Approval(_from, msg.sender, _allowance[_from][msg.sender]);
        return true;
    }

    function _burn(address _from, uint256 _value)
    internal {
        // Check if the targeted balance is enough
        require(_balanceOf[_from] >= _value, "Insuffient balance!");
        // Subtract from the sender
        _balanceOf[_from] = _balanceOf[_from].sub(_value);
        // Updates totalSupply
        totalSupply = totalSupply.sub(_value);
        emit Burn(msg.sender, _value);
        emit Transfer(_from, address(0), _value);
    }

    // ------------------------------------------------------------------------
    // Don't accept accidental ETH
    // ------------------------------------------------------------------------
    function () external payable {
        revert("This contract is not accepting ETH.");
    }

    //Owner can take ETH from contract
    function withdraw(uint256 _amount)
    external onlyOwner
    returns (bool){
        require(_amount <= address(this).balance, "Not enough balance!");
        owner.transfer(_amount);
        return true;
    }

    // ------------------------------------------------------------------------
    // Owner can transfer out any accidentally sent ERC20 tokens
    // ------------------------------------------------------------------------
    function transferAnyERC20Token(address tokenAddress, uint256 _value)
    external onlyOwner
    returns(bool success) {
        return ERC20Interface(tokenAddress).transfer(owner, _value);
    }
}