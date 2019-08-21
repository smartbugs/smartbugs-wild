// The contract that allows DTH that held DAO at a contract address to
// authorize an enduser-account to do the withdrawal for them
//
// License: BSD3

contract Owned {
    /// Prevents methods from perfoming any value transfer
    modifier noEther() {if (msg.value > 0) throw; _}
    /// Allows only the owner to call a function
    modifier onlyOwner { if (msg.sender != owner) throw; _ }

    address owner;

    function Owned() { owner = msg.sender;}



    function changeOwner(address _newOwner) onlyOwner {
        owner = _newOwner;
    }

    function getOwner() noEther constant returns (address) {
        return owner;
    }
}

contract WHAuthorizeAddress is Owned {

    bool isClosed;

    mapping (address => bool) usedAddresses;

    event Authorize(address indexed dthContract, address indexed authorizedAddress);

    function WHAuthorizeAddress () {
        isClosed = false;
    }

    /// @notice Authorizes a regular account to act on behalf of a contract
    /// @param _authorizedAddress The address of the regular account that will
    ///                           act on behalf of the msg.sender contract.
    function authorizeAddress(address _authorizedAddress) noEther() {

        // after the contract is closed no more authorizations can happen
        if (isClosed) {
            throw;
        }

        // sender must be a contract and _authorizedAddress must be a user account
        if (getCodeSize(msg.sender) == 0 || getCodeSize(_authorizedAddress) > 0) {
            throw;
        }

        // An authorized address can be used to represent only a single contract.
        if (usedAddresses[_authorizedAddress]) {
            throw;
        }
        usedAddresses[_authorizedAddress] = true;

        Authorize(msg.sender, _authorizedAddress);
    }

    function() {
        throw;
    }

    function getCodeSize(address _addr) constant internal returns(uint _size) {
        assembly {
            _size := extcodesize(_addr)
        }
    }

    /// @notice Close the contract. After closing no more authorizations can happen
    function close() noEther onlyOwner {
        isClosed = true;
    }

    function getIsClosed() noEther constant returns (bool) {
        return isClosed;
    }
}