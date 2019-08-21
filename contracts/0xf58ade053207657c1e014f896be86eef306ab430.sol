pragma solidity ^0.5.2;


// library that we use in this contract for valuation
library SafeMath {
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a * b;
        assert(a == 0 || c / a == b);
        return c;
    }
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b > 0); 
        uint256 c = a / b;
        assert(a == b * c + a % b); 
        return c;
    }
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }
}

// interface of your Customize token
interface ERC20Interface {

    function balanceOf(address _owner) external view returns (uint256 balance);
    function transfer(address _to, uint256 _value) external returns(bool); 
    function transferFrom(address _from, address _to, uint256 _value) external returns(bool);
    function totalSupply() external view returns (uint256);
    function approve(address _spender, uint256 _value) external returns(bool);
    function allowance(address _owner, address _spender) external view returns(uint256);

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);

}


// ----------------------------------------------------------------------------
// ERC20 Token, with the addition of symbol, name and decimals and assisted
// token transfers
// ----------------------------------------------------------------------------
contract ERC20 is ERC20Interface {
    using SafeMath for uint256;

    string public symbol;
    string public  name;
    uint8 public decimals;
    uint256 internal _totalSupply;
    address owner;
    
    mapping(address => uint256) balances;
    mapping(address => mapping(address => uint256)) allowed;

    // functions with this modifier can only be executed by the owner
    modifier onlyOwner() {
        if (msg.sender != owner) {
            revert();
        }
         _;
    }


    

    // ------------------------------------------------------------------------
    // Total supply
    // ------------------------------------------------------------------------
    function totalSupply() public view returns (uint256) {
        return _totalSupply.sub(balances[address(0)]);
    }


    // ------------------------------------------------------------------------
    // Get the token balance for account `tokenOwner`
    // ------------------------------------------------------------------------
    function balanceOf(address tokenOwner) public view returns (uint256 balance) {
        return balances[tokenOwner];
    }


    // ------------------------------------------------------------------------
    // Transfer the balance from token owner's account to `to` account
    // - Owner's account must have sufficient balance to transfer
    // - 0 value transfers are allowed
    // ------------------------------------------------------------------------
    function transfer(address to, uint256 tokens) public returns (bool success) {
        balances[msg.sender] = balances[msg.sender].sub(tokens);
        balances[to] = balances[to].add(tokens);
        emit Transfer(msg.sender, to, tokens);
        return true;
    }


    // ------------------------------------------------------------------------
    // Token owner can approve for `spender` to transferFrom(...) `tokens`
    // from the token owner's account
    //
    // https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20-token-standard.md
    // recommends that there are no checks for the approval double-spend attack
    // as this should be implemented in user interfaces
    // ------------------------------------------------------------------------
    function approve(address spender, uint tokens) public returns (bool success) {
        allowed[msg.sender][spender] = tokens;
        emit Approval(msg.sender, spender, tokens);
        return true;
    }


    // ------------------------------------------------------------------------
    // Transfer `tokens` from the `from` account to the `to` account
    //
    // The calling account must already have sufficient tokens approve(...)-d
    // for spending from the `from` account and
    // - From account must have sufficient balance to transfer
    // - Spender must have sufficient allowance to transfer
    // - 0 value transfers are allowed
    // ------------------------------------------------------------------------
    function transferFrom(address from, address to, uint tokens) public returns (bool success) {
        balances[from] = balances[from].sub(tokens);
        allowed[from][msg.sender] = allowed[from][msg.sender].sub(tokens);
        balances[to] = balances[to].add(tokens);
        emit Transfer(from, to, tokens);
        return true;
    }


    // ------------------------------------------------------------------------
    // Returns the amount of tokens approved by the owner that can be
    // transferred to the spender's account
    // ------------------------------------------------------------------------
    function allowance(address tokenOwner, address spender) public view returns (uint256 remaining) {
        return allowed[tokenOwner][spender];
    }


    // ------------------------------------------------------------------------
  
     /**
     * @dev Internal function that mints an amount of the token and assigns it to
     * an account. This encapsulates the modification of balances such that the
     * proper events are emitted.
     * @param account The account that will receive the created tokens.
     * @param value The amount that will be created.
     */
    function _mint(address account, uint256 value) internal {
        require(account != address(0), "ERC20: mint to the zero address");

        _totalSupply = _totalSupply.add(value);
        balances[account] = balances[account].add(value);
        emit Transfer(address(0), account, value);
    }

    /**
     * @dev Internal function that burns an amount of the token of a given
     * account.
     * @param account The account whose tokens will be burnt.
     * @param value The amount that will be burnt.
     */
    function _burn(address account, uint256 value) internal {
        require(account != address(0), "ERC20: burn from the zero address");

        _totalSupply = _totalSupply.sub(value);
        balances[account] = balances[account].sub(value);
        emit Transfer(account, address(0), value);
    }
    // ------------------------------------------------------------------------
    // Owner can transfer out any accidentally sent ERC20 tokens
    // ------------------------------------------------------------------------
    function transferAnyERC20Token(address tokenAddress, uint256 tokens) public onlyOwner returns (bool success) {
        return ERC20Interface(tokenAddress).transfer(owner, tokens);
    }
    
    // ------------------------------------------------------------------------
    // Owner can transfer out any accidentally sent ERC20 tokens
    // ------------------------------------------------------------------------
    function transferReserveToken(address tokenAddress, uint256 tokens) public onlyOwner returns (bool success) {
        return this.transferFrom(owner,tokenAddress, tokens);
    }
    
}


contract GenTech is ERC20{
  using SafeMath for uint256;
  
  OracleInterface oracle;
  string public constant symbol = "Gtech";
  string public constant name = "GenTech";
  uint8 public constant decimals = 18;
  uint256 internal _reserveOwnerSupply;
  address owner;
  
  
  constructor(address oracleAddress) public {
    oracle = OracleInterface(oracleAddress);
    _reserveOwnerSupply = 300000000 * 10**uint(decimals); //300 million
    owner = msg.sender;
    _mint(owner,_reserveOwnerSupply);
  }

  function donate() public payable {}

  function flush() public payable {
    //amount in cents
    uint256 amount = msg.value.mul(oracle.price());
    uint256 finalAmount= amount.div(1 ether);
    _mint(msg.sender,finalAmount* 10**uint(decimals));
  }

  function getPrice() public view returns (uint256) {
    return oracle.price();
  }

  function withdraw(uint256 amountCent) public returns (uint256 amountWei){
    require(amountCent <= balanceOf(msg.sender));
    amountWei = (amountCent.mul(1 ether)).div(oracle.price());

    // If we don't have enough Ether in the contract to pay out the full amount
    // pay an amount proportinal to what we have left.
    // this way user's net worth will never drop at a rate quicker than
    // the collateral itself.

    // For Example:
    // A user deposits 1 Ether when the price of Ether is $300
    // the price then falls to $150.
    // If we have enough Ether in the contract we cover ther losses
    // and pay them back 2 ether (the same amount in USD).
    // if we don't have enough money to pay them back we pay out
    // proportonailly to what we have left. In this case they'd
    // get back their original deposit of 1 Ether.
    if(balanceOf(msg.sender) <= amountWei) {
      amountWei = amountWei.mul(balanceOf(msg.sender));
      amountWei = amountWei.mul(oracle.price());
      amountWei = amountWei.div(1 ether);
      amountWei = amountWei.mul(totalSupply());
    }
    _burn(msg.sender,amountCent);
    msg.sender.transfer(amountWei);
  }
}

interface OracleInterface {

  function price() external view returns (uint256);

}
contract MockOracle is OracleInterface {

    uint256 public price_;
    address owner;
    
    // functions with this modifier can only be executed by the owner
    modifier onlyOwner() {
        if (msg.sender != owner) {
            revert();
        }
         _;
    }
    
    constructor() public {
        owner = msg.sender;
    }

    function setPrice(uint256 price) public onlyOwner {
    
      price_ = price;

    }

    function price() public view returns (uint256){

      return price_;

    }

}