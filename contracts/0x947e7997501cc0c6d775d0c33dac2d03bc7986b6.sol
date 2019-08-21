pragma solidity 0.5.5; /*

___________________________________________________________________
  _      _                                        ______           
  |  |  /          /                                /              
--|-/|-/-----__---/----__----__---_--_----__-------/-------__------
  |/ |/    /___) /   /   ' /   ) / /  ) /___)     /      /   )     
__/__|____(___ _/___(___ _(___/_/_/__/_(___ _____/______(___/__o_o_


███████╗███╗   ██╗██╗   ██╗ ██████╗ ██╗   ██╗     ██████╗██╗  ██╗ █████╗ ██╗███╗   ██╗
██╔════╝████╗  ██║██║   ██║██╔═══██╗╚██╗ ██╔╝    ██╔════╝██║  ██║██╔══██╗██║████╗  ██║
█████╗  ██╔██╗ ██║██║   ██║██║   ██║ ╚████╔╝     ██║     ███████║███████║██║██╔██╗ ██║
██╔══╝  ██║╚██╗██║╚██╗ ██╔╝██║   ██║  ╚██╔╝      ██║     ██╔══██║██╔══██║██║██║╚██╗██║
███████╗██║ ╚████║ ╚████╔╝ ╚██████╔╝   ██║       ╚██████╗██║  ██║██║  ██║██║██║ ╚████║
╚══════╝╚═╝  ╚═══╝  ╚═══╝   ╚═════╝    ╚═╝        ╚═════╝╚═╝  ╚═╝╚═╝  ╚═╝╚═╝╚═╝  ╚═══╝
                                                                                      
                                                                                        
  
// ----------------------------------------------------------------------------
// 'Envoy' Token contract with following features
//      => ERC20 Compliance
//      => Higher degree of control by owner - safeguard functionality
//      => SafeMath implementation 
//      => Burnable and minting 
//      => user whitelisting 
//      => air drop (active and passive)
//      => in-built buy/sell functions 
//      => in-built ICO simple phased 
//      => upgradibilitiy 
//
// Name        : Envoy
// Symbol      : NVOY
// Total supply: 250,000,000
// Decimals    : 18
//
// Copyright 2019 onwards - Envoy Group ( http://envoychain.io )
// Special thanks to openzeppelin for inspiration: 
// https://github.com/zeppelinos/labs/tree/master/upgradeability_using_unstructured_storage
// ----------------------------------------------------------------------------
*/ 

//*******************************************************************//
//------------------------ SafeMath Library -------------------------//
//*******************************************************************//
/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    assert(c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

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


//*******************************************************************//
//------------------ Contract to Manage Ownership -------------------//
//*******************************************************************//
    
contract owned {
    address payable public owner;
    
     constructor () public {
        owner = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    function transferOwnership(address payable newOwner) onlyOwner public {
        owner = newOwner;
    }
}
    

    
//****************************************************************************//
//---------------------        MAIN CODE STARTS HERE     ---------------------//
//****************************************************************************//
    
contract EnvoyChain_v1 is owned {
    

    /*===============================
    =         DATA STORAGE          =
    ===============================*/

    // Public variables of the token
    using SafeMath for uint256;
    string public name;
    string public symbol;
    uint256 public decimals;
    uint256 public totalSupply;
    bool public safeguard = false;  //putting safeguard on will halt all non-owner functions

    // This creates a mapping with all data storage
    mapping (address => uint256) public balanceOf;
    mapping (address => mapping (address => uint256)) public allowance;
    mapping (address => bool) public frozenAccount;


    /*===============================
    =         PUBLIC EVENTS         =
    ===============================*/

    // This generates a public event of token transfer
    event Transfer(address indexed from, address indexed to, uint256 value);

    // This notifies clients about the amount burnt
    event Burn(address indexed from, uint256 value);
        
    // This generates a public event for frozen (blacklisting) accounts
    event FrozenFunds(address target, bool frozen);



    /*======================================
    =       STANDARD ERC20 FUNCTIONS       =
    ======================================*/

    /* Internal transfer, only can be called by this contract */
    function _transfer(address _from, address _to, uint _value) internal {
        
        //checking conditions
        require(!safeguard);
        require (_to != address(0));                      // Prevent transfer to 0x0 address. Use burn() instead
        require(!frozenAccount[_from]);                     // Check if sender is frozen
        require(!frozenAccount[_to]);                       // Check if recipient is frozen
        
        // overflow and undeflow checked by SafeMath Library
        balanceOf[_from] = balanceOf[_from].sub(_value);    // Subtract from the sender
        balanceOf[_to] = balanceOf[_to].add(_value);        // Add the same to the recipient
        
        // emit Transfer event
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
    function transfer(address _to, uint256 _value) public returns (bool success) {
        //no need to check for input validations, as that is ruled by SafeMath
        _transfer(msg.sender, _to, _value);
        return true;
    }

    /**
        * Transfer tokens from other address
        *
        * Send `_value` tokens to `_to` in behalf of `_from`
        *
        * @param _from The address of the sender
        * @param _to The address of the recipient
        * @param _value the amount to send
        */
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require(_value <= allowance[_from][msg.sender]);     // Check allowance
        allowance[_from][msg.sender] = allowance[_from][msg.sender].sub(_value);
        _transfer(_from, _to, _value);
        return true;
    }

    /**
        * Set allowance for other address
        *
        * Allows `_spender` to spend no more than `_value` tokens in your behalf
        *
        * @param _spender The address authorized to spend
        * @param _value the max amount they can spend
        */
    function approve(address _spender, uint256 _value) public returns (bool success) {
        require(!safeguard);
        allowance[msg.sender][_spender] = _value;
        return true;
    }


    /*=====================================
    =       CUSTOM PUBLIC FUNCTIONS       =
    ======================================*/
    
    constructor() public{
        //sending all the tokens to Owner
        balanceOf[owner] = totalSupply;
        
        //firing event which logs this transaction
        emit Transfer(address(0), owner, totalSupply);
    }
    
    function () external payable {
        
        buyTokens();
    }

    /**
        * Destroy tokens
        *
        * Remove `_value` tokens from the system irreversibly
        *
        * @param _value the amount of money to burn
        */
    function burn(uint256 _value) public returns (bool success) {
        require(!safeguard);
        //checking of enough token balance is done by SafeMath
        balanceOf[msg.sender] = balanceOf[msg.sender].sub(_value);  // Subtract from the sender
        totalSupply = totalSupply.sub(_value);                      // Updates totalSupply
        emit Burn(msg.sender, _value);
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
    function burnFrom(address _from, uint256 _value) public returns (bool success) {
        require(!safeguard);
        //checking of allowance and token value is done by SafeMath
        balanceOf[_from] = balanceOf[_from].sub(_value);                         // Subtract from the targeted balance
        allowance[_from][msg.sender] = allowance[_from][msg.sender].sub(_value); // Subtract from the sender's allowance
        totalSupply = totalSupply.sub(_value);                                   // Update totalSupply
        emit  Burn(_from, _value);
        return true;
    }
        
    
    /** 
        * @notice `freeze? Prevent | Allow` `target` from sending & receiving tokens
        * @param target Address to be frozen
        * @param freeze either to freeze it or not
        */
    function freezeAccount(address target, bool freeze) onlyOwner public {
            frozenAccount[target] = freeze;
        emit  FrozenFunds(target, freeze);
    }
    
    /** 
        * @notice Create `mintedAmount` tokens and send it to `target`
        * @param target Address to receive the tokens
        * @param mintedAmount the amount of tokens it will receive
        */
    function mintToken(address target, uint256 mintedAmount) onlyOwner public {
        balanceOf[target] = balanceOf[target].add(mintedAmount);
        totalSupply = totalSupply.add(mintedAmount);
        emit Transfer(address(0), target, mintedAmount);
    }

        

    /**
        * Owner can transfer tokens from contract to owner address
        *
        * When safeguard is true, then all the non-owner functions will stop working.
        * When safeguard is false, then all the functions will resume working back again!
        */
    
    function manualWithdrawTokens(uint256 tokenAmount) public onlyOwner{
        // no need for overflow checking as that will be done in transfer function
        _transfer(address(this), owner, tokenAmount);
    }
    
    //Just in rare case, owner wants to transfer Ether from contract to owner address
    function manualWithdrawEther()onlyOwner public{
        address(owner).transfer(address(this).balance);
    }
    
    /**
        * Change safeguard status on or off
        *
        * When safeguard is true, then all the non-owner functions will stop working.
        * When safeguard is false, then all the functions will resume working back again!
        */
    function changeSafeguardStatus() onlyOwner public{
        if (safeguard == false){
            safeguard = true;
        }
        else{
            safeguard = false;    
        }
    }
    
    /*************************************/
    /*    Section for User Air drop      */
    /*************************************/
    
    bool public passiveAirdropStatus;
    uint256 public passiveAirdropTokensAllocation;
    uint256 public airdropAmount;  //in wei
    uint256 public passiveAirdropTokensSold;
    mapping(uint256 => mapping(address => bool)) public airdropClaimed;
    uint256 internal airdropClaimedIndex;
    uint256 public airdropFee = 0.05 ether;
    
    /**
     * This function to start a passive air drop by admin only
     * Admin have to put airdrop amount (in wei) and total toens allocated for it.
     * Admin must keep allocated tokens in the contract
     */
    function startNewPassiveAirDrop(uint256 passiveAirdropTokensAllocation_, uint256 airdropAmount_  ) public onlyOwner {
        passiveAirdropTokensAllocation = passiveAirdropTokensAllocation_;
        airdropAmount = airdropAmount_;
        passiveAirdropStatus = true;
    } 
    
    /**
     * This function will stop any ongoing passive airdrop
     */
    function stopPassiveAirDropCompletely() public onlyOwner{
        passiveAirdropTokensAllocation = 0;
        airdropAmount = 0;
        airdropClaimedIndex++;
        passiveAirdropStatus = false;
    }
    
    /**
     * This function called by user who want to claim passive air drop.
     * He can only claim air drop once, for current air drop. If admin stop an air drop and start fresh, then users can claim again (once only).
     */
    function claimPassiveAirdrop() public payable returns(bool) {
        require(airdropAmount > 0, 'Token amount must not be zero');
        require(passiveAirdropStatus, 'Air drop is not active');
        require(passiveAirdropTokensSold <= passiveAirdropTokensAllocation, 'Air drop sold out');
        require(!airdropClaimed[airdropClaimedIndex][msg.sender], 'user claimed air drop already');
        require(!isContract(msg.sender),  'No contract address allowed to claim air drop');
        require(msg.value >= airdropFee, 'Not enough ether to claim this airdrop');
        
        _transfer(address(this), msg.sender, airdropAmount);
        passiveAirdropTokensSold += airdropAmount;
        airdropClaimed[airdropClaimedIndex][msg.sender] = true; 
        return true;
    }
    
    function changePassiveAirdropAmount(uint256 newAmount) public onlyOwner{
        airdropAmount = newAmount;
    }
    
    function isContract(address _address) public view returns (bool){
        uint32 size;
        assembly {
            size := extcodesize(_address)
        }
        return (size > 0);
    }
    
    function updateAirdropFee(uint256 newFee) public onlyOwner{
        airdropFee = newFee;
    }
    
    /**
     * Run an ACTIVE Air-Drop
     *
     * It requires an array of all the addresses and amount of tokens to distribute
     * It will only process first 150 recipients. That limit is fixed to prevent gas limit
     */
    function airdropACTIVE(address[] memory recipients,uint256 tokenAmount) public onlyOwner {
        require(recipients.length <= 150);
        uint256 totalAddresses = recipients.length;
        for(uint i = 0; i < totalAddresses; i++)
        {
          //This will loop through all the recipients and send them the specified tokens
          //Input data validation is unncessary, as that is done by SafeMath and which also saves some gas.
          _transfer(address(this), recipients[i], tokenAmount);
        }
    }
    
    
    
    
    /*************************************/
    /*  Section for User whitelisting    */
    /*************************************/
    bool public whitelistingStatus;
    mapping (address => bool) public whitelisted;
    
    /**
     * Change whitelisting status on or off
     *
     * When whitelisting is true, then crowdsale will only accept investors who are whitelisted.
     */
    function changeWhitelistingStatus() onlyOwner public{
        if (whitelistingStatus == false){
            whitelistingStatus = true;
        }
        else{
            whitelistingStatus = false;    
        }
    }
    
    /**
     * Whitelist any user address - only Owner can do this
     *
     * It will add user address in whitelisted mapping
     */
    function whitelistUser(address userAddress) onlyOwner public{
        require(whitelistingStatus == true);
        require(userAddress != address(0));
        whitelisted[userAddress] = true;
    }
    
    /**
     * Whitelist Many user address at once - only Owner can do this
     * It will require maximum of 150 addresses to prevent block gas limit max-out and DoS attack
     * It will add user address in whitelisted mapping
     */
    function whitelistManyUsers(address[] memory userAddresses) onlyOwner public{
        require(whitelistingStatus == true);
        uint256 addressCount = userAddresses.length;
        require(addressCount <= 150);
        for(uint256 i = 0; i < addressCount; i++){
            require(userAddresses[i] != address(0));
            whitelisted[userAddresses[i]] = true;
        }
    }
    
    
    /*************************************/
    /*  Section for Buy/Sell of tokens   */
    /*************************************/
    
    uint256 public sellPrice;
    uint256 public buyPrice;
    
    /** 
     * Allow users to buy tokens for `newBuyPrice` eth and sell tokens for `newSellPrice` eth
     * newSellPrice Price the users can sell to the contract
     * newBuyPrice Price users can buy from the contract
     */
    function setPrices(uint256 newSellPrice, uint256 newBuyPrice) onlyOwner public {
        sellPrice = newSellPrice;   //sellPrice is 1 Token = ?? WEI
        buyPrice = newBuyPrice;     //buyPrice is 1 ETH = ?? Tokens
    }

    /**
     * Buy tokens from contract by sending ether
     * buyPrice is 1 ETH = ?? Tokens
     */
    
    function buyTokens() payable public {
        uint amount = msg.value * buyPrice;                 // calculates the amount
        _transfer(address(this), msg.sender, amount);       // makes the transfers
    }

    /**
     * Sell `amount` tokens to contract
     * amount amount of tokens to be sold
     */
    function sellTokens(uint256 amount) public {
        uint256 etherAmount = amount * sellPrice/(10**decimals);
        require(address(this).balance >= etherAmount);   // checks if the contract has enough ether to buy
        _transfer(msg.sender, address(this), amount);           // makes the transfers
        msg.sender.transfer(etherAmount);                // sends ether to the seller. It's important to do this last to avoid recursion attacks
    }
    
    
    /********************************************/
    /* Custom Code for the contract Upgradation */
    /********************************************/
    
    bool internal initialized;
    function initialize(
        address payable _owner
    ) public {
        require(!initialized);
        require(owner == address(0)); //When this methods called, then owner address must be zero

        name = "Envoy";
        symbol = "NVOY";
        decimals = 18;
        totalSupply = 250000000 * (10**decimals);
        owner = _owner;
        
        //sending all the tokens to Owner
        balanceOf[owner] = totalSupply;
        
        //firing event which logs this transaction
        emit Transfer(address(0), owner, totalSupply);
        
        initialized = true;
    }
    

}







//********************************************************************************//
//-------------  MAIN PROXY CONTRACTS (UPGRADEABILITY) SECTION STARTS ------------//
//********************************************************************************//


/****************************************/
/*            Proxy Contract            */
/****************************************/
/**
 * @title Proxy
 * @dev Gives the possibility to delegate any call to a foreign implementation.
 */
contract Proxy {
  /**
  * @dev Tells the address of the implementation where every call will be delegated.
  * @return address of the implementation to which it will be delegated
  */
  function implementation() public view returns (address);

  /**
  * @dev Fallback function allowing to perform a delegatecall to the given implementation.
  * This function will return whatever the implementation call returns
  */
  function () payable external {
    address _impl = implementation();
    require(_impl != address(0));

    assembly {
      let ptr := mload(0x40)
      calldatacopy(ptr, 0, calldatasize)
      let result := delegatecall(gas, _impl, ptr, calldatasize, 0, 0)
      let size := returndatasize
      returndatacopy(ptr, 0, size)

      switch result
      case 0 { revert(ptr, size) }
      default { return(ptr, size) }
    }
  }
}


/****************************************/
/*    UpgradeabilityProxy Contract      */
/****************************************/
/**
 * @title UpgradeabilityProxy
 * @dev This contract represents a proxy where the implementation address to which it will delegate can be upgraded
 */
contract UpgradeabilityProxy is Proxy {
  /**
   * @dev This event will be emitted every time the implementation gets upgraded
   * @param implementation representing the address of the upgraded implementation
   */
  event Upgraded(address indexed implementation);

  // Storage position of the address of the current implementation
  bytes32 private constant implementationPosition = keccak256("EtherAuthority.io.proxy.implementation");

  /**
   * @dev Constructor function
   */
  constructor () public {}

  /**
   * @dev Tells the address of the current implementation
   * @return address of the current implementation
   */
  function implementation() public view returns (address impl) {
    bytes32 position = implementationPosition;
    assembly {
      impl := sload(position)
    }
  }

  /**
   * @dev Sets the address of the current implementation
   * @param newImplementation address representing the new implementation to be set
   */
  function setImplementation(address newImplementation) internal {
    bytes32 position = implementationPosition;
    assembly {
      sstore(position, newImplementation)
    }
  }

  /**
   * @dev Upgrades the implementation address
   * @param newImplementation representing the address of the new implementation to be set
   */
  function _upgradeTo(address newImplementation) internal {
    address currentImplementation = implementation();
    require(currentImplementation != newImplementation);
    setImplementation(newImplementation);
    emit Upgraded(newImplementation);
  }
}

/****************************************/
/*  OwnedUpgradeabilityProxy contract   */
/****************************************/
/**
 * @title OwnedUpgradeabilityProxy
 * @dev This contract combines an upgradeability proxy with basic authorization control functionalities
 */
contract OwnedUpgradeabilityProxy is UpgradeabilityProxy {
  /**
  * @dev Event to show ownership has been transferred
  * @param previousOwner representing the address of the previous owner
  * @param newOwner representing the address of the new owner
  */
  event ProxyOwnershipTransferred(address previousOwner, address newOwner);

  // Storage position of the owner of the contract
  bytes32 private constant proxyOwnerPosition = keccak256("EtherAuthority.io.proxy.owner");

  /**
  * @dev the constructor sets the original owner of the contract to the sender account.
  */
  constructor () public {
    setUpgradeabilityOwner(msg.sender);
  }

  /**
  * @dev Throws if called by any account other than the owner.
  */
  modifier onlyProxyOwner() {
    require(msg.sender == proxyOwner());
    _;
  }

  /**
   * @dev Tells the address of the owner
   * @return the address of the owner
   */
  function proxyOwner() public view returns (address owner) {
    bytes32 position = proxyOwnerPosition;
    assembly {
      owner := sload(position)
    }
  }

  /**
   * @dev Sets the address of the owner
   */
  function setUpgradeabilityOwner(address newProxyOwner) internal {
    bytes32 position = proxyOwnerPosition;
    assembly {
      sstore(position, newProxyOwner)
    }
  }

  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param newOwner The address to transfer ownership to.
   */
  function transferProxyOwnership(address newOwner) public onlyProxyOwner {
    require(newOwner != address(0));
    emit ProxyOwnershipTransferred(proxyOwner(), newOwner);
    setUpgradeabilityOwner(newOwner);
  }

  /**
   * @dev Allows the proxy owner to upgrade the current version of the proxy.
   * @param implementation representing the address of the new implementation to be set.
   */
  function upgradeTo(address implementation) public onlyProxyOwner {
    _upgradeTo(implementation);
  }

  /**
   * @dev Allows the proxy owner to upgrade the current version of the proxy and call the new implementation
   * to initialize whatever is needed through a low level call.
   * @param implementation representing the address of the new implementation to be set.
   * @param data represents the msg.data to bet sent in the low level call. This parameter may include the function
   * signature of the implementation to be called with the needed payload
   */
  function upgradeToAndCall(address implementation, bytes memory data) payable public onlyProxyOwner {
    _upgradeTo(implementation);
    (bool success,) = address(this).call.value(msg.value).gas(200000)(data);
    require(success,'initialize function errored');
  }
  
  function generateData() public view returns(bytes memory){
        
    return abi.encodeWithSignature("initialize(address)",msg.sender);
      
  }
}


/****************************************/
/*      EnvoyChain Proxy Contract       */
/****************************************/

/**
 * @title EnvoyChain_proxy
 * @dev This contract proxies FiatToken calls and enables FiatToken upgrades
*/ 
contract EnvoyChain_proxy is OwnedUpgradeabilityProxy {
    constructor() public OwnedUpgradeabilityProxy() {
    }
}