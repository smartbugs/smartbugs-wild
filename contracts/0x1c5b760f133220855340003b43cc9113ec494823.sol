pragma solidity 0.4.25; /*


___________________________________________________________________
  _      _                                        ______           
  |  |  /          /                                /              
--|-/|-/-----__---/----__----__---_--_----__-------/-------__------
  |/ |/    /___) /   /   ' /   ) / /  ) /___)     /      /   )     
__/__|____(___ _/___(___ _(___/_/_/__/_(___ _____/______(___/__o_o_


 ██████╗ ██████╗ ██╗███╗   ██╗████████╗ ██████╗ ██████╗  ██████╗ ██╗  ██╗
██╔════╝██╔═══██╗██║████╗  ██║╚══██╔══╝██╔═══██╗██╔══██╗██╔═══██╗╚██╗██╔╝
██║     ██║   ██║██║██╔██╗ ██║   ██║   ██║   ██║██████╔╝██║   ██║ ╚███╔╝ 
██║     ██║   ██║██║██║╚██╗██║   ██║   ██║   ██║██╔══██╗██║   ██║ ██╔██╗ 
╚██████╗╚██████╔╝██║██║ ╚████║   ██║   ╚██████╔╝██║  ██║╚██████╔╝██╔╝ ██╗
 ╚═════╝ ╚═════╝ ╚═╝╚═╝  ╚═══╝   ╚═╝    ╚═════╝ ╚═╝  ╚═╝ ╚═════╝ ╚═╝  ╚═╝
                                                                         

// ----------------------------------------------------------------------------
// 'Cointorox' Token contract with following features
//      => ERC20 Compliance
//      => Higher control of ICO by owner
//      => selfdestruct ability by owner
//      => SafeMath implementation 
//      => User whitelisting
//      => Burnable and no minting
//
// Name        : Cointorox
// Symbol      : OROX
// Total supply: 10,000,000 (10 Million)
// Decimals    : 18
//
// Copyright (c) 2018 Cointorox Inc. ( https://cointorox.com )
// Contract designed by EtherAuthority ( https://EtherAuthority.io )
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
        address public owner;
        
         constructor () public {
            owner = msg.sender;
        }
    
        modifier onlyOwner {
            require(msg.sender == owner);
            _;
        }
    
        function transferOwnership(address newOwner) onlyOwner public {
            owner = newOwner;
        }
    }
    
    interface tokenRecipient { function receiveApproval(address _from, uint256 _value, address _token, bytes  _extraData) external; }


//***************************************************************//
//------------------ ERC20 Standard Template -------------------//
//***************************************************************//
    
    contract TokenERC20 {
        // Public variables of the token
        using SafeMath for uint256;
        string public name;
        string public symbol;
        uint8 public decimals = 18; // 18 decimals is the strongly suggested default, avoid changing it
        uint256 public totalSupply;
        bool public safeguard = false;  //putting safeguard on will halt all non-owner functions
    
        // This creates an array with all balances
        mapping (address => uint256) public balanceOf;
        mapping (address => mapping (address => uint256)) public allowance;
    
        // This generates a public event on the blockchain that will notify clients
        event Transfer(address indexed from, address indexed to, uint256 value);
    
        // This notifies clients about the amount burnt
        event Burn(address indexed from, uint256 value);
    
        /**
         * Constrctor function
         *
         * Initializes contract with initial supply tokens to the creator of the contract
         */
        constructor (
            uint256 initialSupply,
            string memory tokenName,
            string memory tokenSymbol
        ) public {
            totalSupply = initialSupply.mul(1 ether);       // Update total supply with the decimal amount
            balanceOf[msg.sender] = totalSupply;            // All the tokens will be sent to owner
            name = tokenName;                               // Set the name for display purposes
            symbol = tokenSymbol;                           // Set the symbol for display purposes
        }
    
        /**
         * Internal transfer, only can be called by this contract
         */
        function _transfer(address _from, address _to, uint _value) internal {
            require(!safeguard);
            // Prevent transfer to 0x0 address. Use burn() instead
            require(_to != address(0x0));
            // Check if the sender has enough
            require(balanceOf[_from] >= _value);
            // Check for overflows
            require(balanceOf[_to].add(_value) > balanceOf[_to]);
            // Save this for an assertion in the future
            uint previousBalances = balanceOf[_from].add(balanceOf[_to]);
            // Subtract from the sender
            balanceOf[_from] = balanceOf[_from].sub(_value);
            // Add the same to the recipient
            balanceOf[_to] = balanceOf[_to].add(_value);
            emit Transfer(_from, _to, _value);
            // Asserts are used to use static analysis to find bugs in your code. They should never fail
            assert(balanceOf[_from].add(balanceOf[_to]) == previousBalances);
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
            require(!safeguard);
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
        function approve(address _spender, uint256 _value) public
            returns (bool success) {
            require(!safeguard);
            allowance[msg.sender][_spender] = _value;
            return true;
        }
    
        /**
         * Set allowance for other address and notify
         *
         * Allows `_spender` to spend no more than `_value` tokens in your behalf, and then ping the contract about it
         *
         * @param _spender The address authorized to spend
         * @param _value the max amount they can spend
         * @param _extraData some extra information to send to the approved contract
         */
        function approveAndCall(address _spender, uint256 _value, bytes memory _extraData)
            public
            returns (bool success) {
            require(!safeguard);
            tokenRecipient spender = tokenRecipient(_spender);
            if (approve(_spender, _value)) {
                spender.receiveApproval(msg.sender, _value, address(this), _extraData);
                return true;
            }
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
            require(balanceOf[msg.sender] >= _value);   // Check if the sender has enough
            balanceOf[msg.sender] = balanceOf[msg.sender].sub(_value);            // Subtract from the sender
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
            require(balanceOf[_from] >= _value);                // Check if the targeted balance is enough
            require(_value <= allowance[_from][msg.sender]);    // Check allowance
            balanceOf[_from] = balanceOf[_from].sub(_value);                         // Subtract from the targeted balance
            allowance[_from][msg.sender] = allowance[_from][msg.sender].sub(_value);             // Subtract from the sender's allowance
            totalSupply = totalSupply.sub(_value);                              // Update totalSupply
            emit  Burn(_from, _value);
            return true;
        }
        
    }
    
//****************************************************************************//
//---------------------  COINTOROX MAIN CODE STARTS HERE ---------------------//
//****************************************************************************//
    
    contract Cointorox is owned, TokenERC20 {
        
        /*************************************/
        /*  User whitelisting functionality  */
        /*************************************/
        bool public whitelistingStatus = false;
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
            require(userAddress != address(0x0));
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
                require(userAddresses[i] != address(0x0));
                whitelisted[userAddresses[i]] = true;
            }
        }
        
        
        
        /*********************************/
        /* Code for the ERC20 OROX Token */
        /*********************************/
    
        /* Public variables of the token */
        string private tokenName = "Cointorox";
        string private tokenSymbol = "OROX";
        uint256 private initialSupply = 10000000;  //10 Million
        
        
        /* Records for the fronzen accounts */
        mapping (address => bool) public frozenAccount;
        
        /* This generates a public event on the blockchain that will notify clients */
        event FrozenFunds(address target, bool frozen);
    
        /* Initializes contract with initial supply tokens to the creator of the contract */
        constructor () TokenERC20(initialSupply, tokenName, tokenSymbol) public {}

        /* Internal transfer, only can be called by this contract */
        function _transfer(address _from, address _to, uint _value) internal {
            require(!safeguard);
            require (_to != address(0x0));                      // Prevent transfer to 0x0 address. Use burn() instead
            require (balanceOf[_from] >= _value);               // Check if the sender has enough
            require (balanceOf[_to].add(_value) >= balanceOf[_to]); // Check for overflows
            require(!frozenAccount[_from]);                     // Check if sender is frozen
            require(!frozenAccount[_to]);                       // Check if recipient is frozen
            balanceOf[_from] = balanceOf[_from].sub(_value);    // Subtract from the sender
            balanceOf[_to] = balanceOf[_to].add(_value);        // Add the same to the recipient
            emit Transfer(_from, _to, _value);
        }
        
        /// @notice `freeze? Prevent | Allow` `target` from sending & receiving tokens
        /// @param target Address to be frozen
        /// @param freeze either to freeze it or not
        function freezeAccount(address target, bool freeze) onlyOwner public {
                frozenAccount[target] = freeze;
            emit  FrozenFunds(target, freeze);
        }

          
        //Just in rare case, owner wants to transfer Ether from contract to owner address
        function manualWithdrawEther()onlyOwner public{
            address(owner).transfer(address(this).balance);
        }
        
        //selfdestruct function. just in case owner decided to destruct this contract.
        function destructContract()onlyOwner public{
            selfdestruct(owner);
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

}