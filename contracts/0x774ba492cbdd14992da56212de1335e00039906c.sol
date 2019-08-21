pragma solidity ^0.4.24;
//Spielleys Divide Drain and Destroy minigame v 1.0

//99% of eth payed is returned directly to players according to their stack of shares vs totalSupply
// players need to fetch divs themselves or perform transactions to get the divs
// 1% will be set aside to buy P3D with Masternode reward for UI builders
// 100% of vanity change sales will go to buying P3D with (UIdev MN reward)

// Game Concept: (inspired by a hill type idea for kotch https://kotch.dvx.me/#/)
// - Divide: Convert eth spent to buy shares factor eth value *3 
// - Drain : Drain someones shares, enemy loses shares eth value *2, you gain these
// - Destroy : Burn an enemies stack of shares at rate of eth value *5

// Steps of the transactions
// 1: update total divs with payed amount
// 2: fetchdivs from accounts in the transactions
// 3: update shares

// no matter your innitial shares amount, 
// you'll still get eth for getting destroyed according to your shares owned


// Thank you for playing Spielleys contract creations.
// speilley is not liable for any contract bugs known and unknown.
//

// ----------------------------------------------------------------------------
// Safe maths
// ----------------------------------------------------------------------------
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

// ----------------------------------------------------------------------------
// Owned contract
// ----------------------------------------------------------------------------
contract Owned {
    address public owner;
    address public newOwner;

    event OwnershipTransferred(address indexed _from, address indexed _to);

    constructor() public {
        owner = 0x0B0eFad4aE088a88fFDC50BCe5Fb63c6936b9220;
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
// ----------------------------------------------------------------------------
// ERC Token Standard #20 Interface
// https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20.md
// ----------------------------------------------------------------------------
contract ERC20Interface {
    function totalSupply() public constant returns (uint);
    function balanceOf(address tokenOwner) public constant returns (uint balance);
    function allowance(address tokenOwner, address spender) public constant returns (uint remaining);
    function transfer(address to, uint tokens) public returns (bool success);
    function approve(address spender, uint tokens) public returns (bool success);
    function transferFrom(address from, address to, uint tokens) public returns (bool success);

    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
}

interface HourglassInterface  {
    function() payable external;
    function buy(address _playerAddress) payable external returns(uint256);
    function sell(uint256 _amountOfTokens) external;
    function reinvest() external;
    function withdraw() external;
    function exit() external;
    function dividendsOf(address _playerAddress) external view returns(uint256);
    function balanceOf(address _playerAddress) external view returns(uint256);
    function transfer(address _toAddress, uint256 _amountOfTokens) external returns(bool);
    function stakingRequirement() external view returns(uint256);
}
interface SPASMInterface  {
    function() payable external;
    function disburse() external  payable;
}
// ----------------------------------------------------------------------------
// Contract function to receive approval and execute function in one call
//
// Borrowed from MiniMeToken
// ----------------------------------------------------------------------------
contract ApproveAndCallFallBack {
    function receiveApproval(address from, uint256 tokens, address token, bytes data) public;
}

// ----------------------------------------------------------------------------
// ERC20 Token, with the addition of symbol, name and decimals and a
// fixed supply
// ----------------------------------------------------------------------------
contract DivideDrainDestroy is ERC20Interface, Owned {
    using SafeMath for uint;

    string public symbol;
    string public  name;
    uint8 public decimals;
    uint _totalSupply;

    mapping(address => uint) balances;
    mapping(address => mapping(address => uint)) allowed;


    // ------------------------------------------------------------------------
    // Constructor
    // ------------------------------------------------------------------------
    constructor() public {
        symbol = "DDD";
        name = "Divide Drain and Destroy";
        decimals = 0;
        _totalSupply = 1;
        balances[owner] = _totalSupply;
        emit Transfer(address(0),owner, _totalSupply);
        
    }


    // ------------------------------------------------------------------------
    // Total supply
    // ------------------------------------------------------------------------
    function totalSupply() public view returns (uint) {
        return _totalSupply.sub(balances[address(0)]);
    }


    // ------------------------------------------------------------------------
    // Get the token balance for account `tokenOwner`
    // ------------------------------------------------------------------------
    function balanceOf(address tokenOwner) public view returns (uint balance) {
        return balances[tokenOwner];
    }


    // ------------------------------------------------------------------------
    // Transfer the balance from token owner's account to `to` account
    // - Owner's account must have sufficient balance to transfer
    // - 0 value transfers are allowed
    // ------------------------------------------------------------------------
    function transfer(address to, uint tokens) updateAccount(to) updateAccount(msg.sender) public returns (bool success) {
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
    function transferFrom(address from, address to, uint tokens)updateAccount(to) updateAccount(from) public returns (bool success) {
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
    function allowance(address tokenOwner, address spender) public view returns (uint remaining) {
        return allowed[tokenOwner][spender];
    }


    // ------------------------------------------------------------------------
    // Token owner can approve for `spender` to transferFrom(...) `tokens`
    // from the token owner's account. The `spender` contract function
    // `receiveApproval(...)` is then executed
    // ------------------------------------------------------------------------
    function approveAndCall(address spender, uint tokens, bytes data) public returns (bool success) {
        allowed[msg.sender][spender] = tokens;
        emit Approval(msg.sender, spender, tokens);
        ApproveAndCallFallBack(spender).receiveApproval(msg.sender, tokens, this, data);
        return true;
    }





    // ------------------------------------------------------------------------
    // Owner can transfer out any accidentally sent ERC20 tokens
    // ------------------------------------------------------------------------
    function transferAnyERC20Token(address tokenAddress, uint tokens) public onlyOwner returns (bool success) {
        return ERC20Interface(tokenAddress).transfer(owner, tokens);
    }

// divfunctions
HourglassInterface constant P3Dcontract_ = HourglassInterface(0xB3775fB83F7D12A36E0475aBdD1FCA35c091efBe);
SPASMInterface constant SPASM_ = SPASMInterface(0xfaAe60F2CE6491886C9f7C9356bd92F688cA66a1);
// view functions
function harvestabledivs()
        view
        public
        returns(uint256)
    {
        return ( P3Dcontract_.dividendsOf(address(this)))  ;
    }
function amountofp3d() external view returns(uint256){
    return ( P3Dcontract_.balanceOf(address(this)))  ;
}
//divsection
uint256 public pointMultiplier = 10e18;
struct Account {
  uint balance;
  uint lastDividendPoints;
}
mapping(address=>Account) accounts;
mapping(address => uint256) public ETHtoP3Dbymasternode;
mapping(address => string) public Vanity;
uint public ethtotalSupply;
uint public totalDividendPoints;
uint public unclaimedDividends;

function dividendsOwing(address account) public view returns(uint256) {
  uint256 newDividendPoints = totalDividendPoints.sub(accounts[account].lastDividendPoints);
  return (balances[account] * newDividendPoints) / pointMultiplier;
}
modifier updateAccount(address account) {
  uint256 owing = dividendsOwing(account);
  if(owing > 0) {
    unclaimedDividends = unclaimedDividends.sub(owing);
    
    account.transfer(owing);
  }
  accounts[account].lastDividendPoints = totalDividendPoints;
  _;
}
function () external payable{}
function fetchdivs(address toupdate) public updateAccount(toupdate){}
function disburse(address masternode) public  payable {
    uint256 amount = msg.value;
    uint256 base = amount.div(100);
    uint256 amt2 = amount.sub(base);
  totalDividendPoints = totalDividendPoints.add(amt2.mul(pointMultiplier).div(_totalSupply));
 unclaimedDividends = unclaimedDividends.add(amt2);
 ETHtoP3Dbymasternode[masternode] = ETHtoP3Dbymasternode[masternode].add(base);
}
function Divide(address masternode) public  payable{
    uint256 amount = msg.value.mul(3);
    address sender = msg.sender;
    uint256 sup = _totalSupply;//totalSupply
    require(amount >= 1);
    sup = sup.add(amount);
    disburse(masternode);
    fetchdivs(msg.sender);
    balances[msg.sender] = balances[sender].add(amount);
    emit Transfer(0,sender, amount);
     _totalSupply =  sup;

}
function Drain(address drainfrom, address masternode) public  payable{
    uint256 amount = msg.value.mul(2);
    address sender = msg.sender;
    uint256 sup = _totalSupply;//totalSupply
    require(amount >= 1);
    require(amount <= balances[drainfrom]);
    
    disburse(masternode);
    fetchdivs(msg.sender);
    fetchdivs(drainfrom);
    balances[msg.sender] = balances[sender].add(amount);
    balances[drainfrom] = balances[drainfrom].sub(amount);
    emit Transfer(drainfrom,sender, amount);
     _totalSupply =  sup.add(amount);
    
}
function Destroy(address destroyfrom, address masternode) public  payable{
    uint256 amount = msg.value.mul(5);
    uint256 sup = _totalSupply;//totalSupply
    require(amount >= 1);
    require(amount <= balances[destroyfrom]);
        disburse(masternode);
        fetchdivs(msg.sender);
    fetchdivs(destroyfrom);
    balances[destroyfrom] = balances[destroyfrom].sub(amount);
    emit Transfer(destroyfrom,0x0, amount);
     _totalSupply =  sup.sub(amount);

}
function Expand(address masternode) public {
    
    uint256 amt = ETHtoP3Dbymasternode[masternode];
    ETHtoP3Dbymasternode[masternode] = 0;
    if(masternode == 0x0){masternode = 0x989eB9629225B8C06997eF0577CC08535fD789F9;}// raffle3d's address
    P3Dcontract_.buy.value(amt)(masternode);
    
}
function changevanity(string van , address masternode) public payable{
    require(msg.value >= 100  finney);
    Vanity[msg.sender] = van;
    ETHtoP3Dbymasternode[masternode] = ETHtoP3Dbymasternode[masternode].add(msg.value);
}
function P3DDivstocontract() public payable{
    uint256 divs = harvestabledivs();
    require(divs > 0);
 
P3Dcontract_.withdraw();
    //1% to owner
    uint256 base = divs.div(100);
    uint256 amt2 = divs.sub(base);
    SPASM_.disburse.value(base)();// to dev fee sharing contract
   totalDividendPoints = totalDividendPoints.add(amt2.mul(pointMultiplier).div(_totalSupply));
 unclaimedDividends = unclaimedDividends.add(amt2);
}
}