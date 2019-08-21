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

    function Ownable() public {
        owner = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }
}

contract ERC20Basic {
    uint256 public totalSupply;
    function balanceOf(address who) constant public returns (uint256);
    function transfer(address to, uint256 value) public returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
}

contract ERC20 is ERC20Basic {
    function allowance(address owner, address spender) constant public returns (uint256);
    function transferFrom(address from, address to, uint256 value) public  returns (bool);
    function approve(address spender, uint256 value) public returns (bool);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract BasicToken is ERC20Basic, Ownable {

    using SafeMath for uint256;

    mapping (address => uint256) balances;

    modifier onlyPayloadSize(uint size) {
        if (msg.data.length < size + 4) {
            revert();
        }
        _;
    }

    function transfer(address _to, uint256 _amount) public onlyPayloadSize(2 * 32) returns (bool) {
        require(balances[msg.sender] >= _amount);
        balances[msg.sender] = balances[msg.sender].sub(_amount);
        balances[_to] = balances[_to].add(_amount);
        Transfer(msg.sender, _to, _amount);
        return true;
    }

    function balanceOf(address _addr) public constant returns (uint256) {
        return balances[_addr];
    }
}

contract AdvancedToken is BasicToken, ERC20 {

    mapping (address => mapping (address => uint256)) allowances;

    function transferFrom(address _from, address _to, uint256 _amount) public onlyPayloadSize(3 * 32) returns (bool) {
        require(allowances[_from][msg.sender] >= _amount && balances[_from] >= _amount);
        allowances[_from][msg.sender] = allowances[_from][msg.sender].sub(_amount);
        balances[_from] = balances[_from].sub(_amount);
        balances[_to] = balances[_to].add(_amount);
        Transfer(_from, _to, _amount);
        return true;
    }

    function approve(address _spender, uint256 _amount) public returns (bool) {
        allowances[msg.sender][_spender] = _amount;
        Approval(msg.sender, _spender, _amount);
        return true;
    }

    function increaseApproval(address _spender, uint256 _amount) public returns (bool) {
        allowances[msg.sender][_spender] = allowances[msg.sender][_spender].add(_amount);
        Approval(msg.sender, _spender, allowances[msg.sender][_spender]);
        return true;
    }

    function decreaseApproval(address _spender, uint256 _amount) public returns (bool) {
        require(allowances[msg.sender][_spender] != 0);
        if (_amount >= allowances[msg.sender][_spender]) {
            allowances[msg.sender][_spender] = 0;
        } else {
            allowances[msg.sender][_spender] = allowances[msg.sender][_spender].sub(_amount);
            Approval(msg.sender, _spender, allowances[msg.sender][_spender]);
        }
    }

    function allowance(address _owner, address _spender) public constant returns (uint256) {
        return allowances[_owner][_spender];
    }

}

contract MintableToken is AdvancedToken {

    bool public mintingFinished;

    event TokensMinted(address indexed to, uint256 amount);
    event MintingFinished();

    function mint(address _to, uint256 _amount) external onlyOwner onlyPayloadSize(2 * 32) returns (bool) {
        require(_to != 0x0 && _amount > 0 && !mintingFinished);
        balances[_to] = balances[_to].add(_amount);
        totalSupply = totalSupply.add(_amount);
        Transfer(0x0, _to, _amount);
        TokensMinted(_to, _amount);
        return true;
    }

    function finishMinting() external onlyOwner {
        require(!mintingFinished);
        mintingFinished = true;
        MintingFinished();
    }

    function mintingFinished() public constant returns (bool) {
        return mintingFinished;
    }
}

contract ACO is MintableToken {

    uint8 public decimals;
    string public name;
    string public symbol;

    function ACO() public {
        totalSupply = 0;
        decimals = 18;
        name = "ACO";
        symbol = "ACO";
    }
}

contract MultiOwnable {
    
    address[2] public owners;

    event OwnershipTransferred(address from, address to);
    event OwnershipGranted(address to);

    function MultiOwnable() public {
        owners[0] = 0x1d554c421182a94E2f4cBD833f24682BBe1eeFe8; 
        owners[1] = 0x0D7a2716466332Fc5a256FF0d20555A44c099453; 
    }

    modifier onlyOwners {
        require(msg.sender == owners[0] || msg.sender == owners[1]);
        _;
    }

    function transferOwnership(address _newOwner) public onlyOwners {
        require(_newOwner != 0x0 && _newOwner != owners[0] && _newOwner != owners[1]);
        if (msg.sender == owners[0]) {
            OwnershipTransferred(owners[0], _newOwner);
            owners[0] = _newOwner;
        } else {
            OwnershipTransferred(owners[1], _newOwner);
            owners[1] = _newOwner;
        }
    }
}

contract Crowdsale is Ownable, MultiOwnable {

    using SafeMath for uint256;

    ACO public ACO_Token;

    address public constant MULTI_SIG = 0x3Ee28dA5eFe653402C5192054064F12a42EA709e;

    uint256 public rate;

    uint256 public tokensSold;
    uint256 public startTime;
    uint256 public endTime;
    uint256 public softCap;
    uint256 public hardCap;

    uint256[4] public bonusStages;

    mapping (address => uint256) investments;
    mapping (address => bool) hasAuthorizedWithdrawal;

    event TokensPurchased(address indexed by, uint256 amount);
    event RefundIssued(address indexed by, uint256 amount);
    event FundsWithdrawn(address indexed by, uint256 amount);
    event DurationAltered(uint256 newEndTime);
    event NewSoftCap(uint256 newSoftCap);
    event NewHardCap(uint256 newHardCap);
    event NewRateSet(uint256 newRate);
    event HardCapReached();
    event SoftCapReached();

    function Crowdsale() public {
        ACO_Token = new ACO();
        softCap = 0; 
        hardCap = 250000000e18; 
        rate = 4000;
        startTime = now;
        endTime = startTime.add(365 days);
        bonusStages[0] = startTime.add(6 weeks);

        for(uint i = 1; i < bonusStages.length; i++) {
            bonusStages[i] = bonusStages[i - 1].add(6 weeks);
        }
    }

    function processOffchainPayment(address _beneficiary, uint256 _toMint) public onlyOwners {
        require(_beneficiary != 0x0 && now <= endTime && tokensSold.add(_toMint) <= hardCap && _toMint > 0);
        if(tokensSold.add(_toMint) == hardCap) { HardCapReached(); }
        if(tokensSold.add(_toMint) >= softCap && !isSuccess()) { SoftCapReached(); }
        ACO_Token.mint(_beneficiary, _toMint);
        tokensSold = tokensSold.add(_toMint);
        TokensPurchased(_beneficiary, _toMint);
    }

    function() public payable {
        buyTokens(msg.sender);
    }

    function buyTokens(address _beneficiary) public payable {
        require(_beneficiary != 0x0 && validPurchase() && tokensSold.add(calculateTokensToMint()) <= hardCap); 
        if(tokensSold.add(calculateTokensToMint()) == hardCap) { HardCapReached(); }
        if(tokensSold.add(calculateTokensToMint()) >= softCap && !isSuccess()) { SoftCapReached(); }
        uint256 toMint = calculateTokensToMint();
        ACO_Token.mint(_beneficiary, toMint);
        tokensSold = tokensSold.add(toMint);
        investments[_beneficiary] = investments[_beneficiary].add(msg.value);
        TokensPurchased(_beneficiary, toMint); 
    }

    function calculateTokensToMint() internal view returns(uint256 toMint) {
        toMint = msg.value.mul(getCurrentRateWithBonus());
    }

    function getCurrentRateWithBonus() public view returns (uint256 rateWithBonus) {
        rateWithBonus = (rate.mul(getBonusPercentage()).div(100)).add(rate);
    }

    function getBonusPercentage() internal view returns (uint256 bonusPercentage) {
        uint256 timeStamp = now;
        if (timeStamp > bonusStages[3]) {
            bonusPercentage = 0;
        } else { 
            bonusPercentage = 25;
            for (uint i = 0; i < bonusStages.length; i++) {
                if (timeStamp <= bonusStages[i]) {
                    break;
                } else {
                    bonusPercentage = bonusPercentage.sub(5);
                }
            }
        }
        return bonusPercentage;
    }

    function authorizeWithdrawal() public onlyOwners {
        require(hasEnded() && isSuccess() && !hasAuthorizedWithdrawal[msg.sender]);
        hasAuthorizedWithdrawal[msg.sender] = true;
        if (hasAuthorizedWithdrawal[owners[0]] && hasAuthorizedWithdrawal[owners[1]]) {
            FundsWithdrawn(owners[0], this.balance);
            MULTI_SIG.transfer(this.balance);
        }
    }

    function issueBounty(address _to, uint256 _toMint) public onlyOwners {
        require(_to != 0x0 && _toMint > 0 && tokensSold.add(_toMint) <= hardCap);
        ACO_Token.mint(_to, _toMint);
        tokensSold = tokensSold.add(_toMint);
    }

    function finishMinting() public onlyOwners {
        require(hasEnded());
        ACO_Token.finishMinting();
    }

    function getRefund(address _addr) public {
        if(_addr == 0x0) { _addr = msg.sender; }
        require(!isSuccess() && hasEnded() && investments[_addr] > 0);
        uint256 toRefund = investments[_addr];
        investments[_addr] = 0;
        _addr.transfer(toRefund);
        RefundIssued(_addr, toRefund);
    }
    
    function giveRefund(address _addr) public onlyOwner {
        require(_addr != 0x0 && investments[_addr] > 0);
        uint256 toRefund = investments[_addr];
        investments[_addr] = 0;
        _addr.transfer(toRefund);
        RefundIssued(_addr, toRefund);
    }

    function isSuccess() public view returns(bool success) {
        success = tokensSold >= softCap;
    }

    function hasEnded() public view returns(bool ended) {
        ended = now > endTime;
    }

    function investmentOf(address _addr) public view returns(uint256 investment) {
        investment = investments[_addr];
    }

    function validPurchase() internal constant returns (bool) {
        bool withinPeriod = now >= startTime && now <= endTime;
        bool nonZeroPurchase = msg.value != 0;
        return withinPeriod && nonZeroPurchase;
    }

    function setEndTime(uint256 _numberOfDays) public onlyOwners {
        require(_numberOfDays > 0);
        endTime = now.add(_numberOfDays * 1 days);
        DurationAltered(endTime);
    }

    function changeSoftCap(uint256 _newSoftCap) public onlyOwners {
        require(_newSoftCap > 0);
        softCap = _newSoftCap;
        NewSoftCap(softCap);
    }

    function changeHardCap(uint256 _newHardCap) public onlyOwners {
        assert(_newHardCap > 0);
        hardCap = _newHardCap;
        NewHardCap(hardCap);
    }

    function changeRate(uint256 _newRate) public onlyOwners {
        require(_newRate > 0);
        rate = _newRate;
        NewRateSet(rate);
    }
}