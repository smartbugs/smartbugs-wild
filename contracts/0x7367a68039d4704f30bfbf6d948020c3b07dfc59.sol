pragma solidity ^0.4.19;


/**
 * A contract containing the fundamental state variables of the Beercoin
 */
contract InternalBeercoin {
    // As 18 decimal places will be used, the constants are multiplied by 10^18
    uint256 internal constant INITIAL_SUPPLY = 15496000000 * 10**18;
    uint256 internal constant DIAMOND_VALUE = 10000 * 10**18;
    uint256 internal constant GOLD_VALUE = 100 * 10**18;
    uint256 internal constant SILVER_VALUE = 10 * 10**18;
    uint256 internal constant BRONZE_VALUE = 1 * 10**18;

    // In addition to the initial total supply of 15496000000 Beercoins,
    // more Beercoins will only be added by scanning bottle caps.
    // 20800000000 bottle caps will be eventually produced.
    //
    // Within 10000 bottle caps,
    // 1 (i.e. every 10000th cap in total) has a value of 10000 ("Diamond") Beercoins,
    // 9 (i.e. every 1000th cap in total) have a value of 100 ("Gold") Beercoins,
    // 990 (i.e. every 10th cap in total) have a value of 10 ("Silver") Beercoins,
    // 9000 (i.e. every remaining cap) have a value of 1 ("Bronze") Beercoin.
    //
    // Therefore one bottle cap has an average Beercoin value of
    // (1 * 10000 + 9 * 100 + 990 * 10 + 9000 * 1) / 10000 = 2.98.
    //
    // This means the total Beercoin value of all bottle caps that will
    // be eventually produced equals 20800000000 * 2.98 = 61984000000.
    uint64 internal producibleCaps = 20800000000;

    // The  amounts of diamond, gold, silver, and bronze caps are stored
    // as a single 256-bit value divided into four sections of 64 bits.
    //
    // Bits 255 to 192 are used for the amount of diamond caps,
    // bits 191 to 128 are used for the amount of gold caps,
    // bits 127 to 64 are used for the amount of silver caps,
    // bits 63 to 0 are used for the amount of bronze caps.
    //
    // For example, the following numbers represent a single cap of a certain type:
    // 0x0000000000000001000000000000000000000000000000000000000000000000 (diamond)
    // 0x0000000000000000000000000000000100000000000000000000000000000000 (gold)
    // 0x0000000000000000000000000000000000000000000000010000000000000000 (silver)
    // 0x0000000000000000000000000000000000000000000000000000000000000001 (bronze)
    uint256 internal packedProducedCaps = 0;
    uint256 internal packedScannedCaps = 0;

    // The amount of irreversibly burnt Beercoins
    uint256 internal burntValue = 0;
}


/**
 * A contract containing functions to understand the packed low-level data
 */
contract ExplorableBeercoin is InternalBeercoin {
    /**
     * The amount of caps that can still be produced
     */
    function unproducedCaps() public view returns (uint64) {
        return producibleCaps;
    }

    /**
     * The amount of caps that is produced but not yet scanned
     */
    function unscannedCaps() public view returns (uint64) {
        uint256 caps = packedProducedCaps - packedScannedCaps;
        uint64 amount = uint64(caps >> 192);
        amount += uint64(caps >> 128);
        amount += uint64(caps >> 64);
        amount += uint64(caps);
        return amount;
    }

    /**
     * The amount of all caps produced so far
     */
    function producedCaps() public view returns (uint64) {
        uint256 caps = packedProducedCaps;
        uint64 amount = uint64(caps >> 192);
        amount += uint64(caps >> 128);
        amount += uint64(caps >> 64);
        amount += uint64(caps);
        return amount;
    }

    /**
     * The amount of all caps scanned so far
     */
    function scannedCaps() public view returns (uint64) {
        uint256 caps = packedScannedCaps;
        uint64 amount = uint64(caps >> 192);
        amount += uint64(caps >> 128);
        amount += uint64(caps >> 64);
        amount += uint64(caps);
        return amount;
    }

    /**
     * The amount of diamond caps produced so far
     */
    function producedDiamondCaps() public view returns (uint64) {
        return uint64(packedProducedCaps >> 192);
    }

    /**
     * The amount of diamond caps scanned so far
     */
    function scannedDiamondCaps() public view returns (uint64) {
        return uint64(packedScannedCaps >> 192);
    }

    /**
     * The amount of gold caps produced so far
     */
    function producedGoldCaps() public view returns (uint64) {
        return uint64(packedProducedCaps >> 128);
    }

    /**
     * The amount of gold caps scanned so far
     */
    function scannedGoldCaps() public view returns (uint64) {
        return uint64(packedScannedCaps >> 128);
    }

    /**
     * The amount of silver caps produced so far
     */
    function producedSilverCaps() public view returns (uint64) {
        return uint64(packedProducedCaps >> 64);
    }

    /**
     * The amount of silver caps scanned so far
     */
    function scannedSilverCaps() public view returns (uint64) {
        return uint64(packedScannedCaps >> 64);
    }

    /**
     * The amount of bronze caps produced so far
     */
    function producedBronzeCaps() public view returns (uint64) {
        return uint64(packedProducedCaps);
    }

    /**
     * The amount of bronze caps scanned so far
     */
    function scannedBronzeCaps() public view returns (uint64) {
        return uint64(packedScannedCaps);
    }
}


/**
 * A contract implementing all standard ERC20 functionality for the Beercoin
 */
contract ERC20Beercoin is ExplorableBeercoin {
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);

    mapping (address => uint256) internal balances;
    mapping (address => mapping (address => uint256)) internal allowances;

    /**
     * Beercoin's name
     */
    function name() public pure returns (string) {
        return "Beercoin";
    }

    /**
     * Beercoin's symbol
     */
    function symbol() public pure returns (string) {
        return "?";
    }

    /**
     * Beercoin's decimal places
     */
    function decimals() public pure returns (uint8) {
        return 18;
    }

    /**
     * The current total supply of Beercoins
     */
    function totalSupply() public view returns (uint256) {
        uint256 caps = packedScannedCaps;
        uint256 supply = INITIAL_SUPPLY;
        supply += (caps >> 192) * DIAMOND_VALUE;
        supply += ((caps >> 128) & 0xFFFFFFFFFFFFFFFF) * GOLD_VALUE;
        supply += ((caps >> 64) & 0xFFFFFFFFFFFFFFFF) * SILVER_VALUE;
        supply += (caps & 0xFFFFFFFFFFFFFFFF) * BRONZE_VALUE;
        return supply - burntValue;
    }

    /**
     * Check the balance of a Beercoin user
     *
     * @param _owner the user to check
     */
    function balanceOf(address _owner) public view returns (uint256) {
        return balances[_owner];
    }

    /**
     * Transfer Beercoins to another user
     *
     * @param _to the address of the recipient
     * @param _value the amount to send
     */
    function transfer(address _to, uint256 _value) public returns (bool) {
        require(_to != 0x0);

        uint256 balanceFrom = balances[msg.sender];

        require(_value <= balanceFrom);

        uint256 oldBalanceTo = balances[_to];
        uint256 newBalanceTo = oldBalanceTo + _value;

        require(oldBalanceTo <= newBalanceTo);

        balances[msg.sender] = balanceFrom - _value;
        balances[_to] = newBalanceTo;

        Transfer(msg.sender, _to, _value);

        return true;
    }

    /**
     * Transfer Beercoins from other address if a respective allowance exists
     *
     * @param _from the address of the sender
     * @param _to the address of the recipient
     * @param _value the amount to send
     */
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
        require(_to != 0x0);

        uint256 balanceFrom = balances[_from];
        uint256 allowanceFrom = allowances[_from][msg.sender];

        require(_value <= balanceFrom);
        require(_value <= allowanceFrom);

        uint256 oldBalanceTo = balances[_to];
        uint256 newBalanceTo = oldBalanceTo + _value;

        require(oldBalanceTo <= newBalanceTo);

        balances[_from] = balanceFrom - _value;
        balances[_to] = newBalanceTo;
        allowances[_from][msg.sender] = allowanceFrom - _value;

        Transfer(_from, _to, _value);

        return true;
    }

    /**
     * Allow another user to spend a certain amount of Beercoins on your behalf
     *
     * @param _spender the address of the user authorized to spend
     * @param _value the maximum amount that can be spent on your behalf
     */
    function approve(address _spender, uint256 _value) public returns (bool) {
        allowances[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }

    /**
     * The amount of Beercoins that can be spent by a user on behalf of another
     *
     * @param _owner the address of the user user whose Beercoins are spent
     * @param _spender the address of the user who executes the transaction
     */
    function allowance(address _owner, address _spender) public view returns (uint256) {
        return allowances[_owner][_spender];
    }
}


/**
 * A contract that defines a master with special debiting abilities
 * required for operating a user-friendly Beercoin redemption system
 */
contract MasteredBeercoin is ERC20Beercoin {
    address internal beercoinMaster;
    mapping (address => bool) internal directDebitAllowances;

    /**
     * Construct the MasteredBeercoin contract
     * and make the sender the master
     */
    function MasteredBeercoin() public {
        beercoinMaster = msg.sender;
    }

    /**
     * Restrict to the master only
     */
    modifier onlyMaster {
        require(msg.sender == beercoinMaster);
        _;
    }

    /**
     * The master of the Beercoin
     */
    function master() public view returns (address) {
        return beercoinMaster;
    }

    /**
     * Declare a master at another address
     *
     * @param newMaster the new owner's address
     */
    function declareNewMaster(address newMaster) public onlyMaster {
        beercoinMaster = newMaster;
    }

    /**
     * Allow the master to withdraw Beercoins from your
     * account so you don't have to send Beercoins yourself
     */
    function allowDirectDebit() public {
        directDebitAllowances[msg.sender] = true;
    }

    /**
     * Forbid the master to withdraw Beercoins from you account
     */
    function forbidDirectDebit() public {
        directDebitAllowances[msg.sender] = false;
    }

    /**
     * Check whether a user allows direct debits by the master
     *
     * @param user the user to check
     */
    function directDebitAllowance(address user) public view returns (bool) {
        return directDebitAllowances[user];
    }

    /**
     * Withdraw Beercoins from multiple users
     *
     * Beercoins are only withdrawn this way if and only if
     * a user deliberately wants it to happen by initiating
     * a transaction on a plattform operated by the owner
     *
     * @param users the addresses of the users to take Beercoins from
     * @param values the respective amounts to take
     */
    function debit(address[] users, uint256[] values) public onlyMaster returns (bool) {
        require(users.length == values.length);

        uint256 oldBalance = balances[msg.sender];
        uint256 newBalance = oldBalance;

        address currentUser;
        uint256 currentValue;
        uint256 currentBalance;
        for (uint256 i = 0; i < users.length; ++i) {
            currentUser = users[i];
            currentValue = values[i];
            currentBalance = balances[currentUser];

            require(directDebitAllowances[currentUser]);
            require(currentValue <= currentBalance);
            balances[currentUser] = currentBalance - currentValue;
            
            newBalance += currentValue;

            Transfer(currentUser, msg.sender, currentValue);
        }

        require(oldBalance <= newBalance);
        balances[msg.sender] = newBalance;

        return true;
    }

    /**
     * Withdraw Beercoins from multiple users
     *
     * Beercoins are only withdrawn this way if and only if
     * a user deliberately wants it to happen by initiating
     * a transaction on a plattform operated by the owner
     *
     * @param users the addresses of the users to take Beercoins from
     * @param value the amount to take from each user
     */
    function debitEqually(address[] users, uint256 value) public onlyMaster returns (bool) {
        uint256 oldBalance = balances[msg.sender];
        uint256 newBalance = oldBalance + (users.length * value);

        require(oldBalance <= newBalance);
        balances[msg.sender] = newBalance;

        address currentUser;
        uint256 currentBalance;
        for (uint256 i = 0; i < users.length; ++i) {
            currentUser = users[i];
            currentBalance = balances[currentUser];

            require(directDebitAllowances[currentUser]);
            require(value <= currentBalance);
            balances[currentUser] = currentBalance - value;

            Transfer(currentUser, msg.sender, value);
        }

        return true;
    }

    /**
     * Send Beercoins to multiple users
     *
     * @param users the addresses of the users to send Beercoins to
     * @param values the respective amounts to send
     */
    function credit(address[] users, uint256[] values) public onlyMaster returns (bool) {
        require(users.length == values.length);

        uint256 balance = balances[msg.sender];
        uint256 totalValue = 0;

        address currentUser;
        uint256 currentValue;
        uint256 currentOldBalance;
        uint256 currentNewBalance;
        for (uint256 i = 0; i < users.length; ++i) {
            currentUser = users[i];
            currentValue = values[i];
            currentOldBalance = balances[currentUser];
            currentNewBalance = currentOldBalance + currentValue;

            require(currentOldBalance <= currentNewBalance);
            balances[currentUser] = currentNewBalance;

            totalValue += currentValue;

            Transfer(msg.sender, currentUser, currentValue);
        }

        require(totalValue <= balance);
        balances[msg.sender] = balance - totalValue;

        return true;
    }

    /**
     * Send Beercoins to multiple users
     *
     * @param users the addresses of the users to send Beercoins to
     * @param value the amounts to send to each user
     */
    function creditEqually(address[] users, uint256 value) public onlyMaster returns (bool) {
        uint256 balance = balances[msg.sender];
        uint256 totalValue = users.length * value;

        require(totalValue <= balance);
        balances[msg.sender] = balance - totalValue;

        address currentUser;
        uint256 currentOldBalance;
        uint256 currentNewBalance;
        for (uint256 i = 0; i < users.length; ++i) {
            currentUser = users[i];
            currentOldBalance = balances[currentUser];
            currentNewBalance = currentOldBalance + value;

            require(currentOldBalance <= currentNewBalance);
            balances[currentUser] = currentNewBalance;

            Transfer(msg.sender, currentUser, value);
        }

        return true;
    }
}


/**
 * A contract that defines the central business logic
 * which also mirrors the life of a Beercoin
 */
contract Beercoin is MasteredBeercoin {
    event Produce(uint256 newCaps);
    event Scan(address[] users, uint256[] caps);
    event Burn(uint256 value);

    /**
     * Construct the Beercoin contract and
     * assign the initial supply to the creator
     */
    function Beercoin() public {
        balances[msg.sender] = INITIAL_SUPPLY;
    }

    /**
     * Increase the amounts of produced diamond, gold, silver, and
     * bronze bottle caps in respect to their occurrence probabilities
     *
     * This function is called if and only if a brewery has actually
     * ordered codes to produce the specified amount of bottle caps
     *
     * @param numberOfCaps the number of bottle caps to be produced
     */
    function produce(uint64 numberOfCaps) public onlyMaster returns (bool) {
        require(numberOfCaps <= producibleCaps);

        uint256 producedCaps = packedProducedCaps;

        uint64 targetTotalCaps = numberOfCaps;
        targetTotalCaps += uint64(producedCaps >> 192);
        targetTotalCaps += uint64(producedCaps >> 128);
        targetTotalCaps += uint64(producedCaps >> 64);
        targetTotalCaps += uint64(producedCaps);

        uint64 targetDiamondCaps = (targetTotalCaps - (targetTotalCaps % 10000)) / 10000;
        uint64 targetGoldCaps = ((targetTotalCaps - (targetTotalCaps % 1000)) / 1000) - targetDiamondCaps;
        uint64 targetSilverCaps = ((targetTotalCaps - (targetTotalCaps % 10)) / 10) - targetDiamondCaps - targetGoldCaps;
        uint64 targetBronzeCaps = targetTotalCaps - targetDiamondCaps - targetGoldCaps - targetSilverCaps;

        uint256 targetProducedCaps = 0;
        targetProducedCaps |= uint256(targetDiamondCaps) << 192;
        targetProducedCaps |= uint256(targetGoldCaps) << 128;
        targetProducedCaps |= uint256(targetSilverCaps) << 64;
        targetProducedCaps |= uint256(targetBronzeCaps);

        producibleCaps -= numberOfCaps;
        packedProducedCaps = targetProducedCaps;

        Produce(targetProducedCaps - producedCaps);

        return true;
    }

    /**
     * Approve scans of multiple users and grant Beercoins
     *
     * This function is called periodically to mass-transfer Beercoins to
     * multiple users if and only if each of them has scanned codes that
     * our server has never verified before for the same or another user
     *
     * @param users the addresses of the users who scanned valid codes
     * @param caps the amounts of caps the users have scanned as single 256-bit values
     */
    function scan(address[] users, uint256[] caps) public onlyMaster returns (bool) {
        require(users.length == caps.length);

        uint256 scannedCaps = packedScannedCaps;

        uint256 currentCaps;
        uint256 capsValue;
        for (uint256 i = 0; i < users.length; ++i) {
            currentCaps = caps[i];

            capsValue = DIAMOND_VALUE * (currentCaps >> 192);
            capsValue += GOLD_VALUE * ((currentCaps >> 128) & 0xFFFFFFFFFFFFFFFF);
            capsValue += SILVER_VALUE * ((currentCaps >> 64) & 0xFFFFFFFFFFFFFFFF);
            capsValue += BRONZE_VALUE * (currentCaps & 0xFFFFFFFFFFFFFFFF);

            balances[users[i]] += capsValue;
            scannedCaps += currentCaps;
        }

        require(scannedCaps <= packedProducedCaps);
        packedScannedCaps = scannedCaps;

        Scan(users, caps);

        return true;
    }

    /**
     * Remove Beercoins from the system irreversibly
     *
     * @param value the amount of Beercoins to burn
     */
    function burn(uint256 value) public onlyMaster returns (bool) {
        uint256 balance = balances[msg.sender];
        require(value <= balance);

        balances[msg.sender] = balance - value;
        burntValue += value;

        Burn(value);

        return true;
    }
}