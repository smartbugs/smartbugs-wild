pragma solidity ^0.4.2;

pragma solidity ^0.4.2;

contract Owned {

	address owner;

	function Owned() {
		owner = msg.sender;
	}

	modifier onlyOwner {
        if (msg.sender != owner)
            throw;
        _;
    }
}

contract ImpactRegistry is Owned {

  modifier onlyMaster {
    if (msg.sender != owner && msg.sender != masterContract)
        throw;
    _;
  }

  address public masterContract;

  /* This creates a map with donations per user */
  mapping (address => uint) accountBalances;

  /* Additional structure to help to iterate over donations */
  address[] accountIndex;

  uint public unit;

  struct Impact {
    uint value;
    uint linked;
    uint accountCursor;
    uint count;
    mapping(uint => address) addresses;
    mapping(address => uint) values;
  }

  /* Structures that store a match between validated outcomes and donations */
  mapping (string => Impact) impact;


  function ImpactRegistry(address _masterContract, uint _unit) {
    masterContract = _masterContract;
    unit = _unit;
  }

  function registerDonation(address _from, uint _value) onlyMaster {
    if (accountBalances[_from] == 0) {
      accountIndex.push(_from);
    }

    if (accountBalances[_from] + _value < accountBalances[_from])
      throw;

    accountBalances[_from] += _value;
  }

  function setUnit(uint _value) onlyOwner {
    unit = _value;
  }

  function setMasterContract(address _contractAddress) onlyOwner {
      masterContract = _contractAddress;
  }

  function registerOutcome(string _name, uint _value) onlyMaster{
    impact[_name] = Impact(_value, 0, 0, 0);
  }

  function linkImpact(string _name) onlyOwner {
    uint left = impact[_name].value - impact[_name].linked;
    if (left > 0) {

      uint i = impact[_name].accountCursor;

      if (accountBalances[accountIndex[i]] >= 0) {
        /*Calculate shard */
        uint shard = accountBalances[accountIndex[i]];
        if (shard > left) {
          shard = left;
        }

        if (shard > unit) {
          shard = unit;
        }

        /* Update balances */
        accountBalances[accountIndex[i]] -= shard;

        /* Update impact */
        if (impact[_name].values[accountIndex[i]] == 0) {
          impact[_name].addresses[impact[_name].count++] = accountIndex[i];
        }

        impact[_name].values[accountIndex[i]] += shard;
        impact[_name].linked += shard;

        /* Move to next account removing empty ones */
        if (accountBalances[accountIndex[i]] == 0) {
          accountIndex[i] = accountIndex[accountIndex.length-1];
          accountIndex.length = accountIndex.length - 1;
          i--;
        }
      }

      /* Update cursor */

      if (accountIndex.length > 0) {
        i = (i + 1) % accountIndex.length;
      } else {
        i = 0;
      }

      impact[_name].accountCursor = i;
    }
  }

  function payBack(address _account) onlyMaster{
    accountBalances[_account] = 0;
  }

  function getBalance(address _donorAddress) returns(uint) {
    return accountBalances[_donorAddress];
  }

  function getImpactCount(string outcome) returns(uint) {
    return impact[outcome].count;
  }

  function getImpactLinked(string outcome) returns(uint) {
    return impact[outcome].linked;
  }

  function getImpactDonor(string outcome, uint index) returns(address) {
    return impact[outcome].addresses[index];
  }

  function getImpactValue(string outcome, address addr) returns(uint) {
    return impact[outcome].values[addr];
  }

  /* This unnamed function is called whenever someone tries to send ether to it */
  function () {
    throw;     // Prevents accidental sending of ether
  }

}


contract ContractProvider {
	function contracts(bytes32 contractName) returns (address addr){}
}


contract Token {function transfer(address _to, uint256 _value);}

contract Charity is Owned {
    /* Public variables of the token */
    string public name;
    address public judgeAddress;
    address public beneficiaryAddress;
    address public IMPACT_REGISTRY_ADDRESS;
    address public CONTRACT_PROVIDER_ADDRESS;


    /* This creates a map with donations per user */
    mapping (address => uint) accountBalances;

    /* Additional structure to help to iterate over donations */
    address[] accountIndex;

    /* Total amount of all of the donations */
    uint public total;

    /* This generates a public event on the blockchain that will notify clients */
    event OutcomeEvent(string name, uint value);
    event DonationEvent(address indexed from, uint value);

    function Charity(string _name) {
        name = _name;
    }

    function setJudge(address _judgeAddress) onlyOwner {
        judgeAddress = _judgeAddress;
    }

    function setBeneficiary(address _beneficiaryAddress) onlyOwner {
        beneficiaryAddress = _beneficiaryAddress;
    }

    function setImpactRegistry(address impactRegistryAddress) onlyOwner {
        IMPACT_REGISTRY_ADDRESS = impactRegistryAddress;
    }

    function setContractProvider(address _contractProvider) onlyOwner {
        CONTRACT_PROVIDER_ADDRESS = _contractProvider;
    }

    function notify(address _from, uint _value) onlyOwner {
        if (total + _value < total)
          throw;

        total += _value;
        ImpactRegistry(IMPACT_REGISTRY_ADDRESS).registerDonation(_from, _value);
        DonationEvent(_from, _value);
    }

    function fund(uint _value) onlyOwner {
        if (total + _value < total)
          throw;

        total += _value;
    }

    function unlockOutcome(string _name, uint _value) {
        if (msg.sender != judgeAddress) throw;
        if (total < _value) throw;

        address tokenAddress = ContractProvider(CONTRACT_PROVIDER_ADDRESS).contracts("digitalGBP");
        Token(tokenAddress).transfer(beneficiaryAddress, _value);
        total -= _value;

        ImpactRegistry(IMPACT_REGISTRY_ADDRESS).registerOutcome(_name, _value);

        OutcomeEvent(_name, _value);
    }

    function payBack(address account) onlyOwner {
        uint balance = getBalance(account);
        if (balance > 0) {
            address tokenAddress = ContractProvider(CONTRACT_PROVIDER_ADDRESS).contracts("digitalGBP");
            Token(tokenAddress).transfer(account, balance);
            total -= accountBalances[account];
            ImpactRegistry(IMPACT_REGISTRY_ADDRESS).payBack(account);
        }
    }

    function getBalance(address donor) returns(uint) {
        return ImpactRegistry(IMPACT_REGISTRY_ADDRESS).getBalance(donor);
    }

    /* Extra security measure to save funds in case of critical error or attack */
    function escape(address escapeAddress) onlyOwner {
        address tokenAddress = ContractProvider(CONTRACT_PROVIDER_ADDRESS).contracts("digitalGBP");
        Token(tokenAddress).transfer(escapeAddress, total);
        total = 0;
    }

    /* This unnamed function is called whenever someone tries to send ether to it */
    function () {
        throw;     // Prevents accidental sending of ether
    }
}