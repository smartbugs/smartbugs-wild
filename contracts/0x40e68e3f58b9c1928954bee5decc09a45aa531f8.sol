pragma solidity 0.4.24;
pragma experimental "v0.5.0";

contract Administration {

    using SafeMath for uint256;

    address public owner;
    address public admin;

    event AdminSet(address _admin);
    event OwnershipTransferred(address _previousOwner, address _newOwner);


    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    modifier onlyAdmin() {
        require(msg.sender == owner || msg.sender == admin);
        _;
    }

    modifier nonZeroAddress(address _addr) {
        require(_addr != address(0), "must be non zero address");
        _;
    }

    constructor() public {
        owner = msg.sender;
        admin = msg.sender;
    }

    function setAdmin(
        address _newAdmin
    )
        public
        onlyOwner
        nonZeroAddress(_newAdmin)
        returns (bool)
    {
        require(_newAdmin != admin);
        admin = _newAdmin;
        emit AdminSet(_newAdmin);
        return true;
    }

    function transferOwnership(
        address _newOwner
    )
        public
        onlyOwner
        nonZeroAddress(_newOwner)
        returns (bool)
    {
        owner = _newOwner;
        emit OwnershipTransferred(msg.sender, _newOwner);
        return true;
    }

}

library SafeMath {

  // We use `pure` bbecause it promises that the value for the function depends ONLY
  // on the function arguments
    function mul(uint256 a, uint256 b) internal pure  returns (uint256) {
        uint256 c = a * b;
        require(a == 0 || c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a / b;
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a);
        return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a);
        return c;
    }
}

interface RTCoinInterface {
    

    /** Functions - ERC20 */
    function transfer(address _recipient, uint256 _amount) external returns (bool);

    function transferFrom(address _owner, address _recipient, uint256 _amount) external returns (bool);

    function approve(address _spender, uint256 _amount) external returns (bool approved);

    /** Getters - ERC20 */
    function totalSupply() external view returns (uint256);

    function balanceOf(address _holder) external view returns (uint256);

    function allowance(address _owner, address _spender) external view returns (uint256);

    /** Getters - Custom */
    function mint(address _recipient, uint256 _amount) external returns (bool);

    function stakeContractAddress() external view returns (address);

    function mergedMinerValidatorAddress() external view returns (address);
    
    /** Functions - Custom */
    function freezeTransfers() external returns (bool);

    function thawTransfers() external returns (bool);
}

/*
    ERC20 Standard Token interface
*/
interface ERC20Interface {
    function owner() external view returns (address);
    function decimals() external view returns (uint8);
    function transfer(address _to, uint256 _value) external returns (bool);
    function transferFrom(address _from, address _to, uint256 _value) external returns (bool);
    function approve(address _spender, uint256 _amount) external returns (bool);
    function totalSupply() external view returns (uint256);
    function balanceOf(address _owner) external view returns (uint256);
    function allowance(address _owner, address _spender) external view returns (uint256);
}

/// @title RTCETH allows the sale of RTC for ETH with an updatable ETH price
/// @author Postables, RTrade Technologies Ltd
/// @dev We able V5 for safety features, see https://solidity.readthedocs.io/en/v0.4.24/security-considerations.html#take-warnings-seriously
contract RTCETH is Administration {
    using SafeMath for uint256;

    // we mark as constant private to save gas
    address constant private TOKENADDRESS = 0xecc043b92834c1ebDE65F2181B59597a6588D616;
    RTCoinInterface constant public RTI = RTCoinInterface(TOKENADDRESS);
    string constant public VERSION = "production";

    address public hotWallet;
    uint256 public ethUSD;
    uint256 public weiPerRtc;
    bool   public locked;

    event EthUsdPriceUpdated(uint256 _ethUSD);
    event EthPerRtcUpdated(uint256 _ethPerRtc);
    event RtcPurchased(uint256 _rtcPurchased);
    event ForeignTokenTransfer(address indexed _sender, address indexed _recipient, uint256 _amount);

    modifier notLocked() {
        require(!locked, "sale must not be locked");
        _;
    }

    modifier isLocked() {
        require(locked, "sale must be locked");
        _;
    }

    function lockSales()
        public
        onlyAdmin
        notLocked
        returns (bool)
    {
        locked = true;
        return true;
    }

    function unlockSales()
        public
        onlyAdmin
        isLocked
        returns (bool)
    {
        locked = false;
        return true;
    }

    constructor() public {
        // prevent deployment if the token address isnt set
        require(TOKENADDRESS != address(0), "token address cant be unset");
        locked = true;
    }

    function () external payable {
        require(msg.data.length == 0, "data length must be 0");
        require(buyRtc(), "buying rtc failed");
    }

    function updateEthPrice(
        uint256 _ethUSD)
        public
        onlyAdmin
        returns (bool)
    {
        ethUSD = _ethUSD;
        uint256 oneEth = 1 ether;
        // here we calculate how many ETH 1 USD is worth
        uint256 oneUsdOfEth = oneEth.div(ethUSD);
        // for the duration of this contract, RTC will be at a fixed price of 0.125USD, which divides into 1 8 times
        weiPerRtc = oneUsdOfEth.div(8);
        emit EthUsdPriceUpdated(ethUSD);
        emit EthPerRtcUpdated(weiPerRtc);
        return true;
    }

    function setHotWallet(
        address _hotWalletAddress)
        public
        onlyOwner
        isLocked
        returns (bool)
    {
        hotWallet = _hotWalletAddress;
        return true;
    }

    function withdrawRemainingRtc()
        public
        onlyOwner
        isLocked
        returns (bool)
    {
        require(RTI.transfer(msg.sender, RTI.balanceOf(address(this))), "transfer failed");
        return true;
    }

    function buyRtc()
        public
        payable
        notLocked
        returns (bool)
    {
        require(hotWallet != address(0), "hot wallet cant be unset");
        require(msg.value > 0, "msg value must be greater than zero");
        uint256 rtcPurchased = (msg.value.mul(1 ether)).div(weiPerRtc);
        hotWallet.transfer(msg.value);
        require(RTI.transfer(msg.sender, rtcPurchased), "transfer failed");
        emit RtcPurchased(rtcPurchased);
        return true;
    }

    /** @notice Allow us to transfer tokens that someone might've accidentally sent to this contract
        @param _tokenAddress this is the address of the token contract
        @param _recipient This is the address of the person receiving the tokens
        @param _amount This is the amount of tokens to send
     */
    function transferForeignToken(
        address _tokenAddress,
        address _recipient,
        uint256 _amount)
        public
        onlyAdmin
        returns (bool)
    {
        require(_recipient != address(0), "recipient address can't be empty");
        // don't allow us to transfer RTC tokens stored in this contract
        require(_tokenAddress != TOKENADDRESS, "token can't be RTC");
        ERC20Interface eI = ERC20Interface(_tokenAddress);
        require(eI.transfer(_recipient, _amount), "token transfer failed");
        emit ForeignTokenTransfer(msg.sender, _recipient, _amount);
        return true;
    }
}