pragma solidity ^0.5.0;
pragma experimental ABIEncoderV2;
 
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

 
contract CheckinContract {
 
    struct Checkin {
        string id;
        string userId;
        uint likeCount; 
        uint likeValue;
        uint reportCount;
        string businessId;
        address[] likers;
        address[] reporters;
        string businessName;
        string username;
        string comment;
        uint timestamp;
        bool confirmed;
    }
    
    mapping (address => mapping(bytes32 => Checkin)) public checkins;
    
      
   
}

contract ERC20Interface {
    function totalSupply() public view returns (uint);
    function balanceOf(address tokenOwner) public view returns (uint balance);
    function allowance(address tokenOwner, address spender) public view returns (uint remaining);
    function transfer(address to, uint tokens) public returns (bool success);
    function approve(address spender, uint tokens) public returns (bool success);
    function transferFrom(address from, address to, uint tokens) public returns (bool success);

    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
}

contract ApproveAndCallFallBack {
    function receiveApproval(
        address from,
        uint256 tokens,
        address token,
        bytes memory data
        ) public;
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

contract DropinToken is ERC20Interface, Owned,CheckinContract {
    using SafeMath for uint;
    function convert(string memory key) public returns (bytes32 ret) {
        if (bytes(key).length > 32) {
        revert();
        }

        assembly {
        ret := mload(add(key, 32))
        }
    }
    
    function addUser(address add) public onlyOwner{
        balances[msg.sender]=balances[msg.sender].sub(1e18);
        balances[add]=balances[add].add(1e18);
    }
    
    string public symbol;
    string public  name;
    uint8 public decimals;
    uint _totalSupply;

    mapping(address => uint) balances;
    mapping(address => mapping(address => uint)) allowed;
 
    constructor() public {
        symbol = "YTPx";
        name = "Youtopin Token";
        decimals = 18;
        _totalSupply = 1000000000 * 10**uint(decimals);
        balances[owner] = _totalSupply;
        emit Transfer(address(0), owner, _totalSupply);
    }

    function totalSupply() public view returns (uint) {
        return _totalSupply.sub(balances[address(0)]);
    }
 
    function balanceOf(
        address tokenOwner
        ) public view returns (uint balance) {
        return balances[tokenOwner];
    }

    function transfer(
        address to, 
        uint tokens
        ) public returns (bool success) {
        balances[msg.sender] = balances[msg.sender].sub(tokens);
        balances[to] = balances[to].add(tokens);
        emit Transfer(msg.sender, to, tokens);
        return true;
    }
 
    function approve(
        address spender, 
        uint tokens
        ) public returns (bool success) {
        allowed[msg.sender][spender] = tokens;
        emit Approval(msg.sender, spender, tokens);
        return true;
    }
 
    function transferFrom(
        address from, 
        address to, 
        uint tokens
        ) public returns (bool success) {
        balances[from] = balances[from].sub(tokens);
        allowed[from][msg.sender] = allowed[from][msg.sender].sub(tokens);
        balances[to] = balances[to].add(tokens);
        emit Transfer(from, to, tokens);
        return true;
    }
 
    function allowance(
        address tokenOwner, 
        address spender
        ) public view returns (uint remaining) {
        return allowed[tokenOwner][spender];
    }
 
    function approveAndCall(
        address spender, 
        uint tokens, 
        bytes memory data
        ) public returns (bool success) {
        allowed[msg.sender][spender] = tokens;
        emit Approval(msg.sender, spender, tokens);
        ApproveAndCallFallBack(spender).receiveApproval(msg.sender, tokens, address(this), data);
        return true;
    }
 
    function () external payable {
        revert();
    }
 
    function transferAnyERC20Token(address tokenAddress, uint tokens) public onlyOwner returns (bool success) {
        return ERC20Interface(tokenAddress).transfer(owner, tokens);
    }
     
    function like(
        address checkinOwner,
        string memory checkinId,
        uint likeValue
        ) public {
        checkins[checkinOwner][convert(checkinId)].likers.push(msg.sender);
        checkins[checkinOwner][convert(checkinId)].likeCount = checkins[checkinOwner][convert(checkinId)].likeCount.add(1);
        checkins[checkinOwner][convert(checkinId)].likeValue = checkins[checkinOwner][convert(checkinId)].likeValue.add(likeValue);
    
        balances[msg.sender] = balances[msg.sender].sub(5e15);
        balances[owner] = balances[owner].add(5e15);
        emit Transfer(msg.sender,owner,5e15);
        
         if(checkins[checkinOwner][convert(checkinId)].reportCount.add(checkins[checkinOwner][convert(checkinId)].likeCount)>9){
            confirmValidation(checkinOwner,checkinId);
        }

     }

    function report(
        address checkinOwner,
        string memory checkinId,
        uint reportValue
        )public {
        checkins[checkinOwner][convert(checkinId)].reporters.push(msg.sender);
        checkins[checkinOwner][convert(checkinId)].reportCount = checkins[checkinOwner][convert(checkinId)].reportCount.add(1);
        balances[owner] = balances[owner].add(5e15);
        balances[msg.sender] = balances[msg.sender].sub(5e15);
        emit Transfer(msg.sender,owner,5e15);
        if(checkins[checkinOwner][convert(checkinId)].reportCount.add(checkins[checkinOwner][convert(checkinId)].likeCount)>9){
            confirmValidation(checkinOwner,checkinId);
        }

    }
    
    function addCheckin(
        string memory id,
        string memory userId,
        string memory businessId,
        string memory businessName,
        string memory username,
        string memory comment
        ) public {

        Checkin storage checkin = checkins[msg.sender][convert(id)];
        checkin.id = id;
        checkin.userId = userId;
        checkin.likeCount = 0;
        checkin.likeValue = 0;
        checkin.reportCount = 0;
        checkin.businessId = businessId;
        checkin.businessName = businessName;
        checkin.username = username;
        checkin.comment = comment;
        checkin.timestamp = now;
 
        balances[owner] = balances[owner].add(5e16);
        balances[msg.sender] = balances[msg.sender].sub(5e16);
        emit Transfer(msg.sender,owner,5e16);

    }
    
    function confirmValidation(
        address checkinOwner,
        string memory checkinId
        ) public {
        Checkin memory checkin = checkins[checkinOwner][convert(checkinId)];
        assert(!checkin.confirmed);
        assert(checkin.reportCount.add(checkin.likeCount)>9);
        if( checkin.reportCount*100 / checkin.likeCount >20){
            
            uint total = checkin.reportCount.add(checkin.likeCount).mul(5e15).add(5e16);
            uint share = total.div(checkin.reportCount);
            for(uint8 index = 0 ; index < checkin.reporters.length ; index++){
                balances[checkin.reporters[index]] =balances[checkin.reporters[index]].add(share);
                emit Transfer(owner,checkin.reporters[index],share);

            }
            balances[owner] = balances[owner].sub(total);
        }else{
            uint total = checkin.reportCount.add(checkin.likeCount).mul(5e15).add(10e16);
            uint checkinerShare = total.mul(6).div(10);
            uint likersShare = total.sub(checkinerShare);
            uint share = likersShare.div(checkin.likeCount);
            balances[checkinOwner] = balances[checkinOwner].add(checkinerShare);
            emit Transfer(owner,checkinOwner,checkinerShare);
            for(uint8 i = 0;i<checkin.likers.length;i++){
                balances[checkin.likers[i]] = balances[checkin.likers[i]].add(share);
                emit Transfer(owner,checkin.likers[i],share);

            }
            balances[owner] = balances[owner].sub(total);
        }
        checkins[checkinOwner][convert(checkinId)].confirmed = true;
    }
}