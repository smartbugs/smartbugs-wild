pragma solidity ^0.4.18;
/**
* SMARTRealty
* ERC-20 Token Standard Compliant + Crowdsale
* @author Oyewole A. Samuel oyewoleabayomi@gmail.com
*/


/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {

  /**
  * @dev Multiplies two numbers, throws on overflow.
  */
  function safeMul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    assert(c / a == b);
    return c;
  }

  /**
  * @dev Integer division of two numbers, truncating the quotient.
  */
  function safeDiv(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  /**
  * @dev Substracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
  */
  function safeSub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  /**
  * @dev Adds two numbers, throws on overflow.
  */
  function safeAdd(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}

/**
* @title Admin parameters
* @dev Define administration parameters for this contract
*/
contract admined {
    //This token contract is administered
    address public admin; //Admin address is public
    bool public lockSupply; //Mint and Burn Lock flag
    bool public lockTransfer; //Transfer Lock flag
    address public allowedAddress; //an address that can override lock condition
    bool public lockTokenSupply;

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

    function setLockTokenSupply(bool _set) onlyAdmin public {
        lockTokenSupply = _set;
        SetLockTokenSupply(_set);
    }

    function getLockTokenSupply() returns (bool) {
        return lockTokenSupply;
    }

    //All admin actions have a log for public review
    event AllowedSet(address _to);
    event SetSupplyLock(bool _set);
    event SetTransferLock(bool _set);
    event TransferAdminship(address newAdminister);
    event Admined(address administer);
    event SetLockTokenSupply(bool _set);

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
* @title Token definition
* @dev Define token paramters including ERC20 ones
*/
contract StandardToken is ERC20TokenInterface, admined { //Standard definition of a ERC20Token
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
        balances[msg.sender] = balances[msg.sender].safeSub(_value);
        balances[_to] = balances[_to].safeAdd(_value);
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
        balances[_to] = balances[_to].safeAdd(_value);
        balances[_from] = balances[_from].safeSub(_value);
        allowed[_from][msg.sender] = allowed[_from][msg.sender].safeSub(_value);
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
        balances[_target] = SafeMath.safeAdd(balances[_target], _mintedAmount);
        totalSupply = SafeMath.safeAdd(totalSupply, _mintedAmount);
        Transfer(0, this, _mintedAmount);
        Transfer(this, _target, _mintedAmount);
    }

    /**
    * @dev Burn token of an specified address.
    * @param _target The address of the holder of the tokens.
    * @param _burnedAmount amount to burn.
    */
    function burnToken(address _target, uint256 _burnedAmount) onlyAdmin supplyLock public {
        balances[_target] = SafeMath.safeSub(balances[_target], _burnedAmount);
        totalSupply = SafeMath.safeSub(totalSupply, _burnedAmount);
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

contract SMARTRealty is StandardToken{
    //using SafeMath for uint256;
    
    string public name = "SMARTRealty";
    string public symbol = "RLTY";
    uint8 public decimals = 8;
    string public version = "1.0.0";

    uint public constant RATE = 1250; //1 RLTY = 0.0008 ETH
    address public owner;
    
    // amount of raised money in wei
    uint256 weiRaised;    
    
    struct ICOPhase {
        uint fromTimestamp; //ico starting timestamp
        uint toTimestamp; // ico end timestamp
        uint256 minimum; // Minimum purchase for each phase
        uint256 fundRaised;
        uint bonus; // In percent, ie 10 is a 10% for bonus
        uint totalNumberOfTokenPurchase; //number of token allowed for each phase
    }
    
    mapping(uint => ICOPhase) phases;
    uint icoPhaseCounter = 0;
    
    enum IcoStatus{Pending, Active, Inactive}
    IcoStatus status;    
    
    function SMARTRealty() public payable {
        
        owner = msg.sender;
        
        totalSupply = 500000000 * (10**uint256(decimals));          //500 million initial token creation
        
        //Tokens to creator wallet - For distribution        
        balances[owner] = 200000000 * (10**uint256(decimals)); //40% for public distribution
        
        //Initial Token Distribution
        balances[0xF9568bd772C9B517193275b3C2E0CDAd38E586bB] = 50000000 * (10**uint256(decimals)); //10% Development, Executive, and Advisory Teams
        balances[0x07ADB1D9399Bd1Fa4fD613D3179DFE883755Bb13] = 50000000 * (10**uint256(decimals)); //10% SMARTRealty Economy
        balances[0xd35909DbeEb5255D65b1ea14602C7f00ce3872f6] = 50000000 * (10**uint256(decimals)); //10% Marketing
        balances[0x9D2Fe4D5f1dc4FcA1f0Ea5f461C9fAA5D09b9CCE] = 50000000 * (10**uint256(decimals)); //10% SMARTMortgages
        balances[0x8Bb41848B6dD3D98b8849049b780dC3549568c89] = 25000000 * (10**uint256(decimals)); //5% Admin
        balances[0xC78DF195DE5717FB15FB3448D5C6893E8e7fB254] = 25000000 * (10**uint256(decimals)); //5% Contractors
        balances[0x4690678926BCf9B30985c06806d4568C0C498123] = 25000000 * (10**uint256(decimals)); //5% Legal
        balances[0x08AF803F0F90ccDBFCe046Bc113822cFf415e148] = 20000000 * (10**uint256(decimals)); //4% Bounties and Giveaways
        balances[0x8661dFb67dE4E5569da9859f5CB4Aa676cd5F480] = 5000000 * (10**uint256(decimals)); //1% Charitable Use
        
    }
    
    //Set ICO Status
    function activateICOStatus() public {
        status = IcoStatus.Active;
    }    
    
    //Set each Phase of your ICO here
    function setICOPhase(uint _fromTimestamp, uint _toTimestamp, uint256 _min, uint _bonus) onlyAdmin public returns (uint ICOPhaseId) {
        uint icoPhaseId = icoPhaseCounter++;
        ICOPhase storage ico = phases[icoPhaseId];
        ico.fromTimestamp = _fromTimestamp;
        ico.toTimestamp = _toTimestamp;
        ico.minimum = _min;
        ico.bonus = _bonus;
        //ico.totalNumberOfTokenPurchase = _numOfToken;

        phases[icoPhaseId] = ico;

        return icoPhaseId;
    }
    
    //Get current ICO Phase
    function getCurrentICOPhaseBonus() public view returns (uint _bonus, uint icoPhaseId) {
        require(icoPhaseCounter > 0);
        uint currentTimestamp = block.timestamp; //Get the current block timestamp

        for (uint i = 0; i < icoPhaseCounter; i++) {
            
            ICOPhase storage ico = phases[i];

            if (currentTimestamp >= ico.fromTimestamp && currentTimestamp <= ico.toTimestamp) {
                return (ico.bonus, i);
            }
        }

    }
    
    // Override this method to have a way to add business logic to your crowdsale when buying
    function getTokenAmount(uint256 weiAmount) internal returns(uint256 token, uint id) {
        var (bonus, phaseId) = getCurrentICOPhaseBonus();       //get current ICO phase information
        uint256 numOfTokens = weiAmount.safeMul(RATE);
        uint256 bonusToken = (bonus / 100) * numOfTokens;
        
        uint256 totalToken = numOfTokens.safeAdd(bonusToken);               //Total tokens to transfer
        return (totalToken, phaseId);
    }    
    
    // low level token purchase function
    function _buyTokens(address beneficiary) public payable {
        require(beneficiary != address(0) && beneficiary != owner);
        
        uint256 weiAmount = msg.value;
        
        // calculate token amount to be created
        var (tokens, phaseId) = getTokenAmount(weiAmount);
        
        //update the current ICO Phase
        ICOPhase storage ico = phases[phaseId]; //get phase
        ico.fundRaised = ico.fundRaised.safeAdd(msg.value); //Update fundRaised for a particular phase
        phases[phaseId] = ico;
        
        // update state
        weiRaised = weiRaised.safeAdd(weiAmount);
        
        _transferToken(beneficiary, tokens);
        TokenPurchase(msg.sender, beneficiary, weiAmount, tokens);
        
        forwardFunds();
    }
    
    function _transferToken(address _to, uint256 _amount) public returns (bool){
        balances[owner] = balances[owner].safeSub(_amount);
        balances[_to] = balances[_to].safeAdd(_amount);
        Transfer(address(0), _to, _amount);
        return true;        
    }
    
    // send ether to the fund collection wallet
    // override to create custom fund forwarding mechanisms
    function forwardFunds() internal {
        owner.transfer(msg.value);
    }    

    // fallback function can be used to buy tokens
    function () external payable {
        _buyTokens(msg.sender);
    } 
    
    
    event TokenPurchase(address _sender, address _beneficiary, uint256 weiAmount, uint256 tokens);
    
}