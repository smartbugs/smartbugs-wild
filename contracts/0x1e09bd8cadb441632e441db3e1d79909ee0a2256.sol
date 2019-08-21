pragma solidity ^0.4.18;
/**
* Digital Safe Coin
* ERC-20 Token Standar Compliant
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
    bool public lockSupply; //Mint and Burn Lock flag
    bool public lockTransfer; //Transfer Lock flag
    address public allowedAddress; //an address that can override lock condition

    /**
    * @dev Contract constructor
    * define initial administrator
    */
    function admined() internal {
        admin = msg.sender; //Set initial admin to contract creator
        Admined(admin);
    }

   /**
    * @dev Function to set an allowed address
    * @param _to The address to give privileges.
    */
    function setAllowedAddress(address _to) public {
        allowedAddress = _to;
        AllowedSet(_to);
    }

    modifier onlyAdmin() { //A modifier to define admin-only functions
        require(msg.sender == admin);
        _;
    }

    modifier supplyLock() { //A modifier to lock mint and burn transactions
        require(lockSupply == false);
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
        admin = _newAdmin;
        TransferAdminship(admin);
    }

   /**
    * @dev Function to set mint and burn locks
    * @param _set boolean flag (true | false)
    */
    function setSupplyLock(bool _set) onlyAdmin public { //Only the admin can set a lock on supply
        lockSupply = _set;
        SetSupplyLock(_set);
    }

   /**
    * @dev Function to set transfer lock
    * @param _set boolean flag (true | false)
    */
    function setTransferLock(bool _set) onlyAdmin public { //Only the admin can set a lock on transfers
        lockTransfer = _set;
        SetTransferLock(_set);
    }

    //All admin actions have a log for public review
    event AllowedSet(address _to);
    event SetSupplyLock(bool _set);
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
    mapping (address => bool) frozen; //A mapping of frozen accounts

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
        require(frozen[msg.sender]==false);
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
        require(frozen[_from]==false);
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
    * @dev Mint token to an specified address.
    * @param _target The address of the receiver of the tokens.
    * @param _mintedAmount amount to mint.
    */
    function mintToken(address _target, uint256 _mintedAmount) onlyAdmin supplyLock public {
        balances[_target] = SafeMath.add(balances[_target], _mintedAmount);
        totalSupply = SafeMath.add(totalSupply, _mintedAmount);
        Transfer(0, this, _mintedAmount);
        Transfer(this, _target, _mintedAmount);
    }

    /**
    * @dev Burn token of an specified address.
    * @param _target The address of the holder of the tokens.
    * @param _burnedAmount amount to burn.
    */
    function burnToken(address _target, uint256 _burnedAmount) onlyAdmin supplyLock public {
        balances[_target] = SafeMath.sub(balances[_target], _burnedAmount);
        totalSupply = SafeMath.sub(totalSupply, _burnedAmount);
        Burned(_target, _burnedAmount);
    }

    /**
    * @dev Frozen account.
    * @param _target The address to being frozen.
    * @param _flag The status of the frozen
    */
    function setFrozen(address _target,bool _flag) onlyAdmin public {
        frozen[_target]=_flag;
        FrozenStatus(_target,_flag);
    }


    /**
    * @dev Log Events
    */
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
    event Burned(address indexed _target, uint256 _value);
    event FrozenStatus(address _target,bool _flag);
}

/**
* @title Asset
* @dev Initial supply creation
*/
contract Asset is ERC20Token {
    string public name = 'Digital Safe Coin';
    uint8 public decimals = 1;
    string public symbol = 'DSC';
    string public version = '1';

    function Asset() public {

        totalSupply = 500000000 * (10**uint256(decimals));          //500 million initial token creation
        //Initial Token Distribution
        //Tokens to creator wallet - For distribution        
        balances[msg.sender] = 300000000 * (10**uint256(decimals)); //60% for public distribution
        //Tokens to reserve fund wallet
        balances[0x9caC17210aAc675E39b7fd6B9182eF5eBe724EC8] = 100000000 * (10**uint256(decimals));//20% for reserve fund
        //Tokens to team members
        balances[0x3B41bFA39241CDF7afeF807087774e27fd01a1b2] = 50000000 * (10**uint256(decimals));//10% for team members
        //Tokens for advisors and others ---------------------------------------------------------//10% For advisors and others* */
        balances[0xBa52E579C7296A6B45D724CD8163966eEdC5997a] = 49500000 * (10**uint256(decimals));// |---> *9.9% for advisors----|
        balances[0xFAB6368b0F7be60c573a6562d82469B5ED9e7eE6] = 500000 * (10**uint256(decimals));  // |---> *0.1% for contract writer
        
        Transfer(0, this, totalSupply);
        Transfer(this, msg.sender, balances[msg.sender]);
        Transfer(this, 0x9caC17210aAc675E39b7fd6B9182eF5eBe724EC8, balances[0x9caC17210aAc675E39b7fd6B9182eF5eBe724EC8]);
        Transfer(this, 0x3B41bFA39241CDF7afeF807087774e27fd01a1b2, balances[0x3B41bFA39241CDF7afeF807087774e27fd01a1b2]);
        Transfer(this, 0xBa52E579C7296A6B45D724CD8163966eEdC5997a, balances[0xBa52E579C7296A6B45D724CD8163966eEdC5997a]);
        Transfer(this, 0xFAB6368b0F7be60c573a6562d82469B5ED9e7eE6, balances[0xFAB6368b0F7be60c573a6562d82469B5ED9e7eE6]);
    }
    
    /**
    *@dev Function to handle callback calls
    */
    function() public {
        revert();
    }

}