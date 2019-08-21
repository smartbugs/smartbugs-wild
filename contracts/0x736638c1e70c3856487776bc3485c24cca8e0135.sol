pragma solidity ^0.4.18;

/// rare.claims

contract RareClaim {
  /*** CONSTANTS ***/
  uint256 private fiveHoursInSeconds = 18000; // 18000;
  string public constant NAME = "RareClaims";
  string public constant SYMBOL = "RareClaim";

  /*** STORAGE ***/
  mapping (address => uint256) private ownerCount;

  address public ceoAddress;
  address public cooAddress;

  struct Rare {
    address owner;
    uint256 price;
    uint256 last_transaction;
    address approve_transfer_to;
  }
  uint rare_count;
  mapping (string => Rare) rares;

  /*** ACCESS MODIFIERS ***/
  modifier onlyCEO() { require(msg.sender == ceoAddress); _; }
  modifier onlyCOO() { require(msg.sender == cooAddress); _; }
  modifier onlyCXX() { require(msg.sender == ceoAddress || msg.sender == cooAddress); _; }

  /*** ACCESS MODIFIES ***/
  function setCEO(address _newCEO) public onlyCEO {
    require(_newCEO != address(0));
    ceoAddress = _newCEO;
  }
  function setCOO(address _newCOO) public onlyCEO {
    require(_newCOO != address(0));
    cooAddress = _newCOO;
  }

  /*** DEFAULT METHODS ***/
  function symbol() public pure returns (string) { return SYMBOL; }
  function name() public pure returns (string) { return NAME; }
  function implementsERC721() public pure returns (bool) { return true; }

  /*** CONSTRUCTOR ***/
  function RareClaim() public {
    ceoAddress = msg.sender;
    cooAddress = msg.sender;
  }

  /*** INTERFACE METHODS ***/
  function createRare(string _rare_id, uint256 _price) public onlyCXX {
    require(msg.sender != address(0));
    _create_rare(_rare_id, address(this), _price);
  }

  function totalSupply() public view returns (uint256 total) {
    return rare_count;
  }

  function balanceOf(address _owner) public view returns (uint256 balance) {
    return ownerCount[_owner];
  }
  function priceOf(string _rare_id) public view returns (uint256 price) {
    return rares[_rare_id].price;
  }

  function getRare(string _rare_id) public view returns (
    string id,
    address owner,
    uint256 price,
    uint256 last_transaction
  ) {
    id = _rare_id;
    owner = rares[_rare_id].owner;
    price = rares[_rare_id].price;
    last_transaction = rares[_rare_id].last_transaction;
  }

  function purchase(string _rare_id) public payable {
    Rare storage rare = rares[_rare_id];

    require(rare.owner != msg.sender);
    require(msg.sender != address(0));

    uint256 time_diff = (block.timestamp - rare.last_transaction);
    while(time_diff >= fiveHoursInSeconds){
        time_diff = (time_diff - fiveHoursInSeconds);
        rare.price = SafeMath.mul(SafeMath.div(rare.price, 100), 75);
    }
    if(rare.price < 1000000000000000){ rare.price = 1000000000000000; }
    require(msg.value >= rare.price);

    uint256 excess = SafeMath.sub(msg.value, rare.price);

    if(rare.owner == address(this)){
      ceoAddress.transfer(rare.price);
    } else {
      ceoAddress.transfer(uint256(SafeMath.mul(SafeMath.div(rare.price, 100), 7)));
      rare.owner.transfer(uint256(SafeMath.mul(SafeMath.div(rare.price, 100), 93)));
    }

    rare.price = SafeMath.mul(SafeMath.div(rare.price, 100), 150);
    rare.owner = msg.sender;
    rare.last_transaction = block.timestamp;

    msg.sender.transfer(excess);
  }

  function payout() public onlyCEO {
    ceoAddress.transfer(this.balance);
  }

  /*** PRIVATE METHODS ***/

  function _create_rare(string _rare_id, address _owner, uint256 _price) private {
    rare_count++;
    rares[_rare_id] = Rare({
      owner: _owner,
      price: _price,
      last_transaction: block.timestamp,
      approve_transfer_to: address(0)
    });
  }

  function _transfer(address _from, address _to, string _rare_id) private {
    rares[_rare_id].owner = _to;
    rares[_rare_id].approve_transfer_to = address(0);
    ownerCount[_from] -= 1;
    ownerCount[_to] += 1;
  }
}

library SafeMath {
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    assert(c / a == b);
    return c;
  }
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a / b;
    return c;
  }
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}