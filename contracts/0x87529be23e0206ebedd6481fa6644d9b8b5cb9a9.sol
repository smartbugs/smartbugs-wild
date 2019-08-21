pragma solidity ^0.4.25;


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


contract UsdPrice {
    function USD(uint _id) public constant returns (uint256);
}


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

contract ERC20Basic {
    uint256 public totalSupply;
    string public name;
    string public symbol;
    uint8 public decimals;
    function balanceOf(address who) constant public returns (uint256);
    function transfer(address to, uint256 value) public returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
}

contract BasicToken is ERC20Basic {
    
    using SafeMath for uint256;
    
    mapping (address => uint256) internal balances;
    
    /**
    * Returns the balance of the qeuried address
    *
    * @param _who The address which is being qeuried
    **/
    function balanceOf(address _who) public view returns(uint256) {
        return balances[_who];
    }
    
    /**
    * Allows for the transfer of MSTCOIN tokens from peer to peer. 
    *
    * @param _to The address of the receiver
    * @param _value The amount of tokens to send
    **/
    function transfer(address _to, uint256 _value) public returns(bool) {
        require(balances[msg.sender] >= _value && _value > 0 && _to != 0x0);
        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);
        emit Transfer(msg.sender, _to, _value);
        return true;
    }
}


contract ERC20 is ERC20Basic {
    function allowance(address owner, address spender) constant public returns (uint256);
    function transferFrom(address from, address to, uint256 value) public  returns (bool);
    function approve(address spender, uint256 value) public returns (bool);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}


contract StandardToken is BasicToken, ERC20, Ownable {
    
    address public MembershipContractAddr = 0x0;
    
    mapping (address => mapping (address => uint256)) internal allowances;
    
    function changeMembershipContractAddr(address _newAddr) public onlyOwner returns(bool) {
        require(_newAddr != address(0));
        MembershipContractAddr = _newAddr;
    }
    
    /**
    * Returns the amount of tokens one has allowed another to spend on his or her behalf.
    *
    * @param _owner The address which is the owner of the tokens
    * @param _spender The address which has been allowed to spend tokens on the owner's
    * behalf
    **/
    function allowance(address _owner, address _spender) public view returns (uint256) {
        return allowances[_owner][_spender];
    }
    
    event TransferFrom(address msgSender);
    /**
    * Allows for the transfer of tokens on the behalf of the owner given that the owner has
    * allowed it previously. 
    *
    * @param _from The address of the owner
    * @param _to The address of the recipient 
    * @param _value The amount of tokens to be sent
    **/
    function transferFrom(address _from, address _to, uint256 _value) public  returns (bool) {
        require(allowances[_from][msg.sender] >= _value || msg.sender == MembershipContractAddr);
        require(balances[_from] >= _value && _value > 0 && _to != address(0));
        emit TransferFrom(msg.sender);
        balances[_from] = balances[_from].sub(_value);
        balances[_to] = balances[_to].add(_value);
        if(msg.sender != MembershipContractAddr) {
            allowances[_from][msg.sender] = allowances[_from][msg.sender].sub(_value);
        }
        emit Transfer(_from, _to, _value);
        return true;
    }
    
    /**
    * Allows the owner of tokens to approve another to spend tokens on his or her behalf
    *
    * @param _spender The address which is being allowed to spend tokens on the owner' behalf
    * @param _value The amount of tokens to be sent
    **/
    function approve(address _spender, uint256 _value) public returns (bool) {
        require(_spender != 0x0 && _value > 0);
        if(allowances[msg.sender][_spender] > 0 ) {
            allowances[msg.sender][_spender] = 0;
        }
        allowances[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }
}

contract BurnableToken is StandardToken {
    
    address public ICOaddr;
    address public privateSaleAddr;
    
    constructor() public {
        ICOaddr = 0x0;
        privateSaleAddr = 0x0;
    }
    
    event TokensBurned(address indexed burner, uint256 value);
    
    function burnFrom(address _from, uint256 _tokens) public onlyOwner {
        require(ICOaddr == _from || privateSaleAddr == _from);
        if(balances[_from] < _tokens) {
            emit TokensBurned(_from,balances[_from]);
            emit Transfer(_from, address(0), balances[_from]);
            balances[_from] = 0;
            totalSupply = totalSupply.sub(balances[_from]);
        } else {
            balances[_from] = balances[_from].sub(_tokens);
            totalSupply = totalSupply.sub(_tokens);
            emit TokensBurned(_from, _tokens);
            emit Transfer(_from, address(0), _tokens);
        }
    }
}


contract AIB is BurnableToken {
    
    constructor() public {
        name = "AI Bank";
        symbol = "AIB";
        decimals = 18;
        totalSupply = 856750000e18;
        balances[owner] = totalSupply;
        emit Transfer(address(this), owner, totalSupply);
    }
}


contract PrivateSale is Ownable {
    
    using SafeMath for uint256;
    
    event PurchaseMade(address indexed by, uint256 tokensPurchased, uint256 tokenPricee);
    event TokenPriceChanged(uint256 oldPrice, uint256 newPrice);
    event BonusChanged(uint256 oldBonus, uint256 newBonus);
    
    UsdPrice public fiat;
    AIB public AIBToken;
    
    uint256 public tokenPrice;
    uint256 public bonus;
    uint256 public deadline;
    
    constructor() public {
        fiat = UsdPrice(0x8055d0504666e2B6942BeB8D6014c964658Ca591);
        tokenPrice = 5;
        bonus = 35;
        deadline = 0;
    }
    
    function startSale() public onlyOwner {
        deadline = now.add(120 days);
    }
    
    /**
     * Allows the owner of the contract to change the bonus
     * 
     * @param _newBonus The new bonus value
     * */
    function setBonus(uint256 _newBonus) public onlyOwner {
        require(_newBonus != bonus && _newBonus > 0);
        emit BonusChanged(bonus, _newBonus);
        bonus = _newBonus;
    }
    
    
    /**
     * Allows the owner of the contract to change the token price
     * 
     * @param _newPrice The new price value
     */
    function setTokenPrice(uint256 _newPrice) public onlyOwner {
        require(_newPrice != tokenPrice && _newPrice > 0);
        emit TokenPriceChanged(tokenPrice, _newPrice);
        tokenPrice = _newPrice;
    }
    
    
    /**
     * Allows the owner of the contract to set the token address
     * 
     * @param _addr The token contract address
     * */
    function setAIBTokenAddress(address _addr) public onlyOwner {
        require(_addr != address(0));
        AIBToken = AIB(_addr);
    }
    
    
    /**
     * @return The unit price of the AIB token in ETH. 
     * */
    function getTokenPriceInETH() public view returns(uint256) {
        return fiat.USD(0).mul(tokenPrice);
    }
    
    /**
     * @return 1 ETH worth of AIB tokens. 
     * */
    function getRate() public view returns(uint256) {
        uint256 e18 = 1e18;
        return e18.div(getTokenPriceInETH());
    }
    
    /**
     * @return The current price of the token with the bonus
     * */
    function addBonus(uint256 _tokens) internal view returns(uint256) {
        return (_tokens.add((_tokens.mul(bonus)).div(100)));
    }
    
    
    /**
     * Allows investors to buy tokens
     * 
     * @param _addr The address of the investor 
     * */
    function buyTokens(address _addr) public payable returns(bool){
        require(_addr != address(0) && msg.value > 0);
        require(now <= deadline);
        uint256 toTransfer = addBonus(msg.value.mul(getRate()));
        AIBToken.transfer(_addr, toTransfer);
        emit PurchaseMade(_addr, toTransfer, msg.value);
        owner.transfer(msg.value);
        return true;
    }
    
    
    function() public payable {
        buyTokens(msg.sender);
    }
    
    
    /**
     * Allows the owner of the contract to withdraw AIB tokens 
     * 
     * @param _to The recipient address 
     * @param _value The total amount of tokens to send
     * */
    function withdrawTokens(address _to, uint256 _value) public onlyOwner {
        require(_to != address(0) && _value > 0);
        AIBToken.transfer(_to, _value);
    }
    
}