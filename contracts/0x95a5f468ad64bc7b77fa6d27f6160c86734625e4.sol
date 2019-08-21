// produced by the Solididy File Flattener (c) David Appleton 2018
// contact : dave@akomba.com
// released under Apache 2.0 licence
library Roles {
  struct Role {
    mapping (address => bool) bearer;
  }

  /**
   * @dev give an address access to this role
   */
  function add(Role storage role, address addr)
    internal
  {
    role.bearer[addr] = true;
  }

  /**
   * @dev remove an address' access to this role
   */
  function remove(Role storage role, address addr)
    internal
  {
    role.bearer[addr] = false;
  }

  /**
   * @dev check if an address has this role
   * // reverts
   */
  function check(Role storage role, address addr)
    view
    internal
  {
    require(has(role, addr));
  }

  /**
   * @dev check if an address has this role
   * @return bool
   */
  function has(Role storage role, address addr)
    view
    internal
    returns (bool)
  {
    return role.bearer[addr];
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

contract RefundVault is Ownable {
  using SafeMath for uint256;

  enum State { Active, Refunding, Closed }

  mapping (address => uint256) public deposited;
  address public wallet;
  State public state;

  event Closed();
  event RefundsEnabled();
  event Refunded(address indexed beneficiary, uint256 weiAmount);

  /**
   * @param _wallet Vault address
   */
  constructor(address _wallet) public {
    require(_wallet != address(0));
    wallet = _wallet;
    state = State.Active;
  }

  /**
   * @param investor Investor address
   */
  function deposit(address investor) onlyOwner public payable {
    require(state == State.Active);
    deposited[investor] = deposited[investor].add(msg.value);
  }

  function close() onlyOwner public {
    require(state == State.Active);
    state = State.Closed;
    emit Closed();
    wallet.transfer(address(this).balance);
  }

  function enableRefunds() onlyOwner public {
    require(state == State.Active);
    state = State.Refunding;
    emit RefundsEnabled();
  }

  /**
   * @param investor Investor address
   */
  function refund(address investor) public {
    require(state == State.Refunding);
    uint256 depositedValue = deposited[investor];
    deposited[investor] = 0;
    investor.transfer(depositedValue);
    emit Refunded(investor, depositedValue);
  }
}

contract Claimable is Ownable {
  address public pendingOwner;

  /**
   * @dev Modifier throws if called by any account other than the pendingOwner.
   */
  modifier onlyPendingOwner() {
    require(msg.sender == pendingOwner);
    _;
  }

  /**
   * @dev Allows the current owner to set the pendingOwner address.
   * @param newOwner The address to transfer ownership to.
   */
  function transferOwnership(address newOwner) onlyOwner public {
    pendingOwner = newOwner;
  }

  /**
   * @dev Allows the pendingOwner address to finalize the transfer.
   */
  function claimOwnership() onlyPendingOwner public {
    emit OwnershipTransferred(owner, pendingOwner);
    owner = pendingOwner;
    pendingOwner = address(0);
  }
}

contract RBAC {
  using Roles for Roles.Role;

  mapping (string => Roles.Role) private roles;

  event RoleAdded(address addr, string roleName);
  event RoleRemoved(address addr, string roleName);

  /**
   * @dev reverts if addr does not have role
   * @param addr address
   * @param roleName the name of the role
   * // reverts
   */
  function checkRole(address addr, string roleName)
    view
    public
  {
    roles[roleName].check(addr);
  }

  /**
   * @dev determine if addr has role
   * @param addr address
   * @param roleName the name of the role
   * @return bool
   */
  function hasRole(address addr, string roleName)
    view
    public
    returns (bool)
  {
    return roles[roleName].has(addr);
  }

  /**
   * @dev add a role to an address
   * @param addr address
   * @param roleName the name of the role
   */
  function addRole(address addr, string roleName)
    internal
  {
    roles[roleName].add(addr);
    emit RoleAdded(addr, roleName);
  }

  /**
   * @dev remove a role from an address
   * @param addr address
   * @param roleName the name of the role
   */
  function removeRole(address addr, string roleName)
    internal
  {
    roles[roleName].remove(addr);
    emit RoleRemoved(addr, roleName);
  }

  /**
   * @dev modifier to scope access to a single role (uses msg.sender as addr)
   * @param roleName the name of the role
   * // reverts
   */
  modifier onlyRole(string roleName)
  {
    checkRole(msg.sender, roleName);
    _;
  }

  /**
   * @dev modifier to scope access to a set of roles (uses msg.sender as addr)
   * @param roleNames the names of the roles to scope access to
   * // reverts
   *
   * @TODO - when solidity supports dynamic arrays as arguments to modifiers, provide this
   *  see: https://github.com/ethereum/solidity/issues/2467
   */
  // modifier onlyRoles(string[] roleNames) {
  //     bool hasAnyRole = false;
  //     for (uint8 i = 0; i < roleNames.length; i++) {
  //         if (hasRole(msg.sender, roleNames[i])) {
  //             hasAnyRole = true;
  //             break;
  //         }
  //     }

  //     require(hasAnyRole);

  //     _;
  // }
}

contract RoundVault is RefundVault {

    uint256 constant DEV_FUND_COMMISSION = 4; //%

    uint256 public totalRoundPrize;
    uint256 public finalCumulativeWeight;

    StartersProxyInterface public startersProxy;

    event RewardWinner(address player, uint256 weiAmount, uint256 kPercent);

    constructor(address _devFundWallet, address _proxyAddress) RefundVault(_devFundWallet) public {
        startersProxy = StartersProxyInterface(_proxyAddress);
    }

    /**
    * @dev Pays actual ETH to the winner
    */
    function reward(address _winner, uint256 _personalWeight) onlyOwner public {
        //millions of % for better precision
        uint256 _portion = _personalWeight.mul(100000000).div(finalCumulativeWeight);

        //wei
        uint256 _prizeWei = totalRoundPrize.mul(_portion).div(100000000);

        require(address(this).balance > _prizeWei, "Vault run out of funds!");

        if (isContract(_winner)) {
            //do noting
            //bad guy, punish this hacking attempt
        } else {
            //check if any debt player has
            uint256 _personalDept = startersProxy.debt(_winner);
            if (_personalDept > 0) {
                uint256 _toRepay = _personalDept;
                if (_prizeWei < _personalDept) {
                    //don't repay more than won
                    _toRepay = _prizeWei;
                }
                startersProxy.payDebt.value(_toRepay)(_winner);
                //anything left to reward with?
                if (_prizeWei.sub(_toRepay) > 0) {
                    _winner.transfer(_prizeWei.sub(_toRepay));
                }
            } else {
                _winner.transfer(_prizeWei);
            }
        }

        emit RewardWinner(_winner, _prizeWei, _portion);
    }

    function isContract(address _address) internal view returns (bool) {
        uint size;
        assembly { size := extcodesize(_address) }
        return size > 0;
    }

    function personalPrizeByNow(uint256 _personalWeight, uint256 _roundCumulativeWeigh) onlyOwner public view returns (uint256){
        if (_roundCumulativeWeigh == 0) {
            //no wins in this round yet
            return 0;
        }
        //millions of % for better precision
        uint256 _portion = _personalWeight.mul(100000000).div(_roundCumulativeWeigh);
        //wei
        return totalPrizePot().mul(_portion).div(100000000);
    }

    function personalPrizeWithBet(uint256 _personalWeight, uint256 _roundCumulativeWeight, uint256 _bet) onlyOwner public view returns (uint256){
        if (_roundCumulativeWeight == 0) {
            //no wins in this round yet
            _roundCumulativeWeight = _personalWeight;
        } else {
            //assuming cumulativeWeight
            _roundCumulativeWeight = _roundCumulativeWeight.add(_personalWeight);
        }
        uint256 _portion = _personalWeight.mul(100).div(_roundCumulativeWeight);

        //wei
        uint256 _assumingPersonalAdditionToPot = _bet.mul(100 - DEV_FUND_COMMISSION).div(100);
        uint256 _assumingPrizePot = totalPrizePot().add(_assumingPersonalAdditionToPot);

        return _assumingPrizePot.mul(_portion).div(100);
    }

    function totalPrizePot() internal view returns (uint256) {
        return address(this).balance.mul(100 - DEV_FUND_COMMISSION).div(100);
    }

    function sumUp(uint256 _weight) onlyOwner public {
        finalCumulativeWeight = _weight;
        totalRoundPrize = totalPrizePot();
    }

    function terminate() onlyOwner public {
        state = State.Active;
        super.close();
    }

    function getWallet() public view returns (address) {
        return wallet;
    }

    function getDevFundAddress() public view returns (address){
        return wallet;
    }
}

interface StartersProxyInterface {

    function debt(address signer) external view returns (uint256);

    function payDebt(address signer) external payable;
}

contract Whitelist is Ownable, RBAC {
  event WhitelistedAddressAdded(address addr);
  event WhitelistedAddressRemoved(address addr);

  string public constant ROLE_WHITELISTED = "whitelist";

  /**
   * @dev Throws if called by any account that's not whitelisted.
   */
  modifier onlyWhitelisted() {
    checkRole(msg.sender, ROLE_WHITELISTED);
    _;
  }

  /**
   * @dev add an address to the whitelist
   * @param addr address
   * @return true if the address was added to the whitelist, false if the address was already in the whitelist
   */
  function addAddressToWhitelist(address addr)
    onlyOwner
    public
  {
    addRole(addr, ROLE_WHITELISTED);
    emit WhitelistedAddressAdded(addr);
  }

  /**
   * @dev getter to determine if address is in whitelist
   */
  function whitelist(address addr)
    public
    view
    returns (bool)
  {
    return hasRole(addr, ROLE_WHITELISTED);
  }

  /**
   * @dev add addresses to the whitelist
   * @param addrs addresses
   * @return true if at least one address was added to the whitelist,
   * false if all addresses were already in the whitelist
   */
  function addAddressesToWhitelist(address[] addrs)
    onlyOwner
    public
  {
    for (uint256 i = 0; i < addrs.length; i++) {
      addAddressToWhitelist(addrs[i]);
    }
  }

  /**
   * @dev remove an address from the whitelist
   * @param addr address
   * @return true if the address was removed from the whitelist,
   * false if the address wasn't in the whitelist in the first place
   */
  function removeAddressFromWhitelist(address addr)
    onlyOwner
    public
  {
    removeRole(addr, ROLE_WHITELISTED);
    emit WhitelistedAddressRemoved(addr);
  }

  /**
   * @dev remove addresses from the whitelist
   * @param addrs addresses
   * @return true if at least one address was removed from the whitelist,
   * false if all addresses weren't in the whitelist in the first place
   */
  function removeAddressesFromWhitelist(address[] addrs)
    onlyOwner
    public
  {
    for (uint256 i = 0; i < addrs.length; i++) {
      removeAddressFromWhitelist(addrs[i]);
    }
  }

}

contract EthBattleRound is Whitelist, Claimable {
    using SafeMath for uint256;

    uint256 public constant SMART_ASS_COEFFICIENT = 5; //%
    uint256 public constant REFERRAL_BONUS = 1; //%

    // refund vault used to hold funds while round is running.
    // Can allow claiming of ETH back to participants if something went wrong
    RoundVault public vault;

    event Play(address player, uint256 bet, address referral, address round);
    event Win(address player, address round);
    event Reward(uint256 counter, address winner);
    event Finalize(uint256 count);
    event CoolDown(uint256 winCount);

    //Active - can play
    //CoolingDown - can't play but still can win
    //Rewarding - neither plays nor wins possible, it's in the state of paying rewards
    //Closed - rewarding is over, fund is empty
    enum State {Active, CoolingDown, Rewarding, Closed}
    State private state;

    uint256 public roundCumulativeWeight;
    uint256 public winCount;   //facts
    uint256 public winnerCount; //players
    uint256 public rewardCount;

    uint256 public roundSwapLimit = 200; //the default 'win' counter triggering the round swap

    //backlog of winners counting their wins
    mapping(address => uint256) public winnersBacklog;

    //backlog of players and their referrals
    mapping(address => address) public referralBacklog;
    //players and their last bets
    mapping(address => uint256) public lastBetWei;
    //players and their cumulative wins weight in the round
    mapping(address => uint256) public playerWinWeight;
    //rewarded winners
    mapping(address => bool) public rewardedWinners;


    /**
    * @dev Default fallback function, just deposits funds to the pot
    */
    function () public payable {
        vault.getWallet().transfer(msg.value);
    }

    /**
    * @dev Constructor, creates EthBattleRound.
    * @param _devFundWallet Development funds wallet to store a portion of funds once round is over
    * @param _battleAddress EthBattle address
    * @param _rewardingAddrs addresses authorized to pay the rewards
    */
    constructor (address _devFundWallet, address _battleAddress, address[] _rewardingAddrs, address _proxyAddress) public {
        vault = new RoundVault(_devFundWallet, _proxyAddress);

        addAddressToWhitelist(_battleAddress);

        addAddressesToWhitelist(_rewardingAddrs);

        state = State.Active;
    }

    function isActive() public view returns (bool){
        return state == State.Active;
    }

    /**
    * @dev Enable the refunds to players can claim back their bets
    */
    function enableRefunds() onlyOwner public {
        require(isActive() || isCoolingDown(), "Round must be active");
        vault.enableRefunds();
    }

    /**
    * @dev Last resort, terminate the round from any state
    */
    function terminate() external onlyWhitelisted {
        //from any state
        vault.terminate();
        state = State.Closed;
    }

    /**
    * @dev Every player, if enabled, can claim refund
    */
    function claimRefund() public {
        vault.refund(msg.sender);
    }


    function coolDown() onlyOwner public {
        require(isActive() || isCoolingDown(), "Round must be active");
        state = State.CoolingDown;
        emit CoolDown(winCount);
    }

    function isCoolingDown() public view returns (bool){
        return state == State.CoolingDown;
    }

    function startRewarding() external onlyWhitelisted {
        require(isCoolingDown(), "Cool it down first");
        vault.sumUp(roundCumulativeWeight);

        state = State.Rewarding;
    }

    function isRewarding() public view returns (bool){
        return state == State.Rewarding;
    }

    function playRound(address _player, uint256 _bet) onlyOwner public payable {
        require(isActive(), "Not active anymore");

        lastBetWei[_player] = _bet;

        uint256 _thisBet = msg.value;
        if (referralBacklog[_player] != address(0)) {
            //this player used a referral link once, split the bet
            uint256 _referralReward = _thisBet.mul(REFERRAL_BONUS).div(100);
            if (isContract(referralBacklog[_player])) {
                //do noting
                //bad guy, punish this hacking attempt
                vault.getDevFundAddress().transfer(_referralReward);
            } else {
                referralBacklog[_player].transfer(_referralReward);
            }
            _thisBet = _thisBet.sub(_referralReward);
        }

        vault.deposit.value(_thisBet)(_player);

        emit Play(_player, _thisBet, referralBacklog[_player], address(this));

    }

    function win(address _player) onlyOwner public {
        require(isActive() || isCoolingDown(), "Round must be active or cooling down");

        require(lastBetWei[_player] > 0, "Hmm, did this player call 'play' before?");

        uint256 _thisWinWeight = applySmartAssCorrection(_player, lastBetWei[_player]);

        recordWinFact(_player, _thisWinWeight);
    }

    /**
    * @dev Prize right now, if the payment would have happened immediately
    */
    function currentPrize(address _player) onlyOwner public view returns (uint256) {
        //calculate depending on personal weight and the total weight so far
        return vault.personalPrizeByNow(playerWinWeight[_player], roundCumulativeWeight);
    }

    /**
    * @dev Project the prize if this were the last game and the payment would take place right after this win
    * NOTE: Doesn't apply the referral's correction
    */
    function projectedPrizeForPlayer(address _player, uint256 _bet) onlyOwner public view returns (uint256) {
        uint256 _projectedPersonalWeight = applySmartAssCorrection(_player, _bet);
        //calculate depending on personal weight and the total weight so far
        return vault.personalPrizeWithBet(_projectedPersonalWeight, roundCumulativeWeight, _bet);
    }

    function recordWinFact(address _player, uint256 _winWeight) internal {
        if (playerWinWeight[_player] == 0) {
            //new winner
            winnerCount++;
        }
        winCount++;
        playerWinWeight[_player] = playerWinWeight[_player].add(_winWeight);
        roundCumulativeWeight = roundCumulativeWeight.add(_winWeight);

        winnersBacklog[_player] = winnersBacklog[_player].add(1);
        if (winCount == roundSwapLimit) {
            //this round is over. Cool down.
            coolDown();
        }
        emit Win(_player, address(this));
    }

    function applySmartAssCorrection(address _player, uint256 _bet) internal view returns (uint256){
        if (winnersBacklog[_player] > 0) {
            //has won before, or he's a referral and got his fee before
            uint256 _personalWinCount = winnersBacklog[_player];
            if (_personalWinCount > 10) {
                //even if more than 10 wins limit decrease to 10 * SMART_ASS_COEFFICIENT
                _personalWinCount = 10;
            }
            _bet = _bet.mul(100 - _personalWinCount.mul(SMART_ASS_COEFFICIENT)).div(100);
        }
        return _bet;
    }

    function rewardWinner(address _winner) external onlyWhitelisted {
        require(state == State.Rewarding, "Round in not in 'Rewarding' state yet");
        require(playerWinWeight[_winner] > 0, "This player hasn't actually won anything");
        require(!rewardedWinners[_winner], "This player has been rewarded already");

        vault.reward(_winner, playerWinWeight[_winner]);

        rewardedWinners[_winner] = true;
        rewardCount++;
        emit Reward(rewardCount, _winner);
    }

    function setReferral(address _player, address _referral) onlyOwner public {
        if (referralBacklog[_player] == address(0)) {
            referralBacklog[_player] = _referral;
        }
    }

    function finalizeRound() external onlyWhitelisted {
        require(state == State.Rewarding, "The round must be in 'Rewarding' state");
        isAllWinnersRewarded();

        //vault leftover moves the funds to the dev funds wallet
        vault.close();

        state = State.Closed;
        emit Finalize(rewardCount);
    }

    function isContract(address _address) internal view returns (bool) {
        uint size;
        assembly { size := extcodesize(_address) }
        return size > 0;
    }

    function isClosed() public view returns (bool){
        return state == State.Closed;
    }

    function isAllWinnersRewarded() public view returns (bool){
        return winnerCount == rewardCount;
    }

    function getVault() public view returns (RoundVault) {
        return vault;
    }

    function getDevWallet() public view returns (address) {
        return vault.getWallet();
    }

    function setRoundSwapLimit(uint256 _newLimit) external onlyWhitelisted {
        roundSwapLimit = _newLimit;
    }


}