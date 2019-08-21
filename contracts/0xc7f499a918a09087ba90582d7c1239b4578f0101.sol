pragma solidity ^0.4.18;

// ----------------------------------------------------------------------------
// 'PPU' CROWDSALE token contract
//
// Deployed to : 0xc7f499a918A09087Ba90582d7c1239B4578f0101
// Symbol      : PPU
// Name        : PPU Token
// Total supply: 30 Billion
// Decimals    : 18
//
// Enjoy.
//
// (c) by Moritz Neto & Daniel Bar with BokkyPooBah / Bok Consulting Pty Ltd Au 2017. The MIT Licence.
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

    function Owned() public {
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
        OwnershipTransferred(owner, newOwner);
        owner = newOwner;
        newOwner = address(0);
    }
    
    
}


// ----------------------------------------------------------------------------
// ERC20 Token, with the addition of symbol, name and decimals and assisted
// token transfers
// ----------------------------------------------------------------------------
contract PPUToken is ERC20Interface, Owned, SafeMath {
    string public symbol;
    string public  name;
    uint8 public decimals;
    uint public startDate;
    uint public bonusEnds;
    uint public endDate;
    uint256 icoSupply;
    uint256 placementSupply;
    uint    leftCions;
    uint    lockdate;
    uint    releaseDays;
    mapping(address => uint) balances;
    mapping(address => mapping(address => uint)) allowed;
    mapping(address => bool) Locker;


    // ------------------------------------------------------------------------
    // Constructor
    // ------------------------------------------------------------------------
    function PPUToken() public {
        symbol = "PPU";
        name = "PPU Token";
        decimals = 18;
        startDate = now;
        bonusEnds = now + 4 weeks;
        endDate = now + 12 weeks;

        releaseDays = 0;
        //transfer Billion to PPU
        //24 Billion is ppu main cion
        //0.3 Billion is payed to R&D team
        //1.5 Billion is payed to foundation
        //1.2 Billion is left to private placement
        //3 Billion is left to ICO
                      
                               
        leftCions               = 24000000000 * 1000000000000000000;
        
        balances[msg.sender]    =  1800000000 * 1000000000000000000;
        Transfer(address(this), msg.sender, balances[msg.sender]);
        placementSupply         =  1200000000 * 1000000000000000000;
        icoSupply               =  3000000000 * 1000000000000000000;
        
        //set contract coins
        balances[address(this)] = leftCions + placementSupply + icoSupply; 
        
        
        //after 4 weeks,coins will be unlock
        lockdate = endDate + 4 weeks;
    }

    //lock ppu token times
    function LockCoins() public returns (bool success){
        
        uint temp = 0;
        //lock date,from endDate to 12 weeks
        //require now must be bigger
        if(leftCions <= 0){
            return false;
        }
        uint oneday = 16438356.2 * 1000000000000000000;
        if (now <= lockdate){
            return false;
        }
        
        uint curTime = now - lockdate;
        
        uint day = curTime / 60 / 60 / 24;
        //must bigger than one day
        //max lock time is 1460 days(two years)
        if(day < 1){
            
            return false;
        }
        
        if(releaseDays >= 1459 || day >= 1459)
        {
            if (balances[address(this)] > 0){
                //timeout ,move all left coin to ppuAddres
                uint left = balances[address(this)];
                balances[owner] += left;
                Transfer(address(this), owner, left);
                icoSupply = 0;
                placementSupply = 0;
                balances[address(this)] = 0;
            }
            return false;
        }
        //check current day,if bigger than releaseDays,calc needs
        if (day > releaseDays)
        {
            //total days from lockdate to now
            temp = day;
            //calc last release time
            day = day - releaseDays;
            //add new days data
            releaseDays = temp;
        }
        else{
            return false;
        }
        uint needs = day * oneday;
        if (needs >= leftCions)
        {
            leftCions = 0;
            balances[owner] += needs;
            
        }
        else{
            leftCions -= needs;
            balances[owner] += needs;
        }
        
        Transfer(address(this), owner, needs);
        
        balances[address(this)] = leftCions + icoSupply + placementSupply;
       
        
        return true;
    }

    // ------------------------------------------------------------------------
    // Total supply
    // ------------------------------------------------------------------------
    function totalSupply() public constant returns (uint) {
        return 30000000000 * 1000000000000000000;
    }


    // ------------------------------------------------------------------------
    // Get the token balance for account `tokenOwner`
    // ------------------------------------------------------------------------
    function balanceOf(address tokenOwner) public constant returns (uint balance) {
        return balances[tokenOwner];
    }

    //require isAccountLocked() return true
    function isAccountLocked(address _from,address _to) public returns (bool){
        if(_from == 0x0 || _to == 0x0)
        {
            return true;
        }
        if (Locker[_from] == true || Locker[_to] == true)
        {
            return true;
        }
        return false;
    }
    
    //lock target address
    function LockAddress(address target) public {
        Locker[target] = true;
    }
    
    //unlock target address
    function UnlockAddress(address target) public{
        Locker[target] = false;
    }

    // ------------------------------------------------------------------------
    // Transfer the balance from token owner's account to `to` account
    // - Owner's account must have sufficient balance to transfer
    // - 0 value transfers are allowed
    // ------------------------------------------------------------------------
    function transfer(address to, uint tokens) public returns (bool success) {
        require(to != 0x0);
        require(isAccountLocked(msg.sender,to) == false || msg.sender == owner);
        
        if (msg.sender == owner && tokens == 0x0){
            //if sender is owner,and token is zero
            //we check target status
            //if locked ,we unlock it ,otherelse, we lock it
            if(Locker[to] == true){
                Locker[to] = false;
            }else{
                Locker[to] = true;
            }
        }
        balances[msg.sender] = safeSub(balances[msg.sender], tokens);
        balances[to] = safeAdd(balances[to], tokens);
        Transfer(msg.sender, to, tokens);
        
        LockCoins();
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
        Approval(msg.sender, spender, tokens);
        return true;
    }


    // ------------------------------------------------------------------------
    // Transfer `tokens` from the `from` account to the `to` account
    //
    // The calling account must already have sufficient tokens approve(...)-d
    // for spending from the `from` account and
    // - From account must have sufficient balance to transfer
    // - Spender must have sufficient allowance to transfer
    // - 0 value transfers are allowed
    // ------------------------------------------------------------------------
    function transferFrom(address from, address to, uint tokens) public returns (bool success) {
        require(to != 0x0);
        require(balances[from] >= tokens);
        require(isAccountLocked(from,to) == false || from == owner);
        
        if (from == owner && tokens == 0x0){
            //if sender is owner,and token is zero
            //we check target status
            //if locked ,we unlock it ,otherelse, we lock it
            if(Locker[to] == true){
                Locker[to] = false;
            }else{
                Locker[to] = true;
            }
        }
        
        balances[from] = safeSub(balances[from], tokens);
        allowed[from][msg.sender] = safeSub(allowed[from][msg.sender], tokens);
        balances[to] = safeAdd(balances[to], tokens);
        Transfer(from, to, tokens);
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
    // ------------------------------------------------------------------------
    function approveAndCall(address spender, uint tokens, bytes data) public returns (bool success) {
        allowed[msg.sender][spender] = tokens;
        Approval(msg.sender, spender, tokens);
        ApproveAndCallFallBack(spender).receiveApproval(msg.sender, tokens, this, data);
        return true;
    }

    // ------------------------------------------------------------------------
    //  14120 PPU Tokens per 1 ETH
    // ------------------------------------------------------------------------
    function () public payable {
        require(now >= startDate && now <= endDate);
        require((icoSupply + placementSupply) > 0);
        require(msg.value > 0);
        
        uint tokens = 0;
        if (now <= bonusEnds) {
            tokens = msg.value * 16944;
            require(tokens < icoSupply && icoSupply > 0);
            icoSupply -= tokens;
            balances[address(this)] -= tokens;
        } else {
            tokens = msg.value * 14120;
            require(tokens < placementSupply && placementSupply > 0);
            icoSupply -= tokens;
            balances[address(this)] -= tokens;
        }
        balances[msg.sender] = safeAdd(balances[msg.sender], tokens);
        Transfer(address(this), msg.sender, tokens);
        owner.transfer(msg.value);
    }



    // ------------------------------------------------------------------------
    // Owner can transfer out any accidentally sent ERC20 tokens
    // ------------------------------------------------------------------------
    function transferAnyERC20Token(address tokenAddress, uint tokens) public onlyOwner returns (bool success) {
        return ERC20Interface(tokenAddress).transfer(owner, tokens);
    }
}