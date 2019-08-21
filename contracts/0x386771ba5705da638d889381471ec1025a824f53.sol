pragma solidity ^0.4.11;
contract simplelottery {
    enum State { Started, Locked }
    State public state = State.Started;
    struct Guess{
      address addr;
      //uint    guess;
    }
    uint arraysize=1000;
    uint constant maxguess=1000000;
    uint bettingprice = 1 ether;
    Guess[1000] guesses;
    uint    numguesses = 0;
    bytes32 curhash = '';
    uint _gameindex = 1;
    uint _starttime = 0;
    modifier inState(State _state) {
      require(state == _state);
      _;
    }
    address developer = 0x0;
    address _winner   = 0x0;
    event SentPrizeToWinner(address winner, uint money, uint gameindex, uint lotterynumber, uint starttime, uint finishtime);
    event SentDeveloperFee(uint amount, uint balance);
    
    function simplelottery() 
    {
      if(developer==address(0)){
        developer = msg.sender;
        state = State.Started;
        _starttime = block.timestamp;
      }
    }
    
    function setBettingCondition(uint _contenders, uint _bettingprice)
    {
      if(msg.sender != developer)
        return;
      arraysize  = _contenders;
      if(arraysize>1000)
        arraysize = 1000;
      bettingprice = _bettingprice;
    }
    
    function findWinner(uint value)
    {
      uint i = value % numguesses;
      _winner = guesses[i].addr;
    }
    
      function getMaxContenders() constant returns(uint){
      return arraysize;
    }

    function getBettingPrice() constant returns(uint){
      return bettingprice;
    }

    function getDeveloperAddress() constant returns(address)
    {
      return developer;
    }
    
    function getDeveloperFee() constant returns(uint)
    {
      uint developerfee = this.balance/100;
      return developerfee;
    }
    
    function getBalance() constant returns(uint)
    {
       return this.balance;
    }
    
    function getLotteryMoney() constant returns(uint)
    {
      uint developerfee = getDeveloperFee();
      uint prize = (this.balance - developerfee);
      return prize;
    }

    function getBettingStatus()
      constant
      returns (uint, uint, uint, uint, uint, uint, uint)
    {
      return ((uint)(state), _gameindex, _starttime, numguesses, getLotteryMoney(), this.balance, bettingprice);
    }



    function finish()
    {
      if(msg.sender != developer)
        return;
      _finish();
    }
    
    function _finish() private
    {
      state = State.Locked;
      uint block_timestamp = block.timestamp;
      uint lotterynumber = (uint(curhash)+block_timestamp)%(maxguess+1);
      findWinner(lotterynumber);
      uint prize = getLotteryMoney();
      uint numwinners = 1;
      uint remain = this.balance - (prize*numwinners);

      _winner.transfer(prize);
      SentPrizeToWinner(_winner, prize, _gameindex, lotterynumber, _starttime, block_timestamp);

      // give delveoper the money left behind
      developer.transfer(remain); 
      SentDeveloperFee(remain, this.balance);
      numguesses = 0;
      _gameindex++;
      state = State.Started;
      _starttime = block.timestamp;
    }
    
    function () payable
    {
        _addguess();
    }

    function addguess() 
      inState(State.Started)
      payable
    {
      _addguess();
    }
    
    function _addguess() private
      inState(State.Started)
    {
      require(msg.value >= bettingprice);
      curhash = sha256(block.timestamp, block.coinbase, block.difficulty, curhash);
      if((uint)(numguesses+1)<=arraysize) {
        guesses[numguesses++].addr = msg.sender;
        if((uint)(numguesses)>=arraysize){
          _finish();
        }
      }
    }
}