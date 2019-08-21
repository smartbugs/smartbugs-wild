pragma solidity ^0.4.24;


/*
   ________  _____    ____  ____  _______    _   __   __________  __    ____ 
  / ____/ / / /   |  / __ \/ __ \/  _/   |  / | / /  / ____/ __ \/ /   / __ \
 / / __/ / / / /| | / /_/ / / / // // /| | /  |/ /  / / __/ / / / /   / / / /
/ /_/ / /_/ / ___ |/ _, _/ /_/ // // ___ |/ /|  /  / /_/ / /_/ / /___/ /_/ / 
\____/\____/_/  |_/_/ |_/_____/___/_/  |_/_/ |_/   \____/\____/_____/_____/  


*/
      
//  Guardian Gold Token
//  https://guardian-gold.com
//  https://guardian-gold.com/exchange.html
//  Launch Jan 30, 2019  22:00 UTC
// 
//  Gold Backed Cryptocurrency with Proof of Stake Rewards
//  1 GGT = 1 Gram of Physical Gold
//  NO Transaction Fees
//  NO Gold Storage Fees


contract ERC20Basic {
    function totalSupply() public view returns (uint256);
    function allowance(address tokenOwner, address spender) public view returns (uint remaining);
    function balanceOf(address who) public view returns (uint256);
    function approve(address spender, uint tokens) public returns (bool success);
    function transfer(address to, uint256 value) public returns (bool);
    function transferFrom(address from, address to, uint tokens) public returns (bool success);

    event Transfer(address indexed from, address indexed to, uint256 tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
    event Buy(address to, uint amount);
    event onWithdraw(
        address indexed customerAddress,
        uint256 ethereumWithdrawn
    );
    event onGoldAccountWithdraw(
        uint256 ethereumWithdrawn
    );
    event onOpAccountWithdraw(
        uint256 ethereumWithdrawn
    );
    event onTokenSale(
        address indexed customerAddress,
        uint256 amount
    );
    event onTokenRedeem(
        address indexed customerAddress,
        uint256 amount
    );
}

contract ApproveAndCallFallBack {
    function receiveApproval(address from, uint256 tokens, address token, bytes memory data) public;
}

library SafeMath {

  /**
  * @dev Multiplies two numbers, throws on overflow.
  */
    function mul(uint256 a, uint256 b) internal pure returns (uint256 c) 
        {
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

contract BasicToken is ERC20Basic {
  using SafeMath for uint256;

  mapping(address => uint256) balances;

  uint256 totalSupply_;

  /**
  * @dev Total number of tokens in existence
  */
  function totalSupply() public view returns (uint256) {
    return totalSupply_;
  }

  /**
  * @dev Transfer token for a specified address
  * @param _to The address to transfer to.
  * @param _value The amount to be transferred.
  */
  function transfer(address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));
    require(_value <= balances[msg.sender]);

    //if(myDividends() > 0) withdraw();

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
  function balanceOf(address _owner) public view returns (uint256) {
    return balances[_owner];
  }

}

contract MultiSigTransfer is Ownable {
  string public name = "MultiSigTransfer";
  string public symbol = "MST";
  bool public complete = false;
  bool public denied = false;
  uint256 public quantity;
  address public targetAddress;
  address public requesterAddress;

  /**
  * @dev The multisig transfer contract ensures that no single administrator can
  * GGTs without approval of another administrator
  * @param _quantity The number of GGT to transfer
  * @param _targetAddress The receiver of the GGTs
  * @param _requesterAddress The administrator requesting the transfer
  */
  constructor(
    uint256 _quantity,
    address _targetAddress,
    address _requesterAddress
  ) public {
    quantity = _quantity;
    targetAddress = _targetAddress;
    requesterAddress = _requesterAddress;
  }

  /**
  * @dev Mark the transfer as approved / complete
  */
  function approveTransfer() public onlyOwner {
    require(denied == false, "cannot approve a denied transfer");
    require(complete == false, "cannot approve a complete transfer");
    complete = true;
  }

  /**
  * @dev Mark the transfer as denied
  */
  function denyTransfer() public onlyOwner {
    require(denied == false, "cannot deny a transfer that is already denied");
    denied = true;
  }

  /**
  * @dev Determine if the transfer is pending
  */
  function isPending() public view returns (bool) {
    return !complete;
  }
}

contract RBAC {
  using Roles for Roles.Role;

  mapping (string => Roles.Role) private roles;

  event RoleAdded(address indexed operator, string role);
  event RoleRemoved(address indexed operator, string role);

  /**
   * @dev reverts if addr does not have role
   * @param _operator address
   * @param _role the name of the role
   * // reverts
   */
  function checkRole(address _operator, string _role)
    view
    public
  {
    roles[_role].check(_operator);
  }

  /**
   * @dev determine if addr has role
   * @param _operator address
   * @param _role the name of the role
   * @return bool
   */
  function hasRole(address _operator, string _role)
    view
    public
    returns (bool)
  {
    return roles[_role].has(_operator);
  }

  /**
   * @dev add a role to an address
   * @param _operator address
   * @param _role the name of the role
   */
  function addRole(address _operator, string _role)
    internal
  {
    roles[_role].add(_operator);
    emit RoleAdded(_operator, _role);
  }

  /**
   * @dev remove a role from an address
   * @param _operator address
   * @param _role the name of the role
   */
  function removeRole(address _operator, string _role)
    internal
  {
    roles[_role].remove(_operator);
    emit RoleRemoved(_operator, _role);
  }

  /**
   * @dev modifier to scope access to a single role (uses msg.sender as addr)
   * @param _role the name of the role
   * // reverts
   */
  modifier onlyRole(string _role)
  {
    checkRole(msg.sender, _role);
    _;
  }

  /**
   * @dev modifier to scope access to a set of roles (uses msg.sender as addr)
   * @param _roles the names of the roles to scope access to
   * // reverts
   *
   * @TODO - when solidity supports dynamic arrays as arguments to modifiers, provide this
   *  see: https://github.com/ethereum/solidity/issues/2467
   */
  // modifier onlyRoles(string[] _roles) {
  //     bool hasAnyRole = false;
  //     for (uint8 i = 0; i < _roles.length; i++) {
  //         if (hasRole(msg.sender, _roles[i])) {
  //             hasAnyRole = true;
  //             break;
  //         }
  //     }

  //     require(hasAnyRole);

  //     _;
  // }
}

contract GuardianGoldToken is BasicToken, Ownable, RBAC {
    string public name = "GuardianGoldToken";
    string public symbol = "GGT";
    uint8 public decimals = 18;
    string public constant ADMIN_ROLE = "ADMIN";

    uint256 constant internal magnitude = 2**64;

    uint public maxTokens = 5000e18;

    mapping(address => uint256) internal tokenBalanceLedger_;
    mapping(address => int256) internal payoutsTo_;
    mapping(address => uint256) internal referralBalance_;
    mapping(address => mapping (address => uint256)) allowed;

    uint public goldAccount = 0;
    uint public operationsAccount = 0;

    uint256 internal profitPerShare_;

    address[] public transfers;

    uint public constant INITIAL_SUPPLY = 62207e15; 
    uint public totalSupply = 62207e15;
    uint public totalGoldReserves = 62207e15;
    uint public pendingGold = 0;
    uint public totalETHReceived = 57.599 ether;

    bool public isTransferable = true;
    bool public toggleTransferablePending = false;
    address public transferToggleRequester = address(0);

    uint public tokenPrice = 0.925925 ether;
    uint public goldPrice = 0.390185 ether;

    uint public tokenSellDiscount = 950;  //95%
    uint public referralFee = 30;  //3%

    uint minGoldPrice = 0.2 ether;
    uint maxGoldPrice = 0.7 ether;

    uint minTokenPrice = 0.5 ether;
    uint maxTokenPrice = 2 ether;

    uint public dividendRate = 150;  //15%


    uint public minPurchaseAmount = 0.1 ether;
    uint public minSaleAmount = 1e18;   //1 GGT
    uint public minRefStake = 1e17;  //0.1 GGT

    bool public allowBuy = false;
    bool public allowSell = false;
    bool public allowRedeem = false;



    constructor() public {
        totalSupply = INITIAL_SUPPLY;
        balances[msg.sender] = INITIAL_SUPPLY;
        addRole(msg.sender, ADMIN_ROLE);
        emit Transfer(address(this), msg.sender, INITIAL_SUPPLY);
    }


    function buy(address _referredBy) 

      payable 
      public  

      {
          require(msg.value >= minPurchaseAmount);
          require(allowBuy);
          //uint newTokens = SafeMath.div(msg.value,tokenPrice);
          //newTokens = SafeMath.mul(newTokens, 1e18);
          uint newTokens = ethereumToTokens_(msg.value);

          totalETHReceived = SafeMath.add(totalETHReceived, msg.value);

          require(SafeMath.add(totalSupply, newTokens) <= maxTokens);

          balances[msg.sender] = SafeMath.add(balances[msg.sender], newTokens);
          totalSupply = SafeMath.add(newTokens, totalSupply);

          uint goldAmount = SafeMath.div(SafeMath.mul(goldPrice,msg.value),tokenPrice);
          uint operationsAmount = SafeMath.sub(msg.value,goldAmount);

          uint256 _referralBonus = SafeMath.div(SafeMath.mul(operationsAmount, referralFee),1000);

          goldAccount = SafeMath.add(goldAmount, goldAccount);
          uint _dividends = SafeMath.div(SafeMath.mul(dividendRate, operationsAmount),1000);

          if(
            // is this a referred purchase?
            _referredBy != 0x0000000000000000000000000000000000000000 &&
            _referredBy != msg.sender &&
            balances[_referredBy] >= minRefStake)
            {
                operationsAmount = SafeMath.sub(operationsAmount,_referralBonus);
                //add referral amount to referrer dividend account
                referralBalance_[_referredBy] = SafeMath.add(referralBalance_[_referredBy], _referralBonus);
            }

          uint256 _fee = _dividends * magnitude;
          profitPerShare_ += (_dividends * magnitude / (totalSupply));
          _fee = _fee - (_fee-(newTokens * (_dividends * magnitude / (totalSupply))));
          int256 _updatedPayouts = (int256) ((profitPerShare_ * newTokens) - _fee);

          payoutsTo_[msg.sender] += _updatedPayouts;
          operationsAmount = SafeMath.sub(operationsAmount, _dividends);
          operationsAccount = SafeMath.add(operationsAccount, operationsAmount);

          pendingGold = SafeMath.add(pendingGold, newTokens);
          emit Buy(msg.sender, newTokens);
          emit Transfer(address(this), msg.sender, newTokens);
    
    }

    function sell(uint amount) 

      public
  
      {

        require(allowSell);
        require(amount >= minSaleAmount);
        require(balances[msg.sender] >= amount);

        //calculate Eth to be returned
        uint256 _ethereum = tokensToEthereum_(amount);
        require(_ethereum <= operationsAccount);
        //burn sold tokens
        totalSupply = SafeMath.sub(totalSupply, amount);

        if (pendingGold > amount) {
            pendingGold = SafeMath.sub(pendingGold, amount);
        }else{
            pendingGold = 0;
        }

        balances[msg.sender] = SafeMath.sub(balances[msg.sender], amount);

        //payout goes to dividend account
        int256 _updatedPayouts = (int256) (profitPerShare_ * amount + (_ethereum * magnitude));
        payoutsTo_[msg.sender] -= _updatedPayouts;    

        operationsAccount = SafeMath.sub(operationsAccount, _ethereum);  
        emit onTokenSale(msg.sender, amount); 
    }


    function redeemTokensForGold(uint amount)

    public
    {
        //burn tokens that are to be redeemed for physical gold
        require(allowRedeem);
        require(balances[msg.sender] >= amount);
        if(myDividends(true) > 0) withdraw();

        payoutsTo_[msg.sender] -= (int256) (profitPerShare_ * amount);

        balances[msg.sender] = SafeMath.sub(balances[msg.sender], amount);
        totalSupply = SafeMath.sub(totalSupply, amount);
        emit onTokenRedeem(msg.sender, amount);
    }


    function getTokenAmount(uint amount) public 
    
    returns(uint)

    {
        return (amount*1e18)/(tokenPrice);
    }

    function depositGold()
      public
      payable
    {
        goldAccount = SafeMath.add(goldAccount, msg.value);
    }

    function depositOperations()
      public
      payable
    {
        operationsAccount = SafeMath.add(operationsAccount, msg.value);
    }

  
    function tokensToEthereum_(uint256 _tokens)
       internal
        view
        returns(uint256)
    {
        uint liquidPrice = SafeMath.div(SafeMath.mul(goldPrice, tokenSellDiscount),1000);
        uint256 _etherReceived = SafeMath.div(_tokens * liquidPrice, 1e18);
        return _etherReceived;
    }

    function ethereumToTokens_(uint256 _ethereum)
        public
        view
        returns(uint256)
    {
        uint256 _tokensReceived = SafeMath.div(_ethereum*1e18, tokenPrice);
            
        return _tokensReceived;
    }

    function updateGoldReserves(uint newReserves)
    public
    onlyRole(ADMIN_ROLE)
    {
        totalGoldReserves = newReserves;
        if (totalSupply > totalGoldReserves) {
            pendingGold = SafeMath.sub(totalSupply,totalGoldReserves);
        }else{
            pendingGold = 0;
        }
    }

    function setTokenPrice(uint newPrice)
      public
      onlyRole(ADMIN_ROLE)
    {
        require(newPrice >= minTokenPrice);
        require(newPrice <= maxTokenPrice);
        tokenPrice = newPrice;
    }

    function setGoldPrice(uint newPrice)
      public
      onlyRole(ADMIN_ROLE)
    {
        require(newPrice >= minGoldPrice);
        require(newPrice <= maxGoldPrice);
        goldPrice = newPrice;
    }

    function setTokenRange(uint newMax, uint newMin)
        public
        onlyRole(ADMIN_ROLE)
        {
            minTokenPrice = newMin;
            maxTokenPrice = newMax;
        }

    function setmaxTokens(uint newMax)
      public
      onlyRole(ADMIN_ROLE)
      {
          maxTokens = newMax;
      }

    function setGoldRange(uint newMax, uint newMin)
      public
      onlyRole(ADMIN_ROLE)
      {
        minGoldPrice = newMin;
        maxGoldPrice = newMax;
      }

    function withDrawGoldAccount(uint amount)
        public
        onlyRole(ADMIN_ROLE)
        {
          require(amount <= goldAccount);
          goldAccount = SafeMath.sub(goldAccount, amount);
          msg.sender.transfer(amount);
        }

      function withDrawOperationsAccount(uint amount)
          public
          onlyRole(ADMIN_ROLE)
          {
            require(amount <= operationsAccount);
            operationsAccount = SafeMath.sub(operationsAccount, amount);
            msg.sender.transfer(amount);
          }

      function setAllowBuy(bool newAllow)
          public
          onlyRole(ADMIN_ROLE)
          {
            allowBuy = newAllow;
          }

      function setAllowSell(bool newAllow)
          public
          onlyRole(ADMIN_ROLE)
          {
            allowSell = newAllow;
          }

      function setAllowRedeem(bool newAllow)
          public
          onlyRole(ADMIN_ROLE)
          {
            allowRedeem = newAllow;
          }

      function setMinPurchaseAmount(uint newAmount)
          public 
          onlyRole(ADMIN_ROLE)
      {
          minPurchaseAmount = newAmount;
      } 

      function setMinSaleAmount(uint newAmount)
          public 
          onlyRole(ADMIN_ROLE)
      {
          minSaleAmount = newAmount;
      } 

      function setMinRefStake(uint newAmount)
          public 
          onlyRole(ADMIN_ROLE)
      {
          minRefStake = newAmount;
      } 

      function setReferralFee(uint newAmount)
          public 
          onlyRole(ADMIN_ROLE)
      {
          referralFee = newAmount;
      } 

      function setProofofStakeFee(uint newAmount)
          public 
          onlyRole(ADMIN_ROLE)
      {
          dividendRate = newAmount;
      } 
      
      function setTokenSellDiscount(uint newAmount)
          public 
          onlyRole(ADMIN_ROLE)
      {
          tokenSellDiscount = newAmount;
      } 
      

      function withdraw()
          {
              //require(myDividends() > 0);

              address _customerAddress = msg.sender;
              uint256 _dividends = myDividends(false);

              payoutsTo_[_customerAddress] +=  (int256) (_dividends * magnitude);

              // add ref. bonus
              _dividends += referralBalance_[_customerAddress];
              referralBalance_[_customerAddress] = 0;

              msg.sender.transfer(_dividends);

              onWithdraw(_customerAddress, _dividends);
          }

      function myDividends(bool _includeReferralBonus) 
          public 
          view 
          returns(uint256)
            {
                address _customerAddress = msg.sender;
               // return dividendsOf(_customerAddress);
                return _includeReferralBonus ? dividendsOf(_customerAddress) + referralBalance_[_customerAddress] : dividendsOf(_customerAddress) ;
            }


    /**
      * Retrieve the dividend balance of any single address.
      */
    function dividendsOf(address _customerAddress)
        view
        public
        returns(uint256)
        {
            return (uint256) ((int256)(profitPerShare_ * balanceOf(_customerAddress)) - payoutsTo_[_customerAddress]) / magnitude;
        }
    
    function profitShare() 
        public 
        view 
        returns(uint256)
        {
            return profitPerShare_;
        }

    function payouts() 
        public 
        view 
        returns(int256)
        {
            return payoutsTo_[msg.sender];
        }

    function getTotalDivs() 
      public
      view
      returns(uint256)
      {
          return (profitPerShare_ * totalSupply);
      }


      function tokenData() 
          //Ethereum Balance, MyTokens, TotalTokens, myDividends
          public 
          view 
          returns(uint256, uint256, uint256, uint256, uint256, uint256)
      {
          return(address(this).balance, balanceOf(msg.sender), totalSupply, myDividends(true), tokenSellDiscount, goldPrice);
      }


  /**
  * @dev Determine if the address is the owner of the contract
  * @param _address The address to determine of ownership
  */
  function isOwner(address _address) public view returns (bool) {
    return owner == _address;
  }

  /**
  * @dev Returns the list of MultiSig transfers
  */
  function getTransfers() public view returns (address[]) {
    return transfers;
  }

  /**
  * @dev The GGT ERC20 token uses adminstrators to handle transfering to the crowdsale, vesting and pre-purchasers
  */
  function isAdmin(address _address) public view returns (bool) {
    return hasRole(_address, ADMIN_ROLE);
  }

  /**
  * @dev Set an administrator as the owner, using Open Zepplin RBAC implementation
  */
  function setAdmin(address _newAdmin) public onlyOwner {
    return addRole(_newAdmin, ADMIN_ROLE);
  }

  /**
  * @dev Remove an administrator as the owner, using Open Zepplin RBAC implementation
  */
  function removeAdmin(address _oldAdmin) public onlyOwner {
    return removeRole(_oldAdmin, ADMIN_ROLE);
  }

  /**
  * @dev As an administrator, request the token is made transferable
  * @param _toState The transfer state being requested
  */
  function setTransferable(bool _toState) public onlyRole(ADMIN_ROLE) {
    require(isTransferable != _toState, "to init a transfer toggle, the toState must change");
    toggleTransferablePending = true;
    transferToggleRequester = msg.sender;
  }

  /**
  * @dev As an administrator who did not make the request, approve the transferable state change
  */
  function approveTransferableToggle() public onlyRole(ADMIN_ROLE) {
    require(toggleTransferablePending == true, "transfer toggle not in pending state");
    require(transferToggleRequester != msg.sender, "the requester cannot approve the transfer toggle");
    isTransferable = !isTransferable;
    toggleTransferablePending = false;
    transferToggleRequester = address(0);
  }

  /**
  * @dev transfer token for a specified address
  * @param _to The address to transfer to.
  * @param _value The amount to be transferred.
  */
  function _transfer(address _to, address _from, uint256 _value) private returns (bool) {
    require(_value <= balances[_from], "the balance in the from address is smaller than the tx value");

    // SafeMath.sub will throw if there is not enough balance.
    //payoutsTo_[_to] += (int256) (profitPerShare_ * _value);

  
    if(myDividends(true) > 0) withdraw();
    balances[_from] = balances[_from].sub(_value);
    balances[_to] = balances[_to].add(_value);

     // update dividend trackers
    payoutsTo_[_from] -= (int256) (profitPerShare_ * _value);
    payoutsTo_[_to] += (int256) (profitPerShare_ * _value);
        
    // disperse dividends among holders
    //profitPerShare_ = SafeMath.add(profitPerShare_, (_dividends * magnitude) / totalSupply);

    emit Transfer(_from, _to, _value);
    return true;
  }

  /**
  * @dev Public transfer token function. This wrapper ensures the token is transferable
  * @param _to The address to transfer to.
  * @param _value The amount to be transferred.
  */
  function transfer(address _to, uint256 _value) public returns (bool) {
    require(_to != address(0), "cannot transfer to the zero address");

    /* We allow holders to return their Tokens to the contract owner at any point */
    if (_to != owner && msg.sender != crowdsale) {
      require(isTransferable == true, "GGT is not yet transferable");
    }

    /* Transfers from the owner address must use the administrative transfer */
    require(msg.sender != owner, "the owner of the GGT contract cannot transfer");

    return _transfer(_to, msg.sender, _value);
  }




   function transferFrom(address from, address to, uint tokens) public returns (bool success) {
        balances[from] = balances[from].sub(tokens);
        allowed[from][msg.sender] = allowed[from][msg.sender].sub(tokens);
        balances[to] = balances[to].add(tokens);
        Transfer(from, to, tokens);
        return true;
    }
 
    // Allow `spender` to withdraw from your account, multiple times, up to the `tokens` amount.
    // If this function is called again it overwrites the current allowance with _value.
    function approve(address spender, uint tokens) public returns (bool success) {
        allowed[msg.sender][spender] = tokens;
        Approval(msg.sender, spender, tokens);
        return true;
    }

    // ------------------------------------------------------------------------
    // Returns the amount of tokens approved by the owner that can be
    // transferred to the spender's account
    // ------------------------------------------------------------------------
    function allowance(address tokenOwner, address spender) public view returns (uint remaining) {
        return allowed[tokenOwner][spender];
    }

    // ------------------------------------------------------------------------
    // Token owner can approve for `spender` to transferFrom(...) `tokens`
    // from the token owner's account. The `spender` contract function
    // `receiveApproval(...)` is then executed
    // ------------------------------------------------------------------------
    function approveAndCall(address spender, uint tokens, bytes memory data) public returns (bool success) {
        allowed[msg.sender][spender] = tokens;
        emit Approval(msg.sender, spender, tokens);
        ApproveAndCallFallBack(spender).receiveApproval(msg.sender, tokens, address(this), data);
        return true;
    }


  /**
  * @dev Request an administrative transfer. This does not move tokens
  * @param _to The address to transfer to.
  * @param _quantity The amount to be transferred.
  */
  function adminTransfer(address _to, uint256 _quantity) public onlyRole(ADMIN_ROLE) {
    address newTransfer = new MultiSigTransfer(_quantity, _to, msg.sender);
    transfers.push(newTransfer);
  }

  /**
  * @dev Approve an administrative transfer. This moves the tokens if the requester
  * is an admin, but not the same admin as the one who made the request
  * @param _approvedTransfer The contract address of the multisignature transfer.
  */
  function approveTransfer(address _approvedTransfer) public onlyRole(ADMIN_ROLE) returns (bool) {
    MultiSigTransfer transferToApprove = MultiSigTransfer(_approvedTransfer);

    uint256 transferQuantity = transferToApprove.quantity();
    address deliveryAddress = transferToApprove.targetAddress();
    address requesterAddress = transferToApprove.requesterAddress();

    require(msg.sender != requesterAddress, "a requester cannot approve an admin transfer");

    transferToApprove.approveTransfer();
    return _transfer(deliveryAddress, owner, transferQuantity);
  }

  /**
  * @dev Deny an administrative transfer. This ensures it cannot be approved.
  * @param _approvedTransfer The contract address of the multisignature transfer.
  */
  function denyTransfer(address _approvedTransfer) public onlyRole(ADMIN_ROLE) returns (bool) {
    MultiSigTransfer transferToApprove = MultiSigTransfer(_approvedTransfer);
    transferToApprove.denyTransfer();
  }

  address public crowdsale = address(0);

  /**
  * @dev Any admin can set the current crowdsale address, to allows transfers
  * from the crowdsale to the purchaser
  */
  function setCrowdsaleAddress(address _crowdsaleAddress) public onlyRole(ADMIN_ROLE) {
    crowdsale = _crowdsaleAddress;
  }
}