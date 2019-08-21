pragma solidity^0.4.17;

contract BountyEscrow {

  address public admin;

  mapping(address => bool) public authorizations;

  event Bounty(
    address indexed sender,
    uint256 indexed amount
  );

  event Payout(
    uint256 indexed id,
    bool indexed success
  );

  function BountyEscrow() public {
    admin = msg.sender;
  }

  // Default bounty function
  function () public payable {
    Bounty(msg.sender, msg.value);
  }


  modifier onlyAdmin {
    require(msg.sender == admin);
    _;
  }

  modifier authorized {
    require(msg.sender == admin || authorizations[msg.sender]);
    _;
  }

  function payout(uint256[] ids, address[] recipients, uint256[] amounts) public authorized {
    require(ids.length == recipients.length && ids.length == amounts.length);
    for (uint i = 0; i < recipients.length; i++) {
      Payout(ids[i], recipients[i].send(amounts[i]));
    }
  }

  function deauthorize(address agent) public onlyAdmin {
    authorizations[agent] = false;
  }

  function authorize(address agent) public onlyAdmin {
    authorizations[agent] = true;
  }

}