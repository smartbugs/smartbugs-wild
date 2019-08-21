pragma solidity ^0.4.16;


contract Token3CC {
    /* This creates an array with all balances */

    mapping (address => uint256) public balanceOf;

    /* This generates a public event on the blockchain that will notify clients */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /* Public variables of the token */
    string public name = "3CC";

    string public symbol = "3CC";

    uint8 public decimals = 8;

    uint256 public initialSupply = 2200000000 * (10 ** uint256(decimals));

    address public owner;

    /* Initializes contract with initial supply tokens to the creator of the contract */
    function Token3CC() public {
        owner = msg.sender;
        balanceOf[msg.sender] = initialSupply;
    }

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    function transferOwnership(address newOwner) public onlyOwner {
        owner = newOwner;
    }



    /* Internal transfer, only can be called by this contract */
    function _transfer(address _from, address _to, uint256 _value) internal {
        require(_to != 0x0);
        // Prevent transfer to 0x0 address. Use burn() instead
        require(balanceOf[_from] >= _value);
        // Check if the sender has enough
        require(balanceOf[_to] + _value >= balanceOf[_to]);
        // Check for overflows
        balanceOf[_from] -= _value;
        // Subtract from the sender
        balanceOf[_to] += _value;
        // Add the same to the recipient
        Transfer(_from, _to, _value);
    }

    /// @notice Send `_value` tokens to `_to` from your account
    /// @param _to The address of the recipient
    /// @param _value the amount to send
    function transfer(address _to, uint256 _value) public {
        _transfer(msg.sender, _to, _value);
    }

}