pragma solidity ^0.4.11;


/**
 * SafeMath
 * Math operations with safety checks that throw on error
 */
 
library SafeMath {
  
    function mul(uint256 a, uint256 b) internal constant returns (uint256) {
    uint256 c = a * b;
    assert(a == 0 || c / a == b);
    return c;
    }

    function div(uint256 a, uint256 b) internal constant returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
    }

    function sub(uint256 a, uint256 b) internal constant returns (uint256) {
    assert(b <= a);
    return a - b;
    }

    function add(uint256 a, uint256 b) internal constant returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
    }
    
    function max64(uint64 a, uint64 b) internal constant returns (uint64) {
    return a >= b ? a : b;
    }

    function max256(uint256 a, uint256 b) internal constant returns (uint256) {
    return a >= b ? a : b;
    }

    function min64(uint64 a, uint64 b) internal constant returns (uint64) {
    return a < b ? a : b;
    }

    function min256(uint256 a, uint256 b) internal constant returns (uint256) {
    return a < b ? a : b;
    }
    
}

/**
 * title ERC20 interface
 * dev see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20 {
    uint256 public totalSupply;
    bool public transferlocked;
    bool public wallocked;
    function balanceOf(address who) constant returns (uint256 balance);
    function transfer(address _to, uint256 _value) returns (bool success);
    function allowance(address _owner, address _spender) constant returns (uint256 remaining);
    function transferFrom(address _from, address _to, uint256 _value) returns (bool success);
    function approve(address spender, uint256 value) returns (bool success);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Burn(address indexed burner, uint indexed value);
}

/**
 * Basic token
 * Basic version of StandardToken, with no allowances.
 */

 
contract BasicToken is ERC20 {
    using SafeMath for uint256;

    mapping(address => uint256) balances;

    /**
    * transfer token for a specified address
    * _to The address to transfer to.
    * _value The amount to be transferred.
    */
    function transfer(address _to, uint256 _value) returns (bool success) {
        require(
            balances[msg.sender] >= _value
            && _value > 0
            );
        if (transferlocked) {
            throw;
        }
        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);
        Transfer(msg.sender, _to, _value);
        return true;
    }

    /**
    *  Gets the balance of the specified address.
    *  _owner The address to query the the balance of.
    *  An uint256 representing the amount owned by the passed address.
    */
    function balanceOf(address _owner) constant returns (uint256 balance) {
        return balances[_owner];
    }

}

/**
 *  Ownable
 * The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 * Thanks https://github.com/OpenZeppelin/zeppelin-solidity/
 */
contract Ownable {
    address public owner;

    /**
     * The Ownable constructor sets the original `owner` of the contract to the sender
     * account.
     */
    function Ownable() {
        owner = msg.sender;
    }

    /**
     * Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        assert(msg.sender == owner);
        _;
    }

    /**
     * Allows the current owner to transfer control of the contract to a newOwner.
     * newOwner The address to transfer ownership to.
     */
    function transferOwnership(address newOwner) onlyOwner {
        if (newOwner != address(0)) {
            owner = newOwner;
        }
    }
}

/**
 * Standard ERC20 token
 *
 * Implementation of the basic standard token.
 * https://github.com/ethereum/EIPs/issues/20
 */
contract StandardToken is BasicToken {

    mapping (address => mapping (address => uint256)) allowed;


    /**
     * Transfer tokens from one address to another
     * _from address The address which you want to send tokens from
     * _to address The address which you want to transfer to
     * _value uint256 the amout of tokens to be transfered
     */
    function transferFrom(address _from, address _to, uint256 _value) returns (bool) {
        require(
            allowed[_from][msg.sender] >=_value
            && balances[_from] >= _value
            && _value > 0
            );
        if (transferlocked) {
            throw;
        }

        // Check is not needed because sub(_allowance, _value) will already throw if this condition is not met
        // require (_value <= _allowed);

        balances[_to] = balances[_to].add(_value);
        balances[_from] = balances[_from].sub(_value);
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
        Transfer(_from, _to, _value);
        return true;
    }

    /**
     * Aprove the passed address to spend the specified amount of tokens on behalf of msg.sender.
     * _spender The address which will spend the funds.
     * _value The -amount of tokens to be spent.
     */
    function approve(address _spender, uint256 _value) returns (bool) {

        // To change the approve amount you first have to reduce the addresses`
        //  allowance to zero by calling `approve(_spender, 0)` if it is not
        //  already 0 to mitigate the race condition described here:
        //  https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
        require((_value == 0) || (allowed[msg.sender][_spender] == 0));
        if (transferlocked) {
            throw;
        }
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }

    /**
     * Function to check the amount of tokens that an owner allowed to a spender.
     * _owner address The address which owns the funds.
     * _spender address The address which will spend the funds.
     * A uint256 specifing the amount of tokens still avaible for the spender.
     */
    function allowance(address _owner, address _spender) constant returns (uint256 remaining) {
        return allowed[_owner][_spender];
    }


}

/**
 * Mintable token
 * Simple ERC20 Token example, with mintable token creation
 * Issue: * https://github.com/OpenZeppelin/zeppelin-solidity/issues/120
 * Based on code by TokenMarketNet: https://github.com/TokenMarketNet/ico/blob/master/contracts/MintableToken.sol
 */

contract MintburnToken is StandardToken, Ownable {
  event Mint(address indexed to, uint256 amount);
  event MintFinished();

  bool public mintingFinished = false;


  modifier canMint() {
    require(!mintingFinished);
    _;
  }

  /**
   * Function to mint tokens
   * _to The address that will receive the minted tokens.
   * _amount The amount of tokens to mint.
   * A boolean that indicates if the operation was successful.
   */
   
  function mint(address _to, uint256 _amount) onlyOwner canMint returns (bool) {
    totalSupply = totalSupply.add(_amount);
    balances[_to] = balances[_to].add(_amount);
    Mint(_to, _amount);
    Transfer(0x0, _to, _amount);
    return true;
  }
  
  /**
   *  Burn away the specified amount of CareerXon tokens
  */
  
  function burn(uint256 _value) onlyOwner returns (bool) {
    balances[msg.sender] = balances[msg.sender].sub(_value);
    totalSupply = totalSupply.sub(_value);
    Transfer(msg.sender, 0x0, _value);
    return true;
  }
   function burnFrom(address _from, uint256 _value) onlyOwner returns (bool success) {
        require(balances[_from] >= _value);                // Check if the targeted balance is enough
        require(_value <= allowed[_from][msg.sender]);    // Check allowance
        balances[_from] = balances[_from].sub(_value);                         // Subtract from the targeted balance
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);             // Subtract from the sender's allowance
        totalSupply = totalSupply.sub(_value);                              // Update totalSupply
        Burn(_from, _value);
        return true;
    }

  /**
   * Function to stop minting new tokens.
   * True if the operation was successful.
   */
   
  function finishMinting() onlyOwner returns (bool) {
    mintingFinished = true;
    MintFinished();
    return true;
  }
}

/**
 * CRN (CareerXon) Token
 *
 * Implements ERC 20 Token standard: https://github.com/ethereum/EIPs/issues/20 with the addition 
 * of ownership, a lock and issuing.
 *
 * created 08/20/2017
 * 
 */

contract CareerXonToken is MintburnToken{
    string public constant name = "CareerXon";
    string public constant symbol = "CRN";
    uint public constant decimals = 18;
    string public standard = "Token 0.1";
    uint256 public maxSupply = 1500000000000000000000000;
    //15,000,000 CareerXon tokens max supply

    // timestamps for first presale and ICO
    uint public startPreSale;
    uint public endPreSale;
    uint public startICO;
    uint public endICO;



    // how many token units a buyer gets per wei
    uint256 public rate;

    uint256 public minTransactionAmount;

    uint256 public raisedForEther = 0;

    modifier inActivePeriod() {
        require((startPreSale < now && now <= endPreSale) || (startICO < now && now <= endICO));
        _;
    }
    
    //prevent short address attack

    modifier onlyPayloadSize(uint size) {
        if(msg.data.length < size + 4) revert();
        _;

    }

    function CareerXonToken(uint _startP, uint _endP, uint _startI, uint _endI) {
        require(_startP < _endP);
        require(_startI < _endI);
        

        //12,900,000 for eth supply
        //2,000,000 for bitcoin and bitcoin cash sales supply minted
        //100,000 for bounty and transalation minted
        //After all these distribution, Remaining minted coins will be burned.
        totalSupply = 12900000000000000000000000;


        // 1 ETH = 1300 CareerXon + 50% bonus in presale on first day
        rate = 1300;

        // minimal invest 0.01 ETH
        minTransactionAmount = 0.01 ether;

        startPreSale = _startP;
        endPreSale = _endP;
        startICO = _startI;
        endICO = _endI;
        transferlocked = true;
        // wallet withdrawal lock for protection
        wallocked = true;

    }
    
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }
    
    //Allows owner to stop & start presale.
    //For PreSale starting date visit http://careerxon.com.
    
    function setupPeriodForPreSale(uint _start, uint _end) onlyOwner {
        require(_start < _end);
        startPreSale = _start;
        endPreSale = _end;
    }
    
    //For ICO and project details visit http://careerxon.com
    //Total Amount to be sold 15,000,000
    //Left over OR unsold coins will be burned.
    
    function setupPeriodForICO(uint _start, uint _end) onlyOwner {
        require(_start < _end);
        startICO = _start;
        endICO = _end;
    }

    // fallback function can be used to buy tokens
    function () inActivePeriod payable {
        buyTokens(msg.sender);
    }

    // token auto purchase function
    function buyTokens(address _youraddress) inActivePeriod payable {
        require(_youraddress != 0x0);
        require(msg.value >= minTransactionAmount);

        uint256 weiAmount = msg.value;

        raisedForEther = raisedForEther.add(weiAmount);

        // calculate token amount to be created
        uint256 tokens = weiAmount.mul(rate);
        tokens += getBonus(tokens);
        tokens += getBonustwo(tokens);

        tokenReserved(_youraddress, tokens);

    }
    
    function withdraw(uint256 _value) onlyOwner returns (bool){
        if (wallocked) {
            throw;
        }
        owner.transfer(_value);
        return true;
    }
    function walunlock() onlyOwner returns (bool success)  {
        wallocked = false;
        return true;
    }
    function wallock() onlyOwner returns (bool success)  {
        wallocked = true;
        return true;
    }

    /*
    *    PreSale:
    *        Day 1: +50% bonus
    *        Day 2: +33% bonus
    *        Day 3: +20% bonus
    *        Day 4: +10% bonus
    */
    function getBonus(uint256 _tokens) constant returns (uint256 bonus) {
        require(_tokens != 0);
        if (1 == getCurrentPeriod()) {
            if (startPreSale <= now && now < startPreSale + 1 days) {
                return _tokens.div(2);
            } else if (startPreSale + 1 days <= now && now < startPreSale + 2 days ) {
                return _tokens.div(3);
            } else if (startPreSale + 2 days <= now && now < startPreSale + 3 days ) {
                return _tokens.div(5);
            }else if (startPreSale + 3 days <= now && now < startPreSale + 4 days ) {
                return _tokens.div(10);
            }
        }
        return 0;
    }
        
    /*
    *    ICO:
    *        Day 1: +20% bonus
    *        Day 2: +10% bonus
    *        Day 3: +5% bonus
    *        Day 4 & onwards: No bonuses
    */
    function getBonustwo(uint256 _tokens) constant returns (uint256 bonus) {
        require(_tokens != 0);
        if (2 == getCurrentPeriod()) {
            if (startICO <= now && now < startICO + 1 days) {
                return _tokens.div(5);
            } else if (startICO + 1 days <= now && now < startICO + 2 days ) {
                return _tokens.div(10);
            } else if (startICO + 2 days <= now && now < startICO + 3 days ) {
                return _tokens.mul(5).div(100);
            }
        }
    // Return 0 means token sales are closed
        return 0;
    }

    //start date & end date of presale and future ICO
    function getCurrentPeriod() inActivePeriod constant returns (uint){
        if ((startPreSale < now && now <= endPreSale)) {
            return 1;
        } else if ((startICO < now && now <= endICO)) {
            return 2;
        } else {
            return 0;
        }
    }

    function tokenReserved(address _to, uint256 _value) internal returns (bool) {
        balances[_to] = balances[_to].add(_value);
        Transfer(msg.sender, _to, _value);
        return true;
    }
    // token transfer lock. Unlock at end of Presale,ICO
    
    function transferunlock() onlyOwner returns (bool success)  {
        transferlocked = false;
        return true;
    }
    function transferlock() onlyOwner returns (bool success)  {
        transferlocked = true;
        return true;
    }
}