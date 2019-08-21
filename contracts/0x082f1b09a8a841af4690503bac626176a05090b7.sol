pragma solidity ^0.4.23;

// File: contracts/Ownerable.sol

contract Ownerable {
    /// @notice The address of the owner is the only address that can call
    ///  a function with this modifier
    modifier onlyOwner { require(msg.sender == owner); _; }

    address public owner;

    constructor() public { owner = msg.sender;}

    /// @notice Changes the owner of the contract
    /// @param _newOwner The new owner of the contract
    function setOwner(address _newOwner) public onlyOwner {
        owner = _newOwner;
    }
}

// File: contracts/TokenController.sol

contract TokenController {
    /// @notice Called when `_owner` sends ether to the MiniMe Token contract
    /// @param _owner The address that sent the ether to create tokens
    /// @return True if the ether is accepted, false if it throws
    function proxyPayment(address _owner) public payable returns(bool);

    /// @notice Notifies the controller about a token transfer allowing the
    ///  controller to react if desired
    /// @param _from The origin of the transfer
    /// @param _to The destination of the transfer
    /// @param _amount The amount of the transfer
    /// @return False if the controller does not authorize the transfer
    function onTransfer(address _from, address _to, uint _amount) public returns(bool);

    /// @notice Notifies the controller about an approval allowing the
    ///  controller to react if desired
    /// @param _owner The address that calls `approve()`
    /// @param _spender The spender in the `approve()` call
    /// @param _amount The amount in the `approve()` call
    /// @return False if the controller does not authorize the approval
    function onApprove(address _owner, address _spender, uint _amount) public returns(bool);
}

// File: contracts/ATXICOToken.sol

contract ATXICOToken {
    function atxBuy(address _from, uint256 _amount) public returns(bool);
}

// File: contracts/ATX.sol

contract ATX {
    function blacklistAccount(address tokenOwner) public returns (bool);
    function unBlacklistAccount(address tokenOwner) public returns (bool);
    function enableTransfers(bool _transfersEnabled) public;
    function changeController(address _newController) public;
}

// File: contracts/ATXController.sol

contract ATXController is TokenController, Ownerable {

    address public atxContract;
    mapping (address => bool) public icoTokens;

    event Debug(address indexed _from, address indexed _to, uint256 indexed _amount, uint ord);

    constructor (address _atxContract) public {
        atxContract = _atxContract;
    }

    function addICOToken(address _icoToken) public onlyOwner {
        icoTokens[_icoToken] = true;
    }
    function delICOToken(address _icoToken) public onlyOwner {
        icoTokens[_icoToken] = false;
    }

    function proxyPayment(address _owner) public payable returns(bool) {
        return false;
    }

    function onTransfer(address _from, address _to, uint256 _amount) public returns(bool) {
        require(atxContract == msg.sender);
        require(_to != 0x0);

        // default
        bool result = true;

        if(icoTokens[_to] == true) {
            result = ATXICOToken(_to).atxBuy(_from, _amount);
        }
        return result;
    }

    function onApprove(address _owner, address _spender, uint _amount) public returns(bool) {
        return true;
    }

    //
    // for controlling ATX
    function blacklist(address tokenOwner) public onlyOwner returns (bool) {
        return ATX(atxContract).blacklistAccount(tokenOwner);
    }

    function unBlacklist(address tokenOwner) public onlyOwner returns (bool) {
        return ATX(atxContract).unBlacklistAccount(tokenOwner);
    }

    function enableTransfers(bool _transfersEnabled) public onlyOwner {
        ATX(atxContract).enableTransfers(_transfersEnabled);
    }

    function changeController(address _newController) public onlyOwner {
        ATX(atxContract).changeController(_newController);
    }

    function changeATXTokenAddr(address _newTokenAddr) public onlyOwner {
        atxContract = _newTokenAddr;
    }

    function ownerMethod() public onlyOwner returns(bool) {
      return true;
    }
}