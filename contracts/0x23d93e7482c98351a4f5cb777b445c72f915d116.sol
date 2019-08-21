pragma solidity ^0.4.25;

contract Ownable {
    
    address public owner;

    /**
     * The address whcih deploys this contrcat is automatically assgined ownership.
     * */
    constructor() public {
        owner = msg.sender;
    }

    /**
     * Functions with this modifier can only be executed by the owner of the contract. 
     * */
    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    event OwnershipTransferred(address indexed from, address indexed to);

    /**
    * Transfers ownership to new Ethereum address. This function can only be called by the 
    * owner.
    * @param _newOwner the address to be granted ownership.
    **/
    function transferOwnership(address _newOwner) public onlyOwner {
        require(_newOwner != 0x0);
        emit OwnershipTransferred(owner, _newOwner);
        owner = _newOwner;
    }
}


/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {

  /**
  * @dev Multiplies two numbers, throws on overflow.
  */
  function mul(uint256 _a, uint256 _b) internal pure returns (uint256 c) {
    // Gas optimization: this is cheaper than asserting 'a' not being zero, but the
    // benefit is lost if 'b' is also tested.
    // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
    if (_a == 0) {
      return 0;
    }

    c = _a * _b;
    assert(c / _a == _b);
    return c;
  }

  /**
  * @dev Integer division of two numbers, truncating the quotient.
  */
  function div(uint256 _a, uint256 _b) internal pure returns (uint256) {
    // assert(_b > 0); // Solidity automatically throws when dividing by 0
    // uint256 c = _a / _b;
    // assert(_a == _b * c + _a % _b); // There is no case in which this doesn't hold
    return _a / _b;
  }

  /**
  * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
  */
  function sub(uint256 _a, uint256 _b) internal pure returns (uint256) {
    assert(_b <= _a);
    return _a - _b;
  }

  /**
  * @dev Adds two numbers, throws on overflow.
  */
  function add(uint256 _a, uint256 _b) internal pure returns (uint256 c) {
    c = _a + _b;
    assert(c >= _a);
    return c;
  }
}



contract ERC20Basic {
    uint256 public totalSupply;
    string public name;
    string public symbol;
    uint8 public decimals;
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


contract UsdPrice {
    function USD(uint _id) public constant returns (uint256);
}


contract ICO is Ownable {
    
    using SafeMath for uint256;
    
    UsdPrice public fiat;
    ERC20 public ELYC;
    
    uint256 private tokenPrice;
    uint256 private tokensSold;
    
    constructor() public {
        fiat = UsdPrice(0x8055d0504666e2B6942BeB8D6014c964658Ca591); 
        ELYC = ERC20(0xFD96F865707ec6e6C0d6AfCe1f6945162d510351); 
        tokenPrice = 8; //$0.08
        tokensSold = 0;
    }
    
    
    /**
     * EVENTS
     * */
    event PurchaseMade(address indexed by, uint256 tokensPurchased, uint256 tokenPricee);
    event WithdrawOfELYC(address recipient, uint256 tokensSent);
    event TokenPriceChanged(uint256 oldPrice, uint256 newPrice);
     
     

    /**
     * GETTERS
     * */  
     
    /**
     * @return The unit price of the ELYC token in ETH. 
     * */
    function getTokenPriceInETH() public view returns(uint256) {
        return fiat.USD(0).mul(tokenPrice);
    }
    
    
    /**
     * @return The unit price of ELYC in USD cents. 
     * */
    function getTokenPriceInUsdCents() public view returns(uint256) {
        return tokenPrice;
    }
    
    
    /**
     * @return The total amount of tokens which have been sold.
     * */
    function getTokensSold() public view returns(uint256) {
        return tokensSold;
    }
    
    
    /**
     * @return 1 ETH worth of ELYC tokens. 
     * */
    function getRate() public view returns(uint256) {
        uint256 e18 = 1e18;
        return e18.div(getTokenPriceInETH());
    }


    /**
     * Fallback function invokes the buyTokens() function when ETH is received to 
     * enable easy and automatic token distributions to investors.
     * */
    function() public payable {
        buyTokens(msg.sender);
    }
    
    
    /**
     * Allows investors to buy tokens. In most cases this function will be invoked 
     * internally by the fallback function, so no manual work is required from investors
     * (unless they want to purchase tokens for someone else).
     * @param _investor The address which will be receiving ELYC tokens 
     * @return true if the address is on the blacklist, false otherwise
     * */
    function buyTokens(address _investor) public payable returns(bool) {
        require(_investor != address(0) && msg.value > 0);
        ELYC.transfer(_investor, msg.value.mul(getRate()));
        tokensSold = tokensSold.add(msg.value.mul(getRate()));
        owner.transfer(msg.value);
        emit PurchaseMade(_investor, msg.value.mul(getRate()), getTokenPriceInETH());
        return true;
    }
    
    
    /**
     * ONLY OWNER FUNCTIONS
     * */
     
    /**
     * Allows the owner to withdraw any ERC20 token which may have been sent to this 
     * contract address by mistake. 
     * @param _addressOfToken The contract address of the ERC20 token
     * @param _recipient The receiver of the token. 
     * */
    function withdrawAnyERC20(address _addressOfToken, address _recipient) public onlyOwner {
        ERC20 token = ERC20(_addressOfToken);
        token.transfer(_recipient, token.balanceOf(address(this)));
    }
    

    /**
     * Allows the owner to withdraw any unsold ELYC tokens at any time during or 
     * after the ICO. Can also be used to process offchain payments such as from 
     * BTC, LTC or any other currency and can be used to pay partners and team 
     * members. 
     * @param _recipient The receiver of the token. 
     * @param _value The total amount of tokens to send 
     * */
    function withdrawELYC(address _recipient, uint256 _value) public onlyOwner {
        require(_recipient != address(0));
        ELYC.transfer(_recipient, _value);
        emit WithdrawOfELYC(_recipient, _value);
    }
    
    
    /**
     * Allows the owner to change the price of the token in USD cents anytime during 
     * the ICO. 
     * @param _newTokenPrice The price in cents. For example the value 1 would mean 
     * $0.01
     * */
    function changeTokenPriceInCent(uint256 _newTokenPrice) public onlyOwner {
        require(_newTokenPrice != tokenPrice && _newTokenPrice > 0);
        emit TokenPriceChanged(tokenPrice, _newTokenPrice);
        tokenPrice = _newTokenPrice;
    }
    
    
    /**
     * Allows the owner to kill the ICO contract. This function call is irreversible
     * and cannot be invoked until there are no remaining ELYC tokens stored on the 
     * ICO contract address. 
     * */
    function terminateICO() public onlyOwner {
        require(ELYC.balanceOf(address(this)) == 0);
        selfdestruct(owner);
    }
}