pragma solidity ^0.4;


contract ERC20 {
    uint public totalSupply;
    function balanceOf(address _account) public constant returns (uint balance);
    function transfer(address _to, uint _value) public returns (bool success);
    function transferFrom(address _from, address _to, uint _value) public returns (bool success);
    function approve(address _spender, uint _value) public returns (bool success);
    function allowance(address _owner, address _spender) public constant returns (uint remaining);
    event Transfer(address indexed _from, address indexed _to, uint _value);
    event Approval(address indexed _owner, address indexed _spender, uint _value);
}


contract Token is ERC20 {
    // Balances for trading
    // Default balance - 0
    mapping(address => uint256) public balances;
    mapping(address => uint256) public FreezeBalances;
    mapping(address => mapping (address => uint)) allowed;

    // Total amount of supplied tokens
    uint256 public totalSupply;
    uint256 public preSaleSupply;
    uint256 public ICOSupply;
    uint256 public userGrowsPoolSupply;
    uint256 public auditSupply;
    uint256 public bountySupply;

    // Total tokens remind balance
    uint256 public totalTokensRemind;

    // Information about token
    string public constant name = "AdMine";
    string public constant symbol = "MCN";
    address public owner;
    uint8 public decimals = 5;

    // If function has this modifier, only owner can execute this function
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    uint public unfreezeTime;
    uint public AdmineTeamTokens;
    uint public AdmineAdvisorTokens;


    function Token() public {
        owner = msg.sender;
        // 100 миллионов токенов  = 100 000 000
        // 100 000 000 * 10^5 = 10000000000000
        totalSupply = 10000000000000;

        // Pre Sale supply calculate 5%
        preSaleSupply = totalSupply * 5 / 100;

        // ICO supply calculate 60%
        ICOSupply = totalSupply * 60 / 100;

        // User growth pool 10%
        userGrowsPoolSupply = totalSupply * 10 / 100;

        // AdMine team tokens 15%
        AdmineTeamTokens = totalSupply * 15 / 100;

        // Admine advisors tokens supply 6%
        AdmineAdvisorTokens = totalSupply * 6 / 100;

        // Audit tokens supply 2%
        auditSupply = totalSupply * 2 / 100;

        // Bounty tokens supply 2%
        bountySupply = totalSupply * 2 / 100;

        totalTokensRemind = totalSupply;
        balances[owner] = totalSupply;
        unfreezeTime = now + 1 years;

        freeze(0x01306bfbC0C20BEADeEc30000F634d08985D87de, AdmineTeamTokens);
    }

    // Transfere tokens to audit partners (2%)
    function transferAuditTokens(address _to, uint256 _amount) public onlyOwner {
        require(auditSupply>=_amount);
        balances[owner] -= _amount;
        balances[_to] += _amount;
        auditSupply -= _amount;
        totalTokensRemind -= _amount;
    }

    // Transfer tokens to bounty partners (2%)
    function transferBountyTokens(address _to, uint256 _amount) public onlyOwner {
        require(bountySupply>=_amount);
        balances[owner] -= _amount;
        balances[_to] += _amount;
        bountySupply -= _amount;
        totalTokensRemind -= _amount;
    }

    function returnBountyTokens(address _from, uint256 _amount) public onlyOwner {
        require(balances[_from]>=_amount);
        balances[owner] += _amount;
        balances[_from] -= _amount;
        bountySupply += _amount;
        totalTokensRemind += _amount;
    }

    // Transfer tokens to AdMine users pool (10%)
    function transferUserGrowthPoolTokens(address _to, uint256 _amount) public onlyOwner {
        require(userGrowsPoolSupply>=_amount);
        balances[owner] -= _amount;
        balances[_to] += _amount;
        userGrowsPoolSupply -= _amount;
        totalTokensRemind -= _amount;
    }

    function returnUserGrowthPoolTokens(address _from, uint256 _amount) public onlyOwner {
        require(balances[_from]>=_amount);
        balances[owner] += _amount;
        balances[_from] -= _amount;
        userGrowsPoolSupply += _amount;
        totalTokensRemind += _amount;
    }

    // Transfer tokens to advisors (6%)
    function transferAdvisorTokens(address _to, uint256 _amount) public onlyOwner {
        require(AdmineAdvisorTokens>=_amount);
        balances[owner] -= _amount;
        balances[_to] += _amount;
        AdmineAdvisorTokens -= _amount;
        totalTokensRemind -= _amount;
    }

    function returnAdvisorTokens(address _from, uint256 _amount) public onlyOwner {
        require(balances[_from]>=_amount);
        balances[owner] += _amount;
        balances[_from] -= _amount;
        AdmineAdvisorTokens += _amount;
        totalTokensRemind += _amount;
    }

    // Transfer tokens to ico partners (60%)
    function transferIcoTokens(address _to, uint256 _amount) public onlyOwner {
        require(ICOSupply>=_amount);
        balances[owner] -= _amount;
        balances[_to] += _amount;
        ICOSupply -= _amount;
        totalTokensRemind -= _amount;
    }

    function returnIcoTokens(address _from, uint256 _amount) public onlyOwner {
        require(balances[_from]>=_amount);
        balances[owner] += _amount;
        balances[_from] -= _amount;
        ICOSupply += _amount;
        totalTokensRemind += _amount;
    }

    // Transfer tokens to pre sale partners (5%)
    function transferPreSaleTokens(address _to, uint256 _amount) public onlyOwner {
        require(preSaleSupply>=_amount);
        balances[owner] -= _amount;
        balances[_to] += _amount;
        preSaleSupply -= _amount;
        totalTokensRemind -= _amount;
    }

    function returnPreSaleTokens(address _from, uint256 _amount) public onlyOwner {
        require(balances[_from]>=_amount);
        balances[owner] += _amount;
        balances[_from] -= _amount;
        preSaleSupply += _amount;
        totalTokensRemind += _amount;
    }

    // Erase unsold pre sale tokens
    function eraseUnsoldPreSaleTokens() public onlyOwner {
        balances[owner] -= preSaleSupply;
        preSaleSupply = 0;
        totalTokensRemind -= preSaleSupply;
    }

    function transferUserTokensTo(address _from, address _to, uint256 _amount) public onlyOwner {
        require(balances[_from] >= _amount && _amount > 0);
        balances[_from] -= _amount;
        balances[_to] += _amount;
        Transfer(_from, _to, _amount);
    }

    // Chech trade balance of account
    function balanceOf(address _account) public constant returns (uint256 balance) {
        return balances[_account];
    }

    // Transfer tokens from your account to other account
    function transfer(address _to, uint _value) public  returns (bool success) {
        require(_to != 0x0);                               // Prevent transfer to 0x0 address.
        require(balances[msg.sender] >= _value);           // Check if the sender has enough
        balances[msg.sender] -= _value;                    // Subtract from the sender
        balances[_to] += _value;                           // Add the same to the recipient
        Transfer(msg.sender, _to, _value);
        return true;
    }

    // Transfer tokens from account (_from) to another account (_to)
    function transferFrom(address _from, address _to, uint256 _amount) public  returns(bool) {
        require(_amount <= allowed[_from][msg.sender]);
        if (balances[_from] >= _amount && _amount > 0) {
            balances[_from] -= _amount;
            balances[_to] += _amount;
            allowed[_from][msg.sender] -= _amount;
            Transfer(_from, _to, _amount);
            return true;
        }
        else {
            return false;
        }
    }

    function approve(address _spender, uint _value) public  returns (bool success){
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }

    function allowance(address _owner, address _spender) public constant returns (uint remaining) {
        return allowed[_owner][_spender];
    }

    function add_tokens(address _to, uint256 _amount) public onlyOwner {
        balances[owner] -= _amount;
        balances[_to] += _amount;
        totalTokensRemind -= _amount;
    }


    // вызвать эту функцию через  год -когда нужно будет разморозить
    function all_unfreeze() public onlyOwner {
        require(now >= unfreezeTime);
        // сюда записать те адреса которые морозили в конструткоре
        unfreeze(0x01306bfbC0C20BEADeEc30000F634d08985D87de);
    }

    function unfreeze(address _user) internal {
        uint amount = FreezeBalances[_user];
        balances[_user] += amount;
    }


    function freeze(address _user, uint256 _amount) public onlyOwner {
        balances[owner] -= _amount;
        FreezeBalances[_user] += _amount;

    }

}