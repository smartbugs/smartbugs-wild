pragma solidity ^0.4.16;


/**
 * @title ERC20Basic
 * @dev Simpler version of ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/179
 */
contract ERC20 {
    uint256 public totalSupply;
    function balanceOf(address who) public constant returns (uint256);
    function transfer(address to, uint256 value) public returns (bool);
    function allowance(address owner, address spender) public constant returns (uint256);
    function transferFrom(address from, address to, uint256 value) public returns (bool);
    function approve(address spender, uint256 value) public returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}


/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {
    function mul(uint256 a, uint256 b) internal constant returns (uint256) {
        uint256 c = a * b;
        assert(a == 0 || c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) internal constant returns (uint256) {
        // assert(b > 0); // Solidity automatically throws when dividing by 0
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return c;
    }

    function sub(uint256 a, uint256 b) internal constant returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    function add(uint256 a, uint256 b) internal constant returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }
}


/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
    mapping(address => bool)  internal owners;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev The Ownable constructor sets the original `owner` of the contract to the sender
     * account.
     */
    function Ownable() {
        owners[msg.sender] = true;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owners[msg.sender] == true);
        _;
    }

    function addOwner(address newAllowed) onlyOwner public {
        owners[newAllowed] = true;
    }

    function removeOwner(address toRemove) onlyOwner public {
        owners[toRemove] = false;
    }

}

/**
 * @title Basic token
 * @dev Basic version of StandardToken, with no allowances.
 */
contract BigToken is ERC20, Ownable {
    using SafeMath for uint256;

    string public name = "Big Token";
    string public symbol = "BIG";
    uint256 public decimals = 18;
    uint256 public mintPerBlock = 333333333333333;

    struct BigTransaction {
        uint blockNumber;
        uint256 amount;
    }

    uint public commissionPercent = 10;
    uint256 public totalTransactions = 0;
    bool public enabledMint = true;
    uint256 public totalMembers;

    mapping(address => mapping (address => uint256)) internal allowed;
    mapping(uint256 => BigTransaction) public transactions;
    mapping(address => uint256) public balances;
    mapping(address => uint) public lastMint;
    mapping(address => bool) invested;
    mapping(address => bool) public confirmed;
    mapping(address => bool) public members;

    event Mint(address indexed to, uint256 amount);
    event Commission(uint256 amount);

    /**
     * @dev transfer token for a specified address
     * @param _to The address to transfer to.
     * @param _value The amount to be transferred.
     */
    function transfer(address _to, uint256 _value) public returns (bool)  {
        require(_to != address(0));

        uint256 currentBalance = balances[msg.sender];
        uint256 balanceToMint = getBalanceToMint(msg.sender);
        uint256 commission = _value * commissionPercent / 100;
        require((_value + commission) <= (currentBalance + balanceToMint));

        if(balanceToMint > 0){
            currentBalance = currentBalance.add(balanceToMint);
            Mint(msg.sender, balanceToMint);
            lastMint[msg.sender] = block.number;
            totalSupply = totalSupply.add(balanceToMint);
        }
        
        

        if(block.number == transactions[totalTransactions - 1].blockNumber) {
            transactions[totalTransactions - 1].amount = transactions[totalTransactions - 1].amount + (commission / totalMembers);
        } else {
            uint transactionID = totalTransactions++;
            transactions[transactionID] = BigTransaction(block.number, commission / totalMembers);
        }
        
        balances[msg.sender] = currentBalance.sub(_value + commission);
        balances[_to] = balances[_to].add(_value);
        Transfer(msg.sender, _to, _value);
        return true;
    }

    /**
     * @dev Transfer tokens from one address to another
     * @param _from address The address which you want to send tokens from
     * @param _to address The address which you want to transfer to
     * @param _value uint256 the amount of tokens to be transferred
     */
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
        require(_to != address(0));
        require(_value <= allowed[_from][msg.sender]);

        uint256 currentBalance = balances[_from];
        uint256 balanceToMint = getBalanceToMint(_from);
        uint256 commission = _value * commissionPercent / 100;
        require((_value + commission) <= (currentBalance + balanceToMint));

        if(balanceToMint > 0){
            currentBalance = currentBalance.add(balanceToMint);
            Mint(_from, balanceToMint);
            lastMint[_from] = block.number;
            totalSupply = totalSupply.add(balanceToMint);
        }
        
        
        if(block.number == transactions[totalTransactions - 1].blockNumber) {
            transactions[totalTransactions - 1].amount = transactions[totalTransactions - 1].amount + (commission / totalMembers);
        } else {
            uint transactionID = totalTransactions++;
            transactions[transactionID] = BigTransaction(block.number, commission / totalMembers);
        }

        balances[_from] = currentBalance.sub(_value + commission);
        balances[_to] = balances[_to].add(_value);
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
        Transfer(_from, _to, _value);
        return true;
    }


    /**
     * @dev Gets the balance of the specified address.
     * @param _owner The address to query the the balance of.
     * @return An uint256 representing the amount owned by the passed address.
     */
    function balanceOf(address _owner) public constant returns (uint256 balance) {
        if(lastMint[_owner] != 0){
            return balances[_owner] + getBalanceToMint(_owner);
        } else {
            return balances[_owner];
        }
    }

    /**
     * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.
     *
     * Beware that changing an allowance with this method brings the risk that someone may use both the old
     * and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this
     * race condition is to first reduce the spender's allowance to 0 and set the desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     * @param _spender The address which will spend the funds.
     * @param _value The amount of tokens to be spent.
     */
    function approve(address _spender, uint256 _value) public returns (bool) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }

    /**
     * @dev Function to check the amount of tokens that an owner allowed to a spender.
     * @param _owner address The address which owns the funds.
     * @param _spender address The address which will spend the funds.
     * @return A uint256 specifying the amount of tokens still available for the spender.
     */
    function allowance(address _owner, address _spender) public constant returns (uint256 remaining) {
        return allowed[_owner][_spender];
    }

    /**
     * approve should be called when allowed[_spender] == 0. To increment
     * allowed value is better to use this function to avoid 2 calls (and wait until
     * the first transaction is mined)
     * From MonolithDAO Token.sol
     */
    function increaseApproval(address _spender, uint _addedValue) public returns (bool success) {
        allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
        Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
        return true;
    }

    function decreaseApproval(address _spender, uint _subtractedValue) public returns (bool success) {
        uint oldValue = allowed[msg.sender][_spender];
        if (_subtractedValue > oldValue) {
            allowed[msg.sender][_spender] = 0;
        } else {
            allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
        }
        Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
        return true;
    }

    function refreshBalance(address _address) public returns (uint256){
        if(!members[_address]) return;
        
        uint256 balanceToMint = getBalanceToMint(_address);
        totalSupply = totalSupply.add(balanceToMint);
        balances[_address] = balances[_address] + balanceToMint;
        lastMint[_address] = block.number;
    }

    function mint(address _to, uint256 _amount) onlyOwner public returns (bool) {
        totalSupply = totalSupply.add(_amount);
        balances[_to] = balances[_to].add(_amount);
        Mint(_to, _amount);
        Transfer(0x0, _to, _amount);
        return true;
    }

    function getBalanceToMint(address _address) public constant returns (uint256){
        if(!enabledMint) return 0;
        if(!members[_address]) return 0;
        if(lastMint[_address] == 0) return 0;

        uint256 balanceToMint = (block.number - lastMint[_address]) * mintPerBlock;
        
        for(uint i = totalTransactions - 1; i >= 0; i--){
            if(block.number == transactions[i].blockNumber) continue;
            if(transactions[i].blockNumber < lastMint[_address]) return balanceToMint;
            if(transactions[i].amount > mintPerBlock) {
                balanceToMint = balanceToMint.add(transactions[i].amount - mintPerBlock);
            }
        }

        return balanceToMint;
    }

    function stopMint() public onlyOwner{
        enabledMint = false;
    }

    function startMint() public onlyOwner{
        enabledMint = true;
    }

    function confirm(address _address) onlyOwner public {
        confirmed[_address] = true;
        if(!members[_address] && invested[_address]){
            members[_address] = true;
            totalMembers = totalMembers.add(1);
            setLastMint(_address, block.number);
        }
    }

    function unconfirm(address _address) onlyOwner public {
        confirmed[_address] = false;
        if(members[_address]){
            members[_address] = false;
            totalMembers = totalMembers.sub(1);
        }
    }
    
    function setLastMint(address _address, uint _block) onlyOwner public{
        lastMint[_address] = _block;
    }

    function setCommission(uint _commission) onlyOwner public{
        commissionPercent = _commission;
    }

    function setMintPerBlock(uint256 _mintPerBlock) onlyOwner public{
        mintPerBlock = _mintPerBlock;
    }

    function setInvested(address _address) onlyOwner public{
        invested[_address] = true;
        if(confirmed[_address] && !members[_address]){
            members[_address] = true;
            totalMembers = totalMembers.add(1);
            refreshBalance(_address);
        }
    }

    function isMember(address _address) public constant returns(bool){
        return members[_address];
    }

}


contract Crowdsale is Ownable{

    using SafeMath for uint;

    BigToken public token;
    uint public collected;
    address public benefeciar;

    function Crowdsale(address _token, address _benefeciar){
        token = BigToken(_token);
        benefeciar = _benefeciar;
        owners[msg.sender] = true;
    }

    function () payable {
        require(msg.value >= 0.01 ether);
        uint256 amount = msg.value / 0.01 ether * 1 ether;

        if(msg.value >= 100 ether && msg.value < 500 ether) amount = amount * 11 / 10;
        if(msg.value >= 500 ether && msg.value < 1000 ether) amount = amount * 12 / 10;
        if(msg.value >= 1000 ether && msg.value < 5000 ether) amount = amount * 13 / 10;
        if(msg.value >= 5000 ether && msg.value < 10000 ether) amount = amount * 14 / 10;
        if(msg.value >= 10000 ether) amount = amount * 15 / 10;

        collected = collected.add(msg.value);

        token.mint(msg.sender, amount);
        token.setInvested(msg.sender);
    }


    function confirmAddress(address _address) public onlyOwner{
        token.confirm(_address);
    }

    function unconfirmAddress(address _address) public onlyOwner{
        token.unconfirm(_address);
    }

    function setBenefeciar(address _benefeciar) public onlyOwner{
        benefeciar = _benefeciar;
    }

    function withdraw() public onlyOwner{
        benefeciar.transfer(this.balance);
    }

}