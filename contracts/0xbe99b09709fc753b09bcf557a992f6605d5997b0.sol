pragma solidity ^0.4.18;
/**
* TOKEN Contract
* ERC-20 Token Standard Compliant
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

    function balanceOf(address _owner) public constant returns (uint256 value);
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

    modifier transferLock() { //A modifier to lock transactions
        require(lockTransfer == false || allowedAddress == msg.sender);
        _;
    }

   /**
    * @dev Function to set new admin address
    * @param _newAdmin The address to transfer administration to
    */
    function transferAdminship(address _newAdmin) onlyAdmin public { //Admin can be transfered
        require(_newAdmin != 0);
        admin = _newAdmin;
        TransferAdminship(admin);
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
    event SetTransferLock(bool _set);
    event TransferAdminship(address newAdminister);
    event Admined(address administer);

}

/**
* @title Token definition
* @dev Define token paramters including ERC20 ones
*/
contract ERC20Token is ERC20TokenInterface, admined { //Standard definition of a ERC20Token
    using SafeMath for uint256;
    uint256 public totalSupply;
    mapping (address => uint256) balances; //A mapping of all balances per address
    mapping (address => mapping (address => uint256)) allowed; //A mapping of all allowances
    mapping (address => bool) frozen; //A mapping of frozen accounts

    /**
    * @dev Get the balance of an specified address.
    * @param _owner The address to be query.
    */
    function balanceOf(address _owner) public constant returns (uint256 value) {
      return balances[_owner];
    }

    /**
    * @dev transfer token to a specified address
    * @param _to The address to transfer to.
    * @param _value The amount to be transferred.
    */
    function transfer(address _to, uint256 _value) transferLock public returns (bool success) {
        require(_to != address(0)); //If you dont want that people destroy token
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
        require(frozen[_from]==false);
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
        balances[_from] = balances[_from].sub(_value);
        balances[_to] = balances[_to].add(_value);
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
    * @dev Frozen account.
    * @param _target The address to being frozen.
    * @param _flag The status of the frozen
    */
    function setFrozen(address _target,bool _flag) onlyAdmin public {
        frozen[_target]=_flag;
        FrozenStatus(_target,_flag);
    }

    /**
    * @dev Burn token of an specified address.
    * @param _burnedAmount amount to burn.
    */
    function burnToken(uint256 _burnedAmount) onlyAdmin public {
        balances[msg.sender] = SafeMath.sub(balances[msg.sender], _burnedAmount);
        totalSupply = SafeMath.sub(totalSupply, _burnedAmount);
        Burned(msg.sender, _burnedAmount);
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
    string public name = 'SMARTRealty';
    uint8 public decimals = 8;
    string public symbol = 'RLTY';
    string public version = '1'; 

    address DevExecutiveAdvisorTeams= 0xF9568bd772C9B517193275b3C2E0CDAd38E586bB;
    address SMARTRealtyEconomy= 0x07ADB1D9399Bd1Fa4fD613D3179DFE883755Bb13;
    address Marketing= 0xd35909DbeEb5255D65b1ea14602C7f00ce3872f6;
    address SMARTMortgages= 0x9D2Fe4D5f1dc4FcA1f0Ea5f461C9fAA5D09b9CCE;
    address Administer= 0x8Bb41848B6dD3D98b8849049b780dC3549568c89;
    address Contractors= 0xC78DF195DE5717FB15FB3448D5C6893E8e7fB254;
    address Legal= 0x4690678926BCf9B30985c06806d4568C0C498123;
    address BountiesandGiveaways= 0x08AF803F0F90ccDBFCe046Bc113822cFf415e148;
    address CharitableUse= 0x8661dFb67dE4E5569da9859f5CB4Aa676cd5F480;


    function Asset() public {

        totalSupply = 500000000 * (10**uint256(decimals)); //initial token creation
        Transfer(0, this, totalSupply);

        //20% Presale+20% ICO
        balances[msg.sender] = 200000000 * (10**uint256(decimals));
        Transfer(this, msg.sender, balances[msg.sender]);        

        //10%
        balances[DevExecutiveAdvisorTeams] = 50000000 * (10**uint256(decimals));
        Transfer(this, DevExecutiveAdvisorTeams, balances[DevExecutiveAdvisorTeams]);

        //10%
        balances[SMARTRealtyEconomy] = 50000000 * (10**uint256(decimals));
        Transfer(this, SMARTRealtyEconomy, balances[SMARTRealtyEconomy]);

        //10%
        balances[Marketing] = 50000000 * (10**uint256(decimals));
        Transfer(this, Marketing, balances[Marketing]);

        //10%
        balances[SMARTMortgages] = 50000000 * (10**uint256(decimals));
        Transfer(this, SMARTMortgages, balances[SMARTMortgages]);
        
        //5%
        balances[Administer] = 25000000 * (10**uint256(decimals));
        Transfer(this, Administer, balances[Administer]);

        //5%
        balances[Contractors] = 25000000 * (10**uint256(decimals));
        Transfer(this, Contractors, balances[Contractors]);

        //5%
        balances[Legal] = 25000000 * (10**uint256(decimals));
        Transfer(this, Legal, balances[Legal]);

        //4%
        balances[BountiesandGiveaways] =  20000000 * (10**uint256(decimals));
        Transfer(this, BountiesandGiveaways, balances[BountiesandGiveaways]);

        //1%
        balances[CharitableUse] = 5000000  * (10**uint256(decimals));
        Transfer(this, CharitableUse, balances[CharitableUse]);

    }
    
    /**
    *@dev Function to handle callback calls
    */
    function() public {
        revert();
    }

}