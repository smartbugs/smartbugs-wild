pragma solidity ^0.4.18;

// Created by Roman Oznobin (oz_r@mail.ru) - http://code-expert.pro
// Owner is Alexey Malashkin (leningrad18@yandex.ru)
// Smart contract for BasisToken of Ltd "KKM" (armaturaplus@mail.ru) - http://ruarmatura.ru/

library SafeMath {

  function mul(uint a, uint b) internal pure returns (uint) {
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

  function add(uint a, uint b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }

}

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
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
     address inp_sender = msg.sender;
     bool chekk = msg.sender == owner;
    require(chekk);
    _;
  }

  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param newOwner The address to transfer ownership to.
   */
  function transferOwnership(address newOwner) public onlyOwner {
    require(newOwner != address(0));
    owner = newOwner;
  }

}

// The contract...

contract BasisIco  {

  using SafeMath for uint;
  
    string public constant name = "Basis Token";

    string public constant symbol = "BSS";

    uint32 public constant decimals = 0;  
    
    struct Investor {
        address holder;
        uint tokens;

    }
  
    Investor[] internal Cast_Arr;
     
    Investor tmp_investor;  
      
  
  // Used to set wallet for owner, bounty and developer
  // To that address Ether will be sended if Ico will have sucsess done
  // Untill Ico is no finish and is no sucsess, all Ether are closed from anybody on ICO contract wallet
  address internal constant owner_wallet = 0x79d8af6eEA6Aeeaf7a3a92D348457a5C4f0eEe1B;
  address public constant owner = 0x79d8af6eEA6Aeeaf7a3a92D348457a5C4f0eEe1B;
  address internal constant developer = 0xf2F1A92AD7f1124ef8900931ED00683f0B3A5da7;

  //
  //address public bounty_wallet = 0x79d8af6eEA6Aeeaf7a3a92D348457a5C4f0eEe1B;

  uint public constant bountyPercent = 4;
  

  //address public bounty_reatricted_addr;
  //Base price for BSS ICO. Show how much Wei is in 1 BSS. During ICO price calculate from the $rate
  uint internal constant rate = 3300000000000000;
  
    uint public token_iso_price;
// Генерируется в Crowdsale constructor
//  BasisToken public token = new BasisToken();

  // Time sructure of Basis ico
  // start_declaration of first round of Basis ico - Presale ( start_declaration of token creation and ico Presale )
  uint public start_declaration = 1511384400;
  // The period for calculate the time structure of Basis ico, amount of the days
  uint public ico_period = 15;
  // First round finish - Presale finish
  uint public presale_finish;
  // ico Second raund start.
  uint public second_round_start;
  // Basis ico finish, all mint are closed
  uint public ico_finish = start_declaration + (ico_period * 1 days).mul(6);


  // Limmits and callculation of total minted Basis token
    uint public constant hardcap = 1536000;
    // minimal for softcap
    uint public softcap = 150000;
    // Total suplied Basis token during ICO
    uint public bssTotalSuply;
    // Wei raised during ICO
    uint public weiRaised;
  //  list of owners and token balances 
    mapping(address => uint) public ico_balances;
  //  list of owners and ether balances for refund    
    mapping(address => uint) public ico_investor;
   
    event TokenPurchase(address indexed purchaser, address indexed beneficiary, uint256 value, uint256 amount);
    event  Finalized();  
    event Transfer(address indexed from, address indexed to, uint256 value);    
    event Approval(address indexed owner, address indexed spender, uint256 value);

    
    bool RefundICO =false;
    bool isFinalized =false;
    // The map of allowed tokens for external address access
    mapping (address => mapping (address => uint256)) allowed;
    
// The constractor of contract ...
  function BasisIco() public     {

 
    weiRaised = 0;
    bssTotalSuply = 0;
  
    
    token_iso_price = rate.mul(80).div(100); 



    presale_finish = start_declaration + (ico_period * 1 days);
    second_round_start = start_declaration + (ico_period * 1 days).mul(2);
  }
  
    modifier saleIsOn() {
      require(now > start_declaration && now < ico_finish);
      _;
    }

    modifier NoBreak() {
      require(now < presale_finish  || now > second_round_start);
      _;
    }

    modifier isUnderHardCap() {
      require (bssTotalSuply <= hardcap);
      _;
    }  
    
    modifier onlyOwner() {
         address inp_sender = msg.sender;
         bool chekk = msg.sender == owner;
        require(chekk);
    _;
     }
  
    function setPrice () public isUnderHardCap saleIsOn {
          if  (now < presale_finish ){
               // Chek total supply BSS for price level changes
              if( bssTotalSuply > 50000 && bssTotalSuply <= 100000 ) {
                  token_iso_price = rate.mul(85).div(100);
              }
                if( bssTotalSuply > 100000 && bssTotalSuply <= 150000 ) {
                  token_iso_price = rate.mul(90).div(100);
                  }

          }
          else {
               if(bssTotalSuply <= 200000) {
                   token_iso_price = rate.mul(90).div(100);
               } else { if(bssTotalSuply <= 400000) {
                        token_iso_price = rate.mul(95).div(100);
                        }
                        else {
                        token_iso_price = rate;
                        }
                      }
           }
    } 
    
    function getActualPrice() public returns (uint) {
        setPrice ();        
        return token_iso_price;
    }  
    
     function validPurchase(uint _msg_value) internal constant returns (bool) {
     bool withinPeriod = now >= start_declaration && now <= ico_finish;
     bool nonZeroPurchase = _msg_value != 0;
     return withinPeriod && nonZeroPurchase;
   }
   
   function token_mint(address _investor, uint _tokens, uint _wei) internal {
       
       ico_balances[_investor] = ico_balances[_investor].add(_tokens);
       tmp_investor.holder = _investor;
       tmp_investor.tokens = _tokens;
       Cast_Arr.push(tmp_investor);
       ico_investor[_investor]= ico_investor[_investor].add(_wei);
   }
    
   function buyTokens() external payable saleIsOn NoBreak {
     
     //require(beneficiary != address(0));
     require(validPurchase(msg.value));

     uint256 weiAmount = msg.value;

     // calculate token amount to be created
     uint256 tokens = weiAmount.div(token_iso_price);
     if  (now < presale_finish ){
         require ((bssTotalSuply + tokens) <= softcap);
     }
    require ((bssTotalSuply + tokens) < hardcap);
     // update state
     weiRaised = weiRaised.add(weiAmount);

     token_mint( msg.sender, tokens, msg.value);
     TokenPurchase(msg.sender, msg.sender, weiAmount, tokens);

     //forwardFunds();
     bssTotalSuply += tokens;
    }

   // fallback function can be used to buy tokens
   function () external payable {
     buyTokensFor(msg.sender);
   } 

   function buyTokensFor(address beneficiary) public payable saleIsOn NoBreak {
     
     require(beneficiary != address(0));
     require(validPurchase(msg.value));

     uint256 weiAmount = msg.value;

     // calculate token amount to be created
     uint256 tokens = weiAmount.div(token_iso_price);
      if  (now < presale_finish ){
         require ((bssTotalSuply + tokens) <= softcap);
     }
    require ((bssTotalSuply + tokens) < hardcap);
     // update state
     weiRaised = weiRaised.add(weiAmount);

     token_mint( beneficiary, tokens, msg.value);
     TokenPurchase(msg.sender, beneficiary, weiAmount, tokens);

     //forwardFunds();
     bssTotalSuply += tokens;
 }
 
   function extraTokenMint(address beneficiary, uint _tokens) external payable saleIsOn onlyOwner {
     
    require(beneficiary != address(0));
    require ((bssTotalSuply + _tokens) < hardcap);
    
    uint weiAmount = _tokens.mul(token_iso_price);
     // update state
    weiRaised = weiRaised.add(weiAmount);

     token_mint( beneficiary, _tokens, msg.value);
     TokenPurchase(msg.sender, beneficiary, weiAmount, _tokens);

     //forwardFunds();
     bssTotalSuply += _tokens;
  }

  function goalReached() public constant returns (bool) {
    return bssTotalSuply >= softcap;
  }
  
  function bounty_mining () internal {
    uint bounty_tokens = bssTotalSuply.mul(bountyPercent).div(100);
    uint tmp_z = 0;
    token_mint(owner_wallet, bounty_tokens, tmp_z);
    bssTotalSuply += bounty_tokens;
    }  
  
  // vault finalization task, called when owner calls finalize()
  function finalization() public onlyOwner {
    require (now > ico_finish);
    if (goalReached()) {
        bounty_mining ();
        EtherTakeAfterSoftcap ();
        } 
    else {
        RefundICO = true;    
    }
    isFinalized = true;
    Finalized();
  }  

  function investor_Refund()  public {
        require (RefundICO && isFinalized);
        address investor = msg.sender;
        uint for_refund = ico_investor[msg.sender];
        investor.transfer(for_refund);

  }
  
  function EtherTakeAfterSoftcap () onlyOwner public {
      require ( bssTotalSuply >= softcap );
      uint for_developer = this.balance;
      for_developer = for_developer.mul(6).div(100);
      developer.transfer(for_developer);
      owner.transfer(this.balance);
  }

  function balanceOf(address _owner) constant public returns (uint256 balance) {
    return ico_balances[_owner];
  }
  
   function transfer(address _to, uint256 _value) public returns (bool) {
    ico_balances[msg.sender] = ico_balances[msg.sender].sub(_value);
    ico_balances[_to] = ico_balances[_to].add(_value);
    Transfer(msg.sender, _to, _value);
    return true;
  } 

  function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
    var _allowance = allowed[_from][msg.sender];

    // Check is not needed because sub(_allowance, _value) will already throw if this condition is not met
    require (_value <= _allowance);

    ico_balances[_to] = ico_balances[_to].add(_value);
    ico_balances[_from] = ico_balances[_from].sub(_value);
    allowed[_from][msg.sender] = _allowance.sub(_value);
    Transfer(_from, _to, _value);
    return true;
  }
  
  function approve(address _spender, uint256 _value) public returns (bool) {

    require((_value == 0) || (allowed[msg.sender][_spender] == 0));

    allowed[msg.sender][_spender] = _value;
    Approval(msg.sender, _spender, _value);
    return true;
  }  

  function allowance(address _owner, address _spender) constant public returns (uint256 remaining) {
    return allowed[_owner][_spender];
  }

}