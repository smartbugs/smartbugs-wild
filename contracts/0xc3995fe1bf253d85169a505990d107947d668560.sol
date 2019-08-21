pragma solidity ^0.4.24;

contract TokenContract {
  function transferFrom(address _from, address _to, uint256 _value) external returns (bool);
  function balanceOf(address who) external view returns (uint256);
  function allowance(address owner, address spender) external view returns (uint256);
}

contract Ownable {
  address public owner;

  constructor() public {
    owner = msg.sender;
  }
  
  modifier onlyOwner() {
    require(msg.sender == owner, "Only Owner");
    _;
  }
}

contract GymRewardsExchange is Ownable {
  TokenContract public tkn;
  bool public active = true;
  mapping (address => uint256) public deposits;
  mapping (address => string) public ethtoeosAddress;
  mapping (bytes32 => address) public eostoethAddress;
  mapping (uint256 => address) public indexedAddress;
  uint256 public addresIndex = 0;

  constructor() public {
    tkn = TokenContract(0x92D3e963aA94D909869940A8d15FA16CcbC6655E);
  }

  function activateExchange(bool _active) public onlyOwner {
    active = _active;
  }

  function deposit(bytes32 _addressHash, string _eosAddress) public {
    require(active, "Exchange is not active");
    uint256 currentBalance = tkn.balanceOf(msg.sender);
    require(currentBalance > 0, "You should have Tokens to exchange");
    require(tkn.allowance(msg.sender, address(this)) == currentBalance, "This contract needs aproval for the whole amount of tokens");
    require(deposits[msg.sender] == 0, "Only one deposit per address is allowed");
    if (tkn.transferFrom(msg.sender, address(this), currentBalance)) {
      addresIndex += 1;
      indexedAddress[addresIndex] = msg.sender;
      deposits[msg.sender] = currentBalance;
      ethtoeosAddress[msg.sender] = _eosAddress;
      eostoethAddress[_addressHash] = msg.sender;
      emit NewDeposit(msg.sender, currentBalance, _eosAddress);
    }
  }

  function checkAddressDeposit(address _address) public view returns (uint256) {
      return(deposits[_address]);
  }
  
  function checkAddressEOS(address _address) public view returns (string) {
      return(ethtoeosAddress[_address]);
  }

  function checkAddressETH(bytes32 _address) public view returns (address) {
      return(eostoethAddress[_address]);
  }
  
  event NewDeposit(address senderAccount, uint256 amount, string eosAddress);

}