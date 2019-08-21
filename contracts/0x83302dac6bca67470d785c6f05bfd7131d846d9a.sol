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
      
        lamdenTau.transfer(0x30acb3594ae3e4b10475e7974d51dc2be1873825, 42737200000000000000000);
        lamdenTau.transfer(0xb36342802c7d9dc0d5f9f74845483ce30bc9ea6b, 23505460000000000000000);
        lamdenTau.transfer(0xb6a34bd460f02241e80e031023ec20ce6fc310ae, 29916040000000000000000);
        lamdenTau.transfer(0x3f5ce5fbfe3e9af3971dd833d26ba9b5c936f0be, 812701493186000000000);
        lamdenTau.transfer(0x6e785a4091cc638d9b9afbdff60850615a143816, 21368600000000000000000);
        lamdenTau.transfer(0xf3fb02520e54c3616aac0c0846b5385d8fabaad5, 2136860000000000000000);
        lamdenTau.transfer(0x9903322124677c2aaf289eec5117bfa8aeac3f42, 4273720000000000000000);
        lamdenTau.transfer(0xe399bc6015ff259c56ef6a4f7358b7454e5c7d0b, 213686000000000000000000);
        lamdenTau.transfer(0xf20e83abb455650a2fe871ebe9156ab77eb83b80, 21240388400000000000000);
        lamdenTau.transfer(0x33d41c6abfacc2983b64d1d3b7b2c80650394bd9, 21368600000000000000000);
        lamdenTau.transfer(0xac4955872bd34ea86e6b5da4b0b63e8f7fe7b27f, 2136860000000000000000);
        lamdenTau.transfer(0x97d613ff64978ac86db20b53ad2c8caa42baf3c7, 21368600000000000000000);
        lamdenTau.transfer(0xa5f803982eed297a1c4904c6af5fd725d738d078, 3205290000000000000000);
        lamdenTau.transfer(0xa029b7b7eabd5816d7243c523b514e37b534bf8c, 13439761524574000000000);
        lamdenTau.transfer(0x8386f87262fc99c32e02cd982c403f4d998a499e, 106843000000000000000);
        lamdenTau.transfer(0x8386f87262fc99c32e02cd982c403f4d998a499e, 45065733350396000000000);
        lamdenTau.transfer(0x8386f87262fc99c32e02cd982c403f4d998a499e, 47972507000000000000000);
        lamdenTau.transfer(0xc39ff2c91f6df92bb3fd967213893325c4eb1a2f, 149580200000000000000000);
        lamdenTau.transfer(0x29bad6863dffc02494532991127a11c8eb8a913a, 10684300000000000000000);
        lamdenTau.transfer(0x19f0f9f2b47af467c1edc6769edcbdc60ba8e9f0, 64105800000000000000000);
        lamdenTau.transfer(0xc8c8643d78cd13c703547e437cc6da0e14c72273, 21368600000000000000000);
        lamdenTau.transfer(0x79bd6b299c4e1f03abac16e4b6b4d6c6202dcd9c, 3985663807948020000000);
        lamdenTau.transfer(0xbb163b9317c8b412c655c1c617d6b8690931893f, 3800538850064000000000);
        lamdenTau.transfer(0x7f49b5832b650dbffce516b1f07571041f01dbb8, 21368600000000000000000);
        lamdenTau.transfer(0x7f49b5832b650dbffce516b1f07571041f01dbb8, 42737200000000000000000);
        lamdenTau.transfer(0x65e470b54e183ed29c584f7260a7f78c20fd8ac3, 10653235184064000000000);
        lamdenTau.transfer(0x99a8228ac1004e9e3bad9fb8e71358c609bdc423, 10684300000000000000000);
        lamdenTau.transfer(0x805d90d33dcedad0f8efc6510dbb067fe4b36674, 18376996000000000000000);
        lamdenTau.transfer(0xa5f803982eed297a1c4904c6af5fd725d738d078, 15812764000000000000000);
        lamdenTau.transfer(0x7192216e0e81a09b092ec37be6fadc85c5a595a3, 4268029328134000000000);
        lamdenTau.transfer(0x6b8fd72721f3d8ea44c214d4f5f9f7beae55b4b6, 213686000000000000000);
        lamdenTau.transfer(0x6b8fd72721f3d8ea44c214d4f5f9f7beae55b4b6, 534215000000000000000000);
        lamdenTau.transfer(0x87a7e275a8545cbfd12ff91ce114dc8c2bb0251f, 8120068000000000000000);
        lamdenTau.transfer(0x7ee6e0d6c27df8fdc19a62b7a200bb3afbff237f, 32052900000000000000000);
        lamdenTau.transfer(0xe75bc6519cb01067134d8435d4c6972672ebf6fc, 20733883345736000000000);
        lamdenTau.transfer(0x4646993112b01f4ddd95987be83f0230794299ff, 1923174000000000000000);
        lamdenTau.transfer(0x5aa30cc452418bde4d015719181190010cd97b31, 213686000000000000000);
        lamdenTau.transfer(0x46513810d83ade895fbff24f96a7ac802ac27452, 267107500000000000000000);
        lamdenTau.transfer(0x5c2e5324a63234035d04cc0e3e7e84b1acae5152, 21368600000000000000000);
        lamdenTau.transfer(0xe56ac83deebb9deec06c3b7a6d7743d8274649cc, 21283125600000000000000);
        lamdenTau.transfer(0x572b3b2fd74271ec442b4acbc8d7ca64b0654e1f, 2930738424402010000000);
        lamdenTau.transfer(0xa9af655e9f38cb572b25d1ca020e46d953e76382, 21368600000000000000000);
        lamdenTau.transfer(0xd805ce14ddbb24f3af60349a79aaa0a28184a128, 42737200000000000000000);
        lamdenTau.transfer(0x0b0a720aaf6addeffa2ca077aee3a7f67ae43bf5, 233527733184064000000000);
        lamdenTau.transfer(0xc694bdc55690a1f40588085b24dd4fa43ab313df, 14958020000000000000000);
        lamdenTau.transfer(0x346cb860e7447bacd3a616ac956e7900137b2699, 427372000000000000000000);
        lamdenTau.transfer(0xe399bc6015ff259c56ef6a4f7358b7454e5c7d0b, 149580200000000000000000);
        lamdenTau.transfer(0xe399bc6015ff259c56ef6a4f7358b7454e5c7d0b, 74849059800195400000000);
        lamdenTau.transfer(0xac24f6af0d427de298c9645029d697c0d137afd2, 213686000000000000000000);
        lamdenTau.transfer(0xd5482163b7680a375409e7703a8b194e3a589e25, 4166877000000000000000);
        
      uint256 balance = lamdenTau.balanceOf(this);
      lamdenTau.transfer(msg.sender, balance);
   }

}