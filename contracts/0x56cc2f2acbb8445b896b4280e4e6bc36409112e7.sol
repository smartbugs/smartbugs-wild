pragma solidity ^0.4.8;

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
    uint tokenSaleLot2 = 50000 * UNIT;
    uint tokenSaleLot3 = 50000 * UNIT;

    struct BonusStruct {
        uint8 ratio1;
        uint8 ratio2;
        uint8 ratio3;
        uint8 ratio4;
    }
    BonusStruct bonusRatio;

    uint public saleCounter = 0;

    uint public limitedSale = 0;

    uint public sentBonus = 0;

    uint public soldToken = 0;

    mapping(address => uint) balances;

    mapping(address => mapping(address => uint)) allowed;

    address[] addresses;

    mapping(address => address) private userStructs;

    address owner;

    address mint = address(this);   // Contract address as a minter
    
    address genesis = 0x0;

    //uint256 public tokenPrice = 0.001 ether; // Test
    uint256 public tokenPrice = 0.8 ether;

    event Log(uint e);

    event TOKEN(string e);

    bool icoOnPaused = false;

    uint256 startDate;

    uint256 endDate;

    uint currentPhase = 0;

    bool needToBurn = false;

    modifier onlyOwner() {
        if (msg.sender != owner) {
            revert();
        }
        _;
    }

    function SMSCoin() public {
        owner = msg.sender;
    }

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

    /**
     * Multiplication with safety check
     */
    function safeMul(uint a, uint b) pure internal returns(uint) {
        uint c = a * b;
        //check result should not be other wise until a=0
        assert(a == 0 || c / a == b);
        return c;
    }

    /**
     * Add with safety check
     */
    function safeAdd(uint a, uint b) pure internal returns (uint) {
        assert (a + b >= a);
        return a + b;
    }

    function setBonus(uint8 ratio1, uint8 ratio2, uint8 ratio3, uint8 ratio4) private {
        bonusRatio.ratio1 = ratio1;
        bonusRatio.ratio2 = ratio2;
        bonusRatio.ratio3 = ratio3;
        bonusRatio.ratio4 = ratio4;
    }

    function calcBonus(uint256 sendingSMSToken) view private returns(uint256) {
        uint256 sendingSMSBonus;

        // Calculating bonus
        if (sendingSMSToken < (10 * UNIT)) {            // 0-9
            sendingSMSBonus = (sendingSMSToken * bonusRatio.ratio1) / 100;
        } else if (sendingSMSToken < (50 * UNIT)) {     // 10-49
            sendingSMSBonus = (sendingSMSToken * bonusRatio.ratio2) / 100;
        } else if (sendingSMSToken < (100 * UNIT)) {    // 50-99
            sendingSMSBonus = (sendingSMSToken * bonusRatio.ratio3) / 100;
        } else {                                        // 100+
            sendingSMSBonus = (sendingSMSToken * bonusRatio.ratio4) / 100;
        }

        return sendingSMSBonus;
    }

    // Selling SMS token
    function () public payable {
        uint256 receivedETH = 0;
        uint256 sendingSMSToken = 0;
        uint256 sendingSMSBonus = 0;
        Log(msg.value);

        // Only for selling to investors
        if (!icoOnPaused && msg.sender != owner) {
            if (now <= endDate) {
                // All the phases
                Log(currentPhase);

                // Calculating SMS
                receivedETH = (msg.value * UNIT);
                sendingSMSToken = safeDiv(receivedETH, tokenPrice);
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
                revert();
            }

        } else {
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
        if (currentPhase == 0) {
            balances[owner] = tokenSaleLot1; // Start balance for SpeedMining Co., Ltd.
            balances[address(this)] = tokenSaleLot1;  // Start balance for SMSCoin (for investors)
            totalSupply = balances[owner] + balances[address(this)];
            saleCounter = 0;
            limitedSale = tokenSaleLot1;

            // Add owner address into the list as the first wallet who own token(s)
            addAddress(owner);

            // Send owner account the initial tokens (rather than only a contract address)
            Transfer(address(this), owner, balances[owner]);

            // Set burning is needed
            needToBurn = true;
        }

        // ICO stage init
        icoOnPaused = false;
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
        icoOnPaused = false;
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
    // --- Time --- (51 days)
    // From 11 Nov 2017, 00:00 AM JST (10 Nov 2017, 15:00 PM GMT)
    // To   31 Dec 2017, 23:59 PM JST (31 Dec 2017, 14:59 PM GMT)
    function start3BonusPeriod3() external onlyOwner {
        // ICO stage init
        icoOnPaused = false;
        currentPhase = 3;
        startDate = block.timestamp;
        endDate = startDate + 51 days;

        // Bonus setting 
        setBonus(1, 3, 5, 8);
    }

    // ======== Normal Period 1 (2018) ========
    // --- Time --- (31 days)
    // From 1 Jan 2018, 00:00 AM JST (31 Dec 2017, 15:00 PM GMT)
    // To   31 Jan 2018, 23:59 PM JST (31 Jan 2018, 14:59 PM GMT)
    function start4NormalPeriod() external onlyOwner {
        // ICO stage init
        icoOnPaused = false;
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
    function start5Phase2020() external onlyOwner {
        // Supply setting (only after phase 4)
        if (currentPhase == 4) {
            // Burn SMS if it was not done yet
            if (needToBurn)
                burnSMSProcess();
                
            balances[address(this)] = tokenSaleLot2;
            totalSupply = 3 * totalSupply;
            totalSupply += balances[address(this)];
            saleCounter = 0;
            limitedSale = tokenSaleLot2;

            // Bonus
            x3Token(); // 3X distributions to token holders

            // Mint new tokens for 2020
            Transfer(mint, address(this), balances[address(this)]);

            // Set burning is needed
            needToBurn = true;
        }

        // ICO stage init
        icoOnPaused = false;
        currentPhase = 5;
        startDate = block.timestamp;
        endDate = startDate + 7 days;
    }

    // ======== Normal Period 3 (2025) ========
    // --- Bonus ---
    // 3X
    // --- Time --- (7 days)
    // From 2 Jan 2025, 00:00 AM JST (1 Jan 2025, 15:00 PM GMT)
    // To   8 Jan 2025, 23:59 PM JST (8 Oct 2025, 14:59 PM GMT)
    function start6Phase2025() external onlyOwner {
        // Supply setting (only after phase 5)
        if (currentPhase == 5) {
            // Burn SMS if it was not done yet
            if (needToBurn)
                burnSMSProcess();

            balances[address(this)] = tokenSaleLot3;
            totalSupply = 3 * totalSupply;
            totalSupply += balances[address(this)];
            saleCounter = 0;
            limitedSale = tokenSaleLot3;
            
            // Bonus
            x3Token(); // 3X distributions to token holders

            // Mint new tokens for 2025
            Transfer(mint, address(this), balances[address(this)]);

            // Set burning is needed
            needToBurn = true;
        }
        
        // ICO stage init
        icoOnPaused = false;
        currentPhase = 6;
        startDate = block.timestamp;
        endDate = startDate + 7 days;
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

    // Called by the owner, to emergency pause the current phase
    function pausePhase() external onlyOwner {
        icoOnPaused = true;
    }

    // Called by the owner, to resumes the paused phase
    function resumePhase() external onlyOwner {
        icoOnPaused = false;
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

    function saleCounter() public constant returns(uint256 _saleCounter) {
        return saleCounter;
    }

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

    // Price should be entered in multiple of 10000's
    // E.g. for .0001 ether enter 1, for 5 ether price enter 50000 
    function setTokenPrice(uint ethRate) external onlyOwner {
        tokenPrice = (ethRate * 10 ** 18) / 10000; // (Convert to ether unit then make 4 decimals)
    }

    // Allow _spender to withdraw from your account, multiple times, up to the _value amount.
    // If this function is called again it overwrites the current allowance with _value.
    function approve(address _spender, uint256 _amount) public returns(bool success) {
        allowed[msg.sender][_spender] = _amount;
        Approval(msg.sender, _spender, _amount);
        return true;
    }

    function allowance(address _owner, address _spender) public constant returns(uint256 remaining) {
        return allowed[_owner][_spender];
    }

    // Transfer the balance from caller's wallet address to investor's wallet address
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

    // Transfer the balance from SMS's contract address to an investor's wallet account
    function transferTokens(address _to, uint256 _amount, uint256 _bonus) private returns(bool success) {
        if (_amount > 0 && balances[address(this)] >= _amount && balances[address(this)] - _amount >= 0 && soldToken + _amount > soldToken && saleCounter + _amount <= limitedSale && balances[_to] + _amount > balances[_to]) {
            
            // Transfer token from contract to target
            balances[address(this)] -= _amount;
            soldToken += _amount;
            saleCounter += _amount;
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

    // Add wallet address with existing check
    function addAddress(address _to) private {
        if (addresses.length > 0) {
            if (userStructs[_to] != _to) {
                userStructs[_to] = _to;
                addresses.push(_to);
            }
        } else {
            userStructs[_to] = _to;
            addresses.push(_to);
        }
    }

    // Drain all the available ETH from the contract back to owner's wallet
    function drainETH() external onlyOwner {
        owner.transfer(this.balance);
    }

    // Burn all the available SMS from the contract and from owner to make it equal to investors
    // This will burn only the available token up to the current phase
    // A burning function 
    function burnSMSProcess() private {
        // Allow to burn left SMS only on phase 4, 5, 6
        if (currentPhase >= 4) {
            // Burn all available tokens
            // From SMS contract
            if (balances[address(this)] > 0) {
                uint toBeBurnedFromContract = balances[address(this)];
                Transfer(address(this), genesis, toBeBurnedFromContract);
                balances[address(this)] = 0;
                totalSupply -= toBeBurnedFromContract;

                // Burn from owner wallet only in phase 4
                if (currentPhase == 4) {
                    if (balances[owner] > soldToken) {
                        uint toBeBurnedFromOwner = balances[owner] - soldToken;
                        Transfer(owner, genesis, toBeBurnedFromOwner);
                        balances[owner] = balances[owner] - toBeBurnedFromOwner;
                        totalSupply -= toBeBurnedFromOwner;
                    }
                }

                // Clear burning status
                needToBurn = false;
            }
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