pragma solidity ^0.5.7;

contract Ownable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () internal {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(isOwner());
        _;
    }

    function isOwner() public view returns (bool) {
        return msg.sender == _owner;
    }

    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0));
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

contract SafeMath {

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b);

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0);
        uint256 c = a / b;
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a);
        uint256 c = a - b;

        return c;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a);

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0);
        return a % b;
    }
}

interface IERC20 {
    function transfer(address to, uint256 value) external returns (bool);

    function approve(address spender, uint256 value) external returns (bool);

    function transferFrom(address from, address to, uint256 value) external returns (bool);

    function totalSupply() external view returns (uint256);

    function balanceOf(address who) external view returns (uint256);

    function allowance(address owner, address spender) external view returns (uint256);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract ERC20 is IERC20, SafeMath ,Ownable {
    
    string public name;
    string public symbol;
    uint8 public decimals;
    uint public startTime;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowed;

    uint256 private _totalSupply;
    
    event UserAdedd(uint vestedAmount,uint vestingDuration,uint vestingPercentage,uint releasedAmount,string vesterType,uint tokenUsed,uint startTime,uint month);
    
    constructor() public {
         
         name = "Hartanah Dcom Token";
         symbol = "HADT";
         decimals = 10;
         startTime = now;
         _totalSupply = 10000000000000000000;
         _balances[msg.sender] = _totalSupply;
         
     }
    
    struct User {
        uint vestedAmount;
        uint vestingDuration;
        uint vestingPercentage;
        uint releasedAmount;
        string vesterType;
        uint tokenUsed;
        uint startTime;
        uint vestingMonth;
    }
    
    mapping(address => User) vestInfo;
    mapping(string => address) addressMap;
    
    modifier checkReleasable(uint value) {
        address sender = msg.sender;
        
        if(vestInfo[sender].vestedAmount == 0 || sender == owner()) {
            _;
        }
        else{
            if(keccak256(abi.encodePacked(vestInfo[sender].vesterType)) == keccak256(abi.encodePacked("Public Sales"))) {
                uint current = ((now - vestInfo[sender].startTime)/31536000)+1;
                if(vestInfo[sender].vestingMonth < current && current <= vestInfo[sender].vestingDuration) {
                        vestInfo[sender].releasedAmount = (vestInfo[sender].vestedAmount);
                        vestInfo[sender].vestingMonth++;
                }
            }
            else{
                uint current = ((now - vestInfo[sender].startTime)/2592000)+1;
                    if(vestInfo[sender].vestingMonth < current && current <= vestInfo[sender].vestingDuration) {
                        vestInfo[sender].releasedAmount = (vestInfo[sender].vestedAmount/vestInfo[sender].vestingDuration) * current;
                        vestInfo[sender].vestingMonth++;
                    }
            }
            require((vestInfo[sender].releasedAmount - vestInfo[sender].tokenUsed) >= value);
            _;
        }
        
    } 
    
    function addUser(address _account,uint _vestingDuration,uint _vestingPercentage,string memory _vesterType) public onlyOwner {
      uint vestedAmount;
      uint releasedAmount;
      if(keccak256(abi.encodePacked(_vesterType)) == keccak256(abi.encodePacked("Public Sales"))) {
         vestedAmount = (_totalSupply * _vestingPercentage)/100;
         releasedAmount = vestedAmount/3;
      }else{
         vestedAmount = (_totalSupply * _vestingPercentage)/100;
         releasedAmount = vestedAmount/_vestingDuration;
      }
      addressMap[_vesterType] = _account;
      vestInfo[_account] = User(vestedAmount,_vestingDuration,_vestingPercentage,releasedAmount,_vesterType,0,now,1);
      _transfer(owner(),_account,vestedAmount);
      emit UserAdedd(vestedAmount,_vestingDuration,_vestingPercentage,releasedAmount,_vesterType,0,now,1);
    }
  
    function getReleasedAmount(address _account) public view returns(uint){
        
      uint release = vestInfo[_account].releasedAmount;
      if(keccak256(abi.encodePacked(vestInfo[_account].vesterType)) == keccak256(abi.encodePacked("Public Sales"))) {
          uint current = ((now - vestInfo[_account].startTime)/31536000)+1;
                if(vestInfo[_account].vestingMonth < current && current <= vestInfo[_account].vestingDuration) {
                        release = (vestInfo[_account].vestedAmount);
                }
      }else {
          uint time = ((now - vestInfo[_account].startTime)/2592000)+1;
                if((vestInfo[_account].vestingMonth < time) && (time <= vestInfo[_account].vestingDuration)) {
                       release = (vestInfo[_account].vestedAmount/vestInfo[_account].vestingDuration) * time;
                }
       }
        return(release);
    }
  
    function FoundersVestedAmount() public view returns(uint){
      address account = addressMap["Founders"];
      return vestInfo[account].vestedAmount;
    } 
    
    function ManagementVestedAmount() public view returns(uint){
      address account = addressMap["Management"];
      return vestInfo[account].vestedAmount;
    }
    
    function TechnologistVestedAmount() public view returns(uint){
      address account = addressMap["Technologist"];
      return vestInfo[account].vestedAmount;
    }
    
    function LegalAndFinanceVestedAmount() public view returns(uint){
      address account = addressMap["Legal & Finance"];
      return vestInfo[account].vestedAmount;
    }
    
    function MarketingVestedAmount() public view returns(uint){
      address account = addressMap["Marketing"];
      return vestInfo[account].vestedAmount;
    }
    
    function PublicSalesVestedAmount() public view returns(uint){
      address account = addressMap["Public Sales"];
      return vestInfo[account].vestedAmount;
    }
    
    function AirdropVestedAmount() public view returns(uint){
      address account = addressMap["Airdrop"];
      return vestInfo[account].vestedAmount;
    }
    
    function PromotionVestedAmount() public view returns(uint){
      address account = addressMap["Promotion"];
      return vestInfo[account].vestedAmount;
    }
    
    function RewardsVestedAmount() public view returns(uint){
      address account = addressMap["Rewards"];
      return vestInfo[account].vestedAmount;
    }

    function FoundersReleasedAmount() public view returns(uint){
      address account = addressMap["Founders"];
      return getReleasedAmount(account);
    } 
    
    function ManagementReleasedAmount() public view returns(uint){
      address account = addressMap["Management"];
      return getReleasedAmount(account);
    }
    
    function TechnologistReleasedAmount() public view returns(uint){
      address account = addressMap["Technologist"];
      return getReleasedAmount(account);
    }
    
    function LegalAndFinanceReleasedAmount() public view returns(uint){
      address account = addressMap["Legal & Finance"];
      return getReleasedAmount(account);
    }
    
    function MarketingReleasedAmount() public view returns(uint){
      address account = addressMap["Marketing"];
      return getReleasedAmount(account);
    }
    
    function PublicSalesReleasedAmount() public view returns(uint){
      address account = addressMap["Public Sales"];
      return getReleasedAmount(account);
    }
    
    function AirdropReleasedAmount() public view returns(uint){
      address account = addressMap["Airdrop"];
      return getReleasedAmount(account);
    }
    
    function PromotionReleasedAmount() public view returns(uint){
      address account = addressMap["Promotion"];
      return getReleasedAmount(account);
    }
    
    function RewardsReleasedAmount() public view returns(uint){
      address account = addressMap["Rewards"];
      return getReleasedAmount(account);
    }
    
    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address owner) public view returns (uint256) {
        return _balances[owner];
    }

    function allowance(address owner, address spender) public view returns (uint256) {
        return _allowed[owner][spender];
    }

    function transfer(address to, uint256 value) public checkReleasable(value) returns (bool) {
        _transfer(msg.sender, to, value);
        return true;
    }

    function approve(address spender, uint256 value) public returns (bool) {
        _approve(msg.sender, spender, value);
        return true;
    }

    function transferFrom(address from, address to, uint256 value) public returns (bool) {
        _transfer(from, to, value);
        _approve(from, msg.sender, sub(_allowed[from][msg.sender],value));
        return true;
    }
     
    function _transfer(address from, address to, uint256 value) internal  {
        require(to != address(0));

        _balances[from] = sub(_balances[from],value);
        _balances[to] = add(_balances[to],value);
        vestInfo[from].tokenUsed = vestInfo[from].tokenUsed + value;
        emit Transfer(from, to, value);
    }

    function _approve(address owner, address spender, uint256 value) internal {
        require(spender != address(0));
        require(owner != address(0));

        _allowed[owner][spender] = value;
        emit Approval(owner, spender, value);
    }

}