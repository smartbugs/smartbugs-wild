pragma solidity ^0.4.9;


/***
 * VIP Token and Crowdfunding contracts.
 */


/**
 * @title ERC20
 */
contract ERC20 {
    function totalSupply() constant returns (uint256 totalSupply);
    function balanceOf(address _owner) constant returns (uint256 balance);
    function transfer(address _to, uint256 _value) returns (bool success);
    function transferFrom(address _from, address _to, uint256 _value) returns (bool success);
    function approve(address _spender, uint256 _value) returns (bool success);
    function allowance(address _owner, address _spender) constant returns (uint256 remaining);

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}

/**
 * @title LegendsCrowdfund
 */
contract LegendsCrowdfund {

    address public creator;
    address public exitAddress;

    uint public start;
    uint public limitVIP;

    LegendsToken public legendsToken;

    mapping (address => uint) public recipientETH;
    mapping (address => uint) public recipientVIP;

    uint public totalETH;
    uint public totalVIP;

    event VIPPurchase(address indexed sender, address indexed recipient, uint ETH, uint VIP);

    modifier saleActive() {
        if (address(legendsToken) == 0) {
            throw;
        }
        if (block.timestamp < start) {
            throw;
        }
        _;
    }

    modifier hasValue() {
        if (msg.value == 0) {
            throw;
        }
        _;
    }

    modifier recipientIsValid(address recipient) {
        if (recipient == 0 || recipient == address(this)) {
            throw;
        }
        _;
    }

    modifier isCreator() {
        if (msg.sender != creator) {
            throw;
        }
        _;
    }

    modifier tokenContractNotSet() {
        if (address(legendsToken) != 0) {
            throw;
        }
        _;
    }

    /**
     * @dev Constructor.
     * @param _exitAddress Address that all ETH should be forwarded to.
     * @param _start Timestamp of when the crowdsale will start.
     * @param _limitVIP Maximum amount of VIP that can be allocated in total. Denominated in wei.
     */
    function LegendsCrowdfund(address _exitAddress, uint _start, uint _limitVIP) {
        creator = msg.sender;
        exitAddress = _exitAddress;
        start = _start;
        limitVIP = _limitVIP;
    }

    /**
     * @dev Set the address of the token contract. Must be called by creator of this. Can only be set once.
     * @param _legendsToken Address of the token contract.
     */
    function setTokenContract(LegendsToken _legendsToken) external isCreator tokenContractNotSet {
        legendsToken = _legendsToken;
    }

    /**
     * @dev Forward Ether to the exit address. Store all ETH and VIP information in public state and logs.
     * @param recipient Address that tokens should be attributed to.
     */
    function purchaseMembership(address sender, address recipient) external payable saleActive hasValue recipientIsValid(recipient) {

        if (msg.sender != address(legendsToken)) {
            throw;
        }
        // Attempt to send the ETH to the exit address.
        if (!exitAddress.send(msg.value)) {
            throw;
        }

        // Update ETH amounts.
        recipientETH[recipient] += msg.value;
        totalETH += msg.value;

        // Calculate VIP amount.
        uint VIP = msg.value * 12;  // $1 / VIP based on $10 / ETH value.

        // Are we in the pre-sale?
        if (block.timestamp - start < 2 weeks) {
            VIP = (VIP * 10) / 9;   // 10% discount.
        }

        // Update VIP amounts.
        recipientVIP[recipient] += VIP;
        totalVIP += VIP;

        // Check we have not exceeded the maximum VIP.
        if (totalVIP > limitVIP) {
            throw;
        }

        // Tell the token contract about the increase.
        legendsToken.addTokens(recipient, VIP);

        // Log this purchase.
        VIPPurchase(sender, recipient, msg.value, VIP);
    }

}


/**
 * @title LegendsToken
 */
contract LegendsToken is ERC20 {
    string public name = 'VIP';             //The Token's name: e.g. DigixDAO Tokens
    uint8 public decimals = 18;             // 1Token ¨= 1$ (1ETH ¨= 10$)
    string public symbol = 'VIP';           //An identifier: e.g. REP
    string public version = 'VIP_0.1';

    mapping (address => uint) ownerVIP;
    mapping (address => mapping (address => uint)) allowed;
    uint public totalVIP;
    uint public start;

    address public legendsCrowdfund;

    bool public testing;

    modifier fromCrowdfund() {
        if (msg.sender != legendsCrowdfund) {
            throw;
        }
        _;
    }

    modifier isActive() {
        if (block.timestamp < start) {
            throw;
        }
        _;
    }

    modifier isNotActive() {
        if (!testing && block.timestamp >= start) {
            throw;
        }
        _;
    }

    modifier recipientIsValid(address recipient) {
        if (recipient == 0 || recipient == address(this)) {
            throw;
        }
        _;
    }

    modifier allowanceIsZero(address spender, uint value) {
        // To change the approve amount you first have to reduce the addresses´
        // allowance to zero by calling `approve(_spender,0)` if it is not
        // already 0 to mitigate the race condition described here:
        // https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
        if ((value != 0) && (allowed[msg.sender][spender] != 0)) {
            throw;
        }
        _;
    }

    /**
     * @dev Constructor.
     * @param _legendsCrowdfund Address of crowdfund contract.
     * @param _preallocation Address to receive the pre-allocation.
     * @param _start Timestamp when the token becomes active.
     */
    function LegendsToken(address _legendsCrowdfund, address _preallocation, uint _start, bool _testing) {
        legendsCrowdfund = _legendsCrowdfund;
        start = _start;
        testing = _testing;
        totalVIP = ownerVIP[_preallocation] = 25000 ether;
    }

    /**
     * @dev Add to token balance on address. Must be from crowdfund.
     * @param recipient Address to add tokens to.
     * @return VIP Amount of VIP to add.
     */
    function addTokens(address recipient, uint VIP) external isNotActive fromCrowdfund {
        ownerVIP[recipient] += VIP;
        totalVIP += VIP;
        Transfer(0x0, recipient, VIP);
    }

    /**
     * @dev Implements ERC20 totalSupply()
     */
    function totalSupply() constant returns (uint256 totalSupply) {
        totalSupply = totalVIP;
    }

    /**
     * @dev Implements ERC20 balanceOf()
     */
    function balanceOf(address _owner) constant returns (uint256 balance) {
        balance = ownerVIP[_owner];
    }

    /**
     * @dev Implements ERC20 transfer()
     */
    function transfer(address _to, uint256 _value) isActive recipientIsValid(_to) returns (bool success) {
        if (ownerVIP[msg.sender] >= _value) {
            ownerVIP[msg.sender] -= _value;
            ownerVIP[_to] += _value;
            Transfer(msg.sender, _to, _value);
            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Implements ERC20 transferFrom()
     */
    function transferFrom(address _from, address _to, uint256 _value) isActive recipientIsValid(_to) returns (bool success) {
        if (allowed[_from][msg.sender] >= _value && ownerVIP[_from] >= _value) {
            ownerVIP[_to] += _value;
            ownerVIP[_from] -= _value;
            allowed[_from][msg.sender] -= _value;
            Transfer(_from, _to, _value);
            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Implements ERC20 approve()
     */
    function approve(address _spender, uint256 _value) isActive allowanceIsZero(_spender, _value) returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }

    /**
     * @dev Implements ERC20 allowance()
     */
    function allowance(address _owner, address _spender) constant returns (uint256 remaining) {
        remaining = allowed[_owner][_spender];
    }

    /**
     * @dev Direct Buy
     */
    function () payable {
        LegendsCrowdfund(legendsCrowdfund).purchaseMembership.value(msg.value)(msg.sender, msg.sender);
    }

    /**
     * @dev Proxy Buy
     */
    function purchaseMembership(address recipient) payable {
        LegendsCrowdfund(legendsCrowdfund).purchaseMembership.value(msg.value)(msg.sender, recipient);
    }

}