// File: contracts/interfaces/ERC20.sol

pragma solidity ^0.5.9;


interface ERC20 {
    function transfer(address _to, uint _value) external returns (bool success);
    function transferFrom(address _from, address _to, uint256 _value) external returns (bool success);
    function allowance(address _owner, address _spender) external view returns (uint256 remaining);
    function approve(address _spender, uint256 _value) external returns (bool success);
    function increaseApproval (address _spender, uint _addedValue) external returns (bool success);
    function balanceOf(address _owner) external view returns (uint256 balance);
}

// File: contracts/interfaces/NanoLoanEngine.sol

pragma solidity ^0.5.9;


interface NanoLoanEngine {
    enum Status { initial, lent, paid, destroyed }
    function rcn() external returns (ERC20);
    function getTotalLoans() external view returns (uint256);
    function pay(uint index, uint256 _amount, address _from, bytes calldata oracleData) external returns (bool);
    function cosign(uint index, uint256 cost) external returns (bool);
    function getCreator(uint index) external view returns (address);
    function getDueTime(uint index) external view returns (uint256);
    function getDuesIn(uint index) external view returns (uint256);
    function getPendingAmount(uint index) external returns (uint256);
    function getStatus(uint index) external view returns (Status);
}

// File: contracts/commons/Ownable.sol

pragma solidity ^0.5.9;


contract Ownable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() internal {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(msg.sender == _owner, "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) external onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

// File: contracts/commons/Wallet.sol

pragma solidity ^0.5.9;



contract Wallet is Ownable {
    function execute(
        address payable _to,
        uint256 _value,
        bytes calldata _data
    ) external onlyOwner returns (bool, bytes memory) {
        return _to.call.value(_value)(_data);
    }
}

// File: contracts/commons/Pausable.sol

pragma solidity ^0.5.9;



contract Pausable is Ownable {
    bool public paused;

    event SetPaused(bool _paused);

    constructor() public {
        emit SetPaused(false);
    }

    modifier notPaused() {
        require(!paused, "Contract is paused");
        _;
    }

    function setPaused(bool _paused) external onlyOwner {
        paused = _paused;
        emit SetPaused(_paused);
    }
}

// File: contracts/interfaces/Cosigner.sol

pragma solidity ^0.5.9;



contract Cosigner {
    uint256 public constant VERSION = 2;

    /**
        @return the url of the endpoint that exposes the insurance offers.
    */
    function url() external view returns (string memory);

    /**
        @dev Retrieves the cost of a given insurance, this amount should be exact.

        @return the cost of the cosign, in RCN wei
    */
    function cost(address engine, uint256 index, bytes calldata data, bytes calldata oracleData) external view returns (uint256);

    /**
        @dev The engine calls this method for confirmation of the conditions, if the cosigner accepts the liability of
        the insurance it must call the method "cosign" of the engine. If the cosigner does not call that method, or
        does not return true to this method, the operation fails.

        @return true if the cosigner accepts the liability
    */
    function requestCosign(NanoLoanEngine engine, uint256 index, bytes calldata data, bytes calldata oracleData) external returns (bool);

    /**
        @dev Claims the benefit of the insurance if the loan is defaulted, this method should be only calleable by the
        current lender of the loan.

        @return true if the claim was done correctly.
    */
    function claim(NanoLoanEngine engine, uint256 index, bytes calldata oracleData) external returns (bool);
}

// File: contracts/RPCosigner.sol

pragma solidity ^0.5.9;








contract RPCosigner is Cosigner, Ownable, Wallet, Pausable {
    uint256 public deltaPayment = 15 days;
    NanoLoanEngine public engine;
    uint256 public legacyLimit;
    ERC20 public token;

    mapping(address => bool) public originators;
    mapping(uint256 => bool) public liability;

    event SetOriginator(address _originator, bool _enabled);
    event SetDeltaPayment(uint256 _prev, uint256 _val);
    event SetLegacyLimit(uint256 _prev, uint256 _val);
    event Cosigned(uint256 _id);
    event Paid(uint256 _id, uint256 _amount, uint256 _tokens);

    constructor(
        NanoLoanEngine _engine
    ) public {
        // Approve token spending
        ERC20 _token = _engine.rcn();
        _token.approve(address(_engine), uint(-1));
        // Save to storage
        token = _token;
        engine = _engine;
        // Emit initial events
        emit SetDeltaPayment(0, deltaPayment);
        emit SetLegacyLimit(0, legacyLimit);
    }

    function setOriginator(address _originator, bool _enabled) external onlyOwner {
        emit SetOriginator(_originator, _enabled);
        originators[_originator] = _enabled;
    }

    function setDeltaPayment(uint256 _delta) external onlyOwner {
        emit SetDeltaPayment(deltaPayment, _delta);
        deltaPayment = _delta;
    }

    function setLegacyLimit(uint256 _time) external onlyOwner {
        emit SetLegacyLimit(legacyLimit, _time);
        legacyLimit = _time;
    }

    function url() external view returns (string memory) {
        return "";
    }

    function cost(
        address,
        uint256,
        bytes calldata,
        bytes calldata
    ) external view returns (uint256) {
        return 0;
    }

    function requestCosign(
        NanoLoanEngine _engine,
        uint256 _index,
        bytes calldata,
        bytes calldata
    ) external notPaused returns (bool) {
        require(_engine == engine, "Invalid loan engine");
        require(originators[_engine.getCreator(_index)], "Invalid originator");
        require(!liability[_index], "Liability already exists");
        liability[_index] = true;
        require(_engine.cosign(_index, 0), "Cosign failed");
        emit Cosigned(_index);
        return true;
    }

    function claim(
        NanoLoanEngine _engine,
        uint256 _index,
        bytes calldata _oracleData
    ) external returns (bool) {
        require(_engine == engine, "Invalid loan engine");
        require(_engine.getStatus(_index) == NanoLoanEngine.Status.lent, "Invalid status");

        uint256 dueTime = _engine.getDueTime(_index);
        require(dueTime + deltaPayment < block.timestamp, "Loan is ongoing");

        if (!liability[_index]) {
            require(originators[_engine.getCreator(_index)], "Invalid originator");
            uint256 _legacyLimit = legacyLimit;
            require(_legacyLimit == 0 || (dueTime - _engine.getDuesIn(_index)) < _legacyLimit, "Loan outside legacy limits");
        }

        ERC20 _token = token;
        uint256 toPay = _engine.getPendingAmount(_index);
        uint256 prevBalance = _token.balanceOf(address(this));
        require(_engine.pay(_index, toPay, address(this), _oracleData), "Error paying loan");
        emit Paid(_index, toPay, prevBalance - _token.balanceOf(address(this)));
        return true;
    }
}