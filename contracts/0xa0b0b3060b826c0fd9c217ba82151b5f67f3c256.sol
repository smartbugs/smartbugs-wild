pragma solidity >=0.4.22 <0.6.0;

contract ThreeLeeks {
    struct STR_NODE
        {
            address payable addr;
            uint32 ID;
            uint32 faNode;//父节点
            uint32 brNode;//兄弟节点
            uint32 chNode;//子节点
            uint256 Income;//获得的收入
            uint32 Subordinate;//总下级数
        }
    struct PRIZE_RECORD
    {
        address addr;//获得奖地址　
        uint32 NodeNumber;//获奖的Node编号
        uint256 EthGained;//获状金额
    }
    //有人加入产生事件  推荐人/加入人员的编号/加入时间
    event HaveAdd(uint32 Recommender,uint32 Number,uint64 Add_Time);
    //执行奖励 获奖人编号/获奖金额/奖励编号
    event OnReward(uint32 Awardee,uint256 PrizeMoney,uint32 PrizeNumber);
    
    mapping (uint32 => STR_NODE) private Node;//结点映射
    mapping (uint32 => PRIZE_RECORD)private PrizeRecord;
    uint32 NodeIndex;//当前映射
    uint32 PrizeIndex;//当前获奖记录
    uint64 NodeAddTime;//最后一次加入的时间
    bool IsDistribution;//奖池计时是否开始
    address payable ContractAddress;
    /* Initializes contract with initial supply tokens to the creator of the contract */
    constructor  () public {//构造方法
        NodeIndex=0;
        PrizeIndex=0;
        Node[0]=STR_NODE(msg.sender,0,0,0,0,0,0);
        NodeIndex=10;
        for (uint32 i=1;i<=10;i++)
        {
            Node[i]=STR_NODE(msg.sender,i,0,0,0,0,0);
        }
        ContractAddress=address(uint160(address(this)));
    }
  
    /*  本函数注入资金,Recommender是投资人的推荐人编号*/
    function CapitalInjection(uint32 Recommender)public payable
    {
        uint32 index;
        require(Recommender>=0 && Recommender<NodeIndex,"Recommenders do not exist");
        if(msg.value!=0.99 ether)
        {
            msg.sender.transfer(msg.value);
            emit HaveAdd(0,0,uint64(now));
            return ;
        }
        NodeAddTime=uint64(now);
        NodeIndex+=1;
        //奖池计时开始
        if(IsDistribution==true)IsDistribution=false;
        //把推荐人设为当前投资者的上线
        Node[NodeIndex]=STR_NODE(msg.sender,NodeIndex,Recommender,0,0,0,0);
            
        if(Node[Recommender].chNode<=0)//如果推荐人还没有下线
        {//把当前投资者设为推荐人的下线
            Node[Recommender].chNode=NodeIndex;
        }
        else//如果推荐人已经有了下线
        {
            index=Node[Recommender].chNode;
            while (Node[index].brNode>0)//循环查找直到推荐人的子节点没有兄弟节点
            {
                index=Node[index].brNode;
            }
            Node[index].brNode=NodeIndex;//把当前投资者设为推荐人的下线的兄弟
        }

        //到这里，已实现了节点上下线关系，开始转帐
        index=Node[NodeIndex].faNode;
        Node[index].addr.transfer(0.3465 ether);//直接上级提取0.999*35%
        Node[index].Income+=0.3465 ether;
        Node[index].Subordinate+=1;
        index=Node[index].faNode;
        for (uint32 i=0;i<10;i++)
        {
            Node[index].addr.transfer(0.0495 ether);//间接上级提取0.999*5%
            Node[index].Income+=0.0495 ether;
            if(index!=0) Node[index].Subordinate+=1;
            index=Node[index].faNode;//index指向父节点
        }
        Node[0].addr.transfer(0.0495 ether);
        
        //有人加入产生事件
        emit HaveAdd(Recommender,NodeIndex,NodeAddTime);
    }
    //本函数由部署者调用，用于准许部分人免费加入
    function FreeAdmission(address addr,uint32 index)public returns (bool)
    {
        //只能由部署者执行
        require (msg.sender==Node[0].addr,"This function can only be called by the deployer");
        //部署者也只能修改编号为前10的
        require (index>0 && index<=10,"Users who can only modify the first 10 numbers");
        //把指定地址设置给某个编号
        Node[index].addr=address(uint160(addr));
        return true;
    }
    //本函数返回奖池资金总额度
    function GetPoolOfFunds()public view returns(uint256)
    {
        return ContractAddress.balance;
    }
    //本函数返回自己的Index
    function GetMyIndex() public view returns(uint32)
    {
        for(uint32 i=0 ;i<=NodeIndex;i++)
        {    if(msg.sender==Node[i].addr)
            {
                return i;
            }
        }
        return 0;
    }
    //返回我的总收入
    function GetMyIncome() public view returns(uint256)
    {
        uint32 ret=GetMyIndex();
        return Node[ret].Income;
    }
    //返回我的推荐人
    function GetMyRecommend() public view returns(uint32)
    {
        uint32 ret=GetMyIndex();
        return Node[ret].faNode;
    }
    //返回我的下级总人数
    function GetMySubordinateNumber(uint32 ID)public view returns(uint32)
    {
        uint32 index;
        if(ID>0 && ID<=NodeIndex)
        {
            index=ID;
        }
        else
            {index=GetMyIndex();}
        return Node[index].Subordinate;
    }
    //返回直接下级数
    function GetMyRecommendNumber(uint32 ID)public view returns(uint32)
    {
        uint32 index;
        if(ID>0 && ID<=NodeIndex)
        {
            index=ID;
        }
        else
            {index=GetMyIndex();}
        uint32 Number;
        if(Node[index].chNode>0)
        {
            Number=1;
            index=Node[index].chNode;
            while (Node[index].brNode>0)
            {
                Number++;
                index=Node[index].brNode;
            }
        }
    return Number;
    }
    //返回总人数
    function GetAllPeopleNumber()public view returns(uint32)
    {
        return NodeIndex;
    }
    //分配资金池50%的资金到最后账户
    function DistributionMoney() public payable
    {
        require(ContractAddress.balance>0,"There is no capital in the pool.");
        if(IsDistribution==false && now-NodeAddTime>86400)
        {
            IsDistribution=true;
            Node[NodeIndex].addr.transfer((ContractAddress.balance)/2);
            Node[NodeIndex].Income+=ContractAddress.balance;
            PrizeRecord[PrizeIndex]=PRIZE_RECORD(Node[NodeIndex].addr,NodeIndex,ContractAddress.balance);
            emit OnReward(NodeIndex,ContractAddress.balance,PrizeIndex);
            PrizeIndex++;
        }
    }
    //销毁合约
    function DeleteContract() public payable
    {
        require(msg.sender==Node[0].addr,"This function can only be called by the deployer");
        uint256 AverageMoney=ContractAddress.balance/NodeIndex;
        for (uint32 i=0;i<NodeIndex;i++)
        {
            Node[i].addr.transfer(AverageMoney);
        }
        selfdestruct(Node[0].addr);
        
    }
    //返回最后一个人加入时间
    function GetLastAddTime()public view returns(uint64)
    {
        return NodeAddTime;
    }

}