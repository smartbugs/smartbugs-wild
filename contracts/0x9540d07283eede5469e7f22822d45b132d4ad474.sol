pragma solidity ^0.5.00;

interface ERC20TokenInterface {
  function totalSupply() external returns (uint256 _totalSupply);
  function balanceOf(address _owner) external returns (uint256 balance) ;
  function transfer(address _to, uint256 _value) external returns (bool success);
  function transferFrom(address _from, address _to, uint256 _value) external returns (bool success);
  function approve(address _spender, uint256 _value) external returns (bool success);
  function allowance(address _owner, address _spender) external returns (uint256 remaining);

  event Transfer(address indexed _from, address indexed _to, uint256 _value);
  event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}

contract Owned {
    address payable public owner;
    address payable public newOwner;

    constructor() public {
        owner = msg.sender;
    }

    modifier onlyOwner {
        assert(msg.sender == owner);
        _;
    }

    function transferOwnership(address payable _newOwner) public onlyOwner {
        require(_newOwner != owner);
        newOwner = _newOwner;
    }

    function acceptOwnership() public {
        require(msg.sender == newOwner);
        emit OwnerUpdate(owner, newOwner);
        owner = newOwner;
        newOwner = address(0x0);
    }

    event OwnerUpdate(address _prevOwner, address _newOwner);
}

contract TokenWatcher is Owned {
    address public tokenAddress;
    uint public timeStart;
    uint public timeStop;
    
    address payable public holder1;
    address payable public holder2;
    uint public holder1Balance;
    uint public holder2Balance;
    
    address payable public creditor;
    
    event DepositCredited(uint _amount);
    
    constructor() public {
        tokenAddress = address(0x64CdF819d3E75Ac8eC217B3496d7cE167Be42e80);
        holder1 = address(0xFaF6A6Fd1e53AAa5F00940B123f7504B2dFBDa76);
        holder2 = address(0x496A65376dc258c38866BDF3ED149e3B3b540b7B);
        creditor = address(0xCC6326d7Ebdd88477bc4C76285Fd1b7661191aCc);
        holder1Balance = ERC20TokenInterface(tokenAddress).balanceOf(holder1);
        holder2Balance = ERC20TokenInterface(tokenAddress).balanceOf(holder2);
        timeStart = now;
        timeStop = now + 365 days; // one year since 11.12.2018
    }
    
    function withdrawEthToHolders() public {
        require(now > timeStop);
        holder1.transfer(address(this).balance/2);
        holder2.transfer(address(this).balance);
    }
    
    function withdrawEthToCreditor() public{
        require(now <= timeStop);
        uint tempBalance = ERC20TokenInterface(tokenAddress).balanceOf(holder1) + ERC20TokenInterface(tokenAddress).balanceOf(holder2);
        require(holder1Balance + holder2Balance > tempBalance);
        creditor.transfer(address(this).balance);
    }
    
    function depositFunds() public payable onlyOwner {
        emit DepositCredited(msg.value);
    }
    
    function getTime() public view returns (uint){
        return now;
    }
    
    function contractBalance() public view returns (uint){
        return address(this).balance;
    }
    
    function kill() public onlyOwner {
        selfdestruct(owner);
    }
}