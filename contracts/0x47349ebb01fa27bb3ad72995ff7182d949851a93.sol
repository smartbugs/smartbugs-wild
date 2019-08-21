pragma solidity ^0.4.18;

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


contract ERC20Basic {
    uint256 public totalSupply;
    function balanceOf(address who) public view returns (uint256);
    function transfer(address to, uint256 value) public returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
}


contract ERC20 is ERC20Basic {
    function allowance(address owner, address spender) public view returns (uint256);
    function transferFrom(address from, address to, uint256 value) public returns (bool);
    function approve(address spender, uint256 value) public returns (bool);
    event Approval(address indexed owner, address indexed spender, uint256 value);
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
        require(_to != address(0));
        require(_value <= balances[msg.sender]);

        // SafeMath.sub will throw if there is not enough balance.
        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);
        Transfer(msg.sender, _to, _value);
        return true;
    }

    /**
    * @dev Gets the balance of the specified address.
    * @param _owner The address to query the the balance of.
    * @return An uint256 representing the amount owned by the passed address.
    */
    function balanceOf(address _owner) public view returns (uint256 balance) {
        return balances[_owner];
    }

}


contract Ownable {
    address public owner;


    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


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
        require(msg.sender == owner);
        _;
    }


    /**
     * @dev Allows the current owner to transfer control of the contract to a newOwner.
     * @param newOwner The address to transfer ownership to.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0));
        OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }

}

contract StandardToken is ERC20, BasicToken {

    mapping (address => mapping (address => uint256)) internal allowed;


    /**
     * @dev Transfer tokens from one address to another
     * @param _from address The address which you want to send tokens from
     * @param _to address The address which you want to transfer to
     * @param _value uint256 the amount of tokens to be transferred
     */
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
        require(_to != address(0));
        require(_value <= balances[_from]);
        require(_value <= allowed[_from][msg.sender]);

        balances[_from] = balances[_from].sub(_value);
        balances[_to] = balances[_to].add(_value);
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
        Transfer(_from, _to, _value);
        return true;
    }

    /**
     * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.
     *
     * Beware that changing an allowance with this method brings the risk that someone may use both the old
     * and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this
     * race condition is to first reduce the spender's allowance to 0 and set the desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     * @param _spender The address which will spend the funds.
     * @param _value The amount of tokens to be spent.
     */
    function approve(address _spender, uint256 _value) public returns (bool) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }

    /**
     * @dev Function to check the amount of tokens that an owner allowed to a spender.
     * @param _owner address The address which owns the funds.
     * @param _spender address The address which will spend the funds.
     * @return A uint256 specifying the amount of tokens still available for the spender.
     */
    function allowance(address _owner, address _spender) public view returns (uint256) {
        return allowed[_owner][_spender];
    }

    /**
     * approve should be called when allowed[_spender] == 0. To increment
     * allowed value is better to use this function to avoid 2 calls (and wait until
     * the first transaction is mined)
     * From MonolithDAO Token.sol
     */
    function increaseApproval(address _spender, uint _addedValue) public returns (bool) {
        allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
        Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
        return true;
    }

    function decreaseApproval(address _spender, uint _subtractedValue) public returns (bool) {
        uint oldValue = allowed[msg.sender][_spender];
        if (_subtractedValue > oldValue) {
            allowed[msg.sender][_spender] = 0;
        } else {
            allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
        }
        Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
        return true;
    }

}

contract BurnableToken is StandardToken {

    event Burn(address indexed burner, uint256 value);

    /**
     * @dev Burns a specific amount of tokens.
     * @param _value The amount of token to be burned.
     */
    function burn(uint256 _value) public {
        require(_value > 0);
        require(_value <= balances[msg.sender]);
        // no need to require value <= totalSupply, since that would imply the
        // sender's balance is greater than the totalSupply, which *should* be an assertion failure

        address burner = msg.sender;
        balances[burner] = balances[burner].sub(_value);
        totalSupply = totalSupply.sub(_value);
        Burn(burner, _value);
    }
}

contract MintableToken is StandardToken, Ownable {
    event Mint(address indexed to, uint256 amount);
    event MintFinished();

    bool public mintingFinished = false;


    modifier canMint() {
        require(!mintingFinished);
        _;
    }

    /**
     * @dev Function to mint tokens
     * @param _to The address that will receive the minted tokens.
     * @param _amount The amount of tokens to mint.
     * @return A boolean that indicates if the operation was successful.
     */
    function mint(address _to, uint256 _amount) onlyOwner canMint public returns (bool) {
        totalSupply = totalSupply.add(_amount);
        balances[_to] = balances[_to].add(_amount);
        Mint(_to, _amount);
        Transfer(address(0), _to, _amount);
        return true;
    }

    /**
     * @dev Function to stop minting new tokens.
     * @return True if the operation was successful.
     */
    function finishMinting() onlyOwner canMint public returns (bool) {
        mintingFinished = true;
        MintFinished();
        return true;
    }
}


contract HireGoToken is MintableToken, BurnableToken {

    string public constant name = "HireGo";
    string public constant symbol = "HGO";
    uint32 public constant decimals = 18;

    function HireGoToken() public {
        totalSupply = 100000000E18;  //100m
        balances[owner] = totalSupply; // Add all tokens to issuer balance (crowdsale in this case)
    }

}


contract HireGoCrowdsale is Ownable {

    using SafeMath for uint;

    HireGoToken public token = new HireGoToken();
    uint totalSupply = token.totalSupply();

    bool public isRefundAllowed;

    uint public icoStartTime;
    uint public icoEndTime;
    uint public totalWeiRaised;
    uint public weiRaised;
    uint public hardCap; // amount of ETH collected, which marks end of crowd sale
    uint public tokensDistributed; // amount of bought tokens
    uint public foundersTokensUnlockTime;

    /*         Bonus variables          */
    uint internal baseBonus1 = 135;
    uint internal baseBonus2 = 130;
    uint internal baseBonus3 = 125;
    uint internal baseBonus4 = 115;
    uint public manualBonus;
    /* * * * * * * * * * * * * * * * * * */

    uint public waveCap1;
    uint public waveCap2;
    uint public waveCap3;
    uint public waveCap4;

    uint public rate; // how many token units a buyer gets per wei
    uint private icoMinPurchase; // In ETH

    address[] public investors_number;
    address private wallet; // address where funds are collected

    mapping (address => uint) public orderedTokens;
    mapping (address => uint) contributors;

    event FundsWithdrawn(address _who, uint256 _amount);

    modifier hardCapNotReached() {
        require(totalWeiRaised < hardCap);
        _;
    }

    modifier crowdsaleEnded() {
        require(now > icoEndTime);
        _;
    }

    modifier foundersTokensUnlocked() {
        require(now > foundersTokensUnlockTime);
        _;
    }

    modifier crowdsaleInProgress() {
        bool withinPeriod = (now >= icoStartTime && now <= icoEndTime);
        require(withinPeriod);
        _;
    }

    function HireGoCrowdsale(uint _icoStartTime, uint _icoEndTime, address _wallet) public {
        require (
          _icoStartTime > now &&
          _icoEndTime > _icoStartTime
        );

        icoStartTime = _icoStartTime;
        icoEndTime = _icoEndTime;
        foundersTokensUnlockTime = icoEndTime.add(180 days);
        wallet = _wallet;

        rate = 250 szabo; // wei per 1 token (0.00025ETH)

        hardCap = 11836 ether;
        icoMinPurchase = 50 finney; // 0.05 ETH
        isRefundAllowed = false;

        waveCap1 = 2777 ether;
        waveCap2 = waveCap1.add(2884 ether);
        waveCap3 = waveCap2.add(4000 ether);
        waveCap4 = waveCap3.add(2174 ether);
    }

    // fallback function can be used to buy tokens
    function() public payable {
        buyTokens();
    }

    // low level token purchase function
    function buyTokens() public payable crowdsaleInProgress hardCapNotReached {
        require(msg.value > 0);

        // check if the buyer exceeded the funding goal
        calculatePurchaseAndBonuses(msg.sender, msg.value);
    }

    // Returns number of investors
    function getInvestorCount() public view returns (uint) {
        return investors_number.length;
    }

    // Owner can allow or disallow refunds even if soft cap is reached. Should be used in case KYC is not passed.
    // WARNING: owner should transfer collected ETH back to contract before allowing to refund, if he already withdrawn ETH.
    function toggleRefunds() public onlyOwner {
        isRefundAllowed = true;
    }

    // Sends ordered tokens to investors after ICO end if soft cap is reached
    // tokens can be send only if ico has ended
    function sendOrderedTokens() public onlyOwner crowdsaleEnded {
        address investor;
        uint tokensCount;
        for(uint i = 0; i < investors_number.length; i++) {
            investor = investors_number[i];
            tokensCount = orderedTokens[investor];
            assert(tokensCount > 0);
            orderedTokens[investor] = 0;
            token.transfer(investor, tokensCount);
        }
    }

    // Owner can send back collected ETH if soft cap is not reached or KYC is not passed
    // WARNING: crowdsale contract should have all received funds to return them.
    // If you have already withdrawn them, send them back to crowdsale contract
    function refundInvestors() public onlyOwner {
        require(now >= icoEndTime);
        require(isRefundAllowed);
        require(msg.sender.balance > 0);

        address investor;
        uint contributedWei;
        uint tokens;
        for(uint i = 0; i < investors_number.length; i++) {
            investor = investors_number[i];
            contributedWei = contributors[investor];
            tokens = orderedTokens[investor];
            if(contributedWei > 0) {
                totalWeiRaised = totalWeiRaised.sub(contributedWei);
                weiRaised = weiRaised.sub(contributedWei);
                if(weiRaised<0){
                  weiRaised = 0;
                }
                contributors[investor] = 0;
                orderedTokens[investor] = 0;
                tokensDistributed = tokensDistributed.sub(tokens);
                investor.transfer(contributedWei); // return funds back to contributor
            }
        }
    }

    // Owner of contract can withdraw collected ETH by calling this function
    function withdraw() public onlyOwner {
        uint to_send = weiRaised;
        weiRaised = 0;
        FundsWithdrawn(msg.sender, to_send);
        wallet.transfer(to_send);
    }

    function burnUnsold() public onlyOwner crowdsaleEnded {
        uint tokensLeft = totalSupply.sub(tokensDistributed);
        token.burn(tokensLeft);
    }

    function finishIco() public onlyOwner {
        icoEndTime = now;
    }

    function distribute_for_founders() public onlyOwner foundersTokensUnlocked {
        uint to_send = 40000000E18; //40m
        checkAndMint(to_send);
        token.transfer(wallet, to_send);
    }

    function transferOwnershipToken(address _to) public onlyOwner {
        token.transferOwnership(_to);
    }

    /***************************
    **  Internal functions    **
    ***************************/

    // Calculates purchase conditions and token bonuses
    function calculatePurchaseAndBonuses(address _beneficiary, uint _weiAmount) internal {
        if (now >= icoStartTime && now < icoEndTime) require(_weiAmount >= icoMinPurchase);

        uint cleanWei; // amount of wei to use for purchase excluding change and hardcap overflows
        uint change;
        uint _tokens;

        //check for hardcap overflow
        if (_weiAmount.add(totalWeiRaised) > hardCap) {
            cleanWei = hardCap.sub(totalWeiRaised);
            change = _weiAmount.sub(cleanWei);
        }
        else cleanWei = _weiAmount;

        assert(cleanWei > 4); // 4 wei is a price of minimal fracture of token

        _tokens = cleanWei.div(rate).mul(1 ether);

        if (contributors[_beneficiary] == 0) investors_number.push(_beneficiary);

        _tokens = calculateBonus(_tokens);
        checkAndMint(_tokens);

        contributors[_beneficiary] = contributors[_beneficiary].add(cleanWei);
        weiRaised = weiRaised.add(cleanWei);
        totalWeiRaised = totalWeiRaised.add(cleanWei);
        tokensDistributed = tokensDistributed.add(_tokens);
        orderedTokens[_beneficiary] = orderedTokens[_beneficiary].add(_tokens);

        if (change > 0) _beneficiary.transfer(change);
    }

    // Calculates bonuses based on current stage
    function calculateBonus(uint _baseAmount) internal returns (uint) {
        require(_baseAmount > 0);

        if (now >= icoStartTime && now < icoEndTime) {
            return calculateBonusIco(_baseAmount);
        }
        else return _baseAmount;
    }

    // Calculates bonuses, specific for the ICO
    // Contains date and volume based bonuses
    function calculateBonusIco(uint _baseAmount) internal returns(uint) {
        if(totalWeiRaised < waveCap1) {
            return _baseAmount.mul(baseBonus1).div(100);
        }
        else if(totalWeiRaised >= waveCap1 && totalWeiRaised < waveCap2) {
            return _baseAmount.mul(baseBonus2).div(100);
        }
        else if(totalWeiRaised >= waveCap2 && totalWeiRaised < waveCap3) {
            return _baseAmount.mul(baseBonus3).div(100);
        }
        else if(totalWeiRaised >= waveCap3 && totalWeiRaised < waveCap4) {
            return _baseAmount.mul(baseBonus4).div(100);
        }
        else {
            // No bonus
            return _baseAmount;
        }
    }

    // Checks if more tokens should be minted based on amount of sold tokens, required additional tokens and total supply.
    // If there are not enough tokens, mint missing tokens
    function checkAndMint(uint _amount) internal {
        uint required = tokensDistributed.add(_amount);
        if(required > totalSupply) token.mint(this, required.sub(totalSupply));
    }
}