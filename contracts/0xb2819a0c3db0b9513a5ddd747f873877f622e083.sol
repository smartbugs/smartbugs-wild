pragma solidity 0.4.20;

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
  address public owner;
  uint public totalSupply = 0;

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
    require (msg.sender == owner);
    _;
  }

  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param newOwner The address to transfer ownership to.
   */
  function transferOwnership(address newOwner) public onlyOwner {
    if (newOwner != address(0)) {
      owner = newOwner;
    }
  }

}


/**
 * @title Authorizable
 * @dev Allows to authorize access to certain function calls
 *
 * ABI
 *
 */
contract Authorizable {
 
  address[] authorizers;
  mapping(address => uint256) authorizerIndex;
 
  /**
   * @dev Throws if called by any account that is not authorized.
   */
  modifier onlyAuthorized {
    require(isAuthorized(msg.sender));
    _;
  }
 
  /**
   * @dev Contructor that authorizes the msg.sender.
   */
  function Authorizable() public {
    authorizers.length = 2;
    authorizers[1] = msg.sender;
    authorizerIndex[msg.sender] = 1;
  }
 
  /**
   * @dev Function to get a specific authorizer
   * @param authIndex index of the authorizer to be retrieved.
   * @return The address of the authorizer.
   */
  function getAuthorizer(uint256 authIndex) external constant returns(address) {
    return address(authorizers[authIndex + 1]);
  }
 
  /**
   * @dev Function to check if an address is authorized
   * @param _addr the address to check if it is authorized.
   * @return boolean flag if address is authorized.
   */
  function isAuthorized(address _addr) public constant returns(bool) {
    return authorizerIndex[_addr] > 0;
  }
 
  /**
   * @dev Function to add a new authorizer
   * @param _addr the address to add as a new authorizer.
   */
  function addAuthorized(address _addr) external onlyAuthorized {
    authorizerIndex[_addr] = authorizers.length;
    authorizers.length++;
    authorizers[authorizers.length - 1] = _addr;
  }
}


/**
 * Math operations with safety checks
 */
library SafeMath {
  function mul(uint a, uint b) internal pure returns (uint) {
    uint c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function div(uint a, uint b) internal pure returns (uint) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  function sub(uint a, uint b) internal pure returns (uint) {
    assert(b <= a);
    return a - b;
  }

  function add(uint a, uint b) internal pure returns (uint) {
    uint c = a + b;
    assert(c >= a);
    return c;
  }

  function max64(uint64 a, uint64 b) internal pure returns (uint64) {
    return a >= b ? a : b;
  }

  function min64(uint64 a, uint64 b) internal pure returns (uint64) {
    return a < b ? a : b;
  }

  function max256(uint256 a, uint256 b) internal pure returns (uint256) {
    return a >= b ? a : b;
  }

  function min256(uint256 a, uint256 b) internal pure returns (uint256) {
    return a < b ? a : b;
  }

  //function assert(bool _assertion) internal pure {
  //  require (_assertion);
  //}
}


/**
 * @title ERC20Basic
 * @dev Simpler version of ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20Basic {
  function balanceOf(address who) public constant returns (uint);
  function transfer(address to, uint value) public;
  event Transfer(address indexed from, address indexed to, uint value);
}


/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender) public constant returns (uint);
  function transferFrom(address from, address to, uint value) public;
  function approve(address spender, uint value) public;
  event Approval(address indexed owner, address indexed spender, uint value);
}


/**
 * @title Basic token
 * @dev Basic version of StandardToken, with no allowances.
 */
contract BasicToken is ERC20Basic {
  using SafeMath for uint;
  mapping(address => uint) public balances;

  /**
   * @dev Fix for the ERC20 short address attack.
   */
  modifier onlyPayloadSize(uint size) {
     require(msg.data.length >= size + 4);
     _;
  }

  /**
  * @dev transfer token for a specified address
  * @param _to The address to transfer to.
  * @param _value The amount to be transferred.
  */
  function transfer(address _to, uint _value) public onlyPayloadSize(2 * 32) {
    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);
    Transfer(msg.sender, _to, _value);
  }

  /**
  * @dev Gets the balance of the specified address.
  * @param _owner The address to query the the balance of.
  * @return An uint representing the amount owned by the passed address.
  */
  function balanceOf(address _owner) public constant returns (uint balance) {
    return balances[_owner];
  }

}


/**
 * @title Standard ERC20 token
 *
 * @dev Implemantation of the basic standart token.
 * @dev https://github.com/ethereum/EIPs/issues/20
 * @dev Based on code by FirstBlood: https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol
 */
contract StandardToken is BasicToken, ERC20 {

  mapping (address => mapping (address => uint)) allowed;

  /**
   * @dev Transfer tokens from one address to another
   * @param _from address The address which you want to send tokens from
   * @param _to address The address which you want to transfer to
   * @param _value uint the amout of tokens to be transfered
   */
  function transferFrom(address _from, address _to, uint _value) public onlyPayloadSize(3 * 32) {
    uint _allowance = allowed[_from][msg.sender];
    balances[_to] = balances[_to].add(_value);
    balances[_from] = balances[_from].sub(_value);
    allowed[_from][msg.sender] = _allowance.sub(_value);
    Transfer(_from, _to, _value);
  }

  /**
   * @dev Aprove the passed address to spend the specified amount of tokens on beahlf of msg.sender.
   * @param _spender The address which will spend the funds.
   * @param _value The amount of tokens to be spent.
   */
  function approve(address _spender, uint _value) public {

    // To change the approve amount you first have to reduce the addresses`
    // allowance to zero by calling `approve(_spender, 0)` if it is not
    // already 0 to mitigate the race condition described here:
    // https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
    // if ((_value != 0) && (allowed[msg.sender][_spender] != 0)) throw;
    require(!((_value != 0) && (allowed[msg.sender][_spender] != 0)));

    allowed[msg.sender][_spender] = _value;
    Approval(msg.sender, _spender, _value);
  }

  /**
   * @dev Function to check the amount of tokens than an owner allowed to a spender.
   * @param _owner address The address which owns the funds.
   * @param _spender address The address which will spend the funds.
   * @return A uint specifing the amount of tokens still avaible for the spender.
   */
  function allowance(address _owner, address _spender) public constant returns (uint remaining) {
    return allowed[_owner][_spender];
  }

}


/**
 * @title Mintable token
 * @dev Simple ERC20 Token example, with mintable token creation
 * @dev Issue: * https://github.com/OpenZeppelin/zeppelin-solidity/issues/120
 * Based on code by TokenMarketNet: https://github.com/TokenMarketNet/ico/blob/master/contracts/MintableToken.sol
 */

contract MintableToken is StandardToken, Ownable {
  event Mint(address indexed to, uint value);
  event MintFinished();

  bool public mintingFinished = false;

  modifier canMint() {
    require(!mintingFinished);
    _;
  }

  /**
   * @dev Function to mint tokens
   * @param _to The address that will recieve the minted tokens.
   * @param _amount The amount of tokens to mint.
   * @return A boolean that indicates if the operation was successful.
   */
  function mint(address _to, uint _amount) onlyOwner canMint public returns (bool) {
    totalSupply = totalSupply.add(_amount);
    balances[_to] = balances[_to].add(_amount);
    Mint(_to, _amount);
    return true;
  }

  /**
   * @dev Function to stop minting new tokens.
   * @return True if the operation was successful.
   */
  function finishMinting() public onlyOwner returns (bool) {
    mintingFinished = true;
    MintFinished();
    return true;
  }
}


/**
 * @title RecToken
 * @dev The main REC token contract
 *
 * ABI
 *
 */
contract RecToken is MintableToken {
  string public standard = "Renta.City";
  string public name = "Renta.City";
  string public symbol = "REC";
  uint public decimals = 18;
  address public saleAgent;

  bool public tradingStarted = false;

  /**
   * @dev modifier that throws if trading has not started yet
   */
  modifier hasStartedTrading() {
    require(tradingStarted);
    _;
  }

  /**
   * @dev Allows the owner to enable the trading. This can not be undone
   */
  function startTrading() public onlyOwner {
    tradingStarted = true;
  }

  /**
   * @dev Allows anyone to transfer the REC tokens once trading has started
   * @param _to the recipient address of the tokens.
   * @param _value number of tokens to be transfered.
   */
  function transfer(address _to, uint _value) public hasStartedTrading {
    super.transfer(_to, _value);
  }

   /**
   * @dev Allows anyone to transfer the REC tokens once trading has started
   * @param _from address The address which you want to send tokens from
   * @param _to address The address which you want to transfer to
   * @param _value uint the amout of tokens to be transfered
   */
  function transferFrom(address _from, address _to, uint _value) public hasStartedTrading {
    super.transferFrom(_from, _to, _value);
  }
  
  function set_saleAgent(address _value) public onlyOwner {
    saleAgent = _value;
  }
}


/**
 * @title MainSale
 * @dev The main REC token sale contract
 *
 * ABI
 *
 */
contract MainSale is Ownable, Authorizable {
  using SafeMath for uint;
  event TokenSold(address recipient, uint ether_amount, uint pay_amount, uint exchangerate);
  event AuthorizedCreate(address recipient, uint pay_amount);
  event MainSaleClosed();

  RecToken public token = new RecToken();

  address public multisigVault;
  mapping(address => uint) public balances;

  uint public hardcap = 100000 ether;
  uint public altDeposits = 0;
  uint public start = 1519862400; 
  uint public rate = 1000000000000000000000;
  bool public isRefund = false;

  uint public stage_Days = 30 days;
  uint public stage_Discount = 0;

  uint public commandPercent = 10;
  uint public refererPercent = 2;
  uint public bountyPercent = 2;

  uint public maxBountyTokens = 0;
  uint public maxTokensForCommand = 0;
  uint public issuedBounty = 0;			// <= 2% from total emission
  uint public issuedTokensForCommand = 0;       // <= 10% from total emission

  /**
   * @dev modifier to allow token creation only when the sale IS ON
   */
  modifier saleIsOn() {
    require(now > start && now < start + stage_Days);
    _;
  }

  /**
   * @dev modifier to allow token creation only when the hardcap has not been reached
   */
  modifier isUnderHardCap() {
    require(multisigVault.balance + altDeposits <= hardcap);
    _;
  }

  /**
   * Convert bytes to address
   */
  function bytesToAddress(bytes source) internal pure returns(address) {
     uint result;
     uint mul = 1;
     for(uint i = 20; i > 0; i--) {
        result += uint8(source[i-1])*mul;
        mul = mul*256;
     }
     return address(result);
    }

  /**
   * @dev Allows the owner to set the periods of ICO in days(!).
   */
  function set_stage_Days(uint _value) public onlyOwner {
    stage_Days = _value * 1 days;
  }

  function set_stage_Discount(uint _value) public onlyOwner {
    stage_Discount = _value;
  }

  function set_commandPercent(uint _value) public onlyOwner {
    commandPercent = _value;
  }

  function set_refererPercent(uint _value) public onlyOwner {
    refererPercent = _value;
  }

  function set_bountyPercent(uint _value) public onlyOwner {
    bountyPercent = _value;
  }

  function set_Rate(uint _value) public onlyOwner {
    rate = _value * 1 ether;
  }
  
  /**
   * @dev Allows anyone to create tokens by depositing ether.
   * @param recipient the recipient to receive tokens.
   */
  function createTokens(address recipient) public isUnderHardCap saleIsOn payable {
    require(msg.value >= 0.01 ether);
    
    // Calculate discounts
    uint CurrentDiscount = 0;
    if (now > start && now < (start + stage_Days)) {CurrentDiscount = stage_Discount;}
    
    // Calculate tokens
    uint tokens = rate.mul(msg.value).div(1 ether);
    tokens = tokens + tokens.mul(CurrentDiscount).div(100);
    token.mint(recipient, tokens);
    balances[msg.sender] = balances[msg.sender].add(msg.value);
    maxBountyTokens = token.totalSupply().mul(bountyPercent).div(100-bountyPercent).div(1 ether);
    maxTokensForCommand = token.totalSupply().mul(commandPercent).div(100-commandPercent).div(1 ether);
    
    require(multisigVault.send(msg.value));
    TokenSold(recipient, msg.value, tokens, rate);

    // Transfer 2% => to Referer
    address referer = 0x0;
    if(msg.data.length == 20) {
        referer = bytesToAddress(bytes(msg.data));
        require(referer != msg.sender);
        uint refererTokens = tokens.mul(refererPercent).div(100);
        if (referer != 0x0 && refererTokens > 0) {
    	    token.mint(referer, refererTokens);
    	    maxBountyTokens = token.totalSupply().mul(bountyPercent).div(100-bountyPercent).div(1 ether);
    	    maxTokensForCommand = token.totalSupply().mul(commandPercent).div(100-commandPercent).div(1 ether);
    	    TokenSold(referer, 0, refererTokens, rate);
        }
    }
  }

  /**
   * @dev Allows the owner to mint tokens for Command (<= 10%)
   */
  function mintTokensForCommand(address recipient, uint tokens) public onlyOwner returns (bool){
    maxTokensForCommand = token.totalSupply().mul(commandPercent).div(100-commandPercent).div(1 ether);
    if (tokens <= (maxTokensForCommand - issuedTokensForCommand)) {
        token.mint(recipient, tokens * 1 ether);
	issuedTokensForCommand = issuedTokensForCommand + tokens;
        maxTokensForCommand = token.totalSupply().mul(commandPercent).div(100-commandPercent).div(1 ether);
        TokenSold(recipient, 0, tokens * 1 ether, rate);
        return(true);
    }
    else {return(false);}
  }

  /**
   * @dev Allows the owner to mint tokens for Bounty (<= 2%)
   */
  function mintBounty(address recipient, uint tokens) public onlyOwner returns (bool){
    maxBountyTokens = token.totalSupply().mul(bountyPercent).div(100-bountyPercent).div(1 ether);
    if (tokens <= (maxBountyTokens - issuedBounty)) {
        token.mint(recipient, tokens * 1 ether);
	issuedBounty = issuedBounty + tokens;
        maxBountyTokens = token.totalSupply().mul(bountyPercent).div(100-bountyPercent).div(1 ether);
        TokenSold(recipient, 0, tokens * 1 ether, rate);
        return(true);
    }
    else {return(false);}
  }

  function refund() public {
      require(isRefund);
      uint value = balances[msg.sender]; 
      balances[msg.sender] = 0; 
      msg.sender.transfer(value); 
    }

  function startRefund() public onlyOwner {
      isRefund = true;
    }

  function stopRefund() public onlyOwner {
      isRefund = false;
    }

  /**
   * @dev Allows to set the total alt deposit measured in ETH to make sure the hardcap includes other deposits
   * @param totalAltDeposits total amount ETH equivalent
   */
  function setAltDeposit(uint totalAltDeposits) public onlyOwner {
    altDeposits = totalAltDeposits;
  }

  /**
   * @dev Allows the owner to set the hardcap.
   * @param _hardcap the new hardcap
   */
  function setHardCap(uint _hardcap) public onlyOwner {
    hardcap = _hardcap;
  }

  /**
   * @dev Allows the owner to set the starting time.
   * @param _start the new _start
   */
  function setStart(uint _start) public onlyOwner {
    start = _start;
  }

  /**
   * @dev Allows the owner to set the multisig contract.
   * @param _multisigVault the multisig contract address
   */
  function setMultisigVault(address _multisigVault) public onlyOwner {
    if (_multisigVault != address(0)) {
      multisigVault = _multisigVault;
    }
  }

  /**
   * @dev Allows the owner to finish the minting. This will create the
   * restricted tokens and then close the minting.
   * Then the ownership of the REC token contract is transfered
   * to this owner.
   */
  function finishMinting() public onlyOwner {
    uint issuedTokenSupply = token.totalSupply();
    uint restrictedTokens = issuedTokenSupply.mul(commandPercent).div(100-commandPercent);
    token.mint(multisigVault, restrictedTokens);
    token.finishMinting();
    token.transferOwnership(owner);
    MainSaleClosed();
  }

  /**
   * @dev Allows the owner to transfer ERC20 tokens to the multi sig vault
   * @param _token the contract address of the ERC20 contract
   */
  function retrieveTokens(address _token) public payable {
    require(msg.sender == owner);
    ERC20 erctoken = ERC20(_token);
    erctoken.transfer(multisigVault, erctoken.balanceOf(this));
  }

  /**
   * @dev Fallback function which receives ether and created the appropriate number of tokens for the
   * msg.sender.
   */
  function() external payable {
    createTokens(msg.sender);
  }

}