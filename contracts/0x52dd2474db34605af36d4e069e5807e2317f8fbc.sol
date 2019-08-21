// File: node_modules\openzeppelin-solidity\contracts\token\ERC20\ERC20Basic.sol

pragma solidity ^0.4.21;


/**
 * @title ERC20Basic
 * @dev Simpler version of ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/179
 */
contract ERC20Basic {
  function totalSupply() public view returns (uint256);
  function balanceOf(address who) public view returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}

// File: node_modules\openzeppelin-solidity\contracts\token\ERC20\ERC20.sol

pragma solidity ^0.4.21;



/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender) public view returns (uint256);
  function transferFrom(address from, address to, uint256 value) public returns (bool);
  function approve(address spender, uint256 value) public returns (bool);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}

// File: node_modules\openzeppelin-solidity\contracts\token\ERC20\SafeERC20.sol

pragma solidity ^0.4.21;




/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure.
 * To use this library you can add a `using SafeERC20 for ERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
  function safeTransfer(ERC20Basic token, address to, uint256 value) internal {
    assert(token.transfer(to, value));
  }

  function safeTransferFrom(
    ERC20 token,
    address from,
    address to,
    uint256 value
  )
    internal
  {
    assert(token.transferFrom(from, to, value));
  }

  function safeApprove(ERC20 token, address spender, uint256 value) internal {
    assert(token.approve(spender, value));
  }
}

// File: node_modules\openzeppelin-solidity\contracts\math\SafeMath.sol

pragma solidity ^0.4.21;


/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {

  /**
  * @dev Multiplies two numbers, throws on overflow.
  */
  function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
    if (a == 0) {
      return 0;
    }
    c = a * b;
    assert(c / a == b);
    return c;
  }

  /**
  * @dev Integer division of two numbers, truncating the quotient.
  */
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    // uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return a / b;
  }

  /**
  * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
  */
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  /**
  * @dev Adds two numbers, throws on overflow.
  */
  function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
    c = a + b;
    assert(c >= a);
    return c;
  }
}

// File: node_modules\openzeppelin-solidity\contracts\token\ERC20\BasicToken.sol

pragma solidity ^0.4.21;




/**
 * @title Basic token
 * @dev Basic version of StandardToken, with no allowances.
 */
contract BasicToken is ERC20Basic {
  using SafeMath for uint256;

  mapping(address => uint256) balances;

  uint256 totalSupply_;

  /**
  * @dev total number of tokens in existence
  */
  function totalSupply() public view returns (uint256) {
    return totalSupply_;
  }

  /**
  * @dev transfer token for a specified address
  * @param _to The address to transfer to.
  * @param _value The amount to be transferred.
  */
  function transfer(address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));
    require(_value <= balances[msg.sender]);

    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);
    emit Transfer(msg.sender, _to, _value);
    return true;
  }

  /**
  * @dev Gets the balance of the specified address.
  * @param _owner The address to query the the balance of.
  * @return An uint256 representing the amount owned by the passed address.
  */
  function balanceOf(address _owner) public view returns (uint256) {
    return balances[_owner];
  }

}

// File: node_modules\openzeppelin-solidity\contracts\token\ERC20\StandardToken.sol

pragma solidity ^0.4.21;




/**
 * @title Standard ERC20 token
 *
 * @dev Implementation of the basic standard token.
 * @dev https://github.com/ethereum/EIPs/issues/20
 * @dev Based on code by FirstBlood: https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol
 */
contract StandardToken is ERC20, BasicToken {

  mapping (address => mapping (address => uint256)) internal allowed;


  /**
   * @dev Transfer tokens from one address to another
   * @param _from address The address which you want to send tokens from
   * @param _to address The address which you want to transfer to
   * @param _value uint256 the amount of tokens to be transferred
   */
  function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));
    require(_value <= balances[_from]);
    require(_value <= allowed[_from][msg.sender]);

    balances[_from] = balances[_from].sub(_value);
    balances[_to] = balances[_to].add(_value);
    allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
    emit Transfer(_from, _to, _value);
    return true;
  }

  /**
   * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.
   *
   * Beware that changing an allowance with this method brings the risk that someone may use both the old
   * and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this
   * race condition is to first reduce the spender's allowance to 0 and set the desired value afterwards:
   * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
   * @param _spender The address which will spend the funds.
   * @param _value The amount of tokens to be spent.
   */
  function approve(address _spender, uint256 _value) public returns (bool) {
    allowed[msg.sender][_spender] = _value;
    emit Approval(msg.sender, _spender, _value);
    return true;
  }

  /**
   * @dev Function to check the amount of tokens that an owner allowed to a spender.
   * @param _owner address The address which owns the funds.
   * @param _spender address The address which will spend the funds.
   * @return A uint256 specifying the amount of tokens still available for the spender.
   */
  function allowance(address _owner, address _spender) public view returns (uint256) {
    return allowed[_owner][_spender];
  }

  /**
   * @dev Increase the amount of tokens that an owner allowed to a spender.
   *
   * approve should be called when allowed[_spender] == 0. To increment
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   * @param _spender The address which will spend the funds.
   * @param _addedValue The amount of tokens to increase the allowance by.
   */
  function increaseApproval(address _spender, uint _addedValue) public returns (bool) {
    allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

  /**
   * @dev Decrease the amount of tokens that an owner allowed to a spender.
   *
   * approve should be called when allowed[_spender] == 0. To decrement
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   * @param _spender The address which will spend the funds.
   * @param _subtractedValue The amount of tokens to decrease the allowance by.
   */
  function decreaseApproval(address _spender, uint _subtractedValue) public returns (bool) {
    uint oldValue = allowed[msg.sender][_spender];
    if (_subtractedValue > oldValue) {
      allowed[msg.sender][_spender] = 0;
    } else {
      allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
    }
    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

}

// File: node_modules\openzeppelin-solidity\contracts\token\ERC721\ERC721Basic.sol

pragma solidity ^0.4.21;


/**
 * @title ERC721 Non-Fungible Token Standard basic interface
 * @dev see https://github.com/ethereum/EIPs/blob/master/EIPS/eip-721.md
 */
contract ERC721Basic {
  event Transfer(address indexed _from, address indexed _to, uint256 _tokenId);
  event Approval(address indexed _owner, address indexed _approved, uint256 _tokenId);
  event ApprovalForAll(address indexed _owner, address indexed _operator, bool _approved);

  function balanceOf(address _owner) public view returns (uint256 _balance);
  function ownerOf(uint256 _tokenId) public view returns (address _owner);
  function exists(uint256 _tokenId) public view returns (bool _exists);

  function approve(address _to, uint256 _tokenId) public;
  function getApproved(uint256 _tokenId) public view returns (address _operator);

  function setApprovalForAll(address _operator, bool _approved) public;
  function isApprovedForAll(address _owner, address _operator) public view returns (bool);

  function transferFrom(address _from, address _to, uint256 _tokenId) public;
  function safeTransferFrom(address _from, address _to, uint256 _tokenId) public;
  function safeTransferFrom(
    address _from,
    address _to,
    uint256 _tokenId,
    bytes _data
  )
    public;
}

// File: node_modules\openzeppelin-solidity\contracts\token\ERC721\ERC721Receiver.sol

pragma solidity ^0.4.21;


/**
 * @title ERC721 token receiver interface
 * @dev Interface for any contract that wants to support safeTransfers
 *  from ERC721 asset contracts.
 */
contract ERC721Receiver {
  /**
   * @dev Magic value to be returned upon successful reception of an NFT
   *  Equals to `bytes4(keccak256("onERC721Received(address,uint256,bytes)"))`,
   *  which can be also obtained as `ERC721Receiver(0).onERC721Received.selector`
   */
  bytes4 constant ERC721_RECEIVED = 0xf0b9e5ba;

  /**
   * @notice Handle the receipt of an NFT
   * @dev The ERC721 smart contract calls this function on the recipient
   *  after a `safetransfer`. This function MAY throw to revert and reject the
   *  transfer. This function MUST use 50,000 gas or less. Return of other
   *  than the magic value MUST result in the transaction being reverted.
   *  Note: the contract address is always the message sender.
   * @param _from The sending address
   * @param _tokenId The NFT identifier which is being transfered
   * @param _data Additional data with no specified format
   * @return `bytes4(keccak256("onERC721Received(address,uint256,bytes)"))`
   */
  function onERC721Received(address _from, uint256 _tokenId, bytes _data) public returns(bytes4);
}

// File: node_modules\openzeppelin-solidity\contracts\AddressUtils.sol

pragma solidity ^0.4.21;


/**
 * Utility library of inline functions on addresses
 */
library AddressUtils {

  /**
   * Returns whether the target address is a contract
   * @dev This function will return false if invoked during the constructor of a contract,
   *  as the code is not actually created until after the constructor finishes.
   * @param addr address to check
   * @return whether the target address is a contract
   */
  function isContract(address addr) internal view returns (bool) {
    uint256 size;
    // XXX Currently there is no better way to check if there is a contract in an address
    // than to check the size of the code at that address.
    // See https://ethereum.stackexchange.com/a/14016/36603
    // for more details about how this works.
    // TODO Check this again before the Serenity release, because all addresses will be
    // contracts then.
    assembly { size := extcodesize(addr) }  // solium-disable-line security/no-inline-assembly
    return size > 0;
  }

}

// File: node_modules\openzeppelin-solidity\contracts\token\ERC721\ERC721BasicToken.sol

pragma solidity ^0.4.21;






/**
 * @title ERC721 Non-Fungible Token Standard basic implementation
 * @dev see https://github.com/ethereum/EIPs/blob/master/EIPS/eip-721.md
 */
contract ERC721BasicToken is ERC721Basic {
  using SafeMath for uint256;
  using AddressUtils for address;

  // Equals to `bytes4(keccak256("onERC721Received(address,uint256,bytes)"))`
  // which can be also obtained as `ERC721Receiver(0).onERC721Received.selector`
  bytes4 constant ERC721_RECEIVED = 0xf0b9e5ba;

  // Mapping from token ID to owner
  mapping (uint256 => address) internal tokenOwner;

  // Mapping from token ID to approved address
  mapping (uint256 => address) internal tokenApprovals;

  // Mapping from owner to number of owned token
  mapping (address => uint256) internal ownedTokensCount;

  // Mapping from owner to operator approvals
  mapping (address => mapping (address => bool)) internal operatorApprovals;

  /**
   * @dev Guarantees msg.sender is owner of the given token
   * @param _tokenId uint256 ID of the token to validate its ownership belongs to msg.sender
   */
  modifier onlyOwnerOf(uint256 _tokenId) {
    require(ownerOf(_tokenId) == msg.sender);
    _;
  }

  /**
   * @dev Checks msg.sender can transfer a token, by being owner, approved, or operator
   * @param _tokenId uint256 ID of the token to validate
   */
  modifier canTransfer(uint256 _tokenId) {
    require(isApprovedOrOwner(msg.sender, _tokenId));
    _;
  }

  /**
   * @dev Gets the balance of the specified address
   * @param _owner address to query the balance of
   * @return uint256 representing the amount owned by the passed address
   */
  function balanceOf(address _owner) public view returns (uint256) {
    require(_owner != address(0));
    return ownedTokensCount[_owner];
  }

  /**
   * @dev Gets the owner of the specified token ID
   * @param _tokenId uint256 ID of the token to query the owner of
   * @return owner address currently marked as the owner of the given token ID
   */
  function ownerOf(uint256 _tokenId) public view returns (address) {
    address owner = tokenOwner[_tokenId];
    require(owner != address(0));
    return owner;
  }

  /**
   * @dev Returns whether the specified token exists
   * @param _tokenId uint256 ID of the token to query the existance of
   * @return whether the token exists
   */
  function exists(uint256 _tokenId) public view returns (bool) {
    address owner = tokenOwner[_tokenId];
    return owner != address(0);
  }

  /**
   * @dev Approves another address to transfer the given token ID
   * @dev The zero address indicates there is no approved address.
   * @dev There can only be one approved address per token at a given time.
   * @dev Can only be called by the token owner or an approved operator.
   * @param _to address to be approved for the given token ID
   * @param _tokenId uint256 ID of the token to be approved
   */
  function approve(address _to, uint256 _tokenId) public {
    address owner = ownerOf(_tokenId);
    require(_to != owner);
    require(msg.sender == owner || isApprovedForAll(owner, msg.sender));

    if (getApproved(_tokenId) != address(0) || _to != address(0)) {
      tokenApprovals[_tokenId] = _to;
      emit Approval(owner, _to, _tokenId);
    }
  }

  /**
   * @dev Gets the approved address for a token ID, or zero if no address set
   * @param _tokenId uint256 ID of the token to query the approval of
   * @return address currently approved for a the given token ID
   */
  function getApproved(uint256 _tokenId) public view returns (address) {
    return tokenApprovals[_tokenId];
  }

  /**
   * @dev Sets or unsets the approval of a given operator
   * @dev An operator is allowed to transfer all tokens of the sender on their behalf
   * @param _to operator address to set the approval
   * @param _approved representing the status of the approval to be set
   */
  function setApprovalForAll(address _to, bool _approved) public {
    require(_to != msg.sender);
    operatorApprovals[msg.sender][_to] = _approved;
    emit ApprovalForAll(msg.sender, _to, _approved);
  }

  /**
   * @dev Tells whether an operator is approved by a given owner
   * @param _owner owner address which you want to query the approval of
   * @param _operator operator address which you want to query the approval of
   * @return bool whether the given operator is approved by the given owner
   */
  function isApprovedForAll(address _owner, address _operator) public view returns (bool) {
    return operatorApprovals[_owner][_operator];
  }

  /**
   * @dev Transfers the ownership of a given token ID to another address
   * @dev Usage of this method is discouraged, use `safeTransferFrom` whenever possible
   * @dev Requires the msg sender to be the owner, approved, or operator
   * @param _from current owner of the token
   * @param _to address to receive the ownership of the given token ID
   * @param _tokenId uint256 ID of the token to be transferred
  */
  function transferFrom(address _from, address _to, uint256 _tokenId) public canTransfer(_tokenId) {
    require(_from != address(0));
    require(_to != address(0));

    clearApproval(_from, _tokenId);
    removeTokenFrom(_from, _tokenId);
    addTokenTo(_to, _tokenId);

    emit Transfer(_from, _to, _tokenId);
  }

  /**
   * @dev Safely transfers the ownership of a given token ID to another address
   * @dev If the target address is a contract, it must implement `onERC721Received`,
   *  which is called upon a safe transfer, and return the magic value
   *  `bytes4(keccak256("onERC721Received(address,uint256,bytes)"))`; otherwise,
   *  the transfer is reverted.
   * @dev Requires the msg sender to be the owner, approved, or operator
   * @param _from current owner of the token
   * @param _to address to receive the ownership of the given token ID
   * @param _tokenId uint256 ID of the token to be transferred
  */
  function safeTransferFrom(
    address _from,
    address _to,
    uint256 _tokenId
  )
    public
    canTransfer(_tokenId)
  {
    // solium-disable-next-line arg-overflow
    safeTransferFrom(_from, _to, _tokenId, "");
  }

  /**
   * @dev Safely transfers the ownership of a given token ID to another address
   * @dev If the target address is a contract, it must implement `onERC721Received`,
   *  which is called upon a safe transfer, and return the magic value
   *  `bytes4(keccak256("onERC721Received(address,uint256,bytes)"))`; otherwise,
   *  the transfer is reverted.
   * @dev Requires the msg sender to be the owner, approved, or operator
   * @param _from current owner of the token
   * @param _to address to receive the ownership of the given token ID
   * @param _tokenId uint256 ID of the token to be transferred
   * @param _data bytes data to send along with a safe transfer check
   */
  function safeTransferFrom(
    address _from,
    address _to,
    uint256 _tokenId,
    bytes _data
  )
    public
    canTransfer(_tokenId)
  {
    transferFrom(_from, _to, _tokenId);
    // solium-disable-next-line arg-overflow
    require(checkAndCallSafeTransfer(_from, _to, _tokenId, _data));
  }

  /**
   * @dev Returns whether the given spender can transfer a given token ID
   * @param _spender address of the spender to query
   * @param _tokenId uint256 ID of the token to be transferred
   * @return bool whether the msg.sender is approved for the given token ID,
   *  is an operator of the owner, or is the owner of the token
   */
  function isApprovedOrOwner(address _spender, uint256 _tokenId) internal view returns (bool) {
    address owner = ownerOf(_tokenId);
    return _spender == owner || getApproved(_tokenId) == _spender || isApprovedForAll(owner, _spender);
  }

  /**
   * @dev Internal function to mint a new token
   * @dev Reverts if the given token ID already exists
   * @param _to The address that will own the minted token
   * @param _tokenId uint256 ID of the token to be minted by the msg.sender
   */
  function _mint(address _to, uint256 _tokenId) internal {
    require(_to != address(0));
    addTokenTo(_to, _tokenId);
    emit Transfer(address(0), _to, _tokenId);
  }

  /**
   * @dev Internal function to burn a specific token
   * @dev Reverts if the token does not exist
   * @param _tokenId uint256 ID of the token being burned by the msg.sender
   */
  function _burn(address _owner, uint256 _tokenId) internal {
    clearApproval(_owner, _tokenId);
    removeTokenFrom(_owner, _tokenId);
    emit Transfer(_owner, address(0), _tokenId);
  }

  /**
   * @dev Internal function to clear current approval of a given token ID
   * @dev Reverts if the given address is not indeed the owner of the token
   * @param _owner owner of the token
   * @param _tokenId uint256 ID of the token to be transferred
   */
  function clearApproval(address _owner, uint256 _tokenId) internal {
    require(ownerOf(_tokenId) == _owner);
    if (tokenApprovals[_tokenId] != address(0)) {
      tokenApprovals[_tokenId] = address(0);
      emit Approval(_owner, address(0), _tokenId);
    }
  }

  /**
   * @dev Internal function to add a token ID to the list of a given address
   * @param _to address representing the new owner of the given token ID
   * @param _tokenId uint256 ID of the token to be added to the tokens list of the given address
   */
  function addTokenTo(address _to, uint256 _tokenId) internal {
    require(tokenOwner[_tokenId] == address(0));
    tokenOwner[_tokenId] = _to;
    ownedTokensCount[_to] = ownedTokensCount[_to].add(1);
  }

  /**
   * @dev Internal function to remove a token ID from the list of a given address
   * @param _from address representing the previous owner of the given token ID
   * @param _tokenId uint256 ID of the token to be removed from the tokens list of the given address
   */
  function removeTokenFrom(address _from, uint256 _tokenId) internal {
    require(ownerOf(_tokenId) == _from);
    ownedTokensCount[_from] = ownedTokensCount[_from].sub(1);
    tokenOwner[_tokenId] = address(0);
  }

  /**
   * @dev Internal function to invoke `onERC721Received` on a target address
   * @dev The call is not executed if the target address is not a contract
   * @param _from address representing the previous owner of the given token ID
   * @param _to target address that will receive the tokens
   * @param _tokenId uint256 ID of the token to be transferred
   * @param _data bytes optional data to send along with the call
   * @return whether the call correctly returned the expected magic value
   */
  function checkAndCallSafeTransfer(
    address _from,
    address _to,
    uint256 _tokenId,
    bytes _data
  )
    internal
    returns (bool)
  {
    if (!_to.isContract()) {
      return true;
    }
    bytes4 retval = ERC721Receiver(_to).onERC721Received(_from, _tokenId, _data);
    return (retval == ERC721_RECEIVED);
  }
}

// File: contracts\Strings.sol

pragma solidity ^0.4.23;

library Strings {
  // via https://github.com/oraclize/ethereum-api/blob/master/oraclizeAPI_0.5.sol
  function strConcat(string _a, string _b, string _c, string _d, string _e) internal pure returns (string) {
    bytes memory _ba = bytes(_a);
    bytes memory _bb = bytes(_b);
    bytes memory _bc = bytes(_c);
    bytes memory _bd = bytes(_d);
    bytes memory _be = bytes(_e);
    string memory abcde = new string(_ba.length + _bb.length + _bc.length + _bd.length + _be.length);
    bytes memory babcde = bytes(abcde);
    uint k = 0;
    for (uint i = 0; i < _ba.length; i++) babcde[k++] = _ba[i];
    for (i = 0; i < _bb.length; i++) babcde[k++] = _bb[i];
    for (i = 0; i < _bc.length; i++) babcde[k++] = _bc[i];
    for (i = 0; i < _bd.length; i++) babcde[k++] = _bd[i];
    for (i = 0; i < _be.length; i++) babcde[k++] = _be[i];
    return string(babcde);
  }

  function strConcat(string _a, string _b, string _c, string _d) internal pure returns (string) {
    return strConcat(_a, _b, _c, _d, "");
  }

  function strConcat(string _a, string _b, string _c) internal pure returns (string) {
    return strConcat(_a, _b, _c, "", "");
  }

  function strConcat(string _a, string _b) internal pure returns (string) {
    return strConcat(_a, _b, "", "", "");
  }

  function uint2str(uint i) internal pure returns (string) {
    if (i == 0) return "0";
    uint j = i;
    uint len;
    while (j != 0){
      len++;
      j /= 10;
    }
    bytes memory bstr = new bytes(len);
    uint k = len - 1;
    while (i != 0){
      bstr[k--] = byte(48 + i % 10);
      i /= 10;
    }
    return string(bstr);
  }
}

// File: contracts\DefinerBasicLoan.sol

pragma solidity ^0.4.23;






interface ERC721Metadata /* is ERC721 */ {
  /// @notice A descriptive name for a collection of NFTs in this contract
  function name() external view returns (string _name);

  /// @notice An abbreviated name for NFTs in this contract
  function symbol() external view returns (string _symbol);

  /// @notice A distinct Uniform Resource Identifier (URI) for a given asset.
  /// @dev Throws if `_tokenId` is not a valid NFT. URIs are defined in RFC
  ///  3986. The URI may point to a JSON file that conforms to the "ERC721
  ///  Metadata JSON Schema".
  function tokenURI(uint256 _tokenId) external view returns (string);
}

contract DefinerBasicLoan is ERC721BasicToken, ERC721Metadata {
  using SafeERC20 for ERC20;
  using SafeMath for uint;

  enum States {
    Init,                 //0
    WaitingForLender,     //1
    WaitingForBorrower,   //2
    WaitingForCollateral, //3
    WaitingForFunds,      //4
    Funded,               //5
    Finished,             //6
    Closed,               //7
    Default,              //8
    Cancelled             //9
  }

  address public ownerAddress;
  address public borrowerAddress;
  address public lenderAddress;
  string public loanId;
  uint public endTime;  // use to check default
  uint public nextPaymentDateTime; // use to check default
  uint public daysPerInstallment; // use to calculate next payment date
  uint public totalLoanTerm; // in days
  uint public borrowAmount; // total borrowed amount
  uint public collateralAmount; // total collateral amount
  uint public installmentAmount; // amount of each installment
  uint public remainingInstallment; // total installment left

  States public currentState = States.Init;

  /**
   * TODO: change address below to actual factory address after deployment
   *       address constant private factoryContract = 0x...
   */
  address internal factoryContract; // = 0x38Bddc3793DbFb3dE178E3dE74cae2E223c02B85;
  modifier onlyFactoryContract() {
      require(factoryContract == 0 || msg.sender == factoryContract, "not factory contract");
      _;
  }

  modifier atState(States state) {
    require(state == currentState, "Invalid State");
    _;
  }

  modifier onlyOwner() {
    require(msg.sender == ownerAddress, "Invalid Owner Address");
    _;
  }

  modifier onlyLender() {
    require(msg.sender == lenderAddress || msg.sender == factoryContract, "Invalid Lender Address");
    _;
  }

  modifier onlyBorrower() {
    require(msg.sender == borrowerAddress || msg.sender == factoryContract, "Invalid Borrower Address");
    _;
  }

  modifier notDefault() {
    require(now < nextPaymentDateTime, "This Contract has not yet default");
    require(now < endTime, "This Contract has not yet default");
    _;
  }

  /**
   * ERC721 Interface
   */

  function name() public view returns (string _name)
  {
    return "DeFiner Contract";
  }

  function symbol() public view returns (string _symbol)
  {
    return "DFINC";
  }

  function tokenURI(uint256) public view returns (string)
  {
    return Strings.strConcat(
      "https://api.definer.org/OKh4I2yYpKU8S2af/definer/api/v1.0/opensea/",
      loanId
    );
  }

  function transferFrom(address _from, address _to, uint256 _tokenId) public {
    require(_from != address(0));
    require(_to != address(0));

    super.transferFrom(_from, _to, _tokenId);
    lenderAddress = tokenOwner[_tokenId];
  }

  function safeTransferFrom(
    address _from,
    address _to,
    uint256 _tokenId
  )
  public
  {
    // solium-disable-next-line arg-overflow
    safeTransferFrom(_from, _to, _tokenId, "");
    lenderAddress = tokenOwner[_tokenId];
  }

  function safeTransferFrom(
    address _from,
    address _to,
    uint256 _tokenId,
    bytes _data
  )
  public
  {
    transferFrom(_from, _to, _tokenId);
    // solium-disable-next-line arg-overflow
    require(checkAndCallSafeTransfer(_from, _to, _tokenId, _data));
    lenderAddress = tokenOwner[_tokenId];
  }


  /**
   * Borrower transfer ETH to contract
   */
  function transferCollateral() public payable /*atState(States.WaitingForCollateral)*/;

  /**
   * Check if borrower transferred correct amount of Token
   */
  function checkCollateral() public /*atState(States.WaitingForCollateral)*/;

  /**
  *  Borrower cancel the transaction is Default
  */
  function borrowerCancel() public /*onlyLender atState(States.WaitingForLender)*/;

  /**
  *  Lender cancel the transaction is Default
  */
  function lenderCancel() public /*onlyLender atState(States.WaitingForBorrower)*/;

  /**
   * Lender transfer ETH to contract
   */
  function transferFunds() public payable /*atState(States.WaitingForFunds)*/;

  /**
   * Check if lender transferred correct amount of Token
   */
  function checkFunds() public /*atState(States.WaitingForFunds)*/;

  /**
   *  Borrower pay back ETH or Token
   */
  function borrowerMakePayment() public payable /*onlyBorrower atState(States.Funded) notDefault*/;

  /**
   *  Borrower gets collateral back
   */
  function borrowerReclaimCollateral() public /*onlyBorrower atState(States.Finished)*/;

  /**
   *  Lender gets collateral when contract state is Default
   */
  function lenderReclaimCollateral() public /*onlyLender atState(States.Default)*/;


  /**
  * Borrower accept loan
  */
  function borrowerAcceptLoan() public atState(States.WaitingForBorrower) {
    require(msg.sender != address(0), "Invalid address.");
    borrowerAddress = msg.sender;
    currentState = States.WaitingForCollateral;
  }

  /**
   * Lender accept loan
   */
  function lenderAcceptLoan() public atState(States.WaitingForLender) {
    require(msg.sender != address(0), "Invalid address.");
    lenderAddress = msg.sender;
    currentState = States.WaitingForFunds;
  }

  function transferETHToBorrowerAndStartLoan() internal {
    borrowerAddress.transfer(borrowAmount);
    endTime = now.add(totalLoanTerm.mul(1 days));
    nextPaymentDateTime = now.add(daysPerInstallment.mul(1 days));
    currentState = States.Funded;
  }

  function transferTokenToBorrowerAndStartLoan(StandardToken token) internal {
    require(token.transfer(borrowerAddress, borrowAmount), "Token transfer failed");
    endTime = now.add(totalLoanTerm.mul(1 days));
    nextPaymentDateTime = now.add(daysPerInstallment.mul(1 days));
    currentState = States.Funded;
  }

  //TODO not in use yet
  function checkDefault() public onlyLender atState(States.Funded) returns (bool) {
    if (now > endTime || now > nextPaymentDateTime) {
      currentState = States.Default;
      return true;
    } else {
      return false;
    }
  }

  // For testing
  function forceDefault() public onlyOwner {
    currentState = States.Default;
  }

  function getLoanDetails() public view returns (address,address,address,string,uint,uint,uint,uint,uint,uint,uint,uint,uint) {
//    address public ownerAddress;
//    address public borrowerAddress;
//    address public lenderAddress;
//    string public loanId;
//    uint public endTime;  // use to check default
//    uint public nextPaymentDateTime; // use to check default
//    uint public daysPerInstallment; // use to calculate next payment date
//    uint public totalLoanTerm; // in days
//    uint public borrowAmount; // total borrowed amount
//    uint public collateralAmount; // total collateral amount
//    uint public installmentAmount; // amount of each installment
//    uint public remainingInstallment; // total installment left
//    States public currentState = States.Init;
//
//    return (
//      nextPaymentDateTime,
//      remainingInstallment,
//      uint(currentState),
//      loanId,
//      borrowerAddress,
//      lenderAddress
//    );
    return (
      ownerAddress,
      borrowerAddress,
      lenderAddress,
      loanId,
      endTime,
      nextPaymentDateTime,
      daysPerInstallment,
      totalLoanTerm,
      borrowAmount,
      collateralAmount,
      installmentAmount,
      remainingInstallment,
      uint(currentState)
    );
  }
}

// File: contracts\ERC20ETHLoan.sol

pragma solidity ^0.4.23;


/**
 * Collateral: ERC20 Token
 * Borrowed: ETH
 */
contract ERC20ETHLoan is DefinerBasicLoan {

  StandardToken token;
  address public collateralTokenAddress;

  /**
   * NOT IN USE
   * WHEN COLLATERAL IS TOKEN, TRANSFER IS DONE IN FRONT END
   */
  function transferCollateral() public payable {
    revert();
  }

  function establishContract() public {

    // ERC20 as collateral
    uint amount = token.balanceOf(address(this));
    require(amount >= collateralAmount, "Insufficient collateral amount");

    // Ether as Fund
    require(address(this).balance >= borrowAmount, "Insufficient fund amount");

    // Transit to Funded state
    transferETHToBorrowerAndStartLoan();
  }

  /**
   * NOT IN USE
   * WHEN FUND IS ETH, CHECK IS DONE IN transferFunds()
   */
  function checkFunds() onlyLender atState(States.WaitingForFunds) public {
    return establishContract();
  }

  /**
   * Check if borrower transferred correct amount of token to this contract
   */
  function checkCollateral() public onlyBorrower atState(States.WaitingForCollateral) {
    uint amount = token.balanceOf(address(this));
    require(amount >= collateralAmount, "Insufficient collateral amount");
    currentState = States.WaitingForLender;
  }

  /**
   *  Lender transfer ETH to fund this contract
   */
  function transferFunds() public payable onlyLender atState(States.WaitingForFunds) {
    if (address(this).balance >= borrowAmount) {
      establishContract();
    }
  }

  /*
   *  Borrower pay back ETH
   */
  function borrowerMakePayment() public payable onlyBorrower atState(States.Funded) notDefault {
    require(msg.value >= installmentAmount);
    remainingInstallment--;
    lenderAddress.transfer(installmentAmount);
    if (remainingInstallment == 0) {
      currentState = States.Finished;
    } else {
      nextPaymentDateTime = nextPaymentDateTime.add(daysPerInstallment.mul(1 days));
    }
  }

  /*
   *  Borrower gets collateral token back when contract completed
   */
  function borrowerReclaimCollateral() public onlyBorrower atState(States.Finished) {
    uint amount = token.balanceOf(address(this));
    token.transfer(borrowerAddress, amount);
    currentState = States.Closed;
  }

  /*
   *  Lender gets collateral token when contract defaulted
   */
  function lenderReclaimCollateral() public onlyLender atState(States.Default) {
    uint amount = token.balanceOf(address(this));
    token.transfer(lenderAddress, amount);
    currentState = States.Closed;
  }
}

// File: contracts\ERC20ETHLoanBorrower.sol

pragma solidity ^0.4.23;


/**
 * Collateral: ERC20 Token
 * Borrowed: ETH
 */
contract ERC20ETHLoanBorrower is ERC20ETHLoan {
  function init (
    address _ownerAddress,
    address _borrowerAddress,
    address _lenderAddress,
    address _collateralTokenAddress,
    uint _borrowAmount,
    uint _paybackAmount,
    uint _collateralAmount,
    uint _daysPerInstallment,
    uint _remainingInstallment,
    string _loanId
  ) public onlyFactoryContract {
    require(_collateralTokenAddress != address(0), "Invalid token address");
    require(_borrowerAddress != address(0), "Invalid lender address");
    require(_lenderAddress != address(0), "Invalid lender address");
    require(_remainingInstallment > 0, "Invalid number of installments");
    require(_borrowAmount > 0, "Borrow amount must not be 0");
    require(_paybackAmount > 0, "Payback amount must not be 0");
    require(_collateralAmount > 0, "Collateral amount must not be 0");
    super._mint(_lenderAddress, 1);
    factoryContract = msg.sender;
    ownerAddress = _ownerAddress;
    loanId = _loanId;
    collateralTokenAddress = _collateralTokenAddress;
    borrowAmount = _borrowAmount;
    collateralAmount = _collateralAmount;
    totalLoanTerm = _remainingInstallment * _daysPerInstallment;
    daysPerInstallment = _daysPerInstallment;
    remainingInstallment = _remainingInstallment;
    installmentAmount = _paybackAmount / _remainingInstallment;
    token = StandardToken(_collateralTokenAddress);
    borrowerAddress = _borrowerAddress;
    lenderAddress = _lenderAddress;

    // initialial state for borrower initiated ERC20 flow
    currentState = States.WaitingForCollateral;
  }

  /**
   * NOT IN USE
   * WHEN FUND IS ETH, CHECK IS DONE IN transferFunds()
   */
  function checkFunds() onlyLender atState(States.WaitingForFunds) public {
    return establishContract();
  }

  /**
   * Check if borrower transferred correct amount of token to this contract
   */
  function checkCollateral() public onlyBorrower atState(States.WaitingForCollateral) {
    uint amount = token.balanceOf(address(this));
    require(amount >= collateralAmount, "Insufficient collateral amount");
    currentState = States.WaitingForFunds;
  }

  /**
   *  Lender transfer ETH to fund this contract
   */
  function transferFunds() public payable onlyLender atState(States.WaitingForFunds) {
    if (address(this).balance >= borrowAmount) {
      establishContract();
    }
  }

  /*
   *  Borrower gets collateral token back when contract completed
   */
  function borrowerCancel() public onlyBorrower atState(States.WaitingForFunds) {
    uint amount = token.balanceOf(address(this));
    token.transfer(borrowerAddress, amount);
    currentState = States.Cancelled;
  }

  /*
   *  Lender gets funds token back when contract is cancelled
   */
  function lenderCancel() public onlyLender atState(States.WaitingForCollateral) {
    // For ETH leader, no way to cancel
    revert();
  }
}

// File: contracts\ERC20ETHLoanLender.sol

pragma solidity ^0.4.23;


/**
 * Collateral: ERC20 Token
 * Borrowed: ETH
 */
contract ERC20ETHLoanLender is ERC20ETHLoan {
  function init (
    address _ownerAddress,
    address _borrowerAddress,
    address _lenderAddress,
    address _collateralTokenAddress,
    uint _borrowAmount,
    uint _paybackAmount,
    uint _collateralAmount,
    uint _daysPerInstallment,
    uint _remainingInstallment,
    string _loanId
  ) public onlyFactoryContract {
    require(_collateralTokenAddress != address(0), "Invalid token address");
    require(_borrowerAddress != address(0), "Invalid lender address");
    require(_lenderAddress != address(0), "Invalid lender address");
    require(_remainingInstallment > 0, "Invalid number of installments");
    require(_borrowAmount > 0, "Borrow amount must not be 0");
    require(_paybackAmount > 0, "Payback amount must not be 0");
    require(_collateralAmount > 0, "Collateral amount must not be 0");
    super._mint(_lenderAddress, 1);
    factoryContract = msg.sender;
    ownerAddress = _ownerAddress;
    loanId = _loanId;
    collateralTokenAddress = _collateralTokenAddress;
    borrowAmount = _borrowAmount;
    collateralAmount = _collateralAmount;
    totalLoanTerm = _remainingInstallment * _daysPerInstallment;
    daysPerInstallment = _daysPerInstallment;
    remainingInstallment = _remainingInstallment;
    installmentAmount = _paybackAmount / _remainingInstallment;
    token = StandardToken(_collateralTokenAddress);
    borrowerAddress = _borrowerAddress;
    lenderAddress = _lenderAddress;

    // initialial state for borrower initiated ERC20 flow
    currentState = States.WaitingForFunds;
  }

  /**
   * Check if borrower transferred correct amount of token to this contract
   */
  function checkCollateral() public onlyBorrower atState(States.WaitingForCollateral) {
    return establishContract();
  }

  /**
   *  Lender transfer ETH to fund this contract
   */
  function transferFunds() public payable onlyLender atState(States.WaitingForFunds) {
    if (address(this).balance >= borrowAmount) {
      currentState = States.WaitingForCollateral;
    }
  }


  /*
   *  Borrower gets collateral token back when contract completed
   */
  function borrowerCancel() public onlyBorrower atState(States.WaitingForFunds) {
    revert();
  }

  /*
   *  Lender gets funds token back when contract is cancelled
   */
  function lenderCancel() public onlyLender atState(States.WaitingForCollateral) {
    lenderAddress.transfer(address(this).balance);
    currentState = States.Cancelled;
  }
}

// File: contracts\ETHERC20Loan.sol

pragma solidity ^0.4.23;


/**
 * Collateral: ETH
 * Borrowed: ERC20 Token
 */
contract ETHERC20Loan is DefinerBasicLoan {

  StandardToken token;
  address public borrowedTokenAddress;

  function establishContract() public {

    // ERC20 as collateral
    uint amount = token.balanceOf(address(this));
    require(amount >= collateralAmount, "Insufficient collateral amount");

    // Ether as Fund
    require(address(this).balance >= borrowAmount, "Insufficient fund amount");

    // Transit to Funded state
    transferETHToBorrowerAndStartLoan();
  }

  /*
   *  Borrower pay back ERC20 Token
   */
  function borrowerMakePayment() public payable onlyBorrower atState(States.Funded) notDefault {
    require(remainingInstallment > 0, "No remaining installments");
    require(installmentAmount > 0, "Installment amount must be non zero");
    token.transfer(lenderAddress, installmentAmount);
    remainingInstallment--;
    if (remainingInstallment == 0) {
      currentState = States.Finished;
    } else {
      nextPaymentDateTime = nextPaymentDateTime.add(daysPerInstallment.mul(1 days));
    }
  }

  /*
   *  Borrower gets collateral ETH back when contract completed
   */
  function borrowerReclaimCollateral() public onlyBorrower atState(States.Finished) {
    borrowerAddress.transfer(address(this).balance);
    currentState = States.Closed;
  }

  /*
   *  Lender gets collateral ETH when contract defaulted
   */
  function lenderReclaimCollateral() public onlyLender atState(States.Default) {
    lenderAddress.transfer(address(this).balance);
    currentState = States.Closed;
  }
}

// File: contracts\ETHERC20LoanBorrower.sol

pragma solidity ^0.4.23;


/**
 * Collateral: ETH
 * Borrowed: ERC20 Token
 */
contract ETHERC20LoanBorrower is ETHERC20Loan {
  function init (
    address _ownerAddress,
    address _borrowerAddress,
    address _lenderAddress,
    address _borrowedTokenAddress,
    uint _borrowAmount,
    uint _paybackAmount,
    uint _collateralAmount,
    uint _daysPerInstallment,
    uint _remainingInstallment,
    string _loanId
  ) public onlyFactoryContract {
    require(_borrowedTokenAddress != address(0), "Invalid token address");
    require(_borrowerAddress != address(0), "Invalid lender address");
    require(_lenderAddress != address(0), "Invalid lender address");
    require(_remainingInstallment > 0, "Invalid number of installments");
    require(_borrowAmount > 0, "Borrow amount must not be 0");
    require(_paybackAmount > 0, "Payback amount must not be 0");
    require(_collateralAmount > 0, "Collateral amount must not be 0");
    super._mint(_lenderAddress, 1);
    factoryContract = msg.sender;
    ownerAddress = _ownerAddress;
    loanId = _loanId;
    borrowedTokenAddress = _borrowedTokenAddress;
    borrowAmount = _borrowAmount;
    collateralAmount = _collateralAmount;
    totalLoanTerm = _remainingInstallment * _daysPerInstallment;
    daysPerInstallment = _daysPerInstallment;
    remainingInstallment = _remainingInstallment;
    installmentAmount = _paybackAmount / _remainingInstallment;
    token = StandardToken(_borrowedTokenAddress);
    borrowerAddress = _borrowerAddress;
    lenderAddress = _lenderAddress;

    currentState = States.WaitingForCollateral;
  }

  /**
   * Borrower transfer ETH to contract
   */
  function transferCollateral() public payable atState(States.WaitingForCollateral) {
    if (address(this).balance >= collateralAmount) {
      currentState = States.WaitingForFunds;
    }
  }

  /**
   *
   */
  function checkFunds() public onlyLender atState(States.WaitingForFunds) {
    uint amount = token.balanceOf(address(this));
    require(amount >= borrowAmount, "Insufficient borrowed amount");
    transferTokenToBorrowerAndStartLoan(token);
  }

  /**
   * NOT IN USE
   * WHEN COLLATERAL IS ETH, CHECK IS DONE IN transferCollateral()
   */
  function checkCollateral() public {
    revert();
  }

  /**
   * NOT IN USE
   * WHEN FUND IS TOKEN, TRANSFER IS DONE IN FRONT END
   */
  function transferFunds() public payable {
    revert();
  }

  /*
 *  Borrower gets collateral ETH back when contract completed
 */
  function borrowerCancel() public onlyBorrower atState(States.WaitingForFunds) {
    borrowerAddress.transfer(address(this).balance);
    currentState = States.Cancelled;
  }

  /*
*  Borrower gets collateral ETH back when contract completed
*/
  function lenderCancel() public onlyLender atState(States.WaitingForCollateral) {
    revert();
  }
}

// File: contracts\ETHERC20LoanLender.sol

pragma solidity ^0.4.23;


/**
 * Collateral: ETH
 * Borrowed: ERC20 Token
 */
contract ETHERC20LoanLender is ETHERC20Loan {

  function init (
    address _ownerAddress,
    address _borrowerAddress,
    address _lenderAddress,
    address _borrowedTokenAddress,
    uint _borrowAmount,
    uint _paybackAmount,
    uint _collateralAmount,
    uint _daysPerInstallment,
    uint _remainingInstallment,
    string _loanId
  ) public onlyFactoryContract {
    require(_borrowedTokenAddress != address(0), "Invalid token address");
    require(_borrowerAddress != address(0), "Invalid lender address");
    require(_lenderAddress != address(0), "Invalid lender address");
    require(_remainingInstallment > 0, "Invalid number of installments");
    require(_borrowAmount > 0, "Borrow amount must not be 0");
    require(_paybackAmount > 0, "Payback amount must not be 0");
    require(_collateralAmount > 0, "Collateral amount must not be 0");
    super._mint(_lenderAddress, 1);
    factoryContract = msg.sender;
    ownerAddress = _ownerAddress;
    loanId = _loanId;
    borrowedTokenAddress = _borrowedTokenAddress;
    borrowAmount = _borrowAmount;
    collateralAmount = _collateralAmount;
    totalLoanTerm = _remainingInstallment * _daysPerInstallment;
    daysPerInstallment = _daysPerInstallment;
    remainingInstallment = _remainingInstallment;
    installmentAmount = _paybackAmount / _remainingInstallment;
    token = StandardToken(_borrowedTokenAddress);
    borrowerAddress = _borrowerAddress;
    lenderAddress = _lenderAddress;

    currentState = States.WaitingForFunds;
  }

  /**
   * Borrower transfer ETH to contract
   */
  function transferCollateral() public payable atState(States.WaitingForCollateral) {
    require(address(this).balance >= collateralAmount, "Insufficient ETH collateral amount");
    transferTokenToBorrowerAndStartLoan(token);
  }

  /**
   *
   */
  function checkFunds() public onlyLender atState(States.WaitingForFunds) {
    uint amount = token.balanceOf(address(this));
    require(amount >= borrowAmount, "Insufficient fund amount");
    currentState = States.WaitingForCollateral;
  }

  /**
   * NOT IN USE
   * WHEN COLLATERAL IS ETH, CHECK IS DONE IN transferCollateral()
   */
  function checkCollateral() public {
    revert();
  }

  /**
   * NOT IN USE
   * WHEN FUND IS TOKEN, TRANSFER IS DONE IN FRONT END
   */
  function transferFunds() public payable {
    revert();
  }

  /*
 *  Borrower gets collateral ETH back when contract completed
 */
  function borrowerCancel() public onlyBorrower atState(States.WaitingForFunds) {
    revert();
  }

  /*
*  Borrower gets collateral ETH back when contract completed
*/
  function lenderCancel() public onlyLender atState(States.WaitingForCollateral) {
    uint amount = token.balanceOf(address(this));
    token.transfer(lenderAddress, amount);
    currentState = States.Cancelled;
  }
}

// File: contracts\ERC20ERC20Loan.sol

pragma solidity ^0.4.23;


/**
 * Collateral: ERC20 Token
 * Borrowed: ERC20 Token
 */
contract ERC20ERC20Loan is DefinerBasicLoan {

  StandardToken collateralToken;
  StandardToken borrowedToken;
  address public collateralTokenAddress;
  address public borrowedTokenAddress;

  /*
   *  Borrower pay back Token
   */
  function borrowerMakePayment() public payable onlyBorrower atState(States.Funded) notDefault {
    require(remainingInstallment > 0, "No remaining installments");
    require(installmentAmount > 0, "Installment amount must be non zero");
    borrowedToken.transfer(lenderAddress, installmentAmount);
    remainingInstallment--;
    if (remainingInstallment == 0) {
      currentState = States.Finished;
    } else {
      nextPaymentDateTime = nextPaymentDateTime.add(daysPerInstallment.mul(1 days));
    }
  }

  /*
   *  Borrower gets collateral token back when contract completed
   */
  function borrowerReclaimCollateral() public onlyBorrower atState(States.Finished) {
    uint amount = collateralToken.balanceOf(address(this));
    collateralToken.transfer(borrowerAddress, amount);
    currentState = States.Closed;
  }

  /*
   *  Lender gets collateral token when contract defaulted
   */
  function lenderReclaimCollateral() public onlyLender atState(States.Default) {
    uint amount = collateralToken.balanceOf(address(this));
    collateralToken.transfer(lenderAddress, amount);
    currentState = States.Closed;
  }
}

// File: contracts\ERC20ERC20LoanBorrower.sol

pragma solidity ^0.4.23;


/**
 * Collateral: ERC20 Token
 * Borrowed: ERC20 Token
 */
contract ERC20ERC20LoanBorrower is ERC20ERC20Loan {

  function init (
    address _ownerAddress,
    address _borrowerAddress,
    address _lenderAddress,
    address _collateralTokenAddress,
    address _borrowedTokenAddress,
    uint _borrowAmount,
    uint _paybackAmount,
    uint _collateralAmount,
    uint _daysPerInstallment,
    uint _remainingInstallment,
    string _loanId
  ) public onlyFactoryContract {
    require(_collateralTokenAddress != _borrowedTokenAddress);
    require(_collateralTokenAddress != address(0), "Invalid token address");
    require(_borrowedTokenAddress != address(0), "Invalid token address");
    require(_borrowerAddress != address(0), "Invalid lender address");
    require(_lenderAddress != address(0), "Invalid lender address");
    require(_remainingInstallment > 0, "Invalid number of installments");
    require(_borrowAmount > 0, "Borrow amount must not be 0");
    require(_paybackAmount > 0, "Payback amount must not be 0");
    require(_collateralAmount > 0, "Collateral amount must not be 0");
    super._mint(_lenderAddress, 1);
    factoryContract = msg.sender;
    ownerAddress = _ownerAddress;
    loanId = _loanId;
    collateralTokenAddress = _collateralTokenAddress;
    borrowedTokenAddress = _borrowedTokenAddress;
    borrowAmount = _borrowAmount;
    collateralAmount = _collateralAmount;
    totalLoanTerm = _remainingInstallment * _daysPerInstallment;
    daysPerInstallment = _daysPerInstallment;
    remainingInstallment = _remainingInstallment;
    installmentAmount = _paybackAmount / _remainingInstallment;
    collateralToken = StandardToken(_collateralTokenAddress);
    borrowedToken = StandardToken(_borrowedTokenAddress);

    borrowerAddress = _borrowerAddress;
    lenderAddress = _lenderAddress;
    currentState = States.WaitingForCollateral;
  }

  /**
   * NOT IN USE
   * WHEN COLLATERAL IS TOKEN, TRANSFER IS DONE IN FRONT END
   */
  function transferCollateral() public payable {
    revert();
  }

  /**
   * NOT IN USE
   * WHEN FUND IS TOKEN, TRANSFER IS DONE IN FRONT END
   */
  function transferFunds() public payable {
    revert();
  }

  /**
   *
   */
  function checkFunds() public onlyLender atState(States.WaitingForFunds) {
    uint amount = borrowedToken.balanceOf(address(this));
    require(amount >= borrowAmount, "Insufficient borrowed amount");
    transferTokenToBorrowerAndStartLoan(borrowedToken);
  }

  /**
   * Check if borrower transferred correct amount of token to this contract
   */
  function checkCollateral() public onlyBorrower atState(States.WaitingForCollateral) {
    uint amount = collateralToken.balanceOf(address(this));
    require(amount >= collateralAmount, "Insufficient Collateral Token amount");
    currentState = States.WaitingForFunds;
  }

  /*
   *  Borrower gets collateral token back when contract cancelled
   */
  function borrowerCancel() public onlyBorrower atState(States.WaitingForFunds) {
    uint amount = collateralToken.balanceOf(address(this));
    collateralToken.transfer(borrowerAddress, amount);
    currentState = States.Cancelled;
  }

  /*
   *  Lender gets fund token back when contract cancelled
   */
  function lenderCancel() public onlyLender atState(States.WaitingForCollateral) {
    revert();
  }
}

// File: contracts\ERC20ERC20LoanLender.sol

pragma solidity ^0.4.23;


/**
 * Collateral: ERC20 Token
 * Borrowed: ERC20 Token
 */
contract ERC20ERC20LoanLender is ERC20ERC20Loan {

  function init (
    address _ownerAddress,
    address _borrowerAddress,
    address _lenderAddress,
    address _collateralTokenAddress,
    address _borrowedTokenAddress,
    uint _borrowAmount,
    uint _paybackAmount,
    uint _collateralAmount,
    uint _daysPerInstallment,
    uint _remainingInstallment,
    string _loanId
  ) public onlyFactoryContract {
    require(_collateralTokenAddress != _borrowedTokenAddress);
    require(_collateralTokenAddress != address(0), "Invalid token address");
    require(_borrowedTokenAddress != address(0), "Invalid token address");
    require(_borrowerAddress != address(0), "Invalid lender address");
    require(_lenderAddress != address(0), "Invalid lender address");
    require(_remainingInstallment > 0, "Invalid number of installments");
    require(_borrowAmount > 0, "Borrow amount must not be 0");
    require(_paybackAmount > 0, "Payback amount must not be 0");
    require(_collateralAmount > 0, "Collateral amount must not be 0");
    super._mint(_lenderAddress, 1);
    factoryContract = msg.sender;
    ownerAddress = _ownerAddress;
    loanId = _loanId;
    collateralTokenAddress = _collateralTokenAddress;
    borrowedTokenAddress = _borrowedTokenAddress;
    borrowAmount = _borrowAmount;
    collateralAmount = _collateralAmount;
    totalLoanTerm = _remainingInstallment * _daysPerInstallment;
    daysPerInstallment = _daysPerInstallment;
    remainingInstallment = _remainingInstallment;
    installmentAmount = _paybackAmount / _remainingInstallment;
    collateralToken = StandardToken(_collateralTokenAddress);
    borrowedToken = StandardToken(_borrowedTokenAddress);

    borrowerAddress = _borrowerAddress;
    lenderAddress = _lenderAddress;
    currentState = States.WaitingForFunds;
  }

  /**
   * NOT IN USE
   * WHEN COLLATERAL IS TOKEN, TRANSFER IS DONE IN FRONT END
   */
  function transferCollateral() public payable {
    revert();
  }

  /**
   * NOT IN USE
   * WHEN FUND IS TOKEN, TRANSFER IS DONE IN FRONT END
   */
  function transferFunds() public payable {
    revert();
  }

  /**
   *
   */
  function checkFunds() public onlyLender atState(States.WaitingForFunds) {
    uint amount = borrowedToken.balanceOf(address(this));
    require(amount >= borrowAmount, "Insufficient fund amount");
    currentState = States.WaitingForCollateral;
  }

  /**
   * Check if borrower transferred correct amount of token to this contract
   */
  function checkCollateral() public onlyBorrower atState(States.WaitingForCollateral) {
    uint amount = collateralToken.balanceOf(address(this));
    require(amount >= collateralAmount, "Insufficient Collateral Token amount");
    transferTokenToBorrowerAndStartLoan(borrowedToken);
  }

  /*
   *  Borrower gets collateral token back when contract cancelled
   */
  function borrowerCancel() public onlyBorrower atState(States.WaitingForFunds) {
    revert();
  }

  /*
   *  Lender gets fund token back when contract cancelled
   */
  function lenderCancel() public onlyLender atState(States.WaitingForCollateral) {
    uint amount = borrowedToken.balanceOf(address(this));
    borrowedToken.transfer(lenderAddress, amount);
    currentState = States.Cancelled;
  }
}

// File: contracts\DefinerLoanFactory.sol

pragma solidity ^0.4.23;







library Library {
  struct contractAddress {
    address value;
    bool exists;
  }
}

contract CloneFactory {
  event CloneCreated(address indexed target, address clone);

  function createClone(address target) internal returns (address result) {
    bytes memory clone = hex"3d602d80600a3d3981f3363d3d373d3d3d363d73bebebebebebebebebebebebebebebebebebebebe5af43d82803e903d91602b57fd5bf3";
    bytes20 targetBytes = bytes20(target);
    for (uint i = 0; i < 20; i++) {
      clone[20 + i] = targetBytes[i];
    }
    assembly {
      let len := mload(clone)
      let data := add(clone, 0x20)
      result := create(0, data, len)
    }
  }
}

contract DefinerLoanFactory is CloneFactory {

  using Library for Library.contractAddress;

  address public owner = msg.sender;
  address public ERC20ETHLoanBorrowerMasterContractAddress;
  address public ERC20ETHLoanLenderMasterContractAddress;

  address public ETHERC20LoanBorrowerMasterContractAddress;
  address public ETHERC20LoanLenderMasterContractAddress;

  address public ERC20ERC20LoanBorrowerMasterContractAddress;
  address public ERC20ERC20LoanLenderMasterContractAddress;

  mapping(address => address[]) contractMap;
  mapping(string => Library.contractAddress) contractById;

  modifier onlyOwner() {
    require(msg.sender == owner, "Invalid Owner Address");
    _;
  }

  constructor (
    address _ERC20ETHLoanBorrowerMasterContractAddress,
    address _ERC20ETHLoanLenderMasterContractAddress,
    address _ETHERC20LoanBorrowerMasterContractAddress,
    address _ETHERC20LoanLenderMasterContractAddress,
    address _ERC20ERC20LoanBorrowerMasterContractAddress,
    address _ERC20ERC20LoanLenderMasterContractAddress
  ) public {
    owner = msg.sender;
    ERC20ETHLoanBorrowerMasterContractAddress = _ERC20ETHLoanBorrowerMasterContractAddress;
    ERC20ETHLoanLenderMasterContractAddress = _ERC20ETHLoanLenderMasterContractAddress;
    ETHERC20LoanBorrowerMasterContractAddress = _ETHERC20LoanBorrowerMasterContractAddress;
    ETHERC20LoanLenderMasterContractAddress = _ETHERC20LoanLenderMasterContractAddress;
    ERC20ERC20LoanBorrowerMasterContractAddress = _ERC20ERC20LoanBorrowerMasterContractAddress;
    ERC20ERC20LoanLenderMasterContractAddress = _ERC20ERC20LoanLenderMasterContractAddress;
  }

  function getUserContracts(address userAddress) public view returns (address[]) {
    return contractMap[userAddress];
  }

  function getContractByLoanId(string _loanId) public view returns (address) {
    return contractById[_loanId].value;
  }

  function createERC20ETHLoanBorrowerClone(
    address _collateralTokenAddress,
    uint _borrowAmount,
    uint _paybackAmount,
    uint _collateralAmount,
    uint _daysPerInstallment,
    uint _remainingInstallment,
    string _loanId,
    address _lenderAddress
  ) public payable returns (address) {
    require(!contractById[_loanId].exists, "contract already exists");

    address clone = createClone(ERC20ETHLoanBorrowerMasterContractAddress);
    ERC20ETHLoanBorrower(clone).init({
      _ownerAddress : owner,
      _borrowerAddress : msg.sender,
      _lenderAddress : _lenderAddress,
      _collateralTokenAddress : _collateralTokenAddress,
      _borrowAmount : _borrowAmount,
      _paybackAmount : _paybackAmount,
      _collateralAmount : _collateralAmount,
      _daysPerInstallment : _daysPerInstallment,
      _remainingInstallment : _remainingInstallment,
      _loanId : _loanId});

    contractMap[msg.sender].push(clone);
    contractById[_loanId] = Library.contractAddress(clone, true);
    return clone;
  }


  function createERC20ETHLoanLenderClone(
    address _collateralTokenAddress,
    uint _borrowAmount,
    uint _paybackAmount,
    uint _collateralAmount,
    uint _daysPerInstallment,
    uint _remainingInstallment,
    string _loanId,
    address _borrowerAddress
  ) public payable returns (address) {
    require(!contractById[_loanId].exists, "contract already exists");

    address clone = createClone(ERC20ETHLoanLenderMasterContractAddress);
    ERC20ETHLoanLender(clone).init({
      _ownerAddress : owner,
      _borrowerAddress : _borrowerAddress,
      _lenderAddress : msg.sender,
      _collateralTokenAddress : _collateralTokenAddress,
      _borrowAmount : _borrowAmount,
      _paybackAmount : _paybackAmount,
      _collateralAmount : _collateralAmount,
      _daysPerInstallment : _daysPerInstallment,
      _remainingInstallment : _remainingInstallment,
      _loanId : _loanId});

    if (msg.value > 0) {
      ERC20ETHLoanLender(clone).transferFunds.value(msg.value)();
    }
    contractMap[msg.sender].push(clone);
    contractById[_loanId] = Library.contractAddress(clone, true);
    return clone;
  }

  function createETHERC20LoanBorrowerClone(
    address _borrowedTokenAddress,
    uint _borrowAmount,
    uint _paybackAmount,
    uint _collateralAmount,
    uint _daysPerInstallment,
    uint _remainingInstallment,
    string _loanId,
    address _lenderAddress
  ) public payable returns (address) {
    require(!contractById[_loanId].exists, "contract already exists");

    address clone = createClone(ETHERC20LoanBorrowerMasterContractAddress);
    ETHERC20LoanBorrower(clone).init({
      _ownerAddress : owner,
      _borrowerAddress : msg.sender,
      _lenderAddress : _lenderAddress,
      _borrowedTokenAddress : _borrowedTokenAddress,
      _borrowAmount : _borrowAmount,
      _paybackAmount : _paybackAmount,
      _collateralAmount : _collateralAmount,
      _daysPerInstallment : _daysPerInstallment,
      _remainingInstallment : _remainingInstallment,
      _loanId : _loanId});

    if (msg.value >= _collateralAmount) {
      ETHERC20LoanBorrower(clone).transferCollateral.value(msg.value)();
    }

    contractMap[msg.sender].push(clone);
    contractById[_loanId] = Library.contractAddress(clone, true);
    return clone;
  }

  function createETHERC20LoanLenderClone(
    address _borrowedTokenAddress,
    uint _borrowAmount,
    uint _paybackAmount,
    uint _collateralAmount,
    uint _daysPerInstallment,
    uint _remainingInstallment,
    string _loanId,
    address _borrowerAddress
  ) public payable returns (address) {
    require(!contractById[_loanId].exists, "contract already exists");

    address clone = createClone(ETHERC20LoanLenderMasterContractAddress);
    ETHERC20LoanLender(clone).init({
      _ownerAddress : owner,
      _borrowerAddress : _borrowerAddress,
      _lenderAddress : msg.sender,
      _borrowedTokenAddress : _borrowedTokenAddress,
      _borrowAmount : _borrowAmount,
      _paybackAmount : _paybackAmount,
      _collateralAmount : _collateralAmount,
      _daysPerInstallment : _daysPerInstallment,
      _remainingInstallment : _remainingInstallment,
      _loanId : _loanId});

    contractMap[msg.sender].push(clone);
    contractById[_loanId] = Library.contractAddress(clone, true);
    return clone;
  }

  function createERC20ERC20LoanBorrowerClone(
    address _collateralTokenAddress,
    address _borrowedTokenAddress,
    uint _borrowAmount,
    uint _paybackAmount,
    uint _collateralAmount,
    uint _daysPerInstallment,
    uint _remainingInstallment,
    string _loanId,
    address _lenderAddress
  ) public returns (address) {
    require(!contractById[_loanId].exists, "contract already exists");

    address clone = createClone(ERC20ERC20LoanBorrowerMasterContractAddress);
    ERC20ERC20LoanBorrower(clone).init({
      _ownerAddress : owner,
      _borrowerAddress : msg.sender,
      _lenderAddress : _lenderAddress,
      _collateralTokenAddress : _collateralTokenAddress,
      _borrowedTokenAddress : _borrowedTokenAddress,
      _borrowAmount : _borrowAmount,
      _paybackAmount : _paybackAmount,
      _collateralAmount : _collateralAmount,
      _daysPerInstallment : _daysPerInstallment,
      _remainingInstallment : _remainingInstallment,
      _loanId : _loanId});
    contractMap[msg.sender].push(clone);
    contractById[_loanId] = Library.contractAddress(clone, true);
    return clone;
  }

  function createERC20ERC20LoanLenderClone(
    address _collateralTokenAddress,
    address _borrowedTokenAddress,
    uint _borrowAmount,
    uint _paybackAmount,
    uint _collateralAmount,
    uint _daysPerInstallment,
    uint _remainingInstallment,
    string _loanId,
    address _borrowerAddress
  ) public returns (address) {
    require(!contractById[_loanId].exists, "contract already exists");

    address clone = createClone(ERC20ERC20LoanLenderMasterContractAddress);
    ERC20ERC20LoanLender(clone).init({
      _ownerAddress : owner,
      _borrowerAddress : _borrowerAddress,
      _lenderAddress : msg.sender,
      _collateralTokenAddress : _collateralTokenAddress,
      _borrowedTokenAddress : _borrowedTokenAddress,
      _borrowAmount : _borrowAmount,
      _paybackAmount : _paybackAmount,
      _collateralAmount : _collateralAmount,
      _daysPerInstallment : _daysPerInstallment,
      _remainingInstallment : _remainingInstallment,
      _loanId : _loanId});
    contractMap[msg.sender].push(clone);
    contractById[_loanId] = Library.contractAddress(clone, true);
    return clone;
  }

  function changeOwner(address newOwner) public onlyOwner {
    owner = newOwner;
  }
}