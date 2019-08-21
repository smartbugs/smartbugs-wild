pragma solidity ^0.4.16;

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


contract Ownable {
    address public owner;


    /**
     * @dev The Ownable constructor sets the original `owner` of the contract to the sender
     * account.
     */
    function Ownable() {
        owner = msg.sender;
    }


    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }


    /**
     * @dev Allows the current owner to transfer control of the contract to a newOwner.
     * @param newOwner The address to transfer ownership to.
     */
    function transferOwnership(address newOwner) onlyOwner {
        if (newOwner != address(0)) {
            owner = newOwner;
        }
    }

}

contract ERC20Basic {
    uint256 public totalSupply;
    function balanceOf(address who) constant returns (uint256);
    function transfer(address to, uint256 value) returns (bool);

    // KYBER-NOTE! code changed to comply with ERC20 standard
    event Transfer(address indexed _from, address indexed _to, uint _value);
    //event Transfer(address indexed from, address indexed to, uint256 value);
}

contract BasicToken is ERC20Basic {
    using SafeMath for uint256;

    mapping(address => uint256) balances;

    /**
    * @dev transfer token for a specified address
    * @param _to The address to transfer to.
    * @param _value The amount to be transferred.
    */
    function transfer(address _to, uint256 _value) returns (bool) {
        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);
        Transfer(msg.sender, _to, _value);
        return true;
    }

    /**
    * @dev Gets the balance of the specified address.
    * @param _owner The address to query the the balance of.
    * @return An uint256 representing the amount owned by the passed address.
    */
    function balanceOf(address _owner) constant returns (uint256 balance) {
        return balances[_owner];
    }

}

contract ERC20 is ERC20Basic {
    function allowance(address owner, address spender) constant returns (uint256);
    function transferFrom(address from, address to, uint256 value) returns (bool);
    function approve(address spender, uint256 value) returns (bool);

    // KYBER-NOTE! code changed to comply with ERC20 standard
    event Approval(address indexed _owner, address indexed _spender, uint _value);
    //event Approval(address indexed owner, address indexed spender, uint256 value);
}



contract StandardToken is ERC20, BasicToken {

    mapping (address => mapping (address => uint256)) allowed;


    /**
     * @dev Transfer tokens from one address to another
     * @param _from address The address which you want to send tokens from
     * @param _to address The address which you want to transfer to
     * @param _value uint256 the amout of tokens to be transfered
     */
    function transferFrom(address _from, address _to, uint256 _value) returns (bool) {
        uint256 _allowance = allowed[_from][msg.sender];

        balances[_from] = balances[_from].sub(_value);
        balances[_to] = balances[_to].add(_value);
        allowed[_from][msg.sender] = _allowance.sub(_value);
        Transfer(_from, _to, _value);
        return true;
    }

    /**
     * @dev Aprove the passed address to spend the specified amount of tokens on behalf of msg.sender.
     * @param _spender The address which will spend the funds.
     * @param _value The amount of tokens to be spent.
     */
    function approve(address _spender, uint256 _value) returns (bool) {

        // To change the approve amount you first have to reduce the addresses`
        //  allowance to zero by calling `approve(_spender, 0)` if it is not
        //  already 0 to mitigate the race condition described here:
        //  https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
        require((_value == 0) || (allowed[msg.sender][_spender] == 0));

        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }

    /**
     * @dev Function to check the amount of tokens that an owner allowed to a spender.
     * @param _owner address The address which owns the funds.
     * @param _spender address The address which will spend the funds.
     * @return A uint256 specifing the amount of tokens still avaible for the spender.
     */
    function allowance(address _owner, address _spender) constant returns (uint256 remaining) {
        return allowed[_owner][_spender];
    }

}

contract Lock is StandardToken, Ownable{

    mapping(address => uint256) public lockedBalance;

    mapping(address => uint256) public lockStartTime;

    mapping(address => uint256) public usedBalance;

    function availablePercent(address _to) internal constant returns (uint256) {
        uint256 percent = 25;
        percent += ((now - lockStartTime[_to]) / 90 days ) * 25;
        if(percent > 100) {
            percent = 100;
        }
        return percent;
    }

    function issueToken(address _to,uint256 _value) public onlyOwner {
        require(super.transfer(_to,_value) ==  true);
        require(lockStartTime[_to] == 0);
        lockedBalance[_to] = lockedBalance[_to].add(_value);
        lockStartTime[_to] = block.timestamp;
    }

    function available(address _to) public constant returns (uint256) {
        uint256 percent = availablePercent(_to);
        uint256 avail = lockedBalance[_to];
        avail = avail.mul(percent);
        avail = avail.div(100);
        avail = avail.sub(usedBalance[_to]);
        return avail ;
    }

    function totalAvailable(address _to) public constant returns (uint256){
        uint256 avail1 = available(_to);
        uint256 avail2 = balances[_to].add(usedBalance[_to]).sub(lockedBalance[_to]);
        uint256 totalAvail = avail1.add(avail2);
        return totalAvail;
    }

    function lockTransfer(address _to, uint256 _value) internal returns (bool) {
        uint256 avail1 = available(msg.sender);
        uint256 avail2 = balances[msg.sender].add(usedBalance[msg.sender]).sub(lockedBalance[msg.sender]);
        uint256 totalAvail = avail1.add(avail2);
        require(_value <= totalAvail);
        bool ret = super.transfer(_to,_value);
        if(ret == true) {
            if(_value > avail2){
                usedBalance[msg.sender] = usedBalance[msg.sender].add(_value).sub(avail2);
            }
            if(usedBalance[msg.sender] >= lockedBalance[msg.sender]) {
                delete lockStartTime[msg.sender];
            }
        }
        return ret;
    }

    function lockTransferFrom(address _from,address _to, uint256 _value) internal returns (bool) {
        uint256 avail1 = available(_from);
        uint256 avail2 = balances[_from].add(usedBalance[_from]).sub(lockedBalance[_from]);
        uint256 totalAvail = avail1.add(avail2);
        require(_value <= totalAvail);
        bool ret = super.transferFrom(_from,_to,_value);
        if(ret == true) {
            if(_value > avail2){
                usedBalance[_from] = usedBalance[_from].add(_value).sub(avail2);
            }
            if(usedBalance[_from] >= lockedBalance[_from]) {
                delete lockStartTime[_from];
            }
        }
        return ret;
    }
}

contract PrototypeNetworkToken is Lock{
    string  public  constant name = "Prototype Network";
    string  public  constant symbol = "PROT";
    uint    public  constant decimals = 18;

    bool public transferEnabled = true;


    modifier validDestination( address to ) {
        require(to != address(0x0));
        require(to != address(this) );
        _;
    }

    function PrototypeNetworkToken() {
        // Mint all tokens. Then disable minting forever.
        totalSupply = 2100000000 * (10 ** decimals);
        balances[msg.sender] = totalSupply;
        Transfer(address(0x0), msg.sender, totalSupply);
        transferOwnership(msg.sender); // admin could drain tokens that were sent here by mistake
    }

    function transfer(address _to, uint _value) validDestination(_to) returns (bool) {
        require(transferEnabled == true);

        // The sender is in locked address list
        if(lockStartTime[msg.sender] > 0) {
            return super.lockTransfer(_to,_value);
        }else {
            return super.transfer(_to, _value);
        }
    }

    function transferFrom(address _from, address _to, uint _value) validDestination(_to) returns (bool) {
        require(transferEnabled == true);
        // The sender is in locked address list
        if(lockStartTime[_from] > 0) {
            return super.lockTransferFrom(_from,_to,_value);
        }else {
            return super.transferFrom(_from, _to, _value);
        }
    }


    function emergencyERC20Drain( ERC20 token, uint amount ) onlyOwner {
        token.transfer( owner, amount );
    }

    function setTransferEnable(bool enable) onlyOwner {
        transferEnabled = enable;
    }
}