pragma solidity ^0.4.18;

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {
    function add(uint256 x, uint256 y) pure internal returns (uint256) {
        uint256 z = x + y;
        assert((z >= x) && (z >= y));
        return z;
    }

    function sub(uint256 x, uint256 y) pure internal returns (uint256) {
        assert(x >= y);
        uint256 z = x - y;
        return z;
    }

    function mul(uint256 x, uint256 y) pure internal returns (uint256) {
        uint256 z = x * y;
        assert((x == 0) || (z / x == y));
        return z;
    }
}


/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
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
    require(msg.sender == owner);
    _;
  }
}
/*
 * Haltable
 *
 * Abstract contract that allows children to implement an
 * emergency stop mechanism. Differs from Pausable by causing a throw when in halt mode.
 *
 *
 * Originally envisioned in FirstBlood ICO contract.
 */
contract Haltable is Ownable {
  bool public halted;

  modifier stopInEmergency {
    require (!halted);
    _;
  }

  modifier onlyInEmergency {
    require (halted);
    _;
  }

  // called by the owner on emergency, triggers stopped state
  function halt() external onlyOwner {
    halted = true;
  }

  // called by the owner on end of emergency, returns to normal state
  function unhalt() external onlyOwner onlyInEmergency {
    halted = false;
  }

}

/**
 * @title ERC20Basic
 * @dev Simpler version of ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/179
 */
contract ERC20Basic {
  uint256 public totalSupply;
  function balanceOf(address who) public constant returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}


/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender) public constant returns (uint256);
  function transferFrom(address from, address to, uint256 value) public returns (bool);
  function approve(address spender, uint256 value) public returns (bool);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}



/**
 * @title Basic token
 * @dev Basic version of StandardToken, with no allowances. 
 */
contract BasicToken is ERC20Basic {
  using SafeMath for uint256;

  mapping(address => uint256) balances;

  /**
  * @dev transfer token for a specified address
  * @param _to The address to transfer to.
  * @param _value The amount to be transferred.
  */
  function transfer(address _to, uint256 _value) public returns (bool) {
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
  function balanceOf(address _owner) public constant returns (uint256 balance) {
    return balances[_owner];
  }

}

/**
 * @title Standard ERC20 token
 *
 * @dev Implementation of the basic standard token.
 * @dev https://github.com/ethereum/EIPs/issues/20
 * @dev Based on code by FirstBlood: https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol
 */
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
   * @return A uint256 specifing the amount of tokens still available for the spender.
   */
  function allowance(address _owner, address _spender) public constant returns (uint256 remaining) {
    return allowed[_owner][_spender];
  }

}


/**
 * @title DogezerICOPublicCrowdSale public crowdsale contract
 */
contract DogezerICOPublicCrowdSale is Haltable{
    using SafeMath for uint;

    string public name = "Dogezer Public Sale ITO";

    address public beneficiary;

    uint public startTime = 1518699600;
    uint public stopTime = 1520514000;

    uint public totalTokensAvailableForSale = 9800000000000000;
    uint public preDGZTokensSold = 20699056632305;
    uint public privateSalesTokensSold = 92644444444444;
    uint public tokensAvailableForSale = 0;
    uint public tokensSoldOnPublicRound = 0;

    StandardToken public tokenReward;
    StandardToken public tokenRewardPreDGZ;
        

    mapping(address => uint256) public balanceOf;
    mapping(address => uint256) public nonWLBalanceOf;
    mapping(address => uint256) public preBalanceOf;
    mapping(address => bool) public whiteList;

    event DGZTokensWithdraw(address where, uint amount);
    event DGZTokensSold(address where, uint amount);
    event TokensWithdraw(address where, address token, uint amount);
    event FundsWithdrawal(address where, uint amount);

    bool[] public yearlyTeamTokensPaid = [false, false, false];
    uint public yearlyTeamAmount= 0;
    bool public bountyPaid = false;
    uint public bountyAmount = 0;

    bool public crowdsaleClosed = false;
    uint public constant maxPurchaseNonWhiteListed = 10 * 1 ether;
    uint public preDGZtoDGZExchangeRate = 914285714;

    uint public discountValue5 = 50.0 * 1 ether;
    uint public discountValue10 = 100.0 * 1 ether;

    uint[] public price1stWeek = [ 5625000, 5343750, 5062500];
    uint[] public price2ndWeek = [ 5940000, 5643000, 5346000];
    uint[] public price3rdWeek = [ 6250000, 5937500, 5625000];

    
    function DogezerICOPublicCrowdSale(
        address addressOfPreDGZToken,
        address addressOfDGZToken,
        address addressOfBeneficiary
    ) public
    {
        beneficiary = addressOfBeneficiary;
        tokenRewardPreDGZ = StandardToken(addressOfPreDGZToken);
        tokenReward = StandardToken(addressOfDGZToken);
        tokensAvailableForSale = totalTokensAvailableForSale - preDGZTokensSold * preDGZtoDGZExchangeRate / 100000000 - privateSalesTokensSold;
        tokensSoldOnPublicRound = 0;
    }
    
    
    modifier onlyAfterStart() {
        require (now >= startTime);
        _;
    }

    modifier onlyBeforeEnd() {
        require (now < stopTime);
        _;
    }


    /**
     * @notice Main Payable function.
     * @dev In case if purchaser purchases on more than 10 ETH - only send tokens back if a person passed KYC (whitelisted) 
     * in other case - funds are being frozen until whitelisting will be done. If price will change before 
     * whitelisting is done for person, person will receive tokens basing on the new price, not old price.
     */    
    function () payable stopInEmergency onlyAfterStart onlyBeforeEnd public
    {
        require (crowdsaleClosed == false);
        require (tokensAvailableForSale > tokensSoldOnPublicRound);
        require (msg.value > 500000000000000);

        if ((balanceOf[msg.sender] + msg.value) > maxPurchaseNonWhiteListed && whiteList[msg.sender] == false) 
        {
            
            // DGZ tokens are not being reserved for the purchasers who are not in a whitelist yet.
            nonWLBalanceOf[msg.sender] += msg.value;
        } 
        else 
        {
            sendTokens(msg.sender, msg.value); 
        }
    }


    /**     
     * @notice Add multiple addresses to white list to allow purchase for more than 10 ETH. Owned.
     * @dev Automatically send tokens to addresses being whitelisted if they have already send funds before
     * the call of this function. It is recommended to check that addreses being added are VALID and not smartcontracts
     * as problem somewhere in the middle of the loop may cause error which will make all gas to be lost.
     * @param _addresses address[] Pass a bunch of etherium addresses as 
     *        ["0xca35b7d915458ef540ade6068dfe2f44e8fa733c", "0x14723a09acff6d2a60dcdf7aa4aff308fddc160c"] to add to WhiteList
     */        
    function addListToWhiteList (address[] _addresses) public onlyOwner
    {
        for (uint i = 0; i < _addresses.length; i++)
        {
            if (nonWLBalanceOf[_addresses[i]] > 0)
            {
                sendTokens(_addresses[i], nonWLBalanceOf[_addresses[i]]);
                nonWLBalanceOf[_addresses[i]] = 0;
            }
            whiteList[_addresses[i]] = true;
        }
    }
    
    
    /**    
     * @notice Add a single address to white list to allow purchase for more than 10 ETH. Owned.
     * @param _address address An etherium addresses to add to WhiteList
     */    
    function addToWhiteList (address _address) public onlyOwner
    {
        if (nonWLBalanceOf[_address] > 0)
        {
            sendTokens(_address, nonWLBalanceOf[_address]);
            nonWLBalanceOf[_address] = 0;
        }
        whiteList[_address] = true;
    }    
    
    
    /**
     * @notice Finalize sales and sets bounty & yearly paid value. Owned.
     */        
    function finalizeSale () public onlyOwner
    {
        require (crowdsaleClosed == false);
        crowdsaleClosed = true;
        uint totalSold = tokensSoldOnPublicRound + preDGZTokensSold * preDGZtoDGZExchangeRate / 100000000 + privateSalesTokensSold;
        bountyAmount = totalSold / 980 * 15;
        yearlyTeamAmount= totalSold / 980 * 5 / 3;
    }
    

    /**
     * @notice A function to burn unsold DGZ tokens. The ammount would be a parameter, not calculated value to ensure that all of the 
     * last moment changes related to KYC processing, such as overdue of KYC documents or delay with confirming of KYC
     * documents which caused purchaser to receive tokens using next period price, are handled. Owned.
     * @param _amount uint Number of tokens to burn
     */        
    function tokenBurn (uint _amount) public onlyOwner
    {
        require (crowdsaleClosed == true);
        tokenReward.transfer(address(0), _amount);
    }


    /**
     * @notice A function to withdraw tokens for bounty campaign. Can be called only once. Owned.
     */            
    function bountyTokenWithdrawal () public onlyOwner
    {
        require (crowdsaleClosed == true);
        require (bountyPaid == false);

        tokenReward.transfer(beneficiary, bountyAmount);
        bountyPaid = true;
    }


    /**
     * @notice A function to withdraw team tokens. Allow to withdraw one third of founders share in each yearly
     * after the end of ICO. In total can be called at maximum 3 times. Owned.
     */        
    function yearlyOwnerTokenWithdrawal () public onlyOwner 
    {
        require (crowdsaleClosed == true);
        require (
            ((now > stopTime + 1 years) && (yearlyTeamTokensPaid[0] == false))
            || ((now > stopTime + 2 years) && (yearlyTeamTokensPaid[1] == false))
            || ((now > stopTime + 3 years) && (yearlyTeamTokensPaid[2] == false))
        );

        tokenReward.transfer(beneficiary, yearlyTeamAmount);

        if (yearlyTeamTokensPaid[0] == false)
            yearlyTeamTokensPaid[0] = true;
        else if (yearlyTeamTokensPaid[1] == false)
            yearlyTeamTokensPaid[1] = true;
        else if (yearlyTeamTokensPaid[2] == false)
            yearlyTeamTokensPaid[2] = true;
    }

    
    /**
     * @notice A method to exchange preDGZ tokens to DGZ tokens. To use that method, a person first
     * need to call approve method of preDGZ to define how many tokens to convert. Note that function
     * doesn't end with the rest of crowdsale - it may be possible to exchange preDGZ after the end of crowdsale
     * @dev Exchanged preDGZ tokens are automatically burned.
     */        
    function exchangePreDGZTokens() stopInEmergency onlyAfterStart public
    {
        uint tokenAmount = tokenRewardPreDGZ.allowance(msg.sender, this);
        require(tokenAmount > 0);
        require(tokenRewardPreDGZ.transferFrom(msg.sender, address(0), tokenAmount));
        uint amountSendTokens = tokenAmount * preDGZtoDGZExchangeRate  / 100000000;
        preBalanceOf[msg.sender] += tokenAmount;
        tokenReward.transfer(msg.sender, amountSendTokens);
    }
    
    
    /**
     * @notice This function is needed to handled unlikely case when person who owns preDGZ tokens
     * makes a mistake and send them to smartcontract without setting the allowance in advance. In such case
     * conversion of tokens by calling exchangePreDGZTokens is not possible. Ownable.
     * @dev IMPORTANT! Should only be called is Dogezer team is in possesion of preDGZ tokens. 
     * @dev Doesn't increment tokensSoldOnPublicRound as these tokens are already accounted as preDGZTokensSold
     * @param _address address Etherium address where to send tokens as a result of conversion.
     * @param preDGZAmount uint Number of preDGZ to convert.
     */        
    function manuallyExchangeContractPreDGZtoDGZ(address _address, uint preDGZAmount) public onlyOwner
    {
        require (_address != address(0));
        require (preDGZAmount > 0);

        uint amountSendTokens = preDGZAmount * preDGZtoDGZExchangeRate  / 100000000;
        preBalanceOf[_address] += preDGZAmount;
        tokenReward.transfer(_address, amountSendTokens);
    }


    /**
     * @notice Function to define prices for some particular week. Would be utilized if prices are changed. Owned.
     * @dev It is important to apply this function for all of three weeks. The final week should be a week which is active now
     * @param week uint Ordinal number of the week.
     * @param price uint DGZ token price.
     * @param price5 uint DGZ token price with 5% discount.
     * @param price10 uint DGZ token price with 10% discount.
     */        
    function setTokenPrice (uint week, uint price, uint price5, uint price10) public onlyOwner
    {
        require (crowdsaleClosed == false);
        require (week >= 1 && week <= 3);
        if (week == 1)
            price1stWeek = [price, price5, price10];
        else if (week == 2)
            price2ndWeek = [price, price5, price10];
        else if (week == 3)
            price3rdWeek = [price, price5, price10];
    }


    /**
     * @notice In case if prices are changed due to some great change in ETH price,
     * this function can be used to change conversion rate for preDGZ owners. Owned.
     * @param rate uint Conversion rate.
     */        
    function setPreDGZtoDgzRate (uint rate) public onlyOwner
    {
        preDGZtoDGZExchangeRate = rate;
        tokensAvailableForSale = totalTokensAvailableForSale - preDGZTokensSold * preDGZtoDGZExchangeRate / 100000000 - privateSalesTokensSold;
    }


    /**
     * @notice Set number of tokens sold on private round. Required to correctly calcualte 
     * total numbers of tokens sold at the end. Owned.
     * @param tokens uint Number of tokens sold on private sale.
     */            
    function setPrivateSaleTokensSold (uint tokens) public onlyOwner
    {
        privateSalesTokensSold = tokens;
        tokensAvailableForSale = totalTokensAvailableForSale - preDGZTokensSold * preDGZtoDGZExchangeRate / 100000000 - privateSalesTokensSold;
    }


    /**
     * @notice Internal function which is responsible for sending tokens. Note that 
     * discount is determined basing on accumulated sale, but only applied to the current
     * request to send tokens.
     * @param msg_sender address Address of PreDGZ holder who allowed it to exchange.
     * @param msg_value uint Number of DGZ tokens to send.
     */            
    function sendTokens(address msg_sender, uint msg_value) internal
    {
        var prices = price1stWeek;

        if (now >= startTime + 2 weeks)
            prices = price3rdWeek;
        else if (now >= startTime + 1 weeks)
            prices = price2ndWeek;


        uint currentPrice = prices[0];

        if (balanceOf[msg_sender] + msg_value >= discountValue5)
        {
            currentPrice = prices[1];
            if (balanceOf[msg_sender] + msg_value >= discountValue10)
                currentPrice = prices[2];
        }

        uint amountSendTokens = msg_value / currentPrice;

        if (amountSendTokens > (tokensAvailableForSale - tokensSoldOnPublicRound))
        {
            uint tokensAvailable = tokensAvailableForSale - tokensSoldOnPublicRound;
            uint refund = msg_value - (tokensAvailable * currentPrice);
            amountSendTokens = tokensAvailable;
            tokensSoldOnPublicRound += amountSendTokens;            
            msg_sender.transfer(refund);
            balanceOf[msg_sender] += (msg_value - refund);
        }
        else
        {
            tokensSoldOnPublicRound += amountSendTokens;            
            balanceOf[msg_sender] += msg_value;
        }

        tokenReward.transfer(msg_sender, amountSendTokens);
        DGZTokensSold(msg_sender, amountSendTokens);
    }


    /**
     * @notice Withdraw funds to beneficiary. Owned
     * @param _amount uint Amount funds to withdraw.
     */    
    function fundWithdrawal (uint _amount) public onlyOwner
    {
        require (crowdsaleClosed == true);
        beneficiary.transfer(_amount);
        FundsWithdrawal(beneficiary, _amount);
    }


    /**
     * @notice Function to process cases when person send more than 10 ETH to smartcontract
     * but never provided KYC data and wants/needs to be refunded. Owned
     * @param _address address Address of refunded person.
     */        
    function refundNonWhitelistedPerson (address _address) public onlyOwner
    {
        uint refundAmount = nonWLBalanceOf[_address];
        nonWLBalanceOf[_address] = 0;
        _address.transfer(refundAmount);
    }


    /**
     * @notice Withdraws DGZ tokens to beneficiary. Would be used to process BTC payments. Owned.
     * @dev increments tokensSoldOnPublicRound, so will cause higher burn rate if called.
     * @param _amount uint Amount of DGZ tokens to withdraw.
     */    
    function tokenWithdrawal (uint _amount) public onlyOwner
    {
        require (crowdsaleClosed == false);
        tokenReward.transfer(beneficiary, _amount);
        tokensSoldOnPublicRound += _amount;
        DGZTokensWithdraw(beneficiary, _amount);
    }


    /**
     * @notice Withdraws tokens other than DGZ to beneficiary. Owned
     * @dev Generally need this to handle cases when user just transfers preDGZ 
     * to the contract by mistake and we need to manually burn then after calling
     * manuallyExchangeContractPreDGZtoDGZ
     * @param _address address Address of tokens to withdraw.
     * @param _amount uint Amount of tokens to withdraw.
     */        
    function anyTokenWithdrawal (address _address, uint _amount) public onlyOwner
    {
        require(_address != address(tokenReward));

        StandardToken token = StandardToken(_address);
        token.transfer(beneficiary, _amount);
        TokensWithdraw(beneficiary, _address, _amount);
    }


    /**
     * @notice Changes beneficiary address. Owned.
     * @param _newBeneficiary address Address of new beneficiary.
     */        
    function changeBeneficiary(address _newBeneficiary) public onlyOwner
    {
        if (_newBeneficiary != address(0)) {
            beneficiary = _newBeneficiary;
        }
    }


    /**
     * @notice Reopens closed sale to recalcualte total tokens sold if there are any late deals - such as
     * delayed whitelist processing. Owned.
     */    
    function reopenSale () public onlyOwner
    {
        require (crowdsaleClosed == true);
        crowdsaleClosed = false;
    }
}