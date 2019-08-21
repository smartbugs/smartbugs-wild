pragma solidity ^0.4.17;

/**
 * 众筹合约
 */
contract BSHCrowd {
    address public beneficiary = 0x5b218A74aAc7BcCB5dF3C73c5e2c9d7cf8834334; //受益人地址
    uint256 public fundingGoal = 9600 ether;  //众筹目标，单位是ether
    uint256 public amountRaised = 0; //已筹集金额数量， 单位是wei
    bool public fundingGoalReached = false;  //达成众筹目标
    bool public crowdsaleClosed = false; //众筹关闭

    mapping(address => uint256) public balance; 

    event GoalReached(address _beneficiary, uint _amountRaised);
    event FundTransfer(address _backer, uint _amount, bool _isContribution);
    event ReceiveFund(address _addr, uint _amount);

    function BSHCrowd() public {
    }

    /**
     * 默认函数，可以向合约直接打款
     */
    function () payable public {
        //判断是否关闭众筹
        require(!crowdsaleClosed);
        uint amount = msg.value;

        //众筹人余额累加
        balance[msg.sender] += amount;

        //众筹总额累加
        amountRaised += amount;

        ReceiveFund(msg.sender, amount);
    }

    /**
     * 检测众筹目标是否已经达到
     */
    function checkGoalReached() public {
        if (amountRaised >= fundingGoal) {
            //达成众筹目标
            fundingGoalReached = true;
            GoalReached(beneficiary, amountRaised);
                
            //关闭众筹
            crowdsaleClosed = true;
        }
    }

    /**
     * 关闭众筹
     */
    function closeCrowd() public {
        if (beneficiary == msg.sender) {
            crowdsaleClosed = true;
        }
    }

    /**
     * 提币
     */
    function safeWithdrawal(uint256 _value) public {
        if (beneficiary == msg.sender && _value > 0) {
            if (beneficiary.send(_value)) {
                FundTransfer(beneficiary, _value, false);
            } else {
                revert();
            }
        }
    }
}