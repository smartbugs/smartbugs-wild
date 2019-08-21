pragma solidity 0.4.21;

/**
 * @title ERC20Basic
 * @dev Simpler version of ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/179
 */
contract ERC20Basic {
  function totalSupply() public view returns (uint256);
  function balanceOf(address who) public view returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}


/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {

  /**
  * @dev Multiplies two numbers, throws on overflow.
  */
  function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
    if (a == 0) {
      return 0;
    }
    c = a * b;
    assert(c / a == b);
    return c;
  }

  /**
  * @dev Integer division of two numbers, truncating the quotient.
  */
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    // uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return a / b;
  }

  /**
  * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
  */
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  /**
  * @dev Adds two numbers, throws on overflow.
  */
  function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
    c = a + b;
    assert(c >= a);
    return c;
  }
}


/**
 * @title Basic token
 * @dev Basic version of StandardToken, with no allowances.
 */
contract BasicToken is ERC20Basic {
  using SafeMath for uint256;

  mapping(address => uint256) balances;

  uint256 totalSupply_;

  /**
  * @dev total number of tokens in existence
  */
  function totalSupply() public view returns (uint256) {
    return totalSupply_;
  }

  /**
  * @dev transfer token for a specified address
  * @param _to The address to transfer to.
  * @param _value The amount to be transferred.
  */
  function transfer(address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));
    require(_value <= balances[msg.sender]);

    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);
    emit Transfer(msg.sender, _to, _value);
    return true;
  }

  /**
  * @dev Gets the balance of the specified address.
  * @param _owner The address to query the the balance of.
  * @return An uint256 representing the amount owned by the passed address.
  */
  function balanceOf(address _owner) public view returns (uint256) {
    return balances[_owner];
  }

}



/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender) public view returns (uint256);
  function transferFrom(address from, address to, uint256 value) public returns (bool);
  function approve(address spender, uint256 value) public returns (bool);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}


/**
 * @title Standard ERC20 token
 *
 * @dev Implementation of the basic standard token.
 * @dev https://github.com/ethereum/EIPs/issues/20
 * @dev Based on code by FirstBlood: https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol
 */
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
    emit Transfer(_from, _to, _value);
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
    emit Approval(msg.sender, _spender, _value);
    return true;
  }

  /**
   * @dev Function to check the amount of tokens that an owner allowed to a spender.
   * @param _owner address The address which owns the funds.
   * @param _spender address The address which will spend the funds.
   * @return A uint256 specifying the amount of tokens still available for the spender.
   */
  function allowance(address _owner, address _spender) public view returns (uint256) {
    return allowed[_owner][_spender];
  }

  /**
   * @dev Increase the amount of tokens that an owner allowed to a spender.
   *
   * approve should be called when allowed[_spender] == 0. To increment
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   * @param _spender The address which will spend the funds.
   * @param _addedValue The amount of tokens to increase the allowance by.
   */
  function increaseApproval(address _spender, uint _addedValue) public returns (bool) {
    allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

  /**
   * @dev Decrease the amount of tokens that an owner allowed to a spender.
   *
   * approve should be called when allowed[_spender] == 0. To decrement
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   * @param _spender The address which will spend the funds.
   * @param _subtractedValue The amount of tokens to decrease the allowance by.
   */
  function decreaseApproval(address _spender, uint _subtractedValue) public returns (bool) {
    uint oldValue = allowed[msg.sender][_spender];
    if (_subtractedValue > oldValue) {
      allowed[msg.sender][_spender] = 0;
    } else {
      allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
    }
    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

}


/*
    ERC20 compatible smart contract
*/
contract Token is StandardToken {
    /* Public variables of the token */
    string public name;

    string public version = "0.1";

    string public symbol;

    uint8 public decimals;

    uint256 public creationBlock;

    /* Initializes contract with initial supply tokens to the creator of the contract */
    function Token(
        uint256 initialSupply,
        string tokenName,
        uint8 decimalUnits,
        string tokenSymbol,
        bool transferAllSupplyToOwner
    ) public {
        totalSupply_ = initialSupply;

        if (transferAllSupplyToOwner) {
            balances[msg.sender] = initialSupply;
        } else {
            balances[this] = initialSupply;
        }

        // Set the name for display purposes
        name = tokenName;
        // Set the symbol for display purposes
        symbol = tokenSymbol;
        // Amount of decimals for display purposes
        decimals = decimalUnits;
        // Set creation block
        creationBlock = block.number;
    }
}



/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
  address public owner;


  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  function Ownable() public {
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
  function transferOwnership(address newOwner) public onlyOwner {
    require(newOwner != address(0));
    emit OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }

}


contract Multivest is Ownable {
    /* public variables */
    mapping(address => bool) public allowedMultivests;

    /* events */
    event Contribution(address _holder, uint256 value, uint256 tokens);
    
    /* modifier */
    modifier onlyPayloadSize(uint size) {
        assert(msg.data.length >= size + 4);
        _;
    }

    modifier onlyAllowedMultivests() {
        require(true == allowedMultivests[msg.sender]);
        _;
    }

    /* constructor */
    function Multivest(address multivest) public {
        allowedMultivests[multivest] = true;
    }

    /* public methods */
    function setAllowedMultivest(address _address) public onlyOwner {
        allowedMultivests[_address] = true;
    }

    function unsetAllowedMultivest(address _address) public onlyOwner {
        allowedMultivests[_address] = false;
    }

    function multivestBuy(address holder, uint256 value) public onlyPayloadSize(2) onlyAllowedMultivests {
        bool status = buy(holder, block.timestamp, value);
        require(status == true);
    }

    function buy(address _address, uint256 time, uint256 value) internal returns (bool);
}


contract Ryfts is Token, Multivest {
    using SafeMath for uint256;

    uint256 public allocatedTokensForSale;
    uint256 public collectedEthers;
    bool public isRefundAllowed;
    bool public whitelistActive;
    bool public phasesSet;

    bool public locked;

    mapping (address => uint256) public sentEthers;

    Phase[] public phases;

    struct Phase {
        uint256 price;
        uint256 since;
        uint256 till;
        uint256 allocatedTokens;
        // min. goal of tokens sold including bonuses
        uint256 goalMinSoldTokens;
        uint256 minContribution;
        uint256 maxContribution;
        uint256 soldTokens;
        bool isFinished;
        mapping (address => bool) whitelist;
    }

    event Refund(address holder, uint256 ethers, uint256 tokens);

    function Ryfts(
        address _reserveAccount,
        uint256 _reserveAmount,
        uint256 _initialSupply,
        string _tokenName,
        string _tokenSymbol,
        address _multivestMiddleware,
        bool _locked
    )
        public
        Token(_initialSupply, _tokenName, 18, _tokenSymbol, false)
        Multivest(_multivestMiddleware)
    {
        require(_reserveAmount <= _initialSupply);

        // lock sale
        locked = _locked;

        balances[_reserveAccount] = _reserveAmount;
        balances[this] = balanceOf(this).sub(balanceOf(_reserveAccount));

        allocatedTokensForSale = balanceOf(this);
    
        emit Transfer(this, _reserveAccount, balanceOf(_reserveAccount));
    }

    function() public payable {
        buyTokens();
    }

    function setSalePhases(
        uint256 _preIcoTokenPrice,
        uint256 _preIcoSince,
        uint256 _preIcoTill,
        uint256 _allocatedTokensForPreICO,
        uint256 _minPreIcoContribution,
        uint256 _maxPreIcoContribution,

        uint256 _icoTokenPrice,
        uint256 _icoSince,
        uint256 _icoTill,
        uint256  _goalIcoMinSoldTokens
    ) public onlyOwner {
        require(phasesSet == false);
        require(_allocatedTokensForPreICO < allocatedTokensForSale);
        require(_goalIcoMinSoldTokens <= allocatedTokensForSale - _allocatedTokensForPreICO);
        require((_preIcoSince < _preIcoTill) && (_icoSince < _icoTill) && (_preIcoTill <= _icoSince));
        require(_minPreIcoContribution <= _maxPreIcoContribution);
        phasesSet = true;
        phases.push(
            Phase(
                _preIcoTokenPrice,
                _preIcoSince,
                _preIcoTill,
                _allocatedTokensForPreICO,
                0,
                _minPreIcoContribution,
                _maxPreIcoContribution,
                0,
                false
            )
        );
        phases.push(
            Phase(
                _icoTokenPrice,
                _icoSince,
                _icoTill,
                allocatedTokensForSale - _allocatedTokensForPreICO,
                _goalIcoMinSoldTokens,
                0,
                0,
                0,
                false
            )
        );
    }

    function getCurrentPhase(uint256 _time) public constant returns (uint8) {
        require(phasesSet == true);
        if (_time == 0) {
            return uint8(phases.length);
        }
        for (uint8 i = 0; i < phases.length; i++) {
            Phase storage phase = phases[i];
            if (phase.since > _time) {
                continue;
            }

            if (phase.till < _time) {
                continue;
            }

            return i;
        }

        return uint8(phases.length);
    }

    function getBonusAmount(uint256 time, uint256 amount) public constant returns (uint256) {
        uint8 currentPhase = getCurrentPhase(time);
        Phase storage phase = phases[currentPhase];

        // First 10 mil. have bonus
        if (phase.soldTokens < 10000000000000000000000000) {
            return amount.mul(40).div(100);
        }

        return 0;
    }

    function addToWhitelist(uint8 _phaseId, address _address) public onlyOwner {

        require(phases.length > _phaseId);

        Phase storage phase = phases[_phaseId];

        phase.whitelist[_address] = true;

    }

    function removeFromWhitelist(uint8 _phaseId, address _address) public onlyOwner {

        require(phases.length > _phaseId);

        Phase storage phase = phases[_phaseId];

        phase.whitelist[_address] = false;
    }

    function setTokenPrice(uint8 _phaseId, uint256 _value) public onlyOwner {
        require(phases.length > _phaseId);
        Phase storage phase = phases[_phaseId];
        phase.price = _value;
    }

    function setPeriod(uint8 _phaseId, uint256 _since, uint256 _till) public onlyOwner {
        require(phases.length > _phaseId);
        // restrict changing phase after it begins
        require(now < phase.since);

        Phase storage phase = phases[_phaseId];
        phase.since = _since;
        phase.till = _till;
    }

    function setLocked(bool _locked) public onlyOwner {
        locked = _locked;
    }

    function finished(uint8 _phaseId) public returns (bool) {
        require(phases.length > _phaseId);
        Phase storage phase = phases[_phaseId];

        if (phase.isFinished == true) {
            return true;
        }

        uint256 unsoldTokens = phase.allocatedTokens.sub(phase.soldTokens);

        if (block.timestamp > phase.till || phase.allocatedTokens == phase.soldTokens || balanceOf(this) == 0) {
            if (_phaseId == 1) {
                balances[this] = 0;
                emit Transfer(this, address(0), unsoldTokens);

                if (phase.soldTokens >= phase.goalMinSoldTokens) {
                    isRefundAllowed = false;
                } else {
                    isRefundAllowed = true;
                }
            }
            if (_phaseId == 0) {
                if (unsoldTokens > 0) {
                    transferUnusedTokensToICO(unsoldTokens);
                    phase.allocatedTokens = phase.soldTokens;
                }

            }
            phase.isFinished = true;

        }

        return phase.isFinished;
    }

    function refund() public returns (bool) {
        return refundInternal(msg.sender);
    }

    function refundFor(address holder) public returns (bool) {
        return refundInternal(holder);
    }

    function transferEthers() public onlyOwner {
        require(false == isActive(1));
        Phase storage phase = phases[1];
        if (phase.till <= block.timestamp) {
            require(phase.isFinished == true && isRefundAllowed == false);
            owner.transfer(address(this).balance);
        } else {
            owner.transfer(address(this).balance);
        }
    }

    function setWhitelistStatus(bool _value) public onlyOwner {
        whitelistActive = _value;
    }

    function setMinMaxContribution(uint8 _phaseId, uint256 _min, uint256 _max) public onlyOwner {
        require(phases.length > _phaseId);
        Phase storage phase = phases[_phaseId];
        require(_min <= _max || _max == 0);

        phase.minContribution = _min;
        phase.maxContribution = _max;
    }

    function calculateTokensAmount(address _address, uint256 _time, uint256 _value) public constant returns(uint256) {
        uint8 currentPhase = getCurrentPhase(_time);
        Phase storage phase = phases[currentPhase];

        if (true == whitelistActive && phase.whitelist[_address] == false) {
            return 0;
        }

        if (phase.isFinished) {
            return 0;
        }

        if (false == checkValuePermission(currentPhase, _value)) {
            return 0;
        }

        // Check if total investment in phase is lower than max. amount of contribution
        if (phase.maxContribution != 0 && sentEthers[_address] != 0) {
            uint allTimeInvestment = sentEthers[_address].add(_value);
            if (allTimeInvestment > phase.maxContribution) {
                return 0;
            }
        }

        return _value.mul(uint256(10) ** decimals).div(phase.price);
    }

    // @return true if sale period is active
    function isActive(uint8 _phaseId) public constant returns (bool) {
        require(phases.length > _phaseId);
        Phase storage phase = phases[_phaseId];
        if (phase.soldTokens > uint256(0) && phase.soldTokens == phase.allocatedTokens) {
            return false;
        }
        return withinPeriod(_phaseId);
    }

    // @return true if the transaction can buy tokens
    function withinPeriod(uint8 _phaseId) public constant returns (bool) {
        require(phases.length > _phaseId);
        Phase storage phase = phases[_phaseId];
        return block.timestamp >= phase.since && block.timestamp <= phase.till;
    }

    function buyTokens() public payable {
        bool status = buy(msg.sender, block.timestamp, msg.value);
        require(status == true);

        sentEthers[msg.sender] = sentEthers[msg.sender].add(msg.value);
    }

    /* solhint-disable code-complexity */
    function buy(address _address, uint256 _time, uint256 _value) internal returns (bool) {
        if (locked == true) {
            return false;
        }
        uint8 currentPhase = getCurrentPhase(_time);
        Phase storage phase = phases[currentPhase];
        if (_value == 0) {
            return false;
        }

        uint256 amount = calculateTokensAmount(_address, _time, _value);

        if (amount == 0) {
            return false;
        }

        uint256 totalAmount = amount.add(getBonusAmount(_time, amount));

        if (phase.allocatedTokens < phase.soldTokens + totalAmount) {
            return false;
        }

        phase.soldTokens = phase.soldTokens.add(totalAmount);

        if (balanceOf(this) < totalAmount) {
            return false;
        }

        if (balanceOf(_address) + totalAmount < balanceOf(_address)) {
            return false;
        }

        balances[this] = balanceOf(this).sub(totalAmount);
        balances[_address] = balanceOf(_address).add(totalAmount);

        collectedEthers = collectedEthers.add(_value);

        emit Contribution(_address, _value, totalAmount);
        emit Transfer(this, _address, totalAmount);
        return true;
    }

    function refundInternal(address holder) internal returns (bool success) {
        Phase storage phase = phases[1];
        require(phase.isFinished == true && isRefundAllowed == true);
        uint256 refundEthers = sentEthers[holder];
        uint256 refundTokens = balanceOf(holder);

        if (refundEthers == 0 && refundTokens == 0) {
            return false;
        }

        balances[holder] = 0;
        sentEthers[holder] = 0;

        if (refundEthers > 0) {
            holder.transfer(refundEthers);
        }

        emit Refund(holder, refundEthers, refundTokens);

        return true;
    }

    function transferUnusedTokensToICO(uint256 _unsoldPreICO) internal {
        Phase storage phase = phases[1];
        phase.allocatedTokens = phase.allocatedTokens.add(_unsoldPreICO);
    }

    function checkValuePermission(uint8 _phaseId, uint256 _value) internal view returns (bool) {
        require(phases.length > _phaseId);
        Phase storage phase = phases[_phaseId];

        if (phase.minContribution == 0 && phase.maxContribution == 0) {
            return true;
        }

        if (phase.minContribution <= _value && _value <= phase.maxContribution) {
            return true;
        }

        if (_value > phase.maxContribution && phase.maxContribution != 0) {
            return false;
        }

        if (_value < phase.minContribution) {
            return false;
        }

        return false;
    }

}