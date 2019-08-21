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


/**
* @title Ownable
* @dev The Ownable contract has an owner address, and provides basic authorization control
* functions, this simplifies the implementation of "user permissions".
*/
contract Ownable {
    address public owner;
    
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
    * @dev The Ownable constructor sets the original `owner` of the contract to the sender
    * account.
    */
    function Ownable() public {	
        owner = msg.sender;
    }

    /**
    * @dev Throws if called by any account other than the owner.
    */
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    /**
    * @dev Allows the current owner to transfer control of the contract to a newOwner.
    * @param newOwner The address to transfer ownership to.
    */
    function transferOwnership(address newOwner) onlyOwner public {
        require(newOwner != address(0));
        OwnershipTransferred(owner, newOwner);
        owner = newOwner;
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

    // @notice Called by the owner in emergency, triggers stopped state
    function emergencyStop() external onlyOwner {
        stopped = true;
    }

    /// @notice Called by the owner to end of emergency, returns to normal state
    function release() external onlyOwner onlyInEmergency {
        stopped = false;
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


// @notice Migration Agent interface

contract MigrationAgent {
    function migrateFrom(address _from, uint256 _value) public;
}


// @notice  Whitelist interface which will hold whitelisted users
contract WhiteList is Ownable {

    function isWhiteListed(address _user) external view returns (bool);        
}

// @notice contract to control vesting schedule for company and team tokens
contract Vesting is Ownable {

    using SafeMath for uint;

    uint public teamTokensInitial = 2e25;      // max tokens amount for the team 20,000,000
    uint public teamTokensCurrent = 0;         // to keep record of distributed tokens so far to the team
    uint public companyTokensInitial = 15e24;  // max tokens amount for the company 15,000,000
    uint public companyTokensCurrent = 0;      // to keep record of distributed tokens so far to the company
    Token public token;                        // token contract
    uint public dateICOEnded;                  // date when ICO ended updated from the finalizeSale() function
    uint public dateProductCompleted;          // date when product has been completed


    event LogTeamTokensTransferred(address indexed receipient, uint amouontOfTokens);
    event LogCompanyTokensTransferred(address indexed receipient, uint amouontOfTokens);


    // @notice set the handle of the token contract
    // @param _token  {Token} address of the token contract
    // @return  {bool} true if successful
    function setToken(Token _token) public onlyOwner() returns(bool) {
        require (token == address(0));  
        token = _token;
        return true;
    }

    // @notice set the product completion date for release of dev tokens
    function setProductCompletionDate() external onlyOwner() {
        dateProductCompleted = now;
    }

    // @notice  to release tokens of the team according to vesting schedule
    // @param _recipient {address} of the recipient of token transfer
    // @param _tokensToTransfer {uint} amount of tokens to transfer
    function transferTeamTokens(address _recipient, uint _tokensToTransfer) external onlyOwner() {

        require(_recipient != 0);       
        require(now >= 1533081600);  // before Aug 1, 2018 00:00 GMT don't allow on distribution tokens to the team.

        require(dateProductCompleted > 0);
        if (now < dateProductCompleted + 1 years)            // first year after product release
            require(teamTokensCurrent.add(_tokensToTransfer) <= (teamTokensInitial * 30) / 100);
        else if (now < dateProductCompleted + 2 years)       // second year after product release
            require(teamTokensCurrent.add(_tokensToTransfer) <= (teamTokensInitial * 60) / 100);
        else if (now < dateProductCompleted + 3 years)       // third year after product release
            require(teamTokensCurrent.add(_tokensToTransfer) <= (teamTokensInitial * 80) / 100);
        else                                                 // fourth year after product release
            require(teamTokensCurrent.add(_tokensToTransfer) <= teamTokensInitial);

        teamTokensCurrent = teamTokensCurrent.add(_tokensToTransfer);  // update released token amount
        
        if (!token.transfer(_recipient, _tokensToTransfer))
                revert();

        LogTeamTokensTransferred(_recipient, _tokensToTransfer);
    }

    // @notice  to release tokens of the company according to vesting schedule
    // @param _recipient {address} of the recipient of token transfer
    // @param _tokensToTransfer {uint} amount of tokens to transfer
    function transferCompanyTokens(address _recipient, uint _tokensToTransfer) external onlyOwner() {

        require(_recipient != 0);
        require(dateICOEnded > 0);       

        if (now < dateICOEnded + 1 years)   // first year
            require(companyTokensCurrent.add(_tokensToTransfer) <= (companyTokensInitial * 50) / 100);
        else if (now < dateICOEnded + 2 years) // second year
            require(companyTokensCurrent.add(_tokensToTransfer) <= (companyTokensInitial * 75) / 100);
        else                                    // third year                                                                                   
            require(companyTokensCurrent.add(_tokensToTransfer) <= companyTokensInitial);

        companyTokensCurrent = companyTokensCurrent.add(_tokensToTransfer);  // update released token amount

        if (!token.transfer(_recipient, _tokensToTransfer))
                revert();
        LogCompanyTokensTransferred(_recipient, _tokensToTransfer);
    }
}

// Presale Smart Contract
// This smart contract collects ETH and in return sends tokens to the backers.
contract CrowdSale is  Pausable, Vesting {

    using SafeMath for uint;

    struct Backer {
        uint weiReceivedOne; // amount of ETH contributed during first presale
        uint weiReceivedTwo;  // amount of ETH contributed during second presale
        uint weiReceivedMain; // amount of ETH contributed during main sale
        uint tokensSent; // amount of tokens  sent
        bool claimed;
        bool refunded;
    }

    address public multisig; // Multisig contract that will receive the ETH
    uint public ethReceivedPresaleOne; // Amount of ETH received in presale one
    uint public ethReceivedPresaleTwo; // Amount of ETH received in presale two
    uint public ethReceiveMainSale; // Amount of ETH received in main sale
    uint public totalTokensSold; // Number of tokens sold to contributors in all campaigns
    uint public startBlock; // Presale start block
    uint public endBlock; // Presale end block

    uint public minInvestment; // Minimum amount to invest    
    WhiteList public whiteList; // whitelist contract
    uint public dollarPerEtherRatio; // dollar to ether ratio set at the beginning of main sale
    uint public returnPercentage;  // percentage to be returned from first presale in case campaign is cancelled
    Step public currentStep;  // to move through campaigns and set default values
    uint public minCapTokens;  // minimum amount of tokens to raise for campaign to be successful

    mapping(address => Backer) public backers; //backer list
    address[] public backersIndex;  // to be able to iterate through backer list
    uint public maxCapEth;  // max cap eth
    uint public maxCapTokens; // max cap tokens
    uint public claimCount;  // number of contributors claiming tokens
    uint public refundCount;  // number of contributors receiving refunds
    uint public totalClaimed;  // total of tokens claimed
    uint public totalRefunded;  // total of tokens refunded
    mapping(address => uint) public claimed; // tokens claimed by contributors
    mapping(address => uint) public refunded; // tokens refunded to contributors



    // @notice to set and determine steps of crowdsale
    enum Step {
        FundingPresaleOne,  // presale 1 mode
        FundingPresaleTwo,  // presale 2 mode
        FundingMainSale,    // main ICO
        Refunding           // refunding
    }


    // @notice to verify if action is not performed out of the campaign range
    modifier respectTimeFrame() {
        if ((block.number < startBlock) || (block.number > endBlock))
            revert();
        _;
    }

    // Events
    event ReceivedETH(address indexed backer, Step indexed step, uint amount);
    event TokensClaimed(address indexed backer, uint count);
    event Refunded(address indexed backer, uint amount);



    // CrowdFunding   {constructor}
    // @notice fired when contract is crated. Initializes all needed variables for presale 1.
    function CrowdSale(WhiteList _whiteList, address _multisig) public {

        require(_whiteList != address(0x0));
        multisig = _multisig;
        minInvestment = 10 ether;
        maxCapEth = 9000 ether;
        startBlock = 0; // Starting block of the campaign
        endBlock = 0; // Ending block of the campaign
        currentStep = Step.FundingPresaleOne;  // initialize to first presale
        whiteList = _whiteList; // address of white list contract
        minCapTokens = 6.5e24;  // 10% of maxCapTokens
    }


    // @notice return number of  contributors for all campaigns
    // @return {uint} number of contributors in each campaign and total number
    function numberOfBackers() public view returns(uint, uint, uint, uint) {

        uint numOfBackersOne;
        uint numOfBackersTwo;
        uint numOfBackersMain;

        for (uint i = 0; i < backersIndex.length; i++) {
            Backer storage backer = backers[backersIndex[i]];
            if (backer.weiReceivedOne > 0)
                numOfBackersOne ++;
            if (backer.weiReceivedTwo > 0)
                numOfBackersTwo ++;
            if (backer.weiReceivedMain > 0)
                numOfBackersMain ++;
            }
        return ( numOfBackersOne, numOfBackersTwo, numOfBackersMain, backersIndex.length);
    }



    // @notice advances the step of campaign to presale 2
    // contract is deployed in presale 1 mode
    function setPresaleTwo() public onlyOwner() {
        currentStep = Step.FundingPresaleTwo;
        maxCapEth = 60000 ether;
        minInvestment = 5 ether;
    }

    // @notice advances step of campaign to main sale
    // @param _ratio   - it will be amount of dollars for one ether with two decimals.
    // two decimals will be passed as next sets of digits. eg. $300.25 will be passed as 30025
    function setMainSale(uint _ratio) public onlyOwner() {

        require(_ratio > 0);
        currentStep = Step.FundingMainSale;
        dollarPerEtherRatio = _ratio;
        maxCapTokens = 65e24;
        minInvestment = 1 ether / 5;  // 0.2 eth
        totalTokensSold = (dollarPerEtherRatio * ethReceivedPresaleOne) / 48;  // determine amount of tokens to send from first presale
        totalTokensSold += (dollarPerEtherRatio * ethReceivedPresaleTwo) / 58;  // determine amount of tokens to send from second presale and total it.
    }


    // @notice to populate website with status of the sale
    function returnWebsiteData() external view returns(uint, uint, uint, uint, uint, uint, uint, uint,  bool) {

        return (startBlock, endBlock, backersIndex.length, ethReceivedPresaleOne, ethReceivedPresaleTwo, ethReceiveMainSale, maxCapTokens,   minInvestment,  stopped);
    }


    // {fallback function}
    // @notice It will call internal function which handles allocation of Ether and calculates tokens.
    function () public payable {
        contribute(msg.sender);
    }

    // @notice in case refunds are needed, money can be returned to the contract
    // @param _returnPercentage {uint} percentage of return in respect to first presale. e.g 75% would be passed as 75
    function fundContract(uint _returnPercentage) external payable onlyOwner() {

        require(_returnPercentage > 0);
        require(msg.value == (ethReceivedPresaleOne.mul(_returnPercentage) / 100) + ethReceivedPresaleTwo + ethReceiveMainSale);
        returnPercentage = _returnPercentage;
        currentStep = Step.Refunding;
    }

    // @notice It will be called by owner to start the sale
    // block numbers will be calculated based on current block time average.    
    function start() external onlyOwner() {
        startBlock = block.number;
        endBlock = startBlock + 383904; // 4.3*60*24*62 days
    }

    // @notice Due to changing average of block time
    // this function will allow on adjusting duration of campaign closer to the end
    // allow adjusting campaign length to 70 days, equivalent of 433440 blocks at 4.3 blocks per minute
    // @param _block  number of blocks representing duration
    function adjustDuration(uint _block) external onlyOwner() {

        require(_block <= 433440);  // 4.3×60×24×70 days 
        require(_block > block.number.sub(startBlock)); // ensure that endBlock is not set in the past
        endBlock = startBlock.add(_block);
    }


    // @notice It will be called by fallback function whenever ether is sent to it
    // @param  _contributor {address} address of contributor
    // @return res {bool} true if transaction was successful

    function contribute(address _contributor) internal stopInEmergency respectTimeFrame returns(bool res) {


        require(whiteList.isWhiteListed(_contributor));  // ensure that user is whitelisted
        Backer storage backer = backers[_contributor];
        require (msg.value >= minInvestment);  // ensure that min contributions amount is met

        if (backer.weiReceivedOne == 0 && backer.weiReceivedTwo == 0 && backer.weiReceivedMain == 0)
            backersIndex.push(_contributor);

        if (currentStep == Step.FundingPresaleOne) {          
            backer.weiReceivedOne = backer.weiReceivedOne.add(msg.value);
            ethReceivedPresaleOne = ethReceivedPresaleOne.add(msg.value); // Update the total Ether received in presale 1
            require(ethReceivedPresaleOne <= maxCapEth);  // ensure that max cap hasn't been reached
        }else if (currentStep == Step.FundingPresaleTwo) {           
            backer.weiReceivedTwo = backer.weiReceivedTwo.add(msg.value);
            ethReceivedPresaleTwo = ethReceivedPresaleTwo.add(msg.value);  // Update the total Ether received in presale 2
            require(ethReceivedPresaleOne + ethReceivedPresaleTwo <= maxCapEth);  // ensure that max cap hasn't been reached
        }else if (currentStep == Step.FundingMainSale) {
            backer.weiReceivedMain = backer.weiReceivedMain.add(msg.value);
            ethReceiveMainSale = ethReceiveMainSale.add(msg.value);  // Update the total Ether received in presale 2
            uint tokensToSend = dollarPerEtherRatio.mul(msg.value) / 62;  // calculate amount of tokens to send for this user 
            totalTokensSold += tokensToSend;
            require(totalTokensSold <= maxCapTokens);  // ensure that max cap hasn't been reached
        }
        multisig.transfer(msg.value);  // send money to multisignature wallet

        ReceivedETH(_contributor, currentStep, msg.value); // Register event
        return true;
    }


    // @notice This function will finalize the sale.
    // It will only execute if predetermined sale time passed or all tokens were sold

    function finalizeSale() external onlyOwner() {
        require(dateICOEnded == 0);
        require(currentStep == Step.FundingMainSale);
        // purchasing precise number of tokens might be impractical, thus subtract 1000 tokens so finalization is possible
        // near the end
        require(block.number >= endBlock || totalTokensSold >= maxCapTokens.sub(1000));
        require(totalTokensSold >= minCapTokens);
        
        companyTokensInitial += maxCapTokens - totalTokensSold; // allocate unsold tokens to the company        
        dateICOEnded = now;
        token.unlock();
    }


    // @notice this function can be used by owner to update contribution address in case of using address from exchange or incompatible wallet
    // @param _contributorOld - old contributor address
    // @param _contributorNew - new contributor address
    function updateContributorAddress(address _contributorOld, address _contributorNew) public onlyOwner() {

        Backer storage backerOld = backers[_contributorOld];
        Backer storage backerNew = backers[_contributorNew];

        require(backerOld.weiReceivedOne > 0 || backerOld.weiReceivedTwo > 0 || backerOld.weiReceivedMain > 0); // make sure that contribution has been made to the old address
        require(backerNew.weiReceivedOne == 0 && backerNew.weiReceivedTwo == 0 && backerNew.weiReceivedMain == 0); // make sure that existing address is not used
        require(backerOld.claimed == false && backerOld.refunded == false);  // ensure that contributor hasn't be refunded or claimed the tokens yet

        // invalidate old address
        backerOld.claimed = true;
        backerOld.refunded = true;

        // initialize new address
        backerNew.weiReceivedOne = backerOld.weiReceivedOne;
        backerNew.weiReceivedTwo = backerOld.weiReceivedTwo;
        backerNew.weiReceivedMain = backerOld.weiReceivedMain;
        backersIndex.push(_contributorNew);
    }

    // @notice called to send tokens to contributors after ICO.
    // @param _backer {address} address of beneficiary
    // @return true if successful
    function claimTokensForUser(address _backer) internal returns(bool) {        

        require(dateICOEnded > 0); // allow on claiming of tokens if ICO was successful             

        Backer storage backer = backers[_backer];

        require (!backer.refunded); // if refunded, don't allow to claim tokens
        require (!backer.claimed); // if tokens claimed, don't allow to claim again
        require (backer.weiReceivedOne > 0 || backer.weiReceivedTwo > 0 || backer.weiReceivedMain > 0);   // only continue if there is any contribution

        claimCount++;
        uint tokensToSend = (dollarPerEtherRatio * backer.weiReceivedOne) / 48;  // determine amount of tokens to send from first presale
        tokensToSend = tokensToSend + (dollarPerEtherRatio * backer.weiReceivedTwo) / 58;  // determine amount of tokens to send from second presale
        tokensToSend = tokensToSend + (dollarPerEtherRatio * backer.weiReceivedMain) / 62;  // determine amount of tokens to send from main sale

        claimed[_backer] = tokensToSend;  // save claimed tokens
        backer.claimed = true;
        backer.tokensSent = tokensToSend;
        totalClaimed += tokensToSend;

        if (!token.transfer(_backer, tokensToSend))
            revert(); // send claimed tokens to contributor account

        TokensClaimed(_backer,tokensToSend);
        return true;
    }


    // @notice contributors can claim tokens after public ICO is finished
    // tokens are only claimable when token address is available.

    function claimTokens() external {
        claimTokensForUser(msg.sender);
    }


    // @notice this function can be called by admin to claim user's token in case of difficulties
    // @param _backer {address} user address to claim tokens for
    function adminClaimTokenForUser(address _backer) external onlyOwner() {
        claimTokensForUser(_backer);
    }

    // @notice allow refund when ICO failed
    // In such a case contract will need to be funded.
    // Until contract is funded this function will throw

    function refund() external {

        require(currentStep == Step.Refunding);                                                          
        require(totalTokensSold < maxCapTokens/2); // ensure that refund is impossible when more than half of the tokens are sold

        Backer storage backer = backers[msg.sender];

        require (!backer.claimed); // check if tokens have been allocated already
        require (!backer.refunded); // check if user has been already refunded

        uint totalEtherReceived = ((backer.weiReceivedOne * returnPercentage) / 100) + backer.weiReceivedTwo + backer.weiReceivedMain;  // return only e.g. 75% from presale one.
        assert(totalEtherReceived > 0);

        backer.refunded = true; // mark contributor as refunded.
        totalRefunded += totalEtherReceived;
        refundCount ++;
        refunded[msg.sender] = totalRefunded;

        msg.sender.transfer(totalEtherReceived);  // refund contribution
        Refunded(msg.sender, totalEtherReceived); // log event
    }



    // @notice refund non compliant member 
    // @param _contributor {address} of refunded contributor
    function refundNonCompliant(address _contributor) payable external onlyOwner() {
    
        Backer storage backer = backers[_contributor];

        require (!backer.claimed); // check if tokens have been allocated already
        require (!backer.refunded); // check if user has been already refunded
        backer.refunded = true; // mark contributor as refunded.            

        uint totalEtherReceived = backer.weiReceivedOne + backer.weiReceivedTwo + backer.weiReceivedMain;

        require(msg.value == totalEtherReceived); // ensure that exact amount is sent
        assert(totalEtherReceived > 0);

        //adjust amounts received
        ethReceivedPresaleOne -= backer.weiReceivedOne;
        ethReceivedPresaleTwo -= backer.weiReceivedTwo;
        ethReceiveMainSale -= backer.weiReceivedMain;
        
        totalRefunded += totalEtherReceived;
        refundCount ++;
        refunded[_contributor] = totalRefunded;      

        uint tokensToSend = (dollarPerEtherRatio * backer.weiReceivedOne) / 48;  // determine amount of tokens to send from first presale
        tokensToSend = tokensToSend + (dollarPerEtherRatio * backer.weiReceivedTwo) / 58;  // determine amount of tokens to send from second presale
        tokensToSend = tokensToSend + (dollarPerEtherRatio * backer.weiReceivedMain) / 62;  // determine amount of tokens to send from main sale

        if(dateICOEnded == 0) {
            totalTokensSold -= tokensToSend;
        } else {
            companyTokensInitial += tokensToSend;
        }

        _contributor.transfer(totalEtherReceived);  // refund contribution
        Refunded(_contributor, totalEtherReceived); // log event
    }

    // @notice Failsafe drain to individual wallet
    function drain() external onlyOwner() {
        multisig.transfer(this.balance);

    }

    // @notice Failsafe token transfer
    function tokenDrain() external onlyOwner() {
    if (block.number > endBlock) {
        if (!token.transfer(multisig, token.balanceOf(this)))
                revert();
        }
    }
}





// @notice The token contract
contract Token is ERC20,  Ownable {

    using SafeMath for uint;
    // Public variables of the token
    string public name;
    string public symbol;
    uint8 public decimals; // How many decimals to show.
    string public version = "v0.1";
    uint public totalSupply;
    uint public initialSupply;
    bool public locked;
    address public crowdSaleAddress;
    address public migrationMaster;
    address public migrationAgent;
    uint256 public totalMigrated;
    address public authorized;


    mapping(address => uint) public balances;
    mapping(address => mapping(address => uint)) public allowed;

    // @notice tokens are locked during the ICO. Allow transfer of tokens after ICO.
    modifier onlyUnlocked() {
        if (msg.sender != crowdSaleAddress && locked)
            revert();
        _;
    }


    // @Notice allow minting of tokens only by authorized users
    modifier onlyAuthorized() {
        if (msg.sender != owner && msg.sender != authorized )
            revert();
        _;
    }


    // @notice The Token constructor
    // @param _crowdSaleAddress {address} address of crowdsale contract
    // @param _migrationMaster {address} address of authorized migration person
    function Token(address _crowdSaleAddress) public {

        require(_crowdSaleAddress != 0);

        locked = true;  // Lock the transfer function during the crowdsale
        initialSupply = 1e26;
        totalSupply = initialSupply;
        name = "Narrative"; // Set the name for display purposes
        symbol = "NRV"; // Set the symbol for display purposes
        decimals = 18; // Amount of decimals for display purposes
        crowdSaleAddress = _crowdSaleAddress;
        balances[crowdSaleAddress] = initialSupply;
        migrationMaster = owner;
        authorized = _crowdSaleAddress;
    }

    // @notice unlock tokens for trading
    function unlock() public onlyAuthorized {
        locked = false;
    }

    // @notice lock tokens in case of problems
    function lock() public onlyAuthorized {
        locked = true;
    }

    // @notice set authorized party
    // @param _authorized {address} of an individual to get authorization
    function setAuthorized(address _authorized) public onlyOwner {

        authorized = _authorized;
    }


    // Token migration support: as implemented by Golem
    event Migrate(address indexed _from, address indexed _to, uint256 _value);

    /// @notice Migrate tokens to the new token contract.
    /// @dev Required state: Operational Migration
    /// @param _value The amount of token to be migrated
    function migrate(uint256 _value)  external {
        // Abort if not in Operational Migration state.

        require (migrationAgent != 0);
        require(_value > 0);
        balances[msg.sender] = balances[msg.sender].sub(_value);
        totalSupply = totalSupply.sub(_value);
        totalMigrated = totalMigrated.add(_value);
        MigrationAgent(migrationAgent).migrateFrom(msg.sender, _value);
        Migrate(msg.sender, migrationAgent, _value);
    }

    /// @notice Set address of migration target contract and enable migration
    /// process.
    /// @dev Required state: Operational Normal
    /// @dev State transition: -> Operational Migration
    /// @param _agent The address of the MigrationAgent contract
    function setMigrationAgent(address _agent)  external {
        // Abort if not in Operational Normal state.

        require(migrationAgent == 0);
        require(msg.sender == migrationMaster);
        migrationAgent = _agent;
    }

    function setMigrationMaster(address _master) external {
        require(msg.sender == migrationMaster);
        require(_master != 0);
        migrationMaster = _master;
    }

    // @notice mint new tokens with max of 197.5 millions
    // @param _target {address} of receipt
    // @param _mintedAmount {uint} amount of tokens to be minted
    // @return  {bool} true if successful
    function mint(address _target, uint256 _mintedAmount) public onlyAuthorized() returns(bool) {
        assert(totalSupply.add(_mintedAmount) <= 1975e23);  // ensure that max amount ever minted should not exceed 197.5 million tokens with 18 decimals
        balances[_target] = balances[_target].add(_mintedAmount);
        totalSupply = totalSupply.add(_mintedAmount);
        Transfer(0, _target, _mintedAmount);
        return true;
    }

    // @notice transfer tokens to given address
    // @param _to {address} address or recipient
    // @param _value {uint} amount to transfer
    // @return  {bool} true if successful
    function transfer(address _to, uint _value) public onlyUnlocked returns(bool) {

        require(_to != address(0));
        require(balances[msg.sender] >= _value);
        balances[msg.sender] -= _value;
        balances[_to] += _value;
        Transfer(msg.sender, _to, _value);
        return true;
    }


    // @notice transfer tokens from given address to another address
    // @param _from {address} from whom tokens are transferred
    // @param _to {address} to whom tokens are transferred
    // @param _value {uint} amount of tokens to transfer
    // @return  {bool} true if successful
    function transferFrom(address _from, address _to, uint256 _value) public onlyUnlocked returns(bool success) {

        require(_to != address(0));
        require(balances[_from] >= _value); // Check if the sender has enough
        require(_value <= allowed[_from][msg.sender]); // Check if allowed is greater or equal
        balances[_from] -= _value; // Subtract from the sender
        balances[_to] += _value; // Add the same to the recipient
        allowed[_from][msg.sender] -= _value;  // adjust allowed
        Transfer(_from, _to, _value);
        return true;
    }

    // @notice to query balance of account
    // @return _owner {address} address of user to query balance
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


    // @notice to query of allowance of one user to the other
    // @param _owner {address} of the owner of the account
    // @param _spender {address} of the spender of the account
    // @return remaining {uint} amount of remaining allowance
    function allowance(address _owner, address _spender) public view returns(uint remaining) {
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