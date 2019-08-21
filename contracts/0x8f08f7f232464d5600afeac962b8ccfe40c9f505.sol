/*! vlp.sol | (c) 2018 Develop by BelovITLab LLC (smartcontract.ru), author @stupidlovejoy | License: MIT */

pragma solidity 0.4.18;

library SafeMath {
    function mul(uint256 a, uint256 b) internal pure returns(uint256) {
        if(a == 0) {
            return 0;
        }
        uint256 c = a * b;
        assert(c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns(uint256) {
        uint256 c = a / b;
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns(uint256) {
        assert(b <= a);
        return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns(uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }
}

contract Ownable {
    address public owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    modifier onlyOwner() { require(msg.sender == owner); _; }

    function Ownable() public {
        owner = msg.sender;
    }

    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0));
        owner = newOwner;
        OwnershipTransferred(owner, newOwner);
    }
}

contract Pausable is Ownable {
    bool public paused = false;

    event Pause();
    event Unpause();

    modifier whenNotPaused() { require(!paused); _; }
    modifier whenPaused() { require(paused); _; }

    function pause() onlyOwner whenNotPaused public {
        paused = true;
        Pause();
    }

    function unpause() onlyOwner whenPaused public {
        paused = false;
        Unpause();
    }
}

contract Withdrawable is Ownable {
    function withdrawEther(address _to, uint _value) onlyOwner public returns(bool) {
        require(_to != address(0));
        require(this.balance >= _value);

        _to.transfer(_value);

        return true;
    }

    function withdrawTokens(ERC20 _token, address _to, uint _value) onlyOwner public returns(bool) {
        require(_to != address(0));

        return _token.transfer(_to, _value);
    }
}

contract ERC20 {
    uint256 public totalSupply;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    function balanceOf(address who) public view returns(uint256);
    function transfer(address to, uint256 value) public returns(bool);
    function transferFrom(address from, address to, uint256 value) public returns(bool);
    function allowance(address owner, address spender) public view returns(uint256);
    function approve(address spender, uint256 value) public returns(bool);
}

contract StandardToken is ERC20 {
    using SafeMath for uint256;

    string public name;
    string public symbol;
    uint8 public decimals;

    mapping(address => uint256) balances;
    mapping (address => mapping (address => uint256)) internal allowed;

    function StandardToken(string _name, string _symbol, uint8 _decimals) public {
        name = _name;
        symbol = _symbol;
        decimals = _decimals;
    }

    function balanceOf(address _owner) public view returns(uint256 balance) {
        return balances[_owner];
    }

    function transfer(address _to, uint256 _value) public returns(bool) {
        require(_to != address(0));
        require(_value <= balances[msg.sender]);

        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);

        Transfer(msg.sender, _to, _value);

        return true;
    }
    
    function multiTransfer(address[] _to, uint256[] _value) public returns(bool) {
        require(_to.length == _value.length);

        for(uint i = 0; i < _to.length; i++) {
            transfer(_to[i], _value[i]);
        }

        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns(bool) {
        require(_to != address(0));
        require(_value <= balances[_from]);
        require(_value <= allowed[_from][msg.sender]);

        balances[_from] = balances[_from].sub(_value);
        balances[_to] = balances[_to].add(_value);
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);

        Transfer(_from, _to, _value);

        return true;
    }

    function allowance(address _owner, address _spender) public view returns(uint256) {
        return allowed[_owner][_spender];
    }

    function approve(address _spender, uint256 _value) public returns(bool) {
        allowed[msg.sender][_spender] = _value;

        Approval(msg.sender, _spender, _value);

        return true;
    }

    function increaseApproval(address _spender, uint _addedValue) public returns(bool) {
        allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);

        Approval(msg.sender, _spender, allowed[msg.sender][_spender]);

        return true;
    }

    function decreaseApproval(address _spender, uint _subtractedValue) public returns(bool) {
        uint oldValue = allowed[msg.sender][_spender];

        if(_subtractedValue > oldValue) {
            allowed[msg.sender][_spender] = 0;
        } else {
            allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
        }

        Approval(msg.sender, _spender, allowed[msg.sender][_spender]);

        return true;
    }
}

contract MintableToken is StandardToken, Ownable {
    event Mint(address indexed to, uint256 amount);
    event MintFinished();

    bool public mintingFinished = false;

    modifier canMint() { require(!mintingFinished); _; }

    function mint(address _to, uint256 _amount) onlyOwner canMint public returns(bool) {
        totalSupply = totalSupply.add(_amount);
        balances[_to] = balances[_to].add(_amount);

        Mint(_to, _amount);
        Transfer(address(0), _to, _amount);

        return true;
    }

    function finishMinting() onlyOwner canMint public returns(bool) {
        mintingFinished = true;

        MintFinished();

        return true;
    }
}

contract CappedToken is MintableToken {
    uint256 public cap;

    function CappedToken(uint256 _cap) public {
        require(_cap > 0);
        cap = _cap;
    }

    function mint(address _to, uint256 _amount) onlyOwner canMint public returns(bool) {
        require(totalSupply.add(_amount) <= cap);

        return super.mint(_to, _amount);
    }
}

contract BurnableToken is StandardToken {
    event Burn(address indexed burner, uint256 value);

    function burn(uint256 _value) public {
        require(_value <= balances[msg.sender]);

        address burner = msg.sender;

        balances[burner] = balances[burner].sub(_value);
        totalSupply = totalSupply.sub(_value);

        Burn(burner, _value);
    }
}

/*
    ICO Velper
*/
contract Token is BurnableToken, CappedToken, Withdrawable {
    function Token() CappedToken(1000000000 ether) StandardToken("Velper", "VLP", 18) public {
        
    }

    function transferOwner(address _from, address _to, uint256 _value) onlyOwner canMint public returns(bool) {
        require(_to != address(0));
        require(_value <= balances[_from]);

        balances[_from] = balances[_from].sub(_value);
        balances[_to] = balances[_to].add(_value);

        Transfer(_from, _to, _value);

        return true;
    }
}

contract Crowdsale is Withdrawable, Pausable {
    using SafeMath for uint;

    struct Step {
        uint priceTokenWei;
        uint tokensForSale;
        uint8[5] salesPercent;
        uint bonusAmount;
        uint bonusPercent;
        uint tokensSold;
        uint collectedWei;
    }

    Token public token;
    address public beneficiary = 0xe57AB27CA8b87a4e249EbeF7c4BdB17D5Ba2832b;
    address public manager = 0xc5195F2Ee6FF2a9164272F62177e52fBCEF37C04;

    Step[] public steps;
    uint8 public currentStep = 0;

    bool public crowdsaleClosed = false;

    mapping(address => mapping(uint8 => mapping(uint8 => uint256))) public canSell;

    event NewRate(uint256 rate);
    event Purchase(address indexed holder, uint256 tokenAmount, uint256 etherAmount);
    event Sell(address indexed holder, uint256 tokenAmount, uint256 etherAmount);
    event NextStep(uint8 step);
    event CrowdsaleClose();

    function Crowdsale() public { }
    
    function init(address _token) {
        token = Token(_token);

        token.mint(manager, 150000000 ether);                                    // 15%
        token.mint(0x2c2ab894738F3b9026404cBeF2BBc2A896811a2C, 150000000 ether); // 15%
        token.mint(0xc9DE5d617cfdfD7fd1F75AB012Bf711A44745fdF, 100000000 ether); // 10%
        token.mint(0x7aF1e2F03086dcA69E821F51158cF2c0F899Fa6e, 50000000 ether); // 5%
        token.mint(0xFa8d5d96E06d969306CCb76610dA20040656A27B, 30000000 ether); // 3%
        token.mint(0x9a724eC84Ea194A33c91af37Edc6026BCB61CF21, 20000000 ether); // 5%

        steps.push(Step(100 szabo, 75000000 ether, [0, 20, 20, 15, 10], 100000 ether, 15, 0, 0));   // 7.5%
        steps.push(Step(200 szabo, 100000000 ether, [0, 0, 20, 20, 20], 100000 ether, 15, 0, 0));   // 10%
        steps.push(Step(400 szabo, 100000000 ether, [0, 0, 0, 20, 20], 100000 ether, 15, 0, 0));   // 10%
        steps.push(Step(800 szabo, 100000000 ether, [0, 0, 0, 0, 35], 100000 ether, 15, 0, 0));   // 10%
        steps.push(Step(2 finney, 125000000 ether, [0, 0, 0, 0, 0], 50000 ether, 10, 0, 0));   // 12.5%
    }

    function() payable public {
        purchase();
    }

    function setTokenRate(uint _value) onlyOwner public {
        require(!crowdsaleClosed);

        steps[currentStep].priceTokenWei = 1 ether / _value;

        NewRate(steps[currentStep].priceTokenWei);
    }
    
    function purchase() whenNotPaused payable public {
        require(!crowdsaleClosed);
        require(msg.value >= 10 szabo);

        Step memory step = steps[currentStep];

        require(step.tokensSold < step.tokensForSale);

        uint sum = msg.value;
        uint amount = sum.mul(1 ether).div(step.priceTokenWei);
        uint retSum = 0;

        if(amount > step.bonusAmount && step.tokensSold.add(amount) < step.tokensForSale) {
            uint bonusAmount = amount.div(100).mul(step.bonusPercent);
            if(step.tokensSold.add(amount).add(bonusAmount) >= step.tokensForSale) {
                bonusAmount = step.tokensForSale.sub(step.tokensSold.add(amount));
            }
            amount = amount.add(bonusAmount);
        }
        
        if(step.tokensSold.add(amount) > step.tokensForSale) {
            uint retAmount = step.tokensSold.add(amount).sub(step.tokensForSale);
            retSum = retAmount.mul(step.priceTokenWei).div(1 ether);

            amount = amount.sub(retAmount);
            sum = sum.sub(retSum);
        }

        steps[currentStep].tokensSold = step.tokensSold.add(amount);
        steps[currentStep].collectedWei = step.collectedWei.add(sum);

        token.mint(msg.sender, amount);

        for(uint8 i = 0; i < step.salesPercent.length; i++) {
            canSell[msg.sender][currentStep][i] = canSell[msg.sender][currentStep][i].add(amount.div(100).mul(step.salesPercent[i]));
        }

        if(retSum > 0) {
            msg.sender.transfer(retSum);
        }

        Purchase(msg.sender, amount, sum);
    }

    /// @dev Salling: new Crowdsale()(0,4700000); new $0.token.Token(); $0.purchase()(100)[1]; $0.nextStep(); $0.sell(100000000000000000000000)[1]; $1.balanceOf(@1) == 1.05e+24
    function sell(uint256 _value) whenNotPaused public {
        require(!crowdsaleClosed);
        require(currentStep > 0);

        require(canSell[msg.sender][currentStep - 1][currentStep] >= _value);
        require(token.balanceOf(msg.sender) >= _value);

        canSell[msg.sender][currentStep - 1][currentStep] = canSell[msg.sender][currentStep - 1][currentStep].sub(_value);
        token.transferOwner(msg.sender, beneficiary, _value);

        uint sum = _value.mul(steps[currentStep].priceTokenWei).div(1 ether);
        msg.sender.transfer(sum);

        Sell(msg.sender, _value, sum);
    }

    function nextStep() onlyOwner public {
        require(!crowdsaleClosed);
        require(steps.length - 1 > currentStep);
        
        currentStep += 1;

        NextStep(currentStep);
    }

    function closeCrowdsale() onlyOwner public {
        require(!crowdsaleClosed);
        
        beneficiary.transfer(this.balance);
        token.mint(beneficiary, token.cap() - token.totalSupply());
        token.finishMinting();
        token.transferOwnership(beneficiary);

        crowdsaleClosed = true;

        CrowdsaleClose();
    }

    /// @dev ManagerTransfer: new Crowdsale()(0,4700000); new $0.token.Token(); $0.purchase()(1000)[2]; $0.managerTransfer(@1,100000000000000000000000)[5]; $0.nextStep(); $0.sell(20000000000000000000000)[1]; $1.balanceOf(@1) == 8e+22
    function managerTransfer(address _to, uint256 _value) public {
        require(msg.sender == manager);

        for(uint8 i = 0; i < steps[currentStep].salesPercent.length; i++) {
            canSell[_to][currentStep][i] = canSell[_to][currentStep][i].add(_value.div(100).mul(steps[currentStep].salesPercent[i]));
        }
        
        token.transferOwner(msg.sender, _to, _value);
    }
}