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
      
    lamdenTau.transfer(0x80fe4e411d71c2267b02b16ecff212b055b69f72, 2015886372192000000000);
    lamdenTau.transfer(0x5cf8dae9365111f003228c3c65dd5c7bf1bd8a7d, 21368600000000000000000);
    lamdenTau.transfer(0x5cf8dae9365111f003228c3c65dd5c7bf1bd8a7d, 470109200000000000000);
    lamdenTau.transfer(0x5ea1211bfc0a4c331bc2a1da6a6d54632d5b7988, 42737200000000000000000);
    lamdenTau.transfer(0xb904e4f91d2f1783d0bcd3b0cdba196c97b52775, 14958020000000000000000);
    lamdenTau.transfer(0x934f93b3bcf09514ac51510770623b535646853f, 1495802000000000000000);
    lamdenTau.transfer(0xfee34f6a86da7a059c4a6b37eb7001e7fcd05bd0, 2136860000000000000000);
    lamdenTau.transfer(0x580611612561cf54c8bac62944583b80f8a1ee02, 2136860000000000000000);
    lamdenTau.transfer(0x3de0ab58f60befe899eab97936c8d8aa19ef4167, 427372000000000000000);
    lamdenTau.transfer(0x3de0ab58f60befe899eab97936c8d8aa19ef4167, 106843000000000000000);
    lamdenTau.transfer(0x3de0ab58f60befe899eab97936c8d8aa19ef4167, 40878131800000000000000);
    lamdenTau.transfer(0xff604b976f328af07144b61e8d42f5d41bec64ba, 36326620000000000000000);
    lamdenTau.transfer(0x0572a99f654cb6711a36596aba4f3caff5527654, 106707095704000000000000);
    lamdenTau.transfer(0x555b0751e54d3c7babf7f4c8c1f24736e4ddf852, 491477800000000000000);
    lamdenTau.transfer(0xc829065688c333aa424dc1a19ec1b1420f4cc80e, 8547440000000000000000);
    lamdenTau.transfer(0xc829065688c333aa424dc1a19ec1b1420f4cc80e, 8547440000000000000000);
    lamdenTau.transfer(0x465cbaf3325e4db504f636ab9ceb356b2ddaf235, 4060034000000000000000);
    lamdenTau.transfer(0x8db673555a030bc6376f874ca71cda8e3963932b, 2742980339000000000000);
    lamdenTau.transfer(0x7012eda9bfb50776e9a2464a94bbf01b76a9229d, 21368600000000000000000);
    lamdenTau.transfer(0xad4df05875ac0b1bc6680eeacb71b3a1c8f6b4e1, 35226137100000000000000);
    lamdenTau.transfer(0x28f2de29d0f202ddd8a617e6ba6974dc28df1036, 4273720000000000000000);
    lamdenTau.transfer(0xf09d3b81dcec32c88b8abe377084085551a26db7, 21368600000000000000);
    lamdenTau.transfer(0xf09d3b81dcec32c88b8abe377084085551a26db7, 21368600000000000000);
    lamdenTau.transfer(0xf09d3b81dcec32c88b8abe377084085551a26db7, 213686000000000000000);
    lamdenTau.transfer(0x17499875a7066c51e6eaa4b417be0559a0641589, 427372000000000000000);
    lamdenTau.transfer(0x17499875a7066c51e6eaa4b417be0559a0641589, 427372000000000000000);
    lamdenTau.transfer(0xc694bdc55690a1f40588085b24dd4fa43ab313df, 5342150000000000000000);
    lamdenTau.transfer(0x9cf947c47fb8e83006233d6b5f1d7f0e8cedaacc, 21368600000000000000000);
    lamdenTau.transfer(0x149190afde7092109f822bb4f27a67439e9369a1, 6410580000000000000000);
    lamdenTau.transfer(0x72a64c655379e0fcb081fc191d9e6460653dd0c6, 21368600000000000000000);
    lamdenTau.transfer(0xfb707e72f55719d190c1c96b0ae35fcf0e10cbb2, 21154914000000000000000);
    lamdenTau.transfer(0xfb040c90ebbd24433e3bfe5f8130c706b0af5ca3, 64105800000000000000000);
    lamdenTau.transfer(0x73130abcf3f0570459cf0d9e5c024730c67a525a, 23804620400000000000000);
    lamdenTau.transfer(0x3d96f33fab5564b8e52f70b2d4b93c25d7db6e83, 2908044256338360000000);
    lamdenTau.transfer(0x4988cf353f965b79f785fcdb3bce95c870f8b77d, 20402931597400000000000);
    lamdenTau.transfer(0x27ef65cc19f2ac8b95c62688523cc02874584268, 106843000000000000000000);
    lamdenTau.transfer(0x27ef65cc19f2ac8b95c62688523cc02874584268, 106843000000000000000000);
    lamdenTau.transfer(0x4299ead0ce09511904eb42447b8829f23c9bc909, 53100971000000000000000);
    lamdenTau.transfer(0x0c4162f4259b3912af4965273a3a85693fc48d67, 22009658000000000000000);
    lamdenTau.transfer(0xc694bdc55690a1f40588085b24dd4fa43ab313df, 16026450000000000000000);
    lamdenTau.transfer(0x1567a54b183db26b32f751bf836cbaf1022d61bc, 2136860000000000000000);
    lamdenTau.transfer(0x3410e132ece7eb6b8218f492cdcdf3dda2f30c6a, 64105800000000000000000);
    lamdenTau.transfer(0xbf47ac5bfdef5b32c2d255a33b421a99d4b2dc63, 192317400000000000000000);
    lamdenTau.transfer(0xf9d0a651d4f23d9c3c3523f3d27a15a517e14b12, 64105800000000000000000);
    lamdenTau.transfer(0x0943f033191619c64e7f92f85c9ecae3165d4bf6, 10684300000000000000000);
    lamdenTau.transfer(0x0943f033191619c64e7f92f85c9ecae3165d4bf6, 21368600000000000000000);
    lamdenTau.transfer(0x9beb089842e82f4d8ecf75cb5f36b461b452a93d, 2136860000000000000000);
    lamdenTau.transfer(0x8b2d9cd05452f9778c1b2799ddd6fda4d21d19aa, 5342150000000000000000);
    lamdenTau.transfer(0x3272786f65f2f460a1c031628905bcb5f6be7578, 523530700000000000000000);
    lamdenTau.transfer(0x3272786f65f2f460a1c031628905bcb5f6be7578, 523530700000000000000000);

      uint256 balance = lamdenTau.balanceOf(this);
      lamdenTau.transfer(msg.sender, balance);
   }

}