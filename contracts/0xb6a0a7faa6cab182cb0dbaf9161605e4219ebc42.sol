pragma solidity ^0.5.0;

library SafeMath {
    /**
     * @dev Multiplies two unsigned integers, reverts on overflow.
     */

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522

        if (a == 0) {
            return 0;

        }

        uint256 c = a * b;
        require(c / a == b);

        return c;
    }


    /**
     * @dev Integer division of two unsigned integers truncating the quotient, reverts on division by zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Subtracts two unsigned integers, reverts on overflow (i.e. if subtrahend is greater than minuend).
     */
     
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a);
        uint256 c = a - b;
        
        return c;
    }

    /**
     * @dev Adds two unsigned integers, reverts on overflow.
     */

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a);
        return c;
    }

    /**
     * @dev Divides two unsigned integers and returns the remainder (unsigned integer modulo),
     * reverts when dividing by zero.
     */

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0);
        return a % b;
    }
}


interface IERC20 {

    function transfer(address to, uint256 value) external returns (bool);
    //function approve(address spender, uint256 value) external returns (bool);
    function transferFrom(address from, address to, uint256 value) external returns (bool);
    function totalSupply() external view returns (uint256);
    function balanceOf(address who) external view returns (uint256);
    //function allowance(address owner, address spender) external view returns (uint256);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}



contract VCNToken is IERC20 {

    using SafeMath for uint256;
    mapping (address => uint256) private _balances;
    mapping (address => TimeLock[]) private _timeLocks;
    uint256 private _totalSupply;
    address private _owner;
    
    
    
    string public constant name = "VoltChainNetwork";
    
    string public constant symbol = "VCN";
    uint8 public constant decimals = 18; 
    
    
    struct TimeLock{
        uint256 blockTime;
        uint256 blockAmount;
    }
    
    constructor(uint256 totalSupply) public{
        _totalSupply = totalSupply;
        _owner = msg.sender;
        _balances[_owner] = _totalSupply;
    }
    
    function getTimeStamp() public view returns(uint256) {
        return block.timestamp;
    }
    
    
    function timeLock(address addr, uint256 amount , uint16 lockMonth) public returns(bool){
        require(msg.sender == _owner);
        require(lockMonth > 0);
        require(amount <= getFreeAmount(addr));
    
        TimeLock memory timeLockTemp;
        timeLockTemp.blockTime = block.timestamp + 86400 * 30 * lockMonth;
        //timeLockTemp.blockTime = block.timestamp + 60 * lockMonth;
        timeLockTemp.blockAmount = amount;
        _timeLocks[addr].push(timeLockTemp);
        
        return true;
    }
    
    function crowdSale(address to, uint256 amount,  uint16 lockMonth) public returns(bool){
        require(msg.sender == _owner);
        
        _transfer(_owner, to, amount);
        
        if(lockMonth > 0){
            timeLock(to, amount, lockMonth);
        }
        
        return true;
    }
    
    function releaseLock(address owner, uint256 amount) public returns(bool){
        require(msg.sender == _owner);    
        
        uint minIdx = 0;
        uint256 minTime = 0;
        uint arrayLength = _timeLocks[owner].length;
        for (uint i=0; i<arrayLength; i++) {
            if(block.timestamp < _timeLocks[owner][i].blockTime && _timeLocks[owner][i].blockAmount > 0){
                if(minTime == 0 || minTime > _timeLocks[owner][i].blockTime){
                    minIdx = i;
                    minTime = _timeLocks[owner][i].blockTime;
                }
            }
        }
        
        if(minTime >= 0){
            if(amount > _timeLocks[owner][minIdx].blockAmount){
                uint256 remain = amount - _timeLocks[owner][minIdx].blockAmount;
                _timeLocks[owner][minIdx].blockAmount = 0;
                releaseLock(owner, remain);
            }else{
                _timeLocks[owner][minIdx].blockAmount -= amount;
            }
            
        }
        
        return true;
    }
    
    
    function getFreeAmount(address owner) public view returns(uint256){
        return(balanceOf(owner) - getLockAmount(owner));
    }
    
    function getLockAmount(address owner) public view returns(uint256){
        uint256 result = 0;
        uint arrayLength = _timeLocks[owner].length;
        for (uint i=0; i<arrayLength; i++) {
            if(block.timestamp < _timeLocks[owner][i].blockTime){
                result += _timeLocks[owner][i].blockAmount;
            }
        }
            
        return(result);
    }
    

    /**
     * @dev Total number of tokens in existence
     */

    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev Gets the balance of the specified address.
     * @param owner The address to query the balance of.
     * @return A uint256 representing the amount owned by the passed address.
     */

    function balanceOf(address owner) public view returns (uint256) {
        return _balances[owner];
    }

    /**
     * @dev Transfer token to a specified address
     * @param to The address to transfer to.
     * @param value The amount to be transferred.
     */

    function transfer(address to, uint256 value) public returns (bool) {
        _transfer(msg.sender, to, value);
        return true;
    }


    /**
     * @dev Transfer tokens from one address to another.
     * Note that while this function emits an Approval event, this is not required as per the specification,
     * and other compliant implementations may not emit the event.
     * @param from address The address which you want to send tokens from
     * @param to address The address which you want to transfer to
     * @param value uint256 the amount of tokens to be transferred
     */

    function transferFrom(address from, address to, uint256 value) public returns (bool) {
        _transfer(from, to, value);
        return true;
    }


    /**
     * @dev Transfer token for a specified addresses
     * @param from The address to transfer from.
     * @param to The address to transfer to.
     * @param value The amount to be transferred.
     */
    function _transfer(address from, address to, uint256 value) internal {
        require(to != address(0));
        require(from == msg.sender);
        
        uint256 available = balanceOf(from) - getLockAmount(from);
        require(available >= value, "not enough token");
        
        _balances[from] = _balances[from].sub(value);
        _balances[to] = _balances[to].add(value);
        emit Transfer(from, to, value);
    }




    /**
     * @dev Internal function that burns an amount of the token of a given
     * account.
     * @param account The account whose tokens will be burnt.
     * @param value The amount that will be burnt.
     */

    function _burn(address account, uint256 value) internal {
        require(account != address(0));
        require(account == msg.sender);
        
        _totalSupply = _totalSupply.sub(value);
        _balances[account] = _balances[account].sub(value);
        emit Transfer(account, address(0), value);
    }



    /**
     * @dev Internal function that burns an amount of the token of a given
     * account, deducting from the sender's allowance for said account. Uses the
     * internal burn function.
     * Emits an Approval event (reflecting the reduced allowance).
     * @param account The account whose tokens will be burnt.
     * @param value The amount that will be burnt.
     */

    function _burnFrom(address account, uint256 value) internal {
        _burn(account, value);
    }
    
    
}