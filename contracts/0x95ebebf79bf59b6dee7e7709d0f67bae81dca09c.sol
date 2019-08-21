pragma solidity >=0.4.22 <0.6.0;

contract BWSERC20
{
    string public standard = 'https://leeks.cc';
    string public name="Bretton Woods system"; //代币名称
    string public symbol="BWS"; //代币符号
    uint8 public decimals = 18;  //代币单位，展示的小数点后面多少个0,和以太币一样后面是是18个0
    uint256 public totalSupply=100000000 ether; //代币总量
    
    address st_owner;
    address st_owner1;

    uint256 public st_bws_pool;//币仓
    uint256 public st_ready_for_listing;//准备上市　
    bool st_unlock_owner=false;
    bool st_unlock_owner1=false;
    address st_unlock_to;
    address st_unlock_to1;
    
    mapping (address => uint256) public balanceOf;
    mapping (address => mapping (address => uint256)) public allowance;
    mapping (address => uint32) public CredibleContract;//可信任的智能合约，主要是后期的游戏之类的
    /* 在区块链上创建一个事件，用以通知客户端*/
    event Transfer(address indexed from, address indexed to, uint256 value);  //转帐通知事件
    event Burn(address indexed from, uint256 value);  //减去用户余额事件
    
    
    constructor (address owner1)public
    {
        st_owner=msg.sender;
        st_owner1=owner1;
        
        st_bws_pool = 70000000 ether;
        st_ready_for_listing = 14000000 ether;
        
        balanceOf[st_owner]=8000000 ether;
        balanceOf[st_owner1]=8000000 ether;
    }
    
    function _transfer(address _from, address _to, uint256 _value) internal {

      //避免转帐的地址是0x0
      require(_to != address(0x0));
      //检查发送者是否拥有足够余额
      require(balanceOf[_from] >= _value);
      //检查是否溢出
      require(balanceOf[_to] + _value > balanceOf[_to]);
      //保存数据用于后面的判断
      uint previousBalances = balanceOf[_from] + balanceOf[_to];
      //从发送者减掉发送额
      balanceOf[_from] -= _value;
      //给接收者加上相同的量
      balanceOf[_to] += _value;
      //通知任何监听该交易的客户端
      emit Transfer(_from, _to, _value);
      //判断买、卖双方的数据是否和转换前一致
      assert(balanceOf[_from] + balanceOf[_to] == previousBalances);
    }
    
    function transfer(address _to, uint256 _value) public {
        _transfer(msg.sender, _to, _value);
    }
    
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success){
        //检查发送者是否拥有足够余额
        require(_value <= allowance[_from][msg.sender]);   // Check allowance

        allowance[_from][msg.sender] -= _value;

        _transfer(_from, _to, _value);

        return true;
    }
    
    function approve(address _spender, uint256 _value) public returns (bool success) {
        
        allowance[msg.sender][_spender] = _value;
        return true;
    }
    
    //管理员可以解锁1400万币到指定地址
    function unlock_listing(address _to) public
    {
        require(_to != address(0x0),"参数中传入了空地址");
        //解锁1400万，需要两个管理员同时解锁才行
        if(msg.sender==st_owner)
        {
            st_unlock_owner=true;
            st_unlock_to=_to;
        }
        else if(msg.sender==st_owner1)
        {
            st_unlock_owner1=true;
            st_unlock_to1=_to;
        }
        
        if(st_unlock_owner =true && st_unlock_owner1==true && st_unlock_to !=address(0x0) && st_unlock_to==st_unlock_to1)
        {
            //满足了解锁条件
            if(st_ready_for_listing==14000000 ether)
                {
                    st_ready_for_listing=0;
                    balanceOf[_to]+=14000000 ether;
                }
            
        }
    }
    //管理员指定可信的合约地址，这些地址可以进行一些敏感操作，比如从币仓取走股币发放给指定玩家
    function set_CredibleContract(address tract_address) public
    {
        require(tract_address != address(0x0),"参数中传入了空地址");
        //需要两个管理员同时设置才行
        if(msg.sender==st_owner)
        {
            if(CredibleContract[tract_address]==0)CredibleContract[tract_address]=2;
            else if(CredibleContract[tract_address]==3)CredibleContract[tract_address]=1;
        }
        if(msg.sender==st_owner1 )
        {
            if(CredibleContract[tract_address]==0)CredibleContract[tract_address]=3;
            else if(CredibleContract[tract_address]==2)CredibleContract[tract_address]=1;
        }
    }
    
    //从币仓取出指定量的bws给指定玩家
    function TransferFromPool(address _to ,uint256 _value)public
    {
        require(CredibleContract[msg.sender]==1,"非法的调用");
        require(_value<=st_bws_pool,"要取出的股币数量太多");
        
        st_bws_pool-=_value;
        balanceOf[_to] +=_value;
        emit Transfer(address(this), _to, _value);
    }
}