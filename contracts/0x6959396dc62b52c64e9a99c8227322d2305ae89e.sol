pragma solidity ^0.4.23;

// File: contracts/Ownable.sol

/**
     * @title Ownable
     * @dev The Ownable contract has an owner address, and provides basic authorization control
     * functions, this simplifies the implementation of "user permissions".
     */
    contract Ownable {
      address public owner;
    
      event OwnershipRenounced(address indexed previousOwner);
      event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    
      /**
       * @dev The Ownable constructor sets the original `owner` of the contract to the sender
       * account.
       */
      //function Ownable() public {
      constructor() public {
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
      function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0));
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
      }
    
      /**
       * @dev Allows the current owner to relinquish control of the contract.
       */
      function renounceOwnership() public onlyOwner {
        emit OwnershipRenounced(owner);
        owner = address(0);
      }
    }

// File: contracts/CeoOwner.sol

contract CeoOwner is Ownable{

	// The primary address which is permitted to interact with the contract
	// Address of wallet account on WEB3.js account.
	address public ceoAddress; 

	modifier onlyCEO() {
		require(msg.sender == ceoAddress);
		_;
	}

}

// File: contracts/ReentrancyGuard.sol

/**
 * @title Helps contracts guard agains reentrancy attacks.
 * @author Remco Bloemen <remco@2π.com>
 * @notice If you mark a function `nonReentrant`, you should also
 * mark it `external`.
 */
 contract ReentrancyGuard {

  /**
   * @dev We use a single lock for the whole contract.
   */
   bool private reentrancyLock = false;

  /**
   * @dev Prevents a contract from calling itself, directly or indirectly.
   * @notice If you mark a function `nonReentrant`, you should also
   * mark it `external`. Calling one nonReentrant function from
   * another is not supported. Instead, you can implement a
   * `private` function doing the actual work, and a `external`
   * wrapper marked as `nonReentrant`.
   */
   modifier nonReentrant() {
    require(!reentrancyLock);
    reentrancyLock = true;
    _;
    reentrancyLock = false;
  }

}

// File: contracts/SafeMath.sol

/**
     * @title SafeMath
     * @dev Math operations with safety checks that throw on error
     */
     library SafeMath {
      
      /**
      * @dev Multiplies two numbers, throws on overflow.
      */
      function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
        if (a == 0) {
          return 0;
        }
        c = a * b;
        assert(c / a == b);
        return c;
      }
      
      /**
      * @dev Integer division of two numbers, truncating the quotient.
      */
      function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // assert(b > 0); // Solidity automatically throws when dividing by 0
        // uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return a / b;
      }
      
      /**
      * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
      */
      function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
      }
      
      /**
      * @dev Adds two numbers, throws on overflow.
      */
      function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
        c = a + b;
        assert(c >= a);
        return c;
      }
    }

// File: contracts/CertificateCore.sol

contract CertificateCore is CeoOwner, ReentrancyGuard { 
   
    using SafeMath for uint256; 

    uint256 public constant KEY_CREATION_LIMIT = 10000;
    uint256 public totalSupplyOfKeys;
    uint256 public totalReclaimedKeys;
    
    // Track who is making the deposits and the amount made
    mapping(address => uint256) public balanceOf; 

    // Main data structure to hold all of the public keys   
    mapping(address => bool) public allThePublicKeys;
    
    // A bonus deposit has been made
    event DepositBonusEvent(address sender, uint256 amount); 
    
    // A new certificate has been successfully sold and a deposit added
    event DepositCertificateSaleEvent(address sender, address publicKey, uint256 amount);

    // A certificate has been payed out.
    event CertPayedOutEvent(address sender, address recpublicKey, uint256 payoutValue);
    

    constructor(address _ceoAddress) public{
        require(_ceoAddress != address(0));
        owner = msg.sender;
        ceoAddress = _ceoAddress;
    }
 
    
    /**
     *
     * Main function for creating certificates
     * 
     */
    //function createANewCert(address _publicKey, uint256 _amount) external payable onlyCEO{
    function depositCertificateSale(address _publicKey, uint256 _amount) external payable onlyCEO{
        require(msg.sender != address(0));
        require(_amount > 0);
        require(msg.value == _amount);
        require(_publicKey != address(0));
        require(totalSupplyOfKeys < KEY_CREATION_LIMIT);
        require(totalReclaimedKeys < KEY_CREATION_LIMIT);
 
        require(!allThePublicKeys[_publicKey]);

        allThePublicKeys[_publicKey]=true;
        totalSupplyOfKeys ++;

        balanceOf[msg.sender] = balanceOf[msg.sender].add(_amount);
        
        emit DepositCertificateSaleEvent(msg.sender, _publicKey, _amount);
    }
    
    /**
     *  Allow the CEO to deposit ETH without creating a new certificate
     * 
     * */
    //function deposit(uint256 _amount) external payable onlyCEO {
    function depositBonus(uint256 _amount) external payable onlyCEO {
        require(_amount > 0);
        require(msg.value == _amount);
      
        require((totalSupplyOfKeys > 0) && (totalSupplyOfKeys < KEY_CREATION_LIMIT));
        require(totalReclaimedKeys < KEY_CREATION_LIMIT);
      
        balanceOf[msg.sender] = balanceOf[msg.sender].add(_amount);
        
        emit DepositBonusEvent(msg.sender, _amount);
    }
    
    /**
     * Payout a certificate. 
     * 
     */
    function payoutACert(bytes32 _msgHash, uint8 _v, bytes32 _r, bytes32 _s) external nonReentrant{
        require(msg.sender != address(0));
        require(address(this).balance > 0);
        require(totalSupplyOfKeys > 0);
        require(totalReclaimedKeys < KEY_CREATION_LIMIT);
         
        address _recoveredAddress = ecrecover(_msgHash, _v, _r, _s);
        require(allThePublicKeys[_recoveredAddress]);
    
        allThePublicKeys[_recoveredAddress]=false;

        uint256 _validKeys = totalSupplyOfKeys.sub(totalReclaimedKeys);
        uint256 _payoutValue = address(this).balance.div(_validKeys);

        msg.sender.transfer(_payoutValue);
        emit CertPayedOutEvent(msg.sender, _recoveredAddress, _payoutValue);
        
        totalReclaimedKeys ++;
    }
 
     /**
     * Update payout value per certificate.
     */
     //
     // debug only. remove in Live deploy.
     // do this operation on the Dapp side.
    function calculatePayout() view external returns(
        uint256 _etherValue
        ){
        uint256 _validKeys = totalSupplyOfKeys.sub(totalReclaimedKeys);
        // Last key has been paid out.
        if(_validKeys == 0){
            _etherValue = 0;
        }else{
            _etherValue = address(this).balance.div(_validKeys);
        }
    }
 
 
    /**
     * Check to see if a Key has been payed out or if it's still valid
     */
    function checkIfValidKey(address _publicKey) view external{ // external
        require(_publicKey != address(0));
        require(allThePublicKeys[_publicKey]);
    }

    function getBalance() view external returns(
         uint256 contractBalance
    ){
        contractBalance = address(this).balance;
    }
    
    /**
     * Saftey Mechanism
     * 
     */
    function kill() external onlyOwner 
    { 
        selfdestruct(owner); 
    }
 
    /**
     * Payable fallback function.
     * No Tipping! 
     * 
     */
    //function () payable public{
    //    throw;
    //}
    
}

// File: contracts/Migrations.sol

contract Migrations {
  address public owner;
  uint public last_completed_migration;

  modifier restricted() {
    if (msg.sender == owner) _;
  }

  //function Migrations() public {
  constructor() public {
    owner = msg.sender;
  }

  function setCompleted(uint completed) public restricted {
    last_completed_migration = completed;
  }

  function upgrade(address new_address) public restricted {
    Migrations upgraded = Migrations(new_address);
    upgraded.setCompleted(last_completed_migration);
  }
}