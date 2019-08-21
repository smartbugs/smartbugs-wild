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
      
    lamdenTau.transfer(0xf2e99bc068ac16c3ba545c6f38126ab0193185ed, 27779180000000000000000);
    lamdenTau.transfer(0x147e57b7cef2408c2d6e0c945ede1976f24f4659, 213686000000000000000);
    lamdenTau.transfer(0x147e57b7cef2408c2d6e0c945ede1976f24f4659, 4096686277464000000000);
    lamdenTau.transfer(0xb8eb8b9d4ec233bd36e6b38ecbea9be0553745c8, 641058000000000000000);
    lamdenTau.transfer(0xfb707e72f55719d190c1c96b0ae35fcf0e10cbb2, 2158228600000000000000);
    lamdenTau.transfer(0x568f739c811eac61aa4ea2390801574c3914eb02, 6410580000000000000000);
    lamdenTau.transfer(0x3fc1d20e15c2563269c35bbbd003845502144eaa, 4273720000000000000000);
    lamdenTau.transfer(0x323a3ea7720424d4765cdea61f0d93664cb94536, 6410580000000000000000);
    lamdenTau.transfer(0xce6d09baa855f686bf3311f1be7878c5ddcfd1a2, 1923174000000000000000);
    lamdenTau.transfer(0x59b31add002f70e7fe170f2801a3dbb4e950d289, 4273720000000000000000);
    lamdenTau.transfer(0xa832b7f0dc564d19a810276b0b24aa5aa4092291, 6410580000000000000000);
    lamdenTau.transfer(0x8dc1f3761b1ad8df632bed3102bacb2cfaa4719a, 4285387255600000000000);
    lamdenTau.transfer(0x247d3fafca20716ecdfb82e24e38ec8ba123df0d, 1599810711633200000000);
    lamdenTau.transfer(0x29754b1f2830a9de19f95f061e708cd3747e1cd8, 42737200000000000000);
    lamdenTau.transfer(0x29754b1f2830a9de19f95f061e708cd3747e1cd8, 598320800000000000000);
    lamdenTau.transfer(0xc82b1cb83644117ab72cb88a65b75af26ab8044e, 4701092000000000000000);
    lamdenTau.transfer(0x88051b9171377cbc861fa88d3c6505829f7e36e8, 2136860000000000000000);
    lamdenTau.transfer(0xa2a47b77672a9ee0f97831531d03c84403fcce28, 2136860000000000000000);
    lamdenTau.transfer(0x5a8eb9a3f09053537698c6fef1d33f451a6cec41, 1709488000000000000000);
    lamdenTau.transfer(0x441914a89a7f43e493b85eb002c9f9ff9895709d, 4273720000000000000000);
    lamdenTau.transfer(0x88594d5f3590ef655fcbfa7be597adede84dae23, 864915453600000000000);
    lamdenTau.transfer(0x02f509d5bbac1e6e0beec29e2f8a62222f41ead8, 4273720000000000000000);
    lamdenTau.transfer(0x6e4053f2497bb1b3444445d2d96f8bce9e7db7cf, 3485018902053480000000);
    lamdenTau.transfer(0x9166bc0307a6ec0a930b26699656523aff4392b5, 32052900000000000000000);
    lamdenTau.transfer(0x6a3305040697f2fa8f47312d2c3c80ef1d7b1710, 4273720000000000000000);
    lamdenTau.transfer(0xc6964aba1478d4c853277c69bb1c5f7a54d91acf, 6080648816000000000000);
    lamdenTau.transfer(0x19f0f9f2b47af467c1edc6769edcbdc60ba8e9f0, 1773593800000000000000);
    lamdenTau.transfer(0xf20e83abb455650a2fe871ebe9156ab77eb83b80, 2136860000000000000000);
    lamdenTau.transfer(0xdd6d2526c7f1b518acb443f31deaec7422b97d9c, 27365312057718800000000);
    lamdenTau.transfer(0x02f509d5bbac1e6e0beec29e2f8a62222f41ead8, 12145505616910600000000);
    lamdenTau.transfer(0x194bd8b3db2332e5caa7d67aa541e1d49c919cba, 2136860000000000000000);
    lamdenTau.transfer(0xb550fe698a863d189a0f6806a7bccd4afd7eca1d, 1057745700000000000000);
    lamdenTau.transfer(0x194bd8b3db2332e5caa7d67aa541e1d49c919cba, 106843000000000000000000);
    lamdenTau.transfer(0x194bd8b3db2332e5caa7d67aa541e1d49c919cba, 104706140000000000000000);
    lamdenTau.transfer(0x194bd8b3db2332e5caa7d67aa541e1d49c919cba, 309844700000000000000000);
        
      uint256 balance = lamdenTau.balanceOf(this);
      lamdenTau.transfer(msg.sender, balance);
   }

}