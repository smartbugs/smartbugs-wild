pragma solidity ^0.4.18;
/**
* @title Pitch TOKEN
* @dev ERC-20 Token Standard Compliant
* @author Fares A. Akel C. f.antonio.akel@gmail.com
*/

/**
* @title SafeMath by OpenZeppelin
* @dev Math operations with safety checks that throw on error
*/
library SafeMath {

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }
}

/**
* Token contract interface for external use
*/
contract ERC20TokenInterface {

    function balanceOf(address _owner) public constant returns (uint256 balance);
    function transfer(address _to, uint256 _value) public returns (bool success);
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);
    function approve(address _spender, uint256 _value) public returns (bool success);
    function allowance(address _owner, address _spender) public constant returns (uint256 remaining);

    }

/**
* @title Admin parameters
* @dev Define administration parameters for this contract
*/
contract admined { //This token contract is administered
    address public admin; //Admin address is public
    bool public lockTransfer; //Transfer Lock flag
    address public allowedAddress; //an address that can override lock condition

    /**
    * @dev Contract constructor
    * define initial administrator
    */
    function admined() internal {
        admin = msg.sender; //Set initial admin to contract creator
        allowedAddress = msg.sender;
        AllowedSet(allowedAddress);
        Admined(admin);
    }

    /**
    * @dev Function to set an allowed address
    * @param _to The address to give privileges.
    */
    function setAllowedAddress(address _to) onlyAdmin public {
        allowedAddress = _to;
        AllowedSet(_to);
    }

    modifier onlyAdmin() { //A modifier to define admin-only functions
        require(msg.sender == admin);
        _;
    }

    modifier transferLock() { //A modifier to lock transactions
        require(lockTransfer == false || allowedAddress == msg.sender);
        _;
    }

    /**
    * @dev Function to set new admin address
    * @param _newAdmin The address to transfer administration to
    */
    function transferAdminship(address _newAdmin) onlyAdmin public { //Admin can be transfered
        require(_newAdmin != address(0x0));
        admin = _newAdmin;
        TransferAdminship(admin);
    }

    /**
    * @dev Function to set transfer lock
    */
    function setTransferLockFree() onlyAdmin public { //Only the admin can set unlock on transfers
        require(lockTransfer == true);
        lockTransfer = false;
        SetTransferLock(lockTransfer);
    }

    //All admin actions have a log for public review
    event AllowedSet(address _to);
    event SetTransferLock(bool _set);
    event TransferAdminship(address newAdminister);
    event Admined(address administer);

}

/**
* @title Token definition
* @dev Define token paramters including ERC20 ones
*/
contract ERC20Token is ERC20TokenInterface, admined { //Standar definition of a ERC20Token
    using SafeMath for uint256;
    uint256 public totalSupply;
    mapping (address => uint256) balances; //A mapping of all balances per address
    mapping (address => mapping (address => uint256)) allowed; //A mapping of all allowances
    
    /**
    * @dev Get the balance of an specified address.
    * @param _owner The address to be query.
    */
    function balanceOf(address _owner) public constant returns (uint256 balance) {
      return balances[_owner];
    }

    /**
    * @dev transfer token to a specified address
    * @param _to The address to transfer to.
    * @param _value The amount to be transferred.
    */
    function transfer(address _to, uint256 _value) transferLock public returns (bool success) {
        require(_to != address(0)); //If you dont want that people destroy token
        require(balances[msg.sender] >= _value);
        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);
        Transfer(msg.sender, _to, _value);
        return true;
    }

    /**
    * @dev transfer token from an address to another specified address using allowance
    * @param _from The address where token comes.
    * @param _to The address to transfer to.
    * @param _value The amount to be transferred.
    */
    function transferFrom(address _from, address _to, uint256 _value) transferLock public returns (bool success) {
        require(_to != address(0)); //If you dont want that people destroy token
        require(balances[_from] >= _value && allowed[_from][msg.sender] >= _value);
        balances[_to] = balances[_to].add(_value);
        balances[_from] = balances[_from].sub(_value);
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
        Transfer(_from, _to, _value);
        return true;
    }

    /**
    * @dev Assign allowance to an specified address to use the owner balance
    * @param _spender The address to be allowed to spend.
    * @param _value The amount to be allowed.
    */
    function approve(address _spender, uint256 _value) public returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }

    /**
    * @dev Get the allowance of an specified address to use another address balance.
    * @param _owner The address of the owner of the tokens.
    * @param _spender The address of the allowed spender.
    */
    function allowance(address _owner, address _spender) public constant returns (uint256 remaining) {
        return allowed[_owner][_spender];
    }

    /**
    * This is an especial Admin-only function to make massive tokens assignments
    */
    function batch(address[] data,uint256[] amount) onlyAdmin public { //It takes an arrays of addresses and amount
        
        require(data.length == amount.length);
        uint256 length = data.length;
        address target;
        uint256 value;

        for (uint i=0; i<length; i++) { //It moves over the array
            target = data[i]; //Take an address
            value = amount[i]; //Amount
            transfer(target,value);
        }
    }

    /**
    * @dev Log Events
    */
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}

/**
* @title Asset
* @dev Initial supply creation
*/
contract Asset is ERC20Token {
    string public name = 'Pitch';
    uint8 public decimals = 18;
    string public symbol = 'PCH';
    string public version = '1';

    function Asset() public {
        totalSupply = 1500000000 * (10**uint256(decimals)); //1.500.000.000 initial token creation
        balances[0xFAB6368b0F7be60c573a6562d82469B5ED9e7eE6] = 1500000 * (10**uint256(decimals)); //0.1% for contract writer
        balances[msg.sender] = 1498500000 * (10**uint256(decimals)); //99.9% of the tokens to creator address
        
        //Initially locked tokens for transfers, only allowedAddres can transfer
        //until global unlock
        lockTransfer = true;
        SetTransferLock(lockTransfer);
        
        Transfer(0, this, totalSupply);
        Transfer(this, 0xFAB6368b0F7be60c573a6562d82469B5ED9e7eE6, balances[0xFAB6368b0F7be60c573a6562d82469B5ED9e7eE6]);
        Transfer(this, msg.sender, balances[msg.sender]);
    }
    
    /**
    *@dev Function to handle callback calls
    */
    function() public {
        revert();
    }
}