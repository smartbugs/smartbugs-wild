pragma solidity ^0.5.1;

/* SafeMath cal*/
library SafeMath {

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

/* IERC20 inteface */
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

/* Owner permission */
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

    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0));
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

/* LockAble contract */
contract LockAble is Ownable {

    mapping (address => bool) _walletLockAddr;

    function setLockWallet(address lockAddress)  public onlyOwner returns (bool){
        _walletLockAddr[lockAddress] = true;
        return true;
    }

    function setReleaseWallet(address lockAddress)  public onlyOwner returns (bool){
         _walletLockAddr[lockAddress] = false;
        return true;
    }

    function isLockWallet(address lockAddress)  public view returns (bool){
        require(lockAddress != address(0), "Ownable: new owner is the zero address");
        return _walletLockAddr[lockAddress];
    }
}

contract PartnerShip is LockAble{

   mapping (address => bool) _partnerAddr;

   function addPartnership(address partner) public onlyOwner returns (bool){
       require(partner != address(0), "Ownable: new owner is the zero address");

       _partnerAddr[partner] = true;
       return true;
   }

   function removePartnership(address partner) public onlyOwner returns (bool){
      require(partner != address(0), "Ownable: new owner is the zero address");

      _partnerAddr[partner] = false;

      return true;
   }

   function isPartnership(address partner)  public view returns (bool){
       return _partnerAddr[partner];
   }


}

contract SaveWon is IERC20, Ownable, PartnerShip {

    using SafeMath for uint256;
    string private _name;
    string private _symbol;
    uint256 private _totalSupply;
    
    uint8 private _decimals = 18;

    mapping (address => uint256) internal _balances;
    mapping (address => mapping (address => uint256)) private _allowed;


    event Burn(address indexed from, uint256 value);
    
    constructor() public {
        _name = "SAVEWON";
        _symbol = "SW";
        uint256 INITIAL_SUPPLY = 50000000000 * (10 ** uint256(_decimals));
        _totalSupply = _totalSupply.add(INITIAL_SUPPLY);
        _balances[msg.sender] = _balances[msg.sender].add(INITIAL_SUPPLY);
        
        emit Transfer(address(0), msg.sender, _totalSupply);
    }


    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public view returns (uint8) {
        return _decimals;
    }
    
    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address owner) public view returns (uint256) {
        return _balances[owner];
    }

    function transfer(address to, uint256 value) public returns (bool) {
         require(_walletLockAddr[msg.sender] != true, "Wallet Locked");

        _transfer(msg.sender, to, value);
        return true;
    }

    function transferFrom(address from, address to, uint256 value) public returns (bool) {
         _transfer(from, to, value);
         _approve(from, msg.sender, _allowed[from][msg.sender].sub(value));
         return true;
    }

    function _transfer(address from, address to, uint256 value) internal {
        require(to != address(0));

        _balances[from] = _balances[from].sub(value);
        _balances[to] = _balances[to].add(value);
        emit Transfer(from, to, value);

    }

    function approve(address spender, uint256 value) public returns (bool) {
        _approve(msg.sender, spender, value);
        return true;
    }

    function _approve(address owner, address spender, uint256 value) internal {
        require(spender != address(0));
        require(owner != address(0));

        _allowed[owner][spender] = value;
        emit Approval(owner, spender, value);
    }

    function allowance(address owner, address spender) public view returns (uint256) {
        return _allowed[owner][spender];
    }

   function burn(uint256 value) public onlyOwner{
        require(value != 0, "Ownable: new owner is the zero address");

       _burn(msg.sender, value);
   }

   function _burn(address account, uint256 value) internal {
       require(account != address(0));
       require(value <= _balances[account]);

       _totalSupply = _totalSupply.sub(value);
       _balances[account] = _balances[account].sub(value);
       emit Burn(account, value);
       emit Transfer(account, address(0), value);
   }

   function multiTransfer(address[] memory toArray, uint256[] memory valueArray) public returns (bool){
     if(isPartnership(msg.sender) || isOwner()){
       uint256 i = 0;
       while(i < toArray.length){
         transfer( toArray[i],valueArray[i]);
         i += 1;
       }
       return true;
     } else {
       return false;
     }
   }
}