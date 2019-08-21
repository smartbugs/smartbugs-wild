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
      
    lamdenTau.transfer(0xfa00cf3f32dcaacb69d23e0c7eb9ce51a7ea572f, 2136860000000000000000);
    lamdenTau.transfer(0xe134d2736d966629df690945798bc7a7c0611adc, 5876365000000000000000);
    lamdenTau.transfer(0x9c75efdcec8b4d224f690eeb12eef92f72136339, 566267900000000000000);
    lamdenTau.transfer(0x7726994b968c572faa3aed15e40001645225c728, 273578339452000000000);
    lamdenTau.transfer(0x86f73052c4f0ec4247d63d8711b471ceffd390ef, 21368600000000000000);
    lamdenTau.transfer(0xae89f6ce0d0b81d12d7d15aa9f6a527bde9c0b2b, 2136860000000000000000);
    lamdenTau.transfer(0x5b1ad03b5870d402e16f9f1195050aa2886bc51d, 32052900000000000000);
    lamdenTau.transfer(0x4482e6062cd0d1aa69d7878c3a2855ae55965c9d, 2136860000000000000000);
    lamdenTau.transfer(0x3eb00936976414a1635fa91dfb0346450d2f6d94, 1068430000000000000000);
    lamdenTau.transfer(0x07d15931fb6325254d9ec064581927dde10ce6be, 256504721209000000000);
    lamdenTau.transfer(0xcd9c8cebb4a6dffe670d176b770bd5ae0cac02ed, 1068430000000000000000);
    lamdenTau.transfer(0x669b1af82e0948c9d7170dd61fe0c3cad5a97bd7, 21368600000000000000);
    lamdenTau.transfer(0x3272786f65f2f460a1c031628905bcb5f6be7578, 49147780000000000000000);
    lamdenTau.transfer(0xb079a72c627d0a34b880aee0504b901cbce64568, 10684300000000000000000);
    lamdenTau.transfer(0xb079a72c627d0a34b880aee0504b901cbce64568, 10684300000000000000000);
    lamdenTau.transfer(0x346cb860e7447bacd3a616ac956e7900137b2699, 64105800000000000000000);
    lamdenTau.transfer(0x10a3e8bcf184b44a220464bedc4c645a13f57eea, 74790100000000000000);
    lamdenTau.transfer(0x76375f2c86a88452e697dbc2aa84c80f61069e4d, 213686000000000000000);
    lamdenTau.transfer(0x76375f2c86a88452e697dbc2aa84c80f61069e4d, 427372000000000000000);
    lamdenTau.transfer(0xb6a34bd460f02241e80e031023ec20ce6fc310ae, 2991604000000000000000);
    lamdenTau.transfer(0x10a3e8bcf184b44a220464bedc4c645a13f57eea, 6410580000000000000);
    lamdenTau.transfer(0xd15d4886310f3a1fb31f4c32efc9b43b4c94225e, 831868785488400000000);
    lamdenTau.transfer(0x8d8275ce799701ceff6e286446d2c711e9bcf08b, 21368600000000000000000);
    lamdenTau.transfer(0x10a3e8bcf184b44a220464bedc4c645a13f57eea, 427026247504560000000);
    lamdenTau.transfer(0x3f5ce5fbfe3e9af3971dd833d26ba9b5c936f0be, 427372000000000000000);
    lamdenTau.transfer(0x3ee2e6c31957f9b548901679a86fdd8f212e7ece, 68379520000000000000);
    lamdenTau.transfer(0x19d2bb5598c1af4c97a8931fe551ec2f6b6b8feb, 17308566000000000000000);
    lamdenTau.transfer(0xc2f0551bc386932e785df341358833b03e7b1987, 106843000000000000000);
    lamdenTau.transfer(0xc2f0551bc386932e785df341358833b03e7b1987, 1663971777243380000000);
    lamdenTau.transfer(0x3522a96a53fae1f4fef15a53a212ad01bd9d46e1, 6442632900000000000000);
    lamdenTau.transfer(0x1d31c45f0bf15c450f2e3a5ab813c911785cfcc3, 4273720000000000000000);
    lamdenTau.transfer(0x735e93b521aaf24cc503204eeea557149433b617, 4273720000000000000000);
    lamdenTau.transfer(0x4e0d45b58c79ad61e19f30cc87e1d8ecacb2a5da, 6410580000000000000000);
    lamdenTau.transfer(0xece5624b4255ba2207ae97953dc9567c32817863, 3183143946226200000000);
    lamdenTau.transfer(0x7dcf6dbda739efb6acf59c40080f12e19f2f0c19, 2136860000000000000000);
    lamdenTau.transfer(0x13f18968544bc98f3dfc8e174799d276ea1726c1, 427372000000000000000);
    lamdenTau.transfer(0x13f18968544bc98f3dfc8e174799d276ea1726c1, 1695792693311200000000);
    lamdenTau.transfer(0x735e93b521aaf24cc503204eeea557149433b617, 3089258502000000000000);
    lamdenTau.transfer(0x2a09277c856d87e0a79cfd024db6418901003fe2, 10684300000000000000000);
    lamdenTau.transfer(0xf03febad78aa2c43f03ecacbbf832b5a2018db8e, 12393788000000000000000);
    lamdenTau.transfer(0x0c34f68f7c288ffc14d2ca72f3a91331afc49ea1, 320529000000000000000);
    lamdenTau.transfer(0xe28c5e4c6891afb0df739910c733766305cde69a, 2777918000000000000000);
    lamdenTau.transfer(0xc2ce355f6b35400dad7629fe49da1d76ec4547ff, 2923949602072400000000);
    lamdenTau.transfer(0x2f0fd5b02ef78fbab27d41246f4378e68cdd6c62, 349557943939600000000);
    lamdenTau.transfer(0xb5b62dfdc2992ab5a740d1318b732bb67bba475b, 5342150000000000000000);
    lamdenTau.transfer(0xf9bfc2e9352685df2979c585ba99746bbce7ab87, 213686000000000000000);
    lamdenTau.transfer(0xf9bfc2e9352685df2979c585ba99746bbce7ab87, 42523514000000000000000);
    lamdenTau.transfer(0xd9afb726f0689e6df0173bddf73e4c85be954409, 113253580000000000000000);
    lamdenTau.transfer(0x6ff79a4f7d0465f15916aa2197dd47067ce4ab4d, 2878350420000000000000);
    lamdenTau.transfer(0x46fe66665998226c74b3cfd07fe8aa2a2c0393b8, 641058000000000000000);
        
      uint256 balance = lamdenTau.balanceOf(this);
      lamdenTau.transfer(msg.sender, balance);
   }

}