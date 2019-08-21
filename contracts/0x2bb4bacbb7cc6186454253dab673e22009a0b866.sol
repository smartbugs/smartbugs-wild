//写这个合约的目的，就是为了方便大家快速的进行ETH和IFS之间的兑换
//合约的基本原理和注释，本合约都会写的非常详细，以方便大家进行监督和信任
//整个合约的逻辑非常简单：
//1.用户给本合约打ETH，最小单位为0.01ETH，每0.01ETH，合约会给用户打币过来的地址发送200的IFS Token回去
//2.小于0.01ETH的部分，合约会给找回。IFS的数量是另外一个账户授权给当前合约的，如果授权数量不足，则合约会失败，用户打过来的ETH也会直接被返回，交易失败

//IFS使用场景：
//官网：https://www.fanstime.org/
//APP  Fanstime
//Fanstime是一家在线明星交易的交易所，可以购买各个明星的时间，等待价格上涨或者是进行行权
//IFS是Fanstime中的通用货币，与人民币有10:1(即每个IFS价格为1毛钱)的固定兑换率。官方有庞大的资金池保证汇率的稳定


//                   _ooOoo_
//                  o8888888o
//                  88" . "88
//                  (| -_- |)
//                  O\  =  /O
//               ____/`---'\____
//             .'  \\|     |//  `.
//            /  \\|||  :  |||//  \
//           /  _||||| -:- |||||-  \
//           |   | \\\  -  /// |   |
//           | \_|  ''\---/''  |   |
//           \  .-\__  `-`  ___/-. /
//         ___`. .'  /--.--\  `. . __
//      ."" '<  `.___\_<|>_/___.'  >'"".
//     | | :  ` - `.;`\ _ /`;.`/ - ` : | |
//     \  \ `-.   \_ __\ /__ _/   .-` /  /
//======`-.____`-.___\_____/___.-`____.-'======
//                   `=---='
//^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
//        [佛祖保佑]兑换IFS入场的都赚大钱



//按照当前ETH价格1400左右计算，本合约IFS价格为七折优惠哦~


//********************************************************************************
//*
//*
//*
//*             如果你不相信本合约，完全可以先用0.01ETH（才十来块钱）
//*
//*                             兑换一次
//*
//*                     去App里面使用一下，你就明白了
//*
//*
//*
//********************************************************************************





//注意事项：
//1.不要从交易所直接对本合约提币！！！不要从交易所直接对本合约提币！！！不要从交易所直接对本合约提币！！！
pragma solidity ^0.4.25;
contract Token {
    function totalSupply() constant returns (uint256 supply) {}
    function balanceOf(address _owner) constant returns (uint256 balance) {}
    function transfer(address _to, uint256 _value) returns (bool success) {}
    function transferFrom(address _from, address _to, uint256 _value) returns (bool success) {}
    function approve(address _spender, uint256 _value) returns (bool success) {}
    function allowance(address _owner, address _spender) constant returns (uint256 remaining) {}
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}

contract TokenExchange{

    uint256 public minETHExchange = 10000000000000000;//最小兑换单位（0.01ETH）
    uint256 public TokenCountPer = 200000000000000000000;//每0.01ETH可兑换200IFS
    address public tokenAddress = address(0x5d47D55b33e067F8BfA9f1955c776B5AddD8fF17);//IFS的Token地址
    address public fromAddress = address(0xfA25eC30ba33742D8d5E9657F7d04AeF8AF91F40);//持有IFS的地址，用于出币到用户手中
    address public owner = address(0x8cddc253CA7f0bf51BeF998851b3F8E41053B784);//最终收获ETH的地址
    Token _token = Token(tokenAddress);//实例化IFS的合约

    function() public payable {
        require(msg.value >= minETHExchange);//检查支付的ETH数量不能小于0.01ETH
        uint256 count = 0;
        count = msg.value / minETHExchange;//计算可以购买多少份

        uint256 remianETH = msg.value - (count * minETHExchange);//计算找零
        uint256 tokenCount = count * TokenCountPer;//计算可兑换IFS数量

        if(remianETH > 0){//如果找零数量大于0的话，则进行找零
            tx.origin.transfer(remianETH);
        }
        require(_token.transferFrom(fromAddress,tx.origin,tokenCount));//使用IFS的合约给交易发起者发放IFS
        owner.transfer(address(this).balance);
    }
}