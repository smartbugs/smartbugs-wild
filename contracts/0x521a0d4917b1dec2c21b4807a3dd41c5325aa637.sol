pragma solidity ^0.4.16;

contract VCCT {
    //通证名称
    string public name = "VCCT";
    //通证符号
    string public symbol = "VCCT";
    //小数位数
    uint8 public decimals = 18;
    //通证总量
    uint256 public totalSupply;
    bool public lockAll = false;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event FrozenFunds(address target, bool frozen);
    event OwnerUpdate(address _prevOwner, address _newOwner);

    address public owner;
    //0x0无效地址
    address internal newOwner = 0x0;
    mapping(address => bool) public frozens;
    mapping(address => uint256) public balanceOf;

    constructor() public {
        totalSupply = 10000000000 * 10 ** uint256(decimals);
        balanceOf[msg.sender] = totalSupply;
        owner = msg.sender;
    }

    //权限校验
    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    //权限转移
    function transferOwnership(address tOwner) onlyOwner public {
        require(owner != tOwner);
        newOwner = tOwner;
    }

    function acceptOwnership() public {
        require(msg.sender == newOwner && newOwner != 0x0);
        owner = newOwner;
        newOwner = 0x0;
        emit OwnerUpdate(owner, newOwner);
    }

    //设置帐户冻结状态
    function freezeAccount(address target, bool freeze) onlyOwner public {
        frozens[target] = freeze;
        emit FrozenFunds(target, freeze);
    }

    function freezeAll(bool lock) onlyOwner public {
        lockAll = lock;
    }

    function contTransfer(address _to, uint256 weis) onlyOwner public {
        _transfer(this, _to, weis);
    }

    function transfer(address _to, uint256 _value) public {
        _transfer(msg.sender, _to, _value);
    }

    function _transfer(address _from, address _to, uint _value) internal {
        //校验锁定状态
        require(!lockAll);
        //收款地址是否有效
        require(_to != 0x0);
        //付款地址余额是否有效
        require(balanceOf[_from] >= _value);
        //收款是否有数据溢出
        require(balanceOf[_to] + _value >= balanceOf[_to]);
        //付款地址是否冻结
        require(!frozens[_from]);
        uint previousBalances = balanceOf[_from] + balanceOf[_to];
        balanceOf[_from] -= _value;
        balanceOf[_to] += _value;

        emit Transfer(_from, _to, _value);
        assert(balanceOf[_from] + balanceOf[_to] == previousBalances);
    }

}