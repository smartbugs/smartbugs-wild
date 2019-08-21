// Full Contract Sources : https://github.com/DigixGlobal/dao-contracts
// File: @digix/cacp-contracts-dao/contracts/ACOwned.sol
pragma solidity ^0.4.25;
/// @title Owner based access control
/// @author DigixGlobal
contract ACOwned {

  address public owner;
  address public new_owner;
  bool is_ac_owned_init;

  /// @dev Modifier to check if msg.sender is the contract owner
  modifier if_owner() {
    require(is_owner());
    _;
  }

  function init_ac_owned()
           internal
           returns (bool _success)
  {
    if (is_ac_owned_init == false) {
      owner = msg.sender;
      is_ac_owned_init = true;
    }
    _success = true;
  }

  function is_owner()
           private
           constant
           returns (bool _is_owner)
  {
    _is_owner = (msg.sender == owner);
  }

  function change_owner(address _new_owner)
           if_owner()
           public
           returns (bool _success)
  {
    new_owner = _new_owner;
    _success = true;
  }

  function claim_ownership()
           public
           returns (bool _success)
  {
    require(msg.sender == new_owner);
    owner = new_owner;
    _success = true;
  }
}

// File: @digix/cacp-contracts-dao/contracts/Constants.sol
/// @title Some useful constants
/// @author DigixGlobal
contract Constants {
  address constant NULL_ADDRESS = address(0x0);
  uint256 constant ZERO = uint256(0);
  bytes32 constant EMPTY = bytes32(0x0);
}

// File: @digix/cacp-contracts-dao/contracts/ContractResolver.sol
/// @title Contract Name Registry
/// @author DigixGlobal
contract ContractResolver is ACOwned, Constants {

  mapping (bytes32 => address) contracts;
  bool public locked_forever;

  modifier unless_registered(bytes32 _key) {
    require(contracts[_key] == NULL_ADDRESS);
    _;
  }

  modifier if_owner_origin() {
    require(tx.origin == owner);
    _;
  }

  /// Function modifier to check if msg.sender corresponds to the resolved address of a given key
  /// @param _contract The resolver key
  modifier if_sender_is(bytes32 _contract) {
    require(msg.sender == get_contract(_contract));
    _;
  }

  modifier if_not_locked() {
    require(locked_forever == false);
    _;
  }

  /// @dev ContractResolver constructor will perform the following: 1. Set msg.sender as the contract owner.
  constructor() public
  {
    require(init_ac_owned());
    locked_forever = false;
  }

  /// @dev Called at contract initialization
  /// @param _key bytestring for CACP name
  /// @param _contract_address The address of the contract to be registered
  /// @return _success if the operation is successful
  function init_register_contract(bytes32 _key, address _contract_address)
           if_owner_origin()
           if_not_locked()
           unless_registered(_key)
           public
           returns (bool _success)
  {
    require(_contract_address != NULL_ADDRESS);
    contracts[_key] = _contract_address;
    _success = true;
  }

  /// @dev Lock the resolver from any further modifications.  This can only be called from the owner
  /// @return _success if the operation is successful
  function lock_resolver_forever()
           if_owner
           public
           returns (bool _success)
  {
    locked_forever = true;
    _success = true;
  }

  /// @dev Get address of a contract
  /// @param _key the bytestring name of the contract to look up
  /// @return _contract the address of the contract
  function get_contract(bytes32 _key)
           public
           view
           returns (address _contract)
  {
    require(contracts[_key] != NULL_ADDRESS);
    _contract = contracts[_key];
  }
}

// File: @digix/cacp-contracts-dao/contracts/ResolverClient.sol
/// @title Contract Resolver Interface
/// @author DigixGlobal
contract ResolverClient {

  /// The address of the resolver contract for this project
  address public resolver;
  bytes32 public key;

  /// Make our own address available to us as a constant
  address public CONTRACT_ADDRESS;

  /// Function modifier to check if msg.sender corresponds to the resolved address of a given key
  /// @param _contract The resolver key
  modifier if_sender_is(bytes32 _contract) {
    require(sender_is(_contract));
    _;
  }

  function sender_is(bytes32 _contract) internal view returns (bool _isFrom) {
    _isFrom = msg.sender == ContractResolver(resolver).get_contract(_contract);
  }

  modifier if_sender_is_from(bytes32[3] _contracts) {
    require(sender_is_from(_contracts));
    _;
  }

  function sender_is_from(bytes32[3] _contracts) internal view returns (bool _isFrom) {
    uint256 _n = _contracts.length;
    for (uint256 i = 0; i < _n; i++) {
      if (_contracts[i] == bytes32(0x0)) continue;
      if (msg.sender == ContractResolver(resolver).get_contract(_contracts[i])) {
        _isFrom = true;
        break;
      }
    }
  }

  /// Function modifier to check resolver's locking status.
  modifier unless_resolver_is_locked() {
    require(is_locked() == false);
    _;
  }

  /// @dev Initialize new contract
  /// @param _key the resolver key for this contract
  /// @return _success if the initialization is successful
  function init(bytes32 _key, address _resolver)
           internal
           returns (bool _success)
  {
    bool _is_locked = ContractResolver(_resolver).locked_forever();
    if (_is_locked == false) {
      CONTRACT_ADDRESS = address(this);
      resolver = _resolver;
      key = _key;
      require(ContractResolver(resolver).init_register_contract(key, CONTRACT_ADDRESS));
      _success = true;
    }  else {
      _success = false;
    }
  }

  /// @dev Check if resolver is locked
  /// @return _locked if the resolver is currently locked
  function is_locked()
           private
           view
           returns (bool _locked)
  {
    _locked = ContractResolver(resolver).locked_forever();
  }

  /// @dev Get the address of a contract
  /// @param _key the resolver key to look up
  /// @return _contract the address of the contract
  function get_contract(bytes32 _key)
           public
           view
           returns (address _contract)
  {
    _contract = ContractResolver(resolver).get_contract(_key);
  }
}

// File: @digix/solidity-collections/contracts/lib/DoublyLinkedList.sol
library DoublyLinkedList {

  struct Item {
    bytes32 item;
    uint256 previous_index;
    uint256 next_index;
  }

  struct Data {
    uint256 first_index;
    uint256 last_index;
    uint256 count;
    mapping(bytes32 => uint256) item_index;
    mapping(uint256 => bool) valid_indexes;
    Item[] collection;
  }

  struct IndexedUint {
    mapping(bytes32 => Data) data;
  }

  struct IndexedAddress {
    mapping(bytes32 => Data) data;
  }

  struct IndexedBytes {
    mapping(bytes32 => Data) data;
  }

  struct Address {
    Data data;
  }

  struct Bytes {
    Data data;
  }

  struct Uint {
    Data data;
  }

  uint256 constant NONE = uint256(0);
  bytes32 constant EMPTY_BYTES = bytes32(0x0);
  address constant NULL_ADDRESS = address(0x0);

  function find(Data storage self, bytes32 _item)
           public
           constant
           returns (uint256 _item_index)
  {
    if ((self.item_index[_item] == NONE) && (self.count == NONE)) {
      _item_index = NONE;
    } else {
      _item_index = self.item_index[_item];
    }
  }

  function get(Data storage self, uint256 _item_index)
           public
           constant
           returns (bytes32 _item)
  {
    if (self.valid_indexes[_item_index] == true) {
      _item = self.collection[_item_index - 1].item;
    } else {
      _item = EMPTY_BYTES;
    }
  }

  function append(Data storage self, bytes32 _data)
           internal
           returns (bool _success)
  {
    if (find(self, _data) != NONE || _data == bytes32("")) { // rejects addition of empty values
      _success = false;
    } else {
      uint256 _index = uint256(self.collection.push(Item({item: _data, previous_index: self.last_index, next_index: NONE})));
      if (self.last_index == NONE) {
        if ((self.first_index != NONE) || (self.count != NONE)) {
          revert();
        } else {
          self.first_index = self.last_index = _index;
          self.count = 1;
        }
      } else {
        self.collection[self.last_index - 1].next_index = _index;
        self.last_index = _index;
        self.count++;
      }
      self.valid_indexes[_index] = true;
      self.item_index[_data] = _index;
      _success = true;
    }
  }

  function remove(Data storage self, uint256 _index)
           internal
           returns (bool _success)
  {
    if (self.valid_indexes[_index] == true) {
      Item memory item = self.collection[_index - 1];
      if (item.previous_index == NONE) {
        self.first_index = item.next_index;
      } else {
        self.collection[item.previous_index - 1].next_index = item.next_index;
      }

      if (item.next_index == NONE) {
        self.last_index = item.previous_index;
      } else {
        self.collection[item.next_index - 1].previous_index = item.previous_index;
      }
      delete self.collection[_index - 1];
      self.valid_indexes[_index] = false;
      delete self.item_index[item.item];
      self.count--;
      _success = true;
    } else {
      _success = false;
    }
  }

  function remove_item(Data storage self, bytes32 _item)
           internal
           returns (bool _success)
  {
    uint256 _item_index = find(self, _item);
    if (_item_index != NONE) {
      require(remove(self, _item_index));
      _success = true;
    } else {
      _success = false;
    }
    return _success;
  }

  function total(Data storage self)
           public
           constant
           returns (uint256 _total_count)
  {
    _total_count = self.count;
  }

  function start(Data storage self)
           public
           constant
           returns (uint256 _item_index)
  {
    _item_index = self.first_index;
    return _item_index;
  }

  function start_item(Data storage self)
           public
           constant
           returns (bytes32 _item)
  {
    uint256 _item_index = start(self);
    if (_item_index != NONE) {
      _item = get(self, _item_index);
    } else {
      _item = EMPTY_BYTES;
    }
  }

  function end(Data storage self)
           public
           constant
           returns (uint256 _item_index)
  {
    _item_index = self.last_index;
    return _item_index;
  }

  function end_item(Data storage self)
           public
           constant
           returns (bytes32 _item)
  {
    uint256 _item_index = end(self);
    if (_item_index != NONE) {
      _item = get(self, _item_index);
    } else {
      _item = EMPTY_BYTES;
    }
  }

  function valid(Data storage self, uint256 _item_index)
           public
           constant
           returns (bool _yes)
  {
    _yes = self.valid_indexes[_item_index];
    //_yes = ((_item_index - 1) < self.collection.length);
  }

  function valid_item(Data storage self, bytes32 _item)
           public
           constant
           returns (bool _yes)
  {
    uint256 _item_index = self.item_index[_item];
    _yes = self.valid_indexes[_item_index];
  }

  function previous(Data storage self, uint256 _current_index)
           public
           constant
           returns (uint256 _previous_index)
  {
    if (self.valid_indexes[_current_index] == true) {
      _previous_index = self.collection[_current_index - 1].previous_index;
    } else {
      _previous_index = NONE;
    }
  }

  function previous_item(Data storage self, bytes32 _current_item)
           public
           constant
           returns (bytes32 _previous_item)
  {
    uint256 _current_index = find(self, _current_item);
    if (_current_index != NONE) {
      uint256 _previous_index = previous(self, _current_index);
      _previous_item = get(self, _previous_index);
    } else {
      _previous_item = EMPTY_BYTES;
    }
  }

  function next(Data storage self, uint256 _current_index)
           public
           constant
           returns (uint256 _next_index)
  {
    if (self.valid_indexes[_current_index] == true) {
      _next_index = self.collection[_current_index - 1].next_index;
    } else {
      _next_index = NONE;
    }
  }

  function next_item(Data storage self, bytes32 _current_item)
           public
           constant
           returns (bytes32 _next_item)
  {
    uint256 _current_index = find(self, _current_item);
    if (_current_index != NONE) {
      uint256 _next_index = next(self, _current_index);
      _next_item = get(self, _next_index);
    } else {
      _next_item = EMPTY_BYTES;
    }
  }

  function find(Uint storage self, uint256 _item)
           public
           constant
           returns (uint256 _item_index)
  {
    _item_index = find(self.data, bytes32(_item));
  }

  function get(Uint storage self, uint256 _item_index)
           public
           constant
           returns (uint256 _item)
  {
    _item = uint256(get(self.data, _item_index));
  }


  function append(Uint storage self, uint256 _data)
           public
           returns (bool _success)
  {
    _success = append(self.data, bytes32(_data));
  }

  function remove(Uint storage self, uint256 _index)
           internal
           returns (bool _success)
  {
    _success = remove(self.data, _index);
  }

  function remove_item(Uint storage self, uint256 _item)
           public
           returns (bool _success)
  {
    _success = remove_item(self.data, bytes32(_item));
  }

  function total(Uint storage self)
           public
           constant
           returns (uint256 _total_count)
  {
    _total_count = total(self.data);
  }

  function start(Uint storage self)
           public
           constant
           returns (uint256 _index)
  {
    _index = start(self.data);
  }

  function start_item(Uint storage self)
           public
           constant
           returns (uint256 _start_item)
  {
    _start_item = uint256(start_item(self.data));
  }


  function end(Uint storage self)
           public
           constant
           returns (uint256 _index)
  {
    _index = end(self.data);
  }

  function end_item(Uint storage self)
           public
           constant
           returns (uint256 _end_item)
  {
    _end_item = uint256(end_item(self.data));
  }

  function valid(Uint storage self, uint256 _item_index)
           public
           constant
           returns (bool _yes)
  {
    _yes = valid(self.data, _item_index);
  }

  function valid_item(Uint storage self, uint256 _item)
           public
           constant
           returns (bool _yes)
  {
    _yes = valid_item(self.data, bytes32(_item));
  }

  function previous(Uint storage self, uint256 _current_index)
           public
           constant
           returns (uint256 _previous_index)
  {
    _previous_index = previous(self.data, _current_index);
  }

  function previous_item(Uint storage self, uint256 _current_item)
           public
           constant
           returns (uint256 _previous_item)
  {
    _previous_item = uint256(previous_item(self.data, bytes32(_current_item)));
  }

  function next(Uint storage self, uint256 _current_index)
           public
           constant
           returns (uint256 _next_index)
  {
    _next_index = next(self.data, _current_index);
  }

  function next_item(Uint storage self, uint256 _current_item)
           public
           constant
           returns (uint256 _next_item)
  {
    _next_item = uint256(next_item(self.data, bytes32(_current_item)));
  }

  function find(Address storage self, address _item)
           public
           constant
           returns (uint256 _item_index)
  {
    _item_index = find(self.data, bytes32(_item));
  }

  function get(Address storage self, uint256 _item_index)
           public
           constant
           returns (address _item)
  {
    _item = address(get(self.data, _item_index));
  }


  function find(IndexedUint storage self, bytes32 _collection_index, uint256 _item)
           public
           constant
           returns (uint256 _item_index)
  {
    _item_index = find(self.data[_collection_index], bytes32(_item));
  }

  function get(IndexedUint storage self, bytes32 _collection_index, uint256 _item_index)
           public
           constant
           returns (uint256 _item)
  {
    _item = uint256(get(self.data[_collection_index], _item_index));
  }


  function append(IndexedUint storage self, bytes32 _collection_index, uint256 _data)
           public
           returns (bool _success)
  {
    _success = append(self.data[_collection_index], bytes32(_data));
  }

  function remove(IndexedUint storage self, bytes32 _collection_index, uint256 _index)
           internal
           returns (bool _success)
  {
    _success = remove(self.data[_collection_index], _index);
  }

  function remove_item(IndexedUint storage self, bytes32 _collection_index, uint256 _item)
           public
           returns (bool _success)
  {
    _success = remove_item(self.data[_collection_index], bytes32(_item));
  }

  function total(IndexedUint storage self, bytes32 _collection_index)
           public
           constant
           returns (uint256 _total_count)
  {
    _total_count = total(self.data[_collection_index]);
  }

  function start(IndexedUint storage self, bytes32 _collection_index)
           public
           constant
           returns (uint256 _index)
  {
    _index = start(self.data[_collection_index]);
  }

  function start_item(IndexedUint storage self, bytes32 _collection_index)
           public
           constant
           returns (uint256 _start_item)
  {
    _start_item = uint256(start_item(self.data[_collection_index]));
  }


  function end(IndexedUint storage self, bytes32 _collection_index)
           public
           constant
           returns (uint256 _index)
  {
    _index = end(self.data[_collection_index]);
  }

  function end_item(IndexedUint storage self, bytes32 _collection_index)
           public
           constant
           returns (uint256 _end_item)
  {
    _end_item = uint256(end_item(self.data[_collection_index]));
  }

  function valid(IndexedUint storage self, bytes32 _collection_index, uint256 _item_index)
           public
           constant
           returns (bool _yes)
  {
    _yes = valid(self.data[_collection_index], _item_index);
  }

  function valid_item(IndexedUint storage self, bytes32 _collection_index, uint256 _item)
           public
           constant
           returns (bool _yes)
  {
    _yes = valid_item(self.data[_collection_index], bytes32(_item));
  }

  function previous(IndexedUint storage self, bytes32 _collection_index, uint256 _current_index)
           public
           constant
           returns (uint256 _previous_index)
  {
    _previous_index = previous(self.data[_collection_index], _current_index);
  }

  function previous_item(IndexedUint storage self, bytes32 _collection_index, uint256 _current_item)
           public
           constant
           returns (uint256 _previous_item)
  {
    _previous_item = uint256(previous_item(self.data[_collection_index], bytes32(_current_item)));
  }

  function next(IndexedUint storage self, bytes32 _collection_index, uint256 _current_index)
           public
           constant
           returns (uint256 _next_index)
  {
    _next_index = next(self.data[_collection_index], _current_index);
  }

  function next_item(IndexedUint storage self, bytes32 _collection_index, uint256 _current_item)
           public
           constant
           returns (uint256 _next_item)
  {
    _next_item = uint256(next_item(self.data[_collection_index], bytes32(_current_item)));
  }

  function append(Address storage self, address _data)
           public
           returns (bool _success)
  {
    _success = append(self.data, bytes32(_data));
  }

  function remove(Address storage self, uint256 _index)
           internal
           returns (bool _success)
  {
    _success = remove(self.data, _index);
  }


  function remove_item(Address storage self, address _item)
           public
           returns (bool _success)
  {
    _success = remove_item(self.data, bytes32(_item));
  }

  function total(Address storage self)
           public
           constant
           returns (uint256 _total_count)
  {
    _total_count = total(self.data);
  }

  function start(Address storage self)
           public
           constant
           returns (uint256 _index)
  {
    _index = start(self.data);
  }

  function start_item(Address storage self)
           public
           constant
           returns (address _start_item)
  {
    _start_item = address(start_item(self.data));
  }


  function end(Address storage self)
           public
           constant
           returns (uint256 _index)
  {
    _index = end(self.data);
  }

  function end_item(Address storage self)
           public
           constant
           returns (address _end_item)
  {
    _end_item = address(end_item(self.data));
  }

  function valid(Address storage self, uint256 _item_index)
           public
           constant
           returns (bool _yes)
  {
    _yes = valid(self.data, _item_index);
  }

  function valid_item(Address storage self, address _item)
           public
           constant
           returns (bool _yes)
  {
    _yes = valid_item(self.data, bytes32(_item));
  }

  function previous(Address storage self, uint256 _current_index)
           public
           constant
           returns (uint256 _previous_index)
  {
    _previous_index = previous(self.data, _current_index);
  }

  function previous_item(Address storage self, address _current_item)
           public
           constant
           returns (address _previous_item)
  {
    _previous_item = address(previous_item(self.data, bytes32(_current_item)));
  }

  function next(Address storage self, uint256 _current_index)
           public
           constant
           returns (uint256 _next_index)
  {
    _next_index = next(self.data, _current_index);
  }

  function next_item(Address storage self, address _current_item)
           public
           constant
           returns (address _next_item)
  {
    _next_item = address(next_item(self.data, bytes32(_current_item)));
  }

  function append(IndexedAddress storage self, bytes32 _collection_index, address _data)
           public
           returns (bool _success)
  {
    _success = append(self.data[_collection_index], bytes32(_data));
  }

  function remove(IndexedAddress storage self, bytes32 _collection_index, uint256 _index)
           internal
           returns (bool _success)
  {
    _success = remove(self.data[_collection_index], _index);
  }


  function remove_item(IndexedAddress storage self, bytes32 _collection_index, address _item)
           public
           returns (bool _success)
  {
    _success = remove_item(self.data[_collection_index], bytes32(_item));
  }

  function total(IndexedAddress storage self, bytes32 _collection_index)
           public
           constant
           returns (uint256 _total_count)
  {
    _total_count = total(self.data[_collection_index]);
  }

  function start(IndexedAddress storage self, bytes32 _collection_index)
           public
           constant
           returns (uint256 _index)
  {
    _index = start(self.data[_collection_index]);
  }

  function start_item(IndexedAddress storage self, bytes32 _collection_index)
           public
           constant
           returns (address _start_item)
  {
    _start_item = address(start_item(self.data[_collection_index]));
  }


  function end(IndexedAddress storage self, bytes32 _collection_index)
           public
           constant
           returns (uint256 _index)
  {
    _index = end(self.data[_collection_index]);
  }

  function end_item(IndexedAddress storage self, bytes32 _collection_index)
           public
           constant
           returns (address _end_item)
  {
    _end_item = address(end_item(self.data[_collection_index]));
  }

  function valid(IndexedAddress storage self, bytes32 _collection_index, uint256 _item_index)
           public
           constant
           returns (bool _yes)
  {
    _yes = valid(self.data[_collection_index], _item_index);
  }

  function valid_item(IndexedAddress storage self, bytes32 _collection_index, address _item)
           public
           constant
           returns (bool _yes)
  {
    _yes = valid_item(self.data[_collection_index], bytes32(_item));
  }

  function previous(IndexedAddress storage self, bytes32 _collection_index, uint256 _current_index)
           public
           constant
           returns (uint256 _previous_index)
  {
    _previous_index = previous(self.data[_collection_index], _current_index);
  }

  function previous_item(IndexedAddress storage self, bytes32 _collection_index, address _current_item)
           public
           constant
           returns (address _previous_item)
  {
    _previous_item = address(previous_item(self.data[_collection_index], bytes32(_current_item)));
  }

  function next(IndexedAddress storage self, bytes32 _collection_index, uint256 _current_index)
           public
           constant
           returns (uint256 _next_index)
  {
    _next_index = next(self.data[_collection_index], _current_index);
  }

  function next_item(IndexedAddress storage self, bytes32 _collection_index, address _current_item)
           public
           constant
           returns (address _next_item)
  {
    _next_item = address(next_item(self.data[_collection_index], bytes32(_current_item)));
  }


  function find(Bytes storage self, bytes32 _item)
           public
           constant
           returns (uint256 _item_index)
  {
    _item_index = find(self.data, _item);
  }

  function get(Bytes storage self, uint256 _item_index)
           public
           constant
           returns (bytes32 _item)
  {
    _item = get(self.data, _item_index);
  }


  function append(Bytes storage self, bytes32 _data)
           public
           returns (bool _success)
  {
    _success = append(self.data, _data);
  }

  function remove(Bytes storage self, uint256 _index)
           internal
           returns (bool _success)
  {
    _success = remove(self.data, _index);
  }


  function remove_item(Bytes storage self, bytes32 _item)
           public
           returns (bool _success)
  {
    _success = remove_item(self.data, _item);
  }

  function total(Bytes storage self)
           public
           constant
           returns (uint256 _total_count)
  {
    _total_count = total(self.data);
  }

  function start(Bytes storage self)
           public
           constant
           returns (uint256 _index)
  {
    _index = start(self.data);
  }

  function start_item(Bytes storage self)
           public
           constant
           returns (bytes32 _start_item)
  {
    _start_item = start_item(self.data);
  }


  function end(Bytes storage self)
           public
           constant
           returns (uint256 _index)
  {
    _index = end(self.data);
  }

  function end_item(Bytes storage self)
           public
           constant
           returns (bytes32 _end_item)
  {
    _end_item = end_item(self.data);
  }

  function valid(Bytes storage self, uint256 _item_index)
           public
           constant
           returns (bool _yes)
  {
    _yes = valid(self.data, _item_index);
  }

  function valid_item(Bytes storage self, bytes32 _item)
           public
           constant
           returns (bool _yes)
  {
    _yes = valid_item(self.data, _item);
  }

  function previous(Bytes storage self, uint256 _current_index)
           public
           constant
           returns (uint256 _previous_index)
  {
    _previous_index = previous(self.data, _current_index);
  }

  function previous_item(Bytes storage self, bytes32 _current_item)
           public
           constant
           returns (bytes32 _previous_item)
  {
    _previous_item = previous_item(self.data, _current_item);
  }

  function next(Bytes storage self, uint256 _current_index)
           public
           constant
           returns (uint256 _next_index)
  {
    _next_index = next(self.data, _current_index);
  }

  function next_item(Bytes storage self, bytes32 _current_item)
           public
           constant
           returns (bytes32 _next_item)
  {
    _next_item = next_item(self.data, _current_item);
  }

  function append(IndexedBytes storage self, bytes32 _collection_index, bytes32 _data)
           public
           returns (bool _success)
  {
    _success = append(self.data[_collection_index], bytes32(_data));
  }

  function remove(IndexedBytes storage self, bytes32 _collection_index, uint256 _index)
           internal
           returns (bool _success)
  {
    _success = remove(self.data[_collection_index], _index);
  }


  function remove_item(IndexedBytes storage self, bytes32 _collection_index, bytes32 _item)
           public
           returns (bool _success)
  {
    _success = remove_item(self.data[_collection_index], bytes32(_item));
  }

  function total(IndexedBytes storage self, bytes32 _collection_index)
           public
           constant
           returns (uint256 _total_count)
  {
    _total_count = total(self.data[_collection_index]);
  }

  function start(IndexedBytes storage self, bytes32 _collection_index)
           public
           constant
           returns (uint256 _index)
  {
    _index = start(self.data[_collection_index]);
  }

  function start_item(IndexedBytes storage self, bytes32 _collection_index)
           public
           constant
           returns (bytes32 _start_item)
  {
    _start_item = bytes32(start_item(self.data[_collection_index]));
  }


  function end(IndexedBytes storage self, bytes32 _collection_index)
           public
           constant
           returns (uint256 _index)
  {
    _index = end(self.data[_collection_index]);
  }

  function end_item(IndexedBytes storage self, bytes32 _collection_index)
           public
           constant
           returns (bytes32 _end_item)
  {
    _end_item = bytes32(end_item(self.data[_collection_index]));
  }

  function valid(IndexedBytes storage self, bytes32 _collection_index, uint256 _item_index)
           public
           constant
           returns (bool _yes)
  {
    _yes = valid(self.data[_collection_index], _item_index);
  }

  function valid_item(IndexedBytes storage self, bytes32 _collection_index, bytes32 _item)
           public
           constant
           returns (bool _yes)
  {
    _yes = valid_item(self.data[_collection_index], bytes32(_item));
  }

  function previous(IndexedBytes storage self, bytes32 _collection_index, uint256 _current_index)
           public
           constant
           returns (uint256 _previous_index)
  {
    _previous_index = previous(self.data[_collection_index], _current_index);
  }

  function previous_item(IndexedBytes storage self, bytes32 _collection_index, bytes32 _current_item)
           public
           constant
           returns (bytes32 _previous_item)
  {
    _previous_item = bytes32(previous_item(self.data[_collection_index], bytes32(_current_item)));
  }

  function next(IndexedBytes storage self, bytes32 _collection_index, uint256 _current_index)
           public
           constant
           returns (uint256 _next_index)
  {
    _next_index = next(self.data[_collection_index], _current_index);
  }

  function next_item(IndexedBytes storage self, bytes32 _collection_index, bytes32 _current_item)
           public
           constant
           returns (bytes32 _next_item)
  {
    _next_item = bytes32(next_item(self.data[_collection_index], bytes32(_current_item)));
  }
}

// File: @digix/solidity-collections/contracts/abstract/IndexedAddressIteratorStorage.sol
/**
  @title Indexed Address IteratorStorage
  @author DigixGlobal Pte Ltd
  @notice This contract utilizes: [Doubly Linked List](/DoublyLinkedList)
*/
contract IndexedAddressIteratorStorage {

  using DoublyLinkedList for DoublyLinkedList.IndexedAddress;
  /**
    @notice Reads the first item from an Indexed Address Doubly Linked List
    @param _list The source list
    @param _collection_index Index of the Collection to evaluate
    @return {"_item" : "First item on the list"}
  */
  function read_first_from_indexed_addresses(DoublyLinkedList.IndexedAddress storage _list, bytes32 _collection_index)
           internal
           constant
           returns (address _item)
  {
    _item = _list.start_item(_collection_index);
  }

  /**
    @notice Reads the last item from an Indexed Address Doubly Linked list
    @param _list The source list
    @param _collection_index Index of the Collection to evaluate
    @return {"_item" : "First item on the list"}
  */
  function read_last_from_indexed_addresses(DoublyLinkedList.IndexedAddress storage _list, bytes32 _collection_index)
           internal
           constant
           returns (address _item)
  {
    _item = _list.end_item(_collection_index);
  }

  /**
    @notice Reads the next item from an Indexed Address Doubly Linked List based on the specified `_current_item`
    @param _list The source list
    @param _collection_index Index of the Collection to evaluate
    @param _current_item The current item to use as base line
    @return {"_item": "The next item on the list"}
  */
  function read_next_from_indexed_addresses(DoublyLinkedList.IndexedAddress storage _list, bytes32 _collection_index, address _current_item)
           internal
           constant
           returns (address _item)
  {
    _item = _list.next_item(_collection_index, _current_item);
  }

  /**
    @notice Reads the previous item from an Index Address Doubly Linked List based on the specified `_current_item`
    @param _list The source list
    @param _collection_index Index of the Collection to evaluate
    @param _current_item The current item to use as base line
    @return {"_item" : "The previous item on the list"}
  */
  function read_previous_from_indexed_addresses(DoublyLinkedList.IndexedAddress storage _list, bytes32 _collection_index, address _current_item)
           internal
           constant
           returns (address _item)
  {
    _item = _list.previous_item(_collection_index, _current_item);
  }


  /**
    @notice Reads the total number of items in an Indexed Address Doubly Linked List
    @param _list  The source list
    @param _collection_index Index of the Collection to evaluate
    @return {"_count": "Length of the Doubly Linked list"}
  */
  function read_total_indexed_addresses(DoublyLinkedList.IndexedAddress storage _list, bytes32 _collection_index)
           internal
           constant
           returns (uint256 _count)
  {
    _count = _list.total(_collection_index);
  }
}

// File: @digix/solidity-collections/contracts/abstract/UintIteratorStorage.sol
/**
  @title Uint Iterator Storage
  @author DigixGlobal Pte Ltd
*/
contract UintIteratorStorage {

  using DoublyLinkedList for DoublyLinkedList.Uint;

  /**
    @notice Returns the first item from a `DoublyLinkedList.Uint` list
    @param _list The DoublyLinkedList.Uint list
    @return {"_item": "The first item"}
  */
  function read_first_from_uints(DoublyLinkedList.Uint storage _list)
           internal
           constant
           returns (uint256 _item)
  {
    _item = _list.start_item();
  }

  /**
    @notice Returns the last item from a `DoublyLinkedList.Uint` list
    @param _list The DoublyLinkedList.Uint list
    @return {"_item": "The last item"}
  */
  function read_last_from_uints(DoublyLinkedList.Uint storage _list)
           internal
           constant
           returns (uint256 _item)
  {
    _item = _list.end_item();
  }

  /**
    @notice Returns the next item from a `DoublyLinkedList.Uint` list based on the specified `_current_item`
    @param _list The DoublyLinkedList.Uint list
    @param _current_item The current item
    @return {"_item": "The next item"}
  */
  function read_next_from_uints(DoublyLinkedList.Uint storage _list, uint256 _current_item)
           internal
           constant
           returns (uint256 _item)
  {
    _item = _list.next_item(_current_item);
  }

  /**
    @notice Returns the previous item from a `DoublyLinkedList.Uint` list based on the specified `_current_item`
    @param _list The DoublyLinkedList.Uint list
    @param _current_item The current item
    @return {"_item": "The previous item"}
  */
  function read_previous_from_uints(DoublyLinkedList.Uint storage _list, uint256 _current_item)
           internal
           constant
           returns (uint256 _item)
  {
    _item = _list.previous_item(_current_item);
  }

  /**
    @notice Returns the total count of itemsfrom a `DoublyLinkedList.Uint` list
    @param _list The DoublyLinkedList.Uint list
    @return {"_count": "The total count of items"}
  */
  function read_total_uints(DoublyLinkedList.Uint storage _list)
           internal
           constant
           returns (uint256 _count)
  {
    _count = _list.total();
  }
}

// File: @digix/cdap/contracts/storage/DirectoryStorage.sol
/**
@title Directory Storage contains information of a directory
@author DigixGlobal
*/
contract DirectoryStorage is IndexedAddressIteratorStorage, UintIteratorStorage {

  using DoublyLinkedList for DoublyLinkedList.IndexedAddress;
  using DoublyLinkedList for DoublyLinkedList.Uint;

  struct User {
    bytes32 document;
    bool active;
  }

  struct Group {
    bytes32 name;
    bytes32 document;
    uint256 role_id;
    mapping(address => User) members_by_address;
  }

  struct System {
    DoublyLinkedList.Uint groups;
    DoublyLinkedList.IndexedAddress groups_collection;
    mapping (uint256 => Group) groups_by_id;
    mapping (address => uint256) group_ids_by_address;
    mapping (uint256 => bytes32) roles_by_id;
    bool initialized;
    uint256 total_groups;
  }

  System system;

  /**
  @notice Initializes directory settings
  @return _success If directory initialization is successful
  */
  function initialize_directory()
           internal
           returns (bool _success)
  {
    require(system.initialized == false);
    system.total_groups = 0;
    system.initialized = true;
    internal_create_role(1, "root");
    internal_create_group(1, "root", "");
    _success = internal_update_add_user_to_group(1, tx.origin, "");
  }

  /**
  @notice Creates a new role with the given information
  @param _role_id Id of the new role
  @param _name Name of the new role
  @return {"_success": "If creation of new role is successful"}
  */
  function internal_create_role(uint256 _role_id, bytes32 _name)
           internal
           returns (bool _success)
  {
    require(_role_id > 0);
    require(_name != bytes32(0x0));
    system.roles_by_id[_role_id] = _name;
    _success = true;
  }

  /**
  @notice Returns the role's name of a role id
  @param _role_id Id of the role
  @return {"_name": "Name of the role"}
  */
  function read_role(uint256 _role_id)
           public
           constant
           returns (bytes32 _name)
  {
    _name = system.roles_by_id[_role_id];
  }

  /**
  @notice Creates a new group with the given information
  @param _role_id Role id of the new group
  @param _name Name of the new group
  @param _document Document of the new group
  @return {
    "_success": "If creation of the new group is successful",
    "_group_id: "Id of the new group"
  }
  */
  function internal_create_group(uint256 _role_id, bytes32 _name, bytes32 _document)
           internal
           returns (bool _success, uint256 _group_id)
  {
    require(_role_id > 0);
    require(read_role(_role_id) != bytes32(0x0));
    _group_id = ++system.total_groups;
    system.groups.append(_group_id);
    system.groups_by_id[_group_id].role_id = _role_id;
    system.groups_by_id[_group_id].name = _name;
    system.groups_by_id[_group_id].document = _document;
    _success = true;
  }

  /**
  @notice Returns the group's information
  @param _group_id Id of the group
  @return {
    "_role_id": "Role id of the group",
    "_name: "Name of the group",
    "_document: "Document of the group"
  }
  */
  function read_group(uint256 _group_id)
           public
           constant
           returns (uint256 _role_id, bytes32 _name, bytes32 _document, uint256 _members_count)
  {
    if (system.groups.valid_item(_group_id)) {
      _role_id = system.groups_by_id[_group_id].role_id;
      _name = system.groups_by_id[_group_id].name;
      _document = system.groups_by_id[_group_id].document;
      _members_count = read_total_indexed_addresses(system.groups_collection, bytes32(_group_id));
    } else {
      _role_id = 0;
      _name = "invalid";
      _document = "";
      _members_count = 0;
    }
  }

  /**
  @notice Adds new user with the given information to a group
  @param _group_id Id of the group
  @param _user Address of the new user
  @param _document Information of the new user
  @return {"_success": "If adding new user to a group is successful"}
  */
  function internal_update_add_user_to_group(uint256 _group_id, address _user, bytes32 _document)
           internal
           returns (bool _success)
  {
    if (system.groups_by_id[_group_id].members_by_address[_user].active == false && system.group_ids_by_address[_user] == 0 && system.groups_by_id[_group_id].role_id != 0) {

      system.groups_by_id[_group_id].members_by_address[_user].active = true;
      system.group_ids_by_address[_user] = _group_id;
      system.groups_collection.append(bytes32(_group_id), _user);
      system.groups_by_id[_group_id].members_by_address[_user].document = _document;
      _success = true;
    } else {
      _success = false;
    }
  }

  /**
  @notice Removes user from its group
  @param _user Address of the user
  @return {"_success": "If removing of user is successful"}
  */
  function internal_destroy_group_user(address _user)
           internal
           returns (bool _success)
  {
    uint256 _group_id = system.group_ids_by_address[_user];
    if ((_group_id == 1) && (system.groups_collection.total(bytes32(_group_id)) == 1)) {
      _success = false;
    } else {
      system.groups_by_id[_group_id].members_by_address[_user].active = false;
      system.group_ids_by_address[_user] = 0;
      delete system.groups_by_id[_group_id].members_by_address[_user];
      _success = system.groups_collection.remove_item(bytes32(_group_id), _user);
    }
  }

  /**
  @notice Returns the role id of a user
  @param _user Address of a user
  @return {"_role_id": "Role id of the user"}
  */
  function read_user_role_id(address _user)
           constant
           public
           returns (uint256 _role_id)
  {
    uint256 _group_id = system.group_ids_by_address[_user];
    _role_id = system.groups_by_id[_group_id].role_id;
  }

  /**
  @notice Returns the user's information
  @param _user Address of the user
  @return {
    "_group_id": "Group id of the user",
    "_role_id": "Role id of the user",
    "_document": "Information of the user"
  }
  */
  function read_user(address _user)
           public
           constant
           returns (uint256 _group_id, uint256 _role_id, bytes32 _document)
  {
    _group_id = system.group_ids_by_address[_user];
    _role_id = system.groups_by_id[_group_id].role_id;
    _document = system.groups_by_id[_group_id].members_by_address[_user].document;
  }

  /**
  @notice Returns the id of the first group
  @return {"_group_id": "Id of the first group"}
  */
  function read_first_group()
           view
           external
           returns (uint256 _group_id)
  {
    _group_id = read_first_from_uints(system.groups);
  }

  /**
  @notice Returns the id of the last group
  @return {"_group_id": "Id of the last group"}
  */
  function read_last_group()
           view
           external
           returns (uint256 _group_id)
  {
    _group_id = read_last_from_uints(system.groups);
  }

  /**
  @notice Returns the id of the previous group depending on the given current group
  @param _current_group_id Id of the current group
  @return {"_group_id": "Id of the previous group"}
  */
  function read_previous_group_from_group(uint256 _current_group_id)
           view
           external
           returns (uint256 _group_id)
  {
    _group_id = read_previous_from_uints(system.groups, _current_group_id);
  }

  /**
  @notice Returns the id of the next group depending on the given current group
  @param _current_group_id Id of the current group
  @return {"_group_id": "Id of the next group"}
  */
  function read_next_group_from_group(uint256 _current_group_id)
           view
           external
           returns (uint256 _group_id)
  {
    _group_id = read_next_from_uints(system.groups, _current_group_id);
  }

  /**
  @notice Returns the total number of groups
  @return {"_total_groups": "Total number of groups"}
  */
  function read_total_groups()
           view
           external
           returns (uint256 _total_groups)
  {
    _total_groups = read_total_uints(system.groups);
  }

  /**
  @notice Returns the first user of a group
  @param _group_id Id of the group
  @return {"_user": "Address of the user"}
  */
  function read_first_user_in_group(bytes32 _group_id)
           view
           external
           returns (address _user)
  {
    _user = read_first_from_indexed_addresses(system.groups_collection, bytes32(_group_id));
  }

  /**
  @notice Returns the last user of a group
  @param _group_id Id of the group
  @return {"_user": "Address of the user"}
  */
  function read_last_user_in_group(bytes32 _group_id)
           view
           external
           returns (address _user)
  {
    _user = read_last_from_indexed_addresses(system.groups_collection, bytes32(_group_id));
  }

  /**
  @notice Returns the next user of a group depending on the given current user
  @param _group_id Id of the group
  @param _current_user Address of the current user
  @return {"_user": "Address of the next user"}
  */
  function read_next_user_in_group(bytes32 _group_id, address _current_user)
           view
           external
           returns (address _user)
  {
    _user = read_next_from_indexed_addresses(system.groups_collection, bytes32(_group_id), _current_user);
  }

  /**
  @notice Returns the previous user of a group depending on the given current user
  @param _group_id Id of the group
  @param _current_user Address of the current user
  @return {"_user": "Address of the last user"}
  */
  function read_previous_user_in_group(bytes32 _group_id, address _current_user)
           view
           external
           returns (address _user)
  {
    _user = read_previous_from_indexed_addresses(system.groups_collection, bytes32(_group_id), _current_user);
  }

  /**
  @notice Returns the total number of users of a group
  @param _group_id Id of the group
  @return {"_total_users": "Total number of users"}
  */
  function read_total_users_in_group(bytes32 _group_id)
           view
           external
           returns (uint256 _total_users)
  {
    _total_users = read_total_indexed_addresses(system.groups_collection, bytes32(_group_id));
  }
}

// File: openzeppelin-solidity/contracts/math/SafeMath.sol
/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {

  /**
  * @dev Multiplies two numbers, throws on overflow.
  */
  function mul(uint256 _a, uint256 _b) internal pure returns (uint256 c) {
    // Gas optimization: this is cheaper than asserting 'a' not being zero, but the
    // benefit is lost if 'b' is also tested.
    // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
    if (_a == 0) {
      return 0;
    }

    c = _a * _b;
    assert(c / _a == _b);
    return c;
  }

  /**
  * @dev Integer division of two numbers, truncating the quotient.
  */
  function div(uint256 _a, uint256 _b) internal pure returns (uint256) {
    // assert(_b > 0); // Solidity automatically throws when dividing by 0
    // uint256 c = _a / _b;
    // assert(_a == _b * c + _a % _b); // There is no case in which this doesn't hold
    return _a / _b;
  }

  /**
  * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
  */
  function sub(uint256 _a, uint256 _b) internal pure returns (uint256) {
    assert(_b <= _a);
    return _a - _b;
  }

  /**
  * @dev Adds two numbers, throws on overflow.
  */
  function add(uint256 _a, uint256 _b) internal pure returns (uint256 c) {
    c = _a + _b;
    assert(c >= _a);
    return c;
  }
}

// File: contracts/common/DaoConstants.sol
contract DaoConstants {
    using SafeMath for uint256;
    bytes32 EMPTY_BYTES = bytes32(0x0);
    address EMPTY_ADDRESS = address(0x0);


    bytes32 PROPOSAL_STATE_PREPROPOSAL = "proposal_state_preproposal";
    bytes32 PROPOSAL_STATE_DRAFT = "proposal_state_draft";
    bytes32 PROPOSAL_STATE_MODERATED = "proposal_state_moderated";
    bytes32 PROPOSAL_STATE_ONGOING = "proposal_state_ongoing";
    bytes32 PROPOSAL_STATE_CLOSED = "proposal_state_closed";
    bytes32 PROPOSAL_STATE_ARCHIVED = "proposal_state_archived";

    uint256 PRL_ACTION_STOP = 1;
    uint256 PRL_ACTION_PAUSE = 2;
    uint256 PRL_ACTION_UNPAUSE = 3;

    uint256 COLLATERAL_STATUS_UNLOCKED = 1;
    uint256 COLLATERAL_STATUS_LOCKED = 2;
    uint256 COLLATERAL_STATUS_CLAIMED = 3;

    bytes32 INTERMEDIATE_DGD_IDENTIFIER = "inter_dgd_id";
    bytes32 INTERMEDIATE_MODERATOR_DGD_IDENTIFIER = "inter_mod_dgd_id";
    bytes32 INTERMEDIATE_BONUS_CALCULATION_IDENTIFIER = "inter_bonus_calculation_id";

    // interactive contracts
    bytes32 CONTRACT_DAO = "dao";
    bytes32 CONTRACT_DAO_SPECIAL_PROPOSAL = "dao:special:proposal";
    bytes32 CONTRACT_DAO_STAKE_LOCKING = "dao:stake-locking";
    bytes32 CONTRACT_DAO_VOTING = "dao:voting";
    bytes32 CONTRACT_DAO_VOTING_CLAIMS = "dao:voting:claims";
    bytes32 CONTRACT_DAO_SPECIAL_VOTING_CLAIMS = "dao:svoting:claims";
    bytes32 CONTRACT_DAO_IDENTITY = "dao:identity";
    bytes32 CONTRACT_DAO_REWARDS_MANAGER = "dao:rewards-manager";
    bytes32 CONTRACT_DAO_REWARDS_MANAGER_EXTRAS = "dao:rewards-extras";
    bytes32 CONTRACT_DAO_ROLES = "dao:roles";
    bytes32 CONTRACT_DAO_FUNDING_MANAGER = "dao:funding-manager";
    bytes32 CONTRACT_DAO_WHITELISTING = "dao:whitelisting";
    bytes32 CONTRACT_DAO_INFORMATION = "dao:information";

    // service contracts
    bytes32 CONTRACT_SERVICE_ROLE = "service:role";
    bytes32 CONTRACT_SERVICE_DAO_INFO = "service:dao:info";
    bytes32 CONTRACT_SERVICE_DAO_LISTING = "service:dao:listing";
    bytes32 CONTRACT_SERVICE_DAO_CALCULATOR = "service:dao:calculator";

    // storage contracts
    bytes32 CONTRACT_STORAGE_DAO = "storage:dao";
    bytes32 CONTRACT_STORAGE_DAO_COUNTER = "storage:dao:counter";
    bytes32 CONTRACT_STORAGE_DAO_UPGRADE = "storage:dao:upgrade";
    bytes32 CONTRACT_STORAGE_DAO_IDENTITY = "storage:dao:identity";
    bytes32 CONTRACT_STORAGE_DAO_POINTS = "storage:dao:points";
    bytes32 CONTRACT_STORAGE_DAO_SPECIAL = "storage:dao:special";
    bytes32 CONTRACT_STORAGE_DAO_CONFIG = "storage:dao:config";
    bytes32 CONTRACT_STORAGE_DAO_STAKE = "storage:dao:stake";
    bytes32 CONTRACT_STORAGE_DAO_REWARDS = "storage:dao:rewards";
    bytes32 CONTRACT_STORAGE_DAO_WHITELISTING = "storage:dao:whitelisting";
    bytes32 CONTRACT_STORAGE_INTERMEDIATE_RESULTS = "storage:intermediate:results";

    bytes32 CONTRACT_DGD_TOKEN = "t:dgd";
    bytes32 CONTRACT_DGX_TOKEN = "t:dgx";
    bytes32 CONTRACT_BADGE_TOKEN = "t:badge";

    uint8 ROLES_ROOT = 1;
    uint8 ROLES_FOUNDERS = 2;
    uint8 ROLES_PRLS = 3;
    uint8 ROLES_KYC_ADMINS = 4;

    uint256 QUARTER_DURATION = 90 days;

    bytes32 CONFIG_MINIMUM_LOCKED_DGD = "min_dgd_participant";
    bytes32 CONFIG_MINIMUM_DGD_FOR_MODERATOR = "min_dgd_moderator";
    bytes32 CONFIG_MINIMUM_REPUTATION_FOR_MODERATOR = "min_reputation_moderator";

    bytes32 CONFIG_LOCKING_PHASE_DURATION = "locking_phase_duration";
    bytes32 CONFIG_QUARTER_DURATION = "quarter_duration";
    bytes32 CONFIG_VOTING_COMMIT_PHASE = "voting_commit_phase";
    bytes32 CONFIG_VOTING_PHASE_TOTAL = "voting_phase_total";
    bytes32 CONFIG_INTERIM_COMMIT_PHASE = "interim_voting_commit_phase";
    bytes32 CONFIG_INTERIM_PHASE_TOTAL = "interim_voting_phase_total";

    bytes32 CONFIG_DRAFT_QUORUM_FIXED_PORTION_NUMERATOR = "draft_quorum_fixed_numerator";
    bytes32 CONFIG_DRAFT_QUORUM_FIXED_PORTION_DENOMINATOR = "draft_quorum_fixed_denominator";
    bytes32 CONFIG_DRAFT_QUORUM_SCALING_FACTOR_NUMERATOR = "draft_quorum_sfactor_numerator";
    bytes32 CONFIG_DRAFT_QUORUM_SCALING_FACTOR_DENOMINATOR = "draft_quorum_sfactor_denominator";
    bytes32 CONFIG_VOTING_QUORUM_FIXED_PORTION_NUMERATOR = "vote_quorum_fixed_numerator";
    bytes32 CONFIG_VOTING_QUORUM_FIXED_PORTION_DENOMINATOR = "vote_quorum_fixed_denominator";
    bytes32 CONFIG_VOTING_QUORUM_SCALING_FACTOR_NUMERATOR = "vote_quorum_sfactor_numerator";
    bytes32 CONFIG_VOTING_QUORUM_SCALING_FACTOR_DENOMINATOR = "vote_quorum_sfactor_denominator";
    bytes32 CONFIG_FINAL_REWARD_SCALING_FACTOR_NUMERATOR = "final_reward_sfactor_numerator";
    bytes32 CONFIG_FINAL_REWARD_SCALING_FACTOR_DENOMINATOR = "final_reward_sfactor_denominator";

    bytes32 CONFIG_DRAFT_QUOTA_NUMERATOR = "draft_quota_numerator";
    bytes32 CONFIG_DRAFT_QUOTA_DENOMINATOR = "draft_quota_denominator";
    bytes32 CONFIG_VOTING_QUOTA_NUMERATOR = "voting_quota_numerator";
    bytes32 CONFIG_VOTING_QUOTA_DENOMINATOR = "voting_quota_denominator";

    bytes32 CONFIG_MINIMAL_QUARTER_POINT = "minimal_qp";
    bytes32 CONFIG_QUARTER_POINT_SCALING_FACTOR = "quarter_point_scaling_factor";
    bytes32 CONFIG_REPUTATION_POINT_SCALING_FACTOR = "rep_point_scaling_factor";

    bytes32 CONFIG_MODERATOR_MINIMAL_QUARTER_POINT = "minimal_mod_qp";
    bytes32 CONFIG_MODERATOR_QUARTER_POINT_SCALING_FACTOR = "mod_qp_scaling_factor";
    bytes32 CONFIG_MODERATOR_REPUTATION_POINT_SCALING_FACTOR = "mod_rep_point_scaling_factor";

    bytes32 CONFIG_QUARTER_POINT_DRAFT_VOTE = "quarter_point_draft_vote";
    bytes32 CONFIG_QUARTER_POINT_VOTE = "quarter_point_vote";
    bytes32 CONFIG_QUARTER_POINT_INTERIM_VOTE = "quarter_point_interim_vote";

    /// this is per 10000 ETHs
    bytes32 CONFIG_QUARTER_POINT_MILESTONE_COMPLETION_PER_10000ETH = "q_p_milestone_completion";

    bytes32 CONFIG_BONUS_REPUTATION_NUMERATOR = "bonus_reputation_numerator";
    bytes32 CONFIG_BONUS_REPUTATION_DENOMINATOR = "bonus_reputation_denominator";

    bytes32 CONFIG_SPECIAL_PROPOSAL_COMMIT_PHASE = "special_proposal_commit_phase";
    bytes32 CONFIG_SPECIAL_PROPOSAL_PHASE_TOTAL = "special_proposal_phase_total";

    bytes32 CONFIG_SPECIAL_QUOTA_NUMERATOR = "config_special_quota_numerator";
    bytes32 CONFIG_SPECIAL_QUOTA_DENOMINATOR = "config_special_quota_denominator";

    bytes32 CONFIG_SPECIAL_PROPOSAL_QUORUM_NUMERATOR = "special_quorum_numerator";
    bytes32 CONFIG_SPECIAL_PROPOSAL_QUORUM_DENOMINATOR = "special_quorum_denominator";

    bytes32 CONFIG_MAXIMUM_REPUTATION_DEDUCTION = "config_max_reputation_deduction";
    bytes32 CONFIG_PUNISHMENT_FOR_NOT_LOCKING = "config_punishment_not_locking";

    bytes32 CONFIG_REPUTATION_PER_EXTRA_QP_NUM = "config_rep_per_extra_qp_num";
    bytes32 CONFIG_REPUTATION_PER_EXTRA_QP_DEN = "config_rep_per_extra_qp_den";

    bytes32 CONFIG_MAXIMUM_MODERATOR_REPUTATION_DEDUCTION = "config_max_m_rp_deduction";
    bytes32 CONFIG_REPUTATION_PER_EXTRA_MODERATOR_QP_NUM = "config_rep_per_extra_m_qp_num";
    bytes32 CONFIG_REPUTATION_PER_EXTRA_MODERATOR_QP_DEN = "config_rep_per_extra_m_qp_den";

    bytes32 CONFIG_PORTION_TO_MODERATORS_NUM = "config_mod_portion_num";
    bytes32 CONFIG_PORTION_TO_MODERATORS_DEN = "config_mod_portion_den";

    bytes32 CONFIG_DRAFT_VOTING_PHASE = "config_draft_voting_phase";

    bytes32 CONFIG_REPUTATION_POINT_BOOST_FOR_BADGE = "config_rp_boost_per_badge";

    bytes32 CONFIG_VOTE_CLAIMING_DEADLINE = "config_claiming_deadline";

    bytes32 CONFIG_PREPROPOSAL_COLLATERAL = "config_preproposal_collateral";

    bytes32 CONFIG_MAX_FUNDING_FOR_NON_DIGIX = "config_max_funding_nonDigix";
    bytes32 CONFIG_MAX_MILESTONES_FOR_NON_DIGIX = "config_max_milestones_nonDigix";
    bytes32 CONFIG_NON_DIGIX_PROPOSAL_CAP_PER_QUARTER = "config_nonDigix_proposal_cap";

    bytes32 CONFIG_PROPOSAL_DEAD_DURATION = "config_dead_duration";
    bytes32 CONFIG_CARBON_VOTE_REPUTATION_BONUS = "config_cv_reputation";
}

// File: contracts/storage/DaoIdentityStorage.sol
contract DaoIdentityStorage is ResolverClient, DaoConstants, DirectoryStorage {

    // struct for KYC details
    // doc is the IPFS doc hash for any information regarding this KYC
    // id_expiration is the UTC timestamp at which this KYC will expire
    // at any time after this, the user's KYC is invalid, and that user
    // MUST re-KYC before doing any proposer related operation in DigixDAO
    struct KycDetails {
        bytes32 doc;
        uint256 id_expiration;
    }

    // a mapping of address to the KYC details
    mapping (address => KycDetails) kycInfo;

    constructor(address _resolver)
        public
    {
        require(init(CONTRACT_STORAGE_DAO_IDENTITY, _resolver));
        require(initialize_directory());
    }

    function create_group(uint256 _role_id, bytes32 _name, bytes32 _document)
        public
        returns (bool _success, uint256 _group_id)
    {
        require(sender_is(CONTRACT_DAO_IDENTITY));
        (_success, _group_id) = internal_create_group(_role_id, _name, _document);
        require(_success);
    }

    function create_role(uint256 _role_id, bytes32 _name)
        public
        returns (bool _success)
    {
        require(sender_is(CONTRACT_DAO_IDENTITY));
        _success = internal_create_role(_role_id, _name);
        require(_success);
    }

    function update_add_user_to_group(uint256 _group_id, address _user, bytes32 _document)
        public
        returns (bool _success)
    {
        require(sender_is(CONTRACT_DAO_IDENTITY));
        _success = internal_update_add_user_to_group(_group_id, _user, _document);
        require(_success);
    }

    function update_remove_group_user(address _user)
        public
        returns (bool _success)
    {
        require(sender_is(CONTRACT_DAO_IDENTITY));
        _success = internal_destroy_group_user(_user);
        require(_success);
    }

    function update_kyc(address _user, bytes32 _doc, uint256 _id_expiration)
        public
    {
        require(sender_is(CONTRACT_DAO_IDENTITY));
        kycInfo[_user].doc = _doc;
        kycInfo[_user].id_expiration = _id_expiration;
    }

    function read_kyc_info(address _user)
        public
        view
        returns (bytes32 _doc, uint256 _id_expiration)
    {
        _doc = kycInfo[_user].doc;
        _id_expiration = kycInfo[_user].id_expiration;
    }

    function is_kyc_approved(address _user)
        public
        view
        returns (bool _approved)
    {
        uint256 _id_expiration;
        (,_id_expiration) = read_kyc_info(_user);
        _approved = _id_expiration > now;
    }
}

// File: contracts/storage/DaoWhitelistingStorage.sol
// This contract is basically created to restrict read access to
// ethereum accounts, and whitelisted contracts
contract DaoWhitelistingStorage is ResolverClient, DaoConstants {

    // we want to avoid the scenario in which an on-chain bribing contract
    // can be deployed to distribute funds in a trustless way by verifying
    // on-chain votes. This mapping marks whether a contract address is whitelisted
    // to read from the read functions in DaoStorage, DaoSpecialStorage, etc.
    mapping (address => bool) public whitelist;

    constructor(address _resolver)
        public
    {
        require(init(CONTRACT_STORAGE_DAO_WHITELISTING, _resolver));
    }

    function setWhitelisted(address _contractAddress, bool _senderIsAllowedToRead)
        public
    {
        require(sender_is(CONTRACT_DAO_WHITELISTING));
        whitelist[_contractAddress] = _senderIsAllowedToRead;
    }
}

// File: contracts/common/DaoWhitelistingCommon.sol
contract DaoWhitelistingCommon is ResolverClient, DaoConstants {

    function daoWhitelistingStorage()
        internal
        view
        returns (DaoWhitelistingStorage _contract)
    {
        _contract = DaoWhitelistingStorage(get_contract(CONTRACT_STORAGE_DAO_WHITELISTING));
    }

    /**
    @notice Check if a certain address is whitelisted to read sensitive information in the storage layer
    @dev if the address is an account, it is allowed to read. If the address is a contract, it has to be in the whitelist
    */
    function senderIsAllowedToRead()
        internal
        view
        returns (bool _senderIsAllowedToRead)
    {
        // msg.sender is allowed to read only if its an EOA or a whitelisted contract
        _senderIsAllowedToRead = (msg.sender == tx.origin) || daoWhitelistingStorage().whitelist(msg.sender);
    }
}

// File: contracts/common/IdentityCommon.sol
contract IdentityCommon is DaoWhitelistingCommon {

    modifier if_root() {
        require(identity_storage().read_user_role_id(msg.sender) == ROLES_ROOT);
        _;
    }

    modifier if_founder() {
        require(is_founder());
        _;
    }

    function is_founder()
        internal
        view
        returns (bool _isFounder)
    {
        _isFounder = identity_storage().read_user_role_id(msg.sender) == ROLES_FOUNDERS;
    }

    modifier if_prl() {
        require(identity_storage().read_user_role_id(msg.sender) == ROLES_PRLS);
        _;
    }

    modifier if_kyc_admin() {
        require(identity_storage().read_user_role_id(msg.sender) == ROLES_KYC_ADMINS);
        _;
    }

    function identity_storage()
        internal
        view
        returns (DaoIdentityStorage _contract)
    {
        _contract = DaoIdentityStorage(get_contract(CONTRACT_STORAGE_DAO_IDENTITY));
    }
}

// File: contracts/interactive/DaoIdentity.sol
/**
@title Contract to manage the admin roles in DAO (founders, prls, kyc admins)
@author Digix Holdings
*/
contract DaoIdentity is IdentityCommon {

    /**
    @notice Constructor (create initial roles, groups)
    @param _resolver Address of Contract Resolver
    */
    constructor(address _resolver)
        public
    {
        require(init(CONTRACT_DAO_IDENTITY, _resolver));
        // create the three roles and the three corresponding groups
        // the root role, and root group are already created, with only the contract deployer in it
        // After deployment, the contract deployer will call addGroupUser to add a multi-sig to be another root
        // The multi-sig will then call removeGroupUser to remove the contract deployer from root role
        // From then on, the multi-sig will be the only root account
        identity_storage().create_role(ROLES_FOUNDERS, "founders");
        identity_storage().create_role(ROLES_PRLS, "prls");
        identity_storage().create_role(ROLES_KYC_ADMINS, "kycadmins");
        identity_storage().create_group(ROLES_FOUNDERS, "founders_group", ""); // group_id = 2
        identity_storage().create_group(ROLES_PRLS, "prls_group", ""); // group_id = 3
        identity_storage().create_group(ROLES_KYC_ADMINS, "kycadmins_group", ""); // group_id = 4
    }

    /**
    @notice Function to add an address to a group (only root can call this function)
    @param _group_id ID of the group to be added in
    @param _user Ethereum address of the user
    @param _doc hash of IPFS doc containing details of this user
    */
    function addGroupUser(uint256 _group_id, address _user, bytes32 _doc)
        public
        if_root()
    {
        identity_storage().update_add_user_to_group(_group_id, _user, _doc);
    }

    /**
    @notice Function to remove a user from group (only root can call this)
    @param _user Ethereum address of the user to be removed from their group
    */
    function removeGroupUser(address _user)
        public
        if_root()
    {
        identity_storage().update_remove_group_user(_user);
    }

    /**
    @notice Function to update the KYC data of user (expiry data of valid KYC) (can only be called by the KYC ADMIN role)
    @param _user Ethereum address of the user
    @param _doc hash of the IPFS doc containing kyc information about this user
    @param _id_expiration expiry date of the KYC
    */
    function updateKyc(address _user, bytes32 _doc, uint256 _id_expiration)
        public
        if_kyc_admin()
    {
        privateUpdateKyc(_user, _doc, _id_expiration);
    }

    /**
    @notice Function to update the KYC data of multiple users (expiry data of valid KYC) (can only be called by the KYC ADMIN role)
    @param _users Ethereum addresses of the users
    @param _docs hashes of the IPFS docs containing kyc information about these users
    @param _id_expirations expiry dates of the KYC docs for these users
    */
    function bulkUpdateKyc(address[] _users, bytes32[] _docs, uint256[] _id_expirations)
        external
        if_kyc_admin()
    {
        uint256 _n = _users.length;
        for (uint256 _i = 0; _i < _n; _i++) {
            privateUpdateKyc(_users[_i], _docs[_i], _id_expirations[_i]);
        }
    }

    function privateUpdateKyc(address _user, bytes32 _doc, uint256 _id_expiration)
        private
    {
        identity_storage().update_kyc(_user, _doc, _id_expiration);
    }
}