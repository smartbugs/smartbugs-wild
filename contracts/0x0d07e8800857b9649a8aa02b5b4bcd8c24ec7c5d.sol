pragma solidity ^0.4.24;

contract Owned {
    
    /// 'owner' is the only address that can call a function with 
    /// this modifier
    address public owner;
    address internal newOwner;
    
    ///@notice The constructor assigns the message sender to be 'owner'
    constructor() public {
        owner = msg.sender;
    }
    
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }
    
    event updateOwner(address _oldOwner, address _newOwner);
    
    ///change the owner
    function changeOwner(address _newOwner) public onlyOwner returns(bool) {
        require(owner != _newOwner);
        newOwner = _newOwner;
        return true;
    }
    
    /// accept the ownership
    function acceptNewOwner() public returns(bool) {
        require(msg.sender == newOwner);
        emit updateOwner(owner, newOwner);
        owner = newOwner;
        return true;
    }
}

contract SafeMath {
    function safeMul(uint a, uint b) pure internal returns (uint) {
        uint c = a * b;
        assert(a == 0 || c / a == b);
        return c;
    }
    
    function safeSub(uint a, uint b) pure internal returns (uint) {
        assert(b <= a);
        return a - b;
    }
    
    function safeAdd(uint a, uint b) pure internal returns (uint) {
        uint c = a + b;
        assert(c>=a && c>=b);
        return c;
    }

}

contract ERC20Token {
    /* This is a slight change to the ERC20 base standard.
    function totalSupply() constant returns (uint256 supply);
    is replaced with:
    uint256 public totalSupply;
    This automatically creates a getter function for the totalSupply.
    This is moved to the base contract since public getter functions are not
    currently recognised as an implementation of the matching abstract
    function by the compiler.
    */
    /// total amount of tokens
    uint256 public totalSupply;
    
    /// user tokens
    mapping (address => uint256) public balances;
    
    /// @param _owner The address from which the balance will be retrieved
    /// @return The balance
    function balanceOf(address _owner) constant public returns (uint256 balance);

    /// @notice send `_value` token to `_to` from `msg.sender`
    /// @param _to The address of the recipient
    /// @param _value The amount of token to be transferred
    /// @return Whether the transfer was successful or not
    function transfer(address _to, uint256 _value) public returns (bool success);
    
    /// @notice send `_value` token to `_to` from `_from` on the condition it is approved by `_from`
    /// @param _from The address of the sender
    /// @param _to The address of the recipient
    /// @param _value The amount of token to be transferred
    /// @return Whether the transfer was successful or not
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);

    /// @notice `msg.sender` approves `_spender` to spend `_value` tokens
    /// @param _spender The address of the account able to transfer the tokens
    /// @param _value The amount of tokens to be approved for transfer
    /// @return Whether the approval was successful or not
    function approve(address _spender, uint256 _value) public returns (bool success);

    /// @param _owner The address of the account owning tokens
    /// @param _spender The address of the account able to transfer the tokens
    /// @return Amount of remaining tokens allowed to spent
    function allowance(address _owner, address _spender) constant public returns (uint256 remaining);

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}

contract CUSE is ERC20Token {
    
    string public name = "USE Call Option";
    string public symbol = "CUSE12";
    uint public decimals = 0;
    
    uint256 public totalSupply = 75000000;
    
    function transfer(address _to, uint256 _value) public returns (bool success) {
    //Default assumes totalSupply can't be over max (2^256 - 1).
    //If your token leaves out totalSupply and can issue more tokens as time goes on, you need to check if it doesn't wrap.
    //Replace the if with this one instead.
        if (balances[msg.sender] >= _value && balances[_to] + _value >= balances[_to]) {
            balances[msg.sender] -= _value;
            balances[_to] += _value;
            emit Transfer(msg.sender, _to, _value);
            return true;
        } else { return false; }
    }
    
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
    //same as above. Replace this line with the following if you want to protect against wrapping uints.
        if (balances[_from] >= _value && allowances[_from][msg.sender] >= _value && balances[_to] + _value >= balances[_to]) {
          balances[_to] += _value;
          balances[_from] -= _value;
          allowances[_from][msg.sender] -= _value;
          emit Transfer(_from, _to, _value);
          return true;
        } else { return false; }
    }
    
    function balanceOf(address _owner) constant public returns (uint256 balance) {
        return balances[_owner];
    }
    
    function approve(address _spender, uint256 _value) public returns (bool success) {
        allowances[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }
    
    function allowance(address _owner, address _spender) constant public returns (uint256 remaining) {
        return allowances[_owner][_spender];
    }
    
    mapping(address => uint256) public balances;
    
    mapping (address => mapping (address => uint256)) allowances;
}

contract ExchangeCUSE is SafeMath, Owned, CUSE {
    
    // Exercise End Time 1/1/2019 0:0:0
    uint public ExerciseEndTime = 1546272000;
    uint public exchangeRate = 13333 * 10**9 wei; //percentage times (1 ether)
    
    //mapping (address => uint) ustValue; //mapping of token addresses to mapping of account balances (token=0 means Ether)
    
    // UST address
    address public USEaddress = address(0xd9485499499d66B175Cf5ED54c0a19f1a6Bcb61A);
    
    // offical Address
    address public officialAddress = address(0x89Ead717c9DC15a222926221897c68F9486E7229);

    function execCUSEOption() public payable returns (bool) {
        require (now < ExerciseEndTime);
        
        // ETH user send
        uint _ether = msg.value;
        (uint _use, uint _refoundETH) = calcUSE(balances[msg.sender], _ether);
        
        // do exercise
        balances[msg.sender] = safeSub(balances[msg.sender], _use/(10**18));
        balances[officialAddress] = safeAdd(balances[officialAddress], _use/(10**18));
        require (CUSE(USEaddress).transferFrom(officialAddress, msg.sender, _use) == true);

        emit Transfer(msg.sender, officialAddress, _use/(10**18)); 
        
        // refound ETH
        needRefoundETH(_refoundETH);
        officialAddress.transfer(safeSub(_ether, _refoundETH));
    }
    
    // Calculate
    function calcUSE(uint _cuse, uint _ether) internal view returns (uint _use, uint _refoundETH) {
        uint _amount = _ether / exchangeRate;
        require (safeMul(_amount, exchangeRate) <= _ether);
        
        // Check Whether msg.sender Have Enough CUSE
        if (_amount <= _cuse) {
            _use = safeMul(_amount, 10**18);
            _refoundETH = 0;
            
        } else {
            _use = safeMul(_cuse, 10**18);
            _refoundETH = safeMul(safeSub(_amount, _cuse), exchangeRate);
        }
        
    }
    
    function needRefoundETH(uint _refoundETH) internal {
        if (_refoundETH > 0) {
            msg.sender.transfer(_refoundETH);
        }
    }
    
    function changeOfficialAddress(address _newAddress) public onlyOwner {
         officialAddress = _newAddress;
    }
}

contract USECallOption is ExchangeCUSE {

    function () payable public {
        revert();
    }

    // Allocate candy token
    function allocateCandyToken(address[] _owners, uint256[] _values) public onlyOwner {
       for(uint i = 0; i < _owners.length; i++){
		   balances[_owners[i]] = safeAdd(balances[_owners[i]], _values[i]); 
		   emit Transfer(address(this), _owners[i], _values[i]);  		  
        }
    }

    // only end time, onwer can transfer contract's ether out.
    function WithdrawETH() payable public onlyOwner {
        officialAddress.transfer(address(this).balance);
    } 
    
}