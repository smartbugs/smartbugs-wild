library TokenLib {
    struct Token {
        string identity;
        address owner;
    }

    function id(Token storage self) returns (bytes32) {
        return sha3(self.identity);
    }

    function generateId(string identity) returns (bytes32) {
        return sha3(identity);
    }

    event Transfer(address indexed _from, address indexed _to, bytes32 _value);
    event Approval(address indexed _owner, address indexed _spender, bytes32 _value);

    function logApproval(address _owner, address _spender, bytes32 _value) {
        Approval(_owner, _spender, _value);
    }

    function logTransfer(address _from, address _to, bytes32 _value) {
        Transfer(_from, _to, _value);
    }
}

contract TokenInterface {
    /*
     *  Events
     */
    event Mint(address indexed _to, bytes32 _id);
    event Destroy(bytes32 _id);
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
    event MinterAdded(address who);
    event MinterRemoved(address who);

    /*
     *  Minting
     */
    /// @dev Mints a new token.
    /// @param _to Address of token owner.
    /// @param _identity String for owner identity.
    function mint(address _to, string _identity) returns (bool success);

    /// @dev Destroy a token
    /// @param _id Bytes32 id of the token to destroy.
    function destroy(bytes32 _id) returns (bool success);

    /// @dev Add a new minter
    /// @param who Address the address that can now mint tokens.
    function addMinter(address who) returns (bool);

    /// @dev Remove a minter
    /// @param who Address the address that will no longer be a minter.
    function removeMinter(address who) returns (bool);

    /*
     *  Read and write storage functions
     */

    /// @dev Return the number of tokens
    function totalSupply() returns (uint supply);

    /// @dev Transfers sender token to given address. Returns success.
    /// @param _to Address of new token owner.
    /// @param _value Bytes32 id of the token to transfer.
    function transfer(address _to, uint256 _value) returns (bool success);
    function transfer(address _to, bytes32 _value) returns (bool success);

    /// @dev Allows allowed third party to transfer tokens from one address to another. Returns success.
    /// @param _from Address of token owner.
    /// @param _to Address of new token owner.
    /// @param _value Bytes32 id of the token to transfer.
    function transferFrom(address _from, address _to, uint256 _value) returns (bool success);
    function transferFrom(address _from, address _to, bytes32 _value) returns (bool success);

    /// @dev Sets approval spender to transfer ownership of token. Returns success.
    /// @param _spender Address of spender..
    /// @param _value Bytes32 id of token that can be spend.
    function approve(address _spender, uint256 _value) returns (bool success);
    function approve(address _spender, bytes32 _value) returns (bool success);

    /*
     * Read storage functions
     */
    /// @dev Returns id of token owned by given address (encoded as an integer).
    /// @param _owner Address of token owner.
    function balanceOf(address _owner) constant returns (uint256 balance);

    /// @dev Returns the token id that may transfer from _owner account by _spender..
    /// @param _owner Address of token owner.
    /// @param _spender Address of token spender.
    function allowance(address _owner, address _spender) constant returns (uint256 remaining);

    /*
     *  Extra non ERC20 functions
     */
    /// @dev Returns whether the address owns a token.
    /// @param _owner Address to check.
    function isTokenOwner(address _owner) constant returns (bool);

    /// @dev Returns the identity of the given token id.
    /// @param _id Bytes32 id of token to lookup.
    function identityOf(bytes32 _id) constant returns (string identity);

    /// @dev Returns the address of the owner of the given token id.
    /// @param _id Bytes32 id of token to lookup.
    function ownerOf(bytes32 _id) constant returns (address owner);
}

contract Devcon2Token is TokenInterface {
    using TokenLib for TokenLib.Token;

    /*
     *  +----------------+
     *  | Administrative |
     *  +----------------+
     */
    mapping (address => bool) public minters;
    uint constant _END_MINTING = 1474502400;  // UTC (2016/09/22 - 00:00:00)

    function END_MINTING() constant returns (uint) {
        return _END_MINTING;
    }

    function Devcon2Token() {
        minters[msg.sender] = true;
        MinterAdded(msg.sender);
    }

    /*
     *  +------------+
     *  | Token Data |
     *  +------------+
     */
    uint numTokens;

    // id => Token
    mapping (bytes32 => TokenLib.Token) tokens;

    // owner => ownedToken.id
    mapping (address => bytes32) public ownedToken;

    // owner => spender => ownedToken.id
    mapping (address => mapping (address => bytes32)) approvals;

    /*
     *  Read and write storage functions
     */
    /// @dev Mints a new token
    /// @param _to Address of token owner.
    /// @param _identity String for owner identity.
    function mint(address _to, string _identity) returns (bool success) {
        // only mintable till end of conference
        if (now >= _END_MINTING) throw;

        // ensure the msg.sender is allowed to mint.
        if (!minters[msg.sender]) return false;

        // ensure that the token owner doesn't already own a token.
        if (ownedToken[_to] != 0x0) return false;

        // generate the token id and get the token.
        bytes32 id = TokenLib.generateId(_identity);
        var token = tokens[id];

        // don't allow re-minting of a given identity.
        if (id == token.id()) return false;

        // set the token data
        token.owner = _to;
        token.identity = _identity;
        ownedToken[_to] = id;

        // log the minting of this token.
        Mint(_to, id);

        // increase the supply.
        numTokens += 1;

        return true;
    }

    /// @dev Destroy a token
    /// @param _id Bytes32 id of the token to be destroyed
    function destroy(bytes32 _id) returns (bool success) {
        // only mintable till end of conference
        if (now >= _END_MINTING) throw;

        // ensure the msg.sender is allowed to mint.
        if (!minters[msg.sender]) return false;

        // pull the token to destroy
        var tokenToDestroy = tokens[_id];

        // Remove any ownership data
        ownedToken[tokenToDestroy.owner] = 0x0;

        // Zero out the actual token data
        tokenToDestroy.identity = '';
        tokenToDestroy.owner = 0x0;

        // Log the destruction
        Destroy(_id);

        // decrease the supply.
        numTokens -= 1;
        
        return true;
    }

    /// @dev Add a new minter
    /// @param who Address the address that can now mint tokens.
    function addMinter(address who) returns (bool) {
        // only mintable till end of conference
        if (now >= _END_MINTING) throw;

        // ensure the msg.sender is allowed
        if (!minters[msg.sender]) return false;

        minters[who] = true;

        // Log it
        MinterAdded(who);

        return true;
    }

    /// @dev Remove a minter
    /// @param who Address the address that will no longer be a minter.
    function removeMinter(address who) returns (bool) {
        // ensure the msg.sender is allowed
        if (!minters[msg.sender]) return false;

        minters[who] = false;

        // Log it
        MinterRemoved(who);

        return true;
    }

    /// @dev Transfers sender token to given address. Returns success.
    /// @param _to Address of new token owner.
    /// @param _value Bytes32 id of the token to transfer.
    function transfer(address _to, uint256 _value) returns (bool success) {
        return transfer(_to, bytes32(_value));
    }

    function transfer(address _to, bytes32 _value) returns (bool success) {
        // dont allow the null token.
        if (_value == 0x0) return false;

        // ensure it is actually a token
        if (tokens[_value].id() != _value) return false;

        // ensure that the new owner doesn't already own a token.
        if (ownedToken[_to] != 0x0) return false;

        // get the token
        var tokenToTransfer = tokens[_value];

        // ensure msg.sender is the token owner.
        if (tokenToTransfer.owner != msg.sender) return false;

        // set the new owner.
        tokenToTransfer.owner = _to;
        ownedToken[msg.sender] = 0x0;
        ownedToken[_to] = _value;

        // log the transfer
        //Transfer(msg.sender, _to, uint(_value));
        TokenLib.logTransfer(msg.sender, _to, _value);

        return true;
    }

    /// @dev Allows allowed third party to transfer tokens from one address to another. Returns success.
    /// @param _from Address of token owner.
    /// @param _to Address of new token owner.
    /// @param _value Bytes32 id of the token to transfer.
    function transferFrom(address _from, address _to, uint256 _value) returns (bool success) {
        return transferFrom(_from, _to, bytes32(_value));
    }

    function transferFrom(address _from, address _to, bytes32 _value) returns (bool success) {
        // dont allow the null token.
        if (_value == 0x0) return false;

        // ensure it is actually a token
        if (tokens[_value].id() != _value) return false;

        // ensure that the new owner doesn't already own a token.
        if (ownedToken[_to] != 0x0) return false;

        // get the token
        var tokenToTransfer = tokens[_value];

        // ensure that _from actually owns this token.
        if (tokenToTransfer.owner != _from) return false;
        if (ownedToken[_from] != _value) return false;

        // ensure that they are approved to transfer this token.
        if (approvals[_from][msg.sender] != _value) return false;

        // do the transfer
        tokenToTransfer.owner = _to;
        ownedToken[_from] = 0x0;
        ownedToken[_to] = _value;
        approvals[_from][msg.sender] = 0x0;

        // log the transfer
        Transfer(_from, _to, uint(_value));
        TokenLib.logTransfer(_from, _to, _value);

        return true;
    }

    /// @dev Sets approval spender to transfer ownership of token. Returns success.
    /// @param _spender Address of spender..
    /// @param _value Bytes32 id of token that can be spend.
    function approve(address _spender, uint256 _value) returns (bool success) {
        return approve(_spender, bytes32(_value));
    }

    function approve(address _spender, bytes32 _value) returns (bool success) {
        // dont allow the null token.
        if (_value == 0x0) return false;

        // ensure it is actually a token
        if (tokens[_value].id() != _value) return false;

        // get the token that is being approved.
        var tokenToApprove = tokens[_value];

        // ensure they own this token.
        if (tokenToApprove.owner != msg.sender) return false;
        if (ownedToken[msg.sender] != _value) return false;

        // set the approval
        approvals[msg.sender][_spender] = _value;

        // Log the approval
        Approval(msg.sender, _spender, uint(_value));
        TokenLib.logApproval(msg.sender, _spender, _value);

        return true;
    }

    /*
     * Read storage functions
     */
    /// @dev Return the number of tokens
    function totalSupply() returns (uint supply) {
        return numTokens;
    }

    /// @dev Returns id of token owned by given address (encoded as an integer).
    /// @param _owner Address of token owner.
    function balanceOf(address _owner) constant returns (uint256 balance) {
        return uint(ownedToken[_owner]);
    }

    /// @dev Returns number of allowed tokens for given address.
    /// @param _owner Address of token owner.
    /// @param _spender Address of token spender.
    function allowance(address _owner, address _spender) constant returns (uint256 remaining) {
        return uint(approvals[_owner][_spender]);
    }

    /*
     *  Extra non ERC20 functions
     */
    /// @dev Returns whether the address owns a token.
    /// @param _owner Address to check.
    function isTokenOwner(address _owner) constant returns (bool) {
        return (ownedToken[_owner] != 0x0 && tokens[ownedToken[_owner]].owner == _owner);
    }

    /// @dev Returns the identity of the given token id.
    /// @param _id Bytes32 id of token to lookup.
    function identityOf(bytes32 _id) constant returns (string identity) {
        return tokens[_id].identity;
    }

    /// @dev Returns the address of the owner of the given token id.
    /// @param _id Bytes32 id of token to lookup.
    function ownerOf(bytes32 _id) constant returns (address owner) {
        return tokens[_id].owner;
    }
}