pragma solidity ^0.4.19;


contract Owned
{
    address public owner;

    modifier onlyOwner
	{
        require(msg.sender == owner);
        _;
    }

    function transferOwnership(address newOwner) public onlyOwner()
	{
        owner = newOwner;
    }
}

contract Agricoin is Owned
{
    // Dividends payout struct.
    struct DividendPayout
    {
        uint amount;            // Value of dividend payout.
        uint momentTotalSupply; // Total supply in payout moment,
    }

    // Redemption payout struct.
    struct RedemptionPayout
    {
        uint amount;            // Value of redemption payout.
        uint momentTotalSupply; // Total supply in payout moment.
        uint price;             // Price of Agricoin in weis.
    }

    // Balance struct with dividends and redemptions record.
    struct Balance
    {
        uint icoBalance;
        uint balance;                       // Agricoin balance.
        uint posibleDividends;              // Dividend number, which user can get.
        uint lastDividensPayoutNumber;      // Last dividend payout index, which user has gotten.
        uint posibleRedemption;             // Redemption value in weis, which user can use.
        uint lastRedemptionPayoutNumber;    // Last redemption payout index, which user has used.
    }

    // Can act only one from payers.
    modifier onlyPayer()
    {
        require(payers[msg.sender]);
        _;
    }
    
    // Can act only after token activation.
    modifier onlyActivated()
    {
        require(isActive);
        _;
    }

    // Transfer event.
    event Transfer(address indexed _from, address indexed _to, uint _value);    

    // Approve event.
    event Approval(address indexed _owner, address indexed _spender, uint _value);

    // Activate event.
    event Activate(bool icoSuccessful);

    // DividendPayout dividends event.
    event PayoutDividends(uint etherAmount, uint indexed id);

    // DividendPayout redemption event.
    event PayoutRedemption(uint etherAmount, uint indexed id, uint price);

    // Get unpaid event.
    event GetUnpaid(uint etherAmount);

    // Get dividends.
    event GetDividends(address indexed investor, uint etherAmount);

    // Constructor.
    function Agricoin(uint payout_period_start, uint payout_period_end, address _payer) public
    {
        owner = msg.sender;// Save the owner.

        // Set payout period.
        payoutPeriodStart = payout_period_start;
        payoutPeriodEnd = payout_period_end;

        payers[_payer] = true;
    }

    // Activate token.
	function activate(bool icoSuccessful) onlyOwner() external returns (bool)
	{
		require(!isActive);// Check once activation.

        startDate = now;// Save activation date.
		isActive = true;// Make token active.
		owner = 0x00;// Set owner to null.
		
        if (icoSuccessful)
        {
            isSuccessfulIco = true;
            totalSupply += totalSupplyOnIco;
            Activate(true);// Call activation event.
        }
        else
        {
            Activate(false);// Call activation event.
        }

        return true;
	}

    // Add new payer by payer.
    function addPayer(address payer) onlyPayer() external
    {
        payers[payer] = true;
    }

    // Get balance of address.
	function balanceOf(address owner) public view returns (uint)
	{
		return balances[owner].balance;
	}

    // Get posible dividends value.
    function posibleDividendsOf(address owner) public view returns (uint)
    {
        return balances[owner].posibleDividends;
    }

    // Get posible redemption value.
    function posibleRedemptionOf(address owner) public view returns (uint)
    {
        return balances[owner].posibleRedemption;
    }

    // Transfer _value etheres to _to.
    function transfer(address _to, uint _value) onlyActivated() external returns (bool)
    {
        require(balanceOf(msg.sender) >= _value);

        recalculate(msg.sender);// Recalculate user's struct.
        
        if (_to != 0x00)// For normal transfer.
        {
            recalculate(_to);// Recalculate recipient's struct.

            // Change balances.
            balances[msg.sender].balance -= _value;
            balances[_to].balance += _value;

            Transfer(msg.sender, _to, _value);// Call transfer event.
        }
        else// For redemption transfer.
        {
            require(payoutPeriodStart <= now && now >= payoutPeriodEnd);// Check redemption period.
            
            uint amount = _value * redemptionPayouts[amountOfRedemptionPayouts].price;// Calculate amount of weis in redemption.

            require(amount <= balances[msg.sender].posibleRedemption);// Check redemption limits.

            // Change user's struct.
            balances[msg.sender].posibleRedemption -= amount;
            balances[msg.sender].balance -= _value;

            totalSupply -= _value;// Decrease total supply.

            msg.sender.transfer(amount);// Transfer redemption to user.

            Transfer(msg.sender, _to, _value);// Call transfer event.
        }

        return true;
    }

    // Transfer from _from to _to _value tokens.
    function transferFrom(address _from, address _to, uint _value) onlyActivated() external returns (bool)
    {
        // Check transfer posibility.
        require(balances[_from].balance >= _value);
        require(allowed[_from][msg.sender] >= _value);
        require(_to != 0x00);

        // Recalculate structs.
        recalculate(_from);
        recalculate(_to);

        // Change balances.
        balances[_from].balance -= _value;
        balances[_to].balance += _value;
        
        Transfer(_from, _to, _value);// Call tranfer event.
        
        return true;
    }

    // Approve for transfers.
    function approve(address _spender, uint _value) onlyActivated() public returns (bool)
    {
        // Recalculate structs.
        recalculate(msg.sender);
        recalculate(_spender);

        allowed[msg.sender][_spender] = _value;// Set allowed.
        
        Approval(msg.sender, _spender, _value);// Call approval event.
        
        return true;
    }

    // Get allowance.
    function allowance(address _owner, address _spender) onlyActivated() external view returns (uint)
    {
        return allowed[_owner][_spender];
    }

    // Mint _value tokens to _to address.
    function mint(address _to, uint _value, bool icoMinting) onlyOwner() external returns (bool)
    {
        require(!isActive);// Check no activation.

        if (icoMinting)
        {
            balances[_to].icoBalance += _value;
            totalSupplyOnIco += _value;
        }
        else
        {
            balances[_to].balance += _value;// Increase user's balance.
            totalSupply += _value;// Increase total supply.

            Transfer(0x00, _to, _value);// Call transfer event.
        }
        
        return true;
    }

    // Pay dividends.
    function payDividends() onlyPayer() onlyActivated() external payable returns (bool)
    {
        require(now >= payoutPeriodStart && now <= payoutPeriodEnd);// Check payout period.

        dividendPayouts[amountOfDividendsPayouts].amount = msg.value;// Set payout amount in weis.
        dividendPayouts[amountOfDividendsPayouts].momentTotalSupply = totalSupply;// Save total supply on that moment.
        
        PayoutDividends(msg.value, amountOfDividendsPayouts);// Call dividend payout event.

        amountOfDividendsPayouts++;// Increment dividend payouts amount.

        return true;
    }

    // Pay redemption.
    function payRedemption(uint price) onlyPayer() onlyActivated() external payable returns (bool)
    {
        require(now >= payoutPeriodStart && now <= payoutPeriodEnd);// Check payout period.

        redemptionPayouts[amountOfRedemptionPayouts].amount = msg.value;// Set payout amount in weis.
        redemptionPayouts[amountOfRedemptionPayouts].momentTotalSupply = totalSupply;// Save total supply on that moment.
        redemptionPayouts[amountOfRedemptionPayouts].price = price;// Set price of Agricoin in weis at this redemption moment.

        PayoutRedemption(msg.value, amountOfRedemptionPayouts, price);// Call redemption payout event.

        amountOfRedemptionPayouts++;// Increment redemption payouts amount.

        return true;
    }

    // Get back unpaid dividends and redemption.
    function getUnpaid() onlyPayer() onlyActivated() external returns (bool)
    {
        require(now >= payoutPeriodEnd);// Check end payout period.

        GetUnpaid(this.balance);// Call getting unpaid ether event.

        msg.sender.transfer(this.balance);// Transfer all ethers back to payer.

        return true;
    }

    // Recalculates dividends and redumptions.
    function recalculate(address user) onlyActivated() public returns (bool)
    {
        if (isSuccessfulIco)
        {
            if (balances[user].icoBalance != 0)
            {
                balances[user].balance += balances[user].icoBalance;
                Transfer(0x00, user, balances[user].icoBalance);
                balances[user].icoBalance = 0;
            }
        }

        // Check for necessity of recalculation.
        if (balances[user].lastDividensPayoutNumber == amountOfDividendsPayouts &&
            balances[user].lastRedemptionPayoutNumber == amountOfRedemptionPayouts)
        {
            return true;
        }

        uint addedDividend = 0;

        // For dividends.
        for (uint i = balances[user].lastDividensPayoutNumber; i < amountOfDividendsPayouts; i++)
        {
            addedDividend += (balances[user].balance * dividendPayouts[i].amount) / dividendPayouts[i].momentTotalSupply;
        }

        balances[user].posibleDividends += addedDividend;
        balances[user].lastDividensPayoutNumber = amountOfDividendsPayouts;

        uint addedRedemption = 0;

        // For redemption.
        for (uint j = balances[user].lastRedemptionPayoutNumber; j < amountOfRedemptionPayouts; j++)
        {
            addedRedemption += (balances[user].balance * redemptionPayouts[j].amount) / redemptionPayouts[j].momentTotalSupply;
        }

        balances[user].posibleRedemption += addedRedemption;
        balances[user].lastRedemptionPayoutNumber = amountOfRedemptionPayouts;

        return true;
    }

    // Get dividends.
    function () external payable
    {
        if (payoutPeriodStart >= now && now <= payoutPeriodEnd)// Check payout period.
        {
            if (posibleDividendsOf(msg.sender) > 0)// Check posible dividends.
            {
                uint dividendsAmount = posibleDividendsOf(msg.sender);// Get posible dividends amount.

                GetDividends(msg.sender, dividendsAmount);// Call getting dividends event.

                balances[msg.sender].posibleDividends = 0;// Set balance to zero.

                msg.sender.transfer(dividendsAmount);// Transfer dividends amount.
            }
        }
    }

    // Token name.
    string public constant name = "Agricoin";
    
    // Token market symbol.
    string public constant symbol = "AGR";
    
    // Amount of digits after comma.
    uint public constant decimals = 2;

    // Total supply.
    uint public totalSupply;

    // Total supply on ICO only;
    uint public totalSupplyOnIco;
       
    // Activation date.
    uint public startDate;
    
    // Payment period start date, setted by ICO contract before activation.
    uint public payoutPeriodStart;
    
    // Payment period last date, setted by ICO contract before activation.
    uint public payoutPeriodEnd;
    
    // Dividends DividendPayout counter.
    uint public amountOfDividendsPayouts = 0;

    // Redemption DividendPayout counter.
    uint public amountOfRedemptionPayouts = 0;

    // Dividend payouts.
    mapping (uint => DividendPayout) public dividendPayouts;
    
    // Redemption payouts.
    mapping (uint => RedemptionPayout) public redemptionPayouts;

    // Dividend and redemption payers.
    mapping (address => bool) public payers;

    // Balance records.
    mapping (address => Balance) public balances;

    // Allowed balances.
    mapping (address => mapping (address => uint)) public allowed;

    // Set true for activating token. If false then token isn't working.
    bool public isActive = false;

    // Set true for activate ico minted tokens.
    bool public isSuccessfulIco = false;
}


contract Ico is Owned
{
    enum State
    {
        Runned,     // Ico is running.
        Paused,     // Ico was paused.
        Finished,   // Ico has finished successfully.
        Expired,    // Ico has finished unsuccessfully.
        Failed
    }

    // Refund event.
    event Refund(address indexed investor, uint amount);

    // Investment event.
    event Invested(address indexed investor, uint amount);

    // End of ICO event.
    event End(bool result);

    // Ico constructor.
    function Ico(
        address tokenAddress,       // Agricoin contract address.
        uint tokenPreIcoPrice,      // Price of Agricoin in weis on Pre-ICO.
        uint tokenIcoPrice,         // Price of Agricoin in weis on ICO.
        uint preIcoStart,           // Date of Pre-ICO start.
        uint preIcoEnd,             // Date of Pre-ICO end.
        uint icoStart,              // Date of ICO start.
        uint icoEnd,                // Date of ICO end.
        uint preIcoEmissionTarget,  // Max number of Agricoins, which will be minted on Pre-ICO.
        uint icoEmissionTarget,     // Max number of Agricoins, which will be minted on ICO.
        uint icoSoftCap,
        address bountyAddress) public
    {
        owner = msg.sender;
        token = tokenAddress;
        state = State.Runned;
        
        // Save prices.
        preIcoPrice = tokenPreIcoPrice;
        icoPrice = tokenIcoPrice;

        // Save dates.
        startPreIcoDate = preIcoStart;
        endPreIcoDate = preIcoEnd;
        startIcoDate = icoStart;
        endIcoDate = icoEnd;

        preIcoTarget = preIcoEmissionTarget;
        icoTarget = icoEmissionTarget;
        softCap = icoSoftCap;

        bounty = bountyAddress;
    }

    // Returns true if ICO is active now.
    function isActive() public view returns (bool)
    {
        return state == State.Runned;
    }

    // Returns true if date in Pre-ICO period.
    function isRunningPreIco(uint date) public view returns (bool)
    {
        return startPreIcoDate <= date && date <= endPreIcoDate;
    }

    // Returns true if date in ICO period.
    function isRunningIco(uint date) public view returns (bool)
    {
        return startIcoDate <= date && date <= endIcoDate;
    }

    // Fallback payable function.
    function () external payable
    {
        // Initialize variables here.
        uint value;
        uint rest;
        uint amount;
        
        if (state == State.Failed)
        {
            amount = invested[msg.sender] + investedOnPreIco[msg.sender];// Save amount of invested weis for user.
            invested[msg.sender] = 0;// Set amount of invested weis to zero.
            investedOnPreIco[msg.sender] = 0;
            Refund(msg.sender, amount);// Call refund event.
            msg.sender.transfer(amount + msg.value);// Returns funds to user.
            return;
        }

        if (state == State.Expired)// Unsuccessful end of ICO.
        {
            amount = invested[msg.sender];// Save amount of invested weis for user.
            invested[msg.sender] = 0;// Set amount of invested weis to zero.
            Refund(msg.sender, amount);// Call refund event.
            msg.sender.transfer(amount + msg.value);// Returns funds to user.
            return;
        }

        require(state == State.Runned);// Only for active contract.

        if (now >= endIcoDate)// After ICO period.
        {
            if (Agricoin(token).totalSupply() + Agricoin(token).totalSupplyOnIco() >= softCap)// Minted Agricoin amount above fixed SoftCap.
            {
                state = State.Finished;// Set state to Finished.

                // Get Agricoin info for bounty.
                uint decimals = Agricoin(token).decimals();
                uint supply = Agricoin(token).totalSupply() + Agricoin(token).totalSupplyOnIco();
                
                // Transfer bounty funds to Bounty contract.
                if (supply >= 1500000 * decimals)
                {
                    Agricoin(token).mint(bounty, 300000 * decimals, true);
                }
                else if (supply >= 1150000 * decimals)
                {
                    Agricoin(token).mint(bounty, 200000 * decimals, true);
                }
                else if (supply >= 800000 * decimals)
                {
                    Agricoin(token).mint(bounty, 100000 * decimals, true);
                }
                
                Agricoin(token).activate(true);// Activate Agricoin contract.
                End(true);// Call successful end event.
                msg.sender.transfer(msg.value);// Returns user's funds to user.
                return;
            }
            else// Unsuccessful end.
            {
                state = State.Expired;// Set state to Expired.
                Agricoin(token).activate(false);// Activate Agricoin contract.
                msg.sender.transfer(msg.value);// Returns user's funds to user.
                End(false);// Call unsuccessful end event.
                return;
            }
        }
        else if (isRunningPreIco(now))// During Pre-ICO.
        {
            require(investedSumOnPreIco / preIcoPrice < preIcoTarget);// Check for target.

            if ((investedSumOnPreIco + msg.value) / preIcoPrice >= preIcoTarget)// Check for target with new weis.
            {
                value = preIcoTarget * preIcoPrice - investedSumOnPreIco;// Value of invested weis without change.
                require(value != 0);// Check value isn't zero.
                investedSumOnPreIco = preIcoTarget * preIcoPrice;// Max posible number of invested weis in to Pre-ICO.
                investedOnPreIco[msg.sender] += value;// Increase invested funds by investor.
                Invested(msg.sender, value);// Call investment event.
                Agricoin(token).mint(msg.sender, value / preIcoPrice, false);// Mint some Agricoins for investor.
                msg.sender.transfer(msg.value - value);// Returns change to investor.
                return;
            }
            else
            {
                rest = msg.value % preIcoPrice;// Calculate rest/change.
                require(msg.value - rest >= preIcoPrice);
                investedSumOnPreIco += msg.value - rest;
                investedOnPreIco[msg.sender] += msg.value - rest;
                Invested(msg.sender, msg.value - rest);// Call investment event.
                Agricoin(token).mint(msg.sender, msg.value / preIcoPrice, false);// Mint some Agricoins for investor.
                msg.sender.transfer(rest);// Returns change to investor.
                return;
            }
        }
        else if (isRunningIco(now))// During ICO.
        {
            require(investedSumOnIco / icoPrice < icoTarget);// Check for target.

            if ((investedSumOnIco + msg.value) / icoPrice >= icoTarget)// Check for target with new weis.
            {
                value = icoTarget * icoPrice - investedSumOnIco;// Value of invested weis without change.
                require(value != 0);// Check value isn't zero.
                investedSumOnIco = icoTarget * icoPrice;// Max posible number of invested weis in to ICO.
                invested[msg.sender] += value;// Increase invested funds by investor.
                Invested(msg.sender, value);// Call investment event.
                Agricoin(token).mint(msg.sender, value / icoPrice, true);// Mint some Agricoins for investor.
                msg.sender.transfer(msg.value - value);// Returns change to investor.
                return;
            }
            else
            {
                rest = msg.value % icoPrice;// Calculate rest/change.
                require(msg.value - rest >= icoPrice);
                investedSumOnIco += msg.value - rest;
                invested[msg.sender] += msg.value - rest;
                Invested(msg.sender, msg.value - rest);// Call investment event.
                Agricoin(token).mint(msg.sender, msg.value / icoPrice, true);// Mint some Agricoins for investor.
                msg.sender.transfer(rest);// Returns change to investor.
                return;
            }
        }
        else
        {
            revert();
        }
    }

    // Pause contract.
    function pauseIco() onlyOwner external
    {
        require(state == State.Runned);// Only from Runned state.
        state = State.Paused;// Set state to Paused.
    }

    // Continue paused contract.
    function continueIco() onlyOwner external
    {
        require(state == State.Paused);// Only from Paused state.
        state = State.Runned;// Set state to Runned.
    }

    // End contract unsuccessfully.
    function endIco() onlyOwner external
    {
        require(state == State.Paused);// Only from Paused state.
        state = State.Failed;// Set state to Expired.
    }

    // Get invested ethereum.
    function getEthereum() onlyOwner external returns (uint)
    {
        require(state == State.Finished);// Only for successfull ICO.
        uint amount = this.balance;// Save balance.
        msg.sender.transfer(amount);// Transfer all funds to owner address.
        return amount;// Returns amount of transfered weis.
    }

    // Get invested ethereum from Pre ICO.
    function getEthereumFromPreIco() onlyOwner external returns (uint)
    {
        require(now >= endPreIcoDate);
        require(state == State.Runned || state == State.Finished);
        
        uint value = investedSumOnPreIco;
        investedSumOnPreIco = 0;
        msg.sender.transfer(value);
        return value;
    }

    // Invested balances.
    mapping (address => uint) invested;

    mapping (address => uint) investedOnPreIco;

    // State of contract.
    State public state;

    // Agricoin price in weis on Pre-ICO.
    uint public preIcoPrice;

    // Agricoin price in weis on ICO.
    uint public icoPrice;

    // Date of Pre-ICO start.
    uint public startPreIcoDate;

    // Date of Pre-ICO end.
    uint public endPreIcoDate;

    // Date of ICO start.
    uint public startIcoDate;

    // Date of ICO end.
    uint public endIcoDate;

    // Agricoin contract address.
    address public token;

    // Bounty contract address.
    address public bounty;

    // Invested sum in weis on Pre-ICO.
    uint public investedSumOnPreIco = 0;

    // Invested sum in weis on ICO.
    uint public investedSumOnIco = 0;

    // Target in tokens minted on Pre-ICo.
    uint public preIcoTarget;

    // Target in tokens minted on ICO.
    uint public icoTarget;

    // SoftCap fot this ICO.
    uint public softCap;
}