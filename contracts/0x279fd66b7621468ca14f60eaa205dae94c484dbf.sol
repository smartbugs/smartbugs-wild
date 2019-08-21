pragma solidity ^0.4.15;

/* @dev ERC Token Standard #20 Interface (https://github.com/ethereum/EIPs/issues/20)
*/
contract ERC20 {
    //Use original ERC20 totalSupply function instead of public variable since
    //we are mapping the functions for upgradeability
    uint256 public totalSupply;
    function balanceOf(address _owner) public constant returns (uint256 balance);
    function transfer(address _to, uint256 _value) public returns (bool success);
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);
    function approve(address _spender, uint256 _value) public returns (bool success);
    function allowance(address _owner, address _spender) public constant returns (uint256 remaining);
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}
// Licensed under the MIT License
// Copyright (c) 2017 Curvegrid Inc.


/// @title OfflineSecret
/// @dev The OfflineSecret contract provide functionality to verify and ensure a caller
/// provides a valid secret that was exchanged offline. It offers an additional level of verification
/// for sensitive contract operations.
contract OfflineSecret {

    /// @dev Modifier that requires a provided plaintext match a previously stored hash
    modifier validSecret(address to, string secret, bytes32 hashed) {
        require(checkSecret(to, secret, hashed));
        _;
    }

    /// @dev Generate a hash from the provided plaintext. A pure function so can (should) be
    /// run off-chain.
    /// @param to address The recipient address, as a salt.
    /// @param secret string The secret to hash.
    function generateHash(address to, string secret) public pure returns(bytes32 hashed) {
        return keccak256(to, secret);
    }

    /// @dev Check whether a provided plaintext secret hashes to a provided hash. A pure 
    /// function so can (should) be run off-chain.
    /// @param to address The recipient address, as a salt.
    /// @param secret string The secret to hash.
    /// @param hashed string The hash to check the secret against.
    function checkSecret(address to, string secret, bytes32 hashed) public pure returns(bool valid) {
        if (hashed == keccak256(to, secret)) {
            return true;
        }

        return false;
    }
}
// Licensed under the MIT License
// Copyright (c) 2017 Curvegrid Inc.



/// @title Ownable
/// @dev The Ownable contract has an owner address, and provides basic authorization control functions, this simplifies
/// and the implementation of "user permissions".
contract OwnableWithFoundation is OfflineSecret {
    address public owner;
    address public newOwnerCandidate;
    address public foundation;
    address public newFoundationCandidate;

    bytes32 public ownerHashed;
    bytes32 public foundationHashed;

    event OwnershipRequested(address indexed by, address indexed to, bytes32 hashed);
    event OwnershipTransferred(address indexed from, address indexed to);
    event FoundationRequested(address indexed by, address indexed to, bytes32 hashed);
    event FoundationTransferred(address indexed from, address indexed to);

    /// @dev The Ownable constructor sets the original `owner` of the contract to the sender
    /// account.
    function OwnableWithFoundation(address _owner) public {
        foundation = msg.sender;
        owner = _owner;
    }

    /// @dev Reverts if called by any account other than the owner.
    modifier onlyOwner() {
        if (msg.sender != owner) {
            revert();
        }

        _;
    }

    modifier onlyOwnerCandidate() {
        if (msg.sender != newOwnerCandidate) {
            revert();
        }

        _;
    }

    /// @dev Reverts if called by any account other than the foundation.
    modifier onlyFoundation() {
        if (msg.sender != foundation) {
            revert();
        }

        _;
    }

    modifier onlyFoundationCandidate() {
        if (msg.sender != newFoundationCandidate) {
            revert();
        }

        _;
    }

    /// @dev Proposes to transfer control of the contract to a newOwnerCandidate.
    /// @param _newOwnerCandidate address The address to transfer ownership to.
    /// @param _ownerHashed string The hashed secret to use as protection.
    function requestOwnershipTransfer(
        address _newOwnerCandidate, 
        bytes32 _ownerHashed) 
        external 
        onlyFoundation
    {
        require(_newOwnerCandidate != address(0));
        require(_newOwnerCandidate != owner);

        newOwnerCandidate = _newOwnerCandidate;
        ownerHashed = _ownerHashed;

        OwnershipRequested(msg.sender, newOwnerCandidate, ownerHashed);
    }

    /// @dev Accept ownership transfer. This method needs to be called by the previously proposed owner.
    /// @param _ownerSecret string The secret to check against the hash.
    function acceptOwnership(
        string _ownerSecret) 
        external 
        onlyOwnerCandidate 
        validSecret(newOwnerCandidate, _ownerSecret, ownerHashed)
    {
        address previousOwner = owner;

        owner = newOwnerCandidate;
        newOwnerCandidate = address(0);

        OwnershipTransferred(previousOwner, owner);
    }

    /// @dev Proposes to transfer control of the contract to a newFoundationCandidate.
    /// @param _newFoundationCandidate address The address to transfer oversight to.
    /// @param _foundationHashed string The hashed secret to use as protection.
    function requestFoundationTransfer(
        address _newFoundationCandidate, 
        bytes32 _foundationHashed) 
        external 
        onlyFoundation 
    {
        require(_newFoundationCandidate != address(0));
        require(_newFoundationCandidate != foundation);

        newFoundationCandidate = _newFoundationCandidate;
        foundationHashed = _foundationHashed;

        FoundationRequested(msg.sender, newFoundationCandidate, foundationHashed);
    }

    /// @dev Accept foundation transfer. This method needs to be called by the previously proposed foundation.
    /// @param _foundationSecret string The secret to check against the hash.
    function acceptFoundation(
        string _foundationSecret) 
        external 
        onlyFoundationCandidate 
        validSecret(newFoundationCandidate, _foundationSecret, foundationHashed)
    {
        address previousFoundation = foundation;

        foundation = newFoundationCandidate;
        newFoundationCandidate = address(0);

        FoundationTransferred(previousFoundation, foundation);
    }
}

/* @dev Math operations with safety checks
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

    function max64(uint64 a, uint64 b) internal pure returns (uint64) {
        return a >= b ? a : b;
    }

    function min64(uint64 a, uint64 b) internal pure returns (uint64) {
        return a < b ? a : b;
    }

    function max256(uint256 a, uint256 b) internal pure returns (uint256) {
        return a >= b ? a : b;
    }

    function min256(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }
}
// Licensed under the MIT License
// Copyright (c) 2017 Curvegrid Inc.



/**
 * @title Pausable
 * @dev Base contract which allows children to implement an emergency stop mechanism.
 */
contract Pausable is OwnableWithFoundation {
  event Pause();
  event Unpause();

  bool public paused = false;

  function Pausable(address _owner) public OwnableWithFoundation(_owner) {
  }

  /**
   * @dev Modifier to make a function callable only when the contract is not paused.
   */
  modifier whenNotPaused() {
    require(!paused);
    _;
  }

  /**
   * @dev Modifier to make a function callable only when the contract is paused.
   */
  modifier whenPaused() {
    require(paused);
    _;
  }

  /**
   * @dev called by the owner to pause, triggers stopped state
   */
  function pause() onlyOwner whenNotPaused public {
    paused = true;
    Pause();
  }

  /**
   * @dev called by the owner to unpause, returns to normal state
   */
  function unpause() onlyOwner whenPaused public {
    paused = false;
    Unpause();
  }
}


/// @title Basic ERC20 token contract implementation.
/* @dev Kin's BasicToken based on OpenZeppelin's StandardToken.
*/

contract BasicToken is ERC20 {
    using SafeMath for uint256;

    uint256 public totalSupply;
    mapping (address => mapping (address => uint256)) allowed;
    mapping (address => uint256) balances;

    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Transfer(address indexed from, address indexed to, uint256 value);

    /// @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.
    /// @param _spender address The address which will spend the funds.
    /// @param _value uint256 The amount of tokens to be spent.
    function approve(address _spender, uint256 _value) public returns (bool) {
        // https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
        if ((_value != 0) && (allowed[msg.sender][_spender] != 0)) {
            revert();
        }

        allowed[msg.sender][_spender] = _value;

        Approval(msg.sender, _spender, _value);

        return true;
    }

    /// @dev Function to check the amount of tokens that an owner allowed to a spender.
    /// @param _owner address The address which owns the funds.
    /// @param _spender address The address which will spend the funds.
    /// @return uint256 specifying the amount of tokens still available for the spender.
    function allowance(address _owner, address _spender) public constant returns (uint256 remaining) {
        return allowed[_owner][_spender];
    }


    /// @dev Gets the balance of the specified address.
    /// @param _owner address The address to query the the balance of.
    /// @return uint256 representing the amount owned by the passed address.
    function balanceOf(address _owner) public constant returns (uint256 balance) {
        return balances[_owner];
    }

    /// @dev transfer token to a specified address.
    /// @param _to address The address to transfer to.
    /// @param _value uint256 The amount to be transferred.
    function transfer(address _to, uint256 _value) public returns (bool) {
        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);

        Transfer(msg.sender, _to, _value);

        return true;
    }

    /// @dev Transfer tokens from one address to another.
    /// @param _from address The address which you want to send tokens from.
    /// @param _to address The address which you want to transfer to.
    /// @param _value uint256 the amount of tokens to be transferred.
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
        uint256 _allowance = allowed[_from][msg.sender];

        balances[_from] = balances[_from].sub(_value);
        balances[_to] = balances[_to].add(_value);

        allowed[_from][msg.sender] = _allowance.sub(_value);

        Transfer(_from, _to, _value);

        return true;
    }
}
// Licensed under the MIT License
// Copyright (c) 2017 Curvegrid Inc.



/**
 * @dev ERC Token Standard #20 Interface (https://github.com/ethereum/EIPs/issues/20)
 *      D1Coin is the main contract for the D1 platform.
 */
contract D1Coin is BasicToken, Pausable {
    using SafeMath for uint256;

    string public constant name = "D1 Coin";
    string public constant symbol = "D1";

    // Thousands of a token represent the minimum usable unit of token based on
    // its expected value
    uint8 public constant decimals = 3;

    address theCoin = address(this);

    // Hashed secrets required to unlock coins transferred from one address to another address
    struct ProtectedBalanceStruct {
        uint256 balance;
        bytes32 hashed;
    }
    mapping (address => mapping (address => ProtectedBalanceStruct)) protectedBalances;
    uint256 public protectedSupply;

    // constructor passes owner (Mint) down to Pausable() => OwnableWithFoundation()
    function D1Coin(address _owner) public Pausable(_owner) {
    }

    event Mint(address indexed minter, address indexed receiver, uint256 value);
    event ProtectedTransfer(address indexed from, address indexed to, uint256 value, bytes32 hashed);
    event ProtectedUnlock(address indexed from, address indexed to, uint256 value);
    event ProtectedReclaim(address indexed from, address indexed to, uint256 value);
    event Burn(address indexed burner, uint256 value);

    /// @dev Transfer token to this contract, which is shorthand for the owner (Mint). 
    /// Avoids race conditions in cases where the owner has changed just before a 
    /// transfer is called.
    /// @param _value uint256 The amount to be transferred.
    function transferToMint(uint256 _value) external whenNotPaused returns (bool) {
        return transfer(theCoin, _value);
    }

    /// @dev Approve this contract, proxy for owner (Mint), to spend the specified amount of tokens 
    /// on behalf of msg.sender. Avoids race conditions in cases where the owner has changed 
    /// just before an approve is called.
    /// @param _value uint256 The amount of tokens to be spent.
    function approveToMint(uint256 _value) external whenNotPaused returns (bool) {
        return approve(theCoin, _value);
    }

    /// @dev Protected transfer tokens to this contract, which is shorthand for the owner (Mint). 
    /// Avoids race conditions in cases where the owner has changed just before a 
    /// transfer is called.
    /// @param _value uint256 The amount to be transferred.
    /// @param _hashed string The hashed secret to use as protection.
    function protectedTransferToMint(uint256 _value, bytes32 _hashed) external whenNotPaused returns (bool) {
        return protectedTransfer(theCoin, _value, _hashed);
    }

    /// @dev Transfer tokens from an address to this contract, a proxy for the owner (Mint).
    /// Subject to pre-approval from the address. Avoids race conditions in cases where the owner has changed 
    /// just before an approve is called.
    /// @param _from address The address which you want to send tokens from.
    /// @param _value uint256 the amount of tokens to be transferred.
    function withdrawByMint(address _from, uint256 _value) external onlyOwner whenNotPaused returns (bool) {
        // retrieve allowance
        uint256 _allowance = allowed[_from][theCoin];

        // adjust balances
        balances[_from] = balances[_from].sub(_value);
        balances[theCoin] = balances[theCoin].add(_value);

        // adjust allowance
        allowed[_from][theCoin] = _allowance.sub(_value);

        Transfer(_from, theCoin, _value);

        return true;
    }

    /// @dev Creates a specific amount of tokens and credits them to the Mint.
    /// @param _amount uint256 Amount tokens to mint.
    function mint(uint256 _amount) external onlyOwner whenNotPaused {
        require(_amount > 0);

        totalSupply = totalSupply.add(_amount);
        balances[theCoin] = balances[theCoin].add(_amount);

        Mint(msg.sender, theCoin, _amount);

        // optional in ERC-20 standard, but required by Etherscan
        Transfer(address(0), theCoin, _amount);
    }

    /// @dev Retrieve the protected balance and hashed passphrase for a pending protected transfer.
    /// @param _from address The address transferred from.
    /// @param _to address The address transferred to.
    function protectedBalance(address _from, address _to) public constant returns (uint256 balance, bytes32 hashed) {
        return(protectedBalances[_from][_to].balance, protectedBalances[_from][_to].hashed);
    }

    /// @dev Transfer tokens to a specified address protected by a secret.
    /// @param _to address The address to transfer to.
    /// @param _value uint256 The amount to be transferred.
    /// @param _hashed string The hashed secret to use as protection.
    function protectedTransfer(address _to, uint256 _value, bytes32 _hashed) public whenNotPaused returns (bool) {
        require(_value > 0);

        // "transfers" to address(0) should only be by the burn() function
        require(_to != address(0));

        // explicitly disallow tranfer to the owner, as it's automatically translated into the coin
        // in protectedUnlock() and protectedReclaim()
        require(_to != owner);

        address from = msg.sender;

        // special case: msg.sender is the owner (Mint)
        if (msg.sender == owner) {
            from = theCoin;

            // ensure Mint is actually holding this supply; not required below because of revert in .sub()
            require(balances[theCoin].sub(protectedSupply) >= _value);
        } else {
            // otherwise, adjust the balances: transfer the tokens to the Mint to have them held in escrow
            balances[from] = balances[from].sub(_value);
            balances[theCoin] = balances[theCoin].add(_value);
        }

        // protected balance must be zero (unlocked or reclaimed in its entirety)
        // avoid a situation similar to: https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
        if (protectedBalances[from][_to].balance != 0) {
            revert();
        }

        // disallow reusing the previous secret
        // (not intended to prevent reuse of an N-x, x > 1 secret)
        require(protectedBalances[from][_to].hashed != _hashed);

        // set the protected balance and hashed value
        protectedBalances[from][_to].balance = _value;
        protectedBalances[from][_to].hashed = _hashed;

        // adjust the protected supply
        protectedSupply = protectedSupply.add(_value);

        ProtectedTransfer(from, _to, _value, _hashed);

        return true;
    }

    /// @dev Unlock protected tokens from an address.
    /// @param _from address The address to transfer from.
    /// @param _value uint256 The amount to be transferred.
    /// @param _secret string The secret phrase protecting the tokens.
    function protectedUnlock(address _from, uint256 _value, string _secret) external whenNotPaused returns (bool) {
        address to = msg.sender;

        // special case: msg.sender is the owner (Mint)
        if (msg.sender == owner) {
            to = theCoin;
        }

        // validate secret against hash
        require(checkSecret(to, _secret, protectedBalances[_from][to].hashed));

        // must transfer all protected tokens at once as secret will have been leaked on the blockchain
        require(protectedBalances[_from][to].balance == _value);

        // adjust the balances: the Mint is holding the tokens in escrow
        balances[theCoin] = balances[theCoin].sub(_value);
        balances[to] = balances[to].add(_value);
        
        // adjust the protected balances and protected supply
        protectedBalances[_from][to].balance = 0;
        protectedSupply = protectedSupply.sub(_value);

        ProtectedUnlock(_from, to, _value);
        Transfer(_from, to, _value);

        return true;
    }

    /// @dev Reclaim protected tokens granted to a specified address.
    /// @param _to address The address to the tokens were granted to.
    /// @param _value uint256 The amount to be transferred.
    function protectedReclaim(address _to, uint256 _value) external whenNotPaused returns (bool) {
        address from = msg.sender;

        // special case: msg.sender is the owner (Mint)
        if (msg.sender == owner) {
            from = theCoin;
        } else {
            // otherwise, adjust the balances: transfer the tokens to the sender from the Mint, which was holding them in escrow
            balances[theCoin] = balances[theCoin].sub(_value);
            balances[from] = balances[from].add(_value);
        }

        // must transfer all protected tokens at once
        require(protectedBalances[from][_to].balance == _value);
        
        // adjust the protected balances and protected supply
        protectedBalances[from][_to].balance = 0;
        protectedSupply = protectedSupply.sub(_value);

        ProtectedReclaim(from, _to, _value);

        return true;
    }

    /// @dev Destroys (removes from supply) a specific amount of tokens.
    /// @param _amount uint256 The amount of tokens to be burned.
    function burn(uint256 _amount) external onlyOwner whenNotPaused {
        // The Mint is the owner of this contract. In this implementation, the
        // address of this contract (proxy for owner's account)  is used to control 
        // the money supply. Avoids the problem of having to transfer balances on owner change.
        require(_amount > 0);
        require(_amount <= balances[theCoin].sub(protectedSupply)); // account for protected balances

        // adjust the balances and supply
        balances[theCoin] = balances[theCoin].sub(_amount);
        totalSupply = totalSupply.sub(_amount);

        // not part of the ERC-20 standard, but required by Etherscan
        Transfer(theCoin, address(0), _amount);

        Burn(theCoin, _amount);
    }

    /// @dev ERC20 behaviour but revert if paused
    /// @param _spender address The address which will spend the funds.
    /// @param _value uint256 The amount of tokens to be spent.
    function approve(address _spender, uint256 _value) public whenNotPaused returns (bool) {
        return super.approve(_spender, _value);
    }

    /// @dev ERC20 behaviour but revert if paused
    /// @param _owner address The address which owns the funds.
    /// @param _spender address The address which will spend the funds.
    /// @return uint256 specifying the amount of tokens still available for the spender.
    function allowance(address _owner, address _spender) public constant returns (uint256 remaining) {
        return super.allowance(_owner, _spender);
    }

    /// @dev ERC20 behaviour but revert if paused
    /// @param _to address The address to transfer to.
    /// @param _value uint256 The amount to be transferred.
    function transfer(address _to, uint256 _value) public whenNotPaused returns (bool) {
        // "transfers" to address(0) should only be by the burn() function
        require(_to != address(0));

        return super.transfer(_to, _value);
    }

    /// @dev ERC20 behaviour but revert if paused
    /// @param _from address The address which you want to send tokens from.
    /// @param _to address The address which you want to transfer to.
    /// @param _value uint256 the amount of tokens to be transferred.
    function transferFrom(address _from, address _to, uint256 _value) public whenNotPaused returns (bool) {
        // "transfers" to address(0) should only be by the burn() function
        require(_to != address(0));

        // special case: _from is the Mint
        // note: within the current D1 Coin design, should never encounter this case
        if (_from == theCoin) {
            // ensure Mint is not exceeding its balance less protected supply
            require(_value <= balances[theCoin].sub(protectedSupply));
        }

        return super.transferFrom(_from, _to, _value);
    }
}