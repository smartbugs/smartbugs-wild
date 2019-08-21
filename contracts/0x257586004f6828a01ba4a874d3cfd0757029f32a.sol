pragma solidity 0.4.25;
pragma experimental ABIEncoderV2;

contract dexBlue{
    
    // Events

    /** @notice The event, emitted when a trade is settled
      * @param  index Implying the index of the settled trade in the trade array passed to matchTrades() 
      */
    event TradeSettled(uint8 index);

    /** @notice The event, emitted when a trade settlement failed
      * @param  index Implying the index of the failed trade in the trade array passed to matchTrades() 
      */
    event TradeFailed(uint8 index);

    /** @notice The event, emitted after a successful deposit of ETH or token
      * @param  account  The address, which initiated the deposit
      * @param  token    The address of the deposited token (ETH is address(0))
      * @param  amount   The amount deposited in this transaction 
      */
    event Deposit(address account, address token, uint256 amount);

    /** @notice The event, emitted after a successful (multi-sig) withdrawal of deposited ETH or token
      * @param  account  The address, which initiated the withdrawal
      * @param  token    The address of the token which is withdrawn (ETH is address(0))
      * @param  amount   The amount withdrawn in this transaction 
      */
    event Withdrawal(address account, address token, uint256 amount);

    /** @notice The event, emitted after a user successfully blocked tokens or ETH for a single signature withdrawal
      * @param  account  The address controlling the tokens
      * @param  token    The address of the token which is blocked (ETH is address(0))
      * @param  amount   The amount blocked in this transaction 
      */
    event BlockedForSingleSigWithdrawal(address account, address token, uint256 amount);

    /** @notice The event, emitted after a successful single-sig withdrawal of deposited ETH or token
      * @param  account  The address, which initiated the withdrawal
      * @param  token    The address of the token which is withdrawn (ETH is address(0))
      * @param  amount   The amount withdrawn in this transaction 
      */
    event SingleSigWithdrawal(address account, address token, uint256 amount);

    /** @notice The event, emitted once the feeCollector address initiated a withdrawal of collected tokens or ETH via feeWithdrawal()
      * @param  token    The address of the token which is withdrawn (ETH is address(0))
      * @param  amount   The amount withdrawn in this transaction 
      */
    event FeeWithdrawal(address token, uint256 amount);

    /** @notice The event, emitted once an on-chain cancellation of an order was performed
      * @param  hash    The invalidated orders hash 
      */
    event OrderCanceled(bytes32 hash);
   
    /** @notice The event, emitted once a address delegation or dedelegation was performed
      * @param  delegator The delegating address,
      * @param  delegate  The delegated address,
      * @param  status    Whether the transaction delegated an address (true) or inactivated an active delegation (false) 
      */
    event DelegateStatus(address delegator, address delegate, bool status);


    // Mappings 

    mapping(address => mapping(address => uint256)) balances;                           // Users balances (token address > user address > balance amount) (ETH is address(0))
    mapping(address => mapping(address => uint256)) blocked_for_single_sig_withdrawal;  // Users balances they blocked to withdraw without arbiters multi-sig (token address > user address > balance amount) (ETH is address(0))
    mapping(address => uint256) last_blocked_timestamp;                                 // The last timestamp a user blocked tokens to withdraw without arbiters multi-sig
    mapping(bytes32 => bool) processed_withdrawals;                                     // Processed withdrawal hashes
    mapping(bytes32 => uint256) matched;                                                // Orders matched sell_amounts to prevent multiple-/over- matches of the same orders
    mapping(address => address) delegates;                                              // Delegated order signing addresses


    // EIP712 (signTypedData)

    // EIP712 Domain
    struct EIP712_Domain {
        string  name;
        string  version;
        uint256 chainId;
        address verifyingContract;
    }
    bytes32 constant EIP712_DOMAIN_TYPEHASH = keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)");
    bytes32          EIP712_DOMAIN_SEPARATOR;
    // Order typehash
    bytes32 constant EIP712_ORDER_TYPEHASH = keccak256("Order(address buyTokenAddress,address sellTokenAddress,uint256 buyTokenAmount,uint256 sellTokenAmount,uint64 nonce)");
    // Withdrawal typehash
    bytes32 constant EIP712_WITHDRAWAL_TYPEHASH = keccak256("Withdrawal(address token,uint256 amount,uint64 nonce)");
        

    // Utility functions:

    /** @notice Get the balance of a user for a specific token
      * @param  token  The token address (ETH is token address(0))
      * @param  holder The address holding the token
      * @return The amount of the specified token held by the user 
      */
    function getBalance(address token, address holder) constant public returns(uint256){
        return balances[token][holder];
    }
    
    /** @notice Get the balance a user blocked for a single-signature withdrawal (ETH is token address(0))
      * @param  token  The token address (ETH is token address(0))
      * @param  holder The address holding the token
      * @return The amount of the specified token blocked by the user 
      */
    function getBlocked(address token, address holder) constant public returns(uint256){
        return blocked_for_single_sig_withdrawal[token][holder];
    }
    
    /** @notice Returns the timestamp of the last blocked balance
      * @param  user  Address of the user which blocked funds
      * @return The last unix timestamp the user blocked funds at, which starts the waiting period for single-sig withdrawals 
      */
    function getLastBlockedTimestamp(address user) constant public returns(uint256){
        return last_blocked_timestamp[user];
    }


    // Deposit functions:

    /** @notice Deposit Ether into the smart contract 
      */
    function depositEther() public payable{
        balances[address(0)][msg.sender] += msg.value;      // Add the received ETH to the users balance
        emit Deposit(msg.sender, address(0), msg.value);    // Emit a deposit event
    }
    
    /** @notice Fallback function to credit ETH sent to the contract without data 
      */
    function() public payable{
        depositEther();                                     // Call the deposit function to credit ETH sent in this transaction
    }
    
    /** @notice Deposit ERC20 tokens into the smart contract (remember to set allowance in the token contract first)
      * @param  token   The address of the token to deposit
      * @param  amount  The amount of tokens to deposit 
      */
    function depositToken(address token, uint256 amount) public {
        Token(token).transferFrom(msg.sender, address(this), amount);    // Deposit ERC20
        require(
            checkERC20TransferSuccess(),                                 // Check whether the ERC20 token transfer was successful
            "ERC20 token transfer failed."
        );
        balances[token][msg.sender] += amount;                           // Credit the deposited token to users balance
        emit Deposit(msg.sender, token, amount);                         // Emit a deposit event
    }
        
    // Multi-sig withdrawal functions:

    /** @notice User-submitted withdrawal with arbiters signature, which withdraws to the users address
      * @param  token   The token to withdraw (ETH is address(address(0)))
      * @param  amount  The amount of tokens to withdraw
      * @param  nonce   The nonce (to salt the hash)
      * @param  v       Multi-signature v
      * @param  r       Multi-signature r
      * @param  s       Multi-signature s 
      */
    function multiSigWithdrawal(address token, uint256 amount, uint64 nonce, uint8 v, bytes32 r, bytes32 s) public {
        bytes32 hash = keccak256(abi.encodePacked(                      // Calculate the withdrawal hash from the parameters
            "\x19Ethereum Signed Message:\n32", 
            keccak256(abi.encodePacked(
                msg.sender,
                token,
                amount,
                nonce,
                address(this)
            ))
        ));
        if(
            !processed_withdrawals[hash]                                // Check if the withdrawal was initiated before
            && arbiters[ecrecover(hash, v,r,s)]                         // Check if the multi-sig is valid
            && balances[token][msg.sender] >= amount                    // Check if the user holds the required balance
        ){
            processed_withdrawals[hash]  = true;                        // Mark this withdrawal as processed
            balances[token][msg.sender] -= amount;                      // Substract withdrawn token from users balance
            if(token == address(0)){                                    // Withdraw ETH
                require(
                    msg.sender.send(amount),
                    "Sending of ETH failed."
                );
            }else{                                                      // Withdraw an ERC20 token
                Token(token).transfer(msg.sender, amount);              // Transfer the ERC20 token
                require(
                    checkERC20TransferSuccess(),                        // Check whether the ERC20 token transfer was successful
                    "ERC20 token transfer failed."
                );
            }

            blocked_for_single_sig_withdrawal[token][msg.sender] = 0;   // Set possible previous manual blocking of these funds to 0
        
            emit Withdrawal(msg.sender,token,amount);                   // Emit a Withdrawal event
        }else{
            revert();                                                   // Revert the transaction if checks fail
        }
    }    

    /** @notice User-submitted withdrawal with arbiters signature, which sends tokens to specified address
      * @param  token              The token to withdraw (ETH is address(address(0)))
      * @param  amount             The amount of tokens to withdraw
      * @param  nonce              The nonce (to salt the hash)
      * @param  v                  Multi-signature v
      * @param  r                  Multi-signature r
      * @param  s                  Multi-signature s
      * @param  receiving_address  The address to send the withdrawn token/ETH to
      */
    function multiSigSend(address token, uint256 amount, uint64 nonce, uint8 v, bytes32 r, bytes32 s, address receiving_address) public {
        bytes32 hash = keccak256(abi.encodePacked(                      // Calculate the withdrawal hash from the parameters 
            "\x19Ethereum Signed Message:\n32", 
            keccak256(abi.encodePacked(
                msg.sender,
                token,
                amount,
                nonce,
                address(this)
            ))
        ));
        if(
            !processed_withdrawals[hash]                                // Check if the withdrawal was initiated before
            && arbiters[ecrecover(hash, v,r,s)]                         // Check if the multi-sig is valid
            && balances[token][msg.sender] >= amount                    // Check if the user holds the required balance
        ){
            processed_withdrawals[hash]  = true;                        // Mark this withdrawal as processed
            balances[token][msg.sender] -= amount;                      // Substract the withdrawn balance from the users balance
            if(token == address(0)){                                    // Process an ETH withdrawal
                require(
                    receiving_address.send(amount),
                    "Sending of ETH failed."
                );
            }else{                                                      // Withdraw an ERC20 token
                Token(token).transfer(receiving_address, amount);       // Transfer the ERC20 token
                require(
                    checkERC20TransferSuccess(),                        // Check whether the ERC20 token transfer was successful
                    "ERC20 token transfer failed."
                );
            }

            blocked_for_single_sig_withdrawal[token][msg.sender] = 0;   // Set possible previous manual blocking of these funds to 0
            
            emit Withdrawal(msg.sender,token,amount);                   // Emit a Withdrawal event
        }else{
            revert();                                                   // Revert the transaction if checks fail
        }
    }

    /** @notice User-submitted transfer with arbiters signature, which sends tokens to another addresses account in the smart contract
      * @param  token              The token to transfer (ETH is address(address(0)))
      * @param  amount             The amount of tokens to transfer
      * @param  nonce              The nonce (to salt the hash)
      * @param  v                  Multi-signature v
      * @param  r                  Multi-signature r
      * @param  s                  Multi-signature s
      * @param  receiving_address  The address to transfer the token/ETH to
      */
    function multiSigTransfer(address token, uint256 amount, uint64 nonce, uint8 v, bytes32 r, bytes32 s, address receiving_address) public {
        bytes32 hash = keccak256(abi.encodePacked(                      // Calculate the withdrawal/transfer hash from the parameters 
            "\x19Ethereum Signed Message:\n32", 
            keccak256(abi.encodePacked(
                msg.sender,
                token,
                amount,
                nonce,
                address(this)
            ))
        ));
        if(
            !processed_withdrawals[hash]                                // Check if the withdrawal was initiated before
            && arbiters[ecrecover(hash, v,r,s)]                         // Check if the multi-sig is valid
            && balances[token][msg.sender] >= amount                    // Check if the user holds the required balance
        ){
            processed_withdrawals[hash]         = true;                 // Mark this withdrawal as processed
            balances[token][msg.sender]        -= amount;               // Substract the balance from the withdrawing account
            balances[token][receiving_address] += amount;               // Add the balance to the receiving account
            
            blocked_for_single_sig_withdrawal[token][msg.sender] = 0;   // Set possible previous manual blocking of these funds to 0
            
            emit Withdrawal(msg.sender,token,amount);                   // Emit a Withdrawal event
            emit Deposit(receiving_address,token,amount);               // Emit a Deposit event
        }else{
            revert();                                                   // Revert the transaction if checks fail
        }
    }

    /** @notice Arbiter submitted withdrawal with users multi-sig to users address
      * @param  token   The token to withdraw (ETH is address(address(0)))
      * @param  amount  The amount of tokens to withdraw
      * @param  fee     The fee, covering the gas cost of the arbiter
      * @param  nonce   The nonce (to salt the hash)
      * @param  v       Multi-signature v (either 27 or 28. To identify the different signing schemes an offset of 10 is applied for EIP712)
      * @param  r       Multi-signature r
      * @param  s       Multi-signature s
      */
    function userSigWithdrawal(address token, uint256 amount, uint256 fee, uint64 nonce, uint8 v, bytes32 r, bytes32 s) public {            
        bytes32 hash;
        if(v < 30){                                                     // Standard signing scheme (personal.sign())
            hash = keccak256(abi.encodePacked(                          // Restore multi-sig hash
                "\x19Ethereum Signed Message:\n32",
                keccak256(abi.encodePacked(
                    token,
                    amount,
                    nonce,
                    address(this)
                ))
            ));
        }else{                                                          // EIP712 signing scheme
            v -= 10;                                                    // Remove offset
            hash = keccak256(abi.encodePacked(                          // Restore multi-sig hash
                "\x19\x01",
                EIP712_DOMAIN_SEPARATOR,
                keccak256(abi.encode(
                    EIP712_WITHDRAWAL_TYPEHASH,
                    token,
                    amount,
                    nonce
                ))
            ));
        }
        address account = ecrecover(hash, v, r, s);                     // Restore signing address
        if(
            !processed_withdrawals[hash]                                // Check if the withdrawal was initiated before
            && arbiters[msg.sender]                                     // Check if transaction comes from arbiter
            && fee <= amount / 50                                       // Check if fee is not too big
            && balances[token][account] >= amount                       // Check if the user holds the required tokens
        ){
            processed_withdrawals[hash]    = true;
            balances[token][account]      -= amount;
            balances[token][feeCollector] += fee;                       // Fee to cover gas costs for the withdrawal
            if(token == address(0)){                                    // Send ETH
                require(
                    account.send(amount - fee),
                    "Sending of ETH failed."
                );
            }else{
                Token(token).transfer(account, amount - fee);           // Withdraw ERC20
                require(
                    checkERC20TransferSuccess(),                        // Check if the transfer was successful
                    "ERC20 token transfer failed."
                );
            }
        
            blocked_for_single_sig_withdrawal[token][account] = 0;      // Set possible previous manual blocking of these funds to 0
            
            emit Withdrawal(account,token,amount);                      // Emit a Withdrawal event
        }else{
            revert();                                                   // Revert the transaction is checks fail
        }
    }
    
    // Single-sig withdrawal functions:

    /** @notice Allows user to block funds for single-sig withdrawal after 24h waiting period 
      *         (This period is necessary to ensure all trades backed by these funds will be settled.)
      * @param  token   The address of the token to block (ETH is address(address(0)))
      * @param  amount  The amount of the token to block
      */
    function blockFundsForSingleSigWithdrawal(address token, uint256 amount) public {
        if (balances[token][msg.sender] - blocked_for_single_sig_withdrawal[token][msg.sender] >= amount){  // Check if the user holds the required funds
            blocked_for_single_sig_withdrawal[token][msg.sender] += amount;         // Block funds for manual withdrawal
            last_blocked_timestamp[msg.sender] = block.timestamp;                   // Start 24h waiting period
            emit BlockedForSingleSigWithdrawal(msg.sender,token,amount);            // Emit BlockedForSingleSigWithdrawal event
        }else{
            revert();                                                               // Revert the transaction if the user does not hold the required balance
        }
    }
    
    /** @notice Allows user to withdraw funds previously blocked after 24h
      */
    function initiateSingleSigWithdrawal(address token, uint256 amount) public {
        if (
            balances[token][msg.sender] >= amount                                   // Check if the user holds the funds
            && blocked_for_single_sig_withdrawal[token][msg.sender] >= amount       // Check if these funds are blocked
            && last_blocked_timestamp[msg.sender] + 86400 <= block.timestamp        // Check if the one day waiting period has passed
        ){
            balances[token][msg.sender] -= amount;                                  // Substract the tokens from users balance
            blocked_for_single_sig_withdrawal[token][msg.sender] -= amount;         // Substract the tokens from users blocked balance
            if(token == address(0)){                                                // Withdraw ETH
                require(
                    msg.sender.send(amount),
                    "Sending of ETH failed."
                );
            }else{                                                                  // Withdraw ERC20 tokens
                Token(token).transfer(msg.sender, amount);                          // Transfer the ERC20 tokens
                require(
                    checkERC20TransferSuccess(),                                    // Check if the transfer was successful
                    "ERC20 token transfer failed."
                );
            }
            emit SingleSigWithdrawal(msg.sender,token,amount);                      // Emit a SingleSigWithdrawal event
        }else{
            revert();                                                               // Revert the transaction if the required checks fail
        }
    } 


    //Trade settlement structs and function
    
    struct OrderInput{
        uint8       buy_token;      // The token, the order signee wants to buy
        uint8       sell_token;     // The token, the order signee wants to sell
        uint256     buy_amount;     // The total amount the signee wants to buy
        uint256     sell_amount;    // The total amount the signee wants to give for the amount he wants to buy (the orders "rate" is implied by the ratio between the two amounts)
        uint64      nonce;          // Random number to give each order an individual hash and signature
        int8        v;              // Signature v (either 27 or 28)
                                    // To identify the different signing schemes an offset of 10 is applied for EIP712.
                                    // To identify whether the order was signed by a delegated signing address, the number is either positive or negative.
        bytes32     r;              // Signature r
        bytes32     s;              // Signature s
    }
    
    struct TradeInput{
        uint8       maker_order;    // The index of the maker order
        uint8       taker_order;    // The index of the taker order
        uint256     maker_amount;   // The amount the maker gives in return for the taker's tokens
        uint256     taker_amount;   // The amount the taker gives in return for the maker's tokens
        uint256     maker_fee;      // The trading fee of the maker + a share in the settlement (gas) cost
        uint256     taker_fee;      // The trading fee of the taker + a share in the settlement (gas) cost
        uint256     maker_rebate;   // A optional rebate for the maker (portion of takers fee) as an incentive
    }

    /** @notice Allows an arbiter to settle trades between two user-signed orders
      * @param  addresses  Array of all addresses involved in the transactions
      * @param  orders     Array of all orders involved in the transactions
      * @param  trades     Array of the trades to be settled
      */   
    function matchTrades(address[] addresses, OrderInput[] orders, TradeInput[] trades) public {
        require(arbiters[msg.sender] && marketActive);      // Check if msg.sender is an arbiter and the market is active
        
        //Restore signing addresses
        uint len = orders.length;                           // Length of orders array to loop through
        bytes32[]  memory hashes = new bytes32[](len);      // Array of the restored order hashes
        address[]  memory signee = new address[](len);      // Array of the restored order signees
        OrderInput memory order;                            // Memory slot to cache orders while looping (otherwise the Stack would be too deep)
        address    addressCache1;                           // Memory slot 1 to cache addresses while looping (otherwise the Stack would be too deep)
        address    addressCache2;                           // Memory slot 2 to cache addresses while looping (otherwise the Stack would be too deep)
        bool       delegated;
        
        for(uint8 i = 0; i < len; i++){                     // Loop through the orders array to restore all signees
            order         = orders[i];                      // Cache order
            addressCache1 = addresses[order.buy_token];     // Cache orders buy token
            addressCache2 = addresses[order.sell_token];    // Cache orders sell token
            
            if(order.v < 0){                                // Check if the order is signed by a delegate
                delegated = true;                           
                order.v  *= -1;                             // Restore the negated v
            }else{
                delegated = false;
            }
            
            if(order.v < 30){                               // Order is hashed after signature scheme personal.sign()
                hashes[i] = keccak256(abi.encodePacked(     // Restore the hash of this order
                    "\x19Ethereum Signed Message:\n32",
                    keccak256(abi.encodePacked(
                        addressCache1,
                        addressCache2,
                        order.buy_amount,
                        order.sell_amount,
                        order.nonce,        
                        address(this)                       // This contract's address
                    ))
                ));
            }else{                                          // Order is hashed after EIP712
                order.v -= 10;                              // Remove signature format identifying offset
                hashes[i] = keccak256(abi.encodePacked(
                    "\x19\x01",
                    EIP712_DOMAIN_SEPARATOR,
                    keccak256(abi.encode(
                        EIP712_ORDER_TYPEHASH,
                        addressCache1,
                        addressCache2,
                        order.buy_amount,
                        order.sell_amount,
                        order.nonce
                    ))
                ));
            }
            signee[i] = ecrecover(                          // Restore the signee of this order
                hashes[i],                                  // Order hash
                uint8(order.v),                             // Signature v
                order.r,                                    // Signature r
                order.s                                     // Signature s
            );
            // When the signature was delegated restore delegating address
            if(delegated){
                signee[i] = delegates[signee[i]];
            }
        }
        
        // Settle Trades after check
        len = trades.length;                                            // Length of the trades array to loop through
        TradeInput memory trade;                                        // Memory slot to cache trades while looping
        uint maker_index;                                               // Memory slot to cache the trade's maker order index
        uint taker_index;                                               // Memory slot to cache the trade's taker order index
        
        for(i = 0; i < len; i++){                                       // Loop through trades to settle after checks
            trade = trades[i];                                          // Cache trade
            maker_index = trade.maker_order;                            // Cache maker order index
            taker_index = trade.taker_order;                            // Cache taker order index
            addressCache1 = addresses[orders[maker_index].buy_token];   // Cache first of the two swapped token addresses
            addressCache2 = addresses[orders[taker_index].buy_token];   // Cache second of the two swapped token addresses
            
            if( // Check if the arbiter has matched following the conditions of the two order signees
                // Do maker and taker want to trade the same tokens with each other
                    orders[maker_index].buy_token == orders[taker_index].sell_token
                && orders[taker_index].buy_token == orders[maker_index].sell_token
                
                // Do maker and taker hold the required balances
                && balances[addressCache2][signee[maker_index]] >= trade.maker_amount - trade.maker_rebate
                && balances[addressCache1][signee[taker_index]] >= trade.taker_amount
                
                // Are they both matched at a rate better or equal to the one they signed
                && trade.maker_amount - trade.maker_rebate <= orders[maker_index].sell_amount * trade.taker_amount / orders[maker_index].buy_amount + 1  // Check maker doesn't overpay (+ 1 to deal with rouding errors for very smal amounts)
                && trade.taker_amount <= orders[taker_index].sell_amount * trade.maker_amount / orders[taker_index].buy_amount + 1                       // Check taker doesn't overpay (+ 1 to deal with rouding errors for very smal amounts)
                
                // Check if the matched amount + previously matched trades doesn't exceed the amount specified by the order signee
                && trade.taker_amount + matched[hashes[taker_index]] <= orders[taker_index].sell_amount
                && trade.maker_amount - trade.maker_rebate + matched[hashes[maker_index]] <= orders[maker_index].sell_amount
                    
                // Check if the charged fee is not too high
                && trade.maker_fee <= trade.taker_amount / 100
                && trade.taker_fee <= trade.maker_amount / 50
                
                // Check if maker_rebate is smaller than or equal to the taker's fee which compensates it
                && trade.maker_rebate <= trade.taker_fee
            ){
                // Settle the trade:
                
                // Substract sold amounts
                balances[addressCache2][signee[maker_index]] -= trade.maker_amount - trade.maker_rebate;    // Substract maker's sold amount minus the makers rebate
                balances[addressCache1][signee[taker_index]] -= trade.taker_amount;                         // Substract taker's sold amount
                
                // Add bought amounts
                balances[addressCache1][signee[maker_index]] += trade.taker_amount - trade.maker_fee;       // Give the maker his bought amount minus the fee
                balances[addressCache2][signee[taker_index]] += trade.maker_amount - trade.taker_fee;       // Give the taker his bought amount minus the fee
                
                // Save bought amounts to prevent double matching
                matched[hashes[maker_index]] += trade.maker_amount;                                         // Prevent maker order from being reused
                matched[hashes[taker_index]] += trade.taker_amount;                                         // Prevent taker order from being reused
                
                // Give fee to feeCollector
                balances[addressCache2][feeCollector] += trade.taker_fee - trade.maker_rebate;              // Give the feeColletor the taker fee minus the maker rebate 
                balances[addressCache1][feeCollector] += trade.maker_fee;                                   // Give the feeColletor the maker fee
                
                // Set possible previous manual blocking of these funds to 0
                blocked_for_single_sig_withdrawal[addressCache2][signee[maker_index]] = 0;                  // If the maker tried to block funds which he/she used in this order we have to unblock them
                blocked_for_single_sig_withdrawal[addressCache1][signee[taker_index]] = 0;                  // If the taker tried to block funds which he/she used in this order we have to unblock them
                
                emit TradeSettled(i);                                                                       // Emit tradeSettled Event to confirm the trade was settled
            }else{
                emit TradeFailed(i);                                                                        // Emit tradeFailed Event because the trade checks failed
            }
        }
    }


    // Order cancellation functions

    /** @notice Give the user the option to perform multiple on-chain cancellations of orders at once with arbiters multi-sig
      * @param  orderHashes Array of orderHashes of the orders to be canceled
      * @param  v           Multi-sig v
      * @param  r           Multi-sig r
      * @param  s           Multi-sig s
      */
    function multiSigOrderBatchCancel(bytes32[] orderHashes, uint8 v, bytes32 r, bytes32 s) public {
        if(
            arbiters[                                               // Check if the signee is an arbiter
                ecrecover(                                          // Restore the signing address
                    keccak256(abi.encodePacked(                     // Restore the signed hash (hash of all orderHashes)
                        "\x19Ethereum Signed Message:\n32", 
                        keccak256(abi.encodePacked(orderHashes))
                    )),
                    v, r, s
                )
            ]
        ){
            uint len = orderHashes.length;
            for(uint8 i = 0; i < len; i++){
                matched[orderHashes[i]] = 2**256 - 1;               // Set the matched amount of all orders to the maximum
                emit OrderCanceled(orderHashes[i]);                 // emit OrderCanceled event
            }
        }else{
            revert();
        }
    }
        
    /** @notice Give arbiters the option to perform on-chain multiple cancellations of orders at once  
      * @param orderHashes Array of hashes of the orders to be canceled
      */
    function orderBatchCancel(bytes32[] orderHashes) public {
        if(
            arbiters[msg.sender]                        // Check if the sender is an arbiter
        ){
            uint len = orderHashes.length;
            for(uint8 i = 0; i < len; i++){
                matched[orderHashes[i]] = 2**256 - 1;   // Set the matched amount of all orders to the maximum
                emit OrderCanceled(orderHashes[i]);     // emit OrderCanceled event
            }
        }else{
            revert();
        }
    }
        
        
    // Signature delegation

    /** @notice delegate an address to allow it to sign orders on your behalf
      * @param delegate  The address to delegate
      */
    function delegateAddress(address delegate) public {
        // set as delegate
        require(delegates[delegate] == address(0), "Address is already a delegate");
        delegates[delegate] = msg.sender;
        
        emit DelegateStatus(msg.sender, delegate, true);
    }
    
    /** @notice revoke the delegation of an address
      * @param  delegate  The delegated address
      * @param  v         Multi-sig v
      * @param  r         Multi-sig r
      * @param  s         Multi-sig s
      */
    function revokeDelegation(address delegate, uint8 v, bytes32 r, bytes32 s) public {
        bytes32 hash = keccak256(abi.encodePacked(              // Restore the signed hash
            "\x19Ethereum Signed Message:\n32", 
            keccak256(abi.encodePacked(
                delegate,
                msg.sender,
                address(this)
            ))
        ));

        require(arbiters[ecrecover(hash, v, r, s)], "MultiSig is not from known arbiter");  // Check if signee is an arbiter
        
        delegates[delegate] = address(1);       // set to 1 not 0 to prevent double delegation, which would make old signed order valid for the new delegator
        
        emit DelegateStatus(msg.sender, delegate, false);
    }
    

    // Management functions:

    address owner;                      // Contract owner address (has the right to nominate arbiters and the feeCollectors addresses)   
    address feeCollector;               // feeCollector address
    bool marketActive = true;           // Make it possible to pause the market
    bool feeCollectorLocked = false;    // Make it possible to lock the feeCollector address (to allow to change the feeCollector to a fee distribution contract)
    mapping(address => bool) arbiters;  // Mapping of arbiters
    
    /** @notice Constructor function
      */
    constructor() public {
        owner = msg.sender;             // Nominate sender to be the contract owner
        feeCollector = msg.sender;      // Nominate sender to be the standart feeCollector
        arbiters[msg.sender] = true;    // Nominate sender to be an arbiter
        
        // create EIP712 domain seperator
        EIP712_Domain memory eip712Domain = EIP712_Domain({
            name              : "dex.blue",
            version           : "1",
            chainId           : 1,
            verifyingContract : this
        });
        EIP712_DOMAIN_SEPARATOR = keccak256(abi.encode(
            EIP712_DOMAIN_TYPEHASH,
            keccak256(bytes(eip712Domain.name)),
            keccak256(bytes(eip712Domain.version)),
            eip712Domain.chainId,
            eip712Domain.verifyingContract
        ));
    }
    
    /** @notice Allows the owner to nominate or denominate trade arbitting addresses
      * @param  arbiter The arbiter whose status to change
      * @param  status  Whether the address should be an arbiter (true) or not (false)
      */
    function nominateArbiter(address arbiter, bool status) public {
        require(msg.sender == owner);                           // Check if sender is owner
        arbiters[arbiter] = status;                             // Update address status
    }

    /** @notice Allows the owner to pause / unpause the market
      * @param  state  Whether the the market should be active (true) or paused (false)
      */
    function setMarketActiveState(bool state) public {
        require(msg.sender == owner);                           // Check if sender is owner
        marketActive = state;                                   // pause / unpause market
    }
    
    /** @notice Allows the owner to nominate the feeCollector address
      * @param  collector The address to nominate as feeCollector
      */
    function nominateFeeCollector(address collector) public {
        require(msg.sender == owner && !feeCollectorLocked);    // Check if sender is owner and feeCollector address is not locked
        feeCollector = collector;                               // Update feeCollector address
    }
    
    /** @notice Allows the owner to lock the feeCollector address
  */
    function lockFeeCollector() public {
        require(msg.sender == owner);                           // Check if sender is owner
        feeCollectorLocked = true;                              // Lock feeCollector address
    }
    
    /** @notice Get the feeCollectors address
      * @return The feeCollectors address
      */
    function getFeeCollector() public constant returns (address){
        return feeCollector;
    }

    /** @notice Allows the feeCollector to directly withdraw his funds (would allow a fee distribution contract to withdraw collected fees)
      * @param  token   The token to withdraw
      * @param  amount  The amount of tokens to withdraw
  */
    function feeWithdrawal(address token, uint256 amount) public {
        if (
            msg.sender == feeCollector                              // Check if the sender is the feeCollector
            && balances[token][feeCollector] >= amount              // Check if feeCollector has the sufficient balance
        ){
            balances[token][feeCollector] -= amount;                // Substract the feeCollectors balance
            if(token == address(0)){                                // Is the withdrawal token ETH
                require(
                    feeCollector.send(amount),                      // Withdraw ETH
                    "Sending of ETH failed."
                );
            }else{
                Token(token).transfer(feeCollector, amount);        // Withdraw ERC20
                require(                                            // Revert if the withdrawal failed
                    checkERC20TransferSuccess(),
                    "ERC20 token transfer failed."
                );
            }
            emit FeeWithdrawal(token,amount);                       // Emit FeeWithdrawal event
        }else{
            revert();                                               // Revert the transaction if the checks fail
        }
    }
    
    // We have to check returndatasize after ERC20 tokens transfers, as some tokens are implemented badly (dont return a boolean)
    function checkERC20TransferSuccess() pure private returns(bool){
        uint256 success = 0;

        assembly {
            switch returndatasize               // Check the number of bytes the token contract returned
                case 0 {                        // Nothing returned, but contract did not throw > assume our transfer succeeded
                    success := 1
                }
                case 32 {                       // 32 bytes returned, result is the returned bool
                    returndatacopy(0, 0, 32)
                    success := mload(0)
                }
        }

        return success != 0;
    }
}




// Standart ERC20 token interface to interact with ERC20 token contracts
// To support badly implemented tokens (which dont return a boolean on the transfer functions)
// we have to expect a badly implemented token and then check with checkERC20TransferSuccess() whether the transfer succeeded

contract Token {
    /** @return total amount of tokens
      */
    function totalSupply() constant public returns (uint256 supply) {}

    /** @param _owner The address from which the balance will be retrieved
      * @return The balance
      */
    function balanceOf(address _owner) constant public returns (uint256 balance) {}

    /** @notice send `_value` token to `_to` from `msg.sender`
      * @param  _to     The address of the recipient
      * @param  _value  The amount of tokens to be transferred
      * @return Whether the transfer was successful or not
      */
    function transfer(address _to, uint256 _value) public {}

    /** @notice send `_value` token to `_to` from `_from` on the condition it is approved by `_from`
      * @param  _from   The address of the sender
      * @param  _to     The address of the recipient
      * @param  _value  The amount of tokens to be transferred
      * @return Whether the transfer was successful or not
      */
    function transferFrom(address _from, address _to, uint256 _value)  public {}

    /** @notice `msg.sender` approves `_addr` to spend `_value` tokens
      * @param  _spender The address of the account able to transfer the tokens
      * @param  _value   The amount of wei to be approved for transfer
      * @return Whether the approval was successful or not
      */
    function approve(address _spender, uint256 _value) public returns (bool success) {}

    /** @param  _owner   The address of the account owning tokens
      * @param  _spender The address of the account able to transfer the tokens
      * @return Amount of remaining tokens allowed to spend
      */
    function allowance(address _owner, address _spender) constant public returns (uint256 remaining) {}

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);

    uint public decimals;
    string public name;
}