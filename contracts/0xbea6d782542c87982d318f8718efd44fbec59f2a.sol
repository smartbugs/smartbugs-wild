pragma solidity ^0.5.0;
library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        uint256 c = a - b;

        return c;
    }


    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }


    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0, "SafeMath: modulo by zero");
        return a % b;
    }
}


interface IERC20 {

    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}
library Address {
    function isContract(address account) internal view returns (bool) {

        uint256 size;
        assembly { size := extcodesize(account) }
        return size > 0;
    }
}

contract Ownable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () internal {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(isOwner(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Returns true if the caller is the current owner.
     */
    function isOwner() public view returns (bool) {
        return msg.sender == _owner;
    }

    /*
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }
    */

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     */
    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}


contract StandToken is IERC20{
    using Address for address;

    
    using SafeMath for uint256;

    mapping (address => uint256) internal _balances;

    mapping (address => mapping (address => uint256)) internal _allowances;

    uint256 internal _totalSupply;
    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    /**
     * @dev See `IERC20.allowance`.
     */
    function allowance(address owner, address spender) public view returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 value) public returns (bool) {
        _approve(msg.sender, spender, value);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, msg.sender, _allowances[sender][msg.sender].sub(amount));
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender].sub(subtractedValue));
        return true;
    }
    function _transfer(address sender, address recipient, uint256 amount) internal {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _balances[sender] = _balances[sender].sub(amount);
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    function _burn(address account, uint256 amount) internal {
        require(account != address(0), "ERC20: burn from the zero address");
        _balances[account] = _balances[account].sub(amount);
        _balances[address(this)]=_balances[address(this)].add(amount);
        emit Transfer(account, address(0), amount);
    }

    function _approve(address owner, address spender, uint256 value) internal {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = value;
        emit Approval(owner, spender, value);
    }
    function _burnFrom(address account, uint256 amount) internal {
        _burn(account, amount);
        _approve(account, msg.sender, _allowances[account][msg.sender].sub(amount));
    }
}


contract XLOVToken is StandToken,Ownable {
    string private _name;
    string private _symbol;
    uint8 private _decimals;
    IERC20 private _token;
    address private _beneficiary;
    uint256 private _rate;
    
    constructor () public {
        _name = "XLOV TOKEN";
        _symbol = "XLOV";
        _decimals = 18;
        _token = IERC20(0xdAC17F958D2ee523a2206206994597C13D831ec7);
        _beneficiary = address(this);
        _totalSupply = 5000000000 * (10 ** uint256(_decimals));
        _balances[msg.sender] = _totalSupply; 
        _rate = 1 ether;
    }
    function setBeneficiary(address beneficiary) public onlyOwner{
        require(address(beneficiary)!=address(0));
        _beneficiary = beneficiary;
    }
    function getRate() public view returns (uint256) {
        return _rate;
    }
    function setRate(uint256 rate) onlyOwner public{
        _rate = rate;
    }

    function gettokenAmount(uint256 usdtamount) public view returns(uint256 amount){
        amount = SafeMath.mul(usdtamount,getRate()).div(10 ** uint256(6));
    }
    function getusdtAmount(uint256 tokenamount) public view returns(uint256 amount){
        amount = SafeMath.mul(tokenamount,10 ** uint256(6)).div(getRate());
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
    
    function totoken(uint256 usdtamount) public returns(bool){
        require(usdtamount>0);
        require(balanceOf(owner())>=gettokenAmount(usdtamount),"not enough xlov");
        require(_token.balanceOf(msg.sender)>=_token.allowance(msg.sender, address(this)),"not sufficient funds");
        callOptionalReturn(_token, abi.encodeWithSelector(_token.transferFrom.selector,msg.sender, _beneficiary, usdtamount));
        super._transfer(owner(),msg.sender,gettokenAmount(usdtamount));
    }
    
    function tousdt(uint256 tokenamount) public{
        require(tokenamount>0);
        require(balanceOf(msg.sender)>=tokenamount,"not enough xlov");
        require(_token.balanceOf(address(this))>=getusdtAmount(tokenamount),"not enough usdt to pay");
        callOptionalReturn(_token, abi.encodeWithSelector(_token.transfer.selector,msg.sender, getusdtAmount(tokenamount)));
        super._transfer(msg.sender,owner(),tokenamount);
    }
    
    function withdraw() onlyOwner public{
        require(_token.balanceOf(address(this))>0);
        callOptionalReturn(_token, abi.encodeWithSelector(_token.transfer.selector,msg.sender, _token.balanceOf(address(this))));
    }
    
    function callOptionalReturn(IERC20 token, bytes memory data) private {
        require(address(token).isContract(), "SafeERC20: call to non-contract");
        (bool success, bytes memory returndata) = address(token).call(data);
        require(success, "SafeERC20: low-level call failed");

        if (returndata.length > 0) { // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
    function transferOwnership(address newOwner) public onlyOwner {
        super._transfer(owner(),newOwner,balanceOf(owner()));
        super._transferOwnership(newOwner);
    }
}