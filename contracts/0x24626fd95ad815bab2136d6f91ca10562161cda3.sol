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

/// @title Some useful constants
/// @author DigixGlobal
contract Constants {
  address constant NULL_ADDRESS = address(0x0);
  uint256 constant ZERO = uint256(0);
  bytes32 constant EMPTY = bytes32(0x0);
}

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

/**
  @title Bytes Iterator Interactive
  @author DigixGlobal Pte Ltd
*/
contract BytesIteratorInteractive {

  /**
    @notice Lists a Bytes collection from start or end
    @param _count Total number of Bytes items to return
    @param _function_first Function that returns the First Bytes item in the list
    @param _function_last Function that returns the last Bytes item in the list
    @param _function_next Function that returns the Next Bytes item in the list
    @param _function_previous Function that returns previous Bytes item in the list
    @param _from_start whether to read from start (or end) of the list
    @return {"_bytes_items" : "Collection of reversed Bytes list"}
  */
  function list_bytesarray(uint256 _count,
                                 function () external constant returns (bytes32) _function_first,
                                 function () external constant returns (bytes32) _function_last,
                                 function (bytes32) external constant returns (bytes32) _function_next,
                                 function (bytes32) external constant returns (bytes32) _function_previous,
                                 bool _from_start)
           internal
           constant
           returns (bytes32[] _bytes_items)
  {
    if (_from_start) {
      _bytes_items = private_list_bytes_from_bytes(_function_first(), _count, true, _function_last, _function_next);
    } else {
      _bytes_items = private_list_bytes_from_bytes(_function_last(), _count, true, _function_first, _function_previous);
    }
  }

  /**
    @notice Lists a Bytes collection from some `_current_item`, going forwards or backwards depending on `_from_start`
    @param _current_item The current Item
    @param _count Total number of Bytes items to return
    @param _function_first Function that returns the First Bytes item in the list
    @param _function_last Function that returns the last Bytes item in the list
    @param _function_next Function that returns the Next Bytes item in the list
    @param _function_previous Function that returns previous Bytes item in the list
    @param _from_start whether to read in the forwards ( or backwards) direction
    @return {"_bytes_items" :"Collection/list of Bytes"}
  */
  function list_bytesarray_from(bytes32 _current_item, uint256 _count,
                                function () external constant returns (bytes32) _function_first,
                                function () external constant returns (bytes32) _function_last,
                                function (bytes32) external constant returns (bytes32) _function_next,
                                function (bytes32) external constant returns (bytes32) _function_previous,
                                bool _from_start)
           internal
           constant
           returns (bytes32[] _bytes_items)
  {
    if (_from_start) {
      _bytes_items = private_list_bytes_from_bytes(_current_item, _count, false, _function_last, _function_next);
    } else {
      _bytes_items = private_list_bytes_from_bytes(_current_item, _count, false, _function_first, _function_previous);
    }
  }

  /**
    @notice A private function to lists a Bytes collection starting from some `_current_item` (which could be included or excluded), in the forwards or backwards direction
    @param _current_item The current Item
    @param _count Total number of Bytes items to return
    @param _including_current Whether the `_current_item` should be included in the result
    @param _function_last Function that returns the bytes where we stop reading more bytes
    @param _function_next Function that returns the next bytes to read after some bytes (could be backwards or forwards in the physical collection)
    @return {"_address_items" :"Collection/list of Bytes"}
  */
  function private_list_bytes_from_bytes(bytes32 _current_item, uint256 _count, bool _including_current,
                                 function () external constant returns (bytes32) _function_last,
                                 function (bytes32) external constant returns (bytes32) _function_next)
           private
           constant
           returns (bytes32[] _bytes32_items)
  {
    uint256 _i;
    uint256 _real_count = 0;
    bytes32 _last_item;

    _last_item = _function_last();
    if (_count == 0 || _last_item == bytes32(0x0)) {
      _bytes32_items = new bytes32[](0);
    } else {
      bytes32[] memory _items_temp = new bytes32[](_count);
      bytes32 _this_item;
      if (_including_current == true) {
        _items_temp[0] = _current_item;
        _real_count = 1;
      }
      _this_item = _current_item;
      for (_i = _real_count; (_i < _count) && (_this_item != _last_item);_i++) {
        _this_item = _function_next(_this_item);
        if (_this_item != bytes32(0x0)) {
          _real_count++;
          _items_temp[_i] = _this_item;
        }
      }

      _bytes32_items = new bytes32[](_real_count);
      for(_i = 0;_i < _real_count;_i++) {
        _bytes32_items[_i] = _items_temp[_i];
      }
    }
  }




  ////// DEPRECATED FUNCTIONS (old versions)

  /**
    @notice a private function to lists a Bytes collection starting from some `_current_item`, could be forwards or backwards
    @param _current_item The current Item
    @param _count Total number of Bytes items to return
    @param _function_last Function that returns the bytes where we stop reading more bytes
    @param _function_next Function that returns the next bytes to read after some bytes (could be backwards or forwards in the physical collection)
    @return {"_bytes_items" :"Collection/list of Bytes"}
  */
  /*function list_bytes_from_bytes(bytes32 _current_item, uint256 _count,
                                 function () external constant returns (bytes32) _function_last,
                                 function (bytes32) external constant returns (bytes32) _function_next)
           private
           constant
           returns (bytes32[] _bytes_items)
  {
    uint256 _i;
    uint256 _real_count = 0;

    if (_count == 0) {
      _bytes_items = new bytes32[](0);
    } else {
      bytes32[] memory _items_temp = new bytes32[](_count);

      bytes32 _start_item;
      bytes32 _last_item;

      _last_item = _function_last();

      if (_last_item != _current_item) {
        _start_item = _function_next(_current_item);
        if (_start_item != bytes32(0x0)) {
          _items_temp[0] = _start_item;
          _real_count = 1;
          for(_i = 1;(_i <= (_count - 1)) && (_start_item != _last_item);_i++) {
            _start_item = _function_next(_start_item);
            if (_start_item != bytes32(0x0)) {
              _real_count++;
              _items_temp[_i] = _start_item;
            }
          }
          _bytes_items = new bytes32[](_real_count);
          for(_i = 0;_i <= (_real_count - 1);_i++) {
            _bytes_items[_i] = _items_temp[_i];
          }
        } else {
          _bytes_items = new bytes32[](0);
        }
      } else {
        _bytes_items = new bytes32[](0);
      }
    }
  }*/

  /**
    @notice private function to list a Bytes collection starting from the start or end of the list
    @param _count Total number of Bytes item to return
    @param _function_total Function that returns the Total number of Bytes item in the list
    @param _function_first Function that returns the First Bytes item in the list
    @param _function_next Function that returns the Next Bytes item in the list
    @return {"_bytes_items" :"Collection/list of Bytes"}
  */
  /*function list_bytes_from_start_or_end(uint256 _count,
                                 function () external constant returns (uint256) _function_total,
                                 function () external constant returns (bytes32) _function_first,
                                 function (bytes32) external constant returns (bytes32) _function_next)

           private
           constant
           returns (bytes32[] _bytes_items)
  {
    uint256 _i;
    bytes32 _current_item;
    uint256 _real_count = _function_total();

    if (_count > _real_count) {
      _count = _real_count;
    }

    bytes32[] memory _items_tmp = new bytes32[](_count);

    if (_count > 0) {
      _current_item = _function_first();
      _items_tmp[0] = _current_item;

      for(_i = 1;_i <= (_count - 1);_i++) {
        _current_item = _function_next(_current_item);
        if (_current_item != bytes32(0x0)) {
          _items_tmp[_i] = _current_item;
        }
      }
      _bytes_items = _items_tmp;
    } else {
      _bytes_items = new bytes32[](0);
    }
  }*/
}

/**
  @title Address Iterator Interactive
  @author DigixGlobal Pte Ltd
*/
contract AddressIteratorInteractive {

  /**
    @notice Lists a Address collection from start or end
    @param _count Total number of Address items to return
    @param _function_first Function that returns the First Address item in the list
    @param _function_last Function that returns the last Address item in the list
    @param _function_next Function that returns the Next Address item in the list
    @param _function_previous Function that returns previous Address item in the list
    @param _from_start whether to read from start (or end) of the list
    @return {"_address_items" : "Collection of reversed Address list"}
  */
  function list_addresses(uint256 _count,
                                 function () external constant returns (address) _function_first,
                                 function () external constant returns (address) _function_last,
                                 function (address) external constant returns (address) _function_next,
                                 function (address) external constant returns (address) _function_previous,
                                 bool _from_start)
           internal
           constant
           returns (address[] _address_items)
  {
    if (_from_start) {
      _address_items = private_list_addresses_from_address(_function_first(), _count, true, _function_last, _function_next);
    } else {
      _address_items = private_list_addresses_from_address(_function_last(), _count, true, _function_first, _function_previous);
    }
  }



  /**
    @notice Lists a Address collection from some `_current_item`, going forwards or backwards depending on `_from_start`
    @param _current_item The current Item
    @param _count Total number of Address items to return
    @param _function_first Function that returns the First Address item in the list
    @param _function_last Function that returns the last Address item in the list
    @param _function_next Function that returns the Next Address item in the list
    @param _function_previous Function that returns previous Address item in the list
    @param _from_start whether to read in the forwards ( or backwards) direction
    @return {"_address_items" :"Collection/list of Address"}
  */
  function list_addresses_from(address _current_item, uint256 _count,
                                function () external constant returns (address) _function_first,
                                function () external constant returns (address) _function_last,
                                function (address) external constant returns (address) _function_next,
                                function (address) external constant returns (address) _function_previous,
                                bool _from_start)
           internal
           constant
           returns (address[] _address_items)
  {
    if (_from_start) {
      _address_items = private_list_addresses_from_address(_current_item, _count, false, _function_last, _function_next);
    } else {
      _address_items = private_list_addresses_from_address(_current_item, _count, false, _function_first, _function_previous);
    }
  }


  /**
    @notice a private function to lists a Address collection starting from some `_current_item` (which could be included or excluded), in the forwards or backwards direction
    @param _current_item The current Item
    @param _count Total number of Address items to return
    @param _including_current Whether the `_current_item` should be included in the result
    @param _function_last Function that returns the address where we stop reading more address
    @param _function_next Function that returns the next address to read after some address (could be backwards or forwards in the physical collection)
    @return {"_address_items" :"Collection/list of Address"}
  */
  function private_list_addresses_from_address(address _current_item, uint256 _count, bool _including_current,
                                 function () external constant returns (address) _function_last,
                                 function (address) external constant returns (address) _function_next)
           private
           constant
           returns (address[] _address_items)
  {
    uint256 _i;
    uint256 _real_count = 0;
    address _last_item;

    _last_item = _function_last();
    if (_count == 0 || _last_item == address(0x0)) {
      _address_items = new address[](0);
    } else {
      address[] memory _items_temp = new address[](_count);
      address _this_item;
      if (_including_current == true) {
        _items_temp[0] = _current_item;
        _real_count = 1;
      }
      _this_item = _current_item;
      for (_i = _real_count; (_i < _count) && (_this_item != _last_item);_i++) {
        _this_item = _function_next(_this_item);
        if (_this_item != address(0x0)) {
          _real_count++;
          _items_temp[_i] = _this_item;
        }
      }

      _address_items = new address[](_real_count);
      for(_i = 0;_i < _real_count;_i++) {
        _address_items[_i] = _items_temp[_i];
      }
    }
  }


  /** DEPRECATED
    @notice private function to list a Address collection starting from the start or end of the list
    @param _count Total number of Address item to return
    @param _function_total Function that returns the Total number of Address item in the list
    @param _function_first Function that returns the First Address item in the list
    @param _function_next Function that returns the Next Address item in the list
    @return {"_address_items" :"Collection/list of Address"}
  */
  /*function list_addresses_from_start_or_end(uint256 _count,
                                 function () external constant returns (uint256) _function_total,
                                 function () external constant returns (address) _function_first,
                                 function (address) external constant returns (address) _function_next)

           private
           constant
           returns (address[] _address_items)
  {
    uint256 _i;
    address _current_item;
    uint256 _real_count = _function_total();

    if (_count > _real_count) {
      _count = _real_count;
    }

    address[] memory _items_tmp = new address[](_count);

    if (_count > 0) {
      _current_item = _function_first();
      _items_tmp[0] = _current_item;

      for(_i = 1;_i <= (_count - 1);_i++) {
        _current_item = _function_next(_current_item);
        if (_current_item != address(0x0)) {
          _items_tmp[_i] = _current_item;
        }
      }
      _address_items = _items_tmp;
    } else {
      _address_items = new address[](0);
    }
  }*/

  /** DEPRECATED
    @notice a private function to lists a Address collection starting from some `_current_item`, could be forwards or backwards
    @param _current_item The current Item
    @param _count Total number of Address items to return
    @param _function_last Function that returns the bytes where we stop reading more bytes
    @param _function_next Function that returns the next bytes to read after some bytes (could be backwards or forwards in the physical collection)
    @return {"_address_items" :"Collection/list of Address"}
  */
  /*function list_addresses_from_byte(address _current_item, uint256 _count,
                                 function () external constant returns (address) _function_last,
                                 function (address) external constant returns (address) _function_next)
           private
           constant
           returns (address[] _address_items)
  {
    uint256 _i;
    uint256 _real_count = 0;

    if (_count == 0) {
      _address_items = new address[](0);
    } else {
      address[] memory _items_temp = new address[](_count);

      address _start_item;
      address _last_item;

      _last_item = _function_last();

      if (_last_item != _current_item) {
        _start_item = _function_next(_current_item);
        if (_start_item != address(0x0)) {
          _items_temp[0] = _start_item;
          _real_count = 1;
          for(_i = 1;(_i <= (_count - 1)) && (_start_item != _last_item);_i++) {
            _start_item = _function_next(_start_item);
            if (_start_item != address(0x0)) {
              _real_count++;
              _items_temp[_i] = _start_item;
            }
          }
          _address_items = new address[](_real_count);
          for(_i = 0;_i <= (_real_count - 1);_i++) {
            _address_items[_i] = _items_temp[_i];
          }
        } else {
          _address_items = new address[](0);
        }
      } else {
        _address_items = new address[](0);
      }
    }
  }*/
}

/**
  @title Indexed Bytes Iterator Interactive
  @author DigixGlobal Pte Ltd
*/
contract IndexedBytesIteratorInteractive {

  /**
    @notice Lists an indexed Bytes collection from start or end
    @param _collection_index Index of the Collection to list
    @param _count Total number of Bytes items to return
    @param _function_first Function that returns the First Bytes item in the list
    @param _function_last Function that returns the last Bytes item in the list
    @param _function_next Function that returns the Next Bytes item in the list
    @param _function_previous Function that returns previous Bytes item in the list
    @param _from_start whether to read from start (or end) of the list
    @return {"_bytes_items" : "Collection of reversed Bytes list"}
  */
  function list_indexed_bytesarray(bytes32 _collection_index, uint256 _count,
                              function (bytes32) external constant returns (bytes32) _function_first,
                              function (bytes32) external constant returns (bytes32) _function_last,
                              function (bytes32, bytes32) external constant returns (bytes32) _function_next,
                              function (bytes32, bytes32) external constant returns (bytes32) _function_previous,
                              bool _from_start)
           internal
           constant
           returns (bytes32[] _indexed_bytes_items)
  {
    if (_from_start) {
      _indexed_bytes_items = private_list_indexed_bytes_from_bytes(_collection_index, _function_first(_collection_index), _count, true, _function_last, _function_next);
    } else {
      _indexed_bytes_items = private_list_indexed_bytes_from_bytes(_collection_index, _function_last(_collection_index), _count, true, _function_first, _function_previous);
    }
  }

  /**
    @notice Lists an indexed Bytes collection from some `_current_item`, going forwards or backwards depending on `_from_start`
    @param _collection_index Index of the Collection to list
    @param _current_item The current Item
    @param _count Total number of Bytes items to return
    @param _function_first Function that returns the First Bytes item in the list
    @param _function_last Function that returns the last Bytes item in the list
    @param _function_next Function that returns the Next Bytes item in the list
    @param _function_previous Function that returns previous Bytes item in the list
    @param _from_start whether to read in the forwards ( or backwards) direction
    @return {"_bytes_items" :"Collection/list of Bytes"}
  */
  function list_indexed_bytesarray_from(bytes32 _collection_index, bytes32 _current_item, uint256 _count,
                                function (bytes32) external constant returns (bytes32) _function_first,
                                function (bytes32) external constant returns (bytes32) _function_last,
                                function (bytes32, bytes32) external constant returns (bytes32) _function_next,
                                function (bytes32, bytes32) external constant returns (bytes32) _function_previous,
                                bool _from_start)
           internal
           constant
           returns (bytes32[] _indexed_bytes_items)
  {
    if (_from_start) {
      _indexed_bytes_items = private_list_indexed_bytes_from_bytes(_collection_index, _current_item, _count, false, _function_last, _function_next);
    } else {
      _indexed_bytes_items = private_list_indexed_bytes_from_bytes(_collection_index, _current_item, _count, false, _function_first, _function_previous);
    }
  }

  /**
    @notice a private function to lists an indexed Bytes collection starting from some `_current_item` (which could be included or excluded), in the forwards or backwards direction
    @param _collection_index Index of the Collection to list
    @param _current_item The item where we start reading from the list
    @param _count Total number of Bytes items to return
    @param _including_current Whether the `_current_item` should be included in the result
    @param _function_last Function that returns the bytes where we stop reading more bytes
    @param _function_next Function that returns the next bytes to read after another bytes (could be backwards or forwards in the physical collection)
    @return {"_bytes_items" :"Collection/list of Bytes"}
  */
  function private_list_indexed_bytes_from_bytes(bytes32 _collection_index, bytes32 _current_item, uint256 _count, bool _including_current,
                                         function (bytes32) external constant returns (bytes32) _function_last,
                                         function (bytes32, bytes32) external constant returns (bytes32) _function_next)
           private
           constant
           returns (bytes32[] _indexed_bytes_items)
  {
    uint256 _i;
    uint256 _real_count = 0;
    bytes32 _last_item;

    _last_item = _function_last(_collection_index);
    if (_count == 0 || _last_item == bytes32(0x0)) {  // if count is 0 or the collection is empty, returns empty array
      _indexed_bytes_items = new bytes32[](0);
    } else {
      bytes32[] memory _items_temp = new bytes32[](_count);
      bytes32 _this_item;
      if (_including_current) {
        _items_temp[0] = _current_item;
        _real_count = 1;
      }
      _this_item = _current_item;
      for (_i = _real_count; (_i < _count) && (_this_item != _last_item);_i++) {
        _this_item = _function_next(_collection_index, _this_item);
        if (_this_item != bytes32(0x0)) {
          _real_count++;
          _items_temp[_i] = _this_item;
        }
      }

      _indexed_bytes_items = new bytes32[](_real_count);
      for(_i = 0;_i < _real_count;_i++) {
        _indexed_bytes_items[_i] = _items_temp[_i];
      }
    }
  }


  // old function, DEPRECATED
  /*function list_indexed_bytes_from_bytes(bytes32 _collection_index, bytes32 _current_item, uint256 _count,
                                         function (bytes32) external constant returns (bytes32) _function_last,
                                         function (bytes32, bytes32) external constant returns (bytes32) _function_next)
           private
           constant
           returns (bytes32[] _indexed_bytes_items)
  {
    uint256 _i;
    uint256 _real_count = 0;
    if (_count == 0) {
      _indexed_bytes_items = new bytes32[](0);
    } else {
      bytes32[] memory _items_temp = new bytes32[](_count);

      bytes32 _start_item;
      bytes32 _last_item;

      _last_item = _function_last(_collection_index);

      if (_last_item != _current_item) {
        _start_item = _function_next(_collection_index, _current_item);
        if (_start_item != bytes32(0x0)) {
          _items_temp[0] = _start_item;
          _real_count = 1;
          for(_i = 1;(_i <= (_count - 1)) && (_start_item != _last_item);_i++) {
            _start_item = _function_next(_collection_index, _start_item);
            if (_start_item != bytes32(0x0)) {
              _real_count++;
              _items_temp[_i] = _start_item;
            }
          }
          _indexed_bytes_items = new bytes32[](_real_count);
          for(_i = 0;_i <= (_real_count - 1);_i++) {
            _indexed_bytes_items[_i] = _items_temp[_i];
          }
        } else {
          _indexed_bytes_items = new bytes32[](0);
        }
      } else {
        _indexed_bytes_items = new bytes32[](0);
      }
    }
  }*/
}

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

/**
  @title Bytes Iterator Storage
  @author DigixGlobal Pte Ltd
*/
contract BytesIteratorStorage {

  // Initialize Doubly Linked List of Bytes
  using DoublyLinkedList for DoublyLinkedList.Bytes;

  /**
    @notice Reads the first item from the list of Bytes
    @param _list The source list
    @return {"_item": "The first item from the list"}
  */
  function read_first_from_bytesarray(DoublyLinkedList.Bytes storage _list)
           internal
           constant
           returns (bytes32 _item)
  {
    _item = _list.start_item();
  }

  /**
    @notice Reads the last item from the list of Bytes
    @param _list The source list
    @return {"_item": "The last item from the list"}
  */
  function read_last_from_bytesarray(DoublyLinkedList.Bytes storage _list)
           internal
           constant
           returns (bytes32 _item)
  {
    _item = _list.end_item();
  }

  /**
    @notice Reads the next item on the list of Bytes
    @param _list The source list
    @param _current_item The current item to be used as base line
    @return {"_item": "The next item from the list based on the specieid `_current_item`"}
    TODO: Need to verify what happens if the specified `_current_item` is the last item from the list
  */
  function read_next_from_bytesarray(DoublyLinkedList.Bytes storage _list, bytes32 _current_item)
           internal
           constant
           returns (bytes32 _item)
  {
    _item = _list.next_item(_current_item);
  }

  /**
    @notice Reads the previous item on the list of Bytes
    @param _list The source list
    @param _current_item The current item to be used as base line
    @return {"_item": "The previous item from the list based on the spcified `_current_item`"}
    TODO: Need to verify what happens if the specified `_current_item` is the first item from the list
  */
  function read_previous_from_bytesarray(DoublyLinkedList.Bytes storage _list, bytes32 _current_item)
           internal
           constant
           returns (bytes32 _item)
  {
    _item = _list.previous_item(_current_item);
  }

  /**
    @notice Reads the list of Bytes and returns the length of the list
    @param _list The source list
    @return {"count": "`uint256` The lenght of the list"}

  */
  function read_total_bytesarray(DoublyLinkedList.Bytes storage _list)
           internal
           constant
           returns (uint256 _count)
  {
    _count = _list.total();
  }
}

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

library DaoStructs {
    using DoublyLinkedList for DoublyLinkedList.Bytes;
    using SafeMath for uint256;
    bytes32 constant EMPTY_BYTES = bytes32(0x0);

    struct PrlAction {
        // UTC timestamp at which the PRL action was done
        uint256 at;

        // IPFS hash of the document summarizing the action
        bytes32 doc;

        // Type of action
        // check PRL_ACTION_* in "./../common/DaoConstants.sol"
        uint256 actionId;
    }

    struct Voting {
        // UTC timestamp at which the voting round starts
        uint256 startTime;

        // Mapping of whether a commit was used in this voting round
        mapping (bytes32 => bool) usedCommits;

        // Mapping of commits by address. These are the commits during the commit phase in a voting round
        // This only stores the most recent commit in the voting round
        // In case a vote is edited, the previous commit is overwritten by the new commit
        // Only this new commit is verified at the reveal phase
        mapping (address => bytes32) commits;

        // This mapping is updated after the reveal phase, when votes are revealed
        // It is a mapping of address to weight of vote
        // Weight implies the lockedDGDStake of the address, at the time of revealing
        // If the address voted "NO", or didn't vote, this would be 0
        mapping (address => uint256) yesVotes;

        // This mapping is updated after the reveal phase, when votes are revealed
        // It is a mapping of address to weight of vote
        // Weight implies the lockedDGDStake of the address, at the time of revealing
        // If the address voted "YES", or didn't vote, this would be 0
        mapping (address => uint256) noVotes;

        // Boolean whether the voting round passed or not
        bool passed;

        // Boolean whether the voting round results were claimed or not
        // refer the claimProposalVotingResult function in "./../interative/DaoVotingClaims.sol"
        bool claimed;

        // Boolean whether the milestone following this voting round was funded or not
        // The milestone is funded when the proposer calls claimFunding in "./../interactive/DaoFundingManager.sol"
        bool funded;
    }

    struct ProposalVersion {
        // IPFS doc hash of this version of the proposal
        bytes32 docIpfsHash;

        // UTC timestamp at which this version was created
        uint256 created;

        // The number of milestones in the proposal as per this version
        uint256 milestoneCount;

        // The final reward asked by the proposer for completion of the entire proposal
        uint256 finalReward;

        // List of fundings required by the proposal as per this version
        // The numbers are in wei
        uint256[] milestoneFundings;

        // When a proposal is finalized (calling Dao.finalizeProposal), the proposer can no longer add proposal versions
        // However, they can still add more details to this final proposal version, in the form of IPFS docs.
        // These IPFS docs are stored in this array
        bytes32[] moreDocs;
    }

    struct Proposal {
        // ID of the proposal. Also the IPFS hash of the first ProposalVersion
        bytes32 proposalId;

        // current state of the proposal
        // refer PROPOSAL_STATE_* in "./../common/DaoConstants.sol"
        bytes32 currentState;

        // UTC timestamp at which the proposal was created
        uint256 timeCreated;

        // DoublyLinkedList of IPFS doc hashes of the various versions of the proposal
        DoublyLinkedList.Bytes proposalVersionDocs;

        // Mapping of version (IPFS doc hash) to ProposalVersion struct
        mapping (bytes32 => ProposalVersion) proposalVersions;

        // Voting struct for the draft voting round
        Voting draftVoting;

        // Mapping of voting round index (starts from 0) to Voting struct
        // votingRounds[0] is the Voting round of the proposal, which lasts for get_uint_config(CONFIG_VOTING_PHASE_TOTAL)
        // votingRounds[i] for i>0 are the Interim Voting rounds of the proposal, which lasts for get_uint_config(CONFIG_INTERIM_PHASE_TOTAL)
        mapping (uint256 => Voting) votingRounds;

        // Every proposal has a collateral tied to it with a value of
        // get_uint_config(CONFIG_PREPROPOSAL_COLLATERAL) (refer "./../storage/DaoConfigsStorage.sol")
        // Collateral can be in different states
        // refer COLLATERAL_STATUS_* in "./../common/DaoConstants.sol"
        uint256 collateralStatus;
        uint256 collateralAmount;

        // The final version of the proposal
        // Every proposal needs to be finalized before it can be voted on
        // This is the IPFS doc hash of the final version
        bytes32 finalVersion;

        // List of PrlAction structs
        // These are all the actions done by the PRL on the proposal
        PrlAction[] prlActions;

        // Address of the user who created the proposal
        address proposer;

        // Address of the moderator who endorsed the proposal
        address endorser;

        // Boolean whether the proposal is paused/stopped at the moment
        bool isPausedOrStopped;

        // Boolean whether the proposal was created by a founder role
        bool isDigix;
    }

    function countVotes(Voting storage _voting, address[] _allUsers)
        external
        view
        returns (uint256 _for, uint256 _against)
    {
        uint256 _n = _allUsers.length;
        for (uint256 i = 0; i < _n; i++) {
            if (_voting.yesVotes[_allUsers[i]] > 0) {
                _for = _for.add(_voting.yesVotes[_allUsers[i]]);
            } else if (_voting.noVotes[_allUsers[i]] > 0) {
                _against = _against.add(_voting.noVotes[_allUsers[i]]);
            }
        }
    }

    // get the list of voters who voted _vote (true-yes/false-no)
    function listVotes(Voting storage _voting, address[] _allUsers, bool _vote)
        external
        view
        returns (address[] memory _voters, uint256 _length)
    {
        uint256 _n = _allUsers.length;
        uint256 i;
        _length = 0;
        _voters = new address[](_n);
        if (_vote == true) {
            for (i = 0; i < _n; i++) {
                if (_voting.yesVotes[_allUsers[i]] > 0) {
                    _voters[_length] = _allUsers[i];
                    _length++;
                }
            }
        } else {
            for (i = 0; i < _n; i++) {
                if (_voting.noVotes[_allUsers[i]] > 0) {
                    _voters[_length] = _allUsers[i];
                    _length++;
                }
            }
        }
    }

    function readVote(Voting storage _voting, address _voter)
        public
        view
        returns (bool _vote, uint256 _weight)
    {
        if (_voting.yesVotes[_voter] > 0) {
            _weight = _voting.yesVotes[_voter];
            _vote = true;
        } else {
            _weight = _voting.noVotes[_voter]; // if _voter didnt vote at all, the weight will be 0 anyway
            _vote = false;
        }
    }

    function revealVote(
        Voting storage _voting,
        address _voter,
        bool _vote,
        uint256 _weight
    )
        public
    {
        if (_vote) {
            _voting.yesVotes[_voter] = _weight;
        } else {
            _voting.noVotes[_voter] = _weight;
        }
    }

    function readVersion(ProposalVersion storage _version)
        public
        view
        returns (
            bytes32 _doc,
            uint256 _created,
            uint256[] _milestoneFundings,
            uint256 _finalReward
        )
    {
        _doc = _version.docIpfsHash;
        _created = _version.created;
        _milestoneFundings = _version.milestoneFundings;
        _finalReward = _version.finalReward;
    }

    // read the funding for a particular milestone of a finalized proposal
    // if _milestoneId is the same as _milestoneCount, it returns the final reward
    function readProposalMilestone(Proposal storage _proposal, uint256 _milestoneIndex)
        public
        view
        returns (uint256 _funding)
    {
        bytes32 _finalVersion = _proposal.finalVersion;
        uint256 _milestoneCount = _proposal.proposalVersions[_finalVersion].milestoneFundings.length;
        require(_milestoneIndex <= _milestoneCount);
        require(_finalVersion != EMPTY_BYTES); // the proposal must have been finalized

        if (_milestoneIndex < _milestoneCount) {
            _funding = _proposal.proposalVersions[_finalVersion].milestoneFundings[_milestoneIndex];
        } else {
            _funding = _proposal.proposalVersions[_finalVersion].finalReward;
        }
    }

    function addProposalVersion(
        Proposal storage _proposal,
        bytes32 _newDoc,
        uint256[] _newMilestoneFundings,
        uint256 _finalReward
    )
        public
    {
        _proposal.proposalVersionDocs.append(_newDoc);
        _proposal.proposalVersions[_newDoc].docIpfsHash = _newDoc;
        _proposal.proposalVersions[_newDoc].created = now;
        _proposal.proposalVersions[_newDoc].milestoneCount = _newMilestoneFundings.length;
        _proposal.proposalVersions[_newDoc].milestoneFundings = _newMilestoneFundings;
        _proposal.proposalVersions[_newDoc].finalReward = _finalReward;
    }

    struct SpecialProposal {
        // ID of the special proposal
        // This is the IPFS doc hash of the proposal
        bytes32 proposalId;

        // UTC timestamp at which the proposal was created
        uint256 timeCreated;

        // Voting struct for the special proposal
        Voting voting;

        // List of the new uint256 configs as per the special proposal
        uint256[] uintConfigs;

        // List of the new address configs as per the special proposal
        address[] addressConfigs;

        // List of the new bytes32 configs as per the special proposal
        bytes32[] bytesConfigs;

        // Address of the user who created the special proposal
        // This address should also be in the ROLES_FOUNDERS group
        // refer "./../storage/DaoIdentityStorage.sol"
        address proposer;
    }

    // All configs are as per the DaoConfigsStorage values at the time when
    // calculateGlobalRewardsBeforeNewQuarter is called by founder in that quarter
    struct DaoQuarterInfo {
        // The minimum quarter points required
        // below this, reputation will be deducted
        uint256 minimalParticipationPoint;

        // The scaling factor for quarter point
        uint256 quarterPointScalingFactor;

        // The scaling factor for reputation point
        uint256 reputationPointScalingFactor;

        // The summation of effectiveDGDs in the previous quarter
        // The effectiveDGDs represents the effective participation in DigixDAO in a quarter
        // Which depends on lockedDGDStake, quarter point and reputation point
        // This value is the summation of all participant effectiveDGDs
        // It will be used to calculate the fraction of effectiveDGD a user has,
        // which will determine his portion of DGX rewards for that quarter
        uint256 totalEffectiveDGDPreviousQuarter;

        // The minimum moderator quarter point required
        // below this, reputation will be deducted for moderators
        uint256 moderatorMinimalParticipationPoint;

        // the scaling factor for moderator quarter point
        uint256 moderatorQuarterPointScalingFactor;

        // the scaling factor for moderator reputation point
        uint256 moderatorReputationPointScalingFactor;

        // The summation of effectiveDGDs (only specific to moderators)
        uint256 totalEffectiveModeratorDGDLastQuarter;

        // UTC timestamp from which the DGX rewards for the previous quarter are distributable to Holders
        uint256 dgxDistributionDay;

        // This is the rewards pool for the previous quarter. This is the sum of the DGX fees coming in from the collector, and the demurrage that has incurred
        // when user call claimRewards() in the previous quarter.
        // more graphical explanation: https://ipfs.io/ipfs/QmZDgFFMbyF3dvuuDfoXv5F6orq4kaDPo7m3QvnseUguzo
        uint256 dgxRewardsPoolLastQuarter;

        // The summation of all dgxRewardsPoolLastQuarter up until this quarter
        uint256 sumRewardsFromBeginning;
    }

    // There are many function calls where all calculations/summations cannot be done in one transaction
    // and require multiple transactions.
    // This struct stores the intermediate results in between the calculating transactions
    // These intermediate results are stored in IntermediateResultsStorage
    struct IntermediateResults {
        // weight of "FOR" votes counted up until the current calculation step
        uint256 currentForCount;

        // weight of "AGAINST" votes counted up until the current calculation step
        uint256 currentAgainstCount;

        // summation of effectiveDGDs up until the iteration of calculation
        uint256 currentSumOfEffectiveBalance;

        // Address of user until which the calculation has been done
        address countedUntil;
    }
}

contract DaoStorage is DaoWhitelistingCommon, BytesIteratorStorage {
    using DoublyLinkedList for DoublyLinkedList.Bytes;
    using DaoStructs for DaoStructs.Voting;
    using DaoStructs for DaoStructs.Proposal;
    using DaoStructs for DaoStructs.ProposalVersion;

    // List of all the proposals ever created in DigixDAO
    DoublyLinkedList.Bytes allProposals;

    // mapping of Proposal struct by its ID
    // ID is also the IPFS doc hash of the first ever version of this proposal
    mapping (bytes32 => DaoStructs.Proposal) proposalsById;

    // mapping from state of a proposal to list of all proposals in that state
    // proposals are added/removed from the state's list as their states change
    // eg. when proposal is endorsed, when proposal is funded, etc
    mapping (bytes32 => DoublyLinkedList.Bytes) proposalsByState;

    constructor(address _resolver) public {
        require(init(CONTRACT_STORAGE_DAO, _resolver));
    }

    /////////////////////////////// READ FUNCTIONS //////////////////////////////

    /// @notice read all information and details of proposal
    /// @param _proposalId Proposal ID, i.e. hash of IPFS doc Proposal ID, i.e. hash of IPFS doc
    /// return {
    ///   "_doc": "Original IPFS doc of proposal, also ID of proposal",
    ///   "_proposer": "Address of the proposer",
    ///   "_endorser": "Address of the moderator that endorsed the proposal",
    ///   "_state": "Current state of the proposal",
    ///   "_timeCreated": "UTC timestamp at which proposal was created",
    ///   "_nVersions": "Number of versions of the proposal",
    ///   "_latestVersionDoc": "IPFS doc hash of the latest version of this proposal",
    ///   "_finalVersion": "If finalized, the version of the final proposal",
    ///   "_pausedOrStopped": "If the proposal is paused/stopped at the moment",
    ///   "_isDigixProposal": "If the proposal has been created by founder or not"
    /// }
    function readProposal(bytes32 _proposalId)
        public
        view
        returns (
            bytes32 _doc,
            address _proposer,
            address _endorser,
            bytes32 _state,
            uint256 _timeCreated,
            uint256 _nVersions,
            bytes32 _latestVersionDoc,
            bytes32 _finalVersion,
            bool _pausedOrStopped,
            bool _isDigixProposal
        )
    {
        require(senderIsAllowedToRead());
        DaoStructs.Proposal storage _proposal = proposalsById[_proposalId];
        _doc = _proposal.proposalId;
        _proposer = _proposal.proposer;
        _endorser = _proposal.endorser;
        _state = _proposal.currentState;
        _timeCreated = _proposal.timeCreated;
        _nVersions = read_total_bytesarray(_proposal.proposalVersionDocs);
        _latestVersionDoc = read_last_from_bytesarray(_proposal.proposalVersionDocs);
        _finalVersion = _proposal.finalVersion;
        _pausedOrStopped = _proposal.isPausedOrStopped;
        _isDigixProposal = _proposal.isDigix;
    }

    function readProposalProposer(bytes32 _proposalId)
        public
        view
        returns (address _proposer)
    {
        _proposer = proposalsById[_proposalId].proposer;
    }

    function readTotalPrlActions(bytes32 _proposalId)
        public
        view
        returns (uint256 _length)
    {
        _length = proposalsById[_proposalId].prlActions.length;
    }

    function readPrlAction(bytes32 _proposalId, uint256 _index)
        public
        view
        returns (uint256 _actionId, uint256 _time, bytes32 _doc)
    {
        DaoStructs.PrlAction[] memory _actions = proposalsById[_proposalId].prlActions;
        require(_index < _actions.length);
        _actionId = _actions[_index].actionId;
        _time = _actions[_index].at;
        _doc = _actions[_index].doc;
    }

    function readProposalDraftVotingResult(bytes32 _proposalId)
        public
        view
        returns (bool _result)
    {
        require(senderIsAllowedToRead());
        _result = proposalsById[_proposalId].draftVoting.passed;
    }

    function readProposalVotingResult(bytes32 _proposalId, uint256 _index)
        public
        view
        returns (bool _result)
    {
        require(senderIsAllowedToRead());
        _result = proposalsById[_proposalId].votingRounds[_index].passed;
    }

    function readProposalDraftVotingTime(bytes32 _proposalId)
        public
        view
        returns (uint256 _start)
    {
        require(senderIsAllowedToRead());
        _start = proposalsById[_proposalId].draftVoting.startTime;
    }

    function readProposalVotingTime(bytes32 _proposalId, uint256 _index)
        public
        view
        returns (uint256 _start)
    {
        require(senderIsAllowedToRead());
        _start = proposalsById[_proposalId].votingRounds[_index].startTime;
    }

    function readDraftVotingCount(bytes32 _proposalId, address[] _allUsers)
        external
        view
        returns (uint256 _for, uint256 _against)
    {
        require(senderIsAllowedToRead());
        return proposalsById[_proposalId].draftVoting.countVotes(_allUsers);
    }

    function readVotingCount(bytes32 _proposalId, uint256 _index, address[] _allUsers)
        external
        view
        returns (uint256 _for, uint256 _against)
    {
        require(senderIsAllowedToRead());
        return proposalsById[_proposalId].votingRounds[_index].countVotes(_allUsers);
    }

    function readVotingRoundVotes(bytes32 _proposalId, uint256 _index, address[] _allUsers, bool _vote)
        external
        view
        returns (address[] memory _voters, uint256 _length)
    {
        require(senderIsAllowedToRead());
        return proposalsById[_proposalId].votingRounds[_index].listVotes(_allUsers, _vote);
    }

    function readDraftVote(bytes32 _proposalId, address _voter)
        public
        view
        returns (bool _vote, uint256 _weight)
    {
        require(senderIsAllowedToRead());
        return proposalsById[_proposalId].draftVoting.readVote(_voter);
    }

    /// @notice returns the latest committed vote by a voter on a proposal
    /// @param _proposalId proposal ID
    /// @param _voter address of the voter
    /// @return {
    ///   "_commitHash": ""
    /// }
    function readComittedVote(bytes32 _proposalId, uint256 _index, address _voter)
        public
        view
        returns (bytes32 _commitHash)
    {
        require(senderIsAllowedToRead());
        _commitHash = proposalsById[_proposalId].votingRounds[_index].commits[_voter];
    }

    function readVote(bytes32 _proposalId, uint256 _index, address _voter)
        public
        view
        returns (bool _vote, uint256 _weight)
    {
        require(senderIsAllowedToRead());
        return proposalsById[_proposalId].votingRounds[_index].readVote(_voter);
    }

    /// @notice get all information and details of the first proposal
    /// return {
    ///   "_id": ""
    /// }
    function getFirstProposal()
        public
        view
        returns (bytes32 _id)
    {
        _id = read_first_from_bytesarray(allProposals);
    }

    /// @notice get all information and details of the last proposal
    /// return {
    ///   "_id": ""
    /// }
    function getLastProposal()
        public
        view
        returns (bytes32 _id)
    {
        _id = read_last_from_bytesarray(allProposals);
    }

    /// @notice get all information and details of proposal next to _proposalId
    /// @param _proposalId Proposal ID, i.e. hash of IPFS doc
    /// return {
    ///   "_id": ""
    /// }
    function getNextProposal(bytes32 _proposalId)
        public
        view
        returns (bytes32 _id)
    {
        _id = read_next_from_bytesarray(
            allProposals,
            _proposalId
        );
    }

    /// @notice get all information and details of proposal previous to _proposalId
    /// @param _proposalId Proposal ID, i.e. hash of IPFS doc
    /// return {
    ///   "_id": ""
    /// }
    function getPreviousProposal(bytes32 _proposalId)
        public
        view
        returns (bytes32 _id)
    {
        _id = read_previous_from_bytesarray(
            allProposals,
            _proposalId
        );
    }

    /// @notice get all information and details of the first proposal in state _stateId
    /// @param _stateId State ID of the proposal
    /// return {
    ///   "_id": ""
    /// }
    function getFirstProposalInState(bytes32 _stateId)
        public
        view
        returns (bytes32 _id)
    {
        require(senderIsAllowedToRead());
        _id = read_first_from_bytesarray(proposalsByState[_stateId]);
    }

    /// @notice get all information and details of the last proposal in state _stateId
    /// @param _stateId State ID of the proposal
    /// return {
    ///   "_id": ""
    /// }
    function getLastProposalInState(bytes32 _stateId)
        public
        view
        returns (bytes32 _id)
    {
        require(senderIsAllowedToRead());
        _id = read_last_from_bytesarray(proposalsByState[_stateId]);
    }

    /// @notice get all information and details of the next proposal to _proposalId in state _stateId
    /// @param _stateId State ID of the proposal
    /// return {
    ///   "_id": ""
    /// }
    function getNextProposalInState(bytes32 _stateId, bytes32 _proposalId)
        public
        view
        returns (bytes32 _id)
    {
        require(senderIsAllowedToRead());
        _id = read_next_from_bytesarray(
            proposalsByState[_stateId],
            _proposalId
        );
    }

    /// @notice get all information and details of the previous proposal to _proposalId in state _stateId
    /// @param _stateId State ID of the proposal
    /// return {
    ///   "_id": ""
    /// }
    function getPreviousProposalInState(bytes32 _stateId, bytes32 _proposalId)
        public
        view
        returns (bytes32 _id)
    {
        require(senderIsAllowedToRead());
        _id = read_previous_from_bytesarray(
            proposalsByState[_stateId],
            _proposalId
        );
    }

    /// @notice read proposal version details for a specific version
    /// @param _proposalId Proposal ID, i.e. hash of IPFS doc
    /// @param _version Version of proposal, i.e. hash of IPFS doc for specific version
    /// return {
    ///   "_doc": "",
    ///   "_created": "",
    ///   "_milestoneFundings": ""
    /// }
    function readProposalVersion(bytes32 _proposalId, bytes32 _version)
        public
        view
        returns (
            bytes32 _doc,
            uint256 _created,
            uint256[] _milestoneFundings,
            uint256 _finalReward
        )
    {
        return proposalsById[_proposalId].proposalVersions[_version].readVersion();
    }

    /**
    @notice Read the fundings of a finalized proposal
    @return {
        "_fundings": "fundings for the milestones",
        "_finalReward": "the final reward"
    }
    */
    function readProposalFunding(bytes32 _proposalId)
        public
        view
        returns (uint256[] memory _fundings, uint256 _finalReward)
    {
        require(senderIsAllowedToRead());
        bytes32 _finalVersion = proposalsById[_proposalId].finalVersion;
        require(_finalVersion != EMPTY_BYTES);
        _fundings = proposalsById[_proposalId].proposalVersions[_finalVersion].milestoneFundings;
        _finalReward = proposalsById[_proposalId].proposalVersions[_finalVersion].finalReward;
    }

    function readProposalMilestone(bytes32 _proposalId, uint256 _index)
        public
        view
        returns (uint256 _funding)
    {
        require(senderIsAllowedToRead());
        _funding = proposalsById[_proposalId].readProposalMilestone(_index);
    }

    /// @notice get proposal version details for the first version
    /// @param _proposalId Proposal ID, i.e. hash of IPFS doc
    /// return {
    ///   "_version": ""
    /// }
    function getFirstProposalVersion(bytes32 _proposalId)
        public
        view
        returns (bytes32 _version)
    {
        DaoStructs.Proposal storage _proposal = proposalsById[_proposalId];
        _version = read_first_from_bytesarray(_proposal.proposalVersionDocs);
    }

    /// @notice get proposal version details for the last version
    /// @param _proposalId Proposal ID, i.e. hash of IPFS doc
    /// return {
    ///   "_version": ""
    /// }
    function getLastProposalVersion(bytes32 _proposalId)
        public
        view
        returns (bytes32 _version)
    {
        DaoStructs.Proposal storage _proposal = proposalsById[_proposalId];
        _version = read_last_from_bytesarray(_proposal.proposalVersionDocs);
    }

    /// @notice get proposal version details for the next version to _version
    /// @param _proposalId Proposal ID, i.e. hash of IPFS doc
    /// @param _version Version of proposal
    /// return {
    ///   "_nextVersion": ""
    /// }
    function getNextProposalVersion(bytes32 _proposalId, bytes32 _version)
        public
        view
        returns (bytes32 _nextVersion)
    {
        DaoStructs.Proposal storage _proposal = proposalsById[_proposalId];
        _nextVersion = read_next_from_bytesarray(
            _proposal.proposalVersionDocs,
            _version
        );
    }

    /// @notice get proposal version details for the previous version to _version
    /// @param _proposalId Proposal ID, i.e. hash of IPFS doc
    /// @param _version Version of proposal
    /// return {
    ///   "_previousVersion": ""
    /// }
    function getPreviousProposalVersion(bytes32 _proposalId, bytes32 _version)
        public
        view
        returns (bytes32 _previousVersion)
    {
        DaoStructs.Proposal storage _proposal = proposalsById[_proposalId];
        _previousVersion = read_previous_from_bytesarray(
            _proposal.proposalVersionDocs,
            _version
        );
    }

    function isDraftClaimed(bytes32 _proposalId)
        public
        view
        returns (bool _claimed)
    {
        _claimed = proposalsById[_proposalId].draftVoting.claimed;
    }

    function isClaimed(bytes32 _proposalId, uint256 _index)
        public
        view
        returns (bool _claimed)
    {
        _claimed = proposalsById[_proposalId].votingRounds[_index].claimed;
    }

    function readProposalCollateralStatus(bytes32 _proposalId)
        public
        view
        returns (uint256 _status)
    {
        require(senderIsAllowedToRead());
        _status = proposalsById[_proposalId].collateralStatus;
    }

    function readProposalCollateralAmount(bytes32 _proposalId)
        public
        view
        returns (uint256 _amount)
    {
        _amount = proposalsById[_proposalId].collateralAmount;
    }

    /// @notice Read the additional docs that are added after the proposal is finalized
    /// @dev Will throw if the propsal is not finalized yet
    function readProposalDocs(bytes32 _proposalId)
        public
        view
        returns (bytes32[] _moreDocs)
    {
        bytes32 _finalVersion = proposalsById[_proposalId].finalVersion;
        require(_finalVersion != EMPTY_BYTES);
        _moreDocs = proposalsById[_proposalId].proposalVersions[_finalVersion].moreDocs;
    }

    function readIfMilestoneFunded(bytes32 _proposalId, uint256 _milestoneId)
        public
        view
        returns (bool _funded)
    {
        require(senderIsAllowedToRead());
        _funded = proposalsById[_proposalId].votingRounds[_milestoneId].funded;
    }

    ////////////////////////////// WRITE FUNCTIONS //////////////////////////////

    function addProposal(
        bytes32 _doc,
        address _proposer,
        uint256[] _milestoneFundings,
        uint256 _finalReward,
        bool _isFounder
    )
        external
    {
        require(sender_is(CONTRACT_DAO));
        require(
          (proposalsById[_doc].proposalId == EMPTY_BYTES) &&
          (_doc != EMPTY_BYTES)
        );

        allProposals.append(_doc);
        proposalsByState[PROPOSAL_STATE_PREPROPOSAL].append(_doc);
        proposalsById[_doc].proposalId = _doc;
        proposalsById[_doc].proposer = _proposer;
        proposalsById[_doc].currentState = PROPOSAL_STATE_PREPROPOSAL;
        proposalsById[_doc].timeCreated = now;
        proposalsById[_doc].isDigix = _isFounder;
        proposalsById[_doc].addProposalVersion(_doc, _milestoneFundings, _finalReward);
    }

    function editProposal(
        bytes32 _proposalId,
        bytes32 _newDoc,
        uint256[] _newMilestoneFundings,
        uint256 _finalReward
    )
        external
    {
        require(sender_is(CONTRACT_DAO));

        proposalsById[_proposalId].addProposalVersion(_newDoc, _newMilestoneFundings, _finalReward);
    }

    /// @notice change fundings of a proposal
    /// @dev Will throw if the proposal is not finalized yet
    function changeFundings(bytes32 _proposalId, uint256[] _newMilestoneFundings, uint256 _finalReward)
        external
    {
        require(sender_is(CONTRACT_DAO));

        bytes32 _finalVersion = proposalsById[_proposalId].finalVersion;
        require(_finalVersion != EMPTY_BYTES);
        proposalsById[_proposalId].proposalVersions[_finalVersion].milestoneFundings = _newMilestoneFundings;
        proposalsById[_proposalId].proposalVersions[_finalVersion].finalReward = _finalReward;
    }

    /// @dev Will throw if the proposal is not finalized yet
    function addProposalDoc(bytes32 _proposalId, bytes32 _newDoc)
        public
    {
        require(sender_is(CONTRACT_DAO));

        bytes32 _finalVersion = proposalsById[_proposalId].finalVersion;
        require(_finalVersion != EMPTY_BYTES); //already checked in interactive layer, but why not
        proposalsById[_proposalId].proposalVersions[_finalVersion].moreDocs.push(_newDoc);
    }

    function finalizeProposal(bytes32 _proposalId)
        public
    {
        require(sender_is(CONTRACT_DAO));

        proposalsById[_proposalId].finalVersion = getLastProposalVersion(_proposalId);
    }

    function updateProposalEndorse(
        bytes32 _proposalId,
        address _endorser
    )
        public
    {
        require(sender_is(CONTRACT_DAO));

        DaoStructs.Proposal storage _proposal = proposalsById[_proposalId];
        _proposal.endorser = _endorser;
        _proposal.currentState = PROPOSAL_STATE_DRAFT;
        proposalsByState[PROPOSAL_STATE_PREPROPOSAL].remove_item(_proposalId);
        proposalsByState[PROPOSAL_STATE_DRAFT].append(_proposalId);
    }

    function setProposalDraftPass(bytes32 _proposalId, bool _result)
        public
    {
        require(sender_is(CONTRACT_DAO_VOTING_CLAIMS));

        proposalsById[_proposalId].draftVoting.passed = _result;
        if (_result) {
            proposalsByState[PROPOSAL_STATE_DRAFT].remove_item(_proposalId);
            proposalsByState[PROPOSAL_STATE_MODERATED].append(_proposalId);
            proposalsById[_proposalId].currentState = PROPOSAL_STATE_MODERATED;
        } else {
            closeProposalInternal(_proposalId);
        }
    }

    function setProposalPass(bytes32 _proposalId, uint256 _index, bool _result)
        public
    {
        require(sender_is(CONTRACT_DAO_VOTING_CLAIMS));

        if (!_result) {
            closeProposalInternal(_proposalId);
        } else if (_index == 0) {
            proposalsByState[PROPOSAL_STATE_MODERATED].remove_item(_proposalId);
            proposalsByState[PROPOSAL_STATE_ONGOING].append(_proposalId);
            proposalsById[_proposalId].currentState = PROPOSAL_STATE_ONGOING;
        }
        proposalsById[_proposalId].votingRounds[_index].passed = _result;
    }

    function setProposalDraftVotingTime(
        bytes32 _proposalId,
        uint256 _time
    )
        public
    {
        require(sender_is(CONTRACT_DAO));

        proposalsById[_proposalId].draftVoting.startTime = _time;
    }

    function setProposalVotingTime(
        bytes32 _proposalId,
        uint256 _index,
        uint256 _time
    )
        public
    {
        require(sender_is_from([CONTRACT_DAO, CONTRACT_DAO_VOTING_CLAIMS, EMPTY_BYTES]));

        proposalsById[_proposalId].votingRounds[_index].startTime = _time;
    }

    function setDraftVotingClaim(bytes32 _proposalId, bool _claimed)
        public
    {
        require(sender_is(CONTRACT_DAO_VOTING_CLAIMS));
        proposalsById[_proposalId].draftVoting.claimed = _claimed;
    }

    function setVotingClaim(bytes32 _proposalId, uint256 _index, bool _claimed)
        public
    {
        require(sender_is(CONTRACT_DAO_VOTING_CLAIMS));
        proposalsById[_proposalId].votingRounds[_index].claimed = _claimed;
    }

    function setProposalCollateralStatus(bytes32 _proposalId, uint256 _status)
        public
    {
        require(sender_is_from([CONTRACT_DAO_VOTING_CLAIMS, CONTRACT_DAO_FUNDING_MANAGER, CONTRACT_DAO]));
        proposalsById[_proposalId].collateralStatus = _status;
    }

    function setProposalCollateralAmount(bytes32 _proposalId, uint256 _amount)
        public
    {
        require(sender_is(CONTRACT_DAO));
        proposalsById[_proposalId].collateralAmount = _amount;
    }

    function updateProposalPRL(
        bytes32 _proposalId,
        uint256 _action,
        bytes32 _doc,
        uint256 _time
    )
        public
    {
        require(sender_is(CONTRACT_DAO));
        require(proposalsById[_proposalId].currentState != PROPOSAL_STATE_CLOSED);

        DaoStructs.PrlAction memory prlAction;
        prlAction.at = _time;
        prlAction.doc = _doc;
        prlAction.actionId = _action;
        proposalsById[_proposalId].prlActions.push(prlAction);

        if (_action == PRL_ACTION_PAUSE) {
          proposalsById[_proposalId].isPausedOrStopped = true;
        } else if (_action == PRL_ACTION_UNPAUSE) {
          proposalsById[_proposalId].isPausedOrStopped = false;
        } else { // STOP
          proposalsById[_proposalId].isPausedOrStopped = true;
          closeProposalInternal(_proposalId);
        }
    }

    function closeProposalInternal(bytes32 _proposalId)
        internal
    {
        bytes32 _currentState = proposalsById[_proposalId].currentState;
        proposalsByState[_currentState].remove_item(_proposalId);
        proposalsByState[PROPOSAL_STATE_CLOSED].append(_proposalId);
        proposalsById[_proposalId].currentState = PROPOSAL_STATE_CLOSED;
    }

    function addDraftVote(
        bytes32 _proposalId,
        address _voter,
        bool _vote,
        uint256 _weight
    )
        public
    {
        require(sender_is(CONTRACT_DAO_VOTING));

        DaoStructs.Proposal storage _proposal = proposalsById[_proposalId];
        if (_vote) {
            _proposal.draftVoting.yesVotes[_voter] = _weight;
            if (_proposal.draftVoting.noVotes[_voter] > 0) { // minimize number of writes to storage, since EIP-1087 is not implemented yet
                _proposal.draftVoting.noVotes[_voter] = 0;
            }
        } else {
            _proposal.draftVoting.noVotes[_voter] = _weight;
            if (_proposal.draftVoting.yesVotes[_voter] > 0) {
                _proposal.draftVoting.yesVotes[_voter] = 0;
            }
        }
    }

    function commitVote(
        bytes32 _proposalId,
        bytes32 _hash,
        address _voter,
        uint256 _index
    )
        public
    {
        require(sender_is(CONTRACT_DAO_VOTING));

        proposalsById[_proposalId].votingRounds[_index].commits[_voter] = _hash;
    }

    function revealVote(
        bytes32 _proposalId,
        address _voter,
        bool _vote,
        uint256 _weight,
        uint256 _index
    )
        public
    {
        require(sender_is(CONTRACT_DAO_VOTING));

        proposalsById[_proposalId].votingRounds[_index].revealVote(_voter, _vote, _weight);
    }

    function closeProposal(bytes32 _proposalId)
        public
    {
        require(sender_is(CONTRACT_DAO));
        closeProposalInternal(_proposalId);
    }

    function archiveProposal(bytes32 _proposalId)
        public
    {
        require(sender_is(CONTRACT_DAO_VOTING_CLAIMS));
        bytes32 _currentState = proposalsById[_proposalId].currentState;
        proposalsByState[_currentState].remove_item(_proposalId);
        proposalsByState[PROPOSAL_STATE_ARCHIVED].append(_proposalId);
        proposalsById[_proposalId].currentState = PROPOSAL_STATE_ARCHIVED;
    }

    function setMilestoneFunded(bytes32 _proposalId, uint256 _milestoneId)
        public
    {
        require(sender_is(CONTRACT_DAO_FUNDING_MANAGER));
        proposalsById[_proposalId].votingRounds[_milestoneId].funded = true;
    }
}

/**
  @title Address Iterator Storage
  @author DigixGlobal Pte Ltd
  @notice See: [Doubly Linked List](/DoublyLinkedList)
*/
contract AddressIteratorStorage {

  // Initialize Doubly Linked List of Address
  using DoublyLinkedList for DoublyLinkedList.Address;

  /**
    @notice Reads the first item from the list of Address
    @param _list The source list
    @return {"_item" : "The first item from the list"}
  */
  function read_first_from_addresses(DoublyLinkedList.Address storage _list)
           internal
           constant
           returns (address _item)
  {
    _item = _list.start_item();
  }


  /**
    @notice Reads the last item from the list of Address
    @param _list The source list
    @return {"_item" : "The last item from the list"}
  */
  function read_last_from_addresses(DoublyLinkedList.Address storage _list)
           internal
           constant
           returns (address _item)
  {
    _item = _list.end_item();
  }

  /**
    @notice Reads the next item on the list of Address
    @param _list The source list
    @param _current_item The current item to be used as base line
    @return {"_item" : "The next item from the list based on the specieid `_current_item`"}
  */
  function read_next_from_addresses(DoublyLinkedList.Address storage _list, address _current_item)
           internal
           constant
           returns (address _item)
  {
    _item = _list.next_item(_current_item);
  }

  /**
    @notice Reads the previous item on the list of Address
    @param _list The source list
    @param _current_item The current item to be used as base line
    @return {"_item" : "The previous item from the list based on the spcified `_current_item`"}
  */
  function read_previous_from_addresses(DoublyLinkedList.Address storage _list, address _current_item)
           internal
           constant
           returns (address _item)
  {
    _item = _list.previous_item(_current_item);
  }

  /**
    @notice Reads the list of Address and returns the length of the list
    @param _list The source list
    @return {"_count": "The lenght of the list"}
  */
  function read_total_addresses(DoublyLinkedList.Address storage _list)
           internal
           constant
           returns (uint256 _count)
  {
    _count = _list.total();
  }
}

contract DaoStakeStorage is ResolverClient, DaoConstants, AddressIteratorStorage {
    using DoublyLinkedList for DoublyLinkedList.Address;

    // This is the DGD stake of a user (one that is considered in the DAO)
    mapping (address => uint256) public lockedDGDStake;

    // This is the actual number of DGDs locked by user
    // may be more than the lockedDGDStake
    // in case they locked during the main phase
    mapping (address => uint256) public actualLockedDGD;

    // The total locked DGDs in the DAO (summation of lockedDGDStake)
    uint256 public totalLockedDGDStake;

    // The total locked DGDs by moderators
    uint256 public totalModeratorLockedDGDStake;

    // The list of participants in DAO
    // actual participants will be subset of this list
    DoublyLinkedList.Address allParticipants;

    // The list of moderators in DAO
    // actual moderators will be subset of this list
    DoublyLinkedList.Address allModerators;

    // Boolean to mark if an address has redeemed
    // reputation points for their DGD Badge
    mapping (address => bool) public redeemedBadge;

    // mapping to note whether an address has claimed their
    // reputation bonus for carbon vote participation
    mapping (address => bool) public carbonVoteBonusClaimed;

    constructor(address _resolver) public {
        require(init(CONTRACT_STORAGE_DAO_STAKE, _resolver));
    }

    function redeemBadge(address _user)
        public
    {
        require(sender_is(CONTRACT_DAO_STAKE_LOCKING));
        redeemedBadge[_user] = true;
    }

    function setCarbonVoteBonusClaimed(address _user)
        public
    {
        require(sender_is(CONTRACT_DAO_STAKE_LOCKING));
        carbonVoteBonusClaimed[_user] = true;
    }

    function updateTotalLockedDGDStake(uint256 _totalLockedDGDStake)
        public
    {
        require(sender_is_from([CONTRACT_DAO_STAKE_LOCKING, CONTRACT_DAO_REWARDS_MANAGER, EMPTY_BYTES]));
        totalLockedDGDStake = _totalLockedDGDStake;
    }

    function updateTotalModeratorLockedDGDs(uint256 _totalLockedDGDStake)
        public
    {
        require(sender_is_from([CONTRACT_DAO_STAKE_LOCKING, CONTRACT_DAO_REWARDS_MANAGER, EMPTY_BYTES]));
        totalModeratorLockedDGDStake = _totalLockedDGDStake;
    }

    function updateUserDGDStake(address _user, uint256 _actualLockedDGD, uint256 _lockedDGDStake)
        public
    {
        require(sender_is(CONTRACT_DAO_STAKE_LOCKING));
        actualLockedDGD[_user] = _actualLockedDGD;
        lockedDGDStake[_user] = _lockedDGDStake;
    }

    function readUserDGDStake(address _user)
        public
        view
        returns (
            uint256 _actualLockedDGD,
            uint256 _lockedDGDStake
        )
    {
        _actualLockedDGD = actualLockedDGD[_user];
        _lockedDGDStake = lockedDGDStake[_user];
    }

    function addToParticipantList(address _user)
        public
        returns (bool _success)
    {
        require(sender_is(CONTRACT_DAO_STAKE_LOCKING));
        _success = allParticipants.append(_user);
    }

    function removeFromParticipantList(address _user)
        public
        returns (bool _success)
    {
        require(sender_is(CONTRACT_DAO_STAKE_LOCKING));
        _success = allParticipants.remove_item(_user);
    }

    function addToModeratorList(address _user)
        public
        returns (bool _success)
    {
        require(sender_is(CONTRACT_DAO_STAKE_LOCKING));
        _success = allModerators.append(_user);
    }

    function removeFromModeratorList(address _user)
        public
        returns (bool _success)
    {
        require(sender_is(CONTRACT_DAO_STAKE_LOCKING));
        _success = allModerators.remove_item(_user);
    }

    function isInParticipantList(address _user)
        public
        view
        returns (bool _is)
    {
        _is = allParticipants.find(_user) != 0;
    }

    function isInModeratorsList(address _user)
        public
        view
        returns (bool _is)
    {
        _is = allModerators.find(_user) != 0;
    }

    function readFirstModerator()
        public
        view
        returns (address _item)
    {
        _item = read_first_from_addresses(allModerators);
    }

    function readLastModerator()
        public
        view
        returns (address _item)
    {
        _item = read_last_from_addresses(allModerators);
    }

    function readNextModerator(address _current_item)
        public
        view
        returns (address _item)
    {
        _item = read_next_from_addresses(allModerators, _current_item);
    }

    function readPreviousModerator(address _current_item)
        public
        view
        returns (address _item)
    {
        _item = read_previous_from_addresses(allModerators, _current_item);
    }

    function readTotalModerators()
        public
        view
        returns (uint256 _total_count)
    {
        _total_count = read_total_addresses(allModerators);
    }

    function readFirstParticipant()
        public
        view
        returns (address _item)
    {
        _item = read_first_from_addresses(allParticipants);
    }

    function readLastParticipant()
        public
        view
        returns (address _item)
    {
        _item = read_last_from_addresses(allParticipants);
    }

    function readNextParticipant(address _current_item)
        public
        view
        returns (address _item)
    {
        _item = read_next_from_addresses(allParticipants, _current_item);
    }

    function readPreviousParticipant(address _current_item)
        public
        view
        returns (address _item)
    {
        _item = read_previous_from_addresses(allParticipants, _current_item);
    }

    function readTotalParticipant()
        public
        view
        returns (uint256 _total_count)
    {
        _total_count = read_total_addresses(allParticipants);
    }
}

/**
@title Contract to list various storage states from DigixDAO
@author Digix Holdings
*/
contract DaoListingService is
    AddressIteratorInteractive,
    BytesIteratorInteractive,
    IndexedBytesIteratorInteractive,
    DaoWhitelistingCommon
{

    /**
    @notice Constructor
    @param _resolver address of contract resolver
    */
    constructor(address _resolver) public {
        require(init(CONTRACT_SERVICE_DAO_LISTING, _resolver));
    }

    function daoStakeStorage()
        internal
        view
        returns (DaoStakeStorage _contract)
    {
        _contract = DaoStakeStorage(get_contract(CONTRACT_STORAGE_DAO_STAKE));
    }

    function daoStorage()
        internal
        view
        returns (DaoStorage _contract)
    {
        _contract = DaoStorage(get_contract(CONTRACT_STORAGE_DAO));
    }

    /**
    @notice function to list moderators
    @dev note that this list may include some additional entries that are
         not moderators in the current quarter. This may happen if they
         were moderators in the previous quarter, but have not confirmed
         their participation in the current quarter. For a single address,
         a better way to know if moderator or not is:
         Dao.isModerator(_user)
    @param _count number of addresses to list
    @param _from_start boolean, whether to list from start or end
    @return {
      "_moderators": "list of moderator addresses"
    }
    */
    function listModerators(uint256 _count, bool _from_start)
        public
        view
        returns (address[] _moderators)
    {
        _moderators = list_addresses(
            _count,
            daoStakeStorage().readFirstModerator,
            daoStakeStorage().readLastModerator,
            daoStakeStorage().readNextModerator,
            daoStakeStorage().readPreviousModerator,
            _from_start
        );
    }

    /**
    @notice function to list moderators from a particular moderator
    @dev note that this list may include some additional entries that are
         not moderators in the current quarter. This may happen if they
         were moderators in the previous quarter, but have not confirmed
         their participation in the current quarter. For a single address,
         a better way to know if moderator or not is:
         Dao.isModerator(_user)

         Another note: this function will start listing AFTER the _currentModerator
         For example: we have [address1, address2, address3, address4]. listModeratorsFrom(address1, 2, true) = [address2, address3]
    @param _currentModerator start the list after this moderator address
    @param _count number of addresses to list
    @param _from_start boolean, whether to list from start or end
    @return {
      "_moderators": "list of moderator addresses"
    }
    */
    function listModeratorsFrom(
        address _currentModerator,
        uint256 _count,
        bool _from_start
    )
        public
        view
        returns (address[] _moderators)
    {
        _moderators = list_addresses_from(
            _currentModerator,
            _count,
            daoStakeStorage().readFirstModerator,
            daoStakeStorage().readLastModerator,
            daoStakeStorage().readNextModerator,
            daoStakeStorage().readPreviousModerator,
            _from_start
        );
    }

    /**
    @notice function to list participants
    @dev note that this list may include some additional entries that are
         not participants in the current quarter. This may happen if they
         were participants in the previous quarter, but have not confirmed
         their participation in the current quarter. For a single address,
         a better way to know if participant or not is:
         Dao.isParticipant(_user)
    @param _count number of addresses to list
    @param _from_start boolean, whether to list from start or end
    @return {
      "_participants": "list of participant addresses"
    }
    */
    function listParticipants(uint256 _count, bool _from_start)
        public
        view
        returns (address[] _participants)
    {
        _participants = list_addresses(
            _count,
            daoStakeStorage().readFirstParticipant,
            daoStakeStorage().readLastParticipant,
            daoStakeStorage().readNextParticipant,
            daoStakeStorage().readPreviousParticipant,
            _from_start
        );
    }

    /**
    @notice function to list participants from a particular participant
    @dev note that this list may include some additional entries that are
         not participants in the current quarter. This may happen if they
         were participants in the previous quarter, but have not confirmed
         their participation in the current quarter. For a single address,
         a better way to know if participant or not is:
         contracts.dao.isParticipant(_user)

         Another note: this function will start listing AFTER the _currentParticipant
         For example: we have [address1, address2, address3, address4]. listParticipantsFrom(address1, 2, true) = [address2, address3]
    @param _currentParticipant list from AFTER this participant address
    @param _count number of addresses to list
    @param _from_start boolean, whether to list from start or end
    @return {
      "_participants": "list of participant addresses"
    }
    */
    function listParticipantsFrom(
        address _currentParticipant,
        uint256 _count,
        bool _from_start
    )
        public
        view
        returns (address[] _participants)
    {
        _participants = list_addresses_from(
            _currentParticipant,
            _count,
            daoStakeStorage().readFirstParticipant,
            daoStakeStorage().readLastParticipant,
            daoStakeStorage().readNextParticipant,
            daoStakeStorage().readPreviousParticipant,
            _from_start
        );
    }

    /**
    @notice function to list _count no. of proposals
    @param _count number of proposals to list
    @param _from_start boolean value, true if count from start, false if count from end
    @return {
      "_proposals": "the list of proposal IDs"
    }
    */
    function listProposals(
        uint256 _count,
        bool _from_start
    )
        public
        view
        returns (bytes32[] _proposals)
    {
        _proposals = list_bytesarray(
            _count,
            daoStorage().getFirstProposal,
            daoStorage().getLastProposal,
            daoStorage().getNextProposal,
            daoStorage().getPreviousProposal,
            _from_start
        );
    }

    /**
    @notice function to list _count no. of proposals from AFTER _currentProposal
    @param _currentProposal ID of proposal to list proposals from
    @param _count number of proposals to list
    @param _from_start boolean value, true if count forwards, false if count backwards
    @return {
      "_proposals": "the list of proposal IDs"
    }
    */
    function listProposalsFrom(
        bytes32 _currentProposal,
        uint256 _count,
        bool _from_start
    )
        public
        view
        returns (bytes32[] _proposals)
    {
        _proposals = list_bytesarray_from(
            _currentProposal,
            _count,
            daoStorage().getFirstProposal,
            daoStorage().getLastProposal,
            daoStorage().getNextProposal,
            daoStorage().getPreviousProposal,
            _from_start
        );
    }

    /**
    @notice function to list _count no. of proposals in state _stateId
    @param _stateId state of proposal
    @param _count number of proposals to list
    @param _from_start boolean value, true if count from start, false if count from end
    @return {
      "_proposals": "the list of proposal IDs"
    }
    */
    function listProposalsInState(
        bytes32 _stateId,
        uint256 _count,
        bool _from_start
    )
        public
        view
        returns (bytes32[] _proposals)
    {
        require(senderIsAllowedToRead());
        _proposals = list_indexed_bytesarray(
            _stateId,
            _count,
            daoStorage().getFirstProposalInState,
            daoStorage().getLastProposalInState,
            daoStorage().getNextProposalInState,
            daoStorage().getPreviousProposalInState,
            _from_start
        );
    }

    /**
    @notice function to list _count no. of proposals in state _stateId from AFTER _currentProposal
    @param _stateId state of proposal
    @param _currentProposal ID of proposal to list proposals from
    @param _count number of proposals to list
    @param _from_start boolean value, true if count forwards, false if count backwards
    @return {
      "_proposals": "the list of proposal IDs"
    }
    */
    function listProposalsInStateFrom(
        bytes32 _stateId,
        bytes32 _currentProposal,
        uint256 _count,
        bool _from_start
    )
        public
        view
        returns (bytes32[] _proposals)
    {
        require(senderIsAllowedToRead());
        _proposals = list_indexed_bytesarray_from(
            _stateId,
            _currentProposal,
            _count,
            daoStorage().getFirstProposalInState,
            daoStorage().getLastProposalInState,
            daoStorage().getNextProposalInState,
            daoStorage().getPreviousProposalInState,
            _from_start
        );
    }

    /**
    @notice function to list proposal versions
    @param _proposalId ID of the proposal
    @param _count number of proposal versions to list
    @param _from_start boolean, true to list from start, false to list from end
    @return {
      "_versions": "list of proposal versions"
    }
    */
    function listProposalVersions(
        bytes32 _proposalId,
        uint256 _count,
        bool _from_start
    )
        public
        view
        returns (bytes32[] _versions)
    {
        _versions = list_indexed_bytesarray(
            _proposalId,
            _count,
            daoStorage().getFirstProposalVersion,
            daoStorage().getLastProposalVersion,
            daoStorage().getNextProposalVersion,
            daoStorage().getPreviousProposalVersion,
            _from_start
        );
    }

    /**
    @notice function to list proposal versions from AFTER a particular version
    @param _proposalId ID of the proposal
    @param _currentVersion version to list _count versions from
    @param _count number of proposal versions to list
    @param _from_start boolean, true to list from start, false to list from end
    @return {
      "_versions": "list of proposal versions"
    }
    */
    function listProposalVersionsFrom(
        bytes32 _proposalId,
        bytes32 _currentVersion,
        uint256 _count,
        bool _from_start
    )
        public
        view
        returns (bytes32[] _versions)
    {
        _versions = list_indexed_bytesarray_from(
            _proposalId,
            _currentVersion,
            _count,
            daoStorage().getFirstProposalVersion,
            daoStorage().getLastProposalVersion,
            daoStorage().getNextProposalVersion,
            daoStorage().getPreviousProposalVersion,
            _from_start
        );
    }
}

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

contract DaoConfigsStorage is ResolverClient, DaoConstants {

    // mapping of config name to config value
    // config names can be found in DaoConstants contract
    mapping (bytes32 => uint256) public uintConfigs;

    // mapping of config name to config value
    // config names can be found in DaoConstants contract
    mapping (bytes32 => address) public addressConfigs;

    // mapping of config name to config value
    // config names can be found in DaoConstants contract
    mapping (bytes32 => bytes32) public bytesConfigs;

    uint256 ONE_BILLION = 1000000000;
    uint256 ONE_MILLION = 1000000;

    constructor(address _resolver)
        public
    {
        require(init(CONTRACT_STORAGE_DAO_CONFIG, _resolver));

        uintConfigs[CONFIG_LOCKING_PHASE_DURATION] = 10 days;
        uintConfigs[CONFIG_QUARTER_DURATION] = QUARTER_DURATION;
        uintConfigs[CONFIG_VOTING_COMMIT_PHASE] = 14 days;
        uintConfigs[CONFIG_VOTING_PHASE_TOTAL] = 21 days;
        uintConfigs[CONFIG_INTERIM_COMMIT_PHASE] = 7 days;
        uintConfigs[CONFIG_INTERIM_PHASE_TOTAL] = 14 days;



        uintConfigs[CONFIG_DRAFT_QUORUM_FIXED_PORTION_NUMERATOR] = 5; // 5%
        uintConfigs[CONFIG_DRAFT_QUORUM_FIXED_PORTION_DENOMINATOR] = 100; // 5%
        uintConfigs[CONFIG_DRAFT_QUORUM_SCALING_FACTOR_NUMERATOR] = 35; // 35%
        uintConfigs[CONFIG_DRAFT_QUORUM_SCALING_FACTOR_DENOMINATOR] = 100; // 35%


        uintConfigs[CONFIG_VOTING_QUORUM_FIXED_PORTION_NUMERATOR] = 5; // 5%
        uintConfigs[CONFIG_VOTING_QUORUM_FIXED_PORTION_DENOMINATOR] = 100; // 5%
        uintConfigs[CONFIG_VOTING_QUORUM_SCALING_FACTOR_NUMERATOR] = 25; // 25%
        uintConfigs[CONFIG_VOTING_QUORUM_SCALING_FACTOR_DENOMINATOR] = 100; // 25%

        uintConfigs[CONFIG_DRAFT_QUOTA_NUMERATOR] = 1; // >50%
        uintConfigs[CONFIG_DRAFT_QUOTA_DENOMINATOR] = 2; // >50%
        uintConfigs[CONFIG_VOTING_QUOTA_NUMERATOR] = 1; // >50%
        uintConfigs[CONFIG_VOTING_QUOTA_DENOMINATOR] = 2; // >50%


        uintConfigs[CONFIG_QUARTER_POINT_DRAFT_VOTE] = ONE_BILLION;
        uintConfigs[CONFIG_QUARTER_POINT_VOTE] = ONE_BILLION;
        uintConfigs[CONFIG_QUARTER_POINT_INTERIM_VOTE] = ONE_BILLION;

        uintConfigs[CONFIG_QUARTER_POINT_MILESTONE_COMPLETION_PER_10000ETH] = 20000 * ONE_BILLION;

        uintConfigs[CONFIG_BONUS_REPUTATION_NUMERATOR] = 15; // 15% bonus for consistent votes
        uintConfigs[CONFIG_BONUS_REPUTATION_DENOMINATOR] = 100; // 15% bonus for consistent votes

        uintConfigs[CONFIG_SPECIAL_PROPOSAL_COMMIT_PHASE] = 28 days;
        uintConfigs[CONFIG_SPECIAL_PROPOSAL_PHASE_TOTAL] = 35 days;



        uintConfigs[CONFIG_SPECIAL_QUOTA_NUMERATOR] = 1; // >50%
        uintConfigs[CONFIG_SPECIAL_QUOTA_DENOMINATOR] = 2; // >50%

        uintConfigs[CONFIG_SPECIAL_PROPOSAL_QUORUM_NUMERATOR] = 40; // 40%
        uintConfigs[CONFIG_SPECIAL_PROPOSAL_QUORUM_DENOMINATOR] = 100; // 40%

        uintConfigs[CONFIG_MAXIMUM_REPUTATION_DEDUCTION] = 8334 * ONE_MILLION;

        uintConfigs[CONFIG_PUNISHMENT_FOR_NOT_LOCKING] = 1666 * ONE_MILLION;
        uintConfigs[CONFIG_REPUTATION_PER_EXTRA_QP_NUM] = 1; // 1 extra QP gains 1/1 RP
        uintConfigs[CONFIG_REPUTATION_PER_EXTRA_QP_DEN] = 1;


        uintConfigs[CONFIG_MINIMAL_QUARTER_POINT] = 2 * ONE_BILLION;
        uintConfigs[CONFIG_QUARTER_POINT_SCALING_FACTOR] = 400 * ONE_BILLION;
        uintConfigs[CONFIG_REPUTATION_POINT_SCALING_FACTOR] = 2000 * ONE_BILLION;

        uintConfigs[CONFIG_MODERATOR_MINIMAL_QUARTER_POINT] = 4 * ONE_BILLION;
        uintConfigs[CONFIG_MODERATOR_QUARTER_POINT_SCALING_FACTOR] = 400 * ONE_BILLION;
        uintConfigs[CONFIG_MODERATOR_REPUTATION_POINT_SCALING_FACTOR] = 2000 * ONE_BILLION;

        uintConfigs[CONFIG_PORTION_TO_MODERATORS_NUM] = 42; //4.2% of DGX to moderator voting activity
        uintConfigs[CONFIG_PORTION_TO_MODERATORS_DEN] = 1000;

        uintConfigs[CONFIG_DRAFT_VOTING_PHASE] = 7 days;

        uintConfigs[CONFIG_REPUTATION_POINT_BOOST_FOR_BADGE] = 412500 * ONE_MILLION;

        uintConfigs[CONFIG_FINAL_REWARD_SCALING_FACTOR_NUMERATOR] = 7; // 7%
        uintConfigs[CONFIG_FINAL_REWARD_SCALING_FACTOR_DENOMINATOR] = 100; // 7%

        uintConfigs[CONFIG_MAXIMUM_MODERATOR_REPUTATION_DEDUCTION] = 12500 * ONE_MILLION;
        uintConfigs[CONFIG_REPUTATION_PER_EXTRA_MODERATOR_QP_NUM] = 1;
        uintConfigs[CONFIG_REPUTATION_PER_EXTRA_MODERATOR_QP_DEN] = 1;

        uintConfigs[CONFIG_VOTE_CLAIMING_DEADLINE] = 10 days;

        uintConfigs[CONFIG_MINIMUM_LOCKED_DGD] = 10 * ONE_BILLION;
        uintConfigs[CONFIG_MINIMUM_DGD_FOR_MODERATOR] = 842 * ONE_BILLION;
        uintConfigs[CONFIG_MINIMUM_REPUTATION_FOR_MODERATOR] = 400 * ONE_BILLION;

        uintConfigs[CONFIG_PREPROPOSAL_COLLATERAL] = 2 ether;

        uintConfigs[CONFIG_MAX_FUNDING_FOR_NON_DIGIX] = 100 ether;
        uintConfigs[CONFIG_MAX_MILESTONES_FOR_NON_DIGIX] = 5;
        uintConfigs[CONFIG_NON_DIGIX_PROPOSAL_CAP_PER_QUARTER] = 80;

        uintConfigs[CONFIG_PROPOSAL_DEAD_DURATION] = 90 days;
        uintConfigs[CONFIG_CARBON_VOTE_REPUTATION_BONUS] = 10 * ONE_BILLION;
    }

    function updateUintConfigs(uint256[] _uintConfigs)
        external
    {
        require(sender_is(CONTRACT_DAO_SPECIAL_VOTING_CLAIMS));
        uintConfigs[CONFIG_LOCKING_PHASE_DURATION] = _uintConfigs[0];
        /*
        This used to be a config that can be changed. Now, _uintConfigs[1] is just a dummy config that doesnt do anything
        uintConfigs[CONFIG_QUARTER_DURATION] = _uintConfigs[1];
        */
        uintConfigs[CONFIG_VOTING_COMMIT_PHASE] = _uintConfigs[2];
        uintConfigs[CONFIG_VOTING_PHASE_TOTAL] = _uintConfigs[3];
        uintConfigs[CONFIG_INTERIM_COMMIT_PHASE] = _uintConfigs[4];
        uintConfigs[CONFIG_INTERIM_PHASE_TOTAL] = _uintConfigs[5];
        uintConfigs[CONFIG_DRAFT_QUORUM_FIXED_PORTION_NUMERATOR] = _uintConfigs[6];
        uintConfigs[CONFIG_DRAFT_QUORUM_FIXED_PORTION_DENOMINATOR] = _uintConfigs[7];
        uintConfigs[CONFIG_DRAFT_QUORUM_SCALING_FACTOR_NUMERATOR] = _uintConfigs[8];
        uintConfigs[CONFIG_DRAFT_QUORUM_SCALING_FACTOR_DENOMINATOR] = _uintConfigs[9];
        uintConfigs[CONFIG_VOTING_QUORUM_FIXED_PORTION_NUMERATOR] = _uintConfigs[10];
        uintConfigs[CONFIG_VOTING_QUORUM_FIXED_PORTION_DENOMINATOR] = _uintConfigs[11];
        uintConfigs[CONFIG_VOTING_QUORUM_SCALING_FACTOR_NUMERATOR] = _uintConfigs[12];
        uintConfigs[CONFIG_VOTING_QUORUM_SCALING_FACTOR_DENOMINATOR] = _uintConfigs[13];
        uintConfigs[CONFIG_DRAFT_QUOTA_NUMERATOR] = _uintConfigs[14];
        uintConfigs[CONFIG_DRAFT_QUOTA_DENOMINATOR] = _uintConfigs[15];
        uintConfigs[CONFIG_VOTING_QUOTA_NUMERATOR] = _uintConfigs[16];
        uintConfigs[CONFIG_VOTING_QUOTA_DENOMINATOR] = _uintConfigs[17];
        uintConfigs[CONFIG_QUARTER_POINT_DRAFT_VOTE] = _uintConfigs[18];
        uintConfigs[CONFIG_QUARTER_POINT_VOTE] = _uintConfigs[19];
        uintConfigs[CONFIG_QUARTER_POINT_INTERIM_VOTE] = _uintConfigs[20];
        uintConfigs[CONFIG_MINIMAL_QUARTER_POINT] = _uintConfigs[21];
        uintConfigs[CONFIG_QUARTER_POINT_MILESTONE_COMPLETION_PER_10000ETH] = _uintConfigs[22];
        uintConfigs[CONFIG_BONUS_REPUTATION_NUMERATOR] = _uintConfigs[23];
        uintConfigs[CONFIG_BONUS_REPUTATION_DENOMINATOR] = _uintConfigs[24];
        uintConfigs[CONFIG_SPECIAL_PROPOSAL_COMMIT_PHASE] = _uintConfigs[25];
        uintConfigs[CONFIG_SPECIAL_PROPOSAL_PHASE_TOTAL] = _uintConfigs[26];
        uintConfigs[CONFIG_SPECIAL_QUOTA_NUMERATOR] = _uintConfigs[27];
        uintConfigs[CONFIG_SPECIAL_QUOTA_DENOMINATOR] = _uintConfigs[28];
        uintConfigs[CONFIG_SPECIAL_PROPOSAL_QUORUM_NUMERATOR] = _uintConfigs[29];
        uintConfigs[CONFIG_SPECIAL_PROPOSAL_QUORUM_DENOMINATOR] = _uintConfigs[30];
        uintConfigs[CONFIG_MAXIMUM_REPUTATION_DEDUCTION] = _uintConfigs[31];
        uintConfigs[CONFIG_PUNISHMENT_FOR_NOT_LOCKING] = _uintConfigs[32];
        uintConfigs[CONFIG_REPUTATION_PER_EXTRA_QP_NUM] = _uintConfigs[33];
        uintConfigs[CONFIG_REPUTATION_PER_EXTRA_QP_DEN] = _uintConfigs[34];
        uintConfigs[CONFIG_QUARTER_POINT_SCALING_FACTOR] = _uintConfigs[35];
        uintConfigs[CONFIG_REPUTATION_POINT_SCALING_FACTOR] = _uintConfigs[36];
        uintConfigs[CONFIG_MODERATOR_MINIMAL_QUARTER_POINT] = _uintConfigs[37];
        uintConfigs[CONFIG_MODERATOR_QUARTER_POINT_SCALING_FACTOR] = _uintConfigs[38];
        uintConfigs[CONFIG_MODERATOR_REPUTATION_POINT_SCALING_FACTOR] = _uintConfigs[39];
        uintConfigs[CONFIG_PORTION_TO_MODERATORS_NUM] = _uintConfigs[40];
        uintConfigs[CONFIG_PORTION_TO_MODERATORS_DEN] = _uintConfigs[41];
        uintConfigs[CONFIG_DRAFT_VOTING_PHASE] = _uintConfigs[42];
        uintConfigs[CONFIG_REPUTATION_POINT_BOOST_FOR_BADGE] = _uintConfigs[43];
        uintConfigs[CONFIG_FINAL_REWARD_SCALING_FACTOR_NUMERATOR] = _uintConfigs[44];
        uintConfigs[CONFIG_FINAL_REWARD_SCALING_FACTOR_DENOMINATOR] = _uintConfigs[45];
        uintConfigs[CONFIG_MAXIMUM_MODERATOR_REPUTATION_DEDUCTION] = _uintConfigs[46];
        uintConfigs[CONFIG_REPUTATION_PER_EXTRA_MODERATOR_QP_NUM] = _uintConfigs[47];
        uintConfigs[CONFIG_REPUTATION_PER_EXTRA_MODERATOR_QP_DEN] = _uintConfigs[48];
        uintConfigs[CONFIG_VOTE_CLAIMING_DEADLINE] = _uintConfigs[49];
        uintConfigs[CONFIG_MINIMUM_LOCKED_DGD] = _uintConfigs[50];
        uintConfigs[CONFIG_MINIMUM_DGD_FOR_MODERATOR] = _uintConfigs[51];
        uintConfigs[CONFIG_MINIMUM_REPUTATION_FOR_MODERATOR] = _uintConfigs[52];
        uintConfigs[CONFIG_PREPROPOSAL_COLLATERAL] = _uintConfigs[53];
        uintConfigs[CONFIG_MAX_FUNDING_FOR_NON_DIGIX] = _uintConfigs[54];
        uintConfigs[CONFIG_MAX_MILESTONES_FOR_NON_DIGIX] = _uintConfigs[55];
        uintConfigs[CONFIG_NON_DIGIX_PROPOSAL_CAP_PER_QUARTER] = _uintConfigs[56];
        uintConfigs[CONFIG_PROPOSAL_DEAD_DURATION] = _uintConfigs[57];
        uintConfigs[CONFIG_CARBON_VOTE_REPUTATION_BONUS] = _uintConfigs[58];
    }

    function readUintConfigs()
        public
        view
        returns (uint256[])
    {
        uint256[] memory _uintConfigs = new uint256[](59);
        _uintConfigs[0] = uintConfigs[CONFIG_LOCKING_PHASE_DURATION];
        _uintConfigs[1] = uintConfigs[CONFIG_QUARTER_DURATION];
        _uintConfigs[2] = uintConfigs[CONFIG_VOTING_COMMIT_PHASE];
        _uintConfigs[3] = uintConfigs[CONFIG_VOTING_PHASE_TOTAL];
        _uintConfigs[4] = uintConfigs[CONFIG_INTERIM_COMMIT_PHASE];
        _uintConfigs[5] = uintConfigs[CONFIG_INTERIM_PHASE_TOTAL];
        _uintConfigs[6] = uintConfigs[CONFIG_DRAFT_QUORUM_FIXED_PORTION_NUMERATOR];
        _uintConfigs[7] = uintConfigs[CONFIG_DRAFT_QUORUM_FIXED_PORTION_DENOMINATOR];
        _uintConfigs[8] = uintConfigs[CONFIG_DRAFT_QUORUM_SCALING_FACTOR_NUMERATOR];
        _uintConfigs[9] = uintConfigs[CONFIG_DRAFT_QUORUM_SCALING_FACTOR_DENOMINATOR];
        _uintConfigs[10] = uintConfigs[CONFIG_VOTING_QUORUM_FIXED_PORTION_NUMERATOR];
        _uintConfigs[11] = uintConfigs[CONFIG_VOTING_QUORUM_FIXED_PORTION_DENOMINATOR];
        _uintConfigs[12] = uintConfigs[CONFIG_VOTING_QUORUM_SCALING_FACTOR_NUMERATOR];
        _uintConfigs[13] = uintConfigs[CONFIG_VOTING_QUORUM_SCALING_FACTOR_DENOMINATOR];
        _uintConfigs[14] = uintConfigs[CONFIG_DRAFT_QUOTA_NUMERATOR];
        _uintConfigs[15] = uintConfigs[CONFIG_DRAFT_QUOTA_DENOMINATOR];
        _uintConfigs[16] = uintConfigs[CONFIG_VOTING_QUOTA_NUMERATOR];
        _uintConfigs[17] = uintConfigs[CONFIG_VOTING_QUOTA_DENOMINATOR];
        _uintConfigs[18] = uintConfigs[CONFIG_QUARTER_POINT_DRAFT_VOTE];
        _uintConfigs[19] = uintConfigs[CONFIG_QUARTER_POINT_VOTE];
        _uintConfigs[20] = uintConfigs[CONFIG_QUARTER_POINT_INTERIM_VOTE];
        _uintConfigs[21] = uintConfigs[CONFIG_MINIMAL_QUARTER_POINT];
        _uintConfigs[22] = uintConfigs[CONFIG_QUARTER_POINT_MILESTONE_COMPLETION_PER_10000ETH];
        _uintConfigs[23] = uintConfigs[CONFIG_BONUS_REPUTATION_NUMERATOR];
        _uintConfigs[24] = uintConfigs[CONFIG_BONUS_REPUTATION_DENOMINATOR];
        _uintConfigs[25] = uintConfigs[CONFIG_SPECIAL_PROPOSAL_COMMIT_PHASE];
        _uintConfigs[26] = uintConfigs[CONFIG_SPECIAL_PROPOSAL_PHASE_TOTAL];
        _uintConfigs[27] = uintConfigs[CONFIG_SPECIAL_QUOTA_NUMERATOR];
        _uintConfigs[28] = uintConfigs[CONFIG_SPECIAL_QUOTA_DENOMINATOR];
        _uintConfigs[29] = uintConfigs[CONFIG_SPECIAL_PROPOSAL_QUORUM_NUMERATOR];
        _uintConfigs[30] = uintConfigs[CONFIG_SPECIAL_PROPOSAL_QUORUM_DENOMINATOR];
        _uintConfigs[31] = uintConfigs[CONFIG_MAXIMUM_REPUTATION_DEDUCTION];
        _uintConfigs[32] = uintConfigs[CONFIG_PUNISHMENT_FOR_NOT_LOCKING];
        _uintConfigs[33] = uintConfigs[CONFIG_REPUTATION_PER_EXTRA_QP_NUM];
        _uintConfigs[34] = uintConfigs[CONFIG_REPUTATION_PER_EXTRA_QP_DEN];
        _uintConfigs[35] = uintConfigs[CONFIG_QUARTER_POINT_SCALING_FACTOR];
        _uintConfigs[36] = uintConfigs[CONFIG_REPUTATION_POINT_SCALING_FACTOR];
        _uintConfigs[37] = uintConfigs[CONFIG_MODERATOR_MINIMAL_QUARTER_POINT];
        _uintConfigs[38] = uintConfigs[CONFIG_MODERATOR_QUARTER_POINT_SCALING_FACTOR];
        _uintConfigs[39] = uintConfigs[CONFIG_MODERATOR_REPUTATION_POINT_SCALING_FACTOR];
        _uintConfigs[40] = uintConfigs[CONFIG_PORTION_TO_MODERATORS_NUM];
        _uintConfigs[41] = uintConfigs[CONFIG_PORTION_TO_MODERATORS_DEN];
        _uintConfigs[42] = uintConfigs[CONFIG_DRAFT_VOTING_PHASE];
        _uintConfigs[43] = uintConfigs[CONFIG_REPUTATION_POINT_BOOST_FOR_BADGE];
        _uintConfigs[44] = uintConfigs[CONFIG_FINAL_REWARD_SCALING_FACTOR_NUMERATOR];
        _uintConfigs[45] = uintConfigs[CONFIG_FINAL_REWARD_SCALING_FACTOR_DENOMINATOR];
        _uintConfigs[46] = uintConfigs[CONFIG_MAXIMUM_MODERATOR_REPUTATION_DEDUCTION];
        _uintConfigs[47] = uintConfigs[CONFIG_REPUTATION_PER_EXTRA_MODERATOR_QP_NUM];
        _uintConfigs[48] = uintConfigs[CONFIG_REPUTATION_PER_EXTRA_MODERATOR_QP_DEN];
        _uintConfigs[49] = uintConfigs[CONFIG_VOTE_CLAIMING_DEADLINE];
        _uintConfigs[50] = uintConfigs[CONFIG_MINIMUM_LOCKED_DGD];
        _uintConfigs[51] = uintConfigs[CONFIG_MINIMUM_DGD_FOR_MODERATOR];
        _uintConfigs[52] = uintConfigs[CONFIG_MINIMUM_REPUTATION_FOR_MODERATOR];
        _uintConfigs[53] = uintConfigs[CONFIG_PREPROPOSAL_COLLATERAL];
        _uintConfigs[54] = uintConfigs[CONFIG_MAX_FUNDING_FOR_NON_DIGIX];
        _uintConfigs[55] = uintConfigs[CONFIG_MAX_MILESTONES_FOR_NON_DIGIX];
        _uintConfigs[56] = uintConfigs[CONFIG_NON_DIGIX_PROPOSAL_CAP_PER_QUARTER];
        _uintConfigs[57] = uintConfigs[CONFIG_PROPOSAL_DEAD_DURATION];
        _uintConfigs[58] = uintConfigs[CONFIG_CARBON_VOTE_REPUTATION_BONUS];
        return _uintConfigs;
    }
}

contract DaoProposalCounterStorage is ResolverClient, DaoConstants {

    constructor(address _resolver) public {
        require(init(CONTRACT_STORAGE_DAO_COUNTER, _resolver));
    }

    // This is to mark the number of proposals that have been funded in a specific quarter
    // this is to take care of the cap on the number of funded proposals in a quarter
    mapping (uint256 => uint256) public proposalCountByQuarter;

    function addNonDigixProposalCountInQuarter(uint256 _quarterNumber)
        public
    {
        require(sender_is(CONTRACT_DAO_VOTING_CLAIMS));
        proposalCountByQuarter[_quarterNumber] = proposalCountByQuarter[_quarterNumber].add(1);
    }
}

contract DaoUpgradeStorage is ResolverClient, DaoConstants {

    // this UTC timestamp marks the start of the first quarter
    // of DigixDAO. All time related calculations in DaoCommon
    // depend on this value
    uint256 public startOfFirstQuarter;

    // this boolean marks whether the DAO contracts have been replaced
    // by newer versions or not. The process of migration is done by deploying
    // a new set of contracts, transferring funds from these contracts to the new ones
    // migrating some state variables, and finally setting this boolean to true
    // All operations in these contracts that may transfer tokens, claim ether,
    // boost one's reputation, etc. SHOULD fail if this is true
    bool public isReplacedByNewDao;

    // this is the address of the new Dao contract
    address public newDaoContract;

    // this is the address of the new DaoFundingManager contract
    // ether funds will be moved from the current version's contract to this
    // new contract
    address public newDaoFundingManager;

    // this is the address of the new DaoRewardsManager contract
    // DGX funds will be moved from the current version of contract to this
    // new contract
    address public newDaoRewardsManager;

    constructor(address _resolver) public {
        require(init(CONTRACT_STORAGE_DAO_UPGRADE, _resolver));
    }

    function setStartOfFirstQuarter(uint256 _start)
        public
    {
        require(sender_is(CONTRACT_DAO));
        startOfFirstQuarter = _start;
    }


    function setNewContractAddresses(
        address _newDaoContract,
        address _newDaoFundingManager,
        address _newDaoRewardsManager
    )
        public
    {
        require(sender_is(CONTRACT_DAO));
        newDaoContract = _newDaoContract;
        newDaoFundingManager = _newDaoFundingManager;
        newDaoRewardsManager = _newDaoRewardsManager;
    }


    function updateForDaoMigration()
        public
    {
        require(sender_is(CONTRACT_DAO));
        isReplacedByNewDao = true;
    }
}

contract DaoSpecialStorage is DaoWhitelistingCommon {
    using DoublyLinkedList for DoublyLinkedList.Bytes;
    using DaoStructs for DaoStructs.SpecialProposal;
    using DaoStructs for DaoStructs.Voting;

    // List of all the special proposals ever created in DigixDAO
    DoublyLinkedList.Bytes proposals;

    // mapping of the SpecialProposal struct by its ID
    // ID is also the IPFS doc hash of the proposal
    mapping (bytes32 => DaoStructs.SpecialProposal) proposalsById;

    constructor(address _resolver) public {
        require(init(CONTRACT_STORAGE_DAO_SPECIAL, _resolver));
    }

    function addSpecialProposal(
        bytes32 _proposalId,
        address _proposer,
        uint256[] _uintConfigs,
        address[] _addressConfigs,
        bytes32[] _bytesConfigs
    )
        public
    {
        require(sender_is(CONTRACT_DAO_SPECIAL_PROPOSAL));
        require(
          (proposalsById[_proposalId].proposalId == EMPTY_BYTES) &&
          (_proposalId != EMPTY_BYTES)
        );
        proposals.append(_proposalId);
        proposalsById[_proposalId].proposalId = _proposalId;
        proposalsById[_proposalId].proposer = _proposer;
        proposalsById[_proposalId].timeCreated = now;
        proposalsById[_proposalId].uintConfigs = _uintConfigs;
        proposalsById[_proposalId].addressConfigs = _addressConfigs;
        proposalsById[_proposalId].bytesConfigs = _bytesConfigs;
    }

    function readProposal(bytes32 _proposalId)
        public
        view
        returns (
            bytes32 _id,
            address _proposer,
            uint256 _timeCreated,
            uint256 _timeVotingStarted
        )
    {
        _id = proposalsById[_proposalId].proposalId;
        _proposer = proposalsById[_proposalId].proposer;
        _timeCreated = proposalsById[_proposalId].timeCreated;
        _timeVotingStarted = proposalsById[_proposalId].voting.startTime;
    }

    function readProposalProposer(bytes32 _proposalId)
        public
        view
        returns (address _proposer)
    {
        _proposer = proposalsById[_proposalId].proposer;
    }

    function readConfigs(bytes32 _proposalId)
        public
        view
        returns (
            uint256[] memory _uintConfigs,
            address[] memory _addressConfigs,
            bytes32[] memory _bytesConfigs
        )
    {
        _uintConfigs = proposalsById[_proposalId].uintConfigs;
        _addressConfigs = proposalsById[_proposalId].addressConfigs;
        _bytesConfigs = proposalsById[_proposalId].bytesConfigs;
    }

    function readVotingCount(bytes32 _proposalId, address[] _allUsers)
        external
        view
        returns (uint256 _for, uint256 _against)
    {
        require(senderIsAllowedToRead());
        return proposalsById[_proposalId].voting.countVotes(_allUsers);
    }

    function readVotingTime(bytes32 _proposalId)
        public
        view
        returns (uint256 _start)
    {
        require(senderIsAllowedToRead());
        _start = proposalsById[_proposalId].voting.startTime;
    }

    function commitVote(
        bytes32 _proposalId,
        bytes32 _hash,
        address _voter
    )
        public
    {
        require(sender_is(CONTRACT_DAO_VOTING));
        proposalsById[_proposalId].voting.commits[_voter] = _hash;
    }

    function readComittedVote(bytes32 _proposalId, address _voter)
        public
        view
        returns (bytes32 _commitHash)
    {
        require(senderIsAllowedToRead());
        _commitHash = proposalsById[_proposalId].voting.commits[_voter];
    }

    function setVotingTime(bytes32 _proposalId, uint256 _time)
        public
    {
        require(sender_is(CONTRACT_DAO_SPECIAL_PROPOSAL));
        proposalsById[_proposalId].voting.startTime = _time;
    }

    function readVotingResult(bytes32 _proposalId)
        public
        view
        returns (bool _result)
    {
        require(senderIsAllowedToRead());
        _result = proposalsById[_proposalId].voting.passed;
    }

    function setPass(bytes32 _proposalId, bool _result)
        public
    {
        require(sender_is(CONTRACT_DAO_SPECIAL_VOTING_CLAIMS));
        proposalsById[_proposalId].voting.passed = _result;
    }

    function setVotingClaim(bytes32 _proposalId, bool _claimed)
        public
    {
        require(sender_is(CONTRACT_DAO_SPECIAL_VOTING_CLAIMS));
        DaoStructs.SpecialProposal storage _proposal = proposalsById[_proposalId];
        _proposal.voting.claimed = _claimed;
    }

    function isClaimed(bytes32 _proposalId)
        public
        view
        returns (bool _claimed)
    {
        require(senderIsAllowedToRead());
        _claimed = proposalsById[_proposalId].voting.claimed;
    }

    function readVote(bytes32 _proposalId, address _voter)
        public
        view
        returns (bool _vote, uint256 _weight)
    {
        require(senderIsAllowedToRead());
        return proposalsById[_proposalId].voting.readVote(_voter);
    }

    function revealVote(
        bytes32 _proposalId,
        address _voter,
        bool _vote,
        uint256 _weight
    )
        public
    {
        require(sender_is(CONTRACT_DAO_VOTING));
        proposalsById[_proposalId].voting.revealVote(_voter, _vote, _weight);
    }
}

contract DaoPointsStorage is ResolverClient, DaoConstants {

    // struct for a non-transferrable token
    struct Token {
        uint256 totalSupply;
        mapping (address => uint256) balance;
    }

    // the reputation point token
    // since reputation is cumulative, we only need to store one value
    Token reputationPoint;

    // since quarter points are specific to quarters, we need a mapping from
    // quarter number to the quarter point token for that quarter
    mapping (uint256 => Token) quarterPoint;

    // the same is the case with quarter moderator points
    // these are specific to quarters
    mapping (uint256 => Token) quarterModeratorPoint;

    constructor(address _resolver)
        public
    {
        require(init(CONTRACT_STORAGE_DAO_POINTS, _resolver));
    }

    /// @notice add quarter points for a _participant for a _quarterNumber
    function addQuarterPoint(address _participant, uint256 _point, uint256 _quarterNumber)
        public
        returns (uint256 _newPoint, uint256 _newTotalPoint)
    {
        require(sender_is_from([CONTRACT_DAO_VOTING, CONTRACT_DAO_VOTING_CLAIMS, EMPTY_BYTES]));
        quarterPoint[_quarterNumber].totalSupply = quarterPoint[_quarterNumber].totalSupply.add(_point);
        quarterPoint[_quarterNumber].balance[_participant] = quarterPoint[_quarterNumber].balance[_participant].add(_point);

        _newPoint = quarterPoint[_quarterNumber].balance[_participant];
        _newTotalPoint = quarterPoint[_quarterNumber].totalSupply;
    }

    function addModeratorQuarterPoint(address _participant, uint256 _point, uint256 _quarterNumber)
        public
        returns (uint256 _newPoint, uint256 _newTotalPoint)
    {
        require(sender_is_from([CONTRACT_DAO_VOTING, CONTRACT_DAO_VOTING_CLAIMS, EMPTY_BYTES]));
        quarterModeratorPoint[_quarterNumber].totalSupply = quarterModeratorPoint[_quarterNumber].totalSupply.add(_point);
        quarterModeratorPoint[_quarterNumber].balance[_participant] = quarterModeratorPoint[_quarterNumber].balance[_participant].add(_point);

        _newPoint = quarterModeratorPoint[_quarterNumber].balance[_participant];
        _newTotalPoint = quarterModeratorPoint[_quarterNumber].totalSupply;
    }

    /// @notice get quarter points for a _participant in a _quarterNumber
    function getQuarterPoint(address _participant, uint256 _quarterNumber)
        public
        view
        returns (uint256 _point)
    {
        _point = quarterPoint[_quarterNumber].balance[_participant];
    }

    function getQuarterModeratorPoint(address _participant, uint256 _quarterNumber)
        public
        view
        returns (uint256 _point)
    {
        _point = quarterModeratorPoint[_quarterNumber].balance[_participant];
    }

    /// @notice get total quarter points for a particular _quarterNumber
    function getTotalQuarterPoint(uint256 _quarterNumber)
        public
        view
        returns (uint256 _totalPoint)
    {
        _totalPoint = quarterPoint[_quarterNumber].totalSupply;
    }

    function getTotalQuarterModeratorPoint(uint256 _quarterNumber)
        public
        view
        returns (uint256 _totalPoint)
    {
        _totalPoint = quarterModeratorPoint[_quarterNumber].totalSupply;
    }

    /// @notice add reputation points for a _participant
    function increaseReputation(address _participant, uint256 _point)
        public
        returns (uint256 _newPoint, uint256 _totalPoint)
    {
        require(sender_is_from([CONTRACT_DAO_VOTING_CLAIMS, CONTRACT_DAO_REWARDS_MANAGER, CONTRACT_DAO_STAKE_LOCKING]));
        reputationPoint.totalSupply = reputationPoint.totalSupply.add(_point);
        reputationPoint.balance[_participant] = reputationPoint.balance[_participant].add(_point);

        _newPoint = reputationPoint.balance[_participant];
        _totalPoint = reputationPoint.totalSupply;
    }

    /// @notice subtract reputation points for a _participant
    function reduceReputation(address _participant, uint256 _point)
        public
        returns (uint256 _newPoint, uint256 _totalPoint)
    {
        require(sender_is_from([CONTRACT_DAO_VOTING_CLAIMS, CONTRACT_DAO_REWARDS_MANAGER, EMPTY_BYTES]));
        uint256 _toDeduct = _point;
        if (reputationPoint.balance[_participant] > _point) {
            reputationPoint.balance[_participant] = reputationPoint.balance[_participant].sub(_point);
        } else {
            _toDeduct = reputationPoint.balance[_participant];
            reputationPoint.balance[_participant] = 0;
        }

        reputationPoint.totalSupply = reputationPoint.totalSupply.sub(_toDeduct);

        _newPoint = reputationPoint.balance[_participant];
        _totalPoint = reputationPoint.totalSupply;
    }

  /// @notice get reputation points for a _participant
  function getReputation(address _participant)
      public
      view
      returns (uint256 _point)
  {
      _point = reputationPoint.balance[_participant];
  }

  /// @notice get total reputation points distributed in the dao
  function getTotalReputation()
      public
      view
      returns (uint256 _totalPoint)
  {
      _totalPoint = reputationPoint.totalSupply;
  }
}

// this contract will receive DGXs fees from the DGX fees distributors
contract DaoRewardsStorage is ResolverClient, DaoConstants {
    using DaoStructs for DaoStructs.DaoQuarterInfo;

    // DaoQuarterInfo is a struct that stores the quarter specific information
    // regarding totalEffectiveDGDs, DGX distribution day, etc. pls check
    // docs in lib/DaoStructs
    mapping(uint256 => DaoStructs.DaoQuarterInfo) public allQuartersInfo;

    // Mapping that stores the DGX that can be claimed as rewards by
    // an address (a participant of DigixDAO)
    mapping(address => uint256) public claimableDGXs;

    // This stores the total DGX value that has been claimed by participants
    // this can be done by calling the DaoRewardsManager.claimRewards method
    // Note that this value is the only outgoing DGX from DaoRewardsManager contract
    // Note that this value also takes into account the demurrage that has been paid
    // by participants for simply holding their DGXs in the DaoRewardsManager contract
    uint256 public totalDGXsClaimed;

    // The Quarter ID in which the user last participated in
    // To participate means they had locked more than CONFIG_MINIMUM_LOCKED_DGD
    // DGD tokens. In addition, they should not have withdrawn those tokens in the same
    // quarter. Basically, in the main phase of the quarter, if DaoCommon.isParticipant(_user)
    // was true, they were participants. And that quarter was their lastParticipatedQuarter
    mapping (address => uint256) public lastParticipatedQuarter;

    // This mapping is only used to update the lastParticipatedQuarter to the
    // previousLastParticipatedQuarter in case users lock and withdraw DGDs
    // within the same quarter's locking phase
    mapping (address => uint256) public previousLastParticipatedQuarter;

    // This number marks the Quarter in which the rewards were last updated for that user
    // Since the rewards calculation for a specific quarter is only done once that
    // quarter is completed, we need this value to note the last quarter when the rewards were updated
    // We then start adding the rewards for all quarters after that quarter, until the current quarter
    mapping (address => uint256) public lastQuarterThatRewardsWasUpdated;

    // Similar as the lastQuarterThatRewardsWasUpdated, but this is for reputation updates
    // Note that reputation can also be deducted for no participation (not locking DGDs)
    // This value is used to update the reputation based on all quarters from the lastQuarterThatReputationWasUpdated
    // to the current quarter
    mapping (address => uint256) public lastQuarterThatReputationWasUpdated;

    constructor(address _resolver)
           public
    {
        require(init(CONTRACT_STORAGE_DAO_REWARDS, _resolver));
    }

    function updateQuarterInfo(
        uint256 _quarterNumber,
        uint256 _minimalParticipationPoint,
        uint256 _quarterPointScalingFactor,
        uint256 _reputationPointScalingFactor,
        uint256 _totalEffectiveDGDPreviousQuarter,

        uint256 _moderatorMinimalQuarterPoint,
        uint256 _moderatorQuarterPointScalingFactor,
        uint256 _moderatorReputationPointScalingFactor,
        uint256 _totalEffectiveModeratorDGDLastQuarter,

        uint256 _dgxDistributionDay,
        uint256 _dgxRewardsPoolLastQuarter,
        uint256 _sumRewardsFromBeginning
    )
        public
    {
        require(sender_is(CONTRACT_DAO_REWARDS_MANAGER));
        allQuartersInfo[_quarterNumber].minimalParticipationPoint = _minimalParticipationPoint;
        allQuartersInfo[_quarterNumber].quarterPointScalingFactor = _quarterPointScalingFactor;
        allQuartersInfo[_quarterNumber].reputationPointScalingFactor = _reputationPointScalingFactor;
        allQuartersInfo[_quarterNumber].totalEffectiveDGDPreviousQuarter = _totalEffectiveDGDPreviousQuarter;

        allQuartersInfo[_quarterNumber].moderatorMinimalParticipationPoint = _moderatorMinimalQuarterPoint;
        allQuartersInfo[_quarterNumber].moderatorQuarterPointScalingFactor = _moderatorQuarterPointScalingFactor;
        allQuartersInfo[_quarterNumber].moderatorReputationPointScalingFactor = _moderatorReputationPointScalingFactor;
        allQuartersInfo[_quarterNumber].totalEffectiveModeratorDGDLastQuarter = _totalEffectiveModeratorDGDLastQuarter;

        allQuartersInfo[_quarterNumber].dgxDistributionDay = _dgxDistributionDay;
        allQuartersInfo[_quarterNumber].dgxRewardsPoolLastQuarter = _dgxRewardsPoolLastQuarter;
        allQuartersInfo[_quarterNumber].sumRewardsFromBeginning = _sumRewardsFromBeginning;
    }

    function updateClaimableDGX(address _user, uint256 _newClaimableDGX)
        public
    {
        require(sender_is(CONTRACT_DAO_REWARDS_MANAGER));
        claimableDGXs[_user] = _newClaimableDGX;
    }

    function updateLastParticipatedQuarter(address _user, uint256 _lastQuarter)
        public
    {
        require(sender_is(CONTRACT_DAO_STAKE_LOCKING));
        lastParticipatedQuarter[_user] = _lastQuarter;
    }

    function updatePreviousLastParticipatedQuarter(address _user, uint256 _lastQuarter)
        public
    {
        require(sender_is(CONTRACT_DAO_STAKE_LOCKING));
        previousLastParticipatedQuarter[_user] = _lastQuarter;
    }

    function updateLastQuarterThatRewardsWasUpdated(address _user, uint256 _lastQuarter)
        public
    {
        require(sender_is_from([CONTRACT_DAO_REWARDS_MANAGER, CONTRACT_DAO_STAKE_LOCKING, EMPTY_BYTES]));
        lastQuarterThatRewardsWasUpdated[_user] = _lastQuarter;
    }

    function updateLastQuarterThatReputationWasUpdated(address _user, uint256 _lastQuarter)
        public
    {
        require(sender_is_from([CONTRACT_DAO_REWARDS_MANAGER, CONTRACT_DAO_STAKE_LOCKING, EMPTY_BYTES]));
        lastQuarterThatReputationWasUpdated[_user] = _lastQuarter;
    }

    function addToTotalDgxClaimed(uint256 _dgxClaimed)
        public
    {
        require(sender_is(CONTRACT_DAO_REWARDS_MANAGER));
        totalDGXsClaimed = totalDGXsClaimed.add(_dgxClaimed);
    }

    function readQuarterInfo(uint256 _quarterNumber)
        public
        view
        returns (
            uint256 _minimalParticipationPoint,
            uint256 _quarterPointScalingFactor,
            uint256 _reputationPointScalingFactor,
            uint256 _totalEffectiveDGDPreviousQuarter,

            uint256 _moderatorMinimalQuarterPoint,
            uint256 _moderatorQuarterPointScalingFactor,
            uint256 _moderatorReputationPointScalingFactor,
            uint256 _totalEffectiveModeratorDGDLastQuarter,

            uint256 _dgxDistributionDay,
            uint256 _dgxRewardsPoolLastQuarter,
            uint256 _sumRewardsFromBeginning
        )
    {
        _minimalParticipationPoint = allQuartersInfo[_quarterNumber].minimalParticipationPoint;
        _quarterPointScalingFactor = allQuartersInfo[_quarterNumber].quarterPointScalingFactor;
        _reputationPointScalingFactor = allQuartersInfo[_quarterNumber].reputationPointScalingFactor;
        _totalEffectiveDGDPreviousQuarter = allQuartersInfo[_quarterNumber].totalEffectiveDGDPreviousQuarter;
        _moderatorMinimalQuarterPoint = allQuartersInfo[_quarterNumber].moderatorMinimalParticipationPoint;
        _moderatorQuarterPointScalingFactor = allQuartersInfo[_quarterNumber].moderatorQuarterPointScalingFactor;
        _moderatorReputationPointScalingFactor = allQuartersInfo[_quarterNumber].moderatorReputationPointScalingFactor;
        _totalEffectiveModeratorDGDLastQuarter = allQuartersInfo[_quarterNumber].totalEffectiveModeratorDGDLastQuarter;
        _dgxDistributionDay = allQuartersInfo[_quarterNumber].dgxDistributionDay;
        _dgxRewardsPoolLastQuarter = allQuartersInfo[_quarterNumber].dgxRewardsPoolLastQuarter;
        _sumRewardsFromBeginning = allQuartersInfo[_quarterNumber].sumRewardsFromBeginning;
    }

    function readQuarterGeneralInfo(uint256 _quarterNumber)
        public
        view
        returns (
            uint256 _dgxDistributionDay,
            uint256 _dgxRewardsPoolLastQuarter,
            uint256 _sumRewardsFromBeginning
        )
    {
        _dgxDistributionDay = allQuartersInfo[_quarterNumber].dgxDistributionDay;
        _dgxRewardsPoolLastQuarter = allQuartersInfo[_quarterNumber].dgxRewardsPoolLastQuarter;
        _sumRewardsFromBeginning = allQuartersInfo[_quarterNumber].sumRewardsFromBeginning;
    }

    function readQuarterModeratorInfo(uint256 _quarterNumber)
        public
        view
        returns (
            uint256 _moderatorMinimalQuarterPoint,
            uint256 _moderatorQuarterPointScalingFactor,
            uint256 _moderatorReputationPointScalingFactor,
            uint256 _totalEffectiveModeratorDGDLastQuarter
        )
    {
        _moderatorMinimalQuarterPoint = allQuartersInfo[_quarterNumber].moderatorMinimalParticipationPoint;
        _moderatorQuarterPointScalingFactor = allQuartersInfo[_quarterNumber].moderatorQuarterPointScalingFactor;
        _moderatorReputationPointScalingFactor = allQuartersInfo[_quarterNumber].moderatorReputationPointScalingFactor;
        _totalEffectiveModeratorDGDLastQuarter = allQuartersInfo[_quarterNumber].totalEffectiveModeratorDGDLastQuarter;
    }

    function readQuarterParticipantInfo(uint256 _quarterNumber)
        public
        view
        returns (
            uint256 _minimalParticipationPoint,
            uint256 _quarterPointScalingFactor,
            uint256 _reputationPointScalingFactor,
            uint256 _totalEffectiveDGDPreviousQuarter
        )
    {
        _minimalParticipationPoint = allQuartersInfo[_quarterNumber].minimalParticipationPoint;
        _quarterPointScalingFactor = allQuartersInfo[_quarterNumber].quarterPointScalingFactor;
        _reputationPointScalingFactor = allQuartersInfo[_quarterNumber].reputationPointScalingFactor;
        _totalEffectiveDGDPreviousQuarter = allQuartersInfo[_quarterNumber].totalEffectiveDGDPreviousQuarter;
    }

    function readDgxDistributionDay(uint256 _quarterNumber)
        public
        view
        returns (uint256 _distributionDay)
    {
        _distributionDay = allQuartersInfo[_quarterNumber].dgxDistributionDay;
    }

    function readTotalEffectiveDGDLastQuarter(uint256 _quarterNumber)
        public
        view
        returns (uint256 _totalEffectiveDGDPreviousQuarter)
    {
        _totalEffectiveDGDPreviousQuarter = allQuartersInfo[_quarterNumber].totalEffectiveDGDPreviousQuarter;
    }

    function readTotalEffectiveModeratorDGDLastQuarter(uint256 _quarterNumber)
        public
        view
        returns (uint256 _totalEffectiveModeratorDGDLastQuarter)
    {
        _totalEffectiveModeratorDGDLastQuarter = allQuartersInfo[_quarterNumber].totalEffectiveModeratorDGDLastQuarter;
    }

    function readRewardsPoolOfLastQuarter(uint256 _quarterNumber)
        public
        view
        returns (uint256 _rewardsPool)
    {
        _rewardsPool = allQuartersInfo[_quarterNumber].dgxRewardsPoolLastQuarter;
    }
}

contract IntermediateResultsStorage is ResolverClient, DaoConstants {
    using DaoStructs for DaoStructs.IntermediateResults;

    constructor(address _resolver) public {
        require(init(CONTRACT_STORAGE_INTERMEDIATE_RESULTS, _resolver));
    }

    // There are scenarios in which we must loop across all participants/moderators
    // in a function call. For a big number of operations, the function call may be short of gas
    // To tackle this, we use an IntermediateResults struct to store the intermediate results
    // The same function is then called multiple times until all operations are completed
    // If the operations cannot be done in that iteration, the intermediate results are stored
    // else, the final outcome is returned
    // Please check the lib/DaoStructs for docs on this struct
    mapping (bytes32 => DaoStructs.IntermediateResults) allIntermediateResults;

    function getIntermediateResults(bytes32 _key)
        public
        view
        returns (
            address _countedUntil,
            uint256 _currentForCount,
            uint256 _currentAgainstCount,
            uint256 _currentSumOfEffectiveBalance
        )
    {
        _countedUntil = allIntermediateResults[_key].countedUntil;
        _currentForCount = allIntermediateResults[_key].currentForCount;
        _currentAgainstCount = allIntermediateResults[_key].currentAgainstCount;
        _currentSumOfEffectiveBalance = allIntermediateResults[_key].currentSumOfEffectiveBalance;
    }

    function resetIntermediateResults(bytes32 _key)
        public
    {
        require(sender_is_from([CONTRACT_DAO_REWARDS_MANAGER, CONTRACT_DAO_VOTING_CLAIMS, CONTRACT_DAO_SPECIAL_VOTING_CLAIMS]));
        allIntermediateResults[_key].countedUntil = address(0x0);
    }

    function setIntermediateResults(
        bytes32 _key,
        address _countedUntil,
        uint256 _currentForCount,
        uint256 _currentAgainstCount,
        uint256 _currentSumOfEffectiveBalance
    )
        public
    {
        require(sender_is_from([CONTRACT_DAO_REWARDS_MANAGER, CONTRACT_DAO_VOTING_CLAIMS, CONTRACT_DAO_SPECIAL_VOTING_CLAIMS]));
        allIntermediateResults[_key].countedUntil = _countedUntil;
        allIntermediateResults[_key].currentForCount = _currentForCount;
        allIntermediateResults[_key].currentAgainstCount = _currentAgainstCount;
        allIntermediateResults[_key].currentSumOfEffectiveBalance = _currentSumOfEffectiveBalance;
    }
}

library MathHelper {

  using SafeMath for uint256;

  function max(uint256 a, uint256 b) internal pure returns (uint256 _max){
      _max = b;
      if (a > b) {
          _max = a;
      }
  }

  function min(uint256 a, uint256 b) internal pure returns (uint256 _min){
      _min = b;
      if (a < b) {
          _min = a;
      }
  }

  function sumNumbers(uint256[] _numbers) internal pure returns (uint256 _sum) {
      for (uint256 i=0;i<_numbers.length;i++) {
          _sum = _sum.add(_numbers[i]);
      }
  }
}

contract DaoCommonMini is IdentityCommon {

    using MathHelper for MathHelper;

    /**
    @notice Check if the DAO contracts have been replaced by a new set of contracts
    @return _isNotReplaced true if it is not replaced, false if it has already been replaced
    */
    function isDaoNotReplaced()
        public
        view
        returns (bool _isNotReplaced)
    {
        _isNotReplaced = !daoUpgradeStorage().isReplacedByNewDao();
    }

    /**
    @notice Check if it is currently in the locking phase
    @dev No governance activities can happen in the locking phase. The locking phase is from t=0 to t=CONFIG_LOCKING_PHASE_DURATION-1
    @return _isLockingPhase true if it is in the locking phase
    */
    function isLockingPhase()
        public
        view
        returns (bool _isLockingPhase)
    {
        _isLockingPhase = currentTimeInQuarter() < getUintConfig(CONFIG_LOCKING_PHASE_DURATION);
    }

    /**
    @notice Check if it is currently in a main phase.
    @dev The main phase is where all the governance activities could take plase. If the DAO is replaced, there can never be any more main phase.
    @return _isMainPhase true if it is in a main phase
    */
    function isMainPhase()
        public
        view
        returns (bool _isMainPhase)
    {
        _isMainPhase =
            isDaoNotReplaced() &&
            currentTimeInQuarter() >= getUintConfig(CONFIG_LOCKING_PHASE_DURATION);
    }

    /**
    @notice Check if the calculateGlobalRewardsBeforeNewQuarter function has been done for a certain quarter
    @dev However, there is no need to run calculateGlobalRewardsBeforeNewQuarter for the first quarter
    */
    modifier ifGlobalRewardsSet(uint256 _quarterNumber) {
        if (_quarterNumber > 1) {
            require(daoRewardsStorage().readDgxDistributionDay(_quarterNumber) > 0);
        }
        _;
    }

    /**
    @notice require that it is currently during a phase, which is within _relativePhaseStart and _relativePhaseEnd seconds, after the _startingPoint
    */
    function requireInPhase(uint256 _startingPoint, uint256 _relativePhaseStart, uint256 _relativePhaseEnd)
        internal
        view
    {
        require(_startingPoint > 0);
        require(now < _startingPoint.add(_relativePhaseEnd));
        require(now >= _startingPoint.add(_relativePhaseStart));
    }

    /**
    @notice Get the current quarter index
    @dev Quarter indexes starts from 1
    @return _quarterNumber the current quarter index
    */
    function currentQuarterNumber()
        public
        view
        returns(uint256 _quarterNumber)
    {
        _quarterNumber = getQuarterNumber(now);
    }

    /**
    @notice Get the quarter index of a timestamp
    @dev Quarter indexes starts from 1
    @return _index the quarter index
    */
    function getQuarterNumber(uint256 _time)
        internal
        view
        returns (uint256 _index)
    {
        require(startOfFirstQuarterIsSet());
        _index =
            _time.sub(daoUpgradeStorage().startOfFirstQuarter())
            .div(getUintConfig(CONFIG_QUARTER_DURATION))
            .add(1);
    }

    /**
    @notice Get the relative time in quarter of a timestamp
    @dev For example, the timeInQuarter of the first second of any quarter n-th is always 1
    */
    function timeInQuarter(uint256 _time)
        internal
        view
        returns (uint256 _timeInQuarter)
    {
        require(startOfFirstQuarterIsSet()); // must be already set
        _timeInQuarter =
            _time.sub(daoUpgradeStorage().startOfFirstQuarter())
            % getUintConfig(CONFIG_QUARTER_DURATION);
    }

    /**
    @notice Check if the start of first quarter is already set
    @return _isSet true if start of first quarter is already set
    */
    function startOfFirstQuarterIsSet()
        internal
        view
        returns (bool _isSet)
    {
        _isSet = daoUpgradeStorage().startOfFirstQuarter() != 0;
    }

    /**
    @notice Get the current relative time in the quarter
    @dev For example: the currentTimeInQuarter of the first second of any quarter is 1
    @return _currentT the current relative time in the quarter
    */
    function currentTimeInQuarter()
        public
        view
        returns (uint256 _currentT)
    {
        _currentT = timeInQuarter(now);
    }

    /**
    @notice Get the time remaining in the quarter
    */
    function getTimeLeftInQuarter(uint256 _time)
        internal
        view
        returns (uint256 _timeLeftInQuarter)
    {
        _timeLeftInQuarter = getUintConfig(CONFIG_QUARTER_DURATION).sub(timeInQuarter(_time));
    }

    function daoListingService()
        internal
        view
        returns (DaoListingService _contract)
    {
        _contract = DaoListingService(get_contract(CONTRACT_SERVICE_DAO_LISTING));
    }

    function daoConfigsStorage()
        internal
        view
        returns (DaoConfigsStorage _contract)
    {
        _contract = DaoConfigsStorage(get_contract(CONTRACT_STORAGE_DAO_CONFIG));
    }

    function daoStakeStorage()
        internal
        view
        returns (DaoStakeStorage _contract)
    {
        _contract = DaoStakeStorage(get_contract(CONTRACT_STORAGE_DAO_STAKE));
    }

    function daoStorage()
        internal
        view
        returns (DaoStorage _contract)
    {
        _contract = DaoStorage(get_contract(CONTRACT_STORAGE_DAO));
    }

    function daoProposalCounterStorage()
        internal
        view
        returns (DaoProposalCounterStorage _contract)
    {
        _contract = DaoProposalCounterStorage(get_contract(CONTRACT_STORAGE_DAO_COUNTER));
    }

    function daoUpgradeStorage()
        internal
        view
        returns (DaoUpgradeStorage _contract)
    {
        _contract = DaoUpgradeStorage(get_contract(CONTRACT_STORAGE_DAO_UPGRADE));
    }

    function daoSpecialStorage()
        internal
        view
        returns (DaoSpecialStorage _contract)
    {
        _contract = DaoSpecialStorage(get_contract(CONTRACT_STORAGE_DAO_SPECIAL));
    }

    function daoPointsStorage()
        internal
        view
        returns (DaoPointsStorage _contract)
    {
        _contract = DaoPointsStorage(get_contract(CONTRACT_STORAGE_DAO_POINTS));
    }

    function daoRewardsStorage()
        internal
        view
        returns (DaoRewardsStorage _contract)
    {
        _contract = DaoRewardsStorage(get_contract(CONTRACT_STORAGE_DAO_REWARDS));
    }

    function intermediateResultsStorage()
        internal
        view
        returns (IntermediateResultsStorage _contract)
    {
        _contract = IntermediateResultsStorage(get_contract(CONTRACT_STORAGE_INTERMEDIATE_RESULTS));
    }

    function getUintConfig(bytes32 _configKey)
        public
        view
        returns (uint256 _configValue)
    {
        _configValue = daoConfigsStorage().uintConfigs(_configKey);
    }
}

contract DaoCommon is DaoCommonMini {

    using MathHelper for MathHelper;

    /**
    @notice Check if the transaction is called by the proposer of a proposal
    @return _isFromProposer true if the caller is the proposer
    */
    function isFromProposer(bytes32 _proposalId)
        internal
        view
        returns (bool _isFromProposer)
    {
        _isFromProposer = msg.sender == daoStorage().readProposalProposer(_proposalId);
    }

    /**
    @notice Check if the proposal can still be "editted", or in other words, added more versions
    @dev Once the proposal is finalized, it can no longer be editted. The proposer will still be able to add docs and change fundings though.
    @return _isEditable true if the proposal is editable
    */
    function isEditable(bytes32 _proposalId)
        internal
        view
        returns (bool _isEditable)
    {
        bytes32 _finalVersion;
        (,,,,,,,_finalVersion,,) = daoStorage().readProposal(_proposalId);
        _isEditable = _finalVersion == EMPTY_BYTES;
    }

    /**
    @notice returns the balance of DaoFundingManager, which is the wei in DigixDAO
    */
    function weiInDao()
        internal
        view
        returns (uint256 _wei)
    {
        _wei = get_contract(CONTRACT_DAO_FUNDING_MANAGER).balance;
    }

    /**
    @notice Check if it is after the draft voting phase of the proposal
    */
    modifier ifAfterDraftVotingPhase(bytes32 _proposalId) {
        uint256 _start = daoStorage().readProposalDraftVotingTime(_proposalId);
        require(_start > 0); // Draft voting must have started. In other words, proposer must have finalized the proposal
        require(now >= _start.add(getUintConfig(CONFIG_DRAFT_VOTING_PHASE)));
        _;
    }

    modifier ifCommitPhase(bytes32 _proposalId, uint8 _index) {
        requireInPhase(
            daoStorage().readProposalVotingTime(_proposalId, _index),
            0,
            getUintConfig(_index == 0 ? CONFIG_VOTING_COMMIT_PHASE : CONFIG_INTERIM_COMMIT_PHASE)
        );
        _;
    }

    modifier ifRevealPhase(bytes32 _proposalId, uint256 _index) {
      requireInPhase(
          daoStorage().readProposalVotingTime(_proposalId, _index),
          getUintConfig(_index == 0 ? CONFIG_VOTING_COMMIT_PHASE : CONFIG_INTERIM_COMMIT_PHASE),
          getUintConfig(_index == 0 ? CONFIG_VOTING_PHASE_TOTAL : CONFIG_INTERIM_PHASE_TOTAL)
      );
      _;
    }

    modifier ifAfterProposalRevealPhase(bytes32 _proposalId, uint256 _index) {
      uint256 _start = daoStorage().readProposalVotingTime(_proposalId, _index);
      require(_start > 0);
      require(now >= _start.add(getUintConfig(_index == 0 ? CONFIG_VOTING_PHASE_TOTAL : CONFIG_INTERIM_PHASE_TOTAL)));
      _;
    }

    modifier ifDraftVotingPhase(bytes32 _proposalId) {
        requireInPhase(
            daoStorage().readProposalDraftVotingTime(_proposalId),
            0,
            getUintConfig(CONFIG_DRAFT_VOTING_PHASE)
        );
        _;
    }

    modifier isProposalState(bytes32 _proposalId, bytes32 _STATE) {
        bytes32 _currentState;
        (,,,_currentState,,,,,,) = daoStorage().readProposal(_proposalId);
        require(_currentState == _STATE);
        _;
    }

    /**
    @notice Check if the DAO has enough ETHs for a particular funding request
    */
    modifier ifFundingPossible(uint256[] _fundings, uint256 _finalReward) {
        require(MathHelper.sumNumbers(_fundings).add(_finalReward) <= weiInDao());
        _;
    }

    modifier ifDraftNotClaimed(bytes32 _proposalId) {
        require(daoStorage().isDraftClaimed(_proposalId) == false);
        _;
    }

    modifier ifNotClaimed(bytes32 _proposalId, uint256 _index) {
        require(daoStorage().isClaimed(_proposalId, _index) == false);
        _;
    }

    modifier ifNotClaimedSpecial(bytes32 _proposalId) {
        require(daoSpecialStorage().isClaimed(_proposalId) == false);
        _;
    }

    modifier hasNotRevealed(bytes32 _proposalId, uint256 _index) {
        uint256 _voteWeight;
        (, _voteWeight) = daoStorage().readVote(_proposalId, _index, msg.sender);
        require(_voteWeight == uint(0));
        _;
    }

    modifier hasNotRevealedSpecial(bytes32 _proposalId) {
        uint256 _weight;
        (,_weight) = daoSpecialStorage().readVote(_proposalId, msg.sender);
        require(_weight == uint256(0));
        _;
    }

    modifier ifAfterRevealPhaseSpecial(bytes32 _proposalId) {
      uint256 _start = daoSpecialStorage().readVotingTime(_proposalId);
      require(_start > 0);
      require(now.sub(_start) >= getUintConfig(CONFIG_SPECIAL_PROPOSAL_PHASE_TOTAL));
      _;
    }

    modifier ifCommitPhaseSpecial(bytes32 _proposalId) {
        requireInPhase(
            daoSpecialStorage().readVotingTime(_proposalId),
            0,
            getUintConfig(CONFIG_SPECIAL_PROPOSAL_COMMIT_PHASE)
        );
        _;
    }

    modifier ifRevealPhaseSpecial(bytes32 _proposalId) {
        requireInPhase(
            daoSpecialStorage().readVotingTime(_proposalId),
            getUintConfig(CONFIG_SPECIAL_PROPOSAL_COMMIT_PHASE),
            getUintConfig(CONFIG_SPECIAL_PROPOSAL_PHASE_TOTAL)
        );
        _;
    }

    function daoWhitelistingStorage()
        internal
        view
        returns (DaoWhitelistingStorage _contract)
    {
        _contract = DaoWhitelistingStorage(get_contract(CONTRACT_STORAGE_DAO_WHITELISTING));
    }

    function getAddressConfig(bytes32 _configKey)
        public
        view
        returns (address _configValue)
    {
        _configValue = daoConfigsStorage().addressConfigs(_configKey);
    }

    function getBytesConfig(bytes32 _configKey)
        public
        view
        returns (bytes32 _configValue)
    {
        _configValue = daoConfigsStorage().bytesConfigs(_configKey);
    }

    /**
    @notice Check if a user is a participant in the current quarter
    */
    function isParticipant(address _user)
        public
        view
        returns (bool _is)
    {
        _is =
            (daoRewardsStorage().lastParticipatedQuarter(_user) == currentQuarterNumber())
            && (daoStakeStorage().lockedDGDStake(_user) >= getUintConfig(CONFIG_MINIMUM_LOCKED_DGD));
    }

    /**
    @notice Check if a user is a moderator in the current quarter
    */
    function isModerator(address _user)
        public
        view
        returns (bool _is)
    {
        _is =
            (daoRewardsStorage().lastParticipatedQuarter(_user) == currentQuarterNumber())
            && (daoStakeStorage().lockedDGDStake(_user) >= getUintConfig(CONFIG_MINIMUM_DGD_FOR_MODERATOR))
            && (daoPointsStorage().getReputation(_user) >= getUintConfig(CONFIG_MINIMUM_REPUTATION_FOR_MODERATOR));
    }

    /**
    @notice Calculate the start of a specific milestone of a specific proposal.
    @dev This is calculated from the voting start of the voting round preceding the milestone
         This would throw if the voting start is 0 (the voting round has not started yet)
         Note that if the milestoneIndex is exactly the same as the number of milestones,
         This will just return the end of the last voting round.
    */
    function startOfMilestone(bytes32 _proposalId, uint256 _milestoneIndex)
        internal
        view
        returns (uint256 _milestoneStart)
    {
        uint256 _startOfPrecedingVotingRound = daoStorage().readProposalVotingTime(_proposalId, _milestoneIndex);
        require(_startOfPrecedingVotingRound > 0);
        // the preceding voting round must have started

        if (_milestoneIndex == 0) { // This is the 1st milestone, which starts after voting round 0
            _milestoneStart =
                _startOfPrecedingVotingRound
                .add(getUintConfig(CONFIG_VOTING_PHASE_TOTAL));
        } else { // if its the n-th milestone, it starts after voting round n-th
            _milestoneStart =
                _startOfPrecedingVotingRound
                .add(getUintConfig(CONFIG_INTERIM_PHASE_TOTAL));
        }
    }

    /**
    @notice Calculate the actual voting start for a voting round, given the tentative start
    @dev The tentative start is the ideal start. For example, when a proposer finish a milestone, it should be now
         However, sometimes the tentative start is too close to the end of the quarter, hence, the actual voting start should be pushed to the next quarter
    */
    function getTimelineForNextVote(
        uint256 _index,
        uint256 _tentativeVotingStart
    )
        internal
        view
        returns (uint256 _actualVotingStart)
    {
        uint256 _timeLeftInQuarter = getTimeLeftInQuarter(_tentativeVotingStart);
        uint256 _votingDuration = getUintConfig(_index == 0 ? CONFIG_VOTING_PHASE_TOTAL : CONFIG_INTERIM_PHASE_TOTAL);
        _actualVotingStart = _tentativeVotingStart;
        if (timeInQuarter(_tentativeVotingStart) < getUintConfig(CONFIG_LOCKING_PHASE_DURATION)) { // if the tentative start is during a locking phase
            _actualVotingStart = _tentativeVotingStart.add(
                getUintConfig(CONFIG_LOCKING_PHASE_DURATION).sub(timeInQuarter(_tentativeVotingStart))
            );
        } else if (_timeLeftInQuarter < _votingDuration.add(getUintConfig(CONFIG_VOTE_CLAIMING_DEADLINE))) { // if the time left in quarter is not enough to vote and claim voting
            _actualVotingStart = _tentativeVotingStart.add(
                _timeLeftInQuarter.add(getUintConfig(CONFIG_LOCKING_PHASE_DURATION)).add(1)
            );
        }
    }

    /**
    @notice Check if we can add another non-Digix proposal in this quarter
    @dev There is a max cap to the number of non-Digix proposals CONFIG_NON_DIGIX_PROPOSAL_CAP_PER_QUARTER
    */
    function checkNonDigixProposalLimit(bytes32 _proposalId)
        internal
        view
    {
        require(isNonDigixProposalsWithinLimit(_proposalId));
    }

    function isNonDigixProposalsWithinLimit(bytes32 _proposalId)
        internal
        view
        returns (bool _withinLimit)
    {
        bool _isDigixProposal;
        (,,,,,,,,,_isDigixProposal) = daoStorage().readProposal(_proposalId);
        _withinLimit = true;
        if (!_isDigixProposal) {
            _withinLimit = daoProposalCounterStorage().proposalCountByQuarter(currentQuarterNumber()) < getUintConfig(CONFIG_NON_DIGIX_PROPOSAL_CAP_PER_QUARTER);
        }
    }

    /**
    @notice If its a non-Digix proposal, check if the fundings are within limit
    @dev There is a max cap to the fundings and number of milestones for non-Digix proposals
    */
    function checkNonDigixFundings(uint256[] _milestonesFundings, uint256 _finalReward)
        internal
        view
    {
        if (!is_founder()) {
            require(_milestonesFundings.length <= getUintConfig(CONFIG_MAX_MILESTONES_FOR_NON_DIGIX));
            require(MathHelper.sumNumbers(_milestonesFundings).add(_finalReward) <= getUintConfig(CONFIG_MAX_FUNDING_FOR_NON_DIGIX));
        }
    }

    /**
    @notice Check if msg.sender can do operations as a proposer
    @dev Note that this function does not check if he is the proposer of the proposal
    */
    function senderCanDoProposerOperations()
        internal
        view
    {
        require(isMainPhase());
        require(isParticipant(msg.sender));
        require(identity_storage().is_kyc_approved(msg.sender));
    }
}

/// @title Digix Gold Token Demurrage Calculator
/// @author Digix Holdings Pte Ltd
/// @notice This contract is meant to be used by exchanges/other parties who want to calculate the DGX demurrage fees, provided an initial balance and the days elapsed
contract DgxDemurrageCalculator {
    function calculateDemurrage(uint256 _initial_balance, uint256 _days_elapsed)
        public
        view
        returns (uint256 _demurrage_fees, bool _no_demurrage_fees);
}

contract DaoCalculatorService is DaoCommon {

    address public dgxDemurrageCalculatorAddress;

    using MathHelper for MathHelper;

    constructor(address _resolver, address _dgxDemurrageCalculatorAddress)
        public
    {
        require(init(CONTRACT_SERVICE_DAO_CALCULATOR, _resolver));
        dgxDemurrageCalculatorAddress = _dgxDemurrageCalculatorAddress;
    }


    /**
    @notice Calculate the additional lockedDGDStake, given the DGDs that the user has just locked in
    @dev The earlier the locking happens, the more lockedDGDStake the user will get
         The formula is: additionalLockedDGDStake = (90 - t)/80 * additionalDGD if t is more than 10. If t<=10, additionalLockedDGDStake = additionalDGD
    */
    function calculateAdditionalLockedDGDStake(uint256 _additionalDgd)
        public
        view
        returns (uint256 _additionalLockedDGDStake)
    {
        _additionalLockedDGDStake =
            _additionalDgd.mul(
                getUintConfig(CONFIG_QUARTER_DURATION)
                .sub(
                    MathHelper.max(
                        currentTimeInQuarter(),
                        getUintConfig(CONFIG_LOCKING_PHASE_DURATION)
                    )
                )
            )
            .div(
                getUintConfig(CONFIG_QUARTER_DURATION)
                .sub(getUintConfig(CONFIG_LOCKING_PHASE_DURATION))
            );
    }


    // Quorum is in terms of lockedDGDStake
    function minimumDraftQuorum(bytes32 _proposalId)
        public
        view
        returns (uint256 _minQuorum)
    {
        uint256[] memory _fundings;

        (_fundings,) = daoStorage().readProposalFunding(_proposalId);
        _minQuorum = calculateMinQuorum(
            daoStakeStorage().totalModeratorLockedDGDStake(),
            getUintConfig(CONFIG_DRAFT_QUORUM_FIXED_PORTION_NUMERATOR),
            getUintConfig(CONFIG_DRAFT_QUORUM_FIXED_PORTION_DENOMINATOR),
            getUintConfig(CONFIG_DRAFT_QUORUM_SCALING_FACTOR_NUMERATOR),
            getUintConfig(CONFIG_DRAFT_QUORUM_SCALING_FACTOR_DENOMINATOR),
            _fundings[0]
        );
    }


    function draftQuotaPass(uint256 _for, uint256 _against)
        public
        view
        returns (bool _passed)
    {
        _passed = _for.mul(getUintConfig(CONFIG_DRAFT_QUOTA_DENOMINATOR))
                > getUintConfig(CONFIG_DRAFT_QUOTA_NUMERATOR).mul(_for.add(_against));
    }


    // Quorum is in terms of lockedDGDStake
    function minimumVotingQuorum(bytes32 _proposalId, uint256 _milestone_id)
        public
        view
        returns (uint256 _minQuorum)
    {
        require(senderIsAllowedToRead());
        uint256[] memory _weiAskedPerMilestone;
        uint256 _finalReward;
        (_weiAskedPerMilestone,_finalReward) = daoStorage().readProposalFunding(_proposalId);
        require(_milestone_id <= _weiAskedPerMilestone.length);
        if (_milestone_id == _weiAskedPerMilestone.length) {
            // calculate quorum for the final voting round
            _minQuorum = calculateMinQuorum(
                daoStakeStorage().totalLockedDGDStake(),
                getUintConfig(CONFIG_VOTING_QUORUM_FIXED_PORTION_NUMERATOR),
                getUintConfig(CONFIG_VOTING_QUORUM_FIXED_PORTION_DENOMINATOR),
                getUintConfig(CONFIG_FINAL_REWARD_SCALING_FACTOR_NUMERATOR),
                getUintConfig(CONFIG_FINAL_REWARD_SCALING_FACTOR_DENOMINATOR),
                _finalReward
            );
        } else {
            // calculate quorum for a voting round
            _minQuorum = calculateMinQuorum(
                daoStakeStorage().totalLockedDGDStake(),
                getUintConfig(CONFIG_VOTING_QUORUM_FIXED_PORTION_NUMERATOR),
                getUintConfig(CONFIG_VOTING_QUORUM_FIXED_PORTION_DENOMINATOR),
                getUintConfig(CONFIG_VOTING_QUORUM_SCALING_FACTOR_NUMERATOR),
                getUintConfig(CONFIG_VOTING_QUORUM_SCALING_FACTOR_DENOMINATOR),
                _weiAskedPerMilestone[_milestone_id]
            );
        }
    }


    // Quorum is in terms of lockedDGDStake
    function minimumVotingQuorumForSpecial()
        public
        view
        returns (uint256 _minQuorum)
    {
      _minQuorum = getUintConfig(CONFIG_SPECIAL_PROPOSAL_QUORUM_NUMERATOR).mul(
                       daoStakeStorage().totalLockedDGDStake()
                   ).div(
                       getUintConfig(CONFIG_SPECIAL_PROPOSAL_QUORUM_DENOMINATOR)
                   );
    }


    function votingQuotaPass(uint256 _for, uint256 _against)
        public
        view
        returns (bool _passed)
    {
        _passed = _for.mul(getUintConfig(CONFIG_VOTING_QUOTA_DENOMINATOR))
                > getUintConfig(CONFIG_VOTING_QUOTA_NUMERATOR).mul(_for.add(_against));
    }


    function votingQuotaForSpecialPass(uint256 _for, uint256 _against)
        public
        view
        returns (bool _passed)
    {
        _passed =_for.mul(getUintConfig(CONFIG_SPECIAL_QUOTA_DENOMINATOR))
                > getUintConfig(CONFIG_SPECIAL_QUOTA_NUMERATOR).mul(_for.add(_against));
    }


    function calculateMinQuorum(
        uint256 _totalStake,
        uint256 _fixedQuorumPortionNumerator,
        uint256 _fixedQuorumPortionDenominator,
        uint256 _scalingFactorNumerator,
        uint256 _scalingFactorDenominator,
        uint256 _weiAsked
    )
        internal
        view
        returns (uint256 _minimumQuorum)
    {
        uint256 _weiInDao = weiInDao();
        // add the fixed portion of the quorum
        _minimumQuorum = (_totalStake.mul(_fixedQuorumPortionNumerator)).div(_fixedQuorumPortionDenominator);

        // add the dynamic portion of the quorum
        _minimumQuorum = _minimumQuorum.add(_totalStake.mul(_weiAsked.mul(_scalingFactorNumerator)).div(_weiInDao.mul(_scalingFactorDenominator)));
    }


    function calculateUserEffectiveBalance(
        uint256 _minimalParticipationPoint,
        uint256 _quarterPointScalingFactor,
        uint256 _reputationPointScalingFactor,
        uint256 _quarterPoint,
        uint256 _reputationPoint,
        uint256 _lockedDGDStake
    )
        public
        pure
        returns (uint256 _effectiveDGDBalance)
    {
        uint256 _baseDGDBalance = MathHelper.min(_quarterPoint, _minimalParticipationPoint).mul(_lockedDGDStake).div(_minimalParticipationPoint);
        _effectiveDGDBalance =
            _baseDGDBalance
            .mul(_quarterPointScalingFactor.add(_quarterPoint).sub(_minimalParticipationPoint))
            .mul(_reputationPointScalingFactor.add(_reputationPoint))
            .div(_quarterPointScalingFactor.mul(_reputationPointScalingFactor));
    }


    function calculateDemurrage(uint256 _balance, uint256 _daysElapsed)
        public
        view
        returns (uint256 _demurrageFees)
    {
        (_demurrageFees,) = DgxDemurrageCalculator(dgxDemurrageCalculatorAddress).calculateDemurrage(_balance, _daysElapsed);
    }
}

/**
 * @title ERC20Basic
 * @dev Simpler version of ERC20 interface
 * See https://github.com/ethereum/EIPs/issues/179
 */
contract ERC20Basic {
  function totalSupply() public view returns (uint256);
  function balanceOf(address _who) public view returns (uint256);
  function transfer(address _to, uint256 _value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}

/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20 is ERC20Basic {
  function allowance(address _owner, address _spender)
    public view returns (uint256);

  function transferFrom(address _from, address _to, uint256 _value)
    public returns (bool);

  function approve(address _spender, uint256 _value) public returns (bool);
  event Approval(
    address indexed owner,
    address indexed spender,
    uint256 value
  );
}

library DaoIntermediateStructs {

    // Struct used in large functions to cut down on variables
    // store the summation of weights "FOR" proposal
    // store the summation of weights "AGAINST" proposal
    struct VotingCount {
        // weight of votes "FOR" the voting round
        uint256 forCount;
        // weight of votes "AGAINST" the voting round
        uint256 againstCount;
    }

    // Struct used in large functions to cut down on variables
    struct Users {
        // Length of the above list
        uint256 usersLength;
        // List of addresses, participants of DigixDAO
        address[] users;
    }
}

contract DaoRewardsManagerCommon is DaoCommonMini {

    using DaoStructs for DaoStructs.DaoQuarterInfo;

    // this is a struct that store information relevant for calculating the user rewards
    // for the last participating quarter
    struct UserRewards {
        uint256 lastParticipatedQuarter;
        uint256 lastQuarterThatRewardsWasUpdated;
        uint256 effectiveDGDBalance;
        uint256 effectiveModeratorDGDBalance;
        DaoStructs.DaoQuarterInfo qInfo;
    }

    // struct to store variables needed in the execution of calculateGlobalRewardsBeforeNewQuarter
    struct QuarterRewardsInfo {
        uint256 previousQuarter;
        uint256 totalEffectiveDGDPreviousQuarter;
        uint256 totalEffectiveModeratorDGDLastQuarter;
        uint256 dgxRewardsPoolLastQuarter;
        uint256 userCount;
        uint256 i;
        DaoStructs.DaoQuarterInfo qInfo;
        address currentUser;
        address[] users;
        bool doneCalculatingEffectiveBalance;
        bool doneCalculatingModeratorEffectiveBalance;
    }

    // get the struct for the relevant information for calculating a user's DGX rewards for the last participated quarter
    function getUserRewardsStruct(address _user)
        internal
        view
        returns (UserRewards memory _data)
    {
        _data.lastParticipatedQuarter = daoRewardsStorage().lastParticipatedQuarter(_user);
        _data.lastQuarterThatRewardsWasUpdated = daoRewardsStorage().lastQuarterThatRewardsWasUpdated(_user);
        _data.qInfo = readQuarterInfo(_data.lastParticipatedQuarter);
    }

    // read the DaoQuarterInfo struct of a certain quarter
    function readQuarterInfo(uint256 _quarterNumber)
        internal
        view
        returns (DaoStructs.DaoQuarterInfo _qInfo)
    {
        (
            _qInfo.minimalParticipationPoint,
            _qInfo.quarterPointScalingFactor,
            _qInfo.reputationPointScalingFactor,
            _qInfo.totalEffectiveDGDPreviousQuarter
        ) = daoRewardsStorage().readQuarterParticipantInfo(_quarterNumber);
        (
            _qInfo.moderatorMinimalParticipationPoint,
            _qInfo.moderatorQuarterPointScalingFactor,
            _qInfo.moderatorReputationPointScalingFactor,
            _qInfo.totalEffectiveModeratorDGDLastQuarter
        ) = daoRewardsStorage().readQuarterModeratorInfo(_quarterNumber);
        (
            _qInfo.dgxDistributionDay,
            _qInfo.dgxRewardsPoolLastQuarter,
            _qInfo.sumRewardsFromBeginning
        ) = daoRewardsStorage().readQuarterGeneralInfo(_quarterNumber);
    }
}

contract DaoRewardsManagerExtras is DaoRewardsManagerCommon {

    constructor(address _resolver) public {
        require(init(CONTRACT_DAO_REWARDS_MANAGER_EXTRAS, _resolver));
    }

    function daoCalculatorService()
        internal
        view
        returns (DaoCalculatorService _contract)
    {
        _contract = DaoCalculatorService(get_contract(CONTRACT_SERVICE_DAO_CALCULATOR));
    }

    // done
    // calculate dgx rewards; This is basically the DGXs that user has earned from participating in lastParticipatedQuarter, and can be withdrawn on the dgxDistributionDay of the (lastParticipatedQuarter + 1)
    // when user actually withdraw some time after that, he will be deducted demurrage.
    function calculateUserRewardsForLastParticipatingQuarter(address _user)
        public
        view
        returns (uint256 _dgxRewardsAsParticipant, uint256 _dgxRewardsAsModerator)
    {
        UserRewards memory data = getUserRewardsStruct(_user);

        data.effectiveDGDBalance = daoCalculatorService().calculateUserEffectiveBalance(
            data.qInfo.minimalParticipationPoint,
            data.qInfo.quarterPointScalingFactor,
            data.qInfo.reputationPointScalingFactor,
            daoPointsStorage().getQuarterPoint(_user, data.lastParticipatedQuarter),

            // RP has been updated at the beginning of the lastParticipatedQuarter in
            // a call to updateRewardsAndReputationBeforeNewQuarter(); It should not have changed since then
            daoPointsStorage().getReputation(_user),

            // lockedDGDStake should have stayed the same throughout since the lastParticipatedQuarter
            // if this participant has done anything (lock/unlock/continue) to change the lockedDGDStake,
            // updateUserRewardsForLastParticipatingQuarter, and hence this function, would have been called first before the lockedDGDStake is changed
            daoStakeStorage().lockedDGDStake(_user)
        );

        data.effectiveModeratorDGDBalance = daoCalculatorService().calculateUserEffectiveBalance(
            data.qInfo.moderatorMinimalParticipationPoint,
            data.qInfo.moderatorQuarterPointScalingFactor,
            data.qInfo.moderatorReputationPointScalingFactor,
            daoPointsStorage().getQuarterModeratorPoint(_user, data.lastParticipatedQuarter),

            // RP has been updated at the beginning of the lastParticipatedQuarter in
            // a call to updateRewardsAndReputationBeforeNewQuarter();
            daoPointsStorage().getReputation(_user),

            // lockedDGDStake should have stayed the same throughout since the lastParticipatedQuarter
            // if this participant has done anything (lock/unlock/continue) to change the lockedDGDStake,
            // updateUserRewardsForLastParticipatingQuarter would have been called first before the lockedDGDStake is changed
            daoStakeStorage().lockedDGDStake(_user)
        );

        // will not need to calculate if the totalEffectiveDGDLastQuarter is 0 (no one participated)
        if (daoRewardsStorage().readTotalEffectiveDGDLastQuarter(data.lastParticipatedQuarter.add(1)) > 0) {
            _dgxRewardsAsParticipant =
                data.effectiveDGDBalance
                .mul(daoRewardsStorage().readRewardsPoolOfLastQuarter(
                    data.lastParticipatedQuarter.add(1)
                ))
                .mul(
                    getUintConfig(CONFIG_PORTION_TO_MODERATORS_DEN)
                    .sub(getUintConfig(CONFIG_PORTION_TO_MODERATORS_NUM))
                )
                .div(daoRewardsStorage().readTotalEffectiveDGDLastQuarter(
                    data.lastParticipatedQuarter.add(1)
                ))
                .div(getUintConfig(CONFIG_PORTION_TO_MODERATORS_DEN));
        }

        // will not need to calculate if the totalEffectiveModeratorDGDLastQuarter is 0 (no one participated)
        if (daoRewardsStorage().readTotalEffectiveModeratorDGDLastQuarter(data.lastParticipatedQuarter.add(1)) > 0) {
            _dgxRewardsAsModerator =
                data.effectiveModeratorDGDBalance
                .mul(daoRewardsStorage().readRewardsPoolOfLastQuarter(
                    data.lastParticipatedQuarter.add(1)
                ))
                .mul(
                     getUintConfig(CONFIG_PORTION_TO_MODERATORS_NUM)
                )
                .div(daoRewardsStorage().readTotalEffectiveModeratorDGDLastQuarter(
                    data.lastParticipatedQuarter.add(1)
                ))
                .div(getUintConfig(CONFIG_PORTION_TO_MODERATORS_DEN));
        }
    }
}

/**
@title Contract to manage DGX rewards
@author Digix Holdings
*/
contract DaoRewardsManager is DaoRewardsManagerCommon {
    using MathHelper for MathHelper;
    using DaoStructs for DaoStructs.DaoQuarterInfo;
    using DaoStructs for DaoStructs.IntermediateResults;

    // is emitted when calculateGlobalRewardsBeforeNewQuarter has been done in the beginning of the quarter
    // after which, all the other DAO activities could happen
    event StartNewQuarter(uint256 indexed _quarterNumber);

    address public ADDRESS_DGX_TOKEN;

    function daoCalculatorService()
        internal
        view
        returns (DaoCalculatorService _contract)
    {
        _contract = DaoCalculatorService(get_contract(CONTRACT_SERVICE_DAO_CALCULATOR));
    }

    function daoRewardsManagerExtras()
        internal
        view
        returns (DaoRewardsManagerExtras _contract)
    {
        _contract = DaoRewardsManagerExtras(get_contract(CONTRACT_DAO_REWARDS_MANAGER_EXTRAS));
    }

    /**
    @notice Constructor (set the DaoQuarterInfo struct for the first quarter)
    @param _resolver Address of the Contract Resolver contract
    @param _dgxAddress Address of the Digix Gold Token contract
    */
    constructor(address _resolver, address _dgxAddress)
        public
    {
        require(init(CONTRACT_DAO_REWARDS_MANAGER, _resolver));
        ADDRESS_DGX_TOKEN = _dgxAddress;

        // set the DaoQuarterInfo for the first quarter
        daoRewardsStorage().updateQuarterInfo(
            1,
            getUintConfig(CONFIG_MINIMAL_QUARTER_POINT),
            getUintConfig(CONFIG_QUARTER_POINT_SCALING_FACTOR),
            getUintConfig(CONFIG_REPUTATION_POINT_SCALING_FACTOR),
            0, // totalEffectiveDGDPreviousQuarter, Not Applicable, this value should not be used ever
            getUintConfig(CONFIG_MODERATOR_MINIMAL_QUARTER_POINT),
            getUintConfig(CONFIG_MODERATOR_QUARTER_POINT_SCALING_FACTOR),
            getUintConfig(CONFIG_MODERATOR_REPUTATION_POINT_SCALING_FACTOR),
            0, // _totalEffectiveModeratorDGDLastQuarter , Not applicable, this value should not be used ever

            // _dgxDistributionDay, Not applicable, there shouldnt be any DGX rewards in the DAO now. The actual DGX fees that have been collected
            // before the deployment of DigixDAO contracts would be counted as part of the DGX fees incurred in the first quarter
            // this value should not be used ever
            now,

            0, // _dgxRewardsPoolLastQuarter, not applicable, this value should not be used ever
            0 // sumRewardsFromBeginning, which is 0
        );
    }


    /**
    @notice Function to transfer the claimableDGXs to the new DaoRewardsManager
    @dev This is done during the migrateToNewDao procedure
    @param _newDaoRewardsManager Address of the new daoRewardsManager contract
    */
    function moveDGXsToNewDao(address _newDaoRewardsManager)
        public
    {
        require(sender_is(CONTRACT_DAO));
        uint256 _dgxBalance = ERC20(ADDRESS_DGX_TOKEN).balanceOf(address(this));
        ERC20(ADDRESS_DGX_TOKEN).transfer(_newDaoRewardsManager, _dgxBalance);
    }


    /**
    @notice Function for users to claim the claimable DGX rewards
    @dev Will revert if _claimableDGX < MINIMUM_TRANSFER_AMOUNT of DGX.
         Can only be called after calculateGlobalRewardsBeforeNewQuarter() has been called in the current quarter
         This cannot be called once the current version of Dao contracts have been migrated to newer version
    */
    function claimRewards()
        public
        ifGlobalRewardsSet(currentQuarterNumber())
    {
        require(isDaoNotReplaced());

        address _user = msg.sender;
        uint256 _claimableDGX;

        // update rewards for the quarter that he last participated in
        (, _claimableDGX) = updateUserRewardsForLastParticipatingQuarter(_user);

        // withdraw from his claimableDGXs
        // This has to take into account demurrage
        // Basically, the value of claimableDGXs in the contract is for the dgxDistributionDay of (lastParticipatedQuarter + 1)
        // if now is after that, we need to deduct demurrage
        uint256 _days_elapsed = now
            .sub(
                daoRewardsStorage().readDgxDistributionDay(
                    daoRewardsStorage().lastQuarterThatRewardsWasUpdated(_user).add(1) // lastQuarterThatRewardsWasUpdated should be the same as lastParticipatedQuarter now
                )
            )
            .div(1 days);

         // similar logic as in the similar step in updateUserRewardsForLastParticipatingQuarter.
         // it is as if the user has withdrawn all _claimableDGX, and the demurrage is paid back into the DAO immediately
        daoRewardsStorage().addToTotalDgxClaimed(_claimableDGX);

        _claimableDGX = _claimableDGX.sub(
            daoCalculatorService().calculateDemurrage(
                _claimableDGX,
                _days_elapsed
            ));

        daoRewardsStorage().updateClaimableDGX(_user, 0);
        ERC20(ADDRESS_DGX_TOKEN).transfer(_user, _claimableDGX);
        // the _demurrageFees is implicitly "transfered" back into the DAO, and would be counted in the dgxRewardsPool of this quarter (in other words, dgxRewardsPoolLastQuarter of next quarter)
    }


    /**
    @notice Function to update DGX rewards of user. This is only called during locking/withdrawing DGDs, or continuing participation for new quarter
    @param _user Address of the DAO participant
    */
    function updateRewardsAndReputationBeforeNewQuarter(address _user)
        public
    {
        require(sender_is(CONTRACT_DAO_STAKE_LOCKING));

        updateUserRewardsForLastParticipatingQuarter(_user);
        updateUserReputationUntilPreviousQuarter(_user);
    }


    // This function would ALWAYS make sure that the user's Reputation Point is updated for ALL activities that has happened
    // BEFORE this current quarter. These activities include:
    //  - Reputation bonus/penalty due to participation in all of the previous quarters
    //  - Reputation penalty for not participating for a few quarters, up until and including the previous quarter
    //  - Badges redemption and carbon vote reputation redemption (that happens in the first time locking)
    // As such, after this function is called on quarter N, the updated reputation point of the user would tentatively be used to calculate the rewards for quarter N
    // Its tentative because the user can also redeem a badge during the period of quarter N to add to his reputation point.
    function updateUserReputationUntilPreviousQuarter (address _user)
        private
    {
        uint256 _lastParticipatedQuarter = daoRewardsStorage().lastParticipatedQuarter(_user);
        uint256 _lastQuarterThatReputationWasUpdated = daoRewardsStorage().lastQuarterThatReputationWasUpdated(_user);
        uint256 _reputationDeduction;

        // If the reputation was already updated until the previous quarter
        // nothing needs to be done
        if (
            _lastQuarterThatReputationWasUpdated.add(1) >= currentQuarterNumber()
        ) {
            return;
        }

        // first, we calculate and update the reputation change due to the user's governance activities in lastParticipatedQuarter, if it is not already updated.
        // reputation is not updated for lastParticipatedQuarter yet is equivalent to _lastQuarterThatReputationWasUpdated == _lastParticipatedQuarter - 1
        if (
            (_lastQuarterThatReputationWasUpdated.add(1) == _lastParticipatedQuarter)
        ) {
            updateRPfromQP(
                _user,
                daoPointsStorage().getQuarterPoint(_user, _lastParticipatedQuarter),
                getUintConfig(CONFIG_MINIMAL_QUARTER_POINT),
                getUintConfig(CONFIG_MAXIMUM_REPUTATION_DEDUCTION),
                getUintConfig(CONFIG_REPUTATION_PER_EXTRA_QP_NUM),
                getUintConfig(CONFIG_REPUTATION_PER_EXTRA_QP_DEN)
            );

            // this user is not a Moderator for current quarter
            // coz this step is done before updating the refreshModerator.
            // But may have been a Moderator before, and if was moderator in their
            // lastParticipatedQuarter, we will find them in the DoublyLinkedList.
            if (daoStakeStorage().isInModeratorsList(_user)) {
                updateRPfromQP(
                    _user,
                    daoPointsStorage().getQuarterModeratorPoint(_user, _lastParticipatedQuarter),
                    getUintConfig(CONFIG_MODERATOR_MINIMAL_QUARTER_POINT),
                    getUintConfig(CONFIG_MAXIMUM_MODERATOR_REPUTATION_DEDUCTION),
                    getUintConfig(CONFIG_REPUTATION_PER_EXTRA_MODERATOR_QP_NUM),
                    getUintConfig(CONFIG_REPUTATION_PER_EXTRA_MODERATOR_QP_DEN)
                );
            }
            _lastQuarterThatReputationWasUpdated = _lastParticipatedQuarter;
        }

        // at this point, the _lastQuarterThatReputationWasUpdated MUST be at least the _lastParticipatedQuarter already
        // Hence, any quarters between the _lastQuarterThatReputationWasUpdated and now must be a non-participating quarter,
        // and this participant should be penalized for those.

        // If this is their first ever participation, It is fine as well, as the reputation would be still be 0 after this step.
        // note that the carbon vote's reputation bonus will be added after this, so its fine

        _reputationDeduction =
            (currentQuarterNumber().sub(1).sub(_lastQuarterThatReputationWasUpdated))
            .mul(
                getUintConfig(CONFIG_MAXIMUM_REPUTATION_DEDUCTION)
                .add(getUintConfig(CONFIG_PUNISHMENT_FOR_NOT_LOCKING))
            );

        if (_reputationDeduction > 0) daoPointsStorage().reduceReputation(_user, _reputationDeduction);
        daoRewardsStorage().updateLastQuarterThatReputationWasUpdated(_user, currentQuarterNumber().sub(1));
    }


    // update ReputationPoint of a participant based on QuarterPoint/ModeratorQuarterPoint in a quarter
    function updateRPfromQP (
        address _user,
        uint256 _userQP,
        uint256 _minimalQP,
        uint256 _maxRPDeduction,
        uint256 _rpPerExtraQP_num,
        uint256 _rpPerExtraQP_den
    ) internal {
        uint256 _reputationDeduction;
        uint256 _reputationAddition;
        if (_userQP < _minimalQP) {
            _reputationDeduction =
                _minimalQP.sub(_userQP)
                .mul(_maxRPDeduction)
                .div(_minimalQP);

            daoPointsStorage().reduceReputation(_user, _reputationDeduction);
        } else {
            _reputationAddition =
                _userQP.sub(_minimalQP)
                .mul(_rpPerExtraQP_num)
                .div(_rpPerExtraQP_den);

            daoPointsStorage().increaseReputation(_user, _reputationAddition);
        }
    }

    // if the DGX rewards has not been calculated for the user's lastParticipatedQuarter, calculate and update it
    function updateUserRewardsForLastParticipatingQuarter(address _user)
        internal
        returns (bool _valid, uint256 _userClaimableDgx)
    {
        UserRewards memory data = getUserRewardsStruct(_user);
        _userClaimableDgx = daoRewardsStorage().claimableDGXs(_user);

        // There is nothing to do if:
        //   - The participant is already participating this quarter and hence this function has been called in this quarter
        //   - We have updated the rewards to the lastParticipatedQuarter
        // In ANY other cases: it means that the lastParticipatedQuarter is NOT this quarter, and its greater than lastQuarterThatRewardsWasUpdated, hence
        // This also means that this participant has ALREADY PARTICIPATED at least once IN THE PAST, and we have not calculated for this quarter
        // Thus, we need to calculate the Rewards for the lastParticipatedQuarter
        if (
            (currentQuarterNumber() == data.lastParticipatedQuarter) ||
            (data.lastParticipatedQuarter <= data.lastQuarterThatRewardsWasUpdated)
        ) {
            return (false, _userClaimableDgx);
        }

        // now we will calculate the user rewards based on info of the data.lastParticipatedQuarter

        // first we "deduct the demurrage" for the existing claimable DGXs for time period from
        // dgxDistributionDay of (lastQuarterThatRewardsWasUpdated + 1) to dgxDistributionDay of (lastParticipatedQuarter + 1)
        // (note that, when people participate in quarter n, the DGX rewards for quarter n is only released at the dgxDistributionDay of (n+1)th quarter)
        uint256 _days_elapsed = daoRewardsStorage().readDgxDistributionDay(data.lastParticipatedQuarter.add(1))
            .sub(daoRewardsStorage().readDgxDistributionDay(data.lastQuarterThatRewardsWasUpdated.add(1)))
            .div(1 days);
        uint256 _demurrageFees = daoCalculatorService().calculateDemurrage(
            _userClaimableDgx,
            _days_elapsed
        );
        _userClaimableDgx = _userClaimableDgx.sub(_demurrageFees);
        // this demurrage fees will not be accurate to the hours, but we will leave it as this.

        // this deducted demurrage is then added to the totalDGXsClaimed
        // This is as if, the user claims exactly _demurrageFees DGXs, which would be used immediately to pay for the demurrage on his claimableDGXs,
        // from dgxDistributionDay of (lastQuarterThatRewardsWasUpdated + 1) to dgxDistributionDay of (lastParticipatedQuarter + 1)
        // This is done as such, so that this _demurrageFees would "flow back into the DAO" and be counted in the dgxRewardsPool of this current quarter (in other words, dgxRewardsPoolLastQuarter of the next quarter, as will be calculated in calculateGlobalRewardsBeforeNewQuarter of the next quarter)
        // this is not 100% techinally correct as a demurrage concept, because this demurrage fees could have been incurred for the duration of the quarters in the past, but we will account them this way, as if its demurrage fees for this quarter, for simplicity.
        daoRewardsStorage().addToTotalDgxClaimed(_demurrageFees);

        uint256 _dgxRewardsAsParticipant;
        uint256 _dgxRewardsAsModerator;
        (_dgxRewardsAsParticipant, _dgxRewardsAsModerator) = daoRewardsManagerExtras().calculateUserRewardsForLastParticipatingQuarter(_user);
        _userClaimableDgx = _userClaimableDgx.add(_dgxRewardsAsParticipant).add(_dgxRewardsAsModerator);

        // update claimableDGXs. The calculation just now should have taken into account demurrage
        // such that the demurrage has been paid until dgxDistributionDay of (lastParticipatedQuarter + 1)
        daoRewardsStorage().updateClaimableDGX(_user, _userClaimableDgx);

        // update lastQuarterThatRewardsWasUpdated
        daoRewardsStorage().updateLastQuarterThatRewardsWasUpdated(_user, data.lastParticipatedQuarter);
        _valid = true;
    }

    /**
    @notice Function called by the founder after transfering the DGX fees into the DAO at the beginning of the quarter
    @dev This function needs to do lots of calculation, so it might not fit into one transaction
         As such, it could be done in multiple transactions, each time passing _operations which is the number of operations we want to calculate.
         When the value of _done is finally true, that's when the calculation is done.
         Only after this function runs, any other activities in the DAO could happen.

         Basically, if there were M participants and N moderators in the previous quarter, it takes M+N "operations".

         In summary, the function populates the DaoQuarterInfo of this quarter.
         The bulk of the calculation is to go through every participant in the previous quarter to calculate their effectiveDGDBalance and sum them to get the
         totalEffectiveDGDLastQuarter
    */
    function calculateGlobalRewardsBeforeNewQuarter(uint256 _operations)
        public
        if_founder()
        returns (bool _done)
    {
        require(isDaoNotReplaced());
        require(daoUpgradeStorage().startOfFirstQuarter() != 0); // start of first quarter must have been set already
        require(isLockingPhase());
        require(daoRewardsStorage().readDgxDistributionDay(currentQuarterNumber()) == 0); // throw if this function has already finished running this quarter

        QuarterRewardsInfo memory info;
        info.previousQuarter = currentQuarterNumber().sub(1);
        require(info.previousQuarter > 0); // throw if this is the first quarter
        info.qInfo = readQuarterInfo(info.previousQuarter);

        DaoStructs.IntermediateResults memory interResults;
        (
            interResults.countedUntil,,,
            info.totalEffectiveDGDPreviousQuarter
        ) = intermediateResultsStorage().getIntermediateResults(
            getIntermediateResultsIdForGlobalRewards(info.previousQuarter, false)
        );

        uint256 _operationsLeft = sumEffectiveBalance(info, false, _operations, interResults);
        // now we are left with _operationsLeft operations
        // the results is saved in interResults

        // if we have not done with calculating the effective balance, quit.
        if (!info.doneCalculatingEffectiveBalance) { return false; }

        (
            interResults.countedUntil,,,
            info.totalEffectiveModeratorDGDLastQuarter
        ) = intermediateResultsStorage().getIntermediateResults(
            getIntermediateResultsIdForGlobalRewards(info.previousQuarter, true)
        );

        sumEffectiveBalance(info, true, _operationsLeft, interResults);

        // if we have not done with calculating the moderator effective balance, quit.
        if (!info.doneCalculatingModeratorEffectiveBalance) { return false; }

        // we have done the heavey calculation, now save the quarter info
        processGlobalRewardsUpdate(info);
        _done = true;

        emit StartNewQuarter(currentQuarterNumber());
    }


    // get the Id for the intermediateResult for a quarter's global rewards calculation
    function getIntermediateResultsIdForGlobalRewards(uint256 _quarterNumber, bool _forModerator) internal view returns (bytes32 _id) {
        _id = keccak256(abi.encodePacked(
            _forModerator ? INTERMEDIATE_MODERATOR_DGD_IDENTIFIER : INTERMEDIATE_DGD_IDENTIFIER,
            _quarterNumber
        ));
    }


    // final step in calculateGlobalRewardsBeforeNewQuarter, which is to save the DaoQuarterInfo struct for this quarter
    function processGlobalRewardsUpdate(QuarterRewardsInfo memory info) internal {
        // calculate how much DGX rewards we got for this quarter
        info.dgxRewardsPoolLastQuarter =
            ERC20(ADDRESS_DGX_TOKEN).balanceOf(address(this))
            .add(daoRewardsStorage().totalDGXsClaimed())
            .sub(info.qInfo.sumRewardsFromBeginning);

        // starting new quarter, no one locked in DGDs yet
        daoStakeStorage().updateTotalLockedDGDStake(0);
        daoStakeStorage().updateTotalModeratorLockedDGDs(0);

        daoRewardsStorage().updateQuarterInfo(
            info.previousQuarter.add(1),
            getUintConfig(CONFIG_MINIMAL_QUARTER_POINT),
            getUintConfig(CONFIG_QUARTER_POINT_SCALING_FACTOR),
            getUintConfig(CONFIG_REPUTATION_POINT_SCALING_FACTOR),
            info.totalEffectiveDGDPreviousQuarter,

            getUintConfig(CONFIG_MODERATOR_MINIMAL_QUARTER_POINT),
            getUintConfig(CONFIG_MODERATOR_QUARTER_POINT_SCALING_FACTOR),
            getUintConfig(CONFIG_MODERATOR_REPUTATION_POINT_SCALING_FACTOR),
            info.totalEffectiveModeratorDGDLastQuarter,

            now,
            info.dgxRewardsPoolLastQuarter,
            info.qInfo.sumRewardsFromBeginning.add(info.dgxRewardsPoolLastQuarter)
        );
    }


    // Sum the effective balance (could be effectiveDGDBalance or effectiveModeratorDGDBalance), given that we have _operations left
    function sumEffectiveBalance (
        QuarterRewardsInfo memory info,
        bool _badgeCalculation, // false if this is the first step, true if its the second step
        uint256 _operations,
        DaoStructs.IntermediateResults memory _interResults
    )
        internal
        returns (uint _operationsLeft)
    {
        if (_operations == 0) return _operations; // no more operations left, quit

        if (_interResults.countedUntil == EMPTY_ADDRESS) {
            // if this is the first time we are doing this calculation, we need to
            // get the list of the participants to calculate by querying the first _operations participants
            info.users = _badgeCalculation ?
                daoListingService().listModerators(_operations, true)
                : daoListingService().listParticipants(_operations, true);
        } else {
            info.users = _badgeCalculation ?
                daoListingService().listModeratorsFrom(_interResults.countedUntil, _operations, true)
                : daoListingService().listParticipantsFrom(_interResults.countedUntil, _operations, true);

            // if this list is the already empty, it means this is the first step (calculating effective balance), and its already done;
            if (info.users.length == 0) {
                info.doneCalculatingEffectiveBalance = true;
                return _operations;
            }
        }

        address _lastAddress;
        _lastAddress = info.users[info.users.length - 1];

        info.userCount = info.users.length;
        for (info.i=0;info.i<info.userCount;info.i++) {
            info.currentUser = info.users[info.i];
            // check if this participant really did participate in the previous quarter
            if (daoRewardsStorage().lastParticipatedQuarter(info.currentUser) != info.previousQuarter) {
                continue;
            }
            if (_badgeCalculation) {
                info.totalEffectiveModeratorDGDLastQuarter = info.totalEffectiveModeratorDGDLastQuarter.add(daoCalculatorService().calculateUserEffectiveBalance(
                    info.qInfo.moderatorMinimalParticipationPoint,
                    info.qInfo.moderatorQuarterPointScalingFactor,
                    info.qInfo.moderatorReputationPointScalingFactor,
                    daoPointsStorage().getQuarterModeratorPoint(info.currentUser, info.previousQuarter),
                    daoPointsStorage().getReputation(info.currentUser),
                    daoStakeStorage().lockedDGDStake(info.currentUser)
                ));
            } else {
                info.totalEffectiveDGDPreviousQuarter = info.totalEffectiveDGDPreviousQuarter.add(daoCalculatorService().calculateUserEffectiveBalance(
                    info.qInfo.minimalParticipationPoint,
                    info.qInfo.quarterPointScalingFactor,
                    info.qInfo.reputationPointScalingFactor,
                    daoPointsStorage().getQuarterPoint(info.currentUser, info.previousQuarter),
                    daoPointsStorage().getReputation(info.currentUser),
                    daoStakeStorage().lockedDGDStake(info.currentUser)
                ));
            }
        }

        // check if we have reached the last guy in the current list
        if (_lastAddress == daoStakeStorage().readLastModerator() && _badgeCalculation) {
            info.doneCalculatingModeratorEffectiveBalance = true;
        }
        if (_lastAddress == daoStakeStorage().readLastParticipant() && !_badgeCalculation) {
            info.doneCalculatingEffectiveBalance = true;
        }
        // save to the intermediateResult storage
        intermediateResultsStorage().setIntermediateResults(
            getIntermediateResultsIdForGlobalRewards(info.previousQuarter, _badgeCalculation),
            _lastAddress,
            0,0,
            _badgeCalculation ? info.totalEffectiveModeratorDGDLastQuarter : info.totalEffectiveDGDPreviousQuarter
        );

        _operationsLeft = _operations.sub(info.userCount);
    }
}

/**
@title Contract to claim voting results
@author Digix Holdings
*/
contract DaoVotingClaims is DaoCommon {
    using DaoIntermediateStructs for DaoIntermediateStructs.VotingCount;
    using DaoIntermediateStructs for DaoIntermediateStructs.Users;
    using DaoStructs for DaoStructs.IntermediateResults;

    function daoCalculatorService()
        internal
        view
        returns (DaoCalculatorService _contract)
    {
        _contract = DaoCalculatorService(get_contract(CONTRACT_SERVICE_DAO_CALCULATOR));
    }

    function daoFundingManager()
        internal
        view
        returns (DaoFundingManager _contract)
    {
        _contract = DaoFundingManager(get_contract(CONTRACT_DAO_FUNDING_MANAGER));
    }

    function daoRewardsManager()
        internal
        view
        returns (DaoRewardsManager _contract)
    {
        _contract = DaoRewardsManager(get_contract(CONTRACT_DAO_REWARDS_MANAGER));
    }

    constructor(address _resolver) public {
        require(init(CONTRACT_DAO_VOTING_CLAIMS, _resolver));
    }


    /**
    @notice Function to claim the draft voting result (can only be called by the proposal proposer)
    @dev The founder/or anyone is supposed to call this function after the claiming deadline has passed, to clean it up and close this proposal.
         If this voting fails, the collateral will be refunded
    @param _proposalId ID of the proposal
    @param _operations Number of operations to do in this call
    @return {
      "_passed": "Boolean, true if the draft voting has passed, false if the claiming deadline has passed or the voting has failed",
      "_done": "Boolean, true if the calculation has finished"
    }
    */
    function claimDraftVotingResult(
        bytes32 _proposalId,
        uint256 _operations
    )
        public
        ifDraftNotClaimed(_proposalId)
        ifAfterDraftVotingPhase(_proposalId)
        returns (bool _passed, bool _done)
    {
        // if after the claiming deadline, or the limit for non-digix proposals is reached, its auto failed
        if (now > daoStorage().readProposalDraftVotingTime(_proposalId)
                    .add(getUintConfig(CONFIG_DRAFT_VOTING_PHASE))
                    .add(getUintConfig(CONFIG_VOTE_CLAIMING_DEADLINE))
            || !isNonDigixProposalsWithinLimit(_proposalId))
        {
            daoStorage().setProposalDraftPass(_proposalId, false);
            daoStorage().setDraftVotingClaim(_proposalId, true);
            processCollateralRefund(_proposalId);
            return (false, true);
        }
        require(isFromProposer(_proposalId));
        senderCanDoProposerOperations();

        // get the previously stored intermediary state
        DaoStructs.IntermediateResults memory _currentResults;
        (
            _currentResults.countedUntil,
            _currentResults.currentForCount,
            _currentResults.currentAgainstCount,
        ) = intermediateResultsStorage().getIntermediateResults(_proposalId);

        // get the moderators to calculate in this transaction, based on intermediate state
        address[] memory _moderators;
        if (_currentResults.countedUntil == EMPTY_ADDRESS) {
            _moderators = daoListingService().listModerators(
                _operations,
                true
            );
        } else {
            _moderators = daoListingService().listModeratorsFrom(
               _currentResults.countedUntil,
               _operations,
               true
           );
        }

        // count the votes for this batch of moderators
        DaoIntermediateStructs.VotingCount memory _voteCount;
        (_voteCount.forCount, _voteCount.againstCount) = daoStorage().readDraftVotingCount(_proposalId, _moderators);

        _currentResults.countedUntil = _moderators[_moderators.length-1];
        _currentResults.currentForCount = _currentResults.currentForCount.add(_voteCount.forCount);
        _currentResults.currentAgainstCount = _currentResults.currentAgainstCount.add(_voteCount.againstCount);

        if (_moderators[_moderators.length-1] == daoStakeStorage().readLastModerator()) {
            // this is the last iteration
            _passed = processDraftVotingClaim(_proposalId, _currentResults);
            _done = true;

            // reset intermediate result for the proposal.
            intermediateResultsStorage().resetIntermediateResults(_proposalId);
        } else {
            // update intermediate results
            intermediateResultsStorage().setIntermediateResults(
                _proposalId,
                _currentResults.countedUntil,
                _currentResults.currentForCount,
                _currentResults.currentAgainstCount,
                0
            );
        }
    }


    function processDraftVotingClaim(bytes32 _proposalId, DaoStructs.IntermediateResults _currentResults)
        internal
        returns (bool _passed)
    {
        if (
            (_currentResults.currentForCount.add(_currentResults.currentAgainstCount) > daoCalculatorService().minimumDraftQuorum(_proposalId)) &&
            (daoCalculatorService().draftQuotaPass(_currentResults.currentForCount, _currentResults.currentAgainstCount))
        ) {
            daoStorage().setProposalDraftPass(_proposalId, true);

            // set startTime of first voting round
            // and the start of first milestone.
            uint256 _idealStartTime = daoStorage().readProposalDraftVotingTime(_proposalId).add(getUintConfig(CONFIG_DRAFT_VOTING_PHASE));
            daoStorage().setProposalVotingTime(
                _proposalId,
                0,
                getTimelineForNextVote(0, _idealStartTime)
            );
            _passed = true;
        } else {
            daoStorage().setProposalDraftPass(_proposalId, false);
            processCollateralRefund(_proposalId);
        }

        daoStorage().setDraftVotingClaim(_proposalId, true);
    }

    /// NOTE: Voting round i-th is before milestone index i-th


    /**
    @notice Function to claim the  voting round results
    @dev This function has two major steps:
         - Counting the votes
            + There is no need for this step if there are some conditions that makes the proposal auto failed
            + The number of operations needed for this step is the number of participants in the quarter
         - Calculating the bonus for the voters in the preceding round
            + We can skip this step if this is the Voting round 0 (there is no preceding voting round to calculate bonus)
            + The number of operations needed for this step is the number of participants who voted "correctly" in the preceding voting round
         Step 1 will have to finish first before step 2. The proposer is supposed to call this function repeatedly,
         until _done is true

         If the voting round fails, the collateral will be returned back to the proposer
    @param _proposalId ID of the proposal
    @param _index Index of the  voting round
    @param _operations Number of operations to do in this call
    @return {
      "_passed": "Boolean, true if the  voting round passed, false if failed"
    }
    */
    function claimProposalVotingResult(bytes32 _proposalId, uint256 _index, uint256 _operations)
        public
        ifNotClaimed(_proposalId, _index)
        ifAfterProposalRevealPhase(_proposalId, _index)
        returns (bool _passed, bool _done)
    {
        require(isMainPhase());

        // STEP 1
        // If the claiming deadline is over, the proposal is auto failed, and anyone can call this function
        // Here, _done is refering to whether STEP 1 is done
        _done = true;
        _passed = false; // redundant, put here just to emphasize that its false
        uint256 _operationsLeft = _operations;
        // In other words, we only need to do Step 1 if its before the deadline
        if (now < startOfMilestone(_proposalId, _index)
                    .add(getUintConfig(CONFIG_VOTE_CLAIMING_DEADLINE)))
        {
            (_operationsLeft, _passed, _done) = countProposalVote(_proposalId, _index, _operations);
            // from here on, _operationsLeft is the number of operations left, after Step 1 is done
            if (!_done) return (_passed, false); // haven't done Step 1 yet, return. The value of _passed here is irrelevant
        }

        // STEP 2
        // from this point onwards, _done refers to step 2
        _done = false;

        if (_index > 0) { // We only need to do bonus calculation if its a interim voting round
            _done = calculateVoterBonus(_proposalId, _index, _operationsLeft, _passed);
            if (!_done) return (_passed, false); // Step 2 is not done yet, return
        } else {
            // its the first voting round, we return the collateral if it fails, locks if it passes

            _passed = _passed && isNonDigixProposalsWithinLimit(_proposalId); // can only pass if its within the non-digix proposal limit
            if (_passed) {
                daoStorage().setProposalCollateralStatus(
                    _proposalId,
                    COLLATERAL_STATUS_LOCKED
                );

            } else {
                processCollateralRefund(_proposalId);
            }
        }

        if (_passed) {
            processSuccessfulVotingClaim(_proposalId, _index);
        }
        daoStorage().setVotingClaim(_proposalId, _index, true);
        daoStorage().setProposalPass(_proposalId, _index, _passed);
        _done = true;
    }


    // do the necessary steps after a successful voting round.
    function processSuccessfulVotingClaim(bytes32 _proposalId, uint256 _index)
        internal
    {
        // clear the intermediate results for the proposal, so that next voting rounds can reuse the same key <proposal_id> for the intermediate results
        intermediateResultsStorage().resetIntermediateResults(_proposalId);

        // if this was the final voting round, unlock their original collateral
        uint256[] memory _milestoneFundings;
        (_milestoneFundings,) = daoStorage().readProposalFunding(_proposalId);
        if (_index == _milestoneFundings.length) {
            processCollateralRefund(_proposalId);
            daoStorage().archiveProposal(_proposalId);
        }

        // increase the non-digix proposal count accordingly
        bool _isDigixProposal;
        (,,,,,,,,,_isDigixProposal) = daoStorage().readProposal(_proposalId);
        if (_index == 0 && !_isDigixProposal) {
            daoProposalCounterStorage().addNonDigixProposalCountInQuarter(currentQuarterNumber());
        }

        // Add quarter point for the proposer
        uint256 _funding = daoStorage().readProposalMilestone(_proposalId, _index);
        daoPointsStorage().addQuarterPoint(
            daoStorage().readProposalProposer(_proposalId),
            getUintConfig(CONFIG_QUARTER_POINT_MILESTONE_COMPLETION_PER_10000ETH).mul(_funding).div(10000 ether),
            currentQuarterNumber()
        );
    }


    function getInterResultKeyForBonusCalculation(bytes32 _proposalId) public view returns (bytes32 _key) {
        _key = keccak256(abi.encodePacked(
            _proposalId,
            INTERMEDIATE_BONUS_CALCULATION_IDENTIFIER
        ));
    }


    // calculate and update the bonuses for voters who voted "correctly" in the preceding voting round
    function calculateVoterBonus(bytes32 _proposalId, uint256 _index, uint256 _operations, bool _passed)
        internal
        returns (bool _done)
    {
        if (_operations == 0) return false;
        address _countedUntil;
        (_countedUntil,,,) = intermediateResultsStorage().getIntermediateResults(
            getInterResultKeyForBonusCalculation(_proposalId)
        );

        address[] memory _voterBatch;
        if (_countedUntil == EMPTY_ADDRESS) {
            _voterBatch = daoListingService().listParticipants(
                _operations,
                true
            );
        } else {
            _voterBatch = daoListingService().listParticipantsFrom(
                _countedUntil,
                _operations,
                true
            );
        }
        address _lastVoter = _voterBatch[_voterBatch.length - 1]; // this will fail if _voterBatch is empty. However, there is at least the proposer as a participant in the quarter.

        DaoIntermediateStructs.Users memory _bonusVoters;
        if (_passed) {

            // give bonus points for all those who
            // voted YES in the previous round
            (_bonusVoters.users, _bonusVoters.usersLength) = daoStorage().readVotingRoundVotes(_proposalId, _index.sub(1), _voterBatch, true);
        } else {
            // give bonus points for all those who
            // voted NO in the previous round
            (_bonusVoters.users, _bonusVoters.usersLength) = daoStorage().readVotingRoundVotes(_proposalId, _index.sub(1), _voterBatch, false);
        }

        if (_bonusVoters.usersLength > 0) addBonusReputation(_bonusVoters.users, _bonusVoters.usersLength);

        if (_lastVoter == daoStakeStorage().readLastParticipant()) {
            // this is the last iteration

            intermediateResultsStorage().resetIntermediateResults(
                getInterResultKeyForBonusCalculation(_proposalId)
            );
            _done = true;
        } else {
            // this is not the last iteration yet, save the intermediate results
            intermediateResultsStorage().setIntermediateResults(
                getInterResultKeyForBonusCalculation(_proposalId),
                _lastVoter, 0, 0, 0
            );
        }
    }


    // Count the votes for a Voting Round and find out if its passed
    /// @return _operationsLeft The number of operations left after the calculations in this function
    /// @return _passed Whether this voting round passed
    /// @return _done Whether the calculation for this step 1 is already done. If its not done, this function will need to run again in subsequent transactions
    /// until _done is true
    function countProposalVote(bytes32 _proposalId, uint256 _index, uint256 _operations)
        internal
        returns (uint256 _operationsLeft, bool _passed, bool _done)
    {
        senderCanDoProposerOperations();
        require(isFromProposer(_proposalId));

        DaoStructs.IntermediateResults memory _currentResults;
        (
            _currentResults.countedUntil,
            _currentResults.currentForCount,
            _currentResults.currentAgainstCount,
        ) = intermediateResultsStorage().getIntermediateResults(_proposalId);
        address[] memory _voters;
        if (_currentResults.countedUntil == EMPTY_ADDRESS) { // This is the first transaction to count votes for this voting round
            _voters = daoListingService().listParticipants(
                _operations,
                true
            );
        } else {
            _voters = daoListingService().listParticipantsFrom(
                _currentResults.countedUntil,
                _operations,
                true
            );

            // If there's no voters left to count, this means that STEP 1 is already done, just return whether it was passed
            // Note that _currentResults should already be storing the final tally of votes for this voting round, as already calculated in previous iterations of this function
            if (_voters.length == 0) {
                return (
                    _operations,
                    isVoteCountPassed(_currentResults, _proposalId, _index),
                    true
                );
            }
        }

        address _lastVoter = _voters[_voters.length - 1];

        DaoIntermediateStructs.VotingCount memory _count;
        (_count.forCount, _count.againstCount) = daoStorage().readVotingCount(_proposalId, _index, _voters);

        _currentResults.currentForCount = _currentResults.currentForCount.add(_count.forCount);
        _currentResults.currentAgainstCount = _currentResults.currentAgainstCount.add(_count.againstCount);
        intermediateResultsStorage().setIntermediateResults(
            _proposalId,
            _lastVoter,
            _currentResults.currentForCount,
            _currentResults.currentAgainstCount,
            0
        );

        if (_lastVoter != daoStakeStorage().readLastParticipant()) {
            return (0, false, false); // hasn't done STEP 1 yet. The parent function (claimProposalVotingResult) should return after this. More transactions are needed to continue the calculation
        }

        // If it comes to here, this means all votes have already been counted
        // From this point, the IntermediateResults struct will store the total tally of the votes for this voting round until processSuccessfulVotingClaim() is called,
        // which will reset it.

        _operationsLeft = _operations.sub(_voters.length);
        _done = true;

        _passed = isVoteCountPassed(_currentResults, _proposalId, _index);
    }


    function isVoteCountPassed(DaoStructs.IntermediateResults _currentResults, bytes32 _proposalId, uint256 _index)
        internal
        view
        returns (bool _passed)
    {
        _passed = (_currentResults.currentForCount.add(_currentResults.currentAgainstCount) > daoCalculatorService().minimumVotingQuorum(_proposalId, _index))
                && (daoCalculatorService().votingQuotaPass(_currentResults.currentForCount, _currentResults.currentAgainstCount));
    }


    function processCollateralRefund(bytes32 _proposalId)
        internal
    {
        daoStorage().setProposalCollateralStatus(_proposalId, COLLATERAL_STATUS_CLAIMED);
        require(daoFundingManager().refundCollateral(daoStorage().readProposalProposer(_proposalId), _proposalId));
    }


    // add bonus reputation for voters that voted "correctly" in the preceding voting round AND is currently participating this quarter
    function addBonusReputation(address[] _voters, uint256 _n)
        private
    {
        uint256 _qp = getUintConfig(CONFIG_QUARTER_POINT_VOTE);
        uint256 _rate = getUintConfig(CONFIG_BONUS_REPUTATION_NUMERATOR);
        uint256 _base = getUintConfig(CONFIG_BONUS_REPUTATION_DENOMINATOR);

        uint256 _bonus = _qp.mul(_rate).mul(getUintConfig(CONFIG_REPUTATION_PER_EXTRA_QP_NUM))
            .div(
                _base.mul(getUintConfig(CONFIG_REPUTATION_PER_EXTRA_QP_DEN))
            );

        for (uint256 i = 0; i < _n; i++) {
            if (isParticipant(_voters[i])) { // only give bonus reputation to current participants
                daoPointsStorage().increaseReputation(_voters[i], _bonus);
            }
        }
    }
}

/**
@title Interactive DAO contract for creating/modifying/endorsing proposals
@author Digix Holdings
*/
contract Dao is DaoCommon {

    event NewProposal(bytes32 indexed _proposalId, address _proposer);
    event ModifyProposal(bytes32 indexed _proposalId, bytes32 _newDoc);
    event ChangeProposalFunding(bytes32 indexed _proposalId);
    event FinalizeProposal(bytes32 indexed _proposalId);
    event FinishMilestone(bytes32 indexed _proposalId, uint256 indexed _milestoneIndex);
    event AddProposalDoc(bytes32 indexed _proposalId, bytes32 _newDoc);
    event PRLAction(bytes32 indexed _proposalId, uint256 _actionId, bytes32 _doc);
    event CloseProposal(bytes32 indexed _proposalId);

    constructor(address _resolver) public {
        require(init(CONTRACT_DAO, _resolver));
    }

    function daoFundingManager()
        internal
        view
        returns (DaoFundingManager _contract)
    {
        _contract = DaoFundingManager(get_contract(CONTRACT_DAO_FUNDING_MANAGER));
    }

    function daoRewardsManager()
        internal
        view
        returns (DaoRewardsManager _contract)
    {
        _contract = DaoRewardsManager(get_contract(CONTRACT_DAO_REWARDS_MANAGER));
    }

    function daoVotingClaims()
        internal
        view
        returns (DaoVotingClaims _contract)
    {
        _contract = DaoVotingClaims(get_contract(CONTRACT_DAO_VOTING_CLAIMS));
    }

    /**
    @notice Set addresses for the new Dao and DaoFundingManager contracts
    @dev This is the first step of the 2-step migration
    @param _newDaoContract Address of the new Dao contract
    @param _newDaoFundingManager Address of the new DaoFundingManager contract
    @param _newDaoRewardsManager Address of the new daoRewardsManager contract
    */
    function setNewDaoContracts(
        address _newDaoContract,
        address _newDaoFundingManager,
        address _newDaoRewardsManager
    )
        public
        if_root()
    {
        require(daoUpgradeStorage().isReplacedByNewDao() == false);
        daoUpgradeStorage().setNewContractAddresses(
            _newDaoContract,
            _newDaoFundingManager,
            _newDaoRewardsManager
        );
    }

    /**
    @notice Migrate this DAO to a new DAO contract
    @dev This is the second step of the 2-step migration
         Migration can only be done during the locking phase, after the global rewards for current quarter are set.
         This is to make sure that there is no rewards calculation pending before the DAO is migrated to new contracts
         The addresses of the new Dao contracts have to be provided again, and be double checked against the addresses that were set in setNewDaoContracts()
    @param _newDaoContract Address of the new DAO contract
    @param _newDaoFundingManager Address of the new DaoFundingManager contract, which would receive the remaining ETHs in this DaoFundingManager
    @param _newDaoRewardsManager Address of the new daoRewardsManager contract, which would receive the claimableDGXs from this daoRewardsManager
    */
    function migrateToNewDao(
        address _newDaoContract,
        address _newDaoFundingManager,
        address _newDaoRewardsManager
    )
        public
        if_root()
        ifGlobalRewardsSet(currentQuarterNumber())
    {
        require(isLockingPhase());
        require(daoUpgradeStorage().isReplacedByNewDao() == false);
        require(
          (daoUpgradeStorage().newDaoContract() == _newDaoContract) &&
          (daoUpgradeStorage().newDaoFundingManager() == _newDaoFundingManager) &&
          (daoUpgradeStorage().newDaoRewardsManager() == _newDaoRewardsManager)
        );
        daoUpgradeStorage().updateForDaoMigration();
        daoFundingManager().moveFundsToNewDao(_newDaoFundingManager);
        daoRewardsManager().moveDGXsToNewDao(_newDaoRewardsManager);
    }

    /**
    @notice Call this function to mark the start of the DAO's first quarter. This can only be done once, by a founder
    @param _start Start time of the first quarter in the DAO
    */
    function setStartOfFirstQuarter(uint256 _start) public if_founder() {
        require(daoUpgradeStorage().startOfFirstQuarter() == 0);
        require(_start > 0);
        daoUpgradeStorage().setStartOfFirstQuarter(_start);
    }

    /**
    @notice Submit a new preliminary idea / Pre-proposal
    @dev The proposer has to send in a collateral == getUintConfig(CONFIG_PREPROPOSAL_COLLATERAL)
         which he could claim back in these scenarios:
          - Before the proposal is finalized, by calling closeProposal()
          - After all milestones are done and the final voting round is passed

    @param _docIpfsHash Hash of the IPFS doc containing details of proposal
    @param _milestonesFundings Array of fundings of the proposal milestones (in wei)
    @param _finalReward Final reward asked by proposer at successful completion of all milestones of proposal
    */
    function submitPreproposal(
        bytes32 _docIpfsHash,
        uint256[] _milestonesFundings,
        uint256 _finalReward
    )
        external
        payable
        ifFundingPossible(_milestonesFundings, _finalReward)
    {
        senderCanDoProposerOperations();
        bool _isFounder = is_founder();

        require(msg.value == getUintConfig(CONFIG_PREPROPOSAL_COLLATERAL));
        require(address(daoFundingManager()).call.gas(25000).value(msg.value)());

        checkNonDigixFundings(_milestonesFundings, _finalReward);

        daoStorage().addProposal(_docIpfsHash, msg.sender, _milestonesFundings, _finalReward, _isFounder);
        daoStorage().setProposalCollateralStatus(_docIpfsHash, COLLATERAL_STATUS_UNLOCKED);
        daoStorage().setProposalCollateralAmount(_docIpfsHash, msg.value);

        emit NewProposal(_docIpfsHash, msg.sender);
    }

    /**
    @notice Modify a proposal (this can be done only before setting the final version)
    @param _proposalId Proposal ID (hash of IPFS doc of the first version of the proposal)
    @param _docIpfsHash Hash of IPFS doc of the modified version of the proposal
    @param _milestonesFundings Array of fundings of the modified version of the proposal (in wei)
    @param _finalReward Final reward on successful completion of all milestones of the modified version of proposal (in wei)
    */
    function modifyProposal(
        bytes32 _proposalId,
        bytes32 _docIpfsHash,
        uint256[] _milestonesFundings,
        uint256 _finalReward
    )
        external
    {
        senderCanDoProposerOperations();
        require(isFromProposer(_proposalId));

        require(isEditable(_proposalId));
        bytes32 _currentState;
        (,,,_currentState,,,,,,) = daoStorage().readProposal(_proposalId);
        require(_currentState == PROPOSAL_STATE_PREPROPOSAL ||
          _currentState == PROPOSAL_STATE_DRAFT);

        checkNonDigixFundings(_milestonesFundings, _finalReward);

        daoStorage().editProposal(_proposalId, _docIpfsHash, _milestonesFundings, _finalReward);

        emit ModifyProposal(_proposalId, _docIpfsHash);
    }

    /**
    @notice Function to change the funding structure for a proposal
    @dev Proposers can only change fundings for the subsequent milestones,
    during the duration of an on-going milestone (so, cannot be before proposal finalization or during any voting phase)
    @param _proposalId ID of the proposal
    @param _milestonesFundings Array of fundings for milestones
    @param _finalReward Final reward needed for completion of proposal
    @param _currentMilestone the milestone number the proposal is currently in
    */
    function changeFundings(
        bytes32 _proposalId,
        uint256[] _milestonesFundings,
        uint256 _finalReward,
        uint256 _currentMilestone
    )
        external
    {
        senderCanDoProposerOperations();
        require(isFromProposer(_proposalId));

        checkNonDigixFundings(_milestonesFundings, _finalReward);

        uint256[] memory _currentFundings;
        (_currentFundings,) = daoStorage().readProposalFunding(_proposalId);

        // If there are N milestones, the milestone index must be < N. Otherwise, putting a milestone index of N will actually return a valid timestamp that is
        // right after the final voting round (voting round index N is the final voting round)
        // Which could be abused ( to add more milestones even after the final voting round)
        require(_currentMilestone < _currentFundings.length);

        uint256 _startOfCurrentMilestone = startOfMilestone(_proposalId, _currentMilestone);

        // must be after the start of the milestone, and the milestone has not been finished yet (next voting hasnt started)
        require(now > _startOfCurrentMilestone);
        require(daoStorage().readProposalVotingTime(_proposalId, _currentMilestone.add(1)) == 0);

        // can only modify the fundings after _currentMilestone
        // so, all the fundings from 0 to _currentMilestone must be the same
        for (uint256 i=0;i<=_currentMilestone;i++) {
            require(_milestonesFundings[i] == _currentFundings[i]);
        }

        daoStorage().changeFundings(_proposalId, _milestonesFundings, _finalReward);

        emit ChangeProposalFunding(_proposalId);
    }

    /**
    @notice Finalize a proposal
    @dev After finalizing a proposal, no more proposal version can be added. Proposer will only be able to change fundings and add more docs
         Right after finalizing a proposal, the draft voting round starts. The proposer would also not be able to closeProposal() anymore
         (hence, cannot claim back the collateral anymore, until the final voting round passes)
    @param _proposalId ID of the proposal
    */
    function finalizeProposal(bytes32 _proposalId)
        public
    {
        senderCanDoProposerOperations();
        require(isFromProposer(_proposalId));
        require(isEditable(_proposalId));
        checkNonDigixProposalLimit(_proposalId);

        // make sure we have reasonably enough time left in the quarter to conduct the Draft Voting.
        // Otherwise, the proposer must wait until the next quarter to finalize the proposal
        require(getTimeLeftInQuarter(now) > getUintConfig(CONFIG_DRAFT_VOTING_PHASE).add(getUintConfig(CONFIG_VOTE_CLAIMING_DEADLINE)));
        address _endorser;
        (,,_endorser,,,,,,,) = daoStorage().readProposal(_proposalId);
        require(_endorser != EMPTY_ADDRESS);
        daoStorage().finalizeProposal(_proposalId);
        daoStorage().setProposalDraftVotingTime(_proposalId, now);

        emit FinalizeProposal(_proposalId);
    }

    /**
    @notice Function to set milestone to be completed
    @dev This can only be called in the Main Phase of DigixDAO by the proposer. It sets the
         voting time for the next milestone, which is immediately, for most of the times. If there is not enough time left in the current
         quarter, then the next voting is postponed to the start of next quarter
    @param _proposalId ID of the proposal
    @param _milestoneIndex Index of the milestone. Index starts from 0 (for the first milestone)
    */
    function finishMilestone(bytes32 _proposalId, uint256 _milestoneIndex)
        public
    {
        senderCanDoProposerOperations();
        require(isFromProposer(_proposalId));

        uint256[] memory _currentFundings;
        (_currentFundings,) = daoStorage().readProposalFunding(_proposalId);

        // If there are N milestones, the milestone index must be < N. Otherwise, putting a milestone index of N will actually return a valid timestamp that is
        // right after the final voting round (voting round index N is the final voting round)
        // Which could be abused ( to "finish" a milestone even after the final voting round)
        require(_milestoneIndex < _currentFundings.length);

        // must be after the start of this milestone, and the milestone has not been finished yet (voting hasnt started)
        uint256 _startOfCurrentMilestone = startOfMilestone(_proposalId, _milestoneIndex);
        require(now > _startOfCurrentMilestone);
        require(daoStorage().readProposalVotingTime(_proposalId, _milestoneIndex.add(1)) == 0);

        daoStorage().setProposalVotingTime(
            _proposalId,
            _milestoneIndex.add(1),
            getTimelineForNextVote(_milestoneIndex.add(1), now)
        ); // set the voting time of next voting

        emit FinishMilestone(_proposalId, _milestoneIndex);
    }

    /**
    @notice Add IPFS docs to a proposal
    @dev This is allowed only after a proposal is finalized. Before finalizing
         a proposal, proposer can modifyProposal and basically create a different ProposalVersion. After the proposal is finalized,
         they can only allProposalDoc to the final version of that proposal
    @param _proposalId ID of the proposal
    @param _newDoc hash of the new IPFS doc
    */
    function addProposalDoc(bytes32 _proposalId, bytes32 _newDoc)
        public
    {
        senderCanDoProposerOperations();
        require(isFromProposer(_proposalId));
        bytes32 _finalVersion;
        (,,,,,,,_finalVersion,,) = daoStorage().readProposal(_proposalId);
        require(_finalVersion != EMPTY_BYTES);
        daoStorage().addProposalDoc(_proposalId, _newDoc);

        emit AddProposalDoc(_proposalId, _newDoc);
    }

    /**
    @notice Function to endorse a pre-proposal (can be called only by DAO Moderator)
    @param _proposalId ID of the proposal (hash of IPFS doc of the first version of the proposal)
    */
    function endorseProposal(bytes32 _proposalId)
        public
        isProposalState(_proposalId, PROPOSAL_STATE_PREPROPOSAL)
    {
        require(isMainPhase());
        require(isModerator(msg.sender));
        daoStorage().updateProposalEndorse(_proposalId, msg.sender);
    }

    /**
    @notice Function to update the PRL (regulatory status) status of a proposal
    @dev if a proposal is paused or stopped, the proposer wont be able to withdraw the funding
    @param _proposalId ID of the proposal
    @param _doc hash of IPFS uploaded document, containing details of PRL Action
    */
    function updatePRL(
        bytes32 _proposalId,
        uint256 _action,
        bytes32 _doc
    )
        public
        if_prl()
    {
        require(_action == PRL_ACTION_STOP || _action == PRL_ACTION_PAUSE || _action == PRL_ACTION_UNPAUSE);
        daoStorage().updateProposalPRL(_proposalId, _action, _doc, now);

        emit PRLAction(_proposalId, _action, _doc);
    }

    /**
    @notice Function to close proposal (also get back collateral)
    @dev Can only be closed if the proposal has not been finalized yet
    @param _proposalId ID of the proposal
    */
    function closeProposal(bytes32 _proposalId)
        public
    {
        senderCanDoProposerOperations();
        require(isFromProposer(_proposalId));
        bytes32 _finalVersion;
        bytes32 _status;
        (,,,_status,,,,_finalVersion,,) = daoStorage().readProposal(_proposalId);
        require(_finalVersion == EMPTY_BYTES);
        require(_status != PROPOSAL_STATE_CLOSED);
        require(daoStorage().readProposalCollateralStatus(_proposalId) == COLLATERAL_STATUS_UNLOCKED);

        daoStorage().closeProposal(_proposalId);
        daoStorage().setProposalCollateralStatus(_proposalId, COLLATERAL_STATUS_CLAIMED);
        emit CloseProposal(_proposalId);
        require(daoFundingManager().refundCollateral(msg.sender, _proposalId));
    }

    /**
    @notice Function for founders to close all the dead proposals
    @dev Dead proposals = all proposals who are not yet finalized, and been there for more than the threshold time
         The proposers of dead proposals will not get the collateral back
    @param _proposalIds Array of proposal IDs
    */
    function founderCloseProposals(bytes32[] _proposalIds)
        external
        if_founder()
    {
        uint256 _length = _proposalIds.length;
        uint256 _timeCreated;
        bytes32 _finalVersion;
        bytes32 _currentState;
        for (uint256 _i = 0; _i < _length; _i++) {
            (,,,_currentState,_timeCreated,,,_finalVersion,,) = daoStorage().readProposal(_proposalIds[_i]);
            require(_finalVersion == EMPTY_BYTES);
            require(
                (_currentState == PROPOSAL_STATE_PREPROPOSAL) ||
                (_currentState == PROPOSAL_STATE_DRAFT)
            );
            require(now > _timeCreated.add(getUintConfig(CONFIG_PROPOSAL_DEAD_DURATION)));
            emit CloseProposal(_proposalIds[_i]);
            daoStorage().closeProposal(_proposalIds[_i]);
        }
    }
}

/**
@title Contract to manage DAO funds
@author Digix Holdings
*/
contract DaoFundingManager is DaoCommon {

    address public FUNDING_SOURCE;

    event ClaimFunding(bytes32 indexed _proposalId, uint256 indexed _votingRound, uint256 _funding);

    constructor(address _resolver, address _fundingSource) public {
        require(init(CONTRACT_DAO_FUNDING_MANAGER, _resolver));
        FUNDING_SOURCE = _fundingSource;
    }

    function dao()
        internal
        view
        returns (Dao _contract)
    {
        _contract = Dao(get_contract(CONTRACT_DAO));
    }

    /**
    @notice Check if a proposal is currently paused/stopped
    @dev If a proposal is paused/stopped (by the PRLs): proposer cannot call for voting, a current on-going voting round can still pass, but no funding can be withdrawn.
    @dev A paused proposal can still be unpaused
    @dev If a proposal is stopped, this function also returns true
    @return _isPausedOrStopped true if the proposal is paused(or stopped)
    */
    function isProposalPaused(bytes32 _proposalId)
        public
        view
        returns (bool _isPausedOrStopped)
    {
        (,,,,,,,,_isPausedOrStopped,) = daoStorage().readProposal(_proposalId);
    }

    /**
    @notice Function to set the source of DigixDAO funding
    @dev only this source address will be able to fund the DaoFundingManager contract, along with CONTRACT_DAO
    @param _fundingSource address of the funding source
    */
    function setFundingSource(address _fundingSource)
        public
        if_root()
    {
        FUNDING_SOURCE = _fundingSource;
    }

    /**
    @notice Call function to claim the ETH funding for a certain milestone
    @dev Note that the proposer can do this anytime, even in the locking phase
    @param _proposalId ID of the proposal
    @param _index Index of the proposal voting round that they got passed, which is also the same as the milestone index
    */
    function claimFunding(bytes32 _proposalId, uint256 _index)
        public
    {
        require(identity_storage().is_kyc_approved(msg.sender));
        require(isFromProposer(_proposalId));

        // proposal should not be paused/stopped
        require(!isProposalPaused(_proposalId));

        require(!daoStorage().readIfMilestoneFunded(_proposalId, _index));

        require(daoStorage().readProposalVotingResult(_proposalId, _index));
        require(daoStorage().isClaimed(_proposalId, _index));

        uint256 _funding = daoStorage().readProposalMilestone(_proposalId, _index);

        daoStorage().setMilestoneFunded(_proposalId, _index);

        msg.sender.transfer(_funding);

        emit ClaimFunding(_proposalId, _index, _funding);
    }

    /**
    @notice Function to refund the collateral to _receiver
    @dev Can only be called from the Dao contract
    @param _receiver The receiver of the funds
    @return {
      "_success": "Boolean, true if refund was successful"
    }
    */
    function refundCollateral(address _receiver, bytes32 _proposalId)
        public
        returns (bool _success)
    {
        require(sender_is_from([CONTRACT_DAO, CONTRACT_DAO_VOTING_CLAIMS, EMPTY_BYTES]));
        refundCollateralInternal(_receiver, _proposalId);
        _success = true;
    }

    function refundCollateralInternal(address _receiver, bytes32 _proposalId)
        internal
    {
        uint256 _collateralAmount = daoStorage().readProposalCollateralAmount(_proposalId);
        _receiver.transfer(_collateralAmount);
    }

    /**
    @notice Function to move funds to a new DAO
    @param _destinationForDaoFunds Ethereum contract address of the new DaoFundingManager
    */
    function moveFundsToNewDao(address _destinationForDaoFunds)
        public
    {
        require(sender_is(CONTRACT_DAO));
        uint256 _remainingBalance = address(this).balance;
        _destinationForDaoFunds.transfer(_remainingBalance);
    }

    /**
    @notice Payable fallback function to receive ETH funds from DigixDAO crowdsale contract
    @dev this contract can only receive funds from FUNDING_SOURCE address or CONTRACT_DAO (when proposal is created)
    */
    function () external payable {
        require(
            (msg.sender == FUNDING_SOURCE) ||
            (msg.sender == get_contract(CONTRACT_DAO))
        );
    }
}