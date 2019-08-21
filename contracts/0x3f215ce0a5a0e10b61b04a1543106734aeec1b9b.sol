pragma solidity >=0.4.22 <0.6.0;

library SafeMath {
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a * b;
        assert(a == 0 || c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // assert(b > 0); // Solidity automatically throws when dividing by 0
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There tis no case in which this doesn't hold
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
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
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
        require(msg.sender == owner,"Owner can call this function.");
        _;
    }
  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param newOwner The address to transfer ownership to. 
   */
    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0),"Use new owner address.");
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    } 
}

  
contract ERC223 {
    function totalSupply() public view returns (uint256);
    function balanceOf(address who) public view returns (uint256);
    function roleOf(address who) public view returns (uint256);
    function setUserRole(address _user_address, uint256 _role_define) public;
    function transfer(address to, uint256 value) public;
    function transfer(address to, uint value, bytes memory data) public;
    function transferFrom(address from, address to, uint256 value) public;
    function approve(address spender, uint256 value) public;
    function allowance(address owner, address spender) public view returns (uint256);
    event Transfer(address indexed from, address indexed to, uint value, bytes data);
    event Transfer(address indexed from, address indexed to, uint256 value);    
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

// Interface for the contract which implements the ERC223 fallback
contract ERC223ReceivingContract { 
    function tokenFallback(address _from, uint _value, bytes memory _data) public;
}

contract WRTToken is Ownable, ERC223 {
    using SafeMath for uint256;
    // Token properties
    string public name = "Warrior Token";
    string public symbol = "WRT";
    uint256 public decimals = 18;
    uint256 public numberDecimal18 = 1000000000000000000;
    uint256 public RATE = 360e18;

    // Distribution of tokens
    uint256 public _totalSupply = 100000000e18;
    uint256 public _presaleSupply = 5000000e18; // 5% for presale
    uint256 public _projTeamSupply = 5000000e18; // 5% for project team ( will be time sealed for 6 months )
    uint256 public _PartnersSupply = 10000000e18; // 10% for partners and advisors ( will be time sealed for 12 months )
    uint256 public _PRSupply = 9000000e18; // 9% for marketing and bonus 
    uint256 public _metaIcoSupply = 1000000e18; // 1% for Expenses done during the ICO i.e. marketing
    uint256 public _icoSupply = 30000000e18; // 30% for ICO

    //number of total tokens sold in main sale
    uint256 public totalNumberTokenSoldMainSale = 0;
    uint256 public totalNumberTokenSoldPreSale = 0;

    uint256 public softCapUSD = 5000000;
    uint256 public hardCapUSD = 10000000;
    
    bool public mintingFinished = false;
    bool public tradable = true;
    bool public active = true;


    // Balances for each account
    mapping (address => uint256) balances;
    
    // role for each account
    // 0 => No Role, 1 =>Admin, 2 => Team, 3=> Advisors, 4=> Partner, 5=> Marketing, 6=> MetaICO
    
    mapping (address => uint256) role;
    
    // time seal for upper management
    mapping (address => uint256) vault;

    // Owner of account approves the transfer of an amount to another account
    mapping (address => mapping(address => uint256)) allowed;

    mapping (address => bool) whitelist;

    // start and end timestamps where investments are allowed (both inclusive)
    uint256 public mainSaleStartTime; 
    uint256 public mainSaleEndTime;
    uint256 public preSaleStartTime;
    uint256 public preSaleEndTime;
    
    uint256 public projsealDate; // seal date for project team 
    uint256 public partnersealDate; // seal date for partners and advisors ( will be time sealed for 12 months )


    uint256 contractDeployedTime;
    

    // Wallet Address of Token
    address payable public  multisig;

    // how many token units a buyer get in base unit 

    event MintFinished();
    event StartTradable();
    event PauseTradable();
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
        require((mainSaleStartTime <= now && now <= mainSaleEndTime) || (preSaleStartTime <= now && now <= preSaleEndTime));
        _;
    }

    // Constructor
    // @notice WarriorToken Contract
    // @return the transaction address
    constructor(address payable _multisig, uint256 _preSaleStartTime, uint256 _mainSaleStartTime) public {
        require(_multisig != address(0x0),"Invalid address.");
        require(_mainSaleStartTime > _preSaleStartTime);
        multisig = _multisig;


        mainSaleStartTime = _mainSaleStartTime;
        preSaleStartTime = _preSaleStartTime;
        // for now the token sale will run for 60 days
        mainSaleEndTime = mainSaleStartTime + 60 days;
        preSaleEndTime = preSaleStartTime + 60 days;
        contractDeployedTime = now;

        balances[multisig] = _totalSupply;

        // The project team can get their token 180days after the main sale ends
        projsealDate = mainSaleEndTime + 180 days;
        // The partners and advisors can get their token 1 year after the main sale ends
        partnersealDate = mainSaleEndTime + 365 days;

        owner = msg.sender;
    }

    function getTimePassed() public view returns (uint256) {
        return (now - contractDeployedTime).div(1 days);
    }

    function isPresale() public view returns (bool) {
        return now < preSaleEndTime && now > preSaleStartTime;
    }


    function applyBonus(uint256 tokens) public view returns (uint256) {
        if ( now < (preSaleStartTime + 1 days) ) {
            return tokens.mul(20).div(10); // 100% bonus     
        } else if ( now < (preSaleStartTime + 7 days) ) {
            return tokens.mul(15).div(10); // 50% bonus
        } else if ( now < (preSaleStartTime + 14 days) ) {
            return tokens.mul(13).div(10); // 30% bonus
        } else if ( now < (preSaleStartTime + 21 days) ) {
            return tokens.mul(115).div(100); // 15% bonus
        } else if ( now < (preSaleStartTime + 28 days) ) {
            return tokens.mul(11).div(10); // 10% bonus
        } 
        return tokens; // if reached till hear means no bonus 
    }

    // Payable method
    // @notice Anyone can buy the tokens on tokensale by paying ether
    function () external payable {        
        tokensale(msg.sender);
    }

    // @notice tokensale
    // @param recipient The address of the recipient
    // @return the transaction address and send the event as Transfer
    function tokensale(address recipient) internal saleIsOpen isActive {
        require(recipient != address(0x0));
        require(validPurchase());
        require(whitelisted(recipient));
        
        uint256 weiAmount = msg.value;
        uint256 numberToken = weiAmount.mul(RATE).div(1 ether);

        numberToken = applyBonus(numberToken);
        
        // An investor is only allowed to buy tokens between 333 to 350,000 tokens
        require(numberToken >= 333e18 && numberToken <= 350000e18);

        
        // if its a presale
        if (isPresale()) {
            require(_presaleSupply >= numberToken);
            totalNumberTokenSoldPreSale = totalNumberTokenSoldPreSale.add(numberToken);
            _presaleSupply = _presaleSupply.sub(numberToken);
        // as the validPurchase checks for the period, else block will only mean its main sale
        } else {
            require(_icoSupply >= numberToken);
            totalNumberTokenSoldMainSale = totalNumberTokenSoldMainSale.add(numberToken);
            _icoSupply = _icoSupply.sub(numberToken);
        }
    
        updateBalances(recipient, numberToken);
        forwardFunds();
        whitelist[recipient] = false;
    }

    function transFromProjTeamSupply(address receiver, uint256 tokens) public onlyOwner {
 
        require(tokens <= _projTeamSupply);
        updateBalances(receiver, tokens);
        _projTeamSupply = _projTeamSupply.sub(tokens);
        role[receiver] = 2;
    }

    function transFromPartnersSupply(address receiver, uint256 tokens) public onlyOwner {
        require(tokens <= _PartnersSupply);
        updateBalances(receiver, tokens);        
        _PartnersSupply = _PartnersSupply.sub(tokens);
        role[receiver] = 4;
    }
    
    function setUserRole(address _user, uint256 _role) public onlyOwner {
        role[_user] = _role;
    }

    function transFromPRSupply(address receiver, uint256 tokens) public onlyOwner {
        require(tokens <= _PRSupply);
        updateBalances(receiver, tokens);
        _PRSupply = _PRSupply.sub(tokens);
        role[receiver] = 5;
    }

    function transFromMetaICOSupply(address receiver, uint256 tokens) public onlyOwner {
        require(tokens <= _metaIcoSupply);
        updateBalances(receiver, tokens);
        _metaIcoSupply = _metaIcoSupply.sub(tokens);
        role[receiver] = 6;
    }

    function setWhitelistStatus(address user, bool status) public onlyOwner returns (bool) {

        whitelist[user] = status; 
        
        return whitelist[user];
    }
    
    function setWhitelistForBulk(address[] memory listAddresses, bool status) public onlyOwner {
        for (uint256 i = 0; i < listAddresses.length; i++) {
            whitelist[listAddresses[i]] = status;
        }
    }

    // used to transfer manually when senders are using BTC
    function transferToAll(address[] memory tos, uint256[] memory values) public onlyOwner canTradable isActive {
        require(
            tos.length == values.length
            );
        
        for(uint256 i = 0; i < tos.length; i++){
            require(_icoSupply >= values[i]);   
            totalNumberTokenSoldMainSale = totalNumberTokenSoldMainSale.add(values[i]);
            _icoSupply = _icoSupply.sub(values[i]);
            updateBalances(tos[i],values[i]);
        }
    }

    function transferToAllInPreSale(address[] memory tos, uint256[] memory values) public onlyOwner canTradable isActive {
        require(
            tos.length == values.length
            );
        
        for(uint256 i = 0; i < tos.length; i++){
            require(_presaleSupply >= values[i]);   
            totalNumberTokenSoldPreSale = totalNumberTokenSoldPreSale.add(values[i]);
            _presaleSupply = _presaleSupply.sub(values[i]);
            updateBalances(tos[i],values[i]);
        }
    }
    
    function updateBalances(address receiver, uint256 tokens) internal {
        balances[multisig] = balances[multisig].sub(tokens);
        balances[receiver] = balances[receiver].add(tokens);
        emit Transfer(multisig, receiver, tokens);
    }

    function whitelisted(address user) public view returns (bool) {
        return whitelist[user];
    }
    
    // send ether to the fund collection wallet
    // override to create custom fund forwarding mechanisms
    function forwardFunds()  internal {
       multisig.transfer(msg.value);
    }

    
    // @return true if the transaction can buy tokens
    function validPurchase() internal view returns (bool) {
        bool withinPeriod = (now >= mainSaleStartTime && now <= mainSaleEndTime) || (now >= preSaleStartTime && now <= preSaleEndTime);
        bool nonZeroPurchase = msg.value != 0;
        return withinPeriod && nonZeroPurchase;
    }

    // @return true if crowdsale current lot event has ended
    function hasEnded() public view returns (bool) {
        return now > mainSaleEndTime;
    }

    function hasPreSaleEnded() public view returns (bool) {
        return now > preSaleEndTime;
    }

    // Set/change Multi-signature wallet address
    function changeMultiSignatureWallet(address payable _multisig) public onlyOwner isActive {
        multisig = _multisig;
    }

    // Change ETH/Token exchange rate
    function changeTokenRate(uint _tokenPrice) public onlyOwner isActive {
        RATE = _tokenPrice;
    }

    // Set Finish Minting.
    function finishMinting() public onlyOwner isActive {
        mintingFinished = true;
        emit MintFinished();
    }

    // Start or pause tradable to Transfer token
    function startTradable(bool _tradable) public onlyOwner isActive {
        tradable = _tradable;
        if (tradable)
            emit StartTradable();
        else
            emit PauseTradable();
    }
    
    function setActive(bool _active) public onlyOwner {
        active = _active;
    }
    
    //Change mainSaleStartTime to start ICO manually
    function changeMainSaleStartTime(uint256 _mainSaleStartTime) public onlyOwner {
        mainSaleStartTime = _mainSaleStartTime;
    }

    //Change mainSaleEndTime to end ICO manually
    function changeMainSaleEndTime(uint256 _mainSaleEndTime) public onlyOwner {
        mainSaleEndTime = _mainSaleEndTime;
    }

    function changePreSaleStartTime(uint256 _preSaleStartTime) public onlyOwner {
        preSaleStartTime = _preSaleStartTime;
    }

    //Change mainSaleEndTime to end ICO manually
    function changePreSaleEndTime(uint256 _preSaleEndTime) public onlyOwner {
        preSaleEndTime = _preSaleEndTime;
    }

    //Change total supply
    function changeTotalSupply(uint256 newSupply) public onlyOwner {
        _totalSupply = newSupply;
    }

    // In case multiple ICOs are planned, use this with the totalSupply function
    function changeICOSupply(uint256 newICOSupply) public onlyOwner {
        _icoSupply = newICOSupply;
    }

    // Get current price of a Token
    // @return the price or token value for a ether
    function getRate() public view returns (uint256 result) {
        return RATE;
    }
    
    function getTokenDetail() public view returns (string memory, string memory, uint256, uint256, uint256, uint256, uint256, uint256, uint256, uint256, uint256) {
        return (name, symbol, mainSaleStartTime, mainSaleEndTime, preSaleStartTime, preSaleEndTime, _totalSupply, _icoSupply, _presaleSupply, totalNumberTokenSoldMainSale, totalNumberTokenSoldPreSale);
    }


    // ERC223 Methods  
    
    // What is the balance of a particular account?
    // @param who The address of the particular account
    // @return the balance the particular account
    function balanceOf(address who) public view returns (uint256) {
        return balances[who];
    }
    function roleOf(address who) public view returns (uint256) {
        return role[who];
    }

    // @return total tokens supplied
    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }
    
    function burn(uint256 _value) public {
        require(_value <= balances[msg.sender]);
        balances[msg.sender] = balances[msg.sender].sub(_value);
        _totalSupply = _totalSupply.sub(_value);
        emit Burn(multisig, _value);
        
    }
    
    /**
     * @dev Transfer the specified amount of tokens to the specified address.
     *      Invokes the `tokenFallback` function if the recipient is a contract.
     *      The token transfer fails if the recipient is a contract
     *      but does not implement the `tokenFallback` function
     *      or the fallback function to receive funds.
     *
     * @param _to    Receiver address.
     * @param _value Amount of tokens that will be transferred.
     * @param _data  Transaction metadata.
     */
    function transfer(address _to, uint _value, bytes memory _data) public {
        // Standard function transfer similar to ERC20 transfer with no _data .
        // Added due to backwards compatibility reasons .
        uint codeLength;

        assembly {
            // Retrieve the size of the code on target address, this needs assembly .
            codeLength := extcodesize(_to)
        }
        if(role[msg.sender] == 2)
        {
            require(now >= projsealDate,"you can not transfer yet");
        }
        if(role[msg.sender] == 3 || role[msg.sender] == 4)
        {
            require(now >= partnersealDate,"you can not transfer yet");
        }

        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);
        if(codeLength>0) {
            ERC223ReceivingContract receiver = ERC223ReceivingContract(_to);
            receiver.tokenFallback(msg.sender, _value, _data);
        }
        emit Transfer(msg.sender, _to, _value, _data);
    }
    
    /**
     * @dev Transfer the specified amount of tokens to the specified address.
     *      This function works the same with the previous one
     *      but doesn't contain `_data` param.
     *      Added due to backwards compatibility reasons.
     *
     * @param _to    Receiver address.
     * @param _value Amount of tokens that will be transferred.
     */
    function transfer(address _to, uint _value) public {
        uint codeLength;
        bytes memory empty;
        assembly {
            // Retrieve the size of the code on target address, this needs assembly .
            codeLength := extcodesize(_to)
        }
       if(role[msg.sender] == 2)
        {
            require(now >= projsealDate,"you can not transfer yet");
        }
        if(role[msg.sender] == 3 || role[msg.sender] == 4)
        {
            require(now >= partnersealDate,"you can not transfer yet");
        }
        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);
        if(codeLength>0) {
            ERC223ReceivingContract receiver = ERC223ReceivingContract(_to);
            receiver.tokenFallback(msg.sender, _value, empty);
        }
        emit Transfer(msg.sender, _to, _value, empty);
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
        if(role[from] == 2)
        {
            require(now >= projsealDate,"you can not transfer yet");
        }
        if(role[from] == 3 || role[from] == 4)
        {
            require(now >= partnersealDate,"you can not transfer yet");
        }
        balances[from] = balances[from].sub(value);
        balances[to] = balances[to].add(value);
        allowed[from][msg.sender] = allowed[from][msg.sender].sub(value);
        emit Transfer(from, to, value);
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
        emit Approval(msg.sender, spender, value);
    }
    // Check the allowed value for the spender to withdraw from owner
    // @param owner The address of the owner
    // @param spender The address of the spender
    // @return the amount which spender is still allowed to withdraw from owner
    function allowance(address _owner, address spender) public view returns (uint256) {
        return allowed[_owner][spender];
    }    
}