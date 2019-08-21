pragma solidity ^0.4.24;

contract ERC20Interface {
    function totalSupply() public view returns (uint);
    function balanceOf(address tokenOwner) public view returns (uint balance);
    function transfer(address to, uint tokens) public returns (bool success);

    
    //function allowance(address tokenOwner, address spender) public view returns (uint remaining);
    //function approve(address spender, uint tokens) public returns (bool success);
    //function transferFrom(address from, address to, uint tokens) public returns (bool success);
    
    event Transfer(address indexed from, address indexed to, uint tokens);
    //event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
}

contract Ownable {
  address public owner;

  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

  constructor() public {
    owner = msg.sender;
  }

  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

  function transferOwnership(address newOwner) public onlyOwner {
    require(newOwner != address(0));
    emit OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }

}


contract ZCOR is ERC20Interface, Ownable{
    string public name = "ZROCOR";
    string public symbol = "ZCOR";
    uint public decimals = 0;
    
    uint public supply;
    address public founder;
    
    mapping(address => uint) public balances;
    mapping(uint => mapping(address => uint)) public timeLockedBalances;
    mapping(uint => address[]) public lockedAddresses;


 event Transfer(address indexed from, address indexed to, uint tokens);


    constructor() public{
        supply = 10000000000;
        founder = msg.sender;
        balances[founder] = supply;
    }
    
    // transfer locked balance to an address
    function transferLockedBalance(uint _category, address _to, uint _value) public onlyOwner returns (bool success) {
        require(balances[msg.sender] >= _value && _value > 0);
        lockedAddresses[_category].push(_to);
        balances[msg.sender] -= _value;
        timeLockedBalances[_category][_to] += _value;
        emit Transfer(msg.sender, _to, _value);
        return true;
    }
    
    // unlock category of locked address
    function unlockBalance(uint _category) public onlyOwner returns (bool success) {
        uint _length = lockedAddresses[_category].length;
        address _addr;
        uint _value = 0;
        for(uint i = 0; i< _length; i++) {
            _addr = lockedAddresses[_category][i];
            _value = timeLockedBalances[_category][_addr];
            balances[_addr] += _value;
            timeLockedBalances[_category][_addr] = 0;
        }
        delete lockedAddresses[_category];
        return true;
    }
    
    //view locked balance
    function lockedBalanceOf(uint level, address _address) public view returns (uint balance) {
        return timeLockedBalances[level][_address];
    }
    
    function totalSupply() public view returns (uint){
        return supply;
    }
    
    function balanceOf(address tokenOwner) public view returns (uint balance){
        return balances[tokenOwner];
    }
     
     
    //transfer from the owner balance to another address
    function transfer(address to, uint tokens) public returns (bool success){
        require(balances[msg.sender] >= tokens && tokens > 0);
         
        balances[to] += tokens;
        balances[msg.sender] -= tokens;
        emit Transfer(msg.sender, to, tokens);
        return true;
    }
     
     
    function burn(uint256 _value) public onlyOwner returns (bool success) {
        require(balances[founder] >= _value);   // Check if the sender has enough
        balances[founder] -= _value;            // Subtract from the sender
        supply -= _value;                      // Updates totalSupply
        return true;
    }

    function mint(uint256 _value) public onlyOwner returns (bool success) {
        require(balances[founder] >= _value);   // Check if the sender has enough
        balances[founder] += _value;            // Add to the sender
        supply += _value;                      // Updates totalSupply
        return true;
    }
     
}