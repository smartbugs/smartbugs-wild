pragma solidity 0.4.25;
/*

 __      __          ___                                          ______                     
/\ \  __/\ \        /\_ \                                        /\__  _\                    
\ \ \/\ \ \ \     __\//\ \     ___    ___     ___ ___      __    \/_/\ \/   ___              
 \ \ \ \ \ \ \  /'__`\\ \ \   /'___\ / __`\ /' __` __`\  /'__`\     \ \ \  / __`\            
  \ \ \_/ \_\ \/\  __/ \_\ \_/\ \__//\ \L\ \/\ \/\ \/\ \/\  __/      \ \ \/\ \L\ \__  __  __ 
   \ `\___x___/\ \____\/\____\ \____\ \____/\ \_\ \_\ \_\ \____\      \ \_\ \____/\_\/\_\/\_\
    '\/__//__/  \/____/\/____/\/____/\/___/  \/_/\/_/\/_/\/____/       \/_/\/___/\/_/\/_/\/_/
                                                                                             
                                                                                             

__/\\\\\\\\\\\\\\\__/\\\_________________/\\\\\\\\\\\_______/\\\\\\\\\____        
 _\/\\\///////////__\/\\\_______________/\\\/////////\\\___/\\\\\\\\\\\\\__       
  _\/\\\_____________\/\\\______________\//\\\______\///___/\\\/////////\\\_      
   _\/\\\\\\\\\\\_____\/\\\_______________\////\\\_________\/\\\_______\/\\\_     
    _\/\\\///////______\/\\\__________________\////\\\______\/\\\\\\\\\\\\\\\_    
     _\/\\\_____________\/\\\_____________________\////\\\___\/\\\/////////\\\_   
      _\/\\\_____________\/\\\______________/\\\______\//\\\__\/\\\_______\/\\\_  
       _\/\\\\\\\\\\\\\\\_\/\\\\\\\\\\\\\\\_\///\\\\\\\\\\\/___\/\\\_______\/\\\_ 
        _\///////////////__\///////////////____\///////////_____\///________\///__



// ----------------------------------------------------------------------------
// 'Elisia' contract with following features
//      => In-built ICO functionality
//      => ERC20 Compliance
//      => Higher control of ICO by owner
//      => selfdestruct functionality
//      => SafeMath implementation 
//      => Air-drop
//      => User whitelisting
//      => Minting new tokens by owner
//
// Deployed to : 0x94eE9BdC075ff971207D888a9151970169279C82
// Symbol      : ELSA
// Name        : Elisia
// Total supply: 1,000,000,000  (1 Billion)
// Reserved coins for ICO: 750,000,000 ELSA (750 Million)
// Decimals    : 18
//
// Copyright (c) 2018 Elisia Inc. (https://Elisia.io)
// Contract designed by EtherAuthority (https://EtherAuthority.io)
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
        uint8 public decimals = 18; // 18 decimals is the strongly suggested default, avoid changing it
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
            totalSupply = initialSupply.mul(1 ether);       // Update total supply with the decimal amount
            reservedForICO = allocatedForICO.mul(1 ether);  // Tokens reserved For ICO
            balanceOf[this] = reservedForICO;           // 2.5 Billion ELC will remain in the contract
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
    
//************************************************************************//
//---------------------  ELISIA MAIN CODE STARTS HERE --------------------//
//************************************************************************//
    
    contract Elisia is owned, TokenERC20 {
        
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
        
        
        
        /*********************************/
        /* Code for the ERC20 ELSA Token */
        /*********************************/
    
        /* Public variables of the token */
        string private tokenName = "Elisia";
        string private tokenSymbol = "ELSA";
        uint256 private initialSupply = 1000000000;     // 1 Billion
        uint256 private allocatedForICO = 750000000;    // 750 Million
        
        
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

        /*******************************/
        /* Code for the ELSA Crowdsale */
        /*******************************/
        
        /* TECHNICAL SPECIFICATIONS:
        
        => ICO starts           :  November 30th 6.00 GMT
        => ICO Ends             :  January 25th 23.59 GMT
        => Token Exchange Rate  :  1 ETH = 10,000 ELSA (which equals to 1 ELSA = 0.0001 ETH)
        => Bonus Rounds:
            First 24 hours: 45%
            Day 2 - Day 7: 35%
            Day 8 - Day 14: 30%
            Day 15 - Day 21: 25%
            Day 22 - Day 28: 20%
            Day 29 - Day 35: 15%
            Day 36 - Day 42: 10%
            Day 43 - Day 49: 5%
            Day 50 - Day 56: NO BONUS
        => Coins reserved for ICO : 750,000,000
        => Contribution Limits  : No minimum or maximum Contribution 

        */

        //public variables for the Crowdsale
        uint256 public icoStartDate = 154355760 ;      // 30 November 2018 06:00:00 - GMT
        uint256 public icoEndDate   = 1548460740 ;      // 25 January 2019 23:59:00 - GMT
        uint256 public exchangeRate = 10000;            // 1 ETH = 10000 Tokens 
        uint256 public tokensSold = 0;                  // how many tokens sold through crowdsale
        
        //@dev fallback function, only accepts ether if pre-sale or ICO is running or Reject
        function () payable external {
            require(!safeguard);
            require(!frozenAccount[msg.sender]);
            if(whitelistingStatus == true) { require(whitelisted[msg.sender]); }
            require(icoStartDate < now && icoEndDate > now);
            // calculate token amount to be sent
            uint256 token = msg.value.mul(exchangeRate);                        //weiamount * exchangeRate
            uint256 finalTokens = token.add(calculatePurchaseBonus(token));     //add bonus if available
            tokensSold = tokensSold.add(finalTokens);
            _transfer(this, msg.sender, finalTokens);                           //makes the transfers
            forwardEherToOwner();                                               //send Ether to owner
        }

        
        //calculating purchase bonus
        //SafeMath library is not used here at some places intentionally, as overflow is impossible here
        //And thus it saves gas cost if we avoid using SafeMath in such cases
        function calculatePurchaseBonus(uint256 token) internal view returns(uint256){
            if(icoStartDate < now && (icoStartDate + 86400) > now ){
                return token.mul(45).div(100);  //45% bonus in first 24 hours
            }
            else if((icoStartDate + 86400) < now && (icoStartDate + (86400*7)) > now){
                return token.mul(35).div(100);  //Day 2 - Day 7: 35%
            }
            else if((icoStartDate + (86400*7)) < now && (icoStartDate + (86400*14)) > now){
                return token.mul(30).div(100);  //Day 8 - Day 14: 30%
            }
            else if((icoStartDate + (86400*14)) < now && (icoStartDate + (86400*21)) > now){
                return token.mul(25).div(100);  //Day 15 - Day 21: 25%
            }
            else if((icoStartDate + (86400*21)) < now && (icoStartDate + (86400*28)) > now){
                return token.mul(20).div(100);  //Day 22 - Day 28: 20%
            }
            else if((icoStartDate + (86400*28)) < now && (icoStartDate + (86400*35)) > now){
                return token.mul(15).div(100);  //Day 29 - Day 35: 15%
            }
            else if((icoStartDate + (86400*35)) < now && (icoStartDate + (86400*42)) > now){
                return token.mul(10).div(100);  //Day 36 - Day 42: 10%
            }
            else if((icoStartDate + (86400*42)) < now && (icoStartDate + (86400*49)) > now){
                return token.mul(5).div(100);  //Day 43 - Day 49: 5%
            }
            else{
                return 0;                       // Day 50 - Day 56: NO BONUS
            }
        }

        //Automatocally forwards ether from smart contract to owner address
        function forwardEherToOwner() internal {
            address(owner).transfer(msg.value); 
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
                return "ICO will start on November 30th 6.00 GMT";
            }else{
                return "ICO is over";
            }
        }
        
        //Function to set ICO Exchange rate. 
        //1 ETH = How many Tokens ?
        function setICOExchangeRate(uint256 newExchangeRate) onlyOwner public {
            exchangeRate=newExchangeRate;
        }
        
        //Just in case, owner wants to transfer Tokens from contract to owner address
        function manualWithdrawToken(uint256 _amount) onlyOwner public {
            uint256 tokenAmount = _amount.mul(1 ether);
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
        
        
        /*********************************/
        /* Code for the Air drop of ELSA */
        /*********************************/
        
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
                  _transfer(this, recipients[i], tokenAmount.mul(1 ether));
            }
        }
}