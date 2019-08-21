pragma solidity ^ 0.4 .11;

contract SafeMath {
    function safeMul(uint a, uint b) internal returns(uint) {
        uint c = a * b;
        assert(a == 0 || c / a == b);
        return c;
    }

    function safeDiv(uint a, uint b) internal returns(uint) {
        assert(b > 0);
        uint c = a / b;
        assert(a == b * c + a % b);
        return c;
    }

    function safeSub(uint a, uint b) internal returns(uint) {
        assert(b <= a);
        return a - b;
    }
    
    function safeAdd(uint a, uint b) internal returns(uint) {
        uint c = a + b;
        assert(c >= a && c >= b);
        return c;
    }

}

contract ERC20 {
    uint public totalSupply;

    function balanceOf(address who) constant returns(uint);

    function allowance(address owner, address spender) constant returns(uint);

    function transfer(address to, uint value) returns(bool ok);

    function transferFrom(address from, address to, uint value) returns(bool ok);

    function approve(address spender, uint value) returns(bool ok);

    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);
}


contract Ownable {
    address public owner;

    function Ownable() {
        owner = msg.sender;
    }

    function transferOwnership(address newOwner) onlyOwner {
        if (newOwner != address(0)) owner = newOwner;
    }

    function kill() {
        if (msg.sender == owner) selfdestruct(owner);
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
    function emergencyStop() external onlyOwner {
        stopped = true;
    }

    // Called by the owner to end of emergency, returns to normal state
    function release() external onlyOwner onlyInEmergency {
        stopped = false;
    }
}



// Base contract supporting async send for pull payments.
// Inherit from this contract and use asyncSend instead of send.
contract PullPayment {
    mapping(address => uint) public payments;

    event RefundETH(address to, uint value);

    // Store sent amount as credit to be pulled, called by payer
    function asyncSend(address dest, uint amount) internal {
        payments[dest] += amount;
    }
    
    // Withdraw accumulated balance, called by payee
    function withdrawPayments() internal returns (bool) {
        address payee = msg.sender;
        uint payment = payments[payee];

        if (payment == 0) {
            revert();
        }

        if (this.balance < payment) {
            revert();
        }

        payments[payee] = 0;

        if (!payee.send(payment)) {
            revert();
        }
        RefundETH(payee, payment);
        return true;
    }
}


// Crowdsale Smart Contract
// This smart contract collects ETH and in return sends GXC tokens to the Backers
contract Crowdsale is SafeMath, Pausable, PullPayment {

    struct Backer {
        uint weiReceived; // amount of ETH contributed
        uint GXCSent; // amount of tokens  sent        
    }

    GXC public gxc; // DMINI contract reference   
    address public multisigETH; // Multisig contract that will receive the ETH    
    address public team; // Address at which the team GXC will be sent   
    uint public ETHReceived; // Number of ETH received
    uint public GXCSentToETH; // Number of GXC sent to ETH contributors
    uint public startBlock; // Crowdsale start block
    uint public endBlock; // Crowdsale end block
    uint public maxCap; // Maximum number of GXC to sell
    uint public minCap; // Minimum number of ETH to raise
    uint public minInvestETH; // Minimum amount to invest
    bool public crowdsaleClosed; // Is crowdsale still on going
    uint public tokenPriceWei;
    uint GXCReservedForPresale ;  
    

    
    uint multiplier = 10000000000; // to provide 10 decimal values
    // Looping through Backer
    mapping(address => Backer) public backers; //backer list
    address[] public backersIndex ;   // to be able to itarate through backers when distributing the tokens. 


    // @notice to verify if action is not performed out of the campaing range
    modifier respectTimeFrame() {
        if ((block.number < startBlock) || (block.number > endBlock)) revert();
        _;
    }

    modifier minCapNotReached() {
        if (GXCSentToETH >= minCap) revert();
        _;
    }

    // Events
    event ReceivedETH(address backer, uint amount, uint tokenAmount);

    // Crowdsale  {constructor}
    // @notice fired when contract is crated. Initilizes all constnat variables.
    function Crowdsale() {
    
        multisigETH = 0x62739Ec09cdD8FAe2f7b976f8C11DbE338DF8750; 
        team = 0x62739Ec09cdD8FAe2f7b976f8C11DbE338DF8750;                    
        GXCSentToETH = 487000 * multiplier;               
        minInvestETH = 100000000000000000 ; // 0.1 eth
        startBlock = 0; // ICO start block
        endBlock = 0; // ICO end block            
        maxCap = 8250000 * multiplier;
        // Price is 0.001 eth                         
        tokenPriceWei = 3004447000000000;
                        
        minCap = 500000 * multiplier;
    }

    // @notice Specify address of token contract
    // @param _GXCAddress {address} address of GXC token contrac
    // @return res {bool}
    function updateTokenAddress(GXC _GXCAddress) public onlyOwner() returns(bool res) {
        gxc = _GXCAddress;  
        return true;    
    }

    // @notice modify this address should this be needed. 
    function updateTeamAddress(address _teamAddress) public onlyOwner returns(bool){
        team = _teamAddress;
        return true; 
    }

    // @notice return number of contributors
    // @return  {uint} number of contributors
    function numberOfBackers()constant returns (uint){
        return backersIndex.length;
    }

    // {fallback function}
    // @notice It will call internal function which handels allocation of Ether and calculates GXC tokens.
    function () payable {         
        handleETH(msg.sender);
    }

    // @notice It will be called by owner to start the sale   
    function start(uint _block) onlyOwner() {
        startBlock = block.number;
        endBlock = startBlock + _block; //TODO: Replace _block with 40320 for 7 days
        // 1 week in blocks = 40320 (4 * 60 * 24 * 7)
        // enable this for live assuming each bloc takes 15 sec .
        crowdsaleClosed = false;
    }

    // @notice It will be called by fallback function whenever ether is sent to it
    // @param  _backer {address} address of beneficiary
    // @return res {bool} true if transaction was successful
    function handleETH(address _backer) internal stopInEmergency respectTimeFrame returns(bool res) {

        if (msg.value < minInvestETH) revert(); // stop when required minimum is not sent

        uint GXCToSend = (msg.value * multiplier)/ tokenPriceWei ; // calculate number of tokens

        // Ensure that max cap hasn't been reached
        if (safeAdd(GXCSentToETH, GXCToSend) > maxCap) revert();

        Backer storage backer = backers[_backer];

         if ( backer.weiReceived  == 0)
             backersIndex.push(_backer);

        if (!gxc.transfer(_backer, GXCToSend)) revert(); // Transfer GXC tokens
        backer.GXCSent = safeAdd(backer.GXCSent, GXCToSend);
        backer.weiReceived = safeAdd(backer.weiReceived, msg.value);
        ETHReceived = safeAdd(ETHReceived, msg.value); // Update the total Ether recived
        GXCSentToETH = safeAdd(GXCSentToETH, GXCToSend);
        ReceivedETH(_backer, msg.value, GXCToSend); // Register event
        return true;
    }


    // @notice This function will finalize the sale.
    // It will only execute if predetermined sale time passed or all tokens are sold.
    function finalize() onlyOwner() {

        if (crowdsaleClosed) revert();
        
        uint daysToRefund = 4*60*24*10;  //10 days        

        if (block.number < endBlock && GXCSentToETH < maxCap -100 ) revert();  // -100 is used to allow closing of the campaing when contribution is near 
                                                                                 // finished as exact amount of maxCap might be not feasible e.g. you can't easily buy few tokens. 
                                                                                 // when min contribution is 0.1 Eth.  

        if (GXCSentToETH < minCap && block.number < safeAdd(endBlock , daysToRefund)) revert();   

       
        if (GXCSentToETH > minCap) {
            if (!multisigETH.send(this.balance)) revert();  // transfer balance to multisig wallet
            if (!gxc.transfer(team,  gxc.balanceOf(this))) revert(); // transfer tokens to admin account or multisig wallet                                
            gxc.unlock();    // release lock from transfering tokens. 
        }
        else{
            if (!gxc.burn(this, gxc.balanceOf(this))) revert();  // burn all the tokens remaining in the contract                       
        }

        crowdsaleClosed = true;
        
    }

 

  
    // @notice Failsafe drain
    function drain() onlyOwner(){
        if (!owner.send(this.balance)) revert();
    }

    // @notice Failsafe transfer tokens for the team to given account 
    function transferDevTokens(address _devAddress) onlyOwner returns(bool){
        if (!gxc.transfer(_devAddress,  gxc.balanceOf(this))) 
            revert(); 
        return true;

    }    


    // @notice Prepare refund of the backer if minimum is not reached
    // burn the tokens
    function prepareRefund()  minCapNotReached internal returns (bool){
        uint value = backers[msg.sender].GXCSent;

        if (value == 0) revert();           
        if (!gxc.burn(msg.sender, value)) revert();
        uint ETHToSend = backers[msg.sender].weiReceived;
        backers[msg.sender].weiReceived = 0;
        backers[msg.sender].GXCSent = 0;
        if (ETHToSend > 0) {
            asyncSend(msg.sender, ETHToSend);
            return true;
        }else
            return false;
        
    }

    // @notice refund the backer
    function refund() public returns (bool){

        if (!prepareRefund()) revert();
        if (!withdrawPayments()) revert();
        return true;

    }

 
}

// The GXC token
contract GXC is ERC20, SafeMath, Ownable {
    // Public variables of the token
    string public name;
    string public symbol;
    uint8 public decimals; // How many decimals to show.
    string public version = 'v0.1';
    uint public initialSupply;
    uint public totalSupply;
    bool public locked;
    address public crowdSaleAddress;
    uint multiplier = 10000000000;        
    
    uint256 public totalMigrated;

    mapping(address => uint) balances;
    mapping(address => mapping(address => uint)) allowed;
    

    // Lock transfer during the ICO
    modifier onlyUnlocked() {
        if (msg.sender != crowdSaleAddress && locked && msg.sender != owner) revert();
        _;
    }

    modifier onlyAuthorized() {
        if ( msg.sender != crowdSaleAddress && msg.sender != owner) revert();
        _;
    }

    // The GXC Token constructor
    function GXC(address _crowdSaleAddress) {        
        locked = true;  // Lock the transfer of tokens during the crowdsale
        initialSupply = 10000000 * multiplier;
        totalSupply = initialSupply;
        name = 'GXC'; // Set the name for display purposes
        symbol = 'GXC'; // Set the symbol for display purposes
        decimals = 10; // Amount of decimals for display purposes
        crowdSaleAddress = _crowdSaleAddress;               
        balances[crowdSaleAddress] = totalSupply;       
    }


    function restCrowdSaleAddress(address _newCrowdSaleAddress) onlyAuthorized() {
            crowdSaleAddress = _newCrowdSaleAddress;
    }

    

    function unlock() onlyAuthorized {
        locked = false;
    }

      function lock() onlyAuthorized {
        locked = true;
    }

    function burn( address _member, uint256 _value) onlyAuthorized returns(bool) {
        balances[_member] = safeSub(balances[_member], _value);
        totalSupply = safeSub(totalSupply, _value);
        Transfer(_member, 0x0, _value);
        return true;
    }

    function transfer(address _to, uint _value) onlyUnlocked returns(bool) {
        balances[msg.sender] = safeSub(balances[msg.sender], _value);
        balances[_to] = safeAdd(balances[_to], _value);
        Transfer(msg.sender, _to, _value);
        return true;
    }

    /* A contract attempts to get the coins */
    function transferFrom(address _from, address _to, uint256 _value) onlyUnlocked returns(bool success) {
        if (balances[_from] < _value) revert(); // Check if the sender has enough
        if (_value > allowed[_from][msg.sender]) revert(); // Check allowance
        balances[_from] = safeSub(balances[_from], _value); // Subtract from the sender
        balances[_to] = safeAdd(balances[_to], _value); // Add the same to the recipient
        allowed[_from][msg.sender] = safeSub(allowed[_from][msg.sender], _value);
        Transfer(_from, _to, _value);
        return true;
    }

    function balanceOf(address _owner) constant returns(uint balance) {
        return balances[_owner];
    }

    function approve(address _spender, uint _value) returns(bool) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }


    function allowance(address _owner, address _spender) constant returns(uint remaining) {
        return allowed[_owner][_spender];
    }
}