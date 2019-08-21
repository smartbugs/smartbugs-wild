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
    uint public ethReceivedPresale; // Number of ETH received in presale
    uint public ethReceivedMain; // Number of ETH received in public sale
    uint public totalTokensSent; // Number of tokens sent to ETH contributors
    uint public startBlock; // Crowdsale start block
    uint public endBlock; // Crowdsale end block
    uint public maxCap; // Maximum number of tokens to sell
    uint public minCap; // Minimum number of ETH to raise
    uint public minInvestETH; // Minimum amount to invest   
    bool public crowdsaleClosed; // Is crowdsale still in progress
    Step public currentStep;  // to allow for controled steps of the campaign 
    uint public refundCount;  // number of refunds
    uint public totalRefunded; // total amount of refunds    
    uint public tokenPriceWei;  // price of token in wei

    mapping(address => Backer) public backers; //backer list
    address[] public backersIndex; // to be able to itarate through backers for verification.  

    
    // @notice to verify if action is not performed out of the campaing range
    modifier respectTimeFrame() {
        if ((block.number < startBlock) || (block.number > endBlock)) 
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
    // @notice fired when contract is crated. Initilizes all constnat and initial values.
    function Crowdsale() public {
        multisig = 0xc15464420aC025077Ba280cBDe51947Fc12583D6; 
        team = 0xc15464420aC025077Ba280cBDe51947Fc12583D6;                                  
        minInvestETH = 1 ether/100;
        startBlock = 0; // Should wait for the call of the function start
        endBlock = 0; // Should wait for the call of the function start                  
        tokenPriceWei = 1 ether/8000;
        maxCap = 30600000e18;         
        minCap = 900000e18;        
        totalTokensSent = 1253083e18;  
        setStep(Step.FundingPreSale);
    }

    // @notice to populate website with status of the sale 
    function returnWebsiteData() external view returns(uint, uint, uint, uint, uint, uint, uint, uint, Step, bool, bool) {            
    
        return (startBlock, endBlock, backersIndex.length, ethReceivedPresale.add(ethReceivedMain), maxCap, minCap, totalTokensSent, tokenPriceWei, currentStep, stopped, crowdsaleClosed);
    }

    // @notice in case refunds are needed, money can be returned to the contract
    function fundContract() external payable onlyOwner() returns (bool) {
        return true;
    }

    // @notice Specify address of token contract
    // @param _tokenAddress {address} address of token contract
    // @return res {bool}
    function updateTokenAddress(Token _tokenAddress) external onlyOwner() returns(bool res) {
        token = _tokenAddress;
        return true;
    }

    // @notice set the step of the campaign 
    // @param _step {Step}
    function setStep(Step _step) public onlyOwner() {
        currentStep = _step;
        
        if (currentStep == Step.FundingPreSale) {  // for presale 
            tokenPriceWei = 1 ether/8000;  
            minInvestETH = 1 ether/100;                             
        }else if (currentStep == Step.FundingPublicSale) { // for public sale
            tokenPriceWei = 1 ether/5000;   
            minInvestETH = 0;               
        }            
    }

    // @notice return number of contributors
    // @return  {uint} number of contributors   
    function numberOfBackers() external view returns(uint) {
        return backersIndex.length;
    }

    // {fallback function}
    // @notice It will call internal function which handels allocation of Ether and calculates tokens.
    function () external payable {           
        contribute(msg.sender);
    }

    // @notice It will be called by owner to start the sale    
    function start(uint _block) external onlyOwner() {   

        require(_block < 246528);  // 4.28*60*24*40 days = 246528     
        startBlock = block.number;
        endBlock = startBlock.add(_block); 
    }

    // @notice Due to changing average of block time
    // this function will allow on adjusting duration of campaign closer to the end 
    function adjustDuration(uint _block) external onlyOwner() {

        require(_block < 308160);  // 4.28*60*24*50 days = 308160     
        require(_block > block.number.sub(startBlock)); // ensure that endBlock is not set in the past
        endBlock = startBlock.add(_block); 
    }

    // @notice It will be called by fallback function whenever ether is sent to it
    // @param  _backer {address} address contributor
    // @return res {bool} true if transaction was successful
    function contribute(address _backer) internal stopInEmergency respectTimeFrame returns(bool res) {
    
        require(currentStep == Step.FundingPreSale || currentStep == Step.FundingPublicSale); // ensure that this is correct step
        require(msg.value >= minInvestETH);   // ensure that min contributions amount is met
          
        uint tokensToSend = msg.value.mul(1e18) / tokenPriceWei; // calculate amount of tokens to send  (add 18 0s first)     
        require(totalTokensSent.add(tokensToSend) < maxCap); // Ensure that max cap hasn't been reached  
            
        Backer storage backer = backers[_backer];
    
        if (backer.weiReceived == 0)      
            backersIndex.push(_backer);
           
        backer.tokensSent = backer.tokensSent.add(tokensToSend); // save contributors tokens to be sent
        backer.weiReceived = backer.weiReceived.add(msg.value);  // save how much was the contribution
        totalTokensSent = totalTokensSent.add(tokensToSend);     // update the total amount of tokens sent
    
        if (Step.FundingPublicSale == currentStep)  // Update the total Ether recived
            ethReceivedMain = ethReceivedMain.add(msg.value);
        else
            ethReceivedPresale = ethReceivedPresale.add(msg.value);     

        if (!token.transfer(_backer, tokensToSend)) 
            revert(); // Transfer tokens   
    
        multisig.transfer(this.balance);   // transfer funds to multisignature wallet             
    
        ReceivedETH(_backer, msg.value, tokensToSend); // Register event
        return true;
    }

    // @notice This function will finalize the sale.
    // It will only execute if predetermined sale time passed or all tokens are sold.
    // it will fail if minimum cap is not reached
    function finalize() external onlyOwner() {

        require(!crowdsaleClosed);        
        // purchasing precise number of tokens might be impractical, thus subtract 1000 tokens so finalizition is possible
        // near the end 
        require(block.number >= endBlock || totalTokensSent >= maxCap.sub(1000));                 
        require(totalTokensSent >= minCap);  // ensure that minimum was reached

        crowdsaleClosed = true;  
        
        if (!token.transfer(team, token.balanceOf(this))) // transfer all remaing tokens to team address
            revert();
        token.unlock();                      
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
    
    // @notice it will allow contributors to get refund in case campaign failed
    function refund() external stopInEmergency returns (bool) {

        require(currentStep == Step.Refunding);         
       
        require(this.balance > 0);  // contract will hold 0 ether at the end of campaign.                                  
                                    // contract needs to be funded through fundContract() 

        Backer storage backer = backers[msg.sender];

        require(backer.weiReceived > 0);  // esnure that user has sent contribution
        require(!backer.refunded);         // ensure that user hasn't been refunded yet

        if (!token.returnTokens(msg.sender, backer.tokensSent)) // transfer tokens
            revert();
        backer.refunded = true;  // save refund status to true
    
        refundCount++;
        totalRefunded = totalRefunded.add(backer.weiReceived);
        msg.sender.transfer(backer.weiReceived);  // send back the contribution 
        RefundETH(msg.sender, backer.weiReceived);
        return true;
    }
}


contract ERC20 {
    uint public totalSupply;
   
    function transfer(address to, uint value) public returns(bool ok);  
    function balanceOf(address who) public view returns(uint);
}


// The token
contract Token is ERC20, Ownable {

    function returnTokens(address _member, uint256 _value) public returns(bool);
    function unlock() public;
}