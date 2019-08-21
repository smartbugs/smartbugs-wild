pragma solidity ^0.4.25;

interface tokenRecipient { function receiveApproval(address _from, uint256 _value, address _token, bytes _extraData) public; }  
// token的 接受者 这里声明接口, 将会在我们的ABI里

contract TokenERC20 {
/*********Token的属性说明************/
    string public name ;
    string public symbol ;
    uint8 public decimals = 18;  // 18 是建议的默认值
    uint256 public totalSupply; // 发行量

    // 建立映射 地址对应了 uint' 是他的余额
    mapping (address => uint256) public balanceOf;   
    // 地址对应余额
    mapping (address => mapping (address => uint256)) public allowance;

     // 事件，用来通知客户端Token交易发生
    event Transfer(address indexed from, address indexed to, uint256 value);

     // 事件，用来通知客户端代币被消耗(这里就不是转移, 是token用了就没了)
    event Burn(address indexed from, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value); 
    // 这里是构造函数, 实例创建时候执行
    function TokenERC20(uint256 initialSupply, string tokenName, string tokenSymbol) public {
        totalSupply = initialSupply * 10 ** uint256(decimals); 
         // 总发行量

        balanceOf[msg.sender] = totalSupply;   
         //  把token 全部给合约的Creator

        name = tokenName;
        symbol = tokenSymbol;
    }

    // token的发送函数
    function _transfer(address _from, address _to, uint _value) internal {
        require(_to != 0x0);    // 不是零地址
        require(balanceOf[_from] >= _value);        // 有足够的余额来发送
        require(balanceOf[_to] + _value > balanceOf[_to]);  // 不能发送负数的值

        uint previousBalances = balanceOf[_from] + balanceOf[_to];  // 校验避免过程出错, 总量不变对吧
        balanceOf[_from] -= _value; //发钱 
        balanceOf[_to] += _value;
        emit Transfer(_from, _to, _value);   // 这里触发了转账的事件 , 见上event
        assert(balanceOf[_from] + balanceOf[_to] == previousBalances);  // 判断总额是否一致, 避免过程出错
    }

    function transfer(address _to, uint256 _value) public {
        _transfer(msg.sender, _to, _value); 
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require(_value <= allowance[_from][msg.sender]);     // 地址对应的合约地址(也就是token余额)
        allowance[_from][msg.sender] -= _value;
        _transfer(_from, _to, _value);
        return true;
    }


    function approve(address _spender, uint256 _value) public
        returns (bool success) {
        emit Approval(msg.sender, _spender, _value);
        allowance[msg.sender][_spender] = _value;   // 可花费总量
        return true;
    }


    function increaseApproval (address _spender, uint _value)public 
        returns (bool success) {
        require(allowance[msg.sender][_spender] + _value >=allowance[msg.sender][_spender]);
        allowance[msg.sender][_spender] += _value;
        emit Approval(msg.sender, _spender,allowance[msg.sender][_spender]);
        return true;
    }
    function decreaseApproval (address _spender, uint _value)public 
        returns (bool success) {
        if (_value > allowance[msg.sender][_spender]) {
            allowance[msg.sender][_spender] = 0;
        } else {
            allowance[msg.sender][_spender] -= _value;
        }
        emit Approval(msg.sender, _spender,allowance[msg.sender][_spender]);
        return true;
    }


    function approveAndCall(address _spender, uint256 _value, bytes _extraData) public returns (bool success) {
        tokenRecipient spender = tokenRecipient(_spender);
        if (approve(_spender, _value)) {
            spender.receiveApproval(msg.sender, _value, this, _extraData);
            return true;
        }
    }
    // 用于把创建者的 token 烧掉
    function burn(uint256 _value) public returns (bool success) {
        require(balanceOf[msg.sender] >= _value);   // 必须要有这么多
        balanceOf[msg.sender] -= _value;
        totalSupply -= _value;
        emit Burn(msg.sender, _value);
        return true;
    }
    // 这个是用户销毁token.....
    function burnFrom(address _from, uint256 _value) public returns (bool success) {
        require(balanceOf[_from] >= _value);        // 一样要有这么多
        require(_value <= allowance[_from][msg.sender]);    // 
        balanceOf[_from] -= _value;
        allowance[_from][msg.sender] -= _value;
        totalSupply -= _value;
        emit Burn(_from, _value);
        return true;
    }
}