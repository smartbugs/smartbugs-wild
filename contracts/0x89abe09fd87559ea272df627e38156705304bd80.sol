pragma solidity ^0.4.25;

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error.
 */
library SafeMath {
    // Multiplies two numbers, throws on overflow./
    function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
        if (a == 0) return 0;
        c = a * b;
        assert(c / a == b);
        return c;
    }
    // Integer division of two numbers, truncating the quotient.
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }
    // Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }
    // Adds two numbers, throws on overflow.
    function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
        c = a + b;
        assert(c >= a);
        return c;
    }
}


/**
 * @title Smart-Mining 'mining-pool & token-distribution'-contract - https://smart-mining.io - mail@smart-mining.io
 */
contract SmartMining {
    using SafeMath for uint256;
    
    // -------------------------------------------------------------------------
    // Variables
    // -------------------------------------------------------------------------
    
    string  constant public name     = "smart-mining.io"; // EIP-20
    string  constant public symbol   = "SMT";             // EIP-20
    uint8   constant public decimals = 18;                // EIP-20
    uint256 public totalSupply       = 10000;             // EIP-20
    
    struct Member {                                       // 'Member'-struct
        bool    crowdsalePrivateSale;                     // If 'true', member can participate in crowdsale before crowdsaleOpen == true
        uint256 crowdsaleMinPurchase;                     // Approved minimum crowdsale purchase in Wei
        uint256 balance;                                  // Token balance in Ici, represents the percent of mining profits
        uint256 unpaid;                                   // Available Wei for withdrawal, + 1 in storage for gas optimization and indicator if address is member of SmartMining contract
    }                                                  
    mapping (address => Member) public members;           // All Crowdsale members as 'Member'-struct
    
    uint16    public memberCount;                         // Count of all SmartMining members inclusive the team-contract
    address[] public memberIndex;                         // Lookuptable of all member addresses to iterate on deposit over and assign unpaid Ether to members
    address   public owner;                               // Owner of this contract
    address   public withdrawer;                          // Allowed executor of automatic processed member whitdrawals (SmartMining-API)
    address   public depositor;                           // Allowed depositor of mining profits
    
    bool      public crowdsaleOpen;                       // 'true' if crowdsale is open for investors
    bool      public crowdsaleFinished;                   // 'true' after crowdsaleCap was reached
    address   public crowdsaleWallet;                     // Address where crowdsale funds are collected
    uint256   public crowdsaleCap;                        // Wei after crowdsale is finished
    uint256   public crowdsaleRaised;                     // Amount of wei raised in crowdsale
    
    
    // -------------------------------------------------------------------------
    // Constructor
    // -------------------------------------------------------------------------
    
    constructor (uint256 _crowdsaleCapEth, address _crowdsaleWallet, address _teamContract, uint256 _teamShare, address _owner) public {
        require(_crowdsaleCapEth != 0 && _crowdsaleWallet != 0x0 && _teamContract != 0x0 && _teamShare != 0 && _owner != 0x0);
        
        // Initialize contract owner and trigger 'SetOwner'-event
        owner = _owner;
        emit SetOwner(owner);
        
        // Update totalSupply with the decimal amount
        totalSupply = totalSupply.mul(10 ** uint256(decimals));
        
        // Convert '_crowdsaleCapEth' from Ether to Wei
        crowdsaleCap = _crowdsaleCapEth.mul(10 ** 18);
        
        // Initialize withdrawer and crowdsaleWallet
        withdrawer = msg.sender;
        crowdsaleWallet = _crowdsaleWallet;
        
        // Assign totalSupply to contract address and trigger 'from 0x0'-'Transfer'-event for token creation
        members[address(this)].balance = totalSupply;
        emit Transfer(0x0, address(this), totalSupply);
        
        // Initialize team-contract
        members[_teamContract].unpaid = 1;
        memberIndex.push(_teamContract); // memberIndex[0] will become team-contract address
        memberCount++;
        
        // Transfer team tokens
        uint256 teamTokens = totalSupply.mul(_teamShare).div(100);
        members[address(this)].balance = members[address(this)].balance.sub(teamTokens);
        members[_teamContract].balance = teamTokens;
        emit Transfer(address(this), _teamContract, teamTokens);
    }
    
    
    // -------------------------------------------------------------------------
    // Events
    // -------------------------------------------------------------------------
    
    event SetOwner(address indexed owner);
    event SetDepositor(address indexed depositor);
    event SetWithdrawer(address indexed withdrawer);
    event SetTeamContract(address indexed teamContract);
    event Approve(address indexed member, uint256 crowdsaleMinPurchase, bool privateSale);
    event Participate(address indexed member, uint256 value, uint256 tokens);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event ForwardCrowdsaleFunds(address indexed to, uint256 value);
    event CrowdsaleStarted(bool value);
    event CrowdsaleFinished(bool value);
    event Withdraw(address indexed member, uint256 value);
    event Deposit(address indexed from, uint256 value);
    
    
    // -------------------------------------------------------------------------
    // WITHDRAWER (SmartMining-API) & OWNER ONLY external maintenance interface
    // -------------------------------------------------------------------------
    
    function approve (address _beneficiary, uint256 _ethMinPurchase, bool _privateSale) external {
        require(msg.sender == owner || msg.sender == withdrawer, "Only SmartMining-API and contract owner allowed to approve.");
        require(crowdsaleFinished == false, "No new approvals after crowdsale finished.");
        require(_beneficiary != 0x0);
        
        if( members[_beneficiary].unpaid == 1 ) {
            members[_beneficiary].crowdsaleMinPurchase = _ethMinPurchase.mul(10 ** 18);
            members[_beneficiary].crowdsalePrivateSale = _privateSale;
        } else {
            members[_beneficiary].unpaid = 1;
            members[_beneficiary].crowdsaleMinPurchase = _ethMinPurchase.mul(10 ** 18);
            members[_beneficiary].crowdsalePrivateSale = _privateSale;
            
            memberIndex.push(_beneficiary);
            memberCount++;
        }
        
        emit Approve(_beneficiary, members[_beneficiary].crowdsaleMinPurchase, _privateSale);
    }
    
    
    // -------------------------------------------------------------------------
    // OWNER ONLY external maintenance interface
    // -------------------------------------------------------------------------
    
    modifier onlyOwner () {
        require(msg.sender == owner);
        _;
    }
    
    function setTeamContract (address _newTeamContract) external onlyOwner {
        require(_newTeamContract != 0x0 && _newTeamContract != memberIndex[0]);
        
        // Move team-contract member to new addresss
        members[_newTeamContract] = members[memberIndex[0]];
        delete members[memberIndex[0]];
        
        // Trigger 'SetTeamContract' & 'Transfer'-event for token movement
        emit SetTeamContract(_newTeamContract);
        emit Transfer(memberIndex[0], _newTeamContract, members[_newTeamContract].balance);
        
        // Update memberIndex[0] to new team-contract address
        memberIndex[0] = _newTeamContract;
    }
    
    function setOwner (address _newOwner) external onlyOwner {
        if( _newOwner != 0x0 ) { owner = _newOwner; } else { owner = msg.sender; }
        emit SetOwner(owner);
    }
    
    function setDepositor (address _newDepositor) external onlyOwner {
        depositor = _newDepositor;
        emit SetDepositor(_newDepositor);
    }
    
    function setWithdrawer (address _newWithdrawer) external onlyOwner {
        withdrawer = _newWithdrawer;
        emit SetWithdrawer(_newWithdrawer);
    }
    
    function startCrowdsale () external onlyOwner {
        require(crowdsaleFinished == false, "Crowdsale can only be started once.");
        
        crowdsaleOpen = true;
        emit CrowdsaleStarted(true);
    }
    
    function cleanupMember (uint256 _memberIndex) external onlyOwner {
        require(members[memberIndex[_memberIndex]].unpaid == 1, "Not a member.");
        require(members[memberIndex[_memberIndex]].balance == 0, "Only members without participation can be deleted.");
        
        // Delete whitelisted member which not participated in crowdsale
        delete members[memberIndex[_memberIndex]];
        memberIndex[_memberIndex] = memberIndex[memberIndex.length-1];
        memberIndex.length--;
        memberCount--;
    }
    
    
    // -------------------------------------------------------------------------
    // Public external interface
    // -------------------------------------------------------------------------
    
    function () external payable {
        require(crowdsaleOpen || members[msg.sender].crowdsalePrivateSale || crowdsaleFinished, "smart-mining.io crowdsale not started yet.");
        
        if(crowdsaleFinished)
            deposit();
        if(crowdsaleOpen || members[msg.sender].crowdsalePrivateSale)
            participate();
    }
    
    function deposit () public payable {
        // Pre validate deposit
        require(crowdsaleFinished, "Deposits only possible after crowdsale finished.");
        require(msg.sender == depositor, "Only 'depositor' allowed to deposit.");
        require(msg.value >= 10**9, "Minimum deposit 1 gwei.");
        
        // Distribute deposited Ether to all SmartMining members related to their profit-share which is representat by their ICE token balance
        for (uint i=0; i<memberIndex.length; i++) {
            members[memberIndex[i]].unpaid = 
                // Adding current deposit to members unpaid Wei amount
                members[memberIndex[i]].unpaid.add(
                    // MemberTokenBalance * DepositedWei / totalSupply = WeiAmount of member-share to be added to members unpaid holdings
                    members[memberIndex[i]].balance.mul(msg.value).div(totalSupply)
                );
        }
        
        // Trigger 'Deposit'-event
        emit Deposit(msg.sender, msg.value);
    }
    
    function participate () public payable {
        // Pre validate purchase
        require(members[msg.sender].unpaid == 1, "Only whitelisted members are allowed to participate!");
        require(crowdsaleOpen || members[msg.sender].crowdsalePrivateSale, "Crowdsale is not open.");
        require(msg.value != 0, "No Ether attached to this buy order.");
        require(members[msg.sender].crowdsaleMinPurchase == 0 || msg.value >= members[msg.sender].crowdsaleMinPurchase,
            "Send at least your whitelisted crowdsaleMinPurchase Ether amount!");
            
        // Get token count and validate that enaugh tokens are available
        uint256 tokens = crowdsaleCalcTokenAmount(msg.value);
        require(members[address(this)].balance >= tokens, "There are not enaugh Tokens left for this order.");
        emit Participate(msg.sender, msg.value, tokens);
        
        // Remove members crowdsaleMinPurchase for further orders
        members[msg.sender].crowdsaleMinPurchase = 0;
        
        // Subtract tokens from contract and add tokens to members current holdings (Transfer)
        members[address(this)].balance = members[address(this)].balance.sub(tokens);
        members[msg.sender].balance = members[msg.sender].balance.add(tokens);
        emit Transfer(address(this), msg.sender, tokens);
        
        // Update crowdsale states
        crowdsaleRaised = crowdsaleRaised.add(msg.value);
        if(members[address(this)].balance == 0) {
            // Close crowdsale if all tokens are sold out
            crowdsaleOpen = false;
            crowdsaleFinished = true;
            emit CrowdsaleFinished(true);
        }
        
        // Forward msg.value (attached Ether) to crowdsaleWallet and trigger 'ForwardCrowdsaleFunds'-event
        emit ForwardCrowdsaleFunds(crowdsaleWallet, msg.value);
        crowdsaleWallet.transfer(msg.value);
    }
    
    function crowdsaleCalcTokenAmount (uint256 _weiAmount) public view returns (uint256) {
        // Multiplied by totalSupply to avoid floats in calculation
        return 
            // _weiAmount * totalSupply / crowdsaleCap * crowdsaleSupply / totalSupply
            _weiAmount
            .mul(totalSupply)
            .div(crowdsaleCap)
            .mul( totalSupply.sub(members[memberIndex[0]].balance) )
            .div(totalSupply);
    }
    
    function withdrawOf              (address _beneficiary) external                      { _withdraw(_beneficiary); }
    function withdraw                ()                     external                      { _withdraw(msg.sender); }
    function balanceOf               (address _beneficiary) public view returns (uint256) { return members[_beneficiary].balance; }
    function unpaidOf                (address _beneficiary) public view returns (uint256) { return members[_beneficiary].unpaid.sub(1); }
    function crowdsaleIsMemberOf     (address _beneficiary) public view returns (bool)    { return members[_beneficiary].unpaid >= 1; }
    function crowdsaleRemainingWei   ()                     public view returns (uint256) { return crowdsaleCap.sub(crowdsaleRaised); }
    function crowdsaleRemainingToken ()                     public view returns (uint256) { return members[address(this)].balance; }
    function crowdsalePercentOfTotalSupply ()               public view returns (uint256) { return totalSupply.sub(members[memberIndex[0]].balance).mul(100).div(totalSupply); }
    
    
    // -------------------------------------------------------------------------
    // Private functions, can only be called by this contract
    // -------------------------------------------------------------------------
    
    function _withdraw (address _beneficiary) private {
        // Pre-validate withdrawal
        if(msg.sender != _beneficiary) {
            require(msg.sender == owner || msg.sender == withdrawer, "Only 'owner' and 'withdrawer' can withdraw for other members.");
        }
        require(members[_beneficiary].unpaid >= 1, "Not a member account.");
        require(members[_beneficiary].unpaid > 1, "No unpaid balance on account.");
        
        // Remember members unpaid amount but remove it from his contract holdings before initiating the withdrawal for security reasons
        uint256 unpaid = members[_beneficiary].unpaid.sub(1);
        members[_beneficiary].unpaid = 1;
        
        // Trigger 'Withdraw'-event
        emit Withdraw(_beneficiary, unpaid);
        
        // Transfer the unpaid Wei amount to member address
        if(_beneficiary != memberIndex[0]) {
            // Client withdrawals rely on the 'gas stipend' (2300 gas) which has been checked during KYC
            _beneficiary.transfer(unpaid);
        } else {
            // Team-contract withdrawals obtain up to 100 times more gas for further automatic processing
            require( _beneficiary.call.gas(230000).value(unpaid)() );
        }
    }
    
    
}