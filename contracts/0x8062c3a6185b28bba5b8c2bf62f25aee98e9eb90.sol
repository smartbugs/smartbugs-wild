pragma solidity ^0.4.13;

/**
 * Math operations with safety checks
 */
library SafeMath {
  function mul(uint a, uint b) internal returns (uint) {
    uint c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function div(uint a, uint b) internal returns (uint) {
    assert(b > 0);
    uint c = a / b;
    assert(a == b * c + a % b);
    return c;
  }

  function sub(uint a, uint b) internal returns (uint) {
    assert(b <= a);
    return a - b;
  }

  function add(uint a, uint b) internal returns (uint) {
    uint c = a + b;
    assert(c >= a);
    return c;
  }

  function max64(uint64 a, uint64 b) internal constant returns (uint64) {
    return a >= b ? a : b;
  }

  function min64(uint64 a, uint64 b) internal constant returns (uint64) {
    return a < b ? a : b;
  }

  function max256(uint256 a, uint256 b) internal constant returns (uint256) {
    return a >= b ? a : b;
  }

  function min256(uint256 a, uint256 b) internal constant returns (uint256) {
    return a < b ? a : b;
  }

  function assert(bool assertion) internal {
    if (!assertion) {
      revert();
    }
  }
}

/**
 * @title ERC20Basic
 * @dev Simpler version of ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/179
 */
contract ERC20Basic {
    uint256 public totalSupply;
    function balanceOf(address who) public constant returns (uint256);
    function transfer(address to, uint256 value) public returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
}


/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20 is ERC20Basic {
    function allowance(address owner, address spender) public constant returns (uint256);
    function transferFrom(address from, address to, uint256 value) public returns (bool);
    function approve(address spender, uint256 value) public returns (bool);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}


/**
 * @title Basic token
 * @dev Basic version of StandardToken, with no allowances.
 */
contract BasicToken is ERC20Basic {
    using SafeMath for uint256;

    mapping(address => uint256) balances;

    /*
     * Fix for the ERC20 short address attack
     */
    modifier onlyPayloadSize(uint size) {
        if (msg.data.length < size + 4) {
            revert();
        }
        _;
    }

    /**
    * @dev transfer token for a specified address
    * @param _to The address to transfer to.
    * @param _value The amount to be transferred.
    */
    function transfer(address _to, uint256 _value) public onlyPayloadSize(2 * 32)  returns (bool) {
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


contract Ownable {
  address public owner;

  function Ownable() {
    owner = msg.sender;
  }

  modifier onlyOwner() {
    if (msg.sender != owner) {
      revert();
    }
    _;
  }
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

}


contract RBInformationStore is Ownable {
    address public profitContainerAddress;
    address public companyWalletAddress;
    uint public etherRatioForOwner;
    address public multiSigAddress;
    address public accountAddressForSponsee;
    bool public isPayableEnabledForAll = true;

    modifier onlyMultiSig() {
        require(multiSigAddress == msg.sender);
        _;
    }

    function RBInformationStore
    (
        address _profitContainerAddress,
        address _companyWalletAddress,
        uint _etherRatioForOwner,
        address _multiSigAddress,
        address _accountAddressForSponsee
    ) {
        profitContainerAddress = _profitContainerAddress;
        companyWalletAddress = _companyWalletAddress;
        etherRatioForOwner = _etherRatioForOwner;
        multiSigAddress = _multiSigAddress;
        accountAddressForSponsee = _accountAddressForSponsee;
    }

    function changeProfitContainerAddress(address _address) onlyMultiSig {
        profitContainerAddress = _address;
    }

    function changeCompanyWalletAddress(address _address) onlyMultiSig {
        companyWalletAddress = _address;
    }

    function changeEtherRatioForOwner(uint _value) onlyMultiSig {
        etherRatioForOwner = _value;
    }

    function changeMultiSigAddress(address _address) onlyMultiSig {
        multiSigAddress = _address;
    }

    function changeOwner(address _address) onlyMultiSig {
        owner = _address;
    }

    function changeAccountAddressForSponsee(address _address) onlyMultiSig {
        accountAddressForSponsee = _address;
    }

    function changeIsPayableEnabledForAll() onlyMultiSig {
        isPayableEnabledForAll = !isPayableEnabledForAll;
    }
}


contract Rate {
    uint public ETH_USD_rate;
    RBInformationStore public rbInformationStore;

    modifier onlyOwner() {
        require(msg.sender == rbInformationStore.owner());
        _;
    }

    function Rate(uint _rate, address _address) {
        ETH_USD_rate = _rate;
        rbInformationStore = RBInformationStore(_address);
    }

    function setRate(uint _rate) onlyOwner {
        ETH_USD_rate = _rate;
    }
}



/**
@title SponseeTokenModel
*/
contract SponseeTokenModel is StandardToken {

    string public name;
    string public symbol;
    uint8 public decimals = 0;
    uint public totalSupply = 0;
    uint public cap = 100000000;                    // maximum cap = 1 000 000 $ = 100 000 000 tokens
    uint public minimumSupport = 500;               // minimum support is 5$(500 cents)
    uint public etherRatioForInvestor = 10;         // etherRatio (10%) to send ether to investor
    address public sponseeAddress;
    bool public isPayableEnabled = true;
    RBInformationStore public rbInformationStore;
    Rate public rate;

    event LogReceivedEther(address indexed from, address indexed to, uint etherValue, string tokenName);
    event LogBuy(address indexed from, address indexed to, uint indexed value, uint paymentId);
    event LogRollbackTransfer(address indexed from, address indexed to, uint value);
    event LogExchange(address indexed from, address indexed token, uint value);
    event LogIncreaseCap(uint value);
    event LogDecreaseCap(uint value);
    event LogSetRBInformationStoreAddress(address indexed to);
    event LogSetName(string name);
    event LogSetSymbol(string symbol);
    event LogMint(address indexed to, uint value);
    event LogChangeSponseeAddress(address indexed to);
    event LogChangeIsPayableEnabled(bool flag);

    modifier onlyAccountAddressForSponsee() {
        require(rbInformationStore.accountAddressForSponsee() == msg.sender);
        _;
    }

    modifier onlyMultiSig() {
        require(rbInformationStore.multiSigAddress() == msg.sender);
        _;
    }

    // constructor
    function SponseeTokenModel(
        string _name,
        string _symbol,
        address _rbInformationStoreAddress,
        address _rateAddress,
        address _sponsee
    ) {
        name = _name;
        symbol = _symbol;
        rbInformationStore = RBInformationStore(_rbInformationStoreAddress);
        rate = Rate(_rateAddress);
        sponseeAddress = _sponsee;
    }

    /**
    @notice Receive ether from any EOA accounts. Amount of ether received in this function is distributed to 3 parts.
    One is a profitContainerAddress which is address of containerWallet to dividend to investor of Boost token.
    Another is an ownerAddress which is address of owner of REALBOOST site.
    The other is an sponseeAddress which is address of owner of this contract.
    Then, return token of this contract to msg.sender related to the amount of ether that msg.sender sent and rate (US cent) of ehter stored in Rate contract.
    */
    function() payable {

        // check condition
        require(isPayableEnabled && rbInformationStore.isPayableEnabledForAll());

        // check validation
        if (msg.value <= 0) { revert(); }

        // calculate support amount in US
        uint supportedAmount = msg.value.mul(rate.ETH_USD_rate()).div(10**18);

        // if support is less than minimum => return money to supporter
        if (supportedAmount < minimumSupport) { revert(); }

        // calculate the ratio of Ether for distribution
        uint etherRatioForOwner = rbInformationStore.etherRatioForOwner();
        uint etherRatioForSponsee = uint(100).sub(etherRatioForOwner).sub(etherRatioForInvestor);

        /* divide Ether */
        // calculate
        uint etherForOwner = msg.value.mul(etherRatioForOwner).div(100);
        uint etherForInvestor = msg.value.mul(etherRatioForInvestor).div(100);
        uint etherForSponsee = msg.value.mul(etherRatioForSponsee).div(100);

        // get address
        address profitContainerAddress = rbInformationStore.profitContainerAddress();
        address companyWalletAddress = rbInformationStore.companyWalletAddress();

        // send Ether
        if (!profitContainerAddress.send(etherForInvestor)) { revert(); }
        if (!companyWalletAddress.send(etherForOwner)) { revert(); }
        if (!sponseeAddress.send(etherForSponsee)) { revert(); }

        // token amount is transfered to sender
        // 1 token = 1 cent, 1 usd = 100 cents
        uint tokenAmount = msg.value.mul(rate.ETH_USD_rate()).div(10**18);

        // add tokens
        balances[msg.sender] = balances[msg.sender].add(tokenAmount);

        // increase total supply
        totalSupply = totalSupply.add(tokenAmount);

        // check cap
        if (totalSupply > cap) { revert(); }

        // send Event
        LogExchange(msg.sender, this, tokenAmount);
        LogReceivedEther(msg.sender, this, msg.value, name);
        Transfer(address(0x0), msg.sender, tokenAmount);
    }

    /**
    @notice Change rbInformationStoreAddress.
    @param _address The address of new rbInformationStore
    */
    function setRBInformationStoreAddress(address _address) onlyMultiSig {

        rbInformationStore = RBInformationStore(_address);

        // send Event
        LogSetRBInformationStoreAddress(_address);
    }

    /**
    @notice Change name.
    @param _name The new name of token
    */
    function setName(string _name) onlyAccountAddressForSponsee {

        name = _name;

        // send Event
        LogSetName(_name);
    }

    /**
    @notice Change symbol.
    @param _symbol The new symbol of token
    */
    function setSymbol(string _symbol) onlyAccountAddressForSponsee {

        symbol = _symbol;

        // send Event
        LogSetSymbol(_symbol);
    }

    /**
    @notice Mint new token amount.
    @param _address The address that new token amount is added
    @param _value The new amount of token
    */
    function mint(address _address, uint _value) onlyAccountAddressForSponsee {

        // add tokens
        balances[_address] = balances[_address].add(_value);

        // increase total supply
        totalSupply = totalSupply.add(_value);

        // check cap
        if (totalSupply > cap) { revert(); }

        // send Event
        LogMint(_address, _value);
        Transfer(address(0x0), _address, _value);
    }

    /**
    @notice Increase cap.
    @param _value The amount of token that should be increased
    */
    function increaseCap(uint _value) onlyAccountAddressForSponsee {

        // change cap here
        cap = cap.add(_value);

        // send Event
        LogIncreaseCap(_value);
    }

    /**
    @notice Decrease cap.
    @param _value The amount of token that should be decreased
    */
    function decreaseCap(uint _value) onlyAccountAddressForSponsee {

        // check whether cap is lower than totalSupply or not
        if (totalSupply > cap.sub(_value)) { revert(); }

        // change cap here
        cap = cap.sub(_value);

        // send Event
        LogDecreaseCap(_value);
    }

    /**
    @notice Rollback transfer.
    @param _from The EOA address for rollback transfer
    @param _to The EOA address for rollback transfer
    @param _value The number of token for rollback transfer
    */
    function rollbackTransfer(address _from, address _to, uint _value) onlyPayloadSize(3 * 32) onlyMultiSig {

        balances[_to] = balances[_to].sub(_value);
        balances[_from] = balances[_from].add(_value);

        // send Event
        LogRollbackTransfer(_from, _to, _value);
        Transfer(_from, _to, _value);
    }

    /**
    @notice Transfer from msg.sender for downloading of content.
    @param _to The EOA address for buy content
    @param _value The number of token for buy content
    @param _paymentId The id of content which msg.sender want to buy
    */
    function buy(address _to, uint _value, uint _paymentId) {

        transfer(_to, _value);

        // send Event
        LogBuy(msg.sender, _to, _value, _paymentId);
    }

    /**
    @notice This method will change old sponsee address with a new one.
    @param _newAddress new address is set
    */
    function changeSponseeAddress(address _newAddress) onlyAccountAddressForSponsee {

        sponseeAddress = _newAddress;

        // send Event
        LogChangeSponseeAddress(_newAddress);
    }

    /**
    @notice This method will change isPayableEnabled flag.
    */
    function changeIsPayableEnabled() onlyMultiSig {

        isPayableEnabled = !isPayableEnabled;

        // send Event
        LogChangeIsPayableEnabled(isPayableEnabled);
    }
}