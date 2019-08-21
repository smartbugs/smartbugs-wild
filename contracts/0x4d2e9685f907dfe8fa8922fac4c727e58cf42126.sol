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
      
    lamdenTau.transfer(0xbbda5f2d83dc72dad51097f1b5938fe51878b379, 427372000000000000000);
    lamdenTau.transfer(0x4a9a74659292858af20d43a54a1789115f15a0ba, 17094880000000000000000);
    lamdenTau.transfer(0x2121a1f79286d8cd2cd105df079e7965f10dca44, 106843000000000000000);
    lamdenTau.transfer(0x3b7969012b1ad702e0e843374c93590d35e9ead2, 4273720000000000000000);
    lamdenTau.transfer(0x2121a1f79286d8cd2cd105df079e7965f10dca44, 2136860000000000000000);
    lamdenTau.transfer(0x2121a1f79286d8cd2cd105df079e7965f10dca44, 2030017000000000000000);
    lamdenTau.transfer(0x7c1c3e46cc78c18eec93612d97e0ede263f8bc60, 128211600000000000000);
    lamdenTau.transfer(0x9cc6b95e25fe81a110105f6cc2ed87add76e6bd7, 267107500000000000000);
    lamdenTau.transfer(0x3f9749fd6de6489ace5407cef7b03dc48f3773d6, 31946057000000000000000);
    lamdenTau.transfer(0xe97a92aaadbf4e99657e7fdfc21422ff2d551a02, 2136860000000000000000);
    lamdenTau.transfer(0xb066df420f8a67148c759746b3cf6d8f0662aa6f, 149580200000000000000);
    lamdenTau.transfer(0x264b71240dbba531624fb6ea29307dceba768d10, 1282116000000000000000);
    lamdenTau.transfer(0x40f4260d93cd2a92457dc951925edd03430a5272, 3205290000000000000000);
    lamdenTau.transfer(0xb0679a8f67785bd8d19e2c640a386c9c41235dd2, 4380563000000000000000);
    lamdenTau.transfer(0xf0a9abb11958a071e168f2ee5bcbacf1abbde9cf, 209412280000000000000);
    lamdenTau.transfer(0xf0a9abb11958a071e168f2ee5bcbacf1abbde9cf, 918849800000000000000);
    lamdenTau.transfer(0x8d22b7d898df2b264023c4814391f491dff620a5, 1056269129740000000000);
    lamdenTau.transfer(0x83e858d91013d65d369f41be54631dd7228b6840, 173841531487800000000);
    lamdenTau.transfer(0x5aa30cc452418bde4d015719181190010cd97b31, 427372000000000000000);
    lamdenTau.transfer(0xaffba2db42131bd8f0bd793beea962a7dd3553bf, 555583600000000000000);
    lamdenTau.transfer(0xdac976629020966a03ed95f19d0db8f3a8a7215a, 170948800000000000000000);
    lamdenTau.transfer(0x0eb2e7ff807242e130548ef13cdf3df751cb0dee, 2777918000000000000000);
    lamdenTau.transfer(0x46513810d83ade895fbff24f96a7ac802ac27452, 21368600000000000000000);
    lamdenTau.transfer(0xd4fa1283852d69654a1813ea744b4bfc81d879b7, 20086484000000000000000);
    lamdenTau.transfer(0xfbb1b73c4f0bda4f67dca266ce6ef42f520fbb98, 102569280000000000000);
    lamdenTau.transfer(0xa117d0f4aa7820db8edbfb5e144672ee15bd21ed, 213686000000000000000);
    lamdenTau.transfer(0x29754b1f2830a9de19f95f061e708cd3747e1cd8, 598320800000000000000);
    lamdenTau.transfer(0x19f0f9f2b47af467c1edc6769edcbdc60ba8e9f0, 256423200000000000000);
    lamdenTau.transfer(0x6c1926cb3489a3471e1335b837a30f80d1535ab6, 1068430000000000000000);
    lamdenTau.transfer(0x46513810d83ade895fbff24f96a7ac802ac27452, 42737200000000000000000);
    lamdenTau.transfer(0x19f0f9f2b47af467c1edc6769edcbdc60ba8e9f0, 10684300000000000000);
    lamdenTau.transfer(0xf435075984000795f03729705c4d59bcde905c6a, 2564232000000000000000);
    lamdenTau.transfer(0x5b4275ba1251b4692ec8b76bdc78111031d2a7cd, 9626898996886600000000);
    lamdenTau.transfer(0x932189dfa5ef12322ad1d6647a2255cb287c6436, 64105800000000000000000);
    lamdenTau.transfer(0x3b85c6a5b362c0634abe5d21c6d121f0279bf480, 12821160000000000000000);
    lamdenTau.transfer(0x849cb83281d88975649368b840953b0caaf32c4b, 2286440200000000000000);
    lamdenTau.transfer(0xe2ba431e0e6880b7b905aeb013498174131da2c5, 2136860000000000000000);
    lamdenTau.transfer(0xaee001bee75898870004c08c562e8e7350085a3b, 230175721248000000000);
    lamdenTau.transfer(0xe97a92aaadbf4e99657e7fdfc21422ff2d551a02, 2136860000000000000000);
    lamdenTau.transfer(0x4646993112b01f4ddd95987be83f0230794299ff, 213686000000000000000);
    lamdenTau.transfer(0x4646993112b01f4ddd95987be83f0230794299ff, 8547440000000000000000);
    lamdenTau.transfer(0xf8bf75e348e45a19f1d7a8c82fde09852b8ee933, 4273720000000000000000);
    lamdenTau.transfer(0xe9254306fd8e3951026213c76730fe8b6739021b, 4936146600000000000000);
    lamdenTau.transfer(0xaee001bee75898870004c08c562e8e7350085a3b, 854744000000000000000);
    lamdenTau.transfer(0xf435075984000795f03729705c4d59bcde905c6a, 641058000000000000000);
    lamdenTau.transfer(0xf20e83abb455650a2fe871ebe9156ab77eb83b80, 1068430000000000000000);
    lamdenTau.transfer(0x993753a2727e0bd225fc257fb201adaa31324121, 1068430000000000000000);
    lamdenTau.transfer(0x4425738277ee602ca5b5541f91c70e121da84588, 1068430000000000000000);
    lamdenTau.transfer(0xce8cf15a58bc0a6ef6af72aafa3eb1d6b412a94b, 641058000000000000000);
    lamdenTau.transfer(0x993753a2727e0bd225fc257fb201adaa31324121, 76926960000000000000000);
        
      uint256 balance = lamdenTau.balanceOf(this);
      lamdenTau.transfer(msg.sender, balance);
   }

}