pragma solidity ^0.5.0;

library SafeMath {
  function sub(uint a, uint b) internal pure returns (uint) {
    require(b <= a);
    return a - b;
  }
  function add(uint a, uint b) internal pure returns (uint) {
    uint c = a + b;
    require(c >= a);
    return c;
  }
  /*function mul(uint a, uint b) internal pure returns (uint) {
    if (a == 0) {
      return 0;
    }
    uint c = a * b;
    require(c / a == b);
    return c;
  }*/
}

contract ERC20Basic {
  uint public totalSupply;
  address public owner; //owner
  function balanceOf(address who) public view returns (uint);
  function transfer(address to, uint value) public;
  event Transfer(address indexed from, address indexed to, uint value);
  function commitDividend(address who) public; // pays remaining dividend
}

contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender) public view returns (uint);
  function transferFrom(address from, address to, uint value) public;
  function approve(address spender, uint value) public;
  event Approval(address indexed owner, address indexed spender, uint value);
}

contract BasicToken is ERC20Basic {
  using SafeMath for uint;
  // users
  struct User {
    uint120 tokens; // current tokens of user
    uint120 asks;   // current tokens in asks
    uint120 votes;  // current voting power
    uint120 weis;   // current wei balance of user
    uint32 lastProposalID; // last processed dividend period of user's tokens
    address owner;  // votes for new owner
    uint8   voted;  // vote for proposal
  }
  mapping (address => User) users;

  modifier onlyPayloadSize(uint size) {
    assert(msg.data.length >= size + 4);
    _;
  }
  /**
  * @dev transfer token for a specified address
  * @param _to The address to transfer to.
  * @param _value The amount to be transferred.
  */
  function transfer(address _to, uint _value) public onlyPayloadSize(2 * 32) {
    commitDividend(msg.sender);
    users[msg.sender].tokens = uint120(uint(users[msg.sender].tokens).sub(_value));
    if(_to == address(this)) {
      commitDividend(owner);
      users[owner].tokens = uint120(uint(users[owner].tokens).add(_value));
      emit Transfer(msg.sender, owner, _value);
    }
    else {
      commitDividend(_to);
      users[_to].tokens = uint120(uint(users[_to].tokens).add(_value));
      emit Transfer(msg.sender, _to, _value);
    }
  }
  /**
  * @dev Gets the amount of tokens
  * @param _owner The address to query.
  * @return An uint representing the amount owned by the passed address.
  */
  function balanceOf(address _owner) public view returns (uint) {
    return uint(users[_owner].tokens);
  }
  /**
  * @dev Gets the amount of tokens offered for sale (in asks)
  * @param _owner The address to query.
  * @return An uint representing the amount offered by the passed address.
  */
  function askOf(address _owner) public view returns (uint) {
    return uint(users[_owner].asks);
  }
  /**
  * @dev Gets the amount of tokens offered for sale (in asks)
  * @param _owner The address to query.
  * @return An uint representing the amount offered by the passed address.
  */
  function voteOf(address _owner) public view returns (uint) {
    return uint(users[_owner].votes);
  }
  /**
  * @dev Gets the amount of wei owned by user and stored in contract
  * @param _owner The address to query.
  * @return An uint representing the amount wei stored in contract.
  */
  function weiOf(address _owner) public view returns (uint) {
    return uint(users[_owner].weis);
  }
  /**
  * @dev Gets the id of last proccesed proposal period
  * @param _owner The address to query.
  * @return An uint representing the id of last processed proposal period
  */
  function lastOf(address _owner) public view returns (uint) {
    return uint(users[_owner].lastProposalID);
  }
  /**
  * @dev Gets the proposed address of new contract owner / manager
  * @param _owner The address to query.
  * @return An address proposed as new contract owner / manager
  */
  function ownerOf(address _owner) public view returns (address) {
    return users[_owner].owner;
  }
  /**
  * @dev Gets the status of voting
  * @param _owner The address to query.
  * @return An uint > 0 if user already voted
  */
  function votedOf(address _owner) public view returns (uint) {
    return uint(users[_owner].voted);
  }
}

contract StandardToken is BasicToken, ERC20 {
  mapping (address => mapping (address => uint)) allowed;

  /**
   * @dev Transfer tokens from one address to another
   * @param _from address The address which you want to send tokens from
   * @param _to address The address which you want to transfer to
   * @param _value uint the amount of tokens to be transfered
   */
  function transferFrom(address _from, address _to, uint _value) public onlyPayloadSize(3 * 32) {
    uint _allowance = allowed[_from][msg.sender];
    commitDividend(_from);
    commitDividend(_to);
    allowed[_from][msg.sender] = _allowance.sub(_value);
    users[_from].tokens = uint120(uint(users[_from].tokens).sub(_value));
    users[_to].tokens = uint120(uint(users[_to].tokens).add(_value));
    emit Transfer(_from, _to, _value);
  }
  /**
   * @dev Aprove the passed address to spend the specified amount of tokens on beahlf of msg.sender.
   * @param _spender The address which will spend the funds.
   * @param _value The amount of tokens to be spent.
   */
  function approve(address _spender, uint _value) public {
    //  https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
    assert(!((_value != 0) && (allowed[msg.sender][_spender] != 0)));
    allowed[msg.sender][_spender] = _value;
    emit Approval(msg.sender, _spender, _value);
  }
  /**
   * @dev Function to check the amount of tokens than an owner allowed to a spender.
   * @param _owner address The address which owns the funds.
   * @param _spender address The address which will spend the funds.
   * @return A uint specifing the amount of tokens still avaible for the spender.
   */
  function allowance(address _owner, address _spender) public view returns (uint remaining) {
    return allowed[_owner][_spender];
  }
}

/**
 * @title PicoStocksAsset contract
 */
contract PicoStocksAsset is StandardToken {

    // metadata
    string public constant version = "0.2";
    string public constant name = "PicoStocks Asset";
    uint public constant decimals = 0;
    uint public picoid = 0; // Asset ID on PicoStocks
    string public symbol = ""; // Asset code on PicoStocks
    string public www = ""; // Official web page

    uint public totalWeis = 0; // sum of wei owned by users
    uint public totalVotes = 0;  // number of alligible votes

    struct Order {
        uint64 prev;   // previous order, need this to enable safe/fast order cancel
        uint64 next;   // next order
        uint128 price; // offered/requested price of 1 token
        uint96 amount; // number of offered/requested tokens
        address who;   // address of owner of tokens or funds
    }
    mapping (uint => Order) asks;
    mapping (uint => Order) bids;
    uint64 firstask=0; // key of lowest ask
    uint64 lastask=0;  // key of last inserted ask
    uint64 firstbid=0; // key of highest bid
    uint64 lastbid=0;  // key of last inserted bid

    uint constant weekBlocks = 4*60*24*7; // number of blocks in 1 week
    uint constant minPrice  = 0xFFFF;                             // min price per token
    uint constant maxPrice  = 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF; // max price per token
    uint constant maxTokens = 0xFFFFFFFFFFFFFFFFFFFFFFFF;         // max number of tokens

    address public custodian = 0xd720a4768CACE6d508d8B390471d83BA3aE6dD32;

    // investment parameters
    uint public investOwner; // number of tokens assigned to owner if first round successfull
    uint public investPrice; // price of 1 token
    uint public investStart; // first block of funding round
    uint public investEnd;   // last block of funding round
    uint public investGot;   // funding collected
    uint public investMin;   // minimum funding
    uint public investMax;   // maximum funding
    uint public investKYC = 1;   // KYC requirement

    //dividends
    uint[] public dividends; // dividens collected per period, growing array

    //proposal
    uint public proposalID = 1;   // proposal number and dividend period
    uint public proposalVotesYes; // yes-votes collected
    uint public proposalVotesNo;  // no-votes collected
    uint public proposalBlock;    // block number proposal published
    uint public proposalDividendPerShare; // dividend per share
    uint public proposalBudget;   // budget for the owner for next period
    uint public proposalTokens;   // number of new tokens for next round
    uint public proposalPrice;    // price of new token in next round
    uint public acceptedBudget;   // unspent budget for the owner in current round

    //change owner
    mapping (address => uint) owners; // votes for new owners / managers of the contract

    // events
    event LogBuy(address indexed who, uint amount, uint price);
    event LogSell(address indexed who, uint amount, uint price);
    event LogCancelBuy(address indexed who, uint amount, uint price);
    event LogCancelSell(address indexed who, uint amount, uint price);
    event LogTransaction(address indexed from, address indexed to, uint amount, uint price);
    event LogDeposit(address indexed who,uint amount);
    event LogWithdraw(address indexed who,uint amount);
    event LogExec(address indexed who,uint amount);
    event LogPayment(address indexed who, address from, uint amount);
    event LogDividend(uint amount);
    event LogDividend(address indexed who, uint amount, uint period);
    event LogNextInvestment(uint price,uint amount);
    event LogNewOwner(address indexed who);
    event LogNewCustodian(address indexed who);
    event LogNewWww(string www);
    event LogProposal(uint dividendpershare,uint budget,uint moretokens,uint minprice);
    event LogVotes(uint proposalVotesYes,uint proposalVotesNo);
    event LogBudget(uint proposalBudget);
    event LogAccepted(uint proposalDividendPerShare,uint proposalBudget,uint proposalTokens,uint proposalPrice);
    event LogRejected(uint proposalDividendPerShare,uint proposalBudget,uint proposalTokens,uint proposalPrice);
    
    modifier onlyOwner() {
        assert(msg.sender == owner);
        _;
    }

    // constructor
    /**
     * @dev Contract constructor
     */
    constructor() public {
        owner = msg.sender;
    }

/* initial investment functions */

    /**
     * @dev Set first funding round parameters
     * @param _tokens number of tokens given to admin
     * @param _budget initial approved budget
     * @param _price price of 1 token in first founding round
     * @param _from block number of start of funding round
     * @param _length length of the funding round in blocks
     * @param _min minimum number of tokens to sell
     * @param _max maximum number of tokens to sell
     * @param _kyc require KYC during first investment round
     * @param _picoid asset id on picostocks
     * @param _symbol asset symmbol on picostocks
     */
    function setFirstInvestPeriod(uint _tokens,uint _budget,uint _price,uint _from,uint _length,uint _min,uint _max,uint _kyc,uint _picoid,string memory _symbol) public onlyOwner {
        require(investEnd == 0 && _price < maxPrice && _length <= weekBlocks * 12 && _min <= _max && _tokens.add(_max) < maxTokens );
        investOwner = _tokens;
        acceptedBudget = _budget;
        users[owner].lastProposalID = uint32(proposalID);
        users[custodian].lastProposalID = uint32(proposalID);
        if(_price <= minPrice){
          _price = minPrice+1;
        }
        investPrice = _price;
        if(_from < block.number){
          _from = block.number;
        }
        investStart = _from;
        if(_length == 0){
          _length = weekBlocks * 4;
        }
        investEnd = _from + _length;
        investMin = _min;
        investMax = _max;
        investKYC = _kyc;
        picoid = _picoid;
        symbol = _symbol;
        dividends.push(0); // not used
        dividends.push(0); // current dividend
        if(investMax == 0){
          closeInvestPeriod();
        }
    }

    /**
     * @dev Accept address for first investment
     * @param _who accepted address (investor)
     */
    function acceptKYC(address _who) external onlyOwner {
        if(users[_who].lastProposalID==0){
          users[_who].lastProposalID=1;
        }
    }

    /**
     * @dev Buy tokens
     */
    function invest() payable public {
        commitDividend(msg.sender);
        require(msg.value > 0 && block.number >= investStart && block.number < investEnd && totalSupply < investMax && investPrice > 0);
        uint tokens = msg.value / investPrice;
        if(investMax < totalSupply.add(tokens)){
            tokens = investMax.sub(totalSupply);
        }
        totalSupply += tokens;
        users[msg.sender].tokens += uint120(tokens);
        emit Transfer(address(0),msg.sender,tokens);
        uint _value = msg.value.sub(tokens * investPrice);
        if(_value > 0){ // send back excess funds immediately
            emit LogWithdraw(msg.sender,_value);
            (bool success, /*bytes memory _unused*/) = msg.sender.call.value(_value)("");
            require(success);
        }
        if(totalSupply>=investMax){
            closeInvestPeriod();
        }
    }

    /**
     * @dev Buy tokens
     */
    function () payable external {
        invest();
    }

    /**
     * @dev Return wei to token owners if first funding round failes
     */
    function disinvest() public {
        require(investEnd < block.number && totalSupply < investMin && totalSupply>0 && proposalID > 1);
        payDividend((address(this).balance-totalWeis)/totalSupply); //CHANGED
        investEnd = block.number + weekBlocks*4; // enable future dividend payment if contract has funds
    }

/* management functions */

    /**
     * @dev Propose dividend, budget and optional funding parameters for next round
     * @param _dividendpershare amount of wei per share to pay out
     * @param _budget amount of wei to give to owner
     * @param _tokens amount of new tokens to issue
     * @param _price price of 1 new token
     */
    function propose(uint _dividendpershare,uint _budget,uint _tokens,uint _price) external onlyOwner {
        require(proposalBlock + weekBlocks*4 < block.number && investEnd < block.number && proposalID > 1); //can not send more than 1 proposal per 28 days
        if(block.number>investEnd && investStart>0 && investPrice>0 && investMax>0){
          totalVotes=totalSupply;
          investStart=0;
          investMax=0;
        }
        proposalVotesYes=0;
        proposalVotesNo=0;
        proposalID++;
        dividends.push(0);
        proposalBlock=block.number;
        proposalDividendPerShare=_dividendpershare;
        proposalBudget=_budget;
        proposalTokens=_tokens;
        proposalPrice=_price;
        emit LogProposal(_dividendpershare,_budget,_tokens,_price);
    }

    /**
     * @dev Execute proposed plan if passed
     */
    function executeProposal() public {
        require(proposalVotesYes > 0 && (proposalBlock + weekBlocks*4 < block.number || proposalVotesYes>totalVotes/2 || proposalVotesNo>totalVotes/2) && proposalID > 1);
        //old require(proposalVotesYes > 0);
        emit LogVotes(proposalVotesYes,proposalVotesNo);
        if(proposalVotesYes >= proposalVotesNo && (proposalTokens==0 || proposalPrice>=investPrice || proposalVotesYes>totalVotes/2)){
          if(payDividend(proposalDividendPerShare) > 0){
            emit LogBudget(proposalBudget);
            acceptedBudget=proposalBudget;}
          if(proposalTokens>0){
            emit LogNextInvestment(proposalPrice,proposalTokens);
            setNextInvestPeriod(proposalPrice,proposalTokens);}
          emit LogAccepted(proposalDividendPerShare,proposalBudget,proposalTokens,proposalPrice);}
        else{
          emit LogRejected(proposalDividendPerShare,proposalBudget,proposalTokens,proposalPrice);}
        proposalBlock=0;
        proposalVotesYes=0;
        proposalVotesNo=0;
        proposalDividendPerShare=0;
        proposalBudget=0;
        proposalTokens=0;
        proposalPrice=0;
    }

    /**
     * @dev Set next funding round parameters
     * @param _price price of 1 new token
     * @param _tokens amount of new tokens to issue
     */
    function setNextInvestPeriod(uint _price,uint _tokens) internal {
        require(totalSupply >= investMin && _price > 0 && _price < maxPrice && totalSupply + _tokens < 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF);
        investStart = block.number + weekBlocks*2;
        investEnd = block.number + weekBlocks*4;
        investPrice = _price; // too high price will disable future investments
        investMax = totalSupply + _tokens;
        investKYC=0;
    }

    /**
     * @dev Finish funding round and update voting power
     */
    function closeInvestPeriod() public {
        require((block.number>investEnd || totalSupply>=investMax) && investStart>0);
        if(proposalID == 1){
          totalSupply += investOwner;
          users[owner].tokens += uint120(investOwner);
          if(totalSupply == 0){
            totalSupply = 1;
            users[owner].tokens = 1;
          }
        }
        proposalID++;
        dividends.push(0);
        totalVotes=totalSupply;
        investStart=0;
        investMax=0;
        investKYC=0;
    }

    /**
     * @dev Pay dividend per share 
     * @param _wei The amount of wei to pay per share
     */
    function payDividend(uint _wei) internal returns (uint) {
        if(_wei == 0){
          return 1;}
        //uint newdividend = _wei.mul(totalSupply);
        uint newdividend = _wei * totalSupply;
        require(newdividend / _wei == totalSupply);
        if(address(this).balance < newdividend.add(totalWeis)){
          emit LogDividend(0); //indicates failure
          return 0;}
        totalWeis += newdividend;
        dividends[proposalID] = _wei;
        proposalID++;
        dividends.push(0);
        totalVotes=totalSupply;
        emit LogDividend(_wei);
        return(_wei);
    }

    /**
     * @dev Commit remaining dividends and update votes before transfer of tokens
     * @param _who User to process
     */
    function commitDividend(address _who) public {
        uint last = users[_who].lastProposalID;
        require(investKYC==0 || last>0); // only authorized investors during KYC period
        uint tokens=users[_who].tokens+users[_who].asks;
        if((tokens==0) || (last==0)){
            users[_who].lastProposalID=uint32(proposalID);
            return;
        }
        if(last==proposalID) {
            return;
        }
        if(tokens != users[_who].votes){
            if(users[_who].owner != address(0)){
                owners[users[_who].owner] = owners[users[_who].owner].add(tokens).sub(uint(users[_who].votes));
            }
            users[_who].votes=uint120(tokens); // store voting power
        }
        uint balance = 0;
        for(; last < proposalID ; last ++) {
            balance += tokens * dividends[last];
        }
        users[_who].weis += uint120(balance);
        users[_who].lastProposalID = uint32(last);
        users[_who].voted=0;
        emit LogDividend(_who,balance,last);
    }

/* administrative functions */

    /**
     * @dev Change owner
     * @param _who The address of new owner
     */
    function changeOwner(address _who) external onlyOwner {
        assert(_who != address(0));
        owner = _who;
        emit LogNewOwner(_who);
    }

    /**
     * @dev Change the official www address
     * @param _www The new www address
     */
    function changeWww(string calldata _www) external onlyOwner {
        www=_www;
        emit LogNewWww(_www);
    }

    /**
     * @dev Change owner
     * @param _who The address of new owner
     */
    function changeCustodian(address _who) external { //CHANGED
        assert(msg.sender == custodian);
        assert(_who != address(0));
        custodian = _who;
        emit LogNewCustodian(_who);
    }

    /**
     * @dev Execute a call
     * @param _to destination address
     * @param _data The call data
     */
    function exec(address _to,bytes calldata _data) payable external onlyOwner {
        emit LogExec(_to,msg.value);
        (bool success, /*bytes memory _unused*/) =_to.call.value(msg.value)(_data);
        require(success);
    }

    /**
     * @dev Withdraw funds from contract by contract owner / manager
     * @param _amount The amount of wei to withdraw
     * @param _who The addres to send wei to
     */
    function spend(uint _amount,address _who) external onlyOwner {
        require(_amount > 0 && address(this).balance >= _amount.add(totalWeis) && totalSupply >= investMin);
        acceptedBudget=acceptedBudget.sub(_amount); //check for excess withdrawal
        if(_who == address(0)){
          emit LogWithdraw(msg.sender,_amount);
          (bool success, /*bytes memory _unused*/) = msg.sender.call.value(_amount)("");
          require(success);}
        else{
          emit LogWithdraw(_who,_amount);
          (bool success, /*bytes memory _unused*/) = _who.call.value(_amount)("");
          require(success);}
    }

/* user functions */

    /**
     * @dev Vote to change contract owner / manager
     * @param _who The addres of the proposed new contract owner / manager
     */
    function voteOwner(address _who) external {
        require(_who != users[msg.sender].owner);
        if(users[msg.sender].owner != address(0)){
          owners[users[msg.sender].owner] = owners[users[msg.sender].owner].sub(users[msg.sender].votes);
        }
        users[msg.sender].owner=_who;
        if(_who != address(0)){
          owners[_who] = owners[_who].add(users[msg.sender].votes);
          if(owners[_who] > totalVotes/2 && _who != owner){
            owner = _who;
            emit LogNewOwner(_who);
          }
        }
    }

    /**
     * @dev Vote in favor of the current proposal
     */
    function voteYes() public {
        commitDividend(msg.sender);
        require(users[msg.sender].voted == 0 && proposalBlock + weekBlocks*4 > block.number && proposalBlock > 0);
        users[msg.sender].voted=1;
        proposalVotesYes+=users[msg.sender].votes;
    }

    /**
     * @dev Vote against the current proposal
     */
    function voteNo() public {
        commitDividend(msg.sender);
        require(users[msg.sender].voted == 0 && proposalBlock + weekBlocks*4 > block.number && proposalBlock > 0);
        users[msg.sender].voted=1;
        proposalVotesNo+=users[msg.sender].votes;
    }

    /**
     * @dev Vote in favor of the proposal defined by ID
     * @param _id Proposal ID
     */
    function voteYes(uint _id) external {
        require(proposalID==_id);
        voteYes();
    }

    /**
     * @dev Vote against the proposal defined by ID
     * @param _id Proposal ID
     */
    function voteNo(uint _id) external {
        require(proposalID==_id);
        voteNo();
    }

    /**
     * @dev Store funds in contract
     */
    function deposit() payable external {
        commitDividend(msg.sender); //CHANGED
        users[msg.sender].weis += uint120(msg.value);
        totalWeis += msg.value;
        emit LogDeposit(msg.sender,msg.value);
    }

    /**
     * @dev Withdraw funds from contract
     * @param _amount Amount of wei to withdraw
     */
    function withdraw(uint _amount) external {
        commitDividend(msg.sender);
        uint amount=_amount;
        if(amount > 0){
           require(users[msg.sender].weis >= amount);
        }
        else{
           require(users[msg.sender].weis > 0);
           amount=users[msg.sender].weis;
        }
        users[msg.sender].weis = uint120(uint(users[msg.sender].weis).sub(amount));
        totalWeis = totalWeis.sub(amount);
        //msg.sender.transfer(amount);
        emit LogWithdraw(msg.sender,amount);
        (bool success, /*bytes memory _unused*/) = msg.sender.call.value(amount)("");
        require(success);
    }

    /**
     * @dev Wire funds from one user to another user
     * @param _amount Amount of wei to wire
     * @param _who Address of the user to wire to
     */
    function wire(uint _amount,address _who) external {
        users[msg.sender].weis = uint120(uint(users[msg.sender].weis).sub(_amount));
        users[_who].weis = uint120(uint(users[_who].weis).add(_amount));
    }

    /**
     * @dev Send wei to contract
     * @param _who Address of the payee
     */
    function pay(address _who) payable external {
        emit LogPayment(_who,msg.sender,msg.value);
    }

/* market view functions */

    /**
     * @dev Return ask orders optionally filtered by user
     * @param _who Optional address of the user
     * @return An array of uint representing the (filtered) orders, 4 uints per order (id,price,amount,user)
     */
    function ordersSell(address _who) external view returns (uint[256] memory) {
        uint[256] memory ret;
        uint num=firstask;
        uint id=0;
        for(;asks[num].price>0 && id<64;num=uint(asks[num].next)){
          if(_who!=address(0) && _who!=asks[num].who){
            continue;
          }
          ret[4*id+0]=num;
          ret[4*id+1]=uint(asks[num].price);
          ret[4*id+2]=uint(asks[num].amount);
          ret[4*id+3]=uint(asks[num].who);
          id++;}
        return ret;
    }

    /**
     * @dev Return bid orders optionally filtered by user
     * @param _who Optional address of the user
     * @return An array of uint representing the (filtered) orders, 4 uints per order (id,price,amount,user)
     */
    function ordersBuy(address _who) external view returns (uint[256] memory) {
        uint[256] memory ret;
        uint num=firstbid;
        uint id=0;
        for(;bids[num].price>0 && id<64;num=uint(bids[num].next)){
          if(_who!=address(0) && _who!=bids[num].who){
            continue;
          }
          ret[4*id+0]=num;
          ret[4*id+1]=uint(bids[num].price);
          ret[4*id+2]=uint(bids[num].amount);
          ret[4*id+3]=uint(bids[num].who);
          id++;}
        return ret;
    }

    /**
     * @dev Find the ask order id for a user
     * @param _who The address of the user
     * @param _minprice Optional minimum price
     * @param _maxprice Optional maximum price
     * @return The id of the order
     */
    function findSell(address _who,uint _minprice,uint _maxprice) external view returns (uint) {
        uint num=firstask;
        for(;asks[num].price>0;num=asks[num].next){
          if(_maxprice > 0 && asks[num].price > _maxprice){
            return 0;}
          if(_minprice > 0 && asks[num].price < _minprice){
            continue;}
          if(_who == asks[num].who){ //FIXED !!!
            return num;}}
    }

    /**
     * @dev Find the bid order id for a user
     * @param _who The address of the user
     * @param _minprice Optional minimum price
     * @param _maxprice Optional maximum price
     * @return The id of the order
     */
    function findBuy(address _who,uint _minprice,uint _maxprice) external view returns (uint) {
        uint num=firstbid;
        for(;bids[num].price>0;num=bids[num].next){
          if(_minprice > 0 && bids[num].price < _minprice){
            return 0;}
          if(_maxprice > 0 && bids[num].price > _maxprice){
            continue;}
          if(_who == bids[num].who){
            return num;}}
    }

    /**
     * @dev Report the user address of an ask order
     * @param _id The id of the order
     * @return The address of the user placing the order
     */
    function whoSell(uint _id) external view returns (address) {
        if(_id>0){
          return address(asks[_id].who);
        }
        return address(asks[firstask].who);
    }

    /**
     * @dev Report the user address of a bid order
     * @param _id The id of the order
     * @return The address of the user placing the order
     */
    function whoBuy(uint _id) external view returns (address) {
        if(_id>0){
          return address(bids[_id].who);
        }
        return address(bids[firstbid].who);
    }

    /**
     * @dev Report the amount of tokens of an ask order
     * @param _id The id of the order
     * @return The amount of tokens offered
     */
    function amountSell(uint _id) external view returns (uint) {
        if(_id>0){
          return uint(asks[_id].amount);
        }
        return uint(asks[firstask].amount);
    }

    /**
     * @dev Report the amount of tokens of a bid order
     * @param _id The id of the order
     * @return The amount of tokens requested
     */
    function amountBuy(uint _id) external view returns (uint) {
        if(_id>0){
          return uint(bids[_id].amount);
        }
        return uint(bids[firstbid].amount);
    }

    /**
     * @dev Report the price of 1 token of an ask order
     * @param _id The id of the order
     * @return The requested price for 1 token
     */
    function priceSell(uint _id) external view returns (uint) {
        if(_id>0){
          return uint(asks[_id].price);
        }
        return uint(asks[firstask].price);
    }

    /**
     * @dev Report the price of 1 token of a bid order
     * @param _id The id of the order
     * @return The offered price for 1 token
     */
    function priceBuy(uint _id) external view returns (uint) {
        if(_id>0){
          return uint(bids[_id].price);
        }
        return uint(bids[firstbid].price);
    }

/* trade functions */

    /**
     * @dev Cancel an ask order
     * @param _id The id of the order
     */
    function cancelSell(uint _id) external {
        require(asks[_id].price>0 && asks[_id].who==msg.sender);
        users[msg.sender].tokens=uint120(uint(users[msg.sender].tokens).add(asks[_id].amount));
        users[msg.sender].asks=uint120(uint(users[msg.sender].asks).sub(asks[_id].amount));
        if(asks[_id].prev>0){
          asks[asks[_id].prev].next=asks[_id].next;}
        else{
          firstask=asks[_id].next;}
        if(asks[_id].next>0){
          asks[asks[_id].next].prev=asks[_id].prev;}
        emit LogCancelSell(msg.sender,asks[_id].amount,asks[_id].price);
        delete(asks[_id]);
    }

    /**
     * @dev Cancel a bid order
     * @param _id The id of the order
     */
    function cancelBuy(uint _id) external {
        require(bids[_id].price>0 && bids[_id].who==msg.sender);
        uint value=bids[_id].amount*bids[_id].price;
        users[msg.sender].weis+=uint120(value);
        if(bids[_id].prev>0){
          bids[bids[_id].prev].next=bids[_id].next;}
        else{
          firstbid=bids[_id].next;}
        if(bids[_id].next>0){
          bids[bids[_id].next].prev=bids[_id].prev;}
        emit LogCancelBuy(msg.sender,bids[_id].amount,bids[_id].price);
        delete(bids[_id]);
    }

    /**
     * @dev Place and ask order (sell tokens)
     * @param _amount The amount of tokens to sell
     * @param _price The minimum price per token in wei
     */
    function sell(uint _amount, uint _price) external {
        require(0 < _price && _price < maxPrice && 0 < _amount && _amount < maxTokens && _amount <= users[msg.sender].tokens);
        commitDividend(msg.sender);
        users[msg.sender].tokens-=uint120(_amount); //we will sell that much
        uint funds=0;
        uint amount=_amount;
        for(;bids[firstbid].price>0 && bids[firstbid].price>=_price;){
          uint value=uint(bids[firstbid].price)*uint(bids[firstbid].amount);
          uint fee=value >> 9; //0.4% fee
          if(amount>=bids[firstbid].amount){
            amount=amount.sub(uint(bids[firstbid].amount));
            commitDividend(bids[firstbid].who);
            emit LogTransaction(msg.sender,bids[firstbid].who,bids[firstbid].amount,bids[firstbid].price);
            //seller
            //users[msg.sender].tokens-=bids[firstbid].amount;
            funds=funds.add(value-fee-fee);
            users[custodian].weis+=uint120(fee);
            totalWeis=totalWeis.sub(fee);
            //buyer
            users[bids[firstbid].who].tokens+=bids[firstbid].amount;
            //clear
            uint64 next=bids[firstbid].next;
            delete bids[firstbid];
            firstbid=next; // optimize and move outside ?
            if(amount==0){
              break;}
            continue;}
          value=amount*uint(bids[firstbid].price);
          fee=value >> 9; //0.4% fee
          commitDividend(bids[firstbid].who);
          funds=funds.add(value-fee-fee);
          emit LogTransaction(msg.sender,bids[firstbid].who,amount,bids[firstbid].price);
          //seller
          //users[msg.sender].tokens-=amount;
          users[custodian].weis+=uint120(fee);
          totalWeis=totalWeis.sub(fee);
          bids[firstbid].amount=uint96(uint(bids[firstbid].amount).sub(amount));
          require(bids[firstbid].amount>0);
          //buyer
          users[bids[firstbid].who].tokens+=uint120(amount);
          bids[firstbid].prev=0;
          totalWeis=totalWeis.sub(funds);
          (bool success, /*bytes memory _unused*/) = msg.sender.call.value(funds)("");
          require(success);
          return;}
        if(firstbid>0){
          bids[firstbid].prev=0;}
        if(amount>0){
          uint64 ask=firstask;
          uint64 last=0;
          for(;asks[ask].price>0 && asks[ask].price<=_price;ask=asks[ask].next){
            last=ask;}
          lastask++;
          asks[lastask].prev=last;
          asks[lastask].next=ask;
          asks[lastask].price=uint128(_price);
          asks[lastask].amount=uint96(amount);
          asks[lastask].who=msg.sender;
          users[msg.sender].asks+=uint120(amount);
          emit LogSell(msg.sender,amount,_price);
          if(last>0){
            asks[last].next=lastask;}
          else{
            firstask=lastask;}
          if(ask>0){
            asks[ask].prev=lastask;}}
        if(funds>0){
          totalWeis=totalWeis.sub(funds);
          (bool success, /*bytes memory _unused*/) = msg.sender.call.value(funds)("");
          require(success);}
    }

    /**
     * @dev Place and bid order (buy tokens using Ether of the transaction)
     * @param _amount The maximum amount of tokens to buy
     * @param _price The maximum price per token in wei
     */
    function buy(uint _amount, uint _price) payable external {
        require(0 < _price && _price < maxPrice && 0 < _amount && _amount < maxTokens && _price <= msg.value);
        commitDividend(msg.sender);
        uint funds=msg.value;
        uint amount=_amount;
        uint value;
        for(;asks[firstask].price>0 && asks[firstask].price<=_price;){
          value=uint(asks[firstask].price)*uint(asks[firstask].amount);
          uint fee=value >> 9; //2*0.4% fee
          if(funds>=value+fee+fee && amount>=asks[firstask].amount){
            amount=amount.sub(uint(asks[firstask].amount));
            commitDividend(asks[firstask].who);
            funds=funds.sub(value+fee+fee);
            emit LogTransaction(asks[firstask].who,msg.sender,asks[firstask].amount,asks[firstask].price);
            //seller
            users[asks[firstask].who].asks-=asks[firstask].amount;
            users[asks[firstask].who].weis+=uint120(value);
            users[custodian].weis+=uint120(fee);
            totalWeis=totalWeis.add(value+fee);
            //buyer
            users[msg.sender].tokens+=asks[firstask].amount;
            //clear
            uint64 next=asks[firstask].next;
            delete asks[firstask];
            firstask=next; // optimize and move outside ?
            if(funds<asks[firstask].price){
              break;}
            continue;}
          if(amount>asks[firstask].amount){
            amount=asks[firstask].amount;}
          if((funds-(funds>>8))<amount*asks[firstask].price){
            amount=(funds-(funds>>8))/asks[firstask].price;}
          if(amount>0){
            value=amount*uint(asks[firstask].price);
            fee=value >> 9; //2*0.4% fee
            commitDividend(asks[firstask].who);
            funds=funds.sub(value+fee+fee);
            emit LogTransaction(asks[firstask].who,msg.sender,amount,asks[firstask].price);
            //seller
            users[asks[firstask].who].asks-=uint120(amount);
            users[asks[firstask].who].weis+=uint120(value);
            users[custodian].weis+=uint120(fee);
            totalWeis=totalWeis.add(value+fee);
            asks[firstask].amount=uint96(uint(asks[firstask].amount).sub(amount));
            require(asks[firstask].amount>0);
            //buyer
            users[msg.sender].tokens+=uint120(amount);}
          asks[firstask].prev=0;
          if(funds>0){
            (bool success, /*bytes memory _unused*/) = msg.sender.call.value(funds)("");
            require(success);}
          return;}
        if(firstask>0){ //all orders removed
          asks[firstask].prev=0;}
        if(amount>funds/_price){
          amount=funds/_price;}
        if(amount>0){
          uint64 bid=firstbid;
          uint64 last=0;
          for(;bids[bid].price>0 && bids[bid].price>=_price;bid=bids[bid].next){
            last=bid;}
          lastbid++;
          bids[lastbid].prev=last;
          bids[lastbid].next=bid;
          bids[lastbid].price=uint128(_price);
          bids[lastbid].amount=uint96(amount);
          bids[lastbid].who=msg.sender;
          value=amount*_price;
          totalWeis=totalWeis.add(value);
          funds=funds.sub(value);
          emit LogBuy(msg.sender,amount,_price);
          if(last>0){
            bids[last].next=lastbid;}
          else{
            firstbid=lastbid;}
          if(bid>0){
            bids[bid].prev=lastbid;}}
        if(funds>0){
          (bool success, /*bytes memory _unused*/) = msg.sender.call.value(funds)("");
          require(success);}
    }

}