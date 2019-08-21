// Play2liveICO tokensale smart contract.
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

    mapping(address => uint256) balances;
    mapping(address => mapping (address => uint256)) allowed;

    function balanceOf(address _owner) constant returns (uint);
    function transfer(address _to, uint _value) returns (bool);
    function transferFrom(address _from, address _to, uint _value) returns (bool);
    function approve(address _spender, uint _value) returns (bool);
    function allowance(address _owner, address _spender) constant returns (uint);

    event Transfer(address indexed _from, address indexed _to, uint _value);
    event Approval(address indexed _owner, address indexed _spender, uint _value);

} 

/**
 *   @title Play2liveICO contract  - takes funds from users and issues tokens
 */
contract Play2liveICO {
    // LUC - Level Up Coin token contract
    using SafeMath for uint;
    LucToken public LUC = new LucToken(this);
    Presale public preSaleToken;

    // Token price parameters
    // These parametes can be changed only by manager of contract
    uint public tokensPerDollar = 20;
    uint public rateEth = 446; // Rate USD per ETH
    uint public tokenPrice = tokensPerDollar * rateEth; // DTRC per ETH
    //Crowdsale parameters
    uint constant publicIcoPart = 625; // 62,5% of TotalSupply for BountyFund
    uint constant operationsPart = 111;
    uint constant foundersPart = 104;
    uint constant partnersPart = 78; // 7,8% of TotalSupply for parnersFund
    uint constant advisorsPart = 72;
    uint constant bountyPart = 10; // 1% of TotalSupply for BountyFund
    uint constant hardCap = 30000000 * tokensPerDollar * 1e18; // 
    uint public soldAmount = 0;
    // Output ethereum addresses
    address public Company;
    address public OperationsFund;
    address public FoundersFund;
    address public PartnersFund;
    address public AdvisorsFund;
    address public BountyFund;
    address public Manager; // Manager controls contract
    address public Controller_Address1; // First address that is used to buy tokens for other cryptos
    address public Controller_Address2; // Second address that is used to buy tokens for other cryptos
    address public Controller_Address3; // Third address that is used to buy tokens for other cryptos
    address public Oracle; // Oracle address

    // Possible ICO statuses
    enum StatusICO {
        Created,
        PreIcoStarted,
        PreIcoPaused,
        PreIcoFinished,
        IcoStarted,
        IcoPaused,
        IcoFinished
    }
    StatusICO statusICO = StatusICO.Created;
    
    // Mappings
    mapping(address => bool) public swaped;
    mapping (address => string) public keys;
    
    // Events Log
    event LogStartPreICO();
    event LogPausePreICO();
    event LogFinishPreICO();
    event LogStartICO();
    event LogPauseICO();
    event LogFinishICO();
    event LogBuyForInvestor(address investor, uint lucValue, string txHash);
    event LogSwapTokens(address investor, uint tokensAmount);
    event LogRegister(address investor, string key);

    // Modifiers
    // Allows execution by the manager only
    modifier managerOnly { 
        require(msg.sender == Manager);
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
    function Play2liveICO(
        address _preSaleToken,
        address _Company,
        address _OperationsFund,
        address _FoundersFund,
        address _PartnersFund,
        address _AdvisorsFund,
        address _BountyFund,
        address _Manager,
        address _Controller_Address1,
        address _Controller_Address2,
        address _Controller_Address3,
        address _Oracle
        ) public {
        preSaleToken = Presale(_preSaleToken);
        Company = _Company;
        OperationsFund = _OperationsFund;
        FoundersFund = _FoundersFund;
        PartnersFund = _PartnersFund;
        AdvisorsFund = _AdvisorsFund;
        BountyFund = _BountyFund;
        Manager = _Manager;
        Controller_Address1 = _Controller_Address1;
        Controller_Address2 = _Controller_Address2;
        Controller_Address3 = _Controller_Address3;
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
    *   @dev Function to start PreICO
    *   Sets ICO status to PreIcoStarted
    */
    function startPreIco() external managerOnly {
        require(statusICO == StatusICO.Created || statusICO == StatusICO.PreIcoPaused);
        statusICO = StatusICO.PreIcoStarted;
        LogStartPreICO();
    }

   /**
    *   @dev Function to pause PreICO
    *   Sets ICO status to PreIcoPaused
    */
    function pausePreIco() external managerOnly {
       require(statusICO == StatusICO.PreIcoStarted);
       statusICO = StatusICO.PreIcoPaused;
       LogPausePreICO();
    }

   /**
    *   @dev Function to finish PreICO
    *   Sets ICO status to PreIcoFinished
    */
    function finishPreIco() external managerOnly {
        require(statusICO == StatusICO.PreIcoStarted || statusICO == StatusICO.PreIcoPaused);
        statusICO = StatusICO.PreIcoFinished;
        LogFinishPreICO();
    }

   /**
    *   @dev Function to start ICO
    *   Sets ICO status to IcoStarted
    */
    function startIco() external managerOnly {
        require(statusICO == StatusICO.PreIcoFinished || statusICO == StatusICO.IcoPaused);
        statusICO = StatusICO.IcoStarted;
        LogStartICO();
    }

   /**
    *   @dev Function to pause ICO
    *   Sets ICO status to IcoPaused
    */
    function pauseIco() external managerOnly {
       require(statusICO == StatusICO.IcoStarted);
       statusICO = StatusICO.IcoPaused;
       LogPauseICO();
    }

   /**
    *   @dev Function to finish ICO
    *   Sets ICO status to IcoFinished and  emits tokens for funds
    */
    function finishIco() external managerOnly {
        require(statusICO == StatusICO.IcoStarted || statusICO == StatusICO.IcoPaused);
        uint alreadyMinted = LUC.totalSupply();
        uint totalAmount = alreadyMinted.mul(1000).div(publicIcoPart);
        LUC.mintTokens(OperationsFund, operationsPart.mul(totalAmount).div(1000));
        LUC.mintTokens(FoundersFund, foundersPart.mul(totalAmount).div(1000));
        LUC.mintTokens(PartnersFund, partnersPart.mul(totalAmount).div(1000));
        LUC.mintTokens(AdvisorsFund, advisorsPart.mul(totalAmount).div(1000));
        LUC.mintTokens(BountyFund, bountyPart.mul(totalAmount).div(1000));
        statusICO = StatusICO.IcoFinished;
        LogFinishICO();
    }

   /**
    *   @dev Unfreeze tokens(enable token transfers)
    */
    function unfreeze() external managerOnly {
        require(statusICO == StatusICO.IcoFinished);
        LUC.defrost();
    }
    
   /**
    *   @dev Function to swap tokens from pre-sale
    *   @param _investor     pre-sale tokens holder address
    */
    function swapTokens(address _investor) external managerOnly {
         require(statusICO != StatusICO.IcoFinished);
         require(!swaped[_investor]);
         swaped[_investor] = true;
         uint tokensToSwap = preSaleToken.balanceOf(_investor);
         LUC.mintTokens(_investor, tokensToSwap);
         soldAmount = soldAmount.add(tokensToSwap);
         LogSwapTokens(_investor, tokensToSwap);
    }
   /**
    *   @dev Fallback function calls buy(address _investor, uint _DTRCValue) function to issue tokens
    *        when investor sends ETH to address of ICO contract and then stores investment amount 
    */
    function() external payable {
        if (statusICO == StatusICO.PreIcoStarted) {
            require(msg.value >= 100 finney);
        }
        buy(msg.sender, msg.value.mul(tokenPrice)); 
    }

   /**
    *   @dev Function to issues tokens for investors who made purchases in other cryptocurrencies
    *   @param _investor     address the tokens will be issued to
    *   @param _txHash       transaction hash of investor's payment
    *   @param _lucValue     number of LUC tokens
    */

    function buyForInvestor(
        address _investor, 
        uint _lucValue, 
        string _txHash
    ) 
        external 
        controllersOnly {
        buy(_investor, _lucValue);
        LogBuyForInvestor(_investor, _lucValue, _txHash);
    }

   /**
    *   @dev Function to issue tokens for investors who paid in ether
    *   @param _investor     address which the tokens will be issued tokens
    *   @param _lucValue     number of LUC tokens
    */
    function buy(address _investor, uint _lucValue) internal {
        require(statusICO == StatusICO.PreIcoStarted || statusICO == StatusICO.IcoStarted);
        uint bonus = getBonus(_lucValue);
        uint total = _lucValue.add(bonus);
        require(soldAmount + _lucValue <= hardCap);
        LUC.mintTokens(_investor, total);
        soldAmount = soldAmount.add(_lucValue);
    }



   /**
    *   @dev Function to calculates bonuses 
    *   @param _value        amount of tokens
    *   @return              bonus value
    */
    function getBonus(uint _value) public constant returns (uint) {
        uint bonus = 0;
        if (statusICO == StatusICO.PreIcoStarted) {
            if (now < 1517356800) {
                bonus = _value.mul(30).div(100);
                return bonus;
            } else {
                bonus = _value.mul(25).div(100);
                return bonus;                
            }
        }
        if (statusICO == StatusICO.IcoStarted) {
            if (now < 1518652800) {
                bonus = _value.mul(10).div(100);
                return bonus;                   
            }
            if (now < 1518912000) {
                bonus = _value.mul(9).div(100);
                return bonus;                   
            }
            if (now < 1519171200) {
                bonus = _value.mul(8).div(100);
                return bonus;                   
            }
            if (now < 1519344000) {
                bonus = _value.mul(7).div(100);
                return bonus;                   
            }
            if (now < 1519516800) {
                bonus = _value.mul(6).div(100);
                return bonus;                   
            }
            if (now < 1519689600) {
                bonus = _value.mul(5).div(100);
                return bonus;                   
            }
            if (now < 1519862400) {
                bonus = _value.mul(4).div(100);
                return bonus;                   
            }
            if (now < 1520035200) {
                bonus = _value.mul(3).div(100);
                return bonus;                   
            }
            if (now < 1520208000) {
                bonus = _value.mul(2).div(100);
                return bonus;                   
            } else {
                bonus = _value.mul(1).div(100);
                return bonus;                   
            }
        }
        return bonus;
    }

   /**
    *   @dev Allows invetsot to register thier Level Up Chain address
    */
    function register(string _key) public {
        keys[msg.sender] = _key;
        LogRegister(msg.sender, _key);
    }

   /**
    *   @dev Allows Company withdraw investments
    */
    function withdrawEther() external managerOnly {
        Company.transfer(this.balance);
    }

}

/**
 *   @title LucToken
 *   @dev Luc token contract
 */
contract LucToken is ERC20 {
    using SafeMath for uint;
    string public name = "Level Up Coin";
    string public symbol = "LUC";
    uint public decimals = 18;

    // Ico contract address
    address public ico;
    
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
    function LucToken(address _ico) public {
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
    *   @dev Get balance of tokens holder
    *   @param _holder        holder's address
    *   @return               balance of investor
    */
    function balanceOf(address _holder) constant returns (uint256) {
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
    function transfer(address _to, uint256 _amount) public returns (bool) {
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
    function transferFrom(address _from, address _to, uint256 _amount) public returns (bool) {
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
    function approve(address _spender, uint256 _amount) public returns (bool) {
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
    function allowance(address _owner, address _spender) constant returns (uint256) {
        return allowed[_owner][_spender];
    }
}





contract tokenLUCG {
    /* Public variables of the token */
        string public name;
        string public symbol;
        uint8 public decimals;
        uint256 public totalSupply = 0;


        function tokenLUCG (string _name, string _symbol, uint8 _decimals){
            name = _name;
            symbol = _symbol;
            decimals = _decimals;

        }
    /* This creates an array with all balances */
        mapping (address => uint256) public balanceOf;

}

contract Presale is tokenLUCG {

        using SafeMath for uint;
        string name = 'Level Up Coin Gold';
        string symbol = 'LUCG';
        uint8 decimals = 18;
        address manager;
        address public ico;

        function Presale (address _manager) tokenLUCG (name, symbol, decimals){
             manager = _manager;

        }

        event Transfer(address _from, address _to, uint256 amount);
        event Burn(address _from, uint256 amount);

        modifier onlyManager{
             require(msg.sender == manager);
            _;
        }

        modifier onlyIco{
             require(msg.sender == ico);
            _;
        }
        function mintTokens(address _investor, uint256 _mintedAmount) public onlyManager {
             balanceOf[_investor] = balanceOf[_investor].add(_mintedAmount);
             totalSupply = totalSupply.add(_mintedAmount);
             Transfer(this, _investor, _mintedAmount);

        }

        function burnTokens(address _owner) public onlyIco{
             uint  tokens = balanceOf[_owner];
             require(balanceOf[_owner] != 0);
             balanceOf[_owner] = 0;
             totalSupply = totalSupply.sub(tokens);
             Burn(_owner, tokens);
        }

        function setIco(address _ico) onlyManager{
            ico = _ico;
        }
}