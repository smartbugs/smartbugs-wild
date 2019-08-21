pragma solidity ^0.4.23;

contract Htlc {

    // ENUMS

    enum State { Created, Refunded, Redeemed }

    // TYPES

    struct Channel { // Locks ETH in a channel by secret (redeemChannel) or time (refundChannels).
        address initiator; // Initiated this channel.
        address beneficiary; // Beneficiary of this channel.
        uint amount; // If zero then channel not active anymore.
        uint commission; // Commission amount to be paid to multisig authority.
        uint createdAt; // Channel creation timestamp in seconds.
        uint expiresAt; // Channel expiration timestamp in seconds.
        bytes32 hashedSecret; // sha256(secret), hashed secret of channel initiator.
        State state; // The state in which this channel is in.
    }

    // FIELDS

    uint constant MAX_BATCH_ITERATIONS = 20; // Assuming 8mn gaslimit and >0.4mn gas usage for most expensive batch function
    mapping (bytes32 => Channel) public channels; // Mapping of channel hashes to channel structs.
    mapping (bytes32 => bool) public isAntecedentHashedSecret; // Mapping of secrets to whether they have been used already or not.
    address public EXCHANGE_OPERATOR; // Can change the COMMISSION_RECIPIENT address.
    bool public IS_EXCHANGE_OPERATIONAL; // Can change the COMMISSION_RECIPIENT address.
    address public COMMISSION_RECIPIENT; // Recipient of exchange commissions.

    // EVENTS

    event ChannelCreated(bytes32 channelId);
    event ChannelRedeemed(bytes32 channelId);
    event ChannelRefunded(bytes32 channelId);

    // MODIFIER

    modifier only_exchange_operator {
        require(msg.sender == EXCHANGE_OPERATOR, "PERMISSION_DENIED");
        _;
    }

    // METHODS

    // PRIVATE METHODS

    /**
    @notice Sets up a Channel to initiate or participate in.
    @dev Whether right amount has been sent is handled at higher level functions.
    */
    function _setupChannel(address beneficiary, uint amount, uint commission, uint expiresAt, bytes32 hashedSecret)
        private
        returns (bytes32 channelId)
    {
        require(IS_EXCHANGE_OPERATIONAL, "EXCHANGE_NOT_OPERATIONAL");
        require(now <= expiresAt, "TIMELOCK_TOO_EARLY");
        require(amount > 0, "AMOUNT_IS_ZERO");
        require(!isAntecedentHashedSecret[hashedSecret], "SECRET_CAN_BE_DISCOVERED");
        isAntecedentHashedSecret[hashedSecret] = true;
        // Create channel identifier
        channelId = createChannelId(
            msg.sender,
            beneficiary,
            amount,
            commission,
            now,
            expiresAt,
            hashedSecret
        );
        // Create channel
        Channel storage channel = channels[channelId];
        channel.initiator = msg.sender;
        channel.beneficiary = beneficiary;
        channel.amount = amount;
        channel.commission = commission;
        channel.createdAt = now;
        channel.expiresAt = expiresAt;
        channel.hashedSecret = hashedSecret;
        channel.state = State.Created;
        // Transfer commission to commission recipient
        COMMISSION_RECIPIENT.transfer(commission);
        emit ChannelCreated(channelId);
    }

    // PUBLIC METHODS

    /**
    @notice Constructor function.
    */
    function Htlc(
        address ofExchangeOperator,
        address ofCommissionRecipient
    )
        public
    {
        EXCHANGE_OPERATOR = ofExchangeOperator;
        IS_EXCHANGE_OPERATIONAL = true;
        COMMISSION_RECIPIENT = ofCommissionRecipient;
    }

    /**
    @notice Changes the exchange operator.
    */
    function changeExchangeOperator(address newExchangeOperator)
        public
        only_exchange_operator
    {
        EXCHANGE_OPERATOR = newExchangeOperator;
    }

    /**
    @notice Changes the operational status of the exchange.
    */
    function changeExchangeStatus(bool newExchangeState)
        public
        only_exchange_operator
    {
        IS_EXCHANGE_OPERATIONAL = newExchangeState;
    }

    /**
    @notice Changes the recipient of the commission.
    */
    function changeCommissionRecipient(address newCommissionRecipient)
        public
        only_exchange_operator
    {
        COMMISSION_RECIPIENT = newCommissionRecipient;
    }

    /**
    @notice Hashes the channel specific values to create a unique identifier.
    @dev Helper function to create channelIds
    */
    function createChannelId(
        address initiator,
        address beneficiary,
        uint amount,
        uint commission,
        uint createdAt,
        uint expiresAt,
        bytes32 hashedSecret
    )
        public
        pure
        returns (bytes32 channelId)
    {
        channelId = keccak256(abi.encodePacked(
            initiator,
            beneficiary,
            amount,
            commission,
            createdAt,
            expiresAt,
            hashedSecret
        ));
    }

    /**
    @notice Creates a Channel to initiate or participate in.
    @dev If too little commission sent, channel wont be displayed in exchange frontend.
    @dev Does check if right amount (msg.value) has been sent.
    @param beneficiary Beneficiary of this channels amount.
    @param amount Amount to be stored in this channel.
    @param commission Commission amount to be paid to commission recipient.
    @param expiresAt Channel expiration timestamp in seconds.
    @param hashedSecret sha256(secret), hashed secret of channel initiator
    @return channelId Unique channel identifier
    */
    function createChannel(
        address beneficiary,
        uint amount,
        uint commission,
        uint expiresAt,
        bytes32 hashedSecret
    )
        public
        payable
        returns (bytes32 channelId)
    {
        // Require accurate msg.value sent
        require(amount + commission >= amount, "UINT256_OVERFLOW");
        require(msg.value == amount + commission, "INACCURATE_MSG_VALUE_SENT");
        // Setup channel
        _setupChannel(
            beneficiary,
            amount,
            commission,
            expiresAt,
            hashedSecret
        );
    }

    /**
    @notice Creates a batch of channels
    */
    function batchCreateChannel(
        address[] beneficiaries,
        uint[] amounts,
        uint[] commissions,
        uint[] expiresAts,
        bytes32[] hashedSecrets
    )
        public
        payable
        returns (bytes32[] channelId)
    {
        require(beneficiaries.length <= MAX_BATCH_ITERATIONS, "TOO_MANY_CHANNELS");
        // Require accurate msg.value sent
        uint valueToBeSent;
        for (uint i = 0; i < beneficiaries.length; ++i) {
            require(amounts[i] + commissions[i] >= amounts[i], "UINT256_OVERFLOW");
            require(valueToBeSent + amounts[i] + commissions[i] >= valueToBeSent, "UINT256_OVERFLOW");
            valueToBeSent += amounts[i] + commissions[i];
        }
        require(msg.value == valueToBeSent, "INACCURATE_MSG_VALUE_SENT");
        // Setup channel
        for (i = 0; i < beneficiaries.length; ++i)
            _setupChannel(
                beneficiaries[i],
                amounts[i],
                commissions[i],
                expiresAts[i],
                hashedSecrets[i]
            );
    }

    /**
    @notice Redeem ETH to channel beneficiary and and set channel state as redeemed.
    */
    function redeemChannel(bytes32 channelId, bytes32 secret)
        public
    {
        // Require secret to open channels hashlock
        require(sha256(abi.encodePacked(secret)) == channels[channelId].hashedSecret, "WRONG_SECRET");
        require(channels[channelId].state == State.Created, "WRONG_STATE");
        uint amount = channels[channelId].amount;
        address beneficiary = channels[channelId].beneficiary;
        channels[channelId].state = State.Redeemed;
        // Execute channel
        beneficiary.transfer(amount);
        emit ChannelRedeemed(channelId);
    }

    /**
    @notice Redeems a batch of channels.
    */
    function batchRedeemChannel(bytes32[] channelIds, bytes32[] secrets)
        public
    {
        require(channelIds.length <= MAX_BATCH_ITERATIONS, "TOO_MANY_CHANNELS");
        for (uint i = 0; i < channelIds.length; ++i)
            redeemChannel(channelIds[i], secrets[i]);
    }

    /**
    @notice Refund ETH to the channel initiator and set channel state as refuned.
    */
    function refundChannel(bytes32 channelId)
        public
    {
        // Require enough time has passed to open channels timelock.
        require(now >= channels[channelId].expiresAt, "TOO_EARLY");
        require(channels[channelId].state == State.Created, "WRONG_STATE");
        uint amount = channels[channelId].amount;
        address initiator = channels[channelId].initiator;
        channels[channelId].state = State.Refunded;
        // Refund channel
        initiator.transfer(amount);
        emit ChannelRefunded(channelId);
    }

    /**
    @notice Refunds a batch of channels.
    */
    function batchRefundChannel(bytes32[] channelIds)
        public
    {
        require(channelIds.length <= MAX_BATCH_ITERATIONS, "TOO_MANY_CHANNELS");
        for (uint i = 0; i < channelIds.length; ++i)
            refundChannel(channelIds[i]);
    }
}