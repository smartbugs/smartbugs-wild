pragma solidity ^0.4.24;

library SafeMath {
    function add(uint a, uint b) internal pure returns (uint c) {
        c = a + b;
        require(c >= a);
    }
    function sub(uint a, uint b) internal pure returns (uint c) {
        require(b <= a);
        c = a - b;
    }
    function mul(uint a, uint b) internal pure returns (uint c) {
        c = a * b;
        require(a == 0 || c / a == b);
    }
    function div(uint a, uint b) internal pure returns (uint c) {
        require(b > 0);
        c = a / b;
    }
}

contract ERC20Interface {
    function totalSupply() public constant returns (uint);
    function balanceOf(address tokenOwner) public constant returns (uint balance);
    function allowance(address tokenOwner, address spender) public constant returns (uint remaining);
    function transfer(address to, uint tokens) public returns (bool success);
    function approve(address spender, uint tokens) public returns (bool success);
    function transferFrom(address from, address to, uint tokens) public returns (bool success);
    function mint(address _to,uint256 _amount) public returns (bool);

    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
    event Mint(address indexed to, uint256 amount);
}

contract ApproveAndCallFallBack {
    function receiveApproval(address from, uint256 tokens, address token, bytes data) public;
}


contract Owned {
    address public owner;
    address public newOwner;
  

    event OwnershipTransferred(address indexed _from, address indexed _to);

    constructor() public {
        owner = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    function transferOwnership(address _newOwner) public onlyOwner {
        newOwner = _newOwner;
    }
    function acceptOwnership() public {
        require(msg.sender == newOwner);
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
        newOwner = address(0);
    }
}
interface Estate{
    function newContracts(uint _index) external view returns(address);
    function box_contract_amount()external view returns(uint);
}


interface Test{
  function mint(address _to,uint256 _amount) external;
  function burn(address _to,uint256 _amount) external;
  function setName(string _name, string _symbol) external;
  function balanceOf(address tokenOwner) external view returns (uint);
} 

contract Factory is Owned{
    
    mapping(uint8 => mapping(uint8 => address)) public MaterialTokens;
    address mix_address;
    address boxFactory_address;
    
    function control(uint8 boxIndex, uint8 materialIndex, address _addr, uint _value) public{  
        require(checkBox());
        Test test = Test(MaterialTokens[boxIndex][materialIndex]); 
        test.mint(_addr, _value); 
    }
    
    function control_burn(uint8 boxIndex, uint8 materialIndex, address _addr, uint _value) public{ 
        require(msg.sender == mix_address);
        Test test = Test(MaterialTokens[boxIndex][materialIndex]); 
        test.burn(_addr, _value); 
    }
      
    function createContract(uint8 boxIndex, uint8 materialIndex, string _name, string _symbol) public onlyOwner{
        address newContract = new MaterialToken(_name, _symbol);
        
        MaterialTokens[boxIndex][materialIndex] = newContract;
    }  
    
    function controlSetName(uint8 boxIndex, uint8 materialIndex, string _name, string _symbol) public onlyOwner{
        Test test = Test(MaterialTokens[boxIndex][materialIndex]);
        test.setName(_name,_symbol);
    }
    
    function controlSearchCount(uint8 boxIndex, uint8 materialIndex,address target)public view returns (uint) {
         Test test = Test(MaterialTokens[boxIndex][materialIndex]);
         return test.balanceOf(target);
    }
    
    function set_mix_contract(address _mix_address) public onlyOwner{
        mix_address = _mix_address;
    }
    
    function checkBox() public view returns(bool){
        uint length = Estate(boxFactory_address).box_contract_amount();
        for(uint i=0;i<length;i++){
             address box_address = Estate(boxFactory_address).newContracts(i);
             if(msg.sender == box_address){
                 return true;
             }
        }
        return false;
         
    }
    
    function set_boxFactory_addressl(address _boxFactory_address) public onlyOwner {
        boxFactory_address = _boxFactory_address;
    }
    

}

contract MaterialToken is ERC20Interface, Owned {
    using SafeMath for uint;

    string public symbol;
    string public  name;
    uint _totalSupply;

    mapping(address => uint) balances;
    mapping(address => mapping(address => uint)) allowed;
    

    constructor(string _name, string _symbol) public {
        symbol = _symbol;
        name = _name;
        _totalSupply = 0;
        balances[owner] = _totalSupply;

        emit Transfer(address(0), owner, _totalSupply);
    }
    
    
    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }
    
    function mint(address _to,uint256 _amount)public onlyOwner returns (bool) {
        
        _totalSupply = _totalSupply.add(_amount);
        
        balances[_to] = balances[_to].add(_amount);
        
        emit Mint(_to, _amount);
        
        emit Transfer(address(0), _to, _amount);
        return true;
    }
    
    function burn(address _to,uint256 _amount)public onlyOwner returns (bool)  {
        require(balances[_to] >= _amount);
        
        _totalSupply = _totalSupply.sub(_amount);
        
        balances[_to] = balances[_to].sub(_amount);
        
        emit Mint(_to, _amount);
        
        emit Transfer(_to, address(0), _amount);
        return true;
    }
   
    
    function setName(string _name, string _symbol)public onlyOwner{
        symbol = _symbol;
        name = _name;
    }


    function totalSupply() public view returns (uint) {
        return _totalSupply.sub(balances[address(0)]);
    }


    function balanceOf(address tokenOwner) public view returns (uint balance) {
        return balances[tokenOwner];
    }


    function transfer(address to, uint tokens) public returns (bool success) {
        balances[msg.sender] = balances[msg.sender].sub(tokens);
        balances[to] = balances[to].add(tokens);
        emit Transfer(msg.sender, to, tokens);
        return true;
    }


    function approve(address spender, uint tokens) public returns (bool success) {
        allowed[msg.sender][spender] = tokens;
        emit Approval(msg.sender, spender, tokens);
        return true;
    }


    function transferFrom(address from, address to, uint tokens) public returns (bool success) {
        balances[from] = balances[from].sub(tokens);
        allowed[from][msg.sender] = allowed[from][msg.sender].sub(tokens);
        balances[to] = balances[to].add(tokens);
        emit Transfer(from, to, tokens);
        return true;
    }


    function allowance(address tokenOwner, address spender) public view returns (uint remaining) {
        return allowed[tokenOwner][spender];
    }


    function approveAndCall(address spender, uint tokens, bytes data) public returns (bool success) {
        allowed[msg.sender][spender] = tokens;
        emit Approval(msg.sender, spender, tokens);
        ApproveAndCallFallBack(spender).receiveApproval(msg.sender, tokens, this, data);
        return true;
    }


    function () public payable {
        revert();
    }


    function transferAnyERC20Token(address tokenAddress, uint tokens) public onlyOwner returns (bool success) {
        return ERC20Interface(tokenAddress).transfer(owner, tokens);
    }
}