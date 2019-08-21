pragma solidity ^0.4.24;

/**
 * @title ERC20Basic
 * @dev Simpler version of ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/179
 */
contract ERC20Basic {
  function totalSupply() public view returns (uint256);
  function balanceOf(address who) public view returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}

/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender) public view returns (uint256);
  function transferFrom(address from, address to, uint256 value) public returns (bool);
  function approve(address spender, uint256 value) public returns (bool);
  event Approval(address indexed owner, address indexed spender, uint256 value);
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
    emit OwnershipTransferred(owner, newOwner);
    owner = newOwner;
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
  function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
    if (a == 0) {
      return 0;
    }
    c = a * b;
    assert(c / a == b);
    return c;
  }

  /**
  * @dev Integer division of two numbers, truncating the quotient.
  */
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    // uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return a / b;
  }

  /**
  * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
  */
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  /**
  * @dev Adds two numbers, throws on overflow.
  */
  function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
    c = a + b;
    assert(c >= a);
    return c;
  }
}

contract ContractiumNatmin is Ownable {
    using SafeMath for uint256;
    
    uint256 constant public CTU_RATE = 19500; // 1 ETH/19500 CTU
    uint256 constant public NAT_RATE = 10400; // 1 ETH/10400 NAT
    
    mapping (string => ERC20) tokenAddresses;
    mapping (string => address) approverAddresses;
    uint256 receivedETH;
    
    event Deposit(address indexed _from, uint256 _ctuAmount, uint256 _natAmount);
    
    constructor(
        address _ctu,
        address _nat,
        address _approverCTUAddress,
        address _approverNATAddress
    ) public {
        setToken(_ctu, "CTU");
        setToken(_nat, "NAT");
        setApproverCTUAddress(_approverCTUAddress);
        setApproverNATAddress(_approverNATAddress);
    }
    
    function () public payable {
        address sender = msg.sender;
        uint256 depositAmount = msg.value;
        uint256 halfOfDepositAmount = depositAmount.div(2);
        uint256 ctuAmount = depositAmount.mul(CTU_RATE);
        uint256 natAmount = depositAmount.mul(NAT_RATE);
        ERC20 ctuToken = tokenAddresses["CTU"];
        ERC20 natToken = tokenAddresses["NAT"];
        
        require(ctuToken.transferFrom(approverAddresses["CTU"], sender, ctuAmount));
        require(natToken.transferFrom(approverAddresses["NAT"], sender, natAmount));
        
        receivedETH = receivedETH + depositAmount;
        
        approverAddresses["CTU"].transfer(halfOfDepositAmount);
        approverAddresses["NAT"].transfer(depositAmount.sub(halfOfDepositAmount));
        
        emit Deposit(sender, ctuAmount, natAmount);
    }
    
    function setApproverCTUAddress(address _address) public onlyOwner {
        setApprover(_address, "CTU");
    }
    
    function setApproverNATAddress(address _address) public onlyOwner {
        setApprover(_address, "NAT");
    }
    
    
    function getAvailableCTU() public view returns (uint256) {
        return getAvailableToken("CTU");
    }
    
    function getAvailableNAT() public view returns (uint256) {
        return getAvailableToken("NAT");
    }
    
    function getTokenAddress(string _tokenSymbol) public view returns (address) {
        return tokenAddresses[_tokenSymbol];
    }
    
    function getApproverAddress(string _tokenSymbol) public view returns (address) {
        return approverAddresses[_tokenSymbol];
    }
    
    function getAvailableToken(string _tokenSymbol) internal view returns (uint256) {
        ERC20 token = tokenAddresses[_tokenSymbol];
        uint256 allowance = token.allowance(approverAddresses[_tokenSymbol], this);
        uint256 approverBalance = token.balanceOf(approverAddresses[_tokenSymbol]);
        
        return allowance > approverBalance ? approverBalance : allowance;
    }
    
    function setToken(address _address, string _symbol) internal onlyOwner {
        require(_address != 0x0);
        tokenAddresses[_symbol] = ERC20(_address);
    }
    
    function setApprover(address _address, string _tokenSymbol) internal onlyOwner {
        require(_address != 0x0);
        approverAddresses[_tokenSymbol] = _address;
    }
    
}