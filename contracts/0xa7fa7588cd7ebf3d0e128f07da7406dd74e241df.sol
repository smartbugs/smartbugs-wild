pragma solidity ^0.4.16;

contract TWQCrowdsale {
    address public owner;
    uint256 public amount;
    uint256 public hard_limit;
    uint256 public token_price;
    mapping (address => uint256) public tokens_backed;
    address public contract_admin;
    uint256 public start_block;
    uint256 public end_block;
    
    event FundTransfer(address backer, uint256 amount_paid);
    event Withdrawal(address owner, uint256 total_amount);
    
    function TWQCrowdsale (address crowdsale_owner, uint256 set_limit, uint256 price, uint256 time_limit) public {
        owner = crowdsale_owner;
        hard_limit = set_limit * 1 ether;
        token_price = price * 100 szabo;
        contract_admin = msg.sender;
        start_block = block.number;
        end_block = ((time_limit * 1 hours) / 15 seconds) + start_block;
    }
    
    function () public payable {
        if (msg.value < 0.01 ether || msg.value + amount > hard_limit) revert();
        if (block.number < start_block || block.number > end_block) revert();
        FundTransfer(msg.sender, msg.value);
        amount += msg.value;
        tokens_backed[msg.sender] += msg.value / token_price;
    }
    
    modifier authorized {
        if (msg.sender != contract_admin) revert (); 
        _;
    }
    
    function owner_withdrawal(uint256 withdraw_amount) authorized public {
        withdraw_amount = withdraw_amount * 100 szabo;
        Withdrawal(owner, withdraw_amount);
        owner.transfer(withdraw_amount);
    }
    
    function add_hard_limit(uint256 additional_limit) authorized  public {
        hard_limit += additional_limit * 100 szabo;
    }
    
    function change_start_block(uint256 new_block) authorized public {
        start_block = new_block;
    }
    
    function extend_end_block(uint256 end_time_period) authorized public {
        end_block += ((end_time_period * 1 hours) / 15 seconds); 
    }
    
    function shorten_end_block(uint256 end_time_period) authorized public {
        end_block -= ((end_time_period * 1 hours) / 15 seconds);
    }
    
    function set_end_block(uint256 block_number) authorized public {
        end_block = block_number;
    }
    
    function end_now() authorized public {
        end_block = block.number;
    }
}