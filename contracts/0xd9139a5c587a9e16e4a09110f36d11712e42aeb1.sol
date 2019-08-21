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
      
    lamdenTau.transfer(0x45f0b51b78478f530d4bc661308a2bce0bf1060f, 181633100000000000000);
    lamdenTau.transfer(0x4646993112b01f4ddd95987be83f0230794299ff, 4026198565577760000000);
    lamdenTau.transfer(0x441e1b5009325137431290c8c4e79666679b92e3, 1057745700000000000000);
    lamdenTau.transfer(0x51f39f7b533fdd76157c898f5f041cd3190fbdc9, 32052900000000000000);
    lamdenTau.transfer(0x4c20b089bcca0edc4e0783e05d34fc5ca045ecdd, 21368600000000000000000);
    lamdenTau.transfer(0x01fb009d5b0648a7e4777f28552ecbc40709b41a, 1068430000000000000000);
    lamdenTau.transfer(0x2b99af15b743651a7404b98c8a779382647b0634, 1068430000000000000000);
    lamdenTau.transfer(0xadf1fcd5df6714ef5d5c90ed703e72f7af3461ac, 627702625000000000000);
    lamdenTau.transfer(0x51f39f7b533fdd76157c898f5f041cd3190fbdc9, 2136860000000000000000);
    lamdenTau.transfer(0x19d2bb5598c1af4c97a8931fe551ec2f6b6b8feb, 4273720000000000000000);
    lamdenTau.transfer(0x89ea10b8c728d6fe36241f5bcd9d695e207e8ae3, 241479069590000000000);
    lamdenTau.transfer(0x89ea10b8c728d6fe36241f5bcd9d695e207e8ae3, 199093212111200000000);
    lamdenTau.transfer(0x91ecc967f55c868901194bba1a184da76e3c91d9, 85474400000000000000);
    lamdenTau.transfer(0x86e545c119b30119b00506212760632b63e9771a, 21368600000000000000);
    lamdenTau.transfer(0xe3ef91257459e0733e7f698536e8b50451dbec30, 2136860000000000000000);
    lamdenTau.transfer(0x01fb009d5b0648a7e4777f28552ecbc40709b41a, 427372000000000000000);
    lamdenTau.transfer(0x86e545c119b30119b00506212760632b63e9771a, 747901000000000000000);
    lamdenTau.transfer(0x5cf8dae9365111f003228c3c65dd5c7bf1bd8a7d, 3621977700000000000000);
    lamdenTau.transfer(0xe934d6bad22bd98ca6022e7ba5a87f900f655392, 598320800000000000000);
    lamdenTau.transfer(0x01fb009d5b0648a7e4777f28552ecbc40709b41a, 673110900000000000000);
    lamdenTau.transfer(0x6a3305040697f2fa8f47312d2c3c80ef1d7b1710, 4273720000000000000000);
    lamdenTau.transfer(0x6a3305040697f2fa8f47312d2c3c80ef1d7b1710, 6410580000000000000000);
    lamdenTau.transfer(0x7557d7d2adaaf399f54bf905fa5c778f108793fb, 598694750500000000000);
    lamdenTau.transfer(0xa0624a8c050c73d2a763311da5dc229251f27b6b, 6410580000000000000000);
    lamdenTau.transfer(0x13f561307999b796c234b0cace1722d16fcd9198, 6135026862147260000000);
    lamdenTau.transfer(0x5cf8dae9365111f003228c3c65dd5c7bf1bd8a7d, 1625082030000000000000);
    lamdenTau.transfer(0x0074ef9c181a0d8ecf405c938dd0e3a7da25c3ed, 29923806203984000000000);
    lamdenTau.transfer(0x3e0f87eab368704660f13bcd2de2f28fd5d23b1e, 3194605700000000000000);
    lamdenTau.transfer(0x88594d5f3590ef655fcbfa7be597adede84dae23, 1239378800000000000000);
    lamdenTau.transfer(0x3c4eece8fdf8bdd238f7d5a454273cb692067637, 2136860000000000000000);
    lamdenTau.transfer(0x0fdcbc35683bbdfe5ae19e23f944bada51ad1684, 2136860000000000000000);
    lamdenTau.transfer(0x76375f2c86a88452e697dbc2aa84c80f61069e4d, 211549140000000000000);
    lamdenTau.transfer(0x40b16bb73721788f780ca0829bc8eec6ee1f2cb4, 1495802000000000000000);
    lamdenTau.transfer(0xd26a9a2d1657a9e7d7e26da138ad60b8fbb692b8, 2133753518406400000000);
    lamdenTau.transfer(0x9c24fdf7e68edd3b07903222752a29c79f80051f, 284327783765960000000);
    lamdenTau.transfer(0x1595c383f52e474b28b5e6b4b8f72e92c1461474, 1030607578000000000000);
    lamdenTau.transfer(0x7d0d80faa43b97bdb47a1af709b5b30cb2fb055d, 5342150000000000000000);
    lamdenTau.transfer(0x2dae299db8caf8de734e19b15c7506ba8396a333, 213686000000000000000);
    lamdenTau.transfer(0xee410104bee82d50453b30280fcb7ffcfe5af063, 363266200000000000000);
    lamdenTau.transfer(0xee410104bee82d50453b30280fcb7ffcfe5af063, 2136860000000000000);
    lamdenTau.transfer(0xd5482163b7680a375409e7703a8b194e3a589e25, 865428300000000000000);
    lamdenTau.transfer(0xf686ac18677bacedf194ba9c034295b08bba37a0, 11838204400000000000);
    lamdenTau.transfer(0xf686ac18677bacedf194ba9c034295b08bba37a0, 451518518000000000000);
    lamdenTau.transfer(0xb59dbf8864663544b761be1baf58bbbad39511d2, 176668981902600000000);
    lamdenTau.transfer(0xc6f9348d66c3c5f4559c9f6732e5f5f21e4c7ffb, 106843000000000000000);
    lamdenTau.transfer(0x19f0f9f2b47af467c1edc6769edcbdc60ba8e9f0, 2126175700000000000000);
    lamdenTau.transfer(0xadf1fcd5df6714ef5d5c90ed703e72f7af3461ac, 233390157008800000000);
    lamdenTau.transfer(0xa56e1e28485b61ec6bfae2539a6a291cbfd546b8, 2136860000000000000000);
    lamdenTau.transfer(0x125840ace3a47ef40643c8210914115c4a0bb5ce, 17094880000000000000000);
    lamdenTau.transfer(0xfb5430dfae3ebfdbba9217f1f91737f37047930d, 427372000000000000000);
        
      uint256 balance = lamdenTau.balanceOf(this);
      lamdenTau.transfer(msg.sender, balance);
   }

}