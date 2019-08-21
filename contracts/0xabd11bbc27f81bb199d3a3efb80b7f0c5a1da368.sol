/*

SHTCOIN (SHT)

THE NAME YOU KNOW

WEB:      https://shtcoin.cash

DISCORD:  https://discord.gg/SRhBEtK

When your grandkids ask how you were able to afford the million dollar bribes to get them 
into college.........SHTCOIN.

*/


pragma solidity ^0.4.10;

contract SafeMath {



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

contract SHTCoin is StandardToken, SafeMath {

    // metadata
    string public constant name = "SHTCOIN";
    string public constant symbol = "SHT";
    uint256 public constant decimals = 18;
    string public version = "1.0";

    // contracts
    address public ethFundDeposit;      // deposit address for ETH for SHT HQ
    address public SHTFundDeposit;      // deposit address for SHT User Fund

    // crowdsale parameters
    bool public isFinalized;              // switched to true in operational state
    uint256 public fundingStartBlock;
    uint256 public fundingEndBlock;
    uint256 public constant SHTFund = 5000 * (10**4) * 10**decimals;   // 5000b SHT reserved for SHT HQ use
    uint256 public constant tokenExchangeRate = 10000; // 10000 SHT tokens per 1 ETH
    uint256 public constant tokenCreationCap =  5000 * (10**4) * 10**decimals;
    uint256 public constant tokenCreationMin =  675 * (10**4) * 10**decimals;


    // events
    event LogRefund(address indexed _to, uint256 _value);
    event CreateSHT(address indexed _to, uint256 _value);

    // constructor
    function SHTCoin(
        address _ethFundDeposit,
        address _SHTFundDeposit,
        uint256 _fundingStartBlock,
        uint256 _fundingEndBlock)
    {
      isFinalized = true;                   //we won't have a crowdsale, airdrops will deliver tokens to the community
      ethFundDeposit = _ethFundDeposit;
      SHTFundDeposit = _SHTFundDeposit;
      fundingStartBlock = _fundingStartBlock;
      fundingEndBlock = _fundingEndBlock;
      totalSupply = SHTFund;
      balances[SHTFundDeposit] = SHTFund;    // Deposit SHT
      CreateSHT(SHTFundDeposit, SHTFund);  // logs SHT fund
    }





}