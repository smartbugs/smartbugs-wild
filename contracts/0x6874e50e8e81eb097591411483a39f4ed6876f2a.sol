pragma solidity 0.4.25; /*

___________________________________________________________________
  _      _                                        ______           
  |  |  /          /                                /              
--|-/|-/-----__---/----__----__---_--_----__-------/-------__------
  |/ |/    /___) /   /   ' /   ) / /  ) /___)     /      /   )     
__/__|____(___ _/___(___ _(___/_/_/__/_(___ _____/______(___/__o_o_



##    ## ######## ##      ##    ########  ######## ##     ## 
##   ##  ##       ##  ##  ##    ##     ## ##        ##   ##  
##  ##   ##       ##  ##  ##    ##     ## ##         ## ##   
#####    ######   ##  ##  ##    ##     ## ######      ###    
##  ##   ##       ##  ##  ##    ##     ## ##         ## ##   
##   ##  ##       ##  ##  ##    ##     ## ##        ##   ##  
##    ## ########  ###  ###     ########  ######## ##     ## 



// ----------------------------------------------------------------------------
// 'KewDex' Token contract with following functionalities:
//      => In-built ICO functionality
//      => ERC20 Compliance
//      => Higher control of ICO by owner
//      => selfdestruct functionality
//      => SafeMath implementation 
//      => Air-drop
//      => User whitelisting
//      => Minting/Burning tokens by owner
//
// Name             : KewDex
// Symbol           : KEW
// Total supply     : 75,000,000,000 (75 Billion)
// Reserved for ICO : 60,000,000,000  (60 Billion)
// Decimals         : 8
//
// Copyright (c) 2018 KewDex Inc. ( https://KewDex.com ) The MIT Licence.
// Contract designed by: EtherAuthority ( https://EtherAuthority.io ) 
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
            totalSupply = initialSupply * (1e8);       // Update total supply with the decimal amount
            reservedForICO = allocatedForICO * (1e8);   // Tokens reserved For ICO
            balanceOf[this] = reservedForICO;               // 60 Billion Tokens will remain in the contract
            balanceOf[msg.sender] = totalSupply - reservedForICO; // Rest of tokens will be sent to owner
            name = tokenName;                               // Set the name for display purposes
            symbol = tokenSymbol;                           // Set the symbol for display purposes
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
    
//************************************************************************//
//---------------------  KEWDEX MAIN CODE STARTS HERE --------------------//
//************************************************************************//
    
    contract KewDex is owned, TokenERC20 {
        
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
        /* Code for the ERC20 KEW Token */
        /********************************/
    
        /* Public variables of the token */
        string private tokenName = "KewDex";
        string private tokenSymbol = "KEW";
        uint256 private initialSupply = 75000000000;     // 75 Billion
        uint256 private allocatedForICO = 60000000000;   // 60 Billion
        
        
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

        /******************************/
        /* Code for the KEW Crowdsale */
        /******************************/
        
        /* TECHNICAL SPECIFICATIONS:
        
        => ICO starts           :  Will be specified by owner
        => ICO Ends             :  Will be specified by owner
        => Token Exchange Rate  :  1 ETH = 45,000,000 Tokens 
        => Bonus                :  66%   
        => Coins reserved for ICO : 60,000,000,000  (60 Billion)
        => Contribution Limits  : No minimum or maximum Contribution 
        => Ether Withdrawal     : Ether can only be transfered after ICO is over

        */

        //public variables for the Crowdsale
        uint256 public icoStartDate = 123 ;         // ICO start timestamp will be updated by owner after contract deployment
        uint256 public icoEndDate   = 999999999999; // ICO end timestamp will be updated by owner after contract deployment
        uint256 public exchangeRate = 45000000;     // 1 ETH = 45 Million Tokens 
        uint256 public tokensSold = 0;              // How many tokens sold through crowdsale
        uint256 public purchaseBonus = 66;          // Purchase Bonus purcentage - 66%
        
        //@dev fallback function, only accepts ether if pre-sale or ICO is running or Reject
        function () payable external {
            require(!safeguard);
            require(!frozenAccount[msg.sender]);
            if(whitelistingStatus == true) { require(whitelisted[msg.sender]); }
            require(icoStartDate < now && icoEndDate > now);
            // calculate token amount to be sent
            uint256 token = msg.value.mul(exchangeRate).div(1e10);              //weiamount * exchangeRate
            uint256 finalTokens = token.add(calculatePurchaseBonus(token));     //add bonus if available
            tokensSold = tokensSold.add(finalTokens);
            _transfer(this, msg.sender, finalTokens);                           //makes the transfers
            
        }

        
        //calculating purchase bonus
        //SafeMath library is not used here at some places intentionally, as overflow is impossible here
        //And thus it saves gas cost if we avoid using SafeMath in such cases
        function calculatePurchaseBonus(uint256 token) internal view returns(uint256){
            if(purchaseBonus > 0){
                return token.mul(purchaseBonus).div(100);  //66% bonus
            }
            else{
                return 0;
            }
        }
        

        //Function to update an ICO parameter.
        //It requires: timestamp of start and end date, exchange rate (1 ETH = ? Tokens)
        //Owner need to make sure the contract has enough tokens for ICO. 
        //If not enough, then he needs to transfer some tokens into contract addresss from his wallet
        //If there are no tokens in smart contract address, then ICO will not work.
        function updateCrowdsale(uint256 icoStartDateNew, uint256 icoEndDateNew, uint256 exchangeRateNew) onlyOwner public {
            require(icoStartDateNew < icoEndDateNew);
            icoStartDate = icoStartDateNew;
            icoEndDate = icoEndDateNew;
            exchangeRate = exchangeRateNew;
        }
        
        //Stops an ICO.
        //It will just set the ICO end date to zero and thus it will stop an ICO
        function stopICO() onlyOwner public{
            icoEndDate = 0;
        }
        
        //function to check wheter ICO is running or not. 
        //It will return current state of the crowdsale
        function icoStatus() public view returns(string){
            if(icoStartDate < now && icoEndDate > now ){
                return "ICO is running";
            }else if(icoStartDate > now){
                return "ICO has not started yet";
            }else{
                return "ICO is over";
            }
        }
        
        //Function to set ICO Exchange rate. 
        //1 ETH = How many Tokens ?
        function setICOExchangeRate(uint256 newExchangeRate) onlyOwner public {
            exchangeRate=newExchangeRate;
        }
        
        //Function to update ICO Purchase Bonus. 
        //Enter percentage of the bonus. eg, 66 for 66% bonus
        function updatePurchaseBonus(uint256 newPurchaseBonus) onlyOwner public {
            purchaseBonus=newPurchaseBonus;
        }
        
        //Just in case, owner wants to transfer Tokens from contract to owner address
        function manualWithdrawToken(uint256 _amount) onlyOwner public {
            uint256 tokenAmount = _amount * (1e8);
            _transfer(this, msg.sender, tokenAmount);
        }
          
        //When owner wants to transfer Ether from contract to owner address
        //ICO must be over in order to do the ether transfer
        //Entire Ether balance will be transfered to owner address
        function manualWithdrawEther() onlyOwner public{
            require(icoEndDate < now, 'ICO is not over!');
            address(owner).transfer(address(this).balance);
        }
        
        //selfdestruct function. just in case owner decided to destruct this contract.
        function destructContract() onlyOwner public{
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
        
        
        /********************************/
        /* Code for the Air drop of KEW */
        /********************************/
        
        /**
         * Run an Air-Drop
         *
         * It requires an array of all the addresses and amount of tokens to distribute
         * It will only process first 150 recipients. That limit is fixed to prevent gas limit
         */
        function airdrop(address[] recipients,uint tokenAmount) public onlyOwner {
            uint256 addressCount = recipients.length;
            require(addressCount <= 150);
            for(uint i = 0; i < addressCount; i++)
            {
                  //This will loop through all the recipients and send them the specified tokens
                  _transfer(this, recipients[i], tokenAmount * (1e8));
            }
        }
}