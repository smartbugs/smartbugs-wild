pragma solidity ^0.4.16;

contract GSEPTO {
    string public name = "GSEPTO";
    string public symbol = "GSEPTO";

    address private owner;//操作者
    uint256 public fundingGoal; //目标金额
    uint256 public amountRaised; //当前金额
    mapping(address => uint256) public balanceOf; //每个地址的众筹数目，map类型

    event Transfer(address indexed _from, address indexed _to, uint256 _amount);//转账
    event FundTransfer(address indexed _backer, uint256 _amount);//事件，资金转账记录
    event IncreaseFunding(uint256 indexed _increase, uint256 indexed _curFundingGoal);//事件，增发
    bool public crowdsaleOpened = true; //合约开关，启动时默认为“开”

    /*  at initialization, setup the owner */
    function GSEPTO(uint256 _fundingGoal) public {
        owner = msg.sender;
        fundingGoal = _fundingGoal;
        balanceOf[owner] = fundingGoal;
        Transfer(0x0, owner, fundingGoal);
    }

    // allows execution by the owner only
    modifier ownerOnly {
        assert(owner == msg.sender);
        _;
    }
    // when crowdsale closed, throw exception
    modifier validCrowdsale {
        assert(crowdsaleOpened);
        _;
    }

    function record(address _to, uint256 _amount) public ownerOnly validCrowdsale returns (bool success) {
        require(_to != 0x0);
        require(balanceOf[msg.sender] >= _amount);
        require(balanceOf[_to] + _amount >= balanceOf[_to]);
        balanceOf[msg.sender] -= _amount;
        //计入统计，发送者发送的数量
        balanceOf[_to] += _amount;
        //累计收到的金额
        amountRaised += _amount;
        Transfer(msg.sender, _to, _amount);
        //发送资金变动事件通知
        FundTransfer(_to, _amount);
        return true;
    }

    // increase the fundingGoal
    // 增发总目标金额
    function increaseFundingGoal(uint256 _amount) public ownerOnly validCrowdsale {
        balanceOf[msg.sender] += _amount;
        fundingGoal += _amount;
        Transfer(0x0, msg.sender, _amount);
        IncreaseFunding(_amount, fundingGoal);
    }

    //close this crowdsale
    // 关闭合约
    function closeUp() public ownerOnly validCrowdsale {
        crowdsaleOpened = false;
    }

    //re open this crowdsale
    // 开放合约
    function reopen() public ownerOnly {
        crowdsaleOpened = true;
    }
}