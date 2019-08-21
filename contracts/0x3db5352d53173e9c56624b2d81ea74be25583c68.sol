pragma solidity ^0.4.24;

interface POUInterface {

    function totalStaked(address) external view returns(uint256);
    function numApplications(address) external view returns(uint256);

}


interface SaleInterface {
    function saleTokensPerUnit() external view returns(uint256);
    function extraTokensPerUnit() external view returns(uint256);
    function unitContributions(address) external view returns(uint256);
    function disbursementHandler() external view returns(address);
}



/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
  address public owner;


  event OwnershipRenounced(address indexed previousOwner);
  event OwnershipTransferred(
    address indexed previousOwner,
    address indexed newOwner
  );


  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  constructor() public {
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
   * @dev Allows the current owner to relinquish control of the contract.
   * @notice Renouncing to ownership will leave the contract without an owner.
   * It will not be possible to call the functions with the `onlyOwner`
   * modifier anymore.
   */
  function renounceOwnership() public onlyOwner {
    emit OwnershipRenounced(owner);
    owner = address(0);
  }

  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param _newOwner The address to transfer ownership to.
   */
  function transferOwnership(address _newOwner) public onlyOwner {
    _transferOwnership(_newOwner);
  }

  /**
   * @dev Transfers control of the contract to a newOwner.
   * @param _newOwner The address to transfer ownership to.
   */
  function _transferOwnership(address _newOwner) internal {
    require(_newOwner != address(0));
    emit OwnershipTransferred(owner, _newOwner);
    owner = _newOwner;
  }
}





/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {

  /**
  * @dev Multiplies two numbers, throws on overflow.
  */
  function mul(uint256 _a, uint256 _b) internal pure returns (uint256 c) {
    // Gas optimization: this is cheaper than asserting 'a' not being zero, but the
    // benefit is lost if 'b' is also tested.
    // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
    if (_a == 0) {
      return 0;
    }

    c = _a * _b;
    assert(c / _a == _b);
    return c;
  }

  /**
  * @dev Integer division of two numbers, truncating the quotient.
  */
  function div(uint256 _a, uint256 _b) internal pure returns (uint256) {
    // assert(_b > 0); // Solidity automatically throws when dividing by 0
    // uint256 c = _a / _b;
    // assert(_a == _b * c + _a % _b); // There is no case in which this doesn't hold
    return _a / _b;
  }

  /**
  * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
  */
  function sub(uint256 _a, uint256 _b) internal pure returns (uint256) {
    assert(_b <= _a);
    return _a - _b;
  }

  /**
  * @dev Adds two numbers, throws on overflow.
  */
  function add(uint256 _a, uint256 _b) internal pure returns (uint256 c) {
    c = _a + _b;
    assert(c >= _a);
    return c;
  }
}






/// @title Interface for token controllers. The controller specifies whether a transfer can be done.
contract TokenControllerI {

    /// @dev Specifies whether a transfer is allowed or not.
    /// @return True if the transfer is allowed
    function transferAllowed(address _from, address _to)
        external
        view 
        returns (bool);
}




contract FoamTokenController is TokenControllerI, Ownable {
    using SafeMath for uint256;

    POUInterface public registry;
    POUInterface public signaling;
    SaleInterface public sale;
    SaleInterface public saft;

    uint256 public platformLaunchDate;

    uint256 public saleTokensPerUnit;
    uint256 public extraTokensPerUnit;

    mapping (address => bool) public isProtocolContract;

    mapping(address => address) public proposedPair;
    mapping(address => address) public pair;

    mapping(address => bool) public isBlacklisted;

    event ProposeWhitelisted(address _whitelistor, address _whitelistee);
    event ConfirmWhitelisted(address _whitelistor, address _whitelistee);

    // this is one of the TF multisigs.
    // We can then send the tokens onwards to wherever FOAM request for the tokens to be.
    address acceptedAddress = 0x36A9b165ef64767230A7Aded71B04F0911bB1283;

    constructor(POUInterface _registry, POUInterface _signaling, SaleInterface _sale, SaleInterface _saft, uint256 _launchDate) public {
        require(_registry != address(0), "registry contract must have a valid address");
        require(_signaling != address(0), "signaling contract must have a valid address");
        require(_sale != address(0), "sale contract must have a valid address");
        require(_saft != address(0), "saft contract must have a valid address");
        require(_launchDate != 0 && _launchDate <= now, "platform cannot have launched in the future");

        registry = _registry;
        signaling = _signaling;
        sale = _sale;
        saft = _saft;
        platformLaunchDate = _launchDate;

        isProtocolContract[address(registry)] = true;
        isProtocolContract[address(signaling)] = true;

        saleTokensPerUnit = sale.saleTokensPerUnit();
        extraTokensPerUnit = sale.extraTokensPerUnit();
    }

    function setWhitelisted(address _whitelisted) public {
        require(_whitelisted != 0, "cannot whitelist the zero address");

        require(pair[msg.sender] == 0, "sender's address must not be paired yet");
        require(pair[_whitelisted] == 0, "proposed whitelist address must not be paired yet");

        require(sale.unitContributions(msg.sender) != 0, "sender must have purchased tokens during the sale");
        require(sale.unitContributions(_whitelisted) == 0, "proposed whitelist address must not have purchased tokens during the sale");

        proposedPair[msg.sender] = _whitelisted;
        emit ProposeWhitelisted(msg.sender, _whitelisted);
    }

    function confirmWhitelisted(address _whitelistor) public {
        require(pair[msg.sender] == 0, "sender's address must not be paired yet");
        require(pair[_whitelistor] == 0, "whitelistor's address must not be paired yet");

        require(proposedPair[_whitelistor] == msg.sender, "whitelistor's proposed address must be the sender");

        pair[msg.sender] = _whitelistor;
        pair[_whitelistor] = msg.sender;

        emit ConfirmWhitelisted(_whitelistor, msg.sender);
    }

    function setAcceptedAddress(address _newAcceptedAddress) public onlyOwner {
      require(_newAcceptedAddress != address(0), "blacklist bypass address cannot be the zero address");
      acceptedAddress = _newAcceptedAddress;
    }

    function pairAddresses(address[] froms, address[] tos) public onlyOwner {
      require(froms.length == tos.length, "pair arrays must be same size");
      for (uint256 i = 0; i < froms.length; i++) {
        pair[froms[i]] = tos[i];
        pair[tos[i]] = froms[i];
      }
    }

    function blacklistAddresses(address[] _addresses, bool _isBlacklisted) public onlyOwner {
        for (uint256 i = 0; i < _addresses.length; i++) {
            isBlacklisted[_addresses[i]] = _isBlacklisted;
        }
    }

    function changeRegistry(POUInterface _newRegistry) public onlyOwner {
        require(_newRegistry != address(0), "registry contract must have a valid address");
        isProtocolContract[address(registry)] = false;
        isProtocolContract[address(_newRegistry)] = true;
        registry = _newRegistry;
    }

    function changeSignaling(POUInterface _newSignaling) public onlyOwner {
        require(_newSignaling != address(0), "signaling contract must have a valid address");
        isProtocolContract[address(signaling)] = false;
        isProtocolContract[address(_newSignaling)] = true;
        signaling = _newSignaling;
    }

    function setPlatformLaunchDate(uint256 _launchDate) public onlyOwner {
        require(_launchDate != 0 && _launchDate <= now, "platform cannot have launched in the future");
        platformLaunchDate = _launchDate;
    }

    function setProtocolContract(address _contract, bool _isProtocolContract) public onlyOwner {
        isProtocolContract[_contract] = _isProtocolContract;
    }

    function setProtocolContracts(address[] _addresses, bool _isProtocolContract) public onlyOwner {
      for (uint256 i = 0; i < _addresses.length; i++) {
        isProtocolContract[_addresses[i]] = _isProtocolContract;
      }
    }

    function setSaleContract(SaleInterface _sale) public onlyOwner {
      require(_sale != address(0), "sale contract must have a valid address");
      sale = _sale;
    }

    function setSaftContract(SaleInterface _saft) public onlyOwner {
      require(_saft != address(0), "saft contract must have a valid address");
      saft = _saft;
    }

    function transferAllowed(address _from, address _to)
        external
        view
        returns (bool)
    {
        if(isBlacklisted[_from]) {
            return _to == acceptedAddress;
        }

        bool protocolTransfer = isProtocolContract[_from] || isProtocolContract[_to];
        bool whitelistedTransfer = pair[_from] == _to && pair[_to] == _from;

        if (protocolTransfer || whitelistedTransfer || platformLaunchDate + 365 days <= now) {
            return true;
        } else if (platformLaunchDate + 45 days > now) {
            return false;
        }
        return purchaseCheck(_from);
    }

    function purchaseCheck(address _contributor) public view returns (bool) {
        address secondAddress = pair[_contributor];

        uint256 contributed = sale.unitContributions(_contributor).add(saft.unitContributions(_contributor));

        if (contributed == 0) {
            if (secondAddress == 0) {
                return true;
            } else {
                contributed = sale.unitContributions(secondAddress).add(saft.unitContributions(_contributor));
            }
        }

        uint256 tokensStaked = registry.totalStaked(_contributor).add(signaling.totalStaked(_contributor));
        uint256 PoICreated = registry.numApplications(_contributor).add(signaling.numApplications(_contributor));

        if (secondAddress != 0) {
            tokensStaked = tokensStaked.add(registry.totalStaked(secondAddress)).add(signaling.totalStaked(secondAddress));
            PoICreated = PoICreated.add(registry.numApplications(secondAddress)).add(signaling.numApplications(secondAddress));
        }

        uint256 tokensBought = contributed.mul(saleTokensPerUnit.add(extraTokensPerUnit));

        bool enoughStaked;
        if (contributed <= 10000) {
            enoughStaked = tokensStaked >= tokensBought.mul(25).div(100);
        } else {
            enoughStaked = tokensStaked >= tokensBought.mul(50).div(100);
        }

        return enoughStaked && PoICreated >= 10;
    }
}