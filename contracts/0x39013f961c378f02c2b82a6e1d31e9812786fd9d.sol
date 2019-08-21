pragma solidity ^0.4.8;

/**
SMSCoin is a token implementation for Speed Mining Service (SMS) project.
We are aim to issue the SMS tokens to give the privilege to the closed group of investors,
as then they will be able to receive the devidends from our mining farm in Hokkaido and the other countries as well.

Our cloudsale starts from 27 October 2017, 14:00 (JST) with the different bonus ratio based on the number of token and the sale period.

SMS coin team,
https://smscoin.jp
https://github.com/Speed-Mining/SMSCoin
https://etherscan.io/address/0x39013f961c378f02c2b82a6e1d31e9812786fd9d
 */

library SMSLIB {
    /**
     * Divide with safety check
     */
    function safeDiv(uint a, uint b) pure internal returns(uint) {
        //overflow check; b must not be 0
        assert(b > 0);
        uint c = a / b;
        assert(a == b * c + a % b);
        return c;
    }
}

contract ERC20 {
    // Standard interface
    function totalSupply() public constant returns(uint256 _totalSupply);
    function balanceOf(address who) public constant returns(uint256 balance);
    function transfer(address to, uint value) public returns(bool success);
    function transferFrom(address from, address to, uint value) public returns(bool success);
    function approve(address spender, uint value) public returns(bool success);
    function allowance(address owner, address spender) public constant returns(uint remaining);
    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);
}

contract SMSCoin is ERC20 {
    string public constant name = "Speed Mining Service";
    string public constant symbol = "SMS";
    uint256 public constant decimals = 3;

    uint256 public constant UNIT = 10 ** decimals;

    uint public totalSupply = 0; // (initial with 0), targeted 2.9 Million SMS

    uint tokenSaleLot1 = 150000 * UNIT;
    uint reservedBonusLot1 = 45000 * UNIT; // 45,000 tokens are the maximum possible bonus from 30% of 150,000 tokens in the bonus phase
    uint tokenSaleLot3X = 50000 * UNIT;

    struct BonusStruct {
        uint8 ratio1;
        uint8 ratio2;
        uint8 ratio3;
        uint8 ratio4;
    }
    BonusStruct bonusRatio;

    uint public saleCounterThisPhase = 0;

    uint public limitedSale = 0;

    uint public sentBonus = 0;

    uint public soldToken = 0;

    mapping(address => uint) balances;

    mapping(address => mapping(address => uint)) allowed;

    address[] addresses;
    address[] investorAddresses;

    mapping(address => address) private userStructs;

    address owner;

    address mint = address(this);   // Contract address as a minter
    
    address genesis = 0x0;

    uint256 public tokenPrice = 0.8 ether;
    uint256 public firstMembershipPurchase = 0.16 ether;   // White card membership

    event Log(uint e);

    event Message(string msg);

    event TOKEN(string e);

    bool icoOnSale = false;

    bool icoOnPaused = false;

    bool spPhase = false;

    uint256 startDate;

    uint256 endDate;

    uint currentPhase = 0;

    bool needToDrain = false;

    modifier onlyOwner() {
        if (msg.sender != owner) {
            revert();
        }
        _;
    }

    function SMSCoin() public {
        owner = msg.sender;
    }

    function setBonus(uint8 ratio1, uint8 ratio2, uint8 ratio3, uint8 ratio4) private {
        bonusRatio.ratio1 = ratio1;
        bonusRatio.ratio2 = ratio2;
        bonusRatio.ratio3 = ratio3;
        bonusRatio.ratio4 = ratio4;
    }

    function calcBonus(uint256 sendingSMSToken) view private returns(uint256) {
        // Calculating bonus
        if (sendingSMSToken < (10 * UNIT)) {            // 0-9
            return (sendingSMSToken * bonusRatio.ratio1) / 100;
        } else if (sendingSMSToken < (50 * UNIT)) {     // 10-49
            return (sendingSMSToken * bonusRatio.ratio2) / 100;
        } else if (sendingSMSToken < (100 * UNIT)) {    // 50-99
            return (sendingSMSToken * bonusRatio.ratio3) / 100;
        } else {                                        // 100+
            return (sendingSMSToken * bonusRatio.ratio4) / 100;
        }
    }

    // Selling SMS token
    function () public payable {
        uint256 receivedETH = 0;
        uint256 receivedETHUNIT = 0;
        uint256 sendingSMSToken = 0;
        uint256 sendingSMSBonus = 0;
        Log(msg.value);

        // Only for selling to investors
        if (icoOnSale && !icoOnPaused && msg.sender != owner) {
            if (now <= endDate) {
                // All the phases
                Log(currentPhase);
                
                receivedETH = msg.value;
                // Check if the investor already joined and completed membership payment
                // If a new investor, check if the first purchase is at least equal to the membership price
                if ((checkAddress(msg.sender) && checkMinBalance(msg.sender)) || firstMembershipPurchase <= receivedETH) {
                    // Calculating SMS
                    receivedETHUNIT = receivedETH * UNIT;
                    sendingSMSToken = SMSLIB.safeDiv(receivedETHUNIT, tokenPrice);
                    Log(sendingSMSToken);

                    // Calculating Bonus
                    if (currentPhase == 1 || currentPhase == 2 || currentPhase == 3) {
                        // Phase 1-3 with Bonus 1
                        sendingSMSBonus = calcBonus(sendingSMSToken);
                        Log(sendingSMSBonus);
                    }

                    // Giving SMS + Bonus (if any)
                    Log(sendingSMSToken);
                    if (!transferTokens(msg.sender, sendingSMSToken, sendingSMSBonus))
                        revert();
                } else {
                    // Revert if too few ETH for the first purchase
                    revert();
                }
            } else {
                // Revert for end phase
                revert();
            }
        } else {
            // Revert for ICO Paused, Stopped
            revert();
        }
    }

    // ======== Bonus Period 1 ========
    // --- Bonus ---
    // 0-9 SMS -> 5%
    // 10-49 SMS -> 10%
    // 50-99 SMS -> 20%
    // 100~ SMS -> 30%
    // --- Time --- (2 days 9 hours 59 minutes 59 seconds )
    // From 27 Oct 2017, 14:00 PM JST (27 Oct 2017, 5:00 AM GMT)
    // To   29 Oct 2017, 23:59 PM JST (29 Oct 2017, 14:59 PM GMT)
    function start1BonusPeriod1() external onlyOwner {
        // Supply setting (only once)
        require(currentPhase == 0);

        balances[owner] = tokenSaleLot1; // Start balance for SpeedMining Co., Ltd.
        balances[address(this)] = tokenSaleLot1;  // Start balance for SMSCoin (for investors)
        totalSupply = balances[owner] + balances[address(this)];
        saleCounterThisPhase = 0;
        limitedSale = tokenSaleLot1;

        // Add owner address into the list as the first wallet who own token(s)
        addAddress(owner);

        // Send owner account the initial tokens (rather than only a contract address)
        Transfer(address(this), owner, balances[owner]);

        // Set draining is needed
        needToDrain = true;

        // ICO stage init
        icoOnSale = true;
        icoOnPaused = false;
        spPhase = false;
        currentPhase = 1;
        startDate = block.timestamp;
        endDate = startDate + 2 days + 9 hours + 59 minutes + 59 seconds;

        // Bonus setting 
        setBonus(5, 10, 20, 30);
    }

    // ======== Bonus Period 2 ========
    // --- Bonus ---
    // 0-9 SMS -> 3%
    // 10-49 SMS -> 5%
    // 50-99 SMS -> 10%
    // 100~ SMS -> 15%
    // --- Time --- (11 days 9 hours 59 minutes 59 seconds)
    // From 30 Oct 2017, 14:00 PM JST (30 Oct 2017, 5:00 AM GMT)
    // To   10 Nov 2017, 23:59 PM JST (10 Nov 2017, 14:59 PM GMT)
    function start2BonusPeriod2() external onlyOwner {
        // ICO stage init
        icoOnSale = true;
        icoOnPaused = false;
        spPhase = false;
        currentPhase = 2;
        startDate = block.timestamp;
        endDate = startDate + 11 days + 9 hours + 59 minutes + 59 seconds;

        // Bonus setting 
        setBonus(3, 5, 10, 15);
    }

    // ======== Bonus Period 3 ========
    // --- Bonus ---
    // 0-9 SMS -> 1%
    // 10-49 SMS -> 3%
    // 50-99 SMS -> 5%
    // 100~ SMS -> 8%
    // --- Time --- (50 days, 5 hours, 14 minutes and 59 seconds)
    // From 11 Nov 2017, 18:45 PM JST (11 Nov 2017, 09:45 AM GMT) (hardfork maintenance 00:00-18:45 JST)
    // To   31 Dec 2017, 23:59 PM JST (31 Dec 2017, 14:59 PM GMT)
    function start3BonusPeriod3() external onlyOwner {
        // ICO stage init
        icoOnSale = true;
        icoOnPaused = false;
        spPhase = false;
        currentPhase = 3;
        startDate = block.timestamp;
        endDate = startDate + 50 days + 5 hours + 14 minutes + 59 seconds;

        // Bonus setting 
        setBonus(1, 3, 5, 8);
    }

    // ======== Normal Period 1 (2018) ========
    // --- Time --- (31 days)
    // From 1 Jan 2018, 00:00 AM JST (31 Dec 2017, 15:00 PM GMT)
    // To   31 Jan 2018, 23:59 PM JST (31 Jan 2018, 14:59 PM GMT)
    function start4NormalPeriod() external onlyOwner {
        // ICO stage init
        icoOnSale = true;
        icoOnPaused = false;
        spPhase = false;
        currentPhase = 4;
        startDate = block.timestamp;
        endDate = startDate + 31 days;

        // Reset bonus
        setBonus(0, 0, 0, 0);
    }

    // ======== Normal Period 2 (2020) ========
    // --- Bonus ---
    // 3X
    // --- Time --- (7 days)
    // From 2 Jan 2020, 00:00 AM JST (1 Jan 2020, 15:00 PM GMT)
    // To   8 Jan 2020, 23:59 PM JST (8 Oct 2020, 14:59 PM GMT)

    // ======== Normal Period 3 (2025) ========
    // --- Bonus ---
    // 3X
    // --- Time --- (7 days)
    // From 2 Jan 2025, 00:00 AM JST (1 Jan 2025, 15:00 PM GMT)
    // To   8 Jan 2025, 23:59 PM JST (8 Oct 2025, 14:59 PM GMT)
    function start3XPhase() external onlyOwner {
        // Supply setting (only after phase 4 or 5)
        require(currentPhase == 4 || currentPhase == 5);
            
        // Please drain SMS if it was not done yet
        require(!needToDrain);
            
        balances[address(this)] = tokenSaleLot3X;
        totalSupply = 3 * totalSupply;
        totalSupply += balances[address(this)];
        saleCounterThisPhase = 0;
        limitedSale = tokenSaleLot3X;

        // Bonus
        x3Token(); // 3X distributions to token holders

        // Mint new tokens
        Transfer(mint, address(this), balances[address(this)]);
        
        // Set draining is needed
        needToDrain = true;
        
        // ICO stage init
        icoOnSale = true;
        icoOnPaused = false;
        spPhase = false;
        currentPhase = 5;
        startDate = block.timestamp;
        endDate = startDate + 7 days;
    }

    // Selling from the available tokens (on owner wallet) that we collected after each sale end
    // Amount is including full digit
    function startManualPeriod(uint _saleToken) external onlyOwner {
        // Supply setting

        // Require enough token from owner to be sold on manual phase        
        require(balances[owner] >= _saleToken);
        
        // Please drain SMS if it was not done yet
        require(!needToDrain);

        // Transfer sale amount to SMS
        balances[owner] -= _saleToken;
        balances[address(this)] += _saleToken;
        saleCounterThisPhase = 0;
        limitedSale = _saleToken;
        Transfer(owner, address(this), _saleToken);
        
        // Set draining is needed
        needToDrain = true;
        
        // ICO stage init
        icoOnSale = true;
        icoOnPaused = false;
        spPhase = true;
        startDate = block.timestamp;
        endDate = startDate + 7 days; // Default running manual mode for 7 days
    }

    function x3Token() private {
        // Multiply token by 3 to all the current addresses
        for (uint i = 0; i < addresses.length; i++) {
            uint curr1XBalance = balances[addresses[i]];
            // In total 3X, then also calculate value to balances
            balances[addresses[i]] = 3 * curr1XBalance;
            // Transfer 2X from Mint to add with the existing 1X
            Transfer(mint, addresses[i], 2 * curr1XBalance);
            // To keep tracking bonus distribution
            sentBonus += (2 * curr1XBalance);
        }
    }

    // Called by the owner, to end the current phase and mark as burnable		
    function endPhase() external onlyOwner {
        icoOnSale = false;
        icoOnPaused = true;
    }

    // Called by the owner, to emergency pause the current phase
    function pausePhase() external onlyOwner {
        icoOnPaused = true;
    }

    // Called by the owner, to resumes the ended/paused phase
    function resumePhase() external onlyOwner {
        icoOnSale = true;
        icoOnPaused = false;
    }

    // Called by the owner, to extend deadline (usually for special phase mode)
    function extend1Week() external onlyOwner {
        endDate += 7 days;
    }

    // Standard interface
    function totalSupply() public constant returns(uint256 _totalSupply) {
        return totalSupply;
    }

    function balanceOf(address sender) public constant returns(uint256 balance) {
        return balances[sender];
    }

    function soldToken() public constant returns(uint256 _soldToken) {
        return soldToken;
    }

    function sentBonus() public constant returns(uint256 _sentBonus) {
        return sentBonus;
    }

    function saleCounterThisPhase() public constant returns(uint256 _saleCounter) {
        return saleCounterThisPhase;
    }

    // Price should be entered in multiple of 10000's
    // E.g. for .0001 ether enter 1, for 5 ether price enter 50000
    function setTokenPrice(uint ethRate) external onlyOwner {
        tokenPrice = (ethRate * 10 ** 18) / 10000; // (Convert to ether unit then make 4 decimals for ETH)
    }

    function setMembershipPrice(uint ethRate) external onlyOwner {
        firstMembershipPurchase = (ethRate * 10 ** 18) / 10000; // (Convert to ether unit then make 4 decimals for ETH)
    }

    // Transfer the SMS balance from caller's wallet address to target's wallet address
    function transfer(address _to, uint256 _amount) public returns(bool success) {
        if (balances[msg.sender] >= _amount && _amount > 0 && balances[_to] + _amount > balances[_to]) {

            balances[msg.sender] -= _amount;
            balances[_to] += _amount;
            Transfer(msg.sender, _to, _amount);

            // Add destination wallet address to the list
            addAddress(_to);

            return true;
        } else {
            return false;
        }
    }

    // Transfer the SMS balance from specific wallet address to target's wallet address
    function transferFrom(address _from, address _to, uint256 _amount) public returns(bool success) {
        if (balances[_from] >= _amount && allowed[_from][msg.sender] >= _amount && _amount > 0 && balances[_to] + _amount > balances[_to]) {
                
            balances[_from] -= _amount;
            allowed[_from][msg.sender] -= _amount;
            balances[_to] += _amount;
            Transfer(_from, _to, _amount);
            return true;
        } else {
            return false;
        }
    }

    // Allow _spender to withdraw from your account, multiple times, up to the _value amount.
    // If this function is called again it overwrites the current allowance with _value.
    function approve(address _spender, uint256 _amount) public returns(bool success) {
        allowed[msg.sender][_spender] = _amount;
        Approval(msg.sender, _spender, _amount);
        return true;
    }

    // Checking allowance
    function allowance(address _owner, address _spender) public constant returns(uint256 remaining) {
        return allowed[_owner][_spender];
    }

    // Transfer the SMS balance from SMS's contract address to an investor's wallet account
    function transferTokens(address _to, uint256 _amount, uint256 _bonus) private returns(bool success) {
        if (_amount > 0 && balances[address(this)] >= _amount && balances[address(this)] - _amount >= 0 && soldToken + _amount > soldToken && saleCounterThisPhase + _amount <= limitedSale && balances[_to] + _amount > balances[_to]) {
            
            // Transfer token from contract to target
            balances[address(this)] -= _amount;
            soldToken += _amount;
            saleCounterThisPhase += _amount;
            balances[_to] += _amount;
            Transfer(address(this), _to, _amount);
            
            // Transfer bonus token from owner to target
            if (currentPhase <= 3 && _bonus > 0 && balances[owner] - _bonus >= 0 && sentBonus + _bonus > sentBonus && sentBonus + _bonus <= reservedBonusLot1 && balances[_to] + _bonus > balances[_to]) {

                // Transfer with bonus
                balances[owner] -= _bonus;
                sentBonus += _bonus;
                balances[_to] += _bonus;
                Transfer(owner, _to, _bonus);
            }

            // Add investor wallet address to the list
            addAddress(_to);

            return true;
        } else {
            return false;
        }
    }

    // Function to give token to investors
    // Will be used to initialize the number of token and number of bonus after migration
    // Also investor can buy token from thridparty channel then owner will run this function
    // Amount and bonus both including full digit
    function giveAways(address _to, uint256 _amount, uint256 _bonus) external onlyOwner {
        // Calling internal transferTokens
        if (!transferTokens(_to, _amount, _bonus))
            revert();
    }

    // Token bonus reward will be given to investor on each sale end
    // This bonus part will be transferred from the company
    // Bonus will be given to the one who has paid membership (0.16 ETH or holding minimum of 0.2 SMS)
    // Amount is including full digit
    function giveReward(uint256 _amount) external onlyOwner {
        // Checking if amount is available and had sold some token
        require(balances[owner] >= _amount);

        uint totalInvestorHand = 0;
        // ------------ Sum up all investor token
        for (uint idx = 0; idx < investorAddresses.length; idx++) {
            if (checkMinBalance(investorAddresses[idx]))
                totalInvestorHand += balances[investorAddresses[idx]];
        }
        uint valuePerToken = _amount * UNIT / totalInvestorHand;

        // ------------ Giving Reward ------------
        for (idx = 0; idx < investorAddresses.length; idx++) {
            if (checkMinBalance(investorAddresses[idx])) {
                uint bonusForThisInvestor = balances[investorAddresses[idx]] * valuePerToken / UNIT;
                sentBonus += bonusForThisInvestor;
                balances[owner] -= bonusForThisInvestor;
                balances[investorAddresses[idx]] += bonusForThisInvestor;
                Transfer(owner, investorAddresses[idx], bonusForThisInvestor);
            }
        }
    }

    // Check wallet address if exist
    function checkAddress(address _addr) public constant returns(bool exist) {
        return userStructs[_addr] == _addr;
    }

    // Check if minBalance is enough
    function checkMinBalance(address _addr) public constant returns(bool enough) {
        return balances[_addr] >= (firstMembershipPurchase * 10000 / tokenPrice * UNIT / 10000);
    }
    
    // Add wallet address with existing check
    function addAddress(address _to) private {
        if (addresses.length > 0) {
            if (userStructs[_to] != _to) {
                userStructs[_to] = _to;
                // Adding all addresses
                addresses.push(_to);
                // Adding investor addresses
                if (_to != address(this) && _to != owner)
                    investorAddresses.push(_to);
            }
        } else {
            userStructs[_to] = _to;
            // Adding all addresses
            addresses.push(_to);
            // Adding investor addresses
            if (_to != address(this) && _to != owner)
                investorAddresses.push(_to);
        }
    }

    // Drain all the available ETH from the contract back to owner's wallet
    function drainETH() external onlyOwner {
        owner.transfer(this.balance);
    }

    // Drain all the available SMS from the contract back to owner's wallet
    // This will drain only the available token up to the current phase
    function drainSMS() external onlyOwner {
        // Only allowed to be executed after endPhase
        require(!icoOnSale);

        // Allow to drain SMS and SMS Bonus back to owner only on Phase 4, 5, 6
        if (currentPhase >= 4 || spPhase) {
            // Drain all available SMS
            // From SMS contract
            if (balances[address(this)] > 0) {
                balances[owner] += balances[address(this)];
                Transfer(address(this), owner, balances[address(this)]);
                balances[address(this)] = 0;

                // Clear draining status
                needToDrain = false;
            }
        }
    }

    // Manual burning function
    // Force to burn it in some situation
    // Amount is including decimal points
    function hardBurnSMS(address _from, uint _amount) external onlyOwner {
        // Burning from source address
        if (balances[_from] > 0) {
            balances[_from] -= _amount;
            totalSupply -= _amount;
            Transfer(_from, genesis, _amount);
        }
    }

    // Function used in Reward contract to know address of token holder
    function getAddress(uint i) public constant returns(address) {
        return addresses[i];
    }

    // Function used in Reward contract to get to know the address array length
    function getAddressSize() public constant returns(uint) {
        return addresses.length;
    }
}