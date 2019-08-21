pragma solidity ^0.4.2;

contract Presale {
    mapping (address => uint) public balances;
    uint public transfered_total = 0;
    
    uint public constant min_goal_amount = 5 ether;
    uint public constant max_goal_amount = 10 ether;
    
    // Vega Fund Round A Address
    address public project_wallet;

    uint public presale_start_block;
    uint public presale_end_block;
    
    // est. of blocks count in 1 month
    // Based on 1 block every 17 seconds, 30 days would produce ~152,471
    // Just for allowing for some additional time round to 153,000
    uint constant blocks_in_one_months = 153000;
    
    // block number of the end of refund window, 
    // which will occur in the end of 1 month after presale
    uint public refund_window_end_block;
    
    function Presale(uint _start_block, uint _end_block, address _project_wallet) {
        if (_start_block <= block.number) throw;
        if (_end_block <= _start_block) throw;
        if (_project_wallet == 0) throw;
        
        presale_start_block = _start_block;
        presale_end_block = _end_block;
        project_wallet = _project_wallet;
	refund_window_end_block = presale_end_block + blocks_in_one_months;
    }
	
    function has_presale_started() private constant returns (bool) {
	return block.number >= presale_start_block;
    }
    
    function has_presale_time_ended() private constant returns (bool) {
        return block.number > presale_end_block;
    }
    
    function is_min_goal_reached() private constant returns (bool) {
        return transfered_total >= min_goal_amount;
    }
    
    function is_max_goal_reached() private constant returns (bool) {
        return transfered_total >= max_goal_amount;
    }
    
    // Accept ETH while presale is active or until maximum goal is reached.
    function () payable {
	// check if presale has started
        if (!has_presale_started()) throw;
	    
	// check if presale date is not over
	if (has_presale_time_ended()) throw;
	    
	// don`t accept transactions with zero value
	if (msg.value == 0) throw;

        // check if max goal is not reached
	if (is_max_goal_reached()) throw;
        
        if (transfered_total + msg.value > max_goal_amount) {
            // return change
	    var change_to_return = transfered_total + msg.value - max_goal_amount;
	    if (!msg.sender.send(change_to_return)) throw;
            
            var to_add = max_goal_amount - transfered_total;
            balances[msg.sender] += to_add;
	    transfered_total += to_add;
        } else {
            // set data
	    balances[msg.sender] += msg.value;
	    transfered_total += msg.value;
        }
    }
    
    // Transfer ETH to Vega Round A address, as soon as minimum goal is reached.
    function transfer_funds_to_project() {
        if (!is_min_goal_reached()) throw;
        if (this.balance == 0) throw;
        
        // transfer ethers to Vega Round A address
        if (!project_wallet.send(this.balance)) throw;
    }
    
    // Refund ETH in case minimum goal was not reached during presale.
    // Refund will be available for one month window after presale.
    function refund() {
        if (!has_presale_time_ended()) throw;
        if (is_min_goal_reached()) throw;
        if (block.number > refund_window_end_block) throw;
        
        var amount = balances[msg.sender];
        // check if sender has balance
        if (amount == 0) throw;
        
        // reset balance
        balances[msg.sender] = 0;
        
        // actual refund
        if (!msg.sender.send(amount)) throw;
    }
    
    // In case any ETH has left unclaimed after one month window, send them to Vega Round A address.
    function transfer_left_funds_to_project() {
        if (!has_presale_time_ended()) throw;
        if (is_min_goal_reached()) throw;
        if (block.number <= refund_window_end_block) throw;
        
        if (this.balance == 0) throw;
        // transfer left ETH to Vega Round A address
        if (!project_wallet.send(this.balance)) throw;
    }
}