pragma solidity ^ 0.4.25;
contract owned {
    address public owner;
    constructor() public{
    owner = msg.sender;
    }
    /* modifier是修改标志 */
    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    /* 修改管理员账户， onlyOwner代表只能是用户管理员来修改 */
    function transferOwnership(address newOwner) onlyOwner public {
        owner = newOwner;
    }   
}

contract BTCC is owned{
    // 代币（token）的公共变量
    string public name;             //代币名字
    string public symbol;           //代币符号
    uint8 public decimals = 18;     //代币小数点位数， 18是默认， 尽量不要更改

    uint256 public totalSupply;     //代币总量
    uint256 public sellPrice = 1 ether;
    uint256 public buyPrice = 1 ether;

    /* 冻结账户 */
    mapping (address => bool) public frozenAccount;
    // 记录各个账户的代币数目
    mapping (address => uint256) public balanceOf;

    // A账户存在B账户资金
    mapping (address => mapping (address => uint256)) public allowance;

    // 转账通知事件
    event Transfer(address indexed from, address indexed to, uint256 value);

    // 销毁金额通知事件
    event Burn(address indexed from, uint256 value);
    /* This generates a public event on the blockchain that will notify clients */
    event FrozenFunds(address target, bool frozen);
    /* 构造函数 */
    constructor() public {
        totalSupply = 1000000000 ether;  // 根据decimals计算代币的数量
        balanceOf[msg.sender] = totalSupply;                    // 给生成者所有的代币数量
        name = 'BTCC';                                       // 设置代币的名字
        symbol = 'btcc';                                   // 设置代币的符号
        emit Transfer(this, msg.sender, totalSupply);
    }

    /* 私有的交易函数 */
    function _transfer(address _from, address _to, uint _value) internal {
        // 防止转移到0x0， 用burn代替这个功能
        require(_to != 0x0);
        require(!frozenAccount[_from]);                     // Check if sender is frozen
        require(!frozenAccount[_to]);                       // Check if recipient is frozen
        // 检测发送者是否有足够的资金
        require(balanceOf[_from] >= _value);
        // 检查是否溢出（数据类型的溢出）
        require(balanceOf[_to] + _value > balanceOf[_to]);
        // 将此保存为将来的断言， 函数最后会有一个检验
        uint previousBalances = balanceOf[_from] + balanceOf[_to];
        // 减少发送者资产
        balanceOf[_from] -= _value;
        // 增加接收者的资产
        balanceOf[_to] += _value;
        emit Transfer(_from, _to, _value);
        // 断言检测， 不应该为错
        assert(balanceOf[_from] + balanceOf[_to] == previousBalances);
    }

    /* 传递tokens */
    function transfer(address _to, uint256 _value) public {
        _transfer(msg.sender, _to, _value);
    }

    /* 从其他账户转移资产 */
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require(!frozenAccount[_from]);                     // Check if sender is frozen
        require(!frozenAccount[_to]);                       // Check if recipient is frozen
        require(_value <= allowance[_from][msg.sender]);     // Check allowance
        allowance[_from][msg.sender] -= _value;
        _transfer(_from, _to, _value);
        return true;
    }

    /*  授权第三方从发送者账户转移代币，然后通过transferFrom()函数来执行第三方的转移操作 */
    function approve(address _spender, uint256 _value) public
        returns (bool success) {
        allowance[msg.sender][_spender] = _value;
        return true;
    }

    /**
    * 销毁代币
    */
    function burn(uint256 _value) public returns (bool success) {
        require(balanceOf[msg.sender] >= _value);   // Check if the sender has enough
        balanceOf[msg.sender] -= _value;            // Subtract from the sender
        totalSupply -= _value;                      // Updates totalSupply
        emit Burn(msg.sender, _value);
        return true;
    }

    /**
    * 从其他账户销毁代币
    */
    function burnFrom(address _from, uint256 _value) public returns (bool success) {
        require(balanceOf[_from] >= _value);                // Check if the targeted balance is enough
        require(_value <= allowance[_from][msg.sender]);    // Check allowance
        balanceOf[_from] -= _value;                         // Subtract from the targeted balance
        allowance[_from][msg.sender] -= _value;             // Subtract from the sender's allowance
        totalSupply -= _value;                              // Update totalSupply
        emit Burn(_from, _value);
        return true;
    }
    // 冻结 or 解冻账户
    function freezeAccount(address target, bool freeze) onlyOwner public {
        frozenAccount[target] = freeze;
        emit FrozenFunds(target, freeze);
    }

    function setPrices(uint256 newSellPrice, uint256 newBuyPrice) onlyOwner public {
        sellPrice = newSellPrice;
        buyPrice = newBuyPrice;
    }

    /// @notice Buy tokens from contract by sending ether
    function buy() payable public {
        uint amount = msg.value / buyPrice;               // calculates the amount
        require(totalSupply >= amount);
        totalSupply -= amount;
        _transfer(this, msg.sender, amount);              // makes the transfers
    }

    function sell(uint256 amount) public {
        require(address(this).balance >= amount * sellPrice);      // checks if the contract has enough ether to buy
        _transfer(msg.sender, this, amount);              // makes the transfers
        msg.sender.transfer(amount * sellPrice);          // sends ether to the seller. It's important to do this last to avoid recursion attacks
    }
    // 向指定账户增发资金
    function mintToken(address target, uint256 mintedAmount) onlyOwner public {
        require(totalSupply >= mintedAmount);
        balanceOf[target] += mintedAmount;
        totalSupply -= mintedAmount;
        emit Transfer(this, target, mintedAmount);
    }
}