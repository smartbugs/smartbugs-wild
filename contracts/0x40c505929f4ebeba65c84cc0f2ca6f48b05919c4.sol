/**
 * @title ERC20Basic
 * @dev Simpler version of ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/179
 */
pragma solidity ^0.4.18;

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
        uint256 c = a * b;
        assert(a == 0 || c / a == b);
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

contract BasicToken is ERC20Basic {
    using SafeMath for uint256;

    mapping(address => uint256) balances;

    /**
    * @dev transfer token for a specified address
    * @param _to The address to transfer to.
    * @param _value The amount to be transferred.
    */
    function transfer(address _to, uint256 _value) public returns (bool) {
        balances[_to] = balances[_to].add(_value);
        balances[msg.sender] = balances[msg.sender].sub(_value);
        Transfer(msg.sender, _to, _value);
        return true;
    }

    /**
    * @dev Gets the balance of the specified address.
    * @param _owner The address to query the the balance of.
    * @return An uint256 representing the amount owned by the passed address.
    */
    function balanceOf(address _owner) public constant returns (uint256 balance) {
        return balances[_owner];
    }

}

contract StandardToken is ERC20, BasicToken {

    mapping (address => mapping (address => uint256)) allowed;


    /**
     * @dev Transfer tokens from one address to another
     * @param _from address The address which you want to send tokens from
     * @param _to address The address which you want to transfer to
     * @param _value uint256 the amout of tokens to be transfered
     */
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
        var _allowance = allowed[_from][msg.sender];

        // Check is not needed because sub(_allowance, _value) will already throw if this condition is not met
        // require (_value <= _allowance);

        balances[_to] = balances[_to].add(_value);
        balances[_from] = balances[_from].sub(_value);
        allowed[_from][msg.sender] = _allowance.sub(_value);
        Transfer(_from, _to, _value);
        return true;
    }

    /**
     * @dev Aprove the passed address to spend the specified amount of tokens on behalf of msg.sender.
     * @param _spender The address which will spend the funds.
     * @param _value The amount of tokens to be spent.
     */
    function approve(address _spender, uint256 _value) public returns (bool) {

        // To change the approve amount you first have to reduce the addresses`
        //  allowance to zero by calling `approve(_spender, 0)` if it is not
        //  already 0 to mitigate the race condition described here:
        //  https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
        require((_value == 0) || (allowed[msg.sender][_spender] == 0));

        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }

    /**
     * @dev Function to check the amount of tokens that an owner allowed to a spender.
     * @param _owner address The address which owns the funds.
     * @param _spender address The address which will spend the funds.
     * @return A uint256 specifing the amount of tokens still avaible for the spender.
     */
    function allowance(address _owner, address _spender) public constant returns (uint256 remaining) {
        return allowed[_owner][_spender];
    }

}

contract Ownable {
    address public owner;

    /**
     * @dev The Ownable constructor sets the original `owner` of the contract to the sender
     * account.
     */
    function Ownable() public {
        owner = msg.sender;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        assert(msg.sender == owner);
        _;
    }

    /**
     * @dev Allows the current owner to transfer control of the contract to a newOwner.
     * @param newOwner The address to transfer ownership to.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        if (newOwner != address(0)) {
            owner = newOwner;
        }
    }
}

contract TheMoveToken is StandardToken, Ownable {
    string public constant name = "MOVE Token";
    string public constant symbol = "MOVE";
    uint public constant decimals = 18;
    using SafeMath for uint256;
    // timestamps for PRE-ICO phase
    uint public preicoStartDate;
    uint public preicoEndDate;
    // timestamps for ICO phase
    uint public icoStartDate;
    uint public icoEndDate;
    // address where funds are collected
    address public wallet;
    // how many token units a buyer gets per wei
    uint256 public rate;
    uint256 public minTransactionAmount;
    uint256 public raisedForEther = 0;
    uint256 private preicoSupply = 3072000000000000000000000;
    uint256 private icoSupply = 10000000000000000000000000;
    uint256 private bonusesSupply = 3000000000000000000000000;

    uint256 public bonusesSold = 0;
    uint256 public tokensSold = 0;

    // PRE-ICO stages
    uint256 public stage1 = 240000000000000000000000;
    uint256 public stage2 = 360000000000000000000000;
    uint256 public stage3 = 960000000000000000000000;
    uint256 public stage4 = 1512000000000000000000000;

    modifier inActivePeriod() {
	   require((preicoStartDate < now && now <= preicoEndDate) || (icoStartDate < now && now <= icoEndDate));
        _;
    }

    function TheMoveToken(uint _preicostart, uint _preicoend,uint _icostart, uint _icoend, address _wallet) public {
        require(_wallet != 0x0);
        require(_preicostart < _preicoend);
        require(_preicoend < _icostart);
        require(_icostart < _icoend);

        totalSupply = 21172000000000000000000000;
        rate = 3600;

        // minimal invest
        minTransactionAmount = 0.1 ether;
        icoStartDate = _icostart;
        icoEndDate = _icoend;
        preicoStartDate = _preicostart;
        preicoEndDate = _preicoend;
        wallet = _wallet;

	   // Store the ico funds in the contract and send the rest to the developer wallet
       uint256 amountInContract = preicoSupply + icoSupply + bonusesSupply;
       uint256 amountDevelopers = totalSupply - amountInContract;
       
	   balances[this] = balances[this].add(amountInContract);
	   Transfer(_wallet, _wallet, amountDevelopers);
       balances[_wallet] = balances[_wallet].add(totalSupply - amountInContract);
       Transfer(_wallet, this, amountInContract);
    }

    function setupPREICOPeriod(uint _start, uint _end) public onlyOwner {
        require(_start < _end);
        preicoStartDate = _start;
        preicoEndDate = _end;
    }

    function setupICOPeriod(uint _start, uint _end) public onlyOwner {
        require(_start < _end);
        icoStartDate = _start;
        icoEndDate = _end;
    }
    
    function setRate(uint256 _rate) public onlyOwner {
        rate = _rate;
    }

    // fallback function can be used to buy tokens
    function () public inActivePeriod payable {
        buyTokens(msg.sender);
    }

    function burnPREICOTokens() public onlyOwner {
        int256 amountToBurn = int256(preicoSupply) - int256(tokensSold);
        if (amountToBurn > 0) {
            balances[this] = balances[this].sub(uint256(amountToBurn));
        }
    }
    
    function sendTokens(address _sender, uint256 amount) public inActivePeriod onlyOwner {
        // calculate token amount to be issued
        uint256 tokens = amount.mul(rate);
        tokens += getBonus(tokens);

        if (isPREICO()) {
            require(tokensSold + tokens < preicoSupply);
        } else if (isICO()) {
            require(tokensSold + tokens <= (icoSupply + bonusesSupply));
        }

        issueTokens(_sender, tokens);
        tokensSold += tokens;
    }

    // Use with extreme caution this will burn the rest of the tokens in the contract
    function burnICOTokens() public onlyOwner {
        balances[this] = 0;
    }

    function burnBonuses() public onlyOwner {
        int256 amountToBurn = int256(bonusesSupply) - int256(bonusesSold);
        if (amountToBurn > 0) {
            balances[this] = balances[this].sub(uint256(amountToBurn));
        }
    }

    // low level token purchase function
    function buyTokens(address _sender) public inActivePeriod payable {
        require(_sender != 0x0);
        require(msg.value >= minTransactionAmount);

        uint256 weiAmount = msg.value;

        raisedForEther = raisedForEther.add(weiAmount);

        // calculate token amount to be created
        uint256 tokens = weiAmount.mul(rate);
        tokens += getBonus(tokens);

        if (isPREICO()) {
            require(tokensSold + tokens < preicoSupply);
        } else if (isICO()) {
            require(tokensSold + tokens <= (icoSupply + bonusesSupply));
        }

        issueTokens(_sender, tokens);
        tokensSold += tokens;
    }

    function withdrawEther(uint256 amount) external onlyOwner {
        owner.transfer(amount);
    }

    function isPREICO() public view returns (bool) {
        return (preicoStartDate < now && now <= preicoEndDate);
    }

    function isICO() public view returns (bool) {
        return (icoStartDate < now && now <= icoEndDate);
    }
    
    function setTokensSold(uint256 amount) public onlyOwner {
        tokensSold = amount;
    }

    function getBonus(uint256 _tokens) public returns (uint256) {
        require(_tokens != 0);
        uint256 bonuses = 0;
        uint256 multiplier = 0;

        // First case if PRE-ICO is happening
        if (isPREICO()) {
            // Bonus depends on the amount of tokens sold.
            if (tokensSold < stage1) {
                // 100% bonus for stage1
                multiplier = 100;
            } else if (stage1 < tokensSold && tokensSold < (stage1 + stage2)) {
                // 80% bonus for stage2
                multiplier = 80;
            } else if ((stage1 + stage2) < tokensSold && tokensSold < (stage1 + stage2 + stage3)) {
                // 60% bonus for stage2
                multiplier = 60;
            } else if ((stage1 + stage2 + stage3) < tokensSold && tokensSold < (stage1 + stage2 + stage3 + stage4)) {
                // 40% bonus for stage2
                multiplier = 40;
            }
            bonuses = _tokens.mul(multiplier).div(100);

            return bonuses;
        }

        
        // Second case if ICO is happening
        else if (isICO()) {
            // Bonus depends on the week of the ICO and the bonus supply
            if (icoStartDate < now && now <= icoStartDate + 7 days) {
                // 20% bonus week 1
                multiplier = 20;
            } else if (icoStartDate + 7 days < now && now <= icoStartDate + 14 days ) {
                // 10% bonus week 2
                multiplier = 10;
            } else if (icoStartDate + 14 days < now && now <= icoStartDate + 21 days ) {
                // 5% bonus week 3
                multiplier = 5;
            }

            bonuses = _tokens.mul(multiplier).div(100);

            // Bonus supply limit reached.
            if (bonusesSold + bonuses > bonusesSupply) {
                bonuses = 0;
            } else {
                bonusesSold += bonuses;
            }
            return bonuses;
        } 
    }

    function issueTokens(address _to, uint256 _value) internal returns (bool) {
        balances[_to] = balances[_to].add(_value);
        balances[this] = balances[this].sub(_value);
        Transfer(msg.sender, _to, _value);
        return true;
    }
}