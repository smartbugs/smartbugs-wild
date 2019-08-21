pragma solidity ^0.4.8;

// ----------------------------------------------------------------------------
// BokkyPooBah's Ether Refundable Prize
//
// A gift token backed by ethers. Designed to incentivise The DAO refund
// withdrawals, but can be used for any other purposes
//
// These tokens can be bought from this contract at the Buy Price.
//
// These tokens can be sold back to this contract at the Sell Price.
// 
// Period                                ETH per BERP
// ------------------------- ------------------------
// From         To               Buy Price Sell Price
// ------------ ------------ ------------- ----------
// start        +7 days             0.0010     0.0010
// +7 days      +30 days            0.0011     0.0010
// +30 days     +60 days            0.0012     0.0010
// +60 days     +90 days            0.0013     0.0010
// +90 days     +365 days           0.0015     0.0010
// +365 days    forever          1000.0000     0.0010
//
// Based on Vlad's Safe Token Sale Mechanism Contract
// - https://medium.com/@Vlad_Zamfir/a-safe-token-sale-mechanism-8d73c430ddd1
//
// Enjoy. (c) BokkyPooBah / Bok Consulting Pty Ltd 2017. The MIT Licence.
// ----------------------------------------------------------------------------

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

    // Allow _spender to withdraw from your account, multiple times, up to the
    // _value amount. If this function is called again it overwrites the
    // current allowance with _value.
    function approve(
        address _spender,
        uint256 _amount
    ) returns (bool success) {
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

    // Returns the amount of tokens approved by the owner that can be
    // transferred to the spender's account
    function allowance(
        address _owner, 
        address _spender
    ) constant returns (uint256 remaining) {
        return allowed[_owner][_spender];
    }

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender,
        uint256 _value);
}


contract BokkyPooBahsEtherRefundablePrize is ERC20Token {

    // ------------------------------------------------------------------------
    // Token information
    // ------------------------------------------------------------------------
    string public constant symbol = "BERP";
    string public constant name = "BokkyPooBah´s Ether Refundable Prize";
    uint8 public constant decimals = 18;

    uint256 public deployedAt;

    function BokkyPooBahsEtherRefundablePrize() {
        deployedAt = now;
    }


    // ------------------------------------------------------------------------
    // Members buy tokens from this contract at this price
    //
    // This is a maximum price that the tokens should be bought at, as buyers
    // can always buy tokens from this contract for this price
    //
    // Check out the BERP prices on https://cryptoderivatives.market/ to see
    // if you can buy these tokens for less than this maximum price
    // ------------------------------------------------------------------------
    function buyPrice() constant returns (uint256) {
        return buyPriceAt(now);
    }

    function buyPriceAt(uint256 at) constant returns (uint256) {
        if (at < (deployedAt + 7 days)) {
            return 10 * 10**14;
        } else if (at < (deployedAt + 30 days)) {
            return 11 * 10**14;
        } else if (at < (deployedAt + 60 days)) {
            return 12 * 10**15;
        } else if (at < (deployedAt + 90 days)) {
            return 13 * 10**15;
        } else if (at < (deployedAt + 365 days)) {
            return 15 * 10**16;
        } else {
            return 10**21;
        }
    }


    // ------------------------------------------------------------------------
    // Members can always sell to the contract at 1 BERP = 0.001 ETH
    //
    // This is a minimum price that the tokens should sell for, as the owner of
    // the token can always sell tokens to this contract at this price
    //
    // Check out the BERP prices on https://cryptoderivatives.market/ to see
    // if you can sell these tokens for more than this minimum price
    // ------------------------------------------------------------------------
    function sellPrice() constant returns (uint256) {
        return 10**15;
    }


    // ------------------------------------------------------------------------
    // Buy tokens from the contract
    // ------------------------------------------------------------------------
    function () payable {
        buyTokens();
    }

    function buyTokens() payable {
        if (msg.value > 0) {
            uint tokens = msg.value * 1 ether / buyPrice();
            _totalSupply += tokens;
            balances[msg.sender] += tokens;
            TokensBought(msg.sender, msg.value, this.balance, tokens,
                 _totalSupply, buyPrice());
        }
    }
    event TokensBought(address indexed buyer, uint256 ethers, 
        uint256 newEtherBalance, uint256 tokens, uint256 newTotalSupply, 
        uint256 buyPrice);


    // ------------------------------------------------------------------------
    // Sell tokens to the contract
    // ------------------------------------------------------------------------
    function sellTokens(uint256 amountOfTokens) {
        if (amountOfTokens > balances[msg.sender]) throw;
        balances[msg.sender] -= amountOfTokens;
        _totalSupply -= amountOfTokens;
        uint256 ethersToSend = amountOfTokens * sellPrice() / 1 ether;
        if (!msg.sender.send(ethersToSend)) throw;
        TokensSold(msg.sender, ethersToSend, this.balance, amountOfTokens,
            _totalSupply, sellPrice());
    }
    event TokensSold(address indexed seller, uint256 ethers, 
        uint256 newEtherBalance, uint256 tokens, uint256 newTotalSupply, 
        uint256 sellPrice);


    // ------------------------------------------------------------------------
    // Receive deposits. This could be a free donation, or fees earned by
    // a system of payments backing this contract
    // ------------------------------------------------------------------------
    function deposit() payable {
        Deposited(msg.value, this.balance);
    }
    event Deposited(uint256 amount, uint256 balance);


    // ------------------------------------------------------------------------
    // Owner Withdrawal
    // ------------------------------------------------------------------------
    function ownerWithdraw(uint256 amount) onlyOwner {
        uint256 maxWithdrawalAmount = amountOfEthersOwnerCanWithdraw();
        if (amount > maxWithdrawalAmount) {
            amount = maxWithdrawalAmount;
        }
        if (!owner.send(amount)) throw;
        Withdrawn(amount, maxWithdrawalAmount - amount);
    }
    event Withdrawn(uint256 amount, uint256 remainingWithdrawal);


    // ------------------------------------------------------------------------
    // Information function
    // ------------------------------------------------------------------------
    function amountOfEthersOwnerCanWithdraw() constant returns (uint256) {
        uint256 etherBalance = this.balance;
        uint256 ethersSupportingTokens = _totalSupply * sellPrice() / 1 ether;
        if (etherBalance > ethersSupportingTokens) {
            return etherBalance - ethersSupportingTokens;
        } else {
            return 0;
        }
    }

    function currentEtherBalance() constant returns (uint256) {
        return this.balance;
    }

    function currentTokenBalance() constant returns (uint256) {
        return _totalSupply;
    }
}