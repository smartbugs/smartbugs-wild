pragma solidity ^0.4.16;

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {
  function mul(uint256 a, uint256 b) internal returns (uint256) {
    uint256 c = a * b;
    require(a == 0 || c / a == b);
    return c;
  }

  function sub(uint256 a, uint256 b) internal returns (uint256) {
    require(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal returns (uint256) {
    uint256 c = a + b;
    require(c >= a);
    return c;
  }
}


contract CryptoGain {
    using SafeMath for uint256;
    
    struct Bid {
        address player;
        uint8 slot_from;
        uint8 slot_to;
    }

    Bid[] public bids;
    mapping (address => uint256) balances;

    address public admin;
    bool public is_alive = true;
    uint8 constant max_slots = 100;
    uint256 constant price_ticket = 10 finney;
    uint256 constant win_reward = 40 finney;
    uint256 constant house_edge = 2 finney;
    uint8 constant winners_count = 20; //ripemd160 length
    uint8 public last_slot = 0;
    uint public start_ts = 0;
    uint constant week_seconds = 60*60*24*7;
    
    modifier onlyOwner() {
        require(msg.sender == admin);
        _;
    }
    
    modifier onlyAlive() {
        require(is_alive);
        _;
    }

    function CryptoGain() {
        admin = msg.sender;
    }

    function set_admin(address newAdmin) public onlyOwner {
        admin = newAdmin;
    }
    
    // Fully destruct contract. Use ONLY if you want to fully close lottery.
    // This action can't be revert. Use carefully if you know what you do!
    function destruct() public onlyOwner {
        admin.transfer(this.balance);
        is_alive = false; // <- this action is fully destroy contract
    }
    
    function reset() public onlyOwner {
        require(block.timestamp > start_ts + week_seconds); //only after week of inactivity
        admin.transfer(price_ticket.mul(last_slot));
        restart();

    }
    
    function restart() internal {
        start_ts = block.timestamp;
        last_slot = 0;
        delete bids;
    }
    
    function bid(address player, uint8 bid_slots_count) internal {
        uint8 new_last_slot = last_slot + bid_slots_count;
        bids.push(Bid(player, last_slot, new_last_slot));
        remove_exceed(house_edge.mul(bid_slots_count));
        last_slot = new_last_slot;
    }
    
    function is_slot_in_bid(uint8 slot_from, uint8 slot_to, uint8 slot) returns (bool) {
        return (slot >= slot_from && slot < slot_to) ? true : false;
    }
    
    function search_winner_bid_address(uint8 slot) returns (address) {
        uint8 i;
        
        if (slot < 128) {
            for (i=0; i<bids.length; i++) {
                if (is_slot_in_bid(bids[i].slot_from, bids[i].slot_to, slot)) {
                    return bids[i].player;
                }
            }
            
        } else {
            for (i=uint8(bids.length)-1; i>=0; i--) {
                if (is_slot_in_bid(bids[i].slot_from, bids[i].slot_to, slot)) {
                    return bids[i].player;
                }
            }
        }
        
        assert (false);

    }
    
    function playout() internal {
        
        bytes20 hash = ripemd160(block.timestamp, block.number, msg.sender);
        
        uint8 current_winner_slot = 0;
        for (uint8 i=0; i<winners_count; i++) {
            current_winner_slot = ( current_winner_slot + uint8(hash[i]) ) % max_slots;
            address current_winner_address = search_winner_bid_address(current_winner_slot);
            balances[current_winner_address] = balances[current_winner_address].add(win_reward);
        }
        restart();
    
    }
    
    function remove_exceed(uint256 amount) internal {
        balances[admin] = balances[admin].add(amount);
    }
    
    function get_balance() public returns (uint256) {
        return balances[msg.sender];
    }
    
    function get_foreign_balance(address _address) public returns (uint256) {
        return balances[_address];
    }
  
    function withdraw() public onlyAlive {
        require(balances[msg.sender] > 0);
        var amount = balances[msg.sender];
        balances[msg.sender] = 0;
        msg.sender.transfer(amount);
    }
    
    function run(address player, uint256 deposit_eth) internal onlyAlive {
        require(deposit_eth >= price_ticket);
        uint256 exceed_mod_eth = deposit_eth % price_ticket;
        
        if (exceed_mod_eth > 0) {
            remove_exceed(exceed_mod_eth);
            deposit_eth = deposit_eth.sub(exceed_mod_eth);
        }
        
        uint8 deposit_bids = uint8(deposit_eth / price_ticket);
        
        //how much slots is avaliable for bid
        uint8 avaliable_session_slots = max_slots - last_slot;
        

        if (deposit_bids < avaliable_session_slots) {
            bid(player, deposit_bids);
        } else {
            uint8 max_avaliable_slots = (avaliable_session_slots + max_slots - 1);
            if (deposit_bids > max_avaliable_slots) { //overflow
                uint256 max_bid_eth = price_ticket.mul(max_avaliable_slots);
                uint256 exceed_over_eth = deposit_eth.sub(max_bid_eth);
                remove_exceed(exceed_over_eth);
                deposit_bids = max_avaliable_slots;
            }
            uint8 second_session_bids_count = deposit_bids - avaliable_session_slots;
            
            bid(player, avaliable_session_slots);
            playout();
            if (second_session_bids_count > 0) {
                bid(player, second_session_bids_count);
            }
        }
    }
    
    function() payable public {
        run(msg.sender, msg.value);
        
    }

}