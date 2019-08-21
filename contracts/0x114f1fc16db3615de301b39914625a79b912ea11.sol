pragma solidity ^0.4.24;

library SafeMath {

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        assert(c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }
}

// Actually, it is not a RingList anymore. It's a Random Access List
// however, needed cyclic list functionality could modeled on top of Random Access List
// Recommended name - AddressSet
library AddressSet {

    // Name is kept for drop-in replacement reasons. Recommended name `Instance`
    struct Instance {
        address[] list;
        mapping(address => uint256) idx; // actually stores indexes incremented by 1
    }

    // _direction parameter is kept for drop-in replacement consistency; consider remove the parameter
    // Gas efficient version of push
    function push(Instance storage self, address addr) internal returns (bool) {
        if (self.idx[addr] != 0) return false;
        self.idx[addr] = self.list.push(addr);
        return true;
    }

    // Now in O(1)
    function sizeOf(Instance storage self) internal view returns (uint256) {
        return self.list.length;
    }

    // Gets i-th address in O(1) time (RANDOM ACCESS!!!)
    function getAddress(Instance storage self, uint256 index) internal view returns (address) {
        return (index < self.list.length) ? self.list[index] : address(0);
    }

    // Gas efficient version of remove
    function remove(Instance storage self, address addr) internal returns (bool) {
        if (self.idx[addr] == 0) return false;
        uint256 idx = self.idx[addr];
        delete self.idx[addr];
        if (self.list.length == idx) {
            self.list.length--;
        } else {
            address last = self.list[self.list.length-1];
            self.list.length--;
            self.list[idx-1] = last;
            self.idx[last] = idx;
        }
        return true;
    }
}

contract ERC20 {
    function totalSupply() external view returns (uint256 _totalSupply);
    function balanceOf(address _owner) external view returns (uint256 balance);
    function transfer(address _to, uint256 _value) external returns (bool success);
    function transferFrom(address _from, address _to, uint256 _value) external returns (bool success);
    function approve(address _spender, uint256 _value) external returns (bool success);
    function allowance(address _owner, address _spender) external view returns (uint256 remaining);
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}

contract UHCToken is ERC20 {
    using SafeMath for uint256;
    using AddressSet for AddressSet.Instance;

    address public owner;
    address public subowner;

    bool    public              contractEnable = true;

    string  public              name = "UFOHotelCoin";
    string  public              symbol = "UHC";
    uint8   public              decimals = 4;
    uint256 private             summarySupply;
    bool    public              isTransferFee;
    uint8   public              transferFeePercent = 3;
    uint8   public              refererFeePercent = 1;

    struct account{
        uint256 balance;
        uint8 group;
        uint8 status;
        address referer;
        bool isBlocked;
        bool withoutTransferFee;
    }

    mapping(address => account)                      private   accounts;
    mapping(address => mapping (address => uint256)) private   allowed;
    mapping(bytes => address)                        private   promos;

    AddressSet.Instance                             private   holders;

    struct groupPolicy {
        uint8 _default;
        uint8 _backend;
        uint8 _admin;
        uint8 _owner;
    }

    groupPolicy public groupPolicyInstance = groupPolicy(0, 3, 4, 9);

    event EvGroupChanged(address indexed _address, uint8 _oldgroup, uint8 _newgroup);
    event EvMigration(address indexed _address, uint256 _balance, uint256 _secret);
    event EvUpdateStatus(address indexed _address, uint8 _oldstatus, uint8 _newstatus);
    event EvSetReferer(address indexed _referal, address _referer);

    constructor (string _name, string _symbol, uint8 _decimals,uint256 _summarySupply, uint8 _transferFeePercent, uint8 _refererFeePercent) public {
        require(_refererFeePercent < _transferFeePercent);
        owner = msg.sender;

        accounts[owner] = account(_summarySupply, groupPolicyInstance._owner, 4, address(0), false, false);

        holders.push(msg.sender);
        name = _name;
        symbol = _symbol;
        decimals = _decimals;
        summarySupply = _summarySupply;
        transferFeePercent = _transferFeePercent;
        refererFeePercent = _refererFeePercent;
        emit Transfer(address(0), msg.sender, _summarySupply);
    }

    modifier minGroup(int _require) {
        require(accounts[msg.sender].group >= _require);
        _;
    }

    modifier onlySubowner() {
        require(msg.sender == subowner);
        _;
    }

    modifier whenNotMigrating {
        require(contractEnable);
        _;
    }

    modifier whenMigrating {
        require(!contractEnable);
        _;
    }

    function serviceGroupChange(address _address, uint8 _group) minGroup(groupPolicyInstance._admin) external returns(uint8) {
        require(_address != address(0));
        require(_group <= groupPolicyInstance._admin);

        uint8 old = accounts[_address].group;
        require(old < accounts[msg.sender].group);

        accounts[_address].group = _group;
        emit EvGroupChanged(_address, old, _group);

        return accounts[_address].group;
    }

    function serviceTransferOwnership(address newOwner) minGroup(groupPolicyInstance._owner) external {
        require(newOwner != address(0));

        subowner = newOwner;
    }

    function serviceClaimOwnership() onlySubowner() external {
        address temp = owner;
        uint256 value = accounts[owner].balance;

        accounts[owner].balance = accounts[owner].balance.sub(value);
        holders.remove(owner);
        accounts[msg.sender].balance = accounts[msg.sender].balance.add(value);
        holders.push(msg.sender);

        owner = msg.sender;
        subowner = address(0);

        delete accounts[temp].group;
        uint8 oldGroup = accounts[msg.sender].group;
        accounts[msg.sender].group = groupPolicyInstance._owner;

        emit EvGroupChanged(msg.sender, oldGroup, groupPolicyInstance._owner);
        emit Transfer(temp, owner, value);
    }

    function serviceSwitchTransferAbility(address _address) external minGroup(groupPolicyInstance._admin) returns(bool) {
        require(accounts[_address].group < accounts[msg.sender].group);

        accounts[_address].isBlocked = !accounts[_address].isBlocked;

        return true;
    }

    function serviceUpdateTransferFeePercent(uint8 newFee) external minGroup(groupPolicyInstance._admin) {
        require(newFee < 100);
        require(newFee > refererFeePercent);
        transferFeePercent = newFee;
    }

    function serviceUpdateRefererFeePercent(uint8 newFee) external minGroup(groupPolicyInstance._admin) {
        require(newFee < 100);
        require(transferFeePercent > newFee);
        refererFeePercent = newFee;
    }

    function serviceSetPromo(bytes num, address _address) external minGroup(groupPolicyInstance._admin) {
        require(promos[num] == address(0), "Address already set for this promo");
        promos[num] = _address;
    }

    function serviceOnTransferFee() external minGroup(groupPolicyInstance._admin) {
        require(!isTransferFee);
        isTransferFee = true;
    }

    function serviceOffTransferFee() external minGroup(groupPolicyInstance._admin) {
        require(isTransferFee);
        isTransferFee = false;
    }
    
    function serviceAccountTransferFee(address _address, bool _withoutTransferFee) external minGroup(groupPolicyInstance._admin) {
        require(_address != address(0));
        require(accounts[_address].withoutTransferFee != _withoutTransferFee);
        accounts[_address].withoutTransferFee = _withoutTransferFee;
    }

    function backendSetStatus(address _address, uint8 status) external minGroup(groupPolicyInstance._backend) returns(bool){
        require(_address != address(0));
        require(status >= 0 && status <= 4);
        uint8 oldStatus = accounts[_address].status;
        accounts[_address].status = status;

        emit EvUpdateStatus(_address, oldStatus, status);

        return true;
    }

    function backendSetReferer(address _referal, address _referer) external minGroup(groupPolicyInstance._backend) returns(bool) {
        require(accounts[_referal].referer == address(0));
        require(_referal != address(0));
        require(_referal != _referer);
        require(accounts[_referal].referer != _referer);

        accounts[_referal].referer = _referer;

        emit EvSetReferer(_referal, _referer);

        return true;
    }

    function backendSendBonus(address _to, uint256 _value) external minGroup(groupPolicyInstance._backend) returns(bool) {
        require(_to != address(0));
        require(_value > 0);
        require(accounts[owner].balance >= _value);

        accounts[owner].balance = accounts[owner].balance.sub(_value);
        accounts[_to].balance = accounts[_to].balance.add(_value);

        emit Transfer(owner, _to, _value);

        return true;
    }

    function backendRefund(address _from, uint256 _value) external minGroup(groupPolicyInstance._backend) returns(uint256 balance) {
        require(_from != address(0));
        require(_value > 0);
        require(accounts[_from].balance >= _value);
 
        accounts[_from].balance = accounts[_from].balance.sub(_value);
        accounts[owner].balance = accounts[owner].balance.add(_value);
        if(accounts[_from].balance == 0){
            holders.remove(_from);
        }
        emit Transfer(_from, owner, _value);
        return accounts[_from].balance;
    }

    function getGroup(address _check) external view returns(uint8 _group) {
        return accounts[_check].group;
    }

    function getHoldersLength() external view returns(uint256){
        return holders.sizeOf();
    }

    function getHolderByIndex(uint256 _index) external view returns(address){
        return holders.getAddress(_index);
    }

    function getPromoAddress(bytes _promo) external view returns(address) {
        return promos[_promo];
    }

    function getAddressTransferAbility(address _check) external view returns(bool) {
        return !accounts[_check].isBlocked;
    }

    function transfer(address _to, uint256 _value) external returns (bool success) {
        return _transfer(msg.sender, _to, address(0), _value);
    }

    function transferFrom(address _from, address _to, uint256 _value) external returns (bool success) {
        return _transfer(_from, _to, msg.sender, _value);
    }

    function _transfer(address _from, address _to, address _allow, uint256 _value) minGroup(groupPolicyInstance._default) whenNotMigrating internal returns(bool) {
        require(!accounts[_from].isBlocked);
        require(_from != address(0));
        require(_to != address(0));
        uint256 transferFee = accounts[_from].group == 0 && isTransferFee && !accounts[_from].withoutTransferFee ? _value.mul(accounts[_from].referer == address(0) ? transferFeePercent : transferFeePercent - refererFeePercent).div(100) : 0;
        uint256 transferRefererFee = accounts[_from].referer == address(0) || accounts[_from].group != 0 ? 0 : _value.mul(refererFeePercent).div(100);
        uint256 summaryValue = _value.add(transferFee).add(transferRefererFee);
        require(accounts[_from].balance >= summaryValue);
        require(_allow == address(0) || allowed[_from][_allow] >= summaryValue);

        accounts[_from].balance = accounts[_from].balance.sub(summaryValue);
        if(_allow != address(0)) {
            allowed[_from][_allow] = allowed[_from][_allow].sub(summaryValue);
        }

        if(accounts[_from].balance == 0){
            holders.remove(_from);
        }
        accounts[_to].balance = accounts[_to].balance.add(_value);
        holders.push(_to);
        emit Transfer(_from, _to, _value);

        if(transferFee > 0) {
            accounts[owner].balance = accounts[owner].balance.add(transferFee);
            emit Transfer(_from, owner, transferFee);
        }

        if(transferRefererFee > 0) {
            accounts[accounts[_from].referer].balance = accounts[accounts[_from].referer].balance.add(transferRefererFee);
            holders.push(accounts[_from].referer);
            emit Transfer(_from, accounts[_from].referer, transferRefererFee);
        }
        return true;
    }

    function approve(address _spender, uint256 _value) minGroup(groupPolicyInstance._default) external returns (bool success) {
        require (_value == 0 || allowed[msg.sender][_spender] == 0);
        require(_spender != address(0));

        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function increaseApproval(address _spender, uint256 _addedValue) minGroup(groupPolicyInstance._default) external returns (bool)
    {
        allowed[msg.sender][_spender] = (allowed[msg.sender][_spender].add(_addedValue));
        emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
        return true;
    }

    function decreaseApproval(address _spender, uint256 _subtractedValue) minGroup(groupPolicyInstance._default) external returns (bool)
    {
        uint256 oldValue = allowed[msg.sender][_spender];
        if (_subtractedValue > oldValue) {
            allowed[msg.sender][_spender] = 0;
        } else {
            allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
        }
        emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
        return true;
    }

    function allowance(address _owner, address _spender) external view returns (uint256 remaining) {
        return allowed[_owner][_spender];
    }

    function balanceOf(address _owner) external view returns (uint256 balance) {
        return accounts[_owner].balance;
    }

    function statusOf(address _owner) external view returns (uint8) {
        return accounts[_owner].status;
    }

    function refererOf(address _owner) external constant returns (address) {
        return accounts[_owner].referer;
    }

    function totalSupply() external constant returns (uint256 _totalSupply) {
        _totalSupply = summarySupply;
    }

    function settingsSwitchState() external minGroup(groupPolicyInstance._owner) returns (bool state) {

        contractEnable = !contractEnable;

        return contractEnable;
    }

    function userMigration(uint256 _secret) external whenMigrating returns (bool successful) {
        uint256 balance = accounts[msg.sender].balance;

        require (balance > 0);

        accounts[msg.sender].balance = accounts[msg.sender].balance.sub(balance);
        holders.remove(msg.sender);
        accounts[owner].balance = accounts[owner].balance.add(balance);
        holders.push(owner);
        emit EvMigration(msg.sender, balance, _secret);
        emit Transfer(msg.sender, owner, balance);
        return true;
    }
}