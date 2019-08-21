pragma solidity ^0.4.24;

// File: solidity-shared-lib/contracts/ERC20Interface.sol

/**
* Copyright 2017–2018, LaborX PTY
* Licensed under the AGPL Version 3 license.
*/

pragma solidity ^0.4.23;


/// @title Defines an interface for EIP20 token smart contract
contract ERC20Interface {
    
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed from, address indexed spender, uint256 value);

    string public symbol;

    function decimals() public view returns (uint8);
    function totalSupply() public view returns (uint256 supply);

    function balanceOf(address _owner) public view returns (uint256 balance);
    function transfer(address _to, uint256 _value) public returns (bool success);
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);
    function approve(address _spender, uint256 _value) public returns (bool success);
    function allowance(address _owner, address _spender) public view returns (uint256 remaining);
}

// File: solidity-shared-lib/contracts/Owned.sol

/**
* Copyright 2017–2018, LaborX PTY
* Licensed under the AGPL Version 3 license.
*/

pragma solidity ^0.4.23;



/// @title Owned contract with safe ownership pass.
///
/// Note: all the non constant functions return false instead of throwing in case if state change
/// didn't happen yet.
contract Owned {

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    address public contractOwner;
    address public pendingContractOwner;

    modifier onlyContractOwner {
        if (msg.sender == contractOwner) {
            _;
        }
    }

    constructor()
    public
    {
        contractOwner = msg.sender;
    }

    /// @notice Prepares ownership pass.
    /// Can only be called by current owner.
    /// @param _to address of the next owner.
    /// @return success.
    function changeContractOwnership(address _to)
    public
    onlyContractOwner
    returns (bool)
    {
        if (_to == 0x0) {
            return false;
        }
        pendingContractOwner = _to;
        return true;
    }

    /// @notice Finalize ownership pass.
    /// Can only be called by pending owner.
    /// @return success.
    function claimContractOwnership()
    public
    returns (bool)
    {
        if (msg.sender != pendingContractOwner) {
            return false;
        }

        emit OwnershipTransferred(contractOwner, pendingContractOwner);
        contractOwner = pendingContractOwner;
        delete pendingContractOwner;
        return true;
    }

    /// @notice Allows the current owner to transfer control of the contract to a newOwner.
    /// @param newOwner The address to transfer ownership to.
    function transferOwnership(address newOwner)
    public
    onlyContractOwner
    returns (bool)
    {
        if (newOwner == 0x0) {
            return false;
        }

        emit OwnershipTransferred(contractOwner, newOwner);
        contractOwner = newOwner;
        delete pendingContractOwner;
        return true;
    }

    /// @notice Withdraw given tokens from contract to owner.
    /// This method is only allowed for contact owner.
    function withdrawTokens(address[] tokens)
    public
    onlyContractOwner
    {
        address _contractOwner = contractOwner;
        for (uint i = 0; i < tokens.length; i++) {
            ERC20Interface token = ERC20Interface(tokens[i]);
            uint balance = token.balanceOf(this);
            if (balance > 0) {
                token.transfer(_contractOwner, balance);
            }
        }
    }

    /// @notice Withdraw ether from contract to owner.
    /// This method is only allowed for contact owner.
    function withdrawEther()
    public
    onlyContractOwner
    {
        uint balance = address(this).balance;
        if (balance > 0)  {
            contractOwner.transfer(balance);
        }
    }

    /// @notice Transfers ether to another address.
    /// Allowed only for contract owners.
    /// @param _to recepient address
    /// @param _value wei to transfer; must be less or equal to total balance on the contract
    function transferEther(address _to, uint256 _value) 
    public 
    onlyContractOwner 
    {
        require(_to != 0x0, "INVALID_ETHER_RECEPIENT_ADDRESS");
        if (_value > address(this).balance) {
            revert("INVALID_VALUE_TO_TRANSFER_ETHER");
        }
        
        _to.transfer(_value);
    }
}

// File: openzeppelin-solidity/contracts/access/Roles.sol

/**
 * @title Roles
 * @dev Library for managing addresses assigned to a Role.
 */
library Roles {
  struct Role {
    mapping (address => bool) bearer;
  }

  /**
   * @dev give an account access to this role
   */
  function add(Role storage role, address account) internal {
    require(account != address(0));
    role.bearer[account] = true;
  }

  /**
   * @dev remove an account's access to this role
   */
  function remove(Role storage role, address account) internal {
    require(account != address(0));
    role.bearer[account] = false;
  }

  /**
   * @dev check if an account has this role
   * @return bool
   */
  function has(Role storage role, address account)
    internal
    view
    returns (bool)
  {
    require(account != address(0));
    return role.bearer[account];
  }
}

// File: openzeppelin-solidity/contracts/access/roles/SignerRole.sol

contract SignerRole {
  using Roles for Roles.Role;

  event SignerAdded(address indexed account);
  event SignerRemoved(address indexed account);

  Roles.Role private signers;

  constructor() public {
    _addSigner(msg.sender);
  }

  modifier onlySigner() {
    require(isSigner(msg.sender));
    _;
  }

  function isSigner(address account) public view returns (bool) {
    return signers.has(account);
  }

  function addSigner(address account) public onlySigner {
    _addSigner(account);
  }

  function renounceSigner() public {
    _removeSigner(msg.sender);
  }

  function _addSigner(address account) internal {
    signers.add(account);
    emit SignerAdded(account);
  }

  function _removeSigner(address account) internal {
    signers.remove(account);
    emit SignerRemoved(account);
  }
}

// File: openzeppelin-solidity/contracts/access/roles/PauserRole.sol

contract PauserRole {
  using Roles for Roles.Role;

  event PauserAdded(address indexed account);
  event PauserRemoved(address indexed account);

  Roles.Role private pausers;

  constructor() public {
    _addPauser(msg.sender);
  }

  modifier onlyPauser() {
    require(isPauser(msg.sender));
    _;
  }

  function isPauser(address account) public view returns (bool) {
    return pausers.has(account);
  }

  function addPauser(address account) public onlyPauser {
    _addPauser(account);
  }

  function renouncePauser() public {
    _removePauser(msg.sender);
  }

  function _addPauser(address account) internal {
    pausers.add(account);
    emit PauserAdded(account);
  }

  function _removePauser(address account) internal {
    pausers.remove(account);
    emit PauserRemoved(account);
  }
}

// File: openzeppelin-solidity/contracts/lifecycle/Pausable.sol

/**
 * @title Pausable
 * @dev Base contract which allows children to implement an emergency stop mechanism.
 */
contract Pausable is PauserRole {
  event Paused();
  event Unpaused();

  bool private _paused = false;


  /**
   * @return true if the contract is paused, false otherwise.
   */
  function paused() public view returns(bool) {
    return _paused;
  }

  /**
   * @dev Modifier to make a function callable only when the contract is not paused.
   */
  modifier whenNotPaused() {
    require(!_paused);
    _;
  }

  /**
   * @dev Modifier to make a function callable only when the contract is paused.
   */
  modifier whenPaused() {
    require(_paused);
    _;
  }

  /**
   * @dev called by the owner to pause, triggers stopped state
   */
  function pause() public onlyPauser whenNotPaused {
    _paused = true;
    emit Paused();
  }

  /**
   * @dev called by the owner to unpause, returns to normal state
   */
  function unpause() public onlyPauser whenPaused {
    _paused = false;
    emit Unpaused();
  }
}

// File: openzeppelin-solidity/contracts/token/ERC20/IERC20.sol

/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
interface IERC20 {
  function totalSupply() external view returns (uint256);

  function balanceOf(address who) external view returns (uint256);

  function allowance(address owner, address spender)
    external view returns (uint256);

  function transfer(address to, uint256 value) external returns (bool);

  function approve(address spender, uint256 value)
    external returns (bool);

  function transferFrom(address from, address to, uint256 value)
    external returns (bool);

  event Transfer(
    address indexed from,
    address indexed to,
    uint256 value
  );

  event Approval(
    address indexed owner,
    address indexed spender,
    uint256 value
  );
}

// File: @laborx/airdrop/contracts/ERC223ReceivingContract.sol

/**
 * @title Contract that will work with ERC223 tokens.
 */

interface ERC223ReceivingContract {
/**
 * @dev Standard ERC223 function that will handle incoming token transfers.
 *
 * @param _from  Token sender address.
 * @param _value Amount of tokens.
 * @param _data  Transaction metadata.
 */
    function tokenFallback(address _from, uint _value, bytes _data) external;
}

// File: @laborx/airdrop/contracts/Airdrop.sol

/// @title Airdrop contract based on Merkle tree and merkle proof of addresses and amount of tokens to withdraw.
///     Contract requires that merkle tree was built on leafs keccak256(position, recepient address, amount)
///     Supports ERC223 token standard that allows to receive/not receive tokens that allowed (supported) by smart
///     contracts, so no dummy or mistyped token transfers.
contract Airdrop is Owned, SignerRole, Pausable, ERC223ReceivingContract {

    uint constant OK = 1;

    /// @dev Log when airdrop
    event LogAirdropClaimed(address indexed initiator, bytes32 operationId, uint amount);
    /// @dev Log when merkle root will be updated
    event LogMerkleRootUpdated(bytes32 to, address by);

    /// @dev Version of the contract. Allows to distinguish between releases.
    bytes32 public version = "0.2.0";
    /// @dev Token to airdrop to.
    IERC20 public token;
    /// @dev Merkle root of the airdrop
    bytes32 public merkleRoot;
    /// @dev (operation id => completed)
    mapping(bytes32 => bool) public completedAirdrops;

    /// @notice Creates airdrop contract. Fails if token `_token` is 0x0.
    /// @param _token token address to airdrop; supports ERC223 token contracts
    constructor(address _token)
    public
    {
        require(_token != 0x0, "AIRDROP_INVALID_TOKEN_ADDRESS");
        token = IERC20(_token);
    }

    /// @notice Updates merkle root after changes in airdrop records.
    ///     Emits 'LogMerkleRootUpdated' event.
    ///     Only signer allowed to call.
    /// @param _updatedMerkleRoot new merkle root hash calculated on updated airdrop records.
    ///     Could be set empty if you need to stop withraws.
    function setMerkleRoot(bytes32 _updatedMerkleRoot)
    external
    onlySigner
    returns (uint)
    {
        merkleRoot = _updatedMerkleRoot;

        emit LogMerkleRootUpdated(_updatedMerkleRoot, msg.sender);
        return OK;
    }

    /// @notice Claim tokens held by airdrop contract based on proof provided
    ///     by sender `msg.sender` based on position `_position` in airdrop list.
    ///     Emits 'LogAirdropClaimed' event when withdraw claim is successful.
    /// @param _proof merkle proof list of hashes
    /// @param _operationId unique withrawal operation ID
    /// @param _position position of airdrop record that is included in proof calculations
    /// @param _amount amount of tokens to withdraw
    /// @return result code of an operation. OK (1) if all went good.
    function claimTokensByMerkleProof(
        bytes32[] _proof,
        bytes32 _operationId,
        uint _position,
        uint _amount
    )
    external
    whenNotPaused
    returns (uint)
    {
        bytes32 leaf = _calculateMerkleLeaf(_operationId, _position, msg.sender, _amount);

        require(completedAirdrops[_operationId] == false, "AIRDROP_ALREADY_CLAIMED");
        require(checkMerkleProof(merkleRoot, _proof, _position, leaf), "AIRDROP_INVALID_PROOF");
        require(token.transfer(msg.sender, _amount), "AIRDROP_TRANSFER_FAILURE");

        // Mark operation as completed
        completedAirdrops[_operationId] = true;

        emit LogAirdropClaimed(msg.sender, _operationId, _amount);
        return OK;
    }

    /// @notice Checks merkle proof based on the latest merkle root set up.
    /// @param _merkleRoot merkle root hash to compare result with
    /// @param _proof merkle proof list of hashes
    /// @param _position position of airdrop record that is included in proof calculations
    /// @param _leaf leaf hash that should be tested for containment in merkle tree
    /// @return true if leaf `_leaf` is included in merkle tree, false otherwise
    function checkMerkleProof(
        bytes32 _merkleRoot,
        bytes32[] _proof,
        uint _position,
        bytes32 _leaf
    )
    public
    pure
    returns (bool)
    {
        bytes32 _computedHash = _leaf;
        uint _checkedPosition = _position;

        for (uint i = 0; i < _proof.length; i += 1) {
            bytes32 _proofElement = _proof[i];

            if (_checkedPosition % 2 == 0) {
                _computedHash = keccak256(abi.encodePacked(_computedHash, _proofElement));
            } else {
                _computedHash = keccak256(abi.encodePacked(_proofElement, _computedHash));
            }

            _checkedPosition /= 2;
        }

        return _computedHash == _merkleRoot;
    }

    /*
        ERC223 token

        https://github.com/ethereum/EIPs/issues/223
    */

    /// @notice Guards smart contract from accepting non-allowed tokens (if they support ERC223 interface)
    function tokenFallback(address /*_from*/, uint /*_value*/, bytes /*_data*/)
    external
    whenNotPaused
    {
        require(msg.sender == address(token), "AIRDROP_TOKEN_NOT_SUPPORTED");
    }

    /* PRIVATE */

    /// @notice Gets merkle leaf based on index `_index`, destination address `_address` and
    ///     amount of tokens to transfer `_amount`
    function _calculateMerkleLeaf(bytes32 _operationId, uint _index, address _address, uint _amount)
    private
    pure
    returns (bytes32)
    {
        return keccak256(abi.encodePacked(_operationId, _index, _address, _amount));
    }
}

// File: contracts/Import.sol

/**
* Copyright 2017–2018, LaborX PTY
* Licensed under the AGPL Version 3 license.
*/

pragma solidity ^0.4.24;