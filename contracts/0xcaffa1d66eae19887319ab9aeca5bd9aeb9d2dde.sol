pragma solidity ^0.4.8;

// ----------------------------------------------------------------------------------------------
// BokkyPooBah's Autonomous Refundathon Facility Token Contract
//
// A system to incentivise The DAO token holders to withdraw their refunds
//
// Based on Vlad's Safe Token Sale Mechanism Contract
// - https://medium.com/@Vlad_Zamfir/a-safe-token-sale-mechanism-8d73c430ddd1
//
// Enjoy. (c) Bok Consulting Pty Ltd 2017. The MIT Licence.
// ----------------------------------------------------------------------------------------------


contract Owned {
    address public owner;
    event OwnershipTransferred(address indexed _from, address indexed _to);

    function Owned() {
        owner = msg.sender;
    }

    modifier onlyOwner {
        if (msg.sender != owner) throw;
        _;
    }

    function transferOwnership(address newOwner) onlyOwner {
        OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }
}


// ERC Token Standard #20 - https://github.com/ethereum/EIPs/issues/20
contract ERC20Token is Owned {
    uint256 _totalSupply = 0;

    // Balances for each account
    mapping(address => uint256) balances;

    // Owner of account approves the transfer of an amount to another account
    mapping(address => mapping (address => uint256)) allowed;

    // Get the total token supply
    function totalSupply() constant returns (uint256 totalSupply) {
        totalSupply = _totalSupply;
    }

    // Get the account balance of another account with address _owner
    function balanceOf(address _owner) constant returns (uint256 balance) {
        return balances[_owner];
    }

    // Send _value amount of tokens to address _to
    function transfer(address _to, uint256 _amount) returns (bool success) {
        if (balances[msg.sender] >= _amount
            && _amount > 0
            && balances[_to] + _amount > balances[_to]) {
            balances[msg.sender] -= _amount;
            balances[_to] += _amount;
            Transfer(msg.sender, _to, _amount);
            return true;
        } else {
            return false;
        }
    }

    // Allow _spender to withdraw from your account, multiple times, up to the _value amount.
    // If this function is called again it overwrites the current allowance with _value.
    // this function is required for some DEX functionality
    function approve(address _spender, uint256 _amount) returns (bool success) {
        allowed[msg.sender][_spender] = _amount;
        Approval(msg.sender, _spender, _amount);
        return true;
    }

    // Spender of tokens transfer an amount of tokens from the token owner's
    // balance to the spender's account. The owner of the tokens must already
    // have approve(...)-d this transfer
    function transferFrom(
        address _from,
        address _to,
        uint256 _amount
    ) returns (bool success) {
        if (balances[_from] >= _amount
            && allowed[_from][msg.sender] >= _amount
            && _amount > 0
            && balances[_to] + _amount > balances[_to]) {
            balances[_from] -= _amount;
            allowed[_from][msg.sender] -= _amount;
            balances[_to] += _amount;
            Transfer(_from, _to, _amount);
            return true;
        } else {
            return false;
        }
    }

    // Returns the amount of tokens approved by the owner that can be transferred
    // to the spender's account
    function allowance(address _owner, address _spender) constant returns (uint256 remaining) {
        return allowed[_owner][_spender];
    }

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}


contract BokkyPooBahsAutonomousRefundathonFacility is ERC20Token {

    // ------ Token information ------
    string public constant symbol = "BARF";
    string public constant name = "BokkyPooBah Autonomous Refundathon Facility";
    uint8 public constant decimals = 18;

    uint256 public deployedAt;

    function BokkyPooBahsAutonomousRefundathonFacility() {
        deployedAt = now;
    }

    // Members buy tokens from this contract at this price
    //
    // This is a maximum price that the tokens should be bought for buyers
    // can always buy tokens from this contract for this price
    //
    // Check out the BARF prices on https://cryptoderivatives.market/ to see
    // if you can buy these tokens for less than this maximum price
    function buyPrice() constant returns (uint256) {
        // Members buy tokens initially at 1 BARF = 0.01 ETH
        if (now < (deployedAt + 2 days)) {
            return 1 * 10**16;
        // Price increase to 1 BARF = 0.02 ETH after 2 days and before 1 week
        } else if (now < (deployedAt + 7 days)) {
            return 2 * 10**16;
        // Price increase to 1 BARF = 0.04 ETH after 1 week and before 30 days
        } else if (now < (deployedAt + 30 days)) {
            return 4 * 10**16;
        // Price increase to 1 BARF = 0.06 ETH after 30 days and before 60 days
        } else if (now < (deployedAt + 60 days)) {
            return 6 * 10**16;
        // Price increase to 1 BARF = 0.08 ETH after 60 days and before 90 days
        } else if (now < (deployedAt + 90 days)) {
            return 8 * 10**16;
        // Price increase to 1 BARF = 10 ETH after 90 days and before 365 days (1 year)
        } else if (now < (deployedAt + 365 days)) {
            return 1 * 10**19;
        // Price increase to 1 BARF = 1,000 ETH after 365 days and before 3652 days (10 years)
        } else if (now < (deployedAt + 3652 days)) {
            return 1 * 10**22;
        // Price increase to 1 BARF = 1,000,000 ETH after 3652 days (10 years). Effectively free floating ceiling
        } else {
            return 1 * 10**24;
        }
    }

    // Members can always sell to the contract at 1 BARF = 0.01 ETH
    //
    // This is a minimum price that the tokens should sell for as the owner of
    // the token can always sell tokens to this contract at this price
    //
    // Check out the BARF prices on https://cryptoderivatives.market/ to see
    // if you can sell these tokens for more than this minimum price
    function sellPrice() constant returns (uint256) {
        return 10**16;
    }

    // ------ Owner Withdrawal ------
    function amountOfEthersOwnerCanWithdraw() constant returns (uint256) {
        uint256 etherBalance = this.balance;
        uint256 ethersSupportingTokens = _totalSupply * sellPrice() / 1 ether;
        if (etherBalance > ethersSupportingTokens) {
            return etherBalance - ethersSupportingTokens;
        } else {
            return 0;
        }
    }

    function ownerWithdraw(uint256 amount) onlyOwner {
        uint256 maxWithdrawalAmount = amountOfEthersOwnerCanWithdraw();
        if (amount > maxWithdrawalAmount) {
            amount = maxWithdrawalAmount;
        }
        if (!owner.send(amount)) throw;
        Withdrawn(amount, maxWithdrawalAmount - amount);
    }
    event Withdrawn(uint256 amount, uint256 remainingWithdrawal);


    // ------ Member Buy and Sell tokens below ------
    function () payable {
        memberBuyToken();
    }

    function memberBuyToken() payable {
        if (msg.value > 0) {
            uint tokens = msg.value * 1 ether / buyPrice();
            _totalSupply += tokens;
            balances[msg.sender] += tokens;
            MemberBoughtToken(msg.sender, msg.value, this.balance, tokens, _totalSupply,
                buyPrice());
        }
    }
    event MemberBoughtToken(address indexed buyer, uint256 ethers, uint256 newEtherBalance,
        uint256 tokens, uint256 newTotalSupply, uint256 buyPrice);

    function memberSellToken(uint256 amountOfTokens) {
        if (amountOfTokens > balances[msg.sender]) throw;
        balances[msg.sender] -= amountOfTokens;
        _totalSupply -= amountOfTokens;
        uint256 ethersToSend = amountOfTokens * sellPrice() / 1 ether;
        if (!msg.sender.send(ethersToSend)) throw;
        MemberSoldToken(msg.sender, ethersToSend, this.balance, amountOfTokens,
            _totalSupply, sellPrice());
    }
    event MemberSoldToken(address indexed seller, uint256 ethers, uint256 newEtherBalance,
        uint256 tokens, uint256 newTotalSupply, uint256 sellPrice);


    // ------ Information function ------
    function currentEtherBalance() constant returns (uint256) {
        return this.balance;
    }

    function currentTokenBalance() constant returns (uint256) {
        return _totalSupply;
    }
}