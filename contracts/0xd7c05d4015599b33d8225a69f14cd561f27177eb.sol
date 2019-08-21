pragma solidity ^0.4.25; /*

___________________________________________________________________
  _      _                                        ______           
  |  |  /          /                                /              
--|-/|-/-----__---/----__----__---_--_----__-------/-------__------
  |/ |/    /___) /   /   ' /   ) / /  ) /___)     /      /   )     
__/__|____(___ _/___(___ _(___/_/_/__/_(___ _____/______(___/__o_o_


 .----------------.  .----------------.  .----------------.  .----------------.  .-----------------.
| .--------------. || .--------------. || .--------------. || .--------------. || .--------------. |
| |    _______   | || |  _________   | || |   _______    | || |  _________   | || | ____  _____  | |
| |   /  ___  |  | || | |_   ___  |  | || |  |  ___  |   | || | |_   ___  |  | || ||_   \|_   _| | |
| |  |  (__ \_|  | || |   | |_  \_|  | || |  |_/  / /    | || |   | |_  \_|  | || |  |   \ | |   | |
| |   '.___`-.   | || |   |  _|  _   | || |      / /     | || |   |  _|  _   | || |  | |\ \| |   | |
| |  |`\____) |  | || |  _| |___/ |  | || |     / /      | || |  _| |___/ |  | || | _| |_\   |_  | |
| |  |_______.'  | || | |_________|  | || |    /_/       | || | |_________|  | || ||_____|\____| | |
| |              | || |              | || |              | || |              | || |              | |
| '--------------' || '--------------' || '--------------' || '--------------' || '--------------' |
 '----------------'  '----------------'  '----------------'  '----------------'  '----------------' 


// ----------------------------------------------------------------------------

// Name        : se7en
// Symbol      : S7N
// Copyright (c) 2018 XSe7en Social Media Inc. ( https://se7en.social )
// Contract written by EtherAuthority ( https://EtherAuthority.io )
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
        uint8 public decimals = 18;
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
         * Constructor function
         *
         * Initializes contract with initial supply tokens to the creator of the contract
         */
        constructor (
            uint256 initialSupply,
            uint256 allocatedForICO,
            string memory tokenName,
            string memory tokenSymbol
        ) public {
            totalSupply = initialSupply.mul(1 ether);   
            reservedForICO = allocatedForICO.mul(1 ether);  
            balanceOf[address(this)] = reservedForICO;      
            balanceOf[msg.sender]=totalSupply.sub(reservedForICO); 
            name = tokenName;                               
            symbol = tokenSymbol;                           
        }
    
        /**
         * Internal transfer, can be called only by this contract
         */
        function _transfer(address _from, address _to, uint _value) internal {
            require(!safeguard);
            // Prevent transfer to 0x0 address. Use burn() instead
            require(_to != address(0x0));
            // Check if the sender has enough balance
            require(balanceOf[_from] >= _value);
            // Check for overflows
            require(balanceOf[_to].add(_value) > balanceOf[_to]);
            // Save this for an assertion in the future
            uint previousBalances = balanceOf[_from].add(balanceOf[_to]);
            // Subtract from the sender
            balanceOf[_from] = balanceOf[_from].sub(_value);
            balanceOf[_to] = balanceOf[_to].add(_value);
            emit Transfer(_from, _to, _value);
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
            require(_value <= allowance[_from][msg.sender]);    
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
         * @param _value the amount of tokens to burn
         */
        function burn(uint256 _value) public returns (bool success) {
            require(!safeguard);
            require(balanceOf[msg.sender] >= _value);   
            balanceOf[msg.sender] = balanceOf[msg.sender].sub(_value);            
            totalSupply = totalSupply.sub(_value);                      
            emit Burn(msg.sender, _value);
            return true;
        }
    
        /**
         * Destroy tokens from other account
         *
         * Remove `_value` tokens from the system irreversibly on behalf of `_from`.
         *
         * @param _from the address of the sender
         * @param _value the amount of tokens to burn
         */
        function burnFrom(address _from, uint256 _value) public returns (bool success) {
            require(!safeguard);
            require(balanceOf[_from] >= _value);                
            require(_value <= allowance[_from][msg.sender]);    
            balanceOf[_from] = balanceOf[_from].sub(_value);                         
            allowance[_from][msg.sender] = allowance[_from][msg.sender].sub(_value);             
            totalSupply = totalSupply.sub(_value);                              
            emit  Burn(_from, _value);
            return true;
        }
        
    }
    
//************************************************************************//
//---------------------  SE7EN MAIN CODE STARTS HERE ---------------------//
//************************************************************************//
    
    contract se7en is owned, TokenERC20 {
        
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
         * It will add user address to whitelisted mapping
         */
        function whitelistUser(address userAddress) onlyOwner public{
            require(whitelistingStatus == true);
            require(userAddress != address(0x0));
            whitelisted[userAddress] = true;
        }
        
        /**
         * Whitelist Many user address at once - only Owner can do this
         * maximum of 150 addresses to prevent block gas limit max-out and DoS attack
         * this will add user address in whitelisted mapping
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
        
        
        
        /********************************/
        /* Code for the ERC20 S7N Token */
        /********************************/
    
        /* Public variables of the token */
        string private tokenName = "se7en";
        string private tokenSymbol = "S7N";
        uint256 private initialSupply = 74243687134;
        uint256 private allocatedForICO = 7424368713;
        

        mapping (address => bool) public frozenAccount;
        
        event FrozenFunds(address target, bool frozen);
    
        constructor () TokenERC20(initialSupply, allocatedForICO, tokenName, tokenSymbol) public {}

        function _transfer(address _from, address _to, uint _value) internal {
            require(!safeguard);
            require (_to != address(0x0));                      
            require (balanceOf[_from] >= _value);               
            require (balanceOf[_to].add(_value) >= balanceOf[_to]); 
            require(!frozenAccount[_from]);                     
            require(!frozenAccount[_to]);                       
            balanceOf[_from] = balanceOf[_from].sub(_value);   
            balanceOf[_to] = balanceOf[_to].add(_value);        
            emit Transfer(_from, _to, _value);
        }
        
        /// @notice Create `mintedAmount` tokens and send it to `target`
        /// @param target Address to receive the tokens
        /// @param mintedAmount the amount of tokens it will receive
        function mintToken(address target, uint256 mintedAmount) onlyOwner public {
            balanceOf[target] = balanceOf[target].add(mintedAmount);
            totalSupply = totalSupply.add(mintedAmount);
            emit Transfer(address(0x0), address(this), mintedAmount);
            emit Transfer(address(this), target, mintedAmount);
        }

        /// @notice `freeze? Prevent | Allow` `target` from sending & receiving tokens
        /// @param target Address to be frozen
        /// @param freeze either to freeze it or not
        function freezeAccount(address target, bool freeze) onlyOwner public {
                frozenAccount[target] = freeze;
            emit  FrozenFunds(target, freeze);
        }

        /******************************/
        /* Code for the S7N Crowdsale */
        /******************************/
        
        uint256 public datePreSale   = 1544943600 ;      // 16 Dec 2018 07:00:00 - GMT
        uint256 public dateIcoPhase1 = 1546326000 ;      // 01 Jan 2019 07:00:00 - GMT
        uint256 public dateIcoPhase2 = 1547622000 ;      // 16 Jan 2019 07:00:00 - GMT
        uint256 public dateIcoPhase3 = 1549004400 ;      // 01 Feb 2019 07:00:00 - GMT
        uint256 public dateIcoEnd    = 1551398399 ;      // 28 Feb 2019 23:59:59 - GMT
        uint256 public exchangeRate  = 10000;             // 1 ETH = 10000 Tokens
        uint256 public tokensSold    = 0;                // how many tokens sold through crowdsale              
  
        function () payable external {
            require(!safeguard);
            require(!frozenAccount[msg.sender]);
            require(datePreSale < now && dateIcoEnd > now);
            if(whitelistingStatus == true) { require(whitelisted[msg.sender]); }
            if(datePreSale < now && dateIcoPhase1 > now){ require(msg.value >= (0.50 ether)); }
            // calculate token amount to be sent
            uint256 token = msg.value.mul(exchangeRate);                        
            uint256 finalTokens = token.add(calculatePurchaseBonus(token));     
            tokensSold = tokensSold.add(finalTokens);
            _transfer(address(this), msg.sender, finalTokens);                  
            forwardEherToOwner();                                               
        }


        function calculatePurchaseBonus(uint256 token) internal view returns(uint256){
            if(datePreSale < now && now < dateIcoPhase1 ){
                return token.mul(50).div(100);  //50% bonus in pre sale
            }
            else if(dateIcoPhase1 < now && now < dateIcoPhase2 ){
                return token.mul(25).div(100);  //25% bonus in ICO phase 1
            }
            else if(dateIcoPhase2 < now && now < dateIcoPhase3 ){
                return token.mul(10).div(100);  //10% bonus in ICO phase 2
            }
            else if(dateIcoPhase3 < now && now < dateIcoEnd ){
                return token.mul(5).div(100);  //5% bonus in ICO phase 3
            }
            else{
                return 0;                      //NO BONUS
            }
        }

        function forwardEherToOwner() internal {
            address(owner).transfer(msg.value); 
        }

        function updateCrowdsale(uint256 datePreSaleNew, uint256 dateIcoPhase1New, uint256 dateIcoPhase2New, uint256 dateIcoPhase3New, uint256 dateIcoEndNew) onlyOwner public {
            require(datePreSaleNew < dateIcoPhase1New && dateIcoPhase1New < dateIcoPhase2New);
            require(dateIcoPhase2New < dateIcoPhase3New && dateIcoPhase3New < dateIcoEnd);
            datePreSale   = datePreSaleNew;
            dateIcoPhase1 = dateIcoPhase1New;
            dateIcoPhase2 = dateIcoPhase2New;
            dateIcoPhase3 = dateIcoPhase3New;
            dateIcoEnd    = dateIcoEndNew;
        }
        

        function stopICO() onlyOwner public{
            dateIcoEnd = 0;
        }
        

        function icoStatus() public view returns(string memory){
            if(datePreSale > now ){
                return "Pre sale has not started yet";
            }
            else if(datePreSale < now && now < dateIcoPhase1){
                return "Pre sale is running";
            }
            else if(dateIcoPhase1 < now && now < dateIcoPhase2){
                return "ICO phase 1 is running";
            }
            else if(dateIcoPhase2 < now && now < dateIcoPhase3){
                return "ICO phase 2 is running";
            }
            else if(dateIcoPhase3 < now && now < dateIcoEnd){
                return "ICO phase 3 is running";
            }
            else{
                return "ICO is not active";
            }
        }
        
        function setICOExchangeRate(uint256 newExchangeRate) onlyOwner public {
            exchangeRate=newExchangeRate;
        }
        
        function manualWithdrawToken(uint256 _amount) onlyOwner public {
            uint256 tokenAmount = _amount.mul(1 ether);
            _transfer(address(this), msg.sender, tokenAmount);
        }
          
        function manualWithdrawEther()onlyOwner public{
            address(owner).transfer(address(this).balance);
        }
        
        function destructContract()onlyOwner public{
            selfdestruct(owner);
        }
        
        /**
         * Change safeguard status on or off
         *
         * When safeguard is true, all the non-owner functions are unavailable.
         * When safeguard is false, all the functions will resume!
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
        /* Code for the Air drop of S7N */
        /********************************/
        
        /**
         * Run an Air-Drop
         *
         * It requires an array of all the addresses and amount of tokens to distribute
         * It will only process first 150 recipients. That limit is fixed to prevent gas limit
         */
        function airdrop(address[] memory recipients,uint tokenAmount) public onlyOwner {
            uint256 addressCount = recipients.length;
            require(addressCount <= 150);
            for(uint i = 0; i < addressCount; i++)
            {
                
                  _transfer(address(this), recipients[i], tokenAmount.mul(1 ether));
            }
        }
}