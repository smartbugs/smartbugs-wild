pragma solidity ^0.4.17;

library SafeMath {
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a * b;
        assert(a == 0 || c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a / b;
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

contract Ownable {
    address public owner;

    function Ownable() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    function transferOwnership(address newOwner) onlyOwner {
        if (newOwner != address(0)) {
            owner = newOwner;
        }
    }

}

contract Fund is Ownable {
    using SafeMath for uint256;
    
    string public name = "Slot Token";
    uint8 public decimals = 0;
    string public symbol = "SLOT";
    string public version = "0.8";
    
    uint8 constant TOKENS = 0;
    uint8 constant TOTALSTAKE = 1;
    
    uint256 totalWithdrawn;
    uint256 public totalSupply;
    
    mapping(address => uint256[2][]) balances;
    mapping(address => uint256) withdrawals;
    
    event Withdrawn(
            address indexed investor, 
            address indexed beneficiary, 
            uint256 weiAmount);
    event Mint(
            address indexed to, 
            uint256 amount);
    event MintFinished();
    event Transfer(
            address indexed from, 
            address indexed to, 
            uint256 value);
    event Approval(
            address indexed owner, 
            address indexed spender, 
            uint256 value);
            
    mapping (address => mapping (address => uint256)) allowed;

    bool public mintingFinished = false;

    modifier canMint() {
        require(!mintingFinished);
        _;
    }
    
    function Fund() payable {}
    function() payable {}
    
    function getEtherBalance(address _owner) constant public returns (uint256 _balance) {
        uint256[2][] memory snps = balances[_owner];
        
        if (snps.length == 0) { return 0; }
        if (snps.length == 1) {
            uint256 bal = snps[0][TOKENS].mul(getTotalStake()).div(totalSupply);
            return bal.sub(withdrawals[_owner]);
        }

        uint256 balance = 0;
        uint256 prevSnTotalSt = 0;
        
        for (uint256 i = 0 ; i < snps.length-1 ; i++) {
            uint256 snapTotalStake = snps[i][TOTALSTAKE];
            uint256 spanBalance = snps[i][TOKENS].mul(snapTotalStake.sub(prevSnTotalSt)).div(totalSupply);
            balance = balance.add(spanBalance);
            prevSnTotalSt = snapTotalStake;
        }
        
        uint256 b = snps[snps.length-1][TOKENS].mul(getTotalStake().sub(prevSnTotalSt)).div(totalSupply);
        return balance.add(b).sub(withdrawals[_owner]);
    }

    function balanceOf(address _owner) constant returns (uint256 balance) {
        uint256[2][] memory snps = balances[_owner];
        if (snps.length == 0) { return 0; }
        
        return snps[snps.length-1][TOKENS];
    }
    
    function getTotalStake() constant returns (uint256 _totalStake) {
        return this.balance + totalWithdrawn;
    }
    
    function withdrawEther(address _to, uint256 _value) public {
        require(getEtherBalance(msg.sender) >= _value);
        withdrawals[msg.sender] = withdrawals[msg.sender].add(_value);
        totalWithdrawn = totalWithdrawn.add(_value);
        _to.transfer(_value);
        Withdrawn(msg.sender, _to, _value);
    }
    
    function transfer(address _to, uint256 _value) returns (bool) {
        return transferFromPrivate(msg.sender, _to, _value);
    }
    
    function transferFromPrivate(address _from, address _to, uint256 _value) private returns (bool) {
        require(balanceOf(msg.sender) >= _value);
        uint256 fromTokens = balanceOf(msg.sender);
        pushSnp(msg.sender, fromTokens-_value);
        uint256 toTokens = balanceOf(_to);
        pushSnp(_to, toTokens+_value);
        Transfer(_from, _to, _value);
        return true;
    }
    
    function pushSnp(address _beneficiary, uint256 _amount) private {
        if (balances[_beneficiary].length > 0) {
            uint256 length = balances[_beneficiary].length;
            assert(balances[_beneficiary][length-1][TOTALSTAKE] == 0);
            balances[_beneficiary][length-1][TOTALSTAKE] = getTotalStake();
        }
        balances[_beneficiary].push([_amount, 0]);
    }

    function mint(address _to, uint256 _amount) public onlyOwner canMint returns (bool) {
        pushSnp(_to, _amount.add(balanceOf(_to)));
        totalSupply = totalSupply.add(_amount);
        Mint(_to, _amount);
        Transfer(0x0, _to, _amount);
        return true;
    }
    

    function finishMinting() onlyOwner returns (bool) {
        mintingFinished = true;
        MintFinished();
        return true;
    }
    
    
    function approve(address _spender, uint256 _value) returns (bool) {
        require((_value == 0) || (allowed[msg.sender][_spender] == 0));
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }

    function allowance(address _owner, address _spender) constant returns (uint256 remaining) {
        return allowed[_owner][_spender];
    }
    
    function transferFrom(address _from, address _to, uint256 _value) returns (bool) {
        uint256 _allowance = allowed[_from][msg.sender];
        transferFromPrivate(_from, _to, _value);
        allowed[_from][msg.sender] = _allowance.sub(_value);
        return true;
    }
    
}
contract Pausable is Ownable {
  event Pause();
  event Unpause();

  bool public paused = false;

  modifier whenNotPaused() {
    require(!paused);
    _;
  }
  
  modifier whenPaused {
    require(paused);
    _;
  }

  function pause() onlyOwner whenNotPaused returns (bool) {
    paused = true;
    Pause();
    return true;
  }

  function unpause() onlyOwner whenPaused returns (bool) {
    paused = false;
    Unpause();
    return true;
  }
}

contract SlotCrowdsale is Ownable, Pausable {
    using SafeMath for uint256;

    uint256 constant PRICE        =    1 ether;
    uint256 constant TOKEN_CAP    =   10000000;
    uint256 constant BOUNTY       =     250000;
    uint256 constant OWNERS_STAKE =    3750000;
    uint256 constant OWNERS_LOCK  =     200000;
    
    address public bountyWallet;
    address public ownersWallet;
    uint256 public lockBegunAtBlock;
    bool public bountyDistributed = false;
    bool public ownershipDistributed = false;
    
    Fund public fund;
    
    uint256[10] outcomes = [1000000,
                             250000,
                             100000,
                              20000,
                              10000,
                               4000,
                               2000,
                               1250,
                               1000,
                                500];

    uint16[10] outcomesChances = [1, 4, 10, 50, 100, 250, 500,  800, 1000, 2000];
    uint16[10] addedUpChances =  [1, 5, 15, 65, 165, 415, 915, 1715, 2715, 4715];
    
    event OwnershipDistributed();
    event BountyDistributed();

    function SlotCrowdsale() public payable {
        fund = new Fund();
        bountyWallet = 0x00deF93928A3aAD581F39049a3BbCaaB9BbE36C8;
        ownersWallet = 0x0001619153d8FE15B3FA70605859265cb0033c1a;
    }

    function() public payable {
        buyTokenFor(msg.sender);
    }

    function buyTokenFor(address _beneficiary) public whenNotPaused() payable {
        require(_beneficiary != 0x0);
        require(msg.value >= PRICE);
        
        uint256 change = msg.value%PRICE;
        uint256 value = msg.value.sub(change);

        msg.sender.transfer(change);
        ownersWallet.transfer(value);
        fund.mint(_beneficiary, getAmount(value.div(PRICE)));
    }
    
    function correctedIndex(uint8 _index, uint8 i) private constant returns (uint8) {
        require(i < outcomesChances.length);        
        if (outcomesChances[_index] > 0) {
            return uint8((_index + i)%outcomesChances.length);
        } else {
            return correctedIndex(_index, i+1);
        }
    }
    
    function getIndex(uint256 _randomNumber) private returns (uint8) {
        for (uint8 i = 0 ; i < uint8(outcomesChances.length) ; i++) {
            if (_randomNumber < addedUpChances[i]) {
                uint8 index = correctedIndex(i, 0);
                assert(outcomesChances[index] != 0);
                outcomesChances[index]--;
                return index; 
            } else { 
                continue; 
            }
        }
    }

    function getAmount(uint256 _numberOfTries) private returns (uint256) {
        uint16 totalChances = addedUpChances[addedUpChances.length-1];
        uint256 amount = 0;

        for (uint16 i = 0 ; i < _numberOfTries; i++) {
            uint256 rand = uint256(keccak256(block.blockhash(block.number-1),i)) % totalChances;
            amount = amount.add(outcomes[getIndex(rand)]);
        }
        
        return amount;
    }
    
    function crowdsaleEnded() constant private returns (bool) {
        if (fund.totalSupply() >= TOKEN_CAP) { 
            return true;
        } else {
            return false; 
        }
    }
    
    function lockEnded() constant private returns (bool) {
        if (block.number.sub(lockBegunAtBlock) > OWNERS_LOCK) {
            return true; 
        } else {
            return false;
        }
        
    }
        
    function distributeBounty() public onlyOwner {
        require(!bountyDistributed);
        require(crowdsaleEnded());
        
        fund.mint(bountyWallet, BOUNTY);
        
        bountyDistributed = true;
        lockBegunAtBlock = block.number;
        
        BountyDistributed();
    }
    
    function distributeOwnership() public onlyOwner {
        require(!ownershipDistributed);
        require(crowdsaleEnded());
        require(lockEnded());
        
        fund.mint(ownersWallet, OWNERS_STAKE);
        ownershipDistributed = true;
        
        OwnershipDistributed();
    }
    
    function changeOwnersWallet(address _newWallet) public onlyOwner {
        require(_newWallet != 0x0);
        ownersWallet = _newWallet;
    }
    
    function changeBountyWallet(address _newWallet) public onlyOwner {
        require(_newWallet != 0x0);
        bountyWallet = _newWallet;
    }
    
    function changeFundOwner(address _newOwner) public onlyOwner {
        require(_newOwner != 0x0);
        fund.transferOwnership(_newOwner);
    }

    function changeFund(address _newFund) public onlyOwner {
        require(_newFund != 0x0);
        fund = Fund(_newFund);
    }

    function destroy() public onlyOwner {
        selfdestruct(msg.sender);
    }

}