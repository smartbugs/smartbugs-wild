pragma solidity 0.4.18;
/**
 * 一个简单的代币合约。
 */
 contract FAMELINK{

     string public name; //代币名称
     string public symbol; //代币符号比如'$'
     uint8 public decimals = 18;  //代币单位，展示的小数点后面多少个0,和以太币一样后面是是18个0
     uint256 public totalSupply; //代币总量
     /* This creates an array with all balances */
     mapping (address => uint256) public balanceOf;

     event Transfer(address indexed from, address indexed to, uint256 value);  //转帐通知事件


     /* 初始化合约，并且把初始的所有代币都给这合约的创建者
      * @param _owned 合约的管理者
      * @param tokenName 代币名称
      * @param tokenSymbol 代币符号
      */
     function FAMELINK(uint256 initialSupply,address _owned, string tokenName, string tokenSymbol) public{
          totalSupply = initialSupply * 10 ** uint256(decimals);  // 用小数位来初始化总量
         //合约的管理者获得的代币总量
         balanceOf[_owned] = totalSupply;
         name = tokenName;
         symbol = tokenSymbol;

     }
     

     /**
      * 转帐，具体可以根据自己的需求来实现
      * @param  _to address 接受代币的地址
      * @param  _value uint256 接受代币的数量
      */
     function transfer(address _to, uint256 _value) public{
       //从发送者减掉发送额
       balanceOf[msg.sender] -= _value;

       //给接收者加上相同的量
       balanceOf[_to] += _value;

       //通知任何监听该交易的客户端
       Transfer(msg.sender, _to, _value);
     }


  }