pragma solidity ^0.4.18;

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {
  function mul(uint256 a, uint256 b) pure internal returns (uint256) {
    uint256 c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) pure internal returns (uint256) {
    assert(b != 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  function sub(uint256 a, uint256 b) pure internal returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) pure internal returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
  
  function mulByFraction(uint256 number, uint256 numerator, uint256 denominator) pure internal returns (uint256) {
      return div(mul(number, numerator), denominator);
  }
}



/**
 * @title ERC20Basic
 * @dev Simpler version of ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/179
 */
contract ERC20Basic {
  uint256 public totalSupply;
  function balanceOf(address who) public view returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
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



/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
  address public owner;


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
  function transferOwnership(address newOwner) public onlyOwner {
    require(newOwner != address(0));
    OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }

}



/**
 * @title Pausable
 * @dev Base contract which allows children to implement an emergency stop mechanism.
 */
contract Pausable is Ownable {

  // timestamps until all tokens transfers are blocked
  uint256 public blockedTimeForBountyTokens = 0;
  uint256 public blockedTimeForInvestedTokens = 0;

  // minimum timestamp that tokens will be blocked for transfers
  uint256 constant MIN_blockedTimeForBountyTokens = 1524949200; //29.04.2018, 0:00:00
  uint256 constant MIN_blockedTimeForInvestedTokens = 1521061200; //15.03.2018, 0:00:00

  //Addresses pre-ico investors
  mapping(address => bool) preIcoAccounts;

  //Addresses bounty campaign
  mapping(address => bool) bountyAccounts;

  //Addresses with founders tokens and flag is it blocking transfers from this address
  mapping(address => uint) founderAccounts; // 1 - block transfers, 2 - do not block transfers

  function Pausable() public {
    blockedTimeForBountyTokens = MIN_blockedTimeForBountyTokens;
    blockedTimeForInvestedTokens = MIN_blockedTimeForInvestedTokens;
  }

  /**
  * @dev called by owner for changing blockedTimeForBountyTokens
  */
  function changeBlockedTimeForBountyTokens(uint256 _blockedTime) onlyOwner external {
    require(_blockedTime < MIN_blockedTimeForBountyTokens);
    blockedTimeForBountyTokens = _blockedTime;
  }

  /**
* @dev called by owner for changing blockedTimeForInvestedTokens
*/
  function changeBlockedTimeForInvestedTokens(uint256 _blockedTime) onlyOwner external {
    require(_blockedTime < MIN_blockedTimeForInvestedTokens);
    blockedTimeForInvestedTokens = _blockedTime;
  }


  /**
   * @dev Modifier to make a function callable only when the contract is not paused.
   */
  modifier whenNotPaused() {
    require(!getPaused());
    _;
  }

  /**
   * @dev Modifier to make a function callable only when the contract is paused.
   */
  modifier whenPaused() {
    require(getPaused());
    _;
  }

  function getPaused() internal returns (bool) {
    if (now > blockedTimeForBountyTokens && now > blockedTimeForInvestedTokens) {
      return false;
    } else {
      uint256 blockedTime = checkTimeForTransfer(msg.sender);
      return now < blockedTime;
    }
  }


  /**
  * @dev called by owner, add preIcoAccount
  */
  function addPreIcoAccounts(address _addr) onlyOwner internal {
    require(_addr != 0x0);
    preIcoAccounts[_addr] = true;
  }

  /**
  * @dev called by owner, add addBountyAccount
  */
  function addBountyAccounts(address _addr) onlyOwner internal {
    require(_addr != 0x0);
    preIcoAccounts[_addr] = true;
  }

  /**
  * @dev called by owner, add founderAccount
  */
  function addFounderAccounts(address _addr, uint _flag) onlyOwner external {
    require(_addr != 0x0);
    founderAccounts[_addr] = _flag;
  }

  /**
   * @dev called by external contract (ImmlaToken) for checking rights for transfers, depends on who owner of this address
   */
  function checkTimeForTransfer(address _account) internal returns (uint256) {
    if (founderAccounts[_account] == 1) {
      return blockedTimeForInvestedTokens;
    } else if(founderAccounts[_account] == 2) {
      return 1; //do not block transfers
    } else if (preIcoAccounts[_account]) {
      return blockedTimeForInvestedTokens;
    } else if (bountyAccounts[_account]) {
      return blockedTimeForBountyTokens;
    } else {
      return blockedTimeForInvestedTokens;
    }
  }
}



/**
 * @title Pausable token
 *
 * @dev StandardToken modified with pausable transfers.
 **/

contract PausableToken is StandardToken, Pausable {

  function transfer(address _to, uint256 _value) public whenNotPaused returns (bool) {
    return super.transfer(_to, _value);
  }

  function transferFrom(address _from, address _to, uint256 _value) public whenNotPaused returns (bool) {
    return super.transferFrom(_from, _to, _value);
  }

  function approve(address _spender, uint256 _value) public whenNotPaused returns (bool) {
    return super.approve(_spender, _value);
  }

  function increaseApproval(address _spender, uint _addedValue) public whenNotPaused returns (bool success) {
    return super.increaseApproval(_spender, _addedValue);
  }

  function decreaseApproval(address _spender, uint _subtractedValue) public whenNotPaused returns (bool success) {
    return super.decreaseApproval(_spender, _subtractedValue);
  }
}




/**
 * @title Mintable token
 * @dev Simple ERC20 Token example, with mintable token creation
 * @dev Issue: * https://github.com/OpenZeppelin/zeppelin-solidity/issues/120
 * Based on code by TokenMarketNet: https://github.com/TokenMarketNet/ico/blob/master/contracts/MintableToken.sol
 */

contract MintableToken is PausableToken {
  event Mint(address indexed to, uint256 amount);
  event MintFinished();

  bool public mintingFinished = false;


  modifier canMint() {
    require(!mintingFinished);
    _;
  }

  /**
   * @dev Function to mint tokens
   * @param _to The address that will receive the minted tokens.
   * @param _amount The amount of tokens to mint.
   * @return A boolean that indicates if the operation was successful.
   */
  function mint(address _to, uint256 _amount) onlyOwner canMint public returns (bool) {
    totalSupply = totalSupply.add(_amount);
    balances[_to] = balances[_to].add(_amount);
    Mint(_to, _amount);
    Transfer(address(0), _to, _amount);
    return true;
  }

  /**
   * @dev called by the owner to mint tokens for pre-ico
   */
  function multiMintPreico(address[] _dests, uint256[] _values) onlyOwner canMint public returns (uint256) {
    uint256 i = 0;
    uint256 count = _dests.length;
    while (i < count) {
      totalSupply = totalSupply.add(_values[i]);
      balances[_dests[i]] = balances[_dests[i]].add(_values[i]);
      addPreIcoAccounts(_dests[i]);
      Mint(_dests[i], _values[i]);
      Transfer(address(0), _dests[i], _values[i]);
      i += 1;
    }
    return(i);
  }

  /**
   * @dev called by the owner to mint tokens for pre-ico
   */
  function multiMintBounty(address[] _dests, uint256[] _values) onlyOwner canMint public returns (uint256) {
    uint256 i = 0;
    uint256 count = _dests.length;
    while (i < count) {
      totalSupply = totalSupply.add(_values[i]);
      balances[_dests[i]] = balances[_dests[i]].add(_values[i]);
      addBountyAccounts(_dests[i]);
      Mint(_dests[i], _values[i]);
      Transfer(address(0), _dests[i], _values[i]);
      i += 1;
    }
    return(i);
  }

  /**
   * @dev Function to stop minting new tokens.
   * @return True if the operation was successful.
   */
  function finishMinting() onlyOwner canMint public returns (bool) {
    mintingFinished = true;
    MintFinished();
    return true;
  }
}



/**
 * @title ERC20 token that transferable by owner
 */
contract TransferableByOwner is StandardToken, Ownable {

  // timestamp until owner could transfer all tokens
  uint256 constant public OWNER_TRANSFER_TOKENS = now + 1 years;

  /**
   * @dev Transfer tokens from one address to another by owner
   * @param _from address The address which you want to send tokens from
   * @param _to address The address which you want to transfer to
   * @param _value uint256 the amount of tokens to be transferred
   */
  function transferByOwner(address _from, address _to, uint256 _value) onlyOwner public returns (bool) {
    require(now < OWNER_TRANSFER_TOKENS);
    require(_to != address(0));
    require(_value <= balances[_from]);

    balances[_from] = balances[_from].sub(_value);
    balances[_to] = balances[_to].add(_value);
    Transfer(_from, _to, _value);
    return true;
  }
}



contract ImmlaToken is MintableToken, TransferableByOwner {
    using SafeMath for uint256;

    /*
     * Token meta data
     */
    string public constant name = "IMMLA";
    string public constant symbol = "IML";
    uint8 public constant decimals = 18;
}



contract ImmlaDistribution is Ownable {
    using SafeMath for uint256;

    // minimum amount of tokens a buyer gets per 1 ether
    uint256 constant RATE_MIN = 3640;

    // timestamp until owner could transfer all tokens
    uint256 constant public OWNER_TRANSFER_TOKENS = now + 1 years;

    // The token being sold
    ImmlaToken public token;

    //maximum tokens for mint in additional emission
    uint256 public constant emissionLimit = 418124235 * 1 ether;

    // amount of tokens that already minted in additional emission
    uint256 public additionalEmission = 0;

    // amount of token that currently available for buying
    uint256 public availableEmission = 0;

    bool public mintingPreIcoFinish = false;
    bool public mintingBountyFinish = false;
    bool public mintingFoundersFinish = false;

    // address where funds are collected (by default t_Slava address)
    address public wallet;

    // how many token units a buyer gets per 1 ether
    uint256 public rate;

    address constant public t_ImmlaTokenDepository = 0x64075EEf64d9E105A61227CcCd5fA9F6b54DB278;
    address constant public t_ImmlaTokenDepository2 = 0x2Faaf371Af6392fdd3016E111fB4b3B551Ee46aB;
    address constant public t_ImmlaBountyTokenDepository = 0x5AB08C5Dfd53b8f6f6C3e3bbFDb521170C3863B0;
    address constant public t_Andrey = 0x027810A9C17cb0E739a33769A9E794AAF40D2338;
    address constant public t_Michail = 0x00af06cF0Ae6BD83fC36b6Ae092bb4F669B6dbF0;
    address constant public t_Slava = 0x00c11E5B0b5db0234DfF9a357F56077c9a7A83D0;
    address constant public t_Andrey2 = 0xC7e788FeaE61503136021cC48a0c95bB66d0B9f2;
    address constant public t_Michail2 = 0xb6f4ED2CE19A08c164790419D5d87D3074D4Bd92;
    address constant public t_Slava2 = 0x00ded30026135fBC460c2A9bf7beC06c7F31101a;

    /**
     * @dev Proposals for mint tokens to some address
     */
    mapping(address => Proposal) public proposals;

    struct Proposal {
        address wallet;
        uint256 amount;
        uint256 numberOfVotes;
        mapping(address => bool) voted;
    }

    /**
     * @dev Members of congress
     */
    mapping(address => bool) public congress;

    /**
     * @dev Minimal quorum value
     */
    uint256 public minimumQuorum = 1;

    /**
   * event for token purchase logging
   * @param purchaser who paid for the tokens
   * @param value weis paid for purchase
   * @param amount amount of tokens purchased
   */
    event TokenPurchase(address indexed purchaser, uint256 value, uint256 amount);

    /**
     * @dev On proposal added
     * @param congressman Congressman address
     * @param wallet Wallet
     * @param amount Amount of wei to transfer
     */
    event ProposalAdded(address indexed congressman, address indexed wallet, uint256 indexed amount);

    /**
     * @dev On proposal passed
     * @param congressman Congressman address
     * @param wallet Wallet
     * @param amount Amount of wei to transfer
     */
    event ProposalPassed(address indexed congressman, address indexed wallet, uint256 indexed amount);

    /**
   * @dev Modifier to make a function callable only when the minting for pre-ico is not paused.
   */
    modifier whenNotPreIcoFinish() {
        require(!mintingPreIcoFinish);
        _;
    }

    /**
   * @dev Modifier to make a function callable only when the minting for bounty is not paused.
   */
    modifier whenNotBountyFinish() {
        require(!mintingBountyFinish);
        _;
    }

    /**
   * @dev Modifier to make a function callable only when the minting for bounty is not paused.
   */
    modifier whenNotMintingFounders() {
        require(!mintingFoundersFinish);
        _;
    }

    /**
     * @dev Modifier that allows only congress to vote and create new proposals
     */
    modifier onlyCongress {
        require (congress[msg.sender]);
        _;
    }

    /*
     * ImmlaDistribution constructor
     */
    function ImmlaDistribution(address _token) public payable { // gas 6297067
        token = ImmlaToken(_token);

        //@TODO - change this to t_Slava (0x00c11E5B0b5db0234DfF9a357F56077c9a7A83D0) address or deploy contract from this address
        owner = 0x00c11E5B0b5db0234DfF9a357F56077c9a7A83D0;

        wallet = owner;
        rate = RATE_MIN;

        congress[t_Andrey] = true;
        congress[t_Michail] = true;
        congress[t_Slava] = true;
        minimumQuorum = 3;
    }

    /**
   * @dev called by the owner to mint tokens to founders
   */
    function mintToFounders() onlyOwner whenNotMintingFounders public returns (bool) {
        mintToFounders(t_ImmlaTokenDepository, 52000 * 1 ether, 2);
        mintToFounders(t_ImmlaTokenDepository2, 0, 2);
        mintToFounders(t_ImmlaBountyTokenDepository, 0, 2);
        mintToFounders(t_Andrey,   525510849836086000000000, 1);
        mintToFounders(t_Michail,  394133137377065000000000, 1);
        mintToFounders(t_Slava,    394133137377065000000000, 1);
        mintToFounders(t_Andrey2,  284139016853060000000000, 2);
        mintToFounders(t_Michail2, 213104262639795000000000, 2);
        mintToFounders(t_Slava2,   213104262639795000000000, 2);
        mintingFoundersFinish = true;

        return true;
    }

    // fallback function can be used to buy tokens
    function () external payable {
        buyTokens();
    }

    // low level token purchase function
    function buyTokens() public payable {
        require(availableEmission > 0);
        require(msg.value != 0);

        address investor = msg.sender;
        uint256 weiAmount = msg.value;

        uint256 tokensAmount = weiAmount.mul(rate);

        //calculate change
        uint256 tokensChange = 0;
        if (tokensAmount > availableEmission) {
            tokensChange = tokensAmount - availableEmission;
            tokensAmount = availableEmission;
        }

        //make change
        uint256 weiChange = 0;
        if (tokensChange > 0) {
            weiChange = tokensChange.div(rate);
            investor.transfer(weiChange);
        }

        uint256 weiRaised = weiAmount - weiChange;

        // update raised amount and additional emission
        additionalEmission = additionalEmission.add(tokensAmount);
        availableEmission = availableEmission.sub(tokensAmount);

        //send tokens to investor
        token.mint(investor, tokensAmount);
        TokenPurchase(investor, weiRaised, tokensAmount);
        mintBonusToFounders(tokensAmount);

        //send ether to owner wallet
        wallet.transfer(weiRaised);
    }

    /**
   * @dev called by the owner to make additional emission
   */
    function updateAdditionalEmission(uint256 _amount, uint256 _rate) onlyOwner public { // gas 48191
        require(_amount > 0);
        require(_amount < (emissionLimit - additionalEmission));

        availableEmission = _amount;
        if (_rate > RATE_MIN) {
            rate = RATE_MIN;
        } else {
            rate = _rate;
        }
    }

    /**
   * @dev called by the owner to stop minting
   */
    function stopPreIcoMint() onlyOwner whenNotPreIcoFinish public {
        mintingPreIcoFinish = true;
    }

    /**
   * @dev called by the owner to stop minting
   */
    function stopBountyMint() onlyOwner whenNotBountyFinish public {
        mintingBountyFinish = true;
    }

    /**
   * @dev called by the owner to mint tokens for pre-ico
   */
    function multiMintPreIco(address[] _dests, uint256[] _values) onlyOwner whenNotPreIcoFinish public returns (bool) {
        token.multiMintPreico(_dests, _values);
        return true;
    }

    /**
   * @dev called by the owner to mint tokens for bounty
   */
    function multiMintBounty(address[] _dests, uint256[] _values) onlyOwner whenNotBountyFinish public returns (bool) {
        token.multiMintBounty(_dests, _values);
        return true;
    }

    /**
   * @dev called to mint tokens to founders
   */
    function mintToFounders(address _dest, uint256 _value, uint _flag) internal {
        token.mint(_dest, _value);
        token.addFounderAccounts(_dest, _flag);
    }

    /**
   * @dev called to mint bonus tokens to founders
   */
    function mintBonusToFounders(uint256 _value) internal {

        uint256 valueWithCoefficient = (_value * 1000) / 813;
        uint256 valueWithMultiplier1 = valueWithCoefficient / 10;
        uint256 valueWithMultiplier2 = (valueWithCoefficient * 7) / 100;

        token.mint(t_Andrey, (valueWithMultiplier1 * 4) / 10);
        token.mint(t_Michail, (valueWithMultiplier1 * 3) / 10);
        token.mint(t_Slava, (valueWithMultiplier1 * 3) / 10);
        token.mint(t_Andrey2, (valueWithMultiplier2 * 4) / 10);
        token.mint(t_Michail2, (valueWithMultiplier2 * 3) / 10);
        token.mint(t_Slava2, (valueWithMultiplier2 * 3) / 10);
        token.mint(t_ImmlaBountyTokenDepository, (valueWithCoefficient * 15) / 1000);
    }

    /**
  * @dev called by owner for changing blockedTimeForBountyTokens
  */
    function changeBlockedTimeForBountyTokens(uint256 _blockedTime) onlyOwner public {
        token.changeBlockedTimeForBountyTokens(_blockedTime);
    }

    /**
  * @dev called by owner for changing blockedTimeForInvestedTokens
  */
    function changeBlockedTimeForInvestedTokens(uint256 _blockedTime) onlyOwner public {
        token.changeBlockedTimeForInvestedTokens(_blockedTime);
    }

    /**
     * @dev Create a new proposal
     * @param _wallet Beneficiary account address
     * @param _amount Amount of tokens
     */
    function proposal(address _wallet, uint256 _amount) onlyCongress public {
        require(availableEmission > 0);
        require(_amount > 0);
        require(_wallet != 0x0);
        
        if (proposals[_wallet].amount > 0) {
            require(proposals[_wallet].voted[msg.sender] != true); // If has already voted, cancel
            require(proposals[_wallet].amount == _amount); // If amounts is equal

            proposals[_wallet].voted[msg.sender] = true; // Set this voter as having voted
            proposals[_wallet].numberOfVotes++; // Increase the number of votes

            //proposal passed
            if (proposals[_wallet].numberOfVotes >= minimumQuorum) {
                if (_amount > availableEmission) {
                    _amount = availableEmission;
                }

                // update raised amount and additional emission
                additionalEmission = additionalEmission.add(_amount);
                availableEmission = availableEmission.sub(_amount);

                token.mint(_wallet, _amount);
                TokenPurchase(_wallet, 0, _amount);
                ProposalPassed(msg.sender, _wallet, _amount);

                mintBonusToFounders(_amount);
                delete proposals[_wallet];
            }

        } else {
            Proposal storage p = proposals[_wallet];

            p.wallet           = _wallet;
            p.amount           = _amount;
            p.numberOfVotes    = 1;
            p.voted[msg.sender] = true;

            ProposalAdded(msg.sender, _wallet, _amount);
        }
    }

    /**
  * @dev called by owner for transfer tokens
  */
    function transferTokens(address _from, address _to, uint256 _amount) onlyOwner public {
        require(_amount > 0);

        //can't transfer after OWNER_TRANSFER_TOKENS date (after 1 year)
        require(now < OWNER_TRANSFER_TOKENS);

        //can't transfer from and to congressman addresses
        require(!congress[_from]);
        require(!congress[_to]);

        token.transferByOwner(_from, _to, _amount);
    }
}