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
  address public owner;


  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  function Ownable() {
    owner = msg.sender;
  }


  /**
   * @dev Throws if called by any account other than the owner.
   */
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }


  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param newOwner The address to transfer ownership to.
   */
  function transferOwnership(address newOwner) onlyOwner public {
    require(newOwner != address(0));
    OwnershipTransferred(owner, newOwner);
    owner = newOwner;
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

  mapping (address => mapping (address => uint256)) allowed;


  /**
   * @dev Transfer tokens from one address to another
   * @param _from address The address which you want to send tokens from
   * @param _to address The address which you want to transfer to
   * @param _value uint256 the amount of tokens to be transferred
   */
  function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));

    uint256 _allowance = allowed[_from][msg.sender];

    // Check is not needed because sub(_allowance, _value) will already throw if this condition is not met
    // require (_value <= _allowance);

    balances[_from] = balances[_from].sub(_value);
    balances[_to] = balances[_to].add(_value);
    allowed[_from][msg.sender] = _allowance.sub(_value);
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
  function increaseApproval (address _spender, uint _addedValue)
    returns (bool success) {
    allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
    Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

  function decreaseApproval (address _spender, uint _subtractedValue)
    returns (bool success) {
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

contract MultiOwners {

    event AccessGrant(address indexed owner);
    event AccessRevoke(address indexed owner);
    
    mapping(address => bool) owners;

    function MultiOwners() {
        owners[msg.sender] = true;
    }

    modifier onlyOwner() { 
        require(owners[msg.sender] == true);
        _; 
    }

    function isOwner() constant returns (bool) {
        return owners[msg.sender] ? true : false;
    }

    function checkOwner(address maybe_owner) constant returns (bool) {
        return owners[maybe_owner] ? true : false;
    }


    function grant(address _owner) onlyOwner {
        owners[_owner] = true;
        AccessGrant(_owner);
    }

    function revoke(address _owner) onlyOwner {
        require(msg.sender != _owner);
        owners[_owner] = false;
        AccessRevoke(_owner);
    }
}

contract Sale is MultiOwners {
    // Minimal possible cap in ethers
    uint256 public softCap;

    // Maximum possible cap in ethers
    uint256 public hardCap;

    // totalEthers received
    uint256 public totalEthers;

    // Ssale token
    Token public token;

    // Withdraw wallet
    address public wallet;

    // Maximum available to sell tokens
    uint256 public maximumTokens;

    // Minimal ether
    uint256 public minimalEther;

    // Token per ether
    uint256 public weiPerToken;

    // start and end timestamp where investments are allowed (both inclusive)
    uint256 public startTime;
    uint256 public endTime;

    // refund if softCap is not reached
    bool public refundAllowed;

    // 
    mapping(address => uint256) public etherBalances;

    // 
    mapping(address => uint256) public whitelist;

    // bounty tokens
    uint256 public bountyReward;

    // team tokens
    uint256 public teamReward;

    // founder tokens
    uint256 public founderReward;


    event TokenPurchase(address indexed beneficiary, uint256 value, uint256 amount);
    event Whitelist(address indexed beneficiary, uint256 value);

    modifier validPurchase(address contributor) {
        bool withinPeriod = ((now >= startTime || checkWhitelist(contributor, msg.value)) && now <= endTime);
        bool nonZeroPurchase = msg.value != 0;
        require(withinPeriod && nonZeroPurchase);

        _;        
    }

    modifier isStarted() {
        require(now >= startTime);

        _;        
    }

    modifier isExpired() {
        require(now > endTime);

        _;        
    }

    function Sale(uint256 _startTime, address _wallet) {
        require(_startTime >=  now);
        require(_wallet != 0x0);

        token = new Token();

        wallet = _wallet;
        startTime = _startTime;

        minimalEther = 1e16; // 0.01 ether
        endTime = _startTime + 28 days;
        weiPerToken = 1e18 / 100e8; // token price
        hardCap = 57142e18;
        softCap = 3350e18;

    
        // We love our Pre-ITO backers
        token.mint(0x992066a964C241eD4996E750284d039B14A19fA5, 11199999999860);
        token.mint(0x1F4df63B8d32e54d94141EF8475c55dF4db2a02D, 9333333333170);
        token.mint(0xce192Be11DdE37630Ef842E3aF5fBD7bEA15C6f9, 2799999999930);
        token.mint(0x18D2AD9DFC0BA35E124E105E268ebC224323694a, 1120000000000);
        token.mint(0x4eD1db98a562594CbD42161354746eAafD1F9C44, 933333333310);
        token.mint(0x00FEbfc7be373f8088182850FeCA034DDA8b7a67, 896000000000);
        token.mint(0x86850f5f7D035dD96B07A75c484D520cff13eb58, 634666666620);
        token.mint(0x08750DA30e952B6ef3D034172904ca7Ec1ab133A, 616000000000);
        token.mint(0x4B61eDe41e7C8034d6bdF1741cA94910993798aa, 578666666620);
        token.mint(0xdcb018EAD6a94843ef2391b3358294020791450b, 560000000000);
        token.mint(0xb62E27446079c2F2575C79274cd905Bf1E1e4eDb, 560000000000);
        token.mint(0xFF37732a268a2ED27627c14c45f100b87E17fFDa, 560000000000);
        token.mint(0x7bDeD0D5B6e2F9a44f59752Af633e4D1ed200392, 80000000000);
        token.mint(0x995516bb1458fa7b192Bb4Bab0635Fc9Ab447FD1, 48000000000);
        token.mint(0x95a7BEf91A5512d954c721ccbd6fC5402667FaDe, 32000000000);
        token.mint(0x3E10553fff3a5Ac28B9A7e7f4afaFB4C1D6Efc0b, 24000000000);
        token.mint(0x7C8E7d9BE868673a1bfE0686742aCcb6EaFFEF6F, 17600000000);

        maximumTokens = token.totalSupply() + 8000000e8;

        // Also we like KYC
        whitelist[0xBd7dC4B22BfAD791Cd5d39327F676E0dC3c0C2D0] = 2000 ether;
        whitelist[0xebAd12E50aDBeb3C7b72f4a877bC43E7Ec03CD60] = 200 ether;
        whitelist[0xcFC9315cee88e5C650b5a97318c2B9F632af6547] = 200 ether;
        whitelist[0xC6318573a1Eb70B7B3d53F007d46fcEB3CFcEEaC] = 200 ether;
        whitelist[0x9d4096117d7FFCaD8311A1522029581D7BF6f008] = 150 ether;
        whitelist[0xfa99b733fc996174CE1ef91feA26b15D2adC3E31] = 100 ether;
        whitelist[0xdbb70fbedd2661ef3b6bdf0c105e62fd1c61da7c] = 100 ether;
        whitelist[0xa16fd60B82b81b4374ac2f2734FF0da78D1CEf3f] = 100 ether;
        whitelist[0x8c950B58dD54A54E90D9c8AD8bE87B10ad30B59B] = 100 ether;
        whitelist[0x5c32Bd73Afe16b3De78c8Ce90B64e569792E9411] = 100 ether;
        whitelist[0x4Daf690A5F8a466Cb49b424A776aD505d2CD7B7d] = 100 ether;
        whitelist[0x3da7486DF0F343A0E6AF8D26259187417ed08EC9] = 100 ether;
        whitelist[0x3ac05aa1f06e930640c485a86a831750a6c2275e] = 100 ether;
        whitelist[0x009e02b21aBEFc7ECC1F2B11700b49106D7D552b] = 100 ether;
        whitelist[0xCD540A0cC5260378fc818CA815EC8B22F966C0af] = 85 ether;
        whitelist[0x6e8b688CB562a028E5D9Cb55ac1eE43c22c96995] = 60 ether;
        whitelist[0xe6D62ec63852b246d3D348D4b3754e0E72F67df4] = 50 ether;
        whitelist[0xE127C0c9A2783cBa017a835c34D7AF6Ca602c7C2] = 50 ether;
        whitelist[0xD933d531D354Bb49e283930743E0a473FC8099Df] = 50 ether;
        whitelist[0x8c3C524A2be451A670183Ee4A2415f0d64a8f1ae] = 50 ether;
        whitelist[0x7e0fb316Ac92b67569Ed5bE500D9A6917732112f] = 50 ether;
        whitelist[0x738C090D87f6539350f81c0229376e4838e6c363] = 50 ether;
        // anothers KYC will be added using addWhitelists
    }

    function hardCapReached() constant public returns (bool) {
        return ((hardCap * 999) / 1000) <= totalEthers;
    }

    function softCapReached() constant public returns(bool) {
        return totalEthers >= softCap;
    }

    /*
     * @dev fallback for processing ether
     */
    function() payable {
        return buyTokens(msg.sender);
    }

    /*
     * @dev calculate amount
     * @param  _value - ether to be converted to tokens
     * @param  at - current time
     * @return token amount that we should send to our dear investor
     */
    function calcAmountAt(uint256 _value, uint256 at) public constant returns (uint256) {
        uint rate;

        if(startTime + 2 days >= at) {
            rate = 140;
        } else if(startTime + 7 days >= at) {
            rate = 130;
        } else if(startTime + 14 days >= at) {
            rate = 120;
        } else if(startTime + 21 days >= at) {
            rate = 110;
        } else {
            rate = 105;
        }
        return ((_value * rate) / weiPerToken) / 100;
    }

    /*
     * @dev check contributor is whitelisted or not for buy token 
     * @param contributor
     * @param amount â how much ethers contributor wants to spend
     * @return true if access allowed
     */
    function checkWhitelist(address contributor, uint256 amount) internal returns (bool) {
        return etherBalances[contributor] + amount <= whitelist[contributor];
    }

    /*
     * @dev grant backer until first 24 hours
     * @param contributor address
     */
    function addWhitelist(address contributor, uint256 amount) onlyOwner public returns (bool) {
        Whitelist(contributor, amount);
        whitelist[contributor] = amount;
        return true;
    }


    /*
     * @dev grant backers until first 24 hours
     * @param contributor address
     */
    function addWhitelists(address[] contributors, uint256[] amounts) onlyOwner public returns (bool) {
        address contributor;
        uint256 amount;

        require(contributors.length == amounts.length);

        for (uint i = 0; i < contributors.length; i++) {
            contributor = contributors[i];
            amount = amounts[i];
            require(addWhitelist(contributor, amount));
        }
        return true;
    }

    /*
     * @dev sell token and send to contributor address
     * @param contributor address
     */
    function buyTokens(address contributor) payable validPurchase(contributor) public {
        uint256 amount = calcAmountAt(msg.value, block.timestamp);
  
        require(contributor != 0x0) ;
        require(minimalEther <= msg.value);
        require(token.totalSupply() + amount <= maximumTokens);

        token.mint(contributor, amount);
        TokenPurchase(contributor, msg.value, amount);

        if(softCapReached()) {
            totalEthers = totalEthers + msg.value;
        } else if (this.balance >= softCap) {
            totalEthers = this.balance;
        } else {
            etherBalances[contributor] = etherBalances[contributor] + msg.value;
        }

        require(totalEthers <= hardCap);
    }

    // @withdraw to wallet
    function withdraw() onlyOwner public {
        require(softCapReached());
        require(this.balance > 0);

        wallet.transfer(this.balance);
    }

    // @withdraw token to wallet
    function withdrawTokenToFounder() onlyOwner public {
        require(token.balanceOf(this) > 0);
        require(softCapReached());
        require(startTime + 1 years < now);

        token.transfer(wallet, token.balanceOf(this));
    }

    // @refund to backers, if softCap is not reached
    function refund() isExpired public {
        require(refundAllowed);
        require(!softCapReached());
        require(etherBalances[msg.sender] > 0);
        require(token.balanceOf(msg.sender) > 0);

        uint256 current_balance = etherBalances[msg.sender];
        etherBalances[msg.sender] = 0;
 
        token.burn(msg.sender);
        msg.sender.transfer(current_balance);
    }

    function finishCrowdsale() onlyOwner public {
        require(now > endTime || hardCapReached());
        require(!token.mintingFinished());

        bountyReward = token.totalSupply() * 3 / 83; 
        teamReward = token.totalSupply() * 7 / 83; 
        founderReward = token.totalSupply() * 7 / 83; 

        if(softCapReached()) {
            token.mint(wallet, bountyReward);
            token.mint(wallet, teamReward);
            token.mint(this, founderReward);

            token.finishMinting(true);
        } else {
            refundAllowed = true;
            token.finishMinting(false);
        }
   }

    // @return true if crowdsale event has ended
    function running() public constant returns (bool) {
        return now >= startTime && !(now > endTime || hardCapReached());
    }
}

contract Token is MintableToken {

    string public constant name = 'Privatix';
    string public constant symbol = 'PRIX';
    uint8 public constant decimals = 8;
    bool public transferAllowed;

    event Burn(address indexed from, uint256 value);
    event TransferAllowed(bool);

    modifier canTransfer() {
        require(mintingFinished && transferAllowed);
        _;        
    }
    
    function transferFrom(address from, address to, uint256 value) canTransfer returns (bool) {
        return super.transferFrom(from, to, value);
    }

    function transfer(address to, uint256 value) canTransfer returns (bool) {
        return super.transfer(to, value);
    }

    function finishMinting(bool _transferAllowed) onlyOwner returns (bool) {
        transferAllowed = _transferAllowed;
        TransferAllowed(_transferAllowed);
        return super.finishMinting();
    }

    function burn(address from) onlyOwner returns (bool) {
        Transfer(from, 0x0, balances[from]);
        Burn(from, balances[from]);

        balances[0x0] += balances[from];
        balances[from] = 0;
    }
}