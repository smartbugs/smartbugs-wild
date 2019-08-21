pragma solidity ^0.4.25;


contract Owner{
    
    address public owner;
    
    uint public ownerIncome;
    
    constructor()public {
        owner=msg.sender;
    }
    
    modifier onlyOwner(){
        
        require(msg.sender == owner,"you are not the owner");
        _;
    }
    
    function transferOwnership(address newOwner)public onlyOwner{
     
        owner = newOwner;
    }
    
    function ownerWithDraw()public onlyOwner{
        owner.transfer(ownerIncome);
        ownerIncome=0;
    }
}

interface tokenRecipient { 
    function receiveApproval(address _from, uint256 _value, address _token, bytes _extraData) external;
    function receiveApprovalStr(address _from, uint256 _value, address _token, string _extraData) external;
    function toMakeSellOrder(address _from, uint256 _value, address _token, uint _amtMin,uint _amtMax,uint _price) external;
    function toModifySellOrder(address _from, uint256 _value, address _token, uint _id,uint _amtMin,uint _amtMax,uint _price) external;
    function toTakeBuyOrder(address _from, uint256 _value, address _token, uint _id,uint _takeAmt) external;
    function toRegisteName(address _from, uint256 _value, address _token, string _name) external;
    function toBuyName(address _from, uint256 _value, address _token, string _name) external;
    function toGetPaidContent(address _from, uint256 _value, address _token, uint _id) external;
}

contract TokenERC20 is Owner{
    // Public variables of the token
    string public name="DASS";
    string public symbol="DASS";
    uint8 public decimals = 18;
    // 18 decimals is the strongly suggested default, avoid changing it
    uint256 public totalSupply=10000000000 * 10 ** uint256(decimals);

    // This creates an array with all balances
    mapping (address => uint256) public balanceOf;
    mapping (address => mapping (address => uint256)) public allowance;

    event Transfer(address indexed from, address indexed to, uint256 value);
    
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);

    event Burn(address indexed from, uint256 value);
    
    /**
     * Constructor function
     *
     * Initializes contract with initial supply tokens to the creator of the contract
     */
    constructor() public {
        balanceOf[msg.sender] = totalSupply;                // Give the creator all initial tokens
    }
    
    function _transfer(address _from, address _to, uint _value) internal {
        require(_to != address(0x0),"address _to must not be 0x0");
        require(balanceOf[_from] >= _value,"balanceOf _from is not enough");
        // Check for overflows
        require(balanceOf[_to] + _value >= balanceOf[_to],"check overflows fail");
        // Save this for an assertion in the future
        uint previousBalances = balanceOf[_from] + balanceOf[_to];
        balanceOf[_from] -= _value;
        balanceOf[_to] += _value;
        emit Transfer(_from, _to, _value);
        // Asserts are used to use static analysis to find bugs in your code. They should never fail
        assert(balanceOf[_from] + balanceOf[_to] == previousBalances);
    }

    
    function transfer(address _to, uint256 _value) public returns (bool success) {
        _transfer(msg.sender, _to, _value);
        return true;
    }

    
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require(_value <= allowance[_from][msg.sender],"_value exceed allowance");     // Check allowance
        allowance[_from][msg.sender] -= _value;
        _transfer(_from, _to, _value);
        return true;
    }

    
    function approve(address _spender, uint256 _value) public
        returns (bool success) {
        require(balanceOf[msg.sender] >= _value,"balanceOf msg.sender is not enough");
        allowance[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    
    function approveAndCall(address _spender, uint256 _value, bytes _extraData)
        public
        returns (bool success) {
        tokenRecipient spender = tokenRecipient(_spender);
        if (approve(_spender, _value)) {
            spender.receiveApproval(msg.sender, _value, address(this), _extraData);
            return true;
        }
    }
    
    function approveAndCallStr(address _spender, uint256 _value, string _extraData)
        public
        returns (bool success) {
        tokenRecipient spender = tokenRecipient(_spender);
        if (approve(_spender, _value)) {
            spender.receiveApprovalStr(msg.sender, _value, address(this), _extraData);
            return true;
        }
    }

    
    function burn(uint256 _value) public returns (bool success) {
        require(balanceOf[msg.sender] >= _value,"balanceOf is not enough");   // Check if the sender has enough
        balanceOf[msg.sender] -= _value;            // Subtract from the sender
        totalSupply -= _value;                      // Updates totalSupply
        emit Burn(msg.sender, _value);
        return true;
    }

    
    function burnFrom(address _from, uint256 _value) public returns (bool success) {
        require(balanceOf[_from] >= _value,"balanceOf is not enough");                // Check if the targeted balance is enough
        require(_value <= allowance[_from][msg.sender],"allowance is not enough");    // Check allowance
        balanceOf[_from] -= _value;                         // Subtract from the targeted balance
        allowance[_from][msg.sender] -= _value;             // Subtract from the sender's allowance
        totalSupply -= _value;                              // Update totalSupply
        emit Burn(_from, _value);
        return true;
    }
    
    function makeSellOrder(address _spender, uint256 _value,uint _amtMin,uint _amtMax,uint _price)
        public
        returns (bool success) {
        tokenRecipient spender = tokenRecipient(_spender);
        if (approve(_spender, _value)) {
            spender.toMakeSellOrder(msg.sender, _value, address(this), _amtMin,_amtMax,_price);
            return true;
        }
    }
    
    
    function modifySellOrder(address _spender, uint256 _value,uint _id,uint _amtMin,uint _amtMax,uint _price)
        public
        returns (bool success) {
        tokenRecipient spender = tokenRecipient(_spender);
        if (approve(_spender, _value)) {
            spender.toModifySellOrder(msg.sender, _value, address(this),_id, _amtMin,_amtMax,_price);
            return true;
        }
    }
    
    function takeBuyOrder(address _spender, uint256 _value,uint _id,uint _takeAmt)
        public
        returns (bool success) {
        tokenRecipient spender = tokenRecipient(_spender);
        if (approve(_spender, _value)) {
            spender.toTakeBuyOrder(msg.sender, _value, address(this),_id, _takeAmt);
            return true;
        }
    }
    
    function registeName(address _spender, uint256 _value,string _name)
        public
        returns (bool success) {
        tokenRecipient spender = tokenRecipient(_spender);
        if (approve(_spender, _value)) {
            spender.toRegisteName(msg.sender, _value, address(this),_name);
            return true;
        }
    }
    
    function buyName(address _spender, uint256 _value,string _name)
        public
        returns (bool success) {
        tokenRecipient spender = tokenRecipient(_spender);
        if (approve(_spender, _value)) {
            spender.toBuyName(msg.sender, _value, address(this),_name);
            return true;
        }
    }
    
    function getPaidContent(address _spender, uint256 _value,uint _id)
        public
        returns (bool success) {
        tokenRecipient spender = tokenRecipient(_spender);
        if (approve(_spender, _value)) {
            spender.toGetPaidContent(msg.sender, _value, address(this),_id);
            return true;
        }
    }
    
}