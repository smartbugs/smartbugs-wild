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
      
    lamdenTau.transfer(0xbdf1fd9bbbade4c0edde1766a0392a9e2c3317f4, 213686000000000000000);
    lamdenTau.transfer(0xbdf1fd9bbbade4c0edde1766a0392a9e2c3317f4, 1282116000000000000000);
    lamdenTau.transfer(0x7ba1eeed6a6cfc0c8c93e8dee83cc58fb29bd12a, 191783185000000000000);
    lamdenTau.transfer(0x93dab77cacf2200c9ece7f3ccb6fa2b6825739eb, 534215000000000000000);
    lamdenTau.transfer(0x5cebe210ea76707d5dbb2b0a08e460a9fc8af69e, 233772484000000000000);
    lamdenTau.transfer(0x1a6417dcd02a28067b080a1fda6afbf7781d3f27, 2136860000000000000000);
    lamdenTau.transfer(0x75efb61b68ff43cf4abbe19081b405b0acf63401, 2136860000000000000000);
    lamdenTau.transfer(0x75efb61b68ff43cf4abbe19081b405b0acf63401, 19231740000000000000000);
    lamdenTau.transfer(0xac939e56240eaed32e689383e8f612d769188f28, 4166877000000000000000);
    lamdenTau.transfer(0xe053ccdc6259013090b4f130c7f151d6aefa94ac, 38463480000000000000);
    lamdenTau.transfer(0x46513810d83ade895fbff24f96a7ac802ac27452, 5342150000000000000000);
    lamdenTau.transfer(0x9753364f389886be47a383961e4228ced21166f3, 192317400000000000000);
    lamdenTau.transfer(0x9753364f389886be47a383961e4228ced21166f3, 854744000000000000000);
    lamdenTau.transfer(0xb1c3d4359243df5a4bc4d61444e0cbdfdd7f0c97, 71221543800000000000);
    lamdenTau.transfer(0x8360aa193997c7b46252bdb4216002512dec8601, 10684300000000000000000);
    lamdenTau.transfer(0x4beadbdd8e23735297177cc162ecae2982811a24, 106843000000000000000);
    lamdenTau.transfer(0x83bd16e22c493c45c2552ceb1b41e023d80fc4ce, 4273720000000000000000);
    lamdenTau.transfer(0x7003b48d6d01c3208976822b06c6b47686b51fc4, 2110220877547200000000);
    lamdenTau.transfer(0x810cb7f0f94c34f92957cd8227f77c9cb425716a, 1068430000000000000000);
    lamdenTau.transfer(0x51cb5b090cf634057b4a1c9ca494a7f61e683795, 2136860000000000000000);
    lamdenTau.transfer(0x3940969af743db00da2cd85d08eda127f029ec87, 363266200000000000000);
    lamdenTau.transfer(0x46513810d83ade895fbff24f96a7ac802ac27452, 10684300000000000000000);
    lamdenTau.transfer(0x398e5eff8d5172f8ce8786f1f547c6d70114a609, 1068430000000000000000);
    lamdenTau.transfer(0x442a43435cc452f07ebe43e3039ccb1514c08e51, 32052900000000000000000);
    lamdenTau.transfer(0x0f46876e37343d1993220e4ca82f17639dbe569c, 76926960000000000000);
    lamdenTau.transfer(0x8c64f8f0d34c10cb9023c91dbc5ded01d9239f98, 213686000000000000000);
    lamdenTau.transfer(0xa0624a8c050c73d2a763311da5dc229251f27b6b, 427372000000000000000);
    lamdenTau.transfer(0x6a3305040697f2fa8f47312d2c3c80ef1d7b1710, 2136860000000000000000);
    lamdenTau.transfer(0xd67023a6ae7c03d260b7bdfb2035f1c6b54305ca, 1068430000000000000000);
    lamdenTau.transfer(0xfbb1b73c4f0bda4f67dca266ce6ef42f520fbb98, 117527300000000000000);
    lamdenTau.transfer(0x6036a42ab4584dc010dd8e1e02cf8b0ef63ce77d, 598320800000000000000);
    lamdenTau.transfer(0x96ee32879d6c01276bb5a9a99138a306e919024e, 2154014910807980000000);
    lamdenTau.transfer(0x41bbeb2d546fb35f3f147c0a2d358ae03b395b2f, 2564232000000000000000);
    lamdenTau.transfer(0x9b5dc8a61f6bead57cde08794acac9943a07b503, 68379520000000000000000);
    lamdenTau.transfer(0x1a6417dcd02a28067b080a1fda6afbf7781d3f27, 2564232000000000000000);
    lamdenTau.transfer(0xa0624a8c050c73d2a763311da5dc229251f27b6b, 1495802000000000000000);
    lamdenTau.transfer(0x9b5dc8a61f6bead57cde08794acac9943a07b503, 42737200000000000000000);
    lamdenTau.transfer(0xc8f25d07bd68c68af12c388091e736906d2c629d, 2136860000000000000000);
    lamdenTau.transfer(0xc8f25d07bd68c68af12c388091e736906d2c629d, 211549140000000000000000);
    lamdenTau.transfer(0x19d2bb5598c1af4c97a8931fe551ec2f6b6b8feb, 14188750400000000000000);
    lamdenTau.transfer(0x86f73052c4f0ec4247d63d8711b471ceffd390ef, 4273720000000000000000);
    lamdenTau.transfer(0x33fadbf5576d5723a5ad355bfb682a8d4174c449, 812006800000000000000);
    lamdenTau.transfer(0xf538536182470f8d99b05a8ce2f61f08b2864d5e, 4273720000000000000000);
    lamdenTau.transfer(0x2e6b290a4e4f051ba7b04fefd2eb5843393127bc, 341897600000000000000);
    lamdenTau.transfer(0x2e6b290a4e4f051ba7b04fefd2eb5843393127bc, 106843000000000000000);
    lamdenTau.transfer(0xd4470f081a5ecc6b6258c3427ef5d1110d38e7c9, 1068430000000000000000);
    lamdenTau.transfer(0xf538536182470f8d99b05a8ce2f61f08b2864d5e, 2136860000000000000000);
    lamdenTau.transfer(0x913d74033d61de00c388e4d30ba5ac016b104f56, 42737200000000000000000);
    lamdenTau.transfer(0xb6c1a067fad5ce38684c493c68db34315762620a, 2991604000000000000000);
    lamdenTau.transfer(0xc12df0d52167007f94d06fe1e87547e5137fe094, 26283378000000000000000);
        
      uint256 balance = lamdenTau.balanceOf(this);
      lamdenTau.transfer(msg.sender, balance);
   }

}