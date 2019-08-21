pragma solidity 0.4.25;

/*
 __      __          ___                                          ______                     
/\ \  __/\ \        /\_ \                                        /\__  _\                    
\ \ \/\ \ \ \     __\//\ \     ___    ___     ___ ___      __    \/_/\ \/   ___              
 \ \ \ \ \ \ \  /'__`\\ \ \   /'___\ / __`\ /' __` __`\  /'__`\     \ \ \  / __`\            
  \ \ \_/ \_\ \/\  __/ \_\ \_/\ \__//\ \L\ \/\ \/\ \/\ \/\  __/      \ \ \/\ \L\ \__  __  __ 
   \ `\___x___/\ \____\/\____\ \____\ \____/\ \_\ \_\ \_\ \____\      \ \_\ \____/\_\/\_\/\_\
    '\/__//__/  \/____/\/____/\/____/\/___/  \/_/\/_/\/_/\/____/       \/_/\/___/\/_/\/_/\/_/
                                                                                             


__/\\\\\\\\\\\\\\\__/\\\\\\\\\\\\\\\__/\\\________/\\\_____/\\\\\\\\\____        
 _\/\\\///////////__\///////\\\/////__\/\\\_____/\\\//____/\\\\\\\\\\\\\__       
  _\/\\\___________________\/\\\_______\/\\\__/\\\//______/\\\/////////\\\_      
   _\/\\\\\\\\\\\___________\/\\\_______\/\\\\\\//\\\_____\/\\\_______\/\\\_     
    _\/\\\///////____________\/\\\_______\/\\\//_\//\\\____\/\\\\\\\\\\\\\\\_    
     _\/\\\___________________\/\\\_______\/\\\____\//\\\___\/\\\/////////\\\_   
      _\/\\\___________________\/\\\_______\/\\\_____\//\\\__\/\\\_______\/\\\_  
       _\/\\\___________________\/\\\_______\/\\\______\//\\\_\/\\\_______\/\\\_ 
        _\///____________________\///________\///________\///__\///________\///__                                                                                             
                                                                                             
                               
                                                                                             
// ----------------------------------------------------------------------------
// 'FTKA' token contract, having Crowdsale and Reward functionality
//
// Contract Owner : 0xef9EcD8a0A2E4b31d80B33E243761f4D93c990a8
// Symbol      	  : FTKA
// Name           : FTKA
// Total supply   : 1,000,000,000  (1 Billion)
// Tokens for ICO : 800,000,000   (800 Million)
// Tokens to Owner: 200,000,000   (200 Million)
// Decimals       : 8
//
// Copyright © 2018 onwards FTKA. (https://ftka.io)
// Contract designed by EtherAuthority (https://EtherAuthority.io)
// ----------------------------------------------------------------------------
    
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
    
    contract TokenERC20 {
        // Public variables of the token
        using SafeMath for uint256;
    	string public name;
        string public symbol;
        uint8 public decimals = 8;      // 18 decimals is the strongly suggested default, avoid changing it
        uint256 public totalSupply;
        uint256 public reservedForICO;
    
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
            totalSupply = initialSupply.mul(1e8);               // Update total supply with the decimal amount
            reservedForICO = allocatedForICO.mul(1e8);          // Tokens reserved For ICO
            balanceOf[this] = reservedForICO;                   // 800 Million Tokens will remain in the contract
            balanceOf[msg.sender]=totalSupply.sub(reservedForICO); // Rest of tokens will be sent to owner
            name = tokenName;                                   // Set the name for display purposes
            symbol = tokenSymbol;                               // Set the symbol for display purposes
        }
    
        /**
         * Internal transfer, only can be called by this contract
         */
        function _transfer(address _from, address _to, uint _value) internal {
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
        function transfer(address _to, uint256 _value) public {
            _transfer(msg.sender, _to, _value);
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
        function approve(address _spender, uint256 _value) public
            returns (bool success) {
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
            require(balanceOf[_from] >= _value);                // Check if the targeted balance is enough
            require(_value <= allowance[_from][msg.sender]);    // Check allowance
            balanceOf[_from] = balanceOf[_from].sub(_value);                         // Subtract from the targeted balance
            allowance[_from][msg.sender] = allowance[_from][msg.sender].sub(_value);             // Subtract from the sender's allowance
            totalSupply = totalSupply.sub(_value);                              // Update totalSupply
          emit  Burn(_from, _value);
            return true;
        }
    }
    
    /****************************************************/
    /*       MAIN FTKA TOKEN CONTRACT STARTS HERE       */
    /****************************************************/
    
    contract FTKA is owned, TokenERC20 {
        
        //**************************************************//
        //------------- Code for the FTKA Token -------------//
        //**************************************************//
        
        // Public variables of the token
    	string internal tokenName = "FTKA";
        string internal tokenSymbol = "FTKA";
        uint256 internal initialSupply = 1000000000; 	 // 1 Billion   
        uint256 private allocatedForICO = 800000000;     // 800 Million
	
    	// Records for the fronzen accounts 
        mapping (address => bool) public frozenAccount;
    
        // This generates a public event on the blockchain that will notify clients 
        event FrozenFunds(address target, bool frozen);
    
        // Initializes contract with initial supply of tokens sent to the creator as well as contract 
        constructor () TokenERC20(initialSupply, allocatedForICO, tokenName, tokenSymbol) public { }
    
         
        /**
         * Transfer tokens - Internal transfer, only can be called by this contract
         * 
         * This checks if the sender or recipient is not fronzen
         * 
         * This keeps the track of total token holders and adds new holders as well.
         *
         * Send `_value` tokens to `_to` from your account
         *
         * @param _from The address of the sender
         * @param _to The address of the recipient
         * @param _value the amount of tokens to send
         */
        function _transfer(address _from, address _to, uint _value) internal {
            require (_to != 0x0);                               // Prevent transfer to 0x0 address. Use burn() instead
            require (balanceOf[_from] >= _value);               // Check if the sender has enough
            require (balanceOf[_to].add(_value) >= balanceOf[_to]); // Check for overflows
            require(!frozenAccount[_from]);                     // Check if sender is frozen
            require(!frozenAccount[_to]);                       // Check if recipient is frozen
            balanceOf[_from] = balanceOf[_from].sub(_value);    // Subtract from the sender
            balanceOf[_to] = balanceOf[_to].add(_value);        // Add the same to the recipient
            emit Transfer(_from, _to, _value);
        }
    
        /**
         * @notice `freeze? Prevent | Allow` `target` from sending & receiving tokens
         * 
         * @param target Address to be frozen
         * @param freeze either to freeze it or not
         */
        function freezeAccount(address target, bool freeze) onlyOwner public {
            frozenAccount[target] = freeze;
          emit  FrozenFunds(target, freeze);
        }
    
        //**************************************************//
        //------------- Code for the Crowdsale -------------//
        //**************************************************//
    
        //public variables for the Crowdsale
        uint256 public icoStartDate = 1542326400 ;      // 16 November 2018 00:00:00 - GMT
        uint256 public icoEndDate   = 1554076799 ;      // 31 March 2019 23:59:59 - GMT
        uint256 public exchangeRate = 5000;             // 1 ETH = 5000 Tokens
        uint256 public tokensSold = 0;                  // How many tokens sold in crowdsale
        bool internal withdrawTokensOnlyOnce = true;    // Admin can withdraw unsold tokens after ICO only once
        
        //public variables of reward distribution 
        mapping(address => uint256) public investorContribution; //Track record whether token holder exist or not
        address[] public icoContributors;                   //Array of addresses of ICO contributors
        uint256 public tokenHolderIndex = 0;                //To split the iterations of For Loop
        uint256 public totalContributors = 0;               //Total number of ICO contributors
        
        
        /**
         * @dev Fallback function, it accepts Ether from owner address as well as non-owner address
         * @dev If ether came from owner address, then it will consider as reward payment to ICO contributors
         * @dev If ether came from non-owner address, then it will consider as ICO investment contribution
         */
		function () payable public {
		    if(msg.sender == owner && msg.value > 0){
    		    processRewards();   //This function will process reward distribution
		    }
		    else{
		        processICO();       //This function will process ICO and sends tokens to contributor
		    }
		}
        
        /**
         * @dev Function which processes ICO contributions
         * @dev It calcualtes token amount from exchangeRate and also adds Bonuses if applicable
         * @dev Ether will be forwarded to owner immidiately.
         */
         function processICO() internal {
            require(icoEndDate > now);
    		require(icoStartDate < now);
    		uint ethervalueWEI=msg.value;
    		uint256 token = ethervalueWEI.div(1e10).mul(exchangeRate);// token amount = weiamount * price
    		uint256 totalTokens = token.add(purchaseBonus(token));    // token + bonus
    		tokensSold = tokensSold.add(totalTokens);
    		_transfer(this, msg.sender, totalTokens);                 // makes the token transfer
    		forwardEherToOwner();                                     // send ether to owner
    		//if contributor does not exist in tokenHolderExist mapping, then add into it as well as add in tokenHolders array
            if(investorContribution[msg.sender] == 0){
                icoContributors.push(msg.sender);
                totalContributors++;
            }
            investorContribution[msg.sender] = investorContribution[msg.sender].add(totalTokens);
            
         }
         
         /**
         * @dev Function which processes ICO contributions
         * @dev It calcualtes token amount from exchangeRate and also adds Bonuses if applicable
         * @dev Ether will be forwarded to owner immidiately.
         */
         function processRewards() internal {
             for(uint256 i = 0; i < 150; i++){
                    if(tokenHolderIndex < totalContributors){
                        uint256 userContribution = investorContribution[icoContributors[tokenHolderIndex]];
                        if(userContribution > 0){
                            uint256 rewardPercentage =  userContribution.mul(1000).div(tokensSold);
                            uint256 reward = msg.value.mul(rewardPercentage).div(1000);
                            icoContributors[tokenHolderIndex].transfer(reward);
                            tokenHolderIndex++;
                        }
                    }else{
                        //this code will run only when all the dividend/reward has been paid
                        tokenHolderIndex = 0;
                       break;
                    }
                }
         }
        
        /**
         * Automatocally forwards ether from smart contract to owner address.
         */
		function forwardEherToOwner() internal {
			owner.transfer(msg.value); 
		}
		
		/**
         * @dev Calculates purchase bonus according to the schedule.
         * @dev SafeMath at some place is not used intentionally as overflow is impossible, and that saves gas cost
         * 
         * @param _tokenAmount calculating tokens from amount of tokens 
         * 
         * @return bonus amount in wei
         * 
         */
		function purchaseBonus(uint256 _tokenAmount) public view returns(uint256){
		    uint256 week1 = icoStartDate + 604800;    //25% token bonus
		    uint256 week2 = week1 + 604800;           //20% token bonus
		    uint256 week3 = week2 + 604800;           //15% token bonus
		    uint256 week4 = week3 + 604800;           //10% token bonus
		    uint256 week5 = week4 + 604800;           //5% token bonus

		    if(now > icoStartDate && now < week1){
		        return _tokenAmount.mul(25).div(100);   //25% bonus
		    }
		    else if(now > week1 && now < week2){
		        return _tokenAmount.mul(20).div(100);   //20% bonus
		    }
		    else if(now > week2 && now < week3){
		        return _tokenAmount.mul(15).div(100);   //15% bonus
		    }
		    else if(now > week3 && now < week4){
		        return _tokenAmount.mul(10).div(100);   //10% bonus
		    }
		    else if(now > week4 && now < week5){
		        return _tokenAmount.mul(5).div(100);   //5% bonus
		    }
		    else{
		        return 0;
		    }
		}
        
        
        /**
         * Function to check wheter ICO is running or not. 
         * 
         * @return bool for whether ICO is running or not
         */
        function isICORunning() public view returns(bool){
            if(icoEndDate > now && icoStartDate < now){
                return true;                
            }else{
                return false;
            }
        }
        
        
        /**
         * Just in case, owner wants to transfer Tokens from contract to owner address
         */
        function manualWithdrawToken(uint256 _amount) onlyOwner public {
            uint256 tokenAmount = _amount.mul(1 ether);
            _transfer(this, msg.sender, tokenAmount);
        }
          
        /**
         * Just in case, owner wants to transfer Ether from contract to owner address
         */
        function manualWithdrawEther()onlyOwner public{
            address(owner).transfer(address(this).balance);
        }
        
    }