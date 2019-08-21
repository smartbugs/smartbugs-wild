// Roman Storm Multi Sender
pragma solidity 0.4.20;


/**
 * @title ERC20Basic
 * @dev Simpler version of ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/179
 */
contract ERC20Basic {
  function totalSupply() public view returns (uint256);
  function balanceOf(address who) public view returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}

contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender) public view returns (uint256);
  function transferFrom(address from, address to, uint256 value) public returns (bool);
  function approve(address spender, uint256 value) public returns (bool);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}


contract MultiSender {
    mapping(address => uint256) public txCount;
    address public owner;
    address public pendingOwner;
    uint16 public arrayLimit = 150;
    uint256 public fee = 0.05 ether;
    
    modifier onlyOwner(){
        assert(msg.sender == owner);
        _;
    }
    
    modifier hasFee(){
        // uint256 fee = txCount[msg.sender]
        require(msg.value >= fee - discountRate(msg.sender));
        _;
    }
    function MultiSender(address _owner, address _pendingOwner){
        owner = _owner;
        pendingOwner = _pendingOwner;
    }
    
    function discountRate(address _customer) public view returns(uint256) {
        uint256 count = txCount[_customer];
        return count / (10) * 0.005 ether;
    }
    
    function currentFee(address _customer) public view returns(uint256) {
        return fee - discountRate(_customer);
    }
    
    function claimOwner(address _newPendingOwner) public {
        require(msg.sender == pendingOwner);
        owner = pendingOwner;
        pendingOwner = _newPendingOwner;
    }
    
    function changeTreshold(uint16 _newLimit) public onlyOwner {
        arrayLimit = _newLimit;
    }
    
    function changeFee(uint256 _newFee) public onlyOwner {
        fee = _newFee;
    }
    
    function() payable {
    }
    
    function multisendToken(address token, address[] _contributors, uint256[] _balances) public hasFee payable {
        require(_contributors.length <= arrayLimit);
        ERC20 erc20token = ERC20(token);
        uint8 i = 0;
        require(erc20token.allowance(msg.sender, this) > 0);
        for(i; i<_contributors.length;i++){
            erc20token.transferFrom(msg.sender, _contributors[i], _balances[i]);
        }
        txCount[msg.sender]++;
    }
    
    function multisendEther(address[] _contributors, uint256[] _balances) public hasFee payable{
        // this function is always free, however if there is anything left over, I will keep it.
        require(_contributors.length <= arrayLimit);
        uint8 i = 0;
        for(i; i<_contributors.length;i++){
            _contributors[i].transfer(_balances[i]);
        }
        txCount[msg.sender]++;
    }
    
    event ClaimedTokens(address token, address owner, uint256 balance);
    function claimTokens(address _token) public onlyOwner {
        if (_token == 0x0) {
          owner.transfer(this.balance);
          return;
        }
        ERC20 erc20token = ERC20(_token);
        uint256 balance = erc20token.balanceOf(this);
        erc20token.transfer(owner, balance);
        ClaimedTokens(_token, owner, balance);
   }
}