pragma solidity ^0.4.19;

library SafeMath {
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a * b;
        assert(a == 0 || c / a == b);
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
}

contract Ownable {
  address public owner;


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
    if (msg.sender != owner) {
      revert();
    }
    _;
 }

  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param newOwner The address to transfer ownership to. 
   */
  function transferOwnership(address newOwner) public onlyOwner {
      owner = newOwner;
  }
 
}
  
contract ERC20 {

    function totalSupply() public constant returns (uint256);
    function balanceOf(address who) public constant returns (uint256);
    function transfer(address to, uint256 value) public;
    function transferFrom(address from, address to, uint256 value) public;
    function approve(address spender, uint256 value) public;
    function allowance(address owner, address spender) public constant returns (uint256);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

}

contract RAOToken is Ownable, ERC20 {

    using SafeMath for uint256;

    // Token properties
    string public name = "RadioYo Coin";
    string public symbol = "RAO";
    uint256 public decimals = 18;
    uint256 public numberDecimal18 = 1000000000000000000;

    uint256 public initialPrice = 3000e18;
    uint256 public _totalSupply = 33000000e18;
    uint256 public _icoSupply = 33000000e18;
    uint256 public _softcap = 165000e18;

    // Balances for each account
    mapping (address => uint256) balances;

    // whitelisting users
    mapping (address => bool) whitelist;

    // time seal for upper management
    mapping (address => uint256) vault;
    
    
    //Balances for waiting KYC approving
    mapping (address => uint256) balancesWaitingKYC;

    // Owner of account approves the transfer of an amount to another account
    mapping (address => mapping(address => uint256)) allowed;
    
    // start and end timestamps where investments are allowed (both inclusive)
    uint256 public startTime; 
    uint256 public endTime; 
    uint256 public sealdate;

    // Wallet Address of Token
    address public multisig;

    // how many token units a buyer get in base unit 
    uint256 public RATE;

    uint256 public kycLevel = 15 ether;


    uint256 public hardCap = 200000000e18;
    
    //number of total tokens sold 
    uint256 public totalNumberTokenSold=0;

    bool public mintingFinished = false;

    bool public tradable = true;

    bool public active = true;

    event MintFinished();
    event StartTradable();
    event PauseTradable();
    event HaltTokenAllOperation();
    event ResumeTokenAllOperation();
    event TokenPurchase(address indexed purchaser, address indexed beneficiary, uint256 value, uint256 amount);
    event Burn(address indexed burner, uint256 value);


    modifier canMint() {
        require(!mintingFinished);
        _;
    }

    modifier canTradable() {
        require(tradable);
        _;
    }

    modifier isActive() {
        require(active);
        _;
    }
    
    modifier saleIsOpen(){
        require(startTime <= getNow() && getNow() <= endTime);
        _;
    }

    // Constructor
    // @notice RAOToken Contract
    // @return the transaction address
    function RAOToken(address _multisig) public {
        require(_multisig != 0x0);
        multisig = _multisig;
        RATE = initialPrice;
        startTime = now;

        // the balances will be sealed for 6 months
        sealdate = startTime + 180 days;

        // for now the token sale will run for 30 days
        endTime = startTime + 60 days;
        balances[multisig] = _totalSupply;

        owner = msg.sender;
    }

    // Payable method
    // @notice Anyone can buy the tokens on tokensale by paying ether
    function () external payable {
        
        if (!validPurchase()) {
            refundFunds(msg.sender);
        }
        
        tokensale(msg.sender);
    }

    function whitelisted(address user) public constant returns (bool) {
        return whitelist[user];
    }

    // @notice tokensale
    // @param recipient The address of the recipient
    // @return the transaction address and send the event as Transfer
    function tokensale(address recipient) internal canMint isActive saleIsOpen {
        require(recipient != 0x0);
        require(whitelisted(recipient));
        
        uint256 weiAmount = msg.value;
        uint256 numberRaoToken = weiAmount.mul(RATE).div(1 ether);
        
        require(_icoSupply >= numberRaoToken);   
                
        totalNumberTokenSold = totalNumberTokenSold.add(numberRaoToken);

        _icoSupply = _icoSupply.sub(numberRaoToken);

        TokenPurchase(msg.sender, recipient, weiAmount, numberRaoToken);

         if (weiAmount < kycLevel) {
            updateBalances(recipient, numberRaoToken);
         } else {
            balancesWaitingKYC[recipient] = balancesWaitingKYC[recipient].add(numberRaoToken); 
         }
        forwardFunds();
        // a sender can only buy once per white list entry
        setWhitelistStatus(recipient, false);
         
    }
    
    function updateBalances(address receiver, uint256 tokens) internal {
        balances[multisig] = balances[multisig].sub(tokens);
        balances[receiver] = balances[receiver].add(tokens);
    }
    
    //refund back if not KYC approved
     function refundFunds(address origin) internal {
        origin.transfer(msg.value);
    }

    // send ether to the fund collection wallet
    // override to create custom fund forwarding mechanisms
    function forwardFunds() internal {
        multisig.transfer(msg.value);
    }

    function setWhitelistStatus(address user,bool status) public returns (bool) {
        if (status == true) {
            //only owner can set whitelist
            require(msg.sender == owner);
            whitelist[user] = true;        
        } else {
            // owner and the user themselves can remove them selves from whitelist
            require(msg.sender == owner || msg.sender == user);
            whitelist[user] = false;
        }
        return whitelist[user];
    }
    
    function setWhitelistForBulk(address[] listAddresses, bool status) public onlyOwner {
        for (uint256 i = 0; i < listAddresses.length; i++) {
            whitelist[listAddresses[i]] = status;
        }
    }
    
    // @return true if the transaction can buy tokens
    function validPurchase() internal constant returns (bool) {
        bool withinPeriod = getNow() >= startTime && getNow() <= endTime;
        bool nonZeroPurchase = msg.value != 0;
        bool notReachedHardCap = hardCap >= totalNumberTokenSold;
        return withinPeriod && nonZeroPurchase && notReachedHardCap;
    }

    // @return true if crowdsale current lot event has ended
    function hasEnded() public constant returns (bool) {
        return getNow() > endTime;
    }

    function getNow() public constant returns (uint) {
        return now;
    }

    // Set/change Multi-signature wallet address
    function changeMultiSignatureWallet (address _multisig) public onlyOwner isActive {
        multisig = _multisig;
    }

    // Change ETH/Token exchange rate
    function changeTokenRate(uint _tokenPrice) public onlyOwner isActive {
        RATE = _tokenPrice;
    }

    // Set Finish Minting.
    function finishMinting() public onlyOwner isActive {
        mintingFinished = true;
        MintFinished();
    }



    // Start or pause tradable to Transfer token
    function startTradable(bool _tradable) public onlyOwner isActive {
        tradable = _tradable;
        if (tradable)
            StartTradable();
        else
            PauseTradable();
    }

    //UpdateICODateTime(uint256 _startTime,)
    function updateICODate(uint256 _startTime, uint256 _endTime) public onlyOwner {
        startTime = _startTime;
        endTime = _endTime;
    }
    
    //Change startTime to start ICO manually
    function changeStartTime(uint256 _startTime) public onlyOwner {
        startTime = _startTime;
    }

    //Change endTime to end ICO manually
    function changeEndTime(uint256 _endTime) public onlyOwner {
        endTime = _endTime;
    }

    // @return total tokens supplied
    function totalSupply() public constant returns (uint256) {
        return _totalSupply;
    }
    
    // @return total tokens supplied
    function totalNumberTokenSold() public constant returns (uint256) {
        return totalNumberTokenSold;
    }


    //Change total supply
    function changeTotalSupply(uint256 newSupply) public onlyOwner {
        _totalSupply = newSupply;
    }


    // What is the balance of a particular account?
    // @param who The address of the particular account
    // @return the balance the particular account
    function balanceOf(address who) public constant returns (uint256) {
        return balances[who];
    }


    function vaultBalanceOf(address who) public constant returns (uint256) {
        return vault[who];
    }

    function transferToVault(address recipient, uint256 amount) public onlyOwner isActive {
        require (
            balances[multisig] >= amount && amount > 0
        );

        balances[multisig] = balances[multisig].sub(amount);
        // sending tokens to vault is not part of ICO, its a decision made by the owner
        // _icoSupply = _icoSupply.sub(amount);
        vault[recipient] = vault[recipient].add(amount);

    }

    // What is the balance of a particular account?
    // @param who The address of the particular account
    // @return the balance of KYC waiting to be approved
    function balanceOfKyCToBeApproved(address who) public constant returns (uint256) {
        return balancesWaitingKYC[who];
    }
    

    function approveBalancesWaitingKYC(address[] listAddresses) public onlyOwner {
         for (uint256 i = 0; i < listAddresses.length; i++) {
             address client = listAddresses[i];
             balances[multisig] = balances[multisig].sub(balancesWaitingKYC[client]);
             balances[client] = balances[client].add(balancesWaitingKYC[client]);
             balancesWaitingKYC[client] = 0;
        }
    }

    function remit() public {
        require(vault[msg.sender] > 0 && now >= sealdate);
        balances[msg.sender] = balances[msg.sender].add(vault[msg.sender]);
        vault[msg.sender] = 0;
    }

    function remitFor(address person) public onlyOwner {
        require(vault[person] > 0 && now >= sealdate);
        balances[person] = balances[person].add(vault[person]);
        vault[person] = 0;
    }

    function addTimeToSeal(uint256 time) public onlyOwner {
        sealdate = sealdate.add(time);
    }

    function setSealDate(uint256 _sealdate) public onlyOwner {
        sealdate = _sealdate;
    } 

    function resetTimeSeal() public onlyOwner {
        sealdate = now;
    }

    function getSealDate() public constant returns (uint256) {
        return sealdate;
    }

    
    function modifyCurrentHardCap(uint256 _hardCap) public onlyOwner isActive {
        hardCap = _hardCap;
    }


    function burn(uint256 _value) public {
        require(_value <= balances[multisig]);
        balances[multisig] = balances[multisig].sub(_value);
        _totalSupply = _totalSupply.sub(_value);
        Burn(multisig, _value);
        
    }


    // @notice send `value` token to `to` from `msg.sender`
    // @param to The address of the recipient
    // @param value The amount of token to be transferred
    // @return the transaction address and send the event as Transfer
    function transfer(address to, uint256 value) public canTradable isActive {
        require (
            balances[msg.sender] >= value && value > 0
        );
        balances[msg.sender] = balances[msg.sender].sub(value);
        balances[to] = balances[to].add(value);
        Transfer(msg.sender, to, value);
    }
    
    function transferToAll(address[] tos, uint256[] values) public onlyOwner canTradable isActive {
        require(
            tos.length == values.length
            );
        
        for(uint256 i = 0; i < tos.length; i++){
        require(_icoSupply >= values[i]);   
        totalNumberTokenSold = totalNumberTokenSold.add(values[i]);
        _icoSupply = _icoSupply.sub(values[i]);
        updateBalances(tos[i],values[i]);
        }
    }

    // @notice send `value` token to `to` from `from`
    // @param from The address of the sender
    // @param to The address of the recipient
    // @param value The amount of token to be transferred
    // @return the transaction address and send the event as Transfer
    function transferFrom(address from, address to, uint256 value) public canTradable isActive {
        require (
            allowed[from][msg.sender] >= value && balances[from] >= value && value > 0
        );
        balances[from] = balances[from].sub(value);
        balances[to] = balances[to].add(value);
        allowed[from][msg.sender] = allowed[from][msg.sender].sub(value);
        Transfer(from, to, value);
    }

    // Allow spender to withdraw from your account, multiple times, up to the value amount.
    // If this function is called again it overwrites the current allowance with value.
    // @param spender The address of the sender
    // @param value The amount to be approved
    // @return the transaction address and send the event as Approval
    function approve(address spender, uint256 value) public isActive {
        require (
            balances[msg.sender] >= value && value > 0
        );
        allowed[msg.sender][spender] = value;
        Approval(msg.sender, spender, value);
    }

    // Check the allowed value for the spender to withdraw from owner
    // @param owner The address of the owner
    // @param spender The address of the spender
    // @return the amount which spender is still allowed to withdraw from owner
    function allowance(address _owner, address spender) public constant returns (uint256) {
        return allowed[_owner][spender];
    }

    // Get current price of a Token
    // @return the price or token value for a ether
    function getRate() public constant returns (uint256 result) {
      return RATE;
    }
    
    function getTokenDetail() public constant returns (string, string, uint256, uint256, uint256, uint256, uint256) {
        return (name, symbol, startTime, endTime, _totalSupply, _icoSupply, totalNumberTokenSold);
    }

}