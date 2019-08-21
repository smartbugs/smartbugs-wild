pragma solidity ^0.4.24;

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {

    /**
    * @dev Multiplies two numbers, throws on overflow.
    */
    function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
        // Gas optimization: this is cheaper than asserting 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
        if (a == 0) {
            return 0;
    }
        c = a * b;
        assert(c / a == b);
        return c;
    }

    /**
    * @dev Integer division of two numbers, truncating the quotient.
    */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // assert(b > 0); // Solidity automatically throws when dividing by 0
        // uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return a / b;
    }

    /**
    * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
    */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    /**
    * @dev Adds two numbers, throws on overflow.
    */
    function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
        c = a + b;
        assert(c >= a);
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
    constructor() public {
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
   * @param _newOwner The address to transfer ownership to.
   */
    function transferOwnership(address _newOwner) public onlyOwner {
        _transferOwnership(_newOwner);
    }

  /**
   * @dev Transfers control of the contract to a newOwner.
   * @param _newOwner The address to transfer ownership to.
   */
    function _transferOwnership(address _newOwner) internal {
        require(_newOwner != address(0x0));
        emit OwnershipTransferred(owner, _newOwner);
        owner = _newOwner;
    }
}

/**
 * @title ERC20 interface
 */
contract AbstractERC20 {
    uint256 public totalSupply;
    function balanceOf(address _owner) public constant returns (uint256 value);
    function transfer(address _to, uint256 _value) public returns (bool _success);
    function allowance(address owner, address spender) public constant returns (uint256 _value);
    function transferFrom(address from, address to, uint256 value) public returns (bool _success);
    function approve(address spender, uint256 value) public returns (bool _success);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
}

contract LiquidToken is Ownable, AbstractERC20 {
    
    using SafeMath for uint256;

    string public name;
    string public symbol;
    uint8 public decimals;
    
    address public teamWallet;
    address public advisorsWallet;
    address public founderWallet;
    address public bountyWallet;
    
    mapping (address => uint256) public balances;
    /// The transfer allowances
    mapping (address => mapping (address => uint256)) public allowed;
    
    mapping(address => bool) public isTeamOrAdvisorsOrFounder;

    event Burn(address indexed burner, uint256 value);
    
    constructor() public {
    
        name = "Liquid";
        symbol = "LIQUID";
        decimals = 18;
        totalSupply = 58e6 * 10**18;    // 58 million tokens
        owner = msg.sender;
        balances[owner] = totalSupply;
        emit Transfer(0x0, owner, totalSupply);
    }

    /**
    * @dev Check balance of given account address
    * @param owner The address account whose balance you want to know
    * @return balance of the account
    */
    function balanceOf(address owner) public view returns (uint256){
        return balances[owner];
    }

    /**
    * @dev transfer token for a specified address (written due to backward compatibility)
    * @param to address to which token is transferred
    * @param value amount of tokens to transfer
    * return bool true=> transfer is succesful
    */
    function transfer(address to, uint256 value) public returns (bool) {

        require(to != address(0x0));
        require(value <= balances[msg.sender]);
        balances[msg.sender] = balances[msg.sender].sub(value);
        balances[to] = balances[to].add(value);
        emit Transfer(msg.sender, to, value);
        return true;
    }

    /**
    * @dev Transfer tokens from one address to another
    * @param from address from which token is transferred 
    * @param to address to which token is transferred
    * @param value amount of tokens to transfer
    * @return bool true=> transfer is succesful
    */
    function transferFrom(address from, address to, uint256 value) public returns (bool) {
        require(to != address(0x0));
        require(value <= balances[from]);
        require(value <= allowed[from][msg.sender]);
        balances[from] = balances[from].sub(value);
        allowed[from][msg.sender] = allowed[from][msg.sender].sub(value); 
        balances[to] = balances[to].add(value);
        emit Transfer(from, to, value);
        return true;
    }

    /**
    * @dev Approve function will delegate spender to spent tokens on msg.sender behalf
    * @param spender ddress which is delegated
    * @param value tokens amount which are delegated
    * @return bool true=> approve is succesful
    */
    function approve(address spender, uint256 value) public returns (bool) {
        allowed[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }

    /**
    * @dev it will check amount of token delegated to spender by owner
    * @param owner the address which allows someone to spend fund on his behalf
    * @param spender address which is delegated
    * @return return uint256 amount of tokens left with delegator
    */
    function allowance(address owner, address spender) public view returns (uint256) {
        return allowed[owner][spender];
    }

    /**
    * @dev increment the spender delegated tokens
    * @param spender address which is delegated
    * @param valueToAdd tokens amount to increment
    * @return bool true=> operation is succesful
    */
    function increaseApproval(address spender, uint valueToAdd) public returns (bool) {
        allowed[msg.sender][spender] = allowed[msg.sender][spender].add(valueToAdd);
        emit Approval(msg.sender, spender, allowed[msg.sender][spender]);
        return true;
    }

    /**
    * @dev deccrement the spender delegated tokens
    * @param spender address which is delegated
    * @param valueToSubstract tokens amount to decrement
    * @return bool true=> operation is succesful
    */
    function decreaseApproval(address spender, uint valueToSubstract) public returns (bool) {
        uint oldValue = allowed[msg.sender][spender];
        if (valueToSubstract > oldValue) {
          allowed[msg.sender][spender] = 0;
        } else {
          allowed[msg.sender][spender] = oldValue.sub(valueToSubstract);
        }
        emit Approval(msg.sender, spender, allowed[msg.sender][spender]);
        return true;
    }

    /**
    * @dev Burns a specific amount of tokens.
    * @param _value The amount of token to be burned.
    *
    */
    function burn(address _who, uint256 _value) public onlyOwner {
        // no need to require value <= totalSupply, since that would imply the
        // sender's balance is greater than the totalSupply, which *should* be an assertion failure
        balances[_who] = balances[_who].sub(_value);
        totalSupply = totalSupply.sub(_value);
        emit Burn(_who, _value);
        emit Transfer(_who, address(0), _value);
    }
    
        /**
    * @dev set team wallet, funds of team will be allocated to a account controlled by admin/founder
    * @param _teamWallet address of bounty wallet.
    *
    */
    function setTeamWallet (address _teamWallet) public onlyOwner returns (bool) {
        require(_teamWallet   !=  address(0x0));
        if(teamWallet ==  address(0x0)){  
            teamWallet    =   _teamWallet;
            balances[teamWallet]  =   4e6 * 10**18;
            balances[owner] = balances[owner].sub(balances[teamWallet]);
        }else{
            address oldTeamWallet =   teamWallet;
            teamWallet    =   _teamWallet;
            balances[teamWallet]  =   balances[oldTeamWallet];
        }
        return true;
    }

    /**
    * @dev set AdvisorsWallet, funds of team will be allocated to a account controlled by admin/founder
    * @param _advisorsWallet address of Advisors wallet.
    *
    */
    function setAdvisorsWallet (address _advisorsWallet) public onlyOwner returns (bool) {
        require(_advisorsWallet   !=  address(0x0));
        if(advisorsWallet ==  address(0x0)){  
            advisorsWallet    =   _advisorsWallet;
            balances[advisorsWallet]  =   2e6 * 10**18;
            balances[owner] = balances[owner].sub(balances[teamWallet]);
        }else{
            address oldAdvisorsWallet =   advisorsWallet;
            advisorsWallet    =   _advisorsWallet;
            balances[advisorsWallet]  =   balances[oldAdvisorsWallet];
        }
        return true;
    }

    /**
    * @dev set Founders wallet, funds of team will be allocated to a account controlled by admin/founder
    * @param _founderWallet address of Founder wallet.
    *
    */
    function setFoundersWallet (address _founderWallet) public onlyOwner returns (bool) {
        require(_founderWallet   !=  address(0x0));
        if(founderWallet ==  address(0x0)){  
            founderWallet    =   _founderWallet;
            balances[founderWallet]  =  8e6 * 10**18;
            balances[owner] = balances[owner].sub(balances[founderWallet]);
        }else{
            address oldFounderWallet =   founderWallet;
            founderWallet    =   _founderWallet;
            balances[founderWallet]  =   balances[oldFounderWallet];
        }
        return true;
    }
    /**
    * @dev set bounty wallet
    * @param _bountyWallet address of bounty wallet.
    *
    */
    function setBountyWallet (address _bountyWallet) public onlyOwner returns (bool) {
        require(_bountyWallet   !=  address(0x0));
        if(bountyWallet ==  address(0x0)){  
            bountyWallet    =   _bountyWallet;
            balances[bountyWallet]  =   4e6 * 10**18;
            balances[owner] = balances[owner].sub(balances[bountyWallet]);
        }else{
            address oldBountyWallet =   bountyWallet;
            bountyWallet    =   _bountyWallet;
            balances[bountyWallet]  =   balances[oldBountyWallet];
        }
        return true;
    }

    /**
    * @dev Function to Airdrop tokens from bounty wallet to contributors as long as there are enough balance.
    * @param dests destination address of bounty beneficiary.
    * @param values tokesn for beneficiary.
    * @return number of address airdropped and True if the operation was successful.
    */
    function airdrop(address[] dests, uint256[] values) public onlyOwner returns (uint256, bool) {
        require(dests.length == values.length);
        uint8 i = 0;
        while (i < dests.length && balances[bountyWallet] >= values[i]) {
            balances[bountyWallet]  =   balances[bountyWallet].sub(values[i]);
            balances[dests[i]]  =   balances[dests[i]].add(values[i]);
            i += 1;
        }
        return (i, true);
    }

    /**
    * @dev Function to transferTokensToTeams tokens from Advisor wallet to contributors as long as there are enough balance.
    * @param teamMember destination address of team beneficiary.
    * @param values tokens for beneficiary.
    * @return True if the operation was successful.
    */
    function transferTokensToTeams(address teamMember, uint256 values) public onlyOwner returns (bool) {
        require(teamMember != address(0));
        require (values != 0);
        balances[teamWallet]  =   balances[teamWallet].sub(values);
        balances[teamMember]  =   balances[teamMember].add(values);
        isTeamOrAdvisorsOrFounder[teamMember] = true;
        return true;
    }
     
    /**
    * @dev Function to transferTokensToFounders tokens from Advisor wallet to contributors as long as there are enough balance.
    * @param founder destination address of team beneficiary.
    * @param values tokens for beneficiary.
    * @return True if the operation was successful.
    */
    function transferTokensToFounders(address founder, uint256 values) public onlyOwner returns (bool) {
        require(founder != address(0));
        require (values != 0);
        balances[founderWallet]  =   balances[founderWallet].sub(values);
        balances[founder]  =   balances[founder].add(values);
        isTeamOrAdvisorsOrFounder[founder] = true;
        return true;
    }

    /**
    * @dev Function to transferTokensToAdvisors tokens from Advisor wallet to contributors as long as there are enough balance.
    * @param advisor destination address of team beneficiary.
    * @param values tokens for beneficiary.
    * @return True if the operation was successful.
    */
    function transferTokensToAdvisors(address advisor, uint256 values) public onlyOwner returns (bool) {
        require(advisor != address(0));
        require (values != 0);
        balances[advisorsWallet]  =   balances[advisorsWallet].sub(values);
        balances[advisor]  =   balances[advisor].add(values);
        isTeamOrAdvisorsOrFounder[advisor] = true;
        return true;
    }

}

contract Crowdsale is LiquidToken {
    
    using SafeMath for uint256;

    address public ETHCollector;
    uint256 public tokenCost = 140; //140 cents
    uint256 public ETH_USD; //in cents
    uint256 public saleStartDate;
    uint256 public saleEndDate;
    uint256 public softCap;
    uint256 public hardCap; 
    uint256 public minContribution = 28000; //280$ =280,00 cent
    uint256 public tokensSold;
    uint256 public weiCollected;
    //Number of investors who have received refund
    uint256 public countInvestorsRefunded;
    uint256 public countTotalInvestors;
    // Whether the Crowdsale is paused.
    bool public paused;
    bool public start;
    bool public stop;
    //Set status of refund
    bool public refundStatus;
    
    //Structure to store token sent and wei received by the buyer of tokens
    struct Investor {
        uint256 investorID;
        uint256 weiReceived;
        uint256 tokenSent;
    }
    
    //investors indexed by their ETH address
    mapping(address => Investor) public investors;
    mapping(address => bool) public isinvestor;
    mapping(address => bool) public whitelist;
    //investors indexed by their IDs
    mapping(uint256 => address) public investorList;

    //event to log token supplied
    event TokenSupplied(address beneficiary, uint256 tokens, uint256 value);   
    event RefundedToInvestor(address indexed beneficiary, uint256 weiAmount);
    event NewSaleEndDate(uint256 endTime);
    event StateChanged(bool changed);

    modifier respectTimeFrame() {
        require (start);
        require(!paused);
        require(now >= saleStartDate);
        require(now <= saleEndDate);
       _;
    }

    constructor(address _ETHCollector) public {
        ETHCollector = _ETHCollector;    
        hardCap = 40e6 * 10**18;
        softCap = 2e6 * 10**18;
        //Initially no investor has been refunded
        countInvestorsRefunded = 0;
        //Refund eligible or not
        refundStatus = false;
    }
    
    //transfer ownership with token balance
    function transferOwnership(address _newOwner) public onlyOwner {
        super.transfer(_newOwner, balances[owner]);
        _transferOwnership(_newOwner);
    }

     //function to start sale
    function startSale(uint256 _saleStartDate, uint256 _saleEndDate, uint256 _newETH_USD) public onlyOwner{
       require (_saleStartDate < _saleEndDate);
       require (now <= _saleStartDate);
       assert(!start);
       saleStartDate = _saleStartDate;
       saleEndDate = _saleEndDate;  
       start = true; 
       ETH_USD = _newETH_USD;
    }

    //function to finalize sale
    function finalizeSale() public onlyOwner{
        assert(start);
        //end sale only when tokens is not sold and sale time is over OR,
        //end time is not over and all tokens are sold
        assert(!(tokensSold < hardCap && now < saleEndDate) || (hardCap.sub(tokensSold) <= 1e18));  
        if(!softCapReached()){
            refundStatus = true;
        }
        start = false;
        stop = true;
    }

    /**
    * @dev called by the owner to stopInEmergency , triggers stopped state
    */
    function stopInEmergency() onlyOwner public {
        require(!paused);
        paused = true;
        emit StateChanged(true);
    }

    /**
    * @dev after stopping crowdsale, the contract owner can release the crowdsale
    * 
    */
    function release() onlyOwner public {
        require(paused);
        paused = false;
        emit StateChanged(true);
    }

    //function to set ETH_USD rate in cent. Eg: 1 ETH = 300 USD so we need to pass 300,00 cents
    function setETH_USDRate(uint256 _newETH_USD) public onlyOwner {
        require(_newETH_USD > 0);
        ETH_USD = _newETH_USD;
    }

    //function to change token cost
    function changeTokenCost(uint256 _tokenCost) public onlyOwner {
        require(_tokenCost > 0);
        tokenCost = _tokenCost;
    }

    //funcion to change minContribution
    //_minContribution parameter should be in cent 
    function changeMinContribution(uint256 _minContribution) public onlyOwner {
        require(_minContribution > 0);
        minContribution = _minContribution;
    }

    //function to increase time
    function extendTime(uint256 _newEndSaleDate) onlyOwner public {
        //current time should always be less than endTime+extendedTime
        require(saleEndDate < _newEndSaleDate);
        require(_newEndSaleDate != 0);
        saleEndDate = _newEndSaleDate;
        emit NewSaleEndDate(saleEndDate);
    }
    
    
    // function to add single whitelist
    function addWhitelistAddress(address addr) public onlyOwner{
        require (!whitelist[addr]); 
        require(addr != address(0x0));
        // owner approves buyers by address when they pass the whitelisting procedure
        whitelist[addr] = true;
    }
    
    /**
    * @dev add addresses to the whitelist
    * @return true if at least one address was added to the whitelist,
    * false if all addresses were already in the whitelist
    */
    function addWhitelistAddresses(address[] _addrs) public onlyOwner{
        for (uint256 i = 0; i < _addrs.length; i++) {
            addWhitelistAddress(_addrs[i]);        
        }
    }

    function transfer(address to, uint256 value) public returns (bool){
        if(isinvestor[msg.sender]){
            //sale has ended
            require(stop);
            super.transfer(to, value);
        }
        
        else if(isTeamOrAdvisorsOrFounder[msg.sender]){
            //180 days = 6 months
            require(now > saleEndDate.add(180 days));
            super.transfer(to, value);
        }
        else {
            super.transfer(to, value);
        }
    }

    function transferFrom(address from, address to, uint256 value) public returns (bool){
        if(isinvestor[from]){
            //sale has ended
            require(stop);
            super.transferFrom(from, to, value);
        } 
         else if(isTeamOrAdvisorsOrFounder[from]){
            //180 days = 6 months
            require(now > saleEndDate.add(180 days));
            super.transferFrom(from,to, value);
        } 
        else {
           super.transferFrom(from, to, value);
        }
    }
    
    //function to buy tokens
    function buyTokens (address beneficiary) public payable respectTimeFrame {
        // only approved buyers can call this function
        require(whitelist[beneficiary]);
        // No contributions below the minimum
        require(msg.value >= getMinContributionInWei());

        uint256 tokenToTransfer = getTokens(msg.value);

        // Check if the CrowdSale hard cap will be exceeded
        require(tokensSold.add(tokenToTransfer) <= hardCap);
        tokensSold = tokensSold.add(tokenToTransfer);

        //initializing structure for the address of the beneficiary
        Investor storage investorStruct = investors[beneficiary];

        //Update investor's balance
        investorStruct.tokenSent = investorStruct.tokenSent.add(tokenToTransfer);
        investorStruct.weiReceived = investorStruct.weiReceived.add(msg.value);

        //If it is a new investor, then create a new id
        if(investorStruct.investorID == 0){
            countTotalInvestors++;
            investorStruct.investorID = countTotalInvestors;
            investorList[countTotalInvestors] = beneficiary;
        }

        isinvestor[beneficiary] = true;
        ETHCollector.transfer(msg.value);
        
        weiCollected = weiCollected.add(msg.value);
        
        balances[owner] = balances[owner].sub(tokenToTransfer);
        balances[beneficiary] = balances[beneficiary].add(tokenToTransfer);

        emit TokenSupplied(beneficiary, tokenToTransfer, msg.value);
    }

    /**
    * @dev payable function to accept ether.
    *
    */
    function () external payable  {
        buyTokens(msg.sender);
    }

    /*
    * Refund the investors in case target of crowdsale not achieved
    */
    function refund() public onlyOwner {
        assert(refundStatus);
        uint256 batchSize = countInvestorsRefunded.add(50) < countTotalInvestors ? countInvestorsRefunded.add(50): countTotalInvestors;
        for(uint256 i = countInvestorsRefunded.add(1); i <= batchSize; i++){
            address investorAddress = investorList[i];
            Investor storage investorStruct = investors[investorAddress];
            //return everything
            investorAddress.transfer(investorStruct.weiReceived);
            //burn investor tokens and total supply isTeamOrAdvisorsOrFounder
            burn(investorAddress, investorStruct.tokenSent);
            //set everything to zero after transfer successful
            investorStruct.weiReceived = 0;
            investorStruct.tokenSent = 0;
        }
        //Update the number of investors that have recieved refund
        countInvestorsRefunded = batchSize;
    }

    /*
    * Failsafe drain
    */
    function drain() public onlyOwner {
        ETHCollector.transfer(address(this).balance);
    }

    /*
    * Function to add Ether in the contract 
    */
    function fundContractForRefund()public payable{
    }

    /**
    *
    *getter functions
    *
    *
    */
    //function to return the number of tokens sent to investor
    
    function getTokens(uint256 weiReceived) internal view returns(uint256){
        uint256 tokens;
        //Token Sale Stage 1 = Dates Start 10/15/18 End 10/31/18 35% discount
        if(now >= saleStartDate && now <= saleStartDate.add(10 days)){
            tokens = getTokensForWeiReceived(weiReceived);
            tokens = tokens.mul(100 + 60) / 100;
        //Token Sale Stage 2 = Dates Start 11/1/18 End 11/15/18 20% discount    
        }else if (now > saleStartDate.add(10 days) && now <= saleStartDate.add(25 days)){
            tokens = getTokensForWeiReceived(weiReceived);
            tokens = tokens.mul(100 + 50) / 100;
        //Token Sale Stage 3 = Dates Start 11/16/18 End 11/30/18 No discount    
        }else if (now > saleStartDate.add(25 days)  && now <= saleEndDate){
            tokens = getTokensForWeiReceived(weiReceived);
            tokens = tokens.mul(100 + 30) / 100;
        }
        return tokens;
    }

    //function to get tokens number for eth send
    function getTokensForWeiReceived(uint256 _weiAmount) internal view returns (uint256) {
        return _weiAmount.mul(ETH_USD).div(tokenCost);
    }

    //function to check softcap reached or not
    function softCapReached() view public returns(bool) {
        return tokensSold >= softCap;
    }

    //getSaleStage will return current sale stage
    function getSaleStage() view public returns(uint8){
        if(now >= saleStartDate && now <= saleStartDate.add(10 days)){
            return 1;
        }else if(now > saleStartDate.add(10 days) && now <= saleStartDate.add(25 days)){
            return 2;
        }else if (now > saleStartDate.add(25 days)  && now <= saleEndDate){
            return 3;
        }
    }
    
    //get minimum contribution in wei
     function getMinContributionInWei() public view returns(uint256){
        return (minContribution.mul(1e18)).div(ETH_USD);
    }
    
    //is address whitelisted
    function isAddressWhitelisted(address addr) public view returns(bool){
        return whitelist[addr];
    }
}