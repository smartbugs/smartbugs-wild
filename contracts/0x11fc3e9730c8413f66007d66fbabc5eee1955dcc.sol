pragma solidity ^0.4.13;

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
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {
  function mul(uint256 a, uint256 b) internal constant returns (uint256) {
    uint256 c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal constant returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  function sub(uint256 a, uint256 b) internal constant returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal constant returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
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
  function balanceOf(address _owner) public constant returns (uint256 balance) {
    return balances[_owner];
  }

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
 * @title Standard ERC20 token
 *
 * @dev Implementation of the basic standard token.
 * @dev https://github.com/ethereum/EIPs/issues/20
 * @dev Based on code by FirstBlood: https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol
 */
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
  function allowance(address _owner, address _spender) public constant returns (uint256 remaining) {
    return allowed[_owner][_spender];
  }

  /**
   * approve should be called when allowed[_spender] == 0. To increment
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   */
  function increaseApproval (address _spender, uint _addedValue) public returns (bool success) {
    allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
    Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

  function decreaseApproval (address _spender, uint _subtractedValue) public returns (bool success) {
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

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
  address public owner;


  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  function Ownable() {
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
  function transferOwnership(address newOwner) onlyOwner public {
    require(newOwner != address(0));
    OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }

}

/////////////////////////////////////////////////////////
//////////////// Token contract start////////////////////
/////////////////////////////////////////////////////////

contract CryptoGripInitiative is StandardToken, Ownable {
    string  public  constant name = "Crypto Grip Initiative";

    string  public  constant symbol = "CGI";

    uint    public  constant decimals = 18;

    uint    public  saleStartTime;

    uint    public  saleEndTime;

    address public  tokenSaleContract;

    modifier onlyWhenTransferEnabled() {
        if (now <= saleEndTime && now >= saleStartTime) {
            require(msg.sender == tokenSaleContract || msg.sender == owner);
        }
        _;
    }

    modifier validDestination(address to) {
        require(to != address(0x0));
        require(to != address(this));
        _;
    }

    function CryptoGripInitiative(uint tokenTotalAmount, uint startTime, uint endTime, address admin) {
        // Mint all tokens. Then disable minting forever.
        balances[msg.sender] = tokenTotalAmount;
        totalSupply = tokenTotalAmount;
        Transfer(address(0x0), msg.sender, tokenTotalAmount);

        saleStartTime = startTime;
        saleEndTime = endTime;

        tokenSaleContract = msg.sender;
        transferOwnership(admin);
        // admin could drain tokens that were sent here by mistake
    }

    function transfer(address _to, uint _value)
    onlyWhenTransferEnabled
    validDestination(_to)
    returns (bool) {
        return super.transfer(_to, _value);
    }

    function transferFrom(address _from, address _to, uint _value)
    onlyWhenTransferEnabled
    validDestination(_to)
    returns (bool) {
        return super.transferFrom(_from, _to, _value);
    }

    event Burn(address indexed _burner, uint _value);

    function burn(uint _value) onlyWhenTransferEnabled
    returns (bool){
        balances[msg.sender] = balances[msg.sender].sub(_value);
        totalSupply = totalSupply.sub(_value);
        Burn(msg.sender, _value);
        Transfer(msg.sender, address(0x0), _value);
        return true;
    }

    //    // save some gas by making only one contract call
    //    function burnFrom(address _from, uint256 _value) onlyWhenTransferEnabled
    //    returns (bool) {
    //        assert(transferFrom(_from, msg.sender, _value));
    //        return burn(_value);
    //    }

    function emergencyERC20Drain(ERC20 token, uint amount) onlyOwner {
        token.transfer(owner, amount);
    }
}


/////////////////////////////////////////////////////////
/////////////// Whitelist contract start/////////////////
/////////////////////////////////////////////////////////


contract Whitelist {
    address public owner;

    address public sale;

    mapping (address => uint) public accepted;

    function Whitelist(address _owner, address _sale) {
        owner = _owner;
        sale = _sale;
    }

    function accept(address a, uint amountInWei) {
        assert(msg.sender == owner || msg.sender == sale);

        accepted[a] = amountInWei * 10 ** 18;
    }

    function setSale(address sale_) {
        assert(msg.sender == owner);

        sale = sale_;
    }

    function getCap(address _user) constant returns (uint) {
        uint cap = accepted[_user];
        return cap;
    }
}


/////////////////////////////////////////////////////////
///////// Contributor Approver contract start////////////
/////////////////////////////////////////////////////////

contract ContributorApprover {
    Whitelist public list;

    mapping (address => uint)    public participated;

    uint public presaleStartTime;

    uint public remainingPresaleCap;

    uint public remainingPublicSaleCap;

    uint                      public openSaleStartTime;

    uint                      public openSaleEndTime;

    using SafeMath for uint;


    function ContributorApprover(
    Whitelist _whitelistContract,
    uint preIcoCap,
    uint IcoCap,
    uint _presaleStartTime,
    uint _openSaleStartTime,
    uint _openSaleEndTime) {
        list = _whitelistContract;
        openSaleStartTime = _openSaleStartTime;
        openSaleEndTime = _openSaleEndTime;
        presaleStartTime = _presaleStartTime;
        remainingPresaleCap = preIcoCap * 10 ** 18;
        remainingPublicSaleCap = IcoCap * 10 ** 18;

        //    Check that presale is earlier than opensale
        require(presaleStartTime < openSaleStartTime);
        //    Check that open sale start is earlier than end
        require(openSaleStartTime < openSaleEndTime);
    }

    // this is a seperate function so user could query it before crowdsale starts
    function contributorCap(address contributor) constant returns (uint) {
        return list.getCap(contributor);
    }

    function eligible(address contributor, uint amountInWei) constant returns (uint) {
        //        Presale not started yet
        if (now < presaleStartTime) return 0;
        //    Both presale and public sale have ended
        if (now >= openSaleEndTime) return 0;

        //        Presale
        if (now < openSaleStartTime) {
            //        Presale cap limit reached
            if (remainingPresaleCap <= 0) {
                return 0;
            }
            //            Get initial cap
            uint cap = contributorCap(contributor);
            // Account for already invested amount
            uint remainedCap = cap.sub(participated[contributor]);
            //        Presale cap almost reached
            if (remainedCap > remainingPresaleCap) {
                remainedCap = remainingPresaleCap;
            }
            //            Remaining cap is bigger than contribution
            if (remainedCap > amountInWei) return amountInWei;
            //            Remaining cap is smaller than contribution
            else return remainedCap;
        }
        //        Public sale
        else {
            //           Public sale  cap limit reached
            if (remainingPublicSaleCap <= 0) {
                return 0;
            }
            //            Public sale cap almost reached
            if (amountInWei > remainingPublicSaleCap) {
                return remainingPublicSaleCap;
            }
            //            Public sale cap is bigger than contribution
            else {
                return amountInWei;
            }
        }
    }

    function eligibleTestAndIncrement(address contributor, uint amountInWei) internal returns (uint) {
        uint result = eligible(contributor, amountInWei);
        participated[contributor] = participated[contributor].add(result);
        //    Presale
        if (now < openSaleStartTime) {
            //        Decrement presale cap
            remainingPresaleCap = remainingPresaleCap.sub(result);
        }
        //        Publicsale
        else {
            //        Decrement publicsale cap
            remainingPublicSaleCap = remainingPublicSaleCap.sub(result);
        }

        return result;
    }

    function saleEnded() constant returns (bool) {
        return now > openSaleEndTime;
    }

    function saleStarted() constant returns (bool) {
        return now >= presaleStartTime;
    }

    function publicSaleStarted() constant returns (bool) {
        return now >= openSaleStartTime;
    }
}


/////////////////////////////////////////////////////////
///////// Token Sale contract start /////////////////////
/////////////////////////////////////////////////////////

contract CryptoGripTokenSale is ContributorApprover {
    uint    public  constant tokensPerEthPresale = 1055;

    uint    public  constant tokensPerEthPublicSale = 755;

    address             public admin;

    address             public gripWallet;

    CryptoGripInitiative public token;

    uint                public raisedWei;

    bool                public haltSale;

    function CryptoGripTokenSale(address _admin,
    address _gripWallet,
    Whitelist _whiteListContract,
    uint _totalTokenSupply,
    uint _premintedTokenSupply,
    uint _presaleStartTime,
    uint _publicSaleStartTime,
    uint _publicSaleEndTime,
    uint _presaleCap,
    uint _publicSaleCap)

    ContributorApprover(_whiteListContract,
    _presaleCap,
    _publicSaleCap,
    _presaleStartTime,
    _publicSaleStartTime,
    _publicSaleEndTime)
    {
        admin = _admin;
        gripWallet = _gripWallet;

        token = new CryptoGripInitiative(_totalTokenSupply * 10 ** 18, _presaleStartTime, _publicSaleEndTime, _admin);

        // transfer preminted tokens to company wallet
        token.transfer(gripWallet, _premintedTokenSupply * 10 ** 18);
    }

    function setHaltSale(bool halt) {
        require(msg.sender == admin);
        haltSale = halt;
    }

    function() payable {
        buy(msg.sender);
    }

    event Buy(address _buyer, uint _tokens, uint _payedWei);

    function buy(address recipient) payable returns (uint){
        require(tx.gasprice <= 50000000000 wei);

        require(!haltSale);
        require(saleStarted());
        require(!saleEnded());

        uint weiPayment = eligibleTestAndIncrement(recipient, msg.value);

        require(weiPayment > 0);

        // send to msg.sender, not to recipient
        if (msg.value > weiPayment) {
            msg.sender.transfer(msg.value.sub(weiPayment));
        }

        // send payment to wallet
        sendETHToMultiSig(weiPayment);
        raisedWei = raisedWei.add(weiPayment);

        uint recievedTokens = 0;

        if (now < openSaleStartTime) {
            recievedTokens = weiPayment.mul(tokensPerEthPresale);
        }
        else {
            recievedTokens = weiPayment.mul(tokensPerEthPublicSale);
        }

        assert(token.transfer(recipient, recievedTokens));


        Buy(recipient, recievedTokens, weiPayment);

        return weiPayment;
    }

    function sendETHToMultiSig(uint value) internal {
        gripWallet.transfer(value);
    }

    event FinalizeSale();
    // function is callable by everyone
    function finalizeSale() {
        require(saleEnded());
        require(msg.sender == admin);

        // burn remaining tokens
        token.burn(token.balanceOf(this));

        FinalizeSale();
    }

    // ETH balance is always expected to be 0.
    // but in case something went wrong, we use this function to extract the eth.
    function emergencyDrain(ERC20 anyToken) returns (bool){
        require(msg.sender == admin);
        require(saleEnded());

        if (this.balance > 0) {
            sendETHToMultiSig(this.balance);
        }

        if (anyToken != address(0x0)) {
            assert(anyToken.transfer(gripWallet, anyToken.balanceOf(this)));
        }

        return true;
    }

    // just to check that funds goes to the right place
    // tokens are not given in return
    function debugBuy() payable {
        require(msg.value == 123);
        sendETHToMultiSig(msg.value);
    }
}