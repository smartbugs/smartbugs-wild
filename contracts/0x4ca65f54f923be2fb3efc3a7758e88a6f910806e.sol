pragma solidity ^0.4.25;

contract GMBCToken {
  function balanceOf(address who) public view returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
}

contract GamblicaEarlyAccess {

    enum State { CREATED, DEPOSIT, CLAIM }

    uint constant PRIZE_FUND_GMBC = 100000000 * (10 ** 18); // 100 000 000 GMBC

    event DepositRegistered(address _player, uint _amount);    

    GMBCToken public gmbcToken;    
    address public gamblica;

    State public state;    
    uint public gmbcTotal;
    mapping (address => uint) public deposit;
    
    modifier onlyGamblica() {
        require(msg.sender == gamblica, "Method can be called only by gamblica");
        _;
    }

    constructor(address _gamblica, address _gmbcTokenAddress) public {
      state = State.CREATED;

      gamblica = _gamblica;
      gmbcToken = GMBCToken(_gmbcTokenAddress);            
    }

    function () external payable {
      require(msg.value == 0, "This contract does not accept ether");

      claim();
    }

    function start() public onlyGamblica {
      require(gmbcToken.balanceOf(address(this)) >= PRIZE_FUND_GMBC, "Contract can only be activated with a prize fund");
      require(state == State.CREATED, "Invalid contract state");

      gmbcTotal = PRIZE_FUND_GMBC;
      state = State.DEPOSIT;
    }

    function registerDeposit(address player, uint amount) public onlyGamblica {
      require(state == State.DEPOSIT, "Invalid contract state");
      require(gmbcTotal + amount <= gmbcToken.balanceOf(address(this)), "Cant register that deposit");

      gmbcTotal += amount;      
      deposit[player] += amount;

      emit DepositRegistered(player, amount);
    }


    function addWinnigs(address[] memory winners, uint[] memory amounts) public onlyGamblica {
      require(winners.length == amounts.length, "Invalid arguments");
      require(state == State.DEPOSIT, "Invalid contract state");
      
      uint length = winners.length;
      for (uint i = 0; i < length; i++) {
        deposit[winners[i]] += amounts[i];
      }
    }
    
    function end() public onlyGamblica {      
      require(state == State.DEPOSIT, "Invalid contract state");

      state = State.CLAIM;
    }

    function claim() public {
      require(state == State.CLAIM, "Contract should be deactivated first");
      
      uint amount = deposit[msg.sender];
      deposit[msg.sender] = 0;
      gmbcToken.transfer(msg.sender, amount);      
    }

    function die() public onlyGamblica {
      uint amount = gmbcToken.balanceOf(address(this));
      gmbcToken.transfer(msg.sender, amount);
      selfdestruct(msg.sender);
    }
}