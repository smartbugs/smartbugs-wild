pragma solidity ^ 0.4.17;

library SafeMath {
    function mul(uint a, uint b) pure internal returns(uint) {
        uint c = a * b;
        assert(a == 0 || c / a == b);
        return c;
    }


    function sub(uint a, uint b) pure internal returns(uint) {
        assert(b <= a);
        return a - b;
    }

    function add(uint a, uint b) pure internal returns(uint) {
        uint c = a + b;
        assert(c >= a && c >= b);
        return c;
    }
}

contract ERC20 {
    uint public totalSupply;

    function balanceOf(address who) public view returns(uint);

    function allowance(address owner, address spender) public view returns(uint);

    function transfer(address to, uint value) public returns(bool ok);

    function transferFrom(address from, address to, uint value) public returns(bool ok);

    function approve(address spender, uint value) public returns(bool ok);

    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);
}


contract Ownable {
    address public owner;

    function Ownable() public {
        owner = msg.sender;
    }

    function transferOwnership(address newOwner) public onlyOwner {
        if (newOwner != address(0)) 
            owner = newOwner;
    }

    function kill() public {
        if (msg.sender == owner) 
            selfdestruct(owner);
    }

    modifier onlyOwner() {
        if (msg.sender == owner)
            _;
    }
}

contract Pausable is Ownable {
    bool public stopped;

    modifier stopInEmergency {
        if (stopped) {
            revert();
        }
        _;
    }

    modifier onlyInEmergency {
        if (!stopped) {
            revert();
        }
        _;
    }

    // Called by the owner in emergency, triggers stopped state
    function emergencyStop() external onlyOwner() {
        stopped = true;
    }

    // Called by the owner to end of emergency, returns to normal state
    function release() external onlyOwner() onlyInEmergency {
        stopped = false;
    }
}





// Crowdsale Smart Contract
// This smart contract collects ETH and in return sends tokens to contributors
contract Crowdsale is Pausable {

    using SafeMath for uint;

    struct Backer {
        uint weiReceived; // amount of ETH contributed
        uint tokensSent; // amount of tokens  sent  
        bool refunded; // true if user has been refunded       
    }

    Token public token; // Token contract reference   
    address public multisig; // Multisig contract that will receive the ETH    
    address public team; // Address at which the team tokens will be sent     
    address public lottery; //address for 50% of remaining tokens 
    uint public ethReceivedPresale; // Number of ETH received in presal
    uint public ethReceivedMain; // Number of ETH received in main sale
    uint public totalTokensSent; // Number of sent to ETH contributors
    uint public startBlock; // Crowdsale start block
    uint public endBlock; // Crowdsale end block
    uint public maxCap; // Maximum number of to sell
    uint public minCap; // Minimum number of ETH to raise
    uint public minInvestETH; // Minimum amount to invest   
    bool public crowdsaleClosed; // Is crowdsale still on going
    Step public currentStep;  // to allow for controled steps of the campaign 
    uint public refundCount;  // number of refunds
    uint public totalRefunded; // total amount of refunds    
    uint public tokenPriceWei;

    mapping(address => Backer) public backers; //backer list
    address[] public backersIndex; // to be able to itarate through backers for verification.  


     // @ntice ovwrite to ensure that if any money are left, they go 
     // to multisig wallet
     function kill() public {
        if (msg.sender == owner) 
            selfdestruct(multisig);
    }

    // @notice to verify if action is not performed out of the campaing range
    modifier respectTimeFrame() {
        if ((block.number < startBlock) || (block.number > endBlock)) 
            revert();
        _;
    }


    modifier minCapNotReached() {
        if (ethReceivedPresale.add(ethReceivedMain) >= minCap) 
            revert();
        _;
    }


    // @notice to set and determine steps of crowdsale
    enum Step {
        Unknown,
        FundingPreSale,     // presale mode
        FundingPublicSale,  // public mode
        Refunding  // in case campaign failed during this step contributors will be able to receive refunds
    }


    // Events
    event ReceivedETH(address backer, uint amount, uint tokenAmount);
    event RefundETH(address backer, uint amount);


    // Crowdsale  {constructor}
    // @notice fired when contract is crated. Initilizes all constnat variables.
    function Crowdsale() public {
        
        multisig = 0xC30b7a7d82c71467AF9eC85e039e4ED586EF9812; 
        team = 0xC30b7a7d82c71467AF9eC85e039e4ED586EF9812;       
        lottery = 0xC30b7a7d82c71467AF9eC85e039e4ED586EF9812;                                                         
        maxCap = 14700000e18;        
        tokenPriceWei = 6666666666e5;
        totalTokensSent = 0; 
        minCap = (750 ether * 1e18) / tokenPriceWei;
        setStep(Step.FundingPreSale);
    }

       // @notice to populate website with status of the sale 
    function returnWebsiteData() external constant returns(uint, uint, uint, uint, uint, uint, uint, uint, Step, bool, bool) {
        
    
        return (startBlock, endBlock, backersIndex.length, ethReceivedPresale.add(ethReceivedMain), maxCap, minCap, totalTokensSent,  tokenPriceWei, currentStep, stopped, crowdsaleClosed);
    }

    // @notice in case refunds are needed, money can be returned to the contract
    function fundContract() external payable onlyOwner() returns (bool) {
        return true;
    }


    // @notice Specify address of token contract
    // @param _tokenAddress {address} address of token contrac
    // @return res {bool}
    function updateTokenAddress(Token _tokenAddress) external onlyOwner() returns(bool res) {
        token = _tokenAddress;
        return true;
    }


    // @notice set the step of the campaign 
    // @param _step {Step}
    function setStep(Step _step) public onlyOwner() {
        currentStep = _step;
        
        if (currentStep == Step.FundingPreSale)  // for presale             
            minInvestETH = 1 ether/4;                             
        else if (currentStep == Step.FundingPublicSale) // for public sale           
            minInvestETH = 0;                               
    }


    // @notice return number of contributors
    // @return  {uint} number of contributors   
    function numberOfBackers() public constant returns(uint) {
        return backersIndex.length;
    }



    // {fallback function}
    // @notice It will call internal function which handels allocation of Ether and calculates tokens.
    function () external payable {           
        contribute(msg.sender);
    }


    // @notice It will be called by owner to start the sale    
    function start(uint _block) external onlyOwner() {   

        require(_block < 216000);  // 2.5*60*24*60 days = 216000     
        startBlock = block.number;
        endBlock = startBlock.add(_block); 
    }

    // @notice Due to changing average of block time
    // this function will allow on adjusting duration of campaign closer to the end 
    function adjustDuration(uint _block) external onlyOwner() {

        require(_block < 288000);  // 2.5*60*24*80 days = 288000     
        require(_block > block.number.sub(startBlock)); // ensure that endBlock is not set in the past
        endBlock = startBlock.add(_block); 
    }

    // @notice It will be called by fallback function whenever ether is sent to it
    // @param  _backer {address} address of beneficiary
    // @return res {bool} true if transaction was successful
    function contribute(address _backer) internal stopInEmergency respectTimeFrame returns(bool res) {

        uint tokensToSend = validPurchase();
            
        Backer storage backer = backers[_backer];

        if (!token.transfer(_backer, tokensToSend)) 
            revert(); // Transfer tokens
        backer.tokensSent = backer.tokensSent.add(tokensToSend); // save contributors tokens to be sent
        backer.weiReceived = backer.weiReceived.add(msg.value);  // save how much was the contribution

        if (Step.FundingPublicSale == currentStep)  // Update the total Ether recived
           ethReceivedMain = ethReceivedMain.add(msg.value);
        else
            ethReceivedPresale = ethReceivedPresale.add(msg.value); 
                                                     
        totalTokensSent = totalTokensSent.add(tokensToSend);     // update the total amount of tokens sent
        backersIndex.push(_backer);

        multisig.transfer(this.balance);   // transfer funds to multisignature wallet             

        ReceivedETH(_backer, msg.value, tokensToSend); // Register event
        return true;
    }



    // @notice determine if purchase is valid and return proper number of tokens
    // @return tokensToSend {uint} proper number of tokens based on the timline

    function validPurchase() constant internal returns (uint) {
       
        require (msg.value >= minInvestETH);   // ensure that min contributions amount is met

        // calculate amount of tokens to send  (add 18 0s first)   
        uint tokensToSend = msg.value.mul(1e18) / tokenPriceWei;  // basic nmumber of tokens to send
          
        if (Step.FundingPublicSale == currentStep)   // calculate stepped price of token in public sale
            tokensToSend = calculateNoOfTokensToSend(tokensToSend); 
        else                                         // calculate number of tokens for presale with 50% bonus
            tokensToSend = tokensToSend.add(tokensToSend.mul(50) / 100);
          
        require(totalTokensSent.add(tokensToSend) < maxCap); // Ensure that max cap hasn't been reached  

        return tokensToSend;
    }
    
    // @notice It is called by handleETH to determine amount of tokens for given contribution
    // @param _amount {uint} current range computed
    // @return tokensToPurchase {uint} value of tokens to purchase
    function calculateNoOfTokensToSend(uint _amount) internal constant returns(uint) {
   
        if (ethReceivedMain <= 1500 ether)        // First 1500 ETH: 25%
            return _amount.add(_amount.mul(25) / 100);
        else if (ethReceivedMain <= 2500 ether)   // 1501 to 2500 ETH: 15%              
            return _amount.add(_amount.mul(15) / 100);
        else if (ethReceivedMain < 3000 ether)   // 2501 to 3000 ETH: 10%
            return _amount.add(_amount.mul(10) / 100);
        else if (ethReceivedMain <= 4000 ether)  // 3001 to 4000 ETH: 5%
            return _amount.add(_amount.mul(5) / 100);
        else if (ethReceivedMain <= 5000 ether)  // 4001 to 5000 ETH : 2%
            return _amount.add(_amount.mul(2) / 100);
        else                                 // 5000+ No bonus after that
            return _amount;
    }

    // @notice show for display purpose amount of tokens which can be bought 
    // at given moment. 
    // @param _ether {uint} amount of ehter
    function estimateTokenNumber(uint _amountWei ) external view returns (uint) { 
        return calculateNoOfTokensToSend(_amountWei);
    }

    // @notice This function will finalize the sale.
    // It will only execute if predetermined sale time passed or all tokens are sold.
    function finalize() external onlyOwner() {

        uint totalEtherReceived = ethReceivedPresale.add(ethReceivedMain);

        require(!crowdsaleClosed);        
        // purchasing precise number of tokens might be impractical, thus subtract 100 tokens so finalizition is possible
        // near the end 
        require (block.number >= endBlock || totalTokensSent >= maxCap.sub(100)); 
        require(totalEtherReceived >= minCap && block.number >= endBlock);             

        if (totalTokensSent >= minCap) {           
            if (!token.transfer(team, 6300000e18)) // transfer tokens for the team/dev/advisors
                revert();
            if (!token.transfer(lottery, token.balanceOf(this) / 2)) 
                revert();
            if (!token.burn(this, token.balanceOf(this)))
                revert();
             token.unlock();
        }
        crowdsaleClosed = true;       
    }

  

    // @notice Failsafe drain
    function drain() external onlyOwner() {
        multisig.transfer(this.balance);               
    }



    // @notice Failsafe token transfer
    function tokenDrian() external onlyOwner() {
       if (block.number > endBlock) {
        if (!token.transfer(team, token.balanceOf(this))) 
                revert();
        }
    }
    


    function refund()  external stopInEmergency returns (bool) {

        require(totalTokensSent < minCap); 
        require(this.balance > 0);  // contract will hold 0 ether at the end of campaign.                                  
                                    // contract needs to be funded through fundContract() 

        Backer storage backer = backers[msg.sender];

        if (backer.weiReceived == 0)
            revert();

        require(!backer.refunded);
        require(backer.tokensSent != 0);

        if (!token.burn(msg.sender, backer.tokensSent))
            revert();
        backer.refunded = true;
      
        refundCount ++;
        totalRefunded = totalRefunded.add(backer.weiReceived);
        msg.sender.transfer(backer.weiReceived);
        RefundETH(msg.sender, backer.weiReceived);
        return true;
    }
}

// The token
contract Token is ERC20,  Ownable {

    using SafeMath for uint;
    // Public variables of the token
    string public name;
    string public symbol;
    uint8 public decimals; // How many decimals to show.
    string public version = "v0.1";       
    uint public totalSupply;
    bool public locked;
    address public crowdSaleAddress;
    


    mapping(address => uint) balances;
    mapping(address => mapping(address => uint)) allowed;

    // tokens are locked during the ICO. Allow transfer of tokens after ICO. 
    modifier onlyUnlocked() {
        if (msg.sender != crowdSaleAddress && locked) 
            revert();
        _;
    }


    // allow burning of tokens only by authorized users 
    modifier onlyAuthorized() {
        if (msg.sender != owner && msg.sender != crowdSaleAddress ) 
            revert();
        _;
    }


    // The Token 
    function Token(address _crowdSaleAddress) public {
        
        locked = true;  // Lock the transfCrowdsaleer function during the crowdsale
        totalSupply = 21000000e18; 
        name = "Lottery Token"; // Set the name for display purposes
        symbol = "ETHD"; // Set the symbol for display purposes
        decimals = 18; // Amount of decimals for display purposes
        crowdSaleAddress = _crowdSaleAddress;                                  
        balances[crowdSaleAddress] = totalSupply;
    }

    function unlock() public onlyAuthorized {
        locked = false;
    }

    function lock() public onlyAuthorized {
        locked = true;
    }
    

    function burn( address _member, uint256 _value) public onlyAuthorized returns(bool) {
        balances[_member] = balances[_member].sub(_value);
        totalSupply = totalSupply.sub(_value);
        Transfer(_member, 0x0, _value);
        return true;
    }

    function transfer(address _to, uint _value) public onlyUnlocked returns(bool) {
        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);
        Transfer(msg.sender, _to, _value);
        return true;
    }

    
    function transferFrom(address _from, address _to, uint256 _value) public onlyUnlocked returns(bool success) {
        require (balances[_from] >= _value); // Check if the sender has enough                            
        require (_value <= allowed[_from][msg.sender]); // Check if allowed is greater or equal        
        balances[_from] = balances[_from].sub(_value); // Subtract from the sender
        balances[_to] = balances[_to].add(_value); // Add the same to the recipient
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
        Transfer(_from, _to, _value);
        return true;
    }

    function balanceOf(address _owner) public view returns(uint balance) {
        return balances[_owner];
    }


    /**
    * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.
    *
    * Beware that changing an allowance with this method brings the risk that someone may use both the old
    * and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this
    * race condition is to first reduce the spender's allowance to 0 and set the desired value afterwards:
    * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
    * @param _spender The address which will spend the funds.
    * @param _value The amount of tokens to be spent.
    */
    function approve(address _spender, uint _value) public returns(bool) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }


    function allowance(address _owner, address _spender) public constant returns(uint remaining) {
        return allowed[_owner][_spender];
    }

    /**
    * approve should be called when allowed[_spender] == 0. To increment
    * allowed value is better to use this function to avoid 2 calls (and wait until
    * the first transaction is mined)
    * From MonolithDAO Token.sol
    */
    function increaseApproval (address _spender, uint _addedValue) public returns (bool success) {
        allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
        Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
        return true;
    }

    function decreaseApproval (address _spender, uint _subtractedValue) public returns (bool success) {
        uint oldValue = allowed[msg.sender][_spender];
        if (_subtractedValue > oldValue) {
        allowed[msg.sender][_spender] = 0;
        } else {
        allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
        }
        Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
        return true;
    }

}