pragma solidity ^0.4.24;

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMathLib{
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
}


/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
  address public owner;
  address public coinvest;
  mapping (address => bool) public admins;

  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  constructor() public {
    owner = msg.sender;
    coinvest = msg.sender;
    admins[owner] = true;
    admins[coinvest] = true;
  }

  /**
   * @dev Throws if called by any account other than the owner.
   */
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

  modifier onlyCoinvest() {
      require(msg.sender == coinvest);
      _;
  }

  modifier onlyAdmin() {
      require(admins[msg.sender]);
      _;
  }

  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param newOwner The address to transfer ownership to.
   */
  function transferOwnership(address newOwner) onlyOwner public {
    require(newOwner != address(0));
    emit OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }
  
  /**
   * @dev Changes the Coinvest wallet that will receive funds from investment contract.
   * @param _newCoinvest The address of the new wallet.
  **/
  function transferCoinvest(address _newCoinvest) 
    external
    onlyCoinvest
  {
    require(_newCoinvest != address(0));
    coinvest = _newCoinvest;
  }

  /**
   * @dev Used to add admins who are allowed to add funds to the investment contract.
   * @param _user The address of the admin to add or remove.
   * @param _status True to add the user, False to remove the user.
  **/
  function alterAdmin(address _user, bool _status)
    external
    onlyCoinvest
  {
    require(_user != address(0));
    require(_user != coinvest);
    admins[_user] = _status;
  }

}

/**
 * @dev Abstract contract for approveAndCall.
**/
contract ApproveAndCallFallBack {
    function receiveApproval(address from, uint256 tokens, address token, bytes data) public;
}

/**
 * @title Coinvest COIN Token
 * @dev ERC20 contract utilizing ERC865-ish structure (3esmit's implementation with alterations).
 * @dev to allow users to pay Ethereum fees in tokens.
**/
contract CoinvestToken is Ownable {
    using SafeMathLib for uint256;
    
    string public constant symbol = "COIN";
    string public constant name = "Coinvest COIN V3 Token";
    
    uint8 public constant decimals = 18;
    uint256 private _totalSupply = 107142857 * (10 ** 18);
    
    // Function sigs to be used within contract for signature recovery.
    bytes4 internal constant transferSig = 0xa9059cbb;
    bytes4 internal constant approveSig = 0x095ea7b3;
    bytes4 internal constant increaseApprovalSig = 0xd73dd623;
    bytes4 internal constant decreaseApprovalSig = 0x66188463;
    bytes4 internal constant approveAndCallSig = 0xcae9ca51;
    bytes4 internal constant revokeHashSig = 0x70de43f1;

    // Balances for each account
    mapping(address => uint256) balances;

    // Owner of account approves the transfer of an amount to another account
    mapping(address => mapping (address => uint256)) allowed;
    
    // Keeps track of the last nonce sent from user. Used for delegated functions.
    mapping(address => uint256) nonces;
    
    // Mapping of past used hashes: true if already used.
    mapping(address => mapping (bytes32 => bool)) invalidHashes;

    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed from, address indexed spender, uint tokens);
    event HashRedeemed(bytes32 indexed txHash, address indexed from);

    /**
     * @dev Set owner and beginning balance.
    **/
    constructor()
      public
    {
        balances[msg.sender] = _totalSupply;
    }

    /**
     * @dev approveAndCall reception used primarily to pay gas with other tokens.
    **/
    function receiveApproval(address _from, uint256 _amount, address _token, bytes _data) 
      public
    {
        require(address(this).delegatecall(_data));
        _from; _amount; _token;
    }

/** ******************************** ERC20 ********************************* **/

    /**
     * @dev Transfers coins from one address to another.
     * @param _to The recipient of the transfer amount.
     * @param _amount The amount of tokens to transfer.
    **/
    function transfer(address _to, uint256 _amount) 
      public
    returns (bool success)
    {
        require(_transfer(msg.sender, _to, _amount));
        return true;
    }
    
    /**
     * @dev An allowed address can transfer tokens from another's address.
     * @param _from The owner of the tokens to be transferred.
     * @param _to The address to which the tokens will be transferred.
     * @param _amount The amount of tokens to be transferred.
    **/
    function transferFrom(address _from, address _to, uint _amount)
      public
    returns (bool success)
    {
        require(balances[_from] >= _amount && allowed[_from][msg.sender] >= _amount);

        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_amount);
        require(_transfer(_from, _to, _amount));
        return true;
    }
    
    /**
     * @dev Approves a wallet to transfer tokens on one's behalf.
     * @param _spender The wallet approved to spend tokens.
     * @param _amount The amount of tokens approved to spend.
    **/
    function approve(address _spender, uint256 _amount) 
      public
    returns (bool success)
    {
        require(_approve(msg.sender, _spender, _amount));
        return true;
    }
    
    /**
     * @dev Increases the allowed amount for spender from msg.sender.
     * @param _spender The address to increase allowed amount for.
     * @param _amount The amount of tokens to increase allowed amount by.
    **/
    function increaseApproval(address _spender, uint256 _amount) 
      public
    returns (bool success)
    {
        require(_increaseApproval(msg.sender, _spender, _amount));
        return true;
    }
    
    /**
     * @dev Decreases the allowed amount for spender from msg.sender.
     * @param _spender The address to decrease allowed amount for.
     * @param _amount The amount of tokens to decrease allowed amount by.
    **/
    function decreaseApproval(address _spender, uint256 _amount) 
      public
    returns (bool success)
    {
        require(_decreaseApproval(msg.sender, _spender, _amount));
        return true;
    }
    
    /**
     * @dev Used to approve an address and call a function on it in the same transaction.
     * @dev _spender The address to be approved to spend COIN.
     * @dev _amount The amount of COIN to be approved to spend.
     * @dev _data The data to send to the called contract.
    **/
    function approveAndCall(address _spender, uint256 _amount, bytes _data) 
      public
    returns (bool success) 
    {
        require(_approve(msg.sender, _spender, _amount));
        ApproveAndCallFallBack(_spender).receiveApproval(msg.sender, _amount, address(this), _data);
        return true;
    }

/** ****************************** Internal ******************************** **/
    
    /**
     * @dev Internal transfer for all functions that transfer.
     * @param _from The address that is transferring coins.
     * @param _to The receiving address of the coins.
     * @param _amount The amount of coins being transferred.
    **/
    function _transfer(address _from, address _to, uint256 _amount)
      internal
    returns (bool success)
    {
        require (_to != address(0), "Invalid transfer recipient address.");
        require(balances[_from] >= _amount, "Sender does not have enough balance.");
        
        balances[_from] = balances[_from].sub(_amount);
        balances[_to] = balances[_to].add(_amount);
        
        emit Transfer(_from, _to, _amount);
        return true;
    }
    
    /**
     * @dev Internal approve for all functions that require an approve.
     * @param _owner The owner who is allowing spender to use their balance.
     * @param _spender The wallet approved to spend tokens.
     * @param _amount The amount of tokens approved to spend.
    **/
    function _approve(address _owner, address _spender, uint256 _amount) 
      internal
    returns (bool success)
    {
        allowed[_owner][_spender] = _amount;
        emit Approval(_owner, _spender, _amount);
        return true;
    }
    
    /**
     * @dev Increases the allowed by "_amount" for "_spender" from "owner"
     * @param _owner The address that tokens may be transferred from.
     * @param _spender The address that may transfer these tokens.
     * @param _amount The amount of tokens to transfer.
    **/
    function _increaseApproval(address _owner, address _spender, uint256 _amount)
      internal
    returns (bool success)
    {
        allowed[_owner][_spender] = allowed[_owner][_spender].add(_amount);
        emit Approval(_owner, _spender, allowed[_owner][_spender]);
        return true;
    }
    
    /**
     * @dev Decreases the allowed by "_amount" for "_spender" from "_owner"
     * @param _owner The owner of the tokens to decrease allowed for.
     * @param _spender The spender whose allowed will decrease.
     * @param _amount The amount of tokens to decrease allowed by.
    **/
    function _decreaseApproval(address _owner, address _spender, uint256 _amount)
      internal
    returns (bool success)
    {
        if (allowed[_owner][_spender] <= _amount) allowed[_owner][_spender] = 0;
        else allowed[_owner][_spender] = allowed[_owner][_spender].sub(_amount);
        
        emit Approval(_owner, _spender, allowed[_owner][_spender]);
        return true;
    }
    
/** ************************ Delegated Functions *************************** **/

    /**
     * @dev Called by delegate with a signed hash of the transaction data to allow a user
     * @dev to transfer tokens without paying gas in Ether (they pay in COIN instead).
     * @param _signature Signed hash of data for this transfer.
     * @param _to The address to transfer COIN to.
     * @param _value The amount of COIN to transfer.
     * @param _gasPrice Price (IN COIN) that will be paid per unit of gas by user to "delegate".
     * @param _nonce Nonce of the user's new transaction.
    **/
    function transferPreSigned(
        bytes _signature,
        address _to, 
        uint256 _value,
        uint256 _gasPrice, 
        uint256 _nonce) 
      public
    returns (bool) 
    {
        // Log starting gas left of transaction for later gas price calculations.
        uint256 gas = gasleft();
        
        // Recover signer address from signature; ensure address is valid.
        address from = recoverPreSigned(_signature, transferSig, _to, _value, "", _gasPrice, _nonce);
        require(from != address(0), "Invalid signature provided.");
        
        // Require the hash has not been used, declare it used, increment nonce.
        bytes32 txHash = getPreSignedHash(transferSig, _to, _value, "", _gasPrice, _nonce);
        require(!invalidHashes[from][txHash], "Transaction has already been executed.");
        invalidHashes[from][txHash] = true;
        nonces[from]++;
        
        // Internal transfer.
        require(_transfer(from, _to, _value));

        // If the delegate is charging, pay them for gas in COIN.
        if (_gasPrice > 0) {
            // 35000 because of base fee of 21000 and ~14000 for the fee transfer.
            gas = 35000 + gas.sub(gasleft());
            require(_transfer(from, tx.origin, _gasPrice.mul(gas)), "Gas cost could not be paid.");
        }
        
        emit HashRedeemed(txHash, from);
        return true;
    }
    
    /**
     * @dev Called by a delegate with signed hash to approve a transaction for user.
     * @dev All variables equivalent to transfer except _to:
     * @param _to The address that will be approved to transfer COIN from user's wallet.
    **/
    function approvePreSigned(
        bytes _signature,
        address _to, 
        uint256 _value,
        uint256 _gasPrice, 
        uint256 _nonce) 
      public
    returns (bool) 
    {
        uint256 gas = gasleft();
        address from = recoverPreSigned(_signature, approveSig, _to, _value, "", _gasPrice, _nonce);
        require(from != address(0), "Invalid signature provided.");

        bytes32 txHash = getPreSignedHash(approveSig, _to, _value, "", _gasPrice, _nonce);
        require(!invalidHashes[from][txHash], "Transaction has already been executed.");
        invalidHashes[from][txHash] = true;
        nonces[from]++;
        
        require(_approve(from, _to, _value));

        if (_gasPrice > 0) {
            gas = 35000 + gas.sub(gasleft());
            require(_transfer(from, tx.origin, _gasPrice.mul(gas)), "Gas cost could not be paid.");
        }

        emit HashRedeemed(txHash, from);
        return true;
    }
    
    /**
     * @dev Used to increase the amount allowed for "_to" to spend from "from"
     * @dev A bare approve allows potentially nasty race conditions when using a delegate.
    **/
    function increaseApprovalPreSigned(
        bytes _signature,
        address _to, 
        uint256 _value,
        uint256 _gasPrice, 
        uint256 _nonce)
      public
    returns (bool) 
    {
        uint256 gas = gasleft();
        address from = recoverPreSigned(_signature, increaseApprovalSig, _to, _value, "", _gasPrice, _nonce);
        require(from != address(0), "Invalid signature provided.");

        bytes32 txHash = getPreSignedHash(increaseApprovalSig, _to, _value, "", _gasPrice, _nonce);
        require(!invalidHashes[from][txHash], "Transaction has already been executed.");
        invalidHashes[from][txHash] = true;
        nonces[from]++;
        
        require(_increaseApproval(from, _to, _value));

        if (_gasPrice > 0) {
            gas = 35000 + gas.sub(gasleft());
            require(_transfer(from, tx.origin, _gasPrice.mul(gas)), "Gas cost could not be paid.");
        }
        
        emit HashRedeemed(txHash, from);
        return true;
    }
    
    /**
     * @dev Added for the same reason as increaseApproval. Decreases to 0 if "_value" is greater than allowed.
    **/
    function decreaseApprovalPreSigned(
        bytes _signature,
        address _to, 
        uint256 _value, 
        uint256 _gasPrice, 
        uint256 _nonce) 
      public
    returns (bool) 
    {
        uint256 gas = gasleft();
        address from = recoverPreSigned(_signature, decreaseApprovalSig, _to, _value, "", _gasPrice, _nonce);
        require(from != address(0), "Invalid signature provided.");

        bytes32 txHash = getPreSignedHash(decreaseApprovalSig, _to, _value, "", _gasPrice, _nonce);
        require(!invalidHashes[from][txHash], "Transaction has already been executed.");
        invalidHashes[from][txHash] = true;
        nonces[from]++;
        
        require(_decreaseApproval(from, _to, _value));

        if (_gasPrice > 0) {
            gas = 35000 + gas.sub(gasleft());
            require(_transfer(from, tx.origin, _gasPrice.mul(gas)), "Gas cost could not be paid.");
        }

        emit HashRedeemed(txHash, from);
        return true;
    }
    
    /**
     * @dev approveAndCallPreSigned allows a user to approve a contract and call a function on it
     * @dev in the same transaction. As with the other presigneds, a delegate calls this with signed data from user.
     * @dev This function is the big reason we're using gas price and calculating gas use.
     * @dev Using this with the investment contract can result in varying gas costs.
     * @param _extraData The data to send to the contract.
    **/
    function approveAndCallPreSigned(
        bytes _signature,
        address _to, 
        uint256 _value,
        bytes _extraData,
        uint256 _gasPrice,
        uint256 _nonce) 
      public
    returns (bool) 
    {
        uint256 gas = gasleft();
        address from = recoverPreSigned(_signature, approveAndCallSig, _to, _value, _extraData, _gasPrice, _nonce);
        require(from != address(0), "Invalid signature provided.");

        bytes32 txHash = getPreSignedHash(approveAndCallSig, _to, _value, _extraData, _gasPrice, _nonce);
        require(!invalidHashes[from][txHash], "Transaction has already been executed.");
        invalidHashes[from][txHash] = true;
        nonces[from]++;
        
        if (_value > 0) require(_approve(from, _to, _value));
        ApproveAndCallFallBack(_to).receiveApproval(from, _value, address(this), _extraData);

        if (_gasPrice > 0) {
            gas = 35000 + gas.sub(gasleft());
            require(_transfer(from, tx.origin, _gasPrice.mul(gas)), "Gas cost could not be paid.");
        }
        
        emit HashRedeemed(txHash, from);
        return true;
    }

/** *************************** Revoke PreSigned ************************** **/
    
    /**
     * @dev Revoke hash without going through a delegate.
     * @param _hashToRevoke The hash that you no longer want to be used.
    **/
    function revokeHash(bytes32 _hashToRevoke)
      public
    returns (bool)
    {
        invalidHashes[msg.sender][_hashToRevoke] = true;
        nonces[msg.sender]++;
        return true;
    }
    
    /**
     * @dev Revoke hash through a delegate.
     * @param _signature The signature allowing this revocation.
     * @param _hashToRevoke The hash that you would like revoked.
     * @param _gasPrice The amount of token wei to be paid for each uint of gas.
    **/
    function revokeHashPreSigned(
        bytes _signature,
        bytes32 _hashToRevoke,
        uint256 _gasPrice)
      public
    returns (bool)
    {
        uint256 gas = gasleft();
        address from = recoverRevokeHash(_signature, _hashToRevoke, _gasPrice);
        require(from != address(0), "Invalid signature provided.");
        
        bytes32 txHash = getRevokeHash(_hashToRevoke, _gasPrice);
        require(!invalidHashes[from][txHash], "Transaction has already been executed.");
        invalidHashes[from][txHash] = true;
        nonces[from]++;
        
        invalidHashes[from][_hashToRevoke] = true;
        
        if (_gasPrice > 0) {
            gas = 35000 + gas.sub(gasleft());
            require(_transfer(from, tx.origin, _gasPrice.mul(gas)), "Gas cost could not be paid.");
        }
        
        emit HashRedeemed(txHash, from);
        return true;
    }
    
    /**
     * @dev Get hash for a revocation.
     * @param _hashToRevoke The signature to be revoked.
     * @param _gasPrice The amount to be paid to delegate for sending this tx.
    **/
    function getRevokeHash(bytes32 _hashToRevoke, uint256 _gasPrice)
      public
      view
    returns (bytes32 txHash)
    {
        return keccak256(abi.encodePacked(address(this), revokeHashSig, _hashToRevoke, _gasPrice));
    }

    /**
     * @dev Recover the address from a revocation hash.
     * @param _hashToRevoke The hash to be revoked.
     * @param _signature The signature allowing this revocation.
     * @param _gasPrice The amount of token wei to be paid for each unit of gas.
    **/
    function recoverRevokeHash(bytes _signature, bytes32 _hashToRevoke, uint256 _gasPrice)
      public
      view
    returns (address from)
    {
        return ecrecoverFromSig(getSignHash(getRevokeHash(_hashToRevoke, _gasPrice)), _signature);
    }
    
/** ************************** PreSigned Constants ************************ **/

    /**
     * @dev Used in frontend and contract to get hashed data of any given pre-signed transaction.
     * @param _to The address to transfer COIN to.
     * @param _value The amount of COIN to be transferred.
     * @param _extraData Extra data of tx if needed. Transfers and approves will leave this null.
     * @param _function Function signature of the pre-signed function being used.
     * @param _gasPrice The agreed-upon amount of COIN to be paid per unit of gas.
     * @param _nonce The user's nonce of the new transaction.
    **/
    function getPreSignedHash(
        bytes4 _function,
        address _to, 
        uint256 _value,
        bytes _extraData,
        uint256 _gasPrice,
        uint256 _nonce)
      public
      view
    returns (bytes32 txHash) 
    {
        return keccak256(abi.encodePacked(address(this), _function, _to, _value, _extraData, _gasPrice, _nonce));
    }
    
    /**
     * @dev Recover an address from a signed pre-signed hash.
     * @param _sig The signed hash.
     * @param _function The function signature for function being called.
     * @param _to The address to transfer/approve/transferFrom/etc. tokens to.
     * @param _value The amont of tokens to transfer/approve/etc.
     * @param _extraData The extra data included in the transaction, if any.
     * @param _gasPrice The amount of token wei to be paid to the delegate for each unit of gas.
     * @param _nonce The user's nonce for this transaction.
    **/
    function recoverPreSigned(
        bytes _sig,
        bytes4 _function,
        address _to,
        uint256 _value,
        bytes _extraData,
        uint256 _gasPrice,
        uint256 _nonce) 
      public
      view
    returns (address recovered)
    {
        return ecrecoverFromSig(getSignHash(getPreSignedHash(_function, _to, _value, _extraData, _gasPrice, _nonce)), _sig);
    }
    
    /**
     * @dev Add signature prefix to hash for recovery à la ERC191.
     * @param _hash The hashed transaction to add signature prefix to.
    **/
    function getSignHash(bytes32 _hash)
      public
      pure
    returns (bytes32 signHash)
    {
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", _hash));
    }

    /**
     * @dev Helps to reduce stack depth problems for delegations. Thank you to Bokky for this!
     * @param hash The hash of signed data for the transaction.
     * @param sig Contains r, s, and v for recovery of address from the hash.
    **/
    function ecrecoverFromSig(bytes32 hash, bytes sig) 
      public 
      pure 
    returns (address recoveredAddress) 
    {
        bytes32 r;
        bytes32 s;
        uint8 v;
        if (sig.length != 65) return address(0);
        assembly {
            r := mload(add(sig, 32))
            s := mload(add(sig, 64))
            // Here we are loading the last 32 bytes. We exploit the fact that 'mload' will pad with zeroes if we overread.
            // There is no 'mload8' to do this, but that would be nicer.
            v := byte(0, mload(add(sig, 96)))
        }
        // Albeit non-transactional signatures are not specified by the YP, one would expect it to match the YP range of [27, 28]
        // geth uses [0, 1] and some clients have followed. This might change, see https://github.com/ethereum/go-ethereum/issues/2053
        if (v < 27) v += 27;
        if (v != 27 && v != 28) return address(0);
        return ecrecover(hash, v, r, s);
    }

    /**
     * @dev Frontend queries to find the next nonce of the user so they can find the new nonce to send.
     * @param _owner Address that will be sending the COIN.
    **/
    function getNonce(address _owner)
      external
      view
    returns (uint256 nonce)
    {
        return nonces[_owner];
    }

/** ****************************** Constants ******************************* **/
    
    /**
     * @dev Return total supply of token.
    **/
    function totalSupply() 
      external
      view 
     returns (uint256)
    {
        return _totalSupply;
    }

    /**
     * @dev Return balance of a certain address.
     * @param _owner The address whose balance we want to check.
    **/
    function balanceOf(address _owner)
      external
      view 
    returns (uint256) 
    {
        return balances[_owner];
    }
    
    /**
     * @dev Allowed amount for a user to spend of another's tokens.
     * @param _owner The owner of the tokens approved to spend.
     * @param _spender The address of the user allowed to spend the tokens.
    **/
    function allowance(address _owner, address _spender) 
      external
      view 
    returns (uint256) 
    {
        return allowed[_owner][_spender];
    }
    
/** ****************************** onlyOwner ******************************* **/
    
    /**
     * @dev Allow the owner to take ERC20 tokens off of this contract if they are accidentally sent.
    **/
    function tokenEscape(address _tokenContract)
      external
      onlyOwner
    {
        CoinvestToken lostToken = CoinvestToken(_tokenContract);
        
        uint256 stuckTokens = lostToken.balanceOf(address(this));
        lostToken.transfer(owner, stuckTokens);
    }
    
}