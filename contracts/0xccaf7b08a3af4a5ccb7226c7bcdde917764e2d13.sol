//! FeeRegistrar contract.
//! By Parity Technologies, 2017.
//! Released under the Apache Licence 2.

pragma solidity ^0.4.16;

// From Owned.sol
contract Owned {
  /// STORAGE
  address public owner = msg.sender;

  /// EVENTS
  event NewOwner(address indexed old, address indexed current);

  /// MODIFIERS
  modifier only_owner { require (msg.sender == owner); _; }

  /// RESTRICTED PUBLIC METHODS
  function setOwner(address _new) public only_owner { NewOwner(owner, _new); owner = _new; }
}

/// @title Delegated Contract
/// @notice This contract can be used to have a a system of delegates
/// who can be authorized to execute certain methods. A (super-)owner
/// is set, who can modify the delegates.
contract Delegated is Owned {
  /// STORAGE
  mapping (address => bool) delegates;

  /// MODIFIERS
  modifier only_delegate { require (msg.sender == owner || delegates[msg.sender]); _; }

  /// PUBLIC METHODS
  function delegate(address who) public constant returns (bool) { return who == owner || delegates[who]; }

  /// RESTRICTED PUBLIC METHODS
  function addDelegate(address _new) public only_owner { delegates[_new] = true; }
  function removeDelegate(address _old) public only_owner { delete delegates[_old]; }
}

/// @title Fee Registrar
/// @author Nicolas Gotchac <nicolas@parity.io>
/// @notice This contract records fee payments. The address who deploys the contract
/// is set as the `owner` of the contract (which can be later modified). The `fee`
/// which users will have to pay must be specified, as well as the address of the treasury
/// to which the fee will be forwarded to.
/// A payment is a transaction with the value set as the `fee` value, and an address is
/// given as an argument. The given address will be marked as _paid for_, and the number
/// of times it was paid for will be recorded. We also record who is at the origin of the
/// payment.
/// For example, Alice can pay for Bob, and Eve can pay for Bob as well. This contract
/// will record that Bob is marked as paid, 2 times, by Alice and Eve.
/// A payment can be revoked by specified delegates, and the fund should be restored to
/// the payer of the fee.
contract FeeRegistrar is Delegated {
  /// STORAGE
  address public treasury;
  uint public fee;

  // a mapping of addresses to the origin of payments struct
  mapping(address => address[]) s_paid;


  /// EVENTS
  event Paid (address who, address payer);


  /// CONSTRUCTOR

  /// @notice Contructor method of the contract, which
  /// will set the `treasury` where payments will be send to,
  /// and the `fee` users have to pay
  /// @param _treasury The address to which the payments will be forwarded
  /// @param _fee The fee users have to pay, in wei
  function FeeRegistrar (address _treasury, uint _fee) public {
    owner = msg.sender;
    treasury = _treasury;
    fee = _fee;
  }


  /// PUBLIC CONSTANT METHODS

  /// @notice Returns for the given address the number of times
  /// it was paid for, and an array of addresses who actually paid for the fee
  /// (as one might pay the fee for another address)
  /// @param who The address of the payer whose info we check
  /// @return The count (number of payments) and the origins (the senders of the
  /// payment)
  function payer (address who) public constant returns (uint count, address[] origins) {
    address[] memory m_origins = s_paid[who];

    return (m_origins.length, m_origins);
  }

  /// @notice Returns whether the given address paid or not
  /// @param who The address whose payment status we check
  /// @ return Whether the address is marked as paid or not
  function paid (address who) public constant returns (bool) {
    return s_paid[who].length > 0;
  }


  /// PUBLIC METHODS

  /// @notice This method is used to pay for the fee. You can pay
  /// the fee for one address (then marked as paid), from another
  /// address. The origin of the transaction, the
  /// fee payer (`msg.sender`) is stored in an array.
  /// The value of the transaction must
  /// match the fee that was set in the contructor.
  /// The only restriction is that you can't pay for the null
  /// address.
  /// You also can't pay more than 10 times for the same address
  /// The value that is received is directly transfered to the
  /// `treasury`.
  /// @param who The address which should be marked as paid.
  function pay (address who) external payable {
    // We first check that the given address is not the null address
    require(who != 0x0);
    // Then check that the value matches with the fee
    require(msg.value == fee);
    // Maximum 10 payments per address
    require(s_paid[who].length < 10);

    s_paid[who].push(msg.sender);

    // Send the paid event
    Paid(who, msg.sender);

    // Send the message value to the treasury
    treasury.transfer(msg.value);
  }


  /// RESTRICTED (owner or delegate only) PUBLIC METHODS

  /// @notice This method can only be called by the contract
  /// owner, and can be used to virtually create a new payment,
  /// by `origin` for `who`.
  /// @param who The address that `origin` paid for
  /// @param origin The virtual sender of the payment
  function inject (address who, address origin) external only_owner {
    // Add the origin address to the list of payers
    s_paid[who].push(origin);
    // Emit the `Paid` event
    Paid(who, origin);
  }

  /// @notice This method can be called by authorized persons only,
  /// and can issue a refund of the fee to the `origin` address who
  /// paid the fee for `who`.
  /// @param who The address that `origin` paid for
  /// @param origin The sender of the payment, to which we shall
  /// send the refund
  function revoke (address who, address origin) payable external only_delegate {
    // The value must match the current fee, so we can refund
    // the payer, since the contract doesn't hold anything.
    require(msg.value == fee);
    bool found;

    // Go through the list of payers to find
    // the remove the right one
    // NB : this list is limited to 10 items,
    //      @see the `pay` method
    for (uint i = 0; i < s_paid[who].length; i++) {
      if (s_paid[who][i] != origin) {
        continue;
      }

      // If the origin payer is found
      found = true;

      uint last = s_paid[who].length - 1;

      // Switch the last element of the array
      // with the one to remove
      s_paid[who][i] = s_paid[who][last];

      // Remove the last element of the array
      delete s_paid[who][last];
      s_paid[who].length -= 1;

      break;
    }

    // Ensure that the origin payer has been found
    require(found);

    // Refund the fee to the origin payer
    origin.transfer(msg.value);
  }

  /// @notice Change the address of the treasury, the address to which
  /// the payments are forwarded to. Only the owner of the contract
  /// can execute this method.
  /// @param _treasury The new treasury address
  function setTreasury (address _treasury) external only_owner {
    treasury = _treasury;
  }
}