pragma solidity ^0.4.18;


/**
 * @title ERC20Basic
 * @dev Simpler version of ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/179
 * https://github.com/OpenZeppelin/zeppelin-solidity/
 */
contract ERC20Basic {
  uint256 public totalSupply;
  function balanceOf(address who) public view returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}





/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure.
 * To use this library you can add a `using SafeERC20 for ERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
  function safeTransfer(ERC20Basic token, address to, uint256 value) internal {
    assert(token.transfer(to, value));
  }

  function safeTransferFrom(ERC20 token, address from, address to, uint256 value) internal {
    assert(token.transferFrom(from, to, value));
  }

  function safeApprove(ERC20 token, address spender, uint256 value) internal {
    assert(token.approve(spender, value));
  }
}



/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 * https://github.com/OpenZeppelin/zeppelin-solidity/
 */
contract Ownable {
  address public owner;                                                     // Operational owner.
  address public masterOwner = 0xe4925C73851490401b858B657F26E62e9aD20F66;  // for ownership transfer segregation of duty, hard coded to wallet account

  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  function Ownable() public {
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
   * @param newOwner The address to transfer ownership to.
   */
  function transferOwnership(address newOwner) public {
    require(newOwner != address(0));
    require(masterOwner == msg.sender); // only master owner can initiate change to ownership
    OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }
}




/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 * https://github.com/OpenZeppelin/zeppelin-solidity/
 */
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
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
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

  function cei(uint256 a, uint256 b) internal pure returns (uint256) {
    return ((a + b - 1) / b) * b;
  }
}












/**
 * @title Basic token
 * @dev Basic version of StandardToken, with no allowances.
 */
contract BasicToken is ERC20Basic {
  using SafeMath for uint256;

  mapping(address => uint256) balances;

  /**
  * @dev transfer token for a specified address
  * @param _to The address to transfer to.
  * @param _value The amount to be transferred.
  */
  function transfer(address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));
    require(_value <= balances[msg.sender]);

    // SafeMath.sub will throw if there is not enough balance.
    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);
    Transfer(msg.sender, _to, _value);
    return true;
  }

  /**
  * @dev Gets the balance of the specified address.
  * @param _owner The address to query the the balance of.
  * @return An uint256 representing the amount owned by the passed address.
  */
  function balanceOf(address _owner) public view returns (uint256 balance) {
    return balances[_owner];
  }

}





/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 * https://github.com/OpenZeppelin/zeppelin-solidity/
 */
contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender) public view returns (uint256);
  function transferFrom(address from, address to, uint256 value) public returns (bool);
  function approve(address spender, uint256 value) public returns (bool);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}


/**
 * @title Standard ERC20 token
 *
 * @dev Implementation of the basic standard token.
 * @dev https://github.com/ethereum/EIPs/issues/20
 * @dev Based on code by FirstBlood: https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol
 */
contract StandardToken is ERC20, BasicToken {

  mapping (address => mapping (address => uint256)) internal allowed;


  /**
   * @dev Transfer tokens from one address to another
   * @param _from address The address which you want to send tokens from
   * @param _to address The address which you want to transfer to
   * @param _value uint256 the amount of tokens to be transferred
   */
  function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));
    require(_value <= balances[_from]);
    require(_value <= allowed[_from][msg.sender]);

    balances[_from] = balances[_from].sub(_value);
    balances[_to] = balances[_to].add(_value);
    allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
    Transfer(_from, _to, _value);
    return true;
  }

  /**
   * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.
   *
   * Beware that changing an allowance with this method brings the risk that someone may use both the old
   * and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this
   * race condition is to first reduce the spender's allowance to 0 and set the desired value afterwards:
   * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
   * @param _spender The address which will spend the funds.
   * @param _value The amount of tokens to be spent.
   */
  function approve(address _spender, uint256 _value) public returns (bool) {
    allowed[msg.sender][_spender] = _value;
    Approval(msg.sender, _spender, _value);
    return true;
  }

  /**
   * @dev Function to check the amount of tokens that an owner allowed to a spender.
   * @param _owner address The address which owns the funds.
   * @param _spender address The address which will spend the funds.
   * @return A uint256 specifying the amount of tokens still available for the spender.
   */
  function allowance(address _owner, address _spender) public view returns (uint256) {
    return allowed[_owner][_spender];
  }

  /**
   * @dev Increase the amount of tokens that an owner allowed to a spender.
   *
   * approve should be called when allowed[_spender] == 0. To increment
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   * @param _spender The address which will spend the funds.
   * @param _addedValue The amount of tokens to increase the allowance by.
   */
  function increaseApproval(address _spender, uint _addedValue) public returns (bool) {
    allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
    Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

  /**
   * @dev Decrease the amount of tokens that an owner allowed to a spender.
   *
   * approve should be called when allowed[_spender] == 0. To decrement
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   * @param _spender The address which will spend the funds.
   * @param _subtractedValue The amount of tokens to decrease the allowance by.
   */
  function decreaseApproval(address _spender, uint _subtractedValue) public returns (bool) {
    uint oldValue = allowed[msg.sender][_spender];
    if (_subtractedValue > oldValue) {
      allowed[msg.sender][_spender] = 0;
    } else {
      allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
    }
    Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

}


/** This interfaces will be implemented by different VZT contracts in future*/
interface tokenRecipient { function receiveApproval(address _from, uint256 _value, address _token, bytes _extraData) public; }

contract VZToken is StandardToken, Ownable {


    /* metadata */

    string public constant name = "VectorZilla Token"; // solium-disable-line uppercase
    string public constant symbol = "VZT"; // solium-disable-line uppercase
    string public constant version = "1.0"; // solium-disable-line uppercase
    uint8 public constant decimals = 18; // solium-disable-line uppercase

    /* all accounts in wei */

    uint256 public constant INITIAL_SUPPLY = 100000000 * 10 ** 18; //intial total supply
    uint256 public constant BURNABLE_UP_TO =  90000000 * 10 ** 18; //burnable up to 90% (90 million) of total supply
    uint256 public constant VECTORZILLA_RESERVE_VZT = 25000000 * 10 ** 18; //25 million - reserved tokens

    // Reserved tokens will be sent to this address. this address will be replaced on production:
    address public constant VECTORZILLA_RESERVE = 0xF63e65c57024886cCa65985ca6E2FB38df95dA11;

    // - tokenSaleContract receives the whole balance for distribution
    address public tokenSaleContract;

    /* Following stuff is to manage regulatory hurdles on who can and cannot use VZT token  */
    mapping (address => bool) public frozenAccount;
    event FrozenFunds(address target, bool frozen);


    /** Modifiers to be used all over the place **/

    modifier onlyOwnerAndContract() {
        require(msg.sender == owner || msg.sender == tokenSaleContract);
        _;
    }


    modifier onlyWhenValidAddress( address _addr ) {
        require(_addr != address(0x0));
        _;
    }

    modifier onlyWhenValidContractAddress(address _addr) {
        require(_addr != address(0x0));
        require(_addr != address(this));
        require(isContract(_addr));
        _;
    }

    modifier onlyWhenBurnable(uint256 _value) {
        require(totalSupply - _value >= INITIAL_SUPPLY - BURNABLE_UP_TO);
        _;
    }

    modifier onlyWhenNotFrozen(address _addr) {
        require(!frozenAccount[_addr]);
        _;
    }

    /** End of Modifier Definations */

    /** Events */

    event Burn(address indexed burner, uint256 value);
    event Finalized();
    //log event whenever withdrawal from this contract address happens
    event Withdraw(address indexed from, address indexed to, uint256 value);

    /*
        Contructor that distributes initial supply between
        owner and vzt reserve.
    */
    function VZToken(address _owner) public {
        require(_owner != address(0));
        totalSupply = INITIAL_SUPPLY;
        balances[_owner] = INITIAL_SUPPLY - VECTORZILLA_RESERVE_VZT; //75 millions tokens
        balances[VECTORZILLA_RESERVE] = VECTORZILLA_RESERVE_VZT; //25 millions
        owner = _owner;
    }

    /*
        This unnamed function is called whenever the owner send Ether to fund the gas
        fees and gas reimbursement.
    */
    function () payable public onlyOwner {}

    /**
     * @dev transfer `_value` token for a specified address
     * @param _to The address to transfer to.
     * @param _value The amount to be transferred.
     */
    function transfer(address _to, uint256 _value) 
        public
        onlyWhenValidAddress(_to)
        onlyWhenNotFrozen(msg.sender)
        onlyWhenNotFrozen(_to)
        returns(bool) {
        return super.transfer(_to, _value);
    }

    /**
     * @dev Transfer `_value` tokens from one address (`_from`) to another (`_to`)
     * @param _from address The address which you want to send tokens from
     * @param _to address The address which you want to transfer to
     * @param _value uint256 the amount of tokens to be transferred
     */
    function transferFrom(address _from, address _to, uint256 _value) 
        public
        onlyWhenValidAddress(_to)
        onlyWhenValidAddress(_from)
        onlyWhenNotFrozen(_from)
        onlyWhenNotFrozen(_to)
        returns(bool) {
        return super.transferFrom(_from, _to, _value);
    }

    /**
     * @dev Burns a specific (`_value`) amount of tokens.
     * @param _value uint256 The amount of token to be burned.
     */
    function burn(uint256 _value)
        public
        onlyWhenBurnable(_value)
        onlyWhenNotFrozen(msg.sender)
        returns (bool) {
        require(_value <= balances[msg.sender]);
      // no need to require value <= totalSupply, since that would imply the
      // sender's balance is greater than the totalSupply, which *should* be an assertion failure
        address burner = msg.sender;
        balances[burner] = balances[burner].sub(_value);
        totalSupply = totalSupply.sub(_value);
        Burn(burner, _value);
        Transfer(burner, address(0x0), _value);
        return true;
      }

    /**
     * Destroy tokens from other account
     *
     * Remove `_value` tokens from the system irreversibly on behalf of `_from`.
     *
     * @param _from the address of the sender
     * @param _value the amount of money to burn
     */
    function burnFrom(address _from, uint256 _value) 
        public
        onlyWhenBurnable(_value)
        onlyWhenNotFrozen(_from)
        onlyWhenNotFrozen(msg.sender)
        returns (bool success) {
        assert(transferFrom( _from, msg.sender, _value ));
        return burn(_value);
    }

    /**
     * Set allowance for other address and notify
     *
     * Allows `_spender` to spend no more than `_value` tokens on your behalf, and then ping the contract about it
     *
     * @param _spender The address authorized to spend
     * @param _value the max amount they can spend
     * @param _extraData some extra information to send to the approved contract
     */
    function approveAndCall(address _spender, uint256 _value, bytes _extraData)
        public
        onlyWhenValidAddress(_spender)
        returns (bool success) {
        tokenRecipient spender = tokenRecipient(_spender);
        if (approve(_spender, _value)) {
            spender.receiveApproval(msg.sender, _value, this, _extraData);
            return true;
        }
    }

    /**
     * Freezes account and disables transfers/burning
     *  This is to manage regulatory hurdlers where contract owner is required to freeze some accounts.
     */
    function freezeAccount(address target, bool freeze) external onlyOwner {
        frozenAccount[target] = freeze;
        FrozenFunds(target, freeze);
    }

    /* Owner withdrawal of an ether deposited from Token ether balance */
    function withdrawToOwner(uint256 weiAmt) public onlyOwner {
        // do not allow zero transfer
        require(weiAmt > 0);
        owner.transfer(weiAmt);
        // signal the event for communication only it is meaningful
        Withdraw(this, msg.sender, weiAmt);
    }


    /// @notice This method can be used by the controller to extract mistakenly
    ///  sent tokens to this contract.
    /// @param _token The address of the token contract that you want to recover
    ///  set to 0 in case you want to extract ether.
    function claimTokens(address _token) external onlyOwner {
        if (_token == 0x0) {
            owner.transfer(this.balance);
            return;
        }
        StandardToken token = StandardToken(_token);
        uint balance = token.balanceOf(this);
        token.transfer(owner, balance);
        // signal the event for communication only it is meaningful
        Withdraw(this, owner, balance);
    }

    function setTokenSaleContract(address _tokenSaleContract)
        external
        onlyWhenValidContractAddress(_tokenSaleContract)
        onlyOwner {
           require(_tokenSaleContract != tokenSaleContract);
           tokenSaleContract = _tokenSaleContract;
    }

    /// @dev Internal function to determine if an address is a contract
    /// @param _addr address The address being queried
    /// @return True if `_addr` is a contract
    function isContract(address _addr) constant internal returns(bool) {
        if (_addr == 0) {
            return false;
        }
        uint256 size;
        assembly {
            size: = extcodesize(_addr)
        }
        return (size > 0);
    }

    /**
     * @dev Function to send `_value` tokens to user (`_to`) from sale contract/owner
     * @param _to address The address that will receive the minted tokens.
     * @param _value uint256 The amount of tokens to be sent.
     * @return True if the operation was successful.
     */
    function sendToken(address _to, uint256 _value)
        public
        onlyWhenValidAddress(_to)
        onlyOwnerAndContract
        returns(bool) {
        address _from = owner;
        // Check if the sender has enough
        require(balances[_from] >= _value);
        // Check for overflows
        require(balances[_to] + _value > balances[_to]);
        // Save this for an assertion in the future
        uint256 previousBalances = balances[_from] + balances[_to];
        // Subtract from the sender
        balances[_from] -= _value;
        // Add the same to the recipient
        balances[_to] += _value;
        Transfer(_from, _to, _value);
        // Asserts are used to use static analysis to find bugs in your code. They should never fail
        assert(balances[_from] + balances[_to] == previousBalances);
        return true;
    }
    /**
     * @dev Batch transfer of tokens to addresses from owner's balance
     * @param addresses address[] The address that will receive the minted tokens.
     * @param _values uint256[] The amount of tokens to be sent.
     * @return True if the operation was successful.
     */
    function batchSendTokens(address[] addresses, uint256[] _values) 
        public onlyOwnerAndContract
        returns (bool) {
        require(addresses.length == _values.length);
        require(addresses.length <= 20); //only batches of 20 allowed
        uint i = 0;
        uint len = addresses.length;
        for (;i < len; i++) {
            sendToken(addresses[i], _values[i]);
        }
        return true;
    }
}







/**
 * @title Pausable
 * @dev Base contract which allows children to implement an emergency stop mechanism.
 */
contract Pausable is Ownable {
  event Pause();
  event Unpause();

  bool public paused = false;


  /**
   * @dev Modifier to make a function callable only when the contract is not paused.
   */
  modifier whenNotPaused() {
    require(!paused);
    _;
  }

  /**
   * @dev Modifier to make a function callable only when the contract is paused.
   */
  modifier whenPaused() {
    require(paused);
    _;
  }

  /**
   * @dev called by the owner to pause, triggers stopped state
   */
  function pause() onlyOwner whenNotPaused public {
    paused = true;
    Pause();
  }

  /**
   * @dev called by the owner to unpause, returns to normal state
   */
  function unpause() onlyOwner whenPaused public {
    paused = false;
    Unpause();
  }
}









/**
 * @title Contracts that should be able to recover tokens
 * @author SylTi
 * @dev This allow a contract to recover any ERC20 token received in a contract by transferring the balance to the contract owner.
 * This will prevent any accidental loss of tokens.
 * https://github.com/OpenZeppelin/zeppelin-solidity/
 */
contract CanReclaimToken is Ownable {
  using SafeERC20 for ERC20Basic;

    //log event whenever withdrawal from this contract address happens
    event Withdraw(address indexed from, address indexed to, uint256 value);
  /**
   * @dev Reclaim all ERC20Basic compatible tokens
   * @param token ERC20Basic The address of the token contract
   */
  function reclaimToken(address token) external onlyOwner {
    if (token == 0x0) {
      owner.transfer(this.balance);
      return;
    }
    ERC20Basic ecr20BasicToken = ERC20Basic(token);
    uint256 balance = ecr20BasicToken.balanceOf(this);
    ecr20BasicToken.safeTransfer(owner, balance);
    Withdraw(msg.sender, owner, balance);
  }

}

/**
 * @title Contracts that should not own Tokens
 * @author Remco Bloemen <remco@2π.com>
 * @dev This blocks incoming ERC23 tokens to prevent accidental loss of tokens.
 * Should tokens (any ERC20Basic compatible) end up in the contract, it allows the
 * owner to reclaim the tokens.
* https://github.com/OpenZeppelin/zeppelin-solidity/
 */
contract HasNoTokens is CanReclaimToken {

 /**
  * @dev Reject all ERC23 compatible tokens
  * @param from_ address The address that is transferring the tokens
  * @param value_ uint256 the amount of the specified token
  * @param data_ Bytes The data passed from the caller.
  */
  function tokenFallback(address from_, uint256 value_, bytes data_) pure external {
    from_;
    value_;
    data_;
    revert();
  }

}


contract VZTPresale is Ownable, Pausable, HasNoTokens {


    using SafeMath for uint256;

    string public constant name = "VectorZilla Public Presale";  // solium-disable-line uppercase
    string public constant version = "1.0"; // solium-disable-line uppercase

    VZToken token;

    // this multi-sig address will be replaced on production:
    address public constant VZT_WALLET = 0xa50EB7D45aA025525254aB2452679cE888B16b86;
    /* if the minimum funding goal in wei is not reached, buyers may withdraw their funds */
    uint256 public constant MIN_FUNDING_GOAL = 200 * 10 ** 18;
    uint256 public constant PRESALE_TOKEN_SOFT_CAP = 1875000 * 10 ** 18;    // presale soft cap of 1,875,000 VZT
    uint256 public constant PRESALE_RATE = 1250;                            // presale price is 1 ETH to 1,250 VZT
    uint256 public constant SOFTCAP_RATE = 1150;                            // presale price becomes 1 ETH to 1,150 VZT after softcap is reached
    uint256 public constant PRESALE_TOKEN_HARD_CAP = 5900000 * 10 ** 18;    // presale token hardcap
    uint256 public constant MAX_GAS_PRICE = 50000000000;

    uint256 public minimumPurchaseLimit = 0.1 * 10 ** 18;                      // minimum purchase is 0.1 ETH to make the gas worthwhile
    uint256 public startDate = 1516001400;                            // January 15, 2018 7:30 AM UTC
    uint256 public endDate = 1517815800;                              // Febuary 5, 2018 7:30 AM UTC
    uint256 public totalCollected = 0;                                // total amount of Ether raised in wei
    uint256 public tokensSold = 0;                                    // total number of VZT tokens sold
    uint256 public totalDistributed = 0;                              // total number of VZT tokens distributed once finalised
    uint256 public numWhitelisted = 0;                                // total number whitelisted

    struct PurchaseLog {
        uint256 ethValue;
        uint256 vztValue;
        bool kycApproved;
        bool tokensDistributed;
        bool paidFiat;
        uint256 lastPurchaseTime;
        uint256 lastDistributionTime;
    }

    //purchase log that captures
    mapping (address => PurchaseLog) public purchaseLog;
    //capture refunds
    mapping (address => bool) public refundLog;
    //capture buyers in array, this is for quickly looking up from DAPP
    address[] public buyers;
    uint256 public buyerCount = 0;                                              // total number of buyers purchased VZT

    bool public isFinalized = false;                                        // it becomes true when token sale is completed
    bool public publicSoftCapReached = false;                               // it becomes true when public softcap is reached

    // list of addresses that can purchase
    mapping(address => bool) public whitelist;

    // event logging for token purchase
    event TokenPurchase(address indexed purchaser, address indexed beneficiary, uint256 value, uint256 amount);
    // event logging for token sale finalized
    event Finalized();
    // event logging for softcap reached
    event SoftCapReached();
    // event logging for funds transfered to VectorZilla multi-sig wallet
    event FundsTransferred();
    // event logging for each individual refunded amount
    event Refunded(address indexed beneficiary, uint256 weiAmount);
    // event logging for each individual distributed token + bonus
    event TokenDistributed(address indexed purchaser, uint256 tokenAmt);


    /*
        Constructor to initialize everything.
    */
    function VZTPresale(address _token, address _owner) public {
        require(_token != address(0));
        require(_owner != address(0));
        token = VZToken(_token);
        // default owner
        owner = _owner;
    }

    /*
       default function to buy tokens.
    */

    function() payable public whenNotPaused {
        doPayment(msg.sender);
    }

    /*
       allows owner to register token purchases done via fiat-eth (or equivalent currency)
    */
    function payableInFiatEth(address buyer, uint256 value) external onlyOwner {
        purchaseLog[buyer].paidFiat = true;
        // do public presale
        purchasePresale(buyer, value);
    }

    function setTokenContract(address _token) external onlyOwner {
        require(token != address(0));
        token = VZToken(_token);

    }

    /**
    * add address to whitelist
    * @param _addr wallet address to be added to whitelist
    */
    function addToWhitelist(address _addr) public onlyOwner returns (bool) {
        require(_addr != address(0));
        if (!whitelist[_addr]) {
            whitelist[_addr] = true;
            numWhitelisted++;
        }
        purchaseLog[_addr].kycApproved = true;
        return true;
    }

     /**
      * add address to whitelist
      * @param _addresses wallet addresses to be whitelisted
      */
    function addManyToWhitelist(address[] _addresses) 
        external 
        onlyOwner 
        returns (bool) 
        {
        require(_addresses.length <= 50);
        uint idx = 0;
        uint len = _addresses.length;
        for (; idx < len; idx++) {
            address _addr = _addresses[idx];
            addToWhitelist(_addr);
        }
        return true;
    }
    /**
     * remove address from whitelist
     * @param _addr wallet address to be removed from whitelist
     */
     function removeFomWhitelist(address _addr) public onlyOwner returns (bool) {
         require(_addr != address(0));
         require(whitelist[_addr]);
        delete whitelist[_addr];
        purchaseLog[_addr].kycApproved = false;
        numWhitelisted--;
        return true;
     }

    /*
        Send Tokens tokens to a buyer:
        - and KYC is approved
    */
    function sendTokens(address _user) public onlyOwner returns (bool) {
        require(_user != address(0));
        require(_user != address(this));
        require(purchaseLog[_user].kycApproved);
        require(purchaseLog[_user].vztValue > 0);
        require(!purchaseLog[_user].tokensDistributed);
        require(!refundLog[_user]);
        purchaseLog[_user].tokensDistributed = true;
        purchaseLog[_user].lastDistributionTime = now;
        totalDistributed++;
        token.sendToken(_user, purchaseLog[_user].vztValue);
        TokenDistributed(_user, purchaseLog[_user].vztValue);
        return true;
    }

    /*
        Refund ethers to buyer if KYC couldn't/wasn't verified.
    */
    function refundEthIfKYCNotVerified(address _user) public onlyOwner returns (bool) {
        if (!purchaseLog[_user].kycApproved) {
            return doRefund(_user);
        }
        return false;
    }

    /*

    /*
        return true if buyer is whitelisted
    */
    function isWhitelisted(address buyer) public view returns (bool) {
        return whitelist[buyer];
    }

    /*
        Check to see if this is public presale.
    */
    function isPresale() public view returns (bool) {
        return !isFinalized && now >= startDate && now <= endDate;
    }

    /*
        check if allocated has sold out.
    */
    function hasSoldOut() public view returns (bool) {
        return PRESALE_TOKEN_HARD_CAP - tokensSold < getMinimumPurchaseVZTLimit();
    }

    /*
        Check to see if the presale end date has passed or if all tokens allocated
        for sale has been purchased.
    */
    function hasEnded() public view returns (bool) {
        return now > endDate || hasSoldOut();
    }

    /*
        Determine if the minimum goal in wei has been reached.
    */
    function isMinimumGoalReached() public view returns (bool) {
        return totalCollected >= MIN_FUNDING_GOAL;
    }

    /*
        For the convenience of presale interface to present status info.
    */
    function getSoftCapReached() public view returns (bool) {
        return publicSoftCapReached;
    }

    function setMinimumPurchaseEtherLimit(uint256 newMinimumPurchaseLimit) external onlyOwner {
        require(newMinimumPurchaseLimit > 0);
        minimumPurchaseLimit = newMinimumPurchaseLimit;
    }
    /*
        For the convenience of presale interface to find current tier price.
    */

    function getMinimumPurchaseVZTLimit() public view returns (uint256) {
        if (getTier() == 1) {
            return minimumPurchaseLimit.mul(PRESALE_RATE); //1250VZT/ether
        } else if (getTier() == 2) {
            return minimumPurchaseLimit.mul(SOFTCAP_RATE); //1150VZT/ether
        }
        return minimumPurchaseLimit.mul(1000); //base price
    }

    /*
        For the convenience of presale interface to find current discount tier.
    */
    function getTier() public view returns (uint256) {
        // Assume presale top tier discount
        uint256 tier = 1;
        if (now >= startDate && now < endDate && getSoftCapReached()) {
            // tier 2 discount
            tier = 2;
        }
        return tier;
    }

    /*
        For the convenience of presale interface to present status info.
    */
    function getPresaleStatus() public view returns (uint256[3]) {
        // 0 - presale not started
        // 1 - presale started
        // 2 - presale ended
        if (now < startDate)
            return ([0, startDate, endDate]);
        else if (now <= endDate && !hasEnded())
            return ([1, startDate, endDate]);
        else
            return ([2, startDate, endDate]);
    }

    /*
        Called after presale ends, to do some extra finalization work.
    */
    function finalize() public onlyOwner {
        // do nothing if finalized
        require(!isFinalized);
        // presale must have ended
        require(hasEnded());

        if (isMinimumGoalReached()) {
            // transfer to VectorZilla multisig wallet
            VZT_WALLET.transfer(this.balance);
            // signal the event for communication
            FundsTransferred();
        }
        // mark as finalized
        isFinalized = true;
        // signal the event for communication
        Finalized();
    }


    /**
     * @notice `proxyPayment()` allows the caller to send ether to the VZTPresale
     * and have the tokens created in an address of their choosing
     * @param buyer The address that will hold the newly created tokens
     */
    function proxyPayment(address buyer) 
    payable 
    public
    whenNotPaused 
    returns(bool success) 
    {
        return doPayment(buyer);
    }

    /*
        Just in case we need to tweak pre-sale dates
    */
    function setDates(uint256 newStartDate, uint256 newEndDate) public onlyOwner {
        require(newEndDate >= newStartDate);
        startDate = newStartDate;
        endDate = newEndDate;
    }


    // @dev `doPayment()` is an internal function that sends the ether that this
    //  contract receives to the `vault` and creates tokens in the address of the
    //  `buyer` assuming the VZTPresale is still accepting funds
    //  @param buyer The address that will hold the newly created tokens
    // @return True if payment is processed successfully
    function doPayment(address buyer) internal returns(bool success) {
        require(tx.gasprice <= MAX_GAS_PRICE);
        // Antispam
        // do not allow contracts to game the system
        require(buyer != address(0));
        require(!isContract(buyer));
        // limit the amount of contributions to once per 100 blocks
        //require(getBlockNumber().sub(lastCallBlock[msg.sender]) >= maxCallFrequency);
        //lastCallBlock[msg.sender] = getBlockNumber();

        if (msg.sender != owner) {
            // stop if presale is over
            require(isPresale());
            // stop if no more token is allocated for sale
            require(!hasSoldOut());
            require(msg.value >= minimumPurchaseLimit);
        }
        require(msg.value > 0);
        purchasePresale(buyer, msg.value);
        return true;
    }

    /// @dev Internal function to determine if an address is a contract
    /// @param _addr The address being queried
    /// @return True if `_addr` is a contract
    function isContract(address _addr) constant internal returns (bool) {
        if (_addr == 0) {
            return false;
        }
        uint256 size;
        assembly {
            size := extcodesize(_addr)
        }
        return (size > 0);
    }

    /// @dev Internal function to process sale
    /// @param buyer The buyer address
    /// @param value  The value of ether paid
    function purchasePresale(address buyer, uint256 value) internal {
         require(value >= minimumPurchaseLimit);
         require(buyer != address(0));
        uint256 tokens = 0;
        // still under soft cap
        if (!publicSoftCapReached) {
            // 1 ETH for 1,250 VZT
            tokens = value * PRESALE_RATE;
            // get less if over softcap
            if (tokensSold + tokens > PRESALE_TOKEN_SOFT_CAP) {
                uint256 availablePresaleTokens = PRESALE_TOKEN_SOFT_CAP - tokensSold;
                uint256 softCapTokens = (value - (availablePresaleTokens / PRESALE_RATE)) * SOFTCAP_RATE;
                tokens = availablePresaleTokens + softCapTokens;
                // process presale at 1 ETH to 1,150 VZT
                processSale(buyer, value, tokens, SOFTCAP_RATE);
                // public soft cap has been reached
                publicSoftCapReached = true;
                // signal the event for communication
                SoftCapReached();
            } else {
                // process presale @PRESALE_RATE
                processSale(buyer, value, tokens, PRESALE_RATE);
            }
        } else {
            // 1 ETH to 1,150 VZT
            tokens = value * SOFTCAP_RATE;
            // process presale at 1 ETH to 1,150 VZT
            processSale(buyer, value, tokens, SOFTCAP_RATE);
        }
    }

    /*
        process sale at determined price.
    */
    function processSale(address buyer, uint256 value, uint256 vzt, uint256 vztRate) internal {
        require(buyer != address(0));
        require(vzt > 0);
        require(vztRate > 0);
        require(value > 0);

        uint256 vztOver = 0;
        uint256 excessEthInWei = 0;
        uint256 paidValue = value;
        uint256 purchasedVzt = vzt;

        if (tokensSold + purchasedVzt > PRESALE_TOKEN_HARD_CAP) {// if maximum is exceeded
            // find overage
            vztOver = tokensSold + purchasedVzt - PRESALE_TOKEN_HARD_CAP;
            // overage ETH to refund
            excessEthInWei = vztOver / vztRate;
            // adjust tokens purchased
            purchasedVzt = purchasedVzt - vztOver;
            // adjust Ether paid
            paidValue = paidValue - excessEthInWei;
        }

        /* To quick lookup list of buyers (pending token, kyc, or even refunded)
            we are keeping an array of buyers. There might be duplicate entries when
            a buyer gets refund (incomplete kyc, or requested), and then again contributes.
        */
        if (purchaseLog[buyer].vztValue == 0) {
            buyers.push(buyer);
            buyerCount++;
        }

        //if not whitelisted, mark kyc pending
        if (!isWhitelisted(buyer)) {
            purchaseLog[buyer].kycApproved = false;
        }
        //reset refund status in refundLog
        refundLog[buyer] = false;

         // record purchase in purchaseLog
        purchaseLog[buyer].vztValue = SafeMath.add(purchaseLog[buyer].vztValue, purchasedVzt);
        purchaseLog[buyer].ethValue = SafeMath.add(purchaseLog[buyer].ethValue, paidValue);
        purchaseLog[buyer].lastPurchaseTime = now;


        // total Wei raised
        totalCollected += paidValue;
        // total VZT sold
        tokensSold += purchasedVzt;

        /*
            For event, log buyer and beneficiary properly
        */
        address beneficiary = buyer;
        if (beneficiary == msg.sender) {
            beneficiary = msg.sender;
        }
        // signal the event for communication
        TokenPurchase(buyer, beneficiary, paidValue, purchasedVzt);
        // transfer must be done at the end after all states are updated to prevent reentrancy attack.
        if (excessEthInWei > 0 && !purchaseLog[buyer].paidFiat) {
            // refund overage ETH
            buyer.transfer(excessEthInWei);
            // signal the event for communication
            Refunded(buyer, excessEthInWei);
        }
    }

    /*
        Distribute tokens to a buyer:
        - when minimum goal is reached
        - and KYC is approved
    */
    function distributeTokensFor(address buyer) external onlyOwner returns (bool) {
        require(isFinalized);
        require(hasEnded());
        if (isMinimumGoalReached()) {
            return sendTokens(buyer);
        }
        return false;
    }

    /*
        purchaser requesting a refund, only allowed when minimum goal not reached.
    */
    function claimRefund() external returns (bool) {
        return doRefund(msg.sender);
    }

    /*
      send refund to purchaser requesting a refund 
   */
    function sendRefund(address buyer) external onlyOwner returns (bool) {
        return doRefund(buyer);
    }

    /*
        Internal function to manage refunds 
    */
    function doRefund(address buyer) internal returns (bool) {
        require(tx.gasprice <= MAX_GAS_PRICE);
        require(buyer != address(0));
        require(!purchaseLog[buyer].paidFiat);
        if (msg.sender != owner) {
            // cannot refund unless authorized
            require(isFinalized && !isMinimumGoalReached());
        }
        require(purchaseLog[buyer].ethValue > 0);
        require(purchaseLog[buyer].vztValue > 0);
        require(!refundLog[buyer]);
        require(!purchaseLog[buyer].tokensDistributed);

        // ETH to refund
        uint256 depositedValue = purchaseLog[buyer].ethValue;
        //VZT to revert
        uint256 vztValue = purchaseLog[buyer].vztValue;
        // assume all refunded, should we even do this if
        // we are going to delete buyer from log?
        purchaseLog[buyer].ethValue = 0;
        purchaseLog[buyer].vztValue = 0;
        refundLog[buyer] = true;
        //delete from purchase log.
        //but we won't remove buyer from buyers array
        delete purchaseLog[buyer];
        //decrement global counters
        tokensSold = tokensSold.sub(vztValue);
        totalCollected = totalCollected.sub(depositedValue);

        // send must be called only after purchaseLog[buyer] is deleted to
        //prevent reentrancy attack.
        buyer.transfer(depositedValue);
        Refunded(buyer, depositedValue);
        return true;
    }

    function getBuyersList() external view returns (address[]) {
        return buyers;
    }

    /**
        * @dev Transfer all Ether held by the contract to the owner.
        * Emergency where we might need to recover
    */
    function reclaimEther() external onlyOwner {
        assert(owner.send(this.balance));
    }

}