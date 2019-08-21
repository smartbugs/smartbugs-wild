pragma solidity ^0.4.17;

 /*
 * Contract that is working with ERC223 tokens
 * https://github.com/ethereum/EIPs/issues/223
 */

/// @title ERC223ReceivingContract - Standard contract implementation for compatibility with ERC223 tokens.
contract ERC223ReceivingContract {

    /// @dev Function that is called when a user or another contract wants to transfer funds.
    /// @param _from Transaction initiator, analogue of msg.sender
    /// @param _value Number of tokens to transfer.
    /// @param _data Data containig a function signature and/or parameters
    function tokenFallback(address _from, uint256 _value, bytes _data) public;
}

/// @title Base Token contract - Functions to be implemented by token contracts.
contract Token {
    /*
     * Implements ERC 20 standard.
     * https://github.com/ethereum/EIPs/blob/f90864a3d2b2b45c4decf95efd26b3f0c276051a/EIPS/eip-20-token-standard.md
     * https://github.com/ethereum/EIPs/issues/20
     *
     *  Added support for the ERC 223 "tokenFallback" method in a "transfer" function with a payload.
     *  https://github.com/ethereum/EIPs/issues/223
     */

    /*
     * This is a slight change to the ERC20 base standard.
     * function totalSupply() constant returns (uint256 supply);
     * is replaced with:
     * uint256 public totalSupply;
     * This automatically creates a getter function for the totalSupply.
     * This is moved to the base contract since public getter functions are not
     * currently recognised as an implementation of the matching abstract
     * function by the compiler.
     */
    uint256 public totalSupply;

    /*
     * ERC 20
     */
    function balanceOf(address _owner) public constant returns (uint256 balance);
    function transfer(address _to, uint256 _value) public returns (bool success);
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);
    function approve(address _spender, uint256 _value) public returns (bool success);
    function allowance(address _owner, address _spender) public constant returns (uint256 remaining);

    /*
     * ERC 223
     */
    function transfer(address _to, uint256 _value, bytes _data) public returns (bool success);

    /*
     * Events
     */
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);

    // There is no ERC223 compatible Transfer event, with `_data` included.
}

/// @title Standard token contract - Standard token implementation.
contract StandardToken is Token {

    /*
     * Data structures
     */
    mapping (address => uint256) balances;
    mapping (address => mapping (address => uint256)) allowed;

    /*
     * Public functions
     */
    /// @notice Send `_value` tokens to `_to` from `msg.sender`.
    /// @dev Transfers sender's tokens to a given address. Returns success.
    /// @param _to Address of token receiver.
    /// @param _value Number of tokens to transfer.
    /// @return Returns success of function call.
    function transfer(address _to, uint256 _value) public returns (bool) {
        require(_to != 0x0);
        require(_to != address(this));
        require(balances[msg.sender] >= _value);
        require(balances[_to] + _value >= balances[_to]);

        balances[msg.sender] -= _value;
        balances[_to] += _value;

        Transfer(msg.sender, _to, _value);

        return true;
    }

    /// @notice Send `_value` tokens to `_to` from `msg.sender` and trigger
    /// tokenFallback if sender is a contract.
    /// @dev Function that is called when a user or another contract wants to transfer funds.
    /// @param _to Address of token receiver.
    /// @param _value Number of tokens to transfer.
    /// @param _data Data to be sent to tokenFallback
    /// @return Returns success of function call.
    function transfer(
        address _to,
        uint256 _value,
        bytes _data)
        public
        returns (bool)
    {
        require(transfer(_to, _value));

        uint codeLength;

        assembly {
            // Retrieve the size of the code on target address, this needs assembly.
            codeLength := extcodesize(_to)
        }

        if (codeLength > 0) {
            ERC223ReceivingContract receiver = ERC223ReceivingContract(_to);
            receiver.tokenFallback(msg.sender, _value, _data);
        }

        return true;
    }

    /// @notice Transfer `_value` tokens from `_from` to `_to` if `msg.sender` is allowed.
    /// @dev Allows for an approved third party to transfer tokens from one
    /// address to another. Returns success.
    /// @param _from Address from where tokens are withdrawn.
    /// @param _to Address to where tokens are sent.
    /// @param _value Number of tokens to transfer.
    /// @return Returns success of function call.
    function transferFrom(address _from, address _to, uint256 _value)
        public
        returns (bool)
    {
        require(_from != 0x0);
        require(_to != 0x0);
        require(_to != address(this));
        require(balances[_from] >= _value);
        require(allowed[_from][msg.sender] >= _value);
        require(balances[_to] + _value >= balances[_to]);

        balances[_to] += _value;
        balances[_from] -= _value;
        allowed[_from][msg.sender] -= _value;

        Transfer(_from, _to, _value);

        return true;
    }

    /// @notice Allows `_spender` to transfer `_value` tokens from `msg.sender` to any address.
    /// @dev Sets approved amount of tokens for spender. Returns success.
    /// @param _spender Address of allowed account.
    /// @param _value Number of approved tokens.
    /// @return Returns success of function call.
    function approve(address _spender, uint256 _value) public returns (bool) {
        require(_spender != 0x0);

        // To change the approve amount you first have to reduce the addresses`
        // allowance to zero by calling `approve(_spender, 0)` if it is not
        // already 0 to mitigate the race condition described here:
        // https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
        require(_value == 0 || allowed[msg.sender][_spender] == 0);

        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }

    /*
     * Read functions
     */
    /// @dev Returns number of allowed tokens that a spender can transfer on
    /// behalf of a token owner.
    /// @param _owner Address of token owner.
    /// @param _spender Address of token spender.
    /// @return Returns remaining allowance for spender.
    function allowance(address _owner, address _spender)
        constant
        public
        returns (uint256)
    {
        return allowed[_owner][_spender];
    }

    /// @dev Returns number of tokens owned by the given address.
    /// @param _owner Address of token owner.
    /// @return Returns balance of owner.
    function balanceOf(address _owner) constant public returns (uint256) {
        return balances[_owner];
    }
}

/// @title xChainge Token
contract xChaingeToken is StandardToken {

    /*
     *  Terminology:
     *  1 token unit = Xei
     *  1 token = XCH = Xei * multiplier
     *  multiplier set from token's number of decimals (i.e. 10 ** decimals)
     */

    /*
     *  Token metadata
     */
    string constant public name = "xChainge Token";
    string constant public symbol = "XCH";
    uint8 constant public decimals = 18;
    uint constant multiplier = 10 ** uint(decimals);

    event Deployed(uint indexed _totalSupply);
    event Burnt(address indexed _receiver, uint indexed _num, uint indexed _totalSupply);

    /*
     *  Public functions
     */
    /// @dev Contract constructor function sets dutch auction contract address
    /// and assigns all tokens to dutch auction.
    /// @param auctionAddress Address of dutch auction contract.
    /// @param walletAddress Address of wallet.
    function xChaingeToken(address auctionAddress, address walletAddress) public
    {
        // Auction address should not be null.
        require(auctionAddress != 0x0);
        require(walletAddress != 0x0);

        // Total supply of Xei at deployment
        totalSupply = 23529412000000000000000000;

        balances[auctionAddress] = 20000000000000000000000000;
        balances[walletAddress] = 3529412000000000000000000;

        Transfer(0x0, auctionAddress, balances[auctionAddress]);
        Transfer(0x0, walletAddress, balances[walletAddress]);

        Deployed(totalSupply);

        assert(totalSupply == balances[auctionAddress] + balances[walletAddress]);
    }

    /// @notice Allows `msg.sender` to simply destroy `num` token units (Xei). This means the total
    /// token supply will decrease.
    /// @dev Allows to destroy token units (Xei).
    /// @param num Number of token units (Xei) to burn.
    function burn(uint num) public {
        require(num > 0);
        require(balances[msg.sender] >= num);
        require(totalSupply >= num);

        uint preBalance = balances[msg.sender];

        balances[msg.sender] -= num;
        totalSupply -= num;
        Burnt(msg.sender, num, totalSupply);
        Transfer(msg.sender, 0x0, num);

        assert(balances[msg.sender] == preBalance - num);
    }
}

/// @title Dutch auction contract - distribution of a fixed number of tokens using an auction.
/// The contract code is inspired by the Gnosis and Raiden auction contract. 
/// Auction ends if a fixed number of tokens was sold.
contract DutchAuction {
    /*
     * Auction for the XCH Token.
     *
     * Terminology:
     * 1 token unit = Xei
     * 1 token = XCH = Xei * multiplier
     * multiplier set from token's number of decimals (i.e. 10 ** decimals)
     */

    // Wait 10 days after the end of the auction, before anyone can claim tokens
    uint constant public tokenClaimWaitingPeriod = 10 days;

    /*
     * Storage
     */

    xChaingeToken public token;
    address public ownerAddress;
    address public walletAddress;

    // Price decay function parameters to be changed depending on the desired outcome

    // Starting price in WEI;
    uint constant public priceStart = 50000000000000000;    
    uint constant public minPrice = 5000000000000000;
    uint constant public softCap = 10000000000000000000000;

    // For calculating elapsed time for price
    uint public startTime;
    uint public endTime;
    uint public startBlock;

    // Keep track of all ETH received in the bids
    uint public receivedWei;

    // Keep track of cumulative ETH funds for which the tokens have been claimed
    uint public fundsClaimed;

    uint public tokenMultiplier;

    // Total number of Xei (XCH * multiplier) that will be auctioned
    uint public numTokensAuctioned;

    // Wei per XCH (Xei * multiplier)
    uint public finalPrice;

    // Bidder address => bid value
    mapping (address => uint) public bids;

    Stages public stage;

    /*
     * Enums
     */
    enum Stages {
        AuctionDeployed,
        AuctionSetUp,
        AuctionStarted,
        AuctionEnded,
        AuctionCanceled,
        TokensDistributed
    }

    /*
     * Modifiers
     */
    modifier atStage(Stages _stage) {
        require(stage == _stage);
        _;
    }

    modifier isOwner() {
        require(msg.sender == ownerAddress);
        _;
    }

    /*
     * Events
     */

    event Deployed();
    event Setup();
    event AuctionStarted(uint indexed _startTime, uint indexed _blockNumber);
    event BidSubmission(address indexed _sender, uint _amount, uint _missingFunds);
    event ClaimedTokens(address indexed _recipient, uint _sentAmount);
    event AuctionEnded(uint _finalPrice);
    event TokensDistributed();
    event AuctionCanceled();

    /*
     * Public functions
     */

    /// @dev Contract constructor function sets the starting price, divisor constant and
    /// divisor exponent for calculating the Dutch Auction price.
    /// @param _walletAddress Wallet address
    function DutchAuction(address _walletAddress) public
    {
        require(_walletAddress != 0x0);
        walletAddress = _walletAddress;

        ownerAddress = msg.sender;
        stage = Stages.AuctionDeployed;
        Deployed();
    }

    /// @dev Fallback function for the contract, which calls bid() if the auction has started.
    function () public payable atStage(Stages.AuctionStarted) {
        bid();
    }

    /// @notice Set `_tokenAddress` as the token address to be used in the auction.
    /// @dev Setup function sets external contracts addresses.
    /// @param _tokenAddress Token address.
    function setup(address _tokenAddress) public isOwner atStage(Stages.AuctionDeployed) {
        require(_tokenAddress != 0x0);
        token = xChaingeToken(_tokenAddress);

        // Get number of Xei (XCH * multiplier) to be auctioned from token auction balance
        numTokensAuctioned = token.balanceOf(address(this));

        // Set the number of the token multiplier for its decimals
        tokenMultiplier = 10 ** uint(token.decimals());

        stage = Stages.AuctionSetUp;
        Setup();
    }

    /// @notice Start the auction.
    /// @dev Starts auction and sets startTime.
    function startAuction() public isOwner atStage(Stages.AuctionSetUp) {
        stage = Stages.AuctionStarted;
        startTime = now;
        startBlock = block.number;
        AuctionStarted(startTime, startBlock);
    }

    /// @notice Finalize the auction - sets the final XCH token price and changes the auction
    /// stage after no bids are allowed anymore.
    /// @dev Finalize auction and set the final XCH token price.
    function finalizeAuction() public atStage(Stages.AuctionStarted)
    {
        require(price() == minPrice);

        endTime = now;

        if (receivedWei < softCap)
        {
            token.transfer(walletAddress, numTokensAuctioned);
            stage = Stages.AuctionCanceled;
            AuctionCanceled();
            return;
        }

        // Send ETH to wallet
        walletAddress.transfer(receivedWei);

        uint missingFunds = missingFundsToEndAuction();
        if (missingFunds > 0){
            uint soldTokens = tokenMultiplier * receivedWei / price();
            uint burnTokens = numTokensAuctioned - soldTokens;
            token.burn(burnTokens);
            numTokensAuctioned -= burnTokens;
        }

        // Calculate the final price = WEI / XCH = WEI / (Xei / multiplier)
        // Reminder: numTokensAuctioned is the number of Xei (XCH * multiplier) that are auctioned
        finalPrice = tokenMultiplier * receivedWei / numTokensAuctioned;

        stage = Stages.AuctionEnded;
        AuctionEnded(finalPrice);

        assert(finalPrice > 0);
    }

    /// @notice Canceled the auction
    function CancelAuction() public isOwner atStage(Stages.AuctionStarted)
    {
        token.transfer(walletAddress, numTokensAuctioned);
        stage = Stages.AuctionCanceled;
        AuctionCanceled();
    }

    /// --------------------------------- Auction Functions ------------------


    /// @notice Send `msg.value` WEI to the auction from the `msg.sender` account.
    /// @dev Allows to send a bid to the auction.
    function bid() public payable atStage(Stages.AuctionStarted)
    {
        require(msg.value > 0);
        assert(bids[msg.sender] + msg.value >= msg.value);

        // Missing funds without the current bid value
        uint missingFunds = missingFundsToEndAuction();

        // We require bid values to be less than the funds missing to end the auction
        // at the current price.
        require(msg.value <= missingFunds);

        bids[msg.sender] += msg.value;
        receivedWei += msg.value;

        BidSubmission(msg.sender, msg.value, missingFunds);

        assert(receivedWei >= msg.value);
    }

    /// @notice Claim auction tokens for `msg.sender` after the auction has ended.
    /// @dev Claims tokens for `msg.sender` after auction. To be used if tokens can
    /// be claimed by beneficiaries, individually.
    function claimTokens() public atStage(Stages.AuctionEnded) returns (bool) {
        return proxyClaimTokens(msg.sender);
    }

    /// @notice Claim auction tokens for `receiverAddress` after the auction has ended.
    /// @dev Claims tokens for `receiverAddress` after auction has ended.
    /// @param receiverAddress Tokens will be assigned to this address if eligible.
    function proxyClaimTokens(address receiverAddress) public atStage(Stages.AuctionEnded) returns (bool)
    {
        // Waiting period after the end of the auction, before anyone can claim tokens
        // Ensures enough time to check if auction was finalized correctly
        // before users start transacting tokens
        require(now > endTime + tokenClaimWaitingPeriod);
        require(receiverAddress != 0x0);

        if (bids[receiverAddress] == 0) {
            return false;
        }

        // Number of Xei = bid wei / Xei = bid wei / (wei per XCH * multiplier)
        uint num = (tokenMultiplier * bids[receiverAddress]) / finalPrice;

        // Due to finalPrice floor rounding, the number of assigned tokens may be higher
        // than expected. Therefore, the number of remaining unassigned auction tokens
        // may be smaller than the number of tokens needed for the last claimTokens call
        uint auctionTokensBalance = token.balanceOf(address(this));
        if (num > auctionTokensBalance) {
            num = auctionTokensBalance;
        }

        // Update the total amount of funds for which tokens have been claimed
        fundsClaimed += bids[receiverAddress];

        // Set receiver bid to 0 before assigning tokens
        bids[receiverAddress] = 0;

        require(token.transfer(receiverAddress, num));

        ClaimedTokens(receiverAddress, num);

        // After the last tokens are claimed, we change the auction stage
        // Due to the above logic, rounding errors will not be an issue
        if (fundsClaimed == receivedWei) {
            stage = Stages.TokensDistributed;
            TokensDistributed();
        }

        assert(token.balanceOf(receiverAddress) >= num);
        assert(bids[receiverAddress] == 0);
        return true;
    }

    /// @notice Withdraw ETH for `msg.sender` after the auction has canceled.
    function withdraw() public atStage(Stages.AuctionCanceled) returns (bool) {
        return proxyWithdraw(msg.sender);
    }

    /// @notice Withdraw ETH for `receiverAddress` after the auction has canceled.
    /// @param receiverAddress ETH will be assigned to this address if eligible.
    function proxyWithdraw(address receiverAddress) public atStage(Stages.AuctionCanceled) returns (bool) {
        require(receiverAddress != 0x0);
        
        if (bids[receiverAddress] == 0) {
            return false;
        }

        uint amount = bids[receiverAddress];
        bids[receiverAddress] = 0;
        
        receiverAddress.transfer(amount);

        assert(bids[receiverAddress] == 0);
        return true;
    }

    /// @notice Get the XCH price in WEI during the auction, at the time of
    /// calling this function. Returns `0` if auction has ended.
    /// Returns `priceStart` before auction has started.
    /// @dev Calculates the current XCH token price in WEI.
    /// @return Returns WEI per XCH (Xei * multiplier).
    function price() public constant returns (uint) {
        if (stage == Stages.AuctionEnded ||
            stage == Stages.AuctionCanceled ||
            stage == Stages.TokensDistributed) {
            return 0;
        }
        return calcTokenPrice();
    }

    /// @notice Get the missing funds needed to end the auction,
    /// calculated at the current XCH price in WEI.
    /// @dev The missing funds amount necessary to end the auction at the current XCH price in WEI.
    /// @return Returns the missing funds amount in WEI.
    function missingFundsToEndAuction() constant public returns (uint) {

        // numTokensAuctioned = total number of Xei (XCH * multiplier) that is auctioned
        uint requiredWeiAtPrice = numTokensAuctioned * price() / tokenMultiplier;
        if (requiredWeiAtPrice <= receivedWei) {
            return 0;
        }

        // assert(requiredWeiAtPrice - receivedWei > 0);
        return requiredWeiAtPrice - receivedWei;
    }

    /*
     *  Private functions
     */

    /// @dev Calculates the token price (WEI / XCH) at the current timestamp
    /// during the auction; elapsed time = 0 before auction starts.
    /// Based on the provided parameters, the price does not change in the first
    /// `priceConstant^(1/priceExponent)` seconds due to rounding.
    /// Rounding in `decayRate` also produces values that increase instead of decrease
    /// in the beginning; these spikes decrease over time and are noticeable
    /// only in first hours. This should be calculated before usage.
    /// @return Returns the token price - Wei per XCH.
    function calcTokenPrice() constant private returns (uint) {
        uint elapsed;
        if (stage == Stages.AuctionStarted) {
            elapsed = now - startTime;
        }

        uint decayRate = elapsed ** 3 / 541000000000;
        uint currentPrice = priceStart * (1 + elapsed) / (1 + elapsed + decayRate);
        return minPrice > currentPrice ? minPrice : currentPrice;
    }
}