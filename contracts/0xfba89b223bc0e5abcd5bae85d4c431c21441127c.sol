pragma solidity ^0.5.1;

contract Owned {
    modifier onlyOwner() {
        require(msg.sender==owner);
        _;
    }
    address payable owner;
    address payable newOwner;
    function changeOwner(address payable _newOwner) public onlyOwner {
        newOwner=_newOwner;
    }
    function acceptOwnership() public {
        if (msg.sender==newOwner) {
            owner=newOwner;
        }
    }
}

contract ERC20 {
    function balanceOf(address _owner) view public returns (uint256 balance);
    function transfer(address _to, uint256 _value) public returns (bool success);
}

contract SmartWebLock is Owned{
    string public domain;
    uint8 public fee;
    uint256 public unlock;
    uint8 public bonus;
    address public token;
    uint8 public tokens;
    address payable payee;
    mapping (address=>uint) unlocks;
    mapping (address=>address payable) refs;
    mapping (address=>uint256) balances;
    event Bonus(address indexed _user, uint256 _amount);
        
    constructor() public{
        domain = 'videoblog.io';
        fee = 2;
        unlock = 100000000000000000;
        bonus = 49;
        token = 0xCD8aAC9972dc4Ddc48d700bc0710C0f5223fBCfa;
        tokens = 100;
        payee = 0x574c4DB1E399859753A09D65b6C5586429663701;
        owner = msg.sender;
    }
    
    function changeTokens (uint8 _tokens) public returns (bool success){
        require(_tokens>0 && msg.sender==payee);
        tokens=_tokens;
        return true;
    }
    
    function changeBonus (uint8 _bonus) public returns (bool success){
        require (_bonus>0 && _bonus<100-fee && msg.sender==payee);
        bonus=_bonus;
        return true;
    }
    
    function changeUnlock(uint256 _unlock) public returns (bool success){
        require(_unlock>0 && msg.sender==payee);
        unlock = _unlock;
        return true;
    }
    
    function changeRef(address _user, address payable _ref) public returns (bool success){
        require(_ref!=address(0x0) && refs[_user]!=_ref && msg.sender==payee);
        refs[_user] = _ref;
        return true;
    }
    
    function changeFee (uint8 _fee) onlyOwner public returns (bool success){
        require (_fee>0 && _fee<10);
        fee=_fee;
        return true;
    }
    
    function setRef(address payable _ref) public returns (bool success){
        require (_ref!=address(0x0) && refs[msg.sender]==address(0x0) && _ref!=msg.sender);
        refs[msg.sender] = _ref;
        return true;
    }
    
    function getBalance(address _user) view public returns (uint256 balance){
        return balances[_user];
    }
    
    function getUnlock(address _user) view public returns (uint timestamp){
        return unlocks[_user];
    }
    
    function getRef(address _user) view public returns (address ref){
        return refs[_user];
    }
    
    function unLock(uint256 _amount) private{
        balances[msg.sender]+=_amount;
        if (balances[msg.sender]>=unlock) {
            unlocks[msg.sender] = block.timestamp;
            uint256 payout = 0;
            if (refs[msg.sender]!=address(0x0) && bonus>0) {
                payout = bonus*_amount/100;
                refs[msg.sender].transfer(payout);
                emit Bonus(refs[msg.sender],payout);
            }
            uint256 deduct = _amount*fee/100;
            owner.transfer(deduct);
            payee.transfer(_amount-payout-deduct);
            if (ERC20(token).balanceOf(address(this))>=tokens) ERC20(token).transfer(msg.sender, tokens);
        }
    }
    
    function () payable external {
        require(msg.value>0);
        unLock(msg.value);
    }
}