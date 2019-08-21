pragma solidity ^0.4.4;

contract Token
{
    function totalSupply() constant returns (uint256 supply) {}
    function balanceOf(address _owner) constant returns (uint256 balance) {}
    function transfer(address _to, uint256 _value) returns (bool success) {}
    function transferFrom(address _from, address _to, uint256 _value) returns (bool success) {}
    function approve(address _spender, uint256 _value) returns (bool success) {}
    function allowance(address _owner, address _spender) constant returns (uint256 remaining) {}

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);    
}

contract StandardToken is Token
{

    function transfer(address _to, uint256 _value) returns (bool success)
    {
        if (balances[msg.sender] >= _value && _value > 0)
        {
            balances[msg.sender] -= _value;
            balances[_to] += _value;
            Transfer(msg.sender, _to, _value);
            return true;
        } else { return false; }
    }

    function transferFrom(address _from, address _to, uint256 _value) returns (bool success)
    {
        if (balances[_from] >= _value && allowed[_from][msg.sender] >= _value && _value > 0)
        {
            balances[_to] += _value;
            balances[_from] -= _value;
            allowed[_from][msg.sender] -= _value;
            Transfer(_from, _to, _value);
            return true;
        } else { return false; }
    }

    function balanceOf(address _owner) constant returns (uint256 balance)
    {
        return balances[_owner];
    }

    function approve(address _spender, uint256 _value) returns (bool success)
    {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }

    function allowance(address _owner, address _spender) constant returns (uint256 remaining)
    {
      return allowed[_owner][_spender];
    }

    mapping (address => uint256) balances;
    mapping (address => mapping (address => uint256)) allowed;
    uint256 public totalSupply;
}

contract Riccoin is StandardToken
{

    string public name;
    uint8 public decimals;
    string public symbol;
    string public version = 'H1.0';
    
    address public beneficiary;
    address public creator;
    uint public fundingGoal;
    uint public starttime;
    uint public deadline;
    uint public amountRaised;
    uint256 public unitsOneEthCanBuy;
    bool public fundingGoalReached = false;
    bool public crowdsaleClosed = false;

    event GoalReached(address recipient, uint totalAmountRaised);
    
    function Riccoin(string tokenName, string tokenSymbol, uint256 initialSupply, address sendEtherTo, uint fundingGoalInEther, uint durationInMinutes, uint256 tokenInOneEther)
    {
        name = tokenName; 
        symbol = tokenSymbol; 
        decimals = 18;
        totalSupply = initialSupply * 10 ** uint256(decimals);
        beneficiary = sendEtherTo;
        creator = msg.sender;
        balances[beneficiary] = totalSupply;
        fundingGoal = fundingGoalInEther * 1 ether;
        starttime = now;
        deadline = now + durationInMinutes * 1 minutes;
        unitsOneEthCanBuy = tokenInOneEther;
    }

    function() payable
    {
        require(!crowdsaleClosed);
        uint256 amount = msg.value * unitsOneEthCanBuy;
        
        
        if((now - starttime) <= (deadline - starttime) / 20)
            amount = 23 * (amount/20);
        else if((now - starttime) <= 9 * ((deadline - starttime) / 20) )
            amount = 11 * (amount/10);

        require(balances[beneficiary] >= amount);
        
        amountRaised += msg.value;
        balances[beneficiary] = balances[beneficiary] - amount;
        balances[msg.sender] = balances[msg.sender] + amount;
        beneficiary.transfer(msg.value);
        Transfer(beneficiary, msg.sender, amount); 
    }

    modifier afterDeadline()
    { if (now >= deadline) _; }

    function checkGoalReached() afterDeadline
    {
        if (amountRaised >= fundingGoal)
        {
            fundingGoalReached = true;
            GoalReached(beneficiary, amountRaised);
        }
        crowdsaleClosed = true;
    }

    function updateRate(uint256 tokenInOneEther) external
    {
        require(msg.sender == creator);
        require(!crowdsaleClosed);
        unitsOneEthCanBuy = tokenInOneEther;
    }

    function changeCreator(address _creator) external
    {
        require(msg.sender == creator);
        creator = _creator;
    }

    function updateBeneficiary(address _beneficiary) external
    {
        require(msg.sender == creator);
        beneficiary = _beneficiary;
    }

    function approveAndCall(address _spender, uint256 _value, bytes _extraData) returns (bool success)
    {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        if(!_spender.call(bytes4(bytes32(sha3("receiveApproval(address,uint256,address,bytes)"))), msg.sender, _value, this, _extraData))
            { throw; }
        return true;
    }
}