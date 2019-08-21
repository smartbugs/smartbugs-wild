pragma solidity ^0.4.17;

//Developed by Zenos Pavlakou

library SafeMath {
    
    function mul(uint256 a, uint256 b) internal pure  returns (uint256) {
        uint256 c = a * b;
        assert(a == 0 || c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a / b;
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }
}


contract Ownable {
    
    address public owner;

    /**
     * The address whcih deploys this contrcat is automatically assgined ownership.
     * */
    function Ownable() public {
        owner = msg.sender;
    }

    /**
     * Functions with this modifier can only be executed by the owner of the contract. 
     * */
    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }
}


contract ERC20Basic {
    uint256 public totalSupply;
    function balanceOf(address who) constant public returns (uint256);
    function transfer(address to, uint256 value) public returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
}


contract ERC20 is ERC20Basic {
    function allowance(address owner, address spender) constant public returns (uint256);
    function transferFrom(address from, address to, uint256 value) public  returns (bool);
    function approve(address spender, uint256 value) public returns (bool);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}


contract BasicToken is ERC20Basic, Ownable {

    using SafeMath for uint256;

    mapping (address => uint256) balances;

    modifier onlyPayloadSize(uint size) {
        if (msg.data.length < size + 4) {
        revert();
        }
        _;
    }

    /**
     * Transfers ACO tokens from the sender's account to another given account.
     * 
     * @param _to The address of the recipient.
     * @param _amount The amount of tokens to send.
     * */
    function transfer(address _to, uint256 _amount) public onlyPayloadSize(2 * 32) returns (bool) {
        require(balances[msg.sender] >= _amount);
        balances[msg.sender] = balances[msg.sender].sub(_amount);
        balances[_to] = balances[_to].add(_amount);
        Transfer(msg.sender, _to, _amount);
        return true;
    }

    /**
     * Returns the balance of a given address.
     * 
     * @param _addr The address of the balance to query.
     **/
    function balanceOf(address _addr) public constant returns (uint256) {
        return balances[_addr];
    }
}


contract AdvancedToken is BasicToken, ERC20 {

    mapping (address => mapping (address => uint256)) allowances;

    /**
     * Transfers tokens from the account of the owner by an approved spender. 
     * The spender cannot spend more than the approved amount. 
     * 
     * @param _from The address of the owners account.
     * @param _amount The amount of tokens to transfer.
     * */
    function transferFrom(address _from, address _to, uint256 _amount) public onlyPayloadSize(3 * 32) returns (bool) {
        require(allowances[_from][msg.sender] >= _amount && balances[_from] >= _amount);
        allowances[_from][msg.sender] = allowances[_from][msg.sender].sub(_amount);
        balances[_from] = balances[_from].sub(_amount);
        balances[_to] = balances[_to].add(_amount);
        Transfer(_from, _to, _amount);
        return true;
    }

    /**
     * Allows another account to spend a given amount of tokens on behalf of the 
     * owner's account. If the owner has previously allowed a spender to spend
     * tokens on his or her behalf and would like to change the approval amount,
     * he or she will first have to set the allowance back to 0 and then update
     * the allowance.
     * 
     * @param _spender The address of the spenders account.
     * @param _amount The amount of tokens the spender is allowed to spend.
     * */
    function approve(address _spender, uint256 _amount) public returns (bool) {
        require((_amount == 0) || (allowances[msg.sender][_spender] == 0));
        allowances[msg.sender][_spender] = _amount;
        Approval(msg.sender, _spender, _amount);
        return true;
    }


    /**
     * Returns the approved allowance from an owners account to a spenders account.
     * 
     * @param _owner The address of the owners account.
     * @param _spender The address of the spenders account.
     **/
    function allowance(address _owner, address _spender) public constant returns (uint256) {
        return allowances[_owner][_spender];
    }
}


contract MintableToken is AdvancedToken {

    bool public mintingFinished;

    event TokensMinted(address indexed to, uint256 amount);
    event MintingFinished();

    /**
     * Generates new ACO tokens during the ICO, after which the minting period 
     * will terminate permenantly. This function can only be called by the ICO 
     * contract.
     * 
     * @param _to The address of the account to mint new tokens to.
     * @param _amount The amount of tokens to mint. 
     * */
    function mint(address _to, uint256 _amount) external onlyOwner onlyPayloadSize(2 * 32) returns (bool) {
        require(_to != 0x0 && _amount > 0 && !mintingFinished);
        balances[_to] = balances[_to].add(_amount);
        totalSupply = totalSupply.add(_amount);
        Transfer(0x0, _to, _amount);
        TokensMinted(_to, _amount);
        return true;
    }

    /**
     * Terminates the minting period permenantly. This function can only be called
     * by the ICO contract only when the duration of the ICO has ended. 
     * */
    function finishMinting() external onlyOwner {
        require(!mintingFinished);
        mintingFinished = true;
        MintingFinished();
    }
    
    /**
     * Returns true if the minting period has ended, false otherwhise.
     * */
    function mintingFinished() public constant returns (bool) {
        return mintingFinished;
    }
}

contract ACO is MintableToken {

    uint8 public decimals;
    string public name;
    string public symbol;

    function ACO() public {
        totalSupply = 0;
        decimals = 18;
        name = "ACO";
        symbol = "ACO";
    }
}