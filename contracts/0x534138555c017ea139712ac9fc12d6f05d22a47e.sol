pragma solidity 0.4.25;

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
  address public owner;
  address public coinvest;
  mapping (address => bool) public admins;

  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  constructor() public {
    owner = msg.sender;
    coinvest = msg.sender;
    admins[owner] = true;
    admins[coinvest] = true;
  }

  /**
   * @dev Throws if called by any account other than the owner.
   */
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

  modifier coinvestOrOwner() {
      require(msg.sender == coinvest || msg.sender == owner);
      _;
  }

  modifier onlyAdmin() {
      require(admins[msg.sender]);
      _;
  }

  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param newOwner The address to transfer ownership to.
   */
  function transferOwnership(address newOwner) onlyOwner public {
    require(newOwner != address(0));
    emit OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }
  
  /**
   * @dev Changes the Coinvest wallet that will receive funds from investment contract.
   * @param _newCoinvest The address of the new wallet.
  **/
  function transferCoinvest(address _newCoinvest) 
    external
    onlyOwner
  {
    require(_newCoinvest != address(0));
    coinvest = _newCoinvest;
  }

  /**
   * @dev Used to add admins who are allowed to add funds to the investment contract and change gas price.
   * @param _user The address of the admin to add or remove.
   * @param _status True to add the user, False to remove the user.
  **/
  function alterAdmin(address _user, bool _status)
    external
    onlyOwner
  {
    require(_user != address(0));
    require(_user != coinvest);
    admins[_user] = _status;
  }

}

contract ERC20Interface {

    function totalSupply() public constant returns (uint);
    function balanceOf(address tokenOwner) public constant returns (uint balance);
    function allowance(address tokenOwner, address spender) public constant returns (uint remaining);
    function transfer(address to, uint tokens) public returns (bool success);
    function approve(address spender, uint tokens) public returns (bool success);
    function transferFrom(address from, address to, uint tokens) public returns (bool success);

    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);

}

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMathLib{
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

contract UserData is Ownable {
    using SafeMathLib for uint256;

    // Contract that is allowed to modify user holdings (investment.sol).
    address public investmentAddress;
    
    // Address => crypto Id => amount of crypto wei held
    mapping (address => mapping (uint256 => uint256)) public userHoldings;

    /**
     * @param _investmentAddress Beginning address of the investment contract that may modify holdings.
    **/
    constructor(address _investmentAddress) 
      public
    {
        investmentAddress = _investmentAddress;
    }
    
    /**
     * @dev Investment contract has permission to modify user's holdings on a buy or sell.
     * @param _beneficiary The user who is buying or selling tokens.
     * @param _cryptoIds The IDs of the cryptos being bought and sold.
     * @param _amounts The amount of each crypto being bought and sold.
     * @param _buy True if the purchase is a buy, false if it is a sell.
    **/
    function modifyHoldings(address _beneficiary, uint256[] _cryptoIds, uint256[] _amounts, bool _buy)
      external
    {
        require(msg.sender == investmentAddress);
        require(_cryptoIds.length == _amounts.length);
        
        for (uint256 i = 0; i < _cryptoIds.length; i++) {
            if (_buy) {
                userHoldings[_beneficiary][_cryptoIds[i]] = userHoldings[_beneficiary][_cryptoIds[i]].add(_amounts[i]);
            } else {
                userHoldings[_beneficiary][_cryptoIds[i]] = userHoldings[_beneficiary][_cryptoIds[i]].sub(_amounts[i]);
            }
        }
    }

/** ************************** Constants *********************************** **/
    
    /**
     * @dev Return the holdings of a specific address. Returns dynamic array of all cryptos.
     *      Start and end is used in case there are a large number of cryptos in total.
     * @param _beneficiary The address to check balance of.
     * @param _start The beginning index of the array to return.
     * @param _end The (inclusive) end of the array to return.
    **/
    function returnHoldings(address _beneficiary, uint256 _start, uint256 _end)
      external
      view
    returns (uint256[] memory holdings)
    {
        require(_start <= _end);
        
        holdings = new uint256[](_end.sub(_start)+1); 
        for (uint256 i = 0; i < holdings.length; i++) {
            holdings[i] = userHoldings[_beneficiary][_start+i];
        }
        return holdings;
    }
    
/** ************************** Only Owner ********************************** **/
    
    /**
     * @dev Used to switch out the investment contract address to a new one.
     * @param _newAddress The address of the new investment contract.
    **/
    function changeInvestment(address _newAddress)
      external
      onlyOwner
    {
        investmentAddress = _newAddress;
    }
    
/** ************************** Only Coinvest ******************************* **/
    
    /**
     * @dev Allow the owner to take Ether or tokens off of this contract if they are accidentally sent.
     * @param _tokenContract The address of the token to withdraw (0x0 if Ether).
    **/
    function tokenEscape(address _tokenContract)
      external
      coinvestOrOwner
    {
        if (_tokenContract == address(0)) coinvest.transfer(address(this).balance);
        else {
            ERC20Interface lostToken = ERC20Interface(_tokenContract);
        
            uint256 stuckTokens = lostToken.balanceOf(address(this));
            lostToken.transfer(coinvest, stuckTokens);
        }    
    }
    
}