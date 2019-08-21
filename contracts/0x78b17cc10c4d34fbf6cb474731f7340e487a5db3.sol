pragma solidity ^0.4.19;

contract UTEMIS{    
    /******************** Public constants ********************/
    
    // Days of ico since it is deployed
    uint                                            public constant ICO_DAYS             = 59;

    // Minimum value accepted for investors. n wei / 10 ^ 18 = n Ethers
    uint                                            public constant MIN_ACCEPTED_VALUE   = 50000000000000000 wei;

    // Value for each UTS
    uint                                            public constant VALUE_OF_UTS         = 666666599999 wei;

    // Token name
    string                                          public constant TOKEN_NAME           = "UTEMIS";
    
    // Symbol token
    string                                          public constant TOKEN_SYMBOL         = "UTS";

    // Total supply of tokens
    uint256                                         public constant TOTAL_SUPPLY         = 1 * 10 ** 12;    

    // The amount of tokens that will be offered during the ico
    uint256                                         public constant ICO_SUPPLY           = 2 * 10 ** 11;

    // Minimum objective
    uint256                                         public constant SOFT_CAP             = 10000 ether; // 10000 ETH

    // When the ico Starts - GMT Monday, January 8 , 2018 5:00:00 PM //1515430800;
    uint                                            public constant START_ICO            = 1515430800;
    
    /******************** Public variables ********************/

    //Owner of the contract
    address                                         public owner;    

    //Date of end ico
    uint                                            public deadLine;        

    //Date of start ico
    uint                                            public startTime;

    //Balances
    mapping(address => uint256)                     public balance_;

    //Remaining tokens to offer during the ico
    uint                                            public remaining;    

    //Time of bonus application, could be n minutes , n hours , n days , n weeks , n years 
    uint[4]                                         private bonusTime                  = [3 days    , 17 days    , 31 days   , 59 days];

    //Amount of bonus applicated
    uint8[4]                                        private bonusBenefit               = [uint8(40) , uint8(25)  , uint8(20) , uint8(15)];
    uint8[4]                                        private bonusPerInvestion_5        = [uint8(0)  , uint8(5)   , uint8(3)  , uint8(2)];
    uint8[4]                                        private bonusPerInvestion_10       = [uint8(0)  , uint8(10)  , uint8(5)  , uint8(3)];    

    //The accound that receives the ether when the ico is succesful. If not defined, the beneficiary will be the owner
    address                                         private beneficiary;    

    //State of ico
    bool                                            private ico_started;

    //Ethers collected during the ico
    uint256                                         public ethers_collected;
    
    //ETH Balance of contract
    uint256                                         private ethers_balance;
        

    //Struct data for store investors
    struct Investors{
        uint256 amount;
        uint when;        
    }

    //Array for investors
    mapping(address => Investors) private investorsList;     
    address[] private investorsAddress;

    //Events
    event Transfer(address indexed from , address indexed to , uint256 value);
    event Burn(address indexed from, uint256 value);
    event FundTransfer(address backer , uint amount , address investor);

    //Safe math
    function safeSub(uint a , uint b) internal pure returns (uint){assert(b <= a);return a - b;}  
    function safeAdd(uint a , uint b) internal pure returns (uint){uint c = a + b;assert(c>=a && c>=b);return c;}

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }
    
    modifier icoStarted(){
        require(ico_started == true);
        require(now <= deadLine);
        require(now >= START_ICO);
        _;
    }

    modifier icoStopped(){
        require(ico_started == false);
        require(now > deadLine);
        _;        
    }

    modifier minValue(){
        require(msg.value >= MIN_ACCEPTED_VALUE);
        _;
    }

    //Contract constructor
    function UTEMIS() public{          
        balance_[msg.sender] = TOTAL_SUPPLY;                                         //Transfer all tokens to main account        
        owner               = msg.sender;                                           //Set the variable owner to creator of contract                
        deadLine            = START_ICO + ICO_DAYS * 1 days;                        //Declare deadLine        
        startTime           = now;                                                  //Declare startTime of contract
        remaining           = ICO_SUPPLY;                                           //The remaining tokens to sell
        ico_started         = false;                                                //State of ico            
    }

    /**
     * For transfer tokens. Internal use, only can executed by this contract
     *
     * @param  _from         Source address
     * @param  _to           Destination address
     * @param  _value        Amount of tokens to send
     */
    function _transfer(address _from , address _to , uint _value) internal{        
        require(_to != 0x0);                                                        //Prevent send tokens to 0x0 address        
        require(balance_[_from] >= _value);                                          //Check if the sender have enough tokens        
        require(balance_[_to] + _value > balance_[_to]);                              //Check for overflows        
        balance_[_from]         = safeSub(balance_[_from] , _value);                 //Subtract from the source ( sender )        
        balance_[_to]           = safeAdd(balance_[_to]   , _value);                 //Add tokens to destination        
        uint previousBalance    = balance_[_from] + balance_[_to];                    //To make assert        
        Transfer(_from , _to , _value);                                             //Fire event for clients        
        assert(balance_[_from] + balance_[_to] == previousBalance);                   //Check the assert
    }

    /**
     * For transfer tokens from owner of contract
     *
     * @param  _to           Destination address
     * @param  _value        Amount of tokens to send
     */
    function transfer(address _to , uint _value) public onlyOwner{                                             
        _transfer(msg.sender , _to , _value);                                       //Internal transfer
    }
    
    /**
     * ERC20 Function to know's the balances
     *
     * @param  _owner           Address to check
     * @return uint             Returns the balance of indicated address
     */
    function balanceOf(address _owner) constant public returns(uint balances){
        return balance_[_owner];
    }    

    /**
     * Get investors info
     *
     * @return []                Returns an array with address of investors, amount invested and when invested
     */
    function getInvestors() constant public returns(address[] , uint[] , uint[]){
        uint length = investorsAddress.length;                                             //Length of array
        address[] memory addr = new address[](length);
        uint[] memory amount  = new uint[](length);
        uint[] memory when    = new uint[](length);
        for(uint i = 0; i < length; i++){
            address key = investorsAddress[i];
            addr[i]     = key;
            amount[i]   = investorsList[key].amount;
            when[i]     = investorsList[key].when;
        }
        return (addr , amount , when);        
    }

    /**
     * Get total tokens distributeds
     *
     * @return uint              Returns total tokens distributeds
     */
    function getTokensDistributeds() constant public returns(uint){
        return ICO_SUPPLY - remaining;
    }

    /**
     * Get amount of bonus to apply
     *
     * @param _ethers              Amount of ethers invested, for calculation the bonus     
     * @return uint                Returns a % of bonification to apply
     */
    function getBonus(uint _ethers) public view returns(uint8){        
        uint8 _bonus  = 0;                                                          //Assign bonus to 
        uint8 _bonusPerInvestion = 0;
        uint  starter = now - START_ICO;                                            //To control end time of bonus
        for(uint i = 0; i < bonusTime.length; i++){                                 //For loop
            if(starter <= bonusTime[i]){                                            //If the starter are greater than bonusTime, the bonus will be 0                
                if(_ethers >= 5 ether && _ethers < 10 ether){
                    _bonusPerInvestion = bonusPerInvestion_5[i];
                }
                if(_ethers > 10 ether){
                    _bonusPerInvestion = bonusPerInvestion_10[i];
                }
                _bonus = bonusBenefit[i];                                           //Asign amount of bonus to bonus_ variable                                
                break;                                                              //Break the loop

            }
        }        
        return _bonus + _bonusPerInvestion;
    }
    
    /**
     * Escale any value to n * 10 ^ 18
     *
     * @param  _value        Value to escale
     * @return uint          Returns a escaled value
     */
    function escale(uint _value) private pure returns(uint){
        return _value * 10 ** 18;
    }

    /**
     * Calculate the amount of tokens to sends depeding on the amount of ethers received
     *
     * @param  _ethers              Amount of ethers for convert to tokens
     * @return uint                 Returns the amount of tokens to send
     */
    function getTokensToSend(uint _ethers) public view returns (uint){
        uint tokensToSend  = 0;                                                     //Assign tokens to send to 0                                            
        uint8 bonus        = getBonus(_ethers);                                     //Get amount of bonification        
        uint ethToTokens   = _ethers / VALUE_OF_UTS;                                //Make the conversion, divide amount of ethers by value of each UTS                
        uint amountBonus   = escale(ethToTokens) / 100 * escale(bonus);
        uint _amountBonus  = amountBonus / 10 ** 36;
             tokensToSend  = ethToTokens + _amountBonus;
        return tokensToSend;
    }

    /**
     * Set the beneficiary of the contract, who receives Ethers
     *
     * @param _beneficiary          Address that will be who receives Ethers
     */
    function setBeneficiary(address _beneficiary) public onlyOwner{
        require(msg.sender == owner);                                               //Prevents the execution of another than the owner
        beneficiary = _beneficiary;                                                 //Set beneficiary
    }


    /**
     * Start the ico manually
     *     
     */
    function startIco() public onlyOwner{
        ico_started = true;                                                         //Set the ico started
    }

    /**
     * Stop the ico manually
     *
     */
    function stopIco() public onlyOwner{
        ico_started = false;                                                        //Set the ico stopped
    }

    /**
     * Give back ethers to investors if soft cap is not reached
     * 
     */
    function giveBackEthers() public onlyOwner icoStopped{
        require(this.balance >= ethers_collected);                                         //Require that the contract have ethers 
        uint length = investorsAddress.length;                                             //Length of array    
        for(uint i = 0; i < length; i++){
            address investorA = investorsAddress[i];            
            uint amount       = investorsList[investorA].amount;
            if(address(beneficiary) == 0){
                beneficiary = owner;
            }
            _transfer(investorA , beneficiary , balanceOf(investorA));
            investorA.transfer(amount);
        }
    }

    
    /**
     * Fallback when the contract receives ethers
     *
     */
    function () payable public icoStarted minValue{                              
        uint amount_actually_invested = investorsList[msg.sender].amount;           //Get the actually amount invested
        
        if(amount_actually_invested == 0){                                          //If amount invested are equal to 0, will add like new investor
            uint index                = investorsAddress.length++;
            investorsAddress[index]   = msg.sender;
            investorsList[msg.sender] = Investors(msg.value , now);                 //Store investors info        
        }
        
        if(amount_actually_invested > 0){                                           //If amount invested are greater than 0
            investorsList[msg.sender].amount += msg.value;                          //Increase the amount invested
            investorsList[msg.sender].when    = now;                                //Change the last time invested
        }

        uint tokensToSend = getTokensToSend(msg.value);                             //Calc the tokens to send depending on ethers received
        remaining -= tokensToSend;                                                  //Subtract the tokens to send to remaining tokens        
        _transfer(owner , msg.sender , tokensToSend);                               //Transfer tokens to investor
        
        require(balance_[owner] >= (TOTAL_SUPPLY - ICO_SUPPLY));                     //Requires not selling more tokens than those proposed in the ico        
        require(balance_[owner] >= tokensToSend);
        
        if(address(beneficiary) == 0){                                              //Check if beneficiary is not setted
            beneficiary = owner;                                                    //If not, set the beneficiary to owner
        }    
        ethers_collected += msg.value;                                              //Increase ethers_collected   
        ethers_balance   += msg.value;
        if(!beneficiary.send(msg.value)){
            revert();
        }                                                //Send ethers to beneficiary

        FundTransfer(owner , msg.value , msg.sender);                               //Fire events for clients
    }

    /**
     * Extend ICO time
     *
     * @param  timetoextend  Time in miliseconds to extend ico     
     */
    function extendICO(uint timetoextend) onlyOwner external{
        require(timetoextend > 0);
        deadLine+= timetoextend;
    }
    
    /**
     * Destroy contract and send ethers to owner
     * 
     */
    function destroyContract() onlyOwner external{
        selfdestruct(owner);
    }


}