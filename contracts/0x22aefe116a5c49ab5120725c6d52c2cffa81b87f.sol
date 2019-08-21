// ICO Platform Demo smart contract.
// Developed by Phenom.Team <info@phenom.team>
pragma solidity ^0.4.18;

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
 *   @title PhenomTeam contract  - takes funds and issues tokens
 */
contract PhenomTeam {
    // PHN - Phenom Demo Token contract 
    using SafeMath for uint;
    PhenomDemoToken public PHN = new PhenomDemoToken(this);

    
    // rateEth can be changed only by Oracle
    uint public rateEth = 878; // Rate USD per ETH

    // Output ethereum addresses
    address public Company;
    address public Manager; // Manager controls contract
    address public Controller_Address1; // First address that is used to buy tokens for other cryptos
    address public Controller_Address2; // Second address that is used to buy tokens for other cryptos
    address public Controller_Address3; // Third address that is used to buy tokens for other cryptos
    address public Oracle; // Oracle address

    // Possible ICO statuses
    enum StatusICO {
        Created,
        Started,
        Paused,
        Finished
    }
    StatusICO statusICO = StatusICO.Created;
    
    // Events Log
    event LogStartICO();
    event LogPause();
    event LogFinishICO();
    event LogBuyForInvestor(address investor, uint DTRCValue, string txHash);

    // Modifiers
    // Allows execution by the manager only
    modifier managerOnly { 
        require(
            msg.sender == Manager
        );
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
    function PhenomTeam(
        address _Company,
        address _Manager,
        address _Controller_Address1,
        address _Controller_Address2,
        address _Controller_Address3,
        address _Oracle
        ) public {
        Company = _Company;
        Manager = _Manager;
        Controller_Address1 = _Controller_Address1;
        Controller_Address2 = _Controller_Address2;
        Controller_Address3 = _Controller_Address3;
        Oracle = _Oracle;
    }

   /**
    *   @dev Function to set rate of ETH
    *   @param _rateEth       current ETH rate
    */
    function setRate(uint _rateEth) external oracleOnly {
        rateEth = _rateEth;
    }

   /**
    *   @dev Function to start ICO
    *   Sets ICO status to Started
    */
    function startIco() external managerOnly {
        require(statusICO == StatusICO.Created || statusICO == StatusICO.Paused);
        statusICO = StatusICO.Started;
        LogStartICO();
    }

   /**
    *   @dev Function to pause ICO
    *   Sets ICO status to Paused
    */
    function pauseIco() external managerOnly {
       require(statusICO == StatusICO.Started);
       statusICO = StatusICO.Paused;
       LogPause();
    }

   /**
    *   @dev Function to finish ICO
    */
    function finishIco() external managerOnly {
        require(statusICO == StatusICO.Started || statusICO == StatusICO.Paused);
        statusICO = StatusICO.Finished;
        LogFinishICO();
    }

   /**
    *   @dev Fallback function calls buy(address _investor, uint _PHNValue) function to issue tokens
    *        when investor sends ETH to address of ICO contract
    */
    function() external payable {
        buy(msg.sender, msg.value.mul(rateEth)); 
    }

   /**
    *   @dev Function to issues tokens for investors who made purchases in other cryptocurrencies
    *   @param _investor     address the tokens will be issued to
    *   @param _txHash       transaction hash of investor's payment
    *   @param _PHNValue     number of PHN tokens
    */

    function buyForInvestor(
        address _investor, 
        uint _PHNValue, 
        string _txHash
    ) 
        external 
        controllersOnly {
        buy(_investor, _PHNValue);
        LogBuyForInvestor(_investor, _PHNValue, _txHash);
    }

   /**
    *   @dev Function to issue tokens for investors who paid in ether
    *   @param _investor     address which the tokens will be issued tokens
    *   @param _PHNValue     number of PHN tokens
    */
    function buy(address _investor, uint _PHNValue) internal {
        require(statusICO == StatusICO.Started);
        PHN.mintTokens(_investor, _PHNValue);
    }

   /**
    *   @dev Function to enable token transfers
    */
    function unfreeze() external managerOnly {
       PHN.defrost();
    }

   /**
    *   @dev Function to disable token transfers
    */
    function freeze() external managerOnly {
       PHN.frost();
    }

   /**
    *   @dev Function to change withdrawal address
    *   @param _Company     new withdrawal address
    */   
    function setWithdrawalAddress(address _Company) external managerOnly {
        Company = _Company;
    }
   
   /**
    *   @dev Allows Company withdraw investments
    */
    function withdrawEther() external managerOnly {
        Company.transfer(this.balance);
    }

}

/**
 *   @title PhenomDemoToken
 *   @dev Phenom Demo Token contract 
 */
contract PhenomDemoToken is ERC20 {
    using SafeMath for uint;
    string public name = "ICO Platform Demo | https://Phenom.Team ";
    string public symbol = "PHN";
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
    function PhenomDemoToken(address _ico) public {
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
    *   @dev Function to disable token transfers
    */
    function frost() external icoOnly {
       tokensAreFrozen = true;
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