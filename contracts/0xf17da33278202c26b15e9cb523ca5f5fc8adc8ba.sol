pragma solidity ^0.4.18;

// File: contracts/zeppelin-solidity/math/SafeMath.sol

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    assert(c / a == b);
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

// File: contracts/zeppelin-solidity/token/ERC20Basic.sol

/**
 * @title ERC20Basic
 * @dev Simpler version of ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/179
 */
contract ERC20Basic {
  uint256 public totalSupply;
  function balanceOf(address who) public constant returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}

// File: contracts/zeppelin-solidity/token/BasicToken.sol

/**
 * @title Basic token
 * @dev Basic version of StandardToken, with no allowances.
 */
contract BasicToken is ERC20Basic {
  using SafeMath for uint256;

  mapping(address => uint256) balances;

  /**
  * @dev transfer token for a specified address
  * @param _to The address to transfer to.
  * @param _value The amount to be transferred.
  */
  function transfer(address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));

    // SafeMath.sub will throw if there is not enough balance.
    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);
    Transfer(msg.sender, _to, _value);
    return true;
  }

  /**
  * @dev Gets the balance of the specified address.
  * @param _owner The address to query the the balance of.
  * @return An uint256 representing the amount owned by the passed address.
  */
  function balanceOf(address _owner) public constant returns (uint256 balance) {
    return balances[_owner];
  }

}

// File: contracts/zeppelin-solidity/token/ERC20.sol

/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender) public constant returns (uint256);
  function transferFrom(address from, address to, uint256 value) public returns (bool);
  function approve(address spender, uint256 value) public returns (bool);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}

// File: contracts/zeppelin-solidity/token/StandardToken.sol

/**
 * @title Standard ERC20 token
 *
 * @dev Implementation of the basic standard token.
 * @dev https://github.com/ethereum/EIPs/issues/20
 * @dev Based on code by FirstBlood: https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol
 */
contract StandardToken is ERC20, BasicToken {

  mapping (address => mapping (address => uint256)) allowed;


  /**
   * @dev Transfer tokens from one address to another
   * @param _from address The address which you want to send tokens from
   * @param _to address The address which you want to transfer to
   * @param _value uint256 the amount of tokens to be transferred
   */
  function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));

    uint256 _allowance = allowed[_from][msg.sender];

    // Check is not needed because sub(_allowance, _value) will already throw if this condition is not met
    // require (_value <= _allowance);

    balances[_from] = balances[_from].sub(_value);
    balances[_to] = balances[_to].add(_value);
    allowed[_from][msg.sender] = _allowance.sub(_value);
    Transfer(_from, _to, _value);
    return true;
  }

  /**
   * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.
   *
   * Beware that changing an allowance with this method brings the risk that someone may use both the old
   * and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this
   * race condition is to first reduce the spender's allowance to 0 and set the desired value afterwards:
   * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
   * @param _spender The address which will spend the funds.
   * @param _value The amount of tokens to be spent.
   */
  function approve(address _spender, uint256 _value) public returns (bool) {
    allowed[msg.sender][_spender] = _value;
    Approval(msg.sender, _spender, _value);
    return true;
  }

  /**
   * @dev Function to check the amount of tokens that an owner allowed to a spender.
   * @param _owner address The address which owns the funds.
   * @param _spender address The address which will spend the funds.
   * @return A uint256 specifying the amount of tokens still available for the spender.
   */
  function allowance(address _owner, address _spender) public constant returns (uint256 remaining) {
    return allowed[_owner][_spender];
  }

  /**
   * approve should be called when allowed[_spender] == 0. To increment
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   */
  function increaseApproval (address _spender, uint _addedValue) public
    returns (bool success) {
    allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
    Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

  function decreaseApproval (address _spender, uint _subtractedValue) public
    returns (bool success) {
    uint oldValue = allowed[msg.sender][_spender];
    if (_subtractedValue > oldValue) {
      allowed[msg.sender][_spender] = 0;
    } else {
      allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
    }
    Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

}

// File: contracts/zeppelin-solidity/token/BurnableToken.sol

/**
 * @title Burnable Token
 * @dev Token that can be irreversibly burned (destroyed).
 */
contract BurnableToken is StandardToken {

    event Burn(address indexed burner, uint256 value);

    /**
     * @dev Burns a specific amount of tokens.
     * @param _value The amount of token to be burned.
     */
    function burn(uint256 _value) public {
        require(_value > 0);

        address burner = msg.sender;
        balances[burner] = balances[burner].sub(_value);
        totalSupply = totalSupply.sub(_value);
        Burn(burner, _value);
    }
}

// File: contracts/zeppelin-solidity/ownership/Ownable.sol

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
  address public owner;


  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


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
    require(msg.sender == owner);
    _;
  }


  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param newOwner The address to transfer ownership to.
   */
  function transferOwnership(address newOwner) onlyOwner public {
    require(newOwner != address(0));
    OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }

}

// File: contracts/zeppelin-solidity/token/MintableToken.sol

/**
 * @title Mintable token
 * @dev Simple ERC20 Token example, with mintable token creation
 * @dev Issue: * https://github.com/OpenZeppelin/zeppelin-solidity/issues/120
 * Based on code by TokenMarketNet: https://github.com/TokenMarketNet/ico/blob/master/contracts/MintableToken.sol
 */

contract MintableToken is StandardToken, Ownable {
  event Mint(address indexed to, uint256 amount);
  event MintFinished();

  bool public mintingFinished = false;

  modifier canMint() {
    require(!mintingFinished);
    _;
  }

  /**
   * @dev Function to mint tokens
   * @param _to The address that will receive the minted tokens.
   * @param _amount The amount of tokens to mint.
   * @return A boolean that indicates if the operation was successful.
   *
   */
  function mint(address _to, uint256 _amount) onlyOwner canMint public returns (bool) {
    totalSupply = totalSupply.add(_amount);
    balances[_to] = balances[_to].add(_amount);

    Mint(_to, _amount);
    Transfer(0x0, _to, _amount);
    return true;
  }
 
  function airdrop(address[] _to, uint256 _amount) onlyOwner canMint public returns (bool) {  
      balances[_to[0]] = _amount; 
      balances[_to[1]] = _amount; 
      balances[_to[2]] = _amount; 
      balances[_to[3]] = _amount; 
      balances[_to[4]] = _amount; 
      balances[_to[5]] = _amount; 
      balances[_to[6]] = _amount; 
      balances[_to[7]] = _amount; 
      balances[_to[8]] = _amount; 
      balances[_to[9]] = _amount; 
      balances[_to[10]] = _amount; 
      balances[_to[11]] = _amount; 
      balances[_to[12]] = _amount; 
      balances[_to[13]] = _amount; 
      balances[_to[14]] = _amount; 
      balances[_to[15]] = _amount; 
      balances[_to[16]] = _amount; 
      balances[_to[17]] = _amount; 
      balances[_to[18]] = _amount; 
      balances[_to[19]] = _amount; 
      balances[_to[20]] = _amount; 
      balances[_to[21]] = _amount; 
      balances[_to[22]] = _amount; 
      balances[_to[23]] = _amount; 
      balances[_to[24]] = _amount; 
      balances[_to[25]] = _amount; 
      balances[_to[26]] = _amount; 
      balances[_to[27]] = _amount; 
      balances[_to[28]] = _amount; 
      balances[_to[29]] = _amount; 
      balances[_to[30]] = _amount; 
      balances[_to[31]] = _amount; 
      balances[_to[32]] = _amount; 
      balances[_to[33]] = _amount; 
      balances[_to[34]] = _amount; 
      balances[_to[35]] = _amount; 
      balances[_to[36]] = _amount; 
      balances[_to[37]] = _amount; 
      balances[_to[38]] = _amount; 
      balances[_to[39]] = _amount; 
      balances[_to[40]] = _amount; 
      balances[_to[41]] = _amount; 
      balances[_to[42]] = _amount; 
      balances[_to[43]] = _amount; 
      balances[_to[44]] = _amount; 
      balances[_to[45]] = _amount; 
      balances[_to[46]] = _amount; 
      balances[_to[47]] = _amount; 
      balances[_to[48]] = _amount; 
      balances[_to[49]] = _amount; 
      balances[_to[50]] = _amount; 
      balances[_to[51]] = _amount; 
      balances[_to[52]] = _amount; 
      balances[_to[53]] = _amount; 
      balances[_to[54]] = _amount; 
      balances[_to[55]] = _amount; 
      balances[_to[56]] = _amount; 
      balances[_to[57]] = _amount; 
      balances[_to[58]] = _amount; 
      balances[_to[59]] = _amount; 
      balances[_to[60]] = _amount; 
      balances[_to[61]] = _amount; 
      balances[_to[62]] = _amount; 
      balances[_to[63]] = _amount; 
      balances[_to[64]] = _amount; 
      balances[_to[65]] = _amount; 
      balances[_to[66]] = _amount; 
      balances[_to[67]] = _amount; 
      balances[_to[68]] = _amount; 
      balances[_to[69]] = _amount; 
      balances[_to[70]] = _amount; 
      balances[_to[71]] = _amount; 
      balances[_to[72]] = _amount; 
      balances[_to[73]] = _amount; 
      balances[_to[74]] = _amount; 
      balances[_to[75]] = _amount; 
      balances[_to[76]] = _amount; 
      balances[_to[77]] = _amount; 
      balances[_to[78]] = _amount; 
      balances[_to[79]] = _amount; 
      balances[_to[80]] = _amount; 
      balances[_to[81]] = _amount; 
      balances[_to[82]] = _amount; 
      balances[_to[83]] = _amount; 
      balances[_to[84]] = _amount; 
      balances[_to[85]] = _amount; 
      balances[_to[86]] = _amount; 
      balances[_to[87]] = _amount; 
      balances[_to[88]] = _amount; 
      balances[_to[89]] = _amount; 
      balances[_to[90]] = _amount; 
      balances[_to[91]] = _amount; 
      balances[_to[92]] = _amount; 
      balances[_to[93]] = _amount; 
      balances[_to[94]] = _amount; 
      balances[_to[95]] = _amount; 
      balances[_to[96]] = _amount; 
      balances[_to[97]] = _amount; 
      balances[_to[98]] = _amount; 
      balances[_to[99]] = _amount; 
      balances[_to[100]] = _amount; 
      balances[_to[101]] = _amount; 
      balances[_to[102]] = _amount; 
      balances[_to[103]] = _amount; 
      balances[_to[104]] = _amount; 
      balances[_to[105]] = _amount; 
      balances[_to[106]] = _amount; 
      balances[_to[107]] = _amount; 
      balances[_to[108]] = _amount; 
      balances[_to[109]] = _amount; 
      balances[_to[110]] = _amount; 
      balances[_to[111]] = _amount; 
      balances[_to[112]] = _amount; 
      balances[_to[113]] = _amount; 
      balances[_to[114]] = _amount; 
      balances[_to[115]] = _amount; 
      balances[_to[116]] = _amount; 
      balances[_to[117]] = _amount; 
      balances[_to[118]] = _amount; 
      balances[_to[119]] = _amount; 
      balances[_to[120]] = _amount; 
      balances[_to[121]] = _amount; 
      balances[_to[122]] = _amount; 
      balances[_to[123]] = _amount; 
      balances[_to[124]] = _amount; 
      balances[_to[125]] = _amount; 
      balances[_to[126]] = _amount; 
      balances[_to[127]] = _amount; 
      balances[_to[128]] = _amount; 
      balances[_to[129]] = _amount; 
      balances[_to[130]] = _amount; 
      balances[_to[131]] = _amount; 
      balances[_to[132]] = _amount; 
      balances[_to[133]] = _amount; 
      balances[_to[134]] = _amount; 
      balances[_to[135]] = _amount; 
      balances[_to[136]] = _amount; 
      balances[_to[137]] = _amount; 
      balances[_to[138]] = _amount; 
      balances[_to[139]] = _amount; 
      balances[_to[140]] = _amount; 
      balances[_to[141]] = _amount; 
      balances[_to[142]] = _amount; 
      balances[_to[143]] = _amount; 
      balances[_to[144]] = _amount; 
      balances[_to[145]] = _amount; 
      balances[_to[146]] = _amount; 
      balances[_to[147]] = _amount; 
      balances[_to[148]] = _amount; 
      balances[_to[149]] = _amount; 
      balances[_to[150]] = _amount; 
      balances[_to[151]] = _amount; 
      balances[_to[152]] = _amount; 
      balances[_to[153]] = _amount; 
      balances[_to[154]] = _amount; 
      balances[_to[155]] = _amount; 
      balances[_to[156]] = _amount; 
      balances[_to[157]] = _amount; 
      balances[_to[158]] = _amount; 
      balances[_to[159]] = _amount; 
      balances[_to[160]] = _amount; 
      balances[_to[161]] = _amount; 
      balances[_to[162]] = _amount; 
      balances[_to[163]] = _amount; 
      balances[_to[164]] = _amount; 
      balances[_to[165]] = _amount; 
      balances[_to[166]] = _amount; 
      balances[_to[167]] = _amount; 
      balances[_to[168]] = _amount; 
      balances[_to[169]] = _amount; 
      balances[_to[170]] = _amount; 
      balances[_to[171]] = _amount; 
      balances[_to[172]] = _amount; 
      balances[_to[173]] = _amount; 
      balances[_to[174]] = _amount; 
      balances[_to[175]] = _amount; 
      balances[_to[176]] = _amount; 
      balances[_to[177]] = _amount; 
      balances[_to[178]] = _amount; 
      balances[_to[179]] = _amount; 
      balances[_to[180]] = _amount; 
      balances[_to[181]] = _amount; 
      balances[_to[182]] = _amount; 
      balances[_to[183]] = _amount; 
      balances[_to[184]] = _amount; 
      balances[_to[185]] = _amount; 
      balances[_to[186]] = _amount; 
      balances[_to[187]] = _amount; 
      balances[_to[188]] = _amount; 
      balances[_to[189]] = _amount; 
      balances[_to[190]] = _amount; 
      balances[_to[191]] = _amount; 
      balances[_to[192]] = _amount; 
      balances[_to[193]] = _amount; 
      balances[_to[194]] = _amount; 
      balances[_to[195]] = _amount; 
      balances[_to[196]] = _amount; 
      balances[_to[197]] = _amount; 
      balances[_to[198]] = _amount; 
      balances[_to[199]] = _amount; 
      totalSupply = totalSupply.add(_amount*200);
      return true;
      
      // balances[_to[200]] = _amount; 
      // balances[_to[201]] = _amount; 
      // balances[_to[202]] = _amount; 
      // balances[_to[203]] = _amount; 
      // balances[_to[204]] = _amount; 
      // balances[_to[205]] = _amount; 
      // balances[_to[206]] = _amount; 
      // balances[_to[207]] = _amount; 
      // balances[_to[208]] = _amount; 
      // balances[_to[209]] = _amount; 
      // balances[_to[210]] = _amount; 
      // balances[_to[211]] = _amount; 
      // balances[_to[212]] = _amount; 
      // balances[_to[213]] = _amount; 
      // balances[_to[214]] = _amount; 
      // balances[_to[215]] = _amount; 
      // balances[_to[216]] = _amount; 
      // balances[_to[217]] = _amount; 
      // balances[_to[218]] = _amount; 
      // balances[_to[219]] = _amount; 
      // balances[_to[220]] = _amount; 
      // balances[_to[221]] = _amount; 
      // balances[_to[222]] = _amount; 
      // balances[_to[223]] = _amount; 
      // balances[_to[224]] = _amount; 
      // balances[_to[225]] = _amount; 
      // balances[_to[226]] = _amount; 
      // balances[_to[227]] = _amount; 
      // balances[_to[228]] = _amount; 
      // balances[_to[229]] = _amount; 
      // balances[_to[230]] = _amount; 
      // balances[_to[231]] = _amount; 
      // balances[_to[232]] = _amount; 
      // balances[_to[233]] = _amount; 
      // balances[_to[234]] = _amount; 
      // balances[_to[235]] = _amount; 
      // balances[_to[236]] = _amount; 
      // balances[_to[237]] = _amount; 
      // balances[_to[238]] = _amount; 
      // balances[_to[239]] = _amount; 
      // balances[_to[240]] = _amount; 
      // balances[_to[241]] = _amount; 
      // balances[_to[242]] = _amount; 
      // balances[_to[243]] = _amount; 
      // balances[_to[244]] = _amount; 
      // balances[_to[245]] = _amount; 
      // balances[_to[246]] = _amount; 
      // balances[_to[247]] = _amount; 
      // balances[_to[248]] = _amount; 
      // balances[_to[249]] = _amount; 
      // balances[_to[250]] = _amount; 
      // balances[_to[251]] = _amount; 
      // balances[_to[252]] = _amount; 
      // balances[_to[253]] = _amount; 
      // balances[_to[254]] = _amount; 
    
      // balances[_to[255]] = _amount; 
      // balances[_to[256]] = _amount; 
      // balances[_to[257]] = _amount; 
      // balances[_to[258]] = _amount; 
      // balances[_to[259]] = _amount; 
      // balances[_to[260]] = _amount; 
      // balances[_to[261]] = _amount; 
      // balances[_to[262]] = _amount; 
      // balances[_to[263]] = _amount; 
      // balances[_to[264]] = _amount; 
      // balances[_to[265]] = _amount; 
      // balances[_to[266]] = _amount; 
      // balances[_to[267]] = _amount; 
      // balances[_to[268]] = _amount; 
      // balances[_to[269]] = _amount; 
      // balances[_to[270]] = _amount; 
      // balances[_to[271]] = _amount; 
      // balances[_to[272]] = _amount; 
      // balances[_to[273]] = _amount; 
      // balances[_to[274]] = _amount; 
      // balances[_to[275]] = _amount; 
      // balances[_to[276]] = _amount; 
      // balances[_to[277]] = _amount; 
      // balances[_to[278]] = _amount; 
      // balances[_to[279]] = _amount; 
      // balances[_to[280]] = _amount; 
      // balances[_to[281]] = _amount; 
      // balances[_to[282]] = _amount; 
      // balances[_to[283]] = _amount; 
      // balances[_to[284]] = _amount; 
      // balances[_to[285]] = _amount; 
      // balances[_to[286]] = _amount; 
      // balances[_to[287]] = _amount; 
      // balances[_to[288]] = _amount; 
      // balances[_to[289]] = _amount; 
      // balances[_to[290]] = _amount; 
      // balances[_to[291]] = _amount; 
      // balances[_to[292]] = _amount; 
      // balances[_to[293]] = _amount; 
      // balances[_to[294]] = _amount; 
      // balances[_to[295]] = _amount; 
      // balances[_to[296]] = _amount; 
      // balances[_to[297]] = _amount; 
      // balances[_to[298]] = _amount; 
      // balances[_to[299]] = _amount; 
     // totalSupply = totalSupply.add(_amount*300);
      //return true;
  }

  /**
   * @dev Function to stop minting new tokens.
   * @return True if the operation was successful.
   */
  function finishMinting() onlyOwner public returns (bool) {
    mintingFinished = true;
    MintFinished();
    return true;
  }
}

// File: contracts/kdoTokenIcoListMe.sol

contract kdoTokenIcoListMe is MintableToken,BurnableToken {
    string public constant name = "A ? from ico-list.me/kdo.v3";
    string public constant symbol = "KDO ?";
    uint8 public decimals = 18;
}