pragma solidity >=0.4.22 <0.6.0;

interface tokenRecipient {
    function receiveApproval(address _from, uint256 _value, address _token, bytes calldata _extraData) external;
}
contract AssToken{
    //公共变量
    string public name;//代币名称
    string public symbol;//代币符号
    uint8 public decimals = 18;//小数点位数
    uint256 public totalSupply;  //代币发行总量

    //创建一个包含所有余额的数组
    mapping (address => uint256) public balanceOf;  //保存所有账户的代币余额的数组
    mapping (address => mapping (address => uint256)) public allowance;   //嵌套的数组来保存授权账户、被授权账户和授权额度

    //在区块链上生成一个公共事件，该事件将通知客户端
    event Transfer(address indexed from, address indexed to, uint256 value);    //每次转账成功后都必须触发该事件
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);   //将在区块链上生成一个公共事件，每次进行授权，都必须触发该事件。参数为：授权人、被授权人和授权额度
    event Burn(address indexed from, uint256 value);    //关于上涨的客户通知
    /**
     * 构造函数初始化契约，
     * 将初始供应令牌提供给契约的创建者
    */
    constructor(
        uint256 initialSupply,//发行总量
        string memory tokenName,//代币名称
        string memory tokenSymbol//代币符号
    ) public {
        totalSupply = initialSupply * 10 ** uint256(decimals);  // 用十进制数字更新总供应量
        balanceOf[msg.sender] = totalSupply;                // 给创建者所有初始令牌
        name = tokenName;                                   // 代币名称
        symbol = tokenSymbol;                               // 代币符号
    }
    /**
     * 内部转账，只能按本合同调用
     */
    function _transfer(address _from, address _to, uint _value) internal {
        // 防止传输到无效地址。改用burn（）
        require(_to != address(0x0));
        // 检查账号余额是否大于转账金额
        require(balanceOf[_from] >= _value);
        // 检查转账金额是否正常
        require(balanceOf[_to] + _value >= balanceOf[_to]);
        // 保存余额状态
        uint previousBalances = balanceOf[_from] + balanceOf[_to];
        // Subtract from the sender
        balanceOf[_from] -= _value;
        // Add the same to the recipient
        balanceOf[_to] += _value;
        emit Transfer(_from, _to, _value);
        // Asserts are used to use static analysis to find bugs in your code. They should never fail
        assert(balanceOf[_from] + balanceOf[_to] == previousBalances);
    }
    /**
     * 转账操作，将指定数量的代币从总账户发送到另一个账户
     *
     * Send `_value` tokens to `_to` from your account
     *
     * @param _to The address of the recipient
     * @param _value the amount to send
     */
    function transfer(address _to, uint256 _value) public returns (bool success) {
        _transfer(msg.sender, _to, _value);
        return true;
    }
    /**
     * 转账操作，用户转给用户
     *
     * Send `_value` tokens to `_to` on behalf of `_from`
     *
     * @param _from The address of the sender
     * @param _to The address of the recipient
     * @param _value the amount to send
     */
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require(_value <= allowance[_from][msg.sender]);     // 检查转账金额不能小于手续费
        allowance[_from][msg.sender] -= _value; //先扣除转账方的手续费
        _transfer(_from, _to, _value);
        return true;
    }
    /**
     * 给转账用户设置手续费
     *
     * Allows `_spender` to spend no more than `_value` tokens on your behalf
     *
     * @param _spender The address authorized to spend
     * @param _value the max amount they can spend
     */
    function approve(address _spender, uint256 _value) public
        returns (bool success) {
        allowance[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }
    /**
     * 获取到账户地址和 手续费的通知
     *
     * Allows `_spender` to spend no more than `_value` tokens on your behalf, and then ping the contract about it
     *
     * @param _spender The address authorized to spend
     * @param _value the max amount they can spend
     * @param _extraData some extra information to send to the approved contract
     */
    function approveAndCall(address _spender, uint256 _value, bytes memory _extraData)
        public
        returns (bool success) {
        tokenRecipient spender = tokenRecipient(_spender);
        if (approve(_spender, _value)) {
            spender.receiveApproval(msg.sender, _value, address(this), _extraData);
            return true;
        }
    }
    /**
     * 减少代币总余额
     *
     * Remove `_value` tokens from the system irreversibly
     *
     * @param _value the amount of money to burn
     */
    function burn(uint256 _value) public returns (bool success) {
        require(balanceOf[msg.sender] >= _value);   // Check if the sender has enough
        balanceOf[msg.sender] -= _value;            // Subtract from the sender
        totalSupply -= _value;                      // Updates totalSupply
        emit Burn(msg.sender, _value);
        return true;
    }
    /**
     * 减少用户余额
     *
     * Remove `_value` tokens from the system irreversibly on behalf of `_from`.
     *
     * @param _from the address of the sender
     * @param _value the amount of money to burn
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
    //查询指定账户地址的代币余额
    function balanceTo(address _owner) public view returns (uint256 balance){
        return balanceOf[_owner];
    }
     //查询指定账户的手续费
    function allowed(address _owner,address _spender) public view returns (uint256 remaining){
        return allowance[_owner][_spender];
    }
}