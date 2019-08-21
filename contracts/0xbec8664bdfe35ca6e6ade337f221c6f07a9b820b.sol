pragma solidity ^0.5.0;


/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev The Ownable constructor sets the original `owner` of the contract to the sender
     * account.
     */
    constructor () internal {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
    }

    /**
     * @return the address of the owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(isOwner());
        _;
    }

    /**
     * @return true if `msg.sender` is the owner of the contract.
     */
    function isOwner() public view returns (bool) {
        return msg.sender == _owner;
    }

    /**
     * @dev Allows the current owner to relinquish control of the contract.
     * @notice Renouncing to ownership will leave the contract without an owner.
     * It will not be possible to call the functions with the `onlyOwner`
     * modifier anymore.
     */
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Allows the current owner to transfer control of the contract to a newOwner.
     * @param newOwner The address to transfer ownership to.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers control of the contract to a newOwner.
     * @param newOwner The address to transfer ownership to.
     */
    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0));
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

interface DSFeed {
    function read()
    external
    view
    returns (bytes32);
}

contract OracleRegistry is Ownable {


    address payable private _networkWallet;
    address private _networkExecutor;

    // 0.005 ETH as Wei(.5%)
    uint256 public baseFee = uint256(0x0000000000000000000000000000000000000000000000000011c37937e08000);

    mapping(address => bool) public isWhitelisted;
    mapping(uint256 => address) public oracles;
    mapping(address => mapping(address => uint256)) public splitterToFee;


    event OracleActivated(address oracleFeed, uint256 currencyPair);
    event FeeChanged(address merchantModule, address asset, uint256 newFee);

    /// @dev Setup function sets initial storage of contract.
    /// @param _oracles List of whitelisted oracles.
    function setup(
        address[] memory _oracles,
        uint256[] memory _currencyPair,
        address payable[] memory _networkSettings
    )
    public
    onlyOwner
    {
        require(_oracles.length == _currencyPair.length);

        for (uint256 i = 0; i < _oracles.length; i++) {
            addToWhitelist(_oracles[i], _currencyPair[i]);
        }

        require(_networkSettings.length == 2, "OracleResigstry::setup INVALID_DATA: NETWORK_SETTINGS_LENGTH");

        require(_networkWallet == address(0), "OracleResigstry::setup INVALID_STATE: NETWORK_WALLET_SET");

        _networkWallet = _networkSettings[0];

        require(_networkExecutor == address(0), "OracleResigstry::setup INVALID_STATE: NETWORK_EXECUTOR_SET");

        _networkExecutor = _networkSettings[1];
    }

    function setFee(
        address[] memory merchantModule,
        address[] memory assetOfExchange,
        uint256[] memory newFee
    )
    public
    onlyOwner
    returns
    (bool) {

        for (uint256 i = 0; i < merchantModule.length; i++) {
            address merchant = merchantModule[i];
            address asset = assetOfExchange[i];
            uint256 assetFee = newFee[i];
            require(merchant != address(0), "OracleRegistry::setup INVALID_DATA: MERCHANT_MODULE_ADDR");
            require(asset != address(0), "OracleRegistry::setup INVALID_DATA: ASSET_ADDR");

            splitterToFee[merchant][asset] = assetFee;

            emit FeeChanged(merchant, asset, assetFee);
        }
    }

    function read(
        uint256 currencyPair
    ) public view returns (bytes32) {
        address orl = oracles[currencyPair];
        require(isWhitelisted[orl], "INVALID_DATA: CURRENCY_PAIR");
        return DSFeed(orl).read();
    }

    /// @dev Allows to add destination to whitelist. This can only be done via a Safe transaction.
    /// @param oracle Destination address.
    function addToWhitelist(address oracle, uint256 currencyPair)
    public
    onlyOwner
    {
        require(!isWhitelisted[oracle], "OracleResigstry::addToWhitelist INVALID_STATE: ORACLE_WHITELIST");
        require(oracle != address(0), "OracleResigstry::addToWhitelist INVALID_DATA: ORACLE_ADDRESS");
        require(currencyPair != uint256(0), "OracleResigstry::addToWhitelist INVALID_DATA: ORACLE_CURRENCY_PAIR");
        oracles[currencyPair] = oracle;
        isWhitelisted[oracle] = true;
        emit OracleActivated(oracle, currencyPair);
    }

    /// @dev Allows to remove destination from whitelist. This can only be done via a Safe transaction.
    /// @param oracle Destination address.
    function removeFromWhitelist(address oracle)
    public
    onlyOwner
    {
        require(isWhitelisted[oracle], "Address is not whitelisted");
        isWhitelisted[oracle] = false;
    }

    function getNetworkExecutor()
    public
    returns (address) {
        return _networkExecutor;
    }

    function getNetworkWallet()
    public
    returns (address payable) {
        return _networkWallet;
    }

    function getNetworkFee(address asset)
    public
    returns (uint256 fee) {
        fee = splitterToFee[msg.sender][asset];
        if (fee == uint256(0)) {
            fee = baseFee;
        }
    }

}