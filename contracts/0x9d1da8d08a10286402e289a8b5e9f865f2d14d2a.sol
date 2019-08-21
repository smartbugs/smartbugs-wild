pragma solidity ^0.4.11;

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {
  function mul(uint256 a, uint256 b) internal constant returns (uint256) {
    uint256 c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal constant returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  function sub(uint256 a, uint256 b) internal constant returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal constant returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }

    function toUINT112(uint256 a) internal constant returns(uint112) {
    assert(uint112(a) == a);
    return uint112(a);
  }

  function toUINT120(uint256 a) internal constant returns(uint120) {
    assert(uint120(a) == a);
    return uint120(a);
  }

  function toUINT128(uint256 a) internal constant returns(uint128) {
    assert(uint128(a) == a);
    return uint128(a);
  }

  function percent(uint256 a, uint256 b) internal constant returns (uint256) {
    uint256 c = (b*a/100) ;
    assert(c <= a);
    return c;
  }
}

contract Owned {

    address public owner;

    function Owned() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    function setOwner(address _newOwner) onlyOwner {
        owner = _newOwner;
    }
}

/**
 * @title ERC20Basic
 * @dev Simpler version of ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/179
 */
contract ERC20Basic {
  function balanceOf(address who) public constant returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}

/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender) public constant returns (uint256);
  function transferFrom(address from, address to, uint256 value) public returns (bool);
  function approve(address spender, uint256 value) public returns (bool);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}

/**
 * @title Basic token
 * @dev Basic version of StandardToken, with no allowances.
 */
contract BasicToken is ERC20Basic {
  using SafeMath for uint256;

  struct Account {
      uint256 balances;
      uint256 rawTokens;
      uint32 lastMintedTimestamp;
    }

    // Balances for each account
    mapping(address => Account) accounts;


  /**
  * @dev transfer token for a specified address
  * @param _to The address to transfer to.
  * @param _value The amount to be transferred.
  */
  function transfer(address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));
    require(_value <= accounts[msg.sender].balances);

    // SafeMath.sub will throw if there is not enough balance.
    accounts[msg.sender].balances = accounts[msg.sender].balances.sub(_value);
    accounts[_to].balances = accounts[_to].balances.add(_value);
    Transfer(msg.sender, _to, _value);
    return true;
  }

  /**
  * @dev Gets the balance of the specified address.
  * @param _owner The address to query the the balance of.
  * @return An uint256 representing the amount owned by the passed address.
  */
  function balanceOf(address _owner) public constant returns (uint256 balance) {
    return accounts[_owner].balances;
  }

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
    require(_value <= accounts[_from].balances);
    require(_value <= allowed[_from][msg.sender]);

    accounts[_from].balances = accounts[_from].balances.sub(_value);
    accounts[_to].balances = accounts[_to].balances.add(_value);
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
  function allowance(address _owner, address _spender) public constant returns (uint256 remaining) {
    return allowed[_owner][_spender];
  }

  /**
   * approve should be called when allowed[_spender] == 0. To increment
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   */
  function increaseApproval (address _spender, uint _addedValue) public returns (bool success) {
    allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
    Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

  function decreaseApproval (address _spender, uint _subtractedValue) public returns (bool success) {
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

contract Infocash is StandardToken, Owned {
    string public constant name    = "Infocash";  
    uint8 public constant decimals = 8;               
    string public constant symbol  = "ICC";
    bool public canClaimToken = false;
    uint256 public constant maxSupply  = 86000000*10**uint256(decimals);
    uint256 public constant dateInit=1514073600  ;
    uint256 public constant dateICO=dateInit + 30 days;
    uint256 public constant dateIT=dateICO + 365 days;
    uint256 public constant dateMarketing=dateIT + 365 days;
    uint256 public constant dateEco=dateMarketing + 365 days;
    uint256 public constant dateManager=dateEco + 365 days; 
    uint256 public constant dateAdmin=dateManager + 365 days;                              
    
    enum Stage {
        NotCreated,
        ICO,
        IT,
        Marketing,
        Eco,
        MgmtSystem,
        Admin,
        Finalized
    }
    // packed to 256bit to save gas usage.
    struct Supplies {
        // uint128's max value is about 3e38.
        // it's enough to present amount of tokens
        uint256 total;
        uint256 rawTokens;
    }

    //the stage for releasing Tokens
    struct StageRelease {
      Stage stage;
      uint256 rawTokens;
      uint256 dateRelease;
    }

    Supplies supplies;
    StageRelease public  stageICO=StageRelease(Stage.ICO, maxSupply.percent(35), dateICO);
    StageRelease public stageIT=StageRelease(Stage.IT, maxSupply.percent(18), dateIT);
    StageRelease public stageMarketing=StageRelease(Stage.Marketing, maxSupply.percent(18), dateMarketing);
    StageRelease public stageEco=StageRelease(Stage.Eco, maxSupply.percent(18), dateEco);
    StageRelease public stageMgmtSystem=StageRelease(Stage.MgmtSystem, maxSupply.percent(9), dateManager);
    StageRelease public stageAdmin=StageRelease(Stage.Admin, maxSupply.percent(2), dateAdmin);

    // Send back ether 
    function () {
      revert();
    }
    //getter totalSupply
    function totalSupply() public constant returns (uint256 total) {
      return supplies.total;
    }
    
    function mintToken(address _owner, uint256 _amount, bool _isRaw) onlyOwner internal {
      require(_amount.add(supplies.total)<=maxSupply);
      if (_isRaw) {
        accounts[_owner].rawTokens=_amount.add(accounts[_owner].rawTokens);
        supplies.rawTokens=_amount.add(supplies.rawTokens);
      } else {
        accounts[_owner].balances=_amount.add(accounts[_owner].balances);
      }
      supplies.total=_amount.add(supplies.total);
      Transfer(0, _owner, _amount);
    }

    function transferRaw(address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));
    require(_value <= accounts[msg.sender].rawTokens);
    

    // SafeMath.sub will throw if there is not enough balance.
    accounts[msg.sender].rawTokens = accounts[msg.sender].rawTokens.sub(_value);
    accounts[_to].rawTokens = accounts[_to].rawTokens.add(_value);
    Transfer(msg.sender, _to, _value);
    return true;
  }

  function setClaimToken(bool approve) onlyOwner public returns (bool) {
    canClaimToken=true;
    return canClaimToken;
  }

    function claimToken(address _owner) public returns (bool amount) {
      require(accounts[_owner].rawTokens!=0);
      require(canClaimToken);

      uint256 amountToken = accounts[_owner].rawTokens;
      accounts[_owner].rawTokens = 0;
      accounts[_owner].balances = amountToken + accounts[_owner].balances;
      return true;
    }

    function balanceOfRaws(address _owner) public constant returns (uint256 balance) {
      return accounts[_owner].rawTokens;
    }

    function blockTime() constant returns (uint32) {
        return uint32(block.timestamp);
    }

    function stage() constant returns (Stage) { 
      if(blockTime()<=dateInit) {
        return Stage.NotCreated;
      }

      if(blockTime()<=dateICO) {
        return Stage.ICO;
      }
        
      if(blockTime()<=dateIT) {
        return Stage.IT;
      }

      if(blockTime()<=dateMarketing) {
        return Stage.Marketing;
      }

      if(blockTime()<=dateEco) {
        return Stage.Eco;
      }

      if(blockTime()<=dateManager) {
        return Stage.MgmtSystem;
      }

      if(blockTime()<=dateAdmin) {
        return Stage.Admin;
      }
      
      return Stage.Finalized;
    }

    function releaseStage (uint256 amount, StageRelease storage stageRelease, bool isRaw) internal returns (uint256) {
      if(stageRelease.rawTokens>0) {
        int256 remain=int256(stageRelease.rawTokens - amount);
        if(remain<0)
          amount=stageRelease.rawTokens;
        stageRelease.rawTokens=stageRelease.rawTokens.sub(amount);
        mintToken(owner, amount, isRaw);
        return amount;
      }
      return 0;
    }

    function release(uint256 amount, bool isRaw) onlyOwner public returns (uint256) {
      uint256 amountSum=0;

      if(stage()==Stage.NotCreated) {
        throw;
      }

      if(stage()==Stage.ICO) {
        releaseStage(amount, stageICO, isRaw);
        amountSum=amountSum.add(amount);
        return amountSum;
      }

      if(stage()==Stage.IT) {
        releaseStage(amount, stageIT, isRaw);
        amountSum=amountSum.add(amount);
        return amountSum;
      }

      if(stage()==Stage.Marketing) {
        releaseStage(amount, stageMarketing, isRaw);
        amountSum=amountSum.add(amount);
        return amountSum;
      }

      if(stage()==Stage.Eco) {
        releaseStage(amount, stageEco, isRaw);
        amountSum=amountSum.add(amount);
        return amountSum;
      }

      if(stage()==Stage.MgmtSystem) {
        releaseStage(amount, stageMgmtSystem, isRaw);
        amountSum=amountSum.add(amount);
        return amountSum;
      }
      
      if(stage()==Stage.Admin ) {
        releaseStage(amount, stageAdmin, isRaw);
        amountSum=amountSum.add(amount);
        return amountSum;
      }
      
      if(stage()==Stage.Finalized) {
        owner=0;
        return 0;
      }
      return amountSum;
    }
}