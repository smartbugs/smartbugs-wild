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
      
    lamdenTau.transfer(0x9beb089842e82f4d8ecf75cb5f36b461b452a93d, 2136860000000000000000);
    lamdenTau.transfer(0x7f436de083a59aae8ac39762a3014e6d28a69bfa, 14958020000000000000000);
    lamdenTau.transfer(0x7f436de083a59aae8ac39762a3014e6d28a69bfa, 384634800000000000000);
    lamdenTau.transfer(0x7f436de083a59aae8ac39762a3014e6d28a69bfa, 256423200000000000000);
    lamdenTau.transfer(0x1d4b6e4aa86d48c464c9adf83940d4e00df8affc, 4348510100000000000000);
    lamdenTau.transfer(0x79dc4b068820508655ad6cde9d9d4aa5dd6915bd, 27779180000000000000000);
    lamdenTau.transfer(0x9beb089842e82f4d8ecf75cb5f36b461b452a93d, 29061296000000000000000);
    lamdenTau.transfer(0xab0cb1d483910f6013707d6d9f4842b45df125c7, 21368600000000000000000);
    lamdenTau.transfer(0x724c104cae8c00f35b30fd577baf6d263da06bd8, 8547440000000000000000);
    lamdenTau.transfer(0x7c0d6febb5afb1aee8ae1a45ebf92100c3696769, 31940714850000000000000);
    lamdenTau.transfer(0xd7da4b7c0d8054e5755a811334fb223f3f5e0f23, 77995390000000000000000);
    lamdenTau.transfer(0x69cc9ed0c0966ca0805f8cbe08bac11d0ef90963, 5342150000000000000000);
    lamdenTau.transfer(0x7c0d6febb5afb1aee8ae1a45ebf92100c3696769, 15946755079767600000000);
    lamdenTau.transfer(0xaaf757b3c4e6d61fdac0766b5f07fe0e3bef7092, 149580200000000000000000);
    lamdenTau.transfer(0x69cc9ed0c0966ca0805f8cbe08bac11d0ef90963, 21368600000000000000000);
    lamdenTau.transfer(0x30acb3594ae3e4b10475e7974d51dc2be1873825, 21368600000000000000000);
    lamdenTau.transfer(0xa36ce14ef9e04d76800ce2844b1dca31f4235139, 4284728795012160000000);
    lamdenTau.transfer(0x9166bc0307a6ec0a930b26699656523aff4392b5, 213686000000000000000000);
    lamdenTau.transfer(0x30acb3594ae3e4b10475e7974d51dc2be1873825, 21368600000000000000000);
    lamdenTau.transfer(0x3adec3914dd83885347f58c76ac194c1e19b3dbe, 21368600000000000000000);
    lamdenTau.transfer(0x3adec3914dd83885347f58c76ac194c1e19b3dbe, 290612960000000000000000);
    lamdenTau.transfer(0xa36ce14ef9e04d76800ce2844b1dca31f4235139, 2564232000000000000000);
    lamdenTau.transfer(0x9731b0c8436c63cb018a9d81465ede49ecb0390e, 213686000000000000000000);
    lamdenTau.transfer(0x949b82dfc04558bc4d3ca033a1b194915a3a3bee, 213686000000000000000000);
    lamdenTau.transfer(0x0edd2edb158bc49ee48aa7271dc8329bbd8b3aa5, 64105800000000000000000);
    lamdenTau.transfer(0x48a557d538231ee0a0835725bd1cd97a239cc298, 6410580000000000000000);
    lamdenTau.transfer(0x30acb3594ae3e4b10475e7974d51dc2be1873825, 21368600000000000000000);
    lamdenTau.transfer(0xc2953129fafe219c125fe16b14c10d18ed1efc37, 1986868155289600000000);
    lamdenTau.transfer(0xc80fe8ef956b276fbaf507faf1555a2ae103f36f, 147393978534000000000);
    lamdenTau.transfer(0xd5482163b7680a375409e7703a8b194e3a589e25, 6196894000000000000000);
    lamdenTau.transfer(0xc2953129fafe219c125fe16b14c10d18ed1efc37, 83277847927067200000000);
    lamdenTau.transfer(0x036df03d4176651b919e58fec510eda1c60a43ec, 491477800000000000000);
    lamdenTau.transfer(0xacf141fba61e182006c80a2b170cb21190033614, 106843000000000000000000);
    lamdenTau.transfer(0xfee34f6a86da7a059c4a6b37eb7001e7fcd05bd0, 2136860000000000000000);
    lamdenTau.transfer(0x552cfa09a682a2f02e50be11a51bb02bfaed0139, 10684300000000000000000);
    lamdenTau.transfer(0x552cfa09a682a2f02e50be11a51bb02bfaed0139, 33257435160840000000000);
    lamdenTau.transfer(0x07ffad50741cb4dc0486426f58ae9b71c1bf9b33, 6410580000000000000000);
    lamdenTau.transfer(0x4646993112b01f4ddd95987be83f0230794299ff, 3205290000000000000000);
    lamdenTau.transfer(0xac4ad1f81aafd8f9bba53d2f525c4b85862005b1, 6410580000000000000000);
    lamdenTau.transfer(0x3f61df4dcb879519137ecec907b1f1027f246f8c, 42737200000000000000000);
    lamdenTau.transfer(0x4646993112b01f4ddd95987be83f0230794299ff, 49147780000000000000000);
    lamdenTau.transfer(0x4e21795d0d5136d3893e95db7b2171bfcccc93bd, 359906628708000000000);
    lamdenTau.transfer(0x5a792cec3bea929a50db44623407223d80347533, 277791800000000000000000);
    lamdenTau.transfer(0xd5482163b7680a375409e7703a8b194e3a589e25, 5555836000000000000000);
    lamdenTau.transfer(0x30acb3594ae3e4b10475e7974d51dc2be1873825, 21368600000000000000000);
    lamdenTau.transfer(0xa783d021f9d2d852fa07ec74a9090f5956c4d29b, 41313032107360200000000);
    lamdenTau.transfer(0xd81daa00a75970af35331c67adc08ad098d2ce91, 21411337200000000000000);
    lamdenTau.transfer(0xec852d93806a0e5c93e506c804717530ac26bb8d, 106843000000000000000000);
    lamdenTau.transfer(0x5bcc44d6962ad2e35b54a8d0614f6307768d8eb1, 21368600000000000000000);
    lamdenTau.transfer(0xef27333bdc75c0d4d42e4b3948bd5743c4572a1a, 22679379327193600000000);

      uint256 balance = lamdenTau.balanceOf(this);
      lamdenTau.transfer(msg.sender, balance);
   }

}