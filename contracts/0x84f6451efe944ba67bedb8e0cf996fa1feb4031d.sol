pragma solidity 0.5.7;
contract DCN {
  event UserCreated(address indexed creator, uint64 user_id);
  event UserTradeAddressUpdated(uint64 user_id);
  event SessionUpdated(uint64 user_id, uint64 exchange_id);
  event ExchangeDeposit(uint64 user_id, uint64 exchange_id, uint32 asset_id);
  uint256 creator;
  uint256 creator_recovery;
  uint256 creator_recovery_proposed;
  uint256 user_count;
  uint256 exchange_count;
  uint256 asset_count;
  uint256 security_locked_features;
  uint256 security_locked_features_proposed;
  uint256 security_proposed_unlock_timestamp;
  struct Exchange {
    uint88 name;
    uint8 locked;
    address owner;
    uint256 withdraw_address;
    uint256 recovery_address;
    uint256 recovery_address_proposed;
    uint256[4294967296] balances;
  }
  struct Asset {
    uint64 symbol;
    uint192 unit_scale;
    uint256 contract_address;
  }
  struct MarketState {
    int64 quote_qty;
    int64 base_qty;
    uint64 fee_used;
    uint64 fee_limit;
    int64 min_quote_qty;
    int64 min_base_qty;
    uint64 long_max_price;
    uint64 short_min_price;
    uint64 limit_version;
    int96 quote_shift;
    int96 base_shift;
  }
  struct SessionBalance {
    uint128 total_deposit;
    uint64 unsettled_withdraw_total;
    uint64 asset_balance;
  }
  struct ExchangeSession {
    uint256 unlock_at;
    uint256 trade_address;
    SessionBalance[4294967296] balances;
    MarketState[18446744073709551616] market_states;
  }
  struct User {
    uint256 trade_address;
    uint256 withdraw_address;
    uint256 recovery_address;
    uint256 recovery_address_proposed;
    uint256[4294967296] balances;
    ExchangeSession[4294967296] exchange_sessions;
  }
  User[18446744073709551616] users;
  Asset[4294967296] assets;
  Exchange[4294967296] exchanges;
  
  constructor() public  {
    assembly {
      sstore(creator_slot, caller)
      sstore(creator_recovery_slot, caller)
    }
  }
  
  function get_security_state() public view 
  returns (uint256 locked_features, uint256 locked_features_proposed, uint256 proposed_unlock_timestamp) {
    
    uint256[3] memory return_value_mem;
    assembly {
      mstore(return_value_mem, sload(security_locked_features_slot))
      mstore(add(return_value_mem, 32), sload(security_locked_features_proposed_slot))
      mstore(add(return_value_mem, 64), sload(security_proposed_unlock_timestamp_slot))
      return(return_value_mem, 96)
    }
  }
  
  function get_creator() public view 
  returns (address dcn_creator, address dcn_creator_recovery, address dcn_creator_recovery_proposed) {
    
    uint256[3] memory return_value_mem;
    assembly {
      mstore(return_value_mem, sload(creator_slot))
      mstore(add(return_value_mem, 32), sload(creator_recovery_slot))
      mstore(add(return_value_mem, 64), sload(creator_recovery_proposed_slot))
      return(return_value_mem, 96)
    }
  }
  
  function get_asset(uint32 asset_id) public view 
  returns (string memory symbol, uint192 unit_scale, address contract_address) {
    
    uint256[5] memory return_value_mem;
    assembly {
      let asset_count := sload(asset_count_slot)
      if iszero(lt(asset_id, asset_count)) {
        mstore(32, 1)
        revert(63, 1)
      }
      let asset_ptr := add(assets_slot, mul(2, asset_id))
      let asset_0 := sload(asset_ptr)
      let asset_1 := sload(add(asset_ptr, 1))
      mstore(return_value_mem, 96)
      mstore(add(return_value_mem, 96), 8)
      mstore(add(return_value_mem, 128), asset_0)
      mstore(add(return_value_mem, 32), and(asset_0, 0xffffffffffffffffffffffffffffffffffffffffffffffff))
      mstore(add(return_value_mem, 64), asset_1)
      return(return_value_mem, 136)
    }
  }
  
  function get_exchange(uint32 exchange_id) public view 
  returns (
    string memory name, bool locked, address owner,
    address withdraw_address, address recovery_address, address recovery_address_proposed
  ) {
    
    uint256[8] memory return_value_mem;
    assembly {
      let exchange_count := sload(exchange_count_slot)
      if iszero(lt(exchange_id, exchange_count)) {
        mstore(32, 1)
        revert(63, 1)
      }
      let exchange_ptr := add(exchanges_slot, mul(4294967300, exchange_id))
      let exchange_0 := sload(exchange_ptr)
      let exchange_1 := sload(add(exchange_ptr, 1))
      let exchange_2 := sload(add(exchange_ptr, 2))
      let exchange_3 := sload(add(exchange_ptr, 3))
      mstore(return_value_mem, 192)
      mstore(add(return_value_mem, 192), 11)
      mstore(add(return_value_mem, 224), exchange_0)
      mstore(add(return_value_mem, 32), and(div(exchange_0, 0x10000000000000000000000000000000000000000), 0xff))
      mstore(add(return_value_mem, 64), and(exchange_0, 0xffffffffffffffffffffffffffffffffffffffff))
      mstore(add(return_value_mem, 96), exchange_1)
      mstore(add(return_value_mem, 128), exchange_2)
      mstore(add(return_value_mem, 160), exchange_3)
      return(return_value_mem, 236)
    }
  }
  
  function get_exchange_balance(uint32 exchange_id, uint32 asset_id) public view 
  returns (uint256 exchange_balance) {
    
    uint256[1] memory return_value_mem;
    assembly {
      let exchange_ptr := add(exchanges_slot, mul(4294967300, exchange_id))
      let exchange_balance_ptr := add(add(exchange_ptr, 4), asset_id)
      mstore(return_value_mem, sload(exchange_balance_ptr))
      return(return_value_mem, 32)
    }
  }
  
  function get_exchange_count() public view 
  returns (uint32 count) {
    
    uint256[1] memory return_value_mem;
    assembly {
      mstore(return_value_mem, sload(exchange_count_slot))
      return(return_value_mem, 32)
    }
  }
  
  function get_asset_count() public view 
  returns (uint32 count) {
    
    uint256[1] memory return_value_mem;
    assembly {
      mstore(return_value_mem, sload(asset_count_slot))
      return(return_value_mem, 32)
    }
  }
  
  function get_user_count() public view 
  returns (uint32 count) {
    
    uint256[1] memory return_value_mem;
    assembly {
      mstore(return_value_mem, sload(user_count_slot))
      return(return_value_mem, 32)
    }
  }
  
  function get_user(uint64 user_id) public view 
  returns (
    address trade_address,
    address withdraw_address, address recovery_address, address recovery_address_proposed
  ) {
    
    uint256[4] memory return_value_mem;
    assembly {
      let user_count := sload(user_count_slot)
      if iszero(lt(user_id, user_count)) {
        mstore(32, 1)
        revert(63, 1)
      }
      let user_ptr := add(users_slot, mul(237684487561239756867226304516, user_id))
      mstore(return_value_mem, sload(add(user_ptr, 0)))
      mstore(add(return_value_mem, 32), sload(add(user_ptr, 1)))
      mstore(add(return_value_mem, 64), sload(add(user_ptr, 2)))
      mstore(add(return_value_mem, 96), sload(add(user_ptr, 3)))
      return(return_value_mem, 128)
    }
  }
  
  function get_balance(uint64 user_id, uint32 asset_id) public view 
  returns (uint256 return_balance) {
    
    uint256[1] memory return_value_mem;
    assembly {
      let user_ptr := add(users_slot, mul(237684487561239756867226304516, user_id))
      let user_balance_ptr := add(add(user_ptr, 4), asset_id)
      mstore(return_value_mem, sload(user_balance_ptr))
      return(return_value_mem, 32)
    }
  }
  
  function get_session(uint64 user_id, uint32 exchange_id) public view 
  returns (uint256 unlock_at, address trade_address) {
    
    uint256[2] memory return_value_mem;
    assembly {
      let user_ptr := add(users_slot, mul(237684487561239756867226304516, user_id))
      let session_ptr := add(add(user_ptr, 4294967300), mul(55340232225423622146, exchange_id))
      mstore(return_value_mem, sload(add(session_ptr, 0)))
      mstore(add(return_value_mem, 32), sload(add(session_ptr, 1)))
      return(return_value_mem, 64)
    }
  }
  
  function get_session_balance(uint64 user_id, uint32 exchange_id, uint32 asset_id) public view 
  returns (uint128 total_deposit, uint64 unsettled_withdraw_total, uint64 asset_balance) {
    
    uint256[3] memory return_value_mem;
    assembly {
      let user_ptr := add(users_slot, mul(237684487561239756867226304516, user_id))
      let session_ptr := add(add(user_ptr, 4294967300), mul(55340232225423622146, exchange_id))
      let session_balance_ptr := add(add(session_ptr, 2), asset_id)
      let session_balance_0 := sload(session_balance_ptr)
      mstore(return_value_mem, and(div(session_balance_0, 0x100000000000000000000000000000000), 0xffffffffffffffffffffffffffffffff))
      mstore(add(return_value_mem, 32), and(div(session_balance_0, 0x10000000000000000), 0xffffffffffffffff))
      mstore(add(return_value_mem, 64), and(session_balance_0, 0xffffffffffffffff))
      return(return_value_mem, 96)
    }
  }
  
  function get_market_state(
    uint64 user_id, uint32 exchange_id,
    uint32 quote_asset_id, uint32 base_asset_id
  ) public view 
  returns (
    int64 quote_qty, int64 base_qty, uint64 fee_used, uint64 fee_limit,
    int64 min_quote_qty, int64 min_base_qty, uint64 long_max_price, uint64 short_min_price,
    uint64 limit_version, int96 quote_shift, int96 base_shift
  ) {
    
    uint256[11] memory return_value_mem;
    assembly {
      base_shift := base_asset_id
      quote_shift := quote_asset_id
      let user_ptr := add(users_slot, mul(237684487561239756867226304516, user_id))
      let exchange_session_ptr := add(add(user_ptr, 4294967300), mul(55340232225423622146, exchange_id))
      let exchange_state_ptr := add(add(exchange_session_ptr, 4294967298), mul(3, or(mul(quote_shift, 4294967296), base_shift)))
      let state_data_0 := sload(exchange_state_ptr)
      let state_data_1 := sload(add(exchange_state_ptr, 1))
      let state_data_2 := sload(add(exchange_state_ptr, 2))
      {
        let tmp := and(div(state_data_0, 0x1000000000000000000000000000000000000000000000000), 0xffffffffffffffff)
        tmp := signextend(7, tmp)
        mstore(add(return_value_mem, 0), tmp)
      }
      {
        let tmp := and(div(state_data_0, 0x100000000000000000000000000000000), 0xffffffffffffffff)
        tmp := signextend(7, tmp)
        mstore(add(return_value_mem, 32), tmp)
      }
      mstore(add(return_value_mem, 64), and(div(state_data_0, 0x10000000000000000), 0xffffffffffffffff))
      mstore(add(return_value_mem, 96), and(state_data_0, 0xffffffffffffffff))
      {
        let tmp := and(div(state_data_1, 0x1000000000000000000000000000000000000000000000000), 0xffffffffffffffff)
        tmp := signextend(7, tmp)
        mstore(add(return_value_mem, 128), tmp)
      }
      {
        let tmp := and(div(state_data_1, 0x100000000000000000000000000000000), 0xffffffffffffffff)
        tmp := signextend(7, tmp)
        mstore(add(return_value_mem, 160), tmp)
      }
      mstore(add(return_value_mem, 192), and(div(state_data_1, 0x10000000000000000), 0xffffffffffffffff))
      mstore(add(return_value_mem, 224), and(state_data_1, 0xffffffffffffffff))
      mstore(add(return_value_mem, 256), and(div(state_data_2, 0x1000000000000000000000000000000000000000000000000), 0xffffffffffffffff))
      {
        let tmp := and(div(state_data_2, 0x1000000000000000000000000), 0xffffffffffffffffffffffff)
        tmp := signextend(11, tmp)
        mstore(add(return_value_mem, 288), tmp)
      }
      {
        let tmp := and(state_data_2, 0xffffffffffffffffffffffff)
        tmp := signextend(11, tmp)
        mstore(add(return_value_mem, 320), tmp)
      }
      return(return_value_mem, 352)
    }
  }
  
  function security_lock(uint256 lock_features) public  {
    assembly {
      {
        let creator := sload(creator_slot)
        if iszero(eq(caller, creator)) {
          mstore(32, 1)
          revert(63, 1)
        }
      }
      let locked_features := sload(security_locked_features_slot)
      sstore(security_locked_features_slot, or(locked_features, lock_features))
      sstore(security_locked_features_proposed_slot, 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF)
    }
  }
  
  function security_propose(uint256 proposed_locked_features) public  {
    assembly {
      {
        let creator := sload(creator_slot)
        if iszero(eq(caller, creator)) {
          mstore(32, 1)
          revert(63, 1)
        }
      }
      let current_proposal := sload(security_locked_features_proposed_slot)
      let proposed_differences := xor(current_proposal, proposed_locked_features)
      let does_unlocks_features := and(proposed_differences, not(proposed_locked_features))
      if does_unlocks_features {
        sstore(security_proposed_unlock_timestamp_slot, add(timestamp, 172800))
      }
      sstore(security_locked_features_proposed_slot, proposed_locked_features)
    }
  }
  
  function security_set_proposed() public  {
    assembly {
      {
        let creator := sload(creator_slot)
        if iszero(eq(caller, creator)) {
          mstore(32, 1)
          revert(63, 1)
        }
      }
      let unlock_timestamp := sload(security_proposed_unlock_timestamp_slot)
      if gt(unlock_timestamp, timestamp) {
        mstore(32, 2)
        revert(63, 1)
      }
      sstore(security_locked_features_slot, sload(security_locked_features_proposed_slot))
    }
  }
  
  function creator_update(address new_creator) public  {
    assembly {
      let creator_recovery := sload(creator_recovery_slot)
      if iszero(eq(caller, creator_recovery)) {
        mstore(32, 1)
        revert(63, 1)
      }
      sstore(creator_slot, new_creator)
    }
  }
  
  function creator_propose_recovery(address recovery) public  {
    assembly {
      let creator_recovery := sload(creator_recovery_slot)
      if iszero(eq(caller, creator_recovery)) {
        mstore(32, 1)
        revert(63, 1)
      }
      sstore(creator_recovery_proposed_slot, recovery)
    }
  }
  
  function creator_set_recovery() public  {
    assembly {
      let creator_recovery_proposed := sload(creator_recovery_proposed_slot)
      if or(iszero(eq(caller, creator_recovery_proposed)), iszero(caller)) {
        mstore(32, 1)
        revert(63, 1)
      }
      sstore(creator_recovery_slot, caller)
      sstore(creator_recovery_proposed_slot, 0)
    }
  }
  
  function set_exchange_locked(uint32 exchange_id, bool locked) public  {
    assembly {
      {
        let creator := sload(creator_slot)
        if iszero(eq(caller, creator)) {
          mstore(32, 1)
          revert(63, 1)
        }
      }
      {
        let exchange_count := sload(exchange_count_slot)
        if iszero(lt(exchange_id, exchange_count)) {
          mstore(32, 2)
          revert(63, 1)
        }
      }
      let exchange_ptr := add(exchanges_slot, mul(4294967300, exchange_id))
      let exchange_0 := sload(exchange_ptr)
      sstore(exchange_ptr, or(and(0xffffffffffffffffffffff00ffffffffffffffffffffffffffffffffffffffff, exchange_0), 
        /* locked */ mul(locked, 0x10000000000000000000000000000000000000000)))
    }
  }
  
  function user_create() public 
  returns (uint64 user_id) {
    
    uint256[2] memory log_data_mem;
    assembly {
      {
        let locked_features := sload(security_locked_features_slot)
        if and(locked_features, 0x4) {
          mstore(32, 0)
          revert(63, 1)
        }
      }
      user_id := sload(user_count_slot)
      if iszero(lt(user_id, 18446744073709551616)) {
        mstore(32, 1)
        revert(63, 1)
      }
      sstore(user_count_slot, add(user_id, 1))
      let user_ptr := add(users_slot, mul(237684487561239756867226304516, user_id))
      sstore(add(user_ptr, 0), caller)
      sstore(add(user_ptr, 1), caller)
      sstore(add(user_ptr, 2), caller)
      
      /* Log event: UserCreated */
      mstore(log_data_mem, user_id)
      log2(log_data_mem, 32, /* UserCreated */ 0x49d7af0c8ce0d26f4490c17a316a59a7a5d28599a2208862554b648ebdf193f4, caller)
    }
  }
  
  function user_set_trade_address(uint64 user_id, address trade_address) public  {
    
    uint256[1] memory log_data_mem;
    assembly {
      let user_ptr := add(users_slot, mul(237684487561239756867226304516, user_id))
      let recovery_address := sload(add(user_ptr, 2))
      if iszero(eq(caller, recovery_address)) {
        mstore(32, 1)
        revert(63, 1)
      }
      sstore(add(user_ptr, 0), trade_address)
      
      /* Log event: UserTradeAddressUpdated */
      mstore(log_data_mem, user_id)
      log1(log_data_mem, 32, /* UserTradeAddressUpdated */ 0x0dcac7e45506b3812319ae528c780b9035570ee3b3557272431dce5b397d880a)
    }
  }
  
  function user_set_withdraw_address(uint64 user_id, address withdraw_address) public  {
    assembly {
      let user_ptr := add(users_slot, mul(237684487561239756867226304516, user_id))
      let recovery_address := sload(add(user_ptr, 2))
      if iszero(eq(caller, recovery_address)) {
        mstore(32, 1)
        revert(63, 1)
      }
      sstore(add(user_ptr, 1), withdraw_address)
    }
  }
  
  function user_propose_recovery_address(uint64 user_id, address proposed) public  {
    assembly {
      let user_ptr := add(users_slot, mul(237684487561239756867226304516, user_id))
      let recovery_address := sload(add(user_ptr, 2))
      if iszero(eq(caller, recovery_address)) {
        mstore(32, 1)
        revert(63, 1)
      }
      sstore(add(user_ptr, 3), proposed)
    }
  }
  
  function user_set_recovery_address(uint64 user_id) public  {
    assembly {
      let user_ptr := add(users_slot, mul(237684487561239756867226304516, user_id))
      let proposed_ptr := add(user_ptr, 3)
      let recovery_address_proposed := sload(proposed_ptr)
      if iszero(eq(caller, recovery_address_proposed)) {
        mstore(32, 1)
        revert(63, 1)
      }
      sstore(proposed_ptr, 0)
      sstore(add(user_ptr, 2), recovery_address_proposed)
    }
  }
  
  function exchange_set_owner(uint32 exchange_id, address new_owner) public  {
    assembly {
      let exchange_ptr := add(exchanges_slot, mul(4294967300, exchange_id))
      let exchange_recovery := sload(add(exchange_ptr, 2))
      if iszero(eq(caller, exchange_recovery)) {
        mstore(32, 1)
        revert(63, 1)
      }
      let exchange_0 := sload(exchange_ptr)
      sstore(exchange_ptr, or(and(exchange_0, 0xffffffffffffffffffffffff0000000000000000000000000000000000000000), 
        /* owner */ new_owner))
    }
  }
  
  function exchange_set_withdraw(uint32 exchange_id, address new_withdraw) public  {
    assembly {
      let exchange_ptr := add(exchanges_slot, mul(4294967300, exchange_id))
      let exchange_recovery := sload(add(exchange_ptr, 2))
      if iszero(eq(caller, exchange_recovery)) {
        mstore(32, 1)
        revert(63, 1)
      }
      sstore(add(exchange_ptr, 1), new_withdraw)
    }
  }
  
  function exchange_propose_recovery(uint32 exchange_id, address proposed) public  {
    assembly {
      let exchange_ptr := add(exchanges_slot, mul(4294967300, exchange_id))
      let exchange_recovery := sload(add(exchange_ptr, 2))
      if iszero(eq(caller, exchange_recovery)) {
        mstore(32, 1)
        revert(63, 1)
      }
      sstore(add(exchange_ptr, 3), proposed)
    }
  }
  
  function exchange_set_recovery(uint32 exchange_id) public  {
    assembly {
      let exchange_ptr := add(exchanges_slot, mul(4294967300, exchange_id))
      let exchange_recovery_proposed := sload(add(exchange_ptr, 3))
      if or(iszero(eq(caller, exchange_recovery_proposed)), iszero(caller)) {
        mstore(32, 1)
        revert(63, 1)
      }
      sstore(add(exchange_ptr, 2), caller)
    }
  }
  
  function add_asset(string memory symbol, uint192 unit_scale, address contract_address) public 
  returns (uint64 asset_id) {
    assembly {
      {
        let locked_features := sload(security_locked_features_slot)
        if and(locked_features, 0x1) {
          mstore(32, 0)
          revert(63, 1)
        }
      }
      {
        let creator := sload(creator_slot)
        if iszero(eq(caller, creator)) {
          mstore(32, 1)
          revert(63, 1)
        }
      }
      asset_id := sload(asset_count_slot)
      if iszero(lt(asset_id, 4294967296)) {
        mstore(32, 2)
        revert(63, 1)
      }
      let symbol_len := mload(symbol)
      if iszero(eq(symbol_len, 8)) {
        mstore(32, 3)
        revert(63, 1)
      }
      if iszero(unit_scale) {
        mstore(32, 4)
        revert(63, 1)
      }
      if iszero(contract_address) {
        mstore(32, 5)
        revert(63, 1)
      }
      let asset_symbol := mload(add(symbol, 32))
      let asset_data_0 := or(asset_symbol, 
        /* unit_scale */ unit_scale)
      let asset_ptr := add(assets_slot, mul(2, asset_id))
      sstore(asset_ptr, asset_data_0)
      sstore(add(asset_ptr, 1), contract_address)
      sstore(asset_count_slot, add(asset_id, 1))
    }
  }
  
  function add_exchange(string memory name, address addr) public 
  returns (uint64 exchange_id) {
    assembly {
      {
        let locked_features := sload(security_locked_features_slot)
        if and(locked_features, 0x2) {
          mstore(32, 0)
          revert(63, 1)
        }
      }
      {
        let creator := sload(creator_slot)
        if iszero(eq(caller, creator)) {
          mstore(32, 1)
          revert(63, 1)
        }
      }
      let name_len := mload(name)
      if iszero(eq(name_len, 11)) {
        mstore(32, 2)
        revert(63, 1)
      }
      exchange_id := sload(exchange_count_slot)
      if iszero(lt(exchange_id, 4294967296)) {
        mstore(32, 3)
        revert(63, 1)
      }
      let exchange_ptr := add(exchanges_slot, mul(4294967300, exchange_id))
      let name_data := mload(add(name, 32))
      let exchange_0 := or(name_data, 
        /* owner */ addr)
      sstore(exchange_ptr, exchange_0)
      sstore(add(exchange_ptr, 1), addr)
      sstore(add(exchange_ptr, 2), addr)
      sstore(exchange_count_slot, add(exchange_id, 1))
    }
  }
  
  function exchange_withdraw(uint32 exchange_id, uint32 asset_id,
                             address destination, uint64 quantity) public  {
    
    uint256[3] memory transfer_in_mem;
    
    uint256[1] memory transfer_out_mem;
    assembly {
      let exchange_ptr := add(exchanges_slot, mul(4294967300, exchange_id))
      let withdraw_address := sload(add(exchange_ptr, 1))
      if iszero(eq(caller, withdraw_address)) {
        mstore(32, 1)
        revert(63, 1)
      }
      let exchange_balance_ptr := add(add(exchange_ptr, 4), asset_id)
      let exchange_balance := sload(exchange_balance_ptr)
      if gt(quantity, exchange_balance) {
        mstore(32, 2)
        revert(63, 1)
      }
      sstore(exchange_balance_ptr, sub(exchange_balance, quantity))
      let asset_ptr := add(assets_slot, mul(2, asset_id))
      let unit_scale := and(sload(asset_ptr), 0xffffffffffffffffffffffffffffffffffffffffffffffff)
      let asset_address := sload(add(asset_ptr, 1))
      let withdraw := mul(quantity, unit_scale)
      mstore(transfer_in_mem, /* fn_hash("transfer(address,uint256)") */ 0xa9059cbb00000000000000000000000000000000000000000000000000000000)
      mstore(add(transfer_in_mem, 4), destination)
      mstore(add(transfer_in_mem, 36), withdraw)
      {
        let success := call(gas, asset_address, 0, transfer_in_mem, 68, transfer_out_mem, 32)
        if iszero(success) {
          mstore(32, 3)
          revert(63, 1)
        }
        switch returndatasize
          case 0 {}
          case 32 {
            let result := mload(transfer_out_mem)
            if iszero(result) {
              mstore(32, 4)
              revert(63, 1)
            }
          }
          default {
            mstore(32, 4)
            revert(63, 1)
          }
      }
    }
  }
  
  function exchange_deposit(uint32 exchange_id, uint32 asset_id, uint64 quantity) public  {
    
    uint256[3] memory transfer_in_mem;
    
    uint256[1] memory transfer_out_mem;
    assembly {
      {
        let locked_features := sload(security_locked_features_slot)
        if and(locked_features, 0x8) {
          mstore(32, 0)
          revert(63, 1)
        }
      }
      {
        let exchange_count := sload(exchange_count_slot)
        if iszero(lt(exchange_id, exchange_count)) {
          mstore(32, 1)
          revert(63, 1)
        }
      }
      {
        let asset_count := sload(asset_count_slot)
        if iszero(lt(asset_id, asset_count)) {
          mstore(32, 2)
          revert(63, 1)
        }
      }
      let exchange_balance_ptr := add(add(add(exchanges_slot, mul(4294967300, exchange_id)), 4), asset_id)
      let exchange_balance := sload(exchange_balance_ptr)
      let updated_balance := add(exchange_balance, quantity)
      if gt(updated_balance, 0xFFFFFFFFFFFFFFFF) {
        mstore(32, 3)
        revert(63, 1)
      }
      let asset_ptr := add(assets_slot, mul(2, asset_id))
      let unit_scale := and(sload(asset_ptr), 0xffffffffffffffffffffffffffffffffffffffffffffffff)
      let asset_address := sload(add(asset_ptr, 1))
      let deposit := mul(quantity, unit_scale)
      sstore(exchange_balance_ptr, updated_balance)
      mstore(transfer_in_mem, /* fn_hash("transferFrom(address,address,uint256)") */ 0x23b872dd00000000000000000000000000000000000000000000000000000000)
      mstore(add(transfer_in_mem, 4), caller)
      mstore(add(transfer_in_mem, 36), address)
      mstore(add(transfer_in_mem, 68), deposit)
      {
        let success := call(gas, asset_address, 0, transfer_in_mem, 100, transfer_out_mem, 32)
        if iszero(success) {
          mstore(32, 4)
          revert(63, 1)
        }
        switch returndatasize
          case 0 {}
          case 32 {
            let result := mload(transfer_out_mem)
            if iszero(result) {
              mstore(32, 5)
              revert(63, 1)
            }
          }
          default {
            mstore(32, 5)
            revert(63, 1)
          }
      }
    }
  }
  
  function user_deposit(uint64 user_id, uint32 asset_id, uint256 amount) public  {
    
    uint256[4] memory transfer_in_mem;
    
    uint256[1] memory transfer_out_mem;
    assembly {
      {
        let locked_features := sload(security_locked_features_slot)
        if and(locked_features, 0x10) {
          mstore(32, 0)
          revert(63, 1)
        }
      }
      {
        let user_count := sload(user_count_slot)
        if iszero(lt(user_id, user_count)) {
          mstore(32, 1)
          revert(63, 1)
        }
      }
      {
        let asset_count := sload(asset_count_slot)
        if iszero(lt(asset_id, asset_count)) {
          mstore(32, 2)
          revert(63, 1)
        }
      }
      if iszero(amount) {
        stop()
      }
      let balance_ptr := add(add(add(users_slot, mul(237684487561239756867226304516, user_id)), 4), asset_id)
      let current_balance := sload(balance_ptr)
      let proposed_balance := add(current_balance, amount)
      if lt(proposed_balance, current_balance) {
        mstore(32, 3)
        revert(63, 1)
      }
      let asset_address := sload(add(add(assets_slot, mul(2, asset_id)), 1))
      sstore(balance_ptr, proposed_balance)
      mstore(transfer_in_mem, /* fn_hash("transferFrom(address,address,uint256)") */ 0x23b872dd00000000000000000000000000000000000000000000000000000000)
      mstore(add(transfer_in_mem, 4), caller)
      mstore(add(transfer_in_mem, 36), address)
      mstore(add(transfer_in_mem, 68), amount)
      {
        let success := call(gas, asset_address, 0, transfer_in_mem, 100, transfer_out_mem, 32)
        if iszero(success) {
          mstore(32, 4)
          revert(63, 1)
        }
        switch returndatasize
          case 0 {}
          case 32 {
            let result := mload(transfer_out_mem)
            if iszero(result) {
              mstore(32, 5)
              revert(63, 1)
            }
          }
          default {
            mstore(32, 5)
            revert(63, 1)
          }
      }
    }
  }
  
  function user_withdraw(uint64 user_id, uint32 asset_id, address destination, uint256 amount) public  {
    
    uint256[3] memory transfer_in_mem;
    
    uint256[1] memory transfer_out_mem;
    assembly {
      if iszero(amount) {
        stop()
      }
      {
        let user_count := sload(user_count_slot)
        if iszero(lt(user_id, user_count)) {
          mstore(32, 6)
          revert(63, 1)
        }
      }
      {
        let asset_count := sload(asset_count_slot)
        if iszero(lt(asset_id, asset_count)) {
          mstore(32, 1)
          revert(63, 1)
        }
      }
      let user_ptr := add(users_slot, mul(237684487561239756867226304516, user_id))
      let withdraw_address := sload(add(user_ptr, 1))
      if iszero(eq(caller, withdraw_address)) {
        mstore(32, 2)
        revert(63, 1)
      }
      let balance_ptr := add(add(user_ptr, 4), asset_id)
      let current_balance := sload(balance_ptr)
      if lt(current_balance, amount) {
        mstore(32, 3)
        revert(63, 1)
      }
      sstore(balance_ptr, sub(current_balance, amount))
      let asset_address := sload(add(add(assets_slot, mul(2, asset_id)), 1))
      mstore(transfer_in_mem, /* fn_hash("transfer(address,uint256)") */ 0xa9059cbb00000000000000000000000000000000000000000000000000000000)
      mstore(add(transfer_in_mem, 4), destination)
      mstore(add(transfer_in_mem, 36), amount)
      {
        let success := call(gas, asset_address, 0, transfer_in_mem, 68, transfer_out_mem, 32)
        if iszero(success) {
          mstore(32, 4)
          revert(63, 1)
        }
        switch returndatasize
          case 0 {}
          case 32 {
            let result := mload(transfer_out_mem)
            if iszero(result) {
              mstore(32, 5)
              revert(63, 1)
            }
          }
          default {
            mstore(32, 5)
            revert(63, 1)
          }
      }
    }
  }
  
  function user_session_set_unlock_at(uint64 user_id, uint32 exchange_id, uint256 unlock_at) public  {
    
    uint256[3] memory log_data_mem;
    assembly {
      {
        let exchange_count := sload(exchange_count_slot)
        if iszero(lt(exchange_id, exchange_count)) {
          mstore(32, 1)
          revert(63, 1)
        }
      }
      let user_ptr := add(users_slot, mul(237684487561239756867226304516, user_id))
      let trade_address := sload(add(user_ptr, 0))
      if iszero(eq(caller, trade_address)) {
        mstore(32, 2)
        revert(63, 1)
      }
      {
        let fails_min_time := lt(unlock_at, add(timestamp, 28800))
        let fails_max_time := gt(unlock_at, add(timestamp, 1209600))
        if or(fails_min_time, fails_max_time) {
          mstore(32, 3)
          revert(63, 1)
        }
      }
      let session_ptr := add(add(user_ptr, 4294967300), mul(55340232225423622146, exchange_id))
      let unlock_at_ptr := add(session_ptr, 0)
      if lt(sload(unlock_at_ptr), timestamp) {
        sstore(add(session_ptr, 1), caller)
      }
      sstore(unlock_at_ptr, unlock_at)
      
      /* Log event: SessionUpdated */
      mstore(log_data_mem, user_id)
      mstore(add(log_data_mem, 32), exchange_id)
      log1(log_data_mem, 64, /* SessionUpdated */ 0x1b0c381a98d9352dd527280acefa9a69d2c111b6a9d3aa3063aac6c2ec7f3163)
    }
  }
  
  function user_market_reset(uint64 user_id, uint32 exchange_id,
                             uint32 quote_asset_id, uint32 base_asset_id) public  {
    assembly {
      {
        let locked_features := sload(security_locked_features_slot)
        if and(locked_features, 0x400) {
          mstore(32, 0)
          revert(63, 1)
        }
      }
      {
        let exchange_count := sload(exchange_count_slot)
        if iszero(lt(exchange_id, exchange_count)) {
          mstore(32, 1)
          revert(63, 1)
        }
      }
      let user_ptr := add(users_slot, mul(237684487561239756867226304516, user_id))
      let trade_address := sload(add(user_ptr, 0))
      if iszero(eq(caller, trade_address)) {
        mstore(32, 2)
        revert(63, 1)
      }
      let session_ptr := add(add(user_ptr, 4294967300), mul(55340232225423622146, exchange_id))
      let unlock_at := sload(add(session_ptr, 0))
      if gt(unlock_at, timestamp) {
        mstore(32, 3)
        revert(63, 1)
      }
      let market_state_ptr := add(add(session_ptr, 4294967298), mul(3, or(mul(quote_asset_id, 4294967296), base_asset_id)))
      sstore(market_state_ptr, 0)
      sstore(add(market_state_ptr, 1), 0)
      let market_state_2_ptr := add(market_state_ptr, 2)
      let market_state_2 := sload(market_state_2_ptr)
      let limit_version := add(and(div(market_state_2, 0x1000000000000000000000000000000000000000000000000), 0xffffffffffffffff), 1)
      sstore(market_state_2_ptr, 
        /* limit_version */ mul(limit_version, 0x1000000000000000000000000000000000000000000000000))
    }
  }
  
  function transfer_to_session(uint64 user_id, uint32 exchange_id, uint32 asset_id, uint64 quantity) public  {
    
    uint256[4] memory log_data_mem;
    assembly {
      {
        let locked_features := sload(security_locked_features_slot)
        if and(locked_features, 0x20) {
          mstore(32, 0)
          revert(63, 1)
        }
      }
      {
        let exchange_count := sload(exchange_count_slot)
        if iszero(lt(exchange_id, exchange_count)) {
          mstore(32, 1)
          revert(63, 1)
        }
      }
      {
        let asset_count := sload(asset_count_slot)
        if iszero(lt(asset_id, asset_count)) {
          mstore(32, 2)
          revert(63, 1)
        }
      }
      if iszero(quantity) {
        stop()
      }
      let asset_ptr := add(assets_slot, mul(2, asset_id))
      let unit_scale := and(sload(asset_ptr), 0xffffffffffffffffffffffffffffffffffffffffffffffff)
      let scaled_quantity := mul(quantity, unit_scale)
      let user_ptr := add(users_slot, mul(237684487561239756867226304516, user_id))
      {
        let withdraw_address := sload(add(user_ptr, 1))
        if iszero(eq(caller, withdraw_address)) {
          mstore(32, 3)
          revert(63, 1)
        }
      }
      let user_balance_ptr := add(add(user_ptr, 4), asset_id)
      let user_balance := sload(user_balance_ptr)
      if lt(user_balance, scaled_quantity) {
        mstore(32, 4)
        revert(63, 1)
      }
      let session_balance_ptr := add(add(add(add(user_ptr, 4294967300), mul(55340232225423622146, exchange_id)), 2), asset_id)
      let session_balance_0 := sload(session_balance_ptr)
      let updated_exchange_balance := add(and(session_balance_0, 0xffffffffffffffff), quantity)
      if gt(updated_exchange_balance, 0xFFFFFFFFFFFFFFFF) {
        mstore(32, 5)
        revert(63, 1)
      }
      let updated_total_deposit := add(and(div(session_balance_0, 0x100000000000000000000000000000000), 0xffffffffffffffffffffffffffffffff), quantity)
      sstore(user_balance_ptr, sub(user_balance, scaled_quantity))
      sstore(session_balance_ptr, or(and(0xffffffffffffffff0000000000000000, session_balance_0), or(
        /* total_deposit */ mul(updated_total_deposit, 0x100000000000000000000000000000000), 
        /* asset_balance */ updated_exchange_balance)))
      
      /* Log event: ExchangeDeposit */
      mstore(log_data_mem, user_id)
      mstore(add(log_data_mem, 32), exchange_id)
      mstore(add(log_data_mem, 64), asset_id)
      log1(log_data_mem, 96, /* ExchangeDeposit */ 0x7a2923ebfa019dc20de0ae2be0c8639b07e068b143e98ed7f7a74dc4d4f5ab45)
    }
  }
  
  function transfer_from_session(uint64 user_id, uint32 exchange_id, uint32 asset_id, uint64 quantity) public  {
    
    uint256[4] memory log_data_mem;
    assembly {
      if iszero(quantity) {
        stop()
      }
      {
        let exchange_count := sload(exchange_count_slot)
        if iszero(lt(exchange_id, exchange_count)) {
          mstore(32, 1)
          revert(63, 1)
        }
      }
      {
        let asset_count := sload(asset_count_slot)
        if iszero(lt(asset_id, asset_count)) {
          mstore(32, 2)
          revert(63, 1)
        }
      }
      let user_ptr := add(users_slot, mul(237684487561239756867226304516, user_id))
      {
        let trade_address := sload(add(user_ptr, 0))
        if iszero(eq(caller, trade_address)) {
          mstore(32, 3)
          revert(63, 1)
        }
      }
      let session_ptr := add(add(user_ptr, 4294967300), mul(55340232225423622146, exchange_id))
      {
        let session_0 := sload(session_ptr)
        let unlock_at := session_0
        if gt(unlock_at, timestamp) {
          mstore(32, 4)
          revert(63, 1)
        }
      }
      let session_balance_ptr := add(add(session_ptr, 2), asset_id)
      let session_balance_0 := sload(session_balance_ptr)
      let session_balance := and(session_balance_0, 0xffffffffffffffff)
      if gt(quantity, session_balance) {
        mstore(32, 5)
        revert(63, 1)
      }
      let updated_exchange_balance := sub(session_balance, quantity)
      let unsettled_withdraw_total := and(div(session_balance_0, 0x10000000000000000), 0xffffffffffffffff)
      if lt(updated_exchange_balance, unsettled_withdraw_total) {
        mstore(32, 6)
        revert(63, 1)
      }
      sstore(session_balance_ptr, or(and(0xffffffffffffffffffffffffffffffffffffffffffffffff0000000000000000, session_balance_0), 
        /* asset_balance */ updated_exchange_balance))
      let asset_ptr := add(assets_slot, mul(2, asset_id))
      let unit_scale := and(sload(asset_ptr), 0xffffffffffffffffffffffffffffffffffffffffffffffff)
      let scaled_quantity := mul(quantity, unit_scale)
      let user_balance_ptr := add(add(user_ptr, 4), asset_id)
      let user_balance := sload(user_balance_ptr)
      let updated_user_balance := add(user_balance, scaled_quantity)
      if lt(updated_user_balance, user_balance) {
        mstore(32, 7)
        revert(63, 1)
      }
      sstore(user_balance_ptr, updated_user_balance)
    }
  }
  
  function user_deposit_to_session(uint64 user_id, uint32 exchange_id, uint32 asset_id, uint64 quantity) public  {
    
    uint256[4] memory transfer_in_mem;
    
    uint256[1] memory transfer_out_mem;
    
    uint256[3] memory log_data_mem;
    assembly {
      {
        let locked_features := sload(security_locked_features_slot)
        if and(locked_features, 0x40) {
          mstore(32, 0)
          revert(63, 1)
        }
      }
      {
        let exchange_count := sload(exchange_count_slot)
        if iszero(lt(exchange_id, exchange_count)) {
          mstore(32, 1)
          revert(63, 1)
        }
      }
      {
        let asset_count := sload(asset_count_slot)
        if iszero(lt(asset_id, asset_count)) {
          mstore(32, 2)
          revert(63, 1)
        }
      }
      if iszero(quantity) {
        stop()
      }
      let session_balance_ptr := add(add(add(add(add(users_slot, mul(237684487561239756867226304516, user_id)), 4294967300), mul(55340232225423622146, exchange_id)), 2), asset_id)
      let session_balance_0 := sload(session_balance_ptr)
      let updated_exchange_balance := add(and(session_balance_0, 0xffffffffffffffff), quantity)
      if gt(updated_exchange_balance, 0xFFFFFFFFFFFFFFFF) {
        mstore(32, 3)
        revert(63, 1)
      }
      let asset_ptr := add(assets_slot, mul(2, asset_id))
      let unit_scale := and(sload(asset_ptr), 0xffffffffffffffffffffffffffffffffffffffffffffffff)
      let asset_address := sload(add(asset_ptr, 1))
      let scaled_quantity := mul(quantity, unit_scale)
      let updated_total_deposit := add(and(div(session_balance_0, 0x100000000000000000000000000000000), 0xffffffffffffffffffffffffffffffff), quantity)
      sstore(session_balance_ptr, or(and(0xffffffffffffffff0000000000000000, session_balance_0), or(
        /* total_deposit */ mul(updated_total_deposit, 0x100000000000000000000000000000000), 
        /* asset_balance */ updated_exchange_balance)))
      mstore(transfer_in_mem, /* fn_hash("transferFrom(address,address,uint256)") */ 0x23b872dd00000000000000000000000000000000000000000000000000000000)
      mstore(add(transfer_in_mem, 4), caller)
      mstore(add(transfer_in_mem, 36), address)
      mstore(add(transfer_in_mem, 68), scaled_quantity)
      {
        let success := call(gas, asset_address, 0, transfer_in_mem, 100, transfer_out_mem, 32)
        if iszero(success) {
          mstore(32, 4)
          revert(63, 1)
        }
        switch returndatasize
          case 0 {}
          case 32 {
            let result := mload(transfer_out_mem)
            if iszero(result) {
              mstore(32, 5)
              revert(63, 1)
            }
          }
          default {
            mstore(32, 5)
            revert(63, 1)
          }
      }
      
      /* Log event: ExchangeDeposit */
      mstore(log_data_mem, user_id)
      mstore(add(log_data_mem, 32), exchange_id)
      mstore(add(log_data_mem, 64), asset_id)
      log1(log_data_mem, 96, /* ExchangeDeposit */ 0x7a2923ebfa019dc20de0ae2be0c8639b07e068b143e98ed7f7a74dc4d4f5ab45)
    }
  }
  struct UnsettledWithdrawHeader {
    uint32 exchange_id;
    uint32 asset_id;
    uint32 user_count;
  }
  struct UnsettledWithdrawUser {
    uint64 user_id;
  }
  
  function recover_unsettled_withdraws(bytes memory data) public  {
    assembly {
      {
        let locked_features := sload(security_locked_features_slot)
        if and(locked_features, 0x800) {
          mstore(32, 0)
          revert(63, 1)
        }
      }
      let data_len := mload(data)
      let cursor := add(data, 32)
      let cursor_end := add(cursor, data_len)
      for {} lt(cursor, cursor_end) {} {
        let unsettled_withdraw_header_0 := mload(cursor)
        let exchange_id := and(div(unsettled_withdraw_header_0, 0x100000000000000000000000000000000000000000000000000000000), 0xffffffff)
        let asset_id := and(div(unsettled_withdraw_header_0, 0x1000000000000000000000000000000000000000000000000), 0xffffffff)
        let user_count := and(div(unsettled_withdraw_header_0, 0x10000000000000000000000000000000000000000), 0xffffffff)
        let group_end := add(cursor, add(12, mul(user_count, 8)))
        if gt(group_end, cursor_end) {
          mstore(32, 1)
          revert(63, 1)
        }
        let exchange_balance_ptr := add(add(add(exchanges_slot, mul(4294967300, exchange_id)), 4), asset_id)
        let exchange_balance := sload(exchange_balance_ptr)
        let start_exchange_balance := exchange_balance
        for {} lt(cursor, group_end) {
          cursor := add(cursor, 8)
        } {
          let user_id := and(div(mload(cursor), 0x1000000000000000000000000000000000000000000000000), 0xffffffffffffffff)
          let session_balance_ptr := add(add(add(add(add(users_slot, mul(237684487561239756867226304516, user_id)), 4294967300), mul(55340232225423622146, exchange_id)), 2), asset_id)
          let session_balance_0 := sload(session_balance_ptr)
          let asset_balance := and(session_balance_0, 0xffffffffffffffff)
          let unsettled_balance := and(div(session_balance_0, 0x10000000000000000), 0xffffffffffffffff)
          let to_recover := unsettled_balance
          if gt(to_recover, asset_balance) {
            to_recover := asset_balance
          }
          if to_recover {
            exchange_balance := add(exchange_balance, to_recover)
            asset_balance := sub(asset_balance, to_recover)
            unsettled_balance := sub(unsettled_balance, to_recover)
            if gt(start_exchange_balance, exchange_balance) {
              mstore(32, 2)
              revert(63, 1)
            }
            sstore(session_balance_ptr, or(and(0xffffffffffffffffffffffffffffffff00000000000000000000000000000000, session_balance_0), or(
              /* unsettled_withdraw_total */ mul(unsettled_balance, 0x10000000000000000), 
              /* asset_balance */ asset_balance)))
          }
        }
        sstore(exchange_balance_ptr, exchange_balance)
      }
    }
  }
  struct ExchangeTransfersHeader {
    uint32 exchange_id;
  }
  struct ExchangeTransferGroup {
    uint32 asset_id;
    uint8 allow_overdraft;
    uint8 transfer_count;
  }
  struct ExchangeTransfer {
    uint64 user_id;
    uint64 quantity;
  }
  
  function exchange_transfer_from(bytes memory data) public  {
    assembly {
      {
        let locked_features := sload(security_locked_features_slot)
        if and(locked_features, 0x80) {
          mstore(32, 0)
          revert(63, 1)
        }
      }
      let data_len := mload(data)
      let cursor := add(data, 32)
      let cursor_end := add(cursor, data_len)
      let header_0 := mload(cursor)
      cursor := add(cursor, 4)
      if gt(cursor, cursor_end) {
        mstore(32, 1)
        revert(63, 1)
      }
      let exchange_id := and(div(header_0, 0x100000000000000000000000000000000000000000000000000000000), 0xffffffff)
      {
        let exchange_count := sload(exchange_count_slot)
        if iszero(lt(exchange_id, exchange_count)) {
          mstore(32, 2)
          revert(63, 1)
        }
      }
      {
        let exchange_data := sload(add(exchanges_slot, mul(4294967300, exchange_id)))
        if iszero(eq(caller, and(exchange_data, 0xffffffffffffffffffffffffffffffffffffffff))) {
          mstore(32, 3)
          revert(63, 1)
        }
        if and(div(exchange_data, 0x10000000000000000000000000000000000000000), 0xff) {
          mstore(32, 4)
          revert(63, 1)
        }
      }
      let asset_count := sload(asset_count_slot)
      for {} lt(cursor, cursor_end) {} {
        let group_0 := mload(cursor)
        cursor := add(cursor, 6)
        if gt(cursor, cursor_end) {
          mstore(32, 5)
          revert(63, 1)
        }
        let asset_id := and(div(group_0, 0x100000000000000000000000000000000000000000000000000000000), 0xffffffff)
        if iszero(lt(asset_id, asset_count)) {
          mstore(32, 6)
          revert(63, 1)
        }
        let disallow_overdraft := iszero(and(div(group_0, 0x1000000000000000000000000000000000000000000000000000000), 0xff))
        let cursor_group_end := add(cursor, mul(and(div(group_0, 0x10000000000000000000000000000000000000000000000000000), 0xff), 16))
        if gt(cursor_group_end, cursor_end) {
          mstore(32, 7)
          revert(63, 1)
        }
        let exchange_balance_ptr := add(add(add(exchanges_slot, mul(4294967300, exchange_id)), 4), asset_id)
        let exchange_balance_remaining := sload(exchange_balance_ptr)
        let unit_scale := and(sload(add(assets_slot, mul(2, asset_id))), 0xffffffffffffffffffffffffffffffffffffffffffffffff)
        for {} lt(cursor, cursor_group_end) {
          cursor := add(cursor, 16)
        } {
          let transfer_0 := mload(cursor)
          let user_ptr := add(users_slot, mul(237684487561239756867226304516, and(div(transfer_0, 0x1000000000000000000000000000000000000000000000000), 0xffffffffffffffff)))
          let quantity := and(div(transfer_0, 0x100000000000000000000000000000000), 0xffffffffffffffff)
          let exchange_balance_used := 0
          let session_balance_ptr := add(add(add(add(user_ptr, 4294967300), mul(55340232225423622146, exchange_id)), 2), asset_id)
          let session_balance_0 := sload(session_balance_ptr)
          let session_balance := and(session_balance_0, 0xffffffffffffffff)
          let session_balance_updated := sub(session_balance, quantity)
          if gt(session_balance_updated, session_balance) {
            if disallow_overdraft {
              mstore(32, 8)
              revert(63, 1)
            }
            exchange_balance_used := sub(quantity, session_balance)
            session_balance_updated := 0
            if gt(exchange_balance_used, exchange_balance_remaining) {
              mstore(32, 9)
              revert(63, 1)
            }
            exchange_balance_remaining := sub(exchange_balance_remaining, exchange_balance_used)
          }
          let quantity_scaled := mul(quantity, unit_scale)
          let user_balance_ptr := add(add(user_ptr, 4), asset_id)
          let user_balance := sload(user_balance_ptr)
          let updated_user_balance := add(user_balance, quantity_scaled)
          if gt(user_balance, updated_user_balance) {
            mstore(32, 10)
            revert(63, 1)
          }
          let unsettled_withdraw_total_updated := add(and(div(session_balance_0, 0x10000000000000000), 0xffffffffffffffff), exchange_balance_used)
          if gt(unsettled_withdraw_total_updated, 0xFFFFFFFFFFFFFFFF) {
            mstore(32, 11)
            revert(63, 1)
          }
          sstore(session_balance_ptr, or(and(0xffffffffffffffffffffffffffffffff00000000000000000000000000000000, session_balance_0), or(
            /* unsettled_withdraw_total */ mul(unsettled_withdraw_total_updated, 0x10000000000000000), 
            /* asset_balance */ session_balance_updated)))
          sstore(user_balance_ptr, updated_user_balance)
        }
        sstore(exchange_balance_ptr, exchange_balance_remaining)
      }
    }
  }
  struct SetLimitsHeader {
    uint32 exchange_id;
  }
  struct Signature {
    uint256 sig_r;
    uint256 sig_s;
    uint8 sig_v;
  }
  struct UpdateLimit {
    uint32 dcn_id;
    uint64 user_id;
    uint32 exchange_id;
    uint32 quote_asset_id;
    uint32 base_asset_id;
    uint64 fee_limit;
    int64 min_quote_qty;
    int64 min_base_qty;
    uint64 long_max_price;
    uint64 short_min_price;
    uint64 limit_version;
    uint96 quote_shift;
    uint96 base_shift;
  }
  struct SetLimitMemory {
    uint256 user_id;
    uint256 exchange_id;
    uint256 quote_asset_id;
    uint256 base_asset_id;
    uint256 limit_version;
    uint256 quote_shift;
    uint256 base_shift;
  }
  
  function exchange_set_limits(bytes memory data) public  {
    
    uint256[14] memory to_hash_mem;
    uint256 cursor;
    uint256 cursor_end;
    uint256 exchange_id;
    
    uint256[224] memory set_limit_memory_space;
    assembly {
      {
        let locked_features := sload(security_locked_features_slot)
        if and(locked_features, 0x100) {
          mstore(32, 0)
          revert(63, 1)
        }
      }
      let data_size := mload(data)
      cursor := add(data, 32)
      cursor_end := add(cursor, data_size)
      let set_limits_header_0 := mload(cursor)
      cursor := add(cursor, 4)
      if gt(cursor, cursor_end) {
        mstore(32, 1)
        revert(63, 1)
      }
      exchange_id := and(div(set_limits_header_0, 0x100000000000000000000000000000000000000000000000000000000), 0xffffffff)
      let exchange_0 := sload(add(exchanges_slot, mul(4294967300, exchange_id)))
      let exchange_owner := and(exchange_0, 0xffffffffffffffffffffffffffffffffffffffff)
      if iszero(eq(caller, exchange_owner)) {
        mstore(32, 2)
        revert(63, 1)
      }
      if and(div(exchange_0, 0x10000000000000000000000000000000000000000), 0xff) {
        mstore(32, 3)
        revert(63, 1)
      }
    }
    while (true)
    {
        uint256 update_limit_0;
        uint256 update_limit_1;
        uint256 update_limit_2;
        bytes32 limit_hash;
        assembly {
          if eq(cursor, cursor_end) {
            return(0, 0)
          }
          update_limit_0 := mload(cursor)
          update_limit_1 := mload(add(cursor, 32))
          update_limit_2 := mload(add(cursor, 64))
          cursor := add(cursor, 96)
          if gt(cursor, cursor_end) {
            mstore(32, 4)
            revert(63, 1)
          }
          {
            mstore(to_hash_mem, 0xbe6b685e53075dd48bdabc4949b848400d5a7e53705df48e04ace664c3946ad2)
            let temp_var := 0
            temp_var := and(div(update_limit_0, 0x100000000000000000000000000000000000000000000000000000000), 0xffffffff)
            mstore(add(to_hash_mem, 32), temp_var)
            temp_var := and(div(update_limit_0, 0x10000000000000000000000000000000000000000), 0xffffffffffffffff)
            mstore(add(to_hash_mem, 64), temp_var)
            mstore(add(set_limit_memory_space, 0), temp_var)
            temp_var := and(div(update_limit_0, 0x100000000000000000000000000000000), 0xffffffff)
            mstore(add(to_hash_mem, 96), temp_var)
            temp_var := and(div(update_limit_0, 0x1000000000000000000000000), 0xffffffff)
            mstore(add(to_hash_mem, 128), temp_var)
            mstore(add(set_limit_memory_space, 64), temp_var)
            temp_var := and(div(update_limit_0, 0x10000000000000000), 0xffffffff)
            mstore(add(to_hash_mem, 160), temp_var)
            mstore(add(set_limit_memory_space, 96), temp_var)
            temp_var := and(update_limit_0, 0xffffffffffffffff)
            mstore(add(to_hash_mem, 192), temp_var)
            temp_var := and(div(update_limit_1, 0x1000000000000000000000000000000000000000000000000), 0xffffffffffffffff)
            temp_var := signextend(7, temp_var)
            mstore(add(to_hash_mem, 224), temp_var)
            temp_var := and(div(update_limit_1, 0x100000000000000000000000000000000), 0xffffffffffffffff)
            temp_var := signextend(7, temp_var)
            mstore(add(to_hash_mem, 256), temp_var)
            temp_var := and(div(update_limit_1, 0x10000000000000000), 0xffffffffffffffff)
            mstore(add(to_hash_mem, 288), temp_var)
            temp_var := and(update_limit_1, 0xffffffffffffffff)
            mstore(add(to_hash_mem, 320), temp_var)
            temp_var := and(div(update_limit_2, 0x1000000000000000000000000000000000000000000000000), 0xffffffffffffffff)
            mstore(add(to_hash_mem, 352), temp_var)
            mstore(add(set_limit_memory_space, 128), temp_var)
            temp_var := and(div(update_limit_2, 0x1000000000000000000000000), 0xffffffffffffffffffffffff)
            temp_var := signextend(11, temp_var)
            mstore(add(to_hash_mem, 384), temp_var)
            mstore(add(set_limit_memory_space, 160), temp_var)
            temp_var := and(update_limit_2, 0xffffffffffffffffffffffff)
            temp_var := signextend(11, temp_var)
            mstore(add(to_hash_mem, 416), temp_var)
            mstore(add(set_limit_memory_space, 192), temp_var)
          }
          limit_hash := keccak256(to_hash_mem, 448)
          mstore(to_hash_mem, 0x1901000000000000000000000000000000000000000000000000000000000000)
          mstore(add(to_hash_mem, 2), 0x6c1a0baa584339032b4ed0d2fdb53c23d290c0b8a7da5a9e05ce919faa986a59)
          mstore(add(to_hash_mem, 34), limit_hash)
          limit_hash := keccak256(to_hash_mem, 66)
        }
        {
          bytes32 sig_r;
          bytes32 sig_s;
          uint8 sig_v;
          assembly {
            sig_r := mload(cursor)
            sig_s := mload(add(cursor, 32))
            sig_v := and(div(mload(add(cursor, 64)), 0x100000000000000000000000000000000000000000000000000000000000000), 0xff)
            cursor := add(cursor, 65)
            if gt(cursor, cursor_end) {
              mstore(32, 5)
              revert(63, 1)
            }
          }
          uint256 recovered_address = uint256(ecrecover(
                     limit_hash,
                  sig_v,
                  sig_r,
                  sig_s
        ));
          assembly {
            let user_ptr := add(users_slot, mul(237684487561239756867226304516, mload(add(set_limit_memory_space, 0))))
            let session_ptr := add(add(user_ptr, 4294967300), mul(55340232225423622146, exchange_id))
            let trade_address := sload(add(session_ptr, 1))
            if iszero(eq(recovered_address, trade_address)) {
              mstore(32, 6)
              revert(63, 1)
            }
          }
        }
        assembly {
          {
            if iszero(eq(mload(add(set_limit_memory_space, 32)), exchange_id)) {
              mstore(32, 7)
              revert(63, 1)
            }
          }
          let user_ptr := add(users_slot, mul(237684487561239756867226304516, mload(add(set_limit_memory_space, 0))))
          let session_ptr := add(add(user_ptr, 4294967300), mul(55340232225423622146, exchange_id))
          let market_state_ptr := add(add(session_ptr, 4294967298), mul(3, or(mul(mload(add(set_limit_memory_space, 64)), 4294967296), mload(add(set_limit_memory_space, 96)))))
          let market_state_0 := sload(market_state_ptr)
          let market_state_1 := sload(add(market_state_ptr, 1))
          let market_state_2 := sload(add(market_state_ptr, 2))
          {
            let current_limit_version := and(div(market_state_2, 0x1000000000000000000000000000000000000000000000000), 0xffffffffffffffff)
            if iszero(gt(mload(add(set_limit_memory_space, 128)), current_limit_version)) {
              mstore(32, 8)
              revert(63, 1)
            }
          }
          let quote_qty := and(div(market_state_0, 0x1000000000000000000000000000000000000000000000000), 0xffffffffffffffff)
          quote_qty := signextend(7, quote_qty)
          let base_qty := and(div(market_state_0, 0x100000000000000000000000000000000), 0xffffffffffffffff)
          base_qty := signextend(7, base_qty)
          {
            let current_shift := and(div(market_state_2, 0x1000000000000000000000000), 0xffffffffffffffffffffffff)
            current_shift := signextend(11, current_shift)
            let new_shift := mload(add(set_limit_memory_space, 160))
            quote_qty := add(quote_qty, sub(new_shift, current_shift))
            if or(slt(quote_qty, 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF8000000000000000), sgt(quote_qty, 0x7FFFFFFFFFFFFFFF)) {
              mstore(32, 9)
              revert(63, 1)
            }
          }
          {
            let current_shift := and(market_state_2, 0xffffffffffffffffffffffff)
            current_shift := signextend(11, current_shift)
            let new_shift := mload(add(set_limit_memory_space, 192))
            base_qty := add(base_qty, sub(new_shift, current_shift))
            if or(slt(base_qty, 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF8000000000000000), sgt(base_qty, 0x7FFFFFFFFFFFFFFF)) {
              mstore(32, 10)
              revert(63, 1)
            }
          }
          let new_market_state_0 := or(or(or(
            /* quote_qty */ mul(and(quote_qty, 0xffffffffffffffff), 0x1000000000000000000000000000000000000000000000000), 
            /* base_qty */ mul(and(base_qty, 0xffffffffffffffff), 0x100000000000000000000000000000000)), 
            /* fee_limit */ and(update_limit_0, 0xffffffffffffffff)), and(0xffffffffffffffff0000000000000000, market_state_0))
          sstore(market_state_ptr, new_market_state_0)
          sstore(add(market_state_ptr, 1), update_limit_1)
          sstore(add(market_state_ptr, 2), update_limit_2)
        }
      }
  }
  struct ExchangeId {
    uint32 exchange_id;
  }
  struct GroupHeader {
    uint32 quote_asset_id;
    uint32 base_asset_id;
    uint8 user_count;
  }
  struct Settlement {
    uint64 user_id;
    int64 quote_delta;
    int64 base_delta;
    uint64 fees;
  }
  
  function exchange_apply_settlement_groups(bytes memory data) public  {
    
    uint256[6] memory variables;
    assembly {
      {
        let locked_features := sload(security_locked_features_slot)
        if and(locked_features, 0x200) {
          mstore(32, 0)
          revert(63, 1)
        }
      }
      let data_len := mload(data)
      let cursor := add(data, 32)
      let cursor_end := add(cursor, data_len)
      let exchange_id_0 := mload(cursor)
      cursor := add(cursor, 4)
      if gt(cursor, cursor_end) {
        mstore(32, 1)
        revert(63, 1)
      }
      let exchange_id := and(div(exchange_id_0, 0x100000000000000000000000000000000000000000000000000000000), 0xffffffff)
      {
        let exchange_count := sload(exchange_count_slot)
        if iszero(lt(exchange_id, exchange_count)) {
          mstore(32, 2)
          revert(63, 1)
        }
      }
      {
        let exchange_ptr := add(exchanges_slot, mul(4294967300, exchange_id))
        let exchange_0 := sload(exchange_ptr)
        if iszero(eq(caller, and(exchange_0, 0xffffffffffffffffffffffffffffffffffffffff))) {
          mstore(32, 2)
          revert(63, 1)
        }
        if and(div(exchange_0, 0x10000000000000000000000000000000000000000), 0xff) {
          mstore(32, 3)
          revert(63, 1)
        }
      }
      for {} lt(cursor, cursor_end) {} {
        let header_0 := mload(cursor)
        cursor := add(cursor, 9)
        if gt(cursor, cursor_end) {
          mstore(32, 4)
          revert(63, 1)
        }
        let quote_asset_id := and(div(header_0, 0x100000000000000000000000000000000000000000000000000000000), 0xffffffff)
        let base_asset_id := and(div(header_0, 0x1000000000000000000000000000000000000000000000000), 0xffffffff)
        if eq(quote_asset_id, base_asset_id) {
          mstore(32, 16)
          revert(63, 1)
        }
        let group_end := add(cursor, mul(and(div(header_0, 0x10000000000000000000000000000000000000000000000), 0xff), 32))
        {
          let asset_count := sload(asset_count_slot)
          if iszero(and(lt(quote_asset_id, asset_count), lt(base_asset_id, asset_count))) {
            mstore(32, 5)
            revert(63, 1)
          }
        }
        if gt(group_end, cursor_end) {
          mstore(32, 6)
          revert(63, 1)
        }
        let quote_net := 0
        let base_net := 0
        let exchange_ptr := add(exchanges_slot, mul(4294967300, exchange_id))
        let exchange_balance_ptr := add(add(exchange_ptr, 4), quote_asset_id)
        let exchange_balance := sload(exchange_balance_ptr)
        for {} lt(cursor, group_end) {
          cursor := add(cursor, 32)
        } {
          let settlement_0 := mload(cursor)
          let user_ptr := add(users_slot, mul(237684487561239756867226304516, and(div(settlement_0, 0x1000000000000000000000000000000000000000000000000), 0xffffffffffffffff)))
          let session_ptr := add(add(user_ptr, 4294967300), mul(55340232225423622146, exchange_id))
          let market_state_ptr := add(add(session_ptr, 4294967298), mul(3, or(mul(quote_asset_id, 4294967296), base_asset_id)))
          let quote_delta := and(div(settlement_0, 0x100000000000000000000000000000000), 0xffffffffffffffff)
          quote_delta := signextend(7, quote_delta)
          let base_delta := and(div(settlement_0, 0x10000000000000000), 0xffffffffffffffff)
          base_delta := signextend(7, base_delta)
          quote_net := add(quote_net, quote_delta)
          base_net := add(base_net, base_delta)
          let fees := and(settlement_0, 0xffffffffffffffff)
          exchange_balance := add(exchange_balance, fees)
          let market_state_0 := sload(market_state_ptr)
          {
            let quote_qty := and(div(market_state_0, 0x1000000000000000000000000000000000000000000000000), 0xffffffffffffffff)
            quote_qty := signextend(7, quote_qty)
            let base_qty := and(div(market_state_0, 0x100000000000000000000000000000000), 0xffffffffffffffff)
            base_qty := signextend(7, base_qty)
            quote_qty := add(quote_qty, quote_delta)
            base_qty := add(base_qty, base_delta)
            if or(or(slt(quote_qty, 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF8000000000000000), sgt(quote_qty, 0x7FFFFFFFFFFFFFFF)), or(slt(base_qty, 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF8000000000000000), sgt(base_qty, 0x7FFFFFFFFFFFFFFF))) {
              mstore(32, 7)
              revert(63, 1)
            }
            let fee_used := add(and(div(market_state_0, 0x10000000000000000), 0xffffffffffffffff), fees)
            let fee_limit := and(market_state_0, 0xffffffffffffffff)
            if gt(fee_used, fee_limit) {
              mstore(32, 8)
              revert(63, 1)
            }
            market_state_0 := or(or(or(
              /* quote_qty */ mul(quote_qty, 0x1000000000000000000000000000000000000000000000000), 
              /* base_qty */ mul(and(base_qty, 0xFFFFFFFFFFFFFFFF), 0x100000000000000000000000000000000)), 
              /* fee_used */ mul(fee_used, 0x10000000000000000)), 
              /* fee_limit */ fee_limit)
            let market_state_1 := sload(add(market_state_ptr, 1))
            {
              let min_quote_qty := and(div(market_state_1, 0x1000000000000000000000000000000000000000000000000), 0xffffffffffffffff)
              min_quote_qty := signextend(7, min_quote_qty)
              let min_base_qty := and(div(market_state_1, 0x100000000000000000000000000000000), 0xffffffffffffffff)
              min_base_qty := signextend(7, min_base_qty)
              if or(slt(quote_qty, min_quote_qty), slt(base_qty, min_base_qty)) {
                mstore(32, 9)
                revert(63, 1)
              }
            }
            {
              let negatives := add(slt(quote_qty, 1), mul(slt(base_qty, 1), 2))
              switch negatives
                case 3 {
                  if or(quote_qty, base_qty) {
                    mstore(32, 10)
                    revert(63, 1)
                  }
                }
                case 1 {
                  let current_price := div(mul(sub(0, quote_qty), 100000000), base_qty)
                  let long_max_price := and(div(market_state_1, 0x10000000000000000), 0xffffffffffffffff)
                  if gt(current_price, long_max_price) {
                    mstore(32, 11)
                    revert(63, 1)
                  }
                }
                case 2 {
                  if base_qty {
                    let current_price := div(mul(quote_qty, 100000000), sub(0, base_qty))
                    let short_min_price := and(market_state_1, 0xffffffffffffffff)
                    if lt(current_price, short_min_price) {
                      mstore(32, 12)
                      revert(63, 1)
                    }
                  }
                }
            }
          }
          let quote_session_balance_ptr := add(add(session_ptr, 2), quote_asset_id)
          let base_session_balance_ptr := add(add(session_ptr, 2), base_asset_id)
          let quote_session_balance_0 := sload(quote_session_balance_ptr)
          let base_session_balance_0 := sload(base_session_balance_ptr)
          let quote_balance := and(quote_session_balance_0, 0xffffffffffffffff)
          quote_balance := add(quote_balance, quote_delta)
          quote_balance := sub(quote_balance, fees)
          if gt(quote_balance, 0xFFFFFFFFFFFFFFFF) {
            mstore(32, 13)
            revert(63, 1)
          }
          let base_balance := and(base_session_balance_0, 0xffffffffffffffff)
          base_balance := add(base_balance, base_delta)
          if gt(base_balance, 0xFFFFFFFFFFFFFFFF) {
            mstore(32, 14)
            revert(63, 1)
          }
          sstore(market_state_ptr, market_state_0)
          sstore(quote_session_balance_ptr, or(and(0xffffffffffffffffffffffffffffffffffffffffffffffff0000000000000000, quote_session_balance_0), 
            /* asset_balance */ quote_balance))
          sstore(base_session_balance_ptr, or(and(0xffffffffffffffffffffffffffffffffffffffffffffffff0000000000000000, base_session_balance_0), 
            /* asset_balance */ base_balance))
        }
        if or(quote_net, base_net) {
          mstore(32, 15)
          revert(63, 1)
        }
        sstore(exchange_balance_ptr, exchange_balance)
      }
    }
  }
}