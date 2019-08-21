pragma solidity ^0.4.18;

contract owned {
    address public owner;

    function owned() public {
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

interface tokenRecipient { function receiveApproval(address _from, uint256 _value, address _token, bytes _extraData) public; }

contract TokenERC20 {
    // Public variables of the token
    string public name;
    string public symbol;
    
    //Disable Decimal usage
    //uint8 public decimals = 0;

    // 18 decimals is the strongly suggested default, avoid changing it
    uint256 public totalSupply;

    // This creates an array with all balances
    mapping (address => uint256) public balanceOf;
    mapping (address => mapping (address => uint256)) private allowance;

    // This generates a public event on the blockchain that will notify clients
    event Transfer(address indexed from, address indexed to, uint256 value);

    // This notifies clients about the amount burnt
    event Burn(address indexed from, uint256 value);

    /**
     * Constrctor function
     *
     * Initializes contract with initial supply tokens to the creator of the contract
     */
    function TokenERC20(
        uint256 initialSupply,
        string tokenName,
        string tokenSymbol
    ) public {
        //totalSupply = initialSupply * 10 ** uint256(decimals);  // Update total supply with the decimal amount
        totalSupply = initialSupply;
        //balanceOf[msg.sender] = totalSupply;                // Give the creator all initial tokens
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
        require(balanceOf[_to] + _value > balanceOf[_to]);
        // Save this for an assertion in the future
        uint previousBalances = balanceOf[_from] + balanceOf[_to];
        // Subtract from the sender
        balanceOf[_from] -= _value;
        // Add the same to the recipient
        balanceOf[_to] += _value;
        Transfer(_from, _to, _value);
        // Asserts are used to use static analysis to find bugs in your code. They should never fail
        assert(balanceOf[_from] + balanceOf[_to] == previousBalances);
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
        allowance[_from][msg.sender] -= _value;
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
    function approve(address _spender, uint256 _value) internal
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
        internal
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
        balanceOf[msg.sender] -= _value;            // Subtract from the sender
        totalSupply -= _value;                      // Updates totalSupply
        Burn(msg.sender, _value);
        return true;
    }

}

/******************************************/
/*       ADVANCED TOKEN STARTS HERE       */
/******************************************/

contract MyAdvancedToken is owned, TokenERC20 {

    uint256 public sellPrice;
    uint256 public buyPrice;

    mapping (address => bool) public frozenAccount;

    /* This generates a public event on the blockchain that will notify clients */
    event FrozenFunds(address target, bool frozen);

    /* Initializes contract with initial supply tokens to the creator of the contract */
    function MyAdvancedToken(
        uint256 initialSupply,
        string tokenName,
        string tokenSymbol
    ) TokenERC20(initialSupply, tokenName, tokenSymbol) public {}

    /* Internal transfer, only can be called by this contract */
    function _transfer(address _from, address _to, uint _value) internal {
        require (_to != 0x0);                               // Prevent transfer to 0x0 address. Use burn() instead
        require (balanceOf[_from] >= _value);                // Check if the sender has enough
        require (balanceOf[_to] + _value > balanceOf[_to]); // Check for overflows
        require(!frozenAccount[_from]);                     // Check if sender is frozen
        require(!frozenAccount[_to]);                       // Check if recipient is frozen
        balanceOf[_from] -= _value;                         // Subtract from the sender
        balanceOf[_to] += _value;                           // Add the same to the recipient
        Transfer(_from, _to, _value);
    }

    /// @notice Create `mintedAmount` tokens and send it to `target`
    /// @param target Address to receive the tokens
    /// @param mintedAmount the amount of tokens it will receive
    function mintToken(address target, uint256 mintedAmount) internal  {
        //Convert to eth value
        //mintedAmount = mintedAmount  * 10 ** uint256(decimals);
        balanceOf[target] += mintedAmount;
        totalSupply += mintedAmount;
        //Transfer(0, this, mintedAmount);
        Transfer(this, target, mintedAmount);
    }

    /// @notice `freeze? Prevent | Allow` `target` from sending & receiving tokens
    /// @param target Address to be frozen
    /// @param freeze either to freeze it or not
    function freezeAccount(address target, bool freeze) onlyOwner public {
        frozenAccount[target] = freeze;
        FrozenFunds(target, freeze);
    }

    /// @notice Allow users to buy tokens for `newBuyPrice` eth and sell tokens for `newSellPrice` eth
    /// @param newSellPrice Price the users can sell to the contract
    /// @param newBuyPrice Price users can buy from the contract
    function setPrices(uint256 newSellPrice, uint256 newBuyPrice) onlyOwner public {
        sellPrice = newSellPrice;
        buyPrice = newBuyPrice;
    }

/* //Don't allow buying this way
    /// @notice Buy tokens from contract by sending ether
    function buy() payable public {
        uint amount = msg.value / buyPrice;               // calculates the amount
        _transfer(this, msg.sender, amount);              // makes the transfers
    }
*/    

    /// @notice Sell `amount` tokens to contract
    /// @param amount amount of tokens to be sold
    function sell(uint256 amount) public {
        require(this.balance >= amount * sellPrice);      // checks if the contract has enough ether to buy
        _transfer(msg.sender, this, amount);              // makes the transfers
        if (sellPrice>0) {
            msg.sender.transfer(amount * sellPrice);          // sends ether to the seller. It's important to do this last to avoid recursion attacks
        }
        totalSupply -= amount;
    }
    
    function getBalance(address target)  view public returns (uint256){
        return balanceOf[target];
    }

    /**
     * Destroy tokens from other account
     *
     * Remove `_value` tokens from the system irreversibly on behalf of `_from`.
     *
     * @param _from the address of the sender
     * @param _value the amount of money to burn
     */
    function burnFrom(address _from, uint256 _value) onlyOwner public returns (bool success) {
        require(balanceOf[_from] >= _value);                // Check if the targeted balance is enough
        balanceOf[_from] -= _value;                         // Subtract from the targeted balance
        totalSupply -= _value;                              // Update totalSupply
        Burn(_from, _value);
        return true;
    }
    
    
}


interface token {
    function transfer(address receiver, uint amount) public;
}


contract ScavengerHuntTokenWatch is MyAdvancedToken {
    uint public crowdsaleDeadline;
    uint public tokensDistributed;
    uint public totalHunters;
    uint public maxDailyRewards;
    string public scavengerHuntTokenName;
    string public scavengerHuntTokenSymbol;

    //Allow to stop being anonymous
    mapping (address => bytes32) public registeredNames;

    // 1 = Digged, No Reward
    // >1 X = Digged, Got Reward
    mapping (bytes32 => mapping (bytes32 => uint)) public GPSDigs;

    //Address of the person that got the reward
    mapping (bytes32 => mapping (bytes32 => address)) public GPSActivityAddress;

    //Maximize the daily reward
    mapping (address => mapping(uint => uint256) ) public dailyRewardCount;
    
    
    
    //Private
    uint256 digHashBase;
    bool crowdsaleClosed = false;

    event FundTransfer(address backer, uint amountEhter, uint amountScavengerHuntTokens, bool isContribution);
    event ShareLocation(address owner, uint ScavengerHuntTokenAmount, uint PercentageOfTotal, bytes32 GPSLatitude, bytes32 GPSLongitude);
    event ShareMessage(address recipient, string Message, string TokenName);
    event SaleEnded(address owner, uint totalTokensDistributed,uint totalHunters);
    event SharePersonalMessage(address Sender, string MyPersonalMessage, bytes32 GPSLatitude, bytes32 GPSLongitude);
    event NameClaimed(address owner, string Name, bytes32 GPSLatitude, bytes32 GPSLongitude);
    event HunterRewarded(address owner, uint ScavengerHuntTokenAmount, uint PercentageOfTotal, bytes32 GPSLatitude, bytes32 GPSLongitude);
    
    modifier afterDeadline() { if (now >= crowdsaleDeadline) _; }
    

    /**
     * Check if deadline was met, so close the sale of tokens
     */
    function checkDeadlinePassed() afterDeadline public {
        SaleEnded(owner, tokensDistributed,totalHunters);
        crowdsaleClosed = true;
    }

    
    /**
     * Constrctor function
     *
     * Setup the owner
     */
     function ScavengerHuntTokenWatch (
        address ifSuccessfulSendTo,
        uint durationInMinutes,
        uint weiCostOfEachToken,
        uint initialSupply,
        string tokenName,
        string tokenSymbol,
        uint256 adigHashBase,
        uint aMaxDailyRewards
        ) MyAdvancedToken(initialSupply, tokenName, tokenSymbol) public {
        owner=msg.sender;
        
        scavengerHuntTokenName = tokenName;
        scavengerHuntTokenSymbol = tokenSymbol;

        //Make sure we can get these tokens
        setPrices(0,weiCostOfEachToken * 1 wei);
       
        digHashBase = adigHashBase;
        maxDailyRewards = aMaxDailyRewards;

        crowdsaleDeadline = now + durationInMinutes * 1 minutes;
        tokensDistributed = initialSupply;
        FundTransfer(ifSuccessfulSendTo, 0, tokensDistributed, true);

        //Now change the owner to the actual user
        owner = ifSuccessfulSendTo;
        totalHunters=1;
        balanceOf[owner] = initialSupply;
        

    }


    function destroySHT(address _from, uint256 _value) internal {
        require(balanceOf[_from] >= _value);                // Check if the targeted balance is enough
        balanceOf[_from] -= _value;                         // Subtract from the targeted balance
        totalSupply -= _value;                              // Update totalSupply
        if(balanceOf[_from]==0) {
            totalHunters--;
        }
    }

    

    function extendCrowdsalePeriod (uint durationInMinutes) onlyOwner public {
        crowdsaleDeadline = now + durationInMinutes * 1 minutes;
        crowdsaleClosed = false;
        ShareMessage(msg.sender,"The crowdsale is extended for token ->",scavengerHuntTokenName );
    }

    function setMaxDailyRewards(uint aMaxDailyRewards) onlyOwner public {
        maxDailyRewards = aMaxDailyRewards;
        ShareMessage(msg.sender,"The maximum of daily reward is now updated for token ->",scavengerHuntTokenName );
    }

    

    //We also allow the calling of the buying function too.
    function buyScavengerHuntToken() payable public {
        //Only allow buying in, when crowdsale is open.
        if (crowdsaleClosed) {
            ShareMessage(msg.sender,"Sorry: The crowdsale has ended. You cannot buy anymore ->",scavengerHuntTokenName );
        }
        require(!crowdsaleClosed);
        uint amountEth = msg.value;
        uint amountSht = amountEth / buyPrice;

        //Mint a token for each payer
        mintScavengerToken(msg.sender, amountSht);

        FundTransfer(msg.sender, amountEth, amountSht, true);
        
        
        //And check if fundraiser is closed:
        checkDeadlinePassed();
    }

    
    function buyScavengerHuntTokenWithLocationSharing(bytes32 GPSLatitude, bytes32 GPSLongitude) payable public {
        buyScavengerHuntToken();
        ShareLocation(msg.sender, balanceOf[msg.sender],getPercentageComplete(msg.sender), GPSLatitude, GPSLongitude);
    }

    
    /**
     * Fallback function
     *
     * The function without name is the default function that is called whenever anyone sends funds to a contract
     */
    function () payable public {
        buyScavengerHuntToken();
    }

    
    /// @notice Create `mintedAmount` tokens and send it to `target`
    /// @param target Address to receive the tokens
    /// @param mintedAmount the amount of tokens it will receive
    function mintScavengerToken(address target, uint256 mintedAmount) private {
        if(balanceOf[target]==0) {
            //New hunter!
            totalHunters++;
        }else {}
        balanceOf[target] += mintedAmount;
        totalSupply += mintedAmount;
        Transfer(this, target, mintedAmount);
        tokensDistributed += mintedAmount;
    }


    /// @notice Create `mintedAmount` tokens and send it to `target`
    /// @param target Address to receive the tokens
    /// @param mintedAmount the amount of tokens it will receive
    function mintExtraScavengerHuntTokens(address target, uint256 mintedAmount) onlyOwner public {
        mintScavengerToken(target, mintedAmount);
    }



    function shareScavengerHuntTokenLocation(bytes32 GPSLatitude, bytes32 GPSLongitude) public {
        //Only call this if you actually have tokens!
        require(balanceOf[msg.sender] > 0); 
        ShareLocation(msg.sender, balanceOf[msg.sender],getPercentageComplete(msg.sender), GPSLatitude, GPSLongitude);
    }

    function sharePersonalScavengerHuntTokenMessage(string MyPersonalMessage, bytes32 GPSLatitude, bytes32 GPSLongitude) public {
        //Only call this if you actually have tokens!
        require(balanceOf[msg.sender] >=1); 
        SharePersonalMessage(msg.sender, MyPersonalMessage, GPSLatitude, GPSLongitude);
        //Personal messages cost 1 token!
        destroySHT(msg.sender, 1);
    }

    function claimName(string MyName, bytes32 GPSLatitude, bytes32 GPSLongitude) public {
        //Only call this if you actually have tokens!
        require(bytes(MyName).length < 32);
        require(balanceOf[msg.sender] >= 10); 
        registeredNames[msg.sender]=getStringAsKey(MyName);
        NameClaimed(msg.sender, MyName, GPSLatitude, GPSLongitude);
        //Claiming your name costs 10 tokens!
        destroySHT(msg.sender, 10);
    }

    
    function transferScavengerHuntToken(address to, uint SHTokenAmount,bytes32 GPSLatitude, bytes32 GPSLongitude) public {
        //Share the transfer with the new total
        if(balanceOf[to]==0) {
            totalHunters++;
        }

        //Call the internal transfer method
        _transfer(msg.sender, to, SHTokenAmount);

        ShareLocation(to, balanceOf[to], getPercentageComplete(to), "unknown", "unknown");
        ShareLocation(msg.sender, balanceOf[msg.sender], getPercentageComplete(msg.sender), GPSLatitude, GPSLongitude);
        if(balanceOf[msg.sender]==0) {
            totalHunters--;
        }

    }

    function returnEtherumToOwner(uint amount) onlyOwner public {
        if (owner.send(amount)) {
            FundTransfer(owner, amount,0, false);
        } 
    }

    //Date and time library

    uint constant DAY_IN_SECONDS = 86400;
    uint constant YEAR_IN_SECONDS = 31536000;
    uint constant LEAP_YEAR_IN_SECONDS = 31622400;

    uint constant HOUR_IN_SECONDS = 3600;
    uint constant MINUTE_IN_SECONDS = 60;

    uint16 constant ORIGIN_YEAR = 1970;
    
    function leapYearsBefore(uint year) internal pure returns (uint) {
        year -= 1;
        return year / 4 - year / 100 + year / 400;
    }    
    
    function isLeapYear(uint16 year) internal pure returns (bool) {
                if (year % 4 != 0) {
                        return false;
                }
                if (year % 100 != 0) {
                        return true;
                }
                if (year % 400 != 0) {
                        return false;
                }
                return true;
    }
    
    function getDaysInMonth(uint8 month, uint16 year) internal pure returns (uint8) {
                if (month == 1 || month == 3 || month == 5 || month == 7 || month == 8 || month == 10 || month == 12) {
                        return 31;
                }
                else if (month == 4 || month == 6 || month == 9 || month == 11) {
                        return 30;
                }
                else if (isLeapYear(year)) {
                        return 29;
                }
                else {
                        return 28;
                }
    }

    
    function getToday() public view returns (uint) {
        uint16 year;
        uint8 month;
        uint8 day;

        uint secondsAccountedFor = 0;
        uint buf;
        uint8 i;

        
        uint timestamp=now;
        
        // Year
        year = getYear(timestamp);
        buf = leapYearsBefore(year) - leapYearsBefore(ORIGIN_YEAR);

        secondsAccountedFor += LEAP_YEAR_IN_SECONDS * buf;
        secondsAccountedFor += YEAR_IN_SECONDS * (year - ORIGIN_YEAR - buf);

        // Month
        uint secondsInMonth;
        for (i = 1; i <= 12; i++) {
            secondsInMonth = DAY_IN_SECONDS * getDaysInMonth(i, year);
            if (secondsInMonth + secondsAccountedFor > timestamp) {
                    month = i;
                    break;
            }
            secondsAccountedFor += secondsInMonth;
        }

        // Day
        for (i = 1; i <= getDaysInMonth(month, year); i++) {
                if (DAY_IN_SECONDS + secondsAccountedFor > timestamp) {
                        day = i;
                        break;
                }
                secondsAccountedFor += DAY_IN_SECONDS;
        }
        
        //20170106
        uint endDate = uint(year) * 10000;
        if (month<10) {
            endDate += uint(month)*100;
        } else {
            endDate += uint(month)*10;
        }
        endDate += uint(day);
        return endDate;
        
    }

    function getYear(uint timestamp) internal pure returns (uint16) {
            uint secondsAccountedFor = 0;
            uint16 year;
            uint numLeapYears;

            // Year
            year = uint16(ORIGIN_YEAR + timestamp / YEAR_IN_SECONDS);
            numLeapYears = leapYearsBefore(year) - leapYearsBefore(ORIGIN_YEAR);

            secondsAccountedFor += LEAP_YEAR_IN_SECONDS * numLeapYears;
            secondsAccountedFor += YEAR_IN_SECONDS * (year - ORIGIN_YEAR - numLeapYears);

            while (secondsAccountedFor > timestamp) {
                    if (isLeapYear(uint16(year - 1))) {
                            secondsAccountedFor -= LEAP_YEAR_IN_SECONDS;
                    }
                    else {
                            secondsAccountedFor -= YEAR_IN_SECONDS;
                    }
                    year -= 1;
            }
            return year;
    }

    
    function hashSeriesNumber(bytes32 series, uint256 number) internal pure returns (bytes32){
        return keccak256(number, series);
    }
    
    function digRewardCheck(uint hash, uint modulo,uint reward,bytes32 GPSLatitude, bytes32 GPSLongitude) internal returns (uint256) {
        if (hash % modulo == 0) {
            //Reward a 50 tokens
            mintScavengerToken(msg.sender, reward);
            dailyRewardCount[msg.sender][getToday()]++;
            GPSDigs[GPSLatitude][GPSLongitude]=reward;
            GPSActivityAddress[GPSLatitude][GPSLongitude]=msg.sender;
            HunterRewarded(msg.sender, reward,getPercentageComplete(msg.sender), GPSLatitude, GPSLongitude);
            return reward;
        }
        else {
            return 0;
        }
    }

    function digForTokens(bytes32 GPSLatitude, bytes32 GPSLongitude) payable public returns(uint256) {
        //Only call this if you actually have tokens!
        require(balanceOf[msg.sender] > 1); 
        //Only once digging is allowed!
        require(GPSDigs[GPSLatitude][GPSLongitude] == 0); 

        //You can only win that much per day
        require( dailyRewardCount[msg.sender][getToday()] <= maxDailyRewards);
        
        //Diggin costs 1 tokens!
        destroySHT(msg.sender, 1);

        uint hash = uint(hashSeriesNumber(GPSLatitude,digHashBase));
        hash += uint(hashSeriesNumber(GPSLongitude,digHashBase));

        uint awarded = digRewardCheck(hash, 100000000,100000,GPSLatitude,GPSLongitude);
        if (awarded>0) {
            return awarded;
        }

        awarded = digRewardCheck(hash, 100000,1000,GPSLatitude,GPSLongitude);
        if (awarded>0) {
            return awarded;
        }
        
        awarded = digRewardCheck(hash, 10000,500,GPSLatitude,GPSLongitude);
        if (awarded>0) {
            return awarded;
        }

        awarded = digRewardCheck(hash, 1000,200,GPSLatitude,GPSLongitude);
        if (awarded>0) {
            return awarded;
        }

        awarded = digRewardCheck(hash, 100,50,GPSLatitude,GPSLongitude);
        if (awarded>0) {
            return awarded;
        }

        awarded = digRewardCheck(hash, 10,3,GPSLatitude,GPSLongitude);
        if (awarded>0) {
            return awarded;
        }
        
        //You've got nothing!
        GPSDigs[GPSLatitude][GPSLongitude]=1;
        GPSActivityAddress[GPSLatitude][GPSLongitude]=msg.sender;
        HunterRewarded(msg.sender, 0,getPercentageComplete(msg.sender), GPSLatitude, GPSLongitude);
        return 0;
    }
    
    
    function getPercentageComplete(address ScavengerHuntTokenOwner)  view public returns (uint256){
        //Since there are no decimals, just create some of our own
        uint256 myBalance = balanceOf[ScavengerHuntTokenOwner]*100000.0;
        uint256 myTotalSupply = totalSupply;
        uint256 myResult = myBalance / myTotalSupply;
        return  myResult;
    }

    function getStringAsKey(string key) pure public returns (bytes32 ret) {
        require(bytes(key).length < 32);
        assembly {
          ret := mload(add(key, 32))
        }
    }
    
    function getKeyAsString(bytes32 x) pure public returns (string) {
        bytes memory bytesString = new bytes(32);
        uint charCount = 0;
        for (uint j = 0; j < 32; j++) {
            byte char = byte(bytes32(uint(x) * 2 ** (8 * j)));
            if (char != 0) {
                bytesString[charCount] = char;
                charCount++;
            }
        }
        bytes memory bytesStringTrimmed = new bytes(charCount);
        for (j = 0; j < charCount; j++) {
            bytesStringTrimmed[j] = bytesString[j];
        }
        return string(bytesStringTrimmed);
    }
    
    modifier aftercrowdsaleDeadline()  { if (now >= crowdsaleDeadline) _; }
    
}