/**
Contract interface:
1. Standars ERC20 methods: balanceOf, totalSupply, transfer, transferFrom, approve, allowance
2. Finction issue, argument amount
issue new amount coins to totalSupply
3. destroy, argument amount
remove amount coins from totalSupply if available in contract
used only by contract owner
4. sell - argument amount, to
Used only by contract owner
Send amount coins to address to
5. kill
Used only by contract owner
destroy cantract
Contract can be destroyed if totalSupply is empty and all wallets are empty
6. setTransferFee arguments numinator, denuminator
Used only by contract owner
set transfer fee to numinator/denuminator
6. setDemurringFee arguments numinator, denuminator
Used only by contract owner
set demurring fee to numinator/denuminator
7. changeDemurringFeeOwner, argument address 
Used only by contract owner
change demurring fees recipient to address
8. changeTransferFeeOwner, argument address 
Used only by contract owner
change transfer fees recipient to address
*/

pragma solidity ^0.4.11;

/* 
contract svb_ {
  struct Block {
    uint timestamp;
  }

  Block block;

  uint now = 0;

  function setBlockTime(uint val) {
    now = val;
    block.timestamp = val;
  }

  function addBlockTime(uint val) {
    now += val;
    block.timestamp += val;
  }
}
*/

//contract svb is svb_ {
contract svb {
    // totalSupply is zero by default, owner can issue and destroy coins any amount any time
    uint constant totalSupplyDefault = 0;

    string public constant symbol = "SVB";
    string public constant name = "Silver";
    uint8 public constant decimals = 5;
    // minimum fee is 0.00001
    uint32 public constant minFee = 1;
    uint32 public constant minTransfer = 10;

    uint public totalSupply = 0;

    // transfer fee default = 0.17% (0.0017)
    uint32 public transferFeeNum = 17;
    uint32 public transferFeeDenum = 10000;

    // demurring fee default = 0,7 % per year
    // 0.007 per year = 0.007 / 365 per day = 0.000019178 per day
    // 0.000019178 / (24*60) per minute = 0.000000013 per minute
    uint32 public demurringFeeNum = 13;
    uint32 public demurringFeeDenum = 1000000000;

    
    // Owner of this contract
    address public owner;
    modifier onlyOwner() {
        if (msg.sender != owner) {
            revert();
        }
        _;
    }
    address public demurringFeeOwner;
    address public transferFeeOwner;
 
    // Balances for each account
    mapping(address => uint) balances;

    // demurring fee deposit payed date for each account
    mapping(address => uint64) timestamps;
 
    // Owner of account approves the transfer of an amount to another account
    mapping(address => mapping (address => uint)) allowed;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed from , address indexed to , uint256 value);
    event DemurringFee(address indexed to , uint256 value);
    event TransferFee(address indexed to , uint256 value);

    // if supply provided is 0, then default assigned
    function svb(uint supply) {
        if (supply > 0) {
            totalSupply = supply;
        } else {
            totalSupply = totalSupplyDefault;
        }
        owner = msg.sender;
        demurringFeeOwner = owner;
        transferFeeOwner = owner;
        balances[this] = totalSupply;
    }

    function changeDemurringFeeOwner(address addr) onlyOwner {
        demurringFeeOwner = addr;
    }
    function changeTransferFeeOwner(address addr) onlyOwner {
        transferFeeOwner = addr;
    }
 
    function balanceOf(address addr) constant returns (uint) {
        return balances[addr];
    }

    // charge demurring fee for previuos period
    // fee is not applied to owners
    function chargeDemurringFee(address addr) internal {
        if (addr != owner && addr != transferFeeOwner && addr != demurringFeeOwner && balances[addr] > 0 && now > timestamps[addr] + 60) {
            var mins = (now - timestamps[addr]) / 60;
            var fee = balances[addr] * mins * demurringFeeNum / demurringFeeDenum;
            if (fee < minFee) {
                fee = minFee;
            } else if (fee > balances[addr]) {
                fee = balances[addr];
            }

            balances[addr] -= fee;
            balances[demurringFeeOwner] += fee;
            Transfer(addr, demurringFeeOwner, fee);
            DemurringFee(addr, fee);

            timestamps[addr] = uint64(now);
        }
    }

    // fee is not applied to owners
    function chargeTransferFee(address addr, uint amount) internal returns (uint) {
        if (addr != owner && addr != transferFeeOwner && addr != demurringFeeOwner && balances[addr] > 0) {
            var fee = amount * transferFeeNum / transferFeeDenum;
            if (fee < minFee) {
                fee = minFee;
            } else if (fee > balances[addr]) {
                fee = balances[addr];
            }
            amount = amount - fee;

            balances[addr] -= fee;
            balances[transferFeeOwner] += fee;
            Transfer(addr, transferFeeOwner, fee);
            TransferFee(addr, fee);
        }
        return amount;
    }
 
    function transfer(address to, uint amount) returns (bool) {
        if (amount >= minTransfer
            && balances[msg.sender] >= amount
            && balances[to] + amount > balances[to]
            ) {
                chargeDemurringFee(msg.sender);

                if (balances[msg.sender] >= amount) {
                    amount = chargeTransferFee(msg.sender, amount);

                    // charge recepient with demurring fee
                    if (balances[to] > 0) {
                        chargeDemurringFee(to);
                    } else {
                        timestamps[to] = uint64(now);
                    }

                    balances[msg.sender] -= amount;
                    balances[to] += amount;
                    Transfer(msg.sender, to, amount);
                }
                return true;
          } else {
              return false;
          }
    }
 
    function transferFrom(address from, address to, uint amount) returns (bool) {
        if ( amount >= minTransfer
            && allowed[from][msg.sender] >= amount
            && balances[from] >= amount
            && balances[to] + amount > balances[to]
            ) {
                allowed[from][msg.sender] -= amount;

                chargeDemurringFee(msg.sender);

                if (balances[msg.sender] >= amount) {
                    amount = chargeTransferFee(msg.sender, amount);

                    // charge recepient with demurring fee
                    if (balances[to] > 0) {
                        chargeDemurringFee(to);
                    } else {
                        timestamps[to] = uint64(now);
                    }

                    balances[msg.sender] -= amount;
                    balances[to] += amount;
                    Transfer(msg.sender, to, amount);
                }
                return true;
        } else {
            return false;
        }
    }
 
    function approve(address spender, uint amount) returns (bool) {
        allowed[msg.sender][spender] = amount;
        Approval(msg.sender, spender, amount);
        return true;
    }
 
    function allowance(address addr, address spender) constant returns (uint) {
        return allowed[addr][spender];
    }

    function setTransferFee(uint32 numinator, uint32 denuminator) onlyOwner {
        require(denuminator > 0 && numinator < denuminator);
        transferFeeNum = numinator;
        transferFeeDenum = denuminator;
    }

    function setDemurringFee(uint32 numinator, uint32 denuminator) onlyOwner {
        require(denuminator > 0 && numinator < denuminator);
        demurringFeeNum = numinator;
        demurringFeeDenum = denuminator;
    }

    function sell(address to, uint amount) onlyOwner {
        require(amount > minTransfer && balances[this] >= amount);

        // charge recepient with demurring fee
        if (balances[to] > 0) {
            chargeDemurringFee(to);
        } else {
            timestamps[to] = uint64(now);
        }
        balances[this] -= amount;
        balances[to] += amount;
        Transfer(this, to, amount);
    }

    // issue new coins
    function issue(uint amount) onlyOwner {
         if (totalSupply + amount > totalSupply) {
             totalSupply += amount;
             balances[this] += amount;
         }
    }

    // destroy existing coins
    function destroy(uint amount) onlyOwner {
          require(amount>0 && balances[this] >= amount);
          balances[this] -= amount;
          totalSupply -= amount;
    }

    // kill contract only if all wallets are empty
    function kill() onlyOwner {
        require (totalSupply == 0);
        selfdestruct(owner);
    }

    // payments ar reverted back
    function () payable {
        revert();
    }
}