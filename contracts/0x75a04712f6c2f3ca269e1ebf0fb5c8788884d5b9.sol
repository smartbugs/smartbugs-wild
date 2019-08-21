pragma solidity ^0.4.6;

contract VIUREFoundersTokenSale {
  mapping (address => uint) public balances;

  uint public transferred_total = 0;

  uint public constant min_goal_amount = 4000 ether;
  uint public constant max_goal_amount = 7000 ether;

  address public project_wallet;

  uint public token_sale_start_block;
  uint public token_sale_end_block;

  uint constant blocks_in_two_months = 351558;

  uint public refund_window_end_block;

  function VIUREFoundersTokenSale(uint _start_block, uint _end_block, address _project_wallet) {
    if (_start_block <= block.number) throw;
    if (_end_block <= _start_block) throw;
    if (_project_wallet == 0) throw;
    
    token_sale_start_block = _start_block;
    token_sale_end_block = _end_block;
    project_wallet = _project_wallet;
    refund_window_end_block = token_sale_end_block + blocks_in_two_months;
  }

  function has_token_sale_started() private constant returns (bool) {
    return block.number >= token_sale_start_block;
  }

  function has_token_sale_time_ended() private constant returns (bool) {
    return block.number > token_sale_end_block;
  }

  function is_min_goal_reached() private constant returns (bool) {
    return transferred_total >= min_goal_amount;
  }

  function is_max_goal_reached() private constant returns (bool) {
    return transferred_total >= max_goal_amount;
  }

  function() payable {
    if (!has_token_sale_started()) throw;

    if (has_token_sale_time_ended()) throw;

    if (msg.value == 0) throw;

    if (is_max_goal_reached()) throw;

    if (transferred_total + msg.value > max_goal_amount) {
     
      var change_to_return = transferred_total + msg.value - max_goal_amount;
      if (!msg.sender.send(change_to_return)) throw;

      var to_add = max_goal_amount - transferred_total;
      balances[msg.sender] += to_add;
      transferred_total += to_add;

    } else {
      balances[msg.sender] += msg.value;
      transferred_total += msg.value;
    }
  }

  function transfer_funds_to_project() {
    if (!is_min_goal_reached()) throw;
    
    if (this.balance == 0) throw;

    if (!project_wallet.send(this.balance)) throw;
  }

  function refund() {
    if (!has_token_sale_time_ended()) throw;

    if (is_min_goal_reached()) throw;
  
    if (block.number > refund_window_end_block) throw;

    var refund_amount = balances[msg.sender];

    if (refund_amount == 0) throw;

    balances[msg.sender] = 0;

    if (!msg.sender.send(refund_amount)) {
    if (!msg.sender.send(refund_amount)) throw;
    }
  }

  function transfer_remaining_funds_to_project() {
    if (!has_token_sale_time_ended()) throw;
    if (is_min_goal_reached()) throw;
    if (block.number <= refund_window_end_block) throw;

    if (this.balance == 0) throw;
    if (!project_wallet.send(this.balance)) throw;
  }
}