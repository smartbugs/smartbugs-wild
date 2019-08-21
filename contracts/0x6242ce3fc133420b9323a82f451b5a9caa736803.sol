pragma solidity ^0.5.0;

/* 
   ----------------------------------------------------------------------------
   ERC-20 Token: Fixed supply with ICO 
   
*/


// -- Safe Math library - integer overflow prevention (OpenZeppelin) --

library SafeMath {
    
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b);

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0);
        uint256 c = a / b;

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a);
        uint256 c = a - b;

        return c;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a);

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0);
        return a % b;
    }
}


// -- ERC-20 Token Standard interface --
// based on https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20.md

contract ERC20Interface {
    function totalSupply() public view returns (uint);
    function balanceOf(address tokenOwner) public view returns (uint balance);
    function allowance(address tokenOwner, address spender) public view returns (uint remaining);
    function transfer(address to, uint tokens) public returns (bool success);
    function approve(address spender, uint tokens) public returns (bool success);
    function transferFrom(address from, address to, uint tokens) public returns (bool success);

    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
}


// -- Contract function - receive approval and execute function in one call --

contract ApproveAndCallFallBack {
    function receiveApproval(address from, uint256 tokens, address token, bytes memory data) public;
}


// -- Owned Contract --

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


// -- ERC20 Token + fixed supply --

contract LibertyEcoToken is ERC20Interface, Owned {
    using SafeMath for uint;

    string public symbol;
    string public name;
    uint8 public decimals;
    
    uint256 _totalSupply;
    uint256 public reserveCap = 0;                                  // Amount of tokens to reserve for owner (constructor) 
    uint256 public tokensRemain = 0;                                // Amount of tokens to sell (constructor)
    uint256 public tokensSold = 0;                                  // Amount of tokens sold
    uint256 public tokensDistributed = 0;                           // Amount of tokens distributed

    uint256 public tokensPerEth = 100;                               // Units of token can be bought with 1 ETH
    uint256 public EtherInWei = 0;                                  // Store the total ETH raised via ICO 
    address payable public fundsWallet;

    mapping(address => uint) balances;
    mapping(address => mapping(address => uint)) allowed;


    // -- Constructor --
    
    constructor() public {
        symbol = "LES";                                            // Token symbol / abbreviation
        name = "Liberty EcoToken";                                         // Token name
        decimals = 18;                                              
        _totalSupply = 10000000000 * 10**uint(decimals);               // Initial token supply deployed (in wei) -- 100 tokens
        
        balances[owner] = _totalSupply;                             // Give all token supply to owner
        emit Transfer(address(0), owner, _totalSupply);
        
        fundsWallet = msg.sender;                                   // To be funded on owner's wallet
        
        tokensRemain = _totalSupply.sub(reserveCap);
    }


    // -- Total Supply --
    
    function totalSupply() public view returns (uint256) {
        return _totalSupply.sub(balances[address(0)]);
    }


    // -- Get token balance for account `tokenOwner` --
    
    function balanceOf(address tokenOwner) public view returns (uint256 balance) {
        return balances[tokenOwner];
    }


    /*
      -- Transfer balance from token owner's account to other account --
        - Owner's account must have sufficient balance to transfer
        - 0 value transfers are allowed
    */
    
    function transfer(address to, uint256 tokens) public returns (bool success) {
        balances[msg.sender] = balances[msg.sender].sub(tokens);
        balances[to] = balances[to].add(tokens);
        emit Transfer(msg.sender, to, tokens);
        return true;
    }


    /* 
      -- Token owner can approve for `spender` to transferFrom(...) `tokens` from the token owner's account --
     
        ERC-20 Token Standard recommends that there are no checks for the approval 
        double-spend attack as this should be implemented in user interfaces
    */
    
    function approve(address spender, uint256 tokens) public returns (bool success) {
        allowed[msg.sender][spender] = tokens;
        emit Approval(msg.sender, spender, tokens);
        return true;
    }


    /*
      -- Transfer `tokens` from the `from` account to the `to` account --
    
        The calling account must already have sufficient tokens approve(...)-d
        for spending from the `from` account and:
        
        - From account must have sufficient balance to transfer
        - Spender must have sufficient allowance to transfer
        - 0 value transfers are allowed
    */
    
    function transferFrom(address from, address to, uint256 tokens) public returns (bool success) {
        
        balances[from] = balances[from].sub(tokens);
        allowed[from][msg.sender] = allowed[from][msg.sender].sub(tokens);
        balances[to] = balances[to].add(tokens);
        emit Transfer(from, to, tokens);
        return true;
    }


    //  -- Returns the amount of tokens approved by the owner that can be transferred to the spender's account --
    
    function allowance(address tokenOwner, address spender) public view returns (uint256 remaining) {
        return allowed[tokenOwner][spender];
    }


    /*
      -- Token owner can approve for `spender` to transferFrom(...) `tokens` from the token owner's account -- 
        - The `spender` contract function `receiveApproval(...)` is then executed
    */
    
    function approveAndCall(address spender, uint256 tokens, bytes memory data) public returns (bool success) {
        allowed[msg.sender][spender] = tokens;
        emit Approval(msg.sender, spender, tokens);
        ApproveAndCallFallBack(spender).receiveApproval(msg.sender, tokens, address(this), data);
        return true;
    }


    // -- 100 tokens given per 1 ETH but revert if owner reserve limit reached --
    
    function () external payable {
        if(balances[owner] >= reserveCap) {
            EtherInWei = EtherInWei + msg.value;
            uint256 amount = msg.value * tokensPerEth;
            
            require(balances[fundsWallet] >= amount);
            
            balances[fundsWallet] = balances[fundsWallet].sub(amount);
            balances[msg.sender] = balances[msg.sender].add(amount);
            
            emit Transfer(fundsWallet, msg.sender, amount); // Broadcast a message to the blockchain
            
            //Transfer ether to fundsWallet
            fundsWallet.transfer(msg.value);
            
            deductToken(amount);
        }
        
        else {
            revert("Token balance reaches reserve capacity, no more tokens will be given out.");
        }
    }


    // -- Owner can transfer out any accidentally sent ERC20 tokens --
    
    function transferAnyERC20Token(address tokenAddress, uint256 tokens) public onlyOwner returns (bool success) {
        return ERC20Interface(tokenAddress).transfer(owner, tokens);
    }
    
    // -- Mini function to deduct remaining tokens to sell and add in amount of tokens sold
    function deductToken(uint256 amt) private {
        tokensRemain = tokensRemain.sub(amt);
        tokensSold = tokensSold.add(amt);
    }
    
    // -- Set reserve cap by amount 
    
    function setReserveCap(uint256 tokenAmount) public onlyOwner {
        reserveCap = tokenAmount * 10**uint(decimals);
        tokensRemain = balances[owner].sub(reserveCap);
    }
    
    // -- Set reserve cap by percentage
    
    function setReserveCapPercentage (uint percentage) public onlyOwner {
        reserveCap = calcSupplyPercentage(percentage);
        tokensRemain = balances[owner].sub(reserveCap);
    }
    
    // -- Mini function for calculating token percentage from whole supply --
    
    function calcSupplyPercentage(uint256 percent) public view returns (uint256){
        uint256 total = _totalSupply.mul(percent.mul(100)).div(10000);
        
        return total;
    }
    
    // -- Distribute tokens to other address (with amount of tokens) --
    
    function distributeTokenByAmount(address dist_address, uint256 tokens)public payable onlyOwner returns (bool success){
        require(balances[owner] > 0 && tokens <= tokensRemain, "Token distribution fail due to insufficient selling token.");
        uint256 tokenToDistribute = tokens * 10**uint(decimals);
        
        balances[owner] = balances[owner].sub(tokenToDistribute);
        balances[dist_address] = balances[dist_address].add(tokenToDistribute);
        
        emit Transfer(owner, dist_address, tokenToDistribute);
        
        tokensRemain = tokensRemain.sub(tokenToDistribute);
        tokensDistributed = tokensDistributed.add(tokenToDistribute);
        
        return true;
    }
    
    // -- Release reserve cap from owner for token sell by amount of tokens
    
    function releaseCapByAmount(uint256 tokenAmount) public onlyOwner {
        tokenAmount = tokenAmount * 10**uint(decimals);
        
        require(balances[owner] >= tokenAmount);
        reserveCap = reserveCap.sub(tokenAmount);
        tokensRemain = tokensRemain.add(tokenAmount);
    }
}