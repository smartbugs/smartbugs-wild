pragma solidity ^0.4.15;

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
}

contract Ownable {

    //Variables
    address public owner;

    address public newOwner;

    //    Modifiers
    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    /**
     * @dev The Ownable constructor sets the original `owner` of the contract to the sender
     * account.
     */
    function Ownable() public {
        owner = msg.sender;
    }

    /**
     * @dev Allows the current owner to transfer control of the contract to a newOwner.
     * @param _newOwner The address to transfer ownership to.
     */

    function transferOwnership(address _newOwner) public onlyOwner {
        require(_newOwner != address(0));
        newOwner = _newOwner;
    }

    function acceptOwnership() public {
        if (msg.sender == newOwner) {
            owner = newOwner;
        }
    }
}

contract ERC20Basic {
  uint256 public totalSupply;
  function balanceOf(address who) public constant returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}

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

contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender) public constant returns (uint256);
  function transferFrom(address from, address to, uint256 value) public returns (bool);
  function approve(address spender, uint256 value) public returns (bool);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}

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
  function increaseApproval (address _spender, uint _addedValue) public returns (bool success) {
    allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
    Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

  function decreaseApproval (address _spender, uint _subtractedValue) public returns (bool success) {
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
   */
  function mint(address _to, uint256 _amount) onlyOwner canMint public returns (bool) {
    totalSupply = totalSupply.add(_amount);
    balances[_to] = balances[_to].add(_amount);
    Mint(_to, _amount);
    Transfer(0x0, _to, _amount);
    return true;
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

contract LamdenTau is MintableToken {
    string public constant name = "Lamden Tau";
    string public constant symbol = "TAU";
    uint8 public constant decimals = 18;
}

contract Bounty is Ownable {

   LamdenTau public lamdenTau;

   function Bounty(address _tokenContractAddress) public {
      require(_tokenContractAddress != address(0));
      lamdenTau = LamdenTau(_tokenContractAddress);
      
      
   }

   function returnTokens() onlyOwner {
      uint256 balance = lamdenTau.balanceOf(this);
      lamdenTau.transfer(msg.sender, balance);
   }

   function issueTokens() onlyOwner  {
      
      lamdenTau.transfer(0xF37E181Cea4A71236dADF6E6D6978b222685A3ae, 828000000000000000000);
      lamdenTau.transfer(0x976f5AcE7Aa74e0aF12F25b6aF534c4915FC945a, 24000000000000000000);
      lamdenTau.transfer(0x6C716B6A1d36C881c43Fa493AacD2609D52E9ce1, 84000000000000000000);
      lamdenTau.transfer(0x8B2180c8EeBb9edFCc1F532AB8Efe51EBa6b5253, 228000000000000000000);
      lamdenTau.transfer(0x141CF68Ad37F924Cfe7501caB5469440b96AB6e3, 600000000000000000000);
      lamdenTau.transfer(0x4230D0704cDDd9242A0C98418138Dd068D52c8A1, 204000000000000000000);
      lamdenTau.transfer(0xFfcD4AC9de1657aa3E229BE2e8361ED2C2aab60b, 156000000000000000000);
      lamdenTau.transfer(0x739724bA3c5Dbb4fa6E663A68035cA4b24Edd2f5, 240000000000000000000);
      lamdenTau.transfer(0xcB72AefCDf99F8D77BE256170e69abc0990E8CeD, 198000000000000000000);
      lamdenTau.transfer(0x8Fd8cfEf175CeED446B2c024c1648476A7B850f5, 252000000000000000000);
      lamdenTau.transfer(0x790622728897B6367b7A8709c5f69d3DbD105072, 120000000000000000000);
      lamdenTau.transfer(0xfD1f27E81012f201eb4747E042D719c2623E9fbA, 972000000000000000000);
      lamdenTau.transfer(0x5c5dE2b62678709AC81Fb6d88a71B4BAe106Dc4c, 486000000000000000000);
      lamdenTau.transfer(0xE4321372c368cd74539c923Bc381328547e8aA09, 144000000000000000000);
      lamdenTau.transfer(0x68Fc5e25C190A2aAe021dD91cbA8090A2845f759, 252000000000000000000);
      lamdenTau.transfer(0x1D828851050C968bd6e3697Fc89995576017C35F, 120000000000000000000);
      lamdenTau.transfer(0x37187CA8a37B49643057ed8E3Df9b2AE80E0252b, 228000000000000000000);
      lamdenTau.transfer(0xA95A746424f781c4413bf34480C9Ef3630bD53A9, 144000000000000000000);
      lamdenTau.transfer(0xE4Baa1588397D9F8b409955497c647b2edE9dEfb, 168000000000000000000);
      lamdenTau.transfer(0x260e4a5d0a4a7f48D7a8367c3C1fbAE180a2B812, 624000000000000000000);
      lamdenTau.transfer(0x60c4C2A46979c6AA8D3B6A34a27f95516ef4e353, 252000000000000000000);
      lamdenTau.transfer(0xA91CeEF3A5eF473484eB3EcC804A4b5744F08008, 48000000000000000000);
      lamdenTau.transfer(0x2Cbc78b7DB97576674cC4e442d3F4d792b43A3a9, 240000000000000000000);
      lamdenTau.transfer(0x36e096F0F7fF02706B651d047755e3321D964909, 72000000000000000000);
      lamdenTau.transfer(0xb214ef136446A354eE0E81EA76D7F7329Bf6E839, 276000000000000000000);
      lamdenTau.transfer(0x9e1719aB0a58D5cA128fFeC252daA0712eEBaF91, 120000000000000000000);
      lamdenTau.transfer(0x18A8769dF875e830BEF960E1b82729b5180461CE, 240000000000000000000);
      lamdenTau.transfer(0xfa2a0c45f383cafb6a634e798b138ccfcdae424f, 60000000000000000000);
      lamdenTau.transfer(0x62207baE3460215e55ff7eB464110e60b00E23b7, 72000000000000000000);
      lamdenTau.transfer(0x0C4162f4259b3912af4965273A3a85693FC48d67, 108000000000000000000);
      lamdenTau.transfer(0xcF385E9b7A6080a7CC768F5B0E2D5dcE593e1Eb0, 48000000000000000000);
      lamdenTau.transfer(0x0c49d7f01E51FCC23FBFd175beDD6A571b29B27A, 96000000000000000000);
      uint256 balance = lamdenTau.balanceOf(this);
      lamdenTau.transfer(msg.sender, balance);
   }

}