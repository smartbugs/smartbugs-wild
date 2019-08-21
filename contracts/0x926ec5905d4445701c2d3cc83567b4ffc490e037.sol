pragma solidity ^0.4.18;

// ----------------------------------------------------------------------------
// EROS token
//
// Symbol      : ELOVE
// Name        : ELOVE Token for eLOVE Social Network
// Total supply: 200,000,000
// Decimals    : 2

contract ERC20Interface {
    function totalSupply() public constant returns (uint);
    function balanceOf(address tokenOwner) public constant returns (uint balance);
    function allowance(address tokenOwner, address spender) public constant returns (uint remaining);
    function transfer(address to, uint tokens) public returns (bool success);
    function approve(address spender, uint tokens) public returns (bool success);
    function transferFrom(address from, address to, uint tokens) public returns (bool success);

    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
    event Burn(address indexed burner, uint256 value);
}

// ----------------------------------------------------------------------------
// Contract function to receive approval and execute function in one call
// Borrowed from MiniMeToken
contract ApproveAndCallFallBack {
    function receiveApproval(address from, uint256 tokens, address token, bytes data) public;
}

// ----------------------------------------------------------------------------
// Owned contract
contract Owned {
    
    struct Investor {
        address sender;
        uint amount;
        bool kyced;
    }
    
    // version of this smart contract
    string public version = "1.9";
    
    address public owner;
    address public newOwner;
    // reward pool wallet, un-sold tokens will be burned to this address
    address public rewardPoolWallet;
    
    // List of investors with invested amount in ETH
    Investor[] public investors;
    
    mapping(address => uint) public mapInvestors;
    mapping(address => bool) public founders;
    
    event OwnershipTransferred(address indexed _from, address indexed _to);

    function Owned() public {
        owner = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }
    
    // Give KYC status, so token can be traded by this wallet
    function changeKYCStatus(address inv, bool kycStatus) onlyOwner public returns (bool success) {
        require(kycStatus == !investors[mapInvestors[inv]-1].kyced);
        investors[mapInvestors[inv]-1].kyced = kycStatus;
        return true;
    }
    
    function setRewardPoolWallet(address rewardWallet) onlyOwner public returns(bool success) {
        rewardPoolWallet = rewardWallet;
        return true;
    }
    
    function isExistInvestor(address inv) public constant returns (bool exist) {
        return mapInvestors[inv] != 0;
    }
    
    function isExistFounder(address _founder) public constant returns (bool exist) {
        return founders[_founder];
    }
    
    function removeFounder(address _founder) onlyOwner public returns (bool success) {
        require(founders[_founder]);
        founders[_founder] = false;
        return true;
    }
    
    function addFounder(address _founder) onlyOwner public returns (bool success) {
        require(!founders[_founder]);
        founders[_founder] = true;
        return true;
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
// ERC20 Token, with the addition of symbol, name and decimals and an
// initial fixed supply
// ----------------------------------------------------------------------------
contract ELOVEToken is ERC20Interface, Owned {
    using SafeMath for uint;

    string public symbol;
    string public name;
    uint8 public decimals;
    uint public _totalSupply;
    
    uint minInvest = 0.5 ether;
    uint maxInvest = 500 ether;
    
    uint softcap = 5000 ether;
    uint hardcap = 40000 ether;

    uint public icoStartDate;
    
    uint[4] public roundEnd;
    uint[4] public roundTokenLeft;
    uint[4] public roundBonus;
    
    uint public tokenLockTime;
    uint public tokenFounderLockTime;
    bool icoEnded = false;
    bool kycCompleted = false;
    
    mapping(address => uint) balances;
    mapping(address => mapping(address => uint)) allowed;

    uint etherExRate = 2000;

    // ------------------------------------------------------------------------
    // Constructor
    // ------------------------------------------------------------------------
    function ELOVEToken(string tName, string tSymbol) public {
        symbol = tSymbol;
        name = tName;
        decimals = 2;
        _totalSupply = 200000000 * 10**uint(decimals); // 200.000.000 tokens
        
        icoStartDate            = 1518566401;   // 2018/02/14 00:00:01 AM
        
        // Ending time for each round
        // pre-ICO round 1 : ends 28/02/2018, 10M tokens limit, 40% bonus
        // pre-ICO round 2 : ends 15/03/2018, 10M tokens limit, 30% bonus
        // crowdsale round 1 : ends 15/04/2018, 30M tokens limit, 10% bonus
        // crowdsale round 2 : ends 30/04/2018, 30M tokens limit, 0% bonus
        roundEnd = [1519862400, 1521158400, 1523836800, 1525132800];
        roundTokenLeft = [1000000000, 1000000000, 3000000000, 3000000000];
        roundBonus = [40, 30, 10, 0];
        
        // Founder can trade tokens 1 year after ICO ended
        tokenFounderLockTime = roundEnd[3] + 365*24*3600;
        
        // Time to lock all ERC20 transfer 
        tokenLockTime = 1572566400;     // 2019/11/01 after 18 months
        
        balances[owner] = _totalSupply;
        Transfer(address(0), owner, _totalSupply);
    }

    function setRoundEnd(uint round, uint newTime) onlyOwner public returns (bool success)  {
        require(now<newTime);
        if (round>0) {
            require(newTime>roundEnd[round-1]);
        } else {
            require(newTime<roundEnd[1]);
        }

        roundEnd[round] = newTime;
        // If we change ICO ended time, we change also founder trading lock time
        if (round == 3) {
            tokenFounderLockTime = newTime + 365*24*3600;
        }
        return true;
    }
    
    // refund ETH to non-KYCed investors
    function refundNonKYCInvestor() onlyOwner public returns (bool success) {
        require(!kycCompleted);
        for(uint i = 0; i<investors.length; i++) {
            if (!investors[i].kyced) {
                investors[i].sender.transfer(investors[i].amount);    
                investors[i].amount = 0;
            }
        }
        kycCompleted = true;
        return true;
    }
    
    function setSoftCap(uint newSoftCap) onlyOwner public returns (bool success) {
        softcap = newSoftCap;
        return true;
    }
    
    function setEthExRate(uint newExRate) onlyOwner public returns (bool success) {
        etherExRate = newExRate;
        return true;
    }
    
    function setICOStartTime(uint newTime) onlyOwner public returns (bool success) {
        icoStartDate = newTime;
        return true;
    }
    
    function setLockTime(uint newLockTime) onlyOwner public returns (bool success) {
        require(now<newLockTime);
        tokenLockTime = newLockTime;
        return true;
    }

    // ------------------------------------------------------------------------
    // Total supply
    // ------------------------------------------------------------------------
    function totalSupply() public constant returns (uint) {
        return _totalSupply - balances[address(0)];
    }

    // ------------------------------------------------------------------------
    // Get the token balance for account `tokenOwner`
    // ------------------------------------------------------------------------
    function balanceOf(address tokenOwner) public constant returns (uint balance) {
        return balances[tokenOwner];
    }
    
    // ------------------------------------------------------------------------
    // Transfer the balance from token owner's account to `to` account
    // - Owner's account must have sufficient balance to transfer
    // - 0 value transfers are allowed
    // ------------------------------------------------------------------------
    function transfer(address to, uint tokens) public returns (bool success) {
        require(icoEnded);
        // transaction is in tradable period
        require(now<tokenLockTime);
        // either
        // - is founder and current time > tokenFounderLockTime
        // - is not founder but is rewardPoolWallet or sender was kyc-ed
        require((founders[msg.sender] && now>tokenFounderLockTime) || (!founders[msg.sender] && (msg.sender == rewardPoolWallet || mapInvestors[msg.sender] == 0 || investors[mapInvestors[msg.sender]-1].kyced)));
        // sender either is owner or recipient is not 0x0 address
        require(msg.sender == owner || to != 0x0);
        
        balances[msg.sender] = balances[msg.sender].sub(tokens);
        balances[to] = balances[to].add(tokens);
        Transfer(msg.sender, to, tokens);
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
        require(icoEnded);
        // either
        // - is founder and current time > tokenFounderLockTime
        // - is not founder but is rewardPoolWallet or sender was kyc-ed
        require((founders[from] && now>tokenFounderLockTime) || (!founders[from] && (from == rewardPoolWallet || investors[mapInvestors[from]-1].kyced)));
        
        balances[from] = balances[from].sub(tokens);
        allowed[from][msg.sender] = allowed[from][msg.sender].sub(tokens);
        balances[to] = balances[to].add(tokens);
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
    
    function processRound(uint round) internal {
        // Token left for each round must be greater than 0
        require(roundTokenLeft[round]>0);
        // calculate number of tokens can be bought, given number of ether from sender, with discount rate accordingly
        var tokenCanBeBought = (msg.value*10**uint(decimals)*etherExRate*(100+roundBonus[round])).div(100*10**18);
        if (tokenCanBeBought<roundTokenLeft[round]) {
            balances[owner] = balances[owner] - tokenCanBeBought;
            balances[msg.sender] = balances[msg.sender] + tokenCanBeBought;
            roundTokenLeft[round] = roundTokenLeft[round]-tokenCanBeBought;
            
            if (mapInvestors[msg.sender] > 0) {
                // if investors already existed, add amount to the invested sum
                investors[mapInvestors[msg.sender]-1].amount += msg.value;
            } else {
                uint ind = investors.push(Investor(msg.sender, msg.value, false));                
                mapInvestors[msg.sender] = ind;
            }
        } else {
            var neededEtherToBuy = (10**18*roundTokenLeft[round]*100).div(10**uint(decimals)).div(etherExRate*(100+roundBonus[round]));
            balances[owner] = balances[owner] - roundTokenLeft[round];
            balances[msg.sender] = balances[msg.sender] + roundTokenLeft[round];
            roundTokenLeft[round] = 0;
            
            if (mapInvestors[msg.sender] > 0) {
                // if investors already existed, add amount to the invested sum
                investors[mapInvestors[msg.sender]-1].amount += neededEtherToBuy;
            } else {
                uint index = investors.push(Investor(msg.sender, neededEtherToBuy, false));  
                mapInvestors[msg.sender] = index;
            }
            
            // send back ether to sender 
            msg.sender.transfer(msg.value-neededEtherToBuy);
        }
    }

    // ------------------------------------------------------------------------
    // Accept ETH for this crowdsale
    // ------------------------------------------------------------------------
    function () public payable {
        require(!icoEnded);
        uint currentTime = now;
        require (currentTime>icoStartDate);
        require (msg.value>= minInvest && msg.value<=maxInvest);
        
        if (currentTime<roundEnd[0]) {
            processRound(0);
        } else if (currentTime<roundEnd[1]) {
            processRound(1);
        } else if (currentTime<roundEnd[2]) {
            processRound(2);
        } else if (currentTime<roundEnd[3]) {
            processRound(3);
        } else {
            // crowdsale ends, check success conditions
            if (this.balance<softcap) {
                // time to send back funds to investors
                for(uint i = 0; i<investors.length; i++) {
                    investors[i].sender.transfer(investors[i].amount);
                }
            } else {
                // send un-sold tokens to reward address
                require(rewardPoolWallet != address(0));
                uint sumToBurn = roundTokenLeft[0] + roundTokenLeft[1] + roundTokenLeft[2] + roundTokenLeft[3];
                balances[owner] = balances[owner] - sumToBurn;
                balances[rewardPoolWallet] += sumToBurn;
                
                roundTokenLeft[0] = roundTokenLeft[1] = roundTokenLeft[2] = roundTokenLeft[3] = 0;
            }
            
            // give back ETH to sender
            msg.sender.transfer(msg.value);
            icoEnded = true;
        }
    }
    
    function withdrawEtherToOwner() onlyOwner public {   
        require(now>roundEnd[3] && this.balance>softcap);
        owner.transfer(this.balance);
    }

    // ------------------------------------------------------------------------
    // Owner can transfer out any accidentally sent ERC20 tokens
    // ------------------------------------------------------------------------
    function transferAnyERC20Token(address tokenAddress, uint tokens) public onlyOwner returns (bool success) {
        return ERC20Interface(tokenAddress).transfer(owner, tokens);
    }
}

// ----------------------------------------------------------------------------
// Safe maths
// ----------------------------------------------------------------------------
library SafeMath {
    function add(uint a, uint b) internal pure returns (uint c) {
        c = a + b;
        require(c >= a);
    }
    function sub(uint a, uint b) internal pure returns (uint c) {
        require(b <= a);
        c = a - b;
    }
    function mul(uint a, uint b) internal pure returns (uint c) {
        c = a * b;
        require(a == 0 || c / a == b);
    }
    function div(uint a, uint b) internal pure returns (uint c) {
        require(b > 0);
        c = a / b;
    }
}