pragma solidity ^0.4.10;

/* taking ideas from FirstBlood token */
contract SafeMath {

    /* function assert(bool assertion) internal { */
    /*   if (!assertion) { */
    /*     throw; */
    /*   } */
    /* }      // assert no longer needed once solidity is on 0.4.10 */

    function safeAdd(uint256 x, uint256 y) internal returns(uint256) {
      uint256 z = x + y;
      assert((z >= x) && (z >= y));
      return z;
    }

    function safeSubtract(uint256 x, uint256 y) internal returns(uint256) {
      assert(x >= y);
      uint256 z = x - y;
      return z;
    }

    function safeMult(uint256 x, uint256 y) internal returns(uint256) {
      uint256 z = x * y;
      assert((x == 0)||(z/x == y));
      return z;
    }

}


contract Token {
    uint256 public totalSupply;
    function balanceOf(address _owner) constant returns (uint256 balance);
    function transfer(address _to, uint256 _value) returns (bool success);
    function transferFrom(address _from, address _to, uint256 _value) returns (bool success);
    function approve(address _spender, uint256 _value) returns (bool success);
    function allowance(address _owner, address _spender) constant returns (uint256 remaining);
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}


/*  ERC 20 token */
contract StandardToken is Token {

    function transfer(address _to, uint256 _value) returns (bool success) {
      if (balances[msg.sender] >= _value && _value > 0) {
        balances[msg.sender] -= _value;
        balances[_to] += _value;
        Transfer(msg.sender, _to, _value);
        return true;
      } else {
        return false;
      }
    }

    function transferFrom(address _from, address _to, uint256 _value) returns (bool success) {
      if (balances[_from] >= _value && allowed[_from][msg.sender] >= _value && _value > 0) {
        balances[_to] += _value;
        balances[_from] -= _value;
        allowed[_from][msg.sender] -= _value;
        Transfer(_from, _to, _value);
        return true;
      } else {
        return false;
      }
    }

    function balanceOf(address _owner) constant returns (uint256 balance) {
        return balances[_owner];
    }

    function approve(address _spender, uint256 _value) returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }

    function allowance(address _owner, address _spender) constant returns (uint256 remaining) {
      return allowed[_owner][_spender];
    }

    mapping (address => uint256) balances;
    mapping (address => mapping (address => uint256)) allowed;
}
contract Indicoin is StandardToken, SafeMath {

    // metadata
    string public constant name = "Indicoin";
    string public constant symbol = "INDI";
    uint256 public constant decimals = 18;
    string public version = "1.0";

    // contracts
    address public ethFundDeposit;      // deposit address for ETH for Indicoin Developers
    address public indiFundAndSocialVaultDeposit;      // deposit address for indicoin developers use and social vault 
    address public bountyDeposit; // deposit address for bounty
    address public preSaleDeposit; //deposit address for preSale
    // crowdsale parameters
    bool public isFinalized;              // switched to true in operational state
    uint256 public fundingStartTime;
    uint256 public fundingEndTime;
    uint256 public constant indiFundAndSocialVault = 550 * (10**6) * 10**decimals;   // 100m INDI reserved for team use and 450m for social vault
    uint256 public constant bounty = 50 * (10**6) * 10**decimals; // 50m INDI reserved for bounty
    uint256 public constant preSale = 20 * (10**6) * 10**decimals; // 20m INDI reserved for preSale manual distribution
    uint256 public constant tokenExchangeRate = 12500; // 12500 INDI tokens per 1 ETH
    uint256 public constant tokenCreationCap =  1000 * (10**6) * 10**decimals;
    uint256 public constant tokenCreationMin =  620 * (10**6) * 10**decimals;


    // events
    event LogRefund(address indexed _to, uint256 _value);
    event CreateINDI(address indexed _to, uint256 _value);
    

    
    function Indicoin()
    {
      isFinalized = false;                   //controls pre through crowdsale state
      ethFundDeposit = 0xD4A92E6E8f57080e5a73D398B85c6549458a70Ea;
      indiFundAndSocialVaultDeposit = 0xa2551Fa409bEcdacba3A3EAef30e9b3a510F401b;
      preSaleDeposit = 0xfD9264b3Fe7361063f0a0a09BD3557b07A156f17;
      bountyDeposit = 0xc987598c81446b8224818790fF54e4539FE5344B;
      fundingStartTime = 1506814200;
      fundingEndTime = 1509494400;
      
      totalSupply = indiFundAndSocialVault + bounty + preSale;
      balances[indiFundAndSocialVaultDeposit] = indiFundAndSocialVault; // Deposit Indicoin developers share
      balances[bountyDeposit] = bounty; //Deposit bounty Share
      balances[preSaleDeposit] = preSale; //Deposit preSale Share
      CreateINDI(indiFundAndSocialVaultDeposit, indiFundAndSocialVault);  // logs indicoin developers fund
      CreateINDI(bountyDeposit, bounty); // logs bounty fund
      CreateINDI(preSaleDeposit, preSale); // logs preSale fund
    }
    
    
    /// @dev Accepts ether and creates new INDI tokens.
    function createTokens() payable external {
      if (isFinalized) revert();
      if (now < fundingStartTime) revert();
      if (now > fundingEndTime) revert();
      if (msg.value == 0) revert();

      uint256 tokens = safeMult(msg.value, tokenExchangeRate); // check that we're not over totals
      uint256 checkedSupply = safeAdd(totalSupply, tokens);

      // return money if something goes wrong
      if (tokenCreationCap < checkedSupply) revert();  // odd fractions won't be found

      totalSupply = checkedSupply;
      balances[msg.sender] += tokens;  // safeAdd not needed; bad semantics to use here
      CreateINDI(msg.sender, tokens);  // logs token creation
    }

    /// @dev Ends the funding period and sends the ETH home
    function finalize() external {
      if (isFinalized) revert();
      if (msg.sender != ethFundDeposit) revert(); // locks finalize to the ultimate ETH owner
      if(totalSupply < tokenCreationMin) revert();      // have to sell minimum to move to operational
      if(now <= fundingEndTime && totalSupply != tokenCreationCap) revert();
      // move to operational
      isFinalized = true;
      if(!ethFundDeposit.send(this.balance)) revert();  // send the eth to Indicoin developers
    }

    /// @dev Allows contributors to recover their ether in the case of a failed funding campaign.
    function refund() external {
      if(isFinalized) revert();                       // prevents refund if operational
      if (now <= fundingEndTime) revert(); // prevents refund until sale period is over
      if(totalSupply >= tokenCreationMin) revert();  // no refunds if we sold enough
      if(msg.sender == indiFundAndSocialVaultDeposit) revert();    // Indicoin developers not entitled to a refund
      uint256 indiVal = balances[msg.sender];
      if (indiVal == 0) revert();
      balances[msg.sender] = 0;
      totalSupply = safeSubtract(totalSupply, indiVal); // extra safe
      uint256 ethVal = indiVal / tokenExchangeRate;     // should be safe; previous throws covers edges
      LogRefund(msg.sender, ethVal);               // log it 
      if (!msg.sender.send(ethVal)) revert();       // if you're using a contract; make sure it works with .send gas limits
    }

}