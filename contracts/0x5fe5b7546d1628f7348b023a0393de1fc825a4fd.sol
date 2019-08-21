contract Roulette {
    
    // Global variables
    string sWelcome;
    /* Remark: 
     *  Private Seed for generateRand(), 
     *  since this is nowhere visibile, 
     *  it's very hard to guess.
     */
    uint privSeed; 
    struct Casino {
        address addr;
        uint balance;
        uint bettingLimitMin;
        uint bettingLimitMax;
    }
    Casino casino;

    // Init Constructor
    function Roulette() {
        sWelcome = "\n-----------------------------\n     Welcome to Roulette \n Got coins? Then come on in! \n-----------------------------\n";
        privSeed = 1;
        casino.addr = msg.sender;
        casino.balance = 0;
        casino.bettingLimitMin = 1*10**18;
        casino.bettingLimitMax = 10*10**18;
    }
    
    function welcome() constant returns (string) {
        return sWelcome;
    }
    function casinoBalance() constant returns (uint) {
        return casino.balance;
    }
    function casinoDeposit() {
        if (msg.sender == casino.addr)
            casino.balance += msg.value;
        else 
            msg.sender.send(msg.value);
    }
    function casinoWithdraw(uint amount) {
        if (msg.sender == casino.addr && amount <= casino.balance) {
            casino.balance -= amount;
            casino.addr.send(amount);
        }
    }
    
    // Bet on Number
    function betOnNumber(uint number) public returns (string) {
        // Input Handling
        address addr = msg.sender;
        uint betSize = msg.value;
        if (betSize < casino.bettingLimitMin || betSize > casino.bettingLimitMax) {
            // Return Funds
            if (betSize >= 1*10**18)
                addr.send(betSize);
            return "Please choose an amount within between 1 and 10 ETH";
        }
        if (betSize * 36 > casino.balance) {
            // Return Funds
            addr.send(betSize);
            return "Casino has insufficient funds for this bet amount";
        }
        if (number < 0 || number > 36) {
            // Return Funds
            addr.send(betSize);
            return "Please choose a number between 0 and 36";
        }
        // Roll the wheel
        privSeed += 1;
        uint rand = generateRand();
        if (number == rand) {
            // Winner winner chicken dinner!
            uint winAmount = betSize * 36;
            casino.balance -= (winAmount - betSize);
            addr.send(winAmount);
            return "Winner winner chicken dinner!";
        }
        else {
            casino.balance += betSize;
            return "Wrong number.";
        }
    }
    
    // Bet on Color
    function betOnColor(uint color) public returns (string) {
        // Input Handling
        address addr = msg.sender;
        uint betSize = msg.value;
        if (betSize < casino.bettingLimitMin || betSize > casino.bettingLimitMax) {
            // Return Funds
            if (betSize >= 1*10**18)
                addr.send(betSize);
            return "Please choose an amount within between 1 and 10 ETH";
        }
        if (betSize * 2 > casino.balance) {
            // Return Funds
            addr.send(betSize);
            return "Casino has insufficient funds for this bet amount";
        }
        if (color != 0 && color != 1) {
            // Return Funds
            addr.send(betSize);
            return "Please choose either '0' = red or '1' = black as a color";
        }
        // Roll the wheel
        privSeed += 1;
        uint rand = generateRand();
        uint randC = (rand + 1) % 2;
        // Win
        if (rand != 0 && (randC == color)) {
            uint winAmount = betSize * 2;
            casino.balance -= (winAmount - betSize);
            addr.send(winAmount);
            return "Win! Good job.";
        }
        else {
            casino.balance += betSize;
            return "Wrong color.";           
        }
    }
    
    // Returns a pseudo Random number.
    function generateRand() private returns (uint) { 
        // Seeds
        privSeed = (privSeed*3 + 1) / 2;
        privSeed = privSeed % 10**9;
        uint number = block.number; // ~ 10**5 ; 60000
        uint diff = block.difficulty; // ~ 2 Tera = 2*10**12; 1731430114620
        uint time = block.timestamp; // ~ 2 Giga = 2*10**9; 1439147273
        uint gas = block.gaslimit; // ~ 3 Mega = 3*10**6
        // Rand Number in Percent
        uint total = privSeed + number + diff + time + gas;
        uint rand = total % 37;
        return rand;
    }

    // Function to recover the funds on the contract
    function kill() {
        if (msg.sender == casino.addr) 
            suicide(casino.addr);
    }
}