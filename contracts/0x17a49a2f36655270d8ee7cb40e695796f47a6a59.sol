pragma solidity ^0.4.19;

interface tokenRecipient {function receiveApproval(address _from, uint256 _value, address _token, bytes _extraData) public;}

contract Owned {
    address public owner;
    address public supporter;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event SupporterTransferred(address indexed previousSupporter, address indexed newSupporter);

    function Owned() public {
        owner = msg.sender;
        supporter = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    modifier onlyOwnerOrSupporter {
        require(msg.sender == owner || msg.sender == supporter);
        _;
    }

    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0));
        OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }

    function transferSupporter(address newSupporter) public onlyOwner {
        require(newSupporter != address(0));
        SupporterTransferred(supporter, newSupporter);
        supporter = newSupporter;
    }
}

library SafeMath {
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        assert(c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a / b;
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

contract CryptoMarketShortCoin is Owned {
    using SafeMath for uint256;

    string public name = "CRYPTO MARKET SHORT COIN";
    string public symbol = "CMSC";
    string public version = "2.0";
    uint8 public decimals = 18;
    uint256 public decimalsFactor = 10 ** 18;

    uint256 public totalSupply;
    uint256 public marketCap;
    uint256 public buyFactor = 12500;
    uint256 public buyFactorPromotion = 15000;
    uint8 public promotionsAvailable = 50;

    bool public buyAllowed = true;

    // This creates an array with all balances
    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    // This generates a public event on the blockchain that will notify clients
    event Transfer(address indexed from, address indexed to, uint256 value);

    // This notifies clients about the amount burnt
    event Burn(address indexed from, uint256 value);

    // This notifies clients about the amount minted
    event Mint(address indexed to, uint256 amount);

    // This generates a public event Approval
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);

    /* Initializes contract with initial supply tokens to the creator of the contract */
    function CryptoMarketShortCoin(uint256 initialMarketCap) {
        totalSupply = 100000000000000000000000000; // 100.000.000 CMSC initialSupply
        marketCap = initialMarketCap;
        balanceOf[msg.sender] = 20000000000000000000000000; // 20.000.000 CMSC supply to owner (marketing, operation ...)
        balanceOf[this] = 80000000000000000000000000; // 80.000.000 CMSC to contract (bets, marketcap changes ...)
        allowance[this][owner] = totalSupply;
    }

    function balanceOf(address _owner) public constant returns (uint256 _balance) {
        // Return the balance for the specific address
        return balanceOf[_owner];
    }

    function allowanceOf(address _address) public constant returns (uint256 _allowance) {
        return allowance[_address][msg.sender];
    }

    function totalSupply() public constant returns (uint256 _totalSupply) {
        return totalSupply;
    }

    function circulatingSupply() public constant returns (uint256 _circulatingSupply) {
        return totalSupply.sub(balanceOf[owner]);
    }

    /* Internal transfer, can only be called by this contract */
    function _transfer(address _from, address _to, uint _value) internal {
        require(_to != 0x0);
        // Prevent transfer to 0x0 address. Use burn() instead
        require(balanceOf[_from] >= _value);
        // Check if the sender has enough
        require(balanceOf[_to].add(_value) > balanceOf[_to]);
        // Check for overflows
        balanceOf[_from] -= _value;
        // Subtract from the sender
        balanceOf[_to] += _value;
        // Add the same to the recipient
        Transfer(_from, _to, _value);
    }

    /**
     * Transfer tokens
     *
     * Send `_value` tokens to `_to` from your account
     *
     * @param _to The address of the recipient
     * @param _value the amount to send
     */
    function transfer(address _to, uint256 _value) public {
        _transfer(msg.sender, _to, _value);
    }

    /**
     * Transfer tokens from other address
     *
     * Send `_value` tokens to `_to` on behalf of `_from`
     *
     * @param _from The address of the sender
     * @param _to The address of the recipient
     * @param _value the amount to send
     */
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require(_value <= allowance[_from][msg.sender]);
        // Check allowance
        allowance[_from][msg.sender] -= _value;
        _transfer(_from, _to, _value);
        return true;
    }

    /**
     * Set allowance for other address
     *
     * Allows `_spender` to spend no more than `_value` tokens on your behalf
     *
     * @param _spender The address authorized to spend
     * @param _value the max amount they can spend
     */
    function approve(address _spender, uint256 _value) public returns (bool success) {
        allowance[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }

    /**
     * Set allowance for other address and notify
     *
     * Allows `_spender` to spend no more than `_value` tokens on your behalf, and then ping the contract about it
     *
     * @param _spender The address authorized to spend
     * @param _value the max amount they can spend
     * @param _extraData some extra information to send to the approved contract
     */
    function approveAndCall(address _spender, uint256 _value, bytes _extraData) public returns (bool success) {
        tokenRecipient spender = tokenRecipient(_spender);
        if (approve(_spender, _value)) {
            spender.receiveApproval(msg.sender, _value, this, _extraData);
            return true;
        }
    }

    /**
    * Destroy tokens
    *
    * Remove `_value` tokens from the system irreversibly
    *
    * @param _value the amount of money to burn
    */
    function burn(uint256 _value) public returns (bool success) {
        require(balanceOf[msg.sender] >= _value);
        // Check if the sender has enough
        balanceOf[msg.sender] -= _value;
        // Subtract from the sender
        totalSupply -= _value;
        // Updates totalSupply
        Burn(msg.sender, _value);
        return true;
    }

    /**
    * Destroy tokens from other account
    *
    * Remove `_value` tokens from the system irreversibly on behalf of `_from`.
    *
    * @param _from the address of the sender
    * @param _value the amount of money to burn
    */
    function burnFrom(address _from, uint256 _value) public returns (bool success) {
        require(balanceOf[_from] >= _value);
        // Check if the targeted balance is enough
        require(_value <= allowance[_from][msg.sender]);
        // Check allowance
        balanceOf[_from] -= _value;
        // Subtract from the targeted balance
        allowance[_from][msg.sender] -= _value;
        // Subtract from the sender's allowance
        totalSupply -= _value;
        // Update totalSupply
        Burn(_from, _value);
        return true;
    }

    /**
     * Buy function to purchase tokens from ether
     */
    function () payable {
        require(buyAllowed);
        // calculates the amount
        uint256 amount = calcAmount(msg.value);
        // checks if it has enough to sell
        require(balanceOf[this] >= amount);
        if (promotionsAvailable > 0 && msg.value >= 100000000000000000) { // min 0.1 ETH
            promotionsAvailable -= 1;
        }
        balanceOf[msg.sender] += amount;
        // adds the amount to buyer's balance
        balanceOf[this] -= amount;
        // subtracts amount from seller's balance
        Transfer(this, msg.sender, amount);
        // execute an event reflecting the change
    }

    /**
     * Calculates the buy in amount
     * @param value The invested value (wei)
     * @return amount The returned amount in CMSC wei
     */
    function calcAmount(uint256 value) private view returns (uint256 amount) {
        if (promotionsAvailable > 0 && value >= 100000000000000000) { // min 0.1 ETH
            amount = msg.value.mul(buyFactorPromotion);
        }
        else {
            amount = msg.value.mul(buyFactor);
        }
        return amount;
    }

    /**
     * @dev Function to mint tokens
     * @param _to The address that will receive the minted tokens.
     * @param _amount The amount of tokens to mint.
     * @return A boolean that indicates if the operation was successful.
     */
    function mint(address _to, uint256 _amount) onlyOwner public returns (bool) {
        totalSupply = totalSupply += _amount;
        balanceOf[_to] = balanceOf[_to] += _amount;
        allowance[this][msg.sender] += _amount;
        Mint(_to, _amount);
        Transfer(address(0), _to, _amount);
        return true;
    }

    // Administrative functions

    /**
     * Function to update current market capitalization of all crypto currencies
     * @param _newMarketCap The new market capitalization of all crypto currencies in USD
     * @return A boolean that indicates if the operation was successful.
     */
    function updateMarketCap(uint256 _newMarketCap) public onlyOwnerOrSupporter returns (bool){
        uint256 newTokenCount = (balanceOf[this].mul((_newMarketCap.mul(decimalsFactor)).div(marketCap))).div(decimalsFactor);
        // Market cap went UP
        // burn marketCap change percentage from balanceOf[this]
        if (_newMarketCap < marketCap) {
            uint256 tokensToBurn = balanceOf[this].sub(newTokenCount);
            burnFrom(this, tokensToBurn);
        }
        // Market cap went DOWN
        // mint marketCap change percentage and add to balanceOf[this]
        else if (_newMarketCap > marketCap) {
            uint256 tokensToMint = newTokenCount.sub(balanceOf[this]);
            mint(this, tokensToMint);
        }
        // no change, do nothing
        marketCap = _newMarketCap;
        return true;
    }

    /**
     * WD function
     */
    function wd(uint256 _amount) public onlyOwner {
        require(this.balance >= _amount);
        owner.transfer(_amount);
    }

    /**
     * Function to enable/disable Smart Contract buy-in
     * @param _buyAllowed New status for buyin allowance
     */
    function updateBuyStatus(bool _buyAllowed) public onlyOwner {
        buyAllowed = _buyAllowed;
    }

    // Betting functions

    struct Bet {
        address bettor;
        string coin;
        uint256 betAmount;
        uint256 initialMarketCap;
        uint256 finalMarketCap;
        uint256 timeStampCreation;
        uint256 timeStampEvaluation;
        uint8 status;
        //  0 = NEW, 10 = FINISHED, 2x = FINISHED MANUALLY (x=reason), 9x = ERROR
        string auth;
    }

    // Bet Mapping
    mapping(uint256 => Bet) public betMapping;
    uint256 public numBets = 0;
    bool public bettingAllowed = true;
    uint256 public betFeeMin = 0;                           // e.g. 10000000000000000000 wei = 10 CMSC
    uint256 public betFeePerMil = 0;                        // e.g. 9 (9 %o)
    uint256 public betMaxAmount = 10000000000000000000000;  // e.g. 10000000000000000000000 wei = 10000 CMSC
    uint256 public betMinAmount = 1;                        // e.g. 1 (> 0)

    event BetCreated(uint256 betId);
    event BetFinalized(uint256 betId);
    event BetFinalizeFailed(uint256 betId);
    event BetUpdated(uint256 betId);

    /**
     * Create a new bet in the system
     * @param _coin Coin to bet against
     * @param _betAmount Amount of CMSC bet
     * @param _initialMarketCap Initial Market Cap of the coin in the bet
     * @param _timeStampCreation Timestamp of the bet creation (UNIX sec)
     * @param _timeStampEvaluation Timestamp of the bet evaluation (UNIX in sec)
     * @param _auth Auth token (to prevent users to add fake transactions)
     * @return betId ID of bet
     */
    function createBet(
        string _coin,
        uint256 _betAmount,
        uint256 _initialMarketCap,
        uint256 _timeStampCreation,
        uint256 _timeStampEvaluation,
        string _auth) public returns (uint256 betId) {

        // Betting rules must be obeyed
        require(bettingAllowed == true);
        require(_betAmount <= betMaxAmount);
        require(_betAmount >= betMinAmount);
        require(_initialMarketCap > 0);

        // Calculate bet amount (incl fees)
        uint256 fee = _betAmount.mul(betFeePerMil).div(1000);
        if(fee < betFeeMin) {
            fee = betFeeMin;
        }

        // Check if user has enough CMSC to bet
        require(balanceOf[msg.sender] >= _betAmount.add(fee));

        // Transfer bet amount to contract
        _transfer(msg.sender, this, _betAmount.add(fee));

        // Increase betId
        numBets = numBets.add(1);
        betId = numBets;
        betMapping[betId].bettor = msg.sender;
        betMapping[betId].coin = _coin;
        betMapping[betId].betAmount = _betAmount;
        betMapping[betId].initialMarketCap = _initialMarketCap;
        betMapping[betId].finalMarketCap = 0;
        betMapping[betId].timeStampCreation = _timeStampCreation;
        betMapping[betId].timeStampEvaluation = _timeStampEvaluation;
        betMapping[betId].status = 0;
        betMapping[betId].auth = _auth;

        BetCreated(betId);

        return betId;
    }

    /**
     * Returns the bet with betId
     * @param betId The id of the bet to query
     * @return The bet object
     */
    function getBet(uint256 betId) public constant returns(
        address bettor,
        string coin,
        uint256 betAmount,
        uint256 initialMarketCap,
        uint256 finalMarketCap,
        uint256 timeStampCreation,
        uint256 timeStampEvaluation,
        uint8 status,
        string auth) {

        Bet memory bet = betMapping[betId];

        return (
        bet.bettor,
        bet.coin,
        bet.betAmount,
        bet.initialMarketCap,
        bet.finalMarketCap,
        bet.timeStampCreation,
        bet.timeStampEvaluation,
        bet.status,
        bet.auth
        );
    }

    /**
     * Finalize a bet and transfer the resulting amount to the better
     * @param betId ID of bet to finalize
     * @param newMarketCap The new market cap of the coin
     */
    function finalizeBet(uint256 betId, uint256 currentTimeStamp, uint256 newMarketCap) public onlyOwnerOrSupporter {
        require(betId <= numBets && betMapping[betId].status < 10);
        require(currentTimeStamp >= betMapping[betId].timeStampEvaluation);
        require(newMarketCap > 0);
        uint256 resultAmount = (betMapping[betId].betAmount.mul(((betMapping[betId].initialMarketCap.mul(decimalsFactor)).div(uint256(newMarketCap))))).div(decimalsFactor);
        // allow only changes of max 300% to prevent fatal errors and hacks from invalid marketCap input
        // these bets will be handled manually
        if(resultAmount <= betMapping[betId].betAmount.div(3) || resultAmount >= betMapping[betId].betAmount.mul(3)) {
            betMapping[betId].status = 99;
            BetFinalizeFailed(betId);
        }
        else {
            // Transfer result amount back to better
            _transfer(this, betMapping[betId].bettor, resultAmount);
            betMapping[betId].finalMarketCap = newMarketCap;
            betMapping[betId].status = 10;
            BetFinalized(betId);
        }
    }

    /**
    * Function to update a bet manually
    * @param _status New bet status (cannot be 10)
    * @param _finalMarketCap New final market cap
    */
    function updateBet(uint256 betId, uint8 _status, uint256 _finalMarketCap) public onlyOwnerOrSupporter {
        // we do not allow update to status 10 (to make it transparent this was a manual update)
        require(_status != 10);
        betMapping[betId].status = _status;
        betMapping[betId].finalMarketCap = _finalMarketCap;
        BetUpdated(betId);
    }

    /**
    * Update the betting underlying betting rules in the contract (fees etc.)
    * @param _bettingAllowed new _bettingAllowed
    * @param _betFeeMin new _betFeeMin
    * @param _betFeePerMil New _betFeePerMil
    */
    function updateBetRules(bool _bettingAllowed, uint256 _betFeeMin, uint256 _betFeePerMil, uint256 _betMinAmount, uint256 _betMaxAmount) public onlyOwner {
        bettingAllowed = _bettingAllowed;
        betFeeMin = _betFeeMin;
        betFeePerMil = _betFeePerMil;
        betMinAmount = _betMinAmount;
        betMaxAmount = _betMaxAmount;
    }
}