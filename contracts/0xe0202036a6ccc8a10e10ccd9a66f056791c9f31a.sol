pragma solidity ^0.4.18;

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

/**
 * @title ERC20Basic
 * @dev Simpler version of ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/179
 */
contract ERC20Basic {
  uint256 public totalSupply;
  function balanceOf(address who) public view returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}

/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender) public view returns (uint256);
  function transferFrom(address from, address to, uint256 value) public returns (bool);
  function approve(address spender, uint256 value) public returns (bool);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}

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
    require(_value <= balances[msg.sender]);

    // SafeMath.sub will throw if there is not enough balance.
    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);
    emit Transfer(msg.sender, _to, _value);
    return true;
  }

  /**
  * @dev Gets the balance of the specified address.
  * @param _owner The address to query the the balance of.
  * @return An uint256 representing the amount owned by the passed address.
  */
  function balanceOf(address _owner) public view returns (uint256 balance) {
    return balances[_owner];
  }

}

/**
 * @title Standard ERC20 token
 *
 * @dev Implementation of the basic standard token.
 * @dev https://github.com/ethereum/EIPs/issues/20
 * @dev Based on code by FirstBlood: https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol
 */
contract StandardToken is ERC20, BasicToken {

  mapping (address => mapping (address => uint256)) internal allowed;


  /**
   * @dev Transfer tokens from one address to another
   * @param _from address The address which you want to send tokens from
   * @param _to address The address which you want to transfer to
   * @param _value uint256 the amount of tokens to be transferred
   */
  function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));
    require(_value <= balances[_from]);
    require(_value <= allowed[_from][msg.sender]);

    balances[_from] = balances[_from].sub(_value);
    balances[_to] = balances[_to].add(_value);
    allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
    emit Transfer(_from, _to, _value);
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
    emit Approval(msg.sender, _spender, _value);
    return true;
  }

  /**
   * @dev Function to check the amount of tokens that an owner allowed to a spender.
   * @param _owner address The address which owns the funds.
   * @param _spender address The address which will spend the funds.
   * @return A uint256 specifying the amount of tokens still available for the spender.
   */
  function allowance(address _owner, address _spender) public view returns (uint256) {
    return allowed[_owner][_spender];
  }

  /**
   * approve should be called when allowed[_spender] == 0. To increment
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   */
  function increaseApproval(address _spender, uint _addedValue) public returns (bool) {
    allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

  function decreaseApproval(address _spender, uint _subtractedValue) public returns (bool) {
    uint oldValue = allowed[msg.sender][_spender];
    if (_subtractedValue > oldValue) {
      allowed[msg.sender][_spender] = 0;
    } else {
      allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
    }
    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

}

contract DesignerChain is StandardToken {
    using SafeMath for uint256;
    string public name = "Designer Chain";
    string public symbol = "DC";
    uint public decimals = 6;

    address public saleAddress = 0x99b3bf93150E05900CF433FD61e932fE025E6869;
    uint256 public saleAmount = 3000000000 * (10 ** decimals); 
    address public socialAddress = 0x8897fd8334c4b43307a7D781792EbFC6434E8AB6;
    uint256 public socialAmount = 2500000000 * (10 ** decimals); 
    address public operAddress = 0x980D864E9931d6Ee47214522f0a9CFFD100Fc8a0;
    uint256 public operAmount = 1500000000 * (10 ** decimals); 
    address public fundAddress = 0x2FA7bE982cee1d8D44b0db1d0AE177C88E545b08;
    uint256 public fundAmount = 1000000000 * (10 ** decimals); 
    address public teamAddress1 = 0x3240c16b67CB30f530DC2b0192e7647BE9d7E3fD;
    uint256 public teamAmount1 = 711000000 * (10 ** decimals); 
    address public teamAddress2 = 0xB01031F10240D6c98954e187320918230369e5A8;
    uint256 public teamAmount2 = 333000000 * (10 ** decimals); 
    address public teamAddress3 = 0xC601493e335BdC36b736D69f7CD0ef9586dD59a0;
    uint256 public teamAmount3 = 300000000 * (10 ** decimals); 
    address public teamAddress4 = 0x62C1eC256B7bb10AA53FD4208454E1BFD533b7f0;
    uint256 public teamAmount4 = 300000000 * (10 ** decimals); 
    address public teamAddress5 = 0xfE7678004882AD8b00ddBbBA677a16F7361E4c06;
    uint256 public teamAmount5 = 50000000 * (10 ** decimals); 
    address public teamAddress6 = 0xB9c514062C41d290b6567fB64895A48472689eEB;
    uint256 public teamAmount6 = 211000000 * (10 ** decimals);
    address public teamAddress7 = 0x142758621031aDA83C16F877720Cddc0c4129D99;
    uint256 public teamAmount7 = 89000000 * (10 ** decimals); 
    address public teamAddress8 = 0x2036aB5dEBdba6755041316DbF9a3c7852Ed8152;
    uint256 public teamAmount8 = 1000000 * (10 ** decimals); 
    address public teamAddress9 = 0x756CB9C1024B783041aBB894c33eD997556575C3;
    uint256 public teamAmount9 = 1000000 * (10 ** decimals); 
    address public teamAddress10 = 0xeB3611Ab4280D75f32129Cc79d05fc9C8352593F;
    uint256 public teamAmount10 = 1000000 * (10 ** decimals); 
    address public teamAddress11 = 0xd24F5A7dB60DbbE9ca3b48Ed9f337B0C0aD5C589;
    uint256 public teamAmount11 = 1000000 * (10 ** decimals); 
    address public teamAddress12 = 0x45f6c4Ee1a045DF316eDc446EE1a10A8820A7554;
    uint256 public teamAmount12 = 1000000 * (10 ** decimals); 
    address public teamAddress13 = 0x47Cec1725C5732A37e8809a0ca9F00E04783AB0F;
    uint256 public teamAmount13 = 1000000 * (10 ** decimals); 

    function DesignerChain() public {
        balances[saleAddress] = saleAmount;
        emit Transfer(address(0), saleAddress, saleAmount);

        balances[socialAddress] = socialAmount;
        emit Transfer(address(0), socialAddress, socialAmount);

        balances[operAddress] = operAmount;
        emit Transfer(address(0), operAddress, operAmount);

        balances[fundAddress] = fundAmount;
        emit Transfer(address(0), fundAddress, fundAmount);

        balances[teamAddress1] = teamAmount1;
        emit Transfer(address(0), teamAddress1, teamAmount1); 

        balances[teamAddress2] = teamAmount2;
        emit Transfer(address(0), teamAddress2, teamAmount2); 

        balances[teamAddress3] = teamAmount3;
        emit Transfer(address(0), teamAddress3, teamAmount3); 

        balances[teamAddress4] = teamAmount4;
        emit Transfer(address(0), teamAddress4, teamAmount4); 

        balances[teamAddress5] = teamAmount5;
        emit Transfer(address(0), teamAddress5, teamAmount5); 

        balances[teamAddress6] = teamAmount6;
        emit Transfer(address(0), teamAddress6, teamAmount6); 

        balances[teamAddress7] = teamAmount7;
        emit Transfer(address(0), teamAddress7, teamAmount7); 

        balances[teamAddress8] = teamAmount8;
        emit Transfer(address(0), teamAddress8, teamAmount8); 

        balances[teamAddress9] = teamAmount9;
        emit Transfer(address(0), teamAddress9, teamAmount9); 

        balances[teamAddress10] = teamAmount10;
        emit Transfer(address(0), teamAddress10, teamAmount10); 

        balances[teamAddress11] = teamAmount11;
        emit Transfer(address(0), teamAddress11, teamAmount11); 

        balances[teamAddress12] = teamAmount12;
        emit Transfer(address(0), teamAddress12, teamAmount12); 

        balances[teamAddress13] = teamAmount13;
        emit Transfer(address(0), teamAddress13, teamAmount13); 

        totalSupply = 10000000000 * (10 ** decimals);  //总共发行100亿
    }
}