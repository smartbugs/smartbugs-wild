pragma solidity ^0.4.25;

contract Ticket2Crypto {
    struct player_ent{
        address player;
        address ref;
    }
    address public manager;
    uint public ticket_price;
    uint public bot_subscription_price;
    uint public final_price = 1 finney;
    player_ent[] public players;
    
    function Ticket2Crypto() public{
      manager = msg.sender;
      ticket_price = 72;
      bot_subscription_price = ticket_price * 4;
      final_price = ticket_price * 1 finney;
    }
    function update_price(uint _ticket_price) public restricted{
        ticket_price = _ticket_price;
        bot_subscription_price = _ticket_price * 4;
        final_price = ticket_price * 1 finney;
    }
    function buy_tickets(address _ref, uint _total_tickets) public payable{
      final_price = _total_tickets * (ticket_price-1) * 1 finney;
      require(msg.value > final_price);
      for (uint i=0; i<_total_tickets; i++) {
        players.push(player_ent(msg.sender, _ref));
      }
    }
    function bot_subscription() public payable{
      uint _total_tickets = 4;
      address _ref = 0x0000000000000000000000000000000000000000; 
      final_price = _total_tickets * (ticket_price-1) * 1 finney;
      require(msg.value > final_price);
      for (uint i=0; i<_total_tickets; i++) {
        players.push(player_ent(msg.sender, _ref));
      }
    }
    function buy_tickets_2(address _buyer, address _ref, uint _total_tickets) public restricted{
      for (uint i=0; i<_total_tickets; i++) {
        players.push(player_ent(_buyer, _ref));
      }
    }
    function move_all_funds() public restricted {
        manager.transfer(address(this).balance);
    }
    modifier restricted() {
        require(msg.sender == manager);
        _;
    }
    
}