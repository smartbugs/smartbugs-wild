// Datarius tokensale smart contract.
// Developed by Phenom.Team <info@phenom.team>
pragma solidity ^0.4.15;

/**
 *   @title SafeMath
 *   @dev Math operations with safety checks that throw on error
 */

library SafeMath {

  function mul(uint a, uint b) internal constant returns (uint) {
    if (a == 0) {
      return 0;
    }
    uint c = a * b;
    assert(c / a == b);
    return c;
  }

  function div(uint a, uint b) internal constant returns(uint) {
    assert(b > 0);
    uint c = a / b;
    assert(a == b * c + a % b);
    return c;
  }

  function sub(uint a, uint b) internal constant returns(uint) {
    assert(b <= a);
    return a - b;
  }

  function add(uint a, uint b) internal constant returns(uint) {
    uint c = a + b;
    assert(c >= a);
    return c;
  }
}

/**
 *   @title ERC20
 *   @dev Standart ERC20 token interface
 */

contract ERC20 {
    uint public totalSupply = 0;

    mapping(address => uint) balances;
    mapping(address => mapping (address => uint)) allowed;

    function balanceOf(address _owner) constant returns (uint);
    function transfer(address _to, uint _value) returns (bool);
    function transferFrom(address _from, address _to, uint _value) returns (bool);
    function approve(address _spender, uint _value) returns (bool);
    function allowance(address _owner, address _spender) constant returns (uint);

    event Transfer(address indexed _from, address indexed _to, uint _value);
    event Approval(address indexed _owner, address indexed _spender, uint _value);

} 

/**
 *   @title DatariusICO contract  - takes funds from users and issues tokens
 */
contract DatariusICO {
    // DTRC - Datarius token contract
    using SafeMath for uint;
    DatariusToken public DTRC = new DatariusToken(this);
    ERC20 public preSaleToken;

    // Token price parameters
    // These parametes can be changed only by manager of contract
    uint public tokensPerDollar = 100;
    uint public rateEth = 1176; // Rate USD per ETH
    uint public tokenPrice = tokensPerDollar * rateEth; // DTRC per ETH
    uint public DatToDtrcNumerator = 4589059589;
    uint public DatToDtrcDenominator = 100000000;

    //Crowdsale parameters
    uint constant softCap = 1000000 * tokensPerDollar * 1e18; 
    uint constant hardCap = 51000000 * tokensPerDollar * 1e18;
    uint constant bountyPart = 2; // 2% of TotalSupply for BountyFund
    uint constant partnersPart = 5; // 5% of TotalSupply for ParnersFund
    uint constant teamPart = 5; // 5% of TotalSupply for TeamFund
    uint constant reservePart = 15; // 15% of TotalSupply for ResrveFund
    uint constant publicIcoPart = 73; // 73% of TotalSupply for publicICO
    uint public soldAmount = 0;
    uint startTime = 0;
    // Output ethereum addresses
    address public Company;
    address public BountyFund;
    address public PartnersFund;
    address public TeamFund;
    address public ReserveFund;
    address public Manager; // Manager controls contract
    address public ReserveManager; // // Manager controls contract
    address public Controller_Address1; // First address that is used to buy tokens for other cryptos
    address public Controller_Address2; // Second address that is used to buy tokens for other cryptos
    address public Controller_Address3; // Third address that is used to buy tokens for other cryptos
    address public RefundManager; // Refund manager address
    address public Oracle; // Oracle address

    // Possible ICO statuses
    enum StatusICO {
        Created,
        Started,
        Paused,
        Finished
    }
    StatusICO statusICO = StatusICO.Created;
    
    // Mappings
    mapping(address => uint) public investmentsInEth; // Mapping for remembering ether of investors
    mapping(address => uint) public tokensEth; // Mapping for remembering tokens of investors who invest in ETH
    mapping(address => uint) public tokensOtherCrypto; // Mapping for remembering tokens of investors who invest in other crypto currencies
    mapping(address => bool) public swaped;
    // Events Log
    event LogStartICO();
    event LogPause();
    event LogFinishICO();
    event LogBuyForInvestor(address investor, uint DTRCValue, string txHash);
    event LogSwapTokens(address investor, uint tokensAmount);
    event LogReturnEth(address investor, uint eth);
    event LogReturnOtherCrypto(address investor, string logString);

    // Modifiers
    // Allows execution by the managers only
    modifier managersOnly { 
        require(
            (msg.sender == Manager) ||
            (msg.sender == ReserveManager)
        );
        _; 
     }
    // Allows execution by the contract manager only
    modifier refundManagersOnly { 
        require(msg.sender == RefundManager);
        _; 
     }
    // Allows execution by the oracle only
    modifier oracleOnly { 
        require(msg.sender == Oracle);
        _; 
     }
    // Allows execution by the one of controllers only
    modifier controllersOnly {
        require(
            (msg.sender == Controller_Address1)||
            (msg.sender == Controller_Address2)||
            (msg.sender == Controller_Address3)
        );
        _;
    }

   /**
    *   @dev Contract constructor function
    */
    function DatariusICO(
        address _preSaleToken,
        address _Company,
        address _BountyFund,
        address _PartnersFund,
        address _ReserveFund,
        address _TeamFund,
        address _Manager,
        address _ReserveManager,
        address _Controller_Address1,
        address _Controller_Address2,
        address _Controller_Address3,
        address _RefundManager,
        address _Oracle
        ) public {
        preSaleToken = ERC20(_preSaleToken);
        Company = _Company;
        BountyFund = _BountyFund;
        PartnersFund = _PartnersFund;
        ReserveFund = _ReserveFund;
        TeamFund = _TeamFund;
        Manager = _Manager;
        ReserveManager = _ReserveManager;
        Controller_Address1 = _Controller_Address1;
        Controller_Address2 = _Controller_Address2;
        Controller_Address3 = _Controller_Address3;
        RefundManager = _RefundManager;
        Oracle = _Oracle;
    }

   /**
    *   @dev Function to set rate of ETH and update token price
    *   @param _rateEth       current ETH rate
    */
    function setRate(uint _rateEth) external oracleOnly {
        rateEth = _rateEth;
        tokenPrice = tokensPerDollar.mul(rateEth);
    }

   /**
    *   @dev Function to start ICO
    *   Sets ICO status to Started, inits startTime
    */
    function startIco() external managersOnly {
        require(statusICO == StatusICO.Created || statusICO == StatusICO.Paused);
        if(statusICO == StatusICO.Created) {
          startTime = now;
        }
        statusICO = StatusICO.Started;
        LogStartICO();
    }

   /**
    *   @dev Function to pause ICO
    *   Sets ICO status to Paused
    */
    function pauseIco() external managersOnly {
       require(statusICO == StatusICO.Started);
       statusICO = StatusICO.Paused;
       LogPause();
    }

   /**
    *   @dev Function to finish ICO
    *   Emits tokens for bounty company, partners and team
    */
    function finishIco() external managersOnly {
        require(statusICO == StatusICO.Started || statusICO == StatusICO.Paused);
        uint alreadyMinted = DTRC.totalSupply();
        uint totalAmount = alreadyMinted.mul(100).div(publicIcoPart);
        DTRC.mintTokens(BountyFund, bountyPart.mul(totalAmount).div(100));
        DTRC.mintTokens(PartnersFund, partnersPart.mul(totalAmount).div(100));
        DTRC.mintTokens(TeamFund, teamPart.mul(totalAmount).div(100));
        DTRC.mintTokens(ReserveFund, reservePart.mul(totalAmount).div(100));
        if (soldAmount >= softCap) {
            DTRC.defrost();
        }
        statusICO = StatusICO.Finished;
        LogFinishICO();
    }

   /**
    *   @dev Function to swap tokens from pre-sale
    *   @param _investor     pre-sale tokens holder address
    */
    function swapTokens(address _investor) external managersOnly {
         require(!swaped[_investor] && statusICO != StatusICO.Finished);
         swaped[_investor] = true;
         uint tokensToSwap = preSaleToken.balanceOf(_investor);
         uint DTRCTokens = tokensToSwap.mul(DatToDtrcNumerator).div(DatToDtrcDenominator);
         DTRC.mintTokens(_investor, DTRCTokens);
         LogSwapTokens(_investor, tokensToSwap);
    }
   /**
    *   @dev Fallback function calls buy(address _investor, uint _DTRCValue) function to issue tokens
    *        when investor sends ETH to address of ICO contract and then stores investment amount 
    */
    function() external payable {
        buy(msg.sender, msg.value.mul(tokenPrice));
        investmentsInEth[msg.sender] = investmentsInEth[msg.sender].add(msg.value); 
    }

   /**
    *   @dev Function to issues tokens for investors who made purchases in other cryptocurrencies
    *   @param _investor     address the tokens will be issued to
    *   @param _txHash       transaction hash of investor's payment
    *   @param _DTRCValue    number of DTRC tokens
    */

    function buyForInvestor(
        address _investor, 
        uint _DTRCValue, 
        string _txHash
    ) 
        external 
        controllersOnly {
        require(statusICO == StatusICO.Started);
        require(soldAmount + _DTRCValue <= hardCap);
        uint bonus = getBonus(_DTRCValue);
        uint total = _DTRCValue.add(bonus);
        DTRC.mintTokens(_investor, total);
        soldAmount = soldAmount.add(_DTRCValue);
        tokensOtherCrypto[_investor] = tokensOtherCrypto[_investor].add(total); 
        LogBuyForInvestor(_investor, total, _txHash);
    }

   /**
    *   @dev Function to issue tokens for investors who paid in ether
    *   @param _investor     address which the tokens will be issued tokens
    *   @param _DTRCValue    number of DTRC tokens
    */
    function buy(address _investor, uint _DTRCValue) internal {
        require(statusICO == StatusICO.Started);
        require(soldAmount + _DTRCValue <= hardCap);
        uint bonus = getBonus(_DTRCValue);
        uint total = _DTRCValue.add(bonus);
        DTRC.mintTokens(_investor, total);
        soldAmount = soldAmount.add(_DTRCValue);
        tokensEth[msg.sender] = tokensEth[msg.sender].add(total); 
    }

   /**
    *   @dev Calculates bonus 
    *   @param _value        amount of tokens
    *   @return              bonus value
    */
    function getBonus(uint _value) public constant returns (uint) {
        uint bonus = 0;
        if(now <= startTime + 6 hours) {
            bonus = _value.mul(30).div(100);
            return bonus;
        }
        if(now <= startTime + 12 hours) {
            bonus = _value.mul(25).div(100);
            return bonus;
        }
        if(now <= startTime + 24 hours) {
            bonus = _value.mul(20).div(100);
            return bonus;
        }
        if(now <= startTime + 48 hours) {
            bonus = _value.mul(15).div(100);
            return bonus;
        }
        if(now <= startTime + 15 days) {
            bonus = _value.mul(10).div(100);
            return bonus;
        }
    return bonus;
    }

   /**
    *   @dev Allows investors to return their investment after the ICO is over
    *   in the case when the SoftCap was not achieved
    */
    function refundEther() public {
        require(
            statusICO == StatusICO.Finished && 
            soldAmount < softCap && 
            investmentsInEth[msg.sender] > 0
        );
        uint ethToRefund = investmentsInEth[msg.sender];
        investmentsInEth[msg.sender] = 0;
        uint tokensToBurn = tokensEth[msg.sender];
        tokensEth[msg.sender] = 0;
        DTRC.burnTokens(msg.sender, tokensToBurn);
        msg.sender.transfer(ethToRefund);
        LogReturnEth(msg.sender, ethToRefund);
    }

   /**
    *   @dev Burn tokens of investors who paid in other cryptocurrencies after the ICO is over
    *   in the case when the SoftCap was not achieved
    *   @param _investor     address which the tokens will be burnt
    *   @param _logString    string which contain payment information
    */
    function refundOtherCrypto(
        address _investor, 
        string _logString
    ) 
        public
        refundManagersOnly {
        require(
            statusICO == StatusICO.Finished && 
            soldAmount < softCap
        );
        uint tokensToBurn = tokensOtherCrypto[_investor];
        tokensOtherCrypto[_investor] = 0;
        DTRC.burnTokens(_investor, tokensToBurn);
        LogReturnOtherCrypto(_investor, _logString);
    }

   /**
    *   @dev Allows Company withdraw investments when ICO is over and soft cap achieved
    */
    function withdrawEther() external managersOnly {
        require(statusICO == StatusICO.Finished && soldAmount >= softCap);
        Company.transfer(this.balance);
    }

}

/**
 *   @title DatariusToken
 *   @dev Datarius token contract
 */
contract DatariusToken is ERC20 {
    using SafeMath for uint;
    string public name = "Datarius Credit";
    string public symbol = "DTRC";
    uint public decimals = 18;

    // Ico contract address
    address public ico;
    event Burn(address indexed from, uint value);
    
    // Tokens transfer ability status
    bool public tokensAreFrozen = true;

    // Allows execution by the owner only
    modifier icoOnly { 
        require(msg.sender == ico); 
        _; 
    }

   /**
    *   @dev Contract constructor function sets Ico address
    *   @param _ico          ico address
    */
    function DatariusToken(address _ico) public {
       ico = _ico;
    }

   /**
    *   @dev Function to mint tokens
    *   @param _holder       beneficiary address the tokens will be issued to
    *   @param _value        number of tokens to issue
    */
    function mintTokens(address _holder, uint _value) external icoOnly {
       require(_value > 0);
       balances[_holder] = balances[_holder].add(_value);
       totalSupply = totalSupply.add(_value);
       Transfer(0x0, _holder, _value);
    }


   /**
    *   @dev Function to enable token transfers
    */
    function defrost() external icoOnly {
       tokensAreFrozen = false;
    }


   /**
    *   @dev Burn Tokens
    *   @param _holder       token holder address which the tokens will be burnt
    *   @param _value        number of tokens to burn
    */
    function burnTokens(address _holder, uint _value) external icoOnly {
        require(balances[_holder] > 0);
        totalSupply = totalSupply.sub(_value);
        balances[_holder] = balances[_holder].sub(_value);
        Burn(_holder, _value);
    }

   /**
    *   @dev Get balance of tokens holder
    *   @param _holder        holder's address
    *   @return               balance of investor
    */
    function balanceOf(address _holder) constant returns (uint) {
         return balances[_holder];
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
    function transfer(address _to, uint _amount) public returns (bool) {
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
    function transferFrom(address _from, address _to, uint _amount) public returns (bool) {
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
    function approve(address _spender, uint _amount) public returns (bool) {
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
    function allowance(address _owner, address _spender) constant returns (uint) {
        return allowed[_owner][_spender];
    }
}