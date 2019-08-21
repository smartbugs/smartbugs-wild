// produced by the Solididy File Flattener (c) David Appleton 2018
// contact : dave@akomba.com
// released under Apache 2.0 licence
contract Ownable {
  address public owner;


  event OwnershipRenounced(address indexed previousOwner);
  event OwnershipTransferred(
    address indexed previousOwner,
    address indexed newOwner
  );


  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  constructor() public {
    owner = msg.sender;
  }

  /**
   * @dev Throws if called by any account other than the owner.
   */
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

  /**
   * @dev Allows the current owner to relinquish control of the contract.
   */
  function renounceOwnership() public onlyOwner {
    emit OwnershipRenounced(owner);
    owner = address(0);
  }

  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param _newOwner The address to transfer ownership to.
   */
  function transferOwnership(address _newOwner) public onlyOwner {
    _transferOwnership(_newOwner);
  }

  /**
   * @dev Transfers control of the contract to a newOwner.
   * @param _newOwner The address to transfer ownership to.
   */
  function _transferOwnership(address _newOwner) internal {
    require(_newOwner != address(0));
    emit OwnershipTransferred(owner, _newOwner);
    owner = _newOwner;
  }
}

library SafeMath {

  /**
  * @dev Multiplies two numbers, throws on overflow.
  */
  function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
    // Gas optimization: this is cheaper than asserting 'a' not being zero, but the
    // benefit is lost if 'b' is also tested.
    // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
    if (a == 0) {
      return 0;
    }

    c = a * b;
    assert(c / a == b);
    return c;
  }

  /**
  * @dev Integer division of two numbers, truncating the quotient.
  */
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    // uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return a / b;
  }

  /**
  * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
  */
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  /**
  * @dev Adds two numbers, throws on overflow.
  */
  function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
    c = a + b;
    assert(c >= a);
    return c;
  }
}

contract EthBattle is Ownable {
    using SafeMath for uint256;

    uint256 constant TOKEN_USE_BONUS = 15; //%, adds weight of win on top of the market price
    uint256 constant REFERRAL_REWARD = 2 ether; // GTA, 10*19
    uint256 constant MIN_PLAY_AMOUNT = 50 finney; //wei, equal 0.05 ETH

    uint256 public roundIndex = 0;
    mapping(uint256 => address) public rounds;

    address[] private currentRewardingAddresses;

    PlaySeedInterface private playSeedGenerator;
    GTAInterface public token;
    AMUStoreInterface public store;

    mapping(address => address) public referralBacklog; //backlog of players and their referrals

    mapping(address => uint256) public tokens; //map of deposited tokens

    event RoundCreated(address createdAddress, uint256 index);
    event Deposit(address user, uint amount, uint balance);
    event Withdraw(address user, uint amount, uint balance);

    /**
    * @dev Default fallback function, just deposits funds to the pot
    */
    function () public payable {
        getLastRound().getDevWallet().transfer(msg.value);
    }

    /**
    * @dev The EthBattle constructor
    * @param _playSeedAddress address of the play seed generator
    * @param _tokenAddress GTA address
    * @param _storeAddress store contract address
    */
    constructor (address _playSeedAddress, address _tokenAddress, address _storeAddress) public {
        playSeedGenerator = PlaySeedInterface(_playSeedAddress);
        token = GTAInterface(_tokenAddress);
        store = AMUStoreInterface(_storeAddress);
    }

    /**
    * @dev Try (must be allowed by the seed generator itself) to claim ownership of the seed generator
    */
    function claimSeedOwnership() onlyOwner public {
        playSeedGenerator.claimOwnership();
    }

    /**
    * @dev Inject the new round contract, and sets the round with a new index
    * NOTE! Injected round must have had transferred ownership to this EthBattle already
    * @param _roundAddress address of the new round to use
    */
    function startRound(address _roundAddress) onlyOwner public {
        RoundInterface round = RoundInterface(_roundAddress);

        round.claimOwnership();

        roundIndex++;
        rounds[roundIndex] = round;
        emit RoundCreated(round, roundIndex);
    }


    /**
    * @dev Interrupts the round to enable participants to claim funds back
    */
    function interruptLastRound() onlyOwner public {
        getLastRound().enableRefunds();
    }

    /**
    * @dev End last round so no new plays is possible, but ongoing plays are fine to win
    */
    function finishLastRound() onlyOwner public {
        getLastRound().coolDown();
    }

    function getLastRound() public view returns (RoundInterface){
        return RoundInterface(rounds[roundIndex]);
    }

    function getLastRoundAddress() external view returns (address){
        return rounds[roundIndex];
    }

    /**
    * @dev Player starts a new play providing
    * @param _referral (Optional) referral address is any
    * @param _gtaBet (Optional) additional bet in GTA
    */
    function play(address _referral, uint256 _gtaBet) public payable {
        address player = msg.sender;
        uint256 weiAmount = msg.value;

        require(player != address(0), "Player's address is missing");
        require(weiAmount >= MIN_PLAY_AMOUNT, "The bet is too low");
        require(_gtaBet <= balanceOf(player), "Player's got not enough GTA");

        if (_referral != address(0) && referralBacklog[player] == address(0)) {
            //new referral for this player
            referralBacklog[player] = _referral;
            //reward the referral. Tokens remains in this contract
            //but become available for withdrawal by _referral
            transferInternally(owner, _referral, REFERRAL_REWARD);
        }

        playSeedGenerator.newPlaySeed(player);

        uint256 _bet = aggregateBet(weiAmount, _gtaBet);

        if (_gtaBet > 0) {
            //player's using GTA
            transferInternally(player, owner, _gtaBet);
        }

        if (referralBacklog[player] != address(0)) {
            //ongoing round might not know about the _referral
            //delegate the knowledge of the referral to the ongoing round
            getLastRound().setReferral(player, referralBacklog[player]);
        }
        getLastRound().playRound.value(msg.value)(player, _bet);
    }

    /**
    * @dev Player claims a win
    * @param _seed secret seed
    */
    function win(bytes32 _seed) public {
        address player = msg.sender;

        require(player != address(0), "Winner's address is missing");
        require(playSeedGenerator.findSeed(player) == _seed, "Wrong seed!");
        playSeedGenerator.cleanSeedUp(player);

        getLastRound().win(player);
    }

    function findSeedAuthorized(address player) onlyOwner public view returns (bytes32){
        return playSeedGenerator.findSeed(player);
    }

    function aggregateBet(uint256 _bet, uint256 _gtaBet) internal view returns (uint256) {
        //get market price of the GTA, multiply by bet, and apply a bonus on it.
        //since both 'price' and 'bet' are in 'wei', we need to drop 10*18 decimals at the end
        uint256 _gtaValueWei = store.getTokenBuyPrice().mul(_gtaBet).div(1 ether).mul(100 + TOKEN_USE_BONUS).div(100);

        //sum up with ETH bet
        uint256 _resultBet = _bet.add(_gtaValueWei);

        return _resultBet;
    }

    /**
    * @dev Calculates the prize amount for this player by now
    * Note: the result is not the final one and a subject to change once more plays/wins occur
    * @return The prize in wei
    */
    function prizeByNow() public view returns (uint256) {
        return getLastRound().currentPrize(msg.sender);
    }

    /**
    * @dev Calculates the prediction on the prize amount for this player and this bet
    * Note: the result is not the final one and a subject to change once more plays/wins occur
    * @param _bet hypothetical bet in wei
    * @param _gtaBet hypothetical bet in GTA
    * @return The prediction in wei
    */
    function prizeProjection(uint256 _bet, uint256 _gtaBet) public view returns (uint256) {
        return getLastRound().projectedPrizeForPlayer(msg.sender, aggregateBet(_bet, _gtaBet));
    }


    /**
    * @dev Deposit GTA to the EthBattle contract so it can be spent (used) immediately
    * Note: this call must follow the approve() call on the token itself
    * @param _amount amount to deposit
    */
    function depositGTA(uint256 _amount) public {
        require(token.transferFrom(msg.sender, this, _amount), "Insufficient funds");
        tokens[msg.sender] = tokens[msg.sender].add(_amount);
        emit Deposit(msg.sender, _amount, tokens[msg.sender]);
    }

    /**
    * @dev Withdraw GTA from this contract to the own (caller) address
    * @param _amount amount to withdraw
    */
    function withdrawGTA(uint256 _amount) public {
        require(tokens[msg.sender] >= _amount, "Amount exceeds the available balance");
        tokens[msg.sender] = tokens[msg.sender].sub(_amount);
        require(token.transfer(msg.sender, _amount), "Amount exceeds the available balance");
        emit Withdraw(msg.sender, _amount, tokens[msg.sender]);
    }

    /**
    * @dev Internal transfer of the token.
    * Funds remain in this contract but become available for withdrawal
    */
    function transferInternally(address _from, address _to, uint256 _amount) internal {
        require(tokens[_from] >= _amount, "Too much to transfer");
        tokens[_from] = tokens[_from].sub(_amount);
        tokens[_to] = tokens[_to].add(_amount);
    }

    function balanceOf(address _user) public view returns (uint256) {
        return tokens[_user];
    }

    function setPlaySeed(address _playSeedAddress) onlyOwner public {
        playSeedGenerator = PlaySeedInterface(_playSeedAddress);
    }

    function setStore(address _storeAddress) onlyOwner public {
        store = AMUStoreInterface(_storeAddress);
    }

    function getTokenBuyPrice() public view returns (uint256) {
        return store.getTokenBuyPrice();
    }

    function getTokenSellPrice() public view returns (uint256) {
        return store.getTokenSellPrice();
    }

    /**
    * @dev Recover the history of referrals in case of the contract migration.
    */
    function setReferralsMap(address[] _players, address[] _referrals) onlyOwner public {
        require(_players.length == _referrals.length, "Size of players must be equal to the size of referrals");
        for (uint i = 0; i < _players.length; ++i) {
            referralBacklog[_players[i]] = _referrals[i];
        }
    }

}

/**
 * @title PlaySeed contract interface
 */
interface PlaySeedInterface {

    function newPlaySeed(address _player) external;

    function findSeed(address _player) external view returns (bytes32);

    function cleanSeedUp(address _player) external;

    function claimOwnership() external;

}

/**
 * @title GTA contract interface
 */
interface GTAInterface {

    function transferFrom(address _from, address _to, uint256 _value) external returns (bool);

    function transfer(address to, uint256 value) external returns (bool);

}

/**
 * @title EthBattleRound contract interface
 */
interface RoundInterface {

    function claimOwnership() external;

    function setReferral(address _player, address _referral) external;

    function playRound(address _player, uint256 _bet) external payable;

    function enableRefunds() external;

    function coolDown() external;

    function currentPrize(address _player) external view returns (uint256);

    function projectedPrizeForPlayer(address _player, uint256 _bet) external view returns (uint256);

    function win(address _player) external;

    function getDevWallet() external view returns (address);

}

/**
 * @title Ammu-Nation contract interface
 */
interface AMUStoreInterface {

    function getTokenBuyPrice() external view returns (uint256);

    function getTokenSellPrice() external view returns (uint256);

}