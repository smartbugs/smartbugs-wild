/**
Contract interface:
- Standars ERC20 methods: balanceOf, totalSupply, transfer, transferFrom, approve, allowance
- Function issue, argument amount
    issue new amount coins to totalSupply
- Function destroy, argument amount
    remove amount coins from totalSupply if available in contract
    used only by contract owner
- Function sell - argument amount, to
    Used only by contract owner
    Send amount coins to address to
- Function kill
    Used only by contract owner
    destroy cantract
    Contract can be destroyed if totalSupply is empty and all wallets are empty
- Function setTransferFee arguments numinator, denuminator
    Used only by contract owner
    set transfer fee to numinator/denuminator
- Function changeTransferFeeOwner, argument address 
    Used only by contract owner
    change transfer fees recipient to address
- Function sendDividends, arguments address, amount
    Used only by contract owner
    address - ERC20 address
    issue dividends to investors - amount is tokens
- Function sendDividendsEthers
    Used only by contract owner
    issue ether dividends to investors
- Function addInvestor, argument - address
    Used only by contract owner
    add address to investors list (to paying dividends in future)
- Function removeInvestor, argument - address
    Used only by contract owner
    remove address from investors list (to not pay dividends in future)
- Function getDividends
    Used by investor to actual receive dividend coins
- Function changeRate, argument new_rate
    Change coin/eth rate for autosell
- Function changeMinimalWei, argument new_wei
    Used only by contract owner
    Change minimal wei amount to sell coins wit autosell
*/

pragma solidity ^0.4.11;

contract ERC20Basic {
  uint256 public totalSupply;
  function balanceOf(address who) public constant returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}

contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender) public constant returns (uint256);
  function transferFrom(address from, address to, uint256 value) public returns (bool);
  function approve(address spender, uint256 value) public returns (bool);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}

library SafeMath {
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    assert(c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
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

//contract PDT is PDT {
contract PDT {
    using SafeMath for uint256;

    // totalSupply is zero by default, owner can issue and destroy coins any amount any time
    uint constant totalSupplyDefault = 0;

    string public constant symbol = "PDT";
    string public constant name = "Prime Donor Token";
    uint8 public constant decimals = 5;

    uint public totalSupply = 0;

    // minimum fee is 0.00001
    uint32 public constant minFee = 1;
    // transfer fee default = 0.17% (0.0017)
    uint32 public transferFeeNum = 17;
    uint32 public transferFeeDenum = 10000;

    uint32 public constant minTransfer = 10;

    // coin exchange rate to eth for automatic sell
    uint256 public rate = 1000;

    // minimum ether amount to buy
    uint256 public minimalWei = 1 finney;

    // wei raised in automatic sale
    uint256 public weiRaised;

    //uint256 public payedDividends;
    //uint256 public dividends;
    address[] tokens;

    // Owner of this contract
    address public owner;
    modifier onlyOwner() {
        if (msg.sender != owner) {
            revert();
        }
        _;
    }
    address public transferFeeOwner;

    function notOwner(address addr) internal view returns (bool) {
        return addr != address(this) && addr != owner && addr != transferFeeOwner;
    }


    // ---------------------------- dividends related definitions --------------------
    // investors white list
    // dividends can be send only investors from list
    mapping(address => bool) public investors;

    // minimal coin balance to pay dividends
    uint256 public constant investorMinimalBalance = uint256(10000)*(uint256(10)**decimals);

    uint256 public investorsTotalSupply;

    uint constant MULTIPLIER = 10e18;

    // dividends for custom coins
    mapping(address=>mapping(address=>uint256)) lastDividends;
    mapping(address=>uint256) totalDividendsPerCoin;

    // dividends for custom ethers
    mapping(address=>uint256) lastEthers;
    uint256 divEthers;

/*
    function balanceEnough(uint256 amount) internal view returns (bool) {
        return balances[this] >= dividends && balances[this] - dividends >= amount;
    }
    */

    function activateDividendsCoins(address account) internal {
        for (uint i = 0; i < tokens.length; i++) {
            address addr = tokens[i];
            if (totalDividendsPerCoin[addr] != 0 && totalDividendsPerCoin[addr] > lastDividends[addr][account]) {
                if (investors[account] && balances[account] >= investorMinimalBalance) {
                    var actual = totalDividendsPerCoin[addr] - lastDividends[addr][account];
                    var divs = (balances[account] * actual) / MULTIPLIER;
                    Debug(divs, account, "divs");

                    ERC20 token = ERC20(addr);
                    if (divs > 0 && token.balanceOf(this) >= divs) {
                        token.transfer(account, divs);
                        lastDividends[addr][account] = totalDividendsPerCoin[addr];
                    }
                }
                lastDividends[addr][account] = totalDividendsPerCoin[addr];
            }
        }
    }

    function activateDividendsEthers(address account) internal {
        if (divEthers != 0 && divEthers > lastEthers[account]) {
            if (investors[account] && balances[account] >= investorMinimalBalance) {
                var actual = divEthers - lastEthers[account];
                var divs = (balances[account] * actual) / MULTIPLIER;
                Debug(divs, account, "divsEthers");

                require(divs > 0 && this.balance >= divs);
                account.transfer(divs);
                lastEthers[account] = divEthers;
            }
            lastEthers[account] = divEthers;
        }
    }

    function activateDividends(address account) internal {
        activateDividendsCoins(account);
        activateDividendsEthers(account);
    }

    function activateDividends(address account1, address account2) internal {
        activateDividends(account1);
        activateDividends(account2);
    }

    function addInvestor(address investor) public onlyOwner {
        activateDividends(investor);
        investors[investor] = true;
        if (balances[investor] >= investorMinimalBalance) {
            investorsTotalSupply = investorsTotalSupply.add(balances[investor]);
        }
    }
    function removeInvestor(address investor) public onlyOwner {
        activateDividends(investor);
        investors[investor] = false;
        if (balances[investor] >= investorMinimalBalance) {
            investorsTotalSupply = investorsTotalSupply.sub(balances[investor]);
        }
    }

    function sendDividends(address token_address, uint256 amount) public onlyOwner {
        require (token_address != address(this)); // do not send this contract for dividends
        require(investorsTotalSupply > 0); // investor capital must exists to pay dividends
        ERC20 token = ERC20(token_address);
        require(token.balanceOf(this) > amount);

        totalDividendsPerCoin[token_address] = totalDividendsPerCoin[token_address].add(amount.mul(MULTIPLIER).div(investorsTotalSupply));

        // add tokens to the set
        uint idx = tokens.length;
        for(uint i = 0; i < tokens.length; i++) {
            if (tokens[i] == token_address || tokens[i] == address(0x0)) {
                idx = i;
                break;
            }
        }
        if (idx == tokens.length) {
            tokens.length += 1;
        }
        tokens[idx] = token_address;
    }

    function sendDividendsEthers() public payable onlyOwner {
        require(investorsTotalSupply > 0); // investor capital must exists to pay dividends
        divEthers = divEthers.add((msg.value).mul(MULTIPLIER).div(investorsTotalSupply));
    }

    function getDividends() public {
        // Any investor can call this function in a transaction to receive dividends
        activateDividends(msg.sender);
    }
    // -------------------------------------------------------------------------------
 
    // Balances for each account
    mapping(address => uint) balances;

    // Owner of account approves the transfer of an amount to another account
    mapping(address => mapping (address => uint)) allowed;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed from , address indexed to , uint256 value);
    event TransferFee(address indexed to , uint256 value);
    event TokenPurchase(address indexed from, address indexed to, uint256 value, uint256 amount);
    event Debug(uint256 from, address to, string value);

    function transferBalance(address from, address to, uint256 amount) internal {
        if (from != address(0x0)) {
            require(balances[from] >= amount);
            if (notOwner(from) && investors[from] && balances[from] >= investorMinimalBalance) {
                if (balances[from] - amount >= investorMinimalBalance) {
                    investorsTotalSupply = investorsTotalSupply.sub(amount);
                } else {
                    investorsTotalSupply = investorsTotalSupply.sub(balances[from]);
                }
            }
            balances[from] = balances[from].sub(amount);
        }
        if (to != address(0x0)) {
            balances[to] = balances[to].add(amount);
            if (notOwner(to) && investors[to] && balances[to] >= investorMinimalBalance) {
                if (balances[to] - amount >= investorMinimalBalance) {
                    investorsTotalSupply = investorsTotalSupply.add(amount);
                } else {
                    investorsTotalSupply = investorsTotalSupply.add(balances[to]);
                }
            }
        }
    }

    // if supply provided is 0, then default assigned
    function PDT(uint supply) public {
        if (supply > 0) {
            totalSupply = supply;
        } else {
            totalSupply = totalSupplyDefault;
        }
        owner = msg.sender;
        transferFeeOwner = owner;
        balances[this] = totalSupply;
    }

    function changeTransferFeeOwner(address addr) onlyOwner public {
        transferFeeOwner = addr;
    }
 
    function balanceOf(address addr) constant public returns (uint) {
        return balances[addr];
    }

    // fee is not applied to owner and transferFeeOwner
    function chargeTransferFee(address addr, uint amount)
        internal returns (uint) {
        activateDividends(addr);
        if (notOwner(addr) && balances[addr] > 0) {
            var fee = amount * transferFeeNum / transferFeeDenum;
            if (fee < minFee) {
                fee = minFee;
            } else if (fee > balances[addr]) {
                fee = balances[addr];
            }
            amount = amount - fee;

            transferBalance(addr, transferFeeOwner, fee);
            Transfer(addr, transferFeeOwner, fee);
            TransferFee(addr, fee);
        }
        return amount;
    }
 
    function transfer(address to, uint amount)
        public returns (bool) {
        activateDividends(msg.sender, to);
        //activateDividendsFunc(to);
        if (amount >= minTransfer
            && balances[msg.sender] >= amount
            && balances[to] + amount > balances[to]
            ) {
                if (balances[msg.sender] >= amount) {
                    amount = chargeTransferFee(msg.sender, amount);

                    transferBalance(msg.sender, to, amount);
                    Transfer(msg.sender, to, amount);
                }
                return true;
          } else {
              return false;
          }
    }
 
    function transferFrom(address from, address to, uint amount)
        public returns (bool) {
        activateDividends(from, to);
        //activateDividendsFunc(to);
        if ( amount >= minTransfer
            && allowed[from][msg.sender] >= amount
            && balances[from] >= amount
            && balances[to] + amount > balances[to]
            ) {
                allowed[from][msg.sender] -= amount;

                if (balances[from] >= amount) {
                    amount = chargeTransferFee(from, amount);

                    transferBalance(from, to, amount);
                    Transfer(from, to, amount);
                }
                return true;
        } else {
            return false;
        }
    }
 
    function approve(address spender, uint amount) public returns (bool) {
        allowed[msg.sender][spender] = amount;
        Approval(msg.sender, spender, amount);
        return true;
    }
 
    function allowance(address addr, address spender) constant public returns (uint) {
        return allowed[addr][spender];
    }

    function setTransferFee(uint32 numinator, uint32 denuminator) onlyOwner public {
        require(denuminator > 0 && numinator < denuminator);
        transferFeeNum = numinator;
        transferFeeDenum = denuminator;
    }

    // Manual sell
    function sell(address to, uint amount) onlyOwner public {
        activateDividends(to);
        //require(amount >= minTransfer && balanceEnough(amount));
        require(amount >= minTransfer);

        transferBalance(this, to, amount);
        Transfer(this, to, amount);
    }

    // issue new coins
    function issue(uint amount) onlyOwner public {
        totalSupply = totalSupply.add(amount);
        balances[this] = balances[this].add(amount);
    }

    function changeRate(uint256 new_rate) public onlyOwner {
        require(new_rate > 0);
        rate = new_rate;
    }

    function changeMinimalWei(uint256 new_wei) public onlyOwner {
        minimalWei = new_wei;
    }

    // buy for ethereum
    function buyTokens(address addr)
        public payable {
        activateDividends(msg.sender);
        uint256 weiAmount = msg.value;
        require(weiAmount >= minimalWei);
        //uint256 tkns = weiAmount.mul(rate) / 1 ether * (uint256(10)**decimals);
        uint256 tkns = weiAmount.mul(rate).div(1 ether).mul(uint256(10)**decimals);
        require(tkns > 0);

        weiRaised = weiRaised.add(weiAmount);

        transferBalance(this, addr, tkns);
        TokenPurchase(this, addr, weiAmount, tkns);
        owner.transfer(msg.value);
    }

    // destroy existing coins
    // TOD: not destroy dividends tokens
    function destroy(uint amount) onlyOwner public {
          //require(amount > 0 && balanceEnough(amount));
          require(amount > 0);
          transferBalance(this, address(0x0), amount);
          totalSupply -= amount;
    }

    function () payable public {
        buyTokens(msg.sender);
    }

    // kill contract only if all wallets are empty
    function kill() onlyOwner public {
        require (totalSupply == 0);
        selfdestruct(owner);
    }
}