pragma solidity 0.5.1;

/// @title birthday.sol -- A birthday card for a special person.
/// @author Preston Van Loon <preston@prysmaticlabs.com>
contract BirthdayCard {
    event PassphraseOK(string passphrase);
    
    string public message;
    
    bytes32 hashed_passphrase;
    ERC20 constant dai = ERC20(0x89d24A6b4CcB1B6fAA2625fE562bDD9a23260359);
    
    /// @dev Initialize the contract
    /// @param _message to write inside of the birthday card
    /// @param _hashed_passphrase is the keccak256 hashed passphrase
    constructor(string memory _message, bytes32 _hashed_passphrase) public {
        message = _message;
        hashed_passphrase = _hashed_passphrase;
    }
    
    /// @dev Withdraw the DAI and selfdestruct this birthday card!
    /// Just like real life: take the money out and throw the card away!!
    /// @param passphrase is the secret to test.
    function withdraw(string memory passphrase) public {
        require(isPassphrase(passphrase));
        emit PassphraseOK(passphrase);
        
        assert(dai.transfer(msg.sender, dai.balanceOf(address(this))));
        selfdestruct(msg.sender);
    }

    /// @dev How much money is inside of this birthday card? 
    /// Divide the result of this by 10^18 to get the DAI dollar amount.
    function balanceOf() public view returns (uint) {
        return dai.balanceOf(address(this));
    }
    
    /// @dev Sanity check for the passphrase before sending the transaction.
    /// @param passphrase is the secret to test.
    function isPassphrase(string memory passphrase) public view returns (bool) {
        return keccak256(bytes(passphrase)) == hashed_passphrase;
    }
}


/// erc20.sol -- API for the ERC20 token standard

// See <https://github.com/ethereum/EIPs/issues/20>.
contract ERC20Events {
    event Approval(address indexed src, address indexed guy, uint wad);
    event Transfer(address indexed src, address indexed dst, uint wad);
}

contract ERC20 is ERC20Events {
    function totalSupply() public view returns (uint);
    function balanceOf(address guy) public view returns (uint);
    function allowance(address src, address guy) public view returns (uint);

    function approve(address guy, uint wad) public returns (bool);
    function transfer(address dst, uint wad) public returns (bool);
    function transferFrom(
        address src, address dst, uint wad
    ) public returns (bool);
}