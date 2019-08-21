pragma solidity ^0.4.17;

// ----------------------------------------------------------------------------
// Copyright (c) 2017 GAT International Limited.
// http://www.gatcoin.io/
//
// The MIT Licence.
// ----------------------------------------------------------------------------
contract Owned {

    address public owner;
    address public newOwner;

    event OwnerChanged(address indexed _newOwner);


    function Owned() public {
        owner = msg.sender;
    }


    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }


    function transferOwnership(address _newOwner) public onlyOwner returns (bool) {
        require(_newOwner != address(0));
        require(_newOwner != owner);

        newOwner = _newOwner;

        return true;
    }


    function acceptOwnership() public returns (bool) {
        require(msg.sender == newOwner);

        owner = msg.sender;

        OwnerChanged(msg.sender);

        return true;
    }
}


contract GATTokenSaleConfig {

    string  public constant SYMBOL                  = "GAT";
    string  public constant NAME                    = "GAT Token";
    uint256 public constant DECIMALS                = 18;

    uint256 public constant DECIMALSFACTOR          = 10**uint256(DECIMALS);
    uint256 public constant START_TIME              = 1513512000; // 2017-12-17T12:00:00Z
    uint256 public constant END_TIME                = 1515326399; // 2018-01-07T11:59:59Z
    uint256 public constant CONTRIBUTION_MIN        = 2 ether;
    uint256 public constant TOKEN_TOTAL_CAP         = 1000000000  * DECIMALSFACTOR;
    uint256 public constant TOKEN_PRIVATE_SALE_CAP  =   54545172  * DECIMALSFACTOR; // past presale
    uint256 public constant TOKEN_PRESALE_CAP       =  145454828  * DECIMALSFACTOR; // 200000000 - what was raised in round 1
    uint256 public constant TOKEN_PUBLIC_SALE_CAP   =  445454828  * DECIMALSFACTOR; // This also includes presale
    uint256 public constant TOKEN_FOUNDATION_CAP    =          0  * DECIMALSFACTOR;
    uint256 public constant TOKEN_RESERVE1_CAP      =  100000000  * DECIMALSFACTOR;
    uint256 public constant TOKEN_RESERVE2_CAP      =          0  * DECIMALSFACTOR;
    uint256 public constant TOKEN_FUTURE_CAP        =  400000000  * DECIMALSFACTOR;

    // Default bonus amount for the presale.
    // 100 = no bonus
    // 120 = 20% bonus.
    // Note that the owner can change the amount of bonus given.
    uint256 public constant PRESALE_BONUS      = 120;

    // Default value for tokensPerKEther based on ETH at 300 USD.
    // The owner can update this value before the sale starts based on the
    // price of ether at that time.
    // E.g. 300 USD/ETH -> 300,000 USD/KETH / 0.2 USD/TOKEN = 1,500,000
    uint256 public constant TOKENS_PER_KETHER = 14800000;
}

library SafeMath {

  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}

contract ERC20Interface {

    uint256 public totalSupply;

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);

    function balanceOf(address _owner) public view returns (uint256 balance);
    function transfer(address _to, uint256 _value) public returns (bool success);
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);
    function approve(address _spender, uint256 _value) public returns (bool success);
    function allowance(address _owner, address _spender) public view returns (uint256 remaining);
}

// Implementation of standard ERC20 token with ownership.
//
contract GATToken is ERC20Interface, Owned {

    using SafeMath for uint256;

    string public symbol;
    string public name;
    uint256 public decimals;

    mapping(address => uint256) balances;
    mapping(address => mapping (address => uint256)) allowed;


    function GATToken(string _symbol, string _name, uint256 _decimals, uint256 _totalSupply) public
        Owned()
    {
        symbol      = _symbol;
        name        = _name;
        decimals    = _decimals;
        totalSupply = _totalSupply;

        Transfer(0x0, owner, _totalSupply);
    }


    function balanceOf(address _owner) public view returns (uint256 balance) {
        return balances[_owner];
    }


    function transfer(address _to, uint256 _value) public returns (bool success) {
        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);

        Transfer(msg.sender, _to, _value);

        return true;
    }


    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        balances[_from] = balances[_from].sub(_value);
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);

        Transfer(_from, _to, _value);

        return true;
     }


     function allowance(address _owner, address _spender) public view returns (uint256 remaining) {
         return allowed[_owner][_spender];
     }


     function approve(address _spender, uint256 _value) public returns (bool success) {
         allowed[msg.sender][_spender] = _value;

         Approval(msg.sender, _spender, _value);

         return true;
     }
}


// This is the main contract that drives the GAT token sale.
// It exposes the ERC20 interface along with various sale-related functions.
//
contract GATTokenSale is GATToken, GATTokenSaleConfig {

    using SafeMath for uint256;

    // Once finalized, tokens will be freely tradable
    bool public finalized;

    // Sale can be suspended or resumed by the owner
    bool public suspended;

    // Addresses for the bank, funding and reserves.
    address public bankAddress;
    address public fundingAddress;
    address public reserve1Address;
    address public reserve2Address;

    // Price of tokens per 1000 ETH
    uint256 public tokensPerKEther;

    // The bonus amount on token purchases
    // E.g. 120 means a 20% bonus will be applied.
    uint256 public bonus;

    // Total number of tokens that have been sold through the sale contract so far.
    uint256 public totalTokensSold;

    // Minimum contribution value
    uint256 public contributionMinimum;

    // Keep track of start time and end time for the sale. These have default
    // values when the contract is deployed but can be changed by owner as needed.
    uint256 public startTime;
    uint256 public endTime;


    // Events
    event TokensPurchased(address indexed beneficiary, uint256 cost, uint256 tokens);
    event TokensPerKEtherUpdated(uint256 newAmount);
    event ContributionMinimumUpdated(uint256 newAmount);
    event BonusAmountUpdated(uint256 newAmount);
    event TimeWindowUpdated(uint256 newStartTime, uint256 newEndTime);
    event SaleSuspended();
    event SaleResumed();
    event TokenFinalized();
    event ContractTokensReclaimed(uint256 amount);

// "0x1a4FBba7231Ec0707925c52b047b951a0BeAA325", "0xa85b419eee304563d3587fe934e932f056ca3c14", "0xa85b419eee304563d3587fe934e932f056ca3c14", "0x587d06eb855811ee987cc842880b9255a3aab45b", 
    function GATTokenSale(address _bankAddress, address _fundingAddress, address _reserve1Address, address _reserve2Address) public
        GATToken(SYMBOL, NAME, DECIMALS, 0)
    {
        // Can only create the contract is the sale has not yet started or ended.
        require(START_TIME >= currentTime());
        require(END_TIME > START_TIME);

        // Need valid wallet addresses
        require(_bankAddress    != address(0x0));
        require(_bankAddress    != address(this));
        require(_fundingAddress != address(0x0));
        require(_fundingAddress != address(this));
        require(_reserve1Address != address(0x0));
        require(_reserve1Address != address(this));
        require(_reserve2Address != address(0x0));
        require(_reserve2Address != address(this));

        uint256 salesTotal = TOKEN_PUBLIC_SALE_CAP.add(TOKEN_PRIVATE_SALE_CAP);
        require(salesTotal.add(TOKEN_FUTURE_CAP).add(TOKEN_FOUNDATION_CAP).add(TOKEN_RESERVE1_CAP).add(TOKEN_RESERVE2_CAP) == TOKEN_TOTAL_CAP);

        // Start in non-finalized state
        finalized = false;
        suspended = false;

        // Start and end times (used for presale).
        startTime = START_TIME;
        endTime   = END_TIME;

        // Initial pricing
        tokensPerKEther = TOKENS_PER_KETHER;

        // Initial contribution minimum
        contributionMinimum = CONTRIBUTION_MIN;

        // Bonus for contributions
        bonus = PRESALE_BONUS;

        // Initialize wallet addresses
        bankAddress    = _bankAddress;
        fundingAddress = _fundingAddress;
        reserve1Address = _reserve1Address;
        reserve2Address = _reserve2Address;

        // Assign initial balances
        balances[address(this)] = balances[address(this)].add(TOKEN_PRESALE_CAP);
        totalSupply = totalSupply.add(TOKEN_PRESALE_CAP);
        Transfer(0x0, address(this), TOKEN_PRESALE_CAP);

        balances[reserve1Address] = balances[reserve1Address].add(TOKEN_RESERVE1_CAP);
        totalSupply = totalSupply.add(TOKEN_RESERVE1_CAP);
        Transfer(0x0, reserve1Address, TOKEN_RESERVE1_CAP);

        balances[reserve2Address] = balances[reserve2Address].add(TOKEN_RESERVE2_CAP);
        totalSupply = totalSupply.add(TOKEN_RESERVE2_CAP);
        Transfer(0x0, reserve2Address, TOKEN_RESERVE2_CAP);

        uint256 bankBalance = TOKEN_TOTAL_CAP.sub(totalSupply);
        balances[bankAddress] = balances[bankAddress].add(bankBalance);
        totalSupply = totalSupply.add(bankBalance);
        Transfer(0x0, bankAddress, bankBalance);

        // The total supply that we calculated here should be the same as in the config.
        require(balanceOf(address(this))  == TOKEN_PRESALE_CAP);
        require(balanceOf(reserve1Address) == TOKEN_RESERVE1_CAP);
        require(balanceOf(reserve2Address) == TOKEN_RESERVE2_CAP);
        require(balanceOf(bankAddress)    == bankBalance);
        require(totalSupply == TOKEN_TOTAL_CAP);
    }


    function currentTime() public constant returns (uint256) {
        return now;
    }


    // Allows the owner to change the price for tokens.
    //
    function setTokensPerKEther(uint256 _tokensPerKEther) external onlyOwner returns(bool) {
        require(_tokensPerKEther > 0);

        // Set the tokensPerKEther amount for any new sale.
        tokensPerKEther = _tokensPerKEther;

        TokensPerKEtherUpdated(_tokensPerKEther);

        return true;
    }

    // Allows the owner to change the minimum contribution amount
    //
    function setContributionMinimum(uint256 _contributionMinimum) external onlyOwner returns(bool) {
        require(_contributionMinimum > 0);

        // Set the tokensPerKEther amount for any new sale.
        contributionMinimum = _contributionMinimum;

        ContributionMinimumUpdated(_contributionMinimum);

        return true;
    }

    // Allows the owner to change the bonus amount applied to purchases.
    //
    function setBonus(uint256 _bonus) external onlyOwner returns(bool) {
        // 100 means no bonus
        require(_bonus >= 100);

        // 200 means 100% bonus
        require(_bonus <= 200);

        bonus = _bonus;

        BonusAmountUpdated(_bonus);

        return true;
    }


    // Allows the owner to change the time window for the sale.
    //
    function setTimeWindow(uint256 _startTime, uint256 _endTime) external onlyOwner returns(bool) {
        require(_startTime >= START_TIME);
        require(_endTime > _startTime);

        startTime = _startTime;
        endTime   = _endTime;

        TimeWindowUpdated(_startTime, _endTime);

        return true;
    }


    // Allows the owner to suspend / stop the sale.
    //
    function suspend() external onlyOwner returns(bool) {
        if (suspended == true) {
            return false;
        }

        suspended = true;

        SaleSuspended();

        return true;
    }


    // Allows the owner to resume the sale.
    //
    function resume() external onlyOwner returns(bool) {
        if (suspended == false) {
            return false;
        }

        suspended = false;

        SaleResumed();

        return true;
    }


    // Accept ether contributions during the token sale.
    //
    function () payable public {
        buyTokens(msg.sender);
    }


    // Allows the caller to buy tokens for another recipient (proxy purchase).
    // This can be used by exchanges for example.
    //
    function buyTokens(address beneficiary) public payable returns (uint256) {
        require(!suspended);
        require(beneficiary != address(0x0));
        require(beneficiary != address(this));
        require(currentTime() >= startTime);
        require(currentTime() <= endTime);
        require(msg.value >= contributionMinimum);
        require(msg.sender != fundingAddress);

        // Check if the sale contract still has tokens for sale.
        uint256 saleBalance = balanceOf(address(this));
        require(saleBalance > 0);

        // Calculate the number of tokens that the ether should convert to.
        uint256 tokens = msg.value.mul(tokensPerKEther).mul(bonus).div(10**(18 - DECIMALS + 3 + 2));
        require(tokens > 0);

        uint256 cost = msg.value;
        uint256 refund = 0;

        if (tokens > saleBalance) {
            // Not enough tokens left for sale to fulfill the full order.
            tokens = saleBalance;

            // Calculate the actual cost for the tokens that can be purchased.
            cost = tokens.mul(10**(18 - DECIMALS + 3 + 2)).div(tokensPerKEther.mul(bonus));

            // Calculate the amount of ETH refund to the contributor.
            refund = msg.value.sub(cost);
        }

        totalTokensSold = totalTokensSold.add(tokens);

        // Move tokens from the sale contract to the beneficiary
        balances[address(this)] = balances[address(this)].sub(tokens);
        balances[beneficiary]   = balances[beneficiary].add(tokens);
        Transfer(address(this), beneficiary, tokens);

        if (refund > 0) {
           msg.sender.transfer(refund);
        }

        // Transfer the contributed ether to the crowdsale wallets.
        uint256 contribution      = msg.value.sub(refund);

        fundingAddress.transfer(contribution);

        TokensPurchased(beneficiary, cost, tokens);

        return tokens;
    }


    // ERC20 transfer function, modified to only allow transfers once the sale has been finalized.
    //
    function transfer(address _to, uint256 _amount) public returns (bool success) {
        if (!isTransferAllowed(msg.sender, _to)) {
            return false;
        }

        return super.transfer(_to, _amount);
    }


    // ERC20 transferFrom function, modified to only allow transfers once the sale has been finalized.
    //
    function transferFrom(address _from, address _to, uint256 _amount) public returns (bool success) {
        if (!isTransferAllowed(_from, _to)) {
            return false;
        }

        return super.transferFrom(_from, _to, _amount);
    }


    // Internal helper to check if the transfer should be allowed
    //
    function isTransferAllowed(address _from, address _to) private view returns (bool) {
        if (finalized) {
            // We allow everybody to transfer tokens once the sale is finalized.
            return true;
        }

        if (_from == bankAddress || _to == bankAddress) {
            // We allow the bank to initiate transfers. We also allow it to be the recipient
            // of transfers before the token is finalized in case a recipient wants to send
            // back tokens. E.g. KYC requirements cannot be met.
            return true;
        }

        return false;
    }


    // Allows owner to transfer tokens assigned to the sale contract, back to the bank wallet.
    function reclaimContractTokens() external onlyOwner returns (bool) {
        uint256 tokens = balanceOf(address(this));

        if (tokens == 0) {
            return false;
        }

        balances[address(this)] = balances[address(this)].sub(tokens);
        balances[bankAddress]   = balances[bankAddress].add(tokens);
        Transfer(address(this), bankAddress, tokens);

        ContractTokensReclaimed(tokens);

        return true;
    }


    // Allows the owner to finalize the sale and allow tokens to be traded.
    //
    function finalize() external onlyOwner returns (bool) {
        require(!finalized);

        finalized = true;

        TokenFinalized();

        return true;
    }
}