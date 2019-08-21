pragma solidity ^0.4.25;

library Math {
    
    function Mul(uint a,uint b) internal pure returns (uint) {
        if(a==0) {
            return 0;
        }
        uint res = a*b;
        require(res/a == b,"Overflow in Multiply");
        return res;
    }   
    
    function Div(uint a,uint b) internal pure returns (uint) {
        require(b>0,"Division by zero");
        return (a/b);
    }   
    
    function Mod(uint a, uint b) internal pure returns (uint) {
        require(b>0,"Division by zero");
        return (a%b);
    }   
    
    function Add(uint a, uint b) internal pure returns (uint) {
        uint res = a+b;
        require(res>=a,"Overflow in Addition");
        return res;
    }   
    
    function Sub(uint a,uint b) internal pure returns (uint) {
        require(a>=b,"Subtraction results in negative number");
        return (a-b);
    }   
}

contract TEST_MultiSig {

    using Math for uint256;
    struct Transaction {
        address destination;
        uint256 value;
        bytes data;
        bool executed;
        uint256 expiration;
        uint256 receivedConfirmations;

    }

    event LogMultiSigContractCreated(
        uint256 numOwners,
        uint256 numAllowedDestinations,
        uint256 quorum,
        uint256 maxTxValiditySeconds
    );
    event LogDestinationStatus(address destination,bool status);
    event LogTransactionProposal(
        uint256 indexed txId,
        address destination,
        uint256 value,
        bytes data
    );
    event LogTransactionConfirmationRescission(
        uint256 indexed txId,
        address approver,
        uint256 currentlyReceivedConfirmations
    );
    event LogTransactionExecutionSuccess(uint256 indexed txId);
    event LogTransactionExecutionFailure(uint256 indexed txId);
    event LogTransactionConfirmation(
        uint256 indexed txId,
        address indexed approver,
        uint256 currentlyReceivedConfirmations
    );
    event LogDeposit(address depositer, uint256 depositedValue); 
   

    mapping (uint256 => Transaction) public transactions;
    mapping (uint256 => mapping (address => bool)) public confirmations;
    mapping (address => bool) public isOwner;
    mapping (address => bool) public destinationAddressStatus;
    address[] public owners;
    uint256 public requiredConfirmations;
    uint256 public transactionCount;
    uint256 public maxValidTimeSecs;
    uint256 constant MIN_OWNER_COUNT=3;
    uint256 constant MIN_REQD_COUNT=2;

    modifier onlyByThisAddress {
        require(msg.sender == address(this),"onlyByThisAddress");
        _;
    }

    modifier onlyByOwners {
        require(isOwner[msg.sender],"onlyByOwners");
        _;
    }

    modifier destinationStatusCheck(address _destination,bool _status) {
        require(
            destinationAddressStatus[_destination]==_status,
            "Failed destinationStatusCheck"
        );
        _;
    }

    modifier awaitingConfirmation(uint256 _tx_id) {
        //need only up to required approvals
        require(!isConfirmed(_tx_id),"Already confirmed");
        _;
    }

    modifier completedConfirmation(uint256 _tx_id) {
        //need exactly required approvals
        require(isConfirmed(_tx_id),"Not confirmed yet");
        _;
    }

    modifier confirmationStatusCheck(
        uint256 _tx_id,
        address _sender,
        bool _status
    ) 
    {
        require(
            confirmations[_tx_id][_sender]==_status,
            "Failed confirmationStatusCheck"
        );
        _;
    }

    modifier awaitingExecution(uint256 _tx_id) {
        require( 
            !isExecuted(_tx_id), 
            "Tx already executed"
        );
        _;
    }

    modifier awaitingExpiry(uint256 _tx_id) {
        require(
            !isExpired(_tx_id),
            "Tx has expired"
        );
        _;
    }


    modifier validRequirement(uint _ownercount,uint _required) {
        require(
            (_ownercount>=MIN_OWNER_COUNT) &&
            (_required >= MIN_REQD_COUNT)  &&
            (MIN_REQD_COUNT <= MIN_OWNER_COUNT),
            "Constructor requirements not met"
        );
        _;
    }

    modifier validExpiration(uint256 _expiration) {
        require(
            _expiration>=now,
            "time must be >= now"
        );
        require(
            (_expiration-now)<maxValidTimeSecs,
            "Expiration time is too far in the future" 
        );
        _;
    }


    /**
     * @dev constructor
     * @param _owners owners array
     * @param _required_confirmations number of required confirmations
     */
    constructor(
        address[] _owners,
        address[] _allowed_destinations, 
        uint256 _required_confirmations,
        uint256 _max_valid_time_secs
    ) 
        public
        validRequirement(_owners.length,_required_confirmations)
    {

        //for(uint256 i=0;i<_owners.length;i++) {
        for(uint256 i=0;i<_owners.length;i=i.Add(1)) {
            
            //requires an address
            require(_owners[i] != address(0));

            //cant be repeated address
            require(!isOwner[_owners[i]]);
            
            isOwner[_owners[i]]=true;
        }

        requiredConfirmations = _required_confirmations;
        maxValidTimeSecs = _max_valid_time_secs;
        owners = _owners;
        
        //to allow this contract to call its own admin functions
        destinationAddressStatus[address(this)] = true;

        //for(uint256 j=0;j<_allowed_destinations.length;/*j++*/j=j.Add(1)) {
        for(uint256 j=0;j<_allowed_destinations.length;j=j.Add(1)) {
            destinationAddressStatus[_allowed_destinations[j]]=true;
        }

        emit LogMultiSigContractCreated(
            _owners.length,
            _allowed_destinations.length.Add(1),
            _required_confirmations,
            _max_valid_time_secs
        );
    }

    function() public payable {
        if(msg.value>0)
            emit LogDeposit(msg.sender,msg.value);
    }

    /* =================================================================
     *  admin functions
     * =================================================================
     */

    /**
     * @notice Sets whether a destination address is allowed
     * @param _destination Destination address
     * @param _status true=allowed, false=not allowed
     */
    function setDestinationAddressStatus(
        address _destination,
        bool _status
    )
        public
        onlyByThisAddress
        destinationStatusCheck(_destination,!_status)
    {
        require(
            _destination!=address(this),
            "contract can never disable calling itself"
        );

        destinationAddressStatus[_destination] = _status;      
        emit LogDestinationStatus(_destination,_status);
    }

    /* =================================================================
     *  (propose,approve,revokeApproval,execute)Tx
     * =================================================================
     */

    /**
     * @notice Propose a transaction for multi-sig approval
     * @dev Proposal also counts as one confirmation
     * @param _destination Destination address
     * @param _value Wei, if payable function
     * @param _data Transaction data
     * @return {"tx_id":"Transaction id"}
     */
    function proposeTx(
        address _destination, 
        uint256 _value, 
        bytes _data,
        uint256 _expiration
    )
        public
        onlyByOwners
        destinationStatusCheck(_destination,true)
        validExpiration(_expiration)
        returns (uint256 tx_id)
    {
        tx_id = _createTx(_destination,_value,_data,_expiration);
        _confirmTx(tx_id);
    }

    /**
     * @notice Approver calls this to approve a transaction
     * @dev Transaction will be executed if <br/>
     * @dev ...1) quorum is reached <br/> 
     * @dev ...2) not expired, <br/> 
     * @dev ...3) valid transaction <br/>
     * @param _tx_id Transaction id
     */
    function approveTx(uint256 _tx_id)
        public
        onlyByOwners
        confirmationStatusCheck(_tx_id,msg.sender,false)
        awaitingConfirmation(_tx_id)
        awaitingExecution(_tx_id)
        awaitingExpiry(_tx_id)
    {
        _confirmTx(_tx_id);
    }
     
    /**
     * @notice Approver calls this to revoke an earlier approval
     * @param _tx_id the transaction id
     */
    function revokeApprovalTx(uint256 _tx_id)
        public
        onlyByOwners
        confirmationStatusCheck(_tx_id,msg.sender,true)
        awaitingExecution(_tx_id)
        awaitingExpiry(_tx_id)
    {
        _unconfirmTx(_tx_id);
    }

    /**
     * @notice Executes a multi-sig transaction
     * @param _tx_id the transaction id
     */
    function executeTx(uint256 _tx_id)
        public
        //onlyByOwners
        completedConfirmation(_tx_id)
        awaitingExecution(_tx_id)
        awaitingExpiry(_tx_id)
    {
        _executeTx(_tx_id);
    }

    /* =================================================================
     *  view functions
     * =================================================================
     */

    /**
     * @notice Returns the number of owners of this contract
     * @return {"":"the number of owners"}
     */
    function getNumberOfOwners() 
        external 
        view 
        returns (uint256) 
    {
        return owners.length;
    }

    /**
     * @notice Checks to see if transacton was executed
     * @param _tx_id Transaction id
     * @return {"":"true on Executed, false on Not Executed"}
     */
    function isExecuted(uint256 _tx_id) internal view returns(bool) {
        return transactions[_tx_id].executed;
    }

    /**
     * @notice Checks to see if transacton has expired
     * @param _tx_id Transaction id
     * @return {"":"true on Expired, false on Not Expired"}
     */
    function isExpired(uint256 _tx_id) internal view returns(bool) {
        return (now>transactions[_tx_id].expiration);
    }

    /**
     * @notice Checks to see if transacton has been confirmed
     * @param _tx_id Transaction id
     * @return {"":"true on Confirmed, false on Not Confirmed"}
     */
    function isConfirmed(uint256 _tx_id) internal view returns(bool) {
        return 
            transactions[_tx_id].receivedConfirmations==requiredConfirmations;
    }



    /* =================================================================
     *  internal functions
     * =================================================================
     */

    /**
     * @notice Creates a multi-sig transaction
     * @param _destination Destination address 
     * @param _value Amount of wei to pay if calling a payable fn
     * @param _data Transaction data
     */
    function _createTx(
        address _destination,
        uint256 _value,
        bytes _data,
        uint256 _expiration
    )
        internal
        returns (uint256 tx_id)
    {
        tx_id = transactionCount;
        transactionCount=transactionCount.Add(1);
        
        transactions[tx_id] = Transaction({
            destination: _destination,
            value: _value,
            data: _data,
            executed: false,
            expiration: _expiration,
            receivedConfirmations: 0
        });
        emit LogTransactionProposal(tx_id,_destination,_value,_data);
    }

    /**
     * @notice Confirms a multi-sig transaction
     * @param _tx_id Transaction id
     */
    function _confirmTx(uint256 _tx_id) 
        internal
    {
        confirmations[_tx_id][msg.sender]=true;
        
        transactions[_tx_id].receivedConfirmations=
                transactions[_tx_id].receivedConfirmations.Add(1);

        //try to execute
        _executeTx(_tx_id);

        emit LogTransactionConfirmation(
            _tx_id,
            msg.sender,
            transactions[_tx_id].receivedConfirmations
        );
    }

    /**
     * @notice Removes confirmation of a multi-sig transaction
     * @param _tx_id Transaction id
     */
    function _unconfirmTx(uint256 _tx_id) 
        internal
    {
        confirmations[_tx_id][msg.sender]=false;

        assert(transactions[_tx_id].receivedConfirmations!=0);
        
        transactions[_tx_id].receivedConfirmations = 
            transactions[_tx_id].receivedConfirmations.Sub(1);

        emit LogTransactionConfirmationRescission(
            _tx_id,
            msg.sender,
            transactions[_tx_id].receivedConfirmations
        );
    }

    /**
     * @notice Internal execute function invoking "call"
     * @dev this function cannot throw<br/>
     * @dev cannot use modifiers, check explicitly here<br/>
     * @dev ignoring the gas limits here<br/>
     * @param _tx_id Transaction id
     */
    function _executeTx(uint256 _tx_id)
        internal
    {
        if( 
            (!isExecuted(_tx_id)) && 
            (!isExpired(_tx_id)) && 
            (isConfirmed(_tx_id)) 
        )
        {

            transactions[_tx_id].executed = true;
            bool result = 
                (transactions[_tx_id].destination)
                .call
                .value(transactions[_tx_id].value)
                (transactions[_tx_id].data);

            transactions[_tx_id].executed = result;

            if(result) 
            {
                emit LogTransactionExecutionSuccess(_tx_id);
            }
            else 
            {
                emit LogTransactionExecutionFailure(_tx_id);
            }
        }
    }
}