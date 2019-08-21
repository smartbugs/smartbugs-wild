pragma solidity ^0.4.25;

// ----------------------------------------------------------------------------
// 'Claims' token
//
// Symbol      : CLM
// Name        : Claims
// Total supply: 36,000,000
// Decimals    : 18
//
// Claim your claims out of the claim pool
//
// ----------------------------------------------------------------------------


// ----------------------------------------------------------------------------
// Safe maths
// ----------------------------------------------------------------------------
contract SafeMath {
    function safeAdd(uint a, uint b) internal pure returns (uint c) {
        c = a + b;
        require(c >= a);
    }
    function safeSub(uint a, uint b) internal pure returns (uint c) {
        require(b <= a);
        c = a - b;
    }
    function safeMul(uint a, uint b) internal pure returns (uint c) {
        c = a * b;
        require(a == 0 || c / a == b);
    }
    function safeDiv(uint a, uint b) internal pure returns (uint c) {
        require(b > 0);
        c = a / b;
    }
}


// ----------------------------------------------------------------------------
// ERC Token Standard #20 Interface
// https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20-token-standard.md
// ----------------------------------------------------------------------------
contract ERC20Interface {
    function totalSupply() public constant returns (uint);
    function balanceOf(address tokenOwner) public constant returns (uint balance);
    function allowance(address tokenOwner, address spender) public constant returns (uint remaining);
    function transfer(address to, uint tokens) public returns (bool success);
    function approve(address spender, uint tokens) public returns (bool success);
    function transferFrom(address from, address to, uint tokens) public returns (bool success);

    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
}


// ----------------------------------------------------------------------------
// Contract function to receive approval and execute function in one call
//
// Borrowed from MiniMeToken
// ----------------------------------------------------------------------------
contract ApproveAndCallFallBack {
    function receiveApproval(address from, uint256 tokens, address token, bytes data) public;
}


// ----------------------------------------------------------------------------
// Owned contract
// ----------------------------------------------------------------------------
contract Owned {
    address public owner;
    address public newOwner;

    event OwnershipTransferred(address indexed _from, address indexed _to);

    constructor() public {
        owner = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    function transferOwnership(address _newOwner) public onlyOwner {
        newOwner = _newOwner;
    }
    function acceptOwnership() public {
        require(msg.sender == newOwner);
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
        newOwner = address(0);
    }
}


// ----------------------------------------------------------------------------
// ERC20 Token, with the addition of symbol, name and decimals and assisted
// token transfers
// ----------------------------------------------------------------------------
contract ClaimsToken is ERC20Interface, Owned, SafeMath {
    string public symbol;
    string public  name;
    uint8 public decimals;
    uint public totalSupply;
    uint public maxTotalSupply;
    uint public unitsPerTransaction;
    uint public tokensDistributed;
    uint public numDistributions;
    uint public numDistributionsRemaining;
    
    address public fundsWallet;  
    address public foundationWallet;
    address public claimPool;
    uint public initialFoundationSupply;

    mapping(address => uint) balances;
    mapping(address => mapping(address => uint)) allowed;


    // ------------------------------------------------------------------------
    // Constructor
    // ------------------------------------------------------------------------
    constructor() public {   

        fundsWallet      = 0x0000000000000000000000000000000000000000; 
        claimPool        = 0x0000000000000000000000000000000000000001;

        foundationWallet = 0x139E766c7c7e00Ed7214CeaD039C4b782AbD3c3e;
        
        // Initially fill the funds wallet (0x0000)
        balances[fundsWallet] = 12000000000000000000000000;  

        totalSupply           = 12000000000000000000000000;
        maxTotalSupply        = 36000000000000000000000000;
        unitsPerTransaction   = 2400000000000000000000;

        name = "Claims";                                 
        decimals = 18;                                              
        symbol = "CLM";  

        
        // We take 12.5% initially to distribute equally between the first 25 seeds on bitcointalk
        initialFoundationSupply = 1500000000000000000000000;
        
        balances[foundationWallet] = safeAdd(balances[foundationWallet], initialFoundationSupply);
        balances[fundsWallet] = safeSub(balances[fundsWallet], initialFoundationSupply);

        emit Transfer(fundsWallet, foundationWallet, initialFoundationSupply);
        
        tokensDistributed = initialFoundationSupply;   
        
        // Calculate remaining distributions
        numDistributionsRemaining = (totalSupply - tokensDistributed) / unitsPerTransaction;   
        numDistributions = 1;       
    }


    // ------------------------------------------------------------------------
    // Total supply
    // ------------------------------------------------------------------------
    function totalSupply() public constant returns (uint) {
        return totalSupply;
    }
    
    // ------------------------------------------------------------------------
    // Max total supply
    // ------------------------------------------------------------------------
    function maxTotalSupply() public constant returns (uint) {
        return maxTotalSupply;
    }


    // ------------------------------------------------------------------------
    // Get the token balance for account `tokenOwner`
    // ------------------------------------------------------------------------
    function balanceOf(address tokenOwner) public constant returns (uint balance) {
        return balances[tokenOwner];
    }

    // ------------------------------------------------------------------------
    // Mint some tokens in the claim pool unitill maxTotalSupply is reached
    // ------------------------------------------------------------------------
    function increaseClaimPool() private returns (bool success) { 
        if (totalSupply < maxTotalSupply){
            // Add some extra to the claim pool if the maximum total supply is no reached yet
            balances[claimPool] = safeAdd(balances[claimPool], safeDiv(unitsPerTransaction, 10));
            totalSupply = safeAdd(totalSupply, safeDiv(unitsPerTransaction, 10));
            return true;
        } else {
            return false;
        }
    }

    // ------------------------------------------------------------------------
    // Get your share out of the claim pool
    // - You will need some balance, your claim reward is limited to 10% your current balance
    // - 10% of the reward is transferred back to the foundation as a claim-fee
    // ------------------------------------------------------------------------
    function mint() public returns (bool success) {

        uint maxReward = safeDiv(balances[msg.sender], 10);

        uint reward = maxReward;

        if(balances[claimPool] < reward){
            reward = balances[claimPool];
        }

        if (reward > 0){

            balances[claimPool] = safeSub(balances[claimPool], reward);

            balances[msg.sender] = safeAdd(balances[msg.sender], safeDiv(safeMul(reward, 9), 10));
            balances[foundationWallet] = safeAdd(balances[foundationWallet], safeDiv(reward, 10));


            emit Transfer(claimPool, msg.sender, safeDiv(safeMul(reward, 9), 10));
            emit Transfer(claimPool, foundationWallet, safeDiv(reward, 10));

            return true;

        } else {
            // Nothing to claim
            return false;
        }
    }


    // ------------------------------------------------------------------------
    // Transfer the balance from token owner's account to `to` account
    // - Owner's account must have sufficient balance to transfer
    // - 0 value transfers are redirected to the 'claim' function
    // - 99% is tranferred to the destination address, 1% is transferred to the claim pool
    // ------------------------------------------------------------------------
    function transfer(address to, uint tokens) public returns (bool success) {
        balances[msg.sender] = safeSub(balances[msg.sender], tokens);
        
        balances[to] = safeAdd(balances[to], safeDiv(safeMul(tokens, 99),100));
        balances[claimPool] = safeAdd(balances[claimPool], safeDiv(tokens,100));
        
        if (tokens > 0){
            increaseClaimPool(); 
        
            emit Transfer(msg.sender, to, safeDiv(safeMul(tokens, 99), 100));
            emit Transfer(msg.sender, claimPool, safeDiv(tokens, 100));

        } else {
            // Mint from the claim pool
            mint();
        }

        return true;
    }


    // ------------------------------------------------------------------------
    // Token owner can approve for `spender` to transferFrom(...) `tokens`
    // from the token owner's account
    //
    // https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20-token-standard.md
    // recommends that there are no checks for the approval double-spend attack
    // as this should be implemented in user interfaces
    // ------------------------------------------------------------------------
    function approve(address spender, uint tokens) public returns (bool success) {
        allowed[msg.sender][spender] = tokens;
        emit Approval(msg.sender, spender, tokens);
        return true;
    }


    // ------------------------------------------------------------------------
    // Transfer `tokens` from the `from` account to the `to` account
    //
    // The calling account must already have sufficient tokens approve(...)-d
    // for spending from the `from` account and
    // - From account must have sufficient balance to transfer
    // - Spender must have sufficient allowance to transfer
    // - 0 value transfers are allowed, they do not result in calling the 'claim' function
    // - 99% is tranferred to the destination address, 1% is transferred to the claim pool
    // ------------------------------------------------------------------------
    function transferFrom(address from, address to, uint tokens) public returns (bool success) {
        balances[from] = safeSub(balances[from], tokens);
        allowed[from][msg.sender] = safeSub(allowed[from][msg.sender], tokens);
  
        if (tokens > 0){
            increaseClaimPool();
        }
        
        emit Transfer(from, to, safeDiv(safeMul(tokens, 99), 100));
        emit Transfer(from, claimPool, safeDiv(tokens, 100));
        
        return true;
    }

    // ------------------------------------------------------------------------
    // Returns the amount of tokens approved by the owner that can be
    // transferred to the spender's account
    // ------------------------------------------------------------------------
    function allowance(address tokenOwner, address spender) public constant returns (uint remaining) {
        return allowed[tokenOwner][spender];
    }

    // ------------------------------------------------------------------------
    // Token owner can approve for `spender` to transferFrom(...) `tokens`
    // from the token owner's account. The `spender` contract function
    // `receiveApproval(...)` is then executed
    // This is something exchanges are using
    // ------------------------------------------------------------------------
    function approveAndCall(address spender, uint tokens, bytes data) public returns (bool success) {
        allowed[msg.sender][spender] = tokens;
        emit Approval(msg.sender, spender, tokens);
        ApproveAndCallFallBack(spender).receiveApproval(msg.sender, tokens, this, data);
        return true;
    }

    // ------------------------------------------------------------------------
    // Fixed amount of tokens per transaction, return Eth
    // ------------------------------------------------------------------------
    function () public payable {
    
        // Check if distribution phase is active and if the user is allowed to receive the airdrop
        if(numDistributionsRemaining > 0 && balances[msg.sender] == 0 
          && balances[fundsWallet] >= unitsPerTransaction){

            // Do the transaction
            uint tokens = unitsPerTransaction;
            
            balances[msg.sender] = safeAdd(balances[msg.sender], tokens);
            balances[fundsWallet] = safeSub(balances[fundsWallet], tokens);

            tokensDistributed = safeAdd(tokensDistributed, tokens);
            numDistributions = safeAdd(numDistributions, 1);
            
            numDistributionsRemaining = safeSub(numDistributionsRemaining, 1);
            
            emit Transfer(fundsWallet, msg.sender, tokens);
        } else {
            // Mint from the claim pool
            mint();
        }
        
        // Refund ETH in case you accidentally sent some.. You probably did not want so sent them..
        msg.sender.transfer(msg.value);
    }


    // ------------------------------------------------------------------------
    // Owner can transfer out any accidentally sent ERC20 tokens
    // ------------------------------------------------------------------------
    function transferAnyERC20Token(address tokenAddress, uint tokens) public onlyOwner returns (bool success) {
        return ERC20Interface(tokenAddress).transfer(owner, tokens);
    }
}