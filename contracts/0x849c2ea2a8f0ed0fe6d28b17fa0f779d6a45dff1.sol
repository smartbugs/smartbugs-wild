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


contract ERC20Basic {
  uint256 public totalSupply;
  function balanceOf(address who) public constant returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}


contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender) public constant returns (uint256);
  function transferFrom(address from, address to, uint256 value) public returns (bool);
  function approve(address spender, uint256 value) public returns (bool);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}


contract BasicToken is ERC20Basic {
  using SafeMath for uint256;

  mapping(address => uint256) balances;

  function transfer(address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));

    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);
    Transfer(msg.sender, _to, _value);
    return true;
  }

  function balanceOf(address _owner) public constant returns (uint256 balance) {
    return balances[_owner];
  }
}


contract StandardToken is ERC20, BasicToken {

  mapping (address => mapping (address => uint256)) allowed;

  function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));

    uint256 _allowance = allowed[_from][msg.sender];

    balances[_from] = balances[_from].sub(_value);
    balances[_to] = balances[_to].add(_value);
    allowed[_from][msg.sender] = _allowance.sub(_value);
    Transfer(_from, _to, _value);
    return true;
  }

  function approve(address _spender, uint256 _value) public returns (bool) {
    allowed[msg.sender][_spender] = _value;
    Approval(msg.sender, _spender, _value);
    return true;
  }

  function allowance(address _owner, address _spender) public constant returns (uint256 remaining) {
    return allowed[_owner][_spender];
  }

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

contract Certifier {
    event Confirmed(address indexed who);
    event Revoked(address indexed who);
    function certified(address) public constant returns (bool);
    function get(address, string) public constant returns (bytes32);
    function getAddress(address, string) public constant returns (address);
    function getUint(address, string) public constant returns (uint);
}

contract EDUToken is StandardToken {

    using SafeMath for uint256;

    Certifier public certifier;

    // EVENTS
    event CreatedEDU(address indexed _creator, uint256 _amountOfEDU);
    event Transfer(address indexed _from, address indexed _to, uint _value);
    event Approval(address indexed _owner, address indexed _spender, uint _value);

    // GENERAL INFORMATION ABOUT THE TOKEN
    string public constant name = "EDU Token";
    string public constant symbol = "EDU";
    uint256 public constant decimals = 4;
    string public version = "1.0";

    // CONSTANTS
    // Purchase limits
    uint256 public constant TotalEDUSupply = 48000000*10000;                    // MAX TOTAL EDU TOKENS 48 million
    uint256 public constant maxEarlyPresaleEDUSupply = 2601600*10000;           // Maximum EDU tokens early presale supply (Presale Stage 1)
    uint256 public constant maxPresaleEDUSupply = 2198400*10000;                // Maximum EDU tokens presale supply (Presale Stage 2)
    uint256 public constant OSUniEDUSupply = 8400000*10000;                     // Open Source University EDU tokens supply
    uint256 public constant SaleEDUSupply = 30000000*10000;                     // Allocated EDU tokens for crowdsale
    uint256 public constant sigTeamAndAdvisersEDUSupply = 3840000*10000;        // EDU tokens supply allocated for team and advisers
    uint256 public constant sigBountyProgramEDUSupply = 960000*10000;           // EDU tokens supply allocated for bounty program

    //ASSIGNED IN INITIALIZATION
    // Time limits
    uint256 public preSaleStartTime;                                            // Start presale time
    uint256 public preSaleEndTime;                                              // End presale time
    uint256 public saleStartTime;                                               // Start sale time (start crowdsale)
    uint256 public saleEndTime;                                                 // End crowdsale

    // Purchase limits
    uint256 public earlyPresaleEDUSupply;
    uint256 public PresaleEDUSupply;

    // Refund in EDU tokens because of the KYC procedure
    uint256 public EDU_KYC_BONUS = 50*10000;                                    // Bonus 50 EDU tokens for the KYC procedure

    // Lock EDU tokens
    uint256 public LockEDUTeam;                                                 // Lock EDU tokens relocated for the team

    // Token bonuses
    uint256 public EDU_PER_ETH_EARLY_PRE_SALE = 1350;                           // 1350 EDU = 1 ETH  presale stage 1  until the quantities are exhausted
    uint256 public EDU_PER_ETH_PRE_SALE = 1200;                                 // 1200 EDU = 1 ETH  presale stage 2

    // Token sale
    uint256 public EDU_PER_ETH_SALE;                                            // Crowdsale price which will be anaunced after the alpha version of the OSUni platform

    // Addresses
    address public ownerAddress;                                                // Address used by Open Source University
    address public presaleAddress;                                              // Address used in the presale period
    address public saleAddress;                                                 // Address used in the crowdsale period
    address public sigTeamAndAdvisersAddress;                                   // EDU tokens for the team and advisers
    address public sigBountyProgramAddress;                                     // EDU tokens bounty program
    address public contributionsAddress;                                        // Address used for contributions

    // Contribution indicator
    bool public allowContribution = true;                                       // Flag to change if transfering is allowed

    // Running totals
    uint256 public totalWEIInvested = 0;                                        // Total WEI invested
    uint256 public totalEDUSLeft = 0;                                           // Total EDU left
    uint256 public totalEDUSAllocated = 0;                                      // Total EDU allocated
    mapping (address => uint256) public WEIContributed;                         // Total WEI Per Account

    // Owner of account approves the transfer of an amount to another account
    mapping(address => mapping (address => uint256)) allowed;

    // Functions with this modifier can only be executed by the owner of following smart contract
    modifier onlyOwner() {
        if (msg.sender != ownerAddress) {
            revert();
        }
        _;
    }

    // Minimal contribution which will be processed is 0.5 ETH
    modifier minimalContribution() {
        require(500000000000000000 <= msg.value);
        _;
    }

    // Freeze all EDU token transfers during sale period
    modifier freezeDuringEDUtokenSale() {
        if ( (msg.sender == ownerAddress) ||
             (msg.sender == contributionsAddress) ||
             (msg.sender == presaleAddress) ||
             (msg.sender == saleAddress) ||
             (msg.sender == sigBountyProgramAddress) ) {
            _;
        } else {
            if((block.timestamp > preSaleStartTime && block.timestamp < preSaleEndTime) || (block.timestamp > saleStartTime && block.timestamp < saleEndTime)) {
                revert();
            } else {
                _;
            }
        }
    }

    // Freeze EDU tokens for TeamAndAdvisers for 1 year after the end of the presale
    modifier freezeTeamAndAdvisersEDUTokens(address _address) {
        if (_address == sigTeamAndAdvisersAddress) {
            if (LockEDUTeam > block.timestamp) { revert(); }
        }
        _;
    }

    // INITIALIZATIONS FUNCTION
    function EDUToken(
        address _presaleAddress,
        address _saleAddress,
        address _sigTeamAndAdvisersAddress,
        address _sigBountyProgramAddress,
        address _contributionsAddress
    ) {
        certifier = Certifier(0x1e2F058C43ac8965938F6e9CA286685A3E63F24E);
        ownerAddress = msg.sender;                                                               // Store owners address
        presaleAddress = _presaleAddress;                                                        // Store presale address
        saleAddress = _saleAddress;
        sigTeamAndAdvisersAddress = _sigTeamAndAdvisersAddress;                                  // Store sale address
        sigBountyProgramAddress = _sigBountyProgramAddress;
        contributionsAddress = _contributionsAddress;

        preSaleStartTime = 1511179200;                                                           // Start of presale right after end of early presale period
        preSaleEndTime = 1514764799;                                                             // End of the presale period 1 week after end of early presale
        LockEDUTeam = preSaleEndTime + 1 years;                                                  // EDU tokens allocated for the team will be freezed for one year

        earlyPresaleEDUSupply = maxEarlyPresaleEDUSupply;                                        // MAX TOTAL DURING EARLY PRESALE (2 601 600 EDU Tokens)
        PresaleEDUSupply = maxPresaleEDUSupply;                                                  // MAX TOTAL DURING PRESALE (2 198 400 EDU Tokens)

        balances[contributionsAddress] = OSUniEDUSupply;                                         // Allocating EDU tokens for Open Source University             // Allocating EDU tokens for early presale
        balances[presaleAddress] = SafeMath.add(maxPresaleEDUSupply, maxEarlyPresaleEDUSupply);  // Allocating EDU tokens for presale
        balances[saleAddress] = SaleEDUSupply;                                                   // Allocating EDU tokens for sale
        balances[sigTeamAndAdvisersAddress] = sigTeamAndAdvisersEDUSupply;                       // Allocating EDU tokens for team and advisers
        balances[sigBountyProgramAddress] = sigBountyProgramEDUSupply;                           // Bounty program address


        totalEDUSAllocated = OSUniEDUSupply + sigTeamAndAdvisersEDUSupply + sigBountyProgramEDUSupply;
        totalEDUSLeft = SafeMath.sub(TotalEDUSupply, totalEDUSAllocated);                        // EDU Tokens left for sale

        totalSupply = TotalEDUSupply;                                                            // Total EDU Token supply
    }

    // FALL BACK FUNCTION TO ALLOW ETHER CONTRIBUTIONS
    function()
        payable
        minimalContribution
    {
        require(allowContribution);

        // Only PICOPS certified addresses will be allowed to participate
        if (!certifier.certified(msg.sender)) {
            revert();
        }

        // Transaction value in Wei
        uint256 amountInWei = msg.value;

        // Initial amounts
        uint256 amountOfEDU = 0;

        if (block.timestamp > preSaleStartTime && block.timestamp < preSaleEndTime) {
            amountOfEDU = amountInWei.mul(EDU_PER_ETH_EARLY_PRE_SALE).div(100000000000000);
            if(!(WEIContributed[msg.sender] > 0)) {
                amountOfEDU += EDU_KYC_BONUS;  // Bonus for KYC procedure
            }
            if (earlyPresaleEDUSupply > 0 && earlyPresaleEDUSupply >= amountOfEDU) {
                require(updateEDUBalanceFunc(presaleAddress, amountOfEDU));
                earlyPresaleEDUSupply = earlyPresaleEDUSupply.sub(amountOfEDU);
            } else if (PresaleEDUSupply > 0) {
                if (earlyPresaleEDUSupply != 0) {
                    PresaleEDUSupply = PresaleEDUSupply.add(earlyPresaleEDUSupply);
                    earlyPresaleEDUSupply = 0;
                }
                amountOfEDU = amountInWei.mul(EDU_PER_ETH_PRE_SALE).div(100000000000000);
                if(!(WEIContributed[msg.sender] > 0)) {
                    amountOfEDU += EDU_KYC_BONUS;
                }
                require(PresaleEDUSupply >= amountOfEDU);
                require(updateEDUBalanceFunc(presaleAddress, amountOfEDU));
                PresaleEDUSupply = PresaleEDUSupply.sub(amountOfEDU);
            } else {
                revert();
            }
        } else if (block.timestamp > saleStartTime && block.timestamp < saleEndTime) {
            // Sale period
            amountOfEDU = amountInWei.mul(EDU_PER_ETH_SALE).div(100000000000000);
            require(totalEDUSLeft >= amountOfEDU);
            require(updateEDUBalanceFunc(saleAddress, amountOfEDU));
        } else {
            // Outside contribution period
            revert();
        }

        // Update total WEI Invested
        totalWEIInvested = totalWEIInvested.add(amountInWei);
        assert(totalWEIInvested > 0);
        // Update total WEI Invested by account
        uint256 contributedSafe = WEIContributed[msg.sender].add(amountInWei);
        assert(contributedSafe > 0);
        WEIContributed[msg.sender] = contributedSafe;

        // Transfer contributions to Open Source University
        contributionsAddress.transfer(amountInWei);

        // CREATE EVENT FOR SENDER
        CreatedEDU(msg.sender, amountOfEDU);
    }

    /**
     * @dev Function for updating the balance and double checks allocated EDU tokens
     * @param _from The address that will send EDU tokens.
     * @param _amountOfEDU The amount of tokens which will be send to contributor.
     * @return A boolean that indicates if the operation was successful.
     */
    function updateEDUBalanceFunc(address _from, uint256 _amountOfEDU) internal returns (bool) {
        // Update total EDU balance
        totalEDUSLeft = totalEDUSLeft.sub(_amountOfEDU);
        totalEDUSAllocated += _amountOfEDU;

        // Validate EDU allocation
        if (totalEDUSAllocated <= TotalEDUSupply && totalEDUSAllocated > 0) {
            // Update user EDU balance
            uint256 balanceSafe = balances[msg.sender].add(_amountOfEDU);
            assert(balanceSafe > 0);
            balances[msg.sender] = balanceSafe;
            uint256 balanceDiv = balances[_from].sub(_amountOfEDU);
            balances[_from] = balanceDiv;
            return true;
        } else {
            totalEDUSLeft = totalEDUSLeft.add(_amountOfEDU);
            totalEDUSAllocated -= _amountOfEDU;
            return false;
        }
    }

    /**
     * @dev Set contribution flag status
     * @param _allowContribution This is additional parmition for the contributers
     * @return A boolean that indicates if the operation was successful.
     */
    function setAllowContributionFlag(bool _allowContribution) public returns (bool success) {
        require(msg.sender == ownerAddress);
        allowContribution = _allowContribution;
        return true;
    }

    /**
     * @dev Set the sale period
     * @param _saleStartTime Sets the starting time of the sale period
     * @param _saleEndTime Sets the end time of the sale period
     * @return A boolean that indicates if the operation was successful.
     */
    function setSaleTimes(uint256 _saleStartTime, uint256 _saleEndTime) public returns (bool success) {
        require(msg.sender == ownerAddress);
        saleStartTime = _saleStartTime;
        saleEndTime = _saleEndTime;
        return true;
    }

    /**
     * @dev Set change the presale period if necessary
     * @param _preSaleStartTime Sets the starting time of the presale period
     * @param _preSaleEndTime Sets the end time of the presale period
     * @return A boolean that indicates if the operation was successful.
     */
    function setPresaleTime(uint256 _preSaleStartTime, uint256 _preSaleEndTime) public returns (bool success) {
        require(msg.sender == ownerAddress);
        preSaleStartTime = _preSaleStartTime;
        preSaleEndTime = _preSaleEndTime;
        return true;
    }

    function setEDUPrice(
        uint256 _valEarlyPresale,
        uint256 _valPresale,
        uint256 _valSale
    ) public returns (bool success) {
        require(msg.sender == ownerAddress);
        EDU_PER_ETH_EARLY_PRE_SALE = _valEarlyPresale;
        EDU_PER_ETH_PRE_SALE = _valPresale;
        EDU_PER_ETH_SALE = _valSale;
        return true;
    }

    function updateCertifier(address _address) public returns (bool success) {
        certifier = Certifier(_address);
        return true;
    }

    // Balance of a specific account
    function balanceOf(address _owner) constant returns (uint256 balance) {
        return balances[_owner];
    }

    // Transfer the balance from owner's account to another account
    function transfer(address _to, uint256 _amount) freezeDuringEDUtokenSale freezeTeamAndAdvisersEDUTokens(msg.sender) returns (bool success) {
        if (balances[msg.sender] >= _amount && _amount > 0 && balances[_to] + _amount > balances[_to]) {
            balances[msg.sender] -= _amount;
            balances[_to] += _amount;
            Transfer(msg.sender, _to, _amount);
            return true;
        } else {
            return false;
        }
    }

    // Send _value amount of tokens from address _from to address _to
    // The transferFrom method is used for a withdraw workflow, allowing contracts to send
    // tokens on your behalf, for example to "deposit" to a contract address and/or to charge
    // fees in sub-currencies; the command should fail unless the _from account has
    // deliberately authorized the sender of the message via some mechanism; we propose
    // these standardized APIs for approval:
    function transferFrom(address _from, address _to, uint256 _amount) freezeDuringEDUtokenSale freezeTeamAndAdvisersEDUTokens(_from) returns (bool success) {
        if (balances[_from] >= _amount
             && allowed[_from][msg.sender] >= _amount
             && _amount > 0
             && balances[_to] + _amount > balances[_to]) {
            balances[_from] -= _amount;
            allowed[_from][msg.sender] -= _amount;
            balances[_to] += _amount;
            Transfer(_from, _to, _amount);
            return true;
        } else {
            return false;
        }
    }

    // Allow _spender to withdraw from your account, multiple times, up to the _value amount.
    // If this function is called again it overwrites the current allowance with _value.
    function approve(address _spender, uint256 _amount) freezeDuringEDUtokenSale freezeTeamAndAdvisersEDUTokens(msg.sender) returns (bool success) {
        allowed[msg.sender][_spender] = _amount;
        Approval(msg.sender, _spender, _amount);
        return true;
    }

    function allowance(address _owner, address _spender) constant returns (uint256 remaining) {
        return allowed[_owner][_spender];
    }

}