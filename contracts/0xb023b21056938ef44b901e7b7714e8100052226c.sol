pragma solidity 0.4.25;
/**
 * 外部调用外部代币。
 */
 interface token {
    function transfer(address receiver, uint amount) external;
}

/**
 * 众筹合约
 */
contract Crowdsale {
    address public beneficiary = msg.sender; //受益人地址，测试时为合约创建者
    uint public fundingGoal;  //众筹目标，单位是ether
    uint public amountRaised; //已筹集金额数量， 单位是ether
    uint public deadline; //截止时间
    uint public price;  //代币价格
    token public tokenReward;   // 要卖的token
    bool public fundingGoalReached = false;  //达成众筹目标
    bool public crowdsaleClosed = false; //众筹关闭


    mapping(address => uint256) public balance; //保存众筹地址及对应的以太币数量

    // 受益人将众筹金额转走的通知
    event GoalReached(address _beneficiary, uint _amountRaised);

    // 用来记录众筹资金变动的通知，_isContribution表示是否是捐赠，因为有可能是捐赠者退出或发起者转移众筹资金
    event FundTransfer(address _backer, uint _amount, bool _isContribution);

    /**
     * 初始化构造函数
     *
     * @param fundingGoalInEthers 众筹以太币总量
     * @param durationInMinutes 众筹截止,单位是分钟
     */
    constructor(
        uint fundingGoalInEthers,
        uint durationInMinutes,
        uint TokenCostOfEachether,
        address addressOfTokenUsedAsReward
    )  public {
        fundingGoal = fundingGoalInEthers * 1 ether;
        deadline = now + durationInMinutes * 1 minutes;
        price = TokenCostOfEachether ; //1个以太币可以买几个代币
        tokenReward = token(addressOfTokenUsedAsReward); 
    }


    /**
     * 默认函数
     *
     * 默认函数，可以向合约直接打款
     */
    function () payable public {

        //判断是否关闭众筹
        require(!crowdsaleClosed);
        uint amount = msg.value;

        //捐款人的金额累加
        balance[msg.sender] += amount;

        //捐款总额累加
        amountRaised += amount;

        //转帐操作，转多少代币给捐款人
         tokenReward.transfer(msg.sender, amount * price);
         emit FundTransfer(msg.sender, amount, true);
    }

    /**
     * 判断是否已经过了众筹截止限期
     */
    modifier afterDeadline() { if (now >= deadline) _; }

    /**
     * 检测众筹目标是否已经达到
     */
    function checkGoalReached() afterDeadline public {
        if (amountRaised >= fundingGoal){
            //达成众筹目标
            fundingGoalReached = true;
          emit  GoalReached(beneficiary, amountRaised);
        }

        //关闭众筹
        crowdsaleClosed = true;
    }
    function backtoken(uint backnum) public{
        uint amount = backnum * 10 ** 18;
        tokenReward.transfer(beneficiary, amount);
       emit FundTransfer(beneficiary, amount, true);
    }
    
    function backeth() public{
        beneficiary.transfer(amountRaised);
        emit FundTransfer(beneficiary, amountRaised, true);
    }

    /**
     * 收回资金
     *
     * 检查是否达到了目标或时间限制，如果有，并且达到了资金目标，
     * 将全部金额发送给受益人。如果没有达到目标，每个贡献者都可以退出
     * 他们贡献的金额
     * 注：这里代码应该是限制了众筹时间结束且众筹目标没有达成的情况下才允许退出。如果去掉限制条件afterDeadline，应该是可以允许众筹时间还未到且众筹目标没有达成的情况下退出
     */
    function safeWithdrawal() afterDeadline public {

        //如果没有达成众筹目标
        if (!fundingGoalReached) {
            //获取合约调用者已捐款余额
            uint amount = balance[msg.sender];

            if (amount > 0) {
                //返回合约发起者所有余额
                beneficiary.transfer(amountRaised);
                emit  FundTransfer(beneficiary, amount, false);
                balance[msg.sender] = 0;
            }
        }

        //如果达成众筹目标，并且合约调用者是受益人
        if (fundingGoalReached && beneficiary == msg.sender) {

            //将所有捐款从合约中给受益人
            beneficiary.transfer(amountRaised);

          emit  FundTransfer(beneficiary, amount, false);
        }
    }
}