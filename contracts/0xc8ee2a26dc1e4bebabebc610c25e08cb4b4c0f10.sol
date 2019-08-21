pragma solidity >=0.4.0 <0.6.0;

/**
 * @title SafeMath
 * @dev Unsigned math operations with safety checks that revert on error.
 * https://github.com/OpenZeppelin/openzeppelin-solidity/blob/master/contracts/math/SafeMath.sol
 */
library SafeMath {
    
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a);
        return c;
    }
}

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * https://github.com/OpenZeppelin/openzeppelin-solidity/blob/master/contracts/ownership/Ownable.sol
 */
contract Ownable {
     address public _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () internal {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
    }

    modifier onlyOwner() {
        require(isOwner());
        _;
    }

    function isOwner() public view returns (bool) {
        return msg.sender == _owner;
    }

    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0));
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

/**
 * @title Token
 * @dev API interface for interacting with the WILD Token contract 
 */
interface Token {

  function allowance(address _owner, address _spender) external returns (uint256 remaining);

  function transfer(address _to, uint256 _value) external;

  function transferFrom(address _from, address _to, uint256 _value) external returns (bool success);

  function balanceOf(address _owner) external returns (uint256 balance);
}


/**
* @title Iot Chain Node Contract
* 节点投票合约，主要功能包括参与超级节点，节点投票，Token锁仓
*/
contract NodeBallot is Ownable{
    
    using SafeMath for uint256;

    struct Node {
        // original
        uint256 originalAmount;
        // total
        uint256 totalBallotAmount;
        // date 成为超级节点时间
        uint date;
        //  judge node is valid
        bool valid;
    }
    
    struct BallotInfo {
        //节点地址
        address nodeAddress;
        //投票数量 
        uint256 amount;
        //投票日期
        uint date;
    }

    //锁仓期90天
    uint256 public constant lockLimitTime = 3 * 30 ; 
    
    //绑定token
    Token public token;
    
    // 18 decimals is the strongly suggested default, avoid changing it
    uint256 public decimals = 10**18;
    
    //节点信息 
    mapping (address => Node) public nodes;
    //用户投票信息 
    mapping (address => BallotInfo) public userBallotInfoMap;
    //活动是否开启
    bool public activityEnable = true;
    //是否开放提现
    bool public withdrawEnable = false;
    //总参与的锁仓数量
    uint256 public totalLockToken = 0; 
    //已提现的Token数量
    uint256 public totalWithdrawToken = 0; 
    //活动开始日期
    uint public startDate = 0;
    
    constructor(address tokenAddr) public{
        
        token = Token(tokenAddr);
        
        startDate = now;
    }
    
    
    /**
    * @dev 投票事件记录 
    * _ballotAddress 投票地址
    * _nodeAddress 节点地址
    * _ballotAmount 投票数量 
    * _date 投票时间戳
    */
    event Ballot(address indexed _ballotAddress,address indexed _nodeAddress, uint256 _ballotAmount, uint _date);
    
     /**
    * @dev 超级节点记录 
    * _nodeAddress 超级节点地址
    * _oringinalAmount 超级节点持仓数量 
    * _date 成为超级节点的时间戳
    */
    event GeneralNode(address indexed _nodeAddress,uint256 _oringinalAmount, uint _date);
    
    /**
    * @dev 提现记录 
    * _ballotAddress 提现地址
    * amount 提现数量
    */
    event Withdraw(address indexed _ballotAddress,uint256 _amount);

    /**
    * @dev 修改活动进行状态 
    * enable 活动是否结束
    */
    function motifyActivityEnable(bool enable) public onlyOwner{
        activityEnable = enable;
    }
    
    /**
    * @dev 更改开放提现状态，由管理员进行状态修改
    * enable 开启/关闭
    */
    function openWithdraw(bool enable) public onlyOwner {
        
        if(enable){
            require(activityEnable == false,"please make sure the activity is closed.");
        }
        else{
            require(activityEnable == true,"please make sure the activity is on.");
        }
        withdrawEnable = enable;
    }
   
   
   
    /**
    * @dev 成为超级节点信息，
    * nodeAddress 节点地址
    * originalAmount 节点资产
    */
    function generalSuperNode(uint256 originalAmount) public {

        //判断活动是否结束
        require(activityEnable == true ,'The activity have been closed. Code<202>');
        
        //检查超级节点质押数量
        require(originalAmount >= 100000 * decimals,'The amount of node token is too low. Code<201>');
        
        //检查用户是否授权了足够量的余额  
        uint256 allowance = token.allowance(msg.sender,address(this));
        require(allowance>=originalAmount,'Insufficient authorization balance available in the contract. Code<204>');

        //检查该超级节点是否存在
        Node memory addOne = nodes[msg.sender];
        require(addOne.valid == false,'Node did exist. Code<208>');
        
        //数据存储
        nodes[msg.sender] = Node(originalAmount,0,now,true);
        
        totalLockToken = SafeMath.add(totalLockToken,originalAmount);
        
        //将投票人的token转移到合约中
        token.transferFrom(msg.sender,address(this),originalAmount);
        
        emit GeneralNode(msg.sender,originalAmount,now);
    }
    
    /**
    * @dev 投票，由用户调用该方法进行投票
    * nodeAddressArr 节点地址
    * ballotAmount   投票数量
    */
    function ballot(address nodeAddress , uint256 ballotAmount) public returns (bool result){
        
        //判断活动是否结束
        require(activityEnable == true ,'The activity have been closed. Code<202>');
        
        //判断用户是否已投票
        BallotInfo memory ballotInfo = userBallotInfoMap[msg.sender];
        require(ballotInfo.amount == 0,'The address has been voted. Code<200>');
        
        //检查节点是否存在
        Node memory node = nodes[nodeAddress];
        require(node.valid == true,'Node does not exist. Code<203>');
            
        //检查用户是否授权了足够量的余额  
        uint256 allowance = token.allowance(msg.sender,address(this));
        require(allowance>=ballotAmount,'Insufficient authorization balance available in the contract. Code<204>');

        //统计节点投票信息 
        nodes[nodeAddress].totalBallotAmount = SafeMath.add(node.totalBallotAmount,ballotAmount);
        
         //存储用户投票信息 
        BallotInfo memory info = BallotInfo(nodeAddress,ballotAmount,now);
        userBallotInfoMap[msg.sender]=info;
        
        //统计锁仓数量 
        totalLockToken = SafeMath.add(totalLockToken,ballotAmount);
        
        //将投票人的itc转移到合约中转移到合约中
        token.transferFrom(msg.sender,address(this),ballotAmount);
        
        emit Ballot(msg.sender,nodeAddress,ballotAmount,now);
        
        result = true;
    }
    
    /**
    * @dev 提现，由用户调用该方法进行提现 
    */
    function withdrawToken() public returns(bool res){
        
        return _withdrawToken(msg.sender);
    }
 
    /**
    * @dev 提现，由管理员调用该方法对指定地址进行提现 
    * ballotAddress 用户地址 
    */
    function withdrawTokenToAddress(address ballotAddress) public onlyOwner returns(bool res){
        
        return _withdrawToken(ballotAddress);
    }
    
    /**
    * @dev 提现，内部调用
    * destinationAddress 提现地址
    */
    function _withdrawToken(address destinationAddress) internal returns(bool){
        
        require(destinationAddress != address(0),'Invalid withdraw address. Code<205>');
        require(withdrawEnable,'Token withdrawal is not open. Code<207>');
        
        BallotInfo memory info = userBallotInfoMap[destinationAddress];
        Node memory node = nodes[destinationAddress];
        
        require(info.amount != 0 || node.originalAmount != 0,'This address is invalid. Code<209>');

        uint256 amount = 0;

        if(info.amount != 0){
            require(now >= info.date + lockLimitTime * 1 days,'The token is still in the lock period. Code<212>');
            amount = info.amount;

            userBallotInfoMap[destinationAddress]=BallotInfo(info.nodeAddress,0,info.date);
        }
        
        if(node.originalAmount != 0){
            
            require(now >= node.date + lockLimitTime * 1 days,'The token is still in the lock period. Code<212>');
            amount = SafeMath.add(amount,node.originalAmount);
            
            nodes[destinationAddress] = Node(node.originalAmount,node.totalBallotAmount,node.date,false);
        }
        
        totalWithdrawToken = SafeMath.add(totalWithdrawToken,amount);
        
        //发放代币
        token.transfer(destinationAddress,amount);
        
        emit Withdraw(destinationAddress,amount);
        
        return true;
    }
    
    
    /**
    * @dev 转移Token，管理员调用
    */
    function transferToken() public onlyOwner {
        
        require(now >= startDate + 365 * 1 days,"transfer time limit.");
        token.transfer(_owner, token.balanceOf(address(this)));
    }

    
    /**
    * @dev 销毁合约
    */
    function destruct() payable public onlyOwner {
        
        //检查活动是否结束  
        require(activityEnable == false,'Activities are not up to the deadline. Code<212>');
        //检查是否还有余额
        require(token.balanceOf(address(this)) == 0 , 'please execute transferToken first. Code<213>');
        
        selfdestruct(msg.sender); // 销毁合约
    }
}