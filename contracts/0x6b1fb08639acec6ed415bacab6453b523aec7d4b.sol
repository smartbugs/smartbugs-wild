pragma solidity ^0.4.18;

interface Crowdsale {
    function safeWithdrawal() public;
    function shiftSalePurchase() payable public returns(bool success);
}

interface Token {
    function transfer(address _to, uint256 _value) public;
}

contract ShiftSale {

    Crowdsale public crowdSale;
    Token public token;

    address public crowdSaleAddress;
    address[] public owners;
    mapping(address => bool) public isOwner;
    uint public fee;
    /*
     *  Constants
     */
    uint constant public MAX_OWNER_COUNT = 10;

    event FundTransfer(uint amount);
    event OwnerAddition(address indexed owner);
    event OwnerRemoval(address indexed owner);

    /// @dev Contract constructor sets initial Token, Crowdsale and the secret password to access the public methods.
    /// @param _crowdSale Address of the Crowdsale contract.
    /// @param _token Address of the Token contract.
    /// @param _owners An array containing the owner addresses.
    /// @param _fee The Shapeshift transaction fee to cover gas expenses.
    function ShiftSale(
        address _crowdSale,
        address _token,
        address[] _owners,
        uint _fee
    ) public {
        crowdSaleAddress = _crowdSale;
        crowdSale = Crowdsale(_crowdSale);
        token = Token(_token);
        for (uint i = 0; i < _owners.length; i++) {
            require(!isOwner[_owners[i]] && _owners[i] != 0);
            isOwner[_owners[i]] = true;
        }
        owners = _owners;
        fee = _fee;
    }

    modifier ownerDoesNotExist(address owner) {
        require(!isOwner[owner]);
        _;
    }
    modifier ownerExists(address owner) {
        require(isOwner[owner]);
        _;
    }
    modifier notNull(address _address) {
        require(_address != 0);
        _;
    }
    modifier validAmount() {
        require((msg.value - fee) > 0);
        _;
    }

    /**
     * Fallback function
     *
     * The function without name is the default function that is called whenever anyone sends funds to a contract
     */
    function()
    payable
    public
    validAmount
    {
        if(crowdSale.shiftSalePurchase.value(msg.value - fee)()){
            FundTransfer(msg.value - fee);
        }
    }

    /// @dev Returns list of owners.
    /// @return List of owner addresses.
    function getOwners()
    public
    constant
    returns (address[])
    {
        return owners;
    }
    /// @dev Allows to transfer MTC tokens. Can only be executed by an owner.
    /// @param _to Destination address.
    /// @param _value quantity of MTC tokens to transfer.
    function transfer(address _to, uint256 _value)
    ownerExists(msg.sender)
    public {
        token.transfer(_to, _value);
    }
    /// @dev Allows to withdraw the ETH from the CrowdSale contract. Transaction has to be sent by an owner.
    function withdrawal()
    ownerExists(msg.sender)
    public {
        crowdSale.safeWithdrawal();
    }
    /// @dev Allows to refund the ETH to destination address. Transaction has to be sent by an owner.
    /// @param _to Destination address.
    /// @param _value Wei to transfer.
    function refund(address _to, uint256 _value)
    ownerExists(msg.sender)
    public {
        _to.transfer(_value);
    }
    /// @dev Allows to refund the ETH to destination addresses. Transaction has to be sent by an owner.
    /// @param _to Array of destination addresses.
    /// @param _value Array of Wei to transfer.
    function refundMany(address[] _to, uint256[] _value)
    ownerExists(msg.sender)
    public {
        require(_to.length == _value.length);
        for (uint i = 0; i < _to.length; i++) {
            _to[i].transfer(_value[i]);
        }
    }
    /// @dev Allows to change the fee value. Transaction has to be sent by an owner.
    /// @param _fee New value for the fee.
    function setFee(uint _fee)
    ownerExists(msg.sender)
    public {
        fee = _fee;
    }

    /// @dev Withdraw all the eth on the contract. Transaction has to be sent by an owner.
    function empty()
    ownerExists(msg.sender)
    public {
        msg.sender.transfer(this.balance);
    }

}