pragma solidity ^0.4.23;


contract owned {
    address public owner;

    constructor() public {
        owner = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }
}

interface tokenRecipient { function receiveApproval(address _from, uint256 _value, address _token, bytes _extraData) external; }

contract Relotto is owned {
    string public name;
    string public symbol;
    uint8 public decimals = 18;    
    uint256 public totalSupply;
    bool internal greenlight;
    address public payer;

    
    mapping (address => uint256) public balanceOf;
    mapping (address => mapping (address => uint256)) public allowance;
    mapping (address => bool) public holderpayed;

    
    event Transfer(address indexed from, address indexed to, uint256 value);
    
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);

    event Payment(address indexed _payer, uint256 values);

    
    constructor(
        uint256 initialSupply,
        string tokenName,
        string tokenSymbol
    ) public {
        totalSupply = initialSupply * 10 ** uint256(decimals);  
        balanceOf[msg.sender] = totalSupply;                
        name = tokenName;                                   
        symbol = tokenSymbol;
        greenlight = false;
        payer = msg.sender;
    }

    function _transfer(address _from, address _to, uint _value) internal {
       
        require(_to != 0x0);
        
        require(balanceOf[_from] >= _value);
        
        require(balanceOf[_to] + _value > balanceOf[_to]);               
        
        uint previousBalances = balanceOf[_from] + balanceOf[_to];
        
        balanceOf[_from] -= _value;
        
        balanceOf[_to] += _value;

        emit Transfer(_from, _to, _value);
        
        assert(balanceOf[_from] + balanceOf[_to] == previousBalances);
    }

    
    function transfer(address _to, uint256 _value) public returns (bool success) {
        _transfer(msg.sender, _to, _value);
        return true;
    }
    
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require(_value <= allowance[_from][msg.sender]);     
        allowance[_from][msg.sender] -= _value;
        _transfer(_from, _to, _value);
        return true;
    }
   
    function approve(address _spender, uint256 _value) public
        returns (bool success) {
        allowance[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }
    
    function approveAndCall(address _spender, uint256 _value, bytes _extraData)
        public
        returns (bool success) {
        tokenRecipient spender = tokenRecipient(_spender);
        if (approve(_spender, _value)) {
            spender.receiveApproval(msg.sender, _value, this, _extraData);
            return true;
        }
    }

    function SetPayerAddress(address _payer) onlyOwner public
        returns (bool success){
        payer = _payer;
        return true;
    }

    function ApprovePayment() onlyOwner public
        returns (bool success) {            
        require(address(payer).balance > 0); 
        greenlight = true;
        emit Payment(payer,address(payer).balance);
        return true;
    }

    function EndofPayment() onlyOwner public
        returns (bool success) {
        greenlight = false;
        return true;
    }

    function RequestPayment(address _holder) public {
        address myAddress = payer;
        require(greenlight);
        require(!holderpayed[_holder]);              
        _holder.transfer(balanceOf[_holder] * myAddress.balance / totalSupply);
        holderpayed[_holder] = true;          
    }

    function ReNew(address _holder) public {
        require(!greenlight);
        require(holderpayed[_holder]);
        holderpayed[_holder] = false;
    }
}