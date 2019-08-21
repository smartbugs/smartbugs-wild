pragma solidity ^0.4.23;

contract Contract {
    mapping (address => uint256) public balances_bonus;
    uint256 public contract_eth_value_bonus;
}

contract ERC20 {
  function transfer(address _to, uint256 _value) public returns (bool success);
  function balanceOf(address _owner) public constant returns (uint256 balance);
}

contract EdenchainProxy {

  struct Snapshot {
    uint256 tokens_balance;
    uint256 eth_balance;
  }


  Contract contr;
  uint256 public eth_balance;
  ERC20 public token;
  mapping (address => uint8) public contributor_rounds;
  Snapshot[] public snapshots;
  address owner;
  uint8 public rounds;

  constructor(address _contract, address _token) {
      owner = msg.sender;
      contr = Contract(_contract);
      token = ERC20(_token);
      eth_balance = contr.contract_eth_value_bonus();
  }

  //public functions
  function withdraw()  {
  		/* require(contract_token_balance != 0); */
  		if (contributor_rounds[msg.sender] < rounds) {
            uint256 balance = contr.balances_bonus(msg.sender);
  			Snapshot storage snapshot = snapshots[contributor_rounds[msg.sender]];
            uint256 tokens_to_withdraw = (balance * snapshot.tokens_balance) / snapshot.eth_balance;
            /* require(tokens_to_withdraw != 0); */
  			snapshot.tokens_balance -= tokens_to_withdraw;
  			snapshot.eth_balance -= balance;
            contributor_rounds[msg.sender]++;
            require(token.transfer(msg.sender, tokens_to_withdraw));
      }
  }

  function emergency_withdraw(address _token) {
      require(msg.sender == owner);
      require(ERC20(_token).transfer(owner, ERC20(_token).balanceOf(this)));
  }

  function set_tokens_received() {
    require(msg.sender == owner);
    uint256 previous_balance;
    uint256 tokens_this_round;
    for (uint8 i = 0; i < snapshots.length; i++) {
      previous_balance += snapshots[i].tokens_balance;
    }
    tokens_this_round = token.balanceOf(address(this)) - previous_balance;
    require(tokens_this_round != 0);
    snapshots.push(Snapshot(tokens_this_round, eth_balance));
    rounds++;
  }

  function set_token_address(address _token) {
    require(msg.sender == owner && _token != 0x0);
    token = ERC20(_token);
  }

  function set_contract_address(address _contract) {
    require(msg.sender == owner);
    contr = Contract(_contract);
  }
}