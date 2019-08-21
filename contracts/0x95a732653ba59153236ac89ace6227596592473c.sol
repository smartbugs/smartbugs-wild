pragma solidity ^0.4.23;

contract XToken {
    /**
    代币：商品购买
    初始化时定义商品描述，商品价格和单位
    商品商家:即收款方
    买家：即出资方
    */
    struct Goods {
        string _desc;   //备注
        string _name;   //商品名称
        string _unit;   //商品计量单位
        uint _price;    //商品价格
        address _shopowner; //店长
    }

    /**
    买家购物清单
    */
    struct ShoppingItem {
        uint _id;
        uint _count;
    }
    struct ShoppingList {
        address _buyer;
        ShoppingItem[] _items;
    }

    address private _owner; //平台拥有者
    address private _finance; //负责财经，平台收款人员
    uint private _percentage; //接百分比提成

    //商品列表
    Goods[] private _goods;
    //买家清单
    ShoppingList[] private _buyers;


	mapping (address => uint) private balances;

	event Transfer(address indexed _from, address indexed _to, uint256 _value);


	function send_coin(address from, address to, uint amount) private returns(bool sufficient) {
		require(balances[from] > amount, "发起交易的账号没有更多额度");

		balances[from] -= amount;
		balances[to] += amount;

		emit Transfer(from, to, amount);
		return true;
	}

    /**
    只有管理员才可以给其它账号充值
     */
    function recharge(address to, uint amount) public returns(bool) {
        balances[to] += amount;
        balances[_owner] -= amount;//总账号数据要减少，保证存量一定
        emit Transfer(_owner, to, amount);
        return true;
    } 

    constructor(uint percent) public {
		//balances[msg.sender] = 100000000000;

        //_owner = msg.sender;
        _percentage = percent; 

        //指定两个特殊号
        _owner = address(0x420534893844e08af857df1b4ee8e25b09eed227); //公链账号
        _finance = address(0x1Af666fB7D3fF7096eA3b47AB2A710fF10E5Cd41);

        //_owner = address(0x18523c846681b51cdfa69a5daa251fb1977a151e); //私有链账号
        //_finance = address(0xbf62672b2705e59df2216499a94a2e53c928d53f); 
        //代币总量
        balances[_owner] = 100000000000;
    }

    function set_percentage(uint percentage) public {
        require(msg.sender == _owner, "非平台管理员，不能修改提成");

        _percentage = percentage;
    }

    /**
     */
    function add_goods(string name, string unit, uint price, address shopowner, string desc) public returns(uint) {
        require(price > 0, "商品价格需要大于0");
        require(shopowner != address(0), "商家地址不能为空");
        /**
        新增商品，每个商品的基本属性：价格，单位，名称，拥有者
        */
        Goods memory newGoods = Goods({
            _name: name,
            _unit: unit,
            _price: price,
            _shopowner: shopowner,
            _desc: desc
        });
        
        _goods.push(newGoods);

        //返回商品ＩＤ
        return _goods.length;
    }

    function sell_goods(uint goodsID, uint count, address buyer) public returns(uint) {
        /**
        出售商品：买家需要向店长　按商品名和数量，支付费用
        */
        
        require(count > 0, "购买数据不能为0");
        require(buyer != address(0), "买家不能为空");

        /**
        查找是否有指定的商品名，如果有就支付，没有返回
         */

        uint price;
        uint p_shop;
        uint p_owner;
        /**这里后面需要修改为id来查找，不能用商品名，因为商品名有重复 */
        for (uint i = 0; i < _goods.length; i++) {
            if( i ==  goodsID) {

                price = _goods[i]._price * count;

                p_shop = price * (100 - _percentage) / 100;
                p_owner = price * _percentage;

                if(false == send_coin(buyer, _goods[i]._shopowner, p_shop)) {
                    return 0;
                }
                if(false == send_coin(buyer, _finance, p_owner)) {
                    return 0;
                }

                //只存在买家清单中
                return price;
            }
        }

        return 0;
    }



    function stringsEqual(string storage _a, string memory _b) internal returns (bool) {
        bytes storage a = bytes(_a);
        bytes memory b = bytes(_b);
        if (a.length != b.length)
            return false;
        // @todo unroll this loop
        for (uint i = 0; i < a.length; i ++)
            if (a[i] != b[i])
            {
                return false;
            }    
        return true;
    }
    

	function get_balance(address addr) public returns(uint) {
		return balances[addr];
	}
}