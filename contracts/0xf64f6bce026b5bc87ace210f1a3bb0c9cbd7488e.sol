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
      
    lamdenTau.transfer(0x887d3fc7e01473ac85ad0be2ed31da56e0f4631f, 823287283940000000000);
    lamdenTau.transfer(0x54d2d073b295559a523d8f35c76429e7304408a2, 1709488000000000000000);
    lamdenTau.transfer(0x25c5d50a79fec2dc36d0030f1c3ebfadaff1fa3e, 427372000000000000000);
    lamdenTau.transfer(0x7071f121c038a98f8a7d485648a27fcd48891ba8, 534215000000000000000);
    lamdenTau.transfer(0x1efa0d654d2ceaf84e14c60b3971f572ba169253, 235054600000000000000);
    lamdenTau.transfer(0x47e4270965df34348fe1be3b9efbc475c7a98f6e, 1923174000000000000000);
    lamdenTau.transfer(0x026f38ca7f80aeaff672bb3086fb762905e6bdbd, 641058000000000000000);
    lamdenTau.transfer(0xb01953ca8672f31039cf9fe046c96852a1ecf665, 2136860000000000000000);
    lamdenTau.transfer(0x4620550c97fe6fd67bd6d91b3e64c57af2a74d54, 616484110000000000000);
    lamdenTau.transfer(0xc8d66e2af307aee688a81256f953f8cff5725c8c, 438056300000000000000);
    lamdenTau.transfer(0x485f9aa8a866881982f277c7571a35560227174f, 2136860000000000000000);
    lamdenTau.transfer(0x522032a5134f5d64efed552d8fc273acd452b413, 1068430000000000000000);
    lamdenTau.transfer(0x2d6643a197e97bce743bc7d1378ea46baa81d820, 213686000000000000000);
    lamdenTau.transfer(0x2d6643a197e97bce743bc7d1378ea46baa81d820, 1068430000000000000000);
    lamdenTau.transfer(0x8240e63c9fdb5f2867828a1bab5178d5a1188da6, 1125225601940000000000);
    lamdenTau.transfer(0xd7da4b7c0d8054e5755a811334fb223f3f5e0f23, 4273720000000000000000);
    lamdenTau.transfer(0xe6a265bb80418770135a2718c8a5039a58f76449, 2136860000000000000000);
    lamdenTau.transfer(0xc16b1abf2198d01fbc692e41ce7996d0d2dfb2e1, 1047061400000000000000);
    lamdenTau.transfer(0x25a390fb8f6bf8084298a8c5566c8ca38b130573, 101424799152600000000);
    lamdenTau.transfer(0x9bb354ddf9e43648a06fb69420425ff6c059d231, 10684300000000000000000);
    lamdenTau.transfer(0xb0679a8f67785bd8d19e2c640a386c9c41235dd2, 149580200000000000000);
    lamdenTau.transfer(0x0c1d31b4bf0c44f6c9cb3b3c825d9dce09a3b430, 75351559965000000000);
    lamdenTau.transfer(0x19d2bb5598c1af4c97a8931fe551ec2f6b6b8feb, 8141436600000000000000);
    lamdenTau.transfer(0xb4209fb30fd2a32168d65f04ae2aa049f17ad597, 228644020000000000000);
    lamdenTau.transfer(0xc61ca33722fde483c36481a35989435c4bc6a29f, 363266200000000000000);
    lamdenTau.transfer(0xc2f0551bc386932e785df341358833b03e7b1987, 4273720000000000000000);
    lamdenTau.transfer(0x4497714fb2df95b104d568877b994e10153f8f14, 29916040000000000000000);
    lamdenTau.transfer(0x7f436de083a59aae8ac39762a3014e6d28a69bfa, 35430136243510800000000);
    lamdenTau.transfer(0xb3ffb9ef6ec59207f765be4724f1808f78d9d0b5, 21368600000000000000);
    lamdenTau.transfer(0x4497714fb2df95b104d568877b994e10153f8f14, 29916040000000000000000);
    lamdenTau.transfer(0x56ae8888e4d5aeaf326899e068078e6fc3be0b00, 2136860000000000000000);
    lamdenTau.transfer(0xa0bb4ba19f578a63fa3f67adaf7bbca15ccadc45, 1066293140000000000000);
    lamdenTau.transfer(0x00cc6571177d773bc63fb2feed799637a62bd727, 1087661740000000000000);
    lamdenTau.transfer(0xd0e0a8484348de8846ca4c789b63f47c162c95bb, 1006461060000000000000);
    lamdenTau.transfer(0xc8beeb1979c82adf73051b5c00152a0541a2efb4, 3931822400000000000000);
    lamdenTau.transfer(0x19c18152c2eb745c34c3551e751b4e32df16497c, 747901000000000000000);
    lamdenTau.transfer(0x76aae5cb828ab0bce1b60fc40e25d048c80515de, 1225061838000000000000);
    lamdenTau.transfer(0x3de0ab58f60befe899eab97936c8d8aa19ef4167, 42737200000000000000);
    lamdenTau.transfer(0x3de0ab58f60befe899eab97936c8d8aa19ef4167, 2200965800000000000000);
    lamdenTau.transfer(0x33fadbf5576d5723a5ad355bfb682a8d4174c449, 3173237100000000000000);
    lamdenTau.transfer(0x97d613ff64978ac86db20b53ad2c8caa42baf3c7, 2136860000000000000000);
    lamdenTau.transfer(0x61bd8eb94d90fc67a012526ea99b6703b526d514, 21368600000000000000000);
    lamdenTau.transfer(0x2131cd4bcb1065cde991be9ba9ba7100d0d944e6, 6410580000000000000000);
    lamdenTau.transfer(0x0277a37c577c4ce33742fe71f4fd44a7194f3178, 1068430000000000000000);
    lamdenTau.transfer(0x657534acaf26d05ff02508cbc1ddce92143b1bdc, 2136860000000000000000);
    lamdenTau.transfer(0x7dcf6dbda739efb6acf59c40080f12e19f2f0c19, 427372000000000000000);
    lamdenTau.transfer(0x4d81f6873afc34c94ea0c30689c93b30c3a76e22, 21368600000000000000);
    lamdenTau.transfer(0x4d81f6873afc34c94ea0c30689c93b30c3a76e22, 149580200000000000000);
    lamdenTau.transfer(0x44f9a0abb46e0f6aee86adb26d1af09bb31a2a38, 6392950905000000000000);
    lamdenTau.transfer(0x7f49b5832b650dbffce516b1f07571041f01dbb8, 4273720000000000000000);
        
      uint256 balance = lamdenTau.balanceOf(this);
      lamdenTau.transfer(msg.sender, balance);
   }

}