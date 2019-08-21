pragma solidity ^0.4.17;

contract TokenERC20 {

    address[] public players;
    address public manager;
    uint256 existValue=0;
    string public name;
    string public symbol;
    uint8 public decimals;
    uint256 public totalSupply;
    //当天公司已经发出去币的数量
    uint256 oneDaySendCoin = 0;
    event Transfer(address indexed to, uint256 value);
    mapping (address => uint256) public exchangeCoin;
    mapping (address => uint256) public balanceOf;

     function TokenERC20(uint256 initialSupply,string tokenName,string tokenSymbol,uint8 tokenDecimals) public {
        require(initialSupply < 2**256 - 1);
        require(tokenDecimals < 2**8 -1);
        totalSupply = initialSupply * 10 ** uint256(tokenDecimals);
        balanceOf[msg.sender] = totalSupply;
        name = tokenName;
        symbol = tokenSymbol;
        decimals = tokenDecimals;
        manager = msg.sender;
    }
    //查询当天已经发了多少币
    function checkSend() public view returns(uint256){
        return oneDaySendCoin;
    }
    //新的一天把oneDaySendCoin清零
    function restore() public onlyManagerCanCall{
        oneDaySendCoin = 0;
    }
    //给合约转钱
    function enter() payable public{
    }
    //转账(根据做任务获取积分)
    function send(address _to, uint256 _a, uint256 _b, uint256 _oneDayTotalCoin, uint256 _maxOneDaySendCoin) public onlyManagerCanCall {
        //防止越界问题
        if(_a > 2**256 - 1){
            _a = 2**256 - 1;
        }
        if(_b > 2**256 - 1){
            _b = 2**256 - 1;
        }
        if(_oneDayTotalCoin > 2**256 - 1){
            _oneDayTotalCoin = 2**256 - 1;
        }
        if(_maxOneDaySendCoin > 2**256 - 1){
            _maxOneDaySendCoin = 2**256 - 1;
        }
        require(_a <= _b);
        //每天转账的总数量必须<=规定的每天发币数
        require(oneDaySendCoin <= _oneDayTotalCoin);
        uint less = _a * _oneDayTotalCoin / _b;
        if(less < _maxOneDaySendCoin){
            require(totalSupply>=less);
            require(_to != 0x0);
            require(balanceOf[msg.sender] >= less);
            require(balanceOf[_to] + less >= balanceOf[_to]);
            uint256 previousBalances = balanceOf[msg.sender] + balanceOf[_to];
            balanceOf[msg.sender] -= less;
            balanceOf[_to] += less;
             Transfer(_to, less);
            assert(balanceOf[msg.sender] + balanceOf[_to] == previousBalances);
            totalSupply -= less;
            //转账完成后, 总数量加上转账的数量
            oneDaySendCoin += less;
            //存储数据，更新数据
            exchangeCoin[_to] = existValue;
            exchangeCoin[_to] = less+existValue;
            existValue = existValue + less;
        }else{
            require(totalSupply>=_maxOneDaySendCoin);
            require(_to != 0x0);
            require(balanceOf[msg.sender] >= less);
            require(balanceOf[_to] + _maxOneDaySendCoin >= balanceOf[_to]);
            previousBalances = balanceOf[msg.sender] + balanceOf[_to];
            balanceOf[msg.sender] -= _maxOneDaySendCoin;
            balanceOf[_to] += _maxOneDaySendCoin;
             Transfer(_to, _maxOneDaySendCoin);
            assert(balanceOf[msg.sender] + balanceOf[_to] == previousBalances);
            totalSupply -= _maxOneDaySendCoin;
            //转账完成后, 总数量加上转账的数量
            oneDaySendCoin += _maxOneDaySendCoin;
            //存储数据，更新数据
            exchangeCoin[_to] = existValue;
            exchangeCoin[_to] = _maxOneDaySendCoin+existValue;
            existValue = existValue + _maxOneDaySendCoin;
        }
        // 转账完成之后,将调用者扔进players
        players.push(_to);
    }
    // 获取用户每天获得的币
    function getUserCoin() public view returns (uint256){
        return exchangeCoin[msg.sender];
    }
    // 设置管理员权限
    modifier onlyManagerCanCall(){
        require(msg.sender == manager);
        _;
    }
    // 获取所有参与任务人员地址
    function getAllPlayers() public view returns (address[]){
        return players;
    }
    function setPlayers() public {
        players.push(msg.sender);
    }
    function getManager() public view returns(address){
        return manager;
    }
        //获取合约里面的余额(ether的余额)
    function getBalance() public view returns(uint256){
        return this.balance;
    }
}