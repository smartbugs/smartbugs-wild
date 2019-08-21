pragma solidity ^0.4.24;

//
//                       .#########'
//                    .###############+
//                  ,####################
//                `#######################+
//               ;##########################
//              #############################.
//             ###############################,
//           +##################,    ###########`
//          .###################     .###########
//         ##############,          .###########+
//         #############`            .############`
//         ###########+                ############
//        ###########;                  ###########
//        ##########'                    ###########                                                                                      
//       '##########    '#.        `,     ##########                                                                                    
//       ##########    ####'      ####.   :#########;                                                                                   
//      `#########'   :#####;    ######    ##########                                                                                 
//      :#########    #######:  #######    :#########         
//      +#########    :#######.########     #########`       
//      #########;     ###############'     #########:       
//      #########       #############+      '########'        
//      #########        ############       :#########        
//      #########         ##########        ,#########        
//      #########         :########         ,#########        
//      #########        ,##########        ,#########        
//      #########       ,############       :########+        
//      #########      .#############+      '########'        
//      #########:    `###############'     #########,        
//      +########+    ;#######`;#######     #########         
//      ,#########    '######`  '######    :#########         
//       #########;   .#####`    '#####    ##########         
//       ##########    '###`      +###    :#########:         
//       ;#########+     `                ##########          
//        ##########,                    ###########          
//         ###########;                ############
//         +############             .############`
//          ###########+           ,#############;
//          `###########     ;++#################
//           :##########,    ###################
//            '###########.'###################
//             +##############################
//              '############################`
//               .##########################
//                 #######################:
//                   ###################+
//                     +##############:
//                        :#######+`
//
//
//
// Play0x.com (The ONLY gaming platform for all ERC20 Tokens)
// -------------------------------------------------------------------------------------------------------
// * Multiple types of game platforms
// * Build your own game zone - Not only playing games, but also allowing other players to join your game.
// * Support all ERC20 tokens.
//
//
//
// 0xC Token (Contract address : 0x2a43a3cf6867b74566e657dbd5f0858ad0f77d66)
// -------------------------------------------------------------------------------------------------------
// * 0xC Token is an ERC20 Token specifically for digital entertainment.
// * No ICO and private sales,fair access.
// * There will be hundreds of games using 0xC as a game token.
// * Token holders can permanently get ETH's profit sharing.
//


/**
* @title SafeMath
* @dev Math operations with safety checks that throw on error
*/
library SafeMath {
/**
     * @dev Multiplies two unsigned integers, reverts on overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b);

        return c;
    }

    /**
     * @dev Integer division of two unsigned integers truncating the quotient, reverts on division by zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0);
        uint256 c = a / b;
        assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Subtracts two unsigned integers, reverts on overflow (i.e. if subtrahend is greater than minuend).
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a);
        uint256 c = a - b;

        return c;
    }

    /**
     * @dev Adds two unsigned integers, reverts on overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a);

        return c;
    }

    /**
     * @dev Divides two unsigned integers and returns the remainder (unsigned integer modulo),
     * reverts when dividing by zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0);
        return a % b;
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
    constructor() public {
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
        if (newOwner != address(0)) {
            owner = newOwner;
        }
    }
}



/**
* @title Standard ERC20 token
*
* @dev Implementation of the basic standard token.
* @dev https://github.com/ethereum/EIPs/issues/20
* @dev Based on code by FirstBlood: https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol
*/
contract StandardToken {

    mapping (address => mapping (address => uint256)) internal allowed;
    using SafeMath for uint256;
    uint256 public totalSupply;
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    mapping(address => uint256) balances;
    
    /**
    * @dev transfer token for a specified address
    * @param _to The address to transfer to.
    * @param _value The amount to be transferred.
    */
    function transfer(address _to, uint256 _value) public returns (bool) {
        require(_to != address(0));
        require(_value <= balances[msg.sender]);
        require(balances[msg.sender] >= _value && balances[_to].add(_value) >= balances[_to]);

    
        // SafeMath.sub will throw if there is not enough balance.
        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);
        emit Transfer(msg.sender, _to, _value);
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
    
    /**
    * @dev Transfer tokens from one address to another
    * @param _from address The address which you want to send tokens from
    * @param _to address The address which you want to transfer to
    * @param _value uint256 the amout of tokens to be transfered
    */
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
    // Check is not needed because sub(_allowance, _value) will already throw if this condition is not met
    // require (_value <= _allowance);

        require(_to != address(0));
        require(_value <= balances[_from]);
        require(_value <= allowed[_from][msg.sender]);
    
        balances[_from] = balances[_from].sub(_value);
        balances[_to] = balances[_to].add(_value);
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
        emit Transfer(_from, _to, _value);
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
        emit Approval(msg.sender, _spender, _value);
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

/*Token  Contract*/
contract Token0xC is StandardToken, Ownable {
    using SafeMath for uint256;

    // Token Information
    string  public constant name = "0xC";
    string  public constant symbol = "0xC";
    uint8   public constant decimals = 18;

    // Sale period1.
    uint256 public startDate1;
    uint256 public endDate1;
    uint256 public rate1;
    
    // Sale period2.
    uint256 public startDate2;
    uint256 public endDate2;
    uint256 public rate2;
    
    // Sale period3. 
    uint256 public startDate3;
    uint256 public endDate3;
    uint256 public rate3;

    //2018 08 16
    uint256 BaseTimestamp = 1534377600;
    
    //SaleCap
    uint256 public dailyCap;
    uint256 public saleCap;
    uint256 public LastbetDay;
    uint256 public LeftDailyCap;
    uint256 public BuyEtherLimit = 500000000000000000; //0.5 ether

    // Address Where Token are keep
    address public tokenWallet ;

    // Address where funds are collected.
    address public fundWallet ;

    // Event
    event TokenPurchase(address indexed purchaser, uint256 value, uint256 amount);
    event TransferToken(address indexed buyer, uint256 amount);

    // Modifiers
    modifier uninitialized() {
        require(tokenWallet == 0x0);
        require(fundWallet == 0x0);
        _;
    }

    constructor() public {}
    // Trigger with Transfer event
    // Fallback function can be used to buy tokens
    function () public payable {
        buyTokens(msg.sender, msg.value);
    }

    //Initial Contract
    function initialize(address _tokenWallet, address _fundWallet, uint256 _start1, uint256 _end1,
                         uint256 _dailyCap, uint256 _saleCap, uint256 _totalSupply) public
                        onlyOwner uninitialized {
        require(_start1 < _end1);
        require(_tokenWallet != 0x0);
        require(_fundWallet != 0x0);
        require(_totalSupply >= _saleCap);

        startDate1 = _start1;
        endDate1 = _end1;
        saleCap = _saleCap;
        dailyCap = _dailyCap;
        tokenWallet = _tokenWallet;
        fundWallet = _fundWallet;
        totalSupply = _totalSupply;

        balances[tokenWallet] = saleCap;
        balances[0xb1] = _totalSupply.sub(saleCap);
    }

    //Set Sale Period
    function setPeriod(uint256 period, uint256 _start, uint256 _end) public onlyOwner {
        require(_end > _start);
        if (period == 1) {
            startDate1 = _start;
            endDate1 = _end;
        }else if (period == 2) {
            require(_start > endDate1);
            startDate2 = _start;
            endDate2 = _end;
        }else if (period == 3) {
            require(_start > endDate2);
            startDate3 = _start;
            endDate3 = _end;      
        }
    }

    //Set Sale Period
    function setPeriodRate(uint256 _period, uint256 _rate) public onlyOwner {
        if (_period == 1) {
           rate1 = _rate;
        }else if (_period == 2) {
            rate2 = _rate;
        }else if (_period == 3) {
            rate3 = _rate;
        }
    }

    // For transferToken
    function transferToken(address _to, uint256 amount) public onlyOwner {
        require(saleCap >= amount,' Not Enough' );
        require(_to != address(0));
        require(_to != tokenWallet);
        require(amount <= balances[tokenWallet]);

        saleCap = saleCap.sub(amount);
        // Transfer
        balances[tokenWallet] = balances[tokenWallet].sub(amount);
        balances[_to] = balances[_to].add(amount);
        emit TransferToken(_to, amount);
        emit Transfer(tokenWallet, _to, amount);
    }

    function setDailyCap(uint256 _dailyCap) public onlyOwner{
        dailyCap = _dailyCap;
    }
    
    function setBuyLimit(uint256 _BuyEtherLimit) public onlyOwner{
        BuyEtherLimit = _BuyEtherLimit;
    }

    //Set SaleCap
    function setSaleCap(uint256 _saleCap) public onlyOwner {
        require(balances[0xb1].add(balances[tokenWallet]).sub(_saleCap) >= 0);
        uint256 amount = 0;
        //Check SaleCap
        if (balances[tokenWallet] > _saleCap) {
            amount = balances[tokenWallet].sub(_saleCap);
            balances[0xb1] = balances[0xb1].add(amount);
        } else {
            amount = _saleCap.sub(balances[tokenWallet]);
            balances[0xb1] = balances[0xb1].sub(amount);
        }
        balances[tokenWallet] = _saleCap;
        saleCap = _saleCap;
    }

    //Calcute Bouns
    function getBonusByTime() public constant returns (uint256) {
        if (now < startDate1) {
            return 0;
        } else if (endDate1 > now && now > startDate1) {
            return rate1;
        } else if (endDate2 > now && now > startDate2) {
            return rate2;
        } else if (endDate3 > now && now > startDate3) {
            return rate3;
        } else {
            return 0;
        }
    }

    //Stop Contract
    function finalize() public onlyOwner {
        require(!saleActive());

        // Transfer the rest of token to tokenWallet
        balances[tokenWallet] = balances[tokenWallet].add(balances[0xb1]);
        balances[0xb1] = 0;
    }
    
    //Purge the time in the timestamp.
    function DateConverter(uint256 ts) public view returns(uint256 currentDayWithoutTime){
        uint256 dayInterval = ts.sub(BaseTimestamp);
        uint256 dayCount = dayInterval.div(86400);
        return BaseTimestamp.add(dayCount.mul(86400));
    }
    
    //Check SaleActive
    function saleActive() public constant returns (bool) {
        return (
            (now >= startDate1 &&
                now < endDate1 && saleCap > 0) ||
            (now >= startDate2 &&
                now < endDate2 && saleCap > 0) ||
            (now >= startDate3 &&
                now < endDate3 && saleCap > 0)
                );
    }
    
    //Buy Token
    function buyTokens(address sender, uint256 value) internal {
        //Check Sale Status
        require(saleActive());
        
        //Minum buying limit
        require(value >= BuyEtherLimit,"value no enough" );
        require(sender != tokenWallet);
        
        if(DateConverter(now) > LastbetDay )
        {
            LastbetDay = DateConverter(now);
            LeftDailyCap = dailyCap;
        }

        // Calculate token amount to be purchased
        uint256 bonus = getBonusByTime();
        
        uint256 amount = value.mul(bonus);
        
        // We have enough token to sale
        require(LeftDailyCap >= amount, "cap not enough");
        require(balances[tokenWallet] >= amount);
        
        LeftDailyCap = LeftDailyCap.sub(amount);

        // Transfer
        balances[tokenWallet] = balances[tokenWallet].sub(amount);
        balances[sender] = balances[sender].add(amount);
        emit TokenPurchase(sender, value, amount);
        emit Transfer(tokenWallet, sender, amount);
        
        saleCap = saleCap.sub(amount);

        // Forward the fund to fund collection wallet.
        fundWallet.transfer(msg.value);
    }
}