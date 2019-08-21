pragma solidity ^0.4.16;

interface tokenRecipient { function receiveApproval(address _from, uint256 _value, address _token, bytes _extraData) public; }

//创建一个owned合约
contract owned {

				//定义一个变量"owner"，这个变量的类型是address，这是用于存储代币的管理者。
				//owned()类似于C++中的构造函数，功能是给owner赋值。
        address public owner;

        function owned() {
            owner = msg.sender;
        }

				//定义一个modifier(修改标志)，可以理解为函数的附属条件。
				//这个条件的内容是假设发送者不是owner（管理者），就跳出。起到一个身份鉴别的作用。
        modifier onlyOwner {
            require(msg.sender == owner);
            _;
        }

        //实现所有权转移
        //定义一个transferOwnership函数，这个函数是用于转移管理者的身份。
        //注意，transferOwnership后面跟着"onlyOwner"。所以这个函数的前提是，执行人必须是owner。
        function transferOwnership(address newOwner) onlyOwner {
            owner = newOwner;
        }
}

//创建一个ERC20代币
contract TokenERC20 is owned {
    string public name;
    string public symbol;
    uint8 public decimals = 18;  // 18 是建议的默认值
    uint256 public totalSupply;

    mapping (address => uint256) public balanceOf;  // 
    mapping (address => mapping (address => uint256)) public allowance;

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Burn(address indexed from, uint256 value);

    function TokenERC20(
    		uint256 initialSupply, 
    		string tokenName, 
    		string tokenSymbol,
    		//在TokenERC20中添加了地址变量centralMinter，这个变量是有输入位置的。
    		address centralMinter
    		) public {
        totalSupply = initialSupply * 10 ** uint256(decimals);
        balanceOf[msg.sender] = totalSupply;
        name = tokenName;
        symbol = tokenSymbol;
        //if从句，只要输入地址不为0，拥有者就是发送者，所以这里输入什么都没关系。这个if从句，目前没看到有什么用处。
        if(centralMinter != 0 ) owner = centralMinter;
    }
    
    //代币增发
    //代码解释:
		//第2句代码给指定目标增加代币数量；
		//第3句代码给代币总量增加相应的数目；
		//第4句和第5句代码的意义只是提醒客户端发生了这样的交易。
		function mintToken(address target, uint256 mintedAmount) onlyOwner {
        balanceOf[target] += mintedAmount;
        totalSupply += mintedAmount;
        Transfer(0, owner, mintedAmount);
        Transfer(owner, target, mintedAmount);
		}

    function _transfer(address _from, address _to, uint _value) internal {
        require(_to != 0x0);
        require(balanceOf[_from] >= _value);
        require(balanceOf[_to] + _value > balanceOf[_to]);
        uint previousBalances = balanceOf[_from] + balanceOf[_to];
        balanceOf[_from] -= _value;
        balanceOf[_to] += _value;
        Transfer(_from, _to, _value);
        assert(balanceOf[_from] + balanceOf[_to] == previousBalances);
    }

    function transfer(address _to, uint256 _value) public {
        _transfer(msg.sender, _to, _value);
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require(_value <= allowance[_from][msg.sender]);     // Check allowance
        allowance[_from][msg.sender] -= _value;
        _transfer(_from, _to, _value);
        return true;
    }

    function approve(address _spender, uint256 _value) public
        returns (bool success) {
        allowance[msg.sender][_spender] = _value;
        return true;
    }

    function approveAndCall(address _spender, uint256 _value, bytes _extraData) public returns (bool success) {
        tokenRecipient spender = tokenRecipient(_spender);
        if (approve(_spender, _value)) {
            spender.receiveApproval(msg.sender, _value, this, _extraData);
            return true;
        }
    }

    function burn(uint256 _value) public returns (bool success) {
        require(balanceOf[msg.sender] >= _value);
        balanceOf[msg.sender] -= _value;
        totalSupply -= _value;
        Burn(msg.sender, _value);
        return true;
    }

    function burnFrom(address _from, uint256 _value) public returns (bool success) {
        require(balanceOf[_from] >= _value);
        require(_value <= allowance[_from][msg.sender]);
        balanceOf[_from] -= _value;
        allowance[_from][msg.sender] -= _value;
        totalSupply -= _value;
        Burn(_from, _value);
        return true;
    }
}