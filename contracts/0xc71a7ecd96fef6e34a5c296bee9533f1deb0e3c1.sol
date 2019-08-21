pragma solidity 0.4.25;

library SafeMath {

    /**
     * @dev Multiplies two numbers, reverts on overflow.
     */
    function mul(uint256 _a, uint256 _b) internal pure returns(uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
        if (_a == 0) {
            return 0;
        }

        uint256 c = _a * _b;
        require(c / _a == _b);

        return c;
    }

    /**
     * @dev Integer division of two numbers truncating the quotient, reverts on division by zero.
     */
    function div(uint256 _a, uint256 _b) internal pure returns(uint256) {
        require(_b > 0); // Solidity only automatically asserts when dividing by 0
        uint256 c = _a / _b;
        // assert(_a == _b * c + _a % _b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Subtracts two numbers, reverts on overflow (i.e. if subtrahend is greater than minuend).
     */
    function sub(uint256 _a, uint256 _b) internal pure returns(uint256) {
        require(_b <= _a);
        uint256 c = _a - _b;

        return c;
    }

    /**
     * @dev Adds two numbers, reverts on overflow.
     */
    function add(uint256 _a, uint256 _b) internal pure returns(uint256) {
        uint256 c = _a + _b;
        require(c >= _a);

        return c;
    }

    /**
     * @dev Divides two numbers and returns the remainder (unsigned integer modulo),
     * reverts when dividing by zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns(uint256) {
        require(b != 0);
        return a % b;
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
   * @dev Renouncing to ownership will leave the contract without an owner.
   * It will not be possible to call the functions with the `onlyOwner`
   * modifier anymore.
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

interface IRemoteFunctions {
  function _externalAddMasternode(address) external;
  function _externalStopMasternode(address) external;
  function isMasternodeOwner(address) external view returns (bool);
  function userHasActiveNodes(address) external view returns (bool);
}

interface ICaelumMasternode {
    function _externalArrangeFlow() external;
    function rewardsProofOfWork() external view returns (uint) ;
    function rewardsMasternode() external view returns (uint) ;
    function masternodeIDcounter() external view returns (uint) ;
    function masternodeCandidate() external view returns (uint) ; 
    function getUserFromID(uint) external view returns  (address) ;
    function userCounter() external view returns(uint);
    function contractProgress() external view returns (uint, uint, uint, uint, uint, uint, uint, uint);
}

contract ERC20Basic {
    function totalSupply() public view returns(uint256);

    function balanceOf(address _who) public view returns(uint256);

    function transfer(address _to, uint256 _value) public returns(bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
}

contract ERC20 is ERC20Basic {
    function allowance(address _owner, address _spender) public view returns(uint256);

    function transferFrom(address _from, address _to, uint256 _value) public returns(bool);

    function approve(address _spender, uint256 _value) public returns(bool);

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

contract BasicToken is ERC20Basic {
    using SafeMath
    for uint256;

    mapping(address => uint256) internal balances;

    uint256 internal totalSupply_;

    /**
     * @dev Total number of tokens in existence
     */
    function totalSupply() public view returns(uint256) {
        return totalSupply_;
    }

    /**
     * @dev Transfer token for a specified address
     * @param _to The address to transfer to.
     * @param _value The amount to be transferred.
     */
    function transfer(address _to, uint256 _value) public returns(bool) {
        require(_value <= balances[msg.sender]);
        require(_to != address(0));

        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);
        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    /**
     * @dev Gets the balance of the specified address.
     * @param _owner The address to query the the balance of.
     * @return An uint256 representing the amount owned by the passed address.
     */
    function balanceOf(address _owner) public view returns(uint256) {
        return balances[_owner];
    }

}

contract StandardToken is ERC20, BasicToken {

    mapping(address => mapping(address => uint256)) internal allowed;


    /**
     * @dev Transfer tokens from one address to another
     * @param _from address The address which you want to send tokens from
     * @param _to address The address which you want to transfer to
     * @param _value uint256 the amount of tokens to be transferred
     */
    function transferFrom(
        address _from,
        address _to,
        uint256 _value
    )
    public
    returns(bool) {
        require(_value <= balances[_from]);
        require(_value <= allowed[_from][msg.sender]);
        require(_to != address(0));

        balances[_from] = balances[_from].sub(_value);
        balances[_to] = balances[_to].add(_value);
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
        emit Transfer(_from, _to, _value);
        return true;
    }

    /**
     * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.
     * Beware that changing an allowance with this method brings the risk that someone may use both the old
     * and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this
     * race condition is to first reduce the spender's allowance to 0 and set the desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     * @param _spender The address which will spend the funds.
     * @param _value The amount of tokens to be spent.
     */
    function approve(address _spender, uint256 _value) public returns(bool) {
        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    /**
     * @dev Function to check the amount of tokens that an owner allowed to a spender.
     * @param _owner address The address which owns the funds.
     * @param _spender address The address which will spend the funds.
     * @return A uint256 specifying the amount of tokens still available for the spender.
     */
    function allowance(
        address _owner,
        address _spender
    )
    public
    view
    returns(uint256) {
        return allowed[_owner][_spender];
    }

    /**
     * @dev Increase the amount of tokens that an owner allowed to a spender.
     * approve should be called when allowed[_spender] == 0. To increment
     * allowed value is better to use this function to avoid 2 calls (and wait until
     * the first transaction is mined)
     * From MonolithDAO Token.sol
     * @param _spender The address which will spend the funds.
     * @param _addedValue The amount of tokens to increase the allowance by.
     */
    function increaseApproval(
        address _spender,
        uint256 _addedValue
    )
    public
    returns(bool) {
        allowed[msg.sender][_spender] = (
            allowed[msg.sender][_spender].add(_addedValue));
        emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
        return true;
    }

    /**
     * @dev Decrease the amount of tokens that an owner allowed to a spender.
     * approve should be called when allowed[_spender] == 0. To decrement
     * allowed value is better to use this function to avoid 2 calls (and wait until
     * the first transaction is mined)
     * From MonolithDAO Token.sol
     * @param _spender The address which will spend the funds.
     * @param _subtractedValue The amount of tokens to decrease the allowance by.
     */
    function decreaseApproval(
        address _spender,
        uint256 _subtractedValue
    )
    public
    returns(bool) {
        uint256 oldValue = allowed[msg.sender][_spender];
        if (_subtractedValue >= oldValue) {
            allowed[msg.sender][_spender] = 0;
        } else {
            allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
        }
        emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
        return true;
    }

}

contract ERC20Interface {

    function totalSupply() public constant returns (uint);

    function balanceOf(address tokenOwner) public constant returns (uint balance);

    function allowance(address tokenOwner, address spender) public constant returns (uint remaining);

    function transfer(address to, uint tokens) public returns (bool success);

    function approve(address spender, uint tokens) public returns (bool success);

    function transferFrom(address from, address to, uint tokens) public returns (bool success);


    event Transfer(address indexed from, address indexed to, uint tokens);

    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);

}

contract InterfaceContracts is Ownable {
    InterfaceContracts public _internalMod;
    
    function setModifierContract (address _t) onlyOwner public {
        _internalMod = InterfaceContracts(_t);
    }

    modifier onlyMiningContract() {
      require(msg.sender == _internalMod._contract_miner(), "Wrong sender");
          _;
      }

    modifier onlyTokenContract() {
      require(msg.sender == _internalMod._contract_token(), "Wrong sender");
      _;
    }
    
    modifier onlyMasternodeContract() {
      require(msg.sender == _internalMod._contract_masternode(), "Wrong sender");
      _;
    }
    
    modifier onlyVotingOrOwner() {
      require(msg.sender == _internalMod._contract_voting() || msg.sender == owner, "Wrong sender");
      _;
    }
    
    modifier onlyVotingContract() {
      require(msg.sender == _internalMod._contract_voting() || msg.sender == owner, "Wrong sender");
      _;
    }
      
    function _contract_voting () public view returns (address) {
        return _internalMod._contract_voting();
    }
    
    function _contract_masternode () public view returns (address) {
        return _internalMod._contract_masternode();
    }
    
    function _contract_token () public view returns (address) {
        return _internalMod._contract_token();
    }
    
    function _contract_miner () public view returns (address) {
        return _internalMod._contract_miner();
    }
}

contract CaelumAcceptERC20  is InterfaceContracts {
    using SafeMath for uint;

    address[] public tokensList;
    bool setOwnContract = true;

    struct _whitelistTokens {
        address tokenAddress;
        bool active;
        uint requiredAmount;
        uint validUntil;
        uint timestamp;
    }

    mapping(address => mapping(address => uint)) public tokens;
    mapping(address => _whitelistTokens) acceptedTokens;

    event Deposit(address token, address user, uint amount, uint balance);
    event Withdraw(address token, address user, uint amount, uint balance);

    /**
     * @notice Allow the dev to set it's own token as accepted payment.
     * @dev Can be hardcoded in the constructor. Given the contract size, we decided to separate it.
     * @return bool
     */
    function addOwnToken() internal returns(bool) {
        require(setOwnContract);
        addToWhitelist(this, 5000 * 1e8, 36500);
        setOwnContract = false;
        return true;
    }


    /**
     * @notice Add a new token as accepted payment method.
     * @param _token Token contract address.
     * @param _amount Required amount of this Token as collateral
     * @param daysAllowed How many days will we accept this token?
     */
    function addToWhitelist(address _token, uint _amount, uint daysAllowed) internal {
        _whitelistTokens storage newToken = acceptedTokens[_token];
        newToken.tokenAddress = _token;
        newToken.requiredAmount = _amount;
        newToken.timestamp = now;
        newToken.validUntil = now + (daysAllowed * 1 days);
        newToken.active = true;

        tokensList.push(_token);
    }

    /**
     * @dev internal function to determine if we accept this token.
     * @param _ad Token contract address
     * @return bool
     */
    function isAcceptedToken(address _ad) internal view returns(bool) {
        return acceptedTokens[_ad].active;
    }

    /**
     * @dev internal function to determine the requiredAmount for a specific token.
     * @param _ad Token contract address
     * @return bool
     */
    function getAcceptedTokenAmount(address _ad) internal view returns(uint) {
        return acceptedTokens[_ad].requiredAmount;
    }

    /**
     * @dev internal function to determine if the token is still accepted timewise.
     * @param _ad Token contract address
     * @return bool
     */
    function isValid(address _ad) internal view returns(bool) {
        uint endTime = acceptedTokens[_ad].validUntil;
        if (block.timestamp < endTime) return true;
        return false;
    }

    /**
     * @notice Returns an array of all accepted token. You can get more details by calling getTokenDetails function with this address.
     * @return array Address
     */
    function listAcceptedTokens() public view returns(address[]) {
        return tokensList;
    }

    /**
     * @notice Returns a full list of the token details
     * @param token Token contract address
     */
    function getTokenDetails(address token) public view returns(address ad, uint required, bool active, uint valid) {
        return (acceptedTokens[token].tokenAddress, acceptedTokens[token].requiredAmount, acceptedTokens[token].active, acceptedTokens[token].validUntil);
    }

    /**
     * @notice Public function that allows any user to deposit accepted tokens as collateral to become a masternode.
     * @param token Token contract address
     * @param amount Amount to deposit
     */
    function depositCollateral(address token, uint amount) public {

        require(isAcceptedToken(token), "ERC20 not authorised"); // Should be a token from our list
        require(amount == getAcceptedTokenAmount(token)); // The amount needs to match our set amount
        require(isValid(token)); // It should be called within the setup timeframe


        tokens[token][msg.sender] = tokens[token][msg.sender].add(amount);
        emit Deposit(token, msg.sender, amount, tokens[token][msg.sender]);

        require(StandardToken(token).transferFrom(msg.sender, this, amount), "error with transfer");
        IRemoteFunctions(_contract_masternode())._externalAddMasternode(msg.sender);
    }

    /**
     * @notice Public function that allows any user to withdraw deposited tokens and stop as masternode
     * @param token Token contract address
     * @param amount Amount to withdraw
     */
    function withdrawCollateral(address token, uint amount) public {
        require(token != 0, "No token specified"); // token should be an actual address
        require(isAcceptedToken(token), "ERC20 not authorised"); // Should be a token from our list
        require(amount == getAcceptedTokenAmount(token)); // The amount needs to match our set amount, allow only one withdrawal at a time.
        uint amountToWithdraw = amount;

        tokens[token][msg.sender] = tokens[token][msg.sender] - amount;
        emit Withdraw(token, msg.sender, amountToWithdraw, amountToWithdraw);

        require(StandardToken(token).transfer(msg.sender, amountToWithdraw),"error with transfer");
        IRemoteFunctions(_contract_masternode())._externalStopMasternode(msg.sender);
    }

}

contract CaelumToken is CaelumAcceptERC20, StandardToken {
    using SafeMath for uint;

    ICaelumMasternode public masternodeInterface;

    bool public swapClosed = false;
    bool isOnTestNet = true;

    string public symbol = "CLM";
    string public name = "Caelum Token";
    uint8 public decimals = 8;
    uint256 public totalSupply = 2100000000000000;

    address allowedSwapAddress01 = 0x7600bF5112945F9F006c216d5d6db0df2806eDc6;
    address allowedSwapAddress02 = 0x16Da16948e5092A3D2aA71Aca7b57b8a9CFD8ddb;

    uint swapStartedBlock;

    mapping(address => uint) manualSwaps;
    mapping(address => bool) hasSwapped;

    event NewSwapRequest(address _swapper, uint _amount);
    event TokenSwapped(address _swapper, uint _amount);

    constructor() public {
        addOwnToken();
        swapStartedBlock = now;
    }

    /**
     * @dev Allow users to upgrade from our previous tokens.
     * For trust issues, addresses are hardcoded.
     * @param _token Token the user wants to swap.
     */
    function upgradeTokens(address _token) public {
        require(!hasSwapped[msg.sender], "User already swapped");
        require(now <= swapStartedBlock + 1 days, "Timeframe exipred, please use manualUpgradeTokens function");
        require(_token == allowedSwapAddress01 || _token == allowedSwapAddress02, "Token not allowed to swap.");

        uint amountToUpgrade = ERC20(_token).balanceOf(msg.sender);

        require(amountToUpgrade <= ERC20(_token).allowance(msg.sender, this));
        require(ERC20(_token).transferFrom(msg.sender, this, amountToUpgrade));
        require(ERC20(_token).balanceOf(msg.sender) == 0);

        tokens[_token][msg.sender] = tokens[_token][msg.sender].add(amountToUpgrade);
        balances[msg.sender] = balances[msg.sender].add(amountToUpgrade);

        emit Transfer(this, msg.sender, amountToUpgrade);
        emit TokenSwapped(msg.sender, amountToUpgrade);

        if(
          ERC20(allowedSwapAddress01).balanceOf(msg.sender) == 0  &&
          ERC20(allowedSwapAddress02).balanceOf(msg.sender) == 0
        ) {
          hasSwapped[msg.sender] = true;
        }

    }

    /**
     * @dev Allow users to upgrade manualy from our previous tokens.
     * For trust issues, addresses are hardcoded.
     * Used when a user failed to swap in time.
     * Dev should manually verify the origin of these tokens before allowing it.
     * @param _token Token the user wants to swap.
     */
    function manualUpgradeTokens(address _token) public {
        require(!hasSwapped[msg.sender], "User already swapped");
        require(now >= swapStartedBlock + 1 days, "Timeframe incorrect");
        require(_token == allowedSwapAddress01 || _token == allowedSwapAddress02, "Token not allowed to swap.");

        uint amountToUpgrade = ERC20(_token).balanceOf(msg.sender);
        require(amountToUpgrade <= ERC20(_token).allowance(msg.sender, this));

        if (ERC20(_token).transferFrom(msg.sender, this, amountToUpgrade)) {
            require(ERC20(_token).balanceOf(msg.sender) == 0);
            if(
              ERC20(allowedSwapAddress01).balanceOf(msg.sender) == 0  &&
              ERC20(allowedSwapAddress02).balanceOf(msg.sender) == 0
            ) {
              hasSwapped[msg.sender] = true;
            }

            tokens[_token][msg.sender] = tokens[_token][msg.sender].add(amountToUpgrade);
            manualSwaps[msg.sender] = amountToUpgrade;
            emit NewSwapRequest(msg.sender, amountToUpgrade);
        }
    }

    /**
     * @dev Allow users to partially upgrade manualy from our previous tokens.
     * For trust issues, addresses are hardcoded.
     * Used when a user failed to swap in time.
     * Dev should manually verify the origin of these tokens before allowing it.
     * @param _token Token the user wants to swap.
     */
    function manualUpgradePartialTokens(address _token, uint _amount) public {
        require(!hasSwapped[msg.sender], "User already swapped");
        require(now >= swapStartedBlock + 1 days, "Timeframe incorrect");
        require(_token == allowedSwapAddress01 || _token == allowedSwapAddress02, "Token not allowed to swap.");

        uint amountToUpgrade = _amount; //ERC20(_token).balanceOf(msg.sender);
        require(amountToUpgrade <= ERC20(_token).allowance(msg.sender, this));

        uint newBalance = ERC20(_token).balanceOf(msg.sender) - (amountToUpgrade);
        if (ERC20(_token).transferFrom(msg.sender, this, amountToUpgrade)) {

            require(ERC20(_token).balanceOf(msg.sender) == newBalance, "Balance error.");

            if(
              ERC20(allowedSwapAddress01).balanceOf(msg.sender) == 0  &&
              ERC20(allowedSwapAddress02).balanceOf(msg.sender) == 0
            ) {
              hasSwapped[msg.sender] = true;
            }

            tokens[_token][msg.sender] = tokens[_token][msg.sender].add(amountToUpgrade);
            manualSwaps[msg.sender] = amountToUpgrade;
            emit NewSwapRequest(msg.sender, amountToUpgrade);
        }
    }

    /**
     * @dev Due to some bugs in the previous contracts, a handfull of users will
     * be unable to fully withdraw their masternodes. Owner can replace those tokens
     * who are forever locked up in the old contract with new ones.
     */
     function getLockedTokens(address _contract, address _holder) public view returns(uint) {
         return CaelumAcceptERC20(_contract).tokens(_contract, _holder);
     }

    /**
     * @dev Approve a request for manual token swaps
     * @param _holder Holder The user who requests a swap.
     */
    function approveManualUpgrade(address _holder) onlyOwner public {
        balances[_holder] = balances[_holder].add(manualSwaps[_holder]);
        emit Transfer(this, _holder, manualSwaps[_holder]);
    }

    /**
     * @dev Decline a request for manual token swaps
     * @param _holder Holder The user who requests a swap.
     */
    function declineManualUpgrade(address _token, address _holder) onlyOwner public {
        require(ERC20(_token).transfer(_holder, manualSwaps[_holder]));
        tokens[_token][_holder] = tokens[_token][_holder] - manualSwaps[_holder];
        delete manualSwaps[_holder];
        delete hasSwapped[_holder];
    }

    /**
     * @dev Due to some bugs in the previous contracts, a handfull of users will
     * be unable to fully withdraw their masternodes. Owner can replace those tokens
     * who are forever locked up in the old contract with new ones.
     */
     function replaceLockedTokens(address _contract, address _holder) onlyOwner public {
         uint amountLocked = getLockedTokens(_contract, _holder);
         balances[_holder] = balances[_holder].add(amountLocked);
         emit Transfer(this, _holder, amountLocked);
         hasSwapped[msg.sender] = true;
     }

    /**
     * @dev Used to grant the mining contract rights to reward users.
     * As our contracts are separate, we call this function with modifier onlyMiningContract to sent out rewards.
     * @param _receiver Who receives the mining reward.
     * @param _amount What amount to reward.
     */
    function rewardExternal(address _receiver, uint _amount) onlyMiningContract public {
        balances[_receiver] = balances[_receiver].add(_amount);
        emit Transfer(this, _receiver, _amount);
    }

    /**
     * @dev We allow the masternodecontract to add tokens to our whitelist. By this approach,
     * we can move all voting logic to a contract that can be upgraden when needed.
     */
    function addToWhitelistExternal(address _token, uint _amount, uint daysAllowed) onlyMasternodeContract public {
        addToWhitelist( _token, _amount, daysAllowed);
    }

    /**
     * @dev Fetch data from the actual reward. We do this to prevent pools payout out
     * the global reward instead of the calculated ones.
     * By default, pools fetch the `getMiningReward()` value and will payout this amount.
     */
    function getMiningRewardForPool() public view returns(uint) {
        return masternodeInterface.rewardsProofOfWork();
    }

    /**
     * @dev Return the Proof of Work reward from the masternode contract.
     */
    function rewardsProofOfWork() public view returns(uint) {
        return masternodeInterface.rewardsProofOfWork();
    }

    /**
     * @dev Return the masternode reward from the masternode contract.
     */
    function rewardsMasternode() public view returns(uint) {
        return masternodeInterface.rewardsMasternode();
    }

    /**
     * @dev Return the number of masternodes from the masternode contract.
     */
    function masternodeCounter() public view returns(uint) {
        return masternodeInterface.userCounter();
    }

    /**
     * @dev Return the general state from the masternode contract.
     */
    function contractProgress() public view returns
    (
        uint epoch,
        uint candidate,
        uint round,
        uint miningepoch,
        uint globalreward,
        uint powreward,
        uint masternodereward,
        uint usercounter
    )
    {
        return ICaelumMasternode(_contract_masternode()).contractProgress();

    }

    /**
     * @dev pull new masternode contract from the modifier contract
     */
    function setMasternodeContract() internal  {
        masternodeInterface = ICaelumMasternode(_contract_masternode());
    }

    /**
     * Override; For some reason, truffle testing does not recognize function.
     * Remove before live?
     */
    function setModifierContract (address _contract) onlyOwner public {
        require (now <= swapStartedBlock + 10 days);
        _internalMod = InterfaceContracts(_contract);
        setMasternodeContract();
    }

    /**
    * @dev Move the voting away from token. All votes will be made from the voting
    */
    function VoteModifierContract (address _contract) onlyVotingContract external {
        //_internalMod = CaelumModifierAbstract(_contract);
        _internalMod = InterfaceContracts(_contract);
        setMasternodeContract();
    }
    
    /**
     * Owner can transfer out any accidentally sent ERC20 tokens
     */
    function transferAnyERC20Token(address tokenAddress, uint tokens) public onlyOwner returns (bool success) {
        return ERC20Interface(tokenAddress).transfer(owner, tokens);
    }

    /**
     * @dev Needed for testnet only. Comment codeblock out before deploy, leave it as example.
     */
    /** 
    function setSwap(address _contract, address _contract_2) onlyOwner public {
        require (isOnTestNet == true);
        allowedSwapAddress01 = _contract;
        allowedSwapAddress02 = _contract_2;
    }
    */


}