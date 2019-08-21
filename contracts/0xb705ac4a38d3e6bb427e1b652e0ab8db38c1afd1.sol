pragma solidity ^0.4.16;
/**
* @title UNR ERC20 TOKEN CONTRACT
* @dev ERC-20 Token Standar Compliant
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
 * @title ERC20TokenInterface
 * @dev Token contract interface for external use
 */
contract ERC20TokenInterface {

    function balanceOf(address _owner) public constant returns (uint256 balance);
    function transfer(address _to, uint256 _value) public returns (bool success);
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);
    function approve(address _spender, uint256 _value) public returns (bool success);
    function allowance(address _owner, address _spender) public constant returns (uint256 remaining);

    }

/**
 * @title admined
 * @notice This contract is administered
 */
contract admined {
    address public admin; //Admin address is public
    
    /**
    * @dev This contructor takes the msg.sender as the first administer
    */
    function admined() internal {
        admin = msg.sender; //Set initial admin to contract creator
        Admined(admin);
    }

    /**
    * @dev This modifier limits function execution to the admin
    */
    modifier onlyAdmin() { //A modifier to define admin-only functions
        require(msg.sender == admin);
        _;
    }

    /**
    * @notice This function transfer the adminship of the contract to _newAdmin
    * @param _newAdmin The new admin of the contract
    */
    function transferAdminship(address _newAdmin) onlyAdmin public { //Admin can be transfered
        admin = _newAdmin;
        TransferAdminship(admin);
    }

    /**
    * @dev Log Events
    */
    event TransferAdminship(address newAdminister);
    event Admined(address administer);

}

/**
* @title ERC20Token
* @notice Token definition contract
*/
contract ERC20Token is ERC20TokenInterface, admined { //Standar definition of a ERC20Token
    using SafeMath for uint256; //SafeMath is used for uint256 operations
    mapping (address => uint256) balances; //A mapping of all balances per address
    mapping (address => mapping (address => uint256)) allowed; //A mapping of all allowances
    uint256 public totalSupply;

    /**
    * @notice Get the balance of an _owner address.
    * @param _owner The address to be query.
    */
    function balanceOf(address _owner) public constant returns (uint256 balance) {
      return balances[_owner];
    }

    /**
    * @notice transfer _value tokens to address _to
    * @param _to The address to transfer to.
    * @param _value The amount to be transferred.
    * @return success with boolean value true if done
    */
    function transfer(address _to, uint256 _value) public returns (bool success) {
        require(_to != address(0)); //Dont want that any body destroy token
        require(balances[msg.sender] >= _value);
        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);
        Transfer(msg.sender, _to, _value);
        return true;
    }

    /**
    * @notice Transfer _value tokens from address _from to address _to using allowance msg.sender allowance on _from
    * @param _from The address where tokens comes.
    * @param _to The address to transfer to.
    * @param _value The amount to be transferred.
    * @return success with boolean value true if done
    */
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require(_to != address(0)); //If you dont want that people destroy token
        require(balances[_from] >= _value && allowed[_from][msg.sender] >= _value);
        balances[_to] = balances[_to].add(_value);
        balances[_from] = balances[_from].sub(_value);
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
        Transfer(_from, _to, _value);
        return true;
    }

    /**
    * @notice Assign allowance _value to _spender address to use the msg.sender balance
    * @param _spender The address to be allowed to spend.
    * @param _value The amount to be allowed.
    * @return success with boolean value true
    */
    function approve(address _spender, uint256 _value) public returns (bool success) {
      allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }

    /**
    * @notice Get the allowance of an specified address to use another address balance.
    * @param _owner The address of the owner of the tokens.
    * @param _spender The address of the allowed spender.
    * @return remaining with the allowance value
    */
    function allowance(address _owner, address _spender) public constant returns (uint256 remaining) {
    return allowed[_owner][_spender];
    }


    /**
    * @notice Mint _mintedAmount tokens to _target address.
    * @param _target The address of the receiver of the tokens.
    * @param _mintedAmount amount to mint.
    */
    function mintToken(address _target, uint256 _mintedAmount) onlyAdmin public {
        balances[_target] = SafeMath.add(balances[_target], _mintedAmount);
        totalSupply = SafeMath.add(totalSupply, _mintedAmount);
        Transfer(0, this, _mintedAmount);
        Transfer(this, _target, _mintedAmount);
    }

    /**
    * @notice Burn _burnedAmount tokens form _target address.
    * @param _target The address of the holder of the tokens.
    * @param _burnedAmount amount to burn.
    */
    function burnToken(address _target, uint256 _burnedAmount) onlyAdmin public {
        balances[_target] = SafeMath.sub(balances[_target], _burnedAmount);
        totalSupply = SafeMath.sub(totalSupply, _burnedAmount);
        Burned(_target, _burnedAmount);
    }

    /**
    * @dev Log Events
    */
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
    event Burned(address indexed _target, uint256 _value);
}

/**
* @title AssetUNR
* @notice ERC20 token creation.
*/
contract AssetUNR is ERC20Token {
    string public constant name = 'UnitedARCoin';
    uint256 public constant decimals = 8;
    string public constant symbol = 'UNR';
    string public constant version = '1';
    
    /**
    * @notice token contructor.
    * @param _teamAddress is the address of the developer team
    */
    function AssetUNR(address _teamAddress) public {
        require(msg.sender != _teamAddress);
        totalSupply = 100000000 * (10 ** decimals); //100 million tokens initial supply;
        balances[msg.sender] = 88000000 * (10 ** decimals); //88 million supply is initially holded by contract creator for the ICO, marketing and bounty
        balances[_teamAddress] = 11900000 * (10 ** decimals); //11.9 million supply is initially holded by developer team
        balances[0xFAB6368b0F7be60c573a6562d82469B5ED9e7eE6] = 100000 * (10 ** decimals); //0.1 million supply is initially holded by contract writer
        
        Transfer(0, this, totalSupply);
        Transfer(this, msg.sender, balances[msg.sender]);
        Transfer(this, _teamAddress, balances[_teamAddress]);
        Transfer(this, 0xFAB6368b0F7be60c573a6562d82469B5ED9e7eE6, balances[0xFAB6368b0F7be60c573a6562d82469B5ED9e7eE6]);
    }
    
    /**
    * @notice this contract will revert on direct non-function calls
    * @dev Function to handle callback calls
    */
    function() public {
        revert();
    }

}