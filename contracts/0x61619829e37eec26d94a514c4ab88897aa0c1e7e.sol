pragma solidity 0.4.18;


/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a * b;
        assert(a == 0 || c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // assert(b > 0); // Solidity automatically throws when dividing by 0
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
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


contract TelcoinSaleCapEscrow {
    using SafeMath for uint256;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event WalletChanged(address indexed previousWallet, address indexed newWallet);
    event ValuePlaced(address indexed purchaser, address indexed beneficiary, uint256 amount);
    event Approved(address indexed participant, uint256 amount);
    event Rejected(address indexed participant);
    event Closed();

    /// The owner of the contract.
    address public owner;

    /// The wallet that will receive funds on approval after the token
    /// sale's  registerAltPurchase() has been called.
    address public wallet;

    /// Whether the escrow has closed.
    bool public closed = false;

    /// The amount of wei deposited by each participant. This value
    /// can change with new deposits, approvals and rejections.
    mapping(address => uint256) public deposited;

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    modifier escrowOpen() {
        require(!closed);
        _;
    }

    function TelcoinSaleCapEscrow(address _wallet) public payable {
        require(msg.value > 0);
        require(_wallet != address(0));

        owner = msg.sender;
        wallet = _wallet;

        wallet.transfer(msg.value);
    }

    function () public payable {
        placeValue(msg.sender);
    }

    /// By the time approve() is called by the owner, a matching call for
    /// registerAltPurchase(_participant, "ETH", tx.id, _weiAmount) shall
    /// have been called in the main token sale.
    function approve(address _participant, uint256 _weiAmount) onlyOwner public {
        uint256 depositedAmount = deposited[_participant];
        require(depositedAmount > 0);
        require(_weiAmount <= depositedAmount);

        deposited[_participant] = depositedAmount.sub(_weiAmount);
        Approved(_participant, _weiAmount);
        wallet.transfer(_weiAmount);
    }

    function approveMany(address[] _participants, uint256[] _weiAmounts) onlyOwner public {
        require(_participants.length == _weiAmounts.length);

        for (uint256 i = 0; i < _participants.length; i++) {
            approve(_participants[i], _weiAmounts[i]);
        }
    }

    function changeWallet(address _wallet) onlyOwner public payable {
        require(_wallet != 0x0);
        require(msg.value > 0);

        WalletChanged(wallet, _wallet);
        wallet = _wallet;
        wallet.transfer(msg.value);
    }

    function close() onlyOwner public {
        require(!closed);

        closed = true;
        Closed();
    }

    function placeValue(address _beneficiary) escrowOpen public payable {
        require(_beneficiary != address(0));

        uint256 weiAmount = msg.value;
        require(weiAmount > 0);

        uint256 newDeposited = deposited[_beneficiary].add(weiAmount);
        deposited[_beneficiary] = newDeposited;

        ValuePlaced(
            msg.sender,
            _beneficiary,
            weiAmount
        );
    }

    function reject(address _participant) onlyOwner public {
        uint256 weiAmount = deposited[_participant];
        require(weiAmount > 0);

        deposited[_participant] = 0;
        Rejected(_participant);
        require(_participant.call.value(weiAmount)());
    }

    function rejectMany(address[] _participants) onlyOwner public {
        for (uint256 i = 0; i < _participants.length; i++) {
            reject(_participants[i]);
        }
    }

    function transferOwnership(address _to) onlyOwner public {
        require(_to != address(0));
        OwnershipTransferred(owner, _to);
        owner = _to;
    }
}