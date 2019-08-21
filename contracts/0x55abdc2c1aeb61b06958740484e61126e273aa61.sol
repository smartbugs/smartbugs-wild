pragma solidity ^0.4.13;

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
  function transferOwnership(address newOwner) onlyOwner {
    if (newOwner != address(0)) {
      owner = newOwner;
    }
  }

}

contract Pausable is Ownable {
  event Pause();
  event Unpause();

  bool public paused = false;


  /**
   * @dev modifier to allow actions only when the contract IS paused
   */
  modifier whenNotPaused() {
    require(!paused);
    _;
  }

  /**
   * @dev modifier to allow actions only when the contract IS NOT paused
   */
  modifier whenPaused {
    require(paused);
    _;
  }

  /**
   * @dev called by the owner to pause, triggers stopped state
   */
  function pause() onlyOwner whenNotPaused returns (bool) {
    paused = true;
    Pause();
    return true;
  }

  /**
   * @dev called by the owner to unpause, returns to normal state
   */
  function unpause() onlyOwner whenPaused returns (bool) {
    paused = false;
    Unpause();
    return true;
  }
}

contract ERC20Basic {
  uint256 public totalSupply;
  function balanceOf(address who) constant returns (uint256);
  function transfer(address to, uint256 value) returns (bool);
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
  function transfer(address _to, uint256 _value) returns (bool) {
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
  function balanceOf(address _owner) constant returns (uint256 balance) {
    return balances[_owner];
  }

}

contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender) constant returns (uint256);
  function transferFrom(address from, address to, uint256 value) returns (bool);
  function approve(address spender, uint256 value) returns (bool);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract StandardToken is ERC20, BasicToken {

  mapping (address => mapping (address => uint256)) allowed;


  /**
   * @dev Transfer tokens from one address to another
   * @param _from address The address which you want to send tokens from
   * @param _to address The address which you want to transfer to
   * @param _value uint256 the amout of tokens to be transfered
   */
  function transferFrom(address _from, address _to, uint256 _value) returns (bool) {
    var _allowance = allowed[_from][msg.sender];

    // Check is not needed because sub(_allowance, _value) will already throw if this condition is not met
    // require (_value <= _allowance);

    balances[_to] = balances[_to].add(_value);
    balances[_from] = balances[_from].sub(_value);
    allowed[_from][msg.sender] = _allowance.sub(_value);
    Transfer(_from, _to, _value);
    return true;
  }

  /**
   * @dev Aprove the passed address to spend the specified amount of tokens on behalf of msg.sender.
   * @param _spender The address which will spend the funds.
   * @param _value The amount of tokens to be spent.
   */
  function approve(address _spender, uint256 _value) returns (bool) {

    // To change the approve amount you first have to reduce the addresses`
    //  allowance to zero by calling `approve(_spender, 0)` if it is not
    //  already 0 to mitigate the race condition described here:
    //  https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
    require((_value == 0) || (allowed[msg.sender][_spender] == 0));

    allowed[msg.sender][_spender] = _value;
    Approval(msg.sender, _spender, _value);
    return true;
  }

  /**
   * @dev Function to check the amount of tokens that an owner allowed to a spender.
   * @param _owner address The address which owns the funds.
   * @param _spender address The address which will spend the funds.
   * @return A uint256 specifing the amount of tokens still avaible for the spender.
   */
  function allowance(address _owner, address _spender) constant returns (uint256 remaining) {
    return allowed[_owner][_spender];
  }

}

contract PausableToken is StandardToken, Pausable {

  function transfer(address _to, uint _value) whenNotPaused returns (bool) {
    return super.transfer(_to, _value);
  }

  function transferFrom(address _from, address _to, uint _value) whenNotPaused returns (bool) {
    return super.transferFrom(_from, _to, _value);
  }
}

contract Factory {

    // address public mainnetPresaleContractAddress = 0x6a5B0fa01590ec2F03682023192C95A2EBd8e3B9;
    // address[] public mainnetPresaleBuyers = [
    //     0x00010bd8606a84b1bbad0f2c70b13cce44a46910,
    //     0x00a109ab01028056768469aa11328c8f9d3db45b,
    //     0x01e2f9ba53b6cb91e7f158090d24ebbcadf0c564,
    //     0x0347297c8c1f278c739ff8d76550a3386cf88b60,
    //     0x09b467499cfa5b094aa96eea80fa7095a2508731,
    //     0x0cea3e5c3663f8634b623327a635ca8c2e0ca276,
    //     0x0f659b838270390aaa6bf16e0b9d01ad15d43f00,
    //     0x188cac349c6a156476711a2357779706cfed403f,
    //     0x18ea39b27b1dd0e53a46a90f544a3ee6e16f94c4,
    //     0x1b3b36b36a64aaef71354ef655bffd577ba0276c,
    //     0x1e74a46e968bc0472d09533bf93da27a6c21b079,
    //     0x20abf65634219512c6c98a64614c43220ca2085b,
    //     0x2195fe76d358acd2dc7e804f60bb5f4d53d9f907,
    //     0x23cdcdfcf58a593ed16cf8ff5516a37fee1d48d8,
    //     0x2471ceb7520b926ba02d876cd032fd020237e413,
    //     0x249f600fd158ccd81a418db93a5d3d1b3c420b13,
    //     0x267be1c1d684f78cb4f6a176c4911b741e4ffdc0,
    //     0x2c02d03f53489bd2774f9e360ea393a6c6329bdb,
    //     0x330c63a5b737b5542be108a74b3fef6272619585,
    //     0x358c39cc0aba5fcc0689d840024c4caeb06f85c0,
    //     0x36ca1322f23209703d7bfc4663d2267b07a4cbe8,
    //     0x3833f8dbdbd6bdcb6a883ff209b869148965b364,
    //     0x387fa411fae6769e4fcedcba838d22ea2dd9ffed,
    //     0x3d6f29c67f571cad827bb512c7949b0a1c0b9899,
    //     0x3eb0aefabec429149dd0d4ae560238fb0b68976e,
    //     0x3f04b7101708b7e4a2c693270254ef8a32977b36,
    //     0x41e8374286aacb2b85189cc74b4d1c0362d4fc80,
    //     0x4644c88b98dd5dda0cb6040366df2b4f37e6b50f,
    //     0x4a83cee7d83c28891d851910f7a240a4c2c4d9eb,
    //     0x4b0250098cf3f62f4595be93d8c0afcfe0bd63f1,
    //     0x4f813b5cf2750a59a45f3c5e50397d6ac02b64f9,
    //     0x5030baf58fab3c95799edc9e6cd08abfde5f1e5a,
    //     0x51072c4f9bca88bc9b3b2327fb44b1272ba115c0,
    //     0x532cbc68f66bb7482086a15972fa20ee3aca21c4,
    //     0x53564581a45a5520243083ce050f76ef933a1e66,
    //     0x55c86e80fbe2db0d81ff856110556b1df1713899,
    //     0x598f65c344b3644a9b6bd23a99860cd8d0c3e20a,
    //     0x5f2bdf26f6528ce05aac77d7fa52bac7a836ef66,
    //     0x63e0d8753480ffcc6ce65ec46f9efb06778e819c,
    //     0x66294a00e801db524b215952bf60e85e1a945895,
    //     0x6771bb70d84bedeb60166df47ebb9056169d7a0d,
    //     0x67adfab056edc1a03602139b8ac36a06fc62f1bb,
    //     0x72df894c334a0b8a58b7d220b72d29a50521d9a4,
    //     0x72f084f5ed9384194870b855c22b0065961305b4,
    //     0x75360cbe8c7cb8174b1b623a6d9aacf952c117e3,
    //     0x75e7f640bf6968b6f32c47a3cd82c3c2c9dcae68,
    //     0x76d3451bec571316cfe096b1ab64681286b078d5,
    //     0x783bd8a6077d02eeecbfc142929d71ff4aa2762d,
    //     0x7c01113c3c382d9c1c39e3daa9262e27787a02ee,
    //     0x7ed1e469fcb3ee19c0366d829e291451be638e59,
    //     0x7fec3afb1075d3ee2ca6bd685a9895290ad917df,
    //     0x83e09aee382c74ac0c3094d4a99a45d607590c28,
    //     0x86a392b40c6b33fdbb142eae4c40ff05d3daa82f,
    //     0x87b10daf0522e54cd4cdd3029eac0fdd306f644e,
    //     0x87b325cf000e426b64518d50bf3fb11c28eee89e,
    //     0x8c46dc82995d3bad337418df9a111b289fd50abc,
    //     0x93fb7bea36d788bcb87ba92094b72c6c43586bdb,
    //     0x952aa202f9656eca051ef36ce66925a0d0e34723,
    //     0x9903322124677c2aaf289eec5117bfa8aeac3f42,
    //     0x993841ab5028ee74245d350edd3c89405d4212ea,
    //     0x9ac0233a97b0005462f7d65943b8cf6d7d074280,
    //     0x9d8d17d134be89c832559e1653f8e15d6b8bb05a,
    //     0xa102d39f4aa67f458e9536b04da9b80847c04a57,
    //     0xa163d40de9dc681d7850ed24564d1805414ac468,
    //     0xa263327200a9648c063ef1d9f0746a50b23caa56,
    //     0xaefb5464fadc9293700a9c4bc4fbefb4d768931d,
    //     0xaf302aa751058797c6ab5249cb83547a6357763a,
    //     0xb37e62dce9daee5a2de41e4475c8262f5bb9edae,
    //     0xb93b6e8816091ceb78cca35f7022b477e44c490a,
    //     0xb94142f522bfe77b1075527d8e6a11cbcd901e26,
    //     0xbb4e6fdfbc01b1f2b52272d998fcaa274d7f1651,
    //     0xbdf9b5bda53c709cce44a073067b3e26afe1d816,
    //     0xcd73fd5deec3670926d0cd29b634f6c2938b1df6,
    //     0xcf1996c3b7f9ff891ebf94067b6d0edfa1b181f0,
    //     0xd1f670779246349931ba76ffdf8c90de70946cac,
    //     0xd2e3c4856d25a71fa777769b5dc9596890568026,
    //     0xd4cb7fd8e2b214596c1cbd4ba0f1c701fbf2bcb8,
    //     0xd5742c05e6ae9ea99af45a7c7d1517ce6c042d25,
    //     0xe41ce247756d757e3060ec361c201be019bd54f6,
    //     0xe702afb99a46f9a6e15d3565823867b8b40c499c,
    //     0xec30eacdb39705ec281e10891d605cb0be41e094,
    //     0xee55181386d9b743064c570601014df163d5554c,
    //     0xee8ce6f0ebef4231068db3705fadff5ef9a1f45e,
    //     0xef58321032cf693fa7e39f31e45cbc32f2092cb3,
    //     0xef9a1b20384989f79f73fd5a261e270d6d1888d3,
    //     0xf656d04f13b7bdf09410b8b5cb75bbe3ac5a37e7,
    //     0xf6dc43ba328affec2afebda472ac6977200da957,
    //     0xf6edf5dcdfba55f3cecee2a430bb6c2d30a4a1a8,
    //     0xf8ac3740622308414a41619af0648328f69b6fc0,
    //     0xf8f337c518b4979f12348c279696a5b7754f662e,
    //     0xfbb1b73c4f0bda4f67dca266ce6ef42f520fbb98,
    //     0xfc7d5e499f869d8ee0b17c61b0f6f83bbac2fbc2,
    //     0xffca1e2e0e50faf10cd4a8e1d5bd2f5db57a0771
    // ];

    // address public testnetPresaleContractAddress = 0x6fb8A63800a00141052Ea524f415398188879086;
    // address[] public testnetPresaleBuyers = [
    //     0xf6c6fac8b78e3196eced61df42a0d37cfddbf3f8  
    // ];

    function createContract(
        address newWallet,
        address newMarketingWallet,
        address newLiquidityReserveWallet,
        uint256 newIcoEtherMinCap,
        uint256 newIcoEtherMaxCap,
        uint256 totalPresaleRaised) returns(address created)
    {
        return new SomaIco(
                        newWallet,
                        newMarketingWallet,
                        newLiquidityReserveWallet,
                        newIcoEtherMinCap * 1 ether,
                        newIcoEtherMaxCap * 1 ether,
                        totalPresaleRaised
        );
    }

    function createTestNetContract(
        address wallet,
        address marketingWallet,
        address liquidityReserveWallet,
        uint256 newIcoEtherMinCap,
        uint256 newIcoEtherMaxCap,
        uint256 totalPresaleRaised) returns(address created)
    {
    
     /*
     Contract Admin/Owner: 0x695CA2a93A53f81a7bc48E2c92801A9c0D489a4C
     Funds Wallet: 0x114189928020641C388cBD6126E615f8328A7409
     Marketing wallet: 0x114189928020641C388cBD6126E615f8328A7409
     Liquidity reserve 0x0873D8c478A2E80C5467374661e903c121c3A8C4
     Presale total supply: 2007500000000000000000
     */
     
        address contractAddress = createContract(
            wallet,
            marketingWallet,
            liquidityReserveWallet,
            newIcoEtherMinCap,
            newIcoEtherMaxCap,
            totalPresaleRaised
        );

        //migratePresaleBalances(contractAddress, testnetPresaleContractAddress, testnetPresaleBuyers);

        //transferOwnership(owner, contractAddress);

        return contractAddress;
    }

    function createMainNetContract(
        uint256 newIcoEtherMinCap,
        uint256 newIcoEtherMaxCap) returns(address created)
    {
        //address owner = 0x1025376b8991ACAFBc7d84Fa1a56a63DcfBF04CB; // mainnet admin
        address wallet = 0x22c6731A21aD946Bcd934f62f04B2D06EBFbedC9; // mainnet funds
        address marketingWallet = 0x4A5467431b54C152E404EB702242E78030972DE7; // marketing wallet
        address liquidityReserveWallet = 0xdf398E0bE9e0Da2D8F8D687FD6B2c9082eEFC29a;

        uint256 totalPresaleRaised = 258405312277978624000;

        address contractAddress = createContract(
            wallet,
            marketingWallet,
            liquidityReserveWallet,
            newIcoEtherMinCap,
            newIcoEtherMaxCap,
            totalPresaleRaised
        );

        //migratePresaleBalances(contractAddress, mainnetPresaleContractAddress, mainnetPresaleBuyers);

        //transferOwnership(owner, contractAddress);

        return contractAddress;
    }

    function transferOwnership(address owner, address contractAddress) public {
        Ownable ownableContract = Ownable(contractAddress);
        ownableContract.transferOwnership(owner);
    }

    function migratePresaleBalances(
        address icoContractAddress,
        address presaleContractAddress,
        address[] buyers) public
    {
        SomaIco icoContract = SomaIco(icoContractAddress);
        ERC20Basic presaleContract = ERC20Basic(presaleContractAddress);
        for (uint i = 0; i < buyers.length; i++) {
            address buyer = buyers[i];
            if (icoContract.balanceOf(buyer) > 0) {
                continue;
            }
            uint256 balance = presaleContract.balanceOf(buyer);
            if (balance > 0) {
                icoContract.manuallyAssignTokens(buyer, balance);
            }
        }
    }
}

contract SomaIco is PausableToken {
    using SafeMath for uint256;

    string public name = "Soma Community Token";
    string public symbol = "SCT";
    uint8 public decimals = 18;

    address public liquidityReserveWallet; // address where liquidity reserve tokens will be delivered
    address public wallet; // address where funds are collected
    address public marketingWallet; // address which controls marketing token pool

    uint256 public icoStartTimestamp; // ICO start timestamp
    uint256 public icoEndTimestamp; // ICO end timestamp

    uint256 public totalRaised = 0; // total amount of money raised in wei
    uint256 public totalSupply; // total token supply with decimals precisoin
    uint256 public marketingPool; // marketing pool with decimals precisoin
    uint256 public tokensSold = 0; // total number of tokens sold

    bool public halted = false; //the owner address can set this to true to halt the crowdsale due to emergency

    uint256 public icoEtherMinCap; // should be specified as: 8000 * 1 ether
    uint256 public icoEtherMaxCap; // should be specified as: 120000 * 1 ether
    uint256 public rate = 450; // standard SCT/ETH rate

    event Burn(address indexed burner, uint256 value);

    function SomaIco(
        address newWallet,
        address newMarketingWallet,
        address newLiquidityReserveWallet,
        uint256 newIcoEtherMinCap,
        uint256 newIcoEtherMaxCap,
        uint256 totalPresaleRaised
    ) {
        require(newWallet != 0x0);
        require(newMarketingWallet != 0x0);
        require(newLiquidityReserveWallet != 0x0);
        require(newIcoEtherMinCap <= newIcoEtherMaxCap);
        require(newIcoEtherMinCap > 0);
        require(newIcoEtherMaxCap > 0);

        pause();

        icoEtherMinCap = newIcoEtherMinCap;
        icoEtherMaxCap = newIcoEtherMaxCap;
        wallet = newWallet;
        marketingWallet = newMarketingWallet;
        liquidityReserveWallet = newLiquidityReserveWallet;

        // calculate marketingPool and totalSupply based on the max cap:
        // totalSupply = rate * icoEtherMaxCap + marketingPool
        // marketingPool = 10% * totalSupply
        // hence:
        // totalSupply = 10/9 * rate * icoEtherMaxCap
        totalSupply = icoEtherMaxCap.mul(rate).mul(10).div(9);
        marketingPool = totalSupply.div(10);

        // account for the funds raised during the presale
        totalRaised = totalRaised.add(totalPresaleRaised);

        // assign marketing pool to marketing wallet
        assignTokens(marketingWallet, marketingPool);
    }

    /// fallback function to buy tokens
    function () nonHalted nonZeroPurchase acceptsFunds payable {
        address recipient = msg.sender;
        uint256 weiAmount = msg.value;

        uint256 amount = weiAmount.mul(rate);

        assignTokens(recipient, amount);
        totalRaised = totalRaised.add(weiAmount);

        forwardFundsToWallet();
    }

    modifier acceptsFunds() {
        bool hasStarted = icoStartTimestamp != 0 && now >= icoStartTimestamp;
        require(hasStarted);

        // ICO is continued over the end date until the min cap is reached
        bool isIcoInProgress = now <= icoEndTimestamp
                || (icoEndTimestamp == 0) // before dates are set
                || totalRaised < icoEtherMinCap;
        require(isIcoInProgress);

        bool isBelowMaxCap = totalRaised < icoEtherMaxCap;
        require(isBelowMaxCap);

        _;
    }

    modifier nonHalted() {
        require(!halted);
        _;
    }

    modifier nonZeroPurchase() {
        require(msg.value > 0);
        _;
    }

    function forwardFundsToWallet() internal {
        wallet.transfer(msg.value); // immediately send Ether to wallet address, propagates exception if execution fails
    }

    function assignTokens(address recipient, uint256 amount) internal {
        balances[recipient] = balances[recipient].add(amount);
        tokensSold = tokensSold.add(amount);

        // sanity safeguard
        if (tokensSold > totalSupply) {
            // there is a chance that tokens are sold over the supply:
            // a) when: total presale bonuses > (maxCap - totalRaised) * rate
            // b) when: last payment goes over the maxCap
            totalSupply = tokensSold;
        }

        Transfer(0x0, recipient, amount);
    }

    function setIcoDates(uint256 newIcoStartTimestamp, uint256 newIcoEndTimestamp) public onlyOwner {
        require(newIcoStartTimestamp < newIcoEndTimestamp);
        require(!isIcoFinished());
        icoStartTimestamp = newIcoStartTimestamp;
        icoEndTimestamp = newIcoEndTimestamp;
    }

    function setRate(uint256 _rate) public onlyOwner {
        require(!isIcoFinished());
        rate = _rate;
    }

    function haltFundraising() public onlyOwner {
        halted = true;
    }

    function unhaltFundraising() public onlyOwner {
        halted = false;
    }

    function isIcoFinished() public constant returns (bool icoFinished) {
        return (totalRaised >= icoEtherMinCap && icoEndTimestamp != 0 && now > icoEndTimestamp) ||
               (totalRaised >= icoEtherMaxCap);
    }

    function prepareLiquidityReserve() public onlyOwner {
        require(isIcoFinished());
        
        uint256 unsoldTokens = totalSupply.sub(tokensSold);
        // make sure there are any unsold tokens to be assigned
        require(unsoldTokens > 0);

        // try to allocate up to 10% of total sold tokens to Liquidity Reserve fund:
        uint256 liquidityReserveTokens = tokensSold.div(10);
        if (liquidityReserveTokens > unsoldTokens) {
            liquidityReserveTokens = unsoldTokens;
        }
        assignTokens(liquidityReserveWallet, liquidityReserveTokens);
        unsoldTokens = unsoldTokens.sub(liquidityReserveTokens);

        // if there are still unsold tokens:
        if (unsoldTokens > 0) {
            // decrease  (burn) total supply by the number of unsold tokens:
            totalSupply = totalSupply.sub(unsoldTokens);
        }

        // make sure there are no tokens left
        assert(tokensSold == totalSupply);
    }

    function manuallyAssignTokens(address recipient, uint256 amount) public onlyOwner {
        require(tokensSold < totalSupply);
        assignTokens(recipient, amount);
    }

    /**
     * @dev Burns a specific amount of tokens.
     * @param _value The amount of token to be burned.
     */
    function burn(uint256 _value) public whenNotPaused {
        require(_value > 0);

        address burner = msg.sender;
        balances[burner] = balances[burner].sub(_value);
        totalSupply = totalSupply.sub(_value);
        Burn(burner, _value);
    }

}