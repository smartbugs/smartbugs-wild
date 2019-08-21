pragma solidity ^0.4.16;

/// @title SafeMath
/// @dev Math operations with safety checks that throw on error
library SafeMath {
    function mul(uint256 a, uint256 b) internal constant returns (uint256) {
        uint256 c = a * b;
        assert(a == 0 || c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) internal constant returns (uint256) {
        uint256 c = a / b;
        return c;
    }

    function sub(uint256 a, uint256 b) internal constant returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    function add(uint256 a, uint256 b) internal constant returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }
}

contract IOwned {
    function owner() public constant returns (address) { owner; }
}

contract Owned is IOwned {
    address public owner;

    function Owned() {
        owner = msg.sender;
    }
    modifier onlyOwner {
        assert(msg.sender == owner);
        _;
    }
}

/// @title B2BK (B2BX) contract interface
contract IB2BKToken {
    function totalSupply() public constant returns (uint256) { totalSupply; }
    function balanceOf(address _owner) public constant returns (uint256 balance) { _owner; balance; }

    function transfer(address _to, uint256 _value) public returns (bool success);

    event Buy(address indexed _from, address indexed _to, uint256 _rate, uint256 _value);
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event FundTransfer(address indexed backer, uint amount, bool isContribution);
    event UpdateRate(uint256 _rate);
    event Finalize(address indexed _from, uint256 _value);
    event Burn(address indexed _from, uint256 _value);
}

/// @title B2BK (B2BX) contract - integration code for KICKICO.
contract B2BKToken is IB2BKToken, Owned {
    using SafeMath for uint256;
 
    string public constant name = "B2BX KICKICO";
    string public constant symbol = "B2BK";
    uint8 public constant decimals = 18;

    uint256 public totalSupply = 0;
    // Total number of tokens available for BUY.
    uint256 public constant totalMaxBuy = 5000000 ether;

    // The total number of ETH.
    uint256 public totalETH = 0;

    address public wallet;
    uint256 public rate = 0;

    // The flag indicates is in transfers state.
    bool public transfers = false;
    // The flag indicates is in BUY state.
    bool public finalized = false;

    mapping (address => uint256) public balanceOf;

    /// @notice B2BK Project - Initializing.
    /// @dev Constructor.
    function B2BKToken(address _wallet, uint256 _rate) validAddress(_wallet) {
        wallet = _wallet;
        rate = _rate;
    }

    modifier validAddress(address _address) {
        assert(_address != 0x0);
        _;
    }

    modifier transfersAllowed {
        require(transfers);
        _;
    }

    modifier isFinalized {
        require(finalized);
        _;
    }

    modifier isNotFinalized {
        require(!finalized);
        _;
    }

    /// @notice This function is disabled. Addresses having B2BK tokens automatically receive an equal number of B2BX tokens.
    function transfer(address _to, uint256 _value) public transfersAllowed returns (bool success) {
        return false;
    }

    /// @notice This function if anybody sends ETH directly to this contract, consider he is getting B2BK.
    function () payable {
        buy(msg.sender);
    }

    /// @notice This function sends B2BK tokens to the specified address when sending ETH
    /// @param _to Address of the recipient
    function buy(address _to) public validAddress(_to) isNotFinalized payable {
        uint256 _amount = msg.value;

        assert(_amount > 0);

        uint256 _tokens = _amount.mul(rate);

        assert(totalSupply.add(_tokens) <= totalMaxBuy);

        totalSupply = totalSupply.add(_tokens);
        totalETH = totalETH.add(_amount);

        balanceOf[_to] = balanceOf[_to].add(_tokens);

        wallet.transfer(_amount);

        Buy(msg.sender, _to, rate, _tokens);
        Transfer(this, _to, _tokens);
        FundTransfer(msg.sender, _amount, true);
    }

    /// @notice This function updates rates.
    function updateRate(uint256 _rate) external isNotFinalized onlyOwner {
        rate = _rate;

        UpdateRate(rate);
    }

    /// @notice This function completes BUY tokens.
    function finalize() external isNotFinalized onlyOwner {
        finalized = true;

        Finalize(msg.sender, totalSupply);
    }

    /// @notice This function burns all B2BK tokens on the address that caused this function.
    function burn() external isFinalized {
        uint256 _balance = balanceOf[msg.sender];

        assert(_balance > 0);

        totalSupply = totalSupply.sub(_balance);
        balanceOf[msg.sender] = 0;

        Burn(msg.sender, _balance);
    }
}