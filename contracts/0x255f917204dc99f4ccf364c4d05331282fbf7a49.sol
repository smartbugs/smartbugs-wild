pragma solidity ^0.4.15;


/**
 * @title Eliptic curve signature operations
 *
 * @dev Based on https://gist.github.com/axic/5b33912c6f61ae6fd96d6c4a47afde6d
 */

library ECRecovery {

  /**
   * @dev Recover signer address from a message by using his signature
   * @param hash bytes32 message, the hash is the signed message. What is recovered is the signer address.
   * @param sig bytes signature, the signature is generated using web3.eth.sign()
   */
  function recover(bytes32 hash, bytes sig) public constant returns (address) {
    bytes32 r;
    bytes32 s;
    uint8 v;

    //Check the signature length
    if (sig.length != 65) {
      return (address(0));
    }

    // Divide the signature in r, s and v variables
    assembly {
      r := mload(add(sig, 32))
      s := mload(add(sig, 64))
      v := byte(0, mload(add(sig, 96)))
    }

    // Version of signature should be 27 or 28, but 0 and 1 are also possible versions
    if (v < 27) {
      v += 27;
    }

    // If the version is correct return the signer address
    if (v != 27 && v != 28) {
      return (address(0));
    } else {
      return ecrecover(hash, v, r, s);
    }
  }

}


//Papyrus State Channel Library
//moved to separate library to save gas
library ChannelLibrary {
    
    struct Data {
        uint close_timeout;
        uint settle_timeout;
        uint audit_timeout;
        uint opened;
        uint close_requested;
        uint closed;
        uint settled;
        uint audited;
        ChannelManagerContract manager;
    
        address sender;
        address receiver;
        address client;
        uint balance;
        address auditor;

        //state update for close
        uint nonce;
        uint completed_transfers;
    }

    struct StateUpdate {
        uint nonce;
        uint completed_transfers;
    }

    modifier notSettledButClosed(Data storage self) {
        require(self.settled <= 0 && self.closed > 0);
        _;
    }

    modifier notAuditedButClosed(Data storage self) {
        require(self.audited <= 0 && self.closed > 0);
        _;
    }

    modifier stillTimeout(Data storage self) {
        require(self.closed + self.settle_timeout >= block.number);
        _;
    }

    modifier timeoutOver(Data storage self) {
        require(self.closed + self.settle_timeout <= block.number);
        _;
    }

    modifier channelSettled(Data storage self) {
        require(self.settled != 0);
        _;
    }

    modifier senderOnly(Data storage self) {
        require(self.sender == msg.sender);
        _;
    }

    modifier receiverOnly(Data storage self) {
        require(self.receiver == msg.sender);
        _;
    }

    /// @notice Sender deposits amount to channel.
    /// must deposit before the channel is opened.
    /// @param amount The amount to be deposited to the address
    /// @return Success if the transfer was successful
    /// @return The new balance of the invoker
    function deposit(Data storage self, uint256 amount) 
    senderOnly(self)
    returns (bool success, uint256 balance)
    {
        require(self.opened > 0);
        require(self.closed == 0);

        StandardToken token = self.manager.token();

        require (token.balanceOf(msg.sender) >= amount);

        success = token.transferFrom(msg.sender, this, amount);
    
        if (success == true) {
            self.balance += amount;

            return (true, self.balance);
        }

        return (false, 0);
    }

    function request_close(
        Data storage self
    ) {
        require(msg.sender == self.sender || msg.sender == self.receiver);
        require(self.close_requested == 0);
        self.close_requested = block.number;
    }

    function close(
        Data storage self,
        address channel_address,
        uint nonce,
        uint completed_transfers,
        bytes signature
    )
    {
        if (self.close_timeout > 0) {
            require(self.close_requested > 0);
            require(block.number - self.close_requested >= self.close_timeout);
        }
        require(nonce > self.nonce);
        require(completed_transfers >= self.completed_transfers);
        require(completed_transfers <= self.balance);
    
        if (msg.sender != self.sender) {
            //checking signature
            bytes32 signed_hash = hashState(
                channel_address,
                nonce,
                completed_transfers
            );

            address sign_address = ECRecovery.recover(signed_hash, signature);
            require(sign_address == self.sender);
        }

        if (self.closed == 0) {
            self.closed = block.number;
        }
    
        self.nonce = nonce;
        self.completed_transfers = completed_transfers;
    }

    function hashState (
        address channel_address,
        uint nonce,
        uint completed_transfers
    ) returns (bytes32) {
        return sha3 (
            channel_address,
            nonce,
            completed_transfers
        );
    }

    /// @notice Settles the balance between the two parties
    /// @dev Settles the balances of the two parties fo the channel
    /// @return The participants with netted balances
    function settle(Data storage self)
        notSettledButClosed(self)
        timeoutOver(self)
    {
        StandardToken token = self.manager.token();
        
        if (self.completed_transfers > 0) {
            require(token.transfer(self.receiver, self.completed_transfers));
        }

        if (self.completed_transfers < self.balance) {
            require(token.transfer(self.sender, self.balance - self.completed_transfers));
        }

        self.settled = block.number;
    }

    function audit(Data storage self, address auditor)
        notAuditedButClosed(self) {
        require(self.auditor == auditor);
        require(block.number <= self.closed + self.audit_timeout);
        self.audited = block.number;
    }

    function validateTransfer(
        Data storage self,
        address transfer_id,
        address channel_address,
        uint sum,
        bytes lock_data,
        bytes signature
    ) returns (uint256) {

        bytes32 signed_hash = hashTransfer(
            transfer_id,
            channel_address,
            lock_data,
            sum
        );

        address sign_address = ECRecovery.recover(signed_hash, signature);
        require(sign_address == self.client);
    }

    function hashTransfer(
        address transfer_id,
        address channel_address,
        bytes lock_data,
        uint sum
    ) returns (bytes32) {
        if (lock_data.length > 0) {
            return sha3 (
                transfer_id,
                channel_address,
                sum,
                lock_data
            );
        } else {
            return sha3 (
                transfer_id,
                channel_address,
                sum
            );
        }
    }
}


/// @title ERC20 interface
/// @dev Full ERC20 interface described at https://github.com/ethereum/EIPs/issues/20.
contract ERC20 {

  // EVENTS

  event Transfer(address indexed from, address indexed to, uint256 value);
  event Approval(address indexed owner, address indexed spender, uint256 value);

  // PUBLIC FUNCTIONS

  function transfer(address _to, uint256 _value) public returns (bool);
  function transferFrom(address _from, address _to, uint256 _value) public returns (bool);
  function approve(address _spender, uint256 _value) public returns (bool);
  function balanceOf(address _owner) public constant returns (uint256);
  function allowance(address _owner, address _spender) public constant returns (uint256);

  // FIELDS

  uint256 public totalSupply;
}


/// @title SafeMath
/// @dev Math operations with safety checks that throw on error.
library SafeMath {
  function mul(uint256 a, uint256 b) internal constant returns (uint256) {
    uint256 c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal constant returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  function sub(uint256 a, uint256 b) internal constant returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal constant returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}


/// @title Standard ERC20 token
/// @dev Implementation of the basic standard token.
contract StandardToken is ERC20 {
  using SafeMath for uint256;

  // PUBLIC FUNCTIONS

  /// @dev Transfers tokens to a specified address.
  /// @param _to The address which you want to transfer to.
  /// @param _value The amount of tokens to be transferred.
  /// @return A boolean that indicates if the operation was successful.
  function transfer(address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));
    require(_value <= balances[msg.sender]);
    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);
    Transfer(msg.sender, _to, _value);
    return true;
  }
  
  /// @dev Transfers tokens from one address to another.
  /// @param _from The address which you want to send tokens from.
  /// @param _to The address which you want to transfer to.
  /// @param _value The amount of tokens to be transferred.
  /// @return A boolean that indicates if the operation was successful.
  function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));
    require(_value <= balances[_from]);
    require(_value <= allowances[_from][msg.sender]);
    balances[_from] = balances[_from].sub(_value);
    balances[_to] = balances[_to].add(_value);
    allowances[_from][msg.sender] = allowances[_from][msg.sender].sub(_value);
    Transfer(_from, _to, _value);
    return true;
  }

  /// @dev Approves the specified address to spend the specified amount of tokens on behalf of msg.sender.
  /// Beware that changing an allowance with this method brings the risk that someone may use both the old
  /// and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this
  /// race condition is to first reduce the spender's allowance to 0 and set the desired value afterwards:
  /// https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
  /// @param _spender The address which will spend tokens.
  /// @param _value The amount of tokens to be spent.
  /// @return A boolean that indicates if the operation was successful.
  function approve(address _spender, uint256 _value) public returns (bool) {
    allowances[msg.sender][_spender] = _value;
    Approval(msg.sender, _spender, _value);
    return true;
  }

  /// @dev Gets the balance of the specified address.
  /// @param _owner The address to query the balance of.
  /// @return An uint256 representing the amount owned by the specified address.
  function balanceOf(address _owner) public constant returns (uint256) {
    return balances[_owner];
  }

  /// @dev Function to check the amount of tokens that an owner allowances to a spender.
  /// @param _owner The address which owns tokens.
  /// @param _spender The address which will spend tokens.
  /// @return A uint256 specifying the amount of tokens still available for the spender.
  function allowance(address _owner, address _spender) public constant returns (uint256) {
    return allowances[_owner][_spender];
  }

  // FIELDS

  mapping (address => uint256) balances;
  mapping (address => mapping (address => uint256)) allowances;
}


contract ChannelApi {
    function applyRuntimeUpdate(address from, address to, uint impressionsCount, uint fraudCount);

    function applyAuditorsCheckUpdate(address from, address to, uint fraudCountDelta);
}


contract ChannelContract {
    using ChannelLibrary for ChannelLibrary.Data;
    ChannelLibrary.Data data;

    event ChannelNewBalance(address token_address, address participant, uint balance, uint block_number);
    event ChannelCloseRequested(address closing_address, uint block_number);
    event ChannelClosed(address closing_address, uint block_number);
    event TransferUpdated(address node_address, uint block_number);
    event ChannelSettled(uint block_number);
    event ChannelAudited(uint block_number);
    event ChannelSecretRevealed(bytes32 secret, address receiver_address);

    modifier onlyManager() {
        require(msg.sender == address(data.manager));
        _;
    }

    function ChannelContract(
        address manager_address,
        address sender,
        address client,
        address receiver,
        uint close_timeout,
        uint settle_timeout,
        uint audit_timeout,
        address auditor
    )
    {
        //allow creation only from manager contract
        require(msg.sender == manager_address);
        require (sender != receiver);
        require (client != receiver);
        require (audit_timeout >= 0);
        require (settle_timeout > 0);
        require (close_timeout >= 0);

        data.sender = sender;
        data.client = client;
        data.receiver = receiver;
        data.auditor = auditor;
        data.manager = ChannelManagerContract(manager_address);
        data.close_timeout = close_timeout;
        data.settle_timeout = settle_timeout;
        data.audit_timeout = audit_timeout;
        data.opened = block.number;
    }

    /// @notice Caller makes a deposit into their channel balance.
    /// @param amount The amount caller wants to deposit.
    /// @return True if deposit is successful.
    function deposit(uint256 amount) returns (bool) {
        bool success;
        uint256 balance;

        (success, balance) = data.deposit(amount);

        if (success == true) {
            ChannelNewBalance(data.manager.token(), msg.sender, balance, 0);
        }

        return success;
    }

    /// @notice Get the address and balance of both partners in a channel.
    /// @return The address and balance pairs.
    function addressAndBalance()
        constant
        returns (
        address sender,
        address receiver,
        uint balance)
    {
        sender = data.sender;
        receiver = data.receiver;
        balance = data.balance;
    }

    /// @notice Request to close the channel. 
    function request_close () {
        data.request_close();
        ChannelCloseRequested(msg.sender, data.closed);
    }

    /// @notice Close the channel. 
    function close (
        uint nonce,
        uint256 completed_transfers,
        bytes signature
    ) {
        data.close(address(this), nonce, completed_transfers, signature);
        ChannelClosed(msg.sender, data.closed);
    }

    /// @notice Settle the transfers and balances of the channel and pay out to
    ///         each participant. Can only be called after the channel is closed
    ///         and only after the number of blocks in the settlement timeout
    ///         have passed.
    function settle() {
        data.settle();
        ChannelSettled(data.settled);
    }

    /// @notice Settle the transfers and balances of the channel and pay out to
    ///         each participant. Can only be called after the channel is closed
    ///         and only after the number of blocks in the settlement timeout
    ///         have passed.
    function audit(address auditor) onlyManager {
        data.audit(auditor);
        ChannelAudited(data.audited);
    }

    function destroy() onlyManager {
        require(data.settled > 0);
        require(data.audited > 0 || block.number > data.closed + data.audit_timeout);
        selfdestruct(0);
    }

    function sender() constant returns (address) {
        return data.sender;
    }

    function receiver() constant returns (address) {
        return data.receiver;
    }

    function client() constant returns (address) {
        return data.client;
    }

    function auditor() constant returns (address) {
        return data.auditor;
    }

    function closeTimeout() constant returns (uint) {
        return data.close_timeout;
    }

    function settleTimeout() constant returns (uint) {
        return data.settle_timeout;
    }

    function auditTimeout() constant returns (uint) {
        return data.audit_timeout;
    }

    /// @return Returns the address of the manager.
    function manager() constant returns (address) {
        return data.manager;
    }

    function balance() constant returns (uint) {
        return data.balance;
    }

    function nonce() constant returns (uint) {
        return data.nonce;
    }

    function completedTransfers() constant returns (uint) {
        return data.completed_transfers;
    }

    /// @notice Returns the block number for when the channel was opened.
    /// @return The block number for when the channel was opened.
    function opened() constant returns (uint) {
        return data.opened;
    }

    function closeRequested() constant returns (uint) {
        return data.close_requested;
    }

    function closed() constant returns (uint) {
        return data.closed;
    }

    function settled() constant returns (uint) {
        return data.settled;
    }

    function audited() constant returns (uint) {
        return data.audited;
    }

    function () { revert(); }
}


contract ChannelManagerContract {

    event ChannelNew(
        address channel_address,
        address indexed sender,
        address client,
        address indexed receiver,
        uint close_timeout,
        uint settle_timeout,
        uint audit_timeout
    );

    event ChannelDeleted(
        address channel_address,
        address indexed sender,
        address indexed receiver
    );

    StandardToken public token;
    ChannelApi public channel_api;

    function ChannelManagerContract(address token_address, address channel_api_address) {
        require(token_address != 0);
        require(channel_api_address != 0);
        token = StandardToken(token_address);
        channel_api = ChannelApi(channel_api_address);
    }

    /// @notice Create a new channel from msg.sender to receiver
    /// @param receiver The address of the receiver
    /// @param settle_timeout The settle timeout in blocks
    /// @return The address of the newly created ChannelContract.
    function newChannel(
        address client, 
        address receiver, 
        uint close_timeout,
        uint settle_timeout,
        uint audit_timeout,
        address auditor
    )
        returns (address)
    {
        address new_channel_address = new ChannelContract(
            this,
            msg.sender,
            client,
            receiver,
            close_timeout,
            settle_timeout,
            audit_timeout,
            auditor
        );

        ChannelNew(
            new_channel_address, 
            msg.sender, 
            client, 
            receiver,
            close_timeout,
            settle_timeout,
            audit_timeout
        );

        return new_channel_address;
    }

    function auditReport(address contract_address, uint total, uint fraud) {
        ChannelContract ch = ChannelContract(contract_address);
        require(ch.manager() == address(this));
        address auditor = msg.sender;
        ch.audit(auditor);
        channel_api.applyRuntimeUpdate(ch.sender(), ch.receiver(), total, fraud);
    }
    
    function destroyChannel(address channel_address) {
        ChannelContract ch = ChannelContract(channel_address);
        require(ch.manager() == address(this));
        ChannelDeleted(channel_address,ch.sender(),ch.receiver());
        ch.destroy();
    }
}