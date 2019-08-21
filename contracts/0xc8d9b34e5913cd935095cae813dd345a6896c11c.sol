// Appics tokensale smart contract.
// Developed by Phenom.Team <info@phenom.team>

pragma solidity ^ 0.4.15;

/**
 *   @title SafeMath
 *   @dev Math operations with safety checks that throw on error
 */
library SafeMath {
    function mul(uint256 a, uint256 b) internal constant returns (uint256) {
        uint256 c = a * b;
        assert(a == 0 || c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) internal constant returns(uint256) {
        assert(b > 0);
        uint256 c = a / b;
        assert(a == b * c + a % b);
        return c;
    }

    function sub(uint256 a, uint256 b) internal constant returns(uint256) {
        assert(b <= a);
        return a - b;
    }

    function add(uint256 a, uint256 b) internal constant returns(uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }
}


/**
 *   @title ERC20
 *   @dev Standart ERC20 token interface
 */
contract ERC20 {
    uint256 public totalSupply = 0;
    mapping(address => uint256) balances;
    mapping(address => mapping(address => uint256)) allowed;
    function balanceOf(address _owner) public constant returns(uint256);
    function transfer(address _to, uint256 _value) public returns(bool);
    function transferFrom(address _from, address _to, uint256 _value) public returns(bool);
    function approve(address _spender, uint256 _value) public returns(bool);
    function allowance(address _owner, address _spender) public constant returns(uint256);
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}

/**
*   @title AppicsICO contract  - takes funds from users and issues tokens
*/
contract AppicsICO {
    // XAP - Appics token contract
    AppicsToken public XAP = new AppicsToken(this);
    using SafeMath for uint256;
    mapping (address => string) public  keys;

    // Token price parameters
    // These parametes can be changed only by manager of contract
    uint256 public Rate_Eth = 700; // Rate USD per ETH
    uint256 public Tokens_Per_Dollar_Numerator = 20;// Appics token = 0.15$
    uint256 public Tokens_Per_Dollar_Denominator = 3;// Appics token = 0.15$
    
    // Crowdfunding parameters
    uint256 constant AppicsPart = 20; // 20% of TotalSupply for Appics
    uint256 constant EcosystemPart = 20; // 20% of TotalSupply for Ecosystem
    uint256 constant SteemitPart = 5; // 5% of TotalSupply for Steemit
    uint256 constant BountyPart = 5; // 5% of TotalSupply for Bounty
    uint256 constant icoPart = 50; // 50% of TotalSupply for PublicICO and PrivateOffer
    uint256 constant PreSaleHardCap = 12500000*1e18;
    uint256 constant RoundAHardCap = 25000000*1e18;
    uint256 constant RoundBHardCap = 30000000*1e18;
    uint256 constant RoundCHardCap = 30000000*1e18;
    uint256 constant RoundDHardCap = 22500000*1e18;
    uint256 public PreSaleSold = 0;
    uint256 public RoundASold = 0;
    uint256 public RoundBSold = 0;
    uint256 public RoundCSold = 0;
    uint256 public RoundDSold = 0;        
    uint256 constant TENTHOUSENDLIMIT = 66666666666666666666666;
    // Output ethereum addresses
    address public Company;
    address public AppicsFund;
    address public EcosystemFund;
    address public SteemitFund;
    address public BountyFund;
    address public Manager; // Manager controls contract
    address public Controller_Address1; // First address that is used to buy tokens for other cryptos
    address public Controller_Address2; // Second address that is used to buy tokens for other cryptos
    address public Controller_Address3; // Third address that is used to buy tokens for other cryptos
    address public Oracle; // Oracle address

    // Possible ICO statuses
    enum StatusICO {
        Created,
        PreSaleStarted,
        PreSalePaused,
        PreSaleFinished,
        RoundAStarted,
        RoundAPaused,
        RoundAFinished,
        RoundBStarted,
        RoundBPaused,
        RoundBFinished,
        RoundCStarted,
        RoundCPaused,
        RoundCFinished,
        RoundDStarted,
        RoundDPaused,
        RoundDFinished
    }

    StatusICO statusICO = StatusICO.Created;

    // Events Log
    event LogStartPreSaleRound();
    event LogPausePreSaleRound();
    event LogFinishPreSaleRound(
        address AppicsFund, 
        address EcosystemFund,
        address SteemitFund,
        address BountyFund
    );
    event LogStartRoundA();
    event LogPauseRoundA();
    event LogFinishRoundA(
        address AppicsFund, 
        address EcosystemFund,
        address SteemitFund,
        address BountyFund
    );
    event LogStartRoundB();
    event LogPauseRoundB();
    event LogFinishRoundB(
        address AppicsFund, 
        address EcosystemFund,
        address SteemitFund,
        address BountyFund
    );
    event LogStartRoundC();
    event LogPauseRoundC();
    event LogFinishRoundC(
        address AppicsFund, 
        address EcosystemFund,
        address SteemitFund,
        address BountyFund
    );
    event LogStartRoundD();
    event LogPauseRoundD();
    event LogFinishRoundD(
        address AppicsFund, 
        address EcosystemFund,
        address SteemitFund,
        address BountyFund
    );
    event LogBuyForInvestor(address investor, uint256 aidValue, string txHash);
    event LogRegister(address investor, string key);

    // Modifiers
    // Allows execution by the oracle only
    modifier oracleOnly {
        require(msg.sender == Oracle);
        _;
    }
    // Allows execution by the contract manager only
    modifier managerOnly {
        require(msg.sender == Manager);
        _;
    }
    // Allows execution by the one of controllers only
    modifier controllersOnly {
        require(
            (msg.sender == Controller_Address1) || 
            (msg.sender == Controller_Address2) || 
            (msg.sender == Controller_Address3)
        );
        _;
    }
    // Allows execution if the any round started only
    modifier startedOnly {
        require(
            (statusICO == StatusICO.PreSaleStarted) || 
            (statusICO == StatusICO.RoundAStarted) || 
            (statusICO == StatusICO.RoundBStarted) ||
            (statusICO == StatusICO.RoundCStarted) ||
            (statusICO == StatusICO.RoundDStarted)
        );
        _;
    }
    // Allows execution if the any round finished only
    modifier finishedOnly {
        require(
            (statusICO == StatusICO.PreSaleFinished) || 
            (statusICO == StatusICO.RoundAFinished) || 
            (statusICO == StatusICO.RoundBFinished) ||
            (statusICO == StatusICO.RoundCFinished) ||
            (statusICO == StatusICO.RoundDFinished)
        );
        _;
    }


   /**
    *   @dev Contract constructor function
    */
    function AppicsICO(
        address _Company,
        address _AppicsFund,
        address _EcosystemFund,
        address _SteemitFund,
        address _BountyFund,
        address _Manager,
        address _Controller_Address1,
        address _Controller_Address2,
        address _Controller_Address3,
        address _Oracle
    )
        public {
        Company = _Company;
        AppicsFund = _AppicsFund;
        EcosystemFund = _EcosystemFund;
        SteemitFund = _SteemitFund;
        BountyFund = _BountyFund;
        Manager = _Manager;
        Controller_Address1 = _Controller_Address1;
        Controller_Address2 = _Controller_Address2;
        Controller_Address3 = _Controller_Address3;
        Oracle = _Oracle;
    }

   /**
    *   @dev Set rate of ETH and update token price
    *   @param _RateEth       current ETH rate
    */
    function setRate(uint256 _RateEth) external oracleOnly {
        Rate_Eth = _RateEth;
    }

   /**
    *   @dev Start Pre-Sale
    *   Set ICO status to PreSaleStarted
    */
    function startPreSaleRound() external managerOnly {
        require(statusICO == StatusICO.Created || statusICO == StatusICO.PreSalePaused);
        statusICO = StatusICO.PreSaleStarted;
        LogStartPreSaleRound();
    }

   /**
    *   @dev Pause Pre-Sale
    *   Set Ico status to PreSalePaused
    */
    function pausePreSaleRound() external managerOnly {
        require(statusICO == StatusICO.PreSaleStarted);
        statusICO = StatusICO.PreSalePaused;
        LogPausePreSaleRound();
    }


   /**
    *   @dev Finish Pre-Sale and mint tokens for AppicsFund, EcosystemFund, SteemitFund,
        RewardFund and ReferralFund
    *   Set Ico status to PreSaleFinished
    */
    function finishPreSaleRound() external managerOnly {
        require(statusICO == StatusICO.PreSaleStarted || statusICO == StatusICO.PreSalePaused);
        uint256 totalAmount = PreSaleSold.mul(100).div(icoPart);
        XAP.mintTokens(AppicsFund, AppicsPart.mul(totalAmount).div(100));
        XAP.mintTokens(EcosystemFund, EcosystemPart.mul(totalAmount).div(100));
        XAP.mintTokens(SteemitFund, SteemitPart.mul(totalAmount).div(100));
        XAP.mintTokens(BountyFund, BountyPart.mul(totalAmount).div(100));
        statusICO = StatusICO.PreSaleFinished;
        LogFinishPreSaleRound(AppicsFund, EcosystemFund, SteemitFund, BountyFund);

    }
   
   /**
    *   @dev Start Round A
    *   Set ICO status to RoundAStarted
    */
    function startRoundA() external managerOnly {
        require(statusICO == StatusICO.PreSaleFinished || statusICO == StatusICO.RoundAPaused);
        statusICO = StatusICO.RoundAStarted;
        LogStartRoundA();
    }

   /**
    *   @dev Pause Round A
    *   Set Ico status to RoundAPaused
    */
    function pauseRoundA() external managerOnly {
        require(statusICO == StatusICO.RoundAStarted);
        statusICO = StatusICO.RoundAPaused;
        LogPauseRoundA();
    }


   /**
    *   @dev Finish Round A and mint tokens AppicsFund, EcosystemFund, SteemitFund,
        RewardFund and ReferralFund
    *   Set Ico status to RoundAFinished
    */
    function finishRoundA() external managerOnly {
        require(statusICO == StatusICO.RoundAStarted || statusICO == StatusICO.RoundAPaused);
        uint256 totalAmount = RoundASold.mul(100).div(icoPart);
        XAP.mintTokens(AppicsFund, AppicsPart.mul(totalAmount).div(100));
        XAP.mintTokens(EcosystemFund, EcosystemPart.mul(totalAmount).div(100));
        XAP.mintTokens(SteemitFund, SteemitPart.mul(totalAmount).div(100));
        XAP.mintTokens(BountyFund, BountyPart.mul(totalAmount).div(100));
        statusICO = StatusICO.RoundAFinished;
        LogFinishRoundA(AppicsFund, EcosystemFund, SteemitFund, BountyFund);
    }

   /**
    *   @dev Start Round B
    *   Set ICO status to RoundBStarted
    */
    function startRoundB() external managerOnly {
        require(statusICO == StatusICO.RoundAFinished || statusICO == StatusICO.RoundBPaused);
        statusICO = StatusICO.RoundBStarted;
        LogStartRoundB();
    }

   /**
    *   @dev Pause Round B
    *   Set Ico status to RoundBPaused
    */
    function pauseRoundB() external managerOnly {
        require(statusICO == StatusICO.RoundBStarted);
        statusICO = StatusICO.RoundBPaused;
        LogPauseRoundB();
    }


   /**
    *   @dev Finish Round B and mint tokens AppicsFund, EcosystemFund, SteemitFund,
        RewardFund and ReferralFund
    *   Set Ico status to RoundBFinished
    */
    function finishRoundB() external managerOnly {
        require(statusICO == StatusICO.RoundBStarted || statusICO == StatusICO.RoundBPaused);
        uint256 totalAmount = RoundBSold.mul(100).div(icoPart);
        XAP.mintTokens(AppicsFund, AppicsPart.mul(totalAmount).div(100));
        XAP.mintTokens(EcosystemFund, EcosystemPart.mul(totalAmount).div(100));
        XAP.mintTokens(SteemitFund, SteemitPart.mul(totalAmount).div(100));
        XAP.mintTokens(BountyFund, BountyPart.mul(totalAmount).div(100));
        statusICO = StatusICO.RoundBFinished;
        LogFinishRoundB(AppicsFund, EcosystemFund, SteemitFund, BountyFund);
    }

   /**
    *   @dev Start Round C
    *   Set ICO status to RoundCStarted
    */
    function startRoundC() external managerOnly {
        require(statusICO == StatusICO.RoundBFinished || statusICO == StatusICO.RoundCPaused);
        statusICO = StatusICO.RoundCStarted;
        LogStartRoundC();
    }

   /**
    *   @dev Pause Round C
    *   Set Ico status to RoundCPaused
    */
    function pauseRoundC() external managerOnly {
        require(statusICO == StatusICO.RoundCStarted);
        statusICO = StatusICO.RoundCPaused;
        LogPauseRoundC();
    }


   /**
    *   @dev Finish Round C and mint tokens AppicsFund, EcosystemFund, SteemitFund,
        RewardFund and ReferralFund
    *   Set Ico status to RoundCStarted
    */
    function finishRoundC() external managerOnly {
        require(statusICO == StatusICO.RoundCStarted || statusICO == StatusICO.RoundCPaused);
        uint256 totalAmount = RoundCSold.mul(100).div(icoPart);
        XAP.mintTokens(AppicsFund, AppicsPart.mul(totalAmount).div(100));
        XAP.mintTokens(EcosystemFund, EcosystemPart.mul(totalAmount).div(100));
        XAP.mintTokens(SteemitFund, SteemitPart.mul(totalAmount).div(100));
        XAP.mintTokens(BountyFund, BountyPart.mul(totalAmount).div(100));
        statusICO = StatusICO.RoundCFinished;
        LogFinishRoundC(AppicsFund, EcosystemFund, SteemitFund, BountyFund);
    }

   /**
    *   @dev Start Round D
    *   Set ICO status to RoundDStarted
    */
    function startRoundD() external managerOnly {
        require(statusICO == StatusICO.RoundCFinished || statusICO == StatusICO.RoundDPaused);
        statusICO = StatusICO.RoundDStarted;
        LogStartRoundD();
    }

   /**
    *   @dev Pause Round D
    *   Set Ico status to RoundDPaused
    */
    function pauseRoundD() external managerOnly {
        require(statusICO == StatusICO.RoundDStarted);
        statusICO = StatusICO.RoundDPaused;
        LogPauseRoundD();
    }


   /**
    *   @dev Finish Round D and mint tokens AppicsFund, EcosystemFund, SteemitFund,
        RewardFund and ReferralFund
    *   Set Ico status to RoundDFinished
    */
    function finishRoundD() external managerOnly {
        require(statusICO == StatusICO.RoundDStarted || statusICO == StatusICO.RoundDPaused);
        uint256 totalAmount = RoundDSold.mul(100).div(icoPart);
        XAP.mintTokens(AppicsFund, AppicsPart.mul(totalAmount).div(100));
        XAP.mintTokens(EcosystemFund, EcosystemPart.mul(totalAmount).div(100));
        XAP.mintTokens(SteemitFund, SteemitPart.mul(totalAmount).div(100));
        XAP.mintTokens(BountyFund, BountyPart.mul(totalAmount).div(100));
        statusICO = StatusICO.RoundDFinished;
        LogFinishRoundD(AppicsFund, EcosystemFund, SteemitFund, BountyFund);
    }    


   /**
    *   @dev Enable token transfers
    */
    function unfreeze() external managerOnly {
        XAP.defrostTokens();
    }

   /**
    *   @dev Disable token transfers
    */
    function freeze() external managerOnly {
        XAP.frostTokens();
    }

   /**
    *   @dev Fallback function calls buyTokens() function to buy tokens
    *        when investor sends ETH to address of ICO contract
    */
    function() external payable {
        uint256 tokens; 
        tokens = msg.value.mul(Tokens_Per_Dollar_Numerator).mul(Rate_Eth);
        // rounding tokens amount:
        tokens = tokens.div(Tokens_Per_Dollar_Denominator);
        buyTokens(msg.sender, tokens);
    }

   /**
    *   @dev Issues tokens for users who made purchases in other cryptocurrencies
    *   @param _investor     address the tokens will be issued to
    *   @param _xapValue     number of Appics tokens
    *   @param _txHash       transaction hash of investor's payment
    */
    function buyForInvestor(
        address _investor,
        uint256 _xapValue,
        string _txHash
    )
        external
        controllersOnly
        startedOnly {
        buyTokens(_investor, _xapValue);        
        LogBuyForInvestor(_investor, _xapValue, _txHash);
    }


   /**
    *   @dev Issue tokens for investors who paid in ether
    *   @param _investor     address which the tokens will be issued to
    *   @param _xapValue     number of Appics tokens
    */
    function buyTokens(address _investor, uint256 _xapValue) internal startedOnly {
        require(_xapValue > 0);
        uint256 bonus = getBonus(_xapValue);
        uint256 total = _xapValue.add(bonus);
        if (statusICO == StatusICO.PreSaleStarted) {
            require (PreSaleSold.add(total) <= PreSaleHardCap);
            require(_xapValue > TENTHOUSENDLIMIT);
            PreSaleSold = PreSaleSold.add(total);
        }
        if (statusICO == StatusICO.RoundAStarted) {
            require (RoundASold.add(total) <= RoundAHardCap);
            RoundASold = RoundASold.add(total);
        }
        if (statusICO == StatusICO.RoundBStarted) {
            require (RoundBSold.add(total) <= RoundBHardCap);
            RoundBSold = RoundBSold.add(total);
        }
        if (statusICO == StatusICO.RoundCStarted) {
            require (RoundCSold.add(total) <= RoundCHardCap);
            RoundCSold = RoundCSold.add(total);
        }
        if (statusICO == StatusICO.RoundDStarted) {
            require (RoundDSold.add(total) <= RoundDHardCap);
            RoundDSold = RoundDSold.add(total);
        }
        XAP.mintTokens(_investor, total);
    }

   /**
    *   @dev Calculates bonus
    *   @param _value        amount of tokens
    *   @return              bonus value
    */
    function getBonus(uint256 _value)
        public
        constant
        returns(uint256)
    {
        uint256 bonus = 0;
        if (statusICO == StatusICO.PreSaleStarted) {
            bonus = _value.mul(20).div(100);
        }
        if (statusICO == StatusICO.RoundAStarted) {
            bonus = _value.mul(15).div(100); 
        }
        if (statusICO == StatusICO.RoundBStarted) {
            bonus = _value.mul(10).div(100); 
        }
        if (statusICO == StatusICO.RoundCStarted) {
            bonus = _value.mul(5).div(100); 
        }
        return bonus;
    }
    
    function register(string _key) public {
        keys[msg.sender] = _key;
        LogRegister(msg.sender, _key);
    }


   /**
    *   @dev Allows Company withdraw investments when round is over
    */
    function withdrawEther() external managerOnly finishedOnly{
        Company.transfer(this.balance);
    }

}


/**
 *   @title 
 *   @dev Appics token contract
 */
contract AppicsToken is ERC20 {
    using SafeMath for uint256;
    string public name = "Appics";
    string public symbol = "XAP";
    uint256 public decimals = 18;

    // Ico contract address
    address public ico;
    event Burn(address indexed from, uint256 value);

    // Disables/enables token transfers
    bool public tokensAreFrozen = true;

    // Allows execution by the ico only
    modifier icoOnly {
        require(msg.sender == ico);
        _;
    }

   /**
    *   @dev Contract constructor function sets Ico address
    *   @param _ico          ico address
    */
    function AppicsToken(address _ico) public {
        ico = _ico;
    }

   /**
    *   @dev Mint tokens
    *   @param _holder       beneficiary address the tokens will be issued to
    *   @param _value        number of tokens to issue
    */
    function mintTokens(address _holder, uint256 _value) external icoOnly {
        require(_value > 0);
        balances[_holder] = balances[_holder].add(_value);
        totalSupply = totalSupply.add(_value);
        Transfer(0x0, _holder, _value);
    }

   /**
    *   @dev Enables token transfers
    */
    function defrostTokens() external icoOnly {
      tokensAreFrozen = false;
    }

    /**
    *   @dev Disables token transfers
    */
    function frostTokens() external icoOnly {
      tokensAreFrozen = true;
    }

   /**
    *   @dev Burn Tokens
    *   @param _investor     token holder address which the tokens will be burnt
    *   @param _value        number of tokens to burn
    */
    function burnTokens(address _investor, uint256 _value) external icoOnly {
        require(balances[_investor] > 0);
        totalSupply = totalSupply.sub(_value);
        balances[_investor] = balances[_investor].sub(_value);
        Burn(_investor, _value);
    }

   /**
    *   @dev Get balance of investor
    *   @param _owner        investor's address
    *   @return              balance of investor
    */
    function balanceOf(address _owner) public constant returns(uint256) {
      return balances[_owner];
    }

   /**
    *   @dev Send coins
    *   throws on any error rather then return a false flag to minimize
    *   user errors
    *   @param _to           target address
    *   @param _amount       transfer amount
    *
    *   @return true if the transfer was successful
    */
    function transfer(address _to, uint256 _amount) public returns(bool) {
        require(!tokensAreFrozen);
        balances[msg.sender] = balances[msg.sender].sub(_amount);
        balances[_to] = balances[_to].add(_amount);
        Transfer(msg.sender, _to, _amount);
        return true;
    }

   /**
    *   @dev An account/contract attempts to get the coins
    *   throws on any error rather then return a false flag to minimize user errors
    *
    *   @param _from         source address
    *   @param _to           target address
    *   @param _amount       transfer amount
    *
    *   @return true if the transfer was successful
    */
    function transferFrom(address _from, address _to, uint256 _amount) public returns(bool) {
        require(!tokensAreFrozen);
        balances[_from] = balances[_from].sub(_amount);
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_amount);
        balances[_to] = balances[_to].add(_amount);
        Transfer(_from, _to, _amount);
        return true;
    }

   /**
    *   @dev Allows another account/contract to spend some tokens on its behalf
    *   throws on any error rather then return a false flag to minimize user errors
    *
    *   also, to minimize the risk of the approve/transferFrom attack vector
    *   approve has to be called twice in 2 separate transactions - once to
    *   change the allowance to 0 and secondly to change it to the new allowance
    *   value
    *
    *   @param _spender      approved address
    *   @param _amount       allowance amount
    *
    *   @return true if the approval was successful
    */
    function approve(address _spender, uint256 _amount) public returns(bool) {
        require((_amount == 0) || (allowed[msg.sender][_spender] == 0));
        allowed[msg.sender][_spender] = _amount;
        Approval(msg.sender, _spender, _amount);
        return true;
    }

   /**
    *   @dev Function to check the amount of tokens that an owner allowed to a spender.
    *
    *   @param _owner        the address which owns the funds
    *   @param _spender      the address which will spend the funds
    *
    *   @return              the amount of tokens still avaible for the spender
    */
    function allowance(address _owner, address _spender) public constant returns(uint256) {
        return allowed[_owner][_spender];
    }
}