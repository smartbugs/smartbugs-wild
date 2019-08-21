pragma solidity 0.4.25; /*

___________________________________________________________________
  _      _                                        ______           
  |  |  /          /                                /              
--|-/|-/-----__---/----__----__---_--_----__-------/-------__------
  |/ |/    /___) /   /   ' /   ) / /  ) /___)     /      /   )     
__/__|____(___ _/___(___ _(___/_/_/__/_(___ _____/______(___/__o_o_


███████╗████████╗ ██████╗ ██████╗  █████╗  ██████╗      ██████╗ ██████╗ ██╗███╗   ██╗
██╔════╝╚══██╔══╝██╔═══██╗██╔══██╗██╔══██╗██╔════╝     ██╔════╝██╔═══██╗██║████╗  ██║
███████╗   ██║   ██║   ██║██████╔╝███████║██║  ███╗    ██║     ██║   ██║██║██╔██╗ ██║
╚════██║   ██║   ██║   ██║██╔══██╗██╔══██║██║   ██║    ██║     ██║   ██║██║██║╚██╗██║
███████║   ██║   ╚██████╔╝██║  ██║██║  ██║╚██████╔╝    ╚██████╗╚██████╔╝██║██║ ╚████║
╚══════╝   ╚═╝    ╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═╝ ╚═════╝      ╚═════╝ ╚═════╝ ╚═╝╚═╝  ╚═══╝
                                                                                     


// ----------------------------------------------------------------------------
// 'Storag Coin' contract with following features
//      => In-built ICO functionality - receive tokens when sent ether to contract address
//      => ERC20 Compliance
//      => Higher control of ICO by owner
//      => selfdestruct functionality
//      => SafeMath implementation 
//      => User whitelisting
//      => Minting new tokens by owner
//
// Name        : Storag Coin
// Symbol      : STG
// Decimals    : 8
// Total supply: 1,000,000,000  (1 Billion)
//
// Copyright (c) 2018 Storag Coin Inc. The MIT Licence.
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
    
    interface tokenRecipient { function receiveApproval(address _from, uint256 _value, address _token, bytes _extraData) external; }


//***************************************************************//
//------------------ ERC20 Standard Template -------------------//
//***************************************************************//
    
    contract TokenERC20 {
        // Public variables of the token
        using SafeMath for uint256;
        string public name;
        string public symbol;
        uint256 public decimals = 8; 
        uint256 public totalSupply;
        uint256 public reservedForICO;
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
            uint256 allocatedForICO,
            string tokenName,
            string tokenSymbol
        ) public {
            totalSupply = initialSupply.mul(1e8);       // Update total supply with the decimal amount
            reservedForICO = allocatedForICO.mul(1e8);  // Tokens reserved For ICO
            balanceOf[this] = reservedForICO;           // 250 Million Tokens will remain in the contract
            balanceOf[msg.sender]=totalSupply.sub(reservedForICO); // Rest of tokens will be sent to owner
            name = tokenName;                           // Set the name for display purposes
            symbol = tokenSymbol;                       // Set the symbol for display purposes
        }
    
        /**
         * Internal transfer, only can be called by this contract
         */
        function _transfer(address _from, address _to, uint _value) internal {
            require(!safeguard);
            // Prevent transfer to 0x0 address. Use burn() instead
            require(_to != 0x0);
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
        function approveAndCall(address _spender, uint256 _value, bytes _extraData)
            public
            returns (bool success) {
            require(!safeguard);
            tokenRecipient spender = tokenRecipient(_spender);
            if (approve(_spender, _value)) {
                spender.receiveApproval(msg.sender, _value, this, _extraData);
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
    
//******************************************************************************//
//---------------------  STORAG COIN MAIN CODE STARTS HERE --------------------//
//******************************************************************************//
    
    contract StoragCoin is owned, TokenERC20 {
        
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
            require(userAddress != 0x0);
            whitelisted[userAddress] = true;
        }
        
        /**
         * Whitelist Many user address at once - only Owner can do this
         * It will require maximum of 150 addresses to prevent block gas limit max-out and DoS attack
         * It will add user address in whitelisted mapping
         */
        function whitelistManyUsers(address[] userAddresses) onlyOwner public{
            require(whitelistingStatus == true);
            uint256 addressCount = userAddresses.length;
            require(addressCount <= 150);
            for(uint256 i = 0; i < addressCount; i++){
                require(userAddresses[i] != 0x0);
                whitelisted[userAddresses[i]] = true;
            }
        }
        
        
        
        /********************************/
        /* Code for the ERC20 STG Token */
        /********************************/
    
        /* Public variables of the token */
        string private tokenName = "Storag Coin";
        string private tokenSymbol = "STG";
        uint256 private initialSupply = 1000000000;     // 1 Billion
        uint256 private allocatedForICO = 250000000;    // 250 Million
        
        
        /* Records for the fronzen accounts */
        mapping (address => bool) public frozenAccount;
        
        /* This generates a public event on the blockchain that will notify clients */
        event FrozenFunds(address target, bool frozen);
    
        /* Initializes contract with initial supply tokens to the creator of the contract */
        constructor () TokenERC20(initialSupply, allocatedForICO, tokenName, tokenSymbol) public {}

        /* Internal transfer, only can be called by this contract */
        function _transfer(address _from, address _to, uint _value) internal {
            require(!safeguard);
            require (_to != 0x0);                               // Prevent transfer to 0x0 address. Use burn() instead
            require (balanceOf[_from] >= _value);               // Check if the sender has enough
            require (balanceOf[_to].add(_value) >= balanceOf[_to]); // Check for overflows
            require(!frozenAccount[_from]);                     // Check if sender is frozen
            require(!frozenAccount[_to]);                       // Check if recipient is frozen
            balanceOf[_from] = balanceOf[_from].sub(_value);    // Subtract from the sender
            balanceOf[_to] = balanceOf[_to].add(_value);        // Add the same to the recipient
            emit Transfer(_from, _to, _value);
        }
        
        /// @notice Create `mintedAmount` tokens and send it to `target`
        /// @param target Address to receive the tokens
        /// @param mintedAmount the amount of tokens it will receive
        function mintToken(address target, uint256 mintedAmount) onlyOwner public {
            balanceOf[target] = balanceOf[target].add(mintedAmount);
            totalSupply = totalSupply.add(mintedAmount);
            emit Transfer(0, this, mintedAmount);
            emit Transfer(this, target, mintedAmount);
        }

        /// @notice `freeze? Prevent | Allow` `target` from sending & receiving tokens
        /// @param target Address to be frozen
        /// @param freeze either to freeze it or not
        function freezeAccount(address target, bool freeze) onlyOwner public {
                frozenAccount[target] = freeze;
            emit  FrozenFunds(target, freeze);
        }

        
        //public variables for the Crowdsale
        uint256 public exchangeRate = 9672;            // 1 ETH = 9672 Tokens 
        uint256 public tokensSold = 0;                  // how many tokens sold through crowdsale
        
        //@dev fallback function, only accepts ether if pre-sale or ICO is running or Reject
        function () payable external {
            require(!safeguard);
            require(!frozenAccount[msg.sender]);
            if(whitelistingStatus == true) { require(whitelisted[msg.sender]); }
            // calculate token amount to be sent
            uint256 finalTokens = msg.value.mul(exchangeRate).div(1e10);        //weiamount * exchangeRate
            tokensSold = tokensSold.add(finalTokens);
            _transfer(this, msg.sender, finalTokens);                           //makes the transfers
            forwardEherToOwner();                                               //send Ether to owner
        }

        //Automatocally forwards ether from smart contract to owner address
        function forwardEherToOwner() internal {
            address(owner).transfer(msg.value); 
        }
        
        //Function to set ICO Exchange rate. 
        //1 ETH = How many Tokens ?
        function setICOExchangeRate(uint256 newExchangeRate) onlyOwner public {
            exchangeRate=newExchangeRate;
        }
        
        //Just in case, owner wants to transfer Tokens from contract to owner address
        function manualWithdrawToken(uint256 _amount) onlyOwner public {
            uint256 tokenAmount = _amount.mul(1e8);
            _transfer(this, msg.sender, tokenAmount);
        }
          
        //Just in case, owner wants to transfer Ether from contract to owner address
        function manualWithdrawEther()onlyOwner public{
            uint256 amount=address(this).balance;
            address(owner).transfer(amount);
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